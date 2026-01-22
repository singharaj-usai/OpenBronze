print("BattleP")
local _f = require(script.Parent.Parent)

local undefined, null, toId, class, shallowcopy, deepcopy, Not, rc4, jsonEncode; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	undefined = util.undefined
	null = util.null
	toId = util.toId
	class = util.class
	shallowcopy = util.shallowcopy
	deepcopy = util.deepcopy
	Not = util.Not
	rc4 = util.rc4
	jsonEncode = util.jsonEncode
end

--local gifData = require(game:GetService('ServerStorage').Data.Spritesheets)


local BattlePokemon
BattlePokemon = class({
	className = 'BattlePokemon',
	
	trapped = false,
	maybeTrapped = false,
	maybeDisabled = false,
	hp = 0,
	maxhp = 100,
--	illusion = nil,
	fainted = false,
	faintQueued = false,
	lastItem = '',
	ateBerry = false,
	status = '',
	position = 0,
	
	lastMove = '',
	moveThisTurn = '',
--	activeTurns = 0, -- was gonna make this a thing, haven't yet
	
	lastDamage = 0,
--	lastAttackedBy = nil,
	usedItemThisTurn = false,
	newlySwitched = false,
	beingCalledBack = false,
	isActive = false,
	isStarted = false,
	transformed = false,
	duringMove = false,
	speed = 0,
	
	__isBattlePokemon = true,
	
}, function(self, set, side)
--	print 'SET'; require(game.ServerStorage.Utilities).print_r(set)
	self.side = side
	self.battle = side.battle
--	if type(set) == 'string' then set = {name = set} end
	
	self.getHealth = function(side) return BattlePokemon.getHealth(self, side) end
	self.getDetails = function(side) return BattlePokemon.getDetails(self, side) end
--	self.getSpriteData = function(side) return BattlePokemon.getSpriteData(self, side) end
	
	self.set = set
	
	self.baseTemplate = self.battle:getTemplate(set.id)
--	if not self.baseTemplate.exists then
--		self.battle:debug('Unidentified species = ' .. self.species)
--		self.baseTemplate = self.battle:getTemplate('Unown')
--	end
	if set.forme then
		local id = self.baseTemplate.species .. '-' .. set.forme
		local formeTemplate = self.battle:getTemplate(id)
		if formeTemplate.exists then
			self.baseTemplate = formeTemplate
		end
		if _f.Database.Spritesheets._FRONT[id] then --require(game:GetService('ServerStorage').Data.Spritesheets)._FRONT[id] then
			self.spriteForme = set.forme
		end
	end
	self.stamps = set.stamps
	self.species = self.baseTemplate.species
	if set.name == set.species or not set.name or not set.species then
		set.name = self.species -- lulwut
	end
	self.name = set.nickname or set.name
	self.speciesid = toId(self.species)
	self.template = self.baseTemplate
	self.moves = {}
	self.baseMoves = self.moves
	self.movepp = {}
	self.moveset = {}
	self.baseMoveset = {}
	
	self.level = self.battle:clampIntRange(self.battle.forcedLevel or set.level or 1, 1, 100)
	
	self.gender = set.gender
	
	self.happiness = set.happiness or self.baseTemplate.baseHappiness
	
	self.fullname = self.side.id .. ': ' .. self.name
	self.details = self.species .. ', L' .. self.level .. (self.gender == '' and '' or ', ') .. self.gender .. (set.shiny and ', shiny' or '')
	if set.shiny then self.shiny = true end
	
	self.id = self.fullname -- shouldn't really be used anywhere
	
	self.statusData = {}
	self.volatiles = {}
--	self.negateImmunity = {}
	
	self.height = self.template.height
	self.heightm = self.template.heightm
	self.weight = self.template.weight
	self.weightkg = self.template.weightkg
	
	if type(set.ability) == 'number' then
--		if not self.baseTemplate.abilities then
--			print(self.baseTemplate.species)
--			require(game.ServerStorage.Utilities).print_r(self.baseTemplate)
--		end
		if set.ability == 3 and self.baseTemplate.hiddenAbility then
			set.ability = self.baseTemplate.hiddenAbility
		elseif set.ability == 2 and #self.baseTemplate.abilities > 1 then
			set.ability = self.baseTemplate.abilities[2]
		else
			set.ability = self.baseTemplate.abilities[1]
		end
	end
	self.baseAbility = toId(set.ability)
	self.ability = self.baseAbility
	if set.item then self.item = toId(set.item) end
	self.abilityData = {id = self.ability}
	self.itemData = {id = self.item}
	self.speciesData = {id = self.speciesid}
	
	self.types = {}
	if not self.template.types then
		print('potentially corrupt template:', set.id)
	end
	for i, t in pairs(self.template.types) do
		self.types[i] = self.battle.data.TypeFromInt[t]
	end
	self.typesData = {}
	for _, t in pairs(self.types) do
		table.insert(self.typesData, { type = t, suppressed = false, isAdded = false })
	end
	
	if not set.moves then
		local moves = {}
		local learnedMoves = _f.Database.LearnedMoves[self.baseTemplate.num]
		if self.species == 'Meowstic' and self.gender == 'F' then
			learnedMoves = _f.Database.FemaleMeowsticLearnedMoves
	--	elseif self.species == 'Indeedee' and self.gender == 'F' then
	--		learnedMoves = _f.Database.FemaleIndeedeeLearnedMoves
		elseif self.species == 'Lycanroc' and self.forme == 'midnight' then --will this work? lycanroc midnight
			learnedMoves = _f.Database.MidnightMoves
		end
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
			moves[i] = {id = _f.Database.MoveByNumber[num].id}
		end
		set.moves = moves
	end
	for i, m in pairs(set.moves) do
		local move = self.battle:getMove(m.id)
		if move.id then
			table.insert(self.baseMoveset, {
				move = move.name,
				id = move.id,
				pp = m.pp or move.pp,--(move.noPPBoosts and move.pp or move.pp * 8 / 5),
				maxpp = m.maxpp or move.pp,--(move.noPPBoosts and move.pp or move.pp * 8 / 5),
				target = (move.nonGhostTarget and not self:hasType('Ghost')) and move.nonGhostTarget or move.target,
				disabled = false,
				used = false
			})
			table.insert(self.moves, move.id)
		end
	end
	self.disabledMoves = {}
	
	self.canMegaEvo = self.battle:canMegaEvo(self)
	self.canZMove = self.battle:canZMove(self)

	self.evs = {}
	self.ivs = {}
	if not set.evs then
		set.evs = {0, 0, 0, 0, 0, 0}
	end
	for i, v in pairs({'hp','atk','def','spa','spd','spe'}) do
		self.evs[v] = self.battle:clampIntRange(set.evs[i], 0, 252)
		self.ivs[v] = self.battle:clampIntRange(set.ivs[i], 0, 31)
	end
	
	if not self.hpType then
		local hpTypes = {'Fighting', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug', 'Ghost', 'Steel', 'Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Ice', 'Dragon', 'Dark'}
		local hpTypeX = 0
		local i = 1
		for s in pairs({'hp','atk','def','spa','spd','spe'}) do
			hpTypeX = hpTypeX + i * (set.ivs[s] % 2)
			i = i * 2
		end
		self.hpType = hpTypes[math.floor(hpTypeX * 15 / 63)]
		-- In Gen 6, Hidden Power is always 60 base power
	end
	
	self.boosts = {
		atk = 0, def = 0, spa = 0, spd = 0, spe = 0,
		accuracy = 0, evasion = 0
	}
	self.stats = {atk = 0, def = 0, spa = 0, spd = 0, spe = 0}
	self.baseStats = {atk = 10, def = 10, spa = 10, spd = 10, spe = 10}
	local statIndices = {atk = 2, def = 3, spa = 4, spd = 5, spe = 6}
	local nature = self.battle:getNature(set.nature)
	for statName in pairs(self.baseStats) do
		local stat = self.template.baseStats[statIndices[statName]]
		stat = math.floor(math.floor(2 * stat + self.ivs[statName] + math.floor(self.evs[statName] / 4)) * self.level / 100 + 5)
		
		if statName == nature.plus then stat = stat * 1.1 end
		if statName == nature.minus then stat = stat * 0.9 end
		self.baseStats[statName] = math.floor(stat)
	end
	
	self.maxhp = math.floor(math.floor(2 * self.template.baseStats[1] + self.ivs['hp'] + math.floor(self.evs['hp'] / 4) + 100) * self.level / 100 + 10)
	if self.template.baseStats[1] == 1 then self.maxhp = 1 end -- Shedinja
	self.hp = math.min(self.maxhp, set.hp or self.maxhp)
	
	self.isStale = 0
	self.isStaleCon = 0
	self.isStaleHP = self.maxhp
	self.isStalePPTurns = 0
	
	self.baseIvs = deepcopy(self.ivs)
	self.baseHpType = self.hpType
	
	self.ball = set.pokeball or 1
	
	self.participatingFoes = {}
	self.isNotOT = set.isNotOT
	self.pokerus = set.pokerus
	
	self.index = set.index
	self.originalPartyIndex = set.originalPartyIndex
	
	self.aiStrategy = set.strategy
	
	if set.isEgg then self.isEgg = true end
	
	self:clearVolatile(true)
	
	return self
end)


function BattlePokemon:toString()
	local fullname = self.fullname
	if self.illusion then fullname = self.illusion.fullname end
	
	local positionList = 'abcdef'
	if self.isActive then return (self.index or 0) .. fullname:sub(1, 2) .. positionList:sub(self.position, self.position) .. fullname:sub(3) end
	return (self.index or 0) .. fullname
end
BattlePokemon.__concat = function(op1, op2)
	pcall(function() if type(op1) == 'table' then op1 = op1:toString() end end)
	pcall(function() if type(op2) == 'table' then op2 = op2:toString() end end)
	local s, r = pcall(function() return op1 .. op2 end)
	assert(s, 'unable to concatenate BattlePokemon')
	return r
end


function BattlePokemon:getPlayerPokemon()
	local p
	pcall(function() p = _f.PlayerDataService[self.side.player].party[self.index] end)
	return p
end

--function BattlePokemon.getSpriteData(self, side)
--	local spriteTableName = (self.shiny and '_SHINY' or '')..(side==self.side and '_FRONT' or '_BACK')
--	local spriteTable = gifData[spriteTableName]
--	local spriteName = self.baseTemplate.baseSpecies or self.baseTemplate.species
--	local spriteData = spriteTable[spriteName]
--	if self.spriteForme then
--		local spriteFormeName = spriteName .. '-' .. self.spriteForme
--		local spriteFormeData = spriteTable[spriteFormeName]
--		if spriteFormeData then
--			spriteName = spriteFormeName
--			spriteData = spriteFormeData
--		end
--	elseif self.gender == 'F' then
--		
--	end
--	return jsonEncode({spriteTableName, spriteName, spriteData})
--end

function BattlePokemon:recalculateStats()
	if self.transformed then return end
	self.stats = {atk = 0, def = 0, spa = 0, spd = 0, spe = 0}
	self.baseStats = {atk = 10, def = 10, spa = 10, spd = 10, spe = 10}
	local statIndices = {atk = 2, def = 3, spa = 4, spd = 5, spe = 6}
	local nature = self.battle:getNature(self.set.nature)
	for statName in pairs(self.baseStats) do
		local stat = self.template.baseStats[statIndices[statName]]
		stat = math.floor(math.floor(2 * stat + self.ivs[statName] + math.floor(self.evs[statName] / 4)) * self.level / 100 + 5)
		
		if statName == nature.plus then stat = stat * 1.1 end
		if statName == nature.minus then stat = stat * 0.9 end
		self.baseStats[statName] = math.floor(stat)
		self.stats[statName] = math.floor(stat)
	end
	
	-- added maxhp to this recalculation because it is now called on level up by the exp giver
	self.maxhp = math.floor(math.floor(2 * self.template.baseStats[1] + self.ivs['hp'] + math.floor(self.evs['hp'] / 4) + 100) * self.level / 100 + 10)
	if self.template.baseStats[1] == 1 then self.maxhp = 1 end -- Shedinja
	
	self.speed = self:getStat('spe')
end
function BattlePokemon.getDetails(self, side)
	if self.illusion then return self.illusion.details .. '|' .. self.getHealth(side) end
	return self.details .. '|' .. self.getHealth(side)
end
function BattlePokemon:update(init)
	-- reset for Light Metal etc
--	self.weightkg = self.template.weightkg
	-- reset for disabled moves
--	self.disabledMoves = {}
--	self.negateImmunity = {}
	self.trapped = false
	self.maybeTrapped = false
	self.trappedBy = nil -- added by tbradm
	self.maybeDisabled = false
	-- reset for ignore settings
--	self.ignore = {}
	for _, m in pairs(self.moveset) do
		if m then m.disabled = false end
	end
	if init then return end
	
	if self:runImmunity('trapped') then self.battle:runEvent('MaybeTrapPokemon', self) end
	-- Disable the faculty to cancel switches if a foe may have a trapping ability
	for _, side in pairs(self.battle.sides) do
		if side ~= self.side then
			for _, pokemon in pairs(side.active) do
				if pokemon ~= null and not pokemon.fainted then
					local template = (pokemon.illusion or pokemon).template
					if template.abilities then
						for k, ability in pairs(template.abilities) do
							if ability == pokemon.ability then
								-- This event was already run above so we don't need to run it again.
--							elseif k == 'H' and template.unreleasedHidden then
								-- unreleased hidden ability
							elseif self:runImmunity('trapped') then
								self.battle:singleEvent('FoeMaybeTrapPokemon', self.battle:getAbility(ability), {}, self, pokemon)
							end
						end
					end
				end
			end
		end
	end
	self.battle:runEvent('ModifyPokemon', self)
	
	self.speed = self:getStat('spe')
end
function BattlePokemon:calculateStat(statName, boost, modifier)
	statName = toId(statName)
	
	if statName == 'hp' then return self.maxhp end -- please just read .maxhp directly
	
	local stat = self.stats[statName]
	
	local boosts = {}
	boosts[statName] = boost
	boosts = self.battle:runEvent('ModifyBoost', self, nil, nil, boosts)
	boost = boosts[statName]
	local boostTable = {1.5, 2, 2.5, 3, 3.5, 4}
	boost = math.min(6, math.max(-6, boost))
	if boost > 0 then
		stat = math.floor(stat * boostTable[boost])
	elseif boost < 0 then
		stat = math.floor(stat / boostTable[-boost])
	end
	
	stat = self.battle:modify(stat, (modifier or 1))
	if self.battle.getStatCallback then
		stat = self.battle:getStatCallback(stat, statName, self)
	end
	return stat
end
function BattlePokemon:getStat(statName, unboosted, unmodified)
	statName = toId(statName)
	
	if statName == 'hp' then return self.maxhp end -- please just read .maxhp directly
	
	local stat = self.stats[statName]
	
	if not unboosted then
		local boosts = self.battle:runEvent('ModifyBoost', self, nil, nil, deepcopy(self.boosts))
		local boost = boosts[statName]
		local boostTable = {1.5, 2, 2.5, 3, 3.5, 4}
		boost = math.min(6, math.max(-6, boost))
		if boost > 0 then
			stat = math.floor(stat * boostTable[boost])
		elseif boost < 0 then
			stat = math.floor(stat / boostTable[-boost])
		end
	end
	
	if not unmodified then
		local statTable = {atk='Atk', def='Def', spa='SpA', spd='SpD', spe='Spe'}
		stat = self.battle:runEvent('Modify' .. statTable[statName], self, nil, nil, stat)
	end
	if self.battle.getStatCallback then
		stat = self.battle:getStatCallback(stat, statName, self, unboosted)
	end
	return stat
end
function BattlePokemon:getWeight()
	local weight = self.battle:runEvent('ModifyWeight', self, nil, nil, self.template.weightkg)
	return math.max(0.1, weight)
end
function BattlePokemon:getMoveData(move)
	move = self.battle:getMove(move)
	for _, moveData in pairs(self.moveset) do
		if moveData.id == move.id then
			return moveData
		end
	end
	return nil--null
end
function BattlePokemon:getMoveTargets(move, target)
	local targets = {}
	local t = move.target
	if t == 'all' or t == 'foeSide' or t == 'allySide' or t == 'allyTeam' then
		if string.sub(t, 1, 3) ~= 'foe' then
			for _, ally in pairs(self.side.active) do
				if ally ~= null and not ally.fainted then
					table.insert(targets, ally)
				end
			end
		end
		if string.sub(t, 1, 4) ~= 'ally' then
			for _, foe in pairs(self.side.foe.active) do
				if foe ~= null and not foe.fainted then
					table.insert(targets, foe)
				end
			end
		end
	elseif t == 'allAdjacent' or t == 'allAdjacentFoes' then
		if t == 'allAdjacent' then
			for _, ally in pairs(self.side.active) do
				if ally ~= null and self.battle:isAdjacent(self, ally) then
					table.insert(targets, ally)
				end
			end
		end
		for _, foe in pairs(self.side.foe.active) do
			if foe ~= null and self.battle:isAdjacent(self, foe) then
				table.insert(targets, foe)
			end
		end
	else
		if Not(target) or (target.fainted and target.side ~= self.side) then
			-- If a targeted foe faints, the move is retargeted
			target = self.battle:resolveTarget(self, move)
		end
		if target ~= null and #target.side.active > 1 then
			target = self.battle:runEvent('RedirectTarget', self, self, move, target)
		end
		targets = {target}
		
		-- Resolve apparent targets for Pressure.
		if move.pressureTarget then
			-- At the moment, this is the only supported target.
			if move.pressureTarget == 'foeSide' then
				for _, foe in pairs(self.side.foe.active) do
					if foe ~= null and not foe.fainted then
						table.insert(targets, foe)
					end
				end
			end
		end
	end
	return targets
end
function BattlePokemon:ignoringAbility()
	return (not self.isActive or self.volatiles['gastroacid']) and true or false
end
function BattlePokemon:ignoringItem()
	return (not self.isActive or self:hasAbility('klutz') or self.volatiles['embargo'] or self.battle.pseudoWeather['magicroom']) and true or false
end
function BattlePokemon:deductPP(move, amount, source)
	move = self.battle:getMove(move)
	local ppData = self:getMoveData(move)
	if not ppData then return false end
	ppData.used = true
	if not ppData.pp then return false end
	
	ppData.pp = math.max(0, ppData.pp - (amount or 1))
	if ppData.virtual then
		for _, foe in pairs(self.side.foe.active) do
			if foe.isStale >= 2 then
				if move.selfSwitch then
					self.isStalePPTurns = self.isStalePPTurns + 1
				end
				return true
			end
		end
	end
	self.isStalePPTurns = 0
	return true
end
function BattlePokemon:moveUsed(move)
	self.lastMove = self.battle:getMove(move).id
	self.moveThisTurn = self.lastMove
end
function BattlePokemon:gotAttacked(move, damage, source)
	if not damage then damage = 0 end
	move = self.battle:getMove(move)
	self.lastAttackedBy = {
		pokemon = source,
		damage = damage,
		move = move.id,
		thisTurn = true
	}
end
function BattlePokemon:getLockedMove()
	local lockedMove = self.battle:runEvent('LockMove', self)
	if lockedMove == true then lockedMove = false end
	return lockedMove
end
function BattlePokemon:getMoves(lockedMove, restrictData)
	if lockedMove then
		lockedMove = toId(lockedMove)
		self.trapped = true
	end
	if lockedMove == 'recharge' then
		return {{
			move = 'Recharge',
			id = 'recharge'
		}}
	end
	local moves = {}
	local hasValidMove = false
	for i, move in pairs(self.moveset) do
		if lockedMove then
			if lockedMove == move.id then
				return {{
					move = move.move,
					id = move.id
				}}
			end
		else
			if (self.disabledMoves[move.id] and (not restrictData or not self.disabledMoves[move.id].isHidden)) or move.pp <= 0 then
				move.disabled = (not restrictData and self.disabledMoves[move.id] and self.disabledMoves[move.id].isHidden) and 'hidden' or true
			elseif not move.disabled or move.disabled == 'hidden' and restrictData then
				hasValidMove = true
			end
--			local moveName = move.move
--			if move.id == 'hiddenpower' then
--				moveName = 'Hidden Power ' .. self.hpType
--			end
			table.insert(moves, {
				move = move.move,--moveName,
				id = move.id,
				pp = move.pp,
				maxpp = move.maxpp,
				target = move.target,
				disabled = move.disabled
			})
		end
	end
	if lockedMove then
		return {{
			move = self.battle:getMove(lockedMove).name,
			id = lockedMove
		}}
	end
	if hasValidMove then return moves end
	return {}
end
function BattlePokemon:getRequestData() -- for pokemon in request.active (for request.side, see BattleSide:getData())
	local lockedMove = self:getLockedMove()
	
	-- Information should be restricted for the last active Pok�mon
	local isLastActive = self:isLastActive()
	local moves = self:getMoves(lockedMove, isLastActive)
	local data = {moves = #moves>0 and moves or {{move = 'Struggle', id = 'struggle'}}}
	for _, m in pairs(data.moves) do
		m.type = self.battle:getMove(m.id).baseType
	end
	data.icon = self.template.icon
	data.index = self.index
	if self.isEgg then data.isEgg = true end
	data.fainted = self.fainted
	if self.teamn then data.teamn = self.teamn end
	if self.canMegaEvo then data.canMegaEvo = true end
	if self.canZMove then data.canZMove = self.canZMove end 
	if isLastActive then
		if self.maybeDisabled then
			data.maybeDisabled = true
		end
		if self.trapped == true then -- exclude "hidden" traps
			data.trapped = true
		elseif self.maybeTrapped then
			data.maybeTrapped = true
		end
	else
		if self.trapped then
			data.trapped = true
		end
	end
	return data
end
function BattlePokemon:isLastActive()
	if not self.isActive then return false end
	
	local allyActive = self.side.active
	for i = self.position + 1, #allyActive do
		if allyActive[i] ~= null and not allyActive[i].fainted then return false end
	end
	return true
end
function BattlePokemon:positiveBoosts()
	local boosts = 0
	for _, b in pairs(self.boosts) do
		if b > 0 then boosts = boosts + b end
	end
	return boosts
end
function BattlePokemon:boostBy(boost)
	local changed = false
	for i, b in pairs(boost) do
		local before = self.boosts[i]
		self.boosts[i] = math.min(6, math.max(-6, self.boosts[i] + b))
		if self.boosts[i] ~= before then changed = true end
	end
	self:update()
	return changed
end
function BattlePokemon:clearBoosts()
	for i in pairs(self.boosts) do
		self.boosts[i] = 0
	end
	self:update()
end
function BattlePokemon:setBoost(boost)
	for i, b in pairs(boost) do
		self.boosts[i] = b
	end
	self:update()
end
function BattlePokemon:copyVolatileFrom(pokemon)
	self:clearVolatile()
	self.boosts = pokemon.boosts
	for i, v in pairs(pokemon.volatiles) do
		if not self.battle:getEffect(i).noCopy then
			self.volatiles[i] = shallowcopy(v)
			if self.volatiles[i].linkedPokemon then
				v["linkedPokemon"] = nil
				v["linkedStatus"] = nil
				self.volatiles[i].linkedPokemon.volatiles[self.volatiles[i].linkedStatus].linkedPokemon = self
			end
		end
	end
	pokemon:clearVolatile()
	self:update()
	for i, v in pairs(self.volatiles) do
		self.battle:singleEvent('Copy', self:getVolatile(i), v, self)
	end
end
function BattlePokemon:transformInto(pokemon, user, effect)
	local template = pokemon.template
	if pokemon.fainted or pokemon.illusion or pokemon.volatiles['substitute'] then return false end
	if not template.abilities or (pokemon and pokemon.transformed) or (user and user.transformed) then return false end
	if not self:formeChange(template, true) then return false end
	self.transformed = true
	self.typesData = {}
	for i, t in pairs(pokemon.typesData) do
		table.insert(self.typesData, { type = t.type, suppressed = false, isAdded = t.isAdded })
	end
	for statName in pairs(self.stats) do
		self.stats[statName] = pokemon.stats[statName]
	end
	self.moveset = {}
	self.moves = {}
	
	for i, moveData in pairs(pokemon.moveset) do
--		local move = self.battle:getMove(self.set.moves[i])
		local moveName = moveData.move
		if moveData.id == 'hiddenpower' then
			moveName = 'Hidden Power ' .. self.hpType
		end
		table.insert(self.moveset, {
			move = moveName,
			id = moveData.id,
			pp = moveData.maxpp==1 and 1 or 5,
			maxpp = moveData.maxpp==1 and 1 or 5,
			target = moveData.target,
			disabled = false,
			used = false,
			virtual = true
		})
		table.insert(self.moves, toId(moveName))
	end
	for i, b in pairs(pokemon.boosts) do
		self.boosts[i] = b;
	end
	if effect then
		self.battle:add('-transform', self, pokemon, '[from] ' .. effect)
	else
		self.battle:add('-transform', self, pokemon)
	end
	self:setAbility(pokemon.ability)
	self:update()
	return true
end
function BattlePokemon:formeChange(template, dontRecalculateStats)
	template = self.battle:getTemplate(template)

	if not template.abilities then return false end
	self.illusion = nil
	self.template = template
	self.types = {}
	for i, t in pairs(template.types) do
		self.types[i] = self.battle.data.TypeFromInt[t]
	end
	self.typesData = {}
	for i = 1, #self.types do
		table.insert(self.typesData, { type = self.types[i], suppressed = false, isAdded = false })
	end
	local nature = self.battle:getNature(self.set.nature)
	if not dontRecalculateStats then
		for statName in pairs(self.stats) do
			local statIndex = ({hp=1,atk=2,def=3,spa=4,spd=5,spe=6})[statName]
			local stat = self.template.baseStats[statIndex]
			stat = math.floor(math.floor(2 * stat + self.ivs[statName] + math.floor(self.evs[statName] / 4)) * self.level / 100 + 5)
			-- nature
			if statName == nature.plus then stat = stat * 1.1
			elseif statName == nature.minus then stat = stat * 0.9 end
			self.baseStats[statName] = math.floor(stat)
			self.stats[statName] = math.floor(stat)
		end
		self.speed = self.stats.spe
	end
	return true
end
function BattlePokemon:clearVolatile(init)
	self.boosts = {
		atk = 0,
		def = 0,
		spa = 0,
		spd = 0,
		spe = 0,
		accuracy = 0,
		evasion = 0
	}
	
	self.moveset = {}
	self.moves = {}
	for i, bm in pairs(self.baseMoveset) do
		self.moveset[i] = bm
		self.moves[i] = toId(bm.move)
	end
	
	self.transformed = false
	self.ability = self.baseAbility
	self.ivs = deepcopy(self.baseIvs)
	self.hpType = self.baseHpType
	for i in pairs(self.volatiles) do
		if self.volatiles[i].linkedStatus then
			self.volatiles[i].linkedPokemon:removeVolatile(self.volatiles[i].linkedStatus)
		end
	end
	self.volatiles = {}
	self.switchFlag = false
	
	self.lastMove = ''
	self.moveThisTurn = ''
	
	self.lastDamage = 0
	self.lastAttackedBy = nil
	self.newlySwitched = true
	self.beingCalledBack = false
	
	self:formeChange(self.baseTemplate)
	
	self:update(init)
end
function BattlePokemon:hasType(...)
	local args = {...}
	if #args == 0 then return false end
	if #args == 1 and type(args[1]) == "table" then -- old format; idealy should change these calls to tuples
		args = args[1]
	end
	for _, ty in pairs(args) do
		for _, myType in pairs(self:getTypes()) do
			if myType == ty then
				return true
			end
		end
	end
	return false
end
-- returns the amount of damage actually dealt
function BattlePokemon:faint(source, effect)
	-- This function only puts the pokemon in the faint queue; actual setting of self.fainted comes later when the faint queue is resolved.
	if self.fainted or self.faintQueued then return 0 end
	local d = self.hp
	self.hp = 0
	self.switchFlag = false
	self.faintQueued = true
	table.insert(self.battle.faintQueue, { target = self, source = source, effect = effect })
	self.battle:queueExp(self, self.participatingFoes)
	if self.battle.battleType < 2 and self.side.n == 1 then
		local playerPokemon = self:getPlayerPokemon()
		if playerPokemon then
			playerPokemon:addHappiness(-1)
		end
	end
	return d
end
function BattlePokemon:damage(d, source, effect)
	if self.hp <= 0 then return 0 end
	if d < 1 and d > 0 then d = 1 end
	d = math.floor(d)
--	if isNaN(d) then return 0 end
	if d <= 0 then return 0 end
	self.hp = self.hp - d
	if self.hp <= 0 then
		d = d + self.hp
		self:faint(source, effect)
	end
	return d
end
function BattlePokemon:tryTrap(isHidden, source, effectName)
	if self:runImmunity('trapped') then
		if self.trapped and isHidden then return true end
		self.trapped = isHidden and 'hidden' or true
--		require(game.ServerStorage.Utilities).print_r(self.battle.event, 3)
		self.trappedBy = {
			source = source,
			effectName = effectName
		}
		return true
	end
	return false
end
function BattlePokemon:hasMove(moveid)
	moveid = toId(moveid)
	if moveid:sub(1, 11) == 'hiddenpower' then moveid = 'hiddenpower' end
	for _, move in pairs(self.moveset) do
		if moveid == self.battle:getMove(move.move).id then
			return moveid
		end
	end
	return false
end
--[[function BattlePokemon:getValidMoves(lockedMove)
	local pMoves = self:getMoves(lockedMove)
	local moves = {}
	for i = 1, #pMoves do
		if not pMoves[i].disabled then
			table.insert(moves, pMoves[i].id)
		end
	end
	if #moves > 0 then return moves end
	return {'struggle'}
end--]]
function BattlePokemon:disableMove(moveid, isHidden, sourceEffect)
	if not sourceEffect and self.battle.event then
		sourceEffect = self.battle.effect
	end
	moveid = toId(moveid)
	if string.sub(moveid, 1, 11) == 'hiddenpower' then
		moveid = 'hiddenpower'
	end
	
	if self.disabledMoves[moveid] and not self.disabledMoves[moveid].isHidden then return end
	self.disabledMoves[moveid] = {
		isHidden = isHidden and true or false,
		sourceEffect = sourceEffect
	}
end
-- returns the amount of hp actually healed
function BattlePokemon:heal(d)
	if self.hp <= 0 then return false end
	d = math.floor(d)
--	if isNaN(d) then return false end
	if d <= 0 then return false end
	if self.hp >= self.maxhp then return false end
	self.hp = self.hp + d
	if self.hp > self.maxhp then
		d = d - (self.hp - self.maxhp)
		self.hp = self.maxhp
	end
	return d
end
-- sets HP, returns delta
function BattlePokemon:sethp(d)
	if self.hp <= 0 then return 0 end
	d = math.floor(d)
--	if isNaN(d) then return end
	if d < 1 then d = 1 end
	d = d - self.hp
	self.hp = self.hp + d
	if self.hp > self.maxhp then
		d = d - (self.hp - self.maxhp)
		self.hp = self.maxhp
	end
	return d
end
function BattlePokemon:trySetStatus(status, source, sourceEffect)
	if self.hp <= 0 or (self.status and self.status ~= '') then return false end
	return self:setStatus(status, source, sourceEffect)
end
function BattlePokemon:cureStatus()
	if self.hp <= 0 then return false end
	-- unlike clearStatus, gives cure message
	if self.status and self.status ~= '' then
		self.battle:add('-curestatus', self, self.status)
		self:setStatus('')
	end
end
function BattlePokemon:setStatus(status, source, sourceEffect, ignoreImmunities)
	if self.hp <= 0 then return false end
	status = self.battle:getEffect(status)
	if self.battle.event then
		if not source then source = self.battle.event.source end
		if not sourceEffect then sourceEffect = self.battle.effect end
	end
	
	if not ignoreImmunities and status.id then
		-- the game currently never ignores immunities
		if not self:runImmunity(status.id == 'tox' and 'psn' or status.id) then
			self.battle:debug('immune to status')
			return false
		end
	end
	
	if self.status == status.id then return false end
	local prevStatus = self.status
	local prevStatusData = self.statusData
	if status.id and Not(self.battle:runEvent('SetStatus', self, source, sourceEffect, status)) then
		self.battle:debug('set status [' .. status.id .. '] interrupted')
		return false
	end
	
	self.status = status.id
	self.statusData = {id = status.id, target = self}
	if source then self.statusData.source = source end
	if status.duration then
		self.statusData.duration = status.duration
	end
	if status.durationCallback then
		self.statusData.duration = self.battle:call(status.durationCallback, self, source, sourceEffect)
	end
	
	if status.id and Not(self.battle:singleEvent('Start', status, self.statusData, self, source, sourceEffect)) then
		self.battle:debug('status start [' .. status.id .. '] interrupted')
		-- cancel the setstatus
		self.status = prevStatus
		self.statusData = prevStatusData
		return false
	end
	self:update()
	if status.id and Not(self.battle:runEvent('AfterSetStatus', self, source, sourceEffect, status)) then
		return false
	end
	return true
end
function BattlePokemon:clearStatus()
	-- unlike cureStatus, does not give cure message
	return self:setStatus('')
end
function BattlePokemon:getStatus()
	return self.battle:getEffect(self.status)
end
function BattlePokemon:eatItem(item, source, sourceEffect)
	if self.hp <= 0 or not self.isActive or Not(self.item) then return false end
	
--	local id = toId(item)
--	if id and self.item ~= id then return false end
	
	if not sourceEffect and self.battle.effect then sourceEffect = self.battle.effect end
	if not source and self.battle.event and self.battle.event.target then source = self.battle.event.target end
	item = self:getItem()
	if not Not(self.battle:runEvent('UseItem', self, nil, nil, item)) and not Not(self.battle:runEvent('EatItem', self, nil, nil, item)) then
		self.battle:add('-enditem', self, item, '[eat]')
		
		self.battle:singleEvent('Eat', item, self.itemData, self, source, sourceEffect)
		
		self.lastItem = self.item
		self.item = ''
		self.itemData = {id = '', target = self}
		self.usedItemThisTurn = true
		self.ateBerry = true
		self.battle:runEvent('AfterUseItem', self, nil, nil, item)
		return true
	end
	return false
end
function BattlePokemon:useItem(item, source, sourceEffect)
	if not self.isActive or Not(self.item) then return false end
	
	local id = toId(item)
	if item and id and self.item ~= id then return false end
	
	if not sourceEffect and self.battle.effect then sourceEffect = self.battle.effect end
	if not source and self.battle.event and self.battle.event.target then source = self.battle.event.target end
	item = self:getItem()
	if not Not(self.battle:runEvent('UseItem', self, nil, nil, item)) then
		if item.id == 'redcard' then
			self.battle:add('-enditem', self, item, '[of] ' .. source)
		elseif not item.isGem then
			self.battle:add('-enditem', self, item)
		end
		
		self.battle:singleEvent('Use', item, self.itemData, self, source, sourceEffect)
		
		self.lastItem = self.item
		self.item = ''
		self.itemData = {id = '', target = self}
		self.usedItemThisTurn = true
		self.battle:runEvent('AfterUseItem', self, nil, nil, item)
		return true
	end
	return false
end
function BattlePokemon:takeItem(source)
	if not self.isActive or not self.item then return false end
	if not source then source = self end
	local item = self:getItem()
	if not Not(self.battle:runEvent('TakeItem', self, source, nil, item)) then
--		self.lastItem = ''
		self.item = ''
		self.itemData = {id = '', target = self}
		return item
	end
	return false
end
function BattlePokemon:setItem(item, source, effect)
	if self.hp <= 0 or not self.isActive then return false end
	item = self.battle:getItem(item)
	if item.id == 'leppaberry' then
		self.isStale = 2
		self.isStaleSource = 'getleppa'
	end
	self.lastItem = self.item
	self.item = item.id
	self.itemData = {id = item.id, target = self}
	if item.id then
		self.battle:singleEvent('Start', item, self.itemData, self, source, effect)
	end
	if self.lastItem then self.usedItemThisTurn = true end
	return true
end
function BattlePokemon:getItem()
	return self.battle:getItem(self.item)
end
function BattlePokemon:hasItem(...)
	if self:ignoringItem() then return false end
	local ownItem = self.item
	local args = {...}
	if #args == 1 and type(args[1]) == "table" then -- old format; idealy should change these calls to tuples
		args = args[1]
	end
	for _, it in pairs(args) do
		if ownItem == toId(it) then
			return true
		end
	end
	return false
end
function BattlePokemon:clearItem()
	return self:setItem('')
end
function BattlePokemon:setAbility(ability, source, effect, noForce)
	if self.hp <= 0 then return false end
	ability = self.battle:getAbility(ability)
	local oldAbility = self.ability
	if noForce and oldAbility == ability.id then return false end
	if ({illusion=true, multitype=true, stancechange=true})[ability.id] then return false end
	if oldAbility == 'multitype' or oldAbility == 'stancechange' then return false end
	self.battle:singleEvent('End', self.battle:getAbility(oldAbility), self.abilityData, self, source, effect)
	self.ability = ability.id
	self.abilityData = {id = ability.id, target = self}
	if ability.id then
		self.battle:singleEvent('Start', ability, self.abilityData, self, source, effect)
	end
	return oldAbility
end
function BattlePokemon:getAbility()
	return self.battle:getAbility(self.ability)
end
function BattlePokemon:hasAbility(...)
	if self:ignoringAbility() then return false end
	local ownAbility = self.ability
	local args = {...}
	if #args == 1 and type(args[1]) == "table" then -- old format; idealy should change these calls to tuples
		args = args[1]
	end
	for _, ab in pairs(args) do
		if ownAbility == toId(ab) then
			return true
		end
	end
	return false
end
function BattlePokemon:clearAbility()
	return self:setAbility('')
end
function BattlePokemon:getNature()
	return self.battle:getNature(self.set.nature)
end
function BattlePokemon:addVolatile(status, source, sourceEffect, linkedStatus)
	local result
	status = self.battle:getEffect(status)
	if self.hp <= 0 and not status.affectsFainted then return false end
	if self.battle.event then
		if not source then source = self.battle.event.source end
		if not sourceEffect then sourceEffect = self.battle.effect end
	end
	
	if self.volatiles[status.id] then
		if not status.onRestart then return false end
		return self.battle:singleEvent('Restart', status, self.volatiles[status.id], self, source, sourceEffect)
	end
	if not self:runImmunity(status.id) then return false end
	result = self.battle:runEvent('TryAddVolatile', self, source, sourceEffect, status)
	if Not(result) then
		self.battle:debug('add volatile [' .. status.id .. '] interrupted')
		return result
	end
	local volatile = {id = status.id, target = self}
	self.volatiles[status.id] = volatile
	if source then
		volatile.source = source
		volatile.sourcePosition = source.position
	end
	if sourceEffect then
		volatile.sourceEffect = sourceEffect
	end
	if status.duration then
		volatile.duration = status.duration
	end
	if status.durationCallback then
		volatile.duration = self.battle:call(status.durationCallback, self, source, sourceEffect)
	end
	result = self.battle:singleEvent('Start', status, volatile, self, source, sourceEffect)
	if Not(result) then
		-- cancel
		self.volatiles[status.id] = nil
		return result
	end
	if linkedStatus and source and not source.volatiles[linkedStatus] then
		source:addVolatile(linkedStatus, self, sourceEffect, status.id)
		source.volatiles[linkedStatus].linkedPokemon = self
		source.volatiles[linkedStatus].linkedStatus = status.id
		self.volatiles[status.id].linkedPokemon = source
		self.volatiles[status.id].linkedStatus = linkedStatus
	end
	self:update()
	return true
end
function BattlePokemon:getVolatile(status)
	status = self.battle:getEffect(status)
	if not self.volatiles[status.id] then return nil end--null end
	return status
end
function BattlePokemon:removeVolatile(status)
	if self.hp <= 0 then return false end
	status = self.battle:getEffect(status)
	if not self.volatiles[status.id] then return false end
	self.battle:singleEvent('End', status, self.volatiles[status.id], self)
	local linkedPokemon = self.volatiles[status.id].linkedPokemon
	local linkedStatus = self.volatiles[status.id].linkedStatus
	self.volatiles[status.id] = nil
	if linkedPokemon and linkedPokemon.volatiles[linkedStatus] then
		linkedPokemon:removeVolatile(linkedStatus)
	end
	self:update()
	return true
end
function BattlePokemon.getHealth(self, side)
--	if self.hp <= 0 then return '0 fnt' end
	local hpstring
--	if side == true or self.side == side or self.battle:getFormat().debug or self.battle.reportExactHP then
		hpstring = self.hp .. '/' .. self.maxhp
	if side == true or self.side == side and self.battle.battleType < 2 then
		local expProg = self.expProg -- cached value
		if not expProg then
			local pokemon = self:getPlayerPokemon()
			if pokemon then
				local xpProg = 0
				if pokemon.level < 100 then
					local cl = pokemon:getRequiredExperienceForLevel(pokemon.level)
					local nl = pokemon:getRequiredExperienceForLevel(pokemon.level+1)
					expProg = (pokemon.experience-cl) / (nl-cl)
					self.expProg = expProg -- needs to be uncached/replaced when pokemon gains exp
				end
			end
		end
		if expProg then
			hpstring = string.format('%s;%.4f', hpstring, expProg)
		end
	end
--[[	end else {
		local ratio = self.hp / self.maxhp;
		if self.battle.reportPercentages) {
			-- HP Percentage Mod mechanics
			local percentage = Math.ceil(ratio * 100);
			if (percentage == 100) and (ratio < 1.0)) {
				percentage = 99;
			end
			hpstring = '' + percentage + '/100';
		end else {
			-- In-game accurate pixel health mechanics
			local pixels = Math.floor(ratio * 48) or 1;
			hpstring = '' + pixels + '/48';
			if (pixels == 9) and (ratio > 0.2)) {
				hpstring += 'y'; -- force yellow HP bar
			end else if (pixels == 24) and (ratio > 0.5)) {
				hpstring += 'g'; -- force green HP bar
			end
		end
	end
	if self.status) hpstring += ' ' + self.status;--]]
	return hpstring
end
function BattlePokemon:setType(newType, enforce)
	-- Arceus first type cannot be normally changed
	if not enforce and self.template.num == 493 then return false end
	
	self.typesData = {{ type = newType, suppressed = false, isAdded = false }}
	return true
end
function BattlePokemon:addType(newType)
	-- removes any types added previously and adds another one
	for i = #self.typesData, 1, -1 do
		if self.typesData[i].isAdded then
			table.remove(self.typesData, i)
		end
	end
	table.insert(self.typesData, { type = newType, suppressed = false, isAdded = true })
	return true
end
function BattlePokemon:getTypes(getAll)
	local types = {}
	for _, td in pairs(self.typesData) do
		if getAll or not td.suppressed then
			table.insert(types, td.type)
		end
	end
	if #types > 0 then return types end
	return {'Normal'}
end
function BattlePokemon:isGrounded()
	if not self:hasType('Flying') and not Not(self.battle:runEvent('Immunity', self, nil, nil, 'Ground')) then return true end
	return (self:hasItem('ironball') or self.volatiles['ingrain'] or self.volatiles['smackdown'] or self.battle:getPseudoWeather('gravity')) and true or false
end
function BattlePokemon:isSemiInvulnerable()
	if self.volatiles['fly'] or self.volatiles['bounce'] or self.volatiles['skydrop'] or self.volatiles['dive'] or self.volatiles['dig'] or self.volatiles['phantomforce'] or self.volatiles['shadowforce'] then
		return true
	end
	for _, foe in pairs(self.side.foe.active) do
		if foe ~= null and foe.volatiles['skydrop'] and foe.volatiles['skydrop'].source == self then
			return true
		end
	end
	return false
end
function BattlePokemon:runEffectiveness(move)
	local totalTypeMult = 1
	for _, t in pairs(self:getTypes()) do
		local typeMult = self.battle:getEffectiveness(move, t)
		typeMult = self.battle:singleEvent('Effectiveness', move, nil, t, move, nil, typeMult)
		totalTypeMult = totalTypeMult * self.battle:runEvent('Effectiveness', self, t, move, typeMult)
	end
	return totalTypeMult
end
function BattlePokemon:runImmunity(type, message)
	if self.fainted then
		return false
	end
	if not type or type == '???' then
		return true
	end
	if Not(self.battle:runEvent('NegateImmunity', self, type)) then return true end
	if not self.battle:getImmunity(type, self) then
--		self.battle:debug('natural immunity')
		if message then
			self.battle:add('-immune', self, '[msg]')
		end
		return false
	end
	local immunity = self.battle:runEvent('Immunity', self, nil, nil, type)
	if not immunity then
		self.battle:debug('artificial immunity')
		if message and immunity ~= nil then
			self.battle:add('-immune', self, '[msg]')
		end
		return false
	end
	return true
end
function BattlePokemon:remove()
	-- deallocate ourself
	-- get rid of circular references
	self.battle = nil
	self.side = nil
	self.illusion = nil
	self.participatingFoes = nil
	
	self.volatiles = nil
	
	self.template = nil
	self.baseTemplate = nil
end



return BattlePokemon