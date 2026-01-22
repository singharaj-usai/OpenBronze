print("MiningItems")
local o = false
local x = true
local items = {
	{
		ItemId = 'oddkeystone',
		Chance = 1,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(19, 1),		
	}, {
		ItemId = 'leafstone',
		Chance = 1,
		Size = Vector2.new(3, 4),
		Position = Vector2.new(23, 1),
		OccupiedSlots = {
			{o, x, o},
			{x, x, x},
			{x, x, x},
			{o, x, o},
		}
	}, {
		ItemId = 'firestone',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(26, 1),
	}, {
		ItemId = 'waterstone',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(29, 1),
		OccupiedSlots = {
			{x, x, x},
			{x, x, x},
			{x, x, o},
		}
	}, {
		ItemId = 'thunderstone',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(19, 5),
		OccupiedSlots = {
			{o, x, x},
			{x, x, x},
			{x, x, o},
		}
	}, {
		ItemId = 'moonstone',
		Chance = 1,
		Size = Vector2.new(4, 2),
		Position = Vector2.new(22, 5),
		OccupiedSlots = {
			{o, x, x, x},
			{x, x, x, o},
		}
	}, {
		ItemId = 'sunstone',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(26, 4),
		OccupiedSlots = {
			{o, x, o},
			{x, x, x},
			{x, x, x},
		}
	}, {
		ItemId = 'revive',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(29, 4),
		OccupiedSlots = {
			{o, x, o},
			{x, x, x},
			{o, x, o},
		}
	}, {
		ItemId = 'maxrevive',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(19, 8),
	}, {
		ItemId = 'starpiece',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(22, 7),
		OccupiedSlots = {
			{o, x, o},
			{x, x, x},
			{o, x, o},
		}
	}, {
		ItemId = 'damprock',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(25, 7),
		OccupiedSlots = {
			{x, x, x},
			{x, x, x},
			{x, o, x},
		}
	}, {
		ItemId = 'icyrock',
		Chance = 1,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(28, 7),
		OccupiedSlots = {
			{o, x, x, o},
			{x, x, x, x},
			{x, x, x, x},
			{x, o, o, x},
		}
	}, {
		ItemId = 'heatrock',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(23, 10),
		OccupiedSlots = {
			{x, o, x, o},
			{x, x, x, x},
			{x, x, x, x},
		}
	}, {
		ItemId = 'smoothrock',
		Chance = 1,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(9, 26),
		OccupiedSlots = {
			{o, o, x, o},
			{x, x, x, o},
			{o, x, x, x},
			{o, x, o, o},
		}
	}, {
		ItemId = 'heartscale',
		Chance = 1,
		Size = Vector2.new(2, 2),
		Position = Vector2.new(17, 11),
		OccupiedSlots = {
			{x, o},
			{x, x},
		}
	}, {
		ItemId = 'everstone',
		Chance = 1,
		Size = Vector2.new(4, 2),
		Position = Vector2.new(19, 11),
	}, {
		ItemId = 'insectplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(1, 13),
	}, {
		ItemId = 'dreadplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(5, 13),
	}, {
		ItemId = 'dracoplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(9, 13),
	}, {
		ItemId = 'zapplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(13, 13),
	}, {
		ItemId = 'fistplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(17, 13),
	}, {
		ItemId = 'flameplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(21, 13),
	}, {
		ItemId = 'skyplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(25, 13),
	}, {
		ItemId = 'meadowplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(1, 16),
	}, {
		ItemId = 'earthplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(5, 16),
	}, {
		ItemId = 'icicleplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(9, 16),
	}, {
		ItemId = 'toxicplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(13, 16),
	}, {
		ItemId = 'mindplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(17, 16),
	}, {
		ItemId = 'stoneplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(21, 16),
	}, {
		ItemId = 'ironplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(25, 16),
	}, {
		ItemId = 'spookyplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(1, 19),
	}, {
		ItemId = 'splashplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(5, 19),
	}, {
		ItemId = 'pixieplate',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(9, 19),
	}, {
		ItemId = 'rarebone',
		Chance = 1,
		Size = Vector2.new(3, 6),
		Position = Vector2.new(29, 13),
		OccupiedSlots = {
			{x, x, x},
			{o, x, o},
			{o, x, o},
			{o, x, o},
			{o, x, o},
			{x, x, x},
		}
	}, {
		ItemId = 'greenshard',
		Chance = 1,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(13, 19),
		OccupiedSlots = {
			{x, x, x, x},
			{x, x, x, x},
			{x, x, o, x},
		}
	}, {
		ItemId = 'redshard',
		Chance = 22,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(17, 19),
		OccupiedSlots = {
			{x, x, x},
			{x, x, o},
			{x, x, x},
		}
	}, {
		ItemId = 'blueshard',
		Chance = 22,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(20, 19),
		OccupiedSlots = {
			{x, x, x},
			{x, x, x},
			{x, x, o},
		}
	}, {
		ItemId = 'yellowshard',
		Chance = 22,
		Size = Vector2.new(4, 3),
		Position = Vector2.new(23, 19),
		OccupiedSlots = {
			{x, o, x, o},
			{x, x, x, o},
			{x, x, x, x},
		}
	}, {
		ItemId = 'rootfossil',
		Chance = 4,
		Size = Vector2.new(5, 5),
		Position = Vector2.new(27, 19),
		OccupiedSlots = {
			{x, x, x, x, o},
			{x, x, x, x, x},
			{x, x, o, x, x},
			{o, o, o, x, x},
			{o, o, x, x, o},
		}
	}, {
		ItemId = 'skullfossil',
		Chance = 4,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(1, 22),
		OccupiedSlots = {
			{x, x, x, x},
			{x, x, x, x},
			{x, x, x, x},
			{o, x, x, o},
		}
	}, {
		ItemId = 'armorfossil',
		Chance = 1,
		Size = Vector2.new(5, 4),
		Position = Vector2.new(5, 22),
		OccupiedSlots = {
			{o, x, x, x, o},
			{o, x, x, x, o},
			{x, x, x, x, x},
			{o, x, x, x, o},
		}
	}, {
		ItemId = 'domefossil',
		Chance = 1,
		Size = Vector2.new(5, 4),
		Position = Vector2.new(10, 22),
		OccupiedSlots = {
			{x, x, x, x, x},
			{x, x, x, x, x},
			{x, x, x, x, x},
			{o, x, x, x, o},
		}
	}, {
		ItemId = 'helixfossil',
		Chance = 1,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(15, 22),
		OccupiedSlots = {
			{o, x, x, x},
			{x, x, x, x},
			{x, x, x, x},
			{x, x, x, o},
		}
	}, {
		ItemId = 'clawfossil',
		Chance = 1,
		Size = Vector2.new(5, 4),
		Position = Vector2.new(19, 22),
		OccupiedSlots = {
			{x, x, x, o, o},
			{x, x, x, x, o},
			{o, x, x, x, x},
			{o, o, o, x, x},
		}
	}, {
		ItemId = 'coverfossil',
		Chance = 1,
		Size = Vector2.new(5, 5),
		Position = Vector2.new(23, 28),--16, 26),
		OccupiedSlots = {
			{o, x, x, x, x},
			{x, x, x, x, x},
			{x, x, x, x, x},
			{x, x, x, x, x},
			{o, o, x, x, o},
		}
	}, {
		ItemId = 'plumefossil',
		Chance = 1,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(29, 24),
	}, {
		ItemId = 'jawfossil',
		Chance = 1,
		Size = Vector2.new(5, 5),
		Position = Vector2.new(28, 28),--21, 26),
		OccupiedSlots = {
			{o, x, x, x, x},
			{o, x, x, x, x},
			{x, x, x, x, x},
			{x, x, x, x, x},
			{o, x, x, o, o},
		}
	}, {
		ItemId = 'sailfossil',
		Chance = 1,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(13, 29)--28, 28),
	}, {
		ItemId = 'oldamber',
		Chance = 1,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(1, 26),
		OccupiedSlots = {
			{x, x, x, o},
			{x, x, x, x},
			{x, x, x, x},
			{o, x, x, x},
		}
	}, {
		ItemId = 'ironball',
		Chance = 8,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(24, 22),
	}, {
		ItemId = 'lightclay',
		Chance = 10,
		Size = Vector2.new(4, 4),
		Position = Vector2.new(5, 26),
		OccupiedSlots = {
			{x, o, x, o},
			{x, x, x, o},
			{x, x, x, x},
			{o, x, o, x},
		}
	}, {
		ItemId = 'ovalstone',
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(13, 26),
	}, {
		ItemId = 'hardstone',
		Chance = 1,
		Size = Vector2.new(2, 2),
		Position = Vector2.new(24, 25)--11, 30),
	}, {
		IsEgg = true,
		Chance = 1,
		Size = Vector2.new(5, 5),
		Position = Vector2.new(17, 26),
		OccupiedSlots = {
			{x, x, x, x, x},
			{x, x, x, x, x},
			{x, x, x, x, x},
			{x, x, x, x, x},
			{x, x, x, o, o},
		}
	}
}
--	local t = 0
--	for _, item in pairs(items) do
--		if item.ItemId then
--			item.ItemId = rc4(item.ItemId)
--		end
----		t = t + item.Chance
--	end
--	print('total mining weight:', t)
local irons = {
	{ -- S
		Chance = 2,
		Size = Vector2.new(3, 2),
		Position = Vector2.new(27, 11),
		OccupiedSlots = {
			{o, x, x},
			{x, x, o},
		}
	}, { -- 2x2 square
		Chance = 2,
		Size = Vector2.new(2, 2),
		Position = Vector2.new(30, 11),
	}, { -- 2x4 rect
		Chance = 1,
		Size = Vector2.new(4, 2),
		Position = Vector2.new(1, 30),
	}, { -- Z
		Chance = 2,
		Size = Vector2.new(3, 2),
		Position = Vector2.new(5, 30),
		OccupiedSlots = {
			{x, x, o},
			{o, x, x},
		}
	}, { -- T
		Chance = 2,
		Size = Vector2.new(3, 2),
		Position = Vector2.new(8, 30),
		OccupiedSlots = {
			{x, x, x},
			{o, x, o},
		}
	}, { -- 3x3 square
		Chance = 1,
		Size = Vector2.new(3, 3),
		Position = Vector2.new(26, 25)--13, 29),
	}, { -- 1x4 rect
		Chance = 2,
		Size = Vector2.new(4, 1),
		Position = Vector2.new(1, 32)--16, 31),
	}
}

local fossilEggs = {
	{'Togepi', 85},
	{'Uxie',    5},
	{'Mesprit', 5},
	{'Azelf',   5},
}

return {items, irons, fossilEggs}