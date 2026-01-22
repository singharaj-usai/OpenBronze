print("BattleEngine")
--	To Do:
--	~ Substitute
--	- Me First (PVP?)
--	+ Mean Look (PVP)
--	+ Natural Cure
--		Cured status condition, but condition icon persisted
--		Did not cure current Pokemon at battle end
--	- Aegislash returning to Shield Forme still renders as Blade Forme - unable to repro
--	+ Skill Link + Double Hit
--	- Leftovers (improper message & occurs too quickly after takes damage
-- 	- Attempt capture while opponent is underground/in the air
--	+ Multi-hit move in double battle: animates hitting wrong target if retargeted
--
--	- Move priorities seem reversed (or just ignored?) when both players perform Mega Evolution on the same turn
--	+ A Protect that cancels a Dig/Fly does not reset their sprite
--	
--
--	NEEDED SECURITY UPDATES:
--   verify initial battle properties before creating
--
-- S: 10-20-15
-- C: 10-19-15
--[[========================================================================--
	
	Pokemon Brick Bronze Battle Engine
	Tate Mouser (Zexlku)
	2014-2016
	
	
	The base of Pokemon Brick Bronze's Battle Engine is a port of Pokemon
	Showdown to Roblox Lua. The Battle Client is also somewhat based on
	Pokemon Showdown's client, however is more heavily modified (since we
	are obviously working with Roblox objects instead of HTML; with major
	changes to style as well).
	
	The Battle Engine has had modifications made to it to make it more like
	the battles from the game series (adds capturing, use of items, AIs;
	allows starting battle without full HP, with a status, etc.).
	
	Pokemon Showdown's server source can be found at:
	https://github.com/Zarel/Pokemon-Showdown
	
	Note that the code for the Battle Engine has been broken up into a few
	ModuleScripts for ease of management; that is to say, (most of) the 
	ModuleScripts parented to this are under this same license as they came 
	from the same original JavaScript source file--the exception being the 
	files that I created myself (e.g. TwoPlayerSide).
	
	The license for Pokemon Showdown (server) follows:
--==========================================================================--
	
	Copyright (c) 2011-2015 Guangcong Luo and other contributors
	http://pokemonshowdown.com/
	
	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:
	
	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	
--========================================================================]]--

local _f = require(script.Parent)
--math.randomseed(tick())
local function printStackTrace() print(debug.traceback()) end
local debug = {
	calls = false,
	unexpectedEffects = false,
}

local storage = game:GetService('ServerStorage')
local undefined, null, toId, class, deepcopy, Not, filter, jsonEncode, indexOf, isArray, split, trim; do
	local util = require(storage:WaitForChild('src').BattleUtilities)
	undefined = util.undefined
	null = util.null
	toId = util.toId
	class = util.class
	deepcopy = util.deepcopy
	Not = util.Not
	filter = util.filter
	jsonEncode = util.jsonEncode
	indexOf = util.indexOf
	isArray = util.isArray
	split = util.split
	trim = util.trim
end
local uid = _f.Utilities.uid
local weightedRandom = _f.Utilities.weightedRandom

local network = _f.Network
local encounterLists, roamingEncounter; do
	local c = require(storage.Data.Chunks)
	encounterLists = c.encounterLists
	roamingEncounter = c.roamingEncounter
end


local push = table.insert
local function slice(array, s, e)
	s = s or 1
	e = e or #array
	local new = {}
	for i = s, e do
		new[i-s+1] = array[i]
	end
	return new
end

local function rshift(n, o)
	return math.floor(n / 2^o)
end

local function concat(tbl, str)
	if type(tbl) == 'table' and tbl.toString then
		return tbl:toString()
	end
	local mt = getmetatable(tbl)
	if mt and mt.__concat then
		return mt.__concat(tbl, '')
	end
	local t = {}
	for i, v in pairs(tbl) do
		if type(v) == 'table' then
			t[i] = concat(v, str)
		elseif type(v) == 'userdata' then
			t[i] = 'userdata'
		elseif v == nil then
			t[i] = 'nil'
		else
			t[i] = v
		end
	end
	return table.concat(t, str)
end

local function any(tbl, fn)
	for _, v in pairs(tbl) do
		if fn(v) then
			return true
		end
	end
	return false
end


local Battle
local BattleSide = require(script.BattleSide)
local BattlePokemon = require(script.BattlePokemon)

local TwoPlayerSide = require(script.TwoPlayerSide)
local EloManager

local Battles = {}



local BATTLE_TYPE_WILD = 0
local BATTLE_TYPE_NPC  = 1
local BATTLE_TYPE_PVP  = 2
local BATTLE_TYPE_2V2  = 3 -- PVP 2v2


-- TODO 
--  verify modifications to Effectiveness (including BattlePokemon:getEffectiveness and the onEffectiveness event)
--    (had to fix Foresight, Odor Sleuth, etc. (improperly converted onEffectiveness event))

Battle = class({
	className = 'BattleEngine',

	runAttempts = 0,
	turn = 0,
	--	p1 = nil,
	--	p2 = nil,
	lastUpdate = 0,
	weather = '',
	terrain = '',
	ended = false,
	started = false,
	active = false,
	eventDepth = 0,
	lastMove = '',
	--	activeMove = nil,
	--	activePokemon = nil,
	--	activeTarget = nil,
	midTurn = false,
	currentRequest = '',
	currentRequestDetails = '',
	rqid = 0,
	lastMoveLine = 0,
	reportPercentages = false,
	supportCancel = false,
	--	events = nil,

}, function(self, creatingPlayer) -- TODO: filter properties of self; ALSO prevent creation of multiple battles by same player
	-- legal properties:
	-- battleType, expShare, isDay, isDark, eid, rfl, gameType, npcPartner, trainerId, forcedLevel,
	--    location, chunkId, regionId, roomId, allowSpectate, battleSceneType

	--	print('spectated allowed?', self.allowSpectate)

	-- todo: remove this
	local format = 'singles'--self:getFormat(formatarg) -- in Tools

	self.log = {}
	self.sides = {null, null}
	--	self.roomid = roomid
	--	self.id = roomid
	--	self.rated = rated
	self.weatherData = {id = ''}
	self.terrainData = {id = ''}
	self.pseudoWeather = {}

	self.format = toId(format)
	self.formatData = {id = self.format}

	self.effect = {id = ''}
	self.effectData = {id = ''}
	self.event = {id = ''}

	--	print('Game Type:', self.gameType)
	self.gameType = self.gameType or 'singles'

	self.queue = {}
	self.faintQueue = {}
	--	self.messageLog = {}


	self.listeningPlayers = {}
	self.spectators = {}
	self.queriedData = {}
	self.transferDataToP1 = {}
	self.transferDataToP2 = {}
	self.transferDataToSpec = {}

	self.giveExp = {}

	self.arq_data = {}
	self.arq_count = 0

	local data = {}

	if self.expShare then
		if creatingPlayer then
			local bd = _f.PlayerDataService[creatingPlayer]:getBagDataById('expshare', 5)
			if not bd or not bd.quantity or bd.quantity <= 0 then
				self.expShare = nil
			end
		else
			self.expShare = nil
		end
	end

	-- get battle scene
	local scene
	if _f.Context == 'battle' then
		local folder = storage.Models.BattleScenes[self.gameType == 'doubles' and 'DoubleFields' or 'SingleFields']
		pcall(function() scene = folder[self.location] end)
		if scene then
			local defaultScene = folder.Default
			for _, partName in pairs({'_User', '_Foe', 'pos11', 'pos12', 'pos21', 'pos22'}) do -- todo: triples
				if not scene:FindFirstChild(partName) then
					local p = defaultScene:FindFirstChild(partName)
					if p then p:Clone().Parent = scene end
				end
			end
		else
			scene = folder.Default
		end
	else
		local chunkId, regionId, roomId = self.chunkId, self.regionId, self.roomId
		local chunkData = chunkId and _f.Database.ChunkData[chunkId]
		local regionData = chunkData and regionId and chunkData.regions and chunkData.regions[regionId]
		local roomData = chunkData and roomId and chunkData.buildings and chunkData.buildings[roomId]

		if self.battleSceneType then -- try the scene specific to this battle
			pcall(function() scene = storage.Models.BattleScenes[self.battleSceneType] end)
			if not scene then -- try the scene specific to this battle @ Day / Night
				pcall(function() scene = storage.Models.BattleScenes[self.battleSceneType..(self.isDay and 'Day' or 'Night')] end)
			end
		end
		if not scene then -- try the scene of the current room's roomdata
			pcall(function() -- seems like this is for indoors
				scene = storage.Models.BattleScenes[roomData.BattleScene] --BattleScene, or BattleSceneType??? Answer: it's BattleScene
			end)
		end
		if not scene and self.gameType == 'doubles' then -- try the chunk region scene + Double (if applic.)
			pcall(function() scene = storage.Models.BattleScenes[regionData.BattleScene..'Double'] end)
		end
		if not scene then -- try the scene of the chunk region @ Day / Night
			pcall(function() scene = storage.Models.BattleScenes[regionData.BattleScene..(self.isDay and 'Day' or 'Night')] end)
		end
		if not scene then -- try the scene of the chunk region
			pcall(function() scene = storage.Models.BattleScenes[regionData.BattleScene] end)
		end
		if not scene then -- default scene
			local defaultName = 'Route'
			if self.gameType == 'doubles' then
				defaultName = 'Double'
			end
			scene = storage.Models.BattleScenes[defaultName..(self.isDay and 'Day' or 'Night')]
		end
	end
	self.scene = scene
	if creatingPlayer then
		data.scene = scene:Clone()
		data.scene.Parent = creatingPlayer:WaitForChild('PlayerGui')
	else
		data.scene = true
	end
	--

	if self.battleType == BATTLE_TYPE_WILD and self.eid then
		-- eid = encounter id
		-- rfl = repel-forced level
		local PlayerData = _f.PlayerDataService[creatingPlayer]

		self.yieldExp = true
		self.RoPowerExpMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(1) / 2
		self.RoPowerEVMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(4)
		self.RoPowerCatchMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(6)
		--		self.startWeather = self.startWeather -- OVH  todo

		local encounterData = encounterLists[self.eid]
		-- encounters with special verification
		if encounterData.Verify and not encounterData.Verify(PlayerData) then return false end -- should it be nil-enabled?
		-- encounters associated with events
		if encounterData.PDEvent and PlayerData:completeEventServer(encounterData.PDEvent) == false then return false end
		-- encounters with weather
		if encounterData.Weather then self.startWeather = encounterData.Weather end
		-- safari battles
		--[[
		if encounterData.isSafari then 
			self.isSafari = encounterData.isSafari 
			data.isSafari = self.isSafari
			self.SBCount = PlayerData:getBagDataById("safariball", 3).quantity
			data.SBCount = self.SBCount
		end
		--]]
		-- encounters with special getters
		local pokemon
		--[[if true then -- TESTING PURPOSES; BE SURE TO DISABLE
			pokemon = PlayerData:newPokemon {
				name = 'Landorus',
				level = 40,
				moves = {
					{id='splash',pp=40},
					{id='splash',pp=1},
					{id='splash',pp=3},
					{id='splash',pp=15},
				}
			}
		else]]if encounterData.GetPokemon then
			local s, r = pcall(function() return encounterData.GetPokemon(PlayerData) end)
			if not s or not r then return false end
			pokemon = r
		else
			local encounterList = encounterData.list
			local rfl = self.rfl -- repel-forced level
			-- attempt a roaming encounter
			local roamChance = 4 -- out of 4096
			if PlayerData:ROPowers_getPowerLevel(7) >= 1 then
				roamChance = roamChance * 4
			end
			if PlayerData:ownsGamePass('RoamingCharm', true) then
				roamChance = roamChance * 2
			end
			local shinyChance = 3000 --default shiny chance (default is 4096, lower it for higher chance if kids complain enough...)
			if not encounterData.Locked and not encounterData.Verify and not encounterData.PDEvent and not encounterData.rod and PlayerData:random2(4096) <= roamChance then --roaming legend chance
				local list = {}
				for eventName, encounters in pairs(roamingEncounter) do
					if PlayerData.completedEvents[eventName] then
						for _, enc in pairs(encounters) do
							list[#list+1] = {enc[1], 40, 40, enc[2]}
						end
					end
				end
				if #list > 0 then
					encounterList = list
					rfl = nil
					data.musicId = 9537298254
					data.musicVolume = .8
				end
			--[[ Valentine's Event February 2017
			elseif not encounterData.Locked and not encounterData.Verify and not encounterData.PDEvent and not encounterData.rod and PlayerData:random2(1600) < 5 then
				local minlv, maxlv = 100, 1
				for _, enc in pairs(encounterList) do
					minlv = math.min(minlv, enc[2])
					maxlv = math.max(maxlv, enc[3])
				end
				encounterList = {{'Pikachu', minlv, maxlv, 1, nil, nil, 'heart'}}
				rfl = nil
				shinyChance = shinyChance / 4 --]]
			end
			--
			if rfl then
				local modifiedEncounter = {}
				for _, entry in pairs(encounterList) do
					if entry[2] <= rfl and entry[3] >= rfl and (not entry[5] or (entry[5] == 'day' and self.isDay) or (entry[5] == 'night' and not self.isDay)) then
						modifiedEncounter[#modifiedEncounter+1] = entry
					end
				end
				if #modifiedEncounter > 0 then -- defaults to normal random encounter in case something went wrong
					encounterList = modifiedEncounter
				end
			end
			local foe = weightedRandom(encounterList, function(p)
				if p[5] == 'day'   and not self.isDay then return 0 end
				if p[5] == 'night' and     self.isDay then return 0 end
				return p[4]
			end)

			if encounterData.rod then
				shinyChance = math.floor(4096 * math.max(.025, math.cos(math.min(PlayerData.fishingStreak, 100)/100*math.pi/2)))
				PlayerData.fishingStreak = PlayerData.fishingStreak + 1
			end
			--old
			--[[
			if foe[6] == false then -- forces NOT shiny
				shinyChance = nil
			end
			local foeData = {
				name = foe[1],
				level = (rfl and foe[2] <= rfl and foe[3] >= rfl) and rfl or math.random(foe[2], foe[3]),
				shinyChance = shinyChance,
				-- [6] = forced shiny
				forme = foe[7]
			}
			--]]
			--if foe[6] == false then -- forces NOT shiny
			--shinyChance = nil
			--end
			--[[
			if type(foe[8]) == 'table' then
				if not foe[8]['chance'] <= math.random(1,100) then foe[8]['item'] = nil end
			end --Does % calc otherwise 100%
--]]
			if foe[6] == false then -- forces NOT shiny
				shinyChance = nil
			end

			local isshiny = nil
			if foe[6] == true then -- forces shiny
				shinyChance = nil
				isshiny = true
			end

			if not foe[3] then foe[3] = foe[2]; end;

			local firstNonEgg = PlayerData:getFirstNonEgg()

			local random
			if foe[8] and foe[9] then
				local rate = foe[9]
				if firstNonEgg:getAbilityName() == 'Compound Eyes' then
					if foe[8] and rate == 20 then
						rate = 5
					elseif foe[8] and rate == 2 then
						rate = 1.6666666666667
					end
				end
				if rate == 1.6666666666667 then
					local newrate = 2
					local newrandom = (math.random(10) == 1)
					if newrandom then
						newrate = 1
					end
					random = (math.random(newrate) == 1)
				else
					random = (math.random(rate) == 1)
				end
			end

			local random1
			if foe[10] and foe[11] then
				local rate1 = foe[11]
				if firstNonEgg:getAbilityName() == 'Compound Eyes' then
					if foe[10] and rate1 == 20 then
						rate1 = 5
					elseif foe[10] and rate1 == 2 then
						rate1 = 1.6666666666667
					end
				end
				if rate1 == 1.6666666666667 then
					local newrate1 = 2
					local newrandom1 = (math.random(10) == 1)
					if newrandom1 then
						newrate1 = 1
					end
					random1 = (math.random(newrate1) == 1)
				else
					random1 = (math.random(rate1) == 1)
				end
			end

			if type(foe[8]) == 'table' then
				if not ((math.random(1,100)<=foe[8]['chance'])) then 
					foe[8] = nil
				else
					foe[8] = foe[8]['item'] 
				end
			end --Does % calc otherwise 100%
			local foeData = {
				name = foe[1],
				level = (rfl and foe[2] <= rfl and foe[3] >= rfl) and rfl or math.random(foe[2], foe[3]),
				shinyChance = shinyChance,
				-- [6] = forced shiny
				forme = foe[7],
				item = foe[8],
			}


			if foeData.name == 'Sceptile' and foeData.forme == 'christmas' then --// 2022 Winter Event
				foeData.shinyChance = foeData.shinyChance / 4
			end
			if foeData.name == 'Basculin' then
				foeData.forme = weightedRandom({{50, nil}, {50, 'Blue-Striped'}}, function(o) return o[1] end)[2]
			elseif foeData.name == 'Minior' then
				foeData.forme = weightedRandom({{200, 'Red'}, {200, 'Orange'}, {200, 'Yellow'}, {200, 'Green'}, {200, 'Blue'}, {200, 'Indigo'}, {200, 'Violet'}}, function(o) return o[1] end)[2]
			elseif foeData.name == 'Pumpkaboo' or foeData.name == 'Gourgeist' then
				foeData.forme = weightedRandom({{30, 's'}, {50, nil}, {15, 'L'}, {5, 'S'}}, function(o) return o[1] end)[2]
			elseif foeData.name == 'Flabebe' or foeData.name == 'Floette' or foeData.name == 'Florges' then
				foeData.forme = weightedRandom({{40, nil}, {30, 'o'}, {20, 'y'}, {9, 'w'}, {6, 'b'}}, function(o) return o[1] end)[2]
			elseif foeData.name == 'Unown' then
				local forme
				local r = PlayerData:random(54)
				if r == 53 then
					forme = 'exclaim'
				elseif r == 54 then
					forme = 'query'
				else
					forme = string.char(96+math.ceil(r/2))
					if forme == 'a' then forme = nil end
				end
				foeData.forme = forme
			end

			pokemon = _f.ServerP:new(foeData, PlayerData)
			if pokemon.shiny then
				PlayerData:resetFishStreak()
			end

			local rngFactorRoam = 1500
			local haChance = 512

			local haMultiplier = 1
			if haMultiplier then
				haChance /= haMultiplier
			end

			local currentChain = PlayerData.captureChain.chain

			if currentChain >= 17 then
				rngFactorRoam = math.floor(rngFactorRoam * math.max(.025, math.cos(math.min(currentChain, 1000)/200*math.pi/2)))
				haChance = math.floor(haChance * math.max(.025, math.cos(math.min(currentChain, 1000)/200*math.pi/2)))--math.ceil(haChance/(currentChain/17)) 
				if haChance <= 25 then
					haChance = 25
				end
				if rngFactorRoam <= roamChance+25 then
					rngFactorRoam = roamChance+25
				end
			end



			if PlayerData:ownsGamePass('AbilityCharm', true) and pokemon.data.hiddenAbility and PlayerData:random2(512) == 69 then
				pokemon.hiddenAbility = true
			end
			if firstNonEgg:getAbilityName() == 'Synchronize' and math.random(2)==1 then
				pokemon.nature = firstNonEgg.nature
			end
		end


		--[[
		if pokemon and (pokemon.hiddenAbility or pokemon.shiny) then
			_f.Logger:logEncounter(PlayerData.player, {
				details = {
					name = pokemon.name,
					level = pokemon.level,
				--	forme = pokemon.forme,
					shiny = pokemon.shiny,
					hiddenAbility = pokemon.hiddenAbility,
				},
				data = {
					gamemode = PlayerData.gamemode,
					chain = (PlayerData.captureChain.chain >= 10 and PlayerData.captureChain.chain or '<10'),
				},
			})
		end  
		--]]

		self.alreadyOwnsFoeSpecies = PlayerData:hasOwnedPokemon(pokemon.num)
		PlayerData:onSeePokemon(pokemon.num)

		self.wildFoePokemon = pokemon

		self:join(nil, 2, '#Wild', {pokemon:getBattleData()})--player, slot, name, team, megaadornment
	elseif self.battleType == BATTLE_TYPE_NPC then
		local PlayerData = _f.PlayerDataService[creatingPlayer]

		self.yieldExp = true
		self.isTrainer = true
		--self.battleMode = PlayerData.battleMode

		self.RoPowerMoneyMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(3)
		self.RoPowerExpMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(1) / 2
		self.RoPowerEVMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(4)
		--		self.startWeather = self.startWeather -- OVH  todo

		-- OVH  todo: verify they haven't already fought this trainer, or that the trainer is rematchable
		local trainerId = tonumber(self.trainerId)
		local trainer = _f.Database:getBattle(trainerId)
		trainer.id = trainerId
		self.npcTrainerData = trainer
		if trainer.Weather then
			self.startWeather = trainer.Weather
		end
		--		print 'PARTY'; require(game.ServerStorage.Utilities).print_r(trainer.Party)
		self:join('npc', 2, trainer.Name, trainer.Party)
	elseif self.battleType == BATTLE_TYPE_PVP then
		self.pvp = true
	elseif self.battleType == BATTLE_TYPE_2V2 then

		self.is2v2 = true

	else
		error('unknown battle structure')
	end


	-- Get a unique ID
	local id
	repeat
		id = uid()
	until not Battles[id]
	self.id = id
	self.roomid = id

	Battles[id] = self

	self.createdAt = tick()


	data.battleId = id
	self.creationData = data

	return self
end)


function Battle:toString()
	return 'Battle: ' .. self.format
end
function Battle:call(fn, ...)
	if type(fn) ~= 'function' then
		error('attempt to call ('..type(fn)..') as Battle', 2)
	end
	return self:callAs(self, fn, ...)
end
function Battle:callAs(obj, fn, ...)-- pseudo-: call syntax
	if type(fn) ~= 'function' then
		error('attempt to call ('..type(fn)..') as (?object)', 2)
	end
	local selfBeforeCall = getfenv(fn)['self']
	getfenv(fn)['self'] = obj
	local result = fn(...)
	getfenv(fn)['self'] = selfBeforeCall
	return result
end
function Battle:setWeather(status, source, sourceEffect)
	status = self:getEffect(status)
	--	print('weather ->', status.id)
	if sourceEffect == nil and self.effect then sourceEffect = self.effect end
	if source == nil and self.event and self.event.target then source = self.event.target end

	if self.weather == status.id then return false end
	if status.id then
		local result = self:runEvent('SetWeather', source, source, status)
		if Not(result) then
			if result == false then
				if sourceEffect and sourceEffect.weather then
					self:add('-fail', source, sourceEffect, '[from] ' .. self.weather)
				elseif sourceEffect and sourceEffect.effectType == 'Ability' then
					self:add('-ability', source, sourceEffect, '[from] ' .. self.weather, '[fail]')
				end
			end
			return null
		end
	end
	if self.weather and not status.id then
		local oldstatus = self:getWeather()
		self:singleEvent('End', oldstatus, self.weatherData, self)
	end
	local prevWeather = self.weather
	local prevWeatherData = self.weatherData
	self.weather = status.id
	self.weatherData = {id = status.id}
	if source then
		self.weatherData.source = source
		self.weatherData.sourcePosition = source.position
	end
	if status.duration then
		self.weatherData.duration = status.duration
	end
	if status.durationCallback then
		self.weatherData.duration = self:call(status.durationCallback, source, sourceEffect)
	end
	if Not(self:singleEvent('Start', status, self.weatherData, self, source, sourceEffect)) then
		self.weather = prevWeather
		self.weatherData = prevWeatherData
		return false
	end
	self:update()
	return true
end
function Battle:clearWeather()
	return self:setWeather('')
end
function Battle:effectiveWeather(target)
	if self.event and not target then
		target = self.event.target
	end
	if self:suppressingWeather() then return '' end
	return self.weather
end
function Battle:isWeather(weather, target)
	local ourWeather = self:effectiveWeather(target)
	if type(weather) == "table" then
		for _, w in pairs(weather) do
			if ourWeather == toId(w) then return true end
		end
		return false
	end
	return ourWeather == toId(weather)
end
function Battle:getWeather()
	return self:getEffect(self.weather)
end
function Battle:setTerrain(status, source, sourceEffect)
	status = self:getEffect(status)
	if sourceEffect == undefined and self.effect then sourceEffect = self.effect end
	if source == undefined and self.event and self.event.target then source = self.event.target end

	if self.terrain == status.id then return false end
	if self.terrain and not status.id then
		local oldstatus = self:getTerrain()
		self:singleEvent('End', oldstatus, self.terrainData, self)
	end
	local prevTerrain = self.terrain
	local prevTerrainData = self.terrainData
	self.terrain = status.id
	self.terrainData = {id = status.id}
	if source then
		self.terrainData.source = source
		self.terrainData.sourcePosition = source.position
	end
	if status.duration then
		self.terrainData.duration = status.duration
	end
	if status.durationCallback then
		self.terrainData.duration = self:call(status.durationCallback, source, sourceEffect)
	end
	if Not(self:singleEvent('Start', status, self.terrainData, self, source, sourceEffect)) then
		self.terrain = prevTerrain
		self.terrainData = prevTerrainData
		return false
	end
	self:update()
	return true
end
function Battle:clearTerrain()
	return self:setTerrain('')
end
function Battle:effectiveTerrain(target)
	if self.event and not target then target = self.event.target end
	if Not(self:runEvent('TryTerrain', target)) then return '' end
	return self.terrain
end
function Battle:isTerrain(terrain, target)
	local ourTerrain = self:effectiveTerrain(target)
	if type(terrain) == "table" then
		for _, t in pairs(terrain) do
			if ourTerrain == toId(t) then return true end
		end
		return false
	end
	return ourTerrain == toId(terrain)
end
function Battle:getTerrain()
	return self:getEffect(self.terrain)
end
function Battle:getFormat()
	return self:getEffect(self.format)
end
function Battle:addPseudoWeather(status, source, sourceEffect)
	status = self:getEffect(status)
	if self.pseudoWeather[status.id] then
		if not status.onRestart then return false end
		return self:singleEvent('Restart', status, self.pseudoWeather[status.id], self, source, sourceEffect)
	end
	self.pseudoWeather[status.id] = {id = status.id}
	if source then
		self.pseudoWeather[status.id].source = source
		self.pseudoWeather[status.id].sourcePosition = source.position
	end
	if status.duration then
		self.pseudoWeather[status.id].duration = status.duration
	end
	if status.durationCallback then
		self.pseudoWeather[status.id].duration = self:call(status.durationCallback, source, sourceEffect)
	end
	if Not(self:singleEvent('Start', status, self.pseudoWeather[status.id], self, source, sourceEffect)) then
		self.pseudoWeather[status.id] = nil
		return false
	end
	self:update()
	return true
end
function Battle:getPseudoWeather(status)
	status = self:getEffect(status)
	if not self.pseudoWeather[status.id] then return nil end --return null end
	return status
end
function Battle:removePseudoWeather(status)
	status = self:getEffect(status)
	if not self.pseudoWeather[status.id] then return false end
	self:singleEvent('End', status, self.pseudoWeather[status.id], self)
	self.pseudoWeather[status.id] = nil
	self:update()
	return true
end
function Battle:suppressingAttackEvents()
	return self.activePokemon and self.activePokemon.isActive and not self.activePokemon:ignoringAbility() and self.activePokemon:getAbility().stopAttackEvents
end
function Battle:suppressingWeather()
	for _, side in pairs(self.sides) do
		for _, pokemon in pairs(side.active) do
			if pokemon ~= null and not pokemon:ignoringAbility() and pokemon:getAbility().suppressWeather then
				return true
			end
		end
	end
	return false
end
function Battle:setActiveMove(move, pokemon, target)
	--	if not move then move = null end
	--	if not pokemon then pokemon = null end
	if not target then target = pokemon end
	self.activeMove = move
	self.activePokemon = pokemon
	self.activeTarget = target

	-- Mold Breaker and the like
	self:update()
end
function Battle:clearActiveMove(failed)
	if self.activeMove then
		if not failed then
			self.lastMove = self.activeMove.id
		end
		self.activeMove = nil
		self.activePokemon = nil
		self.activeTarget = nil

		-- Mold Breaker and the like, again
		self:update()
	end
end
function Battle:update()
	for _, a in pairs(self.p1.active) do
		if a ~= null then a:update() end
	end
	for _, a in pairs(self.p2.active) do
		if a ~= null then a:update() end
	end
end

function Battle.comparePriority(a, b)
	if b == nil then return true end
	if a == nil then return false end

	a.priority = a.priority or 0
	a.subPriority = a.subPriority or 0
	a.speed = a.speed or 0

	b.priority = b.priority or 0
	b.subPriority = b.subPriority or 0
	b.speed = b.speed or 0

	if (type(a.order) == 'number' or type(b.order == 'number')) and a.order ~= b.order then
		if type(a.order) ~= 'number' then
			return true
		elseif type(b.order) ~= 'number' then
			return false
		end
		return a.order < b.order
	end
	if a.priority ~= b.priority then
		return a.priority > b.priority
	end
	if a.speed ~= b.speed then
		return a.speed > b.speed
	end
	if a.subOrder ~= b.subOrder then
		return a.subOrder < b.subOrder
	end
	return math.random() < 0.5
end

function Battle:sortByPriority(t, sortFn)
	-- ok so we cheat here by forcing comp(a, b) == not comp(b, a) using a cache
	-- I do this because Lua keeps throwing an "invalid order function for sorting" error randomly
	-- (probably due to the random at the end of the compare function)
	-- so yeah, why not...
	local cache = {}
	sortFn = sortFn or self.comparePriority
	table.sort(t, function(a, b) -- a, b are tables -> tostring(a) == 'table: 0xXXXXXXXX' (none contain a __tostring metamethod, do they?)
		local aHash = tostring(a)
		local bHash = tostring(b)
		if not cache[aHash] then cache[aHash] = {} end
		if not cache[bHash] then cache[bHash] = {} end
		local ab = cache[aHash][bHash]
		if ab ~= nil then return ab end
		local ba = cache[bHash][aHash]
		if ba ~= nil then return not ba end
		ab = sortFn(a, b)
		cache[aHash][bHash] = ab
		return ab
	end)
end
function Battle:getResidual(thing, callbackType)
	local statuses = self:getRelevantEffectsInner(thing or self, callbackType or 'residualCallback', nil, nil, false, true, 'duration')
	self:sortByPriority(statuses)
	--if statuses[1] then self:debug('match ' .. (callbackType or 'residualCallback') .. ': ' .. statuses[1].status.id)
	return statuses
end
function Battle:eachEvent(eventid, effect, relayVar)
	local actives = {}
	if not effect and self.effect then effect = self.effect end
	for _, side in pairs(self.sides) do
		for _, active in pairs(side.active) do
			if active ~= null then table.insert(actives, active) end
		end
	end
	self:sortByPriority(actives, function(a, b)
		if b == nil then return true end
		if a == nil then return false end
		if a.speed ~= b.speed then
			return a.speed > b.speed
		end
		return math.random() < 0.5
	end)
	for _, active in pairs(actives) do
		if active.isStarted then
			self:runEvent(eventid, active, nil, effect, relayVar)
		end
	end
end
function Battle:residualEvent(eventid, relayVar)
	local statuses = self:getRelevantEffectsInner(self, 'on' .. eventid, nil, nil, false, true, 'duration')
	self:sortByPriority(statuses)
	while #statuses > 0 do
		local statusObj = table.remove(statuses, 1)
		local status = statusObj.status
		if not statusObj.thing.fainted then
			local fire = true
			if statusObj.statusData and statusObj.statusData.duration and statusObj.statusData.duration > 0 then
				statusObj.statusData.duration = statusObj.statusData.duration - 1
				if statusObj.statusData.duration == 0 and statusObj["end"] then
					local endFn = statusObj["end"]
					local mcall = true
					local thing = statusObj.thing
					if thing then
						local originalThing = thing
						local function try(thing)
							for _, v in pairs(thing) do
								if v == endFn then
									v(originalThing, status.id)
									mcall = false
									break
								end
							end
							if mcall then
								pcall(function()
									for _, v in pairs(getmetatable(thing).__index) do
										if v == endFn then
											v(originalThing, status.id)
											mcall = false
											break
										end
									end
								end)
							end
						end
						local thing = thing
						try(thing)
						while mcall and thing.super do
							thing = thing.super
							try(thing)
						end
					end
					if mcall then
						self:callAs(thing, endFn, status.id)
					end
					fire = false
				end
			end
			if fire then
				self:singleEvent(eventid, status, statusObj.statusData, statusObj.thing, relayVar)
			end
		end
	end
end
-- The entire event system revolves around this function
-- (and its helper functions, getRelevant * )
function Battle:singleEvent(eventid, effect, effectData, target, source, sourceEffect, relayVar) 
	if self.eventDepth >= 8 then
		-- aw man
		self:add('message', 'error: STACK LIMIT EXCEEDED')
		--		self:add('message', 'PLEASE REPORT IN BUG THREAD')
		--		self:add('message', 'Event: ' .. eventid)
		--		self:add('message', 'Parent event: ' .. self.event.id)
		error('Stack overflow')
	end
--[[
	if self.isSafari and effect.effectType == 'Ability' then -- ignore abilities in safari battle
		return
	end
	--]]
	--self:add('Event: ' .. eventid .. ' (depth ' .. self.eventDepth .. ')')
	effect = self:getEffect(effect)
	local hasRelayVar = true
	if relayVar == undefined or relayVar == nil then
		relayVar = true
		hasRelayVar = false
	end

	if effect.effectType == 'Status' and target.status ~= effect.id then
		-- it's changed; call it off
		return relayVar
	end
	local targetIsInstanceOfBattlePokemon = (type(target) == 'table' and  target.__isBattlePokemon) and true or false
	if eventid ~= 'Start' and eventid ~= 'TakeItem' and effect.effectType == 'Item' and targetIsInstanceOfBattlePokemon and target:ignoringItem() then
		self:debug(eventid .. ' handler suppressed by Embargo, Klutz or Magic Room')
		return relayVar
	end
	if eventid ~= 'End' and effect.effectType == 'Ability' and targetIsInstanceOfBattlePokemon and target:ignoringAbility() then
		-- INVESTIGATE: event suppressed by pokemon whose isActive = false (instead of Gastro Acid)
		self:debug(eventid .. ' handler suppressed by Gastro Acid [singleEvent]')
		return relayVar
	end
	if effect.effectType == 'Weather' and eventid ~= 'Start' and eventid ~= 'Residual' and eventid ~= 'End' and self:suppressingWeather() then
		self:debug(eventid .. ' handler suppressed by Air Lock')
		return relayVar
	end

	if effect['on' .. eventid] == nil then return relayVar end
	local parentEffect = self.effect
	local parentEffectData = self.effectData
	local parentEvent = self.event
	self.effect = effect
	self.effectData = effectData
	self.event = {id = eventid, target = target, source = source, effect = sourceEffect}
	self.eventDepth = self.eventDepth + 1
	local args = {target, source, sourceEffect}
	if hasRelayVar then table.insert(args, 1, relayVar) end
	local returnVal = undefined
	if type(effect['on' .. eventid]) == 'function' then
		returnVal = self:call(effect['on' .. eventid], unpack(args))
	else
		returnVal = effect['on' .. eventid]
	end
	self.eventDepth = self.eventDepth - 1
	self.effect = parentEffect
	self.effectData = parentEffectData
	self.event = parentEvent
	if returnVal == undefined or returnVal == nil then return relayVar end
	return returnVal
end
--[[
 * runEvent is the core of Pokemon Showdown's event system.
 *
 * Basic usage
 * ===========
 *
 *   self:runEvent('Blah')
 * will trigger any onBlah global event handlers.
 *
 *   self:runEvent('Blah', target)
 * will additionally trigger any onBlah handlers on the target, onAllyBlah
 * handlers on any active pokemon on the target's team, and onFoeBlah
 * handlers on any active pokemon on the target's foe's team
 *
 *   self:runEvent('Blah', target, source)
 * will additionally trigger any onSourceBlah handlers on the source
 *
 *   self:runEvent('Blah', target, source, effect)
 * will additionally pass the effect onto all event handlers triggered
 *
 *   self:runEvent('Blah', target, source, effect, relayVar)
 * will additionally pass the relayVar as the first argument along all event
 * handlers
 *
 * You may leave any of these null. For instance, if you have a relayVar but
 * no source or effect:
 *   self:runEvent('Damage', target, null, null, 50)
 *
 * Event handlers
 * ==============
 *
 * Items, abilities, statuses, and other effects like SR, confusion, weather,
 * or Trick Room can have event handlers. Event handlers are functions that
 * can modify what happens during an event.
 *
 * event handlers are passed:
 *   function(target, source, effect)
 * although some of these can be blank.
 *
 * certain events have a relay variable, in which case they're passed:
 *   function(relayVar, target, source, effect)
 *
 * Relay variables are variables that give additional information about the
 * event. For instance, the damage event has a relayVar which is the amount
 * of damage dealt.
 *
 * If a relay variable isn't passed to runEvent, there will still be a secret
 * relayVar defaulting to `true`, but it won't get passed to any event
 * handlers.
 *
 * After an event handler is run, its return value helps determine what
 * happens next:
 * 1. If the return value isn't `undefined`, relayVar is set to the return
 *	value
 * 2. If relayVar is falsy, no more event handlers are run
 * 3. Otherwise, if there are more event handlers, the next one is run and
 *	we go back to step 1.
 * 4. Once all event handlers are run (or one of them results in a falsy
 *	relayVar), relayVar is returned by runEvent
 *
 * As a shortcut, an event handler that isn't a function will be interpreted
 * as a function that returns that value.
 *
 * You can have return values mean whatever you like, but in general, we
 * follow the convention that returning `false` or `null` means
 * stopping or interrupting the event.
 *
 * For instance, returning `false` from a TrySetStatus handler means that
 * the pokemon doesn't get statused.
 *
 * If a failed event usually results in a message like "But it failed!"
 * or "It had no effect!", returning `null` will suppress that message and
 * returning `false` will display it. Returning `null` is useful if your
 * event handler already gave its own custom failure message.
 *
 * Returning `undefined` means "don't change anything" or "keep going".
 * A function that does nothing but return `undefined` is the equivalent
 * of not having an event handler at all.
 *
 * Returning a value means that that value is the new `relayVar`. For
 * instance, if a Damage event handler returns 50, the damage event
 * will deal 50 damage instead of whatever it was going to deal before.
 *
 * Useful values
 * =============
 *
 * In addition to all the methods and attributes of Tools, Battle, and
 * Scripts, event handlers have some additional values they can access:
 *
 * self.effect:
 *   the Effect having the event handler
 * self.effectData:
 *   the data store associated with the above Effect. this is a plain Object
 *   and you can use it to store data for later event handlers.
 * self.effectData.target:
 *   the Pokemon, Side, or Battle that the event handler's effect was
 *   attached to.
 * self.event.id:
 *   the event ID
 * self.event.target, self.event.source, self.event.effect:
 *   the target, source, and effect of the event. These are the same
 *   variables that are passed as arguments to the event handler, but
 *   they're useful for functions called by the event handler.
--]]
function Battle:runEvent(eventid, target, source, effect, relayVar, onEffect)
	if self.eventDepth >= 8 then
		-- aw man
		self:add('message', 'error: STACK LIMIT EXCEEDED')
		--		self:add('message', 'PLEASE REPORT IN BUG THREAD')
		--		self:add('message', 'Event: ' .. eventid)
		--		self:add('message', 'Parent event: ' .. self.event.id)
		error("Stack overflow")
	end
	if not target then target = self end
	local statuses = self:getRelevantEffects(target, 'on' .. eventid, 'onSource' .. eventid, source)
	local hasRelayVar = true
	effect = self:getEffect(effect)
	local args = {target, source, effect}
	--plugins.console.log('Event: ' .. eventid .. ' (depth ' .. self.eventDepth .. ') t:' .. target.id .. ' s:' .. (source or source.id) .. ' e:' .. effect.id)
	if relayVar == undefined or relayVar == nil or relayVar == null then
		relayVar = true
		hasRelayVar = false
	else
		table.insert(args, 1, relayVar)
	end

	local parentEvent = self.event
	self.event = {id = eventid, target = target, source = source, effect = effect, modifier = 1}
	self.eventDepth = self.eventDepth + 1

	if onEffect and effect['on' .. eventid] then
		table.insert(statuses, 1, {status = effect, callback = effect['on' .. eventid], statusData = {}, ["end"] = nil, thing = target})
	end
	for i, s in pairs(statuses) do
		local breakAll = false
		for _=1,1 do -- just so 'break' leads to next status iteration instead of exiting the loop (pseudo-javascript-continue syntax)
			local status = s.status
			local thing = s.thing
			--self:debug('match ' .. eventid .. ': ' .. status.id .. ' ' .. status.effectType)
			if status.effectType == 'Status' and thing.status ~= status.id then
				-- it's changed; call it off
				break
			end
			if status.effectType == 'Ability' and self:suppressingAttackEvents() and self.activePokemon ~= thing then
				-- ignore attacking events
				local AttackingEvents = {
					BeforeMove = true,
					BasePower = true,
					Immunity = true,
					Accuracy = true,
					RedirectTarget = true,
					Heal = true,
					SetStatus = true,
					CriticalHit = true,
					ModifyPokemon = true,
					ModifyAtk = true, ModifyDef = true, ModifySpA = true, ModifySpD = true, ModifySpe = true,
					ModifyBoost = true,
					ModifyDamage = true,
					ModifySecondaries = true,
					ModifyWeight = true,
					TryHit = true,
					TryHitSide = true,
					TryMove = true,
					Hit = true,
					Boost = true,
					DragOut = true
				}
				if AttackingEvents[eventid] then
					if eventid ~= 'ModifyPokemon' then
						self:debug(eventid .. ' handler suppressed by Mold Breaker')
					end
					break
				elseif eventid == 'Damage' and effect and effect.effectType == 'Move' then
					self:debug(eventid .. ' handler suppressed by Mold Breaker')
					break
				end
			end
			local thingIsInstanceOfBattlePokemon = (type(thing) == 'table' and thing.__isBattlePokemon) and true or false
			if eventid ~= 'Start' and eventid ~= 'TakeItem' and status.effectType == 'Item' and thingIsInstanceOfBattlePokemon and thing:ignoringItem() then
				if eventid ~= 'ModifyPokemon' and eventid ~= 'Update' then
					self:debug(eventid .. ' handler suppressed by Embargo, Klutz or Magic Room')
				end
				break
			elseif eventid ~= 'End' and status.effectType == 'Ability' and thingIsInstanceOfBattlePokemon and thing:ignoringAbility() then
				if eventid ~= 'ModifyPokemon' and eventid ~= 'Update' then
					self:debug(eventid .. ' handler suppressed by Gastro Acid [runEvent]')
				end
				break
			end
			if (status.effectType == 'Weather' or eventid == 'Weather') and eventid ~= 'Residual' and eventid ~= 'End' and self:suppressingWeather() then
				self:debug(eventid .. ' handler suppressed by Air Lock')
				break
			end
			local returnVal
			if type(s.callback) == 'function' then
				local parentEffect = self.effect
				local parentEffectData = self.effectData
				self.effect = status
				self.effectData = s.statusData
				self.effectData.target = thing

				returnVal = self:call(statuses[i].callback, unpack(args))

				self.effect = parentEffect
				self.effectData = parentEffectData
			else
				returnVal = s.callback
			end

			if returnVal ~= undefined and returnVal ~= nil then
				relayVar = returnVal
				if Not(relayVar) then
					breakAll = true
					break
				end
				if hasRelayVar then
					args[1] = relayVar
				end
			end
		end
		if breakAll then break end
	end

	self.eventDepth = self.eventDepth - 1
	if self.event.modifier ~= 1 and type(relayVar) == 'number' then
		-- self:debug(eventid .. ' modifier: 0x' .. ('0000' .. (self.event.modifier * 4096).toString(16)).slice(-4):upper())
		relayVar = self:modify(relayVar, self.event.modifier)
	end
	self.event = parentEvent

	return relayVar
end
function Battle:resolveLastPriority(statuses, callbackType)
	local order = false
	local priority = 0
	local subOrder = 0
	local status = statuses[#statuses]
	if status.status[callbackType .. 'Order'] then
		order = status.status[callbackType .. 'Order']
	end
	if status.status[callbackType .. 'Priority'] then
		priority = status.status[callbackType .. 'Priority']
	elseif status.status[callbackType .. 'SubOrder'] then
		subOrder = status.status[callbackType .. 'SubOrder']
	end

	status.order = order
	status.priority = priority
	status.subOrder = subOrder
	if status.thing and status.thing.getStat then status.speed = status.thing.speed end
end
-- bubbles up to parents
function Battle:getRelevantEffects(thing, callbackType, foeCallbackType, foeThing)
	local statuses = self:getRelevantEffectsInner(thing, callbackType, foeCallbackType, foeThing, true, false)
	self:sortByPriority(statuses)
	--if statuses[1] then self:debug('match ' .. callbackType .. ': ' .. statuses[1].status.id) end
	return statuses
end
function Battle:getRelevantEffectsInner(thing, callbackType, foeCallbackType, foeThing, bubbleUp, bubbleDown, getAll, statuses)
	if not callbackType or not thing or thing == null then return {} end
	statuses = statuses or {}
	local status

	-- Battle
	if thing.sides then -- thing should be same as self
		for i, pw in pairs(self.pseudoWeather) do
			status = self:getPseudoWeather(i)
			if status and status[callbackType] or (getAll and thing.pseudoWeather[i][getAll]) then
				table.insert(statuses, {status = status, callback = status[callbackType], statusData = pw, ['end'] = self.removePseudoWeather, thing = thing})
				self:resolveLastPriority(statuses, callbackType)
			end
		end
		status = self:getWeather()
		if status[callbackType] or (getAll and thing.weatherData[getAll]) then
			table.insert(statuses, {status = status, callback = status[callbackType], statusData = self.weatherData, ['end'] = self.clearWeather, thing = thing, priority = status[callbackType .. 'Priority'] or 0})
			self:resolveLastPriority(statuses, callbackType)
		end
		status = self:getTerrain()
		if status[callbackType] or (getAll and thing.terrainData[getAll]) then
			table.insert(statuses, {status = status, callback = status[callbackType], statusData = self.terrainData, ['end'] = self.clearTerrain, thing = thing, priority = status[callbackType .. 'Priority'] or 0})
			self:resolveLastPriority(statuses, callbackType)
		end
		status = self:getFormat()
		if status[callbackType] or (getAll and thing.formatData[getAll]) then
			table.insert(statuses, {status = status, callback = status[callbackType], statusData = self.formatData, ['end'] = function() end, thing = thing, priority = status[callbackType .. 'Priority'] or 0})
			self:resolveLastPriority(statuses, callbackType)
		end
		if self.events and self.events[callbackType] then
			for _, handler in pairs(self.events[callbackType]) do
				local statusData
				if handler.target.effectType == 'Format' then
					statusData = self.formatData
				end
				table.insert(statuses, {status = handler.target, callback = handler.callback, statusData = statusData, ['end'] = function() end, thing = thing, priority = handler.priority, order = handler.order, subOrder = handler.subOrder})
			end
		end
		if bubbleDown then
			self:getRelevantEffectsInner(self.p1, callbackType, nil, nil, false, true, getAll, statuses)
			self:getRelevantEffectsInner(self.p2, callbackType, nil, nil, false, true, getAll, statuses)
		end
		return statuses
	end

	-- BattleSide
	if thing.pokemon then
		for i, sc in pairs(thing.sideConditions) do
			status = thing:getSideCondition(i)
			if status[callbackType] or (getAll and sc[getAll]) then
				table.insert(statuses, {status = status, callback = status[callbackType], statusData = sc, ['end'] = thing.removeSideCondition, thing = thing})
				self:resolveLastPriority(statuses, callbackType)
			end
		end
		if foeCallbackType then
			self:getRelevantEffectsInner(thing.foe, foeCallbackType, nil, nil, false, false, getAll, statuses)
			if string.sub(foeCallbackType, 1, 5) == 'onFoe' then
				local eventName = string.sub(foeCallbackType, 6)
				self:getRelevantEffectsInner(thing.foe, 'onAny' .. eventName, nil, nil, false, false, getAll, statuses)
				self:getRelevantEffectsInner(thing, 'onAny' .. eventName, nil, nil, false, false, getAll, statuses)
			end
		end
		if bubbleUp then
			self:getRelevantEffectsInner(self, callbackType, nil, nil, true, false, getAll, statuses)
		end
		if bubbleDown then
			for _, a in pairs(thing.active) do
				self:getRelevantEffectsInner(a, callbackType, nil, nil, false, true, getAll, statuses)
			end
		end
		return statuses
	end

	-- BattlePokemon
	if not thing.getStatus then -- oops, thing wasn't really a Battle, BattleSide, or a BattlePokemon
		local s = type(thing)
		if s == 'string' then s = s .. ' ' .. thing end
		if debug.unexpectedEffects then self:debug('Battle:getRelevantEffectsInner received unexpected object: ' .. s) end
		return statuses
	end
	local status = thing:getStatus()
	if status[callbackType] or (getAll and thing.statusData[getAll]) then
		table.insert(statuses, {status = status, callback = status[callbackType], statusData = thing.statusData, ['end'] = thing.clearStatus, thing = thing})
		self:resolveLastPriority(statuses, callbackType)
	end
	for i, th in pairs(thing.volatiles) do
		status = thing:getVolatile(i)
		if status[callbackType] or (getAll and th[getAll]) then
			table.insert(statuses, {status = status, callback = status[callbackType], statusData = th, ['end'] = thing.removeVolatile, thing = thing})
			self:resolveLastPriority(statuses, callbackType)
		end
	end
	status = thing:getAbility()
	if status[callbackType] or (getAll and thing.abilityData[getAll]) then
		table.insert(statuses, {status = status, callback = status[callbackType], statusData = thing.abilityData, ['end'] = thing.clearAbility, thing = thing})
		self:resolveLastPriority(statuses, callbackType)
	end
	status = thing:getItem()
	if status[callbackType] or (getAll and thing.itemData[getAll]) then
		table.insert(statuses, {status = status, callback = status[callbackType], statusData = thing.itemData, ['end'] = thing.clearItem, thing = thing})
		self:resolveLastPriority(statuses, callbackType)
	end
	status = self:getEffect(thing.template.baseSpecies)
	if status[callbackType] then
		table.insert(statuses, {status = status, callback = status[callbackType], statusData = thing.speciesData, ['end'] = function() end, thing = thing})
		self:resolveLastPriority(statuses, callbackType)
	end

	if foeThing and foeCallbackType and foeCallbackType:sub(1, 8) ~= 'onSource' then
		self:getRelevantEffectsInner(foeThing, foeCallbackType, nil, nil, false, false, getAll, statuses)
	elseif foeCallbackType then
		local foeActive = thing.side.foe.active
		local allyActive = thing.side.active
		local eventName = ''
		if foeCallbackType:sub(1, 8) == 'onSource' then
			eventName = foeCallbackType:sub(9)
			if foeThing then
				self:getRelevantEffectsInner(foeThing, foeCallbackType, nil, nil, false, false, getAll, statuses)
			end
			foeCallbackType = 'onFoe' .. eventName
			foeThing = nil
		end
		if foeCallbackType:sub(1, 5) == 'onFoe' then
			eventName = foeCallbackType:sub(6)
			for _, ally in pairs(allyActive) do
				if ally ~= null and not ally	.fainted then
					self:getRelevantEffectsInner(ally, 'onAlly' .. eventName, nil, nil, false, false, getAll, statuses)
					self:getRelevantEffectsInner(ally, 'onAny'  .. eventName, nil, nil, false, false, getAll, statuses)
				end
			end
			for _, foe in pairs(foeActive) do
				if foe ~= null and not foe.fainted then
					self:getRelevantEffectsInner(foe, 'onAny' .. eventName, nil, nil, false, false, getAll, statuses)
				end
			end
		end
		for _, foe in pairs(foeActive) do
			if foe ~= null and not foe.fainted then
				self:getRelevantEffectsInner(foe, foeCallbackType, nil, nil, false, false, getAll, statuses)
			end
		end
	end
	if bubbleUp then
		self:getRelevantEffectsInner(thing.side, callbackType, foeCallbackType, nil, true, false, getAll, statuses)
	end
	return statuses
end
--[[
 * Use this function to attach custom event handlers to a battle. See Battle:runEvent for
 * more information on how to write callbacks for event handlers.
 *
 * Try to use this sparingly. Most event handlers can be simply placed in a format instead.
 *
 *     self:on(eventid, target, callback)
 * will set the callback as an event handler for the target when eventid is called with the
 * default priority. Currently only valid formats are supported as targets but this will
 * eventually be expanded to support other target types.
 *
 *     self:on(eventid, target, priority, callback)
 * will set the callback as an event handler for the target when eventid is called with the
 * provided priority. Priority can either be a number or an object that contains the priority,
 * order, and subOrder for the evend handler as needed (undefined keys will use default values)
--]]
function Battle:on(eventid, target, priority, callback)
	if not eventid then error('Event handlers must have an event to listen to', 2) end
	if not target then error('Event handlers must have a target', 2) end
	if not callback and not priority then error('Event handlers must have a callback', 2) end
	local order, subOrder
	if not callback then
		callback = priority
		priority = 0
		order = false
		subOrder = 0
	else
		local data = priority
		if type(data) == 'table' then
			priority = data['priority'] or 0
			order = data['order'] or false
			subOrder = data['subOrder'] or 0
		else
			priority = data or 0
			order = false
			subOrder = 0
		end
	end
	if target.effectType ~= 'Format' then
		error(target.effectType .. ' targets are not supported at this time', 2)
	end
	local eventHandler = {callback = callback, target = target, priority = priority, order = order, subOrder = subOrder}
	local callbackType = 'on' .. eventid
	if not self.events then self.events = {} end
	if not self.events[callbackType] then
		self.events[callbackType] = {eventHandler}
	else
		table.insert(self.events[callbackType], eventHandler)
	end
end
function Battle:getPokemon(id)
	if type(id) ~= 'string' then id = id.id end
	for _, pokemon in pairs(self.p1.pokemon) do
		if pokemon.id == id then return pokemon end
	end
	for _, pokemon in pairs(self.p2.pokemon) do
		if pokemon.id == id then return pokemon end
	end
	return null
end
function Battle:makeRequest(kind, requestDetails)
	--	printStackTrace()
	if kind then
		self.currentRequest = kind
		self.currentRequestDetails = requestDetails or ''
		self.rqid = self.rqid + 1
		self.p1.decision = nil
		self.p2.decision = nil
	else
		kind = self.currentRequest
		requestDetails = self.currentRequestDetails
	end
	self:update()

	-- default to no request
	local p1request
	local p2request
	self.p1.currentRequest = ''
	self.p2.currentRequest = ''

	if kind == 'switch' then
		local switchTable = {}
		for _, active in pairs(self.p1.active) do
			table.insert(switchTable, active ~= null and active.switchFlag and true or false)
		end
		if indexOf(switchTable, true) then
			self.p1.currentRequest = 'switch'
			p1request = {forceSwitch = switchTable, side = self.p1:getData('switch'), rqid = self.rqid}
		end
		local switchTable2 = {}
		for _, active in pairs(self.p2.active) do
			table.insert(switchTable2, active ~= null and active.switchFlag and true or false)
		end
		if indexOf(switchTable2, true) then
			self.p2.currentRequest = 'switch'
			p2request = {forceSwitch = switchTable2, side = self.p2:getData('switch'), rqid = self.rqid}
		end
		pcall(function()
			if p2request and not p1request and self.isTrainer and #self.p1.active == 1 and self.p2.active[1].hp == 0 then
				self.askToSwitchBeforeTrainerFlag = true
			end
		end)
	elseif kind == 'teampreview' then
		self:add('teampreview' .. (requestDetails and '|' .. requestDetails or ''))
		self.p1.currentRequest = 'teampreview'
		p1request = {teamPreview = true, side = self.p1:getData(), rqid = self.rqid}
		self.p2.currentRequest = 'teampreview'
		p2request = {teamPreview = true, side = self.p2:getData(), rqid = self.rqid}
	else
		local activeData = {}
		self.p1.currentRequest = 'move'
		for i, active in pairs(self.p1.active) do
			if active ~= null then
				activeData[i] = active:getRequestData()
			end
		end
		p1request = {active = activeData, side = self.p1:getData(), rqid = self.rqid}

		activeData = {}
		self.p2.currentRequest = 'move'
		for i, active in pairs(self.p2.active) do
			if active ~= null then
				activeData[i] = active:getRequestData()
			end
		end
		p2request = {active = activeData, side = self.p2:getData(), rqid = self.rqid}
	end

	if self.p1 and self.p2 then
		local inactiveSide = 0
		if p1request and not p2request then
			inactiveSide = 1
		elseif not p1request and p2request then
			inactiveSide = 2
		end
		if inactiveSide ~= self.inactiveSide then
			self:send('inactiveside', inactiveSide)
			self.inactiveSide = inactiveSide
		end
	end

	if p2request then
		if not self.supportCancel or not p1request then p2request.noCancel = true end
		self.p2:emitRequest(p2request)
	else
		self.p2.decision = true
		self.p2:emitRequest({wait = true, side = self.p2:getData()})
	end

	if self.askToSwitchBeforeTrainerFlag then -- moar hack
		while type(self.askToSwitchBeforeTrainerFlag) ~= 'string' do wait() end
		self.p1.currentRequest = 'switch'
		p1request = {foeAboutToSendOut = self.askToSwitchBeforeTrainerFlag, side = self.p1:getData(), rqid = self.rqid}
		self.askToSwitchBeforeTrainerFlag = nil
	end

	if p1request then
		if not self.supportCancel or not p2request then p1request.noCancel = true end
		self.p1:emitRequest(p1request)
	else
		self.p1.decision = true
		self.p1:emitRequest({wait = true, side = self.p1:getData()})
	end

	if self.p2.decision and self.p1.decision then
		if self.p2.decision == true and self.p1.decision == true then
			if kind ~= 'move' then
				-- TODO: investigate this race condition; should be fixed properly later
				return self:makeRequest('move')
			end
			warn('the battle "crashed" (?)')
			--			self:add('html', '<div class="broadcast-red"><b>The battle crashed</b></div>')
			self:win()
		else
			-- some kind of weird race condition?
			self:commitDecisions()
		end
		return
	end
end
function Battle:tie()
	self:win()
end
function Battle:win(side)--::win
	local WIN_DEBUG = self.WIN_DEBUG or false
	if self.ended then
		if WIN_DEBUG then print('LANDO: Battle attempted to "win" twice.') end
		return false
	end
	self:residualEvent('BattleEnd')
	if self.endSignal then
		self.endSignal:fire()
	end
	if side == 'p1' or side == 'p2' then
		side = self[side]
	elseif side ~= self.p1 and side ~= self.p2 then
		side = nil
	end
	self.winner = side and side.name or ''

	self:add('')

	if side then
		if self.pvp then
			self:add('-message', side.name .. ' won the match!')
			local p1c, p2c
			-- adjust ranks only for ranked battles
			if self.awardBP and self.isRanked then
				local s, r = pcall(function()
					p1c, p2c = EloManager:processMatchResult(self.p1.UserId, self.p2.UserId, side.UserId)
				end)
				if not s and WIN_DEBUG then print('LANDO: An error occured when trying to manage rank results:', r) end
			else
				if WIN_DEBUG then print('LANDO: This battle was unranked or flagged as a non-BP awarder.') end
			end
			--

			local winner, loser = self.listeningPlayers[side.id], self.listeningPlayers[side.foe.id]

			local wc, lc
			local winnerIsP1 = true
			pcall(function() if self.p2.UserId==winner.UserId then winnerIsP1 = false end end)
			pcall(function() if self.p1.UserId== loser.UserId then winnerIsP1 = false end end)
			wc = winnerIsP1 and p1c or p2c
			lc = winnerIsP1 and p2c or p1c

			self.winningPlayer = winner
			if self.awardBP then
				pcall(function() self:incrementStreak(winner.UserId) end)
				pcall(function() self:resetStreak(loser.UserId) end)
			end
			pcall(function() winner.BattleResult:remove() end)
			pcall(function() loser.BattleResult:remove() end)
			local r1 = Instance.new('StringValue', winner)
			r1.Name = 'BattleResult'
			r1.Value = 'win,'..(wc or '')
			local r2 = Instance.new('StringValue', loser)
			r2.Name = 'BattleResult'
			r2.Value = 'lose,'..(lc or '')
		elseif self.is2v2 then
			self:add('-message', side.name .. ' won the match!')

			local player1, player2, player3, player4 = self.listeningPlayers.p1, self.listeningPlayers.p2, self.listeningPlayers.p3, self.listeningPlayers.p4
			pcall(function() player1.BattleResult:remove() end)
			pcall(function() player2.BattleResult:remove() end)
			pcall(function() player3.BattleResult:remove() end)
			pcall(function() player4.BattleResult:remove() end)
			local side1result = (side==self.p1) and 'win,' or 'lose,'
			local side2result = (side==self.p2) and 'win,' or 'lose,'
			local r1 = Instance.new('StringValue', player1)
			r1.Name = 'BattleResult'
			r1.Value = side1result
			local r2 = Instance.new('StringValue', player2)
			r2.Name = 'BattleResult'
			r2.Value = side2result
			local r3 = Instance.new('StringValue', player3)
			r3.Name = 'BattleResult'
			r3.Value = side1result
			local r4 = Instance.new('StringValue', player4)
			r4.Name = 'BattleResult'
			r4.Value = side2result
		end
		self:add('win', side.n)--.name)
	else
		if WIN_DEBUG then print('LANDO: This battle somehow ended in a tie.') end
		if self.pvp then
			self:add('-message', 'The match ended in a tie!')
			local p1c, p2c
			if self.awardBP then pcall(function() p1c, p2c = EloManager:processMatchResult(self.p1.UserId, self.p2.UserId, nil) end) end

			local player1, player2 = self.listeningPlayers.p1, self.listeningPlayers.p2
			pcall(function() player1.BattleResult:remove() end)
			pcall(function() player2.BattleResult:remove() end)
			local r1 = Instance.new('StringValue', player1)
			r1.Name = 'BattleResult'
			r1.Value = 'tie,'..(p1c or '')
			local r2 = Instance.new('StringValue', player2)
			r2.Name = 'BattleResult'
			r2.Value = 'tie,'..(p2c or '')
		elseif self.is2v2 then
			self:add('-message', 'The match ended in a tie!')

			local player1, player2, player3, player4 = self.listeningPlayers.p1, self.listeningPlayers.p2, self.listeningPlayers.p3, self.listeningPlayers.p4
			pcall(function() player1.BattleResult:remove() end)
			pcall(function() player2.BattleResult:remove() end)
			pcall(function() player3.BattleResult:remove() end)
			pcall(function() player4.BattleResult:remove() end)
			local r1 = Instance.new('StringValue', player1)
			r1.Name = 'BattleResult'
			r1.Value = 'tie,'
			local r2 = Instance.new('StringValue', player2)
			r2.Name = 'BattleResult'
			r2.Value = 'tie,'
			local r3 = Instance.new('StringValue', player3)
			r3.Name = 'BattleResult'
			r3.Value = 'tie,'
			local r4 = Instance.new('StringValue', player4)
			r4.Name = 'BattleResult'
			r4.Value = 'tie,'
		end
		self:add('tie')
	end
	if self.battleType == BATTLE_TYPE_WILD or self.battleType == BATTLE_TYPE_NPC then
		if side == self.p1 then
			self:applyPostBattleUpdates()
		else
			local loss
			pcall(function()
				local PlayerData = _f.PlayerDataService[self.p1.player]
				local maxLevel = 1
				for _, p in pairs(PlayerData.party) do
					maxLevel = math.max(maxLevel, p.level)
				end
				local base = 8
				local badges = 0
				local baseForBadges = {16, 24, 36, 48, 64, 80, 90, 100}
				for _, b in pairs(PlayerData.badges) do
					if b then
						badges = badges + 1
						base = baseForBadges[badges]
						if badges >= #baseForBadges then break end
					end
				end
				loss = math.min(base * maxLevel, PlayerData.money)
				PlayerData:addMoney(-loss)
			end)
			self:add('blackout', loss)
			pcall(function() _f.PlayerDataService[self.p1.player]:heal() end)
		end
	end

	-- handle payouts
	if side == self.p1 and self.battleType == BATTLE_TYPE_NPC and self.npcTrainerData then
		local payout = self.npcTrainerData.Payout
		if payout then
			payout = payout * (self.RoPowerMoneyMultiplier or 1)
			if self.p1.doublePrizeMoney then
				payout = payout * 2
			end
			-- TODO: Happy Hour / Pay Day
			self:add('payout', payout)
			pcall(function() _f.PlayerDataService[self.p1.player]:addMoney(payout) end)
		end
	end
	-- handle evolutions
	if side == self.p1 and (self.battleType == BATTLE_TYPE_WILD or self.battleType == BATTLE_TYPE_NPC) and self.leveledUpPokemon then
		for pokemon in pairs(self.leveledUpPokemon) do
			local playerPokemon = pokemon:getPlayerPokemon()
			local evoData = playerPokemon:generateEvolutionDecision(1, self.isDay)
			if evoData then
				pokemon.evoData = {
					pokeName = playerPokemon:getName(),
					evo = evoData,
				}
				self:add('evolve', pokemon)
			end
		end
	end
	-- handle other trainer-based events
	if self.npcTrainerData then
		local trainer = self.npcTrainerData
		local PlayerData = _f.PlayerDataService[self.p1.player]
		if trainer.onComplete then
			trainer.onComplete(PlayerData)
		end
		if side == self.p1 then
			PlayerData.defeatedTrainers = _f.BitBuffer.SetBit(PlayerData.defeatedTrainers, trainer.id, true)
			if trainer.onWin then
				trainer.onWin(PlayerData)
			end
		elseif trainer.onLose then
			trainer.onLose(PlayerData)
		end
	end

	self.ended = true
	self.active = false
	self.currentRequest = ''
	self.currentRequestDetails = ''

	if self.pvp and self.allowSpectate then--2v2specdo
		pcall(function() _f.SpectateBoard:update() end)
	end

	return true
end
function Battle:switchIn(pokemon, pos)
	if not pokemon or pokemon.isActive then return false end
	pos = pos or 1
	local side = pokemon.side
	if pos > #side.active then
		error("Invalid switch position " .. pos)
	end
	if side.active[pos] ~= null then
		local oldActive = side.active[pos]
		if self:cancelMove(oldActive) then
			for _, foe in pairs(side.foe.active) do
				if foe ~= null and foe.isStale >= 2 then
					oldActive.isStaleCon = oldActive.isStaleCon + 1
					oldActive.isStaleSource = 'drag'
					break
				end
			end
		end
		if oldActive.switchCopyFlag == 'copyvolatile' then
			oldActive.switchCopyFlag = nil
			pokemon:copyVolatileFrom(oldActive)
		end
	end
	pokemon.isActive = true
	self:runEvent('BeforeSwitchIn', pokemon)
	if side.active[pos] ~= null then
		local oldActive = side.active[pos]
		oldActive.isActive = false
		oldActive.isStarted = false
		oldActive.usedItemThisTurn = false
		oldActive.position = pokemon.position
		pokemon.position = pos
		side.pokemon[pokemon.position] = pokemon
		side.pokemon[oldActive.position] = oldActive
		self:cancelMove(oldActive)
		oldActive:clearVolatile()
	else
		pokemon.position = pos
	end
	side.active[pos] = pokemon
	self:indexParticipants(pokemon)
	pokemon.activeTurns = 0
	for _, m in pairs(pokemon.moveset) do
		m.used = false
	end
	self:add('switch', pokemon, pokemon.getDetails, pokemon.status~='' and pokemon.status or nil)
	pokemon:update()
	self:insertQueue({pokemon = pokemon, choice = 'runSwitch'})
end
function Battle:getRandomSwitchable(side, pos)
	local canSwitchIn = {}
	local teamn = side
	for _, pokemon in pairs(side.pokemon) do
		if not pokemon.fainted and not pokemon.isActive and (not pokemon.teamn or pokemon.teamn == pos) then
			table.insert(canSwitchIn, pokemon)
		end
	end
	if #canSwitchIn == 0 then return nil end
	return canSwitchIn[math.random(#canSwitchIn)]
end
function Battle:dragIn(side, pos)--::dragIn
	if pos > #side.active then return false end
	pos = pos or 1
	local pokemon = self:getRandomSwitchable(side, pos)
	if not pokemon or pokemon.isActive then
		self:add('-fail')
		return false
	end
	self:runEvent('BeforeSwitchIn', pokemon)
	local oldActive = side.active[pos]
	if oldActive and oldActive ~= null then
		if oldActive.hp <= 0 then
			return false
		end
		if Not(self:runEvent('DragOut', oldActive)) then
			return false
		end
		self:singleEvent('End', self:getAbility(oldActive.ability), oldActive.abilityData, oldActive)
		self:runEvent('SwitchOut', oldActive)
		oldActive.isActive = false
		oldActive.isStarted = false
		oldActive.usedItemThisTurn = false
		oldActive.position = pokemon.position
		pokemon.position = pos
		side.pokemon[pos] = pokemon
		side.pokemon[oldActive.position] = oldActive
		if self:cancelMove(oldActive) then
			for _, foe in pairs(side.foe.active) do
				if foe.isStale >= 2 then
					oldActive.isStaleCon = oldActive.isStaleCon + 1
					oldActive.isStaleSource = 'drag'
					break
				end
			end
		end
		oldActive:clearVolatile()
	else
		side.pokemon[pos] = pokemon
	end
	side.active[pos] = pokemon
	self:indexParticipants(pokemon)
	pokemon.isActive = true
	pokemon.activeTurns = 0
	for _, m in pairs(pokemon.moveset) do
		m.used = false
	end
	self:add('drag', pokemon, pokemon.getDetails)
	pokemon:update()
	self:runEvent('SwitchIn', pokemon)
	if pokemon.hp <= 0 then return true end
	pokemon.isStarted = true
	if not pokemon.fainted then
		self:singleEvent('Start', pokemon:getAbility(), pokemon.abilityData, pokemon)
		self:singleEvent('Start', pokemon:getItem(), pokemon.itemData, pokemon)
	end
	return true
end
function Battle:swapPosition(pokemon, slot, attributes)
	if slot > #pokemon.side.active then
		error("Invalid swap position " .. slot)
	end
	local target = pokemon.side.active[slot]
	if slot ~= 2 and (not target or target.fainted) then return false end

	self:add('swap', pokemon, slot, attributes or '')

	local side = pokemon.side
	side.pokemon[pokemon.position] = target
	side.pokemon[slot] = pokemon
	side.active[pokemon.position] = side.pokemon[pokemon.position]
	side.active[slot] = side.pokemon[slot]
	if target then target.position = pokemon.position end
	pokemon.position = slot
	return true
end
function Battle:faint(pokemon, source, effect)
	pokemon:faint(source, effect)
end
function Battle:nextTurn()
	self.turn = self.turn + 1
	local allStale = true
	local oneStale = false
	for _, side in pairs(self.sides) do
		for _, pokemon in pairs(side.active) do
			if pokemon ~= null then
				pokemon.moveThisTurn = ''
				pokemon.usedItemThisTurn = false
				pokemon.newlySwitched = false
				pokemon.disabledMoves = {}
				self:runEvent('DisableMove', pokemon)
				if not pokemon.ateBerry then pokemon:disableMove('belch') end
				if pokemon.lastAttackedBy then
					if pokemon.lastAttackedBy.pokemon.isActive then
						pokemon.lastAttackedBy.thisTurn = false
					else
						pokemon.lastAttackedBy = nil
					end
				end
				if not pokemon.fainted then
					if pokemon.isStale < 2 then
						if pokemon.isStaleCon >= 2 then
							if pokemon.hp >= pokemon.isStaleHP - pokemon.maxhp/100 then
								pokemon.isStale = pokemon.isStale + 1
								if self.firstStaleWarned and pokemon.isStale < 2 then
									local s = pokemon.isStaleSource
									if s == 'struggle' then
										self:add('html', '<div class="broadcast-red">' .. self:escapeHTML(pokemon.name) .. ' isn\'t losing HP from Struggle. If this continues, it will be classified as being in an endless loop.</div>')
									elseif s == 'drag' then
										self:add('html', '<div class="broadcast-red">' .. self:escapeHTML(pokemon.name) .. ' isn\'t losing PP or HP from being forced to switch. If this continues, it will be classified as being in an endless loop.</div>')
									elseif s == 'switch' then
										self:add('html', '<div class="broadcast-red">' .. self:escapeHTML(pokemon.name) .. ' isn\'t losing PP or HP from repeatedly switching. If this continues, it will be classified as being in an endless loop.</div>')
									end
								end
							end
							pokemon.isStaleCon = 0
							pokemon.isStalePPTurns = 0
							pokemon.isStaleHP = pokemon.hp
						end
						if pokemon.isStalePPTurns >= 5 then
							if pokemon.hp >= pokemon.isStaleHP - pokemon.maxhp/100 then
								pokemon.isStale = pokemon.isStale + 1
								pokemon.isStaleSource = 'ppstall'
								if self.firstStaleWarned and pokemon.isStale < 2 then
									self:add('html', '<div class="broadcast-red">' .. self:escapeHTML(pokemon.name) .. ' isn\'t losing PP or HP. If it keeps on not losing PP or HP, it will be classified as being in an endless loop.</div>')
								end
							end
							pokemon.isStaleCon = 0
							pokemon.isStalePPTurns = 0
							pokemon.isStaleHP = pokemon.hp
						end
					end
					if #pokemon:getMoves() == 0 then
						pokemon.isStaleCon = pokemon.isStaleCon + 1
						pokemon.isStaleSource = 'struggle'
					end
					if pokemon.isStale < 2 then
						allStale = false
					elseif pokemon.isStale and not pokemon.staleWarned then
						oneStale = pokemon
					end
					if pokemon.isStalePPTurns == 0 then
						pokemon.isStaleHP = pokemon.hp
						if pokemon.activeTurns > 0 then
							pokemon.isStaleCon = 0
						end
					end
					if pokemon.activeTurns > 0 then
						pokemon.isStalePPTurns = pokemon.isStalePPTurns + 1
					end
					pokemon.activeTurns = pokemon.activeTurns + 1
				end
			end
		end
		side.faintedLastTurn = side.faintedThisTurn
		side.faintedThisTurn = false
	end
	local banlistTable = self:getFormat().banlistTable
	if banlistTable and banlistTable['Rule:endlessbattleclause'] then
		if oneStale then
			local activationWarning = '<br />If all active Pok&eacute;mon go in an endless loop, Endless Battle Clause will activate.'
			if allStale then activationWarning = '' end
			local reasons = {
				struggle = ": it isn't losing HP from Struggle",
				drag = ": it isn't losing PP or HP from being forced to switch",
				switch = ": it isn't losing PP or HP from repeatedly switching",
				getleppa = ": it got a Leppa Berry it didn't start with",
				useleppa = ": it used a Leppa Berry it didn't start with",
				ppstall = ": it isn't losing PP or HP",
				ppoverflow = ": its PP overflowed",
			}
			local loopReason = reasons[oneStale.isStaleSource] or ''
			self:add('html', '<div class="broadcast-red">' .. self:escapeHTML(oneStale.name) .. ' is in an endless loop' .. loopReason .. '.' .. activationWarning .. '</div>')
			oneStale.staleWarned = true
			self.firstStaleWarned = true
		end
		if allStale then
			self:add('message', "All active Pokemon are in an endless loop. Endless Battle Clause activated!")
			local leppaPokemon
			for _, side in pairs(self.sides) do
				for _, pokemon in pairs(side.pokemon) do
					if toId(pokemon.set.item) == 'leppaberry' then
						if leppaPokemon then
							leppaPokemon = nil -- both sides have Leppa
							self:add('-message', "Both sides started with a Leppa Berry.")
						else
							leppaPokemon = pokemon
						end
						break
					end
				end
			end
			if leppaPokemon then
				self:add('-message', leppaPokemon.side.name .. "'s " .. leppaPokemon.name .. " started with a Leppa Berry and loses.")
				self:win(leppaPokemon.side.foe)
				return
			end
			self:win()
			return
		end
	else
--[[		if allStale and not self.staleWarned then
			self.staleWarned = true
			self:add('html', '<div class="broadcast-red">If this format had Endless Battle Clause, it would have activated.</div>')
		elseif oneStale then
			self:add('html', '<div class="broadcast-red">' .. self.escapeHTML(oneStale.name) .. ' is in an endless loop.</div>')
			oneStale.staleWarned = true
		end]]
	end

	if #self.p1.active == 3 and self.p1.pokemonLeft == 1 and self.p2.pokemonLeft == 1 then
		-- If both sides have one Pokemon left in triples and they are not adjacent, they are both moved to the center.
		local center = true
		local switches = {}
		for _, side in pairs(self.sides) do
			for _, pokemon in pairs(side.active) do
				if pokemon ~= null and not pokemon.fainted then
					if pokemon.position == 2 then
						center = false
					else
						table.insert(switches, pokemon)
					end
					break
				end
			end
			if not center then break end
		end
		if center then
			for _, pokemon in pairs(switches) do
				self:swapPosition(pokemon, 2, '[silent]')
			end
			self:add('-center')
		end
	end

	self:add('turn', self.turn)

	self:makeRequest('move')
end
function Battle:start()--::start
	if self.active then return end

	if not self.p1 or not self.p1.isActive or not self.p2 or not self.p2.isActive then
		--		self:debug('need two players to start')
		return
	end

	-- update spectate board
	if self.pvp and self.allowSpectate then
		print('attempting to update board')
		pcall(function() _f.SpectateBoard:update() end)
	end
	--

	self.p2:emitRequest({side = self.p2:getData()})
	self.p1:emitRequest({side = self.p1:getData()})

	if self.started then
		self:makeRequest()
		self.isActive = true
		self.activeTurns = 0
		return
	end
	self.isActive = true
	self.activeTurns = 0
	self.started = true
	self.p2.foe = self.p1
	self.p1.foe = self.p2

	-- PVP
	if self.pvp then
		if not (pcall(function() self.p1.UserId = self.listeningPlayers.p1.UserId end)) then print('no listening p1 on start') end
		if not (pcall(function() self.p2.UserId = self.listeningPlayers.p2.UserId end)) then print('no listening p2 on start') end
	end
	--

	for _, side in pairs(self.sides) do
		for _, pokemon in pairs(side.pokemon) do
			if pokemon.set.status then
				local s, d = pokemon.set.status:match('^(%D+)(%d+)$')
				if not s then
					s = pokemon.set.status
				end
				pokemon:setStatus(s)
				if d then
					d = tonumber(d)
					pokemon.statusData.time = d
					pokemon.statusData.startTime = d
				end
			end
			local icon = pokemon.template.icon
			local playerPokemon = pokemon:getPlayerPokemon()
			if playerPokemon then
				icon = playerPokemon:getIcon()+1
			end
			local showOwnedIcon
			if self.battleType == BATTLE_TYPE_WILD and side == self.p2 and self.alreadyOwnsFoeSpecies then
				showOwnedIcon = true
			end
			local extras = {
				'[icon]'..icon,
				'[ball]'..pokemon.ball,
			}
			if showOwnedIcon then
				table.insert(extras, '[owned]')
			end
			if pokemon.teamn then
				table.insert(extras, '[teamn]'..pokemon.teamn)
			end
			self:add('cache', pokemon, pokemon.getDetails, unpack(extras))
			if pokemon.spriteForme then
				self:add('-spriteForme', pokemon, pokemon.spriteForme)
			end
			if pokemon.stamps and #pokemon.stamps > 0 then
				for _, stamp in pairs(pokemon.stamps) do
					local ed = _f.PBStamps:getStampAnimationData(stamp)
					local colorR, colorG, colorB = ed.color3.r, ed.color3.g, ed.color3.b
					colorR, colorG, colorB = math.floor(colorR*255+.5), math.floor(colorG*255+.5), math.floor(colorB*255+.5)
					local special
					if stamp.color == 20 then
						special = 'Rainbow'
					end
					self:add('-stamp', pokemon, ed.sheetId, ed.n, colorR, colorG, colorB, ed.style, special)
				end
			end
		end
	end

	--	self:add('gametype', self.gameType)

	--	local format = self:getFormat()
	--	Tools.mod(format.mod).getBanlistTable(format) -- fill in format ruleset

	--	self:add('tier', format.name)
	--	if self.rated then
	--		self:add('rated')
	--	end
	--	if format and format.ruleset then
	--		for _, rule in pairs(format.ruleset) do
	--			self:addPseudoWeather(rule)
	--		end
	--	end

	if not self.p1.pokemon[1] or not self.p2.pokemon[1] then
		self:debugError('battle error: one team is empty')--self:add('message', 'battle error: one team is empty')
		return
	end

	--	self:residualEvent('TeamPreview')

	self:addQueue({choice = 'start'})
	self.midTurn = true

	if self.currentRequest == '' then self:go() end
end
function Battle:boost(boost, target, source, effect)
	if self.event then
		if not target then target = self.event.target end
		if not source then source = self.event.source end
		if not effect then effect = self.effect end
	end
	if not target or target.hp <= 0 then return 0 end
	if not target.isActive then return false end
	effect = self:getEffect(effect)
	boost = self:runEvent('Boost', target, source, effect, boost)
	local success = false
	for i, b in pairs(boost) do
		local currentBoost = {}
		currentBoost[i] = b
		if b ~= 0 and target:boostBy(currentBoost) then
			success = true
			local msg = '-boost'
			if b < 0 then
				msg = '-unboost'
				b = -b
			end
			local e = effect.id
			if e == 'bellydrum' then
				self:add('-setboost', target, 'atk', target.boosts['atk'], '[from] move: Belly Drum')
			elseif e == 'intimidate' or e == 'gooey' then
				self:add(msg, target, i, b)
			else
				if effect.effectType == 'Move' then
					self:add(msg, target, i, b)
				else
					self:add(msg, target, i, b, '[from] ' .. effect.fullname)
				end
			end
			self:runEvent('AfterEachBoost', target, source, effect, currentBoost)
		end
	end
	self:runEvent('AfterBoost', target, source, effect, boost)
	return success
end
function Battle:damage(damage, target, source, effect, instafaint, isMove)
	if self.event then
		if not target then target = self.event.target end
		if not source then source = self.event.source end
		if not effect then effect = self.effect end
	end
	if not target or target.hp <= 0 then return 0 end
	if not target.isActive then return false end
	effect = self:getEffect(effect)
	if Not(damage) and damage ~= 0 then return damage end
	if damage ~= 0 then damage = self:clampIntRange(damage, 1) end

	if effect.id ~= 'struggle-recoil' then -- Struggle recoil is not affected by effects
		if effect.effectType == 'Weather' and not target:runImmunity(effect.id) then
			self:debug('weather immunity')
			return 0
		end
		damage = self:runEvent('Damage', target, source, effect, damage)
		if Not(damage) and damage ~= 0 then
			self:debug('damage event failed')
			return damage
		end
		if target.illusion and effect and effect.effectType == 'Move' and effect.id ~= 'confused' then
			self:debug('illusion wore off')
			target.illusion = nil
			--			self:add('replace', target, target.getDetails) -- PS's way of doing it
			self:add('-endability', target, 'Illusion', target.getDetails) -- Zexlku's way
		end
	end
	if damage ~= 0 then damage = self:clampIntRange(damage, 1) end
	damage = target:damage(damage, source, effect)
	if source then source.lastDamage = damage end
	local name = effect.fullname
	if name == 'tox' then name = 'psn' end
	if effect.id == 'partiallytrapped' then
		self:add('-damage', target, target.getHealth, '[from] ' .. self.effectData.sourceEffect.fullname, '[partiallytrapped]')
	elseif effect.id == 'powder' then
		self:add('-damage', target, target.getHealth, '[silent]')
	elseif effect.id == 'confused' then
		self:add('-damage', target, target.getHealth, '[from] confusion')
	elseif effect.effectType == 'Move' then
		self:add('-damage', target, target.getHealth)
		if isMove and not effect.isFutureMove then
			table.insert(self.log, self.lastMoveLine+1, table.remove(self.log))
		end
	elseif source and source ~= target then
		self:add('-damage', target, target.getHealth, '[from] ' .. effect.fullname, '[of] ' .. source)
	else
		self:add('-damage', target, target.getHealth, '[from] ' .. name)
	end

	if effect.drain and source then
		self:heal(math.ceil(damage * effect.drain[1] / effect.drain[2]), source, target, 'drain')
	end

	if not effect.flags then effect.flags = {} end

	if instafaint and target.hp <= 0 then
		--		self:debug('instafaint: ' .. self.faintQueue.map('target').map('name')) -- TODO
		self:faintMessages(true)
	else
		damage = self:runEvent('AfterDamage', target, source, effect, damage)
	end

	return damage
end
function Battle:directDamage(damage, target, source, effect)
	if self.event then
		if not target then target = self.event.target end
		if not source then source = self.event.source end
		if not effect then effect = self.effect end
	end
	if not target or target.hp <= 0 then return 0 end
	if not damage or damage == 0 then return 0 end
	damage = self:clampIntRange(damage, 1)

	damage = target:damage(damage, source, effect)
	if effect.id == 'strugglerecoil' then
		self:add('-damage', target, target.getHealth, '[from] recoil')
	elseif effect.id == 'confusion' then
		self:add('-damage', target, target.getHealth, '[from] confusion')
	else
		self:add('-damage', target, target.getHealth)
	end
	if target.fainted then self:faint(target) end
	return damage
end
function Battle:heal(damage, target, source, effect, allowInactive, ...)
	if self.event then
		if not target then target = self.event.target end
		if not source then source = self.event.source end
		if not effect then effect = self.effect end
	end
	effect = self:getEffect(effect)
	if damage and damage <= 1 then damage = 1 end
	damage = math.floor(damage)
	-- for things like Liquid Ooze, the Heal event still happens when nothing is healed.
	damage = self:runEvent('TryHeal', target, source, effect, damage)
	if not damage or damage == 0 then return 0 end
	if not target or target.hp <= 0 then return 0 end
	if not target.isActive and not allowInactive then return false end
	if target.hp >= target.maxhp then return 0 end
	damage = target:heal(damage, source, effect)
	if effect.id == 'leechseed' or effect.id == 'rest' then
		self:add('-heal', target, target.getHealth, '[silent]', ...)
	elseif effect.id == 'drain' then
		self:add('-heal', target, target.getHealth, '[from] drain', '[of] ' .. source, ...)
	elseif effect.id == 'wish' then

	else
		if effect.effectType == 'Move' then
			self:add('-heal', target, target.getHealth, ...)
		elseif effect.effectType == 'Item' and self.useItemHack then -- ugh...
			self:add('-heal', target, target.getHealth, ...)
		elseif source and source ~= target then
			self:add('-heal', target, target.getHealth, '[from] ' .. effect.fullname, '[of] ' .. source, ...)
		else
			self:add('-heal', target, target.getHealth, '[from] ' .. effect.fullname, ...)
		end
	end
	self:runEvent('Heal', target, source, effect, damage)
	return damage
end

function Battle:chain(previousMod, nextMod)
	-- previousMod or nextMod can be either a number or a table {numerator, denominator}
	if type(previousMod) == 'table' then previousMod = math.floor(previousMod[1] * 4096 / previousMod[2])
	else previousMod = math.floor(previousMod * 4096) end

	if type(nextMod) == 'table' then nextMod = math.floor(nextMod[1] * 4096 / nextMod[2])
	else nextMod = math.floor(nextMod * 4096) end
	return rshift((previousMod * nextMod + 2048), 12) / 4096 -- M'' = ((M * M') + 0x800) >> 12
end
function Battle:chainModify(numerator, denominator)
	local previousMod = math.floor(self.event.modifier * 4096)

	if type(numerator) == 'table' then
		denominator = numerator[2]
		numerator = numerator[1]
	end
	local nextMod = 0
	if self.event.ceilModifier then
		nextMod = math.ceil(numerator * 4096 / (denominator or 1))
	else
		nextMod = math.floor(numerator * 4096 / (denominator or 1))
	end
	self.event.modifier = rshift((previousMod * nextMod + 2048), 12) / 4096
end
function Battle:modify(value, numerator, denominator)
	-- You can also use:
	-- modify(value, [numerator, denominator])
	-- modify(value, fraction) - assuming you trust floats
	if not denominator then denominator = 1 end
	if type(numerator) == 'table' then
		denominator = numerator[2]
		numerator = numerator[1]
	end
	local modifier = math.floor(numerator * 4096 / denominator)
	return math.floor((value * modifier + 2048 - 1) / 4096)
end
function Battle:getCategory(move)
	local cat = self:getMove(move).category
	if type(cat) == 'string' then return cat end
	if not cat then return 'Physical' end
	return ({'Physical', 'Special', 'Status'})[cat + 1]
end
function Battle:getDamage(pokemon, target, move, suppressMessages, zMove)
	if type(move) == 'string' then move = self:getMove(move) end
	--if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
	--if not self:getMove(toId(zMove)).Exclusive and self:getMove(toId(zMove)).isZ then move.volatileStatus = nil 
	--	move.multihit = nil end 
	if zMove and type(zMove) == 'table' then
		if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
		if not self:getMove(toId(zMove)).Exclusive and self:getMove(toId(zMove)).isZ then 
			local pwr = move.basePower
			move = self:getMove(toId(zMove))
			move.basePower = pwr
		end  
	end
	if type(move) == 'number' then
		move = {
			basePower = move,
			type = '???',
			category = 'Physical',
			flags = {}
		}
	end

	if not move.ignoreImmunity or (move.ignoreImmunity ~= true and not move.ignoreImmunity[move.type]) then
		if not target:runImmunity(move.type, not suppressMessages) then
			return false
		end
	end

	if move.ohko then
		return target.maxhp
	end

	if move.damageCallback then
		return self:call(move.damageCallback, pokemon, target)
	end
	if move.damage == 'level' then
		return pokemon.level
	end
	if move.damage then
		return move.damage
	end

	if not move then
		move = {}
	end
	if not move.type then move.type = '???' end
	local typeof = type
	local type = move.type
	-- '???' is typeless damage: used for Struggle and Confusion etc
	local category = self:getCategory(move)
	local defensiveCategory = move.defensiveCategory or category

	local basePower = move.basePower

	print(basePower)
	if move.basePowerCallback and not zMove then -- self is nil in these callbacks ???
		assert(typeof(self) == 'table', 'BasePowerCallback: self is not Battle')
		basePower = self:call(move.basePowerCallback, pokemon, target, move)
	end
	if Not(basePower) then
		if basePower == 0 then return undefined end -- returning undefined means not dealing damage
		return basePower
	end
	basePower = self:clampIntRange(basePower, 1)

	move.critRatio = self:clampIntRange(move.critRatio, 0, 4)
	local critMult = {16, 8, 2, 1}

	move.crit = move.willCrit or false
	if move.willCrit == nil then
		if move.critRatio ~= 0 then
			move.crit = math.random(critMult[move.critRatio]) == 1
		end
	end
	if move.crit then
		move.crit = self:runEvent('CriticalHit', target, nil, move)
	end

	-- happens after crit calculation
	basePower = self:runEvent('BasePower', pokemon, target, move, basePower, true)

	if Not(basePower) then return 0 end
	basePower = math.max(basePower, 1)

	local level = pokemon.level

	local attacker = pokemon
	local defender = target
	local attackStat = (category == 'Physical') and 'atk' or 'spa'
	local defenseStat = (defensiveCategory == 'Physical') and 'def' or 'spd'
	local statTable = {atk='Atk', def='Def', spa='SpA', spd='SpD', spe='Spe'}
	local attack, defense

	local atkBoosts = move.useTargetOffensive and defender.boosts[attackStat]  or attacker.boosts[attackStat]
	local defBoosts = move.useSourceDefensive and attacker.boosts[defenseStat] or defender.boosts[defenseStat]

	local ignoreNegativeOffensive = move.ignoreNegativeOffensive and true or false
	local ignorePositiveDefensive = move.ignorePositiveDefensive and true or false

	if move.crit then
		ignoreNegativeOffensive = true
		ignorePositiveDefensive = true
	end

	local ignoreOffensive = (move.ignoreOffensive or (ignoreNegativeOffensive and atkBoosts < 0)) and true or false
	local ignoreDefensive = (move.ignoreDefensive or (ignorePositiveDefensive and defBoosts > 0)) and true or false

	if ignoreOffensive then
		self:debug('Negating (sp)atk boost/penalty.')
		atkBoosts = 0
	end
	if ignoreDefensive then
		self:debug('Negating (sp)def boost/penalty.')
		defBoosts = 0
	end

	if move.useTargetOffensive then attack = defender:calculateStat(attackStat, atkBoosts)
	else attack = attacker:calculateStat(attackStat, atkBoosts) end

	if move.useSourceDefensive then defense = attacker:calculateStat(defenseStat, defBoosts)
	else defense = defender:calculateStat(defenseStat, defBoosts) end

	-- Apply Stat Modifiers
	attack  = self:runEvent('Modify' .. statTable[attackStat],  attacker, defender, move, attack )
	defense = self:runEvent('Modify' .. statTable[defenseStat], defender, attacker, move, defense)

	--if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
	--if not self:getMove(toId(zMove)).Exclusive and self:getMove(toId(zMove)).isZ then move.volatileStatus = nil 
	--	move.multihit = nil end            
	--int(int(int(2 * L / 5 + 2) * A * P / D) / 50);
	local baseDamage = math.floor(math.floor(math.floor(2 * level / 5 + 2) * basePower * attack / defense) / 50) + 2

	-- multi-target modifier (doubles only)
	if move.spreadHit then
		local spreadModifier = move.spreadModifier or 0.75
		self:debug('Spread modifier: ' .. spreadModifier)
		baseDamage = self:modify(baseDamage, spreadModifier)
	end

	-- weather modifier
	baseDamage = self:runEvent('WeatherModifyDamage', pokemon, target, move, baseDamage)

	-- crit
	if move.crit then
		if not suppressMessages then self:add('-crit', target) end
		baseDamage = self:modify(baseDamage, move.critModifier or 1.5)
	elseif self.currentMoveMultiHits then
		self:add('-nocrit')
	end

	-- randomizer
	-- this is not a modifier
	baseDamage = self:randomizer(baseDamage)

	-- STAB
	if move.hasSTAB or (type ~= '???' and pokemon:hasType(type)) then
		-- The "???" type never gets STAB
		-- Not even if you Roost in Gen 4 and somehow manage to use
		-- Struggle in the same turn.
		-- (On second thought, it might be easier to get a Missingno.)
		baseDamage = self:modify(baseDamage, move.stab or 1.5)
	end

	-- types
	local multiplier = target:runEffectiveness(move)
	move.typeMod = math.max(-6, math.min(math.floor(math.log(multiplier)/math.log(2) + .5), 6))

	multiplier = 2 ^ move.typeMod

	if move.typeMod > 0 then
		if not suppressMessages then self:add('-supereffective', target) end
		baseDamage = baseDamage * multiplier
	end
	if move.typeMod < 0 then
		if not suppressMessages then self:add('-resisted', target) end
		for _ = 1, -move.typeMod do
			baseDamage = math.floor(baseDamage / 2) -- rounds between each division
		end
	end

	if pokemon.status == 'brn' and basePower and basePower > 0 and move.category == 'Physical' and not pokemon:hasAbility('guts') then
		if move.id ~= 'facade' then
			baseDamage = self:modify(baseDamage, 0.5)
		end
	end

	-- Final modifier
	baseDamage = self:runEvent('ModifyDamage', pokemon, target, move, baseDamage)

	if basePower > 0 and math.floor(baseDamage) == 0 then
		return 1
	end

	return math.floor(baseDamage)
end
function Battle:randomizer(baseDamage)
	return math.floor(baseDamage * (100 - math.random(0, 15)) / 100)
end
-- Returns whether a proposed target for a move is valid
function Battle:validTargetLoc(targetLoc, source, targetType)
	local numSlots = #source.side.active
	if math.abs(targetLoc) > numSlots then return false end

	local sourceLoc = -source.position
	local isFoe = (targetLoc > 0)
	local isAdjacent
	if isFoe then
		isAdjacent = math.abs(-(numSlots + 1 - targetLoc) - sourceLoc) <= 1
	else
		isAdjacent = math.abs(targetLoc - sourceLoc) == 1
	end
	local isSelf = (sourceLoc == targetLoc)

	if targetType == 'randomNormal' or targetType == 'normal' then
		return isAdjacent
	elseif targetType == 'adjacentAlly' then
		return isAdjacent and not isFoe
	elseif targetType == 'adjacentAllyOrSelf' then
		return (isAdjacent and not isFoe) or isSelf
	elseif targetType == 'adjacentFoe' then
		return isAdjacent and isFoe
	elseif targetType == 'any' then
		return not isSelf
	end
	return false
end
function Battle:getTargetLoc(target, source)
	if target.side == source.side then
		return -target.position
	end
	return target.position
end
function Battle:validTarget(target, source, targetType)
	return self:validTargetLoc(self:getTargetLoc(target, source), source, targetType)
end
function Battle:getTarget(decision)
	local move = self:getMove(decision.move)
	local target
	if move.target ~= 'randomNormal' and self:validTargetLoc(decision.targetLoc, decision.pokemon, move.target) then
		if decision.targetLoc > 0 then
			target = decision.pokemon.side.foe.active[decision.targetLoc]
		else
			target = decision.pokemon.side.active[-decision.targetLoc]
		end
		if target and target ~= null then
			if not target.fainted then
				-- target exists and is not fainted
				return target
			elseif target.side == decision.pokemon.side then
				-- fainted allied targets don't retarget
				return false
			end
		end
		-- chosen target not valid, retarget randomly with resolveTarget
	end
	--	print('retargeting ' .. decision.pokemon .. '\'s move (attempted to target ' .. decision.targetLoc .. ')')
	if not decision.targetPosition or not decision.targetSide then
		target = self:resolveTarget(decision.pokemon, decision.move)
		decision.targetSide = target.side
		decision.targetPosition = target.position
	end
	return decision.targetSide.active[decision.targetPosition]
end
function Battle:resolveTarget(pokemon, move)
	-- A move was used without a chosen target

	-- For instance: Metronome chooses Ice Beam. Since the user didn't
	-- choose a target when choosing Metronome, Ice Beam's target must
	-- be chosen randomly.

	-- The target is chosen randomly from possible targets, EXCEPT that
	-- moves that can target either allies or foes will only target foes
	-- when used without an explicit target.

	local function filterFn(active)
		return active and active ~= null and not active.fainted
	end

	move = self:getMove(move)
	local moveTarget = move.target
	if moveTarget == 'adjacentAlly' then
		local adjacentAllies = filter({pokemon.side.active[pokemon.position - 1], pokemon.side.active[pokemon.position + 1]}, filterFn)
		if #adjacentAllies > 0 then return adjacentAllies[math.random(#adjacentAllies)] end
		return pokemon
	end
	if moveTarget == 'self' or moveTarget == 'all' or moveTarget == 'allySide' or moveTarget == 'allyTeam' or moveTarget == 'adjacentAllyOrSelf' then
		return pokemon
	end
	if #pokemon.side.active > 2 then
		if moveTarget == 'adjacentFoe' or moveTarget == 'normal' or moveTarget == 'randomNormal' then
			local foeActives = pokemon.side.foe.active
			local frontPosition = #foeActives + 1 - pokemon.position
			local adjacentFoes = filter(filter(foeActives, filterFn), function(p) return math.abs(p.position-frontPosition) < 2 end)
			if #adjacentFoes > 0 then return adjacentFoes[math.random(#adjacentFoes)] end
			-- no valid target at all, return a foe for any possible redirection
		end
	end
	return pokemon.side.foe:randomActive() or pokemon.side.foe.active[1]
end
function Battle:checkFainted()
	local function check(a)
		if Not(a) then return end
		if a.fainted then
			a.status = 'fnt'
			a.switchFlag = true
		end
	end

	for _, a in pairs(self.p1.active) do check(a) end
	for _, a in pairs(self.p2.active) do check(a) end
end
function Battle:faintMessages(lastFirst)
	if self.ended then return end
	if #self.faintQueue == 0 then return false end
	if lastFirst then
		table.insert(self.faintQueue, 1, table.remove(self.faintQueue, #self.faintQueue))
	end
	local faintData
	while #self.faintQueue > 0 do
		faintData = table.remove(self.faintQueue, 1)
		if not faintData.target.fainted then
			self:add('faint', faintData.target)
			self:runEvent('Faint', faintData.target, faintData.source, faintData.effect)
			self:singleEvent('End', self:getAbility(faintData.target.ability), faintData.target.abilityData, faintData.target)
			faintData.target.fainted = true
			faintData.target.isActive = false
			faintData.target.isStarted = false
			faintData.target.side.pokemonLeft = faintData.target.side.pokemonLeft - 1
			faintData.target.side.faintedThisTurn = true
		end
	end
	self:awardQueuedExp()
	if self.p1.pokemonLeft <= 0 and self.p2.pokemonLeft <= 0 then
		self:win(faintData and faintData.target.side)
		return true
	end
	if self.p1.pokemonLeft <= 0 then
		self:win(self.p2)
		return true
	end
	if self.p2.pokemonLeft <= 0 then
		self:win(self.p1)
		return true
	end
	if self.p1.isTwoPlayerSide and self.p1.isSecondPlayerNpc then
		local blackout = true
		for _, p in pairs(self.p1.pokemon) do
			if p.hp > 0 and p.teamn == 1 then
				blackout = false
				break
			end
		end
		if blackout then
			self:win(self.p2)
			return true
		end
	end
	return false
end
function Battle:resolvePriority(decision)
	if decision then
		if not decision.side and decision.pokemon then decision.side = decision.pokemon.side end
		if not decision.choice and decision.move then decision.choice = 'move' end
		if not decision.priority then
			local priorities = {
				team = 102,
				start = 101,
				instaswitch = 101,
				beforeTurn = 100,
				beforeTurnMove = 99,
				runSwitch = 7.1,
				switch = 7,
				megaEvo = 6.9,
				residual = -100,
			}
			if priorities[decision.choice] then
				decision.priority = priorities[decision.choice]
			end
		end
		if decision.choice == 'move' then
			if self:getMove(decision.move).beforeTurnCallback then
				self:addQueue({choice = 'beforeTurnMove', pokemon = decision.pokemon, move = decision.move, targetLoc = decision.targetLoc})
			end
		elseif decision.choice == 'switch' or decision.choice == 'instaswitch' then
			if decision.pokemon.switchFlag and decision.pokemon.switchFlag ~= true then
				decision.pokemon.switchCopyFlag = decision.pokemon.switchFlag
			end
			decision.pokemon.switchFlag = false
			if not decision.speed and decision.pokemon and decision.pokemon.isActive then decision.speed = decision.pokemon.speed end
		end
		if decision.move then
			local target

			if not decision.targetPosition then
				target = self:resolveTarget(decision.pokemon, decision.move)
				decision.targetSide = target.side
				decision.targetPosition = target.position
			end

			decision.move = self:getMoveCopy(decision.move)
			if (decision.zmove) then
				local zMoveName = self:getZMove(decision.move, decision.pokemon, true)
				if (zMoveName) then
					local zMove = self:getMove(zMoveName)
					if (zMove.isZ) then
						decision.zmove = zMove
					end
				end
			end

			if not decision.priority then
				local priority = decision.move.priority
				priority = self:runEvent('ModifyPriority', decision.pokemon, target, decision.move, priority)
				decision.priority = priority
				decision.move.priority = priority
			end
		end
		if not decision.pokemon and not decision.speed then decision.speed = 1 end
		if not decision.speed and (decision.choice == 'switch' or decision.choice == 'instaswitch') and decision.target then decision.speed = decision.target.speed end
		if not decision.speed then decision.speed = decision.pokemon.speed end
	end
end
function Battle:addQueue(decision)
	--	print('===> adding a', decision.choice, 'decision without sorting')
	local ar = isArray(decision, 'finalDecision')
	--	self:debug('isArray:', ar)
	if ar then
		for _, d in ipairs(decision) do
			self:addQueue(d)
		end
		return
	end

	self:resolvePriority(decision)
	table.insert(self.queue, decision)
end
function Battle:sortQueue()
	--	print('===> sorting the queue')
	self:sortByPriority(self.queue)
end
function Battle:insertQueue(decision)
	--	print('===> inserting a', decision.choice, 'decision into the queue in correct place')
	if isArray(decision, 'finaldecision') then
		for _, d in pairs(decision) do
			self:insertQueue(d)
		end
		return
	end

	self:resolvePriority(decision)
	local inserted = false
	for i, q in pairs(self.queue) do
		if Battle.comparePriority(decision, q) then
			table.insert(self.queue, i, decision) -- i+1
			inserted = true
			break
		end
	end
	if not inserted then
		table.insert(self.queue, decision)
	end
end
function Battle:prioritizeQueue(decision, source, sourceEffect)
	--	print('===> prioritizing a', decision.choice, 'decision')
	if self.event then
		if not source then source = self.event.source end
		if not sourceEffect then sourceEffect = self.effect end
	end
	for i, q in pairs(self.queue) do
		if q == decision then
			table.remove(self.queue, i)
			break
		end
	end
	decision.sourceEffect = sourceEffect
	table.insert(self.queue, 1, decision)
end
function Battle:willAct()
	for _, q in pairs(self.queue) do
		if q.choice == 'move' or q.choice == 'switch' or q.choice == 'instaswitch' or q.choice == 'shift' then
			return q
		end
	end
	return nil
end
function Battle:willMove(pokemon)
	for _, q in pairs(self.queue) do
		if q.choice == 'move' and q.pokemon == pokemon then
			return q
		end
	end
	return nil
end
function Battle:cancelDecision(pokemon)
	local success = false
	for i = #self.queue, 1, -1 do
		if self.queue[i].pokemon == pokemon then
			table.remove(self.queue, i)
			success = true
		end
	end
	return success
end
function Battle:cancelMove(pokemon)
	for i, q in pairs(self.queue) do
		if q.choice == 'move' and q.pokemon == pokemon then
			table.remove(self.queue, i)
			return true
		end
	end
	return false
end
function Battle:willSwitch(pokemon)
	for _, q in pairs(self.queue) do
		if q.choice == 'switch' and q.pokemon == pokemon then
			return true
		end
	end
	return false
end
function Battle:runDecision(decision)
	local pokemon

	-- returns true if we ended in a callback
	local c = decision.choice
	--	self:debug('CHOICE:', c)
	if c == 'start' then
		--		local beginCallback = self:getFormat().onBegin
		--		if beginCallback then self:call(beginCallback) end

		self:add('start')
		self.p2:start()
		self.p1:start()

		if self.startWeather then
			self:setWeather(self.startWeather)
		end

		for _, pokemon in pairs(self.p1.pokemon) do
			self:singleEvent('Start', self:getEffect(pokemon.species), pokemon.speciesData, pokemon)
		end
		for _, pokemon in pairs(self.p2.pokemon) do
			self:singleEvent('Start', self:getEffect(pokemon.species), pokemon.speciesData, pokemon)
		end
		self.midTurn = true
	elseif c == 'move' then
		print('Move C')

		if not decision.pokemon.isActive then return false end

		print("1")

		if decision.pokemon.fainted then return false end

		print("2")
		
		--if self.isSafari then return end

		self:runMove(decision.move, decision.pokemon, self:getTarget(decision), decision.sourceEffect, decision.zmove)
		self:add()
	elseif c == 'megaEvo' then
	--	if self.isSafari then return end
		if decision.pokemon.canMegaEvo then self:runMegaEvo(decision.pokemon) end
	elseif c == 'beforeTurnMove' then
		if not decision.pokemon.isActive then return false end
		if decision.pokemon.fainted then return false end
		self:debug('before turn callback: ' .. decision.move.id)
		local target = self:getTarget(decision)
		if not target then return false end
		self:call(decision.move.beforeTurnCallback, decision.pokemon, target)
	elseif c == 'event' then
		self:runEvent(decision.event, decision.pokemon)
	elseif c == 'team' then
		local len = #decision.side.pokemon
		local newPokemon = {}
		for i = 1, len do
			local d = decision.team[i]
			newPokemon[i] = decision.side.pokemon[d]
			newPokemon[i].position = i
		end
		decision.side.pokemon = newPokemon

		-- we return here because the update event would crash since there are no active pokemon yet
		return
	elseif c == 'pass' then
		if not decision.priority or decision.priority <= 101 then return end
		if decision.pokemon then
			decision.pokemon.switchFlag = false
		end
	elseif c == 'instaswitch' or c == 'switch' then
	--	if self.isSafari then return end

		for _ = 1, 1 do -- for breakability
			if decision.pokemon then
				decision.pokemon.beingCalledBack = true
				local lastMove = self:getMove(decision.pokemon.lastMove)
				if lastMove.selfSwitch ~= 'copyvolatile' then
					self:runEvent('BeforeSwitchOut', decision.pokemon)
					self:eachEvent('Update')
				end
				if Not(self:runEvent('SwitchOut', decision.pokemon)) then
					-- Warning: DO NOT interrupt a switch-out
					-- if you just want to trap a pokemon.
					-- To trap a pokemon and prevent it from switching out,
					-- (e.g. Mean Look, Magnet Pull) use the 'trapped' flag
					-- instead. 
					break
				end
				self:singleEvent('End', self:getAbility(decision.pokemon.ability), decision.pokemon.abilityData, decision.pokemon)
			end
			if decision.pokemon and decision.pokemon.hp <= 0 and not decision.pokemon.fainted then
				-- a pokemon fainted from Pursuit before it could switch, the switch is canceled
				self:debug('A Pokemon can\'t switch between when it runs out of HP and when it faints')
				break
			end
			if decision.target.isActive then
				self:debug('Switch target is already active')
				break
			end
			if decision.choice == 'switch' and decision.pokemon.activeTurns == 1 then
				for _, foe in pairs(decision.pokemon.side.foe.active) do
					if foe ~= null and foe.isStale >= 2 then
						decision.pokemon.isStaleCon = decision.pokemon.isStaleCon + 1
						decision.pokemon.isStaleSource = 'switch'
						break
					end
				end
			end
			self:switchIn(decision.target, decision.pokemon.position)
		end
	elseif c == 'runSwitch' then
		self:runEvent('SwitchIn', decision.pokemon)
		if decision.pokemon.hp > 0 then
			decision.pokemon.isStarted = true
			if not decision.pokemon.fainted then
				self:singleEvent('Start', decision.pokemon:getAbility(), decision.pokemon.abilityData, decision.pokemon)
				self:singleEvent('Start', decision.pokemon:getItem(),    decision.pokemon.itemData,    decision.pokemon)
			end
			decision.pokemon.draggedIn = nil
		end
	elseif c == 'shift' then
		if not decision.pokemon.isActive then return false end
		if decision.pokemon.fainted then return false end
		decision.pokemon.activeTurns = decision.pokemon.activeTurns - 1
		self:swapPosition(decision.pokemon, 2)
		for _, foe in pairs(decision.pokemon.side.foe.active) do
			if foe ~= null and foe.isStale >= 2 then
				decision.pokemon.isStaleCon = decision.pokemon.isStaleCon + 1
				decision.pokemon.isStaleSource = 'switch'
				break
			end
		end
	elseif c == 'beforeTurn' then
		self:eachEvent('BeforeTurn')
	elseif c == 'residual' then
		self:add('')
		self:clearActiveMove(true)
		self:residualEvent('Residual')
	elseif c == 'useitem' then
		self:runUseItem(decision)
	end
	
	--[[
	if self.isSafari then
		if c == 'pokerun' then
			self:pokeTryRun()
		elseif c == 'gonear' then
			self:doGoNear()
		end
	end
--]]
	-- phazing (Roar, etc)

	local self = self
	local function checkForceSwitchFlag(a)
		if not a or a == null then return false end
		if a.hp > 0 and a.forceSwitchFlag then
			self:dragIn(a.side, a.position)
		end
		a.forceSwitchFlag = nil
	end
	for _, a in pairs(self.p1.active) do checkForceSwitchFlag(a) end
	for _, a in pairs(self.p2.active) do checkForceSwitchFlag(a) end

	self:clearActiveMove()

	-- fainting

	self:faintMessages()
	if self.ended then return true end

	-- switching (fainted pokemon, U-turn, Baton Pass, etc)

	if #self.queue == 0 then
		self:checkFainted()
	elseif decision.choice == 'pass' then
		self:eachEvent('Update')
		return false
	end

	local function hasSwitchFlag(a)
		return a ~= null and a.switchFlag or false
	end
	local function removeSwitchFlag(a)
		if a ~= null then
			a.switchFlag = false
		end
	end
	local p1switch = any(self.p1.active, hasSwitchFlag)
	local p2switch = any(self.p2.active, hasSwitchFlag)

	if p1switch and not self.p1:canSwitch() then
		for _, a in pairs(self.p1.active) do removeSwitchFlag(a) end
		p1switch = false
	end
	if p2switch and not self.p2:canSwitch() then
		for _, a in pairs(self.p2.active) do removeSwitchFlag(a) end
		p2switch = false
	end

	self:eachEvent('Update')
	if p1switch or p2switch then
		self:makeRequest('switch')
		return true
	end

	return false
end
function Battle:go()
	self:add('')
	if self.currentRequest ~= '' then
		self.currentRequest = ''
		self.currentRequestDetails = ''
	end

	if not self.midTurn then
		table.insert(self.queue, {choice = 'residual', priority = -100})
		table.insert(self.queue, 1, {choice = 'beforeTurn', priority = 100})
		self.midTurn = true
	end

	--	print('===== BATTLE QUEUE: =====')
	--	require(game.ServerStorage.Utilities).print_r(self.queue, 2)

	while #self.queue > 0 do
		local decision = table.remove(self.queue, 1)

		self:runDecision(decision)

		if self.currentRequest ~= '' or self.ended then return end
	end

	self:nextTurn()
	self.midTurn = false
	self.queue = {}
end
--[[
 * Changes a pokemon's decision, and inserts its new decision
 * in priority order.
 *
 * You'd normally want the OverrideDecision event (which doesn't
 * change priority order).
--]]
function Battle:changeDecision(pokemon, decision)
	self:cancelDecision(pokemon)
	if not decision.pokemon then decision.pokemon = pokemon end
	self:insertQueue(decision)
end
--[[
 * Takes a choice string passed from the client. Starts the next
 * turn if all required choices have been made.
--]]
function Battle:choose(player, sideid, choice, rqid)
	local side
	if sideid == 'p1' or sideid == 'p2' then side = self[sideid] end
	if not side then return end

	-- this condition can occur if the client sends a decision at the wrong time.
	if side.currentRequest == '' then return end

	-- Make sure the decision is for the right request.
	if rqid and tonumber(rqid) ~= self.rqid then return end

	if type(choice) == 'string' then choice = split(choice, ',') end

	if side.decision and side.decision.finalDecision and not side.decision.isIncomplete then
		self:debug("Can't override decision: the last pokemon could have been trapped or disabled")
		return
	end

	side.decision = self:parseChoice(player, choice, side)

	if self.p1.decision and self.p2.decision and (type(self.p1.decision)~='table' or not self.p1.decision.isIncomplete) and (type(self.p2.decision)~='table' or not self.p2.decision.isIncomplete) then
		self:commitDecisions()
	end
end
function Battle:commitDecisions()
	local oldQueue = self.queue
	self.queue = {}
	if self.p1.decision ~= true then
		self:addQueue(self.p1:resolveDecision())
	end
	if self.p2.decision ~= true then
		self:addQueue(self.p2:resolveDecision())
	end
	self:sortQueue()
	for _, q in pairs(oldQueue) do
		table.insert(self.queue, q)
	end
	-- debug: dump queue
	--	require(game.ServerStorage.Utilities).print_r(self.queue, 2)

	self.currentRequest = ''
	self.currentRequestDetails = ''
	self.p1.currentRequest = ''
	self.p2.currentRequest = ''

	self.p1.decision = true
	self.p2.decision = true

	self:go()
end
function Battle:undoChoice(sideid)
	local side
	if sideid == 'p1' or sideid == 'p2' then side = self[sideid] end
	if not side then return end

	if side.currentRequest == '' then return end

	if side.decision and side.decision.finalDecision then
		self:debug("Can't cancel decision: the last pokemon could have been trapped or disabled")
		return
	end

	side.decision = false
end
--[[
 * Parses a choice string passed from a client into a decision object
 * usable by the battle engine.
 *
 * Choice validation is also done here.
--]]
function Battle:parseChoice(player, choices, side)
	local prevSwitches = {}
	if side.currentRequest == '' then return true end

	if type(choices) == 'string' then choices = split(choices, ',') end

	local decisions = side.partialDecision or {}
	local len = #choices
	if side.currentRequest ~= 'teampreview' then len = #side.active end

	local isDefault
	local choosableTargets = {normal=true, any=true, adjacentAlly=true, adjacentAllyOrSelf=true, adjacentFoe=true}

	local freeSwitchCount = {switch=0, pass=0}
	if side.currentRequest == 'switch' then
		local canSwitch = 0
		local unfainted = 0
		for _, p in pairs(side.active) do
			if p ~= null and p.switchFlag then
				canSwitch = canSwitch + 1
			end
		end
		for i = #side.active+1, 6 do
			local p = side.pokemon[i]
			if p and p ~= null and not p.fainted then
				unfainted = unfainted + 1
			end
		end
		freeSwitchCount['switch'] = math.min(canSwitch, unfainted)
		freeSwitchCount['pass'] = --[[canSwitch]]#side.active - freeSwitchCount['switch']
		--		print('FreeSwitchCount:', freeSwitchCount['switch'], freeSwitchCount['pass'])
	end

	if side.isTwoPlayerSide then
		print('=== BEGIN PARSE TWOPLAYERCHOICE ===')
		print(player.Name, 'side', side.n)
		local missingIndex
		if side.currentRequest == 'switch' then
			local teamn = (player==self.listeningPlayers[side.id]) and 1 or 2
			local partnerteamn = 3-teamn
			if (side.active[partnerteamn] ~= null and not side.active[partnerteamn].fainted and not side.active[partnerteamn].switchFlag) or not side:canSwitch(partnerteamn) then
				missingIndex = true
				side.partialDecision = true
				--				print(string.format('replacing choice at [%d] with \'pass\' (was %s)', partnerteamn, choices[partnerteamn]))
				choices[partnerteamn] = 'pass'
			end
		elseif side.currentRequest == 'move' then
			local teamn = (player==self.listeningPlayers[side.id]) and 1 or 2
			local partnerteamn = 3-teamn
			if side.active[partnerteamn] == null or side.active[partnerteamn].fainted then
				missingIndex = true
				side.partialDecision = true
			end
		end
		--		print('--contents:')
		--		if not missingIndex then
		for i = 1, len do
			--				print(choices[i])
			local choice = trim(choices[i] or '')
			if choice == 'notmyhalf' then
				missingIndex = i
				--					break
			end
		end
		--		end
		--		print('--')
		if not missingIndex then
			print('2v2ERROR: NO MISSING INDEX; reqType:', side.currentRequest)
			return false
		end
	end

	for i = 1, len do
		for _=1,1 do
			local choice = trim(choices[i] or '')

			if choice == 'notmyhalf' then
				if not side.isTwoPlayerSide then return false end

				break--continue
			end

			local data = ''
			local firstSpaceIndex = indexOf(choice, ' ')
			if firstSpaceIndex then
				data = trim(string.sub(choice, firstSpaceIndex+1))
				choice = trim(string.sub(choice, 1, firstSpaceIndex-1))
			end

			print("choice:", choice, "data:", data)

			local pokemon = side.pokemon[i]

			local forceSwitchFirst = false

			local cr = side.currentRequest
			--			self:debug('parsing:', cr)
			if cr == 'teampreview' then
				if choice ~= 'team' or i > 1 then return false end
			elseif cr == 'move' then
				if choice == 'useitem' then
					local item = data
					local target = side.active[i]
					local i, t = data:match('^(.+)|(.+)$')
					if i and t then
						item = i
						t = tonumber(t)
						target = side.pokemon[t]
					end
					table.insert(decisions, {
						choice = 'useitem',
						priority = 999 - side.n,
						item = item,
						target = target,
						side = side,
					})
					break
				elseif choice == 'pass' then
					table.insert(decisions, {
						choice = 'pass'
					})
					break
				elseif choice == 'pokerun' then
					table.insert(decisions, {
						choice = 'pokerun',
					})
					break
				elseif choice == 'gonear' then
					table.insert(decisions, {
						choice = "gonear",
						priority = 999,
					})
					break
				else
					print("doing move")
					if i > #side.active then print(i.." is bigger than "..#side.active) return false end
					if Not(pokemon) or pokemon.fainted then
						print("poke is fainted")
						table.insert(decisions, {
							choice = 'pass',
						})
						break
					end
					local lockedMove = pokemon:getLockedMove()
					if lockedMove then
						local tl = self:runEvent('LockMoveTarget', pokemon)
						if tl == true then tl = nil end
						table.insert(decisions, {
							choice = 'move',
							pokemon = pokemon,
							targetLoc = tl or 0,
							move = lockedMove
						})
						break
					end
					if isDefault or choice == 'default' then
						isDefault = true
						local moveid = 'struggle'
						for _, m in pairs(pokemon:getMoves()) do
							if not m.disabled then
								moveid = m.id
								break
							end
						end
						table.insert(decisions, {
							choice = 'move',
							pokemon = pokemon,
							targetLoc = 0,
							move = moveid
						})
						break
					end
					if choice ~= 'move' and choice ~= 'switch' and choice ~= 'shift' then
						if i == 1 then return false end
						-- fallback
						choice = 'move'
						data = '1'
					end
				end
			elseif cr == 'switch' then
				if i > #side.active then return false end
				--				if Not(side.active[i]) or not side.active[i].switchFlag then
				--					if choice ~= 'pass' then table.insert(choices, i, 'pass') end
				--					table.insert(decisions, {
				--						choice = 'pass',
				--						pokemon = side.active[i],
				--						priority = 102
				--					})
				--					break
				--				end
				if choice ~= 'switch' and choice ~= 'pass' then return false end
				if side.n == 1 and #side.active == 1 and self.isTrainer then -- ugly hack
					freeSwitchCount.switch = 0
					freeSwitchCount.pass = 0
					forceSwitchFirst = true
				else
					freeSwitchCount[choice] = freeSwitchCount[choice] - 1
				end
			else
				return false
			end

			if choice == 'team' then
				local numPokemon = #side.pokemon
				if not data or #data > numPokemon then return false end

				local dataArr = {}
				for i = 1, numPokemon do dataArr[i] = i end
				local slotMap = deepcopy(dataArr) -- Inverse of `dataArr` (slotMap[dataArr[x]] == x)
				local tempSlot

				for j = 1, #data do
					local slot = tonumber(string.sub(data, j, j))
					if not slot or slot < 1 or slot > numPokemon then return false end
					if slotMap[slot] < j then return false end

					-- Keep track of team order so far
					tempSlot = dataArr[j]
					dataArr[j] = slot
					dataArr[slotMap[slot]] = tempSlot

					-- Update its inverse
					slotMap[tempSlot] = slotMap[slot]
					slotMap[slot] = j
				end

				table.insert(decisions, {
					choice = 'team',
					side = side,
					team = dataArr
				})
			elseif choice == 'switch' then
				if i > #side.active or i > #side.pokemon then break end

				data = tonumber(data) or 1
				data = math.min(data, #side.pokemon)

				if not side.pokemon[data] then
					self:debug("Can't switch: You can't switch to a pokemon that doesn't exist")
					return false
				end
				if data == i then
					self:debug("Can't switch: You can't switch to yourself")
					return false
				end
				if data <= #side.active then
					self:debug("Can't switch: You can't switch to an active pokemon")
					return false
				end
				if side.pokemon[data].fainted then
					self:debug("Can't switch: You can't switch to a fainted pokemon")
					return false
				end
				if prevSwitches[data] then
					self:debug("Can't switch: You can't switch to pokemon already queued to be switched")
					return false
				end
				prevSwitches[data] = true

				if side.currentRequest == 'move' then
					if pokemon.trapped then
						self:debug("Can't switch: The active pokemon is trapped")
						side:emitCallback('trapped', i)
						return false
					elseif pokemon.maybeTrapped then
						decisions.finalDecision = decisions.finalDecision or pokemon:isLastActive()
					end
				end

				if self.askToSwitchBeforeTrainerFlag then
					if side.n ~= 2 or not self.isTrainer then
						self.askToSwitchBeforeTrainerFlag = nil
						self:debug('TrainerAskToSwitchFlag raised improperly')
					else
						self.askToSwitchBeforeTrainerFlag = side.pokemon[data].name
						--						battleFunction:InvokeClient(self.listeningPlayers.p1, 'askToSwitchBeforeTrainer', side.pokemon[i].name)
					end
				end

				table.insert(decisions, {
					choice = (side.currentRequest=='switch' and 'instaswitch' or 'switch'),
					pokemon = side.pokemon[i],
					target = side.pokemon[data],
					priority = forceSwitchFirst and 9999 or nil,
				})
			elseif choice == 'shift' then
				if i > #side.active or i > #side.pokemon then break end
				if self.gameType ~= 'triples' then
					self:debug("Can't shift: You can't shift a pokemon to the center except in a triple battle")
					return false
				end
				if i == 2 then
					self:debug("Can't shift: You can't shift a pokemon to its own position")
					return false
				end

				table.insert(decisions, {
					choice = 'shift',
					pokemon = side.pokemon[i]
				})
			elseif choice == 'move' then
				local moveid = ''
				local targetLoc = 0
				local pokemon = side.pokemon[i]

				local targLocs = {[' 1']=1, [' 2']=2, [' 3']=3, [' -1']=-1, [' -2']=-2, [' -3']=-3}
				targetLoc = targLocs[string.sub(data, -2)] or targLocs[string.sub(data, -3)] or targetLoc

				if targetLoc ~= 0 then
					data = string.sub(data, 1, targetLoc>0 and -3 or -4)
				end

				local zmove = false

				if string.sub(data, -5) == ' zmov' then             
					zmove = true                    
					data = string.sub(data, 1, -6)
				elseif string.sub(data, -5) == ' mega' then
					table.insert(decisions, {
						choice = 'megaEvo',
						pokemon = pokemon
					})
					data = string.sub(data, 1, -6)
				end

				--	Parse the move identifier (name or index), according to the request sent to the client.
				--	If the move is not found, the decision is invalid without requiring further inspection.

				local requestMoves = pokemon:getRequestData().moves
				if string.find(data, '^[0-9]+$') then
					-- parse a one-based move index
					local moveIndex = tonumber(data)
					if not requestMoves[moveIndex] then
						self:debug("Can't use an unexpected move (index: "..moveIndex..")")
						return false
					end
					moveid = requestMoves[moveIndex].id
					if not targetLoc and #side.active > 1 and choosableTargets[requestMoves[moveIndex].target] then
						self:debug("Can't use the move without a target")
						return false
					end
				else
					-- parse a move name
					moveid = toId(data)
					if string.sub(moveid, 1, 11) == 'hiddenpower' then
						moveid = 'hiddenpower'
					end
					local isValidMove = false
					for _, m in pairs(requestMoves) do
						if m.id == moveid then
							if not targetLoc and #side.active > 1 and choosableTargets[m.target] then
								self:debug("Can't use the move without a target")
								return false
							end
							isValidMove = true
							break
						end
					end
					if not isValidMove then
						self:debug("Can't use an unexpected move (id: "..moveid..")")
						return false
					end
				end
				--				self:debug('Move ID:', moveid)

				--	Check whether the chosen move is really valid, accounting for effects active in battle,
				--	which could be unknown for the client.

				local moves = pokemon:getMoves()
				if #moves == 0 then
					-- Override decision and use Struggle if there are no enabled moves with PP
					moveid = 'struggle'
				else
					-- At least a move is valid. Check if the chosen one is.
					-- This may include Struggle in Hackmons.
					local isEnabled = false
					for _, m in pairs(moves) do
						if m.id == moveid then
							if not m.disabled then
								isEnabled = true
								break
							end
						end
					end
					if not isEnabled then --and not ZMove then
						-- request a different choice
						local sourceEffect = pokemon.disabledMoves[moveid] and pokemon.disabledMoves[moveid].sourceEffect
						side:emitCallback('cant', pokemon:toString(), sourceEffect and sourceEffect.fullname or '', moveid)

						--print('BAD REtURN')

						return false
					end
					-- the chosen move is valid
				end

				if pokemon.maybeDisabled then
					decisions.finalDecision = decisions.finalDecision or pokemon:isLastActive()
				end

				table.insert(decisions, {
					choice = 'move',
					pokemon = pokemon,
					targetLoc = targetLoc,
					zmove = zmove,
					move = moveid
				})
				zmove = false
			elseif choice == 'pass' then
				if i > #side.active or i > #side.pokemon then break end
				if side.currentRequest ~= 'switch' then
					self:debug("Can't pass the turn")
					return false
				end
				table.insert(decisions, {
					choice = 'pass',
					priority = 102,
					pokemon = side.active[i]
				})
			end
		end
	end
	if (freeSwitchCount['switch'] ~= 0 or freeSwitchCount['pass'] ~= 0) and not side.isTwoPlayerSide then-- > 0 then
		self:debug('Bad free switch count on parseChoice:', freeSwitchCount['switch'], freeSwitchCount['pass'])
		return false
	end

	if side.isTwoPlayerSide then
		if side.partialDecision then
			--			print('completed a choice')
			decisions.isIncomplete = nil
			side.partialDecision = nil
		else
			--			print('started a partial choice')
			decisions.isIncomplete = true
			side.partialDecision = decisions
		end
		--		print('=== END PARSE TWOPLAYERCHOICE ===')
	end

	if not self.supportCancel or isDefault then decisions.finalDecision = true end
	
	return decisions
end
function Battle:add(...)
	local args = {...}
	local hasFn = false
	for _, f in pairs(args) do
		if type(f) == 'function' then
			hasFn = true
			break
		end
	end
	if not hasFn then
		table.insert(self.log, '|' .. concat(args, '|'))
	else
		--		table.insert(self.log, '|split')
		--		for _, side in pairs({null, self.sides[1], self.sides[2], true}) do
		local line = ''
		for _, arg in pairs(args) do
			line = line .. '|'
			if type(arg) == 'function' then
				line = line .. arg(true)--side)
			else
				line = line .. arg
			end
		end
		table.insert(self.log, line)
		--		end
	end
end
function Battle:addMove(...)
	--	require(game.ReplicatedStorage.src.Utilities).print_r({...})
	table.insert(self.log, '|' .. concat({...}, '|'))
	self.lastMoveLine = #self.log
end
function Battle:attrLastMove(...)
	self.log[self.lastMoveLine] = self.log[self.lastMoveLine] .. '|' .. table.concat({...}, '|')
end
function Battle:debug(...)
	warn('DEBUG:', ...)
	--	if self:getFormat().debug then
	--		self:add('debug', activity)
	--	end
end
function Battle:debugError(...)
	--	self:add('debug', activity)
	warn('DEBUG (ERROR):', ...)
end


function Battle:join(player, slot, name, team)--::join
	if self.p1 and self.p1.isActive and self.p2 and self.p2.isActive then return false end
	if (self.p1 and self.p1.isActive and self.p1.name == name) or (self.p2 and self.p2.isActive and self.p2.name == name) then return false end
	local side
	local megaAdornment
	-- get team
	if player == 'npc' then
		megaAdornment = 'true'
	elseif player then
		local s, r = pcall(function()
			team = _f.PlayerDataService[player]:getBattleTeam(self.pvp and true or false, self.pvp and team or nil)
		end)
		--		if not s then
		--			print('ERROR DURING GETPLAYERBATTLETEAM:')
		--			print(r)
		--		end
		pcall(function()
			local bd = _f.PlayerDataService[player]:getBagDataById('megakeystone', 5)
			if bd and bd.quantity > 0 then
				megaAdornment = 'true' -- todo: allow different adornments
			end
		end)
		--[[
		pcall(function()
			if player.Name == 'WoahhBob' then
				self.WIN_DEBUG = true
			end
		end)
		--]]
	end
	--
	if self.p1 and self.p1.isActive or slot == 'p2' or slot == 2 then
		if self.started then
			self.p2.name = name
		else
			side = BattleSide:new(nil, name, self, 2, team, megaAdornment)
			self.p2 = side
			self.sides[2] = self.p2
			if self.npcTrainerData then
				side.difficulty = self.npcTrainerData.TrainerDifficulty
			end
		end
		self.p2.isActive = true
		self:add('player', 'p2', self.p2.name)
	else
		if self.started then
			self.p1.name = name
		elseif self.npcPartner then
			local team2, name2 = self:getNPCPartnerTeam(self.npcPartner)
			print("npcPartner:", name2)
			side = TwoPlayerSide:new(nil, {Name = name, plrObj = player}, {Name = name2}, self, 1, team, team2)--, megaAdornment)
			side.isSecondPlayerNpc = true
			self.p1 = side
			self.sides[1] = side
		else
			side = BattleSide:new(nil, name, self, 1, team, megaAdornment)
			self.p1 = side
			self.sides[1] = self.p1
		end
		self.p1.isActive = true
		self:add('player', 'p1', self.p1.name)
	end
	if side and player then
		side.player = player
		-- move userId assignment here?
	end
	self:start()
	return true
end
function Battle:join2v2(player, teamOrder)--::join2v2
	if not self.is2v2 then return end
	-- confirm location of player
	local playerIndex
	for i, member in pairs(self.roster) do
		if member == player then
			playerIndex = i
			break
		end
	end
	if not playerIndex then return end
	-- filter/verify teamOrder
	local team = {}
	local teamData = self.playerTeams[player]
	if type(teamOrder) == 'table' and #teamOrder > 0 then
		local already = {}
		for i = 1, #teamOrder do
			local v = teamOrder[i]
			if type(v) == 'number' then
				v = math.floor(v)
				-- ignore repeats
				if not already[v] then
					already[v] = true
					local pd = teamData[v]
					pd.originalPartyIndex = v
					if pd then
						table.insert(team, pd)
					end
				end
			end
		end
	else
		-- if they pass garbage, just give them their first non-egg
		for i, pd in pairs(teamData) do
			if not pd.egg then
				pd.originalPartyIndex = i
				team[1] = pd
				break
			end
		end
	end
	-- try to create TwoPlayerSide
	local siden = 2-(playerIndex%2)
	local posOnSide = math.floor((playerIndex+1)/2)
	if not self['p'..siden] then
		local partnerIndex = ((siden==1) and 4 or 6) - playerIndex
		local pteam = self['teamForPlayer'..partnerIndex]
		if pteam then
			self['teamForPlayer'..partnerIndex] = nil
			local team1 = playerIndex < 3 and team or pteam
			local team2 = playerIndex < 3 and pteam or team
			local player1 = siden==1 and self.roster[1] or self.roster[2]
			local player2 = siden==1 and self.roster[3] or self.roster[4]
			local side = TwoPlayerSide:new(nil, player1, player2, self, siden, team1, team2)
			self['p'..siden] = side
			self.sides[siden] = side
			side.isActive = true
		else
			self['teamForPlayer'..playerIndex] = team
		end
	end
	-- register player
	self.listeningPlayers['p'..playerIndex] = player
	-- try to start
	self:start()
end
--[[Battle:rename = function(slot, name, avatar) {
	if slot == 'p1' or slot == 'p2') {
		local side = self[slot];
		side.name = name;
		if avatar) side.avatar = avatar;
		self.add('player', slot, name, side.avatar);
	}
};
Battle:leave = function(slot) {
	if slot == 'p1' or slot == 'p2') {
		local side = self[slot];
		if not side) {
			console.log('**** ' + slot + ' tried to leave before it was possible in ' + self.id);
			require('./crashlogger.js')({stack: '**** ' + slot + ' tried to leave before it was possible in ' + self.id}, 'A simulator process');
			return;
		}

		side.emitRequest(null);
		side.isActive = false;
		self.add('player', slot);
		self.active = false;
	}
	return true;
};--]]
function Battle:sendUpdates(logPos, alreadyEnded)
	if self.p1 and self.p2 then
		local inactiveSide = 0
		if not self.p1.isActive and self.p2.isActive then
			inactiveSide = 1
		elseif self.p1.isActive and not self.p2.isActive then
			inactiveSide = 2
		elseif not self.p1.decision and self.p2.decision then
			inactiveSide = 1
		elseif self.p1.decision and not self.p2.decision then
			inactiveSide = 2
		end
		if inactiveSide ~= self.inactiveSide then
			self:send('inactiveside', inactiveSide)
			self.inactiveSide = inactiveSide
		end
	end

	if #self.log >= logPos then
		if self.ended and alreadyEnded==false then
			if self.rated then-- or Config.logchallenges then
				local log = {
					turns = self.turn,
					p1 = self.p1.name,
					p2 = self.p2.name,
					p1team = self.p1.team,
					p2team = self.p2.team,
					log = self.log
				}
				self:send('log', jsonEncode(log))
			end
			self:send('score', {self.p1.pokemonLeft, self.p2.pokemonLeft})
			local args = {self.winner, unpack(slice(self.log, logPos))} -- REPLAYS I don't think we use the winner stored here... perhaps should remove
			local td = self:getDataForTransferToPlayer('p1')
			--			self:sendToPlayer('p1', 'winupdate', args, td)--, self.p1:getRelevantDataChanges())
			--			--td = self:getDataForTransferToPlayer('p2')
			--			self:sendToPlayer('p2', 'winupdate', args, td)--, self.p2:getRelevantDataChanges())
			for _, player in pairs(self.listeningPlayers) do
				self:sendToPlayer(player, 'winupdate', args, td)
			end
			if #self.spectators > 0 then
				td = self:addDataForTransferToSpectator(td)
				for _, spectator in pairs(self.spectators) do
					self:sendToPlayer(spectator, 'winupdate', args, td)
				end
			end
		else
			local log = slice(self.log, logPos)
			local td = self:getDataForTransferToPlayer('p1')
			--			self:sendToPlayer('p1', 'update', log, td)
			--			--td = self:getDataForTransferToPlayer('p2')
			--			self:sendToPlayer('p2', 'update', log, td)
			for _, player in pairs(self.listeningPlayers) do
				self:sendToPlayer(player, 'update', log, td)
			end
			if #self.spectators > 0 then
				td = self:addDataForTransferToSpectator(td)
				for _, spectator in pairs(self.spectators) do
					self:sendToPlayer(spectator, 'update', log, td)
				end
			end
		end
	end
	--	print(self.currentRequest)
end
function Battle:send(...)
	for _, p in pairs(self.listeningPlayers) do
		--		local s = pcall(function(...)
		network:post('BattleEvent', p, self.id, ...)--battleEvent:FireClient(p, self.id, ...)
		--		end, ...)
		--		if not s then
		--			print(...)
		--		end
	end
	--	if select(1, ...) == 'inactiveside' then
	--		for _, s in pairs(self.spectators) do
	--			network:post('BattleEvent', s, self.id, ...)
	--		end
	--	end
end
function Battle:sendToPlayer(p, ...)
	if type(p) == 'string' then
		p = self.listeningPlayers[p]
	end
	if not p then return end
	--	print(require(game.ReplicatedStorage.Utilities).print_r({...}))
	local s, r = pcall(function(...)
		network:post('BattleEvent', p, self.id, ...)--battleEvent:FireClient(p, self.id, ...)
	end, ...)
	if not s and r:find('tables cannot be cyclic') then
		warn('attempt to pass cyclic table:')
		require(game.ServerStorage.Utilities).print_r({...})
	end
end
function Battle:receive(fn, ...)--::receive
	--	table.insert(self.messageLog, concat({fn, ...}, ' '))
	local logPos = #self.log + 1
	local alreadyEnded = self.ended

	if type(self[fn]) ~= 'function' then
		warn('Battle '..self.id..' received unknown request '..tostring(fn))
		return
	end

	self[fn](self, ...)
	if fn == 'remove' then return end

	self:sendUpdates(logPos, alreadyEnded)
end

-- SAFARI FNS <BlueGuyCodes>

function Battle:pokeTryRun()
	if not self.isSafari then return end
	local baseRate = 100 -- 1 : testing only
	local berryRate = 0 

	if self.berryRate then
		for i, v in pairs(self.berryRate) do
			if berryRate + v < 30 then
				berryRate += v
			else
				break
			end	
		end
	end

	if self.nearRate then
		berryRate -= self.nearRate 
	end	

	if berryRate < 0 then
		berryRate = 0
	end

	if math.random(baseRate+berryRate) <= 1 then
		self:add('message', 'The wild '..self.wildFoePokemon.name..' fled from battle!')
		self:win('p1')
	end
end

function Battle:throwBerry(pokemon, berry)
	if not self.isSafari then return end
	local colors = {
		["Razz Berry"] = 'Bright red',
		["Pinap Berry"] = 'Light yellow',
		["Bluk Berry"] = 'Bright bluish violet',
		["Wepear Berry"] = 'Sea green',
		["Nanab Berry"] = 'Light pink',
		["Lum Berry"] = 'Shamrock',
	}

	local berryName = berry.name

	if not self.berryRate then
		self.berryRate = {}
	end

	local rate, status = self:getBerryRate(pokemon, berry)
	--print(rate, status)
	table.insert(self.berryRate, rate)
	--print(self.berryRate)

	-- poke, rate, berryName, berryColor
	self:add('-animBerryThrow', pokemon, status, berryName, colors[berryName])
end

function Battle:getBerryRate(pokemon, berry)
	if not self.isSafari then return end
	local ftnTable = { -- flavour to nature
		"atk", -- Spicy
		"spa", -- Dry
		"spe", -- Sweet
		"spd", -- Bitter
		"def", -- Sour
	}

	local nature = pokemon:getNature()
	local berryFlavour = berry.flavour
	local likedFlavour = table.find(ftnTable, nature.plus)
	local hatedFlavour = table.find(ftnTable, nature.minus)
	local h, l

	for i, v in pairs(berryFlavour) do
		if i == likedFlavour and v ~= 0 then
			l = v/5
		elseif i == hatedFlavour and v ~= 0 then
			h = -v/5
		end
	end

	-- 10, 15, 20, 25, 30, 40 - if div by 5: 2, 3, 4, 5, 6, 8

	local berryRate, likeStatus = 1, 1

	if hatedFlavour and likedFlavour then
		berryRate, likeStatus = math.floor(likedFlavour/1.3+0.5), 2
	else
		if likedFlavour then
			berryRate, likeStatus = likedFlavour, 3
		elseif hatedFlavour then
			berryRate, likeStatus = hatedFlavour, 1
		end
	end

	return berryRate, likeStatus
end

function Battle:doGoNear()
	if not self.isSafari then return end

	if not self.nearRate then
		self.nearRate = 1
	end

	self.nearRate += 1
	self:add('message', self.p1.name .. ' drew closer to the wild ' .. self.wildFoePokemon.name .. '...')
end

--[[ 
	OTHER OLD BERRY BS
		--local list = {10, 15, 20, 25, 30, 40}
	
	--for i, v in pairs(list) do
	--	local a = -(v/5/1.3)
	--	print(a, math.floor(a/3+0.5)) 
	--end
	
	-- local hatedRate, likedRate = 
	OLD BERRY RATE BS
	
	local berryToRate = {
		lumberry = 3,
		nanabberry = 3,
		razzberry = 2,
		blukberry = 2,
		weaperberry = 2,
		pinapberry = 2,
	}

	if berryToRate[berry] then
		berryRate = berryToRate[berry]
	else
		local berryType = berry.naturalGift.type
		if berryType then
			local t = pokemon:getTypes()
			if t[1] == berryType or t[2] == berryType then
				berryRate = 3.5
			end
		end
	end
]]

-- ADDITIONS
-- escape
function Battle:tryRun()
	if self.battleType ~= BATTLE_TYPE_WILD then return false end
	if self.cannotRun then
		return 'partial'
	end
	self:residualEvent('BattleEnd')
	self:applyPostBattleUpdates()
	return true
	--	local pokemon = self.p1.active[1]
	--	if pokemon.volatiles['partiallytrapped'] then
	--		return 'partial'
	--	end
	--	self.runAttempts = self.runAttempts + 1
	--	if pokemon.trapped or pokemon.maybeTrapped then return false end
	--	local A = pokemon:getStat('spd', true, true)
	--	local B = math.max(1, self.p2.active[1]:getStat('spd', true, true))
	--	local C = self.runAttempts
	--	local F = (A * 128 / B + 30 * C)-- % 256
	--	return math.random(256)-1 < F
end
function Battle:isTrapped(sideId, pokemonSlot) -- called as request from client when attempting to switch when maybeTrapped
	local pokemon = self[sideId].active[pokemonSlot]
	if pokemon.trapped then
		local sName, eName = '', ''
		pcall(function() sName = pokemon.trappedBy.source:toString() end)
		pcall(function() eName = pokemon.trappedBy.effectName end)
		return true, sName, eName
	end
	return false
end
-- exp
function Battle:indexParticipants(pokemon)
	if not self.yieldExp then return end
	for _, foe in pairs(pokemon.side.foe.active) do
		if foe ~= null then
			if pokemon.side.n == 1 then
				foe.participatingFoes[pokemon] = true
			elseif pokemon.side.n == 2 then
				pokemon.participatingFoes[foe] = true
			end
		end
	end
end
function Battle:queueExp(faintedPokemon, participants)
	if not self.yieldExp or faintedPokemon.side.n ~= 2 then return end
	local giveExp = self.giveExp
	local a = self.isTrainer and 1.5 or 1
	local b, evs = self:getExpYield(faintedPokemon.template)
	local L = faintedPokemon.level
	local p = self.RoPowerExpMultiplier or 1 -- O-Power
	local powerItems = {'powerweight','powerbracer','powerbelt','powerlens','powerband','poweranklet'}
	local function add(pokemon, s)
		local t = pokemon.isNotOT and 1.5 or 1
		local item = pokemon:getItem().id
		local e = item == 'luckyegg' and 1.5 or 1
		local f = 1 -- Affection               (not implemented)
		local v = 1 -- Can evolve but hasn't   (not implemented)
		local exp = math.floor(a * t * b * e * L * p * f * v / (7 * s))
		giveExp[pokemon] = giveExp[pokemon] or {0, 0, 0, 0, 0, 0, 0, false, false}
		giveExp[pokemon][1] = giveExp[pokemon][1] + exp
		local evMult = self.RoPowerEVMultiplier or 1
		for i = 1, 6 do
			local e = evs[i] or 0
			if item == powerItems[i] then e = e + 4 end
			if item == 'machobrace' then e = e * 2 end
			if pokemon.pokerus then e = e * 2 end
			giveExp[pokemon][i+1] = giveExp[pokemon][i+1] + e*evMult
		end
		if p > 1 or t > 1 or e > 1 or f > 1 then -- boosted
			giveExp[pokemon][8] = true
		end
	end
	for pokemon in pairs(participants) do
		add(pokemon, 1)
		giveExp[pokemon][9] = true
	end
	if self.expShare then
		for _, pokemon in pairs(self.p1.pokemon) do
			if pokemon ~= null and not participants[pokemon] then
				add(pokemon, 2)
			end
		end
	end
end
function Battle:awardQueuedExp()
	if not self.yieldExp or not self.giveExp then return end
	local other = {}
	local function give(pokemon, amount)
		local playerPokemon = pokemon:getPlayerPokemon()
		if not playerPokemon then return end
		local maxExp = playerPokemon:getRequiredExperienceForLevel(_f.levelCap)
		local expBefore = playerPokemon.experience
		if expBefore >= maxExp then return end

		local hpMissing = pokemon.maxhp - pokemon.hp

		playerPokemon.experience = math.min(maxExp, expBefore + amount)
		local difference = playerPokemon.experience - expBefore

		local levelStart = playerPokemon.level
		local levelEnd = playerPokemon:getLevelFromExperience()

		if levelEnd > levelStart then
			self.leveledUpPokemon = self.leveledUpPokemon or {}
			self.leveledUpPokemon[pokemon] = true

			playerPokemon.level = levelEnd
			return difference, function()
				local levelUpMoves = playerPokemon:getLearnedMoves().levelUp or {}
				local nextLevelUpMove
				for i, lum in pairs(levelUpMoves) do
					if lum[1] >= levelStart then
						nextLevelUpMove = i
						break
					end
				end
				for level = levelStart+1, levelEnd do
					playerPokemon:addHappiness(5, 4, 3)
					pokemon.level = level
					pokemon:recalculateStats()
					pokemon.hp = pokemon.maxhp - hpMissing
					self:add('-lvlup', pokemon, level, pokemon.getHealth, (playerPokemon.num == 686 and '[sample]' or nil))

					-- check for level-up moves
					if nextLevelUpMove and levelUpMoves[nextLevelUpMove][1] == level then
						local moveset = levelUpMoves[nextLevelUpMove]
						nextLevelUpMove = nextLevelUpMove<#levelUpMoves and (nextLevelUpMove+1) or nil
						self:tryLearnLevelUpMoves(pokemon, playerPokemon, moveset)
					end
				end
				pcall(function()
					if playerPokemon:isLead() then
						_f.Network:post('PDChanged', playerPokemon.PlayerData.player, 'firstNonEggLevel', playerPokemon.level)
					end
				end)
				playerPokemon.maxhp = pokemon.maxhp -- is this okay to assume?
			end
		end
		return difference, nil
	end
	local function process(pokemon, xp)
		if pokemon.isEgg or pokemon.hp <= 0 or pokemon.fainted then return end
		if xp[9] then
			local difference, levelUpFunction = give(pokemon, xp[1])
			if difference then
				self:add('-exp', pokemon, difference, xp[8] and '[boosted]' or nil)
				if levelUpFunction then
					levelUpFunction()
				end
				pokemon.expProg = nil
				self:add('-xpr', pokemon, pokemon.getHealth)
			end
		else
			table.insert(other, {pokemon, xp[1]})
		end
		-- award EVs
		local stats = {'hp','atk','def','spa','spd','spe'}
		local total = 0
		for i = 1, 6 do
			total = total + pokemon.evs[stats[i]]
		end
		for i = 1, 6 do
			if total >= 510 then break end
			local s = stats[i]
			local e = pokemon.evs[s]
			local gain = xp[i+1]
			if i == 1 and pokemon.set.id == 'shedinja' then gain = 0 end -- prevent Shedinja from gaining HP EVs
			pokemon.evs[s] = math.min(252, e + gain, e + 510-total)
			local d = pokemon.evs[s] - e
			total = total + d
		end
	end
	local giveExp = self.giveExp
	for _, pokemon in pairs(self.p1.active) do -- start with active pokemon, in order
		if pokemon ~= null and giveExp[pokemon] then
			process(pokemon, giveExp[pokemon])
			giveExp[pokemon] = nil
		end
	end
	for _, pokemon in pairs(self.p1.pokemon) do -- remaining inactive pokemon, in order
		if pokemon ~= null and giveExp[pokemon] then
			process(pokemon, giveExp[pokemon])
			giveExp[pokemon] = nil
		end
	end
	if #other > 0 then -- exp shared pokemon
		self:add('-partyexp')
		for _, pxp in pairs(other) do
			local pokemon, amount = unpack(pxp)
			local _, levelUpFunction = give(pokemon, amount)
			if levelUpFunction then
				levelUpFunction()
			end
			pokemon.expProg = nil
		end
	end
end
function Battle:tryLearnLevelUpMoves(pokemon, playerPokemon, moveset, evolution_arq_id) -- evolution gets ugly; should have used PD_decisions, but meh...
	for i = 2, #moveset do
		local md = _f.Database.MoveByNumber[moveset[i] ]
		-- make sure move is not already known
		local known = false
		for _, m in pairs(playerPokemon.moves) do
			if m.id == md.id then
				known = true
				break
			end
		end
		if not known then
			-- try to learn
			local nMoves = #playerPokemon.moves
			local evoAutoLearn
			if evolution_arq_id then
				local evo = self.arq_data[evolution_arq_id]
				evoAutoLearn = evo.autoLearn
				if not evoAutoLearn then
					evoAutoLearn = {}
					evo.autoLearn = evoAutoLearn
				end
				nMoves = nMoves + #evoAutoLearn
			end
			if nMoves < 4 then
				if evolution_arq_id then
					evoAutoLearn[#evoAutoLearn+1] = md.id
				else
					local slot = nMoves+1
					local move = { -- battle move structure
						move = md.name,
						id = md.id,
						pp = md.pp,
						maxpp = md.pp,
						target = (md.nonGhostTarget and not pokemon:hasType('Ghost')) and md.nonGhostTarget or md.target,
						disabled = false,
						used = false,
					}
					pokemon.baseMoveset[slot] = move
					pokemon.moveset    [slot] = move
					pokemon.moves      [slot] = md.id
					playerPokemon.moves[slot] = {id = md.id}
				end
				self:add('-learnedmove', pokemon, md.name, (evolution_arq_id and '[evo]' or nil))
			else
				local arq_id = self.arq_count
				self.arq_count = arq_id + 1

				self:add('learnmove', pokemon, md.name, arq_id, (evolution_arq_id and '[evo]' or nil))
				self.arq_data[arq_id] = {
					type = 'move',
					pokemon = pokemon,
					playerPokemon = playerPokemon,
					move = md,
					evolution_arq_id = evolution_arq_id,
					completed = false,
				}
			end
		end
	end
end
function Battle:getLearnMoveData(arq_id)
	if not arq_id then return end
	local arq_data = self.arq_data[arq_id]
	if not arq_data or arq_data.completed or arq_data.type ~= 'move' then return end
	local moves = {}
	-- this ensures it is always up-to-date
	for _, m in pairs(arq_data.playerPokemon.moves) do
		local move = _f.Database.MoveById[m.id]
		moves[#moves+1] = {
			name = move.name,
			category = move.category,
			type = move.type,
			power = move.basePower,
			accuracy = move.accuracy,
			pp = move.pp,
			desc = move.desc,
		}
	end
	local move = arq_data.move
	moves[#moves+1] = {
		name = move.name,
		category = move.category,
		type = move.type,
		power = move.basePower,
		accuracy = move.accuracy,
		pp = move.pp,
		desc = move.desc,
	}
	return moves
end
function Battle:learnMove(arq_id, slot)
	if not arq_id then return end
	local arq_data = self.arq_data[arq_id]
	if not arq_data or arq_data.completed or arq_data.type ~= 'move' then return end
	arq_data.completed = true
	if not slot then return end

	if arq_data.evolution_arq_id then -- can only learn the move if the evolution was accepted
		local evo_arq_data = self.arq_data[arq_data.evolution_arq_id]
		if not evo_arq_data or not evo_arq_data.allowed then return end
	end

	local pokemon = arq_data.pokemon
	for _, move in pairs(arq_data.playerPokemon.moves) do
		if move.id == arq_data.move.id then return end -- prevent learn same move twice
	end
	local md = self:getMove(arq_data.move.id)
	local move = {
		move = md.name,
		id = md.id,
		pp = md.pp,
		maxpp = md.pp,
		target = (md.nonGhostTarget and not pokemon:hasType('Ghost')) and md.nonGhostTarget or md.target,
		disabled = false,
		used = false,
	}
	pokemon.baseMoveset[slot] = move
	pokemon.moveset    [slot] = move
	pokemon.moves      [slot] = md.id
	arq_data.playerPokemon.moves[slot] = {id = md.id}
end
function Battle:getEvolutionData(index)
	for _, p in pairs(self.p1.pokemon) do
		if p.index == index then
			pcall(function()
				if p.evoData.evo.moves then
					p.evoData.known = p:getPlayerPokemon():getCurrentMovesData()
				end
			end)
			return p.evoData
		end
	end
end
--[[function Battle:evolvePokemon(arq_id, allowed)
	if not arq_id then return end
	local arq_data = self.arq_data[arq_id]
	if not arq_data or arq_data.completed or arq_data.type ~= 'evolve' then return end
	arq_data.completed = true
	
	arq_data.allowed = allowed
	if not allowed then return end
	
	local pokemon = arq_data.playerPokemon
	pokemon:evolve(arq_data.evolutionData, arq_data.consumeHeldItem)
	if arq_data.autoLearn then
		-- don't bother with BattlePokemons' moves because the battle is over when evolution occurs
		for _, moveId in pairs(arq_data.autoLearn) do
			if #pokemon.moves >= 4 then break end
			local knows = false
			for _, move in pairs(pokemon.moves) do
				if move.id == moveId then
					knows = true
					break
				end
			end
			if not knows then
				pokemon.moves[#pokemon.moves+1] = {id = moveId}
			end
		end
	end
end]]
-- use items
function Battle:tryCapture(pokemon, pokeball) -- todo: DIG, FLY, etc.
	local function getShakes()
		if pokeball == 'masterball' then -- or first route
			return 4
		end
		local function round(n)
			return math.floor(n*4096)/4096
		end
		local rate, ball, status, opower, nearRate = pokemon.template.captureRate, 1, 1, (self.RoPowerCatchMultiplier or 1), 1
		if not rate and pokemon.template.baseSpecies then
			rate = self:getTemplate(toId(pokemon.template.baseSpecies)).captureRate
		end

		if pokeball == 'greatball' or pokeball == 'sportball' or pokeball == 'safariball' then
			ball = 1.5
		elseif pokeball == 'ultraball' then
			ball = 2
		elseif pokeball == 'cherishball' then
			ball = 0
		elseif pokeball == 'netball' then
			local t = pokemon:getTypes()
			if t[1] == 'Water' or t[2] == 'Water' or t[1] == 'Bug' or t[2] == 'Bug' then
				ball = 3
			end
		elseif pokeball == 'nestball' then
			ball = math.max(1, (41 - pokemon.level) / 10)
		elseif pokeball == 'diveball' then
			--todo 3.5 when in water
		elseif pokeball == 'repeatball' then
			if self.alreadyOwnsFoeSpecies then
				ball = 3
			end
		elseif pokeball == 'timerball' then
			ball = math.min(4, 1 + self.turn*1229/4096)
		elseif pokeball == 'quickball' then
			if self.turn == 1 then
				ball = 5
			end
		elseif pokeball == 'duskball' then
			if self.isDark then
				ball = 3.5
			end
		else
			local typeBalls = {
				colorlessball = 'Normal',
				insectball = 'Bug',
				dreadball = 'Dark',
				dracoball = 'Dragon',
				zapball = 'Electric',
				fistball = 'Fighting',
				flameball = 'Fire',
				skyball = 'Flying',
				spookyball = 'Ghost',
				meadowball = 'Grass',
				earthball = 'Ground',
				icicleball = 'Ice',
				toxicball = 'Poison',
				mindball = 'Psychic',
				stoneball = 'Rock',
				steelball = 'Steel',
				splashball = 'Water',
				pixieball = 'Fairy'
			}
			local ballType = typeBalls[pokeball]
			if ballType then
				local t = pokemon:getTypes()
				if t[1] == ballType or t[2] == ballType then
					ball = 3.5
				end
			end
		end
		rate = math.min(255, math.floor(rate))

		if pokemon.status == 'slp' or pokemon.status == 'frz' then
			status = 2.5
		elseif pokemon.status == 'brn' or pokemon.status == 'par' or pokemon.status == 'psn' or pokemon.status == 'tox' then
			status = 1.5
		end

--[[
		if self.isSafari then
			nearRate = self.nearRate or 1
		end
		--]]

		local a = round(round(round(round((3*pokemon.maxhp - 2*pokemon.hp) * rate * ball * nearRate) / (3*pokemon.maxhp)) * status) * opower)
		local b = math.floor(65536 / round(round(255/a)^0.1875))

		local m = 0
		local sc = self.numSpeciesCaught
		if not sc then
			sc = select(2, _f.PlayerDataService[self.p1.player]:countSeenAndOwnedPokemon()) -- just calculate when needed, cache for rest of battle
			self.numSpeciesCaught = sc
		end
		if sc then
			if sc > 600 then
				m = 2.5
			elseif sc > 450 then
				m = 2
			elseif sc > 300 then
				m = 1.5
			elseif sc > 150 then
				m = 1
			elseif sc > 30 then
				m = 0.5
			end
		end
		local c = math.floor(a * m / 6)
		local critical = math.floor(math.random()*256) < c

		if a > 255 then
			if critical then
				return 1, true
			else
				return 4
			end
		end

		local shakes = 0
		for i = 1, 4 do
			local r = math.floor(math.random()*65536) -- does this hit all non-negative integers less than 65536?
			if r >= b then break end
			if critical then
				return 1, true
			end
			shakes = shakes + 1
		end
		return shakes, critical
	end
	local shakes, critical = getShakes()
--	local sbCount = self.isSafari and self.SBCount or nil
--	print("server sbCount:", tostring(sbCount))

self:add('-capture', pokemon, pokeball, shakes, critical and '[crit]' or nil)
if (critical and shakes == 1) or shakes == 4 then
		-- wild pokemon caught
		local pokemon = self.p2.active[1] -- may not always be true (horde, etc.)
		local playerPokemon = self.wildFoePokemon
		self.wildFoePokemon = nil -- so it doesn't get removeed
		local PlayerData = playerPokemon.PlayerData

		playerPokemon.hp = pokemon.hp
		if pokemon.status == '' then
			playerPokemon.status = nil
		else
			playerPokemon.status = pokemon.status=='tox' and 'psn' or pokemon.status -- what about sleep
		end
		for m, move in pairs(pokemon.moves) do
			local pMove = playerPokemon.moves[m]
			if pMove then
				local id = pMove.id
				if id ~= move.id and id == 'sketch' then
					pMove.id = move.id
				end
				pMove.pp = move.pp
			else
				warn('Wild ' .. pokemon.name .. ' has no move in slot ' .. m .. ' (attempted to update pp for this move)')
			end
		end

		local ballNum
		for i, ballName in pairs(_f.ServerP.balls) do
			if ballName == pokeball then
				ballNum = i
				break
			end
		end
		playerPokemon.pokeball = ballNum or 1
		if not PlayerData:hasOwnedPokemon(playerPokemon.num) then
			self:add('-dex', pokemon)
		end

		local arq_id = self.arq_count
		self.arq_count = arq_id + 1

		self:add('nickname', pokemon, arq_id)
		self.arq_data[arq_id] = {
			type = 'nickname',
			playerPokemon = playerPokemon,
			completed = false,
		}
		local box = PlayerData:caughtPokemon(playerPokemon)
		if box then
			-- OVH  remove THE PLAYERPOKEMON ??
			self:add('-xfr', pokemon, box)
		end

		self:queueExp(pokemon, pokemon.participatingFoes)
		self:awardQueuedExp()
		self:win('p1')
	end
end
function Battle:nicknamePokemon(arq_id, nickname)
	if not arq_id then return end
	local arq_data = self.arq_data[arq_id]
	if not arq_data or arq_data.completed or arq_data.type ~= 'nickname' then return end
	arq_data.completed = true
	if not nickname then return end

	arq_data.playerPokemon:giveNickname(nickname)
end
function Battle:runUseItem(decision)
	if self.pvp then return false end
	--	decision structure: {
	--		choice = 'useitem'
	--		priority = 999 - side.n (so that p1 uses item first, then p2; before everything else)
	--		item = item
	--		target = a BattlePokemon (on the side of the user)
	--		side = the user's BattleSide
	--	}
	local item = self:getItem(decision.item)
	local side = decision.side
	if side.player then
		local PlayerData = _f.PlayerDataService[side.player]
		if not PlayerData then return false end
		if not PlayerData:incrementBagItem(item.num, -1) then return false end -- take 1 of item
	elseif side.n == 1 then
		return false -- p1 should ALWAYS be a player; if it's missing, we have an issue
	end
	-- past here, any `return false` shouldn't happen without exploit; they will have just wasted an item (and turn)
	if not item.battleCategory then return false end
	-- OVH  todo: double-check canUse()
	if item.isPokeball then
		if self.battleType ~= BATTLE_TYPE_WILD then return false end
		self:tryCapture(self.p2.active[1], item.id)
		--	elseif item.onUse then
		--		self:call(item.onUse, decision.target)
	elseif _f.UsableItems[item.id] then
		self:add('message', decision.side.name .. ' used a ' .. item.name .. '!')
		--		local effectBefore = self.effect
		--		self.effect = self:getItem(item.id)
		self.useItemHack = true
		_f.UsableItems[item.id].onUse(decision.target, self)
		self.useItemHack = false
		--		self.effect = effectBefore
	end
end
-- misc
function Battle:applyPostBattleUpdates()
	if self.battleType ~= BATTLE_TYPE_WILD and self.battleType ~= BATTLE_TYPE_NPC then return end
	local side = self.p1
	local PlayerData = _f.PlayerDataService[side.player]

	local statIds = {'hp','atk','def','spa','spd','spe'}
	for i, p in pairs(side.pokemon) do
		if p ~= null and (not p.teamn or p.teamn == 1) then
			local pokemon = PlayerData.party[p.index]
			if not pokemon.egg then
				pokemon.hp = p.hp
				if p.status == '' or not p.status then
					pokemon.status = nil
				else
					pokemon.status = (p.status=='tox') and 'psn' or p.status
				end
				for m, move in pairs(p.moveset) do
					local pMove = pokemon.moves[m]
					if pMove then
						local id = pMove.id
						if id ~= move.id and id == 'sketch' then
							pMove.id = move.id
						end
						pMove.pp = move.pp
					else
						warn(pokemon.name .. ' [' .. p.index .. '] has no move in slot ' .. m .. ' (attempted to update pp for this move)')
					end
				end
				if p.evs then -- OVH  TODO: MAKE SURE EVS ARE APPLYING
					for i = 1, 6 do
						pokemon.evs[i] = math.max(pokemon.evs[i], p.evs[statIds[i]]) -- prevent loss, though ideally it should never happen anyway
					end
				end
				-- frozen shaymin
				pcall(function()
					if pokemon.name == 'Shaymin' and pokemon.forme == 'sky' and not p.template.forme then
						pokemon.forme = nil
						pokemon.data = _f.Database.PokemonById.shaymin
					end
				end)
			end
		end
	end
end

function Battle:finish(player)--::finish
	local WIN_DEBUG = self.WIN_DEBUG or false
	-- unassociate this player with the battle
	if player == self.listeningPlayers.p1 then
		if WIN_DEBUG then print('LANDO (fyi): p1 finished') end
		self.listeningPlayers.p1 = nil
		if not self.is2v2 or not self.listeningPlayers.p3 then
			self.p1:remove()
			self.p1 = nil
		end
	elseif player == self.listeningPlayers.p2 then
		if WIN_DEBUG then print('LANDO (fyi): p2 finished') end
		self.listeningPlayers.p2 = nil
		if not self.is2v2 or not self.listeningPlayers.p4 then
			self.p2:remove()
			self.p2 = nil
		end
	elseif player == self.listeningPlayers.p3 then
		if WIN_DEBUG then print('LANDO (fyi): p3 finished') end
		self.listeningPlayers.p3 = nil
		if not self.listeningPlayers.p1 then
			self.p1:remove()
			self.p1 = nil
		end
	elseif player == self.listeningPlayers.p4 then
		if WIN_DEBUG then print('LANDO (fyi): p4 finished') end
		self.listeningPlayers.p4 = nil
		if not self.listeningPlayers.p2 then
			self.p2:remove()
			self.p2 = nil
		end
	end
	-- award BP if this is the winning player
	if self.pvp and self.awardBP and player == self.winningPlayer then
		local bp = math.max(1, math.min(5, self:getStreak(self.winningPlayer.UserId)))
		print('awarding', bp, 'bp to', player)
		_f.PlayerDataService[player]:addBP(bp, true)
	end
	-- if both players have finished, remove the battle
	if self.p1 or self.p2 then return end
	if WIN_DEBUG then print('LANDO: battle removeing (have all players "finished" yet?)') end
	self:remove()
end
-- END ADDITIONS
function Battle:remove()--::remove
	-- deallocate ourself

	if self.sides then -- deallocate children and get rid of references to them
		for i, side in pairs(self.sides) do
			pcall(function() if side ~= null then side:remove() end end)
			self.sides[i] = nil
		end
		self.sides = nil
	end

	self.p1 = nil
	self.p2 = nil
	if self.queue then
		for i, q in pairs(self.queue) do
			q.pokemon = nil
			q.side = nil
			self.queue[i] = nil
		end
		self.queue = nil
	end
	self.log = nil
	self.giveExp = nil

	self.leveledUpPokemon = nil
	self.arq_data = nil
	--	self.arq_send = nil

	local wildFoe = self.wildFoePokemon
	if wildFoe then
		wildFoe:remove()
		self.wildFoePokemon = nil
	end

	self.previousCachedData = nil

	Battles[self.id] = nil

	-- and, for good measure, why not
	for i in pairs(self) do
		self[i] = nil
	end
end

require(script.Extension)(Battle)
require(script.Data)(Battle)


-- Debugging
function Battle:queryState()
	return 'Inactive Side: ' .. self.inactiveSide ..
		'\nCurrent Request: ' .. self.currentRequest ..
		'\n    Details: ' .. self.currentRequestDetails
end
if debug.calls then
	local stack = 0
	local enabled = true
	for i, v in pairs(Battle) do
		if type(v) == 'function' and i ~= 'debug' and i ~= 'debugError' and i ~= 'clampIntRange' then
			Battle[i] = function(s, ...)
				local disabledHere = false
				if i == 'getRelevantEffectsInner' and enabled then
					enabled = false
					disabledHere = true
				end
				if enabled then
					if s and s.sides then
						print(string.rep('   ', stack)..'battle::'..i..' (', ...)
					else
						print(string.rep('   ', stack)..'battle.'..i..' (', s, ...)
					end
				end
				stack = stack + 1
				local r = v(s, ...)
				stack = stack - 1
				if disabledHere then
					enabled = true
				end
				return r
			end
		end
	end
	for i, v in pairs(BattleSide) do
		if type(v) == 'function' then
			BattleSide[i] = function(s, ...)
				if enabled then
					if s and s.pokemon then
						print(string.rep('   ', stack)..'side::'..i..' (', ...)
					else
						print(string.rep('   ', stack)..'side.'..i..' (', s, ...)
					end
				end
				stack = stack + 1
				local r = v(s, ...)
				stack = stack - 1
				return r
			end
		end
	end
	for i, v in pairs(BattlePokemon) do
		if type(v) == 'function' then
			BattlePokemon[i] = function(s, ...)
				if enabled then
					if s and s.getStatus then
						print(string.rep('   ', stack)..'pokemon::'..i..' (', ...)
					else
						print(string.rep('   ', stack)..'pokemon.'..i..' (', s, ...)
					end
				end
				stack = stack + 1
				local r = v(s, ...)
				stack = stack - 1
				return r
			end
		end
	end
end


-- Remote Communications
-- these event/function lists are changed from values to keys after the binds
local publicEvents = {'remove', 'forfeit', 'choose', 'join', 'learnMove', 'nicknamePokemon', 'finish'}--, 'evolvePokemon', 'awardBPtoWinner'(?)
local publicFunctions = {'new', 'getCD', 'spectate', 'endSpectate', 'tryRun', 'isTrapped', 'getLearnMoveData', 'queryState', 'active', 'getTrainer', 'getEvolutionData'}
network:bindEvent('BattleEvent', function(player, battleId, fn, arg1, ...)
	if not publicEvents[fn] then print('attempt to fire battle event "'..tostring(fn)..'" blocked') return end
	local battle = Battles[battleId]
	if fn == 'join' then
		if battle.is2v2 then
			battle:receive('join2v2', player, arg1, ...)
		else
			if arg1 == 2 and battle.pvp then
				battle.listeningPlayers['p2'] = player
			end
			battle:receive(fn, player, arg1, ...)
			if battle.listeningPlayers.p1 and battle.listeningPlayers.p2 and not battle.bpChecked then
				battle.bpChecked = true
				local p1 = battle.listeningPlayers.p1.UserId
				local p2 = battle.listeningPlayers.p2.UserId
				local bp_id = math.min(p1, p2)..'_'..math.max(p1, p2)
				pcall(function() battle.awardBP = battle:PVPBattleAwardsBP(bp_id) end) -- see DataPersistence
			end
		end
		return
	end
	local playerIsInvolvedInBattle = false
	for _, p in pairs(battle.listeningPlayers) do
		if p == player then
			playerIsInvolvedInBattle = true
			break
		end
	end
	if not playerIsInvolvedInBattle then
		-- player is a spectator or exploiter
		return
	end
	if fn == 'finish' then
		if battle then battle:finish(player) end
		return
	elseif fn == 'choose' or fn == 'forfeit' then -- functions that pass the player as first arg
		--^ this errors:
		--error: Maximum Event re-entry depth exceeded for BindableEvent.Event
		--attempt to index nil with 'endSpectate'
		battle:receive(fn, player, arg1, ...)
		return
	end
	if not battle then
		if fn == 'remove' then return end
		print('battle not found or already removeed;', battleId, fn, arg1, ...)
	end
	battle:receive(fn, arg1, ...)
end)
network:bindFunction('BattleFunction', function(player, battleId, ...) -- we don't even check that the player is involved in this battle
	if battleId == 'new' then
		local battle = Battle:new(select(1, ...), player)
		if not battle.id then pcall(function() battle:remove() end) return end
		battle.listeningPlayers['p1'] = player
		return battle.creationData
	end
	local battle = Battles[battleId]
	local args = {...}
	if args[1] == 'getCD' then
		local d = {}
		for k, v in pairs(battle.creationData) do
			if k == 'scene' then
				local scene = battle.scene:Clone()
				scene.Parent = player:WaitForChild('PlayerGui')
				d[k] = scene
			else
				d[k] = v
			end
		end
		return d
	elseif args[1] == 'spectate' or args[1] == 'endSpectate' then
		return battle[args[1]](battle, player, unpack(args))
	elseif args[1] == 'active' then -- a client's pokemon has leveled up or learned a new move; they need to get fresh active data
		-- IS THIS STILL USED?
		local side = battle[args[2]]
		local activeData = {}
		for i, active in pairs(side.active) do
			if active ~= null then
				activeData[i] = active:getRequestData()
			end
		end
		return activeData
		--	elseif args[1] == 'winupdate' then
		--		local side = battle[args[2]]
		--		return side:getRelevantDataChanges()
	end
	local playerIsInvolvedInBattle = false
	for _, p in pairs(battle.listeningPlayers) do
		if p == player then
			playerIsInvolvedInBattle = true
			break
		end
	end
	if not playerIsInvolvedInBattle then
		-- player is a spectator or exploiter
		return
	end
	if #args == 0 then return end
	local fn = table.remove(args, 1)
	if not publicFunctions[fn] then print('attempt to invoke battle function "'..tostring(fn)..'" blocked') return end
	return battle[fn](battle, unpack(args))
end)
do -- we actually want to represent these lists using keys instead of values
	local pe, pf = {}, {}
	for _, s in pairs(publicEvents)    do pe[s] = true end
	for _, s in pairs(publicFunctions) do pf[s] = true end
	publicEvents, publicFunctions = pe, pf
end

-- nasty hack to fix trainers -> this prevents us from saving replays of NPC trainers [?]
function Battle:getTrainer()
	local trainer = self.npcTrainerData
	if not trainer then return end
	local lp
	if trainer.LosePhrase then
		lp = trainer.LosePhrase
		if type(lp) == 'string' then
			lp = {lp}
		end
	end
	return trainer.Name, lp
end


-- PVP-specific add-ons
--[[function Battle:awardBPtoWinner()
	if not self.pvp or not self.awardBP or not self.winningPlayer then return end
	self.awardBP = false
	pcall(function()
		local bp = math.max(1, math.min(5, self:getStreak(self.winningPlayer.UserId)))
--		print('awarding', bp, 'bp')
		network:post('AwardBP', self.winningPlayer, bp)
	end)
end]]

function Battle:forfeit(player, sideId)
	if self.forfeitDebounce then return end
	self.forfeitDebounce = true
	local side = self[sideId]
	local logPos = #self.log + 1
	local alreadyEnded = self.ended

	self:add('-message', player.Name .. ' forfeited the match.')
	self:win(side.foe.id)
	self:sendUpdates(logPos, alreadyEnded)
end

game:GetService('Players').ChildRemoved:connect(function()
	for _, battle in pairs(Battles) do
		if battle.is2v2 then
			local forfeit = false
			local winner
			local name = 'Somebody'
			if battle.listeningPlayers.p1 and not battle.listeningPlayers.p1.Parent then
				winner = 'p2'
				forfeit = true
				pcall(function() name = battle.listeningPlayers.p1.Name end)
			elseif battle.listeningPlayers.p2 and not battle.listeningPlayers.p2.Parent then
				winner = 'p1'
				forfeit = true
				pcall(function() name = battle.listeningPlayers.p2.Name end)
			elseif battle.listeningPlayers.p3 and not battle.listeningPlayers.p3.Parent then
				winner = 'p2'
				forfeit = true
				pcall(function() name = battle.listeningPlayers.p3.Name end)
			elseif battle.listeningPlayers.p4 and not battle.listeningPlayers.p4.Parent then
				winner = 'p1'
				forfeit = true
				pcall(function() name = battle.listeningPlayers.p4.Name end)
			end
			if forfeit then
				local logPos = #battle.log + 1
				local alreadyEnded = battle.ended
				if winner then
					battle:add('-message', name .. ' left the game.')
					battle:add('-message', 'The match will end.')
				end
				battle:win(winner)
				battle:sendUpdates(logPos, alreadyEnded)
			end
		elseif battle.pvp then
			local forfeit = false
			local winner
			if battle.listeningPlayers.p1 and not battle.listeningPlayers.p1.Parent then
				winner = 'p2'
				forfeit = true
			end
			if battle.listeningPlayers.p2 and not battle.listeningPlayers.p2.Parent then
				winner = winner==nil and 'p1' or nil
				forfeit = true
			end
			if forfeit then
				local logPos = #battle.log + 1
				local alreadyEnded = battle.ended
				if winner then
					local name = 'The opponent'
					pcall(function() name = battle[winner].foe.name end)
					print(name, 'forfeited')
					battle:add('-message', name .. ' left the game.')
					battle:add('-message', name .. ' forfeited the match.')
				end
				battle:win(winner)
				battle:sendUpdates(logPos, alreadyEnded)
			end
		end
	end
end)

function Battle:getSpectatableBattles()
	local sb = {}
	for _, battle in pairs(Battles) do
		if battle.pvp and battle.allowSpectate and battle.p1 and battle.p2 

			and battle.battleType ~= BATTLE_TYPE_2V2 -- 2v2specdo: 2v2 SPECTATING TEMPORARILY DISABLED (until properly implemented)

		then
			sb[battle]=true--table.insert(sb, battle)
		end
	end
	--	table.sort(sb, function(a, b) return a.createdAt < b.createdAt end)
	return sb
end

function Battle:spectate(player)
	if not self.pvp or not self.allowSpectate then return end
	local d = {}
	for k, v in pairs(self.creationData) do
		if k == 'scene' then
			local scene = self.scene:Clone()
			scene.Parent = player:WaitForChild('PlayerGui')
			d[k] = scene
		else
			d[k] = v
		end
	end
	d.gameType = self.gameType
	d.log = self.log
	d.td = self.previousCachedData

	table.insert(self.spectators, player)

	return d
end

function Battle:endSpectate(player)
	for i = #self.spectators, 1, -1 do
		if self.spectators[i] == player then
			table.remove(self.spectators, i)
		end
	end
end


-- PDS Overhaul
function Battle:getBattleSideForPlayer(player)
	if self.sides then return end -- reject request if it is called from a battle itself (should be called as class function)
	for _, battle in pairs(Battles) do
		for sideId, p in pairs(battle.listeningPlayers) do
			if p == player then
				if sideId == 'p3' then
					return battle.p1
				elseif sideId == 'p4' then
					return battle.p2
				end
				return battle[sideId]
			end
		end
	end
end


-- Elo Manager (PVP Colosseum only)
if _f.Context == 'battle' then
	EloManager = require(script.BattleEloManager)
	EloManager:startUpdateCycle()
end




--[[ Bonus Debug
_f.Network:bindEvent('db_btl', function()
	local name1 = 'Player'..math.random(1024)
	local name2 = 'Player'..math.random(1024)
	local fakeBattle = {
		p1 = {name = name1},
		p2 = {name = name2},
		pvp = true,
		allowSpectate = true,
		id = uid()
	}
	Battles[fakeBattle.id] = fakeBattle
	_f.SpectateBoard:update()
end)--]]



return Battle