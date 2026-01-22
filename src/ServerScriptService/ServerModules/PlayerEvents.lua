print("PlayerEvent")
--local _f = require(script.Parent.Parent)
-- todo: prerequisites

local function RotomEvent(n)
	return {
		pseudo = true,
		callback = function(PlayerData)
			--			print('updating Rotom level to', n)
			if PlayerData:getRotomEventLevel() ~= n-1 then return false end
			--			print('success')
			PlayerData:setRotomEventLevel(n)
		end
	}
end

local trusted = true
local manualOnly = false
return { -- todo: write something that checks matches between this list and the index list used by PDS:[de/]serialize
	MeetJake = trusted,
	MeetParents = trusted,
	ChooseFirstPokemon = function(PlayerData, name)
		if type(name) ~= 'string' then return false end
		local g, f, w = 'Grass', 'Fire', 'Water'
		local types = {
			Bulbasaur = g, Charmander = f, Squirtle = w,
			Chikorita = g, Cyndaquil  = f, Totodile = w,
			Treecko   = g, Torchic    = f, Mudkip   = w,
			Turtwig   = g, Chimchar   = f, Piplup   = w,
			Snivy     = g, Tepig      = f, Oshawott = w,
			Chespin   = g, Fennekin   = f, Froakie  = w,
			Rowlet    = g, Litten     = f, Popplio  = w,
			Grookey   = g, Scorbunny  = f, Sobble   = w,
			Sprigatito = g, Fuecoco    = f, Quaxly   = w,

		}
		local pType = types[name]
		if not pType then return false end
		local starter = PlayerData:newPokemon {
			name = name,
			level = 5,
			shinyChance = 2048,
			untradable = true,
		}
		PlayerData.party[1] = starter
		PlayerData:onOwnPokemon(starter.num)
		PlayerData.starterType = pType
		--		return PlayerData:createDecision {
		--			callback = function(_, nickname)
		--				if type(nickname) ~= 'string' then return end
		--				starter:giveNickname(nickname)
		--			end
		--		}
	end,
	JakeBattle1 = manualOnly,
	PCPorygonEncountered = manualOnly,
	ParentsKidnappedScene = trusted,
	BronzeBrickStolen = function(PlayerData)
		PlayerData:incrementBagItem('bronzebrick', -1)
	end,
	JakeTracksLinda = trusted,
	BronzeBrickRecovered = {
		manual = true,
		callback = function(PlayerData)
			PlayerData:addBagItems({id = 'bronzebrick', quantity = 1})
		end
	},
	IntroducedToGym1 = trusted,
	GivenSawsbuckCoffee = function(PlayerData)
		PlayerData:addBagItems({id = 'sawsbuckcoffee', quantity = 1})
	end,
	ReceivedRTD = function(PlayerData)
		if not PlayerData.badges[1] then return false end -- todo: kick people who arrive in subcontexts without this event
	end,
	GetCut = --[[{
		pseudo = true,
		callback =]] function(PlayerData)
		--			if not PlayerData.badges[1] then return false end
		PlayerData:obtainTM(1, true)
	end,
	--	},

	GetSurf = --[[{
		pseudo = true,
		callback =]] function(PlayerData)
		--			if not PlayerData.badges[1] then return false end
		PlayerData:obtainTM(3, true)
	end,
	--	},
	EeveeAwarded = manualOnly, -- no longer completable
	RunningShoesGiven = trusted,
	GroudonScene = manualOnly,

	JakeBattle2 = manualOnly,
	TalkToJakeAndSebastian = trusted,
	IntroToUMV = trusted,
	TestDriveUMV = function(PlayerData)
		return PlayerData:diveInternal()

	end,
	ReceivedBWEgg = function(PlayerData, choice)
		if #PlayerData.party >= 6 then return false end
		table.insert(PlayerData.party, PlayerData:newPokemon {
			name = (choice==1) and 'Seviper' or 'Zangoose',
			egg = true,
			shinyChance = 4096,
		})
		return true -- needed? does client use?
	end,

	ReceivedLottoDitto = function(PlayerData)
		if not game:GetService('MarketplaceService'):PlayerOwnsAsset(PlayerData.player, 3365010965) then 
			return 'no'
		end
		if #PlayerData.party >= 6 then return false end

		table.insert(PlayerData.party, PlayerData:newPokemon {
			name = 'Ditto',
			shinyChance = 4096,
			item = 'destinyknot'
		})
		return true 
	end,

	DamBusted = manualOnly,
	GetOldRod = {
		pseudo = true,
		callback = function(PlayerData)
			if not PlayerData.completedEvents.DamBusted then return false end
			PlayerData:addBagItems({id = 'oldrod', quantity = 1})
		end
	},
	JakeStartFollow = trusted,
	JakeEndFollow = trusted,
	GivenSnover = manualOnly, -- no longer completable
	KingsRockGiven = function(PlayerData)
		PlayerData:addBagItems({id = 'kingsrock', quantity = 1})
	end,

	GetGoodRod = {
		pseudo = true,
		callback = function(PlayerData)
			if not PlayerData.completedEvents.DamBusted then return false end
			PlayerData:addBagItems({id = 'goodrod', quantity = 1})--good rod attempt
		end
	},

	RosecoveWelcome = trusted,
	LighthouseScene = {
		manual = true,
		callback = function(PlayerData)
			PlayerData:addBagItems({id = 'protector', quantity = 1})
		end
	},
	ProfAfterGym3 = trusted,
	JakeAndTessDepart = trusted,
	RotomBit0 = {manual = true, server = true},
	RotomBit1 = {manual = true, server = true},
	RotomBit2 = {manual = true, server = true},
	Rotom1 = RotomEvent(1), Rotom2 = RotomEvent(2), Rotom3 = RotomEvent(3),
	Rotom4 = RotomEvent(4), Rotom5 = RotomEvent(5), Rotom6 = RotomEvent(6),
	Rotom7 = {
		manual = true,
		pseudo = function(PlayerData) return PlayerData:getRotomEventLevel() == 7 end,
		callback = function(PlayerData)
			if PlayerData:getRotomEventLevel() ~= 6 then return false end
			PlayerData:setRotomEventLevel(7)
		end
	},
	JTBattlesR9 = manualOnly,
	GivenLeftovers = function(PlayerData)
		PlayerData:addBagItems({id = 'leftovers', quantity = 1})
	end,
	Jirachi = manualOnly,
	MeetAbsol = trusted,
	ReachCliffPC = trusted,
	BlimpwJT = trusted,
	MeetGerald = trusted,
	G4FoundTape = trusted,
	G4GaveTape = trusted,
	G4FoundWrench = trusted,
	G4GaveWrench = trusted,
	G4FoundHammer = trusted,
	G4GaveHammer = trusted, -- prereq for battle?
	SeeTEship = trusted,
	GeraldKey = function(PlayerData)
		if not PlayerData.badges[4] then return false end
		PlayerData:addBagItems({id = 'basementkey', quantity = 1})
	end,
	TessStartFollow = trusted,
	TessEndFollow = trusted,
	GetAbsol = {
		pseudo = true,
		callback = function(PlayerData)
			if PlayerData.flags.gotAbsol or PlayerData.completedEvents.EnteredPast then return end
			PlayerData.flags.gotAbsol = true
			PlayerData:addBagItems({id = 'megakeystone', quantity = 1})
			if #PlayerData.party < 6 then
				PlayerData:giveStoryAbsol()
			else
				return PlayerData:createDecision {
					callback = function(_, slot)
						if type(slot) ~= 'number' then return false end
						slot = math.floor(slot)
						if not PlayerData.party[slot] then return false end
						PlayerData:giveStoryAbsol(slot)
					end
				}
			end
		end
	},
	DefeatTEinAC = {
		manual = true,
		callback = function(PlayerData)
			PlayerData:addBagItems({id = 'skytrainpass', quantity = 1})
			PlayerData:obtainTM(2, true)
		end
	},
	EnteredPast = {
		manual = true,
		callback = function(PlayerData)
			PlayerData.absolMeta = nil -- lock in the given Absol
			PlayerData:addBagItems({id = 'corekey', quantity = 1})
		end
	},
	-- Christmas 2016 Event (no longer completable)
	LearnAboutSanta = manualOnly,--trusted,
	BeatSanta = manualOnly,
	NiceListReward = manualOnly,-- [[

	function(PlayerData, choice)
		if not PlayerData.completedEvents.BeatSanta then return false end
		local pokemon = PlayerData:newPokemon {
			name = (choice==1) and 'Sandshrew' or 'Vulpix',
			shinyChance = 4096,
			forme = 'Alola',
			level = 20
		}
		local box = PlayerData:caughtPokemon(pokemon)
		if box then
			return pokemon:getName() .. ' was transferred to Box ' .. box .. '!'
		end
	end,
	--]]
	--
--[[	
	LearnAboutBob2 = manualOnly,
	BeatBob2 = manualOnly,
	
	NiceListReward2 = manualOnly, 
	function(PlayerData, choice)
		if not PlayerData.completedEvents.BeatBob2 then return false end
		local pokemon = PlayerData:newPokemon {
			name = (choice==1) and 'Carvanha' or 'Audino' or 'Axew',
			level = 25
		}
		local box = PlayerData:caughtPokemon(pokemon)
		if box then
			return pokemon:getName() .. ' was transferred to Box ' .. box .. '!'
		end
	end,
	--]]
	--

	G5Shovel = manualOnly,
	G5Pickaxe = manualOnly,
	Shaymin = manualOnly,
	RJO = manualOnly,
	RJP = function(PlayerData) if not PlayerData.completedEvents.RJO then return false end end,
	GJO = function(PlayerData) if not PlayerData.completedEvents.RJP then return false end end,
	GJP = function(PlayerData) if not PlayerData.completedEvents.GJO then return false end end,
	PJO = function(PlayerData) if not PlayerData.completedEvents.GJP then return false end end,
	PJP = function(PlayerData) if not PlayerData.completedEvents.PJO then return false end end,
	BJO = manualOnly,--function(PlayerData) if not PlayerData.completedEvents.PJP then return false end end,
	BJP = function(PlayerData) if not PlayerData.completedEvents.BJO then return false end end,
	Victini = manualOnly,
	TEinCastle = manualOnly,
	Snorlax = manualOnly,
	GiveEkans = manualOnly,
	vAredia = function(PlayerData)
		if not PlayerData.badges[4] or not (PlayerData:getBagDataById('skytrainpass', 5)) then return false end
	end,
	gsEkans = manualOnly, -- gave shiny Ekans
	RNatureForces = function(PlayerData)
		if not PlayerData.badges[5] then return false end
	end,
	Landorus = manualOnly,
	Heatran = manualOnly,
	OpenJDoor = function(PlayerData) if not PlayerData.flags.hasjkey then return false end end,
	Diancie = manualOnly,
	FluoDebriefing = function(PlayerData)
		if not PlayerData.badges[6] then return false end
		PlayerData:obtainTM(8, true)
	end,
	vFluoruma = function(PlayerData)
		if not PlayerData.badges[5] then return false end
	end,
	TERt14 = manualOnly,
	RBeastTrio = function(PlayerData)
		if not PlayerData.badges[6] then return false end
	end,
	vCrescentIsland = function(PlayerData)
		if not PlayerData.badges[7] then return false end
	end,
	PBSIntro = function(PlayerData)
		PlayerData:addBagItems({id = 'stampcase', quantity = 1})
		PlayerData.stampSpins = PlayerData.stampSpins + 3
	end,
	hasHoverboard = manualOnly,
	vVictoryRoad = manualOnly,
	BeatTessFrost = manualOnly,
	vFrostveil = manualOnly,
	FrostveilDepart = manualOnly,



	vPortDecca = manualOnly,
	EnteredDecca2 = trusted,
	FinishedDeccaScene = manualOnly,
	DepartDeccaBeach = manualOnly,

	Meowth = function(PlayerData)
		local meowth = PlayerData:newPokemon {
			name = 'Meowth',
			isGift = true,
			level = 25,
		}
		local box = PlayerData:caughtPokemon(meowth)
		if box then
			return 'Meowth was transferred to Box ' .. box .. '!'
		end
	end,

	Glameow = function(PlayerData)
		local glameow = PlayerData:newPokemon {
			name = 'Glameow',
			isGift = true,
			level = 25,
		}
		local box = PlayerData:caughtPokemon(glameow)
		if box then
			return 'Glameow was transferred to Box ' .. box .. '!'
		end
	end,

	Purrloin = function(PlayerData)
		local purrloin= PlayerData:newPokemon {
			name = 'Purrloin',
			isGift = true,
			level = 25,
		}
		local box = PlayerData:caughtPokemon(purrloin)
		if box then
			return 'Purrloin was transferred to Box ' .. box .. '!'
		end
	end,

	LatiosAndLatias = trusted,

	Eevee2Awarded = function(PlayerData)
		local eevee = PlayerData:newPokemon {
			name = 'Eevee',
			level = 5,
			shinyChance = 4096,
		}
		local box = PlayerData:caughtPokemon(eevee)
		if box then
			return 'Eevee was transferred to Box ' .. box .. '!'
		end
	end,

	CaughtMarshadow = trusted,
	GivenZPouch = trusted,

	FindZGrass = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		PlayerData:addBagItems({id = 'grassiumz', quantity = 1})
	end,
	FindZFire = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		PlayerData:addBagItems({id = 'firiumz', quantity = 1})
	end,
	FindZWater = function(PlayerData)
		if not PlayerData.completedEvents.GivenZPouch then return false end
		PlayerData:addBagItems({id = 'wateriumz', quantity = 1})
	end,

	kevSBell = function(PlayerData)
		if not PlayerData.badges[7] then return false end
		PlayerData:addBagItems({id = 'soothebell', quantity = 1})
	end,


	vDecca = function(PlayerData)
		if not PlayerData.badges[7] then return false end
	end,



	meetSSam = function(PlayerData)
		if not PlayerData.badges[7] then return false end
	end,

	DeccaBeachScene = trusted,


	VolItem1 = manualOnly,
	VolItem2 = manualOnly,
	VolItem3 = manualOnly,
	RevealSteamChamber = manualOnly,
	Volcanion = function(PlayerData)
		if not PlayerData.completedEvents.RevealSteamChamber then return false end
	end,


	PushBarrels = function(PlayerData)
		if not PlayerData.completedEvents.EnteredDecca2 and PlayerData:getHeadbutter() then return false end
	end,
	UnlockMewLab = "EnteredDecca2",
	Mew = "UnlockMewLab",

	DefeatTinbell = function(PlayerData)
		if not PlayerData.completedEvents.BeatTessFrost then return false end
		local pokemon = PlayerData:newPokemon {
			name = 'Tyrogue',
			level = 5,
		}
		for i = 1, 6 do
			if not PlayerData.party[i] then
				PlayerData.party[i] = pokemon
				return
			end
		end
		local box = PlayerData:caughtPokemon(pokemon)
		if box then
			return box
		end
	end,

	MeetTessBeach = "EnteredDecca2",

	RevealCatacombs = function(PlayerData)
		if not PlayerData.completedEvents.vFrostveil or not PlayerData.flags.RevealCatacombs then return false end
	end,
	LightPuzzle = "RevealCatacombs",
	SmashRockDoor = "LightPuzzle",

	CompletedCatacombs = "SmashRockDoor",
	Regirock = "CompletedCatacombs",
	Registeel = "CompletedCatacombs",
	Regice = "CompletedCatacombs",


	OpenRDoor = {
		DependsOn = "FluoDebriefing",
		callback = function(PlayerData)
			if not PlayerData.flags.has3regis then return false end
		end
	},
	Regigigas = "OpenRDoor",



	SwordsOJ = "vFrostveil",
	Keldeo = function(PlayerData)
		if not PlayerData.flags.hasSwordsOJ and PlayerData.completedEvents.SwordsOJ then return false end
	end,


	MeetFisherman = "vCrescentIsland",

	EclipseBaseReveal = "MeetFisherman",

	ExposeSecurity = manualOnly,
	PressSecurityButton = "ExposeSecurity",
	FindCardKey = function(PlayerData)
		if not PlayerData.completedEvents.PressSecurityButton then return false end
		PlayerData:addBagItems({id = 'cardkey', quantity = 1})
	end,
	UnlockGenDoor = "FindCardKey",
	Genesect = function(PlayerData)
		if not PlayerData.completedEvents.UnlockGenDoor then return false end
	end,
	burndrive = function(PlayerData)
		if not PlayerData.completedEvents.UnlockGenDoor then return false end
		PlayerData:addBagItems({id = 'burndrive', quantity = 1})
	end,
	dousedrive = function(PlayerData)
		if not PlayerData.completedEvents.UnlockGenDoor then return false end
		PlayerData:addBagItems({id = 'dousedrive', quantity = 1})
	end,
	chilldrive = function(PlayerData)
		if not PlayerData.completedEvents.UnlockGenDoor then return false end
		PlayerData:addBagItems({id = 'chilldrive', quantity = 1})
	end,
	shockdrive = function(PlayerData)
		if not PlayerData.completedEvents.UnlockGenDoor then return false end
		PlayerData:addBagItems({id = 'shockdrive', quantity = 1})
	end,
	ParentalSightings = "PressSecurityButton",
	DefeatEclipseBase = "ParentalSightings",
	OpenEclipseGate = "DefeatEclipseBase",

	--getDeccaDests = manualOnly,


	SebastianRebattle = {
		pseudo = true,
		callback = function(PlayerData)
			if not PlayerData.badges[8] then return false end
			PlayerData:addBagItems({id = 'redorb', quantity = 1})
			return true
		end
	},

--[[
Groudon = {
    DependsOn = "SebastianRebattle",
    callback = function(PlayerData)
        return PlayerData.completedEvents.Groudon == true
    end
},
--]]
	--old
	-- actually we might need this, because if the player tosses the red orb from their bag, they won't be able to fight groudon...
	-- [[
	Groudon = {
		DependsOn = "SebastianRebattle",
		callback = function(PlayerData)
			if not PlayerData:getBagDataById('redorb', 1) then return false end
			return true
		end
	},
	--]]

	getGSBall = {
		callback = function(PlayerData)
			PlayerData:addBagItems({id = 'gsball', quantity = 1})
			return true
		end
	},

ZeldaSword = "MeetTessBeach",


	-- TODO: BEFORE ADDING, MAKE SERIALIZE CHECKER
	ReceivedPikachuCode = function(PlayerData)
		print("Executing ReceivedPikachuCode event")
		local pikachu = PlayerData:newPokemon {
			name = 'Pikachu',
			level = 5,
			shinyChance = 4096,
			moves = {
				{id = 'thundershock'},
				{id = 'quickattack'},
				{id = 'thunderwave'},
				{id = 'growl'}
			},
			item = 'lightball',
			ot = "Promo Code"
		}

		local result
		if #PlayerData.party < 6 then
			table.insert(PlayerData.party, pikachu)
			print("Added Pikachu to party")
			result = true
		else
			-- Allow overflow to ensure the Pikachu is stored even if all normal boxes are full
			local box = PlayerData:PC_sendToStore(pikachu, true)
			if box then
				print("Sent Pikachu to PC box", box)
				result = true
			else
				print("Failed to store Pikachu")
				result = false
			end
		end

		return result
	end,

	ReceivedMoneyCode = function(PlayerData)
		print("Executing ReceivedMoneyCode event")
		-- Check if player has the 1st gym badge
		if PlayerData.badges[1] then
			PlayerData:addMoney(10000)
			print("Added $10,000 to player's account")
			return true
		else
			print("Code denied, player does not have the 1st gym badge")
			return false
		end
	end,
	
	ReceivedMoneyCode2 = function(PlayerData)
		print("Executing ReceivedMoneyCode event")
		-- Check if player has the 1st gym badge
		if PlayerData.badges[1] then
			PlayerData:addMoney(20000)
			print("Added $20,000 to player's account")
			return true
		else
			print("Code denied, player does not have the 1st gym badge")
			return false
		end
	end,
	
	ReceivedMoneyCode3 = function(PlayerData)
		print("Executing ReceivedMoneyCode3 event")
		-- Check if player has the 1st gym badge
		if PlayerData.badges[1] then
			PlayerData:addMoney(10000)
			print("Added $10,000 to player's account")
			return true
		else
			print("Code denied, player does not have the 1st gym badge")
			return false
		end
	end,
	

	ReceivedJune2025Code = function(PlayerData)
		print("Executing ReceivedJune2025Code event")
		PlayerData:addBagItems({id = 'ultraball', quantity = 15})
		PlayerData:addBagItems({id = 'maxpotion', quantity = 10})
		PlayerData:addBagItems({id = 'maxrevive', quantity = 10})
		PlayerData:addBagItems({id = 'fullrestore', quantity = 5})
		PlayerData:addBagItems({id = 'rarecandy', quantity = 30})
		PlayerData:addBagItems({id = 'leftovers', quantity = 3})
		print("Added 15 Ultra Balls, 10 Max Potions, 10 Max Revives, 5 Full Restores, 30 Rare Candies, and 3 Leftovers to player's inventory")
		return true
	end,

	ReceivedJuly2025Code = function(PlayerData)
		print("Executing ReceivedJuly2025Code event")
		PlayerData:addBagItems({id = 'ultraball', quantity = 10})
		PlayerData:addBagItems({id = 'quickball', quantity = 10})
		PlayerData:addBagItems({id = 'duskball', quantity = 5})
		PlayerData:addBagItems({id = 'maxpotion', quantity = 5})
		PlayerData:addBagItems({id = 'fullrestore', quantity = 5})
		PlayerData:addBagItems({id = 'rarecandy', quantity = 20})
		PlayerData:addBagItems({id = 'leftovers', quantity = 1})
		PlayerData:addBagItems({id = 'choiceband', quantity = 1})
		PlayerData:addBagItems({id = 'kingrock', quantity = 1})
		PlayerData:addBagItems({id = 'dragonfang', quantity = 1})
		PlayerData:addBagItems({id = 'waterstone', quantity = 1})
		PlayerData:addBagItems({id = 'firestone', quantity = 1})
		PlayerData:addBagItems({id = 'thunderstone', quantity = 1})
		print("Added mixed promo rewards: Ultra Balls, Quick Balls, Dusk Balls, Max Potions, Full Restores, Rare Candies, Leftovers, Choice Band, King's Rock, Dragon Fang, Water Stone, Fire Stone, and Thunder Stone to player's inventory")
		return true
	end,


	ReceivedWelcomeCode = function(PlayerData)
		print("Executing ReceivedWelcomeCode event")
		PlayerData:addBagItems({id = 'ultraball', quantity = 10})
		PlayerData:addBagItems({id = 'superpotion', quantity = 10})
		PlayerData:addBagItems({id = 'maxrevive', quantity = 10})
		PlayerData:addBagItems({id = 'antidote', quantity = 5})
		PlayerData:addBagItems({id = 'paralyzeheal', quantity = 5})
		PlayerData:addBagItems({id = 'rarecandy', quantity = 20})
		PlayerData:addBagItems({id = 'leftovers', quantity = 2})
		print("Added 10 Ultra Balls, 10 Super Potions, 10 max revives, 5 antidotes, 5 paralyze heals, 5 rare candies, and 2 Leftovers to player's inventory")
		return true
	end,

	ReceivedDiscord10KCode = function(PlayerData)
		print("Executing ReceivedDiscord10KCode event")
		PlayerData:addBagItems({id = 'masterball', quantity = 5})
		print("Added 5 masterballs to player's inventory")
		return true
	end,
	
	ReceivedDiscord12KCode = function(PlayerData)
		print("Executing ReceivedDiscord12KCode event")
		PlayerData:addBagItems({id = 'masterball', quantity = 10})
		print("Added 10 masterballs to player's inventory")
		return true
	end,

	-- Promo code expiration dates
	PromoCodeExpiration = {
		PBBJULY2025 = {
			year = 2025,
			month = 7,
			day = 31,
			hour = 23,
			minute = 59
		},
		PBBJUNE2025 = {
			year = 2025,
			month = 6,
			day = 30,
			hour = 23,
			minute = 59
		},
		PBBMAY2025 = {
			year = 2025,
			month = 5,
			day = 31,
			hour = 23,
			minute = 59
		},
		MONEY = {
			year = 2025,
			month = 5,
			day = 31,
			hour = 23,
			minute = 59
		},
		MONEY2 = {
			year = 2025,
			month = 7,
			day = 31,
			hour = 23,
			minute = 59
		},
		MONEY3 = {
			year = 2025,
			month = 12,
			day = 31,
			hour = 23,
			minute = 59
		},
		DISCORD10K = {
			year = 2025,
			month = 5,
			day = 31,
			hour = 23,
		},
		DISCORD12K = {
			year = 2025,
			month = 7,
			day = 31,
			hour = 23,
		}
	},


	-- Promo code events
	PromoCode_PBBJULY2025 = true,
	PromoCode_PBBJUNE2025 = true,
	PromoCode_PBBMAY2025 = true,
	PromoCode_MONEY = true,
	PromoCode_MONEY2 = true,
	PromoCode_MONEY3 = true,
	PromoCode_DISCORD10K = true,
	PromoCode_DISCORD12K = true,


	-- Victory Road gate keeper battle
	DefeatLuther = trusted,
	
	EonDuo = "TERt14",


}