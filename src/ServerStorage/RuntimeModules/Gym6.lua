return function(_p)
local Utilities = _p.Utilities
local players = game:GetService('Players')
local player = _p.player

local gym6 = {}
local mouse, map -- todo: remove what's not needed
local fruit, bucket
local carrying
local carryAnim

local active = false
local bound = false

local mobile = Utilities.isTouchDevice()

-- todo: if not reducedgraphics, render trajectory

local runService = game:GetService('RunService')
local STEP_BIND_ID = 'Gym6_ThrowCheck'
--local drawcount = 0

local MAX_THROW_VELOCITY = 75

local disk = Utilities.Create 'Part' {
	Material = Enum.Material.Neon,
	BrickColor = BrickColor.new('White'),
	Anchored = true,
	CanCollide = false,
	Size = Vector3.new(5, .2, 5),
	
	Instance.new('CylinderMesh')
}
local dot = Utilities.Create 'Part' {
	Material = Enum.Material.Neon,
	BrickColor = BrickColor.new('White'),
	Anchored = true,
	CanCollide = false,
	Size = Vector3.new(.4, .4, .4),
	Shape = Enum.PartType.Ball
}
local dots = {}
local dq = {}

local DROP_BG_COLOR = Color3.new(.3, .3, .3)
local BUILD_BG_COLOR = Color3.fromRGB(234, 164, 60)
local dropButton = _p.RoundedFrame:new {
	Button = true,
	BackgroundColor3 = DROP_BG_COLOR,
	Size = UDim2.new(.14, 0, .07, 0),
	Position = UDim2.new(.43, 0, .865, 0),
	Visible = false
}
local dropText = Utilities.Write 'Drop' {
	Frame = Utilities.Create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(0.0, 0, .5, 0),
		Position = UDim2.new(.5, 0, .25, 0),
		ZIndex = 2, Parent = dropButton.gui
	}, Scaled = true
} .Frame
local buildText = Utilities.Write 'Build' {
	Frame = Utilities.Create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(0.0, 0, .5, 0),
		Position = UDim2.new(.5, 0, .25, 0),
		ZIndex = 2, Parent = dropButton.gui
	}, Scaled = true
} .Frame

local fruitUpdate; do
	local sqrt = math.sqrt
	local tan = math.tan
	local v3 = Vector3.new
	local cf = CFrame.new
	local half_pi = math.pi/2
	local quarter_pi = math.pi/4
	local floor = math.floor
	local remove = table.remove
	fruitUpdate = function()
		if not carrying then return end
		local pp
		pcall(function() pp = player.Character.Head.Position end)
		if not pp then return end
		local p = mouse.Hit.p
		if mouse.Target and mouse.Target.Parent == bucket then
			p = bucket.Main.Position + v3(0, 7, 0)
		end
		disk.CFrame = cf(p)
		
		local from = carrying.Position
		local xdir = (p-from)*v3(1,0,1)
		local dx = xdir.magnitude
		local dy = p.Y-from.Y
		local theta = dx<10 and (half_pi-quarter_pi*dx/10) or quarter_pi
		local c = 1/tan(theta)
		local vy = dx * 14 / sqrt(c) / sqrt(2*dx-2*dy*c)
		local vx = c*vy
		local valid = sqrt(vy*vy+vx*vx) < MAX_THROW_VELOCITY
		disk.Transparency = valid and .1 or .6
		if valid then
			local t = dx/vx
			local n = floor(t/.05)
			for i = 1, n do
				local ta = .05*i
				local d = dots[i] or remove(dq) or dot:Clone()
				dots[i] = d
				d.Parent = map
				d.CFrame = cf(from + v3(0, vy*ta-98.1*ta*ta, 0) + xdir.unit*vx*ta)
			end
			local dc = #dq
			for i = n+1, #dots do
				local d = dots[i]
				dc = dc + 1
				dq[dc] = d
				d.Parent = nil
				dots[i] = nil
			end
		elseif #dots > 0 then
			local dc = #dq
			for _, d in pairs(dots) do
				dc = dc + 1
				dq[dc] = d
				d.Parent = nil
			end
			dots = {}
		end
	end
end

local bridges, currentBridge, wcn
local function woodUpdate()
	local pp
	pcall(function() pp = player.Character.HumanoidRootPart.Position end)
	if not pp then return end
	if currentBridge and (pp-currentBridge.position).magnitude > 9 then
		currentBridge = nil
	end
	if not currentBridge then
		for _, b in pairs(bridges) do
			if (pp-b.position).magnitude < 9 then
				currentBridge = b
				break
			end
		end
	end
	local build = currentBridge and true or false
	dropText.Visible = not build
	buildText.Visible = build
	dropButton.BackgroundColor3 = build and BUILD_BG_COLOR or DROP_BG_COLOR
	dropButton.Visible = _p.MasterControl.WalkEnabled
end

local function throwFruit(f, weld)
	if not f or not f.Parent then return true end -- player left gym and clicked later
	if not carrying --[[or (not mobile and disk.Transparency > .5)]] then return end
	if not mobile then
		bound = false
		runService:UnbindFromRenderStep(STEP_BIND_ID)
	end
	local from = f.Position
	local to = disk.Position
	if mobile then
		to = mouse.Hit.p
		if mouse.Target and mouse.Target.Parent == bucket then
			to = bucket.Main.Position + Vector3.new(0, 7, 0)
		end
	end
	_p.MasterControl.WalkEnabled = false
	_p.MasterControl:Stop()
	
	disk.Parent = nil
	local dc = #dq
	for _, d in pairs(dots) do
		dc = dc + 1
		dq[dc] = d
		d.Parent = nil
	end
	dots = {}
	
	local xdir = (to-from)*Vector3.new(1,0,1)
	local dx = xdir.magnitude
	local dy = to.Y-from.Y
	
	local theta = math.rad(dx<10 and (90-45*dx/10) or 45)
	local c = 1/math.tan(theta)
	local vy = dx * 14 / math.sqrt(c) / math.sqrt(2*dx-2*dy*c)
	local vx = c*vy
	local cf = f.CFrame
	pcall(function() weld:remove() end)
	if f.Name == 'Main' then
--		f.Parent.Parent = map
	else
--		f:BreakJoints()
		f.Parent = fruit
	end
	f.CFrame = cf
	local v = Vector3.new(0, vy, 0) + xdir.unit*vx
--	print(vx, vy, v.magnitude)
	if --[[mobile and]] v.magnitude > MAX_THROW_VELOCITY then
		v = v.unit * MAX_THROW_VELOCITY
	end
	f.Velocity = v
	pcall(function() carryAnim:Stop(.3) end)
	delay(.1, function() f.CanCollide = true end)
	wait(.5)
	carrying = nil
	pcall(function() Utilities.getHumanoid():SetStateEnabled(Enum.HumanoidStateType.Climbing, true) end)
	_p.RunningShoes:enable()
	_p.MasterControl.WalkEnabled = true
	--_p.MasterControl:Start()
	return true
end

local woodweld
local function buildOrDrop()
	if not carrying or carrying.Name ~= 'Main' or not _p.MasterControl.WalkEnabled then return end
	pcall(function() wcn:disconnect() end)
	wcn = nil
	dropButton.Visible = false
	local main = carrying
--	carrying = nil
	local bridge = currentBridge
	currentBridge = nil
	_p.MasterControl.WalkEnabled = false
	_p.MasterControl:Stop()
	if bridge then
		-- build
		for i = #bridges, 1, -1 do
			if bridges[i] == bridge then
				table.remove(bridges, i)
			end
		end
		bridge.nodes:remove()
		local fparts = {}
		local tparts = {}
		for _, p in pairs(main.Parent:GetChildren()) do
			if p ~= main and p:IsA('BasePart') then
				local bc = p.BrickColor.Number
				local fbcp = fparts[bc]
				if not fbcp then
					fbcp = {}
					fparts[bc] = fbcp
				end
				fbcp[#fbcp+1] = {p, p.Size, p.CFrame}
				p.Anchored = true
			end
		end
		main:remove()
		for _, p in pairs(bridge.bridge:GetChildren()) do
			if p:IsA('BasePart') then
				local bc = p.BrickColor.Number
				local tbcp = tparts[bc]
				if not tbcp then
					tbcp = {}
					tparts[bc] = tbcp
				end
				tbcp[#tbcp+1] = {p.Size, p.CFrame}
			end
		end
		bridge.bridge:remove()
		local parts = {}
		for bc, tgroup in pairs(tparts) do
			local fgroup = fparts[bc]
			local rf = {}
			while #tgroup > 0 do
				local t = table.remove(tgroup, math.random(#tgroup))
				local nf = #fgroup
				if nf > 0 then
					local f = table.remove(fgroup, nf)
					rf[#rf+1] = f
					parts[#parts+1] = {f[1], f[2], t[1]-f[2], select(2, Utilities.lerpCFrame(f[3], t[2]))}
				else
					local f = rf[math.random(#rf)]
					local p = f[1]:Clone()
					p.Parent = f[1].Parent
					parts[#parts+1] = {p, f[2], t[1]-f[2], select(2, Utilities.lerpCFrame(f[3], t[2]))}
				end
			end
			for _, f in pairs(fgroup) do
				f[1]:remove()
			end
		end
		while #parts > 0 do
			local p, ss, sd, cflerp = unpack(table.remove(parts, math.random(#parts)))
			spawn(function()
				Utilities.Tween(.7, nil, function(a)
					p.Size = ss + sd*a
					p.CFrame = cflerp(a) + Vector3.new(0, 5*math.sin(a*math.pi), 0)
				end)
				p.CanCollide = true
			end)
			wait(.05)
		end
		pcall(function() carryAnim:Stop(.3) end)
		wait(.7)
	else
		-- drop
		-- root position
		local root = player.Character.HumanoidRootPart
		local pp = root.Position
		pcall(function()
			local human = Utilities.getHumanoid()
			if human.RigType == Enum.HumanoidRigType.R15 then
				pp = pp + Vector3.new(0, -3 + root.Size.Y/2 + human.HipHeight, 0)
			end
		end)
		-- bucket proximity
		local dif = pp-bucket.Main.Position
		if math.sqrt(dif.X^2+dif.Z^2) < 14 then
			_p.MasterControl:Look(Vector3.new(dif.X, 0, dif.Z).unit)
		end
		-- hinge
		local forward = (root.CFrame.lookVector*Vector3.new(1,0,1)).unit
		if forward.magnitude < .5 then forward = Vector3.new(1, 0, 0) end
		local pivot = pp + Vector3.new(0, .5, 0)
		local pcf = CFrame.new(pivot, pivot + forward)
		local dif = main.Position - pivot
		local r = dif.magnitude
		local fr = main.Size.magnitude/2+1
		local dr = r-fr
		-- angle
		local angle = math.acos(dif.unit:Dot(forward))
		local rcf = pcf:inverse()*main.CFrame
		local ru = rcf.p.unit
		rcf = rcf-rcf.p
		pcall(function() carryAnim:Stop(.5) end)
		-- weld stuff
		local welds = main:GetChildren()
		for i = #welds, 1, -1 do
			local w = welds[i]
			if not w:IsA('Weld') then
				table.remove(welds, i)
			end
		end
		-- animation
		woodweld:remove()
		main.Anchored = true
		main.CanCollide = false
		Utilities.Tween(.7, 'easeOutCubic', function(a)
			local rcfs = rcf + ru*(r-dr*a)
			local cf = pcf * CFrame.Angles(-angle*a, 0, 0) * rcfs
			main.CFrame = cf
			for _, w in pairs(welds) do
				pcall(function() w.Part1.CFrame = cf * w.C0 end)
			end
		end)
		main.Anchored = false
		main.CanCollide = true
	end
	carrying = nil
	pcall(function() Utilities.getHumanoid():SetStateEnabled(Enum.HumanoidStateType.Climbing, true) end)
	_p.RunningShoes:enable()
	_p.MasterControl.WalkEnabled = true
	--_p.MasterControl:Start()
end
dropButton.MouseButton1Click:connect(buildOrDrop)

local function fruitTouched(f)
--	print(f.Name, 'touched')
	carrying = f
	_p.MasterControl.WalkEnabled = false
	_p.MasterControl:Stop()
	local root = player.Character.HumanoidRootPart
	local pp = root.Position
	spawn(function() _p.MasterControl:LookAt(f.Position) end)
	pcall(function()
		local human = Utilities.getHumanoid()
		pcall(function() human:SetStateEnabled(Enum.HumanoidStateType.Climbing, false) end)
		if human.RigType == Enum.HumanoidRigType.R15 then
			pp = pp + Vector3.new(0, -3 + root.Size.Y/2 + human.HipHeight, 0)
		end
	end)
	_p.RunningShoes:disable()
	
	f.Anchored = true
	f.CanCollide = false
	local pivot = pp + Vector3.new(0, .5, 0)
	local pcf = CFrame.new(pivot, f.Position)
	local dif = f.Position - pivot
	local r = dif.magnitude
	local fr = f.Size.magnitude/2+2
	-- minimize with ray if we can
	local _, hp = workspace:FindPartOnRayWithWhitelist(Ray.new(pivot, f.Position-pivot), {f}, true)
	if hp then
		fr = math.min(fr, (f.Position-hp).magnitude+3)
	end
	--
	local dr = r-fr
	local angle = math.acos(Vector3.new(0, 1, 0):Dot(dif.unit))
	local rcf = pcf:inverse()*f.CFrame
	local ru = rcf.p.unit
	rcf = rcf-rcf.p
	pcall(function() carryAnim:Play(.5) end)
	-- wood balls need help cuz anchored welds
	local isWoodBall = f.Name == 'Main'
	local welds
	if isWoodBall then
		welds = f:GetChildren()--f.Parent:GetChildren()
		for i = #welds, 1, -1 do
			local w = welds[i]--p
			if w:IsA('Weld') then--p == f or not p:IsA('BasePart') then
--				pcall(function() w.Part1.Anchored = true end)
			else
				table.remove(welds, i)
			end
		end
	end
	Utilities.Tween(.7, 'easeOutCubic', function(a)
		local rcfs = rcf + ru*(r-dr*a)
		f.CFrame = pcf * CFrame.Angles(angle*a, 0, 0) * rcfs
		if isWoodBall then
			for _, w in pairs(welds) do
				pcall(function() w.Part1.CFrame = f.CFrame * w.C0 end)
			end
		end
	end)
--	if isWoodBall then
--		for _, w in pairs(welds) do
--			pcall(function() w.Part1.Anchored = false end)
--		end
--	end
	--
	local hand = player.Character:FindFirstChild('Right Arm') or player.Character:FindFirstChild('RightHand')
	f.Anchored = false
	local w = Instance.new('Weld')
	w.Part0 = hand
	w.Part1 = f
	w.C0 = hand.CFrame:inverse()*pcf*CFrame.Angles(angle,0,0)*(rcf+ru*fr)
	w.C1 = CFrame.new()
	if isWoodBall then--f.Name == 'Main' then
--		f.Parent.Parent = player.Character
	else
		f.Parent = player.Character
	end
	w.Parent = hand
--	f.CanCollide = true
	
	if isWoodBall then
		dropText.Visible = true
		buildText.Visible = false
		dropButton.BackgroundColor3 = DROP_BG_COLOR
		dropButton.Visible = true
		wcn = runService.Heartbeat:connect(woodUpdate)
		woodweld = w
	else
		disk.Parent = player.Character
		if not bound and not mobile then
			bound = true
			runService:BindToRenderStep(STEP_BIND_ID, Enum.RenderPriority.Last.Value, fruitUpdate)
		end
		local mcn; mcn = (mobile and game:GetService('UserInputService').TouchTap or mouse.Button1Down):connect(function()
			if not _p.MasterControl.WalkEnabled then return end
			if throwFruit(f, w) then
				mcn:disconnect()
			end
		end)
	end
	_p.MasterControl.WalkEnabled = true
	--_p.MasterControl:Start()
end

function gym6:activate(chunk)
	active = true
	mouse = player:GetMouse()
	map = chunk.map
	-- etc
	fruit = map.Fruit
	bucket = map.Bucket
	local fDebounce = false
	
	dropButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.019
	dropButton.Parent = Utilities.backGui
-- [[
	-- prep bridges/material balls
--	for _ = 1, 3 do pcall(function() map.BuildBridge:remove() end) end
	bridges = {}
	currentBridge = nil
	for _, m in pairs(map:GetChildren()) do
		if m.Name == 'BuildNode' then
			table.insert(bridges, {
				position = m.Main.Position,
				bridge = m.Bridge,
				nodes = m
			})
			m.Bridge.Parent = nil
		elseif m.Name == 'Materials' then
			local main = m.Main
--			main.Parent = fruit
			local inv = main.CFrame:inverse()
			for _, p in pairs(m:GetChildren()) do
				if p ~= main and p:IsA('BasePart') then
					Utilities.Create 'Weld' {
						Part0 = main,
						Part1 = p,
						C0 = inv * p.CFrame,
						C1 = CFrame.new(),
						Parent = main
					}
					Utilities.Create 'BodyForce' {
						Force = Vector3.new(0, p:GetMass()*196.2, 0),
						Parent = p
					}
--					p.CustomPhysicalProperties = PhysicalProperties.new(.01, 0.3, 0.5)
					p.Anchored = false
				end
			end
--			main.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
			main.Anchored = false
--			Utilities.Create 'BodyForce' {
--				Force = Vector3.new(0, main:GetMass()*196.2, 0),
--				Parent = main
--			}
			main.Touched:connect(function(p)
				if fDebounce or carrying or not _p.MasterControl.WalkEnabled or not p or not p.Parent or p.Parent:IsA('Accoutrement') or players:GetPlayerFromCharacter(p.Parent) ~= player then return end
				fDebounce = true
				fruitTouched(main)
				fDebounce = false
			end)
		end
	end--]]
	
	for _, f in pairs(fruit:GetChildren()) do
		f.Touched:connect(function(p)
			if fDebounce or carrying or not _p.MasterControl.WalkEnabled or not p or not p.Parent or p.Parent:IsA('Accoutrement') or players:GetPlayerFromCharacter(p.Parent) ~= player then return end
			fDebounce = true
			fruitTouched(f)
			fDebounce = false
		end)
	end
	local human = Utilities.getHumanoid()
	carryAnim = human:LoadAnimation(Utilities.Create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId[(human.RigType==Enum.HumanoidRigType.R15 and 'R15_' or '')..'Carry'] })
	
	spawn(function()
--		local region = _p.Region.new(CFrame.new(bucket.Main.Position + Vector3.new(0, 7, 0)), Vector3.new(10, 14, 10))
		local fruits = fruit:GetChildren()
		local currentFruitCount = 0
		
		local drawbridge = map.Drawbridge
		
		local function getRopePointEndPulley(p1)
			p1 = p1 or drawbridge.RopeAttachL.Position
			local p2 = map.EndPulleyL.Main.Position
			
			local d = (p1-p2).magnitude
			local l = math.sqrt(d*d-4) -- 4 = (r/2)^2
			local th = math.atan2(p2.Y-p1.Y, p2.X-p1.X) - math.asin(2/d) -- 2 = r/2
			return p1 + Vector3.new(math.cos(th), math.sin(th), 0) * l
		end
		
		local ropeFrom = drawbridge.RopeAttachL.Position
		local ropeTo = getRopePointEndPulley()
		local OAL = (ropeTo-ropeFrom).magnitude
--		print(OAL)
		local ropeOffset = drawbridge.RopeAttachR.Position-ropeFrom
		
		local ropeL = map.BucketRopes.Part:Clone()
		local ropeR = ropeL:Clone()
		ropeL.Parent, ropeR.Parent = map, map
		ropeL.Size = Vector3.new(OAL, .4, .4)
		ropeL.CFrame = CFrame.new((ropeFrom+ropeTo)/2, ropeTo) * CFrame.Angles(0, math.pi/2, 0)
		ropeR.Size = ropeL.Size
		ropeR.CFrame = ropeL.CFrame + ropeOffset
		
		local knot = map.BucketRopes.Main:Clone()
		knot.Name = 'Knot'
		knot.Parent = map
		
		local dbparts = {}
		local dbcf = drawbridge.Hinge.CFrame
		do
			local cfi = dbcf:inverse()
			local dbHinge = drawbridge.Hinge
			for _, p in pairs(drawbridge:GetChildren()) do
				if p ~= dbHinge and p:IsA('BasePart') then
					dbparts[p] = cfi * p.CFrame
				end
			end
		end
		local bparts = {}
		local brtop = map.BucketRopes.Top
		for _, p in pairs(bucket:GetChildren()) do
			if p:IsA('BasePart') then bparts[p] = p.CFrame end
		end
		for _, p in pairs(map.BucketRopes:GetChildren()) do
			if p ~= brtop and p:IsA('BasePart') then bparts[p] = p.CFrame end
		end
		local brcf = brtop.CFrame
		local brlen = brtop.Size.X
		local rPlane, rPlaneLength; do
			local t, e = map.TopPulley.Main.Position, map.EndPulleyL.Main.Position
			rPlaneLength = (t-e).magnitude
			local angle = math.atan2(t.Y-e.Y, e.X-t.X) -- e & t purposefully swapped to get positive angle
			local c, s = math.cos(angle), math.sin(angle)
			local p = e+ropeOffset/2+Vector3.new(s*2, c*2, 0)
			rPlane = CFrame.new(p.X, p.Y, p.Z, 0, -c, s, 0, s, c, -1, 0, 0)
			-- translate to guide
			local guideX = map.EndPulleyL.Guide.Position.X - .5
			local gx = p.X-guideX
			local gy = gx*math.tan(angle)
			rPlane = rPlane + Vector3.new(-gx, gy, 0)
			rPlaneLength = rPlaneLength - math.sqrt(gx*gx+gy*gy)
		end
		local rPlaneWidthSquared = ropeOffset.Z^2
--		print(rPlaneLength)
		
		local currentAngle = 0
		local currentResolvedPullLength = 0
		local knotStartDistance = rPlaneLength*.35
		local knotTop = rPlane*Vector3.new(0,rPlaneLength,0)
		local knotLeft = rPlane*Vector3.new(ropeOffset.Z/2,0,0)
		local knotRight = rPlane*Vector3.new(-ropeOffset.Z/2,0,0)
		local ropeKT = ropeL:Clone()
		local ropeKL = ropeL:Clone()
		local ropeKR = ropeL:Clone()
		ropeKT.Parent, ropeKL.Parent, ropeKR.Parent = map, map, map
		do
			local bl = knot:Clone()
			bl.Size = Vector3.new(.4,.4,.4)
			bl.CFrame = CFrame.new(knotLeft)
			bl.Parent = map
			local br = bl:Clone()
			br.CFrame = CFrame.new(knotRight)
			br.Parent = map
			local p = map.EndPulleyL.Main.Position-rPlane.lookVector*2
			local rl = ropeL:Clone()
			rl.Size = Vector3.new((p-knotLeft).magnitude,.4,.4)
			rl.CFrame = CFrame.new((p+knotLeft)/2,p)*CFrame.Angles(0,math.pi/2,0)
			p = p + ropeOffset
			local rr = rl:Clone()
			rr.CFrame = CFrame.new((p+knotRight)/2,p)*CFrame.Angles(0,math.pi/2,0)
			rl.Parent, rr.Parent = map, map
		end
		
		local function updateKnotSection(kp)
			knot.CFrame = CFrame.new(kp)
			ropeKT.Size = Vector3.new((knotTop-kp).magnitude,.4,.4)
			ropeKL.Size = Vector3.new((knotRight-kp).magnitude,.4,.4)
			ropeKR.Size = ropeKL.Size
			ropeKT.CFrame = CFrame.new((knotTop+kp)/2,kp)*CFrame.Angles(0,math.pi/2,0)
			ropeKL.CFrame = CFrame.new((knotLeft+kp)/2,kp)*CFrame.Angles(0,math.pi/2,0)
			ropeKR.CFrame = CFrame.new((knotRight+kp)/2,kp)*CFrame.Angles(0,math.pi/2,0)
		end
		updateKnotSection(rPlane*Vector3.new(0,knotStartDistance,0))
		local function updateBucket(resolvedLength)
			for p, cf in pairs(bparts) do
				p.CFrame = cf + Vector3.new(0, -resolvedLength, 0)
			end
			brtop.Size = Vector3.new(brlen+resolvedLength, .4, .4)
			brtop.CFrame = brcf + Vector3.new(0, -resolvedLength/2, 0)
		end
		
		local function adjustCount(newCount)
--			print(newCount)
			local newAngle = -.1*(newCount==5 and 6 or newCount)
			local ropeFromStart, ropeToStart = ropeFrom, ropeTo
			local ropeFromEnd = (dbcf * CFrame.Angles(0, 0, newAngle) * dbparts[drawbridge.RopeAttachL]).p
			local ropeToEnd = getRopePointEndPulley(ropeFromEnd)
			local da = newAngle - currentAngle
			local newPullLength = OAL - (ropeFromEnd-ropeToEnd).magnitude
			local newResolvedPullLength = math.sqrt((newPullLength+knotStartDistance)^2-rPlaneWidthSquared)-knotStartDistance
--			print(newPullLength, newResolvedPullLength)
			local drpl = newResolvedPullLength-currentResolvedPullLength
			Utilities.Tween(math.abs(currentFruitCount-newCount)*.6, nil, function(a)
				local cf = dbcf * CFrame.Angles(0, 0, currentAngle + da*a)
				for p, rcf in pairs(dbparts) do
					p.CFrame = cf * rcf
				end
				local rf = drawbridge.RopeAttachL.Position--ropeFromStart:Lerp(ropeFromEnd, a)
				local rt = ropeToStart:Lerp(ropeToEnd, a)
				ropeL.Size = Vector3.new((rf-rt).magnitude, .4, .4)
				ropeL.CFrame = CFrame.new((rf+rt)/2, rt) * CFrame.Angles(0, math.pi/2, 0)
				ropeR.Size = ropeL.Size
				ropeR.CFrame = ropeL.CFrame + ropeOffset
				local rlen = currentResolvedPullLength+drpl*a
				updateKnotSection(rPlane*Vector3.new(0, knotStartDistance+rlen, 0))
				updateBucket(rlen)
			end)
			ropeFrom, ropeTo = ropeFromEnd, ropeToEnd
			currentAngle = newAngle
			currentFruitCount = newCount
			currentResolvedPullLength = newResolvedPullLength
		end
		
		while active do
			local nFruitInBasket = 0
			local bp = bucket.Main.Position
			for _, f in pairs(fruits) do
--				if region:CastPoint(f.Position) then
				local fp = f.Position
				if fp.Y > bp.Y and fp.Y < bp.Y+14 and fp.X > bp.X-5 and fp.X < bp.X+5 and fp.Z > bp.Z-5 and fp.Z < bp.Z+5 then
					nFruitInBasket = nFruitInBasket + 1
				end
			end
			if nFruitInBasket ~= currentFruitCount then
				adjustCount(nFruitInBasket)
				if nFruitInBasket == 5 then
					pcall(function() map.LeaderGoalNub:remove() end)
					break -- lock it in at this point
				end
			else
				wait(.5)
			end
		end
	end)
end

function gym6:deactivate()
	active = false
	dropButton.Parent = nil
	if bound then
		bound = false
		runService:UnbindFromRenderStep(STEP_BIND_ID)
	end
	
	-- if carrying fruit, then fix self
	pcall(function() carrying:remove() end)
	pcall(function() carryAnim:Stop(0) end)
	carrying = nil
	disk.Parent = nil
	pcall(function() Utilities.getHumanoid():SetStateEnabled(Enum.HumanoidStateType.Climbing, true) end)
	_p.RunningShoes:enable()
	
	pcall(function() for _, d in pairs(dots) do d:remove() end end)
	pcall(function() for _, d in pairs( dq ) do d:remove() end end)
	dots, dq = {}, {}
	
	-- release de-parented objects
	if type(bridges) == 'table' then
		for _, b in pairs(bridges) do
			pcall(function() b.bridge:remove() end)
		end
	end
end


return gym6
end