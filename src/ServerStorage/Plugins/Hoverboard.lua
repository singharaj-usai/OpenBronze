return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create

	local hoverModule = {}
	local player = game:GetService("Players").LocalPlayer
	local equipping = false
	local hoverboard, hoverWeld
	local runService = game:GetService("RunService")
	local HOVER_CAM_STEP_ID = "HoverboardCamera"
	local animations = {"h_idle","h_mount","h_forward","h_backward","h_left", "h_right","h_trick1","h_trick2","h_trick3"} -- todo: replace with uploaded animations

	local animationTracks = {}
	local playingAnims = {}

	local function setPlaying(name, playing)
		if playingAnims[name] == playing then
			return
		end
		playingAnims[name] = playing
		if playing then
			animationTracks[name]:Play(0.3)
		else
			animationTracks[name]:Stop(0.3)
		end
	end

	function hoverModule:init()
		local MasterControl = _p.MasterControl
	end

	local CurrentSpeed = 0
	local Acceleration = 40
	local CoastDecel = 0.8
	local MaxSpeed = 36
	local MaxSpeedReverse = 15
	local TurnRate = 4
	local TurnSpeed = 0
	local Dampening = 0.5
	local MaxTilt = math.rad(55)
	local bPosition, bGyro, bAngularVelocity, bVelocity, board
	local lastTrickAt, lastTrickRay = 0, 0
	local trickThread, hillStartTick
	local BaseAcceleration = Acceleration
	local TrickAngleTolerance = math.rad(70) / 2
	local HoverHeight = 2.0
	local StepHeight = 2.5
	local RayDistance = 4.0

	local function setup(board)
		bAngularVelocity = create("BodyAngularVelocity")({
			MaxTorque = Vector3.new(0, 9000000, 0),
			AngularVelocity = Vector3.new(0, 0, 0),
			P = 950,
			Parent = board
		})
		bVelocity = create("BodyVelocity")({
			MaxForce = Vector3.new(15000, 0, 15000),
			Velocity = Vector3.new(0, 0, 0),
			P = 800,
			Parent = board
		})
		bGyro = create("BodyGyro")({
			CFrame = board.CFrame,
			MaxTorque = Vector3.new(9000000, 0, 9000000),
			Parent = board
		})
		bPosition = create("BodyPosition")({
			Position = board.Position,
			MaxForce = Vector3.new(0, 9000000, 0),
			P = 10000,
			Parent = board
		})
	end

	local hoverCam = function()
		local cam = workspace.CurrentCamera
		if cam.CameraType ~= Enum.CameraType.Follow then
			return
		end
		local focus = cam.Focus.p
		local dif = cam.CFrame.p - focus
		local zoom = dif.magnitude
		if zoom > 15 then
			cam.CFrame = CFrame.new(focus + dif.unit * 15, focus)
		elseif zoom == 0 then
			cam.CFrame = CFrame.new(focus + Vector3.new(0, 0, 5), focus)
		elseif zoom < 7 then
			cam.CFrame = CFrame.new(focus + dif.unit * 7, focus)
		end
	end

	local lastTick
	local needReset = false
	local lean = CFrame.new()
	local up = Vector3.new(0, 1, 0)
	local xzplane = Vector3.new(1, 0, 1)
	local players = game:GetService("Players")
	local getPfromC = players.GetPlayerFromCharacter

	-- Helper for raycasting with ignore function behavior
	local function raycast(origin, direction, ignoreList)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignoreList
		params.IgnoreWater = true

		local result = workspace:Raycast(origin, direction, params)

		-- Emulate ignore function: ignore non-collide or other players
		while result do
			local hit = result.Instance
			if not hit.CanCollide or getPfromC(players, hit.Parent) then
				table.insert(ignoreList, hit)
				params.FilterDescendantsInstances = ignoreList
				result = workspace:Raycast(origin, direction, params)
			else
				break
			end
		end

		return result
	end

	local hillTimeLabel = create("TextLabel")({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0.05, 0),
		TextScaled = true,
		TextColor3 = Color3.fromRGB(179, 224, 255),
		TextStrokeColor3 = Color3.fromRGB(24, 84, 128),
		TextStrokeTransparency = 0,
		Font = Enum.Font.Code
	})

	local function control(_, moveDir)
		if not hoverModule.equipped then
			return
		end
		if not _p.MasterControl.WalkEnabled then
			if not needReset then
				return
			end
			needReset = false
			bAngularVelocity.AngularVelocity = Vector3.new()
			bVelocity.Velocity = Vector3.new()
			setPlaying("h_forward", false)
			setPlaying("h_backward", false)
			setPlaying("h_left", false)
			setPlaying("h_right", false)
			return
		end
		needReset = true
		if not lastTick then
			lastTick = os.clock()
			return
		end
		local now = os.clock()
		local dt = now - lastTick
		lastTick = now
		Acceleration = BaseAcceleration
		local throttle, steer = -moveDir.Z, moveDir.X
		if throttle > 0 then
			do
				local ms = MaxSpeed
				pcall(function()
					if _p.DataManager.currentChunk.id == "chunk47" then
						local pp = player.Character.HumanoidRootPart.Position
						if CurrentSpeed > 30 then
							local now = os.clock()
							local et = now - lastTrickAt
							if et < 1 then
								ms = MaxSpeed + 60
								Acceleration = BaseAcceleration * 2
							elseif pp.Z > 340 and pp.Z < 1260 then
								if et < 1.5 then
									ms = MaxSpeed + 60 - 20 * (et - 1)
								else
									ms = MaxSpeed + 40
								end
								if now - lastTrickRay > 0.1 then
									lastTrickRay = now

									local params = RaycastParams.new()
									params.FilterType = Enum.RaycastFilterType.Include
									params.FilterDescendantsInstances = {_p.DataManager.currentChunk.map.HoverSpeedRamps}
									local result = workspace:Raycast(pp, Vector3.new(0, -8, 0), params)
									local ramp = result and result.Instance

									if ramp then
										local rv = -ramp.CFrame.lookVector
										local bv = board.CFrame.lookVector
										if math.acos(rv.X * bv.X + rv.Z * bv.Z) < TrickAngleTolerance then
											lastTrickAt = now
											do
												local thisThread = {}
												trickThread = thisThread
												ms = MaxSpeed + 60
												Acceleration = BaseAcceleration * 2
												animationTracks["h_trick" .. math.random(3)]:Play()
												task.spawn(function()
													local cam = workspace.CurrentCamera
													local custom = Enum.CameraType.Custom
													local follow = Enum.CameraType.Follow
													local sFOV = cam.FieldOfView
													local dFOV = 90 - sFOV
													Utilities.Tween(0.25, "easeOutCubic", function(a)
														if cam.CameraType == custom then
															cam.FieldOfView = 70
															return false
														elseif cam.CameraType == follow then
															cam.FieldOfView = sFOV + dFOV * a
														end
													end)
													task.wait(0.5)
													Utilities.Tween(0.5, nil, function(a)
														if trickThread ~= thisThread then
															return false
														end
														if cam.CameraType == custom then
															cam.FieldOfView = 70
															return false
														elseif cam.CameraType == follow then
															cam.FieldOfView = 70 + 20 * (1 - a)
														end
													end)
												end)
											end
										end
									end
								end
							end
						end
						if hillStartTick then
							if pp.Z < 341 then
								hillStartTick = nil
								hillTimeLabel.Parent = nil
							elseif pp.Z > 1260 then
								local dur = os.clock() - hillStartTick
								hillTimeLabel.Text = string.format("%d:%02d.%02d", math.floor(dur / 60), math.floor(dur % 60), math.floor(dur % 1 * 100))
								hillStartTick = nil
								task.spawn(function()
									task.wait(0.5)
									for i = 1, 3 do
										hillTimeLabel.Visible = false
										task.wait(0.3)
										hillTimeLabel.Visible = true
										task.wait(1.2)
									end
									hillTimeLabel.Parent = nil
								end)
								if _p.Network:get("PDS", "reportSlopeTime", dur) then
									_p.PlayerData.slopeRecord = dur
								end
							else
								local dur = os.clock() - hillStartTick
								hillTimeLabel.Text = string.format("%d:%02d.%02d", math.floor(dur / 60), math.floor(dur % 60), math.floor(dur % 1 * 100))
							end
						elseif pp.Z > 340 and pp.Z < 460 then
							hillStartTick = os.clock()
							hillTimeLabel.Text = "0:00.00"
							hillTimeLabel.Parent = Utilities.backGui
						end
					end
				end)
				CurrentSpeed = math.min(ms, CurrentSpeed + throttle * Acceleration * dt)
			end
		elseif throttle < 0 then
			CurrentSpeed = math.max(-MaxSpeedReverse, CurrentSpeed + throttle * Acceleration * dt)
		elseif CurrentSpeed ~= 0 then
			local sign = CurrentSpeed > 0 and 1 or -1
			CurrentSpeed = sign * math.max(0, math.abs(CurrentSpeed) - Acceleration * CoastDecel * dt)
		end
		if steer ~= 0 then
			TurnSpeed = -steer
		elseif math.abs(TurnSpeed) > Dampening then
			TurnSpeed = TurnSpeed - Dampening * (math.abs(TurnSpeed) / TurnSpeed)
		else
			TurnSpeed = 0
		end
		setPlaying("h_forward", throttle > 0)
		local backward = CurrentSpeed < 0 and throttle < 0
		setPlaying("h_backward", backward)
		setPlaying("h_left", steer < 0 and not backward)
		setPlaying("h_right", steer > 0 and not backward)
		local bcf = board.CFrame * lean:inverse()

		local rays = {
			{ offset = Vector3.new(0, 0, -2), dir = bcf.upVector * -RayDistance },
			{ offset = Vector3.new(0, 0, 2), dir = bcf.upVector * -RayDistance },
			{ offset = Vector3.new(-1, 0, 0), dir = bcf.upVector * -RayDistance },
			{ offset = Vector3.new(1, 0, 0), dir = bcf.upVector * -RayDistance },
			{ offset = Vector3.new(0, 0, 0), dir = bcf.upVector * -RayDistance }
		}

		local hitPoints = {}
		local hitNormals = {}
		local validHits = 0

		for _, rayData in ipairs(rays) do
			local result = raycast(bcf * rayData.offset, rayData.dir, {player.Character})
			if result then
				validHits = validHits + 1
				table.insert(hitPoints, result.Position)
				table.insert(hitNormals, result.Normal)
			end
		end

		if validHits > 0 then
			local avgPos = Vector3.new(0, 0, 0)
			local avgNormal = Vector3.new(0, 1, 0)

			for i = 1, #hitPoints do
				avgPos = avgPos + hitPoints[i]
				avgNormal = avgNormal + hitNormals[i]
			end

			avgPos = avgPos / validHits
			avgNormal = (avgNormal / validHits).Unit

			local targetPos = avgPos + avgNormal * HoverHeight

			local cross = up:Cross(avgNormal)
			local angle = math.asin(cross.magnitude)
			local canClimb = true

			local slopeMultiplier = 1.0

			if angle > 0 then
				slopeMultiplier = math.max(0.4, 1.0 - (angle / MaxTilt) * 0.6)

				if angle > MaxTilt then
					canClimb = false
					local nxz = (avgNormal * xzplane).unit
					avgNormal = Vector3.new(nxz.X * math.sin(MaxTilt), math.cos(MaxTilt), nxz.Z * math.sin(MaxTilt))
				end
			end

			local heightDifference = targetPos.Y - bcf.Y
			if heightDifference > 0 and heightDifference < StepHeight then
				canClimb = true
			end

			bPosition.Parent = board
			local right = (bcf.rightVector * xzplane).unit
			local back = right:Cross(avgNormal)
			bGyro.CFrame = CFrame.new(bcf.x, bcf.y, bcf.z, right.X, avgNormal.X, back.X, right.Y, avgNormal.Y, back.Y, right.Z, avgNormal.Z, back.Z)

			local targetY = canClimb and targetPos.Y or bcf.Y
			bPosition.Position = Vector3.new(0, targetY, 0)

			local modifiedSpeed = CurrentSpeed * slopeMultiplier
			local dir = bcf.lookVector
			local v = dir * modifiedSpeed

			if not canClimb and v.Y > 0 then
				local downForce = math.min(3, heightDifference * 2)
				v = Vector3.new(v.X, -downForce, v.Z)
			elseif heightDifference < -1 then
				v = v + Vector3.new(0, heightDifference * 0.5, 0)
			end

			bVelocity.Velocity = v
		else
			bPosition.Parent = nil
			local flatlook = bcf.lookVector * xzplane
			if flatlook.X ~= 0 or flatlook.Z ~= 0 then
				local goalcf = CFrame.new(bcf.p, bcf.p + flatlook.unit)
				bGyro.CFrame = select(2, Utilities.lerpCFrame(bcf, goalcf))(dt)
			end

			local v = bcf.lookVector * CurrentSpeed
			v = v + Vector3.new(0, -2, 0)
			bVelocity.Velocity = v
		end

		bAngularVelocity.AngularVelocity = Vector3.new(0, TurnRate * TurnSpeed, 0)
		local dir = bcf.lookVector
		local v = dir * CurrentSpeed
		if not canClimb and 0 < v.Y then
			v = Vector3.new(v.X, -2, v.Z)
		end
		bVelocity.Velocity = v
		local LeanAmount = -TurnSpeed * 0.3
		lean = CFrame.Angles(0, 0, LeanAmount)
		bGyro.CFrame = bGyro.CFrame * lean
	end

	function hoverModule:equip()
		local human = Utilities.getHumanoid()
		local isR15 = human.RigType == Enum.HumanoidRigType.R15

		if equipping or self.equipped or not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		local surf = _p.Surf
		if chunk.indoors or chunk.data.noHover or surf.surfing == true then return end

		self.equipped = true
		equipping = true

		human:ChangeState(Enum.HumanoidStateType.Physics)

		_p.RunningShoes:setRunning(false)

		local animator = human:FindFirstChild("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = human
		end

		for _, name in pairs(animations) do
			local animationId = _p.animationId[(isR15 and "R15_" or "") .. name]
			if type(animationId) == "number" then
				animationId = "rbxassetid://" .. animationId
			end
			animationTracks[name] = animator:LoadAnimation(create("Animation")({AnimationId = animationId}))
		end

		animationTracks.h_mount:Play()
		task.delay(.4, function() animationTracks.h_idle:Play(0) end)

		hoverboard = _p.Network:get('PDS', 'hover')
		if not self.equipped then -- was forced to unequip async
			pcall(function() hoverboard:Destroy() end)
			animationTracks.h_mount:Stop(0)
			animationTracks.h_idle:Stop(0)
			return
		end
		MaxSpeed = hoverboard.Name:sub(1,6)=='Basic ' and 36 or 40

		board = hoverboard.Main
		for _, ch in pairs(hoverboard:GetChildren()) do
			if ch:IsA('BasePart') then
				ch.CanCollide = true
			end
		end
		setup(board)

		CurrentSpeed = 0
		TurnSpeed = 0
		_p.MasterControl:Stop()
		_p.MasterControl:SetMoveFunc(control)
		workspace.CurrentCamera.CameraType = Enum.CameraType.Follow
		runService:BindToRenderStep(HOVER_CAM_STEP_ID, Enum.RenderPriority.Camera.Value+10, hoverCam)

		task.wait(1)
		if not self.equipped then -- was forced to unequip async
			pcall(function() hoverboard:Destroy() end)
			animationTracks.h_mount:Stop(0)
			animationTracks.h_idle:Stop(0)
			return
		end

		equipping = false
	end

	function hoverModule:SpinningRound()
		-- print('spin spin')
	end

	function hoverModule:unequip(force)
		if (equipping and not force) or not self.equipped then return end
		equipping = true
		self.equipped = false
		hillTimeLabel.Parent = nil
		hillStartTick = nil
		for _, anim in pairs(animationTracks) do
			anim:Stop()
		end
		task.delay(.5, function() animationTracks.h_idle:Stop() end)
		_p.Network:post('PDS', 'unhover')
		pcall(function() hoverboard:Destroy() end)
		hoverboard = nil
		pcall(function() Utilities.getHumanoid():ChangeState(Enum.HumanoidStateType.Freefall) end)
		_p.MasterControl:SetMoveFunc()
		if workspace.CurrentCamera.CameraType == Enum.CameraType.Follow then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end
		runService:UnbindFromRenderStep(HOVER_CAM_STEP_ID)

		equipping = false
	end

	game:GetService('UserInputService').InputBegan:connect(function(input, gpe)
		if not gpe and input.KeyCode == Enum.KeyCode.R then
			if not _p.PlayerData.completedEvents.hasHoverboard then return end
			if hoverModule.equipped then
				hoverModule:unequip()
			else
				hoverModule:equip()
			end
		elseif input.KeyCode == Enum.KeyCode.Space and hoverModule.equipped then
			_p.Network:post("PDS", "hoverboardAction")
		end
	end)
	return hoverModule
end
