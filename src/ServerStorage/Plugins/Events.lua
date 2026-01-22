-- OVH  replace DM:getData('Battle', n) with simple pass n to server
-- _p.PlayerData:completeEvent(name, ...)
-- todo: search with regexp: completedEvents.*=\s*true

-- 1. Arc Badge
-- 2. Brimstone Badge
-- 3. Float Badge
-- 4. Soaring Badge
-- 5. Crater Badge
-- 6. Harvest Badge
-- 7. Peak Badge


return function(_p)--local _p = require(script.Parent)
	--local root = _p.player.Character.HumanoidRootPart
	local Utilities = _p.Utilities
	--local MasterControl = _p.MasterControl
	local create = Utilities.Create
	local Tween = Utilities.Tween
	local rc4 = Utilities.rc4
	local network = _p.Network
	local RENDER_PRIORITY_CAMERA = Enum.RenderPriority.Camera.Value
	local Sprite-- = require(script.Parent.Battle.Sprite)

	local players = game:GetService('Players')
	local stepped = game:GetService('RunService').RenderStepped
	local heartbeat = game:GetService('RunService').Heartbeat

	local completedEvents, chat, interact
	local sceneSignal

	local function ElectricitySound()
		Utilities.sound(4591549719, nil, nil, 10)
	end		

	local function onObtainItemSound()
		Utilities.sound(288899943, nil, nil, 10)
	end
	local function onObtainBadgeSound()
		Utilities.sound(12639886125, nil, nil, 10)
	end
	local function onObtainKeyItemSound()
		Utilities.sound(304774035, nil, nil, 10)
	end

	_p.storage.Remote.PickUpManaphyEgg.PlaySound.OnClientEvent:connect(function(eggMain)
		pcall(function() while not eggMain.Parent.Parent do wait() end end)
		pcall(function()
			if _p.DataManager.currentChunk.id ~= 'chunk11' then return end
			Utilities.sound(409175253, 4, nil, 10, eggMain)
		end)
	end)

	_p.Network:bindEvent('eggFound', function()
		pcall(function()
			_p.PlayerData.daycareManHasEgg = true
			local chunk = _p.DataManager.currentChunk
			if chunk.id == 'chunk9' then
				local dcm = chunk.npcs.DayCareMan
				dcm:Look(Vector3.new(1, 0, 1).unit)
			end
		end)
	end)


	local function touchEvent(eventName, part, completeOnTouch, eventFn)
		if eventName and completedEvents[eventName] then return end
		local cn; cn = part.Touched:connect(function(p)
			if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
			cn:disconnect()
			if eventName and completedEvents[eventName] then return end
			if eventName and completeOnTouch then
				spawn(function() _p.PlayerData:completeEvent(eventName) end) -- is this all? just assume it's a plain trusted event?
			end
			eventFn()
		end)
	end
	
	local doLeaveSafariDialogue = function()
		if _p.DataManager.currentChunk.id ~= 'chunk77' then return end

		spawn(function() _p.Menu:disable() end)
		_p.MasterControl:Stop()
		_p.Hoverboard:unequip(true) 
		if chat:say("[y/n]Do you want to leave the Safari Zone early?") then
			_p.Events.leaveSafari(_p.DataManager.currentChunk)
			return true
		end
		_p.MasterControl.WalkEnabled = true
		_p.Menu:enable()
		return true
	end

	-- Events:
	-- onLoad Chunk (chunk)
	-- onUnload Chunk ()
	-- onDoorFocused Building ()
	-- onBeforeEnter Building/SubRoom (room [, continueCFrame])
	-- onExit Building/SubRoom ()
	-- onExitC OldChunk (newChunk) #fired when exiting a door that led from chunk to chunk
	-- cameraOffset Building/SubRoom () -> return a function to produce camera offset
	return {
		init = function()
			completedEvents = _p.PlayerData.completedEvents
			chat = _p.NPCChat
			interact = chat.interactableNPCs
			Sprite = _p.Battle._SpriteClass
		end,

		-- Sub-Contexts
		onLoad_colosseum = function(chunk)

			local bottlecap = chunk.npcs.HyperTrainer
			interact[bottlecap.model] = function()
				chat:say(bottlecap, 'Ayyyye what\'s up, Hyper Trainer here.',
					'With my Hyper Training, you can boost your Pokemon\'s stats!'
				)
				local r, r2 = _p.Network:get('PDS', 'hasbottlecaps')
				if chat:say(bottlecap, '[y/n]In exchange for Bottle Caps, that is! Wanna try?') then
					if r == 0 and r2 == 0 then
						chat:say(bottlecap, 'You don\'t seem to have any Bottle Caps, come back later if you get any!')
						return
					end
					spawn(function() _p.Menu:disable() end)
					local a = {
						'Gold Bottle Cap',
						'Silver Bottle Cap'
					}

					if r == 0 then
						table.remove(a, 2)
					end
					if r2 == 0 then
						table.remove(a, 1)
					end
					table.sort(a)

					chat:say(bottlecap, 'Which Pokemon do you want to train?')
					local slot = _p.BattleGui:choosePokemon('Train')
					if not slot then
						chat:say(bottlecap, 'Ok, then come back if you want to train your Pokemon.')
						spawn(function() _p.Menu:enable() end)
						return
					end
					local useCapType

					if #a == 1 then
						if not chat:say(bottlecap, '[y/n]'..a[1]..' will be used is that okay?') then
							spawn(function() _p.Menu:enable() end)
							return
						else
							useCapType = a[1]
						end
					else
						chat:say(bottlecap, 'Which type of bottle cap do you want to use?')
						useCapType = a[_p.NPCChat:choose(unpack(a))]
					end

					if useCapType == 'Silver Bottle Cap' then
						local options = {
							'HP',
							'Attack',
							'Defense',
							'Sp Atk',
							'Sp Def',
							'Speed',
						}
						local choice = options[_p.NPCChat:choose(unpack(options))]
						if chat:say(bottlecap, '[y/n]Alright, so you want to Hyper Train in '..choice..'?') then
							local ivs = _p.Network:get('PDS', 'getivs', slot, choice)
							if ivs >= 31 then
								chat:say(bottlecap, 'The '..choice..' stats are already maxed.')
								spawn(function() _p.Menu:enable() end)
								return
							end
							chat:say(bottlecap, 'Alright! Time to do some Hyper Training!')
							_p.Network:get('PDS', 'trainpokemon', slot, choice)
							chat:say(bottlecap, '...',
								'... ...',
								'... ... ...'
							)
							chat:say(bottlecap, 'Success!')
							chat:say(bottlecap, 'We\'ve successfully trained our '..choice..' stats!')
							chat:say(bottlecap, 'I\'ll take that Silver Bottle Cap now.')
							chat:say(bottlecap, 'Thanks! Never stop training!')
							spawn(function() _p.Menu:enable() end)
						else
							chat:say(bottlecap, 'Ok, then come back if you want to train your Pokemon.')
							spawn(function() _p.Menu:enable() end)
						end
					else
						local trained = _p.Network:get('PDS', 'getivs', slot, 'all')
						if chat:say(bottlecap, '[y/n]Alright, so you want to Hyper Train all the stats?') then
							if trained then
								chat:say(bottlecap, 'Thet pokemon\'s stats are already maxed.')
								spawn(function() _p.Menu:enable() end)
								return
							end
							chat:say(bottlecap, 'Alright! Time to do some Hyper Training!')
							_p.Network:get('PDS', 'trainpokemon', slot, 'all')
							chat:say(bottlecap, '...',
								'... ...',
								'... ... ...'
							)
							chat:say(bottlecap, 'Success!')
							chat:say(bottlecap, 'We\'ve successfully trained all of our stats!')
							chat:say(bottlecap, 'I\'ll take that Gold Bottle Cap now.')
							chat:say(bottlecap, 'Thanks! Never stop training!')
							spawn(function() _p.Menu:enable() end)
						else
							chat:say(bottlecap, 'Ok, then come back if you want to train your Pokemon.')
							spawn(function() _p.Menu:enable() end)
						end
					end
				else
					chat:say(bottlecap, 'Ok, then come back if you want to train your Pokemon.')
				end
			end

			local shopGuy = chunk.npcs.MartGuy
			interact[shopGuy.model] = function()
				spawn(function() _p.Menu:disable() end)
				chat:say(shopGuy, 'Welcome to the Battle Shop.')
				_p.Menu.battleShop:open()
				chat:say(shopGuy, 'Thank you, please come again!')
				spawn(function() _p.Menu:enable() end)
			end
			local sixth = chunk.npcs.MoveDeleter
			interact[sixth.model] = function()
				if not sixth:Say('Huh?', '[y/n]Oh, did you want me to help one of your Pok[e\']mon forget a move?') then
					sixth:Say('Oh, okay.', 'Well I\'ll be here if you change your mind later.')
					return
				end
				local moveDeleter = function()
					sixth:Say('Alright, cool. Which Pok[e\']mon?')
					local slot = _p.BattleGui:choosePokemon('Choose')
					if not slot then
						sixth:Say('Oh, okay.', 'Well I\'ll be here if you change your mind later.')
						return
					end
					local name, r = _p.Network:get('PDS', 'deleteMove', slot)
					if not r then
						sixth:Say('Oh, okay.', 'Well I\'ll be here if you change your mind later.')
						return
					elseif r == 'eg' then
						sixth:Say('That\'s an Egg...',
							'It hasn\'t even been scientifically confirmed whether or not Eggs even know moves.')
						return
					elseif r == '0m' then
						sixth:Say('Okay, first I just want to say that I\'m impressed that your Pok[e\']mon knows no moves...',
							'Maybe you should look into learning moves, not forgetting them.')
						return
					elseif r == '1m' then
						sixth:Say('Your ' .. name .. ' only knows one move.',
							'It\'s probably not a good idea to make it forget its only move.')
						return
					end
					sixth:Say(name .. ' HYPE!', 'Alright, which move should be forgotten?')
					local moveslot = _p.BattleGui:promptReplaceMove(r.moves, false)
					if not moveslot or not sixth:Say('[y/n]Are you sure you want your ' .. name .. ' to forget ' .. r.moves[moveslot].name .. '?') then
						spawn(function() _p.Network:get('PDS', 'makeDecision', r.d, nil) end)
						sixth:Say('Oh, okay.', 'Well I\'ll be here if you change your mind later.')
						return
					end
					spawn(function() _p.Network:get('PDS', 'makeDecision', r.d, moveslot) end)
					spawn(function() sixth:Say('[ma].') end)
					wait(1)
					chat:manualAdvance()
					spawn(function() sixth:Say('[ma]..') end)
					wait(1)
					chat:manualAdvance()
					spawn(function() sixth:Say('[ma]...') end)
					wait(1)
					chat:manualAdvance()
					sixth:Say('That should do it!',
						'Your ' .. name .. ' has successfully forgotten... uh... whatever move that was...')
				end
				spawn(function() _p.Menu:disable() end)
				moveDeleter()
				spawn(function() _p.Menu:enable() end)
			end
			local srybon = chunk.npcs.MoveReminder
			interact[srybon.model] = function()
				local r -- currently if canceled before choosing party slot, we get a dangling decision
				local done = false
				Utilities.fastSpawn(function()
					r = _p.Network:get('PDS', 'remindMove')
					done = true
				end)
				if not srybon:Say('Hi, I\'m the Move Reminder.', '[y/n]Would you like me to help your Pok[e\']mon remember a move?') then
					srybon:Say('If you change your mind later, be sure to come back.')
					return
				end
				local moveReminder = function()
					while not done do wait() end
					if not r then
						srybon:Say('If you change your mind later, be sure to come back.')
						return
					end
					srybon:Say('Awesome, and how will you be paying for this service today?')
					local frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.4, 0),
						Position = UDim2.new(0.05, 0, 0.55, 0),
						Parent = Utilities.gui,
					}
					do
						local icon = _p.Menu.bag:getItemIcon(r.hsi)
						icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
						icon.Size = UDim2.new(0.6, 0, 0.6, 0)
						icon.Position = UDim2.new(0.0, 0, -0.05, 0)
						icon.Parent = frame
						Utilities.Write('x' .. r.nhs) {
							Frame = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(0.0, 0, 0.2, 0),
								Position = UDim2.new(0.25, 0, 0.15, 0),
								Parent = frame,
							}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
						}
						Utilities.Write('[$]' .. _p.PlayerData:formatMoney(r.money)) {
							Frame = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(0.0, 0, 0.2, 0),
								Position = UDim2.new(0.1, 0, 0.65, 0),
								Parent = frame,
							}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
						}
					end
					local payment = chat:choose('Heart Scale', '[$]30,000', 'Cancel')
					frame:remove()
					if payment == 1 and r.nhs < 1 then
						srybon:Say('I\'m sorry, but you don\'t have any Heart Scales.',
							'Collect some and come back, or choose a different payment method.')
						return
					elseif payment == 2 and r.money < 30000 then
						srybon:Say('I\'m sorry, but you don\'t have enough [$].')
						if srybon:Say('[y/n]Would you like to buy some with ROBUX?') then
							_p.Menu.shop:buyMoney()
							if _p.PlayerData.money < 30000 then -- we get the money from PD here because hopefully it got updated during the purchase process
								srybon:Say('Save up [$] and come back, or choose a different payment method.')
								return
							end
							if not srybon:Say('[y/n]Are you still interested in helping your Pok[e\']mon remember a move?') then
								srybon:Say('If you change your mind later, be sure to come back.')
								return
							end
						else
							srybon:Say('Save up [$] and come back, or choose a different payment method.')
							return
						end
					elseif payment == 3 then
						srybon:Say('If you change your mind later, be sure to come back.')
						return
					end
					srybon:Say('Alright, now which Pok[e\']mon are we trying to teach a move to?')
					local slot = _p.BattleGui:choosePokemon('Choose')
					if not slot then
						-- hanging decision
						srybon:Say('No worries, come back if your Pok[e\']mon ever need to remember a move.')
						return
					end
					local name
					name, r = _p.Network:get('PDS', 'makeDecision', r.d, slot)
					if not r then
						srybon:Say('If you change your mind later, be sure to come back.')
						return
					elseif r == 'eg' then
						srybon:Say('That\'s an Egg...', 'It\'s never known any moves to begin with.')
						return
					elseif r == 'nm' then
						srybon:Say('Hmmm, it seems there aren\'t any moves for your ' .. name .. ' to remember.',
							'Let me know if you have any other requests.')
						return
					end
					srybon:Say('Which move would you like your ' .. name .. ' to remember?')
					local move = _p.Menu.party:remindMove(r)
					if not move then
						srybon:Say('If you change your mind later, be sure to come back.')
						return
					end
					if not srybon:Say('[y/n]You want me to teach ' .. move.name .. ' to your ' .. name .. '?') then
						srybon:Say('If you change your mind later, be sure to come back.')
						return
					end
					if not _p.Pokemon:tryLearnMove(r.nn, r.known, {id = r.d, move = move, transform = function(move, slot) return payment, move.num, slot end}) then
						-- another dangling decision
						srybon:Say('If you change your mind later, be sure to come back.')
						return
					end
					if payment == 1 then
						srybon:Say('Alright, and I\'ll accept that Heart Scale now.')
						--					_p.Menu.bag:incrementBagItem(ids.heartscale, -1)
					elseif payment == 2 then
						srybon:Say('Alright, and I\'ll accept the [$]30,000 now.')
						--					_p.PlayerData.money = math.max(0, _p.PlayerData.money - 30000)
					end
					srybon:Say('Thank you so much, have a wonderful day!')
				end
				spawn(function() _p.Menu:disable() end)
				moveReminder()
				spawn(function() _p.Menu:enable() end)
			end
		end,

		onLoad_resort = function(chunk)
			pcall(function()
				local hatch = workspace.WorldModel.Hatch
				local event = hatch.HatchButtonClicked
				hatch.Button1.ClickDetector.MouseClick:connect(function() event:FireServer() end)
				hatch.Button2.ClickDetector.MouseClick:connect(function() event:FireServer() end)
			end)
		end,
		--extra stuff
		--[[
onLoad_arcade = function(chunk)
	_p.DataManager:loadModule("Arcade"):onLoadMap(chunk)
end,
onUnload_arcade = function()
	pcall(function()
		_p.DataManager:getModule("Arcade"):onUnload()
	end)
end,
--]]		
		onBeforeEnter_ShipTickets = function(room)
			local lady = room.npcs.TicketLady
			interact[lady.model] = function()
				spawn(function()
					_p.Menu:disable()
				end)
				lady:Say("Welcome to the Port Decca travel agency!", "You can select from available tickets to travel to other places off the shores of Roria!", "Have a look at our available tickets.")
				_p.Menu.shop:buyMenu("shiptix")
				lady:Say("Thanks, come back and check with us again!")
				_p.Menu:enable()
			end
			--local steve = room.npcs.PirateSteve
			--interact[steve.model] = function() --TODO: Moltres/Articuno/Zapdos
			--	local d, done
			--	spawn(function()
			--		d = _p.Network:get("PDS", "getSteveStatus")
			--		done = true
			--	end)
			--	if not completedEvents.meetPSteve then
			--		spawn(function()
			--			_p.PlayerData:completeEvent("meetPSteve")
			--		end)
			--		if not steve:Say("Ahoy there, young scallywag!", "Looks to me like ye be the type to enjoy the occasional adventure.", "I've sailed the seventeen seas and explored the strangest of places.", "I've seen a thing or two.", "I tell ye what.", "I'll give ye special tickets to places that few have dared set foot.", "In exchange, I wonder if ye happen to have any Deep Sea Scales.", "I once had me the most beautiful sea Pokemon, with shimmering scales, the likes of which be hard to find.", "I collect these bedeepened scales in its remembrance.", "I'll trade ye one ticket for one scale.", "[y/n]What do ye say?") then
			--			return
			--		end
			--	elseif not steve:Say("Ahoy again young sea traveler.", "[y/n]Have ye brought me any Deep Sea Scales?") then
			--		return
			--	end
			--	while not done do
			--		wait()
			--	end
			--	if d == "nt" then
			--		steve:Say("Avast! I be all out of tickets!")
			--	elseif d == "ns" then
			--		steve:Say("Avast! Ye don't have any Deep Sea Scales!")
			--	elseif type(d) == "table" then
			--		local choices = {}
			--		for i, v in pairs(d) do
			--			choices[i] = v .. " Ticket"
			--		end
			--		table.insert(choices, "Cancel")
			--		local choice = chat:choose(unpack(choices))
			--		local t = d[choice]
			--		if not t then
			--			return
			--		end
			--		_p.Network:post("PDS", "tradeScaleForTicket", t)
			--		steve:Say("Aye, here ye go!")
			--		onObtainKeyItemSound()
			--		chat.bottom = true
			--		chat:say("Obtained " .. Utilities.aOrAn(t) .. " Ticket!", _p.PlayerData.trainerName .. " put the " .. t .. " Ticket in the Bag.")
			--		chat.bottom = nil
			--	end
			--end
		end,		



		-- Main story: Act I
		onExit_yourhomef1 = function()
			if completedEvents.MeetJake then return end
			spawn(function() _p.PlayerData:completeEvent('MeetJake') end)
			spawn(function() _p.Menu:disable() end)

			local jake = _p.NPC:new(_p.storage.Modelss.NPCs.Jake:Clone())--_p.DataManager.currentChunk.npcs.Jake
			jake.model.Parent = _p.DataManager.currentChunk.map
			jake:Animate()
			pcall(function() jake.model.Interact:remove() end)
			chat:say('Hey ' .. _p.PlayerData.trainerName .. ', it\'s me, Jake!')
			local playerPos = _p.player.Character.HumanoidRootPart.Position
			local jakePos = Vector3.new(-7.8, 53.7, 148)
			jake:Teleport(CFrame.new(jakePos, playerPos))
			spawn(function() _p.MasterControl:LookAt(jakePos) end)
			local cam = workspace.CurrentCamera
			local camP = CFrame.new(cam.CoordinateFrame.p+Vector3.new(-1, -8, -4), jake.model.Head.Position)
			local walking = true
			spawn(function()
				jake:WalkTo(playerPos+(jake.model.HumanoidRootPart.Position-playerPos).unit*7)
				walking = false
			end)
			local start = tick()
			while true do
				stepped:wait()
				if tick()-start > 4 then
					cam.CoordinateFrame = CFrame.new(camP.p, jake.model.Head.Position)
					break
				end
				local speed = 0.05 + 0.1*(tick()-start)
				local cf = cam.CoordinateFrame
				local focus = cf.p + cf.lookVector * (jake.model.Head.Position - cf.p).magnitude
				if (jake.model.Head.Position-focus).magnitude < 0.2 and not walking then break end
				cam.CoordinateFrame = CFrame.new(cf.p + (camP.p-cf.p)*speed, focus + (jake.model.Head.Position-focus)*speed)
			end
			chat:say(jake, 'I can\'t believe we\'re getting our first Pok[e\']mon today!',
				'This is the day we\'ve dreamed of since we were kids!',
				'I\'m sure you\'ve heard of that somewhere so many times at this point',
				'Anyways, I\'m on my way to the lab to get mine right now!',
				'Oh yeah, your parents wanted to see you before you went to the lab.',
				'I saw them pass my house earlier, heading towards the digging site.',
				'Hurry and go talk to them.',
				'I\'ll be waiting for you at the lab like usual!')
			spawn(function()
				jake:WalkTo(Vector3.new(-27, 53.7, 151.6))
				jake:WalkTo(Vector3.new(-48.8, 53.7, 169))
				jake:WalkTo(Vector3.new(-148.2, 58.7, 175.6))
				local door = _p.DataManager.currentChunk:getDoor('lab')
				door:open(.5)
				jake:WalkTo(Vector3.new(-152.2, 58.7, 175.6))
				door:close(.5)
				jake:remove()--jake:Teleport(CFrame.new(3.1, 88, 389))
			end)
			delay(.5, function() _p.Menu:enable() end)

			return true
		end,

		onLoad_chunk1 = function(chunk)
			-- eclipse grunts
			if completedEvents.ParentsKidnappedScene then
				chunk.npcs.EclipseGrunt1:remove()
				chunk.npcs.EclipseGrunt2:remove()
			end
			-- heal guy
			local healer = chunk.npcs.HealGuy
			interact[healer.model] = function()
				if completedEvents.ChooseFirstPokemon then
					healer:Say('Here, let me heal your Pok[e\']mon for you!')
					_p.Network:get('PDS', 'getPartyPokeBalls')
				else
					healer:Say('It\'s dangerous to enter the tall grass without a Pok[e\']mon of your own.')
				end
			end
			-- block for no party
			local block = chunk.map.NoPokemonBlocker
			if completedEvents.ChooseFirstPokemon then
				block:remove()
			else
				local db = false
				block.Touched:connect(function(p)
					if db or not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
					db = true
					if completedEvents.ChooseFirstPokemon then
						block:remove()
						_p.MasterControl.WalkEnabled = false
						_p.MasterControl:Stop()
						healer:Say('Good luck on your adventures out there!',
							'I know I probably look familiar, I can promise you it\'s not dejavu.',
							'If your Pok[e\']mon ever need a quick healing, come talk to me.')
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
					else
						_p.MasterControl.WalkEnabled = false
						_p.MasterControl:Stop()
						healer:Say('Remember, it\'s dangerous to enter the tall grass without a Pok[e\']mon of your own.')
						_p.player:Move(Vector3.new(0, 0, 1), false)
						wait(.45)
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
					end
					db = false
				end)
			end
			-- Cutscene for parents intro
			if not completedEvents.MeetParents then
				local momCF = CFrame.new(Vector3.new(152.2, 69.1, 254.6), Vector3.new(169.2, 69.1, 260.6))
				local dadCF = CFrame.new(Vector3.new(150.2, 69.1, 260.6), Vector3.new(169.2, 69.1, 260.6))
				local momModel = _p.storage.Modelss.NPCs.Mom:Clone()
				local dadModel = _p.storage.Modelss.NPCs.Dad:Clone()
				Utilities.MoveModel(momModel.HumanoidRootPart, momCF, true)
				Utilities.MoveModel(dadModel.HumanoidRootPart, dadCF, true)
				momModel.Parent = chunk.map
				dadModel.Parent = chunk.map
				local mom = _p.NPC:new(momModel)
				local dad = _p.NPC:new(dadModel)
				mom:Animate()
				dad:Animate()
				touchEvent('MeetParents', chunk.map.ParentsCutsceneTrigger, true, function()
					spawn(function() _p.Menu:disable() end)
					spawn(function()
						local cam = workspace.CurrentCamera
						cam.CameraType = Enum.CameraType.Scriptable
						local _, lerp = Utilities.lerpCFrame(cam.CoordinateFrame, CFrame.new(134, 77, 256, -0.164034188, 0.265323371, -0.950103402, -3.7252903e-09, 0.963149667, 0.268966585, 0.986454725, 0.0441197194, -0.157989442))
						Tween(2, 'easeInOutCubic', function(a)
							local cf = lerp(a)
							cam.CoordinateFrame = CFrame.new(cf.p, cf.p+cf.lookVector)
						end)
					end)
					local playerPos = Vector3.new(144, 69.1, 256)
					_p.MasterControl:WalkTo(playerPos, 12)
					_p.MasterControl:LookAt(momCF.p + (dadCF.p-momCF.p)/2)
					_p.MasterControl.WalkEnabled = false
					chat:say(mom, 'Well that ought to take care of it...')
					chat:say(dad, 'We have to keep this a secret, for everyone\'s safety.')
					chat:say(mom, 'You\'re right.',
						'It\'s too dangerous for anyone to go down there.')
					chat:say(dad, 'I don\'t think we should tell anybody about this.')
					chat:say(mom, 'Maybe we can tell that new professor.')
					chat:say(dad, 'Maybe you\'re right.')
					mom:LookAt(playerPos)
					dad:LookAt(playerPos)
					chat:say(mom, 'Oh, '.._p.PlayerData.trainerName..'!',
						'You startled me!')
					chat:say(dad, 'Hey, champ!',
						'Today is the day you get your first Pok[e\']mon!')
					chat:say(mom, 'We are so happy for you, sweetie!')
					chat:say(dad, 'Sorry we didn\'t meet you at home like always.',
						'We just discovered something in the cave last night.',
						'As archeologists, your mother and I are very thorough in our work.')
					chat:say(mom, 'That\'s right, but enough talking.',
						'Let\'s head down to the professor\'s lab and let you pick your very first Pok[e\']mon!')
					chat:say(dad, 'We\'ll see you there!')
					local nodes = {
						Vector3.new(129.2, 69.1, 234.8),
						Vector3.new(121.2, 69.1, 213.8),
						Vector3.new(117.2, 61.1, 199.8),
						Vector3.new( 88.2, 61.1, 192.8),
					}
					local door = _p.DataManager.currentChunk:getDoor('lab')
					spawn(function()
						wait(.6)
						for _, node in pairs(nodes) do
							mom:WalkTo(node)
						end
						mom:WalkTo(Vector3.new(-144.2, 58.7, 175.6))
						wait(.5)
						mom:WalkTo(Vector3.new(-152.2, 58.7, 175.6))
						door:close(.5)
						mom:remove()
						dad:remove()
					end)
					spawn(function()
						for _, node in pairs(nodes) do
							dad:WalkTo(node)
						end
						dad:WalkTo(Vector3.new(-148.2, 58.7, 175.6))
						door:open(.5)
						dad:WalkTo(Vector3.new(-156.2, 58.7, 175.6))
					end)

					wait(1.5)
					Utilities.lookBackAtMe()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
				end)
			end
		end,

		onBeforeEnter_lab = function(room)
			local starterData = _p.Network:get('PDS', 'getStarterData')
			local sds = {}
			for _, sd in pairs(starterData) do table.insert(sds, sd[2]) end
			_p.DataManager:preloadSprites(unpack(sds))

			if completedEvents.MeetJake then
				local function arrangeNPCs()
					local jake = _p.NPC:PlaceNew('Jake', room.model, room.model.Base.CFrame * CFrame.new(-5, 4, 5) * CFrame.Angles(0, -1.75, 0))
					local prof = _p.NPC:PlaceNew('Professor', room.model, room.model.Base.CFrame * CFrame.new(-5, 4, 15) * CFrame.Angles(0, -math.pi/2, 0))
					local mom  = _p.NPC:PlaceNew('Mom', room.model, room.model.Base.CFrame * CFrame.new(0, 4, 25) * CFrame.Angles(0, 0.2, 0))
					local dad  = _p.NPC:PlaceNew('Dad', room.model, room.model.Base.CFrame * CFrame.new(3, 4, 23.5) * CFrame.Angles(0, 0.8, 0))
					local n = room.npcs
					table.insert(n, jake) table.insert(n, prof) table.insert(n, mom) table.insert(n, dad)
					return jake, prof, mom, dad
				end
				local function pickStarter(og)
					local sig = Utilities.Signal()
					local ready = false
					local chosenType
					local grass, fire, water
					local chooser; chooser = create 'ImageButton' { -- 600x200
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5227165907',
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						Size = UDim2.new(0.8, 0, 0.8/3, 0),
						Parent = Utilities.gui,
						MouseButton1Up = function(x)
							if not ready then return end
							ready = false
							local p = (x - chooser.AbsolutePosition.X) / chooser.AbsoluteSize.X
							if p < 0 or p > 1 then return end
							local pokemon, type
							if p < 1/3 then
								pokemon = grass[1]
								type = 'Grass'
							elseif p < 2/3 then
								pokemon = fire[1]
								type = 'Fire'
							else
								pokemon = water[1]
								type = 'Water'
							end
							chosenType = type
							if not pokemon then return end
							if chat:say('[y/n]So you would like ' .. pokemon .. ', the ' .. type .. '-type pokemon?') then
								sig:fire(pokemon)
							else
								ready = true
							end
						end,
					}
					local more = _p.RoundedFrame:new {
						BackgroundColor3 = Color3.new(.2, .2, .2),
						Size = UDim2.new(0.225, 0, 0.175, 0),
						Position = UDim2.new(0.5-0.225/2, 0, 1.05, 0),
						Parent = chooser,
					}
					Utilities.Write 'More' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.8, 0),
							Position = UDim2.new(0.5, 0, 0.1, 0),
							ZIndex = 2, Parent = more.gui,
						}, Scaled = true,
					}
					local gen = math.random(9) -- increase this by +1 for new generations
					local anims = {}
					local thread
					local function showChoices()
						ready = false
						for _, anim in pairs(anims) do
							anim:remove()
						end
						anims = {}
						local thisThread = {}
						thread = thisThread
						grass = starterData[(gen-1)*3+1]
						fire  = starterData[(gen-1)*3+2]
						water = starterData[(gen-1)*3+3]
						for i, starter in pairs({grass, fire, water}) do
							delay((i-1)*.1, function()
								local ball = create 'ImageLabel' {
									BackgroundTransparency = 1.0,
									Image = 'rbxassetid://6142797841',
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									Size = UDim2.new(0.15, 0, 0.15, 0),
									ZIndex = 2, Parent = chooser,
								}
								Tween(.3, nil, function(a)
									if thread ~= thisThread then return false end
									ball.Position = UDim2.new(i/3-1/6, -ball.AbsoluteSize.X/2, 0.1+0.65*a, 0)
								end)
								ball:remove()
								if thread ~= thisThread then return end
								local sd = starter[2]
								local animation = _p.AnimatedSprite:new(sd)
								animation:Play()
								local sprite = animation.spriteLabel
								sprite.SizeConstraint = Enum.SizeConstraint.RelativeYY
								sprite.Parent = chooser
								Tween(.3, 'easeOutCubic', function(a)
									if thread ~= thisThread then return false end
									local s = a*.6*sd.fHeight/60
									sprite.Size = UDim2.new(s/sd.fHeight*sd.fWidth, 0, s, 0)
									sprite.Position = UDim2.new(i/3-1/6, -sprite.AbsoluteSize.X/2, 0.9-s, 0)
									sprite.ImageColor3 = Color3.new(a, a, a)
								end)
								if thread ~= thisThread then
									animation:remove()
									return
								end
								table.insert(anims, animation)
								if i == 3 then
									ready = true
								end
							end)
						end
					end
					create 'ImageButton' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5218044909',
						Rotation = 180,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(-1.3, 0, 1.3, 0),
						Position = UDim2.new(-0.1, 0, -0.15, 0),
						Parent = more.gui,
						MouseButton1Click = function()
							gen = gen - 1
							if gen < 1 then gen = 9 end -- increase this too
							showChoices()
						end,
					}
					create 'ImageButton' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5218044909',
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(1.3, 0, 1.3, 0),
						Position = UDim2.new(1.1, 0, -0.15, 0),
						Parent = more.gui,
						MouseButton1Click = function()
							gen = gen + 1
							if gen > 8 then gen = 1 end
							showChoices()
						end,
					}
					Tween(.5, 'easeOutCubic', function(a)
						chooser.Position = UDim2.new(0.1, 0, 1-.8*a, 0)
					end)
					showChoices()
					local choice = sig:wait()
					Tween(.5, 'easeOutCubic', function(a)
						chooser.Position = UDim2.new(0.1, 0, .2+.8*a, 0)
					end)
					more:remove()
					chooser:remove()
					return choice
				end
				local function setupDevProduct()
					local david = room.npcs.David
					interact[david.model] = function()
						spawn(function() _p.Menu:disable() end)
						local res = (function()
							if not chat:say(david, 'The professor sells these Pok[e\']mon for 5 R$ each.', '[y/n]Would you like to purchase one?') then return end
							--						if not _p.PlayerData.pc:hasSpace() then -- OVH  TODO
							--							chat:say(david, 'It looks like you don\'t have enough space to store this Pok[e\']mon.')
							--							return true
							--						end
							if not chat:say(david, '[y/n]You\'ll have to save after you do so, are you willing to save?') then return end
							if _p.Menu.willOverwriteIfSaveFlag then
								if not chat:say(david, 'Oh my, it looks like there\'s another save file that will be overwritten.', '[y/n]Are you absolutely sure you want to overwrite that?') then return end
							end
							chat:say(david, 'Alright let\'s take a look at these Pok[e\']mon.')
							local species = pickStarter()
							spawn(function() chat:say(david, '[ma]Please wait a moment while your purchase is processed...') end)
							local loadTag = {}
							_p.DataManager:setLoading(loadTag, true)
							local r = _p.Network:get('PDS', 'buyStarter', species)
							_p.DataManager:setLoading(loadTag, false)
							chat:manualAdvance()
							if not r then
								chat:say(david, 'It seems an error occurred.', 'Hm... Try again later, I suppose.')
							elseif r == 'to' then
								chat:say(david, 'Looks like the purchase timed out.', 'No worries, though.',
									'If for some odd reason it processes later, I\'ll have ' .. species .. ' sent to your PC.',
									'Make sure to save though.')
							else
								chat:say(david, 'There we go!')
								local nickname
								if chat:say(david, '[y/n]Would you like to give a nickname to '..species..'?') then
									nickname = _p.Pokemon:giveNickname(r.i, r.s)
								end
								local msg = _p.Network:get('PDS', 'makeDecision', r.d, nickname)
								if msg then chat:say(msg) end
								spawn(function() chat:say('[ma]Saving...') end)
								local success = _p.PlayerData:save()
								wait()
								chat:manualAdvance()
								if success then
									Utilities.sound(301970897, nil, nil, 3)
									chat:say('Save successful!')
									_p.Menu.willOverwriteIfSaveFlag = nil
								else
									chat:say('SAVE FAILED!', 'Be sure to try again later.')
								end
							end
							return true
						end)()
						if not res then
							chat:say(david, 'Okay, well have a nice day!')
						end
						_p.Menu:enable()
					end
				end
				local function setupJakeFight(jake, prof, mom, dad)
					setupDevProduct()
					interact[jake.model] = 'I\'m so excited for the adventures that await us!'
					interact[prof.model] = 'Go and explore the world of Pok[e\']mon!'
					interact[mom.model] = 'Your new Pok[e\']mon is so cute!'
					interact[dad.model] = {'We need to stay behind and talk to the professor for a minute.', 'We\'ll meet up with you later.'}

					_p.DataManager:preload(12639840340)
					touchEvent('JakeBattle1', room.model.CutsceneTrigger2, false, function()

						_p.MasterControl.WalkEnabled = false
						spawn(function() _p.Menu:disable() end)

						local p = room.model.CutsceneTrigger2.Position + Vector3.new(-8, 0, 5)
						_p.MasterControl:WalkTo(p)
						--root.Anchored = true--workaround
						interact[jake.model] = nil
						chat:say('Wait, ' .. _p.PlayerData.trainerName .. '!')
						spawn(function() _p.MasterControl:Look(Vector3.new(3, 0, -1.5)) end)
						jake:WalkTo(p + Vector3.new(10, 0, 0))
						jake:WalkTo(p + Vector3.new(3, 0, -1).unit*3)
						jake:LookAt(p)
						chat:say(jake, 'We both have Pok[e\']mon now, you know what that means?', 'LET\'S BATTLE!')
						_p.Battle:doTrainerBattle {
							IgnoreBlackout = true,
							battleSceneType = 'Lab',
							musicId = 12639840340,
							PreventMoveAfter = true,
							trainerModel = jake.model,
							num = 107
						}
						chat:say(jake, 'Nice fighting!', 'Here, allow me to heal your Pok[e\']mon.')
						interact[jake.model] = 'Nice fighting!'
						local p1 = p + Vector3.new(10, 0, -5)
						local dadp = p + Vector3.new(0, 0, -5)
						local momp = p + Vector3.new(-1, 0, -1).unit*5
						delay(.75, function()
							dad:WalkTo(p1)
							dad:WalkTo(dadp)
							dad:LookAt(p)
						end)
						mom:WalkTo(p1)
						mom:WalkTo(dadp)
						mom:WalkTo(momp)
						mom:LookAt(p)
						local mid = momp+(dadp-momp)/2
						spawn(function() _p.MasterControl:LookAt(mid) end)
						spawn(function() jake:LookAt(mid) end)
						chat:say(mom, _p.PlayerData.trainerName .. ', that was an excellent battle!', 'Your father and I watched you while we were discussing things with the professor.')
						chat:say(dad, 'We are very proud of you in taking this step to become a Pok[e\']mon Trainer!', 'We want you to know that we will be supporting you as you explore Roria.')
						chat:say(mom, 'You need to be very careful, as you are going to be out on your own for the first time.', 'Don\'t forget to floss!')
						chat:say(dad, _p.PlayerData.trainerName .. ', we want to give you something to take with you as a gift to celebrate this momentous occasion.')
						local brick = _p.DataManager.currentChunk.map.TheBronzeBrick:Clone()
						local cfs = {}
						local main = brick.SpinCenter
						for _, p in pairs(brick:GetChildren()) do
							if p:IsA('BasePart') and p ~= main then
								cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
							end
						end
						brick.Parent = workspace
						local st = tick()
						local spinRate = 1
						local function cframeTo(rcf)
							local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(0, (tick()-st)*spinRate, 0)
							for p, ocf in pairs(cfs) do
								p.CFrame = cf:toWorldSpace(ocf)
							end
						end
						local r = 8
						local f = CFrame.new(0, 0, -6)
						Tween(1, nil, function(a)
							local t = a*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						local spin = true
						Utilities.fastSpawn(function()
							while spin do
								cframeTo(f)
								stepped:wait()
							end
						end)
						wait(2)
						Utilities.sound(304774035, nil, nil, 8)
						chat:say('Bronze Brick obtained!', _p.PlayerData.trainerName .. ' put the Bronze Brick in the Bag.')
						spin = false
						Tween(.5, nil, function(a)
							local t = (1-a)*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						brick:remove()
						chat:say(dad, 'I made it into a necklace just this morning.', 'When you look at it, remember your family who loves you.', 'Don\'t forget to keep it safe.')
						chat:say(mom, 'We\'re headed back to the house.', 'If you need anything, that\'s where you can find us!')
						local exitp = room.model.Exit.Position + Vector3.new(0, 0, 1)
						spawn(function()
							dad:WalkTo(exitp)
							dad:remove()
						end)
						delay(.45, function()
							mom:WalkTo(exitp)
							mom:remove()
						end)
						wait(2)
						spawn(function() _p.MasterControl:LookAt(jake.model.HumanoidRootPart.Position) end)
						jake:LookAt(p)
						chat:say(jake, 'Wow, that was really cool of your parents.', 'Oh, by the way, I have something for you.', 'They\'re for catching wild Pok[e\']mon!')
						Utilities.sound(288899943, nil, nil, 10)
						chat:say('Obtained 5 Pok[e\'] Balls!', _p.PlayerData.trainerName .. ' put the Pok[e\'] Balls in the Bag.')
						chat:say(jake, 'These Pok[e\'] Balls can catch Pok[e\']mon!', 'It works best if you weaken the Pok[e\']mon before throwing a Pok[e\'] Ball at it.', 'Well, I need to gather a few things before I set off on my adventure.', 'You should go start training your Pok[e\']mon on Route 1!', 'Past Route 1 is Cheshma Town.', 'That\'ll be a good place for us to meet up.', 'Alright, I\'ll see you later!')
						spawn(function()
							jake:WalkTo(exitp)
							jake:remove()
						end)
						wait(2)
						_p.MasterControl.WalkEnabled = true
						--root.Anchored = false
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
					end)
				end
				if not completedEvents.ChooseFirstPokemon then
					if completedEvents.MeetParents then
						_p.DataManager:preload(6142797841, 294746267, 6142885897)
						local jake, prof, mom, dad = arrangeNPCs()

						touchEvent('ChooseFirstPokemon', room.model.CutsceneTrigger, false, function()
							spawn(function() _p.Menu:disable() end)
							local playerPos = (room.model.Base.CFrame * CFrame.new(0, 4, 12)).p
							_p.MasterControl:WalkTo(playerPos)
							spawn(function() jake:LookAt(playerPos) end)
							spawn(function() mom:LookAt(playerPos) end)
							spawn(function() dad:LookAt(playerPos) end)
							prof:LookAt(playerPos)
							_p.MasterControl:LookAt(prof.model.Head.Position)
							_p.MasterControl:Stop()
							_p.MasterControl.WalkEnabled = false
							chat:say(prof, 'Hello, my name is Professor Cypress.',
								'I am the new professor in Mitis Town.', -- todo
								'I\'ll bet you\'re '.._p.PlayerData.trainerName..'.',
								'Your parents were just telling me about you.',
								'You must be very excited to be getting your first Pok[e\']mon today.',
								'There are a few things you must know about Pok[e\']mon first.',
								'Pok[e\']mon are our friends, and we grow alongside them.',
								'They grow, and in some cases, evolve and change form, as we battle with them.',
								'Your Pok[e\']mon will grow to love you as you adventure with them.')
							chat:say(jake, 'Oh that\'s cool, I never knew that before!')
							chat:say(prof, 'Yes, and there are still many things that we do not know about Pok[e\']mon.',
								_p.PlayerData.trainerName..', I want you now to pick a Pok[e\']mon that you would like to accompany you on your adventures.',
								'Make a choice from these 24 different breeds.',
								'Go ahead now.')
							_p.MasterControl:WalkTo((room.model.Base.CFrame * CFrame.new(-4, 0, 11.25)).p, 10)
							_p.MasterControl:Look(Vector3.new(0, 0, 1), .2)
							local pokemon = pickStarter(true)
							_p.PlayerData:completeEvent('ChooseFirstPokemon', pokemon) -- aparently we never gave them the option to nickname the og
							_p.Menu:setButtonEnabled('Party', true)
							pcall(function() room.chunk.map.NoPokemonBlocker.CanCollide = false end)
							_p.MasterControl:WalkTo(playerPos)
							_p.MasterControl:LookAt(prof.model.Head.Position)
							chat:say(prof, 'Excellent choice, ' .. _p.PlayerData.trainerName .. '!')
							chat:say(mom, 'Your new Pok[e\']mon is so cute!')
							chat:say(dad, 'That Pok[e\']mon definitely has potential in battle!')
							chat:say(jake, 'I hope our Pok[e\']mon become best friends like we are!')
							chat:say(prof, 'Alright ' .. _p.PlayerData.trainerName .. ', many challenges await you.',
								'Let me give you one other gift that will help you along your way.',
								'It\'s a Pokedex.',
								'It\'s like an electronic encyclopedia that records the kinds of Pok[e\']mon you encounter and capture.',
								'It will also help me in my research with Pok[e\']mon.')
							Utilities.sound(304774035, nil, nil, 8)
							chat:say('Pokedex obtained!')
							chat:say(prof, 'Also, if you\'d like, you can come back at any time and purchase another Pok[e\']mon from my assistant, David.',
								'Now, what are you waiting for?',
								'Go and explore the world of Pok[e\']mon!')
							chat:say(dad, 'Yes, ' .. _p.PlayerData.trainerName .. '. Go ahead and have fun with your Pok[e\']mon.',
								'We need to stay behind and talk to the professor for a minute.',
								'We\'ll meet up with you later.')
							_p.Menu:setButtonEnabled('Pokedex', true)

							-- setup trigger for fight with Jake
							setupJakeFight(jake, prof, mom, dad)

							spawn(function() _p.Menu:enable() end)
							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()
						end)
					else
						local jake = _p.NPC:PlaceNew('Jake', room.model, room.model.Base.CFrame * CFrame.new(-3, 4, -20) * CFrame.Angles(0, -1.75, 0))
						interact[jake.model] = {'The professor\'s not here yet.',
							'Go ahead and go find your parents.',
							'They should be around the digging site somewhere.'}
						table.insert(room.npcs, jake)
						interact[room.model.David] = {'The professor sells these Pok[e\']mon for 5 R$ each.',
							'I\'m pretty sure he plans on giving you your first one free, though.'}
					end
				elseif not completedEvents.JakeBattle1 then
					setupJakeFight(arrangeNPCs())
				else
					setupDevProduct()
				end
			end
		end,

		onBeforeEnter_yourhomef1 = function(room)
			if completedEvents.JakeBattle1 and not completedEvents.ParentsKidnappedScene then
				local mom = _p.NPC:PlaceNew('Mom', room.model, room.model.Base.CFrame * CFrame.new(0, 3.1, 8) * CFrame.Angles(0, 0.3, 0))
				table.insert(room.npcs, mom)
				interact[mom.model] = {'Don\'t forget to floss!', 'Gingivitis can kill, you know.'}
				local dad = _p.NPC:PlaceNew('Dad', room.model, room.model.Base.CFrame * CFrame.new(3, 3.1, 5) * CFrame.Angles(0, 1, 0))
				table.insert(room.npcs, dad)
				interact[dad.model] = 'We\'re rooting for you, champ!'
			end
		end,

		onBeforeEnter_friendhomef1 = function(room)
			interact[room.model.JakeMom] = {'Hey, ' .. _p.PlayerData.trainerName .. '.', 'Jake is so excited to be adventuring with you!',
				'I remember you two staying up late as kids and talking about the adventures you\'d have.'}
		end,

		onDoorFocused_Gate1 = function()
			if _p.DataManager.currentChunk.id ~= 'chunk1' then return end
			if completedEvents.ParentsKidnappedScene then return end
			spawn(function() _p.PlayerData:completeEvent('ParentsKidnappedScene') end)
			spawn(function() _p.Menu:disable() end)
			chat:say(_p.PlayerData.trainerName:upper() .. '!!!')
			local yp = _p.player.Character.HumanoidRootPart.Position
			local sp = Vector3.new(-104, 61, -40)
			local jake = _p.NPC:PlaceNew('Jake', _p.DataManager.currentChunk.map, CFrame.new(sp))
			local jp = yp + (sp-yp).unit * 3.5
			spawn(function() _p.MasterControl:LookAt(sp, .2) end)
			jake:WalkTo(jp)
			chat:say(jake, 'I got here as fast as I could!', 'Something terrible has happened.', 'I need you to come back to town with me.', 'I don\'t have time to explain.', 'Let\'s go!')
			spawn(function() jake:WalkTo(sp) end)
			delay(.15, function() _p.MasterControl:WalkTo(sp) end)
			local chunk = _p.DataManager.currentChunk
			spawn(function() _p.MusicManager:prepareToStack(1) end)
			Utilities.FadeOut(1)
			jake:Stop()
			_p.MasterControl:Stop()
			-- delete the grunts
			chunk.npcs.EclipseGrunt1:remove()
			chunk.npcs.EclipseGrunt2:remove()
			local sceneNPCs = {}
			local dummies = _p.storage.Modelss.Misc.KidnapScene:Clone()
			dummies.Parent = workspace
			_p.NPC:collectNPCs(dummies, sceneNPCs)
			local prof = sceneNPCs.Professor
			workspace.CurrentCamera.CoordinateFrame = CFrame.new(1.95215666, 58.6736107, 120.124763, -0.345804513, -0.228563339, 0.910042882, -7.4505806e-09, 0.969877958, 0.243591309, -0.93830663, 0.0842349678, -0.335388184)
			pcall(function() chunk.map.nutty:remove() end)
			local p = prof.model.HumanoidRootPart.Position
			local jp = p + Vector3.new(3, 0, -6)
			local yp = p + Vector3.new(0.5, 0, -4)
			jake:Teleport(CFrame.new(jp) + Vector3.new(0, 0, -13))
			Utilities.Teleport(CFrame.new(yp) + Vector3.new(0, 0, -15))
			chunk.StartMusicAtZeroVolume = true
			wait(1)
			chunk.indoors = false
			spawn(function() Utilities.FadeIn(1, function() chunk.regionThread = nil end) end)
			spawn(function()
				jake:WalkTo(jp)
				jake:LookAt(p)
			end)
			delay(.5, function() prof:LookAt(yp) end)
			_p.MasterControl:WalkTo(yp)
			_p.MasterControl:LookAt(p)
			local music = Utilities.loopSound(305574921)
			chat:say(prof, _p.PlayerData.trainerName .. '...',
				'I\'m so glad to see you are safe.',
				'I am so sorry to be the one to tell you this, ' .. _p.PlayerData.trainerName .. '...',
				'... but your parents have been abducted from their home in the short time you have been gone.',
				'Not much is known yet, but it is suspected that they were taken by a group of people known as Team Eclipse.',
				'You see, Team Eclipse is an organization of people who have a unique perspective on people and Pok[e\']mon.',
				'They believe that people and Pok[e\']mon are not at harmony with one another, and they have interesting ideas for how to solve this problem.',
				'They are also dangerous and not to be trifled with.',
				'They seem to do whatever it takes to accomplish their goals.',
				'I do not know what they want with your parents, but I suspect it has something to do with their skills as archeologists.',
				'Your parents are familiar with Pok[e\']mon of legend on Roria.',
				'Whatever Team Eclipse is after, I\'m sure they are getting very close to achieving it.',
				'Now tell me, ' .. _p.PlayerData.trainerName .. ', did your parents say anything about their work when you saw them this morning?')
			wait(1)
			chat:say(prof, 'Oh, so your parents gave you that necklace earlier.',
				'That\'s interesting.',
				'Anyways, it\'s not safe for you here now.',
				_p.PlayerData.trainerName .. ', I think for the time being it\'s best for you to leave town.',
				'At least until we figure out what\'s happened here.',
				'Cheshma Town is a good place to start.', 'It\'s just past Route 1.',
				'Be careful now ' .. _p.PlayerData.trainerName .. ', and don\'t go looking for trouble.')
			spawn(function() Utilities.lookBackAtMe(1) end)
			Utilities.FadeOut(1, nil, function(a) music.Volume = 0.5*(1-a) end)
			music:Stop()
			music:remove()
			jake:remove()
			dummies:remove()
			chunk.StartMusicAtZeroVolume = nil
			spawn(function() _p.MusicManager:returnFromSilence(1) end)
			Utilities.FadeIn(1)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
			spawn(function() _p.Menu:enable() end)
			return true
		end,
		-- [[
		onLoad_chunk64 = function(chunk)
			--			if not completedEvents.PolutEnter then spawn(function() _p.PlayerData:completeEvent('PolutEnter') end)end
			local Cptn = chunk.npcs.MadScientist
			interact[Cptn.model] = function()
				if not 	 Cptn:Say('We just rigged up this teleportation device that sends you to an alternate reality of ours.',
					'Our study has shown that certain types of monsters are exclusive in this realm.',
					'[y/n]Would you like to enter?') then
					Cptn:Say('Come back if you wanna go.')
					return
				end
				Cptn:Say('Alright, hang on tight!')
				Utilities.FadeOut(.5)
				local startTick = tick()
				Utilities.TeleportToSpawnBox()
				chunk:remove()
				-- change chunks
				_p.DataManager:loadMap('chunk65')
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				Utilities.Teleport(CFrame.new(-3992.33, 1592.305, -3256))
				local elapsed = tick()-startTick
				if elapsed < .5 then
					wait(.5-elapsed)
				end
				Utilities.FadeIn(.5)
			end
		end,	

		onLoad_chunk65 = function(chunk)
	
			local Cptn = chunk.npcs.MadScientist
			interact[Cptn.model] = function()
				if not Cptn:Say('Hey there again, it looks like you had fun.',
					'[y/n]Would you like to go back to our lab?') then
					Cptn:Say('Come back if you wanna go.')
					return
				end
				Cptn:Say('Alright, hang on tight!')
				Utilities.FadeOut(.5)
				local startTick = tick()
				Utilities.TeleportToSpawnBox()
				chunk:remove()
				-- change chunks
				_p.DataManager:loadMap('chunk64')
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				Utilities.Teleport(CFrame.new(-4192.545, 1574.391, 30.731))
				local elapsed = tick()-startTick
				if elapsed < .5 then
					wait(.5-elapsed)
				end
				Utilities.FadeIn(.5)	
			end
		end,
		--]]		

		onLoad_chunk2 = function(chunk)
			local function setupForestBattle()
				_p.DataManager:preload(5226446060, 12639846584)
				local linda = _p.NPC:PlaceNew('Linda', chunk.map, chunk.map.LindaForestFight.CFrame)
				table.insert(_p.DataManager.currentChunk.npcs, linda)
				interact[linda.model] = function()
					chat:say(linda, 'Well darn, looks like you caught up to me.',
						'It\'s my fault for running into this dead end.',
						'The bridge was under construction so hiding here was my only option.',
						'So you want this necklace back, huh?',
						'Well too bad, Team Eclipse doesn\'t return what they earn.',
						'That\'s right kid, I\'m a member of Team Eclipse.',
						'The only way I\'d let you have your precious brick back is if you beat me in a Pok[e\']mon battle.',
						'But let\'s face it - you are just a fresh new trainer.',
						'Theres no way you can beat me!')
					local win = _p.Battle:doTrainerBattle {
						IconId = 5226446060,
						musicId = 12639846584,
						PreventMoveAfter = true,
						trainerModel = linda.model,
						trainer = {
							--						ModelName = 'Linda', -- do we ever use Linda? can we remove the model from the storage?
							Name = 'Eclipse Member Linda',
							LosePhrase = 'Beaten by a kid... ugh...',
							TrainerDifficulty = 1,
							Payout = 40 * 9,
							num = 108
						}
					}
					if win then
						chat:say(linda, 'What, how could this happen?',
							'Oh, this really isn\'t good.',
							'The boss is going to be so disappointed in me.',
							'Fine, here, take your necklace back.',
							'Team Eclipse will be back for it, though.',
							'We always get what we want.')
						Utilities.FadeOut(.5)
						linda:remove()
						wait(.5)
						local jake
						for _, npc in pairs(chunk.npcs) do
							if npc.model and npc.model.Name == 'Jake' then
								jake = npc
								break
							end
						end
						if jake then
							interact[jake.model] = nil
							local yp = _p.player.Character.HumanoidRootPart.Position
							local jp = Vector3.new(-230.881, 65, -875.598)
							jake:Teleport(CFrame.new(jp, yp))
							spawn(function()
								Utilities.FadeIn(.5)
								_p.MasterControl:LookAt(jp)
							end)
							jake:WalkTo(yp + (jp-yp).unit*4)
							chat:say(jake, 'Good job getting your necklace back.',
								'So she was one of those Team Eclipse people...',
								'I wonder what their problem is.',
								'Anyways, it\'s clear that you can\'t really trust anyone to find your parents for you right now.',
								'If Team Eclipse really did take them, you will need a strong team of Pok[e\']mon to beat them.',
								'A great way to strengthen your Pok[e\']mon is to challenge the gym leaders in Roria.',
								'There are 8 gym leaders in Roria.',
								'And who knows, maybe while traveling you will learn more information on what might have happened to your parents.',
								'Anyways, there\'s a gym in the next town over.',
								'I suggest we start there.',
								'Don\'t worry ' .. _p.PlayerData.trainerName .. ', we\'ll get your parents back.',
								'Now let\'s go!')
							spawn(function()
								jake.humanoid.WalkSpeed = 16
								jake:WalkTo(Vector3.new(-235.1, 65, -871.5))
								jake:WalkTo(Vector3.new(-197.9, 65, -871.5))
								jake:WalkTo(Vector3.new(-190.1, 65, -841.6))
								jake:WalkTo(Vector3.new(-183.7, 65, -840.2))
								jake:remove()
							end)
						else
							warn'Jake not found'
						end

						wait(.5)
						chunk.map.Construction:remove()
						chunk.map.WorkerBob:remove()
					end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					chat:enable()
					_p.Menu:enable()
				end
			end
			if not completedEvents.BronzeBrickStolen then
				local linda = _p.NPC:PlaceNew('Linda', chunk.map, CFrame.new(-99.3029022, 62.4683685, -540.798706, -0.798631907, 0, 0.601812422, 0, 1, 0, -0.601812422, 0, -0.798631907))
				table.insert(chunk.npcs, linda)
				local wave = linda.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCWave })
				touchEvent('BronzeBrickStolen', chunk.map.SceneTrigger, false, function()
					spawn(function() _p.Menu:disable() end)
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					wave:Play()
					chat:say(linda, 'Hey, over here!')
					wave:Stop()
					local yp = _p.player.Character.HumanoidRootPart.Position
					local lp = linda.model.HumanoidRootPart.Position
					spawn(function() _p.MasterControl:LookAt(lp) end)
					linda:WalkTo(yp + (lp-yp).unit*4)
					chat:say(linda, 'You look like a brand new trainer.',
						'This must be your first time traveling alone.',
						'...', 'I see...', 'Your parents were abducted by Team Eclipse...',
						'That\'s terrible!', 'I have some information about Team Eclipse that might be valuable.',
						'Follow me to my home where we can discuss it privately.')
					local door = chunk:getDoor('LindaHome')
					local main = door.model.Main
					local size = main.Size
					local cf = main.CFrame
					main.Size = Vector3.new(3.5, 6.9, 5.5)
					main.CFrame = cf
					local path = {
						Vector3.new(-111, 62.5, -549),
						Vector3.new(-132.5, 62.5, -577.4),
						Vector3.new(-151.9, 62.5, -577.8),
						cf.p + Vector3.new(-1, 0, 5),
					}
					local walking = true
					spawn(function()
						for _, p in pairs(path) do
							linda:WalkTo(p)
						end
						walking = false
					end)
					wait(.3)
					for i = 1, 3 do
						_p.MasterControl:WalkTo(path[i])
					end
					sceneSignal = Utilities.Signal()
					_p.MasterControl:WalkTo(cf.p + Vector3.new(0, 0, -1.5))
					local room = sceneSignal:wait()
					linda:Stop()
					linda:Teleport(room.model.Base.CFrame * CFrame.new(0, 3.1, 8) * CFrame.Angles(0, -1.8, 0))
					while not _p.MasterControl.WalkEnabled do stepped:wait() end
					_p.MasterControl.WalkEnabled = false
					door:close()
					main.Size = size
					main.CFrame = cf
					yp = _p.player.Character.HumanoidRootPart.Position
					lp = linda.model.HumanoidRootPart.Position
					spawn(function() linda:LookAt(yp) end)
					_p.MasterControl:WalkTo(lp + (yp-lp).unit * 4)
					spawn(function() _p.MasterControl:LookAt(lp) end)
					spawn(function() _p.PlayerData:completeEvent('BronzeBrickStolen') end)
					chat:say(linda, 'So your parents were taken by Team Eclipse.',
						'Gosh, that must be awful.',
						'I bet you must miss them...',
						'Oh, so they gave you that necklace before they were taken?',
						'Do you mind if I see it?',
						'Thanks, this necklace looks old...', '...and valuable...',
						'Heh... thanks!')
					spawn(function() _p.MasterControl:LookAt(yp) end)
					linda.humanoid.WalkSpeed = 25
					linda:WalkTo(lp + Vector3.new(-1, 0, -4))
					linda:WalkTo(yp + Vector3.new(0, 0, -2))
					linda:remove()
					wait(1)
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					setupForestBattle()
					_p.Menu:enable()
				end)
			elseif completedEvents.BronzeBrickStolen and not completedEvents.BronzeBrickRecovered then
				local jake = _p.NPC:PlaceNew('Jake', chunk.map, CFrame.new(-119, 65, -728))
				spawn(function() jake:Look(Vector3.new(0, 0, -1)) end)
				table.insert(chunk.npcs, jake)
				interact[jake.model] = function()
					chat:say(jake, 'She\'s in here somewhere.',
						'I\'ll wait right here so she doesn\'t get away.',
						'You go look for her and get your necklace back.')
					spawn(function() jake:Look(Vector3.new(0, 0, -1)) end)
				end
				setupForestBattle()
			elseif completedEvents.BronzeBrickRecovered then
				chunk.map.Construction:remove()
				chunk.map.WorkerBob:remove()
			end
		end,

		onBeforeEnter_LindaHome = function(room)
			if sceneSignal then sceneSignal:fire(room) end
		end,

		onExit_LindaHome = function()
			if completedEvents.JakeTracksLinda then return end
			spawn(function() _p.PlayerData:completeEvent('JakeTracksLinda') end)
			spawn(function() _p.Menu:disable() end)
			local chunk = _p.DataManager.currentChunk
			local playerPos = _p.player.Character.HumanoidRootPart.Position
			local door = chunk:getDoor('LindaHome')
			local jakePos = (door.model.Main.CFrame * CFrame.new(20, -0.3, -20)).p
			local jake = _p.NPC:PlaceNew('Jake', chunk.map, CFrame.new(jakePos, playerPos))
			table.insert(chunk.npcs, jake)
			spawn(function() _p.MasterControl:LookAt(jakePos) end)
			local cam = workspace.CurrentCamera
			local camP = CFrame.new(cam.CoordinateFrame.p+Vector3.new(-1, -8, -4), jake.model.Head.Position)
			local walking = true
			spawn(function()
				jake:WalkTo(playerPos+(jake.model.HumanoidRootPart.Position-playerPos).unit*7)
				walking = false
			end)
			local start = tick()
			while true do
				stepped:wait()
				if tick()-start > 4 then
					cam.CoordinateFrame = CFrame.new(camP.p, jake.model.Head.Position)
					break
				end
				local speed = 0.05 + 0.1*(tick()-start)
				local cf = cam.CoordinateFrame
				local focus = cf.p + cf.lookVector * (jake.model.Head.Position - cf.p).magnitude
				if (jake.model.Head.Position-focus).magnitude < 0.2 and not walking then break end
				cam.CoordinateFrame = CFrame.new(cf.p + (camP.p-cf.p)*speed, focus + (jake.model.Head.Position-focus)*speed)
			end
			chat:say(jake, 'Hey, there you are ' .. _p.PlayerData.trainerName .. '.',
				'Who was that person that just took off running out of here?',
				'Wait, what?', 'She took the necklace that your parents gave you!?',
				'That was the last thing your parents gave you before they dissapeared!',
				'We have to go after her and get that back!',
				'I saw her running into the woods just outside of town.',
				'Quick, follow me and I\'ll lead you there.')
			delay(.5, function()
				spawn(function() _p.Menu:enable() end)
				jake.humanoid.WalkSpeed = 15
				jake:WalkTo(Vector3.new(-139, 62, -605))
				jake:WalkTo(Vector3.new(-120, 62, -634))
				jake:WalkTo(Vector3.new(-119, 65, -728))
				interact[jake.model] = function()
					chat:say(jake, 'She\'s in here somewhere.',
						'I\'ll wait right here so she doesn\'t get away.',
						'You go look for her and get your necklace back.')
					spawn(function() jake:Look(Vector3.new(0, 0, -1)) end)
				end
			end)

			return true
		end,

		onBeforeEnter_PokeCenter = function(room)
			_p.DataManager:preload(300394295)
			local npc = room.npcs['Nurse']
			if npc then
				local bow = npc.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NurseBow })
				npc.bow = bow
				local machine = room.model.HealingMachine
				npc.humanoid.WalkSpeed = 9
				interact[npc.model] = function()
					local pokeballs
					Utilities.fastSpawn(function()
						local ballNums = _p.Network:get('PDS', 'getPartyPokeBalls')
						local ballNames = {}
						for i, num in pairs(ballNums) do
							ballNames[i] = _p.Pokemon.balls[num]
						end
						pokeballs = ballNames
					end)
					spawn(function() _p.Menu:disable() end)
					local p1 = room.model.Base.Position + Vector3.new(-0.2, 3.16, 4.8)-- base -84.4, 0.1, 9.1; person -84.6, 3.26, 13.9
					local p2 = p1 + Vector3.new(0, 0, 2)
					if chat:say(npc, 'Hello, and welcome to the Pok[e\']mon Center.', '[y/n]Would you like to rest your Pok[e\']mon?') then
						spawn(function() chat:say(npc, '[ma]OK. I\'ll take your Pok[e\']mon for a few seconds, then.') end)
						wait(1)
						npc:WalkTo(p2)
						npc:Look(Vector3.new(0, 0, 1))
						chat:manualAdvance()
						while not pokeballs do wait() end
						local models = {}
						for i, p in pairs(pokeballs) do
							if i > 6 then break end
							Utilities.sound(301970857, 1, .1, 2)
							local model = (_p.storage.Modelss.Pokeballs:FindFirstChild(p) or _p.storage.Modelss.pokeball):Clone()
							Utilities.MoveModel(model.Main, machine['Slot'..i].CFrame*CFrame.Angles(0, math.pi/2, 0)+Vector3.new(0, 1.5, 0), true)
							model.Parent = room.model
							table.insert(models, model)
							wait(.5)
						end
						Utilities.sound(300394295, nil, .5, 10)
						Tween(2, nil, function(a)
							machine.Screen.Reflectance = 0.3 + 0.5*math.abs(math.sin(a*4*math.pi))
						end)
						wait(.5)
						for _, m in pairs(models) do
							m:remove()
						end
						npc:WalkTo(p1)
						pcall(function() npc:LookAt(_p.player.Character.HumanoidRootPart.Position) end)
						chat:say(npc, 'Thank you for waiting.', 'We\'ve restored your Pok[e\']mon to full health.')
					end
					bow:Play(.3)
					spawn(function() chat:say(npc, '[ma]We hope to see you again!') end)
					wait(1.1)
					chat:manualAdvance()
					spawn(function() npc:Look(Vector3.new(0, 0, -1)) end)
					spawn(function() _p.Menu:enable() end)
				end
			end
			local martguy = room.npcs.MartGuy
			if martguy then
				interact[martguy.model] = function()
					spawn(function() _p.Menu:disable() end)
					chat:say(martguy, 'Welcome to the Pok[e\'] Mart!', 'May I help you?')
					while true do
						if not _p.Menu.shop:open() then break end
						chat:say(martguy, 'Is there anything else I may do for you?')
					end
					chat:say(martguy, 'Please come again!')
					_p.Menu:enable()
				end
			end
		end,

		onBeforeEnter_SawsbuckCoffee = function(room)
			local barista = room.npcs.barista
			local interactAfterCoffee = {
				'Enjoy your Sawsbuck Coffee.',
				'Pok[e\']mon especially enjoy the boost they get from it.',
			}
			if completedEvents.GivenSawsbuckCoffee then
				interact[barista.model] = interactAfterCoffee
			else
				interact[barista.model] = function()
					chat:say(barista, 'Welcome to Sawsbuck Coffee.',
						'We\'re having a special today.',
						'We\'re giving out free samples of our famous Sawsbuck Coffee.',
						'Here, have one!')
					Utilities.sound(288899943, nil, nil, 10)
					chat:say('Obtained a Sawsbuck Coffee!', _p.PlayerData.trainerName .. ' put the Sawsbuck Coffee in the Bag.')
					_p.PlayerData:completeEvent('GivenSawsbuckCoffee')
					--				_p.PlayerData:addBagItems({ id = ids.sawsbuckcoffee, quantity = 1 })
					--				completedEvents.GivenSawsbuckCoffee = true
					chat:say(barista, 'Pok[e\']mon especially enjoy drinking Sawsbuck Coffee.')
					interact[barista.model] = interactAfterCoffee
				end
			end
		end,

		onBeforeEnter_EeveeHouse = function(room)
			local inGroup = _p.player:IsInGroup(8140166)
			local man = room.npcs.OldMan
			interact[man.model] = function()
				if inGroup and not completedEvents.Eevee2Awarded then
					if man:Say('Eevee is such a playful and peaceful Pok[e\']mon.',
						'They bring my wife and I much joy.',
						'As we\'ve gotten older, we\'ve realized that we love to spread that joy to everyone else!',
						'I\'d like you to take one of our Eevees, and to care for it.',
						'[y/n]Would you like to take on this responsibility?') then
						man:Say('Alright, here you go!')
						chat.bottom = true
						chat:say('Eevee obtained!')
						local msg = _p.PlayerData:completeEvent('Eevee2Awarded')
						if msg then chat:say(msg) end
						chat.bottom = nil
						man:Say('I hope you will enjoy Eevee as much as we do!')
					end
				else
					man:Say('Eevee is such a playful and peaceful Pok[e\']mon.',
						'They bring my wife and I much joy.')
				end
			end
		end,

		onBeforeEnter_Gym1 = function(room, continueCFrame)
			local battleService = _p.Battle
			_p.DataManager:preload(12639876591,
				6142910487, 6142914919) -- vs text, trainer icon
			local m = room.model
			-- teleport on BaseTouched
			m.Base.Touched:connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				Utilities.Teleport(CFrame.new(m.Entrance.Position + Vector3.new(0, 3, 8)))
			end)
			-- continue support
			local doPuzzle1, doPuzzle2 = true, true
			if continueCFrame then
				continueCFrame = continueCFrame + m.Base.Position
				if continueCFrame.z > m.Blockade1.Wall.Position.Z then
					doPuzzle1 = false
					for _, p in pairs(m.Blockade1:GetChildren()) do
						if p.Name == 'LineSegment' or p.Name == 'Wall' then
							p:remove()
						end
					end
					for _, p in pairs(m.Puzzle1:GetChildren()) do
						if p:IsA('BasePart') and p.Name ~= 'Base' then
							p.BrickColor = BrickColor.new('Lime green')
						end
					end
				end
				if continueCFrame.z > m.Blockade2.Wall.Position.Z then
					doPuzzle2 = false
					for _, p in pairs(m.Blockade2:GetChildren()) do
						if p.Name == 'LineSegment' or p.Name == 'Wall' then
							p:remove()
						end
					end
					for _, p in pairs(m.Puzzle2:GetChildren()) do
						if p:IsA('BasePart') and p.Name ~= 'Base' then
							p.BrickColor = BrickColor.new('Lime green')
						end
					end
				end
			end
			-- leader
			local chad = room.npcs.Leader
			local postWinInteract = {
				'This club is hopping at night.',
				'Challengers like you always energize the other club members.'
			}
			if _p.PlayerData.badges[1] then
				interact[chad.model] = postWinInteract
			else
				interact[chad.model] = function()
					chat:say(chad, 'Hello.',
						'I\'m Chad, the creator and leader of this fine establishment.',
						'I see you have no badges yet.',
						'That makes this your first battle for a Gym Badge.',
						'Don\'t expect me to go easy on you.',
						'My club has a reputation that I like to keep by making my badges difficult to earn.',
						'Now, get ready for the drop!')
					local win = battleService:doTrainerBattle {
						battleSceneType = 'Gym1',
						musicId = 12639876591,
						PreventMoveAfter = true,
						vs = {name = 'Chad', id = 496818267, hue = 0.167, sat = .4, val = .65},
						trainerModel = chad.model,
						num = 109
					}
					if win then
						chat:say(chad, 'Well congratulations on your victory, trainer!',
							'It is my pleasure now to present to you your first Gym Badge.')

						local badge = m.Badge1:Clone()
						local cfs = {}
						local main = badge.SpinCenter
						for _, p in pairs(badge:GetChildren()) do
							if p:IsA('BasePart') and p ~= main then
								cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
							end
						end
						badge.Parent = workspace
						local st = tick()
						local spinRate = 1
						local function cframeTo(rcf)
							local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi/2, 0, (tick()-st)*spinRate + math.pi/2)
							main.CFrame = cf
							for p, ocf in pairs(cfs) do
								p.CFrame = cf:toWorldSpace(ocf)
							end
						end
						local r = 8
						local f = CFrame.new(0, 0, -6)
						Tween(1, nil, function(a)
							local t = a*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						local spin = true
						Utilities.fastSpawn(function()
							while spin do
								cframeTo(f)
								stepped:wait()
							end
						end)
						wait(2)
						Utilities.sound(12639886125, nil, nil, 10)
						chat:say('Obtained the Arc Badge!')
						spin = false
						Tween(.5, nil, function(a)
							local t = (1-a)*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						badge:remove()

						chat:say(chad, 'I would also like for you to take this TM as a gift for your victory.')
						Utilities.sound(288899943, nil, nil, 10)
						chat:say('Obtained a TM57!',
							_p.PlayerData.trainerName .. ' put the TM57 in the Bag.')
						chat:say(chad, 'This TM contains the move Charge Beam.',
							'TMs are an excellent way to make your Pok[e\']mon stronger.',
							'TMs contain battle moves the Pok[e\']mon are capable of learning.',
							'In this case TM57, or Charge Beam, is an Electric-type move that has a special side effect that can boost your Pok[e\']mon\'s Special Attack.',
							'The Arc Badge allows you to use HM01 Cut outside of battle.',
							'It also allows you to trade for Pok[e\']mon up to level 20.',
							'Thank you for stopping by my club.',
							'That was a very entertaining battle.')
						interact[chad.model] = postWinInteract
					end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					chat:enable()
					_p.Menu:enable()
				end
			end
			-- info
			local guide = room.npcs.InfoGuide
			local postIntroInteract = {
				'Now, this gym is not only a test of a trainer\'s strength, but your dance moves as well.',
				'You see those red squares up ahead?',
				'They are dance tiles.',
				'Stepping on them will turn them green.',
				'Stepping on all of the red ones will open up way ahead so you can move forward.',
				'But be careful, stepping on a tile you\'ve already turned green will reset the whole dance pad.',
				'Only after turning them all green will you be able to step on them again without them resetting.',
				'You\'ll also need to fight a few of the gym\'s official trainers to get to the Gym Leader.',
				'Good luck, and if you have any questions, you can come back and talk to me.'
			}
			if completedEvents.IntroducedToGym1 then
				interact[guide.model] = postIntroInteract
			else
				touchEvent('IntroducedToGym1', m.EagerTrigger, true, function()
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					spawn(function() _p.MasterControl:LookAt(guide.model.HumanoidRootPart.Position) end)
					spawn(function() guide:LookAt(_p.player.Character.HumanoidRootPart.Position) end)
					chat:say(guide, 'Hey slow down there Eager McBidoof.',
						'This must be your first Pok[e\']mon Gym visit.',
						'Let me just give you the lowdown really quickly.',
						'Every Pok[e\']mon Gym focuses on a specific type of Pok[e\']mon in battle.',
						'I don\'t usually give away this kind of information but this gym\'s specialty is Electric-type Pok[e\']mon.',
						unpack(postIntroInteract))
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					interact[guide.model] = postIntroInteract
				end)
			end
			-- dancers
			m.HorseDancer.Humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCDance1 }):Play()
			m.GrannyDancer.Humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCDance2 }):Play()
			m.PerkyDancer.Humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCDance3 }):Play()
			m.EpicDancer.Humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCDance3 }):Play()
			m.HipDancer.Humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCDance1 }):Play()
			--		create 'BodyAngularVelocity' {
			--			AngularVelocity = Vector3.new(0, 20, 0),
			--			MaxTorque = Vector3.new(0, 5e5, 0),
			--			P = 9e3,
			--			Parent = m.HipDancer.HumanoidRootPart,
			--		}
			-- puzzles
			local function setupPuzzle(puzzle, blockade)
				local on = false
				local won = false
				local failed = false
				local currentTile
				local baseRegions = {}
				local tileRegions = {}
				for _, p in pairs(puzzle:GetChildren()) do
					if p:IsA('BasePart') then
						if p.Name == 'Base' then
							table.insert(baseRegions, _p.Region.new(p.CFrame + Vector3.new(0, 5, 0), p.Size + Vector3.new(0, 10, 0)))
						else
							tileRegions[p] = _p.Region.new(p.CFrame + Vector3.new(0, 5, 0), p.Size + Vector3.new(.6, 10, .6))
						end
					end
				end
				local function reset()
					currentTile = nil
					failed = false
					for _, p in pairs(puzzle:GetChildren()) do
						if p:IsA('BasePart') then
							if p.Name == 'Base' then
								p.BrickColor = BrickColor.new('Fossil')
							else
								p.BrickColor = BrickColor.new('Really red')
							end
						end
					end
				end
				local function win()
					won = true
					for _, p in pairs(blockade:GetChildren()) do
						if p.Name == 'LineSegment' or p.Name == 'Wall' then
							p:remove()
						end
					end
				end
				local function fail()
					failed = true
					for _, p in pairs(puzzle:GetChildren()) do
						if p:IsA('BasePart') then
							if p.Name == 'Base' then
								p.BrickColor = BrickColor.new('Really red')
							else
								p.BrickColor = BrickColor.new('Bright red')
							end
						end
					end
				end
				local root = _p.player.Character.HumanoidRootPart
				spawn(function()
					while not won and puzzle.Parent do
						stepped:wait()
						if not battleService.currentBattle then
							local p = root.Position
							local isIn = false
							for _, r in pairs(baseRegions) do
								if r:CastPoint(p) then
									isIn = true
									break
								end
							end
							if isIn then
								on = true
								if not failed then
									for tile, region in pairs(tileRegions) do
										if region:CastPoint(p) then
											if tile == currentTile then break end
											if tile.BrickColor.Name == 'Lime green' then
												fail()
											else
												tile.BrickColor = BrickColor.new('Lime green')
												currentTile = tile
												local didWin = true
												for tile in pairs(tileRegions) do
													if tile.BrickColor.Name ~= 'Lime green' then
														didWin = false
														break
													end
												end
												if didWin then
													win()
												end
											end
											break
										end
									end
								end
							else
								if on then
									reset()
									on = false
								end
							end
						end
					end
				end)
			end
			if doPuzzle1 then
				setupPuzzle(m.Puzzle1, m.Blockade1)
			end
			if doPuzzle2 then
				setupPuzzle(m.Puzzle2, m.Blockade2)
			end
			-- lasers
			local offset = CFrame.new(0, -0.6, 0)
			local offsetInverse = offset:inverse()
			local tweens = {'easeInCubic','easeOutCubic','easeInOutCubic','linear'}
			local rayFn = Utilities.findPartOnRayWithIgnoreFunction
			local ignoreFn = function(p) return p.Transparency >= 0.2 end
			for _, l in pairs(m.Lasers:GetChildren()) do
				local main = l.StadiumLight
				local o = l.StadiumLight.CFrame*offset
				local p = l.Part
				local pc = l.StadiumLight.CFrame:toObjectSpace(l.Part.CFrame)
				local beam = l.Beam
				local alpha = 0
				local beta = 0
				local function shootRay()
					local sp = p.Position
					local ep = select(2, rayFn(Ray.new(sp, (sp-main.Position).unit*100), {main, p, beam}, ignoreFn))
					beam.Size = Vector3.new((sp-ep).magnitude, .2, .2)
					beam.CFrame = CFrame.new(sp + (ep-sp)/2, ep) * CFrame.Angles(0, math.pi/2, 0)
				end
				spawn(function()
					while main.Parent do
						local newalpha = (math.random()-0.5)*2
						local newbeta = (math.random()-0.5)*2
						Tween(0.5+2*math.random(), tweens[math.random(#tweens)], function(a)
							local cf = o * CFrame.Angles(alpha + (newalpha-alpha)*a, 0, beta + (newbeta-beta)*a)
							main.CFrame = cf * offsetInverse
							p.CFrame = main.CFrame:toWorldSpace(pc)
							shootRay()
						end)
						alpha = newalpha
						beta = newbeta
						while battleService.currentBattle do wait(1) end
						Tween(0.5+1*math.random(), nil, function()
							shootRay()
						end)
					end
				end)
			end
			-- floor colors
			spawn(function()
				while m.Parent do
					m.Base.Color = Color3.new(math.random(), math.random(), math.random())
					m.GymAmbient.AmbientLight.Color = m.Base.BrickColor.Color
					while battleService.currentBattle do wait(1) end
					wait(2)
				end
			end)
		end,

		onExit_Gym1 = function()
			if not _p.PlayerData.badges[1] or completedEvents.ReceivedRTD then return end
			spawn(function() _p.PlayerData:completeEvent('ReceivedRTD') end)
			spawn(function() _p.Menu:disable() end)

			local jake = _p.NPC:new(_p.storage.Modelss.NPCs.Jake:Clone())
			jake.model.Parent = _p.DataManager.currentChunk.map
			jake:Animate()
			pcall(function() jake.model.Interact:remove() end)
			chat:say('Oh hey ' .. _p.PlayerData.trainerName .. '!')
			local playerPos = _p.player.Character.HumanoidRootPart.Position
			local jakePos = Vector3.new(-1207, 93, -858)---1207, 95.5, -859)
			jake:Teleport(CFrame.new(jakePos, playerPos))
			spawn(function() _p.MasterControl:LookAt(jakePos) end)
			local cam = workspace.CurrentCamera
			local camP = CFrame.new(cam.CoordinateFrame.p+Vector3.new(-1, -4, -8), jake.model.Head.Position)
			local walking = true
			spawn(function()
				local jp = playerPos+(jake.model.HumanoidRootPart.Position-playerPos).unit*5
				jake:WalkTo(jp + Vector3.new(0, playerPos.Y-jp.y, 0))
				walking = false
			end)
			local start = tick()
			while true do
				stepped:wait()
				if tick()-start > 4 then
					cam.CoordinateFrame = CFrame.new(camP.p, jake.model.Head.Position)
					break
				end
				local speed = 0.05 + 0.1*(tick()-start)
				local cf = cam.CoordinateFrame
				local focus = cf.p + cf.lookVector * (jake.model.Head.Position - cf.p).magnitude
				if (jake.model.Head.Position-focus).magnitude < 0.2 and not walking then break end
				cam.CoordinateFrame = CFrame.new(cf.p + (camP.p-cf.p)*speed, focus + (jake.model.Head.Position-focus)*speed)
			end
			chat:say(jake, 'Wow, you have the Arc Badge now.',
				'I\'m on my way to challenge the gym right now.',
				'I really hope my Pok[e\']mon are as strong as yours.',
				'Maybe we can have another battle soon.',
				'Anyways, check this out.',
				'This is the reason I was late getting here.',
				'It\'s called an RTD.',
				'I want you to have this one.')
			Utilities.sound(304774035, nil, nil, 8)
			_p.Menu.rtd:enable()
			--		spawn(function() _p.Menu.rtd:open() end)
			chat:say('Obtained the RTD!')
			--		spawn(function() _p.Menu.rtd:close() end)
			chat:say(jake, 'RTD stands for Recreational Teleportation Device.',
				'It allows you to teleport to some really neat places just for trainers like you and I.',
				'For example, the Trade Resort or the Battle Colloseum.',
				'The Trade Resort is where trainers can go to trade their Pok[e\']mon with other trainers.',
				'The Battle Colloseum is also a place for trainers where they can battle other trainers\' Pok[e\']mon.',
				'It\'s really convenient having specific places to go when you\'re in the mood for trading or battling others.',
				'Anyways, time to get me that badge!',
				'Seeya later, ' .. _p.PlayerData.trainerName .. '.')
			local door = _p.DataManager.currentChunk:getDoor('Gym1')
			spawn(function()
				_p.MasterControl:WalkTo(_p.player.Character.HumanoidRootPart.Position + Vector3.new(3, 0, 5))
				_p.MasterControl:LookAt(door.Position)
			end)
			local done = false
			spawn(function()
				jake:WalkTo(door.Position + Vector3.new(1.5, 0, 0))
				door:open(.75)
				spawn(function() jake:WalkTo(door.Position + Vector3.new(-10, 0, 0)) end)
				wait(.5)
				door:close(.75)
				jake:remove()
				done = true
			end)
			local s = tick()
			while not done do
				wait()
				if tick()-s > 8 then
					pcall(function() jake:remove() end)
					break
				end
			end
			spawn(function() _p.Menu:enable() end)

			return true
		end,

		-- Act II
		onLoad_chunk3 = function(chunk)
			local defaultio = chunk.npcs.Defaultio
			if _p.PlayerData.badges[2] then
				defaultio:remove()
			else
				interact[defaultio.model] = function()
					if completedEvents.GetCut then
						defaultio:Say('You need the badge from the Silvent City Gym in order to use Cut outside of battle.',
							'Be careful when teaching HMs to Pok[e\']mon.',
							'A Pok[e\']mon cannot forget an HM move unless brought to a specific person, known as the Move Deleter.')
					else
						_p.PlayerData:completeEvent('GetCut')
						chat:say(defaultio, 'Oh, the life of a lumberjack.',
							'Hacking away at trees for days, with your trusty axe.',
							'Pok[e\']mon can also cut down the smaller trees if you teach them the move Cut!',
							'You\'ll need the badge from the Silvent City Gym in order to use Cut outside of battle, but here\'s the HM so that you can teach it to your Pok[e\']mon!')
						onObtainItemSound()
						chat:say('Obtained an HM01!', _p.PlayerData.trainerName .. ' put the HM01 in the Bag.')
						chat:say(defaultio, 'Be careful when teaching HMs to Pok[e\']mon.',
							'A Pok[e\']mon cannot forget an HM move unless brought to a specific person, known as the Move Deleter.')
					end
				end
			end
		end,

		onLoad_chunk4 = function(chunk)
			touchEvent('RunningShoesGiven', chunk.map.RunningShoesTrigger, true, function()
				local wsly = chunk.npcs.Wsly
				wsly.walkAnim = wsly.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.Run })
				local door = chunk:getDoor('Gate3')
				wsly:Teleport(CFrame.new(door.Position + Vector3.new(-4, -2, 0), door.Position + Vector3.new(0, -2, 0)))
				spawn(function() _p.Menu:disable() end)
				door:open(.5)
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				chat:say('Hey, wait up!')
				local midZ = -1398
				local pRoot = _p.player.Character.HumanoidRootPart
				local dir = -Vector3.new(pRoot.CFrame.Z - midZ, 0, 0).unit.X
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				local walking = true
				spawn(function()
					local p = _p.player.Character.Head.Position + Vector3.new(8, 5, dir*5)
					Utilities.lookAt(p, function() return wsly.model.Head.Position end, 1)
					while walking do
						stepped:wait()
						workspace.CurrentCamera.CoordinateFrame = CFrame.new(p, wsly.model.Head.Position)
					end
				end)
				wsly.humanoid.WalkSpeed = 26
				delay(.5, function()
					door:close(.75)
				end)
				spawn(function()
					_p.MasterControl:LookAt(wsly.model.Head.Position)
				end)
				wsly:WalkTo(pRoot.Position + (wsly.model.Torso.Position-pRoot.Position).unit*5)
				walking = false
				local answer = chat:say(wsly, '[y/n]You look like you love running, am I right?')
				if answer then
					chat:say(wsly, 'Me too!')
				else
					chat:say(wsly, 'Well I do!')
				end
				chat:say(wsly, 'I just ran for 024035103:56...')
				if answer then
					chat:say(wsly, 'I actually have an extra pair of Running Shoes!',
						'Here, I want you to have them.')
				else
					chat:say(wsly, 'Take this extra pair of Running Shoes.',
						'I know you\'ll fall in love with running in no time!')
				end
				onObtainKeyItemSound()
				chat:say('Obtained the Running Shoes!')
				_p.RunningShoes:enable()
				if Utilities.isTouchDevice() then
					chat:say(wsly, 'Just hit the Run button on your screen to use them!')
				else
					chat:say(wsly, 'Just hold the left Shift key to use them!',
						'If that\'s not your style, you can change how they work from the Options menu.')
				end
				chat:say(wsly, 'Try and keep up with me!')
				if dir == 0 then dir = 1 end
				local wp = pRoot.Position + Vector3.new(0, 0, dir*5)
				wsly:WalkTo(wp)
				spawn(function()
					--				Utilities.lookBackAtMe()
					Utilities.lookAt(_p.player.Character.Head.Position + Vector3.new(-4, 1, 0).unit*12.5, _p.player.Character.Head.Position, 1)
					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
				end)
				if math.abs(wp.z-midZ) > 12 then
					wp = Vector3.new(-976, 119, wp.z<midZ and midZ-12 or midZ+12)
					wsly:WalkTo(wp)
				end
				wsly.gyro.Parent = nil
				wsly.position.Parent = nil
				spawn(function()
					wsly:WalkTo(Vector3.new(wp.x+50, wp.y, midZ+6))
				end)
				wait(1.5)
				local cage = chunk.map.RopeCage:Clone()
				cage.Parent = chunk.map--wsly.model
				local main = cage.Main
				local function w(m)
					for _, p in pairs(m:GetChildren()) do
						if p:IsA('BasePart') and p ~= main then
							create 'Weld' {
								Part0 = main,
								Part1 = p,
								C0 = CFrame.new(),
								C1 = p.CFrame:inverse() * main.CFrame,
								Parent = main,
							}
							p.Anchored = false
						elseif p:IsA('Model') then
							w(p)
						end
					end
				end
				w(cage)
				main.Anchored = false
				local root = wsly.model.HumanoidRootPart
				create 'Weld' {
					Part0 = root,
					Part1 = main,
					C0 = CFrame.new(0, 3.6, 0),
					C1 = CFrame.new(),
					Parent = root,
				}
				wsly.humanoid.PlatformStand = true
				wsly:Stop()
				wait(1)
				--			_p.BubbleChat:enable()
				--			_p.BubbleChat:OnGameChatMessage(wsly.model.Head, 'not again!')
				local bbg = wsly.model.Head.ChatGui
				bbg.Adornee = bbg.Parent
				bbg.BillboardFrame.Visible = true
				wait(2)
				wsly.model:BreakJoints()
				local sound = create 'Sound' {
					SoundId = 'rbxasset://sounds/uuhhh.mp3',
					Volume = 1,
					Parent = wsly.model.Head,
				}
				sound:Play()
				wait(2)
				bbg:remove()
				wait(2)
				wsly:remove()
				cage:remove()
				--			_p.BubbleChat:disable()
			end)
		end,

		onDoorFocused_Gate4 = function()
			if _p.DataManager.currentChunk.id ~= 'chunk4' then return end
			if completedEvents.JakeBattle2 then return end
			spawn(function() _p.Menu:disable() end)
			chat:say('Wait up!')
			local yp = _p.player.Character.HumanoidRootPart.Position + Vector3.new(0, 0, -4)
			local sp = yp + Vector3.new(0, 0, -12)
			_p.MasterControl:LookAt(sp)
			wait(.5)
			_p.MasterControl:WalkTo(yp)
			wait(.25)
			local jake = _p.NPC:PlaceNew('Jake', _p.DataManager.currentChunk.map, CFrame.new(sp, yp))
			local jp = yp + (sp-yp).unit * 4
			jake:WalkTo(jp)
			chat:say(jake, 'I finally caught up to you!', 'When did you get so fast?', 'Anyways, let\'s have another battle!',
				'After getting the Arc Badge, I feel like my Pok[e\']mon are a lot tougher this time!')

			local win = _p.Battle:doTrainerBattle {
				battleScene = 'Safari',
				musicId = 12639840340,
				PreventMoveAfter = true,
				LeaveCameraScriptable = true,
				trainerModel = jake.model,
				num = 110
			}
			if not win then
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				chat:enable()
				_p.Menu:enable()
				return true
			end

			chat:say(jake, 'Brimber City should be just through this gate.',
				'They have a Pok[e\']mon Gym there too.',
				'We should also ask around and see if anyone knows anything about Team Eclipse while we\'re here.',
				'I\'m gonna head over to the Pok[e\']mon Center and heal my Pok[e\']mon!',
				'See you later!')
			local door = _p.DataManager.currentChunk:getDoor('Gate4')
			spawn(function() _p.MasterControl:LookAt(door.Position) end)
			jake:WalkTo(yp + Vector3.new(yp.X < door.Position.X and 3 or -3, 0, 0))
			delay(.1, function()
				door:open(.5)
			end)
			jake:WalkTo(door.Position)
			spawn(function() jake:WalkTo(door.Position + Vector3.new(0, 0, 20)) end)
			wait(.2)
			door:close(.5)
			wait(.5)
			jake:remove()

			Utilities.lookBackAtMe()
			--_p.MasterControl:Start()
			_p.MasterControl.WalkEnabled = true
			spawn(function() _p.Menu:enable() end)
			return true
		end,

		onExit_Gate4 = function()
			local chunk = _p.DataManager.currentChunk
			if chunk.id ~= 'chunk5' then return end
			if completedEvents.TalkToJakeAndSebastian then return end
			chat:say(_p.PlayerData.trainerName .. ', quick, over here!')
			local jp = Vector3.new(-109, 144, -1426)
			local lp = Vector3.new(-115, 144, -1426)
			local wp = Vector3.new(-112, 144, -1430)
			local pp = _p.player.Character.HumanoidRootPart.Position
			local jake = _p.NPC:PlaceNew('Jake', chunk.map, CFrame.new(jp, pp))
			local leader = _p.NPC:PlaceNew('LeaderSebastian', chunk.map, CFrame.new(lp, pp))

			local cam = workspace.CurrentCamera
			local camGoal = CFrame.new(-126.174782, 156.702637, -1447.93384, -0.837163031, 0.28281191, -0.468162, -0, 0.855944753, 0.517067432, 0.546953619, 0.432869732, -0.716565132)
			local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, camGoal))
			spawn(function()
				Tween(1.5, 'easeOutCubic', function(a)
					local cf = lerp(a)
					cam.CoordinateFrame = CFrame.new(cf.p, cf.p+cf.lookVector)
				end)
			end)
			_p.MasterControl:WalkTo(wp)
			spawn(function() _p.PlayerData:completeEvent('TalkToJakeAndSebastian') end)
			spawn(function() leader:LookAt(wp) end)
			jake:LookAt(wp)
			chat:say(jake, 'This is the Gym Leader of the Brimber City Gym.',
				'I just ran into him as I walked into town.')
			spawn(function() leader:LookAt(jp) end)
			jake:LookAt(lp)
			chat:say(jake, 'Would it be OK if we stopped by the gym later today for a challenge?')
			chat:say(leader, 'I\'m sorry but the gym is closed for right now.',
				'Earlier this morning, something terrible happened.',
				'A group of bandits known as Team Eclipse raided my gym and stole a priceless artifact.')
			chat:say(jake, 'What exactly did they steal?')
			chat:say(leader, 'It is called the Red Orb.',
				'The Red Orb has been passed down for generations in my family.',
				'A long time ago, my ancestors, when passing through this valley, found the Red Orb inside the volcano.',
				'Legend has it that the Red Orb is used to awaken a sleeping Pok[e\']mon within the volcano.',
				'Supposedly the Pok[e\']mon\'s power is tremendous enough to cause the volcano to erupt.',
				'I\'m not much of a believer in legends, but if this were true, it could remove this entire city and half of Roria.',
				'I don\'t think Team Eclipse realizes that.',
				'I believe they\'re just after the legendary Pok[e\']mon.',
				'Until I know more, it is unsafe to practice battling inside the gym.')
			spawn(function() leader:LookAt(wp) end)
			jake:LookAt(wp)
			chat:say(jake, _p.PlayerData.trainerName .. ', if Team Eclipse is nearby, maybe they\'ll have your parents.',
				'We have to go look for them!')
			chat:say(leader, 'Team Eclipse is a dangerous group.',
				'It\'s not wise to go after them, but I\'m not going to stop you.')
			spawn(function() leader:LookAt(jp) end)
			jake:LookAt(lp)
			chat:say(jake, 'Which way did they go?')
			leader:LookAt(Vector3.new(-250, 145, -1332))
			chat:say(leader, 'They were headed towards Route 6.',
				'Route 6 leads to the entrance in the side of the volcano.')
			leader:LookAt(wp)
			chat:say(leader, 'Whatever you decide to do, be very careful.')
			chat:say(jake, 'Before I do anything, I\'m going to get my Pok[e\']mon healed.')
			jake:LookAt(wp)
			chat:say(jake, _p.PlayerData.trainerName .. ', you go ahead and try and find Team Eclipse.',
				'I\'ll try and meet up with you later.')
			local door = chunk:getDoor('PokeCenter')
			jake:WalkTo(door.Position + (jp-door.Position).unit*2)
			door:open(.5)
			delay(.25, function() door:close(.5) end)
			jake:WalkTo(door.Position + Vector3.new(0, 0, 10))
			jake:remove()
			table.insert(chunk.npcs, leader)
			interact[leader.model] = {'Team Eclipse is on their way to the volcano with the Red Orb now.',
				'If they aren\'t stopped, I fear for the survival of the city.'}
			delay(.5, function() _p.Menu:enable() end)

			return true
		end,

		onBeforeEnter_FriendshipHouse = function(room)
			local checker = room.npcs.FriendshipChecker
			interact[checker.model] = function()
				local phrase, done
				Utilities.fastSpawn(function()
					phrase = _p.Network:get('PDS', 'getHappiness')
					done = true
				end)
				chat:say(checker, 'Let me take a look at your Pok[e\']mon.')
				while not done do wait() end
				if not phrase then return end
				chat:say(checker, unpack(phrase))
			end
		end,

		onLoad_chunk5 = function(chunk)
			if completedEvents.GroudonScene then
				chunk.npcs.GymClosed:remove()
			else
				for _, door in pairs(chunk.doors) do
					if door.id == 'Gym2' then
						door.disabled = true
					end
				end
			end
			if _p.PlayerData.badges[2] then
				chunk.map.ConstructionWorker:remove()
				chunk.map.ConstructionWall:remove()
			else
				chunk:getDoor('Gate6').disabled = true
			end

			-- Volcanion Security
			local door = chunk.map:FindFirstChild('CaveDoor:chunk62')
			if not completedEvents.RevealSteamChamber then
				door.CanTouch = false
			end

			if completedEvents.RevealSteamChamber then
				chunk.map.RockSmash:Destroy()
			end

			local rocknpc = chunk.npcs.Punch
			interact[rocknpc.model] = function()
				if completedEvents.RevealSteamChamber then
					rocknpc:Say('Thanks for the meal!')
					return
				end
				rocknpc:Say('I\'ve been training my fists on this rock.',
					'I\'ve been at it so long that I\'m starting to get tired and hungry.'
				)
				local hasitems = _p.Network:get('PDS', 'hasvolitems', 'epineshroom')
				if hasitems.epineshroom then
					rocknpc:Say('What\'s that I smell?',
						'Is that Epineshroom?',
						'That\'s my favorite meal. It always gets me PUMPED!'
					)
					if rocknpc:Say('[y/n]Can I have your Epineshroom?') then
						_p.Network:get('PDS', 'hasvolitems', 'epineshroom', true)
						rocknpc:Say('Thanks!')
						wait(1)
						rocknpc:Say('Oh man, I can\'t believe how good this is!',
							'I can feel my adrenaline rushing now!'
						)
						local cam = workspace.CurrentCamera
						cam.CameraType = Enum.CameraType.Scriptable
						cam.CFrame = CFrame.new(-178.859772, 155.180283, -1314.01794, -0.70710516, 0, 0.70710516, 0, 1, 0, -0.70710516, 0, -0.70710516)
						rocknpc:LookAt(chunk.map.RockSmash.Main.Position)
						spawn(function()
							local animation = rocknpc.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCPoint })
							animation:Play()
							animation:Destroy()
						end)
						rocknpc:Say('HUAAAAAH!')
						wait(1)
						local rm = game.ReplicatedStorage.Modelss.BrokenRock:Clone()	
						local main = chunk.map.RockSmash.Main
						local cf = main.CFrame
						local scale = main.Size.Magnitude / 14.8471231460572	
						Utilities.ScaleModel(rm.Main, scale)
						Utilities.MoveModel(rm.Main, cf)
						rm.Main:Destroy()
						chunk.map.RockSmash:Destroy()
						rm.Parent = workspace			
						for _, p in pairs(rm:GetChildren()) do
							if p:IsA('BasePart') then
								p.Anchored = false
								local dir = (p.Position-cf.p+Vector3.new(0,1,0)).unit
								p.Velocity = dir * 20
								local force = create 'BodyForce' {
									Force = dir * 50 * p:GetMass(),
									Parent = p
								}
								delay(.25, function() force:Destroy() end)
							end
						end	
						wait(1)
						Utilities.Tween(.5, nil, function(a)
							for _, p in pairs(rm:GetChildren()) do
								if p:IsA('BasePart') then
									p.Transparency = a
								end
							end
						end)
						rm:Destroy()
						cam.CameraType = Enum.CameraType.Custom
						rocknpc:LookAt(_p.player.Character.HumanoidRootPart.Position)
						rocknpc:Say('Wow, I was so pumped after that meal that I smashed right through that rock!',
							'My training has finally paid off.',
							'Thanks for the meal!')
						door.CanTouch = true
						_p.MasterControl.WalkEnabled = true				
						spawn(function() _p.Menu:enable() end)
						wait(1)
					else
						rocknpc:Say('Aww, that\'s too bad.')
					end
				end
			end
		end,

		onLoad_chunk6 = function(chunk)
			if completedEvents.GroudonScene then
				for _, npc in pairs(chunk.npcs) do
					if npc.model:FindFirstChild('IsTeamEclipse') then
						npc:remove()
					end
				end
			end

			_p.DataManager:preload(317129150)
			local trigger = chunk.map.ToChunk7Trigger
			trigger.Touched:connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player or not _p.MasterControl.WalkEnabled then return end
				if _p.DataManager.currentChunk.doorDebounce then return end
				_p.DataManager.currentChunk.doorDebounce = true
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				spawn(function()
					_p.MasterControl:WalkTo(Vector3.new(383, 127, -1307))
				end)
				local container = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 1.0, 36),
					Position = UDim2.new(0.0, 0, 0.0, -36),
					Parent = Utilities.frontGui,
				}
				local scope = create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://6142857420',
					Parent = container,
				}
				local left   = create 'Frame' { BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = container, }
				local right  = create 'Frame' { BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = container, Position = UDim2.new(1.0, 0, 0.0, 0), }
				local top    = create 'Frame' { BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = container, }
				local bottom = create 'Frame' { BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = container, Position = UDim2.new(0.0, 0, 1.0, 0), }

				local cam = workspace.CurrentCamera
				local camF0 = cam.Focus.p
				local camC0 = cam.CoordinateFrame.p
				local camF1 = trigger.Position
				local camC1 = trigger.Position + (trigger.CFrame * CFrame.Angles(0, -math.pi/2, 0) * CFrame.Angles(math.rad(35), 0, 0)).lookVector*20
				cam.CameraType = Enum.CameraType.Scriptable
				Tween(.5, 'easeOutCubic', function(a)
					cam.CoordinateFrame = CFrame.new(camC0:Lerp(camC1, a), camF0:Lerp(camF1, a))
				end)
				_p.MusicManager:popMusic('all', 1)
				Tween(1, nil, function(a)
					local x = container.AbsoluteSize.X * 2 * (1-a)
					scope.Size = UDim2.new(0.0, x, 0.0, x)
					scope.Position = UDim2.new(0.5, -x/2, 0.6, -x/2)
					left.Size   = UDim2.new(0.5, -x/2, 1.0, 0)
					right.Size  = UDim2.new(-0.5, x/2, 1.0, 0)
					top.Size    = UDim2.new(1.0, 0, 0.6, -x/2)
					bottom.Size = UDim2.new(1.0, 0, -0.4, x/2)
				end)
				_p.MasterControl:Stop()
				-- teleport to spawn box for now
				Utilities.Teleport(CFrame.new(3, 70, 389) + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20)))
				chunk:remove()
				local newChunk = _p.DataManager:loadMap('chunk7')
				newChunk.doorDebounce = true
				local newTrigger = newChunk.map.ToChunk6Trigger
				cam.CoordinateFrame = CFrame.new(newTrigger.Position + (CFrame.new(newTrigger.Position, newTrigger.Position + Vector3.new(1, 0, 0)) * CFrame.Angles(math.rad(20), 0, 0)).lookVector*20, newTrigger.Position)
				Utilities.Teleport(CFrame.new(Vector3.new(-779, 50, -705), Vector3.new(-750, 50, -705)))
				spawn(function()
					Tween(1, nil, function(a)
						local x = container.AbsoluteSize.X * 2 * a
						scope.Size = UDim2.new(0.0, x, 0.0, x)
						scope.Position = UDim2.new(0.5, -x/2, 0.6, -x/2)
						left.Size   = UDim2.new(0.5, -x/2, 1.0, 0)
						right.Size  = UDim2.new(-0.5, x/2, 1.0, 0)
						top.Size    = UDim2.new(1.0, 0, 0.6, -x/2)
						bottom.Size = UDim2.new(1.0, 0, -0.4, x/2)
					end)
					container:remove()
				end)
				_p.MasterControl:WalkTo(newTrigger.Position + Vector3.new(5, 0, 0))
				Utilities.lookBackAtMe()
				newChunk.doorDebounce = false
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
			end)
		end,

		onLoad_chunk7 = function(chunk)
			_p.DataManager:preload(317129150)
			
			-- Check if player has already completed the Groudon event
		--	if _p.PlayerData.completedEvents.Groudon then
		--		chunk.map.Pedestal["#InanimateInteract"]:remove()

		--	end

			local trigger = chunk.map.ToChunk6Trigger
			trigger.Touched:connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player or not _p.MasterControl.WalkEnabled then return end
				if _p.DataManager.currentChunk.doorDebounce then return end
				_p.DataManager.currentChunk.doorDebounce = true
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				spawn(function()
					_p.MasterControl:WalkTo(Vector3.new(-779, 50, -705))
				end)
				local container = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 1.0, 36),
					Position = UDim2.new(0.0, 0, 0.0, -36),
					Parent = Utilities.frontGui,
				}
				local scope = create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://6142857420',
					Parent = container,
				}
				local left   = create 'Frame' { BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = container, }
				local right  = create 'Frame' { BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = container, Position = UDim2.new(1.0, 0, 0.0, 0), }
				local top    = create 'Frame' { BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = container, }
				local bottom = create 'Frame' { BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = container, Position = UDim2.new(0.0, 0, 1.0, 0), }

				local cam = workspace.CurrentCamera
				local camF0 = cam.Focus.p
				local camC0 = cam.CoordinateFrame.p
				local camF1 = trigger.Position
				local camC1 = trigger.Position + (trigger.CFrame * CFrame.Angles(0, math.pi, 0) * CFrame.Angles(math.rad(20), 0, 0)).lookVector*20
				cam.CameraType = Enum.CameraType.Scriptable
				Tween(.5, 'easeOutCubic', function(a)
					cam.CoordinateFrame = CFrame.new(camC0:Lerp(camC1, a), camF0:Lerp(camF1, a))
				end)
				_p.MusicManager:popMusic('all', 1)
				Tween(1, nil, function(a)
					local x = container.AbsoluteSize.X * 2 * (1-a)
					scope.Size = UDim2.new(0.0, x, 0.0, x)
					scope.Position = UDim2.new(0.5, -x/2, 0.6, -x/2)
					left.Size   = UDim2.new(0.5, -x/2, 1.0, 0)
					right.Size  = UDim2.new(-0.5, x/2, 1.0, 0)
					top.Size    = UDim2.new(1.0, 0, 0.6, -x/2)
					bottom.Size = UDim2.new(1.0, 0, -0.4, x/2)
				end)
				_p.MasterControl:Stop()
				-- teleport to spawn box for now
				Utilities.Teleport(CFrame.new(3, 70, 389) + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20)))
				chunk:remove()
				local newChunk = _p.DataManager:loadMap('chunk6')
				newChunk.doorDebounce = true
				local newTrigger = newChunk.map.ToChunk7Trigger
				cam.CoordinateFrame = CFrame.new(newTrigger.Position + (newTrigger.CFrame * CFrame.Angles(0, -math.pi/2, 0) * CFrame.Angles(math.rad(35), 0, 0)).lookVector*20, newTrigger.Position)
				Utilities.Teleport(CFrame.new(Vector3.new(383, 127, -1307), newTrigger.Position))
				spawn(function()
					Tween(1, nil, function(a)
						local x = container.AbsoluteSize.X * 2 * a
						scope.Size = UDim2.new(0.0, x, 0.0, x)
						scope.Position = UDim2.new(0.5, -x/2, 0.6, -x/2)
						left.Size   = UDim2.new(0.5, -x/2, 1.0, 0)
						right.Size  = UDim2.new(-0.5, x/2, 1.0, 0)
						top.Size    = UDim2.new(1.0, 0, 0.6, -x/2)
						bottom.Size = UDim2.new(1.0, 0, -0.4, x/2)
					end)
					container:remove()
				end)
				_p.MasterControl:WalkTo(newTrigger.Position + (newTrigger.CFrame * CFrame.Angles(0, -math.pi/2, 0)).lookVector*5)
				Utilities.lookBackAtMe()
				newChunk.doorDebounce = false
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
			end)


			--===== Groudon cutscene =====--

			if completedEvents.GroudonScene then
				for _, npc in pairs(chunk.npcs) do
					if npc.model:FindFirstChild('IsTeamEclipse') then
						npc:remove()
					end
				end
			else
				_p.DataManager:preload(12640050794, 12640051993, 5226446060, 317440901, 12640115508, 12640116297, 68068592, 317480860) -- admin music, eclipse logo, earthquake, groudon scene music[2], particle, pulse
				_p.DataManager:queueSpritesToCache({'_FRONT', 'Groudon'}) -- for the cry
				_p.DataManager:preloadModule('AnchoredRig')

				touchEvent('GroudonScene', chunk.map.GroudonTrigger, false, function()
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					spawn(function() _p.Menu:disable() end)

					local cam = workspace.CurrentCamera
					cam.CameraType = Enum.CameraType.Scriptable

					local camCFrame1 = CFrame.new(-809.025024, 83.6930923, -824.031494, -0.857597828, -0.196856126, 0.475156426, -0, 0.923852146, 0.382749647, -0.51432085, 0.328245252, -0.792293608)
					local camCFrame2 = CFrame.new(-839.190063, 75.9603577, -802.962585, -0.954399168, 0.0467679016, 0.294847548, -0, 0.987652898, -0.156658739, -0.298533618, -0.149514973, -0.942614973)

					spawn(function()
						local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, camCFrame1))
						Tween(1.5, 'easeOutQuad', function(a)
							local cf = lerp(a)
							cam.CoordinateFrame = CFrame.new(cf.p, cf.p+cf.lookVector)-- no roll
						end)
					end)

					local admin = chunk.npcs.EclipseAdmin
					local ap = admin.model.HumanoidRootPart.Position
					local pp = _p.player.Character.HumanoidRootPart.Position
					_p.MasterControl:WalkTo(ap + (pp-ap).unit*8)
					admin:LookAt(pp)
					chat:say(admin, 'Oh, hello there.',
						'You are just in time for the show.',
						'What\'s this? You want your parents to be set free?',
						'You must be the child of those two archeologists we abducted back in Mitis Town.',
						'Your parents have been rather difficult to work with.',
						'They were not cooperative at first.',
						'It wasn\'t until after we threatened to harm their family that they gave in to our requests.',
						'They must have been afraid for you.',
						'They have every right to be.',
						'I\'m afraid if you are here to stop us then you are too late.',
						'According to legend, I need only lay this orb on the pedestal behind me in order to awaken a powerful, sleeping Pok[e\']mon.',
						'Why awaken such a beast you ask?',
						'Thats for us to know.',
						'I\'m afraid you will not be privileged to find out the purposes to our actions at this time.',
						'...',
						'I grow weary of speaking to you, child.',
						'It is time for me to carry out our plan.',
						'What? You won\'t allow that?',
						'You fear for the town\'s safety, do you?',
						'Well, if you are only here to get in my way then I\'m afraid that the only way to be rid of you is with a Pok[e\']mon battle.',
						'I warn you, though.',
						'I am one of Team Eclipse\'s admins.',
						'I will not be defeated!')

					local win = _p.Battle:doTrainerBattle {
						IconId = 5226446131,
						musicId = {12640050794, 12640051993},
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = admin.model,
						num = 111
					}
					if not win then
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
						return
					end

					chat:say(admin, 'Well, it seems you are quite strong for such a new trainer.',
						'No matter, I have come here to carry out a very important task.',
						'I will not let my leader down!',
						'Prepare yourself for the awesome power within this volcano!')
					spawn(function() _p.MusicManager:prepareToStack(1) end)
					local op = chunk.map.RedOrb.Position
					op = Vector3.new(op.x, ap.y, op.z)
					admin:WalkTo(op + (ap-op).unit*4)
					admin:LookAt(op)
					chunk.map.RedOrb.Transparency = 0
					wait(1)

					local gp = Vector3.new(-846, 72, -767)
					spawn(function() _p.MasterControl:LookAt(gp) end)
					local eclipse = {admin, chunk.npcs.grunt1, chunk.npcs.grunt2, chunk.npcs.grunt3}
					for _, npc in pairs(eclipse) do
						spawn(function() npc:LookAt(gp) end)
					end
					local lerp = select(2, Utilities.lerpCFrame(camCFrame1, camCFrame2))
					local groudon = chunk.map.Groudon
					local rig = _p.DataManager:loadModule('AnchoredRig'):new(groudon)
					rig:connect(groudon, groudon.Body)
					rig:connect(groudon.Body, groudon.Head)
					rig:connect(groudon.Head, groudon.Jaw)
					rig:connect(groudon.Body, groudon.RArm)
					rig:connect(groudon.Body, groudon.LArm)
					rig:connect(groudon.Body, groudon.RLeg)
					rig:connect(groudon.Body, groudon.LLeg)

					local blurPart = create 'Part' {
						Material = Enum.Material.Neon,
						Transparency = 1.0,
						BrickColor = BrickColor.new('Crimson'),
						--					FormFactor = Enum.FormFactor.Custom,
						Size = Vector3.new(20, 20, .2),
						Anchored = true,
						CanCollide = false,
						Parent = workspace,
					}
					local function blur()
						blurPart.CFrame = cam.CoordinateFrame * CFrame.new(0, 0, -1)
					end

					rig:reset()
					local cf = cam.CoordinateFrame
					local st = tick()
					local duration = 8
					Utilities.sound(317440901, .6, nil, 18)
					local sceneMusic = Utilities.sound(12640115508, .3)
					delay(99, function()
						if not sceneMusic then return end
						sceneMusic = Utilities.loopSound(12640116297, .3)
					end)
					while true do
						stepped:wait()
						local et = tick()-st
						if et > duration then break end
						local o = (et%.25)*2
						if o >= .325 then
							o = .5-(o-.325)*4
						elseif o >= .25 then
							o = (o-.25)*4
						elseif o >= .125 then
							o = -.5+(o-.125)*4
						else
							o = o*-4
						end
						local m = 0
						if et < duration-.5 then
							m = math.min(1, math.sin(et/(duration-.5)*math.pi))
						end
						local cf = lerp(et/duration)
						cam.CoordinateFrame = CFrame.new(cf.p, cf.p+cf.lookVector) * CFrame.new(o*m*5, 0, 0)--cf * CFrame.new(o*m*5, 0, 10-10*et/duration)
						blurPart.Transparency = 1-et/duration*.25
						blur()
					end
					cam.CoordinateFrame = camCFrame2
					blur()
					wait(1)

					-- setup initial rig poses
					rig:pose('Groudon', CFrame.new(-826, 42, -747) * CFrame.Angles(0, 1, 0) * CFrame.Angles(-0.6, 0, 0))

					-- animate coming out of lava
					delay(.25, function()
						Tween(.5, nil, function(a)
							local o = 1-a
							local t = math.random()*math.pi*2
							cam.CoordinateFrame = camCFrame2 * CFrame.new(math.cos(t)*o*2.5, math.sin(t)*o*2.5, 0)
							blur()
						end)
					end)
					local cry
					delay(.5, function()
						cry = _p.DataManager:getSprite('_FRONT', 'Groudon').cry
						Sprite:playCry(.5, cry, .5)
						_p.Particles:new {
							N = 20,
							Position = Vector3.new(-836, 62, -757),
							Velocity = Vector3.new(0, 40, 0),
							VelocityVariation = 60,
							Acceleration = Vector3.new(0, -18, 0),
							Size = 2,
							Image = 68068592,
							Color = BrickColor.new('Crimson').Color,
							Lifetime = 8,
						}
					end)
					rig:poses(
						{'Groudon', CFrame.new(-836, 62, -757) * CFrame.Angles(0, 0.7, 0) * CFrame.Angles(0.5, 0, 0), 2, 'easeOutQuad'},
						{'RArm', CFrame.Angles(0, 0, -1) * CFrame.Angles(0, -0.5, 0), 2},
						{'LArm', CFrame.Angles(0, 0, 1) * CFrame.Angles(0, 0.5, 0), 2},
						{'Jaw', CFrame.Angles(0.8, 0, 0), 3, 'easeOutCubic'})

					wait(.7)
					rig:poses({'Groudon', CFrame.new(-846, 72, -767) * CFrame.Angles(0, 0.4, 0), 2, 'easeInOutQuad'},
					{'RArm', CFrame.new(), 1.75, 'easeInOutQuad'},
					{'LArm', CFrame.new(), 1.75, 'easeInOutQuad'},
					{'Jaw', CFrame.Angles(0.3, 0, 0), 1.5})
					rig:poses({'Groudon', CFrame.new(-846, 71.3, -767) * CFrame.Angles(0, 0.4, 0), 1},
					{'RLeg', CFrame.new(0, 0.7, 0), 1},
					{'LLeg', CFrame.new(0, 0.7, 0), 1},
					{'Jaw', CFrame.Angles(0.2, 0, 0), 1})
					local breathe = true
					spawn(function()
						while breathe do
							rig:poses({'Groudon', CFrame.new(-846, 72, -767) * CFrame.Angles(0, 0.2, 0), .75},
							{'RLeg', CFrame.new(), .75},
							{'LLeg', CFrame.new(), .75},
							{'Jaw', CFrame.Angles(0.3, 0, 0), .75})
							if not breathe then break end
							rig:poses({'Groudon', CFrame.new(-846, 71.3, -767) * CFrame.Angles(0, 0.2, 0), 1},
							{'RLeg', CFrame.new(0, 0.7, 0), 1},
							{'LLeg', CFrame.new(0, 0.7, 0), 1},
							{'Jaw', CFrame.Angles(0.2, 0, 0), 1})
						end
					end)
					cam.CoordinateFrame = camCFrame1
					blur()
					spawn(function() _p.MasterControl:LookAt(op) end)
					admin:LookAt(pp)
					chat.bottom = true
					chat:say(admin, 'Groudon, the giant sleeping within this volcano, has now awoken!',
						'With his power, Team Eclipse will more fully be capable of carrying out its purposes!',
						'Fear this mighty Pok[e\']mon, foolish child, as I now manipulate Groudon to do our bidding!')
					local p2 = chunk.npcs.grunt2.model.HumanoidRootPart.Position
					local p3 = chunk.npcs.grunt3.model.HumanoidRootPart.Position
					local ep = p2 + (p3-p2)*1.5--p2 + (p3-p2)/2
					spawn(function() _p.MasterControl:LookAt(gp) end)
					admin:WalkTo(ep)
					admin:LookAt(gp)
					-- load running animations for each NPC in preparation for the getaway
					for _, npc in pairs(eclipse) do
						npc.humanoid.WalkSpeed = 60
						npc.walkAnim = npc.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.Run })
					end
					chat:say(admin, 'Groudon, it was I who woke you from your slumber!',
						'You will now help Team Eclipse fulfill its purpose.',
						'I command you now, Groudon, to follow my exact orders!')
					-- re-rig Groudon from a core position between legs
					local l1 = groudon.RLeg.Hinge.Position
					local l2 = groudon.LLeg.Hinge.Position
					local lm = l1 + (l2-l1)/2
					local f = Vector3.new(groudon.Main.Position.X, lm.Y, groudon.Main.Position.Z)
					local core = CFrame.new(lm, f)
					local hipsModel = create 'Model' {
						Name = 'Hips',
						Parent = groudon,

						create 'Part' {
							Name = 'Main',
							Transparency = 1.0,
							Anchored = true,
							CanCollide = false,
							Size = Vector3.new(1, 1, 1),
							CFrame = core,
						}
					}
					breathe = false
					rig:poses({'Groudon'},{'RLeg'},{'LLeg'},{'Jaw'}) -- cut off threads
					rig:connect(hipsModel, groudon)
					rig.models.Hips.cframe = core
					rig.models.Groudon.cframe = CFrame.new()
					local facing = CFrame.new(core.p, Vector3.new(ep.X, core.Y, ep.Z))
					rig:poses({'Hips', facing * CFrame.Angles(0.3, 0, 0), .5},
					{'RArm', CFrame.Angles(0, 0, 0.3), .5},
					{'LArm', CFrame.Angles(0, 0, -0.3), .5},
					{'RLeg', CFrame.Angles(-0.3, 0, 0), .5},
					{'LLeg', CFrame.Angles(-0.3, 0, 0), .5})
					wait(.2)
					delay(.2, function()
						Tween(1, nil, function(a)
							local o = 1-a
							local t = math.random()*math.pi*2
							cam.CoordinateFrame = camCFrame1 * CFrame.new(math.cos(t)*o*2.5, math.sin(t)*o*2.5, 0)
							blur()
						end)
					end)
					delay(.2, function()
						Sprite:playCry(.5, cry, .8)
					end)
					delay(.3, function()
						local p = create 'Part' {
							Transparency = 1,
							Anchored = true,
							CanCollide = false,
							--						FormFactor = Enum.FormFactor.Custom,

							create 'Decal' {
								Texture = 'rbxassetid://6142896054',
								Face = Enum.NormalId.Back,
							}
						}
						for i = 1, 4 do
							local p = p:Clone()
							p.Parent = groudon
							local cf = groudon.Head.Hinge.CFrame
							Utilities.fastSpawn(function()
								Tween(1, nil, function(a)
									p.Size = Vector3.new(5+a*15, 5+a*15, .2)
									p.CFrame = cf * CFrame.new(0, 0, 8+10*a)
								end)
								p:remove()
							end)
							wait(.2)
						end
					end)
					delay(1.25, function()
						local hair = admin.model.Hair
						hair:BreakJoints()
						create 'BodyAngularVelocity' {
							AngularVelocity = Vector3.new(-20, 0, 0),
							MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
							Parent = hair,
						}
						local dir = (hair.Position-groudon.Head.Hinge.Position+Vector3.new(0, 5, 0)).unit
						create 'BodyVelocity' {
							Velocity = dir*40,
							MaxForce = Vector3.new(math.huge, math.huge, math.huge),
							Parent = hair,
						}
						wait(5)
						hair:remove()
					end)
					rig:poses({'Hips', facing * CFrame.Angles(-0.3, 0, 0), .3},
					{'RArm', CFrame.Angles(0, 0, -0.8), .3},
					{'LArm', CFrame.Angles(0, 0, 0.8), .3},
					{'RLeg', CFrame.Angles(0.3, 0, 0), .3},
					{'LLeg', CFrame.Angles(0.3, 0, 0), .3},
					{'Head', CFrame.Angles(-0.6, 0, 0), .3},
					{'Jaw', CFrame.Angles(0.8, 0, 0), .3})
					wait(2.4)
					breathe = true
					spawn(function()
						rig:poses({'Hips', facing, .6},
						{'RLeg', CFrame.new(), .6},
						{'LLeg', CFrame.new(), .6},
						{'Jaw', CFrame.Angles(0.3, 0, 0), .6},
						{'RArm', CFrame.new(), .6},
						{'LArm', CFrame.new(), .6},
						{'Head', CFrame.new(), .6})
						while breathe do
							rig:poses({'Hips', facing + Vector3.new(0, -.7, 0), 1},
							{'RLeg', CFrame.new(0, 0.7, 0), 1},
							{'LLeg', CFrame.new(0, 0.7, 0), 1},
							{'Jaw', CFrame.Angles(0.2, 0, 0), 1})
							if not breathe then break end
							rig:poses({'Hips', facing, .75},
							{'RLeg', CFrame.new(), .75},
							{'LLeg', CFrame.new(), .75},
							{'Jaw', CFrame.Angles(0.3, 0, 0), .75})
						end
					end)
					chat:say(admin, '...', 'EVERYBODY RUUUUUN!!1!')
					for _, npc in pairs(eclipse) do
						spawn(function()
							npc:WalkTo(Vector3.new(-788, 68, -798))
							npc:WalkTo(Vector3.new(-766, 68, -785))
							npc:remove()
						end)
					end
					delay(4, function()
						for _, npc in pairs(chunk.npcs) do
							pcall(function()
								if npc.model:FindFirstChild('IsTeamEclipse') then
									npc:remove()
								end
							end)
						end
					end)
					wait(1)
					local leader = _p.NPC:PlaceNew('LeaderSebastian', chunk.map, CFrame.new(-777, 72, -791))
					pp = _p.player.Character.HumanoidRootPart.Position
					local lp = Vector3.new(-788, 68, -798)
					leader:WalkTo(lp)
					leader:WalkTo(pp + (lp-pp).unit*5)
					spawn(function() _p.MasterControl:LookAt(lp) end)
					chat:say(leader, 'I have to grab that Red Orb quick, before Groudon gets out of control!')
					spawn(function() _p.MasterControl:LookAt(op) end)
					local wp = pp + Vector3.new(-1, 0, 3)
					leader:WalkTo(wp)
					leader:WalkTo(op + (wp-op).unit*4)
					chunk.map.RedOrb.Transparency = 1
					spawn(function() _p.MasterControl:LookAt(gp) end)
					wait(.5)
					leader:LookAt(gp)
					chat:say(leader, 'Groudon, please forgive us for disturbing your rest.',
						'We promise that we won\'t disturb you again.',
						'There is a village right outside this volcano with a lot of good people in it.',
						'If this volcano erupts, it could remove the entire village and hurt many innocent people.',
						'Please accept this apology and we will be on our way.')
					breathe = false
					delay(.1, function()
						Sprite:playCry(1, cry)
					end)
					rig:poses({'Hips'},{'RLeg'},{'LLeg'},
					{'Head', CFrame.Angles(-0.4, 0, 0), .3},
					{'Jaw', CFrame.Angles(0.6, 0, 0), .3})
					wait(1.2)
					rig:poses({'Hips'},{'RLeg'},{'LLeg'},
					{'Head', CFrame.new(), .3},
					{'Jaw', CFrame.new(), .3})
					wait(.2)
					rig:poses(
						{'Hips', facing * CFrame.new(0, -4, 4), .5},
						{'RLeg', CFrame.new(0, 4, -4), .5},
						{'LLeg', CFrame.new(0, -4, 4), .5})
					wait(.2)
					rig:poses(
						{'Hips', facing * CFrame.new(0, -8, 8), .5},
						{'RLeg', CFrame.new(0, -4, 4), .5},
						{'LLeg', CFrame.new(0, 4, -4), .5})
					wait(.2)
					rig:poses(
						{'Hips', facing * CFrame.new(0, -12, 12), .5},
						{'RLeg', CFrame.new(0, 4, -4), .5},
						{'LLeg', CFrame.new(0, -4, 4), .5})
					wait(.2)
					rig:poses(
						{'Hips', facing * CFrame.new(0, -16, 16), .5},
						{'RLeg', CFrame.new(0, -4, 4), .5},
						{'LLeg', CFrame.new(0, 4, -4), .5})
					wait(.2)
					rig:poses(
						{'Hips', facing * CFrame.new(0, -20, 20), .5},
						{'RLeg', CFrame.new(0, 4, -4), .5},
						{'LLeg', CFrame.new(0, -4, 4), .5})
					wait(.2)
					rig:poses(
						{'Hips', facing * CFrame.new(0, -24, 24), .5},
						{'RLeg', CFrame.new(0, -4, 4), .5},
						{'LLeg', CFrame.new(0, 4, -4), .5})
					wait(1)
					rig:pose('Hips', facing * CFrame.new(0, -36, 24), 1.5)
					wait(1)
					local t = blurPart.Transparency
					local music = sceneMusic
					local volume = music.Volume
					sceneMusic = nil
					Tween(1, nil, function(a)
						blurPart.Transparency = t + (1-t)*a
						music.Volume = volume*(1-a)
					end)
					music:remove()
					blurPart:remove()
					spawn(function() _p.MusicManager:returnFromSilence(1) end)
					spawn(function() Utilities.lookBackAtMe(1, true) end)
					lp = leader.model.HumanoidRootPart.Position
					spawn(function() _p.MasterControl:LookAt(lp) end)
					leader:WalkTo(pp + (lp-pp).unit*5)
					chat.bottom = nil
					chat:say(leader, 'I\'m actually kind of surprised Groudon let us go that easily.',
						'For a second there I thought might\'ve been toast.',
						'Did you see the way Groudon was looking at you, though?',
						'It was as if he saw something in you.',
						'Maybe that\'s why he just left like that.',
						'I have a feeling that we might see Groudon again someday.',
						'Either way, you did a good job showing Team Eclipse who\'s boss.',
						'I can let everyone back in town now that their homes are safe.',
						'Hey, you should stop by my gym.',
						'I\'d love to see first-hand how strong of a trainer you are.',
						'Alright, well I better get going.',
						'I\'ll be seeing you soon, hopefully.')
					leader:WalkTo(wp)
					spawn(function() leader:WalkTo(Vector3.new(-788, 68, -798)) end)
					wait(2)
					leader:remove()

					cam.CameraType = Enum.CameraType.Custom
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
					chat:enable()
				end)
			end
		end,

		onBeforeEnter_Gym2 = function(room)
			_p.DataManager:preload(317011433, 317012607,
				6142910487, 496819113) -- vs text, trainer icon
			_p.MasterControl:SetJumpEnabled(true)
			local m = room.model
			-- lava "killing"
			do
				local chunk = _p.DataManager.currentChunk
				local parts = {}
				local transparencies = {}
				local partsModel = create 'Model' {
					create 'Humanoid' {
						DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None,
						RigType = Utilities.getHumanoid().RigType,
						Health = 0,
					}
				}
				local hidePoint = m.Entrance.CFrame + Vector3.new(0, -20, 10)
				local function indexPart(p)
					if not p then return end
					transparencies[p] = p.Transparency
					local pc
					if p:IsA('MeshPart') then
						pc = p:Clone()
						pc:ClearAllChildren()
						pc:BreakJoints()
					else
						pc = Instance.new('Part')
						pc.Name = p.Name
						pc.Size = p.Size
						pc.BrickColor = p.BrickColor
						pc.Transparency = p.Transparency
						if p:FindFirstChild('Mesh') then
							p.Mesh:Clone().Parent = pc
						end
					end
					pc.Anchored = true
					pc.CFrame = hidePoint
					pc.Parent = partsModel
					parts[p] = pc
				end
				for _, p in pairs(_p.player.Character:GetChildren()) do
					if p:IsA('BasePart') and p.Name ~= 'HumanoidRootPart' then
						indexPart(p)
					elseif p:IsA('Accoutrement') then
						indexPart(p:FindFirstChild('Handle'))
					elseif p:IsA('CharacterAppearance') then
						p:Clone().Parent = partsModel
					end
				end
				local respawnPoint = CFrame.new(m.Entrance.Position + Vector3.new(0, 3, 26)) * CFrame.Angles(0, math.pi, 0)
				--			create 'Part' {
				--				CFrame = respawnPoint,
				--				Anchored = true,
				--				CanCollide = false,
				--				Size = Vector3.new(2, 2, 1),
				--				Parent = workspace
				--			}
				partsModel.Parent = m
				local function lavaTouched(p)
					if not _p.MasterControl.WalkEnabled or not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					local cam = workspace.CurrentCamera
					local head = _p.player.Character.Head
					local sp = head.Position
					local offset = cam.CFrame.p - sp
					chunk.roomCamDisabled = true
					--
					local c_from, c_to = {}, {}
					for p in pairs(parts) do
						c_from[p] = p.CFrame
					end
					Utilities.Teleport(respawnPoint)
					stepped:wait()
					local headPos = head.Position
					for p in pairs(parts) do
						c_to[p] = p.CFrame
					end
					Utilities.TeleportToSpawnBox()
					for p, pc in pairs(parts) do
						pc.Anchored = false
						pc.CanCollide = true
						pc.CFrame = c_from[p]
						--					p.Transparency = 1
					end
					wait(1)
					--				head.Anchored = true
					local cframes = {}
					for p, pc in pairs(parts) do
						pc.Anchored = true
						cframes[pc] = select(2, Utilities.lerpCFrame(pc.CFrame, c_to[p]))--p.CFrame))
					end
					Tween(1, 'easeOutCubic', function(a)
						local p = sp:Lerp(headPos, a)--head.Position, a)
						cam.CoordinateFrame = CFrame.new(p + offset, p)
						for pc, lerp in pairs(cframes) do
							pc.CFrame = lerp(a)
							pc.CanCollide = false
						end
					end)
					--				partsModel.Parent = nil
					for _, pc in pairs(parts) do
						pc.CFrame = hidePoint
					end
					--				for p, t in pairs(transparencies) do
					--					p.Transparency = t
					--				end
					--				head.Anchored = false
					Utilities.Teleport(respawnPoint)
					chunk.roomCamDisabled = false
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
				end
				m.Base.Touched:connect(lavaTouched)
				for _, p in pairs(m.Lava:GetChildren()) do
					p.Touched:connect(lavaTouched)
				end
			end
			-- animate flowing lava
			local flowingLava = {sheets={{id=317011433,rows=6}},nFrames=32,fWidth=160,fHeight=160,framesPerRow=6,speed=.08}
			local lavaFallAnimation = _p.AnimatedSprite:new(flowingLava)
			lavaFallAnimation.spriteLabel.ImageColor3 = Color3.new(1, .6, .6)
			lavaFallAnimation.spriteLabel.ImageTransparency = .2
			lavaFallAnimation.spriteLabel.Rotation = 180
			lavaFallAnimation.spriteLabel.Parent = create 'SurfaceGui' {
				CanvasSize = Vector2.new(160, 160),
				Face = Enum.NormalId.Left,
				Adornee = m.Lavafall,
				Parent = m.Lavafall,
			}
			lavaFallAnimation:Play()
			local boilingLava = {sheets={{id=317012607,rows=6}},nFrames=32,fWidth=160,fHeight=160,framesPerRow=6,speed=.075}
			local lavaFloorAnimation = _p.AnimatedSprite:new(boilingLava)
			lavaFloorAnimation.spriteLabel.ImageColor3 = Color3.new(1, .6, .6)
			lavaFloorAnimation.spriteLabel.ImageTransparency = .5
			lavaFloorAnimation.spriteLabel.Parent = create 'SurfaceGui' {
				CanvasSize = Vector2.new(160, 160),
				Face = Enum.NormalId.Top,
				Adornee = m.Base,
				Parent = m.Base,
			}
			lavaFloorAnimation:Play()
			m.AncestryChanged:connect(function()
				if not m.Parent then
					--				print('cleaning up gym')
					lavaFallAnimation:remove()
					lavaFloorAnimation:remove()
				end
			end)
			-- leader
			local leader = room.npcs.Leader
			local postWinInteract = function()
				if _p.PlayerData.badges[8] then
					if completedEvents.SebastianRebattle then
						chat:say(leader, 'That was an excellent battle, I wish you the best of luck on your next adventures.')
					else
						local c = chat:say(leader, 
							'Eyy, looks like you have all eight gym badges correct?',
							'[y/n]This calls for a celebration, let\'s have a rematch if you want?'
						)
						if c then
							local win = _p.Battle:doTrainerBattle {
								battleSceneType = 'Gym2',
								musicId = 12639907402,
								PreventMoveAfter = true,
								vs = {name = 'Sebastian', id = 496819113, hue = 0.015, sat = .8, val = .7},
								trainerModel = leader.model,
								num = 231
							}
							if win then
								print("Sebastian Rebattle event complete?", _p.PlayerData.completedEvents.SebastianRebattle)

								chat:say(leader, 
									'Hey, ' .. _p.PlayerData.trainerName .. '!')
								Utilities.exclaim(_p.player.Character.Head)
								spawn(function()
									_p.MasterControl:LookAt(leader.model.HumanoidRootPart.Position)
								end)
								chat:say(leader, 
									'Remember the orb that Team Eclipse tried stealing to summon Groudon?',
									'It has always been the duty of this gym to protect this orb within the Volcano.',
									'You have proven to me that you are indeed a strong and worthy trainer.',
									'I want you to have this.')

								onObtainItemSound()
								chat:say('Obtained the Red Orb!', _p.PlayerData.trainerName .. ' put the Red Orb in the Bag.')
								chat:say(leader, 						
									'You may be capable of defeating and maybe even capturing Groudon yourself!',
									'I trust you with this orb because you\'re an incredibly powerful trainer and even I can feel the purity inside of you whenever you battle.',
									'I appreciate you coming back and visiting me.', 'That was an excellent battle, I wish you the best of luck on your next adventures.')
							end
						else
							chat:say(leader, 'Hmm, maybe some other time then.')
						end
						_p.Menu:enable()
					end
				else			
					chat:say(leader,
						'If you enjoyed the obstacles in this gym, you should check out my other worlds.',
						'Yeeeaaaaaaah.')
				end
			end
			if _p.PlayerData.badges[2] then
				interact[leader.model] = postWinInteract
			else
				interact[leader.model] = function()
					chat:say(leader, 'Hello again.',
						'As you know, I am Sebastian, the leader of the Brimber City Gym.',
						'I\'m grateful for your assistance earlier with Groudon.',
						'I think everyone in town is.',
						'Now, show me the power of your Pok[e\']mon!')
					local win = _p.Battle:doTrainerBattle {
						battleSceneType = 'Gym2',
						musicId = 12639907402,
						PreventMoveAfter = true,
						vs = {name = 'Sebastian', id = 496819113, hue = 0.015, sat = .5, val = .7},
						trainerModel = leader.model,
						num = 112
					}
					if win then
						chat:say(leader, 'I wasn\'t wrong when I said that Groudon saw something in you!',
							'I am proud to present you with Brimber City\'s Gym Badge.')

						local badge = m.Badge2:Clone()
						local cfs = {}
						local main = badge.SpinCenter
						for _, p in pairs(badge:GetChildren()) do
							if p:IsA('BasePart') and p ~= main then
								cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
							end
						end
						badge.Parent = workspace
						local st = tick()
						local spinRate = 1
						local function cframeTo(rcf)
							local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi/2, 0, (tick()-st)*spinRate + math.pi/2)
							main.CFrame = cf
							for p, ocf in pairs(cfs) do
								p.CFrame = cf:toWorldSpace(ocf)
							end
						end
						local r = 8
						local f = CFrame.new(0, 0, -6)
						Tween(1, nil, function(a)
							local t = a*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						local spin = true
						Utilities.fastSpawn(function()
							while spin do
								cframeTo(f)
								stepped:wait()
							end
						end)
						wait(2)
						Utilities.sound(12639886125, nil, nil, 10)
						chat:say('Obtained the Brimstone Badge!')
						spin = false
						Tween(.5, nil, function(a)
							local t = (1-a)*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						badge:remove()

						chat:say(leader, 'The Brimstone Badge allows you to trade for Pok[e\']mon up to level 40.',
							'It\'s the least I can do to give you this TM as well.')
						Utilities.sound(288899943, nil, nil, 10)
						chat:say('Obtained a TM50!',
							_p.PlayerData.trainerName .. ' put the TM50 in the Bag.')
						chat:say(leader, 'TM50 contains Overheat.',
							'Overheat is a Fire-type move that\'s extremely powerful, however is harshly reduces your Pok[e\']mon\'s Special Attack after use.',
							'Good luck with the rest of your adventure.',
							'I believe you will do many great things.')
						local chunk = _p.DataManager.currentChunk
						pcall(function() chunk.map.ConstructionWorker:remove() end)
						pcall(function() chunk.map.ConstructionWall:remove() end)
						chunk:getDoor('Gate6').disabled = nil
						interact[leader.model] = postWinInteract
					end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					chat:enable()
					_p.Menu:enable()
				end
			end
		end,

		-- Act 2.5
		onLoad_chunk8 = function(chunk)
			local function turnWheel()
				local st = tick()
				local model = chunk.map
				local wheel = model.WaterWheel.Wheel
				local main = wheel.Main
				local mcf = main.CFrame
				local cfs = {}
				for _, p in pairs(wheel:GetChildren()) do
					if p:IsA('BasePart') and p ~= main then
						cfs[p] = mcf:toObjectSpace(p.CFrame)
					end
				end
				while model.Parent do
					stepped:wait()
					local et = tick()-st
					local cf = mcf * CFrame.Angles(0, et*.3, 0)
					main.CFrame = cf
					for p, rcf in pairs(cfs) do
						p.CFrame = cf:toWorldSpace(rcf)
					end
				end
			end
			local bidoofObserverNoDamInteract = {'The dam the Bidoofs built is gone now.',
				'Somebody must have taught those lumberjacks a lesson!'}
			if completedEvents.DamBusted then
				interact[chunk.npcs.BidoofObserver.model] = bidoofObserverNoDamInteract
				chunk.map.DamStuff:remove()
				spawn(turnWheel)
			else
				interact[chunk.npcs.BidoofObserver.model] = {'Those lazy lumberjacks...',
					'They let their Bidoofs out again, and this time they\'ve gone and made a dam.',
					'Now it\'s impossible to get over to Lagoona Lake.',
					'Somebody needs to go have a talk with those lumberjacks.',
					'I\'m going to call their boss right now...'}
				local nw = chunk.map.Water
				nw.Parent = nil
				local sig = Utilities.Signal()
				sceneSignal = sig
				sig:connect(function()
					if nw.Parent then return end
					nw.Parent = chunk.map
					interact[chunk.npcs.BidoofObserver.model] = bidoofObserverNoDamInteract
					chunk.map.DamStuff:remove()
					spawn(turnWheel)
				end)
			end
		end,

		onBeforeEnter_SawMill = function(room)
			if not completedEvents.DamBusted then
				room.npcs.Defaultio.model.Parent = nil
			else
				interact[room.npcs.Defaultio.model] = {'You must have been pretty tough to beat my workers like that.',
					'Come back when you have all eight Gym Badges and I\'ll have a battle with you.'}
			end
		end,
		
--[[
-- activate this when celebi is done
		onBeforeEnter_SawMill = function(room)
			if not completedEvents.DamBusted then
				room.npcs.Defaultio.model.Parent = nil
			else
				if _p.PlayerData.badges[7] then
					if not completedEvents.getGSBall then
						interact[room.npcs.Defaultio.model] = function()
							room.npcs.Defaultio:Say('Well, look who\'s back.', 'Our trainer friend from before.', 'I do apologize again for the trouble my workers caused you.', 'I see you now have Roria\'s eight gym badges.', 'That must make you a very strong trainer, right?', 'I happen to be a trainer myself.', 'Would you be interested in having battle?')
							if room.npcs.Defaultio:Say('[y/n]If you win, I\'ll let you have something I found recently while I was out.') then
								room.npcs.Defaultio:Say('Awesome, I can tell this is going to be a good battle.')
								local win = _p.Battle:doTrainerBattle {
									battleSceneType = 'SawMill',
									PreventMoveAfter = true,
									trainerModel = room.npcs.Defaultio.model,
									num = 232
								}
								if win then
									_p.PlayerData:completeEvent('getGSBall')
									room.npcs.Defaultio:Say('You and your Pokemon did an excellent job in that battle.', 'My Pokemon and I battle trainers so that we can be stronger as a team, and ultimately become better wood cutters.', 'Anyways, I made a promise that I would share something with you.', 'This is something I\'ve come to call the GS Ball.', 'I found it when I was cutting trees on Route 9.', 'I don\'t know what its purpose is, but it looks very nice.', 'I want you to take it as a gift.')
									spawn(function() onObtainKeyItemSound() end)
									chat:say('Obtained the GS Ball!', _p.PlayerData.trainerName .. ' put the GS Ball in the Bag.')
									room.npcs.Defaultio:Say('Now, if you don\'t mind, I need to get these workers back in shape.')
									_p.Menu:enable()
									interact[room.npcs.Defaultio.model] = {'Now, if you don\'t mind, I need to get these workers back in shape.'}
								end
								_p.MasterControl.WalkEnabled = true
								chat:enable()
								_p.Menu:enable()
							end
						end
					else
						interact[room.npcs.Defaultio.model] = {'Now, if you don\'t mind, I need to get these workers back in shape.'}
					end
				else
					interact[room.npcs.Defaultio.model] = {'You must have been pretty tough to beat my workers like that.',
						'Come back when you have all eight Gym Badges and I\'ll have a battle with you.'}
				end
			end
		end,

--]]

		onBeatLumberjack = function()
			sceneSignal:fire() -- remove bidoofs, start wheel
			local chunk = _p.DataManager.currentChunk
			local room = chunk:topRoom()
			local lumberjack = room.npcs['Lumberjack Paul']
			if not lumberjack then
				for name, npc in pairs(room.npcs) do
					--				print(name)
					if npc.model:FindFirstChild('MainLumberjack') then
						lumberjack = npc
						break
					end
				end
			end
			lumberjack:Say('I really don\'t feel like going out and rounding up the Bidoofs.',
				'It\'s too much work.')
			local defaultio = room.npcs.Defaultio
			defaultio:Teleport(room.model.Base.CFrame * CFrame.new(9, 4, -7))
			defaultio.model.Parent = room.model
			local dp = (room.model.Base.CFrame * CFrame.new(-18.5, 4, -7)).p
			defaultio:WalkTo(dp)
			defaultio:LookAt(lumberjack.model.HumanoidRootPart.Position)
			defaultio:Say('What\'s going on in here?!')
			lumberjack:Say('Oh no, it\'s the boss...')
			spawn(function() lumberjack:LookAt(dp) end)
			spawn(function()
				_p.MasterControl:WalkTo(lumberjack.model.HumanoidRootPart.Position + Vector3.new(0, 0, -4.5))
				_p.MasterControl:LookAt(dp)
			end)
			defaultio:Say('I just saw your Bidoofs outside causing all sorts of shenanigans.',
				'The gate to Lagoona Lake was flooded over by the water displacement.',
				'I had to break down the dam with my Pok[e\']mon.')
			lumberjack:Say('We\'re sorry, boss.', 'We just wanted to take a little break and have some fun.')
			defaultio:Say('I don\'t mind you guys taking breaks, but you can\'t just let the Bidoofs get out of hand like this.')
			lumberjack:Say('We won\'t let it happen again, we promise.')
			defaultio:Say('No, you won\'t.', 'I\'m sticking around to keep an eye on you guys.')
			lumberjack:Say('Ugh...')
		end,

		onLoad_chunk9 = function(chunk)
			_p.Events.onExit_Gate8 = nil
			local dcm = chunk.npcs.DayCareMan
			local originalDirection = dcm.model.Head.CFrame.lookVector
			if _p.PlayerData.daycareManHasEgg then
				spawn(function()
					dcm:Look(Vector3.new(1, 0, 1).unit)
				end)
			end
			interact[dcm.model] = function()
				if _p.PlayerData.daycareManHasEgg then
					local want = dcm:Say('Oh hey, just the person I wanted to see!',
						'When we were raising your Pok[e\']mon, something amazing happened!',
						'It somehow ended up holding an Egg!',
						'I\'m not quite sure where it came from...',
						'[y/n][ma]But you want it, right?')
					if want then
						local state, done
						Utilities.fastSpawn(function()
							state = _p.Network:get('PDS', 'takeEgg')
							done = true
						end)
						while not done do wait() end
						if not state then -- indicates inconsistent state; recover as much as possible
							dcm:Say('That\'s strange.', 'I don\'t seem to have an Egg.',
								'Maybe I imagined the whole thing...')
							_p.PlayerData.daycareManHasEgg = false
							spawn(function() dcm:Look(originalDirection) end)
							return
						elseif state == 'full' then
							dcm:Say('Oops, looks like you\'ve got a full team already.',
								'You don\'t have any space for this Egg...',
								'Why don\'t you deposit one of your Pok[e\']mon in the PC to make space?')
							return
						end
						wait()
						chat.bottom = true
						chat:say(_p.PlayerData.trainerName .. ' received the Egg from the Day Care Man.')
						chat.bottom = nil
						wait()
						_p.PlayerData.daycareManHasEgg = false
						dcm:Say('There you go.', 'Take good care of it!')
					else
						local manKeep = dcm:Say('Oh...', 'Well, I\'d be happy to keep it for you.',
							'[y/n]Would you like me to keep the Egg?')
						if manKeep then
							spawn(function() _p.Network:post('PDS', 'keepEgg') end)
							dcm:Say('Alright, then.', 'I\'ll keep it.', 'Thanks!')
							_p.PlayerData.daycareManHasEgg = false
							spawn(function() dcm:Look(originalDirection) end)
						else
							dcm:Say('Come back whenever you\'d like to pick up the Egg.')
						end
					end
				else
					local phrase
					Utilities.fastSpawn(function() phrase = _p.Network:get('PDS', 'getDCPhrase') end)
					dcm:Say('Hey there!')
					while not phrase do wait() end
					if type(phrase) == 'table' then
						dcm:Say('Your ' .. phrase[1] .. ' and ' .. phrase[2] .. ' are doing just fine.',
							({'The two seem to get along very well!',
								'The two seem to get along.',
								'The two don\'t really seem to like each other very much.',
								'The two prefer to play with other Pok[e\']mon more than with each other.'})[phrase[3] ])
					elseif type(phrase) == 'string' then
						dcm:Say('Your ' .. phrase .. ' is doing just fine.',
							'Talk to my wife if you\'d like to pick it up or leave another Pok[e\']mon.')
					else
						dcm:Say('My wife and I look after Pok[e\']mon here at our Day Care.',
							'If you\'d like us to help you raise a Pok[e\']mon, talk to my wife inside.')
					end
				end
			end
		end,

		onBeforeEnter_DayCare = function(room)
			local eg = room.npcs.EggGift
			interact[eg.model] = function()
				if completedEvents.ReceivedBWEgg then
					eg:Say('Pok[e\']mon eggs are so mysterious, aren\'t they?',
						'I understand that they come from leaving two Pok[e\']mon at the day care, but determining what kind of Pok[e\']mon comes from them is always a mystery.')
				else
					eg:Say('I usually leave my Pok[e\']mon here at the day care while I go to work during the day.',
						'Just recently I\'ve received two different eggs from the day care man.',
						'I have a white egg and a black egg.',
						'I can\'t keep them both so I was wondering if you would like one?')
					eg:Say('Here, I\'ll even let you pick which one you\'d like.')
					local choice = chat:choose('Black', 'White')
					local s = _p.PlayerData:completeEvent('ReceivedBWEgg', choice)
					if s then
						eg:Say('Take care of that egg for me, okay?')
					else
						eg:Say('You don\'t have any room in your team to put this egg.', 'Come back when you\'ve made room.')
					end
				end
			end
			local dcl = room.npcs.DayCareLady
			dcl.humanoid.WalkSpeed = 10
			local dclp = dcl.model.HumanoidRootPart.Position
			--
			local hinge = room.model.BackDoor.Hinge
			local hcf = hinge.CFrame
			local mm = Utilities.MoveModel
			local function walkOutside()
				delay(.2, function()
					Tween(.5, 'easeOutCubic', function(a)
						mm(hinge, hcf * CFrame.Angles(0, a*1.5, 0))
					end)
				end)
				dcl:WalkTo(dclp+Vector3.new(-10, 0, 0))
			end
			local function walkInside()
				delay(.6, function()
					Tween(.5, 'easeOutCubic', function(a)
						mm(hinge, hcf * CFrame.Angles(0, (1-a)*1.5, 0))
					end)
				end)
				dcl:WalkTo(dclp)
				dcl:LookAt(_p.player.Character.HumanoidRootPart.Position)
			end
			--
			interact[dcl.model] = function()
				if _p.PlayerData.daycareManHasEgg then
					dcl:Say('My husband was looking for you.', 'He\'s right outside, please go see him.')
					return
				end
				spawn(function() _p.Menu:disable() end)
				local dc
				Utilities.fastSpawn(function() dc = _p.Network:get('PDS', 'getDCInfo') end)
				dcl:Say('Welcome to the Pok[e\']mon Day Care.', 'We\'re happy to help raise your Pok[e\']mon!',
					'How can we help you today?')
				while not dc do wait() end
				local dp = dc.p
				local option
				if #dp == 0 then
					option = chat:choose('Leave Pok[e\']mon', 'Cancel')
					if option == 2 then option = 3 end
				elseif #dp == 1 then
					option = chat:choose('Leave Pok[e\']mon', 'Take back', 'Cancel')
				else--if #dp == 2 then
					option = chat:choose('Take back', 'Cancel') + 1
				end
				if option == 1 then
					dcl:Say('Which Pok[e\']mon should we raise for you?')
					local slot = _p.BattleGui:choosePokemon('Leave')
					if slot then
						local r = _p.Network:get('PDS', 'leaveDCPokemon', slot)
						if r == 'eg' then
							dcl:Say('I\'m sorry, we can\'t raise an Egg for you.',
								'Come back if you want us to help raise one of your Pok[e\']mon.')
							spawn(function() _p.Menu:enable() end)
							return
						elseif r == 'oh' then
							dcl:Say('I\'m sorry, but I can\'t take your only healthy Pok[e\']mon.',
								'Come back if you want us to help raise one of your Pok[e\']mon.')
							spawn(function() _p.Menu:enable() end)
							return
						elseif r then
							dcl:Say('Got it! We\'ll raise your ' .. r .. ' for a while.',
								'You can come pick it up any time!')
						end
					else
						dcl:Say('Come again!')
					end
				elseif option == 2 then
					dcl:Say('We\'ve had a great time with your Pok[e\']mon!')
					local ps = {'Cancel'}
					for i, p in pairs(dp) do
						table.insert(ps, i, p.name .. ' ' .. (p.gen and ('['..p.gen..'] ') or '') .. 'Lv. ' .. p.lvl)
					end
					local pChoice = chat:choose(unpack(ps))
					local poke = dp[pChoice]
					if poke then
						local growth = poke.inc
						if growth > 0 then
							local take = dcl:Say('Your ' .. poke.name .. ' has grown ' .. growth .. ' levels during its stay with us.')
						end
						local price = 100 + 100*growth
						_p.PlayerData.money = dc.m -- update the cached money amount
						-- show money on-screen
						local take = dcl:Say('[y/n]If you\'d like to take your ' .. poke.name .. ' back now, it\'s going to cost [$]' .. Utilities.comma_value(price) .. '. Is that OK?')
						if take then
							if _p.PlayerData.money < price then
								if dcl:Say('I\'m sorry, you don\'t have enough [$]...', '[y/n]Would you like to buy [$] with ROBUX?') then
									_p.Menu.shop:buyMoney()
									if _p.PlayerData.money < price then -- OVH  TODO: send update to client when purchase is completed
										dcl:Say('Save up some more [$] then come see me.')
										spawn(function() _p.Menu:enable() end)
										return
									end
									if not dcl:Say('[y/n]Okay, so if you\'d like to take your ' .. poke.name .. ' back now, it\'s going to cost [$]' .. Utilities.comma_value(price) .. '. Is that still OK?') then
										spawn(function() _p.Menu:enable() end)
										return
									end
								else
									dcl:Say('Save up some more [$] then come see me.')
									spawn(function() _p.Menu:enable() end)
									return
								end
							end
							if dc.f then
								dcl:Say('I can\'t return your Pok[e\']mon to you, your team is full.',
									'You could drop a Pok[e\']mon off in a PC Box to make space.')
								spawn(function() _p.Menu:enable() end)
								return
							end

							local done = false
							Utilities.fastSpawn(function()
								_p.Network:get('PDS', 'takeDCPokemon', pChoice)
								done = true
							end)
							--	walkOutside()
							--	local st = tick()
							--	while not done do wait() end
							--	local et = tick()-st
							--	if et < 1 then wait(1-et) end
							--	walkInside()

							chat.bottom = true
							chat:say(_p.PlayerData.trainerName .. ' took ' .. poke.name .. ' back from the Pok[e\']mon Day Care.')
							chat.bottom = nil
							--Would you like your other Pok[e\']mon back, too?
							dcl:Say('Thanks, come again!')
						else
							dcl:Say('Alright, come again!')
						end
					else
						dcl:Say('Come again!')
					end
				else
					dcl:Say('Come again!')
				end
				spawn(function() _p.Menu:enable() end)
			end
		end,

		onBeforeEnter_DomeLab = function(room)
			_p.DataManager:preloadModule('Mining')
			do
				-- Fossils / Fossil Eggs
				local fr = room.npcs.FossilReviver
				local machine = room.model.Machine
				interact[fr.model] = function()
					local hasFossil, hasFossilEgg, done
					Utilities.fastSpawn(function()
						hasFossil, hasFossilEgg = _p.Network:get('PDS', 'hasFossil')
						done = true
					end)
					fr:Say('If you happen to find a fossil in the lake, you can bring it to me and I will revive it with this machine.')
					while not done do wait() end

					local function chooseReviveFossil()
						local fossilId = _p.Menu.bag:chooseItem()
						local result
						if fossilId then
							done = false
							Utilities.fastSpawn(function()
								result = _p.Network:get('PDS', 'reviveFossil', fossilId)
								done = true
							end)
						end
						wait(.6)
						while not done do wait() end
--[[					if #_p.PlayerData.party == 6 and not _p.PlayerData.pc:hasSpace() then  -- todo?
				fr:Say('Hold on now, you don\'t have any space to store this Pok[e\']mon if I were to revive it...',
					'Make some space, then come back and see me.')
			else]]if result then
							local fossilName = result[1]
							if fr:Say('[y/n]So, you want to try reviving the ' .. fossilName .. '?') then
								fr:Say('Alright, let me see it.')
								local nn
								done = false
								Utilities.fastSpawn(function()
									nn = _p.Network:get('PDS', 'makeDecision', result[3], true)
									done = true
								end)
								fr:Look(Vector3.new(-1, 0, 0))
								machine.Fossil.Transparency = 0
								machine.ParticlePlate.Particles.Enabled = true
								wait(2.5)
								machine.ParticlePlate.Particles.Enabled = false
								wait(1)
								machine.Fossil.Transparency = 1
								fr:LookAt(_p.player.Character.HumanoidRootPart.Position)
								local pokemonName = result[2]
								fr:Say('Would you look at that!', 'Your ' .. fossilName .. ' turned into ' .. Utilities.aOrAn(pokemonName) .. '!')
								local nickname
								if chat:say('[y/n]Would you like to give a nickname to ' .. pokemonName .. '?') then
									nickname = _p.Pokemon:giveNickname(nn[1], nn[2])
								end
								local msg = _p.Network:get('PDS', 'makeDecision', nn[3], nickname)
								if type(msg) == 'string' then
									chat:say(msg)
								elseif msg then
									fr:Say('Here you go.')
								end
								fr:Say('If you ever have more fossils to revive, come back and see me.')
							else
								if result and result[3] then spawn(function() _p.Network:get('PDS', 'makeDecision', result[3], false) end) end
								fr:Say('Well, if you decide to revive any fossils, come back and see me.')
							end
						else
							fr:Say('Well, if you decide to revive any fossils, come back and see me.')
						end
					end
					local function chooseReviveFossilEgg()
						local slot = _p.BattleGui:choosePokemon('Revive')
						if slot and _p.Network:get('PDS', 'reviveFossil', slot) then
							fr:Say('Alright, let me see it.')
							fr:Look(Vector3.new(-1, 0, 0))
							machine.Fossil.Transparency = 0
							machine.Egg.Transparency = 0
							machine.ParticlePlate.Particles.Enabled = true
							wait(2.5)
							machine.ParticlePlate.Particles.Enabled = false
							wait(1)
							machine.Fossil.Transparency = 1
							machine.Egg.Transparency = 1
							fr:LookAt(_p.player.Character.HumanoidRootPart.Position)
							fr:Say('Wow, your egg looks good as new!',
								'I wonder what will hatch from it...')
						else
							fr:Say('Well, if you decide to revive any fossils, come back and see me.')
						end
					end
					if hasFossil and hasFossilEgg then
						spawn(function() _p.Menu:disable() end)
						fr:Say('Which kind of fossil should I revive?')
						local c = chat:choose('Fossil', 'Egg', 'Cancel')
						if c == 1 then
							fr:Say('Which fossil should I revive?')
							chooseReviveFossil()
						elseif c == 2 then
							fr:Say('Which fossilized egg should I revive?')
							chooseReviveFossilEgg()
						elseif c == 3 then
							fr:Say('Well, if you decide to revive any fossils, come back and see me.')
						end
						spawn(function() _p.Menu:enable() end)
					elseif hasFossil then
						spawn(function() _p.Menu:disable() end)
						fr:Say('Oh, I see you have fossils!', 'Which fossil should I revive?')
						chooseReviveFossil()
						spawn(function() _p.Menu:enable() end)
					elseif hasFossilEgg then
						spawn(function() _p.Menu:disable() end)
						fr:Say('Oh, I see you have fossilized eggs!', 'Which fossilized egg should I revive?')
						chooseReviveFossilEgg()
						spawn(function() _p.Menu:enable() end)
					end
				end
			end
			-- UW Mining
			local sg = room.npcs.SubmarineGuide
			local function rideUMV(firstTime)
				local fd
				if firstTime then
					Utilities.fastSpawn(function() fd = _p.PlayerData:completeEvent('TestDriveUMV') end)
				else
					Utilities.fastSpawn(function() fd = _p.Network:get('PDS', 'dive') end)
				end
				local c = Utilities.FadeOutWithCircle(.9, true)
				local lighting = game:GetService('Lighting')
				local color = Color3.new(78/255, 133/255, 191/255)
				lighting.Ambient = color
				lighting.OutdoorAmbient = color
				lighting.FogColor = Color3.new(78/400, 133/400, 191/400)
				lighting.FogStart = 0
				lighting.FogEnd = 100
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				Utilities.TeleportToSpawnBox()
				_p.DataManager.currentChunk:remove()
				_p.MasterControl:SetIndoors(false)
				local newChunk = _p.DataManager:loadMap('mining')
				local MineSystem = _p.DataManager:loadModule('Mining')
				local cn; cn = MineSystem.Done:connect(function(c)
					cn:disconnect()
					lighting.Ambient = Color3.new(.31, .31, .31)
					lighting.OutdoorAmbient = Color3.new(.5, .5, .5)
					lighting.FogEnd = 1e5
					Utilities.TeleportToSpawnBox()
					newChunk:remove()
					local chunk = _p.DataManager:loadMap('chunk9')
					chunk.indoors = true
					local door = chunk:getDoor('DomeLab')
					local room = chunk:getRoom('DomeLab', door, 1)
					_p.Events.onBeforeEnter_DomeLab(room)
					chunk.roomStack = {room}
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					chunk:bindIndoorCam()
					Utilities.Teleport(room.model.Base.CFrame * CFrame.new(18, 10.5, 0) * CFrame.Angles(0, -math.pi/2, 0))
					Utilities.FadeInWithCircle(.9, c)
					_p.MasterControl:SetIndoors(true)
					--				_p.MusicManager:popMusic('all')
					_p.DataManager.ignoreRegionChangeFlag = true
					chunk:checkRegion(door.Position)
					stepped:wait()
					_p.MusicManager:prepareToStack(0)
					spawn(function() _p.Menu:enable() end)
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.MusicManager:fadeToVolume('top', 0.3, 0)
				end)
				while not fd do wait() end
				MineSystem:Enable(fd)
				Utilities.Teleport(newChunk.map.SpawnPosition.CFrame)
				wait(.2)
				Utilities.FadeInWithCircle(.9, c)
			end
			-- Mining Employee (Buy/Dive)
			local function buyOrDive()
				spawn(function() _p.Menu:disable() end)
				sg:Say('Hello again.', 'Would you like to take another dive in the UMV, or buy more batteries?')
				local MineSystem = _p.DataManager:loadModule('Mining')
				local function countBatteries()
					return _p.Network:get('PDS', 'countBatteries')
				end
				local choice = MineSystem:Menu(countBatteries())
				if choice == 'dive' then
					if countBatteries() <= 0 then
						sg:Say('You don\'t have any UMV Batteries...')
					else
						if sg:Say('You must save before diving.', '[y/n]Would you like to save the game?') then
							if _p.Menu:saveGame() then
								rideUMV()
								return -- to prevent menu from appearing underwater
							else
								sg:Say('Well that\'s odd...', 'I guess you\'ll have to try again in a minute or two...')
							end
						else
							sg:Say('Have a nice day!')
						end
					end
				elseif choice == 'buy' then
					MineSystem:BuyBatteries()
				else
					sg:Say('Have a nice day!')
				end
				_p.Menu:enable()
			end
			local function saidNo()
				spawn(function() _p.Menu:disable() end)
				if sg:Say('[y/n]Now, would you like to go ahead and ride the UMV for your first time?') then
					if sg:Say('You must save before diving.', '[y/n]Would you like to save the game?') then
						interact[sg.model] = buyOrDive
						if _p.Menu:saveGame() then
							rideUMV(true)
							return
						else
							sg:Say('Well that\'s odd...', 'I guess you\'ll have to try again in a minute or two...')
							interact[sg.model] = saidNo
						end
					else
						sg:Say('Come back any time, your first ride is free!')
					end
				else
					sg:Say('Come back any time, your first ride is free!')
				end
				_p.Menu:enable()
			end
			if not completedEvents.IntroToUMV then
				interact[sg.model] = function()
					spawn(function() _p.Menu:disable() end)
					sg:Say('Welcome to the Lagoona Lake laboratory.',
						'Here we explore and study the bottom of the lake and what\'s been left behind by nature.',
						'Using this submersible, known as the Underwater Mining Vessel, we have sent many people deep below the surface in search of whatever they may find within the lake\'s trenches.',
						'The UMV is electric, powered by special batteries.',
						'You will need to purchase your own batteries to power the UMV if you wish to go on a dive yourself.',
						'However, we do have enough funding that we can send you down once for free.',
						'Once below the surface, you may search the walls in the trenches for shiny spots indicating hidden objects.',
						'Simply '..(Utilities.isTouchDevice() and 'tap' or 'click')..' on a shiny spot to begin mining.',
						'The UMV is equipped with explosive charges and a drill.',
						'The explosives will break away the rock quickly, but the drill is much more careful and precise.',
						'The reason I mention this is because with each atempt to break away the rock, the walls will become more fragile.',
						'Eventually they will cave in and anything you fail to dig up will be lost.',
						'After you are done or run out of battery power you will be returned to the lab.',
						'You may keep anything that you find.')
					_p.PlayerData:completeEvent('IntroToUMV')
					interact[sg.model] = saidNo
					saidNo()
				end
			elseif not completedEvents.TestDriveUMV then
				interact[sg.model] = saidNo
			else
				interact[sg.model] = buyOrDive
			end
		end,

		onBeforeEnter_OldRodHouse = function(room)
			local fisher = room.npcs.OldRodGiver
			interact[fisher.model] = function() -- OVH  TODO old rod owned used as flag; create pseudo-event
				if completedEvents.GetOldRod then
					fisher:Say('My fishing streak is 51 consecutive encounters.')
				else
					fisher:Say('Back in my day, I used to enter a lot of fishing competitions.',
						'My highest streak of reeling in Pok[e\']mon consecutively was 51.',
						'I love fishing so much that I moved out here next to the lake.',
						'I don\'t fish very much nowadays.',
						'Hey, I know!',
						'I could share one of my older rods with you.',
						'Here, take this.')
					onObtainKeyItemSound()
					chat:say('Obtained the Old Rod!', _p.PlayerData.trainerName .. ' put the Old Rod in the Bag.')
					_p.PlayerData:completeEvent('GetOldRod')
					fisher:Say('To use the Old Rod, just go near water and ' .. (Utilities.isTouchDevice() and 'tap' or 'click') .. ' on the surface.',
						'Select the Old Rod, then wait until you get a bite.',
						'Then just ' .. (Utilities.isTouchDevice() and 'tap' or 'click') .. ' quickly to reel it in.',
						'If you don\'t do it fast enough, the Pok[e\']mon could get away.',
						'Good luck, and happy fishing!')
				end
			end
		end,

		-- Act III
		onLoad_chunk10 = function(chunk)
			_p.PlayerData.hasOddKeystone = _p.Network:get('PDS', 'hasOKS')
			local jake = chunk.npcs.Jake
			local function connectJakeStopTrigger()
				touchEvent('JakeEndFollow', chunk.map.JakeStopTrigger, true, function()
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					local jp = jake.model.HumanoidRootPart.Position
					local pp = _p.player.Character.HumanoidRootPart.Position
					spawn(function() _p.MasterControl:LookAt(jp) end)
					spawn(function() jake:LookAt(pp) end)
					jake:Say('Hey '.._p.PlayerData.trainerName..', that was really fun.',
						'I learned a lot from how you battle.',
						'I\'m so excited to use what I\'ve learned now!',
						'There\'s a gym ahead in the next city.',
						'I can use the skill you\'ve taught me there and earn another Gym Badge!',
						'I\'ll see you there, '.._p.PlayerData.trainerName..'.')
					jake:StopFollowingPlayer()
					_p.Battle.npcPartner = nil
					local door = chunk:getDoor('Gate9')
					wait()
					local p1 = pp + Vector3.new(4, 0, 0)
					local p2 = pp + Vector3.new(-4, 0, 0)
					if (jp-p1).magnitude+(p1-door.Position).magnitude < (jp-p2).magnitude+(p2-door.Position).magnitude then
						jake:WalkTo(p1)
					else
						jake:WalkTo(p2)
					end
					jake:WalkTo(door.Position + Vector3.new(0, 0, 2))
					door:open(.5)
					delay(.5, function()
						door:close(.5)
					end)
					jake:WalkTo(door.Position + Vector3.new(0, 0, -15))
					jake:remove()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
				end)
			end
			if completedEvents.JakeEndFollow then
				jake:remove()
			elseif completedEvents.JakeStartFollow then
				jake:Teleport(CFrame.new(chunk:getDoor('Gate8').Position + Vector3.new(-6, 0, -6))*CFrame.Angles(0,math.pi,0))
				delay(1, function()
					repeat wait() until _p.MasterControl.WalkEnabled
					jake:StartFollowingPlayer()
					_p.Battle.npcPartner = 'jakeChunk10'
				end)
				connectJakeStopTrigger()
			else
				touchEvent('JakeStartFollow', chunk.map.JakeFollowTrigger, true, function()
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					local pp = _p.player.Character.HumanoidRootPart.Position
					Utilities.Sync {
						function() Utilities.exclaim(jake.model.Head) end,
						function() jake:LookAt(pp) end,
					}
					local jp = jake.model.HumanoidRootPart.Position
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:WalkTo(pp + (jp-pp).unit*4)
					jake:Say('Oh hey, ' .. _p.PlayerData.trainerName .. '!',
						'Looks like you\'ve finally caught up with me.',
						'You took on Team Eclipse all by yourself.',
						'That was pretty brave of you.',
						'I\'ve got to be honest, that whole time I was just waiting at the gym for Sebastian to get back so I could be the first person to get the Brimstone Badge.',
						'I was honestly too scared to go challenge Team Eclipse.',
						'But you\'ve proven to me that we really are capable of doing great things with the help of our Pok[e\']mon.',
						'I really admire your strength and determination.',
						'The way you\'re training your Pok[e\']mon...',
						'You should have your parents back in no time!',
						'I just know you will.')
					spawn(function() Utilities.exclaim(jake.model.Head) end)
					jake:Say('I know!',
						'You can show me how you train your Pok[e\']mon!',
						'Let\'s tackle the trainers on this route together!',
						'You take the lead.',
						'I\'ve got tons of Potions and stuff, if your Pok[e\']mon get hurt in battle I\'ll heal them afterwards.')
					jake:StartFollowingPlayer()
					_p.Battle.npcPartner = 'jakeChunk10'
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					connectJakeStopTrigger()
				end)
			end
			local claus = chunk.npcs.MrsClaus
			interact[claus.model] = 'We grow trees here and sell them around Christmas each year.' --function()
			--			if completedEvents.GivenSnover then
			--				claus:Say('Thank you for helping us cut down the Christmas trees for that big order.',
			--					'It really helped us out when we were in a pinch!')
			--			else
			--				claus:Say('Oh no, I don\'t know what to do...',
			--					'Those lazy lumberjacks were supposed to show up days ago to cut down these Christmas trees.',
			--					'We have a large order for the holidays, and I don\'t know what we\'re going to do.',
			--					'I can\'t cut down all these trees myself, and my husband is too old.')
			--			end
			--		end
		end,

		onDoorFocused_Gate8 = function()
			if _p.DataManager.currentChunk.id ~= 'chunk10' then return end
			if completedEvents.JakeEndFollow or not completedEvents.JakeStartFollow then return end
			pcall(function()
				local jake = _p.DataManager.currentChunk.npcs.Jake
				jake:Say('Oh okay, I\'ll just wait for you here.')
				jake:StopFollowingPlayer()
				_p.Battle.npcPartner = nil

				delay(2, function()
					jake:Teleport(CFrame.new(_p.DataManager.currentChunk:getDoor('Gate8').Position + Vector3.new(-6, 0, -6))*CFrame.Angles(0,math.pi,0))
				end)

				_p.Events.onExit_Gate8 = function()
					_p.Events.onExit_Gate8 = nil
					jake:StartFollowingPlayer()
					_p.Battle.npcPartner = 'jakeChunk10'
				end
			end)
		end,

		onBeforeEnter_Kresmas = function(room)
			--		local encryptedId = rc4('hotchocolate')
			local hcman = room.npcs.HCMan
			interact[hcman.model] = {'During the holidays, we enjoy selling Hot Chocolate here.',
				'I really do enjoy the holiday season...'} --function()
			--			if hcman:Say('Hi, we sell Hot Chocolate here during the holidays.',
			--				'They\'re [$]350 each.',
			--				'[y/n]Would you like to buy some?') then
			--				local currentQty = 0
			--				local bd = _p.PlayerData:getBagDataById(encryptedId)
			--				if bd then
			--					currentQty = bd.quantity or 0
			--				end
			--				if currentQty >= 99 then
			--					hcman:Say('You don\'t have any more room in your bag for this item.')
			--					return
			--				end
			--				if _p.PlayerData.money < 350 then -- NOT UPDATED TO NEW MONEY SYSTEM
			--					hcman:Say('You don\'t have enough money.')
			--					return
			--				end
			--				local maxQty = math.min(99-currentQty, math.floor(_p.PlayerData.money/350))
			--				local qty = _p.Menu.bag:selectQuantity(maxQty, _p.Menu.bag:getItemIcon({name='Hot Chocolate',num=641}), 'How many would you like?', '[$]%d', 350)
			--				if qty then
			--					_p.PlayerData:addBagItems({id = encryptedId, quantity = qty})
			--					_p.PlayerData.money = _p.PlayerData.money - qty*350
			--				end
			--			end
			--			hcman:Say('Thank you, please come again!')
			--		end
			--		local tree = room.model['Christmas Tree']
			--		spawn(function()
			--			local lights = tree.Lights:GetChildren()
			--			while tree.Parent and wait(1) do
			--				for _,v in pairs(lights) do
			--					if v:IsA("BasePart") then
			--						if v.BrickColor == BrickColor.new("Really red") then v.BrickColor = BrickColor.new("New Yeller")
			--						elseif v.BrickColor == BrickColor.new("New Yeller") then v.BrickColor = BrickColor.new("Really blue")
			--						elseif v.BrickColor == BrickColor.new("Really blue") then v.BrickColor = BrickColor.new("Really red")
			--						end
			--					end
			--				end
			--			end
			--		end)
			--		spawn(function()
			--			local main = tree.Train.Center
			--			local mcf = main.CFrame
			--			local cfs = {}
			--			for _, p in pairs(tree.Train:GetChildren()) do
			--				if p:IsA('BasePart') and p ~= main then
			--					cfs[p] = mcf:toObjectSpace(p.CFrame)
			--				end
			--			end
			--			local st = tick()
			--			while tree.Parent do
			--				stepped:wait()
			--				local et = tick()-st
			--				local cf = mcf * CFrame.Angles(0, et, 0)
			--				for p, rcf in pairs(cfs) do
			--					p.CFrame = cf:toWorldSpace(rcf)
			--				end
			--			end
			--		end)
		end,

		--	onCutAllChristmasTrees = function()
		--		if completedEvents.GivenSnover then return end
		--		local claus; pcall(function() claus = _p.DataManager.currentChunk.npcs.MrsClaus end)
		--		if not claus then return end
		--		local cp = claus.model.HumanoidRootPart.Position
		--		local pp = _p.player.Character.HumanoidRootPart.Position
		--		claus:WalkTo(cp + Vector3.new(-3, 0, 0))
		--		claus:WalkTo(pp + (cp-pp).unit*5)
		--		spawn(function() MasterControl:LookAt(claus.model.HumanoidRootPart.Position) end)
		--		claus:LookAt(pp)
		--		claus:Say('Oh my goodness, did you really just cut down all the trees by yourself?',
		--			'I can\'t believe it, you have no idea how much you just helped us.',
		--			'We needed those Christmas trees cut down for a huge order.',
		--			'Now we\'ll be able to deliver those trees in time.',
		--			'How could I ever repay you?')
		--		spawn(function() Utilities.exclaim(claus.model.Head) end)
		--		claus:Say('Oh, I know!',
		--			'Just as you started cutting down those trees, this little Pok[e\']mon ran out of the tree lot.',
		--			'I suppose he didn\'t want to get mistaken for a tree and get cut.',
		--			'It looks like it could use a nice trainer.',
		--			'Here, I want you to take it with you, we can\'t keep it here anyways.')
		--		Utilities.sound(304774035, nil, nil, 8)
		--		chat:say('Obtained Snover!')
		--		local snover = _p.Pokemon:new {
		--			name = rc4(Snover),
		--			level = 15,
		--			shiny = true,
		--			item = abomasite,
		--		}
		--		if chat:say('[y/n]Would you like to give Snover a nickname?') then
		--			snover:giveNickname()
		--		end
		--		completedEvents.GivenSnover = true
		--		local msg = _p.PlayerData:caughtPokemon(snover)
		--		if msg then
		--			chat:say(msg)
		--		end
		--	end,

		onLoad_chunk11 = function(chunk)
			
			----goodrodevent----
			local defaultio = chunk.npcs.nointeractyet
			interact[defaultio.model] = function()
				if completedEvents.GetGoodRod then
					defaultio:Say('Fishing with the Good Rod will allow you to catch some Pok[e\']mon that are only obtainable with it.')
				else
					_p.PlayerData:completeEvent('GetGoodRod')
					chat:say(defaultio, 'What am I doing out here, you say?',
						'Well, this is where all the good fish are.',
						'I happen to catch some of the most amazing Pok[e\']mon in this spot.',
						'But that isn\'t all.',
						'I also have a pretty good fishing rod.',
						'I\'ve come to call it the "Good Rod" because that\'s just what it is.',
						'Anyway, a trainer like you could use a good rod, just like mine.',
						'Here, take this extra rod I brought along. I don\'t mind.')
					onObtainItemSound()
					chat:say('Obtained the Good Rod!', _p.PlayerData.trainerName .. ' put the Good Rod in the Bag.')
					chat:say(defaultio, 'You\'ll find higher-level Pok[e\']mon than with an Old Rod.',
						'There are even some Pok[e\']mon you can catch only with a Good Rod.')
				end
			end
			-- preload manaphy egg sound
			_p.DataManager:preload(409175253)
			-- special beach encounters
			local beachEncounter = chunk.data.regions['Rosecove Beach'].MiscEncounter
			local function waveTouched(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				local root; pcall(function() root = _p.player.Character.HumanoidRootPart end)
				if not root or math.random(7) ~= 5 or root.Velocity.magnitude < .5 or not _p.MasterControl.WalkEnabled then return end
				_p.Battle:doWildBattle(beachEncounter)
			end
			spawn(function()
				-- waves
				local cfs = {}
				local waves = chunk.map.Waves
				for _, wave in pairs(waves:GetChildren()) do
					cfs[wave] = wave.CFrame
					wave.Touched:connect(waveTouched)
				end
				local st = tick()
				st = st - (st%(2*math.pi/0.85))
				while waves.Parent do
					stepped:wait()
					local et = (tick()-st)*0.85
					for wave, cf in pairs(cfs) do
						wave.CFrame = cf * CFrame.new(math.sin(et)*14, -1+math.sin(et), 0)-- * CFrame.Angles(0, 0, math.cos(et)*0.05)
					end
				end
			end)
			-- setup King's Rock giver
			local krg = chunk.npcs.KingsRockGiver
			interact[krg.model] = function()
				if not completedEvents.KingsRockGiven then
					spawn(function() _p.PlayerData:completeEvent('KingsRockGiven') end)
					krg:Say('Good job beating the 5 trainers I hired to test the strength of all who make their way to Rosecove.',
						'Not everyone makes it this far.',
						'And for that, I reward you with this special prize.')
					onObtainItemSound()
					chat:say('Obtained a King\'s Rock!', _p.PlayerData.trainerName .. ' put the King\'s Rock in the Bag.')
				end
				krg:Say('The King\'s Rock is a symbol of strength.',
					'It has interesting and hidden properties that are not fully understood.',
					'It\'s been known to trigger evolution in a few Pok[e\']mon.',
					'Maybe you can unlock its hidden abilities.')
			end
			for _, door in pairs(chunk.doors) do
				if door.id == 'Gym3' or door.id == 'Gate10' then
					door.disabled = true
				end
			end
			-- Jake and Tess at gate
			if completedEvents.JakeAndTessDepart then
				chunk.npcs.Jake:remove()
				chunk.npcs.Tess:remove()
				chunk:getDoor('Gate10').disabled = false
			else
				local cn; cn = chunk.map.JTDepartTrigger.Touched:connect(function(p)
					if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
					if not completedEvents.LighthouseScene or not _p.PlayerData.badges[3] then return end
					cn:disconnect()
					if completedEvents.JakeAndTessDepart then return end
					spawn(function() _p.PlayerData:completeEvent('JakeAndTessDepart') end) -- this is fine because cn is disconnected
					spawn(function() _p.Menu:disable() end)
					_p.MasterControl.WalkEnabled = false
					local jake = chunk.npcs.Jake
					local tess = chunk.npcs.Tess
					local jp = jake.model.HumanoidRootPart.Position
					local tp = tess.model.HumanoidRootPart.Position
					local pp = (jp+tp)/2 + Vector3.new(-5, 0, 0)
					_p.MasterControl:WalkTo(pp)
					spawn(function() tess:LookAt(pp) end)
					local myName = _p.PlayerData.trainerName
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('Oh look, '..myName..' is here now.',
						'How was the gym?',
						'Water-type Pok[e\']mon are okay, but my ideal Pok[e\']mon type is Dragon.',
						'I would go fight the Gym Leader but I\'m more interested in adventure than I am in earning badges.')
					spawn(function() tess:LookAt(jp) end)
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:Say('Heh, yeah me too.')
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('Don\'t you already have a couple badges, Jake?')
					spawn(function() jake:LookAt(pp) end)
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:Say('Ummm, so who\'s ready to move on now?',
						'There is still so much to see, and we still haven\'t found '..myName..'\'s parents.')
					spawn(function() tess:LookAt(pp) end)
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('Oh yes, Jake was just telling me about your situation, '..myName..'.',
						'That is just plain awful.',
						'I promise to help you in any way I can.')
					spawn(function() jake:LookAt(tp) end)
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:Say('You are so nice and beautiful, Tess.')
					spawn(function() tess:LookAt(jp) end)
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('I\'m what?')
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:Say('Oh uh...',
						'I said you\'re so bored waiting around here.',
						'Let\'s go on ahead.')
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('Oh yeah, let\'s go.')
					spawn(function() tess:LookAt(pp) end)
					tess:Say('We\'ll see you on the other side of the gate, '..myName..'.',
						'Come on through when you are ready.')
					local door = chunk:getDoor('Gate10')
					spawn(function() _p.MasterControl:LookAt(door.Position) end)
					spawn(function() jake:LookAt(door.Position) end)
					tess:WalkTo(door.Position + Vector3.new(-2, 0, 0))
					door:open(.5)
					spawn(function()
						jake:WalkTo(door.Position)
						delay(.5, function()
							door:close(.5)
							wait(1)
							door.disabled = nil
							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()
							_p.Menu:enable()
						end)
						jake:WalkTo(door.Position + Vector3.new(8, 0, 0))
						jake:remove()
					end)
					spawn(function()
						tess:WalkTo(door.Position + Vector3.new(10, 0, 0))
						tess:remove()
					end)
				end)
			end
			-- Lighthouse Cutscene
			local function clearCutsceneCharacters()
				for _, door in pairs(chunk.doors) do
					if door.id == 'Gym3' then
						door.disabled = nil
					end
				end
				pcall(function() chunk.npcs.CutsceneGrunt:remove() end)
				pcall(function() chunk.npcs.EclipseBlock1:remove() end)
				pcall(function() chunk.npcs.EclipseBlock2:remove() end)
				for name, npc in pairs(chunk.npcs) do
					if name:sub(1, 4) == 'LHC_' or name:find('Eclipse Grunt') then
						npc:remove()
					end
				end
			end
			local function setupJakeAndTessAfterLighthouseCutscene()
				local gate = chunk:getDoor('Gate10')
				local gcp = gate.Position + Vector3.new(-5, -gate.Size.Y/2+3.2, -4)
				local jcp = gcp + Vector3.new(0, 0, 8)
				local jake, tess = chunk.npcs.Jake, chunk.npcs.Tess
				interact[jake.model] = {'Haha, you\'re so funny Tess.',
					'Oh hey '.._p.PlayerData.trainerName..', don\'t you still need to get that badge or something?'}
				interact[tess.model] = {'Oh good it\'s you.',
					'Does Jake always talk a lot?',
					'Up at my grandpa\'s he hardly talked, but now I can\'t get him to shut up.',
					'He also said he single-handedly took on Team Eclipse at Mt. Igneus and saved Brimber City.',
					'You two are quite the heroes.'}
				jake:Teleport(CFrame.new(jcp, gcp))
				tess:Teleport(CFrame.new(gcp, jcp))
			end
			if completedEvents.LighthouseScene then
				if not completedEvents.JakeAndTessDepart then
					setupJakeAndTessAfterLighthouseCutscene()
				end
				clearCutsceneCharacters()
			else
				local orb = chunk.map.BlueOrb
				local orbCF = orb.CFrame
				local connectLighthouseScene

				local man = chunk.npcs.LHC_Grandpa
				local admin = chunk.npcs.LHC_Admin
				local girl = chunk.npcs.Tess
				local grunt = chunk.npcs.LHC_Grunt2
				local grunt2 = chunk.npcs.LHC_Grunt1
				local mp = man.model.HumanoidRootPart.Position
				local ap = admin.model.HumanoidRootPart.Position
				local gp = girl.model.HumanoidRootPart.Position
				local grp = grunt.model.HumanoidRootPart.Position
				local grp2 = grunt2.model.HumanoidRootPart.Position

				local function resetScene() -- we do not reload chunk on blackout; need to call this if we blackout mid-cutscene
					orb.CFrame = orbCF
					man:Teleport(CFrame.new(mp, ap))
					girl:Teleport(CFrame.new(gp, ap))
					admin:Teleport(CFrame.new(ap, mp))
					grunt:Teleport(CFrame.new(grp, mp))
					grunt2:Teleport(CFrame.new(grp2, mp))
					--
					connectLighthouseScene()
				end
				connectLighthouseScene = function()
					local lhtrigger = chunk.map.LighthouseCutsceneTrigger
					touchEvent('LighthouseScene', lhtrigger, false, function()
						_p.MasterControl.WalkEnabled = false
						spawn(function() _p.Menu:disable() end)

						_p.DataManager:queueSpritesToCache({'_FRONT', 'Kyogre'}) -- for the cry
						_p.DataManager:preload(337448917, 243728104, 337594642, 337448867, 337973384, 317480860, 338262406)
						_p.DataManager:preloadModule('AnchoredRig')
						--					_p.DataManager:preloadModule('Rain')

						local pp = lhtrigger.Position + Vector3.new(-9, 0, 0)
						spawn(function() _p.MasterControl:WalkTo(pp) end)

						local cam = workspace.CurrentCamera
						cam.CameraType = Enum.CameraType.Scriptable
						local camP = ap + (mp-ap)/3.5 + Vector3.new(0, 1.1, 2).unit*18.5
						local camF = mp + (ap-mp)/2
						local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, CFrame.new(camP, camF)))
						Tween(2, 'easeOutCubic', function(a)
							cam.CoordinateFrame = lerp(a)
							cam:SetRoll(0)
						end)

						admin:Say('I wont say this again, old man - hand over the orb!')
						man:Say('You can\'t have it!',
							'This is too dangerous in the wrong hands.',
							'And in case you are confused, your hands are the wrong hands.',
							'Do you even know what this orb can do?')
						admin:Say('Yes I know.',
							'We have a pair of archeological experts that tell us that the orb can be used to summon a powerful Pok[e\']mon.',
							'Powerful enough to create the seas!')
						man:Say('And what makes you think you could control such a beast?')
						admin:Say('We\'re Team Eclipse, you old fool!',
							'We can do anything we want.',
							'We are the most powerful organization on the planet!',
							'And right now, the only thing standing in our way is a feeble old man.')
						man:Say('Well I\'d say if you\'re having trouble enough with me, there\'s no way you are as powerful of a group as you claim.')
						admin:Say('THAT\'S IT! I\'VE HAD ENOUGH!')

						girl:LookAt(mp)
						spawn(function() man:LookAt(gp) end)
						girl:Say('Grandpa, please let me fight these men.',
							'My Pok[e\']mon are strong enough! I can do this!')
						man:Say('No Tess, it\'s not safe.',
							'You shouldn\'t be out here.',
							'Please run inside and lock the door behind you.')
						girl:Say('But grandpa...')
						man:Say('Go now, I can\'t let anything happen to you.')
						local door = chunk:getDoor('lighthouse')
						girl:WalkTo(door.Position + Vector3.new(2, 0, 0))
						spawn(function() door:open(.5) end)
						girl:WalkTo(door.Position + Vector3.new(-3, 0, 0))
						door:close(.5)
						man:LookAt(ap)
						admin:Say('It was smart of you to send away your granddaughter.',
							'She would have been crushed by our Pok[e\']mon.')
						man:Say('You leave her alone.',
							'This fight is between us.')
						admin:Say('Yes, and it ends now.',
							'Take the orb from him!')
						grunt:Say('Yes, sir.')
						spawn(function() man:LookAt(grp) end)
						grunt:WalkTo(mp + (grp-mp).unit*3.5)
						orb.CFrame = orbCF - orbCF.p + mp + Vector3.new(0, -2.5, 0)
						Tween(.5, 'easeOutCubic', function(a)
							local p = mp - (grp-mp).unit*2*a
							man.model.HumanoidRootPart.CFrame = CFrame.new(p, grp)
							man.position.Position = p
						end)
						wait(.4)
						grunt:WalkTo(mp)
						orb.CFrame = orbCF
						wait(.1)
						delay(.3, function() man:WalkTo(mp) end)
						grunt:WalkTo(ap + (mp-ap).unit*4)
						wait(.5)
						spawn(function()
							grunt:WalkTo(grunt.model.HumanoidRootPart.Position + Vector3.new(0, 0, 1.5))
							grunt:WalkTo(grp)
							grunt:LookAt(mp)
						end)
						spawn(function() man:LookAt(ap) end)
						admin:Say('We finally have what we need to call on the legendary Pok[e\']mon of the sea now!',
							'The boss is going to give me a huge raise for this.',
							'Well thank you, we\'ll be leaving now.')
						spawn(function() grunt:LookAt(pp) end)
						spawn(function() grunt2:LookAt(pp) end)
						spawn(function()
							local camP = cam.CoordinateFrame.p
							local camF = ap + (pp-ap)/3
							local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, CFrame.new(camP, camF)))
							Tween(1, 'easeOutCubic', function(a)
								cam.CoordinateFrame = lerp(a)
								cam:SetRoll(0)
							end)
						end)
						admin:WalkTo(ap + (pp-ap).unit*6)
						spawn(function() admin:LookAt(pp) end)
						Utilities.exclaim(admin.model.TopHat)--.Head)
						wait(.1)
						admin:Say('Oh, who\'s this?',
							'Are you here to try and stop us too?',
							'Heh, I\'m afraid you\'re a little late.',
							'We have what we have come for.',
							'Our plan is one step closer to being completed.',
							'Now if you\'ll just excuse us, we\'ll be on our way.',
							'What\'s this? You wont let us pass without a fight?',
							'Well if a fight is what you want, a fight is what you\'ll get.',
							'Alright boys, you\'re up.')
						spawn(function() _p.MasterControl:LookAt(grp) end)
						grunt:WalkTo(pp + (grp-pp).unit*4)
						grunt:Say('The trail ends here for you.')
						local win = _p.Battle:doTrainerBattle {
							IconId = 5226446131,
							musicId = {9536676199, 12639990881},
							musicVolume = 2,
							PreventMoveAfter = true,
							LeaveCameraScriptable = true,
							trainerModel = grunt.model,
							num = 69
						} 
						if not win then
							resetScene()
							chat:enable()
							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()
							return
						end
						grunt:WalkTo(grp)
						spawn(function() grunt:LookAt(pp) end)
						spawn(function() _p.MasterControl:LookAt(grp2) end)
						grunt2:WalkTo(pp + (grp2-pp).unit*4)
						grunt2:Say('You\'re lucky to have made it this far.')
						local win = _p.Battle:doTrainerBattle {
							IconId = 5226446131,
							musicId = {9536676199, 12639990881},
							musicVolume = 2,
							PreventMoveAfter = true,
							LeaveCameraScriptable = true,
							trainerModel = grunt2.model,
							num = 70
						}
						if not win then
							resetScene()
							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()
							return
						end
						grunt2:WalkTo(grp2)
						spawn(function() _p.MasterControl:LookAt(ap) end)
						grunt2:LookAt(pp)
						admin:Say('Ugh, if you want the job done right, you gotta do it yourself...',
							'I\'m not going to let you ruin our plan like some kid did back in the volcano.',
							'Because of that kid interfering with my brother\'s efforts to capture Groudon, I was trusted by the boss to come here and secure the Blue Orb.',
							'I musn\'t let my boss down.',
							'Prepare now for your defeat.')
						local win = _p.Battle:doTrainerBattle {
							IconId = 5226446131,
							musicId = {12640050794, 12640051993},
							PreventMoveAfter = true,
							LeaveCameraScriptable = true,
							trainerModel = admin.model,
							num = 71
						}
						if not win then
							resetScene()
							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()
							return
						end
						local kyogre = _p.DataManager:request({'Model', 'Kyogre'})
						_p.DataManager:preload(337448917, 243728104, 337594642, 337448867, 337973384, 317480860, 338262406)
						admin:Say('No, this can\'t happen again.',
							'Team Eclipse cannot continue to be frustrated like this!')
						spawn(function() admin:LookAt(grp) end)
						grunt:Say('Wait, I thought I might\'ve recognized you.',
							'You\'re that kid that messed up the volcano job, too.')
						admin:Say('Oh really?')
						spawn(function() admin:LookAt(pp) end)
						admin:Say('So you make it your business to ruin our plans, do you?',
							'You should really be careful.',
							'We do not deal lightly with repeat offenders.',
							'I\'ll make sure that you are paid another visit by some very strong Team Eclipse members.',
							'Anyways, it\'s clear that we\'ve been beaten here.',
							'I can see by that look on your face that you don\'t plan on letting us get away with the Blue Orb.',
							'Well - in that case - if I can\'t have it, nobody can.')
						local dir = Vector3.new(0, 0, 1)
						local nap = grp + Vector3.new(-5, 0, 0)
						Utilities.Sync {
							function()
								local camP = pp + Vector3.new(1, 0.5, 3).unit * 50
								local camF = mp + Vector3.new(4, -15, 0)
								local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, CFrame.new(camP, camF)))
								Tween(1, 'easeOutCubic', function(a)
									cam.CoordinateFrame = lerp(a)
									cam:SetRoll(0)
								end)
							end,
							function() grunt:Look(dir) end,
							function()
								admin:WalkTo(nap)
								admin:Look(dir)
							end,
							function()
								grunt2:WalkTo(grp + Vector3.new(5, 0, 0))
								grunt2:Look(dir)
							end,
							function() man:LookAt(nap) end,
							function() _p.MasterControl:LookAt(nap) end,
						}
						wait()
						local adminIdle = admin.humanoid:GetPlayingAnimationTracks()[1]
						adminIdle:Stop(0)
						wait()
						local rs = admin.model.Torso['Right Shoulder']
						local rarm = admin.model['Right Arm']
						rs.MaxVelocity = .5
						local da = 3
						rs.DesiredAngle = da
						local orb2 = orb:Clone()
						orb2.Parent = workspace
						repeat
							stepped:wait()
							orb2.CFrame = rarm.CFrame * CFrame.new(0, -1, 0)
						until math.abs(rs.CurrentAngle-da) < .05
						da = math.pi*2/3
						rs.DesiredAngle = da
						repeat
							stepped:wait()
							orb2.CFrame = rarm.CFrame * CFrame.new(0, -1, 0)
						until math.abs(rs.CurrentAngle-da) < .05
						rs.MaxVelocity = .1
						adminIdle:Play()
						local cf = orb2.CFrame
						local vi = Vector3.new(0, -2, 3).unit*40
						local a = Vector3.new(0, -196.2, 0)
						local planeY = 87
						local st = tick()
						repeat
							stepped:wait()
							local t = tick()-st
							orb2.CFrame = cf + vi*t + .5*a*t^2
						until orb2.Position.Y < planeY
						orb2.CFrame = orb2.CFrame + Vector3.new(0, -5, 0)
						Utilities.sound(337448917, 1, nil, 5)

						local pos = Vector3.new(orb2.Position.X, planeY, orb2.Position.Z)
						for i = 1, 12 do
							_p.Particles:new {
								Position = pos,
								Velocity = Vector3.new(0, 10, 0),
								VelocityVariation = 30,
								Acceleration = Vector3.new(0, -18, 0),
								Size = 1.5,
								Image = 243728104,
								Color = BrickColor.new('Navy blue').Color,
								Lifetime = 3,
							}
						end
						spawn(function() _p.MusicManager:prepareToStack(1) end)
						man:Say('NO! Do you have any idea what you\'ve just done?',
							'You\'ve summoned the beast!')

						-- cutscene
						local atmosphere
						spawn(function()
							atmosphere = create 'Part' {
								--							FormFactor = Enum.FormFactor.Symmetric,
								Size = Vector3.new(4, 4, 4),
								Anchored = true,
								CFrame = CFrame.new(-1412, -140, -2264),
								BrickColor = BrickColor.new('Storm blue'),
								Parent = workspace,

								create 'SpecialMesh' {
									MeshType = Enum.MeshType.Head,
									Scale = Vector3.new(-300, -300, -300),
								}
							}
							Tween(3, nil, function(a)
								atmosphere.Transparency = 1-a
							end)
						end)
						local lighting = game:GetService('Lighting')
						lighting.FogColor = Color3.new(54/255, 64/255, 83/255)
						lighting.FogStart = 0
						lighting.FogEnd = 400
						local sceneStart = tick()
						local sceneMusic = Utilities.sound(337594642, .75)--, 35)
						local function flash()
							local blurPart = create 'Part' {
								Material = Enum.Material.Neon,
								BrickColor = BrickColor.new('White'),
								--							FormFactor = Enum.FormFactor.Custom,
								Size = Vector3.new(20, 20, .2),
								Anchored = true,
								CanCollide = false,
								Parent = workspace,
							}
							Tween(.1, nil, function(a)
								blurPart.CFrame = cam.CoordinateFrame * CFrame.new(0, 0, -1)
								blurPart.Transparency = 1-.25*a
								local b = .5+.5*a
								lighting.OutdoorAmbient = Color3.new(b, b, b)
							end)
							Tween(.6, nil, function(a)
								blurPart.CFrame = cam.CoordinateFrame * CFrame.new(0, 0, -1)
								blurPart.Transparency = .75+.25*a
								local b = 1-.5*a
								lighting.OutdoorAmbient = Color3.new(b, b, b)
							end)
							blurPart:remove()
						end
						delay(4.898, flash)
						delay(19.627, flash)
						delay(35.760, flash)

						delay(91, function()
							if not sceneMusic then return end
							sceneMusic = Utilities.loopSound(92193581859009, 1)
						end)
						local rain
						delay(1, function()
							rain = --[[_p.DataManager:loadModule('Rain')]] _p.Rain:start(create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(1.0, 0, 1.0, 36),
								Position = UDim2.new(0.0, 0, 0.0, -36),
								Parent = Utilities.gui,
							})
							Tween(5, nil, function(a)
								rain:setTransparency(1.1-a)
							end)
						end)
						delay(.3, function()
							local p = create 'Part' {
								Transparency = 1,
								Anchored = true,
								CanCollide = false,
								--							FormFactor = Enum.FormFactor.Custom,

								create 'Decal' {
									Texture = 'rbxassetid://6142896054',
									Face = Enum.NormalId.Top,
								}
							}
							for i = 1, 3 do
								local p = p:Clone()
								p.Parent = workspace
								local cf = CFrame.new(orb2.Position.X, 87.2, orb2.Position.Z)
								Utilities.fastSpawn(function()
									Tween(1, nil, function(a)
										p.Size = Vector3.new(a*550, .2, a*550)
										p.CFrame = cf
										if a > .8 then
											p.Decal.Transparency = (a-.8)*5
										end
									end)
									p:remove()
								end)
								wait(.3)
							end
						end)
						kyogre.Parent = workspace
						wait(5.9)
						Utilities.fadeGui.ZIndex = 10
						Utilities.FadeOut(1, Color3.new(0, 0, 0))
						spawn(function() Utilities.FadeIn(1) end)
						delay(8, function() Utilities.FadeOut(1) end)
						local camCF = CFrame.new(-1087.75769, 150.418915, -2129.27148, 0.430999517, 0.457167804, -0.777969778, 1.49011612e-08, 0.862157583, 0.506640136, 0.902352154, .218361676, 0.371589512)--CFrame.new(-1061.09802, 161.858078, -2157.72754, 0.327669561, 0.683905602, -0.651848018, -0, 0.68993783, 0.723868668, 0.94479239, -0.237189725, 0.226071626)
						Tween(9, nil, function(a)
							cam.CoordinateFrame = camCF + Vector3.new(0, 0, 40*a)
						end)
						spawn(function() Utilities.FadeIn(1) end)
						delay(8, function() Utilities.FadeOut(1) end)
						camCF = CFrame.new(-1225.76978, 120.718094, -2016.38342, 0.204576582, 0.432986856, -0.877878726, -0, 0.896846592, 0.442342103, 0.978850663, -0.0904928371, 0.183473781)
						Tween(9, nil, function(a)
							cam.CoordinateFrame = camCF + Vector3.new(0, 0, -20-40*a)
						end)
						spawn(function() Utilities.FadeIn(1) end)
						local camLerp = select(2, Utilities.lerpCFrame(
							CFrame.new(-1201.38721, 136.98761, -2329.47388, -0.297642022, -0.145087212, 0.943588316, 3.7252903e-09, 0.988384306, 0.151975095, -0.954677522, 0.0452341773, -0.294184715) * CFrame.new(0, 0, -10),
							CFrame.new(-1336.0885, 157.496597, -2341.01709, -0.883104861, -0.227327734, 0.410424024, -1.49011612e-08, 0.874776959, 0.48452583, -0.469175637, 0.427887112, -0.772519767)))
						local angleTimer = Utilities.Timing.easeInCubic(1)
						Tween(12, nil, function(a)
							cam.CoordinateFrame = camLerp(a, angleTimer(a)) + Vector3.new(0, 0, -25*math.sin(a*math.pi))
							cam:SetRoll(0)
						end)

						-- 36.9 jumps out water
						-- 42.2 lands back in water

						local rig = _p.DataManager:loadModule('AnchoredRig'):new(kyogre)
						rig:connect(kyogre, kyogre.Body)
						rig:connect(kyogre.Body, kyogre.LowerJaw)
						rig:connect(kyogre.Body, kyogre.RightArm)
						rig:connect(kyogre.Body, kyogre.LeftArm)
						wait(36.9-(tick()-sceneStart))

						local ri = Vector3.new(-1589, 74.5, -2253)
						local vi = Vector3.new(math.sqrt(3)/2, 1/2, 0)

						local apex = Vector3.new(-1472, 124, -2253)

						delay(.15, function()
							local pos = kyogre.Main.CFrame * Vector3.new(0, 0, -20)
							for i = 1, 30 do
								_p.Particles:new {
									Position = pos + Vector3.new(-10+math.random()*20, 0, -10+math.random()*20),
									Velocity = Vector3.new(1, 3, 0).unit*30,
									VelocityVariation = 30,
									Acceleration = Vector3.new(0, -25, 0),
									Size = 5,
									Image = 243728104,
									Color = BrickColor.new('Navy blue').Color,
									Lifetime = 3,
								}
							end
						end)

						local dur = 42.2-36.9
						local halfPi = math.pi/2
						delay(dur, function()
							local pos = kyogre.Main.CFrame * Vector3.new(0, 0, -20)
							for i = 1, 30 do
								_p.Particles:new {
									Position = pos + Vector3.new(-10+math.random()*20, 0, -10+math.random()*20),
									Velocity = Vector3.new(1, 2, 0).unit*30,
									VelocityVariation = 30,
									Acceleration = Vector3.new(0, -25, 0),
									Size = 5,
									Image = 243728104,
									Color = BrickColor.new('Navy blue').Color,
									Lifetime = 3,
								}
							end
						end)
						local timer = Utilities.Timing.cubicBezier(1, .4,.9,.6,.1)
						Tween(dur+.7, nil, function(a)
							a = timer(a)*2
							if a < 1 then
								local p = Vector3.new(ri.X+(apex.X-ri.X)*(1-math.cos(a*halfPi)),ri.Y+(apex.Y-ri.Y)*math.sin(a*halfPi),ri.Z)
								local cf = CFrame.new(p, p + vi*Vector3.new(1, 1-a, 0))
								rig:pose('Kyogre', cf)
								rig:pose('LowerJaw', CFrame.Angles(a*0.3, 0, 0))
								rig:pose('RightArm', CFrame.Angles((1-a)*-0.5, 0, 0))
								rig:pose('LeftArm', CFrame.Angles((1-a)*0.5, 0, 0))
								local f = kyogre.Main.CFrame * Vector3.new(0, 0, -15)
								cam.CoordinateFrame = CFrame.new(apex + Vector3.new(15, 5, -30), f)
							else
								a = a - 1
								local p = Vector3.new(ri.X+(apex.X-ri.X)*(1-math.cos(halfPi+a*halfPi)),apex.Y+(ri.Y-apex.Y-15)*(1-math.sin((1-a)*halfPi)),ri.Z)
								local cf = CFrame.new(p, p + vi*Vector3.new(1, -a*2, 0))
								rig:pose('Kyogre', cf)
								rig:pose('LowerJaw', CFrame.Angles((1-a)*0.3, 0, 0))
								rig:pose('RightArm', CFrame.Angles(a*-0.5, 0, 0))
								rig:pose('LeftArm', CFrame.Angles(a*0.5, 0, 0))
								local f = kyogre.Main.CFrame * Vector3.new(0, 0, -15)
								cam.CoordinateFrame = CFrame.new(apex + Vector3.new(15, 5, -30), f)
							end
						end)

						wait(1)
						cam.CoordinateFrame = CFrame.new(-1255.82715, 146.143784, -2336.25146, -0.760671139, -0.384244442, 0.523197472, -1.49011612e-08, 0.805988789, 0.591930807, -0.649137437, 0.450264692, -0.613092422)
							* CFrame.new(0, 0, -15) * CFrame.Angles(-0.15, 0, 0)

						rig:poses({'LowerJaw',CFrame.new()},{'RightArm',CFrame.Angles(-0.2,0,0)},{'LeftArm',CFrame.Angles(0.2,0,0)})
						local kp = Vector3.new(grp.X, 88, kyogre.Main.Position.Z-4)
						local kcf = CFrame.new(kp, grp)
						local kyp = kcf * Vector3.new(0, 0, -20)
						spawn(function() _p.MasterControl:LookAt(kyp) end)
						spawn(function() man:LookAt(kyp) end)
						Tween(3, 'easeOutCubic', function(a)
							rig:pose('Kyogre', kcf + Vector3.new(0, -15*(1-a), 0))
						end)
						local idleAnimating = true
						spawn(function()
							local st = tick()
							while idleAnimating do
								stepped:wait()
								local et = tick()-st
								local a = math.cos(et*1.75)
								local aa = (a+1)*.1
								rig:poses({'Kyogre', kcf + Vector3.new(0, -1+a, 0)},
								{'RightArm', CFrame.Angles(-aa, 0, 0)},
								{'LeftArm', CFrame.Angles(aa, 0, 0)})
							end
						end)

						wait(1)
						admin:Say('We did it!',
							'Despite our losses, Kyogre has shown itself to us!',
							'We have another chance!')
						spawn(function() man:LookAt(nap) end)
						man:Say('We need to get out of here right now!',
							'Kyogre has been absent from the presence of humans for too long.',
							'There is no telling what it may do!')
						spawn(function() admin:LookAt(mp) end)
						admin:Say('Hush, old fool!',
							'It is clear that Kyogre is showing loyalty to the one who summoned it!',
							'It awaits my command!')
						man:Say('Or perhaps it\'s trying to decide who to punish for calling upon it without a purpose?',
							'Did you think of that?')
						admin:Say('Our archeological experts swear that Kyogre will show its loyalty to those who summon it!',
							'We must act quickly now to capture Kyogre, then bring it back to the boss.')
						spawn(function() admin:LookAt(grp) end)
						admin:Say('Quickly, hand me an empty Pok[e\'] Ball.')
						spawn(function() man:LookAt(kyp) end)
						admin:LookAt(kyp)
						admin:Say('Kyogre, accept me as your new trainer and help us create a new world together!')

						-- throw poke ball
						adminIdle:Stop(0)
						wait()
						local rs = admin.model.Torso['Right Shoulder']
						local rarm = admin.model['Right Arm']
						rs.MaxVelocity = .5
						local da = 3
						rs.DesiredAngle = da
						local ball = _p.storage.Modelss.pokeball:Clone()
						ball.Parent = admin.model
						local MoveModel = Utilities.MoveModel
						repeat
							stepped:wait()
							MoveModel(ball.Main, rarm.CFrame * CFrame.new(0, -1, 0), true)
						until math.abs(rs.CurrentAngle-da) < .05
						da = math.pi*2/3
						rs.DesiredAngle = da
						repeat
							stepped:wait()
							MoveModel(ball.Main, rarm.CFrame * CFrame.new(0, -1, 0), true)
						until math.abs(rs.CurrentAngle-da) < .05
						rs.MaxVelocity = .1
						adminIdle:Play()
						local cf = ball.Main.CFrame
						local vi = Vector3.new(0, 3, 4).unit*80
						local a = Vector3.new(0, -196.2, 0)
						local rv = Vector3.new(3, 0, 0)
						local planeY = 87
						local bounceY, bounceNormal
						local st = tick()
						local fporwif = Utilities.findPartOnRayWithIgnoreFunction
						local ray = Ray.new
						local function ignoreFn(p)
							return not p:IsDescendantOf(kyogre)
						end
						repeat
							stepped:wait()
							local t = tick()-st
							MoveModel(ball.Main, cf * CFrame.Angles(rv.X*t, rv.Y*t, rv.Z*t) + vi*t + .5*a*t^2, true)
							if not bounceY then
								local v = vi + a*t
								local hit, pos, norm = fporwif(ray(ball.Main.Position, v.unit*4), ignoreFn)
								if hit then
									bounceY = pos.Y
									bounceNormal = norm
								end
							end
						until (ball.Main.Position.Y < planeY) or (bounceY and ball.Main.Position.Y < bounceY)
						if bounceNormal then
							rv = Vector3.new(0, 0, 3)
							cf = ball.Main.CFrame
							vi = bounceNormal * (vi+a*(tick()-st)).magnitude * 0.4
							st = tick()
							repeat
								stepped:wait()
								local t = tick()-st
								MoveModel(ball.Main, cf * CFrame.Angles(rv.X*t, rv.Y*t, rv.Z*t) + vi*t + .5*a*t^2, true)
							until ball.Main.Position.Y < planeY
						end
						MoveModel(ball.Main, ball.Main.CFrame + Vector3.new(0, -5, 0), true)
						Utilities.sound(337448917, 1, nil, 5)
						local pos = Vector3.new(ball.Main.Position.X, planeY, ball.Main.Position.Z)
						for i = 1, 12 do
							_p.Particles:new {
								Position = pos,
								Velocity = Vector3.new(0, 10, 0),
								VelocityVariation = 30,
								Acceleration = Vector3.new(0, -18, 0),
								Size = 1.5,
								Image = 243728104,
								Color = BrickColor.new('Navy blue').Color,
								Lifetime = 3,
							}
						end

						wait(1)

						local cry
						local function roar()
							if not cry then
								cry = _p.DataManager:getSprite('_FRONT', 'Kyogre').cry
							end
							spawn(function() Sprite:playCry(1, cry, .5) end)
							rig:pose('LowerJaw', CFrame.Angles(0.4, 0, 0), .5)
							wait(.75)
							rig:pose('LowerJaw', CFrame.new(), .5)
						end
						roar()

						admin:Say('Uhhhh... Was that supposed to happen?')

						wait(.25)
						roar()

						admin:Say('What\'s wrong, you overgrown stinking fish!')

						delay(1.5, function()
							pp = _p.player.Character.HumanoidRootPart.Position + Vector3.new(4, 0, 1.5)
							_p.MasterControl:WalkTo(pp)
							_p.MasterControl:LookAt(kyp)
						end)

						-- fire lazzzzaaaaaaaahhhhh
						idleAnimating = false
						delay(1, function()
							Utilities.sound(338262406, .75, nil, 8)
							local energy = create 'Part' {
								Material = Enum.Material.Neon,
								--							FormFactor = Enum.FormFactor.Custom,
								BrickColor = BrickColor.new('Cyan'),
								Anchored = true,
								CanCollide = false,
								TopSurface = Enum.SurfaceType.Smooth,
								BottomSurface = Enum.SurfaceType.Smooth,
								Parent = workspace,

								create 'SpecialMesh' {
									MeshType = Enum.MeshType.Sphere,
								}
							}
							local r = 15
							for i = 1, 20 do
								delay(.1*i, function()
									local beam = create 'Part' {
										Material = Enum.Material.Neon,
										--									FormFactor = Enum.FormFactor.Custom,
										BrickColor = BrickColor.new('Cyan'),
										Anchored = true,
										CanCollide = false,
										TopSurface = Enum.SurfaceType.Smooth,
										BottomSurface = Enum.SurfaceType.Smooth,
										Parent = workspace,
									}
									local twoPi = math.pi*2
									local transform = CFrame.Angles(twoPi*math.random(),twoPi*math.random(),twoPi*math.random()).lookVector * r
									Tween(.5, nil, function(a)
										local s = energy.CFrame * transform
										beam.Size = Vector3.new(.4, .4, r*a)
										beam.CFrame = CFrame.new(s + (energy.Position-s)/2*a, s)
									end)
									Tween(.5, nil, function(a)
										local s = energy.CFrame * transform
										beam.Size = Vector3.new(.4, .4, r*(1-a))
										beam.CFrame = CFrame.new(s + (energy.Position-s)*(.5+.5*a), s)
									end)
									beam:remove()
								end)
							end
							Tween(3, nil, function(a)
								local s = 15*a
								energy.Size = Vector3.new(s, s, s)
								energy.CFrame = kyogre.Main.CFrame * CFrame.new(0, 0, -28)
							end)
							local ring = create 'Part' {
								Transparency = 1,
								Anchored = true,
								CanCollide = false,
								--							FormFactor = Enum.FormFactor.Custom,
								Parent = workspace,

								create 'Decal' {
									Texture = 'rbxassetid://6142896054',
									Face = Enum.NormalId.Front,
								}
							}
							Tween(.5, nil, function(a)
								energy.CFrame = kyogre.Main.CFrame * CFrame.new(0, 0, -28)
								local o = 1-a
								ring.Decal.Transparency = o
								ring.Size = Vector3.new(o*100, o*100, .2)
								ring.CFrame = energy.CFrame
							end)
							ring:remove()
							local beam = create 'Part' {
								Material = Enum.Material.Neon,
								--							FormFactor = Enum.FormFactor.Custom,
								BrickColor = BrickColor.new('Cyan'),
								Anchored = true,
								CanCollide = false,
								TopSurface = Enum.SurfaceType.Smooth,
								BottomSurface = Enum.SurfaceType.Smooth,
								Parent = workspace,

								create 'CylinderMesh' {}
							}
							local ecf = energy.CFrame
							Tween(.3, nil, function(a)
								beam.Size = Vector3.new(15, a*100, 15)
								beam.CFrame = ecf * CFrame.new(0, 0, -15/2-a*50) * CFrame.Angles(math.pi/2, 0, 0)
							end)
							admin:remove()
							grunt:remove()
							grunt2:remove()
							wait(.5)
							local bcf = beam.CFrame
							Tween(.5, nil, function(a)
								local s = 15*(1-a)
								energy.Size = Vector3.new(s, s, s)
								energy.CFrame = ecf
								beam.Size = Vector3.new(s, 100, s)
								beam.CFrame = bcf
							end)
							energy:remove()
							beam:remove()
						end)
						wait()
						rig:poses({'Kyogre', kcf * CFrame.Angles(1, 0, 0) + Vector3.new(0, 5, 0), 4},
						{'LowerJaw', CFrame.Angles(0.7, 0, 0), 1.5},
						{'RightArm', CFrame.Angles(-1, 0, 0), 4},
						{'LeftArm', CFrame.Angles(1, 0, 0), 4})
						rig:poses({'Kyogre', kcf, .5},
						{'RightArm', CFrame.Angles(-0.2,0,0), .5},
						{'LeftArm', CFrame.Angles(0.2,0,0), .5})
						wait(.3)
						rig:pose('LowerJaw', CFrame.new(), .5)

						wait(1)
						spawn(function() man:Look(Vector3.new(0, 0, -1)) end)
						spawn(function() _p.MasterControl:Look(Vector3.new(0, 0, -1)) end)
						man:Say('Wow, I thought only Team Rocket blasted off like that...')

						wait(.5)
						spawn(function() man:LookAt(kyp) end)
						spawn(function() _p.MasterControl:LookAt(kyp) end)
						roar()
						Tween(2, nil, function(a)
							rig:pose('Kyogre', kcf + Vector3.new(0, -15*a, 0))
						end)
						delay(2/3, function()
							local sp = kyogre.Main.CFrame * Vector3.new(0, 5, -15)
							local ep = Vector3.new((mp.X+pp.X)/2, 116.7, (mp.Z+pp.Z)/2 + 4)
							local halfSqrt2 = math.sqrt(2)/2
							Tween(1, nil, function(a)
								local p = Vector3.new(sp.X+(ep.X-sp.X)*a, sp.Y+(ep.Y-sp.Y)*math.sin(a*math.pi*3/4)/halfSqrt2, sp.Z+(ep.Z-sp.Z)*a)
								orb2.CFrame = CFrame.new(p) * CFrame.Angles(0, math.pi, 0)
							end)
							Tween(.5, 'easeOutCubic', function(a)
								local dist = a*4
								orb2.CFrame = CFrame.new(ep) * CFrame.Angles(0, math.pi, 0) * CFrame.Angles(dist/.4*math.pi, 0, 0) + Vector3.new(0, 0, -dist)
							end)
						end)
						Tween(1, nil, function(a)
							local h = math.sin(a*math.pi*3/4)
							rig:pose('Kyogre', kcf + Vector3.new(0, -15+20*h, 0))
						end)

						wait(1)
						local kLerp = select(2, Utilities.lerpCFrame(kyogre.Main.CFrame, CFrame.new(kyogre.Main.Position, kyogre.Main.Position + Vector3.new(-1, 0, 0))))
						local swimRadius = 10
						Tween(3, nil, function(a)
							local aa = a*math.pi/2
							rig:pose('Kyogre', kLerp(a) + Vector3.new(swimRadius*(math.cos(aa)-1), -15*a, -swimRadius*math.sin(aa)))
						end)
						rig:remove()

						lighting.FogEnd = 1e5
						local music = sceneMusic
						local volume = music.Volume
						sceneMusic = nil
						Tween(1.5, nil, function(a)
							atmosphere.Transparency = a
							rain:setTransparency(0.1+a)
							music.Volume = volume*(1-a)
						end)
						atmosphere:remove()
						rain:remove()
						spawn(function() _p.MusicManager:returnFromSilence(1) end)

						local op = Vector3.new(orb2.Position.X, pp.Y, orb2.Position.Z)
						pp = op + (pp-op).unit*4
						mp = op + (mp-op).unit*4
						spawn(function() _p.MasterControl:WalkTo(pp) end)
						spawn(function() man:WalkTo(mp) end)

						local camF = op + Vector3.new(0, 1.5, 0)
						local camP = camF + Vector3.new(2, 1, -2.5).unit*13
						local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, CFrame.new(camP, camF)))
						Tween(1, 'easeOutCubic', function(a)
							cam.CoordinateFrame = lerp(a)
							cam:SetRoll(0)
						end)

						man:Say('I warned those guys.',
							'Pok[e\']mon of legend do not take kindly to corrupt people with selfish intentions.',
							'Those men were only here to capture and control Kyogre to fulfill their evil plans.',
							'And was it just me, or did that man ask Kyogre to "help him build a new world together"?',
							'I wonder what he was talking about.',
							'Anyways, it\'s a good sign that Kyogre returned the Blue Orb.',
							'He must have gone back to resting.')
						man.humanoid.WalkSpeed = 8
						man:WalkTo(op)
						orb2:remove()
						wait(.5)
						man:WalkTo(mp)
						man.humanoid.WalkSpeed = 16
						man:LookAt(pp)
						man:Say('It seems that Kyogre could tell that we were trying to help.',
							'The Blue Orb has been in my family for centuries, and many tales have been passed down with it.',
							'Team Eclipse mentioned something about archeologists telling them that Kyogre would follow whoever summoned him.',
							'The tales in my family say otherwise.',
							'Kyogre chooses to follow only those with pure intentions.',
							'It seems those archeologists sent those men out on a wild Zangoose chase.',
							'I\'m sure men like those will never understand why what they had done was wrong.')

						local jake = chunk.npcs.Jake
						local jp = pp + Vector3.new(0, 0, -5)
						jake:Teleport(CFrame.new(jp + Vector3.new(10, 0, 0), jp))
						jake:WalkTo(jp)
						spawn(function() _p.MasterControl:LookAt(jp) end)
						spawn(function() jake:LookAt(pp) end)
						jake:Say('I just saw that whole thing from the beach!',
							'What was that Pok[e\']mon?!')
						spawn(function() _p.MasterControl:LookAt(mp) end)
						spawn(function() man:LookAt(jp) end)
						spawn(function() jake:LookAt(mp) end)
						man:Say('That was Kyogre, the legendary Pok[e\']mon of the sea.',
							'Its presence created that monsoon that just came out of nowhere.',
							'It has the power to create heavy downpoors wherever it goes.',
							'According to legends, it created the seas.')
						jake:Say('That\'s incredible!',
							'It must have been so exciting to see it from so close.')
						man:Say('No, the exciting part is that we are still alive.',
							'Oh, and that reminds me - my granddaughter is still inside the house.')
						man:LookAt(door.Position)
						man:Say('Tess, you can come out now, the bad men are gone.')
						local cf = CFrame.new(girl.model.HumanoidRootPart.Position, door.Position)
						girl.model.HumanoidRootPart.CFrame = cf
						girl.gyro.cframe = cf
						door:open(.5)
						gp = mp + Vector3.new(0, 0, -5)
						delay(.6, function() door:close(.5) end)
						spawn(function() man:LookAt(gp) end)
						spawn(function() jake:LookAt(gp) end)
						girl:WalkTo(gp)
						spawn(function() girl:LookAt(mp) end)
						_p.DataManager:preload(22070531, 124313348)
						girl:Say('You don\'t need to talk to me like I\'m a child grandpa, let alone treat me like one.',
							'I could have taken care of those men a long time ago if you would\'ve just let me battle them.')
						man:Say('I\'m sorry sweetie, I\'m just afraid for you is all.',
							'You tend to be a little reckless at times.')
						girl:Say('Well, if you would just let me go have my own adventures, I wouldn\'t be so reckless.')
						man:Say('You know what Tess, you are right.')
						girl:Say('Wait, really?')
						man:Say('Yes, I really haven\'t been very fair making you stay at home.',
							'I just worry for your safety.',
							'As young as you are, I wasn\'t sure if it was right for you to leave on your own yet.')
						man:LookAt(pp)
						man:Say('But after seeing this young trainer courageously take on those men like that, I think I can allow you to leave home.',
							'I do have one request, however.')
						spawn(function() girl:LookAt((pp+jp)/2) end)
						man:LookAt((pp+jp)/2)
						man:Say('Would you two please allow my granddaughter to travel with you?',
							'It would give me peace of mind knowing that she is in the company of two strong and brave heroes.',
							'Oh my, I didn\'t catch your names.')
						spawn(function() girl:LookAt(pp) end)
						man:LookAt(pp)
						man:Say('What is yours?')
						man:Say('Oh alright, so you are '.._p.PlayerData.trainerName..'.')
						spawn(function() girl:LookAt(jp) end)
						spawn(function() man:LookAt(jp) end)
						man:Say('Excellent, and what is your name, young lad?')
						spawn(function() _p.MasterControl:LookAt(jp) end)
						jake.model.Head.face.Texture = 'rbxassetid://22070531'
						-- you see jake has hearts over his eyes and has heats coming out oh the top of is head
						local jhp = jake.model.Head.Position
						cam.CoordinateFrame = CFrame.new(jhp + Vector3.new(-2, 1, -1).unit*10, jhp)
						local particles = create 'ParticleEmitter' {
							Texture = 'rbxassetid://124313348',
							Size = NumberSequence.new(.3),
							VelocitySpread = 15,
							Rate = 5,
							RotSpeed = NumberRange.new(-15, 15),
							Speed = NumberRange.new(3.5),
							Lifetime = NumberRange.new(.5, 1),
							EmissionDirection = Enum.NormalId.Top,
							Parent = jake.model.Head,
						}
						wait(1)
						jake:Say('...')
						wait(1)
						cam.CoordinateFrame = CFrame.new(camP, camF) + Vector3.new(0, 0, -2.5)
						wait(.5)
						spawn(function() _p.MasterControl:LookAt(gp) end)
						girl:LookAt(pp)
						girl:Say('Um '.._p.PlayerData.trainerName..', what\'s up with your friend..?')
						particles.Enabled = false
						jake.model.Head.face.Texture = 'rbxassetid://210559073'
						delay(1, function()
							particles:remove()
						end)
						_p.MasterControl:LookAt(jp)
						wait(1)
						spawn(function() _p.MasterControl:LookAt(mp) end)
						man:Say('Ummm okay, let\'s just call you '.._p.PlayerData.trainerName..'\'s friend for now.',
							'Thank you again for helping me with those fiendish men, '.._p.PlayerData.trainerName..'.',
							'You have much success in your future, I can tell.',
							'I wish all of you the best of luck in your adventures.',
							'And please do watch over my granddaughter.')
						spawn(function() man:LookAt(gp) end)
						spawn(function() girl:LookAt(mp) end)
						girl:Say('Grandpa, thank you so much!',
							'I will come back when I\'ve seen the world.',
							'We can talk about all of my adventures and it will be so much fun!')
						man:Say('I know, sweetie.',
							'Good luck and enjoy the company of your new friends.')
						girl:Say('I will.')
						girl:LookAt(pp)
						girl:Say('Well, I\'m ready to leave town when you are.',
							'Oh, I see you are collecting Gym Badges.',
							'There is a gym in town, you know.',
							'So how about I wait by the gate that leads to Route 9 until you get the badge in Rosecove City?')
						spawn(function() girl:LookAt(jp) end)
						spawn(function() man:LookAt(jp) end)
						spawn(function() _p.MasterControl:LookAt(jp) end)
						jake:Say('That sounds like a lovely idea!',
							'I will come with you to keep you company.')
						girl:Say('Oh look at that, he does talk after all.')
						jake:Say('Heh, yeah...')
						jake:LookAt(pp)
						jake:Say('You go ahead and get that badge, '.._p.PlayerData.trainerName..'.',
							'I\'m going to go keep Tess safe in case there are any more of those Team Eclipse goons still in town.',
							'Come meet us by the gate to Route 9 when you are ready.')
						girl:WalkTo(jp + Vector3.new(0, 0, -3))
						delay(.5, function()
							jake:WalkTo(jp + Vector3.new(10, 0, 0))
						end)
						spawn(function()
							girl:WalkTo(jp + Vector3.new(10, 0, 0))
						end)
						wait(1)
						spawn(function() _p.MasterControl:LookAt(mp) end)
						spawn(function() man:LookAt(pp) end)
						man:Say('Oh '.._p.PlayerData.trainerName..', before you go, please take this.')
						setupJakeAndTessAfterLighthouseCutscene()
						onObtainItemSound()
						chat:say('Obtained a Protector!', _p.PlayerData.trainerName .. ' put the Protector in the Bag.')
						man:Say('I know it\'s not much but I wanted to give you something for all that you\'ve done.',
							'Now, if you\'ll excuse me, I\'ll be heading inside or some rest.',
							'This old man has been through quite a lot today already.',
							'Goodbye and good luck!')

						man:WalkTo(door.Position + Vector3.new(2, 0, 0))
						spawn(function() door:open(.5) end)
						man:WalkTo(door.Position + Vector3.new(-3, 0, 0))
						door:close(.5)

						clearCutsceneCharacters()

						Utilities.lookBackAtMe()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						_p.Menu:enable()
						chat:enable()
					end)
				end
				connectLighthouseScene()
			end
		end,

		onExit_Gate9 = function()
			local chunk = _p.DataManager.currentChunk
			if chunk.id ~= 'chunk11' or completedEvents.RosecoveWelcome then return end
			spawn(function() _p.PlayerData:completeEvent('RosecoveWelcome') end)
			local jake = chunk.npcs.Jake
			local grunt = chunk.npcs.CutsceneGrunt
			local jp = jake.model.HumanoidRootPart.Position
			local gp = grunt.model.HumanoidRootPart.Position
			local pp = jp + (gp-jp)/2.5 + Vector3.new(3, 0, 0)
			spawn(function()
				local cam = workspace.CurrentCamera
				local camP = gp + (jp-gp)/2.5 + Vector3.new(-2, 1, 0).unit*10
				local camF = jp + (gp-jp)/2
				local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, CFrame.new(camP, camF)))
				Tween(1.5, 'easeOutCubic', function(a)
					cam.CoordinateFrame = lerp(a)
					cam:SetRoll(0)
				end)
			end)
			spawn(function() grunt:LookAt(jp) end)
			_p.MasterControl:WalkTo(pp)
			spawn(function() _p.MasterControl:LookAt(jp) end)
			jake:LookAt(pp)
			jake:Say('Hey '.._p.PlayerData.trainerName..', I ran into this guy when I came out of the gate.',
				'He\'s one of those Team Eclipse hooligans.')
			spawn(function() _p.MasterControl:LookAt(gp) end)
			spawn(function() jake:LookAt(gp) end)
			grunt:Say('Who are you callin\' hooligan?!',
				'Team Eclipse is here on official business.',
				'I can\'t be letting either of you two past this point.',
				'You need to turn around and go back.')
			jake:Say('Why, what are you crooks up to this time?')
			grunt:Say('That\'s none of your business.')
			spawn(function() jake:LookAt(pp) end)
			spawn(function() _p.MasterControl:LookAt(jp) end)
			jake:Say('Knowing Team Eclipse, it can\'t be good.',
				'We need to find out what\'s going on.',
				'I\'ll battle this goon to keep him busy, you go find out what their plans are.')
			jake:LookAt(gp)
			return true
		end,

		onBeforeEnter_Gym3 = function(room, continueCFrame)
			local puzzlesCompleted = 0
			local m = room.model
			_p.DataManager:preload(6142910487, 6142918450) -- vs text, trainer icon
			-- continue support
			if continueCFrame then
				continueCFrame = continueCFrame + m.Base.Position
				for i = 3, 1, -1 do
					local block = m['Puzzle'..i].Blockade
					if continueCFrame.z > block.Position.Z-block.Size.Z/2+.1 then
						puzzlesCompleted = i
						break
					end
				end
			end
			-- puzzle
			local puzzle = _p.DataManager:loadModule('Gym3Puzzle')
			puzzle:Init(m.EverLight)
			for i = 1, puzzlesCompleted do
				puzzle:AutoComplete(m['Puzzle'..i])
			end
			local function loadNextLevel()
				if puzzlesCompleted < 3 then
					local n = puzzlesCompleted + 1
					puzzle:ActivatePuzzle(n, m['Puzzle'..n])
				end
			end
			loadNextLevel()
			puzzle.PuzzleCompleted:connect(function(n)
				if n > puzzlesCompleted then
					puzzlesCompleted = n
					loadNextLevel()
				end
			end)
			for _, puzzle in pairs({m.Puzzle1, m.Puzzle2, m.Puzzle3}) do
				for _, piece in pairs(puzzle.Pieces:GetChildren()) do
					if piece.Name == 'Draggable' then
						for _, part in pairs(piece:GetChildren()) do
							if part:IsA('BasePart') and part.Name == 'CollisionFix' then
								local cf = part.CFrame
								part.Size = part.Size + Vector3.new(0, .2, 0)
								part.CFrame = cf + Vector3.new(0, .1, 0)
							end
						end
					end
				end
			end
			-- leader
			local leader = room.npcs.Leader
			interact[leader.model] = function()
				if _p.PlayerData.badges[3] then
					leader:Say('You have a very important journey ahead of you.',
						'Remember to fight for a good cause and not just to gain power.')
					return
				end
				leader:Say('Hello, young trainer.',
					'I am Quentin, leader of the Rosecove City Gym.',
					'You must be the kid that ran Team Eclipse out of town.',
					'Word spreads fast around this town.',
					'I\'m sure you are here now to test your strength and earn a badge.',
					'I must warn you, my specialty is Water-type Pok[e\']mon.',
					'Water-type Pok[e\']mon are said to be some of the oldest living species on the planet.',
					'They\'ve had millions of years to evolve into battling machines.',
					'You must be strong to have beaten all of those Team Eclipse members, but are you strong enough to take on the Rosecove City Gym Leader?',
					'Let\'s find out now, shall we?')
				local win = _p.Battle:doTrainerBattle {
					battleSceneType = 'Gym3',
					musicId = 121757660131215,
					PreventMoveAfter = true,
					vs = {name = 'Quentin', id = 5226490625, hue = 0.583, sat = .4},
					trainerModel = leader.model,
					num = 113
				}
				if win then
					leader:Say('You certainly are a driven individual.',
						'I can tell that you and your victories have more meaning than just a victory over battle.',
						'You are training with a purpose, and I like that.',
						'Your journey, wherever it may take you, is something special.',
						'As soon as you let that go, you will become weak.',
						'Always fight for something and not for personal gain, I always say.',
						'You have earned my respect, and now you have earned this prize.',
						'I present to you, the Float Badge!')

					local badge = m.Badge3:Clone()
					local cfs = {}
					local main = badge.SpinCenter
					for _, p in pairs(badge:GetChildren()) do
						if p:IsA('BasePart') and p ~= main then
							cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
						end
					end
					badge.Parent = workspace
					local st = tick()
					local spinRate = 1
					local function cframeTo(rcf)
						local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi/2, 0, (tick()-st)*spinRate + math.pi/2)
						main.CFrame = cf
						for p, ocf in pairs(cfs) do
							p.CFrame = cf:toWorldSpace(ocf)
						end
					end
					local r = 8
					local f = CFrame.new(0, 0, -6)
					Tween(1, nil, function(a)
						local t = a*math.pi/2
						cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
					end)
					local spin = true
					Utilities.fastSpawn(function()
						while spin do
							cframeTo(f)
							stepped:wait()
						end
					end)
					wait(2)
					onObtainBadgeSound()
					chat:say('Obtained the Float Badge!')
					spin = false
					Tween(.5, nil, function(a)
						local t = (1-a)*math.pi/2
						cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
					end)
					badge:remove()

					leader:Say('With that badge, you will be able to trade for Pok[e\']mon up to level 50.',
						'I also want you to have this.')
					onObtainItemSound()
					chat:say('Obtained a TM55!',
						_p.PlayerData.trainerName .. ' put the TM55 in the Bag.')
					chat:say(leader, 'TM 55 contains the move Scald.',
						'Scald is a strategic Water-type move that can actually burn the opponent.',
						'As I\'m sure you know, a burn slowly hurts the opponent turn by turn, but it will also cut their attack power in half.',
						'Now, about what I said earlier about your "fighting with a purpose".',
						'The reason you fight is pure and will grant you incredible strength in your journey.',
						'I know about your parents.',
						'Like I said before, word travels fast here.',
						'The story of the child that lost their parents to the wicked Team Eclipse, then shows up and fights them back - not once - but twice, now is spreading all over town.',
						'Your story not only strengthens you but others who hear of your journey.',
						'Now young trainer, go and continue to fight for what is right.',
						'Your journey is only just beginning.')
				end
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				chat:enable()
				_p.Menu:enable()
			end
		end,

		onExit_Gym3 = function()
			if not _p.PlayerData.badges[3] or completedEvents.ProfAfterGym3 then return end
			spawn(function() _p.PlayerData:completeEvent('ProfAfterGym3') end)
			spawn(function() _p.Menu:disable() end)
			chat:say('Well, look who it is...')

			local chunk = _p.DataManager.currentChunk
			local playerPos = _p.player.Character.HumanoidRootPart.Position
			local door = chunk:getDoor('Gym3')
			local profPos = (door.model.Main.CFrame * CFrame.new(20, -0.3, -20)).p
			local prof = _p.NPC:PlaceNew('Professor', chunk.map, CFrame.new(profPos, playerPos))
			--		table.insert(chunk.npcs, prof)
			spawn(function() _p.MasterControl:LookAt(profPos) end)
			local cam = workspace.CurrentCamera
			local camP = CFrame.new(cam.CoordinateFrame.p+Vector3.new(1, -8, 4), prof.model.Head.Position)
			local walking = true
			spawn(function()
				prof:WalkTo(playerPos+(prof.model.HumanoidRootPart.Position-playerPos).unit*7)
				walking = false
			end)
			local start = tick()
			while true do
				stepped:wait()
				if tick()-start > 4 then
					cam.CoordinateFrame = CFrame.new(camP.p, prof.model.Head.Position)
					break
				end
				local speed = 0.05 + 0.1*(tick()-start)
				local cf = cam.CoordinateFrame
				local focus = cf.p + cf.lookVector * (prof.model.Head.Position - cf.p).magnitude
				if (prof.model.Head.Position-focus).magnitude < 0.2 and not walking then break end
				cam.CoordinateFrame = CFrame.new(cf.p + (camP.p-cf.p)*speed, focus + (prof.model.Head.Position-focus)*speed)
			end
			local myName = _p.PlayerData.trainerName
			prof:Say('What a surprise to run into you here, '..myName..'.',
				'I was just in the neighborhood to talk to a man about some Pok[e\']mon-related issues I\'ve been having.',
				'Anyways, I heard from a few people that a member of Team Eclipse tried stealing your necklace in Cheshma Town.',
				'It was very fortunate that you managed to escape.', 'I\'ll bet you and your Pok[e\']mon are very strong now?',
				'Oh, it looks like you have 3 badges now.', 'You really are coming along quite well.',
				'Anyways '..myName..', I also wanted to tell you that I haven\'t gotten any word regarding you parents yet.',
				'According to a few sources, it would appear that Team Eclipse definitely has them, but it\'s unclear where they are keeping them.',
				'Team Eclipse has been giving the people of Roria trouble for a few years now but their base of operation has never been found.',
				'What\'s odd is that in the past they have been keeping their villainous attempts on the down low.',
				'Lately, though, they have been attacking very populated areas and in large numbers.',
				'If I had to guess, I\'d say they were getting close to whatever it is that they are after.',
				'What\'s that, you want to know what they\'re trying to do?',
				'Well, there have been stories and rumors spread around that they are looking for a particular ancient Pok[e\']mon with an incredibly unique power.',
				'I was once told that Team Eclipse is not happy with the world we live in.',
				'Apparently whatever they are searching for might have the potential to take them someplace new.',
				'I would guess an entirely new world.', 'What Pok[e\']mon has that sort of power, though, is beyond me.',
				'I\'ve heard that Team Eclipse has also been making attempts to gather lots of other Pok[e\']mon, including some mythical or legendary Pok[e\']mon.',
				'Groudon and Kyogre are great and powerful Pok[e\']mon that can create land and seas.', 'They give our world balance.',
				'I\'m guessing they need those Pok[e\']mon to bring balance to wherever they are trying to get to.',
				'Without these Pok[e\']mon however, I\'m afraid it would bring chaos upon Roria.',
				'You see, legendary Pok[e\']mon crafted this world.', 'Be it, the land and seas, or even time and space.',
				'It was all made by legendary Pok[e\']mon.', 'Anyways, we have nothing to fear.',
				'It seems that Team Eclipse\'s attempt to secure another legendary Pok[e\']mon has failed.',
				'Well, I really must get going '..myName..'.', 'I need to run to the Pok[e\']mon Center real fast.',
				'Be safe and stay out of trouble.', 'It was nice talking to you.')
			spawn(function()
				local door = chunk:getDoor('PokeCenter')
				prof:WalkTo(Vector3.new(-994.4, 116, -2170.6))
				prof:WalkTo(door.Position + Vector3.new(0, 0, 2))
				spawn(function() door:open(.5) end)
				prof:WalkTo(door.Position + Vector3.new(0, 0, -3))
				door:close(.5)
				prof:remove()
			end)
			_p.Menu:enable()

			return true
		end,

		-- Haunted Mansion
		setRotomEventValue = function(n)
			local st = tick()
			if _p.PlayerData:completeEvent('Rotom'..n) then
				_p.PlayerData.rotomEventLevel = n
			end
			local et = tick()-st
			if et < 2 then
				wait(2-et)
			end
		end,

		onEnterHauntedMansion = function()
			local chunk = _p.DataManager.currentChunk
			if chunk.id ~= 'chunk13' then return end
			local r = chunk.data.regions['Fortulose Manor']
			r.Grass = r.InsideEnc
			r.GrassNotRequired = true
			r.GrassEncounterChance = 3
			r.battleSceneType = 'HauntedMansion'
		end,

		onExitHauntedMansion = function()
			local chunk = _p.DataManager.currentChunk
			if chunk.id ~= 'chunk13' then return end
			local r = chunk.data.regions['Fortulose Manor']
			r.Grass = r.OutsideEnc
			r.GrassNotRequired = nil
			r.GrassEncounterChance = nil
			r.battleSceneType = nil
		end,

		RotomElectrifyFrom = function(pos, targetCharacter, yellow)
			if targetCharacter then
				targetCharacter = _p.player.Character.HumanoidRootPart.Position
			end
			local partPrototype = create 'Part' {
				BrickColor = BrickColor.new(yellow and 'New Yeller' or 'Cyan'),
				Material = Enum.Material.SmoothPlastic,
				Anchored = true,
				CanCollide = false,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				create 'BlockMesh' {
					Scale = Vector3.new(.5, .5, 1),
				}
			}
			local soundPart = partPrototype:Clone()
			soundPart.Transparency = 1
			soundPart.CFrame = CFrame.new(pos)
			soundPart.Parent = workspace
			local sound = create 'Sound' {
				SoundId = 'rbxassetid://360053049',
				Volume = targetCharacter and 1 or .5,
				Parent = soundPart,
			}
			sound:Play()
			delay(5, function()
				soundPart:remove()
			end)
			local function line(p1, p2)
				local p = partPrototype:Clone()
				p.Size = Vector3.new(.2, .2, (p2-p1).magnitude)
				p.CFrame = CFrame.new((p1+p2)/2, p1)
				p.Parent = workspace
				return p
			end
			local charDir = targetCharacter and (targetCharacter-pos) or nil
			for i = 1, 15 do
				spawn(function()
					local heading = math.random()*math.pi*2
					local attitude = math.random()*math.pi*2/3-math.pi/6
					local dir = charDir or Vector3.new(math.cos(heading), math.sin(attitude), math.sin(heading))
					local range = charDir and 1 or (2 + math.random()*1.5)
					local maxDeviation = charDir and (charDir.magnitude/3) or (range/3)
					local endPoint = targetCharacter or (pos + dir*range)
					local parts = {}
					for j = 1, math.random(10, 20) do
						local nSegments = math.random(2, 3) + (targetCharacter and 1 or 0)
						local positions = {pos}
						for k = 2, nSegments do
							local theta = math.random()*math.pi*2
							local deviation = math.random()*maxDeviation
							positions[k] = CFrame.new(pos + dir*range/(nSegments+1)*k, endPoint) * Vector3.new(math.cos(theta)*deviation, math.sin(theta)*deviation, 0)
						end
						positions[nSegments+1] = endPoint
						for l = 1, nSegments do
							parts[l] = line(positions[l], positions[l+1])
						end
						stepped:wait()
						stepped:wait()
						for l = 1, nSegments do
							parts[l]:remove()
						end
					end
				end)
				stepped:wait()
				stepped:wait()
				stepped:wait()
			end
		end,

		onLoad_chunk13 = function(chunk)
			--		local lighting = game:GetService('Lighting')
			--		lighting.FogColor = Color3.fromHSV(5/6, .2, .5)
			--		lighting.FogStart = 45
			--		lighting.FogEnd = 200

			local r = chunk.data.regions['Fortulose Manor']
			r.OutsideEnc = r.Grass
		end,

		onBeforeEnter_HMFoyer = function(room, ccf)
			_p.Events.onEnterHauntedMansion()
			_p.DataManager:preload(360053049, 360064127, 360068426)
			-- Haunter
			if ccf then
				room.model.Haunter:remove()
			else
				spawn(function()
					local function disappear()
						wait(.2)
						local mm = Utilities.MoveModel
						local hmain = room.model.Haunter.Main
						local hcf = hmain.CFrame
						Tween(1, 'easeOutCubic', function(a)
							mm(hmain, hcf * CFrame.new(0, 0, -3*a), true)
						end)
						room.model.Haunter:remove()
					end
					local in_house = false
					local hroot = _p.player.Character.HumanoidRootPart
					local base = room.model.Base
					local lnode = room.model.HaunterNodeL
					local rnode = room.model.HaunterNodeR
					while stepped:wait() do
						if not room.model or not room.model.Parent then return end
						local p = hroot.Position - base.Position
						if in_house then
							if p.Y > 6.5 then
								disappear()
								return
							end
							local wz = (hroot.Position.X-lnode.Position.X)/(rnode.Position.X-lnode.Position.X)*(rnode.Position.Z-lnode.Position.Z)+lnode.Position.Z
							if hroot.Position.Z > wz then
								disappear()
								return
							end
						elseif p.Y > 0 then
							in_house = true
						end
					end
				end)
			end
			-- Litwicks
			for _, m in pairs(room.model.Candles:GetChildren()) do
				if m:FindFirstChild('Wick') then
					if math.random(30) == 23 then
						local pe = m.Wick.ParticleEmitter
						pe.Texture = 'rbxassetid://356993522'
						pe.Color = ColorSequence.new(
							Color3.new(.5, .8, 1),
							Color3.new(1, 1, 1))
						chat.silentInteract[m] = function()
							if (_p.player.Character.HumanoidRootPart.Position-m.Wick.Position).magnitude > 8 then return end
							chat.silentInteract[m] = nil
							delay(3, function()
								pe.Texture = 'rbxassetid://326054833'
								pe.Color = ColorSequence.new(
									Color3.new(1, .6, .04),
									Color3.new(1, .92, .06))
							end)
							_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Candle)
						end
					end
				end
			end
			do -- Side External Doors
				local chunk = _p.DataManager.currentChunk
				local Door = _p.Door
				local fd1 = room.model.FakeDoor1
				fd1.Main.Touched:connect(function(p)
					if chunk.doorDebounce or not p or not p:IsDescendantOf(_p.player.Character) or not p.Parent or p.Parent:IsA('Accoutrement') then return end
					if not _p.MasterControl.WalkEnabled then return end
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					chunk.doorDebounce = true
					local door = Door:new(fd1)
					spawn(function() door:open(.75) end)
					Utilities.FadeOut(1, Color3.new(0, 0, 0))
					door:remove()

					_p.Events.onExitHauntedMansion()
					chunk:exitDoor(chunk:getDoor('HMStub1'), true)
					chunk.doorDebounce = false
				end)
				local fd2 = room.model.FakeDoor2
				fd2.Main.Touched:connect(function(p)
					if chunk.doorDebounce or not p or not p:IsDescendantOf(_p.player.Character) or not p.Parent or p.Parent:IsA('Accoutrement') then return end
					if not _p.MasterControl.WalkEnabled then return end
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					chunk.doorDebounce = true
					local door = Door:new(fd2)
					spawn(function() door:open(.75) end)
					Utilities.FadeOut(1, Color3.new(0, 0, 0))
					door:remove()

					_p.Events.onExitHauntedMansion()
					chunk:exitDoor(chunk:getDoor('HMStub2'), true)
					chunk.doorDebounce = false
				end)
			end
		end,
		onExit_HMFoyer = function() _p.Events.onExitHauntedMansion() end,

		-- Haunted Mansion multi-external-door hack
		onBeforeEnter_HMStub1 = function(room)
			local chunk = _p.DataManager.currentChunk
			room:remove()
			room = chunk:getRoom('HMFoyer', chunk:getDoor('HMFoyer'), 1)
			chunk.roomStack = {room}
			_p.Events.onBeforeEnter_HMFoyer(room)
			room.Entrance = room.model.FakeDoor1.Entrance
		end,

		onBeforeEnter_HMStub2 = function(room)
			local chunk = _p.DataManager.currentChunk
			room:remove()
			room = chunk:getRoom('HMFoyer', chunk:getDoor('HMFoyer'), 1)
			chunk.roomStack = {room}
			_p.Events.onBeforeEnter_HMFoyer(room)
			room.Entrance = room.model.FakeDoor2.Entrance
		end,

		-- Spooky Rocking Chair
		onBeforeEnter_HMMotherLounge = function(room)
			local st = tick()
			local chair = room.model.RockingChair
			local tm = room.model:FindFirstChild('#Item')
			local ic = room.model.ItemContainer
			local lockTMTrans = false
			local function setTMTrans(t)
				if lockTMTrans then return end
				pcall(function()
					tm.Top.Transparency = t
					tm.Base.Bottom.Transparency = t
				end)
			end
			setTMTrans(1)
			if tm then tm.Parent = ic end

			local ocf = chair.Hinge.CFrame
			local cfs = {}
			for _, p in pairs(chair:GetChildren()) do
				if p:IsA('BasePart') and p.Name ~= 'Hinge' then
					cfs[p] = ocf:toObjectSpace(p.CFrame)
				end
			end
			chair.Hinge:remove()
			local tmcf; pcall(function() tmcf = ocf:toObjectSpace(ic.Main.CFrame) end)

			local amplitude = 0
			local player = _p.player

			spawn(function()
				local enableTimer = Utilities.Timing.easeInCubic(4)
				local disableTimer = Utilities.Timing.easeOutCubic(.5)

				local heartbeat = game:GetService('RunService').Heartbeat
				local halfPi = math.pi/2

				local function angle(cf, p)
					local s = (cf - cf.p):toObjectSpace(CFrame.new(-(p - cf.p)))
					return math.atan2(s.x, s.z)
				end
				local p = ocf.p
				local state = 'idle'
				local stateTick = tick()
				local maxAmplitude = 1
				while chair.Parent do
					heartbeat:wait()
					local cf
					pcall(function() cf = player.Character.HumanoidRootPart.CFrame end)
					if cf then
						local shouldBeEnabled = not _p.Battle.currentBattle and ((cf.p-p)*Vector3.new(1,0,1)).magnitude > 6
						if shouldBeEnabled then
							local theta = angle(cf, Vector3.new(p.x, cf.p.y, p.z))
							if math.abs(theta) <= halfPi then
								shouldBeEnabled = false
							end
						end
						--					print(state, shouldBeEnabled)
						local now = tick()
						if state == 'idle' and shouldBeEnabled then
							state = 'enabling'
							stateTick = now
						elseif state == 'enabling' then
							if shouldBeEnabled then
								if now-stateTick > 2 then
									state = 'enabled'
									stateTick = now
								end
							else
								state = 'idle'
								stateTick = now
							end
						elseif state == 'enabled' then
							if shouldBeEnabled then
								local et = now-stateTick
								if et > 4 then
									amplitude = 1
								else
									amplitude = enableTimer(et)
								end
							else
								state = 'disabling'
								stateTick = now
								maxAmplitude = amplitude
							end
						elseif state == 'disabling' then
							local et = now-stateTick
							if et > .5 then
								state = 'idle'
								stateTick = now
								amplitude = 0
							else
								amplitude = (1-disableTimer(et)) * maxAmplitude
							end
						end
					end
				end
			end)

			local MoveModel = Utilities.MoveModel
			spawn(function()
				while chair.Parent do
					stepped:wait()
					local a = math.sin((tick()-st)*2) * .35 * amplitude
					local ncf = ocf * CFrame.new(0, 0, a*3.65) * CFrame.Angles(a, 0, 0)
					for p, cf in pairs(cfs) do
						p.CFrame = ncf:toWorldSpace(cf)
					end
					if tm then
						pcall(function() MoveModel(ic.Main, ncf:toWorldSpace(tmcf), true) end)
						local trans = 1 - amplitude
						if trans < .1 then
							setTMTrans(0)
							lockTMTrans = true
						else
							setTMTrans(trans)
						end
					end
				end
			end)
		end,

		-- Rotom series of events
		-- 0: Jukebox
		onBeforeEnter_HMMusicRoom = function(room)
			if _p.PlayerData.rotomEventLevel == 0 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .1, .5) end)

				local jukebox = room.model.Jukebox
				local tag = create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'HauntedJukebox',
					Parent = jukebox,
				}
				local sound = create 'Sound' {
					SoundId = 'rbxassetid://358961168',
					Volume = 1,
					Looped = true,
					Parent = jukebox.Main,
				}
				sound:Play()

				local function enableLights(obj, enabled)
					for _, c in pairs(obj:GetChildren()) do
						if c:IsA('Light') then
							c.Enabled = enabled
						end
					end
				end
				-- old code that I don't fell like re-interpreting
				local function colorLights(obj, col)
					for _, c in pairs(obj:GetChildren()) do
						if c:IsA('Light') then
							c.Color = col
						end
					end
				end
				local function shiftColor(p)
					local function u(n, i)
						if math.abs(n) < i then
							return n
						end
						return (Vector3.new(n,0,0).unit.x)*i
					end
					local new = Vector3.new(10/math.random(10,100),10/math.random(10,100),10/math.random(10,100))
					local dif = new - p.Light1.Mesh.VertexColor 
					repeat
						local d = Vector3.new(u(dif.x,0.01),u(dif.y,0.01),u(dif.z,0.01))
						local vc = p.Light1.Mesh.VertexColor + d
						p.Light1.Mesh.VertexColor = vc
						p.Light2.Mesh.VertexColor = vc
						local color = Color3.new(vc.X, vc.Y, vc.Z)
						colorLights(p.Light1, color)
						colorLights(p.Light2, color)
						dif = dif - d
						wait()
					until not tag.Parent or (math.abs(dif.x) <= 0.03 and math.abs(dif.y) <= 0.03 and math.abs(dif.z) <= 0.03)
				end
				spawn(function()
					local lights = jukebox.Lights
					enableLights(lights.Light1, true)
					enableLights(lights.Light2, true)
					while tag.Parent do
						wait()
						shiftColor(lights)
					end
					if not jukebox.Parent then return end
					enableLights(lights.Light1, false)
					enableLights(lights.Light2, false)
					lights.Light1.Mesh.VertexColor = Vector3.new(1, 1, 1)
					lights.Light2.Mesh.VertexColor = Vector3.new(1, 1, 1)
				end)
				-- end copied jukebox code
			end
		end,

		onExit_HMMusicRoom = function(room)
			if _p.PlayerData.rotomEventLevel == 0 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
				pcall(function()
					local s = room.model.Jukebox.Main.Sound
					local v = s.Volume
					Tween(.5, nil, function(a)
						s.Volume = v * (1-a)
					end)
				end)
			end
		end,

		onHauntedJukeboxClicked = function(jukebox)
			if _p.PlayerData.rotomEventLevel ~= 0 then return end
			_p.Events.RotomElectrifyFrom(jukebox.RotomRoot.Position)
			pcall(function()
				local s = jukebox.Main.Sound
				local v = s.Volume
				Tween(.5, nil, function(a)
					s.Volume = v * (1-a)
				end)
				s:remove()
			end)
			_p.Events.setRotomEventValue(1)
			chat:say('A strange presence has fled from the room.',
				'Sounds can be heard coming from somewhere else in the house.')
			spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
		end,

		-- 1: Computer
		onBeforeEnter_HMLibrary = function(room)
			if _p.PlayerData.rotomEventLevel == 1 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .1, .5) end)

				local computer = room.model.Computer
				local tag = create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'HauntedComputer',
					Parent = computer,
				}
				local sound = create 'Sound' {
					SoundId = 'rbxassetid://358962422',
					Volume = 1,
					Looped = true,
					Parent = computer.Main,
				}
				sound:Play()

				spawn(function()
					local screen = computer.Screen
					screen.Material = Enum.Material.Neon
					while tag.Parent do
						wait(.1)
						screen.BrickColor = BrickColor.new(Color3.new(.5+math.random()*.5, .5+math.random()*.5, .5+math.random()*.5))
					end
					if not computer.Parent then return end
					screen.Material = Enum.Material.SmoothPlastic
					screen.BrickColor = BrickColor.new('Navy blue')
				end)
			end
		end,

		onExit_HMLibrary = function(room)
			if _p.PlayerData.rotomEventLevel == 1 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
				pcall(function()
					local s = room.model.Computer.Main.Sound
					local v = s.Volume
					Tween(.5, nil, function(a)
						s.Volume = v * (1-a)
					end)
				end)
			end
		end,

		onHauntedComputerClicked = function(computer)
			if _p.PlayerData.rotomEventLevel ~= 1 then return end
			_p.Events.RotomElectrifyFrom(computer.Main.Position + Vector3.new(0, 0.75, 0))
			pcall(function()
				local s = computer.Main.Sound
				local v = s.Volume
				Tween(.5, nil, function(a)
					s.Volume = v * (1-a)
				end)
				s:remove()
			end)
			_p.Events.setRotomEventValue(2)
			chat:say('A strange presence has fled from the room.',
				'Sounds can be heard coming from somewhere else in the house.')
			spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
		end,

		-- 2: Toaster
		onBeforeEnter_HMDiningRoom = function(room)
			if _p.PlayerData.rotomEventLevel == 2 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .1, .5) end)

				local toaster = room.model.Toaster
				local tag = create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'HauntedToaster',
					Parent = toaster,
				}
				local sound = create 'Sound' {
					SoundId = 'rbxassetid://358963501',
					Volume = .6,
					Parent = toaster.Main,
				}

				spawn(function()
					local right = false
					local button = toaster.Button
					local bcf = button.CFrame
					toaster.Main.CanCollide = false
					while tag.Parent do
						Tween(.4, nil, function(a)
							if not toaster.Parent then return false end
							button.CFrame = bcf + Vector3.new(0, -0.6*a, 0)
						end)
						if not toaster.Parent then break end
						right = not right
						local toast = toaster[(right and 'R' or 'L')..'Bread']:Clone()
						toast.CanCollide = true
						toast.Anchored = false
						toast.Transparency = 0
						toast.Velocity = Vector3.new((math.random()-.5)*10, 60, (math.random()-.5)*10)
						toast.Parent = toaster
						delay(3, function()
							toast:remove()
						end)
						sound:Play()
						Tween(.1, nil, function(a)
							if not toaster.Parent then return false end
							button.CFrame = bcf + Vector3.new(0, -0.6*(1-a), 0)
						end)
					end
					if not toaster.Parent then return end
					toaster.Main.CanCollide = true
				end)
			end
		end,

		onExit_HMDiningRoom = function(room)
			if _p.PlayerData.rotomEventLevel == 2 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
			end
		end,

		onHauntedToasterClicked = function(toaster)
			if _p.PlayerData.rotomEventLevel ~= 2 then return end
			_p.Events.RotomElectrifyFrom(toaster.Main.Position + Vector3.new(0, 0.5, 0))
			_p.Events.setRotomEventValue(3)
			chat:say('A strange presence has fled from the room.',
				'Sounds can be heard coming from somewhere else in the house.')
			spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
		end,

		-- 3: Television
		onBeforeEnter_HMAttic = function(room)
			_p.Events.onEnterHauntedMansion()
			if _p.PlayerData.rotomEventLevel == 3 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .1, .5) end)

				local television = room.model.Television
				local tag = create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'HauntedTelevision',
					Parent = television,
				}
				local sound = create 'Sound' {
					SoundId = 'rbxassetid://358962482',
					Volume = .08,
					Looped = true,
					Parent = television.Main,
				}
				sound:Play()

				spawn(function()
					local screen = television.Screen
					local n = 0
					local scf = {screen.CFrame, screen.CFrame * CFrame.Angles(0, 0, math.pi)}
					local decal = create 'Decal' {
						Texture = 'rbxassetid://250646296',
						Face = Enum.NormalId.Front,
						Parent = screen,
					}
					while tag.Parent do
						n = (n + 1) % 2
						screen.CFrame = scf[n+1]
						wait(.1)
					end
					if not television.Parent then return end
					decal:remove()
				end)
			end
		end,

		onExit_HMAttic = function(room)
			_p.Events.onExitHauntedMansion()
			if _p.PlayerData.rotomEventLevel == 3 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
				pcall(function()
					local s = room.model.Television.Main.Sound
					local v = s.Volume
					Tween(.5, nil, function(a)
						s.Volume = v * (1-a)
					end)
				end)
			end
		end,

		onHauntedTelevisionClicked = function(television)
			if _p.PlayerData.rotomEventLevel ~= 3 then return end
			_p.Events.RotomElectrifyFrom(television.Main.Position + Vector3.new(0, 1.5, 0))
			pcall(function()
				local s = television.Main.Sound
				local v = s.Volume
				Tween(.5, nil, function(a)
					s.Volume = v * (1-a)
				end)
				s:remove()
			end)
			_p.Events.setRotomEventValue(4)
			chat:say('A strange presence has fled from the room.',
				'Sounds can be heard coming from somewhere else in the house.')
			spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
		end,

		-- 4: Hair Dryer
		onBeforeEnter_HMBathroom = function(room)
			if _p.PlayerData.rotomEventLevel == 4 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .1, .5) end)

				local hdryer = room.model.HairDryer
				local tag = create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'HauntedHairDryer',
					Parent = hdryer,
				}
				local sound = create 'Sound' {
					SoundId = 'rbxassetid://11717967',
					Volume = .4,
					Looped = true,
					Parent = hdryer.Main,
				}
				sound:Play()

				spawn(function()
					local main = hdryer.Main
					local cf = hdryer.Hinge.CFrame
					local rcf = cf:toObjectSpace(main.CFrame)
					local st = tick()
					while tag.Parent do
						local et = tick()-st
						main.CFrame = (cf * CFrame.Angles(0, et*4, 0)):toWorldSpace(rcf)
						stepped:wait()
					end
				end)
			end
		end,

		onExit_HMBathroom = function(room)
			if _p.PlayerData.rotomEventLevel == 4 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
				pcall(function()
					local s = room.model.HairDryer.Main.Sound
					local v = s.Volume
					Tween(.5, nil, function(a)
						s.Volume = v * (1-a)
					end)
				end)
			end
		end,

		onHauntedHairDryerClicked = function(hdryer)
			if _p.PlayerData.rotomEventLevel ~= 4 then return end
			_p.Events.RotomElectrifyFrom(hdryer.Main.Position + Vector3.new(0, 0.5, 0))
			pcall(function()
				local s = hdryer.Main.Sound
				local v = s.Volume
				Tween(.5, nil, function(a)
					s.Volume = v * (1-a)
				end)
				s:remove()
			end)
			_p.Events.setRotomEventValue(5)
			chat:say('A strange presence has fled from the room.',
				'Sounds can be heard coming from somewhere else in the house.')
			spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
		end,

		-- 5: Baby Monitor
		onBeforeEnter_HMBabyRoom = function(room)
			if _p.PlayerData.rotomEventLevel == 5 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .1, .5) end)

				local bmonitor = room.model.BabyMonitor
				local tag = create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'HauntedBabyMonitor',
					Parent = bmonitor,
				}
				local sound = create 'Sound' {
					SoundId = 'rbxassetid://358960837',
					Volume = .5,
					Looped = true,
					Parent = bmonitor.Main,
				}
				sound:Play()

				spawn(function()
					local main = bmonitor.Main
					local ocf = CFrame.new(main.Position + Vector3.new(0, -0.7, 0))
					local cfs = {}
					for _, p in pairs(bmonitor:GetChildren()) do
						if p:IsA('BasePart') then
							cfs[p] = ocf:toObjectSpace(p.CFrame)
						end
					end
					local st = tick()
					while tag.Parent do
						local et = tick()-st
						local max = .5+math.random()*.5
						local heading = math.random()*math.pi*2
						local axis = Vector3.new(math.cos(heading), 0, math.sin(heading))
						Tween(.5, nil, function(a)
							local angle = math.sin(a*math.pi*2) * max * (1-a)
							local cf = ocf * CFrame.fromAxisAngle(axis, angle)
							for p, rcf in pairs(cfs) do
								p.CFrame = cf:toWorldSpace(rcf)
							end
						end)
						wait(.1+math.random()*.6)
					end
					if not bmonitor.Parent then return end
					for p, rcf in pairs(cfs) do
						p.CFrame = ocf:toWorldSpace(rcf)
					end
				end)
			end
		end,

		onExit_HMBabyRoom = function(room)
			if _p.PlayerData.rotomEventLevel == 5 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
				pcall(function()
					local s = room.model.BabyMonitor.Main.Sound
					local v = s.Volume
					Tween(.5, nil, function(a)
						s.Volume = v * (1-a)
					end)
				end)
			end
		end,

		onHauntedBabyMonitorClicked = function(bmonitor)
			if _p.PlayerData.rotomEventLevel ~= 5 then return end
			_p.Events.RotomElectrifyFrom(bmonitor.Main.Position + Vector3.new(0, 0.5, 0))
			pcall(function()
				local s = bmonitor.Main.Sound
				local v = s.Volume
				Tween(.5, nil, function(a)
					s.Volume = v * (1-a)
				end)
				s:remove()
			end)
			_p.Events.setRotomEventValue(6)
			chat:say('A strange presence has fled from the room.',
				'Sounds can be heard coming from somewhere else in the house.')
			spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
		end,

		-- 6: GameBoy
		onBeforeEnter_HMBadBedroom = function(room)
			if _p.PlayerData.rotomEventLevel == 6 then
				_p.DataManager:preloadModule('RotomGBC')
				spawn(function() _p.MusicManager:fadeToVolume('top', .1, .5) end)

				local gameboy = room.model.GameBoy
				local tag = create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'HauntedGameBoy',
					Parent = gameboy,
				}
				local sound = create 'Sound' {
					SoundId = 'rbxassetid://333249262',
					Volume = .3,
					Looped = true,
					Parent = gameboy.Main,
				}
				sound:Play()

				local decal = create 'Decal' {
					Texture = 'rbxassetid://360436198',
					Face = Enum.NormalId.Top,
					Parent = gameboy.Screen
				}
			end
		end,

		onExit_HMBadBedroom = function(room)
			if _p.PlayerData.rotomEventLevel == 6 then
				spawn(function() _p.MusicManager:fadeToVolume('top', .3, .5) end)
				pcall(function()
					local s = room.model.GameBoy.Main.Sound
					local v = s.Volume
					Tween(.5, nil, function(a)
						s.Volume = v * (1-a)
					end)
				end)
			end
		end,

		onHauntedGameBoyClicked = function(gameboy)
			if _p.PlayerData.rotomEventLevel ~= 6 then return end
			local rotom
			spawn(function() rotom = _p.DataManager:request({'Model', 'Rotom'}) end)
			_p.Events.RotomElectrifyFrom(gameboy.Main.Position + Vector3.new(0, 0.5, 0))
			pcall(function()
				local s = gameboy.Main.Sound
				local v = s.Volume
				Tween(.5, nil, function(a)
					s.Volume = v * (1-a)
				end)
				s:remove()
				gameboy.Screen.Decal:remove()
			end)
			wait(2)

			if not Utilities.isTouchDevice() then
				_p.Events.RotomElectrifyFrom(gameboy.Main.Position + Vector3.new(0, 0.5, 0), true)
				wait(1)
				spawn(function() _p.MusicManager:prepareToStack(1) end)
				Utilities.FadeOut(1, Color3.new(0, 0, 0))
				local event = _p.DataManager:loadModule('RotomGBC')
				event:activate()
				event.FinishedSignal:wait()
				_p.Events.RotomElectrifyFrom(gameboy.Main.Position + Vector3.new(0, 0.5, 0), nil, true)
				Utilities.fadeGui.BackgroundTransparency = 1.0
				Utilities:layerGuis()
			end

			while not rotom do wait() end
			rotom.Parent = workspace
			local sp = gameboy.Main.Position
			local pp = _p.player.Character.HumanoidRootPart.Position
			pp = Vector3.new(pp.X, sp.Y, pp.Z)
			local lastScale = 1
			Tween(1, 'easeOutCubic', function(a)
				local scale = .3+.7*a
				Utilities.ScaleModel(rotom.Main, scale/lastScale)
				lastScale = scale
				Utilities.MoveModel(rotom.Main, CFrame.new(sp, pp) * CFrame.Angles(0, math.pi*a, 0) + (pp-sp)*2*a + Vector3.new(0, math.sin(math.pi*a)*5 + 2*a, 0))
			end)

			_p.PlayerData.rotomEventLevel = 7
			delay(3, function() rotom:remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Gameboy,{battleSceneType = 'HauntedMansion', musicId = {456112412, 456113817}})
		end,
		--

		-- Jake and Tess on Route 9
		onLoad_chunk12 = function(chunk)
			--		local lighting = game:GetService('Lighting')
			--		if lighting.FogEnd < 500 then
			--			lighting.FogEnd = 100000
			--		end

			local pName = _p.PlayerData.trainerName
			local jake = chunk.npcs.Jake
			local tess = chunk.npcs.Tess
			local function postInteractJake()
				interact[jake.model] = {
					'Hey ' .. pName .. ', thanks for not blowing my cover back there with that battle.',
					'I know I\'m weak but I don\'t want Tess to know.',
					'I\'m using this time to get stronger so that next time we have a battle I won\'t lose so miserably.',
					'Anyways, whenever you are ready to move on, just go to Route 10 and we will meet you there.'
				}
			end
			local function postInteractTess()
				interact[tess.model] = {
					'Hey can I ask you something, ' .. pName .. '?',
					'Does Jake really think he\'s stronger than you?',
					'I could tell in his battle that he was trying really hard.',
					'It seems he was battling as if everything was on the line.',
					'I hope he knows that being the strongest isn\'t what\'s important.',
					'It\'s what you do with that strength that defines who you are as a person.',
					'He\'s a good guy, I just hope he\'s focusing on the right things.'
				}
			end
			local function postInteract()
				postInteractJake()
				postInteractTess()
			end
			if completedEvents.MeetAbsol then
				jake:remove()
				tess:remove()
			elseif not completedEvents.JTBattlesR9 then
				local tp = Vector3.new(-589, 62.1, -256)
				local jp = Vector3.new(-583, 62.1, -256)
				local mp = (tp+jp)/2
				local pp = mp + Vector3.new(0, 0, 7)

				jake:Teleport(CFrame.new(jp, tp))
				tess:Teleport(CFrame.new(tp, jp))

				touchEvent('JTBattlesR9', chunk.map.JTBattleTrigger, false, function()
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					spawn(function() _p.Menu:disable() end)

					spawn(function()
						workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
						Utilities.lookAt(mp+Vector3.new(-5, 7, 13), mp+Vector3.new(0, 2, 0), 1)
					end)
					_p.MasterControl:WalkTo(pp)
					spawn(function() _p.MasterControl:LookAt(mp) end)

					jake:Say('Alright, ' .. pName .. ' is here.',
						'Looks like we\'re all ready to go.')
					tess:Say('Actually, before we go anywhere, I would like to suggest we do something first.')
					jake:Say('Oh ok, what do you have in mind?')
					tess:Say('Well, I know you are both tough trainers.',
						'I\'m curious which one of you is stronger.')
					jake:Say('Oh uh, well that would be me of course!')
					jake:LookAt(pp)
					jake:Say('Right ' .. pName .. '???')
					spawn(function() jake:LookAt(tp) end)
					tess:Say('Actually, what I\'m really asking is if you could let me watch you battle each other.',
						'I would also like to battle the winner of your match.',
						'I know this seems kind of sudden, but I want to make sure that you are both tough if I\'m going to be traveling with you.',
						'And if the winner of your match can beat me then I will know that you are without a doubt very strong trainers.')
					jake:Say('Hmm, I guess I wasn\'t really prepared for this.')
					jake:LookAt(pp)
					jake:Say('I dont think ' .. pName .. ' was either so maybe we should do this another time?')
					spawn(function() jake:LookAt(tp) end)
					tess:Say('Well, if you\'re afraid to battle ' .. pName .. ' then we\'ll just have our match without you.')
					tess:LookAt(pp)
					tess:Say('You aren\'t afraid of a little friendly fight, are you ' .. pName .. '?')
					spawn(function() tess:LookAt(jp) end)
					jake:Say('Wait, I\'m not afraid.',
						'I uhh... just dont think its fair to ' .. pName .. ' is all.')
					tess:Say(pName .. ' seems fine with it.')
					jake:Say('Oh, well in that case I guess we should have a battle.')
					jake:LookAt(pp)
					jake:Say('I\'m sorry ' .. pName .. ', but I won\'t be going easy on you.')
					tess:Say('Oh good, this will be so exciting!')
					tess:LookAt(pp)
					tess:Say('I will be cheering for you both.')
					jake:Say('Alright ' .. pName .. ', let\'s do this.')

					local win = _p.Battle:doTrainerBattle {
						musicId = 12639840340,
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = jake.model,
						num = 72
					}
					if not win then
						chat:enable()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						return
					end

					tess:Say('That was such a great match!',
						'You both did very well.',
						pName .. ' must be really strong, though, to have beaten Jake.')
					spawn(function() tess:LookAt(jp) end)
					jake:LookAt(tp)
					jake:Say('I might\'ve gone a little too easy on ' .. pName .. '.')
					tess:Say('Well that was nice of you, Jake.',
						'Now I want to challenge ' .. pName .. '.')
					tess:LookAt(pp)
					tess:Say('This is going to be so exciting!',
						'Alright ' .. pName .. ', I hope you\'re ready!',
						'I won\'t be going easy on you like Jake did!')

					local win = _p.Battle:doTrainerBattle {
						musicId = 12639840340,
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = tess.model,
						num = 73
					}
					if not win then
						chat:enable()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						return
					end

					tess:Say('Oh my, you really are a strong trainer!',
						'I thought for sure that I would win.',
						'I really don\'t know what happened.',
						'Maybe this is what my grandfather meant when he said I was too reckless.',
						'I must have placed too much confidence in myself.')
					spawn(function() tess:LookAt(jp) end)
					jake:Say('You aren\'t reckless, Tess!',
						'You\'re a great trainer!',
						'I could tell that you and your Pok[e\']mon have been in many great battles together.')
					tess:Say('Actually, if we\'re being honest here, that was my first real battle.')
					jake:Say('Wait, what?')
					tess:Say('My grandfather would never let me go out and challenge other real trainers because he thought I would hurt myself.',
						'My Pok[e\']mon and I have only trained with each other.',
						'It\'s been a struggle to teach them what they know now.')
					jake:Say('Wow, I wouldn\'t have guessed.',
						'You seemed so confident and...')
					tess:Say('Reckless, I know.')
					jake:Say('No, not at all.',
						'I was going to say capable.')
					tess:Say('Well thanks, Jake.',
						'Anyways, now you know a little more about me.',
						'One of my hopes in setting out on this adventure with you is to become a real Pok[e\']mon trainer.',
						'I want my Pok[e\']mon and I to grow strong together.')
					jake:Say('Well, I know you\'ll be great.')
					tess:Say('Thanks, Jake.')
					jake:Say('Oh uh, don\'t mention it.',
						'So, where to now?')
					tess:LookAt(pp)
					tess:Say(pName .. ', you said Team Eclipse has your parents, right?',
						'I think I might know someone that can help.',
						'He\'s an old friend of my grandpa\'s and he really knows his way around Roria.',
						'I think maybe he could help us figure out where Team Eclipse\'s base might be.')
					jake:LookAt(pp)
					jake:Say('That sounds like a good idea, don\'t you think?')
					spawn(function() tess:LookAt(jp) end)
					jake:LookAt(tp)
					jake:Say('Where does this friend of yours live?')
					tess:Say('He actually lives in the capital city of Roria, Anthian City.')
					tess:LookAt(pp)
					tess:Say('There\'s a gym there too from what I\'ve heard, ' .. pName .. '.')
					jake:Say('Oh my!',
						'I\'ve always wanted to visit Anthian City.',
						'I\'ve heard so many wonderful things about it!')
					jake:LookAt(pp)
					jake:Say('Aren\'t you excited too, ' .. pName .. '?',
						'Wait, WHAT?',
						'You\'ve never even heard of Anthian City?',
						'I can\'t believe it!',
						'Well you\'re in for a big surprise.',
						'I don\'t want to spoil anything for you.',
						'Just wait until we get there!')
					tess:Say('This will be interesting indeed.')
					spawn(function() tess:LookAt(jp) end)
					jake:LookAt(tp)
					jake:Say('Yes for sure.',
						'So how do we get there, anyways?')
					tess:Say('Well, we\'re on Route 9 now.',
						'I\'m pretty sure we just travel through this forest until we reach Route 10.',
						'From there we travel through a cave to the top of the Cragonos Mountains.')
					jake:Say('Seems simple enough.')
					tess:Say('We want to be careful not to get lost here, though.',
						'I heard there is a haunted mansion somewhere in these woods.',
						'I would hate to end up there.',
						'Ghost-type Pok[e\']mon scare me a little.',
						'I\'m not afraid to admit it.')
					jake:Say('G-g-g-ghosts?',
						'I\'m not scared of any g-g-ghosts...',
						'I\'ll fight them off, no problem.')
					tess:Say('That\'s kind of you, Jake.',
						'But since we are here in the woods, can I suggest that we train?',
						'I want to see what kinds of Pok[e\']mon this area offers.')
					jake:Say('Yeah that\'s fine by me.')
					jake:LookAt(pp)
					jake:Say(pName .. ', let\'s take a short break and look around the area.',
						'We will meet you on Route 10 when you are ready to move on, ' .. pName .. '.')

					spawn(function()
						Utilities.lookBackAtMe(1)
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						_p.Menu:enable()
					end)

					spawn(function()
						jake:WalkTo(Vector3.new(-579, 58, -290))
						postInteractJake()
					end)
					spawn(function()
						tess:WalkTo(Vector3.new(-594.339, 58, -308.601))
						tess:WalkTo(Vector3.new(-612.74, 58, -343.202))
						postInteractTess()
					end)
				end)
			else
				postInteract()
			end
		end,

		-- Jirachi event, etc.
		onLoad_chunk14 = function(chunk)
			local map = chunk.map
			local jirachi = map.Jirachi
			jirachi.Parent = nil

			local chatCn
			if not completedEvents.Jirachi then
				_p.DataManager:preload(9542447894, 9537298254)
				_p.DataManager:queueSpritesToCache({'_FRONT', 'Jirachi'}) -- for cry
				chatCn = _p.player.Chatted:connect(function(msg)
					if completedEvents.Jirachi then return end
					if _p.MasterControl.WalkEnabled and not _p.DataManager.isDay and msg:lower():match('^i%s+wish%s+%a') then
						local pp = Vector3.new(-865.212, 45, 53.745)
						local pos = _p.player.Character.HumanoidRootPart.Position - pp
						if pos.Y > 0 and pos.Y < 5 and math.sqrt(pos.X^2+pos.Z^2) < 3.5 then
							local jcf = jirachi.Main.CFrame
							Utilities.MoveModel(jirachi.Main, jcf + Vector3.new(0, -20, 0), true)
							jirachi.Parent = map
							_p.MusicManager:stackMusic(9542447894, 'Jirachi')
							network:post('Doc', 'wish', msg)
							chatCn:disconnect()
							chatCn = nil
							spawn(function() _p.Menu:disable() end)
							_p.MasterControl.WalkEnabled = false
							_p.MasterControl:Stop()
							spawn(function()
								_p.MasterControl:WalkTo(pp)
								_p.MasterControl:Look(Vector3.new(-1, 0, 0))
							end)
							--						completedEvents.Jirachi = true

							wait(1)
							local monument = map.Monument
							local mm = monument.Main
							local mcf = mm.CFrame
							workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
							spawn(function()
								Tween(1, nil, function(a)
									mm.CFrame = mcf * CFrame.new(0, 0, -.1 * a)
								end)
							end)
							Utilities.lookAt(mcf.p + Vector3.new(1, .3, 0).unit*10, mcf.p, 4)
				--[[
					-883.012, 49.9, 55.845 right of H
					-883.312, 48.5, 53.745 main
					 56.7 ; 50.7 -> 6
					 54.7 ; 52.9 -> 1.8
					 56.4 ; 50.9 -> 5.5
				--]]
							wait(.5)
							local sp = 4
							local glow = mm:Clone()
							glow.Material = Enum.Material.Neon
							glow.BrickColor = BrickColor.new('Cyan')
							glow.Parent = monument
							Tween(6.4/sp, nil, function(a)
								glow.Size = Vector3.new(6.4*a, 1.2, 0.8)
								glow.CFrame = mcf * CFrame.new(-3.2*(1-a), 1.4, 0)
							end)
							local glow2 = glow:Clone()
							glow2.Parent = monument
							Tween(2.2/sp, nil, function(a)
								glow2.Size = Vector3.new(2.2*a, 1.2, 0.8)
								glow2.CFrame = mcf * CFrame.new(-1.1*(1-a)-.1, 0, 0)
							end)
							local glow3 = glow:Clone()
							glow3.Parent = monument
							Tween(5.9/sp, nil, function(a)
								glow3.Size = Vector3.new(5.9*a, 1.2, 0.8)
								glow3.CFrame = mcf * CFrame.new(-2.95*(1-a)+.05, -1.4, 0)
							end)
							wait(2.5)
							Utilities.lookAt(mcf.p + Vector3.new(4, 1.8, 2).unit*30, mcf.p + Vector3.new(-5, 3, -5), 2)
							wait(1)
							local orb = create 'Part' {
								Material = Enum.Material.Neon,
								BrickColor = BrickColor.new('White'),
								Size = Vector3.new(5, 5, 5),
								Anchored = true,
								Parent = map,
								create 'SpecialMesh' {
									MeshType = Enum.MeshType.Sphere,
								}
							}
							delay(.5, function()
								Utilities.lookAt(mcf.p + Vector3.new(4, 0.9, 1.6).unit*25 + Vector3.new(0, 0, -5), mcf.p + Vector3.new(-5, 3, -3), 4)
							end)
							Tween(5, 'easeOutCubic', function(a)
								orb.CFrame = jcf + Vector3.new(-15 + 35*a, math.sin(a*math.pi)*5-5, 0)
							end)
							wait(1)
							Utilities.MoveModel(jirachi.Main, orb.CFrame + Vector3.new(0, -1, 0), true)
							Tween(2, 'easeOutCubic', function(a)
								orb.Transparency = a
							end)
							orb:remove()
							Sprite:playCry(1, _p.DataManager:getSprite('_FRONT', 'Jirachi').cry)
							wait(1)

							delay(3, function()
								jirachi:remove()
								jirachi = nil
								glow:remove()
								glow2:remove()
								glow3:remove()
							end)
							_p.MusicManager:popMusic('Jirachi', .5, true)
							_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Wish,{battleSceneType = 'Jirachi', musicId = 9537298254})
							chat:say('Jirachi can now be found roaming in the wild.')

							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()
							_p.Menu:enable()
						end
					end
				end)
			end

			map.Changed:connect(function()
				--			print('cleaning chunk')
				if not map.Parent then
					if chatCn then
						chatCn:disconnect()
						chatCn = nil
					end
					if jirachi then
						jirachi:remove()
						jirachi = nil
					end
				end
			end)
		end,

		onBeforeEnter_LeftoversHome = function(room)
			local guy = room.npcs.LeftoversGuy
			interact[guy.model] = function()
				if not completedEvents.GivenLeftovers then
					spawn(function() _p.PlayerData:completeEvent('GivenLeftovers') end)
					guy:Say('Oh hi.',
						'I was just about to throw out these leftovers.',
						'Your Pok[e\']mon look hungry, so I figure you can give it to them.',
						'Between you and me though, it\'s my wife\'s cooking so it may not be the best.')
					onObtainItemSound()
					chat:say('Obtained some Leftovers!', _p.PlayerData.trainerName .. ' put the Leftovers in the Bag.')
				end
				guy:Say('When Pok[e\']mon hold Leftovers in battle, they regain a little health at the end of every turn.')
			end
		end,

		onLoad_chunk15 = function(chunk)
			local model = chunk.map
			-- windmills
			local windmills = {}
			for _, m in pairs(model:GetChildren()) do
				if m.Name == 'Windmill' and m:IsA('Model') and m:FindFirstChild('Main') then
					local main = m.Main
					local mcf = main.CFrame
					local cfs = {}
					for _, p in pairs(m:GetChildren()) do
						if p:IsA('BasePart') and p ~= main then
							cfs[p] = mcf:toObjectSpace(p.CFrame)
						end
					end
					mcf = mcf * CFrame.Angles(0, math.pi*2*math.random(), 0)
					table.insert(windmills, {main, mcf, cfs})
				end
			end
			spawn(function()
				local st = tick()
				while model.Parent do
					stepped:wait()
					local et = tick()-st
					for _, w in pairs(windmills) do
						local cf = w[2] * CFrame.Angles(0, et, 0)
						w[1].CFrame = cf
						for p, rcf in pairs(w[3]) do
							p.CFrame = cf:toWorldSpace(rcf)
						end
					end
				end
			end)
			-- beekeeper
			local honeyData = _p.Network:get('PDS', 'getHoneyData')
			_p.PlayerData.honey = honeyData
			local beekeeper = chunk.npcs.Beekeeper
			interact[beekeeper.model] = function()
				if honeyData.canget then
					honeyData.canget = false
					honeyData.has = true
					spawn(function() _p.Network:get('PDS', 'getHoney') end)
					beekeeper:Say('Oh hello, I\'m a Combee keeper.',
						'I gather lots of honey from the local Combees.',
						'I have enough to share.',
						'Here, have some of my honey.')
					onObtainItemSound()
					chat:say('Obtained a Honey!', _p.PlayerData.trainerName .. ' put the Honey in the Bag.')
					beekeeper:Say('You can take that honey and slather it on the bark of this tree.',
						'If you come back later you may find it has attracted a hungry wild Pok[e\']mon.')
				else
					beekeeper:Say('I\'m out of honey handouts for today.',
						'Stop by tomorrow and I\'ll have some more for you.')
				end
			end
			-- honey tree
			if honeyData.status > 0 then pcall(function() model.HoneyTree.SlatheredHoney.Transparency = .2 end) end
			if honeyData.status == 2 then
				-- Teddiursa
				_p.DataManager:request({'Model', 'HoneyTeddiursa'}).Parent = model.HoneyTree
			elseif honeyData.status == 3 then
				-- Combee
				spawn(function()
					local o = CFrame.new(model.HoneyTree.SlatheredHoney.Position + Vector3.new(3, .75, 0))
					local bees = {  
						create 'Part' {
							BrickColor = BrickColor.new('Black'),
							Anchored = true,
							CanCollide = false,
							Size = Vector3.new(.2, .2, .2),
							TopSurface = Enum.SurfaceType.Smooth,
							BottomSurface = Enum.SurfaceType.Smooth,
							Parent = model,
						}
					}
					for i = 2, 3 do
						bees[i] = bees[1]:Clone()
						bees[i].Parent = model
					end
					local st = tick()
					local pd = _p.PlayerData
					local cos = math.cos
					local sin = math.sin
					local v3 = Vector3.new
					while honeyData.status == 3 do
						stepped:wait()
						local et = (tick()-st)*5
						bees[1].CFrame = o + v3(sin(et)*2, cos(et*3), cos(et)*2)
						bees[2].CFrame = o + v3(cos(et*1.2)*2, sin(et*1.2)*2, sin(et*1.2)*2)
						bees[3].CFrame = o + v3(sin(et*1.4)*2, -cos(et*1.4)*2, cos(et*1.4)*2)
					end
					for _, bee in pairs(bees) do
						bee:remove()
					end
				end)
			end
			-- absol cutscene
			if completedEvents.MeetAbsol then
				model.Absol:remove()
				chunk.npcs.Jake:remove()
				chunk.npcs.Tess:remove()
			else
				_p.DataManager:queueSpritesToCache({'_FRONT', 'Absol'}) -- for the cry
				_p.DataManager:preloadModule('AnchoredRig')
				touchEvent('MeetAbsol', model.AbsolTrigger, true, function()
					_p.MasterControl.WalkEnabled = false
					_p.RunningShoes:disable()
					spawn(function() _p.Menu:disable() end)

					local absol = model.Absol
					local rig = _p.DataManager:loadModule('AnchoredRig'):new(absol)
					rig:connect(absol, absol.Body)
					rig:connect(absol.Body, absol.Head)
					rig:connect(absol.Body, absol.Tail)
					rig:connect(absol.Body, absol.RFU)
					rig:connect(absol.RFU,  absol.RFL)
					rig:connect(absol.Body, absol.LFU)
					rig:connect(absol.LFU,  absol.LFL)
					rig:connect(absol.Body, absol.RRU)
					rig:connect(absol.RRU,  absol.RRL)
					rig:connect(absol.Body, absol.LRU)
					rig:connect(absol.LRU,  absol.LRL)
					rig:connect(absol.Body, absol.Necklace)

					local root = _p.player.Character.HumanoidRootPart
					local walking = true
					spawn(function()
						root.CFrame = CFrame.new(Vector3.new(679.3, 100.2, 70), Vector3.new(679.3, 100.2, 43))
						_p.MasterControl:WalkTo(Vector3.new(679.3, 98, 43))
						walking = false
					end)

					local cam = workspace.CurrentCamera
					cam.CameraType = Enum.CameraType.Scriptable
					local head = _p.player.Character.Head


					-- character walks; Absol appears, cries
					local posedRig = false
					local cried = false
					Tween(999, nil, function()
						local a = 1 - ((root.Position.Z - 46) / 27.6)
						if not posedRig and a >= .4 then
							posedRig = true
							rig:pose('Absol', CFrame.new(653.952, 117.74, 60.602) * CFrame.Angles(0, -0.87, 0))
						end
						if not cried and a >= .85 then
							cried = true
							local cry = _p.DataManager:getSprite('_FRONT', 'Absol').cry
							Sprite:playCry(.5, cry, .5)
						end
						if not walking then return false end

						cam.CFrame = CFrame.new(root.Position + Vector3.new(4.75, -.75, -5.75), head.Position + Vector3.new(0, 0, -3))
					end)
					_p.MasterControl:Stop()
					root.Anchored = true
					root.Velocity = Vector3.new()

					local main = absol.Main
					Utilities.exclaim(head)
					wait(.2)

					-- zoom in on Absol
					spawn(function() _p.MasterControl:LookAt(main.Position) end)
					local eyes = absol.Head.Eyes
					local cp = cam.CFrame.p
					local ep = eyes.Position-cp
					local sp = cam.CFrame.lookVector * (cp-eyes.Position).magnitude
					Tween(.8, 'easeOutCubic', function(a)
						cam.FieldOfView = 70 - 50*a
						cam.CFrame = CFrame.new(cp, cp + sp:Lerp(ep, a))
					end)

					wait(1)
					cam.FieldOfView = 70
					cam.CFrame = CFrame.new(main.Position + Vector3.new(-3, 14, 8), head.Position)

					-- Absol turns to face his jump
					wait(.2)
					local pos = function(x, y, z) return CFrame.new(x or 0, y or 0, z or 0) end
					local nul = pos()
					local rot = function(x, y, z) return CFrame.Angles(x or 0, y or 0, z or 0) end
					spawn(function()
						rig:poses(
							--name, cframe, duration, easing
							{'Body', rot(0, 0, .05), .2},
							{'LFU', rot(0, .2) * pos(0.1), .2, 'easeOutCubic'},
							{'RFU', rot(0, -.2) * pos(-0.1), .2, 'easeOutCubic'},
							{'RFL', rot(0, 0, .25), .2, 'sineBack'}
						)
						rig:poses(
							{'Body', nul, .2},
							{'LFU', nul, .2, 'easeOutCubic'},
							{'LFL', rot(0, 0, -.25), .2, 'sineBack'},
							{'RFU', nul, .2, 'easeOutCubic'}
						)
					end)
					local rootPos = root.Position
					local startPos = main.Position
					local jump2endPos = startPos + Vector3.new(-5, 0, 0)
					local endPos = Vector3.new(679.3, 97.31, rootPos.Z + 6.5)
					local startCF = main.CFrame

					local dir = endPos - startPos
					local theta = math.atan2(dir.X, dir.Z) - math.atan2(startCF.lookVector.X, startCF.lookVector.Z)
					Tween(.4, 'easeOutCubic', function(a)
						rig:pose('Absol', startCF * CFrame.Angles(0, theta*a, 0))
					end)
					startCF = main.CFrame

					-- Absol jumps
					spawn(function()
						local d1, d2 = .1, .9
						rig:poses(
							{'Body', rot(0, 0, .6), d1},
							{'LFU', rot(-.3), d1},
							{'RFU', rot(-.3), d1},
							{'LRU', rot(0, 0, -.5), d1},
							{'LRL', rot(0, 0, .35), d1},
							{'RRU', rot(0, 0, .4), d1}
						)
						rig:poses(
							{'Body', rot(0, 0, -.3), d2, 'easeInCubic'},
							{'LRU', rot(0, 0, .2), d2, 'easeInCubic'},
							{'LRL', nul, d2, 'easeInCubic'},
							{'RRU', rot(0, 0, -.2), d2, 'easeInCubic'}
						)
						rig:poses(
							{'Body', nul, .3},
							{'LFU', nul, .3},
							{'RFU', nul, .3},
							{'LRU', nul, .3},
							{'RRU', nul, .3}
						)
					end)
					local grav = -196.2
					local jumpDur = 1
					local dx = (endPos-startPos)*Vector3.new(1, 0, 1)
					local dy = endPos.Y - startPos.Y
					local vy0 = dy - (grav * jumpDur) / 2
					Tween(jumpDur, nil, function(a, t)
						rig:pose('Absol', startCF + dx*a + Vector3.new(0, vy0*t + .5*grav*t*t, 0))
						root.CFrame = CFrame.new(rootPos, Vector3.new(main.Position.X, rootPos.Y, main.Position.Z))
					end)
					wait(.5)

					local focus = eyes.Position + Vector3.new(-2, 0, -2)
					cam.CFrame = CFrame.new(head.Position + Vector3.new(8, -1, 1), focus)
					wait(.2)

					-- Absol turns to face player
					local rigCF = main.CFrame
					local theta, lerp = Utilities.lerpCFrame(rigCF, CFrame.new(rigCF.p, Vector3.new(root.Position.X, rigCF.p.Y, root.Position.Z)))
					spawn(function()
						local d = theta*.15
						rig:poses(
							{'Body', rot(0, 0, .05), d},
							{'LFU', rot(0, .2) * pos(0.1), d, 'easeOutCubic'},
							{'LFL', rot(0, 0, .25), d, 'sineBack'},
							{'RFU', rot(0, -.2) * pos(-0.1), d, 'easeOutCubic'}
						)
						rig:poses(
							{'Body', nul, d},
							{'LFU', nul, d, 'easeOutCubic'},
							{'RFU', nul, d, 'easeOutCubic'},
							{'RFL', rot(0, 0, -.25), d, 'sineBack'}
						)
					end)
					Tween(theta*.3, 'easeOutCubic', function(a)
						rig:pose('Absol', lerp(a))
					end)

					-- Absol sniffs character
					wait(.9)
					eyes.EyesOpen.Face = Enum.NormalId.Left
					spawn(function() rig:pose('Body', pos(1), 2, 'easeInOutCubic') end)
					spawn(function()
						local ease = nil
						rig:poses(
							{'RFU', rot(.3), 1, ease},
							{'RFL', rot(0, -.3), 1, ease},
							{'LFU', rot(-.3), 1, ease},
							{'LFL', rot(0, .3), 1, ease},
							{'RRU', rot(0, 0, .3), 1, ease},
							{'RRL', rot(0, 0, .3), 1, ease},
							{'LRU', rot(0, 0, -.3), 1, ease},
							{'LRL', rot(0, 0, -.3), 1, ease}
						)
						rig:poses(
							{'RFU', nul, 1, ease},
							{'RFL', nul, 1, ease},
							{'LFU', nul, 1, ease},
							{'LFL', nul, 1, ease},
							{'RRU', nul, 1, ease},
							{'RRL', nul, 1, ease},
							{'LRU', nul, 1, ease},
							{'LRL', nul, 1, ease}
						)
					end)
					rig:poses({'Head', rot(.5), .5, 'easeOutCubic'},
					{'Necklace', pos(0, -.4, -.25), .5, 'easeOutCubic'})
					for i = 1, 2 do
						rig:poses({'Head', rot(.3), 1, 'sineBack'},
						{'Necklace', pos(0, -.175, -.1), 1, 'sineBack'})
					end
					wait(.3)

					-- Jake and Tess appear
					delay(.25, function()
						eyes.EyesOpen.Face = Enum.NormalId.Right
						rig:poses({'Head', nul, .2, 'easeOutCubic'},
						{'Necklace', nul, .2, 'easeOutCubic'})
					end)
					spawn(function() Utilities.exclaim(head) end)
					spawn(function() Utilities.exclaim(eyes) end)
					chat:say(_p.PlayerData.trainerName .. '!')

					local npcsWalking = true
					local jake = chunk.npcs.Jake
					local tess = chunk.npcs.Tess
					spawn(function()
						local tp = Vector3.new(688.2, 100.2, 86)
						local jp = Vector3.new(693.4, 100.2, 88.4)
						tess:Teleport(CFrame.new(tp, tp + Vector3.new(0, 0, -1)))
						jake:Teleport(CFrame.new(jp, jp + Vector3.new(0, 0, -1)))
						Utilities.Sync {
							function()
								tess:WalkTo(tp + Vector3.new(-6, 0, -20))
								Utilities.exclaim(tess.model.Head)
							end,
							function()
								jake:WalkTo(jp + Vector3.new(-6, 0, -20))
								Utilities.exclaim(jake.model.Head)
							end,
						}
						npcsWalking = false

					end)

					local osp = cam.CFrame.p
					local oep = head.Position + Vector3.new(4, -1, -3)
					Tween(.5, 'easeOutCubic', function(a)
						cam.CFrame = CFrame.new(osp:Lerp(oep, a), focus + Vector3.new(2*a, 0, 2*a))
					end)
					wait(.25)

					-- Absol turns to look at Jake and Tess
					local jakeRoot = jake.model.HumanoidRootPart
					rigCF = main.CFrame
					theta, lerp = Utilities.lerpCFrame(rigCF, CFrame.new(rigCF.p, Vector3.new(jakeRoot.Position.X, rigCF.p.Y, jakeRoot.Position.Z)))
					spawn(function()
						local d = theta*.15
						rig:poses(
							{'Body', rot(0, 0, .05), d},
							{'LFU', rot(0, .2) * pos(0.1), d, 'easeOutCubic'},
							{'RFU', rot(0, -.2) * pos(-0.1), d, 'easeOutCubic'},
							{'RFL', rot(0, 0, .25), d, 'sineBack'}
						)
						rig:poses(
							{'Body', nul, d},
							{'LFU', nul, d, 'easeOutCubic'},
							{'LFL', rot(0, 0, -.25), d, 'sineBack'},
							{'RFU', nul, d, 'easeOutCubic'}
						)
					end)
					Tween(theta*.3, 'easeOutCubic', function(a)
						rig:pose('Absol', lerp(a))
					end)

					-- Absol turns to face leaving jump
					repeat wait() until not npcsWalking
					wait(.5)
					rigCF = main.CFrame
					theta, lerp = Utilities.lerpCFrame(rigCF, CFrame.new(rigCF.p, Vector3.new(jump2endPos.X, rigCF.p.Y, jump2endPos.Z)))
					spawn(function()
						local d = theta*.15
						rig:poses(
							{'Body', rot(0, 0, .05), d},
							{'LFU', rot(0, .2) * pos(0.1), d, 'easeOutCubic'},
							{'RFU', rot(0, -.2) * pos(-0.1), d, 'easeOutCubic'},
							{'RFL', rot(0, 0, .25), d, 'sineBack'}
						)
						rig:poses(
							{'Body', nul, d},
							{'LFU', nul, d, 'easeOutCubic'},
							{'LFL', rot(0, 0, -.25), d, 'sineBack'},
							{'RFU', nul, d, 'easeOutCubic'}
						)
					end)
					Tween(theta*.3, 'easeOutCubic', function(a)
						rig:pose('Absol', lerp(a))
					end)

					-- Absol's second jump
					spawn(function()
						local d1, d2 = .1, .9
						rig:poses(
							{'Body', rot(0, 0, .6), d1},
							{'LFU', rot(-.3), d1},
							{'RFU', rot(-.3), d1},
							{'LRU', rot(0, 0, -.5), d1},
							{'LRL', rot(0, 0, .35), d1},
							{'RRU', rot(0, 0, .4), d1}
						)
						rig:poses(
							{'Body', rot(0, 0, -.3), d2, 'easeInCubic'},
							{'LRU', rot(0, 0, .2), d2, 'easeInCubic'},
							{'LRL', nul, d2, 'easeInCubic'},
							{'RRU', rot(0, 0, -.2), d2, 'easeInCubic'}
						)
					end)
					local jrp = jakeRoot.Position
					local tessRoot = tess.model.HumanoidRootPart
					local trp = tessRoot.Position
					startCF = main.CFrame
					startPos = main.Position
					endPos = jump2endPos
					jumpDur = 1
					dx = (endPos-startPos)*Vector3.new(1, 0, 1)
					dy = Vector3.new(0, endPos.Y - startPos.Y, 0)
					spawn(function() jake:LookAt(endPos) end)
					spawn(function() tess:LookAt(endPos) end)
					Tween(jumpDur, nil, function(a)
						rig:pose('Absol', startCF + dx*(1-math.cos(a*math.pi)) + dy*math.sin(a*math.pi))
						local mp = main.Position
						root.CFrame = CFrame.new(rootPos, Vector3.new(mp.X, rootPos.Y, mp.Z))
					end)
					wait(1)
					rig:remove()
					absol:remove()

					-- conversation
					local pp = root.Position
					local tp = pp + Vector3.new(-1, 0, 6)
					local jp = pp + Vector3.new(4, 0, 6)
					local mp = (tp + jp)/2

					Utilities.Sync {
						function() _p.MasterControl:LookAt(mp) end,
						function() tess:WalkTo(tp) spawn(function() tess:LookAt(pp) end) end,
						function() jake:WalkTo(jp) spawn(function() jake:LookAt(pp) end) end,
						function()
							osp = oep
							oep = oep + Vector3.new(0, 4, 0)
							focus = focus + Vector3.new(2, 0, 2)
							Tween(1.5, 'easeOutCubic', function(a)
								cam.CFrame = CFrame.new(osp:Lerp(oep, a), focus:Lerp(mp, a))
							end)
						end
					}
					tess:Say('What Pok[e\']mon was that, '.._p.PlayerData.trainerName..', and why did it run off?')
					spawn(function() jake:LookAt(tp) end)
					spawn(function() tess:LookAt(jp) end)
					jake:Say('I think I might know what it was.')
					spawn(function() jake:LookAt(pp) end)
					jake:Say('My father used to tell me of a Pok[e\']mon that looked exactly like that one.',
						'It\'s called Absol.')
					spawn(function() jake:LookAt(tp) end)
					tess:Say('Absol?', 'You mean Absol the Disaster Pok[e\']mon?')
					jake:Say('Yeah, that\'s the one.')
					spawn(function() jake:LookAt(pp) end)
					jake:Say('Legends say that wherever Absol goes, a disaster will surely follow.',
						'It appears only to warn those who are in danger.')
					spawn(function() jake:LookAt(tp) end)
					jake:Say('If one has appeared here, it can\'t be a good sign.')
					tess:Say('Certainly not.',
						'That worries me a little.')
					jake:Say('I don\'t know what is more strange--the appearance of an Absol, or the keen interest it took in '.._p.PlayerData.trainerName..'.')
					tess:Say('That was very interesting indeed.')
					spawn(function() tess:LookAt(pp) end)
					tess:Say('I almost thought you were being attacked.')
					spawn(function() jake:LookAt(pp) end)
					spawn(function() tess:LookAt(jp) end)
					jake:Say('Well, at least everyone\'s alright.')
					spawn(function() jake:LookAt(tp) end)
					tess:Say('Right, and we\'re all back together now too.')
					spawn(function() jake:LookAt(pp) end)
					jake:Say('Alright, so this is Route 10.',
						'If we continue on this path, we\'ll reach the entrance to the Cragonos Mines.',
						'You just follow the mine to the top of the mountain, where we\'ll catch a ride to Anthian City.')
					spawn(function() jake:LookAt(tp) end)
					tess:Say('Caves are kinda scary, though.',
						'I\'d much rather take the sky train up to the top.')
					jake:Say('The lady in the gate we just came through told me the sky train isn\'t working right now.',
						'Don\'t worry, I will lead you safely through the mine.',
						'I hiked through here with my father once.')
					tess:Say('Oh, I suppose that sounds alright.',
						'But if we run into any Zubats or Woobats or any other oo-bats, I don\'t know what I\'ll do.')
					spawn(function() jake:LookAt(pp) end)
					spawn(function() tess:LookAt(pp) end)
					jake:Say('Alright '.._p.PlayerData.trainerName..', we\'re heading through the mine now.',
						'We\'ll rendezvous at the top where we all ride together to Anthian City.',
						'Have fun and good luck!')
					tess:Say('Seeya at the top, '.._p.PlayerData.trainerName..'!')

					spawn(function()
						jake:WalkTo(pp + Vector3.new(5, 0, 0))
						jake:WalkTo(pp + Vector3.new(5, 0, -10))
					end)
					tess:WalkTo(pp + Vector3.new(-5, 0, 0))
					tess:WalkTo(pp + Vector3.new(-5, 0, -10))
					tess:remove()
					jake:remove()

					root.Anchored = false

					Utilities.lookBackAtMe()
					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
				end)
			end
		end,

		onBeforeEnter_CableCars = function(room) -- can be route 10 OR route 11
			local has = _p.Network:get('PDS', 'hasSTP')
			local guide = room.npcs.CarGuide
			interact[guide.model] = function()
				guide:Say('Welcome to the Sky Train!',
					'May I see your Sky Train Pass?')
				if not has then
					guide:Say('You need a Sky Train Pass to ride.')
					return
				end
				spawn(function() _p.Menu:disable() end)
				local destination
				local chunk = _p.DataManager.currentChunk
				local choice
				if chunk.id == 'chunk15' then
					guide:Say('Great! Would you like to ride to Cragonos Peak, or straight through to Route 11?')
					choice = chat:choose('Cragonos Peak', 'Route 11', 'Cancel')
					destination = choice==1 and 'chunk18' or 'chunk24'
				else
					guide:Say('Great! Would you like to ride to Cragonos Peak, or straight through to Route 10?')
					choice = chat:choose('Cragonos Peak', 'Route 10', 'Cancel')
					destination = choice==1 and 'chunk18' or 'chunk15'
				end
				if choice == 3 then
					guide:Say('Oh, well come back if you\'d like to ride the Sky Train!')
					spawn(function() _p.Menu:enable() end)
					return
				end
				local gp = guide.model.HumanoidRootPart.Position
				spawn(function()
					guide:WalkTo(gp + Vector3.new(4, 0, 0))
					guide:Look(Vector3.new(-1, 0, 0))
				end)
				wait(.4)
				room.model.Barrier.CanCollide = false
				_p.MasterControl:WalkTo(room.model.Barrier.Position)
				_p.MasterControl:WalkTo(room.basePosition + Vector3.new(0, 14, 22))
				chunk:unbindIndoorCam()
				_p.MasterControl:WalkTo(room.basePosition + Vector3.new(-8, 14, 22))
				Utilities.FadeOut(1)
				wait()
				Utilities.TeleportToSpawnBox()
				chunk:remove()
				chunk = _p.DataManager:loadMap(destination)
				chunk.indoors = true
				local roomName = choice==1 and 'CableCarPeak' or 'CableCars'
				local room = chunk:getRoom(roomName, chunk:getDoor(roomName), 1)
				chunk.roomStack = {room}
				_p.Events['onBeforeEnter_'..roomName](room)
				chunk:bindIndoorCam()
				local offset = choice==1 and Vector3.new(-11.7, 23.7, 1) or Vector3.new(0, 16.5, -4)
				Utilities.Teleport(CFrame.new(room.basePosition + offset))
				wait()
				Utilities.FadeIn(1)
				spawn(function() _p.Menu:enable() end)
			end
		end,
		onBeforeEnter_CableCarPeak = function(room) -- peaks only
			local has = _p.Network:get('PDS', 'hasSTP')
			local guide = room.npcs.CarGuide
			interact[guide.model] = function()
				guide:Say('Welcome to the Sky Train!',
					'May I see your Sky Train Pass?')
				if not has then
					guide:Say('You need a Sky Train Pass to ride.')
					return
				end
				spawn(function() _p.Menu:disable() end)
				guide:Say('Great! Which side of the mountain would you like to ride down?')
				local c = chat:choose('Route 10', 'Route 11', 'Cancel')
				if c == 3 then
					guide:Say('Return any time you\'d like to ride the Sky Train!')
					spawn(function() _p.Menu:enable() end)
					return
				end
				local gp = guide.model.HumanoidRootPart.Position
				local pp = _p.player.Character.HumanoidRootPart.Position
				spawn(function()
					guide:WalkTo(gp + Vector3.new(3, 0, pp.Z > gp.Z and -3 or 3))
					guide:LookAt(gp)
				end)
				wait(.4)
				room.model.RideDoor.CanCollide = false
				_p.MasterControl:WalkTo(gp)
				_p.MasterControl:WalkTo(room.basePosition + Vector3.new(-27.6, 23, 0))
				_p.MusicManager:popMusic('all', 1)
				Utilities.FadeOut(1)
				wait()
				local chunk = _p.DataManager.currentChunk
				chunk:unbindIndoorCam()
				Utilities.TeleportToSpawnBox()
				chunk:remove()
				wait()
				chunk = _p.DataManager:loadMap(c==1 and 'chunk15' or 'chunk24')
				chunk.indoors = true
				local room = chunk:getRoom('CableCars', chunk:getDoor('CableCars'), 1)
				chunk.roomStack = {room}
				_p.Events.onBeforeEnter_CableCars(room)
				chunk:bindIndoorCam()
				Utilities.Teleport(CFrame.new(room.basePosition + Vector3.new(0, 16.5, -4)))
				wait()
				Utilities.FadeIn(1)
				spawn(function() _p.Menu:enable() end)
			end
		end,

		onBeforeEnter_DrifloonWindmill = function(room)
			if not _p.Network:get('PDS', 'isDinWM') then
				room.model.Drifloon:remove()
			end
		end,

		onLoad_chunk17 = function(chunk)
			_p.PlayerData:completeEvent('ReachCliffPC')
		end,

		onLoad_chunk18 = function(chunk)
			local map = chunk.map
			local blimpDoor = map.BlimpDoor
			local blimpBridgeParts = {}
			for _, p in pairs(map.BlimpBridge:GetChildren()) do
				if p:IsA('BasePart') then
					blimpBridgeParts[p] = p.CFrame
				end
			end
			-- blimp setup
--[[
local blimp = map.Blimp
local blimpEngine = blimp.Main
local blimpCFrame = blimpEngine.CFrame
local blimpWelds = {}
local function weld(p0,p1)return create'Weld'{Part0=p0,Part1=p1,C0=p0.CFrame:toObjectSpace(p1.CFrame),Parent=p0}end
for _, m in pairs(blimp:GetChildren()) do
	if m:IsA('Model') then
		local main = m:FindFirstChild('Main')
		if main then
			for _, ch in pairs(m:GetChildren()) do
				if ch ~= main and ch:IsA('BasePart') then
					weld(main, ch)
					ch.Anchored = false
				end
			end
			blimpWelds[m.Name] = weld(blimpEngine, main)
			main.Anchored = false
		else
			for _, ch in pairs(m:GetChildren()) do
				if ch:IsA('BasePart') then
					weld(blimpEngine, ch)
					ch.Anchored = false
				end
			end
		end
	end
end
local anchorPoint = create 'Part' {
	Anchored = false,
	CanCollide = false,
	Transparency = 1,
	Size = blimpEngine.Size,
	CFrame = blimpCFrame,
	Parent = map,
	create 'BodyPosition' {
		Position = blimpCFrame.p,
		MaxForce = Vector3.new(math.huge, math.huge, math.huge),
	},
	create 'BodyGyro' {
		CFrame = blimpCFrame,
		MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
	}
}
local blimpWeld = create 'Weld' {
	Part0 = anchorPoint,
	Part1 = blimpEngine,
	C0 = CFrame.new(),
	C1 = CFrame.new(),
	Parent = anchorPoint
}
blimpEngine.Anchored = false
local apci = blimpCFrame:inverse()
spawn(function()
--				blimpEngine.Anchored = false
	while map.Parent do
		blimpWeld.C0 = apci * (blimpCFrame + Vector3.new(0, math.cos(tick())*.8, 0))
--				blimpEngine.Anchored = false
--				blimpEngine.CFrame = blimpCFrame + Vector3.new(0, math.cos(tick())*.8, 0)
--				blimpEngine.Anchored = true
		stepped:wait()
	end
end)--]]
			--
			local pilot = chunk.npcs.Imaginaerum
			local jake = chunk.npcs.Jake
			local tess = chunk.npcs.Tess
			local function rideBlimp(isFirstTime)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				spawn(function() Utilities.lookAt(CFrame.new(-1583.89429, 147.553986, -302.987915, 0.247560412, -0.471010149, 0.84667778, -0, 0.873879552, 0.486142516, -0.968872547, -0.120349638, 0.216337949)) end)

				blimpDoor.CanCollide = false

				--			local pWeld
				local function startEngines()
		--[[
		local maxv = 10
		local a = 2
		local v = 0
		local r = 0
		local lt = tick()
		local flying = true
		while flying do
			local n = tick()
			local dt = n-lt
			lt = n
			v = math.min(maxv, v + a*dt)
			r = r + v*dt
			local cf = CFrame.Angles(0, r*1.5, 0)
			for _, weld in pairs(blimpWelds) do
				weld.C1 = cf
			end
			if v > 2 then
				if not pWeld then
					Utilities.getHumanoid():SetStateEnabled(Enum.HumanoidStateType.Freefall , false)
					pWeld = weld(blimpEngine, _p.player.Character.HumanoidRootPart)
					weld(blimpEngine, pilot.model.HumanoidRootPart)
					if tess then weld(blimpEngine, tess.model.HumanoidRootPart) end
					if jake then weld(blimpEngine, jake.model.HumanoidRootPart) end
					delay(5, function()--]]
					_p.MusicManager:popMusic('RegionMusic', .5, true)
					Utilities.FadeOut(.5)
					local startTick = tick()
					--								flying = false
					--								pWeld:remove()
					Utilities.TeleportToSpawnBox()
					chunk:remove()
					-- change chunks
					_p.DataManager:loadMap('chunk19', {firstTime = isFirstTime, viaBlimp = true})
					if not isFirstTime then
						workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
						Utilities.Teleport(CFrame.new(-2707.602, 260.614, 2745.94))
						local elapsed = tick()-startTick
						if elapsed < .5 then
							wait(.5-elapsed)
						end
						Utilities.FadeIn(.5)

						-- re-enable stuff
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						_p.RunningShoes:enable()
						_p.Menu:enable()
					end--[[
					end)
				end
				blimpCFrame = blimpCFrame + Vector3.new(0, 0, (v-2)/2*dt)
			end
			stepped:wait()
		end--]]
				end

				local angles = {math.pi*3/4}
				if jake then angles[#angles+1] = math.pi/2 end
				if tess then angles[#angles+1] = math.pi/4 end
				local function board(character, root)
					spawn(function()
						if not root then root = character.model.HumanoidRootPart end
						character:WalkTo(Vector3.new(-1590, 127, -310))
						spawn(function()
							while root.Position.X > -1617 do wait() end
							if character == _p.MasterControl then
								_p.MasterControl:SetJumpEnabled(true)
								_p.MasterControl:ForceJump()
								delay(.5, function() _p.MasterControl:SetJumpEnabled(false) end)
							else
								character:Jump()
							end
						end)
						character:WalkTo(Vector3.new(-1621, 120, -310))
						if character == pilot then
							character:WalkTo(Vector3.new(-1626, 120, -366))
							startEngines()
						else
							local angle = table.remove(angles, 1)
							character:WalkTo(Vector3.new(-1621-math.sin(angle)*5, 120, -310-math.cos(angle)*5))
							character:LookAt(Vector3.new(-1621, 120, -310))
						end
					end)
				end

				local root = _p.player.Character.HumanoidRootPart
				local proot = pilot.model.HumanoidRootPart
				if root.Position.X < proot.Position.X  and root.Position.Z > proot.Position.Z then
					_p.MasterControl:WalkTo(proot.Position + Vector3.new(3, 0, 3))
				end
				board(pilot)
				wait(.4)
				board(_p.MasterControl, root)
				if tess then
					wait(.4)
					board(tess)
				end
				if jake then
					wait(.4)
					board(jake)
				end

				while #angles > 0 do wait() end

				Tween(3, 'easeInOutCubic', function(a, t)
					for p, cf in pairs(blimpBridgeParts) do
						p.CFrame = cf + Vector3.new(23*a, math.sin(t*50)*.1, 0)
					end
				end)
			end
			if completedEvents.BlimpwJT then
				jake:remove()
				tess:remove()
				jake, tess = nil, nil

				interact[pilot.model] = function()
					if not pilot:Say('[y/n]Would you like a ride to Anthian City?') then
						pilot:Say('I\'ll be waiting here if you change your mind.')
						return
					end
					_p.MasterControl.WalkEnabled = false
					_p.RunningShoes:disable()
					spawn(function() _p.Menu:disable() end)
					pilot:Say('Let\'s go!')
					rideBlimp(false)
				end
			else
				touchEvent('BlimpwJT', map.BlimpButton, true, function()
					_p.MasterControl.WalkEnabled = false
					_p.RunningShoes:disable()
					spawn(function() _p.Menu:disable() end)

					local jp = jake.model.HumanoidRootPart.Position
					local tp = tess.model.HumanoidRootPart.Position
					local pp = Vector3.new(-1581.5, 128, -309)

					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					spawn(function() Utilities.lookAt(pp + Vector3.new(5, 10, -8), (jp + tp)/2) end)
					_p.MasterControl:WalkTo(Vector3.new(-1574.5, 128, -309.6))
					_p.MasterControl:WalkTo(pp)

					spawn(function() tess:LookAt(pp) end)
					spawn(function() jake:LookAt(pp) end)
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('Awesome, looks like we\'re all here!')
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:Say('Let\'s board the airship already!')
					spawn(function() _p.MasterControl:LookAt(tp) end)
					if tess:Say('Why the puzzled look, '.._p.PlayerData.trainerName..'?',
						'[y/n]You do know where Anthian City is, right?') then
						spawn(function() jake:LookAt(tp) end)
						spawn(function() tess:LookAt(jp) end)
						spawn(function() _p.MasterControl:LookAt(jp) end)
						jake:Say('How could anyone not?', 'It\'s a huge city floating above the center of Roria.',
							'Those who haven\'t been have at least heard stories about it all their lives...')
						spawn(function() tess:LookAt(pp) end)
						spawn(function() jake:LookAt(pp) end)
					else
						spawn(function() _p.MasterControl:LookAt(jp) end)
						jake:Say('Seriously?!', 'It\'s the huge city floating above the center of Roria.',
							'We\'ve heard stories about it all our lives...')
					end
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('It\'s an astounding demonstration of where science has gotten us today.',
						'The whole city is supported by a power core that never runs dry.', 'It\'s incredible!')
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:Say('There\'s a gym there too!')
					spawn(function() _p.MasterControl:LookAt(tp) end)
					spawn(function() tess:LookAt(jp) end)
					tess:Say('Right, but the first thing we\'ll need to do is go speak with my father\'s old friend.')
					spawn(function() tess:LookAt(pp) end)
					spawn(function() jake:LookAt(tp) end)
					tess:Say('His name is Gerald.',
						'He\'s the only person aside from my grandfather that I know, that also knew my parents.',
						'I haven\'t seen him for a while, but I know he works at the Pok[e\'] Ball shop in Anthian City\'s Shopping District.',
						'Once we arrive in Anthian City, we\'ll need to go see him as soon as possible.',
						'He knows and talks with a lot of people from all over Roria.',
						'If anyone can tell us anything about Team Eclipse and your parents, he can.')
					spawn(function() tess:LookAt(jp) end)
					jake:Say('Yeah that\'s really a good idea.')
					spawn(function() jake:LookAt(pp) end)
					jake:Say('If Gerald can give us any information at all, we\'ll be that much closer to saving your parents, '.._p.PlayerData.trainerName..'!')
					tess:Say('Exactly, so let\'s not waste any more time.')
					local pilotpos = pilot.model.HumanoidRootPart.Position
					spawn(function() Utilities.lookAt(pp + Vector3.new(8, 10, 8), pilotpos + Vector3.new(0, 5, 0)) end)
					spawn(function() tess:LookAt(pilotpos) end)
					tess:Say('Alright, pilot.',
						'We\'re ready to go!')
					pilot:Say('All aboard!')

					rideBlimp(true)
				end)
			end
		end,
		

		
		onLoad_chunk19 = function(chunk, d) -- ANTHIAN: HOUSING
			local map = chunk.map
			local blimpDoor = map.BlimpDoor
--[[
local blimpBridgeParts = {}
local blimpBridgeMain = map.BlimpBridge.Main
local bbcf = blimpBridgeMain.CFrame
for _, p in pairs(map.BlimpBridge:GetChildren()) do
	if p:IsA('BasePart') then
		blimpBridgeParts[p] = bbcf:toObjectSpace(p.CFrame)
	end
end
local function transformBridge(t)
	local cf = bbcf * t
	blimpBridgeMain.CFrame = cf
	for p, rcf in pairs(blimpBridgeParts) do
		p.CFrame = cf:toWorldSpace(rcf)
	end
end
local blimpDocked = true
-- blimp setup
local blimp = map.Blimp
local blimpEngine = blimp.Main
local blimpCFrame = blimpEngine.CFrame
local blimpWelds = {}
local function weld(p0,p1)return create'Weld'{Part0=p0,Part1=p1,C0=p0.CFrame:toObjectSpace(p1.CFrame),Parent=p0}end
for _, m in pairs(blimp:GetChildren()) do
	if m:IsA('Model') then
		local main = m:FindFirstChild('Main')
		if main then
			for _, ch in pairs(m:GetChildren()) do
				if ch ~= main and ch:IsA('BasePart') then
					weld(main, ch)
					ch.Anchored = false
				end
			end
			blimpWelds[m.Name] = weld(blimpEngine, main)
			main.Anchored = false
		else
			for _, ch in pairs(m:GetChildren()) do
				if ch:IsA('BasePart') then
					weld(blimpEngine, ch)
					ch.Anchored = false
				end
			end
		end
	end
end
local anchorPoint = create 'Part' {
	Anchored = false,
	CanCollide = false,
	Transparency = 1,
	Size = blimpEngine.Size,
	CFrame = blimpCFrame,
	Parent = map,
	create 'BodyPosition' {
		Position = blimpCFrame.p,
		MaxForce = Vector3.new(math.huge, math.huge, math.huge),
	},
	create 'BodyGyro' {
		CFrame = blimpCFrame,
		MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
	}
}
local blimpWeld = create 'Weld' {
	Part0 = anchorPoint,
	Part1 = blimpEngine,
	C0 = CFrame.new(),
	C1 = CFrame.new(),
	Parent = anchorPoint
}
blimpEngine.Anchored = false
local apci = blimpCFrame:inverse()
spawn(function()
--				blimpEngine.Anchored = false
	local cos = math.cos
	local rot = CFrame.Angles
	game:GetService('RunService'):BindToRenderStep('MoveBlimp', 0, function()
		if not map.Parent then
			game:GetService('RunService'):UnbindFromRenderStep('MoveBlimp')
			return
		end
		local a = cos(tick())
		blimpWeld.C0 = apci * (blimpCFrame + Vector3.new(0, math.cos(tick())*.8, 0))
--				blimpEngine.Anchored = false
--				blimpEngine.CFrame = blimpCFrame + Vector3.new(0, a*.8, 0)
--				blimpEngine.Anchored = true
		if blimpDocked then
			transformBridge(rot(0, a*-.06, 0))
		end
	end)
end)--]]
			-- Eclipse grunts
			if _p.PlayerData.badges[4] and not completedEvents.DefeatTEinAC then
				for _, door in pairs(chunk.doors) do
					if door.id == 'Museum' then -- recall that there are two
						door.locked = true
					end
				end
			else
				chunk.npcs.EclipseGrunt1:remove()
				chunk.npcs.EclipseGrunt2:remove()
			end
			--
			local pilot = chunk.npcs.Imaginaerum
			local jake = chunk.npcs.Jake
			local tess = chunk.npcs.Tess
			if not d or not d.firstTime then
				jake:remove()
				tess:remove()
				jake, tess = nil, nil
			end
			if d and d.viaBlimp then
				wait()
	--[[
	blimpDocked = false
	transformBridge(CFrame.Angles(0, -math.pi*.4, 0))
	local st = tick()
	local pRoot, jRoot, tRoot = _p.player.Character.HumanoidRootPart, (jake and jake.model.HumanoidRootPart), (tess and tess.model.HumanoidRootPart)
	local jp, tp = (jRoot and jRoot.Position), (tRoot and tRoot.Position)
	
	local reverse = CFrame.Angles(0, math.pi, 0)
	pRoot.CFrame = blimpEngine.CFrame * CFrame.new( 0, 15.4, 50) * reverse
	if jRoot then jRoot.CFrame = blimpEngine.CFrame * CFrame.new( 5, 15.4, 50) * reverse end
	if tRoot then tRoot.CFrame = blimpEngine.CFrame * CFrame.new(-5, 15.4, 50) * reverse end
	local cWelds = {
		          create 'Weld' { Part0 = blimpEngine, Part1 = pRoot, C0 = CFrame.new( 0, 15.4, 50) * reverse, Parent = blimpEngine },
		(jake and create 'Weld' { Part0 = blimpEngine, Part1 = jRoot, C0 = CFrame.new( 5, 15.4, 50) * reverse, Parent = blimpEngine }),
		(tess and create 'Weld' { Part0 = blimpEngine, Part1 = tRoot, C0 = CFrame.new(-5, 15.4, 50) * reverse, Parent = blimpEngine }),
	}
	local obcf = blimpCFrame
	blimpCFrame = obcf * CFrame.new(0, 0, -150)
	local cam = workspace.CurrentCamera
	wait(1.5)
	
	spawn(function() Utilities.FadeIn(.5) end)
	local pOffset = Vector3.new(11, 20, 35)
	local fOffset = Vector3.new(0, 21, 50)
	if d.firstTime then
		delay(1, function() tess:Say('[ma]We\'re getting close!') end)
		delay(3, function()
			chat:manualAdvance()
			wait(1.5)
			Utilities.FadeOut(.5)
		end)
	else
		delay(4.5, function() Utilities.FadeOut(.5) end)
	end
	Tween(5, nil, function(a)
		blimpCFrame = obcf * CFrame.new(0, 0, -150+50*a)
		cam.CFrame = CFrame.new(blimpEngine.CFrame * pOffset, blimpEngine.CFrame * fOffset)
	end, 205)
	for _, w in pairs(cWelds) do pcall(function() w:remove() end) end
	
	wait()
	blimpCFrame = obcf
	blimpDocked = true
	--]]
				--
				local cam = workspace.CurrentCamera
				local pRoot, jRoot, tRoot = _p.player.Character.HumanoidRootPart, (jake and jake.model.HumanoidRootPart), (tess and tess.model.HumanoidRootPart)
				local jp, tp = (jRoot and jRoot.Position), (tRoot and tRoot.Position)
				--
				cam.CameraType = Enum.CameraType.Custom
				local ap = Vector3.new(-2685, 268, 2450)
				local pp = Vector3.new(-2707.6, 260.6, 2746)
				--			Utilities.getHumanoid():SetStateEnabled(Enum.HumanoidStateType.Freefall , true)
				Utilities.Teleport(CFrame.new(pp, ap))
				if jake then jake:Teleport(CFrame.new(jp, ap)) end
				if tess then tess:Teleport(CFrame.new(tp, ap)) end
				cam.CFrame = CFrame.new(pp + Vector3.new(-5, 7, 10), pp + Vector3.new(0, 1.5, 0))
				wait(.5)
				Utilities.FadeIn(.5)

				if d.firstTime then
					wait(.5)
					jake:Say('We\'ve finally made it!',
						'Anthian City.',
						'What a beautiful place!')
					spawn(function() jake:LookAt(tp) end)
					jake:Say('Where should we go first?')
					spawn(function() tess:LookAt(jp) end)
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('Well, Anthian City is divided into four districts',
						'We are currently in the Housing District.',
						'This is where all the locals live.',
						'There are even several places where trainers like us can rent apartments.',
						'Plus the museum is in this district, with lots of great art and history.',
						'At the end of the Housing District is the entrance to the Shopping District.',
						'The Shopping District is where you can do a lot of shopping for Pok[e\'] Balls, clothes and other neat items.',
						'And from the Shopping District you can reach the Battle District and Park District.')
					spawn(function() tess:LookAt(pp) end)
					tess:Say('First, we need to head to the Shopping District.',
						'Gerald, my fathers friend, works there with his wife.')
					spawn(function() tess:LookAt(jp) end)
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:Say('Alright, what are we waiting for?',
						'Let\'s go talk to him!')
					local nodes = {
						Vector3.new(-2695, 258, 2736),
						Vector3.new(-2687, 258, 2710),
						Vector3.new(-2692, 258, 2684),
						Vector3.new(-2702, 259, 2661),
						Vector3.new(-2705, 266, 2629),
						Vector3.new(-2714, 266, 2530),
						Vector3.new(-2714, 278, 2252),
						Vector3.new(-2717, 278, 2232),
						Vector3.new(-2717, 295, 2195),
						Vector3.new(-2702, 295, 2158),
					}
					jake.humanoid.WalkSpeed = 26
					tess.humanoid.WalkSpeed = 26
					jake.walkAnim = jake.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.Run })
					tess.walkAnim = tess.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.Run })
					spawn(function()
						for _, n in ipairs(nodes) do
							if not map.Parent then return end
							jake:WalkTo(n)
						end
						jake:remove()
					end)
					delay(.3, function()
						for _, n in ipairs(nodes) do
							if not map.Parent then return end
							tess:WalkTo(n)
						end
						tess:remove()
					end)
					wait(1)
				end
				-- re-enable stuff
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				_p.RunningShoes:enable()
				_p.Menu:enable()
			end
			interact[pilot.model] = function()
				if not pilot:Say('[y/n]Would you like a ride to Cragonos Peak?') then
					pilot:Say('I\'ll be waiting here if you change your mind.')
					return
				end
				pilot:Say('Let\'s go!')

				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				spawn(function() Utilities.lookAt(CFrame.new(-2702.47729, 279.756744, 2736.88647, -0.250097841, -0.408168852, 0.877980292, -0, 0.906797767, 0.42156601, -0.968220532, 0.105432749, -0.226788178)) end)

				blimpDoor.CanCollide = false

				local root = _p.player.Character.HumanoidRootPart
				local proot = pilot.model.HumanoidRootPart
				if root.Position.X < proot.Position.X  and root.Position.Z > proot.Position.Z then
					_p.MasterControl:WalkTo(proot.Position + Vector3.new(3, 0, 3))
				end

				local node1 = Vector3.new(-2719, 258.442, 2745.2)
				local node2 = Vector3.new(-2737.8, 255.042, 2745.2)
				pilot:WalkTo(node1)
				spawn(function()
					pilot:WalkTo(node2)
					pilot:WalkTo(Vector3.new(-2751.399, 255.042, 2791.8))
				end)
				_p.MasterControl:WalkTo(node1)
				_p.MasterControl:WalkTo(node2)
				_p.MasterControl:WalkTo(Vector3.new(-2742.8, 255.042, 2745.2))
				_p.MasterControl:Look(Vector3.new(0, 0, -1))
				wait(1)

				_p.MusicManager:popMusic('RegionMusic', .5, true)
				Utilities.FadeOut(.5)
				pilot:Stop()
				local startTick = tick()
				Utilities.TeleportToSpawnBox()
				chunk:remove()
				-- change chunks
				_p.DataManager:loadMap('chunk18')

				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				Utilities.Teleport(CFrame.new(-1583, 131, -310, 0, 0, -1, 0, 1, 0, 1, 0, 0))
				local elapsed = tick()-startTick
				if elapsed < .5 then
					wait(.5-elapsed)
				end
				Utilities.FadeIn(.5)

				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				_p.RunningShoes:enable()
				_p.Menu:enable()
			end
			-- dumpster / Trubbish enc
			local dumpster = map.Dumpster
			local isv = dumpster:FindFirstChild('#InanimateInteract')
			if isv then
				local isFull = _p.Network:get('PDS', 'isTinD')
				if isFull then
					isv.Value = 'FullDumpster'
					local parts = {}
					local main = dumpster.Main
					local mcf = main.CFrame
					local function index(obj)
						for _, ch in pairs(obj:GetChildren()) do
							if ch:IsA('BasePart') and ch ~= main then
								parts[ch] = mcf:toObjectSpace(ch.CFrame)
							elseif ch:IsA('Model') then
								index(ch)
							end
						end
					end
					index(dumpster)
					delay(2, function()
						while map.Parent and isv.Value == 'FullDumpster' do
							-- vibrate
							local f = math.random()-.5
							Tween(.8, nil, function(a)
								local m = math.sin(a*math.pi)
								local cf = mcf * CFrame.new(0, 0, math.sin(a*15)*m*f)
								for p, rcf in pairs(parts) do
									p.CFrame = cf:toWorldSpace(rcf)
								end
								main.CFrame = cf
							end)
							wait(math.random()*3+1)
						end
					end)
				end
			end

--[[							-- mrbobbilly Event
	local lawyer = chunk.npcs.Extreme
	interact[lawyer.model] = function()
		if completedEvents.NiceListReward2 then
			lawyer:Say('Thanks again for the help with Bob.',
				'I wish I could have seen the look on his face when you beat him in that battle.')
		elseif completedEvents.BeatBob2 then
			lawyer:Say('Oh, you\'re back.', 'Did you find Bob?',
				'Really?! Well what did he say to you?',
				'You had to battle him to make him forgive me?',
				'That sounds exactly like him.', 'Thank you so much for that.',
				'Your help really means a lot to me.',
				'And as I promised, I have three very special Mons for you to choose from.',
				'You may only have one, so pick really carefully.',
				'These Mons are some of the rarest in Roria, which I got from Bob himself.',
				'I have a Carvanha, Audino and an Axew.', 'Which one would you like?')
			local choice = _p.NPCChat:choose('Carvanha', 'Audino', 'Axew')
			local msg = _p.PlayerData:completeEvent('NiceListReward2', choice)
			if msg then chat:say(msg) end
			lawyer:Say('Excellent choice.', 'That Mon is very special.',
				'Treat it kindly.', 'And remember, kid, if you\'re ever in any need of help, come look me up.')
		else
			if not completedEvents.LearnAboutBob2 then
				spawn(function() _p.PlayerData:completeEvent('LearnAboutBob2') end)
				lawyer:Say('Looks like it\'ll be another time where Bob doesn\'t forgive me for my bad deeds.',
					'What\'s wrong, you look confused?',
					'Don\'t tell me you don\'t know about Bob.',
					'Legend has it that Bob is one of the best trainer Roria has seen.',
					'And with that comes with his stingy attitude.',
					'Sadly enough, I\'ve come to experience that attitude first hand when I so called borrowed his Mons.',
					'He\'s been going around the city telling everyone about my bad deeds I committed.',
					'Hey, I have an idea.', 'You\'re a trainer right?',
					'Would you help me out and go find and talk to Bob for me?',
					'I\'d talk to him myself, but I hear he only respects strong trainers.',
					'If you can talk the guy into forgiving me, I would be incredibly grateful!',
					'In fact, I might just have a reward for you!',
					'Like I said, I borrowed a few of his Mons and he actually believed me when I said that I lost them.',
					'I wouldn\'t mind sharing from my collection.',
					'So what do you say?', 'Will you help me?')
			end
			lawyer:Say('You\'re probably wondering where to find Bob.',
				'From what I\'ve heard, he likes to come out at night at the Battle District.',
				'He can usually be found in the center square over there.',
				'If you\'re passing through that area, be sure to find him at night.',
				'And don\'t forget, if he agrees to forgive me, come back and let me know.',
				'I\'ll have something awesome for you!')
		end
	end
--]]		
		end,

		cameraOffset_Museum = function()
			local v2, v3 = Vector2.new, Vector3.new
			local min, max = math.min, math.max
			local sin, cos = math.sin, math.cos
			return function(p)
				if p.X > 93 then -- left wall
					local a = min(1, (p.X-93)/5)
					local pitch = .7-(.2*a)
					local t = -1.57*a
					local h = v3(0, 8*a, 0)
					if p.Z > 75 then -- back-left corner
						local o = max(a, min(1, (p.Z-75)/10))
						if o ~= a then
							pitch = .7-(.2*o)
							h = v3(0, 8*o, 0)
						end
					end
					return v3(sin(t), sin(pitch), -cos(pitch)*cos(t))*18, h
				elseif p.X < -93 then -- right wall
					local a = min(1, (-p.X-93)/5)
					local pitch = .7-(.2*a)
					local t = 1.57*a
					local h = v3(0, 8*a, 0)
					if p.Z > 75 then -- back-right corner
						local o = max(a, min(1, (p.Z-75)/10))
						if o ~= a then
							pitch = .7-(.2*o)
							h = v3(0, 8*o, 0)
						end
					end
					return v3(sin(t), sin(pitch), -cos(pitch)*cos(t))*18, h
				elseif p.Z < 50.8 then -- lapras
					local d = v2(p.X, p.Z-19)
					local r = d.magnitude-- min 21
					if r < 40 then
						local a = min(1, -(r-40)/10)
						local pitch = .7+(.3*a)
						local t = .4*a
						return v3(sin(t), sin(pitch), -cos(pitch)*cos(t))*(18+10*a), v3(0, 18*a, 0)
					end
				elseif p.Z > 75 then -- back wall
					local a = min(1, (p.Z-75)/10)
					local pitch = .7-(.2*a)
					return v3(0, sin(pitch), -cos(pitch))*18, v3(0, 8*a, 0)
				end
			end
		end,

		onBeforeEnter_Museum = function(room)
			if _p.PlayerData.badges[4] then
				room.model.PrisonBottle:remove()
			else
				room.npcs.Looker:remove()
				room.model.GlassCase.BrokenGlass:remove()
			end
		end,

		cameraOffset_LottoShop = function()
			local v2, v3 = Vector2.new, Vector3.new
			local min, max = math.min, math.max
			local sin, cos = math.sin, math.cos

			return function(p)
				-- When player approaches the left wall
				if p.X > 10 then -- left wall
					-- Calculate how close to the wall we are (0 to 1)
					local a = min(1, (p.X-10)/5)
					-- Calculate camera angles
					local pitch = .7-(.2*a)
					local t = -1.57*a
					-- Calculate height offset
					local h = v3(0, 8*a, 0)
					-- Return camera offset and height adjustment
					return v3(sin(t), sin(pitch), -cos(pitch)*cos(t))*4, h
				end
			end
		end,

		onBeforeEnter_LottoShop = function(room)
			local prizes, triesToday = _p.Network:get("PDS", "getLottoPrizes")
			for i, day in pairs({"Today", "Tomorrow"}) do
				local display = room.model[day .. "Display"]
				local screen = create("SurfaceGui")({
					Adornee = display,
					Face = Enum.NormalId.Back,
					CanvasSize = Vector2.new(display.Size.X * 25, display.Size.Y * 25),
					Parent = display,
					create("Frame")({
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(0.8, 0, 0, 2),
						Position = UDim2.new(0.1, 0, 0.2, 0)
					})
				})
				Utilities.Write(day .. "'s Prizes")({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.1, 0),
						Position = UDim2.new(0.5, 0, 0.05, 0),
						Parent = screen
					}),
					Scaled = true
				})
				local maxxb = 0
				local things = {}
				for prizeNum, prizeName in pairs(prizes[i]) do
					local thing = Utilities.Write(prizeNum .. ". " .. prizeName)({
						Frame = create("Frame")({
							BackgroundTransparency = 1,
							Size = UDim2.new(0, 0, 0.08, 0),
							Parent = screen
						}),
						Scaled = true,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					maxxb = math.max(maxxb, thing.AbsoluteMaxBounds.X)
					things[prizeNum] = thing
				end
				local bh = things[1].AbsoluteMaxBounds.X / things[1].Frame.Size.X.Scale
				local xpos = 0.5 - maxxb / bh * 0.08 / screen.CanvasSize.X * screen.CanvasSize.Y / 2
				for n, thing in pairs(things) do
					thing.Frame.Parent.Position = UDim2.new(xpos, 0, 0.16 + 0.13 * n, 0)
				end
			end
			local hobo = room.npcs.Hobo
			interact[hobo.model] = function()
				--spawn(function() _p.Menu:disable() end)

				if not hobo:Say("Welcome to Hobo's Lucky Lotto!", "[y/n]Would you like to try your luck in the Ticket Draw?") then
					hobo:Say("Please do visit again!")
					--spawn(function() _p.Menu:enable() end)
					return
				end

				if triesToday >= 4 then
					hobo:Say("That's all the tickets you can draw for today.", "Come back tomorrow to try again!")
					spawn(function() _p.Menu:enable() end)
					return
				elseif triesToday > 0 then
					if not hobo:Say("So far, you've drawn " .. triesToday .. " ticket" .. (triesToday == 1 and "" or "s") .. " today.", "You can draw " .. 4 - triesToday .. " more ticket" .. (triesToday == 3 and "" or "s") .. " for 30 R$" .. (triesToday == 3 and "." or " each."), "[y/n]Would you like to purchase a ticket for 10 R$?") then
						hobo:Say("Please do visit again!")
						return
					end
				end
				if not hobo:Say("You must save when you draw a ticket.", "[y/n]Would you like to save the game?") then
					hobo:Say("Please do visit again!")
					--spawn(function() _p.Menu:enable() end)
					return
				end

				local head = hobo.model.Head
				local processing = false
				local complete = false

				local function draw()
					local ticket, result
					spawn(function()
						processing = true
						ticket = _p.Network:get("PDS", "drawLotto", _p.PlayerData:getEtc())
						if ticket ~= 'timeout' then
							processing = false
							result = {
								_p.Network:get("PDS", "getLottoResults")
							}
							if ticket then -- Only increment if we got a valid ticket
								triesToday = triesToday + 1
							end
						else
							processing = false
							complete = true
							spawn(function() _p.Menu:enable() end)
							hobo:Say("The purchase was cancelled.")
							return
						end
					end)

					chat:say(head, "Awesome! Let's draw a random ticket...")
					while not ticket and processing do
						wait()
					end

					if ticket == 'timeout' then
						return
					end


					Utilities.fastSpawn(function()
						chat:say(head, "[ma]Your ticket number is " .. string.format("%05d", ticket) .. "...")
					end)
					wait(2.5)
					while not result do
						wait()
					end
					chat:manualAdvance()
					local digitsMatched, matchLocation, prizeData = unpack(result)
					if digitsMatched == 0 then
						chat:say(head, "No matches found...")
					else
						local matchPhrase
						if matchLocation[2] == 1 then
							matchPhrase = "The " .. matchLocation[1] .. " in your party"
						elseif matchLocation[2] == 2 then
							matchPhrase = "Your " .. matchLocation[1] .. " at the Day Care Center"
						elseif matchLocation[2] == 3 then
							matchPhrase = Utilities.aOrAn(matchLocation[1], true) .. " in box " .. matchLocation[3] .. " of your PC"
						end
						if matchPhrase then
							local numbers = {
								"one",
								"two",
								"three",
								"four",
								"five"
							}
							matchPhrase = matchPhrase .. " matched " .. numbers[digitsMatched] .. " digit" .. (digitsMatched > 1 and "s" or "") .. "!"
							chat:say(head, matchPhrase)
						else
							chat:say(head, "An error occured.")
						end
						if prizeData then
							local prizeIsItem = prizeData[2]
							if prizeIsItem then
								onObtainItemSound()
							end
							chat:say(head, "You won " .. (prizeIsItem and Utilities.aOrAn(prizeData[1]) or prizeData[1]) .. "!")
							if prizeIsItem then
								chat.bottom = true
								chat:say(_p.PlayerData.trainerName .. " put the " .. prizeData[1] .. " in the Bag.")
								chat.bottom = nil
							end
						end
					end
					if triesToday < 4 then
						chat:say(head, "Today, you can draw up to " .. 4 - triesToday .. " more ticket" .. (triesToday == 3 and "" or "s") .. " for 10 R$" .. (triesToday == 3 and "." or " each."))
					end
					chat:say(head, "Please do visit again!")
					complete = true
				end
				if triesToday > 0 then
					spawn(draw)
					local st = tick()
					while not complete do
						if tick() - st > 20 and processing then
							hobo:Say("Your purchase timed out.")
							spawn(function() _p.Menu:enable() end)
							return
						else

							wait()
						end
					end
				else
					draw()
				end
			end
		end,

		onLoad_chunk20 = function(chunk) -- ANTHIAN: SHOPPING
			local map = chunk.map
			spawn(function() -- spinning Poke Ball sign
				if not map:FindFirstChild('EmporiumSign') then return end
				local spinningBall = map.EmporiumSign.SpinningPart
				local st = tick()
				local scf = spinningBall.CFrame
				while map.Parent do
					spinningBall.CFrame = scf * CFrame.Angles(0, 1.2*(tick()-st), 0)
					stepped:wait()
				end
			end)
			do -- sign flipping Shipool
				local shipool = chunk.npcs.Shipool
				local sign = shipool.model.Sign
				sign.Name = 'Part'
				sign:BreakJoints()
				local torso = shipool.model.Torso
				create 'Motor6D' {
					Part0 = torso,
					Part1 = sign,
					C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					C1 = CFrame.new(0, 0.411267102, 0.497990757, 1, 0, 0, 0, 1, 1.1920929e-07, 0, -1.1920929e-07, 1),
					Parent = torso,
				}
				local animation = shipool.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.FlipSign })
				animation:Play()
			end
			spawn(function() -- LightSet
				local sets = {}
				while true do
					local ls = map:FindFirstChild('LightSet')
					if not ls then break end
					local set = {parts = {}, light = create'PointLight'{Color=Color3.fromRGB(255,96,96)}}
					for _, ch in pairs(ls:GetChildren()) do
						if ch:IsA('BasePart') then
							table.insert(set.parts, ch)
						end
					end
					table.sort(set.parts, function(a, b) return a.Name < b.Name end)
					table.insert(sets, set)
					ls.Name = 'LightSetInstalled'
				end
				if #sets == 0 then return end
				while map.Parent do
					for i = 1, 6 do
						if not map.Parent then return end
						for _, set in pairs(sets) do
							if set.last then
								set.last.Transparency = 0.39
								set.last.Material = Enum.Material.SmoothPlastic
							end
							local l = set.parts[i]
							set.last = l
							set.light.Parent = l
							l.Transparency = 0
							l.Material = Enum.Material.Neon
						end
						wait(.1)
					end
					for _, set in pairs(sets) do
						set.light.Parent = nil
						if set.last then
							set.last.Transparency = 0.39
							set.last.Material = Enum.Material.SmoothPlastic
						end
					end
					wait(.5)
				end
			end)
			-- Cars
			--	if Utilities.isTouchDevice() and not _p.Menu.options.reduceGraphics then
			spawn(function()
				local cars = map.Cars:GetChildren()
				while map.Parent do
					local car = cars[math.random(#cars)]:Clone()
					car.Color.BrickColor = BrickColor.new(math.random(), math.random(), math.random())
					local pos, dir
					local v = math.random(80, 90)
					if math.random(20) > 10 then
						pos = Vector3.new(-405.4, 40.5, 380)
						dir = Vector3.new(0, 0, 1)
					else
						pos = Vector3.new(-389.4, 40.5, 885)
						dir = Vector3.new(0, 0, -1)
					end
					car.Parent = map
					spawn(function()
						Utilities.MoveModel(car.Main, CFrame.new(pos, pos+dir), true)
						local cfs = {}
						for _, p in pairs(Utilities.GetDescendants(car, 'BasePart')) do
							cfs[p] = p.CFrame
						end
						Tween(505/v, nil, function(a)
							local offset = dir*505*a
							for p, cf in pairs(cfs) do
								p.CFrame = cf + offset
							end
						end)
						car:remove()
					end)
					wait(math.random(2, 7))
				end
			end)
			--end
			-- Eclipse grunts
			if _p.PlayerData.badges[4] and not completedEvents.DefeatTEinAC then
				pcall(function() map['CaveDoor:chunk22:a']:remove() end)
			else
				chunk.npcs.EclipseGrunt1:remove()
				chunk.npcs.EclipseGrunt2:remove()
				chunk.npcs.EclipseGrunt3:remove()
				chunk.npcs.EclipseGrunt4:remove()
				map.EclipseBlockadeParts:remove()
			end
			--
			local jake = chunk.npcs.Jake
			local tess = chunk.npcs.Tess
			local gerald = chunk.npcs.ChunkGerald
			local basementDoor = chunk:getDoor('C_chunk23')
			-- JT cutscene
			if not completedEvents.MeetGerald then
				basementDoor.locked = true
				gerald:remove()
				touchEvent('MeetGerald', map.JTCutscene, false, function()
					spawn(function() _p.Menu:disable() end)
					_p.RunningShoes:disable()
					_p.MasterControl.WalkEnabled = false

					local jp = jake.model.HumanoidRootPart.Position
					local tp = tess.model.HumanoidRootPart.Position
					local pp = (jp + tp) / 2 + Vector3.new(0, 0, 5)
					_p.MasterControl:WalkTo(pp)
					spawn(function() tess:LookAt(pp) end)
					spawn(function() jake:LookAt(pp) end)
					tess:Say('Welcome to the Shopping District, '.._p.PlayerData.trainerName..'.',
						'The Pok[e\'] Ball shop is just ahead.',
						'Let\'s all go now.')
					local door = chunk:getDoor('PokeBallShop')
					door.openTemp = door.open
					door.open = function() end
					local main = door.model.Main
					local size = main.Size
					local cf = main.CFrame
					main.Size = Vector3.new(3.5, 6.9, 5.5)
					main.CFrame = cf
					local path = {
						Vector3.new(-295, 64, 674),
						Vector3.new(-268.2, 64, 586),
						cf * Vector3.new(0, 0, 20),
					}
					local walking = true
					spawn(function()
						for i, p in pairs(path) do
							if i == 3 then
								spawn(function() door:openTemp(.75) end)
								wait(.5)
							end
							tess:WalkTo(p)
						end
						walking = false
					end)
					wait(.55)
					spawn(function()
						for _, p in pairs(path) do
							jake:WalkTo(p)
						end
						walking = false
					end)
					wait(.35)
					for i = 1, 2 do
						_p.MasterControl:WalkTo(path[i])
					end
				end)
			elseif _p.PlayerData.badges[4] and not completedEvents.GeraldKey then
				basementDoor.locked = true
				jake:remove()
				tess:Teleport(CFrame.new(-271, 66.5, 591.6, 0.682, 0, 0.731, 0, 1, 0, -0.731, 0, 0.682))
				touchEvent('GeraldKey', map.GTTrigger, true, function()
					spawn(function() _p.Menu:disable() end)
					_p.RunningShoes:disable()
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()

					local walls = {
						[create 'Part' {
							Anchored = true, Transparency = 1, CanCollide = false,
							CFrame = CFrame.new(-274.3, 68.8, 585.2, -0.707, 0, -0.707, 0, 1, 0, 0.707, 0, -0.707),
							Size = Vector3.new(10.4, 12.2, 2),
							Parent = workspace,
						}] = Vector3.new(-278.8, 64, 588.4),
						[create 'Part' {
							Anchored = true, Transparency = 1, CanCollide = false,
							CFrame = CFrame.new(-268.7, 68.8, 590.8, -0.707, 0, -0.707, 0, 1, 0, 0.707, 0, -0.707),
							Size = Vector3.new(10.4, 12.2, 2),
							Parent = workspace,
						}] = Vector3.new(-271.6, 64, 595.2),
						[create 'Part' {
							Anchored = true, Transparency = 1, CanCollide = false,
							CFrame = CFrame.new(-272.9, 68.8, 589.4, -0.707, 0, -0.707, 0, 1, 0, 0.707, 0, -0.707),
							Size = Vector3.new(14.2, 12.2, 2),
							Parent = workspace,
						}] = false
					}
					local cp = _p.player.Character.HumanoidRootPart.Position+Vector3.new(1,0,1)+Vector3.new(0,64,0)
					local pp = Vector3.new(-276, 64, 593)
					local part = (Utilities.findPartOnRayWithIgnoreFunction(Ray.new(cp, pp-cp), function(hit) return walls[hit]==nil end))
					local pos = part and walls[part]
					for part in pairs(walls) do part:remove() end
					if pos then _p.MasterControl:WalkTo(pos) end
					_p.MasterControl:WalkTo(pp)
					local tp = tess.model.HumanoidRootPart.Position
					local gp = gerald.model.HumanoidRootPart.Position
					spawn(function() tess:LookAt(pp) end)
					spawn(function() gerald:LookAt(pp) end)
					spawn(function() _p.MasterControl:LookAt(tp) end)
					local pName = _p.PlayerData.trainerName
					tess:Say(pName..', thank goodness you\'re back!',
						'Something awful has happened.',
						'It\'s all my fault, too!')
					spawn(function() _p.MasterControl:LookAt(gp) end)
					gerald:Say('That boy is going to get himself into trouble.',
						'I told him not to go.')
					spawn(function() _p.MasterControl:LookAt(tp) end)
					spawn(function() gerald:LookAt(tp) end)
					tess:Say('Team Eclipse is back in Anthian City, and Jake has run off to face them alone!',
						'I tried to stop him, but he was determined to save your parents and protect us.',
						'I should have gone with him.')
					spawn(function() tess:LookAt(gp) end)
					spawn(function() _p.MasterControl:LookAt(gp) end)
					gerald:Say('No, you did the right thing by staying here.',
						'That boy is a fool.',
						'He\'s going to get himself captured for meddling with those goons.')
					gerald:LookAt(pp)
					gerald:Say('It\'s true, Team Eclipse has resurfaced in Anthian City.',
						'Their presence here can only mean one thing.',
						'They must be going back after that artifact in the museum.',
						'I saw a bunch of them pass the shop heading to the housing district.',
						'It would appear that they flew a ship of their own and docked it in the park district.',
						'Your friend went over there as soon as he heard thy were here.',
						'There isn\'t much you can do for him.',
						'Hopefully, Team Eclipse won\'t find him as very much of a threat and simply kick him out of their area of operations.')
					spawn(function() gerald:LookAt(tp) end)
					tess:Say('What if he\'s captured, though?!',
						'Jake is my friend, and if it were me in trouble, he would come looking for me.')
					gerald:Say('I\'m sure he would, but I can\'t afford to send you looking for him and risk you getting in trouble as well.',
						'...especially after you tell me that you haven\'t had much battling experience.')
					tess:Say('Maybe I don\'t, but I know someone who does!')
					tess:LookAt(pp)
					tess:Say(pName..', you just won the badge from the Anthian City Gym, right?')
					tess:LookAt(gp)
					tess:Say(pName..' happens to be an amazing Pok[e\']mon trainer, and if we went together, I doubt anyone would stand in our way.',
						'Please Gerald, you have to let us try.')
					gerald:Say('You are every bit as determined as your father was when he wanted his way, Tess.',
						'I guess there really is no stopping you.',
						'If '..pName..' will be there to assist you, then I\'m fine with it.')
					gerald:LookAt(pp)
					gerald:Say('I want you to take this.')

					onObtainKeyItemSound()
					chat:say('Obtained a Basement Key!',
						pName .. ' put the Basement Key in the Bag.')

					gerald:Say('That\'s the key to the basement below my shop.',
						'It will take you through the Anthian Sewers.',
						'The sewers connect to the park district underground from the shopping district.',
						'There are Team Eclipse members guarding the path above ground to the park district, but I\'m sure they don\'t know about the sewer path.')
					spawn(function() gerald:LookAt(tp) end)
					gerald:Say('If you take the tunnels below the city, I am confident you will reach your destination safely.')
					tess:Say('Thank you so much, Gerald!',
						'This will be incredibly helpful.',
						'Don\'t worry about '..pName..' and I.',
						'I promise we will come back safely.')
					gerald:Say('I sure hope so.',
						'I\'ll be inside the shop if you need anything.',
						'I need to call a few friends in the city to make sure they\'re alright.',
						'Good luck, you two.')
					local door = chunk:getDoor('PokeBallShop')
					local cf = door.model.Main.CFrame
					spawn(function() _p.MasterControl:LookAt(cf.p) end)
					spawn(function() tess:LookAt(cf.p) end)
					gerald:WalkTo(Vector3.new(-269.2, 64, 588))
					door:open(.75)
					spawn(function() gerald:WalkTo(cf * CFrame.new(0, 0, 10)) end)
					wait(.8)
					door:close(.6)
					gerald:Stop()
					gerald:remove()
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:LookAt(pp)
					tess:Say('Alright, let\'s go find the sewer entrance.')
					local nodes = {
						Vector3.new(-278.4, 64, 580.7),
						Vector3.new(-278.4, 64, 548.3),
						Vector3.new(-242.6, 64, 548.3),
						Vector3.new(-242.6, 64, 554.3),
						Vector3.new(-269.8, 54, 554.3)
					}
					local tessWalking = true
					spawn(function()
						for _, node in pairs(nodes) do
							tess:WalkTo(node)
						end
						tessWalking = false
					end)
					wait(.35)
					for i, node in pairs(nodes) do
						if i == #nodes then
							_p.MasterControl:WalkTo(node + Vector3.new(4, 0, 0))
						else
							_p.MasterControl:WalkTo(node)
						end
					end
					while tessWalking do wait() end
					tess:LookAt(_p.player.Character.HumanoidRootPart.Position)
					tess:Say('Alright, let\'s go.',
						'Oh, I guess I haven\'t given you a chance to run some last-minute errands you might need to prepare for this.',
						'If it\'s healing your Pok[e\']mon, don\'t worry about that.',
						'I have plenty of potions, I\'ll keep our Pok[e\']mon healed up as we go through.',
						'I\'ll wait for you right inside, in case you need to do something else.',
						'Please hurry though, we need to find Jake quickly.')
					Utilities.Sync {
						function() basementDoor:open(.75) end,
						function() tess:Look(Vector3.new(0,0,1)) end,
					}
					spawn(function() tess:WalkTo(Vector3.new(-269.8, 54, 564.3)) end)
					wait(2)
					basementDoor:close(.75)
					tess:Stop()
					tess:remove()

					basementDoor.locked = false
					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
				end)
			else
				if not completedEvents.GeraldKey then
					basementDoor.locked = true
				end
				jake:remove()
				tess:remove()
				gerald:remove()
			end
			-- Ash-Greninja Dealer
			local dealer = chunk.npcs.Ashgrendealer
			interact[dealer.model] = function()
				local buy = dealer:Say('Hello there, young trainer.',
					'You wouldn\'t happen to be interested in collecting rare Pok[e\']mon, would you?',
					'Nah, I\'m sure that\'s not your sort of thing...',
					'You see, I have this Pok[e\']mon that\'s not of a particularly rare species.',
					'Interestingly however, he has a rare ability...',
					'His ability allows him to bond with powerful trainers, and become stronger.',
					'His appearance changes noticably when he knocks out an opponent\'s Pok[e\']mon.',
					'It\'s incredibly cool!',
					'Well, you don\'t seem particularly interested in this Pok[e\']mon...',
					'I suppose I could make it worth your while.',
					'I\'ll turn him over to you for a mere 150 ROBUX.',
					'Oh, and you\'d have to save after we complete the deal.',
					'[y/n]So, whaddaya say?')
				if not buy then
					dealer:Say('Yeah, I didn\'t think so...', 'Sorry to waste your time.')
					return
				end

				spawn(function() dealer:Say('[ma]Alright, let me see those ROBUX...') end)
				local loadTag = {}
				_p.DataManager:setLoading(loadTag, true)
				local r = _p.Network:get('PDS', 'buyAshGreninja')
				_p.DataManager:setLoading(loadTag, false)
				chat:manualAdvance()
				if not r then
					dealer:Say('Your payment failed.', 'Let me know if you get serious about this deal.')
				elseif r == 'to' then
					dealer:Say('Your payment failed or is being delayed.', 'I\'m a legitimate businessman, though.',
						'If I receive your payment later for whatever reason, I\'ll have the Pok[e\']mon delivered to your PC.',
						'You\'ll have to be sure to save, though.')
				elseif r == 'fp' then
					dealer:Say('You don\'t have any room in your party.', 'Make some room first, and come see me again.')
				else
					dealer:Say('Alright, you just scored big time!', 'Here you go!')
					chat.bottom = true
					Utilities.sound(304774035, nil, nil, 8)
					chat:say('Obtained Greninja!')
					local nickname
					if dealer:Say('[y/n]Would you like to give a nickname to Greninja?') then
						nickname = _p.Pokemon:giveNickname(r.i, r.s)
					end
					local msg = _p.Network:get('PDS', 'makeDecision', r.d, nickname)
					if msg then chat:say(msg) end
					spawn(function() chat:say('[ma]Saving...') end)
					local success = _p.PlayerData:save()
					wait()
					chat:manualAdvance()
					if success then
						Utilities.sound(301970897, nil, nil, 3)
						chat:say('Save successful!')
						_p.Menu.willOverwriteIfSaveFlag = nil -- we don't have a condition checking this, but who is going to start a new game and reach this point without ever having saved?
					else
						chat:say('SAVE FAILED!', 'Be sure to try again later.')
					end
				end
			end
		end,

		onBeforeEnter_PokeBallShop = function(room)
			if not completedEvents.MeetGerald then
				-- First time here: let's meet Gerald!
				spawn(function() _p.PlayerData:completeEvent('MeetGerald') end)
				room.npcs.RoomJake:remove()
				room.npcs.RoomTess:remove()

				local chunk = _p.DataManager.currentChunk
				local door = chunk:getDoor('PokeBallShop')
				door.open = door.openTemp
				door.openTemp = nil
				door:close()

				local jake = chunk.npcs.Jake
				local tess = chunk.npcs.Tess
				local cf = room.Entrance.CFrame * CFrame.new(0, 3, 3.5) * CFrame.Angles(0, math.pi, 0)
				tess:Teleport(cf * CFrame.new(0, 0, -8))
				jake:Teleport(cf * CFrame.new(0, 0, -4))
				local gerald = room.npcs.Gerald
				local gp = gerald.model.HumanoidRootPart.CFrame
				local tp = gp + Vector3.new(0, 0, -5)
				local jp = tp + Vector3.new(-4, 0, 1)
				local pp = tp + Vector3.new(4, 0, 1)
				spawn(function()
					repeat wait() until _p.MasterControl.WalkEnabled
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					Utilities.Sync {
						function()
							tess:WalkTo(tp)
							tess:LookAt(gp)
						end,
						function()
							jake:WalkTo(jp)
							jake:LookAt(gp)
						end,
						function()
							_p.MasterControl:WalkTo(pp)
							_p.MasterControl:LookAt(gp)
						end
					}
					local pName = _p.PlayerData.trainerName
					tess:Say('Um Gerald, is that you?')
					gerald:LookAt(tp)
					Utilities.exclaim(gerald.model.Head)
					gerald:Say('Well my goodness, is that you Tess?',
						'My my, you\'re quite a lot older than the last time I saw ya.',
						'It\'s been five or six years at least.',
						'How\'s that grandfather of yours?')
					tess:Say('It\'s been ten actually, and grandfather is as old and obnoxious as always.')
					gerald:Say('Oh hahaha, that sounds like him alright.',
						'So what brings you kids all the way out to the great city in the sky?')
					tess:Say('Gerald, I remember my father talking about traveling with you all over Roria.')
					gerald:Say('Oh yes, your father and I were very well known for our adventures and findings all throughout this region.',
						'There is hardly a rock in Roria that we have left unturned throughout the course of our expeditions.',
						'I was so hurt when I found out about your mother and father\'s disappearance.',
						'I\'ve hardly left the city but a handful of times since that time.',
						'You know, I was a part of the first search party to go looking for your parents.',
						'After a week of searching some of the places your father and I traveled to, I could not think where else to look for them.',
						'I\'m so sorry that they were not around to see you grow to become the capable young person you are now.')
					tess:Say('It\'s alright, Gerald.',
						'I\'m actually not here to talk about my parents, though.')
					gerald:Say('Oh, well then, how can I help you?')
					tess:Say('These are my friends Jake and '..pName..'.',
						'You see, not too long ago, a ruthless gang of evil people named "Team Eclipse" kidnapped '..pName..'\'s parents.',
						pName..' and Jake had been tracking them down until they wound up in Rosecove where Grandpa and I were attacked by Team Eclipse.',
						'Thanks to '..pName..' and Jake, Grandpa and I were saved.',
						'Unfortunately, we were not able to get any information on '..pName..'\'s parents.',
						'We decided to set out and look for them together.',
						'I thought we could try asking you if you knew anything that might help us find '..pName..'\'s parents or track down Team Eclipse.')
					gerald:Say('Yes, I\'m well-acquainted with the name Eclipse.',
						'Those goons have raided our city before.',
						'Anthian City has since banned them and anyone suspected to be associated with them.')
					gerald:LookAt(pp)
					gerald:Say('I\'m curious, though, '..pName..'.',
						'What did they want from your parents?')
					spawn(function() gerald:LookAt(jp) end)
					jake:Say('The Professor Cypress from Mitis Town believes it may have something to do with the fact that they are archeologists, and know a lot about the history of Roria.')
					gerald:LookAt(pp)
					gerald:Say('Oh my, your parents are the world-famous archeologists from Mitis Town?',
						'I\'ve run into them on several of my own adventures.',
						'They are some of the greatest people I\'ve met in my journeys.',
						'They sure do know an awful lot about the history and legends of Roria.',
						'That worries me though, knowing that Team Eclipse wants them.',
						'When Team Eclipse was here in Anthian, they made an attempt to steal an artifact from the museum.',
						'Thankfully our local police were able to stop them in time.',
						'The item that they were after is known as the Prison Bottle.',
						'Your parents were actually the ones that discovered it, in a cavern off the main shores of Roria.',
						'There\'s a legend that says that it contains the true power of a Pok[e\']mon that lies dormant somewhere deep within the caves of Crescent Island.',
						'Nobody has been able to prove that these legends are true.',
						'Nobody has proven them false, either.')
					spawn(function() gerald:LookAt(jp) end)
					jake:Say('Crescent Island is just off the eastern coast of Roria, isn\'t it?')
					gerald:Say('Correct.',
						'Many times, adventurers like Tess\'s father and I would go cave diving in Crescent Island.',
						'We\'ve never seen anything more than an interesting set of rocks in those caves.')
					gerald:LookAt(pp)
					gerald:Say('Anyone that has gone down into those caves looking for artifacts has returned empty handed...',
						'...with the exception of your parents, '..pName..'.',
						'I don\'t know what the Prison Bottle is really for, but it\'s best it stays in the museum, out of reach of that Team Eclipse.')
					spawn(function() gerald:LookAt(jp) end)
					spawn(function() tess:LookAt(jp) end)
					spawn(function() _p.MasterControl:LookAt(jp) end)
					jake:Say('So Team Eclipse was here and tried stealing an artifact?',
						'That\'s interesting.',
						'I wonder if they were after it because of something your parents told them.',
						'You know, since your parents were the ones that found it.',
						'I can\'t imagine why else they would be after it.')
					spawn(function() tess:LookAt(gp) end)
					spawn(function() _p.MasterControl:LookAt(gp) end)
					spawn(function() jake:LookAt(gp) end)
					spawn(function() gerald:LookAt(tp) end)
					tess:Say('Gerald, is there anything else you can tell us about Team Eclipse?',
						'Anything that can help us find them?')
					gerald:Say('Unfortunately, that\'s all I know about them.',
						'They usually only surface when they\'re after something.',
						'They were yelling something about a "new world" when they were here.',
						'Our police managed to capture one of them.',
						'They interrogated the man, and he said that our world would crumble and that a new world would save mankind.',
						'If you ask me, it just sounds like a bunch of crazy people decided to make a gang and harass innocent members of our city.',
						'If I were you kids, I wouldn\'t go messing with them.',
						'They are nothing but trouble.',
						'I would let the police of Roria take care of it.')
					tess:Say('I\'m afraid I can\'t stand back and wait.',
						'When my parents disappeared, it took a whole month to get a search team together.',
						'I can\'t let that happen to '..pName..' too.',
						'I\'m going to do whatever it takes to help save '..pName..'\'s parents from Team Eclipse.')
					gerald:Say('You are just like your father, you know.',
						'Brave and adventurous.',
						'The Exeggcute don\'t fall far from the Exeggutor.',
						'Alright, I will start doing some quick research and see what else I can find on Team Eclipse.',
						'I know a few people from a few places around Roria that might know a thing or two more than I do.')
					tess:Say('Great!',
						'That would be so helpful!')
					spawn(function() tess:LookAt(pp) end)
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say(pName..', we are going to stop Team Eclipse and get your parents back!',
						'I just know it.')
					spawn(function() tess:LookAt(gp) end)
					spawn(function() _p.MasterControl:LookAt(gp) end)
					gerald:Say('This may take some time.',
						'If you kids want to go explore the city while I make a few calls, I will come find you when I am done.')
					spawn(function() jake:LookAt(tp) end)
					tess:Say('I think I will wait here with you, Gerald.',
						'I want to know as soon as you find any information.')
					jake:Say('Yeah, I want to stay here with Tess and help her help Gerald.')
					spawn(function() tess:LookAt(pp) end)
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say(pName..', you collect Gym Badges, right?',
						'There is a Pok[e\']mon Gym here in Anthian City, in the Battle District!',
						'If you want to go challenge it while we wait, that would be a good use of your time.',
						'It wouldn\'t hurt to train up your Pok[e\']mon, too, in case we run into more Team Eclipse that want to battle.',
						'I will come find you myself if anything comes up.',
						'Just don\'t get lost.')

					interact[tess.model] = {'There is a Pok[e\']mon Gym here in Anthian City, in the Battle District!',
						'If you want to go challenge it while we wait, that would be a good use of your time.'}
					interact[jake.model] = 'I wonder if there\'s a good candy store in this district.'
					interact[gerald.model] = 'Let\'s see if I can remember how to open my contacts...'

					spawn(function() _p.Menu:enable() end)
					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
				end)
			elseif not _p.PlayerData.badges[4] then
				-- I'm back, but haven't gotten the badge yet.
				interact[room.npcs.RoomTess.model] = {'There is a Pok[e\']mon Gym here in Anthian City, in the Battle District!',
					'If you want to go challenge it while we wait, that would be a good use of your time.'}
				interact[room.npcs.RoomJake.model] = 'I wonder if there\'s a good candy store in this district.'
				interact[room.npcs.Gerald.model] = 'Let\'s see if I can remember how to open my contacts...'
				room.npcs.Gerald:Look(Vector3.new(0, 0, -1), .01)
			elseif not completedEvents.DefeatTEinAC then
				-- I have the basement key, but haven't taken care of Team Eclipse yet
				room.npcs.RoomJake:remove()
				room.npcs.RoomTess:remove()
				room.npcs.Gerald:Look(Vector3.new(0, 0, -1), .01)
				interact[room.npcs.Gerald.model] = {'Good luck getting to your friend over in Anthian Park.',
					'The sewers should be a safe passage to get there.', 'The entrance is just behind the shop.'}
			elseif not completedEvents.FluoDebriefing then
				-- I have defeated Team Eclipse in Anthian City
				room.npcs.RoomJake:remove()
				room.npcs.Gerald:Look(Vector3.new(0, 0, -1), .01)
				interact[room.npcs.RoomTess.model] = {'I know you are strong enough to save Jake and your family.',
					'I wish I was out there fighting battles alongside you but I\'m not strong enough.',
					'Instead, I will stay here and help find information that might help us.', 'Good luck out there, '.._p.PlayerData.trainerName..'!'}
				interact[room.npcs.Gerald.model] = {'I\'m waiting to hear from some friends who have recently traveled around Crescent Island.',
					'They might have more information that can help us stop Team Eclipse.'}
			else
				-- I have earned the 6th gym badge and been debriefed by Tess/Gerald in Fluoruma City
				room.npcs.RoomJake:remove()
				room.npcs.RoomTess:remove()
				room.npcs.Gerald:remove()--interact[room.npcs.Gerald.model] = {}
				-- TODO: future cases that may cause the context of Gerald's text to change
			end
			local salesperson = room.npcs.Salesperson
			interact[salesperson.model] = function()
				spawn(function() _p.Menu:disable() end)
				chat:say(salesperson, 'Welcome to the Pok[e\'] Ball Emporium!', 'May I help you?')
				while true do
					if not _p.Menu.shop:open('pbemp') then break end
					chat:say(salesperson, 'Is there anything else I may do for you?')
				end
				chat:say(salesperson, 'Please come again!')
				_p.Menu:enable()
			end
		end,

		onExit_PokeBallShop = function()
			if not _p.PlayerData.badges[4] then
				local chunk = _p.DataManager.currentChunk
				pcall(function() chunk.npcs.Tess:remove() end)
				pcall(function() chunk.npcs.Jake:remove() end)
			end
		end,

		-- SHOPS / APARTMENTS
		onBeforeEnter_StoneShop = function(room)
			local salesperson = room.npcs.Salesperson
			interact[salesperson.model] = function()
				spawn(function() _p.Menu:disable() end)
				chat:say(salesperson, 'Welcome to the Stone Shop!', 'May I help you?')
				while true do
					if not _p.Menu.shop:open('stnshp') then break end
					chat:say(salesperson, 'Is there anything else I may do for you?')
				end
				chat:say(salesperson, 'Please come again!')
				_p.Menu:enable()
			end
		end,

		-- todo: here down
		onBeforeEnter_ZombiesHardware = function(room)
			local salesperson = room.npcs.Zommi
			interact[salesperson.model] = {'Welcome to the future home of Zombie\'s Hardware!',
				'We\'re not open for business at the moment, as we\'re still finishing up some preparations.',
				'Please come back soon!'}
		end,

		onBeforeEnter_HerosHoverboards = function(room)
			local salesperson = room.npcs.Hero

			local debounce = true
			local csig = Utilities.Signal()
			local function onClickHoverboard(model)
				local shopGuy = _p.DataManager.currentChunk:topRoom().npcs.Hero
				if model.Name:sub(1, 6) == 'Basic ' then
					if shopGuy:Say('[y/n]Ah, the '..model.Name..' Board... Would you like to take this one with you?') then
						spawn(function() _p.Network:get('PDS', 'setHoverboard', model.Name) end)
						pcall(function() csig:fire() end)
					else
						debounce = false
					end
				else
					if _p.Network:get('PDS', 'ownsHoverboard', model.Name) then
						if shopGuy:Say('Ah, '..model.Name..'... You\'ve already purchased this one.',
							'[y/n]Would you like to take it with you?') then
							spawn(function() _p.Network:get('PDS', 'setHoverboard', model.Name) end)
							pcall(function() csig:fire() end)
						else
							debounce = false
						end
					else
						if shopGuy:Say('[y/n]Ah, '..model.Name..'... Would you like to purchase this one for 5 R$?')
							and shopGuy:Say('[y/n]You must save if your purchase goes through. Is it okay to save the game?') then
							spawn(function() shopGuy:Say('[ma]Please wait a moment while I process your purchase...') end)
							local loadTag = {}
							_p.DataManager:setLoading(loadTag, true)
							local r = _p.Network:get('PDS', 'purchaseHoverboard', model.Name, _p.PlayerData:getEtc())
							_p.DataManager:setLoading(loadTag, false)
							_p.NPCChat:manualAdvance()
							if r == 'ao' then
								shopGuy:Say('Wait, I was mistaken. You have purchased this hoverboard already.')
								debounce = false
							elseif r == 'to' then
								shopGuy:Say('That\'s odd, it looks like the purchase timed out.', 'Not to worry, though.',
									'If it happens to process later, you\'ll definitely get your hoverboard.',
									'Make sure you save, though!')
								debounce = false
							else
								pcall(function() csig:fire('Awesome, thanks for your business!') end)
							end
						else
							debounce = false
						end
					end
				end
			end

			local mcn
			local function connectMouse(model)
				local mouse = _p.player:GetMouse()
				mcn = mouse.Button1Down:connect(function()
					if debounce then return end
					local ur = mouse.UnitRay
					local p = Utilities.findPartOnRayWithIgnoreFunction(Ray.new(ur.Origin, ur.Direction*50), {}, function(p) return p.Transparency > .9 and not(pcall(function()assert(p.Parent.Parent==model or p.Parent.Parent.Parent==model)end)) end)
					if p then
						local board = select(2, pcall(function()
							return (p.Parent.Parent==model and p.Parent)
								or (p.Parent.Parent.Parent==model and p.Parent.Parent)
								or nil
						end))
						if board and type(board) ~= 'string' then
							debounce = true
							onClickHoverboard(board)
						end
					end
				end)
			end

			interact[salesperson.model] = function()
				spawn(function() _p.Menu:disable() end)
				salesperson:Say('Welcome to Hero\'s Hoverboards!',-- 'You guessed it, I\'m your hero!',
					--'Unfortunately, at the moment our inventory is not ready and we don\'t have a proper business license.',
					--'Come back after we officially open and we\'ll get you all set up!'}
					'What can I do for ya?')
				local choice = chat:choose('Free Boards', 'Paid Boards', 'Cancel')
				if choice == 1 then
					spawn(function() salesperson:Look(Vector3.new(1, 0, 4).unit) end)
					local chunk = _p.DataManager.currentChunk
					chunk.roomCamDisabled = true
					Utilities.lookAt(CFrame.new(-24.5, 11.1, 21.7, -.962, -.081, .263, 0, .956, .294, -.275, .283, -.919)+room.basePosition)
					salesperson:Say('This is our Basic Collection. You may take one out at a time for free!',
						'Click on whichever one you\'d like!')

					local closeButton = _p.RoundedFrame:new {
						Button = true, CornerRadius = Utilities.gui.AbsoluteSize.Y*.018,
						BackgroundColor3 = Color3.fromRGB(217, 99, 103),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(.2, 0, .08, 0),
						Position = UDim2.new(.6, 0, .04, 0),
						Parent = Utilities.gui,
						MouseButton1Click = function()
							if debounce then return end
							debounce = true
							csig:fire()
						end,
					}
					Utilities.Write 'Done' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.5, 0),
							Position = UDim2.new(0.5, 0, 0.25, 0),
							ZIndex = 2, Parent = closeButton.gui
						}, Scaled = true
					}

					debounce = false
					connectMouse(room.model.BasicBoards)
					csig:wait()
					pcall(function() mcn:disconnect() end)
					closeButton:remove()

					spawn(function() salesperson:LookAt(_p.player.Character.HumanoidRootPart.Position) end)
					Utilities.lookAt(chunk.getIndoorCamCFrame())
					chunk.roomCamDisabled = false
				elseif choice == 2 then
					spawn(function() salesperson:Look(Vector3.new(1, 0, 0)) end)
					local chunk = _p.DataManager.currentChunk
					chunk.roomCamDisabled = true
					Utilities.lookAt(CFrame.new(22.6, 10, 10.9, -.994, .018, -.111, 0, .988, .157, .112, .156, -.981)+room.basePosition)
					salesperson:Say('This is our Deluxe Collection. Once you purchase a board for 5 R$ you can take it out any time!',
						'Click on whichever one you\'d like!')

					local closeButton = _p.RoundedFrame:new {
						Button = true, CornerRadius = Utilities.gui.AbsoluteSize.Y*.018,
						BackgroundColor3 = Color3.fromRGB(217, 99, 103),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(.2, 0, .08, 0),
						Position = UDim2.new(.6, 0, .04, 0),
						Parent = Utilities.gui,
						MouseButton1Click = function()
							if debounce then return end
							debounce = true
							csig:fire()
						end,
					}
					Utilities.Write 'Done' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.5, 0),
							Position = UDim2.new(0.5, 0, 0.25, 0),
							ZIndex = 2, Parent = closeButton.gui
						}, Scaled = true
					}

					debounce = false
					connectMouse(room.model.PaidBoards)
					local msg = csig:wait()
					pcall(function() mcn:disconnect() end)
					closeButton:remove()

					spawn(function() salesperson:LookAt(_p.player.Character.HumanoidRootPart.Position) end)
					Utilities.lookAt(chunk.getIndoorCamCFrame())
					if msg then salesperson:Say(msg) end
					chunk.roomCamDisabled = false
				end
				salesperson:Say('Thanks for stopping by! Peace!')
				spawn(function() _p.Menu:enable() end)
			end
		end,

		onBeforeEnter_SixthsFurniture = function(room)
			local salesperson = room.npcs.Salesperson
			interact[salesperson.model] = {'Furniture HYPE!', 'You look like you\'re here to swag up your pad!',
				'Well, as you can see, our showroom is empty.', 'They delivery guy hasn\'t showed up in days...',
				'...(or did I forget to place the order?)'}
		end,

		onBeforeEnter_RorianBraviary = function(room)
			local salesperson = room.npcs.Salesperson
			interact[salesperson.model] = function()
				spawn(function() _p.Menu:disable() end)
				salesperson:Say('Welcome to Rorian Braviary!', 'How may I help you?')
				local c = chat:choose('Catalog', 'Cancel')
				if c == 1 then
					-- splash
					local window = _p.RoundedFrame:new {
						CornerRadius = Utilities.gui.AbsoluteSize.Y*.03,
						BackgroundColor3 = Color3.new(.3, .3, .3),
						Size = UDim2.new(2.0, 0, 1.0, 0),
						Position = UDim2.new(-1.0, 0, 0.0, 0),
						Parent = create 'Frame' {
							BackgroundTransparency = 1.0,
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(.3, 0, .3, 0),
							Position = UDim2.new(.5, 0, .35, 0),
							Parent = Utilities.gui
						}
					}
					local textbox = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(.485, 0, .8, 0),
						Position = UDim2.new(.485, 0, .05, 0),
						ZIndex = 2, Parent = window.gui
					}
					Utilities.Write 'Rorian Braviary is a third-party clothing company and is not affiliated with Pok[e\']mon Brick Bronze.' {
						Frame = textbox,
						Size = textbox.AbsoluteSize.Y*.09,
						Wraps = true
					}
					local b_anim = _p.AnimatedSprite:new {sheets={{id=174838736,startPixelY=174,rows=2},{id=174838747,rows=3},{id=174838755,rows=3},{id=174838764,rows=3}},nFrames=21,fWidth=207,fHeight=176,framesPerRow=2}
					b_anim.spriteLabel.Parent = create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxasset://textures/WhiteCircle.png',
						ImageColor3 = Color3.fromRGB(105, 60, 54),
						Size = UDim2.new(.4, 0, .8, 0),
						Position = UDim2.new(.05, 0, .05, 0),
						ZIndex = 2, Parent = window.gui
					}
					b_anim.spriteLabel.Size = UDim2.new(1.5, 0, 1.5, 0)
					b_anim.spriteLabel.Position = UDim2.new(-.25, 0, -.25, 0)
					b_anim.spriteLabel.ZIndex = 3
					b_anim:Play()
					local ok = _p.RoundedFrame:new {
						Button = true,
						CornerRadius = Utilities.gui.AbsoluteSize.Y*.01,
						BackgroundColor3 = Color3.fromRGB(125, 135, 188),
						Size = UDim2.new(.175, 0, .15, 0),
						Position = UDim2.new(.5-.175/2, 0, .8, 0),
						ZIndex = 2, Parent = window.gui
					}
					Utilities.Write 'OK' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, .7, 0),
							Position = UDim2.new(.5, 0, .15, 0),
							ZIndex = 3, Parent = ok.gui
						}, Scaled = true
					}
					ok.gui.MouseButton1Click:wait()
					b_anim:remove()
					ok:remove()
					window:remove()
					local r = _p.Network:get('RorianBraviary', 'open')
					if r then
						local rb = Utilities.gui.Parent:WaitForChild('RorianBraviary', 10)
						if rb then
							repeat wait() until not rb.Parent
						end
					end
				end
				salesperson:Say('Please come again!')
				spawn(function() _p.Menu:enable() end)
			end
		end,

		onBeforeEnter_SushiPlace = function(room)
			local salesperson = room.npcs.Salesperson
			local seat = room.model.PlayerSeat
			local seatMain = seat.Main
			local sushi = room.model.SushiTray:Clone()
			room.model.SushiTray:remove()
			local sitAnim, eatAnim
			interact[salesperson.model] = function()
				spawn(function() _p.Menu:disable() end)
				salesperson:Say('Welcome to New Sushi Stick!')
				local moneyFrame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.08, 0),
					Position = UDim2.new(0.1, 0, 0.8, 0),
					Parent = Utilities.gui,
				}
				Utilities.Write('[$]' .. _p.PlayerData:formatMoney()) {Frame = moneyFrame, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left}
				if not salesperson:Say('[y/n]Would you like a tray of Magik Sushi for [$]5,000?') then
					moneyFrame:remove()
					spawn(function() _p.Menu:enable() end)
					return
				end
				moneyFrame:remove()
				local r = _p.Network:get('PDS', 'buySushi')
				if r == 'nm' then
					salesperson:Say('You don\'t have enough [$], please come again.')
					spawn(function() _p.Menu:enable() end)
					return
				end
				_p.PlayerData.money = _p.PlayerData.money - 5000
				salesperson:Say('Thank you, please enjoy.')

				local sitCF = seatMain.CFrame * CFrame.new(0, 1.4, -.25)
				if not sitAnim then
					local human = Utilities.getHumanoid()
					local isR15 = human.RigType == Enum.HumanoidRigType.R15
					sitAnim = human:LoadAnimation(create'Animation'{AnimationId='rbxassetid://'.._p.animationId[isR15 and'R15_Sit'or'Sit']})
					eatAnim = human:LoadAnimation(create'Animation'{AnimationId='rbxassetid://'.._p.animationId[isR15 and'R15_Sushi'or'EatSushi']})
				end
				local root = _p.player.Character.HumanoidRootPart
				local lerp = select(2, Utilities.lerpCFrame(root.CFrame, sitCF))
				root.Anchored = true
				for _, p in pairs(seat:GetChildren()) do pcall(function() p.CanCollide = false end) end
				for _, p in pairs(room.model.OtherCollides:GetChildren()) do pcall(function() p.CanCollide = false end) end
				pcall(function() room.model.BlackPlate.CanCollide = false end)
				sitAnim:Play(.5)
				Tween(.5, 'easeOutCubic', function(a)
					root.CFrame = lerp(a)
				end)
				wait(.25)
				local s = sushi:Clone()
				s.Parent = room.model
				wait(.25)
				eatAnim:Play()
				for i = 1, 4 do
					wait(1)
					s['S'..i]:remove()
				end
				wait(1)
				chat:say('Your meal came with a fortune cookie!',
					'Inside you find...')
				onObtainItemSound()
				chat:say('...'..Utilities.aOrAn(r)..'!',
					_p.PlayerData.trainerName..' put the '..r..' in the Bag.')

				s:remove()
				local standCF = seatMain.CFrame * CFrame.Angles(0, 1.57, 0) * CFrame.new(0, .7, -2)
				lerp = select(2, Utilities.lerpCFrame(root.CFrame, standCF))
				for _, p in pairs(seat:GetChildren()) do if p ~= seatMain then pcall(function() p.CanCollide = true end) end end
				for _, p in pairs(room.model.OtherCollides:GetChildren()) do pcall(function() p.CanCollide = true end) end
				pcall(function() room.model.BlackPlate.CanCollide = true end)
				sitAnim:Stop(.5)
				Tween(.5, 'easeOutCubic', function(a)
					root.CFrame = lerp(a)
				end)
				root.Anchored = false

				salesperson:Say('Please come again!')
				spawn(function() _p.Menu:enable() end)
			end
		end,

		onBeforeEnter_ApartmentLow = function(room)
			local receptionist = room.npcs.Receptionist
			interact[receptionist.model] = {'One health code violation and they shut the whole place down...',
				'There was only one room with Rattatas...', 'Why we couldn\'t just shut that room down, I don\'t know.',
				'We should be re-opening soon, though.'}
		end,

		onBeforeEnter_ApartmentMedium = function(room)
			local receptionist = room.npcs.Receptionist
			interact[receptionist.model] = {'My apologies, but we\'re renovating all our vacant rooms at present.',
				'It should only be a matter of time before renovations are complete.'}
		end,

		onBeforeEnter_ApartmentHigh = function(room)
			local model = room.model
			local receptionist = room.npcs.Receptionist
			interact[receptionist.model] = {'Welcome to the Golden Pok[e\'] Ball.',
				'We\'re completely booked right now, but if you fill out an application, I can put you on the waitlist.',
				'Hmmm...', 'It seems we are out of applications, too.'}
			local spinner = model.Spinner
			local scf = spinner.CFrame
			local st = tick()
			spawn(function()
				while model.Parent do
					spinner.CFrame = scf * CFrame.Angles(0, .3*(tick()-st), 0)
					stepped:wait()
				end
			end)
		end,

		onLoad_chunk21 = function(chunk) -- ANTHIAN: BATTLE
			local map = chunk.map
			--	if not Utilities.isTouchDevice() and not _p.Menu.options.reduceGraphics then
			-- spinning stuff
			local spinningObjects = {}
			local function checkForSpinningObjects(model)
				for _, ch in pairs(model:GetChildren()) do
					if ch:IsA('BasePart') then
						local axis, rpf = ch.Name:match('^Spin:(%a):([%-%.%d]+)$')
						if axis and rpf and tonumber(rpf) then
							if axis:lower() == 'x' then
								table.insert(spinningObjects, {ch, ch.CFrame, Vector3.new(tonumber(rpf) * 30, 0, 0)})
							elseif axis:lower() == 'y' then
								table.insert(spinningObjects, {ch, ch.CFrame, Vector3.new(0, tonumber(rpf) * 30, 0)})
							elseif axis:lower() == 'z' then
								table.insert(spinningObjects, {ch, ch.CFrame, Vector3.new(0, 0, tonumber(rpf) * 30)})
							end
						end
					end
				end
				--	end
				checkForSpinningObjects(map.Blades)
				checkForSpinningObjects(map.Fountain)
				if #spinningObjects > 0 then
					local st = tick()
					spawn(function()
						while map.Parent do
							local et = tick()-st
							for _, obj in pairs(spinningObjects) do
								local p, cf, rv = obj[1], obj[2], obj[3]
								p.CFrame = cf * CFrame.Angles(rv.X*et, rv.Y*et, rv.Z*et)
							end
							heartbeat:wait()
						end
					end)
				end
				do -- jets
					local wing11 = map.Jet1.Wing1
					local wing12 = map.Jet1.Wing2
					local wing21 = map.Jet2.Wing1
					local wing22 = map.Jet2.Wing2
					local light1 = create'PointLight'{Color=Color3.new(1,1,1)}--fromRGB(255,96,96)}
					local light2 = light1:Clone()
					spawn(function()
						while map.Parent do
							light1.Parent = wing11
							wing11.Transparency = 0
							wing12.Transparency = .39
							wing11.Material = Enum.Material.Neon
							wing12.Material = Enum.Material.SmoothPlastic
							light2.Parent = wing21
							wing21.Transparency = 0
							wing22.Transparency = .39
							wing21.Material = Enum.Material.Neon
							wing22.Material = Enum.Material.SmoothPlastic
							wait(1)
							if not map.Parent then return end
							light1.Parent = wing12
							wing11.Transparency = .39
							wing12.Transparency = 0
							wing11.Material = Enum.Material.SmoothPlastic
							wing12.Material = Enum.Material.Neon
							light2.Parent = wing22
							wing21.Transparency = .39
							wing22.Transparency = 0
							wing21.Material = Enum.Material.SmoothPlastic
							wing22.Material = Enum.Material.Neon
							wait(1)
						end
					end)
				end
				do -- light strips
					local sets = {
						{model = map.LightSetA1, cycleTime = nil, betweenTime = .1, light = create'PointLight'{Color=Color3.fromRGB(255, 96, 96)}},
						{model = map.LightSetA2, cycleTime = nil, betweenTime = .1, light = create'PointLight'{Color=Color3.fromRGB(255, 96, 96)}},
						{model = map.LightSetA3, cycleTime = nil, betweenTime = .1, light = create'PointLight'{Color=Color3.fromRGB(255, 96, 96)}},
						{model = map.LightSetA4, cycleTime = nil, betweenTime = .1, light = create'PointLight'{Color=Color3.fromRGB(255, 96, 96)}},
						{model = map.LightSetA5, cycleTime = nil, betweenTime = .1, light = create'PointLight'{Color=Color3.fromRGB(255, 96, 96)}},
						{model = map.LightSetA6, cycleTime = nil, betweenTime = .1, light = create'PointLight'{Color=Color3.fromRGB(255,255,255)}, trans = 1},
						{model = map.LightSetA7, cycleTime = nil, betweenTime = .1, light = create'PointLight'{Color=Color3.fromRGB(137,205,255)}, trans = 1},
						{model = map.LightSetA8, cycleTime = nil, betweenTime = .1, light = create'PointLight'{Color=Color3.fromRGB(137,205,255)}, trans = 1},
						{model = map.LightSetB1, cycleTime = .5,  betweenTime = .1},
					}
					for _, set in pairs(sets) do
						local parts = {}
						local n = 1
						while true do
							local p = set.model:FindFirstChild(tostring(n))
							if p then
								parts[n] = p
								n = n + 1
							else
								break
							end
						end
						spawn(function()
							while map.Parent do
								for _, p in pairs(parts) do
									if not map.Parent then return end
									if set.light then set.light.Parent = p end
									p.Transparency = 0
									p.Material = Enum.Material.Neon
									wait(set.betweenTime)
									p.Transparency = set.trans or .39
									p.Material = Enum.Material.SmoothPlastic
								end
								if set.light then set.light.Parent = nil end
								wait(set.cycleTime)
							end
						end)
					end
				end
			end			
		end,

		cameraOffset_Gym4 = function()
			local v3 = Vector3.new
			local sin, cos = math.sin, math.cos
			local min = math.min
			return function(p)
				if p.y > 10 and p.x < -70 then
					return v3(10.1635647, 6.17216063, -13.9553595)
				elseif p.x < -86 then
					local a = min(1, (-p.x-86)/10)
					local pitch = .7*(1-a*.5)
					local t = .6*a
					return v3(sin(t), sin(pitch), -cos(pitch)*cos(t))*18
				elseif p.x > 86 then
					local a = min(1, (p.x-86)/10)
					local pitch = .7*(1-a*.5)
					local t = -.6*a
					return v3(sin(t), sin(pitch), -cos(pitch)*cos(t))*18
				end
			end
		end,

		onBeforeEnter_Gym4 = function(room)
			local santos, alberto, leader = room.npcs.Santos, room.npcs.Alberto, room.npcs.Leader

			_p.DataManager:preload(6142910487, 496819222) -- vs text, trainer icon
			-- tools
			if completedEvents.G4FoundTape then room.model.MeasuringTape:remove() end
			if completedEvents.G4FoundWrench then room.model.Wrench:remove() end
			if completedEvents.G4FoundHammer then room.model.Hammer:remove() end
			-- Santos
			local dumontDidDrive = false
			interact[santos.model] = function()
				local car = room.model.ConveyorCar
				if dumontDidDrive then
					santos:Say('The truck is in place, so you should be able to reach the toolbox up there now.')
					return
				end
				local function drive()
					dumontDidDrive = true
					santos:Say('You beat me fair and square, and I\'m a man of my word.')
					santos:LookAt(car.Body.Dumont.Head.Position)
					santos:Say('Alright Dumont, pull her forward!')
					local base = car.Body.Main
					local bcf = base.CFrame
					local wheelbase = car.Wheels.Main
					local wcf = wheelbase.CFrame
					local MoveModel = Utilities.MoveModel
					wait(.3)
					-- startup
					Tween(1, nil, function(a)
						MoveModel(base, bcf + Vector3.new(0, math.sin(a*19)*(1-a)*.3, 0), true)
					end)
					wait(.5)
					-- drive (physics)
					local accel = 10-- 5
					local decel = 14-- 7
					local maxV  = 15--10
					local dist  = 24
					local aDur  = maxV / accel
					local dDur  = maxV / decel
					local aDist = .5*accel*aDur*aDur
					local dDist = .5*decel*dDur*dDur
					local cDist = dist-aDist-dDist
					local cDur  = cDist / maxV
					--				print('acceleration:', aDist, 'studs in', aDur, 'seconds')
					--				print('cruise:',       cDist, 'studs in', cDur, 'seconds')
					--				print('deceleration:', dDist, 'studs in', dDur, 'seconds')
					--
					Tween(aDur, nil, function(a, t)
						local travel = Vector3.new(0, 0, .5*accel*t*t)
						MoveModel(wheelbase, wcf + travel, true)
						MoveModel(base, bcf * CFrame.Angles(-math.sin(a*2)*.08, 0, 0) + travel, true)
					end)
					local angle = CFrame.Angles(-math.sin(2)*.08, 0, 0)
					Tween(cDur, nil, function(a, t)
						local travel = Vector3.new(0, 0, aDist+cDist*a)
						MoveModel(wheelbase, wcf + travel, true)
						MoveModel(base, bcf * angle + travel, true)
					end)
					Tween(dDur, nil, function(a, t)
						local travel = Vector3.new(0, 0, aDist+cDist+maxV*t-.5*decel*t*t)
						MoveModel(wheelbase, wcf + travel, true)
						MoveModel(base, bcf * CFrame.Angles(-math.sin(2+a*4.28)*(.08-.03*a), 0, 0) + travel, true)
					end)
					wait(.5)
					santos:LookAt(_p.player.Character.Head.Position)
					santos:Say('The truck is in place, so you should be able to reach the toolbox up there now.')
				end
				local battleN = 96
				if _p.BitBuffer.GetBit(_p.PlayerData.defeatedTrainers, battleN) then
					drive()
					return
				end
				if not santos:Say('The boss might end up needing tools from that toolbox up there.',
					'If you beat me in a battle, I\'ll give you access to the toolbox.',
					'[y/n]What do you say?') then
					santos:Say('Well then, good luck getting up there.')
					return
				end
				santos:Say('Alright, let\'s do this!')
				local win = _p.Battle:doTrainerBattle {
					--				musicId = TBD,
					PreventMoveAfter = true,
					trainerModel = santos.model,
					num = 96,
					battleSceneType = 'Gym4',

				}
				if win then
					_p.PlayerData.defeatedTrainers = _p.BitBuffer.SetBit(_p.PlayerData.defeatedTrainers, battleN, true)
					drive()
				end
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				chat:enable()
				_p.Menu:enable()
			end
			-- Alberto
			local lift = room.model.ScissorLift
			local isUp = false
			local rows = 4
			local arm = create 'Part' {
				Anchored = true,
				BrickColor = BrickColor.new('Bright orange'),
				Material = Enum.Material.SmoothPlastic,
				Size = Vector3.new(13.6, .8, .6),
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Parent = create 'Model' {
					Name = 'Scissors',
					Parent = lift,
				}
			}
			local armwidth = arm.Size.Y
			local armthickness = arm.Size.Z
			local armlength = arm.Size.X - armwidth
			local arms = {arm}
			for i = 2, 4*rows do
				local a = arm:Clone()
				a.Parent = arm.Parent
				arms[i] = a
			end
			local function drawScissors()
				local start = lift.BottomMount.Position
				local finish = lift.Platform.TopMount.Position
				local pitch = (finish.Y-start.Y)/rows
				local theta = math.acos(pitch/armlength)
				local alpha = math.pi/2-theta
				local c = start + Vector3.new(0, pitch/2, armlength/2*math.sin(theta))
				local o = CFrame.new(0, 0, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
				for i = 1, rows do
					local y = pitch*(i-1)
					arms[i*4-3].CFrame = o * CFrame.Angles(0, 0, -alpha) + c + Vector3.new(0,              y, 0)
					arms[i*4-2].CFrame = o * CFrame.Angles(0, 0,  alpha) + c + Vector3.new(armthickness,   y, 0)
					arms[i*4-1].CFrame = o * CFrame.Angles(0, 0,  alpha) + c + Vector3.new(5,              y, 0)
					arms[i*4  ].CFrame = o * CFrame.Angles(0, 0, -alpha) + c + Vector3.new(5+armthickness, y, 0)
				end
			end
			drawScissors()
			local liftMain = lift.Platform.TopMount
			local lcf = liftMain.CFrame
			local liftParts = {}
			for _, ch in pairs(lift.Platform:GetChildren()) do
				if ch:IsA('BasePart') and ch ~= liftMain then
					liftParts[ch] = lcf:toObjectSpace(ch.CFrame)
				end
			end
			interact[alberto.model] = function()
				_p.MasterControl.WalkEnabled = false
				local battleN = 97
				local function switch()
					if _p.player.Character.HumanoidRootPart.Position.X < lift.BottomMount.Position.X then
						alberto:Say('Actually, in the interest of safety, you should probably get onto the platform a little better.')
						return
					end
					spawn(function() _p.Menu:disable() end)
					local scf = isUp and (lcf + Vector3.new(0, 15, 0)) or lcf
					local dir = Vector3.new(0, isUp and -15 or 15, 0)
					Tween(2, 'easeInOutCubic', function(a)
						local cf = scf + dir * a
						liftMain.CFrame = cf
						for p, rcf in pairs(liftParts) do
							p.CFrame = cf:toWorldSpace(rcf)
						end
						drawScissors()
					end)
					isUp = not isUp
					spawn(function() _p.Menu:enable() end)
				end
				if _p.BitBuffer.GetBit(_p.PlayerData.defeatedTrainers, battleN) then -- TEST THAT THIS SAVES
					if isUp then
						if not alberto:Say('[y/n]Want a ride back down?') then
							alberto:Say('Oh, okay.', 'Let me know if you change your mind.')
						else
							alberto:Say('Yeehaw!')
							switch()
						end
					else
						if not alberto:Say('[y/n]Would you like a ride up?') then
							alberto:Say('Oh, okay.', 'Let me know if you change your mind.')
						else
							alberto:Say('Woohoo!')
							switch()
						end
					end
				else
					if not alberto:Say('Hey, how about a battle?',
						'[y/n]If you win, I\'ll give you a ride on this scissor lift!') then
						alberto:Say('Aww, you\'re no fun!')
					else
						alberto:Say('Sweet!')
						local win = _p.Battle:doTrainerBattle {
							--						musicId = TBD,
							PreventMoveAfter = true,
							trainerModel = alberto.model,
							num = 97,
							battleSceneType = 'Gym4',
						}
						if win then
							_p.PlayerData.defeatedTrainers = _p.BitBuffer.SetBit(_p.PlayerData.defeatedTrainers, battleN, true)
							if not alberto:Say('[y/n]Alright then, shall we go up?') then
								alberto:Say('Oh, okay.', 'Let me know if you change your mind.')
							else
								alberto:Say('Woohoo!')
								switch()
							end
						end
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
						return
					end
				end
				_p.MasterControl.WalkEnabled = true
			end
			-- Leader
			if _p.PlayerData.badges[4] then
				local lroot = leader.model.HumanoidRootPart
				leader.humanoid = leader.model.Humanoid
				leader.model.NoAnimate.Name = 'Shirt'
				leader.model.TopHat.Transparency = 0
				leader.model.Shades.Transparency = 0
				Utilities.MoveModel(lroot, lroot.CFrame * CFrame.new(0, -5, -2, 1, 0, 0, 0, 0, 1, 0, -1, 0) + Vector3.new(0, 0, -10), true)
				leader:Animate()
				interact[leader.model] = {'I want to thank you again for your help.',
					'Good luck to you on your adventures, and remember to fly freely.'}
			else
				local lroot = leader.model.HumanoidRootPart
				leader.humanoid = leader.model.Humanoid
				leader:Rig()
				create 'Motor6D' {
					Name = 'Left Grip',
					Part0 = leader.model['Left Arm'],
					Part1 = leader.model.Shades,
					C0 = CFrame.new(0.9, 1.74, -0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					C1 = CFrame.new(-0.6, 0, -0.1, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					Parent = leader.model['Left Arm'],
				}
				create 'Motor6D' {
					Name = 'Right Grip',
					Part0 = leader.model['Right Arm'],
					Part1 = leader.model.TopHat,
					C0 = CFrame.new(-1.5, 1.9, -0.6, 1, 0, 0, 0, 1, -0.1, 0, 0.1, 11),
					C1 = CFrame.new(0, -0.667, -0.637, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					Parent = leader.model['Right Arm'],
				}
				create 'Weld' {
					Part0 = leader.model.Torso,
					Part1 = leader.model.Tie,
					C0 = leader.model.Torso.CFrame:toObjectSpace(leader.model.Tie.CFrame),
					Parent = leader.model.Torso,
				}
				local jump = leader.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.cmJump })
				local hats = leader.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.cmHats })
				for _, p in pairs(leader.model:GetChildren()) do
					if p:IsA('BasePart') and p ~= lroot then
						p.Anchored = false
					end
				end
				local leaderUp = false
				local function rollOut()
					if leaderUp then return end
					spawn(function() _p.Menu:disable() end)
					_p.MasterControl.WalkEnabled = false

					leaderUp = true
					local lcf = lroot.CFrame
					local cmain = room.model.Creeper.Main
					local ccf = cmain.CFrame
					local MoveModel = Utilities.MoveModel

					local bp = room.basePosition
					local chunk = _p.DataManager.currentChunk
					chunk.roomCamDisabled = true
					local cam = workspace.CurrentCamera
					cam.CFrame = CFrame.new(bp + Vector3.new(-10, 10, 14), bp + Vector3.new(0, 5, 24))

					Utilities.Teleport(CFrame.new(lcf.p.X, bp.Y+3.52, bp.Z+18, -1, 0, 0, 0, 1, 0, 0, 0, -1))
					Tween(1, 'easeOutCubic', function(a)
						lroot.CFrame = lcf + Vector3.new(0, 0, -10*a)
						MoveModel(cmain, ccf + Vector3.new(0, 0, -10*a), true)
					end)

					local function schedule(animTrack, kfName, kfTime, func)
						local fired = false
						local cn
						local function onFire()
							if fired then return end
							fired = true
							pcall(function() cn:disconnect() end)
							cn = nil
							func()
						end
						cn = animTrack.KeyframeReached:connect(function(reachedKfName) if reachedKfName == kfName then onFire() end end)
						delay(kfTime+.05, onFire)
					end
					local sig = Utilities.Signal()
					jump:Play(0)
					game:GetService('RunService').Heartbeat:wait()
					lroot.CFrame = lcf * CFrame.new(0, -5, -2, 1, 0, 0, 0, 0, 1, 0, -1, 0) + Vector3.new(0, 0, -10)
					delay(.4, function()-- .3 - .5
						Tween(.75, 'easeOutCubic', function(a)
							MoveModel(cmain, ccf + Vector3.new(0, 0, -10+3*a), true)
						end)
					end)
					schedule(jump, 'End', .65, sig.fire)
					sig:wait()
					leader.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCIdle }):Play()
					leader:Say('Sorry about that.',
						'Thanks for the help gathering the necessary tools.',
						'Oops, one second...')
					wait(.1)
					local tophat = leader.model.TopHat
					local shades = leader.model.Shades
					local s = .85
					hats:Play(0,1,s)
					schedule(hats, 'GrabHat',     .1 /s, function() tophat.Transparency = 0 end)
					schedule(hats, 'GrabShades',  .2 /s, function() shades.Transparency = 0 end)
					schedule(hats, 'PlaceHat',    .65/s, function() tophat:BreakJoints() create 'Weld' {Part0=leader.model.Head,Part1=tophat,C0=CFrame.new(0, 1, 0.1, 1, 0, 0, 0, 1, -0.1, 0, 0.1, 1),Parent=leader.model.Head} end)
					schedule(hats, 'PlaceShades', .75/s, function() shades:BreakJoints() create 'Weld' {Part0=leader.model.Head,Part1=shades,C0=CFrame.new(0, 0.24, -0.15, 1, 0, 0, 0, 1, 0, 0, 0, 1),Parent=leader.model.Head} end)
					schedule(hats, 'End',         .85/s, sig.fire)
					sig:wait()
					wait(.2)
					leader:Say('That\'s better.',
						'Now, to what do I owe the pleasure of this visit?',
						'Ah, you have come to challenge me for Anthian City\'s Gym Badge.',
						'Battling is the least I can do in return for your timely assistance.',
						'Well excellent, I love a good battle.')
					delay(2, function() chunk.roomCamDisabled = false end)
					local win = _p.Battle:doTrainerBattle {
						musicId = 121757660131215,
						battleSceneType = 'Gym4',
						PreventMoveAfter = true,
						trainerModel = leader.model,
						vs = {name = 'Stephen', id = 496819222, hue = 0.574, sat = .1},
						num = 98



					}
					if win then
						leader:Say('I\'m not sure whether it was the work I did on the jet, or that battle, but I feel winded.',
							'I find great joy in every battle, regardless of whether I win or lose.',
							'It\'s much like the enjoyment I get from flying.',
							'There just isn\'t a way to express the freedom felt while soaring through the sky or fighting on the battlefield.',
							'I could tell that you were feeling that freedom during our match.',
							'You were definitely an opponent worthy of my time, and for that I\'m grateful.',
							'It is my privilege to reward you with the Soaring Badge.')

						local badge = room.model.Badge4:Clone()
						local cfs = {}
						local main = badge.SpinCenter
						for _, p in pairs(badge:GetChildren()) do
							if p:IsA('BasePart') and p ~= main then
								cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
							end
						end
						badge.Parent = workspace
						local st = tick()
						local spinRate = 1
						local function cframeTo(rcf)
							local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi/2, 0, (tick()-st)*spinRate + math.pi/2)
							main.CFrame = cf
							for p, ocf in pairs(cfs) do
								p.CFrame = cf:toWorldSpace(ocf)
							end
						end
						local r = 8
						local f = CFrame.new(0, 0, -6)
						Tween(1, nil, function(a)
							local t = a*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						local spin = true
						Utilities.fastSpawn(function()
							while spin do
								cframeTo(f)
								stepped:wait()
							end
						end)
						wait(2)
						onObtainBadgeSound()
						chat:say('Obtained the Soaring Badge!')
						spin = false
						Tween(.5, nil, function(a)
							local t = (1-a)*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						badge:remove()

						leader:Say('With this badge, you will be able to trade for Pok[e\']mon up to level 60.',
							'You will also be able to use the move Fly outside of battle.',
							'Fly will enable you to travel more quickly between the towns and cities of Roria.',
							'That also reminds me, I want you to have this.')
						onObtainItemSound()
						chat:say('Obtained a TM40!',
							_p.PlayerData.trainerName .. ' put the TM40 in the Bag.')
						leader:Say('TM40 contains the move Aerial Ace.',
							'This Flying-type move never misses.',
							'You\'ve done an outstanding job today, young trainer.',
							'I want to thank you again for your help.',
							'Good luck to you on your adventures, and remember to fly freely.')
						interact[leader.model] = {'I want to thank you again for your help.',
							'Good luck to you on your adventures, and remember to fly freely.'}
					end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					chat:enable()
					_p.Menu:enable()
				end
				chat.customMaxInteractDist[leader.model] = 11
				interact[leader.model] = function()
					if not completedEvents.G4GaveTape then
						if completedEvents.G4FoundTape then
							completedEvents.G4GaveTape = true
							leader:Say('That measuring tape!',
								'It\'s just what I need!',
								'Thanks... let me just... there we go.',
								'About one and seven eighths.',
								'Hmmm...')
						else
							leader:Say('Hey there!',
								'I\'m sorry, but I\'ve got my hands full at the moment.',
								'I need to measure this gap.',
								'Would you mind finding a measuring tape for me?',
								'We\'ve got to have one lying around here somewhere.')
						end
					elseif not completedEvents.G4GaveWrench then
						if completedEvents.G4FoundWrench then
							completedEvents.G4GaveWrench = true
							leader:Say('That\'s exactly the wrench I need!',
								'How did you know?',
								'Okay... I\'m just gonna... alright.',
								'Sweet, now I just have to take care of this annoying little deformed bar...')
						else
							leader:Say('Thanks for your help with the tape, but now I need a wrench.',
								'I\'d prefer our adjustable wrench.',
								'It\'s one-of-a-kind.',
								'I think it\'s in a tool chest somewhere in the hangar.')
						end
					elseif not completedEvents.G4GaveHammer then
						if completedEvents.G4FoundHammer then
							completedEvents.G4GaveHammer = true
							leader:Say('I see you found a hammer!',
								'Probably the only one we\'ve got!',
								'Now... if I can just... wow.',
								'I can\'t believe that worked so easily...')
							rollOut()
						else
							leader:Say('Okay, this is going to sound crazy...',
								'...but I\'m going to try to bend this back into shape with a hammer.',
								'I don\'t use hammers very often, so I don\'t know where exactly you\'ll find one.',
								'I am certain, however, that we\'ve got one.',
								'The only question is where...')
						end
					else
						rollOut()
					end
				end
			end
		end,

		onExit_Gym4 = function()
			if _p.PlayerData.badges[4] and not completedEvents.SeeTEship then
				spawn(function() _p.Menu:disable() end)
				spawn(function() _p.PlayerData:completeEvent('SeeTEship') end)
				local cam = workspace.CurrentCamera
				local ship
				spawn(function() ship = _p.DataManager:request({'Model', 'EclipseShip'}) end)
				spawn(function()
					while not _p.MasterControl.WalkEnabled do stepped:wait() end
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					cam.CameraType = Enum.CameraType.Scriptable
					local focus = _p.player.Character.HumanoidRootPart.CFrame * Vector3.new(0, 1.5, 0)
					local pos = cam.CFrame.p
					local amp = 0
					local f = 7.5
					local st = tick()
					local zig = function()
						local c = ((tick()-st) * f) % 1
						if c < .25 then
							return 4*c
						elseif c < .75 then
							return 1-4*(c-.25)
						else
							return -1+4*(c-.75)
						end
					end
					spawn(function()
						Tween(1.5, nil, function(a)
							amp = .5*a
						end)
					end)
					local rumble = true
					spawn(function()
						while rumble do
							cam.CFrame = CFrame.new(pos, focus) * CFrame.new(0, amp * zig(), 0)
							stepped:wait()
						end
					end)
					while not ship do wait() end
					ship.Parent = workspace
					while amp < .45 do wait() end
					Utilities.exclaim(_p.player.Character.Head)
					wait(.5)
					local sp = CFrame.new()
					local fs = focus
					local tweenDone = false
					local parts = {}
					local main = ship.Main
					local mcf = main.CFrame
					for _, ch in pairs(ship:GetChildren()) do
						if ch ~= main and ch:IsA('BasePart') then
							parts[ch] = mcf:toObjectSpace(ch.CFrame)
						end
					end
					spawn(function()
						Tween(3, 'easeOutCubic', function(a)
							focus = fs + (main.Position-fs)*a
						end)
						tweenDone = true
					end)
					delay(2, function() _p.MasterControl:Look(Vector3.new(1, 0, 4).unit) end)
					delay(4, function()
						Tween(1.5, nil, function(a)
							amp = .5*(1-a)
						end)
					end)
					Tween(5, nil, function(a)
						local cf = mcf + Vector3.new(680*a, 0, 0)
						main.CFrame = cf
						for p, rcf in pairs(parts) do
							p.CFrame = cf:toWorldSpace(rcf)
						end
						if tweenDone then focus = cf.p end
					end)
					wait(.75)
					rumble = false
					pcall(function() ship:remove() end)
					Utilities.lookBackAtMe()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
				end)
			end
		end,

		onLoad_chunk22 = function(chunk, data)
			local map = chunk.map
			-- Locked basement door
			local basementDoor = chunk:getDoor('C_chunk23')
			if not completedEvents.GeraldKey then
				basementDoor.locked = true
			end
			-- Eclipse grunts / cutscene
			if _p.PlayerData.badges[4] and not completedEvents.DefeatTEinAC then
				_p.DataManager:queueSpritesToCache({'_FRONT', 'Absol'}) -- for the cry
				_p.DataManager:preload(280857070, 507282487, 507289472, 334858056, 509072758, 509073816, 510817248)
				-- randomize the idle animations (synced just looks creepy)
				local function offsetBreath(npc)
					local at = npc.humanoid:GetPlayingAnimationTracks()[1]
					at:Stop()
					delay(math.random(), function() at:Play() end)
				end
				offsetBreath(chunk.npcs.EclipseGrunt1)
				offsetBreath(chunk.npcs.EclipseGrunt2)
				offsetBreath(chunk.npcs.EclipseGrunt3)
				offsetBreath(chunk.npcs.EclipseAdmin1)
				offsetBreath(chunk.npcs.EclipseAdmin2)
				offsetBreath(chunk.npcs.Jake)
				_p.DataManager.ignoreRegionChangeFlag = true

				chunk.npcs.Gerald:remove()

				-- setup professor's special rig
				local prof = chunk.npcs.Professor
				local proot = prof.model.HumanoidRootPart
				create 'Weld' {
					Part0 = prof.model.Head,
					Part1 = prof.model.Hair,
					C1 = prof.model.Hair.CFrame:inverse() * prof.model.Head.CFrame,
					Parent = prof.model.Head,
				}
				create 'Weld' {
					Part0 = prof.model.Head,
					Part1 = prof.model.Glasses,
					C1 = prof.model.Glasses.CFrame:inverse() * prof.model.Head.CFrame,
					Parent = prof.model.Head,
				}
				prof.model.Humanoid:remove()
				prof.humanoid = create 'Humanoid' {DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None, Parent = prof.model}
				for _, ch in pairs(prof.model:GetChildren()) do if ch:IsA('BasePart') then ch.Anchored = false end end
				--[[Idle Anim]] prof.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCIdle }):Play()
				prof.walkAnim = prof.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCWalk })
				local changeAnim = prof.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.profChange })
				local turnAnim   = prof.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.profTurn   })
				prof.position = create 'BodyPosition' {MaxForce = Vector3.new(2e4, 0, 2e4), Position = proot.Position, Parent = proot}
				prof.gyro = create 'BodyGyro' {MaxTorque = Vector3.new(math.huge, 9e3, math.huge), CFrame = proot.CFrame, P = 1e4, Parent = proot}
				prof.animated = true

				local dialgapalkia; spawn(function() dialgapalkia = _p.DataManager:request({'Model', 'DialgaPalkia'}) end)
				--			Utilities.print_r(_p.DataManager:getSprite('_FRONT', 'Dialga').cry)
				--			Utilities.print_r(_p.DataManager:getSprite('_FRONT', 'Palkia').cry)

				spawn(function()
					while not _p.MasterControl.WalkEnabled do wait() end
					spawn(function() _p.Menu:disable() end)
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					_p.RunningShoes:disable()
					-- [=[
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					spawn(function() Utilities.lookAt(CFrame.new(-4192, 248.4, 2155, -0.902, 0.147, -0.405, 0, 0.940, 0.342, 0.431, 0.309, -0.848)) end)
					local tess = chunk.npcs.Tess
					local tp = tess.model.HumanoidRootPart.Position
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:LookAt(_p.player.Character.HumanoidRootPart.Position)
					--[ [
					tess:Say('I see Jake!',
						'It looks like he\'s in trouble!',
						'We better hurry and help him!')
					--]]
					spawn(function() _p.MasterControl:WalkTo(tp + Vector3.new(0, 0, 20)) end)
					spawn(function() tess:WalkTo(tp + Vector3.new(0, 0, 20)) end)
					wait(.5)
					Utilities.FadeOut(1)
					_p.MasterControl:Stop()
					tess:Stop()
					wait(.25)
					local c1 = CFrame.new(-4274, 250.4, 2394, .356, -.341, .870, 0, .931, .365, -.935, -.13, .331)
					workspace.CurrentCamera.CFrame = c1
					_p.MusicManager:stackMusic(9536675165, 'Cutscene', .4)
					Utilities.FadeIn(1)

					wait(1)
					local pName = _p.PlayerData.trainerName
					local jake = chunk.npcs.Jake
					local admin1 = chunk.npcs.EclipseAdmin1
					local admin2 = chunk.npcs.EclipseAdmin2
					--[ [
					admin1:Say('Well, look at what we have here.', 'It\'s the friend of that kid that keeps ruining our plans.')
					admin2:Say('Yeah, where\'s your little friend at now?', 'You made a big mistake messing with us, kid.')
					--]]
					local jp = jake.model.HumanoidRootPart.Position
					local pp = jp + Vector3.new(11, 0, -2.5)
					tp = jp + Vector3.new(11, 0,  2.5)
					local fp = jp + Vector3.new(11, 0, 0)
					Utilities.Teleport(CFrame.new(pp + Vector3.new(10, 0, 0), pp))
					tess:Teleport(CFrame.new(tp + Vector3.new(10, 0, 0), tp))
					Utilities.Sync {
						function() Utilities.exclaim(jake.model.Head) end,
						function() _p.MasterControl:WalkTo(pp) end,
						function() wait(.25) tess:WalkTo(tp) end,
					}
					--[ [
					jake:Say('Tess, '..pName..', thank goodness you came!')
					--]]
					Utilities.Sync {
						function()           Utilities.exclaim(admin1.model.Hat ) admin1:LookAt(fp) end,
						function() wait(.25) Utilities.exclaim(admin2.model.Hair) admin2:LookAt(fp) end,
					}
					local a1, a2 = admin1.model.HumanoidRootPart.Position, admin2.model.HumanoidRootPart.Position
					local ap = (a1+a2)/2
					spawn(function() _p.MasterControl:LookAt(ap) end)
					spawn(function() tess:LookAt(ap) end)
					--[ [
					admin1:Say('Oh, look who showed up.', 'You\'re a really persistent brat.')
					admin2:Say('Do you miss your mommy and daddy yet, kid?', 'We\'ve been taking real good care of them.',
						'We keep them cozily locked away back at our base.')
					spawn(function() admin2:LookAt(a1) end)
					admin1:LookAt(a2)
					admin1:Say('He doesn\'t need to know that, imbecile.')
					spawn(function() _p.MasterControl:LookAt(jp) end)
					spawn(function() tess:LookAt(jp) end)
					spawn(function() admin1:LookAt(jp) end)
					spawn(function() admin2:LookAt(jp) end)
					jake:Say('I\'m real sorry about this, '..pName..'.', 'I was just trying to help.',
						'I wanted to protect everyone.', 'I\'m not as strong as I thought.')
					admin1:Say('Zip it, kid.', 'You do what we say now.',
						'You don\'t challenge Team Eclipse without facing serious consequences.')
					spawn(function() _p.MasterControl:LookAt(ap) end)
					spawn(function() tess:LookAt(ap) end)
					admin1:LookAt(fp)
					delay(.1, function() admin2:LookAt(fp) end)
					admin1:Say('We\'ll be taking your friend back with us as our hostage.')
					tess:Say('You can\'t do that!', 'He\'s our friend, and we won\'t let you take him!')
					admin2:Say('You act like he has a choice.',
						'Soon we\'ll be done here and fly away with another one of your loved ones.',
						'We told you not to meddle with us, child.')
					admin1:Say('We just had our team members return from the museum with what we came here for.',
						'We\'re just waiting for Tyler to return from completing his mission.')
					admin2:Say('He should be back soon.', 'The boss doesn\'t like waiting.')
					--]]
					local dummy = create 'Model' {
						create 'Humanoid' {MaxHealth = 0, Health = 0},
						create 'Shirt' {ShirtTemplate = prof.model.Shirt.ShirtTemplate},
						create 'Pants' {PantsTemplate = prof.model.Pants.PantsTemplate},
						create 'Part' {Anchored = true, CanCollide = false, Name =     'Torso', Size = Vector3.new(2, 2, 1), BrickColor = BrickColor.new('Black')},
						create 'Part' {Anchored = true, CanCollide = false, Name = 'Right Arm', Size = Vector3.new(1, 2, 1), BrickColor = BrickColor.new('Black')},
						create 'Part' {Anchored = true, CanCollide = false, Name =  'Left Arm', Size = Vector3.new(1, 2, 1), BrickColor = BrickColor.new('Black')},
						create 'Part' {Anchored = true, CanCollide = false, Name = 'Right Leg', Size = Vector3.new(1, 2, 1), BrickColor = BrickColor.new('Black')},
						create 'Part' {Anchored = true, CanCollide = false, Name =  'Left Leg', Size = Vector3.new(1, 2, 1), BrickColor = BrickColor.new('Black')},
						Parent = workspace
					}
					local shipDoor = map.EclipseShip.Door
					local scf = shipDoor.CFrame
					Tween(1, 'easeOutCubic', function(a)
						shipDoor.CFrame = scf * CFrame.new(0, 0, -11*a)
					end)
					--[ [
					admin1:Say('Speaking of the boss, here he comes now.')
					--]]
					local grunt1, grunt2, grunt3 = chunk.npcs.EclipseGrunt1, chunk.npcs.EclipseGrunt2, chunk.npcs.EclipseGrunt3
					local npcs = {_p.MasterControl, tess, jake, admin1, admin2, grunt1, grunt2, grunt3}
					_p.MasterControl.model = _p.player.Character
					for _, npc in pairs(npcs) do
						spawn(function() npc:LookAt(scf.p) end)
					end
					Utilities.lookAt(CFrame.new(-4318, 259.5, 2386, -.004, -.238, .971, 0, .971, .238, -1, 0, -.004), nil, 1)
					map.WallToEclipseShip.CanCollide = false
					wait(.25)
					local pWalking = true
					local watchingProf = true
					spawn(function() prof:WalkTo(ap + Vector3.new(1, 0, 0)) pWalking = false end)
					local function activateWatch()
						watchingProf = true
						spawn(function()
							local cf, v3 = CFrame.new, Vector3.new
							local atan2 = math.atan2
							local pi = math.pi
							local sin, cos = math.sin, math.cos
							local twopi = pi*2
							while watchingProf do
								local pos = proot.Position
								for _, npc in pairs(npcs) do
									if not npc.ignore then
										local ncf = npc.model.HumanoidRootPart.CFrame
										local c = atan2(ncf.lookVector.X, ncf.lookVector.Z)
										local g = atan2(pos.X-ncf.p.X, pos.Z-ncf.p.Z)
										if g-c > pi then
											g = g - twopi
										elseif c-g > pi then
											c = c - twopi
										end
										c = c + (g-c) * .07
										npc:Look(v3(sin(c), 0, cos(c)), 0)
									end
								end
								stepped:wait()
							end
						end)
					end
					activateWatch()
					wait(.75)
					workspace.CurrentCamera.CFrame = CFrame.new(ap + Vector3.new(4, 3, 0).unit*15, ap + Vector3.new(0, 3, 0))
					while proot.Position.X < -4315 do stepped:wait() end
					spawn(function()
						grunt2.ignore = true
						grunt2:WalkTo(grunt2.model.HumanoidRootPart.Position + Vector3.new(-1.5, 0, 5))
						grunt2.ignore = nil
					end)
					spawn(function()
						grunt1.ignore = true
						grunt1:WalkTo(grunt1.model.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
						grunt1.ignore = nil
					end)
					while proot.Position.X < -4298 do stepped:wait() end
					spawn(function()
						jake.ignore = true
						jake:WalkTo(jp + Vector3.new(0, 0, 4))
						jake.ignore = nil
					end)
					wait(.25)
					spawn(function()
						admin1.ignore = true
						admin1:WalkTo(a1 + Vector3.new(0, 0, -2))
						admin1.ignore = nil
					end)
					wait(.25)
					spawn(function()
						admin2.ignore = true
						admin2:WalkTo(a2 + Vector3.new(0, 0, 2))
						admin2.ignore = nil
					end)
					while pWalking do stepped:wait() end
					wait(.5)
					delay(1, function() watchingProf = false end)
					--[ [
					prof:Say('Hello '..pName..', it\'s been a while since I saw you last.')
					prof:Say('I believe we bumped into each other last at the Rosecove City Gym.')
					jake:Say('Professor Cypress?')
					turnAnim:Play(.3)
					jake:Say('What are you doing here?')
					prof:Say('Haha, yes I guess I should explain.')
					turnAnim:Stop(.3)
					prof:Say('You see, I\'m not just Roria\'s Professor of Pok[e\']mon...')
					--]]
					local function schedule(animTrack, kfName, kfTime, func)
						local fired = false
						local cn
						local function onFire()
							if fired then return end
							fired = true
							pcall(function() cn:disconnect() end)
							cn = nil
							func()
						end
						cn = animTrack.KeyframeReached:connect(function(reachedKfName) if reachedKfName == kfName then onFire() end end)
						delay(kfTime+.05, onFire)
					end
					local function attach(p0, p1)
						p1.Anchored = false
						p1.CFrame = p0.CFrame
						create 'Weld' {Part0 = p0, Part1 = p1, Parent = p0}
					end
					proot.Anchored = true
					admin1.model.HumanoidRootPart.Anchored = true
					admin2.model.HumanoidRootPart.Anchored = true
					tess.model.HumanoidRootPart.Anchored = true
					_p.player.Character.HumanoidRootPart.Anchored = true
					changeAnim:Play()
					schedule(changeAnim, 'Grab', .3, function()
						local pm = prof.model
						attach(pm.T,  dummy.Torso)
						attach(pm.RA, dummy['Right Arm'])
						attach(pm.LA, dummy['Left Arm'])
						attach(pm.RL, dummy['Right Leg'])
						attach(pm.LL, dummy['Left Leg'])
						pm.Shirt.ShirtTemplate = 'rbxassetid://502354419'
						pm.Pants.PantsTemplate = 'rbxassetid://502354800'
						pm.Head.face.Texture = 'rbxassetid://277939506'
					end)
					local sig = Utilities.Signal()
					schedule(changeAnim, 'End', 1.35, sig.fire)
					sig:wait()
					proot.Anchored = false
					admin1.model.HumanoidRootPart.Anchored = false
					admin2.model.HumanoidRootPart.Anchored = false
					tess.model.HumanoidRootPart.Anchored = false
					_p.player.Character.HumanoidRootPart.Anchored = false
					dummy:remove()
					pcall(function() prof.model.LL:remove() end)
					pcall(function() prof.model.RL:remove() end)
					pcall(function() prof.model.RA:remove() end)
					pcall(function() prof.model.LA:remove() end)
					pcall(function() prof.model.T:remove() end)
					--[ [
					prof:Say('I\'m also the leader and grand architect of Team Eclipse.')
					turnAnim:Play(.3)
					jake:Say('Wait what, how could you???')
					prof:Say('Well, let me tell you all a story.')
					turnAnim:Stop(.3)
					prof:Say('Long ago, when I started my career as a Pok[e\']mon professor, I wanted to help Pok[e\']mon.',
						'When I was a child I had no friends.', 'That is, except for my Pok[e\']mon.',
						'I loved my Pok[e\']mon dearly and wanted the best for every Pok[e\']mon.',
						'Pok[e\']mon are excellent at bringing joy and comfort to their trainers and are very loyal.',
						'So as a professor, I devoted all my time in observing Pok[e\']mon and their relationships with humans.',
						'What I discovered was very disappointing.',
						'Humans do not show the same love and respect for their Pok[e\']mon as Pok[e\']mon do for their trainers.',
						'I\'ve observed Pok[e\']mon being mistreated by other humans for quite some time now.',
						'The way people force their Pok[e\']mon to pointlessly battle over such a petty thing as who may be stronger, is just an example.',
						'I cannot stand to watch humans abuse their Pok[e\']mon.', 'Pok[e\']mon should only be expected to battle to bring forth their own freedom.',
						'But then again...', 'Why bother starting a war to free Pok[e\']mon when there\'s a simpler solution?',
						'What if I could simply take the Pok[e\']mon to another place?',
						'A better place even, where humanity is reconstructed around the idea that Pok[e\']mon would be free from humans.',
						'As it turns out, I\'m not far from discovering such a place.',
						'I\'m close to finding a new world where people and Pok[e\']mon can live freely and independently.',
						'That day you came to my lab with your parents, they told me they had found something.',
						'It was a part of a legend that was tied in with an ancient Pok[e\']mon called Hoopa.',
						'They did not tell me what it was that they found specifically, but that it would unlock Hoopa and its infinite potential.',
						'I asked for more information, but it turned out that they didn\'t seem fond of sharing.',
						'I instructed my admins to take your parents to our base of operations for more questioning.',
						'With their reluctant help, we have almost discovered Hoopa\'s location.',
						'You see, Hoopa can open portals to new worlds across space and time.',
						'We need this power in order to reach our ultimate destination.', 'We will not be stopped in finding our new world.',
						'Those who do not join us and follow us to the new world will be left behind.')
					--]]
					pcall(function() chunk.npcs.ProfessorLoader:remove() end)
					local tyler = chunk.npcs.Tyler
					local tsp = a1 + Vector3.new(8, 0, -16)
					spawn(function() prof:LookAt(tsp) end)
					spawn(function() admin1:LookAt(tsp) end)
					tyler:Teleport(CFrame.new(tsp, a1))
					tyler:WalkTo(a1 + Vector3.new(2, 0, -6))
					spawn(function()
						admin1:WalkTo(a1 + Vector3.new(-3, 0, -4))
						admin1:LookAt(ap)
					end)
					local tmp = a1 + Vector3.new(1, 0, -2)
					tyler:WalkTo(tmp)
					tyler:LookAt(proot.Position)
					--[ [
					tyler:Say('The explosives are in place, sir.', 'We are ready to proceed.')
					spawn(function() prof:LookAt(fp) end)
					tess:Say('Explosives?', 'What explosives?')
					prof:Say('Oh yes, we left a little present for Anthian City.',
						'We felt less than welcome the last time we visited, so now we plan to repay the city\'s generosity by removeing its power core upon our departure.',
						'When the bombs explode, the power core will, of course, be obliterated.',
						'That core is what keeps this island floating, you know.')
					tess:Say('Why would you do such a thing?',
						'That would cause so much destruction!',
						'You\'re a professor of Pok[e\']mon, not a terrorist!')
					prof:Say('Maybe so, but we cannot afford to be stopped this time.',
						'Perhaps I forgot to mention, this world will be removeed anyway once we leave it behind for the new world.')
					tess:Say('That\'s awful!',
						'How can you justify such a thing?!')
					prof:Say('It\'s not justice, it\'s revenge.', 'Pok[e\']mon have been subjected to worse, and for way too long.')

					prof:LookAt(tmp)
					prof:Say('Get everyone on board and ready to go.')
					tyler:Say('Yes, sir!')
					--]]
					spawn(function() prof:Look(Vector3.new(-1, 0, 0)) end)
					tyler:WalkTo(proot.Position + Vector3.new(-7, 0, 0))
					local function board(npc, waitForPass, waitForComplete)
						local function a()
							npc:WalkTo(Vector3.new(-4302, 238, 2386))
						end
						local function b()
							npc:WalkTo(Vector3.new(-4345.395, 253.178, 2386.253))
							npc:WalkTo(Vector3.new(-4351.694, 253.178, 2396.553))
							npc:remove()
						end
						if waitForComplete then
							a()b()
						elseif waitForPass then
							a()spawn(b)
						else
							spawn(function()a()b()end)
						end
					end
					jp = jake.model.HumanoidRootPart.Position
					spawn(function() admin2:LookAt(jp) end)
					board(tyler)
					spawn(function() jake:Look(Vector3.new(0, 0, -1)) end)
					admin1:WalkTo(jp + Vector3.new(0, 0, -4))
					spawn(function() admin1:LookAt(jp) end)
					delay(.8, function() chat:manualAdvance() end)
					admin1:Say('[ma]Come with me.')
					board(admin1)
					wait(.25)
					board(jake)
					board(admin2, true)
					board(grunt2, true)
					board(grunt3, true)
					board(grunt1)
					prof:LookAt(fp)
					delay(.6, function() chat:manualAdvance() end)
					prof:Say('[ma]Ciao!')
					npcs = {_p.MasterControl, tess}
					activateWatch()
					spawn(function() prof:WalkTo(Vector3.new(-4302, 238, 2386)) end)
					wait(.2)
					spawn(function() prof:Stop() Utilities.exclaim(prof.model.Head) end)
					--[ [
					tess:Say('Wait!')
					wait(.25)
					--]]
					prof:LookAt(fp)
					--[ [
					tess:Say('We will not let you go without a fight!')
					--]]
					watchingProf = false
					spawn(function() _p.MasterControl:LookAt(tp) end)
					local cam = workspace.CurrentCamera
					--[ [
					spawn(function() Utilities.lookAt(cam.CFrame.p + Vector3.new(2.5, 1.5, 0), (ap + fp)/2 + Vector3.new(-1, 0, 0)) end)
					tess:LookAt(pp)
					tess:Say(pName..', you have to stop them.', 'They\'re about to leave with Jake.',
						'You\'re the strongest trainer I know!', 'Please stop them.')
					spawn(function() tess:LookAt(proot.Position) end)
					spawn(function() _p.MasterControl:LookAt(proot.Position) end)
					prof:Say('Are you actually challenging me to a fight?', 'You can\'t be serious!',
						'The reliance on Pok[e\']mon and violence sickens me, but that\'s how this world handles tough situations.',
						'I may be against Pok[e\']mon battles, but that doesn\'t mean I won\'t come prepared for one.')

					wait(.1)
					-- play absol's cry
					local cry = _p.DataManager:getSprite('_FRONT', 'Absol').cry
					Sprite:playCry(.7, cry, .5)
					wait(.3)

					spawn(function() Utilities.exclaim(prof.model.Head) end)
					spawn(function() Utilities.exclaim(tess.model.Head) end)
					Utilities.exclaim(_p.player.Character.Head)

					local absol = map.Absol

					local absStart = Vector3.new(-4222, 237.8, 2342)
					local absEnd = pp + Vector3.new(-1.5, 237.8-pp.Y, -7)
					local absV = absEnd-absStart
					local absCF = CFrame.new(absStart, absEnd)
					absol.Base.CFrame = absCF
					local eyes = absol.Head.Eyes

					absol.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.absolIdle }):Play()
					local absRunAnim   = absol.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.absolRun })
					local absSniffAnim = absol.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.absolSniff })
					absRunAnim:Play()

					local running = true
					spawn(function()
						Tween(3, nil, function(a)
							absol.Base.CFrame = absCF + absV*a
						end, 0) -- priority 0 (first)
						running = false
						absRunAnim:Stop()
					end)

					local camP = cam.CFrame.p
					Utilities.lookAt(camP, function() return eyes.Position end)
					--				while running do
					Tween(99, nil, function()
						if not running then return false end
						cam.CFrame = CFrame.new(camP, eyes.Position)
						--					stepped:wait()
					end, 205) -- priority 205 (camera)
					--				end
					spawn(function() _p.MasterControl:LookAt(absEnd) end)
					spawn(function() prof:LookAt(absEnd) end)
					local function absolLookAt(p)
						local cf = absol.Base.CFrame
						local lerp = select(2, Utilities.lerpCFrame(cf, CFrame.new(cf.p, Vector3.new(p.X, cf.p.Y, p.Z))))
						Tween(.4, 'easeOutCubic', function(a)
							absol.Base.CFrame = lerp(a)
						end)
					end
					spawn(function() absolLookAt(_p.player.Character.HumanoidRootPart.Position) end)
					tess:LookAt(absEnd)

					tess:Say(pName..', it\'s that Absol again!', 'It must have been following you.',
						'It doesn\'t seem to have a trainer...')

					wait(.2)
					eyes.EyesOpen.Face = Enum.NormalId.Left
					absSniffAnim:Play(0.1, 1, .5)
					schedule(absSniffAnim, 'End', 1.1/.5, sig.fire)
					sig:wait()
					wait(.25)
					eyes.EyesOpen.Face = Enum.NormalId.Right
					wait(.25)

					spawn(function() _p.MasterControl:LookAt(tp) end)
					spawn(function() prof:LookAt(fp) end)
					--]]
					local camCF = CFrame.new(cam.CFrame.p + Vector3.new(2.5, 1.5, 0), (ap + fp)/2 + Vector3.new(-1, 0, 0))
					--[ [
					spawn(function() Utilities.lookAt(cam.CFrame.p + Vector3.new(2.5, 1.5, 0), (ap + fp)/2 + Vector3.new(-1, 0, 0)) end)
					tess:Say(pName..', I think it wants to help you.', 'What\'s in the necklace it\'s wearing?',
						'Oh, '..pName..', that must be a Mega Stone!', 'Absol is one of few Pok[e\']mon that is known to be capable of Mega Evolving.',
						'In order to Mega Evolve a Pok[e\']mon, the Pok[e\']mon must be holding a Mega Stone, and its trainer must be holding a Key Stone.')
					Utilities.exclaim(tess.model.Head)
					tess:Say('I actually happen to have a Key Stone with me.', 'My father gave it to me before he disappeared, but I think you should use it.')

					onObtainKeyItemSound()
					chat:say('Obtained a Mega Key Stone!', pName .. ' put the Mega Key Stone in the Bag.')

					tess:Say('If Absol is willing to help us, then you can use Mega Evolution to your advantage!')

					spawn(function() _p.MasterControl:LookAt(absEnd) end)
					Sprite:playCry(.7, cry, .5)
					absCF = absol.Base.CFrame
					eyes.EyesOpen.Face = Enum.NormalId.Left
					Tween(1.5, nil, function(a)
						local h = .5 + 1-a
						absol.Base.CFrame = absCF + Vector3.new(0, h*math.abs(math.sin(math.pi*3)), 0)
					end)
					eyes.EyesOpen.Face = Enum.NormalId.Right
					wait(.4)

					--
					local d = _p.PlayerData:completeEvent('GetAbsol')
					if d then
						chat:say('Absol desires to join your team.',
							'Please choose a Pok[e\']mon to send to the PC.')
						local slot = _p.BattleGui:choosePokemon('Send', true)
						_p.Network:get('PDS', 'makeDecision', d, slot)
					else
						chat:say('Absol joined your team!')
					end
					--

					wait(1)
					spawn(function() _p.MasterControl:LookAt(proot.Position) end)
					spawn(function() tess:LookAt(proot.Position) end)
					spawn(function() absolLookAt(proot.Position) end)

					prof:Say('Even when equipped with Mega Evolution, you stand no chance against my power.',
						'My Pok[e\']mon shall be the tools in bringing about the liberation of Pok[e\']mon everywhere.',
						'You will be defeated, then you will fall with the other ignorant citizens of Anthian City.')
					for _, p in pairs(prof.model:GetChildren()) do if p:IsA('BasePart') and p ~= proot and p.Transparency >= .99 then p:remove() end end

					delay(1, function() absol:remove() end)
					local win = _p.Battle:doTrainerBattle {
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = prof.model,
						num = 105,
						battleSceneType = 'EclipsePark',
						musicId = 82634402287619,
						vs = {name = 'Prof. Cypress', id = 506375182, hue = 1/12}
					}
					if not win then
						_p.RunningShoes:enable()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
						return
					end
					-- just in case stuff gets unloaded when not used for a while ?
					_p.DataManager:preload(280857070, 507282487, 507289472, 334858056, 509072758, 509073816, 510817248)
					--]]
					dialgapalkia.Parent = map
					--[ [

					prof:Say('You may have won this battle, but you have lost the war.',
						'I still have the explosives in place and they will detonate as soon as we take off from this city.',
						'Team Eclipse cannot be stopped now.', 'We will find our new world!')
					tess:Say('No, please stop!', 'Think of all the people and Pok[e\']mon that will be removeed as a result of this!')
					prof:Say('Sacrifices must be made to bring justice to future generations.',
						'If it makes you feel any better, you can have this key to the energy core room.')

					onObtainKeyItemSound()
					chat:say('Obtained a Core Key!', pName .. ' put the Core Key in the Bag.')

					prof:Say('The bomb will have blown up by the time you can reach the room, but at least you will be able to watch the pretty light show from up close as the core melts down.',
						'Well, I must be off now.', 'I don\'t want to be here when the bomb goes off.')
					--]]

					spawn(function() Utilities.lookAt(fp + Vector3.new(6, 2, 0), scf.p - Vector3.new(0, 8, 0)) end)
					board(prof, false, true)

					Utilities.Sync {
						function()
							Tween(1, 'easeOutCubic', function(a)
								shipDoor.CFrame = scf * CFrame.new(0, 0, -11*(1-a))
							end)
						end,
						function()
							local ramp = map.EclipseShip.Ramp
							local cf = ramp.CFrame
							local offset = CFrame.new(0, ramp.Size.Y/2, 0)
							local hinge = cf * offset:inverse()
							local theta = math.acos(cf.upVector.X)
							Tween(.8, 'easeInOutCubic', function(a)
								ramp.CFrame = hinge * CFrame.Angles(0, 0, theta*a) * offset
							end)
							cf = ramp.CFrame
							Tween(.8, 'easeOutCubic', function(a)
								ramp.CFrame = cf + Vector3.new(-(ramp.Size.Y-1)*a, 0, 0)
							end)
						end
					}

					cam.CFrame = CFrame.new(-3978, 332, 2303, -.532, -.223, .816, 0, .965, .264, -.846, .140, -.514)

					local mcf = map.EclipseShip.Main.CFrame * CFrame.new(0, 0, 50)
					local shipParts = {}
					for _, ch in pairs(Utilities.GetDescendants(map.EclipseShip, 'BasePart')) do
						shipParts[ch] = mcf:toObjectSpace(ch.CFrame)
					end
					local function moveShipTo(cf)
						for p, rcf in pairs(shipParts) do
							p.CFrame = cf * rcf
						end
					end

					map.CLOUD.ParticleEmitter.Enabled = false
					local cf
					Tween(4, 'easeInSine', function(a)
						cf = mcf * CFrame.Angles(0, a*1.57, .6*math.sin(a*3.14)) + Vector3.new(300*(1-math.cos(a*1.57)), 0, 300*math.sin(a*1.57))
						moveShipTo(cf)
					end)
					mcf = map.EclipseShip.Main.CFrame * CFrame.new(0, 0, 50)
					_p.MusicManager:popMusic('Cutscene', 2, true)
					Tween(2, nil, function(_, t)
						cf = mcf + Vector3.new(135*t + 80*t*t, 0, 0)
						moveShipTo(cf)
					end)
					spawn(function() _p.MusicManager:returnFromSilence(.5) end)

					map.EclipseShip:remove()
					tess:LookAt(_p.player.Character.HumanoidRootPart.Position, 0)
					_p.MasterControl:LookAt(tess.model.HumanoidRootPart.Position, 0)

					cam.CFrame = camCF

					--[ [
					tess:Say('This is terrible, '..pName..'!',
						'They took Jake and now they\'re going to remove Anthian City, along with half of Roria.',
						'What do we do?!', 'There\'s not enough time to warn everyone.',
						'We need to figure out a...')
					--]]
					spawn(function() _p.MusicManager:prepareToStack(.5) end)
					--[ [
					local function shake(vig, dur)
						Tween(dur or 1.2, nil, function(a)
							local r = (1-a)*vig
							local t = math.random()*math.pi*2
							cam.CFrame = camCF * CFrame.new(math.cos(t)*r, 0, math.sin(t)*r)
						end)
					end
					local st = tick()
					Utilities.sound(507282487, nil, nil, 15)

					spawn(function() shake(1.5) end)
					delay(1, function() Utilities.exclaim(_p.player.Character.Head) end)
					delay(1, function() Utilities.exclaim(tess.model.Head) end)
					delay(2.37, function() shake(1.5) end)
					delay(4.5, function() shake(1) end)
					delay(6.3, function() shake(1) end)
					delay(7.9, function() shake(1) end)
					delay(10.2, function() shake(.5, .6) end)
					--0     big
					--2.37  big
					--4.5   med
					--6.3   med
					--7.9   med
					--10.2  sml

					local earthquakeSound
					delay(5.75, function()
						earthquakeSound = Utilities.loopSound(507289472)
						map.CutsceneCloud.ParticleEmitter.Enabled = true
					end)

					wait(2)
					tess:Say('It sounds like the explosives just detonated.', 'It might be too late!',
						pName..', I\'ve never been this scared before!', 'I can\'t move my legs.',
						'I can\'t believe this is how our adventure is going to end.')
					while tick()-st < 12 do wait() end
					tess:Say(pName..', I just want to thank you for...')
					--]]

					_p.Particles:new {
						Image = 280857070,
						Color = Color3.fromRGB(225, 208, 110),
						Position = _p.player.Character.HumanoidRootPart.CFrame * Vector3.new(0, .5, -1),
						MaxSize = 1,
						Size = _p.Particles:timedProperty{Function = function(a) return math.sin(a*math.pi) end},
						RotVelocity = 300,
						Acceleration = Vector3.new(0, 0, 0),
						Lifetime = 1,
					}
					spawn(function()
						local pulse = dialgapalkia.Portal.Main:Clone()
						pulse.Parent = map
						pulse.CFrame = _p.player.Character.HumanoidRootPart.CFrame * CFrame.new(0, .5, -1) * CFrame.Angles(1.57, 0, 0)
						pulse.BrickColor = BrickColor.new('Bright yellow')
						local mesh = pulse.Mesh
						Tween(.5, 'easeOutCubic', function(a)
							mesh.Scale = Vector3.new(a*5, a*5, 1)
							pulse.Transparency = a
							pulse.Reflectance = .5-.5*a
						end)
						pulse:remove()
					end)
					wait(.5)
					Utilities.exclaim(tess.model.Head)
					tess:Say(pName..', your necklace just sparkled!', 'What is it doing?')

					-- Dialga and Palkia
					_p.MusicManager:stackMusic(140468987287494, 'Cutscene')
					--				wait(.75)
					local function openPortal(pos)
						local portal = dialgapalkia.Portal:Clone()
						portal.Parent = map
						local sg = create 'SurfaceGui' {
							CanvasSize = Vector2.new(252, 252),
							Face = Enum.NormalId.Back,
							Adornee = portal.GuiPart,
							Parent = portal.GuiPart,
						}
						local anim = _p.AnimatedSprite:new {sheets={{id=509072758,rows=4},{id=509073816,rows=4},},nFrames=32,fWidth=252,fHeight=252,framesPerRow=4}
						anim.spriteLabel.Parent = sg
						anim:Play()
						local meshSize = portal.Main.Mesh.Scale
						local portalSize = portal.GuiPart.Size
						local scale
						--					local particlesEnabled = true
						--					spawn(function()
						--						while portal.Parent and particlesEnabled do
						--							if scale > .5 then
						--								local maxRad = portal.GuiPart.Size.X
						--								local r = math.random()*.7*maxRad
						--								local theta = math.random()*math.pi*2
						--								local x = r*.8
						--								local y = (maxRad-r)+1
						--								local t = .5
						--								local rDir = Vector3.new(math.cos(theta), 0, math.sin(theta))
						--								_p.Particles:new {
						--									Image = 334858056,
						--									Color = Color3.fromRGB(138, 64, 146),
						--									Position = pos + rDir*(r+x) + Vector3.new(0, 1-y, 0),
						--									Size = 1,
						--									Rotation = 360*math.random(),
						--									Velocity = x/t * -rDir,
						--									Acceleration = Vector3.new(0, 2*y/t/t, 0),
						--									Lifetime = 1,
						--								}
						--							end
						--							wait(.1)
						--						end
						--					end)
						Tween(1.5, 'easeOutCubic', function(a)
							scale = a*6+.1
							local cf = CFrame.new(pos) * CFrame.Angles(1.57, 0, -12*a)
							portal.Main.Mesh.Scale = meshSize * scale
							portal.GuiPart.Size = Vector3.new(portalSize.X*scale, portalSize.Y*scale, .2)
							portal.Main.CFrame = cf
							portal.GuiPart.CFrame = cf + Vector3.new(0, .1, 0)
						end)
						return function()
							--						particlesEnabled = false
							Tween(1.5, 'easeOutCubic', function(a)
								scale = (1-a)*6+.1
								local cf = CFrame.new(pos) * CFrame.Angles(1.57, 0, -12-12*a)
								portal.Main.Mesh.Scale = meshSize * scale
								portal.GuiPart.Size = Vector3.new(portalSize.X*scale, portalSize.Y*scale, .2)
								portal.Main.CFrame = cf
								portal.GuiPart.CFrame = cf + Vector3.new(0, .1, 0)
							end)
							portal:remove()
						end
					end
					local dialgaCF = CFrame.new(fp + Vector3.new(-8, 0,  20), fp) + Vector3.new(0, 237.8-fp.Y, 0)
					local palkiaCF = CFrame.new(fp + Vector3.new(-8, 0, -20), fp) + Vector3.new(0, 237.8-fp.Y, 0)

					local anims = {
						dIdle  = dialgapalkia.Dialga.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.dialgaIdle }),
						dHover = dialgapalkia.Dialga.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.dialgaHover }),
						--					dLand  = dialgapalkia.Dialga.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.dialgaLand }),
						dRoar1 = dialgapalkia.Dialga.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.dialgaRoarAir }),
						dRoar2 = dialgapalkia.Dialga.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.dialgaRoarGround }),

						pIdle  = dialgapalkia.Palkia.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.palkiaIdle }),
						pHover = dialgapalkia.Palkia.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.palkiaHover }),
						--					pLand  = dialgapalkia.Palkia.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.palkiaLand }),
						pRoar1 = dialgapalkia.Palkia.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.palkiaRoarAir }),
						pRoar2 = dialgapalkia.Palkia.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.palkiaRoarGround }),
					}
					local dCry = {id = 18856423150, duration = 1.57, startTime = 2.21}
					local pCry = {id = 18856423150, duration = 1.63, startTime = 4.79}

					local camPos = camCF.p

					local roarDur = 3
					local comeThroughPortalDur = 3

					spawn(function() tess:LookAt(dialgaCF.p) end)
					Utilities.lookAt(camPos + Vector3.new(10, 5, 5), dialgaCF.p + Vector3.new(0, 25, 0), 2.5)
					local dPortal = openPortal(dialgaCF.p + Vector3.new(0, 36.5, 0))
					anims.dHover:Play()
					delay(comeThroughPortalDur/2, function() anims.dRoar1:Play(nil, nil, 6/roarDur) end)
					delay(comeThroughPortalDur/2+.25, function() Sprite:playCry(.6, dCry, .65) end)
					delay(2, dPortal)
					Tween(comeThroughPortalDur, 'easeOutCubic', function(a)
						dialgapalkia.Dialga.Base.CFrame = dialgaCF + Vector3.new(0, 37.5*(1-a), 0)
					end)
					wait(roarDur-comeThroughPortalDur/2)
					anims.dHover:Stop()
					anims.dIdle:Play()

					spawn(function() _p.MasterControl:LookAt(palkiaCF.p) end)
					Utilities.lookAt(camPos + Vector3.new(10, 5, -5), palkiaCF.p + Vector3.new(0, 25, 0), 2.5)
					local pPortal = openPortal(palkiaCF.p + Vector3.new(0, 36.5, 0))
					anims.pHover:Play()
					delay(comeThroughPortalDur/2, function() anims.pRoar1:Play(nil, nil, 6/roarDur) end)
					delay(comeThroughPortalDur/2+.25, function() Sprite:playCry(.6, pCry, .65) end)
					delay(2, pPortal)
					Tween(comeThroughPortalDur, 'easeOutCubic', function(a)
						dialgapalkia.Palkia.Base.CFrame = palkiaCF + Vector3.new(0, 37.5*(1-a), 0)
					end)
					wait(roarDur-comeThroughPortalDur/2)
					anims.pHover:Stop()
					anims.pIdle:Play()

					Utilities.lookAt(camPos + Vector3.new(10, 5, 0), fp + Vector3.new(0, 5, 0))

					pp = _p.player.Character.HumanoidRootPart.Position
					tp = tess.model.HumanoidRootPart.Position

					chat.bottom = true
					tess:Say('I can\'t believe what we are witnessing!',
						'The Legendary Dragon-type Pok[e\']mon Dialga and Palkia have just appeared before us!',
						'According to legend, they have control over time and space.', 'What called them here, though?')
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:LookAt(pp)
					tess:Say('Wait, could it have been your necklace?', 'It glowed right before they appeared.',
						'Well, whatever happened, this is a pretty big deal.', 'We could really use their help right now.')

					map.CutsceneCloud.ParticleEmitter.Enabled = false
					spawn(function() _p.MasterControl:LookAt(palkiaCF.p) end)
					Utilities.lookAt(camPos + Vector3.new(10, 5, 0), palkiaCF.p + Vector3.new(0, 10, 0), 1)
					anims.pRoar2:Play(nil, nil, 4/roarDur)
					delay(.5, function() earthquakeSound:remove() end)
					delay(.4, function()
						Sprite:playCry(.6, pCry, .65)
						local core = dialgapalkia.Palkia:FindFirstChild('CorePart', true)
						local pulse = create 'Part' {
							Anchored = true,
							CanCollide = false,
							BrickColor = BrickColor.new('Sunrise'),
							TopSurface = Enum.SurfaceType.Smooth,
							BottomSurface = Enum.SurfaceType.Smooth,
							Material = Enum.Material.Neon,
							Shape = Enum.PartType.Ball,
							Parent = map
						}
						wait(.3)
						Tween(.7, nil, function(a)
							pulse.Size = Vector3.new(a*69, a*69, a*69)
							pulse.CFrame = core.CFrame
							pulse.Transparency = .5+.5*a
						end)
						pulse:remove()
					end)
					wait(roarDur)
					Utilities.lookAt(camPos + Vector3.new(10, 5, 0), fp + Vector3.new(0, 5, 0))
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:Say('Whoa!', 'Palkia\'s roar seems to have temporarily stabilized the city.',
						'This might buy us some time.', 'Now we just need to figure out a way to save everyone.')

					spawn(function() tess:LookAt(dialgaCF.p) end)
					Utilities.lookAt(camPos + Vector3.new(10, 5, 0), dialgaCF.p + Vector3.new(0, 10, 0), 1)
					anims.dRoar2:Play(nil, nil, 5.5/roarDur)
					delay(.6, function()
						Sprite:playCry(.6, dCry, .65)
						local core = dialgapalkia.Dialga:FindFirstChild('CorePart', true)
						local pulse = create 'Part' {
							Anchored = true,
							CanCollide = false,
							BrickColor = BrickColor.new('Electric blue'),
							TopSurface = Enum.SurfaceType.Smooth,
							BottomSurface = Enum.SurfaceType.Smooth,
							Material = Enum.Material.Neon,
							Shape = Enum.PartType.Ball,
							Parent = map
						}
						wait(.4)
						Tween(.7, nil, function(a)
							pulse.Size = Vector3.new(a*69, a*69, a*69)
							pulse.CFrame = core.CFrame
							pulse.Transparency = .5+.5*a
						end)
						pulse:remove()
					end)
					wait(roarDur)
					spawn(function() Utilities.lookAt(camPos + Vector3.new(10, 5, 0), fp + Vector3.new(0, 5, 0)) end)

					-- portal opens beneath player & tess
					local portalPos = (tp+pp)/2
					portalPos = portalPos + Vector3.new(0, 238-portalPos.Y, 0)
					local portal = dialgapalkia.Portal:Clone()
					portal.Parent = map
					local sg = create 'SurfaceGui' {
						CanvasSize = Vector2.new(252, 252),
						Face = Enum.NormalId.Front,
						Adornee = portal.GuiPart,
						Parent = portal.GuiPart,
					}
					local anim = _p.AnimatedSprite:new {sheets={{id=509072758,rows=4},{id=509073816,rows=4},},nFrames=32,fWidth=252,fHeight=252,framesPerRow=4}
					anim.spriteLabel.Parent = sg
					anim:Play()
					local meshSize = portal.Main.Mesh.Scale
					local portalSize = portal.GuiPart.Size
					Tween(1.5, 'easeOutCubic', function(a)
						local scale = a*3.5+.1
						local cf = CFrame.new(portalPos) * CFrame.Angles(1.57, 0, -12*a)
						portal.Main.Mesh.Scale = meshSize * scale
						portal.GuiPart.Size = Vector3.new(portalSize.X*scale, portalSize.Y*scale, .2)
						portal.Main.CFrame = cf
						portal.GuiPart.CFrame = cf + Vector3.new(0, -.1, 0)
					end)
					spawn(function() Utilities.exclaim(tess.model.Head) end)
					spawn(function() Utilities.exclaim(_p.player.Character.Head) end)
					wait(.5)
					proot = _p.player.Character.HumanoidRootPart
					local troot = tess.model.HumanoidRootPart

					-- fall
					proot.Anchored, troot.Anchored = true, true
					for _, p in pairs(map.CutsceneFloor:GetChildren()) do pcall(function() p.CanCollide = false end) end
					local a = 50
					local v = 0
					local d = 0
					local lt = tick()
					while true do
						stepped:wait()
						local now = tick()
						local dt = now-lt
						lt = now
						v = v + a*dt
						d = d + v*dt
						proot.CFrame = proot.CFrame + Vector3.new(0, -v*dt, 0)
						troot.CFrame = troot.CFrame + Vector3.new(0, -v*dt, 0)
						if d >= 8 then break end
					end
					--]=]
					-- for test purposes --
					--	local tess = chunk.npcs.Tess
					--	local cam = workspace.CurrentCamera
					--	_p.PlayerData:addBagItems({id = ids.corekey, quantity = 1})
					-- end test portion  --

					wait(.5)
					_p.MusicManager:popMusic('RegionMusic', 1, true) -- should pop both cutscene and park musics
					Utilities.FadeOut(1)

					chat.bottom = nil
					chunk:remove() -- no need to tp to spawn box, you're anchored

					chunk = _p.DataManager:loadMap('chunk23', {inPast = true, ignoreNPCs = true})
					completedEvents.EnteredPast = true

					cam.CameraType = Enum.CameraType.Custom
					Utilities.Teleport(CFrame.new(-130, 75, 947) * CFrame.Angles(0, 3.1, 0))
					wait()
					proot.Anchored = false

					tess = chunk.npcs.Tess
					wait(.5)
					Utilities.FadeIn(1)
					wait(.5)
					--[ [
					tess:Say('What just happened?', 'We\'re back in the sewers.',
						'Look around, everything appears to be frozen, as if time itself has stopped.',
						'This must be the power of Dialga.', 'Oh look at the time!',
						'My watch is frozen on the time just right as we showed up in Anthian Park to find Jake.',
						'But why would Dialga send us back here?',
						'Oh! I got it!', 'Dialga must want us to stop the Team Eclipse Admin from planting those explosives.',
						'And as luck would have it, Professor Cypress gave you the key to get into the energy core room.',
						'We have what we need to save the city.', 'Let\'s hurry to the core room and stop Team Eclipse!',
						'The core room should be on the other side of the sewers, close to where we first entered from behind Gerald\'s shop.')
					--]]

					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
					chat:enable()
				end)
			else
				-- clean up clean up, everybody everywhere
				chunk.npcs.EclipseGrunt1:remove()
				chunk.npcs.EclipseGrunt2:remove()
				chunk.npcs.EclipseGrunt3:remove()
				chunk.npcs.EclipseAdmin1:remove()
				chunk.npcs.EclipseAdmin2:remove()
				chunk.npcs.Professor:remove()
				chunk.npcs.ProfessorLoader:remove()
				chunk.npcs.Jake:remove()
				chunk.npcs.Tyler:remove()
				map.Absol:remove()
				map.EclipseShip:remove()

				if data and data.teleportAfterBeatingTyler then
					--				local tp = Vector3.new(-4282, 241, 2389)
					--				chunk.npcs.Tess:Teleport(CFrame.new(tp, tp + Vector3.new(0, 0, -1)))
				else
					chunk.npcs.Tess:remove()
					chunk.npcs.Gerald:remove()
				end
			end
			-- Christmas 2016 Event
--[[
local lawyer = chunk.npcs.EventLawyer
interact[lawyer.model] = function()
if completedEvents.NiceListReward then
	lawyer:Say('Thanks again for the help with Santa.',
		'I wish I could have seen the look on his face when you beat him in that battle.')
elseif completedEvents.BeatSanta then
	lawyer:Say('Oh, you\'re back.', 'Did you find Santa?',
		'You did?! Well what did he say?',
		'You had to fight him in order to secure me a position back on the nice list?',
		'That sounds just like him.', 'I can\'t thank you enough.',
		'Your help really means a lot to me.',
		'As I promised, I have two very special Pok[e\']mon for you to choose from.',
		'You may only have one, so pick carefully.',
		'These Pok[e\']mon have adapted to the climate of a far away region.',
		'I have a Sandshrew and a Vulpix.', 'Which would you like?')
	local choice = _p.NPCChat:choose('Sandshrew', 'Vulpix')
	local msg = _p.PlayerData:completeEvent('NiceListReward', choice)
	if msg then chat:say(msg) end
	lawyer:Say('Excellent choice.', 'That Pok[e\']mon is very special.',
		'Treat it kindly.', 'And remember, kid, if you\'re ever in any trouble with the law, come look me up.')
else
	if not completedEvents.LearnAboutSanta then
		spawn(function() _p.PlayerData:completeEvent('LearnAboutSanta') end)
		lawyer:Say('Looks like it\'ll be another year without presents for me.',
			'What\'s wrong, you look confused?',
			'Don\'t tell me you don\'t know about Santa.',
			'Santa is the fiercest winter trainer in all of Roria.',
			'He\'s also a jolly old man that leaves presents for you every year around this time.',
			'Sadly enough, I\'ve been on the naughty list ever since I quit my job as a dentist and became a lawyer.',
			'He\'s been leaving Charcoal in my stocking for years, and I don\'t even have any Fire-type Pok[e\']mon.',
			'Hey, I have an idea.', 'You\'re a trainer right?',
			'Would you help me out and go talk to Santa for me?',
			'I\'d talk to him myself, but I hear he only respects strong trainers.',
			'If you can talk the old guy into putting me back on his nice list, I would be incredibly grateful!',
			'In fact, I might just have a reward for you!',
			'I recently took a vacation to the Alola region and did a little collecting while I was there.',
			'I wouldn\'t mind sharing from my collection.',
			'So what do you say?', 'Will you help me?')
	end
	lawyer:Say('You\'re probably wondering where to find Santa.',
		'From what I\'ve heard, he likes to come out at night.',
		'He can usually be found on peoples\' rooftops.',
		'If you\'re passing through a town, make sure and scope out the homes in the area.',
		'And don\'t forget, if he agrees to put me on the nice list, come back and let me know.',
		'I\'ll have something nice for you.')
end
end
--]]
		end,

		onLoad_chunk23 = function(chunk, data)
			local map = chunk.map
			--		local bd = _p.PlayerData:getBagDataById(ids.corekey, 5)
			if not completedEvents.EnteredPast then--if not bd or not bd.quantity or bd.quantity < 1 then
				-- Assume that EnteredPast == hasCoreKey
				chunk:getDoor('EnergyCore').locked = true
			end
			if (data and data.inPast) or (completedEvents.EnteredPast and not completedEvents.DefeatTEinAC) then
				_p.DataManager.ignoreRegionChangeFlag = true
				chunk.data.regions['Anthian Sewer'].Grass = nil
				game:GetService('Lighting').ColorCorrection.Saturation = -1
				chunk:getDoor('C_chunk20').locked = true
				chunk:getDoor('C_chunk22').locked = true

				local tess = _p.NPC:new(chunk.map.Tess)
				tess:Animate()
				chunk.npcs.Tess = tess
				if data and data.inPast then -- just teleported as opposed to saved & loaded
					tess:Teleport(CFrame.new(-130, 75, 951))
				end
				tess:StartFollowingPlayer()

				local particles = {}
				for _, pe in pairs(Utilities.GetDescendants(map, 'ParticleEmitter')) do
					if pe.Enabled then
						table.insert(particles, pe)
						pe.Enabled = false
					end
				end
				local interacts = {}
				while true do
					local interact = map:FindFirstChild('Interact', true)
					if not interact then break end
					table.insert(interacts, interact)
					interact.Parent = nil
				end
			else
				-- crazy john
				spawn(function()
					local shed = map.John
					local mcf = shed.HumanoidRootPart.CFrame * CFrame.new(0, -1, .5)
					local parts = {}
					for _, ch in pairs(shed:GetChildren()) do
						if ch:IsA('BasePart') then
							parts[ch] = mcf:toObjectSpace(ch.CFrame)
						end
					end
					mcf = mcf * CFrame.Angles(-.15, 0, 0)
					while map.Parent do
						local cf = mcf * CFrame.Angles(math.sin(tick()*2)*.15, 0, 0)
						for p, rcf in pairs(parts) do
							p.CFrame = cf:toWorldSpace(rcf)
						end
						heartbeat:wait()
					end
				end)
				-- locker door
				local ld = map.LockerDoor
				chat.silentInteract[ld] = function()
					chat.silentInteract[ld] = nil
					local hinge = map.LockerDoor.Hinge
					local cf = hinge.CFrame
					Tween(1, 'easeOutCubic', function(a)
						Utilities.MoveModel(hinge, cf * CFrame.Angles(0, -2*a, 0))
					end)
				end
				-- tess follow
				local tess = chunk.npcs.Tess
				local function connectTessStopTrigger()
					touchEvent('TessEndFollow', chunk.map.TessStopTrigger, true, function()
						spawn(function() _p.Menu:disable() end)
						local pp = _p.player.Character.HumanoidRootPart.Position
						if pp.X > -173.1 then return end
						_p.MasterControl.WalkEnabled = false
						_p.MasterControl:Stop()
						pp = Vector3.new(-176.4, 72, 931.6)
						local tp = Vector3.new(-181.4, 72, 931.6)
						tess:StopFollowingPlayer()
						wait()
						_p.Battle.npcPartner = nil
						Utilities.Sync {
							function()
								_p.MasterControl:WalkTo(pp)
								_p.MasterControl:LookAt(tp)
							end,
							function()
								tess:WalkTo(tp)
								tess:LookAt(pp)
							end,
						}
						tess:Say('I think this is the end of the sewers.',
							'I can hear wind.',
							'The park district must be on the other side of this door.',
							'Let\'s go make sure Jake is okay!')
						local door = chunk:getDoor('C_chunk22')
						spawn(function() _p.MasterControl:LookAt(door.Position) end)
						tess:WalkTo(Vector3.new(-179, 72, 938.6))
						tess:WalkTo(door.Position + Vector3.new(0, 0, -2))
						door:open(.5)
						delay(.5, function()
							door:close(.5)
							tess:Stop()
							wait()
							tess:remove()
						end)
						tess:WalkTo(door.Position + Vector3.new(0, 0, 15))
						wait(.5)
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						_p.Menu:enable()
					end)
				end
				local function tessStartTriggeredFirstTime()
					interact[tess.model] = nil
					tess:Say('Ew, it smells awful down here.',
						'Let\'s try and make it out the other side as quickly as we can.',
						'You go ahead and lead, and I will follow.')
					-- if need heal, do it now
					tess:StartFollowingPlayer()
					_p.Battle.npcPartner = 'tessChunk23'
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					connectTessStopTrigger()
				end
				if completedEvents.TessEndFollow then
					tess:remove()
				elseif completedEvents.TessStartFollow then
					tess:Teleport(CFrame.new(10.8, 73, 680, -.351, .001, .936, -.001, 1, -.001, -.936, -.001, -.351))
					delay(1, function()
						repeat wait() until _p.MasterControl.WalkEnabled
						tess:StartFollowingPlayer()
						_p.Battle.npcPartner = 'tessChunk23'
					end)
					connectTessStopTrigger()
				else
					touchEvent('TessStartFollow', chunk.map.TessFollowTrigger, true, function()
						_p.MasterControl.WalkEnabled = false
						_p.MasterControl:Stop()
						local pp = _p.player.Character.HumanoidRootPart.Position
						spawn(function() tess:LookAt(pp) end)
						local tp = tess.model.HumanoidRootPart.Position
						spawn(function() _p.MasterControl:LookAt(tp) end)
						tessStartTriggeredFirstTime()
					end)
					interact[tess.model] = function()
						if completedEvents.TessStartFollow then return end
						completedEvents.TessStartFollow = true
						tessStartTriggeredFirstTime()
					end
				end
			end
		end,

		onDoorFocused_C_chunk20 = function()
			if _p.DataManager.currentChunk.id ~= 'chunk23' then return end
			if completedEvents.TessEndFollow or not completedEvents.TessStartFollow then return end
			pcall(function()
				local tess = _p.DataManager.currentChunk.npcs.Tess
				tess:Say('I\'ll wait for you here.',
					'Hurry back, though, Jake needs our help!')
				tess:StopFollowingPlayer()
				_p.Battle.npcPartner = nil
			end)
		end,

		onBeforeEnter_EnergyCore = function(room)
			local model = room.model
			if completedEvents.DefeatTEinAC then
				model.Explosives:remove()
				room.npcs.Tyler:remove()
			elseif completedEvents.EnteredPast then
				local triggered = false
				touchEvent(nil, model.TylerTrigger, nil, function()
					if triggered then return end
					triggered = true

					spawn(function() _p.Menu:disable() end)
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					_p.RunningShoes:disable()

					local pName = _p.PlayerData.trainerName

					local tess = _p.DataManager.currentChunk.npcs.Tess
					tess:StopFollowingPlayer()
					spawn(function() _p.MasterControl:LookAt(tess.model.HumanoidRootPart.Position) end)
					tess:LookAt(_p.player.Character.HumanoidRootPart.Position)

					tess:Say('There\'s the Eclipse goon setting up the explosives now.',
						'Now is our chance to stop him.')

					local cc = game:GetService('Lighting').ColorCorrection
					Tween(1, 'easeOutCubic', function(a)
						cc.Saturation = -1 + 1.31*a
					end)
					spawn(function() Utilities.exclaim(tess.model.Head) end)
					Utilities.exclaim(_p.player.Character.Head)
					wait(.25)
					tess:Say('It looks like time has resumed.',
						'We have to stop him now!')

					local tyler = room.npcs.Tyler
					spawn(function() tess:WalkTo(tyler.model.HumanoidRootPart.Position + Vector3.new(0, 0, -9)) end)
					_p.MasterControl:WalkTo(tyler.model.HumanoidRootPart.Position + Vector3.new(0, 0, -5))

					tyler:Say('Is it red in, green out...?', '...or green in, red out?',
						'Well, it\'s fifty/fifty...')
					Utilities.exclaim(tyler.model.Hat)
					tyler:Look(Vector3.new(0, 0, -1))
					--[ [
					tyler:Say('Hey, how did you two get in here?')
					tess:Say('It doesn\'t matter, we\'re here to stop you.')
					tyler:Say('Oh you are?', 'Well I\'ll have you know that I\'m a Team Eclipse admin.',
						'I\'m not exactly a pushover.', 'If you want to stop me right now, you\'ll have to beat me in a battle.')
					tess:Say('That\'s not a problem.',
						pName..' will certainly beat you, and when the battle is over you will pack up here and leave for good.')
					tyler:Say('My my, you\'re a sassy one.', 'Something must have made you really angry before getting here...')
					tess:Say('Yeah, you could say that.', 'We don\'t have much time, so let\'s get this show on the road.')
					tyler:Say('Say no more.', 'You\'re in for some disappointment.')



					local bdata; bdata = {
						IconId = 5226446131,
						musicId = 12639846584,
						PreventMoveAfter = true,
						trainerModel = tyler.model,
						num = 106,
						battleSceneType = 'CoreRoom',
						blackoutHandler = function()
							-- if black out then teleport you and tess back outside core room
							-- BattleEngine *should* automatically heal you when you blackout
							local chunk = _p.DataManager.currentChunk
							chunk.indoors = false
							chunk:unbindIndoorCam()
							for _, r in pairs(chunk.roomStack) do r:remove() end
							chunk.roomStack = {}

							Utilities.Teleport(CFrame.new(-96, 73, 706))
							tess:Teleport(CFrame.new(-96, 73, 710))
							cc.Saturation = -1

							bdata.PreventMoveAfter = false
							_p.RunningShoes:enable()
							chat:enable()
						end
					}
					local win = _p.Battle:doTrainerBattle(bdata)
					if not win then return end -- note blackout handler above

					tyler:Say('Wow, I really underestimated this situation.', 'You beat me, kid.',
						'Don\'t get too excited, though.', 'Team Eclipse still got what they wanted here.',
						'We came for a priceless artifact that will help us reach a new world.',
						'The plan to remove the city may have been compromised, but the plan to remove this world is still in effect.',
						'I must be going now.')
					--]]

					Utilities.FadeOut(.6)
					model.Explosives:remove()
					tyler:remove()
					_p.MasterControl:Look(Vector3.new(0, 0, -1), 1) -- waits 1
					Utilities.FadeIn(.6)
					wait(.25)

					tess:Say('We did it, '..pName..', we saved the city!',
						'I cannot believe that this all happened and that we were able to help!')

					local proot, troot = _p.player.Character.HumanoidRootPart, tess.model.HumanoidRootPart
					-- portal opens beneath player & tess
					local portalPos = (proot.Position+troot.Position)/2 + Vector3.new(0, -3, 0)

					local portal = model.Portal:Clone()
					portal.Parent = model
					local sg = create 'SurfaceGui' {
						CanvasSize = Vector2.new(252, 252),
						Face = Enum.NormalId.Front,
						Adornee = portal.GuiPart,
						Parent = portal.GuiPart,
					}
					local anim = _p.AnimatedSprite:new {sheets={{id=509072758,rows=4},{id=509073816,rows=4},},nFrames=32,fWidth=252,fHeight=252,framesPerRow=4}
					anim.spriteLabel.Parent = sg
					anim:Play()
					local meshSize = portal.Main.Mesh.Scale
					local portalSize = portal.GuiPart.Size
					Tween(1.5, 'easeOutCubic', function(a)
						local scale = a*3.5+.1
						local cf = CFrame.new(portalPos) * CFrame.Angles(1.57, 0, -12*a)
						portal.Main.Mesh.Scale = meshSize * scale
						portal.GuiPart.Size = Vector3.new(portalSize.X*scale, portalSize.Y*scale, .2)
						portal.Main.CFrame = cf
						portal.GuiPart.CFrame = cf + Vector3.new(0, -.1, 0)
					end)
					spawn(function() Utilities.exclaim(tess.model.Head) end)
					spawn(function() Utilities.exclaim(_p.player.Character.Head) end)
					wait(.5)

					-- fall
					proot.Anchored, troot.Anchored = true, true
					for _, p in pairs(model.CutsceneFloor:GetChildren()) do pcall(function() p.CanCollide = false end) end
					local a = 50
					local v = 0
					local d = 0
					local lt = tick()
					while true do
						stepped:wait()
						local now = tick()
						local dt = now-lt
						lt = now
						v = v + a*dt
						d = d + v*dt
						proot.CFrame = proot.CFrame + Vector3.new(0, -v*dt, 0)
						troot.CFrame = troot.CFrame + Vector3.new(0, -v*dt, 0)
						if d >= 8 then break end
					end

					_p.MusicManager:popMusic('RegionMusic', 1, true) -- should pop chunk music (and room if applic.)
					Utilities.FadeOut(1)

					_p.DataManager.currentChunk:remove() -- no need to tp to spawn box, you're anchored

					local chunk = _p.DataManager:loadMap('chunk22', {teleportAfterBeatingTyler = true})
					local pp = Vector3.new(-4282, 241, 2384)
					local tp = Vector3.new(-4282, 241, 2389)
					Utilities.Teleport(CFrame.new(pp, tp))
					wait()
					proot.Anchored = false

					tess = chunk.npcs.Tess
					tess:Teleport(CFrame.new(tp, pp))
					wait(.5)

					local cam = workspace.CurrentCamera
					cam.CameraType = Enum.CameraType.Scriptable
					local fp = (tp+pp)/2 + Vector3.new(0, 1.5, 0)
					local camCF = CFrame.new(fp + Vector3.new(4, 3, 2).unit * 15, fp)
					cam.CFrame = camCF

					Utilities.FadeIn(1)
					wait(.5)

					tess:Say('Hey, it looks like we\'re back now, and the city is safe.',
						'We may have saved the city, but Team Eclipse was still able to get away with Jake.',
						'I feel horrible right now.', 'He was only trying to help protect us and now he\'s gone.',
						'If only I had been there to stop him...', 'We have to save him, '..pName..', along with your family.',
						'I will do whatever it takes right now to help get them back.',
						'Team Eclipse made a big mistake by messing with my friends.', 'They won\'t get away with this.')
					delay(.75, function() Utilities.exclaim(_p.player.Character.Head) end)
					delay(.75, function() Utilities.exclaim(tess.model.Head) end)
					chat:say('Worry not, kids, there is still time to save your friend.')
					spawn(function() Utilities.lookAt(camCF + Vector3.new(3, 0, 0)) end)
					local gp = fp + Vector3.new(6, 0, 0)
					spawn(function() _p.MasterControl:LookAt(gp) end)
					spawn(function() tess:LookAt(gp) end)
					local gerald = chunk.npcs.Gerald
					gerald:Teleport(CFrame.new(gp + Vector3.new(12, 0, 0), gp))
					gerald:WalkTo(gp)
					tess:Say('Oh, Gerald... what do you mean there is still time?',
						'What did you find out?')
					gerald:Say('I did some research on the item that Team Eclipse stole from the museum.',
						'It turns out the prison bottle is part of an ancient legend surrounding the mythical Pok[e\']mon Hoopa.',
						'Legends say that the bottle is used to unleash Hoopa\'s true strength.')
					tess:Say('Yes, Professor Cypress did mention that Pok[e\']mon.',
						'He said that they plan to use it to take themselves and Pok[e\']mon to a new world.')
					gerald:Say('Yes, it is true that this is the power of Hoopa.', 'It can open portals to new worlds.',
						'What they don\'t know is that they are still missing a piece of the puzzle for uncovering Hoopa\'s location.')
					tess:Say('What do you mean?', 'They have the bottle, don\'t they?', 'Isn\'t that all they need?')
					gerald:Say('The bottle simply releases Hoopa from its bound form.',
						'What Team Eclipse doesn\'t know is that Hoopa is asleep, sealed in a sort of tomb.',
						'You see, a legend says that long ago, Hoopa was with great power but lacked any control over itself and caused much destruction.',
						'The all-powerful Pok[e\']mon Arceus saw this and decided to cut off the raw power from Hoopa by sealing its power away in the prison bottle.',
						'As an added measure, Arceus sealed away Hoopa in a tomb somewhere beneath Crescent Island, and created a special key to open it.',
						'Your parents were smart enough to only give Team Eclipse half the information they needed to get Hoopa.')
					tess:Say('So Team Eclipse still doesn\'t have the key to open Hoopa\'s tomb?')
					gerald:Say('Correct.', 'In truth, I believe that '..pName..'\'s parents had found the key and hid it somewhere...',
						'...somewhere in plain sight.', '...somewhere that Team Eclipse would never think to look.')
					tess:Say('What does the key look like?')
					gerald:Say('There are several old tales about the key.',
						'Some say that it\'s a large, golden key.', 'Others believe it\'s metaphorical, like a password.',
						'According to an article written by '..pName..'\'s parents, it could be a small brick.')
					tess:Say('Wait, a small brick?', 'No, it couldn\'t be.')
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:LookAt(pp)
					tess:Say(pName..', you don\'t think the necklace your parents made you could be the key, do you?')
					spawn(function() _p.MasterControl:LookAt(gp) end)
					gerald:LookAt(pp)
					gerald:Say('Well I\'ll be.',
						'Your parents must have found the key and given it to you, knowing that someone would come after them for it.',
						'They are absolute geniuses.', 'Nobody would suspect a child would be carrying the key to the tomb of Hoopa.')
					tess:Say('Your necklace must be the key.', 'That would explain how it called upon Dialga and Palkia to aid us.',
						'It\'s imbued with powers because it was crafted by Arceus.')
					spawn(function() gerald:LookAt(tp) end)
					gerald:Say('What\'s this about Palkia and Dialga?')
					spawn(function() tess:LookAt(gp) end)
					tess:Say('Oh, nothing...')
					spawn(function() gerald:LookAt((tp+pp)/2) end)
					gerald:Say('Alright, well I think we know what needs to happen next.',
						pName..', it\'s going to be up to you now to go after Team Eclipse and save Jake and your parents.',
						'You\'ve proven how strong you are and I have a good feeling that there is nobody better for the job than you.')
					tess:LookAt(pp)
					tess:Say('Gerald is right, '..pName..'.', 'You are probably the only person right now that can stop them.',
						'You\'ve already stopped them so many times from causing so much destruction.')
					spawn(function() tess:LookAt(gp) end)
					gerald:Say('You will need to travel to Crescent Island.', 'I believe that is where they have set up their base of operations.',
						'It would make sense, given that it\'s the location of Hoopa\'s tomb.',
						'Unfortunately you cannot fly there.', 'The winds around the island are far too strong.',
						'You will have to sail there from Port Decca.', 'Port Decca is on the east coast of Roria.',
						'Getting there will require you to go back to the Cragonos Peaks and take the Sky Train down to Route 11.',
						'From there, you will have to travel through several roads and cities.',
						'Here, you\'ll need this pass to be able to access the Sky Train.')

					onObtainKeyItemSound()
					chat:say('Obtained a Sky Train Pass!', pName..' put the Sky Train Pass in the Bag.')

					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:LookAt(pp)
					tess:Say(pName..', I think I will stay here for now with Gerald.',
						'I want to aid him in finding more information that will help us find Team Eclipse.',
						'I want nothing more right now that to rescue my friend in need.',
						'Jake was the best friend I\'ve ever had and I must repay his kindness.',
						'When we find more information I will fly to you immediately and share what I can.',
						'Oh, speaking of which, I want you to have this.')

					onObtainItemSound()
					chat:say('Obtained an HM02!', pName..' put the HM02 in the Bag.')

					tess:Say('That HM contains Fly.', 'You can use Fly to travel quickly, but only to cities you\'ve visited before.')
					spawn(function() tess:LookAt(gp) end)
					spawn(function() _p.MasterControl:LookAt(gp) end)
					gerald:Say('That is a wonderful idea.', 'Tess and I will be searching hard for critical details.',
						'When we find something, you will be the first person to know.',
						'We will all be working together to keep Roria safe.',
						'There\'s no telling what catastrophic effects would occur if Team Eclipse manages to leave this world with the Pok[e\']mon.',
						'Well then, I think it\'s time we get to searching for helpful information.',
						'If you want to talk again before you leave, you can find me at the Pok[e\'] Ball shop.')
					spawn(function()
						gerald:WalkTo(gp + Vector3.new(12, 0, 0))
						gerald:remove()
					end)
					tess:Say('Alright Gerald, I\'ll be right there.')
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:LookAt(pp)
					tess:Say(pName..', I believe in you.', 'I know that together we can find and save Jake and your parents.',
						'I will be doing my best to help any way I can.',
						'I didn\'t get to finish saying this earlier, because we were interrupted by doom and destruction, but thank you for being such a great friend.',
						'This short journey has already taught me so much, and my greatest lesson learned is how important my friends are.',
						'Together we are strong.', 'So let\'s get Jake back.', 'I\'ll see you later, '..pName..'.')
					tess:WalkTo(tp + Vector3.new(14, 0, 5))
					tess:remove()
					cam.CameraType = Enum.CameraType.Custom

					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
					chat:enable()
				end)
			end
		end,

		onLoad_chunk24 = function(chunk)
			local map = chunk.map
			-- sand
			local root = _p.player.Character.HumanoidRootPart
			local human = Utilities.getHumanoid()
			local inSand = false
			local yPos = 53
			if human.RigType == Enum.HumanoidRigType.R15 then
				yPos = 50 + root.Size.Y/2+human.HipHeight
			end
			local run = _p.RunningShoes
			local connections = {}
			table.insert(connections, heartbeat:connect(function()
				if not map.Parent then
					for _, cn in pairs(connections) do
						pcall(function() cn:disconnect() end)
					end
					return
				end
				local isInSand = root.Position.Y < yPos
				if isInSand == inSand then return end
				if isInSand then
					run:setSpeedMultiplier('Sand', .5)
				else
					run:removeSpeedMultiplier('Sand')
				end
				inSand = isInSand
			end))
			-- FogColor changing day/night
			local lighting = game:GetService('Lighting')
			local function updateFogColor()
				--			local hour, minute = lighting.TimeOfDay:match('^(%d+):(%d+):')
				local hour = lighting:GetMinutesAfterMidnight() / 60
				if hour < 6 or hour >= 18 then -- night
					lighting.FogColor = Color3.fromRGB(88, 79, 46)
				elseif hour < 7 then -- 6:00-7:00 transition
					local a = hour-6
					lighting.FogColor = Color3.fromRGB(88+(216-88)*a, 79+(194-79)*a, 46+(114-46)*a)
				elseif hour < 17 then -- day
					lighting.FogColor = Color3.fromRGB(216, 194, 114)
				elseif hour < 18 then -- 17:00-18:00 transition
					local a = hour-17
					lighting.FogColor = Color3.fromRGB(216+(88-216)*a, 194+(79-194)*a, 114+(46-114)*a)
				end
			end
			table.insert(connections, lighting.Changed:connect(function(property)
				if property ~= 'TimeOfDay' then return end
				updateFogColor()
			end))
			updateFogColor()
		end,

		onBeforeEnter_Greenhouse = function(room) -- Shaymin Stuff
			local grace = room.npcs.Grace
			local gstate = _p.Network:get('PDS', 'getGreenhouseState')
			interact[grace.model] = function()
				if gstate.f == 3 then
					grace:Say('The Gracidea is one of the rarest flowers I\'ve ever found.',
						'It is said to only grow in the purest soil.',
						'It\'s also coveted by a very rare Pok[e\']mon, but that\'s just a myth.',
						'Either way, it was a neat piece of my collection.',
						'I hope you enjoy it.')
				else
					grace:Say('I love flowers!', 'They give off such a Sweet Scent, plus they are absolutely beautiful.',
						'I heard that there are these precious Pok[e\']mon called Flabebe that share my love for flowers.',
						'Not only that, but there are five different color variations of this Pok[e\']mon.',
						'It\'s been a dream of mine to see all five colors of Flabebe, or any of its evolutions.',
						'I would do anything to see them, maybe even reward someone if they were to bring them to show me.',
						'I collect rare and beautiful flowers, and I wouldn\'t mind sharing from my collection.')
					if gstate.f == 2 then
						spawn(function() _p.Network:get('PDS', 'makeDecision', gstate.d) end)
						grace:Say('Wait a second...', 'I can\'t believe my eyes!',
							'You actually have all five color variations!',
							'They are absolutely stunning to look at!',
							'This has been a dream come true.', 'I cannot thank you enough.',
							'Here, I know. I want you to have this.')
						onObtainKeyItemSound()
						chat:say('Obtained the Gracidea!', _p.PlayerData.trainerName .. ' put the Gracidea in the Bag.')
						grace:Say('The Gracidea is one of the rarest flowers in my collection.',
							'It is said to only grow in the purest soil.',
							'It\'s also coveted by a very rare Pok[e\']mon, but that part is just a myth.',
							'Either way, it was a neat piece of my collection.',
							'I hope you enjoy it.')
						gstate.f = 3
					else
						grace:Say('Let me know if you ever come across those Pok[e\']mon.')
					end
				end
			end
		end,

		-- 5th Gym
		onLoad_chunk25 = function(chunk)
			local map = chunk.map
			if not completedEvents.vAredia then spawn(function() _p.PlayerData:completeEvent('vAredia') end) end
			-- Palace Gates
			if completedEvents.TEinCastle then
				local function open(gate)
					local function o(m, d)
						local hinge = create 'Part' {
							Anchored = true,
							CFrame = m.Union.CFrame * CFrame.new(-m.Union.Size.X/2+.5, 0, 0),
							Parent = m
						}
						Utilities.MoveModel(hinge, hinge.CFrame * CFrame.Angles(0, -1.75*d, 0))
						hinge:remove()
					end
					o(gate.Left, -1)
					o(gate.Right, 1)
				end
				open(map.PalaceGateCenter)
				open(map.PalaceGateLeft)
				open(map.PalaceGateRight)
			end
			-- Charmed Ekans
			local sanjay = chunk.npcs.Sanjay
			interact[sanjay.model] = function()
				if completedEvents.GiveEkans then
					sanjay:Say('Thanks again for the Ekans!', 'I hope you are enjoying the Pok[e\'] Flute!')
				else
					if sanjay:Say('I am an aspiring Ekans Charmer.',
						'I just have one problem... I don\'t have an Ekans to charm.',
						'I know this is a big favor to ask, but do you have an Ekans that you could give me?',
						'I have an extra Pok[e\'] Flute that I would trade for it.',
						'[y/n]Does that sound like a trade you\'re interested in?') then
						local tradeslot = _p.BattleGui:choosePokemon('Trade')
						local d
						if tradeslot then
							d = _p.Network:get('PDS', 'giveEkans', tradeslot)
						end
						if not tradeslot or not d then
							sanjay:Say('Aw, okay.', 'Let me know if you wanna trade later.')
						else
							local trade = sanjay:Say('[y/n]Are you sure you want to trade this Ekans for my Pok[e\'] Flute?')
							spawn(function() _p.Network:get('PDS', 'makeDecision', d, trade) end)
							if not trade then
								sanjay:Say('Aw, okay.', 'Let me know if you wanna trade later.')
							else
								sanjay:Say('Thanks!', 'Here you go!')
								onObtainKeyItemSound()
								chat:say('Obtained a Pok[e\'] Flute!', _p.PlayerData.trainerName .. ' put the Pok[e\'] Flute in the Bag.')
							end
						end
					end
				end
			end
			if completedEvents.GiveEkans then
				local snake = map.EkansJar
				if completedEvents.gsEkans then
					local cm = {
						[BrickColor.new('Lavender')] = BrickColor.new('Medium green'),
						[BrickColor.new('Plum')] = BrickColor.new('Sand green')
					}
					for _, p in pairs(Utilities.GetDescendants(snake, 'BasePart')) do
						local n = cm[p.BrickColor]
						if n then
							p.BrickColor = n
							--						pcall(function() p.UsePartColor = true end)
						end
					end
				end
				local rig = _p.DataManager:loadModule('AnchoredRig'):new(snake)
				rig:connect(snake, snake.Neck, true)
				rig:connect(snake.Neck, snake.Lid, true)
				rig:connect(snake.Neck, snake.Head, true)
				local neckjoint = rig.models.Head
				spawn(function()
					local tick = tick
					local st = tick()
					local sin, cos = math.sin, math.cos
					local cf, rot = CFrame.new, CFrame.Angles
					while map.Parent do
						local et = (tick()-st)*2.4
						local s, c = sin(et), cos(et)
						neckjoint.cframe = rot(0, 0, .5*s)
						rig:pose('Neck', cf(c*.5, 1.2+.8*sin(et)*c, -.5))
						heartbeat:wait()
					end
				end)
			end
		end,

		onLoad_gym5 = function(chunk) -- gym 5 is a chunk
			_p.MasterControl:SetJumpEnabled(true)
			_p.DataManager:loadModule('Gym5'):activate(chunk)
			local leader = chunk.npcs.LeaderRyan
			interact[leader.model] = function()
				if _p.PlayerData.badges[5] then
					leader:Say('The jewel I gave you has been in my family\'s care since the days we were ruled by a king.',
						'When the old castle was removeed and abandoned, the last thing that my ancestors were able to recover was that jewel.',
						'It was left in front of the pedestal in the main foyer.', 'I wonder what other mysteries lie within those ruins.')
				else
					leader:Say('Hey, you found me!', 'Glad to see you could make it to my gym after all.',
						'When I\'m not chasing bandits out of Old Aredia Ruins, I spend my time here at the gym battling aspiring trainers.',
						'As a prince, I wanted my gym to resemble a prince\'s palace on the outside, but inside it\'s all dirt, haha.',
						'My Pok[e\']mon enjoy coming down here and tunneling through the ground.',
						'I think you\'ll find that we have the advantage with my Pok[e\']mon being Ground-type.',
						'Before we battle, I want to thank you again for your help at the ruins.',
						'With that said, I won\'t be going easy on you in this battle.')
					local win = _p.Battle:doTrainerBattle {

						musicId = 12639907402,
						PreventMoveAfter = true,
						trainerModel = leader.model,
						vs = {name = 'Ryan', id = 608964635, hue = .097, sat = .1},
						num = 126
					}
					if win then
						leader:Say('After watching you battle those Team Eclipse goons, I knew that you would not be an easy opponent.',
							'You turned out to be even tougher than I expected!',
							'That\'s why I\'m happy to award you with the Crater Badge!')

						local badge = chunk.map.Badge5:Clone()
						local cfs = {}
						local main = badge.SpinCenter
						for _, p in pairs(badge:GetChildren()) do
							if p:IsA('BasePart') and p ~= main then
								p.CanCollide = false
								cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
							end
						end
						badge.Parent = workspace
						local st = tick()
						local spinRate = 1
						local function cframeTo(rcf)
							local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi/2, 0, (tick()-st)*spinRate + math.pi/2)
							main.CFrame = cf
							for p, ocf in pairs(cfs) do
								p.CFrame = cf:toWorldSpace(ocf)
							end
						end
						local r = 8
						local f = CFrame.new(0, 0, -6)
						Tween(1, nil, function(a)
							local t = a*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						local spin = true
						Utilities.fastSpawn(function()
							while spin do
								cframeTo(f)
								stepped:wait()
							end
						end)
						wait(2)
						onObtainBadgeSound()
						chat.bottom = true
						chat:say('Obtained the Crater Badge!')
						chat.bottom = nil
						spin = false
						Tween(.5, nil, function(a)
							local t = (1-a)*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						badge:remove()

						leader:Say('The Crater Badge enables trading for Pok[e\']mon up to level 70.',
							'Like I told you earlier, the Crater Badge also enables you to use Rock Smash outside of battle.',
							'While on your journey you may sometimes find that there are cracked boulders that stand in the way of your path.',
							'Rock Smash allows your Pok[e\']mon to clear those obstacles so that you can keep adventuring!',
							'I\'d also like you to have this TM.')
						onObtainItemSound()
						chat.bottom = true
						chat:say('Obtained a TM78!',
							_p.PlayerData.trainerName .. ' put the TM78 in the Bag.')
						chat.bottom = nil
						leader:Say('That TM contains the move Bulldoze.',
							'It\'s a helpful Ground-type move that also reduces the speed of the opponents you strike.',
							'Now, there is one last favor I would like to ask of you before you leave.',
							'I have with me the jewel that Team Eclipse tried stealing from Old Aredia Ruins.',
							'It has always been the duty of the living prince to protect this jewel within the Ruins.',
							'There is a legend that has been passed down for centuries that pertains to the ruins and this jewel.',
							'I don\'t know if they are true or not, but I think it\'s time to put the legend to the test.',
							'You have proven yourself a very brave and worthy trainer.',
							'I want you to take this.')
						onObtainKeyItemSound()
						chat.bottom = true
						chat:say('Obtained the King\'s Red Jewel!',
							'It glows a fierce red color!')
						chat.bottom = nil
						leader:Say('There is a slot on the pedestal in the ruins that the jewel fits into.',
							'You may be capable of unlocking the ruins\' great secret.',
							'I trust you with this because your intentions seem pure, and it\'s time that my family\'s past be laid to rest.',
							'It is your choice now to return and face any challenges that may lie in those ruins or to continue on your adventure.',
							'I thank you one last time for your help and bravery.', 'I wish you the best on your journey.')
					end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					chat:enable()
					_p.Menu:enable()
				end
			end
		end,

		onUnload_gym5 = function()
			_p.MasterControl:SetJumpEnabled(false)
			local m = _p.DataManager:getModule('Gym5')
			if m then
				m:deactivate()
			end
		end,

		onG5GetShovel = function()
			local npc = _p.DataManager.currentChunk.npcs['Miner Chuck']
			npc:Say('Alright, you win.', 'Here\'s your shovel, as promised.', 'Click on dirt to dig it up.')
			_p.DataManager:loadModule('Gym5'):setLevel(1)
		end,

		onG5GetPickaxe = function()
			local npc = _p.DataManager.currentChunk.npcs['Miner Carson']
			npc:Say('Here you go!', 'A nice, trusty pickaxe.', 'You can now dig through stone!')
			_p.DataManager:loadModule('Gym5'):setLevel(2)
		end,

		-- Castle Ruins
		onLoad_chunk28 = function(chunk)
			-- Pillar thing
			local map = chunk.map
			local jewels = {'Red', 'Green', 'Purple', 'Blue'}
			local jewelParts = {}
			for i, n in pairs(jewels) do
				local p = map.JewelStand[n..'Jewel']
				if completedEvents[n:sub(1,1)..'JP'] then
					p.Transparency = 0
				end
				jewelParts[i] = p
			end
			-- Eclipse Cutscene
			if completedEvents.TEinCastle then
				chunk.npcs.Ryan:remove()
				chunk.npcs.EclipseGrunt1:remove()
				chunk.npcs.EclipseGrunt2:remove()
				chunk.npcs.EclipseGrunt3:remove()
				chunk.npcs.EclipseGrunt4:remove()
				map.FloorJewel:remove()
			else
				local ryan = chunk.npcs.Ryan
				local grunt1 = chunk.npcs.EclipseGrunt1
				local grunt2 = chunk.npcs.EclipseGrunt2
				local grunt3 = chunk.npcs.EclipseGrunt3
				local grunt4 = chunk.npcs.EclipseGrunt4
				local function offsetBreath(npc)
					local at = npc.humanoid:GetPlayingAnimationTracks()[1]
					at:Stop()
					delay(math.random(), function() at:Play() end)
				end
				offsetBreath(ryan)
				offsetBreath(grunt1)
				offsetBreath(grunt2)
				offsetBreath(grunt3)
				offsetBreath(grunt4)

				spawn(function()
					while not _p.MasterControl.WalkEnabled do wait() end
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()

					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					Utilities.lookAt(CFrame.new(-842, 41, 282, .77, -.375, .516, 0, .809, .588, -.638, -.453, .623), nil, 2)

					grunt2:Say('Get out of our way, fool.', 'Team Eclipse will be taking this jewel back to our base of operations for examination.',
						'We believe it may be a part of an old legend.')
					ryan:Say('You will give me that jewel and leave promptly, or things will get real ugly for you guys.')
					grunt3:Say('Oh no, what\'s the big bad prince gonna do?', 'Heh... you have no power over us.')
					ryan:Say('I\'ve warned you fairly.', 'If you do not hand that jewel over now, I will have to take it by force.',
						'That jewel has been under my family\'s protection in this castle for centuries.',
						'I\'m not about to let some punks walk out of here with it.')
					grunt2:Say('I\'m afraid that may be your only option, your highness.', 'You\'re outnumbered, after all.')
					Utilities.Teleport(CFrame.new(-852, 31, 293))
					local rp = ryan.model.HumanoidRootPart.Position
					local gp = grunt2.model.HumanoidRootPart.Position
					local pp = rp + Vector3.new(5, 0, 0)
					_p.MasterControl:WalkTo(pp)
					spawn(function() _p.MasterControl:LookAt(rp) end)
					delay(.4, function() Utilities.exclaim(ryan.model.Helm) end)
					ryan:LookAt(pp)
					ryan:Say('Oh, hello young trainer, what an unexpected surprise this is.',
						'Yes, I am Aredia City\'s gym leader, but as you can see I\'m busy taking care of these goons.')
					grunt3:Say('Hey, who you callin\' goons?')
					ryan:Say('It looks like you already have a few badges of your own.', 'You must be pretty tough.',
						'Would you mind assisting me in battling these punks?',
						'They\'ve stolen a priceless artifact from the pedestal up there and are threatening to take it with them.',
						'This castle has been under my family\'s protection for centuries.',
						'If we don\'t stop them, there\'s no telling what they will do with it.',
						'Will you help me?', 'I\'ll take this half if you will take that half.')
					spawn(function() _p.MasterControl:Look(Vector3.new(0, 0, -1)) end)
					spawn(function() ryan:LookAt(gp) end)
					grunt2:Say('You couldn\'t stop us with an army, fool.', 'Prepare to be crushed by our power.')

					grunt3:Say('Bring it on!')
					local win = _p.Battle:doTrainerBattle {
						IconId = 5226446131,
						musicId = {9536676199, 12639990881},
						musicVolume = 2,
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = grunt3.model,
						num = 131,
					}
					if not win then
						_p.RunningShoes:enable()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
						return
					end
					wait(.5)
					spawn(function() _p.MasterControl:LookAt(grunt4.model.Head.Position) end)
					grunt4:Say('I\'ll take it from here.')
					local win = _p.Battle:doTrainerBattle {
						IconId = 5226446131,
						musicId = {9536676199, 12639990881},
						musicVolume = 2,
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = grunt4.model,
						num = 132,
					}
					if not win then
						_p.RunningShoes:enable()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
						return
					end

					wait(.5)
					spawn(function() _p.MasterControl:LookAt(gp) end)
					grunt2:Say('This can\'t be!', 'We were given some of the toughest-looking Pok[e\']mon that were at the base!')
					ryan:Say('How tough a Pok[e\']mon looks does not determine the outcome of a battle.',
						'The bond you and your Pok[e\']mon share is what will ultimately declare who is winner.')
					grunt2:Say('People and Pok[e\']mon are not meant to share some silly bond.',
						'Pok[e\']mon should not be used like tools in the first place.')
					ryan:Say('If people like you didn\'t exist, maybe we wouldn\'t have to.',
						'Either way, we\'ve beaten you.', 'You will hand me that jewel and you will leave at once.')
					grunt2:Say('Fine, the jewel isn\'t necessary to our plan anyway.', 'I just figured we\'d get rewarded for bringing it back.',
						'Our ultimate plan is about to come together, and you will both perish with the rest of this world.',
						'Goodbye, fools.')

					map.FloorJewel.Transparency = 0
					local nodes = {Vector3.new(-852, 28, 270), Vector3.new(-859, 28, 277), Vector3.new(-859, 28, 305)}
					grunt2:WalkTo(nodes[2])
					spawn(function()
						grunt2:WalkTo(nodes[3])
						grunt2:remove()
					end)
					spawn(function()
						grunt3:WalkTo(nodes[1])
						grunt3:WalkTo(nodes[2])
						grunt3:WalkTo(nodes[3])
						grunt3:remove()
					end)
					grunt1:WalkTo(nodes[2])
					spawn(function()
						grunt4:WalkTo(nodes[1])
						grunt4:WalkTo(nodes[2])
						grunt4:WalkTo(nodes[3])
						grunt4:remove()
					end)
					grunt1:WalkTo(nodes[3])
					grunt1:remove()
					local jp = map.FloorJewel.Position
					ryan:WalkTo(jp)
					map.FloorJewel:remove()
					ryan:LookAt(pp)
					ryan:Say('Well, that certainly was quite dramatic.', 'Those fools talk a lot about power and destruction.',
						'With that attitude, I think they will find most of their battles ending with the same results.',
						'Anyways, I really owe you for showing up and helping me like that.',
						'Here, I want you to have this.')
					onObtainItemSound()
					chat.bottom = true
					chat:say('Obtained an HM06!', _p.PlayerData.trainerName .. ' put the HM06 in the Bag.')
					chat.bottom = nil
					ryan:Say('HM06 contains Rock Smash.', 'It allows you to remove cracked boulders that wind up in your way along your path.',
						'You won\'t be able to use Rock Smash outside of battle without the Aredia City Gym\'s badge, though.',
						'I\'ll head back and open the palace now.', 'It would be an honor to have a battle with you.',
						'The jewel that Team Eclipse tried stealing is actually a significant part of this castle\'s history.',
						'There\'s an ancient legend tied in with it.', 'That\'s a story for another day, though.',
						'I must be off now.', 'I\'ll be waiting for you in the gym.')
					ryan:WalkTo(nodes[3])
					ryan:remove()
					Utilities.lookBackAtMe()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
				end)
			end
		end,

		onLoad_chunk29 = function(chunk)
			chunk.map[completedEvents.BJP and 'BlueDoor'   or 'CaveDoor:chunk34']:remove()
		end,

		onLoad_chunk30 = function(chunk)
			chunk.map[completedEvents.RJP and 'RedDoor'    or 'CaveDoor:chunk31']:remove()
			chunk.map[completedEvents.GJP and 'GreenDoor'  or 'CaveDoor:chunk32']:remove()
			chunk.map[completedEvents.PJP and 'PurpleDoor' or 'CaveDoor:chunk33']:remove()
		end,

		onLoad_chunk31 = function(chunk)
			local map = chunk.map
			if completedEvents.GJO then
				map.RoomSand:remove()
				map.GreenJewel:remove()
			else
				local key = map.KeyRockSmash
				local jewel = map.GreenJewel
				jewel.Parent = nil
				spawn(function()
					while map.Parent do
						if map.Parent and not key.Parent then
							pcall(function()
								while not _p.MasterControl.WalkEnabled do wait() end
								_p.MasterControl.WalkEnabled = false
								_p.MasterControl:Stop()
								jewel.Parent = map
								local sand = map.RoomSand
								local cf = sand.CFrame
								Tween(1.5, nil, function(a)
									sand.CFrame = cf + Vector3.new(0, -3*a, 0)
								end)
								sand:remove()
								_p.MasterControl.WalkEnabled = true
								--_p.MasterControl:Start()
								touchEvent(nil, jewel, false, function()
									spawn(function() _p.PlayerData:completeEvent('GJO') end)
									_p.MasterControl.WalkEnabled = false
									_p.MasterControl:Stop()
									chat:say(_p.PlayerData.trainerName .. ' found one of the King\'s Jewels!',
										'It shines a luminescent green color.')
									jewel:remove()
									_p.MasterControl.WalkEnabled = true
									--_p.MasterControl:Start()
								end)
							end)
							break
						end
						wait(.2)
					end
					pcall(function() if not map.Parent then jewel:remove() end end)
				end)
			end
		end,
		onLoad_chunk32 = function(chunk)
			local map = chunk.map
			if completedEvents.PJO then
				map.Puzzle:remove()
				map.PurpleJewel:remove()
			else
				local jewel = map.PurpleJewel
				jewel.Parent = nil
				local puzzle = _p.DataManager:loadModule('PuzzleJ')
				puzzle:init(map.Puzzle)
				puzzle.completed:connect(function()
					local cf = jewel.CFrame
					jewel.Parent = map
					Tween(.5, nil, function(a)
						jewel.CFrame = cf + Vector3.new(0, -.4*(1-a), 0)
					end)
					touchEvent(nil, jewel, false, function()
						spawn(function() _p.PlayerData:completeEvent('PJO') end)
						_p.MasterControl.WalkEnabled = false
						_p.MasterControl:Stop()
						chat:say(_p.PlayerData.trainerName .. ' found one of the King\'s Jewels!',
							'It sparkles an extravagant purple color.')
						jewel:remove()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
					end)
				end)
			end
		end,

		onLoad_chunk33 = function(chunk, data)
			local map = chunk.map
			if completedEvents.BJO then
				map.Torch:remove()
				map.Ropes:remove()
				map.InvisibleWalls.EventWall:remove()
				map.BlueJewel:remove()
				--			chunk.npcs.Mummy:remove()
				local lidcf = map.Sarcophagus.LidEndLocation.CFrame
				map.Sarcophagus.LidEndLocation:remove()
				pcall(function() map.Sarcophagus['#InanimateInteract']:remove() end)
				Utilities.MoveModel(map.Sarcophagus.Main, lidcf)
				Utilities.MoveModel(map.Pillar.Pivot, map.Pillar.Pivot.CFrame * CFrame.Angles(-1.4, 0, 0))
			else
				-- continue support
				if data and data.continueCFrame then
					local pos = data.continueCFrame.p
					if pos.X > -820 or (pos.Z < 974 and pos.X > -832) then
						map.Torch:remove()
						map.Ropes:remove()
						map.InvisibleWalls.EventWall:remove()
						Utilities.MoveModel(map.Pillar.Pivot, map.Pillar.Pivot.CFrame * CFrame.Angles(-1.4, 0, 0))
					end
				end
				--
				local torch = map:FindFirstChild('Torch')
				if torch then
					local flame = torch.Flame
					touchEvent(nil, torch.Main, false, function()
						local tool = create 'Tool' {
							Name = 'c33f08c4',
							CanBeDropped = false,
							RequiresHandle = true,
						}
						local main = torch.Main
						main.Name = 'Handle'
						main.CanCollide = false
						main.Anchored = false
						main.Parent = tool
						flame.CanCollide = false
						flame.Anchored = false
						flame.Parent = tool
						tool.Changed:connect(function(property)
							if property == 'Parent' and tool.Parent ~= _p.player.Character then
								stepped:wait()
								pcall(function() tool.Parent = _p.player.Character end)
							end
						end)
						--				tool.Parent = _p.player.Character
						--				stepped:wait()
						tool.Parent = _p.player.Backpack
						--				stepped:wait()
						--				tool.Parent = _p.player.Character
						create 'Weld' {
							Part0 = main,
							Part1 = flame,
							C0 = CFrame.new(0, .965, 0),
							Parent = main
						}
					end)
					local ropes = map.Ropes
					local rope1 = ropes.Rope1
					local ftcn; ftcn = flame.Touched:connect(function(obj)
						if obj.Parent ~= rope1 then return end
						ftcn:disconnect()
						_p.MasterControl.WalkEnabled = false
						_p.MasterControl:Stop()
						-- BURN ROPE
						local cam = workspace.CurrentCamera
						local camOCF = cam.CFrame
						cam.CameraType = Enum.CameraType.Scriptable
						local rate = 20
						local fire = flame:Clone()
						fire.Transparency = 1
						fire.Parent = map
						local function burn(rope, follow)
							local len = 0
							local segments = {}
							local i = 1
							while true do
								local seg = rope:FindFirstChild('Seg'..i)
								if not seg then break end
								segments[i] = seg
								len = len + seg.Size.Z
								i = i + 1
							end
							i = 1
							local ps = 0
							local cp = segments[1]
							local ccf = cp.CFrame
							local cl = cp.Size.Z
							local sig = cl/len
							Tween(len/rate, nil, function(a)
								while true do
									if a > ps+sig then
										if cp then cp:remove() end
										i = i + 1
										ps = ps + sig
										cp = segments[i]
										if not cp then return false end
										ccf = cp.CFrame
										cl = cp.Size.Z
										sig = cl/len
									else
										break
									end
								end
								local ca = (a - ps)/sig
								fire.CFrame = ccf * CFrame.new(0, 0, -cl/2+cl*ca)
								if follow then
									cam.CFrame = CFrame.new(Vector3.new(-848, 83, 975), fire.Position)
								end
								cp.Size = Vector3.new(.2, .2, cl*(1-ca))
								cp.CFrame = ccf * CFrame.new(0, 0, cl*ca/2)
							end)
							pcall(function() cp:remove() end)
						end
						burn(rope1, true)
						burn(ropes.Rope2, true)
						pcall(function() _p.player.Character.c33f08c4:remove() end)
						burn(ropes.Rope3, true)
						spawn(function() burn(ropes.Rope4b) end)
						spawn(function() burn(ropes.Rope4c) end)
						burn(ropes.Rope4, true)
						spawn(function() burn(ropes.Rope5b) end)
						spawn(function() burn(ropes.Rope5 ) end)
						local pivot = map.Pillar.Pivot
						local pcf = pivot.CFrame
						Tween(1, nil, function(a)
							Utilities.MoveModel(pivot, pcf * CFrame.Angles(math.sin(a*math.pi*4)*math.cos(a*math.pi/2)*.025, 0, 0))
						end)
						--				wait(.3)
						local sf, ef = Vector3.new(-830, 72, 958), Vector3.new(-828, 53, 976)
						Tween(1, 'easeInCubic', function(a)
							Utilities.MoveModel(pivot, pcf * CFrame.Angles(-1.4*a, 0, 0))
							cam.CFrame = CFrame.new(Vector3.new(-848, 83, 975), sf:Lerp(ef, a))
						end)
						wait(2)
						map.InvisibleWalls.EventWall:remove()
						Utilities.lookBackAtMe()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
					end)
				end
			end
		end,

		onUnload_chunk33 = function()
			pcall(function() _p.player.Character.c33f08c4:remove() end)
		end,
		onActivateMummy = function(mummy)
			local backup = mummy:Clone()
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			local mroot = mummy.HumanoidRootPart
			local mcf = mroot.CFrame
			local pos = Vector3.new(-780, 58.5, 993)
			Utilities.Teleport(CFrame.new(pos, pos + Vector3.new(-1, 0, 0)))
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = CFrame.new(_p.player.Character.Head.Position + Vector3.new(-5, 0, -2), mcf.p + Vector3.new(0, 3, 0))
			wait(.05)
			Utilities.exclaim(_p.player.Character.Head)
			_p.MasterControl:LookAt(mcf.p)
			delay(.3, function()
				Tween(1.5, 'easeOutCubic', function(a)
					cam.FieldOfView = 70 - 40*a
				end)
			end)
			Tween(1.7, 'easeOutCubic', function(a)
				Utilities.MoveModel(mroot, mcf * CFrame.Angles(-1.4*a, 0, 0) + Vector3.new(0, 2.5*a, 0), true)
			end)
			wait(.6)
			local head = mummy.HeadStuff.Head
			local lerp = select(2, Utilities.lerpCFrame(head.CFrame, CFrame.new(head.Position, _p.player.Character.Head.Position)))
			Tween(2, 'easeOutCubic', function(a)
				Utilities.MoveModel(head, lerp(a))
			end)
			wait(.6)

			local tm = backup:Clone()
			for _, obj in pairs(tm.HeadStuff:GetChildren()) do obj.Parent = tm end
			tm.HeadStuff:remove(); tm.NoAnimate:remove()
			for _, obj in pairs(tm:GetChildren()) do pcall(function() obj.Anchored = false end) end

			delay(3, function()
				backup:Clone().Parent = mummy.Parent
				mummy:remove()
			end)
			local win = _p.Battle:doTrainerBattle {
				musicId = 105871631848322,
				trainerModel = tm,
				PreventMoveAfter = true,
				num = 130
			}
			if win then
				chat:say('You have proven yourself worthy of entering the Pok[e\']mon\'s chamber.',
					'Please, for me, do what I can no longer do.', 'Free the Pok[e\']mon.',
					'I kept it locked away, thinking it would always be with me.',
					'I was wrong and now it has been trapped for several millennia.',
					'Do this, and my soul can finally rest.')
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
			chat:enable()
			_p.Menu:enable()
		end,

		onLoad_chunk34 = function(chunk)
			local map = chunk.map
			if map:FindFirstChild('Victini') then
				_p.DataManager:preload(608811548)
				_p.DataManager:preloadModule('AnchoredRig')
			else
				map.VictiniSeal['#InanimateInteract']:remove()
			end
		end,

		onLoad_chunk37 = function(chunk)
			local map = chunk.map
			local to, th = map:FindFirstChild('Tornadus'), map:FindFirstChild('Thundurus')
			if to and th then
				local tom = to.Cloud
				local thm = th.Cloud
				local toc = tom.CFrame * CFrame.Angles(0, 0,  2)
				local thc = thm.CFrame * CFrame.Angles(0, 0, -2)
				local top = {[tom] = CFrame.new()}
				local thp = {[thm] = CFrame.new()}
				local toci = tom.CFrame:inverse()
				local thci = thm.CFrame:inverse()
				for _, p in pairs(Utilities.GetDescendants(to, 'BasePart')) do if p ~= tom then top[p] = toci * p.CFrame end end
				for _, p in pairs(Utilities.GetDescendants(th, 'BasePart')) do if p ~= thm then thp[p] = thci * p.CFrame end end
				local float = true
				spawn(function()
					local st = tick()
					while map.Parent and float do
						local et = (tick()-st)*1.7
						local cf = toc + Vector3.new(0, math.sin(et)*.4, 0)
						for p, rcf in pairs(top) do
							p.CFrame = cf * rcf
						end
						cf = thc + Vector3.new(0, math.sin(et+1.2)*.4, 0)
						for p, rcf in pairs(thp) do
							p.CFrame = cf * rcf
						end
						heartbeat:wait()
					end
				end)
				touchEvent('RNatureForces', map.CTrigger, true, function()
					_p.MasterControl.WalkEnabled = false
					spawn(function() _p.Menu:disable() end)
					spawn(function() _p.MasterControl:WalkTo(Vector3.new(-470, 0, 1567)) end)
					local cp = (toc.p+thc.p)/2
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					Utilities.lookAt(CFrame.new(cp - Vector3.new(20, -14, -9), cp + Vector3.new(0, 4, 0)))
					wait(.5)
					spawn(function() Utilities.exclaim(to:FindFirstChild('Top', true)) end)
					Utilities.exclaim(th:FindFirstChild('Top', true))
					local stoc, sthc = toc, thc
					delay(.3, function()
						Tween(.8, 'easeOutCubic', function(a)
							thc = sthc * CFrame.Angles(0, 0, 2*a)
						end)
					end)
					Tween(.8, 'easeOutCubic', function(a)
						toc = stoc * CFrame.Angles(0, 0, -2*a)
					end)
					wait(2)
					local goal = Vector3.new(-447, 3.6, 1566)
					local d = goal - stoc.p
					Tween(1, nil, function(a)
						toc = stoc * CFrame.Angles(0, 0, a<.4 and (2*(a*2.5-1)^3) or 0) + d*a
					end)
					spawn(function()
						Tween(1.2, 'easeInQuad', function(a)
							toc = stoc + d + Vector3.new(0, 30*a, 0)
						end)
						to:remove()
					end)
					wait(.5)
					local dh = goal - sthc.p
					Tween(1, nil, function(a)
						thc = sthc * CFrame.Angles(0, 0, a<.4 and (-2*(a*2.5-1)^3) or 0) + dh*a
					end)
					Tween(1.2, 'easeInQuad', function(a)
						thc = sthc + dh + Vector3.new(0, 30*a, 0)
					end)
					th:remove()
					float = false
					chat.bottom = true
					chat:say('The wild Pok[e\']mon fled!', 'Tornadus and Thundurus can now be found roaming in the wild.')
					chat.bottom = nil
					Utilities.lookBackAtMe()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
				end) 
			else
				local la = map:FindFirstChild('Landorus')
				if la then
					local main = la.Main
					local mcf = main.CFrame
					local parts = {}
					local inv = mcf:inverse()
					for _, p in pairs(Utilities.GetDescendants(la, 'BasePart')) do
						if p ~= main then
							parts[p] = inv * p.CFrame
						end
					end
					spawn(function()
						local st = tick()
						while map.Parent and la.Parent do
							local et = (tick()-st)*1.7
							local cf = mcf + Vector3.new(0, math.sin(et)*.4, 0)
							main.CFrame = cf
							for p, rcf in pairs(parts) do
								p.CFrame = cf * rcf
							end
							heartbeat:wait()
						end
					end)
				end
			end
		end,


		--put latioslatias here when you got time






		---




		onBeforeEnter_PowerPlant = function(room)
			_p.PlayerData.nRotom = _p.Network:get('PDS', 'hasRTM')
		end,

		--[= =[
		onLoad_chunk38 = function(chunk)
			if completedEvents.OpenJDoor then
				chunk.map.Sesame:remove()
				local door = chunk.map.CD41
				door.Name = 'CaveDoor:chunk41'
				chunk:hookupCaveDoor(door)
			else
				_p.PlayerData.hasjkey = _p.Network:get('PDS', 'hasJKey')
			end
		end,

		onLoad_chunk39 = function(chunk)
			if not completedEvents.vFluoruma then spawn(function() _p.PlayerData:completeEvent('vFluoruma') end) end
		end,
		-- [[
		onBeforeEnter_PBStampShop = function(room)
			-- todo: preload assets (roulette bg etc)
			local stampSystem = _p.DataManager:loadModule('PBStamps')

			local bmap = room.model.bmap
			bmap.Parent = nil -- potential for data leak? (released but not removeed)

			local guy, gal = room.npcs.ShopGuy, room.npcs.ShopGal


			-- Fountain
			-- Explode
			-- ExplodeWave
			-- Swirl
			-- Rise

			-- all start big; get smaller until they disappear

			interact[guy.model] = function()
				spawn(function() _p.Menu:disable() end)
				guy:Say('Welcome to the Pok[e\'] Ball Stamp Shop!')
				if completedEvents.PBSIntro then
					guy:Say('What can I do for you today?')
				else
					spawn(function() _p.PlayerData:completeEvent('PBSIntro') end)
					guy:Say('Here you can try your luck on the Stamp Spinner and see which stamps you\'ll win.',
						'Pok[e\'] Ball Stamps can be applied to your Pok[e\'] Balls to produce cool effects as you send your Pok[e\']mon into battle!',
						'I am here to assist you with using the Stamp Spinner.',
						'The lady to your right will assist you with applying stamps from your inventory to your Pok[e\'] Balls.',
						'For being a new customer, I\'ll give you three free spins!',
						'Ah yes, and you\'ll need a case in which to collect your stamps.',
						'Here you are, a brand new Stamp Case!')
					onObtainKeyItemSound()
					chat.bottom = true
					chat:say('Obtained a Stamp Case!', _p.PlayerData.trainerName .. ' put the Stamp Case in the Bag.')
					chat.bottom = nil
					guy:Say('Now then, would you like to try it now?')
				end
				if chat:choose('Spin', 'Cancel') == 1 and guy:Say('You must save before opening the spinner.', '[y/n]Would you like to save the game?') then
					if _p.Menu:saveGame() then
						stampSystem:openSpinner()
					else
						guy:Say('Hm, that\'s weird.', 'Please try again in a minute or two...')
						spawn(function() _p.Menu:enable() end)
						return
					end
				end
				guy:Say('Thanks, please come again!')
				spawn(function() _p.Menu:enable() end)
			end
			interact[gal.model] = function()
				spawn(function() _p.Menu:disable() end)
				gal:Say('Welcome to the Pok[e\'] Ball Stamp Shop!')
				if not completedEvents.PBSIntro then
					gal:Say('I see you don\'t own a Stamp Case yet.',
						'We are currently giving away Stamp Cases with three free spins!',
						'Talk to the gentleman to your left for your very own Stamp Case.',
						'Act now, while supplies last!')
					spawn(function() _p.Menu:enable() end)
					return
				end
				gal:Say('How may I help you?')
				if chat:choose('Customize', 'Cancel') == 1 then
					gal:Say('Which Pok[e\']mon\'s Pok[e\'] Ball would you like to customize?')
					local slot = _p.BattleGui:choosePokemon('Choose')
					if slot then
						stampSystem:openInventory(bmap, slot)
					end
				end
				gal:Say('Thank you, come again soon!')
				spawn(function() _p.Menu:enable() end)
			end
		end,
		--]]
		onLoad_gym6 = function(chunk) -- gym 6 is also a chunk
			--		MasterControl:SetJumpEnabled(true)
			_p.DataManager:loadModule('Gym6'):activate(chunk)
			-- [[
			local leader = chunk.npcs.Leader
			interact[leader.model] = function()
				if _p.PlayerData.badges[6] then
					leader:Say('Life is always trying to teach us something new, but if we aren\'t listening, we might miss something important.',
						'Thank you again for stopping by our humble gym, and good luck on your journey!')
				else
					leader:Say('Hi there, welcome to the Fluoruma City gym.', 'My name is Fissy.',
						'I\'m the leader of the gym and head of the gardens.', 'We\'re very proud of the plants we produce here.',
						'If you\'ve made it this far, that means you\'ve already made your way around the gardens and have seen firsthand the amazing size of the fruit we grow.',
						'We owe a lot to the caring nature of our Pok[e\']mon.',
						'I personally believe that people and Pok[e\']mon are meant to work together to help provide for one another.',
						'These concepts are self-evident as we work alongside one another in this garden.',
						'Growing up, I found that battling side by side also increased our trust and friendship.',
						'That is why I opened up my gardens as a Pok[e\']mon Gym.',
						'I managed to bring my two great loves together in one place.',
						'But enough about me, I\'m sure you didn\'t come all this way to listen to me brag about fruit!',
						'I\'m always ready for a good battle.', 'I hope you\'re ready as well, because I\'m really feeling it today!',
						'Let\'s see what you\'re made of!')
					local win = _p.Battle:doTrainerBattle {
						musicId = 121757660131215,
						PreventMoveAfter = true,
						trainerModel = leader.model,
						vs = {name = 'Fissy', id = 658350333, hue = .356, sat = .4},
						num = 147
					}
					if win then
						leader:Say('Well that fight was really something.',
							'Another one of life\'s beautiful truths is that there is always something new to learn.',
							'You have certainly done a good job at teaching me today.',
							'Now, for beating me you deserve a Harvest Badge!')
						local badge = chunk.map.Badge6:Clone()
						local cfs = {}
						local main = badge.SpinCenter
						for _, p in pairs(badge:GetChildren()) do
							if p:IsA('BasePart') and p ~= main then
								p.CanCollide = false
								cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
							end
						end
						badge.Parent = workspace
						local st = tick()
						local spinRate = 1
						local function cframeTo(rcf)
							local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi/2, 0, (tick()-st)*spinRate + math.pi/2)
							main.CFrame = cf
							for p, ocf in pairs(cfs) do
								p.CFrame = cf:toWorldSpace(ocf)
							end
						end
						local r = 8
						local f = CFrame.new(0, 0, -6)
						Tween(1, nil, function(a)
							local t = a*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						local spin = true
						Utilities.fastSpawn(function()
							while spin do
								cframeTo(f)
								stepped:wait()
							end
						end)
						wait(2)
						onObtainBadgeSound()
						chat.bottom = true
						chat:say('Obtained the Harvest Badge!')
						chat.bottom = nil
						spin = false
						Tween(.5, nil, function(a)
							local t = (1-a)*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						badge:remove()

						leader:Say('With the Harvest Badge, you will be able to trade for Pok[e\']mon up to level 80.',
							'You will also be able to use the move Rock Climb outside of battle.',
							'You\'ll find that there are rows of rocks leading up or down a wall that you can scale only with that move.',
							'I also want you to have this TM.')
						onObtainItemSound()
						chat.bottom = true
						chat:say('Obtained a TM22!',
							_p.PlayerData.trainerName .. ' put the TM22 in the Bag.')
						chat.bottom = nil
						leader:Say('That TM contains the move Solar Beam.', 'It\'s one of the most powerful Grass-type moves.',
							'It takes one turn to charge, and then releases on the next.',
							'If it\'s extra sunny, however, you can use the move without needing to charge it first!',
							'I hope that you have learned something new from your experience here like I have.',
							'Life is always trying to teach us something new, but if we aren\'t listening, we might miss something important.',
							'Thank you again for stopping by our humble gym, and good luck on your journey!')
					end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					chat:enable()
					_p.Menu:enable()
				end
			end--]]
		end,

		onUnload_gym6 = function()
			--		MasterControl:SetJumpEnabled(false)
			local m = _p.DataManager:getModule('Gym6')
			if m then
				m:deactivate()
			end
		end,

		onExitC_gym6 = function(chunk)
			if _p.PlayerData.badges[6] and not completedEvents.FluoDebriefing then
				spawn(function() _p.PlayerData:completeEvent('FluoDebriefing') end)
				local tess = chunk.npcs.Tess
				local gerald = chunk.npcs.Gerald
				local tsp = Vector3.new(1201, -4, 832)
				local gsp = Vector3.new(1206, -4, 833)
				local pp = _p.player.Character.HumanoidRootPart.Position
				pp = Vector3.new(pp.X, -4, pp.Z)
				local fmp = (tsp+gsp)/2
				local dir = pp-fmp
				local tp = tsp + dir*.84
				local gp = gsp + dir*.87

				tess:Teleport(CFrame.new(tsp, tp))
				gerald:Teleport(CFrame.new(gsp, gp))
				chunk.regionThread = nil
				local pName = _p.PlayerData.trainerName
				spawn(function() Utilities.exclaim(_p.player.Character.Head) end)
				chat:say('Hey, '..pName..'! Over here!')
				spawn(function()
					gerald:WalkTo(gp)
					gerald:LookAt(pp)
				end)
				local cam = workspace.CurrentCamera
				local sp = cam.CFrame.p
				local sf = cam.Focus.p
				cam.CFrame = CFrame.new(pp + Vector3.new(2.5, 4, -3), fmp + Vector3.new(3, 4, 0))
				tess:WalkTo(tp)
				tess:LookAt(pp)
				cam.CFrame = CFrame.new(sp + Vector3.new(3, -4, 2), pp + Vector3.new(2, 3, 0))

				tess:Say('We finally caught up to you.', 'It\'s so good to finally see you again!',
					'We discovered some useful new information, and came to share it with you.',
					'We knew you had traveled down to Route 11 via Sky Train, but we weren\'t completely sure how far you would\'ve gotten from there.',
					'We asked around at Aredia Palace, and learned you had already earned the Crater Badge and departed towards Fluoruma City.',
					'We expected to find you preparing to challenge Fluoruma City Gym, and here you are!', '...',
					'Is that the Harvest Badge?! Already?', pName..', you are an incredible trainer!')
				gerald:Say('Yes, indeed.', 'It\'s quite impressive what you have accomplished in the meantime.',
					'Your skills as a Pok[e\']mon Trainer will come in handy as we attempt to foil Team Eclipse\'s plans.')
				tess:Say('We were able to confirm that Team Eclipse\'s secret base is located on Crescent Island.',
					'There was also more information regarding Hoopa that seems to suggest it is indeed imprisoned somewhere on that same island.')
				gerald:Say('According to my sources, there should be a way to get into Team Eclipse\'s base without any guards catching you.',
					'Once you find your way in, you should be able to make your way to Jake and your parents.',
					'Since your Pok[e\']mon are pretty strong at this point, you ought to be able to fight off any stray Eclipse members you may happen to run into.')
				tess:Say('So what do you say, '..pName..'?',
					'Are you willing to take the risk, to break into Team Eclipse\'s base with me, and rescue everyone?',
					'...', 'I can tell by that expression on your face that you are very determined to do this!',
					'We\'ve got this!', 'We simply have to! For Jake, your parents, and all of Roria!',
					'We must stop them from unleashing Hoopa and accomplishing their goal of escaping and removeing this world.')
				spawn(function() tess:LookAt(gp) end)
				gerald:Say('Well, it sounds like a plan, then.',
					'I would love to travel with you beyond this point, but unfortunately I would not be of much use.',
					'I will continue to seek information, though, and keep you updated.',
					'Before I leave, though, I should to remind you how to get to Crescent Island.',
					'You will first need to travel from here through Route 14.',
					'Oh, you might find that this is useful in your travels.')
				chat.bottom = true
				chat:say('Obtained an HM08!', _p.PlayerData.trainerName .. ' put the HM08 in the Bag.')
				chat.bottom = nil
				gerald:Say('HM08 contains Rock Climb, a move that will enable your Pok[e\']mon to scale walls.',
					'You\'ll find it especially useful as you travel through caves.',
					'Anyways, if you follow Route 14, it will lead you to Frostveil City.',
					'Frostveil City is tucked away in the cold, snowy mountains.',
					'From there, you ought to be able to make your way to Port Decca.',
					'Port Decca is a big seaside town that has many ships that can take you to different places.',
					'You will need to ride a ship to Crescent Island.')
				spawn(function() gerald:LookAt(tp) end)
				tess:Say('Alright, so it sounds like we have our direction.', 'Thank you so much for your help, Gerald!')
				gerald:Say('No problem.')
				spawn(function() gerald:LookAt(pp) end)
				gerald:Say('I\'ll be on my way back to Anthian now.', 'Good luck, you two.',
					'I have faith in you.')
				spawn(function()
					gerald:WalkTo(gp-dir.unit*10)
					gerald:remove()
				end)
				tess:LookAt(pp)
				tess:Say('Alright, '..pName..', we\'re back on mission to save everyone!',
					'We\'ll need to be tough in the face of our adversaries.', 'I know we can do this.',
					'Gerald said we will need to head through Route 14 to Frostveil City.',
					'I think I\'ll go ahead and get a head start on my way there.',
					'I\'m just really anxious, and it will give you time to gather any last-minute provisions you may need.',
					'Seeya in Frostveil!')
				spawn(function()
					local map = chunk.map
					tess:WalkTo(Vector3.new(1217, -15, 896)) if not map.Parent then return end
					tess:WalkTo(Vector3.new(1235, -15, 954)) if not map.Parent then return end
					tess:WalkTo(Vector3.new(1241, -15, 957)) if not map.Parent then return end
					tess:WalkTo(Vector3.new(1306, -19, 976)) if not map.Parent then return end
					tess:WalkTo(Vector3.new(1391, -19, 993)) if not map.Parent then return end
					chunk.doorDebounce = true
					local door = chunk:getDoor('Gate18')
					door:open(.75)                           if not map.Parent then return end
					spawn(function() tess:WalkTo(Vector3.new(1420, -19, 993)) end)
					wait(.5)                                 if not map.Parent then return end
					door:close(.75)                          if not map.Parent then return end
					tess:Stop() tess:remove()
					wait(.2)
					chunk.doorDebounce = false
				end)
			else
				chunk.npcs.Tess:remove()
				chunk.npcs.Gerald:remove()
			end
		end,

		onLoad_chunk40 = function(chunk)
			local map = chunk.map
			local lf = map.Lavafall
			local cf = lf.CFrame
			local h = lf.Size.X
			local h2 = h*2
			local lf2 = lf:Clone()
			lf2.Parent = map
			local st = tick()
			local fallspeed = 20
			local cn; cn = heartbeat:connect(function()
				if not map.Parent then
					pcall(function() cn:disconnect() end)
					return
				end
				local dt = tick()-st
				local o = (dt*fallspeed)%h2
				lf.CFrame  = cf + Vector3.new(0, o>h and (h2-o) or (-o), 0)
				lf2.CFrame = cf + Vector3.new(0, h-o, 0)
			end)
			local heatran = map:FindFirstChild('Heatran')
			if heatran then
				heatran.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.heatranIdle }):Play()
				for _, p in pairs(Utilities.GetDescendants(heatran, 'BasePart')) do
					p.Parent = heatran
				end
				for _, m in pairs(Utilities.GetDescendants(heatran, 'Model')) do
					m:remove()
				end
				create 'StringValue' {
					Name = '#InanimateInteract',
					Value = 'heatran',
					Parent = heatran
				}
				local main = create 'Part' {
					Name = 'Main',
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					CFrame = heatran.Jaw.CFrame,--['Torso-Head'].CFrame,
					Parent = heatran
				}
			end
		end,

		onLoad_chunk41 = function(chunk)
			local map = chunk.map
			local diancie = map:FindFirstChild('Diancie')
			if diancie then
				local main = diancie.Main
				local mcf = main.CFrame
				local parts = {}
				local inv = mcf:inverse()
				for _, p in pairs(Utilities.GetDescendants(diancie, 'BasePart')) do
					if p ~= main then
						parts[p] = inv * p.CFrame
					end
				end
				spawn(function()
					local st = tick()
					while map.Parent and diancie.Parent do
						local et = (tick()-st)*1.7
						local cf = mcf + Vector3.new(0, math.sin(et)*.4, 0)
						main.CFrame = cf
						for p, rcf in pairs(parts) do
							p.CFrame = cf * rcf
						end
						heartbeat:wait()
					end
				end)
			end
		end,

		onLoad_chunk42 = function(chunk)
			if completedEvents.OpenRDoor then
				local rDoor = chunk.map.RDoor
				local DoorMain = rDoor.Main
				local DoorCFrame = DoorMain.CFrame
				spawn(function()
					pcall(function() rDoor['#InanimateInteract']:Destroy() end)
					Utilities.Tween(.1, "easeInSine", function(p87)
						Utilities.MoveModel(DoorMain, DoorCFrame + Vector3.new(0, 10 * p87, 0))
					end)
				end)
			end
		end,

		onLoad_chunk43 = function(chunk)
			if completedEvents.TERt14 then
				chunk.npcs.Tess:remove()
				chunk.npcs.Jake:remove()
				chunk.npcs.Grunt1:remove()
				chunk.npcs.Grunt2:remove()
			else
				local map = chunk.map
				local construction = map:FindFirstChild('Construction')
				if construction then construction.Parent = nil end

				local tess = chunk.npcs.Tess
				local jake = chunk.npcs.Jake
				local grunt1 = chunk.npcs.Grunt1
				local grunt2 = chunk.npcs.Grunt2

				local function offsetBreath(npc)
					local at = npc.humanoid:GetPlayingAnimationTracks()[1]
					at:Stop()
					delay(math.random(), function() at:Play() end)
				end
				offsetBreath(tess)
				offsetBreath(jake)
				offsetBreath(grunt1)
				offsetBreath(grunt2)

				local rh = jake.model.Hat:Clone()
				rh:BreakJoints()
				rh.Name = 'RemovableHat'
				rh.Transparency = 1.0
				rh.Parent = jake.model
				local jra = jake.model:FindFirstChild('Right Arm')
				create 'Motor6D' {
					Part0 = jra,
					Part1 = rh,
					C0 = CFrame.new(-.1, -1.06, -.01, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					C1 = CFrame.new(1.4, -2.6, .001, 1, 0, 0, 0, 1, 0, 0, 0, 1),
					Parent = jra
				}
				local jhidle = jake.humanoid:LoadAnimation(create 'Animation' {AnimationId = 'rbxassetid://'.._p.animationId.jhatIdle})
				local jhaction = jake.humanoid:LoadAnimation(create 'Animation' {AnimationId = 'rbxassetid://'.._p.animationId.jhatAction})

				_p.DataManager:preload(667228671)

				touchEvent(nil, map.CTrigger, false, function()
					spawn(function() _p.Menu:disable() end)
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					_p.RunningShoes:disable()

					_p.DataManager:preload(667228671)

					local cam = workspace.CurrentCamera
					cam.CameraType = Enum.CameraType.Scriptable
					local mainCamCF = CFrame.new(556, 119.2, 1317.7, -.664, -.391, .637, 0, .852, .523, -.748, .347, -.566)
						* CFrame.Angles(.1, 0, 0) -- + Vector3.new(0, 2, 0)
					Utilities.lookAt(mainCamCF, nil, 1.8)

					local tp = tess.model.HumanoidRootPart.Position
					local jp = jake.model.HumanoidRootPart.Position
					local pp = tp + Vector3.new(0, 0, -5)
					local pName = _p.PlayerData.trainerName

					tess:Say('You won\'t get away with anything.',
						'We\'re going to stop you!')
					grunt1:Say('Yeah, who\'s "we"?')
					Utilities.Teleport(CFrame.new(pp + Vector3.new(8, 0, 0), pp))
					delay(.5, function() Utilities.exclaim(grunt1.model.Head) end)
					_p.MasterControl:WalkTo(pp)
					spawn(function() _p.MasterControl:LookAt(tp) end)
					tess:LookAt(pp)
					tess:Say('Oh good, you\'re here!',
						'I made it this far, before running into these guys blocking the path out.')
					spawn(function() _p.MasterControl:LookAt(jp) end)
					-- [[
					spawn(function() tess:LookAt(jp) end)
					grunt2:Say('We\'re accepting new member recruits.', 'You\'re welcome to join us.', '...',
						'I should\'ve mentioned, we\'re not taking no for an answer.')
					tess:Say('There\'s no way we would ever join your group of thieves and lunatics.',
						'Not after everything you\'ve done.', 'You\'ve taken our friends and family, and almost removeed an entire city.')
					grunt1:Say('We do what we have to in order to save mankind from its foolish ways.',
						'Don\'t you want people and Pok[e\']mon to be happy?', 'That\'s all we want.')
					tess:Say('You people are all brainwashed into believing your foolish leader\'s ideals.',
						'People and Pok[e\']mon are happy the way they are.', 'Professor Cypress just can\'t see that.',
						'He\'s allowed years of overanalysis to twist his perspective on reality.')
					grunt1:Say('Gah, quit talking.', 'You are wrong, all of what you say is wrong!',
						'We will prove to you the truth of our words in a battle.',
						'If we win, you will have no other choice but to accept our truths and join Team Eclipse.')
					tess:Say('That\'s the most insane thing I have heard in a long time.')
					tess:LookAt(pp)
					tess:Say(pName..', I\'m going to leave it to you to crush these losers.',
						'I have no doubt that you can convince them to leave.')
					spawn(function() tess:LookAt(jp) end)
					grunt1:Say('Who are you calling "loser"?', 'You think we are gonna lose to a kid like you?',
						'I don\'t think so, let\'s go!')
					local win = _p.Battle:doTrainerBattle {
						IconId = 5226446131,
						musicId = {9536676199, 12639990881},
						musicVolume = 2.5,
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = grunt1.model,
						num = 151
					}
					if not win then
						_p.RunningShoes:enable()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
						return
					end
					grunt1:Say('I went easy on you, kid.', 'I didn\'t want to see our newest recruit cry at my hand.')
					grunt2:Say('Yeah whatever, I guess it\'s up to me, then.')
					local win = _p.Battle:doTrainerBattle {
						IconId = 5226446131,
						musicId = {9536676199, 12639990881},
						musicVolume = 2.5,
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = grunt2.model,
						num = 152
					}
					if not win then
						_p.RunningShoes:enable()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
						return
					end
					grunt2:Say('We\'re not through with you yet, kid.')
					grunt1:Say('Yeah, you\'re the kid whose parents we kidnapped, aren\'t you?')
					grunt2:Say('Oh yeah, I thought I recognized you from somewhere.',
						'I saw you the day we kidnapped your parents.', 'I was there when we got \'em.',
						'They begged us not to harm you.',
						'We would have taken you too, if you weren\'t gone playing with your new Pok[e\']mon.')
					spawn(function() Utilities.exclaim(grunt1.model.Head) end)
					spawn(function() Utilities.exclaim(grunt2.model.Head) end)
					spawn(function() grunt1:LookAt(jp) end)
					spawn(function() grunt2:LookAt(jp) end)
					--]]
					jake:Say('Enough!')
					jp = jp + Vector3.new(3, 0, 0)
					spawn(function() grunt1:LookAt(jp) end)
					spawn(function() grunt2:LookAt(jp) end)
					jake:WalkTo(jp)
					-- [[
					jake:Say('We are here to offer people membership in Team Eclipse\'s group.',
						'All who join will be allowed safe passage to the new world.',
						'What do you say?')
					tess:Say('We will never join the likes of you.',
						'You people will remove this world and see a new world fail as people and Pok[e\']mon stop helping each other to prosper.',
						'You think that people and Pok[e\']mon are not existing in harmony, but really we grow from each other.',
						'Why must you remove everything in order to see that?')
					jake:Say('I\'m only trying to help you two.')
					jake:LookAt(pp)
					jake:Say(pName..', don\'t you want to be reunited with your family?')
					jake:LookAt(tp)
					jake:Say('And Tess, if you come with us, we can all be safe!')
					--]]
					local cp = (tp+pp)/2
					jake:LookAt(cp)
					jake:Say('Professor Cypress is very close to discovering the secret to awakening Hoopa.',
						'When he does, this world will be left desolate.',
						'Can\'t you see that I\'m only trying to protect you?')
					Utilities.exclaim(tess.model.Head)
					tess:Say('Wait a second, how do you know my name?')
					delay(.8, chat.manualAdvance)
					jake:Say('[ma]...')
					delay(1.2, chat.manualAdvance)
					jake:Say('[ma]... Tess, ...')
					wait(.7)
					cam.CFrame = CFrame.new(-2.665, .036, 2.74, .021, .193, -.981, 0, .981, .193, 1, -.004, .021)
						* CFrame.Angles(.15, 0, 0) + jake.model.HumanoidRootPart.Position
					wait(.5)
					_p.MusicManager:prepareToStack(1)
					delay(1.2, chat.manualAdvance)
					jake:Say('[ma]...please forgive me.')
					_p.MusicManager:stackMusic(9537319412, 'Cutscene')
					wait(.5)
					local speed = .5
					local function schedule(animTrack, kfName, kfTime, func)
						local fired = false
						local cn
						local function onFire()
							if fired then return end
							fired = true
							pcall(function() cn:disconnect() end)
							cn = nil
							func()
						end
						cn = animTrack.KeyframeReached:connect(function(reachedKfName) if reachedKfName == kfName then onFire() end end)
						delay(kfTime+.05, onFire)
					end
					schedule(jhaction, 'ChangeHats', .3/speed, function()
						jake.model.Hat:remove()--.Transparency = 1.0
						rh.Transparency = 0.0
					end)
					schedule(jhaction, 'ShowHair', .4/speed, function()
						jake.model.Hair.Transparency = 0.0
						jhidle:Play(0.0)
					end)
					jhaction:Play(nil, nil, speed)
					wait(1/speed)
					spawn(function() Utilities.exclaim(tess.model.Head) end)
					wait(.6)
					tess.model.Head.face.Texture = 'rbxassetid://147144198'
					wait(.5)
					delay(.8, chat.manualAdvance)
					tess:Say('[ma]No!')
					delay(2, chat.manualAdvance)
					tess:Say('[ma]No! It can\'t be!')
					cam.CFrame = CFrame.new(558.766, 119.292, 1325.253, 0, -0.431, 0.902, 0, .902, .431, -1, 0, 0)
					wait(1)
					-- jake slowly looks up?
					tess:Say('Jake?')
					wait(.5)
					jake:Say('Yes... it\'s me.')
					wait(.3)
					tess:Say('But... How could you do this, Jake?!')
					cam.CFrame = mainCamCF
					tess.model.Head.face.Texture = 'rbxassetid://629933140'
					jake:Say('You don\'t understand, Tess. They are going to leave this world in ruins.',
						'My best option was to join them, come looking for you guys, then bring you back with me.',
						'I can save all of us.', 'Will you please just stop all this fighting and come back with me?')
					tess:Say('Do you hear what you are saying, Jake?', 'You are fine with what Cypress wants to do to the world as we know it?',
						'He\'s going to remove Roria, and with it, all of its inhabitants!',
						'How can you be okay with that?')
					jake:Say('I\'m doing everything in my power to help you right now, Tess.', 'What else could I have done in my situation?')
					tess:Say('We were supposed to fight Team Eclipse together, remember?',
						'You, '..pName..', and I were going to stop them together.',
						'We were going to do whatever it took to stop this horrible tragedy from occurring.',
						'Instead, you seem to have given up and taken their side?')
					jake:Say('I\'m sorry, I tried that and was beaten.',
						'I was not strong enough, and now I\'m trying to do what I can to save you both.',
						'This is my last offer, will you please give in and come with me?')
					tess:Say('I\'m sorry, Jake, we are on a mission and we are not about to give up.')
					jake:Say('Then I\'m left with no other choice.')
					jake:LookAt(pp)
					jake:Say(pName..', we must battle.', 'If I win, I will be taking you back with me by force.',
						'It\'s for your own good.')
					-- [[
					local win = _p.Battle:doTrainerBattle {
						IconId = 5226446131,
						musicId = {9536676199, 12639990881},
						musicVolume = 2.5,
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = jake.model,
						num = 153
					}
					if not win then
						_p.RunningShoes:enable()
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						chat:enable()
						_p.Menu:enable()
						return
					end
					--]]
					jake:Say('If that\'s how it\'s going to be, then fine.',
						'You are both my best friends.', 'I thought for sure you would listen to me.')
					tess:Say('Listen to yourself, Jake.', 'Yes we are your friends, but you\'ve joined forces with our common enemy.',
						'I know your capture was not easy for you, but we were on our way to rescue you.',
						'You lost your faith in us and our mission, and you joined their side.')
					jake:Say('I\'m sorry, Tess.', 'I wish I was stronger, for you and '..pName..'.',
						'We will leave now.', 'I will look for you again, in case you change your mind.')
					tess:Say('Jake, you don\'t have to do this.')
					jake:Say('Goodbye, Tess.')

					-- jake walks out (tess walks a few steps toward him?)
					local exit = Vector3.new(505.5, 109, 1326)
					spawn(function() tess:WalkTo(tp + (jp-tp).unit*2) end)
					delay(.3, function()
						grunt1:WalkTo(exit)
						grunt1:remove()
					end)
					delay(.5, function()
						grunt2:WalkTo(exit)
						grunt2:remove()
					end)
					jake:WalkTo(exit)
					jake:remove()
					_p.MusicManager:popMusic('Cutscene', 1)

					-- tess continues staring at the exit as she says:
					tess:Say('I cannot believe this, '..pName..'...',
						'After all we\'ve been through together, Jake has turned against us.',
						'I\'m not sure how much longer I can keep this up now.')
					spawn(function() _p.MasterControl:LookAt(tess.model.HumanoidRootPart.Position) end)
					spawn(function() tess:LookAt(pp) end)
					Utilities.lookAt(CFrame.new(547.2, 117, 1321.7, -.789, .279, -.547, 0, .891, .454, .614, .358, -.703))--544.9, 116.9, 1326.8, -.089, .433, -.897, -0, .9, .435, .996, .0386, -.08))
					tess:Say('You and Jake were the reason I left home on this adventure.',
						'Jake was such an inspiration to me, and now he\'s done this.',
						'This encounter has hurt me so very deeply.',
						'I don\'t know if I have the courage and energy to keep going now.', '...')
					tess.model.Head.face.Texture = 'rbxassetid://209713384'
					tess:Say('No... We can\'t give up!',
						'Jake needs us now more than ever.', 'I know that he\'s still good at heart.',
						'He\'s just confused right now. That\'s all.',
						'He\'s always been worried about how physically strong he and his Pok[e\']mon are.',
						'He still doesn\'t realize that physical strength is not important.',
						'It\'s the strength to always do what\'s right in the face of adversity that we must cling to.',
						'We must not give up. We must help him learn that.',
						'Well, are you ready to press forward?', '...',
						'Good, I\'m glad that you are so strong.', 'We can do this.',
						'After all, we have something they need and can\'t move forward without.',
						'The key.', 'Your necklace is the missing puzzle piece to unlocking Hoopa.',
						'If we can keep it safe and out of their hands, they are stuck, which gives us time to reach their base.',
						'We aren\'t far now from Frostveil.',
						'I say we go ahead and make our way there and get prepared for the rest of our journey to Crescent Island.',
						'I\'ll see you in Frostveil.')
					spawn(function() _p.MasterControl:LookAt(exit) end)
					spawn(function() tess:WalkTo(exit) end)
					Utilities.lookBackAtMe(1)
					tess:Stop()
					wait()
					tess:remove()
					if construction then construction.Parent = map end

					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.Menu:enable()
					chat:enable()
				end)
			end
		end,

		onLoad_chunk44 = function(chunk)
			if not _p.PlayerData.badges[7] then
				chat:say('You Haven\'t Gotten the 7th Gym Badge Yet.', 'Come Back When you Have the 7th Gym Badge.','Then ill give you what you came for.')
				return end
			--		suicune,301815944,115.93,1.06

			local map = chunk.map
			local raikou, entei, suicune = map:FindFirstChild('Raikou'), map:FindFirstChild('Entei'), map:FindFirstChild('Suicune')
			if raikou and entei and suicune then
				local raikouRun = raikou.AnimationController:LoadAnimation(create 'Animation' {AnimationId = 'rbxassetid://'.._p.animationId.raikouRun})
				local enteiRun = entei.AnimationController:LoadAnimation(create 'Animation' {AnimationId = 'rbxassetid://'.._p.animationId.enteiRun})
				local suicuneRun = suicune.AnimationController:LoadAnimation(create 'Animation' {AnimationId = 'rbxassetid://'.._p.animationId.suicuneRun})

				touchEvent('RBeastTrio', map.CTrigger, true, function()
					_p.MasterControl.WalkEnabled = false
					_p.RunningShoes:disable()
					spawn(function() _p.Menu:disable() end)
					local walking = true
					spawn(function()
						_p.MasterControl:WalkTo(Vector3.new(1212, 28, 1539))
						walking = false
					end)
					local rbase, ebase, sbase = raikou.Base, entei.Base, suicune.Base
					local rp, ep, sp = rbase.Position, ebase.Position, sbase.Position
					local exit = Vector3.new(1186, 27, 1539)
					local transform = CFrame.Angles(0, math.pi, 0)

					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					spawn(function() Utilities.lookAt(CFrame.new(1208.3, 41.1, 1552.2, .659, .41, -.631, 0, .839, .545, .752, -.359, .553) * CFrame.Angles(.1, 0, 0), nil, 2) end)
					Tween(99, nil, function()
						if not walking then return false end
						local pp
						pcall(function() pp = _p.player.Character.HumanoidRootPart.Position end)
						if not pp then return end
						rbase.CFrame = CFrame.new(rp, Vector3.new(pp.X, rp.Y, pp.Z))*transform
						ebase.CFrame = CFrame.new(ep, Vector3.new(pp.X, ep.Y, pp.Z))*transform
						sbase.CFrame = CFrame.new(sp, Vector3.new(pp.X, sp.Y, pp.Z))*transform
					end)

					wait(.5)
					-- raikou
					spawn(function() _p.MasterControl:LookAt(raikou.Head.Head.Position) end)
					spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301815944, startTime = 111.41, duration = 1.25}) end)
					spawn(function() chat:say(raikou.Head.Head, '[ma]Raaairawr!') end)
					wait(1.15)
					chat:manualAdvance()
					--				wait(.5)
					raikouRun:Play(nil, nil, 1.5)
					local bcf = CFrame.new(rp, Vector3.new(exit.X, rp.Y, exit.Z))*transform
					local dir = -bcf.lookVector
					local lerp = select(2, Utilities.lerpCFrame(rbase.CFrame, bcf))
					spawn(function() _p.MasterControl:LookAt(exit) end)
					local timer = Utilities.Timing.easeOutCubic(.3)
					Tween(1.2, nil, function(a)
						rbase.CFrame = (a<.3 and lerp(timer(a)) or bcf) + dir*40*a
					end)
					raikou:remove()

					-- entei
					spawn(function() _p.MasterControl:LookAt(entei.Head.Head.Position) end)
					spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301815944, startTime = 113.65, duration = 1.28}) end)
					spawn(function() chat:say(entei.Head.ChatFrom, '[ma]Graahrawrr!') end)
					wait(1.15)
					chat:manualAdvance()
					--				wait(.5)
					enteiRun:Play(nil, nil, 1.5)
					bcf = CFrame.new(ep, Vector3.new(exit.X, ep.Y, exit.Z))*transform
					dir = -bcf.lookVector
					lerp = select(2, Utilities.lerpCFrame(ebase.CFrame, bcf))
					spawn(function() _p.MasterControl:LookAt(exit) end)
					Tween(1.2, nil, function(a)
						ebase.CFrame = (a<.3 and lerp(timer(a)) or bcf) + dir*40*a
					end)
					entei:remove()

					-- suicune
					spawn(function() _p.MasterControl:LookAt(suicune.Head.Head.Position) end)
					spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 301815944, startTime = 115.93, duration = 1.06}) end)
					spawn(function() chat:say(suicune.Head.Head, '[ma]Grahyeeeyoo!') end)
					wait(1)
					chat:manualAdvance()
					suicuneRun:Play(nil, nil, 1.5)
					local midpoint = Vector3.new(1212, 28, 1533)
					bcf = CFrame.new(sp, Vector3.new(midpoint.X, sp.Y, midpoint.Z))*transform
					dir = -bcf.lookVector
					lerp = select(2, Utilities.lerpCFrame(sbase.CFrame, bcf))
					spawn(function() _p.MasterControl:LookAt(exit) end)
					timer = Utilities.Timing.easeOutCubic(.4)
					local dist = (bcf.p-midpoint).magnitude
					Tween(dist/40*1.2, nil, function(a)
						sbase.CFrame = (a<.4 and lerp(timer(a)) or bcf) + dir*dist*a
					end)
					bcf = CFrame.new(sbase.Position, Vector3.new(exit.X, sp.Y, exit.Z))*transform
					dir = -bcf.lookVector
					lerp = select(2, Utilities.lerpCFrame(sbase.CFrame, bcf))
					spawn(function() _p.MasterControl:LookAt(exit) end)
					local dist = (bcf.p-exit).magnitude
					Tween(dist/40*1.2, nil, function(a)
						sbase.CFrame = (a<.4 and lerp(timer(a)) or bcf) + dir*dist*a
					end)
					suicune:remove()
					wait(1)
					chat:say('The wild Pok[e\']mon fled!', 'Raikou, Entei, and Suicune can now be found roaming in the wild.')

					Utilities.lookBackAtMe()
					--_p.MasterControl:Start()
					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true
					_p.Menu:enable()
				end)
			end
		end,
		
		onLoad_chunk45 = function(chunk)
		

			--// Latios & Latias Cutscene
			local latias = chunk.map:FindFirstChild("Latias")
			local latios = chunk.map:FindFirstChild("Latios") 
			if completedEvents.EonDuo then 
				latias:remove()
				latios:remove()
				return
			end

			spawn(function() _p.DataManager:preload("Sound", 15487232315) end)
			local amain = latias.Main
			local acfs = {}
			local amcfi = amain.CFrame:inverse()
			for _, ch in pairs(latias:GetChildren()) do
				if ch ~= amain and ch:IsA("BasePart") then
					acfs[ch] = amcfi * ch.CFrame
				end
			end
			local omain = latios.Main
			local ocfs = {}
			local omcfi = amain.CFrame:inverse()
			for _, ch in pairs(latios:GetChildren()) do
				if ch ~= omain and ch:IsA("BasePart") then
					ocfs[ch] = omcfi * ch.CFrame
				end
			end
			local p0 = latios.Main.Position
			local p1 = p0 + Vector3.new(-236, 30, -15)
			local p2 = p1 + Vector3.new(-178, 32, -114)
			local p3 = p2 + Vector3.new(-352, 43, 126)

			touchEvent('EonDuo', chunk.map.CTrigger, true, function()
				_p.Hoverboard:unequip(true)
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				spawn(function()
					_p.MasterControl:LookAt(p0)
				end)
				spawn(function()
					Utilities.exclaim(_p.player.Character.Head)
				end)
				local root = _p.player.Character.HumanoidRootPart
				local pp = root.Position
				local cam = workspace.CurrentCamera
				local fp = cam.Focus.p
				cam.CameraType = Enum.CameraType.Scriptable
				local function getCamCF(p)
					local camcf = CFrame.new(fp, p)
					return camcf + (camcf * Vector3.new(4, 0, 6) - camcf.p) * Vector3.new(1, 0.5, 1)
				end

				Utilities.lookAt(getCamCF(p0))

				Utilities.sound(15487232315, nil, nil, 10)
				local function fly()
					Utilities.Tween(3, nil, function(alpha)
						local alphaSquared = alpha * alpha
						local alphaCubed = alpha * alphaSquared
						local oneMinusAlpha = 1 - alpha
						local oneMinusAlphaSquared = oneMinusAlpha * oneMinusAlpha
						local oneMinusAlphaCubed = oneMinusAlpha * oneMinusAlphaSquared
						--I found you brad ;)
						--https://prnt.sc/uogf6e
						--B(t) = (1 - t) ^ 3 * p0 + 3 * (1 - t) ^ 2 * t * p1 + 3 * (1 - t) * t ^ 2 * p3
						local position = oneMinusAlphaCubed * p0 + 3 * oneMinusAlphaSquared * alpha * p1 + 3 * oneMinusAlpha * alphaSquared * p2 + alphaCubed * p3
						local back = -3 * ((p3 - 3 * p2 + 3 * p1 - p0) * alphaSquared + (2 * p2 - 4 * p1 + 2 * p0) * alpha + p1 - p0).unit
						local up, aangle
						if alpha < 0.75 then
							local subalpha = alpha / 0.75
							local a = subalpha * math.pi
							up = Vector3.new(0, math.sin(a), -math.cos(a))
							aangle = math.pi * (-0.25 + subalpha * 1.25)
						else
							local subalpha = (alpha - 0.75) * 4
							local a = subalpha * math.pi / 2
							up = Vector3.new(0, math.sin(a), math.cos(a))
							aangle = math.pi * (1 - 0.75 * subalpha)
						end
						local right = up:Cross(back)
						local cf = CFrame.new(position.X, position.Y, position.Z, right.X, up.X, back.X, right.Y, up.Y, back.Y, right.Z, up.Z, back.Z)
						latias:SetPrimaryPartCFrame(cf)
						local acf = cf * CFrame.new(-math.cos(aangle) * 8, math.sin(aangle) * 8, 20 - 10 * alpha)
						latios:SetPrimaryPartCFrame(acf)
						root.CFrame = CFrame.new(pp, Vector3.new(position.X, pp.Y, position.Z))
						cam.CFrame = getCamCF(position)
					end)
				end
				fly()
				p0 = p3 
				p1 = p3 + Vector3.new(380, 58, -119)
				p2 = p3 + Vector3.new(156, 81, -281)
				p3 = p2 + Vector3.new(0, 1, -100)

				fly()
				latias:remove()
				latios:remove()
				wait(1)
				chat:say('Latias and Latios can now be found roaming in the wild.')
				Utilities.lookAt(CFrame.new(fp + Vector3.new(-1, 3, 5) * 2, fp))
				Utilities.lookBackAtMe(0.2)
				_p.MasterControl.WalkEnabled = true
			end)		
		end,

		--[[
onLoad_gym7 = function(chunk) -- gym 7 is also a chunk
	--		MasterControl:SetJumpEnabled(true)
	-- [[
	local Zeek = chunk.npcs.LeaderZeek
	interact[Zeek.model] = function()
		if _p.PlayerData.badges[7] then
			Zeek:Say('I wish you the best of luck as you continue your adventure.',
				'Watch Your Step On the Way Out.')
		else
			Zeek:Say('Welcome Weary Traveler.',
				'My Name is Zeek, and I am the Frostveil City Gym Leader.',
				'I bet you had an interesting time finding your way through the maze to get this far.',
				'Darkness gives our Pok[e\']mon the advantage of stealth and prowess.',
				'It also saves us on the electric bill, most of the time.',
				'I\'m assuming you\'re here to try to win my gym badge.',
				'My Pok[e\']mon are prepared to take you on.',
				'Can you handle their dark power?',
				'Let\'s find out shall we?')
			local win = _p.Battle:doTrainerBattle {
				musicId = 5887689829,
				musicVolume = 0.8,
				PreventMoveAfter = true,
				trainerModel = Zeek.model,
				vs = {name = 'Zeek', id = 658350333, hue = 10000, sat = 10000},
				num = 154
			}
			if win then
				Zeek:Say('Well, I guess you win fair and square.',
					'I must say i wasn\'t expecting your Pok[e\']mon to handle this so well.',
					'I guess we\'ll have to take what we learned today and learn how to counter moves like yours.',
					'I want you to have this now as a token of your victory.')
				local badge = chunk.map.Badge7:Clone()
				local cfs = {}
				local main = badge.SpinCenter
				for _, p in pairs(badge:GetChildren()) do
					if p:IsA('BasePart') and p ~= main then
						p.CanCollide = false
						cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
					end
				end
				badge.Parent = workspace
				local st = tick()
				local spinRate = 1
				local function cframeTo(rcf)
					local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi/2, 0, (tick()-st)*spinRate + math.pi/2)
					main.CFrame = cf
					for p, ocf in pairs(cfs) do
						p.CFrame = cf:toWorldSpace(ocf)
					end
				end
				local r = 8
				local f = CFrame.new(0, 0, -6)
				Tween(1, nil, function(a)
					local t = a*math.pi/2
					cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
				end)
				local spin = true
				Utilities.fastSpawn(function()
					while spin do
						cframeTo(f)
						stepped:wait()
					end
				end)
				wait(2)
				onObtainBadgeSound()
				chat.bottom = true
				chat:say('Obtained the Contrast Badge!')
				chat.bottom = nil
				spin = false
				Tween(.5, nil, function(a)
					local t = (1-a)*math.pi/2
					cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
				end)
				badge:remove()

				Zeek:Say('Equipped with the Contrast Badge you will be able to trade for Pok[e\']mon up to level 90.',
					'You will also be able to use the move Surf outside of battle.',
					'I would also like for you to have this TM.')
				onObtainItemSound()
				chat.bottom = true
				chat:say('Obtained a TM97!',
					_p.PlayerData.trainerName .. ' put the TM97 in the Bag.')
				chat.bottom = nil
				Zeek:Say('Dark Pulse is a Dark-type special attack that can even cause your opponent to flinch if you\'re lucky.', 
					'Your victory may have been in the dark, but you have a bright future ahead of you.',
					'With that, I wish you the best of luck as you continue your adventure.',
					'Also, Watch your step on the way out, Dont get lost.')
				--_p.PlayerData:completeEvent('FrostveilComplete')
			end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
			chat:enable()
			_p.Menu:enable()
		end
	end
end,
	--]]	

		--NEW GYM 7!!!
		onLoad_gym72 = function(chunk)
			warn('CHUNK?')
			print(chunk.id)
			local player = _p.player
			_p.MasterControl:SetJumpEnabled(true)
			--pcall(function()
			--	workspace.UnionMeshPreload:remove()
			--end)
			warn('gym:')
			warn(chunk.map:GetFullName())
			for _, ch in pairs(chunk.map.Walkable:GetChildren()) do
				if ch:IsA("BasePart") or ch:IsA("WedgePart") then
					ch.Transparency = 1
				end
			end
			for _, ch in pairs(chunk.map.Visible:GetChildren()) do
				if ch:IsA("BasePart") or ch:IsA("WedgePart") then
					ch.CanCollide = false
				end
			end
			local lighting = game:GetService("Lighting")
			game:GetService("ContentProvider"):PreloadAsync({
				create("Sky")({
					Name = "Gym7Sky",
					CelestialBodiesShown = false,
					SkyboxBk = "rbxassetid://55054494",
					SkyboxLf = "rbxassetid://55054494",
					SkyboxRt = "rbxassetid://55054494",
					Parent = lighting
				})
			})
			--local lf
			--lf = {
			--	tod = lighting.TimeOfDay,
			--	cn = lighting.Changed:connect(function(prop)
			--		if prop ~= "TimeOfDay" then
			--			return
			--		end
			--		if lighting.TimeOfDay == "14:00:00" then
			--			return
			--		end
			--		lf.tod = lighting.TimeOfDay
			--		lighting.TimeOfDay = "14:00:00"
			--	end)
			--}
			_p.DataManager:lockClockTime(14)
			--	_p.Events.gym7_lightingfix = lf
			lighting.TimeOfDay = "14:00:00"
			--lighting.FogColor = Color3.new(0, 0, 0)
			--lighting.FogEnd = 10
			create("BodyPosition")({
				Position = Vector3.new(0, 0, 4297.915),
				MaxForce = Vector3.new(0, 0, math.huge),
				D = 1,
				Parent = player.Character.HumanoidRootPart
			})
			_p.MasterControl:SetIndoors(true)
			local moveFunc = player.Move
			local trusses = {}
			for _, truss in pairs(Utilities.GetDescendants(chunk.map, "TrussPart")) do
				trusses[truss] = truss.CFrame
			end
			local currentLadderCollision = true
			local zero3 = Vector3.new(0, 0, 0)
			local function overrideMoveFunc(_, dir, rel)
				local c = dir.Z < -0.5 or dir == zero3 and pcall(function()
					return player.Character.HumanoidRootPart.CFrame.lookVector.Z > 0
				end)
				if c ~= currentCollision then
					currentCollision = c
					for truss in pairs(trusses) do
						truss.CanCollide = c
					end
				end
				moveFunc(player, dir, rel)
			end
			local human = Utilities.getHumanoid()
			if human.RigType == Enum.HumanoidRigType.R15 then
				_p.MasterControl:SetMoveFunc(nil)
				currentCollision = true
				for tp, cf in pairs(trusses) do
					tp.CanCollide = true
					tp.CFrame = cf
				end
			else
				_p.MasterControl:SetMoveFunc(overrideMoveFunc)
				for tp, cf in pairs(trusses) do
					tp.CFrame = cf * CFrame.new(0, 0, -0.2)
				end
			end
			for _, bin in pairs(chunk.map.Important:GetChildren()) do
				if bin.Name == "PlatformButton" then
					do
						local plat = bin.Platform
						plat.Parent = nil
						local debounce = false
						bin.Trigger.Touched:connect(function(p)
							if not p or p.Parent ~= player.Character then
								return
							end
							if debounce then
								return
							end
							debounce = true
							bin.RemoveOnPress:remove()
							plat.Parent = bin
						end)
					end
				end
			end
			do
				local bin = chunk.map.Important.TrapDoor
				local debounce = false
				local wall = bin.Wall
				wall.Transparency = 0
				bin.Trigger.Touched:connect(function(p)
					if not p or p.Parent ~= player.Character then
						return
					end
					if debounce then
						return
					end
					debounce = true
					_p.MasterControl.WalkEnabled = false
					--		MasterControl:Stop()
					local lfloor, rfloor = bin.LFloor:Clone(), bin.RFloor:Clone()
					local lhinge = lfloor.CFrame * CFrame.new(3, 0.5, 0)
					lfloor.CanCollide = false
					lfloor.Size = Vector3.new(6, 1, 0.2)
					lfloor.Transparency = 0
					lfloor.Parent = bin
					local lrcf = lhinge:inverse() * lfloor.CFrame
					local rhinge = rfloor.CFrame * CFrame.new(-3, 0.5, 0)
					rfloor.CanCollide = false
					rfloor.Size = Vector3.new(6, 1, 0.2)
					rfloor.Transparency = 0
					rfloor.Parent = bin
					local rrcf = rhinge:inverse() * rfloor.CFrame
					delay(0.3, function()
						bin.MainFloor:remove()
					end)
					Utilities.Tween(0.5, "easeOutCubic", function(a)
						wall.Transparency = a
						lfloor.CFrame = lhinge * CFrame.Angles(0, 0, a) * lrcf
						rfloor.CFrame = rhinge * CFrame.Angles(0, 0, -a) * rrcf
					end)

					_p.MasterControl.WalkEnabled = true
					_p.MasterControl:SetJumpEnabled(true)
					bin.LFloor:remove()
					bin.RFloor:remove()
					bin.Trigger.CanCollide = false
				end)
			end
			local coffset = Vector3.new(0, 0, -20)
			local curtain = chunk.map.Curtain
			local cmain = curtain.Main
			local ccfs = {}
			do
				local cmaincfinverse = cmain.CFrame:inverse()
				for _, p in pairs(curtain:GetChildren()) do
					if p ~= cmain and p:IsA("BasePart") then
						ccfs[p] = cmaincfinverse * p.CFrame
					end
				end
			end
			local camOffset = Vector3.new(0, 1.5, 0)
			pcall(function()
				local human = Utilities.getHumanoid()
				if human.RigType == Enum.HumanoidRigType.R15 then
					camOffset = Vector3.new(0, 3.5 - human.HipHeight, 0)
				end
			end)
			game:GetService("RunService"):BindToRenderStep("gym7CameraRenderUpdate", Enum.RenderPriority.Last.Value + 20, function()
				if _p.Battle.currentBattle then
					return
				end
				local cam = workspace.CurrentCamera
				if not cam then
					return
				end
				local pos
				pcall(function()
					pos = player.Character.HumanoidRootPart.Position + camOffset
				end)
				if not pos then
					return
				end
				cam.CFrame = CFrame.new(pos + coffset, pos)
				local cf = CFrame.new(pos) * CFrame.Angles(1.57, 0, 0)
				cmain.CFrame = cf
				for p, rcf in pairs(ccfs) do
					p.CFrame = cf * rcf
				end
			end)

			workspace.CurrentCamera.FieldOfView = 70
			local leader = chunk.npcs.Leader
			interact[leader.model] = function()
				if _p.PlayerData.badges[7] then
					leader:Say("Your victory may have been in the dark, but you have a bright future ahead of you.", "With that, I wish you the best of luck as you continue your adventure.", "Also, watch your step on the way out.")
				else
					leader:Say("Welcome, weary traveler.", "My name is Zeek, and I am the Frostveil City Gym Leader.", "I bet you had an interesting time finding your way through the dark to get this far.", "The darkness gives our Pok[e\']mon the advantage of stealth and prowess.", "It also saves us on the electric bill.", "I'm assuming you're here to try to win my gym badge.", "My Pok[e\']mon are prepared to take you on.", "Can you handle their dark power?")
					local win = _p.Battle:doTrainerBattle({
						musicId = 5887689829,
						musicVolume = 1,
						PreventMoveAfter = true,
						trainerModel = leader.model,
						vs = {
							name = "Zeek",
							id = 739146541,
							hue = 0.67,
							sat = 0.1
						},
						num = 154
					})
					if win then
						leader:Say("Well, I guess you win fair and square.", "I must say, I wasn't expecting your Pok[e\']mon to handle this darkness so well.", "I guess we'll have to take what we learned today and learn how to counter moves like yours.", "I want you to have this now as a token of your victory.")
						do
							local badge = chunk.map.Badge7:Clone()
							local cfs = {}
							local main = badge.SpinCenter
							for _, p in pairs(badge:GetChildren()) do
								if p:IsA("BasePart") and p ~= main then
									p.CanCollide = false
									cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
								end
							end
							badge.Parent = workspace
							local st = tick()
							local spinRate = 1
							local function cframeTo(rcf)
								local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi / 2, 0, (tick() - st) * spinRate + math.pi / 2)
								main.CFrame = cf
								for p, ocf in pairs(cfs) do
									p.CFrame = cf:toWorldSpace(ocf)
								end
							end
							local r = 8
							local f = CFrame.new(0, 0, -6)
							Tween(1, nil, function(a)
								local t = a * math.pi / 2
								cframeTo(CFrame.new(0, -r + math.sin(t) * r, f.z - math.cos(t) * r * 0.5))
							end)
							local spin = true
							Utilities.fastSpawn(function()
								while spin do
									cframeTo(f)
									stepped:wait()
								end
							end)
							wait(2)
							onObtainBadgeSound()
							chat.bottom = true
							chat:say("Obtained the Contrast Badge!")
							chat.bottom = nil
							spin = false
							Tween(0.5, nil, function(a)
								local t = (1 - a) * math.pi / 2
								cframeTo(CFrame.new(0, -r + math.sin(t) * r, f.z - math.cos(t) * r * 0.5))
							end)
							badge:remove()
							leader:Say("Equipped with the Contrast Badge, you will be able to trade for Pok[e\']mon up to level 90.", "You will also be able to use the move Surf outside of battle.", "I would also like for you to have this TM.")
							onObtainItemSound()
							chat.bottom = true
							chat:say("Obtained a TM97!", _p.PlayerData.trainerName .. " put the TM97 in the Bag.")
							chat.bottom = nil
							leader:Say("Dark Pulse is a Dark-type special attack that can even cause your opponent to flinch if you're lucky.", "Your victory may have been in the dark, but you have a bright future ahead of you.", "With that, I wish you the best of luck as you continue your adventure.", "Also, watch your step on the way out.")
						end
					end
					_p.MasterControl.WalkEnabled = true
					chat:enable()
					_p.Menu:enable()
				end
			end
		end,
		onUnload_gym72 = function()
			local lighting = game:GetService("Lighting")
			pcall(function()
				lighting.Gym7Sky:remove()
			end)
			pcall(function()
				_p.player.Character.HumanoidRootPart.BodyPosition:remove()
			end)
			_p.MasterControl:SetIndoors(false)
			_p.MasterControl:SetMoveFunc(nil)
			game:GetService("RunService"):UnbindFromRenderStep("gym7CameraRenderUpdate")
			_p.DataManager:unlockClockTime()
			--lighting.FogColor = Color3.new(191, 191, 191)
			--lighting.FogEnd = 10000
			_p.MasterControl:SetJumpEnabled(false)
		end,	




		-- [[


		onLoad_chunk46 = function(chunk) -- tess battle after gym 7
			if not completedEvents.vFrostveil then 
				spawn(function() _p.PlayerData:completeEvent('vFrostveil') end)end
			local Tess = chunk.npcs.Tess
			if completedEvents.BeatTessFrost then
				Tess:remove()
				chunk:getDoor('Gate20').disabled = false
			else
				chunk:getDoor('Gate20').disabled = true				
				interact[Tess.model] = function()				
					local jp = Tess.model.HumanoidRootPart.Position
					local pp = _p.player.Character.HumanoidRootPart.Position				
					if not _p.PlayerData.badges[7] then--
						--Tess:Say('Hey ' .. _p.PlayerData.trainerName .. ', Have you gotten the 7th Badge Yet?',
						--	'Come back when you have gotten it.')
						Tess:Say("Hey, " .. _p.PlayerData.trainerName .. ".", "Glad to see that you made it.", "Before we head off to Port Decca, you should swing by Frostveil City Gym and train up.", "We'll need you to be as strong as possible in case we run into any more Team Eclipse members.")

					else
						_p.Menu:disable()
						_p.MasterControl.WalkEnabled = false			
						Tess:Say('Hey ' .. _p.PlayerData.trainerName .. ', Have you gotten the 7th Badge Yet?',
							'Oh, you did it!',
							'You beat Frostveil\'s gym leader!',
							'That\'s really impressive!',
							'Listen ' .. _p.PlayerData.trainerName .. ', I have a request before we move on to Port Decca.',
							'It\'s been a while since we have battled each other.',
							'I\'ve also been training my Pok[e\']mon, and I think we\'ve gotten a lot stronger.',
							'What I\'m saying is, would you mind if we had another battle?',
							'I think battling you will help me learn a lot more and prepare me for what is ahead.',
							'I will give it my best shot!')					
						local win = _p.Battle:doTrainerBattle {
							battleSceneType = 'Frostveil',
							musicId = 12639840340,
							musicVolume = 0.7,
							PreventMoveAfter = true,
							--LeaveCameraScriptable = true,
							trainerModel = Tess.model,
							num = 187
						}					
						if not win then
							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()
							chat:enable()
							_p.Menu:enable()
							return
						end							
						Tess:Say('Wow, you have gotten way stronger since our last battle!',
							'I learned so much from you, and I\'m sure there is still more to learn.',
							'Thanks for the battle.',
							'Now then, we better be off to Port Decca.',
							'Route 16 is just through this gate.',
							'I heard it\'s a popular slope for hoverboarders.',
							'If you haven\'t gotten yourself a hoverboard yet, you should fly back to Anthian City first and pick one up from Hero Hoverboards in Anthian Shopping District.',

							'I\'ll meet you at Port Decca.',
							'See you there!')																				
						local door = chunk:getDoor('Gate20')
						wait()
						local p1 = pp + Vector3.new(4, 0, 0)
						local p2 = pp + Vector3.new(-4, 0, 0)
						door:open(.8)
						Tess:WalkTo(door.Position + Vector3.new(0, 0, 3))	
						door:close(.3)
						Tess:WalkTo(door.Position + Vector3.new(0, 0, 5))
						Tess:remove()
						_p.PlayerData:completeEvent('FrostveilDepart')
						chunk:getDoor('Gate20').disabled = false												
					end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					chat:enable()
					_p.Menu:enable()					
				end				
			end
		end,				
		--]]					

	--[[	
		onLoad_chunk51 = function(chunk) -- gate keeper battle
			if not completedEvents.meetGatekeeper then 
				spawn(function() _p.PlayerData:completeEvent('meetGatekeeper') end)end
			local gatekeeper = chunk.npcs.gatekeeper
			local postWinInteract = {
				'Good luck on your adventure to Victory Road, trainer!',
				'You are ready to take on the challenge up ahead!'
			}
			if completedEvents.vVictoryRoad then			
				chunk:getDoor('').disabled = false--victory rd gate				
			else
				chunk:getDoor('').disabled = true--victory rd gate				
				interact[gatekeeper.model] = function()					
					local jp = gatekeeper.model.HumanoidRootPart.Position
					local pp = _p.player.Character.HumanoidRootPart.Position					
					if not _p.PlayerData.badges[8] then--
						gatekeeper:Say('Behind this gate is the entrance to Victory Road.',
							'Only trainers who\'ve collected all eight Badges may pass!',
							'Your total number of Badges is... One, two, three, four...',
							'Oops! Looks like you don\'t have enough Badges.',
							'Come back when you have all eight Badges!')						
					else
						_p.Menu:disable()
						MasterControl.WalkEnabled = false					
						gatekeeper:Say('Behind this gate is the entrance to Victory Road.',
							'Only trainers who\'ve collected all eight Badges may pass!',
							'Your total number of Badges is... One, two, three, four...',
							'Wow! You have all eight. Well then, allow me to test your abilities.')					
						local win = _p.Battle:doTrainerBattle {
							battleScene = 'Safari',
							musicId = 303861020,
							musicVolume = 0.7,
							PreventMoveAfter = true,
							LeaveCameraScriptable = true,
							trainerModel = gatekeeper.model,
							num = 188
						}						
						if not win then
							MasterControl.WalkEnabled = true
							MasterControl:Start()
							chat:enable()
							_p.Menu:enable()
							return true
						end						
						gatekeeper:Say('Amazing!',
							'You can continue to Victory Road!'
							--add more dialogs later
							
						)							
						local door = chunk:getDoor('')--victory road gate
						wait()
						local p1 = pp + Vector3.new(4, 0, 0)
						local p2 = pp + Vector3.new(-4, 0, 0)
						if (jp-p1).magnitude+(p1-door.Position).magnitude < (jp-p2).magnitude+(p2-door.Position).magnitude then
							gatekeeper:WalkTo(p1)
						else
							gatekeeper:WalkTo(p2)
						end
						gatekeeper:WalkTo(door.Position + Vector3.new(0, 0, 2))
						door:open(.5)
						delay(.5, function()
							door:close(.5)
						end)
						gatekeeper:WalkTo(door.Position + Vector3.new(0, 0, -15))
						gatekeeper:remove()
						_p.PlayerData:completeEvent('vVictoryRoad')
						
						chunk:getDoor('').disabled = false--victory rd gate						
					end
					MasterControl.WalkEnabled = true
					MasterControl:Start()
					chat:enable()
					_p.Menu:enable()					
				end				
			end			
		end,
				
	--]]	

--[[
		onExit_Gate4 = function()
			local chunk = _p.DataManager.currentChunk
			if chunk.id ~= 'chunk5' then return end
			if completedEvents.TalkToJakeAndSebastian then return end
			chat:say(_p.PlayerData.trainerName .. ', quick, over here!')
			local jp = Vector3.new(-109, 144, -1426)
			local lp = Vector3.new(-115, 144, -1426)
			local wp = Vector3.new(-112, 144, -1430)
			local pp = _p.player.Character.HumanoidRootPart.Position
			local jake = _p.NPC:PlaceNew('Jake', chunk.map, CFrame.new(jp, pp))
			local leader = _p.NPC:PlaceNew('LeaderSebastian', chunk.map, CFrame.new(lp, pp))

			local cam = workspace.CurrentCamera
			local camGoal = CFrame.new(-126.174782, 156.702637, -1447.93384, -0.837163031, 0.28281191, -0.468162, -0, 0.855944753, 0.517067432, 0.546953619, 0.432869732, -0.716565132)
			local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, camGoal))
			spawn(function()
				Tween(1.5, 'easeOutCubic', function(a)
					local cf = lerp(a)
					cam.CoordinateFrame = CFrame.new(cf.p, cf.p+cf.lookVector)
				end)
			end)
			MasterControl:WalkTo(wp)
			spawn(function() _p.PlayerData:completeEvent('TalkToJakeAndSebastian') end)
			spawn(function() leader:LookAt(wp) end)
			jake:LookAt(wp)
			chat:say(jake, 'This is the Gym Leader of the Brimber City Gym.',
				'I just ran into him as I walked into town.')
			spawn(function() leader:LookAt(jp) end)
			delay(.5, function() _p.Menu:enable() end)

			return true
		end,
--]]

		onLoad_chunk75 = function(chunk)
			-- Puzzle 2
			local order = {
				'Red',
				'Green',
				'Red',
				'Blue',
				'Blue',
				'Yellow',
				'Green',

			}
			local cbutton
			local stage = 1
			local dolightup = function(color,state)
				if state then
					for _,obj in pairs(chunk.map[color..'Lights']:GetChildren()) do
						obj.Material = Enum.Material.Neon
					end
					for _,obj in pairs(chunk.map.LightDoor:GetChildren()) do
						if obj.Name == color..'Lights' then
							obj.Material = Enum.Material.Neon
						end
					end
				else
					for _,obj in pairs(chunk.map[color..'Lights']:GetChildren()) do
						obj.Material = Enum.Material.Plastic
					end
					for _,obj in pairs(chunk.map.LightDoor:GetChildren()) do
						if obj.Name == color..'Lights' then
							obj.Material = Enum.Material.Plastic
						end
					end
				end
			end
			local dopuzzle = function(buttonname)
				if order[stage] == buttonname then
					stage = stage + 1
				else
					stage = 1
				end
				if stage == 8 then
					spawn(function() 
						wait(1)
						local cam = workspace.CurrentCamera
						cam.CameraType = Enum.CameraType.Scriptable
						cam.CFrame = chunk.map.DOORCAM.CFrame
						spawn(function() _p.Menu:disable() end)
						_p.MasterControl.WalkEnabled = false
						_p.MasterControl:Stop()
						wait(.5)
						dolightup('Blue', true)
						wait(.5)
						dolightup('Red', true)
						wait(.5)
						dolightup('Yellow', true)
						wait(.5)
						local model = chunk.map.LightDoor
						local DoorMain = model.Main
						local DoorCFrame = DoorMain.CFrame
						Utilities.Tween(3, "easeInSine", function(p87)
							Utilities.MoveModel(DoorMain, DoorCFrame + Vector3.new(0, 8 * p87, 0))
						end)
						Utilities.lookBackAtMe()
						spawn(function() _p.Menu:enable() end)
						pcall(function() _p.PlayerData:completeEvent('LightPuzzle') end)
						_p.MasterControl.WalkEnabled = true
					end)
				end
			end
			chunk.map.Buttons.Red.Touched:Connect(function(p)
				local name = 'Red'
				if cbutton == name or (not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player) or completedEvents.LightPuzzle then return end
				if cbutton then dolightup(cbutton, false) end
				cbutton = name
				dopuzzle(name)
				dolightup(name, true)
			end)
			chunk.map.Buttons.Green.Touched:Connect(function(p)
				local name = 'Green'
				if cbutton == name or (not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player) or completedEvents.LightPuzzle then return end
				if cbutton then dolightup(cbutton, false) end
				cbutton = name
				dopuzzle(name)
				dolightup(name, true)
			end)
			chunk.map.Buttons.Blue.Touched:Connect(function(p)
				local name = 'Blue'
				if cbutton == name or (not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player) or completedEvents.LightPuzzle then return end
				if cbutton then dolightup(cbutton, false) end
				cbutton = name
				dopuzzle(name)
				dolightup(name, true)
				if stage == 5 then
					wait(1)
					dolightup(cbutton, false)
					cbutton = nil
				end
			end)
			chunk.map.Buttons.Yellow.Touched:Connect(function(p)
				local name = 'Yellow'
				if cbutton == name or (not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player) or completedEvents.LightPuzzle then return end
				if cbutton then dolightup(cbutton, false) end
				cbutton = name
				dopuzzle(name)
				dolightup(name, true)
			end)

			-- Puzzle 3
			touchEvent('CompletedCatacombs', chunk.map.tolazytomakethis, true, function()
				_p.Hoverboard:unequip(true)
				spawn(function() _p.Menu:disable() end)
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				Utilities.FadeOut(.5)
				wait(.5)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				workspace.CurrentCamera.CFrame = chunk.map.PUZZLECAM.CFrame
				Utilities.FadeIn(.5)
				local CamCFrame = workspace.CurrentCamera.CFrame;

				(function(p84)
					Utilities.Tween(6, nil, function(p86)
						workspace.CurrentCamera.CFrame = CamCFrame * CFrame.new(0, math.cos(math.random() * math.pi * 5) * ((1 - p86) * p84), 0)
					end)
				end)(1)
				wait(.3);
				(function(p84)
					Utilities.Tween(1, nil, function(p86)
						workspace.CurrentCamera.CFrame = CamCFrame * CFrame.new(0, math.cos(math.random() * math.pi * 7) * ((1 - p86) * p84), 0)
					end)
				end)(0.07)

				wait(1)
				chat:say('It sounded as if doors opened somewhere far away.')
				Utilities.lookBackAtMe()
				spawn(function() _p.Menu:enable() end)
				_p.MasterControl.WalkEnabled = true
			end)


			if completedEvents.RevealCatacombs then
				local model = chunk.map.GirafarigDunsparceDoor
				pcall(function() model['#InanimateInteract']:remove() end)
				local DoorMain = model.Main
				local DoorCFrame = DoorMain.CFrame
				spawn(function()
					Utilities.Tween(1, "easeInSine", function(p87)
						Utilities.MoveModel(DoorMain, DoorCFrame + Vector3.new(0, 10 * p87, 0))
					end)
				end)
			end
			if completedEvents.SmashRockDoor then
				local model = chunk.map.RockDoor
				model:remove()
			end
			if completedEvents.CompletedCatacombs then
				local model = chunk.map.MainPuzzle.Dots
				model:remove()
			end
			if completedEvents.LightPuzzle then
				spawn(function()
					dolightup('Blue', true)
					dolightup('Red', true)
					dolightup('Yellow', true)
					dolightup('Green', true)
					local model = chunk.map.LightDoor
					local DoorMain = model.Main
					local DoorCFrame = DoorMain.CFrame
					Utilities.Tween(1, "easeInSine", function(p87)
						Utilities.MoveModel(DoorMain, DoorCFrame + Vector3.new(0, 8 * p87, 0))
					end)
				end)
			end
		end,

		onLoad_chunk61 = function(chunk)
			if completedEvents.Regirock or not completedEvents.CompletedCatacombs then
				chunk.map.Regirock:remove()
			end
		end,
		onLoad_chunk58 = function(chunk)
			if completedEvents.Registeel or not completedEvents.CompletedCatacombs then
				chunk.map.Registeel:remove()
			end
		end,
		onLoad_chunk59 = function(chunk)
			if completedEvents.Regice or not completedEvents.CompletedCatacombs then
				chunk.map.Regice:remove()
			end
		end,

		onLoad_chunk63 = function(chunk)
			if completedEvents.Regigigas then
				-- Add nil check before attempting to access/destroy
				local deadgigas = chunk.map and chunk.map:FindFirstChild("Deadgigas")
				if deadgigas then
					deadgigas:remove()
				end
				return
			end

			touchEvent('Regigigas', chunk.map.Trigger, true, function()
				_p.Hoverboard:unequip(true)
				spawn(function() _p.Menu:disable() end)
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

				-- Add nil check for CAM
				local cam = chunk.map and chunk.map:FindFirstChild("CAM")
				if not cam then return end
				workspace.CurrentCamera.CFrame = cam.CFrame

				wait(5)
				Utilities.FadeOut(.5, Color3.fromRGB(255,255,255))

				local model
				pcall(function()
					model = _p.DataManager:request({ "Model", "Regigigas" })
				end)

				-- Add nil checks before accessing map
				if model and chunk.map then
					model.Parent = chunk.map
					local deadgigas = chunk.map:FindFirstChild("Deadgigas")
					if deadgigas then
						deadgigas:remove()
					end
				end

				Utilities.FadeIn(1)
				wait(.5)
				delay(1.5, function()
					chat:manualAdvance()
				end)
				chat.bottom = true
				spawn(function()
					_p.Battle._SpriteClass:playCry(1, _p.DataManager:getSprite("_FRONT", "Regigigas").cry)
				end)
				chat:say('[ma]Zut zutt!')
				chat.bottom = false
				wait(.5)
				Utilities.FadeOut(.5)

				-- Add nil check before removing model
				if model then
					model:remove()
				end

				Utilities.FadeIn(.5)
				Utilities.lookBackAtMe()
				chat:say('Regigigas can now be found roaming in the wild.')
				spawn(function() _p.Menu:enable() end)
				_p.MasterControl.WalkEnabled = true
			end)
		end,

		onLoad_chunk47 = function(chunk)
			local keeper = chunk.npcs.RecordKeeper
			interact[keeper.model] = function()
				keeper:Say("Hoverboarding down this slope is so much fun!", 
					"I love keeping track of the fastest times people complete it in!")
				local sr = _p.PlayerData.slopeRecord
				if sr then
					keeper:Say("Your personal best is " .. string.format("%d:%02d.%02d", math.floor(sr / 60), math.floor(sr % 60), math.floor(sr % 1 * 100)) .. "!")
				end
			end
		end,
		onBeforeEnter_SkittyLodge = function(room)
			local kevin = room.npcs.kevin
			interact[kevin.model] = function()
				if not completedEvents.kevSBell then
					spawn(function()
						_p.PlayerData:completeEvent("kevSBell")
					end)
					kevin:Say("Hi, my name is Kevin.", "I run this lodge with my seven Skitties.", "Since you took the trouble of stopping by to visit, I'd like you to have this Soothe Bell.")
					chat.bottom = true
					onObtainItemSound()
					chat:say("Obtained a Soothe Bell!", _p.PlayerData.trainerName .. " put the Soothe Bell in the Bag.")
					chat.bottom = nil
				end
				kevin:Say("When given to a pokemon, the Sooth Bell will cause its happiness to increase more rapidly.")
			end
		end,

		onBeforeEnter_PondEntrance = function(room)
			--spawn(function()
			--while wait() do
			--if _p.PlayerData.hasPondPass then
			--room.model.Blocker:Destroy()
			--break
			--end
			--end
			--end)
			local bob = room.npcs.Bob
			interact[bob.model] = function()
				--if _p.PlayerData.hasPondPass then
				bob:Say('Good luck fishing, my friend.',
					'There are many rare Magikarp waiting to be found.',
					'There are some that even I haven\'t discovered!'
				)
				--[[else
					bob:Say("Hello there, explorer!",
						"I see you've found your way into my humble abode.",
						"My family has owned this property for over a century.",
						"Why, you ask?",
						"Well I'll share some interesting information with you.",
						"Behind this house is a secret grotto with a pond.",
						"The pond is home to some special Magikarp.",
						"This pond has mythical properties that has allowed the Magikarp to take on new patterns and textures to their skin.",
						"The Magikarp in the pond have many, many different variations, some rarer than others.",
						"I allow trainers to go to my secret pond and fish for these rare Magikarp if they have a Pond Pass.",
						"The Pond Pass, which will give you unlimited access to my rare Magikarp pond, will only require you to join the community group linked to our game.")
				end
				--]]
			end
		end,

		onLoad_chunk50 = function(chunk)
			local doorDebounce = false

			local useDoor = function(door1, door2)
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				_p.NPCChat:disable()
				spawn(function() _p.Menu:disable() end)

				-- START OF DOOR1
				local walkTo1 = door1.model.WalkTo1.Position
				local walkTo2 = door1.model.WalkTo2.Position
				local cam = workspace.CurrentCamera
				local camF0 = cam.Focus.p
				local camC0 = cam.CoordinateFrame.p
				--	local oCamOffset = camC0 - camF0
				local camF1 = door1.Position
				local camC1 = door1.Position + (door1.CFrame * CFrame.Angles(math.rad(35), 0, 0)).lookVector*(20)
				cam.CameraType = Enum.CameraType.Scriptable
				Utilities.Tween(.3, 'easeOutCubic', function(a)
					cam.CoordinateFrame = CFrame.new(camC0:Lerp(camC1, a), camF0:Lerp(camF1, a))
				end)
				_p.Hoverboard:unequip(true)

				door1:open(.5)
				_p.MasterControl:WalkTo(walkTo2)
				spawn(function() _p.MasterControl:LookAt(walkTo1) end)
				door1:close(.5)
				Utilities.FadeOut(1)

				-- START OF DOOR2
				local walkFrom = door2.model.WalkTo2.Position
				local walkTo   = door2.model.WalkTo1.Position
				local flat = Vector3.new(1,0,1)
				local torso = _p.player.Character.HumanoidRootPart
				local prox
				cam.CoordinateFrame = CFrame.new(door2.Position + (door2.CFrame * CFrame.Angles(math.rad(35), 0, 0)).lookVector*(20),  door2.Position)
				Utilities.Teleport(CFrame.new(walkFrom))
				Utilities.FadeIn(1)
				door2:open(.5)
				wait()
				_p.MasterControl:WalkTo(walkTo)
				_p.MasterControl:Stop()
				door2:close(.5)
				Utilities.lookBackAtMe()
				doorDebounce = false

				_p.MasterControl.WalkEnabled = true
				_p.NPCChat:enable()
				spawn(function() _p.Menu:enable() end)
			end
			local door = _p.Door:new(chunk.map.FakeDoor)
			local door2 = _p.Door:new(chunk.map.FakeDoor2)
			door.model.Main.Touched:connect(function(p)
				if doorDebounce or not p or not p:IsDescendantOf(_p.player.Character) or not p.Parent or p.Parent:IsA('Accoutrement') or _p.Battle.currentBattle then return end
				doorDebounce = true
				useDoor(door, door2)
			end)
			door2.model.Main.Touched:connect(function(p)
				if doorDebounce or not p or not p:IsDescendantOf(_p.player.Character) or not p.Parent or p.Parent:IsA('Accoutrement') or _p.Battle.currentBattle then return end
				doorDebounce = true
				useDoor(door2, door)
			end)

			local boss = chunk.npcs.Deven
			interact[boss.model] = function()
				if completedEvents.DefeatTinbell then
					boss:Say('Tyrogue is a very peculiar breed of Pokemon that has the ability to evolve into one of several different other Pokemon.',
						'Thank you again for that wonderful battle.',
						'Be sure and check the Tower out when it\'s complete. You\'ll love it.'
					)
					return
				end
				boss:Say('Oh, what do we have here?',
					'A young trainer has made it all the way up the tower to see me?',
					'Well, I\'m impressed.',
					'It\'s not every day that we get young visitors here at Tinbell Tower.',
					'I\'m Deven, the boss on site.',
					'I oversee the construction of the tower.',
					'I\'ve been in the construction business for ages.',
					'I first started construction back in the Cragonos mines, and now I\'m here.',
					'This tower is going to be a large hotel for those visiting Roria from far away.',
					'Its name, however, was created to honor the iconic towers from the Johto region.',
					'Located right next to a popular port and tour destination, the tower is sure to get many people to stay in it.',
					'Now, since you are a trainer, I\'d like to reward you with a special prize.',
					'I cannot simply give it to you, though.',
					'I want you to battle me for it.',
					'Only if you beat me in battle will I give you this special prize.',
					'What do you say? A trainer like yourself surely wouldn\'t refuse this opportunity.'
				)
				local win = _p.Battle:doTrainerBattle {
					musicId = 121757660131215,
					PreventMoveAfter = true,
					trainerModel = boss.model,
					num = 217
				}
				if win then
					boss:Say('We could use someone with your strength on my construction team.',
						'Maybe someday when you\'re older you can look us up?',
						'Anyways, I\'m sure a young trainer like yourself has lots of other things on their mind right now.',
						'Before I mentioned a special prize.',
						'I\'d like you to take with you a very special Pokemon.',
						'Its name is Tyrogue.',
						'I came this across this Pokemon on one of my trips once and have been looking for someone to take care of it.',
						'I\'m sure Tyrogue would love to acompany you on your adventures.',
						'You take him? Well that\'s just wonderful!',
						'Here you go now, Tyrogue is all yours.'
					)
					chat.bottom = true
					chat:say(_p.PlayerData.trainerName..' received Tyrogue!')
					chat.bottom = false
					boss:Say('Tyrogue is a very peculiar breed of Pokemon that has the ability to evolve into one of several different other Pokemon.',
						'I\'ll be interested to see what becomes of your Tyrogue as you level him up.',
						'Thank you again for that wonderful battle.',
						'Be sure and check the Tower out when it\'s complete. You\'ll love it.'
					)
				end
				_p.MasterControl.WalkEnabled = true
				chat:enable()
				_p.Menu:enable()
			end
		end,

		onLoad_chunk51 = function(chunk)
			local luther = chunk.npcs.Luther

			-- Check if the player has defeated Luther and enable the door accordingly
			if completedEvents.DefeatLuther then
				-- Enable the door to chunk51
				local door = chunk:getDoor('C_chunk89')
				luther.model:remove()
				if door then
					door.disabled = false
				end
			else
				-- Disable the door until Luther is defeated
				local door = chunk:getDoor('C_chunk89')
				if door then
					door.disabled = true
				end
			end

			-- Get the Luther NPC
			if luther and luther.model then
				-- Override the interact function to check for 8 badges
				interact[luther.model] = function()
					-- Check if player has 8 badges
					if not _p.PlayerData.badges[8] then
						luther:Say('Behind this gate is the entrance to Victory Road.',
							'Only trainers who\'ve collected all eight Badges may pass!',
							'Your total number of Badges is... One, two, three, four...',
							'Oops! Looks like you don\'t have enough Badges.',
							'Come back when you have all eight Badges!')
						return
					end

					-- If player has 8 badges, proceed with the battle
					_p.Menu:disable()
					_p.MasterControl.WalkEnabled = false
					luther:Say('Behind this gate is the entrance to Victory Road.',
						'Only trainers who\'ve collected all eight Badges may pass!',
						'Your total number of Badges is... One, two, three, four...',
						'Wow! You have all eight. Well then, allow me to test your abilities.')

					local win = _p.Battle:doTrainerBattle {
						battleScene = 'Safari',
						musicId = 121757660131215,
						musicVolume = 0.7,
						PreventMoveAfter = true,
						LeaveCameraScriptable = true,
						trainerModel = luther.model,
						num = 233
					}

					if not win then
						_p.MasterControl.WalkEnabled = true
						--_p.MasterControl:Start()
						--_p.NPCChat:enable()
						_p.Menu:enable()
						return
					end

					luther:Say('That was an amazing battle!',
						'You really have lived up to my expectations',
						'Now you will see if you are up to the challenge up ahead.',
						'I wish you good luck as you continue your adventure.',
						'You can continue to Victory Road!')

					-- Handle the door opening and Luther walking away
					local door = chunk:getDoor('C_chunk89')
					local pp = _p.player.Character.HumanoidRootPart.Position
					local jp = luther.model.HumanoidRootPart.Position

					local p1 = pp + Vector3.new(4, 0, 0)
					local p2 = pp + Vector3.new(-4, 0, 0)

					if (jp-p1).magnitude+(p1-door.Position).magnitude < (jp-p2).magnitude+(p2-door.Position).magnitude then
						luther:WalkTo(p1)
	
					end

					--luther:WalkTo(door.Position + Vector3.new(0, 0, 2))



					_p.PlayerData:completeEvent('DefeatLuther')
					print("Defeated Luther event complete?", _p.PlayerData.completedEvents.DefeatLuther)
					door.disabled = false

					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					_p.NPCChat:enable()
					_p.Menu:enable()
				end
			end
		end,

		onExit_Gate21 = function()
			local chunk = _p.DataManager.currentChunk
			if chunk.id ~= 'chunk52' then return end 
			if completedEvents.EnteredDecca2 then return end
			--	print('Already Finished EnteredDecca2')



			local jp = Vector3.new(-943.102, 2946.75, 1465.452)
			local gp = Vector3.new(-951.134, 2946.75, 1465.42)
			local pp = jp + (gp-jp)/2.5 + Vector3.new(0, 0, 3)	
			local tess = _p.NPC:PlaceNew('Tess', chunk.map, CFrame.new(jp, pp))
			local brad = _p.NPC:PlaceNew('Brad', chunk.map, CFrame.new(gp, pp))
			print('EnterDecca2 CompleteEvent')						
			spawn(function()
				local cam = workspace.CurrentCamera
				local camP = gp + (jp-gp)/2.5 + Vector3.new(0, 1, 4).unit*10
				local camF = jp + (gp-jp)/2
				local lerp = select(2, Utilities.lerpCFrame(cam.CoordinateFrame, CFrame.new(camP, camF)))
				Tween(1.5, 'easeOutCubic', function(a)
					cam.CoordinateFrame = lerp(a)
					cam:SetRoll(0)
				end)
			end)

			spawn(function() brad:LookAt(pp) end)
			spawn(function() tess:LookAt(pp) end)
			_p.MasterControl:WalkTo(pp)
			tess:LookAt(pp)
			tess:Say('Oh good, you made it, '.._p.PlayerData.trainerName..'.')
			spawn(function() tess:LookAt(gp) end)
			spawn(function() _p.MasterControl:LookAt(gp) end)
			brad:Say('Oh, so this is '.._p.PlayerData.trainerName..'.',
				'Your friend here was just telling me about your situation.',
				'It\'s quite unfortunate what has happened to you, but it sounds like you come a long way since.')
			spawn(function() _p.MasterControl:LookAt(jp) end)
			tess:Say('Oh right, '.._p.PlayerData.trainerName..', this is Brad.',
				'Brad was just telling me that he had just come from Crescent Island.',
				'Apparently it\'s not a very friendly place.')
			spawn(function() _p.MasterControl:LookAt(gp) end)
			brad:Say('That\'s right, the whole island is full of criminals and pirates.')
			tess:Say('What a convenient location for a group of mad men to place their base of operation.')
			brad:Say('It\'s quite an interesting place, and it wouldn\'t surprise me if their headquarters was on the island.',
				'I wasn\'t there to associate with the community, though.',
				'I was there to earn my final gym badge so that I could challenge the Roria League.',
				'You need eight gym badges to compete, and it so happens that the last badge I needed is found on that island.')
			spawn(function() brad:LookAt(jp) end)
			spawn(function() _p.MasterControl:LookAt(jp) end)
			tess:Say('Oh, that\'s interesting to know!',
				''.._p.PlayerData.trainerName..' has been collecting Roria\'s badges and only needs one more of the eight.')
			spawn(function()brad:LookAt(pp) end)		
			brad:Say('Is that so?',
				'Well, if you do earn the badge on the island, maybe we\'ll get a chance to compete at the league.',
				'I won\'t give away any details on the gym there, but it wasn\'t an easy battle.')
			spawn(function()brad:LookAt(jp) end)
			tess:Say('That shouldn\'t be a problem.',
				''.._p.PlayerData.trainerName..' is one of the toughest trainers in Roria.')
			spawn(function()brad:LookAt(pp) end)
			spawn(function() _p.MasterControl:LookAt(gp) end)
			brad:Say('Oh really?',
				'Well then, one day we ought to have a chance to battle.',
				'Oh, speaking of Crescent Island though...',
				'Not even the burliest of the sailors around here will take you there on their boat.',
				'Instead you\'ll need to travel across the waters on Route 17.',
				'You\'ll need this. Please take it, I insist!')
			_p.PlayerData:completeEvent('GetSurf')
			print("gotSurfHM")
			onObtainItemSound()
			chat.bottom = true
			chat:say('Obtained an HM03!', _p.PlayerData.trainerName .. ' put the HM03 in the Bag.')				
			chat.bottom = nil
			brad:Say('It\'s a Hidden Machine that contains the move Surf.',
				'Surf will enable you to ride your Pok[e\']mon across the water.',
				'You\'ll need it to reach Crescent Island.')
			spawn(function()brad:LookAt(jp) end)
			tess:Say('Thank you, that\'s very kind of you!')
			brad:Say('Yeah, don\'t mention it.')
			spawn(function() _p.MasterControl:LookAt(jp) end)
			tess:Say('By the way, what\'s up with the unicorn mask?')
			spawn(function() _p.MasterControl:LookAt(gp) end)
			brad:Say('UNIC--...',
				'...',
				'It\'s a narwhal mask, and it\'s for my son\'s birthday party.')
			tess:Say('Ah, for your son... sure it is.')
			brad:Say('Anyways, I need to get going.')
			spawn(function()brad:LookAt(pp) end)
			brad:Say('Good luck buddy, I hope you find your dad!')
			tess:Say('Thanks, Mr. Narwhal!')
			local door = chunk:getDoor('Gate21')
			wait()
			local p1 = pp + Vector3.new(4, 0, 0)
			local p2 = pp + Vector3.new(-4, 0, 0)
			brad:WalkTo(door.Position + Vector3.new(0, 0, -2))
			brad:remove()
			spawn(function() _p.MasterControl:LookAt(jp) end)
			spawn(function()tess:LookAt(pp) end)
			tess:Say('What a nice guy.',
				'Anyways, now is our chance to get ready to head out for Crescent Island.',
				'Once we get there we\'ll need to find Team Eclipse\'s secret base, so we\'ll probably want to be ready to fight.',
				'I\'m going to run into the Pok[e\']mon Center and prepare for the journey ahead.',
				'When you\'re ready, meet me at Decca Beach!',
				'I\'ll see you there, '.._p.PlayerData.trainerName..'!')
			local door = chunk:getDoor('PokeCenter')
			wait()
			local p1 = pp + Vector3.new(4, 0, 0)
			local p2 = pp + Vector3.new(-4, 0, 0)
			door:open(.8)
			tess:WalkTo(door.Position + Vector3.new(0, 0, 3))	
			door:close(.3)
			tess:WalkTo(door.Position + Vector3.new(0, 0, 4))
			tess:remove()
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
			chat:enable()
			_p.Menu:enable()
			spawn(function() _p.PlayerData:completeEvent('EnteredDecca2') end)

			return true		


		end,

		onBeforeEnter_Aifes = function(room)



			local Lass = room.npcs.Lass

			interact[Lass.model] = function()			


				local  cE = completedEvents 

				if cE.Meowth or cE.Glameow or cE.Purrloint then

					Lass:Say ("I hope you enjoy the cat.")

					return end			

				if not Lass:Say('Hey we provide free cat adoption!', '[y/n]Would you like to adopt one?') then
					Lass:Say('Oh, okay.', 'Well I\'ll be here if you change your mind later.')
					return	end	


				local cat = chat:choose ("Meowth","Glameow","Purrloin")				
				if cat == 1 then 
					Lass:Say ("One second.")
					Utilities.FadeOut (1)
					chat:say ("OW MEOWTH STOP IT!")

					Utilities.FadeIn (1)
					Lass:Say ("I hope you enjoy Meowth")
					spawn(function() _p.PlayerData:completeEvent('Meowth') end)

				elseif cat == 2 then 
					Lass:Say ("One second.")
					Utilities.FadeOut (1)
					chat:say ("OW Glameow STOP IT!")

					Utilities.FadeIn (1)
					Lass:Say ("I hope you enjoy Glameow")
					spawn(function() _p.PlayerData:completeEvent('Glameow') end)

				else					
					Lass:Say ("One second.")
					Utilities.FadeOut (1)
					chat:say ("OW Purrloin STOP IT!")

					Utilities.FadeIn (1)
					Lass:Say ("I hope you enjoy Purrloin")
					spawn(function() _p.PlayerData:completeEvent('Purrloin') end)
				end						
			end
		end,	

		onBeforeEnter_HerosHoverboardsDecca = function(room)
			local salesperson = room.npcs.Hero

			local debounce = true
			local csig = Utilities.Signal()
			local function onClickHoverboard(model)
				local shopGuy = _p.DataManager.currentChunk:topRoom().npcs.Hero
				if model.Name:sub(1, 6) == 'Basic ' then
					if shopGuy:Say('[y/n]Ah, the '..model.Name..' Board... Would you like to take this one with you?') then
						spawn(function() _p.Network:get('PDS', 'setHoverboard', model.Name) end)
						pcall(function() csig:fire() end)
					else
						debounce = false
					end
				else
					if _p.Network:get('PDS', 'ownsHoverboard', model.Name) then
						if shopGuy:Say('Ah, '..model.Name..'... You\'ve already purchased this one.',
							'[y/n]Would you like to take it with you?') then
							spawn(function() _p.Network:get('PDS', 'setHoverboard', model.Name) end)
							pcall(function() csig:fire() end)
						else
							debounce = false
						end
					else
						if shopGuy:Say('[y/n]Ah, '..model.Name..'... Would you like to purchase this one for 5 R$?')
							and shopGuy:Say('[y/n]You must save if your purchase goes through. Is it okay to save the game?') then
							spawn(function() shopGuy:Say('[ma]Please wait a moment while I process your purchase...') end)
							local loadTag = {}
							_p.DataManager:setLoading(loadTag, true)
							local r = _p.Network:get('PDS', 'purchaseHoverboard', model.Name, _p.PlayerData:getEtc())
							_p.DataManager:setLoading(loadTag, false)
							_p.NPCChat:manualAdvance()
							if r == 'ao' then
								shopGuy:Say('Wait, I was mistaken. You have purchased this hoverboard already.')
								debounce = false
							elseif r == 'to' then
								shopGuy:Say('That\'s odd, it looks like the purchase timed out.', 'Not to worry, though.',
									'If it happens to process later, you\'ll definitely get your hoverboard.',
									'Make sure you save, though!')
								debounce = false
							else
								pcall(function() csig:fire('Awesome, thanks for your business!') end)
							end
						else
							debounce = false
						end
					end
				end
			end

			local mcn
			local function connectMouse(model)
				local mouse = _p.player:GetMouse()
				mcn = mouse.Button1Down:connect(function()
					if debounce then return end
					local ur = mouse.UnitRay
					local p = Utilities.findPartOnRayWithIgnoreFunction(Ray.new(ur.Origin, ur.Direction*50), {}, function(p) return p.Transparency > .9 and not(pcall(function()assert(p.Parent.Parent==model or p.Parent.Parent.Parent==model)end)) end)
					if p then
						local board = select(2, pcall(function()
							return (p.Parent.Parent==model and p.Parent)
								or (p.Parent.Parent.Parent==model and p.Parent.Parent)
								or nil
						end))
						if board and type(board) ~= 'string' then
							debounce = true
							onClickHoverboard(board)
						end
					end
				end)
			end

			interact[salesperson.model] = function()
				spawn(function() _p.Menu:disable() end)
				salesperson:Say('Welcome to Hero\'s Hoverboards!',-- 'You guessed it, I\'m your hero!',
					--'Unfortunately, at the moment our inventory is not ready and we don\'t have a proper business license.',
					--'Come back after we officially open and we\'ll get you all set up!'}
					'What can I do for ya?')
				local choice = chat:choose('Free Boards', 'Paid Boards', 'Cancel')
				if choice == 1 then
					spawn(function() salesperson:Look(Vector3.new(1, 0, 4).unit) end)
					local chunk = _p.DataManager.currentChunk
					chunk.roomCamDisabled = true
					Utilities.lookAt(CFrame.new(-24.5, 11.1, 21.7, -.962, -.081, .263, 0, .956, .294, -.275, .283, -.919)+room.basePosition)
					salesperson:Say('This is our Basic Collection. You may take one out at a time for free!',
						'Click on whichever one you\'d like!')

					local closeButton = _p.RoundedFrame:new {
						Button = true, CornerRadius = Utilities.gui.AbsoluteSize.Y*.018,
						BackgroundColor3 = Color3.fromRGB(217, 99, 103),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(.2, 0, .08, 0),
						Position = UDim2.new(.6, 0, .04, 0),
						Parent = Utilities.gui,
						MouseButton1Click = function()
							if debounce then return end
							debounce = true
							csig:fire()
						end,
					}
					Utilities.Write 'Done' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.5, 0),
							Position = UDim2.new(0.5, 0, 0.25, 0),
							ZIndex = 2, Parent = closeButton.gui
						}, Scaled = true
					}

					debounce = false
					connectMouse(room.model.BasicBoards)
					csig:wait()
					pcall(function() mcn:disconnect() end)
					closeButton:remove()

					spawn(function() salesperson:LookAt(_p.player.Character.HumanoidRootPart.Position) end)
					Utilities.lookAt(chunk.getIndoorCamCFrame())
					chunk.roomCamDisabled = false
				elseif choice == 2 then
					spawn(function() salesperson:Look(Vector3.new(1, 0, 0)) end)
					local chunk = _p.DataManager.currentChunk
					chunk.roomCamDisabled = true
					Utilities.lookAt(CFrame.new(19.6, 10, 5.9, -.994, .018, -.111, 0, .988, .157, .112, .156, -.981)+room.basePosition)
					salesperson:Say('This is our Deluxe Collection. Once you purchase a board for 5 R$ you can take it out any time!',
						'Click on whichever one you\'d like!')

					local closeButton = _p.RoundedFrame:new {
						Button = true, CornerRadius = Utilities.gui.AbsoluteSize.Y*.018,
						BackgroundColor3 = Color3.fromRGB(217, 99, 103),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(.2, 0, .08, 0),
						Position = UDim2.new(.6, 0, .04, 0),
						Parent = Utilities.gui,
						MouseButton1Click = function()
							if debounce then return end
							debounce = true
							csig:fire()
						end,
					}
					Utilities.Write 'Done' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.5, 0),
							Position = UDim2.new(0.5, 0, 0.25, 0),
							ZIndex = 2, Parent = closeButton.gui
						}, Scaled = true
					}

					debounce = false
					connectMouse(room.model.PaidBoards)
					local msg = csig:wait()
					pcall(function() mcn:disconnect() end)
					closeButton:remove()

					spawn(function() salesperson:LookAt(_p.player.Character.HumanoidRootPart.Position) end)
					Utilities.lookAt(chunk.getIndoorCamCFrame())
					if msg then salesperson:Say(msg) end
					chunk.roomCamDisabled = false
				end
				salesperson:Say('Thanks for stopping by! Peace!')
				spawn(function() _p.Menu:enable() end)
			end
		end,		

		onLoad_chunk62 = function(chunk)
			if completedEvents.Volcanion then
				chunk.map.Volcanion:remove()
			end
		end,

		onLoad_chunk52 = function(chunk)
			game.Lighting.Bloom.Enabled = true
			if not completedEvents.vDecca then
				spawn(function()
					_p.PlayerData:completeEvent("vDecca")
				end)
			end
			local capn = chunk.npcs.Capn
			interact[capn.model] = function()
				--if completedEvents.meetSSam then
				if not completedEvents.meetSSam then
					spawn(function()
						_p.PlayerData:completeEvent("meetSSam");
					end);
					capn:Say("Ahoy, who be this young bucko standing here before me?", 
						"Yer name's " .. _p.PlayerData.trainerName .. ", eh?", 
						"Well my name be Salty Sam.", 
						"My friends call me Sammy.", 
						"I be the captain of this beauty, the Double Decca.", 
						"I run folks to their destinations if they bring me but a ticket from ye olde travel agency over yonder.", 
						"Upon procuring yerself a ticket, return hither and we shall set sail.")
					return
				end
				do
					local dests
					spawn(function()
						dests = _p.Network:get("PDS", "getDeccaDests")
					end)
					capn:Say("Have ye got yerself a ticket?")
					while not dests do
						wait()
					end
					if #dests == 0 then
						capn:Say("Go talk to ye olde clerk at yonder travel agency 'n' get yerself one.")
					else
						capn:Say("Aye. Whither shall we sail, eh?")
						local options = Utilities.map(dests, function(d)
							return d.name
						end)
						table.insert(options, "Cancel")
						local choice = chat:choose(unpack(options))
						if choice == #options then
							capn:Say("Blimey! Another time, then?")
						else
							capn:Say("All aboard!")
							local dest = dests[choice]
							Utilities.FadeOut(0.5)
							Utilities.TeleportToSpawnBox()
							local chunk = _p.DataManager.currentChunk
							chunk:remove()
							wait()
							chunk = _p.DataManager:loadMap(dest.chunk)
							Utilities.Teleport(CFrame.new(dest.pos))
							Utilities.FadeIn(0.5)

						end
					end
				end
			end
		end,

		onBeforeEnter_CookesKitchen = function(room)
			local VolGirl = room.npcs.VolGirl

			interact[VolGirl.model] = function()
				if completedEvents.VolItem3 then
					VolGirl:Say('I wish you luck on all of your own endeavors!') 
					return
				end

				if not completedEvents.VolItem1 then
					VolGirl:Say('Welcome to Cooke\'s Kitchen!',
						'Today we\'ll be cooking up an Epineshroom!',
						'...',
						'Sorry about that, I want to have my own cooking show someday, and I\'m trying to get some practice.',
						'I really do want to make Epineshroom, but I don\'t have the ingredients.',
						'If you bring me one Big Mushroom, we can get started.')

					if VolGirl:Say('[y/n]Do you happen to have a Big Mushroom that I can use?') then
						local hasitems = _p.Network:get('PDS', 'hasvolitems', 'bigmushroom')
						if hasitems.bigmushroom then
							VolGirl:Say('Perfect! Let\'s get started!')
							VolGirl:LookAt(room.model.Pan.Position)
						else
							VolGirl:Say('Aww, it does not seem that you have one.',
								'Come back later if you end up finding one!'
							)
						end
					else
						VolGirl:Say('Oh, well that\'s too bad.')
					end
					return
				end

				if not completedEvents.VolItem2 then
					VolGirl:Say('Alright, next what we\'re going to do is chop up a Chilan Berry.',
						'...',
						'I don\'t have a Chilan Berry.')

					if VolGirl:Say('[y/n]Do you have a Chilan Berry that I can chop up?') then
						local hasitems = _p.Network:get('PDS', 'hasvolitems', 'chilanberry')
						if hasitems.chilanberry then
							VolGirl:Say('Thank you so much!')
							VolGirl:LookAt(room.model.Pan.Position)
						else
							VolGirl:Say('Aww, it does not seem that you have one.',
								'Come back later If you end up finding one!'
							)
						end
					else
						VolGirl:Say('Oh, well that\'s too bad.')
					end
					return
				end

				if not completedEvents.VolItem3 then
					VolGirl:Say('Finally, we just need to top it off with a little Stardust.',
						'...',
						'I don\'t even know where to find Stardust...')

					if VolGirl:Say('[y/n]I bet that you\'ve got one that I can have, though?') then
						local hasitems = _p.Network:get('PDS', 'hasvolitems', 'stardust')
						if hasitems.stardust then
							VolGirl:Say('Awesome! Let\'s do this!')
							VolGirl:LookAt(room.model.Pan.Position)
							wait(2)
							VolGirl:LookAt(_p.player.Character.HumanoidRootPart.Position)
							VolGirl:Say('Thank you for all your help!',
								'I want you to have this.')
							chat.bottom = true
							onObtainItemSound()
							chat:say('Obtained an Epineshroom!', _p.PlayerData.trainerName..' put the Epineshroom in the Bag.')
							chat.bottom = nil
							VolGirl:Say('I wish you luck on all of your own endeavors!') 
						else
							VolGirl:Say('Aww, it does not seem that you have one.',
								'Come back later If you end up finding one!'
							)
						end
					else
						VolGirl:Say('Oh, well that\'s too bad.')
					end
					return
				end
			end
		end,

		onBeforeEnter_ShipHouse = function(room)
			local SecurityDude = room.npcs.Guy
			interact[SecurityDude.model] = function()
				SecurityDude:Say("Upstairs is off-limits.", "We're not hiding anything, now get lost.")
			end
			if completedEvents.PushBarrels then
				room.model.PushBarrels:remove()
				room.model.NoPass.CanCollide = false
				spawn(function()
					SecurityDude:Teleport(room.model.GuyWalkTo.CFrame)
					SecurityDude:LookAt(room.model.Boat.LookAt.CFrame)
				end)
				SecurityDude.model.Interact.Parent = nil
				interact[SecurityDude.model] = function()
					SecurityDude:Say("Look at what you've done!", "How am I supposed to clean this?")
					SecurityDude:LookAt(room.model.Boat.LookAt.CFrame)
				end
				for i, v in pairs(room.model:GetChildren()) do
					if v:IsA("BasePart") and v.Name == "OilSpill" then
						v.Transparency = 0
					end
				end
			end
			if completedEvents.UnlockMewLab then
				local HookMain = room.model.Hook.Main
				local HookCFrame = HookMain.CFrame
				local CraneMain = room.model.Crane.Main
				local CraneCFrame = CraneMain.CFrame
				local TruckMain = room.model.Truck.Main
				room.model.CraneButton["#InanimateInteract"]:remove()
				local HookMainCFrame = HookMain.CFrame
				local TruckMainCFrame = TruckMain.CFrame
				spawn(function()
					Utilities.Tween(0, nil, function(f)
						Utilities.MoveModel(HookMain, HookMainCFrame * CFrame.new(0, 0, 27 * f))
					end)
					HookMainCFrame = HookMain.CFrame
					Utilities.Tween(0, nil, function(c)
						Utilities.MoveModel(HookMain, HookMainCFrame * CFrame.new(0, -10.5 * c, 13.5 * c))
					end)
					HookMainCFrame = HookMain.CFrame
					Utilities.Tween(0, nil, function(b)
						Utilities.MoveModel(HookMain, HookMainCFrame * CFrame.new(0, 0, 13.5 * b))
					end)
					HookMainCFrame = HookMain.CFrame
					spawn(function()
						Utilities.Tween(0, nil, function(n)
							Utilities.MoveModel(TruckMain, TruckMainCFrame * CFrame.new(0, 2.625 * n, 0) * CFrame.Angles(0, 0, math.rad(20 * n)))
						end)
						TruckMainCFrame = TruckMain.CFrame
						Utilities.Tween(0, nil, function(g)
							Utilities.MoveModel(TruckMain, TruckMainCFrame * CFrame.new(2.625 * g, 7.875 * g, 0))
						end)
					end)
					Utilities.Tween(0, nil, function(r)
						Utilities.MoveModel(HookMain, HookMainCFrame * CFrame.new(0, 10.5 * r, 0))
					end)
				end)
				local CraneCFrame2 = CraneMain.CFrame
				Utilities.Tween(0, nil, function(s)
					Utilities.MoveModel(CraneMain, CraneCFrame2 * CFrame.new(-54 * s, 0, 0))
				end)
			end
		end,

		onUnload_chunk52 = function(chunk)
			game.Lighting.Bloom.Enabled = false
		end,
				--[[else
					spawn(function()
						_p.PlayerData:completeEvent("meetSSam")
					end)
				end]]
		--	capn:Say("Ahoy, who be this young bucko standing here before me?", "Yer name's " .. _p.PlayerData.trainerName .. ", eh?", "Well my name be Salty Sam.", "My friends call me Sammy.", "I be the captain of this beauty, the Double Decca.", "I run folks to their destinations if they bring me but a ticket from ye olde travel agency over yonder.", "Upon procuring yerself a ticket, return hither and we shall set sail.")
		--	end



		onLoad_chunk74 = function(chunk)
			if completedEvents.Mew then
				local MewChamber = chunk.map.MewChamber
				MewChamber.Mew:remove()
				MewChamber.TubeInner:remove()
				local MewTube = MewChamber.Tube
				chunk.map.Machine["#InanimateInteract"]:remove()
				local CFrameHandler = MewTube.CFrame
				Utilities.Tween(0, "easeOutCubic", function(x)
					MewTube.CFrame = CFrameHandler * CFrame.new(10 * x, 0, 0)
				end)
				chunk.map.Machine.Main.Color = Color3.fromRGB(76, 78, 79)
			end
		end,





		onLoad_chunk70 = function(chunk) 

			local Capn = chunk.npcs.Capn
			interact[Capn.model] = function()
				if not Capn:Say('I\'m giving free rides.',
					'[y/n]Want a ride back to Port Decca?') then
					Capn:Say('Come back if you wanna go.')
					return
				end
				Capn:Say('Alright, let\'s Go!')
				Utilities.FadeOut(.5)
				local startTick = tick()
				Utilities.TeleportToSpawnBox()
				chunk:remove()
				-- change chunks
				_p.DataManager:loadMap('chunk52')

				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				Utilities.Teleport(CFrame.new(-910.87, 2931.88, 1271.4))
				local elapsed = tick()-startTick
				if elapsed < .5 then
					wait(.5-elapsed)
				end
				Utilities.FadeIn(.5)

			end
			--[[
			if completedEvents.FindZGrass then
				pcall(function() chunk.map.FindZGrass['#InanimateInteract']:remove() end)
				pcall(function() chunk.map.FindZGrass['Main']:remove() end)
			end
			if completedEvents.FindZWater then
				pcall(function() chunk.map.FindZWater['#InanimateInteract']:remove() end)
				pcall(function() chunk.map.FindZWater['Main']:remove() end)
			end
			if completedEvents.FindZFire then
				pcall(function() chunk.map.FindZFire['#InanimateInteract']:remove() end)
				pcall(function() chunk.map.FindZFire['Main']:remove() end)
			end
			local zmove = chunk.npcs.Krystal
			interact[zmove.model] = function()
				if not completedEvents.GivenZPouch then
					chat:say(zmove, 'Oh, hello young traveler.',
						'Welcome to the Lost Islands.',
						'We dont\'t get many visitors out here.',
						'My crew of explorers came here to study this island several months ago after its discovery.',
						'There are many rare breeds of Pokemon here, and even some rare variations of Pokemon that we are already familiar with.',
						'Perhaps the strangest thing we\'ve discovered on this island are some rare stones that give off powerful energy.',
						'We are not sure what the stones are for, but they seem to emit similar energy to that of the mega stones.',
						'Unfortunately, most of these stones are hard to get to, or are guarded by strong Pokemon.',
						'None of us here are trainers, so it\'s difficult for us to travel deep into the island without being attacked.',
						'I have an idea, though. You\'re a trainer, right?',
						'Would you mind helping us explore the islands and unlock the secrets of the mysterious Z-Crystals, as we\'ve come to call them?',
						'You will? Oh thank you!',
						'This will help us learn so much more than we could on our own.',
						'Here, I want you to have this pouch for your bag.'
					)
					chat.bottom = true
					spawn(function() _p.PlayerData:completeEvent('GivenZPouch') end)
					print("Obtained Z Pouch event complete?", _p.PlayerData.completedEvents.GivenZPouch)

					_p.Menu.bag:enablezmovepouch()
					chat:say('The Z-Crystal pouch has been added to the Bag!')
					chat.bottom = nil
					chat:say(zmove, 'The Z-Crystal pouch will allow you to store the mysterious crystals you find as you explore the Lost Islands.',
						'The crystals can be given to your Pokemon from the pouch as well.',
						'Let us know what you learn about these Z-Crystals.'
					)
				else
					chat:say(zmove, 'After some reasearch, we\'ve found that Z-Crystals allow Pokemon to use powerful moves.',
						'The Z-Moves drain your bracelet of its energy, so they can only be used once per battle.',
						'You must choose when to use your moves wisely.')
				end
				
			end
			--]]
		end,


		onLoad_chunk53 = function(chunk)
			local fisherman = nil
			local Motorboat = nil
			local Tess = chunk.npcs.Tess
			Motorboat = chunk.map.Boat
			fisherman = chunk.npcs.TheFisherman
			local tesswave = Tess.humanoid:LoadAnimation(create("Animation")({
				AnimationId = "rbxassetid://" .. _p.animationId.NPCWave
			}))
			if not completedEvents.MeetTessBeach then
				local CurrentCamera = workspace.CurrentCamera
				local Jake = chunk.npcs.Jake
				touchEvent("MeetTessBeach", chunk.map.MeetTessTrigger, true, function()
					_p.Hoverboard:unequip(true)
					spawn(function()
						_p.Menu:disable()
					end)
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					_p.RunningShoes:disable()
					local PRootPart = _p.player.Character.HumanoidRootPart.CFrame
					spawn(function()
						Tess:LookAt(PRootPart)
					end)
					Utilities.exclaim(Tess.model.Head)
					tesswave:Play()
					wait(1)
					_p.MasterControl:WalkTo(Vector3.new(-529.622, 51.384, 151.165))
					PRootPart = _p.player.Character.HumanoidRootPart.CFrame
					local TRootPart2 = Tess.model.HumanoidRootPart.CFrame
					spawn(function()
						_p.MasterControl:LookAt(TRootPart2)
					end)
					spawn(function()
						Tess:LookAt(PRootPart)
					end)
					Tess:Say("I've got good news, " .. _p.PlayerData.trainerName .. "!", "The older couple that run the fish market here said that we can try to catch a ride to Crescent Island with one of their fishermen.", "He rides all the way out to Crescent Island to gather fish for their market", "He's down at the beach about to take off right now, so we'll to go catch him quickly.", "Let's go.")
					local loc1 = {Vector3.new(-543.688, 43.675, 190.193), Vector3.new(-586.594, 32.576, 202.242), Vector3.new(-630.162, 27.489, 236.813)}
					local loc2 = {Vector3.new(-543.688, 43.675, 190.193), Vector3.new(-586.594, 32.576, 202.242), Vector3.new(-625.964, 27.796, 240.867)}
					spawn(function()
						wait(0.5)
						for i, v in pairs(loc2) do
							_p.MasterControl:WalkTo(v)
						end
					end)
					for i, v in pairs(loc1) do
						Tess:WalkTo(v)
					end
					wait(0.5)
					TRootPart2 = Tess.model.HumanoidRootPart.CFrame
					PRootPart = _p.player.Character.HumanoidRootPart.CFrame
					local FRootPart2 = fisherman.model.HumanoidRootPart.CFrame
					Tess:LookAt(FRootPart2)
					Tess:Say("Excuse me, sir!")
					fisherman:LookAt(TRootPart2)
					fisherman:Say("Aye, if you want some of Kade Krabby's Klassic Karefully-Krafted Kantonian Kwik-Krisped Karp, I just gave all I caught to my boss at the market.")
					Utilities.question(Tess.model.Head)
					Tess:Say("Oh no, we aren't looking for seafood.", "I was hoping to ask you for help with something else.")
					fisherman:Say("Oh, well alright, what is it?")
					Tess:Say("Well, my name is Tess, and this is my friend " .. _p.PlayerData.trainerName .. ", and we need to get to Crescent Island.", "I talked with the older couple at the market, and they told me that you make fishing trips out to Crescent Island frequently.", "So, I was wondering...")
					fisherman:Say("Stop it right there, missy. Do you know what kinda people are out on that island?", "They're some of the roughest, tougest, nastiest, scoundrels you'll ever meet...")
					wait(1)
					fisherman:LookAt(TRootPart2)
					wait(0.5)
					fisherman:LookAt(PRootPart)
					Utilities.exclaim(fisherman.model.Head)
					fisherman:Say("You kids aren't serious about wanting to go there, are you?")
					Tess:Say("Yes, we are on a mission to save our friends and family.", "We're chasing a group of goons that go by the name \"Team Eclipse.\"", "They are plotting something disastrous, and if we don't stop them, Roria could be in danger.")
					fisherman:Say("Wow that is quite a tale.", "I've heard a lot of stories in my time, and yours sounds just as fishy as a fishing story.", "Still, you both look rather determined to get there, regardless of your reasons...")
					Tess:Say("I wish we were making this up...", "We'll do whatever it takes to get to the island.")
					fisherman:Say("Is that so?", "Well, I supposed our only obstacle now is that I can really only take one extra person on my boat.")
					TRootPart2 = Tess.model.HumanoidRootPart.CFrame
					PRootPart = _p.player.Character.HumanoidRootPart.CFrame
					Tess:LookAt(PRootPart)
					spawn(function()
						_p.MasterControl:LookAt(TRootPart2)
					end)
					Tess:Say("Okay, I have a new plan.", "Remember how Brad gave you the Hidden Machine for teaching Surf?", "I will ride in the boat with this guy to the island, and you Surf your way there.", "I know you, and I know you can handle the waters from here to there.")
					Tess:Say("[small]And don't worry about me getting on a boat with a stranger. Garchomp can take this guy, easily. I mean, just look at him. His best move is probably Struggle...")
					Tess:LookAt(FRootPart2)
					Tess:Say("Alright, it's settled.", "I'll ride in the boat with you, and " .. _p.PlayerData.trainerName .. " will Surf to Crescent Island.")
					fisherman:Say("Aight, if I can't talk you out of going, I would at least recommend stocking up on items and healing your Pokemon before we depart.")
					Tess:LookAt(PRootPart)
					Tess:Say("I already just healed my team!", "Make sure you do the same.", "Come find me when you get to Crescent Island!")
					Tess:LookAt(FRootPart2)
					Tess:Say("Ok, I'm ready to go!")
					fisherman:Say("Alright, hop it and we'll be off.")
					CurrentCamera.CameraType = Enum.CameraType.Scriptable
					spawn(function()
						local camCFrame = CFrame.new(-609.415, 40.033, 249.364, 0.45704028, -0.147810057, 0.877078354, -7.45057971E-09, 0.986095071, 0.16618216, -0.889445961, -0.0759519488, 0.450685203)
						Utilities.lookAt(camCFrame)
					end)
					spawn(function()
						fisherman:LookAt(Motorboat.FishermanPos.CFrame)
					end)
					Tess:LookAt(Motorboat.TessPos.CFrame)
					local FRootPart = fisherman.model.HumanoidRootPart
					local l__CFrame__597 = FRootPart.CFrame
					spawn(function()
						Utilities.Tween(1, nil, function(p550)
							Utilities.MoveModel(FRootPart, l__CFrame__597 * CFrame.new(0, 5 * math.sin(math.pi * p550), -8 * p550))
						end)
						FRootPart.Anchored = true
						FRootPart.CFrame = Motorboat.FishermanPos.CFrame
					end)
					wait(0.2)
					local TRootPart = Tess.model.HumanoidRootPart
					local l__CFrame__598 = TRootPart.CFrame
					Utilities.Tween(1, nil, function(p551)
						Utilities.MoveModel(TRootPart, l__CFrame__598 * CFrame.new(0, 5 * math.sin(math.pi * p551), -10 * p551))
					end)
					TRootPart.Anchored = true
					TRootPart.CFrame = Motorboat.TessPos.CFrame
					local RunService = game:GetService("RunService")
					RunService:BindToRenderStep("DeccaBoat", Enum.RenderPriority.Camera.Value - 1, function()
						TRootPart.CFrame = Motorboat.TessPos.CFrame
						FRootPart.CFrame = Motorboat.FishermanPos.CFrame
					end)
					spawn(function()
						local MotorboatMain = Motorboat.Main
						local MotorboatCFrame = MotorboatMain.CFrame
						Utilities.Tween(10, "easeInSine", function(p552)
							Utilities.MoveModel(MotorboatMain, MotorboatCFrame * CFrame.Angles(0, math.rad(90 * p552), 0) * CFrame.new(700 * p552, 0, 0))
						end)
						RunService:UnbindFromRenderStep("DeccaBoat")
						Tess:remove()
						fisherman:remove()
						Motorboat:remove()
					end)
					Jake:Teleport(CFrame.new(-535.369, 52.383, 274.527))
					Jake:LookAt(PRootPart)
					local CameraCFrame = CurrentCamera.CFrame
					local u601 = CFrame.new(-529.583, 50.304, 277.653, 0.269544631, -0.182833284, 0.945472181, 3.72529074E-09, 0.981811166, 0.189860404, -0.962987959, -0.0511758476, 0.264641881)
					Utilities.Tween(8.5, "linear", function(p553)
						CurrentCamera.CFrame = CameraCFrame:Lerp(u601, p553)
					end)
					wait(3)
					Jake:WalkTo(Vector3.new(-537.579, 49.913, 297.773))
					Jake:remove()
					Utilities.lookBackAtMe()
					_p.MasterControl.WalkEnabled = true
					_p.RunningShoes:enable()
					spawn(function()
						_p.Menu:enable()
					end)
					spawn(function()
						_p.PlayerData:completeEvent("MeetTessBeach")
					end)
				end)
				return
			end
			Tess:Teleport(CFrame.new(-622.68, 8.026, 7734.233))
			fisherman:Teleport(CFrame.new(-622.68, 8.026, 7729.109))
			Motorboat:remove()
		end,


		onLoad_chunk54 = function(chunk)
			if not completedEvents.vCrescentIsland then spawn(function() _p.PlayerData:completeEvent('vCrescentIsland') end)end
			--local map = chunk.map
			local fisherman = chunk.npcs.Fisherman
			local cutgrunt = chunk.npcs.CutsceneGrunt
			local blockerguy = chunk.npcs.LHC_Grunt2

			local door = _p.DataManager.currentChunk:getDoor('Gate23')
			door.disabled = true
			interact[blockerguy.model] = function()
				blockerguy:Say("Sorry, nobody gets through here.", "The boss isn't letting anyone past until he's ready.", "If you're here to join Team Eclipse, go check in town for assistance.")
			end
			if completedEvents.DefeatEclipseBase then
				door.disabled = false
				blockerguy:remove()
			end

			if not completedEvents.MeetFisherman then
				--Utilities.Teleport(CFrame.new(-1379.652, 35.259, -466.587))
				touchEvent('MeetFisherman', chunk.map.cTrigger1, true, function()
					spawn(function() _p.Menu:disable() end)
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					fisherman:LookAt(_p.player.Character.Head.Position)
					spawn(function() _p.MasterControl:LookAt(fisherman.model.Head.Position) end)
					fisherman:Say('Oh hey, it\'s you.',
						'As soon as we made land, that friend of yours took off running after some guy wearing orange and black.',
						'They were headed toward Tanner\'s Tavern.',
						'She looked pretty angry.',
						'Anyways, I need to get back to fishin\' here soon.',
						'Good luck findin\' your way \'round this town, and be careful not to get caught up with any crooks.'
					)
					_p.MasterControl.WalkEnabled = true
					_p.MasterControl:Stop()
					interact[fisherman.model] = function()
						fisherman:Say('Good luck findin\' your way \'round this town, and be careful not to get caught up with any crooks.')
					end
					_p.Menu:enable()
				end)
			else
				fisherman:remove()
				chunk.map.Boat:remove()
			end

			if not completedEvents.EclipseBaseReveal then
				touchEvent('EclipseBaseReveal', chunk.map.cTrigger2, true, function()
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					_p.Menu:disable()
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					workspace.CurrentCamera.CFrame = CFrame.new(-1720.54, 38.133, -411.146, -0.965925753, 0, 0.258819103, 0, 1, 0, -0.258819103, 0, -0.965925753)
					cutgrunt:LookAt(_p.player.Character.Head.Position)
					Utilities.exclaim(cutgrunt.model.Head)
					local tdoor = chunk:getDoor('Tavern')
					spawn(function() cutgrunt:WalkTo(Vector3.new(-1719.875, 31.853, -368.026)) end)
					wait(.5)
					tdoor:open(.3)
					wait(1)
					tdoor:close(.3)
					cutgrunt:remove()
					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					_p.MasterControl.WalkEnabled = true
					_p.MasterControl:Stop()
					_p.Menu:enable()
				end)
			else
				cutgrunt:remove()
			end

		end,


		onBeforeEnter_Tavern = function(room)
			touchEvent(nil, room.model.Elevator.Trigger, true, function()
				local currentChunk = _p.DataManager.currentChunk
				local ElevatorM = room.model.Elevator.ElevatorMain
				local camera = workspace.CurrentCamera
				local pos = CFrame.new(-1979.59253, 944.208069, -437.762665, -0, -0.369622111, 0.929182172, -0, 0.929182172, 0.369622111, -1, 0, -0)
				spawn(function()
					_p.Menu:disable()
					_p.MasterControl.WalkEnabled = false
				end)
				wait(.5)
				_p.MasterControl:WalkTo(room.model.TeleportSpawn2.Position + Vector3.new(0, 0, 0))
				_p.MasterControl:LookAt(room.model.TeleportSpawn.Position + Vector3.new(0, 0, -5))
				currentChunk:unbindIndoorCam()
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = camera.CFrame
				spawn(function()
					local cameraCFrame = workspace.CurrentCamera.CFrame;
					(function(pos8)
						Utilities.Tween(1.2, nil, function(pos7)
							workspace.CurrentCamera.CFrame = cameraCFrame * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - pos7) * pos8), 0)
						end)
					end)(0.07)
				end)
				wait(0.5)
				local cframe = ElevatorM.CFrame
				spawn(function()
					Utilities.Tween(1.8, "easeInSine", function(pos6)
						Utilities.MoveModel(ElevatorM, cframe + Vector3.new(0, -7.5 * pos6, 0))
					end)
				end)
				wait(1)
				_p.MusicManager:popMusic("all", 1)
				Utilities.FadeOut(1)
				Utilities.TeleportToSpawnBox()
				currentChunk:remove()
				wait()
				local newChunk = _p.DataManager:loadMap('chunk57')
				newChunk.indoors = false
				_p.MasterControl:SetIndoors(false)
				camera.CFrame = pos
				local ElevatorM2 = newChunk.map.Elevator
				local main = ElevatorM2.Main.CFrame
				Tween(0.1, nil, function(pos1)
					Utilities.MoveModel(ElevatorM2.Main, main * CFrame.new(0, 10 * pos1, 0))
				end)
				Utilities.Teleport(newChunk.map.Elevator.Main.CFrame + Vector3.new(0, 1, 0))
				_p.MasterControl:LookAt(Vector3.new(-1537.939, 944.25, -439.106))
				main = ElevatorM2.Main.CFrame
				local function tween(pos2)
					Tween(1.2, nil, function(pos3)
						camera.CFrame = pos * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - pos3) * pos2), 0)
					end)
				end
				spawn(function()
					newChunk.map.ElevatorTrigger.CFrame = CFrame.new(0, 100, 0)
					Tween(2, nil, function(pos4)
						Utilities.MoveModel(ElevatorM2.Main, main + Vector3.new(0, -10 * pos4, 0))
					end)
					tween(0.2)
					wait(0.5)
					_p.MasterControl:WalkTo(newChunk.map.spawnPos.Position + Vector3.new(9, 0, 0))
					Utilities.lookBackAtMe()
					_p.MasterControl.WalkEnabled = true
					spawn(function()
						_p.Menu:enable()
					end)
					camera.CameraType = Enum.CameraType.Custom
					newChunk.map.ElevatorTrigger.CFrame = CFrame.new(-1988.218, 940.418, -438.134)
				end)
				Utilities.FadeIn(1)
			end)
		end,



		onLoad_gym8 = function(chunk)

			-- [[
			local Captain = chunk.npcs.CaptainB
			local CaptainBB = chunk.npcs.CaptainBB
			interact[Captain.model] = function()
				if _p.PlayerData.badges[8] then
					Captain:Say('I wish you the best of luck as you continue your adventure.',
						'You can battle the Roria League!')
				else
					Captain:Say('Welcome Traveler',
						'Im the gym leader in this town.',
						'You can call me Captain B.',
						'You\'ve Probably heard many people talk about how hard this badge is to get.',
						'You Better be ready.',
						'But be warned, Trainer, I won\'t let you have it easy.')
					local win = _p.Battle:doTrainerBattle {
						musicId = 105871631848322,
						PreventMoveAfter = true,
						trainerModel = CaptainBB.model,
						vs = {name = 'Captain B', id = 658350333, hue = 10000, sat = 10000},
						num = 173
					}
					if win then
						Captain:Say('Well, Congratulations',
							'You beat me!',
							'The Treasure Is yours.',
							'Here is your prize.')
						local badge = chunk.map.Badge8:Clone()
						local cfs = {}
						local main = badge.SpinCenter
						for _, p in pairs(badge:GetChildren()) do
							if p:IsA('BasePart') and p ~= main then
								p.CanCollide = false
								cfs[p] = main.CFrame:toObjectSpace(p.CFrame)
							end
						end
						badge.Parent = workspace
						local st = tick()
						local spinRate = 1
						local function cframeTo(rcf)
							local cf = workspace.CurrentCamera.CoordinateFrame * rcf * CFrame.Angles(math.pi/2, 0, (tick()-st)*spinRate + math.pi/2)
							main.CFrame = cf
							for p, ocf in pairs(cfs) do
								p.CFrame = cf:toWorldSpace(ocf)
							end
						end
						local r = 8
						local f = CFrame.new(0, 0, -6)
						Tween(1, nil, function(a)
							local t = a*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						local spin = true
						Utilities.fastSpawn(function()
							while spin do
								cframeTo(f)
								stepped:wait()
							end
						end)
						wait(2)
						onObtainBadgeSound()
						chat.bottom = true
						chat:say('Obtained the Haunted Badge!')
						chat.bottom = nil
						spin = false
						Tween(.5, nil, function(a)
							local t = (1-a)*math.pi/2
							cframeTo(CFrame.new(0, -r + math.sin(t)*r, f.z - math.cos(t)*r*0.5))
						end)
						badge:remove()

						Captain:Say('Equipped with the Haunted Badge you will be able to trade for Pok[e\']mon up to level 100.',
							'You will also be able to use the move Surf outside of battle.',
							'I would also like for you to have this TM.')
						onObtainItemSound()
						chat.bottom = true
						chat:say('Obtained a TM65!',
							_p.PlayerData.trainerName .. ' put the TM65 in the Bag.')
						chat.bottom = nil
						Captain:Say('Shadow Claw is a Dark-type special attack that can even cause your opponent to flinch if you\'re lucky.', 
							'Now That you have Beaten all Eight Gyms You can Challenge The Roria League.',
							'With that, I wish you the best of luck as you continue your adventure.',
							'Good luck as you go challenge the Roria League.',
							'Do note that the Roria League is under construction.')
						--_p.PlayerData:completeEvent('FrostveilComplete')
					end
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()
					chat:enable()
					_p.Menu:enable()
				end
			end--]]
		end,

		onLoad_chunk57 = function(chunk)
			touchEvent(nil, chunk.map.ElevatorTrigger, false, function()
				local currentCamera = workspace.CurrentCamera
				local pos1 = CFrame.new(-1978.00208, 944.83075, -437.182831, 0.00755485985, -0.275141299, 0.961374164, 2.32830616e-10, 0.961401641, 0.275149167, -0.999971449, -0.00207871315, 0.00726325437)
				local elevator = chunk.map.Elevator
				spawn(function()
					_p.Menu:disable()
					_p.MasterControl.WalkEnabled = false
				end)
				wait(.5)
				currentCamera.CameraType = Enum.CameraType.Scriptable
				spawn(function()
					Utilities.lookAt(CFrame.new(-1978.00208, 944.83075, -437.182831, 0.00755485985, -0.275141299, 0.961374164, 2.32830616e-10, 0.961401641, 0.275149167, -0.999971449, -0.00207871315, 0.00726325437))
				end)
				_p.MasterControl:WalkTo(Vector3.new(-1992.144, 939.572, -437.878))
				_p.MasterControl:LookAt(Vector3.new(-1983.208, 939.572, -436.747));
				(function(x)
					Tween(1.2, nil, function(y)
						currentCamera.CFrame = pos1 * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - y) * x), 0)
					end)
				end)(0.2)
				local newElevator = elevator
				local l__CFrame__648 = elevator.Main.CFrame
				Tween(2, "easeInSine", function(b)
					Utilities.MoveModel(newElevator.Main, l__CFrame__648 + Vector3.new(0, 10 * b, 0))
				end)
				_p.MusicManager:popMusic("all", 1)
				Utilities.FadeOut(1)
				Utilities.TeleportToSpawnBox()
				_p.DataManager.currentChunk:remove()
				wait(0.5)
				wait()
				local newChunk = _p.DataManager:loadMap("chunk54")
				newChunk.indoors = true
				_p.MasterControl:SetIndoors(true)
				local newRoom = newChunk:getRoom("Tavern", newChunk:getDoor("Tavern"), 1)
				newChunk.roomStack = { newRoom }
				local cpos = CFrame.new(1194.23425, 19.6975975, 1017.59741, -0.999953687, 0.00624616956, -0.00732445344, -4.65661287E-10, 0.760893404, 0.648876965, 0.00962612405, 0.648846924, -0.760858119)
				newChunk:bindIndoorCam()
				newElevator = newRoom.model.Elevator
				Utilities.Teleport(newRoom.model.TeleportSpawn.CFrame + Vector3.new(0, 0, 0))
				spawn(function()
					_p.MasterControl:LookAt(newRoom.model.TeleportSpawn.Position + Vector3.new(0, 0, -5))
				end)
				spawn(function()
					local CameraCFrame = workspace.CurrentCamera.CFrame;
					(function(d)
						Utilities.Tween(1.2, nil, function(j)
							local f = (1 - j) * d
							local si = math.random() * math.pi * 2
							workspace.CurrentCamera.CFrame = CameraCFrame * CFrame.new(math.cos(si) * f, 0, math.sin(si) * f)
						end)
					end)(0.07)
				end)
				wait()
				pos1 = CFrame.new(1194.06641, 17.4220715, 1012.09058, -0.999999523, -0.000600461033, 0.000854510698, -5.82076609E-11, 0.818194509, 0.574941695, -0.00104438583, 0.574941397, -0.818194032)
				spawn(function()
					local ElevatorMainCFrame = newElevator.ElevatorMain
					local ElevatorMain = ElevatorMainCFrame.CFrame
					Utilities.Tween(2, nil, function(x)
						Utilities.MoveModel(ElevatorMainCFrame, ElevatorMain + Vector3.new(0, 7.5 * x, 0))
					end)
					spawn(function()
						local cameraCFrame2 = workspace.CurrentCamera.CFrame;
						(function(x)
							Tween(1.2, nil, function(n)
								currentCamera.CFrame = cameraCFrame2 * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - n) * x), 0)
							end)
						end)(0.07)
					end)
					wait(1)
					newChunk.roomCamDisabled = false
					_p.MasterControl:WalkTo(newRoom.model.TeleportSpawn.Position + Vector3.new(0, 0, -6))
					wait(1.5)
					_p.Menu:enable()
					_p.Events.onBeforeEnter_Tavern(newRoom)
					_p.MasterControl.WalkEnabled = true
				end)
				newChunk.roomCamDisabled = true
				currentCamera.CameraType = Enum.CameraType.Scriptable
				Utilities.Tween(0.1, nil, function(v)
					currentCamera.CFrame = currentCamera.CFrame * CFrame.new(Vector3.new(0, 7.5 * v, 0))
				end)
				Utilities.FadeIn(1)
			end)
			if completedEvents.PressSecurityButton then
				local map = chunk.map
				local cframe1 = map.Door2.Left.Main.CFrame
				delay(0, function()
					Utilities.Tween(0.1, "easeOutSine", function(pos6)
						Utilities.MoveModel(map.Door2.Left.Main, cframe1 + Vector3.new(0, 0, -10 * pos6))
					end)
				end)
				local cframe2 = map.Door2.Right.Main.CFrame
				delay(0, function()
					Utilities.Tween(0.1, "easeOutSine", function(pos7)
						Utilities.MoveModel(map.Door2.Right.Main, cframe2 + Vector3.new(0, 0, 10 * pos7))
					end)
				end)
				local cframe3 = map.Door3.Left.Main.CFrame
				delay(0, function()
					Utilities.Tween(0.1, "easeOutCubic", function(pos8)
						Utilities.MoveModel(map.Door3.Left.Main, cframe3 + Vector3.new(0, 0, -10 * pos8))
					end)
				end)
				local cframe4 = map.Door3.Right.Main.CFrame
				delay(0, function()
					Utilities.Tween(0.1, "easeOutCubic", function(pos9)
						Utilities.MoveModel(map.Door3.Right.Main, cframe4 + Vector3.new(0, 0, 10 * pos9))
					end)
				end)
				local cframe5 = map.Door4.Left.Main.CFrame
				delay(0, function()
					Utilities.Tween(0.1, "easeOutCubic", function(pos10)
						Utilities.MoveModel(map.Door4.Left.Main, cframe5 + Vector3.new( -7 * pos10, 0, 0))
					end)
				end)
				local cframe6 = map.Door4.Right.Main.CFrame
				delay(0, function()
					Utilities.Tween(0.1, "easeOutCubic", function(pos11)
						Utilities.MoveModel(map.Door4.Right.Main, cframe6 + Vector3.new( 7 * pos11, 0, 0))
					end)
				end)
				local cframe7 = map.Door5.Left.Main.CFrame
				delay(0, function()
					Utilities.Tween(0.1, "easeOutCubic", function(pos12)
						Utilities.MoveModel(map.Door5.Left.Main, cframe7 + Vector3.new(7 * pos12, 0, 0))
					end)
				end)
				local cframe8 = map.Door5.Right.Main.CFrame
				delay(0, function()
					Utilities.Tween(0.1, "easeOutCubic", function(pos13)
						Utilities.MoveModel(map.Door5.Right.Main, cframe8 + Vector3.new(-7 * pos13, 0, 0))
					end)
				end)
			end
			spawn(function()
				wait(.1)
				if completedEvents.DefeatEclipseBase then
					for i,obj in pairs(chunk.map:GetChildren()) do
						if obj.Name:sub(1, 9) == 'Eclipse G' then
							obj:remove()
						end
					end
				end
			end)
		end,

		onLoad_chunk81 = function(chunk)
			spawn(function()
				wait(.1)
				if completedEvents.DefeatEclipseBase then
					for i,obj in pairs(chunk.map:GetChildren()) do
						if obj.Name:sub(1, 9) == 'Eclipse G' then
							obj:remove()
						end
					end
				end
			end)
		end,

		onLoad_chunk82 = function(chunk)
			local door = _p.DataManager.currentChunk:getDoor('C_chunk88')
			door.disabled = true

			spawn(function()
				wait(.1)
				if completedEvents.DefeatEclipseBase then
					for i,obj in pairs(chunk.map:GetChildren()) do
						if obj.Name:sub(1, 9) == 'Eclipse G' or obj.Name:sub(1, 9) == 'Scientist' then
							obj:remove()
						end
					end
				end
			end)
		end,

		onLoad_chunk83 = function(chunk)
			spawn(function()
				wait(.1)
				if completedEvents.DefeatEclipseBase then
					for i,obj in pairs(chunk.map:GetChildren()) do
						if obj.Name:sub(1, 9) == 'Eclipse G' then
							obj:remove()
						end
					end
				end
			end)
		end,

		onLoad_chunk84 = function(chunk)
			if completedEvents.PressSecurityButton then
				chunk.map.Button.Main.BrickColor = BrickColor.new("Really red")
				pcall(function() chunk.map.Button['#InanimateInteract']:remove() end)
			end
			local man = chunk.npcs['Eclipse Grunt']
			if not completedEvents.ExposeSecurity then
				touchEvent('ExposeSecurity', chunk.map.CTrigger, false, function()
					_p.MasterControl.WalkEnabled = false
					local cam = workspace.CurrentCamera
					cam.CameraType = Enum.CameraType.Scriptable
					cam.CFrame = chunk.map.cam.CFrame
					spawn(function() _p.Menu:disable() end)
					spawn(function() _p.MasterControl:WalkTo(chunk.map.WalkT.Position) end)
					Utilities.exclaim(man.model.Head)
					man:LookAt(_p.player.Character.Head.Position)
					man:Say('Hey, you aren\'t supposed to be in here!',
						'How did you get past all of our grunts to make it this far?',
						'The base is under heavy lockdown while we pack up and move everything out to the cave on Route 18.',
						'We\'ll soon be ready to awaken Hoopa and travel to a beautiful new world.',
						'Some punk kid isn\'t going to stop us.',
						'I guess it\'s up to me now to finish you off here.'
					)
					local win = _p.Battle:doTrainerBattle {
						LeaveCameraScriptable = true,
						PreventMoveAfter = true, 
						trainerModel = man.model,
						num = 229,
						battleSceneType = 'SecurityRoom',
						IconId = 5226446131,
						musicId = {9536676199, 12639990881},
						musicVolume = 1,
					}
					if win then
						man:Say('Well that\'s no good.',
							'I guess I should go join up with everyone at the ship before they take off for the island.',
							'Don\'t do anything stupid to try and stop us.',
							'Oh, and don\'t press that green button on the security desk.',
							'See ya!'
						)
						_p.MasterControl:WalkTo(chunk.map.WalkT2.Position)
						spawn(function() _p.MasterControl:LookAt(chunk.map.WalkT3.Position) end)
						man:WalkTo(chunk.map.WalkT3.Position)
						man:remove()
						Utilities.lookBackAtMe()
					end
					if not win then
						_p.RunningShoes:enable()
						_p.MasterControl.WalkEnabled = true
						chat:enable()
						_p.Menu:enable()
						return
					end
					_p.MasterControl.WalkEnabled = true
					chat:enable()
					_p.Menu:enable()
				end)
			else
				man:remove()
			end
		end, 

		onLoad_chunk85 = function(chunk)
			if completedEvents.FindCardKey then
				chunk.map['Card Key']:remove()
			end
		end,

		onLoad_chunk86 = function(chunk)
			local Mom = chunk.npcs.Mom
			local Dad = chunk.npcs.Dad
			local EC1 = chunk.npcs.EclipseAdmin1
			local EC2 = chunk.npcs.EclipseAdmin2
			local GateMain = chunk.map.LockedGate.Main
			local GateCFrame = GateMain.CFrame

			if completedEvents.OpenEclipseGate then
				spawn(function()
					pcall(function() GateMain.Parent['#InanimateInteract']:remove() end)
					Utilities.Tween(.1, "easeInSine", function(pos3)
						Utilities.MoveModel(GateMain, GateCFrame + Vector3.new(pos3 * 9, 0, 0))
					end)
				end)
			end
			if completedEvents.ParentalSightings then
				Mom:remove()
				Dad:remove()
				EC1:remove()
				EC2:remove()
				return
			end
			touchEvent('ParentalSightings', chunk.map.TRIGGER, true, function()
				local door = chunk:getDoor('C_chunk60')
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				spawn(function()
					_p.Menu:disable()
					door:open(.5)
				end)
				local cam = workspace.CurrentCamera
				cam.CameraType = Enum.CameraType.Scriptable
				cam.CFrame = CFrame.new(90.1435699, -9.72504997, 1231.59839, 1.19248806e-08, 0, -1, 0, 1, 0, 1, 0, 1.19248806e-08)
				local pos = Vector3.new(163.354, -17.7, 1240.928)
				local pos2 = Vector3.new(163.354, -17.7, 1249.188)

				Mom:WalkTo(pos2)
				Mom:remove()
				Dad:WalkTo(pos2)
				Dad:remove()
				EC1:WalkTo(pos)	
				EC1:remove()
				wait(.5)
				EC2:WalkTo(pos)
				EC2:remove()
				wait(1)
				_p.MasterControl.WalkEnabled = true
				_p.MasterControl:Stop()
				Utilities.lookBackAtMe()
				spawn(function()
					_p.Menu:enable()
					door:close(.5)
				end)
			end)
		end,

		onExitC_chunk86 = function()
			local chunk = _p.DataManager.currentChunk
			if chunk.id ~= 'chunk60' then return end
			if not completedEvents.DefeatEclipseBase then
				local prof = chunk.npcs.Professor
				local Ship = chunk.map.EclipseShip
				local Ramp = chunk.map.Ramp
				local ECAdmin = chunk.npcs.EclipseAdmin1
				local ECAdmin2 = chunk.npcs.EclipseAdmin2
				local Tyler = chunk.npcs.Tyler
				local Mom = chunk.npcs.Mom
				local Dad = chunk.npcs.Dad
				local Tess = chunk.npcs.Tess
				local map = chunk.map
				local ThisGUy = chunk.map.LookPart.Position
				local ECA = chunk.map.ECA.Position
				local PH = chunk.map.PH.Position
				local Jaake = chunk.npcs.Jake
				local BJake = chunk.map.BJake.Position
				Utilities.FadeOut(0.5) 

				spawn(function() Utilities.FadeIn(1) end)
				_p.MusicManager:popMusic('all', 1)
				_p.MusicManager:stackMusic(10840673764, 'Cutscene', .4)

				local cam = workspace.CurrentCamera
				cam.CameraType = Enum.CameraType.Scriptable
				Utilities.lookAt(Vector3.new(-191.8, 440.009, 256.8), Vector3.new(-191.943, 436.198, 264.32), 2)
				wait(0.25)
				cam.CFrame = CFrame.lookAt(Vector3.new(-180.9, 439.998, 278.6),Vector3.new(-191.243, 432.298, 273.82))
				prof:Say('Alright, we\'re all here.','Let\'s not waste any more time.','I will not wait a moment longer to reach my new kingdom!')
				wait(0.25)
				cam.CFrame = CFrame.lookAt(Vector3.new(-180.943, 439.298, 264.32),Vector3.new(-186.279, 436.418, 272.002))
				Mom:Say('Please stop this, you\'re making a huge mistake.')
				Dad:Say('It\'s true, Hoopa is far too powerful for you to control.','It nearly destroyed Roria when it was first discovered.')
				wait(0.25)
				cam.CFrame = CFrame.lookAt(Vector3.new(-180.9, 439.998, 278.6),Vector3.new(-191.243, 432.298, 273.82))
				prof:Say('I hold the bottle that grants me power over the beast.','You and your silly warnings will not stop me.')
				wait(0.5)
				Utilities.exclaim(Mom.model.Head)
				Utilities.exclaim(Dad.model.Head)
				Utilities.exclaim(Tess.model.Head)
				local playerposition = (Vector3.new(-191.943, 431.198, 265.22))
				Utilities.Teleport(CFrame.new(playerposition - Vector3.new(0, 0, 40)))
				_p.MasterControl:WalkTo(playerposition)
				_p.MasterControl:LookAt(prof.model.Head.Position)
				Utilities.Sync {
					function()
						prof:LookAt(playerposition)
					end,
					function()
						Jaake:LookAt(playerposition)	
					end,
					function()
						ECAdmin:LookAt(playerposition)	
					end,
					function()
						ECAdmin2:LookAt(playerposition)
						Tyler:LookAt(playerposition)
					end,
				}
				Mom.model.Head.Decal.Texture = 'rbxassetid://210657685'
				Dad.model.Head.Decal.Texture = 'rbxassetid://50725748'
				Tess.model.Head.Decal.Texture = 'rbxassetid://209713384'
				wait(0.25)
				cam.CFrame = CFrame.lookAt(Vector3.new(-179.143, 441.748, 260.37),Vector3.new(-186.293, 438.348, 267.67))
				Mom:Say(_p.PlayerData.trainerName .. ', is that you, Sweetie?')
				Dad:Say('Oh, thank goodness, you\'re alright!')
				Tess:Say('I knew you would find us!','Team Eclipse captured me and threw me in their prison with your parents.','I told them you would come rescue us!')
				Mom:Say('Sweetie, we\'ve missed you so much!')
				wait(0.25)
				cam.CFrame = CFrame.lookAt(Vector3.new(-180.9, 439.998, 278.6),Vector3.new(-191.243, 432.298, 273.82))
				prof:Say('Alright, that\'s enough!','This is no time for a reunion.','Your parents are coming with us into the cave.','They are going to show us the correct path into the beast\'s lair.','There will be no distractions now.')
				ECAdmin:LookAt(prof.model.Head.Position)	
				prof:LookAt(ECAdmin.model.Head.Position)
				prof:Say('Load up our prisoners.','Have the ship ready to go immediately.')
				ECAdmin:Say('Yes sir!')
				prof:LookAt(Vector3.new(-191.943, 431.048, 268.07))
				wait(0.25)
				cam.CFrame = CFrame.lookAt(Vector3.new(-179.143, 441.748, 260.37),Vector3.new(-186.293, 438.348, 267.67))
				ECAdmin:WalkTo(Vector3.new(-192.209, 431.484, 274.504))
				ECAdmin:LookAt(Vector3.new(-191.569, 444.199, 307.574))
				Dad:Say(_p.PlayerData.trainerName.. ', do not worry about us!','Just keep "it" safe!')
				Mom:Say('We\'ll be okay, '.._p.PlayerData.trainerName..'.','Do not forget what we told you.')
				Tess:Say(_p.PlayerData.trainerName..', you can\'t let them win!')
				prof:Say('Enough, let\'s go!')
				Utilities.FadeOut(0.5)
				wait(0.5)
				Dad:remove()
				Mom:remove()
				ECAdmin:remove()
				Tess:remove()
				ECAdmin2:remove()
				Tyler:remove()
				Utilities.FadeIn(1)		
				Jaake:WalkTo(Vector3.new(-191.709, 435.657, 280.903))
				Utilities.Sync {
					function()
						Jaake:LookAt(prof.model.Head.Position)
					end,
					function()
						prof:LookAt(Jaake.model.Head.Position)
						prof:Say('Not you, Jake. I need you here.','Keep your friend busy while we leave for the cave.')
					end,
				}
				Jaake:Say('Oh, yes sir.')
				prof:Say('Good, come meet us at the cave when you are done.')
				Utilities.FadeOut(0.5)
				wait(0.5)
				Jaake:WalkTo(Vector3.new(-187.143, 433.735, 269.925))
				prof:remove()
				Ramp:remove()
				Ship:remove()
				Jaake:LookAt(Vector3.new(-191.943, 431.198, 265.22))
				cam.CFrame = CFrame.lookAt(Vector3.new(-190.626, 439.548, 258.299),Vector3.new(-189.993, 435.348, 266.57))
				_p.MasterControl:LookAt(Jaake.model.Head.Position)
				Utilities.FadeIn(1)

				_p.MusicManager:popMusic('all', 1)
				spawn(function()
					wait(2)
					_p.MusicManager:stackMusic(107350888359075, 'Cutscene')
				end)
				Jaake:Say('Well, ' .. _p.PlayerData.trainerName .. ', here we are again.',
					'The plan has already been set in motion.',
					'Too much is at stake here, I can\'t let you mess it up.',
					'At least let me see how strong you\'ve become since we last met.',
					'Tell me, am I stronger now?')

				local win = _p.Battle:doTrainerBattle {
					IconId = 5226446131,
					musicId = {9536676199, 12639990881},
					musicVolume = 1,
					PreventMoveAfter = true,
					LeaveCameraScriptable = true,
					trainerModel = Jaake.model,
					num = 230,
					battleSceneType = 'EclipseHangar',
				}
				if not win then
					_p.MasterControl.WalkEnabled = true
					chat:enable()
					_p.Menu:enable()
					cam.CameraType = Enum.CameraType.Custom
					return true
				end
				cam.CFrame = CFrame.lookAt(Vector3.new(-190.626, 439.548, 258.299),Vector3.new(-189.993, 435.348, 266.57))
				Jaake:Say('I\'ve always learned from battling with you.',
					'I knew before we battled that I would not stop you.',
					'Soon the professor will be opening the tomb that has imprisoned Hoopa for eons.',
					'It is located deep within a cave on the other side of Route 18.',
					'Always remember: We fall, we fight.',
					'I need to go now.')
				Jaake:WalkTo(Vector3.new(-200.173, 431.199, 221.581))
				wait(0.5)
				Jaake:remove()

				Utilities.lookBackAtMe(0.5)
				_p.RunningShoes:enable()
				_p.MasterControl.WalkEnabled = true
				_p.Menu:enable()
				chat:enable()
				cam.CameraType = Enum.CameraType.Custom
			end
		end,

		onLoad_chunk60 = function(chunk)

			if not completedEvents.ExposeSecurity then
				_p.DataManager:loadMap("chunk57")
				Utilities.Teleport(CFrame.new(-1992.144, 939.572, -437.878))
				return
			end

			local prof = chunk.npcs.Professor
			local Ship = chunk.map.EclipseShip
			local Ramp = chunk.map.Ramp
			local ECAdmin = chunk.npcs.EclipseAdmin1
			local ECAdmin2 = chunk.npcs.EclipseAdmin2
			local Tyler = chunk.npcs.Tyler
			local Mom = chunk.npcs.Mom
			local Dad = chunk.npcs.Dad
			local Tess = chunk.npcs.Tess
			local map = chunk.map
			local ThisGUy = chunk.map.LookPart.Position
			local ECA = chunk.map.ECA.Position
			local PH = chunk.map.PH.Position
			local Jaake = chunk.npcs.Jake
			local BJake = chunk.map.BJake.Position

			if completedEvents.DefeatEclipseBase then
				prof:remove()
				Dad:remove()
				Mom:remove()
				Jaake:remove()
				ECAdmin:remove()
				Tess:remove()
				ECAdmin2:remove()
				Tyler:remove()
				if completedEvents.DefeatHoopa then
					return
				end
				Ramp:remove()
				Ship:remove()
				return
			end
			local prisoners = (Vector3.new(-192.079, 436.003, 277.406))
			if not completedEvents.DefeatEclipseBase then
				Utilities.Sync {
					function()
						prof:LookAt(prisoners)
						ECAdmin:LookAt(prisoners)
						ECAdmin2:LookAt(prisoners)
						Jaake:LookAt(prisoners)
						Tyler:LookAt(prisoners)
					end,}
			end
		end,
		
		onLoad_chunk88 = function(chunk)

			if completedEvents.burndrive then
				chunk.map.burndrive:remove()
			end
			if completedEvents.dousedrive then
				chunk.map.dousedrive:remove()
			end
			if completedEvents.chilldrive then
				chunk.map.chilldrive:remove()
			end
			if completedEvents.shockdrive then
				chunk.map.shockdrive:remove()
			end
		end,


		onLoad_chunk66 = function(chunk)
			local map = chunk.map
			local Cobalion = map:FindFirstChild("Cobalion")
			if Cobalion then 
				Cobalion.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.CobalionIdle}):Play()
			end
			local Terrakion = map:FindFirstChild("Terrakion")
			if Terrakion then
				Terrakion.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.TerrakionIdle}):Play()
			end
			local Virizion = map:FindFirstChild("Virizion")
			if Virizion then
				Virizion.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.VirizionIdle}):Play()
			end
			local RSword = map.Sword
			if completedEvents.SwordsOJ then
				if _p.Network:get('PDS', 'hasSwordsOJ') and not completedEvents.Keldeo then
					local Keldeo = _p.DataManager:request({'Model', 'Keldeo'})
					Keldeo.Parent = chunk.map
					if Keldeo then 
						Keldeo.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.KeldeoIdle}):Play()
					end
				end
				Cobalion:Destroy()
				Terrakion:Destroy()
				Virizion:Destroy()
				RSword:Destroy()
				return
			end
			if Cobalion and Terrakion and Virizion then
				touchEvent('SwordsOJ', chunk.map.SwordsOJTrigger, true, function()
					_p.Hoverboard:unequip(true)
					local camera = workspace.CurrentCamera
					camera.CameraType = Enum.CameraType.Scriptable
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					spawn(function()
						_p.Menu:disable()
					end)

					Utilities.lookAt(CFrame.new(-236.616592, 972.725403, 430.249847, -0.9999066, -0.00271226768, 0.0133971944, 2.32830616e-10, 0.980116189, 0.198424965, -0.0136689851, 0.198406428, -0.980024636))
					wait(1)
					RSword.Size = Vector3.new(0.515, 0.26, 4.665)
					RSword.CFrame = RSword.CFrame + Vector3.new(0, 10, 0)
					Utilities.Tween(1, "easeOutCubic", function(z)
						RSword.Transparency = 1 - 0.8 * z
					end)
					local orientation = RSword.Orientation
					local RSwordCFrame = RSword.CFrame
					Utilities.Tween(1, nil, function(z)
						RSword.CFrame = RSwordCFrame * CFrame.new(0, 0, 10 * z) * CFrame.Angles(0, math.rad(-360 * z), 0)
						RSword.Size = Vector3.new(1.515 + 5.929 * z, 0.36 + 1.41 * z, 5.665 + 22.164 * z)
						RSword.Transparency = 0.2 - 0.2 * z
					end)
					RSwordCFrame = RSword.CFrame
					Utilities.Tween(0.4, "easeInSine", function(z)
						RSword.CFrame = RSwordCFrame * CFrame.new(0, 0, 5 * z)
					end)
					Utilities.FadeOut(0.3, Color3.fromRGB(255, 255, 255))
					Cobalion:Destroy()
					Virizion:Destroy()
					Terrakion:Destroy()
					RSword:Destroy()
					wait(0.3)
					Utilities.FadeIn(0.7)
					_p.NPCChat:say("The wild Pokemon fled!", "Cobalion, Terrakion, and Virizion can now be found roaming in the wild.")
					camera.CameraType = Enum.CameraType.Custom
					_p.MasterControl.WalkEnabled = true
					spawn(function()
						_p.Menu:enable()
					end)
				end)
			end
		end,
		
		onLoad_chunk76 = function(chunk)
			local salesperson = chunk.npcs.Lady
			local SafariTrigger = chunk.map.SafariTrigger
			local wkb = chunk.map.WTriggerB.Position
			local wkt = chunk.map.WTriggerT.Position

			local function doUi()

				local bg, buy
				local dt = false -- doingTween
				local bgHover, mHover = false, false

				local function stopTween()
					if dt then
						dt = false
						wait(.5)
					end
				end

				local function tweenBuyBtn(g, v)
					stopTween()

					local y = buy.Position.Y.Scale 
					local d

					if y ~= g then
						d = g-y
					else
						return
					end

					if v then return end

					dt = true

					Utilities.Tween(.5, nil, function(a)
						if not dt then return end

						buy.Position = UDim2.new(0.125, 0, y+d*a, 0)
					end)
				end

				bg = _p.RoundedFrame:new({
					BackgroundColor3 = Color3.new(.3, .3, .3),
					Size = UDim2.new(0.15, 0, 0.09, 0),
					Position = UDim2.new(0.125, 0, 0.8, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Button = true,
					MouseEnter = function()
						tweenBuyBtn(0.85)
						bgHover = true
					end,
					MouseLeave = function()
						tweenBuyBtn(0.80, mHover)
						bgHover = false
					end,
					ZIndex = 7, Parent = Utilities.gui,
				})

				local function writeMoney()
					if bg.gui:FindFirstChild("txt") then
						bg.gui:FindFirstChild("txt"):Destroy()
					end
					Utilities.Write('[$]' .. _p.PlayerData:formatMoney()) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.55, 0, 0.55, 0),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Name = "txt",
							ZIndex = 8, Parent = bg.gui
						}, Scaled = true, 
					}
				end

				_p.PlayerData.moneyUpdateCallback = writeMoney

				writeMoney()

				buy = _p.RoundedFrame:new({
					BackgroundColor3 = Color3.fromRGB(104, 225, 74),
					Size = UDim2.new(0.1, 0, 0.07, 0),
					Position = UDim2.new(0.125, 0, 0.8, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Button = true,
					MouseEnter = function()
						if bgHover then return end
						mHover = true
						tweenBuyBtn(0.85)
					end,
					MouseLeave = function()
						tweenBuyBtn(0.8, bgHover)
						mHover = false
					end,
					MouseButton1Click = function()
						_p.Menu.shop:buyMoney()
					end,
					ZIndex = 6, Parent = Utilities.gui,
				})

				Utilities.Write("Buy [$]") {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.45, 0, 0.45, 0),
						Position = UDim2.new(0.5, 0, 0.65, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						ZIndex = 6, Parent = buy.gui
					}, Scaled = true, 
				}

				return function()
					_p.PlayerData.moneyUpdateCallback = nil
					stopTween()
					bg:remove()
					buy:remove()
				end
			end
			-- ante Here, can't use touchEvent because it disconnects the fn after one touch :(
			local debounce = false
			SafariTrigger.Touched:connect(function(p)
				if debounce or not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				debounce = true
				local cam = workspace.CurrentCamera
				spawn(function()
					_p.MasterControl.WalkEnabled = false
					_p.MasterControl:Stop()
					_p.Menu:disable()
				end)
				_p.MasterControl:LookAt(salesperson.model.Head.Position)
				salesperson:LookAt(_p.player.Character.HumanoidRootPart.Position)
				salesperson:Say('Welcome to Roria\'s Safari Zone.')
				salesperson:Say('Would you like to have a go at capturing Pokemon safari style?')

				if _p.Network:get('PDS', 'moneySafari') then
					salesperson:Say('You don\'t have enough [$], please come again.')
					_p.MasterControl:WalkTo(wkb)
					_p.Menu:enable()
					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true 
					debounce = false
					return
				end

				local destroyUi = doUi()

				salesperson:Say('For [$]500, you can have twenty Safari Balls to use to try and capture wild pokemon.')
				local choice = salesperson:Say('[y/n]Are you interested?')

				if choice then
					destroyUi()
					salesperson:Say('Here are your Safari Balls. Have fun!')
					spawn(function() 
						_p.MasterControl:WalkTo(wkt) 
						debounce = false
					end)
				else
					destroyUi()
					salesperson:Say('Oh, I understand.', 'Come back some other time!')
					_p.MasterControl:WalkTo(wkb)
					_p.Menu:enable()
					_p.RunningShoes:enable()
					_p.MasterControl.WalkEnabled = true
					debounce = false
				end
			end)
		end,
		["onDoorFocused_C_chunk76|a"] = doLeaveSafariDialogue,
		["onDoorFocused_C_chunk76|b"] = doLeaveSafariDialogue,
		leaveSafari = function(chunk, isForced)
			if not chunk.data.isSafari then return end

			if isForced then
				chat.bottom = true
				chat:say("You have run out of Safari Balls.",
					"You must now return to the Safari Lodge.")
				chat.bottom = nil
			end	

			Utilities.FadeOut(1)
			Utilities.TeleportToSpawnBox()
			chunk:remove()
			chunk = _p.DataManager:loadMap('chunk76')
			local pos  = chunk.map.SafariTrigger.Position
			Utilities.Teleport(CFrame.new(pos-Vector3.new(0, 2, 4), pos-Vector3.new(0, 2, 5)))
			spawn(function() Utilities.FadeIn(1) end)
			_p.MasterControl.WalkEnabled = true
			_p.Menu:enable()
		end,

		

		onLoad_chunk56 = function(chunk)
			local prof = chunk.npcs.Professor
			local Mom = chunk.npcs.Mom
			--	local Player = chunk.map.You.Position
			local Dad = chunk.npcs.Dad
			local Tyler = chunk.npcs.Tyler

			local Tess = chunk.npcs.Tess
			--	local DadP = chunk.map.DadPart.Position
			local Jake = chunk.npcs.Jake
			--	local JakeL = chunk.map.JakeLook.Position
			local EC2 = chunk.npcs.EclipseAdmin2
			local EC1 = chunk.npcs.EclipseAdmin1
			local Unblock = chunk.map.Unblocker
			local block = chunk.map.TheTrigger
			local playerPos = Vector3.new(-549.003, 716.245, 565.978)
			local db = false
			touchEvent(nil, block, false, function()
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				_p.Menu:disable()
				_p.RunningShoes:disable()
				Utilities.FadeOut(0.5)

				do

					wait(1)
					local cam0 = CFrame.new(-546.532471, 793.722839, 518.02832, 1, 0, 0, 0, 0.866025388, -0.5, 0, 0.5, 0.866025388 )
					local cam1 = CFrame.new( -546.532471, 758.722839, 678.028259, 1, -3.23608242e-06, 8.56015049e-06, 2.32457273e-06, 0.994533658, 0.104416542, -8.85125519e-06, -0.104416542, 0.994533658 )
					local cam2 = CFrame.new(-540.807983, 726.695557, 567.85144, 0.60632211, -0.271423966, 0.747464657, -0.0270700455, 0.932355106, 0.360524446, -0.794760704, -0.238828585, 0.557971418 )
					local camera = workspace.CurrentCamera
					camera.CameraType = Enum.CameraType.Scriptable
					camera.CFrame = cam0	
					spawn(function()
						_p.MusicManager:stackMusic(7223926171, 'Cutscene')
						Utilities.FadeIn(2)
						wait(0.2)




						Utilities.Tween(3, "easeInOutQuad", function(a)
							camera.CFrame = cam0:Lerp(cam1, a)
						end, RENDER_PRIORITY_CAMERA)
						wait(0.8)


						_p.MasterControl:WalkTo(playerPos)

						camera.CFrame = cam1		
						Utilities.Tween(1.2, "easeInOutQuad", function(a)
							camera.CFrame = cam1:Lerp(cam2, a)
						end, RENDER_PRIORITY_CAMERA)

						local eclipse = {prof, Mom, Dad, Tess, Jake, EC2, EC1}
						for _, npc in pairs(eclipse) do
							spawn(function() npc:LookAt(playerPos) end)
						end

						prof:Say("Hahahahaha... You never give up, do you?")
						prof:Say("You just don't know when to quit.")
						prof:Say("Also why are you in here?")
						Mom:Say("This cutscene is a work in progress, so it's not done...")
						Mom:Say("Please rejoin the game  and get out of this area...")
					end)
				end
			end)
		end,





--[[			
		onLoad_chunk47 = function(chunk)
			local zmove = chunk.npcs.avalanche
			interact[zmove.model] = function()
				if not completedEvents.GivenZPouch then
					chat:say(zmove, 'Hi.'
						
					)
					chat.bottom = true
					spawn(function() _p.PlayerData:completeEvent('GivenZPouch') end)
					_p.Menu.bag:enablezmovepouch()
					chat:say('The Z-Crystal pouch has been added to the Bag!')
					chat.bottom = nil
					chat:say(zmove, 'There.'
					)
				else
					chat:say(zmove, 'After some reasearch, we\'ve found that Z-Crystals allow Pok[e\']mon to use powerful moves.',
						'The Z-Moves drain your bracelet of its energy, so they can only be used once per battle.',
						'You must choose when to use your moves wisely.')
				end
			end
		end,		
				
		--]]		



	--[[onExit_gym8 = function()
		local chunk = _p.DataManager.currentChunk
		local Tess = chunk.npcs.CaptainA
		if _p.PlayerData.badges[6] then
		chat:say('Hey!')
		Utilities.lookBackAtMe()
		chat:disable()
		_p.Menu:disable()
		wait(1)
		
		Tess:Say('Your Friend Just Ran off chasing a guy wearing black and orange clothes.',
		'She ran into that tavern over there.',
		'Im going back to fishing.',
		'See ya!')
		else
			Tess:remove()
			
		end
		
	end,]]
		--Trying to Make Jumping Possible
		onLoad_UrAnthianHouse = function(chunk) -- Your House
			_p.MasterControl:SetJumpEnabled(true)
		end,
		onExit_UrAnthianHouse = function()
			_p.MasterControl:SetJumpEnabled(false)
		end,

		--]==]
	--[[



	--]]
	}

--[[
Todo:

(FUTURE): see Events.onBeforeEnter_PokeBallShop
Current Save, Frostveil City Working on the rest
see DataService

--]]
end
