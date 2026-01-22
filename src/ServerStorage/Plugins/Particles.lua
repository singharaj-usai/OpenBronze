return function(_p)--local _p = require(script.Parent)
local Utilities = _p.Utilities
local stepped = game:GetService('RunService').RenderStepped

local particles = {}
local pCn

local lastStep
local function onStepped()
	if #particles == 0 and pCn then
		pCn:disconnect()
		pCn = nil
		lastStep = nil
		return
	end
	if not lastStep then
		lastStep = tick()
		return
	end
	local t = tick()
	local dt = lastStep - t
	for _, p in pairs(particles) do
		p:update(t, dt)
	end
	lastStep = t
end

-- particle object
local zero3 = Vector3.new()
local particle = Utilities.class({
	className = 'Particle',
	
	Color = Color3.new(1, 1, 1),
	Image = 'rbxasset://textures/particles/sparkles_main.dds',
	InitialPosition = zero3,
	InitialVelocity = zero3,
	Acceleration = Vector3.new(0, -196.2, 0),
	Lifetime = 2,
	Size = Vector2.new(1, 1),
	
}, function(self)
	self.birth = tick()
	if self.Position then
		self.InitialPosition = self.Position
	end
	if self.Velocity then
		self.InitialVelocity = self.Velocity
	end
	
--	self.gui = Utilities.Create 'ImageLabel' {
--		Name = 'particle',
--		BackgroundTransparency = 1.0,
--		Image = self.Image,
--		ImageColor3 = self:get('Color', 0),
--		Parent = Utilities.gui,
--	}
	local size = self.Size or self.MaxSize
	if type(size) == 'number' then
		size = Vector2.new(size, size)
	end
	self.gui = Utilities.Create 'Part' {
		Transparency = 1.0,
		Anchored = true,
		CanCollide = false,
		Size = Vector3.new(.2, .2, .2),
		CFrame = CFrame.new(self.InitialPosition),
		Parent = workspace,
		
		Utilities.Create 'BillboardGui' {
			Size = UDim2.new(size.X, 0, size.Y, 0),
			
			Utilities.Create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = self.Image,
				ImageRectSize = self.ImageRectSize,
				ImageRectOffset = self.ImageRectOffset,
				ImageColor3 = self:get('Color', 0),
				Size = UDim2.new(1.0, 0, 1.0, 0),
				Rotation = self.Rotation or 0,
			}
		}
	}
	
	table.insert(particles, self)
	if not pCn then
		lastStep = self.birth
		pCn = stepped:connect(onStepped)
	end
	return self
end)
function particle:get(prop, age)
	local v = self[prop]
	if type(v) == 'table' and v.isTimedProperty then
		return v:at(age)
	end
	return v
end
function particle:update(t, dt)
	local et = t-self.birth
	self.age = et
	local lifetime = self.Lifetime
	if et >= lifetime then
		self:remove()
		return
	end
	local pos = self.InitialPosition + self.InitialVelocity * et + (self.Acceleration or zero3) * et * et * .5
	self.gui.CFrame = CFrame.new(pos)
	if self.SizeIsTimedProperty then
		local size = self.Size:at(et)
		self.gui.BillboardGui.Size = UDim2.new(size, 0, size, 0)
	end
	if self.RotVelocity then
		local label = self.gui.BillboardGui.ImageLabel
		label.Rotation = label.Rotation + self.RotVelocity*dt
	end
	if self.OnUpdate then
		self.OnUpdate(et/lifetime, self.gui)
	end
--	local camP = workspace.CurrentCamera.CoordinateFrame.p
--	local hit, part = Utilities.findPartOnRayWithIgnoreFunction(Ray.new(camP, pos-camP), function(p) return p.Transparency == 1 end)
--	if part then
--		self.gui.Visible = false
--		return
--	end
	
--	local p, s, v = Utilities.extents(pos, self.Size.x)
--	if v then
--		self.gui.Visible = true
--		local y = s/self.Size.x*self.Size.y
--		self.gui.Size = UDim2.new(0.0, s, 0.0, y)
--		self.gui.Position = UDim2.new(0.0, p.x-s/2, 0.0, p.y-y/2)
--	else
--		self.gui.Visible = false
--	end
end
function particle:remove()
	for i = #particles, 1, -1 do
		if particles[i] == self then
			table.remove(particles, i)
		end
	end
	self.gui:remove()
end

-- timed property
local tProp = Utilities.class({
	className = 'TimedProperty',
	
	IsTimedProperty = true,
}, function(self)
	if type(self.Timing) == 'string' then
		self.Timing = Utilities.Timing[self.Timing](self.Lifetime)
	end
	return self
end)
function tProp:at(age)
	local alpha = age / self.Lifetime
	if self.Timing then
		alpha = self.Timing(age)
	end
	if self.Function then
		return self.Function(alpha)
	end
	if not self.StartValue or not self.EndValue then
		return self.StartValue or self.EndValue
	end
	return self.StartValue + (self.EndValue - self.StartValue)*alpha
end

-- particle library
local pLibrary = {
--	newParticle = particle.new
}
function pLibrary:new(t)
	local size = t.Size
	local sizeIsTimedProperty
	if type(size) == 'number' then
		size = Vector2.new(size, size)
	elseif type(size) == 'table' and size.IsTimedProperty then
		size.Lifetime = t.Lifetime
		sizeIsTimedProperty = true
	end
	for i = 1, (t.N or 1) do
		local v = t.InitialVelocity or t.Velocity
		local image = t.Image
		if v and t.VelocityVariation then
			local cf = CFrame.new(zero3, v)
			cf = cf * CFrame.Angles(0, 0, math.random()*math.pi*2) * CFrame.Angles(math.random()*math.rad(t.VelocityVariation), 0, 0)
			v = cf.lookVector * v.magnitude
		end
		if type(image) == 'table' then
			image = image[math.random(#image)]
		end
		if type(image) == 'number' then
			image = 'rbxassetid://'..image
		end
		local p = {
			InitialPosition = t.InitialPosition or t.Position,
			InitialVelocity = v,
			Acceleration = t.Acceleration,
			Color = t.Color,
			Image = image,
			ImageRectSize = t.ImageRectSize,
			ImageRectOffset = t.ImageRectOffset,
			MaxSize = t.MaxSize,
			Size = size,
			SizeIsTimedProperty = sizeIsTimedProperty,
			Lifetime = t.Lifetime,
			OnUpdate = t.OnUpdate,
			Rotation = t.Rotation,
			RotVelocity = t.RotVelocity
		}
		particle:new(p)
	end
end
function pLibrary:timedProperty(...)
	return tProp:new(...)
end
function pLibrary:timedColor(c1, c2)
	--
end

return pLibrary end