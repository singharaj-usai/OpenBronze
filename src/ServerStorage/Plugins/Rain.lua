return function(_p)--local _p = require(script.Parent)
local Utilities = _p.Utilities

local create = Utilities.Create
local stepped = game:GetService('RunService').RenderStepped

local rain = {}

-- 337973384  rain       900x679
-- 389508322  sandstorm  300x225
-- 389514941  hail       650x650

function rain:start(frame, imageId, ar, velocity)
	if not ar then
		ar = 900/679
	end
	if not velocity then
		local angle = math.rad(90+15)
		velocity = Vector2.new(math.cos(angle), math.sin(angle)) * 2
	end
	local img = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		ImageTransparency = 0.1,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(ar, 0, 1.0, 0),
	}
	if imageId then
		if type(imageId) == 'number' then
			imageId = 'rbxassetid://'..imageId
		end
		img.Image = imageId
	else
		img.Image = 'rbxassetid://7107090608'
		img.ImageColor3 = Color3.new(.6, .7, 1)
	end
	local imgs = {img:Clone(),img:Clone(),img:Clone(),img:Clone()}
	local pos = Vector2.new(0.5, 0.5)
	local lastTick = tick()
	
	imgs[1].Parent = frame
	imgs[2].Parent = frame
	
	local raining = true
	Utilities.fastSpawn(function()
		while raining do
			local now = tick()
			local dt = now-lastTick
			lastTick = now
			local posX = pos.X + dt*frame.AbsoluteSize.Y*velocity.X/frame.AbsoluteSize.X
			local sx = frame.AbsoluteSize.Y*ar/frame.AbsoluteSize.X
			while posX < 0 do
				posX = posX + sx
			end
			pos = Vector2.new(posX, (pos.Y+velocity.Y*dt)%1)
			imgs[1].Position = UDim2.new(posX, 0, pos.Y-1, 0)
			imgs[2].Position = UDim2.new(posX, 0, pos.Y, 0)
			local i = 3
			local x = posX
			while x > 0 do
				x = x - sx
				if not imgs[i] then
					imgs[i] = img:Clone()
					imgs[i+1] = img:Clone()
				end
				imgs[i].Position = UDim2.new(x, 0, pos.Y-1, 0)
				imgs[i].Parent = frame
				imgs[i+1].Position = UDim2.new(x, 0, pos.Y, 0)
				imgs[i+1].Parent = frame
				i = i + 2
			end
			x = pos.X+sx
			while x < 1 do
				if not imgs[i] then
					imgs[i] = img:Clone()
					imgs[i+1] = img:Clone()
				end
				imgs[i].Position = UDim2.new(x, 0, pos.Y-1, 0)
				imgs[i].Parent = frame
				imgs[i+1].Position = UDim2.new(x, 0, pos.Y, 0)
				imgs[i+1].Parent = frame
				i = i + 2
				x = x + sx
			end
			for j = i, #imgs do
				imgs[j].Parent = nil
			end
			stepped:wait()
		end
	end)
	
	local obj = {}
	function obj:setTransparency(t)
		img.ImageTransparency = t
		for _, img in pairs(imgs) do
			img.ImageTransparency = t
		end
	end
	function obj:setColor(c)
		img.ImageColor3 = c
		for _, img in pairs(imgs) do
			img.ImageColor3 = c
		end
	end
	function obj:remove()
		raining = false
		for _, i in pairs(imgs) do
			i:remove()
		end
	end
	return obj
end


return rain end