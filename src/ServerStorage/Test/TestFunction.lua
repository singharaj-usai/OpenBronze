--local pGui, c1, c2, c3
--local mName
--local mShiny = false

return function(_p)
	local Utilities = _p.Utilities
	local rc4 = Utilities.rc4
	local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework')) --require(game.ServerScriptService.SFramework)
	local SPD = _f.PlayerDataService[game.Players.LocalPlayer]
	-- ADAMANT NATURE = 4  (+Atk   -SpAtk)
	--  MODEST NATURE = 16 (+SpAtk -Atk  )
	
--	_p.PVP:onClickedPlayer()
	
	local imageId1 = 'http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&userid=260394649'
	local imageId2 = 'http://www.roblox.com/Thumbs/Avatar.ashx?x=420&y=420&Format=Png&userid=274500945'
	_p.Battle:doVsAnimation({'mrbobbilly', 'XUXUK'}, {imageId1, imageId2})
	
--	SPD.money = 500
	
	--[[
	local s = _p.DataManager:loadModule('PBStamps')--_p.Menu.stamps
--	if s.stop then
--		s.stop = nil
--		s.spinning = false
--	elseif s.spinning then
--		s.stop = true
--	else
		s:openSpinner()
--	end
	--]]
	
--	_p.Battle:doTrainerBattle {
--		gameType = 'doubles',
--		battleSceneType = 'Double',--'Beach',
--		trainerModel = game.ReplicatedStorage.Modelss.NPCs.Dad,
--		num = 121,
--	}
	
--	SPD:PC_sendToStore(SPD:newPokemon {
--		name = 'Giratina',
--		level = 60,
--		ot = 14838908,
--	})
--	SPD:PC_sendToStore(SPD:newPokemon {
--		name = 'Rayquaza',
--		level = 60,
--		ot = 14838908,
--	})
	
--	_p.Network:post('db_btl')
	
--	_p.Battle:doVsAnimation('Fissy', 658350333, .356, .4)
--	_p.Battle:doTrainerBattle {
	--		musicId = 12639907402,
--		PreventMoveAfter = true,
--		trainerModel = game.ReplicatedStorage.Modelss.NPCs.Jake,
--		vs = {name = 'Fissy', id = 658350333, hue = .356, sat = .4},
--		num = 147
--	}
	
--	_p.PVP:spectate()
	
	-- manually turn lv 29 Inkay into lv 30 Malamar
--	SPD:onOwnPokemon(687)
--	local p = SPD.party[2]
--	p.name = 'Malamar'
--	p.num = 687
--	p.data = _f.Database.PokemonById.malamar
--	p.experience = p:getRequiredExperienceForLevel(30)
--	p.level = 30
	
	-- teleport to outside dome lab on lake
	--	_p.DataManager:loadMap('chunk9')
--	Utilities.Teleport(CFrame.new(350, 93, -883))
	
--	SPD:addBagItems({id='umvbattery',quantity=99})
	
--	SPD:PC_sendToStore(SPD:newPokemon {
--		name = 'Zorua',
--		level = 25,
--		ot = 1123551,
--	})
--	for i = 1, 6 do
--		SPD:PC_sendToStore(SPD:newPokemon {
--			name = 'Rotom',
--			level = 25,
--			ot = 1123551,
--		})
--	end
	
--	SPD:obtainTM(6, true)
--	SPD:completeEventServer('RJO')
--	_p.DataManager:loadModule('Gym5'):setLevel(2)
	
--	SPD:PC_sendToStore(SPD:newPokemon {
--		name = 'Mew',
--		forme = 'rainbow',
--		level = 40,
--		ot = 13094490,
--	})
	
--	SPD:PC_sendToStore(SPD:newPokemon {
--		name = 'Mew',
--		shiny = true,
--		level = 1,
--		nature = 16,
--		ot = 28243725,
--		ivs = {31, 31, 31, 31, 31, 31},
--		moves = {{id = 'nastyplot'},
--			{id = 'aurasphere'},
--			{id = 'reflecttype'},
--			{id = 'transform'}},
--	})
--	SPD:PC_sendToStore(SPD:newPokemon {
--		name = 'Ho-Oh',
--		shiny = true,
--		hiddenAbility = true,
--		level = 1,
--		nature = 14,
--		ot = 28243725,
--		ivs = {31, 31, 31, 31, 31, 31},
--		moves = {{id = 'recover'},
--			{id = 'whirlwind'},
--			{id = 'weatherball'}},
--	})
	
--	SPD:PC_sendToStore(SPD:newPokemon {
--		name = 'Cinccino',
--		hiddenAbility = true,
--		level = 40,
--		ot = 64643985,
--		moves = {{id = 'bulletseed'},
--			{id = 'rockblast'},
--			{id = 'tailslap'},
--			{id = 'sing'}},
--	})
	
--	local egg = SPD.party[6]
--	for _, move in pairs(egg.moves) do print(move.id) end
--	egg.eggCycles = 1
--	SPD:completedEggCycle()
	
--	local room = _p.DataManager.currentChunk:topRoom()
--	for npcName in pairs(room.npcs) do
--		print(npcName)
--	end
	
--	_f.PlayerDataService[_p.player].completedEvents.ReceivedBWEgg = false
	
--	_p.Battle:doTrainerBattle {
--		IgnoreBlackout = true,
--		battleSceneType = 'Lab',
--		musicId = 303861020,
--		PreventMoveAfter = true,
--		trainerModel = game.ReplicatedStorage.Modelss.NPCs.Jake,
--		num = 107
--	}
	
--	_p.Battle:doPVPBattle({opponent = player, teamPreviewEnabled = true})
--	_p.Menu:testTopbarMenu()
--	_p.PVP:host2v2()
	
	
--	_p.MasterControl.WalkEnabled = false
--	_p.MasterControl:Stop()
--	spawn(function() _p.Menu:disable() end)
--	_p.MusicManager:popMusic(true)
--	_p.Intro:newGame(Utilities.fadeGui)
	
--	_p.PlayerData.completedEvents.TessStartFollow = false
--	_p.PlayerData.completedEvents.TessEndFollow = false
--	_p.PlayerData.completedEvents.DefeatTEinAC = false
--	_p.PlayerData.completedEvents.EnteredPast = false
	
--	_p.PlayerData.defeatedTrainers = _p.BitBuffer.SetBit(_p.PlayerData.defeatedTrainers, 102, false)
	
--[[	_p.PlayerData.pc:sendToStore(_p.Pokemon:new {
		name = 'Tyranitar',
		level = 50,
		shiny = true,
		item = rc4('tyranitarite'),
		nature = 4,
		ot = 1281876,
		moves = {
			{id = rc4('stoneedge')},
			{id = rc4('dragonclaw')},
			{id = rc4('superpower')},
			{id = rc4('crunch')},
		},
	})--]]
	
--	_p.PlayerData.party[6].moves = {
--		{id = Utilities.rc4('heatwave')},
--		{id = Utilities.rc4('flamethrower')},
--		{id = Utilities.rc4('crunch')},
--		{id = Utilities.rc4('agility')}
--	}

--	_p.Menu.shop:buyMoney()
	
--	local n = Utilities.weightedRandom(_p.DataManager.currentChunk.data.regions['Lagoona Trenches'].MiscEncounter, function(o) return o[4] end)[1]
--	print(n, Utilities.rc4(n))
	
--	_p.PlayerData.party[1] = _p.Pokemon:deserialize('C6ECBtaLsRzNaOhf1RydmLCW48hcZNCmFo8Bw7ORRajHqgPrCEjA')
	
--	_p.Menu:testTopbarMenu()
	

--	_p.PlayerData.trainerName = 'Calesca'
--	_p.PlayerData:addBagItems({id=Utilities.rc4('swampertite'),quantity=1})
--	_p.PlayerData:addBagItems({id=Utilities.rc4('megakeystone'),quantity=1})--,{id=Utilities.rc4('gardevoirite'),quantity=1})
--	_p.PlayerData:addBagItems({id=Utilities.rc4('rarecandy'),quantity=40})
--	_p.PlayerData.pc:sendToStore(_p.Pokemon:new {
--		name = 'Inkay',
--		level = 29,
--		ot = 1123551,
--	})
	
--[[	
	if not pGui then
		local g = Instance.new('ScreenGui', game.Players.LocalPlayer.PlayerGui)
		g.Name = 'TestGui'
		pGui = Utilities.Create 'TextBox' {
			BorderSizePixel = 2,
			BorderColor3 = Color3.new(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(58, 65, 71),
			Text = '',
			Font = Enum.Font.SourceSansBold,
			FontSize = Enum.FontSize.Size18,
			TextColor3 = Color3.fromRGB(181, 194, 204),
			Size = UDim2.new(.1, 0, .05, 0),
			Position = UDim2.new(.025, 0, .015, 0),
			Parent = Utilities.gui,
		}
		c1 = pGui:Clone()
		c1.Position = UDim2.new(.175, 0, .015, 0)
		c1.Parent = Utilities.gui
		c2 = pGui:Clone()
		c2.Position = UDim2.new(.325, 0, .015, 0)
		c2.Parent = Utilities.gui
		c3 = pGui:Clone()
		c3.Position = UDim2.new(.475, 0, .015, 0)
		c3.Parent = Utilities.gui
		
		_p.colorBox1, _p.colorBox2, _p.colorBox3 = c1, c2, c3
		
		return
	end
	
	
	local battle = _p.Battle.currentBattle
	if battle then
		battle.p1.active[1].sprite:animMegaEvolve(_p.DataManager:getSprite((mShiny and '_SHINY' or '')..'_BACK', mName..'-megay', false))--Sceptile-mega', false))
	else
		local name = pGui.Text
		if name == '' then return end
		mShiny = false
		if name:sub(1,1) == '_' then
			mShiny = true
			name = name:sub(2)
		end
		mName = name
		print('giving', mName)
		_p.PlayerData.party[1] = _p.Pokemon:new{
			name = mName,
			shiny = mShiny,
			level = 60,
		}
	end--]]
	
--	_p.PlayerData.pc:sendToStore(_p.Pokemon:new {
--		name = 'Jirachi',
--		level = 25,
--		shiny = true,
--		ivs = {31, 31, 31, 23, 19, 19},
--		ot = 4513510,
--		nature = 3,
--	})
--	print(_p.PlayerData.completedEvents.Jirachi)
--	_p.PlayerData.completedEvents.Jirachi = true
----	_p.PlayerData.completedEvents.Jirachi = nil
--	print(_p.PlayerData.completedEvents.Jirachi)
	
	
--	local rc4 = Utilities.rc4
--	_p.PlayerData.party[1].ivs = {31, 31, 31, 31, 31, 31}
--	_p.PlayerData.pc:sendToStore(_p.Pokemon:new {
--		name = 'Volcanion',
--		forme = 'black',
--		level = 100,
--		ivs = {31, 31, 31, 31, 31, 31},
--		ot = 8194465,
--		nature = 16,
--	})
--	_p.PlayerData.pc:sendToStore(_p.Pokemon:new {
--		name = 'Groudon',
--		level = 100,
--		ivs = {31, 31, 31, 31, 31, 31},
--		ot = 8194465,
--		nature = 4,
--	})
--	_p.PlayerData.pc:sendToStore(_p.Pokemon:new {
--		name = 'Yveltal',
--		level = 100,
--		ivs = {31, 31, 31, 31, 31, 31},
--		ot = 8194465,
--		nature = 16,
--	})
	
--	_p.PlayerData.pc:sendToStore(_p.Pokemon:new {
--		name = 'Celebi',
--		level = 5,
--		ot = 5730064,
--	})
	
--	local m = _p.AnimatedSprite:new{sheets={{id=456223912,rows=10}},nFrames=20,fWidth=393,fHeight=99,framesPerRow=2}--,speed=.0}
--	local s = m.spriteLabel
--	s.Size = UDim2.new(0.0, 524, 0.0, 132)
--	s.Position = UDim2.new(0.5, -524/2, 0.5, -132/2)
--	s.Parent = Utilities.gui
--	m:Play()
	
--	_p.Menu.battleShop:open()
	
--	_p.Battle:doTrainerBattle {
--		IgnoreBlackout = true,
--		battleSceneType = 'Lab',
--		musicId = 303861020,
--		PreventMoveAfter = true,
--		trainer = {
--			ModelName = 'Jake',
--			Name = 'Pokemon Trainer Jake',
--			LosePhrase = 'Amazing!',
--			TrainerDifficulty = 1,
--			Payout = 40 * 5,
--			Party = {
--				{
--					id = Utilities.rc4('Haunter'),
--					level = 6,
--					gender = 'M',
--					ivs = {1,1,1,1,1,1},
--					ability = 'Run Away',
--					nature = 'Hardy',
--					moves = {
--						{ id = 'meanlook' },
--					},
--				}
--			}
--		}
--	}
end