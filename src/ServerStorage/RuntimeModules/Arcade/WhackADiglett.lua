return function(_p)
	local WhackADiglett = {}
	local map = _p.DataManager.currentChunk.map
	local WhackADiglettModel = map.WhackADiglett
	local UniqueMoles = WhackADiglettModel.UniqueMoles
	local commonDiglett = WhackADiglettModel.Common
	
	local gui = nil
	local Utilities = _p.Utilities
	local angle = 45
	local score = 0
	
	function WhackADiglett.appear(node, node2, node3)
		local rand = math.random(1, 9)
		node3 = node3 and math.random(1, 9)
		if gui.Nodes[node3]:FindFirstChild("Occupied") then
			return
		end
		local nodeLoc = (node2 or commonDiglett):Clone()
		nodeLoc.Parent = gui.frame
		local p = nodeLoc.p
		Utilities.MoveModel(p, gui.Nodes[node3].CFrame * CFrame.new(1, 0, 0))
		local valueB = Utilities.Create("NumberValue")({
			Name = "Occupied", 
			Value = 0, 
			Parent = gui.Nodes[node3]
		})
		local pCFrame = nodeLoc.p.CFrame
		Utilities.Tween(0.2, nil, function(x)
			Utilities.MoveModel(p, pCFrame * CFrame.new(-1.5 * x, 0, 0))
		end)
		local value = Instance.new("NumberValue")
		local value2 = 0
		if angle < 30 then
			value2 = 1
		end
		if angle < 15 then
			value2 = 2
		end
		value.Value = 3 - value2
		value.Parent = nodeLoc
		spawn(function()
			while true do
				task.wait()
				if value.Value == 0 then
					break
				end			
			end
			pCFrame = nodeLoc.p.CFrame
			Utilities.Tween(0.2, nil, function(x)
				Utilities.MoveModel(p, pCFrame * CFrame.new(1.5 * x, 0, 0))
			end)
			gui.Nodes[node3].Occupied:destroy()
			nodeLoc:Destroy()
		end)
		while true do
			wait(1)
			value.Value = value.Value - 1		
		end
	end
	
	local rareMoles = WhackADiglettModel.Rare
	local uMolesList = { UniqueMoles.Beard, UniqueMoles.BuilderDong, UniqueMoles.Girl, UniqueMoles.Landumb, UniqueMoles.Our_Negr0, UniqueMoles.Sparkle, UniqueMoles.TheBreadMan, UniqueMoles.TopHat, UniqueMoles.Watermelon, UniqueMoles.Zambie, UniqueMoles.Brew }
	
	function WhackADiglett.SpawnBunch(ab, r)
		r = r and 2
		for v11 = 1, r do
			spawn(function()
				local commonDigletts = commonDiglett
				if math.random(1, 40) == 1 then
					commonDigletts = rareMoles
				end
				if math.random(1, 10) == 1 then
					commonDigletts = uMolesList[math.random(1, #uMolesList)]
				end
				WhackADiglett:appear(commonDigletts, math.random(1, 9))
			end)
		end
	end
	
	function WhackADiglett.GetHammer(p9)
		local hammer = gui.frame.hammer:Clone()
		hammer.Parent = workspace
		local MousePlane = gui.MousePlane
		hammer.Size = Vector3.new(0.8, 2, 1.5)
		hammer.Mesh.Scale = Vector3.new(0.21, 0.21, 0.21)
		hammer.Position = MousePlane.Position
		local heartbeat = game:GetService("RunService").Heartbeat
		local mouseFinder = game.Players.LocalPlayer:GetMouse()
		local mousePos = MousePlane.Position.Y + 1.5
		local mouseFound = false
		local mouseFinderDisc = mouseFinder.Button1Down:Connect(function()
			if mouseFound then
				return
			end
			mouseFound = true
			Utilities.Tween(0.1, nil, function(c)
				hammer.Orientation = Vector3.new(0 + 90 * c, 90, 0)
			end)
			hammer.Anchored = false
			local toucher = hammer:GetTouchingParts()
			local allowed = false
			local list = nil
			list = hammer.Touched:Connect(function(pr)
				if pr.Name == "p" then
					if allowed then
						list:Disconnect()
					end
					if not allowed then
						allowed = true
						local part = Instance.new("Part")
						part.Transparency = 1
						part.Anchored = true
						part.CFrame = pr.CFrame
						part.Parent = gui
						part.Name = "BoomPart"
						local partAttachment = Instance.new("Attachment")
						partAttachment.Parent = part
						partAttachment.Position = Vector3.new(-0.7, 0, -0.15)
						delay(0.2, function()
							part:Destroy()
						end)
						pcall(function()
							pr.Parent.Value.Value = 0
						end)		
						if gui:FindFirstChild("Score") then
							if pr.Parent.Name == "Common" then
								gui.Score.Value = gui.Score.Value + 50
								return
							end
							if pr.Parent.Name == "Rare" then
								gui.Score.Value = gui.Score.Value + 500
								return
							end
							gui.Score.Value = gui.Score.Value + 100
						end
					end
				end
			end)
			delay(0.01, function()
				if not allowed then
					list:Disconnect()
				end
			end)
			Utilities.Tween(0.1, nil, function(a)
				hammer.Orientation = Vector3.new(90 - 90 * a, 90, 0)
			end)
			hammer.Anchored = true
			allowed = false
			mouseFound = false
		end)
		local connectingFunc = heartbeat:Connect(function()
			hammer.Orientation = Vector3.new(0, 90, 0)
			hammer.Position = Vector3.new(mouseFinder.Hit.X, mousePos, mouseFinder.Hit.Z)
		end)
		spawn(function()
			while task.wait() do
				if gui.Scoreboard.SurfaceGui:FindFirstChild("TimeCount") and gui.Scoreboard.SurfaceGui.TimeCount.Text == "00" then
					mouseFinderDisc:Disconnect()
					connectingFunc:Disconnect()
					hammer:Destroy()
					return
				end			
			end
		end)
	end
	
	local on = false
	function WhackADiglett.start(func, wh)
		gui = wh or map.WhackADiglett
		gui.frame.Barrier.CFrame = CFrame.new(0, 0, 0)
		angle = 45
		local SurfaceGui = gui.Scoreboard.SurfaceGui
		local label = Utilities.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.2, 0, 0.2, 0), 
			Position = UDim2.new(0.79, 0, 0, 0), 
			Text = "00000", 
			TextSize = 65, 
			Parent = SurfaceGui
		})
		local label2 = Utilities.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.2, 0, 0.2, 0), 
			Position = UDim2.new(0.57, 0, 0, 0), 
			Text = "Score", 
			TextSize = 65, 
			Parent = SurfaceGui
		})
		local label3 = Utilities.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.25, 0, 0.2, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "Time", 
			TextSize = 65, 
			Parent = SurfaceGui
		})
		local label4 = Utilities.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(1, 1, 1), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(0.15, 0, 0.2, 0), 
			Position = UDim2.new(0.2, 0, 0, 0), 
			Text = "45", 
			Name = "TimeCount", 
			TextSize = 65, 
			Parent = SurfaceGui
		})
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		local camCFrame = cam.CFrame
		local camCFrameF = gui.focal.CFrame * CFrame.new(0, -1.5, 7) * CFrame.Angles(math.rad(-15), math.rad(0), math.rad(0))
		Utilities.Tween(1, "easeInOutCubic", function(z)
			cam.CFrame = camCFrame:Lerp(camCFrameF, z)
		end)
		WhackADiglett:GetHammer()
		local ScoreValue = Instance.new("NumberValue")
		ScoreValue.Name = "Score"
		ScoreValue.Parent = gui
		local points = 0
		spawn(function()
			while ScoreValue.Parent do
				points = ScoreValue.Value
				task.wait()
				if points == 0 then
					label.Text = "0000" .. points
				end
				if points < 100 and points > 10 then
					label.Text = "000" .. points
				end
				if points >= 100 then
					label.Text = "00" .. points
				end
				if points >= 1000 then
					label.Text = "0" .. points
				end
				if points >= 10000 then
					label.Text = points
				end
				score = tonumber(points)
			end
		end)
		spawn(function()
			while not (angle <= 0) do
				WhackADiglett:SpawnBunch(math.random(2, 4))
				local calculate = 1
				if angle < 30 then
					calculate = 1.5
				end
				if angle < 15 then
					calculate = 2
				end
				wait(math.random(1, 2) / calculate)			
			end
		end)
		while true do
			on = false
			if angle == 0 then
				break
			end
			wait(1)
			angle = angle - 1
			label4.Text = angle
			if angle < 10 then
				label4.Text = "0" .. angle
			end		
		end
		local label5 = Utilities.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(0, 0, 0), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 0.65, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "Final Score", 
			TextSize = 100, 
			Parent = SurfaceGui
		})
		local label6 = Utilities.Create("TextLabel")({
			BackgroundTransparency = 1, 
			TextColor3 = Color3.new(0, 0, 0), 
			Font = Enum.Font.Arcade, 
			Size = UDim2.new(1, 0, 1, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Text = "00000", 
			TextSize = 100, 
			Parent = SurfaceGui
		})
		if points == 0 then
			label6.Text = "0000" .. points
		end
		if points < 100 and points > 10 then
			label6.Text = "000" .. points
		end
		if points >= 100 then
			label6.Text = "00" .. points
		end
		if points >= 1000 then
			label6.Text = "0" .. points
		end
		if points >= 10000 then
			label6.Text = points
		end
		wait(1.5)
		label5.Visible = false
		label6.Visible = false
		wait(0.5)
		label5.Visible = true
		label6.Visible = true
		wait(1.5)
		label5.Visible = false
		label6.Visible = false
		wait(0.5)
		label5.Visible = true
		label6.Visible = true
		wait(1.5)
		label5.Visible = false
		label6.Visible = false
		wait(0.5)
		label5.Visible = true
		label6.Visible = true
		wait(1.5)
		label6:destroy()
		label5:destroy()
		ScoreValue:Destroy()
		label4:destroy()
		label3:destroy()
		label2:destroy()
		label:destroy()
		Utilities.Tween(1, "easeInOutCubic", function(y)
			cam.CFrame = camCFrameF:Lerp(camCFrame, y)
		end)
		cam.CameraType = Enum.CameraType.Custom
		gui.frame.Barrier.CFrame = gui.frame.Barrier.CFrame
		points = 0
		_p.Network:get("PDS", "ArcadeReward", "whack", score)
	end
	
	return WhackADiglett
end
