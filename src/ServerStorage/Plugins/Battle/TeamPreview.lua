return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
local Utilities = _p.Utilities
local create = Utilities.Create
local write = Utilities.Write

local COLOR_BACKGROUND = Color3.fromRGB(65, 65, 70)

local COLOR_PLAYER_FRAME = Color3.fromHSV(4/6, .3, .5)--Color3.new(.68, .83, .72)
local COLOR_PLAYER_ICON  = Color3.fromHSV(4/6, .25, .3)--Color3.new(.4, .45, .4)
local COLOR_PLAYER_ICON_DISABLED = Color3.fromHSV(4/6, .3, .2)


local COLOR_SELECTOR_FRAME = Color3.fromHSV(0, .6, .5)--Color3.new(.68, .72, .83)
local COLOR_SELECTOR_ICON  = Color3.fromHSV(0, .5, .3)--Color3.new(.4, .4, .45)

local COLOR_OTHERPLAYER_FRAME = Color3.new(.7, .7, .7)
local COLOR_OTHERPLAYER_ICON  = Color3.new(.4, .4, .4)

local COLOR_PARTNERREADY_FRAME = BrickColor.new('Bright green').Color--Color3.fromHSV(1/3, .6, .5)--
local COLOR_PARTNERREADY_ICON  = Color3.fromHSV(1/3, .5, .3)--BrickColor.new('Dark green').Color--

local ID_CIRCLE = 'rbxasset://textures/WhiteCircle.png'

local margin = .15--.2
local outFirst = 1.25
local inOffset = outFirst-1
local styles = {
	default = {
		xElems = 6 + 7*margin,
		yElems = 1 + 2*margin,
	},
	twoRows = {
		xElems = 3 + 4*margin,
		yElems = 2 + 3*margin,
		offset4x = -3-3*margin, offset5x = -3-3*margin, offset6x = -3-3*margin,
		offset4y =    1+margin, offset5y =    1+margin, offset6y =    1+margin,
		isTwoRows = true,
	},
	singleSelector = {
		xElems = 5 + outFirst + 7*margin,
		yElems = outFirst + 2*margin,
		scale1 = outFirst,
		offset2x = inOffset, offset3x = inOffset, offset4x = inOffset, offset5x = inOffset, offset6x = inOffset, 
		offset2y = inOffset, offset3y = inOffset, offset4y = inOffset, offset5y = inOffset, offset6y = inOffset,
		isSelector = true,
	},
	unratedSelector = {
		xElems = 5 + outFirst + 7*margin,
		yElems = outFirst + 2*margin,
		scale1 = outFirst,
		offset2x = inOffset, offset3x = inOffset, offset4x = inOffset, offset5x = inOffset, offset6x = inOffset, 
		offset2y = inOffset, offset3y = inOffset, offset4y = inOffset, offset5y = inOffset, offset6y = inOffset,
		isSelector = true,
	},
	doubleSelector = {
		xElems = 4 + outFirst*2 + 7*margin,
		yElems = outFirst + 2*margin,
		scale1 = outFirst, scale2 = outFirst,
		offset2x = inOffset, offset3x = inOffset*2, offset4x = inOffset*2, offset5x = inOffset*2, offset6x = inOffset*2, 
		                     offset3y = inOffset,   offset4y = inOffset,   offset5y = inOffset,   offset6y = inOffset,
		isSelector = true,
	},
	tripleSelector = {
		xElems = 3 + outFirst*3 + 7*margin,
		yElems = outFirst + 2*margin,
		scale1 = outFirst, scale2 = outFirst, scale3 = outFirst,
		offset2x = inOffset, offset3x = inOffset*2, offset4x = inOffset*3, offset5x = inOffset*3, offset6x = inOffset*3, 
		                                            offset4y = inOffset,   offset5y = inOffset,   offset6y = inOffset,
		isSelector = true,
	},
	halfSelector = {
		xElems = 2 + outFirst + 4*margin,
		yElems = outFirst + 2*margin,
		scale1 = outFirst,
		offset2x = inOffset, offset3x = inOffset,
		offset2y = inOffset, offset3y = inOffset,
		maxIcons = 3,
		isSelector = true,
	},
}
for _, style in pairs(styles) do
	if style.xElems and style.yElems then
		style.ratio = style.xElems / style.yElems
	end
end


local tp = {}

local bg = create 'ImageButton' {
	AutoButtonColor = false,
	Selectable = false,
	BackgroundColor3 = COLOR_BACKGROUND,
	BorderSizePixel = 0,
	Size = UDim2.new(1.0, 0, 1.0, 36),
	Position = UDim2.new(0.0, 0, 0.0, -36),
}



function tp:prepare(battle)
	self.finished = false
	self.timerFinished = false
	local pIcons = {}
	for i, id in pairs(battle.icons[1]) do
		pIcons[i] = _p.Pokemon:getIcon(unpack(id))
	end
	battle.teamPreviewPartyIcons = pIcons
end

function tp:startTimer(is2v2)
	local start = tick()
	Utilities.fastSpawn(function()
		local gui = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.0, 0, .07, 0),
			Position = UDim2.new(is2v2 and .5 or .7, 0,.115, 0),
			ZIndex = 10, Parent = Utilities.gui
		}
		local countdown = 60
		for i = countdown, 0, -1 do
			if self.timerFinished then break end
			gui:ClearAllChildren()
			local s = tostring(i%60)
			if s:len()<2 then s = '0'..s end
			Utilities.Write(math.floor(i/60)..':'..s){Frame = gui, Scaled = true}
			wait((countdown-i+1)-(tick()-start))
		end
		gui:remove()
		if not self.finished and self.forceAutoFinish then
			self.finished = true
			_p.NPCChat:clear()
			self.forceAutoFinish:fire()
		end
	end)
end


local function makeTeamGui(frameColor, iconColor, maxWidth, maxHeight, centerX, centerY, name, iconList, kind)
	local style = styles.default; if kind then style = styles[kind] or style end
	local xElems, yElems, ratio = style.xElems, style.yElems, style.ratio
	local margin = style.margin or margin
	local maxIcons = style.maxIcons or 6
	local isTwoRows = style.isTwoRows or false
	
	local rf = _p.RoundedFrame:new {
		Style = (not isTwoRows) and 'HorizontalBar' or nil,
		BackgroundColor3 = frameColor,
		ZIndex = 4
	}
	if name then
		local size = isTwoRows and .15 or .3
		write(name) {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(.0, 0, size, 0),
				Position = UDim2.new(.03, 0, -size*4/3.5, 0),
				ZIndex = 7, Parent = rf.gui
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left
		}
	end
	local buttons, icons = {}, {}
	for i = 1, maxIcons do
		local img = create 'ImageButton' {
			Name = tostring(i),
			BackgroundTransparency = 1.0,
			Image = ID_CIRCLE,
			ImageColor3 = iconColor,
			ZIndex = 5, Parent = rf.gui
		}
		buttons[i] = img
		if iconList then
			local icon = iconList[i]
			if icon then
				if type(icon) == 'table' then
					icon = _p.Pokemon:getIcon(unpack(icon))
				end
				icon.Size = UDim2.new(1.0, 0, .75, 0)
				icon.Position = UDim2.new(.0, 0, .125, 0)
				icon.ZIndex = 6
				icon.Parent = img
				icons[i] = icon
			end
		elseif not style.isSelector then
			write '?' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, .5, 0),
					Position = UDim2.new(0.5, 0, .25, 0),
					ZIndex = 6, Parent = img
				}, Scaled = true, Color = frameColor
			}
		end
	end
	rf.tgUpdate = function(screenSize)
		if screenSize.X * maxWidth / ratio > screenSize.Y * maxHeight then
			-- Base on Y
			rf.SizeConstraint = Enum.SizeConstraint.RelativeYY
			rf.Size = UDim2.new(maxHeight*ratio, 0, maxHeight, 0)
			rf.Position = UDim2.new(centerX, -rf.gui.AbsoluteSize.X/2, centerY-maxHeight/2, 0)
		else
			-- Base on X
			rf.SizeConstraint = Enum.SizeConstraint.RelativeXX
			rf.Size = UDim2.new(maxWidth, 0, maxWidth/ratio, 0)
			rf.Position = UDim2.new(centerX-maxWidth/2, 0, centerY, -rf.gui.AbsoluteSize.Y/2)
		end
		for i = 1, maxIcons do
			local scale = style['scale'..i] or 1
			local xOffset = style['offset'..i..'x'] or 0
			local yOffset = style['offset'..i..'y'] or 0
			local img = buttons[i]
			img.Size = UDim2.new(scale/xElems, 0, scale/yElems, 0)
			img.Position = UDim2.new((margin+xOffset+(i-1)*(1+margin))/xElems, 0, (margin+yOffset)/yElems, 0)
		end
	end
	rf.tgButtons = buttons
	rf.tgIcons = icons
--	rf.tgStyle = style
	return rf
end




function tp:getOrder(battle)
	local gameType = battle.gameType or 'singles'
	local is2v2 = battle.is2v2 and true or false
	
	bg.Parent = Utilities.gui
	local screen = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Position = UDim2.new(0.0, 0, 0.0, 0),
		Parent = Utilities.gui,
		
		create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = ID_CIRCLE,
			ImageColor3 = Color3.fromRGB(65*1.2, 65*1.2, 70*1.2),
			ImageRectSize = Vector2.new(256, 144),
			ImageRectOffset = Vector2.new(128, 0),
			Size = UDim2.new(1.0, 0, .75, 0),
			Position = UDim2.new(0.0, 0, .25, 0),
			ZIndex = 2--, Parent = screen
		}
	}
	local update
	local pIcons = battle.teamPreviewPartyIcons
	local amReady, amBusy = false, false
	local ready = _p.RoundedFrame:new {
		Button = true,
		BackgroundColor3 = BrickColor.new('Electric blue').Color,
		Size = UDim2.new(.15, 0, .1, 0),
		Position = UDim2.new(.825, 0, .725, 0),
		ZIndex = 3, Parent = screen
	}
	write 'Ready' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.0, 0, .5, 0),
			Position = UDim2.new(.5, 0, .25, 0),
			ZIndex = 4, Parent = ready.gui
		}, Scaled = true
	}
	
	write 'Select' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, .06, 0),
			Position = UDim2.new(.1, 0, .695, 0),
			ZIndex = 5, Parent = screen
		}, Scaled = true
	}
	write 'pokemon' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, .06, 0),
			Position = UDim2.new(.1, 0, .795, 0),
			ZIndex = 5, Parent = screen
		}, Scaled = true
	}
	
	local prf, brf
	local otherRFs = {}
	local order = {0, 0, 0, 0, 0, 0}
	local moveIconTo -- defined below
	
	if is2v2 then
		--makeTeamGui(frameColor, iconColor, maxWidth, maxHeight, centerX, centerY, name, iconList, kind)
		local leftOpponent = makeTeamGui(COLOR_OTHERPLAYER_FRAME, COLOR_OTHERPLAYER_ICON, .35/1.25, .175*1.25, .35, .175, battle.opponent2.Name, battle.icons[4], 'twoRows')
		leftOpponent.Parent = screen
		table.insert(otherRFs, leftOpponent)
		
		local rightOpponent = makeTeamGui(COLOR_OTHERPLAYER_FRAME, COLOR_OTHERPLAYER_ICON, .35/1.25, .175*1.25, .65, .175, battle.opponent1.Name, battle.icons[3], 'twoRows')
		rightOpponent.Parent = screen
		table.insert(otherRFs, rightOpponent)
		
		local amLeft = battle.myTeamN == 1
		
		local partnerUnselectedTeam = makeTeamGui(COLOR_OTHERPLAYER_FRAME, COLOR_OTHERPLAYER_ICON, .48/1.5, .2*1.5, amLeft and .65 or .35, .5, battle.partner.Name, battle.icons[2], 'twoRows')
		partnerUnselectedTeam.Parent = screen
		table.insert(otherRFs, partnerUnselectedTeam)
		
		local partnerSelectedTeam = makeTeamGui(COLOR_OTHERPLAYER_FRAME, COLOR_OTHERPLAYER_ICON, .25, .2, amLeft and .65 or .35, .8, nil, nil, 'halfSelector')
		partnerSelectedTeam.Parent = screen
		table.insert(otherRFs, partnerSelectedTeam)
		
		prf = makeTeamGui(COLOR_PLAYER_FRAME, COLOR_PLAYER_ICON, .48/1.5, .2*1.5, amLeft and .35 or .65, .5, _p.PlayerData.trainerName, pIcons, 'twoRows')
		prf.Parent = screen
		
		brf = makeTeamGui(COLOR_SELECTOR_FRAME, COLOR_SELECTOR_ICON, .25, .2, amLeft and .35 or .65, .8, nil, nil, 'halfSelector')
		brf.Parent = screen
		
		-- connect partner's changes
		_p.Network:bindEvent('2v2TPUS', function(originalPartyIndex, activePartyIndex)
			if not partnerUnselectedTeam.Parent then return end
			if originalPartyIndex == 'ready' then
				partnerSelectedTeam.BackgroundColor3 = COLOR_PARTNERREADY_FRAME
				for _, button in pairs(partnerSelectedTeam.tgButtons) do
					button.ImageColor3 = COLOR_PARTNERREADY_ICON
				end
				return
			end
			moveIconTo(partnerUnselectedTeam.tgIcons[originalPartyIndex],
				activePartyIndex and (partnerSelectedTeam.tgButtons[activePartyIndex]) or (partnerUnselectedTeam.tgButtons[originalPartyIndex]))
		end)
		--
		
		update = function(screenSize)
			ready.CornerRadius = screenSize.Y * .03
			leftOpponent.tgUpdate(screenSize)
			rightOpponent.tgUpdate(screenSize)
			partnerUnselectedTeam.tgUpdate(screenSize)
			partnerSelectedTeam.tgUpdate(screenSize)
			prf.tgUpdate(screenSize)
			brf.tgUpdate(screenSize)
			local opcr = leftOpponent.AbsoluteSize.Y * .2
			leftOpponent.CornerRadius = opcr
			rightOpponent.CornerRadius = opcr
			local tcr = prf.AbsoluteSize.Y * .2
			prf.CornerRadius = tcr
			partnerUnselectedTeam.CornerRadius = tcr
		end
	elseif gameType == 'singles'or gameType == 'unrated' or gameType == 'doubles' or gameType == 'triples' then
		local orf = makeTeamGui(COLOR_OTHERPLAYER_FRAME, COLOR_OTHERPLAYER_ICON, .35, .175, .425, .15, battle.opponent.Name, battle.icons[2])
		orf.Parent = screen
		table.insert(otherRFs, orf)
		
		prf = makeTeamGui(COLOR_PLAYER_FRAME, COLOR_PLAYER_ICON, .48, .2, .5, .45, _p.PlayerData.trainerName, pIcons)
		prf.Parent = screen
		
		brf = makeTeamGui(COLOR_SELECTOR_FRAME, COLOR_SELECTOR_ICON, .6, .25, .5, .775, nil, nil, gameType:sub(1, -2)..'Selector')
		brf.Parent = screen
		
		update = function(screenSize)
			ready.CornerRadius = screenSize.Y * .03
			orf.tgUpdate(screenSize)
			prf.tgUpdate(screenSize)
			brf.tgUpdate(screenSize)
		end
	end
	local function printOrder() end--print(table.concat(order, ', ')) end
	moveIconTo = function(icon, home)
		-- send update to partner
		if is2v2 then
			--print(icon:GetFullName(), home:GetFullName())
			--Players.Player1.PlayerGui.MainGui.PokemonIcon; Players.Player1.PlayerGui.MainGui.Frame.RoundedFrame.ImageButton
			local isInActiveParty = home:IsDescendantOf(brf.gui)
			if isInActiveParty or home:IsDescendantOf(prf.gui) then
				local originalPartyIndex
				for i, otherIcon in pairs(prf.tgIcons) do
					if icon == otherIcon then
						originalPartyIndex = i
						break
					end
				end
				if originalPartyIndex then
--					print(originalPartyIndex, isInActiveParty and tonumber(home.Name) or nil)
					_p.Network:post('2v2e', 'updateSelection', originalPartyIndex, isInActiveParty and tonumber(home.Name) or nil)
				end
			end
		end
		--
		local startSize = icon.AbsoluteSize
		local startPosition = icon.AbsolutePosition
		local endSize = Vector2.new(home.AbsoluteSize.X, home.AbsoluteSize.Y*.75)
		local endPosition = Vector2.new(home.AbsolutePosition.X, home.AbsolutePosition.Y+home.AbsoluteSize.Y*.125)
		icon.Parent = Utilities.gui
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			local size = startSize:lerp(endSize, a)
			local position = startPosition:lerp(endPosition, a)
			icon.Size = UDim2.new(0.0, size.X, 0.0, size.Y)
			icon.Position = UDim2.new(0.0, position.X, 0.0, position.Y)
		end)
		icon.Parent = home
		icon.Size = UDim2.new(1.0, 0, 0.75, 0)
		icon.Position = UDim2.new(0.0, 0, 0.125, 0)
	end
	local icons = prf.tgIcons
	local activeDragger, draggingIcon, pos0, draggingIndex
	local function onDragBegin(iconIndex, dragger, offset)
		if not iconIndex then return end
		local icon = icons[iconIndex]
		if not icon then return end
		draggingIndex = iconIndex
		activeDragger = dragger
		draggingIcon = icon
		local abs, abp = icon.AbsoluteSize, icon.AbsolutePosition
		icon.Size = UDim2.new(0.0, abs.X, 0.0, abs.Y)
		icon.Position = UDim2.new(0.0, abp.X+offset.X, 0.0, abp.Y+offset.Y)
		icon.Parent = Utilities.gui
		icon.ZIndex = 10
		pos0 = abp
	end
	local function onDragMove(dragger, offset)
		if not draggingIcon or dragger ~= activeDragger then return end
		draggingIcon.Position = UDim2.new(0.0, pos0.X+offset.X, 0.0, pos0.Y+offset.Y)
	end
	local function onDragEnd(dragger)
		if not draggingIcon or dragger ~= activeDragger then return end
		local icon = draggingIcon
		local fromIndex = draggingIndex
		activeDragger = nil
		draggingIcon = nil
		pos0 = nil
		draggingIndex = nil
		
		amBusy = true
		local iconSize = icon.AbsoluteSize
		local iconPosition = icon.AbsolutePosition
		local centerX = iconPosition.X+iconSize.X/2
		local centerY = iconPosition.Y+iconSize.Y/2
		local tg = brf.gui
		if centerX > tg.AbsolutePosition.X and centerX < tg.AbsolutePosition.X+tg.AbsoluteSize.X and
		   centerY > tg.AbsolutePosition.Y and centerY < tg.AbsolutePosition.Y+tg.AbsoluteSize.Y then
			local index, closestSlot, minDist
			for i, slot in pairs(brf.tgButtons) do
				local dist = (centerX-slot.AbsolutePosition.X-slot.AbsoluteSize.X/2)^2+(centerY-slot.AbsolutePosition.Y-slot.AbsoluteSize.Y/2)^2
				if not closestSlot or dist < minDist then
					minDist = dist
					closestSlot = slot
					index = i
				end
			end
			local alreadyInSlot = order[index]
			if alreadyInSlot ~= 0 then
				spawn(function() moveIconTo(icons[alreadyInSlot], prf.tgButtons[alreadyInSlot]) end)
			end
			order[index] = fromIndex
			moveIconTo(icon, closestSlot)
		else
			for slotNum, index in pairs(order) do
				if index == fromIndex then
					order[index] = 0
				end
			end
			moveIconTo(icon, prf.tgButtons[fromIndex])
		end
		icon.ZIndex = 6
		amBusy = false
		printOrder()
	end
	--TESTING BELOW
	
	--TESTING ABOVE
	local myIcons = battle.icons[1]
	for i, b in pairs(prf.tgButtons) do
--		local pokemon = _p.PlayerData.party[i]
		if myIcons[i] and myIcons[i][1] < 1450 then -- egg threshold
			local dragger = _p.Dragger:new { gui = b, clickEnabled = true }
			dragger.onClick:connect(function()
				if amReady or amBusy then return end
				for _, index in pairs(order) do
					if index == i then return end
				end
				_p.Menu.party:viewSummary(i, true, true)
			end)
			dragger.onDragBegin:connect(function(offset)
				if amReady or amBusy then return end
				for _, index in pairs(order) do
					if index == i then return end
				end
				onDragBegin(i, dragger, offset)
			end)
			dragger.onDragMove:connect(function(offset)
				onDragMove(dragger, offset)
			end)
			dragger.onDragEnd:connect(function()
				onDragEnd(dragger)
			end)
		else
			b.ImageColor3 = COLOR_PLAYER_ICON_DISABLED
		end
	end
	for i, b in pairs(brf.tgButtons) do
		local dragger = _p.Dragger:new { gui = b, clickEnabled = true }
		dragger.onClick:connect(function()
			if amReady or amBusy then return end
			local index = order[i]
			if index == 0 then return end
			if not myIcons[index] then return end
			_p.Menu.party:viewSummary(index, true, true)
		end)
		dragger.onDragBegin:connect(function(offset)
			if amReady or amBusy then return end
			local index = order[i]
			if index == 0 then return end
			order[i] = 0
			onDragBegin(index, dragger, offset)
		end)
		dragger.onDragMove:connect(function(offset)
			onDragMove(dragger, offset)
		end)
		dragger.onDragEnd:connect(function()
			onDragEnd(dragger)
		end)
	end
	local close = Utilities.Signal()
	local autoFinish = Utilities.Signal()
	self.forceAutoFinish = autoFinish
	autoFinish:connect(function()
		amBusy = true
		amReady = true
		local choiceCount = 0
		local chosen, unchosen = {}, {}
		for _, index in pairs(order) do
			if index ~= 0 then
				choiceCount = choiceCount + 1
				chosen[index] = true
			end
		end
		for i, p in pairs(myIcons) do
			if p and p[1] < 1450 and not chosen[i] then -- egg threshold
				table.insert(unchosen, i)
			end
		end
		if order[1] == 0 and choiceCount > 0 then
			for battleIndex = 2, 6 do
				local partyIndex = order[battleIndex]
				if partyIndex ~= 0 then
					order[battleIndex] = 0
					order[1] = partyIndex
					break
				end
			end
		end
		for battleIndex, b in pairs(brf.tgButtons) do
			if #unchosen == 0 then break end
			if order[battleIndex] == 0 then
				local partyIndex = table.remove(unchosen, 1)
				order[battleIndex] = partyIndex
			end
		end
		for i = 6, 1, -1 do
			if order[i] == 0 then
				table.remove(order, i)
			end
		end
		if not is2v2 then
			_p.Network:post('BattleRequest', battle.opponent, {teamPreviewReady = true})
		end
		self.forceAutoFinish = nil
		close:fire()
	end)
	ready.gui.MouseButton1Click:connect(function()
		if amReady or amBusy then return end
		amBusy = true
		local choiceCount = 0
		local chosen, unchosen = {}, {}
		for _, index in pairs(order) do
			if index ~= 0 then
				choiceCount = choiceCount + 1
				chosen[index] = true
			end
		end
		for i, p in pairs(myIcons) do
			if p and p[1] < 1450 and not chosen[i] then -- egg threshold
				table.insert(unchosen, i)
			end
		end
		printOrder()
		if #unchosen > 0 and choiceCount < #brf.tgButtons then
			if _p.NPCChat:say('[y/n]Auto-fill team with remaining Pok[e\']mon?') then
				if self.finished then return end
				local movedToFrontFrom
				if order[1] == 0 and choiceCount > 0 then
					for battleIndex = 2, 6 do
						local partyIndex = order[battleIndex]
						if partyIndex ~= 0 then
							order[battleIndex] = 0
							order[1] = partyIndex
							movedToFrontFrom = battleIndex
							spawn(function() moveIconTo(icons[partyIndex], brf.tgButtons[1]) end)
							break
						end
					end
				end
				local forceChosen = {}
				for battleIndex, b in pairs(brf.tgButtons) do
					if #unchosen == 0 then break end
					if order[battleIndex] == 0 then
						local partyIndex = table.remove(unchosen, 1)
						table.insert(forceChosen, {battleIndex, partyIndex})
						order[battleIndex] = partyIndex
						spawn(function() moveIconTo(icons[partyIndex], brf.tgButtons[battleIndex]) end)
					end
				end
				printOrder()
				wait(.5)
				if not _p.NPCChat:say('[y/n]Battle using this team?') then
					if self.finished then return end
					for _, forcedChoice in pairs(forceChosen) do
						local battleIndex, partyIndex = unpack(forcedChoice)
						spawn(function() moveIconTo(icons[partyIndex], prf.tgButtons[partyIndex]) end)
						order[battleIndex] = 0
					end
					if movedToFrontFrom then
						local partyIndex = order[1]
						order[1] = 0
						order[movedToFrontFrom] = partyIndex
						spawn(function() moveIconTo(icons[partyIndex], brf.tgButtons[movedToFrontFrom]) end)
					end
					printOrder()
					wait(.5)
					amBusy = false
					return
				end
			elseif choiceCount == 0 then
				_p.NPCChat:say('Please choose at least one pokemon.')
				amBusy = false
				return
				elseif not _p.NPCChat:say('[y/n]Proceed with only '..choiceCount..' Pok[e\']mon?') then
				amBusy = false
				return
			end
		elseif not _p.NPCChat:say('[y/n]Battle using this team?') then
			amBusy = false
			return 
		end
		amReady = true
		amBusy = false
		for i = 6, 1, -1 do
			if order[i] == 0 then
				table.remove(order, i)
			end
		end
		-- submit ready
		-- allow cancel?
		self.finished = true
		ready.gui.Parent = nil
		if not is2v2 then
			_p.Network:post('BattleRequest', battle.opponent, {teamPreviewReady = true})
		end
		self.forceAutoFinish = nil
		close:fire()
	end)
	if update then
		local updateThread
		local function needUpdate(prop)
			if prop ~= 'AbsoluteSize' then return end
			local thread = {}
			updateThread = thread
			wait(.1)
			if updateThread ~= thread then return end
			update(screen.AbsoluteSize)
		end
		screen.Changed:connect(needUpdate)
		update(screen.AbsoluteSize)
	end
	
	close:wait()
	if is2v2 then
		_p.Network:post('2v2e', 'updateSelection', 'ready')
	end
	return order, function()
		_p.Network:bindEvent('2v2TPUS', nil)
		for _, rf in pairs(otherRFs) do
			pcall(function() rf:remove() end)
		end
		pcall(function() prf:remove() end)
		pcall(function() brf:remove() end)
		screen:remove()
		bg.Parent = nil
	end
end


return tp end