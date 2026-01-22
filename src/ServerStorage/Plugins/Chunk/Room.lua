return function(_p, Door)
local player = game:GetService('Players').LocalPlayer
local storage = game:GetService('ReplicatedStorage')

--local _p = require(script.Parent.Parent.Parent)--storage.Plugins)
local Utilities = _p.Utilities
--local Door = require(script.Parent.Door)

local Room = Utilities.class({
	className = 'Room',
	
}, function(model, pos)
	local self = {
		model = model,
		id = model.Name,
		Entrance = model:FindFirstChild('Entrance'),
		Exit = model:FindFirstChild('Exit'),
		npcs = {},
	}
	
	local p = storage.Modelss.BlackPlate:Clone()
	p.Size = Vector3.new(999, 1, 999)
	p.CFrame = CFrame.new(pos)
	
	local base = model.Base
	Utilities.MoveModel(base, base.CFrame-base.Position+pos+Vector3.new(0, 2, 0), true)
	self.basePosition = base.Position
	p.Parent = model
	local ps = {
		base.CFrame*CFrame.new(-base.Size.x/2, 0, -base.Size.z/2),
		base.CFrame*CFrame.new( base.Size.x/2, 0, -base.Size.z/2),
		base.CFrame*CFrame.new(-base.Size.x/2, 0,  base.Size.z/2),
		base.CFrame*CFrame.new( base.Size.x/2, 0,  base.Size.z/2)
	}
	local minX, maxX = ps[1].p.x, ps[1].p.x
	for i = 2, #ps do
		minX = math.min(minX, ps[i].p.x)
		maxX = math.max(maxX, ps[i].p.x)
	end
	self.indoorCamMinX = minX + 10
	self.indoorCamMaxX = maxX - 10
	
	local doors = {}
	for _, ch in pairs(model:GetChildren()) do
		if ch.Name == 'InsideDoor' then
			local door = Door:new(ch)
			ch.Main.Touched:connect(function(p)
				if self.chunk.doorDebounce or not p or not p:IsDescendantOf(player.Character) or not p.Parent or p.Parent:IsA('Accoutrement') then return end
				if not _p.MasterControl.WalkEnabled then return end
				self.chunk.doorDebounce = true
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				spawn(function() door:open(.75) end)
				self.chunk:stackSubRoom(door.id, door)
				self.chunk.doorDebounce = false
				door:close()
			end)
			table.insert(doors, door)
		end
	end
	if #doors > 0 then
		self.doors = doors
	end
	
	return self
end)


function Room:init()
	for _, obj in pairs(self.model:GetChildren()) do
		if obj.Name == 'SubRoom' and obj:FindFirstChild('id') then
			obj.Touched:connect(function(p)
				if self.chunk.doorDebounce or not p or not p:IsDescendantOf(player.Character) or not p.Parent or p.Parent:IsA('Accoutrement') then return end
				self.chunk.doorDebounce = true
				self.chunk:stackSubRoom(obj.id.Value, obj)
				self.chunk.doorDebounce = false
			end)
		elseif obj.Name == '#Item' then
			self.chunk:hookupItem(obj)
		elseif obj:IsA'Model' and obj:FindFirstChild'Humanoid' then
			local npc = _p.NPC:new(obj)
			if not obj:FindFirstChild('NoAnimate') then npc:Animate() end
			self.npcs[obj.Name] = npc
		elseif obj.Name:match('^CaveDoor:') then
			_p.DataManager.currentChunk:hookupCaveDoor(obj, self.id)
		end
	end
	_p.NPC:collectNPCs(self.model, self.npcs)
end

function Room:getDoor(id)
	if not self.doors then return nil end
	for _, door in pairs(self.doors) do
		if door.id == id then
			return door
		end
	end
end

function Room:remove() 
		self:remove() 
	end
	
function Room:remove()
	self.chunk = nil
	if self.doors then
		for _, door in pairs(self.doors) do
			pcall(function() door:remove() end)
		end
		self.doors = nil
	end
	self.model:remove()
	self.model = nil
	for _, npc in pairs(self.npcs) do
		pcall(function() npc:remove() end)
	end
	self.npcs = nil
end


return Room end