return function(_p)--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local create = Utilities.Create

	local Fishing = {}

	local anims = {
		idle = create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.RodIdle },
		cast = create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.RodCast },
		reel = create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.RodReel }
	}
	local r15anims = {
		idle = create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.R15_RodIdle },
		cast = create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.R15_RodCast },
		reel = create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.R15_RodReel }
	}
	local animTracks = {}

	local oldrod = Utilities.rc4('oldrod')
	local goodrod = Utilities.rc4('goodrod')
	local superrod = Utilities.rc4('superrod')
	local storage = game:GetService("ReplicatedStorage")
	local bobber = storage.Modelss:FindFirstChild('RodBobber'):Clone()
	Utilities.Create 'Weld' {
		Part0 = bobber.Main,
		Part1 = bobber.Top,
		C0 = CFrame.new(),
		C1 = bobber.Top.CFrame:inverse() * bobber.Main.CFrame,
		Parent = bobber.Main,
	}
	Utilities.Create 'Weld' {
		Part0 = bobber.Main,
		Part1 = bobber.Bottom,
		C0 = CFrame.new(),
		C1 = bobber.Bottom.CFrame:inverse() * bobber.Main.CFrame,
		Parent = bobber.Main,
	}
	bobber.Top.Anchored = false
	bobber.Bottom.Anchored = false


	local cachedHumanoid
	local function getHumanoid()
		if cachedHumanoid and cachedHumanoid.Parent == _p.player.Character then
			return cachedHumanoid
		end
		for _, human in pairs(_p.player.Character:GetChildren()) do
			if human:IsA('Humanoid') then
				cachedHumanoid = human
				local isR15 = human.RigType == Enum.HumanoidRigType.R15
				for name, animation in pairs(isR15 and r15anims or anims) do
					animTracks[name] = human:LoadAnimation(animation)
				end
				return human
			end
		end
	end


	local reeled = false
	local canReel = false
	local reelSignal = Utilities.Signal()
	function Fishing:init()
		spawn(function()
			local player = _p.player
			repeat wait() until player.Character
			getHumanoid()
		end)
		_p.NPCChat.AdvanceSignal:connect(function()
			if canReel then
				canReel = false
				reelSignal:fire()
				reeled = true
			end
		end)
	end

	local function resetStreak()
		_p.Network:post('PDS', 'resetFishStreak')
	end

	local function fishStepBreakStreakFunc()
		resetStreak()
		_p.WalkEvents:unbindFromStep('FishingStreak')
	end


	function Fishing:Fish(kind, pos)
		local encounters
		pcall(function() encounters = _p.DataManager.currentChunk.regionData[kind] end)
		getHumanoid()
		if _p.Surf.surfing then
		_p.Surf:beforeFishing()
		end
		local rod = _p.storage.Modelss[kind]:Clone()
		rod.Parent = _p.player.Character
		local main = rod.Arm
		for _, p in pairs(rod:GetChildren()) do
			if p:IsA('BasePart') and p ~= main then
				Utilities.Create 'Weld' {
					Part0 = main,
					Part1 = p,
					C0 = CFrame.new(),
					C1 = p.CFrame:inverse() * main.CFrame,
					Parent = main,
				}
				p.Anchored = false
			end
		end
		bobber.Main.Anchored = false
		bobber.Parent = _p.player.Character
		local isR15 = false
		local offset = 0
		local arm = _p.player.Character:FindFirstChild('Right Arm')
		if not arm then
			arm = _p.player.Character:FindFirstChild('RightHand')
			if arm then
				isR15 = true
				offset = .8325
			end
		end
		local bobberWeld = Utilities.Create 'Weld' {
			Part0 = arm,
			Part1 = bobber.Main,
			C0 = CFrame.new(0, -1 + offset, -5.5),
			C1 = CFrame.new(),
			Parent = arm,
		}
		main.Anchored = false
		Utilities.Create 'Weld' {
			Part0 = arm,
			Part1 = main,
			C0 = CFrame.new(0, offset, 0),
			C1 = CFrame.new(),
			Parent = arm,
		}
		animTracks.cast:Play(.3)
		wait(.3)
		animTracks.idle:Play(.2)
		wait(.2)
		do--spawn(function()
			local pp = _p.player.Character.HumanoidRootPart.Position
			local cf1 = bobber.Main.CFrame
			local cf2 = CFrame.new(pos, Vector3.new(pp.x, pos.y, pp.z))*CFrame.Angles(0,math.pi,0)
			local lerp = select(2, Utilities.lerpCFrame(cf1, cf2))
			local duration = .5
			local timer = Utilities.Timing.easeOutCubic(1)
			bobberWeld:remove()
			Utilities.Tween(duration, nil, function(a)
				local cf = lerp(timer(a))
				bobber.Main.CFrame = cf + Vector3.new(0, -cf.y+cf1.y+(cf2.y-cf1.y)*a, 0)
			end)
			bobber.Main.Anchored = true
		end--)
		reeled = false
		canReel = true
		Utilities.Tween(.2+4*math.random(), nil, function(_)
			if reeled then return false end
		end)
		if reeled then
			animTracks.reel:Play(.15)
			wait(.15)
			resetStreak()
			_p.NPCChat:say('Oops! Reeled in too soon...')
			animTracks.reel:Stop(.3)
		elseif encounters and (_p.PlayerData.firstNonEggAbility == 'Suction Cups' or math.random(5) > 1) then
			local reelCn; reelCn = reelSignal:connect(function()
				reelCn:disconnect()
				animTracks.reel:Play(.15)
				wait(.2)
				_p.WalkEvents:resetStepDistance()
				_p.WalkEvents:bindToStep('FishingStreak', fishStepBreakStreakFunc)
				delay(2, function()
					animTracks.reel:Stop(.3)
				end)
				local scene = 'Fishing'
				pcall(function()
					local s = _p.DataManager.currentChunk.regionData.RodScene
					if s then scene = s end
				end)
				_p.Battle:doWildBattle(encounters, {battleSceneType = scene})
			end)
			local char = _p.player.Character
			local part = create 'Part' {
				Size = Vector3.new(1, 1, 1),
				Anchored = true,
				CanCollide = false,
				Transparency = 1.0,
				CFrame = char.Head.CFrame * CFrame.new(0, 2, 0),
				Parent = char,
			}
			local bbg = create 'BillboardGui' { Adornee = part, Parent = part, }
			local exc = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Parent = Utilities.gui,
			}
			Utilities.Write '!' { Frame = exc, Scaled = true, }
			exc.Parent = bbg
			exc.Size = UDim2.new(1.0, 0, 1.0, 0)
			local duration = .35
			Utilities.Tween(duration, Utilities.Timing.cubicBezier(duration, .85, 0, .6, 2), function(a)
				bbg.Size = UDim2.new(1.8, 0, 1.8*a, 0)
			end)
			wait(.25)
			bbg:remove()
			part:remove()
			wait(.15)
			reelCn:disconnect()

			if reeled then
				wait(2)
			else
				animTracks.reel:Play(.15)
				wait(.15)
				resetStreak()
				_p.NPCChat:say('Oops! Reeled in too late...')
				animTracks.reel:Stop(.3)
			end
		else
			resetStreak()
			_p.NPCChat:say('Nothing seems to be biting...')
		end
		canReel = false
		animTracks.idle:Stop()
		rod:remove()
		bobber.Parent = nil
		if _p.Surf.surfing then
			_p.Surf:afterFishing()
		end
	end


	function Fishing:getClosestSurfWall(pos)
		local Closest = nil
		local pp = _p.player.Character.HumanoidRootPart.Position
		
		-- Get all SurfWalls in current chunk
		for _, v in pairs(_p.DataManager.currentChunk.map:GetChildren()) do
			if v.Name == "SurfWall" or v.Name == "NotSurfWall" then 
				if Closest == nil then
					Closest = v
				else
					if (pp - v.Position).magnitude < (Closest.Position - pp).magnitude then
						Closest = v
					end
				end
			end
		end
		
		return Closest
	end

	function Fishing:OnWaterClicked(pos)
		if not _p.MasterControl.WalkEnabled then 
			return 
		end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() 
			_p.MasterControl:LookAt(pos) 
		end)


		local own
		local srf, pName
		Utilities.fastSpawn(function() own = _p.Network:get('PDS', 'getWtrOp') end)
		Utilities.fastSpawn(function() srf, pName = _p.Network:get('PDS', 'getWtrSurf') end)


--[[ 		local Closest = nil
		local pp = _p.player.Character.HumanoidRootPart.Position
		for _,v in pairs(_p.DataManager.currentChunk.map:GetChildren()) do
			if v.Name == "SurfWall" or v.Name == "NotSurfWall" then 
				if Closest == nil then
					Closest = v
				else
					if (pp - v.Position).magnitude < (Closest.Position - pp).magnitude then
						Closest = v
					end
				end
			end
		end 
		--]]
		--[[
		if not _p.DataManager.currentChunk.map:FindFirstChild('SurfWall') then
			Closest = _p.DataManager.currentChunk.map--Check if it is a part that can be used?
		end
		--]]

		-- Show initial water message
		if not _p.Surf.surfing then
			_p.NPCChat:say("The water is a nice, clear blue.")
		end

		-- Wait for the player to get their fishing rods
		while not own do wait() end

		local wtrH
		local options = {}
		print(_p.DataManager.currentChunk)
		if _p.DataManager.currentChunk.map:FindFirstChild("Water") then
			wtrH = _p.DataManager.currentChunk.map:FindFirstChild("Water").Position.Y;
		end

		-- Check for surf
		local Closest = self:getClosestSurfWall(pos)
		if Closest and Closest.Name == 'SurfWall' and srf and srf.ord and not _p.Surf.surfing then
			table.insert(options, 'Surf')
		end

		-- Check for fishing rods
		if own.ord then
			table.insert(options, 'Old Rod')
		end
		if own.grd then
			table.insert(options, 'Good Rod')
		end	

		-- Show options menu if we have any options
		if #options > 0 then
			spawn(function() _p.Menu:disable() end)
			table.insert(options, 'Cancel')
			local choice = options[_p.NPCChat:choose(unpack(options))]
			if (choice == 'Surf' and _p.NPCChat:say('[y/n]Would you like '..pName..' to use Surf?')) then 
				_p.NPCChat:say(pName..' used Surf!') 
				_p.Surf:surf(nil, Closest.CFrame, _p.DataManager.currentChunk.map.Water.Position.Y)
			elseif choice == 'Old Rod' then
				self:Fish('OldRod', pos)
			elseif choice == 'Good Rod' then --Good Rod
				self:Fish('GoodRod', pos)
			end
		end
		--]]
		
		--[[
		--old fishing
		local own
		Utilities.fastSpawn(function() own = _p.Network:get('PDS', 'getWtrOp') end)
		_p.NPCChat:say('The water is a nice, clear blue.')
		while not own do wait() end
		local wtrH
		local options = {}
		print(_p.DataManager.currentChunk)
		if _p.DataManager.currentChunk.map:FindFirstChild("Water") then
			wtrH = _p.DataManager.currentChunk.map:FindFirstChild("Water").Position.Y;
		end
		if own.ord then
			table.insert(options, 'Old Rod')
		end
		if own.grd then
			table.insert(options, 'Good Rod')
		end	
		local surfer = _p.Network:get('PDS', 'getSurfer')
		if surfer and not _p.Surf.surfing then
			table.insert(options, 'Surf')
		end
		if #options > 0 then
			spawn(function() _p.Menu:disable()
			end)
			table.insert(options, 'Cancel')
			local choice = options[_p.NPCChat:choose(unpack(options))]
			if choice == 'Old Rod' then
				self:Fish('OldRod', pos)
			elseif choice == 'Good Rod' then
				self:Fish('GoodRod', pos)
			elseif choice == 'Surf' and _p.NPCChat:say('[y/n]Would you like '..surfer..' to use Surf?') then 
				_p.NPCChat:say(surfer..' used Surf!')


				-- [[		
				for _, Wall in pairs(_p.DataManager.currentChunk.map:GetChildren()) do
					if Wall.Name == "SurfWall" then
						local moveto = (Wall.CFrame.p - _p.player.Character.HumanoidRootPart.CFrame.p).Magnitude
						if moveto <= 50 then
							_p.Surf:surf(nil, Wall.CFrame, _p.DataManager.currentChunk.map.Water.Position.Y)--cf,wall,water
						else

							print(moveto)
						end
					end
				end

			end
		end
--]]
		if not _p.Battle.currentBattle then
			_p.MasterControl.WalkEnabled = true
			_p.Menu:enable()
		end
	end
	return Fishing 
end