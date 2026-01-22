local null, Not, filter; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	null = util.null
	Not = util.Not
	filter = util.filter
end

--[[
	Todo:
	Oblivious
	
	Pickup (after battle)
--]]

self = nil -- to hush intelisense; self property is injected at object-call simulation; see BattleEngine::call / BattleEngine::callAs

return {
	['battlebond'] = {
		onSourceFaint = function(target, source, effect)
			if effect and effect.effectType == 'Move' and source.template.species == 'Greninja' and source.template.forme == 'BB' and source.hp > 0 and not source.transformed and source.side.foe.pokemonLeft > 0 then
				self:add('-activate', source, 'ability: Battle Bond')
				local template = self:getTemplate('Greninja-Ash')
				source:formeChange(template)
				source.baseTemplate = template
				source.details = template.species .. ', L' .. source.level .. (source.gender == '' and '' or ', ') .. source.gender .. (source.set.shiny and ', shiny' or '')
				self:add('detailschange', source, source.details, '[battleBond]', '[icon] '..(template.icon or 0))
				local shinyPrefix = source.shiny and '_SHINY' or ''
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/Greninja-ash')
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/Greninja-ash')
				
				source.iconOverride = template.icon-1
				-- is there a better way to access this?
				source.frontSpriteOverride = require(game:GetService('ServerStorage').Data.Spritesheets)[shinyPrefix..'_FRONT']['Greninja-ash']
				source.baseStatOverride = template.baseStats
			end
		end,
		onModifyMove = function(move, attacker)
			if move.id == 'watershuriken' and attacker.template.species == 'Greninja' and attacker.template.forme == 'Ash' then
--				self:debug('battle bond modify watershuriken')
				-- for some reason base power is handled on the move itself
				move.multihit = 3
			end
		end,
		id = "battlebond",
		name = "Battle Bond",
		rating = 3,
		num = 210,
	},
	['liquidvoice'] = {
		onModifyMovePriority = -1,
		onModifyMove = function(move)
			if move.flags and move.flags['sound'] then
				move.type = 'Water'
			end
		end,
		id = "liquidvoice",
		name = "Liquid Voice",
		rating = 2.5,
		num = 204,
	},
	['longreach'] = {
		onModifyMove = function(move)
			if move.flags then
				move.flags['contact'] = nil
			end
		end,
		id = "longreach",
		name = "Long Reach",
		rating = 1.5,
		num = 203,
	},
	['slushrush'] = {
		onModifySpe = function(spe, pokemon)
			if self:isWeather('hail') then
				return self:chainModify(2)
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'hail' then return false end
		end,
		id = "slushrush",
		name = "Slush Rush",
		rating = 2.5,
		num = 202,
	},
	
	['adaptability'] = {
		onModifyMove = function(move)
			move.stab = 2
		end,
		id = "adaptability",
		name = "Adaptability",
		rating = 3.5,
		num = 91
	},
	['aftermath'] = {
		id = "aftermath",
		name = "Aftermath",
		onAfterDamageOrder = 1,
		onAfterDamage = function(damage, target, source, move)
			if source and source ~= target and move and move.flags['contact'] and target.hp <= 0 then
				self:damage(source.maxhp / 4, source, target, nil, true)
			end
		end,
		rating = 2.5,
		num = 106
	},
	['aerilate'] = {
		onModifyMovePriority = -1,
		onModifyMove = function(move, pokemon)
			if move.type == 'Normal' and move.id ~= 'naturalgift' then
				move.type = 'Flying'
				if move.category ~= 'Status' then
					pokemon:addVolatile('aerilate')
				end
			end
		end,
		effect = {
			duration = 1,
			onBasePowerPriority = 8,
			onBasePower = function(basePower, pokemon, target, move)
				return self:chainModify(0x14CD, 0x1000)
			end
		},
		id = "aerilate",
		name = "Aerilate",
		rating = 4,
		num = 185
	},
	['airlock'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Air Lock')
		end,
		suppressWeather = true,
		id = "airlock",
		name = "Air Lock",
		rating = 3,
		num = 76
	},
	['analytic'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if not self:willMove(defender) then
				self:debug('Analytic boost')
				return self:chainModify(0x14CD, 0x1000)
			end
		end,
		id = "analytic",
		name = "Analytic",
		rating = 2,
		num = 148
	},
	['angerpoint'] = {
		onAfterDamage = function(damage, target, source, move)
			if target.hp <= 0 then return end
			if move and move.effectType == 'Move' and move.crit then
				target:setBoost({atk = 6})
				self:add('-setboost', target, 'atk', 12, '[from] ability: Anger Point')
			end
		end,
		id = "angerpoint",
		name = "Anger Point",
		rating = 2,
		num = 83
	},
	['anticipation'] = {
		onStart = function(pokemon)
			for _, target in pairs(pokemon.side.foe.active) do
				if target ~= null and not target.fainted then
					for _, m in pairs(target.moveset) do
						local move = self:getMove(m.move)
						if move.category ~= 'Status' and (self:getImmunity(move.type, pokemon) and self:getEffectiveness(move.type, pokemon) > 1 or move.ohko) then
							self:add('-ability', pokemon, 'Anticipation')
							return
						end
					end
				end
			end
		end,
		id = "anticipation",
		name = "Anticipation",
		rating = 1,
		num = 107
	},
	['arenatrap'] = {
		onFoeModifyPokemon = function(pokemon)
			if not self:isAdjacent(pokemon, self.effectData.target) then return end
			if pokemon:isGrounded() then
				pokemon:tryTrap(true, self.effectData.target, 'Arena Trap')
			end
		end,
		onFoeMaybeTrapPokemon = function(pokemon, source)
			if not source then source = self.effectData.target end
			if not self:isAdjacent(pokemon, source) then return end
			if pokemon:isGrounded() then
				pokemon.maybeTrapped = true
			end
		end,
		id = "arenatrap",
		name = "Arena Trap",
		rating = 4.5,
		num = 71
	},
	['aromaveil'] = {
		onAllyTryHit = function(target, source, move)
			local protects = {'attract', 'disable', 'encore', 'healblock', 'taunt', 'torment'}
			if move and protects[move.id] then
				return false
			end
		end,
		id = "aromaveil",
		name = "Aroma Veil",
		rating = 1.5,
		num = 165
	},
	['aurabreak'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Aura Break')
		end,
		onAnyTryPrimaryHit = function(target, source, move)
			if target == source or move.category == 'Status' then return end
			source:addVolatile('aurabreak')
		end,
		effect = {
			duration = 1
		},
		id = "aurabreak",
		name = "Aura Break",
		rating = 2,
		num = 188
	},
	['baddreams'] = {
		onResidualOrder = 26,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			if pokemon.hp <= 0 then return end
			for _, target in pairs(pokemon.side.foe.active) do
				if target ~= null and target.hp > 0 then
					if target.status == 'slp' then
						self:damage(target.maxhp / 8, target)
					end
				end
			end
		end,
		id = "baddreams",
		name = "Bad Dreams",
		rating = 2,
		num = 123
	},
	['battlearmor'] = {
		onCriticalHit = function() return false end,
		id = "battlearmor",
		name = "Battle Armor",
		rating = 1,
		num = 4
	},
	['bigpecks'] = {
		onBoost = function(boost, target, source, effect)
			if source and target == source then return end
			if boost['def'] and boost['def'] < 0 then
				boost['def'] = 0
				if not effect.secondaries then
					self:add("-fail", target, "unboost", "Defense", "[from] ability = Big Pecks", "[of] " .. target)
				end
			end
		end,
		id = "bigpecks",
		name = "Big Pecks",
		rating = 0.5,
		num = 145
	},
	['blaze'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk, attacker, defender, move)
			if move.type == 'Fire' and attacker.hp <= attacker.maxhp/3 then
				self:debug('Blaze boost')
				return self:chainModify(1.5)
			end
		end,
		onModifySpAPriority = 5,
		onModifySpA = function(atk, attacker, defender, move)
			if move.type == 'Fire' and attacker.hp <= attacker.maxhp/3 then
				self:debug('Blaze boost')
				return self:chainModify(1.5)
			end
		end,
		id = "blaze",
		name = "Blaze",
		rating = 2,
		num = 66
	},
	['bulletproof'] = {
		onTryHit = function(pokemon, target, move)
			if move.flags['bullet'] then
				self:add('-immune', pokemon, '[msg]', '[from] Bulletproof')
				return null
			end
		end,
		id = "bulletproof",
		name = "Bulletproof",
		rating = 3,
		num = 171
	},
	['cheekpouch'] = {
		onEatItem = function(item, pokemon)
			self:heal(pokemon.maxhp / 3)
		end,
		id = "cheekpouch",
		name = "Cheek Pouch",
		rating = 2,
		num = 167
	},
	['chlorophyll'] = {
		onModifySpe = function(spe)
			if self:isWeather({'sunnyday', 'desolateland'}) then
				return self:chainModify(2)
			end
		end,
		id = "chlorophyll",
		name = "Chlorophyll",
		rating = 2.5,
		num = 34
	},
	['clearbody'] = {
		onBoost = function(boost, target, source, effect)
			if source and target == source then return end
			local showMsg = false
			for i, b in pairs(boost) do
				if b < 0 then
					boost[i] = nil
					showMsg = true
				end
			end
			if showMsg and not effect.secondaries then
				self:add("-fail", target, "unboost", "[from] ability = Clear Body", "[of] " .. target)
			end
		end,
		id = "clearbody",
		name = "Clear Body",
		rating = 2,
		num = 29
	},
	['cloudnine'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Cloud Nine')
		end,
		suppressWeather = true,
		id = "cloudnine",
		name = "Cloud Nine",
		rating = 3,
		num = 13
	},
	['colorchange'] = {
		onAfterMoveSecondary = function(target, source, move)
			local type = move.type
			if target.isActive and move.effectType == 'Move' and move.category ~= 'Status' and type ~= '???' and not target:hasType(type) then
				if not target:setType(type) then return false end
				self:add('-start', target, 'typechange', type, '[from] Color Change')
				target:update()
			end
		end,
		id = "colorchange",
		name = "Color Change",
		rating = 1,
		num = 16
	},
	['competitive'] = {
		onAfterEachBoost = function(boost, target, source)
			if not source or target.side == source.side then return end
			local statsLowered = false
			for i, b in pairs(boost) do
				if b < 0 then
					statsLowered = true
					break
				end
			end
			if statsLowered then
				self:boost({spa = 2})
			end
		end,
		id = "competitive",
		name = "Competitive",
		rating = 2.5,
		num = 172
	},
	['compoundeyes'] = {
		onSourceModifyAccuracy = function(accuracy)
			if type(accuracy) ~= 'number' then return end
			self:debug('compoundeyes - enhancing accuracy')
			return accuracy * 1.3
		end,
		-- does this actually work??
		onWildItemChance = function(chance, pokemon)
			if chance == 50 then return 60      -- Common items: 50% -> 60%
			elseif chance == 5 then return 20   -- Uncommon items: 5% -> 20%
			elseif chance == 1 then return 5    -- Rare items: 1% -> 5%
			end
			return chance
		end,
		id = "compoundeyes",
		name = "Compound Eyes",
		rating = 3.5,
		num = 14
	},
	['contrary'] = {
		onBoost = function(boost)
			for i, b in pairs(boost) do
				boost[i] = -b
			end
		end,
		id = "contrary",
		name = "Contrary",
		rating = 4,
		num = 126
	},
	['cursedbody'] = {
		onAfterDamage = function(damage, target, source, move)
			if not source or source.volatiles['disable'] then return end
			if source ~= target and move and move.effectType == 'Move' then
				if math.random(10) <= 3 then
					source:addVolatile('disable')
				end
			end
		end,
		id = "cursedbody",
		name = "Cursed Body",
		rating = 2,
		num = 130
	},
	['cutecharm'] = {
		onAfterDamage = function(damage, target, source, move)
			if move and move.flags['contact'] then
				if math.random(10) <= 3 then
					source:addVolatile('attract', target)
				end
			end
		end,
		id = "cutecharm",
		name = "Cute Charm",
		rating = 1,
		num = 56
	},
	['damp'] = {
		id = "damp",
		onAnyTryMove = function(target, source, effect)
			if effect.id == 'selfdestruct' or effect.id == 'explosion' then
				self:attrLastMove('[still]')
				self:add('-activate', self.effectData.target, 'ability = Damp')
				return false
			end
		end,
		onAnyDamage = function(damage, target, source, effect)
			if effect and effect.id == 'aftermath' then
				return false
			end
		end,
		name = "Damp",
		rating = 1,
		num = 6
	},
	['darkaura'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Dark Aura')
		end,
		onAnyTryPrimaryHit = function(target, source, move)
			if target == source or move.category == 'Status' then return end
			if move.type == 'Dark' then
				source:addVolatile('aura')
			end
		end,
		id = "darkaura",
		name = "Dark Aura",
		rating = 3,
		num = 186
	},
	['defeatist'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk, pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				return self:chainModify(0.5)
			end
		end,
		onModifySpAPriority = 5,
		onModifySpA = function(atk, pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				return self:chainModify(0.5)
			end
		end,
		onResidual = function(pokemon)
			pokemon:update()
		end,
		id = "defeatist",
		name = "Defeatist",
		rating = -1,
		num = 129
	},
	['defiant'] = {
		onAfterEachBoost = function(boost, target, source)
			if not source or target.side == source.side then return end
			local statsLowered = false
			for i, b in pairs(boost) do
				if b < 0 then
					statsLowered = true
					break
				end
			end
			if statsLowered then
				self:boost({atk = 2})
			end
		end,
		id = "defiant",
		name = "Defiant",
		rating = 2.5,
		num = 128
	},
	['deltastream'] = {
		onStart = function(source)
			self:setWeather('deltastream')
		end,
		onAnySetWeather = function(target, source, weather)
			local weathers = {desolateland=true, primordialsea=true, deltastream=true}
			if self:getWeather().id == 'deltastream' and not weathers[weather.id] then return false end
		end,
		onEnd = function(pokemon)
			if self.weatherData.source ~= pokemon then return end
			for _, side in pairs(self.sides) do
				for _, target in pairs(side.active) do
					if target ~= null and target ~= pokemon and target.hp > 0 and target:hasAbility('deltastream') then
						self.weatherData.source = target
						return
					end
				end
			end
			self:clearWeather()
		end,
		id = "deltastream",
		name = "Delta Stream",
		rating = 5,
		num = 191
	},
	['desolateland'] = {
		onStart = function(source)
			self:setWeather('desolateland')
		end,
		onAnySetWeather = function(target, source, weather)
			local weathers = {desolateland=true, primordialsea=true, deltastream=true}
			if self:getWeather().id == 'desolateland' and not weathers[weather.id] then return false end
		end,
		onEnd = function(pokemon)
			if self.weatherData.source ~= pokemon then return end
			for _, side in pairs(self.sides) do
				for _, target in pairs(side.active) do
					if target ~= null and target ~= pokemon and target.hp > 0 and target:hasAbility('desolateland') then
						self.weatherData.source = target
						return
					end
				end
			end
			self:clearWeather()
			self.weatherData.source = null
		end,
		onSwitchOut = function(pokemon)
			if self:isWeather({'desolateland'}) then 
				self:add('message', "The harsh sunlight faded.")    
				self.weatherData.source = null
				self:clearWeather()
				return 
			end
		end,
		id = "desolateland",
		name = "Desolate Land",
		rating = 5,
		num = 190
	},
	['download'] = {
		onStart = function(pokemon)
			local totaldef = 0
			local totalspd = 0
			for _, foe in pairs(pokemon.side.foe.active) do
				if foe ~= null and not foe.fainted then
					totaldef = totaldef + foe:getStat('def', false, true)
					totalspd = totalspd + foe:getStat('spd', false, true)
				end
			end
			if totaldef and totaldef >= totalspd then
				self:boost({spa = 1})
			elseif totalspd > 0 then
				self:boost({atk = 1})
			end
		end,
		id = "download",
		name = "Download",
		rating = 4,
		num = 88
	},
	['drizzle'] = {
		onStart = function(source)
			self:setWeather('raindance', source)
		end,
		id = "drizzle",
		name = "Drizzle",
		rating = 4,
		num = 2
	},
	['drought'] = {
		onStart = function(source)
			self:setWeather('sunnyday', source)
		end,
		id = "drought",
		name = "Drought",
		rating = 4,
		num = 70
	},
	['dryskin'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.type == 'Water' then
				local h = self:heal(target.maxhp / 4)
				if not h or h == 0 then
					self:add('-immune', target, '[msg]')
				end
				return null
			end
		end,
		onBasePowerPriority = 7,
		onFoeBasePower = function(basePower, attacker, defender, move)
			if self.effectData.target ~= defender then return end
			if move.type == 'Fire' then
				return self:chainModify(1.25)
			end
		end,
		onWeather = function(target, source, effect)
			if effect.id == 'raindance' or effect.id == 'primordialsea' then
				self:heal(target.maxhp / 8)
			elseif effect.id == 'sunnyday' or effect.id == 'desolateland' then
				self:damage(target.maxhp / 8)
			end
		end,
		id = "dryskin",
		name = "Dry Skin",
		rating = 3.5,
		num = 87
	},
	['earlybird'] = {
		id = "earlybird",
		name = "Early Bird",
		-- Implemented in Statuses
		rating = 2.5,
		num = 48
	},
	['effectspore'] = {
		onAfterDamage = function(damage, target, source, move)
			if move and move.flags['contact'] and (not source.status or source.status == '') and source:runImmunity('powder') then
				local r = math.random(100)
				if r <= 30 then
					self.statusSourceMessage = {'-ability', target, 'effectspore'}
				end
				if r <= 10 then
					source:setStatus('slp', target)
				elseif r <= 20 then
					source:setStatus('par', target)
				elseif r <= 30 then
					source:setStatus('psn', target)
				end
				self.statusSourceMessage = nil
			end
		end,
		id = "effectspore",
		name = "Effect Spore",
		rating = 2,
		num = 27
	},
	['fairyaura'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Fairy Aura')
		end,
		onAnyTryPrimaryHit = function(target, source, move)
			if target == source or move.category == 'Status' then return end
			if move.type == 'Fairy' then
				source:addVolatile('aura')
			end
		end,
		id = "fairyaura",
		name = "Fairy Aura",
		rating = 3,
		num = 187
	},
	['filter'] = {
		onSourceModifyDamage = function(damage, source, target, move)
			if move.typeMod > 0 then --if self:getEffectiveness(move, target) > 1 then
				self:debug('Filter neutralize')
				return self:chainModify(0.75)
			end
		end,
		id = "filter",
		name = "Filter",
		rating = 3,
		num = 111
	},
	['flamebody'] = {
		onAfterDamage = function(damage, target, source, move)
			if move and move.flags['contact'] then
				if math.random(10) <= 3 then
					self.statusSourceMessage = {'-ability', target, 'flamebody'}
					source:trySetStatus('brn', target, move)
					self.statusSourceMessage = nil
				end
			end
		end,
		id = "flamebody",
		name = "Flame Body",
		rating = 2,
		num = 49
	},
	['flareboost'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if attacker.status == 'brn' and move.category == 'Special' then
				return self:chainModify(1.5)
			end
		end,
		id = "flareboost",
		name = "Flare Boost",
		rating = 2.5,
		num = 138
	},
	['flashfire'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.type == 'Fire' then
				move.accuracy = true
				if not target:addVolatile('flashfire') then
					self:add('-immune', target, '[msg]')
				end
				return null
			end
		end,
		onEnd = function(pokemon)
			pokemon:removeVolatile('flashfire')
		end,
		effect = {
			noCopy = true, -- doesn't get copied by Baton Pass
			onStart = function(target)
				self:add('-start', target, 'ability = Flash Fire')
			end,
			onModifyAtkPriority = 5,
			onModifyAtk = function(atk, attacker, defender, move)
				if move.type == 'Fire' then
					self:debug('Flash Fire boost')
					return self:chainModify(1.5)
				end
			end,
			onModifySpAPriority = 5,
			onModifySpA = function(atk, attacker, defender, move)
				if move.type == 'Fire' then
					self:debug('Flash Fire boost')
					return self:chainModify(1.5)
				end
			end,
			onEnd = function(target)
				self:add('-end', target, 'ability: Flash Fire', '[silent]')
			end
		},
		id = "flashfire",
		name = "Flash Fire",
		rating = 3,
		num = 18
	},
	['flowergift'] = {
		onStart = function(pokemon)
			self.effectData.forme = nil
		end,
		onUpdate = function(pokemon)
			if not pokemon.isActive or pokemon.baseTemplate.speciesid ~= 'cherrim' then return end
			if self:isWeather({'sunnyday', 'desolateland'}) then
				if pokemon.template.speciesid ~= 'cherrimsunshine' then
					pokemon:formeChange('Cherrim-Sunshine')
					self:add('-formechange', pokemon, 'Cherrim-Sunshine', '[msg]')
				end
			else
				if pokemon.template.speciesid == 'cherrimsunshine' then
					pokemon:formeChange('Cherrim')
					self:add('-formechange', pokemon, 'Cherrim', '[msg]')
				end
			end
		end,
		onModifyAtkPriority = 3,
		onAllyModifyAtk = function(atk)
			if self.effectData.target.baseTemplate.speciesid ~= 'cherrim' then return end
			if self:isWeather({'sunnyday', 'desolateland'}) then
				return self:chainModify(1.5)
			end
		end,
		onModifySpDPriority = 4,
		onAllyModifySpD = function(spd)
			if self.effectData.target.baseTemplate.speciesid ~= 'cherrim' then return end
			if self:isWeather({'sunnyday', 'desolateland'}) then
				return self:chainModify(1.5)
			end
		end,
		id = "flowergift",
		name = "Flower Gift",
		rating = 2.5,
		num = 122
	},
	['flowerveil'] = {
		onAllyBoost = function(boost, target, source, effect)
			if (source and target == source) or not target:hasType('Grass') then return end
			local showMsg = false
			for i, b in pairs(boost) do
				if b < 0 then
					boost[i] = nil
					showMsg = true
				end
			end
			if showMsg and not effect.secondaries then
				self:add("-fail", target, "unboost", "[from] ability = Flower Veil", "[of] " .. target)
			end
		end,
		onAllySetStatus = function(status, target)
			if target:hasType('Grass') then return false end
		end,
		id = "flowerveil",
		name = "Flower Veil",
		rating = 0,
		num = 166
	},
	['forecast'] = {
		onUpdate = function(pokemon)
			if pokemon.baseTemplate.species ~= 'Castform' or pokemon.transformed then return end
			local forme
			local w = self:effectiveWeather()
			if (w == 'sunnyday' or w == 'desolateland') and pokemon.template.speciesid ~= 'castformsunny' then
				forme = 'Castform-Sunny'
			elseif (w == 'raindance' or w == 'primordialsea') and pokemon.template.speciesid ~= 'castformrainy' then
				forme = 'Castform-Rainy'
			elseif w == 'hail' and pokemon.template.speciesid ~= 'castformsnowy' then
				forme = 'Castform-Snowy'
			elseif pokemon.template.speciesid ~= 'castform' then
				forme = 'Castform'
			end
			if pokemon.isActive and forme then
				pokemon:formeChange(forme)
				self:add('-formechange', pokemon, forme, '[msg]')
			end
		end,
		id = "forecast",
		name = "Forecast",
		rating = 3,
		num = 59
	},
	['forewarn'] = {
		onStart = function(pokemon)
			local warnMoves = {}
			local warnBp = 1
			for _, target in pairs(pokemon.side.foe.active) do
				if target ~= null and not target.fainted then
					for _, m in pairs(target.moveset) do
						local move = self:getMove(m.move)
						local bp = move.basePower
						if move.ohko then bp = 160 end
						if move.id == 'counter' or move.id == 'metalburst' or move.id == 'mirrorcoat' then bp = 120 end
						if (not bp or bp == 0) and move.category ~= 'Status' then bp = 80 end
						if bp > warnBp then
							warnMoves = {{move, target}}
							warnBp = bp
						elseif bp == warnBp then
							table.insert(warnMoves, {move, target})
						end
					end
				end
			end
			if #warnMoves == 0 then return end
			local warnMove = warnMoves[math.random(#warnMoves)]
			self:add('-activate', pokemon, 'ability = Forewarn', warnMove[1], '[of] ' .. warnMove[2])
		end,
		id = "forewarn",
		name = "Forewarn",
		rating = 1,
		num = 108
	},
	['friendguard'] = {
		id = "friendguard",
		name = "Friend Guard",
		onAnyModifyDamage = function(damage, source, target, move)
			if target ~= self.effectData.target and target.side == self.effectData.target.side then
				self:debug('Friend Guard weaken')
				return self:chainModify(0.75)
			end
		end,
		rating = 0,
		num = 132
	},
	['frisk'] = {
		onStart = function(pokemon)
			for _, foe in pairs(pokemon.side.foe.active) do
				if foe ~= null and not foe.fainted then
					if foe.item and foe.item ~= '' then
						self:add('-item', foe, foe:getItem().name, '[from] ability = Frisk', '[of] ' .. pokemon, '[identify]')
					end
				end
			end
		end,
		id = "frisk",
		name = "Frisk",
		rating = 1.5,
		num = 119
	},
	['furcoat'] = {
		onModifyDefPriority = 6,
		onModifyDef = function(def)
			return self:chainModify(2)
		end,
		id = "furcoat",
		name = "Fur Coat",
		rating = 3.5,
		num = 169
	},
	['galewings'] = {
		onModifyPriority = function(priority, pokemon, target, move)
			if move and move.type == 'Flying' then return priority + 1 end
		end,
		id = "galewings",
		name = "Gale Wings",
		rating = 4.5,
		num = 177
	},
	['gluttony'] = {
		onEat = function(item, pokemon)
			-- This triggers when a berry would normally be eaten
			if pokemon.hp <= pokemon.maxhp / 2 then
				return true
			end
		end,
		onEatItem = function(item, pokemon)
			-- Check if the item is a berry
			if not item.isBerry then return end
			-- Allow eating berry at 50% HP instead of 25%
			if pokemon.hp <= pokemon.maxhp / 2 then
				return true
			end
		end,
		id = "gluttony",
		name = "Gluttony",
		rating = 1.5,
		num = 82
	},
	['gooey'] = {
		onAfterDamage = function(damage, target, source, effect)
			if effect and effect.flags['contact'] then
				self:boost({spe = -1}, source, target)
			end
		end,
		id = "gooey",
		name = "Gooey",
		rating = 2.5,
		num = 183
	},
	['grasspelt'] = {
		onModifyDefPriority = 6,
		onModifyDef = function(pokemon) -- shouldn't it be def, pokemon? doesn't *really* matter cuz neither is used
			if self:isTerrain('grassyterrain') then
				return self:chainModify(1.5)
			end
		end,
		id = "grasspelt",
		name = "Grass Pelt",
		rating = 0.5,
		num = 179
	},
	['guts'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk, pokemon)
			if pokemon.status and pokemon.status ~= '' then
				return self:chainModify(1.5)
			end
		end,
		id = "guts",
		name = "Guts",
		rating = 3,
		num = 62
	},
	['harvest'] = {
		id = "harvest",
		name = "Harvest",
		onResidualOrder = 26,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			if self:isWeather({'sunnyday', 'desolateland'}) or math.random(2) == 1 then
				if pokemon.hp and Not(pokemon.item) and self:getItem(pokemon.lastItem).isBerry then
					pokemon:setItem(pokemon.lastItem)
					self:add('-item', pokemon, pokemon:getItem(), '[from] ability = Harvest')
				end
			end
		end,
		rating = 2.5,
		num = 139
	},
	['healer'] = {
		id = "healer",
		name = "Healer",
		onResidualOrder = 5,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			if #pokemon.side.active == 1 then return end
			for _, ally in pairs(pokemon.side.active) do
				if ally ~= null and self:isAdjacent(pokemon, ally) and ally.status and math.random(10) <= 3 then
					ally:cureStatus()
				end
			end
		end,
		rating = 0,
		num = 131
	},
	['heatproof'] = {
		onBasePowerPriority = 7,
		onSourceBasePower = function(basePower, attacker, defender, move)
			if move.type == 'Fire' then
				return self:chainModify(0.5)
			end
		end,
		onDamage = function(damage, target, source, effect)
			if effect and effect.id == 'brn' then
				return damage / 2
			end
		end,
		id = "heatproof",
		name = "Heatproof",
		rating = 2.5,
		num = 85
	},
	
	
	['heavymetal'] = {
		onModifyWeight = function(weight)
			return weight * 2
		end,
		id = "heavymetal",
		name = "Heavy Metal",
		rating = -1,
		num = 134
	},
	['honeygather'] = {
		id = "honeygather",
		name = "Honey Gather",
		rating = 0,
		num = 118
	},
	['hugepower'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk)
			return self:chainModify(2)
		end,
		id = "hugepower",
		name = "Huge Power",
		rating = 5,
		num = 37
	},
	['hustle'] = {
		-- This should be applied directly to the stat as opposed to chaining witht he others
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk)
			return self:modify(atk, 1.5)
		end,
		onModifyMove = function(move)
			if move.category == 'Physical' and type(move.accuracy) == 'number' then
				move.accuracy = move.accuracy * 0.8
			end
		end,
		id = "hustle",
		name = "Hustle",
		rating = 3,
		num = 55
	},
	['hydration'] = {
		onResidualOrder = 5,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			if pokemon.status and self:isWeather({'raindance', 'primordialsea'}) then
				self:debug('hydration')
				pokemon:cureStatus()
			end
		end,
		id = "hydration",
		name = "Hydration",
		rating = 2,
		num = 93
	},
	['hypercutter'] = {
		onBoost = function(boost, target, source, effect)
			if source and target == source then return end
			if boost['atk'] and boost['atk'] < 0 then
				boost['atk'] = 0
				if not effect.secondaries then
					self:add("-fail", target, "unboost", "Attack", "[from] ability = Hyper Cutter", "[of] " .. target)
				end
			end
		end,
		id = "hypercutter",
		name = "Hyper Cutter",
		rating = 1.5,
		num = 52
	},
	['icebody'] = {
		onWeather = function(target, source, effect)
			if effect.id == 'hail' then
				self:heal(target.maxhp / 16)
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'hail' then return false end
		end,
		id = "icebody",
		name = "Ice Body",
		rating = 1.5,
		num = 115
	},
	['illuminate'] = {
		-- does this work??
		onModifyEncounterRate = function(rate)
			return rate * 2
		end,
		id = "illuminate",
		name = "Illuminate",
		rating = 0,
		num = 35
	},
	['illusion'] = {
		onBeforeSwitchIn = function(pokemon)
			pokemon.illusion = nil
			local illusion
			for i = #pokemon.side.pokemon, pokemon.position, -1 do
				local p = pokemon.side.pokemon[i]
				if p ~= null and not p.fainted then
					illusion = p
					break
				end
			end
			if not illusion or pokemon == illusion then return end
			pokemon.illusion = illusion
		end,
		-- illusion clearing is hardcoded in the damage function
		-- function because mold breaker inhibits the damage event
		onEnd = function(pokemon)
			if pokemon.illusion then
				self:debug('illusion cleared')
				pokemon.illusion = nil
--				let details = pokemon.template.species + (pokemon.level === 100 ? '' : ', L' + pokemon.level) + (pokemon.gender === '' ? '' : ', ' + pokemon.gender) + (pokemon.set.shiny ? ', shiny' : '');
--				this.add('replace', pokemon, details);
--				this.add('-end', pokemon, 'Illusion');
				self:add('-endability', pokemon, 'Illusion', pokemon.getDetails)
			end
		end,
		onFaint = function(pokemon)
			pokemon.illusion = nil
		end,
		id = "illusion",
		name = "Illusion",
		rating = 4.5,
		num = 149
	},
	['immunity'] = {
		onUpdate = function(pokemon)
			if pokemon.status == 'psn' or pokemon.status == 'tox' then
				pokemon:cureStatus()
			end
		end,
		onImmunity = function(type)
			if type == 'psn' then return false end
		end,
		id = "immunity",
		name = "Immunity",
		rating = 2,
		num = 17
	},
	['imposter'] = {
		onStart = function(pokemon)
			local target = pokemon.side.foe.active[#pokemon.side.foe.active + 1 - pokemon.position]
			if not Not(target) then
				pokemon:transformInto(target, pokemon, self:getAbility('imposter'))
			end
		end,
		id = "imposter",
		name = "Imposter",
		rating = 4.5,
		num = 150
	},
	['infiltrator'] = {
		onModifyMove = function(move)
			move.infiltrates = true
		end,
		id = "infiltrator",
		name = "Infiltrator",
		rating = 3,
		num = 151
	},
	['innerfocus'] = {
		onFlinch = function() return false end,
		id = "innerfocus",
		name = "Inner Focus",
		rating = 1.5,
		num = 39
	},
	['insomnia'] = {
		onUpdate = function(pokemon)
			if pokemon.status == 'slp' then
				pokemon:cureStatus()
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'slp' then return false end
		end,
		id = "insomnia",
		name = "Insomnia",
		rating = 2,
		num = 15
	},

	
	
	['intimidate'] = {
		onStart = function(pokemon)
			local activated = false
			for _, foe in pairs(pokemon.side.foe.active) do
				if foe ~= null and self:isAdjacent(foe, pokemon) then
					if not activated then
						self:add('-ability', pokemon, 'Intimidate')
						activated = true
					end
					if foe.volatiles['substitute'] then
						self:add('-activate', foe, 'Substitute', 'ability = Intimidate', '[of] ' .. pokemon)
					else
						self:boost({atk = -1}, foe, pokemon)
					end
				end
			end
		end,
		id = "intimidate",
		name = "Intimidate",
		rating = 3.5,
		num = 22
	},
	

	

	
	
	['ironbarbs'] = {
		onAfterDamageOrder = 1,
		onAfterDamage = function(damage, target, source, move)
			if source and source ~= target and move and move.flags['contact'] then
				self:damage(source.maxhp / 8, source, target, nil, true)
			end
		end,
		id = "ironbarbs",
		name = "Iron Barbs",
		rating = 3,
		num = 160
	},
	['ironfist'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if move.flags['punch'] then
				self:debug('Iron Fist boost')
				return self:chainModify(0x1333, 0x1000)
			end
		end,
		id = "ironfist",
		name = "Iron Fist",
		rating = 3,
		num = 89
	},
	['justified'] = {
		onAfterDamage = function(damage, target, source, effect)
			if effect and effect.type == 'Dark' then
				self:boost({atk = 1})
			end
		end,
		id = "justified",
		name = "Justified",
		rating = 2,
		num = 154
	},
	['keeneye'] = {
		onBoost = function(boost, target, source, effect)
			if source and target == source then return end
			if boost['accuracy'] and boost['accuracy'] < 0 then
				boost['accuracy'] = 0
				if not effect.secondaries then
					self:add("-fail", target, "unboost", "accuracy", "[from] ability = Keen Eye", "[of] " .. target)
				end
			end
		end,
		onModifyMove = function(move)
			move.ignoreEvasion = true
		end,
		id = "keeneye",
		name = "Keen Eye",
		rating = 1,
		num = 51
	},
	['klutz'] = {
		-- Item suppression implemented in BattlePokemon:ignoringItem()
		id = "klutz",
		name = "Klutz",
		rating = -1,
		num = 103
	},
	['leafguard'] = {
		onSetStatus = function(pokemon)
			if self:isWeather({'sunnyday', 'desolateland'}) then
				return false
			end
		end,
		onTryHit = function(target, source, move)
			if move and move.id == 'yawn' and self:isWeather({'sunnyday', 'desolateland'}) then
				return false
			end
		end,
		id = "leafguard",
		name = "Leaf Guard",
		rating = 1,
		num = 102
	},
	['levitate'] = {
		onImmunity = function(type)
			if type == 'Ground' then return false end
		end,
		id = "levitate",
		name = "Levitate",
		rating = 3.5,
		num = 26
	},
	['lightmetal'] = {
		onModifyWeight = function(weight)
			return weight / 2
		end,
		id = "lightmetal",
		name = "Light Metal",
		rating = 1,
		num = 135
	},
	['lightningrod'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.type == 'Electric' then
				if not self:boost({spa = 1}) then
					self:add('-immune', target, '[msg]')
				end
				return null
			end
		end,
		onAnyRedirectTargetPriority = 1,
		onAnyRedirectTarget = function(target, source, source2, move)
			if move.type ~= 'Electric' or ({firepledge=true, grasspledge=true, waterpledge=true})[move.id] then return end
			if self:validTarget(self.effectData.target, source, move.target) then
				return self.effectData.target
			end
		end,
		id = "lightningrod",
		name = "Lightning Rod",
		rating = 3.5,
		num = 32
	},
	['limber'] = {
		onUpdate = function(pokemon)
			if pokemon.status == 'par' then
				pokemon:cureStatus()
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'par' then return false end
		end,
		id = "limber",
		name = "Limber",
		rating = 1.5,
		num = 7
	},
	['liquidooze'] = {
		id = "liquidooze",
		onSourceTryHeal = function(damage, target, source, effect)
			self:debug("Heal is occurring = " .. target .. " <- " .. source .. " : = " .. effect.id)
			local canOoze = {drain=true, leechseed=true}
			if canOoze[effect.id] then
				self:damage(damage, nil, nil, nil, true)
				return 0
			end
		end,
		name = "Liquid Ooze",
		rating = 1.5,
		num = 64
	},
	['magicbounce'] = {
		id = "magicbounce",
		name = "Magic Bounce",
		onTryHitPriority = 1,
		onTryHit = function(target, source, move)
			if target == source or move.hasBounced or not move.flags['reflectable'] then return end
			local newMove = self:getMoveCopy(move.id)
			newMove.hasBounced = true
			self:useMove(newMove, target, source)
			return null
		end,
		onAllyTryHitSide = function(target, source, move)
			if target.side == source.side or move.hasBounced or not move.flags['reflectable'] then return end
			local newMove = self:getMoveCopy(move.id)
			newMove.hasBounced = true
			self:useMove(newMove, target, source)
			return null
		end,
		effect = {
			duration = 1
		},
		rating = 4.5,
		num = 156
	},
	['magicguard'] = {
		onDamage = function(damage, target, source, effect)
			if effect.effectType ~= 'Move' then
				return false
			end
		end,
		id = "magicguard",
		name = "Magic Guard",
		rating = 4.5,
		num = 98
	},
	['magician'] = {
		onSourceHit = function(target, source, move)
			if not move or not target then return end
			if target ~= source and move.category ~= 'Status' then
				if source.item and source.item ~= '' then return end
				local yourItem = target:takeItem(source)
				if Not(yourItem) then return end
				if not source:setItem(yourItem) then
					target.item = yourItem.id -- bypass setItem so we don't break choicelock or anything
					return
				end
				self:add('-item', source, yourItem, '[from] ability = Magician', '[of] ' .. target)
			end
		end,
		id = "magician",
		name = "Magician",
		rating = 1.5,
		num = 170
	},
	['magmaarmor'] = {
		onUpdate = function(pokemon)
			if pokemon.status == 'frz' then
				pokemon:cureStatus()
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'frz' then return false end
		end,
		id = "magmaarmor",
		name = "Magma Armor",
		rating = 0.5,
		num = 40
	},
	['magnetpull'] = {
		onFoeModifyPokemon = function(pokemon)
			if pokemon:hasType('Steel') and self:isAdjacent(pokemon, self.effectData.target) then
				pokemon:tryTrap(true, self.effectData.target, 'Magnet Pull')
			end
		end,
		onFoeMaybeTrapPokemon = function(pokemon, source)
			if not source then source = self.effectData.target end
			if pokemon:hasType('Steel') and self:isAdjacent(pokemon, source) then
				pokemon.maybeTrapped = true
			end
		end,
		id = "magnetpull",
		name = "Magnet Pull",
		rating = 4.5,
		num = 42
	},
	['marvelscale'] = {
		onModifyDefPriority = 6,
		onModifyDef = function(def, pokemon)
			if pokemon.status then
				return self:chainModify(1.5)
			end
		end,
		id = "marvelscale",
		name = "Marvel Scale",
		rating = 2.5,
		num = 63
	},
	['megalauncher'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if move.flags['pulse'] then
				return self:chainModify(1.5)
			end
		end,
		id = "megalauncher",
		name = "Mega Launcher",
		rating = 3.5,
		num = 178
	},
	['minus'] = {
		onModifySpAPriority = 5,
		onModifySpA = function(spa, pokemon)
			if #pokemon.side.active == 1 then return end
			for _, ally in pairs(pokemon.side.active) do
				if ally and ally.position ~= pokemon.position and not ally.fainted and ally:hasAbility('minus', 'plus') then
					return self:chainModify(1.5)
				end
			end
		end,
		id = "minus",
		name = "Minus",
		rating = 0,
		num = 58
	},
	['moldbreaker'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Mold Breaker')
		end,
		stopAttackEvents = true,
		id = "moldbreaker",
		name = "Mold Breaker",
		rating = 3.5,
		num = 104
	},
	['moody'] = {
		onResidualOrder = 26,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			local stats = {}
			local boost = {}
			local inc
			for i, b in pairs(pokemon.boosts) do
				if b < 6 then
					table.insert(stats, i)
				end
			end
			if #stats > 0 then
				inc = stats[math.random(#stats)]
				boost[inc] = 2
			end
			stats = {}
			for j, b in pairs(pokemon.boosts) do
				if b > -6 and j ~= inc then
					table.insert(stats, j)
				end
			end
			if #stats > 0 then
				local dec = stats[math.random(#stats)]
				boost[dec] = -1
			end
			self:boost(boost)
		end,
		id = "moody",
		name = "Moody",
		rating = 5,
		num = 141
	},
	['motordrive'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.type == 'Electric' then
				if not self:boost({spe = 1}) then
					self:add('-immune', target, '[msg]')
				end
				return null
			end
		end,
		id = "motordrive",
		name = "Motor Drive",
		rating = 3,
		num = 78
	},
	['moxie'] = {
		onSourceFaint = function(target, source, effect)
			if effect and effect.effectType == 'Move' then
				self:boost({atk = 1}, source)
			end
		end,
		id = "moxie",
		name = "Moxie",
		rating = 3.5,
		num = 153
	},
	['multiscale'] = {
		onSourceModifyDamage = function(damage, source, target, move)
			if target.hp >= target.maxhp then
				self:debug('Multiscale weaken')
				return self:chainModify(0.5)
			end
		end,
		id = "multiscale",
		name = "Multiscale",
		rating = 4,
		num = 136
	},
	['multitype'] = {
		-- Multitype's type-changing is implemented in Statuses
		onTakeItem = function(item)
			if item.onPlate then return false end
		end,
		id = "multitype",
		name = "Multitype",
		rating = 4,
		num = 121
	},
	['mummy'] = {
		id = "mummy",
		name = "Mummy",
		onAfterDamage = function(damage, target, source, move)
			if source and source ~= target and move and move.flags['contact'] then
				local oldAbility = source:setAbility('mummy', source, 'mummy', true)
				if oldAbility then
--					self:add('-endability', source, oldAbility, '[from] Mummy')
--					self:add('-ability', source, 'Mummy', '[from] Mummy')
					self:add('-activate', target, 'ability: Mummy', oldAbility, '[of] ' .. source)
				end
			end
		end,
		rating = 2,
		num = 152
	},
	['naturalcure'] = {
		onSwitchOut = function(pokemon)
			pokemon:setStatus('')
		end,
		onBattleEnd = function(pokemon)
			pokemon:setStatus('')
		end,
		id = "naturalcure",
		name = "Natural Cure",
		rating = 3.5,
		num = 30
	},
	['noguard'] = {
		onAnyAccuracy = function(accuracy, target, source, move)
			if move and (source == self.effectData.target or target == self.effectData.target) then
				return true
			end
			return accuracy
		end,
		id = "noguard",
		name = "No Guard",
		rating = 4,
		num = 99
	},
	['normalize'] = {
		onModifyMovePriority = 1,
		onModifyMove = function(move)
			if move.id ~= 'struggle' then
				move.type = 'Normal'
			end
		end,
		id = "normalize",
		name = "Normalize",
		rating = -1,
		num = 96
	},
	['oblivious'] = {
		onUpdate = function(pokemon)
			if pokemon.volatiles['attract'] then
				pokemon:removeVolatile('attract')
				self:add('-end', pokemon, 'move: Attract', '[from] ability: Oblivious')
			end
			if pokemon.volatiles['taunt'] then
				pokemon:removeVolatile('taunt')
				-- Taunt's volatile already sends the -end message when removed
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'attract' then
				self:add('-immune', pokemon, '[from] Oblivious')
				return false
			end
		end,
		onTryHit = function(pokemon, target, move)
			if move.id == 'captivate' or move.id == 'taunt' then
				self:add('-immune', pokemon, '[msg]', '[from] Oblivious')
				return null
			end
		end,
		id = "oblivious",
		name = "Oblivious",
		rating = 1,
		num = 12
	},
	['overcoat'] = {
		onImmunity = function(type, pokemon)
			if type == 'sandstorm' or type == 'hail' or type == 'powder' then return false end
		end,
		id = "overcoat",
		name = "Overcoat",
		rating = 2.5,
		num = 142
	},
	['overgrow'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk, attacker, defender, move)
			if move.type == 'Grass' and attacker.hp <= attacker.maxhp/3 then
				self:debug('Overgrow boost')
				return self:chainModify(1.5)
			end
		end,
		onModifySpAPriority = 5,
		onModifySpA = function(atk, attacker, defender, move)
			if move.type == 'Grass' and attacker.hp <= attacker.maxhp/3 then
				self:debug('Overgrow boost')
				return self:chainModify(1.5)
			end
		end,
		id = "overgrow",
		name = "Overgrow",
		rating = 2,
		num = 65
	},
	['owntempo'] = {
		onUpdate = function(pokemon)
			if pokemon.volatiles['confusion'] then
				pokemon:removeVolatile('confusion')
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'confusion' then
				self:add('-immune', pokemon, 'confusion')
				return false
			end
		end,
		id = "owntempo",
		name = "Own Tempo",
		rating = 1,
		num = 20
	},
	['parentalbond'] = {
		onPrepareHit = function(source, target, move)
			if move.id == 'iceball' or move.id == 'rollout' then return end
			if move.category ~= 'Status' and not move.selfdestruct and not move.multihit and not move.flags['charge'] and not move.spreadHit then
				move.multihit = 2
				source:addVolatile('parentalbond')
			end
		end,
		effect = {
			duration = 1,
			onBasePowerPriority = 8,
			onBasePower = function(basePower)
				if self.effectData.hit then
					return self:chainModify(0.5)
				else
					self.effectData.hit = true
				end
			end
		},
		id = "parentalbond",
		name = "Parental Bond",
		rating = 5,
		num = 184
	},
	['pickup'] = {
		onResidualOrder = 26,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			if pokemon.item and pokemon.item ~= '' then return end
			local pickupTargets = {}
			for _, side in pairs(self.sides) do
				for _, target in pairs(side.active) do
					if target ~= null and (target.lastItem and target.lastItem ~= '') and target.usedItemThisTurn and self:isAdjacent(pokemon, target) then
						table.insert(pickupTargets, target)
					end
				end
			end
			if #pickupTargets == 0 then return end
			local target = pickupTargets[math.random(#pickupTargets)]
			pokemon:setItem(target.lastItem)
			target.lastItem = ''
			local item = pokemon:getItem()
			self:add('-item', pokemon, item, '[from] Pickup')
			if item.isBerry then pokemon:update() end
		end,
		id = "pickup",
		name = "Pickup",
		rating = 0.5,
		num = 53
	},
	['pickpocket'] = {
		onAfterMoveSecondary = function(target, source, move)
			if source and source ~= target and move and move.flags['contact'] then
				if target.item and target.item ~= '' then return end
				local yourItem = source:takeItem(target)
				if Not(yourItem) then return end
				if not target:setItem(yourItem) then
					source.item = yourItem.id
					return
				end
				self:add('-item', target, yourItem, '[from] ability = Pickpocket', '[of] ' .. source)
			end
		end,
		id = "pickpocket",
		name = "Pickpocket",
		rating = 1,
		num = 124
	},
	['pixilate'] = {
		onModifyMovePriority = -1,
		onModifyMove = function(move, pokemon)
			if move.type == 'Normal' and move.id ~= 'naturalgift' then
				move.type = 'Fairy'
				if move.category ~= 'Status' then
					pokemon:addVolatile('pixilate')
				end
			end
		end,
		effect = {
			duration = 1,
			onBasePowerPriority = 8,
			onBasePower = function(basePower, pokemon, target, move)
				return self:chainModify(0x14CD, 0x1000)
			end
		},
		id = "pixilate",
		name = "Pixilate",
		rating = 4,
		num = 182
	},
	['plus'] = {
		onModifySpAPriority = 5,
		onModifySpA = function(spa, pokemon)
			if #pokemon.side.active == 1 then return end
			for _, ally in pairs(pokemon.side.active) do
				if ally ~= null and ally.position ~= pokemon.position and not ally.fainted and ally:hasAbility('minus', 'plus') then
					return self:chainModify(1.5)
				end
			end
		end,
		id = "plus",
		name = "Plus",
		rating = 0,
		num = 57
	},
	['poisonheal'] = {
		onDamage = function(damage, target, source, effect)
			if effect.id == 'psn' or effect.id == 'tox' then
				self:heal(target.maxhp / 8)
				return false
			end
		end,
		id = "poisonheal",
		name = "Poison Heal",
		rating = 4,
		num = 90
	},
	['poisonpoint'] = {
		onAfterDamage = function(damage, target, source, move)
			if move and move.flags['contact'] then
				if math.random(10) <= 3 then
					self.statusSourceMessage = {'-ability', target, 'poisonpoint'}
					source:trySetStatus('psn', target, move)
					self.statusSourceMessage = nil
				end
			end
		end,
		id = "poisonpoint",
		name = "Poison Point",
		rating = 2,
		num = 38
	},
	['poisontouch'] = {
		onModifyMove = function(move)
			if not move or not move.flags['contact'] then return end
			if not move.secondaries then
				move.secondaries = {}
			end
			table.insert(move.secondaries, {
				chance = 30,
				status = 'psn'
			})
		end,
		id = "poisontouch",
		name = "Poison Touch",
		rating = 2,
		num = 143
	},
	['prankster'] = {
		onModifyPriority = function(priority, pokemon, target, move)
			if move and move.category == 'Status' then
				return priority + 1
			end
		end,
		id = "prankster",
		name = "Prankster",
		rating = 4.5,
		num = 158
	},
	['pressure'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Pressure')
		end,
		onDeductPP = function(target, source)
			if target.side == source.side then return end
			return 1
		end,
		id = "pressure",
		name = "Pressure",
		rating = 1.5,
		num = 46
	},
	['primordialsea'] = {
		onStart = function(source)
			self:setWeather('primordialsea')
		end,
		onAnySetWeather = function(target, source, weather)
			local weathers = {desolateland=true, primordialsea=true, deltastream=true}
			if self:getWeather().id == 'primordialsea' and not weathers[weather.id] then return false end
		end,
		onEnd = function(pokemon)
			if self.weatherData.source ~= pokemon then return end
			for _, side in pairs(self.sides) do
				for _, target in pairs(side.active) do
					if target ~= null and target ~= pokemon and target.hp > 0 and target:hasAbility('primordialsea') then
						self.weatherData.source = target
						return
					end
				end
			end
			self:clearWeather()
		end,
		id = "primordialsea",
		name = "Primordial Sea",
		rating = 5,
		num = 189
	},
	['protean'] = {
		onPrepareHit = function(source, target, move)
			local type = move.type
			if type and type ~= '???' and table.concat(source:getTypes(), '') ~= type then
				if not source:setType(type) then return end
				self:add('-start', source, 'typechange', type, '[from] Protean')
			end
		end,
		id = "protean",
		name = "Protean",
		rating = 4,
		num = 168
	},
	['purepower'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk)
			return self:chainModify(2)
		end,
		id = "purepower",
		name = "Pure Power",
		rating = 5,
		num = 74
	},
	['quickfeet'] = {
		onModifySpe = function(spe, pokemon)
			if pokemon.status and pokemon.status ~= '' then
				return self:chainModify(1.5)
			end
		end,
		id = "quickfeet",
		name = "Quick Feet",
		rating = 2.5,
		num = 95
	},
	['raindish'] = {
		onWeather = function(target, source, effect)
			if effect.id == 'raindance' or effect.id == 'primordialsea' then
				self:heal(target.maxhp / 16)
			end
		end,
		id = "raindish",
		name = "Rain Dish",
		rating = 1.5,
		num = 44
	},
	['rattled'] = {
		onAfterDamage = function(damage, target, source, effect)
			if effect and (effect.type == 'Dark' or effect.type == 'Bug' or effect.type == 'Ghost') then
				self:boost({spe = 1})
			end
		end,
		id = "rattled",
		name = "Rattled",
		rating = 1.5,
		num = 155
	},
	['reckless'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if move.recoil or move.hasCustomRecoil then
				self:debug('Reckless boost')
				return self:chainModify(0x1333, 0x1000)
			end
		end,
		id = "reckless",
		name = "Reckless",
		rating = 3,
		num = 120
	},
	['refrigerate'] = {
		onModifyMovePriority = -1,
		onModifyMove = function(move, pokemon)
			if move.type == 'Normal' and move.id ~= 'naturalgift' then
				move.type = 'Ice'
				if move.category ~= 'Status' then
					pokemon:addVolatile('refrigerate')
				end
			end
		end,
		effect = {
			duration = 1,
			onBasePowerPriority = 8,
			onBasePower = function(basePower, pokemon, target, move)
				return self:chainModify(0x14CD, 0x1000)
			end
		},
		id = "refrigerate",
		name = "Refrigerate",
		rating = 4,
		num = 174
	},
	['regenerator'] = {
		onSwitchOut = function(pokemon)
			pokemon:heal(pokemon.maxhp / 3)
		end,
		id = "regenerator",
		name = "Regenerator",
		rating = 4,
		num = 144
	},
	['rivalry'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if attacker.gender and attacker.gender ~= '' and defender.gender and defender.gender ~= '' then
				if attacker.gender == defender.gender then
					self:debug('Rivalry boost')
					return self:chainModify(1.25)
				else
					self:debug('Rivalry weaken')
					return self:chainModify(0.75)
				end
			end
		end,
		id = "rivalry",
		name = "Rivalry",
		rating = 0.5,
		num = 79
	},
	['rockhead'] = {
		onDamage = function(damage, target, source, effect)
			if effect.id == 'recoil' and self.activeMove.id ~= 'struggle' then return null end
		end,
		id = "rockhead",
		name = "Rock Head",
		rating = 3,
		num = 69
	},
	['roughskin'] = {
		onAfterDamageOrder = 1,
		onAfterDamage = function(damage, target, source, move)
			if source and source ~= target and move and move.flags['contact'] then
				self:damage(source.maxhp / 8, source, target, nil, true)
			end
		end,
		id = "roughskin",
		name = "Rough Skin",
		rating = 3,
		num = 24
	},
	['runaway'] = {
		id = "runaway",
		name = "Run Away",
		rating = 0,
		num = 50
	},
	['sandforce'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if self:isWeather('sandstorm') then
				if move.type == 'Rock' or move.type == 'Ground' or move.type == 'Steel' then
					self:debug('Sand Force boost')
					return self:chainModify(0x14CD, 0x1000)
				end
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'sandstorm' then return false end
		end,
		id = "sandforce",
		name = "Sand Force",
		rating = 2,
		num = 159
	},
	['sandrush'] = {
		onModifySpe = function(spe, pokemon)
			if self:isWeather('sandstorm') then
				return self:chainModify(2)
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'sandstorm' then return false end
		end,
		id = "sandrush",
		name = "Sand Rush",
		rating = 2.5,
		num = 146
	},
	['sandstream'] = {
		onStart = function(source)
			self:setWeather('sandstorm')
		end,
		id = "sandstream",
		name = "Sand Stream",
		rating = 4,
		num = 45
	},
	['sandveil'] = {
		onImmunity = function(type, pokemon)
			if type == 'sandstorm' then return false end
		end,
		onModifyAccuracy = function(accuracy)
			if type(accuracy) ~= 'number' then return end
			if self:isWeather('sandstorm') then
				self:debug('Sand Veil - decreasing accuracy')
				return accuracy * 0.8
			end
		end,
		id = "sandveil",
		name = "Sand Veil",
		rating = 1.5,
		num = 8
	},
	['sapsipper'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.type == 'Grass' then
				if not self:boost({atk = 1}) then
					self:add('-immune', target, '[msg]')
				end
				return null
			end
		end,
		onAllyTryHitSide = function(target, source, move)
			if target == self.effectData.target or target.side ~= source.side then return end
			if move.type == 'Grass' then
				self:boost({atk = 1}, self.effectData.target)
			end
		end,
		id = "sapsipper",
		name = "Sap Sipper",
		rating = 3.5,
		num = 157
	},
	['scrappy'] = {
		onModifyMovePriority = -5,
		onModifyMove = function(move)
			if not move.ignoreImmunity then move.ignoreImmunity = {} end
			if move.ignoreImmunity ~= true then
				move.ignoreImmunity['Fighting'] = true
				move.ignoreImmunity['Normal'] = true
			end
		end,
		id = "scrappy",
		name = "Scrappy",
		rating = 3,
		num = 113
	},
	['serenegrace'] = {
		onModifyMovePriority = -2,
		onModifyMove = function(move)
			if move.secondaries and move.id ~= 'secretpower' then
				self:debug('doubling secondary chance')
				for _, s in pairs(move.secondaries) do
					s.chance = s.chance * 2
				end
			end
		end,
		id = "serenegrace",
		name = "Serene Grace",
		rating = 4,
		num = 32
	},
	['shadowtag'] = {
		onFoeModifyPokemon = function(pokemon)
			if not pokemon:hasAbility('shadowtag') and self:isAdjacent(pokemon, self.effectData.target) then
				pokemon:tryTrap(true, self.effectData.target, 'Shadow Tag')
			end
		end,
		onFoeMaybeTrapPokemon = function(pokemon, source)
			if not source then source = self.effectData.target end
			if not pokemon:hasAbility('shadowtag') and self:isAdjacent(pokemon, source) then
				pokemon.maybeTrapped = true
			end
		end,
		id = "shadowtag",
		name = "Shadow Tag",
		rating = 5,
		num = 23
	},
	['shedskin'] = {
		onResidualOrder = 5,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			if pokemon.hp and (pokemon.status and pokemon.status ~= '') and math.random(3) == 1 then
				self:debug('shed skin')
				self:add('-activate', pokemon, 'ability = Shed Skin')
				pokemon:cureStatus()
			end
		end,
		id = "shedskin",
		name = "Shed Skin",
		rating = 3.5,
		num = 61
	},
	['sheerforce'] = {
		onModifyMove = function(move, pokemon)
			if move.secondaries then
				move.secondaries = nil
				-- Negation of `AfterMoveSecondary` effects implemented in Extension
				pokemon:addVolatile('sheerforce')
			end
		end,
		effect = {
			duration = 1,
			onBasePowerPriority = 8,
			onBasePower = function(basePower, pokemon, target, move)
				return self:chainModify(0x14CD, 0x1000)
			end
		},
		id = "sheerforce",
		name = "Sheer Force",
		rating = 4,
		num = 125
	},
	['shellarmor'] = {
		onCriticalHit = function() return false end,
		id = "shellarmor",
		name = "Shell Armor",
		rating = 1,
		num = 75
	},
	['shielddust'] = {
		onModifySecondaries = function(secondaries)
			self:debug('Shield Dust prevent secondary')
			return filter(secondaries, function(effect)
				return effect.self and true or false
			end)
		end,
		id = "shielddust",
		name = "Shield Dust",
		rating = 2.5,
		num = 19
	},
	['simple'] = {
		onBoost = function(boost)
			for i, b in pairs(boost) do
				boost[i] = b * 2
			end
		end,
		id = "simple",
		name = "Simple",
		rating = 4,
		num = 86
	},
	['skilllink'] = {
		onModifyMove = function(move)
			if move.multihit and type(move.multihit) == 'table' then
				move.multihit = move.multihit[2]
			end
		end,
		id = "skilllink",
		name = "Skill Link",
		rating = 4,
		num = 92
	},
	['slowstart'] = {
		onStart = function(pokemon)
			pokemon:addVolatile('slowstart')
		end,
		onEnd = function(pokemon)
			pokemon.volatiles['slowstart'] = nil
			self:add('-end', pokemon, 'Slow Start', '[silent]')
		end,
		effect = {
			duration = 5,
			onStart = function(target)
				self:add('-start', target, 'Slow Start')
			end,
			onModifyAtkPriority = 5,
			onModifyAtk = function(atk, pokemon)
				return self:chainModify(0.5)
			end,
			onModifySpe = function(spe, pokemon)
				return self:chainModify(0.5)
			end,
			onEnd = function(target)
				self:add('-end', target, 'Slow Start')
			end
		},
		id = "slowstart",
		name = "Slow Start",
		rating = -2,
		num = 112
	},
	['sniper'] = {
		onModifyDamage = function(damage, source, target, move)
			if move.crit then
				self:debug('Sniper boost')
				return self:chainModify(1.5)
			end
		end,
		id = "sniper",
		name = "Sniper",
		rating = 1,
		num = 97
	},
	['snowcloak'] = {
		onImmunity = function(type, pokemon)
			if type == 'hail' then return false end
		end,
		onModifyAccuracy = function(accuracy)
			if type(accuracy) ~= 'number' then return end
			if self:isWeather('hail') then
				self:debug('Snow Cloak - decreasing accuracy')
				return accuracy * 0.8
			end
		end,
		id = "snowcloak",
		name = "Snow Cloak",
		rating = 1.5,
		num = 81
	},
	['snowwarning'] = {
		onStart = function(source)
			self:setWeather('hail')
		end,
		id = "snowwarning",
		name = "Snow Warning",
		rating = 3.5,
		num = 117
	},
	['solarpower'] = {
		onModifySpAPriority = 5,
		onModifySpA = function(spa, pokemon)
			if self:isWeather({'sunnyday', 'desolateland'}) then
				return self:chainModify(1.5)
			end
		end,
		onWeather = function(target, source, effect)
			if effect.id == 'sunnyday' or effect.id == 'desolateland' then
				self:damage(target.maxhp / 8)
			end
		end,
		id = "solarpower",
		name = "Solar Power",
		rating = 1.5,
		num = 94
	},
	['solidrock'] = {
		onSourceModifyDamage = function(damage, source, target, move)
			if move.typeMod > 0 then --if self:getEffectiveness(move, target) > 1 then
				self:debug('Solid Rock neutralize')
				return self:chainModify(0.75)
			end
		end,
		id = "solidrock",
		name = "Solid Rock",
		rating = 3,
		num = 116
	},
	['soundproof'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.flags['sound'] then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		id = "soundproof",
		name = "Soundproof",
		rating = 2,
		num = 43
	},
	['speedboost'] = {
		onResidualOrder = 26,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			if pokemon.activeTurns and pokemon.activeTurns > 0 then
				self:boost({spe = 1})
			end
		end,
		id = "speedboost",
		name = "Speed Boost",
		rating = 4.5,
		num = 3
	},
	['stall'] = {
		onModifyPriority = function(priority)
			return priority - 0.1
		end,
		id = "stall",
		name = "Stall",
		rating = -1,
		num = 100
	},
	['stancechange'] = {
		onBeforeMovePriority = 11,
		onBeforeMove = function(pokemon, target, move)
			if pokemon.template.species ~= 'Aegislash' then return end
			if move.category ~= 'Status' then
				if Not(pokemon.template.forme) and pokemon:formeChange('Aegislash-Blade') then
					self:add('-formechange', pokemon, 'Aegislash-Blade')
				end
			elseif move.id == 'kingsshield' then
				if pokemon.template.forme == 'Blade' and pokemon:formeChange('Aegislash') then
					self:add('-formechange', pokemon, 'Aegislash')
				end
			end
		end,
		id = "stancechange",
		name = "Stance Change",
		rating = 5,
		num = 176
	},
	['static'] = {
		onAfterDamage = function(damage, target, source, effect)
			if effect and effect.flags['contact'] then
				if math.random(10) <= 3 then
					self.statusSourceMessage = {'-ability', target, 'static'}
					source:trySetStatus('par', target, effect)
					self.statusSourceMessage = nil
				end
			end
		end,
		id = "static",
		name = "Static",
		rating = 2,
		num = 9
	},
	['steadfast'] = {
		onFlinch = function(pokemon)
			self:boost({spe = 1})
		end,
		id = "steadfast",
		name = "Steadfast",
		rating = 1,
		num = 80
	},
	['stench'] = {
		onModifyMove = function(move)
			if move.category ~= "Status" then
				self:debug('Adding Stench flinch')
				if not move.secondaries then move.secondaries = {} end
				for _, s in pairs(move.secondaries) do
					if s.volatileStatus == 'flinch' then return end
				end
				table.insert(move.secondaries, {
					chance = 10,
					volatileStatus = 'flinch'
				})
			end
		end,
		id = "stench",
		name = "Stench",
		rating = 0.5,
		num = 1
	},
	['stickyhold'] = {
		onTakeItem = function(item, pokemon, source)
			if self:suppressingAttackEvents() and pokemon ~= self.activePokemon then return end
			if (source and source ~= pokemon) or self.activeMove.id == 'knockoff' then
				self:add('-activate', pokemon, 'ability: Sticky Hold')
				return false
			end
		end,
		id = "stickyhold",
		name = "Sticky Hold",
		rating = 1.5,
		num = 60
	},
	['stormdrain'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.type == 'Water' then
				if not self:boost({spa = 1}) then
					self:add('-immune', target, '[msg]')
				end
				return null
			end
		end,
		onAnyRedirectTargetPriority = 1,
		onAnyRedirectTarget = function(target, source, source2, move)
			if move.type ~= 'Water' or ({firepledge=true, grasspledge=true, waterpledge=true})[move.id] then return end
			if self:validTarget(self.effectData.target, source, move.target) then
				move.accuracy = true
				return self.effectData.target
			end
		end,
		id = "stormdrain",
		name = "Storm Drain",
		rating = 3.5,
		num = 114
	},
	['strongjaw'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if move.flags['bite'] then
				return self:chainModify(1.5)
			end
		end,
		id = "strongjaw",
		name = "Strong Jaw",
		rating = 3,
		num = 173
	},
	['sturdy'] = {
		onTryHit = function(pokemon, target, move)
			if move.ohko then
				self:add('-immune', pokemon, '[msg]')
				return null
			end
		end,
		onDamagePriority = -100,
		onDamage = function(damage, target, source, effect)
			if target.hp == target.maxhp and damage >= target.hp and effect and effect.effectType == 'Move' then
				self:add('-ability', target, 'Sturdy')
				return target.hp - 1
			end
		end,
		id = "sturdy",
		name = "Sturdy",
		rating = 3,
		num = 5
	},
	['suctioncups'] = {
		onDragOutPriority = 1,
		onDragOut = function(pokemon)
			self:add('-activate', pokemon, 'ability = Suction Cups')
			return null
		end,
		id = "suctioncups",
		name = "Suction Cups",
		rating = 2,
		num = 21
	},
	['superluck'] = {
		onModifyMove = function(move)
			move.critRatio = move.critRatio + 1
		end,
		id = "superluck",
		name = "Super Luck",
		rating = 1.5,
		num = 105
	},
	['swarm'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk, attacker, defender, move)
			if move.type == 'Bug' and attacker.hp <= attacker.maxhp/3 then
				self:debug('Swarm boost')
				return self:chainModify(1.5)
			end
		end,
		onModifySpAPriority = 5,
		onModifySpA = function(atk, attacker, defender, move)
			if move.type == 'Bug' and attacker.hp <= attacker.maxhp/3 then
				self:debug('Swarm boost')
				return self:chainModify(1.5)
			end
		end,
		id = "swarm",
		name = "Swarm",
		rating = 2,
		num = 68
	},
	['sweetveil'] = {
		id = "sweetveil",
		name = "Sweet Veil",
		onAllySetStatus = function(status, target, source, effect)
			if status.id == 'slp' then
				self:debug('Sweet Veil interrupts sleep')
				return false
			end
		end,
		onAllyTryHit = function(target, source, move)
			if move and move.id == 'yawn' then
				self:debug('Sweet Veil blocking yawn')
				return false
			end
		end,
		rating = 2,
		num = 175
	},
	['swiftswim'] = {
		onModifySpe = function(spe, pokemon)
			if self:isWeather({'raindance', 'primordialsea'}) then
				return self:chainModify(2)
			end
		end,
		id = "swiftswim",
		name = "Swift Swim",
		rating = 2.5,
		num = 33
	},
	['symbiosis'] = {
		onAllyAfterUseItem = function(item, pokemon)
			local sourceItem = self.effectData.target:getItem()
			local noSharing = sourceItem.onTakeItem and sourceItem.onTakeItem(sourceItem, pokemon) == false
			if (not sourceItem or sourceItem == '') or noSharing then return end
			sourceItem = self.effectData.target:takeItem()
			if Not(sourceItem) then return end
			if pokemon:setItem(sourceItem) then
				self:add('-activate', pokemon, 'ability = Symbiosis', sourceItem, '[of] ' .. self.effectData.target)
			end
		end,
		id = "symbiosis",
		name = "Symbiosis",
		rating = 0,
		num = 180
	},
	['synchronize'] = {
		onAfterSetStatus = function(status, target, source, effect)
			if not source or source == target then return end
			if effect and effect.id == 'toxicspikes' then return end
			if status.id == 'slp' or status.id == 'frz' then return end
			source:trySetStatus(status, target)
		end,
		id = "synchronize",
		name = "Synchronize",
		rating = 2.5,
		num = 28
	},
	['tangledfeet'] = {
		onModifyAccuracy = function(accuracy, target)
			if type(accuracy) ~= 'number' then return end
			if target and target.volatiles['confusion'] then
				self:debug('Tangled Feet - decreasing accuracy')
				return accuracy * 0.5
			end
		end,
		id = "tangledfeet",
		name = "Tangled Feet",
		rating = 1,
		num = 77
	},
	['technician'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if basePower <= 60 then
				self:debug('Technician boost')
				return self:chainModify(1.5)
			end
		end,
		id = "technician",
		name = "Technician",
		rating = 4,
		num = 101
	},
	['telepathy'] = {
		onTryHit = function(target, source, move)
			if target ~= source and target.side == source.side and move.category ~= 'Status' then
				self:add('-activate', target, 'ability = Telepathy')
				return null
			end
		end,
		id = "telepathy",
		name = "Telepathy",
		rating = 0,
		num = 140
	},
	['teravolt'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Teravolt')
		end,
		stopAttackEvents = true,
		id = "teravolt",
		name = "Teravolt",
		rating = 3.5,
		num = 164
	},
	['thickfat'] = {
		onModifyAtkPriority = 6,
		onSourceModifyAtk = function(atk, attacker, defender, move)
			if move.type == 'Ice' or move.type == 'Fire' then
				self:debug('Thick Fat weaken')
				return self:chainModify(0.5)
			end
		end,
		onModifySpAPriority = 5,
		onSourceModifySpA = function(atk, attacker, defender, move)
			if move.type == 'Ice' or move.type == 'Fire' then
				self:debug('Thick Fat weaken')
				return self:chainModify(0.5)
			end
		end,
		id = "thickfat",
		name = "Thick Fat",
		rating = 3.5,
		num = 47
	},
	['tintedlens'] = {
		onModifyDamage = function(damage, source, target, move)
			if move.typeMod < 0 then --if self:getEffectiveness(move, target) < 1 then
				self:debug('Tinted Lens boost')
				return self:chainModify(2)
			end
		end,
		id = "tintedlens",
		name = "Tinted Lens",
		rating = 4,
		num = 110
	},
	['torrent'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk, attacker, defender, move)
			if move.type == 'Water' and attacker.hp <= attacker.maxhp/3 then
				self:debug('Torrent boost')
				return self:chainModify(1.5)
			end
		end,
		onModifySpAPriority = 5,
		onModifySpA = function(atk, attacker, defender, move)
			if move.type == 'Water' and attacker.hp <= attacker.maxhp/3 then
				self:debug('Torrent boost')
				return self:chainModify(1.5)
			end
		end,
		id = "torrent",
		name = "Torrent",
		rating = 2,
		num = 67
	},
	['toxicboost'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if (attacker.status == 'psn' or attacker.status == 'tox') and move.category == 'Physical' then
				return self:chainModify(1.5)
			end
		end,
		id = "toxicboost",
		name = "Toxic Boost",
		rating = 3,
		num = 137
	},
	['toughclaws'] = {
		onBasePowerPriority = 8,
		onBasePower = function(basePower, attacker, defender, move)
			if move.flags['contact'] then
				return self:chainModify(0x14CD, 0x1000)
			end
		end,
		id = "toughclaws",
		name = "Tough Claws",
		rating = 3.5,
		num = 181
	},
	['trace'] = {
		onUpdate = function(pokemon)
			local possibleTargets = {}
			for _, foe in pairs(pokemon.side.foe.active) do
				if foe ~= null and not foe.fainted then
					table.insert(possibleTargets, foe)
				end
			end
			while #possibleTargets > 0 do
				local rand = 1
				if #possibleTargets > 1 then
					rand = math.random(#possibleTargets)
				end
				local target = possibleTargets[rand]
				local ability = self:getAbility(target.ability)
				local bannedAbilities = {flowergift=true, forecast=true, illusion=true, imposter=true, multitype=true, stancechange=true, trace=true, zenmode=true}
				if bannedAbilities[target.ability] then
					table.remove(possibleTargets, rand)
				else
					self:add('-ability', pokemon, ability, '[from] ability = Trace', '[of] ' .. target)
					pokemon:setAbility(ability)
					return
				end
			end
		end,
		id = "trace",
		name = "Trace",
		rating = 3,
		num = 36
	},
	['truant'] = {
		onBeforeMovePriority = 9,
		onBeforeMove = function(pokemon, target, move)
			if pokemon:removeVolatile('truant') then
				self:add('cant', pokemon, 'ability = Truant', move)
				return false
			end
			pokemon:addVolatile('truant')
		end,
		effect = {
			duration = 2
		},
		id = "truant",
		name = "Truant",
		rating = -2,
		num = 54
	},
	['turboblaze'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Turboblaze')
		end,
		stopAttackEvents = true,
		id = "turboblaze",
		name = "Turboblaze",
		rating = 3.5,
		num = 163
	},
	['unaware'] = {
		id = "unaware",
		name = "Unaware",
		onAnyModifyBoost = function(boosts, target)
			local source = self.effectData.target
			if source == target then return end
			if source == self.activePokemon and target == self.activeTarget then
				boosts['def'] = 0
				boosts['spd'] = 0
				boosts['evasion'] = 0
			end
			if target == self.activePokemon and source == self.activeTarget then
				boosts['atk'] = 0
				boosts['spa'] = 0
				boosts['accuracy'] = 0
			end
		end,
		rating = 3,
		num = 109
	},
	['unburden'] = {
		onAfterUseItem = function(item, pokemon)
			if pokemon ~= self.effectData.target then return end
			pokemon:addVolatile('unburden')
		end,
		onTakeItem = function(item, pokemon)
			pokemon:addVolatile('unburden')
		end,
		onEnd = function(pokemon)
			pokemon:removeVolatile('unburden')
		end,
		effect = {
			onModifySpe = function(spe, pokemon)
				if not pokemon.item or pokemon.item == '' then
					return self:chainModify(2)
				end
			end
		},
		id = "unburden",
		name = "Unburden",
		rating = 3.5,
		num = 84
	},
	['unnerve'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Unnerve', pokemon.side.foe)
		end,
		onFoeEatItem = function() return false end,
		id = "unnerve",
		name = "Unnerve",
		rating = 1.5,
		num = 127
	},
	['victorystar'] = {
		onAllyModifyMove = function(move)
			if type(move.accuracy) == 'number' then
				move.accuracy = move.accuracy * 1.1
			end
		end,
		id = "victorystar",
		name = "Victory Star",
		rating = 2.5,
		num = 162
	},
	['vitalspirit'] = {
		onUpdate = function(pokemon)
			if pokemon.status == 'slp' then
				pokemon:cureStatus()
			end
		end,
		onImmunity = function(type)
			if type == 'slp' then return false end
		end,
		id = "vitalspirit",
		name = "Vital Spirit",
		rating = 2,
		num = 72
	},
	['voltabsorb'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.type == 'Electric' then
				if Not(self:heal(target.maxhp / 4)) then
					self:add('-immune', target, '[msg]')
				end
				return null
			end
		end,
		id = "voltabsorb",
		name = "Volt Absorb",
		rating = 3.5,
		num = 10
	},
	['waterabsorb'] = {
		onTryHit = function(target, source, move)
			if target ~= source and move.type == 'Water' then
				if Not(self:heal(target.maxhp / 4)) then
					self:add('-immune', target, '[msg]')
				end
				return null
			end
		end,
		id = "waterabsorb",
		name = "Water Absorb",
		rating = 3.5,
		num = 11
	},
	['waterveil'] = {
		onUpdate = function(pokemon)
			if pokemon.status == 'brn' then
				pokemon:cureStatus()
			end
		end,
		onImmunity = function(type, pokemon)
			if type == 'brn' then return false end
		end,
		id = "waterveil",
		name = "Water Veil",
		rating = 2,
		num = 41
	},
	['weakarmor'] = {
		onAfterDamage = function(damage, target, source, move)
			if move.category == 'Physical' then
				self:boost({def = -1, spe = 1})
			end
		end,
		id = "weakarmor",
		name = "Weak Armor",
		rating = 0.5,
		num = 133
	},
	['whitesmoke'] = {
		onBoost = function(boost, target, source, effect)
			if source and target == source then return end
			local showMsg = false
			for i, b in pairs(boost) do
				if b < 0 then
					boost[i] = nil
					showMsg = true
				end
			end
			if showMsg and not effect.secondaries then
				self:add("-fail", target, "unboost", "[from] ability = White Smoke", "[of] " .. target)
			end
		end,
		id = "whitesmoke",
		name = "White Smoke",
		rating = 2,
		num = 73
	},
	['wonderguard'] = {
		onTryHit = function(target, source, move)
			if target == source or move.category == 'Status' or move.type == '???' or move.id == 'struggle' or move.isFutureMove then return end
			self:debug('Wonder Guard immunity = ' .. move.id)
			if target:runEffectiveness(move) <= 1 then
				self:add('-activate', target, 'ability = Wonder Guard')
				return null
			end
		end,
		id = "wonderguard",
		name = "Wonder Guard",
		rating = 5,
		num = 25
	},
	['wonderskin'] = {
		onModifyAccuracyPriority = 10,
		onModifyAccuracy = function(accuracy, target, source, move)
			if move.category == 'Status' and type(move.accuracy) == 'number' then
				self:debug('Wonder Skin - setting accuracy to 50')
				return 50
			end
		end,
		id = "wonderskin",
		name = "Wonder Skin",
		rating = 2,
		num = 147
	},
	['zenmode'] = {
		onResidualOrder = 27,
		onResidual = function(pokemon)
			if pokemon.baseTemplate.species ~= 'Darmanitan' then return end
			if pokemon.hp <= pokemon.maxhp/2 and pokemon.template.speciesid == 'darmanitan' then
				pokemon:addVolatile('zenmode')
			elseif pokemon.hp > pokemon.maxhp/2 and pokemon.template.speciesid == 'darmanitanzen' then
				pokemon:removeVolatile('zenmode')
			end
		end,
		onEnd = function(pokemon)
			if not pokemon.volatiles['zenmode'] or pokemon.hp <= 0 then return end
			pokemon.transformed = false
			pokemon.volatiles['zenmode'] = nil
			if pokemon:formeChange('Darmanitan') then
				self:add('-formechange', pokemon, 'Darmanitan', '[silent]')
			end
		end,
		effect = {
			onStart = function(pokemon)
				if pokemon:formeChange('Darmanitan-Zen') then
					self:add('-formechange', pokemon, 'Darmanitan-Zen', '[from] ability: Zen Mode')
				else
					return false
				end
			end,
			onEnd = function(pokemon)
				if pokemon:formeChange('Darmanitan') then
					self:add('-formechange', pokemon, 'Darmanitan', '[from] ability: Zen Mode')
				else
					return false
				end
			end,
		},
		id = "zenmode",
		name = "Zen Mode",
		rating = -1,
		num = 161
	},
	
	['galarianzenmode'] = {
--stub
		id = "galarianzenmode",
		name = "Galarian Zen Mode",
		rating = -1,
		num = 224
	},
	
	['stakeout'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk, attacker, defender, move)
			if defender.activeTurns == 1 then
				self:debug ("Stakeout Boost")
				return self:chainModify(2)                
			end
		end,    
		onModifySpAPriority = 5,
		onModifySpA = function(atk, attacker, defender, move)
			if defender.activeTurns == 1 then
				self:debug ("Stakeout Boost")
				return self:chainModify(2)
			end
		end,    
		id = "stakeout",
		name = "Stakeout",
		rating = 4.5,
		num = 162
	},   	
	
	['dancer'] = { --TODO: MAKE DANCER ACTUALLY WORK
		id = "dancer",
		name = "Dancer",
		rating = 2,
		num = 163
	},
	
	['stamina'] = {
		onAfterDamage = function(damage, target, source, move)
			if source and source ~= target then
				self:debug('Stamina boost')
				self:boost({def = 1}, target)
			end
		end,
		id = "stamina",
		name = "Stamina",
		rating = 3,
		num = 164
	},
	
	['merciless'] = {
		onModifyCritRatio = function(critRatio, source, target)
			if target and (target.status == 'psn' or target.status == 'tox') then
				return 5
			end
		end,
		id = "merciless",
		name = "Merciless",
		rating = 2,
		num = 165
	},

	['waterbubble'] = {
		onSourceModifyAtkPriority = 5,
		onSourceModifyAtk = function(atk, attacker, defender, move)
			if move.type == 'Fire' then
				return self:chainModify(0.5)
			end
		end,
		onModifyAtk = function(atk, attacker, defender, move)
			if move.type == 'Water' then
				return self:chainModify(2)
			end
		end,
		onModifySpA = function(atk, attacker, defender, move)
			if move.type == 'Water' then
				return self:chainModify(2)
			end
		end,
		onUpdate = function(pokemon)
			if pokemon.status == 'brn' then
				pokemon:cureStatus()
			end
		end,
		onSetStatus = function(status, target, source, effect)
			if status.id == 'brn' then
				if effect and effect.status then
					self:add('-immune', target, '[from] ability: Water Bubble')
				end
				return false
			end
		end,
		id = "waterbubble",
		name = "Water Bubble",
		rating = 4,
		num = 166
	},
	
	['corrosion'] = {
		onModifyMovePriority = -5,
		onModifyMove = function(move)
			if not move.ignoreImmunity then move.ignoreImmunity = {} end
			if move.ignoreImmunity ~= true then
				move.ignoreImmunity['Steel'] = true
				move.ignoreImmunity['Poison'] = true
			end
		end,
		id = "corrosion",
		name = "Corrosion",
		rating = 2,
		num = 167
	},	
	
	['fluffy'] = {
		onSourceModifyDamage= function(damage,source,target,move)
			local mod = 1
			if move.type == "Fire" then mod = mod * 2
				if move.flags["contact"]then mod = mod / 2        
					return self:chainModify (mod)    
				end    
			end                
		end,
		id = "fluffy",
		name = "Fluffy",
		rating = 3.5,
		num = 168
	},  
	
	['queenlymajesty'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "queenlymajesty",
		name = "Queenly Majesty",
		rating = 2,
		num = 169
	},
	
	['triage'] = {
		onModifyPriority = function(priority, pokemon, target, move)
			if move.flags and move.flags ['heal']
			then return priority + 3
			end
		end,
		id = "triage",
		name = "Triage",
		rating = 3.5,
		num = 170
	},	
	
	['receiver'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "receiver",
		name = "Receiver",
		rating = 2,
		num = 171
	},
	
	['wimpout'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "wimpout",
		name = "Wimp Out",
		rating = 2,
		num = 172
	},
	
	['emergencyexit'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "emergencyexit",
		name = "Emergency Exit",
		rating = 2,
		num = 173
	},
	
	['watercompaction'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "watercompaction",
		name = "Water Compaction",
		rating = 2,
		num = 174
	},
	
	['innardsout'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "innardsout",
		name = "Innards Out",
		rating = 2,
		num = 175
	},
	
	['rkssystem'] = {
		onStart = function(pokemon)
			if pokemon.baseTemplate.baseSpecies ~= 'Silvally' then return end
			local item = pokemon:getItem()
			local memories = {
				fightingmemory = 'Fighting',
				flyingmemory = 'Flying',
				poisonmemory = 'Poison',
				groundmemory = 'Ground',
				rockmemory = 'Rock',
				bugmemory = 'Bug',
				ghostmemory = 'Ghost',
				steelmemory = 'Steel',
				firememory = 'Fire',
				watermemory = 'Water',
				grassmemory = 'Grass',
				electricmemory = 'Electric',
				psychicmemory = 'Psychic',
				icememory = 'Ice',
				dragonmemory = 'Dragon',
				darkmemory = 'Dark',
				fairymemory = 'Fairy'
			}
			if memories[item.id] then
				pokemon:setType(memories[item.id])
				self:add('-start', pokemon, 'typechange', memories[item.id], '[from] ability: RKS System')
			end
		end,
		onTakeItem = function(item, pokemon)
			if pokemon.baseTemplate.baseSpecies ~= 'Silvally' then return end
			pokemon:setType(pokemon.baseTemplate.types)
			self:add('-start', pokemon, 'typechange', pokemon.baseTemplate.types.join('/'), '[from] ability: RKS System')
		end,
		id = "rkssystem",
		name = "RKS System",
		rating = 4,
		num = 176
	},
	
	['shieldsdown'] = {
		onBeforeSwitchIn = function(pokemon)
			if (pokemon.baseTemplate.species ~= 'Minior' or pokemon.transformed) then return end
			if (pokemon.hp > pokemon.maxhp / 2) then
				if pokemon.template.speciesid ~= 'miniormeteor' then
					pokemon:formeChange('Minior-Meteor')
					self:add('-formechange', pokemon, 'Minior-Meteor', '[silent]')
					local template = self:getTemplate('Minior-Meteor')
					pokemon.baseStatOverride = template.baseStats
					pokemon.iconOverride = 951
				end
			else
				if (pokemon.template.speciesid == 'miniormeteor') then
					pokemon:formeChange(pokemon.baseTemplate.species)
					self:add('-formechange', pokemon, pokemon.baseTemplate.species, '[silent]')
				end
			end
		end,
		onResidualOrder = 27,
		onResidual = function(pokemon)
			if (pokemon.baseTemplate.species ~= 'Minior' or pokemon.transformed) then return end
			if (pokemon.hp > pokemon.maxhp / 2) then
				if pokemon.template.speciesid ~= 'miniormeteor' then
					pokemon:formeChange('Minior-Meteor')
					self:add('-formechange', pokemon, 'Minior-Meteor', '[silent]')
					local template = self:getTemplate('Minior-Meteor')
					pokemon.baseStatOverride = template.baseStats
				end
			else
				if pokemon.template.speciesid == 'miniormeteor' then
					pokemon:formeChange(pokemon.baseTemplate.species)
					self:add('-formechange', pokemon, pokemon.baseTemplate.species, '[silent]')
					self:add('-ability', pokemon, 'Shields Down')
					local template = self:getTemplate('Minior-Red')
					pokemon.baseStatOverride = template.baseStats
				end
			end
		end,
		onSetStatus = function(status, target, source, effect)
			if target.template.speciesid ~= 'miniormeteor' or target.transformed then return end
			if effect.status then
				self:add('-immune', target, '[from] ability: Shields Down')
			end
			return false
		end,
		onTryAddVolatile = function(status, target)
			if target.template.speciesid ~= 'miniormeteor' or target.transformed then return end 
			if status.id ~= 'yawn' then return end
			self:add('-immune', target, '[from] ability: Shields Down')
			return
		end,
		name = 'Shields Down',
		id = 'shieldsdown', 
		rating = 3,
		num = 177,
		
		},
	['comatose'] = {
		onResidualOrder = 5,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			self:debug('Simple Comatose')
			pokemon:cureStatus()
		end,
		id ="comatose",
		name = "Comatose",
		rating = 3,
		num = 178,
	},
	
	
	
	
	
	['disguise'] = {
		onDamagePriority = 1,
		onDamage = function(damage, target, source, effect)
			if effect and effect.effectType == 'Move' and 
			   target.template.speciesid == 'mimikyu' and 
			   not target.transformed then
				self:add('-ability', target, 'Disguise')
				self:add('-formechange', target, 'Mimikyu-Busted')
				target:formeChange('Mimikyu-Busted')
				target.transformed = true
				return 0
			end
		end,
		onCriticalHit = false, -- Disable critical hits while disguise is active
		onUpdate = function(pokemon)
			if pokemon.template.speciesid == 'mimikyu' and 
			   not pokemon.transformed then
				pokemon:addVolatile('disguise')
			end
		end,
		effect = {
			onStart = function(pokemon)
				self:add('-start', pokemon, 'Disguise')
			end,
			onEnd = function(pokemon)
				self:add('-end', pokemon, 'Disguise')
				pokemon.transformed = true
			end
		},
		id = "disguise",
		name = "Disguise",
		rating = 3.5,
		num = 179
	},
	
	
	
	['dazzling'] = {
		onFoeTryMove = function(target, source, move)
			local targetAllExceptions = {'perishsong', 'flowershield', 'rototiller'}
			if (move.target.side or (move.target == 'all' and not targetAllExceptions[move.id])) then
				return
			end
			local dazzlingHolder = self.effectData.target
			if ((source.side == dazzlingHolder.side or move.target == 'all') and move.priority > 0.1) then
				target.lastMove('[still]')
				self:add('cant', dazzlingHolder, 'ability: Dazzling', move, '[of] '..target)
				return false
			end
		end,
		name = "Dazzling",
		rating = 2.5,
		num = 180,
		id = 'dazzling'
	},
	

	
	
	['berserk'] = {
		onDamage = function(damage, target, source, effect)
			if effect.effectType == 'Move' and not effect.multihit and  source:hasAbility('sheerforce') then --Check if thats right
				self.effectData.checkedBerserk = false
			else
				self.effectData.checkedBerserk = true
			end
		end,
		onTryEatItem = function(item, pokemon)
			local healingItems = {'aguavberry', 'enigmaberry', 'figyberry', 'iapapaberry', 'magoberry', 'sitrusberry', 'wikiberry', 'oranberry', 'berryjuice'}
			if healingItems[item.id] then
				return self.effectData.checkedBerserk
			end
			return true
		end,
		onAfterSecondary = function(target, source, move)
			self.effectData.checkedBerserk = true
			if not (source or source == target or target.hp or move.totalDamage) then return end
			local lastAttackedBy = target:getLastAttackedBy() --Check if it exists
			if not lastAttackedBy then return end
			local damage = move.multihit or move.totalDamage or lastAttackedBy.damage
			if (target.hp <= target.maxhp/2 and target.hp + damage > target.maxhp/2) then
				self:boost({spa=1})
			end
		end,
		id = 'berserk',
		name = 'Berserk',
		rating = 2,
		num = 181,
	},
	
	
	
	['steelworker'] = {
		onModifyAtkPriority = 5,
		onModifyAtk = function(atk, attacker, defender, move)
			if (move.type == 'Steel') then
				return self:chainModify(1.5)
			end
		end,
		onModifySpAPriority = 5,
		onModifySpA = function(atk, attacker, defender, move)
			if (move.type == 'Steel') then
				return self:chainModify(1.5)
			end
		end,
		name = "Steelworker",
		rating = 3.5,
		num = 182,
		id = 'steelworker'
	},
	
	['electricsurge'] = {
		id = "electricsurge",
		name = "Electric Surge",
		terrain = 'electricsurge',
		onStart = function(source)
			if not self:isTerrain('electricsurge') then
				self:add('-ability', source, 'Electric Surge', '')
				self:setTerrain('electricsurge')
			end
		end,
		effect = {
			duration = 5,
			durationCallback = function(source, effect)
				if source and source ~= null and source:hasItem('terrainextender') then
					return 8
				end
				return 5
			end,
			onSetStatus = function(status, target, source, effect)
				if status.id == 'slp' and target:isGrounded() and not target:isSemiInvulnerable() then
					self:debug('Interrupting sleep from Electric Terrain')
					return false
				end
			end,
			onTryHit = function(target, source, move)
				if not target:isGrounded() or target:isSemiInvulnerable() then return end
				if move and move.id == 'yawn' then
					return false
				end
			end,
			onBasePower = function(basePower, attacker, defender, move)
				if move.type == 'Electric' and attacker:isGrounded() and not attacker:isSemiInvulnerable() then
					self:debug('electric terrain boost')
					return self:chainModify(1.5)
				end
			end,
			onStart = function()
				self:add('message', "An electric current runs across the battlefield!")
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 2,
			onEnd = function()
				self:add('message', "The electricity disappeared from the battlefield.")
			end
		},
		rating = 4,
		num = 183,
	},
	
	['psychicsurge'] = {
		id = "psychicsurge",
		name = "Psychic Surge",
		terrain = 'psychicsurge',
		onStart = function(source)
			if not self:isTerrain('psychicsurge') then
				self:add('-ability', source, 'Psychic Surge', '')
				self:setTerrain('psychicsurge')
			end
		end,
		effect = {
			duration = 5,
			durationCallback = function(source, effect)
				if source and source ~= null and source:hasItem('terrainextender') then
					return 8
				end
				return 5
			end,
			onTryHitPriority = 4,
			onTryHit = function(target, source, effect)
				if not target:isGrounded() or target:isSemiInvulnerable() then return end
				if effect and (effect.priority <= 0.1 or effect.target == 'self') then
					return
				end
				self:add('message', "The move failed to work on Psychic Terrain!")
				return null
			end,
			onBasePower = function(basePower, attacker, defender, move)
				if move.type == 'Psychic' and attacker:isGrounded() and not attacker:isSemiInvulnerable() then
					self:debug('psychic terrain boost')
					return self:chainModify(1.5)
				end
			end,
			onStart = function(battle, source, effect)
				if effect and effect.effectType == 'Ability' then
					self:add('-fieldstart', 'move = Psychic Terrain', '[from] ability = ' .. effect, '[of] ' .. source)
				else
					self:add('message', "The battlefield got weird.")
				end
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 2,
			onEnd = function()
				self:add('message', "The battlefield went back to normal.")
				self:add('-fieldend', 'move = Psychic Terrain')
			end,
		},
		rating = 4,
		num = 184,
	},
	['grassysurge'] = {
		id = "grassysurge",
		name = "Grassy Surge",
		terrain = 'grassysurge',
		onStart = function(source)
			if not self:isTerrain('grassysurge') then
				self:add('-ability', source, 'Grassy Surge', '')
				self:setTerrain('grassysurge')
			end
		end,
		effect = {
			duration = 5,
			durationCallback = function(source, effect)
				if source and source ~= null and source:hasItem('terrainextender') then
					return 8
				end
				return 5
			end,
			onBasePower = function(basePower, attacker, defender, move)
				local weakenedMoves = {earthquake=true, bulldoze=true, magnitude=true}
				if weakenedMoves[move.id] then
					self:debug('move weakened by grassy terrain')
					return self:chainModify(0.5)
				end
				if move.type == 'Grass' and attacker:isGrounded() then
					self:debug('grassy terrain boost')
					return self:chainModify(1.5)
				end
			end,
			onStart = function(target, source)
				self:add('message', "Grass grew to cover the battlefield!")
			end,
			onResidualOrder = 5,
			onResidualSubOrder = 2,
			onResidual = function(battle)
				self:debug('onResidual battle')
				for _, side in pairs(battle.sides) do
					for _, pokemon in pairs(side.active) do
						if pokemon ~= null and pokemon:isGrounded() and not pokemon:isSemiInvulnerable() then
							self:debug('Pok�mon is grounded, healing through Grassy Terrain.')
							self:heal(pokemon.maxhp / 16, pokemon, pokemon)
						end
					end
				end
			end,
			onEnd = function(target, source)
				self:add('message', "Grass has stopped covering the battlefield!")
			end,
		},
		rating = 4,
		num = 185,
	},
	['mistysurge'] = {
		id = "mistysurge",
		name = "Misty Surge",
		terrain = 'mistysurge',
		onStart = function(source)
			if not self:isTerrain('mistysurge') then
				self:add('-ability', source, 'Misty Surge', '')
				self:setTerrain('mistysurge')
			end
		end,
		effect = {
			duration = 5,
			durationCallback = function(source, effect)
				if source and source ~= null and source:hasItem('terrainextender') then
					return 8
				end
				return 5
			end,
			onSetStatus = function(status, target, source, effect)
				if not target:isGrounded() or target:isSemiInvulnerable() then return end
				self:debug('misty terrain preventing status')
				self:add('message', target.name .. " surrounded itself with a protective mist!")
				return false
			end,
			onBasePower = function(basePower, attacker, defender, move)
				if move.type == 'Dragon' and defender:isGrounded() and not defender:isSemiInvulnerable() then
					self:debug('misty terrain weaken')
					return self:chainModify(0.5)
				end
			end,
			onStart = function(side)
				self:add('message', "Mist swirled about the battlefield!")
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 2,
			onEnd = function(side)
				self:add('message', "Mist has stopped swirling!")
				self:add('-fieldend', 'Misty Terrain')
			end
		},
		rating = 4,
		num = 186,
	},
	
	['fullmetalbody'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "fullmetalbody",
		name = "Full Metal Body",
		rating = 2,
		num = 187
	},
	
	['shadowshield'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "shadowshield",
		name = "Shadow Shield",
		rating = 2,
		num = 188
	},
	
	['beastboost'] = {
		id = "beastboost",
		name = "Beast Boost",
		onSourceFaint = function(target, source, effect)
			if effect and effect.effectType == 'Move' then 
				local stat = 'atk'
				local bestStat = 0
				for i, s in pairs(source.stats) do
					if (source.stats[i] > bestStat) then
						stat = i
						bestStat = source.stats[i]
					end
				end
				self:boost({[stat]=1}, source)
			end
		end,
		rating = 5,
		num = 189,
	},
	
	['prismarmor'] = {
		onSourceModifyDamage = function(damage, source, target, move)
			if move.typeMod > 0 then  -- If move is super effective
				self:debug('Prism Armor neutralize')
				return self:chainModify(0.75)
			end
		end,
		id = "prismarmor",
		name = "Prism Armor",
		rating = 3,
		num = 190
	},
	
	['soulheart'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "soulheart",
		name = "Soul-Heart",
		rating = 2,
		num = 191
	},
	
	
	['libero'] = {
		onAfterMoveSecondary = function(target, source, move)
			local type = move.type
			if target.isActive and move.effectType == 'Move' and move.category ~= 'Status' and type ~= '???' and not target:hasType(type) then
				if not target:setType(type) then return false end
				self:add('-start', target, 'typechange', type, '[from] Libero')
				target:update()
			end
		end,
		id = "libero",
		name = "Libero",
		rating = 1,
		num = 192
	},
	
	
	schooling = {
		onStart = function(pokemon) 
			if pokemon.template.species == 'Wishiwashi' and pokemon.level >= 20 and pokemon.hp > pokemon.maxhp / 4 and not pokemon.schooling and pokemon:formeChange('Wishiwashi-School') then 
				pokemon.schooling = true
				self:add('-formechange', pokemon, 'Wishiwashi-School')
			end
		end,
		onResidualOrder = 27,
		onResidual = function(pokemon) 
			if pokemon.template.species == 'Wishiwashi' and pokemon.level >= 20 then 
				if pokemon.hp > pokemon.maxhp / 4 and not pokemon.schooling then
					if pokemon:formeChange('Wishiwashi-School') then
						pokemon.schooling = true
						self:add('-formechange', pokemon, 'Wishiwashi-School')
					end
				elseif pokemon.hp <= pokemon.maxhp / 4 and pokemon.schooling then
					if pokemon:formeChange('Wishiwashi') then
						pokemon.schooling = false
						self:add('-formechange', pokemon, 'Wishiwashi')
					end
				end
			end
		end,

		name = "Schooling",
		rating = 3,
		num = 193,
		id = 'schooling'
	},
	
	['mirrorarmor'] = {
		id = "mirrorarmor",
		name = "Mirror Armor",
		onTryHitPriority = 1,
		onTryHit = function(target, source, move)
			if target == source or move.hasBounced or not move.flags['reflectable'] then return end
			local newMove = self:getMoveCopy(move.id)
			newMove.hasBounced = true
			self:useMove(newMove, target, source)
			return null
		end,
		onAllyTryHitSide = function(target, source, move)
			if target.side == source.side or move.hasBounced or not move.flags['reflectable'] then return end
			local newMove = self:getMoveCopy(move.id)
			newMove.hasBounced = true
			self:useMove(newMove, target, source)
			return null
		end,
		effect = {
			duration = 1
		},
		rating = 4.5,
		num = 194
	},
	
	['cottondown'] = {
		onAfterDamageOrder = 1,
		onAfterDamage = function(damage, target, source, move)
			if source and source ~= target and move and move.flags['contact'] then
				self:boost({atk = -1}, source, target)
				--self:damage(source.maxhp / 8, source, target, nil, true)
			end
		end,
		id = "cottondown",
		name = "Cotton Down",
		rating = 3,
		num = 195
	},
	
	
	['ballfetch'] = { --TODO: MAKE STAMINA ACTUALLY WORK
		id = "ballfetch",
		name = "Ball Fetch",
		rating = 2,
		num = 196
	},
	
	['steamengine'] = {
		onDamagingHit = function(damage, target, source, move)
			if move.type == 'Water' or move.type == 'Fire' then
				self:boost({spe = 6}, target)
				self:add('-ability', target, 'Steam Engine')
				self:add('-boost', target, 'spe', 6, '[from] ability: Steam Engine')
			end
		end,
		id = "steamengine",
		name = "Steam Engine",
		rating = 2,
		num = 197
	},
	
	['ripen'] = {
		id = "ripen",
		name = "Ripen",
		onResidualOrder = 26,
		onResidualSubOrder = 1,
		onResidual = function(pokemon)
			if self:isWeather({'sunnyday', 'desolateland'}) or math.random(2) == 1 then
				if pokemon.hp and Not(pokemon.item) and self:getItem(pokemon.lastItem).isBerry then
					pokemon:setItem(pokemon.lastItem)
					self:add('-item', pokemon, pokemon:getItem(), '[from] ability = Ripen')
				end
			end
		end,
		rating = 2.5,
		num = 198
	},
	
	['sandspit'] = {
		onAfterDamageOrder = 1,
		onAfterDamage = function(damage, target, source, move)
			if source and source ~= target and move and move.flags['contact'] then
			self:setWeather('sandstorm')
			end
		end,
		id = "sandspit",
		name = "Sand Spit",
		rating = 4,
		num = 199
	},
	
	['gulpmissile'] = { --TODO
		id = "gulpmissile",
		name = "Gulp Missile",
		rating = 2,
		num = 200
	},
	
	['propellertail'] = { --TODO
		id = "propellertail",
		name = "Propeller Tail",
		rating = 2,
		num = 201
	},
	
	['punkrock'] = { --TODO
		id = "punkrock",
		name = "Punk Rock",
		rating = 2,
		num = 202
	},

	
	['steelyspirit'] = {
		onStart = function(pokemon,source)
			local targets = {}
			local activated = false
			for _, side in pairs(self.sides) do
				for _, pokemon in pairs(side.active) do
					if pokemon ~= null and not pokemon.fainted and pokemon:hasType('Steel') then

						table.insert(targets, pokemon)
					end
				end
			end
			if #targets == 0 then return false end -- No targets; move fails
			for _, target in pairs(targets) do
				self:boost({atk = 1}, target, source, self:getMove('Steely Spirit'))
			end
		end,
		id = "steelyspirit",
		name = "Steely Spirit",
		rating = 3.5,
		num = 203
	},
	
	['screencleaner'] = {
		onStart = function(pokemon)

			if not Not(pokemon:runImmunity('Fighting')) then
				pokemon.side:removeSideCondition('reflect')
				pokemon.side:removeSideCondition('lightscreen')
				pokemon.side:removeSideCondition('auroraveil')
			end
		end,
		id = "screencleaner",
		name = "Screen Cleaner",
		rating = 3.5,
		num = 204
	},
	
	['wanderingspirit'] = {
		onTryHit = function(target, source)
			local bannedAbilities = {illusion=true, multitype=true, stancechange=true, wonderguard=true}
			if bannedAbilities[target.ability] or bannedAbilities[source.ability] then
				return false
			end
		end,
		onHit = function(target, source, move)
			local targetAbility = self:getAbility(target.ability)
			local sourceAbility = self:getAbility(source.ability)

			self:add('-activate', source, 'ability: Wandering Spirit', targetAbility, sourceAbility, '[of] ' .. target)
			source.battle:singleEvent('End', sourceAbility, source.abilityData, source)
			target.battle:singleEvent('End', targetAbility, target.abilityData, target)
			if targetAbility.id ~= sourceAbility.id then
				source.ability = targetAbility.id
				target.ability = sourceAbility.id
				source.abilityData = {id = source.ability.id, target = source}
				target.abilityData = {id = target.ability.id, target = target}
			end
			source.battle:singleEvent('Start', targetAbility, source.abilityData, source)
			target.battle:singleEvent('Start', sourceAbility, target.abilityData, target)
		end,

		id = "wanderingspirit",
		name = "Wandering Spirit",
		rating = 3,
		num = 205
	},
	
	['icescales'] = {
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Ice Break')
		end,
		onAnyTryPrimaryHit = function(target, source, move)
			if target == source or move.category == 'Special' then return end
			source:addVolatile('aurabreak')
		end,
		effect = {
			duration = 1
		},
		id = "icescales",
		name = "Ice Scales",
		rating = 2,
		num = 206
	},
	
	['powerspot'] = { --TODO
		id = "powerspot",
		name = "Power Spot",
		rating = 2,
		num = 207
	},
	
	
	['iceface'] = {
		onHit = function(pokemon)
			pokemon:addVolatile('stall')
		end,
		duration = 1,
		onStart = function(target)
			if Not(target.template.forme) then
				self:add('-singleturn', target, 'ability = Ice Face')
			end
		end,
		onDamagePriority = -100,
		onDamage = function(damage, target, source, effect)

			if effect and effect.effectType == 'Move'and source.side ~= target.side and self:getCategory(effect.id) == 'Physical' and Not(target.template.forme) then
				self:add('-ability', target, 'Ice Face', '')
				local template = self:getTemplate('Eiscue-Noice')
				target:formeChange('Eiscue-Noiceface')
				self:add('-formechange', target, 'Eiscue-Noice')
				target.baseTemplate = template
				self:add('-disguised', target)
				return null
			--[[	
				if move.category ~= 'Status' then
					if Not(pokemon.template.forme) and pokemon:formeChange('Aegislash-Blade') then
						self:add('-formechange', pokemon, 'Aegislash-Blade')
					end
				elseif move.id == 'kingsshield' then
					if pokemon.template.forme == 'Blade' and pokemon:formeChange('Aegislash') then
						self:add('-formechange', pokemon, 'Aegislash')
				--]]
			end
		end,
		id = "iceface",
		name = "Ice Face",
		rating = 2,
		num = 208
		},
	
	-- does this work idk
	['hungerswitch'] = {
		onResidualOrder = 26,
		onResidual = function(pokemon)
			if pokemon.baseTemplate.baseSpecies ~= 'Morpeko' then return end
			
			if pokemon.template.speciesid == 'morpeko' then
				pokemon:formeChange('Morpeko-Hangry')
				self:add('-formechange', pokemon, 'Morpeko-Hangry', '[from] ability: Hunger Switch')
			else
				pokemon:formeChange('Morpeko')
				self:add('-formechange', pokemon, 'Morpeko', '[from] ability: Hunger Switch')
			end
		end,
		id = "hungerswitch",
		name = "Hunger Switch",
		rating = 3,
		num = 209
	},

	
	['stalwart'] = { --TODO
		id = "stalwart",
		name = "Stalwart",
		rating = 2,
		num = 210
	},
	
	['intrepidsword'] = {
		onStart = function(pokemon)
			local activated = false
			for _, foe in pairs(pokemon.side.active) do
			--	if foe ~= null and self:isAdjacent(foe, pokemon) then
				--	if not activated then
				--		self:add('-ability', pokemon, 'Intrepid Sword')
				--		activated = true
				--	end
					if foe.volatiles['substitute'] then
						self:add('-activate', foe, 'Substitute', 'ability = Intrepid Sword', '[of] ' .. pokemon)
					else
						self:boost({atk = 1}, foe, pokemon)
					end
				end
			end,
		--end,
		id = "intrepidsword",
		name = "Intrepid Sword",
		rating = 3.5,
		num = 211
	
	},
	
	['dauntlessshield'] = {
		onStart = function(pokemon)
			local activated = false
			for _, foe in pairs(pokemon.side.active) do
				--	if foe ~= null and self:isAdjacent(foe, pokemon) then
			--	if not activated then
			--		self:add('-ability', pokemon, 'Dauntless Shield')
			--		activated = true
		--		end
				if foe.volatiles['substitute'] then
					self:add('-activate', foe, 'Substitute', 'ability = Dauntless Shield', '[of] ' .. pokemon)
				else
					self:boost({def = 1}, foe, pokemon)
				end
			end
		end,
		--end,
		id = "dauntlessshield",
		name = "Dauntless Shield",
		rating = 3.5,
		num = 212

	},
	['unseenfist'] = {
		flags = {contact = true, protect = true, mirror = true},
		onTryHit = function(pokemon)
			-- will shatter screens through sub, before you hit
			if not Not(pokemon:runImmunity('Fighting')) then
				pokemon.side:removeSideCondition('protect')
				pokemon.side:removeSideCondition('detect')
			end
		end,
		--end,
		id = "unseenfist",
		name = "Unseen Fist",
		rating = 3.5,
		num = 213

	},
	['transistor'] = {
		onBasePower = function(basePower, attacker, defender, move)
			if move.type == 'Electric' then
				self:debug('regieleki transistor electric move boost')
				return self:chainModify(1.5)
			end
		end,
		--end,
		id = "transistor",
		name = "Transistor",
		rating = 3.5,
		num = 214


	},
	
	['dragonsmaw'] = {
		onBasePower = function(basePower, attacker, defender, move)
			if move.type == 'Dragon' then
				self:debug('regidrago\'s Dragon\'s Maw Dragon move boost')
				return self:chainModify(1.5)
			end
		end,
		--end,
		id = "dragonsmaw",
		name = "Dragon's Maw",
		rating = 3.5,
		num = 215


	},
	
	['chillingneigh'] = {
		id = "chillingneigh",
		name = "Chilling Neigh",
		onSourceFaint = function(target, source, effect)
			if effect and effect.effectType == 'Move' then 
				local stat = 'atk'
				local bestStat = 0
				for i, s in pairs(source.stats) do
					if (source.stats[i] > bestStat) then
						stat = i
						bestStat = source.stats[i]
					end
				end
				self:boost({[stat]=1}, source)
			end
		end,
		rating = 3,
		num = 216,
	},
	['grimneigh'] = {
		id = "grimneigh",
		name = "Grim Neigh",
		onSourceFaint = function(target, source, effect)
			if effect and effect.effectType == 'Move' then 
				local stat = 'spa'
				local bestStat = 0
				for i, s in pairs(source.stats) do
					if (source.stats[i] > bestStat) then
						stat = i
						bestStat = source.stats[i]
					end
				end
				self:boost({[stat]=1}, source)
			end
		end,
		rating = 3,
		num = 217,
	},
	
	['curiousmedicine'] = {
		id = "curiousmedicine",
		name = "Curious Medicine",
		onStart = function(pokemon)
			self:add('-ability', pokemon, 'Curious Medicine')
			self:add('-clearboost', pokemon)
			pokemon:clearBoosts()
		end,
		rating = 2,
		num = 218
},
	
	
	['pastelveil'] = {
		id = "pastelveil",
		name = "Pastel Veil",
		onAllySetStatus = function(status, target, source, effect)
			if status.id == 'psn' then
				self:debug('Pastel Veil interrupts poison')
				return false
			end
		end,
		onAllyTryHit = function(target, source, move)
			if move and move.id == 'toxic' then
				self:debug('Pastel Veil blocking Toxic')
				return false
			end
		end,
		rating = 2,
		num = 219
	},
	
	['gorillatactics'] = { --TODO
		id = "gorillatactics",
		name = "Gorilla Tactics",
		rating = 2,
		num = 220
	},
	
	
	['mimicry'] = {
	
		onStart = function(target)

			local newType = 'Normal'
			if self:isTerrain('electricterrain') then
				newType = 'Electric'
			elseif self:isTerrain('grassyterrain') then
				newType = 'Grass'
			elseif self:isTerrain('mistyterrain') then
				newType = 'Fairy'
			end

			if Not(target:setType(newType)) then return false end
			self:add('-start', target, 'typechange', newType)
		end,
			
		--end,
		id = "mimicry",
		name = "Mimicry",
		rating = 2,
		num = 221
		
	},
	['tanglinghair'] = {
		onAfterDamageOrder = 1,
		onAfterDamage = function(pokemon, damage, target, source, move)
			for _, foe in pairs(pokemon.side.foe.active) do
				if foe ~= null and self:isAdjacent(foe, pokemon) then
					if source and source ~= target and move and move.flags['contact'] then
						self:boost({spd = -1}, foe, pokemon)
					end
				end
			end
		end,
		id = "tanglinghair",
		name = "Tangling Hair",
		rating = 3,
		num = 222
	},
	
	['galvanize'] = {
		onModifyMovePriority = -1,
		onModifyMove = function(move, pokemon)
			if move.type == 'Normal' then
				move.type = 'Electric'
				if move.category ~= 'Status' then
					pokemon:addVolatile('galvanize')
				end
			end
		end,
		effect = {
			duration = 1,
			onBasePowerPriority = 8,
			onBasePower = function(basePower, pokemon, target, move)
				return self:chainModify(0x14CD, 0x1000)
			end
		},
		id = "galvanize",
		name = "Galvanize",
		rating = 4,
		num = 223
	},
	
	-- does this work?
	asone = {
		onBeforeStart = function(pokemon)
			self:add('-ability', pokemon, 'As One')
			self:add('-ability', pokemon, 'Unnerve', pokemon.side.foe)
		end,
		onFoeTryEatItem = false,
		onSourceAfterFaint = function(length, target, source, effect)
			if (effect and effect.effectType == 'Move') then
				if source.template.forme == 'shadowrider' then
					self:boost({atk = length}, source, source, self:getAbility('grimneigh'))

				else
					self:boost({atk = length}, source, source, self:getAbility('chillingneigh'))
				end
			end
		end,
		name = "As One",
		id = 'asone',
		rating = 3.5,
		num = 224,
	},
	
	-- no idea if this works, gotta test
	['powerconstruct'] = {
		onStart = function(pokemon)
			if pokemon.baseTemplate.baseSpecies ~= 'Zygarde' or pokemon.transformed then return end
			if pokemon.hp <= pokemon.maxhp / 2 and pokemon.template.speciesid ~= 'zygardecomplete' then
				self:add('-ability', pokemon, 'Power Construct')
				local completeTemplate = self:getTemplate('Zygarde-Complete')
				pokemon:formeChange('Zygarde-Complete')
				pokemon.baseTemplate = completeTemplate

				-- Update visuals and stats
				local shinyPrefix = pokemon.shiny and '_SHINY' or ''
				pokemon.details = pokemon.species .. ', L' .. pokemon.level .. 
					(pokemon.gender == '' and '' or ', ') .. pokemon.gender .. 
					(pokemon.set.shiny and ', shiny' or '')

				-- Set up sprites and data
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/Zygarde-Complete')
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/Zygarde-Complete')

				-- Update overrides
				pokemon.iconOverride = completeTemplate.icon-1
				pokemon.frontSpriteOverride = require(game:GetService('ServerStorage').Data.Spritesheets)[shinyPrefix..'_FRONT']['Zygarde-Complete']
				pokemon.typeOverride = completeTemplate.types
				pokemon.baseStatOverride = completeTemplate.baseStats

				self:add('-formechange', pokemon, 'Zygarde-Complete', '[from] ability: Power Construct')
			end
		end,
		onResidualOrder = 27,
		onResidual = function(pokemon)
			if pokemon.baseTemplate.baseSpecies ~= 'Zygarde' or pokemon.transformed then return end
			if pokemon.hp <= pokemon.maxhp / 2 and pokemon.template.speciesid ~= 'zygardecomplete' then
				self:add('-activate', pokemon, 'ability: Power Construct')
				local completeTemplate = self:getTemplate('Zygarde-Complete')
				pokemon:formeChange('Zygarde-Complete')
				pokemon.baseTemplate = completeTemplate
				pokemon.baseStatOverride = completeTemplate.baseStats
				self:add('-formechange', pokemon, 'Zygarde-Complete', '[from] ability: Power Construct')
			end
		end,
		isPermanent = true,
		name = "Power Construct",
		rating = 4,
		num = 225
	},

	['battery'] = {
		onAllyBasePower = function(basePower, attacker, defender, move)
			if move.category == 'Special' and attacker ~= self.effectData.target then
				return self:chainModify(1.3)
			end
		end,
		id = "battery",
		name = "Battery",
		rating = 0,
		num = 226
	},

	-- old power construct
	--[[
	['powerconstruct'] = {
		onStart = function(pokemon)
			local template = self:getTemplate('Zygarde')
			if pokemon.hp > pokemon.maxhp/4 and pokemon.baseTemplate == template then 
				self:add('-ability', pokemon, 'Power Construct', '')
				local schooltemplate = self:getTemplate('Zygarde-Complete')
				pokemon:formeChange('Zygarde-Complete')
				pokemon:formeChange(schooltemplate)
				self:add('-formechange', pokemon, 'Zygarde-Complete')
				pokemon.baseTemplate = schooltemplate
				pokemon:setAbility(schooltemplate.abilities[1])
				pokemon.baseAbility = pokemon.ability
				pokemon.details = pokemon.species .. ', L' .. pokemon.level .. (pokemon.gender == '' and '' or ', ') .. pokemon.gender .. (pokemon.set.shiny and ', shiny' or '')
				local shinyPrefix = pokemon.shiny and '_SHINY' or ''
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/Zygarde-Complete')
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/Zygarde-Complete')

				pokemon.iconOverride = schooltemplate.icon-1
				pokemon.frontSpriteOverride = require(game:GetService('ServerStorage').Data.Spritesheets)[shinyPrefix..'_FRONT']['Zygarde-Complete']
				pokemon.abilityOverride = schooltemplate.abilities[1]
				pokemon.typeOverride = schooltemplate.types
				pokemon.baseStatOverride = schooltemplate.baseStats
				self:add('-powerconstructon', pokemon)
			else return end
		end,

		onSwitchOut = function(pokemon)
			local schooltemplate = self:getTemplate('Zygarde-Complete')
			local template = self:getTemplate('Zygarde')
			if pokemon.baseTemplate == schooltemplate then
				pokemon:formeChange('Zygarde')
				pokemon:formeChange(template)
				self:add('-formechange', pokemon, 'Zygarde')
				pokemon.baseTemplate = template
				pokemon:setAbility(template.abilities[1])
				pokemon.baseAbility = pokemon.ability
				pokemon.details = pokemon.species .. ', L' .. pokemon.level .. (pokemon.gender == '' and '' or ', ') .. pokemon.gender .. (pokemon.set.shiny and ', shiny' or '')
				local shinyPrefix = pokemon.shiny and '_SHINY' or ''
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/Zygarde')
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/Zygarde')

				pokemon.iconOverride = template.icon-1
				pokemon.frontSpriteOverride = require(game:GetService('ServerStorage').Data.Spritesheets)[shinyPrefix..'_FRONT']['Zygarde']
				pokemon.abilityOverride = template.abilities[1]
				pokemon.typeOverride = template.types
				pokemon.baseStatOverride = template.baseStats
			else return end
		end,

		id = "powerconstruct",
		name = "Power Construct",
		rating = 5,
		num = 225
	},
	--]]
	
	}