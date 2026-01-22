return function(_p)
	local HammerArm = {}
	local Utilities = _p.Utilities
	local score = 0
	local map = _p.DataManager.currentChunk.map
	local SmonksModel = map.Smonkaroons
	local Smonkaroons = nil
	local points = 0

	function HammerArm.randomizeGradient(grade)
		local randNum = Random.new():NextNumber(-0.5, 0.5)
		SmonksModel.Board.SurfaceGui.BackgroundContainer.Gradient.Position = UDim2.new(0, 0, randNum, 0)
	end

	function HammerArm.floatingText(a, frame, cframe)
		local instancePart = Instance.new("Part")
		instancePart.Name = "Floating"
		instancePart.Anchored = true
		instancePart.CanCollide = false
		instancePart.Transparency = 1
		instancePart.Parent = workspace
		instancePart.Size = Vector3.new(0.876, 0.715, 0.001)
		local billGUI = Instance.new("BillboardGui")
		billGUI.Parent = instancePart
		billGUI.LightInfluence = 0
		billGUI.Size = UDim2.new(2, 0, 2, 0)
		local label = Utilities.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "+" .. frame, 
			TextSize = 28, 
			Name = "NewScore", 
			BackgroundTransparency = 1, 
			Parent = billGUI
		})
		instancePart.CFrame = cframe
		local instancePartCFrame = instancePart.CFrame
		Utilities.Tween(1.5, "easeOutCubic", function(y)
			instancePart.CFrame = instancePartCFrame * CFrame.new(0, 0.5 * y, 0)
		end)
		instancePart:Destroy()
	end

	function HammerArm.start(mod1, par)
		Smonkaroons = par or map.Smonkaroons
		SmonksModel = Smonkaroons
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		local camCFrame = cam.CFrame
		local SmonksTargetFrame = SmonksModel.Target.CFrame * CFrame.new(5, 5.5, -8) * CFrame.Angles(math.rad(0), math.rad(150), 0)
		Utilities.Tween(1, "easeInOutCubic", function(a)
			cam.CFrame = camCFrame:Lerp(SmonksTargetFrame, a)
		end)
		SmonksModel.Board.SurfaceGui.Enabled = true
		local textLabel = Utilities.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "000", 
			TextSize = 28, 
			Name = "Score", 
			BackgroundTransparency = 1, 
			Parent = SmonksModel.Board.SurfaceGui.ScoreContainer
		})
		HammerArm:GetArrow()
		wait(1.8)
		HammerArm:GetArrow()
		wait(1.8)
		HammerArm:GetArrow()
		wait(1.8)
		textLabel.Visible = false
		wait(0.5)
		textLabel.Visible = true
		wait(1.5)
		textLabel.Visible = false
		wait(0.5)
		textLabel.Visible = true
		wait(1.5)
		textLabel.Visible = false
		wait(0.5)
		textLabel.Visible = true
		wait(1.5)
		points = 0
		SmonksModel.Board.SurfaceGui.ScoreContainer.Score:destroy()
		SmonksModel.Board.SurfaceGui.Enabled = false
		SmonksModel.hammer:destroy()
		Utilities.Tween(1, "easeInOutCubic", function(y)
			cam.CFrame = SmonksTargetFrame:Lerp(camCFrame, y)
		end)
		cam.CameraType = Enum.CameraType.Custom
		print(score)
		_p.Network:get("PDS", "ArcadeReward", "hammer", score)
	end

	function HammerArm.GetArrow(p11)
		if SmonksModel:FindFirstChild("hammer") then
			SmonksModel.hammer:destroy()
		end
		local Smonks = map.WhackADiglett.frame.hammer:Clone()
		Smonks.Parent = SmonksModel
		Smonks.CFrame = SmonksModel.Target.CFrame * CFrame.new(0, 4, -2)
		Smonks.Mesh.Scale = Vector3.new(0.4, 0.4, 0.4)
		local Arrow = SmonksModel.Board.SurfaceGui.Arrow
		local mouseLoc = game.Players.LocalPlayer:GetMouse()
		local gradient = Instance.new("NumberValue")
		gradient.Parent = workspace
		Arrow.Position = UDim2.new(0, 0, 0, 0)
		HammerArm:randomizeGradient()
		local mouseOn = nil
		local area = false

		local function targetValues(meth)
			return math.floor(meth + 0.5)
		end
		local GradientValues = 0
		mouseOn = mouseLoc.Button1Down:Connect(function()
			mouseOn:disconnect()
			local MTargetCFrame = SmonksModel.Target.CFrame * CFrame.new(0, 4, -2)
			local SmonksCFrame = Smonks.CFrame
			Utilities.Tween(0.15, nil, function(x)
				Smonks.CFrame = SmonksCFrame * CFrame.new(0, -2 * x, 1 * x) * CFrame.Angles(math.rad(90 * x), 0, 0)
			end)
			area = true
			spawn(function()
				local sound2 = Utilities.Create("Sound")({
					Parent = SmonksModel.Target, 
					TimePosition = 0, 
					Volume = 0.8, 
					SoundId = "rbxassetid://138285836", 
					PlaybackSpeed = 0.9, 
					Playing = true
				})
				sound2.Ended:Connect(function()
					sound2:destroy()
				end)
			end)
			SmonksCFrame = Smonks.CFrame
			spawn(function()
				Utilities.Tween(0.15, nil, function(a)
					Smonks.CFrame = SmonksCFrame:Lerp(MTargetCFrame, a)
				end)
			end)
			if gradient.Value > 4.8 and gradient.Value < 5.1 then
				HammerArm:hitTarget(100)
			end
			if gradient.Value > 5.2 then
				HammerArm:hitTarget(targetValues(GradientValues * 10 * 2))
			end
			if gradient.Value < 4.8 then
				HammerArm:hitTarget(targetValues(GradientValues * 10 * 2))
			end
		end)
		local ColorValues = SmonksModel.Board.SurfaceGui.BackgroundContainer.Gradient
		spawn(function()
			while true do
				task.wait()
				if area then
					break
				end
				gradient.Value = (ColorValues.AbsolutePosition - Arrow.AbsolutePosition).Magnitude / 24.5
				if gradient.Value > 4.8 and gradient.Value < 5.2 then
					GradientValues = 5
				end
				if gradient.Value > 5.25 then
					if gradient.Value > 5.27 and gradient.Value < 6 then
						GradientValues = 4.5
					end
					if gradient.Value > 6.1 and gradient.Value < 6.5 then
						GradientValues = 4
					end
					if gradient.Value > 6.5 and gradient.Value < 7 then
						GradientValues = 3.5
					end
					if gradient.Value > 7.1 and gradient.Value < 7.5 then
						GradientValues = 3
					end
					if gradient.Value > 7.6 and gradient.Value < 8 then
						GradientValues = 2.5
					end
					if gradient.Value > 8.1 and gradient.Value < 8.5 then
						GradientValues = 2
					end
					if gradient.Value > 8.6 and gradient.Value < 9 then
						GradientValues = 1.5
					end
					if gradient.Value > 9.5 and gradient.Value < 10 then
						GradientValues = 1
					end
				elseif gradient.Value < 4.8 then
					GradientValues = (ColorValues.AbsolutePosition - Arrow.AbsolutePosition).Magnitude / 24.5
				end			
			end
		end)
		while not area do
			task.wait()
			Utilities.Tween(0.35, nil, function(p15)
				if area then
					return false
				end
				Arrow.Position = UDim2.new(0.4, 0, 0 + 0.9 * p15)
			end)
			Utilities.Tween(0.35, nil, function(p16)
				if area then
					return false
				end
				Arrow.Position = UDim2.new(0.4, 0, 0.9 - 0.9 * p16)
			end)		
		end
	end

	function HammerArm.hitTarget(r, z)
		z = z 
		local FirstGreen = SmonksModel.FirstGreen:Clone()
		local SecondGreen = SmonksModel.SecondGreen:Clone()
		FirstGreen.Parent = SmonksModel.Frame
		SecondGreen.Parent = SmonksModel.Frame
		local FirstGreenSize = FirstGreen.Size
		local SecondGreenSize = SecondGreen.Size
		local FirstGreenCFrame = FirstGreen.CFrame
		Utilities.Tween(0.2, nil, function(a)
			FirstGreen.Size = Vector3.new(0.21, 0.21, 0.21 + 6.1 * a)
			FirstGreen.CFrame = FirstGreenCFrame * CFrame.new(0, 0, 3.05 * a)
		end)
		spawn(function()
			for _, v in pairs(SmonksModel.Lights:GetDescendants()) do
				if v:IsA("BasePart") then
					spawn(function()
						while FirstGreen.Parent and SecondGreen.Parent do
							task.wait()
							if v.CFrame.Y < SecondGreen.CFrame.Y + z / 16 then
								v.Material = Enum.Material.Neon
							else
								v.Material = Enum.Material.SmoothPlastic
							end						
						end
					end)
				end
			end
		end)
		local SecondGreenCFrame = SecondGreen.CFrame
		Utilities.Tween(0.7, "easeOutCubic", function(b)
			SecondGreen.Size = Vector3.new(0.22, 0.22 + z / 7.5 * b, 0.22)
			SecondGreen.CFrame = SecondGreenCFrame * CFrame.new(0, 0 + z / 16 * b, 0)
		end)
		if z == 100 then
			local sound1 = Utilities.Create("Sound")({
				Parent = SmonksModel.Bell, 
				TimePosition = 0.3, 
				Volume = 1, 
				SoundId = "rbxassetid://6150774030", 
				PlaybackSpeed = 0.3, 
				Playing = true
			})
			sound1.Ended:Connect(function()
				sound1:destroy()
			end)
		end
		points = points + z
		if points == 0 then
			SmonksModel.Board.SurfaceGui.ScoreContainer.Score.Text = "00" .. points
		end
		if points >= 10 then
			SmonksModel.Board.SurfaceGui.ScoreContainer.Score.Text = "0" .. points
		end
		if points >= 100 then
			SmonksModel.Board.SurfaceGui.ScoreContainer.Score.Text = points
		end
		score = tonumber(points)
		FirstGreenCFrame = FirstGreen.CFrame
		SecondGreenCFrame = SecondGreen.CFrame
		spawn(function()
			HammerArm:floatingText(z, SecondGreenCFrame * CFrame.new(2, z / 16, 0))
		end)
		Utilities.Tween(0.7, "easeInCubic", function(y)
			SecondGreen.CFrame = SecondGreenCFrame * CFrame.new(0, 0 - z / 7 * y, 0)
		end)
		local FireGreenZ = FirstGreen.Size.Z
		Utilities.Tween(0.2, nil, function(d)
			FirstGreen.Size = Vector3.new(0.21, 0.21, FireGreenZ - 6.1 * d)
			FirstGreen.CFrame = FirstGreenCFrame * CFrame.new(0, 0, -3.05 * d)
		end)
		FirstGreen:Destroy()
		SecondGreen:Destroy()
	end
	return HammerArm
end
