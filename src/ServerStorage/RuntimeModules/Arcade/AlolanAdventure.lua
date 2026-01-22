return function(_p)
	local AlolanAdventure = {}
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RenderStepped = game:GetService("RunService").Stepped
	local InputService = game:GetService("UserInputService")
	local Utilities = _p.Utilities
	
	local Tween = Utilities.Tween
	local MasterControl = _p.MasterControl
	local create = Utilities.Create
	local bg1 = nil
	local bg2 = nil
	local bg3 = nil
	local gui2 = nil
	
	
	function AlolanAdventure.animFlap(machine)
		if machine.ended then
			return
		end
		machine.currentFlap = (machine.currentFlap + 1 + 1) % 3 * 64
		machine.bird.ImageRectOffset = Vector2.new(machine.currentFlap, 0)
	end

	function AlolanAdventure.getBird(machine)
		if machine.bird then
			return machine.bird
		end
		machine.currentFlap = 0
		machine.bird = create("ImageLabel")({
			Name = "Bird", 
			Parent = bg1, 
			Image = "rbxassetid://785167181", 
			BackgroundTransparency = 1, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			Position = UDim2.new(0, bg2, 0, bg3.y), 
			Size = UDim2.new(0, 42.666666666666664, 0, 42.666666666666664), 
			ImageRectOffset = Vector2.new(8, 9), 
			ImageRectSize = Vector2.new(58, 58), 
			LayoutOrder = 2, 
			ZIndex = 999
		})
		spawn(function()
			while wait(0.15) do
				machine:animFlap()			
			end
		end)
		return machine.bird
	end
	
	local function pos(machine, name)
		local AbsolutePosition = machine.AbsolutePosition
		local AbsoluteSize = AbsolutePosition + machine.AbsoluteSize
		local AbsoluteView = name.AbsolutePosition
		local AbsoluteAngle = AbsoluteView + name.AbsoluteSize
		local saw = false
		if AbsolutePosition.x < AbsoluteAngle.x then
			saw = false
			if AbsoluteView.x < AbsoluteSize.x then
				saw = false
				if AbsolutePosition.y < AbsoluteAngle.y then
					saw = AbsoluteView.y < AbsoluteSize.y
				end
			end
		end
		return saw
	end
	
	local tickCounter = tick()
	local speed = {
		velocity = {
			x = 0, 
			y = 0
		}
	}
	local gravity = {
		GRAVITY = -0.6867000000000001, 
		time = 0
	}
	
	function AlolanAdventure.step(machine, gui)
		if pos(machine.bird, bg1.Floor) then
			if not machine.ended then
				AlolanAdventure:die()
			end
			return
		end
		local v11 = tick() - tickCounter
		speed.velocity.y = speed.velocity.y + gravity.GRAVITY
		gui.Position = UDim2.new(0, gui.Position.X.Offset, 0, gui.Position.Y.Offset - speed.velocity.y)
		gui.Rotation = -math.deg(math.atan2(math.rad(speed.velocity.y), 1)) * 5
	end
	
	function AlolanAdventure.onSpaceClicked(machine)
		if machine.ended then
			return
		end
		if not machine.started then
			machine.started = true
		end
		speed.velocity.y = 9
	end
	
	function AlolanAdventure.die(machine)
		if not machine.ended then
			_p.Network:get("PDS", "ArcadeReward", "alolan", machine.points)
			_p.PlayerData.money = _p.PlayerData.money + machine.points
			_p.PlayerData.money = _p.PlayerData.money + machine.points
			machine.ended = true
			local color = gui2.Color
			Tween(0.1, nil, function(a)
				gui2.Color = color:Lerp(Color3.new(1, 1, 1), a)
			end)
			Tween(0.1, nil, function(b)
				gui2.Color = Color3.new(1, 1, 1):Lerp(color, b)
			end)
			for i = 1, 3 do
				bg1.points.Visible = false
				wait(0.3)
				bg1.points.Visible = true
				wait(1.5)
			end
			bg1.points.Visible = false
			gui2.Transparency = 1
			gui2.Color = Color3.fromRGB(27, 42, 53)
			Utilities.lookBackAtMe()
			bg1:destroy()
			MasterControl.WalkEnabled = true
			_p.Menu:enable()
			machine.GameEnded:fire()
		end
	end
	function AlolanAdventure.boundaryCheck(a, b, c)
		local AbsolutePosition = b.AbsolutePosition
		local AbsoluteSize = b.AbsoluteSize
		local AbsoluteAngle = c.AbsolutePosition
		local AbsoluteView = c.AbsoluteSize
		if AbsoluteAngle.Y - AbsolutePosition.Y > 0 then
			return false
		end
		if AbsoluteAngle.Y + AbsoluteView.Y - (AbsolutePosition.Y + AbsoluteSize.Y) < 0 then
			return false
		end
		if AbsoluteAngle.X - AbsolutePosition.X > 0 then
			return false
		end
		if AbsoluteAngle.X + AbsoluteView.X - (AbsolutePosition.X + AbsoluteSize.X) < 0 then
			return false
		end
		return true
	end
	function AlolanAdventure.spawnPipe(machine, screen)
		local TreeBottom = bg1:FindFirstChild("TreeBottom"):Clone()
		TreeBottom.Parent = bg1
		TreeBottom.Visible = true
		local TreeTop = bg1:FindFirstChild("TreeTop"):Clone()
		TreeTop.Parent = bg1
		TreeTop.Visible = true
		TreeBottom.Position = TreeBottom.Position - UDim2.new(0, 0, screen / 10, 0)
		TreeTop.Position = TreeTop.Position - UDim2.new(0, 0, screen / 10, 0)
		machine.pipes[#machine.pipes + 0.5] = TreeBottom
		machine.pipes[#machine.pipes + 0.5] = TreeTop
		local getBird = machine:getBird()
		local enabled = false
		while TreeBottom.AbsolutePosition.X > -100 do
			if TreeBottom.AbsolutePosition.X < getBird.AbsolutePosition.X and not enabled then
				enabled = true
				machine.points = machine.points + 1
				machine:updatePoints()
			end
			if machine:boundaryCheck(getBird, TreeBottom) then
				machine:die()
			end
			if machine:boundaryCheck(getBird, TreeTop) then
				machine:die()
			end
			if not machine.ended then
				TreeBottom.Position = TreeBottom.Position - UDim2.new(0.008, 0, 0, 0)
				TreeTop.Position = TreeTop.Position - UDim2.new(0.008, 0, 0, 0)
			end
			game:GetService("RunService").RenderStepped:Wait()		
		end
		TreeBottom:Destroy()
		TreeTop:Destroy()
	end
	function AlolanAdventure.updatePoints(arcade)
		bg1.points.Text = tostring(arcade.points)
	end
	function AlolanAdventure.getPipeSpawnTimeMultiplier(mul)
		return 1.5
	end
	local colorCode = Color3.fromRGB(68, 149, 245)
	local cam = workspace.CurrentCamera
	function AlolanAdventure.start(machine, uio)
		machine.ended = false
		machine.started = false
		machine.bird = nil
		speed = {
			velocity = {
				x = 0, 
				y = 0
			}
		}
		gui2 = uio:WaitForChild("Screen")
		bg1 = gui2.SurfaceGui:Clone()
		bg1.Parent = gui2
		bg1.Enabled = true
		local FloorFrame = Utilities.Create("Frame")({
			BackgroundTransparency = 1, 
			Parent = bg1, 
			BorderSizePixel = 1, 
			BorderColor3 = Color3.fromRGB(colorCode), 
			Size = UDim2.new(1, 0, 0.001, 0), 
			Position = UDim2.new(0, 0, 0.99, 0), 
			Name = "Floor"
		})
		local CeilingFrame = Utilities.Create("Frame")({
			BackgroundTransparency = 1, 
			Parent = bg1, 
			BorderSizePixel = 1, 
			BorderColor3 = Color3.fromRGB(colorCode), 
			Size = UDim2.new(1, 0, 0.001, 0), 
			Position = UDim2.new(0, 0, 0, 0), 
			Name = "Ceiling"
		})
		bg2 = 0.3333333333333333 * bg1.AbsoluteSize.X
		bg3 = Vector2.new(bg1.AbsoluteSize.X / 2, bg1.AbsoluteSize.Y / 2)
		cam.CameraType = Enum.CameraType.Scriptable
		local cframe = workspace.CurrentCamera.CFrame
		Tween(1, "easeOutCubic", function(y)
			cam.CFrame = cframe:Lerp(CFrame.new((gui2.CFrame * CFrame.new(0, 0, -3)).p, gui2.Position), y)
		end)
		gui2.Color = colorCode
		gui2.Transparency = 0
		bg1.points.Visible = true
		local getBird = machine:getBird()
		machine.pipes = {}
		while not machine.started do
			Tween(0.65, nil, function(x)
				if machine.started then
					return false
				end
				getBird.Position = UDim2.new(0, bg2, 0, bg3.y + x * 30, 0)
			end)
			Tween(0.65, nil, function(z)
				if machine.started then
					return false
				end
				getBird.Position = UDim2.new(0, bg2, 0, bg3.y + 30 - z * 30, 0)
			end)		
		end
		machine.points = 0
		bg1.ClipsDescendants = true
		spawn(function()
			while game:GetService("RunService").RenderStepped:Wait() and getBird.Parent do
				if pos(machine.bird, CeilingFrame) and not machine.ended then
					spawn(function()
						AlolanAdventure:die()
					end)
				end
				machine:step(machine:getBird())			
			end
		end)
		while not machine.ended do
			wait(machine:getPipeSpawnTimeMultiplier())
			local rand = math.random(-4, -1)
			spawn(function()
				machine:spawnPipe(rand)
			end)		
		end
	end
	AlolanAdventure.GameEnded = Utilities.Signal()
	return AlolanAdventure
end
