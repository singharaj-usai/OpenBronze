local _f = require(script.Parent.Parent)
local null, toId, Not, deepcopy, shallowcopy, indexOf; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	null = util.null
	toId = util.toId
	Not = util.Not
	deepcopy = util.deepcopy
	shallowcopy = util.shallowcopy
	indexOf = util.indexOf
end

local function Or(a, b)
	if Not(a) then
		return b
	end
	return a
end

local MegaColors = {
	Venusaur   = {{'Artichoke','Bright red'},{'Sea green','Bright yellow'}},
	CharizardX = {{'Black','Cyan'},{'Bright bluish green','Crimson'}},
	CharizardY = {{'Bright orange','Bright bluish green'},{'Lavender','Crimson'}},
	Blastoise  = {{'Brown','Bright blue'},{'Earth green','Alder'}},
	Alakazam   = {{'Brown','Bright yellow'},{'Lilac','Bright yellow'}},
	Gengar     = {{'Mulberry','Pink'},{'White','Mauve'}},
	GengarH    = {{'Black','Black'},{'Bright orange','Bright green'}},-- can only be shiny
	Kangaskhan = {{'Brown','Medium blue'},{'Cloudy grey','Alder'}},
	Pinsir     = {{'Flint','Pastel blue-green'},{'Alder','Pastel blue-green'}},
	Gyarados   = {{'Bright blue','Persimmon'},{'Bright red','White'}},
	Aerodactyl = {{'Medium stone grey','Alder'},{'Alder','Electric blue'}},
	MewtwoX    = {{'Carnation pink','Sunrise'},{'Lime green','Fossil'}},-- move non-mega left
	MewtwoY    = {{'Sunrise','White'},{'Mint','White'}},
	Ampharos   = {{'Bright yellow','White'},{'Mauve','White'}},
	Scizor     = {{'Bright red','Bright blue'},{'Br. yellowish green','Bright yellow'}},
	Heracross  = {{'Bright blue','Bright red'},{'Carnation pink','Bright red'}},
	Houndoom   = {{'Dark stone grey','Bright orange'},{'Storm blue','Bright red'}},
	Tyranitar  = {{'Medium green','Bright red'},{'Daisy orange','Alder'}},
	Blaziken   = {{'Bright red','Bright orange'},{'Gold','Neon orange'}},
	Gardevoir  = {{'Mint','White','Persimmon'},{'Smoky grey','Medium blue','Bright orange'}},
	Mawile     = {{'Dark stone grey','Lavender'},{'Lilac','Bright violet'}},
	Aggron     = {{'Dark stone grey','White'},{'Bright bluish green','Brick yellow'}},
	Medicham   = {{'Pink','Fossil'},{'Steel blue','Cork'}},
	Manectric  = {{'Daisy orange','Medium blue'},{'Smoky grey','Bright yellow'}},
	Banette    = {{'Smoky grey','Pink'},{'Storm blue','Pink'}},
	Absol      = {{'Sand blue','White'},{'Persimmon','Pastel orange'}},
	Garchomp   = {{'Lavender','Bright red'},{'Lilac','Hot pink'}},
	Lucario    = {{'Bright bluish green','Black'},{'Olive','Sand blue'}},
	Abomasnow  = {{'Bright bluish green','White','Medium blue'},{'Storm blue','White','Medium blue'}},
	Beedrill   = {{'Black','Bright yellow'},{'Black','Bright green'}},-- clean wings
	Pidgeot    = {{'Nougat','Persimmon','Brick yellow'},{'Br. yellowish orange','Daisy orange','Bright violet'}},-- move left
	Slowbro    = {{'Baby blue','Light reddish violet'},{'Cork','Alder'}},
	Steelix    = {{'Fossil','White'},{'Daisy orange','White'}},
	Sceptile   = {{'Moss','Persimmon'},{'Bright bluish green','Daisy orange'}},
	SceptileC   = {{'Parsley green','White','Wheat'},{'Cocoa','White','White'}},

	Swampert   = {{'Cyan','Bright orange'},{'Carnation pink','Bright orange'}},
	Sableye    = {{'Lavender','Persimmon'},{'Gold','Bright green'}},
	Sharpedo   = {{'Electric blue','White'},{'Lilac','Mauve'}},
	Camerupt   = {{'Smoky grey','Neon orange'},{'Smoky grey','Neon orange'}},
	Altaria    = {{'Pastel Blue','White'},{'Cool yellow','White'}},
	Glalie     = {{'White','Bright blue'},{'White','Bright red'}},
	Salamence  = {{'Cyan','Bright red'},{'Lime green','Neon orange'}},
	Metagross  = {{'Cyan','Fossil'},{'Fossil','Bright yellow'}},
	Latias     = {{'Pastel violet','White','Bright red'},{'Neon green','White','Bright yellow'}},
	Latios     = {{'Pastel violet','White','Bright blue'},{'Neon green','White','Bright bluish green'}},
	Rayquaza   = {{'Dark green','Bright yellow'},{'Black','Bright yellow'}},-- move left
	Lopunny    = {{'Brown','Beige'},{'Linen','Pink'}},
	Gallade    = {{'White','Bright green'},{'White','Bright blue'}},
	Audino     = {{'White','Carnation pink'},{'White','Alder'}},
	Diancie    = {{'White','Pink'},{'Black','Pink'}},
	
	--[[
	-- Preparing for Z to A new mega evos
	-- Kanto Region Mega Evolutions
	Clefable   = {{'Pink','White'},{'Bright violet','White'}},
	Starmie    = {{'Medium blue','Gold'},{'Bright blue','Bright yellow'}},
	Victreebel = {{'Br. yellowish green','Dark green'},{'Lime green','Forest green'}},
	Dragonite  = {{'Bright orange','Electric blue'},{'Gold','Bright blue'}},

	-- Johto Region Mega Evolutions
	Meganium   = {{'Bright green','Pink'},{'Lime green','Hot pink'}},
	Feraligatr = {{'Navy blue','Bright red'},{'Cyan','Crimson'}},
	Skarmory   = {{'Dark stone grey','Bright blue'},{'Silver','Electric blue'}},

	-- Sinnoh Region Mega Evolutions
	Froslass   = {{'White','Cyan'},{'Ice blue','Electric blue'}},

	-- Unova Region Mega Evolutions
	Emboar     = {{'Bright red','Gold'},{'Crimson','Bright yellow'}},
	Scolipede  = {{'Dark violet','Neon green'},{'Deep purple','Lime green'}},
	Excadrill  = {{'Rust','Dark stone grey'},{'Bronze','Silver'}},
	Eelektross = {{'Electric blue','Black'},{'Cyan','Dark indigo'}},
	Scrafty    = {{'Brown','Bright red'},{'Sand red','Crimson'}},
	Chandelure = {{'Black','Bright violet'},{'Dark indigo','Hot pink'}},

	-- Kalos Region Mega Evolutions
	Chesnaught = {{'Earth green','Gold'},{'Forest green','Bright yellow'}},
	Delphox    = {{'Bright red','Gold'},{'Deep orange','Bright yellow'}},
	Greninja   = {{'Navy blue','Crimson'},{'Dark blue','Hot pink'}},
	Pyroar     = {{'Brown','Bright red'},{'Gold','Crimson'}},
	Malamar    = {{'Dark violet','Bright red'},{'Deep purple','Crimson'}},
	Barbaracle = {{'Brown','Dark stone grey'},{'Rust','Silver'}},
	Dragalge   = {{'Dark violet','Toxic green'},{'Deep purple','Lime green'}},
	Hawlucha   = {{'Bright green','Bright red'},{'Lime green','Crimson'}},
	Floette    = {{'White','Gold','Bright red'},{'Ice blue','Bright yellow','Hot pink'}},
	Zygarde    = {{'Dark green','Bright green'},{'Forest green','Lime green'}},

	-- Alola Region Mega Evolutions
	Drampa     = {{'White','Cyan'},{'Ice blue','Electric blue'}},

	-- Galar Region Mega Evolutions
	Falinks    = {{'Bronze','Gold'},{'Rust','Bright yellow'}},
--]]
	-- Other Mega Evolutions
}

do
	local cache = {['Neon orange']=1005}
	local default = BrickColor.new('aofpisjadf')
	for name, t in pairs(MegaColors) do
		for i, set in pairs(t) do
			for j, color in pairs(set) do
				local n = cache[color]
				if n then
					set[j] = n
				else
					local bc = BrickColor.new(color)
					if bc == default and color ~= 'Medium stone grey' then
						error('typo in color for '..name..': '..color, 0)
					end
					n = bc.Number
					cache[color] = n
				end
			end
		end
	end
	--	print('colors passed')
end


return function(Battle)
	function Battle:runMove(move, pokemon, target, sourceEffect, zMove)--, zMove)
		local Basemove = self:getMove(move, zMove)

		if not sourceEffect and toId(move) ~= 'struggle' or zMove then
			--if zMove then move.name = zMove end
			local changedMove = self:runEvent('OverrideDecision', pokemon, target, move)
			if changedMove and changedMove ~= true then
				move = changedMove
				target = nil
			end
		end
		move = Basemove
		if not target and target ~= false then target = self:resolveTarget(pokemon, move) end
		if zMove then move = self:getActiveZMove(move, pokemon) end

		self:setActiveMove(move, pokemon, target)
		--if zMove then move.name = zMove 
		--move.id = toId(zMove) end
		--if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
		--if not self:getMove(toId(zMove)).Exclusive and self:getMove(toId(zMove)).isZ then move.volatileStatus = nil 
		--	move.multihit = nil end
		--if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
		--if not self:getMove(toId(zMove)).Exclusive and self:getMove(toId(zMove)).isZ then 
		--	local pwr = move.basePower
		--	move = self:getMove(toId(zMove))
		--	move.basePower = pwr
		--end  
		--[[if pokemon.moveThisTurn ~= '' then
			-- THIS IS PURELY A SANITY CHECK
			-- DO NOT TAKE ADVANTAGE OF THIS TO PREVENT A POKEMON FROM MOVING;
			-- USE self:cancelMove INSTEAD
			self:debug(pokemon.id .. ' INCONSISTENT STATE, ALREADY MOVED: ' .. pokemon.moveThisTurn)
			self:clearActiveMove(true)
			return
		end]]

		local ev_res = self:runEvent('BeforeMove', pokemon, target, move)
		--		self:debug('BeforeMove event result:', ev_res == null and 'null' or ev_res)
		if Not(ev_res) then
			-- Prevent invulnerability from persisting until the turn ends
			pokemon:removeVolatile('twoturnmove')
			-- Prevent Pursuit from running again against a slower U-turn/Volt Switch/Parting Shot
			pokemon.moveThisTurn = true
			self:clearActiveMove(true)
			-- resets zmove stuff
			if zMove then
				pokemon.canZMove = self:canZMove(pokemon)
				for _, poke in pairs(pokemon.side.pokemon) do
					if poke ~= pokemon and poke.teamn == pokemon.teamn then
						poke.canZMove = self:canZMove(poke)
					end
				end
			end
			return
		end
		if move.beforeMoveCallback then
			if self:call(move.beforeMoveCallback, pokemon, target, move) then
				self:clearActiveMove(true)
				return
			end
		end
		pokemon.lastDamage = 0
		local lockedMove = self:runEvent('LockMove', pokemon)
		if lockedMove == true then lockedMove = false end
		if not lockedMove then
			if not pokemon:deductPP(Basemove, nil, target) and (move.id ~= 'struggle') then
				self:add('cant', pokemon, 'nopp', move)
				self:clearActiveMove(true)
				return
			end
		else
			sourceEffect = self:getEffect('lockedmove')
		end
		pokemon:moveUsed(move)
		--if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
		self:useMove(move, pokemon, target, sourceEffect, zMove)
		self:singleEvent('AfterMove', move, nil, pokemon, target, move)
	end
	function Battle:useMove(move, pokemon, target, sourceEffect, zMove)
		if not sourceEffect and self.effect.id then sourceEffect = self.effect end
		move = self:getMoveCopy(move, zMove)

		--if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
		--if not self:getMove(toId(zMove)).Exclusive and self:getMove(toId(zMove)).isZ then 
		--	local pwr = move.basePower
		--	move = self:getMove(toId(zMove))
		--	move.basePower = pwr
		--end  
		if self.activeMove then move.priority = self.activeMove.priority end
		local baseTarget = move.target
		if not target and target ~= false then target = self:resolveTarget(pokemon, move) end
		if move.target == 'self' or move.target == 'allies' then
			target = pokemon
		end
		if sourceEffect then move.sourceEffect = sourceEffect.id end
		local moveResult = false

		self:setActiveMove(move, pokemon, target)

		self:singleEvent('ModifyMove', move, nil, pokemon, target, move, move)
		if baseTarget ~= move.target then
			-- Target changed in ModifyMove, so we must adjust it here
			-- Adjust before the next event so the correct target is passed to the
			-- event
			target = self:resolveTarget(pokemon, move)
		end
		move = self:runEvent('ModifyMove', pokemon, target, move, move)
		if baseTarget ~= move.target then
			-- Adjust again
			target = self:resolveTarget(pokemon, move)
		end
		if not move then return false end

		local attrs = ''
		local missed = false
		if pokemon.fainted then
			return false
		end

		if move.flags['charge'] and not pokemon.volatiles[move.id] then
			attrs = '|[still]' -- suppress the default move animation
		end

		local movename = move.name
		if move.id == 'hiddenpower' then movename = 'Hidden Power' end
		if sourceEffect and sourceEffect ~= '' and sourceEffect.id ~= '' then attrs = attrs .. '|[from]' .. self:getEffect(sourceEffect) end
		if zMove and move.category == 'Status' then
			attrs = '|[anim]'..movename..''..attrs
			movename = 'Z-'..movename
		end
		self:addMove('move', pokemon, movename, ((type(target)=='table' and target.toString) and target or tostring(target)) .. attrs) -- tbh we don't really need target in here, do we?
		if zMove then self:runZPower(move, pokemon) end
		if target == false then
			self:attrLastMove('[notarget]')
			self:add('-notarget')
			if move.target == 'normal' then pokemon.isStaleCon = 0 end
			return true
		end

		local targets = pokemon:getMoveTargets(move, target)
		local extraPP = 0
		for _, target in pairs(targets) do
			if target ~= null then
				local ppDrop = self:singleEvent('DeductPP', target:getAbility(), target.abilityData, target, pokemon, move)
				if ppDrop ~= true then
					extraPP = extraPP + (ppDrop or 0)
				end
			end
		end
		if extraPP > 0 then
			pokemon:deductPP(move, extraPP)
		end
		if Not(self:runEvent('TryMove', pokemon, target, move)) then
			return true
		end

		self:singleEvent('UseMoveMessage', move, nil, pokemon, target, move)

		if move.ignoreImmunity == nil then
			move.ignoreImmunity = (move.category == 'Status')
		end

		local damage = false
		if move.target == 'all' or move.target == 'foeSide' or move.target == 'allySide' or move.target == 'allyTeam' then
			damage = self:tryMoveHit(target, pokemon, move, nil, zMove)
			if damage or damage == nil then moveResult = true end
		elseif move.target == 'allAdjacent' or move.target == 'allAdjacentFoes' then
			if move.selfdestruct then
				self:faint(pokemon, pokemon, move)
			end
			if #targets == 0 then
				self:attrLastMove('[notarget]')
				self:add('-notarget')
				return true
			end
			if #targets > 1 then move.spreadHit = true end
			damage = 0
			for _, target in pairs(targets) do
				local hitResult = self:tryMoveHit(target, pokemon, move, true, zMove)
				--				require(game.ReplicatedStorage.src.Utilities).print_r({damage, hitResult})
				if hitResult ~= null and hitResult ~= false then moveResult = true end
				damage = damage + Or(hitResult, 0)
			end
			if pokemon.hp <= 0 then pokemon:faint() end
		else
			target = targets[1]
			local lacksTarget = target==null or target.fainted
			if not lacksTarget then
				if move.target == 'adjacentFoe' or move.target == 'adjacentAlly' or move.target == 'normal' or move.target == 'randomNormal' then
					lacksTarget = not self:isAdjacent(target, pokemon)
				end
			end
			if lacksTarget then
				self:attrLastMove('[notarget]')
				self:add('-notarget')
				if move.target == 'normal' then pokemon.isStaleCon = 0 end
				return true
			end
			damage = self:tryMoveHit(target, pokemon, move, nil, zMove)
			if damage or damage == nil then moveResult = true end
		end
		if pokemon.hp <= 0 then
			self:faint(pokemon, pokemon, move)
		end

		if not moveResult then
			self:singleEvent('MoveFail', move, nil, target, pokemon, move)
			return true
		end

		if move.selfdestruct then
			self:faint(pokemon, pokemon, move)
		end

		if not move.negateSecondary and not (pokemon:hasAbility('sheerforce') and pokemon.volatiles['sheerforce']) then
			self:singleEvent('AfterMoveSecondarySelf', move, nil, pokemon, target, move)
			self:runEvent('AfterMoveSecondarySelf', pokemon, target, move)
		end
		return true
	end
	function Battle:tryMoveHit(target, pokemon, move, spreadHit, zMove)
		if move.selfdestruct and spreadHit then pokemon.hp = 0 end
		--if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
		--if not self:getMove(toId(zMove)).Exclusive and self:getMove(toId(zMove)).isZ then move.volatileStatus = nil 
		--	move.multihit = nil end  
		--if self:getMove(toId(zMove)).Exclusive then move = self:getMove(toId(zMove)) end
		--if not self:getMove(toId(zMove)).Exclusive and self:getMove(toId(zMove)).isZ then 
		--	local pwr = move.basePower
		--	move = self:getMove(toId(zMove))
		--	move.basePower = pwr
		--end  
		self:setActiveMove(move, pokemon, target)
		local hitResult = true

		hitResult = self:singleEvent('PrepareHit', move, {}, target, pokemon, move)
		if Not(hitResult) then
			if hitResult == false then self:add('-fail', target) end
			return false
		end
		self:runEvent('PrepareHit', pokemon, target, move)

		if Not(self:singleEvent('Try', move, nil, pokemon, target, move)) then
			return false
		end

		if move.target == 'all' or move.target == 'foeSide' or move.target == 'allySide' or move.target == 'allyTeam' then
			if move.target == 'all' then
				hitResult = self:runEvent('TryHitField', target, pokemon, move)
			else
				hitResult = self:runEvent('TryHitSide', target, pokemon, move)
			end
			if Not(hitResult) then
				if hitResult == false then self:add('-fail', target) end
				return true
			end
			return self:moveHit(target, pokemon, move, nil, zMove)
		end

		if move.ignoreImmunity == nil then
			move.ignoreImmunity = (move.category == 'Status')
		end

		if move.ignoreImmunity ~= true and (move.ignoreImmunity == false or not move.ignoreImmunity[move.type]) and not target:runImmunity(move.type, true) then
			return false
		end

		hitResult = self:runEvent('TryHit', target, pokemon, move)
		if Not(hitResult) then
			if hitResult == false then self:add('-fail', target) end
			return false
		end

		local boostTable = {4/3, 5/3, 2, 7/3, 8/3, 3}

		-- calculate true accuracy
		local accuracy = move.accuracy
		if accuracy ~= true then
			if not move.ignoreAccuracy then
				local boosts = self:runEvent('ModifyBoost', pokemon, nil, nil, deepcopy(pokemon.boosts))
				local boost = self:clampIntRange(boosts['accuracy'], -6, 6)
				if boost > 0 then
					accuracy = accuracy * boostTable[boost]
				elseif boost < 0 then
					accuracy = accuracy / boostTable[-boost]
				end
			end
			if not move.ignoreEvasion then
				local boosts = self:runEvent('ModifyBoost', target, nil, nil, deepcopy(target.boosts))
				local boost = self:clampIntRange(boosts['evasion'], -6, 6)
				if boost > 0 then
					accuracy = accuracy / boostTable[boost]
				elseif boost < 0 then
					accuracy = accuracy * boostTable[-boost]
				end
			end
		end
		if move.ohko then -- bypasses accuracy modifiers
			if not target:isSemiInvulnerable() then
				accuracy = 30
				if pokemon.level >= target.level then
					accuracy = accuracy + (pokemon.level - target.level)
				else
					self:add('-immune', target, '[ohko]')
					return false
				end
			end
		else
			accuracy = self:runEvent('ModifyAccuracy', target, pokemon, move, accuracy)
		end
		if move.alwaysHit then
			accuracy = true -- bypasses ohko accuracy modifiers
		else
			accuracy = self:runEvent('Accuracy', target, pokemon, move, accuracy)
		end
		if accuracy ~= true and math.random(99) >= accuracy then
			if not spreadHit then self:attrLastMove('[miss]') end
			self:add('-miss', pokemon, target)
			return false
		end
		if move.stealBoosts then
			local stolen = false
			local boosts = {}
			for stat, stage in pairs(target.boosts) do
				if stage > 0 then
					print(stat)
					print(stage)
					boosts[stat] = stage
					stolen = true
				end
			end
			
			if stolen then
				self:attrLastMove('[still]')
				self:boost(boosts, pokemon, pokemon, move)
				for stat, stage in pairs(boosts) do
					boosts[stat] = 0
				end
				target:setBoost(boosts)
				self:addMove('-anim', pokemon, "Spectral Thief", target)
			end
		end
		if move.breaksProtect then
			local broke = false
			for _, v in pairs({'kingsshield', 'protect', 'spikyshield'}) do
				if target:removeVolatile(v) then
					broke = true
				end
			end
			for _, sc in pairs({'craftyshield', 'matblock', 'quickguard', 'wideguard'}) do
				if target.side:removeSideCondition(sc) then
					broke = true
				end
			end
			if broke then
				if move.isZOrMaxPowered then
					move.zBrokeProtect = true
				end
				if move.id == 'feint' then
					self:add('-activate', target, 'move: Feint')
				else
					self:add('-activate', target, 'move: ' .. move.name, '[broken]')
				end
			end
		end

		local totalDamage = 0
		local damage = 0
		pokemon.lastDamage = 0
		if move.multihit then
			self.currentMoveMultiHits = true
			local hits = move.multihit
			if type(hits) == 'table' then
				if hits[1] == 2 and hits[2] == 5 then
					hits = ({2, 2, 3, 3, 4, 5})[math.random(6)]
				else
					hits = math.random(hits[1], hits[2])
				end
			end
			--		hits = math.floor(hits)
			local nullDamage = true
			local moveDamage
			local isSleepUsable = move.sleepUsable or self:getMove(move.sourceEffect).sleepUsable
			local actualHits = 0
			for i = 1, hits do
				if target.hp <= 0 or pokemon.hp <= 0 then break end
				if pokemon.status == 'slp' and not isSleepUsable then break end

				moveDamage = self:moveHit(target, pokemon, move, nil, nil, nil, zMove)
				if moveDamage == false then break end
				if nullDamage and (moveDamage or moveDamage == nil) then nullDamage = false end
				-- Damage from each hit is individually counted for the
				-- purposes of Counter, Metal Burst, and Mirror Coat.
				damage = moveDamage or 0
				-- Total damage dealt is accumulated for the purposes of recoil (Parental Bond).
				totalDamage = totalDamage + damage
				self:eachEvent('Update')
				actualHits = actualHits + 1
			end
			if actualHits == 0 then return true end
			if nullDamage then damage = false end
			self:add('-hitcount', target, actualHits)
		else
			self.currentMoveMultiHits = false
			damage = self:moveHit(target, pokemon, move, nil, nil, nil, zMove)
			totalDamage = damage
		end

		if move.recoil then
			self:damage(self:clampIntRange(math.floor(totalDamage * move.recoil[1] / move.recoil[2] + 0.5), 1), pokemon, target, 'recoil')
		end

		if target and pokemon ~= target then target:gotAttacked(move, damage, pokemon) end

		if move.ohko then self:add('-ohko') end

		if Not(damage) and damage ~= 0 then return damage end

		if target and not move.negateSecondary and not (pokemon:hasAbility('sheerforce') and pokemon.volatiles['sheerforce']) then
			self:singleEvent('AfterMoveSecondary', move, nil, target, pokemon, move)
			self:runEvent('AfterMoveSecondary', target, pokemon, move)
		end

		return damage
	end
	function Battle:moveHit(target, pokemon, move, moveData, isSecondary, isSelf, zMove)
		local damage
		move = self:getMoveCopy(move, zMove)

		if not moveData then moveData = move end
		if not moveData.flags then moveData.flags = {} end
		local hitResult = true

		-- TryHit events:
		--   STEP 1: we see if the move will succeed at all:
		--   - TryHit, TryHitSide, or TryHitField are run on the move,
		--     depending on move target (these events happen in useMove
		--     or tryMoveHit, not below)
		--   == primary hit line ==
		--   Everything after this only happens on the primary hit (not on
		--   secondary or self-hits)
		--   STEP 2: we see if anything blocks the move from hitting:
		--   - TryFieldHit is run on the target
		--   STEP 3: we see if anything blocks the move from hitting the target:
		--   - If the move's target is a pokemon, TryHit is run on that pokemon

		-- Note:
		--   If the move target is `foeSide`:
		--     event target = pokemon 0 on the target side
		--   If the move target is `allySide` or `all`:
		--     event target = the move user
		--
		--   This is because events can't accept actual sides or fields as
		--   targets. Choosing these event targets ensures that the correct
		--   side or field is hit.
		--
		--   It is the `TryHitField` event handler's responsibility to never
		--   use `target`.
		--   It is the `TryFieldHit` event handler's responsibility to read
		--   move.target and react accordingly.
		--   An exception is `TryHitSide` as a single event (but not as a normal
		--   event), which is passed the target side.

		if move.target == 'all' and not isSelf then
			hitResult = self:singleEvent('TryHitField', moveData, {}, target, pokemon, move)
		elseif (move.target == 'foeSide' or move.target == 'allySide') and not isSelf then
			hitResult = self:singleEvent('TryHitSide', moveData, {}, target.side, pokemon, move)
		elseif target then
			hitResult = self:singleEvent('TryHit', moveData, {}, target, pokemon, move)
		end
		if Not(hitResult) then
			if hitResult == false then self:add('-fail', target) end
			return false
		end

		if target and not isSecondary and not isSelf then
			if move.target ~= 'all' and move.target ~= 'allySide' and move.target ~= 'foeSide' then
				hitResult = self:runEvent('TryPrimaryHit', target, pokemon, moveData)
				if hitResult == 0 then
					-- special Substitute flag
					hitResult = true
					target = nil
				end
			end
		end
		if target and isSecondary and moveData.self then
			hitResult = true
		end
		if Not(hitResult) then
			return false
		end

		if target then
			local didSomething = false

			damage = self:getDamage(pokemon, target, moveData, nil, zMove)

			-- getDamage has several possible return values:
			--
			--   a number:
			--     means that much damage is dealt (0 damage still counts as dealing
			--     damage for the purposes of things like Static)
			--   false:
			--     gives error message: "But it failed!" and move ends
			--   null:
			--     the move ends, with no message (usually, a custom fail message
			--     was already output by an event handler)
			--   undefined:
			--     means no damage is dealt and the move continues
			--
			-- basically, these values have the same meanings as they do for event handlers.

			if not Not(damage) and not target.fainted then
				if move.noFaint and damage >= target.hp then
					damage = target.hp - 1
				end
				damage = self:damage(damage, target, pokemon, move, nil, true, zMove)
				if not damage then
					self:debug('damage interrupted')
					return false
				end
				didSomething = true
			end
			if damage == false or damage == null then
				if damage == false and not isSecondary and not isSelf then
					self:add('-fail', target)
				end
				self:debug('damage calculation interrupted')
				return false
			end

			if moveData.boosts and not target.fainted then
				hitResult = self:boost(moveData.boosts, target, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.heal and not target.fainted then
				local d = target:heal(math.floor(target.maxhp * moveData.heal[1] / moveData.heal[2] + 0.5))
				if not d then
					self:add('-fail', target)
					self:debug('heal interrupted')
					return false
				end
				self:add('-heal', target, target.getHealth)
				didSomething = true
			end
			if moveData.status then
				if Not(target.status) then
					hitResult = target:setStatus(moveData.status, pokemon, move)
					if not hitResult and move.status then
						self:add('-immune', target, '[msg]')
						return false
					end
					didSomething = Or(didSomething, hitResult)
				elseif not isSecondary then
					if target.status == moveData.status then
						self:add('-fail', target, target.status)
					else
						self:add('-fail', target)
					end
					return false
				end
			end
			if moveData.forceStatus then
				hitResult = target:setStatus(moveData.forceStatus, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.volatileStatus then
				hitResult = target:addVolatile(moveData.volatileStatus, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.sideCondition then
				hitResult = target.side:addSideCondition(moveData.sideCondition, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.weather then
				hitResult = self:setWeather(moveData.weather, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.terrain then	
				hitResult = self:setTerrain(moveData.terrain, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.pseudoWeather then
				hitResult = self:addPseudoWeather(moveData.pseudoWeather, pokemon, move)
				didSomething = Or(didSomething, hitResult)
			end
			if moveData.forceSwitch then
				if target.side:canSwitch(target.position) then didSomething = true end -- at least defer the fail message to later
			end
			if moveData.selfSwitch then
				if pokemon.side:canSwitch(target.position) then didSomething = true end -- at least defer the fail message to later
			end
			-- Hit events
			--   These are like the TryHit events, except we don't need a FieldHit event.
			--   Scroll up for the TryHit event documentation, and just ignore the "Try" part. ;)
			hitResult = nil
			if move.target == 'all' and not isSelf then
				if moveData.onHitField then hitResult = self:singleEvent('HitField', moveData, {}, target, pokemon, move) end
			elseif (move.target == 'foeSide' or move.target == 'allySide') and not isSelf then
				if moveData.onHitSide then hitResult = self:singleEvent('HitSide', moveData, {}, target.side, pokemon, move) end
			else
				if moveData.onHit then hitResult = self:singleEvent('Hit', moveData, {}, target, pokemon, move) end
				if not isSelf and not isSecondary then
					self:runEvent('Hit', target, pokemon, move)
				end
				if moveData.onAfterHit then hitResult = self:singleEvent('AfterHit', moveData, {}, target, pokemon, move) end
			end

			--			if moveData.boosts then print(hitResult, didSomething) end
			if Not(hitResult) and not didSomething and not moveData.self and not moveData.selfdestruct then
				if not isSelf and not isSecondary then
					if hitResult == false or didSomething == false then self:add('-fail', target) end
				end
				self:debug('move failed because it did nothing')
				return false
			end
		end
		if moveData.self then
			local selfRoll
			if not isSecondary and moveData.self.boosts then selfRoll = math.random(100) end
			-- This is done solely to mimic in-game RNG behaviour. All self drops have a 100% chance of happening but still grab a random number.
			if moveData.self.chance == nil or selfRoll <= moveData.self.chance then
				self:moveHit(pokemon, pokemon, move, moveData.self, isSecondary, true, zMove)
			end
		end
		if moveData.secondaries then
			local secondaryRoll
			local secondaries = self:runEvent('ModifySecondaries', target, pokemon, moveData, shallowcopy(moveData.secondaries))
			for _, secondary in pairs(secondaries) do
				secondaryRoll = math.random(100)
				if secondary.chance == nil or secondaryRoll <= secondary.chance then
					self:moveHit(target, pokemon, move, secondary, true, isSelf, zMove)
				end
			end
		end
		-- whirlwind, growl, etc.
		if moveData.forceSwitch and (target and target ~= null) and target.hp > 0 and pokemon.hp > 0 and target.side:canSwitch(target.position) then
			hitResult = self:runEvent('DragOut', target, pokemon, move)
			local canReallySwitch = false
			for _, pokemon in pairs(target.side.pokemon) do
				if not pokemon.fainted and pokemon ~= target and (not target.teamn or pokemon.teamn == target.teamn) then
					canReallySwitch = true
					break
				end
			end
			if not canReallySwitch then
				hitResult = false
			end
			if not Not(hitResult) then
				target.forceSwitchFlag = true
			elseif hitResult == false and move.category == 'Status' then
				self:add('-fail', target)
			end
		end
		if move.selfSwitch and pokemon.hp > 0 then
			pokemon.switchFlag = move.selfSwitch
		end
		return damage
	end
	function Battle:canMegaEvo(pokemon)
		-- Special case for Rayquaza: can mega evolve with Dragon Ascent
		if pokemon.baseTemplate.baseSpecies == 'Rayquaza' and indexOf(pokemon.moves, 'dragonascent') then
			return 'Rayquaza-Mega'
		end

		if pokemon.side.isTwoPlayerSide then -- player must have a Mega Keystone
			if not pokemon.side.megaAdornment[pokemon.teamn] then return false end
		else
			if not pokemon.side.megaAdornment then return false end
		end
		local altForme = pokemon.baseTemplate.otherFormes and self:getTemplate(pokemon.baseTemplate.otherFormes[1])
		if altForme and altForme.isMega and altForme.requiredMove and indexOf(pokemon.moves, toId(altForme.requiredMove)) then
			return altForme.species
		end
		local item = pokemon:getItem()
		if item.megaEvolves ~= pokemon.baseTemplate.baseSpecies or item.megaStone == pokemon.species then
			return false
		end
		-- special condition: only Halloween Gengars can use Gengarite H
		if item.id == 'gengariteh' and (pokemon.set.forme ~= 'hallow' or not pokemon.shiny) then
			print('wrong gengar')
			return false
		elseif item.id == 'sceptilitec' and (pokemon.set.forme ~= 'Christmas') then
			print('wrong Sceptile you Dunce')
			return false	
		end
		return item.megaStone
	end
	function Battle:runMegaEvo(pokemon)
		local template = self:getTemplate(pokemon.canMegaEvo)
		local side = pokemon.side

		-- Pokemon affected by Sky Drop cannot mega evolve. Enforce it here for now.
		for _, foe in pairs(side.foe.active) do
			if foe ~= null and foe.volatiles['skydrop'] and foe.volatiles['skydrop'].source == pokemon then
				return false
			end
		end

		pokemon:formeChange(template)
		pokemon.baseTemplate = template -- mega evolution is permanent
		pokemon.details = template.species .. ', L' .. pokemon.level .. (pokemon.gender == '' and '' or ', ') .. pokemon.gender .. (pokemon.set.shiny and ', shiny' or '')
		self:add('detailschange', pokemon, pokemon.details, '[forMega]', '[icon] '..(template.icon or 0))

		local megaId = 'mega'
		local colorSuffix = ''
		if template.megaId then
			megaId = template.megaId
			colorSuffix = megaId:sub(-1):upper()
		end
		local colors = MegaColors[template.baseSpecies..colorSuffix][pokemon.shiny and 2 or 1]
		self:add('-mega', pokemon, template.baseSpecies, pokemon:getItem().name, 
			colors[1], colors[2], colors[3] or 0, '[megaId] '..megaId)--template.requiredItem)
		local shinyPrefix = pokemon.shiny and '_SHINY' or ''
		local spriteId = template.baseSpecies..'-'..megaId
		self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/'..spriteId)
		self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/'..spriteId)

		pokemon:setAbility(template.abilities[1])
		pokemon.baseAbility = pokemon.ability

		-- for Summary page:
		pokemon.iconOverride = template.icon-1
		pokemon.frontSpriteOverride = _f.Database.Spritesheets[shinyPrefix..'_FRONT'][spriteId]
		pokemon.abilityOverride = template.abilities[1]
		pokemon.typeOverride = template.types
		pokemon.baseStatOverride = template.baseStats

		pokemon.didMegaEvo = true
		pokemon.canMegaEvo = false
		-- Limit one mega evolution
		for _, ally in pairs(side.pokemon) do
			if ally.canMegaEvo and ally ~= pokemon and ally.teamn == pokemon.teamn then
				ally.couldMegaEvo = true
				ally.canMegaEvo = false
			end
		end
		return true
	end
	function Battle:isAdjacent(pokemon1, pokemon2)
		if pokemon1.fainted or pokemon2.fainted then return false end
		if pokemon1.side == pokemon2.side then return math.abs(pokemon1.position - pokemon2.position) == 1 end
		return math.abs(pokemon1.position + pokemon2.position - 1 - #pokemon1.side.active) <= 1
		--because
		-- 1 2 3
		-- 3 2 1
	end





	-- coming soon
	function Battle:calcRecoilDamage(damageDealt, move)
		return math.max(1, math.floor(damageDealt * move.recoil[0] / move.recoil[1] + .5))
	end
	Battle.zStatus = {
		clearnegativeboost = {'Acid Armor', 'Agility', 'Amnesia', 'Attract', 'Autotomize', 'Barrier', 'Baton Pass', 'Calm Mind', 'Coil', 'Cotton Guard', 'Cotton Spore', 'Dark Void', 'Disable', 'Double Team', 'Dragon Dance', 'Endure', 'Floral Healing', 'Follow Me', 'Heal Order', 'Heal Pulse', 'Helping Hand', 'Iron Defense', "King's Shield", 'Leech Seed', 'Milk Drink', 'Minimize', 'Moonlight', 'Morning Sun', 'Nasty Plot', 'Perish Song', 'Protect', 'Quiver Dance', 'Rage Powder', 'Recover', 'Rest', 'Rock Polish', 'Roost', 'Shell Smash', 'Shift Gear', 'Shore Up', 'Slack Off', 'Soft-Boiled', 'Spore', 'Substitute', 'Swagger', 'Swallow', 'Swords Dance', 'Synthesis', 'Tail Glow'},
		spd1 = {'Charge', 'Confide', 'Cosmic Power', 'Crafty Shield', 'Eerie Impulse', 'Entrainment', 'Flatter', 'Glare', 'Ingrain', 'Light Screen', 'Magic Room', 'Magnetic Flux', 'Mean Look', 'Misty Terrain', 'Mud Sport', 'Spotlight', 'Stun Spore', 'Thunder Wave', 'Water Sport', 'Whirlwind', 'Wish', 'Wonder Room'},
		spd2 = {'Aromatic Mist', 'Captivate', 'Imprison', 'Magic Coat', 'Powder'},
		eva = {'Camouflage', 'Detect', 'Flash', 'Kinesis', 'Lucky Chant', 'Magnet Rise', 'Sand Attack', 'Smokescreen'},
		atk1 = {'Bulk Up', 'Hone Claws', 'Howl', 'Laser Focus', 'Leer', 'Meditate', 'Odor Sleuth', 'Power Trick', 'Rototiller', 'Screech', 'Sharpen', 'Tail Whip', 'Taunt', 'Topsy-Turvy', 'Will-O-Wisp', 'Work Up'},
		atk2 = {'Mirror Move'},
		atk3 = {'Splash'},
		spa1 = {'Confuse Ray', 'Electrify', 'Embargo', 'Fake Tears', 'Gear Up', 'Gravity', 'Growth', 'Instruct', 'Ion Deluge', 'Metal Sound', 'Mind Reader', 'Miracle Eye', 'Nightmare', 'Psychic Terrain', 'Reflect Type', 'Simple Beam', 'Soak', 'Sweet Kiss', 'Teeter Dance', 'Telekinesis'}, 
		spa2 = {'Heal Block', 'Psycho Shift'},
		def1 = {'Aqua Ring', 'Baby-Doll Eyes', 'Baneful Bunker', 'Block', 'Charm', 'Defend Order', 'Fairy Lock', 'Feather Dance', 'Flower Shield', 'Grassy Terrain', 'Growl', 'Harden', 'Mat Block', 'Noble Roar', 'Pain Split', 'Play Nice', 'Poison Gas', 'Poison Powder', 'Quick Guard', 'Reflect', 'Roar', 'Spider Web', 'Spikes', 'Spiky Shield', 'Stealth Rock', 'Strength Sap', 'Tearful Look', 'Tickle', 'Torment', 'Toxic', 'Toxic Spikes', 'Venom Drench', 'Wide Guard', 'Withdraw'},
		spe1 = {'After You', 'Aurora Veil', 'Electric Terrain', 'Encore', 'Gastro Acid', 'Grass Whistle', 'Guard Split', 'Guard Swap', 'Hail', 'Hypnosis', 'Lock-On', 'Lovely Kiss', 'Power Split', 'Power Swap', 'Quash', 'Rain Dance', 'Role Play', 'Safeguard', 'Sandstorm', 'Scary Face', 'Sing', 'Skill Swap', 'Sleep Powder', 'Speed Swap', 'Sticky Web', 'String Shot', 'Sunny Day', 'Supersonic', 'Toxic Thread', 'Worry Seed', 'Yawn'},
		spe2 = {'Ally Switch', 'Bestow', 'Me First', 'Recycle', 'Snatch', 'Switcheroo', 'Trick'},
		heal = {'Aromatherapy', 'Belly Drum', 'Conversion 2', 'Haze', 'Heal Bell', 'Mist', 'Psych Up', 'Refresh', 'Spite, Stockpile', 'Teleport', 'Transform'},
		acc = {'Copycat', 'Defense Curl', 'Defog', 'Focus Energy', 'Mimic', 'Sweet Scent', 'Trick Room'},
		all = {'Celebrate', 'Conversion', "Forest's Curse", 'Geomancy', 'Happy Hour', 'Hold Hands', 'Purify', 'Sketch', 'Trick-or-Treat'},
		crit2 = {'Acupressure', 'Foresight', 'Heart Swap', 'Sleep Talk', 'Tailwind'},
		healreplacement = {'Memento', 'Parting Shot'},
		redirect = {'Destiny Bond', 'Grudge'},
		runrandom = {'Metronome'}
	}
	Battle.zMoveTable = {
		Poison   = "Acid Downpour",
		Fighting = "All-Out Pummeling",
		Dark     = "Black Hole Eclipse",
		Grass    = "Bloom Doom",
		Normal   = "Breakneck Blitz",
		Rock     = "Continental Crush",
		Steel    = "Corkscrew Crash",
		Dragon   = "Devastating Drake",
		Electric = "Gigavolt Havoc",
		Water    = "Hydro Vortex",
		Fire     = "Inferno Overdrive",
		Ghost    = "Never-Ending Nightmare",
		Bug      = "Savage Spin-Out",
		Psychic  = "Shattered Psyche",
		Ice      = "Subzero Slammer",
		Flying   = "Supersonic Skystrike",
		Ground   = "Tectonic Rage",
		Fairy    = "Twinkle Tackle",
	}
	function Battle:findIn(moveName, pokemon)

		for name, t in pairs ((self.zStatus)) do
			local foundForMove = false
			for _, move in pairs (t) do		
				if move == moveName then
					if pokemon and 	indexOf(self:getMove(toId(name)).isMax, pokemon.species) then
						return name
					elseif not pokemon then
						foundForMove = true
						return name
					end
				end
			end		
		end
	end
	function Battle:getZMove(move, pokemon, skipChecks)
		local item = pokemon:getItem()
		if not skipChecks then
			if not item.zMove then return end
			if item.zMoveUser and not indexOf(item.zMoveUser, pokemon.species) then return end
		end
		if item.zMoveFrom then
			if move.name == item.zMoveFrom then return item.zMove end
		elseif item.zMove == true then
			if move.type == item.zMoveType then
				if move.category == "Status" then
					return 'Z-'..move.name--
				else
					return self.zMoveTable[move.type]
				end	
			end
		end
	end
	function Battle:canZMove(pokemon)
		--[[if pokemon.side.isTwoPlayerSide then 
			if not pokemon.side.zmoveAdornment[pokemon.teamn] then return end
		else
			if not pokemon.side.zmoveAdornment then return end
		end]]--

		local item = pokemon:getItem()

		if not item.zMove then return end

		if item.zMoveUser and not indexOf(item.zMoveUser, pokemon.species) then return end

		local atLeastOne = false
		local zMoves = {}
		for _, m in pairs(pokemon.moves) do
			local move = self:getMove(m)
			local zMove = self:getZMove(move, pokemon, true) or ''
			table.insert(zMoves, zMove)
			if zMove then atLeastOne = true end
		end

		if atLeastOne then

			return zMoves
		end
	end
	function Battle:newBasePower(move, new)
		if new.ExlcusivePwr then return new.ExlcusivePwr end

		local basePower = move.basePower
		local pwr = 1
		if new.isZ then -- Should I add a check for status?
			if basePower < 56 then pwr = 100
			elseif basePower < 76 then pwr = 140 
			elseif basePower < 86 then pwr = 160 
			elseif basePower < 96 then pwr = 175 
			elseif basePower < 101 then pwr = 180 
			elseif basePower < 111 then pwr = 185 
			elseif basePower < 126 then pwr = 190 
			elseif basePower < 131 then pwr = 195 
			elseif basePower > 130 then pwr = 200 end
		end
		return pwr
	end
	function Battle:getActiveZMove(move, pokemon)
		self:add('-zmove', pokemon, 'zmove')

		-- Makes it where only 1 Pokemon can use a z move per a team.
		pokemon.canZMove= false
		for _, ally in pairs(pokemon.side.pokemon) do
			if ally.canZMove and ally ~= pokemon and ally.teamn == pokemon.teamn then
				ally.canZMove = false
			end
		end

		if (pokemon) then
			local item = pokemon:getItem()
			if (move.name == item.zMoveFrom) then
				local zMove = self:getMove(item.zMove)
				zMove.isZOrMaxPowered = true
				zMove.basePower = self:newBasePower(move, zMove)
				return zMove;
			end
		end

		if (move.category == 'Status') then
			local zMove = self:getMove(move)
			zMove.isZ = true
			zMove.isZOrMaxPowered = true
			return zMove
		end
		local zMove = self:getMove(self.zMoveTable[move.type])
		zMove.category = move.category
		zMove.priority = move.priority
		zMove.basePower = self:newBasePower(move, zMove)
		zMove.isZOrMaxPowered = true --Should I Merge BreaksProtect Under IsZorMaxPowered?
		zMove.breaksProtect = true
		return zMove
	end
	function Battle:runZPower(move, pokemon)
		local zPower = self:getEffect('zpower')
		local bonus = self:findIn(move.name)
		print(move..''..(bonus or ''))
		if (move.category == 'Status') then --Should I add a default Status boost if one can't be found? 
			self:attrLastMove('[zeffect]')
			if (bonus:sub(4, 4) == '1' or bonus:sub(4, 4) == '2' or bonus:sub(4, 4) == '3') then
				local atk, num = bonus:match("^(%a+)(%d-)$")
				self:boost({[atk] = tonumber(num)}, pokemon, pokemon, zPower);
				self:add('-boostFromZEffect', pokemon, atk, tonumber(num));		
			elseif (bonus == 'acc') then
				self:boost({accuracy = 1}, pokemon, pokemon, zPower);
				self:add('-boostFromZEffect', pokemon, 'accuracy', 1);
			elseif (bonus == 'all') then
				self:boost({atk = 1,def = 1,spa = 1,spd = 1,spe = 1}, pokemon, pokemon, zPower);
				self:add('-boostMultipleFromZEffect', pokemon);
			elseif not (bonus.boost) then
				if bonus == 'heal' then
					self:heal(pokemon.maxhp, pokemon, pokemon, zPower)
					self:add('-healFromZEffect', pokemon)				
				elseif bonus ==  'healreplacement' then
					move.self = {slotCondition = 'healingwish'}
					self:add('-healreplacement', pokemon)				
				elseif bonus == 'clearnegativeboost' then
					local boosts = {}
					for i in pairs(pokemon.boosts) do
						if pokemon.boosts[i] < 0 then
							pokemon.boosts[i] = 0
						end
					end
					pokemon:setBoost(boosts);
					self:add('-clearnegativeboost', pokemon, '[zeffect]');

				elseif bonus == 'redirect' then
					pokemon:addVolatile('followme', pokemon, zPower);				
				elseif bonus == 'crit2' then
					pokemon:addVolatile('focusenergy', pokemon, zPower);

				elseif bonus ==  'curse' then
					if (pokemon:hasType('Ghost')) then
						self:heal(pokemon.maxhp, pokemon, pokemon, zPower);
						self:add('-heal', pokemon, pokemon.getHealth)
					else
						self:boost({atk = 1}, pokemon, pokemon, zPower);
					end
				end
			end
		end
	end
end