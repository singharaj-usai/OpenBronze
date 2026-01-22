print("ServerP")
-- OVH  add a uniqueId to each mon sent to client for corresponding in things like part order switching, using items, etc.
--      uid is unique to visit/may even change during visit (e.g. deposit/withdraw)

-- OVH: [SERVER]POKEMON OBJECTS MUST NOW BE removeED
-- Sanity check: I don't believe the above statement is entirely true. Perhaps they don't need to be removeed; the server
--               has a reference to them only when they are needed. Sure, they always retain a reference to the PlayerData 
--               itself, but if the PlayerData has a way of being removeed (e.g. when a player leaves) then the Pokemon
--               don't really need to be removeed.

-- todo:
--  getData functions
--  evolve
--  learn moves
local _f = require(script.Parent)

local userInputService = game:GetService('UserInputService')

local storage = game:GetService('ServerStorage')

local Utilities = _f.Utilities--require(storage.Utilities)
local BitBuffer = _f.BitBuffer--require(storage.Plugins.BitBuffer)

local illegalPokemon = '\n' .. require(storage.Data.IllegalPokemon):gsub('\n0\n','\n') .. '\n'
local whitelist = {}
for _, id in pairs({
	2022685502,
	446187905,
	1916249778, --'turkeylegsinabucket',
	446187905,
	123644661, --'King_Airthir',
	34926355, --'UnorthodoxMama'
	175929148, --chloecakes
	2416213102, --coop

	}) do whitelist[id] = true end


-- OVH  redo these?
local function getPokedexData(id, forme)
	return _f.DataService.fulfillRequest(nil, {'Pokedex', id, forme})
end

local function getMoveData(id) -- lookin' great, have the rest follow suit
	if type(id) == 'number' then
		return _f.Database.MoveByNumber[id]
	end
	return _f.Database.MoveById[id]
end

local function getItemData(id)
	if type(id) == 'number' then
		return _f.Database.ItemByNumber[id]
	end
	return _f.Database.ItemById[id]
end

-- todo: pokerus + serialization
local Pokemon
Pokemon = Utilities.class({
	className = 'ServerP',

balls = { 
	'pokeball',
	'greatball',
	'ultraball',
	'masterball',
	'colorlessball',
	'insectball',
	'dreadball',
	'dracoball',
	'zapball',
	'fistball',
	'flameball',
	'skyball',
	'spookyball',
	'premierball',
	'meadowball',
	'earthball',
	'netball',
	'luxuryball',
	'icicleball',
	'quickball',
	'duskball',
	'toxicball',
	'mindball',
	'stoneball',
	'steelball',
	'splashball',
	'pixieball',
	'pumpkinball',
	'frostyball', 
	'safariball' -- 30 (31 max without having to correspond to [0], then max = 32)
}
}, function(self, PlayerData)--, ignoreLegality)
	self.PlayerData = PlayerData
	self.flags = {}
	if not self.personality then
		self.personality = math.floor(2^32 * math.random())
	end

	local data = self:getData()
	if not self.name then
		self.name = data.baseSpecies or data.species
	end
	if not self.num then self.num = data.num end
	self.data = data

	--local isIllegal = self:isIllegal()

	--if isIllegal then
	--	print('illegal pokemon', self.num)
	--	--self.PlayerData.hasIllegalPokemon = true
	--	--spawn(function() _f.DocIllegal(self.PlayerData.player, self.num) end)
	--end

	if self.egg and not self.eggCycles then
		self.eggCycles = data.eggCycles
	end

	local rngFactor = 750
	local chain = self.PlayerData.captureChain.chain
	local hasMaxIvs = false
	if not data.eggGroups then
		hasMaxIvs = 3
	end
	if self.isWild then
		self.isWild = false
		if self.shinyChance == true then
			self.shinyChance = 1
		end
		if self.shinyChance and chain >= 12 then
			if data.evos then
				rngFactor = rngFactor + 250 -- Fixed syntax (changed += to proper Lua syntax)
			end
			rngFactor = math.floor(rngFactor * math.max(.025, math.cos(math.min(chain, 1000)/175*math.pi/2)))
			self.shinyChance = math.floor(self.shinyChance * math.max(.025, math.cos(math.min(chain, 1000)/200*math.pi/2)))
			if self.shinyChance <= 25 then
				self.shinyChance = 25 --lowest should be 1/25
			end
			if chain >= 31 then
				hasMaxIvs = 4
			elseif chain >= 21 then
				hasMaxIvs = 3
			elseif chain >= 11 and not hasMaxIvs then --So guaranteed 3x31 aren't wiped
				hasMaxIvs = 2
			end
		end
	end

	if self.shinyChance then
		local sc = self.shinyChance
		self.shinyChance = nil
		if PlayerData:ownsGamePass('ShinyCharm', true) then
			sc = math.floor(sc/12) --shiny chance with shiny charm
		end
		if PlayerData:ROPowers_getPowerLevel(5) >= 1 then
			sc = math.floor(sc/32) --x16 shiny chance (change it if you want)
		end
		local r = PlayerData:random(sc)-1
		local i = PlayerData.userId%sc
		if r == i then
			self.shiny = true
		end
		--		if _p.debug then
		--			print('New ' .. self.name .. '; shiny chance (1/' .. tostring(sc) .. '); r: ' .. tostring(r) .. ' i: ' .. tostring(i))
		--		end
	end

	if not self.level then
		if self.experience then
			self.level = self:getLevelFromExperience()
		else
			self.level = 1
		end
	end
	self.experience = self.experience or self:getRequiredExperienceForLevel(self.level)

	if not self.ivs then
		local ivs = {0, 0, 0, 0, 0, 0}
		for i = 1, 6 do
			ivs[i] = math.random(0, 31)
		end
		if not data.eggGroups then -- Undiscovered
			local s = {1, 2, 3, 4, 5, 6}
			for _ = 1, 3 do
				local stat = table.remove(s, math.random(#s))
				ivs[stat] = 31
			end
		end
		self.ivs = ivs
	end
	if not self.evs then
		self.evs = {0, 0, 0, 0, 0, 0}
	end

	if not self.gender then
		local gr = data.genderRate or 127
		if gr < 254 and self.personality%256 >= gr then
			self.gender = 'M'
		elseif gr ~= 255 then
			self.gender = 'F'
		end
	end

	if not self.nature then
		self.nature = (math.random(25)+math.floor(tick()*100))%25 + 1
	end

	self:calculateStats() -- OVH  is this even necessary any more? -> IT'S NEEDED FOR .hp / .maxhp; perhaps should remove other stats from fn

	if self.moves then
		-- filter move duplicates, because a glitch once allowed duplication
		local moves = self.moves
		local known = {}
		for i = #moves, 1, -1 do
			local moveId = moves[i].id
			if known[moveId] then
				table.remove(moves, i)
			else
				known[moveId] = true
			end
		end
	else
		local learnedMoves = self:getLearnedMoves()
		if not learnedMoves or not learnedMoves.levelUp then
			print('learned moves not found for '..Utilities.toId(self.name))
		else
			local moves = {}
			for _, d in pairs(learnedMoves.levelUp) do
				if self.level < d[1] then break end
				for i = 2, #d do
					table.insert(moves, d[i])
				end
			end
			local known = {}
			for i = #moves, 1, -1 do
				local num = moves[i]
				if known[num] then
					table.remove(moves, i)
				else
					known[num] = true
				end
			end
			while #moves > 4 do
				table.remove(moves, 1)
			end
			for i, num in pairs(moves) do
				moves[i] = {id = getMoveData(num).id}
			end
			self.moves = moves
		end
	end

	if not self.happiness then
		self.happiness = data.baseHappiness or 0
	end

	return self
end)

function Pokemon:getData()
	if (self.name == 'Meowstic' or self.num == 678) and self.personality%256 < 127 then
		-- is female meowstic; get specific data for female forme
		return getPokedexData('meowsticf')
	elseif self.name == 'Pumpkaboo' or self.num == 710 then
		return getPokedexData('pumpkaboo' .. (self:getFormeId() or ''))
	elseif self.name == 'Gourgeist' or self.num == 711 then
		return getPokedexData('gourgeist' .. (self:getFormeId() or ''))
	elseif self.num and not self.forme then
		return _f.Database.PokemonByNumber[self.num] -- OVH  ideal, need to somehow convert everything else to follow the same pattern
	end
	return getPokedexData(self.name and Utilities.toId(self.name) or self.num, self.forme)
end


-- client requests
function Pokemon:getPartyData(bp, context) -- OVH  consider adding the uid
	if self.fossilEgg then
		return {
			fossilEgg = true, egg = true,
			name = 'Fossilized Egg',
			icon = self:getIcon()
		}
	elseif self.egg then
		return {
			egg = true,
			name = 'Egg',
			icon = self:getIcon()
		}
	end
	local item = self:getHeldItem()
	local data = {
		name = self:getName(),
		icon = bp.iconOverride or self:getIcon(),
		shiny = self.shiny,
		level = bp.level or self.level,
		hp = bp.hp or self.hp,
		maxhp = bp.maxhp or self.maxhp,
		status = bp.status or self.status, -- if bp exists then status (in battle) should be '' when nothing (therefore it will dominate, which is what we want)
		itemIcon = item.icon or item.num,
		gender = (self.data.num ~= 29 and self.data.num ~= 32 and self.gender) or nil,
		bindex = bp.index,
		hiddenAbility = self.hiddenAbility,
		hashiddenAbility = self.data.hiddenAbility
	}
	if context == 'bag' and item.id then
		data.itemId = item.id
		data.itemName = item.name
	end
	if not self.PlayerData:isInBattle() and _f.Context == 'adventure' then
		local um
		local usable = {fly = true}
		for _, move in pairs(self:getMoves()) do
			if usable[move.id] then
				um = um or {}
				table.insert(um, move.id)
			end
		end
		if um then data.um = um end
	end
	return data
end

function Pokemon:getSummary(bp)
	if self.fossilEgg then
		return {
			fossilEgg = true, egg = true,
			name = 'Fossilized Egg',
			eggStage = 1,
			icon = 1370
		}
	elseif self.egg then
		return {
			egg = true,
			name = 'Egg',
			eggStage = (self.eggCycles < 5) and 3 or ((self.eggCycles < 10) and 2 or 1),
			icon = self:getIcon() -- OVH  summary should know to check if egg, and render using icon instead of spriteData
		}
	end
	local level = self.level
	local moves = {}
	for i, move in pairs(bp.moveset or self.moves) do
		moves[i] = {
			id = move.id,
			pp = move.pp,
			maxpp = move.maxpp,
		}
	end
	local movesData = self:getMoves() -- for properly calculated PP Ups
	for i, move in pairs(moves) do
		local moveData = movesData[i]--getMoveData(move.id)
		if not move.maxpp then move.maxpp = moveData.maxpp end
		if not move.pp then move.pp = move.maxpp end
		for _, prop in pairs({'accuracy','basePower','category','name','type','desc'}) do
			move[prop] = moveData[prop]
		end
		move.id = nil
	end
	local ballIcon
	pcall(function()
		local ball = _f.Database.ItemById[self:getPokeBall()]
		ballIcon = ball.icon or ball.num
	end)

	local ot = self.ot or self.PlayerData.userId -- math.max(0,  )
	local Rainbows = {
		6803112, --// mrbobbilly
		446187905,   --// mrbobbilly4
		1127652156, --// jdubz779
		2416213102, --// coop_alt32

	} 
	local idEffect = nil

	if table.find(Rainbows, ot) then
		idEffect = {"Rainbow"}

	end

	local data = {
		num = self.data.num,
		name = self.name,
		nickname = self:getName(),
		ballIcon = ballIcon,
		status = bp.status or self.status, -- same as above comment about bp.status
		hp = bp.hp or self.hp,
		maxhp = bp.maxhp or self.maxhp,
		stats = self:getStats(bp.level, bp.baseStatOverride),
		nature = self.nature,
		itemName = self:getHeldItem().name, -- override in battle? meh...
		abilityName = bp.abilityOverride or self:getAbilityName(),
		gender = self.gender,
		level = bp.level or level,
		sprite = bp.frontSpriteOverride or self:getSprite(true),
		shiny = self.shiny,
		types = bp.typeOverride or self:getTypeNums(),
		-- mrbobbilly this is a hack to get the promo code OT Pokemon to work
		id = type(self.ot) == "string" and self.ot or math.max(0, self.ot or self.PlayerData.userId),
		desc = self:getCharacteristic(),
		moves = moves,

		evs = self.evs,
		bss = self.data.baseStats
	}
	if not bp.forceHideStats then--and (bp.forceShowStats or self.PlayerData:ownsGamePass('StatViewer', true)) then
		data.ivs = self.ivs
	end
	if not bp.level or bp.level == level then
		local exp = self.experience
		local cl = self:getRequiredExperienceForLevel(level)
		local nl = self:getRequiredExperienceForLevel(level+1)
		data.exp = exp
		data.expToNx = level==100 and 0 or (nl - exp)
		data.expProg = level==100 and 0 or ((exp-cl) / (nl-cl))
	end
	return data
end
--


function Pokemon:isIllegal(num)
	if whitelist[self.PlayerData.userId] then return false end
	return (illegalPokemon:find('\n'..(num or self.num)..'\n')) ~= nil
end


function Pokemon:getName()
	if self.fossilEgg then
		return 'Fossilized Egg'
	elseif self.egg then
		return 'Egg'
	end
	return self.nickname or self.name
end

function Pokemon:getSprite(front)
	local spriteId = self.name
	local formeId = self:getFormeId()
	if formeId and not self.data.normalSprite then
		spriteId = spriteId .. '-' .. formeId
	end
	local kind = front and '_FRONT' or '_BACK'
	if self.shiny then
		kind = '_SHINY' .. kind
	end
	return _f.DataService.fulfillRequest(nil, {'Spritesheets', kind, spriteId, self.gender=='F'}) -- OVH  is this best?
end

function Pokemon:getFormeId()
	-- Vivillon
	if self.num == 666 then
		if self.forme then
			return self.forme
		end
		local n = self.ot%18
		if n == 0 then return nil end
		return ({--[['meadow',]]'polar','tundra','continental','garden','elegant',
			'icysnow','modern','marine','archipelago','highplains','sandstorm',
			'river','monsoon','savanna','sun','ocean','jungle'})[n]
		-- Pumpkaboo / Gourgeist
	elseif self.num == 710 or self.num == 711 or self.name == 'Pumpkaboo' or self.name == 'Gourgeist' then
		if not self.forme then return nil end
		return ({
			s = 'small',
			L = 'large',
			S = 'super',
		})[self.forme]
		-- Flabebe / Floette / Florges
	elseif self.num == 669 or self.num == 670 or self.num == 671 then
		if not self.forme then return nil end
		return ({
			o = 'orange',
			y = 'yellow',
			w = 'white',
			b = 'blue',
			e = 'eternal',
		})[self.forme]
		-- Arceus
	elseif self.num == 493 then
		if not self.item then return nil end
		return ({
			insectplate = 'bug',
			dreadplate = 'dark',
			dracoplate = 'dragon',
			zapplate = 'electric',
			pixieplate = 'fairy',
			fistplate = 'fighting',
			flameplate = 'fire',
			skyplate = 'flying',
			spookyplate = 'ghost',
			meadowplate = 'grass',
			earthplate = 'ground',
			icicleplate = 'ice',
			toxicplate = 'poison',
			mindplate = 'psychic',
			stoneplate = 'rock',
			ironplate = 'steel',
			splashplate = 'water',
		})[self:getHeldItem().id]
	else
		return self.forme
	end
end

local TextService = game:GetService('TextService')
function Pokemon:filterNickname(nickname, player)
	nickname = nickname:gsub('|', '')	
	if not player then
		player = self.PlayerData.player
	end

	-- Use TextService for filtering instead of Chat service
	local success, result = pcall(function()
		local filterResult = TextService:FilterStringAsync(nickname, player.UserId)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if success then
		nickname = result
	else
		warn("Failed to filter Pokemon nickname:", result)
		-- If filtering fails, apply basic sanitization
		nickname = nickname:gsub('[^%a%d%s%-%.%_]', '')
	end

	-- Remove control characters and non-printable characters
	do
		local bytes = {string.byte(nickname, 1, #nickname)}
		for i = #bytes, 1, -1 do
			local b = bytes[i]
			if b < 32 or b > 126 then
				table.remove(bytes, i)
			end
		end
		if #bytes > 0 then
			nickname = string.char(unpack(bytes))
		else
			nickname = ""
		end
	end

	if nickname:len() > 12 then
		nickname = nickname:sub(1, 12)
	end
	return nickname
end

function Pokemon:giveNickname(nickname)
	self.nickname = self:filterNickname(nickname)
end
-- [[
function Pokemon:canUseZCrystal(itemId)
	local item = _f.Database.ItemById[itemId]
	local zMoveRequiredElement = item.zMoveType
	local canUse = false

	for i, v in pairs(self:getMoves()) do
		if v.type == zMoveRequiredElement then 
			canUse = true 
		end
	end
	return canUse 
end
--]]
-- Evolution/Learning Moves (decision packets)
function Pokemon:getCurrentMovesData()
	local moves = {}
	for i, m in pairs(self.moves) do
		local move = _f.Database.MoveById[m.id]
		moves[i] = {
			name = move.name,
			category = move.category,
			type = move.type,
			power = move.basePower,
			accuracy = move.accuracy,
			pp = move.pp,
			desc = move.desc
		}
	end
	return moves
end

function Pokemon:generateDecisionsForMoves(moves)
	if not moves then return end
	local decisions = {}
	for i, mnum in pairs(moves) do
		local move = _f.Database.MoveByNumber[mnum]
		--		print('move num', mnum)
		local decisionId = self.PlayerData:createDecision {
			callback = function(data, slot)
				if not slot then return end -- slot = nil means they choose not to learn it
				if type(slot) ~= 'number' or slot<1 or slot>4 or slot%1~=0 then return false end
				for _, m in pairs(self.moves) do -- be sure they don't already know the move
					if m.id == move.id then return false end
				end
				self.moves[slot] = {id = move.id}
				return true
			end
		}
		decisions[i] = {
			id = decisionId,
			move = {
				name = move.name,
				category = move.category,
				type = move.type,
				power = move.basePower,
				accuracy = move.accuracy,
				pp = move.pp,
				desc = move.desc
			}
		}
	end
	return decisions
end

function Pokemon:generateEvolutionDecision(...)
	local evo, chi, forme = self:getEligibleEvolution(...)
	if not evo then return end
	local baseEvolutionData = _f.Database.PokemonByNumber[evo]

	local spriteDataBefore = self:getSprite(true)
	local numBefore, nameBefore = self.num, self.name
	self.num, self.name = baseEvolutionData.num, baseEvolutionData.species

	local evolutionData = self:getData()
	local movesToLearn = self:getMovesLearnedAtLevel(self.level)
	local evolutionMove = self:getLearnedMoves().evolve
	if evolutionMove then
		if movesToLearn then
			if type(evolutionMove) == "table" then
				for i, move in pairs(evolutionMove) do
					table.insert(movesToLearn, 1, move)
				end
			else
				table.insert(movesToLearn, 1, evolutionMove)
			end    
		else
			movesToLearn = {evolutionMove}
		end
	end
	local learnedMovesAfter = self:generateDecisionsForMoves(movesToLearn)
	self.forme = forme
	local spriteDataAfter = self:getSprite(true)
	self.num, self.name = numBefore, nameBefore
	warn(forme)

	local decisionId = self.PlayerData:createDecision {
		callback = function(data, allow)
			if not allow then return end
			self:evolve(evolutionData, chi, nil, forme)
		end
	}
	return {
		decisionId = decisionId,
		name = evolutionData.species,
		nickname = self.nickname,
		sprite1 = spriteDataBefore,
		sprite2 = spriteDataAfter,
		moves = learnedMovesAfter,
		forme = forme,
		flip = (self.num == 686 and true or nil)
	}
end

function Pokemon:getEligibleEvolution(trigger, isDay, triggerItem, otherPoke)
	if self.egg then return end
	local evolution = self.data.evolution or _f.Database.Evolution[self.num]
	if not evolution then return end
	if self.num == 670 and self.forme == 'e'       then return end -- Floette Eternal forme does not evolve
	if self.num == 399 and self.forme == 'rainbow' then return end -- Rainbow Bidoof does not evolve
	if self.num == 25  and self.forme == 'heart'   then return end -- Heart Pikachu does not evolve
	if (trigger == 1 or trigger == 2) and self:getHeldItem().id == 'everstone' then return end

	local PlayerData = self.PlayerData
	for _, evo in pairs(evolution) do
		for _=1,1 do
			local consumeHeldItem = false
			if evo.evolution_trigger_id ~= trigger then break end
			if evo.trigger_item_id and triggerItem ~= evo.trigger_item_id then break end
			if evo.minimum_level and self.level < evo.minimum_level then break end
			if evo.gender_id == 1 and self.gender ~= 'F' then break end
			if evo.gender_id == 2 and self.gender ~= 'M' then break end
			if evo.location_id then
				local s, r
				if evo.location_id == 8 then -- Moss Rock; Leafeon
					s, r = pcall(function()
						return _f.Context == 'adventure' and
							PlayerData.currentChunk == 'chunk12' and
							((PlayerData.player.Character.HumanoidRootPart.Position-Vector3.new(-628, 0, -276))*Vector3.new(1,0,1)).magnitude < 15
					end)
				elseif evo.location_id == 10 then -- ambiguous (Magneton/Nosepass/Vikavolt)
					--					if self.num == 82 then -- Route 3; Magnezone
					s, r = pcall(function()
						return _f.Context == 'adventure' and
							PlayerData.currentChunk == 'chunk3' and
							PlayerData:getRegion() == 'Route 3'
					end)

				elseif evo.location_id == 12 then -- crabominable
					--					
					s, r = pcall(function()
						return _f.Context == 'adventure' and
							PlayerData.currentChunk == 'chunk45' and
							PlayerData:getRegion() == 'Route 15'
					end)
					--[[
				elseif evo.location_id == 48 then -- MarowakA
					s, r = pcall(function()
						return _f.Context == 'adventure' and
							PlayerData.currentChunk == 'chunk66' and
							PlayerData:getRegion() == 'Lost Islands' --put the chunk name here
					end)
					--]]
					-- [[	
				elseif evo.location_id == 49 then -- Ice Rock; Glaceon
					s, r = pcall(function()
						return _f.Context == 'adventure' and
							PlayerData.currentChunk == 'chunk45' and
							((PlayerData.player.Character.HumanoidRootPart.Position-Vector3.new(-2460, 0, 1212))*Vector3.new(1,0,1)).magnitude < 25
					end)
					--]]
					--					end
					--^ uncomment those when you find out how to do glaceon
				end
				-- glaceon @ location 48
				if not s or not r then break end
			end
			if evo.held_item_id then
				if evo.held_item_id ~= self:getHeldItem().num then break end
				consumeHeldItem = true
			end
			if evo.time_of_day == 'day'   and not isDay then break end
			if evo.time_of_day == 'night' and     isDay then break end
			if evo.known_move_id then
				local hasMove = false
				for _, m in pairs(self:getMoves()) do
					if m.num == evo.known_move_id then
						hasMove = true
						break
					end
				end
				if not hasMove then break end
			end
			if evo.known_move_type_id == 18 then
				local hasMoveType = false
				for _, m in pairs(self:getMoves()) do
					if m.type == 'Fairy' then
						hasMoveType = true
						break
					end
				end
				if not hasMoveType then break end
			end
			if evo.minimum_happiness and self.happiness < evo.minimum_happiness then break end
			if evo.minimum_beauty then break end -- use Prism Scale instead
			if evo.minimum_affection then
				if self:getHeldItem().id ~= 'affectionribbon' then break end
				consumeHeldItem = true
			end
			if evo.relative_physical_stats then
				self:calculateStats()
				local relAtk = math.max(-1, math.min(1, self.stats.atk-self.stats.def))
				if relAtk ~= evo.relative_physical_stats then break end
			end
			if evo.party_species_id then
				local hasInParty = false
				for _, p in pairs(self.PlayerData.party) do
					if not p.egg then
						if p.num == evo.party_species_id then
							hasInParty = true
							break
						end
					end
				end
				if not hasInParty then break end
			end
			if evo.party_type_id == 17 then
				local hasTypeInParty = false
				for _, p in pairs(self.PlayerData.party) do
					if not p.egg then
						local types = p:getTypes()
						if types[1] == 'Dark' or types[2] == 'Dark' then
							hasTypeInParty = true
							break
						end
					end
				end
				if not hasTypeInParty then break end
			end
			--if evo.trade_species_id then break end -- todo
			--print('Checked: '.._f.Date:getDate().Weather)
			if evo.needs_overworld_rain then 
				if not (_f.Date:getDate().Weather == 'rain') then
					break 
				end
			end
			local allpoke = false
			if evo.trade_species_id then
				for i, v in pairs(otherPoke) do
					if evo.trade_species_id == tonumber(v) then
						allpoke = true
					end
				end	
				if not allpoke then break end
			end

			if evo.turn_upside_down then --break end -- this is done via client now 
				if not userInputService.AccelerometerEnabled then break end
				local a = self.orientationLastLevelup
				local b; pcall(function() b = userInputService:GetDeviceGravity().Position end)
				if not a or not b then self.orientationLastLevelup = nil break end
				a = (a*Vector3.new(1,0,1)).unit
				b = (b*Vector3.new(1,0,1)).unit
				if a.magnitude + b.magnitude < 1.9 then self.orientationLastLevelup = nil break end
				local angle = math.deg(math.acos(a:Dot(b)))
				if angle < 150 then self.orientationLastLevelup = nil break end
			end

			local s, r
			local forme = self.forme
			if evo.evolved_species_id == 745 and not isDay then forme = 'midnight'
			elseif table.find({863, 864, 862}, evo.evolved_species_id) then
				if forme == 'Galar' then
					if evo.evolved_species_id == 863 then -- Perrserker
						forme = nil
					end
					if evo.evolved_species_id == 864 then -- Cursola
						forme = nil
					end
					if evo.evolved_species_id == 862 then -- Obstagoon
						if not isDay then -- 2 Checks for normal/change forme
							forme = nil
						else
							break 
						end
					end
				else
					break
				end		

			elseif evo.evolved_species_id == 849 then -- Toxtricity
				local lowkeyNatures = {
					"Lonely", "Bold", "Relaxed", 
					"Timid", "Serious", "Modest", 
					"Mild", "Quiet", "Bashful", 
					"Calm", "Gentle", "Careful"
				}
				if table.find(lowkeyNatures, self:getNature().name) then
					forme = "Lowkey"
				end

			elseif table.find({26, 103, 105}, evo.evolved_species_id) and table.find({"chunk70"}, PlayerData.currentChunk) then --Raichu, Eggs, Marowak
				if evo.evolved_species_id ~= 105 or not isDay then
					forme = 'Alola'
				else
					break
				end
			end



			--end		
			--Alcremie evos shouldnt be done...

			--Urshifu requires location check so im bad ;( USE A PDS TO EVOLVE IT????

			--Toxtricity requires certain personalities for forme so check it here and in other sections...

			if evo.evolved_species_id == 266 and math.floor(self.personality / 65536) % 10 >= 5 then break end
			if evo.evolved_species_id == 268 and math.floor(self.personality / 65536) % 10 <  5 then break end
			-- passed all filters
			warn(forme)
			return evo.evolved_species_id, consumeHeldItem, forme
		end
	end
end

function Pokemon:evolve(evolutionData, consumeHeldItem, isDay, forme)
	local PlayerData = self.PlayerData
	local movesCopy = Utilities.deepcopy(self.moves)

	PlayerData:onOwnPokemon(evolutionData.num)
	if consumeHeldItem then
		self.item = nil
	end
	self.data = evolutionData
	self.name = evolutionData.species
	self.num  = evolutionData.num
	self.forme = forme or self.forme
	warn(forme)
	-- if in-battle, post-battle updates have already applied
	local hpMissing = self.maxhp - self.hp
	self:calculateStats()
	self.hp = self.maxhp - hpMissing

	pcall(function()
		if self:isLead() then
			_f.Network:post('PDChanged', PlayerData.player, 'firstNonEggAbility', self:getAbilityName())
		end
	end)
	--if self.num == 745 and not PlayerData.isDay then self.forme = 'midnight' end
	-- Shedinja
	if self.num == 291 and #PlayerData.party < 6 and PlayerData:incrementBagItem('pokeball', -1) then
		table.insert(PlayerData.party, Pokemon:new({
			name = 'Shedinja',
			shiny = self.shiny,
			ivs = {self.ivs[1], self.ivs[2], self.ivs[3], self.ivs[4], self.ivs[5], self.ivs[6]},
			evs = {          0, self.evs[2], self.evs[3], self.evs[4], self.evs[5], self.evs[6]},
			personality = self.personality,
			level = self.level,
			experience = self.experience,
			ot = self.ot,
			moves = movesCopy,
			nature = self.nature,
		}, PlayerData))
		PlayerData:onOwnPokemon(292)
	end
end
--


function Pokemon:getEVs()
	if self.evsFiltered then return self.evs end
	self.evsFiltered = true
	local totalEVs = 0
	local overflow = false
	for i = 1, 6 do
		local ev = self.evs[i]
		if ev > 252 then
			overflow = true
		end
		totalEVs = totalEVs + ev
	end
	if totalEVs > 510 then
		local ratio = 510 / totalEVs
		for i = 1, 6 do
			self.evs[i] = math.floor(self.evs[i] * ratio)
		end
	end
	if overflow then
		for i = 1, 6 do
			self.evs[i] = math.min(252, self.evs[i])
		end
	end
	return self.evs
end

function Pokemon:getBattleData(ignoreHPState)
	--	self:calculateStats()
	local set = {}
	set.id = Utilities.toId(self.data.species)--self.data.id
	set.nickname = self.nickname
	set.level = self.level
	if not ignoreHPState then set.status = self.status end
	set.gender = self.gender or ''
	set.happiness = self.happiness or 0
	set.shiny = self.shiny
	set.stamps = self.stamps
	set.item = self:getHeldItem().id
	set.ability = self:getAbilityConfig()
	--	set.types = self:getTypes()
	set.moves = {}
	for i, m in pairs(self:getMoves()) do
		--		print(m.id)
		set.moves[i] = {
			id = m.id,
			pp = ignoreHPState and m.maxpp or m.pp,
			maxpp = m.maxpp,
		}
	end
	set.ivs = self.ivs
	set.evs = self:getEVs()
	set.nature = self:getNature().name
	if not ignoreHPState then set.hp = self.hp end
	if self.egg then
		set.hp = 0
		set.isEgg = true
	else
		set.forme = self:getFormeId()
	end
	set.isNotOT = (self.ot and self.PlayerData and self.ot ~= self.PlayerData.userId)
	--	set.pokerus = self.pokerus -- todo
	set.index = self:getPartyIndex()
	set.pokeball = self.pokeball
	return set
end

function Pokemon:isLead()
	local lead = false
	pcall(function()
		if self.PlayerData:getFirstNonEgg() == self then
			lead = true
		end
	end)
	return lead
end

function Pokemon:getPartyIndex()
	for i = 1, 6 do
		if self.PlayerData.party[i] == self then
			return i
		end
	end
end

function Pokemon:getLearnedMoves()
	local Regional = {
		"Alola",
		"Galar",
		"Hisui",
		"Paldea"
	}

	local forme = self.forme

	if forme and string.sub(forme, 1, 5) == "totem" then
		forme = string.sub(forme, 6, string.len(forme))
	end

	local LearnedMoves = _f.Database.LearnedMoves
	local fMoves = LearnedMoves.Female[Utilities.toId(self.name)]
	if self.gender == 'F' and fMoves then
		return fMoves
		-- female special moves setup
	elseif forme and LearnedMoves.Formes[Utilities.toId(self.name..''..forme)] then
		local moves = LearnedMoves.Formes[Utilities.toId(self.name..''..forme)]
		if moves then
			return moves
		end
		--New System for forme
	else
		if forme then
			for i=1, #Regional do
				local Region = Regional[i]
				local lR = string.len(Region)
				if string.sub(forme, 1, lR) == Region then
					forme = string.sub(forme, lR, string.len(forme))
					local sub = ""
					if forme then
						sub = string.sub(forme, lR+1, string.len(forme))
					end
					local moves = LearnedMoves[Region][Utilities.toId(self.name..sub)]
					if moves then
						return moves
					end
				end
			end
		end    
		-- regional forme setup, just add forme name to regional table - bgc
	end
	-- Create a default structure if no learned moves are found
	local defaultMoves = LearnedMoves[self.num]
	if defaultMoves then
		return defaultMoves
	else
		-- Return a properly structured empty table to prevent nil errors
		return {levelUp = {}, machine = {}, egg = {}, evolve = nil}
	end
end

function Pokemon:canLearnMove(num)
	local lm = self:getLearnedMoves()
	local num = type(num) == "string" and _f.Database.MoveById[num].num or num
	local tags = {
		"machine",
		"egg",
		"tutor",
		"event",
	}

	if not num then return end

	for i, d in pairs(lm.levelUp) do
		if d[1] <= self.level then
			for i=2, #d do
				if d[i] == num then return true end
			end
		end
	end

	for i, tag in pairs(tags) do
		if lm[tag] and table.find(lm[tag], num) then return true end
	end

	return false
end

function Pokemon:getMovesLearnedAtLevel(level)
	local moves = self:getLearnedMoves()
	if not moves.levelUp then return end
	for _, md in pairs(moves.levelUp) do
		if md[1] == level then
			local list = {}
			for i = 2, #md do
				list[i-1] = md[i]
			end
			return list
		end
	end
end

function Pokemon:forceLearnLevelUpMoves(startLevel, endLevel) -- used by daycare
	local s, r = pcall(function()
		local function learn(num)
			for _, m in pairs(self:getMoves()) do
				if num == m.num then return end
			end
			table.insert(self.moves, {id = getMoveData(num).id})
			while #self.moves > 4 do
				table.remove(self.moves, 1)
			end
		end
		for _, lm in pairs(self:getLearnedMoves().levelUp) do
			if lm[1] > endLevel then break end
			if lm[1] >= startLevel then
				for i = 2, #lm do
					learn(lm[i])
				end
			end
		end
	end)
	if not s then
		warn('error occurred while trying to force learn level up moves:')
		warn(r)
	end
end

function Pokemon:calculateStats(withBaseStats)
	local data = self.data
	local bs = withBaseStats or data.baseStats

	self.stats = {atk = 0, def = 0, spa = 0, spd = 0, spe = 0}
	local statIndices = {atk = 2, def = 3, spa = 4, spd = 5, spe = 6}
	local nature = self:getNature()
	for statName in pairs(self.stats) do
		local index = statIndices[statName]
		local stat = bs[index]
		stat = math.floor(math.floor(2 * stat + self.ivs[index] + math.floor(self.evs[index] / 4)) * self.level / 100 + 5)
		if statName == nature.plus then stat = stat * 1.1 end
		if statName == nature.minus then stat = stat * 0.9 end
		self.stats[statName] = math.floor(stat)
	end

	self.maxhp = math.floor(math.floor(2 * data.baseStats[1] + self.ivs[1] + math.floor(self.evs[1] / 4) + 100) * self.level / 100 + 10)
	if bs[1] == 1 then self.maxhp = 1 end -- Shedinja
	self.hp = math.min(self.maxhp, self.hp or self.maxhp)
end

function Pokemon:getStats(level, baseStats) -- returns 5-element array from ATK to SPEED (with HP excluded) for viewSummary requests
	local bs = baseStats or self.data.baseStats
	local stats = {0, 0, 0, 0, 0}
	local nature = self:getNature()
	local statNames = {'atk', 'def', 'spa', 'spd', 'spe'}
	for s = 2, 6 do
		local stat = bs[s]
		stat = math.floor(math.floor(2 * stat + self.ivs[s] + math.floor(self.evs[s] / 4)) * (level or self.level) / 100 + 5)
		local statName = statNames[s-1]
		if statName == nature.plus then stat = stat * 1.1 end
		if statName == nature.minus then stat = stat * 0.9 end
		stats[s-1] = math.floor(stat)
	end
	return stats
end

function Pokemon:heal()
	self:calculateStats()
	self.hp = self.maxhp
	self.status = nil
	for i, m in pairs(self:getMoves()) do
		self.moves[i].pp = m.maxpp
	end
end

do -- TODO: I don't think this function is even used...
	local players = game:GetService('Players')
	local usernameCache = {}
	function Pokemon:getOT()
		local pd = self.PlayerData
		local ot = self.ot
		if not ot or ot == pd.userId then return pd.player.Name, pd.userId end
		if ot <= 0 then
			return 'Guest', 0
		end
		local cachedName = usernameCache[ot]
		if cachedName then return cachedName, ot end
		local name
		local s = pcall(function() name = players:GetNameFromUserIdAsync(self.ot) end)
		--	if not s then
		--		print(self.ot)
		--	end
		usernameCache[ot] = name
		return name, self.ot
	end
end

function Pokemon:getMoves()
	local moves = {}
	for i, m in pairs(self.moves) do
		if not m.id then
			warn('corrupt move found: '..self.name..'['..i..']')
		end
		local moveData = getMoveData(m.id)
		local maxpp = (m.ppup and moveData.pp>1) and math.floor(moveData.pp*(1+.2*m.ppup)) or moveData.pp
		moves[i] = {
			num = moveData.num,
			id = moveData.id,
			name = moveData.name,
			pp = m.pp or maxpp,
			maxpp = maxpp,
			type = moveData.type,
			basePower = moveData.basePower,
			accuracy = moveData.accuracy,
			desc = moveData.desc,
			category = moveData.category,
		}
	end
	return moves
end

function Pokemon:getNature()
	local natures = {
		--[[01]]{name='Hardy'                           },
		--[[02]]{name='Lonely',  plus='atk', minus='def'},
		--[[03]]{name='Brave',   plus='atk', minus='spe'},
		--[[04]]{name='Adamant', plus='atk', minus='spa'},
		--[[05]]{name='Naughty', plus='atk', minus='spd'},
		--[[06]]{name='Bold',    plus='def', minus='atk'},
		--[[07]]{name='Docile'                          },
		--[[08]]{name='Relaxed', plus='def', minus='spe'},
		--[[09]]{name='Impish',  plus='def', minus='spa'},
		--[[10]]{name='Lax',     plus='def', minus='spd'},
		--[[11]]{name='Timid',   plus='spe', minus='atk'},
		--[[12]]{name='Hasty',   plus='spe', minus='def'},
		--[[13]]{name='Serious'                         },
		--[[14]]{name='Jolly',   plus='spe', minus='spa'},
		--[[15]]{name='Naive',   plus='spe', minus='spd'},
		--[[16]]{name='Modest',  plus='spa', minus='atk'},
		--[[17]]{name='Mild',    plus='spa', minus='def'},
		--[[18]]{name='Quiet',   plus='spa', minus='spe'},
		--[[19]]{name='Bashful'                         },
		--[[20]]{name='Rash',    plus='spa', minus='spd'},
		--[[21]]{name='Calm',    plus='spd', minus='atk'},
		--[[22]]{name='Gentle',  plus='spd', minus='def'},
		--[[23]]{name='Sassy',   plus='spd', minus='spe'},
		--[[24]]{name='Careful', plus='spd', minus='spa'},
		--[[25]]{name='Quirky'                          },
	}
	return natures[self.nature]
end

function Pokemon:addHappiness(a, b, c)
	local mult = 1
	if self:getPokeBall() == 'luxuryball' and a > 0 then
		mult = 2
	end
	if self.happiness < 100 then
		self.happiness = self.happiness + a * mult
	elseif self.happiness < 200 then
		self.happiness = self.happiness + (b or a) * mult
	else
		self.happiness = self.happiness + (c or b or a) * mult
	end
	self.happiness = math.max(0, math.min(255, self.happiness))
end

function Pokemon:getIcon(ignoreEgg)--::getIcon
	local icon = self.data.icon-1
	local alts = {['Unown-b']        =215-1,
		['Unown-c']        =216-1,
		['Unown-d']        =217-1,
		['Unown-e']        =218-1,
		['Unown-exclaim']  =219-1,
		['Unown-f']        =220-1,
		['Unown-g']        =221-1,
		['Unown-h']        =222-1,
		['Unown-i']        =223-1,
		['Unown-j']        =224-1,
		['Unown-k']        =225-1,
		['Unown-l']        =226-1,
		['Unown-m']        =227-1,
		['Unown-n']        =228-1,
		['Unown-o']        =229-1,
		['Unown-p']        =230-1,
		['Unown-q']        =231-1,
		['Unown-query']    =232-1,
		['Unown-r']        =233-1,
		['Unown-s']        =234-1,
		['Unown-t']        =235-1,
		['Unown-u']        =236-1,
		['Unown-v']        =237-1,
		['Unown-w']        =238-1,
		['Unown-x']        =239-1,
		['Unown-y']        =240-1,
		['Unown-z']        =241-1,
		['Victini-blue']   =886-1,
		['Volcanion-black']=890-1,
		['Haunter-hallow'] =892-1,
		['Gengar-hallow']  =893-1,

		['Mew-rainbow']    =1114-1,
		['Onix-crystal']   =1024-1,
		['Steelix-crystal']=1025-1,
	}
	if self.egg and not ignoreEgg then
		if self.fossilEgg then
			return 1820 -- egg threshold dependent
		else
			return 1450 + (self.data.eggIcon or 135) -- egg threshold
		end
	elseif self.num == 666 then
		-- Vivillon
		icon = icon + (({
			archipelago =  1,
			continental =  2,
			elegant     =  3,
			fancy      =  4,
			garden      =  5,
			highplains  =  6,
			icysnow     =  7,
			jungle      =  8,
			marine      =  9,
			modern      = 10,
			monsoon     = 11,
			ocean       = 12,
			pokeball   = 13,
			polar       = 14,
			river       = 15,
			sandstorm   = 16,
			savanna     = 17,
			sun         = 18,
			tundra      = 19,
		})[self:getFormeId()] or 0)
	elseif self.forme and (self.num == 669 or self.num == 670 or self.num == 671) then
		-- Flabebe, Floette, Florges
		if self.forme == 'e' then
			icon = icon + 2
		else
			icon = icon + ({
				b=1,
				o=2,
				w=3,
				y=4,
			})[self.forme]
			if self.num == 670 and self.forme ~= 'b' then
				icon = icon + 1
			end
		end
	elseif self.forme and (self.num == 745) then
		if self.forme == 'midnight' then
			icon = icon + 1
		end

	elseif self.forme and alts[self.name..'-'..self.forme] then
		icon = alts[self.name..'-'..self.forme]
	elseif self.gender == 'F' then
		-- Unfezant, Frillish, Jellicent, Pyroar, Meowstic
		if ({[598]=true,[678]=true,[680]=true,[782]=true,[815]=true})[icon+1] then -- TODO: HIPPOWDON/INDEEDEE
			icon = icon + 1
		end
	end
	return icon
end

function Pokemon:getCharacteristic()
	local characteristics = {
		{ 'Loves to eat',            'Proud of its power',      'Sturdy body',            'Highly curious',        'Strong willed',     'Likes to run' },
		{ 'Takes plenty of siestas', 'Likes to thrash about',   'Capable of taking hits', 'Mischievous',           'Somewhat vain',     'Alert to sounds' },
		{ 'Nods off a lot',          'A little quick tempered', 'Highly persistent',      'Thoroughly cunning',    'Strongly defiant',  'Impetuous and silly' },
		{ 'Scatters things often',   'Likes to fight',          'Good endurance',         'Often lost in thought', 'Hates to lose',     'Somewhat of a clown' },
		{ 'Likes to relax',          'Quick tempered',          'Good perseverance',      'Very finicky',          'Somewhat stubborn', 'Quick to flee' },
	}
	local maxivs = {}
	local maxiv = 0
	for i = 1, 6 do
		if self.ivs[i] > maxiv then
			maxiv = self.ivs[i]
			maxivs = {[i] = true}
		elseif self.ivs[i] == maxiv then
			maxivs[i] = true
		end
	end
	local stat
	local stats = {1, 2, 3, 6, 4, 5}
	local p = self.personality%6+1
	for i = p, 6 do
		if maxivs[stats[i]] then
			stat = stats[i]
			break
		end
	end
	if not stat then
		for i = 1, p-1 do
			if maxivs[stats[i]] then
				stat = stats[i]
				break
			end
		end
	end
	return characteristics[maxiv%5+1][stat]
end

function Pokemon:getTypeNums()
	return self.data.types
end

function Pokemon:getTypes(fromTypes)
--[[	if self.num == 493 then
		local forme = self:getFormeId()
		if forme then
			return {forme:sub(1,1):upper()..forme:sub(2)}
		end
		return {'Normal'}
	end--]]
	local typeFromInt = {'Bug','Dark','Dragon','Electric','Fairy','Fighting','Fire','Flying','Ghost','Grass','Ground','Ice','Normal','Poison','Psychic','Rock','Steel','Water'}
	local types = {}
	for i, t in pairs(fromTypes or self:getTypeNums()) do
		types[i] = typeFromInt[t]
	end
	return types
end

function Pokemon:getAbilityName()
	if self.hiddenAbility and self.data.hiddenAbility then
		return self.data.hiddenAbility
	elseif #self.data.abilities == 1 then
		return self.data.abilities[1]
	end
	local a = math.floor(self.personality / 65536) % 2
	if self.swappedAbility then a = 1-a end
	return self.data.abilities[a+1]
end

function Pokemon:getAbilityConfig()
	if self.hiddenAbility and self.data.hiddenAbility then
		return 3
	elseif #self.data.abilities == 1 then
		return 1
	end
	local a = math.floor(self.personality / 65536) % 2
	if self.swappedAbility then a = 1-a end
	return a+1
end

function Pokemon:getHeldItem()--::getHeldItem
	if not self.item then return {} end
	return getItemData(self.item)
end

function Pokemon:getPokeBall(ballId)
	return self.balls[ballId or self.pokeball or 1]
end

function Pokemon:getRequiredExperienceForLevel(lvl)
	local rate = self.data.expRate or 2
	if lvl == 1 then return 0 end
	if rate == 0 then -- Erratic
		if lvl <= 50 then
			return math.floor(lvl^3 * (100-lvl) / 50)
		elseif lvl <= 68 then
			return math.floor(lvl^3 * (150-lvl) / 100)
		elseif lvl <= 98 then
			return math.floor(lvl^3 * math.floor((1911-10*lvl) / 3) / 500)
		end
		return math.floor(lvl^3 * (160-lvl) / 100)
	elseif rate == 1 then -- Fast
		return math.floor(lvl^3 * 4 / 5)
	elseif rate == 2 then -- Medium Fast
		return lvl^3
	elseif rate == 3 then -- Medium Slow
		return math.floor(lvl^3 * 6 / 5) - (lvl^2 * 15) + (lvl * 100) - 140
	elseif rate == 4 then -- Slow
		return math.floor(lvl^3 * 5 / 4)
	elseif rate == 5 then -- Fluctuating
		if lvl <= 15 then
			return math.floor(lvl^3 * (math.floor((lvl+1)/3)+24)/50)
		elseif lvl <= 36 then
			return math.floor(lvl^3 * (lvl+14)/50)
		end
		return math.floor(lvl^3 * (math.floor(lvl/2)+32)/50)
	end
end

function Pokemon:getLevelFromExperience(xp)
	xp = xp or self.experience
	if xp == 0 then
		return 1
	elseif xp >= self:getRequiredExperienceForLevel(100) then
		return 100
	end
	local guess = 50
	local inc = 50
	while true do
		local rxp = self:getRequiredExperienceForLevel(guess)
		local rxppo = self:getRequiredExperienceForLevel(guess+1)
		if rxp == xp or (rxp < xp and rxppo > xp) then
			return guess
		elseif rxp > xp then
			inc = math.ceil(inc/2)
			guess = guess - inc
		elseif rxp < xp then
			inc = math.ceil(inc/2)
			guess = guess + inc
		end
	end
end

do -- todo
	local floor = math.floor
	function Pokemon:hash()
		local b = 100
		if self.shiny then b = b + 4 end
		if self.hiddenAbility then b = b + 8 end
		local ivs = self.ivs
		local p = self.personality
		p = {p%256,floor(p/256)%256,floor(p/65536)%256,floor(p/16777216)%256}
		for i, v in pairs(p) do if v == 0 then p[i] = 33 end end
		local o = self.ot or self.PlayerData.userId
		o = {o%256,floor(o/256)%256,floor(o/65536)%256,floor(o/16777216)%256}
		for i, v in pairs(o) do if v == 0 then o[i] = 87 end end
		local n = 20+self.data.num -- CANNOT USE THIS; MUST USE BASE_EVOLUTION'S NUM
		n = {n%256,floor(n/256)%256}
		for i, v in pairs(n) do if v == 0 then n[i] = 87 end end
		return string.char(b,o[2],n[2],p[3],p[1],12+ivs[3],112+ivs[1],106+ivs[5],n[1],p[2],28+ivs[2],113+ivs[6],o[1],68+ivs[4],p[4],o[4],44+(self.pokeball or 1),43+self.nature,o[3])
	end
end

function Pokemon:serialize(inPC)
	local buffer = BitBuffer.Create()
	local version = 4
	buffer:WriteUnsigned(6, version)
	buffer:WriteBool(inPC and true or false)
	buffer:WriteUnsigned(10, self.data.num)
	buffer:WriteBool(self.egg and true or false)
	if self.egg then
		buffer:WriteBool(self.fossilEgg and true or false) -- v3
		buffer:WriteUnsigned(7, math.max(0, math.min(127, self.eggCycles))) -- v3: 7-bit (was 6)
	end
	buffer:WriteBool(self.shiny and true or false)
	buffer:WriteBool(self.untradable and true or false) -- v2
	buffer:WriteBool(self.hiddenAbility and true or false)
	buffer:WriteBool(self.swappedAbility and true or false)
	buffer:WriteBool(self.nickname ~= nil)
	if self.nickname then
		buffer:WriteString(self.nickname)
	end
	buffer:WriteBool(self.forme ~= nil)
	if self.forme then
		buffer:WriteString(self.forme)
	end
	buffer:WriteUnsigned(5, self.pokeball or 1)
	buffer:WriteUnsigned(21, self.experience or self:getRequiredExperienceForLevel(self.level or 1))
	buffer:WriteUnsigned(32, self.personality or math.floor(2^32 * math.random()))
	buffer:WriteUnsigned(5, self.nature or math.random(25))
	buffer:WriteUnsigned(8, math.max(0, math.min(255, self.happiness or 0)))
	buffer:WriteBool(self.happinessOT ~= nil) -- begin v1``
	if self.happinessOT then
		buffer:WriteUnsigned(8, self.happinessOT)
	end -- end v1
	local ivs = self.ivs or {}
	local evs = self.evs or {}
	for i = 1, 6 do
		buffer:WriteUnsigned(5, ivs[i] or math.random(0, 31))
		buffer:WriteUnsigned(8, math.max(0, math.min(252, evs[i] or 0)))
	end
	if not inPC then
		buffer:WriteUnsigned(10, math.max(0, self.hp or self.maxhp))
		local status = 0
		if self.status then
			local statuses = {brn=1, frz=2, par=3, psn=4,tox=4, slp1=5, slp2=6, slp3=7}
			status = statuses[self.status] or 0
		end
		buffer:WriteUnsigned(3, status)
	end
	local moves = self:getMoves()
	for i = 1, 4 do
		if not moves[i] then
			buffer:WriteBool(false)
			break
		end
		buffer:WriteBool(true)
		buffer:WriteUnsigned(10, moves[i].num)
		buffer:WriteUnsigned(2, moves[i].ppup or 0)
		if not inPC then
			buffer:WriteUnsigned(6, moves[i].pp) -- TODO: with PP Up these can get higher than 6 bits :l
		end
	end
	buffer:WriteUnsigned(33, math.max(0, self.ot or self.PlayerData.userId))
	local item = self:getHeldItem()
	if item and item.num then
		buffer:WriteBool(true)
		buffer:WriteUnsigned(10, item.num)
	else
		buffer:WriteBool(false)
	end
	local hasMarking = false
	if self.marking then
		for i = 1, 5 do
			if self.marking[i] then
				hasMarking = true
				break
			end
		end
	end
	buffer:WriteBool(hasMarking)
	if hasMarking then
		for i = 1, 5 do
			buffer:WriteBool(self.marking[i] and true or false)
		end
	end
	local stamps = self.stamps-- v4
	if stamps then
		buffer:WriteUnsigned(2, #stamps)
		for _, stamp in pairs(stamps) do
			buffer:WriteUnsigned(4, stamp.sheet)
			buffer:WriteUnsigned(5, stamp.n)
			buffer:WriteUnsigned(5, stamp.color)
			buffer:WriteUnsigned(3, stamp.style)
		end
	else
		buffer:WriteUnsigned(2, 0)
	end

	return buffer:ToBase64()
end

function Pokemon:deserialize(str, PlayerData)
	local self = {}
	local buffer = BitBuffer.Create()
	buffer:FromBase64(str)
	local version = buffer:ReadUnsigned(6)
	local inPC = buffer:ReadBool()
	self.num = buffer:ReadUnsigned(10)
	if buffer:ReadBool() then
		self.egg = true
		if version >= 3 and buffer:ReadBool() then
			self.fossilEgg = true
		end
		self.eggCycles = buffer:ReadUnsigned(version >= 3 and 7 or 6)
	end
	self.shiny = buffer:ReadBool()
	if version >= 2 then
		local untradable = buffer:ReadBool()
		if untradable then
			local num = self.num
			if num == 133 or num == 134 or num == 135 or num == 136 or num == 196 or num == 197 or num == 470 or num == 471 or num == 700 then
				-- here we remove Eevee's untradability as a side effect of the free release
			else
				self.untradable = true
			end
		end
	end
	self.hiddenAbility = buffer:ReadBool()
	self.swappedAbility = buffer:ReadBool()
	if buffer:ReadBool() then
		local nickname = buffer:ReadString()
		self.nickname = nickname
		spawn(function()
			nickname = Pokemon:filterNickname(nickname, PlayerData.player)
			self.nickname = (nickname ~= '') and nickname or nil
		end)
	end
	if buffer:ReadBool() then
		self.forme = buffer:ReadString()

		if table.find({93, 94}, self.num) and self.forme == "hallow" then -- adding tag to hw haunter & gengar 
			self.event = true
		end
	end
	self.pokeball = buffer:ReadUnsigned(5)
	self.experience = buffer:ReadUnsigned(21)
	self.personality = buffer:ReadUnsigned(32)
	self.nature = buffer:ReadUnsigned(5)
	self.happiness = buffer:ReadUnsigned(8)
	if version >= 1 then -- Happiness resets to baseHappiness when traded;
		if buffer:ReadBool() then -- If traded back to the OT, happiness is restored to the value it had before being traded away
			self.happinessOT = buffer:ReadUnsigned(8) -- ^^^ uh, this was never implemented...
		end
	end
	self.ivs = {}
	self.evs = {}
	for i = 1, 6 do
		self.ivs[i] = buffer:ReadUnsigned(5)
		self.evs[i] = buffer:ReadUnsigned(8)
	end
	if not inPC then
		self.hp = buffer:ReadUnsigned(10)
		local status = buffer:ReadUnsigned(3)
		if status ~= 0 then
			local statuses = {'brn', 'frz', 'par', 'psn', 'slp1', 'slp2', 'slp3'}
			self.status = statuses[status]
		end
	end
	local moves = {}
	for i = 1, 4 do
		if not buffer:ReadBool() then break end
		moves[i] = {}
		local mnum = buffer:ReadUnsigned(10)
		local moveData = getMoveData(mnum)
		if not moveData then
			warn("Invalid move number encountered during deserialization:", mnum)
			moves[i].id = 1  -- Default to Tackle or another basic move
		else
			moves[i].id = moveData.id
		end
		moves[i].ppup = buffer:ReadUnsigned(2)
		if not inPC then
			moves[i].pp = buffer:ReadUnsigned(6)
		end
	end
	self.moves = moves
	self.ot = buffer:ReadUnsigned(33)
	if not self.ot or self.ot == 0 then
		if PlayerData and PlayerData.userId and PlayerData.userId > 0 then
			self.ot = PlayerData.userId
		else
			self.ot = 0  -- Fallback value if no valid userId
		end
		-- Log the issue for debugging
		if PlayerData and PlayerData.player then
			_f.Network:postToDiscord('ServerP', 'Fixed invalid OT in deserialization for '..PlayerData.player.Name)
		end
	end
	if buffer:ReadBool() then
		local num = buffer:ReadUnsigned(10)
		if num ~= 0 then
			self.item = num
		end
	end
	if buffer:ReadBool() then
		self.marking = {}
		for i = 1, 5 do
			if buffer:ReadBool() then
				self.marking[i] = true
			end
		end
	end
	if version >= 4 then
		local stamps = {}
		for i = 1, buffer:ReadUnsigned(2) do
			stamps[i] = {
				sheet = buffer:ReadUnsigned(4),
				n     = buffer:ReadUnsigned(5),
				color = buffer:ReadUnsigned(5),
				style = buffer:ReadUnsigned(3)
			}
		end
		if #stamps > 0 then
			self.stamps = stamps
		end
	end
	--end
	--^ uncomment that when you figure out how to do glaceon

	return Pokemon:new(self, PlayerData)--, buffer:GetPtr()
end

function Pokemon:remove()
	self.PlayerData = nil -- remove circular reference
end

function Pokemon:getGen()
	local gen = 0
	local gens = {
		{906, "9"  },
		--{899, "8.5"},
		{810, "8"  },
		--{808, "7.5"},
		{722, "7"  },
		{650, "6"  },
		{494, "5"  },
		{387, "4"  },
		{252, "3"  },
		{152, "2"  },
		{1,   "1"  },
	}

	for i, genData in pairs(gens) do
		local num, g = unpack(genData)
		if self.num >= num then
			gen = g
			break
		end
	end

	return gen
end

function Pokemon:getClass()
    --[[
        "", "", "",
        "", "", "",
        "", "", "",
    ]]
	local checkOrder = {"name", "forme"}
	local Classes = {}
	local ClassList = {
		["Starter"] = {            
			"Bulbasaur", "Ivysaur", "Venusaur",
			"Charmander", "Charmeleon", "Charizard",  
			"Squirtle", "Wartortle", "Blastoise",

			"Chikorita", "Bayleef", "Meganium",
			"Cyndaquil", "Quilava", "Typhlosion",
			"Totodile", "Croconaw", "Feraligatr",

			"Treecko", "Grovyle", "Sceptile",
			"Torchic", "Combusken", "Blaziken",
			"Mudkip",  "Marshtomp", "Swampert",

			"Turtwig", "Grotle", "Torterra",
			"Chimchar", "Monferno", "Infernape",
			"Piplup", "Prinplup", "Empoleon",

			"Snivy", "Servine", "Serperior",
			"Tepig", "", "Pignite", "Emboar",
			"Oshawott", "Dewott", "Samurott",

			"Chespin", "Quilladin", "Chesnaught",
			"Fennekin", "Braixen", "Delphox",
			"Froakie", "Frogadier", "Greninja",

			"Rowlet", "Dartrix", "Decidueye",
			"Litten", "Torracat", "Incineroar",
			"Popplio", "Brionne", "Primarina",

			"Grookey", "Thwackey", "Rillaboom",
			"Scorbunny", "Raboot", "Cinderace",
			"Sobble", "Drizzile", "Inteleon",

			"Sprigatito", "Floragato", "Meowscarada",
			"Fuecoco", "Crocalor", "Skeledirge", 
			"Quaxly", "Quaxwell", "Quaquavell",

			--"Pikachu", "Eevee", -- Maybe?


		},
		["Pseudo Legendary"] = {
			"Dragonite", "Dragonair", "Dratini",
			"Tyranitar", "Pupitar", "Larvitar",
			"Salamence", "Shelgon", "Bagon",
			"Metagross", "Metang", "Beldum",
			"Garchomp", "Gabite", "Gible",
			"Hydreigon", "Zweilous", "Dieno",
			"Goodra", "Sliggoo", "Gloomy",
			"Kommo-o", "Hakamo-o", "Jangmo-o",
			"Dragapult", "Drakloak", "Dreepy",
			"Baxcalibur", "Arctibax", "Frigibax",
		},	
		["Fossil"] = {
			"Kabuto", "Kabutops",
			"Omanyte", "Omastar",
			"Aerodactyl",
			"Anorith", "Armaldo",
			"Lileep", "Cradily",
			"Cranidos", "Rampardos",
			"Shieldon", "Bastiodon",
			"Tirtouga", "Carracosta",
			"Archen", "Archeops",
			"Genesect",
			"Tyrunt", "Tyrantrum",
			"Amaura", "Aurorus",
			"Dracozolt", "Arctozolt",
			"Dracovish", "Arctovish",
		},
		["Mythical"] = {
			'Mew', 'Celebi', 'Jirachi', 
			'Deoxys', 'Phione', 'Manaphy',
			'Darkrai', 'Shaymin', 'Arceus',
			'Victini', 'Keldeo', 'Meloetta',
			'Genesect', 'Diancie', 'Hoopa',
			'Volcanion', 'Magearna', 'Marshadow',
			'Zeraora', 'Meltan', 'Melmetal', 'Zarude'
		},
		["Legendary"] = {
			'Articuno', 'Zapdos', 'Moltres',
			'Mewtwo',
			'Raikou', 'Entei', 'Suicune',
			'Lugia', 'Ho-oh',
			'Regirock', 'Regice', 'Registeel', 
			'Latias', 'Latios',
			'Groudon', 'Kyogre', 'Rayquaza',
			'Uxie', 'Mesprit', 'Azelf',
			'Heatran', 'Regigigas', 'Cresselia',
			'Cobalion', 'Terrakion', 'Virizion',
			'Tornadus', 'Thundurus', 'Landorus',
			'Reshiram', 'Zekrom', 'Kyurem',
			'Xerneas', 'Yveltal', 'Zygarde',
			'Type: Null', 'Silvally',
			'Tapu Koko', 'Tapu Lele', 'Tapu Bulu', 'Tapu Fini',
			'Cosmog', 'Cosmoem', 'Solgaleo', 'Lunala', 'Necrozma',
			'Kubfu', 'Urshifu', 'Regieleki', 'Regidrago',
			'Spectrier', 'Glastrier', 'Calyrex',
			'Zacian', 'Zamazenta', 'Eternatus',
			'Enamorus', 'Ting-Lu', 'Chien-Pao', 'Wo-Chien', 'Chi-Yu',
			'Koraidon', 'Miraidon'
		},
		["Ultra Beast"] = {
			'Necrozma', 'Poipole', 'Naganadel',
			'Stakataka', 'Guzzlord', 'Blacephalon',
			'Kartana', 'Buzzwole', 'Celesteela',
			'Xurkitree', 'Pheromosa', 'Nihilego',
		},
		["Paradox"] = {
			"Great Tusk", "Scream Tail", 
			"Brute Bonnet", "Flutter Mane",
			"Slither Wing", "Sandy Shocks", 
			"Koraidon", "Walking Wake",
			"Iron Treads", "Iron Bundle", 
			"Iron Hands", "Iron Jugulis",
			"Iron Moth", "Iron Thorns", 
			"Miraidon", "Iron Leaves",
		},
		["Event"] = {

		}
	}

	for class, list in pairs(ClassList) do
		if table.find(list, self.name) then
			table.insert(Classes, class)
		end
		--local isGood = true
		--for i, data in pairs(list) do
		--	if type(data) == "table" then
		--		for _i, check in pairs(checkOrder) do
		--			if self[check] ~= data[i] then
		--				isGood = false
		--				break
		--			end
		--		end
		--	elseif type(data) == "string" and self.name ~= data then
		--		isGood = false
		--	else
		--		isGood = false
		--	end

		--	if isGood then
		--		table.insert(Classes, class)
		--	end
		--end 
	end


	if self.data then
		if self.data.evos and not self.data.prevo then
			table.insert(Classes, "Baby")
		elseif self.data.evos and self.data.prevo then
			table.insert(Classes, "Middle Stage")
		elseif not self.data.evos and self.data.prevo then
			table.insert(Classes, "Final Stage")
		end
	end

	return Classes
end

function Pokemon:getSafeForme()
	local overrides = {
		["bb"] = "Ash",
		["whitechristmas"] = "White Christmas",
		["darkice"] = "Dark Ice"
	}
	local forme = self:getFormeId()

	if not forme then return "No Form" end
	if overrides[forme] then return overrides[forme] end

	return string.upper(string.sub(forme, 1, 1))..string.sub(forme, 2, string.len(forme))
end

function Pokemon:getPCSearchData(display)
	if self.egg or self.fossilEgg then return false end

	if not self.data then
		self.data = self:getData()
	end

	local data = {
		species = self.name,
		-- gmax = self.gigantamax,
		moves = {},
		helditem = self:getHeldItem().name,
		ability = self:getAbilityName(),
		egggroup = self.data.eggGroups or "Undiscovered",
		form =  self:getSafeForme(),
		nickname = self.nickname or "No Nickname"
	}

	for i, m in pairs(self:getMoves()) do
		data.moves[i] = m.name --dont get id just do toid
	end

	if not display then
		local extra = {
			"shiny",
			"hiddenAbility",
			"level",
			{"nature", self:getNature().name},
			{"type", self:getTypes()},
			"gender",
			{"class", self:getClass()},
			{"generation", "Gen "..self:getGen()},
			{"basestats", self.data.baseStats},
			{"stats", {self.hp, unpack(self:getStats(self.level))}},
			"ivs",
			"evs",
		}

		for i, d in pairs(extra) do
			local v = self[d]

			if type(d) == 'table' then
				d, v = unpack(d)
			end

			data[d] = v
		end
	end

	return data
end

-- Add this to your server-side modules

-- Promo Code Handler
function Pokemon:setupPromoCodeRedemption()
	-- No need to set up network functionality while system is disabled
	print("Promo code system is currently disabled")
end

-- Make sure this is called during initialization
local oldInit = Pokemon.initialize
Pokemon.initialize = function(self, ...)
	local result = oldInit(self, ...)
	self:setupPromoCodeRedemption()
	return result
end

-- At the end of the file, before the return statement
do
	local initialized = false
	local oldInit = Pokemon.initialize
	Pokemon.initialize = function(self, ...)
		if not initialized then
			initialized = true
			self:setupPromoCodeRedemption()
		end
		return oldInit(self, ...)
	end
end

return Pokemon