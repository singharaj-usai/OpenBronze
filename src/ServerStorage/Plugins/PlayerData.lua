return function(_p)
	local Utilities = _p.Utilities
	local rc4 = Utilities.rc4

	local player = _p.player

	local MAX_MONEY = 9999999
	local MAX_BP = 9999

	--local ENABLE_DEBUG_LOCATION = true -- TODO: REMOVE BEFORE PUBLISHING
	--local DEBUG_LOCATION

	local PlayerData = {
		gameBegan = false,
		trainerName = player.Name,
		badges = {},
		money = 0,
		bp = 0,
		spinTokens = 0, -- For Roulette spins
		completedEvents = {},
		expShareOn = false,
		defeatedTrainers = '',
		firstNonEggLevel = 1, -- remember us!!!
		firstNonEggAbility = '',
	}

	_p.Network:bindEvent('PDChanged', function(...) -- k1, v1, k2, v2, ... kn, vn
		local k
		for _, v in pairs({...}) do
			if k then
				PlayerData[k] = v
				if k == 'money' then
					_p.Menu.shop:updateMoneyIfActive()
				end
				k = nil
			else
				k = v
			end
		end
	end)

	_p.Network:bindEvent('eventCompleted', function(name)
		PlayerData.completedEvents = PlayerData.completedEvents or {}
		PlayerData.completedEvents[name] = true
	end)

	_p.Network:bindEvent('badgeObtained', function(i)
		PlayerData.badges[i] = true
	end)

	_p.Network:bindEvent('bpAwarded', function(amount, newTotal)
		PlayerData.bp = math.min(newTotal)
		_p.Menu.battleShop:updateBP()
		local gui = _p.RoundedFrame:new {
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.025,
			BackgroundColor3 = BrickColor.new('Deep blue').Color,
			Size = UDim2.new(.3, 0, .3, 0),
			Position = UDim2.new(.35, 0, .35, 0),
			Parent = Utilities.frontGui,
		}
		Utilities.Write('+'..amount..' BP') {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.3, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 2, Parent = gui.gui,
			}, Scaled = true,
		}
		Utilities.Write 'Remember to SAVE!' {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.15, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 2, Parent = gui.gui,
			}, Scaled = true,
		}
		local ok; ok = _p.RoundedFrame:new {
			Button = true,
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.025,
			BackgroundColor3 = BrickColor.new('Navy blue').Color,
			Size = UDim2.new(.5, 0, .3, 0),
			Position = UDim2.new(.25, 0, .6, 0),
			Parent = gui.gui,
			MouseButton1Click = function()
				ok:remove()
				gui:remove()
			end,
		}
		Utilities.Write 'OK' {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.6, 0),
				Position = UDim2.new(0.5, 0, 0.2, 0),
				ZIndex = 2, Parent = ok.gui,
			}, Scaled = true,
		}
		delay(6, function()
			pcall(function()
				ok:remove()
				gui:remove()
			end)
		end)
	end)

	_p.Network:bindEvent('ItemProductPurchased', function(itemName, itemIcon)
		game:GetService('StarterGui'):SetCore('SendNotification', {
			Title = itemName .. ' Obtained!',
			Text = 'Don\'t forget to SAVE!',
			Icon = 'rbxassetid://'..itemIcon,
			--		Duration = 5; -- Optional, defaults to 5 seconds
			--		Callback = bindableFunction; -- Optional, gets invoked with the text of the button the user pressed
			--		Button1 = "Yes"; -- Optional, makes a button appear with the given text that, when clicked, fires the Callback if it's given
			--		Button2 = "No"; -- Optional, makes another button appear with the given text that, when clicked, fires the Callback if it's given
		})
	end)

	_p.Network:bindEvent('PondPassPassPurchased', function()
		_p.PlayerData.hasPondPass = true
	end)

	_p.Network:bindEvent('spinTokensChanged', function(amount)
		PlayerData.spinTokens = amount
		if _p.Menu and _p.Menu.roulette then
			_p.Menu.roulette:updateTokenDisplay()
		end
	end)

	function PlayerData:formatMoney(m)
		return Utilities.comma_value(m or self.money)
	end

	function PlayerData:hasRedeemedPromoCode(code)
		if not self.completedEvents then return false end
		local eventName = "PromoCode_" .. code
		return self.completedEvents[eventName] == true
	end

	function PlayerData:completeEvent(event, ...)
		local r = _p.Network:get('PDS', 'completeEvent', event, ...)
		if r == false then return false end
		self.completedEvents[event] = true
		return r or true
	end

	function PlayerData:getEtc()
		if not self.gameBegan then error('attempt to save before game began') end

		local etc = {
			expShareOn = self.expShareOn,
			spinTokens = self.spinTokens or 0, -- Save spin tokens
			--		tName = self.trainerName
		}

		-- repel
		if _p.Repel.steps > 0 then
			etc.repel = {}
			etc.repel.kind = _p.Repel.kind
			etc.repel.steps = math.ceil(_p.Repel.steps/2)
		end

		-- options
		etc.options = {}
		etc.options.autosaveEnabled = _p.Autosave.enabled and true or false
		etc.options.reduceGraphics = _p.Menu.options.reduceGraphics and true or false
		etc.options.lastUnstuckTick = _p.Menu.options.lastUnstuckTick

		-- location
--[[
	if ENABLE_DEBUG_LOCATION then
		etc.location = DEBUG_LOCATION
	else]]if _p.context == 'adventure' then
			local buffer = _p.BitBuffer.Create()
			local chunk = _p.DataManager.currentChunk
			-- position
			local cframe = _p.player.Character.HumanoidRootPart.CFrame
			if chunk.id == 'gym5' and cframe.p.Y < 80 then
				cframe = CFrame.new(-130, 83, 350, -1, 0, 0, 0, 1, 0, 0, 0, -1) -- instead of loading under the dirt
			end
			if #chunk.roomStack > 0 then
				local room = chunk.roomStack[#chunk.roomStack]
				cframe = cframe - room.model.Base.Position
			end
			buffer:WriteCFrame(cframe)
			-- chunk / buildings
			buffer:WriteString(chunk.id)
			for i, room in pairs(chunk.roomStack) do
				buffer:WriteBool(true)
				buffer:WriteString(room.id)
				if i > 1 then
					buffer:WriteCFrame(room.exitCFrame-chunk.roomStack[i-1].model.Base.Position)
				end
			end
			buffer:WriteBool(false)
			etc.location = buffer:ToBase64()
		end

		return etc
	end

	function PlayerData:loadEtc(etc)
		self.trainerName = etc.tName
		self.defeatedTrainers = etc.dTrainers or ''
		self.completedEvents = etc.completedEvents --for event in pairs(self.completedEvents) do print(event) end
		_p.Events.init() -- to grab the new completedEvents table
		self.expShareOn = etc.expShareOn
		self.spinTokens = etc.spinTokens or 0 -- Load spin tokens
		local b = {}
		for k, v in pairs(etc.badges) do
			b[tonumber(k)] = v
		end
		self.badges = b

		if self.completedEvents.ReceivedRTD then
			_p.Menu.rtd:enable()
		end
		if self.completedEvents.RunningShoesGiven then
			_p.RunningShoes:enable()
		end
		if self.completedEvents.GivenZPouch then
			_p.Menu.bag:enablezmovepouch()
		end

		if etc.repel then
			_p.Repel.kind = etc.repel.kind
			_p.Repel.steps = etc.repel.steps
			_p.Repel.more = etc.repel.more
		end

		if etc.dcEgg then
			self.daycareManHasEgg = true
		end

		if etc.options then
			if etc.options.autosaveEnabled then
				_p.Autosave:enable()
			end
			if etc.options.reduceGraphics then
				_p.Menu.options.reduceGraphics = true
				_p.Menu.options:setLightingForReducedGraphics(true)
			end
			_p.Menu.options.lastUnstuckTick = etc.options.lastUnstuckTick or 0
		end

		if etc.newGameFlag then
			_p.Menu.newGameFlag = true
		end

		self.rotomEventLevel = etc.rotom


		if etc.slopeRecord then
			PlayerData.slopeRecord = etc.slopeRecord
		end

		-- location
--[[
	if ENABLE_DEBUG_LOCATION then
		_p.DataManager:loadMap('gym6')
		Utilities.Teleport(CFrame.new(216, 50, 883))
		DEBUG_LOCATION = etc.location
	else]]
		local location = etc.location
		if location then
			do

				--if etc.location then
				local buffer = _p.BitBuffer.Create()
				buffer:FromBase64(etc.location)
				--print("Buffer:", buffer)
				print("etc.location:", etc.location)
				-- position
				local cframe = buffer:ReadCFrame()
				print("CFrame:", cframe)
				-- chunk / buildings
				local chunkId = buffer:ReadString()
				print("Attempting to load chunkId:", chunkId)
				local indoors = buffer:ReadBool()
				print("Indoors:", indoors)

				local chunk
				if not indoors then				
					chunk = _p.DataManager:loadMap(chunkId, {continueCFrame = cframe})
					if etc.Surfin == true then
						print('forcesurf')
						_p.Surf:forceSurf(cframe)
					end
				else
					chunk = _p.DataManager:loadMap(chunkId)
					chunk.indoors = true
					_p.MasterControl:SetIndoors(true)
					local roomId = buffer:ReadString()
					local door = chunk:getDoor(roomId)
					local room = chunk:getRoom(roomId, door, 1)
					chunk.roomStack = {room}

					chunk:checkRegion(door.Position)
					game:GetService('RunService').RenderStepped:wait()
					local roomMusicId, roomMusicVolume
					if roomId == 'PokeCenter' then
						roomMusicId = 98391284432910
					elseif roomId:sub(1, 4) == 'Gate' and tonumber(roomId:sub(5)) then
						roomMusicId = 75050392390672--288893317
						roomMusicVolume = .45
						_p.DataManager.ignoreRegionChangeFlag = nil
					end
					pcall(function()
						if not chunk.roomData[roomId].Music then return end
						roomMusicId = chunk.roomData[roomId].Music
						roomMusicVolume = chunk.roomData[roomId].MusicVolume
					end)
					local function fixMusic()
						_p.MusicManager:fadeToVolume('RegionMusic', roomMusicId and 0 or 0.3, 0)
						if roomMusicId then
							_p.MusicManager:stackMusic(roomMusicId, 'RoomMusic', roomMusicVolume)
						end
					end
					local oneRegion = false
					for _ in pairs(chunk.data.regions) do
						if oneRegion then
							oneRegion = false
							break
						else
							oneRegion = true
						end
					end
					if oneRegion then
						spawn(function()
							local stack = _p.MusicManager:getMusicStack()
							while true do
								local l = stack[#stack]
								if l and l.Name == 'RegionMusic' then break end -- hax
								wait(.1)
							end
							fixMusic()
						end)
					else
						fixMusic()
					end

					local event = _p.Events['onBeforeEnter_'..roomId]
					if event then event(room, cframe) end

					while buffer:ReadBool() do
						chunk.indoors = true
						local subRoomId = buffer:ReadString()
						local subRoomButton
						for _, p in pairs(chunk:topRoom().model:GetChildren()) do
							if ((p.Name == 'SubRoom' and p:IsA('BasePart'))
								or (p.Name == 'InsideDoor' and p:IsA('Model')))
								and p:FindFirstChild('id') and p.id.Value == subRoomId then
								subRoomButton = p:IsA('Model') and p.Main or p
								break
							end
						end
						chunk:stackSubRoom(subRoomId, subRoomButton, true) -- support for multi-sub-roomed buildings ?
						chunk:topRoom().exitCFrame = buffer:ReadCFrame() + chunk.roomStack[#chunk.roomStack-1].model.Base.Position
					end
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					chunk:bindIndoorCam()
					cframe = cframe + chunk:topRoom().model.Base.Position
				end
				local function indoorsFix()
					local room = chunk:topRoom()
					local entrance = room.Entrance
					if entrance then
						cframe = entrance.CFrame * CFrame.new(0, 3, 3.5) * CFrame.Angles(0, math.pi, 0)
					else
						entrance = room.model:FindFirstChild('ToChunk:'..chunk.id)
						if entrance then
							cframe = entrance.CFrame * CFrame.new(0, 3, -3.5)
						end
					end
					wait(1)
				end
				pcall(function() -- for those who save in spawn box and were *not* indoors OR were indoors and got the same LocalIndoorsOrigin
					if chunkId == 'mining' or _p.Region.FromPart(_p.storage.Modelss.SpawnRegion):CastPoint(cframe.p) then
						if indoors then
							indoorsFix()
						else
							--					local place = 'PokeCenter'
							--					if chunk.id == 'chunk1' then
							--						place = 'yourhomef1'
							--					end
							--					local door = chunk:getDoor(place) or chunk.doors[1]
							--					cframe = door.CFrame * CFrame.new(0, 0, door.Size.Z + 3)
							_p.Menu.options:getUnstuck(true)
							cframe = nil
							wait(1)
						end
					end
				end)
				pcall(function() -- for those who save in spawn box and were indoors, but got a different LocalIndoorsOrigin
					if not chunk.indoors then return end
					local hit = (workspace:FindPartOnRay(Ray.new(cframe.p, Vector3.new(0, -100, 0))))
					if hit then return end
					indoorsFix()
				end)
				if cframe then 
					if location.surf then
						_p.Surf:forceSurf(cframe)
					else Utilities.Teleport(cframe) end
				end
			end
		end
		self.gameBegan = true
	end

	function PlayerData:save()
		return _p.Network:get('PDS', 'saveGame', self:getEtc())
	end


	return PlayerData end