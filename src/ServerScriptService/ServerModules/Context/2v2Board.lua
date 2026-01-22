print("2v2Board")
local _f = require(script.Parent.Parent)

local board = {}
local Group

local storage = game:GetService('ServerStorage')
local Utilities = _f.Utilities
local create = Utilities.Create
local write = Utilities.Write
local uid = Utilities.uid
local roundedFrame = require(storage.Plugins.RoundedFrame2){Utilities=Utilities}

local sbw, scrollList, container
local gui, hostButton

local Groups = {}
local function groupsInOrder()
	local g = {}
	for _, group in pairs(Groups) do
		table.insert(g, group)
	end
	table.sort(g, function(a, b) return a.createdAt < b.createdAt end)
	return g
end

local publicEvents = {'teamWith', 'kick', 'setReady', 'updateSelection', 'setTPReady'}
local publicFunctions = {'getButtons', 'hostGroup', 'joinGroup', 'leaveGroup'}
_f.Network:bindEvent('2v2e', function(player, fn, ...)
	if not publicEvents[fn] then return end
	board[fn](board, player, ...)
end)
_f.Network:bindFunction('2v2f', function(player, fn, ...)
	if not publicFunctions[fn] then return end
	local args = {...}
	local s, r = pcall(function() return board[fn](board, player, unpack(args)) end)
	if s then return r else print('2v2_BOARD_ERROR:', r) end
end)
do -- move values to keys
	local pe, pf = {}, {}
	for _, s in pairs(publicEvents)    do pe[s] = true end
	for _, s in pairs(publicFunctions) do pf[s] = true end
	publicEvents, publicFunctions = pe, pf
end

local function getGroupFromHost(player)
	for _, group in pairs(Groups) do
		if group.hostPlayer == player then
			return group
		end
	end
end

function board:getButtons(player)
	local joinButtons = {}
	for _, group in pairs(Groups) do
		if group.joinButton then
			table.insert(joinButtons, group.joinButton.gui)
		end
	end
	return {hostButton.gui, joinButtons}
end

function board:hostGroup(player, settings)
	-- filter
	for _, otherGroup in pairs(Groups) do
		for _, member in pairs(otherGroup.members) do
			if member == player then
				return nil
			end
		end
	end
	settings.hostPlayer = player
	local group = Group:new(settings)
	board:update()
	return group.id
end

function board:joinGroup(player, button)
	for _, group in pairs(Groups) do
		if group.joinButton.gui == button then
			local canJoin = not group.inviteOnly
			if not canJoin then
				-- check if invited; set canJoin if so
			end
			if canJoin and #group.members < 4 and #group.members > 0 and not group.battling and (not group.kickedAt[player.Name] or tick()-group.kickedAt[player.Name]>15) then
				-- ensure player is not already in group
				for _, otherGroup in pairs(Groups) do
					for _, member in pairs(otherGroup.members) do
						if member == player then
							return nil
						end
					end
				end
				table.insert(group.members, player)
				group:updateMembers()
				return group.id
			end
			return nil
		end
	end
end

function board:leaveGroup(player, groupId)
	local group = Groups[groupId]
	if not group or group.battling then return false end
	local playerIndex
	for i, member in pairs(group.members) do
		if member == player then
			playerIndex = i
			break
		end
	end
	if not playerIndex then return false end
	if #group.members == 1 then
		Groups[groupId] = nil
		group:remove()
		board:update()
		return true
	end
	if playerIndex == 2 and #group.members == 4 then
		group.members[2] = group.members[4]
		group.members[4] = nil
	else
--		if playerIndex == 1 then
			group.ready = {}
--		end
		table.remove(group.members, playerIndex)
	end
	group.hostPlayer = group.members[1]
	group:updateMembers()
	return true
end

function board:teamWith(hostPlayer, teamWithPlayerNamed)
	local group = getGroupFromHost(hostPlayer)
	if not group or #group.members < 3 or group.battling then return end
	local playerIndex
	if group.members[2].Name == teamWithPlayerNamed then playerIndex = 2
	elseif group.members[4] and group.members[4].Name == teamWithPlayerNamed then playerIndex = 4 end
	if not playerIndex then return end
	group.members[3], group.members[playerIndex] = group.members[playerIndex], group.members[3]
	group.ready = {}
	group:updateMembers()
end

function board:kick(hostPlayer, kickPlayerNamed)
	if not hostPlayer or hostPlayer.Name == kickPlayerNamed then return end
	local group = getGroupFromHost(hostPlayer)
	if not group or group.battling then return end
	for i, member in pairs(group.members) do
		if i ~= 1 and member.Name == kickPlayerNamed then
			group.ready = {}
			pcall(function() _f.Network:post('2v2e', member, 'updateMembers') end)
			if i == 2 and #group.members == 4 then
				group.members[2] = group.members[4]
				group.members[4] = nil
			else
				table.remove(group.members, i)
			end
			group.kickedAt[kickPlayerNamed] = tick()
			group:updateMembers()
			return
		end
	end
end

function board:setReady(player, groupId, isReady)
	local group = Groups[groupId]
	if not group or group.battling then return end
	for i, member in pairs(group.members) do
		if member == player then
			if i == 1 then
				if #group.members ~= 4 then return end
				for j = 2, 4 do
					if not group.ready[group.members[j].Name] then return end
				end
				-- START BATTLE!
				group:startBattle()
			else
				group.ready[player.Name] = isReady
				for _, player in pairs(group.members) do
					pcall(function() _f.Network:post('2v2e', player, 'updateReady', group.ready) end)
				end
			end
			return
		end
	end
end

function board:updateSelection(player, ...)
	for _, group in pairs(Groups) do
		if group.members then
			for i, member in pairs(group.members) do
				if member == player then
					if select(1, ...) == 'ready' then
						group.tpReady[i] = true
						if group.tpReady[1] and group.tpReady[2] and group.tpReady[3] and group.tpReady[4] then
							for _, member in pairs(group.members) do
								pcall(function() _f.Network:post('BattleRequest', member, 'server', {teamPreviewReady = true}) end)
							end
						end
					end
					local partner = group.members[(i+1)%4+1]
					pcall(function(...) _f.Network:post('2v2TPUS', partner, ...) end, ...)
					return
				end
			end
		end
	end
end

Group = Utilities.class({}, function(self)
	self.inviteOnly = false -- disable for now
	
	self.members = {self.hostPlayer,
		
		-- test stuff
--		{Name = 'tbradm'},
--		{Name = 'WoahhBob'},
--		{Name = 'John Doe'}
		--
		
	}
	self.invitations = {} -- todo
	self.ready = {}--tbradm=true}
	self.tpReady = {}
	self.kickedAt = {}
	local c = roundedFrame:new {
		CornerRadius = 20,
		BackgroundColor3 = Color3.fromRGB(25, 35, 50),
		Size = UDim2.new(.98, 0, .12, 0),
		Parent = container
	}
	local nameContainers = {}
	for i = 0, 3 do
		nameContainers[i+1] = create 'Frame' {
			ClipsDescendants = true,
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.33, 0, .5, 0),
			Position = UDim2.new(.01+.35*(i%2), 0, .02+.43*math.floor(i/2), 0),
			Parent = c.gui
		}
	end
	self.nameContainers = nameContainers
	self.countFrame = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(0.0, 0, 0.3, 0),
		Position = UDim2.new(0.75, 0, 0.35, 0),
		ZIndex = 2, Parent = c.gui
	}
	local joinButton = roundedFrame:new {
		Button = true,
		CornerRadius = 15,
		BackgroundColor3 = Color3.fromRGB(47, 69, 99),
		Size = UDim2.new(.2, 0, .5, 0),
		Position = UDim2.new(.79, 0, 0.1, 0),
		ZIndex = 2, Parent = c.gui
	}
	if self.inviteOnly then
		--[[
		write 'Join' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.7, 0),
				Position = UDim2.new(0.5, 0, 0.15, 0),
				ZIndex = 3, Parent = joinButton.gui
			}, Scaled = true, Transparency = .5
		}--]]
		create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5267100735',
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(.8, 0, .8, 0),
			AnchorPoint = Vector2.new(.5, .5),
			Position = UDim2.new(.5, 0, .5, 0),
			ZIndex = 4, Parent = joinButton.gui
		}
	else
		write 'Join' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.7, 0),
				Position = UDim2.new(0.5, 0, 0.15, 0),
				ZIndex = 3, Parent = joinButton.gui
			}, Scaled = true
		}
	end
	self.joinButton = joinButton
	self.gui = c
--	if self.inviteOnly then
--		self:updateIcon(5267100735)--5267102890)
--	end
	self:updateMembers()
	
	local id; repeat id = uid() until not Groups[id]
	self.id = id
	Groups[id] = self
	self.createdAt = tick()
	board:update()
	
	_f.Network:postAll('2v2e', 'newButton', joinButton.gui)
end)

--function Group:updateIcon(id)
--	if self.icon then
--		self.icon:remove()
--		self.icon = nil
--	end
--	if not id then return end
--	self.icon = create 'ImageLabel' {
--		BackgroundTransparency = 1.0,
--		Image = 'rbxassetid://'..id,
--		SizeConstraint = Enum.SizeConstraint.RelativeYY,
--		Size = UDim2.new(.8, 0, .8, 0),
--		Position = UDim2.new(.01, 0, .08, 0),
--		ZIndex = 2, Parent = self.gui.gui,
--	}
--end

function Group:updateMembers()
	if not self.members then return end
	local names = {}
	for _, player in pairs(self.members) do
		table.insert(names, player.Name)
		pcall(function() _f.Network:post('2v2e', player, 'updateMembers', self.members, self.ready) end)
	end
	local cnames = self.cachedDisplayNames
	if not cnames then
		cnames = {}
		self.cachedDisplayNames = cnames
	end
	for i = 1, 4 do
		local name = names[i]
		local cname = cnames[i]
		if cname ~= name then
			self.nameContainers[i]:ClearAllChildren()
			cnames[i] = name
			if name then
				write(name) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.6, 0),
						Position = UDim2.new(0.05, 0, 0.2, 0),
						ZIndex = 2, Parent = self.nameContainers[i]
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = Utilities.GetNameColor(name)
				}
			end
		end
	end
--[[	self.overflowThread = nil
	if self.nameList then
		self.nameList:remove()
	end
	local nameList = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 0.5, 0),
		Position = UDim2.new(0.0, 0, 0.25, 0),
		ZIndex = 2, Parent = create 'Frame' {
			ClipsDescendants = true,
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.535, 0, 1.0, 0),
			Position = UDim2.new(0.075, 0, 0.0, 0),
			Parent = self.gui.gui,
		}
	}
	local nameContainer = write(table.concat(names, ', ')) { Frame = nameList, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, }
	if nameContainer.Frame.AbsoluteSize.X > nameList.AbsoluteSize.X then
		spawn(function()
			local thisThread = {}
			self.overflowThread = thisThread
			local oversize = (nameContainer.Frame.AbsoluteSize.X - nameList.AbsoluteSize.X) / nameList.AbsoluteSize.X
			while self.overflowThread == thisThread do
				wait(2)
				Utilities.Tween(oversize*3, nil, function(a)
					if self.overflowThread ~= thisThread then return false end
					nameContainer.Frame.Position = UDim2.new(-oversize*a, 0, 0.0, 0)
				end)
				if self.overflowThread ~= thisThread then break end
				wait(2)
				Utilities.Tween(oversize*3, nil, function(a)
					if not self.overflowThread ~= thisThread then return false end
					nameContainer.Frame.Position = UDim2.new(-oversize*(1-a), 0, 0.0, 0)
				end)
			end
		end)
	end--]]
	local n = #self.members
	if n ~= self.nWritten then
		self.countFrame:ClearAllChildren()
		write(n..'/4') {Frame = self.countFrame, Scaled = true}
		self.nWritten = n
	end
end

function Group:startBattle()
	self.battling = true
	local icons = {}
	local teams = {}
	for _, member in pairs(self.members) do
		pcall(function()
			local PlayerData = _f.PlayerDataService[member]
			icons[member] = PlayerData:getTeamPreviewIcons()
			teams[member] = PlayerData:getBattleTeam(true) -- note that we don't input the order right away; we do, however, want a snapshot that matches icons
		end)
	end
	local battle = _f.BattleEngine:new {
		battleType = 3,
		forcedLevel = self.forcedLevel,
		gameType = 'doubles',
		allowSpectate = self.allowSpectate,
		location = self.location
	}
	local sig = Utilities.Signal()
	battle.endSignal = sig
	battle.roster = self.members
	battle.playerTeams = teams
	for i, member in pairs(self.members) do
		local opponent1 = self.members[i%2==1 and 2 or 1]
		local opponent2 = self.members[i%2==1 and 4 or 3]
		local partner = self.members[(i+1)%4+1]
		local battle = {
			battleId = battle.id,
			is2v2 = true,
			sideId = 'p'..(2-(i%2)),
			myTeamN = i<3 and 1 or 2,
			gameType = 'doubles',
			icons = {
				icons[member],
				icons[partner],
				self.teamPreviewEnabled and icons[opponent1] or nil,
				self.teamPreviewEnabled and icons[opponent2] or nil
			},
			opponent1 = opponent1,
			opponent2 = opponent2,
			partner = partner
		}
		pcall(function() _f.Network:post('2v2e', member, 'joinBattle', battle) end)
	end
	sig:wait()
	self.battling = false
	self.ready = {}
	self:updateMembers()
end

function Group:remove()
	Groups[self.id] = nil
	self.overflowThread = nil
	self.members = nil
	pcall(function() self.joinButton:remove() end)
	pcall(function() self.gui:remove() end)
	-- TODO: remove cached display names?
end


function board:update()
	if not container then return end
	local h = .13
	
	local groups = groupsInOrder()
	
	local n = #groups
	local contentRelativeSize = n * h * container.AbsoluteSize.X / scrollList.AbsoluteSize.Y
	scrollList.CanvasSize = UDim2.new(scrollList.Size.X.Scale, -1, contentRelativeSize * scrollList.Size.Y.Scale, 0)
	for i, g in pairs(groups) do
		g.gui.Position = UDim2.new(0.0, 0, h*(i-1), 0)
	end
end

function board:enable(guiContainer)
	gui = guiContainer
	
	write '2v2 Battles' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.3, 0, 0.01, 0),
			Parent = gui,
		}, Scaled = true,
	}
	
	hostButton = roundedFrame:new {
		Button = true,
		CornerRadius = 20,
		BackgroundColor3 = Color3.fromRGB(47, 69, 99),
		Size = UDim2.new(.25, 0, .1, 0),
		Position = UDim2.new(.6, 0, 0.0, 0),
		Parent = gui,
	}
	write 'Host' { --'+ Host' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.7, 0),
			Position = UDim2.new(0.5, 0, 0.15, 0),
			ZIndex = 2, Parent = hostButton.gui,
		}, Scaled = true
	}
	
	sbw = math.ceil(gui.AbsoluteSize.X*.04)
	scrollList = create 'ScrollingFrame' {
		BackgroundTransparency = 1.0,
		BorderSizePixel = 0,
		Size = UDim2.new(1.0, 0, 0.875, 0),
		Position = UDim2.new(0.0, 0, 0.15, 0),
		ScrollBarThickness = sbw,
		Parent = gui
	}
	container = create 'Frame' {
		BackgroundTransparency = 1.0,
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Size = UDim2.new(1.0, -sbw, 1.0, -sbw),
		Parent = scrollList
	}
end

game:GetService('Players').ChildRemoved:connect(function()
	for groupId, group in pairs(Groups) do
		local update = false
		for i = #group.members, 1, -1 do
			local member = group.members[i]
			if not member or not member.Parent then
				-- todo: if group.battling then...?
				if #group.members == 1 then
					Groups[groupId] = nil
					group:remove()
					board:update()
					update = false
					break
				else
					if i == 2 and #group.members == 4 then
						group.members[2] = group.members[4]
						group.members[4] = nil
					else
						group.ready = {}
						table.remove(group.members, i)
					end
					group.hostPlayer = group.members[1]
					update = true
				end
			end
		end
		if update and not group.battling then
			group:updateMembers()
		end
	end
end)

return board