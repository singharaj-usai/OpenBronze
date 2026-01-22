local Common    = 1
local Uncommon  = 2
local Rare      = 3
local UltraRare = 4
local Legendary = 5

local pColors = {
	{'Maroon',    Color3.fromRGB(107, 0, 0)},
	{'Red',       Color3.fromRGB(255, 0, 0)},
	{'Orange',    Color3.fromRGB(255, 106, 0)},
	{'Tan',       Color3.fromRGB(211, 162, 110)},
	{'Brown',     Color3.fromRGB(99, 64, 27)},
	{'Yellow',    Color3.fromRGB(255, 216, 0)},
	{'Gold',      Color3.fromRGB(206, 174, 82)},
	{'Green',     Color3.fromRGB(0, 255, 0)},
	{'DarkGreen', Color3.fromRGB(0, 151, 14)},
	{'SkyBlue',   Color3.fromRGB(0, 255, 255)},
	{'Cyan',      Color3.fromRGB(0, 174, 200)},
	{'NavyBlue',  Color3.fromRGB(0, 0, 110)},
	{'Purple',    Color3.fromRGB(78, 0, 255)},
	{'Magenta',   Color3.fromRGB(159, 0, 255)},
	{'Pink',      Color3.fromRGB(255, 0, 255)},
	{'Grey',      Color3.fromRGB(125, 125, 125)},
	{'White',     Color3.fromRGB(255, 255, 255)},
	{'Black',     Color3.fromRGB(0, 0, 0)},
	{'NoColor',   Color3.fromRGB(255, 255, 255)},
	{'Rainbow',   Color3.fromRGB(255, 255, 255)},
	--# !!! ADD NEW COLORS HERE ONLY !!! #--
}

local sheets = {
	[1] = {
		Id = 5267721157,--5267724827,
		Particles = {
			[1] = {
				Name = 'Bubble',
				Colors = {
					SkyBlue = Common,
					Cyan = Common,
					NavyBlue = Common,
					Purple = Rare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[2] = {
				Name = 'Bone',
				Colors = {
					Grey = Uncommon,
					Tan = Rare,
					Maroon = UltraRare,
					Gold = UltraRare
				}
			},
			[3] = {
				Name = 'Bug',
				Colors = {
					Grey = Uncommon,
					DarkGreen = Rare,
					NavyBlue = Rare,
					Gold = UltraRare
				}
			},
			[4] = {
				Name = 'Confetti',
				Colors = {
					Red = Uncommon,
					SkyBlue = Uncommon,
					Green = Uncommon,
					Pink = Uncommon,
					Orange = Uncommon,
					Yellow = Uncommon,
					Purple = Uncommon,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[5] = {
				Name = 'Feather',
				Colors = {
					Grey = Common,
					SkyBlue = Uncommon,
					Magenta = Rare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[6] = {
				Name = 'Flame',
				Colors = {
					Orange = Common,
					Yellow = Common,
					Red = Uncommon,
					NavyBlue = Rare,
					SkyBlue = Rare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[7] = {
				Name = 'Leaf',
				Colors = {
					DarkGreen = Common,
					Brown = Common,
					Yellow = Uncommon,
					Orange = Uncommon,
					Red = Rare,
					Gold = UltraRare,
					Pink = UltraRare,
					Rainbow = Legendary
				}
			},
			[8] = {
				Name = 'Orb',
				Colors = {
					Red = Common,
					Green = Common,
					SkyBlue = Common,
					Orange = Common,
					Yellow = Common,
					Purple = Common,
					Maroon = Uncommon,
					Cyan = Uncommon,
					Pink = Uncommon,
					NavyBlue = Rare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[9] = {
				Name = 'Lightning',
				Colors = {
					Yellow = Common,
					Cyan = Rare,
					NavyBlue = Rare,
					Maroon = Rare,
					Pink = UltraRare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[10] = {
				Name = 'Note',
				Colors = {
					Red = Common,
					Green = Common,
					SkyBlue = Common,
					Orange = Common,
					Yellow = Common,
					Purple = Common,
					Black = Common,
					DarkGreen = Uncommon,
					NavyBlue = Uncommon,
					Pink = Uncommon,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[11] = {
				Name = 'Radioactive',
				Colors = {
					Yellow = Uncommon,
					Black = Uncommon,
					Purple = Uncommon,
					NavyBlue = Rare,
					Green = Rare,
					Pink = UltraRare,
					Gold = UltraRare,
					Rainbow = Legendary,
				}
			},
			[12] = {
				Name = 'Toxic',
				Colors = {
					Yellow = Uncommon,
					Black = Uncommon,
					Purple = Uncommon,
					NavyBlue = Rare,
					Green = Rare,
					Pink = UltraRare,
					Gold = UltraRare,
					Rainbow = Legendary,
				}
			},
			[13] = {
				Name = 'Sand',
				Colors = {
--					Tan = Uncommon
				}
			},
			[14] = {
				Name = 'Skull',
				Colors = {
					Tan = Rare,
					Grey = Rare,
					Maroon = UltraRare,
					NavyBlue = UltraRare,
					Magenta = UltraRare,
					Pink = UltraRare,
					Gold = Legendary,
					Rainbow = Legendary
				}
			},
			[15] = {
				Name = 'Smoke',
				Colors = {
					Grey = Common,
					Tan = Uncommon,
					Maroon = Rare,
					NavyBlue = Rare,
					DarkGreen = Rare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[16] = {
				Name = 'Snowflake',
				Colors = {
					White = Common,
					SkyBlue = Common,
					Cyan = Uncommon,
					NavyBlue = Uncommon,
					Maroon = Rare,
					Pink = UltraRare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[17] = {
				Name = 'Water',
				Colors = {
					NavyBlue = Common,
					Cyan = Common,
					SkyBlue = Uncommon,
					Purple = Rare,
					DarkGreen = Rare,
					Pink = UltraRare,
					Gold = UltraRare,
					Rainbow = UltraRare
				}
			},
			[18] = {
				Name = 'Ghost',
				Colors = {
					Purple = Rare,
					NavyBlue = Rare,
					Maroon = Rare,
					Green = Rare,
					Cyan = UltraRare,
					Pink = UltraRare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[19] = {
				Name = 'Atom',
				Colors = {
					Red = Uncommon,
					Cyan = Uncommon,
					Yellow = Uncommon
				}
			},	
			[20] = {
				Name = 'Boulder',
				Colors = {
					Brown = Common,
					Gold = UltraRare
				}
			},
			[21] = {
				Name = 'Chip',
				Colors = {
					NoColor = Legendary
				}
			},
			[22] = {
				Name = 'Crystal',
				Colors = {
					SkyBlue = Common,
					Green = Common,
					Red = Common,
					Purple = Uncommon,
					Yellow = Uncommon,
					Orange = Uncommon,
					NavyBlue = Rare,
					Maroon = Rare,
					Magenta = Rare,
					Pink = UltraRare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[23] = {
				Name = 'Flower',
				Colors = {
					Green = Common,
					Cyan = Common,
					Red = Common,
					Yellow = Common,
					Orange = Common,
					Pink = Rare,
					Magenta = Rare,
					Rainbow = Legendary				
				}
			},
			[24] = {
				Name = 'Gear',
				Colors = {
					Grey = Common,
					Cyan = Rare,
					Gold = UltraRare
				}
			},
			[25] = {
				Name = 'Cosmic',
				Colors = {
--					NavyBlue = Uncommon,
--					Maroon = Uncommon,
--					Purple = Uncommon,
--					Magenta = Uncommon,
--					Green = Uncommon,
--					Yellow = Uncommon
				}
			},
		}
	},
	[2] = {
		Id = 677876170,--674329675,
		Particles = {
			[1] = {
				Name = 'Shuriken',
				Colors = {
					Grey = Uncommon,
					Cyan = Rare,
					Gold = UltraRare
				}
			},
			[2] = {
				Name = 'Star',
				Colors = {
					Red = Common,
					Orange = Common,
					Yellow = Common,
					Green = Common,
					SkyBlue = Common,
					Purple = Common,
					Pink = Rare,
					Gold = Rare,
					Rainbow = Legendary
				}
			},
			[3] = {
				Name = 'Paw',
				Colors = {
					Brown = Uncommon,
					Gold = Rare
				}
			},
			[4] = {
				Name = 'Pok[e\'] Ball',
				Colors = {
					NoColor = Legendary
				}
			},
			[5] = {
				Name = 'Ring',
				Colors = {
					Red = Common,
					SkyBlue = Common,
					Yellow = Common,
					Green = Common,
					Orange = Common,
					Purple = Common,
					Maroon = Rare,
					NavyBlue = Rare,
					DarkGreen = Rare,
					Pink = UltraRare,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
			[6] = {
				Name = 'Spiral',
				Colors = {
					Red = Common,
					Orange = Common,
					Yellow = Common,
					Green = Common,
					Cyan = Common,
					Purple = Common,
					NavyBlue = Uncommon,
					Maroon = Uncommon,
					Gold = UltraRare,
					Rainbow = Legendary						
				}
			},
			[7] = {
				Name = 'Twister',
				Colors = {
					Brown = Common,
					Cyan = Uncommon,
					NavyBlue = Rare,
					Maroon = UltraRare
				}
			},
			[8] = {
				Name = 'Heart',
				Colors = {
					Pink = Common,
					Red = Uncommon,
					Orange = Uncommon,
					Yellow = Uncommon,
					Green = Uncommon,
					SkyBlue = Uncommon,
					Purple = Uncommon,
					Gold = UltraRare,
					Rainbow = Legendary
				}
			},
		}
	},
}

local stampData = {
	sheetIds = {},
	colorNumToName = {},
	colorNameToNum = {},
	colors = {},
	tiers = {{},{},{},{},{}},
	db = sheets
}

for i, colorPair in pairs(pColors) do
	local colorName, color3 = unpack(colorPair)
	stampData.colorNumToName[i] = colorName
	stampData.colorNameToNum[colorName] = i
	stampData.colors[i] = color3
end

for sheetNum, sheetData in pairs(sheets) do
	stampData.sheetIds[sheetNum] = sheetData.Id
	for particleNum, particleData in pairs(sheetData.Particles) do
		local particleName = particleData.Name
		for colorName, tier in pairs(particleData.Colors) do
			local colorNum = stampData.colorNameToNum[colorName]
			if colorNum then
				table.insert(stampData.tiers[tier], {
					name = particleName,
					sheet = sheetNum,
					n = particleNum,
					color = colorNum
				})
			else
				spawn(function() error('invalid color "'..colorName..'" for particle "'..particleName..'"') end)
			end
		end
	end
end


return stampData