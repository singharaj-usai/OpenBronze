print("DS")
--[[
	TODO:
	Make alt formes auto-fill in extra data like EV Yield, evolution, etc.
	
	
	rc4'd:
	DataManager.Chunk - #Item.Value (right?)
	Menu.Bag.selectionId
	BPShop
--]]

local _f = require(script.Parent)


local DataService = {
	playerspam = {} -- checkspam
} -- todo: convert to Database

local Database = {
	PokemonByNumber = {},
	MoveByNumber = {},
	ItemByNumber = {},
	Evolution = {},
}
_f.Database = Database -- installed manually here for now -> eventually will replace DataService entirely

local debug = false

local players = game:GetService('Players')
local storage = game:GetService('ServerStorage')
--local repStorage = game:GetService('ReplicatedStorage')

local toId, rc4, shallowcopy, deepcopy; do
	local util = _f.Utilities--require(storage:WaitForChild('Utilities'))
	toId = util.toId
	rc4 = util.rc4
	shallowcopy = util.shallowcopy
	deepcopy = util.deepcopy
end

local indoorOrigins = {{},{},{},{},{}}
local data = {
	storage.Data.Spritesheets,
	storage.Data.Chunks,
	storage.Data.ObtainableItems,
	storage.Data.Trainers,
	storage.BattleData.Pokedex,
	storage.BattleData.Movedex,
	storage.BattleData.Items,

	storage.Data.boardFns,

}

local startTime, startMemory = tick(), collectgarbage('count')
do
	local d = {}
	for _, m in pairs(data) do
		if debug then print('loading data module "'..m.Name..'"') end
		d[m.Name] = require(m)
	end
	data = d
	if debug then print('data modules loaded') end
end

do -- Database Setup
	Database.ChunkData = data.Chunks
	Database.Spritesheets = data.Spritesheets

	Database.PokemonById = data.Pokedex -- use sparingly...?
	Database.MoveById = data.Movedex
	Database.ItemById = data.Items
	local numbase = Database.PokemonByNumber
	for _, d in pairs(data.Pokedex) do
		if not d.baseSpecies then -- should move formes to sub-table of baseSpecies
			numbase[d.num] = d
		end
	end
	numbase = Database.MoveByNumber
	for _, d in pairs(data.Movedex) do
		numbase[d.num] = d
	end
	--	Database.ItemByNumber installed later

	Database.boardFns = data.boardFns


	--	local ids = {}
	--	local n = 0
	--	for name, t in pairs(data.Trainers.TrainerClassData) do
	--		if t.EyesMeetMusic then
	--			if ids[t.EyesMeetMusic] then
	--				table.insert(ids[t.EyesMeetMusic], name)
	--			else
	--				ids[t.EyesMeetMusic] = {name}
	--				n = n + 1
	--			end
	--		end
	--	end
	--	print(n, 'eyes meet musics:')
	--	for id, list in pairs(ids) do
	--		print(id)
	--		for _, name in pairs(list) do
	--			print('    '..name)
	--		end
	--	end
end


do -- Data Setup
	local cryIds = { 12639700673, 9543564359, 9543567526, 18856405932, 9543569476,--cr1, cr2, cr3, cr4, cr5 replace/reupload
		9543570404, 9543571221, 9543572416, 9543573754, 9543574531,--cr6, cr7, cr8, cr9, crr10
		9543575512, 9543910274, 9543911046, 9543912919, 9543913697,--cr11, cr12, cr13, 14, altcry15
		--620418262, 620418671, 6577951711 
		9543914580, 9543915520, 138345106993428 }--cr16, cr17, cr18
	local cryData = require(storage.Data.Cries)
	data.PokedexExtended = {}
	do
		local f, b, sf, sb = data.Spritesheets._FRONT, data.Spritesheets._BACK, data.Spritesheets._SHINY_FRONT, data.Spritesheets._SHINY_BACK
		-- install misc pokedex data and cries
		for _, d in pairs(require(storage.Data.PokedexMisc)) do
			local p = data.Pokedex[d.identifier]
			if p then
				p.captureRate = d.capture_rate
				p.baseHappiness = d.base_happiness
				p.eggCycles = d.hatch_counter
				if d.egg_icon then
					p.eggIcon = d.egg_icon
				end
				data.PokedexExtended[d.identifier] = {desc = d.flavor_text, class = d.classification}
				local rates = {4, 2, 1, 3, 0, 5}--mediumslow, mediumfast, slow, fast, fluctuating, erratic
				p.expRate = rates[d.growth_rate_id]
				if f[p.species] then
					local cry = cryData[p.num]
					if cry and cry.num == p.num then
						local c = { id = cryIds[cry.soundId], startTime = cry.startTime, duration = cry.duration }
						f[p.species].cry = c
						if b[p.species] then b[p.species].cry = c else warn('no back for', p.species) end
						if sf[p.species] then sf[p.species].cry = c else warn('no shiny front for', p.species) end
						if sb[p.species] then sb[p.species].cry = c else warn('no shiny back for', p.species) end
					else
						warn('cry data num mismatch')
					end
				else
					warn('no front for', p.species)
				end
			else
				warn('did not find pokedex entry for '..d.identifier)
			end
		end
		-- install cries to alt formes; copy inAir values to others
		for id, sprite in pairs(f) do
			local sprites = {sprite, b[id], sf[id], sb[id]}
			for _, sprite in pairs(sprites) do
				if sprite.inAir then
					for _, otherSprite in pairs(sprites) do
						if not otherSprite.inAir then
							otherSprite.inAir = sprite.inAir
						end
					end
					break
				end
			end
			if id:lower() ~= 'ho-oh' and id:lower() ~= 'porygon-z' then
				local baseId = id:match('^(.+)[_%-][^_%-]+$')
				if baseId then
					local cry
					local s = pcall(function() cry = f[baseId].cry end)
					if s and cry then
						sprite.cry = cry
						if b[id] then b[id].cry = cry else warn('no back for', id) end
						if sf[id] then sf[id].cry = cry else warn('no shiny front for', id) end
						if sb[id] then sb[id].cry = cry else warn('no shiny back for', id) end
					else
						warn('no cry for', id)
					end
				end
			end
		end
		-- install special alt cries
		for _, c in pairs(require(storage.Data.Cries.AltCries)) do
			local id = c.soundName
			if f[id] then
				local cry = { id = cryIds[c.soundId], startTime = c.startTime, duration = c.duration }
				f[id].cry = cry
				if b[id] then b[id].cry = cry else warn('no back for', id) end
				if sf[id] then sf[id].cry = cry else warn('no shiny front for', id) end
				if sb[id] then sb[id].cry = cry else warn('no shiny back for', id) end
			else
				--				warn('sprite not found:', id, '(installing alt cry)') -- those which are not found are currently ignored
			end
		end
	end
	-- make scaled copies of pumpkaboo/gourgeist formes
	for _, s in pairs(data.Spritesheets) do
		local p = s.Pumpkaboo
		s['Pumpkaboo-small'] = deepcopy(p)
		s['Pumpkaboo-small'].scale = .8
		s['Pumpkaboo-large'] = deepcopy(p)
		s['Pumpkaboo-large'].scale = 1.0
		s['Pumpkaboo-super'] = deepcopy(p)
		s['Pumpkaboo-super'].scale = 1.1
		p.scale = .9
		local g = s.Gourgeist
		s['Gourgeist-small'] = deepcopy(g)
		s['Gourgeist-small'].scale = .8
		s['Gourgeist-large'] = deepcopy(g)
		s['Gourgeist-large'].scale = 1.0
		s['Gourgeist-super'] = deepcopy(g)
		s['Gourgeist-super'].scale = 1.1
		g.scale = .9
	end
	do -- evolution
		local Evolution = Database.Evolution
		local multi = {}
		for _, d in pairs(require(storage.Data.Evolution)) do
			--			if d.location_id then print(d.evolved_species_id, 'evolves at location', d.location_id) end
			local found = false
			local pokemon = Database.PokemonByNumber[d.evolved_species_id]
			if pokemon and pokemon.prevo then
				local prevo = data.Pokedex[pokemon.prevo]
				if prevo then
					local evos = Evolution[prevo.num]
					if evos then
						multi[evos] = true
					else
						evos = {}
						Evolution[prevo.num] = evos
					end
					evos[#evos+1] = d
					found = true
				end
			end
			if not found then
				warn('unable to file evolution data for pokemon number '..d.evolved_species_id)
			end
		end
		for evo in pairs(multi) do
			table.sort(evo, function(a, b) return (a.priority or 0) > (b.priority or 0) end)
		end
	end
	-- copy evolution data to pumpkaboo formes
	--	local pe = data.Pokedex.pumpkaboo.evolution
	--	data.Pokedex.pumpkaboosmall.evolution = deepcopy(pe)
	--	data.Pokedex.pumpkaboolarge.evolution = deepcopy(pe)
	--	data.Pokedex.pumpkaboosuper.evolution = deepcopy(pe)
	--
	for _, d in pairs(require(storage.Data.Experience)) do
		local p = data.Pokedex[d.identifier]
		if p then
			p.baseExp = d.exp
			p.evYield = {d.hp, d.atk, d.def, d.spa, d.spd, d.spe}
		else
			warn('did not find pokedex entry for '..d.identifier)
		end
	end
	-- copy extra data to alt formes
	-- note that evolution is NOT copied automatically
	for _, entry in pairs(data.Pokedex) do
		local baseSpecies = entry.baseSpecies
		if baseSpecies then
			local baseEntry = data.Pokedex[toId(baseSpecies)]
			for _, key in pairs({'baseExp', 'evYield', 'captureRate', 'baseHappiness', 'eggCycles', 'eggIcon', 'expRate'}) do
				if not entry[key] then
					entry[key] = baseEntry[key]
				end
			end
		end
	end
	-- install move descriptions
	for m in string.gmatch(require(storage.Data.MoveDesc), '[^\n]+') do
		--		print(m)
		local name, desc = m:match('^([^,]+),(.*)$')
		local move = data.Movedex[name:lower()]
		if move then
			move.desc = desc
		else
			warn('did not find move data for '..name:lower())
		end
	end
	-- Item Metadata
	for _, d in pairs(require(storage.Data.ItemMeta)) do
		local id = toId(d.name)
		local item = data.Items[id]
		if item then
			local num = tonumber(d.item_id)
			item.num = num
			Database.ItemByNumber[num] = item -- here we install items by number
			if not item.name then
				item.name = d.name
			end
			if d.bag_kind then
				item.bagCategory = tonumber(d.bag_kind)
			end
			if d.battle_kind then
				item.battleCategory = tonumber(d.battle_kind)
			end
			item.sellPrice = d.sell_price
			item.desc = d.desc
		else
			--			warn('No core Item data for ' .. id)
			if d.name and d.name:sub(1,1) ~= '[' then
				local item = {
					name = d.name,
					id = id,
					num = tonumber(d.item_id),
					bagCategory = d.bag_kind and tonumber(d.bag_kind),
					battleCategory = d.battle_kind and tonumber(d.battle_kind),
					desc = d.desc,
					sellPrice = d.sell_price,
				}
				data.Items[id] = item
				Database.ItemByNumber[item.num] = item
			end
		end
	end
	for id, item in pairs(data.Items) do
		item.id = id
		--		if not item.num then
		--			warn('No numeric id [num] for Item ' .. id)
		--		end
		--		if not item.fling and not item.isBerry and not item.onPlate and not item.onDrive and not item.megaStone then
		--			warn('no fling data for item ' .. id)
		--		end
	end
	do
		local machines = {tms = {}, hms = {}}
		for _, d in pairs(require(storage.Data.TMs)) do
			local moveId = toId(d.move)
			if moveId ~= 'null' then
				local n = tonumber(d.tm)
				if n > 110 then
					machines.hms[n-110] = moveId
				else
					machines.tms[n]     = moveId
				end
			end
		end
		Database.Machines = machines--data.TMs = {all = machines}
		--		print(#machines.tms)
	end
	--	for _, battle in pairs(data.Trainers.Battles) do
	--		for _, pokemon in pairs(battle.Party) do
	--			pokemon.name = rc4(pokemon.name, true)
	--		end
	--	end
end

-- OVH  store pokemon / moves / items by num in array for fast lookup

Database.LearnedMoves = require(storage.Data.LearnedMovesLiteral)
Database.GalarFormMoves = require(storage.Data.GalarFormMoves)

Database.FemaleMeowsticLearnedMoves = {levelUp={{1,500,382,345,10,43},{5,343},{9,93},{13,113},{17,60},{19,252},{22,574},{25,473},{28,451},{31,247},{35,326},{40,94},{43,272},{45,324},{48,389},{50,248},{53,500}},machine={15,63,85,86,91,92,94,104,113,115,138,148,156,164,173,182,207,213,214,215,216,218,219,231,237,240,241,244,247,259,263,270,271,272,277,278,289,290,324,343,347,351,356,371,399,412,416,428,433,451,472,473,478,496,497,590,612}}
Database.FemaleIndeedeeLearnedMoves = {levelUp={{1,589,500},{5,226},{10,574},{15,60},{20,270},{25,266},{30,312},{35,94},{40,347},{45,470},{50,678},{55,361}},machine={6,345,113,115,219,156,173,182,213,263,129,270,286,385,409,496,577,678,595}}


Database.ShayminSkyLearnedMoves = {levelUp={{1,74},{10,345},{19,73},{28,98},{37,230},{46,363},{55,388},{64,403},{73,412},{82,186},{91,437},{100,465},},machine={14,63,76,92,94,104,148,156,164,173,182,202,207,214,216,218,219,235,237,241,244,263,267,283,290,343,387,388,402,412,414,416,428,447,496,590,605}}

Database.IceriderCalyrexLearnedMoves = {evolve=68,levelUp={{1,44,68,104,203,43,179,28,33,269},{4,28},{7,44},{12,336},{15,88},{18,316},{23,317},{26,46},{29,446},{34,157},{37,184},{40,242},{45,431},{48,444}},machine={5,25,7,9,416,156,157,173,182,184,213,201,263,279,280,317,350,371,422,424,490,496,555,707}} -- need to change these

Database.ShadowriderCalyrexLearnedMoves = {evolve=68,levelUp={{1,44,68,104,203,43,179,28,33,269},{4,28},{7,44},{12,336},{15,88},{18,316},{23,317},{26,46},{29,446},{34,157},{37,184},{40,242},{45,431},{48,444}},machine={5,25,7,9,416,156,157,173,182,184,213,201,263,279,280,317,350,371,422,424,490,496,555,707}} -- need to change these

Database.DarkPalkiaLearnedMoves = {levelUp={{1,225,184},{6,506},{10,246},{15,163},{19,247},{24,242},{28,337},{33,414},{37,396},{42,421},{46,460},{50,399},{61,464}},machine={15,46,53,57,58,59,63,70,85,86,87,89,92,104,126,156,157,164,173,182,200,201,207,214,216,218,219,237,240,241,244,249,258,263,264,280,290,291,304,317,332,337,339,351,352,356,374,401,406,411,414,416,421,433,434,444,468,496,497,510,523,525,590}}
Database.MidnightMoves = {evolve=68,levelUp={{1,44,68,104,203,43,179,28,33,269},{4,28},{7,44},{12,336},{15,88},{18,316},{23,317},{26,46},{29,446},{34,157},{37,184},{40,242},{45,431},{48,444}},machine={5,25,7,9,416,156,157,173,182,184,213,201,263,279,280,317,350,371,422,424,490,496,555,707}}
do
	-- Install Rock Climb as a learnable HM
	local lm = Database.LearnedMoves
	local rockClimbMoveNum = 431
	local function addMoveToList(moveNum, list)
		if not list then return end
		if list.machine then
			table.insert(list.machine, moveNum)
		else
			list.machine = {moveNum}
		end
	end
	local already = {}
	for _, num in pairs({
		--[[ Could learn in Gen 4 from HM ]]3, 9, 27, 28, 31, 34, 55, 56, 57, 59, 62, 66, 67, 68, 74, 75, 76, 95, 104, 105, 106, 107, 108, 111, 112, 113, 115, 125, 126, 127, 128, 139, 141, 143, 150, 151, 154, 157, 160, 181, 208, 210, 217, 242, 243, 244, 245, 248, 254, 257, 260, 272, 288, 289, 295, 296, 297, 306, 335, 377, 378, 379, 383, 387, 388, 389, 390, 391, 392, 395, 400, 408, 409, 443, 444, 445, 446, 448, 452, 453, 454, 460, 463, 464, 466, 467, 473, 485, 486, 487, 487, 491, 493,
		--[[ Can learn in Gen 7 by level+ ]]543, 544, 545, 559, 560, 598, 621, 744, 745, 720,
		--[[ Can learn in Gen 7 by breed  ]]27, 28, 74, 75, 76, 95, 111, 112, 207, 208, 263, 264, 399, 400, 443, 444, 445, 464, 472, 529, 530, 543, 544, 545, 551, 552, 553, 595, 596, 597, 598, 626, 632,
		--[[ Manually added by me;  Gen 5 ]]499, 500, 512, 514, 516, 526, 530, 533, 534, 538, 539, 552, 553, 560, 565, 571, 610, 611, 612, 614, 620, 621, 623, 638, 639, 640, 641, 642, 643, 644, 645, 647, --[[ Gen 6 ]]651, 652, 657, 658, 660, 668, 672, 673, 675, 689, 695, 696, 697, 701, 718, --[[ Gen 7 ]]727, 735, 740, 760, 765, 766, 768, 783, 784, 791, 794, 800
		}) do
		if not already[num] then
			already[num] = true
			addMoveToList(rockClimbMoveNum, lm[num])
		end
	end
	-- todo: add to Alolan Geodude, Graveler, Golem


	-- Install Aurora Veil as a learnable TM
	local auroraVeilMoveNum = 694
	-- note that the Alolan formes are already set for this; it's just old pokemon that need it
	for _, num in pairs({124, 144, 151, 225, 238, 378, 471, 478, 615}) do
		addMoveToList(auroraVeilMoveNum, lm[num])
	end
end



--[[
local function dumpLearnedMoves(moveset)
	print('Moveset dump:')
	if moveset.levelUp then
		print('  Level Up:')
		for _, entry in pairs(moveset.levelUp) do
			print('    Level '..entry[1])
			for i = 2, #entry do
				print('      '..Database.MoveByNumber[entry[i] ].name)
			end
		end
	end
	if moveset.machine then
		print('  Machine:')
		for _, move in pairs(moveset.machine) do
			print('    '..Database.MoveByNumber[move].name)
		end
	end
	if moveset.egg then
		print('  Egg:')
		for _, move in pairs(moveset.egg) do
			print('    '..Database.MoveByNumber[move].name)
		end
	end
end
dumpLearnedMoves(Database.FemaleMeowsticLearnedMoves)--]]

print(string.format('Data set up in %.2f seconds; %.2f MB', tick()-startTime, (collectgarbage('count')-startMemory)/1000))


--_G.GetData = function(d) -- OVH  new database methods
--	return data[d]
--end


local function randomValue(t)
	local keys = {}
	for key in pairs(t) do
		table.insert(keys, key)
	end
	return t[keys[math.random(#keys)]]
end


local grassDataCache = {}

local cachedBattles = {}
local function completeBattle(num, ch)
	local b = cachedBattles[num]
	if b then
		if b.Name then
			ch.Name = b.Name
		end
		return b
	end
	b = data.Trainers.Battles[num]
	if not b then return end
	cachedBattles[num] = b
	--	local b = {}
	--	for k, v in pairs(battle) do
	--		b[k] = v
	--	end
	if not b.TrainerClass and ch and data.Trainers.TrainerClassData[ch.Name] then
		b.TrainerClass = ch.Name
		local name = b.TrainerClass .. ' ' .. b.Name
		b.Name = name
		ch.Name = name
	end
	if b.TrainerClass == 'Eclipse Grunt' then
		b.IconId = 5226446131
		b.musicId = {9536676199, 12639990881}--12639846584
		b.musicVolume = 2
	end
	local trainerDifficulty = b.TrainerDifficulty
	local trainerGender = b.TrainerGender
	if b.TrainerClass then
		local cd = data.Trainers.TrainerClassData[b.TrainerClass]
		b.Payout = b.Party[#b.Party].level * cd.BasePayout
		b.Gender = cd.Gender
		b.EyesMeetMusic = cd.EyesMeetMusic
		trainerGender = cd.Gender
		trainerDifficulty = cd.Difficulty

		b.TrainerDifficulty = trainerDifficulty
		b.TrainerGender = trainerGender
	end
	for pindex, p in pairs(b.Party) do
		if not p.id then
			p.id = toId(p.name)
		end
		local pd = data.Pokedex[p.id]
		if not pd then
			print('No pokedex entry for', p.name)
		end
		--		p.id = rc4(p.id)--, true)
		p.name = nil
		if not p.ivs then
			p.ivs = ({
				{ 6,  6,  6,  6,  6,  6},
				{13, 13, 13, 13, 13, 13},
				{19, 19, 19, 19, 19, 19},
				{25, 25, 25, 25, 25, 25},
				{31, 31, 31, 31, 31, 31},
			})[b.TrainerDifficulty or trainerDifficulty or 1]
		end
		if not p.ability then
			if #pd.abilities == 1 then
				p.ability = pd.abilities[1]
			else
				p.ability = pd.abilities[(p.level+pindex) % 2 + 1]
			end
		end
		if not p.happiness then
			p.happiness = pd.baseHappiness
		end
		if not p.nature then
			local n = {'Hardy',   'Lonely',  'Brave',   'Adamant', 'Naughty', 
				'Bold',    'Docile',  'Relaxed', 'Impish',  'Lax',     
				'Timid',   'Hasty',   'Serious', 'Jolly',   'Naive',   
				'Modest',  'Mild',    'Quiet',   'Bashful', 'Rash',    
				'Calm',    'Gentle',  'Sassy',   'Careful', 'Quirky',  }
			p.nature = n[(pd.num+p.level+b.Name:sub(1,1):byte()) % 25 + 1]
		end
		if not p.gender then
			if pd.genderRate == 0 then
				p.gender = 'M'
			elseif pd.genderRate == 254 then
				p.gender = 'F'
			elseif pd.genderRate == 255 then
				p.gender = ''
			elseif trainerGender then
				p.gender = trainerGender
			else
				p.gender = 'M'
			end
		end
	end
	return b
end

function Database:getBattle(num, dat)
	if dat and dat.gamemode == 'randomizer' then
		return completeBattle(num, nil, true)
	elseif not cachedBattles[num] then
		local battle = data.Trainers.Battles[num]
		if not battle or (not battle.TrainerDifficulty and not battle.TrainerClass) then return end -- means this is meant to be a physical trainer, and no player has been sent this data (exploited?)
		return completeBattle(num)
	end
	return cachedBattles[num]
end

function DataService.fulfillRequest(player, ...)
	if debug then print('request received from', player.Name, '-', ({...})[1][1]) end
	local results = {}
	for i, request in pairs({...}) do
		local v
		local kind = request[1]
		if kind == 'Chunk' then
			local chunkId = request[2]
			local reducedGraphics = request[3] and true or false
			local PlayerData = _f.PlayerDataService[player]
			local lastChunkData

			if PlayerData then
				if PlayerData.currentChunk then
					lastChunkData = data.Chunks[PlayerData.currentChunk]
				end
				PlayerData.currentChunk = chunkId
			end
			local rf = Instance.new('Model')--'Folder')
			local id = Instance.new('StringValue', rf)
			id.Name = 'RequestFor'
			id.Value = player.Name
			local map
			if reducedGraphics then
				pcall(function() map = storage.MapChunks.Mobile[chunkId]:Clone() end)
			end
			if not map then
				local baseMap = storage.MapChunks:FindFirstChild(chunkId)
				--[[
				if not baseMap and not loadedExtraMaps then
					loadedExtraMaps = true
					--
					local lm = game:GetService('InsertService'):LoadAsset(game.CreatorId == 6083112 and 1084073 and 664719910 or 664720287)
					for _, chunk in pairs(lm:GetChildren()) do
						if chunk:IsA('Model') and not storage.MapChunks:FindFirstChild(chunk.Name) then
							chunk.Parent = storage.MapChunks
							local regions = storage.MapChunks.Regions:FindFirstChild(chunk.Name)
							if regions then
								regions.Parent = chunk
								regions.Name = 'Regions'
							end
						end
						if chunk.Name == chunkId then
							baseMap = chunk
						end
					end
					lm:remove()
					--
				end
				--]]
				map = baseMap:Clone()
			end
			-- GRASS
			local grassReplication
			if reducedGraphics then -- Mobile Grass Enabled
				if map:FindFirstChild('MGrass') then -- only remove regular grass if there is mobile grass available
					pcall(function() map.Grass:remove() end)
					for _, g in pairs(map.MGrass:GetChildren()) do
						pcall(function() g.Transparency = 0.0 end)
					end
				end
			else
				pcall(function() map.MGrass:remove() end)
				if map:FindFirstChild('Grass') then
					local grassData = grassDataCache[chunkId]
					if not grassData then
						local function hash(grass)
							local str = tostring(grass.Size) .. '_' .. grass.BrickColor.Number
							local mesh = grass:FindFirstChild('Mesh')
							if mesh then
								if mesh.MeshId ~= '' then
									str = str .. '_' .. string.match(mesh.MeshId, '(%d+)$')
								end
								str = str .. '_' .. tostring(mesh.Scale)
							end
							return str
						end
						local grassModel = storage.MapChunks[chunkId].Grass:Clone()
						local revHash = {}
						for _, g in pairs(grassModel:GetChildren()) do
							local h = hash(g)
							if revHash[h] then
								table.insert(revHash[h], g.CFrame)
								g:remove()
							else
								revHash[h] = {g}
							end
						end
						grassData = {}
						for _, t in pairs(revHash) do
							table.insert(grassData, t)
						end
						grassDataCache[chunkId] = grassData
					end
					local grassFolder = Instance.new('Folder', rf)
					grassReplication = {}
					for _, t in pairs(grassData) do
						local c = shallowcopy(t)
						local p = c[1]:Clone()
						p.Parent = grassFolder
						c[1] = p
						table.insert(grassReplication, c)
					end
					map.Grass:ClearAllChildren()--:remove()
				end
			end
			-- BATTLES
			local battles = {}
			local function checkForBattles(obj)
				for _, ch in pairs(obj:GetChildren()) do
					if ch:FindFirstChild('#Battle') then
						local v = ch['#Battle'].Value
						local battle = completeBattle(v, ch)
						if battle then
							battles[tostring(v)] = { -- only the info that the player needs
								Name             = battle.Name,
								IntroPhrase      = battle.IntroPhrase,
								LosePhrase       = battle.LosePhrase,
								Interact         = battle.Interact,
								RematchQuestion  = battle.RematchQuestion,
								EyesMeetMusic    = shallowcopy(battle.EyesMeetMusic),
								WinEvent         = battle.WinEvent,
								InteractRequired = battle.InteractRequired,
								IgnoreWalls      = battle.IgnoreWalls,
								DontWalk         = battle.DontWalk
								-- is there anything else?
							}
						end
					end
				end
			end
			checkForBattles(map)
			-- ITEMS
			local obtainableItemMap = {}
			pcall(function() PlayerData.currentObtainableItems = obtainableItemMap end)
			local uid = _f.Utilities.uid
			local create = _f.Utilities.Create
			local BitBuffer = _f.BitBuffer
			local function getItemUid()
				local id
				repeat
					id = uid()
				until not obtainableItemMap[id]
				return id
			end
			local function checkForItems(obj)
				for _, ch in pairs(obj:GetChildren()) do
					if ch.Name == '#Item' then
						local ok = false
						if PlayerData then
							local itemTag = ch:FindFirstChild('ObtainableItemNumber')
							local tmTag = ch:FindFirstChild('TM')
							if itemTag then
								local oin = itemTag.Value
								if BitBuffer.GetBit(PlayerData.obtainedItems, oin) then
									ok = true
									ch:remove()
								else
									local itemId = data.ObtainableItems[oin]
									if itemId and Database.ItemById[itemId] then
										ok = true
										local id = getItemUid()
										obtainableItemMap[id] = {itemId, oin}
										create 'StringValue' {
											Name = 'ItemId',
											Value = id,
											Parent = ch
										}
									end
								end
							elseif tmTag then
								local tmNum = tmTag.Value
								if BitBuffer.GetBit(PlayerData.tms, tmNum) then
									ok = true
									ch:remove()
								else
									-- verify num?
									ok = true
									local id = getItemUid()
									obtainableItemMap[id] = tmNum
									create 'StringValue' {
										Name = 'ItemId',
										Value = id,
										Parent = ch
									}
								end
							else
								ch:remove()
							end
							pcall(function() itemTag:remove() end)
							pcall(function() tmTag:remove() end)
						end
						if not ok then
							print('problem with item in '..chunkId..', deleting')
							ch:remove()
						end
					end
				end
			end
			checkForItems(map)
			map.Parent = rf
			-- ROOMS
			local d = data.Chunks[chunkId]
			local rooms = {}
			local roomData = {}
			--[[
			spawn(function()
				if lastChunkData then
					if lastChunkData.isSafari and not d.isSafari then
						PlayerData:leaveSafari()
					elseif d.isSafari and not lastChunkData.isSafari then
						PlayerData:enterSafari()
					end	
				end	
			end)
			--]]
			if d.buildings then
				for id, bd in pairs(d.buildings) do
					if type(id) == 'number' and type(bd) == 'string' then
						id = bd
					else
						roomData[id] = bd
					end
					local m
					pcall(function() m = storage.Indoors[chunkId]:FindFirstChild(id):Clone() end)
					if not m then pcall(function() m = storage.Indoors.world:FindFirstChild(id):Clone() end) end
					if not m and id:sub(1,2) ~= 'C_' then error('could not find room with id '..id, 0) end
					if m then
						if id == 'Museum' and reducedGraphics then
							pcall(function() m.Lapras:remove() end)
						end
						m.Parent = rf
						checkForBattles(m)
						checkForItems(m)
						rooms[id] = m
					end
				end
			end
			if storage.Indoors:FindFirstChild(chunkId) then
				for _, M in pairs(storage.Indoors[chunkId]:GetChildren()) do
					if not rooms[M.Name] then
						local m = M:Clone()
						m.Parent = rf
						checkForBattles(m)
						checkForItems(m)
						rooms[M.Name] = m
					end
				end
			end
			-- MISC
			-- October 2016 Event - White Haunters
--[[			
				if _f.Date:getDate().MonthNum == 10 then
				d = deepcopy(d)
				local function modList(list)
					local totalWeightD = 0
					local totalWeightN = 0
					local minLevel = 100
					local maxLevel = 1
					for _, encounter in pairs(list) do
						local w = encounter[4] * 20
						encounter[4] = w
						if encounter[5] ~= 'night' then totalWeightD = totalWeightD + w end
						if encounter[5] ~= 'day'   then totalWeightN = totalWeightN + w end
						minLevel = math.min(minLevel, encounter[2])
						maxLevel = math.max(maxLevel, encounter[3])
					end
					local totalWeight = (totalWeightD+totalWeightN)/2
					if totalWeight == 0 then return end
					list[#list+1] = {rc4('Haunter'), minLevel, maxLevel, totalWeight/500, nil, true, rc4('hallow')}
				end
				if d.regions then
					for _, region in pairs(d.regions) do
						if region.Grass then
							modList(region.Grass)
						end
						if chunk == 'chunk64' and region.MiscEncounter then
							modList(region.MiscEncounter)
						end
					end
				end
			end
			--]]
			-- Winter 2016 Event - Santa Claus
			-- [[			
			local santa = map:FindFirstChild('Santa')
			if santa then
				local clausChunks = {'chunk5', 'chunk15', 'chunk11'}
				local m = game:GetService('Lighting'):GetMinutesAfterMidnight()

				if not PlayerData or PlayerData.completedEvents.BeatSanta or not PlayerData.completedEvents.LearnAboutSanta 
					or (m > 6*60 and m < 20*60) or chunkId ~= clausChunks[PlayerData.userId%3+1] then
					santa:remove()
				end
			end
			--]]

			-- Halloween 2017 Event - Marshadow
			-- [[			
			local shadowvoid = map:FindFirstChild('Marshadow')
			if shadowvoid then
				local marshChunks = {'chunk12', 'chunk36', 'chunk45', 'chunk51'}
				local minutes = game:GetService('Lighting'):GetMinutesAfterMidnight()

				if not PlayerData or PlayerData.completedEvents.CaughtMarshadow 
					or (minutes > 6*60 and minutes < 20*60) or chunkId ~= marshChunks[PlayerData.userId%3+1] then
					shadowvoid:remove()
				end
			end
			--]]



--[[						-- mrbobbilly event
			local bob = map:FindFirstChild('Bob')
			if bob then
				local clausChunks = {'chunk21'}
				local m = game:GetService('Lighting'):GetMinutesAfterMidnight()
				
				if not PlayerData or PlayerData.completedEvents.BeatBob2 or not PlayerData.completedEvents.LearnAboutBob2  
					or (m > 6*60 and m < 20*60) or chunkId ~= clausChunks[PlayerData.userId%3+1] then
				
					bob:remove()
				end
			end
			--]]
			-- Shaymin
			if chunkId == 'chunk17' and PlayerData and not PlayerData.completedEvents.Shaymin and PlayerData:getBagDataById('gracidea', 5) then
				storage.Models.Shaymin:Clone().Parent = map
			end
			-- Snorlax
			if chunkId == 'chunk25' and PlayerData and not PlayerData.completedEvents.Snorlax then
				storage.Models.Snorlax:Clone().Parent = map
			end
			-- Victini
			if chunkId == 'chunk34' and PlayerData and not PlayerData.completedEvents.Victini then
				storage.Models.Victini:Clone().Parent = map
			end
			-- Tornadus & Thundurus / Landorus
			if chunkId == 'chunk37' and PlayerData then
				if not PlayerData.completedEvents.RNatureForces then
					storage.Models.Tornadus:Clone().Parent = map
					storage.Models.Thundurus:Clone().Parent = map
				elseif not PlayerData.completedEvents.Landorus then
					local hasTornadus, hasThundurus = false, false
					for _, p in pairs(PlayerData.party) do
						if p.num == 641 then
							hasTornadus = true
						elseif p.num == 642 then
							hasThundurus = true
						end
					end
					if hasTornadus and hasThundurus then
						PlayerData.flags.landorusEnabled = true
						storage.Models.Landorus:Clone().Parent = map
					end
				end
			end


			-- Latios/Latias





			-- Heatran
			if chunkId == 'chunk40' then
				if not PlayerData or not PlayerData.badges[6] then return end -- used some exploit to get here (without legitimate Rock Climb)
				if not PlayerData.completedEvents.Heatran then
					storage.Models:WaitForChild('Heatran'):Clone().Parent = map
				end
			end
			-- Diancie
			if chunkId == 'chunk41' then
				if not PlayerData or not PlayerData.badges[6] or not PlayerData.completedEvents.OpenJDoor then return end -- hax
				if not PlayerData.completedEvents.Diancie then
					storage.Models:WaitForChild('Diancie'):Clone().Parent = map
				end
			end
			-- Beast Trio
			if chunkId == 'chunk44' then
				if not PlayerData or not PlayerData.badges[6] then return end -- hax
				if not PlayerData.completedEvents.RBeastTrio then
					storage.Models:WaitForChild('Raikou'):Clone().Parent = map
					storage.Models:WaitForChild('Entei'):Clone().Parent = map
					storage.Models:WaitForChild('Suicune'):Clone().Parent = map
				end
			end

			-- Genesect
			if chunkId == 'chunk88' then
				if PlayerData and PlayerData.completedEvents.Genesect then
					pcall(function() 
						if map:FindFirstChild('Genesect') then
							map.Genesect:remove()
						end
					end)
				else
					if storage.Models:FindFirstChild('Genesect') then
						storage.Models.Genesect:Clone().Parent = map
					end
				end
			end



			--
			v = {map = map, data = d, rooms = rooms, roomData = roomData, id = chunkId, battles = battles, 
				grassReplication = grassReplication--[[, oItems = obtainableItems]]}
			if chunkId == 'chunk14' then
				local keepMonkey
				pcall(function()
					if math.random(5) ~= 1 then return end
					for _, t in pairs(_f.PlayerDataService[player]:getFirstNonEgg():getTypes()) do
						if t == 'Grass' then
							keepMonkey = map.Pansage
							break
						elseif t == 'Fire' then
							keepMonkey = map.Pansear
							break
						elseif t == 'Water' then
							keepMonkey = map.Panpour
							break
						end
					end
				end)
				if keepMonkey ~= map.Pansage then map.Pansage:remove() end
				if keepMonkey ~= map.Pansear then map.Pansear:remove() end
				if keepMonkey ~= map.Panpour then map.Panpour:remove() end
				if keepMonkey then
					_f.Utilities.Create 'StringValue' {
						Name = '#InanimateInteract',
						Value = keepMonkey.Name,
						Parent = keepMonkey
					}
				end
			end
			rf.Parent = player:WaitForChild('PlayerGui')--requestFulfillment
			delay(30, function()
				pcall(function() rf:remove() end)
			end)
		elseif kind == 'ChunkReceived' then
			local x = request[2]
			local Extra = {
				game.ReplicatedStorage.Modelss,
				game.ReplicatedStorage.Remote,
				game.ReplicatedStorage.Preload,
				game.Workspace.SpawnBox, -- will this work
				--game.ReplicatedFirst.loaded
			}
			if x:IsA('Player') then
				return
			else
				for i=1, #Extra do
					if x:IsDescendantOf(Extra[i]) then
						return
					end
				end
			end
			wait(3)
			pcall(function() x:remove() end)
		elseif kind == 'Grass' then
			local chunk = storage.MapChunks:FindFirstChild(request[2])
			if chunk then
				local grassName = request[3] and 'MGrass' or 'Grass'
				local grass = chunk:FindFirstChild(grassName)
				if grass then
					v = grass:Clone()
					v.Parent = player:WaitForChild('PlayerGui')
				end
			end
		elseif kind == 'Model' then
			local model = storage.Models:FindFirstChild(request[2])
			if model and model:IsA('Model') then
				v = model:Clone()
				v.Parent = player:WaitForChild('PlayerGui')
			end
		elseif kind == 'Module' then
			local module = storage.RuntimeModules:FindFirstChild(request[2])
			warn("Module?")
			print(module)
			if module then
				v = module:Clone()
				v.Parent = player:WaitForChild('PlayerGui')
			end
			--[[ --anti cheat broken... so i just use the old non anti cheat^
		elseif kind == 'Grass' then
			local chunk = storage.MapChunks:FindFirstChild(request[2])
			if player:WaitForChild('PlayerGui'):FindFirstChild(request[2]) then --exploit check for loading modules
				player:kick('kicked by anti cheat, Report to the Discord server if this is an error')
				return			
			end
			if chunk then
				local grassName = request[3] and 'MGrass' or 'Grass'
				local grass = chunk:FindFirstChild(grassName)
				if grass then
					v = grass:Clone()
					v.Parent = player:WaitForChild('PlayerGui')
				end
			end
		elseif kind == 'Model' then
			local model = storage.Models:FindFirstChild(request[2])
			if player:WaitForChild('PlayerGui'):FindFirstChild(request[2]) then --exploit check for loading models
				player:kick('kicked by anti cheat, please rejoin if this is an error')
				return
			end
			if model and model:IsA('Model') then
				v = model:Clone()
				v.Parent = player:WaitForChild('PlayerGui')
			end
		elseif kind == 'Module' then
			local module = storage.RuntimeModules:FindFirstChild(request[2])
			if player:WaitForChild('PlayerGui'):FindFirstChild(request[2]) then --exploit check for loading modules
				player:kick('kicked due to anti cheat, please rejoin if this is an error')
				return			
			end
			if module then
				v = module:Clone()
				v.Parent = player:WaitForChild('PlayerGui')
			end
			--]]
			--		elseif kind == 'Battle' then -- OVH  replace these
			--			local battle = data.Trainers.Battles[request[2]]
			--			if battle then
			--				v = completeBattle(battle)
			--			end
		elseif kind == 'LocalIndoorsOrigin' then
			local pos
			for x = 1, 5 do
				for y = 1, 5 do
					if not indoorOrigins[x][y] or not players:FindFirstChild(indoorOrigins[x][y]) then
						indoorOrigins[x][y] = player.Name
						pos = Vector3.new(x * 200, 400, y * 200)
						break
					end
				end
				if pos then break end
			end
			v = pos or Vector3.new(0, 400, 0)
		elseif kind == 'Spritesheets' then
			local isFemale = request[4]
			local sprites = data.Spritesheets[request[2]]
			if isFemale then
				v = sprites[request[3]..'_F']
				if v then
					v.female = true
				else
					v = sprites[request[3]]
				end
			else
				v = sprites[request[3]]
				if sprites[request[3]..'_F'] then
					v.male = true
				end
			end
		elseif kind == 'BabyEvolutionPokedexNumber' then
			local pokemon-- = data.Pokedex[request[2]]
			local num = tonumber(request[2])
			if num == 490 then
				v = 489
			else
				for _, p in pairs(data.Pokedex) do
					if p.num == num then
						pokemon = p
						break
					end
				end
				local i = 0
				while pokemon.baseSpecies do
					pokemon = data.Pokedex[toId(pokemon.baseSpecies)]
					i=i+1; if i>10 then
						print('Stuck in loop searching for BaseSpecies['..tostring(request[2])..']')
						break
					end
				end
				i = 0
				while pokemon.prevo do
					pokemon = data.Pokedex[pokemon.prevo]
					i=i+1; if i>10 then
						print('Stuck in loop searching for BabyEvolutionPokedexNumber['..tostring(request[2])..']')
						break
					end
				end
				v = pokemon.num
			end
			--		elseif kind == 'ItemBundle' then
			--			local nums = request[2]
			--			v = {}
			--			for _, n in pairs(nums) do
			--				v[tostring(n)] = true
			--			end
			--			for _, item in pairs(data.Items) do
			--				if v[tostring(item.num)] then
			--					if item and (item.isPokeball or type(item.onUse) == 'function') then
			--						item.battleUsable = true
			--					end
			--					v[tostring(item.num)] = item
			--				end
			--			end

		elseif #request == 2 or kind == 'Pokedex' then
			local index = request[2]
			if type(index) == 'number' then
				for i, d in pairs(data[kind]) do
					if d.num == index then
						index = i
						v = d
						if kind == 'Pokedex' and v.baseSpecies then
							index = toId(v.baseSpecies)
							v = data.Pokedex[index]
						end
						break
					end
				end
			else
				v = data[kind][index]
			end
			if kind == 'Pokedex' and request[3] then
				v = data.Pokedex[toId(v.species..request[3])] or v
			end
			if not v then print(index) end
			if kind == 'Pokedex' and not v.learnedMoves then -- OVH  
				--				if index == 'meowsticf' then
				--					v.learnedMoves = femaleMeowsticLearnedMoves
				----				elseif index == 'palkiadark' then
				----					v.learnedMoves = darkPalkiaLearnedMoves
				--				else
				--					v.learnedMoves = data.LearnedMoves[v.num]--[index]
				--				end
				v.id = index
			elseif kind == 'Movedex' then
				local move = v
				v = {}
				for _, i in pairs({'num','accuracy','basePower','category','id','name','pp','type','desc'}) do
					v[i] = move[i]
				end
			elseif kind == 'Items' then
				if v and (v.isPokeball or type(v.onUse) == 'function') then
					v.battleUsable = true
				end
			end
		else
			v = data[kind]
			for i = 2, #request do
				v = v[request[i]]
				if not v then
					warn(request[i]..' not found in data lookup')
				end
			end
		end
		results[i] = v
	end
	if debug then print('returning request to', player.Name) end
	return unpack(results)
end

_f.Network:bindFunction('DataRequest', DataService.fulfillRequest)-- OVH  remove as much of the need for this function as we can

return DataService