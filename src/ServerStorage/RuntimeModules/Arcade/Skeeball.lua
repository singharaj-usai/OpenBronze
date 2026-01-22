return function(_p)
	local Skeeball = {}
	local Utilities = _p.Utilities
	local map = _p.DataManager.currentChunk.map
	
	local gui = nil	
	local score = 0
	local hole1 = 8
	local hole2 = 0
	local hole3 = 0
	local hole4 = 0
	local balls = nil
	
	function Skeeball.End(machine)
		hole1 = 8
		hole2 = 0
		hole3 = 0
		hole4 = 0
		balls.BallFolder:destroy()
		local cam = workspace.CurrentCamera
		local scoreBoard = balls.Scoreboard.SurfaceGui.Container.Score
		local ScoreLabel = balls.Scoreboard.SurfaceGui.Container.ScoreLabel
		ScoreLabel.Visible = false
		scoreBoard.Visible = false
		wait(0.5)
		ScoreLabel.Visible = true
		scoreBoard.Visible = true
		wait(1.5)
		ScoreLabel.Visible = false
		scoreBoard.Visible = false
		wait(0.5)
		ScoreLabel.Visible = true
		scoreBoard.Visible = true
		wait(1.5)
		ScoreLabel.Visible = false
		scoreBoard.Visible = false
		wait(0.5)
		ScoreLabel.Visible = true
		scoreBoard.Visible = true
		wait(1.5)
		balls.Scoreboard.SurfaceGui.Container.Score:destroy()
		balls.Scoreboard.SurfaceGui.Container.ScoreLabel:destroy()
		local cframe2 = cam.CFrame
		Utilities.Tween(1, "easeInOutCubic", function(v)
			cam.CFrame = cframe2:Lerp(gui, v)
		end)
		cam.CameraType = Enum.CameraType.Custom
		machine.GameEnded:fire()
		print(score)
		_p.Network:get("PDS", "ArcadeReward", "skeeball", score)
	end

	function Skeeball.start(skee, ball)
		balls = ball or map.Skeeball
		balls.PlayerCollider.CanCollide = false
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		gui = cam.CFrame
		local ballCFrame = balls.Focal.CFrame * CFrame.new(0, -1.5, 20.8) * CFrame.Angles(math.rad(-13), math.rad(-0.5), 0)
		Utilities.Tween(1, "easeInOutCubic", function(v)
			cam.CFrame = gui:Lerp(ballCFrame, v)
		end)
		local label = Utilities.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.35, 0, 1, 0), 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Text = "0000", 
			TextSize = 90, 
			Name = "Score", 
			BackgroundTransparency = 1, 
			Parent = balls.Scoreboard.SurfaceGui.Container
		})
		local label2 = Utilities.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.65, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "Score", 
			TextSize = 90, 
			Name = "ScoreLabel", 
			BackgroundTransparency = 1, 
			Parent = balls.Scoreboard.SurfaceGui.Container
		})
		local ballFolder = Utilities.Create("Folder")({
			Name = "BallFolder", 
			Parent = balls
		})
		while hole2 ~= hole1 - 1 do
			hole2 = hole2 + 1
			wait(0.2)
			local extraBalls = balls.ExtraBalls:Clone()
			extraBalls.Name = "Ball" .. hole2
			extraBalls.Parent = ballFolder
			local specialM = Utilities.Create("SpecialMesh")({
				TextureId = "rbxassetid://433357907", 
				Scale = Vector3.new(0.15, 0.15, 0.15), 
				MeshId = "rbxassetid://433357903", 
				Parent = extraBalls
			})
			extraBalls.CFrame = balls.ExtraBalls.CFrame
			extraBalls.CanCollide = true
			extraBalls.Transparency = 0
			extraBalls.Anchored = false		
		end
		wait(0.5)
		spawn(function()
			Skeeball:rollBall()
		end)
	end
	function Skeeball.floatingText(part1, textinfo, text)
		local FloatingPart = Instance.new("Part")
		FloatingPart.Name = "Floating"
		FloatingPart.Anchored = true
		FloatingPart.CanCollide = false
		FloatingPart.Transparency = 1
		FloatingPart.Parent = workspace
		FloatingPart.Size = Vector3.new(0.876, 0.715, 0.001)
		local floatingGUI = Instance.new("BillboardGui")
		floatingGUI.Parent = FloatingPart
		floatingGUI.LightInfluence = 0
		floatingGUI.Size = UDim2.new(2, 0, 2, 0)
		local label3 = Utilities.Create("TextLabel")({
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "+" .. textinfo, 
			TextSize = 28, 
			Name = "NewScore", 
			BackgroundTransparency = 1, 
			Parent = floatingGUI
		})
		FloatingPart.Position = text
		local cframe = FloatingPart.CFrame
		Utilities.Tween(1.5, "easeOutCubic", function(p10)
			FloatingPart.CFrame = cframe * CFrame.new(0, 0.5 * p10, 0)
		end)
		FloatingPart:Destroy()
	end
	function Skeeball.rollBall(rolling)
		local mouseFunc = game.Players.LocalPlayer:GetMouse()
		local rolledBall = nil
		if hole1 == 8 then
			rolledBall = balls.ExtraBalls:Clone()
			rolledBall.Name = "Ball" .. hole2
			rolledBall.Parent = balls
			local v17 = Utilities.Create("SpecialMesh")({
				TextureId = "rbxassetid://433357907", 
				Scale = Vector3.new(0.15, 0.15, 0.15), 
				MeshId = "rbxassetid://433357903", 
				Parent = rolledBall
			})
			rolledBall.CFrame = balls.ballstart.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(0, math.rad(180), math.rad(0))
			rolledBall.CanCollide = true
			rolledBall.Transparency = 0
			rolledBall.Anchored = true
		elseif hole1 < 8 and hole1 > 0 then
			if balls:FindFirstChild("BallFolder") then
				rolledBall = balls.BallFolder["Ball" .. hole3]
				rolledBall.Parent = balls
				rolledBall.Anchored = true
				rolledBall.CFrame = balls.ballstart.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(0), math.rad(180), math.rad(0))
			end
		elseif hole1 == 0 then
			Skeeball:End()
			return
		end
		hole1 = hole1 - 1
		hole3 = hole3 + 1
		local PartParent = Utilities.Create("Part")({
			Name = "Arrow", 
			Parent = balls, 
			Size = Vector3.new(0, 0, 0), 
			Anchored = true, 
			CanCollide = false, 
			CanTouch = false, 
			Transparency = 1
		})
		local decal = Utilities.Create("Decal")({
			Texture = "rbxassetid://134915318", 
			Color3 = Color3.fromRGB(255, 217, 0), 
			Face = "Top", 
			Parent = PartParent
		})
		local hole11 = 0
		local hole12 = false
		local startCFrame = balls.ballstart.CFrame
		local hole14 = nil
		local hole15 = game:GetService("RunService").Heartbeat:Connect(function()
			if PartParent.Parent then
				PartParent.CFrame = rolledBall.CFrame * CFrame.new(0, 0.8, 0) * CFrame.Angles(0, math.rad(180), 0)
				PartParent.Size = Vector3.new(1, 0, hole11)
			end
			if not hole12 then
				if startCFrame.Position.Z + 2.65 < mouseFunc.Hit.Position.Z then
					return
				end
				if mouseFunc.Hit.Position.Z < startCFrame.Position.Z + -2.65 then
					return
				end
				rolledBall.Position = Vector3.new(rolledBall.Position.X, rolledBall.Position.Y, mouseFunc.Hit.Position.Z)
			end
			if hole12 then
				if startCFrame.Position.Z + 3.5 < mouseFunc.Hit.Position.Z then
					return
				end
				if mouseFunc.Hit.Position.Z < startCFrame.Position.Z + -3.5 then
					return
				end
				local a, b, c = CFrame.new(rolledBall.CFrame.p, mouseFunc.Hit.p):ToOrientation()
				local d, e, f = rolledBall.CFrame:ToOrientation()
				rolledBall.CFrame = CFrame.new(rolledBall.CFrame.p) * CFrame.fromOrientation(d, -b, c)
				hole11 = (mouseFunc.Hit.Position - rolledBall.Position).Magnitude
				if hole11 > 3.5 then
					hole11 = 3.5
				end
			end
		end)
		hole14 = mouseFunc.Button1Down:Connect(function()
			hole12 = true
			hole14:Disconnect()
			local hole16 = nil
			hole16 = mouseFunc.Button1Up:Connect(function()
				hole15:Disconnect()
				hole12 = false
				PartParent:destroy()
				rolledBall.Anchored = false
				hole16:disconnect()
				local v26 = -(mouseFunc.Hit.Position - rolledBall.Position).Magnitude
				rolledBall.Velocity = rolledBall.CFrame.LookVector * hole11 * 30
				wait(3)
				rolledBall.Anchored = true
				wait(1)
				if rolledBall.Parent then
					rolledBall:Destroy()
					if hole3 <= 8 then
						Skeeball:rollBall()
					end
				end
			end)
		end)
		local hole17 = nil
		hole17 = rolledBall.Touched:Connect(function(holes)
			if holes.Parent.Name == "Holes" then
				hole17:Disconnect()
				hole4 = hole4 + holes.Name
				if hole4 == 0 then
					balls.Scoreboard.SurfaceGui.Container.Score.Text = "000" .. hole4
				end
				if hole4 >= 10 then
					balls.Scoreboard.SurfaceGui.Container.Score.Text = "00" .. hole4
				end
				if hole4 >= 100 then
					balls.Scoreboard.SurfaceGui.Container.Score.Text = "0" .. hole4
				end
				if hole4 >= 1000 then
					balls.Scoreboard.SurfaceGui.Container.Score.Text = hole4
				end
				score = tonumber(hole4)
				Skeeball:floatingText(holes.Name, rolledBall.Position + Vector3.new(0, 1.5, 0))
				rolledBall:Destroy()
				if hole3 <= 8 then
					Skeeball:rollBall()
				end
			end
		end)
	end
	Skeeball.GameEnded = Utilities.Signal()
	return Skeeball
end
