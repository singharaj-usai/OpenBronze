local null, Not; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	null = util.null
	Not = util.Not
end

self = nil -- to hush intelisense; self property is injected at object-call simulation; see BattleEngine::call / BattleEngine::callAs

return {
	brn = {
		effectType = 'Status',
		onStart = function(target, source, sourceEffect)
			if sourceEffect and sourceEffect.id == 'flameorb' then
				self:add('-status', target, 'brn', '[from] item: Flame Orb')
				return
			elseif self.statusSourceMessage then
				self:add(unpack(self.statusSourceMessage))
			end
			self:add('-status', target, 'brn')
		end,
		-- Damage reduction is handled directly in the BattleEngine damage function
		onResidualOrder = 9,
		onResidual = function(pokemon)
			self:damage(pokemon.maxhp / 8)
		end,
	},
	par = {
		effectType = 'Status',
		onStart = function(target, source, sourceEffect)
			if self.statusSourceMessage then
				self:add(unpack(self.statusSourceMessage))
			end
			self:add('-status', target, 'par')
		end,
		onModifySpe = function(spe, pokemon)
			if not pokemon:hasAbility('quickfeet') then
				return self:chainModify(0.25)
			end
		end,
		onBeforeMovePriority = 1,
		onBeforeMove = function(pokemon)
			if math.random(4) == 1 then
				self:add('cant', pokemon, 'par')
				return false
			end
		end,
	},
	slp = {
		effectType = 'Status',
		onStart = function(target)
			if self.statusSourceMessage then
				self:add(unpack(self.statusSourceMessage))
			end
			self:add('-status', target, 'slp')
			-- 1-3 turns
			self.effectData.startTime = math.random(2, 4)
			self.effectData.time = self.effectData.startTime
		end,
		onBeforeMovePriority = 10,
		onBeforeMove = function(pokemon, target, move)
			pokemon.statusData.time = pokemon.statusData.time - (pokemon:hasAbility('earlybird') and 2 or 1)
			if pokemon.statusData.time <= 0 then
				pokemon:cureStatus()
				return
			end
			self:add('cant', pokemon, 'slp')
			if move.sleepUsable then
				return
			end
			return false
		end,
	},
	frz = {
		effectType = 'Status',
		onStart = function(target)
			self:add('-status', target, 'frz')
			if target.template.species == 'Shaymin' and target.template.forme == 'sky' and target.baseTemplate.species == target.species then
				local template = self:getTemplate('Shaymin')
				target:formeChange(template)
				target.baseTemplate = template
				target:setAbility(template.abilities[1])
				target.baseAbility = target.ability
				target.details = template.species .. ', L' .. target.level .. (target.gender == '' and '' or ', ') .. target.gender .. (target.set.shiny and ', shiny' or '')
				self:add('detailschange', target, target.details)
				self:add('-formechange', target, 'Shaymin', '[msg]')
			end
		end,
		onBeforeMovePriority = 10,
		onBeforeMove = function(pokemon, target, move)
			if move.flags['defrost'] then return end
			if math.random(5) == 1 then
				pokemon:cureStatus()
				return
			end
			self:add('cant', pokemon, 'frz')
			return false
		end,
		onModifyMove = function(move, pokemon)
			if move.flags['defrost'] then
				self:add('-curestatus', pokemon, 'frz', '[from] move: ' .. move)
				pokemon:setStatus('')
			end
		end,
		onHit = function(target, source, move)
			if move.thawsTarget or (move.type == 'Fire' and move.category ~= 'Status') then
				target:cureStatus()
			end
		end,
	},
	psn = {
		effectType = 'Status',
		onStart = function(target)
			if self.statusSourceMessage then
				self:add(unpack(self.statusSourceMessage))
			end
			self:add('-status', target, 'psn')
		end,
		onResidualOrder = 9,
		onResidual = function(pokemon)
			self:damage(pokemon.maxhp / 8)
		end,
	},
	tox = {
		effectType = 'Status',
		onStart = function(target, source, sourceEffect)
			self.effectData.stage = 0
			if sourceEffect and sourceEffect.id == 'toxicorb' then
				self:add('-status', target, 'tox', '[from] item: Toxic Orb')
				return
			end
			self:add('-status', target, 'tox')
		end,
		onSwitchIn = function()
			self.effectData.stage = 0
		end,
		onResidualOrder = 9,
		onResidual = function(pokemon)
			if self.effectData.stage < 15 then
				self.effectData.stage = self.effectData.stage + 1
			end
			self:damage(self:clampIntRange(pokemon.maxhp / 16, 1) * self.effectData.stage)
		end,
	},
	confusion = {
		-- this is a volatile status
		onStart = function(target, source, sourceEffect)
			local result = self:runEvent('TryConfusion', target, source, sourceEffect)
			if Not(result) then return result end
			if sourceEffect and sourceEffect.id == 'lockedmove' then
				self:add('-start', target, 'confusion', '[fatigue]')
			else
				self:add('-start', target, 'confusion')
			end
			self.effectData.time = math.random(2, 5)
		end,
		onEnd = function(target)
			self:add('-end', target, 'confusion')
		end,
		onBeforeMovePriority = 3,
		onBeforeMove = function(pokemon)
			pokemon.volatiles.confusion.time = pokemon.volatiles.confusion.time - 1
			if pokemon.volatiles.confusion.time == 0 then
				pokemon:removeVolatile('confusion')
				return
			end
			self:add('-activate', pokemon, 'confusion');
			if math.random(2) == 1 then
				return
			end
			self:damage(self:getDamage(pokemon, pokemon, 40), pokemon, pokemon, {
				id = 'confused',
				effectType = 'Move',
				type = '???'
			})
			return false
		end,
	},
	flinch = {
		duration = 1,
		onBeforeMovePriority = 8,
		onBeforeMove = function(pokemon)
			if Not(self:runEvent('Flinch', pokemon)) then
				return
			end
			self:add('cant', pokemon, 'flinch')
			return false
		end,
	},
	trapped = {
		noCopy = true,
		onModifyPokemon = function(pokemon)
			pokemon:tryTrap()
		end,
		onStart = function(target)
			self:add('-activate', target, 'trapped')
		end,
	},
	trapper = {
		noCopy = true
	},
	partiallytrapped = {
		duration = 5,
		durationCallback = function(target, source)
			if source:hasItem('gripclaw') then return 8 end
			return math.random(5, 6)
		end,
		onStart = function(pokemon, source)
			self:add('-activate', pokemon, 'move: ' .. self.effectData.sourceEffect, '[of] ' .. source)
		end,
		onResidualOrder = 11,
		onResidual = function(pokemon)
			if self.effectData.source and (not self.effectData.source.isActive or self.effectData.source.hp <= 0) then
				pokemon.volatiles['partiallytrapped'] = nil
				return
			end
			if self.effectData.source:hasItem('bindingband') then
				self:damage(pokemon.maxhp / 6)
			else
				self:damage(pokemon.maxhp / 8)
			end
		end,
		onEnd = function(pokemon)
			self:add('-end', pokemon, self.effectData.sourceEffect, '[partiallytrapped]')
		end,
		onModifyPokemon = function(pokemon)
			pokemon:tryTrap()
		end,
	},
	lockedmove = {
		-- Outrage, Thrash, Petal Dance...
		duration = 2,
		onResidual = function(target)
			if target.status == 'slp' then
				-- don't lock, and bypass confusion for calming
				target.volatiles.lockedmove = nil
			end
			self.effectData.trueDuration = self.effectData.trueDuration - 1
		end,
		onStart = function(target, source, effect)
			self.effectData.trueDuration = math.random(2, 3)
			self.effectData.move = effect.id
		end,
		onRestart = function()
			if self.effectData.trueDuration >= 2 then
				self.effectData.duration = 2
			end
		end,
		onEnd = function(target)
			if self.effectData.trueDuration > 1 then return end
			target:addVolatile('confusion')
		end,
		onLockMove = function(pokemon)
			return self.effectData.move
		end,
	},
	twoturnmove = {
		-- Skull Bash, SolarBeam, Sky Drop...
		duration = 2,
		onStart = function(target, source, effect)
			self.effectData.move = effect.id
			-- source and target are reversed since the event target is the
			-- pokemon using the two-turn move
			self.effectData.targetLoc = self:getTargetLoc(source, target)
			target:addVolatile(effect.id, source)
		end,
		onEnd = function(target)
			target:removeVolatile(self.effectData.move)
		end,
		onLockMove = function()
			return self.effectData.move
		end,
		onLockMoveTarget = function()
			return self.effectData.targetLoc
		end,
	},
	choicelock = {
		onStart = function(pokemon)
			if not self.activeMove.id or (self.activeMove.sourceEffect and self.activeMove.sourceEffect ~= self.activeMove.id) then return false end
			self.effectData.move = self.activeMove.id
		end,
		onDisableMove = function(pokemon)
			if pokemon:getItem().isChoice or not pokemon:hasMove(self.effectData.move) then
				pokemon:removeVolatile('choicelock')
				return
			end
			if pokemon:ignoringItem() then return end
			for _, move in pairs(pokemon.moveset) do
				if move.id ~= self.effectData.move then
					pokemon:disableMove(move.id, false, self.effectData.sourceEffect)
				end
			end
		end,
	},
	mustrecharge = {
		duration = 2,
		onBeforeMovePriority = 11,
		onBeforeMove = function(pokemon)
			self:add('cant', pokemon, 'recharge')
			pokemon:removeVolatile('mustrecharge')
			return false
		end,
		onLockMove = function(pokemon)
			self:add('-mustrecharge', pokemon)
			return 'recharge'
		end
	},
	futuremove = {
		-- this is a side condition
		onStart = function(side)
			self.effectData.positions = {}
		end,
		onResidualOrder = 3,
		onResidual = function(side)
			local finished = true
			for i = 1, #side.active do
				local posData = self.effectData.positions[i]
				if posData then
					posData.duration = posData.duration - 1
					
					if posData.duration > 0 then
						finished = false
					else	
						-- time's up; time to hit! :D
						local target = side.foe.active[posData.targetPosition]
						local move = self:getMove(posData.move)
						if target.fainted then
							self:add('-hint', move.name .. ' did not hit because the target is fainted.')
							self.effectData.positions[i] = nil
						else
							self:add('-end', target, 'move: ' .. move.name)
							target:removeVolatile('Protect')
							target:removeVolatile('Endure')
							
							if posData.moveData.ignoreImmunity == nil then
								posData.moveData.ignoreImmunity = false
							end
							
							if target:hasAbility('wonderguard') then
								self:debug('Wonder Guard immunity: ' .. move.id)
								if target:runEffectiveness(move) <= 1 then
									self:add('-activate', target, 'ability: Wonder Guard')
									self.effectData.positions[i] = nil
									return null
								end
							end
							
							self:moveHit(target, posData.source, move, posData.moveData)
							
							self.effectData.positions[i] = nil
						end
					end
				end
			end
			if finished then
				side:removeSideCondition('futuremove')
			end
		end,
	},
	stall = {
		-- Protect, Detect, Endure counter
		duration = 2,
		counterMax = 729,
		onStart = function()
			self.effectData.counter = 3
		end,
		onStallMove = function()
			-- self.effectData.counter should never be undefined here.
			-- However, just in case, use 1 if it is undefined.
			local counter = self.effectData.counter or 1
			self:debug("Success chance: " .. math.floor(100 / counter + 0.5) .. "%")
			return math.random(counter) == 1
		end,
		onRestart = function()
			if self.effectData.counter < self.effect.counterMax then
				self.effectData.counter = self.effectData.counter * 3
			end
			self.effectData.duration = 2
		end,
	},
	gem = {
		duration = 1,
		affectsFainted = true,
		onBasePower = function(basePower, user, target, move)
			self:debug('Gem Boost')
			return self:chainModify(0x14CD, 0x1000)
		end,
	},
	aura = {
		duration = 1,
		onBasePowerPriority = 8,
		onBasePower = function(basePower, user, target, move)
			local modifier = 0x1547
			self:debug('Aura Boost')
			if user.volatiles['aurabreak'] then
				modifier = 0x0C00
				self:debug('Aura Boost reverted by Aura Break')
			end
			return self:chainModify(modifier, 0x1000)
		end,
	},
	
	-- weather
	raindance = {
		effectType = 'Weather',
		duration = 5,
		durationCallback = function(source, effect)
			if source and source:hasItem('damprock') then
				return 8
			end
			return 5
		end,
		onWeatherModifyDamage = function(damage, attacker, defender, move)
			if move.type == 'Water' then
				self:debug('rain water boost')
				return self:chainModify(1.5)
			end
			if move.type == 'Fire' then
				self:debug('rain fire suppress')
				return self:chainModify(0.5)
			end
		end,
		onStart = function(battle, source, effect)
			self:add('-weather', 'RainDance', source and ('[of] '..source), effect and ('[from] '..effect))
		end,
		onResidualOrder = 1,
		onResidual = function()
			self:add('-weather', 'RainDance', '[upkeep]')
			self:eachEvent('Weather')
		end,
		onEnd = function()
			self:add('-weather', 'none')
		end,
	},
	primordialsea = {
		effectType = 'Weather',
		duration = 0,
		onTryMove = function(target, source, effect)
			if effect.type == 'Fire' and effect.category ~= 'Status' then
				self:debug('Primordial Sea fire suppress')
				self:add('-fail', source, effect, '[from] Primordial Sea')
				return null
			end
		end,
		onWeatherModifyDamage = function(damage, attacker, defender, move)
			if move.type == 'Water' then
				self:debug('Rain water boost')
				return self:chainModify(1.5)
			end
		end,
		onStart = function()
			self:add('-weather', 'PrimordialSea')
		end,
		onResidualOrder = 1,
		onResidual = function()
			self:add('-weather', 'PrimordialSea', '[upkeep]')
			self:eachEvent('Weather')
		end,
		onEnd = function()
			self:add('-weather', 'none')
		end
	},
	sunnyday = {
		effectType = 'Weather',
		duration = 5,
		durationCallback = function(source, effect)
			if source and source:hasItem('heatrock') then
				return 8
			end
			return 5
		end,
		onWeatherModifyDamage = function(damage, attacker, defender, move)
			if move.type == 'Fire' then
				self:debug('Sunny Day fire boost')
				return self:chainModify(1.5)
			end
			if move.type == 'Water' then
				self:debug('Sunny Day water suppress')
				return self:chainModify(0.5)
			end
		end,
		onStart = function(battle, source, effect)
			self:add('-weather', 'SunnyDay', source and ('[of] '..source), effect and ('[from] '..effect))
		end,
		onImmunity = function(kind)
			if kind == 'frz' then return false end
		end,
		onResidualOrder = 1,
		onResidual = function()
			self:add('-weather', 'SunnyDay', '[upkeep]')
			self:eachEvent('Weather')
		end,
		onEnd = function()
			self:add('-weather', 'none')
		end,
	},
	desolateland = {
		effectType = 'Weather',
		duration = 0,
		onTryMove = function(target, source, effect)
			if effect.type == 'Water' and effect.category ~= 'Status' then
				self:debug('Desolate Land water suppress')
				self:add('-fail', source, effect, '[from] Desolate Land')
				return null
			end
		end,
		onWeatherModifyDamage = function(damage, attacker, defender, move)
			if move.type == 'Fire' then
				self:debug('Sunny Day fire boost')
				return self:chainModify(1.5)
			end
		end,
		onStart = function()
			self:add('-weather', 'DesolateLand')
		end,
		onImmunity = function(type)
			if type == 'frz' then return false end
		end,
		onResidualOrder = 1,
		onResidual = function()
			self:add('-weather', 'DesolateLand', '[upkeep]')
			self:eachEvent('Weather')
		end,
		onEnd = function()
			self:add('-weather', 'none')
		end
	},
	sandstorm = {
		effectType = 'Weather',
		duration = 5,
		durationCallback = function(source, effect)
			if source and source:hasItem('smoothrock') then
				return 8
			end
			return 5
		end,
		-- This should be applied directly to the stat before any of the other modifiers are chained
		-- So we give it increased priority.
		onModifySpDPriority = 10,
		onModifySpD = function(spd, pokemon)
			if pokemon:hasType('Rock') and self:isWeather('sandstorm') then
				return self:modify(spd, 1.5)
			end
		end,
		onStart = function(battle, source, effect)
--			print('EFFECT:')
--			require(game.ServerStorage.Utilities).print_r(effect)
			self:add('-weather', 'Sandstorm', source and ('[of] '..source), (effect and effect.id and effect.id ~= '') and ('[from] '..effect) or nil)
		end,
		onResidualOrder = 1,
		onResidual = function()
			self:add('-weather', 'Sandstorm', '[upkeep]')
			if self:isWeather('sandstorm') then self:eachEvent('Weather') end
		end,
		onWeather = function(target)
			self:damage(target.maxhp / 16)
		end,
		onEnd = function()
			self:add('-weather', 'none')
		end,
	},
	hail = {
		effectType = 'Weather',
		duration = 5,
		durationCallback = function(source, effect)
			if source and source:hasItem('icyrock') then
				return 8
			end
			return 5
		end,
		onStart = function(battle, source, effect)
			self:add('-weather', 'Hail', source and ('[of] '..source), effect and ('[from] '..effect))
		end,
		onResidualOrder = 1,
		onResidual = function()
			self:add('-weather', 'Hail', '[upkeep]')
			if self:isWeather('hail') then self:eachEvent('Weather') end
		end,
		onWeather = function(target)
			self:damage(target.maxhp / 16)
		end,
		onEnd = function()
			self:add('-weather', 'none')
		end,
	},
	deltastream = {
		effectType = 'Weather',
		duration = 0,
		onEffectiveness = function(typeMult, target, type, move)
			if move and move.effectType == 'Move' and type == 'Flying' and typeMult > 1 then
				self:add('-activate', '', 'deltastream')
				return 1
			end
		end,
		onStart = function()
			self:add('-weather', 'DeltaStream')
		end,
		onResidualOrder = 1,
		onResidual = function()
			self:add('-weather', 'DeltaStream', '[upkeep]')
			self:eachEvent('Weather')
		end,
		onEnd = function()
			self:add('-weather', 'none')
		end
	},

	arceus = {
		-- Arceus's actual typing is implemented here
		-- Arceus's true typing for all its formes is Normal, and it's only
		-- Multitype that changes its type, but its formes are specified to
		-- be their corresponding type in the Pokedex, so that needs to be
		-- overridden.
		onSwitchInPriority = 101,
		onSwitchIn = function(pokemon)
			local _type = 'Normal'
			if pokemon.ability == 'multitype' then
				_type = pokemon:getItem().onPlate
				if Not(_type) or _type == true then
					_type = 'Normal'
				end
			end
			pokemon:setType(_type, true)
		end,
	},
}