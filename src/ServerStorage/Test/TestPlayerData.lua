local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework'))

	local BitBuffer = _f.BitBuffer
	local PlayerData = _f.PlayerDataService[game.Players.LocalPlayer]
	local function newPokemon(t)
		return _f.ServerP:new(t, PlayerData)
	end
	
	PlayerData.expShareOn = true
	
	PlayerData.party = {
		--[= =[
		newPokemon {
			name = 'Swampert',--'Swampert',
			level = 61,
			pokeball = 29,
			stamps = {
				{sheet = 1, n = 1, color = 12, style = 4}
			},
			hp = 90,
			item = 'cheriberry',--'swampertite',
			status = 'par',
			moves = {
				{id = 'assist'},
--				{id = 'icebeam'},
--				{id = 'solarbeam'},
--				{id = 'sunnyday'}
			},
		},
		newPokemon {
			name = 'Onix',
			forme = 'crystal',
			level = 40,
		},
		newPokemon {
			name = 'Steelix',
			forme = 'crystal',
			level = 100,
		},
		newPokemon {
			name = 'Aegislash',
			level = 40,
			moves = {
				{id = 'slash'},
				{id = 'kingsshield'},
				{id = 'rockclimb'},
			},
		},
--[[		newPokemon {
			name = 'Gengar',
			forme = 'hallow',
			shiny = true,
			level = 53,
			item = 'gengariteh',--'luckincense',--
			moves = {
				{id = 'leafage'},
				{id = 'throatchop'},
				{id = 'cut'}
			},
		},--]]
		newPokemon {
			name = 'Hawlucha',
			level = 59,
			moves = {
				{id = 'fly'},
				{id = 'acrobatics'},
				{id = 'dig'},
				{id = 'rocksmash'}
			},
		},
--		newPokemon {
--			name = 'Ditto',
--			item = 'destinyknot',
--			level = 58,
--			ivs = {999, 999, 999, 999, 999, 999},
--		},
		newPokemon {
			name = 'Togepi',
			egg = true, --fossilEgg = true,
			eggCycles = 1,
		},--]==]
--[[
		newPokemon {
			name = 'Dialga',
			forme = 'dark',
			level = 60,
			moves = {
				{id = 'roaroftime'},
				{id = 'shadowforce'},
				{id = 'flashcannon'},
				{id = 'dracometeor'}
			},
		},
		newPokemon {
			name = 'Regigigas',
			forme = 'dark',
			level = 60,
			moves = {
				{id = 'suckerpunch'},
				{id = 'gigaimpact'},
				{id = 'swordsdance'},
				{id = 'crushgrip'}
			},
		},
		newPokemon {
			name = 'Landorus',
			forme = 'dark',
			level = 60,
			moves = {
				{id = 'gravity'},
				{id = 'earthquake'},
				{id = 'aeroblast'},
--				{id = 'nightdaze'}
			},
		},
		newPokemon {
			name = 'Groudon',
			forme = 'dark',
			level = 60,
			moves = {
				{id = 'precipiceblades'},
				{id = 'thunderbolt'},
				{id = 'shadowball'},
				{id = 'stoneedge'}
			},
		},
		newPokemon {
			name = 'Entei',
			forme = 'dark',
			level = 60,
			moves = {
				{id = 'shadowball'},
				{id = 'eruption'},
				{id = 'rest'},
				{id = 'sleeptalk'}
			},
		},
		newPokemon {
			name = 'Mewtwo',
			forme = 'dark',
			level = 60,
			moves = {
				{id = 'reflect'},
				{id = 'psyshock'},
				{id = 'mefirst'},
				{id = 'recover'}
			},
		},--]]
	}
	-- make a pokemon close to leveling up
--	local pokemon = PlayerData.party[1]
--	pokemon.experience = pokemon:getRequiredExperienceForLevel(pokemon.level+1)-10
	
	PlayerData.stampSpins = 60
	for i = 1, 50 do PlayerData:spinForStamp() end
-- [[
	local testItems = {'pixieplate','dreadplate','flameplate','splashplate','umvbattery','sailfossil','thunderstone','oddkeystone','oldrod','pokeball','greatball','ultraball','duskball','quickball','potion','paralyzeheal','antidote','freshwater','expshare','superrepel','revive','maxrevive','rarecandy','rarecandy','rarecandy','rarecandy','megakeystone',
		'cheriberry', 'chestoberry', 'pechaberry', 'rawstberry', 'aspearberry', 'basementkey', 'skytrainpass', 'dracoball', 'zapball', 'toxicball', 'pumpkinball', 'fullheal', 'abilitycapsule', 'dawnstone', 'honey', 'icestone', 'heartscale', 'gracidea', 'pokeflute'}
	for i, v in pairs(testItems) do
		local item = _f.Database.ItemById[v]
		testItems[i] = { num = item.num, quantity = 3 }
	end
	PlayerData:addBagItems(unpack(testItems))--]]
--	PlayerData:addBagItems({id = 'sawsbuckcoffee', quantity = 1})
	
	local firstNonEgg = PlayerData:getFirstNonEgg()
	_f.Network:post('PDChanged', PlayerData.player, 'firstNonEggLevel', firstNonEgg.level,
		'firstNonEggAbility', firstNonEgg:getAbilityName())
	
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Mudkip',
		level = 5,
		shinyChance = 4096,
		item = 48,
	})
	for i = 1, 10 do
		PlayerData:PC_sendToStore(newPokemon{
			name = 'Groudon',
			level = 40,
			shiny = true,
		})
	end
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Rhyhorn',
		egg = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Porygon',
		level = 10,
		shinyChance = 4096,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Porygon-Z',
		level = 10,
		shinyChance = 4096,
	})
	PlayerData:PC_sendToStore(newPokemon{
		num = 669, -- Flabebe
		egg = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		num = 669, -- Flabebe
		egg = true,
		forme = 'o',
	})
	PlayerData:PC_sendToStore(newPokemon{
		num = 669, -- Flabebe
		egg = true,
		forme = 'y',
	})
	PlayerData:PC_sendToStore(newPokemon{
		num = 669, -- Flabebe
		egg = true,
		forme = 'w',
	})
	PlayerData:PC_sendToStore(newPokemon{
		num = 669, -- Flabebe
		egg = true,
		forme = 'b',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Landorus',
		egg = false,
		forme = 'Dark',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Pumpkaboo',
		egg = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Pumpkaboo',
		egg = true,
		forme = 'L',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Pumpkaboo',
		egg = true,
		forme = 'S',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Sandshrew',
		egg = true,
		forme = 'Alola',
})





	PlayerData:PC_sendToStore(newPokemon{
		name = 'Sandshrew',
		level = 10,
		forme = 'Alola',
--		shiny = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Sandslash',
		level = 30,
		forme = 'Alola',
--		shiny = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Sandslash',
		level = 30,
		forme = 'Alola',
		shiny = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Vulpix',
		egg = true,
		forme = 'Alola',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Vulpix',
		level = 10,
		forme = 'Alola',
--		shiny = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Ninetales',
		level = 30,
		forme = 'Alola',
--		shiny = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Rowlet',
		egg = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Litten',
		egg = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Popplio',
		egg = true,
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Rowlet',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Litten',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Popplio',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Dartrix',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Torracat',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Brionne',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Decidueye',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Incineroar',
	})
	PlayerData:PC_sendToStore(newPokemon{
		name = 'Primarina',
	})
--	PlayerData.pokedex = 'adXO0BhinAs9dhnvX5uJTGNDEytdifuiygGFmndOISBUYHOQWRUBAFsiyawuehabflaiusdvHILDFJ'--string.rep('/', 300)--
	PlayerData.money = 2600
	local t = {}
	for i = 1, 10 do
		local tm = math.random(100)
		table.insert(t, tm)
		PlayerData.tms = BitBuffer.SetBit(PlayerData.tms, tm, true)
	end
	local h = {}
	for i = 1, 3 do
		local hm = math.random(7)
		table.insert(h, hm)
		PlayerData.hms = BitBuffer.SetBit(PlayerData.hms, hm, true)
	end
--	PlayerData.defeatedTrainers = '//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////'
	PlayerData:winGymBadge(1)
	PlayerData:winGymBadge(2)
	PlayerData:winGymBadge(3)
	PlayerData:winGymBadge(4)
	PlayerData:winGymBadge(5)
	PlayerData:winGymBadge(6)
	PlayerData:completeEventServer('PBSIntro')
	PlayerData.bp = 500 _f.Network:post('updatePD', PlayerData.player, 'bp', 500)
	PlayerData.daycare.depositedPokemon[1] = newPokemon {
		name = 'Ninetales',
		level = 33,
		gender = 'M',
		depositedLevel = 23,
--		moves = {
--			{id='aquajet'},
--			{id='muddywater'},
--		}
	}
	PlayerData.daycare.depositedPokemon[2] = newPokemon {
		name = 'Ninetales',
		level = 29,
		gender = 'F',
		depositedLevel = 29,
		forme = 'Alola'
	}
	PlayerData.daycare.manHasEgg = true
	PlayerData.completedEvents.RJO = true
	PlayerData.completedEvents.RJP = true
	PlayerData.completedEvents.GJO = true
	PlayerData.completedEvents.GJP = true
	PlayerData.completedEvents.PJO = true
	PlayerData.completedEvents.PJP = true
	PlayerData.completedEvents.BJO = true
	PlayerData.completedEvents.BJP = true
	PlayerData.completedEvents.TEinCastle = true
	
--	PlayerData.completedEvents.Jirachi = true
--	PlayerData.completedEvents.Shaymin = true
--	PlayerData.completedEvents.Victini = true
	PlayerData.completedEvents.RNatureForces = true
--	PlayerData.completedEvents.Landorus = true
--[[	
--		self.party[3].untradable = true
--		print(table.concat(h, ', '))
		PlayerData.completedEvents.MeetJake = true
		PlayerData.completedEvents.MeetParents = true
		PlayerData.completedEvents.ChooseFirstPokemon = true
		PlayerData.completedEvents.JakeBattle1 = true
		PlayerData.completedEvents.BronzeBrickStolen = true
		PlayerData.completedEvents.JakeTracksLinda = true
		PlayerData.completedEvents.IntroducedToGym1 = true
		PlayerData.completedEvents.RunningShoesGiven = true
		PlayerData.completedEvents.JakeBattle2 = true
		PlayerData.completedEvents.IntroToUMV = true
--		PlayerData.completedEvents.TestDriveUMV = true
--		PlayerData.completedEvents.GroudonScene = true
		PlayerData.completedEvents.JakeStartFollow = true
--		PlayerData.completedEvents.JakeEndFollow = true
		PlayerData.completedEvents.LighthouseScene = true
		PlayerData.completedEvents.ProfAfterGym3 = true
		PlayerData.completedEvents.JakeAndTessDepart = true
		PlayerData.completedEvents.RotomBit1 = true
		PlayerData.completedEvents.RotomBit2 = true
		PlayerData.completedEvents.JTBattlesR9 = true
--		PlayerData.completedEvents.G4GaveTape = true
--		PlayerData.completedEvents.G4GaveWrench = true
--		PlayerData.completedEvents.G4GaveHammer = true
		PlayerData.badges[1] = true
		PlayerData.badges[2] = true
		PlayerData.badges[3] = true
		PlayerData.badges[4] = true
		PlayerData.money = 24000--MAX_MONEY--
		_p.PlayerList:updateStatus()
--		_p.Repel.steps = 999
		self.evivViewer = true
		_p.Menu.options.hasWBag = true
		PlayerData.honey = {
			slatheredAt = os.time() - 60*65,
			foe = pokemon:new {
				name = 'Teddiursa',--'Combee',
				level = 20,
			},
		}
		self.completedEvents.MeetAbsol = true
		--]]
	
	PlayerData:onGameBegin()
return 0