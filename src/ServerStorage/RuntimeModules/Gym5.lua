return function(_p)
local Utilities = _p.Utilities
local gui = Utilities.frontGui
local raycast = Utilities.findPartOnRayWithIgnoreFunction
local ray = Ray.new
local player = _p.player

local MAX_DIST = 22
local SPEED_MULT_ID = 'Gym5_SpeedMultiplier'
local STEP_BIND_ID = 'Gym5_DigCheck'

local runService = game:GetService('RunService')
local mcn

local gym5 = {}
local mouse, camera
local map, dirt, stone
local level = 0
local bound = false

local active = false

local digging = false
local shovelIcon = Utilities.Create 'ImageLabel' {
	BackgroundTransparency = 1.0,
	Image = 'rbxassetid://5267649868',
	Size = UDim2.new(0.0, 40, 0.0, 40),
}
local pickaxeIcon = Utilities.Create 'ImageLabel' {
	BackgroundTransparency = 1.0,
	Image = 'rbxassetid://5267652968',
	Size = UDim2.new(0.0, 40, 0.0, 40),
}

local surfaceButton = _p.RoundedFrame:new {
	Button = true,
	BackgroundColor3 = Color3.new(.3, .3, .3),
	Size = UDim2.new(.18, 0, .05, 0),
	Position = UDim2.new(.41, 0, .875, 0),
	Visible = false,
	MouseButton1Click = function()
		if not _p.MasterControl.WalkEnabled then return end
		spawn(function() _p.Menu:disable() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		Utilities.FadeOut(.5)
		Utilities.Teleport(CFrame.new(-130, 83, 350, -1, 0, 0, 0, 1, 0, 0, 0, -1))
		wait(.5)
		Utilities.FadeIn(.5)
		_p.MasterControl.WalkEnabled = true
		--_p.MasterControl:Start()
		_p.Menu:enable()
	end
}
Utilities.Write 'Return to Surface' {
	Frame = Utilities.Create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(0.0, 0, .5, 0),
		Position = UDim2.new(.5, 0, .25, 0),
		ZIndex = 2, Parent = surfaceButton.gui
	}, Scaled = true
}

local function getTarget()
	local target = mouse.Target
	if not target then return end
	if target.Parent == dirt or target.Parent == stone then return target end
	local campos = camera.CFrame.p
--	target = workspace:FindPartOnRayWithWhitelist(ray(campos, (mouse.Hit.p-campos).unit*40), {dirt, stone}, true)
	target = (raycast(ray(campos, (mouse.Hit.p-campos).unit*40), {player.Character}, function(obj)
		return obj.Transparency >= 1.0 or (obj.Parent and obj.Parent:IsA('Accoutrement'))
	end))
	if not target then return end
	if target.Parent == dirt or target.Parent == stone then return target end
end

local function removeBlock(block)
	local dif = block.Position - player.Character.Head.Position
	local size, cf = block.Size, block.CFrame
	if dif.Y < -6 then
		-- case 1: above the block: always dig down
		Utilities.Tween(.5, nil, function(a)
			block.Size = size * Vector3.new(1, 1-a, 1)
			block.CFrame = cf * CFrame.new(0, -size.Y*.5*a, 0)
		end)
		block:remove()
	elseif math.abs(dif.X) + math.abs(dif.Z) < 6 and dif.Y > 4 then
		-- case 2: digging up from below
		Utilities.Tween(.5, nil, function(a)
			block.Size = size * Vector3.new(1, 1-a, 1)
			block.CFrame = cf * CFrame.new(0, size.Y*.5*a, 0)
		end)
		block:remove()
	else
		-- case 3: dig in most extreme difference in direction
		local dir = math.abs(dif.X)>math.abs(dif.Z) and Vector3.new(dif.X,0,0).unit or Vector3.new(0,0,dif.Z).unit
		local absdir = Vector3.new(math.abs(dir.X), 0, math.abs(dir.Z))
		local ident = Vector3.new(1, 1, 1)
		local len = (size*dir).magnitude
		Utilities.Tween(.5, nil, function(a)
			block.Size = size * (ident-absdir*a)
			block.CFrame = cf * CFrame.new(dir*len*.5*a)
		end)
		block:remove()
	end
end

local function mouseDown()
	if (_p.NPCChat.chatBox and _p.NPCChat.chatBox.Parent) or not _p.MasterControl.WalkEnabled then return end
	if digging then return end
	digging = true
	local targ = getTarget()
	if targ and (targ.Position-player.Character.Head.Position).magnitude < MAX_DIST and
		((targ.Parent == dirt and level > 0) or (targ.Parent == stone and level > 1)) then
		shovelIcon.Parent = nil
		pickaxeIcon.Parent = nil
		_p.RunningShoes:setSpeedMultiplier(SPEED_MULT_ID, .5)
		removeBlock(targ)
		_p.RunningShoes:removeSpeedMultiplier(SPEED_MULT_ID)
	end
	digging = false
end

local function update()
	if digging then return end
	if not map.Parent then
		-- disable
		bound = false
		runService:UnbindFromRenderStep(STEP_BIND_ID)
		if mcn then
			pcall(function() mcn:disconnect() end)
			mcn = nil
		end
		return
	end
	
	local targ = getTarget()
	if targ and targ.Parent == dirt and level > 0 and (targ.Position-player.Character.Head.Position).magnitude < MAX_DIST then
		pickaxeIcon.Parent = nil
		shovelIcon.Parent = gui
		shovelIcon.Position = UDim2.new(0.0, mouse.X + 5, 0.0, mouse.Y + 16)
	elseif targ and targ.Parent == stone and level > 1 and (targ.Position-player.Character.Head.Position).magnitude < MAX_DIST then
		shovelIcon.Parent = nil
		pickaxeIcon.Parent = gui
		pickaxeIcon.Position = UDim2.new(0.0, mouse.X + 5, 0.0, mouse.Y + 18)
	else
		shovelIcon.Parent = nil
		pickaxeIcon.Parent = nil
	end
end

function gym5:setLevel(l)
	if level > l then return end
	level = l
	if not bound and l > 0 then
		-- enable
		bound = true
		runService:BindToRenderStep(STEP_BIND_ID, Enum.RenderPriority.Last.Value, update)
		mcn = mouse.Button1Down:connect(mouseDown)
	end
end

function gym5:activate(chunk)
	active = true
	mouse = player:GetMouse()
	camera = workspace.CurrentCamera
	
	map = chunk.map
	dirt = map.AllDirt
	stone = map.AllStone
	if _p.PlayerData.completedEvents.G5Pickaxe then
		self:setLevel(2)
	elseif _p.PlayerData.completedEvents.G5Shovel then
		self:setLevel(1)
--	else
--		self:setLevel(0)
	end
	
	surfaceButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.01
	surfaceButton.Parent = Utilities.backGui
	spawn(function()
		local heartbeat = game:GetService('RunService').Heartbeat
		local mc = _p.MasterControl
		local root
		while active do
			if not root or not root.Parent then
				root = nil
				pcall(function() root = _p.player.Character.HumanoidRootPart end)
			end
			surfaceButton.Visible = (mc.WalkEnabled and root and root.Position.Y < 80) or false
			heartbeat:wait()
		end
	end)
end

function gym5:deactivate()
	active = false
	surfaceButton.Parent = nil
end

return gym5
end