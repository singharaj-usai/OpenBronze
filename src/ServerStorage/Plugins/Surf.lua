return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local surf = {surfing = false}
	local function makePhysics(part)
		return create("BodyPosition")({
			Position = part.Position,
			MaxForce = Vector3.new(math.huge, math.huge, math.huge),
			Parent = part
		}), create("BodyGyro")({
			CFrame = CFrame.new(),
			MaxTorque = Vector3.new(9000000, 10000, 9000000),
			Parent = part
		})
	end
	local getSurfWalls = function(map)
		local walls = {}
		while true do
			local wall = map:FindFirstChild("SurfWall", true) or map:FindFirstChild("NotSurfWall", true)
			if not wall then
				break
			end
			walls[#walls + 1] = wall
			wall.Parent = nil
		end
		return walls
	end
	local function surfInternal(part, bp, bg, root, yOffset, surfWalls)
		bp.MaxForce = Vector3.new(0, math.huge, 0)
		local bv = create("BodyVelocity")({
			MaxForce = Vector3.new(15000, 0, 15000),
			Velocity = Vector3.new(0, 0, 0),
			P = 800,
			Parent = part
		})
		function surf.invalidateSurfWalls()
			surfWalls = nil
		end
		local cam = workspace.CurrentCamera
		local MasterControl = _p.MasterControl
		MasterControl:SetMoveFunc(function(_, dir, relativeToCam)
			if relativeToCam then
				local lv = cam.CFrame.lookVector
				local cf = CFrame.new(Vector3.new(), Vector3.new(lv.X, 0, -lv.Z))
				dir = -cf:pointToObjectSpace(dir)
			end
			if dir.magnitude > 1 then
				dir = dir.unit
			end
			bv.Velocity = dir * 30
			if dir.magnitude > 0.1 then
				bg.CFrame = CFrame.new(Vector3.new(), dir)
			else
				bg.CFrame = part.CFrame
			end
		end)
		local touchingWall, touchingThread
		part.Touched:connect(function(obj)
			if obj.Name ~= "SurfWall" then
				return
			end
			touchingWall = obj
			local thisThread = {}
			touchingThread = thisThread
			while touchingWall == obj and touchingThread == thisThread do
				do
					print('touching wall')
					local pp = root.Position
					local dp = obj.CFrame:pointToObjectSpace(pp)
					if MasterControl.WalkEnabled and math.abs(dp.X) < obj.Size.X / 2 - 2 and math.deg(math.acos(part.CFrame.lookVector:Dot(obj.CFrame.lookVector))) < 30 then
						MasterControl:SetMoveFunc()
						MasterControl.WalkEnabled = false
						MasterControl:Stop()
						do
							local lcf = obj.CFrame * CFrame.new(dp.X, 0, -4)
							local characters = {}
							for _, ch in pairs(game:GetService("Players"):GetChildren()) do
								pcall(function()
									characters[#characters + 1] = ch.Character
								end)
							end
							local _, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(lcf.p, Vector3.new(0, -obj.Size.Y, 0)), characters)
							lcf = lcf + Vector3.new(0, pos.Y - lcf.y + yOffset, 0)
							local map = _p.DataManager.currentChunk.map
							if not surfWalls then
								surfWalls = getSurfWalls(map)
							end
							for _, wall in pairs(surfWalls) do
								wall.Parent = nil
							end
							local dif = lcf.p - pp
							local lv = dif * Vector3.new(1, 0, 1).unit
							print('unsurfing')
							_p.Network:post("PDS", "unsurf")
							pcall(function()
								print('removeing')
								--w:remove()
								part:remove()
							end)
							surf.surfAnim:Stop(0.5)
							Utilities.Tween(0.5, nil, function(a)
								local pos = pp + dif * a + Vector3.new(0, 4 * math.sin(a * math.pi), 0)
								root.CFrame = CFrame.new(pos, pos + lv)
							end)
							surf.surfing = false
							for _, wall in pairs(surfWalls) do
								wall.Parent = map
							end
							surf.invalidateSurfWalls = nil
							pcall(function()
								Utilities.getHumanoid():ChangeState(Enum.HumanoidStateType.Freefall)
							end)
							_p.MasterControl.WalkEnabled = true
							break
						end
					end
					wait(0.15)
				end
			end
		end)
		part.TouchEnded:connect(function(obj)
			if touchingWall == obj then
				touchingWall = nil
			end
		end)
	end

	function surf:surf(cf, surfWallCFrame, waterHeight)
		if self.surfing then
			return
		end
		self.surfing = true
		local root = _p.player.Character.HumanoidRootPart
		local pp = root.Position
		local part, weld, bp, bg
		local ppt = surfWallCFrame:pointToObjectSpace(pp)
		local cf = surfWallCFrame * CFrame.new(ppt.X + 2, 5, 4) * CFrame.Angles(0, math.pi, 0)
		cf = cf + Vector3.new(0, waterHeight - cf.y - .1 , 0)
		spawn(function()
			part, weld = _p.Network:get("PDS", "surf")
			part.CFrame = cf
			bp, bg = makePhysics(part)

		end)
		--	_p.NPCChat:say(surfUser .. " used Surf!")
		while not part do
			wait()
		end
		self.surfPart = part
		part.Archivable = false
		--		local ppt = surfWallCFrame:pointToObjectSpace(pp)
		--		local cf = surfWallCFrame * CFrame.new(ppt.X, 0, 4) * CFrame.Angles(0, math.pi, 0)
		--		cf = cf + Vector3.new(0, waterHeight - cf.y - 1.34, 0)
		part.CFrame = cf
		bp.Position = cf.p
		bg.CFrame = cf
		local human = Utilities.getHumanoid()
		human:ChangeState(Enum.HumanoidStateType.Physics)
		local isR15 = human.RigType == Enum.HumanoidRigType.R15
		local hipHeight = isR15 and human.HipHeight + root.Size.Y / 2 or 3
		local map = _p.DataManager.currentChunk.map
		local surfWalls = getSurfWalls(map)
		local dif = cf:vectorToObjectSpace(cf.p - pp)
		local offset = Vector3.new(0, 1 + hipHeight, 0)
		weld.C0 = CFrame.new()
		weld.Part1 = root
		local anim = human:LoadAnimation(create("Animation")({
			AnimationId = "rbxassetid://" .. _p.Assets.animationId[(isR15 and "R15_" or "") .. "Surf"]
		}))
		anim:Play(0.5)
		self.surfAnim = anim
		Utilities.Tween(0.5, nil, function(a)
			weld.C1 = CFrame.new(dif * (1 - a) - offset + Vector3.new(0, -4 * math.sin(a * math.pi), 0))
		end)
		--	_p.Network:post("PDS", "fixSurf")
		for _, wall in pairs(surfWalls) do
			wall.Parent = map
		end
		wait()
		surfInternal(part, bp, bg, root, offset.Y, surfWalls)
	end


	function surf:forceSurf(cf, waterHeight)
		print('called surf:forceSurf')
		self.surfing = true

		local waterHeight 
		if _p.DataManager.currentChunk.map:FindFirstChild("Water") then
			waterHeight = _p.DataManager.currentChunk.map:FindFirstChild("Water").CFrame.Y
			--map.Water.Position.Y
			cf = cf + Vector3.new(0, waterHeight - cf.y - .1 , 0)
			local root
			while true do
				pcall(function()
					root = _p.player.Character.HumanoidRootPart
				end)
				if root then
					break
				end
				wait()
			end
			local part, weld = _p.Network:get("PDS", "surf", true)
			part.CFrame = cf
			part.Archivable = false
			local bp, bg = makePhysics(part)
			bp.Position = cf.p
			bg.CFrame = cf
			self.surfPart = part
			local human = Utilities.getHumanoid()
			human:ChangeState(Enum.HumanoidStateType.Physics)
			local isR15 = human.RigType == Enum.HumanoidRigType.R15
			local yOffset = 2 + (isR15 and human.HipHeight + root.Size.Y / 2 or 3)
			local anim = human:LoadAnimation(create("Animation")({
				AnimationId = "rbxassetid://" .. _p.Assets.animationId[(isR15 and "R15_" or "") .. "Surf"]
			}))
			anim:Play(0)
			self.surfAnim = anim
			wait()
			surfInternal(part, bp, bg, root, yOffset, nil)
		end

			--[[
		local root = _p.player.Character.HumanoidRootPart
		local pp = root.Position
		local part, weld, bp, bg
		--	cf.Y = CFrame.new(0, waterHeight, 0)
			cf = cf + Vector3.new(0, waterHeight - cf.y - .1 , 0)
		--	cf = cf + Vector3.new(0, v.Position.Y - cf.y - .1 , 0) -- 
		
		spawn(function()
			part, weld = _p.Network:get("PDS", "surf")
			part.CFrame = cf
			bp, bg = makePhysics(part)

		end)
		--	_p.NPCChat:say(surfUser .. " used Surf!")
	--	while not part do
	--		wait()
	--	end
	--	part.CFrame = cf
	--	part.Archivable = false
	--	local bp, bg = makePhysics(part)
		bp.Position = cf.p
	--	bg.CFrame = cf
		self.surfPart = part
		local human = Utilities.getHumanoid()
		human:ChangeState(Enum.HumanoidStateType.Physics)
	--	Utilities.Teleport(part.CFrame * CFrame.new(0, 0, 0))
		local isR15 = human.RigType == Enum.HumanoidRigType.R15
		local yOffset = 2 + (isR15 and human.HipHeight + root.Size.Y / 2 or 3)
		local anim = human:LoadAnimation(create("Animation")({
			AnimationId = "rbxassetid://" .. _p.animationId[(isR15 and "R15_" or "") .. "Surf"]
		}))

		print('2')
		anim:Play(0.4)
		self.surfAnim = anim
		wait()
		print('surfInternal')
		surfInternal(part, bp, bg, root, yOffset, nil)
		end
		--]]
	end



	function surf:forceUnsurf()
		_p.Network:post("PDS", "unsurf")
		pcall(function()
			self.surfPart:remove()
		end)
		pcall(function()
			Utilities.getHumanoid():ChangeState(Enum.HumanoidStateType.Freefall)
		end)
		_p.MasterControl:SetMoveFunc()
		pcall(function()
			self.surfAnim:Stop(0)
		end)
		self.surfing = false
	end


	function surf:beforeFishing()
		self.surfAnim:Stop(0.3)
		wait(0.3)
	end


	function surf:afterFishing()
		self.surfAnim:Play(0.3)
		wait(0.3)
	end

	return surf
end
