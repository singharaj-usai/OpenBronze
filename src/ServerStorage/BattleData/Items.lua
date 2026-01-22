local null, Not; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	null = util.null
	Not = util.Not
end

--[[
	Todo:
	Weakness Policy (logic seems wrong - move.damge == 0 ?)
	
	
--]]

self = nil -- to hush intelisense; self property is injected at object-call simulation; see BattleEngine::call / BattleEngine::callAs

local function onTakeMegaStone(item, source)
	if item.megaEvolves == source.baseTemplate.baseSpecies then return false end
	return true
end

local function onTakeDrive(item, pokemon, source)
	if (source and source.baseTemplate.num == 649) or pokemon.baseTemplate.num == 649 then return false end
	return true
end

local function superEffectiveReductionBerry(berryType)
	return function(damage, source, target, move)
		if move.type == berryType and move.typeMod > 0 and not target.volatiles['substitute'] then -- self:getEffectiveness(move, target) > 1
			if target:eatItem() then
				self:debug('-50% reduction')
				return self:chainModify(0.5)
			end
		end
	end
end

local function gem(gemType, pledges)
	return function(target, source, move)
		if target == source or move.category == 'Status' or (pledges and ({firepledge=true, grasspledge=true, waterpledge=true})[move.id]) then return end
		if move.type == gemType then
			if source:useItem() then
				self:add('-enditem', source, gemType..' Gem', '[from] gem', '[move] ' .. move.name)
				source:addVolatile('gem')
			end
		end
	end
end

local function onTakePlate(item, pokemon, source)
	if (source and source.baseTemplate.num == 493) or pokemon.baseTemplate.num == 493 then
		return false
	end
	return true
end

local function plate(plateType)
	return function(basePower, user, target, move)
		if move and move.type == plateType then
			return self:chainModify(0x1333, 0x1000)
		end
	end
end

--[[
23:37:54.063 - No core Item data for energyroot
23:37:54.064 - No core Item data for healpowder
23:37:54.064 - No core Item data for revivalherb
23:37:54.066 - No core Item data for sacredash
23:37:54.066 - No core Item data for hpup
23:37:54.067 - No core Item data for protein
23:37:54.067 - No core Item data for iron
23:37:54.067 - No core Item data for carbos
23:37:54.068 - No core Item data for calcium
23:37:54.068 - No core Item data for rarecandy
23:37:54.068 - No core Item data for ppup
23:37:54.069 - No core Item data for zinc
23:37:54.069 - No core Item data for ppmax
23:37:54.070 - No core Item data for oldgateau
23:37:54.070 - No core Item data for guardspec
23:37:54.070 - No core Item data for direhit
23:37:54.071 - No core Item data for xattack
23:37:54.071 - No core Item data for xdefense
23:37:54.071 - No core Item data for xspeed
23:37:54.072 - No core Item data for xaccuracy
23:37:54.072 - No core Item data for xspatk
23:37:54.072 - No core Item data for xspdef
23:37:54.072 - No core Item data for pokedoll
23:37:54.073 - No core Item data for fluffytail

23:37:54.073 - No core Item data for blueflute
23:37:54.073 - No core Item data for yellowflute
23:37:54.074 - No core Item data for redflute
23:37:54.074 - No core Item data for blackflute
23:37:54.074 - No core Item data for whiteflute

23:37:54.075 - No core Item data for shoalsalt
23:37:54.075 - No core Item data for shoalshell


23:37:54.077 - No core Item data for superrepel
23:37:54.077 - No core Item data for maxrepel
23:37:54.077 - No core Item data for escaperope
23:37:54.078 - No core Item data for repel
23:37:54.078 - No core Item data for sunstone
23:37:54.078 - No core Item data for moonstone
23:37:54.079 - No core Item data for firestone
23:37:54.079 - No core Item data for thunderstone
23:37:54.079 - No core Item data for waterstone
23:37:54.080 - No core Item data for leafstone
23:37:54.080 - No core Item data for tinymushroom
23:37:54.080 - No core Item data for bigmushroom
23:37:54.081 - No core Item data for pearl
23:37:54.081 - No core Item data for bigpearl
23:37:54.081 - No core Item data for stardust
23:37:54.082 - No core Item data for starpiece
23:37:54.082 - No core Item data for nugget
23:37:54.082 - No core Item data for heartscale
23:37:54.083 - No core Item data for honey

23:37:54.085 - No core Item data for shinystone
23:37:54.085 - No core Item data for duskstone
23:37:54.085 - No core Item data for dawnstone
23:37:54.086 - No core Item data for ovalstone
23:37:54.086 - No core Item data for oddkeystone
23:37:54.086 - No core Item data for sweetheart

23:37:54.091 - No core Item data for soothebell
23:37:54.091 - No core Item data for amuletcoin
23:37:54.092 - No core Item data for cleansetag
23:37:54.092 - No core Item data for smokeball
23:37:54.093 - No core Item data for everstone
23:37:54.093 - No core Item data for dragonscale
23:37:54.093 - No core Item data for upgrade
23:37:54.094 - No core Item data for redscarf
23:37:54.094 - No core Item data for bluescarf
23:37:54.094 - No core Item data for pinkscarf
23:37:54.095 - No core Item data for greenscarf
23:37:54.095 - No core Item data for yellowscarf
23:37:54.098 - No core Item data for luckincense
23:37:54.098 - No core Item data for pureincense
23:37:54.098 - No core Item data for protector
23:37:54.099 - No core Item data for magmarizer
23:37:54.099 - No core Item data for dubiousdisc
23:37:54.099 - No core Item data for reapercloth

23:37:54.116 - No core Item data for lunarwing

23:37:54.130 - No core Item data for ragecandybar

23:37:54.132 - No core Item data for healthwing
23:37:54.132 - No core Item data for musclewing
23:37:54.132 - No core Item data for resistwing
23:37:54.133 - No core Item data for geniuswing
23:37:54.133 - No core Item data for cleverwing
23:37:54.133 - No core Item data for swiftwing
23:37:54.134 - No core Item data for prettywing
23:37:54.134 - No core Item data for libertypass
23:37:54.135 - No core Item data for passorb

23:37:54.135 - No core Item data for propcase
23:37:54.136 - No core Item data for dragonskull
23:37:54.136 - No core Item data for balmmushroom
23:37:54.136 - No core Item data for bignugget
23:37:54.137 - No core Item data for pearlstring
23:37:54.137 - No core Item data for cometshard
23:37:54.137 - No core Item data for reliccopper
23:37:54.138 - No core Item data for relicsilver
23:37:54.138 - No core Item data for relicgold
23:37:54.139 - No core Item data for relicvase
23:37:54.140 - No core Item data for relicband
23:37:54.140 - No core Item data for relicstatue
23:37:54.140 - No core Item data for reliccrown
23:37:54.141 - No core Item data for casteliacone

23:37:54.150 - No core Item data for lightstone
23:37:54.151 - No core Item data for darkstone

23:37:54.157 - No core Item data for abilitycapsule
23:37:54.157 - No core Item data for whippeddream
23:37:54.170 - No core Item data for sachet

23:37:54.183 - No core Item data for lumiosegalette
23:37:54.183 - No core Item data for shaloursable
23:37:54.184 - No core Item data for jawfossil
23:37:54.184 - No core Item data for sailfossil

23:37:54.202 - No numeric id [num] for Item mail
--]]

return {
	['sawsbuckcoffee'] = {
		name = 'Sawsbuck Coffee',
		fling = {
			basePower = 30,
			status = 'brn'
		},
		onResidualOrder = 26,
		onResidualSubOrder = 3,
		onResidual = function(pokemon)
			if math.random(10) <= 2 then
				self:boost({spe = 1})
			end
		end,
	},
	['gengariteh'] = {
		name = 'Gengarite H',
		megaStone = 'Gengar-Mega-H',
		megaEvolves = 'Gengar',
		onTakeItem = onTakeMegaStone,
	},
	umvbattery = {
		name = 'UMV Battery',
		showsQuantity = true,
	},
	luckincense = {
		name = 'Luck Incense',
		fling = 10,
		onStart = function(pokemon)
			pokemon.side.doublePrizeMoney = true
		end
	},
	amuletcoin = {
		name = 'Amulet Coin',
		fling = 30,
		onStart = function(pokemon)
			pokemon.side.doublePrizeMoney = true
		end
	},
	luckyegg = {
		name = 'Lucky Egg',
		fling = 30,
	},
	powerbracer = {
		name = 'Power Bracer',
		fling = 70,
	},
	powerbelt = {
		name = 'Power Belt',
		fling = 70,
	},
	powerlens = {
		name = 'Power Lens',
		fling = 70,
	},
	powerband = {
		name = 'Power Band',
		fling = 70,
	},
	poweranklet = {
		name = 'Power Anklet',
		fling = 70,
	},
	powerweight = {
		name = 'Power Weight',
		fling = 70,
	},
	prismscale = {
		name = 'Prism Scale',
		fling = 30,
	},
	redshard = {
		name = 'Red Shard',
		fling = 30,
	},
	blueshard = {
		name = 'Blue Shard',
		fling = 30,
	},
	yellowshard = {
		name = 'Yellow Shard',
		fling = 30,
	},
	greenshard = {
		name = 'Green Shard',
		fling = 30,
	},
	-- todos:
	potion = {
		name = 'Potion',
		fling = 30,
	},
	antidote = {
		name = 'Antidote',
		fling = 30,
	},
	burnheal = {
		name = 'Burn Heal',
		fling = 30,
	},
	iceheal = {
		name = 'Ice Heal',
		fling = 30,
	},
	awakening = {
		name = 'Awakening',
		fling = 30,
	},
	paralyzeheal = {
		name = 'Paralyze Heal',
		fling = 30,
	},
	fullrestore = {
		name = 'Full Restore',
		fling = 30,
	},
	maxpotion = {
		name = 'Max Potion',
		fling = 30,
	},
	hyperpotion = {
		name = 'Hyper Potion',
		fling = 30,
	},
	superpotion = {
		name = 'Super Potion',
		fling = 30,
	},
	fullheal = {
		name = 'Full Heal',
		fling = 30,
	},
	revive = {
		name = 'Revive',
		fling = 30,
	},
	maxrevive = {
		name = 'Max Revive',
		fling = 30,
	},
	freshwater = {
		name = 'Fresh Water',
		fling = 30,
	},
	sodapop = {
		name = 'Soda Pop',
		fling = 30,
	},
	lemonade = {
		name = 'Lemonade',
		fling = 30,
	},
	moomoomilk = {
		name = 'Moomoo Milk',
		fling = 30,
	},
	ether = {
		name = 'Ether',
		fling = 30,
	},
	maxether = {
		name = 'Max Ether',
		fling = 30,
	},
	elixir = {
		name = 'Elixir',
		fling = 30,
	},
	maxelixir = {
		name = 'Max Elixir',
		fling = 30,
	},
	lavacookie = {
		name = 'Lava Cookie',
		fling = 30,
	},
	poketoy = {
		name = 'Pok[e\'] Toy',
		fling = 30,
	},
	
	pumpkinball = {
		isPokeball = true,
	},
	colorlessball = {
		isPokeball = true,
	},
	insectball = {
		isPokeball = true,
	},
	dreadball = {
		isPokeball = true,
	},
	dracoball = {
		isPokeball = true,
	},
	zapball = {
		isPokeball = true,
	},
	fistball = {
		isPokeball = true,
	},
	flameball = {
		isPokeball = true,
	},
	skyball = {
		isPokeball = true,
	},
	spookyball = {
		isPokeball = true,
	},
	meadowball = {
		isPokeball = true,
	},
	earthball = {
		isPokeball = true,
	},
	icicleball = {
		isPokeball = true,
	},
	toxicball = {
		isPokeball = true,
	},
	mindball = {
		isPokeball = true,
	},
	stoneball = {
		isPokeball = true,
	},
	steelball = {
		isPokeball = true,
	},
	splashball = {
		isPokeball = true,
	},
	pixieball = {
		isPokeball = true,
	},

	
	
--============================================================================================================
--============================================================================================================
	
	['abomasite'] = {
		id = "abomasite",
		name = "Abomasite",
		megaStone = "Abomasnow-Mega",
		megaEvolves = "Abomasnow",
		onTakeItem = onTakeMegaStone,
	},
	['absolite'] = {
		id = "absolite",
		name = "Absolite",
		megaStone = "Absol-Mega",
		megaEvolves = "Absol",
		onTakeItem = onTakeMegaStone,
	},
	['absorbbulb'] = {
		id = "absorbbulb",
		name = "Absorb Bulb",
		fling = 30,
		onAfterDamage = function(damage, target, source, move)
			if move.type == 'Water' and target:useItem() then
				self:boost({spa = 1})
			end
		end,
	},
	['adamantorb'] = {
		id = "adamantorb",
		name = "Adamant Orb",
		fling = 60,
		onBasePowerPriority = 6,
		onBasePower = function(basePower, user, target, move)
			if move and user.baseTemplate.species == 'Dialga' and (move.type == 'Steel' or move.type == 'Dragon') then
				return self:chainModify(0x1333, 0x1000)
			end
		end,
	},
	['aerodactylite'] = {
		id = "aerodactylite",
		name = "Aerodactylite",
		megaStone = "Aerodactyl-Mega",
		megaEvolves = "Aerodactyl",
		onTakeItem = onTakeMegaStone,
	},
	['aggronite'] = {
		id = "aggronite",
		name = "Aggronite",
		megaStone = "Aggron-Mega",
		megaEvolves = "Aggron",
		onTakeItem = onTakeMegaStone,
	},
	['aguavberry'] = {
		id = "aguavberry",
		name = "Aguav Berry",
		isBerry = true,
		naturalGift = {
			basePower = 80,
			type = "Dragon"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp / 2 then
				pokemon:eatItem()
			end
		end,
		onEatItem = function(item, pokemon)
			if Not(self:runEvent('TryHeal', pokemon)) then return false end
		end,
		onEat = function(pokemon)
			self:heal(pokemon.maxhp / 8)
			if pokemon:getNature().minus == 'spd' then
				pokemon:addVolatile('confusion')
			end
		end,
	},
	['airballoon'] = {
		id = "airballoon",
		name = "Air Balloon",
		fling = 10,
		onStart = function(target)
			if not target:ignoringItem() then
				self:add('-item', target, 'Air Balloon')
			end
		end,
		onImmunity = function(type)
			if type == 'Ground' then return false end
		end,
		onAfterDamage = function(damage, target, source, effect)
			self:debug('effect = ' .. effect.id)
			if effect.effectType == 'Move' and effect.id ~= 'confused' then
				self:add('-enditem', target, 'Air Balloon')
				target.item = ''
				self.itemData = {id = '', target = self}
				self:runEvent('AfterUseItem', target, nil, nil, 'airballoon')
			end
		end,
		onAfterSubDamage = function(damage, target, source, effect)
			self:debug('effect = ' .. effect.id)
			if effect.effectType == 'Move' and effect.id ~= 'confused' then
				self:add('-enditem', target, 'Air Balloon')
				target:setItem('')
			end
		end,
	},
	['alakazite'] = {
		id = "alakazite",
		name = "Alakazite",
		megaStone = "Alakazam-Mega",
		megaEvolves = "Alakazam",
		onTakeItem = onTakeMegaStone,
	},
	['altarianite'] = {
		id = "altarianite",
		name = "Altarianite",
		megaStone = "Altaria-Mega",
		megaEvolves = "Altaria",
		onTakeItem = onTakeMegaStone,
	},
	['ampharosite'] = {
		id = "ampharosite",
		name = "Ampharosite",
		megaStone = "Ampharos-Mega",
		megaEvolves = "Ampharos",
		onTakeItem = onTakeMegaStone,
	},
	['apicotberry'] = {
		id = "apicotberry",
		name = "Apicot Berry",
		isBerry = true,
		flavour = {10, 30, 0, 0, 30},
		naturalGift = {
			basePower = 100,
			type = "Ground"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			self:boost({spd = 1})
		end,
	},
	['bigpearl'] = {
		id = "bigpearl",
		name = "Big Pearl",
		fling = 100,
	},
	['pearl'] = {
		id = "pearl",
		name = "Pearl",
		fling = 100,
	},
	['cleansetag'] = {
		id = "cleansetag",
		name = "Cleanse Tag",
		fling = 100,
	},
	['bigmushroom'] = {
		id = "bigmushroom",
		name = "Big Mushroom",
		fling = 100,
	},
	['tinymushroom'] = {
		id = "tinymushroom",
		name = "Tiny Mushroom",
		fling = 100,
	},
	['starpiece'] = {
		id = "starpiece",
		name = "Star Piece",
		fling = 100,
	},
	['stardust'] = {
		id = "stardust",
		name = "Stardust",
		fling = 100,
	},
	['prettywing'] = {
		id = "prettywing",
		name = "Pretty Wing",
		fling = 100,
	},
	['armorfossil'] = {
		id = "armorfossil",
		name = "Armor Fossil",
		fling = 100,
	},
	['aspearberry'] = {
		id = "aspearberry",
		name = "Aspear Berry",
		isBerry = true,
		flavour = {0, 0, 0, 0, 10},
		naturalGift = {
			basePower = 80,
			type = "Ice"
		},
		onUpdate = function(pokemon)
			if pokemon.status == 'frz' then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			if pokemon.status == 'frz' then
				pokemon:cureStatus()
			end
		end,
	},
	['assaultvest'] = {
		id = "assaultvest",
		name = "Assault Vest",
		fling = 80,
		onModifySpDPriority = 1,
		onModifySpD = function(spd)
			return self:chainModify(1.5)
		end,
		onDisableMove = function(pokemon)
			for _, m in pairs(pokemon.moveset) do
				if self:getMove(m.move).category == 'Status' then
					pokemon:disableMove(m.id)
				end
			end
		end,
	},
	['audinite'] = {
		id = "audinite",
		name = "Audinite",
		megaStone = "Audino-Mega",
		megaEvolves = "Audino",
		onTakeItem = onTakeMegaStone,
	},
	['babiriberry'] = {
		id = "babiriberry",
		name = "Babiri Berry",
		isBerry = true,
		flavour = {25, 10, 0, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Steel"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Steel'),
		onEat = function() end,
	},
	['banettite'] = {
		id = "banettite",
		name = "Banettite",
		megaStone = "Banette-Mega",
		megaEvolves = "Banette",
		onTakeItem = onTakeMegaStone,
	},
	['beedrillite'] = {
		name = 'Beedrillite',
		megaStone = 'Beedrill-Mega',
		megaEvolves = 'Beedrill',
		onTakeItem = onTakeMegaStone,
	},
	['belueberry'] = {
		id = "belueberry",
		name = "Belue Berry",
		isBerry = true,
		flavour = {10, 0, 0, 0, 30},
		naturalGift = {
			basePower = 100,
			type = "Electric"
		},
	},
	['berryjuice'] = {
		id = "berryjuice",
		name = "Berry Juice",
		fling = 30,
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				if not Not(self:runEvent('TryHeal', pokemon)) and pokemon:useItem() then
					self:heal(20)
				end
			end
		end,
		gen = 2,
	},
	['bigroot'] = {
		id = "bigroot",
		name = "Big Root",
		fling = 10,
		onTryHealPriority = 1,
		onTryHeal = function(damage, target, source, effect)
			local heals = {drain=true, leechseed=true, ingrain=true, aquaring=true}
			if heals[effect.id] then
				return math.ceil(damage * 1.3 - 0.5) -- Big Root rounds half down
			end
		end,
	},
	['bindingband'] = {
		id = "bindingband",
		name = "Binding Band",
		fling = 30,
		-- implemented in Statuses
	},
	['blackbelt'] = {
		id = "blackbelt",
		name = "Black Belt",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Fighting'),
		gen = 2,
	},
	['blacksludge'] = {
		id = "blacksludge",
		name = "Black Sludge",
		fling = 30,
		onResidualOrder = 5,
		onResidualSubOrder = 2,
		onResidual = function(pokemon)
			if pokemon:hasType('Poison') then
				self:heal(pokemon.maxhp / 16)
			else
				self:damage(pokemon.maxhp / 8)
			end
		end,
	},
	['blackglasses'] = {
		id = "blackglasses",
		name = "Black Glasses",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Dark'),
		gen = 2,
	},
	['blastoisinite'] = {
		id = "blastoisinite",
		name = "Blastoisinite",
		megaStone = "Blastoise-Mega",
		megaEvolves = "Blastoise",
		onTakeItem = onTakeMegaStone,
	},
	['blazikenite'] = {
		id = "blazikenite",
		name = "Blazikenite",
		megaStone = "Blaziken-Mega",
		megaEvolves = "Blaziken",
		onTakeItem = onTakeMegaStone,
	},
	['blueorb'] = {
		id = "blueorb",
		name = "Blue Orb",
		onSwitchInPriority = -6,
		onSwitchIn = function(pokemon)
			local template = self:getTemplate('Kyogre')          
			if pokemon.isActive and pokemon.baseTemplate == template then
				local primaltemplate = self:getTemplate('Kyogre-Primal')
				self:add('detailschange', pokemon, pokemon.details, '[primalK]', '[icon] '..(primaltemplate.icon or 0))

				pokemon:formeChange(primaltemplate)
				pokemon.baseTemplate = primaltemplate

				pokemon:setAbility(primaltemplate.abilities[1])
				pokemon.baseAbility = pokemon.ability
				pokemon.details = pokemon.species .. ', L' .. pokemon.level .. (pokemon.gender == '' and '' or ', ') .. pokemon.gender .. (pokemon.set.shiny and ', shiny' or '')
				local shinyPrefix = pokemon.shiny and '_SHINY' or ''
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/Kyogre-Primal')
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/Kyogre-Primal')

				pokemon.iconOverride = primaltemplate.icon-1
				pokemon.frontSpriteOverride = require(game:GetService('ServerStorage').Data.Spritesheets)[shinyPrefix..'_FRONT']['Kyogre-Primal']

				pokemon.abilityOverride = primaltemplate.abilities[1]
				pokemon.typeOverride = primaltemplate.types
				pokemon.baseStatOverride = primaltemplate.baseStats
			else return end
		end,
	},
	['blukberry'] = {
		id = "blukberry",
		name = "Bluk Berry",
		isBerry = true,
		flavour = {0, 10, 10, 0, 0},
		naturalGift = {
			basePower = 90,
			type = "Fire"
		},
	},
	['brightpowder'] = {
		id = "brightpowder",
		name = "BrightPowder",
		fling = 10,
		onModifyAccuracy = function(accuracy)
			if type(accuracy) ~= 'number' then return end
			self:debug('brightpowder - decreasing accuracy')
			return accuracy * 0.9
		end,
		gen = 2,
	},
	['buggem'] = {
		id = "buggem",
		name = "Bug Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Bug'),
	},
	['burndrive'] = {
		id = "burndrive",
		name = "Burn Drive",
		onTakeItem = onTakeDrive,
		onDrive = 'Fire',
	},
	['cameruptite'] = {
		id = "cameruptite",
		name = "Cameruptite",
		megaStone = "Camerupt-Mega",
		megaEvolves = "Camerupt",
		onTakeItem = onTakeMegaStone,
	},
	['cellbattery'] = {
		id = "cellbattery",
		name = "Cell Battery",
		fling = 30,
		onAfterDamage = function(damage, target, source, move)
			if move.type == 'Electric' and target:useItem() then
				self:boost({atk = 1})
			end
		end,
	},
	['charcoal'] = {
		id = "charcoal",
		name = "Charcoal",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Fire'),
		gen = 2,
	},
	['charizarditex'] = {
		id = "charizarditex",
		name = "Charizardite X",
		megaStone = "Charizard-Mega-X",
		megaEvolves = "Charizard",
		onTakeItem = onTakeMegaStone,
	},
	['charizarditey'] = {
		id = "charizarditey",
		name = "Charizardite Y",
		megaStone = "Charizard-Mega-Y",
		megaEvolves = "Charizard",
		onTakeItem = onTakeMegaStone,
	},
	['chartiberry'] = {
		id = "chartiberry",
		name = "Charti Berry",
		isBerry = true,
		flavour = {10, 20, 0, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Rock"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Rock'),
		onEat = function() end,
	},
	['cheriberry'] = {
		id = "cheriberry",
		name = "Cheri Berry",
		isBerry = true,
		flavour = {10, 0, 0, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Fire"
		},
		onUpdate = function(pokemon)
			if pokemon.status == 'par' then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			if pokemon.status == 'par' then
				pokemon:cureStatus()
			end
		end,
	},
	['cherishball'] = {
		id = "cherishball",
		name = "Cherish Ball",
	},
	['chestoberry'] = {
		id = "chestoberry",
		name = "Chesto Berry",
		isBerry = true,
		flavour = {0, 10, 0, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Water"
		},
		onUpdate = function(pokemon)
			if pokemon.status == 'slp' then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			if pokemon.status == 'slp' then
				pokemon:cureStatus()
			end
		end,
	},
	['chilanberry'] = {
		id = "chilanberry",
		name = "Chilan Berry",
		isBerry = true,
		flavour = {0, 25, 10, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Normal"
		},
		onSourceModifyDamage = function(damage, source, target, move)
			if move.type == 'Normal' and not target.volatiles['substitute'] then
				if target:eatItem() then
					self:debug('-50% reduction')
					return self:chainModify(0.5)
				end
			end
		end,
		onEat = function() end,
	},
	['chilldrive'] = {
		id = "chilldrive",
		name = "Chill Drive",
		onTakeItem = onTakeDrive,
		onDrive = 'Ice',
	},
	['choiceband'] = {
		id = "choiceband",
		name = "Choice Band",
		OnStart = function (pokemon)
			if pokemon.activeTurns == 0 then
				return false
			end
		end,
		onModifyAtkPriority = 1,
		onModifyAtk = function(atk)
			return self:chainModify(1.5)
		end,
		onDisableMove = function(pokemon)          
			for _, move in pairs(pokemon.moveset) do
				if move.id ~= pokemon.lastMove and pokemon.activeTurns > 0 then
					pokemon:disableMove(move.id)
				end
			end
		end,
	},
	['choicescarf'] = {
		id = "choicescarf",
		name = "Choice Scarf",
		fling = 10,
		OnStart = function (pokemon)
			if pokemon.activeTurns == 0 then
				return false
			end
		end,
		onModifySpe = function(spe)
			return self:chainModify(1.5)
		end,
		onDisableMove = function(pokemon)    
			for _, move in pairs(pokemon.moveset) do
				if move.id ~= pokemon.lastMove and pokemon.activeTurns > 0 then
					pokemon:disableMove(move.id)
				end
			end
		end,
	},
	['choicespecs'] = {
		id = "choicespecs",
		name = "Choice Specs",
		OnStart = function (pokemon)
			if pokemon.activeTurns == 0 then
				return false
			end
		end,
		onModifySpAPriority = 1,
		onModifySpa = function(spa)
			return self:chainModify(1.5)
		end,
		onDisableMove = function(pokemon)           
			for _, move in pairs(pokemon.moveset) do
				if move.id ~= pokemon.lastMove and pokemon.activeTurns > 0 then
					pokemon:disableMove(move.id)
				end
			end
		end,
	},
	['chopleberry'] = {
		id = "chopleberry",
		name = "Chople Berry",
		isBerry = true,
		flavour = {15, 0, 0, 10, 0},
		naturalGift = {
			basePower = 80,
			type = "Fighting"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Fighting'),
		onEat = function() end,
	},
	['clawfossil'] = {
		id = "clawfossil",
		name = "Claw Fossil",
		fling = 100,
	},
	['cobaberry'] = {
		id = "cobaberry",
		name = "Coba Berry",
		isBerry = true,
		flavour = {0, 10, 0, 15, 0},
		naturalGift = {
			basePower = 80,
			type = "Flying"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Flying'),
		onEat = function() end,
	},
	['colburberry'] = {
		id = "colburberry",
		name = "Colbur Berry",
		isBerry = true,
		flavour = {0, 0, 0, 10, 20},
		naturalGift = {
			basePower = 80,
			type = "Dark"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Dark'),
		onEat = function() end,
	},
	['cornnberry'] = {
		id = "cornnberry",
		name = "Cornn Berry",
		isBerry = true,
		flavour = {0, 20, 10, 0, 0},
		naturalGift = {
			basePower = 90,
			type = "Bug"
		},
	},
	['coverfossil'] = {
		id = "coverfossil",
		name = "Cover Fossil",
		fling = 100,
	},
	['custapberry'] = {
		id = "custapberry",
		name = "Custap Berry",
		isBerry = true,
		flavour = {0, 0, 40, 10, 0},
		naturalGift = {
			basePower = 100,
			type = "Ghost"
		},
		onModifyPriority = function(priority, pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				if pokemon:eatItem() then
					self:add('-activate', pokemon, 'Custap Berry')
					pokemon:removeVolatile('custapberry')
					return priority + 0.1
				end
			end
		end,
	},
	['damprock'] = {
		id = "damprock",
		name = "Damp Rock",
		fling = 60,
	},
	['darkgem'] = {
		id = "darkgem",
		name = "Dark Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Dark'),
	},
	['deepseascale'] = {
		id = "deepseascale",
		name = "DeepSeaScale",
		fling = 30,
		onModifySpDPriority = 2,
		onModifySpD = function(spd, pokemon)
			if pokemon.baseTemplate.species == 'Clamperl' then
				return self:chainModify(2)
			end
		end,
	},
	['deepseatooth'] = {
		id = "deepseatooth",
		name = "DeepSeaTooth",
		fling = 90,
		onModifySpAPriority = 1,
		onModifySpA = function(spa, pokemon)
			if pokemon.baseTemplate.species == 'Clamperl' then
				return self:chainModify(2)
			end
		end,
	},
	['destinyknot'] = {
		id = "destinyknot",
		name = "Destiny Knot",
		fling = 10,
		onAttractPriority = -100,
		onAttract = function(target, source)
			self:debug('attract intercepted = ' .. target .. ' from ' .. source)
			if Not(source) or source == target then return end
			if not source.volatiles.attract then source:addVolatile('attract', target) end
		end,
	},
	['diancite'] = {
		id = "diancite",
		name = "Diancite",
		megaStone = "Diancie-Mega",
		megaEvolves = "Diancie",
		onTakeItem = onTakeMegaStone,
	},
	['diveball'] = {
		id = "diveball",
		name = "Dive Ball",
	},
	['domefossil'] = {
		id = "domefossil",
		name = "Dome Fossil",
		fling = 100,
	},
	['dousedrive'] = {
		id = "dousedrive",
		name = "Douse Drive",
		onTakeItem = onTakeDrive,
		onDrive = 'Water',
	},
	['dracoplate'] = {
		id = "dracoplate",
		name = "Draco Plate",
		onPlate = 'Dragon',
		onBasePowerPriority = 6,
		onBasePower = plate('Dragon'),
		onTakeItem = onTakeDrive,
	},
	['dragonfang'] = {
		id = "dragonfang",
		name = "Dragon Fang",
		fling = 70,
		onBasePowerPriority = 6,
		onBasePower = plate('Dragon'),
		gen = 2,
	},
	['dragongem'] = {
		id = "dragongem",
		name = "Dragon Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Dragon'),
	},
	['dreadplate'] = {
		id = "dreadplate",
		name = "Dread Plate",
		onPlate = 'Dark',
		onBasePowerPriority = 6,
		onBasePower = plate('Dark'),
		onTakeItem = onTakePlate,
	},
	['dreamball'] = {
		id = "dreamball",
		name = "Dream Ball",
	},
	['durinberry'] = {
		id = "durinberry",
		name = "Durin Berry",
		isBerry = true,
		flavour = {0, 0, 0, 30, 10},
		naturalGift = {
			basePower = 100,
			type = "Water"
		},
	},
	['duskball'] = {
		id = "duskball",
		name = "Dusk Ball",
		isPokeball = true,
	},
	['earthplate'] = {
		id = "earthplate",
		name = "Earth Plate",
		onPlate = 'Ground',
		onBasePowerPriority = 6,
		onBasePower = plate('Ground'),
		onTakeItem = onTakePlate,
	},
	['ejectbutton'] = {
		id = "ejectbutton",
		name = "Eject Button",
		fling = 30,
		onAfterMoveSecondary = function(target, source, move)
			if source and source ~= target and target.hp and move and move.category ~= 'Status' then
				if not target.side:canSwitch(target.position) or target.forceSwitchFlag then return end
				if target:useItem() then
					target.switchFlag = true
					source.switchFlag = false
				end
			end
		end,
	},
	['electirizer'] = {
		id = "electirizer",
		name = "Electirizer",
		fling = 80,
	},
	['electricgem'] = {
		id = "electricgem",
		name = "Electric Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Electric', true),
	},
	['energypowder'] = {
		id = "energypowder",
		name = "EnergyPowder",
		fling = 30,
		gen = 2,
	},
	['enigmaberry'] = {
		id = "enigmaberry",
		name = "Enigma Berry",
		isBerry = true,
		flavour = {40, 10, 0, 0, 0},
		naturalGift = {
			basePower = 100,
			type = "Bug"
		},
		onHit = function(target, source, move)
			if move and move.typeMod > 0 then
				target:eatItem()
			end
		end,
		onEatItem = function(item, pokemon)
			if Not(self:runEvent('TryHeal', pokemon)) then return false end
		end,
		onEat = function(pokemon)
			self:heal(pokemon.maxhp / 4)
		end,
	},
	['eviolite'] = {
		id = "eviolite",
		name = "Eviolite",
		fling = 40,
		onModifyDefPriority = 2,
		onModifyDef = function(def, pokemon)
			if pokemon.baseTemplate.nfe then
				return self:chainModify(1.5)
			end
		end,
		onModifySpDPriority = 2,
		onModifySpD = function(spd, pokemon)
			if pokemon.baseTemplate.nfe then
				return self:chainModify(1.5)
			end
		end,
	},
	['expertbelt'] = {
		id = "expertbelt",
		name = "Expert Belt",
		fling = 10,
		onModifyDamage = function(damage, source, target, move)
			if move and move.typeMod > 0 then
				return self:chainModify(0x1333, 0x1000)
			end
		end,
	},
	['fairygem'] = {
		id = "fairygem",
		name = "Fairy Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Fairy'),
	},
	['fastball'] = {
		id = "fastball",
		name = "Fast Ball",
		gen = 2,
	},
	['fightinggem'] = {
		id = "fightinggem",
		name = "Fighting Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Fighting'),
	},
	['figyberry'] = {
		id = "figyberry",
		name = "Figy Berry",
		isBerry = true,
		flavour = {15, 0, 0, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Bug"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				pokemon:eatItem()
			end
		end,
		onEatItem = function(item, pokemon)
			if Not(self:runEvent('TryHeal', pokemon)) then return false end
		end,
		onEat = function(pokemon)
			self:heal(pokemon.maxhp / 8)
			if pokemon:getNature().minus == 'atk' then
				pokemon:addVolatile('confusion')
			end
		end,
	},
	['firegem'] = {
		id = "firegem",
		name = "Fire Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Fire', true),
	},
	
	["firiumz"] = {
		id= "firiumz",
		name= "Firium Z",
		onPlate = 'Fire',
		onTakeItem = false,
		zMove = true,
		zMoveType = "Fire",
		forcedForme = "Arceus-Fire",
		num = 777,
		gen = 7,
	},
	["wateriumz"] = {
		id= "wateriumz",
		name= "Waterium Z",
		onPlate = 'Water',
		onTakeItem = false,
		zMove = true,
		zMoveType = "Water",
		forcedForme = "Arceus-Water",
		num = 778,
		gen = 7,
	},
	["grassiumz"] = {
		id = "grassiumz",
		name= "Grassium Z",
		onPlate = 'Grass',
		onTakeItem = false,
		zMove = true,
		zMoveType = "Grass",
		forcedForme = "Arceus-Grass",
		num = 779,
		gen = 7,
	},
	["dragoniumz"] = {
		id = "dragoniumz",
		name= "Dragonium Z",
		onPlate = 'Dragon',
		onTakeItem = false,
		zMove = true,
		zMoveType = "Dragon",
		forcedForme = "Arceus-Dragon",
		num = 780,
		gen = 7,
	},
	["bugiumz"] = {
		id = "bugiumz",
		name= "Bugium Z",
		onPlate = 'Bug',
		onTakeItem = false,
		zMove = true,
		zMoveType = "Bug",
		forcedForme = "Arceus-Bug",
		num = 781,
		gen = 7,
	},
	["iciumz"] = {
		id = "iciumz",
		name= "Icium Z",
		onPlate = 'Ice',
		onTakeItem = false,
		zMove = true,
		zMoveType = "Ice",
		forcedForme = "Arceus-Ice",
		num = 782,
		gen = 7,
	},	
	
	
	['fistplate'] = {
		id = "fistplate",
		name = "Fist Plate",
		onPlate = 'Fighting',
		onBasePowerPriority = 6,
		onBasePower = plate('Fighting'),
		onTakeItem = onTakePlate,
	},
	['flameorb'] = {
		id = "flameorb",
		name = "Flame Orb",
		fling = {
			basePower = 30,
			status = 'brn'
		},
		onResidualOrder = 26,
		onResidualSubOrder = 2,
		onResidual = function(pokemon)
			pokemon:trySetStatus('brn')
		end,
	},
	['flameplate'] = {
		id = "flameplate",
		name = "Flame Plate",
		fling = 90,
		onPlate = 'Fire',
		onBasePowerPriority = 6,
		onBasePower = plate('Fire'),
		onTakeItem = onTakePlate,
	},
	['floatstone'] = {
		id = "floatstone",
		name = "Float Stone",
		fling = 30,
		onModifyWeight = function(weight)
			return weight / 2
		end,
	},
	['flyinggem'] = {
		id = "flyinggem",
		name = "Flying Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Flying'),
	},
	['focusband'] = {
		id = "focusband",
		name = "Focus Band",
		fling = 10,
		onDamage = function(damage, target, source, effect)
			if math.random(10) == 1 and damage >= target.hp and effect and effect.effectType == 'Move' then
				self:add("-activate", target, "item: Focus Band")
				return target.hp - 1
			end
		end,
		gen = 2,
	},
	['focussash'] = {
		id = "focussash",
		name = "Focus Sash",
		fling = 10,
		onDamage = function(damage, target, source, effect)
			if target.hp == target.maxhp and damage >= target.hp and effect and effect.effectType == 'Move' then
				if target:useItem() then
					return target.hp - 1
				end
			end
		end,
	},
	['friendball'] = {
		id = "friendball",
		name = "Friend Ball",
		gen = 2,
	},
	['fullincense'] = {
		id = "fullincense",
		name = "Full Incense",
		fling = 10,
		onModifyPriority = function(priority, pokemon)
			if not pokemon:hasAbility('stall') then
				return priority - 0.1
			end
		end,
	},
	['galladite'] = {
		id = "galladite",
		name = "Galladite",
		megaStone = "Gallade-Mega",
		megaEvolves = "Gallade",
		onTakeItem = onTakeMegaStone,
	},
	['ganlonberry'] = {
		id = "ganlonberry",
		name = "Ganlon Berry",
		isBerry = true,
		flavour = {0, 30, 10, 30, 0},
		naturalGift = {
			basePower = 100,
			type = "Ice"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			self:boost({def = 1})
		end,
	},
	['garchompite'] = {
		id = "garchompite",
		name = "Garchompite",
		megaStone = "Garchomp-Mega",
		megaEvolves = "Garchomp",
		onTakeItem = onTakeMegaStone,
	},
	['gardevoirite'] = {
		id = "gardevoirite",
		name = "Gardevoirite",
		megaStone = "Gardevoir-Mega",
		megaEvolves = "Gardevoir",
		onTakeItem = onTakeMegaStone,
	},
	['gengarite'] = {
		id = "gengarite",
		name = "Gengarite",
		megaStone = "Gengar-Mega",
		megaEvolves = "Gengar",
		onTakeItem = onTakeMegaStone,
	},
	['ghostgem'] = {
		id = "ghostgem",
		name = "Ghost Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Ghost'),
	},
	['glalitite'] = {
		id = "glalitite",
		name = "Glalitite",
		megaStone = "Glalie-Mega",
		megaEvolves = "Glalie",
		onTakeItem = onTakeMegaStone,
	},
	['grassgem'] = {
		id = "grassgem",
		name = "Grass Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Grass', true),
	},
	['greatball'] = {
		id = "greatball",
		name = "Great Ball",
		isPokeball = true,
		gen = 1,
	},
	['grepaberry'] = {
		id = "grepaberry",
		name = "Grepa Berry",
		isBerry = true,
		flavour = {0, 10, 10, 0, 10},
		naturalGift = {
			basePower = 90,
			type = "Flying"
		},
	},
	['gripclaw'] = {
		id = "gripclaw",
		name = "Grip Claw",
		fling = 90,
		-- implemented in statuses
	},
	['griseousorb'] = {
		id = "griseousorb",
		name = "Griseous Orb",
		fling = 60,
		onBasePowerPriority = 6,

		onSwitchIn = function(pokemon)
			local template = self:getTemplate('Giratina')          
			if pokemon.isActive and pokemon.baseTemplate == template then
				local primaltemplate = self:getTemplate('Giratina-Origin')
				self:add('detailschange', pokemon, pokemon.details, '[originG]', '[icon] '..(primaltemplate.icon or 0))

				pokemon:formeChange(primaltemplate)
				pokemon.baseTemplate = primaltemplate

				pokemon:setAbility(primaltemplate.abilities[1])
				pokemon.baseAbility = pokemon.ability
				pokemon.details = pokemon.species .. ', L' .. pokemon.level .. (pokemon.gender == '' and '' or ', ') .. pokemon.gender .. (pokemon.set.shiny and ', shiny' or '')
				local shinyPrefix = pokemon.shiny and '_SHINY' or ''
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/Giratina-Origin')
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/Giratina-Origin')

				pokemon.iconOverride = primaltemplate.icon-1
				pokemon.frontSpriteOverride = require(game:GetService('ServerStorage').Data.Spritesheets)[shinyPrefix..'_FRONT']['Giratina-Origin']

				pokemon.abilityOverride = primaltemplate.abilities[1]
				pokemon.typeOverride = primaltemplate.types
				pokemon.baseStatOverride = primaltemplate.baseStats
			else return end
		end,
		
		onBasePower = function(basePower, user, target, move)
			if user.baseTemplate.num == 487 and (move.type == 'Ghost' or move.type == 'Dragon') then
				return self:chainModify(0x1333, 0x1000)
			end
		end,

		
	},
	['groundgem'] = {
		id = "groundgem",
		name = "Ground Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Ground'),
	},
	['gyaradosite'] = {
		id = "gyaradosite",
		name = "Gyaradosite",
		megaStone = "Gyarados-Mega",
		megaEvolves = "Gyarados",
		onTakeItem = onTakeMegaStone,
	},
	['habanberry'] = {
		id = "habanberry",
		name = "Haban Berry",
		isBerry = true,
		flavour = {0, 0, 10, 20, 0},
		naturalGift = {
			basePower = 80,
			type = "Dragon"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Dragon'),
		onEat = function() end,
	},
	['hardstone'] = {
		id = "hardstone",
		name = "Hard Stone",
		fling = 100,
		onBasePowerPriority = 6,
		onBasePower = plate('Rock'),
		gen = 2,
	},
	['healball'] = {
		id = "healball",
		name = "Heal Ball",
	},
	['heatrock'] = {
		id = "heatrock",
		name = "Heat Rock",
		fling = 60,
	},
	['heavyball'] = {
		id = "heavyball",
		name = "Heavy Ball",
		gen = 2,
	},
	['helixfossil'] = {
		id = "helixfossil",
		name = "Helix Fossil",
		fling = 100,
	},
	['heracronite'] = {
		id = "heracronite",
		name = "Heracronite",
		megaStone = "Heracross-Mega",
		megaEvolves = "Heracross",
		onTakeItem = onTakeMegaStone,
	},
	['hondewberry'] = {
		id = "hondewberry",
		name = "Hondew Berry",
		isBerry = true,
		flavour = {10, 10, 0, 10, 0},
		naturalGift = {
			basePower = 90,
			type = "Ground"
		},
	},
	['houndoominite'] = {
		id = "houndoominite",
		name = "Houndoominite",
		megaStone = "Houndoom-Mega",
		megaEvolves = "Houndoom",
		onTakeItem = onTakeMegaStone,
	},
	['iapapaberry'] = {
		id = "iapapaberry",
		name = "Iapapa Berry",
		isBerry = true,
		flavour = {0, 0, 0, 0, 15},
		naturalGift = {
			basePower = 80,
			type = "Dark"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				pokemon:eatItem()
			end
		end,
		onEatItem = function(item, pokemon)
			if Not(self:runEvent('TryHeal', pokemon)) then return false end
		end,
		onEat = function(pokemon)
			self:heal(pokemon.maxhp / 8)
			if pokemon:getNature().minus == 'def' then
				pokemon:addVolatile('confusion')
			end
		end,
	},
	['icegem'] = {
		id = "icegem",
		name = "Ice Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Ice'),
	},
	['icicleplate'] = {
		id = "icicleplate",
		name = "Icicle Plate",
		onPlate = 'Ice',
		onBasePowerPriority = 6,
		onBasePower = plate('Ice'),
		onTakeItem = onTakePlate,
	},
	['icyrock'] = {
		id = "icyrock",
		name = "Icy Rock",
		fling = 40,
	},
	['insectplate'] = {
		id = "insectplate",
		name = "Insect Plate",
		onPlate = 'Bug',
		onBasePowerPriority = 6,
		onBasePower = plate('Bug'),
		onTakeItem = onTakePlate,
	},
	['ironball'] = {
		id = "ironball",
		name = "Iron Ball",
		fling = 130,
		onEffectiveness = function(typeMult, target, type, move)
			if target.volatiles['ingrain'] or target.volatiles['smackdown'] or self:getPseudoWeather('gravity') then return end
			if move.type == 'Ground' and not self:getImmunity(move.type, target) then return 1 end
		end,
		onNegateImmunity = function(pokemon, type)
			if type == 'Ground' then return false end
		end,
		onModifySpe = function(spe)
			return self:chainModify(0.5)
		end,
	},
	['ironplate'] = {
		id = "ironplate",
		name = "Iron Plate",
		onPlate = 'Steel',
		onBasePowerPriority = 6,
		onBasePower = plate('Steel'),
		onTakeItem = onTakePlate,
	},
	['jabocaberry'] = {
		id = "jabocaberry",
		name = "Jaboca Berry",
		isBerry = true,
		flavour = {0, 0, 0, 40, 10},
		naturalGift = {
			basePower = 100,
			type = "Dragon"
		},
		onAfterMoveSecondary = function(target, source, move)
			if source and source ~= target and move and move.category == 'Physical' then
				if target:eatItem() then
					self:damage(source.maxhp / 8, source, target, nil, true)
				end
			end
		end,
		onEat = function() end,
	},
	['kasibberry'] = {
		id = "kasibberry",
		name = "Kasib Berry",
		isBerry = true,
		flavour = {0, 10, 20, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Ghost"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Ghost'),
		onEat = function() end,
	},
	['kebiaberry'] = {
		id = "kebiaberry",
		name = "Kebia Berry",
		isBerry = true,
		flavour = {0, 15, 0, 0, 10},
		naturalGift = {
			basePower = 80,
			type = "Poison"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Poison'),
		onEat = function() end,
	},
	['keeberry'] = {
		id = "keeberry",
		name = "Kee Berry",
		isBerry = true,
		flavour = {30, 30, 10, 10, 10},
		naturalGift = {
			basePower = 100,
			type = "Fairy"
		},
		onAfterMoveSecondary = function(target, source, move)
			if move.category == 'Physical' then
				target:eatItem()
			end
		end,
		onEat = function(pokemon)
			self:boost({def = 1})
		end,
	},
	['kelpsyberry'] = {
		id = "kelpsyberry",
		name = "Kelpsy Berry",
		isBerry = true,
		flavour = {0, 10, 0, 10, 10},
		naturalGift = {
			basePower = 90,
			type = "Fighting"
		},
	},
	['kangaskhanite'] = {
		id = "kangaskhanite",
		name = "Kangaskhanite",
		megaStone = "Kangaskhan-Mega",
		megaEvolves = "Kangaskhan",
		onTakeItem = onTakeMegaStone,
	},
	['kingsrock'] = {
		id = "kingsrock",
		name = "King's Rock",
		fling = {
			basePower = 30,
			volatileStatus = 'flinch'
		},
		onModifyMovePriority = -1,
		onModifyMove = function(move)
			if move.category ~= "Status" then
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
		gen = 2,
	},
	['laggingtail'] = {
		id = "laggingtail",
		name = "Lagging Tail",
		fling = 10,
		onModifyPriority = function(priority, pokemon)
			if not pokemon:hasAbility('stall') then
				return priority - 0.1
			end
		end,
	},
	['lansatberry'] = {
		id = "lansatberry",
		name = "Lansat Berry",
		isBerry = true,
		flavour = {30, 10, 30, 10, 30},
		naturalGift = {
			basePower = 100,
			type = "Flying"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			pokemon:addVolatile('focusenergy')
		end,
	},
	['latiasite'] = {
		id = "latiasite",
		name = "Latiasite",
		megaStone = "Latias-Mega",
		megaEvolves = "Latias",
		onTakeItem = onTakeMegaStone,
	},
	['latiosite'] = {
		id = "latiosite",
		name = "Latiosite",
		megaStone = "Latios-Mega",
		megaEvolves = "Latios",
		onTakeItem = onTakeMegaStone,
	},
	['laxincense'] = {
		id = "laxincense",
		name = "Lax Incense",
		fling = 10,
		onModifyAccuracy = function(accuracy)
			if type(accuracy) ~= 'number' then return end
			self:debug('lax incense - decreasing accuracy')
			return accuracy * 0.9
		end,
	},
	['leftovers'] = {
		id = "leftovers",
		name = "Leftovers",
		fling = 10,
		onResidualOrder = 5,
		onResidualSubOrder = 2,
		onResidual = function(pokemon)
			self:heal(pokemon.maxhp / 16)
		end,
		gen = 2,
	},
	['leppaberry'] = {
		id = "leppaberry",
		name = "Leppa Berry",
		isBerry = true,
		flavour = {10, 0, 10, 10, 10},
		naturalGift = {
			basePower = 80,
			type = "Fighting"
		},
		onUpdate = function(pokemon)
			local move = pokemon:getMoveData(pokemon.lastMove)
			if move and move.pp == 0 then
				pokemon:addVolatile('leppaberry')
				pokemon.volatiles['leppaberry'].move = move
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			local move
			if pokemon.volatiles['leppaberry'] then
				move = pokemon.volatiles['leppaberry'].move
				pokemon:removeVolatile('leppaberry')
			else
				local pp = 99
				for _, m in pairs(pokemon.moveset) do
					if m.pp < pp then
						move = m
						pp = move.pp
					end
				end
			end
			move.pp = move.pp + 10
			if move.pp > move.maxpp then move.pp = move.maxpp end
			self:add('-activate', pokemon, 'item: Leppa Berry', move.move)
			if pokemon.item ~= 'leppaberry' then
				local foeActive = pokemon.side.foe.active
				local foeIsStale = false
				for _, foe in pairs(foeActive) do
					if foe ~= null and foe.isStale and foe.isStale >= 2 then
						foeIsStale = true
						break
					end
				end
				if not foeIsStale then return end
			end
			pokemon.isStale = 2
			pokemon.isStaleSource = 'useleppa'
		end,
	},
	['levelball'] = {
		id = "levelball",
		name = "Level Ball",
		gen = 2,
	},
	['liechiberry'] = {
		id = "liechiberry",
		name = "Liechi Berry",
		isBerry = true,
		flavour = {30, 10, 30, 0, 10},
		naturalGift = {
			basePower = 100,
			type = "Grass"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			self:boost({atk = 1})
		end,
	},
	['lifeorb'] = {
		id = "lifeorb",
		name = "Life Orb",
		fling = 30,
		onModifyDamage = function(damage, source, target, move)
			return self:chainModify(0x14CC, 0x1000)
		end,
		onAfterMoveSecondarySelf = function(source, target, move)
			if source and source ~= target and move and move.category ~= 'Status' and not move.ohko then
				self:add('') -- prevent the client from thinking that this damage is from the move
				self:damage(source.maxhp / 10, source, source, self:getItem('lifeorb'))
			end
		end,
	},
	['lightball'] = {
		id = "lightball",
		name = "Light Ball",
		fling = {
			basePower = 30,
			status = 'par'
		},
		onModifyAtkPriority = 1,
		onModifyAtk = function(atk, pokemon)
			if pokemon.baseTemplate.baseSpecies == 'Pikachu' then
				return self:chainModify(2)
			end
		end,
		onModifySpAPriority = 1,
		onModifySpA = function(spa, pokemon)
			if pokemon.baseTemplate.baseSpecies == 'Pikachu' then
				return self:chainModify(2)
			end
		end,
		gen = 2,
	},
	['lightclay'] = {
		id = "lightclay",
		name = "Light Clay",
		fling = 30,
		-- implemented in the corresponding thing
	},
	['lopunnite'] = {
		id = "lopunnite",
		name = "Lopunnite",
		megaStone = "Lopunny-Mega",
		megaEvolves = "Lopunny",
		onTakeItem = onTakeMegaStone,
	},
	['loveball'] = {
		id = "loveball",
		name = "Love Ball",
		gen = 2,
	},
	['lucarionite'] = {
		id = "lucarionite",
		name = "Lucarionite",
		megaStone = "Lucario-Mega",
		megaEvolves = "Lucario",
		onTakeItem = onTakeMegaStone,
	},
	['luckypunch'] = {
		id = "luckypunch",
		name = "Lucky Punch",
		fling = 40,
		onModifyMove = function(move, user)
			if user.baseTemplate.species == 'Chansey' then
				move.critRatio = move.critRatio + 2
			end
		end,
		gen = 2,
	},
	['lumberry'] = {
		id = "lumberry",
		name = "Lum Berry",
		isBerry = true,
		flavour = {10, 10, 10, 10, 0},
		naturalGift = {
			basePower = 80,
			type = "Flying"
		},
		onUpdate = function(pokemon)
			if (pokemon.status and pokemon.status ~= '') or pokemon.volatiles['confusion'] then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			pokemon:cureStatus()
			pokemon:removeVolatile('confusion')
		end,
	},
	['luminousmoss'] = {
		id = "luminousmoss",
		name = "Luminous Moss",
		fling = 30,
		onAfterDamage = function(damage, target, source, move)
			if move.type == 'Water' and target:useItem() then
				self:boost({spd = 1})
			end
		end,
	},
	['lureball'] = {
		id = "lureball",
		name = "Lure Ball",
		gen = 2,
	},
	['lustrousorb'] = {
		id = "lustrousorb",
		name = "Lustrous Orb",
		fling = 60,
		onBasePowerPriority = 6,
		onBasePower = function(basePower, user, target, move)
			if move and user.baseTemplate.species == 'Palkia' and (move.type == 'Water' or move.type == 'Dragon') then
				return self:chainModify(0x1333, 0x1000)
			end
		end,
	},
	['luxuryball'] = {
		id = "luxuryball",
		name = "Luxury Ball",
		isPokeball = true,
	},
	['machobrace'] = {
		id = "machobrace",
		name = "Macho Brace",
		fling = 60,
		onModifySpe = function(spe)
			return self:chainModify(0.5)
		end,
	},
	['magmarizer'] = {
		id = "magmarizer",
		name = "Magmarizer",
		fling = 80,
	},
	['magnet'] = {
		id = "magnet",
		name = "Magnet",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Electric'),
		gen = 2,
	},
	['magoberry'] = {
		id = "magoberry",
		name = "Mago Berry",
		isBerry = true,
		flavour = {0, 0, 15, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Ghost"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				pokemon:eatItem()
			end
		end,
		onEatItem = function(item, pokemon)
			if Not(self:runEvent('TryHeal', pokemon)) then return false end
		end,
		onEat = function(pokemon)
			self:heal(pokemon.maxhp / 8)
			if pokemon:getNature().minus == 'spe' then
				pokemon:addVolatile('confusion')
			end
		end,
	},
	['magostberry'] = {
		id = "magostberry",
		name = "Magost Berry",
		isBerry = true,
		flavour = {0, 0, 20, 10, 0},
		naturalGift = {
			basePower = 90,
			type = "Rock"
		},
	},
	['mail'] = {
		id = "mail",
		name = "Mail",
		onTakeItem = function(item, source)
			if not self.activeMove then return false end
			if self.activeMove.id ~= 'knockoff' and self.activeMove.id ~= 'thief' and self.activeMove.id ~= 'covet' then return false end
		end,
		isUnreleased = true,
		gen = 2,
	},
	['manectite'] = {
		id = "manectite",
		name = "Manectite",
		megaStone = "Manectric-Mega",
		megaEvolves = "Manectric",
		onTakeItem = onTakeMegaStone,
	},
	['marangaberry'] = {
		id = "marangaberry",
		name = "Maranga Berry",
		isBerry = true,
		flavour = {10, 10, 30, 30, 10},
		naturalGift = {
			basePower = 100,
			type = "Dark"
		},
		onAfterMoveSecondary = function(target, source, move)
			if move.category == 'Special' then
				target:eatItem()
			end
		end,
		onEat = function(pokemon)
			self:boost({spd = 1})
		end,
	},
	['masterball'] = {
		id = "masterball",
		name = "Master Ball",
		isPokeball = true,
		gen = 1,
	},
	['mawilite'] = {
		id = "mawilite",
		name = "Mawilite",
		megaStone = "Mawile-Mega",
		megaEvolves = "Mawile",
		onTakeItem = onTakeMegaStone,
	},
	['meadowplate'] = {
		id = "meadowplate",
		name = "Meadow Plate",
		onPlate = 'Grass',
		onBasePowerPriority = 6,
		onBasePower = plate('Grass'),
		onTakeItem = onTakePlate,
	},
	['medichamite'] = {
		id = "medichamite",
		name = "Medichamite",
		megaStone = "Medicham-Mega",
		megaEvolves = "Medicham",
		onTakeItem = onTakeMegaStone,
	},
	['mentalherb'] = {
		id = "mentalherb",
		name = "Mental Herb",
		fling = {
			basePower = 10,
			effect = function(pokemon)
				local conditions = {'attract', 'taunt', 'encore', 'torment', 'disable', 'healblock'}
				for _, c in pairs(conditions) do
					if pokemon.volatiles['attract'] and c == 'attract' then
						self:add('-end', pokemon, 'move: Attract', '[from] item: Mental Herb')
					end
					pokemon:removeVolatile(c)
				end
			end
		},
		onUpdate = function(pokemon)
			local conditions = {'attract', 'taunt', 'encore', 'torment', 'disable', 'healblock'}
			local used = false
			for _, c in pairs(conditions) do
				if pokemon.volatiles[c] then
					if pokemon.volatiles['attract'] and c == 'attract' then
						self:add('-end', pokemon, 'move: Attract', '[from] item: Mental Herb')
					end
					if not used then
						if not pokemon:useItem() then return end
						used = true
					end
					pokemon:removeVolatile(c)
				end
			end
		end,
	},
	['metagrossite'] = {
		id = "metagrossite",
		name = "Metagrossite",
		megaStone = "Metagross-Mega",
		megaEvolves = "Metagross",
		onTakeItem = onTakeMegaStone,
	},
	['metalcoat'] = {
		id = "metalcoat",
		name = "Metal Coat",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Steel'),
		gen = 2,
	},
	['metalpowder'] = {
		id = "metalpowder",
		name = "Metal Powder",
		fling = 10,
		onModifyDefPriority = 2,
		onModifyDef = function(def, pokemon)
			if pokemon.template.species == 'Ditto' and not pokemon.transformed then
				return self:chainModify(2)
			end
		end,
		gen = 2,
	},
	['metronome'] = {
		id = "metronome",
		name = "Metronome",
		fling = 30,
		onStart = function(pokemon)
			pokemon:addVolatile('metronome')
		end,
		effect = {
			onStart = function(pokemon)
				self.effectData.numConsecutive = 0
				self.effectData.lastMove = ''
			end,
			onBeforeMove = function(pokemon, target, move)
				if not pokemon:hasItem('metronome') then
					pokemon:removeVolatile('metronome')
					return
				end
				if self.effectData.lastMove == move.id then
					self.effectData.numConsecutive = self.effectData.numConsecutive + 1
				else
					self.effectData.numConsecutive = 0
				end
				self.effectData.lastMove = move.id
			end,
			onModifyDamage = function(damage, source, target, move)
				local numConsecutive = math.min(5, self.effectData.numConsecutive)
				local dmgMod = {0x1000, 0x1333, 0x1666, 0x1999, 0x1CCC, 0x2000}--{1, 1.2, 1.4, 1.6, 1.8, 2}
				return self:chainModify(dmgMod[numConsecutive+1], 0x1000)--self:chainModify(dmgMod[numConsecutive+1])
			end
		},
	},
	['mewtwonitex'] = {
		id = "mewtwonitex",
		name = "Mewtwonite X",
		megaStone = "Mewtwo-Mega-X",
		megaEvolves = "Mewtwo",
		onTakeItem = onTakeMegaStone,
	},
	['mewtwonitey'] = {
		id = "mewtwonitey",
		name = "Mewtwonite Y",
		megaStone = "Mewtwo-Mega-Y",
		megaEvolves = "Mewtwo",
		onTakeItem = onTakeMegaStone,
	},
	['micleberry'] = {
		id = "micleberry",
		name = "Micle Berry",
		isBerry = true,
		flavour = {0, 40, 10, 0, 0},
		naturalGift = {
			basePower = 100,
			type = "Rock"
		},
		onResidual = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			pokemon:addVolatile('micleberry')
		end,
		effect = {
			duration = 2,
			onSourceModifyAccuracy = function(accuracy, target, source)
				self:add('-enditem', source, 'Micle Berry')
				source:removeVolatile('micleberry')
				if type(accuracy) == 'number' then
					return accuracy * 1.2
				end
			end
		},
	},
	['mindplate'] = {
		id = "mindplate",
		name = "Mind Plate",
		onPlate = 'Psychic',
		onBasePowerPriority = 6,
		onBasePower = plate('Psychic'),
		onTakeItem = onTakePlate,
	},
	['miracleseed'] = {
		id = "miracleseed",
		name = "Miracle Seed",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Grass'),
		gen = 2,
	},
	['moonball'] = {
		id = "moonball",
		name = "Moon Ball",
		gen = 2,
	},
	['muscleband'] = {
		id = "muscleband",
		name = "Muscle Band",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = function(basePower, user, target, move)
			if move.category == 'Physical' then
				return self:chainModify(0x1199, 0x1000)
			end
		end,
	},
	['mysticwater'] = {
		id = "mysticwater",
		name = "Mystic Water",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Water'),
		gen = 2,
	},
	['nanabberry'] = {
		id = "nanabberry",
		name = "Nanab Berry",
		isBerry = true,
		flavour = {0, 0, 10, 10, 0},
		naturalGift = {
			basePower = 90,
			type = "Water"
		},
	},
	['nestball'] = {
		id = "nestball",
		name = "Nest Ball",
	},
	['netball'] = {
		id = "netball",
		name = "Net Ball",
		isPokeball = true,
	},
	['nevermeltice'] = {
		id = "nevermeltice",
		name = "Never-Melt Ice",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Ice'),
		gen = 2,
	},
	['nomelberry'] = {
		id = "nomelberry",
		name = "Nomel Berry",
		isBerry = true,
		flavour = {10, 0, 0, 0, 20},
		naturalGift = {
			basePower = 90,
			type = "Dragon"
		},
	},
	['normalgem'] = {
		id = "normalgem",
		name = "Normal Gem",
		isGem = true,
		onSourceTryPrimaryHit = gem('Normal', true),
	},
	['occaberry'] = {
		id = "occaberry",
		name = "Occa Berry",
		isBerry = true,
		flavour = {15, 0, 10, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Fire"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Fire'),
		onEat = function() end,
	},
	['oddincense'] = {
		id = "oddincense",
		name = "Odd Incense",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = plate('Psychic'),
	},
	['oldamber'] = {
		id = "oldamber",
		name = "Old Amber",
		fling = 100,
	},
	['oranberry'] = {
		id = "oranberry",
		name = "Oran Berry",
		isBerry = true,
		flavour = {10, 10, 0, 10, 10},
		naturalGift = {
			basePower = 80,
			type = "Poison"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				pokemon:eatItem()
			end
		end,
		onEatItem = function(item, pokemon)
			if Not(self:runEvent('TryHeal', pokemon)) then return false end
		end,
		onEat = function(pokemon)
			self:heal(10)
		end,
	},
	['pamtreberry'] = {
		id = "pamtreberry",
		name = "Pamtre Berry",
		isBerry = true,
		flavour = {0, 30, 10, 0, 0},
		naturalGift = {
			basePower = 90,
			type = "Steel"
		},
	},
	['parkball'] = {
		id = "parkball",
		name = "Park Ball",
		gen = 2,
	},
	['passhoberry'] = {
		id = "passhoberry",
		name = "Passho Berry",
		isBerry = true,
		flavour = {0, 15, 0, 10, 0},
		naturalGift = {
			basePower = 80,
			type = "Water"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Water'),
		onEat = function() end,
	},
	['payapaberry'] = {
		id = "payapaberry",
		name = "Payapa Berry",
		isBerry = true,
		flavour = {0, 0, 10, 0, 15},
		naturalGift = {
			basePower = 80,
			type = "Psychic"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Psychic'),
		onEat = function() end,
	},
	['pechaberry'] = {
		id = "pechaberry",
		name = "Pecha Berry",
		isBerry = true,
		flavour = {0, 0, 10, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Electric"
		},
		onUpdate = function(pokemon)
			if pokemon.status == 'psn' or pokemon.status == 'tox' then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			if pokemon.status == 'psn' or pokemon.status == 'tox' then
				pokemon:cureStatus()
			end
		end,
	},
	['persimberry'] = {
		id = "persimberry",
		name = "Persim Berry",
		isBerry = true,
		flavour = {10, 10, 10, 0, 10},
		naturalGift = {
			basePower = 80,
			type = "Ground"
		},
		onUpdate = function(pokemon)
			if pokemon.volatiles['confusion'] then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			pokemon:removeVolatile('confusion')
		end,
	},
	['petayaberry'] = {
		id = "petayaberry",
		name = "Petaya Berry",
		isBerry = true,
		flavour = {30, 0, 0, 30, 0},
		naturalGift = {
			basePower = 100,
			type = "Poison"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			self:boost({spa = 1})
		end,
	},
	['pidgeotite'] = {
		id = "pidgeotite",
		name = "Pidgeotite",
		megaStone = "Pidgeot-Mega",
		megaEvolves = "Pidgeot",
		onTakeItem = function(item, source)
			if item.megaEvolves == source.baseTemplate.baseSpecies then return false end
			return true
		end,
	},
	['pinapberry'] = {
		id = "pinapberry",
		name = "Pinap Berry",
		isBerry = true,
		flavour = {10, 0, 0, 0, 10},
		naturalGift = {
			basePower = 90,
			type = "Grass"
		},
	},
	['pinsirite'] = {
		id = "pinsirite",
		name = "Pinsirite",
		megaStone = "Pinsir-Mega",
		megaEvolves = "Pinsir",
		onTakeItem = onTakeMegaStone,
	},
	['pixieplate'] = {
		id = "pixieplate",
		name = "Pixie Plate",
		onPlate = 'Fairy',
		onBasePowerPriority = 6,
		onBasePower = plate('Fairy'),
		onTakeItem = onTakePlate,
	},
	['plumefossil'] = {
		id = "plumefossil",
		name = "Plume Fossil",
		fling = 100,
	},
	['poisonbarb'] = {
		id = "poisonbarb",
		name = "Poison Barb",
		fling = {
			basePower = 70,
			status = 'psn'
		},
		onBasePowerPriority = 6,
		onBasePower = plate('Poison'),
		gen = 2,
	},
	['poisongem'] = {
		id = "poisongem",
		name = "Poison Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Poison'),
	},
	['pokeball'] = {
		id = "pokeball",
		name = "Pok[e\'] Ball",
		isPokeball = true,
		gen = 1,
	},
	['pomegberry'] = {
		id = "pomegberry",
		name = "Pomeg Berry",
		isBerry = true,
		flavour = {10, 0, 10, 10, 0},
		naturalGift = {
			basePower = 90,
			type = "Ice"
		},
	},
	['powerherb'] = {
		id = "powerherb",
		onChargeMove = function(pokemon, target, move)
			if pokemon:useItem() then
				self:debug('power herb - remove charge turn for ' .. move.id)
				return false -- skip charge turn
			end
		end,
		name = "Power Herb",
		fling = 10,
	},
	['premierball'] = {
		id = "premierball",
		name = "Premier Ball",
		isPokeball = true,
	},
	['psychicgem'] = {
		id = "psychicgem",
		name = "Psychic Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Psychic'),
	},
	['qualotberry'] = {
		id = "qualotberry",
		name = "Qualot Berry",
		isBerry = true,
		flavour = {10, 0, 10, 0, 10},
		naturalGift = {
			basePower = 90,
			type = "Poison"
		},
	},
	['quickball'] = {
		id = "quickball",
		name = "Quick Ball",
		isPokeball = true
	},
	['quickclaw'] = {
		id = "quickclaw",
		onModifyPriority = function(priority, pokemon)
			if math.random(5) == 1 then
				self:add('-activate', pokemon, 'item = Quick Claw')
				return priority + 0.1
			end
		end,
		name = "Quick Claw",
		fling = 80,
		gen = 2,
	},
	['quickpowder'] = {
		id = "quickpowder",
		name = "Quick Powder",
		fling = 10,
		onModifySpe = function(spe, pokemon)
			if pokemon.template.species == 'Ditto' and not pokemon.transformed then
				return self:chainModify(2)
			end
		end,
	},
	['rabutaberry'] = {
		id = "rabutaberry",
		name = "Rabuta Berry",
		isBerry = true,
		flavour = {0, 0, 0, 20, 10},
		naturalGift = {
			basePower = 90,
			type = "Ghost"
		},
	},
	['rarebone'] = {
		id = "rarebone",
		name = "Rare Bone",
		fling = 100,
	},
	['rawstberry'] = {
		id = "rawstberry",
		name = "Rawst Berry",
		isBerry = true,
		flavour = {0, 0, 0, 10, 0},
		naturalGift = {
			basePower = 80,
			type = "Grass"
		},
		onUpdate = function(pokemon)
			if pokemon.status == 'brn' then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			if pokemon.status == 'brn' then
				pokemon:cureStatus()
			end
		end,
	},
	['razorclaw'] = {
		id = "razorclaw",
		name = "Razor Claw",
		fling = 80,
		onModifyMove = function(move)
			move.critRatio = move.critRatio + 1
		end,
	},
	['razorfang'] = {
		id = "razorfang",
		name = "Razor Fang",
		fling = {
			basePower = 30,
			volatileStatus = 'flinch'
		},
		onModifyMovePriority = -1,
		onModifyMove = function(move)
			if move.category ~= "Status" then
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
	},
	['razzberry'] = {
		id = "razzberry",
		name = "Razz Berry",
		isBerry = true,
		flavour = {10, 10, 0, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Steel"
		},
	},
	['redcard'] = {
		id = "redcard",
		name = "Red Card",
		fling = 10,
		onAfterMoveSecondary = function(target, source, move)
			if source and source ~= target and source.hp and target.hp and move and move.category ~= 'Status' then
				if not source.isActive or not source.side:canSwitch(source.position) or target.forceSwitchFlag then return end
				if target:useItem(nil, source) then -- This order is correct - the item is used up even against a pokemon with Ingrain or that otherwise can't be forced out
					if not Not(self:runEvent('DragOut', source, target, move)) then
						self:dragIn(source.side, source.position)
					end
				end
			end
		end,
	},
	['redorb'] = {
		id = "redorb",
		name = "Red Orb",
		onSwitchInPriority = -6,
		onSwitchIn = function(pokemon)
			local template = self:getTemplate('Groudon')           
			if pokemon.isActive and pokemon.baseTemplate == template then
				local primaltemplate = self:getTemplate('Groudon-Primal')
				self:add('detailschange', pokemon, pokemon.details, '[primalG]', '[icon] '..(primaltemplate.icon or 0))

				pokemon:formeChange(primaltemplate)
				pokemon.baseTemplate = primaltemplate

				pokemon:setAbility(primaltemplate.abilities[1])
				pokemon.baseAbility = pokemon.ability
				pokemon.details = pokemon.species .. ', L' .. pokemon.level .. (pokemon.gender == '' and '' or ', ') .. pokemon.gender .. (pokemon.set.shiny and ', shiny' or '')
				local shinyPrefix = pokemon.shiny and '_SHINY' or ''
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_FRONT/Groudon-Primal')
				self:setupDataForTransferToPlayers('Sprite', shinyPrefix..'_BACK/Groudon-Primal')

				pokemon.iconOverride = primaltemplate.icon-1
				pokemon.frontSpriteOverride = require(game:GetService('ServerStorage').Data.Spritesheets)[shinyPrefix..'_FRONT']['Groudon-Primal']

				pokemon.abilityOverride = primaltemplate.abilities[1]
				pokemon.typeOverride = primaltemplate.types
				pokemon.baseStatOverride = primaltemplate.baseStats
			else return end
		end,
	},

	['repeatball'] = {
		id = "repeatball",
		name = "Repeat Ball",
	},
	['rindoberry'] = {
		id = "rindoberry",
		name = "Rindo Berry",
		isBerry = true,
		flavour = {10, 0, 0, 15, 0},
		naturalGift = {
			basePower = 80,
			type = "Grass"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Grass'),
		onEat = function() end,
	},
	['ringtarget'] = {
		id = "ringtarget",
		name = "Ring Target",
		fling = 10,
		onNegateImmunity = function(pokemon, type)
			if self.data.TypeChart[type] and not Not(self:runEvent('Immunity', pokemon, nil, nil, type)) then return false end
		end,
	},
	['rockgem'] = {
		id = "rockgem",
		name = "Rock Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Rock'),
	},
	['rockincense'] = {
		id = "rockincense",
		name = "Rock Incense",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = plate('Rock'),
	},
	['rockyhelmet'] = {
		id = "rockyhelmet",
		name = "Rocky Helmet",
		fling = 60,
		onAfterDamageOrder = 2,
		onAfterDamage = function(damage, target, source, move)
			if source and source ~= target and move and move.flags['contact'] then
				self:damage(source.maxhp / 6, source, target, nil, true)
			end
		end,
	},
	['rootfossil'] = {
		id = "rootfossil",
		name = "Root Fossil",
		fling = 100,
	},
	['roseincense'] = {
		id = "roseincense",
		name = "Rose Incense",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = plate('Grass'),
	},
	['roseliberry'] = {
		id = "roseliberry",
		name = "Roseli Berry",
		isBerry = true,
		flavour = {0, 0, 25, 10, 0},
		naturalGift = {
			basePower = 80,
			type = "Fairy"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Fairy'),
		onEat = function() end,
	},
	['rowapberry'] = {
		id = "rowapberry",
		name = "Rowap Berry",
		isBerry = true,
		flavour = {10, 0, 0, 0, 40},
		naturalGift = {
			basePower = 100,
			type = "Dark"
		},
		onAfterMoveSecondary = function(target, source, move)
			if source and source ~= target and move and move.category == 'Special' then
				if target:eatItem() then
					self:damage(source.maxhp / 8, source, target, nil, true)
				end
			end
		end,
		onEat = function() end,
	},
	['sablenite'] = {
		id = "sablenite",
		name = "Sablenite",
		megaStone = "Sableye-Mega",
		megaEvolves = "Sableye",
		onTakeItem = onTakeMegaStone,
	},
	['safariball'] = {
		id = "safariball",
		name = "Safari Ball",
		isPokeball = true,
		gen = 1,
	},
	['safetygoggles'] = {
		id = "safetygoggles",
		name = "Safety Goggles",
		fling = 80,
		onImmunity = function(type, pokemon)
			if type == 'sandstorm' or type == 'hail' or type == 'powder' then return false end
		end,
		onTryHit = function(pokemon, source, move)
			if move.flags['powder'] and move.id ~= 'ragepowder' then
				self:add('-activate', pokemon, 'Safety Goggles', move.name)
				return null
			end
		end,
	},
	['salacberry'] = {
		id = "salacberry",
		name = "Salac Berry",
		isBerry = true,
		flavour = {0, 0, 30, 10, 30},
		naturalGift = {
			basePower = 100,
			type = "Fighting"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			self.boost({spe = 1})
		end,
	},
	['salamencite'] = {
		id = "salamencite",
		name = "Salamencite",
		megaStone = "Salamence-Mega",
		megaEvolves = "Salamence",
		onTakeItem = onTakeMegaStone,
	},
	['sceptilite'] = {
		id = "sceptilite",
		name = "Sceptilite",
		megaStone = "Sceptile-Mega",
		megaEvolves = "Sceptile",
		onTakeItem = onTakeMegaStone,
	},
	['scizorite'] = {
		id = "scizorite",
		name = "Scizorite",
		megaStone = "Scizor-Mega",
		megaEvolves = "Scizor",
		onTakeItem = onTakeMegaStone,
	},
	['scopelens'] = {
		id = "scopelens",
		name = "Scope Lens",
		fling = 30,
		onModifyMove = function(move)
			move.critRatio = move.critRatio + 1
		end,
		gen = 2,
	},
	['seaincense'] = {
		id = "seaincense",
		name = "Sea Incense",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = plate('Water'),
	},
	['sharpbeak'] = {
		id = "sharpbeak",
		name = "Sharp Beak",
		fling = 50,
		onBasePowerPriority = 6,
		onBasePower = plate('Flying'),
		gen = 2,
	},
	['sharpedonite'] = {
		id = "sharpedonite",
		name = "Sharpedonite",
		megaStone = "Sharpedo-Mega",
		megaEvolves = "Sharpedo",
		onTakeItem = onTakeMegaStone,
	},
	['shedshell'] = {
		id = "shedshell",
		name = "Shed Shell",
		fling = 10,
		onModifyPokemonPriority = -10,
		onModifyPokemon = function(pokemon)
			pokemon.trapped = false
			pokemon.maybeTrapped = false
		end,
	},
	['shellbell'] = {
		id = "shellbell",
		name = "Shell Bell",
		fling = 30,
		onAfterMoveSecondarySelfPriority = -1,
		onAfterMoveSecondarySelf = function(pokemon, target, move)
			if move.category ~= 'Status' then
				self:heal(pokemon.lastDamage / 8, pokemon)
			end
		end,
	},
	['shockdrive'] = {
		id = "shockdrive",
		name = "Shock Drive",
		onTakeItem = onTakeDrive,
		onDrive = 'Electric',
	},
	['shucaberry'] = {
		id = "shucaberry",
		name = "Shuca Berry",
		isBerry = true,
		flavour = {10, 0, 15, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Ground"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Ground'),
		onEat = function() end,
	},
	['silkscarf'] = {
		id = "silkscarf",
		name = "Silk Scarf",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = plate('Normal'),
	},
	['silverpowder'] = {
		id = "silverpowder",
		name = "SilverPowder",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = plate('Bug'),
		gen = 2,
	},
	['sitrusberry'] = {
		id = "sitrusberry",
		name = "Sitrus Berry",
		isBerry = true,
		flavour = {0, 10, 10, 10, 10},
		naturalGift = {
			basePower = 80,
			type = "Psychic"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				pokemon:eatItem()
			end
		end,
		onEatItem = function(item, pokemon)
			if Not(self:runEvent('TryHeal', pokemon)) then return false end
		end,
		onEat = function(pokemon)
			self:heal(pokemon.maxhp / 4)
		end,
	},
	['skullfossil'] = {
		id = "skullfossil",
		name = "Skull Fossil",
		fling = 100,
	},
	['skyplate'] = {
		id = "skyplate",
		name = "Sky Plate",
		onPlate = 'Flying',
		onBasePowerPriority = 6,
		onBasePower = plate('Flying'),
		onTakeItem = onTakePlate,
	},
	['slowbronite'] = {
		id = "slowbronite",
		name = "Slowbronite",
		megaStone = "Slowbro-Mega",
		megaEvolves = "Slowbro",
		onTakeItem = onTakeMegaStone,
	},
	['smoothrock'] = {
		id = "smoothrock",
		name = "Smooth Rock",
		fling = 10,
	},
	['snowball'] = {
		id = "snowball",
		name = "Snowball",
		fling = 30,
		onAfterDamage = function(damage, target, source, move)
			if move.type == 'Ice' and target:useItem() then
				self:boost({atk = 1})
			end
		end,
	},
	['softsand'] = {
		id = "softsand",
		name = "Soft Sand",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = plate('Ground'),
		gen = 2,
	},
	['souldew'] = {
		id = "souldew",
		name = "Soul Dew",
		fling = 30,
		onModifySpAPriority = 1,
		onModifySpA = function(spa, pokemon)
			if pokemon.baseTemplate.num == 380 or pokemon.baseTemplate.num == 381 then
				return self:chainModify(1.5)
			end
		end,
		onModifySpDPriority = 2,
		onModifySpD = function(spd, pokemon)
			if pokemon.baseTemplate.num == 380 or pokemon.baseTemplate.num == 381 then
				return self:chainModify(1.5)
			end
		end,
	},
	['spelltag'] = {
		id = "spelltag",
		name = "Spell Tag",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Ghost'),
		gen = 2,
	},
	['spelonberry'] = {
		id = "spelonberry",
		name = "Spelon Berry",
		isBerry = true,
		flavour = {30, 10, 0, 0, 0},
		naturalGift = {
			basePower = 90,
			type = "Dark"
		},
	},
	['splashplate'] = {
		id = "splashplate",
		name = "Splash Plate",
		onPlate = 'Water',
		onBasePowerPriority = 6,
		onBasePower = plate('Water'),
		onTakeItem = onTakePlate,
	},
	['spookyplate'] = {
		id = "spookyplate",
		name = "Spooky Plate",
		onPlate = 'Ghost',
		onBasePowerPriority = 6,
		onBasePower = plate('Ghost'),
		onTakeItem = onTakePlate,
	},
	['sportball'] = {
		id = "sportball",
		name = "Sport Ball",
	},
	['starfberry'] = {
		id = "starfberry",
		name = "Starf Berry",
		isBerry = true,
		flavour = {30, 10, 30, 10, 30},
		naturalGift = {
			basePower = 100,
			type = "Psychic"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/4 or (pokemon.hp <= pokemon.maxhp/2 and pokemon:hasAbility('gluttony')) then
				pokemon:eatItem()
			end
		end,
		onEat = function(pokemon)
			local stats = {}
			for b, boost in pairs(pokemon.boosts) do
				if b ~= 'accuracy' and b ~= 'evasion' and boost < 6 then
					table.insert(stats, b)
				end
			end
			if #stats > 0 then
				local b = stats[math.random(#stats)]
				self:boost({[b] = 2})
			end
		end,
	},
	['steelixite'] = {
		id = "steelixite",
		name = "Steelixite",
		megaStone = "Steelix-Mega",
		megaEvolves = "Steelix",
		onTakeItem = onTakeMegaStone,
	},
	['steelgem'] = {
		id = "steelgem",
		name = "Steel Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Steel'),
	},
	['stick'] = {
		id = "stick",
		name = "Stick",
		fling = 60,
		onModifyMove = function(move, user)
			if user.baseTemplate.species == 'Farfetch\'d' then
				move.critRatio = move.critRatio + 2
			end
		end,
		gen = 2,
	},
	['stickybarb'] = {
		id = "stickybarb",
		name = "Sticky Barb",
		fling = 80,
		onResidualOrder = 26,
		onResidualSubOrder = 2,
		onResidual = function(pokemon)
			self:damage(pokemon.maxhp / 8)
		end,
		onHit = function(target, source, move)
			if source and source ~= target and (not source.item or source.item == '') and move and move.flags['contact'] then
				local barb = target:takeItem()
				source:setItem(barb)
				-- no message for Sticky Barb changing hands
			end
		end,
	},
	['stoneplate'] = {
		id = "stoneplate",
		name = "Stone Plate",
		onPlate = 'Rock',
		onBasePowerPriority = 6,
		onBasePower = plate('Rock'),
		onTakeItem = onTakePlate,
	},
	['swampertite'] = {
		id = "swampertite",
		name = "Swampertite",
		megaStone = "Swampert-Mega",
		megaEvolves = "Swampert",
		onTakeItem = onTakeMegaStone,
	},
	['tamatoberry'] = {
		id = "tamatoberry",
		name = "Tamato Berry",
		isBerry = true,
		flavour = {20, 10, 0, 0, 0},
		naturalGift = {
			basePower = 90,
			type = "Psychic"
		},
	},
	['tangaberry'] = {
		id = "tangaberry",
		name = "Tanga Berry",
		isBerry = true,
		flavour = {20, 0, 0, 0, 10},
		naturalGift = {
			basePower = 80,
			type = "Bug"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Bug'),
		onEat = function() end,
	},
	['thickclub'] = {
		id = "thickclub",
		name = "Thick Club",
		fling = 90,
		onModifyAtkPriority = 1,
		onModifyAtk = function(atk, pokemon)
			if pokemon.baseTemplate.species == 'Cubone' or pokemon.baseTemplate.species == 'Marowak' then
				return self:chainModify(2)
			end
		end,
		gen = 2,
		icon = 107,
	},
	['timerball'] = {
		id = "timerball",
		name = "Timer Ball",
	},
	['toxicorb'] = {
		id = "toxicorb",
		name = "Toxic Orb",
		fling = {
			basePower = 30,
			status = 'tox'
		},
		onResidualOrder = 26,
		onResidualSubOrder = 2,
		onResidual = function(pokemon)
			pokemon:trySetStatus('tox')
		end,
	},
	['toxicplate'] = {
		id = "toxicplate",
		name = "Toxic Plate",
		onPlate = 'Poison',
		onBasePowerPriority = 6,
		onBasePower = plate('Poison'),
		onTakeItem = onTakePlate,
	},
	['twistedspoon'] = {
		id = "twistedspoon",
		name = "TwistedSpoon",
		fling = 30,
		onBasePowerPriority = 6,
		onBasePower = plate('Psychic'),
		gen = 2,
	},
	['tyranitarite'] = {
		id = "tyranitarite",
		name = "Tyranitarite",
		megaStone = "Tyranitar-Mega",
		megaEvolves = "Tyranitar",
		onTakeItem = onTakeMegaStone,
	},
	['ultraball'] = {
		id = "ultraball",
		name = "Ultra Ball",
		isPokeball = true,
		gen = 1,
	},
	['venusaurite'] = {
		id = "venusaurite",
		name = "Venusaurite",
		megaStone = "Venusaur-Mega",
		megaEvolves = "Venusaur",
		onTakeItem = onTakeMegaStone,
	},
	['wacanberry'] = {
		id = "wacanberry",
		name = "Wacan Berry",
		isBerry = true,
		flavour = {0, 0, 15, 0, 10},
		naturalGift = {
			basePower = 80,
			type = "Electric"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Electric'),
		onEat = function() end,
	},
	['watergem'] = {
		id = "watergem",
		name = "Water Gem",
		isUnreleased = true,
		isGem = true,
		onSourceTryPrimaryHit = gem('Water', true),
	},
	['watmelberry'] = {
		id = "watmelberry",
		name = "Watmel Berry",
		isBerry = true,
		flavour = {0, 0, 30, 10, 0},
		naturalGift = {
			basePower = 100,
			type = "Fire"
		},
	},
	['waveincense'] = {
		id = "waveincense",
		name = "Wave Incense",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = plate('Water'),
	},
	['weaknesspolicy'] = {
		id = "weaknesspolicy",
		name = "Weakness Policy",
		fling = 80,
		onHit = function(target, source, move)
			if (target.hp and target.hp > 0) and move.category ~= 'Status' and (not move.damage or move.damage == 0) and not move.damageCallback and (move.typeMod and move.typeMod > 0) and target:useItem() then
				self:boost({atk = 2, spa = 2})
			end
		end,
	},
	['wepearberry'] = {
		id = "wepearberry",
		name = "Wepear Berry",
		isBerry = true,
		flavour = {0, 0, 0, 10, 10},
		naturalGift = {
			basePower = 90,
			type = "Electric"
		},
	},
	['whiteherb'] = {
		id = "whiteherb",
		name = "White Herb",
		fling = {
			basePower = 10,
			effect = function(pokemon)
				local activate = false
				local boosts = {}
				for b, boost in pairs(pokemon.boosts) do
					if boost < 0 then
						activate = true
						boosts[b] = 0
					end
				end
				if activate then
					pokemon:setBoost(boosts)
				end
			end
		},
		onUpdate = function(pokemon)
			local activate = false
			local boosts = {}
			for b, boost in pairs(pokemon.boosts) do
				if boost < 0 then
					activate = true
					boosts[b] = 0
				end
			end
			if activate and pokemon:useItem() then
				pokemon:setBoost(boosts)
				self:add('-restoreboost', pokemon, '[silent]')
			end
		end,
	},
	['widelens'] = {
		id = "widelens",
		name = "Wide Lens",
		fling = 10,
		onSourceModifyAccuracy = function(accuracy)
			if type(accuracy) == 'number' then
				return accuracy * 1.1
			end
		end,
	},
	['wikiberry'] = {
		id = "wikiberry",
		name = "Wiki Berry",
		isBerry = true,
		flavour = {0, 15, 0, 0, 0},
		naturalGift = {
			basePower = 80,
			type = "Rock"
		},
		onUpdate = function(pokemon)
			if pokemon.hp <= pokemon.maxhp/2 then
				pokemon:eatItem()
			end
		end,
		onEatItem = function(item, pokemon)
			if Not(self:runEvent('TryHeal', pokemon)) then return false end
		end,
		onEat = function(pokemon)
			self:heal(pokemon.maxhp / 8)
			if pokemon:getNature().minus == 'spa' then
				pokemon:addVolatile('confusion')
			end
		end,
	},
	['wiseglasses'] = {
		id = "wiseglasses",
		name = "Wise Glasses",
		fling = 10,
		onBasePowerPriority = 6,
		onBasePower = function(basePower, user, target, move)
			if move.category == 'Special' then
				return self:chainModify(0x1199, 0x1000)
			end
		end,
	},
	['yacheberry'] = {
		id = "yacheberry",
		name = "Yache Berry",
		isBerry = true,
		flavour = {0, 10, 0, 0, 15},
		naturalGift = {
			basePower = 80,
			type = "Ice"
		},
		onSourceModifyDamage = superEffectiveReductionBerry('Ice'),
		onEat = function() end,
	},
	['zapplate'] = {
		id = "zapplate",
		name = "Zap Plate",
		onPlate = 'Electric',
		onBasePowerPriority = 6,
		onBasePower = plate('Electric'),
		onTakeItem = onTakePlate,
	},
	['zoomlens'] = {
		id = "zoomlens",
		name = "Zoom Lens",
		fling = 10,
		onSourceModifyAccuracy = function(accuracy, target)
			if type(accuracy) == 'number' and Not(self:willMove(target)) then
				self:debug('Zoom Lens boosting accuracy')
				return accuracy * 1.2
			end
		end,
	},
	
	['dragonscale'] = {
		id = "dragonscale",
		name = "Dragon Scale",
		gen = 2,
	},

	
	
}