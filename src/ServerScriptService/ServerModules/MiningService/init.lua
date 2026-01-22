print("Mining")
local _f = require(script.Parent)
local Utilities = _f.Utilities

local MAX_MINES_PER_SESSION = 17 -- based on 100 battery power & 6 energy per mine

local items, irons, fossilEggs = unpack(require(script.Items))
local toolHitPatterns = {{{0, 1, 0},{1, 2, 1},{0, 1, 0}},{{1, 2, 1},{2, 2, 2},{1, 2, 1}}}
local infiniteDives = {mrbobbilly4=true,lando64000=true,zombie7737=true,Srybon=true,MySixthSense=true,chrissuper=true}
--^ this is never used...


local BuriedObject, MiningGrid


--// public class MiningSession/MiningService //--
local mine = Utilities.class({
	className = 'MiningSession',
	
}, function(PlayerData)
	local self = {
		PlayerData = PlayerData,
--		id = Utilities.uid(),
		mineCount = 0,
	}
	return self
end)

function mine:next()
	self.mineCount = self.mineCount + 1
	local mGrid = self:generate()
	self.mGrid = mGrid
	return {
		grid = mGrid.Grid,
		objects = Utilities.map(mGrid.BuriedItems, function(bo) return bo:ToPacket() end)
	}
end

function mine:generate()
	local PlayerData = self.PlayerData
	local grid = MiningGrid:new()
	if self.mineCount > MAX_MINES_PER_SESSION then
		-- if exceeding the mine limit, place no items (just irons, lol)
		-- todo: snitch
	else
		for _ = 1, math.random(2, 4) do
			local item = BuriedObject:new(Utilities.weightedRandom(items, function(i) return i.Chance^1.2 end, function(...) return PlayerData:random(...) end))
			for _ = 1, math.random(0, 3) do
				item:Rotate()
			end
			for _ = 1, 3 do
				if grid:TryAddBuriedObject(item, Vector2.new(math.random(15-item.Size.X), math.random(11-item.Size.Y))) then break end
			end
		end
	end
	grid:GenerateGrid()
	for _ = 1, math.random(4, 6) do
		local iron = BuriedObject:new(Utilities.weightedRandom(irons, function(i) return i.Chance end))
		for _ = 1, math.random(0, 3) do
			iron:Rotate()
		end
		for _ = 1, 3 do
			if grid:TryAddBuriedObject(iron, Vector2.new(math.random(15-iron.Size.X), math.random(11-iron.Size.Y))) then break end
		end
	end
	return grid
end


function mine:remove()
	self.PlayerData = nil
end




--// private class BuriedObject //--
BuriedObject = Utilities.class({
	className = 'BuriedObject',
	
	Rotation = 0,
	Position = Vector2.new(),
	Obtained = false,
}, function(data)
	local self = {
		ItemId = data.ItemId or 'iron',
		Size = data.Size,
		OccupiedSlots = data.OccupiedSlots,
		IconSize = data.Size,
		IconPosition = data.Position
	}
	if data.IsEgg then
		self.IsEgg = true
		self.ItemId = nil
	end
	return self
end)

function BuriedObject:Overlaps(otherObject)
	if self.Position.X >= otherObject.Position.X+otherObject.Size.X or
	   self.Position.Y >= otherObject.Position.Y+otherObject.Size.Y or
	   self.Position.X+self.Size.X-1 < otherObject.Position.X or
	   self.Position.Y+self.Size.Y-1 < otherObject.Position.Y then
		return false
	end
	if not self.OccupiedSlots and not otherObject.OccupiedSlots then
		return true
	end
	for x = 1, self.Size.X do
		for y = 1, self.Size.Y do
			local px, py = self.Position.X+x-1, self.Position.Y+y-1
			if (not self.OccupiedSlots or
			    self.OccupiedSlots[y][x]) and
			   px >= otherObject.Position.X and
			   px < otherObject.Position.X+otherObject.Size.X and
			   py >= otherObject.Position.Y and
			   py < otherObject.Position.Y+otherObject.Size.Y and
			   (not otherObject.OccupiedSlots or
			    otherObject.OccupiedSlots[py-otherObject.Position.Y+1][px-otherObject.Position.X+1]) then
				return true
			end
		end
	end
	return false
end

function BuriedObject:Rotate() -- 90 deg clockwise
	self.Rotation = (self.Rotation + 1) % 4
	if self.OccupiedSlots then
		local oldSlots = self.OccupiedSlots
		local newSlots = {}
		for y = 1, self.Size.X do
			newSlots[y] = {}
			for x = 1, self.Size.Y do
				newSlots[y][x] = oldSlots[self.Size.Y+1-x][y]
			end
		end
		self.OccupiedSlots = newSlots
	end
	if self.Size.X ~= self.Size.Y then
		self.Size = Vector2.new(self.Size.Y, self.Size.X)
	end
end

function BuriedObject:ToPacket()
	return {
		size = self.Size,
		pos = self.Position,
		icon = {self.IconSize.X, self.IconSize.Y, self.IconPosition.X, self.IconPosition.Y, self.Rotation},
		iron = self.ItemId == 'iron',
		occ = self.OccupiedSlots
	}
end


--// private class MiningGrid //--
MiningGrid = Utilities.class({ -- 14x10
	className = 'MiningGrid',
	
--	Hits = 50,
--	Tool = 1,
}, function(self)
	self.Grid = {}
	self.BuriedItems = {}
	
end)

function MiningGrid:GenerateGrid()
	local difficulty = #self.BuriedItems -- todo
	for x = 1, 14 do
		if not self.Grid[x] then self.Grid[x] = {} end
		for y = 1, 10 do
			local v = math.random(3) * 2
			if (difficulty == 3 and math.random(3) == 1) or (difficulty == 4 and math.random(2) == 1) then
				v = math.min(6, v+2)
			end
			self.Grid[x][y] = v
		end
	end
	self.GridGenerated = true
end

function MiningGrid:TryAddBuriedObject(object, position)
	object.Position = position
	for _, item in pairs(self.BuriedItems) do
		if object:Overlaps(item) then
			return false
		end
	end
	table.insert(self.BuriedItems, object)
	return true
end

function MiningGrid:IsIronAt(x, y)
	for _, iron in pairs(self.BuriedItems) do
		if iron.ItemId == 'iron' then
			if x >= iron.Position.X and
			   x < iron.Position.X+iron.Size.X and
			   y >= iron.Position.Y and
			   y < iron.Position.Y+iron.Size.Y and
			   (not iron.OccupiedSlots or
			    iron.OccupiedSlots[y-iron.Position.Y+1][x-iron.Position.X+1]) then
				return true
			end
		end
	end
	return false
end

function MiningGrid:Finish(PlayerData, str)
	if self.finished then return end
	self.finished = true
	local buffer = _f.BitBuffer.Create()
	local grid = self.Grid
	-- recreate hits based on hit history
	pcall(function()
		buffer:FromBase64(str)
		local hits = 0
		while hits < 50 do
			local tool = buffer:ReadBool() and 2 or 1
			hits = hits + tool
			local hitPattern = toolHitPatterns[tool]
			local x, y = buffer:ReadUnsigned(4), buffer:ReadUnsigned(4)
			grid[x][y] = math.max(0, grid[x][y] - hitPattern[2][2])
			if grid[x][y] ~= 0 or not self:IsIronAt(x, y) then
				for ox = 1, 3 do
					for oy = 1, 3 do
						if ox ~= 2 or oy ~= 2 then
							local px, py = x-2+ox, y-2+oy
							if px >= 1 and px <= 14 and py >= 1 and py <= 10 then
								grid[px][py] = math.max(0, grid[px][py] - hitPattern[oy][ox])
							end
						end
					end
				end
			end
		end
	end)
	-- get uncovered items
	local obtainedItemNames = {}
	local eggsSentToPC = 0
	for _, item in pairs(self.BuriedItems) do
		if item.ItemId ~= 'iron' then
			local buried = false
			for x = 1, item.Size.X do
				for y = 1, item.Size.Y do
					if grid[item.Position.X-1+x][item.Position.Y-1+y] ~= 0 and (not item.OccupiedSlots or item.OccupiedSlots[y][x]) then
						buried = true
						break
					end
				end
				if buried then break end
			end
			if not buried then
				if item.IsEgg then
					obtainedItemNames['Fossilized Egg'] = (obtainedItemNames['Fossilized Egg'] or 0) + 1
					local p = PlayerData:newPokemon {
						name = Utilities.weightedRandom(fossilEggs, function(o) return o[2] end)[1],
						egg = true,
						fossilEgg = true
					}
					local nParty = #PlayerData.party
					if nParty < 6 then
						PlayerData.party[nParty+1] = p
					else
						eggsSentToPC = eggsSentToPC + 1
						PlayerData:PC_sendToStore(p)
					end
				else
					local item = _f.Database.ItemById[item.ItemId]
					obtainedItemNames[item.name] = (obtainedItemNames[item.name] or 0) + 1
					PlayerData:addBagItems({num = item.num, quantity = 1})
				end
			end
		end
	end
	-- attempt an autosave of the obtained items
	spawn(function()
		if PlayerData.lastSaveEtc then
			PlayerData:saveGame(PlayerData.lastSaveEtc)
		end
	end)
	-- create message[s] for client
	local list = {}
	local numbers = {'a ', 'two ', 'three ', 'four '}
	local vowels = {a=true,e=true,i=true,o=true,u=true}
	for itemName, quantity in pairs(obtainedItemNames) do
		table.insert(list, ((quantity==1 and vowels[itemName:sub(1,1):lower()]) and 'an ' or numbers[quantity]) .. itemName .. (quantity>1 and 's' or ''))
	end
	local msg1 = 'Obtained '
	if #list == 0 then
		msg1 = 'No items were found...'
	elseif #list == 1 then
		msg1 = msg1 .. list[1] .. '!'
	elseif #list == 2 then
		msg1 = msg1 .. list[1] .. ' and ' .. list[2] .. '!'
	else
		local last = table.remove(list)
		msg1 = msg1 .. table.concat(list, ', ') .. ', and ' .. last .. '!'
	end
	local msg2
	if eggsSentToPC == 1 then
		if obtainedItemNames['Fossilized Egg'] == 1 then
			msg2 = 'Sent the Fossilized Egg to the PC.'
		else
			msg2 = 'Sent a Fossilized Egg to the PC.'
		end
	elseif eggsSentToPC > 1 then
		if obtainedItemNames['Fossilized Egg'] == eggsSentToPC then
			msg2 = 'Sent the Fossilized Eggs to the PC.'
		else
			msg2 = 'Sent '..numbers[eggsSentToPC]..' Fossilized Eggs to the PC.'
		end
	end
	return msg1, msg2
end


return mine