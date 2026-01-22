return function(_p)
local player = game:GetService('Players').LocalPlayer

--local _p = require(script.Parent)
local Utilities = _p.Utilities
local rc4 = Utilities.rc4
local toId = Utilities.toId
local network = _p.Network
local stepped = game:GetService('RunService').RenderStepped

local storage = game:GetService('ReplicatedStorage')
local contentProvider = game:GetService('ContentProvider')

local DataManager = {
--	StuffContainer = Utilities.Create 'Folder' { Archivable = false, Parent = storage }
}
local Chunk; function DataManager:init()
	Chunk = _p.Chunk--require(script.Chunk)
end

local urlPrefix = 'rbxassetid://'

-- Loading icon
local loadingIcon = Utilities.Create 'ImageLabel' {
	BackgroundTransparency = 1.0,
	Image = 'rbxassetid://6142797850',
	ImageTransparency = 1.0,
	SizeConstraint = Enum.SizeConstraint.RelativeYY,
	Size = UDim2.new(0.15, 0, -0.15, 0),
	Position = UDim2.new(0.0, 20, 1.0, -20),
	ZIndex = 10, Parent = Utilities.frontGui,
	Visible = false,
}
local loadingTags = {}
local loadingThread
local isLoading = false
function DataManager:setLoading(tag, v)
	loadingTags[tag] = v or nil
	local thisThread = {}
	if next(loadingTags) then
		if isLoading then return end
		isLoading = true
		loadingThread = thisThread
		delay(.25, function()
			if loadingThread ~= thisThread then return end
			spawn(function()
				local r = loadingIcon.Rotation % 360
				local st = tick()
				while loadingIcon.Visible and (loadingThread == thisThread or not isLoading) do
					stepped:wait()
					loadingIcon.Rotation = (tick()-st)*250+r
				end
			end)
			loadingIcon.Visible = true
			local t = loadingIcon.ImageTransparency
			Utilities.Tween(.25, nil, function(a)
				if loadingThread ~= thisThread then return false end
				loadingIcon.ImageTransparency = t * (1-a)
			end)
		end)
	else
		isLoading = false
		loadingThread = thisThread
		spawn(function()
			local t = 1-loadingIcon.ImageTransparency
			Utilities.Tween(.25, nil, function(a)
				if loadingThread ~= thisThread then return false end
				loadingIcon.ImageTransparency = 1 - t*(1-a)
			end)
			if loadingThread == thisThread then loadingIcon.Visible = false end
		end)
	end
end



-- MAPS
do -- Night 17:50 - 06:30
	local lighting = game:GetService('Lighting')
	local function checkLighting()
		local isDay = true
		local hour, minute = string.match(lighting.TimeOfDay, '^(%d+):(%d+)')
		hour, minute = tonumber(hour), tonumber(minute)
		if hour < 6 or hour > 17 or (hour == 6 and minute <= 30) or (hour == 17 and minute >= 50) then
			isDay = false
		end
		if DataManager.isDay ~= isDay then
			DataManager.isDay = isDay
			pcall(function() DataManager.currentChunk:setDay(isDay) end)
		end
	end
	lighting.Changed:connect(checkLighting)
	checkLighting()
		local clockLockConnection, shouldBeClockTime
		function DataManager:lockClockTime(lockedTime)
			if clockLockConnection then
				self:unlockClockTime()
			end
			shouldBeClockTime = lighting.ClockTime
			lighting.ClockTime = lockedTime
			clockLockConnection = lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
				local newTime = lighting.ClockTime
				if newTime ~= lockedTime then
					shouldBeClockTime = newTime
					lighting.ClockTime = lockedTime
				end
			end)
		end
		function DataManager:unlockClockTime()
			if clockLockConnection then
				clockLockConnection:Disconnect()
				clockLockConnection = nil
				if shouldBeClockTime then
					lighting.ClockTime = shouldBeClockTime
					shouldBeClockTime = nil
				end
			end
		end
	end

	function DataManager:loadMap(id, withData)
	local chunkData
	local loadTag = {}
	self:setLoading(loadTag, true)
	local startTick = tick()
	if not self.localIndoorsOrigin then
		local cd, lio = self:request({'Chunk', id, _p.Utilities.isTouchDevice() or _p.Menu.options.reduceGraphics},{'LocalIndoorsOrigin'})
		chunkData = cd
		self.localIndoorsOrigin = lio
	else
		chunkData = self:request({'Chunk', id, _p.Utilities.isTouchDevice() or _p.Menu.options.reduceGraphics})
	end
	pcall(function() chunkData.map.Archivable = false end)
	if chunkData.grassReplication then
		local grassModel = chunkData.map:FindFirstChild('Grass') or chunkData.map
		for _, t in pairs(chunkData.grassReplication) do
			local p = t[1]
--			local rot = false
			pcall(function() -- replace old grass mesh with new grass mesh
				if p.Mesh.MeshId:match('%d+$') == '12212520' then
					p.Mesh.MeshId = 'rbxassetid://510670078'--replace grass mesh
					p.Mesh.Scale = p.Mesh.Scale / 200
					--scale 2,4,2 -> 0.01, 0.02, 0.01
--					rot = true
				end
			end)
			p.Parent = grassModel
			for i = 2, #t do
				local c = p:Clone()
				c.CFrame = t[i]--rot and (t[i] * CFrame.Angles(0, math.random()*math.pi*2, 0) * CFrame.Angles((math.random()-.5)*.05, 0, (math.random()-.5)*.05)) or t[i]
				c.Parent = grassModel
			end
		end
		chunkData.grassReplication = nil
	end
	if _p.debug then
		print(string.format('Chunk %s loaded in %.2f seconds', id, tick()-startTick))
	end
	self:setLoading(loadTag, false)
	local rq = chunkData.map.Parent
	local chunk = Chunk:new(chunkData)
	chunk:setDay(self.isDay)
	chunk.id = id
	chunk.localIndoorsOrigin = self.localIndoorsOrigin
--	if withData and withData.regionCheckDelay then chunk.regionCheckDelay = withData.regionCheckDelay end
	chunk.map.Parent = workspace
	self.currentChunk = chunk
	if chunkData.data.lighting then
		local lighting = game:GetService('Lighting')
		local restore = {}
		for prop, val in pairs(chunkData.data.lighting) do
			restore[prop] = lighting[prop]
			lighting[prop] = val
		end
		chunk.lightingRestore = restore
	end
	chunk:init(withData)
	spawn(function() self:request({'ChunkReceived', rq}) end)
	self:cleanCache()
	return chunk
end

-- Permanent Data: only saves when you hit Save but is not overwritten by New Game
--function DataManager:lookupPermanentValue(key)
--	if not self.permanentData then
--		self.permanentData = network:get('LoadPermanentData') or {}
--		self.updatedPermanentKeys = {}
--	end
--	return self.permanentData[key]
--end

--function DataManager:setPermanentValue(key, value)
--	if not self.permanentData then
--		self.permanentData = network:get('LoadPermanentData') or {}
--		self.updatedPermanentKeys = {}
--	end
--	self.permanentData[key] = value
--	self.updatedPermanentKeys[key] = value
--end

--do
--	local onSave = {}
--	function DataManager:commitPermanentKeys()
--		while #onSave > 0 do
--			Utilities.fastSpawn(function() pcall(table.remove(onSave, 1)) end)
--		end
--		if not self.updatedPermanentKeys or not next(self.updatedPermanentKeys) then return end
--		network:post('SavePermanentData', self.updatedPermanentKeys)
--		self.updatedPermanentKeys = {}
--	end
--	
--	function DataManager:OnSave(fn)
--		table.insert(onSave, fn)
--	end
--end


-- SPRITES
local cache = {}
cache.sprites = {}
function DataManager:preloadSprites(...)
	for _, sprite in pairs({...}) do
		for _, sheet in pairs(sprite.sheets) do
			self:preload(sheet.id)
		end
		if sprite.cry and sprite.cry.id then
			self:preload(sprite.cry.id)
		end
	end
end

function DataManager:queueSpritesToCache(...)
	local sprites = {...}
	spawn(function()
		local rq = {}
		for i, sprite in pairs(sprites) do
			local kind, pokemon, isFemale = unpack(sprite)
			if not cache.sprites[kind] then
				cache.sprites[kind] = {}
			end
			if isFemale then
				if not cache.sprites[kind][pokemon..'_F'] then
					local normal = cache.sprites[kind][pokemon]
					if not normal or normal.male then
							table.insert(rq, {'Spritesheets', kind, pokemon, isFemale})
					end
				end
			else
				if not cache.sprites[kind][pokemon] then
					table.insert(rq, {'Spritesheets', kind, pokemon, isFemale})
				end
			end
		end
		if #rq == 0 then return end
		local data = {self:request(unpack(rq))}
		for i, v in pairs(rq) do
			local kind, pokemon, isFemale = v[2], v[3], v[4]
			if isFemale and data[i].female then
				cache.sprites[kind][pokemon..'_F'] = data[i]
			else
				cache.sprites[kind][pokemon] = data[i]
			end
			self:preloadSprites(data[i])
		end
	end)
end

function DataManager:getSprite(kind, pokemon, isFemale)
	if not cache.sprites[kind] then
		cache.sprites[kind] = {}
	end
	local sp = cache.sprites[kind][pokemon]
	if isFemale then
		sp = cache.sprites[kind][pokemon..'_F'] or sp
		if sp and sp.male then
			sp = nil
		end
	end
	if not sp then
		local loadTag = {}
		self:setLoading(loadTag, true)
		sp = self:request({'Spritesheets', kind, pokemon, isFemale})
		if not sp then
			print('no sprite found for:', kind, pokemon, isFemale)
		end
		self:setLoading(loadTag, false)
		if isFemale and sp.female then
			cache.sprites[kind][pokemon..'_F'] = sp
		else
			cache.sprites[kind][pokemon] = sp
		end
		self:preloadSprites(sp)
	end
	return sp
end

--function DataManager:tryCacheSprite(kind, pokemon, )
--	
--end


-- MISC DATA
cache.data = {}
function DataManager:queueDataToCache(...)
	local datas = {...}
	spawn(function()
		local rq = {}
		for i, data in pairs(datas) do
			local kind, index = unpack(data)
			if not cache.data[kind] then
				cache.data[kind] = {}
			end
			if not cache.data[kind][index] then
				table.insert(rq, {kind, index})
			end
		end
		if #rq == 0 then return end
		local data = {self:request(unpack(rq))}
		for r, v in pairs(rq) do
			local kind, index = v[1], v[2]
			cache.data[kind][index] = data[r]
		end
	end)
end

function DataManager:getData(kind, index, forme)
	if not cache.data[kind] then
		cache.data[kind] = {}
	end
	local v
	if type(index) == 'number' then
		for _, d in pairs(cache.data[kind]) do
			if d.num == index and (kind ~= 'Pokedex' or not d.baseSpecies) then
				v = d
				break
			end
		end
	elseif forme then
		v = cache.data[kind][index..forme]
	else
		v = cache.data[kind][index]
	end
	if not v then
		local loadTag = {}
		self:setLoading(loadTag, true)
		v = self:request({kind, index, forme})
		if kind == 'Pokedex' and v then
			if v.id then
				v.id = rc4(v.id)
			end
--			if v.abilities then
--				for i, a in pairs(v.abilities) do
--					v.abilities[i] = rc4(a)
--				end
--			end
--			if v.hiddenAbility then
--				v.hiddenAbility = rc4(v.hiddenAbility)
--			end
			if v.forme then
				index = toId(v.species..v.forme)
			elseif forme then
				cache.data[kind][index..forme] = v
			end
		end
		self:setLoading(loadTag, false)
		if type(index) == 'number' and v and v.id then
			cache.data[kind][v.id] = v
		else
			cache.data[kind][index] = v
		end
	end
	return v
end

function DataManager:cleanCache() -- cleans with each change of chunk (should we also clean after PVP battles?)
	do return end -- OVH  this function will soon be uneccesary
	local keepSpeciesName = {}
	local keepSpeciesId = {}
	local keepMoveId = {}
	local s
	
	-- Party Pokemon
	for _, p in pairs(_p.PlayerData.party) do
		keepSpeciesName[p.name] = true
		for _, m in pairs(p.moves) do
			keepMoveId[rc4(m.id)] = true
		end
	end
	-- Wild Pokemon
	s = pcall(function()
		if not self.currentChunk or not self.currentChunk.data.regions then return end
		for _, region in pairs(self.currentChunk.data.regions) do
			for _, encounterType in pairs({'Grass', 'OldRod', 'GoodRod', 'SuperRod', 'Surf', 'PalmTree', 'PineTree', 'MiscEncounter', 'EventEncounter'}) do
				if region[encounterType] then
					for _, p in pairs(region[encounterType]) do
						keepSpeciesName[rc4(p[1])] = true
					end
				end
			end
		end
	end)
	if not s then warn('non-fatal error dm::cc - dump [w]') end
	-- Trainer Pokemon
	s = pcall(function()
		if not self.currentChunk or not self.currentChunk.data.battles then return end
		for _, trainer in pairs(self.currentChunk.data.battles) do
			for _, p in pairs(trainer.Party) do
				keepSpeciesId[rc4(p.id)] = true
			end
		end
	end)
	if not s then warn('non-fatal error dm::cc - dump [t]') end
	
	-- cache.sprites
	for _, spriteCategory in pairs(cache.sprites) do
		for id in pairs(spriteCategory) do
			local baseId = id:match('^[^%-_]+') or id
			if id == 'Porygon-Z' or id:lower() == 'ho-oh' then
				baseId = id
			end
			if not keepSpeciesName[baseId] and not keepSpeciesId[toId(baseId)] then
				spriteCategory[id] = nil
			end
		end
	end
	-- cache.data.Pokedex
	s = pcall(function()
		if not cache.data.Pokedex then return end
		for id in pairs(cache.data.Pokedex) do
--			if not keepSpeciesId[id] and not keepSpeciesName
		end
	end)
	if not s then warn('non-fatal error dm::cc - dump [p]') end
	-- cache.data.Movedex
	s = pcall(function()
		if not cache.data.Movedex then return end
		for id in pairs(cache.data.Movedex) do
			if not keepMoveId[id] then
				cache.data.Movedex[id] = nil
			end
		end
	end)
	if not s then warn('non-fatal error dm::cc - dump [m]') end
end

function DataManager:dumpCache(kind)
	cache.data[kind] = nil
end

function DataManager:getItemBundle(list)
	if not cache.data.Items then
		cache.data.Items = {}
	end
	local bundle = self:request({'ItemBundle', list})
	for _, item in pairs(bundle) do
		cache.data.Items[item.id] = item
	end
end

do
	local preloadedModules = {}
	local cachedModules = {}
	function DataManager:preloadModule(name)
		if cachedModules[name] or preloadedModules[name] then return end
		Utilities.fastSpawn(function()
			local ms = self:request({'Module', name})
--			ms.Parent = nil
			preloadedModules[name] = ms
		end)
	end
	
	function DataManager:loadModule(name)
		if cachedModules[name] then return cachedModules[name] end
		local ms
		if preloadedModules[name] then
			ms = preloadedModules[name]
			preloadedModules[name] = nil
		else
			ms = self:request({'Module', name})
		end
		ms.Parent = storage
		local m = require(ms)(_p)
		ms:remove()
		cachedModules[name] = m
		return m
	end
	
	function DataManager:getModule(name) -- only returns the module if it is loaded
		return cachedModules[name]
	end
	
	function DataManager:releaseModule(name) -- to implement
		cachedModules[name] = nil
		pcall(function() preloadedModules[name]:remove() end)
		preloadedModules[name] = nil
	end
end
	
	

-- GENERAL
function DataManager:preload(...)
	for _, id in pairs({...}) do
		if type(id) == 'number' then
			id = urlPrefix..id
		end
		contentProvider:Preload(id)
	end
end

function DataManager:request(...)
	return network:get('DataRequest', ...)
end


	function DataManager:validateChunkLocation(chunkId, position)
		-- Special case for chunk65 - redirect to chunk3's PokeCenter
		if chunkId == 'chunk65' then
			local chunk = self:loadMap('chunk64')
			local door = chunk:getDoor('C_chunk3')
			if door then
				-- Return chunk3 and position in front of PokeCenter
				return 'chunk3', (door.model.Main.CFrame * CFrame.new(5, 0, 0)).p
			end
		end

		-- Check if chunk exists
		local chunkExists = self:request({'ChunkExists', chunkId})
		if not chunkExists then
			-- If chunk doesn't exist, return nearest valid chunk
			local nearestChunk = self:request({'GetNearestChunk', chunkId})
			return nearestChunk, nil
		end

		-- Check if position is valid within chunk
		local isValidPosition = self:request({'ValidatePosition', chunkId, position})
		if not isValidPosition then
			-- Return same chunk but with nil position to trigger door/gate fallback
			return chunkId, nil
		end

		return chunkId, position
	end
	
	
return DataManager end