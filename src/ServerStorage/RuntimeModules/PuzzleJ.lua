return function(_p)
local Utilities = _p.Utilities
local MoveModel = Utilities.MoveModel

local puzzle = {
	completed = Utilities.Signal()
}

local colors = {'Medium red', 'Sand blue', 'Sand red', 'Grime'}
local animating = false
local done = false

local model, backupModel, mousecon


local function win()
	done = true
	mousecon:disconnect()
	model:remove()
	puzzle.completed:fire()
end

local function restart()
	local ch = model:GetChildren()
	if #ch > 0 then
		local main = ch[1]
		local cf = main.CFrame
		Utilities.Tween(1, nil, function(a)
			MoveModel(main, cf + Vector3.new(0, -4*a, 0))
		end)
	end
	model:remove()
	model = backupModel:Clone()
	ch = model:GetChildren()
	local main = ch[1]
	local cf = main.CFrame
	model.Parent = workspace.CurrentCamera
	Utilities.Tween(1, nil, function(a)
		MoveModel(main, cf + Vector3.new(0, -4*(1-a), 0))
	end)
end

local function ray(obj, v, tab)
	local o = (workspace:FindPartOnRayWithWhitelist(Ray.new(obj.Position, v), {model}, true))
	if o and o.Size.y == obj.Size.y then
		table.insert(tab, o)
	end
end

local function toggle(obj)
	local cf = obj.CFrame
	if obj.Size.y >= 4 then
		obj.Size = Vector3.new(2, 1, 2)
		obj.CFrame = cf + Vector3.new(0, -1.5, 0)
	else
		obj.Size = obj.Size + Vector3.new(0, 1, 0)
		obj.CFrame = cf + Vector3.new(0, 0.5, 0)
	end
	cf = obj.CFrame
	obj.BrickColor = BrickColor.new(colors[obj.Size.y])
	local downs = {}
	ray(obj, Vector3.new(-2,  0,  0), downs)
	ray(obj, Vector3.new( 2,  0,  0), downs)
	ray(obj, Vector3.new( 0,  0, -2), downs)
	ray(obj, Vector3.new( 0,  0,  2), downs)
	if #downs > 0 then
		local parts = {[obj] = cf}
		for _, p in pairs(downs) do parts[p] = p.CFrame end
		local height = obj.Size.Y
		Utilities.Tween(.5, nil, function(a)
			for p, cf in pairs(parts) do
				p.CFrame = cf + Vector3.new(0, math.sin(math.pi*a), 0)
			end
		end)
		Utilities.Tween(.5/3.14*height, nil, function(a)
			for p, cf in pairs(parts) do
				p.CFrame = cf + Vector3.new(0, -height*a, 0)
			end
		end)
		obj:remove()
		for _, d in pairs(downs) do
			d:remove()
		end
		if #model:GetChildren() == 0 then
			win()
		end
	end
end

local function MouseDown(mouse)
	if animating or not mouse.Target then return end
	if mouse.Target.Parent == model then
		animating = true
		toggle(mouse.Target)
		animating = false
	elseif mouse.Target.Parent and mouse.Target.Parent.Name == '#RestartPuzzleJ' then
		restart()
	end
end

-- API
function puzzle:init(puzzleModel)
	if done then return end
	if not backupModel then
		backupModel = puzzleModel:Clone()
	end
	model = puzzleModel
	
	local mouse = _p.player:GetMouse()
	mousecon = mouse.Button1Down:connect(function() MouseDown(mouse) end)
end


return puzzle end