return function(_p)
--do return end
--print('TEST MODE ENABLED: DO NOT SAVE IF LOADING PLAYER')
	local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework'))

local test_intro = false -- to enable, also have to modify Driver
local context = _p.context

local testPoint = 17

pcall(function() -- remove chunk on gameClose (memory test)
game:BindToClose(function()
	print('cleaning up')
	if not (pcall(function() _p.DataManager.currentChunk:remove() end)) then print('chunk cleanup failed') end
	if not (pcall(function() _f.PlayerDataService[_p.player]:remove() end)) then print('player data cleanup failed') end
	if not (pcall(function() if _p.Battle.currentBattle then
		_p.Battle.currentBattle:remove()
		wait(.2)
	end end)) then print('battle cleanup failed') end
	wait(.2)
end)
end) --

	--if game:GetService('RunService'):IsStudio() and not game:FindFirstChild('NetworkServer') then
	--local _p = require(game.ReplicatedStorage:WaitForChild('Plugins'))
	local Utilities = _p.Utilities
	
	local s = tick()
	local player = _p.player
	local players = game:GetService('Players')
--	while not player do
--		if tick()-s > 30 then return end
--		player = players:FindFirstChild('Player1') or players:FindFirstChild('Player')
--	wait()
--	end
	wait()
	
	-- get new server-based PlayerData object
	--local PlayerData = require(script.Parent.Parent.SFramework.PlayerDataService)[player]
	local PlayerData = require(game:GetService('ServerScriptService'):WaitForChild('PlayerDataService'))[player]
	
	if not test_intro then
		if game.Lighting:FindFirstChild('TestData') then
--			_p.forceContinue = true
--			_p.loadedData = {game.Lighting.TestData.Value}
--			if game.Lighting:FindFirstChild('TestPC') then
--				_p.loadedData[2] = game.Lighting.TestPC.Value
--			end
		elseif context == 'adventure' then
			_f.DataPersistence.PlaySolo = true
			
--			PlayerData.gameBegan = true     --> BE VERY CAREFUL WITH THESE
--			_p.PlayerData.gameBegan = true
			_p.PlayerData.completedEvents.IntroToUMV = true
			_p.PlayerData.completedEvents.TestDriveUMV = true
			_p.PlayerData.daycareManHasEgg = true
--			PlayerData.completedEvents.LighthouseScene = true
--			PlayerData.completedEvents.GeraldKey = true
--			PlayerData.badges[1] = true
--			PlayerData.badges[2] = true
--			PlayerData.badges[3] = true
--			PlayerData.badges[4] = true
			_p.PlayerData.completedEvents.GroudonScene = true
			_p.PlayerData.completedEvents.JakeStartFollow = true
--			PlayerData.completedEvents.TessEndFollow = true
		--	PlayerData.completedEvents.BlimpwJT = true
			_p.PlayerData.completedEvents.MeetGerald = true
			_p.PlayerData.completedEvents.RJO = true
			_p.PlayerData.completedEvents.RJP = true
			_p.PlayerData.completedEvents.GJO = true
			_p.PlayerData.completedEvents.GJP = true
			_p.PlayerData.completedEvents.PJO = true
			_p.PlayerData.completedEvents.PJP = true
			_p.PlayerData.completedEvents.BJO = true
			_p.PlayerData.completedEvents.BJP = true
			_p.PlayerData.completedEvents.TEinCastle = true
			_p.PlayerData.badges[6] = true
			PlayerData.badges[6] = true
			PlayerData.completedEvents.OpenJDoor = true
			PlayerData.completedEvents.hasHoverboard = true
			_p.PlayerData.completedEvents.hasHoverboard = true
			PlayerData.currentHoverboard = 'Lavaboard'
--			_p.Repel.steps = 999
			_p.PlayerData.rotomEventLevel = 0
			_p.PlayerData.defeatedTrainers = '//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////'
			
			if testPoint == 1 then
				_p.DataManager:loadChunk('chunk1')
				Utilities.Teleport(CFrame.new(2.7, 53.686, 97.1) + Vector3.new(0, 0, -100))
			elseif testPoint == 2 then
				_p.DataManager:loadChunk('chunk2')
--				Utilities.Teleport(CFrame.new(-78.7, 68.9, -647.5)) -- in front of Pokemon Center -- + Vector3.new(-25, 0, 130))
				Utilities.Teleport(CFrame.new(-320, 70, -569)) -- in front of Rock Climb
			elseif testPoint == 3 then
				_p.DataManager:loadChunk('chunk3')
--				Utilities.Teleport(CFrame.new(-995, 85, -1018)) -- next to Defaultio
--				Utilities.Teleport(CFrame.new(-1174, 85, -930)) -- at bottom of stairs to Pokemon Center
				Utilities.Teleport(CFrame.new(-1220, 95, -859)) -- in front of gym
			elseif testPoint == 4 then
				_p.DataManager:loadChunk('chunk4')
				Utilities.Teleport(CFrame.new(-802, 121, -1445)) -- in front of smashable rock
--				Utilities.Teleport(CFrame.new(-646, 119, -1071)) -- in front of gate to Brimber
--				Utilities.Teleport(CFrame.new(-1005, 119, -1390))
			elseif testPoint == 5 then
				_p.PlayerData.badges[2] = true
				_p.DataManager:loadChunk('chunk5')
				Utilities.Teleport(CFrame.new(-128, 191, -1293))
			elseif testPoint == 6 then
				_p.DataManager:loadChunk('chunk6')
				Utilities.Teleport(CFrame.new(360, 128, -1300)) -- 270, 128, -1345))
			elseif testPoint == 7 then
				_p.DataManager:loadChunk('chunk7')
--				Utilities.Teleport(CFrame.new(-788, 70.4, -799)) -- in front of groudon
				Utilities.Teleport(CFrame.new(-482, 50, -803)) -- in front of entrance to deep caves
			elseif testPoint == 8 then
				_p.DataManager:loadChunk('chunk8')
				Utilities.Teleport(CFrame.new(384, 108, 72))-- 346, 100.8, 155))-- 291, 106.5, 78))
			elseif testPoint == 9 then
				_p.DataManager:loadChunk('chunk9')
--				Utilities.Teleport(CFrame.new(350, 93, -883)) -- in front of lab
				Utilities.Teleport(CFrame.new(256, 108.5, -1046)) -- in front of day care
--				Utilities.Teleport(CFrame.new(257, 92.3, -935)) -- in front of lake (easy to test fishing)
			elseif testPoint == 10 then -- w/ jake npc partner
				_p.DataManager:loadChunk('chunk10')
				Utilities.Teleport(CFrame.new(-716, 158, -1701)) -- top of hill
--				Utilities.Teleport(CFrame.new(-1066, 126, -1721)) -- in front of haunted well
--				Utilities.Teleport(CFrame.new(-1316, 94.4, -1602)) -- in front of cabin
			elseif testPoint == 11 then
				_p.DataManager:loadChunk('chunk11')
--				Utilities.Teleport(CFrame.new(-1259, 119.3, -2327)) -- -1105, 103.2, -1934)) -- -981, 118.6, -2128)) -- -1155, 94, -1991))-- -1113, 103, -2120))
				Utilities.Teleport(CFrame.new(-1192, 93.5, -2130))
--				Utilities.Teleport(CFrame.new(-981, 118.6, -2128))
			elseif testPoint == 12 then
				_p.DataManager:loadChunk('chunk12')
				Utilities.Teleport(CFrame.new(-586, 62, -235))-- -614, 58.1, -423))
			elseif testPoint == 13 then
				_p.DataManager:loadChunk('chunk13')
				Utilities.Teleport(CFrame.new(50.8, 81.7, -295))
			elseif testPoint == 14 then
				_p.DataManager:loadChunk('chunk14')
				Utilities.Teleport(CFrame.new(-595.669, 15.2, 197.883))-- -865.212, 48, 53.745))-- -543, 9.8, 246))
			elseif testPoint == 15 then
				_p.DataManager:loadChunk('chunk15')
				Utilities.Teleport(CFrame.new(696.26, 100, -186.182))-- in front of Mines
--				Utilities.Teleport(CFrame.new(688.472, 100.2, 78.226))-- dunno
--				Utilities.Teleport(CFrame.new(692.549, 100.2, 162.426))-- dunno
--				Utilities.Teleport(CFrame.new(602.107, 109.349, 159.991))-- in front of honey tree
			elseif testPoint == 16 then
				_p.DataManager:loadChunk('chunk16')
--				Utilities.Teleport(CFrame.new(643.106, 117.199, 413.335))-- dunno
				Utilities.Teleport(CFrame.new(605, 8, 368)) -- in front of water at bottom
			elseif testPoint == 17 then
				_p.DataManager:loadChunk('chunk17')
				Utilities.Teleport(CFrame.new(-65.105, 406.769, 2495.167))
			elseif testPoint == 18 then
				_p.DataManager:loadChunk('chunk18')
				Utilities.Teleport(CFrame.new(-1407.753, 129.43, -307.435))-- -1563.933, 131.01, -310.066))--
			elseif testPoint == 19 then
				_p.DataManager:loadChunk('chunk19')
--				Utilities.Teleport(CFrame.new(-2684.568, 261.002, 2674.909)) -- front of Anthian, closer to blimps
				Utilities.Teleport(CFrame.new(-2636, 274, 2340)) -- right in front of dumpster
			elseif testPoint == 20 then
				_p.DataManager:loadChunk('chunk20')
--				Utilities.Teleport(CFrame.new( -304, 66, 610))-- near PB shop -507, 69, 666))--
				Utilities.Teleport(CFrame.new(-348, 62, 582)) -- in front of hoverboard shop
			elseif testPoint == 21 then
				_p.DataManager:loadChunk('chunk21')
--				Utilities.Teleport(CFrame.new(-3261, 268, 2364)) -- in front of 4th Gym
				Utilities.Teleport(CFrame.new(-3507, 268, 2249)) -- in front of Pokemon Center
			elseif testPoint == 22 then
				_p.DataManager:loadChunk('chunk22')
				Utilities.Teleport(CFrame.new(-4236, 242, 2252)) -- outside power plant
--				Utilities.Teleport(CFrame.new(-4183, 241, 2163)) -- right outside the door to sewers, I think
			elseif testPoint == 23 then
				_p.DataManager:loadChunk('chunk23')
				Utilities.Teleport(CFrame.new(-113, 73, 780))-- -131, 75, 952))-- 
			elseif testPoint == 24 then
				_p.DataManager:loadChunk('chunk24')
--				Utilities.Teleport(CFrame.new(1196, 56, -748))
				Utilities.Teleport(CFrame.new(815, 56, -623)) -- in front of gate to Aredia City
--				Utilities.Teleport(CFrame.new(960, 83, -803)) -- in front of Catacombs
			elseif testPoint == 25 then
				_p.DataManager:loadChunk('chunk25')
--				Utilities.Teleport(CFrame.new(-474, 46, 1416)) -- in front of Pokemon Center
				Utilities.Teleport(CFrame.new(-235, 40, 1219)) -- in front of snake charmer
			elseif testPoint == 26 then
				_p.DataManager:loadChunk('chunk26')
				Utilities.Teleport(CFrame.new(-388, 38, -1556))
			elseif testPoint == 27 then
				_p.DataManager:loadChunk('chunk27')
				Utilities.Teleport(CFrame.new(-424, 129, -1979)) -- in front of old castle entrance
--				Utilities.Teleport(CFrame.new(-752, 140, -1971)) -- near gate to Aredia City
			elseif testPoint == 28 then
				_p.DataManager:loadChunk('chunk28')
				Utilities.Teleport(CFrame.new(-990, 36, 298)) -- left wing
			elseif testPoint == 29 then
				_p.DataManager:loadChunk('chunk29')
				Utilities.Teleport(CFrame.new(-853, 37, 413))
			elseif testPoint == 30 then
				_p.DataManager:loadChunk('chunk30')
				Utilities.Teleport(CFrame.new(-912, 25, 570))
				
			elseif testPoint == 32 then
				_p.DataManager:loadChunk('chunk32')
				Utilities.Teleport(CFrame.new(-794, 46, 852))
			elseif testPoint == 33 then
				_p.DataManager:loadChunk('chunk33')
--				Utilities.Teleport(CFrame.new(-923, 63, 982)) -- front of room
				Utilities.Teleport(CFrame.new(-734, 75, 981)) -- by sarcophagus
			elseif testPoint == 34 then
				_p.DataManager:loadChunk('chunk34')
				Utilities.Teleport(CFrame.new(-981, 83, 1082))
			elseif testPoint == 35 then
				_p.DataManager:loadChunk('chunk35')
				Utilities.Teleport(CFrame.new(-897, 8, 1166))
			elseif testPoint == 36 then
				_p.DataManager:loadChunk('chunk36')
--				Utilities.Teleport(CFrame.new(981, 127, 2266))
				Utilities.Teleport(CFrame.new(776, 167, 2930)) -- outside Route 13 (cave) entrance
			elseif testPoint == 37 then
				_p.DataManager:loadChunk('chunk37')
				Utilities.Teleport(CFrame.new(-575, 17, 1447))
				
			elseif testPoint == 39 then
				_p.DataManager:loadChunk('chunk39')
--				Utilities.Teleport(CFrame.new(1151, -10, 1066))
				Utilities.Teleport(CFrame.new(1085, -16, 1123)) -- in front of PB Stamp Shop
			elseif testPoint == 40 then
				_p.DataManager:loadChunk('chunk40')
				Utilities.Teleport(CFrame.new(831, 23, 790))
			elseif testPoint == 41 then
				_p.DataManager:loadChunk('chunk41')
				Utilities.Teleport(CFrame.new(564, 28, 1031))
			elseif testPoint == 42 then
				_p.DataManager:loadChunk('chunk42')
				Utilities.Teleport(CFrame.new(1552, -23, 1059))
			elseif testPoint == 43 then
				_p.DataManager:loadChunk('chunk43')
				Utilities.Teleport(CFrame.new(659, 97, 1345))
			elseif testPoint == 44 then
				_p.DataManager:loadChunk('chunk44')
				Utilities.Teleport(CFrame.new(1126, 37, 1533))
				
				
			elseif testPoint == -5 then -- gym 5
				_p.DataManager:loadChunk('gym5')
				Utilities.Teleport(CFrame.new(-130, 83, 350, -1, 0, 0, 0, 1, 0, 0, 0, -1))
			elseif testPoint == -6 then -- gym 6
				_p.DataManager:loadChunk('gym6')
				Utilities.Teleport(CFrame.new(982, 51, 503))
				
			elseif testPoint == -10 then -- hoverboards
				game.ServerStorage.MapChunks.HoverTest.Parent = workspace
				Utilities.Teleport(CFrame.new(-18, 5, 107))
				
			elseif testPoint == -1 then
				local l = game.Lighting
				local c = Color3.new(78/255, 133/255, 191/255)
				l.Ambient = c
				l.OutdoorAmbient = c
				l.FogColor = Color3.new(78/400, 133/400, 191/400)
				l.FogStart = 0
				l.FogEnd = 100
				_p.DataManager:loadChunk('mining')
				Utilities.Teleport(CFrame.new(196, 7, 614))
			elseif testPoint == -2 then
				_p.forceContinue = true
				_p.loadedData = {}
--				_p.DataManager:loadChunk('colosseum')
				Utilities.Teleport(CFrame.new(9.248, 3, -145.876))
				Utilities.Teleport = function() end
				workspace.CurrentCamera.CFrame = CFrame.new(3.22578025, 7.84421825, -156.306686, -0.866023064, 0.13376981, -0.481777638, -0, 0.963547409, 0.267537415, 0.500004113, 0.231693566, -0.834454238)
			end
			require(script.Parent.TestPlayerData)
			_p.Menu.rtd:enable()
		else
			require(script.Parent.TestPlayerData)
			_p.Menu.rtd:enable()
		end
		
		game.ReplicatedFirst:WaitForChild('Loading'):remove()
		player:WaitForChild('PlayerGui'):WaitForChild('LoadingGui'):remove()
		
--		local tag = Instance.new('ObjectValue')
--		tag.Name = 'LoadSequenceComplete'
----		if testPoint == -2 then tag.Value = 
--		tag.Parent = player
	end
--	wait(.5)
	game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
--end
	
	_p.RunningShoes:enable()
	PlayerData.ownedGamePassCache[require(game.ServerStorage.Plugins.Assets).passId.StatViewer] = true
end