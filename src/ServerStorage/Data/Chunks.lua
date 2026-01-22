print("Chunks")

--NEW AUDIO ID LIST AS OF 5/1/2022 DUE TO ROBLOX NOT ALLOWING AUDIOS ANYMORE
--LOST ISLAND 1838607262
--MITIS TOWN 1839954103
--ROUTE 1 1842717979
--CHESHMA TOWN 1836974732
-- GALE FOREST 1837134419
-- ROUTE 2 1842717979
--ROUTE 3 1842717979
--SILVENT CITY 1836732864
--GYM 1 1838659275
--ROUTE 4 1842717979
--ROUTE 5 9048703705
--BRIMBER CITY 1835846014
--GYM 2 9045937895
--ROUTE 6 9048703705
--IGNEUS VOLCANO 1843379879
--ROUTE 7 1845528664
--LAGOONA LAKE 9040399248
--UMV 9040393808
--ROUTE 8 1845528664
--ROSECOVE BEACH 1835514584
--ROSECOVE CITY 9044425606
--ROSECOVE GYM 1842976322
--ROUTE 9 1837818772
--GROVE OF DREAMS 9038716393
--MANOR 1838645170
--ROUTE 10 1844714240
--CRAGONOS CAVE 1843284983
--CRAGONOS PEAK 1845233174
--CRAGONOS CLIFFS 1845233174
--ANTHIAN CITY 
local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework'))

local kmanVolume = 1
local routeMusicVolume = kmanVolume
--dont use kmanvolume or routemusicvolume anymore
--as music volumes are different volumes...

local uid = require(game:GetService('ServerStorage').Utilities).uid

local encounterLists = {}
local function EncounterList(list)
	local isMetadata = false
	-- check a random key, if it is not a number then this is metadata
	for i in pairs(list) do if type(i) ~= 'number' then isMetadata = true end break end
	if isMetadata then
		return function(actualList)
			local eld = EncounterList(actualList)
			local t = encounterLists[eld.id]
			for k, v in pairs(list) do
				t[k] = v
			end
			return eld
		end
	end
	-- modify lists here (e.g. for a new version of October2k16's Haunter event)
	local id = uid()--#encounterLists + 1 -- prefer uid, because it prevents guessing and makes every server unique
	while encounterLists[id] do id = uid() end
	encounterLists[id] = {id = id, list = list}
	local levelDistributionDay   = {}
	local levelDistributionNight = {}
	for _, entry in pairs(list) do
		-- day
		if entry[5] ~= 'night' then
			local chancePerLevel = entry[4] / (entry[3] - entry[2] + 1)
			for level = entry[2], entry[3] do
				levelDistributionDay  [level] = (levelDistributionDay  [level] or 0) + chancePerLevel
			end
		end
		-- night
		if entry[5] ~= 'day' then
			local chancePerLevel = entry[4] / (entry[3] - entry[2] + 1)
			for level = entry[2], entry[3] do
				levelDistributionNight[level] = (levelDistributionNight[level] or 0) + chancePerLevel
			end
		end
	end
	local function convert(t)
		local new = {}
		for level, chance in pairs(t) do
			new[#new+1] = {level, chance}
		end
		return new
	end
	return {
		id = id,
		ld = {convert(levelDistributionDay),
			convert(levelDistributionNight)}
	}
end

local function ConstantLevelList(list, level)
	for _, entry in pairs(list) do
		entry[5] = entry[3] -- [5] day / night
		entry[4] = entry[2] -- [4] chance
		entry[2] = level    -- [2] min level
		entry[3] = level    -- [3] max level
	end
	return EncounterList(list)
end

local function OldRodList(list)
	local ed = ConstantLevelList(list, 10)
	encounterLists[ed.id].rod = 'old'
	return ed
end

local function GoodRodList(list)
	local ed = ConstantLevelList(list, 20)
	encounterLists[ed.id].rod = 'good'
	return ed
end

local ruinsEncounter = EncounterList {
	{'Baltoy',   29, 32, 25, nil, false, nil, {chance=20,item='lightclay'}},
	{'Natu',     29, 32, 20},
	{'Elgyem',   29, 32, 20},
	{'Sigilyph', 29, 32, 10},
	{'Ekans',    29, 32,  8},
	{'Darumaka', 29, 32,  4},
	{'Zorua',    29, 32,  2},
}

local chunks = {
	['chunk1'] = {
		buildings = {
			'Gate1',
		},
		regions = {
			['Mitis Town'] = {
				SignColor = BrickColor.new('Bronze').Color,
				Music = {9536618275, 12640262632},--{424128050, 424129359},--288894671,
				MusicVolume = 0.7,
				OldRod = OldRodList {
					{'Magikarp', 100},
				},
				GoodRod = GoodRodList {
					{'Magikarp', 50},
					{'Gyarados', 5},
				},
			},
			['Route 1'] = {
				Music = 9536626006, --424131884,--301381728,
				MusicVolume = kmanVolume,
				Grass = EncounterList {
					{'Pidgey',     2, 4, 25},
					{'Zigzagoon',  2, 4, 20, nil, false, nil, {chance=60,item='potion'}},
					{'Zigzagoon',  2, 4, 20, nil, false, nil, {chance=20,item='revive'}},
					{'Bunnelby', 2, 4, 11},
					{'Fletchling',   2, 4, 24},
					{'Wurmple',    2, 4, 11, nil, false, nil, {chance=60,item='pechaberry'}},
					{'Wurmple',    2, 4, 11, nil, false, nil, {chance=20,item='brightpowder'}},
					{'Sentret',    2, 4,  5, 'day'},
				},
			},
		},
	},
	['chunk2'] = {
		buildings = {
			['PokeCenter'] = {
				NPCs = {
					{
						appearance = 'Camper',
						cframe = CFrame.new(10, 0, 0),
						interact = { 'See that girl over there behind the counter?', 'She heals your pokemon.' }
					},
				},
			},
			'Gate1',
			'Gate2',
			['SawsbuckCoffee'] = {
				DoorViewAngle = 15,
			},
		},
		regions = {
			['Cheshma Town'] = {
				SignColor = BrickColor.new('Deep blue').Color,
				Music = 12191925019, --296982245, --do this
				MusicVolume = 1.4,
			},
			['Gale Forest'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = {12639734157, 12191927300},--288893686,
				MusicVolume = 0.8,
				BattleScene = 'Forest1',
				IsDark = true,
				Grass = EncounterList {
					{'Caterpie',   3, 5, 20},
					{'Metapod',    5, 6, 10},
					{'Kakuna',     5, 6, 10},
					{'Weedle',     5, 6, 10},
					{'Wurmple',     5, 6, 10, nil, false, nil, {chance=20,item='brightpowder'}},
					{'Wurmple',     5, 6, 10, nil, false, nil, {chance=60,item='pechaberry'}},
					{'Nidoran[F]', 3, 5, 10},
					{'Nidoran[M]', 3, 5, 10},
					{'Ledyba',     3, 5, 15, 'day'},
					{'Spinarak',   3, 5, 15, 'night'},
					{'Hoothoot',   4, 6, 10, 'night'},
					{'Pikachu',    4, 6,  3, nil, false, nil, {chance=20,item='lightball'}},
				},
			},
			['Route 2'] = {
				RTDDisabled = true,
				Music = 9536629006, --424133191,--301381862,
				MusicVolume = 1.2,
				BattleScene = 'Rt2',
				Grass = EncounterList {
					{'Pidgey',     4, 6, 10},
					{'Fletchling', 4, 6, 10},
					{'Zigzagoon',   4, 6,  8, nil, false, nil, {chance=60,item='potion'}},
					{'Zigzagoon',   4, 6,  8, nil, false, nil, {chance=20,item='revive'}},
					{'Plusle',     4, 6,  2, nil, false, nil, {chance=20,item='cellbattery'}},
					{'Minun',      4, 6,  2, nil, false, nil, {chance=20,item='cellbattery'}},
				},
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Feebas', 50},
					{'Barboach', 15},				
				},			
				GoodRod = GoodRodList {
					{'Barboach', 50},
					{'Magikarp', 20},
					{'Gyarados', 5},
					{'Whiscash', 5},
				},
				Surf = EncounterList { 
					{'Goldeen', 13, 18, 40, nil, false, nil, {chance=20,item='mysticwater'}},
					{'Magikarp', 13, 18, 20},
					{'Barboach', 13, 18, 20},
					{'Lotad', 13, 18, 20, nil, false, nil, {chance=20,item='mentalherb'}},
				}
			},
		},
	},
	chunk3 = {
		buildings = {
			['C_chunk64'] = {
				--				DoorViewAngle = 25,
				DoorViewZoom = 14,
			},
			['Gym1'] = {
				Music = {101702776568554, 86301219955611}, --do this
				MusicVolume = 0.4,
				BattleScene = 'Gym1',
			},
			['PokeCenter'] = {
				NPCs = {
					{
						appearance = 'Rich Boy',
						cframe = CFrame.new(-23, 0, 8) * CFrame.Angles(0, -math.pi/3, 0),
						interact = { 'This PC has been acting awfully strange lately.', 'I think it needs an upgrade...' }
					},
				},
			},
			'Gate2',
			'Gate3',
		},
		regions = {
			['Route 3'] = {
				blackOutTo = 'chunk2',
				Music = 9536629006, --424133191,--301381862,
				MusicVolume = 1.2,
				BattleScene = 'Rt3',
				Grass = EncounterList {
					{'Kricketot', 5, 7, 20},
					{'Budew', 5, 7, 20},
					{'Poochyena', 5, 7, 20},
					{'Shinx',     5, 7, 20},
					{'Electrike', 5, 7, 20},
					{'Mareep',    5, 7, 20},
					{'Nincada',   5, 7, 10, nil, false, nil, {chance=20,item='softsand'}},
					{'Abra',      5, 7, 10, nil, false, nil, {chance=20,item='twistedspoon'}},--I FIXED THE SPRITE :D!!...
					{'Pachirisu', 6, 8,  4},
				}
			},
			['Silvent City'] = {
				Music = {9542461086},--456109734, 456110519, --do this
				MusicVolume = 1,
				SignColor = BrickColor.new('Bright yellow').Color,
				PCEncounter = EncounterList {PDEvent = 'PCPorygonEncountered'} {{'Porygon', 5, 5, 1}}
			},
			['Route 4'] = {
				RTDDisabled = true,
				Music = 9536629006, --424133191,--301381862,
				MusicVolume = 1.2,
				BattleScene = 'Rt4',
				Grass = EncounterList {
					{'Pidgey', 7,  9, 25},
					{'Shinx',  7,  9, 20},
					{'Mareep', 7,  9, 20},
					{'Stunky', 7,  9, 15},
					{'Skiddo', 7, 10, 10},
					{'Marill', 7, 10, 10},
				}
			},
		},
	},
	['chunk4'] = {
		blackOutTo = 'chunk3',
		buildings = {
			'Gate3',
			'Gate4',
		},
		regions = {
			['Route 5'] = {
				RTDDisabled = true,
				Music = 9536630269, --497198084,--301381959,
				MusicVolume = .6,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Patrat',     8, 10, 25},
					{'Phanpy',     8, 10, 20},
					{'Blitzle',    8, 10, 20},
					{'Litleo',     8, 10, 20},
					{'Hippopotas', 8, 10, 15},
					{'Girafarig',  9, 11,  5},
				}
			},
			['Old Graveyard'] = {
				Music = 9537325849, --602841375,
				RTDDisabled = true,
				SignColor = Color3.new(.5, .5, .5),
				BattleScene = 'Graveyard',
				GrassEncounterChance = 9,
				Grass = EncounterList {
					{'Cubone',  8, 10, 40, nil, false, nil, {chance=20,item='thickclub'}},
					{'Gothita', 8, 10, 15},
					{'Gastly',  8, 10, 30, 'night'},
					{'Murkrow', 8, 10, 20, 'night'},
					{'Yamask',  8, 10,  5, 'night', false, nil, {chance=20,item='spelltag'}},
				}
			},
		},
	},
	['chunk5'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate4', 'Gate5', 'Gate6',
			'PokeCenter',
			['Gym2'] = {
				Music = 9543918401, --317836326,
				BattleScene = 'Gym2',
			},
		},
		regions = {
			['Brimber City'] = {
				Music = 9536663179, --316929443,--527347414,
				SignColor = BrickColor.new('Crimson').Color,
				BattleScene = 'Safari', -- for Santa, if nothing else
			}
		},
	},
	['chunk6'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate5',
		},
		regions = {
			['Route 6'] = {
				Music = 9536630269, --497198084,--301381959,
				MusicVolume = .8,
				BattleScene = 'Safari',
				Grass = EncounterList {
					{'Litleo',  9, 11, 20},
					{'Blitzle', 9, 11, 20},
					{'Ponyta',  9, 11, 15},
					{'Rhyhorn', 9, 11, 10},
					{'Zubat',   9, 11, 30, 'night'},
				},
				Anthill = EncounterList {Locked = true} {{'Durant', 5, 8, 1}}
			}
		}
	},
	['chunk7'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Mt. Igneus'] = {
				Music = 9537474749, --317351319,--497197006,
				MusicVolume = .8,
				SignColor = BrickColor.new('Cocoa').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Numel',   9, 11, 20},
					{'Nosepass',   9, 11, 20},
					{'Slugma',  9, 11, 20},
					{'Torkoal', 9, 11, 17, nil, false, nil, {chance=20,item='charcoal'}},
					{'Heatmor', 9, 11, 5},
					{'Magby', 9, 11, 5, nil, false, nil, {chance=20,item='magmarizer'}},
					{'Zubat',   9, 11, 30, 'day'},
				},
				Groudon = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.SebastianRebattle then return false end
					return true
				end}
				{{'Groudon', 60, 60, 1}}
			}
		}
	},

	['chunk8'] = {
		blackOutTo = 'chunk5',
		buildings = {
			'Gate6',
			'Gate7',
			['SawMill'] = {
				BattleScene = 'SawMill',
			},
		},
		regions = {
			['Route 7'] = {
				Music = {9537284231, 12640251718},--469639805,
				MusicVolume = .8,
				RTDDisabled = true,
				Grass = EncounterList {
					--[[
					{'Medicham',  12, 14, 20},
					{'Ditto',  12, 14, 20},
					{'Aegislash',  12, 14, 20},
					{'Abra',  12, 14, 20},
					{'Mammoswine',  12, 14, 20},
					{'Kyogre',  12, 14, 20},
					{'Shinx',  12, 14, 20},
					{'Shroomish',  12, 14, 20},
					{'Tympole',  12, 14, 20},
					{'Glaceon',  12, 14, 20},
					{'Porygon',  12, 14, 20},
					{'Porygon-Z',  12, 14, 20},
					{'Porygon2',  12, 14, 20},
					{'Munchlax',  12, 14, 20},
					{'Zapdos',  12, 14, 20},
					{'Articuno',  12, 14, 20},
					{'Chikorita',  12, 14, 20},
					{'Totodile',  12, 14, 20},
					{'Suicune',  12, 14, 20},
					{'Entei',  12, 14, 20},
					{'Celebi',  12, 14, 20},
					{'Froslass',  12, 14, 20},
					{'Rotom',  12, 14, 20},
					{'Manaphy',  12, 14, 20},
					{'Togetic',  12, 14, 20},
					{'Vigoroth',  12, 14, 20},
					{'Arcanine',  12, 14, 20},
					--]]
					{'Bidoof',  12, 14, 20},
					{'Poliwag', 12, 14, 15},
					{'Marill',  12, 14, 15},
					{'Wooper',  12, 14, 15},
					{'Sunkern', 12, 14, 12},
					{'Surskit', 12, 14, 10, nil, false, nil, {chance=60,item='honey'}},
					{'Skitty',  12, 14, 8},
					{'Yanma',   12, 14, 8, nil, false, nil, {chance=20,item='widelens'}},
					{'Ralts',   13, 15, 5},
				},
				OldRod = OldRodList {
					{'Magikarp', 40},
					{'Tympole',  20},
					{'Corphish', 5},
				},
				GoodRod = GoodRodList {
					{'Tympole', 50},
					{'Corphish', 20},
					{'Magikarp', 5},
					{'Whiscash', 5},
				},
				Surf = EncounterList {
					{'Bidoof', 26, 29, 20},
					{'Tympole', 26, 29, 10},
					{'Corphish', 26, 29, 5},		
				},
			}
		}
	},

	['chunk9'] = {
		buildings = {
			'Gate7',
			'Gate8',
			'PokeCenter',
		},
		regions = {
			['Lagoona Lake'] = {
				SignColor = BrickColor.new('Deep blue').Color,
				Music = 9537506183,--{323074713},--527348762,527351446,
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Goldeen',  10},
				},
				GoodRod = GoodRodList {
					{'Goldeen', 50},
				},
				Surf = EncounterList { 
					{'Goldeen', 26, 30, 40, nil, false, nil, {chance=20,item='mysticwater'}},
					{'Gyarados', 26, 30, 5},
					{'Ducklett', 26, 30, 1}
				}
			},
		},
	},

	['chunk10'] = {
		blackOutTo = 'chunk9',
		buildings = {
			'Gate8',
			'Gate9',
		},
		regions = {
			['Route 8'] = {
				RTDDisabled = true,
				Music = {9537284231, 12640251718}, --323074934,--2269965903,
				MusicVolume = 0.8,
				Grass = EncounterList {
					{'Oddish',     13, 16, 40, nil, false, nil, {chance=20, item='absorbbulb'}},
					{'Bellsprout', 13, 16, 40},
					{'Buneary',    13, 16, 35},
					{'Starly',     13, 16, 35},
					{'Lillipup',   13, 16, 35},
					{'Espurr',     13, 16, 25},
					{'Swablu',     13, 16, 20},
					{'Staravia',   14, 16, 15},
					{'Herdier',    14, 16, 15},
					{'Riolu',      13, 16,  4},
				},
				Well = EncounterList
				{Verify = function(PlayerData) return PlayerData:incrementBagItem('oddkeystone', -1) end}
				{{'Spiritomb', 15, 15, 1}}
			},
		},
	},

	['chunk11'] = {
		buildings = {
			'Gate9',
			'Gate10',
			'PokeCenter',
			['Gym3'] = {
				Music = 9537290876,--337187287,
				BattleScene = 'Gym3',
			},
		},
		regions = {
			['Rosecove City'] = {
				SignColor = BrickColor.new('Storm blue').Color,
				Music = 9537496501,--533525589,--330353519,
				BattleScene = 'Beach', -- for Santa, if nothing else
			},
			['Rosecove Beach'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 9537494379,--533466642,--337086384,--330353665,
				MusicVolume = 0.4,
				BattleScene = 'Beach',
				RodScene = 'Beach',
				RTDDisabled = true,
				Grass = EncounterList {
					{'Shellos',  15, 17, 20},
					{'Slowpoke', 15, 17, 15, nil, false, nil, {chance=90, item='laggingtail'}},
					{'Wingull',  15, 17, 10, nil, false, nil, {chance=60, item='prettywing'}},
					{'Psyduck',  15, 17, 10},
				},
				OldRod = OldRodList {
					{'Tentacool', 4},
					--{'Finneon',   1},
				},
				GoodRod = GoodRodList {
					{'Tentacool', 4},
					{'Finneon', 3},
					{'Tentacruel', 1},			
				},
				Surf = EncounterList {
					{'Tentacool', 27, 32, 10, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Finneon', 27, 32, 8},
					{'Lumineon', 27, 32, 5},
					{'Alomomola', 27, 32, 2},
				},
				PalmTree = EncounterList {Locked = true} {
					{'Exeggcute', 15, 17, 4},
					{'Aipom',     15, 17, 1},
				},
				MiscEncounter = EncounterList {Locked = true} { -- waves
					{'Krabby', 15, 17, 3},
					{'Staryu', 15, 17, 2, nil, false, nil, {chance=90, item='stardust'}},
					{'Staryu', 15, 17, 2, nil, false, nil, {chance=90, item='starpiece'}},
				},
			}
		}
	},

	['chunk12'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate10',
			['Gate11'] = {
				Music = 9537492766,--456107045,
			},
			'Gate12',
			'Gate13',
		},
		regions = {
			['Route 9'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 9537289229,--346707914,--2392929710,
				MusicVolume = 0.7,
				BattleScene = 'RT9',
				IsDark = true,
				Grass = EncounterList {
					{'Sewaddle',  19, 21, 30, nil, false, nil, {chance=20, item='mentalherb'}},
					{'Venipede',  19, 21, 25, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Shroomish', 19, 21,  2, nil, false, nil, {chance=20, item='bigmushroom'}},
					{'Shroomish', 19, 21,  2, nil, false, nil, {chance=60, item='tinymushroom'}},
					{'Paras',     19, 21, 35, 'day', false, nil, {chance=60, item='tinymushroom'}},
					{'Paras',     19, 21, 35, 'day', false, nil, {chance=20, item='bigmushroom'}},
					{'Roselia',   19, 21,  5, 'day'},
					{'Kricketot', 19, 21, 35, 'night', false, nil, {chance=20, item='metronome'}},
					{'Venonat',   19, 21,  5, 'night'},
				},
				PineTree = EncounterList {Locked = true} {
					{'Pineco',    19, 21, 30},
					{'Spewpa',    19, 21, 20},
					{'Kakuna',    19, 21, 10},
					{'Metapod',   19, 21, 10},
					{'Heracross', 20, 22,  2, 'night'},
					{'Pinsir',    20, 22,  2, 'day'},
				}
			}
		}
	},

	['chunk13'] = {
		blackOutTo = 'chunk11',
		lighting = {
			FogColor = Color3.fromHSV(5/6, .2, .5),
			FogStart = 45,
			FogEnd = 200,
		},
		buildings = {
			['Gate11'] = {
				Music = 9537492766, --456107045,
			},
			['HMFoyer'] = {
				BattleScene = 'HauntedMansion',
				Music = 9537332240,--456101011,
			},
			['HMStub1'] = { DoorViewAngle = 10 },
			['HMStub2'] = { DoorViewAngle = 10 },
			['HMAttic'] = {
				BattleScene = 'HauntedMansion',
				Music = 9537332240,--456101011,
			},
			['HMBabyRoom'] = {BattleScene = 'HauntedMansion'},
			['HMBadBedroom'] = {BattleScene = 'HauntedMansion'},
			['HMBathroom'] = {BattleScene = 'HauntedMansion'},
			['HMBedroom'] = {BattleScene = 'HauntedMansion'},
			['HMDiningRoom'] = {BattleScene = 'HauntedMansion'},
			['HMLibrary'] = {BattleScene = 'HauntedMansion'},
			['HMMotherLounge'] = {BattleScene = 'HauntedMansion'},
			['HMMusicRoom'] = {BattleScene = 'HauntedMansion'},
			['HMUpperHall'] = {BattleScene = 'HauntedMansion'},
		},
		regions = {
			['Fortulose Manor'] = { -- Well-Mannered Manure Manor
				SignColor = BrickColor.new('Mulberry').Color,
				Music = {9537331253,9542441422},--{456101869, 456102907},--346708311,
				--				IsDark = true,
				Grass = EncounterList {
					{'Phantump',  20, 22, 30},
					{'Pumpkaboo', 20, 22, 30, nil, false, nil, {chance=99, item='miracleseed'}},
					{'Golett',    21, 23,  4, nil, false, nil, {chance=20, item='lightclay'}},
				},
				OldRod = OldRodList {
					{'Magikarp', 18},
					{'Feebas',    1},
				},
				GoodRod = GoodRodList {
					{'Magikarp', 18},
					{'Feebas', 1},
				},
				InsideEnc = EncounterList {
					{'Rattata',    20, 22, 30, nil, false, nil, {chance=20, item='chilanberry'}},
					{'Shuppet',    20, 22, 20, nil, false, nil, {chance=20, item='spelltag'}},
					{'Duskull',    20, 22, 20, nil, false, nil, {chance=20, item='spelltag'}},
					{'Misdreavus', 20, 22,  8},
					{'Honedge',    20, 22,  2},
				},
				Candle = EncounterList {Locked = true} {{'Litwick', 20, 20, 1}},
				Gameboy = EncounterList {PDEvent = 'Rotom7'} {{'Rotom', 25, 25, 1}}
			}
		}
	},

	['chunk14'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'PokeCenter',
			'Gate12',
		},
		regions = {
			['Grove of Dreams'] = {
				Music = 9537488485,--379873128,
				Grass = EncounterList {
					{'Venipede',  20, 22, 25, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Mankey',    20, 22, 15},
					{'Snubbull',  20, 22, 10},
					{'Chatot',    20, 22,  5, nil, false, nil, {chance=20, item='metronome'}},
					{'Pancham',   21, 23,  2, nil, false, nil, {chance=20, item='mentalherb'}},
					{'Minccino',  20, 22, 10, 'day'},
					{'Kricketot', 20, 22, 35, 'night', false, nil, {chance=20, item='metronome'}},
				},
				OldRod = OldRodList {
					{'Magikarp', 49},

				},
				GoodRod = GoodRodList {
					{'Magikarp', 40},
					{'Dratini', 3},	
				},
				Wish = EncounterList {PDEvent = 'Jirachi'} {{'Jirachi', 25, 25, 1}},
				Sage = EncounterList {Locked = true} {{'Pansage', 25, 25, 1}},
				Sear = EncounterList {Locked = true} {{'Pansear', 25, 25, 1}},
				Pour = EncounterList {Locked = true} {{'Panpour', 25, 25, 1}}
			}
		}
	},

	['chunk15'] = {
		blackOutTo = 'chunk11',
		buildings = {
			'Gate13',
			['CableCars'] = {
				DoorViewAngle = 15,
			},
		},
		regions = {
			['Route 10'] = {
				SignColor = BrickColor.new('Linen').Color,
				Music = {9537284231, 12640251718}, --2269965903,
				MusicVolume = 0.8,
				BattleScene = 'Flowers',
				Grass = EncounterList {
					{'Hoppip',     20, 22, 30},
					{'Spoink',     20, 22, 25},
					{'Growlithe',  20, 22, 15},
					{'Chimecho',   20, 22, 10, nil, false, nil, {chance=20, item='cleansetag'}},
					{'Pawniard',   20, 22,  8},
					{'Helioptile', 20, 22,  4},
					{'Scyther',    21, 23,  2},
				},
				MiscEncounter = EncounterList {
					{'Floette',    20, 23, 30},
					{'Hoppip',     20, 23, 30},
					{'Spoink',     20, 23, 25},
					{'Petilil',    20, 23, 15, nil, false, nil, {chance=20, item='absorbbulb'}},
					{'Comfey',    20, 23, 10, nil, false, nil, {chance=20, item='mistyseed'}},
				},
				HoneyTree = EncounterList
				{GetPokemon = function(PlayerData)
					local foe = PlayerData.honey.foe
					PlayerData.honey = nil -- ok to completely remove?
					return foe
				end}
				{{'Teddiursa', 19, 20, 10}, 
					{'Combee', 19, 19, 90, nil, false, nil, {chance=20, item='honey'}}},
				Windmill = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.DinWM then return false end
					PlayerData.flags.DinWM = nil
					PlayerData.lastDrifloonEncounterWeek = _f.Date:getWeekId()
					return true
				end}
				{{'Drifloon', 25, 25, 1}}
			}
		}
	},

	chunk16 = {
		blackOutTo = 'chunk11', -- dynamic
		canFly = false,
		regions = {
			['Cragonos Mines'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 9537312917, --441184012,
				BattleScene = 'CragonosMines',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Woobat',     21, 24, 35, 'day'},
					{'Geodude',    21, 24, 30, nil, false, nil, {chance=20, item='everstone'}},
					{'Roggenrola', 21, 24, 30, nil, false, nil, {chance=60, item='everstone'}},
					{'Roggenrola', 21, 24, 30, nil, false, nil, {chance=20, item='hardstone'}},
					{'Meditite',   21, 24, 15},
					{'Diglett',    21, 24, 10, nil, false, nil, {chance=20, item='softsand'}},
					{'Onix',       21, 24,  7},
					{'Drilbur',    22, 25,  3},
					{'Larvitar',   22, 24,  2},
				},
				RodScene = 'CragonosMines',
				OldRod = OldRodList {
					{'Magikarp', 20},
					{'Goldeen',  10},
					{'Chinchou',  2},
				},			
				GoodRod = GoodRodList {
					{'Magikarp', 20},
					{'Goldeen', 10},
					{'Chinchou', 6},					
				},
				Surf = EncounterList {
					{'Goldeen', 30, 36, 10, nil, false, nil, {chance=20, item='mysticwater'}},
					{'Magikarp', 30, 36, 8},
					{'Tentacool', 30, 36, 5, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Clauncher', 30, 36, 2},
				},
			}
		}
	},

	chunk17 = {
		buildings = {
			'PokeCenter',
		},
		regions = {
			['Cragonos Cliffs'] = {
				SignColor = BrickColor.new('Sand green').Color,
				Music = 9536629006,
				MusicVolume = 0.9,
				BattleScene = 'Cliffs',
				Grass = EncounterList {
					{'Woobat',    21, 24, 30, 'night'},
					{'Spearow',   21, 24, 30, nil, false, nil, {chance=20, item='sharpbeak'}},
					{'Pidgeotto', 21, 24, 20},
					{'Skiddo',    21, 24, 20},
					{'Vullaby',   21, 24, 10},
					{'Gligar',    21, 24,  5},
					{'Bagon',     21, 24,  1, nil, false, nil, {chance=20, item='dragonfang'}},
				},
				Grace = EncounterList
				{Verify = function(PlayerData)
					return PlayerData:getBagDataById('gracidea', 5) and true or false
				end, PDEvent = 'Shaymin'}
				{{'Shaymin', 30, 30, 1, nil, false, nil, {chance=99, item='lumberry'}}}
			}
		}
	},

	chunk18 = {
		blackOutTo = 'chunk17',
		buildings = {
			'PokeCenter',
		},
		regions = {
			['Cragonos Peak'] = {
				SignColor = Color3.new(1, 1, 1),
				Music = 12639744943, --do this
				BattleScene = 'Peak',
				Grass = EncounterList {
					{'Skiddo',   22, 25, 30},
					{'Doduo',    22, 25, 30, nil, false, nil, {chance=20, item='sharpbeak'}},
					{'Spearow',  22, 25, 30, nil, false, nil, {chance=20, item='sharpbeak'}},
					{'Inkay',    22, 25, 10},
					{'Stantler', 23, 26,  6},
					{'Rufflet',  22, 26,  2},
				}
			}
		}
	},

	chunk19 = {
		blackOutTo = 'chunk21',
		regions = {
			['Anthian City - Housing District'] = {
				SignColor = BrickColor.new('Steel blue').Color,
				Music = 9537307358,--506504476,
				--				MusicVolume = 1, -- ?
				Dumpster = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.TinD then return false end
					PlayerData.flags.TinD = nil
					PlayerData.lastTrubbishEncounterWeek = _f.Date:getWeekId()
					return true
				end}
				{{'Trubbish', 22, 25, 1, nil, false, nil, {chance=20, item='silkscarf'}}}
			}
		}
	},

	chunk20 = {
		blackOutTo = 'chunk21',
		buildings = {
			['PokeBallShop'] = {
				DoorViewAngle = 25
			},
			['LudiLoco'] = {
				Music = 9537329754, --511833360,
				DoorViewAngle = 20
			},
			['LottoShop'] = {
				DoorViewAngle = 25
			},
			['C_chunk23'] = {
				DoorViewAngle = 60,
				DoorViewZoom = 15
			}
		},

		regions = {
			['Anthian City - Shopping District'] = {
				SignColor = BrickColor.new('Fossil').Color, -- Daisy orange
				Music = {9537304147,9542522472},--{497194421, 497194687},
				MusicVolume = .8,
			}
		}
	},

	chunk21 = {
		buildings = {
			['Gym4'] = {
				Music = {12639427451, 12640208294}, --do this
				BattleScene = 'Gym4',
				DoorViewZoom = 35,
			},
			'PokeCenter'
		},
		regions = {
			['Anthian City - Battle District'] = {
				SignColor = BrickColor.new('Crimson').Color,
				Music = {9537308431, 12640227487},--498678071,--240790316,
				MusicVolume = 0.7	
			}
		}
	},

	chunk22 = {
		blackOutTo = 'chunk21',
		buildings = {
			['PowerPlant'] = {DoorViewAngle = 20}
		},
		regions = {
			['Anthian Park'] = {--['Anthian City - Park District'] = {
				SignColor = BrickColor.new('Bright green').Color,
				Music = 9537306351, --627901899,
				MusicVolume = 0.7	
			}
		}
	},

	chunk23 = {
		blackOutTo = 'chunk21',
		canFly = false,
		buildings = {
			['C_chunk20'] = {
				--				DoorViewAngle = 25,
				DoorViewZoom = 14,
			},
			['C_chunk22'] = {
				DoorViewAngle = 30,
				DoorViewZoom = 14,
			},
			['EnergyCore'] = {
				DoorViewAngle = 20,
				DoorViewZoom = 12,
				BattleScene = 'CoreRoom',
			}
		},
		lighting = {
			Ambient = Color3.fromRGB(145, 145, 145),
			OutdoorAmbient = Color3.fromRGB(108, 108, 108),
			--			TimeOfDay = '06:00:00',
		},
		regions = {
			['Anthian Sewer'] = { -- IF THE NAME OF THIS CHANGES, EDIT Events.onLoad_chunk23 !
				SignColor = BrickColor.new('Slime green').Color,
				Music = 9537305137, --498677393,
				BattleScene = 'Sewer',
				--				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Voltorb',   27, 30, 25},
					{'Magnemite', 27, 30, 25},
					{'Klink',     27, 30, 20},
					{'Koffing',   27, 30, 10},
					{'Grimer',    27, 30, 10, nil, false, nil, {chance=20, item='blacksludge'}},
					{'Elekid',    28, 29,  2, nil, false, nil, {chance=20, item='electirizer'}},
				}
			}
		}
	},

	chunk24 = {
		blackOutTo = 'chunk21',
		buildings = {
			['CableCars'] = {DoorViewAngle = 15},
			'Gate14',
		},
		lighting = {
			FogColor = Color3.fromRGB(216, 194, 114), -- transition implemented in Events
			FogEnd = 200,
			FogStart = 40,
		},
		regions = {
			['Route 11'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 12635526851, --do this
				BattleScene = 'Desert',
				Grass = EncounterList
				{Weather = 'sandstorm'}
				{
					{'Cacnea',    28, 31, 20, nil, false, nil, {chance=20, item='stickybarb'}},
					{'Trapinch',  28, 31, 20, nil, false, nil, {chance=20, item='softsand'}},
					{'Hippowdon', 28, 31, 15},
					{'Sandslash', 28, 31, 10, nil, false, nil, {chance=20, item='gripclaw'}},
					{'Krokorok',  28, 31,  8, nil, false, nil, {chance=20, item='blackglasses'}},
					{'Maractus',  28, 31,  3, nil, false, nil, {chance=20, item='miracleseed'}},
				}
			}
		}
	},
	--this is where i need to add more music below me vvv
	chunk25 = {
		buildings = {
			'Gate14',
			'Gate15',
			'Gate16',
			['PokeCenter'] = {DoorViewAngle = 25},
			['House4'] = {DoorViewAngle = 25},
			['Palace'] = {Music = {615714813, 608877390}}
		},
		regions = {
			['Aredia City'] = {
				SignColor = BrickColor.new('Flint').Color,
				Music = {12635535724, 9542520663}, --do this
				BattleScene = 'Aredia',
				Snore = EncounterList
				{Verify = function(PlayerData)
					return PlayerData:hasFlute()
				end, PDEvent = 'Snorlax'}
				{{'Snorlax', 30, 30, 1}}
			}
		}
	},

	chunk26 = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Glistening Grotto'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 9537512122, --611071632,
				MusicVolume = .45,
				BattleScene = 'CrystalCave',
				RodScene = 'CrystalCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Zubat',   25, 30, 25, 'day'},
					{'Bronzor', 25, 30, 25},
					{'Boldore', 25, 30, 20, nil, false, nil, {chance=60, item='everstone'}},
					{'Boldore', 25, 30, 20, nil, false, nil, {chance=20, item='hardstone'}},
					{'Carbink', 25, 30, 15},
					{'Elgyem',  25, 30, 10},
					{'Mawile',  25, 30,  5, nil, false, nil, {chance=20, item='ironball'}},
					{'Sableye', 25, 30,  5, nil, false, nil, {chance=20, item='widelens'}},
					{'Aron',    25, 30,  3, nil, false, nil, {chance=20, item='hardstone'}},
				},
				OldRod = OldRodList {
					{'Goldeen',  30},
					{'Shellder', 15},
					--{'Relicanth', 1},
				},
				GoodRod = GoodRodList {
					{'Goldeen', 30},
					{'Shellder', 20},
					{'Relicanth', 6},

				},
			}
		}
	},

	chunk27 = {
		blackOutTo = 'chunk25',
		buildings = {
			'Gate15'
		},
		regions = {
			['Old Aredia'] = {
				SignColor = BrickColor.new('Cashmere').Color,
				Music = 12635526851, --do this
				BattleScene = 'Desert',
				Grass = EncounterList {
					{'Hippowdon', 29, 32, 25},
					{'Cacnea',    29, 32, 20, nil, false, nil, {chance=20, item='stickybarb'}},
					{'Trapinch',  29, 32, 20, nil, false, nil, {chance=20, item='softsand'}},
					{'Sandslash', 29, 32, 15, nil, false, nil, {chance=20, item='gripclaw'}},
					{'Dunsparce', 29, 32, 10},
					{'Gible',     29, 32,  1},
				}
			}
		}
	},
	chunk28 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 18856363981, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk29 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 18856363981, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk30 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 18856363981, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk31 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 18856363981, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk32 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 18856363981, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},
	chunk33 = {blackOutTo = 'chunk25', canFly = false, regions = {c = {NoSign = true, Music = 18856363981, BattleScene = 'DesertCastleRuins', RTDDisabled = true, GrassNotRequired = true, GrassEncounterChance = 1, Grass = ruinsEncounter}}},

	chunk34 = {
		blackOutTo = 'chunk25', 
		canFly = false, 
		regions = {
			c = {
				NoSign = true, 
				Music = 18856363981,
				BattleScene = 'DesertCastleRuins', 
				RTDDisabled = true, 
				GrassNotRequired = true, 
				GrassEncounterChance = 1, 
				Grass = ruinsEncounter,
				Victory = EncounterList
				{Verify = function(PlayerData)
					if not PlayerData.badges[5] then return false end
					return PlayerData.completedEvents.BJP and true or false
				end, PDEvent = 'Victini'}
				{{'Victini', 35, 35, 1}}
			}
		}
	},

	gym5 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk25',
		-- lighting ?
		regions = {
			['Aredia City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = {9542517494,9542518857},--{615714813, 608877390},
				BattleScene = 'Gym5'
			}
		}
	},

	chunk35 = {
		blackOutTo = 'chunk25',
		regions = {
			['Desert Catacombs'] = {
				SignColor = BrickColor.new('Black').Color,
				Music = 12639411308,
				MusicVolume = .8,
				BattleScene = 'UnownRuins',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Unown', 25, 30, 1}
				}
			}
		}
	},

	chunk36 = {
		buildings = {
			'Gate16'
		},
		blackOutTo = 'chunk25',
		regions = {
			['Route 12'] = {
				SignColor = BrickColor.new('Mint').Color,
				Music = 9536629006, --424133191,
				MusicVolume = 1.2,
				BattleScene = 'Rt12',
				Grass = EncounterList {
					--					{'Tranquill',  31, 34, 20},
					{'Houndour',   31, 34, 20},
					{'Vulpix',     31, 34, 15, nil, false, nil, {chance=20, item='charcoal'}},
					{'Sawk',       31, 35, 15, nil, false, nil, {chance=20, item='blackbelt'}},
					{'Throh',      31, 35, 15, nil, false, nil, {chance=20, item='blackbelt'}},
					{'Scraggy',    31, 34, 10, nil, false, nil, {chance=20, item='shedshell'}},
					{'Miltank',    31, 34,  5, nil, false, nil, {chance=99, item='moomoomilk'}},
					{'Tauros',     31, 34,  5},
					{'Bouffalant', 31, 34,  3},
				},
				OldRod = OldRodList {
					{'Magikarp', 10},
					{'Goldeen',   5},
					{'Qwilfish',  1}
				},
				GoodRod = GoodRodList {
					{'Goldeen', 10},
					{'Magikarp', 5},
					{'Qwilfish', 2},	
				},
			}
		}
	},

	chunk37 = {
		blackOutTo = 'chunk25',
		canFly = false,
		regions = {
			['Nature\'s Den'] = {
				SignColor = BrickColor.new('Moss').Color,
				Music = 9537312917,--441184012,
				BattleScene = 'NatureDen',
				Landforce = EncounterList
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.RNatureForces then return false end
					return PlayerData.flags.landorusEnabled and true or false -- flagged by DataService
				end, PDEvent = 'Landorus'}
				{{'Landorus', 40, 40, 1}}
			}
		}
	},

	chunk38 = {
		buildings = {'Gate17'},
		canFly = false,
		blackOutTo = 'chunk25',
		regions = {
			['Route 13'] = {
				SignColor = BrickColor.new('Moss').Color,
				Music = 12639415885, --do this
				BattleScene = 'BioCave',
				IsDark = true,
				NoGrassIndoors = true,
				GrassNotRequired = true,
				GrassEncounterChance = 2,
				Grass = EncounterList {
					{'Foongus',  32, 36, 20, nil, false, nil, {chance=60, item='tinymushroom'}},
					{'Foongus',  32, 36, 20, nil, false, nil, {chance=20, item='bigmushroom'}},
					{'Duosion',  32, 36, 20},
					{'Tangela',  32, 36, 15},
					{'Volbeat',  32, 36, 10, nil, false, nil, {chance=20, item='brightpowder'}},
					{'Illumise', 32, 36, 10, nil, false, nil, {chance=20, item='brightpowder'}},
					{'Joltik',   32, 36, 10},
					{'Tynamo',   32, 36,  3}
				}
			}
		}
	},

	chunk39 = {
		buildings = {'Gate17', 'Gate18', 'PokeCenter'},
		regions = {
			['Fluoruma City'] = {
				SignColor = BrickColor.new('Mint').Color,
				Music = 9537323448 --do this
			}
		}
	},

	gym6 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Fluoruma City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = {12639427451, 12640208294}, --do this
				BattleScene = 'Gym6'
			}
		}
	},

	chunk40 = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Igneus Depths'] = {
				Music = 9537474749, --497197006,--317351319,
				MusicVolume = .8,
				SignColor = BrickColor.new('Burgundy').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Numel',   25, 27, 17},
					{'Slugma',  25, 27, 20},
					{'Torkoal', 25, 27, 17, nil, false, nil, {chance=20, item='charcoal'}},
					{'Magmar',  25, 27,  5, nil, false, nil, {chance=20, item='magmarizer'}},
					{'Heatmor', 25, 27,  8},
				},
				Heat = EncounterList
				{PDEvent = 'Heatran'}
				{{'Heatran', 40, 40, 1}}
			}
		}
	},

	chunk41 = {
		canFly = false,
		blackOutTo = 'chunk39', -- cuz requires rock climb
		regions = {
			['Chamber of the Jewel'] = {
				SignColor = BrickColor.new('Pink').Color,
				BattleScene = 'BioCave',
				Music = 12639415885, --do this
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Foongus',  32, 36, 20, nil, false, nil, {chance=60, item='tinymushroom'}},
					{'Foongus',  32, 36, 20, nil, false, nil, {chance=20, item='bigmushroom'}},
					{'Duosion',  32, 36, 20},
					{'Tangela',  32, 36, 15},
					{'Volbeat',  32, 36, 10, nil, false, nil, {chance=20, item='brightpowder'}},
					{'Illumise', 32, 36, 10, nil, false, nil, {chance=20, item='brightpowder'}},
					{'Joltik',   32, 36, 10},
					{'Tynamo',   32, 36,  3}
				},
				Jewel = EncounterList
				{Verify = function(PlayerData) return PlayerData.completedEvents.OpenJDoor and true or false end,
				PDEvent = 'Diancie'}
				{{'Diancie', 40, 40, 1}}
			}
		}
	},

	chunk42 = {
		buildings = {'Gate18'},
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Route 14'] = {
				SignColor = BrickColor.new('Flint').Color,
				BattleScene = 'Rt14Ruins',
				Music = 12639441173,
				IsDark = true,
				NoGrassIndoors = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Loudred',  32, 36, 30},
					{'Makuhita', 32, 36, 40, nil, false, nil, {chance=20, item='blackbelt'}},
					{'Nosepass', 32, 36, 40, nil, false, nil, {chance=20, item='magnet'}},
					{'Mr. Mime', 32, 36, 20},
					{'Clefairy', 32, 36, 40},
					{'Noibat',   32, 36,  20},
					{'Beldum',   32, 36,  5},
					{'Onix',     32, 36,   1, nil, false, 'crystal'},
				}
			}
		}
	},

	chunk43 = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Route 14'] = {
				SignColor = BrickColor.new('Teal').Color,
				BattleScene = 'Rt14Ice',
				Music = 12639441173,
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Loudred',  32, 36, 30},
					{'Makuhita', 32, 36, 40, nil, false, nil, {chance=20, item='blackbelt'}},
					{'Nosepass', 32, 36, 40, nil, false, nil, {chance=20, item='magnet'}},
					{'Mr. Mime', 32, 36, 20},
					{'Clefairy', 32, 36, 40},
					{'Noibat',   32, 36,  20},
					{'Beldum',   32, 36,  5},
					{'Onix',     32, 36,   1, nil, false, 'crystal'},
				}
			}
		}
	},

	chunk44 = {
		canFly = false,
		blackOutTo = 'chunk17',
		regions = {
			['Cragonos Sanctuary'] = {
				SignColor = BrickColor.new('Hurricane grey').Color,
				Music = 9537312917,--441184012,
			}
		}
	},

	chunk45 = {
		buildings = {
			'Gate19',
			'house1',
			'house2'
		},
		canFly = true,
		blackOutTo = 'chunk39',

		lighting = {
			FogColor = Color3.fromRGB(187, 223, 224),
			FogStart = 180,
			FogEnd = 800,
		},
		regions = {
			['Route 15'] = {
				Music = 12639454821,--301381728,
				BattleScene = 'Snow',
				RodScene = 'Snow',
				RTDDisabled = true,
				MusicVolume = 0.81,
				Grass = EncounterList {
					{'Snover',  34, 38, 50, nil, false, nil, {chance=20, item='nevermeltice'}},
					{'Swinub',  34, 38, 50},
					{'Vanillite',  34, 38, 30, nil, false, nil, {chance=20, item='nevermeltice'}},
					{'Snorunt',  34, 38, 20, nil, false, nil, {chance=20, item='snowball'}},
					{'Sneasel',  34, 38, 5, 'night', false, nil, {chance=20, item='quickclaw'}},
					--winter event
					--{'Vulpix',     32, 36,   15, nil, false, 'Alola'},
					--{'Sandshrew',     32, 36,   15, nil, false, 'Alola'},
				},
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Spheal',   30},
					{'Seel',  10},
					{'Bergmite',   1}
				},
				GoodRod = GoodRodList {
					{'Spheal', 50},
					{'Seel', 30},
					{'Bergmite', 10},	
				},
			},
		},--]]
	},

	chunk58 = {
		canFly = false,
		blackOutTo = 'chunk11',
		regions = {
			['Martensite Chamber'] = {
				RTDDisabled = true,
				Music = 95059364507181,--301381728,
				MusicVolume = 0.81,
				IsDark = true,
				BattleScene = 'RegisteelCave',
				Registeel = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.Registeel or not PlayerData.completedEvents.CompletedCatacombs then return false end
					return true
				end}
				{{'Registeel', 40, 40, 1}}
			},
		},
	},

	chunk59 = {
		canFly = false,
		blackOutTo = 'chunk46',
		regions = {
			['Dendrite Chamber'] = {
				RTDDisabled = true,
				Music = 95059364507181,--301381728,
				BattleScene = 'RegiceCave',
				IsDark = true,
				Regice = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.Regice or not PlayerData.completedEvents.CompletedCatacombs then return false end
					return true
				end}
				{{'Regice', 40, 40, 1}}
			},
		},
	},

	chunk61 = {
		canFly = false,
		blackOutTo = 'chunk5',
		regions = {
			['Calcite Chamber'] = {
				RTDDisabled = true,
				SignColor = BrickColor.new('Yellow flip/flop').Color,
				Music = 95059364507181,
				IsDark = true,
				BattleScene = 'RegirockCave',
				Regirock = EncounterList
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.Regirock or not PlayerData.completedEvents.CompletedCatacombs then return false end
					return true
				end}
				{{'Regirock', 40, 40, 1}}
			},
		},
	},

	chunk46 = {
		buildings = {'Gate19','Gate20','PokeCenter'},
		canFly = true,
		blackOutTo = 'chunk46',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 200,
			FogEnd = 1000,
		},
		regions = {
			['Frostveil City'] = {
				Music = 9537317515, --6959482956,--301381728,
				BattleScene = 'Snow',--for if santa battle
				MusicVolume = 0.81,
			},
		},
	},

	['chunk75'] = {
		canFly = false,
		regions = {
			['Frostveil Catacombs'] = {
				SignColor = BrickColor.new('Smoky grey').Color,
				Music = 95059364507181,
				IsDark = true,
			}
		}
	},


	chunk47 = {
		buildings = {'Gate20','Gate24', 'SkittyLodge'},
		canFly = true,
		blackOutTo = 'chunk46',
		lighting = {
			FogColor = Color3.fromRGB(190, 217, 225),
			FogStart = 0,
			FogEnd = 1000,
		},
		regions = {
			['Route 16'] = {
				SignColor = BrickColor.new('Medium stone grey').Color,
				Music = 9537299603, --3099468912,
				BattleScene = 'Route',
				--	RodScene = 'Forest1',
				Grass = EncounterList {
					{'Jigglypuff',    35, 39, 30, nil, false, nil, {chance=20, item='moonstone'}},
					{'Swellow',    35, 40, 30},
					{'Furfrou',    35, 40, 5},
					{'Nuzleaf',    35, 40,  5, nil, false, nil, {chance=20, item='powerherb'}},
					{'Dedenne',     35, 40,  4},
					{'Emolga',  35, 40,  4},
				},
			}
		}
	},

	chunk48 = {
		blackOutTo = 'chunk46',
		canFly = false,
		lighting = {
			FogColor = Color3.fromRGB(50, 71, 167),
			FogStart = 1,
			FogEnd = 800,
		},
		regions = {
			['Freezing Fissure'] = {
				SignColor = BrickColor.new('Cyan').Color,
				Music = 107660547817580,
				GrassNotRequired = true,
				RTDDisabled = true,
				BattleScene = 'Fissure',
				RodScene = 'Fissure',
				MusicVolume = .9,
				IsDark = true,
				Grass = EncounterList {
					{'Munna',  36, 40, 40},
					{'Cubchoo',   36, 40, 40},
					{'Snorunt', 36, 40, 29, nil, nil, nil, {chance=20, item='snowball'}},
					{'Cryogonal',  36, 40, 25, nil, nil, nil, {chance=20, item='nevermeltice'}},
					{'Jynx',  36, 40, 5},
					{'Delibird',  36, 40, 1},

				},
			},
		}
	},

	['chunk49'] = {
		canFly = false,
		noHover = true,
		regions = {
			['Cosmeos Observatory'] = {
				Music = 9537293965,
				MusicVolume = routeMusicVolume,
			},
		},
	},

	chunk51 = {
		buildings = {
			['PondEntrance'] = {
				BattleSceneType = 'PondEntrance',
			},
			'Gate24','Gate21',
			'Gate25'
		},
		blackOutTo = 'chunk46',
		canFly = true,
		regions = {
			['Cosmeos Valley'] = {
				SignColor = BrickColor.new('Dark green').Color,
				Music = 9537293965, --6959495019,
				BattleScene = 'CValley',
				RodScene = 'Forest1',
				Grass = EncounterList {
					{'Munna',       36, 40, 35}, -- Remove forewarn from Munna or try to fix it
					{'Cottonee',    36, 40, 30, nil, false, nil, {chance=20, item='absorbbulb'}},
					{'Vigoroth',    36, 40, 30},
					--	{'Munna',    36, 40, 30},
					{'Minior',    36, 40, 30, nil, false, nil, {chance=20, item='starpiece'}},
					--{'Minior',      36, 40, 20},
					{'Skarmory',    36, 40, 20},
					{'Hawlucha',    36, 40,  5, nil, false, nil, {chance=20, item='kingsrock'}},
					{'Shelmet',     36, 40,  4},
					{'Karrablast',  36, 40,  4},
					--{'Ditto',  36, 40,  1},
				},
				OldRod = OldRodList {
					{'Magikarp', 50},
					{'Goldeen',   30},
					{'Basculin',  10},
					--{'Luvdisc',   5}
				},		
				GoodRod = GoodRodList {
					{'Goldeen', 50},
					{'Magikarp', 30},
					{'Basculin', 10},
					{'Luvdisc',   5},
				},
			}
		}
	},


	['chunk50'] = {
		blackOutTo = 'chunk46',
		buildings = {
			'Gate25'
		},
		regions = {
			['Tinbell Construction Site'] = {
				SignColor = BrickColor.new('Light orange brown').Color,
				Music = 9537301480,
				MusicVolume = 2,
			},
			['Tinbell Tower'] = {
				SignColor = BrickColor.new('Flame yellowish orange').Color,
				GrassNotRequired = true,
				Music = 9537301480,
				MusicVolume = 2,
				BattleScene = 'TinbellTower',
				Grass = EncounterList {
					{'Machop',    30, 40,  20, nil, false, nil, {chance=20, item='focusband'}},
					{'Timburr', 30, 40, 17},
					{'Clobbopus', 30, 40, 14},
					{'Machoke',    30, 40,  10, nil, false, nil, {chance=20, item='focusband'}},
					{'Gurdurr',  30, 40, 10},
					{'Falinks',  30, 40, 5}
				},
			},
		}
	},

	chunk52 = {
		buildings = {
			'Gate21',
			'PokeCenter',
			'Gate22',
			'ShipTickets',
			'CookesKitchen',
			'ShipHouse',
			'HerosHoverboardsDecca',
			'Aifes',
			'PBStampShop',


		},
		canFly = true,
		blackOutTo = 'chunk52',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Port Decca'] = {
				Music = 9536622339,--301381728,
				BattleScene = 'Docks',
				RodScene = 'Docks',
				MusicVolume = 0.81,
			},
		},
	},

	['chunk74'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk52',
		regions = {
			['Secret Lab'] = {
				SignColor = BrickColor.new('Pink').Color,
				RTDDisabled = true,
				Music = 9537305137,
				BattleScene = 'SecretLab',
			}
		}
	},

	chunk53 = {
		buildings = {'Gate22'},
		canFly = true,
		blackOutTo = 'chunk52',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Decca Beach'] = {
				Music = 9537328256, --6959487612,--301381728, 
				BattleScene = 'DeccaBeach',
				MusicVolume = 0.81,
				Surf = EncounterList {
					{'Tentacruel', 30, 40, 10, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Carvanha', 30, 40, 8, nil, false, nil, {chance=20, item='deepseatooth'}},
					{'Lumineon', 30, 40, 5},
					{'Mantine', 30, 40, 1},
				},
				OldRod = OldRodList {
					{'Tentacool', 60},
					{'Finneon',   20},
					--{'Remoraid',  2}
				},
				GoodRod = GoodRodList {
					{'Tentacool', 60},
					{'Finneon', 20},
					{'Gyarados', 8},
					{'Remoraid',   2},
				},
			},
		},
	},
	chunk54 = {
		buildings = {'Gate23','PokeCenter', 'Tavern'},
		canFly = true,
		blackOutTo = 'chunk54',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 10000000,
		},
		regions = {
			['Crescent Town'] = {
				Music = 9537315080, --6959497193,--301381728,
				BattleScene = 'Crescent',
				RodScene = 'Crescent',
				MusicVolume = 0.81,
				Surf = EncounterList {
					{'Frillish', 31, 39, 10},
					{'Tentacruel', 31, 39, 10, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Binacle', 31, 39, 8},
					{'Seaking', 31, 39, 5, nil, false, nil, {chance=20, item='mysticwater'}},
					{'Lumineon', 31, 39, 2},
					{'Clamperl', 31, 39, 2, nil, false, nil, {chance=20, item='bigpearl'}},
					{'Clamperl', 31, 39, 2, nil, false, nil, {chance=60, item='pearl'}},
				},
				OldRod = OldRodList {
					{'Finneon', 60},
					{'Goldeen',   20},
					{'Tentacool',   20},
					{'Clamperl',   3},
					--{'Remoraid',  2}
				},
				GoodRod = GoodRodList {
					{'Binacle', 20},
					{'Tentacool', 20},
					{'Frillish', 20},
					{'Goldeen',   5},
					{'Finneon',   5},
					{'Clamperl',   3},
					{'Dhelmise',   3},
				},
			},
		},
	},		
	chunk55 = {
		buildings = {'Gate23'},
		canFly = true,
		blackOutTo = 'chunk54',
		lighting = {
			FogColor = Color3.fromRGB(104, 131, 107),
			FogStart = 0,
			FogEnd = 200,
		},
		regions = {
			['Route 18'] = {
				Music = 102208403418686,--301381728, --do this
				BattleScene = 'Swamp',
				MusicVolume = 0.81,
				Grass = EncounterList {
					{'Swalot',34, 42, 10, nil, false, nil, {chance=60, item='oranberry'}},
					{'Swalot',34, 42, 10, nil, false, nil, {chance=20, item='sitrusberry'}},
					{'Croagunk', 34, 42, 5, nil, false, nil, {chance=20, item='blacksludge'}},
					{'Toxicroak', 36, 42, 5, nil, false, nil, {chance=20, item='blacksludge'}},
					{'Ribombee', 34, 42, 5, nil, false, nil, {chance=20, item='honey'}},
					{'Skorupi', 34, 42, 5, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Drapion', 34, 42, 5, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Carnivine', 34, 42, 5},
					--	{'Grimer',  34, 42,  2},
					{'Grimer', 34, 42, 1, nil, false, 'Alola', {chance=20, item='blacksludge'}},
					{'Goomy', 34, 42, 1, nil, false, nil, {chance=20, item='shedshell'}},
				},
			},
		},
	},
	['chunk56'] = {
		canFly = false,
		blackOutTo = 'chunk54',
		lighting = {
			FogColor = Color3.fromRGB(47, 191, 7),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Aborille Outpost'] = {
				Music = 7223947139,--301381728, --do this
				BattleScene = 'Swamp',
				MusicVolume = 0.81,
				GrassNotRequired = true,
				RTDDisabled = true,
				GrassEncounterChance = 3,
				Grass = EncounterList {
					{'Mienfoo',     34, 42,  7},
					{'Wobbuffet',  34, 42,  6},
					{'Solrock',  34, 42,  4},
					{'Lunatone',  34, 42,  2},
					{'Drampa', 34, 42, 1}
				},
				Hoops = EncounterList {{'Hoopa-unbound', 65, 65, 1}}
			},
			["Demon's Tomb"] = {
				RTDDisabled = true,
				Music = 7223947139,--301381728,
				MusicVolume = 0.81,
			},
		},
	},
	chunk57 = {
		buildings = {
			['C_chunk85'] = {
				DoorViewAngle = 20
			},
			['C_chunk86'] = {
				DoorViewAngle = 20
			}
		},
		canFly = false,
		noHover = true,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base - Entrance Hall'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 107350888359075,
				MusicVolume = 1.2,
				BattleScene = 'EclipseHalls'
			}
		}
	},
	chunk81 = {
		buildings = {
			['C_chunk57|b'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base - Cafeteria'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 107350888359075,
				MusicVolume = 1.2,
				BattleScene = 'EclipseCafeteria'
			}
		}
	},

	['chunk82'] = {
		buildings = {
			['C_chunk57|a'] = {
				DoorViewAngle = 20
			},
			['C_chunk57|b'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base - Power Station'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 107350888359075,
				MusicVolume = 1.2,
				BattleScene = 'EclipsePower'
			}
		}
	},

	['chunk83'] = {
		buildings = {
			['C_chunk57'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base - Living Quarters'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 107350888359075,
				MusicVolume = 1.2,
				BattleScene = 'LivingQuarters'
			}
		}
	},

	['chunk84'] = {
		buildings = {
			['C_chunk57'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base - Surveillance Room'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				MusicVolume = 1.2,
				Music = 107350888359075,
			}
		}
	},

	['chunk85'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			["Eclipse Base - Professor's Office"] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				MusicVolume = 1.2,
				Music = 107350888359075,
			}
		}
	},

	['chunk86'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base - Prison Cells'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				MusicVolume = 1.2,
				Music = 107350888359075,
			}
		}
	},


	['chunk88'] = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Gene Lab'] = {
				SignColor = BrickColor.new('Bright violet').Color,
				RTDDisabled = true,
				Music = 107350888359075,
				MusicVolume = 1.2,
				BattleScene = 'GeneLab',
				MetalBug = EncounterList 
				{Verify = function(PlayerData)
					if PlayerData.completedEvents.Genesect then return false end
					if not PlayerData.completedEvents.UnlockGenDoor then return false end
					return true
				end}
				{{'Genesect', 50, 50, 1}}
			}
		}
	},

	gym7 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk46',
		regions = {
			['Frostveil City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 12639467662,
				MusicVolume = 0.81,
				BattleScene = 'Gym7'
			},
		},
	},

	gym72 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk46',
		regions = {
			['Frostveil City Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 12639467662,
				MusicVolume = 0.81,
				BattleScene = 'Gym7'
			},
		},
	},	

	['chunk60'] = {
		buildings = {
			['C_chunk86'] = {
				DoorViewAngle = 20
			}
		},
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Eclipse Base - Aircraft Hangar'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				RTDDisabled = true,
				Music = 107350888359075,--301381728,
			}
		}
	},



	['chunk62'] = {
		blackOutTo = 'chunk5',
		canFly = false,
		regions = {
			['Steam Chamber'] = {
				Music = 9537474749,
				MusicVolume = .9,
				SignColor = BrickColor.new('Cocoa').Color,
				BattleScene = 'LavaCave',
				IsDark = true,
				GrassNotRequired = true,
				GrassEncounterChance = 4,
				Grass = EncounterList {
					{'Camerupt',   36, 40, 20},
					{'Torkoal', 36, 40, 17, nil, nil, nil, {chance=20, item='charcoal'}},
					{'Heatmor',  36, 40, 17},
					{'Magcargo',  36, 40, 10},
					{'Magmar',   36, 40,  10, nil, nil, nil, {chance=20, item='magmarizer'}},
					{'Larvesta', 36, 40,  5},
				},
				Volcanion = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.completedEvents.RevealSteamChamber then return false end
					return true
				end}
				{{'Volcanion', 60, 60, 1}}
			}
		}
	},

	chunk63 = {
		canFly = false,
		blackOutTo = 'chunk39',
		regions = {
			['Titans Throng'] = {
				Music = 95059364507181,--301381728,
				RTDDisabled = true,
				SignColor = BrickColor.new('Gold').Color,
				IsDark = true,
				MusicVolume = 0.81,
			},
		},
	},

	gym8 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk54',
		regions = {
			['Cresent Island Gym'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = {12639427451, 12640208294},
				MusicVolume = 0.81,
				BattleScene = 'Docks'
			},
		},
	},
	chunk64 = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk3',
		regions = {
			['POLUT Base'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 5889640785,
				MusicVolume = 0.61,
			},
		},
	},
	chunk65 = {
		canFly = false,
		blackOutTo = 'chunk3',
		lighting = {
			FogColor = Color3.fromRGB(27, 27, 27),
			FogStart = 0,
			FogEnd = 100,
		},
		regions = {
			['Haloine Place'] = {
				SignColor = BrickColor.new('Royal purple').Color,
				Music = 12639510997,--301381728,
				MusicVolume = 0.4,
				BattleScene = 'Graveyard',
				Grass = EncounterList {
					{'Cubone',   10, 20, 30},
					{'Stufful',   10, 20, 30},
					{'Pyukumuku',   10, 20, 30},
					{'Pikipek',   10, 20, 30},
					{'Cutiefly',   10, 20, 30},
					{'Bounsweet',   10, 20, 25},
					{'Sandygast',   10, 20, 30},
					{'Murkrow',   10, 20, 25},
					{'Gastly',     10, 20, 25},
					{'Haunter', 15, 20, 20},
					{'Lickitung',    10, 20, 10},
					{'Nuzleaf',    15, 20, 5},
					{'Taillow',    15, 20, 5},
					{'Shedinja',    15, 20, 5},
					{'Drifloon',    15, 20, 5},
					{'Umbreon',    10, 25,  3},
					{'Rotom',    10, 25,  3},
					{'Salandit',    10, 25,  3},
					{'Eevee',    10, 25,  3},
					{'Bidoof',     10, 25,  1, nil, false, 'rainbow'},
					--]]
				},
			},
		},
	},
	chunk66 = {
		blackOutTo = 'chunk9',
		regions = {
			['Secret Grove'] = {--['Anthian City - Park District'] = {
				SignColor = BrickColor.new('Bright green').Color,
				Music = 9537306351, --3090985838,
				MusicVolume = 1,
				RTDDisabled = true,
				BattleScene = 'Grove',
				Keldeo = EncounterList 
				{Verify = function(PlayerData)
					if not PlayerData.flags.hasSwordsOJ then return false end
					return true
				end}
				{{'Keldeo', 40, 40, 1}}
			}
		}
	},

	chunk67 = {
		blackOutTo = 'chunk52',
		canFly = false,
		lighting = {
			Ambient = Color3.fromRGB(126, 126, 126),
			OutdoorAmbient = Color3.fromRGB(148, 148, 148),
			--			TimeOfDay = '06:00:00',
			EnvironmentSpecularScale = 1,
			FogEnd = 250,
			FogColor = Color3.fromRGB(41, 87, 108),		
		},
		regions = {
			['Ocean\'s Origin '] = {
				SignColor = BrickColor.new('Bright green').Color,
				Music = 108576926864159,
				MusicVolume = 1.4
			},
		},
	},
	['chunk68'] = {
		blackOutTo = 'chunk8',
		RTDDisabled = true,
		noHover = true,
		canFly = false,
		regions = {
			['Path Of Truth'] = {
				GrassNotRequired = true,
				GrassEncounterChance = 1,
				Grass = EncounterList {
					{'Axew',     36, 41, 35},
					{'Noibat',    36, 41, 30},
					{'Deino',    36, 41,  3},
					{'Duraludon',    36, 41,  3},
					{'Druddigon',   36, 41,  2, nil, false, nil, {chance=20, item='dragonfang'}},
					{'Milcery',   36, 41,  1, nil, false, nil, {chance=20, item='whippeddream'}},
				},
				SignColor = BrickColor.new('Pink').Color,
				BattleScene = 'PathOfTruth',
				Music = 81537934041054,
				MusicVolume = 1,
			},
		}
	},
	chunk72 = {
		blackOutTo = 'chunk3',
		canFly = false,
		lighting = {
			Ambient = Color3.fromRGB(126, 126, 126),
			OutdoorAmbient = Color3.fromRGB(148, 148, 148),
			--			TimeOfDay = '06:00:00',
			EnvironmentSpecularScale = 1,
			FogEnd = 1000,
			FogColor = Color3.fromRGB(160, 206, 225),		
		},
		regions = {
			['Silvent Cove'] = { -- IF THE NAME OF THIS CHANGES, EDIT Events.onLoad_chunk23 !
				SignColor = BrickColor.new('Light blue').Color,
				Music = 4595557202,
				BattleScene = 'CragonosMines',
				GrassNotRequired = true,
				GrassEncounterChance = 5,
				Grass = EncounterList {
					--	{'Carkol', 24, 30, 25},
					-- [[
					{'Blipbug',     24, 28, 25},
					{'Gossifleur',   24, 28, 20},
					{'Sandaconda',   24, 28, 15},
					{'Pidove',   24, 28, 10},
					--{'Zigzagoon',     24, 28,   1, nil, false, 'Galar'},
					--]]
					--{'Meowth',     26, 28,   1, nil, false, 'Galar'},
				},
			},
		},
	},
	chunk70 = {
		blackOutTo = 'chunk52',
		regions = {
			['Lost Islands'] = {
				SignColor = BrickColor.new('Brick yellow').Color,
				Music = 9542451518, --6355088088,--337086384,--533466642
				MusicVolume = 0.6,
				BattleScene = 'Islands', --do this
				--	RodScene = 'Beach',
				--	RTDDisabled = true,
				Grass = EncounterList {
					{'Yungoos',  20, 30, 20, nil, false, nil, {chance=20, item='pechaberry'}},
					-- [[

					{'Pikipek', 20, 30, 15, nil, false, nil, {chance=20, item='oranberry'}},
					{'Rattata',  20, 30, 10, nil, false, 'Alola', {chance=80, item='pechaberry'}},
					{'Rattata',  20, 30, 10, nil, false, 'Alola', {chance=70, item='chilanberry'}},
					{'Grubbin',  20, 30, 5},
					{'Rockruff',  20, 30, 1},
										--]]

				},
				Surf = EncounterList {
					{'Tentacruel', 20, 30, 10, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Tentacool', 20, 30, 8, nil, false, nil, {chance=20, item='deepseatooth'}},
					{'Lumineon', 20, 30, 5},
					{'Corsola', 20, 30, 1, nil, false, nil, {chance=20, item='luminousmoss'}},
				},
				OldRod = OldRodList {
					{'Tentacool', 4},
					{'Finneon',   1},
				},
				GoodRod = GoodRodList {
					{'Tentacruel', 6},
					{'Lumineon', 5},
					{'Tentacool', 4},
					{'Mareanie', 4},
				},
			},
		},
	},


--[[
	chunk66 = {
		buildings = {'Gate21','PokeCenter','Gate22'},
		canFly = true,
		blackOutTo = 'chunk51',
		lighting = {
			FogColor = Color3.fromRGB(184, 212, 227),
			FogStart = 0,
			FogEnd = 100000,
		},
		regions = {
			['Port Decca'] = {
				SignColor = BrickColor.new('Bright orange').Color,
				Music = 4668636704,--301381728,
				MusicVolume = 0.81,
			},
		},
	},
--]]	

	--]]


	chunk71 = {
		canFly = true,
		blackOutTo = 'chunk52',
		lighting = {
			Ambient = Color3.fromRGB(126, 126, 126),
			--OutdoorAmbient = Color3.fromRGB(148, 148, 148),
			--			TimeOfDay = '06:00:00',
			--		EnvironmentSpecularScale = 1,
			FogEnd = 7000,
			FogColor = Color3.fromRGB(0, 110, 255),
		},
		regions = {
			['Route 17'] = {
				SignColor = BrickColor.new('Teal').Color,
				BattleScene = 'Surf',
				Music = 9537292630, --7649193619,
				--IsDark = true,
				--	GrassNotRequired = true,
				--	GrassEncounterChance = 3,
				Surf = EncounterList {
					{'Wailmer', 31, 39, 10},
					{'Tentacruel', 31, 39, 10, nil, false, nil, {chance=20, item='poisonbarb'}},
					{'Lumineon', 31, 39, 8},
					{'Seaking', 31, 39, 8, nil, false, nil, {chance=20, item='mysticwater'}},
					{'Skrelp', 31, 39, 8},
					{'Horsea', 31, 39, 5, nil, false, nil, {chance=20, item='dragonscale'}},
					{'Pyukumuku', 31, 39, 2},
					{'Floatzel', 31, 39, 1},
				},
				OldRod = OldRodList {
					{'Tentacool', 6},
					{'Goldeen',   5},
					{'Finneon',   5},
					{'Buizel',   1},
				},
				GoodRod = GoodRodList {
					{'Wailmer', 5},
					{'Tentacool', 5},
					{'Goldeen', 4},
					{'Skrelp', 4},
					{'Finneon', 4},
					{'Horsea', 4},
					{'Pyukumuku', 1},
					{'Buizel', 1},
					{'Bruxish', 1},
				},
			},
		},
	},

	chunk73 = {
		blackOutTo = 'chunk46',
		canFly = false,
		lighting = {
			FogEnd = 10000,
			FogColor = Color3.fromRGB(51, 104, 168),		
		},
		regions = {
			['Bob\'s Magik Pond'] = { 
				Music = 9537489909, --6960197286,
				RodScene = 'MagikPond',
				OldRod = OldRodList {
					{'Magikarp',  10, 20, 20, nil, false, 'OrangeDapples'},
					{'Magikarp',  10, 20, 20, nil, false, 'PinkDapples'},
					{'Magikarp',  10, 20, 20, nil, false, 'CalicoOrangeWhite'},
					{'Magikarp',  10, 20, 20, nil, false, 'Monochrome'},
					{'Magikarp',  10, 20, 20, nil, false, 'Wasp'},
					{'Magikarp',  10, 20, 20, nil, false, 'YinYang'},
					{'Magikarp',  10, 20, 10, nil, false, 'Seaking'},
					{'Magikarp',  10, 20, 10, nil, false, 'Gyarados'},
					{'Magikarp',  10, 20, 10, nil, false, 'Relicanth'},
					{'Magikarp',  10, 20, 1, nil, false, 'Rayquaza'},


				},
				GoodRod = GoodRodList {
					{'Magikarp',  10, 20, 20, nil, false, 'OrangeDapples'},
					{'Magikarp',  10, 20, 20, nil, false, 'PinkDapples'},
					{'Magikarp',  10, 20, 20, nil, false, 'CalicoOrangeWhite'},
					{'Magikarp',  10, 20, 20, nil, false, 'Monochrome'},
					{'Magikarp',  10, 20, 20, nil, false, 'Wasp'},
					{'Magikarp',  10, 20, 20, nil, false, 'YinYang'},
					{'Magikarp',  10, 20, 20, nil, false, 'Seaking'},
					{'Magikarp',  10, 20, 20, nil, false, 'Gyarados'},
					{'Magikarp',  10, 20, 20, nil, false, 'Relicanth'},
					{'Magikarp',  10, 20, 5, nil, false, 'Rayquaza'},
				},
			},
		},
	},

	chunk89 = {
		canFly = true,
		blackOutTo = 'chunk46',
		
		regions = {
			['Victory Road - Entrance'] = {
				SignColor = BrickColor.new('Teal').Color,
				Music = 9537292630, --7649193619,
				--IsDark = true,
				--	GrassNotRequired = true,
				--	GrassEncounterChance = 3,
				
			},
		},
	},

	['chunk76'] = {
		noHover = true,
		canFly = false,
		buildings = {
			['C_chunk53|a'] = {
				DoorViewAngle = 10
			},
			['C_chunk53|b'] = {
				DoorViewAngle = 10
			},
			['C_chunk77|a'] = {
				DoorViewAngle = 10
			},
			['C_chunk77|b'] = {
				DoorViewAngle = 10
			}
		},
		regions = {
			['Safari Zone Entrance'] = {
				RTDDisabled = true,
				NoSign = true,
				Music = 112313844070488,
				MusicVolume = 1.8,

			}
		}
	},
	
	['chunk77'] = {
		blackOutTo = 'chunk58',
		canFly = false,
		isSafari = true,
		buildings = {
			['C_chunk76|a'] = {
				DoorViewAngle = 10
			},
			['C_chunk76|b'] = {
				DoorViewAngle = 10
			}
		},
		regions = {
			['Roria Safari Zone'] = {
				SignColor = BrickColor.new('Dark green').Color,
				RTDDisabled = true,
				Music = 112313844070488,
				MusicVolume = 1.8,
				BattleScene = 'SafariZone',
				Grass = EncounterList                 
				{isSafari = true}
				{
					{'Deerling', 29, 37, 10},
					--{'Drowzee', 29, 37, 10},
					{'Farfetch\'d', 29, 37, 10, nil, nil, nil,  {chance=20, item='stick'}},
					{'Lickitung', 29, 37, 10, nil, nil, nil, {chance=20, item='laggingtail'}},
					{'Morelull', 29, 37, 10, nil, nil, nil, {chance=20, item='bigmushroom'}},
					{'Mudbray', 29, 37, 10, nil, nil, nil, {chance=20, item='lightclay'}},
					{'Rhyhorn', 29, 37, 10},
					{'Shellos', 29, 37, 10, nil, nil, 'East'},
					{'Spinda', 29, 37, 10},
					{'Ferroseed', 29, 37, 5, nil, nil, nil, {chance=20, item='stickybarb'}},
					{'Kecleon', 29, 37, 5},
					{'Stufful', 29, 37, 5},
					{'Tropius', 29, 37, 5},
					{'Kangaskhan', 29, 37, 5},
					{'Kecleon', 29, 37, 0.5, nil, nil, 'Purple'},
					{'Rhyhorn', 29, 37, 0.3, nil, nil, 'Purple'}, 
				},
				MiscEncounter = EncounterList 
				{isSafari = true}
				{
					--{'Drowzee', 29, 37, 10},
					{'Farfetch\'d', 29, 37, 10, nil, nil, nil, {chance=20, item='stick'}},
					{'Kecleon', 29, 37, 10},
					{'Morelull', 29, 37, 10, nil, nil, nil, {chance=20, item='bigmushroom'}},
					{'Oddish', 29, 37, 10, nil, nil, nil, {chance=20, item='absorbbulb'}},
					{'Spinda', 29, 37, 10},
					{'Spritzee', 29, 37, 10},
					{'Swirlix', 29, 37, 10},
					{'Tropius', 29, 37, 5},
					{'Kangaskhan', 29, 37, 5},
					{'Stufful', 29, 37, 5},
					{'Kecleon', 29, 37, 0.5, nil, nil, 'Purple'},
					{'Oddish', 29, 37, 0.5, nil, nil, 'Aku', {chance=20, item='absorbbulb'}},
				},
				Zelda = EncounterList {Locked = true} {{'Honedge', 30, 30, 1, nil, nil, 'Zelda'}}
			}
		}
	},

	UrAnthianHouse = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk19',
		-- lighting ?
		regions = {
			['Your House'] = {
				RTDDisabled = false,
				NoSign = true,
				Music = {615714813, 608877390},
				BattleScene = 'Gym5'
			},
		},
	},
	Arcade = {
		noHover = true,
		canFly = false,
		blackOutTo = 'chunk21',
		-- lighting ?
		regions = {
			['Golden Pokeball - Arcade'] = {
				SignColor = BrickColor.new('Bright green').Color,
				--RTDDisabled = false,
				--NoSign = false,
				Music = {12639528586},
				--BattleScene = 'Arcade',
				lighting = {
					Ambient = Color3.fromRGB(255, 12, 190),
					OutdoorAmbient = Color3.fromRGB(255, 12, 190),
					--			TimeOfDay = '06:00:00',
				},
			},
		},
	},	
	['mining'] = {
		noHover = true,
		canFly = false,
		regions = {
			['Lagoona Trenches'] = {
				RTDDisabled = true,
				SignColor = Color3.new(78/400, 133/400, 191/400),--BrickColor.new('Smoky grey').Color,--'Reddish brown').Color,
				Music = 12639531039,
			},
		},
	},
	-- sub-contexts
	['colosseum'] = {
		canFly = false,
		regions = {
			['Battle Colosseum'] = {
				SignColor = BrickColor.new('Light orange').Color,
				Music = 12639533018, --1844506039, --440053692,
				--MusicVolume = .5,	
			},
		},
	},
	['resort'] = {
		canFly = false,
		regions = {
			['Trade Resort'] = {
				SignColor = BrickColor.new('Pastel blue-green').Color,
				Music = {12639543578, 9542488465},--{435780183, 435780736}, --2962775556
				MusicVolume = .5,
			},
		},
	},
	rockSmashEncounter = EncounterList {Locked = true} {
		{'Dwebble', 15, 20, 7, nil, false, nil, {chance=20, item='hardstone'}},
		{'Shuckle', 15, 20, 1, nil, false, nil, {chance=20, item='berryjuice'}},
	},
	roamingEncounter = { -- all @ lv 40
		Jirachi = {{'Jirachi', 4}},
		Shaymin = {{'Shaymin', 4}},
		Victini = {{'Victini', 4}},
		RNatureForces = {
			{'Thundurus', 3},
			{'Tornadus',  3}},
		Landorus = {{'Landorus', 2}},
		Heatran = {{'Heatran', 4}},
		Diancie = {{'Diancie', 4}},
		RBeastTrio = {
			{'Raikou',  3},
			{'Entei',   3},
			{'Suicune', 3}},

		Regice = {{'Regice', 4}},
		Regirock = {{'Regirock', 4}},
		Registeel = {{'Registeel', 4}},
		Regigigas = {{'Regigigas', 3}},

		Volcanion = {{'Volcanion', 4}},

		Mew = {{'Mew',  4}},

		SwordsOJ = {{'Cobalion', 3}, {'Terrakion', 3}, {'Virizion', 3}},
		Keldeo = {{'Keldeo', 4}},

		Genesect = {{'Genesect', 4}},

		Groudon = {{'Groudon', 2}},

		EonDuo = {{'Latios',  3}, {'Latias ', 3}},


	}
}

chunks.encounterLists = encounterLists
return chunks