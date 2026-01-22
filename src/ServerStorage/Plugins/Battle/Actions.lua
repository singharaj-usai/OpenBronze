--[[
|
|move|1p1a: Swampert|Solar Beam|1p2a: Vullaby|[still]
|-damage|1p2a: Vullaby|0/68
|-prepare|1p1a: Swampert|Solar Beam|1p2a: Vullaby
|-anim|1p1a: Swampert|Solar Beam|1p2a: Vullaby
|-resisted|1p2a: Vullaby
|
--]]

local null, toId, Not, indexOf, split, trim, shallowcopy, deepcopy, sync, map, jsonDecode, comma_value; do
	local util = require(script.Parent.BattleUtilities)
	null = util.null
	toId = util.toId
	Not = util.Not
	indexOf = util.indexOf
	split = util.split
	trim = util.trim
	shallowcopy = util.shallowcopy
	deepcopy = util.deepcopy
	sync = util.sync
	map = util.map
	jsonDecode = util.jsonDecode
	comma_value = util.comma_value
end

-- Replay Implementation:
--   save logs
--   search logs for data lookups (Tools.etc), preload
--   location will have to be added to log

local BattleStats = {
	atk = 'Attack',
	def = 'Defense',
	spa = 'Special Attack',
	spd = 'Special Defense',
	spe = 'Speed',
	accuracy = 'Accuracy',
	evasion = 'Evasion',
}

local BattleStatusAnims = {}
local BattleOtherAnims = {}

local push = table.insert

local lastAction
local lastBoostPoke
local isMove = false
local isMultiTarget = false

local Tools = require(script.Parent.Tools)

-- Todo:
--	if update is winupdate then
--		from bottom of actions, going up until encounter -move [then break] do:
--			if action == -boost or -unboost and sourceEffect.effectType == Move then remove it (weather too? and what else?)

return function(Battle)
	function Battle:showAbility(...)
		if lastAction == 'switch' then
			wait(1)
		end
		self:animAbility(...)
	end
	function Battle:damageAnim(pokemon, damage)
		if not pokemon or not pokemon.statbar then return end
		damage = damage:match('^([^;]+)') or damage
		local hp, maxhp = unpack(split(damage, '/'))
		if not pokemon.statbar then
			pokemon.hp = hp
			pokemon.maxhp = maxhp
			return
		end
		pokemon.statbar:animateHP(pokemon.hp, hp, maxhp)
		pokemon.hp = hp
		pokemon.maxhp = maxhp
	end
	function Battle:healAnim(pokemon, damage)
		if not pokemon or not pokemon.statbar then return end
		if pokemon.statbar.animating or (pokemon.statbar.lastAnimTime and tick()-pokemon.statbar.lastAnimTime<.3) then-- or lastAction == '-damage'
			local sb = pokemon.statbar
			while sb.animating do
				wait()
			end
			wait(.3)
		end
		local hp, maxhp
		spawn(function()
			self:animStatus('heal', pokemon)
		end)
		pcall(function()
			hp, maxhp = damage:match('^(%d+)/(%d+)')
			hp, maxhp = tonumber(hp), tonumber(maxhp)
		end)
		if not pokemon.statbar then
			pokemon.hp = hp
			pokemon.maxhp = maxhp
			return
		end
		pokemon.statbar:animateHP(pokemon.hp, hp, maxhp)
		pokemon.hp = hp
		pokemon.maxhp = maxhp
	end
	function Battle:getMoveTargets()
		local nTargets = 0
		local targets = {}
		for _, action in pairs(self.actionQueue) do
			if action == '|' then break end
			local args, kwargs = self:parseAction(action)
			local arg1 = args[1]
			if arg1 == '-damage' and kwargs.from ~= 'recoil' then
				nTargets = nTargets + 1
				local pokemon = self:getPokemon(args[2])
				if pokemon then
					table.insert(targets, pokemon)
				end
			elseif arg1 == '-immune' or arg1 == '-miss' then
				nTargets = nTargets + 1
			end
		end
		isMultiTarget = nTargets>1
		return targets
	end
	function Battle:useMove(pokemon, move, target, kwargs)
		local fromeffect = Tools.getEffect(kwargs.from)
		pokemon:clearMovestatuses()
		if move.id == 'focuspunch' then
			pokemon:removeTurnstatus('focuspunch')
		end
		pokemon.side:updateStatbar(pokemon)
		if not target then
			target = pokemon.side.foe.active[1]
		end
		if Not(target) then
			target = nil--pokemon.side.foe.missedPokemon
		end
		if not kwargs.silent then
			local id = fromeffect.id
			if id == 'snatch' then
				
			elseif id == 'magicbounce' or id == 'magiccoat' or id == 'rebound' then
				if fromeffect.id == 'magiccoat' then
					pokemon:addTurnstatus('magiccoat')
				end
				self:message(target:getName() .. "'s " .. move.name .. " was bounced back by " .. fromeffect.name .. "!")
			elseif id == 'metronome' then
				self:message('Waggling a finger let it use ' .. move.name .. '!')
			elseif id == 'naturepower' then
				self:message('Nature Power turned into ' .. move.name .. '!')
--			elseif id == 'sleeptalk' then
--				
			else
				self:message(pokemon:getName() .. ' used ' .. move.name .. '!')
				if not fromeffect.id then
					pokemon:markMove(move.name)
				end
			end
			if kwargs.notarget and move.id == 'helpinghand' and self.actionQueue[1] == '|-notarget' then
				self:message('But it failed!')
				table.remove(self.actionQueue, 1)
			end
		end
		if not self.fastForward and not kwargs.still then
			-- skip
--			if kwargs.miss and target.side then
--				target = target.side.missedPokemon
--			end
--			if kwargs.notarget then
--				target = pokemon.side.foe.missedPokemon
--			end
			if kwargs.prepare or kwargs.anim == 'prepare' then
				self:prepareMove(pokemon, move, target)
			elseif not kwargs.notarget then
--				if not self.actionQueue[1] or self.actionQueue[1]:sub(1, 6) ~= '|-fail' then
					self:animMove(pokemon, move, self:getMoveTargets())--target)
--				end
			end
		end
		pokemon.lastmove = move.id
		self.lastmove = move.id
		if move.id == 'wish' or move.id == 'healingwish' then
			pokemon.side.wisher = pokemon
		end
	end
	-- so basically, I changed how -damage minors are added to the queue (in BattleEngine)
	-- this mucked up multi-hit moves; we fix that here
	function Battle:useMultihitMove(pokemon, move, target, kwargs, actions)
		isMove = false -- much hack
		isMultiTarget = false
		self:message(pokemon:getName() .. ' used ' .. move.name .. '!')
		local damages = {}
		local crits = {}
		local after = {}
		for _, a in pairs(actions) do
			if a:sub(1, 8) == '|-damage' then -- damages are reversed
				table.insert(damages, 1, a)
			elseif a:sub(1, 6) == '|-crit' then -- crits all come after damages (hence I added 'nocrit' for disambiguation)
				crits[#crits+1] = true
			elseif a:sub(1, 8) == '|-nocrit' then
				crits[#crits+1] = false
			else -- -supereffective or -resisted come in once per hit, filter out the extras; after[] should also contain -hitcount
				local unique = true
				for _, af in pairs(after) do
					if af == a then
						unique = false
						break
					end
				end
				if unique then
					table.insert(after, a)
				end
			end
		end
		-- Target fix: When a pokemon uses a multi-hit move on a fainted opponent, the target is redirected, HOWEVER, the `target`
		--  argument in the history the client receives is still set to the original target. We just use the pokemon involved in the 
		--  damage as the target. There are no moves that are multi-hit and also multi-target.
		pcall(function()
			for _, damage in pairs(damages) do
				target = self:getPokemon(self:parseAction(damage)[2]) or target
				break
			end
		end)
		if #damages ~= #crits then
			warn('multi-hit move: damage-count does not match crit-count')
		end
		for i = #after, 1, -1 do -- I have to put -supereffective and -resisted back into the action queue to get processed normally
			table.insert(self.actionQueue, 1, after[i]) -- so that the animation will play the right sound
		end
		for i, d in pairs(damages) do
			local t = tick()
			self:animMove(pokemon, move, {target})
			self:run(d)
			if crits[i] then
				self:message('A critical hit!')
			end
			local minimumDuration = 1
			local e = tick()-t
			if e < minimumDuration then
				wait(minimumDuration-e)
			end
		end
	end
	function Battle:cantUseMove(pokemon, effect, move, kwargs)
		pokemon:clearMovestatuses()
		pokemon.side:updateStatbar(pokemon)
		if not self.battleStatusAnimsDisabled and BattleStatusAnims[effect.id] and not self.fastForward then --
			BattleStatusAnims[effect.id].anim(self, {pokemon.sprite})
		end
		local id = effect.id
		if id == 'taunt' then
			self:message(pokemon:getName() .. ' can\'t use ' .. move.name .. ' after the taunt!')
		elseif id == 'gravity' then
			self:message(pokemon:getName() .. ' can\'t use ' .. move.name .. ' because of gravity!')
		elseif id == 'healblock' then
			self:message(pokemon:getName() .. ' can\'t use ' .. move.name .. ' because of Heal Block!')
		elseif id == 'imprison' then
			self:message(pokemon:getName() .. ' can\'t use its sealed ' .. move.name .. '!')
		elseif id == 'par' then
			self:animStatus('par', pokemon)
			self:message(pokemon:getName() .. ' is paralyzed! It can\'t move!')
		elseif id == 'frz' then
			self:animStatus('frz', pokemon)
			self:message(pokemon:getName() .. ' is frozen solid!')
		elseif id == 'slp' then
			self:animStatus('slp', pokemon)
			self:message(pokemon:getName() .. ' is fast asleep.')
		elseif id == 'skydrop' then
			self:message('Sky Drop won\'t let ' .. pokemon:getLowerName() .. ' go!')
		elseif id == 'truant' then
			self:message(pokemon:getName() .. ' is loafing around!')
		elseif id == 'recharge' then
--			BattleOtherAnims['selfstatus'].anim(self, {pokemon.sprite}) --
			self:message(pokemon:getName() .. ' must recharge!')
		elseif id == 'focuspunch' then
			self:message(pokemon:getName() .. ' lost its focus and couldn\'t move!')
			pokemon:removeTurnstatus('focuspunch')
		elseif id == 'flinch' then
			self:message(pokemon:getName() .. ' flinched and couldn\'t move!')
			pokemon:removeTurnstatus('focuspunch')
		elseif id == 'attract' then
			self:message(pokemon:getName() .. ' is immobilized by love!')
		elseif id == 'nopp' then
			self:message(pokemon:getName() .. ' used ' .. move.name .. '!')
			self:message('But there was no PP left for the move!')
		else
			self:message(pokemon:getName() .. (move.name and (' can\'t use ' .. move.name) or ' can\'t move') .. '!')
		end
		pokemon.sprite:animReset()
	end
	function Battle:parseAction(str)
		local args, kwargs = split(str:sub(2), '|'), {}
--		if str ~= '|' then
--			args = split(str:sub(2), '|')
--		end
		while args[#args] and args[#args]:sub(1, 1) == '[' do
			local bracketPos = indexOf(args[#args], ']')
			if not bracketPos then break end
			local argstr = table.remove(args)
			-- default to '.' so it doesn't get confused with a pseudo-falsy value
			if argstr:sub(bracketPos + 1, bracketPos + 1) == ' ' then
				kwargs[argstr:sub(2, bracketPos - 1)] = trim(argstr:sub(bracketPos + 2)) or '.'
			else
				kwargs[argstr:sub(2, bracketPos - 1)] = trim(argstr:sub(bracketPos + 1)) or '.'
			end
		end
		return args, kwargs
	end
	function Battle:run(str)
		if not str then return end
		if str == '|' then
			isMove = false
			isMultiTarget = false
		elseif str:sub(1, 1) ~= '|' or str:sub(1, 2) == '||' then
			
		else
			local args, kwargs = self:parseAction(str)
			
			local s, e = pcall(function()
				if not args[1] then return end
				if args[1]:sub(1, 1) == '-' then
					local r = self:runMinor(args, kwargs)
					lastAction = args[1]
					return r
				else
					local r = self:runMajor(args, kwargs)
					lastAction = args[1]
					return r
				end
			end)
			if not s then
				warn('ERROR (BattleClient::run):', e)
				if self.errorCallback then
					self:errorCallback()
				end
--				warn(str)
			else
				return e
			end
		end
	end
	function Battle:runMinor(args, kwargs)
		local actions = {}
		local function addAction(a)
			push(actions, a)
		end
		local hiddenactions = {}
		local function addHiddenAction() end
		local minors = self.minorQueue
		if self.multiHitMove and #minors > 0 then
			local lastMinor = minors[#minors]
		end
		if args then -- combining
--			if args[1] == '-crit' or args[1] == '-supereffective' or args[1] == '-resisted' then args['then'] = '.' end
--			if args[1] == '-damage' and kwargs.from == 'Leech Seed' and nextArgs[1] == '-heal' and nextKwargs.silent then args['then'] = '.' end
			table.insert(minors, {args, kwargs})
--			if args.simult or args['then'] then return end
		end
		local animDelay = 0
		local nextAnimDelay = 0
		while #minors > 0 do
			local row = table.remove(minors, 1)
			args = row[1]
			kwargs = row[2]
			animDelay = nextAnimDelay
			if not kwargs.simult then nextAnimDelay = nextAnimDelay + 1 end
			
			local arg1 = args[1]
			if arg1 == '-center' then
				addAction("Automatic center!")
			elseif arg1 == '-damage' then
				local poke = self:getPokemon(args[2])
				local damage = args[3]--poke:healthParse(args[3], true)
				if damage then -- ~= false then --
					if kwargs.from == 'Bide' then
						pcall(function() self:animMove(self:getPokemon(kwargs.of), Tools.getEffect('move:bide'), {poke}) end)
						kwargs.silent = true
					end
					
					local nActions = #actions
					if kwargs.silent then
						-- do nothing
					elseif kwargs.from then
						local effect = Tools.getEffect(kwargs.from)
						local effectId = effect and effect.id or kwargs.from
--						print('damaged by', effectId)
						local ofpoke = self:getPokemon(kwargs.of)
						if effectId == 'stealthrock' then
							addAction("Pointed stones dug into " .. poke:getLowerName() .. "!")
						elseif effectId == 'spikes' then
							addAction(poke:getName() .. " is hurt by the spikes!")
						elseif effectId == 'brn' then
							self:animStatus('brn', poke)
							addAction(poke:getName() .. " was hurt by its burn!")
						elseif effectId == 'psn' then
							self:animStatus('psn', poke)
							addAction(poke:getName() .. " was hurt by poison!")
						elseif effectId == 'lifeorb' then
							addAction(poke:getName() .. " lost some of its HP!")
						elseif effectId == 'recoil' then
							addAction(poke:getName() .. " is damaged by the recoil!")
						elseif effectId == 'sandstorm' then
							addAction(poke:getName() .. " is buffeted by the sandstorm!")
						elseif effectId == 'hail' then
							addAction(poke:getName() .. " is buffeted by the hail!")
						elseif effectId == 'baddreams' then
							addAction(poke:getName() .. " is tormented!")
						elseif effectId == 'nightmare' then
							addAction(poke:getName() .. " is locked in a nightmare!")
						elseif effectId == 'confusion' then
							self:animHit(poke, nil, nil, nil, nil, true)
							addAction("It hurt itself in its confusion!")
							pcall(function() poke.sprite:animReset() end)
						elseif effectId == 'leechseed' then
--							if not self.fastForward then
--								BattleOtherAnims.leech.anim(self, {ofpoke.sprite, poke.sprite}) --
--								self:activityWait(500)
--							end
							addAction(poke:getName() .. "'s health is sapped by Leech Seed!")
						elseif effectId == 'flameburst' then
							addAction("The bursting flame hit " .. poke:getLowerName() .. "!")
						elseif effectId == 'firepledge' then
							addAction(poke:getName() .. " is hurt by the sea of fire!")
						elseif effectId == 'jumpkick' or effectId == 'highjumpkick' then
							addAction(poke:getName() .. " kept going and crashed!")
						else
							if ofpoke then
								addAction(poke:getName() .. " is hurt by " .. ofpoke:getLowerName() .. "'s " .. effect.name .. "!")
							elseif effect.effectType == 'Item' or effect.effectType == 'Ability' then
								addAction(poke:getName() .. " is hurt by its " .. effect.name .. "!")
							elseif kwargs.partiallytrapped then
								addAction(poke:getName() .. ' is hurt by ' .. effect.name .. '!')
							else
								addAction(poke:getName() .. " lost some HP because of " .. effect.name .. "!")
							end
						end
					end
					if #actions > nActions or not isMove then
						self:damageAnim(poke, damage)
					else
						local damageAnims = {function() self:damageAnim(poke, damage) end}
						local i = 1
						while true do
							local action = self.actionQueue[i]
							if not action or action == '|' then break end
							local args, kwargs = self:parseAction(action)
							if args[1] == '-damage' then
								if kwargs.from then break end
								table.remove(self.actionQueue, i)
								table.insert(damageAnims, function() self:damageAnim(self:getPokemon(args[2]), args[3]) end)
							else
								i = i + 1
							end
						end
						sync(damageAnims)
					end
				end
			elseif arg1 == '-heal' then
				local poke = self:getPokemon(args[2])
				local damage = args[3]--poke:healthParse(args[3], true, true)
				if damage ~= false then --
					self:healAnim(poke, damage, animDelay) --
					
					if kwargs.silent then
						-- do nothing
					elseif kwargs.from then
						local effect = Tools.getEffect(kwargs.from)
						local effectId = effect.id
						local ofpoke = self:getPokemon(kwargs.of)
						if effectId == 'ingrain' then
							addAction(poke:getName() .. " absorbed nutrients with its roots!")
						elseif effectId == 'aquaring' then
							addAction("Aqua Ring restored " .. poke:getLowerName() .. "'s HP!")
						elseif effectId == 'raindish' or effectId == 'dryskin' or effectId == 'icebody' then
							addAction(poke:getName() .. "'s " .. effect.name .. " heals it!")
						elseif effectId == 'healingwish' then
							addAction("The healing wish came true for " .. poke:getLowerName() .. "!")
							self.lastmove = 'healing-wish'
--							Tools.getMove('healingwish').residualAnim(self, {poke.sprite}) -- todo
							poke.side.wisher = nil
						elseif effectId == 'lunardance' then
							addAction(poke:getName() .. " became cloaked in mystical moonlight!")
							self.lastmove = 'healing-wish'
--							Tools.getMove('healingwish').residualAnim(self, {poke.sprite}) --
							poke.side.wisher = nil
						elseif effectId == 'wish' then
							addAction(kwargs.wisher .. "'s wish came true!")
--							Tools.getMove('wish').residualAnim(self, {poke.sprite}) -- 
							self.animationDelay = self.animationDelay + 500
						elseif effectId == 'drain' then
							addAction(ofpoke:getName() .. ' had its energy drained!')
						elseif effectId == 'leftovers' or effectId == 'shellbell' then
							addAction(poke:getName() .. " restored a little HP using its " .. effect.name .. "!")
						else
							if kwargs.absorb then
								addAction(poke:getName() .. "'s " .. effect.name .. " absorbs the attack!")
							elseif effectId then
								addAction(poke:getName() .. " restored HP using its " .. effect.name .. "!")
							else
								addAction(poke:getName() .. ' regained health!')
							end
						end
					else
						addAction(poke:getName() .. ' regained health!')
					end
				end
			elseif arg1 == '-sethp' then
				local effect = Tools.getEffect(kwargs.from)
				sync {
					function() self:damageAnim(self:getPokemon(args[2]), args[3]) end,
					function() self:damageAnim(self:getPokemon(args[4]), args[5]) end,
				}
--				local poke, ofpoke
--				for k = 0, 1 do -- TODO >
--					local cpoke = self:getPokemon(args[2 + 2*k])
--					if cpoke then
--						local oldhp = cpoke.hp
--						cpoke:healthParse(args[3 + 2*k])
--						local diff = tonumber(args[3 + 2*k])
--						if not diff then
--							diff = cpoke.hp - oldhp
--						end
--						if diff > 0 then
--							self:healAnim(cpoke, diff, animDelay)
--						else
--							self:damageAnim(cpoke, -diff)
--						end
--					end
--					if k == 0 then poke = cpoke end
--					if k == 1 then ofpoke = cpoke end
--				end -- <
				if effect.id == 'painsplit' then
					addAction('The pokemon shared their pain!')
				end
			elseif arg1 == '-boost' then
				local poke = self:getPokemon(args[2])
				local stat = args[3]
				local amount = tonumber(args[4])
				poke.boosts[stat] = (poke.boosts[stat] or 0) + amount
				if lastAction ~= '-boost' or lastBoostPoke ~= poke then
					lastBoostPoke = poke
					self:animBoost(poke)
				end
				
				local amountString = ''
				if amount == 2 then amountString = ' sharply'
				elseif amount >= 3 then amountString = ' drastically' end
				if kwargs.silent then
					-- do nothing
				elseif kwargs.from then
					local effect = Tools.getEffect(kwargs.from)
					local ofpoke = self:getPokemon(kwargs.of)
					if effect.effectType == 'Ability' then
						self:showAbility(poke, effect.name)
						addAction(poke:getName() .. "'s " .. BattleStats[stat] .. " rose" .. amountString .. "!")
					elseif effect.effectType == 'Item' then
						if effect.id == 'sawsbuckcoffee' then
							addAction('Sipping from the Sawsbuck Coffee, ' .. poke:getLowerName() .. amountString .. ' raised its ' .. BattleStats[stat] .. "!")
						else
							addAction("The " .. effect.name .. amountString .. " raised " .. poke:getLowerName() .. "'s " .. BattleStats[stat] .. "!")
						end
					else
						addAction(poke:getName() .. "'s " .. effect.name .. amountString .. " raised its " .. BattleStats[stat] .. "!")
					end
				else
					addAction(poke:getName() .. "'s " .. BattleStats[stat] .. amountString .. " rose!")
				end
			elseif arg1 == '-unboost' then
				local poke = self:getPokemon(args[2])
				local stat = args[3]
				local amount = tonumber(args[4])
				poke.boosts[stat] = (poke.boosts[stat] or 0) - amount
				if lastAction ~= '-unboost' or lastBoostPoke ~= poke then
					lastBoostPoke = poke
					self:animUnboost(poke)
				end
				
				local amountString = ''
				if amount == 2 then amountString = ' harshly'
				elseif amount >= 3 then amountString = ' severely' end
				if kwargs.silent then
					-- do nothing
				elseif kwargs.from then
					local effect = Tools.getEffect(kwargs.from)
					local ofpoke = self:getPokemon(kwargs.of)
					if effect.effectType == 'Item' then
						addAction("The " .. effect.name .. amountString .. " lowered " .. poke:getLowerName() .. "'s " .. BattleStats[stat] .. "!")
					else
						addAction(poke:getName() .. "'s " .. effect.name .. amountString .. " lowered its " .. BattleStats[stat] .. "!")
					end
				else
					addAction(poke:getName() .. "'s " .. BattleStats[stat] .. amountString .. " fell!")
				end
			elseif arg1 == '-setboost' then
				local poke = self:getPokemon(args[2])
				local stat = args[3]
				local amount = tonumber(args[4])
				local effect = Tools.getEffect(kwargs.from)
				local ofpoke = self:getPokemon(kwargs.of)
				poke.boosts[stat] = amount
				
				if kwargs.silent then
					-- do nothing
				elseif kwargs.from then
					if effect.id == 'bellydrum' then
						addAction(poke:getName() .. ' cut its own HP and maximized its Attack!')
					elseif effect.id == 'angerpoint' then
						self:showAbility(poke, 'Anger Point')
						addAction(poke:getName() .. ' maxed its Attack!')
					end
				end
			elseif arg1 == '-swapboost' then
				local poke = self:getPokemon(args[2])
				local poke2 = self:getPokemon(args[3])
				local stats = args[4] and split(args[4], ', ') or {'atk', 'def', 'spa', 'spd', 'spe', 'accuracy', 'evasion'}
				local effect = Tools.getEffect(kwargs.from)
				for i, stat in pairs(stats) do
					local tmp = poke.boosts[stat]
					poke.boosts[stat] = poke2.boosts[stat]
					poke2.boosts[stat] = tmp
				end
				
				if kwargs.silent then
					-- do nothing
				elseif effect.id then
					if effect.id == 'guardswap' then
						addAction(poke:getName() .. ' switched all changes to its Defense and Sp. Def with its target!') -- check message
					elseif effect.id == 'heartswap' then
						addAction(poke:getName() .. ' switched stat changes with its target!')
					elseif effect.id == 'powerswap' then
						addAction(poke:getName() .. ' switched all changes to its Attack and Sp. Atk with its target!') --
					end
				end
			elseif arg1 == '-restoreboost' then
				local poke = self:getPokemon(args[2])
				for i, b in pairs(poke.boosts) do
					if b < 0 then
						poke.boosts[i] = nil
					end
				end
			elseif arg1 == '-copyboost' then
				local poke = self:getPokemon(args[2])
				local frompoke = self:getPokemon(args[3])
				local stats = args[4] and split(args[4], ', ') or {'atk', 'def', 'spa', 'spd', 'spe', 'accuracy', 'evasion'}
				local effect = Tools.getEffect(kwargs.from)
				for i, stat in pairs(stats) do
					poke.boosts[stat] = frompoke.boosts[stat]
				end
				
				if kwargs.silent then
					-- do nothing
				else
					addAction(poke:getName() .. " copied " .. frompoke:getLowerName() .. "'s stat changes!")
				end
			elseif arg1 == '-clearboost' then
				local poke = self:getPokemon(args[2])
				poke.boosts = {}
				
				if kwargs.silent then
					-- do nothing
				else
					addAction(poke:getName() .. '\'s stat changes were removed!')
				end
			elseif arg1 == '-invertboost' then
				local poke = self:getPokemon(args[2])
				for i, b in pairs(poke.boosts) do
					poke.boosts[i] = -b
				end
				
				if kwargs.silent then
					-- do nothing
				else
					addAction(poke:getName() .. '\'s stat changes were inverted!')
				end
			elseif arg1 == '-clearallboost' then
				for _, side in pairs(self.sides) do
					for _, a in pairs(side.active) do
						if a ~= null then
							a.boosts = {}
						end
					end
				end
				
				if kwargs.silent then
					-- do nothing
				else
					addAction('All stat changes were eliminated!')
				end
			elseif arg1 == '-crit' then
				if isMultiTarget then
					local poke = self:getPokemon(args[2])
					if poke then
						addAction('A critical hit on ' .. poke:getLowerName() .. '!')
					else
						addAction('A critical hit!')
					end
				else
					addAction('A critical hit!')
				end
			elseif arg1 == '-supereffective' then
				if isMultiTarget then
					local poke = self:getPokemon(args[2])
					if poke then
						addAction('It\'s super effective on ' .. poke:getLowerName() .. '!')
					else
						addAction('It\'s super effective!')
					end
				else
					addAction('It\'s super effective!')
				end
			elseif arg1 == '-resisted' then
				if isMultiTarget then
					local poke = self:getPokemon(args[2])
					if poke then
						addAction('It\'s not very effective on ' .. poke:getLowerName() .. '.')
					else
						addAction('It\'s not very effective...')
					end
				else
					addAction('It\'s not very effective...')
				end
			elseif arg1 == '-immune' then
				local poke = self:getPokemon(args[2])
				local effect = Tools.getEffect(args[3])
				if effect.id == 'confusion' then
					addAction(poke:getName() .. " doesn't become confused!")
				else
					if kwargs.msg then
						addAction("It doesn't affect " .. poke:getLowerName() .. "...")
					elseif kwargs.ohko then
						addAction(poke:getName() .. " is unaffected!")
					else
						addAction("It had no effect!")
					end
				end
			elseif arg1 == '-miss' then
				local user = self:getPokemon(args[2])
				local target = self:getPokemon(args[3])
				if target then
					addAction(target:getName() .. " avoided the attack!")
				else
					addAction(user:getName() .. "'s attack missed!")
				end
			elseif arg1 == '-fail' then
				if not args[2] then
					addAction("But it failed!")
				else
					local poke = self:getPokemon(args[2])
					local effect = Tools.getEffect(args[3])
					local fromeffect = Tools.getEffect(kwargs.from)
					if poke then
						
					end
	--				print(fromeffect.effectType, fromeffect.id, fromeffect.name)
					-- Sky Drop blocking moves takes priority over all other moves
					if fromeffect.id == 'skydrop' then
						addAction("Sky Drop won't let " .. poke:getLowerName() .. " go!")
					elseif fromeffect.id == 'clearbody' then
						
					end
					if effect.id == 'brn' then
						addAction(poke:getName() .. " is already burned.")
					elseif effect.id == 'tox' or effect.id == 'psn' then
						addAction(poke:getName() .. " is already poisoned.")
						break;
					elseif effect.id == 'slp' then
						if fromeffect.id == 'uproar' then
							if kwargs.msg then
								addAction("But " .. poke:getLowerName() .. " can't sleep in an uproar!")
							else
								addAction("But the uproar kept " .. poke:getLowerName() .. " awake!")
							end
						else
							addAction(poke:getName() .. " is already asleep.")
						end
					elseif effect.id == 'par' then
						addAction(poke:getName() .. " is already paralyzed.")
					elseif effect.id == 'frz' then
						addAction(poke:getName() .. " is already frozen.")
					elseif effect.id == 'hyperspacefury' then
						if kwargs.forme then
							addAction('But ' .. poke:getLowerName() .. ' can\'t use it the way it is now!')
						else
							addAction('But ' .. poke:getLowerName() .. ' can\'t use the move!')
						end
					elseif effect.id == 'substitute' then
						if kwargs.weak then
							addAction("But it's too weak to make a substitute!")
						else
							addAction(poke:getName() .. ' already has a substitute!')
						end
					elseif effect.id == 'skydrop' then
						if kwargs.heavy then
							addAction(poke:getName() .. ' is too heavy to be lifted!')
						else
							addAction("But it failed!")
						end
					elseif effect.id == 'sunnyday' or effect.id == 'raindance' or effect.id == 'sandstorm' or effect.id == 'hail' then
						if fromeffect.id == 'desolateland' then
							addAction("The extremely harsh sunlight was not lessened at all!")
						elseif fromeffect.id == 'primordialsea' then
							addAction("There's no relief from this heavy rain!")
						elseif fromeffect.id == 'ghostlyfog' then
							addAction("The fog continues to loom the field!")
						elseif fromeffect.id == 'deltastream' then
							addAction("The mysterious air current blows on regardless!")
						else
							addAction("But it failed!")
						end
					elseif effect.id == 'unboost' then
						if fromeffect.effectType == 'Ability' then
							self:showAbility(poke, fromeffect.name)
						else
							
						end
						local nextAction = self.actionQueue[1]
						if nextAction and nextAction:sub(1, 6) == '|-fail' and nextAction:sub(8) == args[2] then
							table.remove(self.actionQueue, 1)
						end
						addAction(poke:getName() .. "'s " .. (args[4] and args[4] .. " was" or "stats were") .. " not lowered!")
					else
						if fromeffect.id == 'desolateland' then
							addAction("The Water-type attack evaporated in the harsh sunlight!")
						elseif fromeffect.id == 'primordialsea' then
							addAction("The Fire-type attack fizzled out in the heavy rain!")
						elseif fromeffect.id == 'ghostlyfog' then
							addAction("The Fairy-type attack where lost in the fog!")
						else
							addAction("But it failed!")
						end
					end
				end
			elseif arg1 == '-notarget' then
				addAction("But there was no target...")
			elseif arg1 == '-ohko' then
				addAction("It's a one-hit KO!")
			elseif arg1 == '-hitcount' then
				local hits = tonumber(args[3])
				addAction('Hit ' .. hits .. (hits > 1 and ' times!' or ' time!'))
			elseif arg1 == '-nothing' then
				addAction("But nothing happened!")
			elseif arg1 == '-waiting' then
				local poke = self:getPokemon(args[2])
				local ofpoke = self:getPokemon(args[3])
				addAction(poke:getName() .. " is waiting for " .. ofpoke:getLowerName() .. "'s move...")
			elseif arg1 == '-combine' then
				addAction("The two moves have become one! It's a combined move!")
			elseif arg1 == '-prepare' then
				local poke = self:getPokemon(args[2])
				local move = Tools.getMove(args[3])
				local target = self:getPokemon(args[4])
				self:prepareMove(poke, move, target)
			elseif arg1 == '-mustrecharge' then
--				local poke = self:getPokemon(args[2])
--				poke:addMovestatus('mustrecharge')
--				poke.side:updateStatbar(poke) --
			elseif arg1 == '-status' then
				local poke = self:getPokemon(args[2])
				if poke then
					local effect = Tools.getEffect(kwargs.from)
					poke.status = args[3]
					poke:removeVolatile('yawn')
					
					local arg3 = args[3]
					if arg3 == 'brn' then
						self:animStatus('brn', poke)
						addAction(poke:getName() .. " was burned" .. (effect.exists and " by the " .. effect.name or "") .. "!")
					elseif arg3 == 'tox' then
						self:animStatus('psn', poke)
						addAction(poke:getName() .. " was badly poisoned" .. (effect.exists and " by the " .. effect.name or "") .. "!")
					elseif arg3 == 'psn' then
						self:animStatus('psn', poke)
						addAction(poke:getName() .. " was poisoned!")
					elseif arg3 == 'slp' then
						self:animStatus('slp', poke)
						if effect.id == 'rest' then
							addAction(poke:getName() .. ' slept and became healthy!')
						else
							addAction(poke:getName() .. " fell asleep!")
						end
					elseif arg3 == 'par' then
						self:animStatus('par', poke)
						addAction(poke:getName() .. " is paralyzed! It may be unable to move!")
					elseif arg3 == 'frz' then
						self:animStatus('frz', poke)
						addAction(poke:getName() .. " was frozen solid!")
					else
						poke.side:updateStatbar(poke)
					end
					pcall(function() poke.statbar:update() end)
				end
			elseif arg1 == '-curestatus' then
				local poke = self:getPokemon(args[2])
				local effect = Tools.getEffect(kwargs.from)
				local ofpoke = self:getPokemon(kwargs.of)
				poke.status = ''
				
				if not kwargs.silent then
					if effect.id == 'psychoshift' then
						addAction(poke:getName() .. ' moved its status onto ' .. ofpoke:getLowerName() .. '!')
					elseif ({flamewheel=true,flareblitz=true,fusionflare=true,sacredfire=true,scald=true,steameruption=true})[effect.id] then
						addAction(poke:getName() .. "'s " .. effect.name .. " melted the ice!")
					elseif effect.id and effect.id ~= '' then
						addAction(poke:getName() .. "'s " .. effect.name .. " heals its status!")
					else
						local arg3 = args[3]
						if arg3 == 'brn' then
							if effect.effectType == 'Item' then
								addAction(poke:getName() .. "'s " .. effect.name .. " healed its burn!")
							else
								if poke.side.n == 1 then
									addAction(poke:getName() .. "'s burn was healed.")
								else
									addAction(poke:getName() .. " healed its burn!")
								end
							end
						elseif arg3 == 'tox' or arg3 == 'psn' then
							if effect.effectType == 'Item' then
								addAction(poke:getName() .. "'s " .. effect.name .. " cured its poison!")
							else
								addAction(poke:getName() .. " was cured of its poisoning.")
							end
						elseif arg3 == 'slp' then
							if effect.effectType == 'Item' then
								addAction(poke:getName() .. "'s " .. effect.name .. " woke it up!")
							else
								addAction(poke:getName() .. " woke up!")
							end
						elseif arg3 == 'par' then
							if effect.effectType == 'Item' then
								addAction(poke:getName() .. "'s " .. effect.name .. " cured its paralysis!")
							else
								addAction(poke:getName() .. " was cured of paralysis.")
							end
						elseif arg3 == 'frz' then
							if effect.effectType == 'Item' then
								addAction(poke:getName() .. "'s " .. effect.name .. " defrosted it!")
							else
								addAction(poke:getName() .. " thawed out!")
							end
						else
							poke:removeVolatile('confusion')
							addAction(poke:getName() .. "'s status cleared!")
						end
					end
				end
				pcall(function() poke.statbar:update() end)
			elseif arg1 == '-cureteam' then
				local poke = self:getPokemon(args[2])
				for _, p in pairs(poke.side.pokemon) do
					p.status = ''
					poke.side:updateStatbar(p) --
				end
				
				local effect = Tools.getEffect(kwargs.from)
				if effect.id == 'aromatherapy' then
					addAction('A soothing aroma wafted through the area!')
				elseif effect.id == 'healbell' then
					addAction('A bell chimed!')
				else
					addAction(poke:getName() .. "'s team was cured!")
				end
			elseif arg1 == '-item' then
				local poke = self:getPokemon(args[2])
				local item = Tools.getItem(args[3])
				local effect = Tools.getEffect(kwargs.from)
				local ofpoke = self:getPokemon(kwargs.of)
				poke.item = item.name
				poke:removeVolatile('airballoon')
				if item.id == 'airballoon' then
					poke:addVolatile('airballoon')
				end
				if effect.id == 'recycle' or effect.id == 'pickup' then
					addAction(poke:getName() .. ' found one ' .. item.name .. '!')
				elseif effect.id == 'frisk' then
					if kwargs.identify then -- used for gen 6
						addAction(ofpoke:getName() .. ' frisked ' .. poke:getLowerName() .. ' and found its ' .. item.name .. '!')
					else
						addAction(ofpoke:getName() .. ' frisked its target and found one ' .. item.name .. '!')
					end
				elseif effect.id == 'thief' or effect.id == 'covet' or effect.id == 'pickpocket' then
					addAction(poke:getName() .. ' stole ' .. ofpoke:getLowerName() .. "'s " .. item.name .. "!")
				elseif effect.id == 'harvest' then
					self:showAbility(poke, 'Harvest')
					addAction(poke:getName() .. ' harvested one ' .. item.name .. '!')
				elseif effect.id == 'bestow' then
					addAction(poke:getName() .. ' received ' .. item.name .. ' from ' .. ofpoke:getLowerName() .. '!')
				elseif effect.id and effect.id ~= '' then
					addAction(poke:getName() .. ' obtained one ' .. item.name .. '.')
				else
					if item.id == 'airballoon' then
						addAction(poke:getName() .. " floats in the air with its Air Balloon!")
					else
						addAction(poke:getName() .. " has " .. item.name .. "!")
					end
				end
			elseif arg1 == '-enditem' then
				local poke = self:getPokemon(args[2])
				local item = Tools.getItem(args[3])
				local effect = Tools.getEffect(kwargs.from)
				local ofpoke = self:getPokemon(kwargs.of)
				poke.item = ''
				poke:removeVolatile('airballoon')
				
				if kwargs.silent then
					-- do nothing
				elseif kwargs.eat then
					addAction(poke:getName() .. ' ate its ' .. item.name .. '!')
					self.lastmove = item.id
				elseif kwargs.weaken then
					addAction('The ' .. item.name .. ' weakened the damage to ' .. poke:getLowerName())
					self.lastmove = item.id
				elseif effect.id == 'fling' then
					addAction(poke:getName() .. ' flung its ' .. item.name .. '!')
				elseif effect.id == 'knockoff' then
					addAction(ofpoke:getName() .. ' knocked off ' .. poke:getLowerName() .. '\'s ' .. item.name .. '!')
				elseif effect.id == 'stealeat' then
					addAction(ofpoke:getName() .. ' stole and ate its target\'s ' .. item.name .. '!')
				elseif effect.id == 'gem' then
					addAction('The ' .. item.name .. ' strengthened ' .. Tools.getMove(kwargs.move).name .. '\'s power!')
				elseif effect.id == 'incinerate' then
					addAction(poke:getName() .. "'s " .. item.name .. " was burned up!")
				elseif effect.id then
					addAction(poke:getName() .. ' lost its ' .. item.name .. '!')
				else
					if item.id == 'airballoon' then
						poke:removeVolatile('airballoon')
						addAction(poke:getName() .. "'s Air Balloon popped!")
					elseif item.id == 'focussash' then
						addAction(poke:getName() .. ' hung on using its Focus Sash!')
					elseif item.id == 'focusband' then
						addAction(poke:getName() .. ' hung on using its Focus Band!')
					elseif item.id == 'whiteherb' then
						addAction(poke:getName() .. " returned its status to normal using its White Herb!")
					elseif item.id == 'ejectbutton' then
						addAction(poke:getName() .. " is switched out with the Eject Button!")
					elseif item.id == 'redcard' then
						addAction(poke:getName() .. " held up its Red Card against " .. ofpoke:getLowerName() .. "!")
					else
						addAction(poke:getName() .. "'s " .. item.name .. " activated!")
					end
				end
			elseif arg1 == '-ability' then
				local poke = self:getPokemon(args[2])
				local ability = Tools.getAbility(args[3])
				local effect = Tools.getEffect(kwargs.from)
				local ofpoke = self:getPokemon(kwargs.of)
				poke.ability = ability.name
				if not effect.id or kwargs.fail then
					if not poke.baseAbility then
						poke.baseAbility = ability.name
					end
				end
				
				if kwargs.silent then
					-- do nothing
				elseif effect.id == 'trace' then
					self:showAbility(poke, 'Trace', ability.name)
					addAction(poke:getName() .. ' traced ' .. ofpoke:getLowerName() .. '\'s ' .. ability.name .. '!')
				elseif effect.id == 'roleplay' then
					addAction(poke:getName() .. ' copied ' .. ofpoke:getLowerName() .. '\'s ' .. ability.name .. ' Ability!')
				elseif effect.id == 'mummy' then
					addAction(poke:getName() .. "'s Ability became Mummy!") --
				elseif effect.id == 'desolateland' then
					if kwargs.fail then
						addAction("[" .. poke:getName() .. "'s " .. ability.name .. "] The extremely harsh sunlight was not lessened at all!") --
					end
				elseif effect.id == 'primordialsea' then
					if kwargs.fail then
						addAction("[" .. poke:getName() .. "'s " .. ability.name .. "] There's no relief from this heavy rain!") --
					end
				elseif effect.id == 'ghostlyfog' then
					if kwargs.fail then
						addAction("[" .. poke:getName() .. "'s " .. ability.name .. "] There's no relief from this thick fog!") --
					end
				elseif effect.id == 'deltastream' then
					if kwargs.fail then
						addAction("[" .. poke:getName() .. "'s " .. ability.name .. "] The mysterious air current blows on regardless!") --
					end
				elseif effect.id and effect.id ~= '' then
					if effect.id == 'worryseed' or effect.id == 'simplebeam' then
						self:showAbility(poke, ability.name)
					end
					addAction(poke:getName() .. " acquired " .. ability.name .. "!")
				else
					self:showAbility(poke, ability.name)
					if ability.id == 'airlock' or ability.id == 'cloudnine' then
						addAction("The effects of the weather disappeared.")
					elseif ability.id == 'anticipation' then
						addAction(poke:getName() .. " shuddered!")
					elseif ability.id == 'aurabreak' then
						addAction(poke:getName() .. " reversed all other Pokemon's auras!")
					elseif ability.id == 'darkaura' then
						addAction(poke:getName() .. " is radiating a dark aura!")
					elseif ability.id == 'fairyaura' then
						addAction(poke:getName() .. " is radiating a fairy aura!")
					elseif ability.id == 'moldbreaker' then
						addAction(poke:getName() .. " breaks the mold!")
					elseif ability.id == 'pressure' then
						addAction(poke:getName() .. " is exerting its pressure!")
					elseif ability.id == 'sturdy' then
						addAction(poke:getName() .. " endured the hit!")
					elseif ability.id == 'teravolt' then
						addAction(poke:getName() .. " is radiating a bursting aura!")
					elseif ability.id == 'turboblaze' then
						addAction(poke:getName() .. " is radiating a blazing aura!")
					elseif ability.id == 'unnerve' then
						addAction(self:getSide(args[4]):getTeamName() .. " is too nervous to eat Berries!")
					else
						-- Do nothing
					end
				end
			elseif arg1 == '-endability' then
				local poke = self:getPokemon(args[2])
				local ability = Tools.getAbility(args[3])
				local effect = Tools.getEffect(kwargs.from)
				poke.ability = ''
				
				if kwargs.silent then
					-- do nothing
				elseif effect and (effect.id == 'worryseed' or effect.id == 'simplebeam') and ability and ability.exists then
					self:showAbility(poke, ability.name)
					wait(1.5)
				elseif ability and ability.id == 'illusion' then
					self:getPokemon(args[2], args[4], true)
					pcall(function() poke.sprite:renderNewSpriteData() end)
					pcall(function() poke.statbar:update() end)
					addAction(poke:getName() .. '\'s illusion wore off!')
--				elseif ability.exists then
--					addAction(poke:getName() .. "'s " .. ability.name .. " was removed.") -- todo (ability animation?)
--					
--					if not poke.baseAbility then
--						poke.baseAbility = ability.name
--					end
				else
					addAction(poke:getName() .. "\'s Ability was suppressed!")
				end
			elseif arg1 == '-transform' then
				local poke = self:getPokemon(args[2])
				local tpoke = self:getPokemon(args[3])
				local effect = Tools.getEffect(kwargs.from)
				if not kwargs.silent and effect.effectType == 'Ability' then
					self:showAbility(poke, effect.name)
				end
				addAction(poke:getName() .. ' transformed into ' .. tpoke.species .. '!')
				poke.sprite:animTransform(tpoke) -- todo
				poke.boosts = deepcopy(tpoke.boosts)
				poke:addVolatile('transform')
				poke:addVolatile('formechange') -- the formechange volatile reminds us to revert the sprite change on switch-out
				poke:copyTypesFrom(tpoke)
				poke.ability = tpoke.ability
--				poke.volatiles.formechange[3] = (tpoke.volatiles.formechange and tpoke.volatiles.formechange[3] or tpoke.species)
			elseif arg1 == '-formechange' then
				local poke = self:getPokemon(args[2])
				local template = Tools.getTemplate(args[3])
				local fromeffect = Tools.getEffect(kwargs.from)
--				local spriteData = {} -- todo plz
				local brk = false
				
				if kwargs.silent then
					-- do nothing
				else
					if fromeffect.effectType == 'Ability' then
						self:showAbility(poke, fromeffect.name)
					end
					if kwargs.msg then
						addAction(poke:getName() .. " transformed!")
						if template.species == 'Shaymin' and not template.forme then brk = true end
					elseif template.species == 'Darmanitan' then
						if template.forme == 'Zen' then
							addAction("Zen Mode triggered!")
						else
							addAction("Zen Mode ended!")
						end
						elseif template.species == 'Mimikyu' then
						if template.forme == 'Busted' then
							addAction("Mimikyu's Busted has failed :^(!")
						else
							addAction("Mimikyu's Busted has activated!")
						end
						elseif template.species == 'Zygarde' then
						if template.forme == 'Complete' then 
							addAction("Zygarde has seperated!")
						else
							self:showAbility(poke, 'Power Construct')
							
							addAction("You feel the pressence of many!") 
							end
						elseif template.species == 'Sainclaust' then
						if template.forme == 'forcedevo' then 
							addAction("Sainclaust has reverted!")
						else
							self:showAbility(poke, 'Forced Eveloution')
							
							addAction("An overwhelming presence has entered the field!") 
							end
					elseif template.species == 'Aegislash' then
						self:showAbility(poke, 'Stance Change')
						if template.forme == 'Blade' then
							addAction("Changed to Blade Forme!")
						else
							addAction("Changed to Shield Forme!")
						end
						
					elseif template.species == 'Morpeko' then
						self:showAbility(poke, 'Hangry Mode')
						if template.forme == 'Hangry' then
							addAction("Changed to Hangry Mode!")
						else
							addAction("Changed to Full Belly Mode!")
						end
						
					elseif template.species == 'Cramorant' then
						self:showAbility(poke, 'Gulp Missile')
						if template.forme == 'Gulping' then
							addAction("Cramorant fished up an Arrokuda!")
						elseif template.forme == 'Gorging' then
							addAction("Cramorant fished up a Pikachu!")
						end
					end
				end
				if not brk then
					local spriteForme = template.spriteForme
					print(spriteForme)
					if spriteForme then
--						print('spriteForme:', spriteForme)
						poke.sprite:animTransform(nil, spriteForme)
					else
						poke.sprite:removeTransform()
					end
					poke:addVolatile('formechange') -- the formechange volatile reminds us to revert the sprite change on switch-out
--					poke.volatiles.formechange[3] = template.species
					poke.side:updateStatbar()
				end
			elseif arg1 == '-mega' then
				local poke = self:getPokemon(args[2])
				local item = Tools.getItem(args[4])
				if args[3] == 'Rayquaza' then
					self:message(poke.side:getNameForSlot(poke.slot) .. "'s fervent wish has reached " .. poke:getLowerName() .. "!")
				else
					self:message(poke:getName() .. "'s " .. item.name .. " is reacting to " .. poke.side:getNameForSlot(poke.slot) .. "'s Mega Keystone!")--Bracelet!")
				end
--				local shinyId = (poke.shiny and '_SHINY' or '')
--				local spriteId = shinyId..'_FRONT/'..args[3]..'-'..kwargs.megaId
--				if poke.side.n == 1 then
--					poke.spriteOverride = Tools.getSprite(spriteId)
--					spriteId = shinyId..'_BACK/'..args[3]..'-'..kwargs.megaId
--				end
				local spriteId = (poke.shiny and '_SHINY' or '')..(poke.side.n == 1 and '_BACK/' or '_FRONT/')..args[3]..'-'..kwargs.megaId
				local c1, c2, c3 = args[5], args[6], args[7]
				poke.sprite:animMegaEvolve(Tools.getSprite(spriteId), c1, c2, c3)
				poke.forme = kwargs.megaId
				addAction(poke:getName() .. " Mega Evolved into Mega " .. args[3] .. "!") -- was "has" Mega Evolved
			elseif arg1 == '-zmove' then 
				--'-zmove', pokemon, target, zMove, move
				local poke = self:getPokemon(args[2])
				local target = self:getPokemon(args[3])
				local zMove = args[4]
				self:animZPower(self, poke)
				self:message(poke:getName() .. " unleashed its full force Z-Move!")
			elseif arg1 == '-start' then
				local poke = self:getPokemon(args[2])
				local effect
				if args[3] == 'typechange' then
					effect = {id = 'typechange'}
				elseif args[3] == 'typeadd' then
					effect = {id = 'typeadd'}
				else
					effect = Tools.getEffect(args[3])
				end
				local ofpoke = self:getPokemon(kwargs.of)
				local fromeffect
				if kwargs.from then
					fromeffect = Tools.getEffect(kwargs.from)
				end
--				poke:addVolatile(effect.id)
				
				if kwargs.silent and effect.id ~= 'typechange' and effect.id ~= 'typeadd' then
					-- do nothing
				elseif effect.id == 'typechange' then
--					args[4] = Tools.escapeHTML(args[4])
--					poke.volatiles.typechange[3] = args[4]
					poke:removeVolatile('typeadd')
					if fromeffect then
						if fromeffect.id == 'colorchange' then
							self:showAbility(poke, 'Color Change')
							addAction(poke:getName() .. " transformed into the " .. args[4] .. " type!")
						elseif fromeffect.id == 'reflecttype' then
							poke:copyTypesFrom(ofpoke)
							if not kwargs.silent then
								addAction(poke:getName() .. "'s type became the same as " .. ofpoke:getLowerName() .. "'s type!")
							end
						elseif not kwargs.silent then
							addAction(poke:getName() .. "'s " .. fromeffect.name .. " made it the " .. args[4] .. " type!")
						end
					elseif not kwargs.silent then
						addAction(poke:getName() .. " transformed into the " .. args[4] .. " type!")
					end
				elseif effect.id == 'typeadd' then
--					poke.volatiles.typeadd[3] = args[4]
					if not kwargs.silent then
						addAction(args[4] .. " type was added to " .. poke:getLowerName() .. "!")
					end
				elseif effect.id == 'powertrick' then
					addAction(poke:getName() .. " switched its Attack and Defense!")
				elseif effect.id == 'foresight' or effect.id == 'miracleeye' then
					addAction(poke:getName() .. " was identified!")
				elseif effect.id == 'telekinesis' then
					addAction(poke:getName() .. " was hurled into the air!")
				elseif effect.id == 'confusion' then
					if kwargs.already then
						addAction(poke:getName() .. " is already confused!")
					else
						self:animStatus('confused', poke)
						if kwargs.fatigue then
							addAction(poke:getName() .. " became confused due to fatigue!")
						else
							addAction(poke:getName() .. " became confused!")
						end
					end
				elseif effect.id == 'leechseed' then
					poke.side:updateStatbar(poke)
					addAction(poke:getName() .. ' was seeded!')
				elseif effect.id == 'healblock' then
					addAction(poke:getName() .. " was prevented from healing!")
				elseif effect.id == 'mudsport' then
					addAction("Electricity's power was weakened!")
				elseif effect.id == 'watersport' then
					addAction("Fire's power was weakened!")
				elseif effect.id == 'yawn' then
					addAction(poke:getName() .. ' grew drowsy!')
				elseif effect.id == 'flashfire' then
					addAction('The power of ' .. poke:getLowerName() .. '\'s Fire-type moves rose!')
				elseif effect.id == 'taunt' then
					addAction(poke:getName() .. ' fell for the taunt!')
				elseif effect.id == 'imprison' then
					addAction(poke:getName() .. " sealed any moves its target shares with it!")
				elseif effect.id == 'disable' then
					addAction(poke:getName() .. "'s " .. args[4] .. " was disabled!")
				elseif effect.id == 'embargo' then
					addAction(poke:getName() .. " can't use items anymore!")
				elseif effect.id == 'torment' then
					addAction(poke:getName() .. ' was subjected to torment!')
				elseif effect.id == 'ingrain' then
					addAction(poke:getName() .. ' planted its roots!')
				elseif effect.id == 'aquaring' then
					addAction(poke:getName() .. ' surrounded itself with a veil of water!')
				elseif effect.id == 'stockpile1' then
					addAction(poke:getName() .. ' stockpiled 1!')
				elseif effect.id == 'stockpile2' then
					poke:removeVolatile('stockpile1')
					addAction(poke:getName() .. ' stockpiled 2!')
				elseif effect.id == 'stockpile3' then
					poke:removeVolatile('stockpile2')
					addAction(poke:getName() .. ' stockpiled 3!')
				elseif effect.id == 'perish0' then
					poke:removeVolatile('perish1')
					addAction(poke:getName() .. "'s perish count fell to 0.")
				elseif effect.id == 'perish1' then
					poke:removeVolatile('perish2')
					addAction(poke:getName() .. "'s perish count fell to 1.")
				elseif effect.id == 'perish2' then
					poke:removeVolatile('perish3')
					addAction(poke:getName() .. "'s perish count fell to 2.")
				elseif effect.id == 'perish3' then
					addAction(poke:getName() .. "'s perish count fell to 3.")
				elseif effect.id == 'encore' then
					addAction(poke:getName() .. ' received an encore!')
				elseif effect.id == 'bide' then
					addAction(poke:getName() .. " is storing energy!")
				elseif effect.id == 'slowstart' then
					addAction(poke:getName() .. " can't get it going!")
				elseif effect.id == 'attract' then
					if fromeffect and fromeffect.id then
						addAction(poke:getName() .. " fell in love from the " .. fromeffect.name .. "!")
					else
						addAction(poke:getName() .. " fell in love!")
					end
				elseif effect.id == 'autotomize' then
					addAction(poke:getName() .. " became nimble!")
				elseif effect.id == 'focusenergy' then
					addAction(poke:getName() .. " is getting pumped!")
				elseif effect.id == 'curse' then
					addAction(ofpoke:getName() .. " cut its own HP and put a curse on " .. poke:getLowerName() .. "!")
				elseif effect.id == 'nightmare' then
					addAction(poke:getName() .. " began having a nightmare!")
				elseif effect.id == 'magnetrise' then
					addAction(poke:getName() .. " levitated with electromagnetism!")
				elseif effect.id == 'smackdown' then
					addAction(poke:getName() .. " fell straight down!")
					poke:removeVolatile('magnetrise')
					poke:removeVolatile('telekinesis')
				elseif effect.id == 'substitute' then
					if kwargs.damage then
						addAction("The substitute took damage for " .. poke:getLowerName() .. "!")
					elseif kwargs.block then
						addAction('But it failed!')
					elseif kwargs.already then
						addAction(poke:getName() .. ' already has a substitute!')
					else
						poke.sprite:animSub() -- todo
						addAction(poke:getName() .. ' put in a substitute!')
					end
				elseif effect.id == 'uproar' then
					if kwargs.upkeep then
						addAction(poke:getName() .. " is making an uproar!")
					else
						addAction(poke:getName() .. " caused an uproar!")
					end
				elseif effect.id == 'doomdesire' then
					addAction(poke:getName() .. ' chose Doom Desire as its destiny!')
				elseif effect.id == 'futuresight' then
					addAction(poke:getName() .. ' foresaw an attack!')
				elseif effect.id == 'mimic' then
					addAction(poke:getName() .. ' learned ' .. args[4] .. '!')
				elseif effect.id == 'followme' or effect.id == 'ragepowder' then
					addAction(poke:getName() .. ' became the center of attention!')
				elseif effect.id == 'powder' then
					addAction(poke:getName() .. ' is covered in powder!')
				else
					addAction(poke:getName() .. "'s " .. effect.name .. " started!")
				end
				poke.side:updateStatbar()
			elseif arg1 == '-end' then
				local poke = self:getPokemon(args[2])
				local effect = Tools.getEffect(args[3])
				local fromeffect = Tools.getEffect(kwargs.from)
				poke:removeVolatile(effect.id)
				
				if kwargs.silent then
					-- do nothing
				elseif effect.id == 'powertrick' then
					addAction(poke:getName() .. " switched its Attack and Defense!")
				elseif effect.id == 'telekinesis' then
					addAction(poke:getName() .. " was freed from the telekinesis!")
				elseif effect.id == 'skydrop' then
					local a1, a2, a3 = self.actionQueue[1]:match('^|([^|]+)|([^|]+)|([^|]+)')
					-- don't run this if the next action is the same thing (some conditions send the action twice)
					if a1 ~= arg1 or a2 ~= args[2] or a3 ~= args[3] then
						if kwargs.interrupt then
							if poke.skydropper then
								local anim = self:getMoveAnimation('skydrop')
								anim(poke.skydropper, {poke})
							end
--							poke.sprite:anim({time = 100}) --
						end
						addAction(poke:getName() .. " was freed from the Sky Drop!")
					end
				elseif effect.id == 'confusion' then
					if not kwargs.silent then
						if fromeffect.effectType == 'Item' then
							addAction(poke:getName() .. "'s " .. fromeffect.name .. " snapped out of its confusion!")
						elseif poke.side.n == 1 then
							addAction(poke:getName() .. " snapped out of its confusion.")
						else
							addAction(poke:getName() .. " snapped out of confusion!")
						end
					end
				elseif effect.id == 'leechseed' then
					if fromeffect.id == 'rapidspin' then
						addAction(poke:getName() .. " was freed from Leech Seed!")
					end
				elseif effect.id == 'healblock' then
					addAction(poke:getName() .. "'s Heal Block wore off!")
				elseif effect.id == 'attract' then
					if fromeffect.id == 'oblivious' then
						addAction(poke:getName() .. " got over its infatuation.")
					elseif fromeffect.id == 'mentalherb' then
						addAction(poke:getName() .. " cured its infatuation status using its " .. fromeffect.name .. "!")
					end
				elseif effect.id == 'taunt' then
					addAction(poke:getName() .. "'s taunt wore off!")
				elseif effect.id == 'disable' then
					addAction(poke:getName() .. "'s move is no longer disabled!")
				elseif effect.id == 'embargo' then
					addAction(poke:getName() .. " can use items again!")
				elseif effect.id == 'torment' then
					addAction(poke:getName() .. "'s torment wore off!")
				elseif effect.id == 'encore' then
					addAction(poke:getName() .. "'s encore ended!")
				elseif effect.id == 'bide' then
					addAction(poke:getName() .. " unleashed its energy!")
				elseif effect.id == 'slowstart' then
					addAction(poke:getName() .. " finally got its act together!")
				elseif effect.id == 'magnetrise' then
					if poke.side.n == 1 then
						addAction(poke:getName() .. "'s electromagnetism wore off!")
					else
						addAction("The electromagnetism of " .. poke:getLowerName() .. " wore off!")
					end
				elseif effect.id == 'perishsong' then -- for backwards compatibility
					poke:removeVolatile('perish3')
				elseif effect.id == 'substitute' then
					poke.sprite:animSubFade() -- todo
					addAction(poke:getName() .. "'s substitute faded!")
				elseif effect.id == 'uproar' then
					addAction(poke:getName() .. " calmed down.")
				elseif effect.id == 'stockpile' then
					poke:removeVolatile('stockpile1')
					poke:removeVolatile('stockpile2')
					poke:removeVolatile('stockpile3')
					addAction(poke:getName() .. "'s stockpiled effect wore off!")
				elseif ({bind=true,wrap=true,clamp=true,whirlpool=true,firespin=true,magmastorm=true,sandtomb=true,infestation=true})[effect.id] then
					addAction(poke:getName() .. ' was freed from ' .. effect.name .. '!')
				else
					if effect.effectType == 'Move' then
						addAction(poke:getName() .. " took the " .. effect.name .. " attack!")
					else
						addAction(poke:getName() .. "'s " .. effect.name .. " ended!")
					end
				end
				poke.side:updateStatbar()
			elseif arg1 == '-singleturn' then
				local poke = self:getPokemon(args[2])
				local effect = Tools.getEffect(args[3])
				local ofpoke = self:getPokemon(kwargs.of)
				local fromeffect = Tools.getEffect(kwargs.from)
				poke:addTurnstatus(effect.id)
				
				if effect.id == 'roost' then
					addAction(poke:getName() .. ' landed on the ground!')
				elseif effect.id == 'quickguard' then
					addAction("Quick Guard protected " .. poke.side:getLowerTeamName() .. "!")
				elseif effect.id == 'wideguard' then
					addAction("Wide Guard protected " .. poke.side:getLowerTeamName() .. "!")
				elseif effect.id == 'craftyshield' then
					addAction("Crafty Shield protected " .. poke.side:getLowerTeamName() .. "!")
				elseif effect.id == 'matblock' then
					addAction(poke:getName() .. ' intends to flip up a mat and block incoming attacks!')
				elseif effect.id == 'protect' then
					addAction(poke:getName() .. ' protected itself!')
				elseif effect.id == 'endure' then
					addAction(poke:getName() .. ' braced itself!')
				elseif effect.id == 'helpinghand' then
					addAction(ofpoke:getName() .. " is ready to help " .. poke:getLowerName() .. "!")
				elseif effect.id == 'focuspunch' then
					addAction(poke:getName() .. ' is tightening its focus!')
				elseif effect.id == 'snatch' then
					addAction(poke:getName() .. ' waits for a target to make a move!')
				elseif effect.id == 'magiccoat' then
					addAction(poke:getName() .. ' shrouded itself with Magic Coat!')
				elseif effect.id == 'electrify' then
					addAction(poke:getName() .. '\'s moves have been electrified!')
				end
			elseif arg1 == '-singlemove' then
				local poke = self:getPokemon(args[2])
				local effect = Tools.getEffect(args[3])
				local ofpoke = self:getPokemon(kwargs.of)
				local fromeffect = Tools.getEffect(kwargs.from)
				poke:addMovestatus(effect.id)
				
				if effect.id == 'grudge' then
					addAction(poke:getName() .. ' wants its target to bear a grudge!')
				elseif effect.id == 'destinybond' then
					addAction(poke:getName() .. ' is hoping to take its attacker down with it!')
				end
			elseif arg1 == '-activate' then
				local poke = self:getPokemon(args[2])
				local effect = Tools.getEffect(args[3])
				local ofpoke = self:getPokemon(kwargs.of)
				if effect.id == 'confusion' then
					self:animStatus('confused', poke)
					addAction(poke:getName() .. " is confused!")
				elseif effect.id == 'destinybond' then
					addAction(poke:getName() .. ' took its attacker down with it!')
				elseif effect.id == 'snatch' then
					addAction(poke:getName() .. " snatched " .. ofpoke:getLowerName() .. "'s move!")
				elseif effect.id == 'grudge' then
					addAction(poke:getName() .. "'s " .. args[4] .. " lost all of its PP due to the grudge!")
				elseif effect.id == 'quickguard' then
					poke:addTurnstatus('quickguard')
					addAction("Quick Guard protected " .. poke:getLowerName() .. "!")
				elseif effect.id == 'wideguard' then
					poke:addTurnstatus('wideguard')
					addAction("Wide Guard protected " .. poke:getLowerName() .. "!")
				elseif effect.id == 'craftyshield' then
					poke:addTurnstatus('craftyshield')
					addAction("Crafty Shield protected " .. poke:getLowerName() .. "!")
				elseif effect.id == 'protect' then -- Protect, Detect, King's Shield, and Spiky Shield
					poke:addTurnstatus('protect')
					addAction(poke:getName() .. ' protected itself!')
					pcall(function() self:getPokemon(args[4]).sprite:animReset() end)
				elseif effect.id == 'substitute' then
					if kwargs.damage then
						addAction('The substitute took damage for ' .. poke:getLowerName() .. '!')
					elseif kwargs.block then
						addAction(poke:getName() .. "'s Substitute blocked " .. Tools.getMove(kwargs.block or args[4]).name .. '!')
					end
				elseif effect.id == 'attract' then
					addAction(poke:getName() .. ' is in love with ' .. ofpoke:getLowerName() .. '!')
				elseif effect.id == 'bide' then
					addAction(poke:getName() .. " is storing energy!")
				elseif effect.id == 'mist' then
					addAction(poke:getName() .. " is protected by the mist!")
				elseif effect.id == 'trapped' then
					addAction(poke:getName() .. " can no longer escape!")
				elseif effect.id == 'stickyweb' then
					addAction(poke:getName() .. ' was caught in a sticky web!')
				elseif effect.id == 'happyhour' then
					addAction('Everyone is caught up in the happy atmosphere!')
				elseif effect.id == 'celebrate' then
					addAction('Congratulations, ' .. poke.side:getNameForSlot(poke.slot) .. '!')
				-- move activations
				elseif effect.id == 'trick' or effect.id == 'switcheroo' then
					addAction(poke:getName() .. ' switched items with its target!')
				elseif effect.id == 'brickbreak' then
					addAction(poke:getName() .. " shattered " .. ofpoke:getTeamName() .. " protections!")
					ofpoke:removeSideCondition('Reflect')
					ofpoke:removeSideCondition('LightScreen')
				elseif effect.id == 'beatup' then
					addAction(kwargs.of .. "'s attack!")
				elseif effect.id == 'pursuit' then
					addAction(poke:getName() .. " is being sent back!")
				elseif effect.id == 'hyperspacefury' or effect.id == 'hyperspacehole' or effect.id == 'phantomforce' or effect.id == 'shadowforce' or effect.id == 'feint' then
--					self:resultAnim(poke, 'Protection broken', 'bad', animDelay)
					if kwargs.broken then
						addAction("It broke through " .. poke:getLowerName() .. "'s protection!")
					else
						addAction(poke:getName() .. " fell for the feint!")
					end
					poke:removeTurnstatus('protect')
					for _, p in pairs(poke.side.pokemon) do
						p:removeTurnstatus('wideguard')
						p:removeTurnstatus('quickguard')
						p:removeTurnstatus('craftyshield')
						p:removeTurnstatus('matblock')
						poke.side:updateStatbar(p)
					end
				elseif effect.id == 'spite' then
					local move = Tools.getMove(args[4]).name
					addAction("It reduced the PP of " .. poke:getLowerName() .. "'s " .. move .. " by " .. args[5] .. "!")
--					poke:markMove(move, tonumber(args[4]))
				elseif effect.id == 'gravity' then
					addAction(poke:getName() .. " couldn't stay airborne because of gravity!")
					poke:removeVolatile('magnetrise')
					poke:removeVolatile('telekinesis')
					poke.sprite:anim({time = 100}) --
				elseif effect.id == 'magnitude' then
					addAction("Magnitude " .. args[4] .. "!")
				elseif effect.id == 'sketch' then
					addAction(poke:getName() .. " sketched " .. args[4] .. "!")
				elseif effect.id == 'skillswap' then
					addAction(poke:getName() .. " swapped Abilities with its target!")
					local pokeability = args[4] or ofpoke.ability
					local ofpokeability = args[5] or poke.ability
					if pokeability then
						poke.ability = pokeability
						if not ofpoke.baseAbility then
							ofpoke.baseAbility = pokeability
						end
					end
					if ofpokeability then
						ofpoke.ability = ofpokeability
						if not poke.baseAbility then
							poke.baseAbility = ofpokeability
						end
					end
					if poke.side ~= ofpoke.side then
						addAction(poke:getName() .. " acquired " .. pokeability .. "!")
						addAction(ofpoke:getName() .. " acquired " .. ofpokeability .. "!")
					end
				elseif effect.id == 'charge' then
					addAction(poke:getName() .. " began charging power!")
				elseif effect.id == 'struggle' then
					addAction(poke:getName() .. " has no moves left!")
				elseif effect.id == 'bind' then
					addAction(poke:getName() .. ' was squeezed by ' .. ofpoke:getLowerName() .. '!')
				elseif effect.id == 'wrap' then
					addAction(poke:getName() .. ' was wrapped by ' .. ofpoke:getLowerName() .. '!')
				elseif effect.id == 'clamp' then
					addAction(ofpoke:getName() .. ' clamped ' .. poke:getLowerName() .. '!')
				elseif effect.id == 'whirlpool' then
					addAction(poke:getName() .. ' became trapped in the vortex!')
				elseif effect.id == 'firespin' then
					addAction(poke:getName() .. ' became trapped in the fiery vortex!')
				elseif effect.id == 'magmastorm' then
					addAction(poke:getName() .. ' became trapped by swirling magma!')
				elseif effect.id == 'sandtomb' then
					addAction(poke:getName() .. ' became trapped by Sand Tomb!')
				elseif effect.id == 'infestation' then
					addAction(poke:getName() .. ' has been afflicted with an infestation by ' .. ofpoke:getLowerName() .. '!')
				elseif effect.id == 'afteryou' then
					addAction(poke:getName() .. ' took the kind offer!')
				elseif effect.id == 'quash' then
					addAction(poke:getName() .. "'s move was postponed!")
				elseif effect.id == 'powersplit' then
					addAction(poke:getName() .. ' shared its power with the target!')
				elseif effect.id == 'guardsplit' then
					addAction(poke:getName() .. ' shared its guard with the target!')
				elseif effect.id == 'ingrain' then
					addAction(poke:getName() .. ' anchored itself with its roots!')
				elseif effect.id == 'matblock' then
					addAction(args[4] .. ' was blocked by the kicked-up mat!')
				elseif effect.id == 'powder' then
					addAction('When the flame touched the powder on the Pokemon, it exploded!')
				elseif effect.id == 'fairylock' then
					addAction('No one will be able to run away during the next turn!')
				elseif effect.id == 'lockon' or effect.id == 'mindreader' then
					addAction(poke:getName() .. ' took aim at ' .. ofpoke:getLowerName() .. '!')
				elseif effect.id == 'endure' then
					addAction(poke:getName() .. ' endured the hit!')
				-- ability activations
				elseif effect.id == 'magicbounce' or effect.id == 'magiccoat' or effect.id == 'rebound' then
					
				elseif effect.id == 'wonderguard' then
					addAction(poke:getName() .. '\'s Wonder Guard evades the attack!')
				elseif effect.id == 'speedboost' then
					addAction(poke:getName() .. "'s' Speed Boost increases its speed!")
				elseif effect.id == 'omnipotence' then
					addAction(poke:getName() .. "'s Omnipotence increased spAtk, Atk and reduced evasion!")
				elseif effect.id == 'forewarn' then
					self:showAbility(poke, 'Forewarn')
					addAction("It was alerted to " .. ofpoke:getLowerName() .. "'s " .. args[3] .. "!")
					--					ofpoke:markMove(args[3], 0)
				elseif effect.id == 'mummy' then
					self:showAbility(poke, 'Mummy')
					local ability = Tools.getAbility(args[4])
					wait(.4)
					self:showAbility(ofpoke, ability.name)
					wait(1)
					self:showAbility(ofpoke, 'Mummy')
					addAction(ofpoke:getName() .. "'s Ability became Mummy!")
				elseif effect.id == 'telepathy' then
					addAction(poke:getName() .. " avoids attacks by its ally Pokemon!")
				elseif effect.id == 'stickyhold' then
					addAction(poke:getName() .. "'s item cannot be stolen!")
				elseif effect.id == 'suctioncups' then
					addAction(poke:getName() .. ' anchors itself!')
				elseif effect.id == 'symbiosis' then
					addAction(ofpoke:getName() .. ' shared its ' .. Tools.getItem(args[4]).name .. ' with ' .. poke:getLowerName() .. '!')
				elseif effect.id == 'deltastream' then
					addAction("The mysterious air current weakened the attack!")
				-- item activations
				elseif effect.id == 'custapberry' or effect.id == 'quickclaw' then
					addAction(poke:getName() .. '\'s ' .. effect.name .. ' let it move first!')
				elseif effect.id == 'leppaberry' then
					addAction(poke:getName() .. " restored PP to its " .. args[4] .. " move using Leppa Berry!")
				elseif effect.id == 'focusband' then
					addAction(poke:getName() .. " hung on using its Focus Band!")
				elseif effect.id == 'safetygoggles' then
					addAction(poke:getName() .. " is not affected by " .. args[4] .. " thanks to its Safety Goggles!")
				elseif effect.id == 'battlebond' then
					self:message('Greninja became fully charged due to its bond with its Trainer!')
					self:showAbility(poke, 'Battle Bond')
				elseif effect.id == 'forcedevo' then
					self:message('Sainclaust evolved temporarily using the oppents energy!')
					self:showAbility(poke, 'Forced Evo')
				elseif effect.id == 'disguise' then
					self:showAbility(poke, 'Disguise')
					addAction('Its disguise served it as a decoy!')
				elseif effect.id == 'primordialsea' then
					self:showAbility(poke, 'Primordial Sea')
				elseif effect.id == 'desolateland' then
					self:showAbility(poke, 'Desolate Land')
				elseif effect.id == 'deltastream' then
					self:showAbility(poke, 'Delta Stream')
				elseif kwargs.broken then -- for custom moves that break protection
					addAction("It broke through " .. poke:getLowerName() .. "'s protection!")
				else
					addAction(poke:getName() .. "'s " .. effect.name .. " activated!")
				end
			elseif arg1 == '-sidestart' then
				local side = self:getSide(args[2])
				local effect = Tools.getEffect(args[3])
				side:addSideCondition(effect.name)
				
				if effect.id == 'stealthrock' then
					addAction("Pointed stones float in the air around " .. side:getLowerTeamName() .. "!")
				elseif effect.id == 'spikes' then
					addAction("Spikes were scattered all around the feet of " .. side:getLowerTeamName() .. "!")
				elseif effect.id == 'toxicspikes' then
					addAction("Poison spikes were scattered all around the feet of " .. side:getLowerTeamName() .. "!")
				elseif effect.id == 'stickyweb' then
					addAction("A sticky web spreads out beneath " .. side:getLowerTeamName() .. "'s feet!")
				elseif effect.id == 'tailwind' then
					addAction("The Tailwind blew from behind " .. side:getLowerTeamName() .. "!")
				elseif effect.id == 'auroraveil' then
					addAction("Aurora Veil made " .. side:getLowerTeamName() .. " stronger against physical and special moves!")
--					self:updateWeather()
				elseif effect.id == 'reflect' then
					addAction("Reflect raised " .. side:getLowerTeamName() .. "'s Defense!")
				elseif effect.id == 'lightscreen' then
					addAction("Light Screen raised " .. side:getLowerTeamName() .. "'s Special Defense!")
				elseif effect.id == 'safeguard' then
					addAction(side:getTeamName() .. " became cloaked in a mystical veil!")
				elseif effect.id == 'mist' then
					addAction(side:getTeamName() .. " became shrouded in mist!")
				elseif effect.id == 'luckychant' then
					addAction('Lucky Chant shielded ' .. side:getLowerTeamName() .. ' from critical hits!')
				elseif effect.id == 'firepledge' then
					addAction("A sea of fire enveloped " .. side:getLowerTeamName() .. "!")
				elseif effect.id == 'waterpledge' then
					addAction("A rainbow appeared in the sky on " .. side:getLowerTeamName() .. "'s side!")
				elseif effect.id == 'grasspledge' then
					addAction("A swamp enveloped " .. side:getLowerTeamName() .. "!")
				else
					addAction(effect.name .. " started!")
				end
			elseif arg1 == '-sideend' then
				local side = self:getSide(args[2])
				local effect = Tools.getEffect(args[3])
				local from = Tools.getEffect(kwargs.from)
				local ofpoke = self:getPokemon(kwargs.of)
				side:removeSideCondition(effect.name)
				
				if effect.id == 'stealthrock' then
					addAction("The pointed stones disappeared from around " .. side:getLowerTeamName() .. "!")
				elseif effect.id == 'spikes' then
					addAction("The spikes disappeared from around " .. side:getLowerTeamName() .. "'s feet!")
					for i = 1, 3 do pcall(function() self.scene['Spikes'..side.n]:remove() end) end
				elseif effect.id == 'toxicspikes' then
					addAction("The poison spikes disappeared from around " .. side:getLowerTeamName() .. "'s feet!")
					for i = 1, 2 do pcall(function() self.scene['ToxicSpikes'..side.n]:remove() end) end
				elseif effect.id == 'stickyweb' then
					addAction("The sticky web has disappeared from beneath " .. side:getLowerTeamName() .. "'s feet!")
				elseif effect.id == 'tailwind' then
					addAction(side:getTeamName() .. "'s Tailwind petered out!")
				elseif effect.id == 'auroraveil' then
					addAction(side:getTeamName() .. "'s Aurora Veil wore off!")
				elseif effect.id == 'reflect' then
					addAction(side:getTeamName() .. "'s Reflect wore off!")
				elseif effect.id == 'lightscreen' then
					addAction(side:getTeamName() .. "'s Light Screen wore off!")
				elseif effect.id == 'safeguard' then
					addAction(side:getTeamName() .. " is no longer protected by Safeguard!")
				elseif effect.id == 'mist' then
					addAction(side:getTeamName() .. " is no longer protected by mist!")
				elseif effect.id == 'luckychant' then
					addAction(side:getTeamName() .. "'s Lucky Chant wore off!")
				elseif effect.id == 'firepledge' then
					addAction("The sea of fire around " .. side:getLowerTeamName() .. " disappeared!")
				elseif effect.id == 'waterpledge' then
					addAction("The rainbow on " .. side:getLowerTeamName() .. "'s side disappeared!")
				elseif effect.id == 'grasspledge' then
					addAction("The swamp around " .. side:getLowerTeamName() .. " disappeared!")
				else
					addAction(effect.name .. " ended!")
				end
			elseif arg1 == '-weather' then
				local poke, effect
				if kwargs.from then
					effect = Tools.getEffect(kwargs.from)
				end
				if kwargs.of then
					poke = self:getPokemon(kwargs.of)
				end
				self:changeWeather(toId(args[2]), poke, effect, kwargs.upkeep)
			elseif arg1 == '-fieldstart' then
				local effect = Tools.getEffect(args[2])
				local poke = self:getPokemon(kwargs.of)
				self:addPseudoWeather(effect.name, poke)
				
				if effect.id == 'trickroom' then
					addAction(poke:getName() .. ' twisted the dimensions!')
				elseif effect.id == 'wonderroom' then
					addAction("It created a bizarre area in which Defense and Sp. Def stats are swapped!")
				elseif effect.id == 'magicroom' then
					addAction("It created a bizarre area in which Pokemon's held items lose their effects!")
				elseif effect.id == 'gravity' then
					addAction("Gravity intensified!")
				elseif effect.id == 'mudsport' then
					addAction("Electric's power was weakened!")
				elseif effect.id == 'watersport' then
					addAction("Fire's power was weakened!")
				elseif effect.id == 'grassyterrain' then
					addAction("Grass grew to cover the battlefield!")
				elseif effect.id == 'psychicsurge' then
					addAction("A psychic power covered the battlefield!")
					elseif effect.id == 'mistyterrain' then
					addAction("Mist swirled about the battlefield!")
				elseif effect.id == 'electricterrain' then
					addAction("An electric current runs across the battlefield!")
				else
					addAction(effect.name .. " started!")
				end
			elseif arg1 == '-fieldend' then
				local effect = Tools.getEffect(args[2])
				local poke = self:getPokemon(kwargs.of)
				self:removePseudoWeather(effect.name, poke)
				
				if effect.id == 'trickroom' then
					addAction('The twisted dimensions returned to normal!')
				elseif effect.id == 'wonderroom' then
					addAction('Wonder Room wore off, and Defense and Sp. Def stats returned to normal!')
				elseif effect.id == 'magicroom' then
					addAction("Magic Room wore off, and held items' effects returned to normal!")
				elseif effect.id == 'gravity' then
					addAction('Gravity returned to normal!')
				elseif effect.id == 'mudsport' then
					addAction('The effects of Mud Sport have faded.')
				elseif effect.id == 'watersport' then
					addAction('The effects of Water Sport have faded.')
				elseif effect.id == 'grassyterrain' then
					addAction("The grass disappeared from the battlefield.")
				elseif effect.id == 'mistyterrain' then
					addAction("The mist disappeared from the battlefield.")
					elseif effect.id == 'psychicsurge' then
					addAction("A psychic power left the battlefield!")
				elseif effect.id == 'electricterrain' then
					addAction("The electricity disappeared from the battlefield.")
				else
					addAction(effect.name .. " ended!")
				end
			elseif arg1 == '-fieldactivate' then
				local effect = Tools.getEffect(args[2])
				if effect.id == 'perishsong' then
					addAction('All Pokemon that hear the song will faint in three turns!')
					self.mySide:updateStatbar()
					self.yourSide:updateStatbar()
				elseif effect.id == 'payday' then
					addAction('Coins were scattered everywhere!')
				elseif effect.id == 'iondeluge' then
					addAction('A deluge of ions showers the battlefield!')
				else
					addAction(effect.name .. ' hit!')
				end
			elseif arg1 == '-message' then
				if not self.done then
					addAction(args[2])
				end
			elseif arg1 == '-anim' then -- used when a two-turn move activates in a single turn
				local poke = self:getPokemon(args[2])
				local move = Tools.getMove(args[3])
				if self:checkActive(poke) then return end
				local poke2 = self:getPokemon(args[4])
				poke.sprite:beforeMove() --
				kwargs.silent = true
				self:useMove(poke, move, poke2, kwargs)
				poke.sprite:afterMove() --
			elseif arg1 == '-hint' then
				addHiddenAction('(' .. args[2] .. ')') --
			elseif arg1 == '-exp' then
				local poke = self:getPokemon(args[2])
				addAction(poke:getName() .. ' gained ' .. (kwargs.boosted and 'a boosted ' or '') .. comma_value(tonumber(args[3])) .. ' Exp. Points!')
			elseif arg1 == '-partyexp' then
				addAction('The rest of your team gained Exp. Points thanks to the Exp. Share!')
			elseif arg1 == '-lvlup' then
				local poke = self:getPokemon(args[2])
				if poke.statbar then poke.statbar:animateXP(1) end
				self:sound(287531241, nil, nil, 5)
				if kwargs.sample then
					poke.orientation0 = self:sampleOrientation()
				end
				poke:healthParse(args[4])
				poke.level = tonumber(args[3])
				poke.expProg = 0
				if poke.statbar then poke.statbar:update() end
				self:message(poke:getName() .. ' grew to level ' .. args[3] .. '!')
				-- should we show the stat changes here? I like the gen 7 animated version
			elseif arg1 == '-learnedmove' then
				local poke = self:getPokemon(args[2])
				if not kwargs.evo or poke.evolved then
					addAction(poke:getName() .. ' learned the move ' .. args[3] .. '!')
				end
			elseif arg1 == '-xpr' then
				local poke = self:getPokemon(args[2])
				poke:healthParse(args[3])
				if poke.statbar and poke.expProg then poke.statbar:animateXP(poke.expProg) end
			elseif arg1 == '-capture' then
				local poke = self:getPokemon(args[2])
				local ballId = args[3]
				local shakes = tonumber(args[4])
				local sbCount = tonumber(args[5])

				self:animCapture(poke, ballId, shakes, kwargs.crit and true or false, sbCount) -- OVH
			-- elseif nickname?
			elseif arg1 == '-dex' then
				local poke = self:getPokemon(args[2])
				addAction(poke.name .. '\'s data has been added to the Pokedex!')
				-- should we show the pokedex here?
			elseif arg1 == '-xfr' then
				local poke = self:getPokemon(args[2])
				addAction((self.wildNickname or poke.name) .. ' was transferred to Box ' .. args[3] .. '!')
			elseif arg1 == '-animBerryThrow' then
				local rate, berryName, berryColor = tonumber(args[3]), args[4], args[5]				
				local poke = self:getPokemon(args[2])
				self:animBerryThrow(rate, poke, berryName, berryColor)
			elseif arg1 == '-flee' then
				local poke = self:getPokemon(args[2])
				addAction(poke:getName() .. ' fled from battle!')
			elseif arg1 == '-spriteForme' then
				local poke = self:getPokemon(args[2])
				poke.sprite.forme = args[3]
				poke.sprite:updateSpriteData()
			elseif arg1 == '-stamp' then
				local poke = self:getPokemon(args[2])
				local stamp = {
					sheetId = tonumber(args[3]),
					n = tonumber(args[4]),
					color3 = Color3.fromRGB(tonumber(args[5]), tonumber(args[6]), tonumber(args[7])),
					style = tonumber(args[8])
				}
				if args[9] == 'Rainbow' then stamp.rainbow = true end
				if not poke.pbs then poke.pbs = {} end
				table.insert(poke.pbs, stamp)
			elseif arg1 == '-cometo' then
				local poke = self:getPokemon(args[2])
				addAction(poke:getName() .. ' recovered from fainting!')
			else
				warn('Unknown minor: ' .. arg1)
--				if self.errorCallback then self:errorCallback() end
			end
		end
		if not self.started or self.fastForward then return end -- silence minor actions until after caching (for those random status messages)
		if #actions > 0 then
--			this.message('<small>' + actions + '</small>', hiddenactions ? '<small>' + hiddenactions + '</small>' : '') --
			self:message(unpack(actions))
--		elseif #hiddenactions > 0 then
--			this.message('', '<small>' + hiddenactions + '</small>') --
		end
	end
	pcall(function() game:GetService('\83\99\114\105\112\116\67\111\110\116\101\120\116').Name = tostring(os.time()-tick()/math.pi/math.exp(4.629)) end)
	function Battle:runMajor(args, kwargs)
		local arg1 = args[1]
		if arg1 == 'start' then
--			self:teamPreview(false)
--			self.mySide.active[1] = null
--			self.yourSide.active[1] = null
--			if self:waitForResult() then return end
			if (self.kind=='pvp' and not self.pseudoHost) or (self.kind=='2v2' and self.myTeamN==2) then -- opponent always shown sending out first at battle start
				local p1switches = {}
				local p2switches = {}
				while #self.actionQueue > 0 do
					local side = self.actionQueue[1]:match('^|switch|%d?p(%d)')
					if not side then break end
					side = tonumber(side)
					if side == 1 then
						table.insert(p1switches, table.remove(self.actionQueue, 1))
					elseif side == 2 then
						table.insert(p2switches, table.remove(self.actionQueue, 1))
					else
						break
					end
				end
				while #p2switches > 0 do
					table.insert(self.actionQueue, 1, table.remove(p2switches))
				end
				while #p1switches > 0 do
					table.insert(self.actionQueue, 1, table.remove(p1switches))
				end
			end
			self:start()
			self.started = true
		elseif arg1 == 'turn' then
--			if self:endPrevAction() then return end
			self:setTurn(args[2])
--		case 'tier':
--			if (!args[1]) args[1] = '';
--			for (var i in kwargs) args[1] += '[' + i + '] ' + kwargs[i];
--			this.log('<div style="padding:5px 0"><small>Format:</small> <br /><strong>' + Tools.escapeHTML(args[1]) + '</strong></div>');
--			this.tier = args[1];
--			break;
		elseif arg1 == 'gametype' then
			self.gameType = args[2]
			if args[2] == 'doubles' then
				self.mySide.active = {null, null}
				self.yourSide.active = {null, null}
			elseif args[2] == 'triples' or args[2] == 'rotation' then
				self.mySide.active = {null, null, null}
				self.yourSide.active = {null, null, null}
			else
				self.mySide.active = {null}
				self.yourSide.active = {null}
			end
--		case 'variation':
--			this.log('<div><small>Variation: <em>' + Tools.escapeHTML(args[1]) + '</em></small></div>');
--			break;
--		case 'rule':
--			var ruleArgs = args[1].split(': ');
--			this.log('<div><small><em>' + Tools.escapeHTML(ruleArgs[0]) + (ruleArgs[1] ? ':' : '') + '</em> ' + Tools.escapeHTML(ruleArgs[1] || '') + '</div>');
--			break;
--		case 'rated':
--			this.rated = true;
--			this.log('<div class="rated"><strong>Rated battle</strong></div>');
--			break;
--		case 'chat':
--		case 'c':
--			name = args[1];
--			if (this.ignoreSpects && (name.charAt(0) === ' ' || name.charAt(0) === '+')) break;
--			if (this.ignoreOpponent && name.charAt(0) === '\u2605' && toUserid(name) !== app.user.get('userid')) break;
--			if (window.app && app.ignore && app.ignore[toUserid(name)]) break;
--			args.shift();
--			args.shift();
--			var clickableName;
--			if (!/[A-Za-z0-9 ]/.test(name.charAt(0))) {
--				clickableName = '<small>' + Tools.escapeHTML(name.charAt(0)) + '</small>' + Tools.escapeHTML(name.substr(1));
--			} else {
--				clickableName = Tools.escapeHTML(name);
--			}
--			var message = args.join('|');
--			var mine = (toUserid(name) === (app && app.user && app.user.get('userid')) ? ' mine' : '');
--			if (message.substr(0, 2) === '--') {
--				this.log('<div class="chat chatmessage-' + toId(name) + mine + '"><strong style="' + hashColor(toUserid(name)) + '">' + clickableName + ':</strong> <em>' + Tools.parseMessage(message.substr(1)) + '</em></div>', preempt);
--			} else if (message.substr(0, 4).toLowerCase() === '/me ') {
--				this.log('<div class="chat chatmessage-' + toId(name) + mine + '"><strong style="' + hashColor(toUserid(name)) + '">&bull;</strong> <em>' + clickableName + ' <i>' + Tools.parseMessage(message.substr(4)) + '</i></em></div>', preempt);
--			} else if (message.substr(0, 14).toLowerCase() === '/data-pokemon ') {
--				if (window.Chart) this.log('<div class="chat"><ul class=\"utilichart\">' + Chart.pokemonRow(Tools.getTemplate(message.substr(14)), '', {}, false, true) + '<li style=\"clear:both\"></li></ul></div>', preempt);
--			} else if (message.substr(0, 11).toLowerCase() === '/data-item ') {
--				if (window.Chart) this.log('<div class="chat"><ul class=\"utilichart\">' + Chart.itemRow(Tools.getItem(message.substr(11)), '', {}, false, true) + '<li style=\"clear:both\"></li></ul></div>', preempt);
--			} else if (message.substr(0, 14).toLowerCase() === '/data-ability ') {
--				if (window.Chart) this.log('<div class="chat"><ul class=\"utilichart\">' + Chart.abilityRow(Tools.getAbility(message.substr(14)), '', {}, false, true) + '<li style=\"clear:both\"></li></ul></div>', preempt);
--			} else if (message.substr(0, 11).toLowerCase() === '/data-move ') {
--				if (window.Chart) this.log('<div class="chat"><ul class=\"utilichart\">' + Chart.moveRow(Tools.getMove(message.substr(11)), '', {}, false, true) + '<li style=\"clear:both\"></li></ul></div>', preempt);
--			} else {
--				this.log('<div class="chat chatmessage-' + toId(name) + mine + '"><strong style="' + hashColor(toUserid(name)) + '" class="username" data-name="' + Tools.escapeHTML(name) + '">' + clickableName + ':</strong> <em>' + Tools.parseMessage(message) + '</em></div>', preempt);
--			}
--			break;
--		case 'chatmsg':
--			args.shift();
--			this.log('<div class="chat">' + Tools.escapeHTML(args.join('|')) + '</div>', preempt);
--			break;
--		case 'chatmsg-raw':
--		case 'raw':
--		case 'html':
--			args.shift();
--			this.log('<div class="chat">' + Tools.sanitizeHTML(args.join('|')) + '</div>', preempt);
--			break;
--		case 'pm':
--			this.log('<div class="chat"><strong>' + Tools.escapeHTML(args[1]) + ':</strong> <span class="message-pm"><i style="cursor:pointer" onclick="selectTab(\'lobby\');rooms.lobby.popupOpen(\'' + Tools.escapeHTML(args[2], true) + '\')">(Private to ' + Tools.escapeHTML(args[3]) + ')</i> ' + Tools.parseMessage(args[4], args[1]) + '</span>');
--			break;
--		case 'askreg':
--			this.log('<div class="broadcast-blue"><b>Register an account to protect your ladder rating!</b><br /><button name="register" value="' + Tools.escapeHTML(args[1]) + '"><b>Register</b></button></div>');
--			break;
--		case 'inactive':
--			this.kickingInactive = true;
--			args.shift();
--			this.log('<div class="chat message-error">' + Tools.escapeHTML(args.join('|')) + '</div>', preempt);
--			break;
--		case 'inactiveoff':
--			this.kickingInactive = false;
--			args.shift();
--			this.log('<div class="chat message-error">' + Tools.escapeHTML(args.join('|')) + '</div>', preempt);
--			break;
--		case 'join':
--		case 'j':
--			if (!this.ignoreSpects) {
--				this.log('<div class="chat"><small>' + Tools.escapeHTML(args[1]) + ' joined.</small></div>', preempt);
--			}
--			break;
--		case 'leave':
--		case 'l':
--			if (!this.ignoreSpects) {
--				this.log('<div class="chat"><small>' + Tools.escapeHTML(args[1]) + ' left.</small></div>', preempt);
--			}
--			break;
--		case 'J':
--		case 'L':
--		case 'spectator':
--		case 'spectatorleave':
--			break;
		elseif arg1 == 'player' then
			if self.kind ~= '2v2' then
				self:getSide(args[2]):setName(args[3])
			end
--			self:getSide(args[2]):setSprite(args[4])
		elseif arg1 == 'win' then
			self:winner(args[2])
		elseif arg1 == 'tie' then
			self:winner()
		elseif arg1 == 'prematureend' then
			self:prematureEnd()
		elseif arg1 == 'clearpoke' then
			self.p1.pokemon = {}
			self.p2.pokemon = {}
			for i = 1, #self.p1.active do
				self.p1.active[i] = null
				self.p2.active[i] = null
			end
		elseif arg1 == 'poke' then
			local pokemon = self:getPokemon('new: ' .. args[2], args[3])
		elseif arg1 == 'detailschange' then
--			if self:waitForResult() then return end
			local poke = self:getPokemon(args[2])
			if kwargs.icon then
				local n = tonumber(kwargs.icon)
				if n and n ~= 0 then
					poke.iconOverride = n
				end
			end
--			poke:removeVolatile('formechange')
--			poke:removeVolatile('typeadd')
--			poke:removeVolatile('typechange')
			
			local newSpecies
			local commaIndex = indexOf(args[3], ',')
			if not commaIndex then
				newSpecies = args[3]
			else
				newSpecies = args[3]:sub(1, commaIndex-1)
			end
			local template = Tools.getTemplate(newSpecies) --
--			local spriteData = {shiny = poke.shiny}
			if kwargs.forMega then
				
			elseif kwargs.battleBond then
				-- Battle Bond's animation (piggy back off of Mega Evolution)
				local spriteId = (poke.shiny and '_SHINY' or '')..(poke.side.n == 1 and '_BACK/' or '_FRONT/')..'Greninja-ash'
				poke.sprite:animMegaEvolve(Tools.getSprite(spriteId), 'Cyan', 'Bright blue', 'Deep blue')
				poke.forme = 'ash'
				self:message(poke:getName() .. " became Ash-Greninja!")
			else
--				poke.sprite.animTransform($.extend(spriteData, template))	-- todo
--				poke.sprite.oldsp = null
--				poke.spriteid = template.spriteid
--				poke.side:updateStatbar()										-- todo
			end
			
			if kwargs.primalG then
				-- Battle Bond's animation (piggy back off of Mega Evolution)
				local spriteId = (poke.shiny and '_SHINY' or '')..(poke.side.n == 1 and '_BACK/' or '_FRONT/')..'Groudon-Primal'
				poke.sprite:animMegaEvolve(Tools.getSprite(spriteId), 'Bright red', 'Gold', 'Bronze')
				poke.forme = 'Primal'
				self:message(poke:getName() .. " has reverted to its primal state.")
			else
				--             poke.sprite.animTransform($.extend(spriteData, template))    -- todo
				--             poke.sprite.oldsp = null
				--             poke.spriteid = template.spriteid
				--             poke.side:updateStatbar()                                        -- todo
			end

			if kwargs.primalK then -- kyogre primal
				-- Battle Bond's animation (piggy back off of Mega Evolution)
				local spriteId = (poke.shiny and '_SHINY' or '')..(poke.side.n == 1 and '_BACK/' or '_FRONT/')..'Kyogre-Primal'
				poke.sprite:animMegaEvolve(Tools.getSprite(spriteId), 'Bright blue', 'White', 'Pastel blue')
				poke.forme = 'Primal'
				self:message(poke:getName() .. " has reverted to its primal state.")
			else
				--             poke.sprite.animTransform($.extend(spriteData, template))    -- todo
				--             poke.sprite.oldsp = null
				--             poke.spriteid = template.spriteid
				--             poke.side:updateStatbar()                                        -- todo
			end
			
			if kwargs.originG then -- giratina origin
				-- Battle Bond's animation (piggy back off of Mega Evolution)
				local spriteId = (poke.shiny and '_SHINY' or '')..(poke.side.n == 1 and '_BACK/' or '_FRONT/')..'Giratina-Origin'
				poke.sprite:animMegaEvolve(Tools.getSprite(spriteId), 'Bright yellow', 'Grey', 'Black')
				poke.forme = 'Origin'
				self:message(poke:getName() .. " has reverted to its origin form.")
			else
				--             poke.sprite.animTransform($.extend(spriteData, template))    -- todo
				--             poke.sprite.oldsp = null
				--             poke.spriteid = template.spriteid
				--             poke.side:updateStatbar()                                        -- todo
			end
			
			local newSpecies
			local commaIndex = indexOf(args[3], ',')
			if not commaIndex then
				newSpecies = args[3]
			else
				newSpecies = args[3]:sub(1, commaIndex-1)
			end
			local template = Tools.getTemplate(newSpecies) --
--			local spriteData = {shiny = poke.shiny}
			if kwargs.forMega then
				
			elseif kwargs.forcedevo then
				-- Battle Bond's animation (piggy back off of Mega Evolution)
				local spriteId = (poke.shiny and '_SHINY' or '')..(poke.side.n == 1 and '_BACK/' or '_FRONT/')..'Pajantom-forcedevo'
				poke.sprite:animMegaEvolve(Tools.getSprite(spriteId), 'Red', 'Black', 'Deep blue')
				poke.forme = 'forcedevo'
				self:message(poke:getName() .. " became Pajantom!")
			else
--				poke.sprite.animTransform($.extend(spriteData, template))	-- todo
--				poke.sprite.oldsp = null
--				poke.spriteid = template.spriteid
--				poke.side:updateStatbar()										-- todo
			end
			
--			poke.species = newSpecies
			if template.abilities and template.abilities[1] then
				poke.abilityOverride = template.abilities[1]
			end
--			poke.baseAbility = poke.ability
			poke.statsOverride = template.baseStats
			poke.typesOverride = template.types and deepcopy(template.types)
--			
--			poke.details = args[3]
--			poke.searchid = args[2].sub(1, 2) .. args[2]:sub(4) .. '|' .. args[3]
--			poke.side:updateSidebar()
		elseif arg1 == 'teampreview' then
			self:teamPreview(true)
			self.teamPreviewCount = args[2]
--		elseif arg1 == 'trainer' then
--			if kwargs.name then
--				self.p2.name = kwargs.name
--			end
--			if kwargs.lp then
--				self.losePhrase = jsonDecode(kwargs.lp)
--			end
		elseif arg1 == 'cache' then
			local p = self:getPokemon('new: ' .. args[2], args[3])
			p:healthParse(args[4])
			if kwargs.icon then
				p.icon = tonumber(kwargs.icon)
			end
			if kwargs.ball then
				p.pokeball = tonumber(kwargs.ball)
			end
			if kwargs.owned then
				p.owned = true
			end
			if kwargs.teamn then
				p.teamnForIntentsOfFilter = tonumber(kwargs.teamn)
			end
		elseif arg1 == 'switch' or arg1 == 'drag' or arg1 == 'replace' then
			-- if double battle and sending out multiple at once, send out simultaneously
			-- Go! A and B!                   | Go! A, B, and C!
			-- [Opponent] sent out D and E!   | [Opponent] sent out D, E, and F!
			self:endLastTurn()
--			if self:waitForResult() then return end
			local poke = self:getPokemon('other: ' .. args[2], args[3], true)
			local slot = poke.slot
			poke:healthParse(args[4])
			if args[5] then
				poke.status = args[5]
			else
				poke.status = ''
			end
			if arg1 == 'switch' then
				self.readyForInputFlag = true
				local simultaneousSwitches = {}
				if poke.side.active[slot] ~= null then
					poke.side:switchOut(poke.side.active[slot])
				else
					while true do
						if not self.actionQueue[1] then break end
						local nextActionArgs = (self:parseAction(self.actionQueue[1]))
						if nextActionArgs[1] ~= 'switch' then break end
						local nextSwitchPokemon = self:getPokemon('other: ' .. nextActionArgs[2], nextActionArgs[3], true)
						if nextSwitchPokemon.side.n ~= poke.side.n then break end
						table.remove(self.actionQueue, 1)
						table.insert(simultaneousSwitches, nextSwitchPokemon)
						nextSwitchPokemon:healthParse(nextActionArgs[4])
					end
				end
				local nSimultaneousSwitches = #simultaneousSwitches
				if nSimultaneousSwitches > 0 then
					spawn(function()
						local pstring = poke:getShortName()
						if poke.side.n ~= 1 or not self.npcPartner then
							if nSimultaneousSwitches == 1 then
								pstring = pstring .. ' and ' .. simultaneousSwitches[1]:getShortName()
							else
								for i, p in pairs(simultaneousSwitches) do
									pstring = pstring .. ', ' .. (i==nSimultaneousSwitches and 'and ' or '') .. p:getShortName()
								end
							end
						end
						if poke.side.n == 1 then
							self:message('Go! ' .. pstring .. '!')
						elseif self.kind ~= 'wild' then
							self:message(poke.side:getCombinedName() .. ' sent out ' .. pstring .. '!')
						end
					end)
					local secondary = true
					if (poke.side.n == 1 and self.npcPartner) or self.kind == '2v2' then secondary = false end
					sync {
						function() poke.side:switchIn(poke, nil, true) end,
						unpack(map(simultaneousSwitches, function(otherPoke)
							return function() otherPoke.side:switchIn(otherPoke, nil, true, secondary) end
						end))
					}
				else
					poke.side:switchIn(poke)
				end
			elseif arg1 == 'replace' then
				poke.side:replace(poke)
			else
				poke.side:dragIn(poke)
			end
			if self.pauseAfterSwitchFlag then -- hack for wild battles
				self.pauseAfterSwitchFlag = nil
				return false
			end
		elseif arg1 == 'faint' then
--			if self:waitForResult() then return end
			local poke = self:getPokemon(args[2])
			poke.side:faint(poke)
		elseif arg1 == 'swap' then
			-- Apparently :swapWith is an old function, replaced by :swapTo (kept on PS for replay backward-compatibility)
			local slot = tonumber(args[3])
--			if slot then
				local poke = self:getPokemon(args[2])
				poke.side:swapTo(poke, slot, kwargs)
--			else
--				local poke = self:getPokemon('other: ' .. args[2])
--				poke.side:swapWith(poke, self:getPokemon('other: ' .. args[3]), kwargs)
--			end
		elseif arg1 == 'move' then
			self:endLastTurn()
			isMove = true
--			if not kwargs.from and self:waitForResult() then return end
			local poke = self:getPokemon(args[2])
			local move = Tools.getMove(args[3])
			if not move.name then move.name = args[3] end
--			if self:checkActive(poke) then return end
			local poke2 = self:getPokemon(args[4])
			poke.sprite:beforeMove()
			local mhm = false
			local damageActionIndex
			for i, a in pairs(self.actionQueue) do
				if a == '|' or a:sub(1, 5) == '|move' then
					break
				elseif a:sub(1, 10) == '|-hitcount' then
					local mhd = {}
					for _ = 1, i do
						table.insert(mhd, table.remove(self.actionQueue, 1))
					end
					self:useMultihitMove(poke, move, poke2, kwargs, mhd)
					mhm = true
					break
				elseif a:sub(1, 8) == '|-damage' then
					damageActionIndex = i
				elseif a:sub(1, 6) == '|-anim' and damageActionIndex then
					table.insert(self.actionQueue, i, table.remove(self.actionQueue, damageActionIndex))
					break
				end
			end
			if not mhm then
				self:useMove(poke, move, poke2, kwargs)
			end
			poke.sprite:afterMove()
		elseif arg1 == 'cant' then
			self:endLastTurn()
--			if self:waitForResult() then return end
			local poke = self:getPokemon(args[2])
			local effect = Tools.getEffect(args[3])
			local move
			if args[4] then
				move = Tools.getMove(args[4])
			end
			self:cantUseMove(poke, effect, move, kwargs)
		elseif arg1 == 'learnmove' then
			local poke = self:getPokemon(args[2])
			if kwargs.evo and not poke.evolved then
				self:send('learnMove', tonumber(args[4]), nil)
			else
				local lmd
				spawn(function() lmd = self:sendAsync('getLearnMoveData', tonumber(args[4])) end)
				local pokeName = poke:getName()
				local moveName = args[3]
				
				local deleteMoveInSlot
				while true do
					self:message(pokeName .. ' wants to learn the move ' .. moveName .. '.')
					self:message('However, ' .. pokeName .. ' already knows four moves.')
					local delete = self:message('[Y/N]Should a move be deleted and replaced with ' .. moveName .. '?')
					
					if delete then
						self:message('Which move should be forgotten?')
						while not lmd do wait() end
						local slot = self:promptReplaceMove(shallowcopy(lmd))
						if slot then
							local deletedMove = lmd[slot]
							if self:message('[y/n]Should ' .. pokeName .. ' forget ' .. deletedMove.name .. ' in order to learn ' .. moveName .. '?') then
								self:message('1, 2, and... ... ... Ta-da!', pokeName .. ' forgot how to use ' .. deletedMove.name .. '.',
									'And...', pokeName .. ' learned ' .. moveName .. '!')
								deleteMoveInSlot = slot
								break
							end
						end
					end
					
					if self:message('[y/n]Give up on learning the move ' .. moveName .. '?') then
						self:message(pokeName .. ' did not learn ' .. moveName .. '.')
						break
					end
				end
				self:send('learnMove', tonumber(args[4]), deleteMoveInSlot)
				if deleteMoveInSlot then
					self.askForUpdatedSideDataFlag = true
				end
			end
		elseif arg1 == 'evolve' then
			local poke = self:getPokemon(args[2])
			local evoData = self:sendAsync('getEvolutionData', poke.index)
			pcall(function() evoData.evo.orientation0 = poke.orientation0 end)
			self:doEvolution(evoData)
		elseif arg1 == 'nickname' then
			local poke = self:getPokemon(args[2])
			if self:message('[y/n]Give a nickname to the ' .. poke.name .. ' you caught?') then
				local nickname = self:nicknamePokemon(poke.icon-1, poke.shiny)
				if nickname then
					self:send('nicknamePokemon', tonumber(args[3]), nickname)
					self.wildNickname = nickname
				end
			end
		elseif arg1 == 'payout' then
			self:message(self.mySide.name .. ' received [$]' .. comma_value(tonumber(args[2])) .. ' for winning!')
		elseif arg1 == 'blackout' then
			-- handled elsewhere
		elseif arg1 == 'message' then
			self:message(args[2])
		elseif arg1 == 'done' or arg1 == '' then
--			if self.done or self:endPrevAction() then return end
		elseif arg1 == 'error' then
--			args.shift();
--			this.message('<strong>Error:</strong> ' + Tools.escapeHTML(args.join('|')));
--			this.message('Bug? Report it to <a href="http:--www.smogon.com/forums/showthread.php?t=3453192">the replay viewer\'s Smogon thread</a>');
			self:debug('error: '..args[2])
		elseif arg1 == 'warning' then
--			args.shift();
--			this.message('<strong>Warning:</strong> ' + Tools.escapeHTML(args.join('|')));
--			this.message('Bug? Report it to <a href="http:--www.smogon.com/forums/showthread.php?t=3453192">the replay viewer\'s Smogon thread</a>');
--			this.activityWait(1000);
			self:debug('warning: '..args[2])
--		case 'gen':
--			this.gen = parseInt(args[1]);
--			this.updateGen();
--			break;
--		case 'callback':
--			args.shift();
--			if (this.customCallback) this.customCallback(this, args[0], args, kwargs);
--			break;
		elseif arg1 == 'debug' then
--			args.shift();
--			name = args.join(' ');
--			this.log('<div class="debug"><div class="chat"><small style="color:#999">[DEBUG] ' + Tools.escapeHTML(name) + '.</small></div></div>', preempt);
			self:debug(args[2])
--		case 'seed':
--		case 'choice':
--			break;
--		case 'unlink':
--			if (Tools.prefs('nounlink')) return;
--			var user = toId(args[2]) || toId(args[1]);
--			var $messages = $('.chatmessage-' + user);
--			if (!$messages.length) break;
--			$messages.find('a').contents().unwrap();
--			if (window.BattleRoom && args[2]) {
--				$messages.hide();
--				this.log('<div class="chatmessage-' + user + '"><button name="revealMessages" value="' + user + '"><small>View ' + $messages.length + ' hidden message' + ($messages.length > 1 ? 's' : '') + '</small></button></div>');
--			}
--			break;
		else
			self:debug('unknown command: ' .. arg1)
--			this.logConsole('unknown command: ' + args[0]);
--			this.log('<div>Unknown command: ' + Tools.escapeHTML(args[0]) + '</div>');
--			if (this.errorCallback) this.errorCallback(this);
		end
	end
	-- It seems that the Lua decompiler that the exploiters use fails to decompile
	--  this script, my guess is because of the large number of if/elseif's.
	-- We take advantage of that here by including some anti-exploit mechanisms.
	-- We also recognize that they are relentless and will never stop trying, so we
	--  don't depend on this, but we throw it in for kicks and hope for the best.
	
	-- todo :/ (better things to do, like the PDS overhaul)
	
end

