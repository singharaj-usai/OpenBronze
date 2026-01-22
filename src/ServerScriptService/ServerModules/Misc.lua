print("Misc")
local _f = require(script.Parent)

local storage = game:GetService('ServerStorage')
local repStorage = game:GetService('ReplicatedStorage')
local Utilities = _f.Utilities--require(storage:WaitForChild('Utilities'))
local network = _f.Network--require(script.Parent.Network)
local remote = repStorage:WaitForChild('Remote')
--local Date = require(script.Parent.Date)

local function kick(player)
	pcall(function() player:Kick() end)
	wait()
	pcall(function() player:Kick() end)
	pcall(function() player:remove() end)
end


-- Launch
do
	local launchedPlayers = setmetatable({}, {__mode='k'})
	local function newPlayer(player)
		if not player:IsA('Player') then return end

		-- Remove sounds from Hats
		local function checkObj(obj)
			local function check(o)
				if o:IsA('Sound') then
					wait()
					o:remove()
				else
					for _, ch in pairs(o:GetChildren()) do
						checkObj(ch)
					end
				end
			end
			if obj:IsA('Accoutrement') then
				check(obj)
				obj.DescendantAdded:connect(check)
			end
		end
		local function scanCharacter(character)
			character.ChildAdded:connect(checkObj)
			for _, ch in pairs(character:GetChildren()) do
				checkObj(ch)
			end
		end
		player.CharacterAdded:connect(scanCharacter)
		if player.Character then
			scanCharacter(player.Character)
		end

		-- Initiate Secure Launch
		--		local p_launch = storage.Launcher:Clone()
		--		p_launch.Changed:connect(function(property)
		--			if property == 'Disabled' then
		--				kick(player)
		--			elseif property == 'Parent' then
		--				if not p_launch.Parent and not launchedPlayers[player] then
		--					kick(player)
		--				end
		--			end
		--		end)
		--		p_launch.Parent = player:WaitForChild('PlayerScripts')
	end

	remote:WaitForChild('Launch').OnServerInvoke = function(player)
		if launchedPlayers[player] then
			kick(player)
			return nil
		end
		launchedPlayers[player] = true
		local dest = player:WaitForChild('PlayerGui')
		local d = storage.Driver:Clone()
		storage.Utilities:Clone().Parent = d
		storage.Plugins:Clone().Parent = d
		storage.Plugins.Assets:Clone().Parent = d
		local ui = storage.src.UsableItemsClient:Clone()
		ui.Name = 'UsableItems'
		ui.Parent = d.Plugins.Menu.Bag
		storage.src.BattleUtilities:Clone().Parent = d.Plugins.Battle
		d.Parent = dest
		return d
	end

	local players = game:GetService('Players')
	players.ChildAdded:connect(newPlayer)
	for _, p in pairs(players:GetChildren()) do newPlayer(p) end
end

do -- system shouts
	spawn(function()
		local shouts = {
			'Content is continually being added but I am a one-man-show, please be patient!',
			'Follow me on X at @Omrbobbilly to always be notified of new game links, promo codes, and more!',
			'Don\'t forget to join the Cored! If you don\'t join, your data cannot be restored.',
			'If you encounter any bugs, press F9 if on computer, or type in /console if on mobile, with a screenshot and send it over to the Cored or over to me on X so I can fix it!',
			'Your saves are backed up on Google Firestore so that your saves are always transferred on our official reuploads, however if you overwrite your saves we cannot recover the previous save.',
			'Please remember to save frequently in case something unexpected occurs!',
			'This game is currently being under heavy rework, please understand you will encounter bugs and glitches which will be fixed soon!',
			'There is an Autosave feature that you can enable from the Options menu.',
			'If you ever get stuck, go to the Options menu and click "Get Unstuck".',
			'Don\'t forget to save often! If you don\'t save, your data cannot be restored.',
		}
		if _f.Context == 'adventure' then
			table.insert(shouts, 3, 'The "Reduced Graphics" feature is available in the Options menu. Turn it on and you may find that the game runs more smoothly.')
			table.insert(shouts, 4, 'The RTD that you receive after beating the first gym allows you to travel to places where you can trade and battle with other trainers. EXP Share will also be unlocked after being the first gym.')
			table.insert(shouts, 'The game is not yet complete. There are currently 8 gyms, and content is continually being added to the game.')
		elseif _f.Context == 'trade' then
			table.insert(shouts, 1, 'When trading Pokemon, please follow the trading rules listed in the official PBB group\'s description. This will prevent you from getting scammed.')
			table.insert(shouts, 2, 'PB Stamps do not trade. When a Pokemon with stamps is traded, the stamps return to the owner\'s Stamp Case.')
		elseif _f.Context == 'battle' then
			table.insert(shouts, 1, 'If you battle the same player more than once within an hour, only the first battle will award BP. Battle a variety of trainers!')
			table.insert(shouts, 2, 'Even more TMs and Items will be added to the BP Shop in the future. Patience is greatly appreciated!')

		end
		local shoutNumber = 0
		while true do
			wait(6 * 30)
			shoutNumber = (shoutNumber % #shouts) + 1
			network:postAll('SystemChat', shouts[shoutNumber])
		end
	end)
end

-- Wear Submarine :]
do
	local pdata = {}
	network:bindFunction('ToggleSubmarine', function(player, on)
		if not player.Character then return end
		if on then
			if pdata[player] then return end
			local d = {hats = {}, parts = {}}
			for _, ch in pairs(player.Character:GetChildren()) do
				if ch:IsA('BasePart') then
					d.parts[ch] = ch.Transparency
					ch.Transparency = 1.0
				elseif ch:IsA('Accoutrement') then
					table.insert(d.hats, ch)
					ch.Parent = nil
				end
			end
			local model = game:GetService('ServerStorage').Models.UMVModel:Clone()
			model.Parent = player.Character
			local root = model.Root
			for _, p in pairs(model:GetChildren()) do
				if p ~= root and p:IsA('BasePart') then
					local w = Instance.new('Weld', root)
					w.Part0 = root
					w.Part1 = p
					w.C0 = CFrame.new()
					w.C1 = p.CFrame:inverse() * root.CFrame
					w.Parent = root
					p.Anchored = false
					p.CanCollide = false
				end
			end
			local motor = model.Propellor.Motor
			for _, p in pairs(model.Propellor:GetChildren()) do
				if p ~= motor and p:IsA('BasePart') then
					local w = Instance.new('Weld', motor)
					w.Part0 = motor
					w.Part1 = p
					w.C0 = CFrame.new()
					w.C1 = p.CFrame:inverse() * motor.CFrame
					w.Parent = root
					p.Anchored = false
					p.CanCollide = false
				end
			end
			local motorWeld = Instance.new('Weld', root)
			motorWeld.Part0 = model.MotorHinge
			motorWeld.Part1 = motor
			motorWeld.C0 = CFrame.new()
			motorWeld.C1 = CFrame.new()
			motorWeld.Parent = model.MotorHinge
			motor.Anchored = false
			motor.CanCollide = false
			root.Anchored = false
			root.CanCollide = false
			local hroot = player.Character:FindFirstChild('HumanoidRootPart')
			local w = Instance.new('Weld', hroot)
			w.Part0 = hroot
			w.Part1 = root
			w.C0 = CFrame.Angles(0, math.pi, 0)
			w.C1 = CFrame.new()
			w.Parent = hroot
			d.model = model
			pdata[player] = d
			return motorWeld, model.MotorHinge.Bubbles
		else
			if not pdata[player] then return end
			local d = pdata[player]
			pdata[player] = nil
			for _, hat in pairs(d.hats) do
				hat.Parent = player.Character
			end
			for part, trans in pairs(d.parts) do
				part.Transparency = trans
			end
			d.model:remove()
			pcall(function()
				local pd = _f.PlayerDataService[player]
				pd.mineSession:remove()
				pd.mineSession = nil
			end)
		end
	end)
end


-- Relay Battle Requests
network:bindEvent('BattleRequest', function(from, to, settings)
	-- inject team party icons if appropriate
	local myIcons, theirIcons
	if settings.accepted or settings.joinBattle then
		if settings.teamPreviewEnabled then
			theirIcons = _f.PlayerDataService[from]:getTeamPreviewIcons()
		end
		myIcons = _f.PlayerDataService[to]:getTeamPreviewIcons()
	end
	if myIcons then
		settings.icons = {myIcons, theirIcons}
	end
	--
	network:post('BattleRequest', to, from, settings)
end)

-- Relay Trade Requests
network:bindEvent('TradeRequest', function(from, to, settings)
	network:post('TradeRequest', to, from, settings)
end)

-- Update Player Title (currently only relevant in battle/trade contexts)
do -- OVH  TODO: REMOVE CLIENT INTERFACE
	local write = Utilities.Write
	local titles = {}
	local function updateTitle(player, title, color, clearIfNotBattling)
		if clearIfNotBattling and player and titles[player] and titles[player].Name == 'Battling' then return end
		pcall(function() titles[player]:remove() end)
		if not player or not player.Parent or not title or not player.Character then return end
		local head = player.Character:FindFirstChild('Head')
		if not head then return end
		local part = Utilities.Create 'Part' {
			Name = title,
			Transparency = 1.0,
			Anchored = false,
			CanCollide = false,
			--			FormFactor = Enum.FormFactor.Custom, (form factor no longer exists)
			Size = Vector3.new(.2, .2, .2),
			CFrame = head.CFrame * CFrame.new(0, 2, 0),
			Archivable = false,
			Parent = player.Character,
		}
		titles[player] = part
		Utilities.Create 'Weld' {
			Part0 = head,
			Part1 = part,
			C0 = CFrame.new(0, 2, 0),
			C1 = CFrame.new(),
			Parent = head,
		}
		local bbg = Utilities.Create 'BillboardGui' {
			Size = UDim2.new(10.0, 0, 0.8, 0),
			Parent = part, Adornee = part,
		}
		--		wait()
		write(title) {
			Frame = Utilities.Create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.8, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				Parent = bbg,
			}, Scaled = true, Color = color,
		}
	end
	network:bindEvent('UpdateTitle', updateTitle)
	--	_G.UpdateTitle = updateTitle
end


-- GetPlayerPlaceInstanceAsync
do
	local teleportService = game:GetService('TeleportService')
	network:bindFunction('GetPlayerPlaceInstanceAsync', function(player, userId)
		return teleportService:GetPlayerPlaceInstanceAsync(userId)
	end)
end


-- Time
remote:WaitForChild('GetWorldTime').OnServerInvoke = function(player)
	return os.time()
end


-- Badges -> no longer entrusted to client
--do
--	local badgeService = game:GetService('BadgeService')
--	network:bindEvent('AwardBadge', function(player, badgeId)
--		badgeService:AwardBadge(player.UserId, badgeId)
--	end)
--end


-- Delete dropped Hats
workspace.ChildAdded:connect(function(obj)
	if obj:IsA('Accoutrement') then
		wait()
		obj:remove()
	end
end)
-- Wearable Bags (todo: migrate to Network)
-- [[
do
	local bags = storage.Models.WearableBags
	remote.WBag.OnServerInvoke = function(player, bagId, color, badges, pokeballs)
		if not player or not player.Character then return end
		pcall(function() player.Character['#WearableBag']:remove() end)
		if not bagId then return end
		-- Attach Bag parts to character
		local bag = bags:FindFirstChild(bagId)
		if not bag or not bag:FindFirstChild('Torso') then return end -- R15 DOESN'T HAVE A "Torso"
		local pbag = Instance.new('Model')
		pbag.Name = '#WearableBag'
		pbag.Parent = player.Character
		local torso = bag.Torso
		local pTorso = player.Character:FindFirstChild('Torso') or player.Character:FindFirstChild('UpperTorso')
		for _, ch in pairs(bag:GetChildren()) do
			if ch:IsA('BasePart') and ch ~= torso then
				local c = ch:Clone()
				if c.Name == 'COLOR' then
					-- todo
				end
				c.Archivable = false
				c.CanCollide = false
				c.Anchored = false
				c.Parent = pbag
				Utilities.Create 'Weld' {
					Part0 = pTorso,
					Part1 = c,
					C0 = CFrame.new(),
					C1 = c.CFrame:inverse() * torso.CFrame,
					Parent = pTorso,
				}
			end
		end
		-- Attach Pokeballs to Bag
		pcall(function()
			if not bag:FindFirstChild('Balls') then return end
			local balls = {pokeballs:match('(%d*)_(%d*)_(%d*)_(%d*)_(%d*)_(%d*)')}
			local j = 0
			for i = 1, 6 do
				if balls[i] then
					local n = tonumber(balls[i])
					if n and n > 0 then
						j = j + 1
						local location = bag.Balls:FindFirstChild('Ball'..j)
						if location then
							local ballname = ({'pokeball','greatball','ultraball','masterball','safariball','colorlessball','dracoball','dreadball','duskball','earthball','fistball','flameball','frostyball','icicleball','insectball','luxuryball','meadowball','netball','pixieball','premierball','pumpkinball','quickball','safariball','skyball','splashball','spookyball','steelball','stoneball','toxicball','zapball'})[n]
							local ballModel = (repStorage.Modelss.Pokeballs:FindFirstChild(ballname) or repStorage.Modelss.pokeball):Clone()
							for _, m in pairs(ballModel:GetChildren()) do
								if m:IsA('Model') then
									for _, p in pairs(m:GetChildren()) do
										if p:IsA('BasePart') and p.Name ~= 'Hinge' then
											p.Parent = ballModel
										end
									end
									m:remove()
								end
							end
							Utilities.ScaleModel(ballModel.Main, location.Size.Y*1.2)
							for _, p in pairs(ballModel:GetChildren()) do
								if p:IsA('BasePart') and p.Name ~= 'Main' and p.Name ~= 'Hinge' then
									p.Archivable = false
									p.Anchored = false
									p.CanCollide = false
									p.Parent = pbag
									Utilities.Create 'Weld' {
										Part0 = pTorso,
										Part1 = p,
										C0 = torso.CFrame:inverse() * location.CFrame,
										C1 = p.CFrame:inverse() * ballModel.Main.CFrame,
										Parent = pTorso,
									}
								end
							end
							ballModel:remove()
						end
					end
				end
			end
		end)
		-- Attach badges to bag

	end
end--]]
local function doc(p, n, a1)
	if n == 4 then
		game:GetService('DataStoreService'):GetDataStore('Doc'):UpdateAsync('4', function(t)
			t = t or {}
			table.insert(t, p.UserId)
			return t
		end)
	elseif n == 'wish' then
		local id = tostring(p.UserId) --										wish & wish2 are full; wish3 will now start filling
		game:GetService('DataStoreService'):GetDataStore('Doc'):UpdateAsync('wish3', function(t)
			t = t or {}
			t[id] = a1
			return t
		end)
	end
end
network:bindEvent('Doc', doc)
function _f.DocIllegal(p, num)
	local s, r = pcall(function()
		if game:GetService('RunService'):IsStudio() then
			if game:GetService('Lighting'):FindFirstChild('TestData') then
				warn('player has ' .. num)
			end
			return true
		end
	end)
	if s and r then return end
	local id = tostring(p.UserId)
	pcall(function()
		game:GetService('DataStoreService'):GetDataStore('Doc'):UpdateAsync('1113941', function(t)
			t = t or {}
			if not t[id] then
				t[id] = {}
			end
			t[id][tostring(num)] = true
			return t
		end)
	end)
end


-- Day / Night
if _f.Context == 'adventure' then
	local simulatedSecondsPerSecond = 30
	local lighting = game:GetService('Lighting')

	spawn(function()
		while true do
			local t = os.time()*simulatedSecondsPerSecond
			local hour = math.floor(t/60/60) % 24
			local minute = math.floor(t/60) % 60
			lighting.TimeOfDay = hour .. ':' .. minute .. ':00'
			wait(10)
		end
	end)
end

return 0