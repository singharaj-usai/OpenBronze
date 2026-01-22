print("GetShop")
local _f = require(script.Parent.Parent)
local Utilities = _f.Utilities
local rc4 = Utilities.rc4

-- TODO:
-- "stnshp" and "bp" shops encrypt after they are requested; move this to before

local encryptedShop = {
	pkbl = {rc4('pokeball'),     200},--200}
	grbl = {rc4('greatball'),    600},--600}
	--msbl = {rc4('masterball'),    0},--600}
	utbl = {rc4('ultraball'),   1200},--1200}
	--pmbl = {rc4('pumpkinball'), 0}, -- OCTOBER
	--[[
	crbl = {rc4('colorlessball'), 0}, 
	inbl = {rc4('insectball'), 0}, 
	debl = {rc4('dreadball'), 0}, 
	drbl = {rc4('dracoball'), 0}, 
	zpbl = {rc4('zapball'), 0}, 
	fibl = {rc4('fistball'), 0}, 
	flbl = {rc4('flameball'), 0}, 
	skbl = {rc4('skyball'), 0}, 
	spbl = {rc4('spookyball'), 0}, 
	prbl = {rc4('premierball'), 0}, 
	rebl = {rc4('repeatball'), 0}, 
	mebl = {rc4('meadowball'), 0}, 
	eabl = {rc4('earthball'), 0}, 
	nebl = {rc4('netball'), 0}, 
	dibl = {rc4('diveball'), 0}, 
	lubl = {rc4('luxuryball'), 0}, 
	icbl = {rc4('icicleball'), 0}, 
	qubl = {rc4('quickball'), 0}, 
	dubl = {rc4('duskball'), 0}, 
	chbl = {rc4('cherishball'), 0}, 
	tobl = {rc4('toxicball'), 0}, 
	mibl = {rc4('mindball'), 0}, 
	stbl = {rc4('stoneball'), 0}, 
	sebl = {rc4('steelball'), 0}, 
	slbl = {rc4('splashball'), 0}, 
	pibl = {rc4('pixieball'), 0}, 
	publ = {rc4('pumpkinball'), 0}, 	
	
	--]]
	
	
	
	
	
	
	
	
	expshr = {rc4('expshare'),	0}, --15000 (so its reasonably priced)}
	
	ptn  = {rc4('potion'),       300},--300}
	sptn = {rc4('superpotion'),  700},--700}
	hptn = {rc4('hyperpotion'), 1200},--1200}
	mptn = {rc4('maxpotion'),   2500},--2500}
	frst = {rc4('fullrestore'), 3000},--3000}
	reve = {rc4('revive'),      1500},--1500}
	antd = {rc4('antidote'),     100},--100}
	przh = {rc4('paralyzeheal'), 150},--150}
	awk  = {rc4('awakening'),    250},--250}
	brnh = {rc4('burnheal'),     250},--250}
	iceh = {rc4('iceheal'),      250},--250}
	flhl = {rc4('fullheal'),     600},--600}
	escr = {rc4('escaperope'),   550},--550}
	rpl  = {rc4('repel'),        350},--350}
	srpl = {rc4('superrepel'),   500},--500}
	mrpl = {rc4('maxrepel'),     700},--700}
	racny = {rc4('rarecandy'), 	 6000},--6000}
	
	ntbl = {rc4('netball'),     1000},--1000}
	lxbl = {rc4('luxuryball'),  1000},--1000}
	qkbl = {rc4('quickball'),   1000},--1000}
	dkbl = {rc4('duskball'),    1000},--1000}
	

}

local dailyBalls = {
	{
		{rc4('toxicball'),     2000},--2000}
		{rc4('insectball'),    2000},--2000}
		{rc4('icicleball'),    2000},--2000}
	}, {
		{rc4('skyball'),       2000},--2000}
		{rc4('zapball'),       2000},--2000}
	}, {
		{rc4('fistball'),      2000},--2000}
		{rc4('flameball'),     2000},--2000}
		{rc4('dracoball'),     2000},--2000}
	}, {
		{rc4('spookyball'),    2000},--2000}
		{rc4('pixieball'),     2000},--2000}
	}, {
		{rc4('earthball'),     2000},--2000}
		{rc4('stoneball'),     2000},--2000}
		{rc4('dreadball'),     2000},--2000}
	}, {
		{rc4('colorlessball'), 2000},--2000}
		{rc4('splashball'),    2000},--2000}
	}, {
		{rc4('mindball'),      2000},--2000}
		{rc4('meadowball'),    2000},--2000}
		{rc4('steelball'),     2000},--2000}
	}
}

return function(self, shopId) -- where self is the PlayerData
--	print('Shop ID:', shopId)
	if shopId == 'pbemp' then
		local items = {}
		table.insert(items, encryptedShop.pkbl)
		table.insert(items, encryptedShop.grbl)
		table.insert(items, encryptedShop.utbl)
		table.insert(items, {rc4'masterball', 'r8', 'MasterBall'})
		table.insert(items, encryptedShop.ntbl)
		table.insert(items, encryptedShop.lxbl)
		table.insert(items, encryptedShop.qkbl)
		table.insert(items, encryptedShop.dkbl)
		table.insert(items, encryptedShop.pmbl)
--[[		
		if _p.Date:getDate().MonthNum == 10 then -- OCTOBER
			table.insert(items, encryptedShop.pmbl)
		end
--]]		
		for _, ball in pairs(dailyBalls[_f.Date:getDate().WeekdayNum + 1]) do
			table.insert(items, ball)
		end
		return items
	elseif shopId == 'stnshp' then
		local stoneShop = {
			{rc4('firegem'),     5000},--5000}
			{rc4('watergem'),    5000},--5000}
			{rc4('electricgem'), 5000},--5000}
			{rc4('grassgem'),    5000},--5000}
			{rc4('icegem'),      5000},--5000}
			{rc4('fightinggem'), 5000},--5000}
			{rc4('poisongem'),   5000},--5000}
			{rc4('groundgem'),   5000},--5000}
			{rc4('flyinggem'),   5000},--5000}
			{rc4('psychicgem'),  5000},--5000}
			{rc4('buggem'),      5000},--5000}
			{rc4('rockgem'),     5000},--5000}
			{rc4('ghostgem'),    5000},--5000}
			{rc4('dragongem'),   5000},--5000}
			{rc4('darkgem'),     5000},--5000}
			{rc4('steelgem'),    5000},--5000}
			{rc4('normalgem'),   5000},--5000}
			{rc4('fairygem'),    5000},--5000}
			
			{rc4('everstone'),    30000},--30000}
			{rc4('waterstone'),    30000},--30000}
			{rc4('firestone'),     30000},--30000}
			{rc4('leafstone'),     30000},--30000}
			{rc4('thunderstone'),  30000},--30000}
			{rc4('moonstone'),     30000},--30000}
			{rc4('icestone'),      30000},--30000}
			
			
			
			{rc4('venusaurite'),   150000},--150000}
			{rc4('glalitite'),   150000},--150000}
			{rc4('sharpedonite'),   150000},--150000}
			{rc4('kangaskhanite'),  150000},--150000}
			--{rc4('latiasite'),   75000},--150000}
			--{rc4('latiosite'),   75000},--150000}
			{rc4('blastoisinite'), 150000},--150000}
			{rc4('charizarditex'), 150000},--150000}
			{rc4('charizarditey'), 150000},--150000}
			{rc4('ampharosite'),   100000},--100000}
			{rc4('beedrillite'),   100000},--100000}
			{rc4('slowbronite'),   100000},--100000}
			{rc4('pidgeotite'),    100000},--100000}
			{rc4('banettite'),     100000},--100000}
			{rc4('scizorite'),     100000},--100000}
			{rc4('heracronite'),   100000},--100000}
			{rc4('pinsirite'),     100000},--100000}
			{rc4('altarianite'),   100000},--100000}
			{rc4('aerodactylite'), 100000},--100000}
			{rc4('alakazite'),     100000},--100000}
			{rc4('lopunnite'),     100000},--100000}
			{rc4('cameruptite'),   100000},--100000}
			{rc4('mawilite'),      100000},--100000}
			{rc4('manectite'),     100000},--100000}
			{rc4('houndoominite'), 100000},--100000}
			{rc4('lucarionite'),   200000},--200000}
			{rc4('aggronite'),     200000},--200000}
			{rc4('garchompite'),   200000},--200000}
			{rc4('salamencite'),   200000},--200000}
			{rc4('tyranitarite'),  200000},--200000}
			{rc4('metagrossite'),  200000},--200000}
			{rc4('medichamite'),  200000},--200000}
			{rc4('blazikenite'),  200000},--200000}
			{rc4('swampertite'),  200000},--200000}
			{rc4('sceptilite'),  200000},--200000}
			{rc4('gengarite'),  200000},--200000}
			{rc4('gyaradosite'),  200000},--200000}
			{rc4('galladite'),  200000},--200000}
			{rc4('gardevoirite'),  200000},--200000}
		}
		
--		if self.completedEvents.NiceListReward then -- during the Winter 2016 event, only people who completed the event could purchase Ice Stones
--			table.insert(stoneShop, 24, {rc4('icestone'), 30000})
--		end
		
		return stoneShop
		
	elseif shopId == 'arcade' then
		local Prizes = {
			{"powerweight",     750},
			{"powerbracer",     750},
			{"powerbelt",       750},
			{"powerlens",       750},
			{"powerband",       750},
			{"poweranklet",     750},
			{"audinite",        1500},
			{"destinyknot",     3500},
			{"luckyegg",        15000},
			{"TM09 Venoshock",  1500},
			{"TM90 Substitute", 1500},
			{"TM02 Dragon Claw",1500},
			{"TM29 Psychic",    2000},
			{"PKMN Audino",    2000},
			{"PKMN Chansey",    2500},
			{"PKMN Ditto",    7500},
			{"HOVER Mega Salamence Board",    15000},
		}
		if self.flags.AA50 then
			table.insert(Prizes, {"HOVER Shiny M.Salamence Board",    25000})
		end
		return Prizes
		
	elseif shopId == 'bp' then
		local items = {
			{'BP10', 5},
			{'BP50', 20},
			{'hpreset', 0},
			{'attackreset', 0},
			{'defensereset', 0},
			{'spatkreset', 0},
			{'spdefreset', 0},
			{'speedreset', 0},
			{'abilitypatch', 5},
			{'lonelymint', 1},
			{'adamantmint', 1},
			{'naughtymint', 1},
			{'bravemint', 1},
			{'boldmint', 1},
			{'impishmint', 1},
			{'laxmint', 1},     
			{'relaxedmint', 1},  
			{'modestmint', 1},
			{'mildmint', 1},
			{'rashmint', 1},
			{'quietmint', 1},
			{'calmmint', 1},
			{'gentlemint', 0},
			{'carefulmint', 1},
			{'sassymint', 1},
			{'timidmint', 1},
			{'hastymint', 1},
			{'jollymint', 1},
			{'naivemint', 1},
			{'seriousmint', 1},  
			{'dragonscale', 0},
			{'destinyknot', 0},
			{'sawsbuckcoffee', 0},
			{'razorfang', 0},
			{'razorclaw', 0},
			{'affectionribbon', 0},
			{'airballoon', 0},
			{'weaknesspolicy', 0},
			{'eviolite', 0},
			{'scopelens', 0},
			{'focussash', 0},
			{'bindingband', 0},
			{'widelens', 0},
			{'seaincense', 0},
			{'laxincense', 0},
			{'roseincense', 0},
			{'pureincense', 0},
			{'rockincense', 0},
			{'oddincense', 0},
			{'waveincense', 0},
			{'fullincense', 0},
			{'luckincense', 0},
			{'assaultvest', 0},
			{'flameorb', 0},
			{'toxicorb', 0},
			{'duskstone', 0},
			{'dawnstone', 0},
			{'shinystone', 0},
			{'lifeorb', 0},
			{'machobrace', 0},
			{'upgrade', 0},
			{'metalcoat', 0},
			{'abilitycapsule', 0},
			{'blackbelt', 0},
			{'magnet', 0},
			{'muscleband', 0},
			{'safetygoggles', 0},
			{'sharpbeak', 0},
			{'shellbell', 0},
			{'silkscarf', 0},
			{'snowball', 0},
			{'stick', 0},
			{'thickclub', 0},
			{'twistedspoon', 0},
			{'wiseglasses', 0},
			{'TM01 Hone Claws', 0},
			{'TM02 Dragon Claw', 0},
			{'TM03 Psyshock', 0},
			{'TM04 Calm Mind', 0},
			{'TM05 Roar', 0},
			{'TM06 Toxic', 0},
			{'TM07 Hail', 0},
			{'TM08 Bulk Up', 0},
			{'TM09 Venoshock', 0},
			{'TM11 Sunny Day', 0},
			{'TM12 Taunt', 0},
			{'TM13 Ice Beam', 0},
			{'TM14 Blizzard', 0},
			{'TM15 Hyper Beam', 0},
			{'TM16 Light Screen', 0},
			{'TM17 Protect', 0},
			{'TM18 Rain Dance', 0},
			{'TM19 Roost', 0},
			{'TM20 Safeguard', 0},
			{'TM21 Frustration', 0},
			{'TM22 Solar Beam', 0},
			{'TM23 Smack Down', 0},
			{'TM24 Thunderbolt', 0},
			{'TM25 Thunder', 0},
			{'TM26 Earthquake', 0},
			{'TM27 Return', 0},
			{'TM28 Dig', 0},
			{'TM29 Psychic', 0},
			{'TM30 Shadow Ball', 0},
			{'TM31 Brick Break', 0},
			{'TM32 Double Team', 0},
			{'TM33 Reflect', 0},
			{'TM34 Sludge Wave', 0},
			{'TM35 Flamethrower', 0},
			{'TM36 Sludge Bomb', 0},
			{'TM37 Sandstorm', 0},
			{'TM38 Fire Blast', 0},
			{'TM39 Rock Tomb', 0},
			{'TM40 Aerial Ace', 0},
			{'TM41 Torment', 0},
			{'TM42 Facade', 0},
			{'TM43 Flame Charge', 0},
			{'TM44 Rest', 0},
			{'TM45 Attract', 0},
			{'TM46 Thief', 0},
			{'TM47 Low Sweep', 0},
			{'TM48 Round', 0},
			{'TM49 Echoed Voice', 0},
			{'TM50 Overheat', 0},
			{'TM51 Steel Wing', 0},
			{'TM52 Focus Blast', 0},
			{'TM53 Energy Ball', 0},
			{'TM54 False Swipe', 0},
			{'TM55 Scald', 0},
			{'TM56 Fling', 0},
			{'TM57 Charge Beam', 0},
			{'TM58 Sky Drop', 0},
			{'TM59 Incinerate', 0},
			{'TM60 Quash', 0},
			{'TM61 Will-O-Wisp', 0},
			{'TM62 Acrobatics', 0},
			{'TM63 Embargo', 0},
			{'TM64 Explosion', 0},
			{'TM65 Shadow Claw', 0},
			{'TM66 Payback', 0},
			{'TM67 Retaliate', 0},
			{'TM68 Giga Impact', 0},
			{'TM69 Rock Polish', 0},
			{'TM70 Flash', 0},
			{'TM71 Stone Edge', 0},
			{'TM72 Volt Switch', 0},
			{'TM73 Thunder Wave', 0},
			{'TM74 Gyro Ball', 0},
			{'TM75 Swords Dance', 0},
			{'TM76 Struggle Bug', 0},
			{'TM77 Psych Up', 0},
			{'TM78 Bulldoze', 0},
			{'TM79 Frost Breath', 0},
			{'TM80 Rock Slide', 0},
			{'TM81 X-Scissor', 0},
			{'TM82 Dragon Tail', 0},
			{'TM83 Infestation', 0},
			{'TM84 Poison Jab', 0},
			{'TM85 Dream Eater', 0},
			{'TM86 Grass Knot', 0},
			{'TM87 Swagger', 0},
			{'TM88 Sleep Talk', 0},
			{'TM89 U-turn', 0},
			{'TM90 Substitute', 0},
			{'TM91 Flash Cannon', 0},
			{'TM92 Trick Room', 0},
			{'TM93 Wild Charge', 0},
			{'TM95 Snarl', 0},
			{'TM97 Dark Pulse', 0},
			{'TM98 Power-Up Punch', 0},
			{'TM99 Dazzling Gleam', 0},
			{'medichamite', 15},
			{'blazikenite', 20},
			{'swampertite', 20},
			{'sceptilite', 20},
			{'gengarite', 20},
			{'gyaradosite', 20},
			{'galladite', 20},
			{'gardevoirite', 20},
		}
--		local encryptedIds = {}
--		for i, v in pairs(items) do
--			local f2 = v[1]:sub(1,2)
--			if f2 ~= 'BP' then--and f2 ~= 'TM' then
--				encryptedIds[i] = Utilities.rc4(v[1])
--			end
--		end
		return items--, encryptedIds
	elseif shopId == 'shiptix' then 
		return {
			{rc4('tropicsticket'), 1000}
		}
	end
	
	local items = {}
	local badges = self:countBadges()
	table.insert(items, encryptedShop.pkbl)
	if badges >= 1 then table.insert(items, encryptedShop.grbl) end
	if badges >= 1 then table.insert(items, encryptedShop.msbl) end
	

	
	if badges >= 1 then table.insert(items, encryptedShop.expshr) end
	if badges >= 3 then table.insert(items, encryptedShop.utbl) end
	--[[
	if badges >= 1 then table.insert(items, encryptedShop.pmbl) end
	if badges >= 1 then table.insert(items, encryptedShop.crbl) end
	if badges >= 1 then table.insert(items, encryptedShop.inbl) end
	if badges >= 1 then table.insert(items, encryptedShop.debl) end
	if badges >= 1 then table.insert(items, encryptedShop.drbl) end
	if badges >= 1 then table.insert(items, encryptedShop.zpbl) end
	if badges >= 1 then table.insert(items, encryptedShop.fibl) end
	if badges >= 1 then table.insert(items, encryptedShop.flbl) end
	if badges >= 1 then table.insert(items, encryptedShop.skbl) end
	if badges >= 1 then table.insert(items, encryptedShop.spbl) end
	if badges >= 1 then table.insert(items, encryptedShop.prbl) end
	if badges >= 1 then table.insert(items, encryptedShop.rebl) end
	if badges >= 1 then table.insert(items, encryptedShop.mebl) end
	if badges >= 1 then table.insert(items, encryptedShop.eabl) end
	if badges >= 1 then table.insert(items, encryptedShop.nebl) end
	if badges >= 1 then table.insert(items, encryptedShop.dibl) end
	if badges >= 1 then table.insert(items, encryptedShop.lubl) end
	if badges >= 1 then table.insert(items, encryptedShop.icbl) end
	if badges >= 1 then table.insert(items, encryptedShop.qubl) end
	if badges >= 1 then table.insert(items, encryptedShop.dubl) end
	if badges >= 1 then table.insert(items, encryptedShop.chbl) end
	if badges >= 1 then table.insert(items, encryptedShop.tobl) end
	if badges >= 1 then table.insert(items, encryptedShop.mibl) end
	if badges >= 1 then table.insert(items, encryptedShop.stbl) end
	if badges >= 1 then table.insert(items, encryptedShop.sebl) end
	if badges >= 1 then table.insert(items, encryptedShop.slbl) end
	if badges >= 1 then table.insert(items, encryptedShop.pibl) end
	if badges >= 1 then table.insert(items, encryptedShop.publ) end
	--]]
	
		
	
	table.insert(items, encryptedShop.ptn)
	if badges >= 1 then table.insert(items, encryptedShop.sptn) end
	
	if badges >= 2 then table.insert(items, encryptedShop.hptn) end
	if badges >= 4 then table.insert(items, encryptedShop.mptn) end
	if badges >= 5 then table.insert(items, encryptedShop.frst) end
	if badges >= 2 then table.insert(items, encryptedShop.reve) end
	table.insert(items, encryptedShop.antd)
	table.insert(items, encryptedShop.przh)
	if badges >= 1 then table.insert(items, encryptedShop.awk)  end
	if badges >= 1 then table.insert(items, encryptedShop.brnh) end
	if badges >= 1 then table.insert(items, encryptedShop.iceh) end
	if badges >= 3 then table.insert(items, encryptedShop.flhl) end
	if badges >= 1 then table.insert(items, encryptedShop.escr) end
	if badges >= 1 then table.insert(items, encryptedShop.rpl)  end
	if badges >= 2 then table.insert(items, encryptedShop.srpl) end
	if badges >= 3 then table.insert(items, encryptedShop.mrpl) end
	if badges >= 2 then table.insert(items, encryptedShop.racny) end
	return items
end
