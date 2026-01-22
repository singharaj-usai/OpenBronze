return function(_p)
	local players = game:GetService('Players')
	local player = players.LocalPlayer

	local Utilities = _p.Utilities

	-- todo: pokerus
	local Pokemon = {
		balls = { -- OVH  these are still necessary for BattleSprite:animSummon
			'pokeball',
			'greatball',
			'ultraball',
			'masterball',
			'colorlessball',
			'insectball',
			'dreadball',
			'dracoball',
			'zapball',
			'fistball',
			'flameball',
			'skyball',
			'spookyball',
			'premierball',
			'meadowball',
			'earthball',
			'netball',
			'luxuryball',
			'icicleball',
			'quickball',
			'duskball',
			'toxicball',
			'mindball',
			'stoneball',
			'steelball',
			'splashball',
			'pixieball',
			'pumpkinball',
			'frostyball', 
			'safariball' -- 30 (31 max without having to correspond to [0], then max = 32)
		}


	}

	function Pokemon:getIcon(icon, shiny)
		local gui
		if icon > 1450 then -- egg threshold
			-- Egg
			local i = icon-1451 -- also egg threshold dependent
			local s = .7
			gui = Utilities.Create 'Frame' {
				Name = 'EggsIcon',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 1.0, 0),

				Utilities.Create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://16648909335',--7182378829,--5217725550--5217726770--323851693--<--323851693 needs to be replaced/reuploaded
					ImageRectSize = Vector2.new(30, 32),
					ImageRectOffset = Vector2.new(30*(i%18), 32*math.floor(i/18)),
					Size = UDim2.new(3/4/32*30*s, 0, s, 0),
					Position = UDim2.new(.5-3/4/32*30*s/2, 0, 0.5-s/2, 0),
					ZIndex = 5,
				}
			}
		else
--[[old logic
	local col = icon % 16
	local row = math.floor(icon/16)
	local image = 1
	if col >= 8  then image = image + 1 end
	if row >= 28 then image = image + 2 end
	col = col % 8
	row = row % 28]]

			--	new logic
			--	[11(x2) x 25] [10(x2) x 25]
			--	[11(x2) x 24] [10(x2) x 23]
			--21 across
			-- 25 down
			
			--[[
			-- old one before adding the new sheets
			local col = icon%21
			local row = math.floor(icon/21)
			local image = 1
			if col>10 then image=image+1 col=col-11 end
			if row>24 then image=image+2 row=row-25 end
-]]
			local image, col, row

			if icon >= 1218 then
				icon -= 1218
				image = 5
				col = icon%10
				row = math.floor(icon/10)
			else
				col = icon%21
				row = math.floor(icon/21)
				image = 1
				if col>10 then image=image+1 col=col-11 end
				if row>24 then image=image+2 row=row-25 end	
			end
			gui = Utilities.Create 'ImageLabel' {
				Name = 'PokemonIcon',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://'..({5217729664, 5217730967, 7051824816, 7051824809, 16650578045, 0})[image],--{5217734559, 5217735901, 5217737087, 5217738275}
				ImageRectSize = Vector2.new(40, 30),
				ImageRectOffset = Vector2.new(80*col+(shiny and 40 or 0), 30*row),
				Size = UDim2.new(1.0, 0, 1.0, 0),
				ZIndex = 5
			}
		end
		return gui, icon
	end


--[[	
	function Pokemon:filterNickname(nickname) -- this is the quick filter; full Roblox filter implemented once they hit submit
		nickname = nickname:gsub('|', '')	
		do
			local bytes = {string.byte(nickname, 1, #nickname)}
			for i = #bytes, 1, -1 do
				local b = bytes[i]
				if b < 32 or b > 126 then
					table.remove(bytes, i)
				end
			end
			nickname = string.char(unpack(bytes))
		end
		if nickname:len() > 12 then
			nickname = nickname:sub(1, 12)
		end
		return nickname
	end
	
	--]]

	--test new filter nickname
	function Pokemon:filterNickname(nickname)
		nickname = nickname:gsub("|", "");
		local bytes = utf8.len(nickname);
		if not bytes then
			return "";
		end;
		if not (bytes > 12) then
			return nickname;
		end;
		local v20 = utf8.offset(nickname, 13);
		if not v20 then
			return "";
		end;
		return nickname:sub(1, v20 - 1);
	end;

	function Pokemon:giveNickname(iconNum, isShiny)
		local prompt = _p.RoundedFrame:new {
			BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = UDim2.new(0.6, 0, 0.2, 0),
			Position = UDim2.new(0.2, 0, 0.4, 0),
			Parent = Utilities.frontGui,
		}
		local icon = self:getIcon(iconNum, isShiny)
		icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		icon.Size = UDim2.new(4/3, 0, 1.0, 0)
		icon.Parent = prompt.gui
		local entryRF = _p.RoundedFrame:new {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0.7325, 0, 0.8, 0),
			Position = UDim2.new(0.25, 0, 0.1, 0),
			ZIndex = 2, Parent = prompt.gui,
		}
		local entryBox = Utilities.Create 'TextBox' {
			BackgroundTransparency = 1.0,
			TextColor3 = Color3.new(.3, .3, .3),
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			Text = '',
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 4, Parent = entryRF.gui,
		}
		local function filter()
			entryBox.Text = self:filterNickname(entryBox.Text)
		end
		entryBox.Changed:connect(filter)
		local name
		entryBox:CaptureFocus()
		entryBox.FocusLost:wait()
		filter()
		name = Utilities.trim(entryBox.Text)
		if name:len() == 0 then
			name = nil
		end
		entryRF:remove()
		prompt:remove()
		return name
	end

	function Pokemon:hatch(data)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		local menuWasEnabled = _p.Menu.enabled
		spawn(function() _p.Menu:disable() end)
		_p.NPCChat:say('Oh?')
		spawn(function() _p.MusicManager:prepareToStack(.5) end)
		Utilities.FadeOut(.5, Color3.new(0, 0, 0))
		local bg = Utilities.Create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(239/255, 181/255, 71/255),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.gui,
		}
		local sq = Utilities.Create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = Utilities.gui,
		}
		local function update(prop)
			if prop ~= 'AbsoluteSize' then return end
			sq.Position = UDim2.new(0.5, -sq.AbsoluteSize.X/2, 0.0, 0)
		end
		sq.Changed:connect(update)
		update('AbsoluteSize')
		local eggFrame = (self:getIcon(data.eggIcon))
		local egg = eggFrame:GetChildren()[1]
		egg.Parent = sq
		eggFrame:remove()
		local s = .3
		egg.Size = UDim2.new(s, 0, s, 0)
		egg.Position = UDim2.new(.5-s/2, 0, .5-s/2, 0)
		Utilities.FadeIn(.5)
		Utilities.sound(287784334, nil, nil, 5)
		local sound
		delay(1, function()
			sound = Utilities.loopSound(12639585348)--ev
		end)
		wait(.5)
		local crack = Utilities.Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://7216367119',
			ImageRectSize = Vector2.new(30, 32),
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 6,
		}
		local function crackStage(s)
			crack.ImageRectOffset = Vector2.new(30*(s+2), 32*20)
		end
		crackStage(1)
		for i = 1, 2 do
			Utilities.Tween(1, nil, function(a)
				local p = math.cos(a*math.pi*2)
				local sy = s*.85
				local oy = 0
				if p > 0 then
					--				if i == 1 and a > .5 then return false end
					sy = s*(.85+p*.15)
				else
					local p2 = math.sin((a*math.pi*2-math.pi/2)*1.2)
					if p2 > 0 then
						sy = s*(.85+p2*.25)
					end
					oy = p*s*.3
				end
				egg.Size = UDim2.new(s, 0, sy, 0)
				egg.Position = UDim2.new(.5-s/2, 0, .5-s/2+(s-sy)+oy, 0)
			end)
			wait(.2)
			if i == 1 then
				crack.Parent = egg
			else
				crackStage(2)
			end
		end
		wait(.5)
		Utilities.Tween(1, nil, function(a)
			local p = math.sin(a*math.pi*2)
			egg.Rotation = 45*p
			egg.Size = UDim2.new(s, 0, s, 0)
			egg.Position = UDim2.new(.5-s/2+s*p/math.pi, 0, .5-s/2, 0)
		end)
		crackStage(3)
		wait(.1)
		Utilities.Tween(.8, nil, function(a)
			local p = math.cos(a*math.pi*2)
			local sy = s*.85
			local oy = 0
			if p > 0 then
				if a > .5 then return false end
				sy = s*(.85+p*.15)
			else
				local p2 = math.sin((a*math.pi*2-math.pi/2)*1.2)
				if p2 > 0 then
					sy = s*(.85+p2*.25)
				end
				oy = p*s*.3
			end
			egg.Size = UDim2.new(s, 0, sy, 0)
			egg.Position = UDim2.new(.5-s/2, 0, .5-s/2+(s-sy)+oy, 0)
		end)
		crackStage(4)
		wait(.1)
		Utilities.Tween(.8, nil, function(a)
			local p = math.sin(a*math.pi*2)
			local sy = s
			if a < .25 then
				sy = s*(.85+p*.15)
			end
			egg.Rotation = 45*p
			egg.Size = UDim2.new(s, 0, sy, 0)
			egg.Position = UDim2.new(.5-s/2+s*p/math.pi, 0, 0.5-s/2+(s-sy), 0)
		end)
		local circle
		spawn(function()
			local p = Utilities.Create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5217740472',
				ZIndex = 7, Parent = sq,
			}
			circle = p
			Utilities.Tween(.3, nil, function(a)
				local ps = a*1.5
				p.Size = UDim2.new(ps, 0, ps, 0)
				p.Position = UDim2.new(.5-ps/2, 0, .5-ps/2, 0)
				local e = s+a*.3
				egg.Size = UDim2.new(e, 0, e, 0)
				egg.Position = UDim2.new(.5-e/2, 0, .5-e/2, 0)
				egg.ImageTransparency = a
				crack.ImageTransparency = a
			end)
		end)
		wait(.1)
		--	crackStage(5)
		wait(.1)
		Utilities.FadeOut(.3, Color3.new(1, 1, 1))
		egg:remove()
		local before = tick()
		local sd = data.pSprite
		local elapsed = tick()-before
		if elapsed < 1 then
			wait(1-elapsed)
		end
		local sprite = _p.AnimatedSprite:new(sd)
		sprite.spriteLabel.Parent = sq
		sprite.spriteLabel.ZIndex = 5
		local scale = sd.scale or 1
		local x = sd.fWidth/175*scale
		local y = sd.fHeight/175*scale
		sprite.spriteLabel.Size = UDim2.new(x, 0, y, 0)
		sprite.spriteLabel.Position = UDim2.new(0.5-x/2, 0, 0.5-y/2, 0)
		sprite:Play()
		spawn(function()
			local p = circle
			Utilities.Tween(.5, nil, function(a)
				local s = (1-a)*1.5
				p.Size = UDim2.new(s, 0, s, 0)
				p.Position = UDim2.new(.5-s/2, 0, .5-s/2, 0)
			end)
			p:remove()
		end)
		Utilities.FadeIn(1)
		pcall(function()
			sound:Stop()
			sound:remove()
		end)
		Utilities.sound(12639642017, nil, .5, 10)
		_p.NPCChat:say(data.pName .. ' hatched from the Egg!')
		wait(1)
		local nickname
		if _p.NPCChat:say('[y/n]Would you like to give a nickname to the newly hatched ' .. data.pName .. '?') then
			nickname = self:giveNickname(data.pIcon, data.pShiny)
		end
		local st = tick()
		_p.Network:get('PDS', 'makeDecision', data.d_id, nickname)
		local et = tick()-st
		if et < 1 then wait(1-et) end
		Utilities.FadeOut(.5, Color3.new(0, 0, 0))
		sprite:remove()
		bg:remove()
		sq:remove()
		wait(.5)
		spawn(function() _p.MusicManager:returnFromSilence(.5) end)
		Utilities.FadeIn(.5)
		if menuWasEnabled then
			Utilities.fastSpawn(function() _p.Menu:enable() end)
		end
		_p.MasterControl.WalkEnabled = true
		--_p.MasterControl:Start()

	end

	function Pokemon:getOT(id)
		if not id or id == _p.userId then return _p.player.Name, _p.userId end
		if id == 12301 then return 'Ash', 12301 end
		if id <= 0 then
			return 'Guest', 0
		end
		local name
		local s = pcall(function() name = players:GetNameFromUserIdAsync(id) end)
		return name, id
	end

	function Pokemon:getNature(num)
		return ({
			{name='Hardy'                           },
			{name='Lonely',  plus='atk', minus='def'},
			{name='Brave',   plus='atk', minus='spe'},
			{name='Adamant', plus='atk', minus='spa'},
			{name='Naughty', plus='atk', minus='spd'},
			{name='Bold',    plus='def', minus='atk'},
			{name='Docile'                          },
			{name='Relaxed', plus='def', minus='spe'},
			{name='Impish',  plus='def', minus='spa'},
			{name='Lax',     plus='def', minus='spd'},
			{name='Timid',   plus='spe', minus='atk'},
			{name='Hasty',   plus='spe', minus='def'},
			{name='Serious'                         },
			{name='Jolly',   plus='spe', minus='spa'},
			{name='Naive',   plus='spe', minus='spd'},
			{name='Modest',  plus='spa', minus='atk'},
			{name='Mild',    plus='spa', minus='def'},
			{name='Quiet',   plus='spa', minus='spe'},
			{name='Bashful'                         },
			{name='Rash',    plus='spa', minus='spd'},
			{name='Calm',    plus='spd', minus='atk'},
			{name='Gentle',  plus='spd', minus='def'},
			{name='Sassy',   plus='spd', minus='spe'},
			{name='Careful', plus='spd', minus='spa'},
			{name='Quirky'                          },
		})[num]
	end

	function Pokemon:getTypes(fromTypes)
		local typeFromInt = {'Bug','Dark','Dragon','Electric','Fairy','Fighting','Fire','Flying','Ghost','Grass','Ground','Ice','Normal','Poison','Psychic','Rock','Steel','Water'}
		local types = {}
		for i, t in pairs(fromTypes) do
			types[i] = typeFromInt[t]
		end
		return types
	end

	function Pokemon:getPokeBall(ballId)
		return Pokemon.balls[ballId or 1] or 'pokeball'
	end


	function Pokemon:tryLearnMove(pokemonName, knownMoves, decision)
		local chat = _p.NPCChat
		local move = decision.move
		local moveName = move.name
		local didLearn = false
		local function learnMove(slot)
			didLearn = true
			knownMoves[slot] = move
			local args = {slot}
			if decision.transform then
				args = {decision.transform(move, slot)}
			end
			_p.Network:get('PDS', 'makeDecision', decision.id, unpack(args))
		end
		for i = 1, 4 do
			if not knownMoves[i] then
				chat:say(pokemonName .. ' learned the move ' .. moveName .. '!')
				learnMove(i)
				break
			end
		end
		if not didLearn then
			while true do
				chat:say(pokemonName .. ' wants to learn the move ' .. moveName .. '.')
				chat:say('However, ' .. pokemonName .. ' already knows four moves.')
				local delete = chat:say('[Y/N]Should a move be deleted and replaced with ' .. moveName .. '?')

				if delete then
					chat:say('Which move should be forgotten?')
					local movesCopy = Utilities.shallowcopy(knownMoves)
					movesCopy[#movesCopy+1] = move
					local slot = _p.BattleGui:promptReplaceMove(movesCopy)
					if slot then
						local deletedMove = knownMoves[slot]
						if chat:say('[Y/N]Should ' .. pokemonName .. ' forget ' .. deletedMove.name .. ' in order to learn ' .. moveName .. '?') then
							chat:say('1, 2, and... ... ... Ta-da!', pokemonName .. ' forgot how to use ' .. deletedMove.name .. '.',
								'And...', pokemonName .. ' learned ' .. moveName .. '!')
							learnMove(slot)
							break
						end
					end
				end

				if chat:say('[y/n]Give up on learning the move ' .. moveName .. '?') then
					chat:say(pokemonName .. ' did not learn ' .. moveName .. '.')
					break
				end
			end
		end
		return didLearn
	end

	function Pokemon:learnMoves(pokemonName, knownMoves, decisions)
		for _, decision in pairs(decisions) do
			local move = decision.move
			local knowsMove = false
			for _, m in pairs(knownMoves) do
				if m.name == move.name then
					knowsMove = true
					break
				end
			end
			if not knowsMove then
				if not self:tryLearnMove(pokemonName, knownMoves, decision) then
					_p.Network:get('PDS', 'makeDecision', decision.id, nil)
				end
			end
		end
	end

	function Pokemon:processMovesAndEvolution(data, alreadyFaded)
		-- try to learn moves
		if data.moves then
			self:learnMoves(data.pokeName, data.known, data.moves)
		end
		-- try to evolve
		local evo = data.evo
		if evo then
			if evo.flip then
				local flipped = false
				local orientation0 = evo.orientation0
				local orientation1 = _p.Battle:sampleOrientation()
				if orientation0 and orientation1 then
					orientation0 = (orientation0*Vector3.new(1,0,1)).unit
					orientation1 = (orientation1*Vector3.new(1,0,1)).unit
					if orientation0.magnitude + orientation1.magnitude > 1.9 then
						local angle = math.deg(math.acos(orientation0:Dot(orientation1)))
						if angle > 150 then
							flipped = true
						end
					end
				end
				if not flipped then
					_p.Network:get('PDS', 'makeDecision', evo.decisionId, false)
					return
				end
			end
			local evolved, endFade = _p.BattleGui:animateEvolution(data.pokeName, evo.name, evo.sprite1, evo.sprite2, alreadyFaded, evo.cannotCancel)
			_p.Network:get('PDS', 'makeDecision', evo.decisionId, evolved)
			if evolved and evo.moves then
				self:learnMoves(evo.nickname or evo.name, data.known, evo.moves)
			end
			if endFade then spawn(endFade) end
		end
	end


	return Pokemon end