return function(_p)
	local player = game:GetService('Players').LocalPlayer
	--local pd = debug
	local debug = {debug = true}
	if player.Name == 'tbradm' then
		debug = {
			--		load = true,
			receive = true,
			--		actionsOnRun = true,
			--		actionsOnAdd = true,
			debug = true,
		}
	elseif player.Name == 'Player1' or player.Name == 'Player' then
		debug = {
			--		receive = true,
			--		actionsOnRun = true,
			actionsOnAdd = true,
			debug = true,
			--		requestsOnFulfill = true,
		}
	end--]]

	local storage = game:GetService('ReplicatedStorage')
	local stepped = game:GetService('RunService').RenderStepped

	--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local MasterControl = _p.MasterControl
	--local root = _p.player.Character.HumanoidRootPart--Attempt To fix broken Master Control.. Note: It works
	local rc4 = Utilities.rc4
	local network = _p.Network
	local battleGui, pokemon

	local Side = require(script.Side)(_p)
	local Tools = require(script.Tools)
	local battleStartAnims = require(script.BattleStartAnims)
	local teamPreview = require(script.TeamPreview)(_p)

	local MoveModel = Utilities.MoveModel

	local split, indexOf; do
		local util = require(script.BattleUtilities)
		split = util.split
		indexOf = util.indexOf
	end

	local megakeystone = Utilities.rc4('megakeystone')
	local htr = Utilities.rc4('Haunter')



	local BattleClient = Utilities.class({
		className = 'BattleClient',
		initPriority = -99,

		kind = 'wild',
		--	scene = nil,
		sceneOffset = Vector3.new(),
		state = 'setup',
		--	lastState = 'input',
		pickup = true,

		-- PSB
		battleStatusAnimsDisabled = false,

		turn = 0,
		done = false,
		weather = '',
		weatherTimeLeft = 0,
		weatherMinTimeLeft = 0,
		lastMove = '',
		paused = true,

		sidesSwitched = false,
		messageActive = false,

		-- activity queue
		animationDelay = 0,
		activityStep = 0,
		activityDelay = 0,
		--	activityAfter = null,
		activityQueueActive = false,
		fastForward = false,

		resultWaiting = false,
		--	multiHitMove = null,

		preloadDone = 0,
		preloadNeeded = 0,

		mute = false,
		messageDelay = 8,

		_SpriteClass = Side._SpriteClass,
		_TeamPreview = teamPreview

	}, function(self)
		--	self:debug('=== New Battle ===')

		self.battleCamera = {
			FieldOfView = 28,
			CoordinateFrame = CFrame.new(-5.59, 4.56, -8.91, -.746, .063, -.663, 0, .996, .094, .666, .07, -.742),
		}

		self.ignoreNicknamesAt = self.ignoreNicknamesAt or {}
		self.actionQueue = {}

		network:bindEvent('BattleEvent', function(id, kind, ...) -- would be an issue if bindEvent allowed multiple events (current implementation includes an "unbinding" in BattleClient:remove)
			local args = {...}
			if id ~= self.battleId then return end
			if (args[1] == 'p1' or args[1] == 'p2') and args[1] ~= self.sideId then
				warn('received request for other player')
				return
			end
			if kind == 'request' then
				self:receiveRequest(args[3])
			elseif kind == 'update' or kind == 'winupdate' then
				if args[2] then
					self:storeQueriedData(args[2])
				end
				if debug.receive then Utilities.print_r({kind, args[1]}) end
				--			if kind == 'winupdate' then
				--				self.postBattleUpdates = args[3]
				--			end
				self:receiveUpdate(args[1])
			elseif kind == 'callback' then
				wait(.75)
				self.currentRequest = self.lastRequest
				self:fulfillRequest()
			else
				if debug.receive then Utilities.print_r({kind, ...}) end
			end
		end)

		local chunk = _p.DataManager.currentChunk
		local chunkId = chunk and chunk.id
		local currentRegion = chunk and chunk.currentRegion
		local regionId = currentRegion and currentRegion.Name
		local room = chunk and chunk:topRoom()
		local roomId = room and room.id

		if self.kind == 'wild' then
			-- in which cases are battle assigned a shinyChance manually? fishing(?); what else?
			local d = network:get('BattleFunction', 'new', {
				battleType = 0,
				battleSceneType = self.battleSceneType,
				expShare = _p.PlayerData.expShareOn,
				isDay = _p.DataManager.isDay,
				isDark = not _p.DataManager.isDay or (_p.DataManager.currentChunk.regionData and _p.DataManager.currentChunk.regionData.IsDark),
				eid = self.eid,
				rfl = self.rfl,

				chunkId = chunkId,
				regionId = regionId,
				roomId = roomId
			})
			for k, v in pairs(d) do self[k] = v end
			self.sideId = 'p1'
			self:send('join', 1, _p.PlayerData.trainerName) -- todo: we don't have to send our trainer name every time any more (PDS)

		elseif self.kind == 'trainer' then
			if self.npcPartner then
				self.gameType = 'doubles' --enable when we have a fix for 2v2
				self.teamn = 1 --enable when we have a fix for 2v2
				--
			end
			local d = network:get('BattleFunction', 'new', {
				battleType = 1,
				battleSceneType = self.battleSceneType,
				expShare = _p.PlayerData.expShareOn,
				isDay = _p.DataManager.isDay,
				gameType = self.gameType,
				npcPartner = self.npcPartner,
				trainerId = self.num or self.trainer.num,
				nnalp = self.trainer == nil,

				chunkId = chunkId,
				regionId = regionId,
				roomId = roomId
			})
			for k, v in pairs(d) do self[k] = v end
			self.sideId = 'p1'
			self:send('join', 1, _p.PlayerData.trainerName) -- same

		elseif self.kind == 'pvp' then
			if self.pseudoHost then
				local d = network:get('BattleFunction', 'new', {
					battleType = 2,
					forcedLevel = self.forcedLevel,
					gameType = self.gameType,
					allowSpectate = self.allowSpectate,
					location = self.location,
					isRanked = self.isRanked
				})
				for k, v in pairs(d) do self[k] = v end
				self.sideId = 'p1'
				-- get the opponent to join this battle
				network:post('BattleRequest', self.opponent,
					{joinBattle = self.battleId, gameType = self.gameType, teamPreviewEnabled = self.teamPreviewEnabled,
						location = self.location, isRanked = self.isRanked})
			else
				local d = network:get('BattleFunction', self.battleId, 'getCD')
				for k, v in pairs(d) do self[k] = v end
				self.sideId = 'p2'
			end

		elseif self.kind == '2v2' then
			self.teamn = self.myTeamN
			local d = network:get('BattleFunction', self.battleId, 'getCD')
			--print('scene:', d.scene)
			for k, v in pairs(d) do self[k] = v end

			--print(self.partner, self.opponent1, self.opponent2)
		end

		if self.gameType == 'doubles' then
			self.battleCamera.FieldOfView = 40
			self.battleCamera.CoordinateFrame = CFrame.new(-2.32, 6.873, -11.056, -.868, .162, -.469, 0, .945, .326, .497, .283, -.821)
		end

		self.cns = {}

		self.BattleEnded = Utilities.Signal()
		self.InputChosen = Utilities.Signal()
		self.Idle = Utilities.Signal()
		table.insert(self.cns, self.Idle:connect(function() self:onIdle() end))
		battleGui.inputEvent = self.InputChosen

		--
		self.minorQueue = {}

		self.pseudoWeather = {}
		self.sideConditions = {}

		self.playbackState = 0

		self.activityQueue = {}
		self.preemptActivityQueue = {}

		--	self:preloadEffects()
		self:reset()

		-- init
		self.mySide = Side:new(nil, self, 1)
		self.yourSide = Side:new(nil, self, 2)
		self.mySide.foe = self.yourSide
		self.yourSide.foe = self.mySide
		self.sides = {self.mySide, self.yourSide}
		self.p1 = self.mySide
		self.p2 = self.yourSide

		if self.kind == 'trainer' then
			if self.trainer then
				self.p2.name = self.trainer.Name
			else
				self.p2.name, self.losePhrase = self:sendAsync('getTrainer') -- RIP NPC replays
			end
		elseif self.kind == 'pvp' then
			if self.pseudoHost then
				self.p2.name = self.opponent.Name
			else
				self:switchSides()
				self.p1.name = self.opponent.Name
			end
		elseif self.kind == '2v2' then
			if self.sideId == 'p2' then
				self:switchSides()
			end
			self.mySide['name'..self.myTeamN] = _p.PlayerData.trainerName
			self.mySide['name'..(3-self.myTeamN)] = self.partner.Name
			self.yourSide.name1 = self.opponent1.Name
			self.yourSide.name2 = self.opponent2.Name
		end

		if self.kind == 'spectate' then
			self.p1.name = self.sdata.name1
			self.p2.name = self.sdata.name2
			if self.siden == 2 then
				self:switchSides()
			end
			self.siden = nil
		else
			self.mySide.name = _p.PlayerData.trainerName
		end

		return self
	end)

	function BattleClient:init()
		battleGui = _p.BattleGui
		pokemon = _p.Pokemon
	end

	network:bindFunction('BattleFunction', function(fn, ...)
		local battle = BattleClient.currentBattle
		if not battle then
			BattleClient:debug('Battle Function invoked without active battle')
			return
		end
		if fn == 'trainer' then
			battle.p2.name    = select(1, ...)
			battle.losePhrase = select(2, ...)
			return
		elseif not battle[fn] then
			battle:debug('Battle Function invoked with unknown request', fn)
			return
		end
		return battle[fn](battle, ...)
	end)

	function BattleClient:startZPowerGlow(sprite)
		self:stopZPowerGlow()
		self.currentZGlowingSprite = sprite
		local st = tick()
		spawn(function()
			Utilities.Tween(99, nil, function(_, et)
				if self.currentZGlowingSprite ~= sprite then
					return false
				end
				pcall(function()
					sprite.animation.spriteLabel.ImageColor3 = Color3.fromHSV(0.125, 0.15 - 0.15 * math.cos(et * 8), 1)
				end)
			end)
		end)
	end
	function BattleClient:stopZPowerGlow()
		local sprite = self.currentZGlowingSprite
		if not sprite then
			return
		end
		self.currentZGlowingSprite = nil
		pcall(function()
			sprite.animation.spriteLabel.ImageColor3 = Color3.new(1, 1, 1)
		end)
	end

	function BattleClient:animZPower(...) return battleGui:animZPower(...) end 

	-- class fns
	function BattleClient:doWildBattle(encounter, battle, repelEnabled)
		if self.currentBattle then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		if _p.DataManager.currentChunk.indoors then
			_p.DataManager.currentChunk.indoorCamFunc("inbattle")
		end

		local b = battle or {}
		local hoopabattle = battle and battle.cannotRun or false
		if repelEnabled then
			local ld = encounter.ld[_p.DataManager.isDay and 1 or 2]
			local l = Utilities.weightedRandom(ld, function(e) return e[2] end)[1]
			if l < _p.PlayerData.firstNonEggLevel then
				_p.MasterControl.WalkEnabled = true
				return
			end
			b.rfl = l
		end
		b.eid = encounter.id

		--	local event = _p.Events['modifyBattle_'.._p.DataManager.currentChunk.id] -- OVH  move to Oerver
		--	if event then event(b) end
		_p.NPCChat:disable()
		spawn(function() _p.Menu:disable() end)
		_p.MasterControl:Hidden(true)
		local battle = BattleClient:new(b)

		self.currentBattle = battle
		spawn(function() battle:setupScene() end) -- preload junk; start music
		local cam = workspace.CurrentCamera
		local preBattleCameraCFrame = cam.CoordinateFrame
		if not hoopabattle then
			cam.CameraType = Enum.CameraType.Scriptable
			local p1dur = .8
			local p2dur = .3
			local timerOut = Utilities.Timing.cubicBezier(p1dur, .1, .5, .5, 1)
			local timerIn = Utilities.Timing.cubicBezier(p2dur, .5, 0, .75, .5)
			local fader = Utilities.fadeGui
			fader.ZIndex = 10
			fader.BackgroundColor3 = Color3.new(1, 1, 1)

			local animContainer = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
				Parent = Utilities.frontGui,
			}
			local animator = battleStartAnims[math.random(#battleStartAnims)](animContainer)
			local zoomEnabled = true
			pcall(function() if _p.DataManager.currentChunk.indoors then zoomEnabled = false end end)

			local st = tick()
			while true do
				stepped:wait()
				local et = tick()-st
				if et >= p1dur+p2dur then
					break
				elseif et > p1dur then
					local a = timerIn(et-p1dur)
					if zoomEnabled then cam.FieldOfView = 120 - 110*a end
					animator((et-p1dur)/p2dur, a)
				else
					local a = timerOut(et)
					if zoomEnabled then cam.FieldOfView = 70 + 50*a end
					local t = et/p1dur*4
					if math.floor(t)%2 == 1 then
						fader.BackgroundTransparency = t%1
					else
						fader.BackgroundTransparency = 1 - (t%1)
					end
				end
			end
			_p.DataManager.currentChunk.regionThread = nil
			fader.BackgroundColor3 = Color3.new(0, 0, 0)
			fader.BackgroundTransparency = 0.0
			animContainer:remove()
		end
		local playerListWasEnabled = _p.PlayerList.enabled
		_p.PlayerList:disable()
		wait(.5)
		while not battle.setupComplete do stepped:wait() end
		battle:focusScene()
		Utilities.FadeIn(.5)
		battle:takeOver()

		-- battle, do yo stuff

		battle.BattleEnded:wait()
		_p.MusicManager:popMusic('BattleMusic', 1, true)
		Utilities.FadeOut(1)
		if playerListWasEnabled then _p.PlayerList:enable() end

		local blackout = false
		local evolutions = {}
		for i = #battle.actionQueue, 1, -1 do
			local kind = battle.actionQueue[i]:match('^|(.-)|')
			if kind == 'evolve' or kind == 'learnmove' or kind == '-learnedmove' then
				table.insert(evolutions, 1, {kind=='evolve', table.remove(battle.actionQueue, i)})
			elseif kind == 'blackout' then
				local args, kwargs = battle:parseAction(battle.actionQueue[i])
				blackout = tonumber(args[2] or '')
				if not blackout then blackout = true end
				break
			end
		end
		if blackout then
			if battle.blackoutHandler then
				battle.blackoutHandler()
			else
				self:blackedOut(true, blackout)
			end
		elseif #evolutions > 0 then
			battle.message = function(_, ...)
				return _p.NPCChat:say(...)
			end
			--		local lastEndFade
			for _, e in pairs(evolutions) do
				--			if e[1] then
				--				if lastEndFade then lastEndFade() end
				--				lastEndFade = battle:run(e[2])
				--			else
				battle:run(e[2])
				--			end
			end
			--		if lastEndFade then lastEndFade() end
		end
		--local isSafari, SBCount = battle.isSafari, battle.SBCount
		battle:remove() -- R.I.P.

		cam.FieldOfView = 70
		if not blackout then cam.CoordinateFrame = battle.afterBattleCameraCFrame or preBattleCameraCFrame end
		if _p.DataManager.currentChunk.indoors then
			_p.DataManager.currentChunk.indoorCamFunc("outbattle")
		else
			cam.CameraType = Enum.CameraType.Custom
		end
		if not blackout and not hoopabattle then
			spawn(function() _p.MusicManager:returnFromSilence() end)
		end
		if not hoopabattle then
			Utilities.FadeIn(1)
		end
		_p.MasterControl:Hidden(false)
		_p.MasterControl.WalkEnabled = true
		spawn(function() _p.Menu:enable() end)
		_p.NPCChat:enable()
		self.currentBattle = nil
		_p.Autosave:queueSave()
	end
	
	function BattleClient:doTrainerBattle(data)
		if self.currentBattle then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.MasterControl:Hidden(true)
		spawn(function() _p.Menu:disable() end)
		_p.NPCChat:disable()

		if _p.DataManager.currentChunk.indoors then
			_p.DataManager.currentChunk.indoorCamFunc("inbattle")
		end

		data.kind = 'trainer'
		if not data.musicId then
			data.musicId = 116663666819728--116663666819728, 1076549083 Both Now
		end
		local b = Utilities.shallowcopy(data)
		--	local event = _p.Events['modifyBattle_'.._p.DataManager.currentChunk.id]
		--	if event then
		--		event(b)
		--	end
		local battle = BattleClient:new(b)

		self.currentBattle = battle
		spawn(function() battle:setupScene() end)
		local cam = workspace.CurrentCamera
		local preBattleCameraCFrame = cam.CoordinateFrame
		--cam.CoordinateFrame = CFrame.new(-5.59, 4.56, -8.91, -.746, .063, -.663, 0, .996, .094, .666, .07, -.742)
		cam.CameraType = Enum.CameraType.Scriptable

		local playerListWasEnabled = _p.PlayerList.enabled
		if data.vs then
			local animation = self:doVsAnimation(data.vs.name, data.vs.id, data.vs.hue, data.vs.sat, data.vs.val)
			_p.DataManager.currentChunk.regionThread = nil
			_p.PlayerList:disable()
			wait(2.5)
			while not battle.setupComplete do stepped:wait() end
			battle:focusScene()
			wait(.5)
			animation:SlideOff()
		else
			local animContainer = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
				Parent = Utilities.frontGui,
			}
			local animator = battleStartAnims[math.random(#battleStartAnims)](animContainer)
			local ballImage = Utilities.Create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://'..(data.IconId or (data.trainer and data.trainer.IconId) or 6142797841),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.3, 0, 0.3, 0),
				Position = UDim2.new(0.08, 0, 0.6, 0),
				ZIndex = 4, Parent = Utilities.Create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.4, 0),
					Position = UDim2.new(0.5, 0, 0.3, 0),
					Parent = animContainer,
				}
			}

			local dur = .5
			local ballTimer = Utilities.Timing.cubicBezier(1, .3, .75, .55, 1.45)

			Utilities.Tween(dur, nil, function(a)
				local b = ballTimer(a)
				ballImage.Size = UDim2.new(b, 0, b, 0)
				ballImage.Position = UDim2.new(0.0, -ballImage.AbsoluteSize.X/2, 0.5-b/2, 0)
				ballImage.Rotation = -700 * (1-a)
				animator(a, a)
			end)
			_p.DataManager.currentChunk.regionThread = nil
			local fader = Utilities.fadeGui
			fader.BackgroundColor3 = Color3.new(0, 0, 0)--
			fader.BackgroundTransparency = 0.0
			_p.PlayerList:disable()
			wait(.5)
			while not battle.setupComplete do stepped:wait() end
			ballImage.Parent.Parent = nil
			animContainer:ClearAllChildren()
			ballImage.Parent.Parent = animContainer
			animContainer.BackgroundTransparency = 1.0
			battle:focusScene()
			spawn(function()
				Utilities.Tween(.3, nil, function(a)
					ballImage.ImageTransparency = a
				end)
				animContainer:remove()
			end)
			Utilities.FadeIn(.5)
		end
		battle:takeOver()

		battle.BattleEnded:wait()
		_p.MusicManager:popMusic('BattleMusic', 1, true)
		Utilities.FadeOut(1)
		if playerListWasEnabled then _p.PlayerList:enable() end

		local blackout = false
		if not data.IgnoreBlackout then -- now ignores evolution too, BUT this is only used in the very first battle
			local evolutions = {}
			for i = #battle.actionQueue, 1, -1 do
				local kind = battle.actionQueue[i]:match('^|(.-)|')
				if kind == 'evolve' or kind == 'learnmove' or kind == '-learnedmove' then
					table.insert(evolutions, 1, {kind=='evolve', table.remove(battle.actionQueue, i)})
				elseif kind == 'blackout' then
					local args, kwargs = battle:parseAction(battle.actionQueue[i])
					blackout = tonumber(args[2] or '')
					break
				end
			end
			if blackout then
				if battle.blackoutHandler then
					battle.blackoutHandler()
				else
					self:blackedOut(false, blackout)
				end
			elseif #evolutions > 0 then
				battle.message = function(_, ...)
					return _p.NPCChat:say(...)
				end
				local lastEndFade
				for _, e in pairs(evolutions) do
					if e[1] then
						if lastEndFade then lastEndFade() end
						lastEndFade = battle:run(e[2])
					else
						battle:run(e[2])
					end
				end
				if lastEndFade then lastEndFade() end
			end
		end
		battle:remove() -- R.I.P.

		cam.FieldOfView = 70
		local winEvent
		if not blackout then
			cam.CoordinateFrame = data.afterBattleCameraCFrame or preBattleCameraCFrame
			pcall(function() winEvent = _p.Events['on'..data.trainer.WinEvent] end)
		end
		if _p.DataManager.currentChunk.indoors then
			_p.DataManager.currentChunk.indoorCamFunc("outbattle")
		else
			cam.CameraType = Enum.CameraType.Custom
		end
		if not blackout then
			spawn(function() _p.MusicManager:returnFromSilence() end)
		end
		Utilities.FadeIn(1)
		if winEvent then
			winEvent()
		end
		if self.npcPartner and not blackout then
			local partner
			for _, npc in pairs(_p.DataManager.currentChunk.npcs) do
				if npc.followingPlayerThread then
					partner = npc
					break
				end
			end
			if partner then
				Utilities.fastSpawn(function() _p.Network:get('PDS', 'getHealing') end)
				spawn(function() _p.MasterControl:LookAt(partner.model.HumanoidRootPart.Position) end)
				spawn(function() partner:LookAt(_p.player.Character.HumanoidRootPart.Position) end)
				if partner.model.Name == 'Jake' or 'Tess' then
					local adj = {'Awesome', 'Excellent', 'Amazing', 'Sweet', 'Nice'}
					partner:Say(adj[math.random(#adj)]..' battling!', 'Let me heal our pokemon now.')
				else
					partner:Say('Excellent battling!', 'Here, allow me to heal your pokemon.')
				end
			end
		end
		_p.MasterControl:Hidden(false)
		if not data.PreventMoveAfter then
			_p.MasterControl.WalkEnabled = true

			spawn(function() _p.Menu:enable() end)
			_p.NPCChat:enable()
		end
		self.currentBattle = nil
		_p.Autosave:queueSave()
		return not blackout
	end

	function BattleClient:blackedOut(wild, moneyLost)
		if _p.DataManager.currentChunk.indoors then
			_p.DataManager.currentChunk.indoorCamFunc("outbattle")
		end
		_p.MasterControl:SetJumpEnabled(false) -- gym 2
		local pokeballs
		Utilities.fastSpawn(function()
			local ballNums = _p.Network:get('PDS', 'getPartyPokeBalls')
			local ballNames = {}
			for i, num in pairs(ballNums) do
				ballNames[i] = _p.Pokemon.balls[num]
			end
			pokeballs = ballNames
		end)
		self.npcPartner = nil
		local name = _p.PlayerData.trainerName
		Utilities.fadeGui.ZIndex = 8
		_p.NPCChat:say(name .. ' has no more pokemon that can fight!')
		if moneyLost and moneyLost > 0 then
			if wild then
				_p.NPCChat:say(name .. ' panicked and dropped [$]' .. _p.PlayerData:formatMoney(moneyLost) .. '.')
			else
				_p.NPCChat:say(name .. ' paid [$]' .. _p.PlayerData:formatMoney(moneyLost) .. ' to the winner.')
			end
		end
		local chunk = _p.DataManager.currentChunk
		_p.DataManager.ignoreRegionChangeFlag = true
		if chunk.id == 'chunk1' then
			_p.NPCChat:say(name .. ' returned home to rest the exhausted pokemon...')
			for _, r in pairs(chunk.roomStack) do r:remove() end
			chunk.indoors = true
			local door = chunk:getDoor('yourhomef1')
			local room = chunk:getRoom('yourhomef1', door, 1)
			chunk.roomStack = {room}
			chunk:stackSubRoom('yourhomef2', room.model.SubRoom, true)
			chunk:bindIndoorCam()
			Utilities.Teleport(chunk.roomStack[2].model.NewGameSpawn.CFrame * CFrame.Angles(0, math.pi/2, 0) + Vector3.new(3, 1, 1))
			_p.MasterControl:SetIndoors(true)
			_p.MusicManager:popMusic('all')
			chunk:checkRegion(door.Position)
			stepped:wait()
			_p.MusicManager:prepareToStack(0)
			_p.MusicManager:fadeToVolume('top', 0.3, 0)
		else
			_p.NPCChat:say(name .. ' scurried to a pokemon Center, protecting the exhausted pokemon from any further harm...')
			local blackOutTo = (chunk.regionData and chunk.regionData.BlackOutTo) or chunk.data.blackOutTo
			pcall(function()
				if chunk.id == 'chunk16' then
					if _p.PlayerData.completedEvents.ReachCliffPC then
						blackOutTo = 'chunk17'
					end
				end
			end)
			Utilities.Teleport(CFrame.new(3+math.random(-20, 20), 86, 389+math.random(-20, 20)))
			if blackOutTo then
				chunk:unbindIndoorCam()
				chunk:remove()
				chunk = _p.DataManager:loadMap(blackOutTo)
			else
				for _, r in pairs(chunk.roomStack) do r:remove() end
			end
			chunk.indoors = true
			local room = chunk:getRoom('PokeCenter', chunk:getDoor('PokeCenter'), 1)
			_p.Events.onBeforeEnter_PokeCenter(room)
			chunk.roomStack = {room}
			chunk:bindIndoorCam()
			Utilities.Teleport(room.model.Base.CFrame * CFrame.new(0, 3.1, 0) * CFrame.Angles(0, math.pi, 0))
			_p.MasterControl:Look(Vector3.new(0, 0, 1), 0)
			_p.MasterControl:SetIndoors(true)

			--
			workspace.CurrentCamera.FieldOfView = 70
			chunk.roomCamDisabled = false
			chunk.indoorCamFunc(true)
			_p.MusicManager:popMusic('all')
			chunk:checkRegion(chunk:getDoor('PokeCenter').Position)
			stepped:wait()
			_p.MusicManager:prepareToStack(0)
			_p.MusicManager:stackMusic(9537352871, 'RoomMusic')
			Utilities.FadeIn(1)
			local machine = room.model.HealingMachine
			local p1 = room.model.Base.Position + Vector3.new(-0.2, 3.16, 4.8)
			local p2 = p1 + Vector3.new(0, 0, 2)
			local npc = room.npcs.Nurse
			local chat = _p.NPCChat
			spawn(function() chat:say(npc, '[ma]I\'ll take your pokemon for a few seconds.') end)
			wait(1)
			npc:WalkTo(p2)
			npc:Look(Vector3.new(0, 0, 1))
			chat:manualAdvance()
			while not pokeballs do wait() end
			local models = {}
			for i, p in pairs(pokeballs) do
				if i > 6 then break end
				Utilities.sound(301970857, 1, .1, 2)
				local model = (_p.storage.Modelss.Pokeballs:FindFirstChild(p) or _p.storage.Modelss.pokeball):Clone()
				Utilities.MoveModel(model.Main, machine['Slot'..i].CFrame*CFrame.Angles(0, math.pi/2, 0)+Vector3.new(0, 1.5, 0), true)
				model.Parent = room.model
				table.insert(models, model)
				wait(.5)
			end
			Utilities.sound(300394295, nil, .5, 10)
			Utilities.Tween(2, nil, function(a)
				machine.Screen.Reflectance = 0.3 + 0.5*math.abs(math.sin(a*4*math.pi))
			end)
			wait(.5)
			for _, m in pairs(models) do
				m:remove()
			end
			npc:WalkTo(p1)
			pcall(function() npc:LookAt(_p.player.Character.HumanoidRootPart.Position) end)
			chat:say(npc, 'Thank you for waiting.', 'We\'ve restored your pokemon to full health.')
			npc.bow:Play(.3)
			spawn(function() chat:say(npc, '[ma]We hope to see you again!') end)
			wait(1)
			chat:manualAdvance()
			spawn(function() npc:Look(Vector3.new(0, 0, -1)) end)
			--
		end
		_p.DataManager.ignoreRegionChangeFlag = nil
	end

	function BattleClient:doVsAnimation(name, imageId, hue, sat, val)
		hue = hue or math.random()
		sat = sat or .3
		val = val or .5
		local clickDisabler = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 10, Parent = Utilities.frontGui
		}
		local square = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Position = UDim2.new(-.5, 0, 0.0, 0),
			Parent = create 'Frame' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(.5, 0, .5, 0),
				Position = UDim2.new(.5, 0, .25, 0),
				Parent = Utilities.frontGui
			}
		}
		local v = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6604442882',
			ImageRectSize = Vector2.new(128, 128),
			ImageRectOffset = Vector2.new(0, 58),
			Size = UDim2.new(.65, 0, .65, 0),
			ZIndex = 6, Parent = square
		}
		local s = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6604442882',
			ImageRectSize = Vector2.new(110, 128),
			ImageRectOffset = Vector2.new(146, 58),
			Size = UDim2.new(.65/128*110, 0, .65, 0),
			ZIndex = 6, Parent = square
		}
		local top = create 'Frame' {
			BackgroundColor3 = Color3.fromRGB(58,47,46),
			BorderSizePixel = 0,
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.frontGui
		}
		local bottom = create 'Frame' {
			BackgroundColor3 = Color3.fromRGB(58,47,46),
			BorderSizePixel = 0,
			Position = UDim2.new(0.0, 0, 1.0, 0),
			Parent = Utilities.frontGui
		}
		local back = create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHSV(hue, sat, val),
			Size = UDim2.new(1.15, 0, .5, 0),
			ZIndex = 2, Parent = Utilities.frontGui
		}
		local clippedContainer = create 'Frame' {
			ClipsDescendants = true,
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = back
		}
		local lastBorder
		for i = 3, 1, -1 do
			local border = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHSV(hue, sat+i*.07, val+i*-.07),
				Size = UDim2.new(1.0, 0, 1.7, 0),
				Position = UDim2.new(0.0, 0, 1.0, 0),
				ZIndex = 2, Parent = lastBorder or clippedContainer
			}
			if not lastBorder then
				border.Size = UDim2.new(1.0, 0, 1/30, 0)
				border.Position = UDim2.new(0.0, 0, 0.0, -1)
			end
			lastBorder = border
		end
		lastBorder = nil
		for i = 3, 1, -1 do
			local border = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromHSV(hue, sat+i*.07, val+i*-.07),
				Size = UDim2.new(1.0, 0, -1.7, 0),
				Position = UDim2.new(0.0, 0, 0.0, 0),
				ZIndex = 2, Parent = lastBorder or clippedContainer
			}
			if not lastBorder then
				border.Size = UDim2.new(1.0, 0, -1/30, 0)
				border.Position = UDim2.new(0.0, 0, 1.0, 1)
			end
			lastBorder = border
		end
		local rectSize = Vector2.new(420, 210)
		local rectOffset = Vector2.new()
		if type(name) == 'table' then
			local scale1, scale2 = .9, 1.1
			local trainer1 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = imageId[1],
				ImageRectSize = rectSize*Vector2.new(1, scale1),
				ImageRectOffset = rectOffset,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(2.0, 0, scale1, 0),
				Position = UDim2.new(.45/1.15+.08, 0, 1-scale1, 0),
				ZIndex = 6, Parent = back
			}
			local trainer2 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = imageId[2],
				ImageRectSize = rectSize*Vector2.new(1, scale2),
				ImageRectOffset = rectOffset,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(2.0, 0, scale2, 0),
				Position = UDim2.new(.45/1.15-.08, 0, 1-scale2, 0),
				ZIndex = 5, Parent = back
			}

			Utilities.Write(name[1]) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.09/scale1, 0),
					Position = UDim2.new(0.5, 0, 1+.05/scale1*scale2, 0),
					ZIndex = 6, Parent = trainer1
				}, Scaled = true
			}
			Utilities.Write(name[2]) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.09/scale2, 0),
					Position = UDim2.new(0.5, 0, 1.05, 0),
					ZIndex = 6, Parent = trainer2
				}, Scaled = true
			}
		else
			if type(imageId) == 'number' then
				imageId = 'rbxassetid://'..imageId
				rectSize = Vector2.new(840, 420)
				rectOffset = Vector2.new(0, 40)
			end
			local trainer = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = imageId,
				ImageRectSize = rectSize,
				ImageRectOffset = rectOffset,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(2.0, 0, 1.0, 0),
				Position = UDim2.new(.45/1.15, 0, 0.0, 0),
				ZIndex = 5, Parent = back
			}
			Utilities.Write(name) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.175, 0),
					Position = UDim2.new(0.5, 0, 1.05, 0),
					ZIndex = 6, Parent = trainer
				}, Scaled = true
			}
		end

		spawn(function()
			local st = tick()
			local lastY = 0
			local random, abs = math.random, math.abs
			while tick()-st < 5 do
				if not clippedContainer.Parent then break end
				local len = .2 + .3*random()
				local spd = .25 + .4*random()
				local yps = .2 + .6*random()
				if abs(yps-lastY) < .08 then
					yps = yps + (yps>.5 and -.3 or .3)
				end
				lastY = yps
				local wid = random(1, 3)*.01
				local lsat = .5*random()
				spawn(function()
					local g = create 'Frame' {
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromHSV(hue, lsat, 1),
						Size = UDim2.new(len, 0, wid, 0),
						ZIndex = 4, Parent = clippedContainer,
					}
					Utilities.Tween(spd, nil, function(a)
						if not clippedContainer.Parent then return false end
						g.Position = UDim2.new(1-(1+len)*a, 0, yps-wid/2, 0)
					end)
					pcall(function() g:remove() end)
				end)
				wait(.05+.075*random())
			end
		end)

		local cx, cy = -.25, .5
		local vsxs, vsys = v.Size.X.Scale/2, v.Size.Y.Scale/2
		local ssxs, ssys = s.Size.X.Scale/2, s.Size.Y.Scale/2
		local sin, cos = math.sin, math.cos
		local pi = math.pi
		local ud2 = UDim2.new
		Utilities.Tween(1, 'easeOutCubic', function(a)
			top.Size = ud2(1.0, 0, a*.5, a*36)
			bottom.Size = ud2(1.0, 0, a*-.5, 0)
			local r = 1.75-1.5*a
			local t = 3*(1-a)+13/12*pi
			local x = cos(t)*r
			local y = sin(t)*r
			v.Position = ud2(cx+x-vsxs, 0, cy+y-vsys, 0)
			s.Position = ud2(cx-x-ssxs, 0, cy-y-ssys, 0)
			back.Position = ud2(1-a, 0, .25, 0)
		end)

		local anim = {}
		function anim:SlideOff()
			local backTimer = Utilities.Timing.easeInBack(.7)
			Utilities.Tween(.7, nil, function(a)
				local b = backTimer(a)
				square.Parent.Position = UDim2.new(.5+b, 0, .25, 0)
				back.Position = UDim2.new(b, 0, .25, 0)
				if b > 0 then
					local o = 1-b
					top.Size = ud2(1.0, 0, o*.5, o*36)
					bottom.Size = ud2(1.0, 0, o*-.5, 0)
				end
			end)
			self:remove()
		end
		function anim:remove()
			back:remove()
			square:remove()
			top:remove()
			bottom:remove()
			clickDisabler:remove()
		end
		return anim
	end

	-- PVP
	function BattleClient:doPVPBattle(data)
		if self.currentBattle then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.MasterControl:Hidden(true)
		spawn(function() _p.Menu:disable() end)
		_p.NPCChat:disable()

		data.kind = 'pvp'
		data.ignoreNicknamesAt = {}
		data.ignoreNicknamesAt['21'] = true
		data.ignoreNicknamesAt['22'] = true
		data.ignoreNicknamesAt['23'] = true
		if not data.musicId then
			data.musicId = 12639769611
		end
		local battle = BattleClient:new(Utilities.shallowcopy(data)) -- battle is not :join()ed yet

		self.currentBattle = battle
		spawn(function() battle:setupScene() end)
		local cam = workspace.CurrentCamera
		local preBattleCameraCFrame = cam.CoordinateFrame
		cam.CameraType = Enum.CameraType.Scriptable
		_p.DataManager.currentChunk.regionThread = nil

		-- START TEAM PREVIEW ADDITION
		_p.MusicManager:stackMusic(9537523484, 'TeamPreview', .3)
		teamPreview:prepare(battle)

		local imageId = 'http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&userid='..math.max(1, battle.opponent.UserId)
		local animation = self:doVsAnimation(battle.opponent.Name, imageId)

		local order, removeTeamPreviewGui
		local teamPreviewReady = false
		spawn(function()
			--		if battle.teamPreviewEnabled then while not battle.opponentPartyPreview do wait(.1) end end
			--		if battle.opponentPartyPreview == 'error' then return end
			teamPreviewReady = true
			order, removeTeamPreviewGui = teamPreview:getOrder(battle)
		end)
		cam.CFrame = CFrame.new(Vector3.new(0, 200, 390), Vector3.new(20, 240, 390)) -- random view, far from characters, looking up (ish)

		wait(3)
		local st = tick()
		while not teamPreviewReady do
			if tick()-st > 20 or not battle.opponent.Parent then
				network:post('UpdateTitle')
				_p.MusicManager:popMusic('TeamPreview', 1, false)
				--			battle.opponentPartyPreview = 'error'
				wait(1)
				battle:remove()

				cam.FieldOfView = 70
				cam.CoordinateFrame = preBattleCameraCFrame
				cam.CameraType = Enum.CameraType.Custom

				animation:remove()

				_p.MasterControl:Hidden(false)
				_p.MasterControl.WalkEnabled = true
				spawn(function() _p.Menu:enable() end)
				_p.NPCChat:enable()
				self.currentBattle = nil

				return
			end
			wait(.5)
		end

		animation:SlideOff()

		teamPreview:startTimer(false)

		local opponent = battle.opponent
		while not order or not battle.opponentReady do
			if not opponent.Parent then
				-- other player left, ugh
				network:post('UpdateTitle')
				_p.MusicManager:popMusic('TeamPreview', 1, false)
				battle:remove()

				cam.FieldOfView = 70
				cam.CoordinateFrame = preBattleCameraCFrame
				cam.CameraType = Enum.CameraType.Custom

				pcall(function() teamPreview.forceAutoComplete:fire() end)
				teamPreview.timerFinished = true
				wait(1)
				pcall(function() removeTeamPreviewGui() end)

				_p.MasterControl:Hidden(false)
				_p.MasterControl.WalkEnabled = true
				spawn(function() _p.Menu:enable() end)
				_p.NPCChat:enable()
				self.currentBattle = nil

				return
			end
			wait()
		end
		teamPreview.timerFinished = true
		battle:send('join', battle.pseudoHost and 1 or 2, player.Name, order)
		-- END TEAM PREVIEW

		_p.MusicManager:stackMusic(battle.musicId, 'BattleMusic', .4)
		-- [[
		local animContainer = Utilities.Create 'Frame' {
			BackgroundTransparency = 1.0,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.frontGui,
		}
		local animator = battleStartAnims[math.random(#battleStartAnims)](animContainer)
		local ballImage = Utilities.Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6142797841',
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.3, 0, 0.3, 0),
			Position = UDim2.new(0.08, 0, 0.6, 0),
			ZIndex = 4, Parent = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.4, 0),
				Position = UDim2.new(0.5, 0, 0.3, 0),
				Parent = animContainer,
			}
		}

		local dur = .5
		local ballTimer = Utilities.Timing.cubicBezier(1, .3, .75, .55, 1.45)

		Utilities.Tween(dur, nil, function(a)
			local b = ballTimer(a)
			ballImage.Size = UDim2.new(b, 0, b, 0)
			ballImage.Position = UDim2.new(0.0, -ballImage.AbsoluteSize.X/2, 0.5-b/2, 0)
			ballImage.Rotation = -700 * (1-a)
			animator(a, a)
		end)--]]


		local fader = Utilities.fadeGui
		fader.BackgroundColor3 = Color3.new(0, 0, 0)--
		fader.BackgroundTransparency = 0.0
		local playerListWasEnabled = _p.PlayerList.enabled
		_p.PlayerList:disable()

		pcall(removeTeamPreviewGui)
		wait(.5)


		while not battle.setupComplete do stepped:wait() end
		-- [[
		ballImage.Parent.Parent = nil
		animContainer:ClearAllChildren()
		ballImage.Parent.Parent = animContainer
		animContainer.BackgroundTransparency = 1.0
		battle:focusScene()
		spawn(function()
			Utilities.Tween(.3, nil, function(a)
				ballImage.ImageTransparency = a
			end)
			animContainer:remove()
		end)--]]
		Utilities.FadeIn(.5)
		--	fader.BackgroundColor3 = Color3.new(0, 0, 0)
		battle:takeOver()

		battle.BattleEnded:wait()
		_p.MusicManager:popMusic('TeamPreview', 1, true)
		Utilities.FadeOut(1)
		if playerListWasEnabled then _p.PlayerList:enable() end
		battle:remove(true) -- OVH  TODO: use this to change titles; protect the title API
		cam.FieldOfView = 70
		cam.CoordinateFrame = preBattleCameraCFrame
		if _p.DataManager.currentChunk.indoors then
			_p.DataManager.currentChunk.indoorCamFunc(true)
		else
			cam.CameraType = Enum.CameraType.Custom
		end
		spawn(function() _p.MusicManager:returnFromSilence() end)
		if _p.player:FindFirstChild('BattleResult') then -- OVH  TODO
			local r = _p.player.BattleResult.Value
			local diff
			pcall(function() r, diff = r:match('^(%a+),(.*)$') end)
			pcall(function()
				diff = tonumber(diff)
				diff = (diff < 0) and (' '..diff) or (' +'..diff)
			end)
			if r == 'win' then
				network:post('UpdateTitle', 'Winner'..(diff or ''), Color3.new(.4, .8, 1))
			elseif r == 'lose' then
				network:post('UpdateTitle', 'Loser'..(diff or ''), Color3.new(1, .4, .4))
			elseif r == 'tie' then
				network:post('UpdateTitle', 'Tied'..(diff or ''), Color3.new(.7, .7, .7))
			end
			delay(10, function()
				network:post('UpdateTitle', nil, nil, true)
			end)
		else
			network:post('UpdateTitle')
		end
		Utilities.FadeIn(1)

		_p.MasterControl:Hidden(false)
		_p.MasterControl.WalkEnabled = true
		spawn(function() _p.Menu:enable() end)
		_p.NPCChat:enable()
		self.currentBattle = nil
		_p.Autosave:queueSave()
	end

	-- 2v2
	function BattleClient:do2v2Battle(data)
		if self.currentBattle then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.MasterControl:Hidden(true)
		spawn(function() _p.Menu:disable() end)
		_p.NPCChat:disable()

		print('MY TEAM POSITION:', data.myTeamN)

		data.kind = '2v2'
		data.ignoreNicknamesAt = {}
		data.ignoreNicknamesAt['1'..(3-data.myTeamN)] = true
		data.ignoreNicknamesAt['21'] = true
		data.ignoreNicknamesAt['22'] = true
		if not data.musicId then
			data.musicId = 12639769611--12639769611
		end
		local battle = BattleClient:new(Utilities.shallowcopy(data))

		self.currentBattle = battle
		spawn(function() battle:setupScene() end)
		local cam = workspace.CurrentCamera
		local preBattleCameraCFrame = cam.CoordinateFrame
		cam.CameraType = Enum.CameraType.Scriptable
		_p.DataManager.currentChunk.regionThread = nil

		-- 2v2 TEAM PREVIEW
		_p.MusicManager:stackMusic(9537523484, 'TeamPreview', .3)
		teamPreview:prepare(battle)

		local imageId1 = 'http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&userid='..math.max(1, battle.opponent1.UserId)
		local imageId2 = 'http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&userid='..math.max(1, battle.opponent2.UserId)
		local animation = self:doVsAnimation({battle.opponent1.Name, battle.opponent2.Name}, {imageId1, imageId2})

		local order, removeTeamPreviewGui
		spawn(function()
			order, removeTeamPreviewGui = teamPreview:getOrder(battle)
		end)
		cam.CFrame = CFrame.new(Vector3.new(0, 200, 390), Vector3.new(20, 240, 390))

		wait(3)
		animation:SlideOff()
		teamPreview:startTimer(true)

		--	local opponent = battle.opponent
		while not order or not battle.opponentReady do
			--		if not opponent.Parent then
			--			-- other player left, ugh
			--			network:post('UpdateTitle')
			--			_p.MusicManager:popMusic('TeamPreview', 1, false)
			--			battle:remove()
			--			
			--			cam.FieldOfView = 70
			--			cam.CoordinateFrame = preBattleCameraCFrame
			--			cam.CameraType = Enum.CameraType.Custom
			--			
			--			pcall(function() teamPreview.forceAutoComplete:fire() end)
			--			teamPreview.timerFinished = true
			--			wait(1)
			--			pcall(function() removeTeamPreviewGui() end)
			--			
			--			MasterControl:Hidden(false)
			--			MasterControl.WalkEnabled = true
			--			spawn(function() _p.Menu:enable() end)
			--			_p.NPCChat:enable()
			--			self.currentBattle = nil
			--			
			--			return
			--		end
			wait()
		end
		teamPreview.timerFinished = true
		battle:send('join', order)
		-- END 2v2 TEAM PREVIEW

		_p.MusicManager:stackMusic(battle.musicId, 'BattleMusic', .4)

		local animContainer = Utilities.Create 'Frame' {
			BackgroundTransparency = 1.0,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.frontGui,
		}
		local animator = battleStartAnims[math.random(#battleStartAnims)](animContainer)
		local ballImage = Utilities.Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6142797841',
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.3, 0, 0.3, 0),
			Position = UDim2.new(0.08, 0, 0.6, 0),
			ZIndex = 4, Parent = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.4, 0),
				Position = UDim2.new(0.5, 0, 0.3, 0),
				Parent = animContainer,
			}
		}

		local dur = .5
		local ballTimer = Utilities.Timing.cubicBezier(1, .3, .75, .55, 1.45)

		Utilities.Tween(dur, nil, function(a)
			local b = ballTimer(a)
			ballImage.Size = UDim2.new(b, 0, b, 0)
			ballImage.Position = UDim2.new(0.0, -ballImage.AbsoluteSize.X/2, 0.5-b/2, 0)
			ballImage.Rotation = -700 * (1-a)
			animator(a, a)
		end)


		local fader = Utilities.fadeGui
		fader.BackgroundColor3 = Color3.new(0, 0, 0)
		fader.BackgroundTransparency = 0.0
		local playerListWasEnabled = _p.PlayerList.enabled
		_p.PlayerList:disable()

		pcall(removeTeamPreviewGui)
		wait(.5)


		while not battle.setupComplete do stepped:wait() end

		ballImage.Parent.Parent = nil
		animContainer:ClearAllChildren()
		ballImage.Parent.Parent = animContainer
		animContainer.BackgroundTransparency = 1.0
		battle:focusScene()
		spawn(function()
			Utilities.Tween(.3, nil, function(a)
				ballImage.ImageTransparency = a
			end)
			animContainer:remove()
		end)
		Utilities.FadeIn(.5)
		battle:takeOver()

		battle.BattleEnded:wait()
		_p.MusicManager:popMusic('TeamPreview', 1, true)
		Utilities.FadeOut(1)
		if playerListWasEnabled then _p.PlayerList:enable() end
		battle:remove(true) -- OVH  TODO: use this to change titles; protect the title API
		cam.FieldOfView = 70
		cam.CoordinateFrame = preBattleCameraCFrame
		if _p.DataManager.currentChunk.indoors then
			_p.DataManager.currentChunk.indoorCamFunc(true)
		else
			cam.CameraType = Enum.CameraType.Custom
		end
		spawn(function() _p.MusicManager:returnFromSilence() end)
--[[	if _p.player:FindFirstChild('BattleResult') then -- OVH  TODO
		local r = _p.player.BattleResult.Value
		local diff
		pcall(function() r, diff = r:match('^(%a+),(.*)$') end)
		pcall(function()
			diff = tonumber(diff)
			diff = (diff < 0) and (' '..diff) or (' +'..diff)
		end)
		if r == 'win' then
			network:post('UpdateTitle', 'Winner'..(diff or ''), Color3.new(.4, .8, 1))
		elseif r == 'lose' then
			network:post('UpdateTitle', 'Loser'..(diff or ''), Color3.new(1, .4, .4))
		elseif r == 'tie' then
			network:post('UpdateTitle', 'Tied'..(diff or ''), Color3.new(.7, .7, .7))
		end
		delay(10, function()
			network:post('UpdateTitle', nil, nil, true)
		end)
	else
		network:post('UpdateTitle')
	end--]]
		Utilities.FadeIn(1)

		_p.MasterControl:Hidden(false)
		_p.MasterControl.WalkEnabled = true
		spawn(function() _p.Menu:enable() end)
		_p.NPCChat:enable()
		self.currentBattle = nil
		_p.Autosave:queueSave()
	end

	function BattleClient:spectate(sdata, siden)
		if self.currentBattle then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.MasterControl:Hidden(true)
		spawn(function() _p.Menu:disable() end)
		_p.NPCChat:disable()

		local bdata = network:get('BattleFunction', sdata.id, 'spectate')
		if bdata then
			local log = bdata.log
			bdata.log = nil
			local td = bdata.td
			bdata.td = nil
			bdata.kind = 'spectate'
			bdata.sdata = sdata
			bdata.siden = siden
			bdata.ignoreNicknamesAt = {}
			bdata.ignoreNicknamesAt['11'] = true
			bdata.ignoreNicknamesAt['12'] = true
			bdata.ignoreNicknamesAt['13'] = true
			bdata.ignoreNicknamesAt['21'] = true
			bdata.ignoreNicknamesAt['22'] = true
			bdata.ignoreNicknamesAt['23'] = true
			--	_p.Battle:doPVPBattle {opponent = from, battleId = request.joinBattle, gameType = request.gameType,
			--		teamPreviewEnabled = request.teamPreviewEnabled, location = request.location, icons = request.icons}
			local battle = BattleClient:new(bdata)
			if td then
				battle:storeQueriedData(td)
			end

			self.currentBattle = battle
			spawn(function() battle:setupScene() end) --
			local cam = workspace.CurrentCamera
			local preBattleCameraCFrame = cam.CoordinateFrame
			cam.CameraType = Enum.CameraType.Scriptable
			_p.DataManager.currentChunk.regionThread = nil

			Utilities.FadeOut(1)--, Color3.new(.3, .3, .3))-- fade out

			local playerListWasEnabled = _p.PlayerList.enabled
			_p.PlayerList:disable()

			while not battle.setupComplete do stepped:wait() end
			battle:focusScene() --
			local ff = false
			if log then
				local n = #log
				for i, u in pairs(log) do
					table.insert(battle.actionQueue, u)
					if u == '|turn|1' and i ~= n then
						ff = true
					end
				end
			end
			if ff then
				-- FAST FORWARD CODE [HACK]
				battle.fastForward = true
				local oldTween = Utilities.Tween
				Utilities.Tween = function(_, _, fn) fn(1) end
				battleGui.moveAnimations.setTweenFunc(Utilities.Tween)

				battle:processUpdates()

				battle.fastForward = false
				Utilities.Tween = oldTween
				battleGui.moveAnimations.setTweenFunc(oldTween)
				--
			end

			Utilities.FadeIn(1)-- fade in
			battle:takeOver() --

			local leaveButton; leaveButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromHSV(0, .9, .5),
				Size = UDim2.new(.1, 0, .0375, 0),
				Position = UDim2.new(.875, 0, .9375, 0),
				Parent = Utilities.backGui,
				MouseButton1Click = function()
					spawn(function() battle:sendAsync('endSpectate') end)
					battle.leave = true
					leaveButton:remove()
					if battle.state == 'idle' then
						battle.done = true
						battle.ended = true
						battle.BattleEnded:fire()
					end
				end
			}
			Utilities.Write 'Leave' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.7, 0),
					Position = UDim2.new(0.5, 0, 0.15, 0),
					ZIndex = 2, Parent = leaveButton.gui
				}, Scaled = true
			}

			battle.BattleEnded:wait() --
			pcall(function() leaveButton:remove() end)

			_p.MusicManager:popMusic('BattleMusic', 1, true)
			Utilities.FadeOut(1)
			if playerListWasEnabled then _p.PlayerList:enable() end

			battle:remove()

			cam.FieldOfView = 70
			cam.CoordinateFrame = preBattleCameraCFrame
			if _p.DataManager.currentChunk.indoors then
				_p.DataManager.currentChunk.indoorCamFunc(true)
			else
				cam.CameraType = Enum.CameraType.Custom
			end
			spawn(function() _p.MusicManager:returnFromSilence() end)
			Utilities.FadeIn(1)
		end
		_p.MasterControl:Hidden(false)
		_p.MasterControl.WalkEnabled = true
		spawn(function() _p.Menu:enable() end)
		_p.NPCChat:enable()
		self.currentBattle = nil
		_p.Autosave:queueSave() -- needed?
	end
	--


--[[
function BattleClient:applyPostBattleUpdates(pbu)
	if not pbu then return false end
	if not pbu.pokemon then return pbu.blackout or false end
	local blackout = true
	for i, p in pairs(pbu.pokemon) do
		local pokemon = _p.PlayerData.party[p.index]
		if not pokemon.egg then
			pokemon.hp = p.hp
			if pokemon.hp > 0 then blackout = false end
			if p.status == '' or not p.status then
				pokemon.status = nil
			else
				pokemon.status = (p.status=='tox') and 'psn' or p.status
			end
			for m, move in pairs(p.moves) do
				local pMove = pokemon.moves[m]
				if pMove then
					local id = rc4(pMove.id)
					if id ~= move.id and id == 'sketch' then
						pMove.id = rc4(move.id)
					end
					pMove.pp = move.pp
				else
					warn(pokemon.name .. ' [' .. p.index .. '] has no move in slot ' .. m .. ' (attempted to update pp for this move)')
				end
			end
			if p.evs then
				for i = 1, 6 do
					pokemon.evs[i] = math.max(pokemon.evs[i], p.evs[i]) -- prevent loss, though ideally it should never happen anyway
				end
			end
		end
	end
	if not blackout then
		self:activatePickup()
	end
	return blackout
end





do -- Pickup
	local primaryList = {'potion', 'antidote', 'superpotion', 'greatball', 'repel', 'escaperope', 'fullheal', 'hyperpotion', 'ultraball', 'revive', 'rarecandy', 'sunstone', 'moonstone', 'heartscale', 'fullrestore', 'maxrevive', 'ppup', 'maxelixer'}
	for i, v in pairs(primaryList) do primaryList[i] = rc4(v) end
	local secondaryList = {'hyperpotion', 'nugget', 'kingsrock', 'fullrestore', 'ether', 'ironball', 'destinyknot', 'elixer', 'destinyknot', 'leftovers', 'destinyknot'}
	for i, v in pairs(secondaryList) do secondaryList[i] = rc4(v) end
	function BattleClient:activatePickup()
		do return end -- disabled for now
		if not self.pickup then return end
		for _, p in pairs(_p.PlayerData.party) do
			if not p.egg and not p.item and p:getAbilityName() == 'Pickup' and math.random(10)==1 then
				pcall(function()
					local itemId
					local l = math.ceil(p.level/10)
					local r = math.random(100)
					if r <= 30 then
						itemId = primaryList[l]
					elseif r <= 90 then
						itemId = primaryList[l+math.ceil((r-30)/10)]
					elseif r <= 98 then
						itemId = primaryList[l+6+math.ceil((r-90)/4)]
					else
						itemId = secondaryList[l+r-99]
					end
					if itemId then
						
					end
				end)
			end
		end
	end
end
--]]









	function BattleClient:onIdle()
		if self.leave and self.kind == 'spectate' then
			self.done = true
			self.ended = true
			self.BattleEnded:fire()
		elseif #self.actionQueue > 0 and self.lastState ~= 'output' then
			--		self:debug('idle -> updates')
			self:processUpdates()
		elseif self.currentRequest and self.lastState ~= 'input' and self.readyForInputFlag then
			--		self:debug('idle -> request')
			self:fulfillRequest()
		else
			--		self:debug('idle -> idling')
			--		self:debug('    last state: '..tostring(self.lastState))
			--		self:debug('    action queue: '..#self.actionQueue)
			--		self:debug('    ready for input: '..tostring(self.readyForInputFlag))
			if self.lastState == 'input' then
				self:toggleWaitingOnOpponent(true)
			end
			self.state = 'idle'
		end
	end

	function BattleClient:setIdle()
		self.Idle:fire() -- to keep stack from overflowing due to alternating between input and output
	end

	function BattleClient:receiveRequest(request)
		if not request then return end
		self.currentRequest = request
		self.lastRequest = request
		if request.qData then
			self:storeQueriedData(request.qData)
			request.qData = nil
		end
		if debug.receive then Utilities.print_r({'request', request}) end
		if request.side then
			self:updateSide(request.side)
		end
		if self.state == 'idle' and self.lastState ~= 'input' and self.readyForInputFlag then
			self:fulfillRequest()
		end
	end

	function BattleClient:fulfillRequest()
		self:toggleWaitingOnOpponent(false)
		if self.done then return end
		self.state = 'input'
		self.lastState = 'input'
		local request = self.currentRequest
		if not request then return end
		self.currentRequest = nil
		self.fulfillingRequest = request
		local active = request.active
		if self.askForUpdatedSideDataFlag then -- OVH  todo
			self.askForUpdatedSideDataFlag = nil
			active = network:get('BattleFunction', self.battleId, 'active', self.sideId)
		end
		self:startTimer(request.requestType)
		if debug.requestsOnFulfill then Utilities.print_r(request) end
		if request.requestType == 'move' then
			wait(.25)
			local choices = {}
			local nActive = battleGui.side.nActive--#request.active
			local i = 1
			local first = true
			local firstValid
			local rewind = false
			while i <= nActive do
				local a = request.active[i]
				if a and not a.fainted then
					if a.teamn and a.teamn ~= self.teamn then
						if self.npcPartner then
							--						print 'choosing random move for npc partner'
							local enabledMoves = {}
							for i, m in pairs(a.moves) do
								if not m.disabled and (not m.pp or m.pp > 0) then
									table.insert(enabledMoves, i)
								end
							end

							choices[i] = 'move '..enabledMoves[math.random(#enabledMoves)]

							print(choices[i])
							--						print(choices[i])
						else
							choices[i] = 'notmyhalf'
						end
					else
						local moves = a.moves
						local moveLocked = #moves==1 and moves[1].maxpp==nil
						if moveLocked and a.trapped then
							choices[i] = 'move 1'
						else
							rewind = false
							if first then
								firstValid = i
								first = false
							else
								wait(.6)
							end
							battleGui.moves = a.moves
							battleGui.fighterIcon = self.mySide.active[i]:getIcon()
							local alreadySwitched = {}
							local alreadyChoseMega = false
							for j = 1, i-1 do
								pcall(function() alreadySwitched[tonumber(choices[j]:match('^switch (%d)$'))] = true end)
								pcall(function() if (choices[j]:find(' mega')) then print("MEGA HACKS") alreadyChoseMega = true end end)
							end
							Utilities.fastSpawn(battleGui.mainChoices, battleGui, a, i, nActive, moveLocked, firstValid==i, alreadySwitched, alreadyChoseMega)
							local choice = self.InputChosen:wait()
							if choice == 'back' then
								rewind = true
							else
								choices[i] = choice
							end
						end
					end
				else
					choices[i] = 'pass'
				end
				i = i + (rewind and -1 or 1)
				if i < 1 then
					i = 1
					rewind = false
				end
			end
			spawn(function() battleGui:toggleRemainingPartyGuis(false) end)
			self:send('choose', self.sideId, choices, request.rqid)
			wait(.7)
			self:setIdle()
		elseif request.requestType == 'switch' then
			if debug.receive then Utilities.print_r(request) end
			if request.foeAboutToSendOut then
				if self:message('[y/n]' .. self.p2.name .. ' is about to send in ' .. request.foeAboutToSendOut .. '. Will you switch your pokemon?') then
					spawn(function() if not battleGui:switchPokemon() then self.InputChosen:fire() end end) -- pretty hacky
					local choice = self.InputChosen:wait()
					--				print('>>', choice)
					if choice then
						self:send('choose', self.sideId, choice, request.rqid)
					else
						self:send('choose', self.sideId, 'pass', request.rqid)
					end
				else
					self:send('choose', self.sideId, 'pass', request.rqid)
				end
			else
				local fs = request.forceSwitch
				local choices = {}
				for i = 1, #fs do
					choices[i] = 'pass'
				end
				local side = request.side--battleGui.side
				if self.npcPartner and fs[2] then
					for i = side.nTeam1+1, #side.healthy do
						if side.healthy[i] then
							choices[2] = 'switch '..i
							break
						end
					end
					fs[2] = false
				elseif self.kind == '2v2' and fs[3-self.myTeamN] then
					choices[3-self.myTeamN] = 'notmyhalf'
					--				if not fs[self.myTeamN] then
					--					-- there is no need for further input from us
					--					self:send('choose', self.sideId, choices, request.rqid)
					--					return
					--				end
				end
				local nSwitchableSlots = 0
				local nSwitchablePokemon = 0
				for i, forced in pairs(fs) do
					if forced then
						nSwitchableSlots = nSwitchableSlots + 1
					end
				end
				for i = side.nActive+1, (side.nTeam1 or 6) do
					if side.healthy[i] then
						nSwitchablePokemon = nSwitchablePokemon + 1
					end
				end
				local switches = (self.kind=='2v2') and 1 or math.min(nSwitchableSlots, nSwitchablePokemon)
				local alreadySwitched = {}
				for i = 1, switches do
					if i > 1 then wait(.8) end
					local chooseSlot = nSwitchableSlots>1 and self.kind~='2v2'
					spawn(function() battleGui:switchPokemon(fs, chooseSlot, alreadySwitched) end)
					local choice, slot = self.InputChosen:wait()
					if self.kind == '2v2' then
						slot = self.myTeamN
					else
						alreadySwitched[tonumber(choice:sub(8))] = true
						if chooseSlot then
							fs[slot] = false
						else
							for i, forced in pairs(fs) do
								if forced then
									slot = i
									break
								end
							end
						end
					end
					nSwitchableSlots = nSwitchableSlots - 1
					--				nSwitchablePokemon = nSwitchablePokemon - 1
					choices[slot] = choice
				end
				--			Utilities.print_r(choices)
				print('choosing', unpack(choices))
				self:send('choose', self.sideId, choices, request.rqid)
			end
			self:setIdle()
			--	elseif request.requestType == 'team' then
			--		
		elseif request.requestType == 'wait' then
			if self.kind == 'pvp' or self.kind == '2v2' then
				self:setIdle()
			end
			--		print('received wait request:')
			--		Utilities.print_r(request)
			--	else
			--		self.lastState = nil
		end
		self.fulfillingRequest = nil
	end

	function BattleClient:receiveUpdate(update)
		local containsWin = false
		for _, u in pairs(update) do
			if debug.actionsOnAdd then print(u) end
			if u:sub(1, 4) == '|win' then
				containsWin = true
			end
			table.insert(self.actionQueue, u)
		end
		if update[#update]:sub(1, 7) == '|player' then
			-- important hack: flush the action queue, we're still waiting for the juicy stuff
			-- if we don't do this, we'll get the black screen of death on random battles (they'll never start)
			self.actionQueue = {}
			return
		end
		if self.state == 'idle' and self.lastState ~= 'output' then
			self:processUpdates()
		elseif containsWin and (self.kind == 'pvp' or self.kind == '2v2') then
			spawn(function() _p.Menu.party:close() end)
			spawn(function() battleGui:exitButtonsMain() end)
			spawn(function() battleGui:toggleRemainingPartyGuis(false) end)
			self:processUpdates()
		end
	end

	function BattleClient:processUpdates()
		self:toggleWaitingOnOpponent(false)
		self:stopTimer()
		self.state = 'output'
		self.lastState = 'output'
		if not self.actionQueue then return end
		while self.actionQueue and #self.actionQueue > 0 and not self.ended do
			local action = table.remove(self.actionQueue, 1)
			if debug.actionsOnRun then print(action) end
			local r = self:run(action)
			if r == false then
				self.state = 'paused'
				return
			end
			if self.leave and self.kind == 'spectate' then
				self.done = true
				self.ended = true
				self.BattleEnded:fire()
				return
			end
		end
		if not self.actionQueue then return end
		if self.kind == 'spectate' then
			-- todo: add message saying "waiting for players..."
			self.lastState = nil -- verify hack
		end
		self:setIdle()
	end

	function BattleClient:updateSide(side)
		if side.id ~= self.sideId then self:debug('side id mismatch on side update') return end
		battleGui.side = side
	end


	function BattleClient:storeQueriedData(data)
		--	Utilities.print_r(data)
		for _, d in pairs(data) do
			Tools.add(unpack(d))
		end
	end

	function BattleClient:send(arg1, ...)
		if arg1 == 'choose' then self:choiceSubmitted() end
		network:post('BattleEvent', self.battleId, arg1, ...)
	end
	function BattleClient:sendAsync(...)
		return network:get('BattleFunction', self.battleId, ...)
	end
	function BattleClient:message(...)
		if self.fastForward then return end
		return battleGui:message(...)
	end
	function BattleClient:promptReplaceMove(...)
		return battleGui:promptReplaceMove(...)
	end
	function BattleClient:animHit(...) return battleGui:animHit(...) end
	function BattleClient:animMove(...) return battleGui:animMove(self, ...) end
	function BattleClient:getMoveAnimation(move) return battleGui.moveAnimations[move] end
	function BattleClient:prepareMove(...) return battleGui:prepareMove(self, ...) end
	function BattleClient:animBoost(p) if self.fastForward then return end return battleGui:animBoost(p, true) end
	function BattleClient:animUnboost(p) if self.fastForward then return end return battleGui:animBoost(p, false) end
	function BattleClient:animAbility(...) if self.fastForward then return end return battleGui:animAbility(...) end
	function BattleClient:animStatus(...) if self.fastForward then return end return battleGui:animStatus(...) end
	function BattleClient:animCapture(...) return battleGui:animCapture(...) end
	function BattleClient:animBerryThrow(...) return battleGui:animBerryThrow(...) end
	function BattleClient:animateEvolution(...) return battleGui:animateEvolution(...) end
	function BattleClient:nicknamePokemon(...) return _p.Pokemon:giveNickname(...) end
	function BattleClient:sound(...) -- presumably no longer needed
		return Utilities.sound(...)
	end
	function BattleClient:getPokemonIcon(...)
		return _p.Pokemon:getIcon(...)
	end
	function BattleClient:debug(...)
		if debug.debug then
			warn('BC::debug:', ...)
		end
	end
	function BattleClient:doEvolution(data)
		_p.Pokemon:processMovesAndEvolution(data, true)
	end
	function BattleClient:sampleOrientation()
		local orientation
		pcall(function()
			local userInputService = game:GetService('UserInputService')
			if not userInputService.AccelerometerEnabled then return end
			orientation = userInputService:GetDeviceGravity().Position
		end)
		return orientation
	end


	function BattleClient:getStatbar(p)
		local s
		if p.side.n == self.mySide.n then
			s = battleGui:createUserHealthGui(#self.mySide.active, p.slot)
			--		p.nonBattleObject = _p.PlayerData.party[p.index] -- OVH  how to replace with similar functionality?
		else
			s = battleGui:createFoeHealthGui(#self.yourSide.active, p.slot)
		end
		s.pokemon = p
		s:update()
		s:slideOnscreen()
		return s
	end

	function BattleClient:getNonBattleObject(poke)
		if poke.side.n ~= self.mySide.n then return end
		return _p.PlayerData.party[poke.index]
	end

	do
		local gui
		local thread

		function BattleClient:toggleWaitingOnOpponent(on)
			Utilities.fastSpawn(function()
				local ep
				if on then
					if self.kind ~= 'pvp' and self.kind ~= '2v2' then return end
					if not gui then
						gui = Utilities.Create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.05, 0),
							Position = UDim2.new(0.5, 0, 1.05, 0),
							Parent = Utilities.gui,
						}
						Utilities.Write 'Waiting for opponent...' {
							Frame = gui,
							Scaled = true,
						}
					end
					gui.Parent = Utilities.gui
					ep = 0.9
				else
					if not gui then return end
					ep = 1.05
				end
				local thisThread = {}
				thread = thisThread
				local sp = gui.Position.Y.Scale
				Utilities.Tween(.25, 'easeOutCubic', function(a)
					if thisThread ~= thread then return false end
					gui.Position = UDim2.new(0.5, 0, sp + (ep-sp)*a, 0)
				end)
				if not on and thisThread == thread then
					gui.Parent = nil
				end
			end)
		end
	end

	do
		local gui, thread
		local forfeit = false
		function BattleClient:startTimer(requestType)
			Utilities.fastSpawn(function()
				if self.kind ~= 'pvp' and self.kind ~= '2v2' then return end
				if not gui then
					gui = Utilities.Create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.09, 0),
						Position = UDim2.new(0.5, 0, 0.05, 0),
						ZIndex = 10,
					}
				end
				local thisThread = {}
				thread = thisThread
				gui.Parent = Utilities.frontGui
				forfeit = true
				local countdown = 90
				local start = tick()
				for i = countdown, 0, -1 do
					if thisThread ~= thread then break end
					gui:ClearAllChildren()
					local s = tostring(i%60)
					if s:len()<2 then s = '0'..s end
					Utilities.Write(math.floor(i/60)..':'..s) { Frame = gui, Scaled = true, }
					wait((countdown-i+1)-(tick()-start))
				end
				gui:ClearAllChildren()
				gui.Parent = nil
				if forfeit and thisThread == thread and requestType and requestType ~= 'wait' then
					self:send('forfeit', self.sideId)
				end
			end)
		end
		function BattleClient:choiceSubmitted()
			forfeit = false
		end
		function BattleClient:stopTimer()
			thread = nil
			if gui then gui:ClearAllChildren() end
		end
	end








	function BattleClient:setupScene()
		pcall(function() if self.trainer.musicId then self.musicId = self.trainer.musicId end end)
		if self.kind ~= 'pvp' and self.kind ~= '2v2' then
			local musicId = self.musicId or {12639579256, 12639579964} -- old: {12639570014, 12639570014}, really old: 282237556
			if musicId ~= 'none' then
				self.music = _p.MusicManager:stackMusic(musicId, 'BattleMusic', self.musicVolume or (self.musicId and .4 or .6))
			end
		end

		local scene = self.scene
		local offset = Vector3.new(0, 95, 385) -- 0, 150, 0
		for _, p in pairs(scene:GetChildren()) do
			if p:IsA('BasePart') then
				MoveModel(p, p.CFrame + offset, true)
				break
			end
		end
		local function check(model)
			for _, p in pairs(model:GetChildren()) do
				if p:IsA('BasePart') then
					p.Anchored = true
					p.CanCollide = false
				end
				check(p)
			end
		end
		check(scene)

		self.CoordinateFrame1 = CFrame.new(scene._User.Position, scene._Foe.Position) + Vector3.new(0, -scene._User.Size.Y/2, 0)
		self.CoordinateFrame2 = CFrame.new(scene._Foe.Position, scene._User.Position) + Vector3.new(0, -scene._Foe.Size.Y/2, 0)

		self.scene = scene
		self.sceneOffset = offset

		local scale = .6
		local function getScaledCharacter(ch, cframe)
			local m = Instance.new('Model', workspace)
			m.Name = 'PlayerCharacterModel'
			local isR15 = ch:FindFirstChild('LowerTorso') and true or false--false
			local hats = {}
			local fakeHats = {}
			for _, obj in pairs(ch:GetChildren()) do
				if obj:IsA('Accoutrement') then
					table.insert(hats, obj)
				elseif obj:IsA('BasePart') and obj.Archivable then
					if obj:IsA('MeshPart') then
						local p = obj:Clone() -- cannot change MeshID at runtime
						p:ClearAllChildren()
						p:BreakJoints()
						p.Size = obj.Size * scale
						p.CanCollide = false
						p.Parent = m
						if not storage.Modelss.R15Rig:FindFirstChild(obj.Name) then
							local h = ch.Head.CFrame-ch.Head.CFrame.p
							table.insert(fakeHats, {p, (obj.CFrame-ch.Head.CFrame.p):inverse() * h})
						end
					else
						local p = Instance.new('Part')
						p.Name = obj.Name
						p.Reflectance = obj.Reflectance
						p.Transparency = obj.Transparency
						p.BrickColor = obj.BrickColor
						pcall(function() p.Shape = obj.Shape end)
						p.Size = obj.Size * scale
						p.CanCollide = false
						p.Parent = m
						if obj.Name == 'Head' or obj.Name == 'Torso' then
							for _, c in pairs(obj:GetChildren()) do
								if c:IsA('Decal') or c:IsA('DataModelMesh') then
									local o = c:Clone()
									o.Parent = p
									if o:IsA('SpecialMesh') and o.MeshType == Enum.MeshType.FileMesh then
										o.Scale = o.Scale * scale
									end
								end
							end
						elseif obj.Name == 'HumanoidRootPart' or obj.Name == 'Right Arm' or obj.Name == 'Left Arm' or obj.Name == 'Right Leg' or obj.Name == 'Left Leg' then

						else
							if obj:FindFirstChild('Mesh') then
								local mesh = obj.Mesh:Clone()
								mesh.Scale = mesh.Scale * scale
								mesh.Parent = p
							end
							local h = ch.Head.CFrame-ch.Head.CFrame.p
							table.insert(fakeHats, {p, (obj.CFrame-ch.Head.CFrame.p):inverse() * h})
						end
					end
				elseif obj:IsA('CharacterAppearance') then
					obj:Clone().Parent = m
				elseif obj:IsA('Humanoid') then
					if obj.RigType == Enum.HumanoidRigType.R15 then
						isR15 = true
					end
				end
			end
			local root = m:FindFirstChild('HumanoidRootPart')
			if not root then
				m:remove()
				return
			end
			root.Transparency = 1
			for _, h in pairs(hats) do
				local handle = h:FindFirstChild('Handle')
				if handle then
					local p = Instance.new('Part')
					p.BrickColor = handle.BrickColor
					p.Size = handle.Size * scale
					p.CanCollide = false
					p.Parent = m
					for _, c in pairs(handle:GetChildren()) do
						if c:IsA('DataModelMesh') then
							local mesh = c:Clone()
							mesh.Parent = p
							if mesh:IsA('SpecialMesh') and mesh.MeshType == Enum.MeshType.FileMesh then
								mesh.Scale = mesh.Scale * scale
							end
						end
					end
					-- new weld system (R15/Accessory compatible)
					local s, e = pcall(function()
						local hatWeld = handle.AccessoryWeld
						local c0, c1 = hatWeld.C0, hatWeld.C1
						local swapped = hatWeld.Part0==handle
						if swapped then c0, c1 = c1, c0 end
						create 'Weld' {
							Part0 = m[hatWeld['Part'..(swapped and '1' or '0')].Name],
							Part1 = p,
							C0 = c0-c0.p+c0.p*scale,
							C1 = c1-c1.p+c1.p*scale,
							Parent = p
						}
					end)
					--				print(s and 'new weld system success!!!' or ('new weld system failed: '..e))
					-- if new system fails, fall back to old
					if not s then
						local ap = h.AttachmentPoint
						create 'Weld' {
							Part0 = m.Head,
							Part1 = p,
							C0 = CFrame.new(0, .5*scale, 0),
							C1 = CFrame.new(ap.p*scale) * (ap-ap.p),
							Parent = m.Head,
						}
					end
				end
			end
			for _, fh in pairs(fakeHats) do
				local ap = fh[2]
				create 'Weld' {
					Part0 = m.Head,
					Part1 = fh[1],
					C0 = CFrame.new(),
					C1 = CFrame.new(ap.p*scale) * (ap-ap.p),
					Parent = m.Head,
				}
			end
			local h
			local s, r = pcall(function()
				h = create 'Humanoid' {
					DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None,
					Parent = m,
				}
				if isR15 then
					h.RigType = Enum.HumanoidRigType.R15
					for _, motor in pairs(Utilities.GetDescendants(storage.Modelss.R15Rig, 'Motor6D')) do
						if motor.Part0 and motor.Part1 then
							local parent = m:FindFirstChild(motor.Parent.Name)
							local p0 = m:FindFirstChild(motor.Part0.Name)
							local p1 = m:FindFirstChild(motor.Part1.Name)
							if parent and p0 and p1 then
								local c0, c1 = motor.C0, motor.C1
								create 'Motor6D' {
									Name = motor.Name,
									Part0 = p0,
									Part1 = p1,
									C0 = c0-c0.p+c0.p*scale,
									C1 = c1-c1.p+c1.p*scale,
									Parent = parent,
								}
							end
						end
					end
				else
					local torso = m.Torso
					local head = m.Head
					create 'Motor6D' {
						Name = 'RootJoint',
						Part0 = root,
						Part1 = torso,
						C0 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
						C1 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
						Parent = root,
					}
					create 'Motor6D' {
						Name = 'Neck',
						Part0 = torso,
						Part1 = head,
						C0 = CFrame.new(0, 1*scale, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
						C1 = CFrame.new(0, -0.5*scale, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
						MaxVelocity = 0.1,
						Parent = torso,
					}
					create 'Motor6D' {
						Name = 'Right Shoulder',
						Part0 = torso,
						Part1 = m:FindFirstChild('Right Arm'),
						C0 = CFrame.new(1*scale, 0.5*scale, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
						C1 = CFrame.new(-0.5*scale, 0.5*scale, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
						MaxVelocity = 0.1,
						Parent = torso,
					}
					create 'Motor6D' {
						Name = 'Left Shoulder',
						Part0 = torso,
						Part1 = m:FindFirstChild('Left Arm'),
						C0 = CFrame.new(-1*scale, 0.5*scale, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
						C1 = CFrame.new(0.5*scale, 0.5*scale, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
						MaxVelocity = 0.1,
						Parent = torso,
					}
					create 'Motor6D' {
						Name = 'Right Hip',
						Part0 = torso,
						Part1 = m:FindFirstChild('Right Leg'),
						C0 = CFrame.new(1*scale, -1*scale, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
						C1 = CFrame.new(0.5*scale, 1*scale, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
						MaxVelocity = 0.1,
						Parent = torso,
					}
					create 'Motor6D' {
						Name = 'Left Hip',
						Part0 = torso,
						Part1 = m:FindFirstChild('Left Leg'),
						C0 = CFrame.new(-1*scale, -1*scale, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
						C1 = CFrame.new(-0.5*scale, 1*scale, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
						MaxVelocity = 0.1,
						Parent = torso,
					}
				end
				h:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId[isR15 and 'R15_Idle' or 'NPCIdle'] }):Play()
			end)
			if not s then print(r) end
			local bg = create 'BodyGyro' {
				MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
				CFrame = cframe,
				Parent = root
			}
			local bp = create 'BodyPosition' {
				MaxForce = Vector3.new(0, math.huge, 0),
				Position = cframe.p,
				Parent = root
			}
			local throw = h:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId[isR15 and 'R15_ThrowBall' or 'ThrowBall'] })
			local ZDance = h:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId[isR15 and 'R15_ZPower' or 'ZPower'] })

			root.CFrame = cframe
			return {Root = root, Humanoid = h, BodyGyro = bg, BodyPosition = bp, ThrowAnimation = throw, ZDance = ZDance, Model = m, Scale = scale, CFrame = cframe}
		end

		local pcf = self.CoordinateFrame1 + Vector3.new(0, 3*scale, 0)
		if self.kind == 'trainer' and self.npcPartner then
			local modelName = 'Jake'
			if self.npcPartner:sub(1, 4):lower() == 'tess' then
				modelName = 'Tess'
			end
			pcf = pcf * CFrame.new(-3.2, 0, 0)
			self.playerModelObj2 = getScaledCharacter(_p.storage.Modelss.NPCs[modelName], self.CoordinateFrame1 * CFrame.new(3.2, 3*scale, 0))
		elseif self.kind == '2v2' then
			local character
			pcall(function() character = self.partner.Character end)

			pcf = pcf * CFrame.new(self.myTeamN==1 and -3.2 or 3.2, 0, 0)
			self.playerModelObj2 = getScaledCharacter(character or storage.Modelss.R15Rig, self.CoordinateFrame1 * CFrame.new(self.myTeamN==1 and 3.2 or -3.2, 3*scale, 0))
		end
		if self.kind == 'spectate' then -- 2v2specdo: spectating 2v2s O.o
			local character
			pcall(function() character = game:GetService('Players'):FindFirstChild(self.mySide.name).Character end)
			local pObj = getScaledCharacter(character or storage.Modelss.R15Rig, pcf)
			self.playerModel = pObj.Model
			self.playerModelObj = pObj

			character = nil
			pcall(function() character = game:GetService('Players'):FindFirstChild(self.yourSide.name).Character end)
			local oObj = getScaledCharacter(character or storage.Modelss.R15Rig, self.CoordinateFrame2 + Vector3.new(0, 3*scale, 0))
			self.trainerModel = oObj.Model
			self.trainerModelObj = oObj
		else
			local pObj = getScaledCharacter(player.Character, pcf)
			self.playerModel = pObj.Model
			self.playerModelObj = pObj
		end
		if self.kind == 'trainer' then
			local tObj = getScaledCharacter(self.trainerModel or _p.storage.Modelss.NPCs[self.trainer.ModelName or self.trainer.TrainerClass], self.CoordinateFrame2 + Vector3.new(0, 3*scale, 0))
			tObj.WalkAnimation = tObj.Humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCWalk })
			self.trainerModel = tObj.Model
			self.trainerModelObj = tObj
		elseif self.kind == 'pvp' then
			local tObj = getScaledCharacter(self.opponent.Character, self.CoordinateFrame2 + Vector3.new(0, 3*scale, 0))
			self.trainerModel = tObj.Model
			self.trainerModelObj = tObj
		elseif self.kind == '2v2' then
			local character
			pcall(function() character = self.opponent1.Character end)
			local tObj = getScaledCharacter(character or storage.Modelss.R15Rig, self.CoordinateFrame2 * CFrame.new(-3.2, 3*scale, 0))
			self.trainerModel1 = tObj.Model
			self.trainerModelObj1 = tObj

			character = nil
			pcall(function() character = self.opponent2.Character end)
			tObj = getScaledCharacter(character or storage.Modelss.R15Rig, self.CoordinateFrame2 * CFrame.new(3.2, 3*scale, 0))
			self.trainerModel2 = tObj.Model
			self.trainerModelObj2 = tObj

			if self.myTeamN == 2 then
				self.playerModel, self.playerModel2 = self.playerModel2, self.playerModel
				self.playerModelObj, self.playerModelObj2 = self.playerModelObj2, self.playerModelObj
			end
		end

		self.setupComplete = true
	end

	function BattleClient:focusScene()
		self.scene.Parent = workspace--.CurrentCamera
		local sc = self.battleCamera
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		cam.FieldOfView = sc.FieldOfView
		cam.CFrame = sc.CoordinateFrame + self.sceneOffset

		if self.kind == 'wild' then
			self.pauseAfterSwitchFlag = true
			self:setIdle()
			while self.state ~= 'paused' do stepped:wait() end
			self.lastState = 'input'
		end
	end

	function BattleClient:takeOver()
		if self.kind == 'wild' then
			local foe = self.p2.pokemon[1]
			foe.sprite:playCry()
			self:message('A wild ' .. foe.name .. ' appeared!')
		elseif self.kind == 'trainer' then
			self:message(self.p2.name .. ' would like to battle!')
		end
		self:setIdle()
	end

	function BattleClient:winner(winner)
		self.done = true
		--	print(type(winner), winner)
		if winner then
			if self.kind == 'trainer' and winner == '1' then--_p.PlayerData.trainerName then
				local trainer = self.trainerModelObj
				local root = trainer.Root
				local parts = {}
				for _, p in pairs(trainer.Model:GetChildren()) do if p:IsA('BasePart') and p ~= root then table.insert(parts, p) end end
				local d = ((trainer.Root.Position-self.CoordinateFrame2.p)*Vector3.new(1,0,1)).magnitude
				trainer.Model.Parent = self.scene
				local walkTime = .75
				local walk = trainer.WalkAnimation
				walk:Play()
				local v = create 'BodyVelocity' {
					MaxForce = Vector3.new(math.huge, 0, math.huge),
					Velocity = trainer.CFrame.lookVector*d/walkTime,
					Parent = trainer.Root,
				}
				Utilities.Tween(.25, nil, function(a)
					local t = 1-a
					for _, p in pairs(parts) do p.Transparency = t end
				end)
				wait(walkTime-.25)
				walk:Stop()
				v:remove()
				local lf = self.losePhrase or (self.trainer and self.trainer.LosePhrase)
				if lf then
					if type(lf) == 'table' then
						_p.NPCChat:say(trainer.Model.Head, unpack(lf))
					else
						_p.NPCChat:say(trainer.Model.Head, lf)
					end
				end
				for i = #self.actionQueue, 1, -1 do
					if self.actionQueue[i]:sub(2, 7) == 'payout' then
						self:run(table.remove(self.actionQueue, i))
						break
					end
				end
			end
		else
			-- tie
		end
		self.ended = true
		self.BattleEnded:fire()
	end


	function BattleClient:remove(isPVP)
		--	print('battle::remove')
		self:stopTimer()
		self:toggleWaitingOnOpponent(false)
		if self.kind ~= 'spectate' then
			network:post('BattleEvent', self.battleId, isPVP and 'finish' or 'remove')
		end

		pcall(function() self.scene:remove() end)
		pcall(function() self.playerModel:remove() end)
		pcall(function() self.trainerModel:remove() end)
		pcall(function() self.playerModelObj2.Model:remove() end)
		pcall(function() self.trainerModelObj2.Model:remove() end)
		self.playerModelObj = nil
		self.trainerModelObj = nil
		self.playerModelObj2 = nil
		self.trainerModelObj2 = nil
		pcall(function() self.music:remove() end)
		for _, cn in pairs(self.cns) do
			pcall(function() cn:disconnect() end)
		end
		network:bindEvent('BattleEvent', nil) -- unbinding

		for i, s in pairs(self.sides) do
			pcall(function() s:remove() end)
			self.sides[i] = nil
		end
		self.mySide = nil
		self.yourSide = nil
		self.p1 = nil
		self.p2 = nil
		Tools.empty()

		self.foe = nil
		battleGui.side = nil
		battleGui:afterBattle()

		self.lastRequest = nil

	end


	require(script.Actions)(BattleClient)
	require(script.Extras)(BattleClient, _p)


	return BattleClient end