print("Loading")
-- For when teleporting to game
local text1, text2 = 'NOW', 'LOADING'
local forceContinue = false
local teleportGui
game:GetService('TeleportService').LocalPlayerArrivedFromTeleport:connect(function(gui, data)
	local player = game:GetService('Players').LocalPlayer
	local userId = player.UserId
	teleportGui = gui
	if not data or type(data) ~= 'table' or data.passcode ~= 'PBB_RTD_fast12<' then return end -- OVH  change passcode?
	if data.userId ~= userId then wait(); player:Kick('Teleport error: player ID mismatch') end
	forceContinue = true
	if data.text1 and data.text2 then
		text1 = data.text1
		text2 = data.text2
	end
end)
--

local player = game:GetService('Players').LocalPlayer
local userId = player.UserId
local gui = Instance.new('ScreenGui')

-- We need local copies of some Utilities
local Timing = {
	easeOutCubic = function(d)
		return function(t)
			t = t / d - 1
			return t^3 + 1
		end
	end
}
local stepped = game:GetService('RunService').RenderStepped
function Tween(duration, timing, fn)
	if type(timing) == 'string' then
		timing = Timing[timing](duration)
	end
	local st = tick()
	fn(0)
	while true do
		stepped:wait()
		local et = tick()-st
		if et >= duration then
			fn(1)
			return
		end
		local a = et/duration
		if timing then
			a = timing(et)
		end
		if fn(a) == false then return end
	end
end
function create(instanceType)
	return function(data)
		local obj = Instance.new(instanceType)
		for k, v in pairs(data) do
			local s, e = pcall(function()
				if type(k) == 'number' then
					v.Parent = obj
				elseif type(v) == 'function' then
					obj[k]:connect(v)
				else
					obj[k] = v
				end
			end)
			if not s then
				error('Create: could not set property '..k..' of '..instanceType..' ('..e..')', 2)
			end
		end
		return obj
	end
end
--[[
local rs = game:GetService('ReplicatedStorage')
local GUI = player:WaitForChild("PlayerGui")
if text1 == "NOW" then
	--game.ReplicatedStorage:WaitForChild("AlreadyEnteredSetupComplete")
	game.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("AlreadyEntered")
	--warn("invoked")
	local Entered = rs.Remote.AlreadyEntered:InvokeServer()
	--local Entered = game.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("AlreadyEntered"):InvokeServer()
	print("already entered")
	if not Entered and text1 == "NOW" and text2 == "LOADING" then
		print("hi")
		--local Trivia = script.Parent
		local Answer = script.ScreenGui:Clone()
		Answer.Parent = GUI
		local Value = false
		Answer.Frame.Main.Answers.Frame.Answer.TextBox.FocusLost:Connect(function()
			if Answer.Frame.Main.Answers.Frame.Answer.TextBox.Text:lower() == "pokemon brick bronze" then
				Answer:remove()
				Value = true
				return
			end
			Answer.Frame.Main.Answers.Frame.Answer.TextBox:remove()
			Answer.Frame.Main.Answers.Objective.Frame.Top.Text = "Thank you for your answer! We always check your answers, so come back every day!"
		end)
		while true do
			wait()
			if Value == true then
				break
			end
		end
		Answer:remove()
		--print("ok")
		rs.Remote.UpdateCodeAlreadyEntered:FireServer()
		--game.ReplicatedStorage:WaitForChild("Remote").UpdateCodeAlreadyEntered:FireServer()
		warn("FIRED SERVER")
	end
end
--]]
--
local PlayerGui = player:WaitForChild('PlayerGui')
gui.Name = 'LoadingGui'
gui.Parent = PlayerGui
for _, id in pairs({288621494,288621623,288621744,288621878, 191836102,191836129,191836172,191836194,191836210, 288652352, 288686590, 270154756, 313110711,313609630}) do
	create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://'..id,
		ImageColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(0.0, 1, 0.0, 1),
		Parent = gui,
	}
end
local container = create 'Frame' {
	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
	Size = UDim2.new(1.0, 0, 1.0, 36),
	Position = UDim2.new(0.0, 0, 0.0, -36),
	Parent = gui
}
local top = create 'Frame' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(1.0, 0, 0.5, 0),-- 36),
	Position = UDim2.new(0.0, 0, 0.0, 0),-- -36),
	ClipsDescendants = true,
	Parent = container,
}
local bottom = create 'Frame' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(1.0, 0, 0.5, 0),
	Position = UDim2.new(0.0, 0, 0.5, 0),
	ClipsDescendants = true,
	Parent = container,

	create 'Frame' {
		Name = 'div',
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 2.0, 0),-- 36),
		Position = UDim2.new(0.0, 0, -1.0, 0),-- -36),
	}
}
function tileBackgroundTexture(frameToFill)
	frameToFill:ClearAllChildren()
	local backgroundTextureSize = Vector2.new(512, 512)
	for i = 0, math.ceil(frameToFill.AbsoluteSize.X/backgroundTextureSize.X) do
		for j = 0, math.ceil(frameToFill.AbsoluteSize.Y/backgroundTextureSize.Y) do
			create 'ImageLabel' {
				BackgroundTransparency = 1,
				Image = 'rbxasset://textures/loading/darkLoadingTexture.png',
				Position = UDim2.new(0, i*backgroundTextureSize.X, 0, j*backgroundTextureSize.Y),
				Size = UDim2.new(0, backgroundTextureSize.X, 0, backgroundTextureSize.Y),
				ZIndex = 2,
				Parent = frameToFill,
			}
		end
	end
end
local sq = create 'Frame' {
	BackgroundTransparency = 1.0,
	SizeConstraint = Enum.SizeConstraint.RelativeYY,
	Size = UDim2.new(1.0, 0, 1.0, 0),
	Parent = container,
}
local function onScreenSizeChanged(prop)
	if prop ~= 'AbsoluteSize' then return end
	tileBackgroundTexture(top)
	tileBackgroundTexture(bottom.div)
	sq.Position = UDim2.new(0.5, -sq.AbsoluteSize.X/2, 0.0, 0)
end

local circle = create 'ImageLabel' {
	BackgroundTransparency = 1.0,
	Image = 'rbxassetid://6138628626',
	ImageColor3 = Color3.new(0, 0, 0),
	Size = UDim2.new(0.0, 1, 0.0, 1),
	Position = UDim2.new(0.1, 0, 0.5, 0),
	ZIndex = 3,
	Parent = sq,
}
local ball = create 'ImageLabel' {
	BackgroundTransparency = 1.0,
	Image = 'rbxassetid://6142797850',-- 5121651632
	Size = UDim2.new(0.0, 1, 0.0, 1),
	Position = UDim2.new(0.1, 0, 0.5, 0),
	ZIndex = 4,
	Parent = sq,
}
spawn(function()
	local s = tick()
	while ball.Parent do
		stepped:wait()
		ball.Rotation = (tick()-s)*250
	end
end)
local s = 0.1
local nowcontainer = create 'Frame' {
	BackgroundTransparency = 1.0,
	ClipsDescendants = true,
	Size = UDim2.new(1.0, 0, s, 0),
	Position = UDim2.new(-0.5-s*2.5/2, 0, 0.5-s/2, 0),
	Parent = sq,
}
local now = create 'TextLabel' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(1.0, 0, 1.0, 0),
	Position = UDim2.new(1.0, 0, 0.0, 0),
	Text = text1,
	TextXAlignment = Enum.TextXAlignment.Right,
	Font = Enum.Font.SourceSansBold,
	TextScaled = true,
	TextColor3 = Color3.new(.3, .3, .3),
	ZIndex = 5,
	Parent = nowcontainer,
}
local loadingcontainer = create 'Frame' {
	BackgroundTransparency = 1.0,
	ClipsDescendants = true,
	Size = UDim2.new(1.0, 0, s, 0),
	Position = UDim2.new(0.5+s*2.5/2, 0, 0.5-s/2, 0),
	Parent = sq,
}
local loading = create 'TextLabel' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(1.0, 0, 1.0, 0),
	Position = UDim2.new(-1.0, 0, 0.0, 0),
	Text = text2,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.SourceSansBold,
	TextScaled = true,
	TextColor3 = Color3.new(.3, .3, .3),
	ZIndex = 5,
	Parent = loadingcontainer,
}

wait(.1)
local ch = gui.Changed:connect(onScreenSizeChanged)
onScreenSizeChanged('AbsoluteSize')
game:GetService('ReplicatedFirst'):RemoveDefaultLoadingScreen()
wait(.1)
if teleportGui then
	teleportGui:remove()
end

local b = s*2.25
delay(.5, function()
	Tween(.7, 'easeOutCubic', function(a)
		ball.Size = UDim2.new(b*a, 0, b*a, 0)
		ball.Position = UDim2.new(0.5-b*a/2, 0, 0.5-b*a/2, 0)
	end)
end)
Tween(1, 'easeOutCubic', function(a)
	top.Position = UDim2.new(0.0, 0, -s/2*a, 0)-- -36)
	bottom.Position = UDim2.new(0.0, 0, 0.5+s/2*a, 0)
	circle.Size = UDim2.new(s*2.5*a, 0, s*2.5*a, 0)
	circle.Position = UDim2.new(0.5-s*2.5*a/2, 0, 0.5-s*2.5*a/2, 0)
end)
Tween(.5, 'easeOutCubic', function(a)
	now.Position = UDim2.new(1-a, 0, -0.01, 0)
	loading.Position = UDim2.new(-1+a, 0, -0.01, 0)
end)


wait(.5)
while true do
	wait(.5)
	if game:IsLoaded() then break end
	wait(.5)
end
game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local removeBan = {
	66018099,  'HellolmNicholas',
	118163254, 'tdradm',
	88143416,  'Ichizure',
	--	91857120,  'Dysekt',
	--	136551797, 'Dominous_Asphalt',

	53110875,  'B0oik',
	20520348,  'scapt',
	44910979,  'Iavavampire',
	16986914,  'Glacier5X55',

	145489345, 'dysekt22',
	120733888, 'OPRHolder',

	--	105862879, '21jlabar2',
	--	41740740,  '2beastnaji',
	--	8009722,   '291sith',
	--	36871990,  '2006mason',
	--	92789666,  '21WilliamH',
	--	57226433,  '20tdunn',
	--	41740740,  '2beastnaji',
}
for _, idOrName in pairs(removeBan) do
	if player.Name == idOrName or userId == idOrName then
		pcall(function() game:GetService('ReplicatedStorage'):ClearAllChildren() end)
		player:Kick()
		player:remove()
		error()
	end
end
local ban = {
	--	34456082, 'TheShinyMudkipz',
	--[[
	74673809, 'Derversin',
	40275496, 'hammad990',
	81126254, 'ola1098',
	41771154, 'ShiroiKitsune',
	93181150, 'TheShinyIceCubes',
--	32652184, 'Phyclops',
	11051588, 'SoberPain',
	25333529, 'xXTheDarkSolderXx',
--	2838769,  'itachi5036',
	4678901,  'stargirl679',
	45715189, 'WengLin',
	56114235, 'iiMadiSparkle',
	43036807, 'SuperShock360',
	9486557,  'dayneisaloser',
	36589133, 'gracjan556',
	
	3095250,  'Robotmega',
--	45124586, '12103net',
	109118730,'plsspaces',
--	62403552, 'PromethiusX',
--	25071745, 'lutenitRigs22',
	3581196,  'nullnull',
	93191245, 'GroovyII',
	
	13497980, 'SuperBossX',
	
	21936591, 'gotokill4',
--	15387584, 'somatey1',
--	41548649, 'SamuelthekidRS',
	
	'BostonRobMariano', 29100668,
	'Altyste', 5878592,
	'tdradm', 118163254,
	'genregaming', 32814691,
	'iloverpg13', 37093992,
--	'switchon', 33122620,
	'Harveybladeop', 71197941,
	'kingjake12396', 93568742,
	'awesomeness69ers', 84172633,
	
	'EG_RaitonAsura', 32743333,
	'Doremn', 39276630,
	--]]
	'iDominusU', 93543142,
}
for _, idOrName in pairs(ban) do
	if player.Name == idOrName or userId == idOrName then
		game:GetService('ReplicatedStorage'):ClearAllChildren()
		Instance.new('BindableEvent').Event:wait()
	end
end

local comTag = script.Parent:WaitForChild('Waiting')

if not teleportGui then
	game:GetService('ContentProvider'):PreloadAsync{'rbxassetid://594478911'}
	create('Sound')({SoundId = 'rbxassetid://594478911', Looped = true, Parent = gui}):Play()
end

local fader = create 'Frame' {
	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
	Size = UDim2.new(1.0, 0, 1.0, 0),
	ZIndex = 10,
	Parent = container,
}
Tween(1.6, 'easeOutCubic', function(a)
	local o = 1-a
	top.Position = UDim2.new(0.0, 0, -s/2*o, 0)-- -36)
	bottom.Position = UDim2.new(0.0, 0, 0.5+s/2*o, 0)
	circle.Size = UDim2.new(s*2.5*o, 0, s*2.5*o, 0)
	circle.Position = UDim2.new(0.5-s*2.5*o/2, 0, 0.5-s*2.5*o/2, 0)

	now.Position = UDim2.new(a, 0, -0.01, 0)
	loading.Position = UDim2.new(-a, 0, -0.01, 0)

	ball.ImageColor3 = Color3.new(o, o, o)
	ball.Size = UDim2.new(b+3*a, 0, b+3*a, 0)
	ball.Position = UDim2.new(0.5-b/2-3*a/2, 0, 0.5-b/2-3*a/2, 0)
	fader.BackgroundTransparency = o
end)

ch:disconnect()
wait(1) -- trying to fix the infinite loading screen due to assets not loading in server storage with bypass
if gui then
	comTag.Value = gui
end
if forceContinue then
	comTag.Name = 'ForceContinue'
else
	comTag.Name = 'Ready'
end
script:remove()