--print('movedex: loading utilities')
local null, indexOf, Not, toId; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	null = util.null
	indexOf = util.indexOf
	Not = util.Not
	toId = util.toId
end
--print('movedex: utilities loaded')

-- current 828 moves
-- current save structure ONLY SUPPORTS 1023

--[[ Todo:

	
	FOR GEN 7 MOVES:
	- Terrain Extender
	
	PS has updated two-turn moves with an event called 'MoveAborted' that may replace the 'twoturnmove' volatile
	
	Flags:
	
	- cantusetwice
--]]

self = nil -- to hush intelisense; self property is injected at object-call simulation; see BattleEngine::call / BattleEngine::callAs

--[[ Flags

authentic: Ignores a target's substitute.
bite: Power is multiplied by 1.5 when used by a Pokemon with the Ability Strong Jaw.
bullet: Has no effect on Pokemon with the Ability Bulletproof.
charge: The user is unable to make a move between turns.
contact: Makes contact.
defrost: Thaws the user if executed successfully while the user is frozen.
distance: Can target a Pokemon positioned anywhere in a Triple Battle.
gravity: Prevented from being executed or selected during Gravity's effect.
heal: Prevented from being executed or selected during Heal Block's effect.
mirror: Can be copied by Mirror Move.
nonsky: Prevented from being executed or selected in a Sky Battle.
powder: Has no effect on Grass-type Pokemon, Pokemon with the Ability Overcoat, and Pokemon holding Safety Goggles.
protect: Blocked by Detect, Protect, Spiky Shield, and if not a Status move, King's Shield.
pulse: Power is multiplied by 1.5 when used by a Pokemon with the Ability Mega Launcher.
punch: Power is multiplied by 1.2 when used by a Pokemon with the Ability Iron Fist.
recharge: If this move is successful, the user must recharge on the following turn and cannot make a move.
reflectable: Bounced back to the original user by Magic Coat or the Ability Magic Bounce.
snatch: Can be stolen from the original user and instead used by another Pokemon using Snatch.
sound: Has no effect on Pokemon with the Ability Soundproof.
--]]

return {

	--------------------------------------------------------------------------------------------------
	--[[Generation 9 Moves listed below!]]--

["hardpress"] = {
	num = 933,
	accuracy = 100,
	basePower = 0,
	basePowerCallback = function(pokemon, target)
		local hp = target.hp
		local maxHP = target.maxhp
		-- TODO figure out actual BP cap
		local bp = math.floor(math.floor((120 * (100 * math.floor(hp * 4096 / maxHP)) + 2048 - 1) / 4096) / 100) or 1
		self:debug('BP for ' .. hp .. '/' .. maxHP .. " HP = " .. bp);
		return bp;
	end,
	category = "Physical",
	name = "Hard Press",
	pp = 10,
	priority = 0,
	flags = {
		contact = true, 
		protect = true, 
		mirror = true
	},
	target = "normal",
	type = "Steel",
},

["upperhand"] = {
	num = 932,
	accuracy = 100,
	basePower = 65,
	category = "Physical",
	name = "Upper Hand",
	pp = 15,
	priority = 3,
	flags = {contact = true, protect = true, mirror = true},
	onTryHit = function(target, pokemon)
		local action = self:willMove(target)
		local move = action.choice == 'move' and action.move or nil

		if not move or move.priority <= 0.1 or move.category == 'Status' then
			return false
		end
	end,
	secondary = {
		chance = 100,
		volatileStatus = 'flinch',
	},
	target = "normal",
	type = "Fighting",
},

["alluringvoice"] = {
	num = 931,
	accuracy = 100,
	basePower = 80,
	category = "Special",
	name = "Alluring Voice",
	pp = 10,
	priority = 0,
	flags = {
		protect = true, 
		mirror = true, 
		sound = true, 
		bypasssub = true
	},
	secondary = {
		chance = 100,
		onHit = function(target, source, move)
			if target.statsRaisedThisTurn then
				target:addVolatile('confusion', source, move)
			end
		end,
	},
	target = "normal",
	type = "Fairy",
},

['malignantchain'] = {
	num = 930,
	accuracy = 100,
	basePower = 100,
	category = "Special",
	id = "malignantchain",
	isNonStandard  = "Unobtainable",
	name = "Malignant Chain",
	priority = 0,
	pp = 5,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 50,
		status = 'tox',
	},
	target = "normal",
	type = "Poison",
},

['terastarstorm'] = {
	num = 929,
	accuracy = 100,
	basePower = 120,
	category = "Special",
	id = "terastarstorm",
	name = "Tera Starstorm",
	priority = 0,
	pp = 5,
	flags = {protect = true, mirror = true, noassist = true, failcopycat = true, failmimic = true},
	onModifyType = function(move, pokemon)
		if (pokemon.species.name == 'Terapagos-Stellar') then
			move.type = 'Stellar'
		else 
			move.type = 'Normal'
		end
	end,
	onModifyMove = function(move, pokemon)
		if (pokemon.species.name == 'Terapagos-Stellar') then
			move.target = "allAdjacentFoes"
		else
			move.target = "Normal"
		end
	end,
	noSketch = true,
	target = "normal",
	type = "Normal",
},

['tachyoncutter'] = {
	num = 928,
	accuracy = true,
	basePower = 50,
	category = "Special",
	id = "tachyoncutter",
	name = "Tachyon Cutter",
	priority = 0,
	pp = 10,
	flags = {contact = true, mirror = true, slicing = true},
	multihit = 2,
	target = "normal",
	type = "Steel",
	contestType  = "Clever",
},

['psychicnoise'] = {
	num = 927,
	accuracy = 100,
	basePower = 75,
	category = "Special",
	id = "psychicnoise",
	name = "Psychic Noise",
	priority = 0,
	pp = 10,
	flags = {protect = true, mirror = true, sound = true, bypasssub = true},
	secondary = {
		chance = 100,
		volatileStatus = 'healblock'
	},
	target = "normal",
	type = "Psychic",
},

['mightycleave'] = {
	num = 926,
	accuracy = 100,
	basePower = 95,
	category = "Special",
	id = "mightycleave",
	name = "Mighty Cleave",
	priority = 0,
	pp = 5,
	flags = {contact = true, mirror = true, slicing = true},
	target = "normal",
	type = "Rock",
},

['thunderclap'] = {
	num = 925,
	accuracy = 100,
	basePower = 70,
	category = "Special",
	id = "thunderclap",
	name = "Thunderclap",
	priority = 1,
	pp = 5,
	flags = {protect = true, mirror = true},
	onTry = function(source, target)
		local decision = self:willMove(target)
		if not decision or decision.choice ~= 'move' or (decision.move.category == 'Status' and decision.move.id ~= 'mefirst') or target.volatiles.mustrecharge then
			self:add('-fail', source)
			return null
		end
	end,
	target = "normal",
	type = "Electric",
	contestType  = "Clever",
},

['supercellslam'] = {
	num = 924,
	accuracy = 95,
	basePower = 100,
	category = "Physical",
	id = "supercellslam",
	name = "Supercell Slam",
	priority = 0,
	pp = 15,
	flags = {contact = true, protect = true, mirror = true},
	hasCrashDamage = true,
	onMoveFail = function(target, source, move)
		self:damage(source.maxhp / 2, source, source, 'supercellslam')
	end,
	target = "normal",
	type = "Electric"
},

['temperflare'] = {
	num = 923,
	accuracy = 100,
	basePower = 75,
	--		basePowerCallback = function(pokemon, target, move)
	--			if (???) then
	--				return move.basePower * 2 
	--			end
	--			return move.basePower
	--		end,
	category = "Physical",
	id = "temperflare",
	name = "Temper Flare",
	priority = 0,
	pp = 10,
	flags = {contact = true, protect = true, mirror = true},
	target = "normal",
	type = "Fire"
},

['burningbulwark'] = {
	num = 922,
	accuracy = true,
	basePower = 0,
	category = "Status",
	id = "burningbulwark",
	name = "Burning Bulwark",
	pp = 10,
	priority = 4,
	stallingMove = true,
	volatileStatus = 'burningbulwark',
	onPrepareHit = function(pokemon)
		return not Not(self:willAct()) and not Not(self:runEvent('StallMove', pokemon))
	end,
	onHit = function(pokemon)
		pokemon:addVolatile('stall')
	end,
	condition = {
		duration = 1,
		onStart = function(target)
			self:add('-singleturn', target, 'move: Protect') --add to Actions
		end,
		onTryHitPriority = 3,
		onTryHit = function(target, source, move)
			if not move.flags['protect'] then return end
			self:add('-activate', target, 'move = Protect')
			local lockedmove = source:getVolatile('lockedmove')
			if lockedmove then
				-- Outrage counter is reset
				if source.volatiles['lockedmove'].duration == 2 then
					source.volatiles['lockedmove'] = nil
				end
			end
			if move.flags['contact'] then
				source:trySetStatus('brn')
			end
			return null
		end,
		onHit = function(pokemon, source, move)
			if move.flags['contact'] then
				source:trySetStatus('brn', pokemon)
			end
		end,
	},
	target = "self",
	type = "Fire"
},

['ficklebeam'] = {
	num = 921,
	accuracy = 100,
	basePower = 80,
	category = "Special",
	id = "ficklebeam",
	name = "Fickle Beam",
	pp = 5,
	flags = {protect = true, mirror = true},
	onBasePowerPriority = 1,
	onBasePower = function(basePower, pokemon)
		if math.random(10) <= 3 then
			self:add('-activate', pokemon, 'move: Fickle Beam')
			return self:chainModify(2) end  
	end,
	target = "normal",
	type = "Dragon"
},

['dragoncheer'] = {
	num = 920,
	accuracy = true,
	basePower = 0,
	category = "Status",
	id = "dragoncheer",
	name = "Dragon Cheer",
	priority = 0,
	pp = 15,
	volatileStatus = 'dragoncheer',
	condition = {
		onStart = function(target, source, effect)
			if target.volatiles['focusenergy'] then return false end
			if effect and (effect.id == 'costar' or effect.id == 'imposter' or effect.id == 'psychup' or effect.id == 'transform') then
				self:add('-start', target, 'move: Dragon Cheer', '[silent]')			
			else
				self:add('-start', target, 'move: Dragon Cheer')
			end
		end,
		onModifyCritRatio = function(critRatio, source, target)
			return critRatio + target:hasType('Dragon') and 2 or 1
		end,
	},
	flags = {bypasssub = true, allyanim = true},
	target = "adjacentAlly",
	type = "Dragon"
},

['electroshot'] = {
	num = 919,
	accuracy = 100,
	basePower = 130,
	category = "Special",
	id = "electroshot",
	name = "Electro Shot",
	priority = 0,
	pp = 10,
	onTryMove = function(attacker, defender, move)
		if (attacker:removeVolatile(move.id)) then
			return
		end
		self:add('-prepare', attacker, move.name)
		self:boost({spa = 1}, attacker, move.name, defender)
		if self:isWeather({'raindance', 'primordialsea'}) then
			self:attrLastMove('[still]')
			self:add('-anim', attacker, move.name, defender)
		end
		if not (self:runEvent('ChargeMove', attacker, defender, move)) then
			return
		end
		attacker:addVolatile('twoturnmove', defender)
		return 
	end,
	hasSheerForce = true,
	flags = {charge = true, protect = true, mirror = true},
	target = "normal",
	type = "Electric"
},

["bloodmoon"] = {
	num = 918,
	accuracy = 100,
	basePower = 140,
	category = "Special",
	name = "Blood Moon",
	pp = 5,
	priority = 0,
	flags = {
		protect = true, 
		mirror = true, 
		cantusetwice = true -- TODO: Flag functionallity
	},
	target = "normal",
	type = "Normal",
},

["matchagotcha"] = {
	num = 917,
	accuracy = 90,
	basePower = 80,
	category = "Special",
	name = "Matcha Gotcha",
	pp = 15,
	priority = 0,
	flags = {
		protect = true, 
		mirror = true, 
		defrost = true
	},
	drain = {1, 2},
	thawsTarget = true,
	secondary = {
		chance = 20,
		status = 'brn',
	},
	target = "allAdjacentFoes",
	type = "Grass",
},

["syrupbomb"] = {
	num = 916,
	accuracy = 85,
	basePower = 60,
	category = "Special",
	name = "Syrup Bomb",
	pp = 10,
	priority = 0,
	flags = {
		protect = true, 
		mirror = true, 
		bullet = true
	},
	condition = {
		noCopy = true,
		duration = 3,
		onStart = function(pokemon, source) 
			self:add('-start', pokemon, 'Syrup Bomb')
		end,
		onResidualOrder = 14,
		onResidual = function(pokemon) 
			self:boost({spe = -1})
		end,
		onEnd = function(pokemon)
			self:add('-end', pokemon, 'Syrup Bomb')
		end,
	},
	secondary = {
		chance = 100,
		volatileStatus = 'syrupbomb',
	},
	target = "normal",
	type = "Grass",
},

["ivycudgel"] = {
	num = 915,
	accuracy = 100,
	basePower = 100,
	category = "Physical",
	name = "Ivy Cudgel",
	pp = 10,
	priority = 0,
	flags = {
		protect = true, 
		mirror = true
	},
	critRatio = 2,
	onModifyType = function(move, pokemon)
		if pokemon.species.name == 'Ogerpon-Wellspring' then
			move.type = 'Water'
		elseif pokemon.species.name == 'Ogerpon-Hearthflame' then
			move.type = 'Fire'
		elseif pokemon.species.name == 'Ogerpon-Cornerstone' then
			move.type = 'Rock'
		end
	end,
	target = "normal",
	type = "Grass",
},

['aquastep'] = {
	num = 852,
	accuracy  = 100,
	basePower = 80,
	category = "Physical",
	id = "aquastep",
	name = "Aqua Step",
	pp = 10,
	priority  = 0,
	flags = {contact = true, protect = true, mirror = true},
	secondary = {
		chance = 100,
		self = {
			boosts = {
				spe = 1
			}
		}
	},
	target = "normal",
	type = "Water"
},
['aquacutter'] = {
	num = 853,
	accuracy = true,
	basePower = 70 ,
	category = "Physical",
	id = "aquacutter",
	name = "Aqua Cutter",
	pp = 20,
	priority = 0,
	flags = {protect = true,  mirror = true},
	target = "normal",
	type = "Water",
	contestType  = "Cool",
},

['armorcannon'] = {
	num = 854,
	accuracy  = 100,
	basePower = 120,
	category = "Special",
	name = "Armor Cannon",
	pp = 5,
	priority = 0,
	flags = {protect = 1, mirror = 1},
	self = {
		boosts = {
			def = -1,
			spd = -1,
		},
	},
	target = "normal",
	type = "Fire",
},

['axekick'] = {
	num = 828,
	accuracy =  90,
	basePower =  120,
	category =  "Physical",
	id = "axekick",
	name = "Axe Kick",
	pp = 10,
	flags = { contact = true, protect = true, mirror = true,},
	target = "allAdjacentFoes",
	type = "Fighting",

},

['bitterblade'] = {
	num = 855,
	accuracy  = 100,
	basePower = 90,
	category =  "Physical",
	name = "Bitter Blade",
	pp = 10,
	priority = 0,
	flags = {contact = 1, protect = 1, mirror = 1},
	drain =  {1, 2},
	target = "normal",
	type = "Fire",
},

['blazingtorque'] = {
	num = 856,
	accuracy  = 100,
	basePower = 80,
	category = "Physical",
	id = "blazingtorque",
	isNonStandard  = "Unobtainable",
	name = "Blazing Torque",
	pp = 10,
	priority = 0,
	flags = {
		protect = 1, failencore = 1, failmefirst = 1, nosleeptalk= 1, noassist= 1, failcopycat= 1, failinstruct= 1, failmimic = 1
	},
	secondary  ={
		chance = 30,
		status = 'brn'
	},
	target = "normal",
	type = "Fire",
},
['chillingwater'] = {
	num = 857,
	accuracy  = 100,
	basePower = 50,
	category = "Special",
	id = "chillingwater",
	name = "Chilling Water",
	pp = 20,
	priority  = 0,
	flags = {protect = 1, mirror = 1},
	secondary = {
		chance = 100,
		boosts = {
			atk = -1
		},
	},
	target = "normal",
	type = "Water",
	contestType = "Beutiful",
},
['chillyreception'] = {
	num = 858,
	accuracy = true,
	basePower = 0,
	category = "Status",
	id = "chillyreception",
	name = "Chilly Reception",
	pp = 10,
	priority = 0,
	flags = {},
	weather = 'snow',
	selfSwitch  = true,
	target = "all",
	type = "Ice",
},
['collisioncourse'] = {
	num = 859,
	accuracy = 100,
	basePower = 100,
	category =  "Physical",
	id = "collisioncourse",
	name = "Colision Course",
	pp = 5,
	priority = 0,
	flags = {contact = 1, protect = 1, mirror = 1},
	onBasePower = function(basePower, source, target, move)
		if (target.runEffectiveness(move) > 0) then
			self:debug('collision course super effective buff')
			return self:chainModify({5461, 4096})
		end
	end,
	target = "normal",
	type = "Fighting",
	contestType = "Tough",
},
['combattorque'] = {
	num = 860,
	accuracy = 100,
	power = 100,
	category = "Physical",
	id = "combattorque",
	name = "Combat Torque",
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true, mefirst = true, sleeptalk = true, assist = true },
	secondary = {
		chance = 30,
		status = 'par',
	},
	target = "normal",
	type  = "Fighting",
},
['comeuppance'] = {
	num = 861,
	accuracy = 100,
	basePower = 0,
	id = "comeuppance",
	name = "Comeuppance",
	damageCallback = function(pokemon, undefined)
		local lastDamagedBy = pokemon.getLastDamagedBy(true)
		if (lastDamagedBy ~= undefined) then
			return (lastDamagedBy.damage * 1.5) 
		end
		return 0
	end,
	category = "Physical",
	pp = 10,
	priority =0,
	flags = {contact = 1, protect = 1, mirror=  1, mefirst = 1 },
	onTry = function(source,undefined)
		local lastDamagedBy = source.getLastDamagedBy(true)
		if (lastDamagedBy == undefined  or lastDamagedBy.thisTurn ) then end return false
	end,
	onModifyTarget  = function(targetRelayVar, source, target, move)
		local lastDamagedBy = source.getLastDamagedBy(true)
		if (lastDamagedBy) then
			targetRelayVar.target = self:getAtSlot(lastDamagedBy.slot)
		end
	end,
	target = "scripted",
	type = "Dark",
	contestType = "Cool",
},


['doodle'] = {
	num = 863,
	accuracy  = 100,
	basePower = 0,
	category = "Status",
	id = "doodle",
	name = "Doodle",
	pp = 10,
	priority = 0,
	flags = {},
	onHit = function(target, source, move , pokemon)
		local success = false
		for _, pokemon in pairs(source.pokemon) do
			if (pokemon.ability == target.ability) then
				local oldAbility = pokemon.setAbility(target.Ability)
				if (oldAbility) then
					self:add('-ability', pokemon, target:getAbility().name, '[from] move: Doodle')
					success = true
				elseif (success and oldAbility == false) then
					success = false
				end
			end
		end
	end,
},
['doubleshock'] = {
	num = 864,
	accuracy = 100,
	basePower = 120,
	category = "Physical",
	id = "doubleshock",
	name = "Double Shock",
	pp = 5,
	priority = 0,
	flags = {contact = 1 , protect = 1, mirror = 1,},
	onTryMove = function(pokemon, target, move)
		if (pokemon.hasType('Electric')) then return
			self:add('-fail', pokemon, 'move: Double Shock'),
			self:attrLastMove('[still]')

		end

		self = {
			pokemon.setType(pokemon.getTypes(true).map),
			self:add('-start', pokemon, 'typechange', pokemon.getTypes().join('/'), '[from] move: Double Shock')
		}
	end,
	target = "normal",
	type = "Electric",
	contestType = "Clever",
},
['electrodrift'] = {
	num = 865,
	accuracy  = 100,
	basePower = 100,
	category = "Special",
	id = "electrodrift",
	name = "Electro Drift",
	pp = 5,
	priority = 0,
	flags = {contact = 1, protect = 1, mirror = 1},
	onBasePower = function(basePower, source, target , move)
		if (target.runEffectiveness(move) > 0) then
			self:Debug("Electro Drift Super Effective Buff")
			return self:chainModify(5461, 4096)
		end
	end,
	target = "normal",
	type = "Electric",
	contestType = "Cool",
},
['filletaway'] = {
	num = 866,
	accuracy = true,
	basePower = 0,
	category = "Status",
	id = "filletaway",
	name = "Fillet Away",
	pp = 10,
	priority = 0,
	flags = {snatch = 1},
	onTry = function(source)
		if (source.hp <= source.maxhp/2 or source.maxhp == 1) then
			return false
		end
	end,
	onTryHit = function(pokemon, target, move)
		if (self:boost(move.boosts)) then
			move.boosts = false
		end
	end,
	onHit = function(pokemon)
		self:damage(pokemon.maxhp / 2)
	end,
	boosts = {
		atk = 2,
		spa = 2,
		spe = 2,
	},
	target = "self",
	type = "Normal"
},
['flowertrick'] = {
	num = 867,
	accuracy = true,
	basePower = 70,
	category = "Physical",
	id = "flowertrick",
	name = "Flower Trick",
	pp = 10,
	willCrit = true,
	flags = {protect = true, mirror = true},
	target = "allAdjacentFoes",
	type = "Grass"
},
['gigatonhammer'] = {
	num = 868,
	accuracy  =100,
	basePower = 160,
	category = "Physical",
	id = "gigatonhammer",
	name = "Gigaton Hammer",
	pp = 5,
	priority = 0,
	flags = {protect = 1, mirror = 1},
	onDisableMove = function(pokemon)
		if (pokemon.lastMove.id  == 'gigatonhammer')  then
			pokemon:disablMove('gigatonhammer')
		end
	end,
	beforeMoveCallback = function(pokemon)
		if (pokemon.lastMove.id == 'gigatonhammer') then
			pokemon:addVolatile('gigatonhammer')
		end
	end,
	onAfterMove = function(pokemon)
		if (pokemon:removeVolatile('gigatonhammer')) then
			self:add('-hint', "Some effects can force a Pokemon to use Gigaton Hammer again in a row")
		end
	end,
	condition = {},
	target = "normal",
	type  = "Steel",

},

['glaiverush'] = {
	num = 829,
	accuracy = 100,
	basePower = 120,
	category = "Physical",
	name = "Glaive Rush",
	id = 'glaiverush',
	pp = 5,
	priority = 0,
	flags = {contact = true, protect = true, mirror = true},
	self = {
		volatileStatus = 'glaiverush',
	},
	condition = {
		noCopy = true,
		duration = 2,
		onRestart = function() 
			self.effectData.duration = 2
		end,
		onSourceModifyDamage = function()
			return self:chainModify(2)
		end,
	},
	target = "normal",
	type = "Dragon",
},

['hydrosteam'] = {    
	num = 827,
	accuracy = 100,
	basePower = 80,
	category = "Special",
	nam = "Hydro Steam",
	pp = 15,
	priority = 0,
	flags = {
		protect = true, 
		mirror = true, 
		defrost = true
	},
	thawsTarget = true,
	onBasePower = function (basePower, user, target, move)
		if self:effectiveWeather() == 'sunnyday' then
			self:debug('hydro steam sun boost')
			return self:chainModify(1.5)
		end
	end,
	target = "normal",
	type = "Water",
},
['hyperdrill'] = {
	num = 869,
	accuracy = 100,
	nasePower = 100,
	category = "Physical",
	id =  "hyperdrill",
	name = "Hyper Drill",
	pp = 5,
	flags = {mirror = 1 , contact =1 },
	target = "allAdjacentFoes",
	type = "Normal"
},
['icespinner'] = {
	num = 870,
	accuracy  = 100,
	basePower = 80,
	category = "Physical",
	id = "icespinner",
	name = "Ice Spinner",
	pp = 15,
	priority = 0,
	flags = {contact = 1, protect  = 1 , mirror = 1},
	onHit = function()
		self.field:clearTerrian()
	end,
	onAfterSubDamage = function()
		self.field:clearTerrian()
	end,
	target = "normal",
	type = "Ice",
},
['jetpunch'] = {
	num = 871,
	accuracy = 100,
	basePower = 60,
	category = "Physical",
	id = "jetpunch",
	name = "Jet Punch",
	pp = 15,
	priority = 1,
	flags = {contact = 1, protect = 1, mirror = 1, punch = 1},
	hasSheerForce = true,
	target = "normal",
	type = "Water"
},
['kowtowcleave'] = {
	num = 872,
	accuracy = true,
	basePower = 85,
	category = "Physical",
	id = "kowtowcleave",
	name = "Kowtow Cleave",
	pp = 10,
	priority = 0,
	flags = {contact = 1, protect = 1, mirror = 1},
	target = "normal",
	type = "Dark"
},
['lastrespects'] = {
	num = 873,
	accuracy = 100,
	basePower = 50,
	basePowerCallback = function(pokemon, target, move)
		return 50 + 50 * pokemon.side.totalFainted
	end,
	category = "Physical",
	id = "lastrespects",
	name = "Last Respects",
	pp = 10,
	flags = { protect = 1, mirror = 1},
	target = "normal",
	type = "Ghost"
},
['luminacrash'] = {
	num = 874,
	accuracy = 100,
	basePower = 0,
	category = "Special",
	id = "luminacrash",
	name = "Lumina Crash",
	pp = 10,
	flags = {protect = 1,  mirror = 1},
	boosts = {
		chance = 100,
		spd = -2
	},
	target = "allAdjacentFoes",
	type = "Physic"
},

['magicaltorque'] = {
	num = 875,
	accuracy = 100,
	basePower =  100,
	category = "Physical",
	id = "magicaltorque",
	name = "Magical Torque",
	pp = 10,
	priority = 0,
	flags = {
		protect= 1, failencore= 1, failmefirst= 1, nosleeptalk= 1, noassist= 1, failcopycat= 1, failinstruct=1, failmimic= 1,
	},
	secondary ={
		chance = 30,
		volatileStatus ='confusion',
	},

	target = "allAdjacentFoes",
	type = "Fairy",

},

['makeitrain'] = {
	num = 830,
	accuracy =  100,
	basePower =  120,
	category =  "Special",
	id = "makeitrain",
	name = "Make It Rain",
	pp = 5,
	flags = { contact = true,  mirror = true},
	onHitSide = function(side, source)
		local targets = {}
		for _, ally in pairs(side.active) do
			if ally:useMove(ally.lastmove) then
				table.insert(targets, ally)
			end
		end
		if #targets == 0 then return false end
		for _, target in pairs(targets) do
			self:addMoney({5000}, target, source, 'move = Make it Rain')
		end
	end,
	target = "allAdjacentFoes",
	type = "Fighting",

},

['mortalspin'] = {
	num = 876,
	accuracy = 100,
	basePower = 30,
	category = "Physical",
	id ="mortalspin",
	name = "Mortal Spin",
	pp = 15,
	priority  =0, 
	flags = {contact = 1 , protect = 1, mirror = 1},
	onAfterHit = function(target, pokemon, condition)
		if (pokemon.hp and pokemon:removeVolatile('leechseed')) then
			self:add('-end', pokemon, 'Leech Seed', '[from] move: Mortal Spin', '[of]' + pokemon)
		end
		local sideConditions = {'spikes', 'toxicspikes', 'stealthrock', 'stickyweb', 'gmaxsteelsurge'}
		if (pokemon.hp and pokemon.side.removeSideCondition(condition)) then
			self:add('-sideend', pokemon.side, self.dex.conditions.get(condition).name, '[from] move = Mortal Spin', '[of]' + pokemon)
		end

	end,
	Pokemon = function(pokemon)
		if (pokemon.hp and pokemon.volatiles['partiallytrapped']) then
		end
	end,
	target = "allAdjacentFoes",
},
['noxioustorque'] = {
	num = 877,
	accuracy = 100,
	basePower =  100,
	category = "Physical",
	id = "noxioustorque",
	name = "Noxious Torque",
	pp = 10,
	flags = {protect = true , },
	target = "allAdjacentFoes",
	type = "Poision",

},
['orderup'] = {
	num = 878,
	accuracy = 100,
	basePower =  80,
	category = "Physical",
	id = "orderup",
	name = "Order Up",
	pp = 10,
	flags = {protect = true , mirror = true },
	target = "allAdjacentFoes",
	type = "Dragon",

},
['populationbomb'] = {
	num = 879,
	accuracy =  90,
	basePower =  20,
	category = "Physical",
	id = "populationbomb",
	name = "Population Bomb",
	pp = 10,
	multihit = {1, 10},
	flags = {contact = true, protect = true , mirror = true },
	target = "allAdjacentFoes",
	type = "Normal",

},
['pounce'] = {
	num = 880,
	accuracy = 100,
	basePower = 20,
	category = "Physical",
	id = "pounce",
	name = "Pounce",
	pp = 20,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 100,
		boosts = {
			spe = -1
		}
	},
	target = "allAdjacentFoes",
	type = "Bug"
},

['psyblade'] = {
	num = 826,
	accuracy = 100,
	basePower = 80,
	category = "Physical",
	name = "Psyblade",
	pp = 15,
	priority = 0,
	flags = {
		contact = true, 
		protect = true, 
		mirror = true, 
		slicing = true,
	},
	onBasePower = function (basePower, user, target, move)
		if self:getPseudoWeather('electricterrain') and user:isGrounded() then
			self:debug('psyblade electric terrain boost')
			return self:chainModify(1.5)
		end
	end,
	target = "normal",
	type = "Psychic",
},

['ragefist'] = {
	num = 881,
	accuracy = 100,
	basePower = 50,
	category = "Physical",
	id = "ragefist",
	name = "Rage Fist",
	pp = 10,
	flags = {contact = true,protect = true, mirror = true},
	onHitSide = function(side, source)
		local targets = {}
		for _, ally in pairs(side.active) do
			if ally:useMove(ally.lastmove) then
				table.insert(targets, ally)
			end
		end
		if #targets == 0 then return false end
		for _, target in pairs(targets) do
			self:boost({atk = 1}, target, source, 'move = Rage Fist')
		end
	end,
	target = "allAdjacentFoes",
	type = "Ghost"
},
['ragingbull'] = {
	num = 882,
	accuracy = 100,
	basePower = 90,
	category = 'Physical',
	name = 'Raging Bull',
	id = 'ragingbull',
	pp = 10,
	priority = 0,
	flags = {contact = true, protect = true, mirror = true},
	onTryHit = function(pokemon) 
		pokemon.side:removeSideCondition('reflect');
		pokemon.side:removeSideCondition('lightscreen');
		pokemon.side:removeSideCondition('auroraveil');
	end,
	onModifyType = function(move, pokemon) 
		if pokemon.species.name == 'Tauros-Paldea' then
			move.type = 'Fighting'
		elseif pokemon.species.name == 'Tauros-PaldeaFire' then
			move.type = 'Fire'
		elseif pokemon.species.name == 'Tauros-PaldeaWater' then
			move.type = 'Water'
		end
	end,
	target = 'normal',
	type = 'Normal',
},
['revivalblessing'] = {
	num = 883,
	accuracy = true,
	basePower = 0,
	category = "Status",
	name = "Revival Blessing",
	id = 'revivalblessing',
	pp = 1,
	noPPBoosts = true,
	priority = 0,
	flags = false,
	onTryHit = function (source, ally) 
		if (source.side.pokemon:filter(ally.fainted).length) then
			return false
		end
	end,
	sideCondition = 'revivalblessing',
	selfSwitch = true,
	condition = {
		duration = 1,
	},
	target = "self",
	type = "Normal",
},
['ruination'] = {
	num = 878,
	accuracy = 90,
	basePower = 0,
	damageCallback = function(pokemon, target) 
		return self:clampIntRange(math.floor(target.maxhp / 2), 1)
	end,
	category = "Special",
	name = "Ruination",
	id = 'ruination',
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true},
	target = "normal",
	type = "Dark",
},
['saltcure'] = {
	num = 879,
	accuracy = 100,
	basePower = 40,
	category = 'Physical',
	name = 'Salt Cure',
	id = 'saltcure',
	pp = 15,
	priority = 0,
	flags = {protect = 1, mirror = 1},
	condition = {
		onStart = function(pokemon, source) 
			self:add('-start', pokemon, 'move = Salt Cure', '[of] ' + source)
		end,
		onResidualOrder = 13,
		onResidual = function(pokemon) 
			local a = 8
			if pokemon:hasType('Water') or pokemon:hasType('Steel') then
				a = 4
			end
			self:damage(pokemon.maxhp / (a))
		end,
		onEnd = function(pokemon) 
			self:add('-end', pokemon, 'move = Salt Cure')
		end,
	},
	secondary = {
		chance = 100,
		volatileStatus = 'saltcure',
	},
	target = 'normal',
	type = 'Rock',
},
['shedtail'] = {
	num = 880,
	accuracy = true,
	basePower = 0,
	category = "Status",
	name = "Shed Tail",
	id = 'shedtail',
	pp = 10,
	priority = 0,
	volatileStatus = 'substitute',
	onTryHit = function(source) 
		if not source.side:canSwitch(source.side) then
			self:add('-fail', source)
		end
		if source.volatiles['substitute'] then
			self:add('-fail', source, 'move = Shed Tail')
		end
		if (source.hp <= source.maxhp / 2) then
			self:add('-fail', source, 'move = Shed Tail', '[weak]')
		end
	end,
	onHit = function(target) 
		self:directDamage(target.maxhp / 2)
	end,
	selfSwitch = true,
	target = "self",
	type = "Normal",
},
['silktrap'] = {
	num = 881,
	accuracy =  100,
	basePower =  100,
	category =  "Status",
	id = "silktrap'",
	name = "Silk Trap",
	pp = 15,
	priority = 4,
	stallingMove = true,
	volatileStatus = 'protect',
	boosts = {

		spe = -1
	},
	flags = { protect = false},
	target = "allAdjacentFoes",
	type = "Bug",

},
['snowscape'] = {
	num = 882,
	accuracy =  100,
	basePower =  100,
	category =  "Status",
	id = "snowscape'",
	name = "Snowscape",
	pp = 15,
	effect = {
		duration = 4,
		onLockMove = 'snowscape',
		onStart = function(pokemon)
			self.effectData.totalDamage = 0;
			self:add('-start', pokemon, 'Snowscape')
		end,
		boosts = {
			def = 1,
		}
	},
	flags = false,
	target = "Self",
	type = "Ice",

},
['spicyextract'] = {
	num = 883,
	accuracy =  100,
	basePower =  100,
	category =  "Status",
	id = "spicyextract'",
	name = "Spicy Extract",
	pp = 15,
	boosts = {
		def = -1,
		atk = 1,
		spe = 1
	},
	flags = { protect = true , mirror = true , reflectable = true,},
	target = "allAdjacentFoes",
	type = "Grass",

},
['spinout'] = {
	num = 884,
	accuracy =  100,
	basePower =  100,
	category =  "Physical",
	id = "spinout'",
	name = "Spin Out",
	pp = 5,
	boosts = {
		spe = 2
	},
	flags = {contact = true, protect = true , mirror = true },
	target = "allAdjacentFoes",
	type = "Steel",

},
['terablast'] = { -- moment when no terrasteralize or whatever its called, lol
	num = 885,
	accuracy =  100,
	basePower =  100,
	category =  "Physical",
	id = "terablast'",
	name = "Tera Blast",
	pp = 10,
	flags = {contact = true, protect = true , mirror = true },
	target = "allAdjacentFoes",
	type = "Normal",
},
['tidyup'] = {
	num = 886,
	accuracy =  100,
	basePower =  0,
	category =  "Status",
	id = "tidyup'",
	name = "Tidy Up",
	pp = 10 ,

	flags = {authentic = true },
	boosts = {
		atk = 1,
		spe = 1
	},
	target = "allAdjacentFoes",
	type = "Fire",

},
['torchsong'] = {
	num = 887,
	accuracy =  100,
	basePower =  80,
	category =  "Special",
	id = "torchsong",
	name = "Torch Song",
	pp = 20,
	flags = {contact = true, protect = true, mirror = true},
	secondary = {
		chance = 100,
		self = {
			boosts = {
				spa = 1
			}
		}
	},
	target = "normal",
	type = "Fire"
},
['trailblaze'] = {
	num = 888,
	accuracy =  100,
	basePower =  50,
	category =  "Physical",
	id = "trailblaze'",
	name = "Trialblaze",
	pp = 20,
	flags = {contact = true, protect = true , mirror = true },
	boosts = {
		spe = 1
	},
	target = "allAdjacentFoes",
	type = "Grass",

},
['tripledive'] = {
	num = 889,
	accuracy =  95,
	basePower =  30,
	category =  "Physical",
	id = "tripledive",
	name = "Triple Dive",
	pp = 10,
	multihit = 3,
	flags = {contact = true, protect = true , mirror = true },
	target = "allAdjacentFoes",
	type = "Water",

},
['twinbeam'] = {
	num = 890,
	accuracy =  100,
	basePower =  40,
	category =  "Physical",
	id = "twinbeam",
	name = "Twin Beam",
	pp = 10,
	multihit = 2,
	flags = {contact = true, protect = true , mirror = true },
	target = "allAdjacentFoes",
	type = "Physic",

},
['wickedtorque'] = {
	num = 891,
	accuracy = 100,
	basePower =  80,
	category = "Physical",
	id = "wickedtorque",
	name = "Wicked Torque",
	pp = 10,
	flags = {protect = true , },
	target = "allAdjacentFoes",
	type = "Dark",

},
--------------------------------------------------------------------------------------------------
--[[Legends: Arceus Moves listed below!]]--

['barbbarrage'] = {
	num = 892,
	accuracy = 100,
	basePower = 60,
	category = 'Physical',
	name = 'Barb Barrage',
	id = 'barbbarrage',
	pp = 10,
	flags = {protect  = true, mirror  = true},
	onBasePower = function(basePower, pokemon, target) 
		if (target.status == 'psn' or target.status == 'tox') then
			return self:chainModify(2)
		end
	end,
	secondary = {
		chance = 50,
		status = 'psn',
	},
	target = 'normal',
	type = 'Poison',
},

['bittermalice'] = {
	num = 893,
	accuracy = 100,
	basePower = 75,
	category = 'Special',
	name = 'Bitter Malice',
	id = 'bittermalice',
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 100,
		boosts = {
			atk = -1,
		},
	},
	target = 'normal',
	type = 'Ghost',
},

['bleakwindstorm'] = { -- REDO THIS ITS WRONG 
	num = 894, 
	basePower = 100,
	accruacy  = 80,
	category = "Special",
	id = "bleakwindstorm",
	name = "Bleakwind Storm",
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 30,
		boosts = {
			spe = 1
		}
	},
	target = "allAdjacentFoes",
	type = "Flying",
},

['ceaselessedge'] = {
	num = 895,
	accuracy = 90,
	basePower = 65,
	category = 'Physical',
	name = 'Ceaseless Edge',
	id = 'ceaselessedge',
	pp = 15,
	priority = 0,
	flags = {contact = true, protect = true, mirror = true, spikes=true},
	onHit = function(source)
		--     if source.side.sideConditions['spikes'] then
		self.side:addSideCondition('spikes')
		--    end
	end,
	target = 'Normal',
	type = 'Dark',
},

['chloroblast'] = {
	num = 896,
	accuracy = 95,
	basePower = 150,
	category = 'Special',
	name= 'Chloroblast',
	id = 'chloroblast',
	pp= 5,
	priority= 0,
	flags = {protect= true, mirror= true},
	mindBlownRecoil = true,
	onAfterMove = function(pokemon, target, move) 
		if (move.mindBlownRecoil and not move.multihit) then    
			self:damage(math.round(pokemon.maxhp / 2), pokemon, pokemon, self:getEffect('Chloroblast'), true)    
		end
	end,
	target = 'normal',
	type = 'Grass',
},

['direclaw'] = {
	num = 897,
	accuracy = 100,
	basePower = 80,
	category = "Physical",
	name = "Dire Claw",
	pp = 15,
	priority = 0,
	flags = {
		contact = true, 
		protect = true, 
		mirror = true
	},
	secondary = {
		chance = 50,
		onHit = function(target, source) 
			target:trySetStatus(({'psn', 'par', 'slp'})[math.random(3)], source)
		end,
	},
	target = "normal",
	type = "Poison",
},

['esperwing'] = {
	num = 898,
	accuracy = 100,
	basePower = 80,
	category = 'Special',
	name = 'Esper Wing',
	id = 'esperwing',
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true},
	critRatio = 2,
	secondary = {
		chance = 100,
		self = {
			boosts = {
				spe = 1,
			},
		},
	},
	target = 'normal',
	type = 'Psychic',
},

['headlongrush'] = {
	num = 899,
	accuracy = 100,
	basePower = 120,
	category = 'Physical',
	name = 'Headlong Rush',
	id = 'headlongrush',
	pp = 5,
	priority = 0,
	flags = {contact = true, protect = true, mirror = true, punch = true},
	self = {
		boosts = {
			def = -1,
			spd = -1,
		},
	},
	target = 'normal',
	type = 'Ground',
},

['infernalparade'] = {
	num = 900,
	accuracy = 100,
	basePower = 60,
	basePowerCallback = function(pokemon, target, move) 
		if target.status or target.hasAbility('comatose') then 
			return move.basePower * 2
		end
		return move.basePower
	end,
	category = 'Special',
	name = 'Infernal Parade',
	id = 'infernalparade',
	pp = 15,
	priority = 0,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 30,
		status = 'brn',
	},
	target = 'normal',
	type = 'Ghost',
},

['lunarblessing'] = {
	num = 901,
	basepower = 0,
	accuracy = 100,
	category = "Status",
	id = "lunarblessing",
	name = "Lunar Blessing",
	pp = 5,
	priortiy = 0,
	flags = {snatch = true, heal = true}, 
	boosts = {
		accuracy = -1
	}, 
	duration = 1, 
	heal = {1, 2},
	OnHit = function(Pokemon, Source)
		for _, ally in pairs(Pokemon.side.pokemon) do
			ally.status = ''
		end
		self:add('-cureteam', Source, '[from] move = LunarBlessing')  
	end,
	target = "allyTeam",
	type = "Psychic",
},

['mountaingale'] = {
	num = 902,
	accuracy = 85,
	basePower = 100,
	category = 'Physical',
	name = 'Mountain Gale',
	id = 'mountaingale',
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 30,
		volatileStatus = 'flinch',
	},
	target = 'normal',
	type = 'Ice',
},

['mysticalpower'] = {  
	num = 903, 
	basePower = 70,
	accruacy  = 90,
	category = "Special",
	id = "mysticalpower",
	name = "Mystical Power",
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 100,
		self = {
			boosts = {
				spa = 1
			}
		},
		boosts = {
			def = -1,
			spd = -1,
			atk = 2,
			spa = 2,
			spe = 2
		},
		target = "Normal",
		type = "Psychic",
	},
},

['powershift'] = {  -- Get this checked 
	num = 904, 
	basePower = 0,
	accruacy  = true,
	category = "Status",
	id = "powershift",
	name = "Power Shift",
	pp = 10,
	priority = 0,
	flags  = {snatch  = true},
	volatileStatus = 'powershift',
	effect = {
		onStart = function(pokemon)
			self:add('-start', pokemon, 'Power Shift')
			local newspdef = pokemon.stats.spa
			local newspatk = pokemon.stats.spd
			local newatk = pokemon.stats.def
			local newdef = pokemon.stats.atk
			pokemon.stats.spd = newspatk
			pokemon.stats.spa = newspdef
			pokemon.stats.atk = newatk
			pokemon.stats.def = newdef
		end,
		onCopy = function(pokemon)
			self:add('-start', pokemon, 'Power Shift')
			local newspdef = pokemon.stats.spa
			local newspatk = pokemon.stats.spd
			local newatk = pokemon.stats.def
			local newdef = pokemon.stats.atk
			pokemon.stats.spd = newspatk
			pokemon.stats.spa = newspdef
			pokemon.stats.atk = newatk
			pokemon.stats.def = newdef
		end,
		onEnd = function(pokemon)
			self:add('-end', pokemon, 'Power Shift')
			local newspdef = pokemon.stats.spa
			local newspatk = pokemon.stats.spd
			local newatk = pokemon.stats.def
			local newdef = pokemon.stats.atk
			pokemon.stats.spd = newspatk
			pokemon.stats.spa = newspdef
			pokemon.stats.atk = newatk
			pokemon.stats.def = newdef
		end,
		onRestart = function(pokemon)
			pokemon:removeVolatile('Power Shift')
		end,

		target = "self",
		type = "Normal",
	}
},

['psyshieldbash'] = {
	num = 905,
	accuracy = 90,
	basePower = 70,
	category = 'Physical',
	name = 'Psyshield Bash',
	id = 'psyshieldbash',
	pp = 10,
	flags = {protect = true, mirror = true, contact = true},
	--sideCondition = 'stealthrock',
	--effect = {
	--	onStart = function(side)
	--		self:add('-sidestart', side, 'move = Stealth Rock')
	--	end,
	--},	
	--target = "foeSide",
	type = 'Psychic',
},

['ragingfury'] = {
	num = 906,
	accuracy = 100,
	basePower = 120,
	category = 'Physical',
	name = 'Raging Fury',
	id = 'ragingfury',
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true},
	self = {
		volatileStatus = 'lockedmove',
	},
	onAfterMove = function(pokemon) 
		if pokemon.volatiles['lockedmove'] and pokemon.volatiles['lockedmove'].duration == 1 then
			pokemon:removeVolatile('lockedmove')
		end
	end,
	target = 'randomNormal',
	type = 'Fire',
},

['sandsearstorm'] = {  -- Guranteed done
	num = 907, 
	basePower = 100,
	accruacy  = 80,
	category = "Special",
	id = "sandsearstorm",
	name = "Sandsear Storm",
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true, wind = true},
	secondary = {
		chance = 30,
		status = 'brn'
	},
	target = "normal",
	type = "Fire",
},

['shelter'] = {
	num = 908,
	accuracy = true,
	basePower = 0,
	category = 'Status',
	name = 'Shelter',
	id = 'shelter',
	pp = 10,
	priority = 0,
	flags = {snatch = true},
	boosts = {
		def = 2,
	},
	target = 'self',
	type = 'Steel',
},

['springtidestorm'] = {
	num = 909,
	accuracy = 80,
	basePower = 100,
	category = 'Special',
	name = 'Springtide Storm',
	id = 'springtidestorm',
	pp = 5,
	priority = 0,
	flags = {protect = true, mirror = true, wind = true},
	secondary = {
		chance = 30,
		boosts = {
			atk = -1,
		},
	},
	target = 'allAdjacentFoes',
	type = 'Fairy',
},

['stoneaxe'] = {
	num = 910,
	accuracy = 90,
	basePower = 65,
	category = 'Physical',
	name = 'Stone Axe',
	id = 'stoneaxe',
	pp = 15,
	flags = {protect = true, mirror = true, contact = true},
	sideCondition = 'stealthrock',
	effect = {
		onStart = function(side)
			self:add('-sidestart', side, 'move = Stealth Rock')
		end,
	},	
	target = "foeSide",
	type = 'Rock',
},

['takeheart'] = {  -- Guranteed done
	num = 911, 
	basePower = 0,
	accruacy  = true,
	category = "Status",
	id = "takeheart",
	name = "Take Heart",
	pp = 15,
	priority = 0,
	flags  = {snatch  = true},
	boosts = {
		spa = 1,
		spd = 1,
	},
	OnHit = function(pokemon)
		pokemon:cureStatus() --  pokemon.cureStatus = true idk if this works but yk 
	end,
	target = "self",
	type = "Psychic",
},


['triplearrows'] = {
	num = 912,
	accuracy = 100,
	basePower = 90,
	category = 'Physical',
	name = 'Triple Arrows',
	id = 'triplearrows',
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true},
	critRatio = 2,
	secondaries = {
		{
			chance = 50,
			boosts = {
				def = -1,
			},
		}, {
			chance = 30,
			volatileStatus = 'flinch',
		},
	},
	target = 'normal',
	type = 'Fighting',
},

['wavecrash'] = {
	num = 913,
	accuracy = 100,
	basePower = 120,
	category = 'Physical',
	name = 'Wave Crash',
	id = 'wavecrash',
	pp = 10,
	priority = 0,
	flags = {contact = true, protect = true, mirror = true},
	recoil = {33, 100},
	target = 'normal',
	type = 'Water',
},

['victorydance'] = {
	num = 831,
	accuracy = true,
	basePower = 0,
	category = 'Status',
	name = 'Victory Dance',
	id = 'victorydance',
	pp = 10,
	priority = 0,
	flags = {snatch = 1, dance = 1},
	boosts = {
		atk = 1,
		def = 1,
		spe = 1,
	},
	target = 'self',
	type = 'Fighting',
},

['wildboltstorm'] = {  -- Guranteed done
	num = 914, 
	basePower = 100,
	accruacy  = 80,
	category = "Special",
	id = "wildboltstorm",
	name = "Wildbolt Storm",
	pp = 10,
	priority = 0,
	flags = {protect = true, mirror = true, wind = true},
	secondary = {
		chance = 20,
		status = 'par'
	},
	target = "allAdjacentFoes",
	type = "Electric",
},

--------------------------------------------------------------------------------------------------

['teatime'] = {
	num = 752,
	accuracy = true,
	basePower = 0,
	category = 'Status',
	name = 'Teatime',
	id = 'teatime',
	pp = 10,
	priority = 0,
	flags = {authentic = true}, 
	onHitField = function(target, source, move)
		local result = false
		for _, side in pairs(self.sides) do --Need to add function for getAllActive 
			for _, active in pairs(side.active) do
				if self:runEvent('Invulnerability', active, source, move) == false then --need to check
					self:add('-miss', source, active)
					result = true
				elseif self:runEvent('TryHit', active, source, move) then
					local item = active:getItem()
					if (active.hp and item.isBerry) then
						--Bypass Unnerve
						active:eatItem(true)
						result = true
					end
				end
			end
		end
		return result
	end,
	target = 'all',
	type = 'Normal',
},	

['octolock'] = {
	num = 753,
	accuracy = 100,
	basePower = 0,
	category = 'Status',
	name = 'Octolock',
	id = 'octolock',
	pp = 15,
	flags = {protect = true, mirror = 1},
	onTryImmunity = function(target)
		return self:getImmunity('trapped', target)
	end,
	volatileStatus = 'octolock',
	condition = {
		onStart = function(pokemon, source)
			self:add('-start', pokemon, 'move: Octolock', '[of] '..source) --add to Actions
		end,
		onResidualOrder = 11,
		onResidual = function(pokemon)
			local source = self.effectData.source --Define?
			if (source and not (source.isActive or source.hp >= 1 or source.activeTurns)) then
				pokemon:removeVolatiles('octolock')
				self:add('-end', pokemon, 'Octolock', '[partiallytrapped]', '[silent]')
				return
			end
			self:boost({def = -1, spd = -1}, pokemon, source, self:getActiveMove('octolock'))
		end,
		onTrapPokemon = function(pokemon)
			if (self.effectData.source and self.effectData.source.isActive) then
				pokemon:tryTrap()
			end
		end,
	},
	target = 'normal',
	type = 'Fighting',
},		

['boltbeak'] = {
	num = 754,
	accuracy = 100,
	basePower = 85,
	basePowerCallback = function(pokemon, target, move)
		if (target.newlySwitchedand and self:willMove(target)) then
			return move.basePower *2
		end
		return move.basePower
	end,
	category = 'Physical',
	name = 'Bolt Beak',
	id = 'boltbeak',
	pp = 10,
	priority = 0,
	flags = {contact = true, protect = true, mirror = true},
	target = 'normal',
	type = 'Electric',
},		

['fishiousrend'] = {
	num = 969,
	accuracy = 100,
	basePower = 85,
	basePowerCallback = function(pokemon, target, move)
		if (target.newlySwitched or self:willMove(target)) then
			return move.basePower * 2 
		end
		return move.basePower
	end,
	category = 'Physical',
	name = 'Fishious Rend',
	id = 'fishiousrend',
	pp = 10,
	priority = 0,
	flags = {bite = true, contact = 1, protect = 1, mirror = 1},
	target = 'normal',
	type = 'Water',
},			

['courtchange'] = {
	num = 756,
	accuracy = 100,
	basePower = 0,
	category = 'Status',
	name = 'Court Change',
	id = 'courtchange',
	pp = 10,
	priority = 0,
	flags = {mirror = true},
	onHitField = function(target, source)
		local sourceSide = source.Side
		local targetSide = source.side.foe
		local sideConditions = {'mist', 'lightscreen', 'reflect', 'spikes', 'safeguard', 'tailwind', 'toxicspikes', 'stealthrock', 'waterpledge', 'firepledge', 'grasspledge', 'stickyweb', 'auroraveil', 'gmaxsteelsurge', 'gmaxcannonade', 'gmaxvinelash', 'gmaxwildfire'} --WHYYYY
		local success = false
		for _, id in pairs(sideConditions) do
			local effectName = self:getEffect(id).name
			if (sourceSide.sideConditions[id] and targetSide.sideConditions[id]) then
				sourceSide.sideConditions[id] = targetSide.sideConditions[id]
				targetSide.sideConditions[id] = sourceSide.sideConditions[id]
				self:add('-sideend', sourceSide, effectName, '[silent]')
				self:add('-sideend', targetSide, effectName, '[silent]')
			elseif (sourceSide.sideConditions[id] and not targetSide.sideConditions[id]) then
				targetSide.sideConditions[id] = sourceSide.sideConditions[id]
				sourceSide:removeSideCondition(id)
				self:add('-sideend', sourceSide, effectName, '[silent]')
			elseif (targetSide.sideConditions[id] and not sourceSide.sideConditions[id]) then
				sourceSide.sideConditions[id] = targetSide.sideConditions[id]
				targetSide:removeSideCondition(id)
				self:add('-sideend', targetSide, effectName, '[silent]')
			end
			local sourceLayers = (sourceSide.sideConditions[id] and sourceSide.sideConditions[id].layers) and 1 or 0
			local targetLayers = (targetSide.sideConditions[id] and targetSide.sideConditions[id].layers) and 1 or 0
			for _, bruh in pairs(sourceLayers) do
				if bruh > 0 then
					self:add('-sidestart', sourceSide, effectName, '[silent]')
				end
			end
			for _, bruh in pairs(targetLayers) do
				if bruh > 0 then
					self:add('-sidestart', bruh, effectName, '[silent]')
				end
			end
			success = true
		end
		if not success then return false end
		self:add('-activate', source, 'move: Court Change')
	end,
	target = 'all',
	type = 'Normal',
},

	-- Z Moves
	['aciddownpour'] = {
		num = 628,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "aciddownpour",
		name = "Acid Downpour",
		pp = 1,
		isZ = "poisoniumz",
		target = "normal",
		type = "Poison",
	},
	['alloutpummeling'] = {
		num = 624,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "alloutpummeling",
		name = "All-Out Pummeling",
		pp = 1,
		isZ = "fightiniumz",
		target = "normal",
		type = "Fighting",
	},
	['blackholeeclipse'] = {
		num = 654,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "blackholeeclipse",
		name = "Black Hole Eclipse",
		pp = 1,
		isZ = "darkiniumz",
		target = "normal",
		type = "Dark",
	},
	['bloomdoom'] = {
		num = 644,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "bloomdoom",
		name = "Bloom Doom",
		pp = 1,
		isZ = "grassiumz",
		target = "normal",
		type = "Grass",
	},
	['breakneckblitz'] = {
		num = 622,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "breakneckblitz",
		name = "Breakneck Blitz",
		pp = 1,
		isZ = "normaliumz",
		target = "normal",
		type = "Normal",
	},
	['continentalcrush'] = {
		num = 632,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "continentalcrush",
		name = "Continental Crush",
		pp = 1,
		isZ = "rockiumz",
		target = "normal",
		type = "Rock",
	},
	['corkscrewcrash'] = {
		num = 638,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "corkscrewcrash",
		name = "Corkscrew Crash",
		pp = 1,
		isZ = "steeliumz",
		target = "normal",
		type = "Steel",
	},
	['devastatingdrake'] = {
		num = 652,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "devastatingdrake",
		name = "Devastating Drake",
		pp = 1,
		isZ = "dragoniumz",
		target = "normal",
		type = "Dragon",
	},
	['gigavolthavoc'] = {
		num = 646,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "gigavolthavoc",
		name = "Gigavolt Havoc",
		pp = 1,
		isZ = "electriumz",
		target = "normal",
		type = "Electric",
	},
	['hydrovortex'] = {
		num = 642,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "hydrovortex",
		name = "Hydro Vortex",
		pp = 1,
		isZ = "wateriumz",
		target = "normal",
		type = "Water",
	},
	['infernooverdrive'] = {
		num = 640,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "infernooverdrive",
		name = "Inferno Overdrive",
		pp = 1,
		isZ = "firiumz",
		target = "normal",
		type = "Fire",
	},
	['neverendingnightmare'] = {
		num = 636,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "neverendingnightmare",
		name = "Never-Ending Nightmare",
		pp = 1,
		isZ = "ghostiumz",
		target = "normal",
		type = "Ghost",
	},
	['savagespinout'] = {
		num = 634,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "savagespinout",
		name = "Savage Spin-Out",
		pp = 1,
		isZ = "buginiumz",
		target = "normal",
		type = "Bug",
	},
	['shatteredpsyche'] = {
		num = 648,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "shatteredpsyche",
		name = "Shattered Psyche",
		pp = 1,
		isZ = "psychiumz",
		target = "normal",
		type = "Psychic",
	},
	['subzeroslammer'] = {
		num = 650,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "subzeroslammer",
		name = "Subzero Slammer",
		pp = 1,
		isZ = "iciumz",
		target = "normal",
		type = "Ice",
	},
	['supersonicskystrike'] = {
		num = 626,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "supersonicskystrike",
		name = "Supersonic Skystrike",
		pp = 1,
		isZ = "flyiniumz",
		target = "normal",
		type = "Flying",
	},
	['tectonicrage'] = {
		num = 630,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "tectonicrage",
		name = "Tectonic Rage",
		pp = 1,
		isZ = "groundiumz",
		target = "normal",
		type = "Ground",
	},
	['twinkletackle'] = {
		num = 656,
		accuracy = true,
		basePower = 1,
		category = "Physical",
		id = "twinkletackle",
		name = "Twinkle Tackle",
		pp = 1,
		isZ = "fairiumz",
		target = "normal",
		type = "Fairy",
	},






	['dualwingbeat'] = {
		num = 814,
		accuracy = 90,
		basePower = 40,
		category = "Physical",
		name = "Dual Wingbeat",
		id = 'dualwingbeat',
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		multihit = 2,
		target = "normal",
		type = "Flying",
	},

	['tripleaxel'] = {
		num = 813,
		accuracy = 90,
		basePower = 20,
		basePowerCallback = function(pokemon, target, move)
			return 20 * move.hit
		end,
		category = "Physical",
		name = "Triple Axel",
		id = 'tripleaxel',
		pp = 10,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		multihit = 3,
		multiaccuracy = true,
		target = "normal",
		type = "Ice",
	},

	['junglehealing'] = {
		num = 816,
		accuracy = true,
		basePower = 0,
		category = 'Status',
		name = 'Jungle Healing',
		id = 'junglehealing',
		pp = 10,
		priority = 0,
		flags = {heal=1,authentic=1,mystery=1},
		onHit = function(pokemon)
			local success = not self:heal(self:modify(pokemon.maxhp, .25))
			return pokemon:cureStatus() or success
		end,
		target = 'allies',
		type = 'Grass',
	},

	['lightthatburnsthesky'] = {
		num = 723,
		accuracy = true,
		basePower = 200,
		category = "Special",
		id = "lightthatburnsthesky",
		name = "Light That Burns The Sky",
		onModifyMove = function(move, pokemon)
			if (pokemon:getStat('atk', false, true) > pokemon:getStat('spa', false, true)) then
				move.category = 'Physical';
			end
		end,
		ignoreAbility = true,
		pp = 1,
		target = "allAdjacentFoes",
		type = "Psychic"
	},

	['accelerock'] = {
		num = 709,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "accelerock",
		name = "Accelerock",
		pp = 20,
		priority = 1,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Rock",
	},
	['anchorshot'] = {
		num = 677,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "anchorshot",
		name = "Anchor Shot",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		onHit = function(target, source, move)
			if source.isActive then
				target:addVolatile('trapped', source, move, 'trapper')
			end
		end,
		target = "normal",
		type = "Steel",

	},
	['auroraveil'] = {
		num = 694,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "auroraveil",
		name = "Aurora Veil",
		pp = 20,
		flags = {snatch = true},
		sideCondition = 'auroraveil',
		onTryHitSide = function()
			if not self:isWeather('hail') then return false end
		end,
		effect = {
			duration = 5,
			durationCallback = function(target, source, effect)
				if source and source ~= null and source:hasItem('lightclay') then
					return 8
				end
				return 5
			end,
			onAnyModifyDamage = function(damage, source, target, move)
				if target ~= source and target.side == self.effectData.target then
					if not move.crit and not move.infiltrates then
						self:debug('Aurora Veil weaken')
						if #target.side.active > 1 then
							return self:chainModify({0xAAC, 0x1000})
						end
						return self:chainModify(0.5)
					end
				end
			end,
			onStart = function(side)
				self:add('-sidestart', side, 'move = Aurora Veil')
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 1,
			onEnd = function(side)
				self:add('-sideend', side, 'move = Aurora Veil')
			end,
		},
		target = "allySide",
		type = "Ice",
	},
	['banefulbunker'] = {
		num = 661,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "banefulbunker",
		name = "Baneful Bunker",
		pp = 10,
		priority = 4,
		stallingMove = true,
		volatileStatus = 'banefulbunker',
		onTryHit = function(target, source, move)
			return self:willAct() and not Not(self:runEvent('StallMove', target))
		end,
		onHit = function(pokemon)
			pokemon:addVolatile('stall')
		end,
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-singleturn', target, 'move = Protect')
			end,
			onTryHitPriority = 3,
			onTryHit = function(target, source, move)
				if not move.flags['protect'] then return end
				self:add('-activate', target, 'move = Protect')
				local lockedmove = source:getVolatile('lockedmove')
				if lockedmove then
					-- Outrage counter is reset
					if source.volatiles['lockedmove'].duration == 2 then
						source.volatiles['lockedmove'] = nil
					end
				end
				if move.flags['contact'] then
					source:trySetStatus('psn')
				end
				return null
			end,
		},
		target = "self",
		type = "Poison",
	},


	['blizzard'] = {
		num = 59,
		accuracy = 70,
		basePower = 110,
		category = "Special",
		id = "blizzard",
		name = "Blizzard",
		pp = 5,
		flags = {protect = true, mirror = true},
		onModifyMove = function(move)
			if self:isWeather('hail') then
				move.accuracy = true
			end
		end,
		secondary = {
			chance = 10,
			status = 'frz'
		},
		target = "allAdjacentFoes",
		type = "Ice"
	},

	['beakblast'] = {
		num = 690,
		accuracy = 100,
		basePower = 100,
		category = "Physical",
		id = "beakblast",
		name = "Beak Blast",
		pp = 15,
		priority = -3,
		flags = {bullet = true, protect = true},
		beforeTurnCallback = function(pokemon)
			pokemon:addVolatile('beakblast')
		end,
		effect = {
			duration = 1,
			onStart = function(pokemon)
				self:add('-singleturn', pokemon, 'move = Beak Blast')
			end,
			onHit = function(pokemon, source, move)
				if move.flags['contact'] then
					source:trySetStatus('brn', pokemon)
				end
			end,
		},
		target = "normal",
		type = "Flying",

	},

	['brutalswing'] = {
		num = 693,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "brutalswing",
		name = "Brutal Swing",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		target = "allAdjacent",
		type = "Dark",

	},

	['burnup'] = {
		num = 682,
		accuracy = 100,
		basePower = 130,
		category = "Special",
		id = "burnup",
		name = "Burn Up",
		pp = 5,
		flags = {protect = true, mirror = true, defrost = true},
		onTryHit = function(target, source, move)
			if not source:hasType('Fire') then return false end
		end,
		self = {
			onHit = function(pokemon)
				local otherType = '???'
				for _, type in pairs(pokemon:getTypes(true)) do
					if type ~= 'Fire' then
						otherType = type
						break
					end
				end
				pokemon:setType(otherType)
			end,
		},
		target = "normal",
		type = "Fire",

	},

	['clangingscales'] = {
		num = 691,
		accuracy = 100,
		basePower = 110,
		category = "Special",
		id = "clangingscales",
		name = "Clanging Scales",
		pp = 5,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		self = {
			boosts = {
				def = -1,
			},
		},
		target = "allAdjacentFoes",
		type = "Dragon",

	},

	['coreenforcer'] = {
		num = 687,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		id = "coreenforcer",
		name = "Core Enforcer",
		pp = 10,
		flags = {protect = true, mirror = true},
		onHit = function(target)
			if target.ability == 'multitype' or target.ability == 'stancechange' then return end
			if not self:willMove(target) then target:addVolatile('gastroacid') end
		end,
		target = "allAdjacentFoes",
		type = "Dragon",

	},
	['darkestlariat'] = {
		num = 663,
		accuracy = 100,
		basePower = 85,
		category = "Physical",
		id = "darkestlariat",
		name = "Darkest Lariat",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		ignoreEvasion = true,
		ignoreDefensive = true,
		target = "normal",
		type = "Dark",

	},
	['dragonhammer'] = {
		num = 692,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "dragonhammer",
		name = "Dragon Hammer",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Dragon",

	},
	['firelash'] = {
		num = 680,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "firelash",
		name = "Fire Lash",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				def = -1,
			},
		},
		target = "normal",
		type = "Fire",

	},
	['firstimpression'] = {
		num = 660,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "firstimpression",
		name = "First Impression",
		pp = 10,
		priority = 2,
		flags = {contact = true, protect = true, mirror = true},
		onTry = function(pokemon, target)
			if pokemon.activeTurns > 1 then
				self:add('-fail', pokemon)
				return null
			end
		end,
		target = "normal",
		type = "Bug",

	},
	['fleurcannon'] = {
		num = 705,
		accuracy = 90,
		basePower = 130,
		category = "Special",
		id = "fleurcannon",
		name = "Fleur Cannon",
		pp = 5,
		flags = {protect = true, mirror = true},
		self = {
			boosts = {
				spa = -2,
			},
		},
		target = "normal",
		type = "Fairy",

	},
	['floralhealing'] = {
		num = 666,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "floralhealing",
		name = "Floral Healing",
		pp = 10,
		flags = {protect = true, reflectable = true, heal = true, mystery = true},
		onHit = function(target)
			if self:isTerrain('grassyterrain') then
				self:heal(self:modify(target.maxhp, 0.667)) -- TODO = find out the real value
			else
				self:heal(math.ceil(target.maxhp * 0.5))
			end
		end,
		target = "normal",
		type = "Fairy",
	},
	['gearup'] = {
		num = 674,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "gearup",
		name = "Gear Up",
		pp = 20,
		flags = {snatch = true, authentic = true},
		onHitSide = function(side, source)
			local targets = {}
			for _, ally in pairs(side.active) do
				if ally:hasAbility('plus', 'minus') then
					table.insert(targets, ally)
				end
			end
			if #targets == 0 then return false end
			for _, target in pairs(targets) do
				self:boost({atk = 1, spa = 1}, target, source, 'move = Gear Up')
			end
		end,
		target = "allySide",
		type = "Steel",
	},
	['highhorsepower'] = {
		num = 667,
		accuracy = 95,
		basePower = 95,
		category = "Physical",
		id = "highhorsepower",
		name = "High Horsepower",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Ground",

	},
	['icehammer'] = {
		num = 665,
		accuracy = 90,
		basePower = 100,
		category = "Physical",
		id = "icehammer",
		name = "Ice Hammer",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		self = {
			boosts = {
				spe = -1,
			},
		},
		target = "normal",
		type = "Ice",

	},
	['instruct'] = {
		num = 689,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "instruct",
		name = "Instruct",
		pp = 15,
		flags = {protect = true, authentic = true, mystery = true},
		onHit = function(target, source)
			local noInstruct = {
				instruct = true, -- TODO = fill this up
			}
			if Not(target.lastMove) or self:getMove(target.lastMove).isZ or noInstruct[target.lastMove] then
				return false
			end
			self:add('-singleturn', target, 'move = Instruct', '[of] ' .. source)
			self:useMove(target.lastMove, target)
		end,
		target = "normal",
		type = "Psychic",
	},
	['laserfocus'] = {
		num = 673,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "laserfocus",
		name = "Laser Focus",
		pp = 30,
		flags = {snatch = true},
		volatileStatus = 'laserfocus',
		effect = {
			duration = 2,
			onStart = function(pokemon)
				self:add('-start', pokemon, 'move = Laser Focus')
			end,
			onModifyCritRatio = function(critRatio)
				return 5
			end,
		},
		target = "self",
		type = "Normal",
	},
	['leafage'] = {
		num = 670,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "leafage",
		name = "Leafage",
		pp = 40,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Grass",

	},
	['liquidation'] = {
		num = 710,
		accuracy = 100,
		basePower = 85,
		category = "Physical",
		id = "liquidation",
		name = "Liquidation",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 20,
			boosts = {
				def = -1,
			},
		},
		target = "normal",
		type = "Water",

	},
	['lunge'] = {
		num = 679,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "lunge",
		name = "Lunge",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				atk = -1,
			},
		},
		target = "normal",
		type = "Bug",

	},
	['steelbeam'] = {
		num = 796,
		accuracy = 95,
		basePower = 140,
		category = "Special",
		name = "Steel Beam",
		id = 'steelbeam',
		pp = 5,
		flags = {protect = true, mirror = true},
		mindBlownRecoil = true,
		onAfterMove = function(pokemon, target, move)
			if (move.mindBlownRecoil and not move.multihit) then
				self:damage(math.round(pokemon.maxhp / 2), pokemon, pokemon, self:getEffect('Steel Beam'), true)
			end
		end,
		target = "normal",
		type = "Steel",
	},
	['moongeistbeam'] = {
		num = 714,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		id = "moongeistbeam",
		name = "Moongeist Beam",
		pp = 5,
		flags = {protect = true, mirror = true},
		ignoreAbility = true,
		target = "normal",
		type = "Ghost",

	},
	['photongeyser'] = {
		num = 722,
		accuracy = 100,
		basePower = 100,
		category = 'Special',
		name = 'Photon Geyser',
		id = 'photongeyser',
		pp = 5,
		flags = {protect = true, mirror = true},
		onModifyMove = function(move, pokemon)
			if (pokemon:getStat('atk', false, true) > pokemon:getStat('spa', false, true)) then
				move.category = 'Physical'
			end
		end,
		ignoreAbility = true,
		target = 'normal',
		type = 'Psychic',
	},
	['multiattack'] = {
		num = 718,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "multiattack",
		name = "Multi-Attack",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		onModifyMove = function(move, pokemon)
			move.type = self:runEvent('Memory', pokemon, null, 'multiattack', 'Normal')
		end,
		target = "normal",
		type = "Normal",

	},
	['naturesmadness'] = {
		num = 717,
		accuracy = 90,
		basePower = 0,
		damageCallback = function(pokemon, target)
			return math.max(1, math.floor(target.hp / 2))
		end,
		category = "Special",
		id = "naturesmadness",
		name = "Nature's Madness",
		pp = 10,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Fairy",

	},
	['pollenpuff'] = {
		num = 676,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "pollenpuff",
		name = "Pollen Puff",
		pp = 15,
		flags = {protect = true, mirror = true},
		onTryHit = function(target, source, move)
			if source.side == target.side then
				move.basePower = 0
				move.heal = {1, 2}
			end
		end,
		target = "normal",
		type = "Bug",

	},
	['scorchingsands'] = {
		num = 815,
		accuracy = 100,
		basePower = 70,
		category = "Special",
		name = "Scorching Sands",
		id = 'scorchingsands',
		pp = 10,
		flags = {protect = true, mirror = true, defrost = true},
		thawsTarget = true,
		secondary = {
			chance = 30,
			status = 'brn',
		},
		target = "normal",
		type = "Ground",
	},
	['powertrip'] = {
		num = 681,
		accuracy = 100,
		basePower = 20,
		basePowerCallback = function(pokemon, target, move)
			return move.basePower + 20 * pokemon:positiveBoosts()
		end,
		category = "Physical",
		id = "powertrip",
		name = "Power Trip",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Dark",

	},
	['prismaticlaser'] = {
		num = 711,
		accuracy = 100,
		basePower = 160,
		category = "Special",
		id = "prismaticlaser",
		name = "Prismatic Laser",
		pp = 10,
		flags = {recharge = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'mustrecharge',
		},
		target = "normal",
		type = "Psychic",

	},
	['psychicfangs'] = {
		num = 706,
		accuracy = 100,
		basePower = 85,
		category = "Physical",
		id = "psychicfangs",
		name = "Psychic Fangs",
		pp = 10,
		flags = {bite = true, contact = true, protect = true, mirror = true},
		onTryHit = function(pokemon)
			-- will shatter screens through sub, before you hit
			if pokemon:runImmunity('Psychic') then
				pokemon.side:removeSideCondition('reflect')
				pokemon.side:removeSideCondition('lightscreen')
				pokemon.side:removeSideCondition('auroraveil')
			end
		end,
		target = "normal",
		type = "Psychic",

	},
	['behemothblade'] = {
		num = 781,
		accuracy = 100,
		basePower = 100,
		category = "Physical",
		name = "Behemoth Blade",
		id = 'behemothblade',
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Steel",
	},
	['behemothbash'] = {
		num = 782,
		accuracy = 100,
		basePower = 100,
		category = "Physical",
		name = "Behemoth Bash",
		id = 'behemothbash',
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Steel",
	},
	['aurawheel'] = {
		num = 783,
		accuracy = 100,
		basePower = 110,
		category = "Physical",
		name = "Aura Wheel",
		id = 'aurawheel',
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			self = {
				boosts = {
					spe = 1,
				},
			},
		},
		onTry = function(source)
			if (source.species.baseSpecies == 'Morpeko')  then
				return
			end
			self:attrLastMove('[still]')
			self:add('-fail', source, 'move: Aura Wheel')
			return 
		end,
		onModifyType = function(move, pokemon)
			if (pokemon.species.name == 'Morpeko-Hangry') then
				move.type = 'Dark'
			else 
				move.type = 'Electric'
			end
		end,
		target = "normal",
		type = "Electric",
	},
	['breakingswipe'] = {
		num = 784,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		name = "Breaking Swipe",
		id = 'breakingswipe',
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				atk = -1,
			},
		},
		target = "allAdjacentFoes",
		type = "Dragon",
	},
	['psychicterrain'] = {
		num = 678,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "psychicterrain",
		name = "Psychic Terrain",
		pp = 10,
		flags = {nonsky = true},
		terrain = 'psychicterrain',
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
				self:add('-activate', target, 'move = Psychic Terrain')
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
					self:add('-fieldstart', 'move = Psychic Terrain')
				end
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 2,
			onEnd = function()
				self:add('-fieldend', 'move = Psychic Terrain')
			end,
		},
		target = "all",
		type = "Psychic",
	},
	['purify'] = {
		num = 685,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "purify",
		name = "Purify",
		pp = 20,
		flags = {protect = true, reflectable = true, heal = true},
		onHit = function(target, source)
			if Not(target.status) then return false end
			target:cureStatus()
			self:heal(math.ceil(source.maxhp * 0.5), source)
		end,
		target = "normal",
		type = "Poison",
	},
	['revelationdance'] = {
		num = 686,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "revelationdance",
		name = "Revelation Dance",
		pp = 15,
		flags = {protect = true, mirror = true},
		onModifyMove = function(move, pokemon)
			move.type = pokemon.types[1] -- TODO = test with users other than Oricorio
		end,
		target = "normal",
		type = "Normal",

	},
	['shadowbone'] = {
		num = 708,
		accuracy = 100,
		basePower = 85,
		category = "Physical",
		id = "shadowbone",
		name = "Shadow Bone",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 20,
			boosts = {
				def = -1,
			},
		},
		target = "normal",
		type = "Ghost",

	},
	['shelltrap'] = {
		num = 704,
		accuracy = 100,
		basePower = 150,
		category = "Special",
		id = "shelltrap",
		name = "Shell Trap",
		pp = 5,
		priority = -3,
		flags = {protect = true},
		beforeTurnCallback = function(pokemon)
			pokemon:addVolatile('shelltrap')
		end,
		beforeMoveCallback = function(pokemon)
			if pokemon.volatiles['shelltrap'] and not pokemon.volatiles['shelltrap'].gotHit then
				self:add('cant', pokemon, 'Shell Trap', 'Shell Trap')
				return true
			end
		end,
		effect = {
			duration = 1,
			onStart = function(pokemon)
				self:add('-singleturn', pokemon, 'move = Shell Trap')
			end,
			onHit = function(pokemon, source, move)
				if move.category == 'Physical' then
					pokemon.volatiles['shelltrap'].gotHit = true
				end
			end,
		},
		target = "allAdjacentFoes",
		type = "Fire",

	},
	['shoreup'] = {
		num = 659,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "shoreup",
		name = "Shore Up",
		pp = 10,
		flags = {snatch = true, heal = true},
		onHit = function(pokemon)
			if self:isWeather('sandstorm') then
				self:heal(self:modify(pokemon.maxhp, 0.667))
			else
				self:heal(self:modify(pokemon.maxhp, 0.5))
			end
		end,
		target = "self",
		type = "Ground",
	},
	['smartstrike'] = {
		num = 684,
		accuracy = true,
		basePower = 70,
		category = "Physical",
		id = "smartstrike",
		name = "Smart Strike",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		target = "normal",
		type = "Steel",

	},
	meteorbeam = {
		num = 800,
		accuracy = 90,
		basePower = 120,
		category = "Special",
		name = "Meteor Beam",
		id = 'meteorbeam',
		pp = 10,
		flags = {charge = true, protect = true, mirror = true},
		onTryMove = function(attacker, defender, move)
			if (attacker:removeVolatile(move.id)) then
				return
			end
			self:add('-prepare', attacker, move.name)
			self:boost({spa = 1}, attacker, attacker, move)
			if not (self:runEvent('ChargeMove', attacker, defender, move)) then
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return 
		end,
		target = "normal",
		type = "Rock",
	},
	['solarblade'] = {
		num = 669,
		accuracy = 100,
		basePower = 125,
		category = "Physical",
		id = "solarblade",
		name = "Solar Blade",
		pp = 10,
		flags = {contact = true, charge = true, protect = true, mirror = true,blademaster = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if self:isWeather{'sunnyday', 'desolateland'} or Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon, target)
			if self:isWeather{'raindance', 'primordialsea', 'sandstorm', 'hail'} then
				self:debug('weakened by weather')
				return self:chainModify(0.5)
			end
		end,
		target = "normal",
		type = "Grass",

	},
	['sparklingaria'] = {
		num = 664,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "sparklingaria",
		name = "Sparkling Aria",
		pp = 10,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		onHit = function(target)
			if target.status == 'brn' then target:cureStatus() end
		end,
		target = "allAdjacent",
		type = "Water",

	},
	['spectralthief'] = {
		num = 712,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "spectralthief",
		name = "Spectral Thief",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, authentic = true},
		stealBoosts = true,
		-- Boost stealing implemented in scripts.js
		target = "normal",
		type = "Ghost",

	},
	['speedswap'] = {
		num = 683,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "speedswap",
		name = "Speed Swap",
		pp = 10,
		flags = {protect = true, mirror = true, authentic = true, mystery = true},
		onHit = function(target, source)
			target.stats.spe, source.stats.spe = source.stats.spe, target.stats.spe
			self:add('-activate', source, 'move = Speed Swap', '[of] ' .. target)
		end,
		target = "normal",
		type = "Psychic",
	},
	['spiritshackle'] = {
		num = 662,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "spiritshackle",
		name = "Spirit Shackle",
		pp = 10,
		flags = {protect = true, mirror = true},
		onHit = function(target, source, move)
			if source.isActive then target:addVolatile('trapped', source, move, 'trapper') end
		end,
		target = "normal",
		type = "Ghost",

	},
	['spotlight'] = {
		num = 671,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "spotlight",
		name = "Spotlight",
		pp = 15,
		priority = 3,
		flags = {protect = true, reflectable = true, mystery = true},
		volatileStatus = 'spotlight',
		onTryHit = function(target)
			if #target.side.active < 2 then return false end
		end,
		effect = {
			duration = 1,
			onStart = function(pokemon)
				self:add('-singleturn', pokemon, 'move = Spotlight')
			end,
			onFoeRedirectTargetPriority = 2,
			onFoeRedirectTarget = function(target, source, source2, move)
				if self:validTarget(self.effectData.target, source, move.target) then
					self:debug("Spotlight redirected target of move")
					return self.effectData.target
				end
			end,
		},
		target = "normal",
		type = "Normal",
	},
	['expandingforce'] = {
		num = 797,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		name = "Expanding Force",
		id = 'expandingforce',
		pp = 10,
		flags = {protect = true, mirror = true},
		onBasePower = function(basePower, source)
			if (self:isTerrain('psychicterrain') and source:isGrounded()) then
				return self:chainModify(1.5)
			end
		end,
		onModifyMove = function(move, source, target)
			if (self:isTerrain('psychicterrain') and source:isGrounded()) then
				move.target = 'allAdjacentFoes'
			end
		end,
		target = "normal",
		type = "Psychic",
	},
	steelroller = {
		num = 798,
		accuracy = 100,
		basePower = 130,
		category = "Physical",
		name = "Steel Roller",
		id = 'steelroller',
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		onTry = function()
			return not self:isTerrain('')
		end,
		onHit = function()
			self:clearTerrain()
		end,
		target = "normal",
		type = "Steel",
	},
	['strangesteam'] = {
		num = 790,
		accuracy = 95,
		basePower = 90,
		category = "Special",
		name = "Strange Steam",
		id = 'strangesteam',
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 20,
			volatileStatus = 'confusion',
		},
		target = "normal",
		type = "Fairy",
	},
	['eeriespell'] = {
		num = 848,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "eeriespell",
		name = "Eerie Spell",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		onHit = function(target)
			if target:deductPP(target.lastMove, 3) then
				self:add('-activate', target, 'Eerie Spell', self:getMove(target.lastMove).name, 3)
				return
			end
			return false
		end,
		target = "normal",
		type = "Psychic"
	},
	['mindblown'] = {
		num = 849,
		accuracy = 100,
		basePower = 150,
		category = "Special",
		id = "mindblown",
		name = "Mind Blown",
		pp = 5,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		mindBlownRecoil = true,
		onAfterMove = function(pokemon, target, move)
			if (move.mindBlownRecoil and not move.multihit) then
				self:damage(math.round(pokemon.maxhp / 2), pokemon, pokemon, self:getEffect('Mind Blown'), true)
			end
		end,	
		target = "normal",
		type = "Fire"
	},
	eternabeam = {
		num = 795,
		accuracy = 90,
		basePower = 160,
		category = "Special",
		name = "Eternabeam",
		id = 'eternabeam',
		pp = 5,
		flags = {recharge = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'mustrecharge',
		},
		target = "normal",
		type = "Dragon",
	},
	['dynamaxcannon'] = {
		num = 744,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		name = "Dynamax Cannon",
		id = 'dynamaxcannon',
		pp = 5,
		flags = {protect = true},
		target = "normal",
		type = "Dragon",
	},
	['astralbarrage'] = {
		num = 825,
		accuracy = 100,
		basePower = 120,
		category = "Special",
		id = "astralbarrage",
		name = "Astral Barrage",
		pp = 5,
		flags = {protect = true, mirror = true, nonsky = true},
		target = "allAdjacentFoes",
		type = "Ghost"
	},
	['glaciallance'] = {
		num = 824,
		accuracy = 100,
		basePower = 130,
		category = "Physical",
		id = "glaciallance",
		name = "Glacial Lance",
		pp = 5,
		flags = {protect = true, reflectable = true, mirror = true},
		target = "normal",
		type = "Ice"
	},
	['dragonenergy'] = {
		num = 820,
		accuracy = 100,
		basePower = 150,
		basePowerCallback = function(pokemon, target, move)
			return move.basePower * pokemon.hp / pokemon.maxhp
		end,
		category = "Special",
		id = "dragonenergy",
		name = "Dragon Energy",
		pp = 5,
		flags = {protect = true, reflectable = true, mirror = true},
		target = "normal",
		type = "Dragon"
	},
	['fierywrath'] = {
		num = 822,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "fierywrath",
		name = "Fiery Wrath",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		secondary = {
			chance = 20,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Dark"
	},
	['freezingglare'] = {
		num = 821,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "freezingglare",
		name = "Freezing Glare",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'frz'
		},
		target = "normal",
		type = "Psychic"
	},
	['surgingstrikes'] = {
		num = 818,
		accuracy = 100,
		basePower = 25,
		category = "Physical",
		id = "surgingstrikes",
		name = "Surging Strikes",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		willCrit = true,
		multihit = 3,
		target = "normal",
		type = "Water"
	},
	['wickedblow'] = {
		num = 817,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "wickedblow",
		name = "Wicked Blow",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		willCrit = true,
		target = "normal",
		type = "Dark"
	},
	['thunderouskick'] = {
		num = 823,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "thunderouskick",
		name = "Thunderous Kick",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				def = -1,
			},
		},
		target = "normal",
		type = "Fighting",
	},
	['thundercage'] = {
		num = 819,
		accuracy = 90,
		basePower = 80,
		category = "Special",
		id = "thundercage",
		name = "Thunder Cage",
		pp = 10,
		flags = {protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Electric"
	},	
	['stompingtantrum'] = {
		num = 707,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		id = "stompingtantrum",
		name = "Stomping Tantrum",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		target = "normal",
		type = "Ground",
	},
	['strengthsap'] = {
		num = 668,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "strengthsap",
		name = "Strength Sap",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true, heal = true},
		onHit = function(target, source)
			if target.boosts.atk == -6 then return false end
			self:heal(target:getStat('atk', false, true), source)
			self:boost({atk = -1}, target, source, null, null, true)
		end,
		target = "normal",
		type = "Grass",
	},
	['clangoroussoul'] = {
		num = 755,
		accuracy = 100,
		category = 'Status',
		name = 'Clangorous Soul',
		id = 'clangoroussoul',
		pp = 5,
		flags = {snatch = true, sound = true, dance = true},
		onTry = function(source)
			if (source.hp <= (source.maxhp * 33 / 100) or source.maxhp == 1) then return false end
		end,
		onTryHit = function(pokemon, target, move)
			if not (self:boost(move.boosts)) then return end --check
		end,
		onHit = function(pokemon)
			self:directDamage(pokemon.maxhp * 33 / 100)
		end,
		boosts = {atk=1,def=1,spa=1,spd=1,spe=1},
		target = 'self',
		type = 'Dragon',
	},
	['sunsteelstrike'] = {
		num = 713,
		accuracy = 100,
		basePower = 100,
		category = "Physical",
		id = "sunsteelstrike",
		name = "Sunsteel Strike",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		ignoreAbility = true,
		target = "normal",
		type = "Steel",
	},
	['tearfullook'] = {
		num = 715,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "tearfullook",
		name = "Tearful Look",
		pp = 20,
		flags = {reflectable = true, mirror = true},
		boosts = {
			atk = -1,
			spa = -1,
		},
		target = "normal",
		type = "Normal",
	},
	['throatchop'] = {
		num = 675,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "throatchop",
		name = "Throat Chop",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		volatileStatus = 'throatchop',
		effect = {
			duration = 2,
			onStart = function(target)
				self:add('-start', target, 'Throat Chop', '[silent]')
			end,
			onBeforeMovePriority = 6,
			onBeforeMove = function(pokemon, target, move)
				if move.flags['sound'] then
					self:add('cant', pokemon, 'move = Throat Chop')
					return false
				end
			end,
			onResidualOrder = 22,
			onEnd = function(target)
				self:add('-end', target, 'Throat Chop', '[silent]')
			end
		},
		target = "normal",
		type = "Dark",
	},
	['toxicthread'] = {
		num = 672,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "toxicthread",
		name = "Toxic Thread",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		status = 'psn',
		boosts = {
			spe = -1,
		},
		target = "normal",
		type = "Poison",
	},
	['tropkick'] = {
		num = 688,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "tropkick",
		name = "Trop Kick",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		secondary = {
			chance = 100,
			boosts = {
				atk = -1,
			},
		},
		target = "normal",
		type = "Grass",
	},
	['zingzap'] = {
		num = 716,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "zingzap",
		name = "Zing Zap",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch',
		},
		target = "normal",
		type = "Electric",
	},

	['absorb'] = {
		num = 71,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "absorb",
		name = "Absorb",
		pp = 15,
		flags = {protect = true, mirror = true, heal = true},
		drain = {1, 2},
		target = "normal",
		type = "Grass"
	},
	['acid'] = {
		num = 51,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "acid",
		name = "Acid",
		pp = 30,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				spd = -1
			}
		},
		target = "allAdjacentFoes",
		type = "Poison"
	},
	['acidarmor'] = {
		num = 151,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "acidarmor",
		name = "Acid Armor",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			def = 2
		},
		target = "self",
		type = "Poison"
	},
	['acidspray'] = {
		num = 491,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "acidspray",
		name = "Acid Spray",
		pp = 20,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spd = -2
			}
		},
		target = "normal",
		type = "Poison"
	},
	['acrobatics'] = {
		num = 512,
		accuracy = 100,
		basePower = 55,
		basePowerCallback = function(pokemon)
			if not pokemon.item or pokemon.item == '' then
				self:debug("Power doubled for no item")
				return 110
			end
			return 55
		end,
		category = "Physical",
		id = "acrobatics",
		name = "Acrobatics",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, distance = true},
		target = "any",
		type = "Flying"
	},
	['acupressure'] = {
		num = 367,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "acupressure",
		name = "Acupressure",
		pp = 30,
		onHit = function(target)
			local stats = {}
			for stat, boost in pairs(target.boosts) do
				if boost < 6 then
					table.insert(stats, stat)
				end
			end
			if #stats > 0 then
				local stat = stats[math.random(#stats)]
				local boost = {}
				boost[stat] = 2
				self:boost(boost)
			else
				return false
			end
		end,
		target = "adjacentAllyOrSelf",
		type = "Normal"
	},
	['aerialace'] = {
		num = 332,
		accuracy = true,
		basePower = 60,
		category = "Physical",
		id = "aerialace",
		name = "Aerial Ace",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, distance = true},
		target = "any",
		type = "Flying"
	},
	['aeroblast'] = {
		num = 177,
		accuracy = 95,
		basePower = 100,
		category = "Special",
		id = "aeroblast",
		name = "Aeroblast",
		pp = 5,
		flags = {protect = true, mirror = true, distance = true},
		critRatio = 2,
		target = "any",
		type = "Flying"
	},
	['afteryou'] = {
		num = 495,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "afteryou",
		name = "After You",
		pp = 15,
		flags = {authentic = true},
		onHit = function(target)
			if #target.side.active < 2 then return false end -- fails in singles
			local decision = self:willMove(target)
			if decision then
				self:cancelMove(target)
				table.insert(self.queue, 1, decision)
				self:add('-activate', target, 'move = After You')
			else
				return false
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['agility'] = {
		num = 97,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "agility",
		name = "Agility",
		pp = 30,
		flags = {snatch = true},
		boosts = {
			spe = 2
		},
		target = "self",
		type = "Psychic"
	},
	['aircutter'] = {
		num = 314,
		accuracy = 95,
		basePower = 60,
		category = "Special",
		id = "aircutter",
		name = "Air Cutter",
		pp = 25,
		flags = {protect = true, mirror = true},
		critRatio = 2,
		target = "allAdjacentFoes",
		type = "Flying"
	},
	['airslash'] = {
		num = 403,
		accuracy = 95,
		basePower = 75,
		category = "Special",
		id = "airslash",
		name = "Air Slash",
		pp = 15,
		flags = {protect = true, mirror = true, distance = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "any",
		type = "Flying"
	},
	['allyswitch'] = {
		num = 502,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "allyswitch",
		name = "Ally Switch",
		pp = 15,
		priority = 2,
		onTryHit = function(source)
			if #source.side.active == 1 then return false end
			if #source.side.active == 3 and source.position == 2 then return false end
			if source.side.isTwoPlayerSide then return false end
		end,
		onHit = function(pokemon)
			local newPosition = pokemon.position==1 and #pokemon.side.active or 1
			if pokemon.side.active[newPosition] == null then return false end
			if pokemon.side.active[newPosition].fainted then return false end
			self:swapPosition(pokemon, newPosition, '[from] move = Ally Switch')
		end,
		target = "self",
		type = "Psychic"
	},
	['amnesia'] = {
		num = 133,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "amnesia",
		name = "Amnesia",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			spd = 2
		},
		target = "self",
		type = "Psychic"
	},
	['ancientpower'] = {
		num = 246,
		accuracy = 100,
		basePower = 60,
		category = "Special",
		id = "ancientpower",
		name = "Ancient Power",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			self = {
				boosts = {
					atk = 1,
					def = 1,
					spa = 1,
					spd = 1,
					spe = 1
				}
			}
		},
		target = "normal",
		type = "Rock"
	},
	['aquajet'] = {
		num = 453,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "aquajet",
		name = "Aqua Jet",
		pp = 20,
		priority = 1,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Water"
	},
	['aquaring'] = {
		num = 392,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "aquaring",
		name = "Aqua Ring",
		pp = 20,
		flags = {snatch = true},
		volatileStatus = 'aquaring',
		effect = {
			onStart = function(pokemon)
				self:add('-start', pokemon, 'Aqua Ring')
			end,
			onResidualOrder = 6,
			onResidual = function(pokemon)
				self:heal(pokemon.maxhp / 16)
			end
		},
		target = "self",
		type = "Water"
	},
	['aquatail'] = {
		num = 401,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "aquatail",
		name = "Aqua Tail",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Water"
	},
	['armthrust'] = {
		num = 292,
		accuracy = 100,
		basePower = 15,
		category = "Physical",
		id = "armthrust",
		name = "Arm Thrust",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Fighting"
	},
	['aromatherapy'] = {
		num = 312,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "aromatherapy",
		name = "Aromatherapy",
		pp = 5,
		flags = {snatch = true, distance = true},
		onHit = function(pokemon, source, move)
			for _, ally in pairs(pokemon.side.pokemon) do
				if ally ~= source and (ally:hasAbility('sapsipper') or (ally.volatiles['substitute'] and not move.infiltrates)) then
				else
					ally.status = ''
				end
			end
			self:add('-cureteam', source, '[from] move = Aromatherapy');
		end,
		target = "allyTeam",
		type = "Grass"
	},
	['aromaticmist'] = {
		num = 597,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "aromaticmist",
		name = "Aromatic Mist",
		pp = 20,
		flags = {authentic = true},
		boosts = {
			spd = 1
		},
		target = "adjacentAlly",
		type = "Fairy"
	},
	['assist'] = {
		num = 274,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "assist",
		name = "Assist",
		pp = 20,
		onHit = function(target)
			local moves = {}
			local invalid = {assist=true, belch=true, bestow=true, bounce=true, chatter=true, circlethrow=true, copycat=true, counter=true, covet=true, destinybond=true, detect=true, dig=true, dive=true, dragontail=true, endure=true, feint=true, fly=true, focuspunch=true, followme=true, helpinghand=true, kingsshield=true, matblock=true, mefirst=true, metronome=true, mimic=true, mirrorcoat=true, mirrormove=true, naturepower=true, phantomforce=true, protect=true, ragepowder=true, roar=true, shadowforce=true, sketch=true, skydrop=true, sleeptalk=true, snatch=true, spikyshield=true, struggle=true, switcheroo=true, thief=true, transform=true, trick=true, whirlwind=true}
			for _, pokemon in pairs(target.side.pokemon) do
				if pokemon ~= target then
					for _, move in pairs(pokemon.moveset) do
						local moveName = move.move
						if not invalid[moveName] then
							table.insert(moves, moveName)
						end
					end
				end
			end
			local move
			if #moves > 0 then
				move = moves[math.random(#moves)]
			end
			if not move then
				return false
			end
			--			print(type(move), move)
			self:useMove(move, target)
		end,
		target = "self",
		type = "Normal"
	},
	['assurance'] = {
		num = 372,
		accuracy = 100,
		basePower = 60,
		basePowerCallback = function(pokemon, target)
			if pokemon.volatiles.assurance and pokemon.volatiles.assurance.hurt then
				self:debug('Boosted for being damaged this turn')
				return 120
			end
			return 60
		end,
		category = "Physical",
		id = "assurance",
		name = "Assurance",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		beforeTurnCallback = function(pokemon, target)
			pokemon:addVolatile('assurance')
			pokemon.volatiles.assurance.position = target.position
		end,
		effect = {
			duration = 1,
			onFoeAfterDamage = function(damage, target)
				if target.position == self.effectData.position then
					self:debug('damaged this turn')
					self.effectData.hurt = true
				end
			end,
			onFoeSwitchOut = function(pokemon)
				if pokemon.position == self.effectData.position then
					self.effectData.hurt = false
				end
			end
		},
		target = "normal",
		type = "Dark"
	},
	['astonish'] = {
		num = 310,
		accuracy = 100,
		basePower = 30,
		category = "Physical",
		id = "astonish",
		name = "Astonish",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Ghost"
	},
	['attackorder'] = {
		num = 454,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "attackorder",
		name = "Attack Order",
		pp = 15,
		flags = {protect = true, mirror = true},
		critRatio = 2,
		target = "normal",
		type = "Bug"
	},
	['attract'] = {
		num = 213,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "attract",
		name = "Attract",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		volatileStatus = 'attract',
		effect = {
			noCopy = true, -- doesn't get copied by Baton Pass
			onStart = function(pokemon, source, effect)
				if not (pokemon.gender == 'M' and source.gender == 'F') and not (pokemon.gender == 'F' and source.gender == 'M') then
					self:debug('incompatible gender')
					return false
				end
				if Not(self:runEvent('Attract', pokemon, source)) then
					self:debug('Attract event failed')
					return false
				end

				if effect.id == 'cutecharm' then
					self:add('-start', pokemon, 'Attract', '[from] ability = Cute Charm', '[of] ' .. source)
				elseif effect.id == 'destinyknot' then
					self:add('-start', pokemon, 'Attract', '[from] item = Destiny Knot', '[of] ' .. source)
				else
					self:add('-start', pokemon, 'Attract')
				end
			end,
			onUpdate = function(pokemon)
				if self.effectData.source and not self.effectData.source.isActive and pokemon.volatiles['attract'] then
					self:debug('Removing Attract volatile on ' .. pokemon)
					pokemon:removeVolatile('attract')
				end
			end,
			onBeforeMovePriority = 2,
			onBeforeMove = function(pokemon, target, move)
				self:add('-activate', pokemon, 'Attract', '[of] ' .. self.effectData.source)
				if math.random(2) == 1 then
					self:add('cant', pokemon, 'Attract')
					return false
				end
			end,
			onEnd = function(pokemon)
				self:add('-end', pokemon, 'Attract', '[silent]')
			end
		},
		target = "normal",
		type = "Normal"
	},
	['aurasphere'] = {
		num = 396,
		accuracy = true,
		basePower = 80,
		category = "Special",
		id = "aurasphere",
		name = "Aura Sphere",
		pp = 20,
		flags = {bullet = true, protect = true, pulse = true, mirror = true, distance = true},
		target = "any",
		type = "Fighting"
	},
	['aurorabeam'] = {
		num = 62,
		accuracy = 100,
		basePower = 65,
		category = "Special",
		id = "aurorabeam",
		name = "Aurora Beam",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				atk = -1
			}
		},
		target = "normal",
		type = "Ice"
	},
	['autotomize'] = {
		num = 475,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "autotomize",
		name = "Autotomize",
		pp = 15,
		flags = {snatch = true},
		onTryHit = function(pokemon)
			local hasContrary = pokemon:hasAbility('contrary')
			if (not hasContrary and pokemon.boosts.spe == 6) or (hasContrary and pokemon.boosts.spe == -6) then
				return false
			end
		end,
		boosts = {
			spe = 2
		},
		volatileStatus = 'autotomize',
		effect = {
			noCopy = true, -- doesn't get copied by Baton Pass
			onStart = function(pokemon)
				if pokemon.weightkg > 0.1 then
					self.effectData.multiplier = 1
					self:add('-start', pokemon, 'Autotomize')
				end
			end,
			onRestart = function(pokemon)
				if pokemon.template.weightkg - (self.effectData.multiplier * 100) > 0.1 then
					self.effectData.multiplier = self.effectData.multiplier + 1
					self:add('-start', pokemon, 'Autotomize')
				end
			end,
			onModifyWeightPriority = 1,
			onModifyWeight = function(weight, pokemon)
				if self.effectData.multiplier then
					weight = weight - self.effectData.multiplier*100
					return math.max(0.1, weight)
				end
			end
		},
		target = "self",
		type = "Steel"
	},
	['avalanche'] = {
		num = 419,
		accuracy = 100,
		basePower = 60,
		basePowerCallback = function(pokemon, target)
			if target.lastDamage > 0 and pokemon.lastAttackedBy and pokemon.lastAttackedBy.thisTurn and pokemon.lastAttackedBy.pokemon == target then
				self:debug('Boosted for getting hit by ' .. pokemon.lastAttackedBy.move)
				return 120
			end
			return 60
		end,
		category = "Physical",
		id = "avalanche",
		name = "Avalanche",
		pp = 10,
		priority = -4,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Ice"
	},
	['babydolleyes'] = {
		num = 608,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "babydolleyes",
		name = "Baby-Doll Eyes",
		pp = 30,
		priority = 1,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			atk = -1
		},
		target = "normal",
		type = "Fairy"
	},
	['barrage'] = {
		num = 140,
		accuracy = 85,
		basePower = 15,
		category = "Physical",
		id = "barrage",
		name = "Barrage",
		pp = 20,
		flags = {bullet = true, protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Normal"
	},
	['barrier'] = {
		num = 112,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "barrier",
		name = "Barrier",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			def = 2
		},
		target = "self",
		type = "Psychic"
	},
	['batonpass'] = {
		num = 226,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "batonpass",
		name = "Baton Pass",
		pp = 40,
		selfSwitch = 'copyvolatile',
		target = "self",
		type = "Normal"
	},
	['beatup'] = {
		num = 251,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			pokemon:addVolatile('beatup')
			if Not(pokemon.side.pokemon[pokemon.volatiles.beatup.index]) then return null end
			return 5 + math.floor(pokemon.side.pokemon[pokemon.volatiles.beatup.index].template.baseStats[2] / 10)
		end,
		category = "Physical",
		id = "beatup",
		name = "Beat Up",
		pp = 10,
		flags = {protect = true, mirror = true},
		multihit = 6,
		effect = {
			duration = 1,
			onStart = function(pokemon)
				self.effectData.index = 1
				while pokemon.side.pokemon[self.effectData.index] ~= pokemon and
					(Not(pokemon.side.pokemon[self.effectData.index]) or
						pokemon.side.pokemon[self.effectData.index].fainted or
						pokemon.side.pokemon[self.effectData.index].status ~= '') do
					self.effectData.index = self.effectData.index + 1
				end
			end,
			onRestart = function(pokemon)
				repeat
					self.effectData.index = self.effectData.index + 1
					if self.effectData.index > 6 then break end
				until not (Not(pokemon.side.pokemon[self.effectData.index]) or
					pokemon.side.pokemon[self.effectData.index].fainted or
					pokemon.side.pokemon[self.effectData.index].status ~= '')
			end
		},
		onAfterMove = function(pokemon)
			pokemon:removeVolatile('beatup')
		end,
		target = "normal",
		type = "Dark"
	},
	['belch'] = {
		num = 562,
		accuracy = 90,
		basePower = 120,
		category = "Special",
		id = "belch",
		name = "Belch",
		pp = 10,
		flags = {protect = true},
		-- Move disabling implemented in Battle:nextTurn()
		target = "normal",
		type = "Poison"
	},
	['bellydrum'] = {
		num = 187,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "bellydrum",
		name = "Belly Drum",
		pp = 10,
		flags = {snatch = true},
		onHit = function(target)
			if target.hp <= target.maxhp/2 or target.boosts.atk >= 6 or target.maxhp == 1 then -- Shedinja clause
				return false
			end
			self:directDamage(target.maxhp / 2)
			self:boost({atk = 12}, target)
		end,
		target = "self",
		type = "Normal"
	},
	['bestow'] = {
		num = 516,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "bestow",
		name = "Bestow",
		pp = 15,
		flags = {mirror = true, authentic = true},
		onHit = function(target, source)
			if target.item and target.item ~= '' then return false end
			local yourItem = source:takeItem()
			if not yourItem or (yourItem.onTakeItem and yourItem.onTakeItem(yourItem, target) == false) then return false end
			if not target:setItem(yourItem) then
				source.item = yourItem
				return false
			end
			self:add('-item', target, yourItem.name, '[from] move = Bestow', '[of] ' .. source)
		end,
		target = "normal",
		type = "Normal"
	},
	['bide'] = {
		num = 117,
		accuracy = true,
		basePower = 0,
		category = "Physical",
		id = "bide",
		name = "Bide",
		pp = 10,
		priority = 1,
		flags = {contact = true, protect = true},
		volatileStatus = 'bide',
		ignoreImmunity = true,
		effect = {
			duration = 3,
			onLockMove = 'bide',
			onStart = function(pokemon)
				self.effectData.totalDamage = 0;
				self:add('-start', pokemon, 'Bide')
			end,
			onDamagePriority = -101,
			onDamage = function(damage, target, source, move)
				if not move or move.effectType ~= 'Move' then return end
				if not source or source.side == target.side then return end
				self.effectData.totalDamage = self.effectData.totalDamage + damage
				self.effectData.sourcePosition = source.position
				self.effectData.sourceSide = source.side
			end,
			onAfterSetStatus = function(status, pokemon)
				if status.id == 'slp' then
					pokemon:removeVolatile('bide')
				end
			end,
			onBeforeMove = function(pokemon)
				if self.effectData.duration == 1 then
					self:add('-end', pokemon, 'Bide')
					if self.effectData.totalDamage == 0 then
						self:add('-fail', pokemon)
						return false
					end
					local target = self.effectData.sourceSide.active[self.effectData.sourcePosition]
					if Not(target) then
						self:add('-fail', pokemon)
						return false
					end
					if Not(target:runImmunity('Normal')) then
						self:add('-immune', target, '[msg]')
						return false
					end
					--					self:moveHit(target, pokemon, 'bide', {damage = self.effectData.totalDamage * 2})
					self:damage(self.effectData.totalDamage * 2, target, pokemon, 'bide')
					return false
				end
				self:add('-activate', pokemon, 'Bide')
				return false
			end
		},
		target = "self",
		type = "Normal"
	},
	['bind'] = {
		num = 20,
		accuracy = 85,
		basePower = 15,
		category = "Physical",
		id = "bind",
		name = "Bind",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Normal"
	},
	['bite'] = {
		num = 44,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "bite",
		name = "Bite",
		pp = 25,
		flags = {bite = true, contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Dark"
	},
	['blastburn'] = {
		num = 307,
		accuracy = 90,
		basePower = 150,
		category = "Special",
		id = "blastburn",
		name = "Blast Burn",
		pp = 5,
		flags = {recharge = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'mustrecharge'
		},
		target = "normal",
		type = "Fire"
	},
	['blazekick'] = {
		num = 299,
		accuracy = 90,
		basePower = 85,
		category = "Physical",
		id = "blazekick",
		name = "Blaze Kick",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		critRatio = 2,
		secondary = {
			chance = 10,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['block'] = {
		num = 335,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "block",
		name = "Block",
		pp = 5,
		flags = {reflectable = true, mirror = true},
		onHit = function(target, source, move)
			if Not(target:addVolatile('trapped', source, move, 'trapper')) then
				self:add('-fail', target)
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['blueflare'] = {
		num = 551,
		accuracy = 85,
		basePower = 130,
		category = "Special",
		id = "blueflare",
		name = "Blue Flare",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 20,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['bodyslam'] = {
		num = 34,
		accuracy = 100,
		basePower = 85,
		category = "Physical",
		id = "bodyslam",
		name = "Body Slam",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, nonsky = true},
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "normal",
		type = "Normal"
	},
	['boltstrike'] = {
		num = 550,
		accuracy = 85,
		basePower = 130,
		category = "Physical",
		id = "boltstrike",
		name = "Bolt Strike",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 20,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},
	['boneclub'] = {
		num = 125,
		accuracy = 85,
		basePower = 65,
		category = "Physical",
		id = "boneclub",
		name = "Bone Club",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Ground"
	},
	['bonerush'] = {
		num = 198,
		accuracy = 90,
		basePower = 25,
		category = "Physical",
		id = "bonerush",
		name = "Bone Rush",
		pp = 10,
		flags = {protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Ground"
	},
	['bonemerang'] = {
		num = 155,
		accuracy = 90,
		basePower = 50,
		category = "Physical",
		id = "bonemerang",
		name = "Bonemerang",
		pp = 10,
		flags = {protect = true, mirror = true},
		multihit = 2,
		target = "normal",
		type = "Ground"
	},
	['boomburst'] = {
		num = 586,
		accuracy = 100,
		basePower = 140,
		category = "Special",
		id = "boomburst",
		name = "Boomburst",
		pp = 10,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		target = "allAdjacent",
		type = "Normal"
	},
	['bounce'] = {
		num = 340,
		accuracy = 85,
		basePower = 85,
		category = "Physical",
		id = "bounce",
		name = "Bounce",
		pp = 5,
		flags = {contact = true, charge = true, protect = true, mirror = true, gravity = true, distance = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then
				return
			end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		effect = {
			duration = 2,
			onAccuracy = function(accuracy, target, source, move)
				if move.id == 'gust' or move.id == 'twister' then return end
				if move.id == 'skyuppercut' or move.id == 'thunder' or move.id == 'hurricane' or move.id == 'smackdown' or move.id == 'thousandarrows' or move.id == 'helpinghand' then return end
				if source:hasAbility('noguard') or target:hasAbility('noguard') then return end
				if source.volatiles['lockon'] and target == source.volatiles['lockon'].source then return end
				return 0
			end,
			onSourceBasePower = function(basePower, target, source, move)
				if move.id == 'gust' or move.id == 'twister' then
					return self:chainModify(2)
				end
			end
		},
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "any",
		type = "Flying"
	},
	['bravebird'] = {
		num = 413,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "bravebird",
		name = "Brave Bird",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, distance = true},
		recoil = {33, 100},
		target = "any",
		type = "Flying"
	},
	['brickbreak'] = {
		num = 280,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		id = "brickbreak",
		name = "Brick Break",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		onTryHit = function(pokemon)
			-- will shatter screens through sub, before you hit
			if not Not(pokemon:runImmunity('Fighting')) then
				pokemon.side:removeSideCondition('reflect')
				pokemon.side:removeSideCondition('lightscreen')
			end
		end,
		target = "normal",
		type = "Fighting"
	},
	['brine'] = {
		num = 362,
		accuracy = 100,
		basePower = 65,
		category = "Special",
		id = "brine",
		name = "Brine",
		pp = 10,
		flags = {protect = true, mirror = true},
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon, target)
			if target.hp*2 < target.maxhp then
				return self:chainModify(2)
			end
		end,
		target = "normal",
		type = "Water"
	},
	['bubble'] = {
		num = 145,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "bubble",
		name = "Bubble",
		pp = 30,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				spe = -1
			}
		},
		target = "allAdjacentFoes",
		type = "Water"
	},
	['bubblebeam'] = {
		num = 61,
		accuracy = 100,
		basePower = 65,
		category = "Special",
		id = "bubblebeam",
		name = "Bubble Beam",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				spe = -1
			}
		},
		target = "normal",
		type = "Water"
	},
	['bugbite'] = {
		num = 450,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "bugbite",
		name = "Bug Bite",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		onHit = function(target, source)
			local item = target:getItem()
			if source.hp>0 and item.isBerry and target:takeItem(source) then
				self:add('-enditem', target, item.name, '[from] stealeat', '[move] Bug Bite', '[of] ' .. source)
				self:singleEvent('Eat', item, nil, source, nil, nil)
				source.ateBerry = true
			end
		end,
		target = "normal",
		type = "Bug"
	},
	['bugbuzz'] = {
		num = 405,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "bugbuzz",
		name = "Bug Buzz",
		pp = 10,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		secondary = {
			chance = 10,
			boosts = {
				spd = -1
			}
		},
		target = "normal",
		type = "Bug"
	},
	['bulkup'] = {
		num = 339,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "bulkup",
		name = "Bulk Up",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			atk = 1,
			def = 1
		},
		target = "self",
		type = "Fighting"
	},
	['bulldoze'] = {
		num = 523,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "bulldoze",
		name = "Bulldoze",
		pp = 20,
		flags = {protect = true, mirror = true, nonsky = true},
		secondary = {
			chance = 100,
			boosts = {
				spe = -1
			}
		},
		target = "allAdjacent",
		type = "Ground"
	},
	['bulletpunch'] = {
		num = 418,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "bulletpunch",
		name = "Bullet Punch",
		pp = 30,
		priority = 1,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		target = "normal",
		type = "Steel"
	},
	['bulletseed'] = {
		num = 331,
		accuracy = 100,
		basePower = 25,
		category = "Physical",
		id = "bulletseed",
		name = "Bullet Seed",
		pp = 30,
		flags = {bullet = true, protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Grass"
	},
	['calmmind'] = {
		num = 347,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "calmmind",
		name = "Calm Mind",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			spa = 1,
			spd = 1
		},
		target = "self",
		type = "Psychic"
	},
	['camouflage'] = {
		num = 293,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "camouflage",
		name = "Camouflage",
		pp = 20,
		flags = {snatch = true},
		onHit = function(target)
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
		target = "self",
		type = "Normal"
	},
	['captivate'] = {
		num = 445,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "captivate",
		name = "Captivate",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		onTryHit = function(pokemon, source)
			if (pokemon.gender == 'M' and source.gender == 'F') or (pokemon.gender == 'F' and source.gender == 'M') then return end
			return false
		end,
		boosts = {
			spa = -2
		},
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['celebrate'] = {
		num = 606,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "celebrate",
		name = "Celebrate",
		pp = 40,
		onTryHit = function(target, source)
			self:add('-activate', target, 'move = Celebrate')
			return null
		end,
		target = "self",
		type = "Normal"
	},
	['charge'] = {
		num = 268,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "charge",
		name = "Charge",
		pp = 20,
		flags = {snatch = true},
		volatileStatus = 'charge',
		onHit = function(pokemon)
			self:add('-activate', pokemon, 'move = Charge')
		end,
		effect = {
			duration = 2,
			onRestart = function(pokemon)
				self.effectData.duration = 2
			end,
			onBasePowerPriority = 3,
			onBasePower = function(basePower, attacker, defender, move)
				if move.type == 'Electric' then
					self:debug('charge boost')
					return self:chainModify(2)
				end
			end
		},
		boosts = {
			spd = 1
		},
		target = "self",
		type = "Electric"
	},
	['chargebeam'] = {
		num = 451,
		accuracy = 90,
		basePower = 50,
		category = "Special",
		id = "chargebeam",
		name = "Charge Beam",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 70,
			self = {
				boosts = {
					spa = 1
				}
			}
		},
		target = "normal",
		type = "Electric"
	},
	['charm'] = {
		num = 204,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "charm",
		name = "Charm",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			atk = -2
		},
		target = "normal",
		type = "Fairy"
	},
	['chatter'] = {
		num = 448,
		accuracy = 100,
		basePower = 65,
		category = "Special",
		id = "chatter",
		name = "Chatter",
		pp = 20,
		flags = {protect = true, mirror = true, sound = true, distance = true, authentic = true},
		noSketch = true,
		secondary = {
			chance = 100,
			volatileStatus = 'confusion'
		},
		target = "any",
		type = "Flying"
	},
	['chipaway'] = {
		num = 498,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "chipaway",
		name = "Chip Away",
		pp = 20,
		isContact = true,
		flags = {contact = true, protect = true, mirror = true},
		ignoreDefensive = true,
		ignoreEvasion = true,
		target = "normal",
		type = "Normal"
	},
	['circlethrow'] = {
		num = 509,
		accuracy = 90,
		basePower = 60,
		category = "Physical",
		id = "circlethrow",
		name = "Circle Throw",
		pp = 10,
		priority = -6,
		flags = {contact = true, protect = true, mirror = true},
		forceSwitch = true,
		target = "normal",
		type = "Fighting"
	},
	['clamp'] = {
		num = 128,
		accuracy = 85,
		basePower = 35,
		category = "Physical",
		id = "clamp",
		name = "Clamp",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Water"
	},
	['clearsmog'] = {
		num = 499,
		accuracy = true,
		basePower = 50,
		category = "Special",
		id = "clearsmog",
		name = "Clear Smog",
		pp = 15,
		flags = {protect = true, mirror = true},
		onHit = function(target)
			target:clearBoosts()
			self:add('-clearboost', target)
		end,
		target = "normal",
		type = "Poison"
	},
	['closecombat'] = {
		num = 370,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "closecombat",
		name = "Close Combat",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		self = {
			boosts = {
				def = -1,
				spd = -1
			}
		},
		target = "normal",
		type = "Fighting"
	},
	['coil'] = {
		num = 489,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "coil",
		name = "Coil",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			atk = 1,
			def = 1,
			accuracy = 1
		},
		target = "self",
		type = "Poison"
	},
	['cometpunch'] = {
		num = 4,
		accuracy = 85,
		basePower = 18,
		category = "Physical",
		id = "cometpunch",
		name = "Comet Punch",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		multihit = {2, 5},
		target = "normal",
		type = "Normal"
	},
	['confide'] = {
		num = 590,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "confide",
		name = "Confide",
		pp = 20,
		flags = {reflectable = true, mirror = true, sound = true, authentic = true},
		boosts = {
			spa = -1
		},
		target = "normal",
		type = "Normal"
	},
	['confuseray'] = {
		num = 109,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "confuseray",
		name = "Confuse Ray",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'confusion',
		target = "normal",
		type = "Ghost"
	},
	['confusion'] = {
		num = 93,
		accuracy = 100,
		basePower = 50,
		category = "Special",
		id = "confusion",
		name = "Confusion",
		pp = 25,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			volatileStatus = 'confusion'
		},
		target = "normal",
		type = "Psychic"
	},
	['constrict'] = {
		num = 132,
		accuracy = 100,
		basePower = 10,
		category = "Physical",
		id = "constrict",
		name = "Constrict",
		pp = 35,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				spe = -1
			}
		},
		target = "normal",
		type = "Normal"
	},
	['conversion'] = {
		num = 160,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "conversion",
		name = "Conversion",
		pp = 30,
		flags = {snatch = true},
		onHit = function(target)
			local type = self:getMove(target.moveset[1].id).type
			if target:hasType(type) or Not(target:setType(type)) then return false end
			self:add('-start', target, 'typechange', type)
		end,
		target = "self",
		type = "Normal"
	},
	['conversion2'] = {
		num = 176,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "conversion2",
		name = "Conversion 2",
		pp = 30,
		flags = {authentic = true},
		onHit = function(target, source)
			if not target.lastMove then return false end
			local possibleTypes = {}
			local attackType = self:getMove(target.lastMove).type
			for typeName, type in pairs(self.data.TypeChart) do
				if not source:hasType(type) and not target:hasType(type) then
					local mult = type[attackType]
					if mult and mult < 1 then
						table.insert(possibleTypes, typeName)
					end
				end
			end
			if #possibleTypes == 0 then return false end
			local type = possibleTypes[math.random(#possibleTypes)]

			--			print'setting type'
			if not source:setType(type) then return false end
			--			print'set type'
			self:add('-start', source, 'typechange', type)
		end,
		target = "normal",
		type = "Normal"
	},
	['copycat'] = {
		num = 383,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "copycat",
		name = "Copycat",
		pp = 20,
		onHit = function(pokemon)
			local noCopycat = {assist=true, bestow=true, chatter=true, circlethrow=true, copycat=true, counter=true, covet=true, destinybond=true, detect=true, dragontail=true, endure=true, feint=true, focuspunch=true, followme=true, helpinghand=true, mefirst=true, metronome=true, mimic=true, mirrorcoat=true, mirrormove=true, naturepower=true, protect=true, ragepowder=true, roar=true, sketch=true, sleeptalk=true, snatch=true, struggle=true, switcheroo=true, thief=true, transform=true, trick=true, whirlwind=true}
			if Not(self.lastMove) or noCopycat[self.lastMove] then return false end
			self:useMove(self:getMove(self.lastMove), pokemon)
		end,
		target = "self",
		type = "Normal"
	},
	['cosmicpower'] = {
		num = 322,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "cosmicpower",
		name = "Cosmic Power",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			def = 1,
			spd = 1
		},
		target = "self",
		type = "Psychic"
	},
	['cottonguard'] = {
		num = 538,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "cottonguard",
		name = "Cotton Guard",
		pp = 10,
		flags = {snatch = true},
		boosts = {
			def = 3
		},
		target = "self",
		type = "Grass"
	},
	['cottonspore'] = {
		num = 178,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "cottonspore",
		name = "Cotton Spore",
		pp = 40,
		flags = {powder = true, protect = true, reflectable = true, mirror = true},
		boosts = {
			spe = -2
		},
		onTryHit = function(target)
			if not target:runImmunity('powder') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		target = "allAdjacentFoes",
		type = "Grass"
	},
	['decorate'] = {
		num = 777,
		accuracy = true,
		basePower = 0,
		category = 'Status',
		name = 'Decorate',
		id = 'decorate',
		pp = 15,
		flags = {mystery = true},
		boosts = {atk=2,spa=2},
		target = 'normal',
		type = 'Fairy',
	},
	['counter'] = {
		num = 68,
		accuracy = 100,
		basePower = 0,
		damageCallback = function(pokemon)
			if not pokemon.volatiles['counter'] then return 0 end
			return math.max(pokemon.volatiles['counter'].damage or 1, 1)
		end,
		category = "Physical",
		id = "counter",
		name = "Counter",
		pp = 20,
		priority = -5,
		flags = {contact = true, protect = true},
		beforeTurnCallback = function(pokemon)
			pokemon:addVolatile('counter')
		end,
		onTryHit = function(target, source, move)
			if not source.volatiles['counter'] then return false end
			if Not(source.volatiles['counter'].position) then return false end
		end,
		effect = {
			duration = 1,
			noCopy = true,
			onStart = function(target, source, source2, move)
				self.effectData.position = nil
				self.effectData.damage = 0
			end,
			onRedirectTarget = function(target, source, source2)
				if source ~= self.effectData.target then return end
				return source.side.foe.active[self.effectData.position]
			end,
			onDamagePriority = -101,
			onDamage = function(damage, target, source, effect)
				if effect and effect.effectType == 'Move' and source.side ~= target.side and self:getCategory(effect.id) == 'Physical' then
					self.effectData.position = source.position
					self.effectData.damage = 2 * damage
				end
			end
		},
		target = "scripted",
		type = "Fighting"
	},
	['covet'] = {
		num = 343,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "covet",
		name = "Covet",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		onHit = function(target, source)
			if source.item and source.item ~= '' then return end
			local yourItem = target:takeItem(source)
			if not yourItem then return end
			if not source:setItem(yourItem) then
				target.item = yourItem.id -- bypass setItem so we don't break choicelock or anything
				return
			end
			self:add('-item', source, yourItem, '[from] move = Covet', '[of] ' .. target)
		end,
		target = "normal",
		type = "Normal"
	},
	['crabhammer'] = {
		num = 152,
		accuracy = 90,
		basePower = 100,
		category = "Physical",
		id = "crabhammer",
		name = "Crabhammer",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		critRatio = 2,
		target = "normal",
		type = "Water"
	},
	['craftyshield'] = {
		num = 578,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "craftyshield",
		name = "Crafty Shield",
		pp = 10,
		priority = 3,
		sideCondition = 'craftyshield',
		onTryHitSide = function(side, source)
			return not Not(self:willAct())
		end,
		effect = {
			duration = 1,
			onStart = function(target, source)
				self:add('-singleturn', source, 'Crafty Shield')
			end,
			onTryHitPriority = 3,
			onTryHit = function(target, source, move)
				if move and (move.target == 'self' or move.category ~= 'Status') then return end
				self:add('-activate', target, 'Crafty Shield')
				return null
			end
		},
		target = "allySide",
		type = "Fairy"
	},
	skittersmack = {
		num = 806,
		accuracy = 90,
		basePower = 70,
		category = "Physical",
		name = "Skitter Smack",
		id = 'skittersmack',
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		secondary= {
			chance = 100,
			boosts = {
				spa = -1,
			},
		},
		target = "normal",
		type = "Bug",
	},
	burningjealousy = {
		num = 807,
		accuracy = 100,
		basePower = 70,
		category = "Special",
		name = "Burning Jealousy",
		id = 'burningjealousy',
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			onHit = function(target, source, move)
				if not (target.statsRaisedThisTurn) then
					target:trySetStatus('brn', source, move)
				end
			end,
		},
		target = "allAdjacentFoes",
		type = "Fire",
	},
	['crosschop'] = {
		num = 238,
		accuracy = 80,
		basePower = 100,
		category = "Physical",
		id = "crosschop",
		name = "Cross Chop",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		critRatio = 2,
		target = "normal",
		type = "Fighting"
	},
	['crosspoison'] = {
		num = 440,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "crosspoison",
		name = "Cross Poison",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'psn'
		},
		critRatio = 2,
		target = "normal",
		type = "Poison"
	},
	['crunch'] = {
		num = 242,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "crunch",
		name = "Crunch",
		pp = 15,
		flags = {bite = true, contact = true, protect = true, mirror = true},
		secondary = {
			chance = 20,
			boosts = {
				def = -1
			}
		},
		target = "normal",
		type = "Dark"
	},
	['crushclaw'] = {
		num = 306,
		accuracy = 95,
		basePower = 75,
		category = "Physical",
		id = "crushclaw",
		name = "Crush Claw",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 50,
			boosts = {
				def = -1
			}
		},
		target = "normal",
		type = "Normal"
	},
	['crushgrip'] = {
		num = 462,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			return math.max(1, math.floor(math.floor((120 * (100 * math.floor(target.hp * 4096 / target.maxhp)) + 2048 - 1) / 4096) / 100))
		end,
		category = "Physical",
		id = "crushgrip",
		name = "Crush Grip",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['curse'] = {
		num = 174,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "curse",
		name = "Curse",
		pp = 10,
		flags = {authentic = true},
		volatileStatus = 'curse',
		onModifyMove = function(move, source, target)
			if not source:hasType('Ghost') then
				move.target = move.nonGhostTarget
			end
		end,
		onTryHit = function(target, source, move)
			if not source:hasType('Ghost') then
				move.volatileStatus = nil
				move.onHit = nil
				move.self = { boosts = {spe=-1, atk=1, def=1} }
			elseif move.volatileStatus and target.volatiles.curse then
				return false
			end
		end,
		onHit = function(target, source)
			self:directDamage(source.maxhp / 2, source, source)
		end,
		effect = {
			onStart = function(pokemon, source)
				self:add('-start', pokemon, 'Curse', '[of] ' .. source)
			end,
			onResidualOrder = 10,
			onResidual = function(pokemon)
				self:damage(pokemon.maxhp / 4)
			end
		},
		target = "normal",
		nonGhostTarget = "self",
		type = "Ghost"
	},
	['cut'] = {
		num = 15,
		accuracy = 95,
		basePower = 50,
		category = "Physical",
		id = "cut",
		name = "Cut",
		pp = 30,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		target = "normal",
		type = "Normal"
	},
	['darkpulse'] = {
		num = 399,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "darkpulse",
		name = "Dark Pulse",
		pp = 15,
		flags = {protect = true, pulse = true, mirror = true, distance = true},
		secondary = {
			chance = 20,
			volatileStatus = 'flinch'
		},
		target = "any",
		type = "Dark"
	},
	['darkvoid'] = {
		num = 464,
		accuracy = 50,
		basePower = 0,
		category = "Status",
		id = "darkvoid",
		name = "Dark Void",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		status = 'slp',
		target = "allAdjacentFoes",
		type = "Dark"
	},
	['dazzlinggleam'] = {
		num = 605,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "dazzlinggleam",
		name = "Dazzling Gleam",
		pp = 10,
		flags = {protect = true, mirror = true},
		target = "allAdjacentFoes",
		type = "Fairy"
	},
	['defendorder'] = {
		num = 455,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "defendorder",
		name = "Defend Order",
		pp = 10,
		flags = {snatch = true},
		boosts = {
			def = 1,
			spd = 1
		},
		target = "self",
		type = "Bug"
	},
	['defensecurl'] = {
		num = 111,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "defensecurl",
		name = "Defense Curl",
		pp = 40,
		flags = {snatch = true},
		boosts = {
			def = 1
		},
		volatileStatus = 'DefenseCurl',
		target = "self",
		type = "Normal"
	},
	['defog'] = {
		num = 432,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "defog",
		name = "Defog",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		onHit = function(target, source, move)
			if not target.volatiles['substitute'] or move.infiltrates then
				self:boost({evasion=-1})
			end
			local sideConditions = {reflect=true, lightscreen=true, safeguard=true, mist=true, spikes=true, toxicspikes=true, stealthrock=true, stickyweb=true}
			local sideEnd = {spikes=true, toxicspikes=true, stealthrock=true, stickyweb=true}
			for sc in pairs(sideConditions) do
				if target.side:removeSideCondition(sc) then
					if sideEnd[sc] then
						self:add('-sideend', target.side, self:getEffect(sc).name, '[from] move: Defog', '[of] ' .. target)
					end
				end
			end
			for sc in pairs(sideEnd) do
				if source.side:removeSideCondition(sc) then
					self:add('-sideend', source.side, self:getEffect(sc).name, '[from] move: Defog', '[of] ' .. source)
				end
			end
		end,
		target = "normal",
		type = "Flying"
	},
	['destinybond'] = {
		num = 194,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "destinybond",
		name = "Destiny Bond",
		pp = 5,
		flags = {authentic = true},
		volatileStatus = 'destinybond',
		effect = {
			onStart = function(pokemon)
				self:add('-singlemove', pokemon, 'Destiny Bond')
			end,
			onFaint = function(target, source, effect)
				if Not(source) or Not(effect) then return end
				if effect.effectType == 'Move' and not effect.isFutureMove then
					self:add('-activate', target, 'Destiny Bond')
					source:faint()
				end
			end,
			onBeforeMovePriority = 100,
			onBeforeMove = function(pokemon)
				self:debug('removing Destiny Bond before attack')
				pokemon:removeVolatile('destinybond')
			end
		},
		target = "self",
		type = "Ghost"
	},
	['detect'] = {
		num = 197,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "detect",
		name = "Detect",
		pp = 5,
		priority = 4,
		stallingMove = true,
		volatileStatus = 'protect',
		onPrepareHit = function(pokemon)
			return not Not(self:willAct()) and not Not(self:runEvent('StallMove', pokemon))
		end,
		onHit = function(pokemon)
			pokemon:addVolatile('stall')
		end,
		target = "self",
		type = "Fighting"
	},
	['diamondstorm'] = {
		num = 591,
		accuracy = 95,
		basePower = 100,
		category = "Physical",
		id = "diamondstorm",
		name = "Diamond Storm",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 50,
			self = {
				boosts = {
					def = 2
				}
			}
		},
		target = "allAdjacentFoes",
		type = "Rock"
	},
	['dig'] = {
		num = 91,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "dig",
		name = "Dig",
		pp = 10,
		flags = {contact = true, charge = true, protect = true, mirror = true, nonsky = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		effect = {
			duration = 2,
			onImmunity = function(type, pokemon)
				if type == 'sandstorm' or type == 'hail' then return false end
			end,
			onAccuracy = function(accuracy, target, source, move)
				if move.id == 'earthquake' or move.id == 'magnitude' or move.id == 'helpinghand' then return end
				if source:hasAbility('noguard') or target:hasAbility('noguard') then return end
				if source.volatiles['lockon'] and target == source.volatiles['lockon'].source then return end
				return 0
			end,
			onSourceModifyDamage = function(damage, source, target, move)
				if move.id == 'earthquake' or move.id == 'magnitude' then
					return self:chainModify(2)
				end
			end
		},
		target = "normal",
		type = "Ground"
	},
	['disable'] = {
		num = 50,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "disable",
		name = "Disable",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		volatileStatus = 'disable',
		effect = {
			duration = 4,
			noCopy = true, -- doesn't get copied by Baton Pass
			onStart = function(pokemon)
				if not self:willMove(pokemon) then
					self.effectData.duration = self.effectData.duration + 1
				end
				if not pokemon.lastMove then
					self:debug('pokemon hasn\'t moved yet')
					return false
				end
				for _, move in pairs(pokemon.moveset) do
					if move.id == pokemon.lastMove then
						if move.pp <= 0 then
							self:debug('Move out of PP')
							return false
						else
							self:add('-start', pokemon, 'Disable', move.move)
							self.effectData.move = pokemon.lastMove
							return
						end
					end
				end
				self:debug('Move doesn\'t exist ???')
				return false
			end,
			onResidualOrder = 14,
			onEnd = function(pokemon)
				self:add('-end', pokemon, 'Disable')
			end,
			onBeforeMovePriority = 7,
			onBeforeMove = function(attacker, defender, move)
				if move.id == self.effectData.move then
					self:add('cant', attacker, 'Disable', move)
					return false
				end
			end,
			onDisableMove = function(pokemon)
				for _, move in pairs(pokemon.moveset) do
					if move.id == self.effectData.move then
						pokemon:disableMove(move.id)
					end
				end
			end
		},
		target = "normal",
		type = "Normal"
	},
	['disarmingvoice'] = {
		num = 574,
		accuracy = true,
		basePower = 40,
		category = "Special",
		id = "disarmingvoice",
		name = "Disarming Voice",
		pp = 15,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		target = "allAdjacentFoes",
		type = "Fairy"
	},
	['discharge'] = {
		num = 435,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "discharge",
		name = "Discharge",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "allAdjacent",
		type = "Electric"
	},
	lashout = {
		num = 808,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		name = "Lash Out",
		id = 'lashout',
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		onBasePower = function(basePower, source)
			if (source.statsLoweredThisTurn) then
				return self:chainModify(2)
			end
		end,
		target = "normal",
		type = "Dark",
	},
	['dive'] = {
		num = 291,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "dive",
		name = "Dive",
		pp = 10,
		flags = {contact = true, charge = true, protect = true, mirror = true, nonsky = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		effect = {
			duration = 2,
			onImmunity = function(type, pokemon)
				if type == 'sandstorm' or type == 'hail' then return false end
			end,
			onAccuracy = function(accuracy, target, source, move)
				if move.id == 'surf' or move.id == 'whirlpool' or move.id == 'helpinghand' then return end
				if source:hasAbility('noguard') or target:hasAbility('noguard') then return end
				if source.volatiles['lockon'] and target == source.volatiles['lockon'].source then return end
				return 0
			end,
			onSourceModifyDamage = function(damage, source, target, move)
				if move.id == 'surf' or move.id == 'whirlpool' then
					return self:chainModify(2)
				end
			end
		},
		target = "normal",
		type = "Water"
	},
	['dizzypunch'] = {
		num = 146,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "dizzypunch",
		name = "Dizzy Punch",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		secondary = {
			chance = 20,
			volatileStatus = 'confusion'
		},
		target = "normal",
		type = "Normal"
	},
	['doomdesire'] = {
		num = 353,
		accuracy = 100,
		basePower = 140,
		category = "Special",
		id = "doomdesire",
		name = "Doom Desire",
		pp = 5,
		isFutureMove = true,
		onTryHit = function(target, source)
			source.side:addSideCondition('futuremove')
			if source.side.sideConditions['futuremove'].positions[source.position] then return false end
			source.side.sideConditions['futuremove'].positions[source.position] = {
				duration = 3,
				move = 'doomdesire',
				targetPosition = target.position,
				source = source,
				moveData = {
					name = "Doom Desire",
					basePower = 140,
					category = "Special",
					type = 'Steel'
				}
			}
			self:add('-start', source, 'Doom Desire')
			return null
		end,
		target = "normal",
		type = "Steel"
	},
	['doubleedge'] = {
		num = 38,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "doubleedge",
		name = "Double-Edge",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		recoil = {33, 100},
		target = "normal",
		type = "Normal"
	},
	['doublehit'] = {
		num = 458,
		accuracy = 90,
		basePower = 35,
		category = "Physical",
		id = "doublehit",
		name = "Double Hit",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		multihit = 2,
		target = "normal",
		type = "Normal"
	},
	['doublekick'] = {
		num = 24,
		accuracy = 100,
		basePower = 30,
		category = "Physical",
		id = "doublekick",
		name = "Double Kick",
		pp = 30,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		multihit = 2,
		target = "normal",
		type = "Fighting"
	},
	['doubleslap'] = {
		num = 3,
		accuracy = 85,
		basePower = 15,
		category = "Physical",
		id = "doubleslap",
		name = "Double Slap",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Normal"
	},
	['doubleteam'] = {
		num = 104,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "doubleteam",
		name = "Double Team",
		pp = 15,
		flags = {snatch = true},
		boosts = {
			evasion = 1
		},
		target = "self",
		type = "Normal"
	},
	['dracometeor'] = {
		num = 434,
		accuracy = 90,
		basePower = 130,
		category = "Special",
		id = "dracometeor",
		name = "Draco Meteor",
		pp = 5,
		flags = {protect = true, mirror = true},
		self = {
			boosts = {
				spa = -2
			}
		},
		target = "normal",
		type = "Dragon"
	},
	['dragonascent'] = {
		num = 620,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "dragonascent",
		name = "Dragon Ascent",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true, distance = true},
		self = {
			boosts = {
				def = -1,
				spd = -1
			}
		},
		target = "any",
		type = "Flying"
	},
	['dragonbreath'] = {
		num = 225,
		accuracy = 100,
		basePower = 60,
		category = "Special",
		id = "dragonbreath",
		name = "Dragon Breath",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "normal",
		type = "Dragon"
	},
	['dragonclaw'] = {
		num = 337,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "dragonclaw",
		name = "Dragon Claw",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Dragon"
	},
	['dragondance'] = {
		num = 349,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "dragondance",
		name = "Dragon Dance",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			atk = 1,
			spe = 1
		},
		target = "self",
		type = "Dragon"
	},
	['dragonpulse'] = {
		num = 406,
		accuracy = 100,
		basePower = 85,
		category = "Special",
		id = "dragonpulse",
		name = "Dragon Pulse",
		pp = 10,
		flags = {protect = true, pulse = true, mirror = true, distance = true},
		target = "any",
		type = "Dragon"
	},
	['dragonrage'] = {
		num = 82,
		accuracy = 100,
		basePower = 0,
		damage = 40,
		category = "Special",
		id = "dragonrage",
		name = "Dragon Rage",
		pp = 10,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Dragon"
	},
	['dragonrush'] = {
		num = 407,
		accuracy = 75,
		basePower = 100,
		category = "Physical",
		id = "dragonrush",
		name = "Dragon Rush",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 20,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Dragon"
	},
	['dragontail'] = {
		num = 525,
		accuracy = 90,
		basePower = 60,
		category = "Physical",
		id = "dragontail",
		name = "Dragon Tail",
		pp = 10,
		priority = -6,
		flags = {contact = true, protect = true, mirror = true},
		forceSwitch = true,
		target = "normal",
		type = "Dragon"
	},
	['drainingkiss'] = {
		num = 577,
		accuracy = 100,
		basePower = 50,
		category = "Special",
		id = "drainingkiss",
		name = "Draining Kiss",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, heal = true},
		drain = {3, 4},
		target = "normal",
		type = "Fairy"
	},
	['drainpunch'] = {
		num = 409,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		id = "drainpunch",
		name = "Drain Punch",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, punch = true, heal = true},
		drain = {1, 2},
		target = "normal",
		type = "Fighting"
	},
	['dreameater'] = {
		num = 138,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		id = "dreameater",
		name = "Dream Eater",
		pp = 15,
		flags = {protect = true, mirror = true, heal = true},
		drain = {1, 2},
		onTryHit = function(target)
			if target.status ~= 'slp' then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		target = "normal",
		type = "Psychic"
	},
	['drillpeck'] = {
		num = 65,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "drillpeck",
		name = "Drill Peck",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, distance = true},
		target = "any",
		type = "Flying"
	},
	['drillrun'] = {
		num = 529,
		accuracy = 95,
		basePower = 80,
		category = "Physical",
		id = "drillrun",
		name = "Drill Run",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		critRatio = 2,
		target = "normal",
		type = "Ground"
	},
	['dualchop'] = {
		num = 530,
		accuracy = 90,
		basePower = 40,
		category = "Physical",
		id = "dualchop",
		name = "Dual Chop",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		multihit = 2,
		target = "normal",
		type = "Dragon"
	},
	['dynamicpunch'] = {
		num = 223,
		accuracy = 50,
		basePower = 100,
		category = "Physical",
		id = "dynamicpunch",
		name = "Dynamic Punch",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		secondary = {
			chance = 100,
			volatileStatus = 'confusion'
		},
		target = "normal",
		type = "Fighting"
	},
	['earthpower'] = {
		num = 414,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "earthpower",
		name = "Earth Power",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		secondary = {
			chance = 10,
			boosts = {
				spd = -1
			}
		},
		target = "normal",
		type = "Ground"
	},
	['earthquake'] = {
		num = 89,
		accuracy = 100,
		basePower = 100,
		category = "Physical",
		id = "earthquake",
		name = "Earthquake",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		target = "allAdjacent",
		type = "Ground"
	},
	['echoedvoice'] = {
		num = 497,
		accuracy = 100,
		basePower = 40,
		basePowerCallback = function()
			if self.pseudoWeather.echoedvoice then
				return 40 * self.pseudoWeather.echoedvoice.multiplier
			end
			return 40
		end,
		category = "Special",
		id = "echoedvoice",
		name = "Echoed Voice",
		pp = 15,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		onTry = function()
			self:addPseudoWeather('echoedvoice')
		end,
		effect = {
			duration = 2,
			onStart = function()
				self.effectData.multiplier = 1
			end,
			onRestart = function()
				if self.effectData.duration ~= 2 then
					self.effectData.duration = 2
					if self.effectData.multiplier < 5 then
						self.effectData.multiplier = self.effectData.multiplier + 1
					end
				end
			end
		},
		target = "normal",
		type = "Normal"
	},
	['eerieimpulse'] = {
		num = 598,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "eerieimpulse",
		name = "Eerie Impulse",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			spa = -2
		},
		target = "normal",
		type = "Electric"
	},
	['eggbomb'] = {
		num = 121,
		accuracy = 75,
		basePower = 100,
		category = "Physical",
		id = "eggbomb",
		name = "Egg Bomb",
		pp = 10,
		flags = {bullet = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['electricterrain'] = {
		num = 604,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "electricterrain",
		name = "Electric Terrain",
		pp = 10,
		flags = {nonsky = true},
		terrain = 'electricterrain',
		effect = {
			duration = 5,
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
				self:add('-fieldstart', 'move = Electric Terrain')				
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 2,
			onEnd = function()
				self:add('-fieldend', 'move = Electric Terrain')
			end
		},
		target = "all",
		type = "Electric"
	},
	['electrify'] = {
		num = 582,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "electrify",
		name = "Electrify",
		pp = 20,
		flags = {protect = true, mirror = true},
		volatileStatus = 'electrify',
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-singleturn', target, 'move = Electrify')
			end,
			onModifyMovePriority = -2,
			onModifyMove = function(move)
				self:debug('Electrify making move type electric')
				move.type = 'Electric'
			end
		},
		target = "normal",
		type = "Electric"
	},
	['electroball'] = {
		num = 486,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			local ratio = pokemon:getStat('spe') / target:getStat('spe')
			pcall(function() self:debug(({40, 60, 80, 120, 150})[(math.floor(ratio)>4 and 4 or math.floor(ratio))+1] .. ' bp') end)
			if ratio >= 4 then
				return 150
			elseif ratio >= 3 then
				return 120
			elseif ratio >= 2 then
				return 80
			elseif ratio >= 1 then
				return 60
			end
			return 40
		end,
		category = "Special",
		id = "electroball",
		name = "Electro Ball",
		pp = 10,
		flags = {bullet = true, protect = true, mirror = true},
		target = "normal",
		type = "Electric"
	},
	['electroweb'] = {
		num = 527,
		accuracy = 95,
		basePower = 55,
		category = "Special",
		id = "electroweb",
		name = "Electroweb",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spe = -1
			}
		},
		target = "allAdjacentFoes",
		type = "Electric"
	},
	['embargo'] = {
		num = 373,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "embargo",
		name = "Embargo",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'embargo',
		effect = {
			duration = 5,
			onStart = function(pokemon)
				self:add('-start', pokemon, 'Embargo')
			end,
			-- Item suppression implemented in BattlePokemon:ignoringItem()
			onResidualOrder = 18,
			onEnd = function(pokemon)
				self:add('-end', pokemon, 'Embargo')
			end,
		},
		target = "normal",
		type = "Dark"
	},
	['ember'] = {
		num = 52,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "ember",
		name = "Ember",
		pp = 25,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['encore'] = {
		num = 227,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "encore",
		name = "Encore",
		pp = 5,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		volatileStatus = 'encore',
		effect = {
			duration = 3,
			onStart = function(target)
				local noEncore = {encore=true, mimic=true, mirrormove=true, sketch=true, struggle=true, transform=true}
				local moveIndex = indexOf(target.moves, target.lastMove)
				if Not(target.lastMove) or noEncore[target.lastMove] or (target.moveset[moveIndex] and target.moveset[moveIndex].pp <= 0) then
					-- it failed
					target.volatiles['encore'] = nil
					return false
				end
				self.effectData.move = target.lastMove
				self:add('-start', target, 'Encore')
				if not self:willMove(target) then
					self.effectData.duration = self.effectData.duration + 1
				end
			end,
			onOverrideDecision = function(pokemon, target, move)
				if move.id ~= self.effectData.move then return self.effectData.move end
			end,
			onResidualOrder = 13,
			onResidual = function(target)
				if indexOf(target.moves, target.lastMove) and target.moveset[indexOf(target.moves, target.lastMove)].pp <= 0 then -- early termination if you run out of PP
					target.volatiles.encore = nil
					self:add('-end', target, 'Encore')
				end
			end,
			onEnd = function(target)
				self:add('-end', target, 'Encore')
			end,
			onDisableMove = function(pokemon)
				if not self.effectData.move or not pokemon:hasMove(self.effectData.move) then return end
				for _, move in pairs(pokemon.moveset) do
					if move.id ~= self.effectData.move then
						pokemon:disableMove(move.id)
					end
				end
			end
		},
		target = "normal",
		type = "Normal"
	},
	['endeavor'] = {
		num = 283,
		accuracy = 100,
		basePower = 0,
		damageCallback = function(pokemon, target)
			if target.hp > pokemon.hp then
				return target.hp - pokemon.hp
			end
			self:add('-immune', target, '[msg]')
			return null
		end,
		category = "Physical",
		id = "endeavor",
		name = "Endeavor",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['endure'] = {
		num = 203,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "endure",
		name = "Endure",
		pp = 10,
		priority = 4,
		stallingMove = true,
		volatileStatus = 'endure',
		onTryHit = function(pokemon)
			return self:willAct() and not Not(self:runEvent('StallMove', pokemon))
		end,
		onHit = function(pokemon)
			pokemon:addVolatile('stall')
		end,
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-singleturn', target, 'move = Endure')
			end,
			onDamagePriority = -10,
			onDamage = function(damage, target, source, effect)
				if effect and effect.effectType == 'Move' and damage >= target.hp then
					self:add('-activate', target, 'move: Endure')
					return target.hp - 1
				end
			end
		},
		target = "self",
		type = "Normal"
	},
	['energyball'] = {
		num = 412,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "energyball",
		name = "Energy Ball",
		pp = 10,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				spd = -1
			}
		},
		target = "normal",
		type = "Grass"
	},
	['entrainment'] = {
		num = 494,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "entrainment",
		name = "Entrainment",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		onTryHit = function(target, source)
			if target == source then return false end
			local bannedTargetAbilities = {multitype=true, stancechange=true, truant=true}
			local bannedSourceAbilities = {flowergift=true, forecast=true, illusion=true, imposter=true, multitype=true, stancechange=true, trace=true, zenmode=true}
			if bannedTargetAbilities[target.ability] or bannedSourceAbilities[source.ability] or target.ability == source.ability then
				return false
			end
		end,
		onHit = function(target, source)
			local oldAbility = target:setAbility(source.ability)
			if oldAbility then
				self:add('-ability', target, target.ability, '[from] move: Entrainment')
				return
			end
			return false
		end,
		target = "normal",
		type = "Normal"
	},
	['eruption'] = {
		num = 284,
		accuracy = 100,
		basePower = 150,
		basePowerCallback = function(pokemon)
			return 150 * pokemon.hp / pokemon.maxhp
		end,
		category = "Special",
		id = "eruption",
		name = "Eruption",
		pp = 5,
		flags = {protect = true, mirror = true},
		target = "allAdjacentFoes",
		type = "Fire"
	},
	['explosion'] = {
		num = 153,
		accuracy = 100,
		basePower = 250,
		category = "Physical",
		id = "explosion",
		name = "Explosion",
		pp = 5,
		flags = {protect = true, mirror = true},
		selfdestruct = true,
		target = "allAdjacent",
		type = "Normal"
	},
	['extrasensory'] = {
		num = 326,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "extrasensory",
		name = "Extrasensory",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Psychic"
	},
	['extremespeed'] = {
		num = 245,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "extremespeed",
		name = "Extreme Speed",
		pp = 5,
		priority = 2,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['facade'] = {
		num = 263,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "facade",
		name = "Facade",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon)
			if pokemon.status and pokemon.status ~= '' and pokemon.status ~= 'slp' then
				return self:chainModify(2)
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['feintattack'] = {
		num = 185,
		accuracy = true,
		basePower = 60,
		category = "Physical",
		id = "feintattack",
		name = "Feint Attack",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Dark"
	},
	['fairylock'] = {
		num = 587,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "fairylock",
		name = "Fairy Lock",
		pp = 10,
		flags = {mirror = true, authentic = true},
		pseudoWeather = 'fairylock',
		effect = {
			duration = 2,
			onStart = function(target)
				self:add('-activate', target, 'move = Fairy Lock')
			end,
			onModifyPokemon = function(pokemon)
				pokemon:tryTrap()
			end
		},
		target = "all",
		type = "Fairy"
	},
	['fairywind'] = {
		num = 584,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "fairywind",
		name = "Fairy Wind",
		pp = 30,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Fairy"
	},
	['fakeout'] = {
		num = 252,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "fakeout",
		name = "Fake Out",
		pp = 10,
		priority = 3,
		flags = {contact = true, protect = true, mirror = true},
		onTryHit = function(target, pokemon)
			if pokemon.activeTurns > 1 then
				self:add('-fail', pokemon)
				self:add('-hint', "Fake Out only works on your first turn out.")
				return null
			end
		end,
		secondary = {
			chance = 100,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Normal"
	},
	['faketears'] = {
		num = 313,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "faketears",
		name = "Fake Tears",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			spd = -2
		},
		target = "normal",
		type = "Dark"
	},
	['falseswipe'] = {
		num = 206,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "falseswipe",
		name = "False Swipe",
		pp = 40,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		noFaint = true,
		target = "normal",
		type = "Normal"
	},
	['featherdance'] = {
		num = 297,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "featherdance",
		name = "Feather Dance",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			atk = -2
		},
		target = "normal",
		type = "Flying"
	},
	['feint'] = {
		num = 364,
		accuracy = 100,
		basePower = 30,
		category = "Physical",
		id = "feint",
		name = "Feint",
		pp = 10,
		priority = 2,
		flags = {mirror = true},
		breaksProtect = true,
		-- Breaking protection implemented in BattleEngine.Extension
		target = "normal",
		type = "Normal"
	},
	['fellstinger'] = {
		num = 565,
		accuracy = 100,
		basePower = 50,
		category = "Physical",
		id = "fellstinger",
		name = "Fell Stinger",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		onHit = function(target, pokemon)
			pokemon:addVolatile('fellstinger')
		end,
		effect = {
			duration = 1,
			onAfterMoveSecondarySelf = function(pokemon, target, move)
				if not target or target.fainted or target.hp <= 0 then self:boost({atk=3}, pokemon, pokemon, move) end
				pokemon:removeVolatile('fellstinger')
			end
		},
		target = "normal",
		type = "Bug"
	},
	['fierydance'] = {
		num = 552,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "fierydance",
		name = "Fiery Dance",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 50,
			self = {
				boosts = {
					spa = 1
				}
			}
		},
		target = "normal",
		type = "Fire"
	},
	['finalgambit'] = {
		num = 515,
		accuracy = 100,
		basePower = 0,
		damageCallback = function(pokemon)
			local damage = pokemon.hp
			pokemon:faint()
			return damage
		end,
		category = "Special",
		id = "finalgambit",
		name = "Final Gambit",
		pp = 5,
		flags = {protect = true},
		selfdestruct = true,
		target = "normal",
		type = "Fighting"
	},
	['fireblast'] = {
		num = 126,
		accuracy = 85,
		basePower = 110,
		category = "Special",
		id = "fireblast",
		name = "Fire Blast",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['firefang'] = {
		num = 424,
		accuracy = 95,
		basePower = 65,
		category = "Physical",
		id = "firefang",
		name = "Fire Fang",
		pp = 15,
		flags = {bite = true, contact = true, protect = true, mirror = true},
		secondaries = { {
			chance = 10,
			status = 'brn'
		}, {
				chance = 10,
				volatileStatus = 'flinch'
			}
		},
		target = "normal",
		type = "Fire"
	},
	['firepledge'] = {
		num = 519,
		accuracy = 100,
		basePower = 80,
		basePowerCallback = function(target, source, move)
			if move.sourceEffect == 'grasspledge' or move.sourceEffect == 'waterpledge' then
				self:add('-combine')
				return 150
			end
			return 80
		end,
		category = "Special",
		id = "firepledge",
		name = "Fire Pledge",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		onPrepareHit = function(target, source, move)
			for _, decision in pairs(self.queue) do
				if decision.move and decision.pokemon and decision.pokemon.isActive and not decision.pokemon.fainted then
					if decision.pokemon.side == source.side and (decision.move.id == 'grasspledge' or decision.move.id == 'waterpledge') then
						self:prioritizeQueue(decision)
						self:add('-waiting', source, decision.pokemon)
						return null
					end
				end
			end
		end,
		onModifyMove = function(move)
			if move.sourceEffect == 'waterpledge' then
				move.type = 'Water'
				move.hasSTAB = true
			end
			if move.sourceEffect == 'grasspledge' then
				move.type = 'Fire'
				move.hasSTAB = true
			end
		end,
		onHit = function(target, source, move)
			if move.sourceEffect == 'grasspledge' then
				target.side:addSideCondition('firepledge')
			end
			if move.sourceEffect == 'waterpledge' then
				source.side:addSideCondition('waterpledge')
			end
		end,
		effect = {
			duration = 4,
			onStart = function(targetSide)
				self:add('-sidestart', targetSide, 'Fire Pledge')
			end,
			onEnd = function(targetSide)
				self:add('-sideend', targetSide, 'Fire Pledge')
			end,
			onResidual = function(side)
				for _, pokemon in pairs(side.active) do
					if pokemon ~= null and not pokemon:hasType('Fire') then
						self:damage(pokemon.maxhp / 8, pokemon)
					end
				end
			end
		},
		target = "normal",
		type = "Fire"
	},
	['firepunch'] = {
		num = 7,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		id = "firepunch",
		name = "Fire Punch",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		secondary = {
			chance = 10,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['firespin'] = {
		num = 83,
		accuracy = 85,
		basePower = 35,
		category = "Special",
		id = "firespin",
		name = "Fire Spin",
		pp = 15,
		flags = {protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Fire"
	},
	['fissure'] = {
		num = 90,
		accuracy = 30,
		basePower = 0,
		category = "Physical",
		id = "fissure",
		name = "Fissure",
		pp = 5,
		flags = {protect = true, mirror = true, nonsky = true},
		ohko = true,
		target = "normal",
		type = "Ground"
	},
	['flail'] = {
		num = 175,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			local ratio = pokemon.hp * 48 / pokemon.maxhp
			if ratio < 2 then
				return 200
			elseif ratio < 5 then
				return 150
			elseif ratio < 10 then
				return 100
			elseif ratio < 17 then
				return 80
			elseif ratio < 33 then
				return 40
			end
			return 20
		end,
		category = "Physical",
		id = "flail",
		name = "Flail",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['flameburst'] = {
		num = 481,
		accuracy = 100,
		basePower = 70,
		category = "Special",
		id = "flameburst",
		name = "Flame Burst",
		pp = 15,
		flags = {protect = true, mirror = true},
		onHit = function(target, source)
			local allyActive = target.side.active
			if #allyActive == 1 then return end
			for _, ally in pairs(allyActive) do
				if ally and self:isAdjacent(target, ally) then
					self:damage(ally.maxhp / 16, ally, source, 'flameburst')
				end
			end
		end,
		target = "normal",
		type = "Fire"
	},
	['flamecharge'] = {
		num = 488,
		accuracy = 100,
		basePower = 50,
		category = "Physical",
		id = "flamecharge",
		name = "Flame Charge",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			self = {
				boosts = {
					spe = 1
				}
			}
		},
		target = "normal",
		type = "Fire"
	},
	['flamewheel'] = {
		num = 172,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "flamewheel",
		name = "Flame Wheel",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true, defrost = true},
		secondary = {
			chance = 10,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['flamethrower'] = {
		num = 53,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "flamethrower",
		name = "Flamethrower",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['flareblitz'] = {
		num = 394,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "flareblitz",
		name = "Flare Blitz",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, defrost = true},
		recoil = {33, 100},
		secondary = {
			chance = 10,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['flash'] = {
		num = 148,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "flash",
		name = "Flash",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			accuracy = -1
		},
		target = "normal",
		type = "Normal"
	},
	['flashcannon'] = {
		num = 430,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "flashcannon",
		name = "Flash Cannon",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				spd = -1
			}
		},
		target = "normal",
		type = "Steel"
	},
	['flatter'] = {
		num = 260,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "flatter",
		name = "Flatter",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'confusion',
		boosts = {
			spa = 1
		},
		target = "normal",
		type = "Dark"
	},
	['fling'] = {
		num = 374,
		accuracy = 100,
		basePower = 0,
		category = "Physical",
		id = "fling",
		name = "Fling",
		pp = 10,
		flags = {protect = true, mirror = true},
		beforeMoveCallback = function(pokemon)
			if pokemon:ignoringItem() then return end
			local item = pokemon:getItem()
			local noFling = item.onTakeItem and item.onTakeItem(item, pokemon) == false
			if item.fling and not noFling then
				pokemon:addVolatile('fling')
				pokemon:setItem('')
				self:runEvent('AfterUseItem', pokemon, nil, nil, item)
			end
		end,
		onPrepareHit = function(target, source, move)
			if not source.volatiles['fling'] then return false end
			local item = self:getItem(source.volatiles['fling'].item)
			self:add("-enditem", source, item.name, '[from] move = Fling')
		end,
		effect = {
			duration = 1,
			onStart = function(pokemon)
				self.effectData.item = pokemon.item
			end,
			onModifyMovePriority = -3,
			onModifyMove = function(move)
				local item = self:getItem(self.effectData.item)
				move.basePower = item.fling.basePower
				if item.isBerry and item.id ~= 'enigmaberry' then
					move.onHit = function(foe)
						self:singleEvent('Eat', item, nil, foe, nil, nil)
						foe.ateBerry = true
					end
				elseif item.fling.effect then
					move.onHit = item.fling.effect
				else
					if not move.secondaries then move.secondaries = {} end
					if item.fling.status then
						table.insert(move.secondaries, {status = item.fling.status})
					elseif item.fling.volatileStatus then
						table.insert(move.secondaries, {volatileStatus = item.fling.volatileStatus})
					end
				end
			end
		},
		target = "normal",
		type = "Dark"
	},
	['flowershield'] = {
		num = 579,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "flowershield",
		name = "Flower Shield",
		pp = 10,
		flags = {distance = true},
		onHitField = function(target, source)
			local targets = {}
			for _, side in pairs(self.sides) do
				for _, pokemon in pairs(side.active) do
					if pokemon ~= null and not pokemon.fainted and pokemon:hasType('Grass') then
						-- This move affects every Grass-type Pokemon in play.
						table.insert(targets, pokemon)
					end
				end
			end
			if #targets == 0 then return false end -- No targets; move fails
			for _, target in pairs(targets) do
				self:boost({def = 1}, target, source, self:getMove('Flower Shield'))
			end
		end,
		target = "all",
		type = "Fairy"
	},
	['fly'] = {
		num = 19,
		accuracy = 95,
		basePower = 90,
		category = "Physical",
		id = "fly",
		name = "Fly",
		pp = 15,
		flags = {contact = true, charge = true, protect = true, mirror = true, gravity = true, distance = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then
				return
			end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		effect = {
			duration = 2,
			onAccuracy = function(accuracy, target, source, move)
				if move.id == 'gust' or move.id == 'twister' then return end
				if move.id == 'skyuppercut' or move.id == 'thunder' or move.id == 'hurricane' or move.id == 'smackdown' or move.id == 'thousandarrows' or move.id == 'helpinghand' then return end
				if source:hasAbility('noguard') or target:hasAbility('noguard') then return end
				if source.volatiles['lockon'] and target == source.volatiles['lockon'].source then return end
				return 0
			end,
			onSourceModifyDamage = function(damage, source, target, move)
				if move.id == 'gust' or move.id == 'twister' then
					return self:chainModify(2)
				end
			end
		},
		target = "any",
		type = "Flying"
	},
	['flyingpress'] = {
		num = 560,
		accuracy = 95,
		basePower = 100,
		category = "Physical",
		id = "flyingpress",
		name = "Flying Press",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, gravity = true, distance = true, nonsky = true},
		onEffectiveness = function(typeMult, type, move)
			return typeMult * self:getEffectiveness('Flying', type)
		end,
		target = "any",
		type = "Fighting"
	},
	['focusblast'] = {
		num = 411,
		accuracy = 70,
		basePower = 120,
		category = "Special",
		id = "focusblast",
		name = "Focus Blast",
		pp = 5,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				spd = -1
			}
		},
		target = "normal",
		type = "Fighting"
	},
	['focusenergy'] = {
		num = 116,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "focusenergy",
		name = "Focus Energy",
		pp = 30,
		flags = {snatch = true},
		volatileStatus = 'focusenergy',
		effect = {
			onStart = function(pokemon)
				self:add('-start', pokemon, 'move = Focus Energy')
			end,
			onModifyMove = function(move)
				move.critRatio = move.critRatio + 2
			end
		},
		target = "self",
		type = "Normal"
	},
	['focuspunch'] = {
		num = 264,
		accuracy = 100,
		basePower = 150,
		category = "Physical",
		id = "focuspunch",
		name = "Focus Punch",
		pp = 20,
		priority = -3,
		flags = {contact = true, protect = true, punch = true},
		beforeTurnCallback = function(pokemon)
			pokemon:addVolatile('focuspunch')
		end,
		beforeMoveCallback = function(pokemon)
			if not pokemon:removeVolatile('focuspunch') then return false end
			if pokemon.lastAttackedBy and pokemon.lastAttackedBy.thisTurn and pokemon.lastAttackedBy.damage > 0 and self:getMove(pokemon.lastAttackedBy.move).category ~= 'Status' then
				self:add('cant', pokemon, 'Focus Punch', 'Focus Punch')
				return true
			end
		end,
		effect = {
			duration = 1,
			onStart = function(pokemon)
				self:add('-singleturn', pokemon, 'move = Focus Punch')
			end
		},
		target = "normal",
		type = "Fighting"
	},
	['followme'] = {
		num = 266,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "followme",
		name = "Follow Me",
		pp = 20,
		priority = 2,
		volatileStatus = 'followme',
		effect = {
			duration = 1,
			onFoeRedirectTarget = function(target, source, source2, move)
				if self:validTarget(self.effectData.target, source, move.target) then
					self:debug("Follow Me redirected target of move")
					return self.effectData.target
				end
			end
		},
		target = "self",
		type = "Normal"
	},
	['forcepalm'] = {
		num = 395,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "forcepalm",
		name = "Force Palm",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "normal",
		type = "Fighting"
	},
	['foresight'] = {
		num = 193,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "foresight",
		name = "Foresight",
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		volatileStatus = 'foresight',
		onTryHit = function (target)
			if target.volatiles['miracleeye'] then return false end
		end,
		effect = {
			onStart = function(pokemon)
				self:add('-start', pokemon, 'Foresight')
			end,
			onNegateImmunity = function(pokemon, type)
				if pokemon:hasType('Ghost') and (type == 'Normal' or type == 'Fighting') then return false end
			end,
			onModifyBoost = function(boosts)
				if boosts.evasion and boosts.evasion > 0 then
					boosts.evasion = 0
				end
			end
		},
		target = "normal",
		type = "Normal"
	},
	['forestscurse'] = {
		num = 571,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "forestscurse",
		name = "Forest's Curse",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		onHit = function(target)
			if target:hasType('Grass') then return false end
			if not target:addType('Grass') then return false end
			self:add('-start', target, 'typeadd', 'Grass', '[from] move = Forest\'s Curse')
		end,
		target = "normal",
		type = "Grass"
	},
	['foulplay'] = {
		num = 492,
		accuracy = 100,
		basePower = 95,
		category = "Physical",
		id = "foulplay",
		name = "Foul Play",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		useTargetOffensive = true,
		target = "normal",
		type = "Dark"
	},
	['freezedry'] = {
		num = 573,
		accuracy = 100,
		basePower = 70,
		category = "Special",
		id = "freezedry",
		name = "Freeze-Dry",
		pp = 20,
		flags = {protect = true, mirror = true},
		onEffectiveness = function(typeMult, type)
			if type == 'Water' then return 2 end
		end,
		secondary = {
			chance = 10,
			status = 'frz'
		},
		target = "normal",
		type = "Ice"
	},
	['freezeshock'] = {
		num = 553,
		accuracy = 90,
		basePower = 140,
		category = "Physical",
		id = "freezeshock",
		name = "Freeze Shock",
		pp = 5,
		flags = {charge = true, protect = true, mirror = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "normal",
		type = "Ice"
	},
	['frenzyplant'] = {
		num = 338,
		accuracy = 90,
		basePower = 150,
		category = "Special",
		id = "frenzyplant",
		name = "Frenzy Plant",
		pp = 5,
		flags = {recharge = true, protect = true, mirror = true, nonsky = true},
		self = {
			volatileStatus = 'mustrecharge'
		},
		target = "normal",
		type = "Grass"
	},
	['frostbreath'] = {
		num = 524,
		accuracy = 90,
		basePower = 60,
		category = "Special",
		id = "frostbreath",
		name = "Frost Breath",
		pp = 10,
		flags = {protect = true, mirror = true},
		willCrit = true,
		target = "normal",
		type = "Ice"
	},
	['frustration'] = {
		num = 218,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon)
			return math.max(math.floor(((255 - pokemon.happiness) * 10) / 25), 1)
		end,
		category = "Physical",
		id = "frustration",
		name = "Frustration",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['furyattack'] = {
		num = 31,
		accuracy = 85,
		basePower = 15,
		category = "Physical",
		id = "furyattack",
		name = "Fury Attack",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Normal"
	},
	['furycutter'] = {
		num = 210,
		accuracy = 95,
		basePower = 40,
		basePowerCallback = function(pokemon)
			if not pokemon.volatiles.furycutter then
				pokemon:addVolatile('furycutter')
			end
			return 40 * pokemon.volatiles.furycutter.multiplier
		end,
		category = "Physical",
		id = "furycutter",
		name = "Fury Cutter",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		onHit = function(target, source)
			source:addVolatile('furycutter')
		end,
		effect = {
			duration = 2,
			onStart = function()
				self.effectData.multiplier = 1
			end,
			onRestart = function()
				if self.effectData.multiplier < 4 then
					self.effectData.multiplier = self.effectData.multiplier * 2
				end
				self.effectData.duration = 2
			end
		},
		target = "normal",
		type = "Bug"
	},
	['furyswipes'] = {
		num = 154,
		accuracy = 80,
		basePower = 18,
		category = "Physical",
		id = "furyswipes",
		name = "Fury Swipes",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Normal"
	},
	['fusionbolt'] = {
		num = 559,
		accuracy = 100,
		basePower = 100,
		category = "Physical",
		id = "fusionbolt",
		name = "Fusion Bolt",
		pp = 5,
		flags = {protect = true, mirror = true},
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon)
			for _, ally in pairs(pokemon.side.active) do
				if ally ~= null and ally.moveThisTurn == 'fusionflare' then
					self:debug('double power')
					return self:chainModify(2)
				end
			end
		end,
		target = "normal",
		type = "Electric"
	},
	['fusionflare'] = {
		num = 558,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		id = "fusionflare",
		name = "Fusion Flare",
		pp = 5,
		flags = {protect = true, mirror = true, defrost = true},
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon)
			for _, ally in pairs(pokemon.side.active) do
				if ally ~= null and ally.moveThisTurn == 'fusionbolt' then
					self:debug('double power')
					return self:chainModify(2)
				end
			end
		end,
		target = "normal",
		type = "Fire"
	},
	['futuresight'] = {
		num = 248,
		accuracy = 100,
		basePower = 120,
		category = "Special",
		id = "futuresight",
		name = "Future Sight",
		pp = 10,
		ignoreImmunity = true,
		isFutureMove = true,
		onTryHit = function(target, source)
			source.side:addSideCondition('futuremove')
			if source.side.sideConditions['futuremove'].positions[source.position] then return false end
			source.side.sideConditions['futuremove'].positions[source.position] = {
				duration = 3,
				move = 'futuresight',
				targetPosition = target.position,
				source = source,
				moveData = {
					name = "Future Sight",
					basePower = 120,
					category = "Special",
					ignoreImmunity = true,
					type = 'Psychic'
				}
			}
			self:add('-start', source, 'move = Future Sight')
			return null
		end,
		target = "normal",
		type = "Psychic"
	},
	['gastroacid'] = {
		num = 380,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "gastroacid",
		name = "Gastro Acid",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'gastroacid',
		onTryHit = function(pokemon)
			local bannedAbilities = {multitype=true, stancechange=true}
			if bannedAbilities[pokemon.ability] then return false end
		end,
		effect = {
			-- Ability suppression implemented in BattlePokemon:ignoringAbility()
			onStart = function(pokemon)
				self:add('-endability', pokemon)
				self:singleEvent('End', self:getAbility(pokemon.ability), pokemon.abilityData, pokemon, pokemon, 'gastroacid')
			end
		},
		target = "normal",
		type = "Poison"
	},
	['geargrind'] = {
		num = 544,
		accuracy = 85,
		basePower = 50,
		category = "Physical",
		id = "geargrind",
		name = "Gear Grind",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		multihit = 2,
		target = "normal",
		type = "Steel"
	},
	['geomancy'] = {
		num = 601,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "geomancy",
		name = "Geomancy",
		pp = 10,
		flags = {charge = true, nonsky = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				attacker:removeVolatile(move.id)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		boosts = {
			spa = 2,
			spd = 2,
			spe = 2
		},
		target = "self",
		type = "Fairy"
	},
	['gigadrain'] = {
		num = 202,
		accuracy = 100,
		basePower = 75,
		category = "Special",
		id = "gigadrain",
		name = "Giga Drain",
		pp = 10,
		flags = {protect = true, mirror = true, heal = true},
		drain = {1, 2},
		target = "normal",
		type = "Grass"
	},
	['gigaimpact'] = {
		num = 416,
		accuracy = 90,
		basePower = 150,
		category = "Physical",
		id = "gigaimpact",
		name = "Giga Impact",
		pp = 5,
		flags = {contact = true, recharge = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'mustrecharge'
		},
		target = "normal",
		type = "Normal"
	},
	['glaciate'] = {
		num = 549,
		accuracy = 95,
		basePower = 65,
		category = "Special",
		id = "glaciate",
		name = "Glaciate",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spe = -1
			}
		},
		target = "allAdjacentFoes",
		type = "Ice"
	},
	['glare'] = {
		num = 137,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "glare",
		name = "Glare",
		pp = 30,
		flags = {protect = true, reflectable = true, mirror = true},
		status = 'par',
		target = "normal",
		type = "Normal"
	},
	['grassknot'] = {
		num = 447,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			local targetWeight = target:getWeight()
			if targetWeight >= 200 then
				self:debug('120 bp')
				return 120
			elseif targetWeight >= 100 then
				self:debug('100 bp')
				return 100
			elseif targetWeight >= 50 then
				self:debug('80 bp')
				return 80
			elseif targetWeight >= 25 then
				self:debug('60 bp')
				return 60
			elseif targetWeight >= 10 then
				self:debug('40 bp')
				return 40
			end
			self:debug('20 bp')
			return 20
		end,
		category = "Special",
		id = "grassknot",
		name = "Grass Knot",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, nonsky = true},
		target = "normal",
		type = "Grass"
	},
	['grasspledge'] = {
		num = 520,
		accuracy = 100,
		basePower = 80,
		basePowerCallback = function(target, source, move)
			if move.sourceEffect == 'waterpledge' or move.sourceEffect == 'firepledge' then
				self:add('-combine')
				return 150
			end
			return 80
		end,
		category = "Special",
		id = "grasspledge",
		name = "Grass Pledge",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		onPrepareHit = function(target, source, move)
			for _, decision in pairs(self.queue) do
				if decision.move and decision.pokemon and decision.pokemon.isActive and not decision.pokemon.fainted then
					if decision.pokemon.side == source.side and (decision.move.id == 'waterpledge' or decision.move.id == 'firepledge') then
						self:prioritizeQueue(decision)
						self:add('-waiting', source, decision.pokemon)
						return null
					end
				end
			end
		end,
		onModifyMove = function(move)
			if move.sourceEffect == 'waterpledge' then
				move.type = 'Grass'
				move.hasSTAB = true
			end
			if move.sourceEffect == 'firepledge' then
				move.type = 'Fire'
				move.hasSTAB = true
			end
		end,
		onHit = function(target, source, move)
			if move.sourceEffect == 'waterpledge' then
				target.side:addSideCondition('grasspledge')
			end
			if move.sourceEffect == 'firepledge' then
				target.side:addSideCondition('firepledge')
			end
		end,
		effect = {
			duration = 4,
			onStart = function(targetSide)
				self:add('-sidestart', targetSide, 'Grass Pledge')
			end,
			onEnd = function(targetSide)
				self:add('-sideend', targetSide, 'Grass Pledge')
			end,
			onModifySpe = function(spe, pokemon)
				return self:chainModify(0.25)
			end
		},
		target = "normal",
		type = "Grass"
	},
	['grasswhistle'] = {
		num = 320,
		accuracy = 55,
		basePower = 0,
		category = "Status",
		id = "grasswhistle",
		name = "Grass Whistle",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true, sound = true, authentic = true},
		status = 'slp',
		target = "normal",
		type = "Grass"
	},
	['grassyterrain'] = {
		num = 580,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "grassyterrain",
		name = "Grassy Terrain",
		pp = 10,
		flags = {nonsky = true},
		terrain = 'grassyterrain',
		effect = {
			duration = 5,
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
				self:add('-fieldstart', 'move = Grassy Terrain')
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
			onEnd = function()
				self:add('-fieldend', 'move = Grassy Terrain')
			end
		},
		target = "all",
		type = "Grass"
	},
	['gravity'] = {
		num = 356,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "gravity",
		name = "Gravity",
		pp = 5,
		flags = {nonsky = true},
		pseudoWeather = 'gravity',
		effect = {
			duration = 5,
			onStart = function()
				self:add('-fieldstart', 'move = Gravity')
			end,
			onModifyAccuracy = function(accuracy)
				if type(accuracy) ~= 'number' then return end
				return accuracy * 5 / 3
			end,
			onDisableMove = function(pokemon)
				local disabledMoves = {'bounce', 'fly', 'flyingpress', 'highjumpkick', 'jumpkick', 'magnetrise', 'skydrop', 'splash', 'telekinesis'}
				for _, m in pairs(disabledMoves) do
					pokemon:disableMove(m)
				end
			end,
			onModifyPokemonPriority = 100,
			onModifyPokemon = function(pokemon)
				local applies = false
				if pokemon:removeVolatile('bounce') or pokemon:removeVolatile('fly') then
					applies = true
					self:cancelMove(pokemon)
					pokemon:removeVolatile('twoturnmove')
				end
				if pokemon.volatiles['skydrop'] then
					applies = true
					self:cancelMove(pokemon)

					if pokemon.volatiles['skydrop'].source then
						self:add('-end', pokemon.volatiles['twoturnmove'].source, 'Sky Drop', '[interrupt]')
					end
					pokemon:removeVolatile('skydrop')
					pokemon:removeVolatile('twoturnmove')
				end
				if pokemon.volatiles['magnetrise'] then
					applies = true
					pokemon.volatiles['magnetrise'] = nil
				end
				if pokemon.volatiles['telekinesis'] then
					applies = true
					pokemon.volatiles['telekinesis'] = nil
				end
				if applies then self:add('-activate', pokemon, 'Gravity') end
			end,
			onNegateImmunity = function(pokemon, type)
				if type == 'Ground' then return false end
			end,
			onBeforeMovePriority = 6,
			onBeforeMove = function(pokemon, target, move)
				if move.flags['gravity'] then
					self:add('cant', pokemon, 'move = Gravity', move)
					return false
				end
			end,
			onResidualOrder = 22,
			onEnd = function()
				self:add('-fieldend', 'move = Gravity')
			end
		},
		target = "all",
		type = "Psychic"
	},
	['growl'] = {
		num = 45,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "growl",
		name = "Growl",
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true, sound = true, authentic = true},
		boosts = {
			atk = -1
		},
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['growth'] = {
		num = 74,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "growth",
		name = "Growth",
		pp = 20,
		flags = {snatch = true},
		onModifyMove = function(move)
			if self:isWeather({'sunnyday', 'desolateland'}) then
				move.boosts = {atk = 2, spa = 2}
			end
		end,
		boosts = {
			atk = 1,
			spa = 1
		},
		target = "self",
		type = "Normal"
	},
	['grudge'] = {
		num = 288,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "grudge",
		name = "Grudge",
		pp = 5,
		flags = {authentic = true},
		volatileStatus = 'grudge',
		effect = {
			onStart = function(pokemon)
				self:add('-singlemove', pokemon, 'Grudge')
			end,
			onFaint = function(target, source, effect)
				self:debug('Grudge detected fainted pokemon')
				if Not(source) or Not(effect) then return end
				if effect.effectType == 'Move' and not effect.isFutureMove then
					for _, move in pairs(source.moveset) do
						if move.id == source.lastMove then
							move.pp = 0
							self:add('-activate', source, 'Grudge', self:getMove(source.lastMove).name)
						end
					end
				end
			end,
			onBeforeMovePriority = 100,
			onBeforeMove = function(pokemon)
				self:debug('removing Grudge before attack')
				pokemon:removeVolatile('grudge')
			end
		},
		target = "self",
		type = "Ghost"
	},
	['guardsplit'] = {
		num = 470,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "guardsplit",
		name = "Guard Split",
		pp = 10,
		flags = {protect = true},
		onHit = function(target, source)
			local newdef = math.floor((target.stats.def + source.stats.def) / 2)
			target.stats.def = newdef
			source.stats.def = newdef
			local newspd = math.floor((target.stats.spd + source.stats.spd) / 2)
			target.stats.spd = newspd
			source.stats.spd = newspd
			self:add('-activate', source, 'Guard Split', '[of] ' .. target)
		end,
		target = "normal",
		type = "Psychic"
	},
	['guardswap'] = {
		num = 385,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "guardswap",
		name = "Guard Swap",
		pp = 10,
		flags = {protect = true, mirror = true, authentic = true},
		onHit = function(target, source)
			local targetBoosts = { def = target.boosts['def'], spd = target.boosts['spd'] }
			local sourceBoosts = { def = source.boosts['def'], spd = source.boosts['spd'] }
			source:setBoost(targetBoosts)
			target:setBoost(sourceBoosts)
			self:add('-swapboost', source, target, 'def, spd', '[from] move = Guard Swap')
		end,
		target = "normal",
		type = "Psychic"
	},
	['guillotine'] = {
		num = 12,
		accuracy = 30,
		basePower = 0,
		category = "Physical",
		id = "guillotine",
		name = "Guillotine",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		ohko = true,
		target = "normal",
		type = "Normal"
	},
	['gunkshot'] = {
		num = 441,
		accuracy = 80,
		basePower = 120,
		category = "Physical",
		id = "gunkshot",
		name = "Gunk Shot",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'psn'
		},
		target = "normal",
		type = "Poison"
	},
	['gust'] = {
		num = 16,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "gust",
		name = "Gust",
		pp = 35,
		flags = {protect = true, mirror = true, distance = true},
		target = "any",
		type = "Flying"
	},
	['gyroball'] = {
		num = 360,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			local power = math.min(math.max(math.floor(25 * target:getStat('spe') / pokemon:getStat('spe')), 1), 150)
			self:debug(power .. ' bp')
			return power
		end,
		category = "Physical",
		id = "gyroball",
		name = "Gyro Ball",
		pp = 5,
		flags = {bullet = true, contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Steel"
	},
	['hail'] = {
		num = 258,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "hail",
		name = "Hail",
		pp = 10,
		weather = 'hail',
		target = "all",
		type = "Ice"
	},
	['hammerarm'] = {
		num = 359,
		accuracy = 90,
		basePower = 100,
		category = "Physical",
		id = "hammerarm",
		name = "Hammer Arm",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		self = {
			boosts = {
				spe = -1
			}
		},
		target = "normal",
		type = "Fighting"
	},
	['happyhour'] = {
		num = 603,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "happyhour",
		name = "Happy Hour",
		pp = 30,
		onTryHit = function(target, source)
			self:add('-activate', target, 'move = Happy Hour')
			return null
		end,
		target = "allySide",
		type = "Normal"
	},
	['harden'] = {
		num = 106,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "harden",
		name = "Harden",
		pp = 30,
		flags = {snatch = true},
		boosts = {
			def = 1
		},
		target = "self",
		type = "Normal"
	},
	['haze'] = {
		num = 114,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "haze",
		name = "Haze",
		pp = 30,
		flags = {authentic = true},
		onHitField = function()
			self:add('-clearallboost')
			for _, side in pairs(self.sides) do
				for _, pokemon in pairs(side.active) do
					if pokemon ~= null then
						pokemon:clearBoosts()
					end
				end
			end
		end,
		target = "all",
		type = "Ice"
	},
	['headcharge'] = {
		num = 543,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "headcharge",
		name = "Head Charge",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		recoil = {1, 4},
		target = "normal",
		type = "Normal"
	},
	['headsmash'] = {
		num = 457,
		accuracy = 80,
		basePower = 150,
		category = "Physical",
		id = "headsmash",
		name = "Head Smash",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		recoil = {1, 2},
		target = "normal",
		type = "Rock"
	},
	['headbutt'] = {
		num = 29,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "headbutt",
		name = "Headbutt",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Normal"
	},
	['healbell'] = {
		num = 215,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "healbell",
		name = "Heal Bell",
		pp = 5,
		flags = {snatch = true, sound = true, distance = true, authentic = true},
		onHit = function(pokemon, source)
			for _, ally in pairs(pokemon.side.pokemon) do
				ally.status = ''
			end
			self:add('-cureteam', source, '[from] move = HealBell')
		end,
		target = "allyTeam",
		type = "Normal"
	},
	['healblock'] = {
		num = 377,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "healblock",
		name = "Heal Block",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'healblock',
		effect = {
			duration = 5,
			onStart = function(pokemon)
				self:add('-start', pokemon, 'move = Heal Block')
			end,
			onDisableMove = function(pokemon)
				local disabledMoves = {healingwish=true, lunardance=true, rest=true, swallow=true, wish=true}
				for _, move in pairs(pokemon.moveset) do
					local moveData = self:getMove(move.id)
					if disabledMoves[move.id] or moveData.heal or moveData.drain then
						pokemon:disableMove(move.id)
					end
				end
			end,
			onBeforeMovePriority = 6,
			onBeforeMove = function(pokemon, target, move)
				local disabledMoves = {healingwish=true, lunardance=true, rest=true, swallow=true, wish=true}
				if disabledMoves[move.id] or move.heal or move.drain then
					self:add('cant', pokemon, 'move = Heal Block', move)
					return false
				end
			end,
			onResidualOrder = 17,
			onEnd = function(pokemon)
				self:add('-end', pokemon, 'move = Heal Block')
			end,
			onTryHeal = false
		},
		target = "allAdjacentFoes",
		type = "Psychic"
	},
	['healorder'] = {
		num = 456,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "healorder",
		name = "Heal Order",
		pp = 10,
		flags = {snatch = true, heal = true},
		heal = {1, 2},
		target = "self",
		type = "Bug"
	},
	['healpulse'] = {
		num = 505,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "healpulse",
		name = "Heal Pulse",
		pp = 10,
		flags = {protect = true, pulse = true, reflectable = true, distance = true, heal = true},
		onHit = function(target, source)
			if source:hasAbility('megalauncher') then
				return self:heal(self:modify(target.maxhp, 0.75))
			else
				return self:heal(math.ceil(target.maxhp * 0.5))
			end
		end,
		target = "any",
		type = "Psychic"
	},
	['healingwish'] = {
		num = 361,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "healingwish",
		name = "Healing Wish",
		pp = 10,
		flags = {snatch = true, heal = true},
		onTryHit = function(pokemon, target, move)
			if not pokemon.side:canSwitch(pokemon.position) then
				move.selfdestruct = nil
				return false
			end
		end,
		selfdestruct = true,
		sideCondition = 'healingwish',
		effect = {
			duration = 2,
			onStart = function(side, source)
				self:debug('Healing Wish started on ' .. side.name)
				self.effectData.positions = {}
				for i = 1, #side.active do
					self.effectData.positions[i] = false
				end
				self.effectData.positions[source.position] = true
			end,
			onRestart = function(side, source)
				self.effectData.positions[source.position] = true
			end,
			onSwitchInPriority = 1,
			onSwitchIn = function(target)
				if not self.effectData.positions[target.position] then return end
				if not target.fainted then
					target:heal(target.maxhp)
					target:setStatus('')
					self:add('-heal', target, target.getHealth, '[from] move = Healing Wish')
					self.effectData.positions[target.position] = false
				end
				if not indexOf(self.effectData.positions, true) then
					target.side:removeSideCondition('healingwish')
				end
			end
		},
		target = "self",
		type = "Psychic"
	},
	['heartstamp'] = {
		num = 531,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "heartstamp",
		name = "Heart Stamp",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Psychic"
	},
	['heartswap'] = {
		num = 391,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "heartswap",
		name = "Heart Swap",
		pp = 10,
		flags = {protect = true, mirror = true, authentic = true},
		onHit = function(target, source)
			local targetBoosts = {}
			local sourceBoosts = {}
			for stat, boost in pairs(target.boosts) do
				targetBoosts[stat] = boost
				sourceBoosts[stat] = source.boosts[stat]
			end
			target:setBoost(sourceBoosts)
			source:setBoost(targetBoosts)
			self:add('-swapboost', source, target, '[from] move = Heart Swap')
		end,
		target = "normal",
		type = "Psychic"
	},
	['heatcrash'] = {
		num = 535,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			local targetWeight = target:getWeight()
			local pokemonWeight = pokemon:getWeight()
			if pokemonWeight > targetWeight * 5 then
				return 120
			elseif pokemonWeight > targetWeight * 4 then
				return 100
			elseif pokemonWeight > targetWeight * 3 then
				return 80
			elseif pokemonWeight > targetWeight * 2 then
				return 60
			end
			return 40
		end,
		category = "Physical",
		id = "heatcrash",
		name = "Heat Crash",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, nonsky = true},
		target = "normal",
		type = "Fire"
	},
	['heatwave'] = {
		num = 257,
		accuracy = 90,
		basePower = 95,
		category = "Special",
		id = "heatwave",
		name = "Heat Wave",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'brn'
		},
		target = "allAdjacentFoes",
		type = "Fire"
	},
	['heavyslam'] = {
		num = 484,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			local targetWeight = target:getWeight()
			local pokemonWeight = pokemon:getWeight()
			if pokemonWeight > targetWeight * 5 then
				return 120
			elseif pokemonWeight > targetWeight * 4 then
				return 100
			elseif pokemonWeight > targetWeight * 3 then
				return 80
			elseif pokemonWeight > targetWeight * 2 then
				return 60
			end
			return 40
		end,
		category = "Physical",
		id = "heavyslam",
		name = "Heavy Slam",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, nonsky = true},
		target = "normal",
		type = "Steel"
	},
	['helpinghand'] = {
		num = 270,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "helpinghand",
		name = "Helping Hand",
		pp = 20,
		priority = 5,
		flags = {authentic = true},
		volatileStatus = 'helpinghand',
		effect = {
			duration = 1,
			onStart = function(target, source)
				self.effectData.multiplier = 1.5
				self:add('-singleturn', target, 'Helping Hand', '[of] ' .. source)
			end,
			onRestart = function(target, source)
				self.effectData.multiplier = self.effectData.multiplier * 1.5
				self:add('-singleturn', target, 'Helping Hand', '[of] ' .. source)
			end,
			onBasePowerPriority = 3,
			onBasePower = function(basePower)
				self:debug('Boosting from Helping Hand = ' .. self.effectData.multiplier)
				return self:chainModify(self.effectData.multiplier)
			end
		},
		target = "adjacentAlly",
		type = "Normal"
	},
	['hex'] = {
		num = 506,
		accuracy = 100,
		basePower = 65,
		basePowerCallback = function(pokemon, target)
			if target.status and target.status ~= '' then return 130 end
			return 65
		end,
		category = "Special",
		id = "hex",
		name = "Hex",
		pp = 10,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Ghost"
	},
	['hiddenpower'] = {
		num = 237,
		accuracy = 100,
		basePower = 60,
		category = "Special",
		id = "hiddenpower",
		name = "Hidden Power",
		pp = 15,
		flags = {protect = true, mirror = true},
		onModifyMove = function(move, pokemon)
			move.type = pokemon.hpType or 'Dark'
		end,
		target = "normal",
		type = "Normal"
	},
	['highjumpkick'] = {
		num = 136,
		accuracy = 90,
		basePower = 130,
		category = "Physical",
		id = "highjumpkick",
		name = "High Jump Kick",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, gravity = true,striker = true},
		hasCustomRecoil = true,
		onMoveFail = function(target, source, move)
			self:damage(source.maxhp / 2, source, source, 'highjumpkick')
		end,
		target = "normal",
		type = "Fighting"
	},
	['holdback'] = {
		num = 610,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "holdback",
		name = "Hold Back",
		pp = 40,
		flags = {contact = true, protect = true, mirror = true},
		noFaint = true,
		target = "normal",
		type = "Normal"
	},
	['holdhands'] = {
		num = 615,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "holdhands",
		name = "Hold Hands",
		pp = 40,
		flags = {authentic = true},
		onTryHit = function(target, source)
			return null
		end,
		target = "adjacentAlly",
		type = "Normal"
	},
	['honeclaws'] = {
		num = 468,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "honeclaws",
		name = "Hone Claws",
		pp = 15,
		flags = {snatch = true},
		boosts = {
			atk = 1,
			accuracy = 1
		},
		target = "self",
		type = "Dark"
	},
	['hornattack'] = {
		num = 30,
		accuracy = 100,
		basePower = 65,
		category = "Physical",
		id = "hornattack",
		name = "Horn Attack",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['horndrill'] = {
		num = 32,
		accuracy = 30,
		basePower = 0,
		category = "Physical",
		id = "horndrill",
		name = "Horn Drill",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		ohko = true,
		target = "normal",
		type = "Normal"
	},
	['hornleech'] = {
		num = 532,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		id = "hornleech",
		name = "Horn Leech",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, heal = true},
		drain = {1, 2},
		target = "normal",
		type = "Grass"
	},
	['howl'] = {
		num = 336,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "howl",
		name = "Howl",
		pp = 40,
		flags = {snatch = true},
		boosts = {
			atk = 1
		},
		target = "self",
		type = "Normal"
	},
	['hurricane'] = {
		num = 542,
		accuracy = 85,
		basePower = 110,
		category = "Special",
		id = "hurricane",
		name = "Hurricane",
		pp = 10,
		flags = {protect = true, mirror = true, distance = true},
		onModifyMove = function(move)
			if self:isWeather({'raindance', 'primordialsea'}) then
				move.accuracy = true
			elseif self:isWeather({'sunnyday', 'desolateland'}) then
				move.accuracy = 50
			end
		end,
		secondary = {
			chance = 30,
			volatileStatus = 'confusion'
		},
		target = "any",
		type = "Flying"
	},
	['hydrocannon'] = {
		num = 308,
		accuracy = 90,
		basePower = 150,
		category = "Special",
		id = "hydrocannon",
		name = "Hydro Cannon",
		pp = 5,
		flags = {recharge = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'mustrecharge'
		},
		target = "normal",
		type = "Water"
	},
	['hydropump'] = {
		num = 56,
		accuracy = 85,
		basePower = 110,
		category = "Special",
		id = "hydropump",
		name = "Hydro Pump",
		pp = 5,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Water"
	},
	['hyperbeam'] = {
		num = 63,
		accuracy = 90,
		basePower = 150,
		category = "Special",
		id = "hyperbeam",
		name = "Hyper Beam",
		pp = 5,
		flags = {recharge = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'mustrecharge'
		},
		target = "normal",
		type = "Normal"
	},
	['hyperfang'] = {
		num = 158,
		accuracy = 90,
		basePower = 80,
		category = "Physical",
		id = "hyperfang",
		name = "Hyper Fang",
		pp = 15,
		flags = {bite = true, contact = true, protect = true, mirror = true},
		secondary = {
			chance = 10,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Normal"
	},
	['hyperspacefury'] = {
		num = 621,
		accuracy = true,
		basePower = 100,
		category = "Physical",
		id = "hyperspacefury",
		name = "Hyperspace Fury",
		pp = 5,
		flags = {mirror = true, authentic = true},
		breaksProtect = true,
		onTry = function(pokemon)
			if pokemon.species == 'Hoopa-Unbound' and pokemon.baseTemplate.species == pokemon.species then return end
			self:add('-hint', "Only a Hoopa in its Unbound forme can use this move.")
			if pokemon.baseTemplate.species == 'Hoopa' then
				self:add('-fail', pokemon, 'move: Hyperspace Fury', '[forme]')
				return null
			end
			self:add('-fail', pokemon, 'move: Hyperspace Fury')
			return null
		end,
		self = {
			boosts = {
				def = -1
			}
		},
		target = "normal",
		type = "Dark"
	},
	scaleshot = {
		num = 799,
		accuracy = 90,
		basePower = 25,
		category = "Physical",
		name = "Scale Shot",
		pp = 20,
		flags = {protect = true, mirror = true},
		multihit = {2, 5},
		self = {
			boosts = {
				def = -1,
				spe = 1,
			},
		},
		target = "normal",
		type = "Dragon",
	},
	['hyperspacehole'] = {
		num = 593,
		accuracy = true,
		basePower = 80,
		category = "Special",
		id = "hyperspacehole",
		name = "Hyperspace Hole",
		pp = 5,
		flags = {mirror = true, authentic = true},
		breaksProtect = true,
		target = "normal",
		type = "Psychic"
	},
	['hypervoice'] = {
		num = 304,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "hypervoice",
		name = "Hyper Voice",
		pp = 10,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['hypnosis'] = {
		num = 95,
		accuracy = 60,
		basePower = 0,
		category = "Status",
		id = "hypnosis",
		name = "Hypnosis",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		status = 'slp',
		target = "normal",
		type = "Psychic"
	},
	['iceball'] = {
		num = 301,
		accuracy = 90,
		basePower = 30,
		basePowerCallback = function(pokemon, target)
			local bp = 30
			local bpTable = {30, 60, 120, 240, 480}
			if pokemon.volatiles.iceball and pokemon.volatiles.iceball.hitCount then
				bp = bpTable[pokemon.volatiles.iceball.hitCount+1] or 30
			end
			pokemon:addVolatile('iceball')
			if pokemon.volatiles.defensecurl then
				bp = bp * 2
			end
			self:debug("Ice Ball bp = " .. bp)
			return bp
		end,
		category = "Physical",
		id = "iceball",
		name = "Ice Ball",
		pp = 20,
		flags = {bullet = true, contact = true, protect = true, mirror = true},
		effect = {
			duration = 2,
			onLockMove = 'iceball',
			onStart = function()
				self.effectData.hitCount = 1
			end,
			onRestart = function()
				self.effectData.hitCount = self.effectData.hitCount + 1
				if self.effectData.hitCount < 5 then
					self.effectData.duration = 2
				end
			end,
			onResidual = function(target)
				if target.lastMove == 'struggle' then
					-- don't lock
					target.volatiles['iceball'] = nil
				end
			end,
		},
		target = "normal",
		type = "Ice"
	},
	['icebeam'] = {
		num = 58,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "icebeam",
		name = "Ice Beam",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'frz'
		},
		target = "normal",
		type = "Ice"
	},
	['iceburn'] = {
		num = 554,
		accuracy = 90,
		basePower = 140,
		category = "Special",
		id = "iceburn",
		name = "Ice Burn",
		pp = 5,
		flags = {charge = true, protect = true, mirror = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		secondary = {
			chance = 30,
			status = 'brn'
		},
		target = "normal",
		type = "Ice"
	},
	['icefang'] = {
		num = 423,
		accuracy = 95,
		basePower = 65,
		category = "Physical",
		id = "icefang",
		name = "Ice Fang",
		pp = 15,
		flags = {bite = true, contact = true, protect = true, mirror = true},
		secondaries = { {
			chance = 10,
			status = 'frz'
		}, {
				chance = 10,
				volatileStatus = 'flinch'
			}
		},
		target = "normal",
		type = "Ice"
	},
	['icepunch'] = {
		num = 8,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		id = "icepunch",
		name = "Ice Punch",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		secondary = {
			chance = 10,
			status = 'frz'
		},
		target = "normal",
		type = "Ice"
	},
	['iceshard'] = {
		num = 420,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "iceshard",
		name = "Ice Shard",
		pp = 30,
		priority = 1,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Ice"
	},
	['iciclecrash'] = {
		num = 556,
		accuracy = 90,
		basePower = 85,
		category = "Physical",
		id = "iciclecrash",
		name = "Icicle Crash",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Ice"
	},
	['iciclespear'] = {
		num = 333,
		accuracy = 100,
		basePower = 25,
		category = "Physical",
		id = "iciclespear",
		name = "Icicle Spear",
		pp = 30,
		flags = {protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Ice"
	},
	['icywind'] = {
		num = 196,
		accuracy = 95,
		basePower = 55,
		category = "Special",
		id = "icywind",
		name = "Icy Wind",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spe = -1
			}
		},
		target = "allAdjacentFoes",
		type = "Ice"
	},
	['imprison'] = {
		num = 286,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "imprison",
		name = "Imprison",
		pp = 10,
		flags = {snatch = true, authentic = true},
		volatileStatus = 'imprison',
		effect = {
			noCopy = true,
			onStart = function(target)
				self:add('-start', target, 'move = Imprison')
			end,
			onFoeDisableMove = function(pokemon)
				for _, move in pairs(self.effectData.source.moveset) do
					if move.id ~= 'struggle' then
						pokemon:disableMove(move.id, true)
					end
				end
				pokemon.maybeDisabled = true
			end,
			onFoeBeforeMovePriority = 4,
			onFoeBeforeMove = function(attacker, defender, move)
				if move.id ~= 'struggle' and self.effectData.source:hasMove(move.id) then
					self:add('cant', attacker, 'move = Imprison', move)
					return false
				end
			end
		},
		pressureTarget = "foeSide",
		target = "self",
		type = "Psychic"
	},
	['incinerate'] = {
		num = 510,
		accuracy = 100,
		basePower = 60,
		category = "Special",
		id = "incinerate",
		name = "Incinerate",
		pp = 15,
		flags = {protect = true, mirror = true},
		onHit = function(pokemon, source)
			local item = pokemon:getItem()
			if (item.isBerry or item.isGem) and pokemon:takeItem(source) then
				self:add('-enditem', pokemon, item.name, '[from] move = Incinerate')
			end
		end,
		target = "allAdjacentFoes",
		type = "Fire"
	},
	['inferno'] = {
		num = 517,
		accuracy = 50,
		basePower = 100,
		category = "Special",
		id = "inferno",
		name = "Inferno",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['infestation'] = {
		num = 611,
		accuracy = 100,
		basePower = 20,
		category = "Special",
		id = "infestation",
		name = "Infestation",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Bug"
	},
	['ingrain'] = {
		num = 275,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "ingrain",
		name = "Ingrain",
		pp = 20,
		flags = {snatch = true, nonsky = true},
		volatileStatus = 'ingrain',
		effect = {
			onStart = function(pokemon)
				self:add('-start', pokemon, 'move = Ingrain')
			end,
			onResidualOrder = 7,
			onResidual = function(pokemon)
				self:heal(pokemon.maxhp / 16)
			end,
			onModifyPokemon = function(pokemon)
				pokemon:tryTrap()
			end,
			onNegateImmunity = function(pokemon, type)
				if type == 'Ground' then return false end
			end,
			onDragOut = function(pokemon)
				self:add('-activate', pokemon, 'move = Ingrain')
				return null
			end
		},
		target = "self",
		type = "Grass"
	},
	['iondeluge'] = {
		num = 569,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "iondeluge",
		name = "Ion Deluge",
		pp = 25,
		priority = 1,
		pseudoWeather = 'iondeluge',
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-fieldactivate', 'move = Ion Deluge')
			end,
			onModifyMovePriority = -2,
			onModifyMove = function(move)
				if move.type == 'Normal' then
					move.type = 'Electric'
					self:debug(move.name .. "'s type changed to Electric")
				end
			end
		},
		target = "all",
		type = "Electric"
	},
	['irondefense'] = {
		num = 334,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "irondefense",
		name = "Iron Defense",
		pp = 15,
		flags = {snatch = true},
		boosts = {
			def = 2
		},
		target = "self",
		type = "Steel"
	},
	['ironhead'] = {
		num = 442,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "ironhead",
		name = "Iron Head",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Steel"
	},
	['irontail'] = {
		num = 231,
		accuracy = 90,
		basePower = 100,
		category = "Physical",
		id = "irontail",
		name = "Iron Tail",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			boosts = {
				def = -1
			}
		},
		target = "normal",
		type = "Steel"
	},
	['judgment'] = {
		num = 449,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		id = "judgment",
		name = "Judgment",
		pp = 10,
		flags = {protect = true, mirror = true},
		onModifyMove = function(move, pokemon)
			move.type = self:runEvent('Plate', pokemon, nil, 'judgement', 'Normal')
		end,
		target = "normal",
		type = "Normal"
	},
	['jumpkick'] = {
		num = 26,
		accuracy = 100,
		basePower = 100,
		category = "Physical",
		id = "jumpkick",
		name = "Jump Kick",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, gravity = true,striker = true},
		hasCustomRecoil = true,
		onMoveFail = function(target, source, move)
			self:damage(source.maxhp / 2, source, source, 'jumpkick')
		end,
		target = "normal",
		type = "Fighting"
	},
	['karatechop'] = {
		num = 2,
		accuracy = 100,
		basePower = 50,
		category = "Physical",
		id = "karatechop",
		name = "Karate Chop",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		critRatio = 2,
		target = "normal",
		type = "Fighting"
	},
	['kinesis'] = {
		num = 134,
		accuracy = 80,
		basePower = 0,
		category = "Status",
		id = "kinesis",
		name = "Kinesis",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			accuracy = -1
		},
		target = "normal",
		type = "Psychic"
	},
	['kingsshield'] = {
		num = 588,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "kingsshield",
		name = "King's Shield",
		pp = 10,
		priority = 4,
		stallingMove = true,
		volatileStatus = 'kingsshield',
		onTryHit = function(pokemon)
			return not Not(self:willAct()) and not Not(self:runEvent('StallMove', pokemon))
		end,
		onHit = function(pokemon)
			pokemon:addVolatile('stall')
		end,
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-singleturn', target, 'Protect')
			end,
			onTryHitPriority = 3,
			onTryHit = function(target, source, move)
				if not move.flags['protect'] or move.category == 'Status' then return end
				self:add('-activate', target, 'Protect', source)
				local lockedmove = source:getVolatile('lockedmove')
				if lockedmove then
					-- Outrage counter is reset
					if source.volatiles['lockedmove'].duration == 2 then
						source.volatiles['lockedmove'] = nil
					end
				end
				if move.flags['contact'] then
					self:boost({atk=-2}, source, target, self:getMove('kingsshield'))
				end
				return null
			end
		},
		target = "self",
		type = "Steel"
	},
	['knockoff'] = {
		num = 282,
		accuracy = 100,
		basePower = 65,
		category = "Physical",
		id = "knockoff",
		name = "Knock Off",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon, target)
			local item = target:getItem()
			local noKnockOff = item.onTakeItem and item.onTakeItem(item, target) == false
			if item.id and not noKnockOff then
				return self:chainModify(1.5)
			end
		end,
		onAfterHit = function(target, source)
			if source.hp > 0 then
				local item = target:takeItem()
				if item and item.name and item.name ~= '' then
					self:add('-enditem', target, item.name, '[from] move = Knock Off', '[of] ' .. source)
				end
			end
		end,
		target = "normal",
		type = "Dark"
	},
	['landswrath'] = {
		num = 616,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "landswrath",
		name = "Land's Wrath",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		target = "allAdjacentFoes",
		type = "Ground"
	},
	['lastresort'] = {
		num = 387,
		accuracy = 100,
		basePower = 140,
		category = "Physical",
		id = "lastresort",
		name = "Last Resort",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		onTryHit = function(target, source)
			if #source.moveset == 1 then return false end -- Last Resort fails unless the user knows at least 2 moves
			local hasLastResort = false -- User must actually have Last Resort for it to succeed
			for _, move in pairs(source.moveset) do
				if move.id == 'lastresort' then
					hasLastResort = true
				elseif not move.used then
					return false
				end
			end
			return hasLastResort
		end,
		target = "normal",
		type = "Normal"
	},
	['lavaplume'] = {
		num = 436,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "lavaplume",
		name = "Lava Plume",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'brn'
		},
		target = "allAdjacent",
		type = "Fire"
	},
	['leafblade'] = {
		num = 348,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "leafblade",
		name = "Leaf Blade",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		critRatio = 2,
		target = "normal",
		type = "Grass"
	},
	['leafstorm'] = {
		num = 437,
		accuracy = 90,
		basePower = 130,
		category = "Special",
		id = "leafstorm",
		name = "Leaf Storm",
		pp = 5,
		flags = {protect = true, mirror = true},
		self = {
			boosts = {
				spa = -2
			}
		},
		target = "normal",
		type = "Grass"
	},
	['leaftornado'] = {
		num = 536,
		accuracy = 90,
		basePower = 65,
		category = "Special",
		id = "leaftornado",
		name = "Leaf Tornado",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 50,
			boosts = {
				accuracy = -1
			}
		},
		target = "normal",
		type = "Grass"
	},
	['leechlife'] = {
		num = 141,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "leechlife",
		name = "Leech Life",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, heal = true},
		drain = {1, 2},
		target = "normal",
		type = "Bug"
	},
	['leechseed'] = {
		num = 73,
		accuracy = 90,
		basePower = 0,
		category = "Status",
		id = "leechseed",
		name = "Leech Seed",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'leechseed',
		effect = {
			onStart = function(target)
				self:add('-start', target, 'move = Leech Seed')
			end,
			onResidualOrder = 8,
			onResidual = function(pokemon)
				local target = self.effectData.source.side.active[pokemon.volatiles['leechseed'].sourcePosition]
				if Not(target) or target.fainted or target.hp <= 0 then
					self:debug('Nothing to leech into')
					return
				end
				local damage = self:damage(pokemon.maxhp / 8, pokemon, target)
				if damage and damage > 0 then
					self:heal(damage, target, pokemon)
				end
			end
		},
		onTryHit = function(target)
			if target:hasType('Grass') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		target = "normal",
		type = "Grass"
	},
	['leer'] = {
		num = 43,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "leer",
		name = "Leer",
		pp = 30,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			def = -1
		},
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['lick'] = {
		num = 122,
		accuracy = 100,
		basePower = 30,
		category = "Physical",
		id = "lick",
		name = "Lick",
		pp = 30,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "normal",
		type = "Ghost"
	},
	['lightofruin'] = {
		num = 617,
		accuracy = 90,
		basePower = 140,
		category = "Special",
		id = "lightofruin",
		name = "Light of Ruin",
		pp = 5,
		flags = {protect = true, mirror = true},
		isUnreleased = true,
		recoil = {1, 2},
		target = "normal",
		type = "Fairy"
	},
	['lightscreen'] = {
		num = 113,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "lightscreen",
		name = "Light Screen",
		pp = 30,
		flags = {snatch = true},
		sideCondition = 'lightscreen',
		effect = {
			duration = 5,
			durationCallback = function(target, source, effect)
				if source and source ~= null and source:hasItem('lightclay') then
					return 8
				end
				return 5
			end,
			onAnyModifyDamage = function(damage, source, target, move)
				if target ~= source and target.side == self.effectData.target and self:getCategory(move) == 'Special' then
					if not move.crit and not move.infiltrates then
						self:debug('Light Screen weaken')
						if #target.side.active > 1 then return self:chainModify(0xA8F, 0x1000) end
						return self:chainModify(0.5)
					end
				end
			end,
			onStart = function(side)
				self:add('-sidestart', side, 'move = Light Screen')
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 1,
			onEnd = function(side)
				self:add('-sideend', side, 'move = Light Screen')
			end
		},
		target = "allySide",
		type = "Psychic"
	},
	['lockon'] = {
		num = 199,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "lockon",
		name = "Lock-On",
		pp = 5,
		flags = {protect = true, mirror = true},
		onTryHit = function(target, source)
			if source.volatiles['lockon'] then return false end
		end,
		onHit = function(target, source)
			source:addVolatile('lockon', target)
			self:add('-activate', source, 'move: Lock-On', '[of] ' .. target)
		end,
		effect = {
			noCopy = true, -- doesn't get copied by Baton Pass
			duration = 2,
			onSourceAccuracy = function(accuracy, target, source, move)
				if move and source == self.effectData.target and target == self.effectData.source then return true end
			end
		},
		target = "normal",
		type = "Normal"
	},
	['lovelykiss'] = {
		num = 142,
		accuracy = 75,
		basePower = 0,
		category = "Status",
		id = "lovelykiss",
		name = "Lovely Kiss",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		status = 'slp',
		target = "normal",
		type = "Normal"
	},
	['lowkick'] = {
		num = 67,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			local targetWeight = target:getWeight()
			if targetWeight >= 200 then
				return 120
			elseif targetWeight >= 100 then
				return 100
			elseif targetWeight >= 50 then
				return 80
			elseif targetWeight >= 25 then
				return 60
			elseif targetWeight >= 10 then
				return 40
			end
			return 20
		end,
		category = "Physical",
		id = "lowkick",
		name = "Low Kick",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		target = "normal",
		type = "Fighting"
	},
	['lowsweep'] = {
		num = 490,
		accuracy = 100,
		basePower = 65,
		category = "Physical",
		id = "lowsweep",
		name = "Low Sweep",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spe = -1
			}
		},
		target = "normal",
		type = "Fighting"
	},
	['luckychant'] = {
		num = 381,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "luckychant",
		name = "Lucky Chant",
		pp = 30,
		flags = {snatch = true},
		sideCondition = 'luckychant',
		effect = {
			duration = 5,
			onStart = function(side)
				self:add('-sidestart', side, 'move = Lucky Chant') -- "The Lucky Chant shielded [side.name]'s team from critical hits!"
			end,
			onCriticalHit = false,
			onResidualOrder = 21,
			onResidualSubOrder = 5,
			onEnd = function(side)
				self:add('-sideend', side, 'move = Lucky Chant') -- "[side.name]'s team's Lucky Chant wore off!"
			end
		},
		target = "allySide",
		type = "Normal"
	},
	['lunardance'] = {
		num = 461,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "lunardance",
		name = "Lunar Dance",
		pp = 10,
		flags = {snatch = true, heal = true},
		onTryHit = function(pokemon, target, move)
			if not pokemon.side:canSwitch(pokemon.position) then
				move.selfdestruct = nil
				return false
			end
		end,
		selfdestruct = true,
		sideCondition = 'lunardance',
		effect = {
			duration = 2,
			onStart = function(side, source)
				self:debug('Lunar Dance started on ' .. side.name)
				self.effectData.positions = {}
				for i = 1, #side.active do
					self.effectData.positions[i] = false
				end
				self.effectData.positions[source.position] = true
			end,
			onSwitchInPriority = 1,
			onSwitchIn = function(target)
				if target.position ~= self.effectData.sourcePosition then return end
				if not target.fainted then
					target:heal(target.maxhp)
					target:setStatus('')
					for _, move in pairs(target.moveset) do
						move.pp = move.maxpp
					end
					self:add('-heal', target, target.getHealth, '[from] move = Lunar Dance')
					self.effectData.positions[target.position] = false
				end
				if not indexOf(self.effectData.positions, true) then
					target.side:removeSideCondition('lunardance')
				end
			end
		},
		target = "self",
		type = "Psychic"
	},
	['lusterpurge'] = {
		num = 295,
		accuracy = 100,
		basePower = 70,
		category = "Special",
		id = "lusterpurge",
		name = "Luster Purge",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 50,
			boosts = {
				spd = -1
			}
		},
		target = "normal",
		type = "Psychic"
	},
	['machpunch'] = {
		num = 183,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "machpunch",
		name = "Mach Punch",
		pp = 30,
		priority = 1,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		target = "normal",
		type = "Fighting"
	},
	['magiccoat'] = {
		num = 277,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "magiccoat",
		name = "Magic Coat",
		pp = 15,
		priority = 4,
		volatileStatus = 'magiccoat',
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-singleturn', target, 'move = Magic Coat')
			end,
			onTryHitPriority = 2,
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
			end
		},
		target = "self",
		type = "Psychic"
	},
	['magicroom'] = {
		num = 478,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "magicroom",
		name = "Magic Room",
		pp = 10,
		flags = {mirror = true},
		onHitField = function(target, source, effect)
			if self.pseudoWeather['magicroom'] then
				self:removePseudoWeather('magicroom', source, effect, '[of] ' .. source)
			else
				self:addPseudoWeather('magicroom', source, effect, '[of] ' .. source)
			end
		end,
		effect = {
			duration = 5,
			onStart = function(target, source)
				self:add('-fieldstart', 'move = Magic Room', '[of] ' .. source)
			end,
			-- Item suppression implemented in BattlePokemon:ignoringItem()
			onResidualOrder = 25,
			onEnd = function()
				self:add('-fieldend', 'move = Magic Room', '[of] ' .. self.effectData.source)
			end
		},
		target = "all",
		type = "Psychic"
	},
	['magicalleaf'] = {
		num = 345,
		accuracy = true,
		basePower = 60,
		category = "Special",
		id = "magicalleaf",
		name = "Magical Leaf",
		pp = 20,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Grass"
	},
	['magmastorm'] = {
		num = 463,
		accuracy = 85,
		basePower = 100,
		category = "Special",
		id = "magmastorm",
		name = "Magma Storm",
		pp = 5,
		flags = {protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Fire"
	},
	['magnetbomb'] = {
		num = 443,
		accuracy = true,
		basePower = 60,
		category = "Physical",
		id = "magnetbomb",
		name = "Magnet Bomb",
		pp = 20,
		flags = {bullet = true, protect = true, mirror = true},
		target = "normal",
		type = "Steel"
	},
	['magneticflux'] = {
		num = 602,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "magneticflux",
		name = "Magnetic Flux",
		pp = 20,
		flags = {snatch = true, distance = true, authentic = true},
		onHitSide = function(side, source)
			local targets = {}
			for _, pokemon in pairs(side.active) do
				if pokemon:hasAbility('plus', 'minus') then
					table.insert(targets, pokemon)
				end
			end
			if #targets == 0 then return false end
			for _, target in pairs(targets) do
				self:boost({def = 1, spd = 1}, target, source, 'move: Magnetic Flux') -- todo boost order
			end
		end,
		target = "allySide",
		type = "Electric"
	},
	['magnetrise'] = {
		num = 393,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "magnetrise",
		name = "Magnet Rise",
		pp = 10,
		flags = {snatch = true, gravity = true},
		volatileStatus = 'magnetrise',
		effect = {
			duration = 5,
			onStart = function(target)
				if target.volatiles['smackdown'] or target.volatiles['ingrain'] then return false end
				self:add('-start', target, 'Magnet Rise')
			end,
			onImmunity = function(type)
				if type == 'Ground' then return false end
			end,
			onResidualOrder = 15,
			onEnd = function(target)
				self:add('-end', target, 'Magnet Rise')
			end
		},
		target = "self",
		type = "Electric"
	},
	['magnitude'] = {
		num = 222,
		accuracy = 100,
		basePower = 0,
		category = "Physical",
		id = "magnitude",
		name = "Magnitude",
		pp = 30,
		flags = {protect = true, mirror = true, nonsky = true},
		onModifyMove = function(move, pokemon)
			local i = math.random(100)
			if i <= 5 then
				move.magnitude = 4
				move.basePower = 10
			elseif i <= 15 then
				move.magnitude = 5
				move.basePower = 30
			elseif i <= 35 then
				move.magnitude = 6
				move.basePower = 50
			elseif i <= 65 then
				move.magnitude = 7
				move.basePower = 70
			elseif i <= 85 then
				move.magnitude = 8
				move.basePower = 90
			elseif i <= 95 then
				move.magnitude = 9
				move.basePower = 110
			else
				move.magnitude = 10
				move.basePower = 150
			end
		end,
		onUseMoveMessage = function(pokemon, target, move)
			self:add('-activate', pokemon, 'move: Magnitude', move.magnitude)
		end,
		target = "allAdjacent",
		type = "Ground"
	},
	['matblock'] = {
		num = 561,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "matblock",
		name = "Mat Block",
		pp = 10,
		flags = {snatch = true, nonsky = true},
		stallingMove = true,
		sideCondition = 'matblock',
		onTryHitSide = function(side, source)
			if source.activeTurns > 1 then
				self:add('-hint', "Mat Block only works your first turn out.")
				return false
			end
		end,
		effect = {
			duration = 1,
			onStart = function(target, source)
				self:add('-singleturn', source, 'Mat Block')
			end,
			onTryHitPriority = 3,
			onTryHit = function(target, source, move)
				if not move.flags['protect'] then return end
				if move and (move.target == 'self' or move.category == 'Status') then return end
				self:add('-activate', target, 'Mat Block', move.name)
				local lockedmove = source:getVolatile('lockedmove')
				if lockedmove then
					-- Outrage counter is reset
					if source.volatiles['lockedmove'].duration == 2 then
						source.volatiles['lockedmove'] = nil
					end
				end
				return null
			end
		},
		target = "allySide",
		type = "Fighting"
	},
	['mefirst'] = {
		num = 382,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "mefirst",
		name = "Me First",
		pp = 20,
		flags = {protect = true, authentic = true},
		onTryHit = function(target, pokemon)
			local decision = self:willMove(target)
			if decision then
				local noMeFirst = {chatter=true, counter=true, covet=true, focuspunch=true, mefirst=true, metalburst=true, mirrorcoat=true, struggle=true, thief=true}
				local move = self:getMove(decision.move)
				if move.category ~= 'Status' and not noMeFirst[move] then
					pokemon:addVolatile('mefirst')
					self:useMove(move, pokemon, target)
					return null
				end
			end
			return false
		end,
		effect = {
			duration = 1,
			onBasePowerPriority = 4,
			onBasePower = function(basePower)
				return self:chainModify(1.5)
			end
		},
		target = "adjacentFoe",
		type = "Normal"
	},
	['meanlook'] = {
		num = 212,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "meanlook",
		name = "Mean Look",
		pp = 5,
		flags = {reflectable = true, mirror = true},
		onHit = function(target, source, move)
			if Not(target:addVolatile('trapped', source, move, 'trapper')) then
				self:add('-fail', target)
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['meditate'] = {
		num = 96,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "meditate",
		name = "Meditate",
		pp = 40,
		flags = {snatch = true},
		boosts = {
			atk = 1
		},
		target = "self",
		type = "Psychic"
	},
	['megadrain'] = {
		num = 72,
		accuracy = 100,
		basePower = 75,
		category = "Special",
		id = "megadrain",
		name = "Mega Drain",
		pp = 10,
		flags = {protect = true, mirror = true, heal = true},
		drain = {1, 2},
		target = "normal",
		type = "Grass"
	},
	['megakick'] = {
		num = 25,
		accuracy = 75,
		basePower = 120,
		category = "Physical",
		id = "megakick",
		name = "Mega Kick",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		target = "normal",
		type = "Normal"
	},
	['megapunch'] = {
		num = 5,
		accuracy = 85,
		basePower = 80,
		category = "Physical",
		id = "megapunch",
		name = "Mega Punch",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		target = "normal",
		type = "Normal"
	},
	['megahorn'] = {
		num = 224,
		accuracy = 85,
		basePower = 120,
		category = "Physical",
		id = "megahorn",
		name = "Megahorn",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Bug"
	},
	['memento'] = {
		num = 262,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "memento",
		name = "Memento",
		pp = 10,
		flags = {protect = true, mirror = true},
		boosts = {
			atk = -2,
			spa = -2
		},
		selfdestruct = true,
		target = "normal",
		type = "Dark"
	},
	['metalburst'] = {
		num = 368,
		accuracy = 100,
		basePower = 0,
		damageCallback = function(pokemon)
			if not pokemon.volatiles['metalburst'] then return 0 end
			return math.max(1, pokemon.volatiles['metalburst'].damage)
		end,
		category = "Physical",
		id = "metalburst",
		name = "Metal Burst",
		pp = 10,
		flags = {protect = true, mirror = true},
		beforeTurnCallback = function(pokemon)
			pokemon:addVolatile('metalburst')
		end,
		onTryHit = function(target, source, move)
			if not source.volatiles['metalburst'] then return false end
			if Not(source.volatiles['metalburst'].position) then return false end
		end,
		effect = {
			duration = 1,
			noCopy = true,
			onStart = function(target, source, source2, move)
				self.effectData.position = null
				self.effectData.damage = 0
			end,
			onRedirectTarget = function(target, source, source2)
				if source ~= self.effectData.target then return end
				return source.side.foe.active[self.effectData.position]
			end,
			onDamagePriority = -101,
			onDamage = function(damage, target, source, effect)
				if effect and effect.effectType == 'Move' and source.side ~= target.side then
					self.effectData.position = source.position
					self.effectData.damage = 1.5 * damage
				end
			end
		},
		target = "scripted",
		type = "Steel"
	},
	['metalclaw'] = {
		num = 232,
		accuracy = 95,
		basePower = 50,
		category = "Physical",
		id = "metalclaw",
		name = "Metal Claw",
		pp = 35,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 10,
			self = {
				boosts = {
					atk = 1
				}
			}
		},
		target = "normal",
		type = "Steel"
	},
	['metalsound'] = {
		num = 319,
		accuracy = 85,
		basePower = 0,
		category = "Status",
		id = "metalsound",
		name = "Metal Sound",
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true, sound = true, authentic = true},
		boosts = {
			spd = -2
		},
		target = "normal",
		type = "Steel"
	},
	['meteormash'] = {
		num = 309,
		accuracy = 90,
		basePower = 90,
		category = "Physical",
		id = "meteormash",
		name = "Meteor Mash",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		secondary = {
			chance = 20,
			self = {
				boosts = {
					atk = 1
				}
			}
		},
		target = "normal",
		type = "Steel"
	},
	['metronome'] = {
		num = 118,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "metronome",
		name = "Metronome",
		pp = 10,
		onHit = function(target)
			local n = 0
			local moves = {}
			local st = tick()
			local noMetronome = {afteryou=true, assist=true, belch=true, bestow=true, celebrate=true, chatter=true, copycat=true, counter=true, covet=true, craftyshield=true, destinybond=true, detect=true, diamondstorm=true, dragonascent=true, endure=true, feint=true, focuspunch=true, followme=true, freezeshock=true, happyhour=true, helpinghand=true, holdhands=true, hyperspacefury=true, hyperspacehole=true, iceburn=true, kingsshield=true, lightofruin=true, matblock=true, mefirst=true, metronome=true, mimic=true, mirrorcoat=true, mirrormove=true, naturepower=true, originpulse=true, precipiceblades=true, protect=true, quash=true, quickguard=true, ragepowder=true, relicsong=true, secretsword=true, sketch=true, sleeptalk=true, snarl=true, snatch=true, snore=true, spikyshield=true, steameruption=true, struggle=true, switcheroo=true, technoblast=true, thief=true, thousandarrows=true, thousandwaves=true, transform=true, trick=true, vcreate=true, wideguard=true}
			for index, move in pairs(self.data.Movedex) do
				if index == move.id then
					if not noMetronome[move.id] and not move.isZ then
						n = n + 1
						moves[n] = move
					end
					--				else
					--					print('bad move at index:', index)
				end
			end
			--			print(tick()-st, 's to get move list')
			--			print('found', n, 'moves')
			local move = ''
			if n > 0 then
				move = moves[math.random(n)].id
			end
			if Not(move) then
				return false
			end
			self:useMove(move, target)
		end,
		target = "self",
		type = "Normal"
	},
	['milkdrink'] = {
		num = 208,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "milkdrink",
		name = "Milk Drink",
		pp = 10,
		flags = {snatch = true, heal = true},
		heal = {1, 2},
		target = "self",
		type = "Normal"
	},
	['mimic'] = {
		num = 102,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "mimic",
		name = "Mimic",
		pp = 10,
		flags = {protect = true, authentic = true},
		onHit = function(target, source)
			local disallowedMoves = {chatter=true, mimic=true, sketch=true, struggle=true, transform=true}
			if source.transformed or Not(target.lastMove) or disallowedMoves[target.lastMove] or indexOf(source.moves, target.lastMove) then return false end
			local moveslot = indexOf(source.moves, 'mimic')
			if not moveslot then return false end
			local move = self:getMove(target.lastMove)
			source.moveset[moveslot] = {
				move = move.name,
				id = move.id,
				pp = move.pp,
				maxpp = move.pp,
				target = move.target,
				disabled = false,
				used = false,
				virtual = true
			}
			source.moves[moveslot] = toId(move.name)
			self:add('-start', source, 'Mimic', move.name)
		end,
		target = "normal",
		type = "Normal"
	},
	['mindreader'] = {
		num = 170,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "mindreader",
		name = "Mind Reader",
		pp = 5,
		flags = {protect = true, mirror = true},
		onTryHit = function(target, source)
			if source.volatiles['lockon'] then return false end
		end,
		onHit = function(target, source)
			source:addVolatile('lockon', target)
			self:add('-activate', source, 'move: Mind Reader', '[of] ' .. target)
		end,
		target = "normal",
		type = "Normal"
	},
	['minimize'] = {
		num = 107,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "minimize",
		name = "Minimize",
		pp = 10,
		flags = {snatch = true},
		volatileStatus = 'minimize',
		effect = {
			noCopy = true,
			onSourceModifyDamage = function(damage, source, target, move)
				local doubleDamage = {stomp=true, steamroller=true, bodyslam=true, flyingpress=true, dragonrush=true, phantomforce=true, shadowforce=true}
				if doubleDamage[move.id] then
					return self:chainModify(2)
				end
			end,
			onAccuracy = function(accuracy, target, source, move)
				local alwaysHit = {stomp=true, steamroller=true, bodyslam=true, flyingpress=true, dragonrush=true, phantomforce=true, shadowforce=true}
				if alwaysHit[move.id] then
					return true
				end
				return accuracy
			end
		},
		boosts = {
			evasion = 2
		},
		target = "self",
		type = "Normal"
	},
	['miracleeye'] = {
		num = 357,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "miracleeye",
		name = "Miracle Eye",
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		volatileStatus = 'miracleeye',
		onTryHit = function(target)
			if target.volatiles['foresight'] then return false end
		end,
		effect = {
			onStart = function(pokemon)
				self:add('-start', pokemon, 'Miracle Eye')
			end,
			onNegateImmunity = function(pokemon, type)
				if pokemon:hasType('Dark') and type == 'Psychic' then return false end
			end,
			onModifyBoost = function(boosts)
				if boosts.evasion and boosts.evasion > 0 then
					boosts.evasion = 0
				end
			end
		},
		target = "normal",
		type = "Psychic"
	},
	['mirrorcoat'] = {
		num = 243,
		accuracy = 100,
		basePower = 0,
		damageCallback = function(pokemon)
			if not pokemon.volatiles['mirrorcoat'] then return 0 end
			return math.max(1, pokemon.volatiles['mirrorcoat'].damage)
		end,
		category = "Special",
		id = "mirrorcoat",
		name = "Mirror Coat",
		pp = 20,
		priority = -5,
		flags = {protect = true},
		beforeTurnCallback = function(pokemon)
			pokemon:addVolatile('mirrorcoat')
		end,
		onTryHit = function(target, source, move)
			if not source.volatiles['mirrorcoat'] then return false end
			if Not(source.volatiles['mirrorcoat'].position) then return false end
		end,
		effect = {
			duration = 1,
			noCopy = true,
			onStart = function(target, source, source2, move)
				self.effectData.position = null
				self.effectData.damage = 0
			end,
			onRedirectTarget = function(target, source, source2)
				if source ~= self.effectData.target then return end
				return source.side.foe.active[self.effectData.position]
			end,
			onDamagePriority = -101,
			onDamage = function(damage, target, source, effect)
				if effect and effect.effectType == 'Move' and source.side ~= target.side and self:getCategory(effect.id) == 'Special' then
					self.effectData.position = source.position
					self.effectData.damage = 2 * damage
				end
			end
		},
		target = "scripted",
		type = "Psychic"
	},
	['mirrormove'] = {
		num = 119,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "mirrormove",
		name = "Mirror Move",
		pp = 20,
		onTryHit = function(target, pokemon)
			if Not(target.lastMove) or not self:getMove(target.lastMove).flags['mirror'] then return false end
			self:useMove(target.lastMove, pokemon, target)
			return null
		end,
		target = "normal",
		type = "Flying"
	},
	['mirrorshot'] = {
		num = 429,
		accuracy = 85,
		basePower = 65,
		category = "Special",
		id = "mirrorshot",
		name = "Mirror Shot",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			boosts = {
				accuracy = -1
			}
		},
		target = "normal",
		type = "Steel"
	},
	['mist'] = {
		num = 54,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "mist",
		name = "Mist",
		pp = 30,
		flags = {snatch = true},
		sideCondition = 'mist',
		effect = {
			duration = 5,
			onBoost = function(boost, target, source, effect)
				if source and target ~= source and (not effect.infiltrates or target.side == source.side) then
					local showMsg = false
					for i, b in pairs(boost) do
						if b < 0 then
							boost[i] = nil
							showMsg = true
						end
					end
					if showMsg and not effect.secondaries then
						self:add('-activate', target, 'Mist')
					end
				end
			end,
			onStart = function(side)
				self:add('-sidestart', side, 'Mist')
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 3,
			onEnd = function(side)
				self:add('-sideend', side, 'Mist')
			end
		},
		target = "allySide",
		type = "Ice"
	},
	['mistball'] = {
		num = 296,
		accuracy = 100,
		basePower = 70,
		category = "Special",
		id = "mistball",
		name = "Mist Ball",
		pp = 5,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 50,
			boosts = {
				spa = -1
			}
		},
		target = "normal",
		type = "Psychic"
	},
	['mistyterrain'] = {
		num = 581,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "mistyterrain",
		name = "Misty Terrain",
		pp = 10,
		flags = {nonsky = true},
		terrain = 'mistyterrain',
		effect = {
			duration = 5,
			onSetStatus = function(status, target, source, effect)
				if not target:isGrounded() or target:isSemiInvulnerable() then return end
				self:debug('misty terrain preventing status')
				return false
			end,
			onBasePower = function(basePower, attacker, defender, move)
				if move.type == 'Dragon' and defender:isGrounded() and not defender:isSemiInvulnerable() then
					self:debug('misty terrain weaken')
					return self:chainModify(0.5)
				end
			end,
			onStart = function(side)
				self:add('-fieldstart', 'Misty Terrain')
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 2,
			onEnd = function(side)
				self:add('-fieldend', 'Misty Terrain')
			end
		},
		target = "all",
		type = "Fairy"
	},
	['moonblast'] = {
		num = 585,
		accuracy = 100,
		basePower = 95,
		category = "Special",
		id = "moonblast",
		name = "Moonblast",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			boosts = {
				spa = -1
			}
		},
		target = "normal",
		type = "Fairy"
	},
	['moonlight'] = {
		num = 236,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "moonlight",
		name = "Moonlight",
		pp = 5,
		flags = {snatch = true, heal = true},
		onHit = function(pokemon)
			if self:isWeather({'sunnyday', 'desolateland'}) then
				return self:heal(self:modify(pokemon.maxhp, 0.667))
			elseif self:isWeather({'raindance', 'primordialsea', 'sandstorm', 'hail'}) then
				return self:heal(self:modify(pokemon.maxhp, 0.25))
			else
				return self:heal(self:modify(pokemon.maxhp, 0.5))
			end
		end,
		target = "self",
		type = "Fairy"
	},
	['morningsun'] = {
		num = 234,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "morningsun",
		name = "Morning Sun",
		pp = 5,
		flags = {snatch = true, heal = true},
		onHit = function(pokemon)
			if self:isWeather({'sunnyday', 'desolateland'}) then
				return self:heal(self:modify(pokemon.maxhp, 0.667))
			elseif self:isWeather({'raindance', 'primordialsea', 'sandstorm', 'hail'}) then
				return self:heal(self:modify(pokemon.maxhp, 0.25))
			else
				return self:heal(self:modify(pokemon.maxhp, 0.5))
			end
		end,
		target = "self",
		type = "Normal"
	},
	['mudslap'] = {
		num = 189,
		accuracy = 100,
		basePower = 20,
		category = "Special",
		id = "mudslap",
		name = "Mud-Slap",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				accuracy = -1
			}
		},
		target = "normal",
		type = "Ground"
	},
	['mudbomb'] = {
		num = 426,
		accuracy = 85,
		basePower = 65,
		category = "Special",
		id = "mudbomb",
		name = "Mud Bomb",
		pp = 10,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			boosts = {
				accuracy = -1
			}
		},
		target = "normal",
		type = "Ground"
	},
	['mudshot'] = {
		num = 341,
		accuracy = 95,
		basePower = 55,
		category = "Special",
		id = "mudshot",
		name = "Mud Shot",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spe = -1
			}
		},
		target = "normal",
		type = "Ground"
	},
	['mudsport'] = {
		num = 300,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "mudsport",
		name = "Mud Sport",
		pp = 15,
		flags = {nonsky = true},
		onHitField = function(target, source, effect)
			if self.pseudoWeather['mudsport'] then
				return false
			else
				self:addPseudoWeather('mudsport', source, effect, '[of] ' .. source)
			end
		end,
		effect = {
			duration = 5,
			onStart = function(side, source)
				self:add('-fieldstart', 'move = Mud Sport', '[of] ' .. source)
			end,
			onBasePowerPriority = 1,
			onBasePower = function(basePower, attacker, defender, move)
				if move.type == 'Electric' then
					self:debug('mud sport weaken')
					return self:chainModify(0x548, 0x1000)
				end
			end,
			onResidualOrder = 21,
			onEnd = function()
				self:add('-fieldend', 'move = Mud Sport')
			end
		},
		target = "all",
		type = "Ground"
	},
	['muddywater'] = {
		num = 330,
		accuracy = 85,
		basePower = 90,
		category = "Special",
		id = "muddywater",
		name = "Muddy Water",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		secondary = {
			chance = 30,
			boosts = {
				accuracy = -1
			}
		},
		target = "allAdjacentFoes",
		type = "Water"
	},
	['mysticalfire'] = {
		num = 595,
		accuracy = 100,
		basePower = 75,
		category = "Special",
		id = "mysticalfire",
		name = "Mystical Fire",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spa = -1
			}
		},
		target = "normal",
		type = "Fire"
	},
	['nastyplot'] = {
		num = 417,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "nastyplot",
		name = "Nasty Plot",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			spa = 2
		},
		target = "self",
		type = "Dark"
	},
	['naturalgift'] = {
		num = 363,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon)
			if pokemon.volatiles['naturalgift'] then
				return pokemon.volatiles['naturalgift'].basePower
			end
			return false
		end,
		category = "Physical",
		id = "naturalgift",
		name = "Natural Gift",
		pp = 15,
		flags = {protect = true, mirror = true},
		beforeMoveCallback = function(pokemon)
			if pokemon:ignoringItem() then return end
			local item = pokemon:getItem()
			if item.id and item.naturalGift then
				pokemon:addVolatile('naturalgift')
				pokemon.volatiles['naturalgift'].basePower = item.naturalGift.basePower
				pokemon.volatiles['naturalgift'].type = item.naturalGift.type
				pokemon:setItem('')
				self:runEvent('AfterUseItem', pokemon, nil, nil, item)
			end
		end,
		onPrepareHit = function(target, source)
			if not source.volatiles['naturalgift'] then return false end
		end,
		onModifyMove = function(move, pokemon)
			if pokemon.volatiles['naturalgift'] then
				move.type = pokemon.volatiles['naturalgift'].type
			end
		end,
		onHit = function(target, source)
			return source.volatiles['naturalgift'] and true or false
		end,
		effect = {
			duration = 1
		},
		target = "normal",
		type = "Normal"
	},
	['naturepower'] = {
		num = 267,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "naturepower",
		name = "Nature Power",
		pp = 20,
		onTryHit = function(target, pokemon)
			--			local move = 'triattack' -- in a building
			--			if self:isTerrain('electricterrain') then
			--				move = 'thunderbolt'
			--			elseif self:isTerrain('grassyterrain') then -- or external terrain is grass
			--				move = 'energyball'
			--			elseif self:isTerrain('mistyterrain') then
			--				move = 'moonblast'
			--			end

			local move = 'energyball' -- for now

			--[[
			cave/mountain
				powergem
			desert/road
				mudbomb
			snow
				blizzard
			water
				hydropump
			--]]
			self:useMove(move, pokemon, target)
			return null
		end,
		target = "normal",
		type = "Normal"
	},
	['needlearm'] = {
		num = 302,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "needlearm",
		name = "Needle Arm",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Grass"
	},
	['nightdaze'] = {
		num = 539,
		accuracy = 95,
		basePower = 85,
		category = "Special",
		id = "nightdaze",
		name = "Night Daze",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 40,
			boosts = {
				accuracy = -1
			}
		},
		target = "normal",
		type = "Dark"
	},
	['nightshade'] = {
		num = 101,
		accuracy = 100,
		basePower = 0,
		damage = 'level',
		category = "Special",
		id = "nightshade",
		name = "Night Shade",
		pp = 15,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Ghost"
	},
	['nightslash'] = {
		num = 400,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "nightslash",
		name = "Night Slash",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		critRatio = 2,
		target = "normal",
		type = "Dark"
	},
	['nightmare'] = {
		num = 171,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "nightmare",
		name = "Nightmare",
		pp = 15,
		flags = {protect = true, mirror = true},
		volatileStatus = 'nightmare',
		effect = {
			onStart = function(pokemon)
				if pokemon.status ~= 'slp' then
					return false
				end
				self:add('-start', pokemon, 'Nightmare')
			end,
			onResidualOrder = 9,
			onResidual = function(pokemon)
				self:damage(pokemon.maxhp / 4)
			end,
			onUpdate = function(pokemon)
				if pokemon.status ~= 'slp' then
					pokemon:removeVolatile('nightmare')
					self:add('-end', pokemon, 'Nightmare', '[silent]')
				end
			end
		},
		target = "normal",
		type = "Ghost"
	},
	['nobleroar'] = {
		num = 568,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "nobleroar",
		name = "Noble Roar",
		pp = 30,
		flags = {protect = true, reflectable = true, mirror = true, sound = true, authentic = true},
		boosts = {
			atk = -1,
			spa = -1
		},
		target = "normal",
		type = "Normal"
	},
	['nuzzle'] = {
		num = 609,
		accuracy = 100,
		basePower = 20,
		category = "Physical",
		id = "nuzzle",
		name = "Nuzzle",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},
	['oblivionwing'] = {
		num = 613,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "oblivionwing",
		name = "Oblivion Wing",
		pp = 10,
		flags = {protect = true, mirror = true, distance = true, heal = true},
		drain = {3, 4},
		target = "any",
		type = "Flying"
	},
	['octazooka'] = {
		num = 190,
		accuracy = 85,
		basePower = 65,
		category = "Special",
		id = "octazooka",
		name = "Octazooka",
		pp = 10,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 50,
			boosts = {
				accuracy = -1
			}
		},
		target = "normal",
		type = "Water"
	},
	['odorsleuth'] = {
		num = 316,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "odorsleuth",
		name = "Odor Sleuth",
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		volatileStatus = 'foresight',
		onTryHit = function(target)
			if target.volatiles['miracleeye'] then return false end
		end,
		target = "normal",
		type = "Normal"
	},
	['ominouswind'] = {
		num = 466,
		accuracy = 100,
		basePower = 60,
		category = "Special",
		id = "ominouswind",
		name = "Ominous Wind",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			self = {
				boosts = {
					atk = 1,
					def = 1,
					spa = 1,
					spd = 1,
					spe = 1
				}
			}
		},
		target = "normal",
		type = "Ghost"
	},
	['originpulse'] = {
		num = 618,
		accuracy = 85,
		basePower = 110,
		category = "Special",
		id = "originpulse",
		name = "Origin Pulse",
		pp = 10,
		flags = {protect = true, pulse = true, mirror = true},
		target = "allAdjacentFoes",
		type = "Water"
	},
	['outrage'] = {
		num = 200,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "outrage",
		name = "Outrage",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'lockedmove'
		},
		onAfterMove = function(pokemon)
			if pokemon.volatiles['lockedmove'] and pokemon.volatiles['lockedmove'].duration == 1 then
				pokemon:removeVolatile('lockedmove')
			end
		end,
		target = "randomNormal",
		type = "Dragon"
	},
	['overheat'] = {
		num = 315,
		accuracy = 90,
		basePower = 130,
		category = "Special",
		id = "overheat",
		name = "Overheat",
		pp = 5,
		flags = {protect = true, mirror = true},
		self = {
			boosts = {
				spa = -2
			}
		},
		target = "normal",
		type = "Fire"
	},
	['painsplit'] = {
		num = 220,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "painsplit",
		name = "Pain Split",
		pp = 20,
		flags = {protect = true, mirror = true},
		onHit = function(target, pokemon)
			local averagehp = math.max(1, math.floor((target.hp + pokemon.hp) / 2))
			target:sethp(averagehp)
			pokemon:sethp(averagehp)
			self:add('-sethp', target, target.getHealth, pokemon, pokemon.getHealth, '[from] move = Pain Split')
		end,
		target = "normal",
		type = "Normal"
	},
	['paraboliccharge'] = {
		num = 570,
		accuracy = 100,
		basePower = 65,
		category = "Special",
		id = "paraboliccharge",
		name = "Parabolic Charge",
		pp = 20,
		flags = {protect = true, mirror = true, heal = true},
		drain = {1, 2},
		target = "allAdjacent",
		type = "Electric"
	},
	['partingshot'] = {
		num = 575,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "partingshot",
		name = "Parting Shot",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true, sound = true, authentic = true},
		selfSwitch = true,
		boosts = {
			atk = -1,
			spa = -1
		},
		target = "normal",
		type = "Dark"
	},
	['payday'] = {
		num = 6,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "payday",
		name = "Pay Day",
		pp = 20,
		flags = {protect = true, mirror = true},
		onHit = function()
			self:add('-fieldactivate', 'move = Pay Day')
		end,
		target = "normal",
		type = "Normal"
	},
	['payback'] = {
		num = 371,
		accuracy = 100,
		basePower = 50,
		basePowerCallback = function(pokemon, target)
			if target.newlySwitched then
				self:debug('Payback NOT boosted on a switch')
				return 50
			end
			if self:willMove(target) then
				self:debug('Payback NOT boosted')
				return 50
			end
			self:debug('Payback damage boost')
			return 100
		end,
		category = "Physical",
		id = "payback",
		name = "Payback",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Dark"
	},
	['peck'] = {
		num = 64,
		accuracy = 100,
		basePower = 35,
		category = "Physical",
		id = "peck",
		name = "Peck",
		pp = 35,
		flags = {contact = true, protect = true, mirror = true, distance = true},
		target = "any",
		type = "Flying"
	},
	['perishsong'] = {
		num = 195,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "perishsong",
		name = "Perish Song",
		pp = 5,
		flags = {sound = true, distance = true, authentic = true},
		onHitField = function(target, source)
			local result = false
			local message = false
			for _, side in pairs(self.sides) do
				for _, pokemon in pairs(side.active) do
					if pokemon ~= null then
						if pokemon:hasAbility('soundproof') then
							self:add('-immune', pokemon, '[msg]')
							result = true
						elseif not pokemon.volatiles['perishsong'] then
							pokemon:addVolatile('perishsong')
							self:add('-start', pokemon, 'perish3', '[silent]')
							result = true
							message = true
						end
					end
				end
			end
			if not result then return false end
			if message then self:add('-fieldactivate', 'move: Perish Song') end
		end,
		effect = {
			duration = 4,
			onEnd = function(target)
				self:add('-start', target, 'perish0')
				target:faint()
			end,
			onResidual = function(pokemon)
				local duration = pokemon.volatiles['perishsong'].duration
				self:add('-start', pokemon, 'perish' .. duration)
			end
		},
		target = "all",
		type = "Normal"
	},
	['petalblizzard'] = {
		num = 572,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "petalblizzard",
		name = "Petal Blizzard",
		pp = 15,
		flags = {protect = true, mirror = true},
		target = "allAdjacent",
		type = "Grass"
	},
	['petaldance'] = {
		num = 80,
		accuracy = 100,
		basePower = 120,
		category = "Special",
		id = "petaldance",
		name = "Petal Dance",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'lockedmove'
		},
		onAfterMove = function(pokemon)
			if pokemon.volatiles['lockedmove'] and pokemon.volatiles['lockedmove'].duration == 1 then
				pokemon:removeVolatile('lockedmove')
			end
		end,
		target = "randomNormal",
		type = "Grass"
	},
	['phantomforce'] = {
		num = 566,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "phantomforce",
		name = "Phantom Force",
		pp = 10,
		flags = {contact = true, charge = true, mirror = true},
		breaksProtect = true,
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		effect = {
			duration = 2,
			onAccuracy = function(accuracy, target, source, move)
				if move.id == 'helpinghand' then return end
				if source:hasAbility('noguard') or target:hasAbility('noguard') then return end
				if source.volatiles['lockon'] and target == source.volatiles['lockon'].source then return end
				return 0
			end
		},
		target = "normal",
		type = "Ghost"
	},
	['pinmissile'] = {
		num = 42,
		accuracy = 95,
		basePower = 25,
		category = "Physical",
		id = "pinmissile",
		name = "Pin Missile",
		pp = 20,
		flags = {protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Bug"
	},
	['playnice'] = {
		num = 589,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "playnice",
		name = "Play Nice",
		pp = 20,
		flags = {reflectable = true, mirror = true, authentic = true},
		boosts = {
			atk = -1
		},
		target = "normal",
		type = "Normal"
	},
	['playrough'] = {
		num = 583,
		accuracy = 90,
		basePower = 90,
		category = "Physical",
		id = "playrough",
		name = "Play Rough",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				atk = -1
			}
		},
		target = "normal",
		type = "Fairy"
	},
	['pluck'] = {
		num = 365,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "pluck",
		name = "Pluck",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, distance = true},
		onHit = function(target, source)
			local item = target:getItem()
			if source.hp > 0 and item.isBerry and target:takeItem(source) then
				self:add('-enditem', target, item.name, '[from] stealeat', '[move] Pluck', '[of] ' .. source)
				self:singleEvent('Eat', item, nil, source, nil, nil)
				source.ateBerry = true
			end
		end,
		target = "any",
		type = "Flying"
	},
	['poisonfang'] = {
		num = 305,
		accuracy = 100,
		basePower = 50,
		category = "Physical",
		id = "poisonfang",
		name = "Poison Fang",
		pp = 15,
		flags = {bite = true, contact = true, protect = true, mirror = true},
		secondary = {
			chance = 50,
			status = 'tox'
		},
		target = "normal",
		type = "Poison"
	},
	['poisongas'] = {
		num = 139,
		accuracy = 90,
		basePower = 0,
		category = "Status",
		id = "poisongas",
		name = "Poison Gas",
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true},
		status = 'psn',
		target = "allAdjacentFoes",
		type = "Poison"
	},
	['poisonjab'] = {
		num = 398,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "poisonjab",
		name = "Poison Jab",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'psn'
		},
		target = "normal",
		type = "Poison"
	},
	['poisonpowder'] = {
		num = 77,
		accuracy = 75,
		basePower = 0,
		category = "Status",
		id = "poisonpowder",
		name = "Poison Powder",
		pp = 35,
		flags = {powder = true, protect = true, reflectable = true, mirror = true},
		onTryHit = function(target)
			if not target:runImmunity('powder') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		status = 'psn',
		target = "normal",
		type = "Poison"
	},
	['poisonsting'] = {
		num = 40,
		accuracy = 100,
		basePower = 15,
		category = "Physical",
		id = "poisonsting",
		name = "Poison Sting",
		pp = 35,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'psn'
		},
		target = "normal",
		type = "Poison"
	},
	['poisontail'] = {
		num = 342,
		accuracy = 100,
		basePower = 50,
		category = "Physical",
		id = "poisontail",
		name = "Poison Tail",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		critRatio = 2,
		secondary = {
			chance = 10,
			status = 'psn'
		},
		target = "normal",
		type = "Poison"
	},
	['pound'] = {
		num = 1,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "pound",
		name = "Pound",
		pp = 35,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['powder'] = {
		num = 600,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "powder",
		name = "Powder",
		pp = 20,
		priority = 1,
		flags = {powder = true, protect = true, reflectable = true, mirror = true, authentic = true},
		onTryHit = function(target)
			if not target.runImmunity('powder') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		volatileStatus = 'powder',
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-start', target, 'Powder')
			end,
			onTryMove = function(pokemon, target, move)
				if move.type == 'Fire' then
					self:add('-activate', pokemon, 'Powder')
					self:damage(self:clampIntRange(math.floor(pokemon.maxhp / 4 + 0.5), 1))
					return false
				end
			end
		},
		target = "normal",
		type = "Bug"
	},
	['powdersnow'] = {
		num = 181,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "powdersnow",
		name = "Powder Snow",
		pp = 25,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'frz'
		},
		target = "allAdjacentFoes",
		type = "Ice"
	},
	['powergem'] = {
		num = 408,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "powergem",
		name = "Power Gem",
		pp = 20,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Rock"
	},
	['powersplit'] = {
		num = 471,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "powersplit",
		name = "Power Split",
		pp = 10,
		flags = {protect = true},
		onHit = function(target, source)
			local newatk = math.floor((target.stats.atk + source.stats.atk) / 2)
			target.stats.atk = newatk
			source.stats.atk = newatk
			local newspa = math.floor((target.stats.spa + source.stats.spa) / 2)
			target.stats.spa = newspa
			source.stats.spa = newspa
			self:add('-activate', source, 'Power Split', '[of] ' .. target)
		end,
		target = "normal",
		type = "Psychic"
	},
	['powerswap'] = {
		num = 384,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "powerswap",
		name = "Power Swap",
		pp = 10,
		flags = {protect = true, mirror = true, authentic = true},
		onHit = function(target, source)
			local targetBoosts = { atk = target.boosts['atk'], spa = target.boosts['spa'] }
			local sourceBoosts = { atk = source.boosts['atk'], spa = source.boosts['spa'] }
			source:setBoost(targetBoosts)
			target:setBoost(sourceBoosts)
			self:add('-swapboost', source, target, 'atk, spa', '[from] move = Power Swap')
		end,
		target = "normal",
		type = "Psychic"
	},
	['powertrick'] = {
		num = 379,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "powertrick",
		name = "Power Trick",
		pp = 10,
		flags = {snatch = true},
		volatileStatus = 'powertrick',
		effect = {
			onStart = function(pokemon)
				self:add('-start', pokemon, 'Power Trick')
				local newatk = pokemon.stats.def
				local newdef = pokemon.stats.atk
				pokemon.stats.atk = newatk
				pokemon.stats.def = newdef
			end,
			onCopy = function(pokemon)
				self:add('-start', pokemon, 'Power Trick')
				local newatk = pokemon.stats.def
				local newdef = pokemon.stats.atk
				pokemon.stats.atk = newatk
				pokemon.stats.def = newdef
			end,
			onEnd = function(pokemon)
				self:add('-end', pokemon, 'Power Trick')
				local newatk = pokemon.stats.def
				local newdef = pokemon.stats.atk
				pokemon.stats.atk = newatk
				pokemon.stats.def = newdef
			end,
			onRestart = function(pokemon)
				pokemon:removeVolatile('Power Trick')
			end
		},
		target = "self",
		type = "Psychic"
	},
	['poweruppunch'] = {
		num = 612,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "poweruppunch",
		name = "Power-Up Punch",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		secondary = {
			chance = 100,
			self = {
				boosts = {
					atk = 1
				}
			}
		},
		target = "normal",
		type = "Fighting"
	},
	['powerwhip'] = {
		num = 438,
		accuracy = 85,
		basePower = 120,
		category = "Physical",
		id = "powerwhip",
		name = "Power Whip",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Grass"
	},
	['precipiceblades'] = {
		num = 619,
		accuracy = 85,
		basePower = 120,
		category = "Physical",
		id = "precipiceblades",
		name = "Precipice Blades",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		target = "allAdjacentFoes",
		type = "Ground"
	},
	['present'] = {
		num = 217,
		accuracy = 90,
		basePower = 0,
		category = "Physical",
		id = "present",
		name = "Present",
		pp = 15,
		flags = {protect = true, mirror = true},
		onModifyMove = function(move, pokemon, target)
			local rand = math.random(10)
			if rand <= 2 then
				move.heal = {1, 4}
			elseif rand <= 6 then
				move.basePower = 40
			elseif rand <= 9 then
				move.basePower = 80
			else
				move.basePower = 120
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['protect'] = {
		num = 182,
		accuracy = true, --PROTECC
		basePower = 0,
		category = "Status",
		id = "protect",
		name = "Protect",
		pp = 10,
		priority = 4,
		stallingMove = true,
		volatileStatus = 'protect',
		onPrepareHit = function(pokemon)
			return not Not(self:willAct()) and not Not(self:runEvent('StallMove', pokemon))
		end,
		onHit = function(pokemon)
			pokemon:addVolatile('stall')
		end,
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-singleturn', target, 'Protect')
			end,
			onTryHitPriority = 3,
			onTryHit = function(target, source, move)
				if not move.flags['protect'] then return end
				self:add('-activate', target, 'Protect', source)
				local lockedmove = source:getVolatile('lockedmove')
				if lockedmove then
					-- Outrage counter is reset
					if source.volatiles['lockedmove'].duration == 2 then
						source.volatiles['lockedmove'] = nil
					end
				end
				return null
			end
		},
		target = "self",
		type = "Normal"
	},
	['psybeam'] = {
		num = 60,
		accuracy = 100,
		basePower = 65,
		category = "Special",
		id = "psybeam",
		name = "Psybeam",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			volatileStatus = 'confusion'
		},
		target = "normal",
		type = "Psychic"
	},
	['psychup'] = {
		num = 244,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "psychup",
		name = "Psych Up",
		pp = 10,
		flags = {authentic = true},
		onHit = function(target, source)
			local targetBoosts = {}
			for i, b in pairs(target.boosts) do
				targetBoosts[i] = b
			end
			source:setBoost(targetBoosts)
			self:add('-copyboost', source, target, '[from] move = Psych Up')
		end,
		target = "normal",
		type = "Normal"
	},
	['psychic'] = {
		num = 94,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "psychic",
		name = "Psychic",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			boosts = {
				spd = -1
			}
		},
		target = "normal",
		type = "Psychic"
	},
	['psychoboost'] = {
		num = 354,
		accuracy = 90,
		basePower = 140,
		category = "Special",
		id = "psychoboost",
		name = "Psycho Boost",
		pp = 5,
		flags = {protect = true, mirror = true},
		self = {
			boosts = {
				spa = -2
			}
		},
		target = "normal",
		type = "Psychic"
	},
	['psychocut'] = {
		num = 427,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "psychocut",
		name = "Psycho Cut",
		pp = 20,
		flags = {protect = true, mirror = true,blademaster = true},
		critRatio = 2,
		target = "normal",
		type = "Psychic"
	},
	['psychoshift'] = {
		num = 375,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "psychoshift",
		name = "Psycho Shift",
		pp = 10,
		flags = {protect = true, mirror = true},
		onHit = function(target, pokemon)
			if pokemon.status and pokemon.status ~= '' and (not target.status or target.status == '') and target:trySetStatus(pokemon.status) then
				pokemon:cureStatus()
			else
				return false
			end
		end,
		target = "normal",
		type = "Psychic"
	},
	['psyshock'] = {
		num = 473,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		defensiveCategory = "Physical",
		id = "psyshock",
		name = "Psyshock",
		pp = 10,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Psychic"
	},
	['psystrike'] = {
		num = 540,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		defensiveCategory = "Physical",
		id = "psystrike",
		name = "Psystrike",
		pp = 10,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Psychic"
	},
	['psywave'] = {
		num = 149,
		accuracy = 100,
		basePower = 0,
		damageCallback = function(pokemon)
			return math.random(50, 150) * pokemon.level / 100
		end,
		category = "Special",
		id = "psywave",
		name = "Psywave",
		pp = 15,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Psychic"
	},
	['punishment'] = {
		num = 386,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			return math.min(200, 60 + 20 * target:positiveBoosts())
		end,
		category = "Physical",
		id = "punishment",
		name = "Punishment",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Dark"
	},
	['pursuit'] = {
		num = 228,
		accuracy = 100,
		basePower = 40,
		basePowerCallback = function(pokemon, target)
			if target.beingCalledBack then
				self:debug('Pursuit damage boost')
				return 80
			end
			return 40
		end,
		category = "Physical",
		id = "pursuit",
		name = "Pursuit",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		beforeTurnCallback = function(pokemon, target)
			target.side:addSideCondition('pursuit', pokemon)
			if not target.side.sideConditions['pursuit'].sources then
				target.side.sideConditions['pursuit'].sources = {}
			end
			table.insert(target.side.sideConditions['pursuit'].sources, pokemon)
		end,
		onModifyMove = function(move, source, target)
			if target and target.beingCalledBack then
				move.accuracy = true
			end
		end,
		onTryHit = function(target, pokemon)
			target.side:removeSideCondition('pursuit')
		end,
		effect = {
			duration = 1,
			onBeforeSwitchOut = function(pokemon)
				self:debug('Pursuit start')
				for _, source in pairs(self.effectData.sources) do
					if Not(source.moveThisTurn) then
						self:cancelMove(source)
						if source.canMegaEvo then
							for _, q in pairs(self.queue) do
								if q.pokemon == source and q.choice == 'megaEvo' then
									self:runMegaEvo(source)
									break
								end
							end
						end
						self:runMove('pursuit', source, pokemon)
					end
				end
			end
		},
		target = "normal",
		type = "Dark"
	},
	['quash'] = {
		num = 511,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "quash",
		name = "Quash",
		pp = 15,
		flags = {protect = true, mirror = true},
		onHit = function(target)
			if #target.side.active < 2 then return false end -- fails in singles
			local decision = self:willMove(target)
			if decision then
				decision.priority = -7.1
				self:cancelMove(target)
				for i, q in pairs(self.queue) do
					if q.choice == 'residual' then
						table.insert(self.queue, i, decision)
						break
					end
				end
				self:add('-activate', target, 'move = Quash')
			else
				return false
			end
		end,
		target = "normal",
		type = "Dark"
	},
	['quickattack'] = {
		num = 98,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "quickattack",
		name = "Quick Attack",
		pp = 30,
		priority = 1,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['quickguard'] = {
		num = 501,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "quickguard",
		name = "Quick Guard",
		pp = 15,
		priority = 3,
		flags = {snatch = true},
		sideCondition = 'quickguard',
		onTryHitSide = function(side, source)
			return self:willAct()
		end,
		onHitSide = function(side, source)
			source:addVolatile('stall')
		end,
		effect = {
			duration = 1,
			onStart = function(target, source)
				self:add('-singleturn', source, 'Quick Guard')
			end,
			onTryHitPriority = 4,
			onTryHit = function(target, source, effect)
				-- Quick Guard blocks moves with positive priority, even those given increased priority by Prankster or Gale Wings.
				-- (e.g. it blocks 0 priority moves boosted by Prankster or Gale Wings)
				if effect and (effect.id == 'feint' or effect.priority <= 0 or effect.target == 'self') then return end
				self:add('-activate', target, 'Quick Guard')
				local lockedmove = source:getVolatile('lockedmove')
				if lockedmove then
					-- Outrage counter is reset
					if source.volatiles['lockedmove'].duration == 2 then
						source.volatiles['lockedmove'] = nil
					end
				end
				return null
			end
		},
		target = "allySide",
		type = "Fighting"
	},
	['quiverdance'] = {
		num = 483,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "quiverdance",
		name = "Quiver Dance",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			spa = 1,
			spd = 1,
			spe = 1
		},
		target = "self",
		type = "Bug"
	},
	['rage'] = {
		num = 99,
		accuracy = 100,
		basePower = 20,
		category = "Physical",
		id = "rage",
		name = "Rage",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'rage'
		},
		effect = {
			onStart = function(pokemon)
				self:add('-singlemove', pokemon, 'Rage')
			end,
			onHit = function(target, source, move)
				if target ~= source and move.category ~= 'Status' then
					self:boost({atk = 1})
				end
			end,
			onBeforeMovePriority = 100,
			onBeforeMove = function(pokemon)
				self:debug('removing Rage before attack')
				pokemon:removeVolatile('rage')
			end
		},
		target = "normal",
		type = "Normal"
	},
	['ragepowder'] = {
		num = 476,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "ragepowder",
		name = "Rage Powder",
		pp = 20,
		priority = 2,
		flags = {powder = true},
		volatileStatus = 'ragepowder',
		effect = {
			duration = 1,
			onStart = function(pokemon)
				self:add('-start', pokemon, 'move = Rage Powder')
			end,
			onFoeRedirectTarget = function(target, source, source2, move)
				if source:runImmunity('powder') and self:validTarget(self.effectData.target, source, move.target) then
					self:debug("Rage Powder redirected target of move")
					return self.effectData.target
				end
			end
		},
		target = "self",
		type = "Bug"
	},
	['raindance'] = {
		num = 240,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "raindance",
		name = "Rain Dance",
		pp = 5,
		weather = 'RainDance',
		target = "all",
		type = "Water"
	},
	['rapidspin'] = {
		num = 229,
		accuracy = 100,
		basePower = 20,
		category = "Physical",
		id = "rapidspin",
		name = "Rapid Spin",
		pp = 40,
		flags = {contact = true, protect = true, mirror = true},
		self = {
			onHit = function(pokemon)
				if pokemon.hp > 0 and pokemon:removeVolatile('leechseed') then
					self:add('-end', pokemon, 'Leech Seed', '[from] move = Rapid Spin', '[of] ' .. pokemon)
				end
				local sideConditions = {'spikes', 'toxicspikes', 'stealthrock', 'stickyweb'}
				for _, sc in pairs(sideConditions) do
					if pokemon.hp > 0 and pokemon.side:removeSideCondition(sc) then
						self:add('-sideend', pokemon.side, self:getEffect(sc).name, '[from] move = Rapid Spin', '[of] ' .. pokemon)
					end
				end
				if pokemon.hp > 0 and pokemon.volatiles['partiallytrapped'] then
					pokemon:removeVolatile('partiallytrapped')
				end
			end,
		},
		target = "normal",
		type = "Normal"
	},
	['razorleaf'] = {
		num = 75,
		accuracy = 95,
		basePower = 55,
		category = "Physical",
		id = "razorleaf",
		name = "Razor Leaf",
		pp = 25,
		flags = {protect = true, mirror = true},
		critRatio = 2,
		target = "allAdjacentFoes",
		type = "Grass"
	},
	['razorshell'] = {
		num = 534,
		accuracy = 95,
		basePower = 75,
		category = "Physical",
		id = "razorshell",
		name = "Razor Shell",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		secondary = {
			chance = 50,
			boosts = {
				def = -1
			}
		},
		target = "normal",
		type = "Water"
	},
	['razorwind'] = {
		num = 13,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "razorwind",
		name = "Razor Wind",
		pp = 10,
		flags = {charge = true, protect = true, mirror = true},
		onTry = function(attacker, defender, move)
			if attacker.volatiles['twoturnmove'] then
				if attacker.volatiles['twoturnmove'].duration == 1 then
					return
				else
					return null
				end
			end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		critRatio = 2,
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['recover'] = {
		num = 105,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "recover",
		name = "Recover",
		pp = 10,
		flags = {snatch = true, heal = true},
		heal = {1, 2},
		target = "self",
		type = "Normal"
	},
	['recycle'] = {
		num = 278,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "recycle",
		name = "Recycle",
		pp = 10,
		flags = {snatch = true},
		onHit = function(pokemon)
			if (pokemon.item and pokemon.item ~= '') or Not(pokemon.lastItem) then return false end
			pokemon:setItem(pokemon.lastItem)
			self:add('-item', pokemon, pokemon:getItem(), '[from] move: Recycle')
		end,
		target = "self",
		type = "Normal"
	},
	['reflect'] = {
		num = 115,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "reflect",
		name = "Reflect",
		pp = 20,
		flags = {snatch = true},
		sideCondition = 'reflect',
		effect = {
			duration = 5,
			durationCallback = function(target, source, effect)
				if source and source:hasItem('lightclay') then
					return 8
				end
				return 5
			end,
			onAnyModifyDamage = function(damage, source, target, move)
				if target ~= source and target.side == self.effectData.target and self:getCategory(move) == 'Physical' then
					if not move.crit and not move.infiltrates then
						self:debug('Reflect weaken')
						if #target.side.active > 1 then return self:chainModify(0xA8F, 0x1000) end
						return self:chainModify(0.5)
					end
				end
			end,
			onStart = function(side)
				self:add('-sidestart', side, 'Reflect')
			end,
			onResidualOrder = 21,
			onEnd = function(side)
				self:add('-sideend', side, 'Reflect')
			end
		},
		target = "allySide",
		type = "Psychic"
	},
	['reflecttype'] = {
		num = 513,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "reflecttype",
		name = "Reflect Type",
		pp = 15,
		flags = {protect = true, authentic = true},
		onHit = function(target, source)
			if source.template and source.template.num == 493 then return false end
			self:add('-start', source, 'typechange', '[from] move = Reflect Type', '[of] ' .. target)
			source.typesData = {}
			for _, td in pairs(target.typesData) do
				if not td.suppressed then
					table.insert(source.typesData, {
						type = td.type,
						suppressed = false,
						isAdded = td.isAdded
					})
				end
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['refresh'] = {
		num = 287,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "refresh",
		name = "Refresh",
		pp = 20,
		flags = {snatch = true},
		onHit = function(pokemon)
			pokemon:cureStatus()
		end,
		target = "self",
		type = "Normal"
	},
	['relicsong'] = {
		num = 547,
		accuracy = 100,
		basePower = 75,
		category = "Special",
		id = "relicsong",
		name = "Relic Song",
		pp = 10,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		secondary = {
			chance = 10,
			status = 'slp'
		},
		onHit = function(target, pokemon)
			if pokemon.baseTemplate.species == 'Meloetta' and not pokemon.transformed then
				pokemon:addVolatile('relicsong')
			end
		end,
		effect = {
			duration = 1,
			onAfterMoveSecondarySelf = function(pokemon, target, move)
				if pokemon.template.species ~= 'Meloetta' then return end
				print("Transform")

				if Not(pokemon.template.forme) and pokemon:formeChange('Meloetta-Pirouette') then
					self:add('-formechange', pokemon, 'Meloetta-Pirouette')
				elseif pokemon.template.forme == 'Pirouette' and pokemon:formeChange('Meloetta') then
					self:add('-formechange', pokemon, 'Meloetta')
				end

				pokemon:removeVolatile('relicsong')
			end
		},
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['rest'] = {
		num = 156,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "rest",
		name = "Rest",
		pp = 10,
		flags = {snatch = true, heal = true},
		onHit = function(target)
			if target.hp >= target.maxhp then return false end
			if not target:setStatus('slp') then return false end
			target.statusData.time = 3
			target.statusData.startTime = 3
			self:heal(target.maxhp) --Aesthetic only as the healing happens after you fall asleep in-game
			self:add('-status', target, 'slp', '[from] move = Rest')
		end,
		target = "self",
		type = "Psychic"
	},
	['retaliate'] = {
		num = 514,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "retaliate",
		name = "Retaliate",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon)
			if pokemon.side.faintedLastTurn then
				self:debug('Boosted for a faint last turn')
				return self:chainModify(2)
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['return'] = {
		num = 216,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon)
			return math.max(1, math.floor(pokemon.happiness * 10 / 25))
		end,
		category = "Physical",
		id = "return",
		name = "Return",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['revenge'] = {
		num = 279,
		accuracy = 100,
		basePower = 60,
		basePowerCallback = function(pokemon, target)
			if type(target.lastDamage) == 'number' and target.lastDamage > 0 and pokemon.lastAttackedBy and pokemon.lastAttackedBy.thisTurn and pokemon.lastAttackedBy.pokemon == target then
				pcall(function() self:debug('Boosted for getting hit by ' .. pokemon.lastAttackedBy.move) end)
				return 120
			end
			return 60
		end,
		category = "Physical",
		id = "revenge",
		name = "Revenge",
		pp = 10,
		priority = -4,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Fighting"
	},
	['reversal'] = {
		num = 179,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			local ratio = pokemon.hp * 48 / pokemon.maxhp
			if ratio < 2 then
				return 200
			elseif ratio < 5 then
				return 150
			elseif ratio < 10 then
				return 100
			elseif ratio < 17 then
				return 80
			elseif ratio < 33 then
				return 40
			end
			return 20
		end,
		category = "Physical",
		id = "reversal",
		name = "Reversal",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Fighting"
	},
	['roar'] = {
		num = 46,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "roar",
		name = "Roar",
		pp = 20,
		priority = -6,
		flags = {reflectable = true, mirror = true, sound = true, authentic = true},
		forceSwitch = true,
		target = "normal",
		type = "Normal"
	},
	['roaroftime'] = {
		num = 459,
		accuracy = 90,
		basePower = 150,
		category = "Special",
		id = "roaroftime",
		name = "Roar of Time",
		pp = 5,
		flags = {recharge = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'mustrecharge'
		},
		target = "normal",
		type = "Dragon"
	},
	['rockblast'] = {
		num = 350,
		accuracy = 90,
		basePower = 25,
		category = "Physical",
		id = "rockblast",
		name = "Rock Blast",
		pp = 10,
		flags = {protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Rock"
	},
	['rockclimb'] = {
		num = 431,
		accuracy = 85,
		basePower = 90,
		category = "Physical",
		id = "rockclimb",
		name = "Rock Climb",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 20,
			volatileStatus = 'confusion'
		},
		target = "normal",
		type = "Normal"
	},
	['rockpolish'] = {
		num = 397,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "rockpolish",
		name = "Rock Polish",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			spe = 2
		},
		target = "self",
		type = "Rock"
	},
	['rockslide'] = {
		num = 157,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		id = "rockslide",
		name = "Rock Slide",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "allAdjacentFoes",
		type = "Rock"
	},
	['rocksmash'] = {
		num = 249,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "rocksmash",
		name = "Rock Smash",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 50,
			boosts = {
				def = -1
			}
		},
		target = "normal",
		type = "Fighting"
	},
	['rockthrow'] = {
		num = 88,
		accuracy = 90,
		basePower = 50,
		category = "Physical",
		id = "rockthrow",
		name = "Rock Throw",
		pp = 15,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Rock"
	},
	['rocktomb'] = {
		num = 317,
		accuracy = 95,
		basePower = 60,
		category = "Physical",
		id = "rocktomb",
		name = "Rock Tomb",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spe = -1
			}
		},
		target = "normal",
		type = "Rock"
	},
	['rockwrecker'] = {
		num = 439,
		accuracy = 90,
		basePower = 150,
		category = "Physical",
		id = "rockwrecker",
		name = "Rock Wrecker",
		pp = 5,
		flags = {bullet = true, recharge = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'mustrecharge'
		},
		target = "normal",
		type = "Rock"
	},
	['roleplay'] = {
		num = 272,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "roleplay",
		name = "Role Play",
		pp = 10,
		flags = {authentic = true},
		onTryHit = function(target, source)
			local bannedAbilities = {flowergift=true, forecast=true, illusion=true, imposter=true, multitype=true, trace=true, wonderguard=true, zenmode=true}
			if bannedAbilities[target.ability] or source.ability == 'multitype' or target.ability == source.ability then
				return false
			end
		end,
		onHit = function(target, source)
			local oldAbility = source:setAbility(target.ability)
			if oldAbility then
				self:add('-ability', source, source.ability, '[from] move = Role Play', '[of] ' .. target)
				return
			end
			return false
		end,
		target = "normal",
		type = "Psychic"
	},
	['rollingkick'] = {
		num = 27,
		accuracy = 85,
		basePower = 60,
		category = "Physical",
		id = "rollingkick",
		name = "Rolling Kick",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Fighting"
	},
	['rollout'] = {
		num = 205,
		accuracy = 90,
		basePower = 30,
		basePowerCallback = function(pokemon, target)
			local bp = 30
			local bpTable = {30, 60, 120, 240, 480}
			if pokemon.volatiles.rollout and pokemon.volatiles.rollout.hitCount then
				bp = bpTable[pokemon.volatiles.rollout.hitCount+1] or 30
			end
			pokemon:addVolatile('rollout')
			if pokemon.volatiles.defensecurl then
				bp = bp * 2
			end
			self:debug("Rollout bp = " .. bp)
			return bp
		end,
		category = "Physical",
		id = "rollout",
		name = "Rollout",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		effect = {
			duration = 2,
			onLockMove = 'rollout',
			onStart = function()
				self.effectData.hitCount = 1
			end,
			onRestart = function()
				self.effectData.hitCount = self.effectData.hitCount + 1
				if self.effectData.hitCount < 5 then
					self.effectData.duration = 2
				end
			end,
			onResidual = function(target)
				if target.lastMove == 'struggle' then
					-- don't lock
					target.volatiles['rollout'] = nil
				end
			end
		},
		target = "normal",
		type = "Rock"
	},
	['roost'] = {
		num = 355,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "roost",
		name = "Roost",
		pp = 10,
		flags = {snatch = true, heal = true},
		heal = {1, 2},
		self = {
			volatileStatus = 'roost'
		},
		effect = {
			duration = 1,
			onStart = function(pokemon)
				for _, td in pairs(pokemon.typesData) do
					if td.type == 'Flying' then
						td.suppressed = true
						break
					end
				end
			end,
			onModifyPokemon = function(pokemon)
				for _, td in pairs(pokemon.typesData) do
					if td.type == 'Flying' then
						td.suppressed = true
						break
					end
				end
			end,
			onEnd = function(pokemon)
				for _, td in pairs(pokemon.typesData) do
					if td.type == 'Flying' then
						td.suppressed = false
						break
					end
				end
			end
		},
		target = "self",
		type = "Flying"
	},
	['rototiller'] = {
		num = 563,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "rototiller",
		name = "Rototiller",
		pp = 10,
		flags = {distance = true, nonsky = true},
		onHitField = function(target, source)
			local targets = {}
			local anyAirborne = false
			for _, side in pairs(self.sides) do
				for _, pokemon in pairs(side.pokemon.active) do
					if pokemon ~= null then
						if not pokemon:runImmunity('Ground') then
							self:add('-immune', pokemon, '[msg]')
							anyAirborne = true
						elseif pokemon:hasType('Grass') then
							-- This move affects every grounded Grass-type Pokemon in play.
							table.insert(targets, pokemon)
						end
					end
				end
			end
			if #targets == 0 and not anyAirborne then return false end -- Fails when there are no grounded Grass types or airborne Pokemon
			for _, target in pairs(targets) do
				self:boost({atk = 1, spa = 1}, target, source)
			end
		end,
		target = "all",
		type = "Ground"
	},
	['round'] = {
		num = 496,
		accuracy = 100,
		basePower = 60,
		basePowerCallback = function(target, source, move) --roundabout
			if move.sourceEffect == 'round' then
				return 120
			end
			return 60
		end,
		category = "Special",
		id = "round",
		name = "Round",
		pp = 15,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		onTryHit = function(target, source)
			for _, decision in pairs(self.queue) do
				if decision.pokemon and decision.move then
					if decision.move.id == 'round' then
						self:prioritizeQueue(decision)
						return
					end
				end
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['sacredfire'] = {
		num = 221,
		accuracy = 95,
		basePower = 100,
		category = "Physical",
		id = "sacredfire",
		name = "Sacred Fire",
		pp = 5,
		flags = {protect = true, mirror = true, defrost = true},
		secondary = {
			chance = 50,
			status = 'brn'
		},
		target = "normal",
		type = "Fire"
	},
	['sacredsword'] = {
		num = 533,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "sacredsword",
		name = "Sacred Sword",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, blademaster = true},
		ignoreEvasion = true,
		ignoreDefensive = true,
		target = "normal",
		type = "Fighting"
	},
	['safeguard'] = {
		num = 219,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "safeguard",
		name = "Safeguard",
		pp = 25,
		flags = {snatch = true},
		sideCondition = 'safeguard',
		effect = {
			duration = 5,
			onSetStatus = function(status, target, source, effect)
				if source and target ~= source and effect and (not effect.infiltrates or target.side == source.side) then
					self:debug('interrupting setStatus')
					return false
				end
			end,
			onTryConfusion = function(target, source, effect)
				if source and target ~= source and effect and (not effect.infiltrates or target.side == source.side) then
					self:debug('interrupting addVolatile')
					return false
				end
			end,
			onTryHit = function(target, source, move)
				if move and move.id == 'yawn' and target ~= source and (not move.infiltrates or target.side == source.side) then
					self:debug('blocking yawn')
					return false
				end
			end,
			onStart = function(side)
				self:add('-sidestart', side, 'Safeguard')
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 2,
			onEnd = function(side)
				self:add('-sideend', side, 'Safeguard')
			end
		},
		target = "allySide",
		type = "Normal"
	},
	['sandattack'] = {
		num = 28,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "sandattack",
		name = "Sand Attack",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			accuracy = -1
		},
		target = "normal",
		type = "Ground"
	},
	['sandtomb'] = {
		num = 328,
		accuracy = 85,
		basePower = 35,
		category = "Physical",
		id = "sandtomb",
		name = "Sand Tomb",
		pp = 15,
		flags = {protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Ground"
	},
	['sandstorm'] = {
		num = 201,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "sandstorm",
		name = "Sandstorm",
		pp = 10,
		weather = 'Sandstorm',
		target = "all",
		type = "Rock"
	},
	['scald'] = {
		num = 503,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "scald",
		name = "Scald",
		pp = 15,
		flags = {protect = true, mirror = true, defrost = true},
		thawsTarget = true,
		secondary = {
			chance = 30,
			status = 'brn'
		},
		target = "normal",
		type = "Water"
	},
	['scaryface'] = {
		num = 184,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "scaryface",
		name = "Scary Face",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			spe = -2
		},
		target = "normal",
		type = "Normal"
	},
	['scratch'] = {
		num = 10,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "scratch",
		name = "Scratch",
		pp = 35,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['screech'] = {
		num = 103,
		accuracy = 85,
		basePower = 0,
		category = "Status",
		id = "screech",
		name = "Screech",
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true, sound = true, authentic = true},
		boosts = {
			def = -2
		},
		target = "normal",
		type = "Normal"
	},
	['searingshot'] = {
		num = 545,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		id = "searingshot",
		name = "Searing Shot",
		pp = 5,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'brn'
		},
		target = "allAdjacent",
		type = "Fire"
	},
	['secretpower'] = {
		num = 290,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "secretpower",
		name = "Secret Power",
		pp = 20,
		flags = {protect = true, mirror = true},
		onHit = function(target, source, move)
			if self:isTerrain('') then return end
			move.secondaries = {}
			if self:isTerrain('electricterrain') then
				table.insert(move.secondaries, {
					chance = 30,
					status = 'par'
				})
			elseif self:isTerrain('grassyterrain') then
				table.insert(move.secondaries, {
					chance = 30,
					status = 'slp'
				})
			elseif self:isTerrain('mistyterrain') then
				table.insert(move.secondaries, {
					chance = 30,
					boosts = {
						spa = -1
					}
				})
			end
		end,
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "normal",
		type = "Normal"
	},
	['secretsword'] = {
		num = 548,
		accuracy = 100,
		basePower = 85,
		category = "Special",
		defensiveCategory = "Physical",
		id = "secretsword",
		name = "Secret Sword",
		pp = 10,
		flags = {protect = true, mirror = true,blademaster = true},
		target = "normal",
		type = "Fighting"
	},
	['seedbomb'] = {
		num = 402,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "seedbomb",
		name = "Seed Bomb",
		pp = 15,
		flags = {bullet = true, protect = true, mirror = true},
		target = "normal",
		type = "Grass"
	},
	['seedflare'] = {
		num = 465,
		accuracy = 85,
		basePower = 120,
		category = "Special",
		id = "seedflare",
		name = "Seed Flare",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 40,
			boosts = {
				spd = -2
			}
		},
		target = "normal",
		type = "Grass"
	},
	['seismictoss'] = {
		num = 69,
		accuracy = 100,
		basePower = 0,
		damage = 'level',
		category = "Physical",
		id = "seismictoss",
		name = "Seismic Toss",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, nonsky = true},
		target = "normal",
		type = "Fighting"
	},
	['selfdestruct'] = {
		num = 120,
		accuracy = 100,
		basePower = 200,
		category = "Physical",
		id = "selfdestruct",
		name = "Self-Destruct",
		pp = 5,
		flags = {protect = true, mirror = true},
		selfdestruct = true,
		target = "allAdjacent",
		type = "Normal"
	},
	['shadowball'] = {
		num = 247,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "shadowball",
		name = "Shadow Ball",
		pp = 15,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 20,
			boosts = {
				spd = -1
			}
		},
		target = "normal",
		type = "Ghost"
	},
	['shadowclaw'] = {
		num = 421,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "shadowclaw",
		name = "Shadow Claw",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		critRatio = 2,
		target = "normal",
		type = "Ghost"
	},
	['shadowforce'] = {
		num = 467,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "shadowforce",
		name = "Shadow Force",
		pp = 5,
		flags = {contact = true, charge = true, mirror = true},
		breaksProtect = true,
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		effect = {
			duration = 2,
			onAccuracy = function(accuracy, target, source, move)
				if move.id == 'helpinghand' then return end
				if source:hasAbility('noguard') or target:hasAbility('noguard') then return end
				if source.volatiles['lockon'] and target == source.volatiles['lockon'].source then return end
				return 0
			end
		},
		target = "normal",
		type = "Ghost"
	},
	['shadowpunch'] = {
		num = 325,
		accuracy = true,
		basePower = 60,
		category = "Physical",
		id = "shadowpunch",
		name = "Shadow Punch",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		target = "normal",
		type = "Ghost"
	},
	['shadowsneak'] = {
		num = 425,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "shadowsneak",
		name = "Shadow Sneak",
		pp = 30,
		priority = 1,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Ghost"
	},
	['shadowspatter'] = {
		num = 720,
		accuracy = 100,
		basePower = 120,
		category = "Special",
		id = "shadowspatter",
		name = "Shadow Spatter",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spa = -1 
			}
		},
		target = "normal",
		type = "Dark"
	},
	['sharpen'] = {
		num = 159,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "sharpen",
		name = "Sharpen",
		pp = 30,
		flags = {snatch = true},
		boosts = {
			atk = 1
		},
		target = "self",
		type = "Normal"
	},
	['sheercold'] = {
		num = 329,
		accuracy = 30,
		basePower = 0,
		category = "Special",
		id = "sheercold",
		name = "Sheer Cold",
		pp = 5,
		flags = {protect = true, mirror = true},
		ohko = true,
		target = "normal",
		type = "Ice"
	},
	['shellsmash'] = {
		num = 504,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "shellsmash",
		name = "Shell Smash",
		pp = 15,
		flags = {snatch = true},
		boosts = {
			def = -1,
			spd = -1,
			atk = 2,
			spa = 2,
			spe = 2
		},
		target = "self",
		type = "Normal"
	},
	['shiftgear'] = {
		num = 508,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "shiftgear",
		name = "Shift Gear",
		pp = 10,
		flags = {snatch = true},
		boosts = {
			spe = 2, -- todo boost order
			atk = 1
		},
		target = "self",
		type = "Steel"
	},
	['shockwave'] = {
		num = 351,
		accuracy = true,
		basePower = 60,
		category = "Special",
		id = "shockwave",
		name = "Shock Wave",
		pp = 20,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Electric"
	},
	['signalbeam'] = {
		num = 324,
		accuracy = 100,
		basePower = 75,
		category = "Special",
		id = "signalbeam",
		name = "Signal Beam",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			volatileStatus = 'confusion'
		},
		target = "normal",
		type = "Bug"
	},
	['silverwind'] = {
		num = 318,
		accuracy = 100,
		basePower = 60,
		category = "Special",
		id = "silverwind",
		name = "Silver Wind",
		pp = 5,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			self = {
				boosts = {
					atk = 1,
					def = 1,
					spa = 1,
					spd = 1,
					spe = 1
				}
			}
		},
		target = "normal",
		type = "Bug"
	},
	['simplebeam'] = {
		num = 493,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "simplebeam",
		name = "Simple Beam",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		onTryHit = function(pokemon)
			local bannedAbilities = {multitype=true, simple=true, stancechange=true, truant=true}
			if bannedAbilities[pokemon.ability] then
				return false
			end
		end,
		onHit = function(pokemon)
			local oldAbility = pokemon:setAbility('simple')
			if oldAbility then
				self:add('-endability', pokemon, oldAbility, '[from] move: Simple Beam')
				self:add('-ability', pokemon, 'Simple', '[from] move = Simple Beam')
				return
			end
			return false
		end,
		target = "normal",
		type = "Normal"
	},
	['sing'] = {
		num = 47,
		accuracy = 55,
		basePower = 0,
		category = "Status",
		id = "sing",
		name = "Sing",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true, sound = true, authentic = true},
		status = 'slp',
		target = "normal",
		type = "Normal"
	},
	['sketch'] = {
		num = 166,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "sketch",
		name = "Sketch",
		pp = 1,
		noPPBoosts = true,
		flags = {authentic = true},
		onHit = function(target, source)
			local disallowedMoves = {chatter=true, sketch=true, struggle=true}
			if source.transformed or (not target.lastMove or target.lastMove == '') or disallowedMoves[target.lastMove] or indexOf(source.moves, target.lastMove) then return false end
			local moveslot = indexOf(source.moves, 'sketch')
			if not moveslot then return false end
			local move = self:getMove(target.lastMove)
			local sketchedMove = {
				move = move.name,
				id = move.id,
				pp = move.pp,
				maxpp = move.pp,
				target = move.target,
				disabled = false,
				used = false
			}
			source.moveset[moveslot] = sketchedMove
			source.baseMoveset[moveslot] = sketchedMove
			source.moves[moveslot] = toId(move.name)
			self:add('-activate', source, 'move = Sketch', move.name)
		end,
		target = "normal",
		type = "Normal"
	},
	['skillswap'] = {
		num = 285,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "skillswap",
		name = "Skill Swap",
		pp = 10,
		flags = {protect = true, mirror = true, authentic = true},
		onTryHit = function(target, source)
			local bannedAbilities = {illusion=true, multitype=true, stancechange=true, wonderguard=true}
			if bannedAbilities[target.ability] or bannedAbilities[source.ability] then
				return false
			end
		end,
		onHit = function(target, source, move)
			local targetAbility = self:getAbility(target.ability)
			local sourceAbility = self:getAbility(source.ability)
			self:add('-activate', source, 'move: Skill Swap', targetAbility, sourceAbility, '[of] ' .. target)
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
		target = "normal",
		type = "Psychic"
	},
	['skullbash'] = {
		num = 130,
		accuracy = 100,
		basePower = 130,
		category = "Physical",
		id = "skullbash",
		name = "Skull Bash",
		pp = 10,
		flags = {contact = true, charge = true, protect = true, mirror = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			self:boost({def = 1}, attacker, attacker, self:getMove('skullbash'))
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				attacker:removeVolatile(move.id)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		target = "normal",
		type = "Normal"
	},
	['skyattack'] = {
		num = 143,
		accuracy = 90,
		basePower = 200,
		category = "Physical",
		id = "skyattack",
		name = "Sky Attack",
		pp = 5,
		flags = {charge = true, protect = true, mirror = true, distance = true},
		critRatio = 2,
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then
				return
			end
			self:add('-prepare', attacker, move.name, defender)
			if Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "any",
		type = "Flying"
	},
	['skydrop'] = {
		num = 507,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "skydrop",
		name = "Sky Drop",
		pp = 10,
		flags = {contact = true, charge = true, protect = true, mirror = true, gravity = true, distance = true},
		onModifyMove = function(move, source)
			if not source.volatiles['skydrop'] then
				move.accuracy = true
			end
		end,
		onMoveFail = function(target, source)
			if source.volatiles['twoturnmove'] and source.volatiles['twoturnmove'].duration == 1 then
				source:removeVolatile('skydrop')
				source:removeVolatile('twoturnmove')
				self:add('-end', target, 'Sky Drop', '[interrupt]')--, '[onMoveFail]')
			end
		end,
		onTryHit = function(target, source, move)
			if target.fainted then return false end
			if source:removeVolatile(move.id) then
				if target ~= source.volatiles['twoturnmove'].source then return false end

				if target:hasType('Flying') then
					self:add('-immune', target, '[msg]', '[noreset]')
					self:add('-end', target, 'Sky Drop')--,'[onTryHit]')
					return null
				end
			else
				if target.volatiles['substitute'] or target.side == source.side then return false end
				if target:getWeight() >= 200 then
					self:add('-fail', target, 'move: Sky Drop', '[heavy]')
					return null
				end

				self:add('-prepare', source, move.name, target)
				source:addVolatile('twoturnmove', target)
				return null
			end
		end,
		onHit = function(target, source)
			self:add('-end', target, 'Sky Drop')--, '[onHit]')
		end,
		effect = {
			duration = 2,
			onStart = function()
				self.effectData.source:removeVolatile('followme')
				self.effectData.source:removeVolatile('ragepowder')
			end,
			onAnyDragOut = function(pokemon)
				if pokemon == self.effectData.target or pokemon == self.effectData.source then return false end
			end,
			onFoeTrapPokemonPriority = -15,
			onFoeTrapPokemon = function(defender)
				if defender ~= self.effectData.source then return end
				defender.trapped = true
			end,
			onFoeBeforeMovePriority = 12,
			onFoeBeforeMove = function(attacker, defender, move)
				if attacker == self.effectData.source then
					--					self:debug('Sky drop nullifying foe\'s move')
					return null
				end
			end,
			onRedirectTargetPriority = 99,
			onRedirectTarget = function(target, source, source2)
				if source ~= self.effectData.target then return end
				if self.effectData.source.fainted then return end
				return self.effectData.source
			end,
			onAnyAccuracy = function(accuracy, target, source, move)
				if target ~= self.effectData.target and target ~= self.effectData.source then return end
				if source == self.effectData.target and target == self.effectData.source then return end
				if move.id == 'gust' or move.id == 'twister' then return end
				if move.id == 'skyuppercut' or move.id == 'thunder' or move.id == 'hurricane' or move.id == 'smackdown' or move.id == 'thousandarrows' or move.id == 'helpinghand' then return end
				if source:hasAbility('noguard') or target:hasAbility('noguard') then return end
				if source.volatiles['lockon'] and target == source.volatiles['lockon'].source then return end
				return 0
			end,
			onAnyBasePower = function(basePower, target, source, move)
				if target ~= self.effectData.target and target ~= self.effectData.source then return end
				if source == self.effectData.target and target == self.effectData.source then return end
				if move.id == 'gust' or move.id == 'twister' then
					return self:chainModify(2)
				end
			end,
			onFaint = function(target)
				if target.volatiles['skydrop'] and target.volatiles['twoturnmove'].source then
					self:add('-end', target.volatiles['twoturnmove'].source, 'Sky Drop', '[interrupt]')--, '[onFaint]')
				end
			end,
		},
		target = "any",
		type = "Flying"
	},
	['skyuppercut'] = {
		num = 327,
		accuracy = 90,
		basePower = 85,
		category = "Physical",
		id = "skyuppercut",
		name = "Sky Uppercut",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		target = "normal",
		type = "Fighting"
	},
	['slackoff'] = {
		num = 303,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "slackoff",
		name = "Slack Off",
		pp = 10,
		flags = {snatch = true, heal = true},
		heal = {1, 2},
		target = "self",
		type = "Normal"
	},
	mistyexplosion = {
		num = 802,
		accuracy = 100,
		basePower = 100,
		category = "Special",
		name = "Misty Explosion",
		id = 'mistyexplosion',
		pp = 5,
		flags = {protect = true, mirror = true},
		selfdestruct = true,
		onBasePower = function(basePower, source)
			if (self:isTerrain('mistyterrain') and source.isGrounded()) then
				return self:chainModify(1.5)
			end
		end,
		target = "allAdjacent",
		type = "Fairy",
	},
	['slam'] = {
		num = 21,
		accuracy = 75,
		basePower = 80,
		category = "Physical",
		id = "slam",
		name = "Slam",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, nonsky = true},
		target = "normal",
		type = "Normal"
	},
	['slash'] = {
		num = 163,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "slash",
		name = "Slash",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		critRatio = 2,
		target = "normal",
		type = "Normal"
	},
	['sleeppowder'] = {
		num = 79,
		accuracy = 75,
		basePower = 0,
		category = "Status",
		id = "sleeppowder",
		name = "Sleep Powder",
		pp = 15,
		flags = {powder = true, protect = true, reflectable = true, mirror = true},
		onTryHit = function(target)
			if not target:runImmunity('powder') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		status = 'slp',
		target = "normal",
		type = "Grass"
	},
	['sleeptalk'] = {
		num = 214,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "sleeptalk",
		name = "Sleep Talk",
		pp = 10,
		sleepUsable = true,
		onTryHit = function(pokemon)
			if pokemon.status ~= 'slp' then return false end
		end,
		onHit = function(pokemon)
			local moves = {}
			local NoSleepTalk = {assist=true, belch=true, bide=true, chatter=true, copycat=true, focuspunch=true, mefirst=true, metronome=true, mimic=true, mirrormove=true, naturepower=true, sketch=true, sleeptalk=true, uproar=true}
			for _, m in pairs(pokemon.moveset) do
				local move = m.id
				if move and not NoSleepTalk[move] and not self:getMove(move).flags['charge'] then
					table.insert(moves, move)
				end
			end
			local move
			if #moves> 0 then
				move = moves[math.random(#moves)]
			end
			if not move then
				return false
			end
			self:useMove(move, pokemon)
		end,
		target = "self",
		type = "Normal"
	},
	['sludge'] = {
		num = 124,
		accuracy = 100,
		basePower = 65,
		category = "Special",
		id = "sludge",
		name = "Sludge",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'psn'
		},
		target = "normal",
		type = "Poison"
	},
	['sludgebomb'] = {
		num = 188,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "sludgebomb",
		name = "Sludge Bomb",
		pp = 10,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'psn'
		},
		target = "normal",
		type = "Poison"
	},
	['sludgewave'] = {
		num = 482,
		accuracy = 100,
		basePower = 95,
		category = "Special",
		id = "sludgewave",
		name = "Sludge Wave",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'psn'
		},
		target = "allAdjacent",
		type = "Poison"
	},
	['smackdown'] = {
		num = 479,
		accuracy = 100,
		basePower = 50,
		category = "Physical",
		id = "smackdown",
		name = "Smack Down",
		pp = 15,
		flags = {protect = true, mirror = true, nonsky = true},
		volatileStatus = 'smackdown',
		effect = {
			onStart = function(pokemon)
				local applies = false
				if pokemon:hasType('Flying') or pokemon:hasAbility('levitate') then applies = true end
				if pokemon:hasItem('ironball') or pokemon.volatiles['ingrain'] or self:getPseudoWeather('gravity') then applies = false end
				if pokemon:removeVolatile('fly') or pokemon:removeVolatile('bounce') then
					applies = true
					self:cancelMove(pokemon)
					pokemon:removeVolatile('twoturnmove')
				end
				if pokemon.volatiles['magnetrise'] then
					applies = true
					pokemon.volatiles['magnetrise'] = nil
				end
				if pokemon.volatiles['telekinesis'] then
					applies = true
					pokemon.volatiles['telekinesis'] = nil
				end
				if not applies then return false end
				self:add('-start', pokemon, 'Smack Down')
			end,
			onRestart = function(pokemon)
				if pokemon:removeVolatile('fly') or pokemon:removeVolatile('bounce') then
					self:cancelMove(pokemon)
					self:add('-start', pokemon, 'Smack Down')
				end
			end,
			onNegateImmunity = function(pokemon, type)
				if type == 'Ground' then return false end
			end
		},
		target = "normal",
		type = "Rock"
	},
	['smellingsalts'] = {
		num = 265,
		accuracy = 100,
		basePower = 70,
		basePowerCallback = function(pokemon, target)
			if target.status == 'par' then return 140 end
			return 70
		end,
		category = "Physical",
		id = "smellingsalts",
		name = "Smelling Salts",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		onHit = function(target)
			if target.status == 'par' then
				target:cureStatus()
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['smog'] = {
		num = 123,
		accuracy = 70,
		basePower = 30,
		category = "Special",
		id = "smog",
		name = "Smog",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 40,
			status = 'psn'
		},
		target = "normal",
		type = "Poison"
	},
	['smokescreen'] = {
		num = 108,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "smokescreen",
		name = "Smokescreen",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			accuracy = -1
		},
		target = "normal",
		type = "Normal"
	},
	['snarl'] = {
		num = 555,
		accuracy = 95,
		basePower = 55,
		category = "Special",
		id = "snarl",
		name = "Snarl",
		pp = 15,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		secondary = {
			chance = 100,
			boosts = {
				spa = -1
			}
		},
		target = "allAdjacentFoes",
		type = "Dark"
	},
	['snatch'] = {
		num = 289,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "snatch",
		name = "Snatch",
		pp = 10,
		priority = 4,
		flags = {authentic = true},
		volatileStatus = 'snatch',
		effect = {
			duration = 1,
			onStart = function(pokemon)
				self:add('-singleturn', pokemon, 'Snatch')
			end,
			onAnyTryMove = function(source, target, move)
				if move and move.flags['snatch'] and move.sourceEffect ~= 'snatch' then
					local snatchUser = self.effectData.source
					snatchUser:removeVolatile('snatch')
					self:add('-activate', snatchUser, 'Snatch', '[of] ' .. source)
					self:useMove(move.id, snatchUser)
					return null
				end
			end
		},
		pressureTarget = "foeSide",
		target = "self",
		type = "Dark"
	},
	['snore'] = {
		num = 173,
		accuracy = 100,
		basePower = 50,
		category = "Special",
		id = "snore",
		name = "Snore",
		pp = 15,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		sleepUsable = true,
		onTryHit = function(target, source)
			if source.status ~= 'slp' then return false end
		end,
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Normal"
	},
	['spikyshield'] = {
		num = 596,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "spikyshield",
		name = "Spiky Shield",
		pp = 10,
		priority = 4,
		stallingMove = true,
		volatileStatus = 'spikyshield',
		onTryHit = function(target, source, move)
			return not Not(self:willAct()) and not Not(self:runEvent('StallMove', target))
		end,
		onHit = function(pokemon)
			pokemon:addVolatile('stall')
		end,
		effect = {
			duration = 1,
			onStart = function(target)
				self:add('-singleturn', target, 'Protect')
			end,
			onTryHitPriority = 3,
			onTryHit = function(target, source, move)
				if not move.flags['protect'] then return end
				self:add('-activate', target, 'Protect', source)
				local lockedmove = source:getVolatile('lockedmove')
				if lockedmove then
					-- Outrage counter is reset
					if source.volatiles['lockedmove'].duration == 2 then
						source.volatiles['lockedmove'] = nil
					end
				end
				if move.flags['contact'] then
					self:damage(source.maxhp / 8, source, target)
				end
				return null
			end
		},
		target = "self",
		type = "Grass"
	},
	['soak'] = {
		num = 487,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "soak",
		name = "Soak",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		onHit = function(target)
			if not target:setType('Water') then return false end
			self:add('-start', target, 'typechange', 'Water')
		end,
		target = "normal",
		type = "Water"
	},
	['softboiled'] = {
		num = 135,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "softboiled",
		name = "Soft-Boiled",
		pp = 10,
		flags = {snatch = true, heal = true},
		heal = {1, 2},
		target = "self",
		type = "Normal"
	},
	['solarbeam'] = {
		num = 76,
		accuracy = 100,
		basePower = 120,
		category = "Special",
		id = "solarbeam",
		name = "Solar Beam",
		pp = 10,
		flags = {charge = true, protect = true, mirror = true},
		onTry = function(attacker, defender, move)
			if attacker:removeVolatile(move.id) then return end
			self:add('-prepare', attacker, move.name, defender)
			if self:isWeather({'sunnyday', 'desolateland'}) or Not(self:runEvent('ChargeMove', attacker, defender, move)) then
				self:add('-anim', attacker, move.name, defender)
				return
			end
			attacker:addVolatile('twoturnmove', defender)
			return null
		end,
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon, target)
			if self:isWeather({'raindance', 'primordialsea', 'sandstorm', 'hail'}) then
				self:debug('weakened by weather')
				return self:chainModify(0.5)
			end
		end,
		target = "normal",
		type = "Grass"
	},
	['sonicboom'] = {
		num = 49,
		accuracy = 90,
		basePower = 0,
		damage = 20,
		category = "Special",
		id = "sonicboom",
		name = "Sonic Boom",
		pp = 20,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['spacialrend'] = {
		num = 460,
		accuracy = 95,
		basePower = 100,
		category = "Special",
		id = "spacialrend",
		name = "Spacial Rend",
		pp = 5,
		flags = {protect = true, mirror = true},
		critRatio = 2,
		target = "normal",
		type = "Dragon"
	},
	['spark'] = {
		num = 209,
		accuracy = 100,
		basePower = 65,
		category = "Physical",
		id = "spark",
		name = "Spark",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},
	['spiderweb'] = {
		num = 169,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "spiderweb",
		name = "Spider Web",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		onHit = function(target, source, move)
			if not target:addVolatile('trapped', source, move, 'trapper') then
				self:add('-fail', target)
			end
		end,
		target = "normal",
		type = "Bug"
	},
	['spikecannon'] = {
		num = 131,
		accuracy = 100,
		basePower = 20,
		category = "Physical",
		id = "spikecannon",
		name = "Spike Cannon",
		pp = 15,
		flags = {protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Normal"
	},
	['spikes'] = {
		num = 191,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "spikes",
		name = "Spikes",
		pp = 20,
		flags = {reflectable = true, nonsky = true},
		sideCondition = 'spikes',
		effect = {
			-- this is a side condition
			onStart = function(side)
				self:add('-sidestart', side, 'Spikes')
				self.effectData.layers = 1
			end,
			onRestart = function(side)
				if self.effectData.layers >= 3 then return false end
				self:add('-sidestart', side, 'Spikes')
				self.effectData.layers = self.effectData.layers + 1
			end,
			onSwitchIn = function(pokemon)
				local side = pokemon.side
				local item = pokemon:getItem()
				if not pokemon:isGrounded() then return end
				if item.id == 'heavydutyboots' then return end
				local damageAmounts = {3, 4, 6} -- 1/8, 1/6, 1/4
				self:damage(damageAmounts[self.effectData.layers] * pokemon.maxhp / 24)
			end
		},
		target = "foeSide",
		type = "Ground"
	},
	['spitup'] = {
		num = 255,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon)
			if not pokemon.volatiles['stockpile'] or not pokemon.volatiles['stockpile'].layers or pokemon.volatiles['stockpile'].layers == 0 then return false end
			return pokemon.volatiles['stockpile'].layers * 100
		end,
		category = "Special",
		id = "spitup",
		name = "Spit Up",
		pp = 10,
		flags = {protect = true},
		onTry = function(pokemon)
			if not pokemon.volatiles['stockpile'] then
				return false
			end
		end,
		onAfterMove = function(pokemon)
			pokemon:removeVolatile('stockpile')
		end,
		target = "normal",
		type = "Normal"
	},
	['spite'] = {
		num = 180,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "spite",
		name = "Spite",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		onHit = function(target)
			if target:deductPP(target.lastMove, 4) then
				self:add('-activate', target, 'Spite', self:getMove(target.lastMove).name, 4)
				return
			end
			return false
		end,
		target = "normal",
		type = "Ghost"
	},
	['splash'] = {
		num = 150,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "splash",
		name = "Splash",
		pp = 40,
		flags = {gravity = true},
		onTryHit = function(target, source)
			self:add('-nothing')
			return null
		end,
		target = "self",
		type = "Normal"
	},
	['spore'] = {
		num = 147,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "spore",
		name = "Spore",
		pp = 15,
		flags = {powder = true, protect = true, reflectable = true, mirror = true},
		onTryHit = function(target)
			if not target:runImmunity('powder') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		status = 'slp',
		target = "normal",
		type = "Grass"
	},
	['stealthrock'] = {
		num = 446,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "stealthrock",
		name = "Stealth Rock",
		pp = 20,
		flags = {reflectable = true},
		sideCondition = 'stealthrock',
		effect = {
			-- this is a side condition
			onStart = function(side)
				self:add('-sidestart', side, 'move = Stealth Rock')
			end,
			onSwitchIn = function(pokemon)
				local item = pokemon:getItem()
				local side = pokemon.side 
				if item.id == 'heavydutyboots' then
					local mult = false
					local factor = false 
					local damage =  false
					print ("User holding boots")

				else if item.id ~= 'heavydutyboots' then
						local item = pokemon:getItem()
						local side = pokemon.side  
						local mult = pokemon:runEffectiveness('Rock')
						local factor = 8 / math.max(.25, math.min(4, mult))
						local damage = self:damage(pokemon.maxhp / factor)
					end
				end		
			end

		},
		target = "foeSide",
		type = "Rock"
	},
	['steameruption'] = {
		num = 592,
		accuracy = 95,
		basePower = 110,
		category = "Special",
		id = "steameruption",
		name = "Steam Eruption",
		pp = 5,
		flags = {protect = true, mirror = true, defrost = true},
		thawsTarget = true,
		isUnreleased = true,
		secondary = {
			chance = 30,
			status = 'brn'
		},
		target = "normal",
		type = "Water"
	},
	['steelwing'] = {
		num = 211,
		accuracy = 90,
		basePower = 70,
		category = "Physical",
		id = "steelwing",
		name = "Steel Wing",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 10,
			self = {
				boosts = {
					def = 1
				}
			}
		},
		target = "normal",
		type = "Steel"
	},
	['stickyweb'] = {
		num = 564,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "stickyweb",
		name = "Sticky Web",
		pp = 20,
		flags = {reflectable = true},
		sideCondition = 'stickyweb',
		effect = {
			onStart = function(side)
				self:add('-sidestart', side, 'move = Sticky Web')
			end,
			onSwitchIn = function(pokemon)
				local item = pokemon:getItem()
				if not pokemon:isGrounded() then return end
				if item.id == 'heavydutyboots' then return end
				self:add('-activate', pokemon, 'move = Sticky Web')
				self:boost({spe = -1}, pokemon, pokemon.side.foe.active[1], self:getMove('stickyweb'))
			end
		},
		target = "foeSide",
		type = "Bug"
	},
	['stockpile'] = {
		num = 254,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "stockpile",
		name = "Stockpile",
		pp = 20,
		flags = {snatch = true},
		onTryHit = function(pokemon)
			if pokemon.volatiles['stockpile'] and pokemon.volatiles['stockpile'].layers >= 3 then return false end
		end,
		volatileStatus = 'stockpile',
		effect = {
			onStart = function(target)
				self.effectData.layers = 1
				self:add('-start', target, 'stockpile' .. self.effectData.layers)
				self:boost({def = 1, spd = 1}, target, target, self:getMove('stockpile'))
			end,
			onRestart = function(target)
				if self.effectData.layers >= 3 then return false end
				self.effectData.layers = self.effectData.layers + 1
				self:add('-start', target, 'stockpile' .. self.effectData.layers)
				self:boost({def = 1, spd = 1}, target, target, self:getMove('stockpile'))
			end,
			onEnd = function(target)
				local l = -self.effectData.layers
				self.effectData.layers = 0
				self:boost({def = l, spd = l}, target, target, self:getMove('stockpile'))
				self:add('-end', target, 'Stockpile')
			end
		},
		target = "self",
		type = "Normal"
	},
	['stomp'] = {
		num = 23,
		accuracy = 100,
		basePower = 65,
		category = "Physical",
		id = "stomp",
		name = "Stomp",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true, nonsky = true,striker = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Normal"
	},
	['stoneedge'] = {
		num = 444,
		accuracy = 90,
		basePower = 100,
		category = "Physical",
		id = "stoneedge",
		name = "Stone Edge",
		pp = 5,
		flags = {protect = true, mirror = true},
		critRatio = 2,
		target = "normal",
		type = "Rock"
	},
	['storedpower'] = {
		num = 500,
		accuracy = 100,
		basePower = 20,
		basePowerCallback = function(pokemon)
			return 20 + 20 * pokemon:positiveBoosts()
		end,
		category = "Special",
		id = "storedpower",
		name = "Stored Power",
		pp = 10,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Psychic"
	},
	['stormthrow'] = {
		num = 480,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "stormthrow",
		name = "Storm Throw",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		willCrit = true,
		target = "normal",
		type = "Fighting"
	},
	['steamroller'] = {
		num = 537,
		accuracy = 100,
		basePower = 65,
		category = "Physical",
		id = "steamroller",
		name = "Steamroller",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 30,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Bug"
	},
	['strength'] = {
		num = 70,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "strength",
		name = "Strength",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['stringshot'] = {
		num = 81,
		accuracy = 95,
		basePower = 0,
		category = "Status",
		id = "stringshot",
		name = "String Shot",
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			spe = -2
		},
		target = "allAdjacentFoes",
		type = "Bug"
	},
	['struggle'] = {
		num = 165,
		accuracy = true,
		basePower = 50,
		category = "Physical",
		id = "struggle",
		name = "Struggle",
		pp = 1,
		noPPBoosts = true,
		flags = {contact = true, protect = true},
		noSketch = true,
		onModifyMove = function(move, pokemon, target)
			move.type = '???'
			self:add('-activate', pokemon, 'move = Struggle')
		end,
		self = {
			onHit = function(source)
				self:directDamage(source.maxhp / 4, source, source, {id = 'strugglerecoil'})
			end
		},
		target = "randomNormal",
		type = "Normal"
	},
	['strugglebug'] = {
		num = 522,
		accuracy = 100,
		basePower = 50,
		category = "Special",
		id = "strugglebug",
		name = "Struggle Bug",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 100,
			boosts = {
				spa = -1
			}
		},
		target = "allAdjacentFoes",
		type = "Bug"
	},
	['stunspore'] = {
		num = 78,
		accuracy = 75,
		basePower = 0,
		category = "Status",
		id = "stunspore",
		name = "Stun Spore",
		pp = 30,
		flags = {powder = true, protect = true, reflectable = true, mirror = true},
		onTryHit = function(target)
			if not target:runImmunity('powder') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		status = 'par',
		target = "normal",
		type = "Grass"
	},
	['submission'] = {
		num = 66,
		accuracy = 80,
		basePower = 80,
		category = "Physical",
		id = "submission",
		name = "Submission",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		recoil = {1, 4},
		target = "normal",
		type = "Fighting"
	},
	['substitute'] = {
		num = 164,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "substitute",
		name = "Substitute",
		pp = 10,
		flags = {snatch = true, nonsky = true},
		volatileStatus = 'Substitute',
		onTryHit = function(target)
			if target.volatiles['substitute'] then
				self:add('-fail', target, 'move = Substitute')
				return null
			end
			if target.hp <= target.maxhp/4 or target.maxhp == 1 then -- Shedinja clause
				self:add('-fail', target, 'move = Substitute', '[weak]')
				return null
			end
		end,
		onHit = function(target)
			self:directDamage(target.maxhp / 4)
		end,
		effect = {
			onStart = function(target)
				self:add('-start', target, 'Substitute')
				self.effectData.hp = math.floor(target.maxhp / 4)
				target.volatiles['partiallytrapped'] = nil
			end,
			onTryPrimaryHitPriority = -1,
			onTryPrimaryHit = function(target, source, move)
				if target == source or move.flags['authentic'] or move.infiltrates then return end
				local damage = self:getDamage(source, target, move)
				if Not(damage) and damage ~= 0 then
					self:add('-fail', target)
					return null
				end
				damage = self:runEvent('SubDamage', target, source, move, damage)
				if Not(damage) then
					return damage
				end
				if damage > target.volatiles['substitute'].hp then
					damage = target.volatiles['substitute'].hp
				end
				target.volatiles['substitute'].hp = target.volatiles['substitute'].hp - damage
				source.lastDamage = damage
				if target.volatiles['substitute'].hp <= 0 then
					target:removeVolatile('substitute')
				else
					self:add('-activate', target, 'Substitute', '[damage]')
				end
				if move.recoil then
					self:damage(math.floor(damage * move.recoil[1] / move.recoil[2] + 0.5), source, target, 'recoil')
				end
				if move.drain then
					self:heal(math.ceil(damage * move.drain[1] / move.drain[2]), source, target, 'drain')
				end
				self:runEvent('AfterSubDamage', target, source, move, damage)
				return 0 -- hit
			end,
			onEnd = function(target)
				self:add('-end', target, 'Substitute')
			end
		},
		target = "self",
		type = "Normal"
	},
	['suckerpunch'] = {
		num = 389,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "suckerpunch",
		name = "Sucker Punch",
		pp = 5,
		priority = 1,
		flags = {contact = true, protect = true, mirror = true},
		onTry = function(source, target)
			local decision = self:willMove(target)
			if not decision or decision.choice ~= 'move' or (decision.move.category == 'Status' and decision.move.id ~= 'mefirst') or target.volatiles.mustrecharge then
				self:add('-fail', source)
				return null
			end
		end,
		target = "normal",
		type = "Dark"
	},
	['sunnyday'] = {
		num = 241,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "sunnyday",
		name = "Sunny Day",
		pp = 5,
		weather = 'sunnyday',
		target = "all",
		type = "Fire"
	},
	['superfang'] = {
		num = 162,
		accuracy = 90,
		basePower = 0,
		damageCallback = function(pokemon, target)
			return target.hp / 2
		end,
		category = "Physical",
		id = "superfang",
		name = "Super Fang",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['superpower'] = {
		num = 276,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "superpower",
		name = "Superpower",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		self = {
			boosts = {
				atk = -1,
				def = -1
			}
		},
		target = "normal",
		type = "Fighting"
	},
	['supersonic'] = {
		num = 48,
		accuracy = 55,
		basePower = 0,
		category = "Status",
		id = "supersonic",
		name = "Supersonic",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true, sound = true, authentic = true},
		volatileStatus = 'confusion',
		target = "normal",
		type = "Normal"
	},
	['surf'] = {
		num = 57,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "surf",
		name = "Surf",
		pp = 15,
		flags = {protect = true, mirror = true, nonsky = true},
		target = "allAdjacent",
		type = "Water"
	},
	['swagger'] = {
		num = 207,
		accuracy = 85,
		basePower = 0,
		category = "Status",
		id = "swagger",
		name = "Swagger",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'confusion',
		boosts = {
			atk = 2
		},
		target = "normal",
		type = "Normal"
	},
	['swallow'] = {
		num = 256,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "swallow",
		name = "Swallow",
		pp = 10,
		flags = {snatch = true, heal = true},
		onTryHit = function(pokemon)
			if not pokemon.volatiles['stockpile'] or not pokemon.volatiles['stockpile'].layers or pokemon.volatiles['stockpile'].layers == 0 then return false end
		end,
		onHit = function(pokemon)
			local healAmount = {0.25, 0.5, 1}
			self:heal(self:modify(pokemon.maxhp, healAmount[pokemon.volatiles['stockpile'].layers]))
			pokemon:removeVolatile('stockpile')
		end,
		target = "self",
		type = "Normal"
	},
	['sweetkiss'] = {
		num = 186,
		accuracy = 75,
		basePower = 0,
		category = "Status",
		id = "sweetkiss",
		name = "Sweet Kiss",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'confusion',
		target = "normal",
		type = "Fairy"
	},
	['sweetscent'] = {
		num = 230,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "sweetscent",
		name = "Sweet Scent",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			evasion = -2
		},
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['swift'] = {
		num = 129,
		accuracy = true,
		basePower = 60,
		category = "Special",
		id = "swift",
		name = "Swift",
		pp = 20,
		flags = {protect = true, mirror = true},
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['switcheroo'] = {
		num = 415,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "switcheroo",
		name = "Switcheroo",
		pp = 10,
		flags = {protect = true, mirror = true},
		onTryHit = function(target)
			if target:hasAbility('stickyhold') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		onHit = function(target, source)
			local yourItem = target:takeItem(source)
			local myItem = source:takeItem()
			if (target.item and target.item ~= '') or (source.item and source.item ~= '') or ((not yourItem or yourItem == '') and (not myItem or myItem == ''))
				or (myItem and myItem.onTakeItem and myItem.onTakeItem(myItem, target) == false) then

				if yourItem and yourItem ~= '' then
					target.item = yourItem
				end
				if myItem and myItem ~= '' then
					source.item = myItem
				end
				return false
			end
			self:add('-activate', source, 'move = Switcheroo', '[of] ' .. target)
			if myItem and myItem ~= '' then
				target:setItem(myItem)
				self:add('-item', target, myItem, '[from] Switcheroo')
			end
			if yourItem and yourItem ~= '' then
				source:setItem(yourItem)
				self:add('-item', source, yourItem, '[from] Switcheroo')
			end
		end,
		target = "normal",
		type = "Dark"
	},
	['swordsdance'] = {
		num = 14,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "swordsdance",
		name = "Swords Dance",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			atk = 2
		},
		target = "self",
		type = "Normal"
	},
	['synchronoise'] = {
		num = 485,
		accuracy = 100,
		basePower = 120,
		category = "Special",
		id = "synchronoise",
		name = "Synchronoise",
		pp = 10,
		flags = {protect = true, mirror = true},
		onTryHit = function(target, source)
			return target:hasType(source:getTypes())
		end,
		target = "allAdjacent",
		type = "Psychic"
	},
	['synthesis'] = {
		num = 235,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "synthesis",
		name = "Synthesis",
		pp = 5,
		flags = {snatch = true, heal = true},
		onHit = function(pokemon)
			if self:isWeather({'sunnyday', 'desolateland'}) then
				return self:heal(self:modify(pokemon.maxhp, 0.667))
			elseif self:isWeather({'raindance', 'primordialsea', 'sandstorm', 'hail'}) then
				return self:heal(self:modify(pokemon.maxhp, 0.25))
			else
				return self:heal(self:modify(pokemon.maxhp, 0.5))
			end
		end,
		target = "self",
		type = "Grass"
	},
	['tackle'] = {
		num = 33,
		accuracy = 100,
		basePower = 40,
		category = "Physical",
		id = "tackle",
		name = "Tackle",
		pp = 35,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['tailglow'] = {
		num = 294,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "tailglow",
		name = "Tail Glow",
		pp = 20,
		flags = {snatch = true},
		boosts = {
			spa = 3
		},
		target = "self",
		type = "Bug"
	},
	['tailslap'] = {
		num = 541,
		accuracy = 85,
		basePower = 25,
		category = "Physical",
		id = "tailslap",
		name = "Tail Slap",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Normal"
	},
	['tailwhip'] = {
		num = 39,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "tailwhip",
		name = "Tail Whip",
		pp = 30,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			def = -1
		},
		target = "allAdjacentFoes",
		type = "Normal"
	},
	['tailwind'] = {
		num = 366,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "tailwind",
		name = "Tailwind",
		pp = 15,
		flags = {snatch = true},
		sideCondition = 'tailwind',
		effect = {
			duration = 4,
			onStart = function(side)
				self:add('-sidestart', side, 'move = Tailwind')
			end,
			onModifySpe = function(spe, pokemon)
				return self:chainModify(2)
			end,
			onResidualOrder = 21,
			onResidualSubOrder = 4,
			onEnd = function(side)
				self:add('-sideend', side, 'move = Tailwind')
			end
		},
		target = "allySide",
		type = "Flying"
	},
	['takedown'] = {
		num = 36,
		accuracy = 85,
		basePower = 90,
		category = "Physical",
		id = "takedown",
		name = "Take Down",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		recoil = {1, 4},
		target = "normal",
		type = "Normal"
	},
	['taunt'] = {
		num = 269,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "taunt",
		name = "Taunt",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		volatileStatus = 'taunt',
		effect = {
			duration = 3,
			onStart = function(target)
				if target.activeTurns and target.activeTurns > 0 and not self:willMove(target) then
					self.effectData.duration = self.effectData.duration + 1
				end
				self:add('-start', target, 'move = Taunt')
			end,
			onResidualOrder = 12,
			onEnd = function(target)
				self:add('-end', target, 'move = Taunt')
			end,
			onDisableMove = function(pokemon)
				for _, move in pairs(pokemon.moveset) do
					if self:getMove(move.move).category == 'Status' then
						pokemon:disableMove(move.id)
					end
				end
			end,
			onBeforeMovePriority = 5,
			onBeforeMove = function(attacker, defender, move)
				if move.category == 'Status' then
					self:add('cant', attacker, 'move = Taunt', move)
					return false
				end
			end
		},
		target = "normal",
		type = "Dark"
	},
	['technoblast'] = {
		num = 546,
		accuracy = 100,
		basePower = 120,
		category = "Special",
		id = "technoblast",
		name = "Techno Blast",
		pp = 5,
		flags = {protect = true, mirror = true},
		onModifyMove = function(move, pokemon)
			move.type = self:runEvent('Drive', pokemon, nil, 'technoblast', 'Normal')
		end,
		target = "normal",
		type = "Normal"
	},
	['teeterdance'] = {
		num = 298,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "teeterdance",
		name = "Teeter Dance",
		pp = 20,
		flags = {protect = true, mirror = true},
		volatileStatus = 'confusion',
		target = "allAdjacent",
		type = "Normal"
	},
	['telekinesis'] = {
		num = 477,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "telekinesis",
		name = "Telekinesis",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true, gravity = true},
		volatileStatus = 'telekinesis',
		effect = {
			duration = 3,
			onStart = function(target)
				if target.volatiles['smackdown'] or target.volatiles['ingrain'] then return false end
				self:add('-start', target, 'Telekinesis')
			end,
			onAccuracyPriority = -1,
			onAccuracy = function(accuracy, target, source, move)
				if move and not move.ohko then return true end
			end,
			onImmunity = function(type)
				if type == 'Ground' then return false end
			end,
			onResidualOrder = 16,
			onEnd = function(target)
				self:add('-end', target, 'Telekinesis')
			end
		},
		target = "normal",
		type = "Psychic"
	},
	['teleport'] = {
		num = 100,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "teleport",
		name = "Teleport",
		pp = 20,
		priority = -6,
		onTryHit = function(target, source, effect)
			if source.volatiles['partiallytrapped'] or source.trapped or source.maybeTrapped then return false end
			if self.p2.name == '#Wild' then
				self:add('-flee', source)
				self:win(self.p1)
				return 0
			end
			return false
		end,
		target = "self",
		type = "Psychic"
	},

	['thief'] = {
		num = 168,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "thief",
		name = "Thief",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		onHit = function(target, source)
			if source.item and source.item ~= '' then return end
			local yourItem = target:takeItem(source)
			if not yourItem or yourItem == '' then return end
			if not source:setItem(yourItem) then
				target.item = yourItem.id -- bypass setItem so we don't break choicelock or anything
				return
			end
			self:add('-item', source, yourItem, '[from] move = Thief', '[of] ' .. target)
		end,
		target = "normal",
		type = "Dark"
	},

	['thousandarrows'] = {
		num = 614,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "thousandarrows",
		name = "Thousand Arrows",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		isUnreleased = true,
		onEffectiveness = function(typeMult, type, move)
			if move.type ~= 'Ground' then return end
			local target = self.activeTarget
			-- only the attack that grounds the target ignores effectiveness
			-- if called from a chat plugin, don't ignore effectiveness
			if not self.runEvent or Not(self:runEvent('NegateImmunity', target, 'Ground')) then return end
			if not self:getImmunity('Ground', target) then return 1 end
		end,
		volatileStatus = 'smackdown',
		ignoreImmunity = {Ground = true},
		target = "allAdjacentFoes",
		type = "Ground"
	},
	['thousandwaves'] = {
		num = 615,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "thousandwaves",
		name = "Thousand Waves",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		isUnreleased = true,
		onHit = function(target, source, move)
			target:addVolatile('trapped', source, move, 'trapper')
		end,
		target = "normal",
		type = "Ground"
	},
	['thrash'] = {
		num = 37,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "thrash",
		name = "Thrash",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		self = {
			volatileStatus = 'lockedmove'
		},
		onAfterMove = function(pokemon)
			if pokemon.volatiles['lockedmove'] and pokemon.volatiles['lockedmove'].duration == 1 then
				pokemon:removeVolatile('lockedmove')
			end
		end,
		target = "randomNormal",
		type = "Normal"
	},
	['thunder'] = {
		num = 87,
		accuracy = 70,
		basePower = 110,
		category = "Special",
		id = "thunder",
		name = "Thunder",
		pp = 10,
		flags = {protect = true, mirror = true},
		onModifyMove = function(move)
			if self:isWeather({'raindance', 'primordialsea'}) then
				move.accuracy = true
			elseif self:isWeather({'sunnyday', 'desolateland'}) then
				move.accuracy = 50
			end
		end,
		secondary = {
			chance = 30,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},
	['thunderfang'] = {
		num = 422,
		accuracy = 95,
		basePower = 65,
		category = "Physical",
		id = "thunderfang",
		name = "Thunder Fang",
		pp = 15,
		flags = {bite = true, contact = true, protect = true, mirror = true},
		secondaries = { {
			chance = 10,
			status = 'par'
		}, {
				chance = 10,
				volatileStatus = 'flinch'
			}
		},
		target = "normal",
		type = "Electric"
	},
	['thunderpunch'] = {
		num = 9,
		accuracy = 100,
		basePower = 75,
		category = "Physical",
		id = "thunderpunch",
		name = "Thunder Punch",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true, punch = true},
		secondary = {
			chance = 10,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},
	['thundershock'] = {
		num = 84,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "thundershock",
		name = "Thunder Shock",
		pp = 30,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},
	['thunderwave'] = {
		num = 86,
		accuracy = 90,
		basePower = 0,
		category = "Status",
		id = "thunderwave",
		name = "Thunder Wave",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		status = 'par',
		ignoreImmunity = false,
		target = "normal",
		type = "Electric"
	},
	['thunderbolt'] = {
		num = 85,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "thunderbolt",
		name = "Thunderbolt",
		pp = 15,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 10,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},
	['tickle'] = {
		num = 321,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "tickle",
		name = "Tickle",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		boosts = {
			atk = -1,
			def = -1
		},
		target = "normal",
		type = "Normal"
	},
	['topsyturvy'] = {
		num = 576,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "topsyturvy",
		name = "Topsy-Turvy",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		onHit = function(target)
			local targetBoosts = {}
			for i, b in pairs(target.boosts) do
				targetBoosts[i] = -b
			end
			target:setBoost(targetBoosts)
			self:add('-invertboost', target, '[from] move = Topsy-turvy')
		end,
		target = "normal",
		type = "Dark"
	},
	['torment'] = {
		num = 259,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "torment",
		name = "Torment",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true, authentic = true},
		volatileStatus = 'torment',
		effect = {
			onStart = function(pokemon)
				self:add('-start', pokemon, 'Torment')
			end,
			onEnd = function(pokemon)
				self:add('-end', pokemon, 'Torment')
			end,
			onDisableMove = function(pokemon)
				if pokemon.lastMove ~= 'struggle' then
					pokemon:disableMove(pokemon.lastMove)
				end
			end
		},
		target = "normal",
		type = "Dark"
	},
	['toxic'] = {
		num = 92,
		accuracy = 90,
		basePower = 0,
		category = "Status",
		id = "toxic",
		name = "Toxic",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		onModifyMove = function(move, pokemon)
			if pokemon:hasType('Poison') then
				move.accuracy = true
				move.alwaysHit = true
			end
		end,
		status = 'tox',
		target = "normal",
		type = "Poison"
	},
	['toxicspikes'] = {
		num = 390,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "toxicspikes",
		name = "Toxic Spikes",
		pp = 20,
		flags = {reflectable = true, nonsky = true},
		sideCondition = 'toxicspikes',
		effect = {
			-- this is a side condition
			onStart = function(side)
				self:add('-sidestart', side, 'move = Toxic Spikes')
				self.effectData.layers = 1
			end,
			onRestart = function(side)
				if self.effectData.layers >= 2 then return false end
				self:add('-sidestart', side, 'move = Toxic Spikes')
				self.effectData.layers = self.effectData.layers + 1
			end,
			onSwitchIn = function(pokemon)
				local item = pokemon:getItem()
				if not pokemon:isGrounded() then return end
				if item.id == 'heavydutyboots' then return end
				if not pokemon:runImmunity('Poison') then return end
				if pokemon:hasType('Poison') then
					self:add('-sideend', pokemon.side, 'move = Toxic Spikes', '[of] ' .. pokemon)
					pokemon.side:removeSideCondition('toxicspikes')
				elseif self.effectData.layers >= 2 then
					pokemon:trySetStatus('tox', pokemon.side.foe.active[1])
				else
					pokemon:trySetStatus('psn', pokemon.side.foe.active[1])
				end
			end
		},
		target = "foeSide",
		type = "Poison"
	},
	['transform'] = {
		num = 144,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "transform",
		name = "Transform",
		pp = 10,
		onHit = function(target, pokemon)
			if not pokemon:transformInto(target, pokemon) then
				return false
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['triattack'] = {
		num = 161,
		accuracy = 100,
		basePower = 80,
		category = "Special",
		id = "triattack",
		name = "Tri Attack",
		pp = 10,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 20,
			onHit = function(target, source)
				local result = math.random(3)
				if result == 1 then
					target:trySetStatus('brn', source)
				elseif result == 2 then
					target:trySetStatus('par', source)
				else
					target:trySetStatus('frz', source)
				end
			end
		},
		target = "normal",
		type = "Normal"
	},
	['trick'] = {
		num = 271,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "trick",
		name = "Trick",
		pp = 10,
		flags = {protect = true, mirror = true},
		onTryHit = function(target)
			if target:hasAbility('stickyhold') then
				self:add('-immune', target, '[msg]')
				return null
			end
		end,
		onHit = function(target, source)
			local yourItem = target:takeItem(source)
			local myItem = source:takeItem()
			if (target.item and target.item ~= '') or (source.item and source.item ~= '') or ((not yourItem or yourItem == '') and (not myItem or myItem == ''))
				or (type(myItem) == 'table' and myItem.onTakeItem and myItem.onTakeItem(myItem, target) == false) then

				if yourItem and yourItem ~= '' then
					target.item = yourItem
				end
				if myItem and myItem ~= '' then
					source.item = myItem
				end
				return false
			end
			self:add('-activate', source, 'move = Trick', '[of] ' .. target)
			if myItem and myItem ~= '' then
				target:setItem(myItem)
				self:add('-item', target, myItem, '[from] Trick')
			end
			if yourItem and yourItem ~= '' then
				source:setItem(yourItem)
				self:add('-item', source, yourItem, '[from] Trick')
			end
		end,
		target = "normal",
		type = "Psychic"
	},
	['trickortreat'] = {
		num = 567,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "trickortreat",
		name = "Trick-or-Treat",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		onHit = function(target)
			if target:hasType('Ghost') then return false end
			if not target:addType('Ghost') then return false end
			self:add('-start', target, 'typeadd', 'Ghost', '[from] move = Trick-or-Treat')
		end,
		target = "normal",
		type = "Ghost"
	},
	poltergeist = {
		num = 809,
		accuracy = 90,
		basePower = 110,
		category = "Physical",
		name = "Poltergeist",
		id = 'poltergeist',
		pp = 5,
		flags = {protect = true, mirror = true},
		onTry = function(source, target) 
			return (target.item and true or false)
		end,
		onTryHit = function(target, source, move) 
			self:add('-activate', target, 'move: Poltergeist', self:getItem(target.item).name)
		end,
		target = "normal",
		type = "Ghost",
	},
	['trickroom'] = {
		num = 433,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "trickroom",
		name = "Trick Room",
		pp = 5,
		priority = -7,
		flags = {mirror = true},
		onHitField = function(target, source, effect)
			if self.pseudoWeather['trickroom'] then
				self:removePseudoWeather('trickroom', source, effect, '[of] ' .. source)
			else
				self:addPseudoWeather('trickroom', source, effect, '[of] ' .. source)
			end
		end,
		effect = {
			duration = 5,
			onStart = function(target, source)
				self:add('-fieldstart', 'move = Trick Room', '[of] ' .. source)
				self.getStatCallback = function(self, stat, statName)
					-- If stat is speed and does not overflow (Trick Room Glitch) return negative speed.
					if statName == 'spe' and stat <= 1809 then return -stat end
					return stat
				end
			end,
			onResidualOrder = 23,
			onEnd = function()
				self:add('-fieldend', 'move = Trick Room')
				self.getStatCallback = nil
			end
		},
		target = "all",
		type = "Psychic"
	},
	['triplekick'] = {
		num = 167,
		accuracy = 90,
		basePower = 10,
		basePowerCallback = function(pokemon)
			pokemon:addVolatile('triplekick')
			return 10 * pokemon.volatiles['triplekick'].hit
		end,
		category = "Physical",
		id = "triplekick",
		name = "Triple Kick",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true,striker = true},
		multihit = {3, 3},
		effect = {
			duration = 1,
			onStart = function()
				self.effectData.hit = 1
			end,
			onRestart = function()
				self.effectData.hit = self.effectData.hit + 1
			end
		},
		onAfterMove = function(pokemon)
			pokemon:removeVolatile('triplekick')
		end,
		target = "normal",
		type = "Fighting"
	},
	['trumpcard'] = {
		num = 376,
		accuracy = true,
		basePower = 0,
		basePowerCallback = function(pokemon)
			local move = pokemon:getMoveData(pokemon.lastMove) -- Account for calling Trump Card via other moves
			if move.pp == 0 then
				return 200
			elseif move.pp == 1 then
				return 80
			elseif move.pp == 2 then
				return 60
			elseif move.pp == 3 then
				return 50
			end
			return 40
		end,
		category = "Special",
		id = "trumpcard",
		name = "Trump Card",
		pp = 5,
		noPPBoosts = true,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['twineedle'] = {
		num = 41,
		accuracy = 100,
		basePower = 25,
		category = "Physical",
		id = "twineedle",
		name = "Twineedle",
		pp = 20,
		flags = {protect = true, mirror = true},
		multihit = {2, 2},
		secondary = {
			chance = 20,
			status = 'psn'
		},
		target = "normal",
		type = "Bug"
	},
	['twister'] = {
		num = 239,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "twister",
		name = "Twister",
		pp = 20,
		flags = {protect = true, mirror = true},
		secondary = {
			chance = 20,
			volatileStatus = 'flinch'
		},
		target = "allAdjacentFoes",
		type = "Dragon"
	},
	['uturn'] = {
		num = 369,
		accuracy = 100,
		basePower = 70,
		category = "Physical",
		id = "uturn",
		name = "U-turn",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		selfSwitch = true,
		target = "normal",
		type = "Bug"
	},
	['uproar'] = {
		num = 253,
		accuracy = 100,
		basePower = 90,
		category = "Special",
		id = "uproar",
		name = "Uproar",
		pp = 10,
		flags = {protect = true, mirror = true, sound = true, authentic = true},
		self = {
			volatileStatus = 'uproar'
		},
		onTryHit = function(target)
			for _, side in pairs(target.battle.sides) do
				for _, pokemon in pairs(side.active) do
					if pokemon ~= null and pokemon.status == 'slp' then
						pokemon:cureStatus()
					end
				end
			end
		end,
		effect = {
			duration = 3,
			onStart = function(target)
				self:add('-start', target, 'Uproar')
			end,
			onResidual = function(target)
				if target.lastMove == 'struggle' then
					-- don't lock
					target.volatiles['uproar'] = nil
				end
				self:add('-start', target, 'Uproar', '[upkeep]')
			end,
			onEnd = function(target)
				self:add('-end', target, 'Uproar')
			end,
			onLockMove = 'uproar',
			onAnySetStatus = function(status, pokemon)
				if status.id == 'slp' then
					if pokemon == self.effectData.target then
						self:add('-fail', pokemon, 'slp', '[from] Uproar', '[msg]')
					else
						self:add('-fail', pokemon, 'slp', '[from] Uproar')
					end
					return null
				end
			end,
			onAnyTryHit = function(target, source, move)
				if move and move.id == 'yawn' then
					return false
				end
			end
		},
		target = "randomNormal",
		type = "Normal"
	},
	['vcreate'] = {
		num = 557,
		accuracy = 95,
		basePower = 180,
		category = "Physical",
		id = "vcreate",
		name = "V-create",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		self = {
			boosts = {
				spe = -1,
				def = -1,
				spd = -1
			}
		},
		target = "normal",
		type = "Fire"
	},
	['vacuumwave'] = {
		num = 410,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "vacuumwave",
		name = "Vacuum Wave",
		pp = 30,
		priority = 1,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Fighting"
	},
	['venomdrench'] = {
		num = 599,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "venomdrench",
		name = "Venom Drench",
		pp = 20,
		flags = {protect = true, reflectable = true, mirror = true},
		onHit = function(target, source, move)
			if target.status == 'psn' or target.status == 'tox' then
				return self:boost({atk = -1, spa = -1, spe = -1}, target, source, move)
			end
			return false
		end,
		target = "allAdjacentFoes",
		type = "Poison"
	},
	['venoshock'] = {
		num = 474,
		accuracy = 100,
		basePower = 65,
		category = "Special",
		id = "venoshock",
		name = "Venoshock",
		pp = 10,
		flags = {protect = true, mirror = true},
		onBasePowerPriority = 4,
		onBasePower = function(basePower, pokemon, target)
			if target.status == 'psn' or target.status == 'tox' then
				return self:chainModify(2)
			end
		end,
		target = "normal",
		type = "Poison"
	},
	['visegrip'] = {
		num = 11,
		accuracy = 100,
		basePower = 55,
		category = "Physical",
		id = "visegrip",
		name = "Vise Grip",
		pp = 30,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['vinewhip'] = {
		num = 22,
		accuracy = 100,
		basePower = 45,
		category = "Physical",
		id = "vinewhip",
		name = "Vine Whip",
		pp = 25,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Grass"
	},
	['vitalthrow'] = {
		num = 233,
		accuracy = true,
		basePower = 70,
		category = "Physical",
		id = "vitalthrow",
		name = "Vital Throw",
		pp = 10,
		priority = -1,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Fighting"
	},
	['voltswitch'] = {
		num = 521,
		accuracy = 100,
		basePower = 70,
		category = "Special",
		id = "voltswitch",
		name = "Volt Switch",
		pp = 20,
		flags = {protect = true, mirror = true},
		selfSwitch = true,
		target = "normal",
		type = "Electric"
	},
	['volttackle'] = {
		num = 344,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "volttackle",
		name = "Volt Tackle",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		recoil = {33, 100},
		secondary = {
			chance = 10,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},
	['wakeupslap'] = {
		num = 358,
		accuracy = 100,
		basePower = 70,
		basePowerCallback = function(pokemon, target)
			if target.status == 'slp' then return 140 end
			return 70
		end,
		category = "Physical",
		id = "wakeupslap",
		name = "Wake-Up Slap",
		pp = 10,
		flags = {contact = true, protect = true, mirror = true},
		onHit = function(target)
			if target.status == 'slp' then
				target:cureStatus()
			end
		end,
		target = "normal",
		type = "Fighting"
	},
	['watergun'] = {
		num = 55,
		accuracy = 100,
		basePower = 40,
		category = "Special",
		id = "watergun",
		name = "Water Gun",
		pp = 25,
		flags = {protect = true, mirror = true},
		target = "normal",
		type = "Water"
	},
	['waterpledge'] = {
		num = 518,
		accuracy = 100,
		basePower = 80,
		basePowerCallback = function(target, source, move)
			if move.sourceEffect == 'firepledge' or move.sourceEffect == 'grasspledge' then
				self:add('-combine')
				return 150
			end
			return 80
		end,
		category = "Special",
		id = "waterpledge",
		name = "Water Pledge",
		pp = 10,
		flags = {protect = true, mirror = true, nonsky = true},
		onPrepareHit = function(target, source, move)
			for _, decision in pairs(self.queue) do
				if decision.move and decision.pokemon and decision.pokemon.isActive and not decision.pokemon.fainted then
					if decision.pokemon.side == source.side and (decision.move.id == 'firepledge' or decision.move.id == 'grasspledge') then
						self:prioritizeQueue(decision)
						self:add('-waiting', source, decision.pokemon)
						return null
					end
				end
			end
		end,
		onModifyMove = function(move)
			if move.sourceEffect == 'grasspledge' then
				move.type = 'Grass'
				move.hasSTAB = true
			end
			if move.sourceEffect == 'firepledge' then
				move.type = 'Water'
				move.hasSTAB = true
			end
		end,
		onHit = function(target, source, move)
			if move.sourceEffect == 'firepledge' then
				source.side:addSideCondition('waterpledge')
			end
			if move.sourceEffect == 'grasspledge' then
				target.side:addSideCondition('grasspledge')
			end
		end,
		effect = {
			duration = 4,
			onStart = function(targetSide)
				self:add('-sidestart', targetSide, 'Water Pledge')
			end,
			onEnd = function(targetSide)
				self:add('-sideend', targetSide, 'Water Pledge')
			end,
			onModifyMove = function(move)
				if move.secondaries and move.id ~= 'secretpower' then
					self:debug('doubling secondary chance')
					for _, s in pairs(move.secondaries) do
						if s.chance then
							s.chance = s.chance * 2
						end
					end
				end
			end
		},
		target = "normal",
		type = "Water"
	},
	['waterpulse'] = {
		num = 352,
		accuracy = 100,
		basePower = 60,
		category = "Special",
		id = "waterpulse",
		name = "Water Pulse",
		pp = 20,
		flags = {protect = true, pulse = true, mirror = true, distance = true},
		secondary = {
			chance = 20,
			volatileStatus = 'confusion'
		},
		target = "any",
		type = "Water"
	},
	['watersport'] = {
		num = 346,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "watersport",
		name = "Water Sport",
		pp = 15,
		flags = {nonsky = true},
		onHitField = function(target, source, effect)
			if self.pseudoWeather['watersport'] then
				return false
			else
				self:addPseudoWeather('watersport', source, effect, '[of] ' .. source)
			end
		end,
		effect = {
			duration = 5,
			onStart = function(side, source)
				self:add('-fieldstart', 'move = Water Sport', '[of] ' .. source)
			end,
			onBasePowerPriority = 1,
			onBasePower = function(basePower, attacker, defender, move)
				if move.type == 'Fire' then
					self:debug('water sport weaken')
					return self:chainModify(0x548, 0x1000) 
				end
			end,
			onResidualOrder = 21,
			onEnd = function()
				self:add('-fieldend', 'move = Water Sport')
			end
		},
		target = "all",
		type = "Water"
	},
	['waterspout'] = {
		num = 323,
		accuracy = 100,
		basePower = 150,
		basePowerCallback = function(pokemon)
			return 150 * pokemon.hp / pokemon.maxhp
		end,
		category = "Special",
		id = "waterspout",
		name = "Water Spout",
		pp = 5,
		flags = {protect = true, mirror = true},
		target = "allAdjacentFoes",
		type = "Water"
	},
	['waterfall'] = {
		num = 127,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "waterfall",
		name = "Waterfall",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 20,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Water"
	},
	['watershuriken'] = {
		num = 594,
		accuracy = 100,
		basePower = 15,
		basePowerCallback = function(pokemon, target, move)
			if pokemon.template.species == 'Greninja' and pokemon.template.forme == 'Ash' and pokemon:hasAbility('battlebond') then
				--				self:debug('water shuriken base power:', move.basePower + 5)
				return move.basePower + 5
			end
			return move.basePower
		end,
		category = "Special",
		id = "watershuriken",
		name = "Water Shuriken",
		pp = 20,
		priority = 1,
		flags = {protect = true, mirror = true},
		multihit = {2, 5},
		target = "normal",
		type = "Water"
	},
	['weatherball'] = {
		num = 311,
		accuracy = 100,
		basePower = 50,
		basePowerCallback = function()
			if self.weather and self.weather ~= '' then return 100 end
			return 50
		end,
		category = "Special",
		id = "weatherball",
		name = "Weather Ball",
		pp = 10,
		flags = {bullet = true, protect = true, mirror = true},
		onModifyMove = function(move)
			local w = self:effectiveWeather()
			if w == 'sunnyday' or w == 'desolateland' then
				move.type = 'Fire'
			elseif w == 'raindance' or w == 'primordialsea' then
				move.type = 'Water'
			elseif w == 'sandstorm' then
				move.type = 'Rock'
			elseif w == 'hail' then
				move.type = 'Ice'
			end
		end,
		target = "normal",
		type = "Normal"
	},
	['whirlpool'] = {
		num = 250,
		accuracy = 85,
		basePower = 35,
		category = "Special",
		id = "whirlpool",
		name = "Whirlpool",
		pp = 15,
		flags = {protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Water"
	},
	['whirlwind'] = {
		num = 18,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "whirlwind",
		name = "Whirlwind",
		pp = 20,
		priority = -6,
		flags = {reflectable = true, mirror = true, authentic = true},
		forceSwitch = true,
		target = "normal",
		type = "Normal"
	},
	['wideguard'] = {
		num = 469,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "wideguard",
		name = "Wide Guard",
		pp = 10,
		priority = 3,
		flags = {snatch = true},
		sideCondition = 'wideguard',
		onTryHitSide = function(side, source)
			return self:willAct()
		end,
		onHitSide = function(side, source)
			source:addVolatile('stall')
		end,
		effect = {
			duration = 1,
			onStart = function(target, source)
				self:add('-singleturn', source, 'Wide Guard')
			end,
			onTryHitPriority = 4,
			onTryHit = function(target, source, effect)
				-- Wide Guard blocks damaging spread moves
				if effect and (effect.category == 'Status' or (effect.target ~= 'allAdjacent' and effect.target ~= 'allAdjacentFoes')) then
					return
				end
				self:add('-activate', target, 'Wide Guard')
				local lockedmove = source:getVolatile('lockedmove')
				if lockedmove then
					-- Outrage counter is reset
					if source.volatiles['lockedmove'].duration == 2 then
						source.volatiles['lockedmove'] = nil
					end
				end
				return null
			end
		},
		target = "allySide",
		type = "Rock"
	},
	['wildcharge'] = {
		num = 528,
		accuracy = 100,
		basePower = 90,
		category = "Physical",
		id = "wildcharge",
		name = "Wild Charge",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		recoil = {1, 4},
		target = "normal",
		type = "Electric"
	},
	['willowisp'] = {
		num = 261,
		accuracy = 85,
		basePower = 0,
		category = "Status",
		id = "willowisp",
		name = "Will-O-Wisp",
		pp = 15,
		flags = {protect = true, reflectable = true, mirror = true},
		status = 'brn',
		target = "normal",
		type = "Fire"
	},
	['wingattack'] = {
		num = 17,
		accuracy = 100,
		basePower = 60,
		category = "Physical",
		id = "wingattack",
		name = "Wing Attack",
		pp = 35,
		flags = {contact = true, protect = true, mirror = true, distance = true},
		target = "any",
		type = "Flying"
	},
	['wish'] = {
		num = 273,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "wish",
		name = "Wish",
		pp = 10,
		flags = {snatch = true, heal = true},
		sideCondition = 'Wish',
		effect = {
			duration = 2,
			onStart = function(side, source)
				self.effectData.hp = source.maxhp / 2
			end,
			onResidualOrder = 4,
			onEnd = function(side)
				local target = side.active[self.effectData.sourcePosition]
				if target ~= null and not target.fainted then
					local source = self.effectData.source
					local damage = self:heal(self.effectData.hp, target, target)
					if damage then
						self:add('-heal', target, target.getHealth, '[from] move = Wish', '[wisher] ' .. source.name)
					end
				end
			end
		},
		target = "self",
		type = "Normal"
	},
	['withdraw'] = {
		num = 110,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "withdraw",
		name = "Withdraw",
		pp = 40,
		flags = {snatch = true},
		boosts = {
			def = 1
		},
		target = "self",
		type = "Water"
	},
	['wonderroom'] = {
		num = 472,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "wonderroom",
		name = "Wonder Room",
		pp = 10,
		flags = {mirror = true},
		onHitField = function(target, source, effect)
			if self.pseudoWeather['wonderroom'] then
				self:removePseudoWeather('wonderroom', source, effect, '[of] ' .. source)
			else
				self:addPseudoWeather('wonderroom', source, effect, '[of] ' .. source)
			end
		end,
		effect = {
			duration = 5,
			onStart = function(side, source)
				self:add('-fieldstart', 'move = WonderRoom', '[of] ' .. source)
			end,
			onModifyMovePriority = -100,
			onModifyMove = function(move)
				move.defensiveCategory = ((move.defensiveCategory or self:getCategory(move)) == 'Physical') and 'Special' or 'Physical'
				self:debug('Defensive Category = ' .. move.defensiveCategory)
			end,
			onResidualOrder = 24,
			onEnd = function()
				self:add('-fieldend', 'move = Wonder Room')
			end
		},
		target = "all",
		type = "Psychic"
	},
	['woodhammer'] = {
		num = 452,
		accuracy = 100,
		basePower = 120,
		category = "Physical",
		id = "woodhammer",
		name = "Wood Hammer",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		recoil = {33, 100},
		target = "normal",
		type = "Grass"
	},
	['workup'] = {
		num = 526,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "workup",
		name = "Work Up",
		pp = 30,
		flags = {snatch = true},
		boosts = {
			atk = 1,
			spa = 1
		},
		target = "self",
		type = "Normal"
	},
	['worryseed'] = {
		num = 388,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		id = "worryseed",
		name = "Worry Seed",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		onTryHit = function(pokemon)
			local bannedAbilities = {insomnia=true, multitype=true, stancechange=true, truant=true}
			if bannedAbilities[pokemon.ability] then
				return false
			end
		end,
		onHit = function(pokemon)
			local oldAbility = pokemon:setAbility('insomnia')
			if oldAbility then
				self:add('-endability', pokemon, oldAbility, '[from] move: Worry Seed')
				self:add('-ability', pokemon, 'Insomnia', '[from] move = Worry Seed')
				if pokemon.status == 'slp' then
					pokemon:cureStatus()
				end
				return
			end
			return false
		end,
		target = "normal",
		type = "Grass"
	},
	['wrap'] = {
		num = 35,
		accuracy = 90,
		basePower = 15,
		category = "Physical",
		id = "wrap",
		name = "Wrap",
		pp = 20,
		flags = {contact = true, protect = true, mirror = true},
		volatileStatus = 'partiallytrapped',
		target = "normal",
		type = "Normal"
	},
	['wringout'] = {
		num = 378,
		accuracy = 100,
		basePower = 0,
		basePowerCallback = function(pokemon, target)
			return math.max(1, math.floor(math.floor((120 * (100 * math.floor(target.hp * 4096 / target.maxhp)) + 2048 - 1) / 4096) / 100))
		end,
		category = "Special",
		id = "wringout",
		name = "Wring Out",
		pp = 5,
		flags = {contact = true, protect = true, mirror = true},
		target = "normal",
		type = "Normal"
	},
	['xscissor'] = {
		num = 404,
		accuracy = 100,
		basePower = 80,
		category = "Physical",
		id = "xscissor",
		name = "X-Scissor",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true,blademaster = true},
		target = "normal",
		type = "Bug"
	},
	corrosivegas = {
		num = 810,
		accuracy = 100,
		basePower = 0,
		category = "Status",
		name = "Corrosive Gas",
		id = 'corrosivegas',
		pp = 40,
		flags = {protect = true, reflectable = true, mirror = true, mystery = true},
		onHit = function(target, source)
			local item = target:takeItem(source)
			if (item) then
				self:add('-enditem', target, item.name, '[from] move: Corrosive Gas', '[of] '..source)
			end
		end,
		target = "allAdjacent",
		type = "Poison",
	},
	coaching = {
		num = 811,
		accuracy = true,
		basePower = 0,
		category = "Status",
		name = "Coaching",
		id = 'coaching',
		pp = 10,
		flags = {authentic = true},
		boosts = {
			atk = 1,
			def = 1,
		},
		target = "adjacentAlly",
		type = "Fighting",
	},
	['yawn'] = {
		num = 281,
		accuracy = true,
		basePower = 0,
		category = "Status",
		id = "yawn",
		name = "Yawn",
		pp = 10,
		flags = {protect = true, reflectable = true, mirror = true},
		volatileStatus = 'yawn',
		onTryHit = function(target)
			if (target.status and target.status ~= '') or not target:runImmunity('slp') then
				return false
			end
		end,
		effect = {
			noCopy = true, -- doesn't get copied by Baton Pass
			duration = 2,
			onStart = function(target, source)
				self:add('-start', target, 'move = Yawn', '[of] ' .. source)
			end,
			onEnd = function(target)
				self:add('-end', target, 'move: Yawn', '[silent]')
				target:trySetStatus('slp')
			end
		},
		target = "normal",
		type = "Normal"
	},
	['zapcannon'] = {
		num = 192,
		accuracy = 50,
		basePower = 120,
		category = "Special",
		id = "zapcannon",
		name = "Zap Cannon",
		pp = 5,
		flags = {bullet = true, protect = true, mirror = true},
		secondary = {
			chance = 100,
			status = 'par'
		},
		target = "normal",
		type = "Electric"
	},

	['zenheadbutt'] = {
		num = 428,
		accuracy = 90,
		basePower = 80,
		category = "Physical",
		id = "zenheadbutt",
		name = "Zen Headbutt",
		pp = 15,
		flags = {contact = true, protect = true, mirror = true},
		secondary = {
			chance = 20,
			volatileStatus = 'flinch'
		},
		target = "normal",
		type = "Psychic"
	},

--gen 8 moves





['astralbarrage'] = {
	num = 721,
	accuracy = 100,
	basePower = 120,
	category = "Special",
	id = "astralbarrage",
	name = "Astral Barrage",
	pp = 5,
	flags = {protect = true, mirror = true, nonsky = true},
	target = "allAdjacentFoes",

	type = "Ghost"
},

['aurawheel'] = {
	num = 722,
	accuracy = 100,
	basePower = 110,
	category = "Physical",
	id = "aurawheel",
	name = "Aura Wheel",
	pp = 10,
	flags = {contact = true, protect = true, mirror = true},

	target = "normal",
	type = "Electric"
},	

['behemothbash'] = {
	num = 723,
	accuracy = 100,
	basePower = 100,
	category = "Physical",
	id = "behemothbash",
	name = "Behemoth Bash",
	pp = 5,
	flags = {contact = true, protect = true, mirror = true},

	target = "normal",
	type = "Steel"
},	

['behemothblade'] = {
	num = 724,
	accuracy = 100,
	basePower = 100,
	category = "Physical",
	id = "behemothblade",
	name = "Behemoth Blade",
	pp = 5,
	flags = {contact = true, protect = true, mirror = true},

	target = "normal",
	type = "Steel"
},


['branchpoke'] = {
	num = 725,
	accuracy = 100,
	basePower = 40,
	category = "Physical",
	id = "branchpoke",
	name = "Branch Poke",
	pp = 40,
	flags = {contact = true, protect = true, mirror = true},
	target = "normal",
	type = "Grass"
},
['drumbeating'] = {
	num = 726,
	accuracy = 100,
	basePower = 80,
	category = "Physical",
	id = "drumbeating",
	name = "Drum Beating",
	pp = 10,
	flags = {protect = true, mirror = true, nonsky = true},
	secondary = {
		chance = 100,
		boosts = {
			spe = -1
		}
	},
	target = "normal",
	type = "Grass"
},

['pyroball'] = {
	num = 727,
	accuracy = 90,
	basePower = 120,
	category = "Special",
	id = "pyroball",
	name = "Pyro Ball",
	pp = 5,
	flags = {bullet = true, protect = true, mirror = true,striker = true},
	secondary = {
		chance = 10,
		status = 'brn'
	},
	target = "normal",
	type = "Fire"
},

['monkepower'] = {
	num = 728,
	accuracy = 100,
	basePower = 180,
	category = "Physical",
	id = "monkepower",
	name = "Monke Power",
	pp = 15,
	flags = {contact = true, protect = true, mirror = true},
	self = {
		boosts = {
			def = 1,
			spd = -1
		}
	},
	target = "normal",
	type = "Fighting"
},

['snipeshot'] = {
	num = 729,
	accuracy = 100,
	basePower = 80,
	category = "Special",
	id = "snipeshot",
	name = "Snipe Shot",
	pp = 15,
	flags = {contact = true, protect = true, mirror = true},
	target = "normal",
	type = "Water"
},

['breakingswipe'] = {
	num = 730,
	accuracy = 100,
	basePower = 60,
	category = "Physical",
	id = "breakingswipe",
	name = "Breaking Swipe",
	pp = 15,
	flags = {protect = true, mirror = true, nonsky = true},
	secondary = {
		chance = 100,
		boosts = {
			atk = -1
		}
	},
	target = "allAdjacent",
	type = "Dragon"
},

['jawlock'] = {
	num = 731,
	accuracy = 100,
	basePower = 80,
	category = "Physical",
	id = "jawlock",
	name = "Jaw Lock",
	pp = 10,
	flags = {contact = true, protect = true, mirror = true},
	volatileStatus = 'partiallytrapped',
	target = "normal",
	type = "Dark"
},

['tarshot'] = {
	num = 732,
	accuracy = 100,
	basePower = 0,
	category = "Status",
	id = "tarshot",
	name = "Tar Shot",
	pp = 15,
	flags = {protect = true, reflectable = true, mirror = true},
	boosts = {
		spe = -1
	},
	target = "normal",
	type = "Rock"
},

['gravapple'] = {
	num = 733,
	accuracy = 100,
	basePower = 80,
	category = "Physical",
	id = "gravapple",
	name = "Grav Apple",
	pp = 10,
	flags = { protect = true, mirror = true},
	onBasePower = function(basePower)
		if (self:getPseudoWeather('gravity')) then
			return self:chainModify(1.5)
		end
	end,
	secondary = {
		chance = 100,
		boosts = {
			def = -1
		}
	},
	target = "normal",
	type = "Grass"
},

['appleacid'] = {
	num = 720,
	accuracy = 100,
	basePower = 80,
	category = "Special",
	id = "appleacid",
	name = "Apple Acid",
	pp = 10,
	flags = { protect = true, mirror = true},
	secondary = {
		chance = 100,
		boosts = {
			spd = -1
		}
	},
	target = "normal",
	type = "Grass"
},

['magicpowder'] = {
	num = 721,
	accuracy = 100,
	basePower = 0,
	category = "Status",
	id = "magicpowder",
	name = "Forest's Curse",
	pp = 20,
	flags = {protect = true, reflectable = true, mirror = true},
	onHit = function(target)
		if target:hasType('Psychic') then return false end
		if not target:addType('Psychic') then return false end
		self:add('-start', target, 'typeadd', 'Psychic', '[from] move = Magic Powder')
	end,
	target = "normal",
	type = "Psychic"
},

['meteorassault'] = {
	num = 722,
	accuracy = 100,
	basePower = 150,
	category = "Physical",
	id = "meteorassault",
	name = "Meteor Assault",
	pp = 5,
	flags = {recharge = true, protect = true, mirror = true},
	self = {
		volatileStatus = 'mustrecharge'
	},
	target = "normal",
	type = "Fighting"
},

['eternabeam'] = {
	num = 732,
	accuracy = 90,
	basePower = 160,
	category = "Special",
	id = "eternabeam",
	name = "Eternabeam",
	pp = 5,
	flags = {recharge = true, protect = true, mirror = true},
	self = {
		volatileStatus = 'mustrecharge'
	},
	target = "normal",
	type = "Dragon"
},


['junglehealing'] = {
	num = 733,
	accuracy = true,
	basePower = 0,
	category = "Status",
	id = "junglehealing",
	name = "Jungle Healing",
	pp = 10,
	flags = {snatch = true, sound = true, distance = true, authentic = true},
	onHit = function(pokemon, source)
		for _, ally in pairs(pokemon.side.pokemon) do
			ally.status = ''
		end
		self:add('-cureteam', source, '[from] move = JungleHealing')
	end,
	heal = {1, 2},
	target = "allyTeam",
	type = "Grass"
},	

['lifedew'] = {
	num = 734,
	accuracy = true,
	basePower = 0,
	category = "Status",
	id = "lifedew",
	name = "Life Dew",
	pp = 10,
	flags = {snatch = true, heal = true},
	heal = {1, 2},
	target = "allyTeam",
	type = "Water"
},

['boltbeak'] = {
	num = 735,
	accuracy = 100,
	basePower = 85,
	basePowerCallback = function(pokemon, target)
		if target.choice == 'move' then return 170 end
		return 85
	end,
	category = "Physical",
	id = "boltbeak",
	name = "Bolt Beak",
	pp = 10,
	priority = 1,
	flags = {contact = true, protect = true, mirror = true},
	target = "normal",
	type = "Electric"
},


['fishiousrend'] = {
	num = 736,
	accuracy = 100,
	basePower = 85,
	basePowerCallback = function(pokemon, target)
		if target.choice == 'move' then return 170 end
		return 85
	end,
	category = "Physical",
	id = "fishiousrend",
	name = "Fishious Rend",
	pp = 10,
	priority = 1,
	flags = {contact = true, protect = true, mirror = true},
	target = "normal",
	type = "Water"
},

['wickedblow'] = {
	num = 737,
	accuracy = 100,
	basePower = 80,
	category = "Physical",
	id = "wickedblow",
	name = "Wicked Blow",
	pp = 10,
	flags = {contact = true, protect = true, mirror = true},
	willCrit = true,
	target = "normal",
	type = "Dark"
},

['thundercage'] = {
	num = 738,
	accuracy = 90,
	basePower = 80,
	category = "Special",
	id = "thundercage",
	name = "Thunder Cage",
	pp = 15,
	flags = {protect = true, mirror = true},
	volatileStatus = 'partiallytrapped',
	target = "normal",
	type = "Electric"
},

['dragonenergy'] = {
	num = 739,
	accuracy = 100,
	basePower = 150,
	basePowerCallback = function(pokemon)
		return 150 * pokemon.hp / pokemon.maxhp
	end,
	category = "Special",
	id = "dragonenergy",
	name = "Dragon Energy",
	pp = 5,
	flags = {protect = true, mirror = true},
	target = "allAdjacentFoes",
	type = "Dragon"
},

['shellsidearm'] = {
	num = 740,
	accuracy = 100,
	basePower = 90,
	category = "Physical",
	id = "shellsidearm",
	name = "Shell Side Arm",
	pp = 10,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 30,
		status = 'psn'
	},
	target = "normal",
	type = "Poison"
},

['eeriespell'] = {
	num = 741,
	accuracy = 100,
	basePower = 80,
	category = "Special",
	id = "eeriespell",
	name = "Eerie Spell",
	pp = 10,
	flags = {protect = true, reflectable = true, mirror = true, authentic = true},
	onHit = function(target)
		if target:deductPP(target.lastMove, 3) then
			self:add('-activate', target, 'Eerie Spell', self:getMove(target.lastMove).name, 3)
			return
		end
		return false
	end,
	target = "normal",
	type = "Psychic"
},

['strangesteam'] = {
	num = 742,
	accuracy = 95,
	basePower = 90,
	category = "Special",
	id = "strangesteam",
	name = "Strange Steam",
	pp = 10,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 20,
		volatileStatus = 'confusion'
	},
	target = "normal",
	type = "Fairy"
},

['freezingglare'] = {
	num = 743,
	accuracy = 100,
	basePower = 90,
	category = "Special",
	id = "freezingglare",
	name = "Freezing Glare",
	pp = 10,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 10,
		status = 'frz'
	},
	target = "normal",
	type = "Psychic"
},



['fierywrath'] = {
	num = 745,
	accuracy = 100,
	basePower = 90,
	category = "Special",
	id = "fierywrath",
	name = "Fiery Wrath",
	pp = 10,
	flags = {protect = true, mirror = true},
	secondary = {
		chance = 20,
		volatileStatus = 'flinch'
	},
	target = "normal",
	type = "Dark"
},

['snaptrap'] = {
	num = 746,
	accuracy = 100,
	basePower = 35,
	category = "Physical",
	id = "snaptrap",
	name = "Snap Trap",
	pp = 15,
	flags = {protect = true, mirror = true},
	volatileStatus = 'partiallytrapped',
	target = "normal",
	type = "Grass"
},

['glaciallance'] = {
	num = 747,
	accuracy = 100,
	basePower = 130,
	category = "Physical",
	id = "glaciallance",
	name = "Glacial Lance",
	pp = 5,
	flags = {protect = true, mirror = true, nonsky = true},
	target = "allAdjacentFoes",
	type = "Ice"
},

['stuffcheeks'] = {
	num = 748,
	accuracy = true,
	basePower = 0,
	category = "Status",
	name = "Stuff Cheeks",
	id = 'stuffcheeks',
	pp = 10,
	flags = {snatch = true},
	onTry = function(source)
		local item = source:getItem();
		if (item.isBerry and source:eatItem(true)) then
			self:boost({def = 2}, source, nil, nil, false, true)
		else
			return false
		end
	end,
	target = "self",
	type = "Normal",
},

['grassyglide'] = {
	num = 803,
	accuracy = 100,
	basePower = 70,
	category = "Physical",
	id = "grassyglide",
	name = "Grassy Glide",
	pp = 20,
	priority = 6,
	flags = {contact = true, protect = true, mirror = true},
	onModifyPriority = function(priority, source, target, move)
		if self:isTerrain ("grassyterrain") then
			print ("TERRAIN IS UP")
			return priority + 1				
		end
	end,
	target = "normal",
	type = "Grass"

},

}