return function(_p)
local Utilities = _p.Utilities--require(script.Parent.Parent.Parent.Parent.Utilities)--game:GetService('ReplicatedStorage').Utilities)
local Tween = Utilities.Tween
local MoveModel = Utilities.MoveModel

local Door = Utilities.class({
	durationMultiplier = 1,
	className = 'Door',
	
}, function(model)
--	if not model:FindFirstChild('Main') then
--		local main = model.Board:Clone()
--		main.Name = 'Main'
--		main.Parent = model
--		main.Size = Vector3.new()
--		main.CFrame = model.Board.CFrame
--	end
	local self = {
		model = model,
		Position = model.Main.Position,
		CFrame = model.Main.CFrame,
		Size = model.Main.Size,
		id = model.id.Value,
		
		openFns = {},
	}
	
	local function tryConnectHingedDoor(m)
		local hinge = m:FindFirstChild('Hinge') or m:FindFirstChild('HingeCCW') or m:FindFirstChild('HingeCW')
		if not hinge then return end
		local ccw = hinge.Name~='HingeCW'
		local hingeCF = hinge.CFrame
		table.insert(self.openFns, function(_, a)
			MoveModel(hinge, hingeCF * CFrame.Angles(0, math.rad(80)*a*(ccw and 1 or -1), 0), true)
		end)
	end
	tryConnectHingedDoor(model)
	
	for _, p in pairs(model:GetChildren()) do
		if p:IsA('BasePart') then
			if p.Name:sub(1, 5):lower() == 'slide' then
				local d = p.Name:sub(6):lower()
				local dir
				if d == 'forward' or d == 'fwd' then
					dir = Vector3.new(0, 0, -1)
				elseif d == 'backwards' or d == 'backward' or d == 'back' then
					dir = Vector3.new(0, 0, 1)
				elseif d == 'right' then
					dir = Vector3.new(1, 0, 0)
				elseif d == 'left' then
					dir = Vector3.new(-1, 0, 0)
				elseif d == 'up' then
					dir = Vector3.new(0, 1, 0)
				elseif d == 'down' then
					dir = Vector3.new(0, -1, 0)
				end
				if dir then
					local cf = p.CFrame
					dir = dir * p.Size * 0.9
					table.insert(self.openFns, function(_, a)
						p.CFrame = cf * CFrame.new(dir*a)
					end)
				end
			elseif p.Name:lower() == 'pcdoorl' then
				local cf = p.CFrame
				local timerX = Utilities.Timing.easeInCubic(1)
				local timerZ = Utilities.Timing.easeInCubic(1)
				table.insert(self.openFns, function(a)
					local z = a > 0.4 and timerZ((a-0.4)/0.6)*3 or 0
					p.CFrame = cf * CFrame.new(-timerX(a)*2, 0,  z)
				end)
			elseif p.Name:lower() == 'pcdoorr' then
				local cf = p.CFrame
				local timerX = Utilities.Timing.easeInCubic(1)
				local timerZ = Utilities.Timing.easeInCubic(1)
				table.insert(self.openFns, function(a)
					local z = a > 0.4 and timerZ((a-0.4)/0.6)*3 or 0
					p.CFrame = cf * CFrame.new(-timerX(a)*2, 0, -z)
				end)
			elseif p.Name:lower() == 'drape' then
				self.durationMultiplier = .5
				local size, cf = p.Size, p.CFrame
				table.insert(self.openFns, function(_, a)
					p.Size = size * Vector3.new(1-.6*a, 1, 1)
					p.CFrame = cf * CFrame.new(2*a, 0, 0)
				end)
			end
		elseif p.Name == 'SubDoor' and p:IsA('Model') then
			tryConnectHingedDoor(p)
		end
	end
	
	return self
end)

local easeOutCubic = Utilities.Timing.easeOutCubic(1)

function Door:open(duration)
	local fns = self.openFns
	if duration then
		Tween(duration * self.durationMultiplier, nil, function(a)
			for _, fn in pairs(fns) do
				fn(a, easeOutCubic(a))
			end
		end)
	else
		for _, fn in pairs(fns) do
			fn(1, 1)
		end
	end
end

function Door:close(duration)
	local fns = self.openFns
	if duration then
		Tween(duration * self.durationMultiplier, nil, function(a)
			for _, fn in pairs(fns) do
				fn(1-a, easeOutCubic(1-a))
			end
		end)
	else
		for _, fn in pairs(fns) do
			fn(0, 0)
		end
	end
end

function Door:remove() self:remove() end
function Door:remove()
	self.model:remove()
	self.openFns = nil
end


return Door end