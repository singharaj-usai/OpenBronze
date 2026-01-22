print("BattleS")
local undefined, null, class, jsonEncode; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	undefined = util.undefined
	null = util.null
	class = util.class
	jsonEncode = util.jsonEncode
end

local weightedRandom = require(script.Parent.Parent).Utilities.weightedRandom

local BattlePokemon = require(script.Parent.BattlePokemon)



local BattleSide = class({
	className = 'BattleSide',
	
	isActive = false,
	pokemonLeft = 0,
	faintedLastTurn = false,
	faintedThisTurn = false,
	currentRequest = '',
--	decision = nil,
--	foe = nil,
--	megaAdornment = nil,
	
}, function(self, name, battle, n, team, megaAdornment)
	self.battle = battle
	self.n = n
	self.name = name
	self.megaAdornment = megaAdornment
	self.pokemon = {}
	self.active = {null}
	self.sideConditions = {}
	
	self.id = 'p'..n
	
	if battle.gameType == 'doubles' then
		self.active = {null, null}
	elseif battle.gameType == 'triples' or battle.gameType == 'rotation' then
		self.active = {null, null, null}
	end
	
--	self.team = team
	local pl = 0
	for i = 1, math.min(#team, 6) do
		local p = BattlePokemon:new(nil, team[i], self)
		if not p.index then
			p.index = i
		end
		table.insert(self.pokemon, p)
		p.fainted = p.hp == 0
		if p.hp > 0 then
			pl = pl + 1
		end
	end
	self.pokemonLeft = pl--#self.pokemon
	for i = 1, #self.pokemon do
		self.pokemon[i].position = i
	end
	
	return self
end)

function BattleSide:toString()
	return self.id .. ': ' .. self.name
end
function BattleSide:start()
	local pos = 1
	for i, p in pairs(self.pokemon) do
		if p.hp > 0 then
			self.battle:switchIn(p, pos)
			pos = pos + 1
			if pos > #self.active then break end
		end
	end
end
function BattleSide:getData(context) -- for pokemon in request.side (for request.active, see BattlePokemon:getRequestData())
	local data = {
--		name = self.name,
		id = self.id,
		nActive = #self.active,
--		pokemon = {}
	}
	if context == 'switch' then
		local h = {}
		data.healthy = h
		for i, pokemon in pairs(self.pokemon) do
			h[i] = not pokemon.egg and pokemon.hp > 0
--			local pp = {}
--			for i, m in pairs(pokemon.moveset) do
--				pp[i] = m.pp
--			end
--			table.insert(data.pokemon, {
--				ident = pokemon.fullname,
--				level = pokemon.level,
--				status = pokemon.status,
--				hp = pokemon.hp,
--				maxhp = pokemon.maxhp,
--				active = (pokemon.position <= #self.active),
--				moves = pokemon.moves,
--				pp = pp,
--				item = pokemon.item,
--				pokeball = pokemon.pokeball,
--				index = pokemon.index,
--				isEgg = pokemon.isEgg,
--			})
		end
	end
	return data
end
function BattleSide:getRelevantDataChanges() -- for post-battle updates
	local data = {
		pokemon = {}
	}
	if self.battle.pvp then return data end
	for i, pokemon in pairs(self.pokemon) do
		local d = {
			hp = pokemon.hp,
			status = pokemon.status,
			moves = {},
			index = pokemon.index,
			evs = {pokemon.evs.hp, pokemon.evs.atk, pokemon.evs.def, pokemon.evs.spa, pokemon.evs.spd, pokemon.evs.spe},
		}
		if pokemon.statusData and pokemon.statusData.time then
			if pokemon.statusData.time <= 0 then
				d.status = nil
			else
				d.status = d.status .. math.min(3, pokemon.statusData.time)
			end
		end
		for i, move in pairs(pokemon.moveset) do
			d.moves[i] = {
				id = move.move,
				pp = move.pp,
			}
		end
		table.insert(data.pokemon, d)
	end
	return data
end
function BattleSide:canSwitch()
	for _, pokemon in pairs(self.pokemon) do
		if not pokemon.isActive and not pokemon.fainted then
			return true
		end
	end
	return false
end
function BattleSide:randomActive()
	local actives = {}
	for _, p in pairs(self.active) do
		if p ~= null and not p.fainted then
			table.insert(actives, p)
		end
	end
	if #actives == 0 then return null end
	return actives[math.random(#actives)]
end
function BattleSide:addSideCondition(status, source, sourceEffect)
	status = self.battle:getEffect(status)
	if self.sideConditions[status.id] then
		if not status.onRestart then return false end
		return self.battle:singleEvent('Restart', status, self.sideConditions[status.id], self, source, sourceEffect)
	end
	self.sideConditions[status.id] = {id = status.id, target = self}
	if source then
		self.sideConditions[status.id].source = source
		self.sideConditions[status.id].sourcePosition = source.position
	end
	if status.duration then
		self.sideConditions[status.id].duration = status.duration
	end
	if status.durationCallback then
		self.sideConditions[status.id].duration = self.battle:call(status.durationCallback, self, source, sourceEffect)
	end
	if not self.battle:singleEvent('Start', status, self.sideConditions[status.id], self, source, sourceEffect) then
		self.sideConditions[status.id] = nil
		return false
	end
	self.battle:update()
	return true
end
function BattleSide:getSideCondition(status)
	status = self.battle:getEffect(status)
	if not self.sideConditions[status.id] then return null end
	return status
end
function BattleSide:removeSideCondition(status)
	status = self.battle:getEffect(status)
	if not self.sideConditions[status.id] then return false end
	self.battle:singleEvent('End', status, self.sideConditions[status.id], self)
	self.sideConditions[status.id] = nil
	self.battle:update()
	return true
end
function BattleSide:send(...)
	local sideUpdate = {...}
	for i, su in pairs(sideUpdate) do
		if type(su) == 'function' then
			sideUpdate[i] = su(self)
		end
	end
	self.battle:send('sideupdate', self.id, unpack(sideUpdate))
end
function BattleSide:emitCallback(...)
	-- todo: what about when an npc trainer receives this request
	if self.name == '#Wild' then
--		require(game.ReplicatedStorage.Utilities).print_r({...})
		return
	end
	self.battle:sendToPlayer(self.id, 'callback', self.id, ...)
end
function BattleSide:AIChooseMove(request)
	if request.requestType ~= 'move' then
		self.battle:debug('non-move request sent to AI foe side')
		return
	end
	local choices = {}
	for n, a in pairs(request.active) do
		-- get valid moves
		local enabledMoves = {}
		for i, m in pairs(a.moves) do
			if not m.disabled and (not m.pp or m.pp > 0) then
				table.insert(enabledMoves, i)
			end
		end
		-- always Mega-evolve if available
		local mega = ''
		if a.canMegaEvo then
			mega = ' mega'
		end
		local zmove = ''
		if a.canZMove then 
			mega = ' zmov'
		end
		-- if npc trainer, then try to use some logic to decide move
		local move
		if self.name ~= '#Wild' then
			local s, r = pcall(function()
				local battle = self.battle
				local pokemon = self.active[n]
				-- for now, assume target is always slot 1 (THIS COULD HILARIOUSLY AFFECT DOUBLES W/ JAKE/TESS)
				local target = self.foe.active[1]
				if target == null then target = self.foe.active[2] end
				if target == null then target = self.foe.active[3] end
				if target == null then target = nil end
				-- check for a manually designed strategy
				if pokemon.aiStrategy then
					local trymovenamed = pokemon.aiStrategy(battle, self, pokemon, target)
					if trymovenamed then
						for _, m in pairs(enabledMoves) do
							if pokemon.moves[m] == trymovenamed then
--								print('ai strategy successful')
								move = m
								break
							end
						end
					end
				end
				-- special Shedinja logic
				if not move and target.ability == 'wonderguard' then
					local superEffectiveMoves = {}
					local nonDamageMoves = {}
					for _, m in pairs(enabledMoves) do
						local moveId = pokemon.moves[m]
						local moveData = battle:getMove(moveId)
						if moveData.baseDamage > 0 then
							local effectiveness = 1
							for _, t in pairs(target:getTypes()) do
								effectiveness = effectiveness * (battle.data.TypeChart[t][moveData.type] or 1)
							end
							if effectiveness > 1 then
								table.insert(superEffectiveMoves, m)
							end
						else
							table.insert(nonDamageMoves, m)
						end
					end
					if #superEffectiveMoves > 0 then
						move = superEffectiveMoves[math.random(#superEffectiveMoves)]
					else
						-- TODO: switch to something that can defeat Shedinja
						move = nonDamageMoves[math.random(#nonDamageMoves)]
					end
				end
				--
				if not move then
					local chance = {0, 0, 0, 0}
					for _, m in pairs(enabledMoves) do
						chance[m] = 1
					end
					local difficulty = self.difficulty or 1
--					print('difficulty', difficulty)
					local d_alpha = math.max(0, math.min(1, difficulty/4))
					local estDamage = {0, 0, 0, 0}
					for _, m in pairs(enabledMoves) do
						local moveId = pokemon.moves[m]
						local moveData = battle:getMove(moveId)
						-- don't heal if it won't help (excludes absorb etc. that still deal damage)
						if moveData.flags.heal and (not moveData.basePower or moveData.basePower < 1) and pokemon.hp == pokemon.maxhp then
							chance[m] = 0
						-- don't bother setting weather if it's already set
						elseif moveData.weather and battle:isWeather(moveData.weather) then
							chance[m] = 0
						end
						-- avoid known fail states
						if moveId == 'helpinghand' and #self.active < 2 then
							chance[m] = 0
						end
						-- status logic
						if moveData.status and target.status ~= '' then
							chance[m] = target.status=='slp' and .25 or 0
						elseif moveData.status == 'slp' then
							chance[m] = 1 + .01*((tonumber(moveData.accuracy) or 100)-30)
						end
						if moveId == 'spore' and target:hasType('Grass') then
							chance = 0
						end
						-- estimate damage dealt by this move
						local effectiveBaseDamage = moveData.baseDamage or 0
						if effectiveBaseDamage > 0 then
							-- SPECIFICS (for gym leaders, etc)
							if pokemon.ability == 'technician' and effectiveBaseDamage <= 60 then
								effectiveBaseDamage = effectiveBaseDamage * 1.5
							end
							if moveId == 'venoshock' and (target.status == 'psn' or target.status == 'tox') then
								effectiveBaseDamage = effectiveBaseDamage * 2
							end
							-- END SPECIFICS
							-- consider charging moves as being half as powerful
							if moveData.flags.charge and pokemon.item ~= 'powerherb' and not (moveId == 'solarbeam' and battle:isWeather({'sunnyday', 'desolateland'})) then
								effectiveBaseDamage = effectiveBaseDamage / 2
							-- same with recharging moves (unless it's the opponent's last pokemon)
							elseif moveData.flags.recharge and self.foe.pokemonLeft > 1 then
								effectiveBaseDamage = effectiveBaseDamage / 2
							end
							-- factor in move's accuracy
							if type(moveData.accuracy) == 'number' then
								effectiveBaseDamage = effectiveBaseDamage * 100 / moveData.accuracy
							end
							-- factor in crit chance
							if moveData.willCrit then
								effectiveBaseDamage = effectiveBaseDamage * 1.5
							elseif moveData.critRatio and moveData.critRatio > 1 then
								effectiveBaseDamage = effectiveBaseDamage * (1.5 / (({16, 8, 2, 1})[math.min(4, moveData.critRatio)]))
							end
							-- factor in STAB
							if pokemon:hasType(moveData.type) then
								effectiveBaseDamage = effectiveBaseDamage * (moveData.stab or 1.5)
							end
							
							if target then
								local minDamage, maxDamage
								if moveData.damage == 'level' then
									minDamage, maxDamage = pokemon.level, pokemon.level
								elseif moveData.damage then
									minDamage, maxDamage = moveData.damage, moveData.damage
								else
									local category = battle:getCategory(moveData)
									local defensiveCategory = moveData.defensiveCategory or category
									
									local level = pokemon.level
									
									local attackStat = (category == 'Physical') and 'atk' or 'spa'
									local defenseStat = (defensiveCategory == 'Physical') and 'def' or 'spd'
									local statTable = {atk='Atk', def='Def', spa='SpA', spd='SpD', spe='Spe'}
									local attack, defense
									
									local atkBoosts = moveData.useTargetOffensive and target.boosts[attackStat]   or pokemon.boosts[attackStat]
									local defBoosts = moveData.useSourceDefensive and pokemon.boosts[defenseStat] or target.boosts[defenseStat]
									if moveData.ignoreOffensive or (moveData.ignoreNegativeOffensive and atkBoosts < 0) then atkBoosts = 0 end
									if moveData.ignoreDefensive or (moveData.ignorePositiveDefensive and defBoosts > 0) then defBoosts = 0 end
									
									if moveData.useTargetOffensive then attack = target:calculateStat(attackStat, atkBoosts)
									else attack = pokemon:calculateStat(attackStat, atkBoosts) end
									
									if moveData.useSourceDefensive then defense = pokemon:calculateStat(defenseStat, defBoosts)
									else defense = target:calculateStat(defenseStat, defBoosts) end
									
									local effectiveness = 1
									for _, t in pairs(target:getTypes()) do
										effectiveness = effectiveness * (battle.data.TypeChart[t][moveData.type] or 1)
									end
									local maxDamage = math.floor(math.floor(math.floor(2 * level / 5 + 2) * effectiveBaseDamage * attack / defense) / 50) + 2
									maxDamage = math.floor(maxDamage * effectiveness)
									local minDamage = math.floor(.85 * maxDamage)
								end
								estDamage[m] = maxDamage + (minDamage-maxDamage)*d_alpha
							end
						end
					end
					-- check if there are moves that can (estimatedly) KO the opponent
					local movesThatCouldKO = {}
					local hp = target.hp
					for _, m in pairs(enabledMoves) do
						if estDamage[m] > hp then
							table.insert(movesThatCouldKO, m)
						end
					end
					if #movesThatCouldKO > 0 and math.random(4) < difficulty+1 then
						if #movesThatCouldKO > 1 then
							-- sort
							-- for now, it only bases it on what has most PP
							table.sort(movesThatCouldKO, function(a, b)
								return pokemon.moveset[a].pp > pokemon.moveset[b].pp
							end)
						end
						move = movesThatCouldKO[1]
					end
					-- set damaging moves' chances
					for _, m in pairs(enabledMoves) do
						if estDamage[m] > 0 then
							local pko = estDamage[m]/hp
							chance[m] = math.max(0, (pko-.25)*4+1)
						end
					end
					-- choose random move based on determined chance
					for _, c in pairs(chance) do
						-- make sure there is at least one value > 0
						if c > 0 then
							move = weightedRandom({1, 2, 3, 4}, function(i) return chance[i] end)
							break
						end
					end
					-- if selected move is Solar Beam AND you know Sunny Day AND it's not already sunny, USE Sunny Day!
					if pokemon.moves[move] == 'solarbeam' and not battle:isWeather({'sunnyday', 'desolateland'}) then
						for _, m in pairs(enabledMoves) do
							if pokemon.moves[m] == 'sunnyday' then
								move = m
							end
						end
					end
					-- TODO: detect when you can't damage opponent and switch pokemon
					
				end
			end)
			if not s then print('NPC Battle AI encountered error:', r) end
		end
		-- default to random move if nothing else
		if not move then
			move = enabledMoves[math.random(#enabledMoves)]
		end
		--
		choices[n] = 'move '..move..mega
	end
	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end
function BattleSide:AIForceSwitch(request)
--	require(game.ReplicatedStorage.Utilities).print_r(request)
--	for i, p in pairs(self.pokemon) do
--		if not p.isActive and p.hp > 0 then
--			self.battle:choose(nil, self.id, {'switch '..i}, self.battle.rqid)
--			return
--		end
--	end
	
	local alreadySwitched = {}
	local function getValidPokemonIndex()
		for i, p in pairs(self.pokemon) do
			if not alreadySwitched[i] and not p.isActive and p.hp > 0 then
				return i
			end
		end
	end
	
	local fs = request.forceSwitch
	local choices = {}
	for i = 1, #fs do
		if fs[i] then
			local s = getValidPokemonIndex()
			if s then
				choices[i] = 'switch '..s
				alreadySwitched[s] = true
			else
				choices[i] = 'pass'
			end
		else
			choices[i] = 'pass'
		end
	end
--	require(game.ReplicatedStorage.Utilities).print_r(choices)
	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end
function BattleSide:emitRequest(request)
	if request.forceSwitch or request.foeAboutToSendOut then
		request.requestType = 'switch'
	elseif request.teamPreview then
		request.requestType = 'team'
	elseif request.wait then
		request.requestType = 'wait'
	elseif request.active then
		request.requestType = 'move'
	end
	if (self.name == '#Wild' or self.battle.isTrainer) and self.n == 2 then
		if request.requestType == 'move' then
			self:AIChooseMove(request)
		elseif request.requestType == 'switch' then
			self:AIForceSwitch(request)
		else
			--			print('NOTICE: battle ai received request of type:', request.requestType)
		end
		return
	end

	local d = self.battle:getDataForTransferToPlayer(self.id, true)
	if d and #d > 0 then
		request.qData = d
	end
	self.battle:sendToPlayer(self.id, 'request', self.id, self.battle.rqid, request)
end
function BattleSide:resolveDecision()
	if self.decision then
--		self.battle:debug('decision resolved previously: auto-returning')
		return self.decision
	end
	local decisions = {}
	
	local cr = self.currentRequest
	self.battle:debug('resolving:', cr)
	if cr == 'move' then
		for _, pokemon in pairs(self.active) do
			if pokemon ~= null and not pokemon.fainted then
				local lockedMove = pokemon:getLockedMove()
				if lockedMove then
					table.insert(decisions, {
						choice = 'move',
						pokemon = pokemon,
						targetLoc = self.battle:runEvent('LockMoveTarget', pokemon) or 0,
						move = lockedMove
					})
				else
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
				end
			end
		end
	elseif cr == 'switch' then
		local canSwitchOut = {}
		for i, pokemon in pairs(self.active) do
			if pokemon ~= null and pokemon.switchFlag then
				table.insert(canSwitchOut, i)
			end
		end
		
		local canSwitchIn = {}
		for i = #self.active+1, #self.pokemon do
			if self.pokemon[i] ~= null and not self.pokemon[i].fainted then
				table.insert(canSwitchIn, i)
			end
		end
		
--		local willPass = canSwitchOut.splice(math.min(#canSwitchOut, #canSwitchIn))
		for i, s in pairs(canSwitchOut) do
			table.insert(decisions, {
				choice = self.foe.currentRequest == 'switch' and 'instaswitch' or 'switch',
				pokemon = self.active[s],
				target = self.pokemon[canSwitchIn[i]]
			})
		end
		for i = math.min(canSwitchOut, canSwitchIn), canSwitchOut do
			table.insert(decisions, {
				choice = 'pass',
				pokemon = self.active[canSwitchOut[i]],
				priority = 102
			})
		end
	elseif cr == 'teampreview' then
		local team = {}
		for i = 1, #self.pokemon do
			team[i] = i
		end
		table.insert(decisions, {
			choice = 'team',
			side = self,
			team = team
		})
	end
	return decisions
end
function BattleSide:remove()
	-- deallocate ourself
	
	-- deallocate children and get rid of references to them
	for i = 1, #self.pokemon do
		if self.pokemon[i] then self.pokemon[i]:remove() end
		self.pokemon[i] = nil
	end
	self.pokemon = nil
	for i = 1, #self.active do
		self.active[i] = nil
	end
	self.active = nil
	
	if self.decision and self.decision ~= true then
		self.decision.side = nil
		self.decision.pokemon = nil
	end
	self.decision = nil
	
	-- get rid of some possibly-circular references
	self.battle = nil
	self.foe = nil
end



return BattleSide