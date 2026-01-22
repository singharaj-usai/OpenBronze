return function(_p)--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write

	local hmMoveIds = {cut=true, surf=true, fly=true, rockclimb=true, rocksmash=true}
	local moveAnims = require(script.MoveAnimations)(_p)

	local BattleGui = {
		moveAnimations = moveAnims
	}
	local roundedFrame, Menu; function BattleGui:init()
		roundedFrame = _p.RoundedFrame
		Menu = _p.Menu
	end

	local state
	local gui = {}

	local typeColors = {
		Bug = Color3.new(.54, .69, .2),
		Dark = Color3.new(.44, .33, .25),
		Dragon = Color3.new(.44, .4, .9),
		Electric = Color3.new(1, 1, .4),
		Fairy = Color3.new(.92, .45, .92),
		Fighting = Color3.new(.65, .32, .26),
		Fire = Color3.new(.95, .26, .12),
		Flying = Color3.new(.55, .8, 1),
		Ghost = Color3.new(.5, 0, 1),
		Grass = Color3.new(.4, 1, .4),
		Ground = Color3.new(.65, .51, .2),
		Ice = Color3.new(.4, 1, 1),
		Normal = Color3.new(.85, .85, .85),
		Poison = Color3.new(.8, .4, 1),
		Psychic = Color3.new(1, .44, .81),
		Rock = Color3.new(.66, .47, .23),
		Steel = Color3.new(.4, .4, .4),
		Water = Color3.new(0, .5, 1),
	}
	BattleGui.typeColors = typeColors

--[[
	function BattleGui:updateButtonForZMove(button, move, zmove, zmoves)
		warn('battleGui:updateButtonForZMove')
		button.MoveNameContainer:ClearAllChildren()
		button.TypeContainer:ClearAllChildren()
		button.PPContainer:ClearAllChildren()

		local Num = tonumber(string.sub(button.Name, 5, 6))

		--HEREMROP

		if not move or zmoves[Num] == "" then
			button.ImageColor3 = Color3.new(0.5, 0.5, 0.5)
			button.ImageTransparency = 0.5
			return
		end

		local ZMoveColors = {
			["Inferno Overdrive"] = Color3.fromRGB(243,	66, 30);
			["Devastating Drake"] = Color3.new(.44, .4, .9);
		};

		local tc = ZMoveColors[zmove] or typeColors[move.type];
		button.ImageColor3 = tc
		button.ImageTransparency = 0
		if zmove:sub(1, 2) == "Z-" then 
			write(zmove)({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.8, 0),
					Position = UDim2.new(0, 0, 0.6, 0),
					Parent = button.MoveNameContainer
				}),
				Scaled = true
			})
		else
			local name1 = zmove
			local name2
			local len = name1:len()
			local splitPosition, dif
			local start = 1
			while true do
				local s = name1:find(" ", start, true)
				if not s then
					break
				end
				local tdif = math.abs(len - s - s + 1)
				if not dif or dif > tdif then
					splitPosition, dif = s, tdif
				end
				start = s + 1
			end
			if splitPosition then
				name2 = name1:sub(splitPosition + 1)
				name1 = name1:sub(1, splitPosition - 1)
			end
			write(name1)({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.8, 0),
					Position = UDim2.new(0, 0, 0.1, 0),
					Parent = button.MoveNameContainer
				}),
				Scaled = true
			})
			if name2 then
				write(name2)({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.8, 0),
						Position = UDim2.new(0, 0, 1.1, 0),
						Parent = button.MoveNameContainer
					}),
					Scaled = true
				})
			end
		end
	end
--]]

	function BattleGui:animWeather(weather)
		local i, a, v
		local mo = 0.9
		if weather == 'raindance' or weather == 'primordialsea' then

		elseif weather == 'sandstorm' then
			i = 12097235888
			a = 300/225
			local angle = math.rad(30)
			v = Vector2.new(math.cos(angle), math.sin(angle)) * 2
			mo = 0.6
		elseif weather == 'hail' then
			i = 12097256736
			a = 1
		else
			return
		end
		local rainFrame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.gui,
		}
		local rain = _p.Rain:start(rainFrame, i, a, v)
		Utilities.Tween(.5, nil, function(a)
			rain:setTransparency(1-a*mo)
		end)
		wait(1)
		Utilities.Tween(.5, nil, function(a)
			rain:setTransparency(1-(1-a)*mo)
		end)
		rain:remove()
		rainFrame:remove()
	end
	function BattleGui:animCapture(poke, pokeballId, shakes, critical)
		local caught = (critical and shakes == 1) or shakes == 4
		poke.sprite:animCaptureAttempt(pokeballId, shakes, critical, caught)
		if caught then
			self:message('Gotcha! ' .. (poke.species or poke.name) .. ' was caught!')
			wait(1)
			return true
		end
		self:message(({'Oh no! The Pokemon broke free!','Aww! It appeared to be caught!','Aargh! Almost had it!','Gah! It was so close, too!'})[shakes+1])
		return false
	end
	function BattleGui:animStatus(status, poke)
		if moveAnims.status[status] then
			moveAnims.status[status](poke)
		else
			wait(.5)
		end
	end
	function BattleGui:animAbility(poke, abilityName)
		local n = poke.side.n
		local posYS, posYO = 0.0, 0
		if #poke.side.active == 1 then
			posYO = poke.statbar.main--[[.gui]].AbsolutePosition.y + poke.statbar.main--[[.gui]].AbsoluteSize.y + 20
		else
			posYS = (n==1 and .45 or .4)-.1/292*110
		end
		local gui = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://'..({12097279444, 12097281861})[n],
			Size = UDim2.new(.2, 0, .2/292*110, 0),-- 292x110
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Parent = Utilities.gui,
		}
		write(poke:getShortName()..'\'s') {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.3, 0),
				Position = UDim2.new(0.5, 0, 0.15, 0),
				ZIndex = 2,
				Parent = gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
		}
		write(abilityName) {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.3, 0),
				Position = UDim2.new(0.5, 0, 0.55, 0),
				ZIndex = 2,
				Parent = gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
		}
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			gui.Position = n==1 and UDim2.new(0.0, -gui.AbsoluteSize.X*(1-a), posYS, posYO) or UDim2.new(1.0, -gui.AbsoluteSize.X*a, posYS, posYO)
		end)
		wait(.1)
		delay(1, function()
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				gui.Position = n==1 and UDim2.new(0.0, -gui.AbsoluteSize.X*a, posYS, posYO) or UDim2.new(1.0, -gui.AbsoluteSize.X*(1-a), posYS, posYO)
			end)
			gui:remove()
		end)
	end
	function BattleGui:animBoost(poke, good)
		local p = poke.sprite.part
		local dir = good and 1 or -1
		Utilities.sound(good and 301970798 or 301970736, .3, nil, 5)
		spawn(function()
			local angles = {}
			local offset = math.random()*math.pi
			for i = 1, 6 do
				angles[i] = math.pi*2/6*i+offset
			end
			for i = 1, 6 do
				local theta = table.remove(angles, math.random(#angles))--math.random()*math.pi*2
				_p.Particles:new {
					Position = p.Position + Vector3.new(math.cos(theta)*(p.Size.x/2+1), -p.Size.Y*.5*dir, math.sin(theta)*(p.Size.x/2+1)),
					Size = Vector2.new(.4, .4/70*291),
					Velocity = Vector3.new(0, 10*dir, 0),
					Acceleration = false,
					Color = good and Color3.new(.4, .8, 1) or Color3.new(1, .4, .4),
					Lifetime = .5,
					Image = 12097352236,--, --stat change
				}
				wait(.125)
			end
		end)
	end
	function BattleGui:animHit(target, source, type, soundid, effectiveness, suppressParticles)
		effectiveness = effectiveness or 1
		local to = target.sprite.part.Position
		local from = source and source.sprite.part.Position or to+Vector3.new(0, 0, target.side.n==1 and -1 or 1)
		local color = typeColors[type or 'Normal']
		local p, s = Utilities.extents(to, 2)
		local smack = create 'ImageLabel' {
			Name = 'SmackAnim',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://12097371902', --smack
			ImageColor3 = color,
			Parent = Utilities.gui,
		}
		Utilities.sound(soundid or 6547048561, .75, effectiveness == 1 and .5 or .6, 5)
		if not suppressParticles then
			local diffsides = source and source.side ~= target.side
			local rotateFudge = (diffsides and #target.side.active==1) and 0.25 or 0
			_p.Particles:new {
				N = 6 * effectiveness,
				Position = to,
				Velocity = (CFrame.new(from, to)*CFrame.Angles(0, rotateFudge, 0)).lookVector*20 + Vector3.new(0, 8, 0),
				VelocityVariation = 30,
				Acceleration = Vector3.new(0, -30, 0),
				Color = color,
				Image = {12097392031, 12097398054},
				Size = 0.25,
				Lifetime = .75,
			}
		end
		Utilities.Tween(.25, nil, function(a)
			smack.ImageTransparency = 1-a
			local s = s * (.5+a/2)
			smack.Size = UDim2.new(0.0, s, 0.0, s)
			smack.Position = UDim2.new(0.0, p.x-s/2, 0.0, p.y-s/2)
		end)
		smack:remove()
	end
	function BattleGui:animMove(battle, pokemon, move, targets) 
		-- Status moves don't have animations because they're skipped...
		-- Will this cause problems if status moves are enabled?

		if not moveAnims[move.id] and move.category == 'Status' then return end
		-- Test thoroughly, if there's problems you can always comment the bottom out and reenable the top to disable animations for status moves
		--if not moveAnims[move.id] then return end

		local effectives, soundids = {}, {}
		for _, a in pairs(battle.actionQueue) do
			if a == '|' then break end
			local args, kwargs = battle:parseAction(a)
			local arg1 = args[1]
			if not arg1 or arg1 == 'move' then
				break
			elseif arg1 == '-immune' or arg1 == '-miss' or arg1 == '-fail' then
				local target = battle:getPokemon(args[2])
				if target then
					for i = #targets, 1, -1 do
						if targets[i] == target then
							table.remove(targets, i)
						end
					end
				end
				if arg1 == '-fail' then
					if move.category == 'Status' then return end
				end
				if not kwargs.noreset then
					pcall(function() pokemon.sprite:animReset() end)
				end
			elseif arg1 == '-supereffective' then
				local target = battle:getPokemon(args[2])
				if target then
					effectives[target] = 2
					soundids[target] = 6547057340
				end
			elseif arg1 == '-resisted' then
				local target = battle:getPokemon(args[2])
				if target then
					effectives[target] = .5
					soundids[target] = 6547129063
				end
			end
		end
		if moveAnims[move.id] then
			local targetMeta = {effectiveness=effectives,soundId=soundids}
			local continue = moveAnims[move.id](pokemon, targets, battle, move, targetMeta)
			if continue == 'sound' then -- TODO: this could be better; for now, ONLY RETURN THIS if the move has a single target
				local s, e
				for t, id in pairs(soundids) do
					s = id
					e = effectives[t]
					break
				end
				if not s then e = 1 end
				Utilities.sound(s or 6547048561, .75, e == 1 and .5 or .6, 5)
				return
			end
			if not continue then return end
		end
		local fns = {}
		for _, target in pairs(targets) do
			if target ~= pokemon then
				table.insert(fns, function()
					local s, r = pcall(function()
						self:animHit(target, pokemon, move.type, soundids[target], effectives[target])
					end)
					if not s then error('BATTLE BROKE ON MOVE: '..move.name..'; PLEASE REPORT THIS! ('..r..')') end
				end)
			end
		end
		if #fns == 1 then
			fns[1]()
		elseif #fns > 1 then
			Utilities.Sync(fns)
		end
	end
	function BattleGui:prepareMove(battle, pokemon, move, target)
		if not moveAnims.prepare[move.id] then return end
		if not target then
			target = pokemon.side.foe.active[1]
		end
		if target.isNull then
			target = pokemon
		end
		local prepareMessage
		--	if not battle.fastForward then
		prepareMessage = moveAnims.prepare[move.id](pokemon, target, battle, move, battle.fastForward)
		--	end
		if prepareMessage and not battle.fastForward then
			self:message(prepareMessage)
		end
	end

	do -- original code
		local mbcOffset = 0.275
		local relSize = 1-mbcOffset
		local msgBox = create 'ImageLabel' {
			Name = 'BattleMsg',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://7184401475',
			ImageTransparency = 1.0,
			Parent = Utilities.frontGui,

			create 'Frame' {
				Name = 'container',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, relSize, 0),
				Position = UDim2.new(0.0, 0, mbcOffset, 0),
				ClipsDescendants = true,
			}
		}
		local msgQueue = {}
		local font = Utilities.AvenirFont--require(game:GetService('ReplicatedStorage').Utilities.FontDisplayService.FontCreator).load('Avenir')
		local thread
		local processingMsg = false
		local msgsDone = Utilities.Signal()
		local function fadeInMsgBox()
			Utilities.fastSpawn(function()
				local thisThread = {}
				thread = thisThread
				Utilities.Tween(.125, nil, function(a)
					if thread ~= thisThread then return false end
					msgBox.ImageTransparency = 1-a
				end)
			end)
		end
		local function fadeOutMsgBox()
			Utilities.fastSpawn(function()
				local thisThread = {}
				thread = thisThread
				Utilities.Tween(.125, nil, function(a)
					if thread ~= thisThread then return false end
					msgBox.ImageTransparency = a
				end)
			end)
		end
		local answer
		local function processMessages()
			local boxHeightFill = 0.6
			local line1Pos = 0.3125
			local line2Pos = line1Pos + boxHeightFill/(font.baseHeight*2+font.lineSpacing)*(font.baseHeight+font.lineSpacing)
			local lineHeight = boxHeightFill/(font.baseHeight*2+font.lineSpacing)*font.baseHeight

			fadeInMsgBox()

			while #msgQueue > 0 do
				local line = 0
				local lines = {}
				msgBox.Size = UDim2.new(1.0, 0, 0.3, 0)
				msgBox.Position = UDim2.new(0.0, 0, 0.8, 0)

				local str = table.remove(msgQueue, 1)
				local overflow
				local yesorno = false
				repeat
					--				if type(str) ~= 'string' then
					--					print(type(str), str)
					--				end
					if str:sub(1, 5):lower() == '[y/n]' then
						yesorno = true
						answer = nil
						str = str:sub(6)
					elseif not yesorno then
						answer = nil
					end
					line = line + 1
					if not overflow then
						msgBox:TweenPosition(UDim2.new(0.0, 0, 0.8, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5, true)
					elseif line >= 2 then
						msgBox:TweenPosition(UDim2.new(0.0, 0, 0.7, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5, line==2)
					end
					local lf = Utilities.Create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.76, 0, lineHeight/relSize, 0),
						Position = UDim2.new(0.12, 0, ((line==1 and line1Pos or line2Pos)-mbcOffset)/relSize, 0),
						Parent = msgBox.container,
					}
					lines[line] = lf
					if line > 2 then
						local l1 = lines[line-2]
						local l2 = lines[line-1]
						local offset = line2Pos-line1Pos
						Utilities.fastSpawn(function()
							Utilities.Tween(.5, 'easeOutCubic', function(a)
								l1.Position = UDim2.new(0.12, 0, (line1Pos-a*offset-mbcOffset)/relSize, 0)
								l2.Position = UDim2.new(0.12, 0, (line2Pos-a*offset-mbcOffset)/relSize, 0)
							end)
							l1:remove()
						end)
						wait(.2)
					end
					overflow = write(str) {
						Size = lf.AbsoluteSize.Y,
						Frame = lf,
						Color = Color3.new(1, 1, 1),
						WritingToChatBox = true,
						AnimationRate = 35, -- ht / sec
					}

					if yesorno and not overflow then
						yesorno = false
						answer = BattleGui:promptYesOrNo()
					elseif line > 1 and overflow then
						wait(.5)
					elseif line ~= 1 or not overflow then
						wait(1)
					end
					str = overflow
				until not overflow
				msgBox.container:ClearAllChildren()
			end

			fadeOutMsgBox()
		end
		function BattleGui:message(...)
			for _, c in pairs({...}) do
				table.insert(msgQueue, c)
			end
			if not processingMsg then
				processingMsg = true
				processMessages()
				processingMsg = false
				msgsDone:fire()
			else
				while processingMsg do
					msgsDone:wait()
				end
			end
			return answer
		end
	end
	--

	do
		local sig, yon
		function BattleGui:promptYesOrNo()
			if not yon then
				sig = Utilities.Signal()
				yon = roundedFrame:new {
					Name = 'YesOrNoPrompt',
					BackgroundColor3 = Color3.new(.2, .2, .2),
					Size = UDim2.new(0.15, 0, 0.3, 0),
					Position = UDim2.new(0.7, 0, 0.45, 0),
					Parent = Utilities.frontGui,
				}
				write 'Yes' {
					Frame = create 'ImageButton' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.8, 0, 0.25, 0),
						Position = UDim2.new(0.1, 0, 0.175, 0),
						ZIndex = 2,
						Parent = yon.gui,
						MouseButton1Click = function()
							yon.Visible = false
							sig:fire(true)
						end,
					},
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Center,
				}
				write 'No' {
					Frame = create 'ImageButton' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.8, 0, 0.25, 0),
						Position = UDim2.new(0.1, 0, 0.575, 0),
						ZIndex = 2,
						Parent = yon.gui,
						MouseButton1Click = function()
							yon.Visible = false
							sig:fire(false)
						end,
					},
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Center,
				}
			end
			yon.CornerRadius = Utilities.gui.AbsoluteSize.Y*.05
			yon.Visible = true
			return sig:wait()
		end
	end

	BattleGui.toggleRemainingPartyGuis = require(script.RemainingPartyGui)(_p)
	--local transition = {
	--	
	--}

	function BattleGui:mainChoices(...)

		local args = {...}
		local rqPokemon, slot, nActive, moveLocked, isFirstValid, alreadySwitched, alreadyChoseMega, alreadyChoseZ = ...

		state = 'animating'
		self.isFirstUserPokemon = isFirstValid

		self.mainButtonClicked = function(name)

			if state ~= 'canchoosemain' then return end
			state = 'choosing'

			if name == 'Fight' then
				if moveLocked then
					self.inputEvent:fire('move 1')
					self:exitButtonsMain()
				else

					self:fightChoices(self.moves, rqPokemon, slot, nActive, alreadyChoseMega, alreadyChoseZ)
				end
			else
				pcall(function()
					gui.mega.selected = false
					gui.mega:Pause()
				end)
				if name == 'Run' then
					local battle = _p.Battle.currentBattle
					local battleKind = battle.kind
					if battleKind == 'pvp' or battleKind == '2v2' then

						spawn(function() self:exitButtonsMain() end)

						if self:message('[y/n]Are you sure you want to forfeit this match?') then
							local battle = _p.Battle.currentBattle
							battle:send('forfeit', battle.sideId)
							battle:setIdle()
						else
							return self:mainChoices(unpack(args)) --
						end
					elseif battleKind == 'wild' then
						spawn(function() self:exitButtonsMain() end)
						spawn(function() self:toggleRemainingPartyGuis(false) end)
						local escaped = _p.Network:get('BattleFunction', _p.Battle.currentBattle.battleId, 'tryRun')
						if escaped == 'partial' then
							self:message('You can\'t escape!')
							return self:mainChoices(unpack(args)) --
						elseif escaped then
							self.pickup = false
							self:message('You got away safely!')
							battle.ended = true
							battle.BattleEnded:fire()
						else
							self:message('You couldn\'t escape!')
							self:send('choose', self.sideId, {'pass'}, self.lastRequest.rqid)
							wait()
							self:setIdle()
						end
					else
						self:message('There\'s no running from a Trainer battle!')
						state = 'canchoosemain'
					end
				elseif name == 'Pokemon' then
					local switched = self:switchPokemon(nil, nil, alreadySwitched, slot)
					if not switched then
						return self:mainChoices(unpack(args)) --
					end
				elseif name == 'Bag' then
					if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' then
						state = 'canchoosemain'
						return
					end
					local sig = Utilities.Signal()
					spawn(function() self:exitButtonsMain() end)
					Menu.bag:open(sig)
					local res = sig:wait()
					if res == 'cancel' then

						return self:mainChoices(unpack(args)) --
					else
						self.inputEvent:fire(res)
						Menu.bag:close()
					end
				end
			end
		end
		local fight, bag, pokemon, run, container
		if gui.main then
			local main = gui.main
			fight, bag, pokemon, run, container = main.fight, main.bag, main.pokemon, main.run, main.container
		else
			container = create 'Frame' {
				Name = 'BattleGui',
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Size = UDim2.new(.25, 0, .25/522*130, 0),
				Parent = Utilities.gui,
			}
			local function onButtonClicked(name)
				self.mainButtonClicked(name)
			end
			local function b(name, labelColor, textColor)
				local label = create 'ImageLabel' { -- 522 x 130
					Name = name,
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://12097418726',--REPLACE THERES NOTHING HERE (GREY SCALE BUTTON IDK WHAT THAT IS)
					ImageColor3 = labelColor,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					ZIndex = 7,
					Parent = container,

					create 'ImageButton' {
						Name = 'Button',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.6, 0, 1.0, 0),
						Position = UDim2.new(0.2, 0, 0.0, 0),
						MouseButton1Click = function()
							onButtonClicked(name)
						end,
					}
				}
				if name == 'Fight' then
					create 'Frame' {
						Name = 'FighterIcon',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.7/522*130/3*4, 0, 0.7, 0),
						Position = UDim2.new(0.125, 0, 0.1, 0),
						Parent = label,
					}
				end
				write(name) {
					Frame = create 'Frame' {
						Name = 'txt',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 0.5, 0),
						Position = UDim2.new(0.0, 0, 0.25, 0),
						Parent = label,
						ZIndex = 8,
					},
					Scaled = true,
					Color = textColor,
				}
				return label
			end
			fight = b('Fight', Color3.new(1, .4, .4), Color3.new(.4, .15, .15))
			bag = b('Bag', Color3.new(1, .8, .4), Color3.new(.4, .25, .15))
			pokemon = b('Pokemon', Color3.new(.4, 1, .8), Color3.new(.15, .4, .25))
			run = b('Run', Color3.new(.4, .8, 1), Color3.new(.15, .25, .4))
			gui.main = {
				fight = fight,
				bag = bag,
				pokemon = pokemon,
				run = run,
				container = container,
			}
			local cancel = create 'ImageLabel' { -- 522 x 130
				Name = 'Cancel',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://12097418726',
				ImageColor3 = Color3.new(.25, 1, 1),
				Size = UDim2.new(1.0, 0, 1.0, 0),
				Parent = container,
				Visible = false,

				create 'ImageButton' {
					Name = 'Button',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.6, 0, 1.0, 0),
					Position = UDim2.new(0.2, 0, 0.0, 0),
					MouseButton1Click = function()
						if state == 'canchoosemain' then
							--						print('cancel to previous')
							self:cancelToPreviousPokemon()
						elseif state == 'canchoosemove' then
							self:cancelToMain()
						elseif state == 'canchoosetarget' then
							self:cancelToMoves()
						end
					end,
				}
			}
			write 'Cancel' {
				Frame = create 'Frame' {
					Name = 'txt',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.5, 0),
					Position = UDim2.new(0.0, 0, 0.25, 0),
					Parent = cancel,
				},
				Scaled = true,
				Color = Color3.new(.1, .4, .4),
			}
			gui.cancel = cancel

			local origin = UDim2.new(.65, 0, 0.0, 0)
			local pfn
			if Utilities.isPhone() then
				origin = UDim2.new(.5, 0, .7, 0)
				container.Size = UDim2.new(.35, 0, .35/522*130, 0)
				pfn = function()
					container.Position = origin + UDim2.new(-container.Size.X.Scale/2, 0, 0.0, -container.AbsoluteSize.Y/2)
				end
			else
				pfn = function(depth)
					container.Position = origin + UDim2.new(-container.Size.X.Scale/2, 0, 0.0, Utilities.gui.AbsoluteSize.Y-container.AbsoluteSize.Y*1.75)
					spawn(function()
						-- fix Windows Restore bug
						if (not depth or depth < 5) and container.AbsolutePosition.Y + container.AbsoluteSize.Y*1.5 > Utilities.gui.AbsoluteSize.Y then
							pfn((depth or 1) + 1)
						end
					end)
				end
			end
			Utilities.gui.Changed:connect(function(prop)
				if prop ~= 'AbsoluteSize' then return end
				--			print(Utilities.gui.AbsoluteSize)
				pfn()
			end)
			pfn()
		end
		container.Parent = Utilities.gui
		fight.Visible, bag.Visible, pokemon.Visible, run.Visible = true, true, true, true
		if isFirstValid then
			if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' then
				bag.Visible = false
				if run.Name ~= 'Forfeit' then
					run.Name = 'Forfeit'
					run.txt:ClearAllChildren()
					write 'Forfeit' {
						Frame = run.txt,
						Scaled = true,
						Color = Color3.new(.15, .25, .4),
					}
				end
			else
				if run.Name ~= 'Run' and run == gui.run then
					run.Name = 'Run'
					run.txt:ClearAllChildren()
					write 'Run' {
						Frame = run.txt,
						Scaled = true,
						Color = Color3.new(.15, .25, .4),
					}
				end
			end
		else
			if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' then
				bag.Visible = false
			end
			run.Visible = false
			run = gui.cancel
			run.Visible = true
		end
		pcall(function() self.fighterIcon.Parent = nil end)
		fight.FighterIcon:ClearAllChildren()
		pcall(function()
			self.fighterIcon.ZIndex = 9
			self.fighterIcon.Parent = fight.FighterIcon
		end)
		container.Visible = true
		spawn(function() self:toggleRemainingPartyGuis(true) end)
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			container.Visible = true -- temp fix for double battle input bug
			local o = 1-a
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*o)
			run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*o)
			bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*o, 0.0, 0)
			pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*o, 0.0, 0)
		end)
		state = 'canchoosemain'
	end

	function BattleGui:chooseMoveTarget(moveNum, move, rqPokemon, userPosition, nActive)
		state = 'animating'
		--	local target = _p.DataManager:getData('Movedex', move.id).target
		-- Targets:
		-- { foe  foe  foe 
		--   me  ally ally }
		-- 0 = unable
		-- 1 = can
		-- 2 = must
		local validTargets = ({
			normal				=  {1, 1, 0,
				0, 1, 0},
			allAdjacentFoes 		=  {2, 2, 2,
				0, 0, 0},
			self					=  {0, 0, 0,
				1, 0, 0},
			all					=  {2, 2, 2,
				2, 2, 2},
			allAdjacent			=  {2, 2, 0,
				0, 2, 0},
			allySide				=  {0, 0, 0,
				2, 2, 2},
			any					=  {1, 1, 1,
				0, 1, 1},
			scripted				=  {0, 0, 0,
				1, 0, 0},
			randomNormal			=  {0, 0, 0,
				1, 0, 0},
			foeSide				=  {2, 2, 2,
				0, 0, 0},
			adjacentAlly			=  {0, 0, 0,
				0, 1, 0},
			allyTeam				=  {0, 0, 0,
				2, 2, 2},
			adjacentFoe			=  {1, 1, 0,
				0, 0, 0},
			adjacentAllyOrSelf	=  {0, 0, 0,
				1, 1, 0},
		})[move.target]

		local function getTokenForPosition(bn)
			if nActive == 2 then
				if bn == 2 or bn == 5 then return 0 end
				local p = bn + (bn%3==0 and -1 or 0)
				if userPosition == 2 then
					p = (p>3 and 9 or 3) - p
				end
				return validTargets[p]
			elseif nActive == 3 then
				-- todo
			end
			return 0
		end

		local main = gui.main
		local cancel = gui.cancel
		local container = gui.targetContainer--main.container
		local targets = gui.targets
		local moves = gui.moves
		local selectedMove = moves[moveNum]


		self.onTargetClicked = function(n)
			if state ~= 'canchoosetarget' then return end
			if getTokenForPosition(n) > 0 then
				state = 'animating'
				local t = n>3 and 3-n or 4-n
				if nActive == 2 then
					if t == 3 then t = 2
					elseif t == -3 then t = -2 end
				end
				self.inputEvent:fire('move '..moveNum..(gui.mega.selected and ' mega ' or ' ')..t)

				-- transition the targets (& chosen move) away after choosing target
				Utilities.Tween(.6, 'easeOutCubic', function(a)
					selectedMove.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+selectedMove.AbsoluteSize.Y+36)*a)
					local l = (container.AbsolutePosition.X+targets[1].AbsoluteSize.X)*a
					targets[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
					targets[4].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
					local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+targets[3].AbsoluteSize.Y)*a
					targets[3].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
					targets[6].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
					-- todo 2, 5
					cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+cancel.AbsoluteSize.Y)*a)
				end)
				gui.mega.selected = false
				gui.mega:Pause()
				container.Parent = nil
			end
		end

		if not targets then
			container = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 1.0, 0),
			}
			targets = {false, false, false, false, false, false}
			for i = 1, 6 do
				targets[i] = create 'ImageLabel' { -- 522 x 130
					Name = 'Move'..i,
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://12097418726',
					ImageColor3 = BrickColor.new('Bright orange').Color,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					ZIndex = 2, Parent = container,

					create 'ImageButton' {
						Name = 'Button',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.6, 0, 1.0, 0),
						Position = UDim2.new(0.2, 0, 0.0, 0),
						ZIndex = 7,
						MouseButton1Click = function()
							if state ~= 'canchoosetarget' then return end
							self.onTargetClicked(i)
						end,
					},
					create 'Frame' {
						Name = 'NameContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.4, 0),
						Position = UDim2.new(0.5+0.7/522*130/3*4/4, 0, 0.3, 0),
						ZIndex = 3,
					},
					create 'ImageLabel' { -- 537x140
						Name = 'HighlightIcon',
						Image = 'rbxassetid://11106505014',
						ImageColor3 = BrickColor.new('Cyan').Color,
						BackgroundTransparency = 1.0,
						Size = UDim2.new(537/522, 0, 140/130, 0),
						Position = UDim2.new(-6/522, 0, -5/130, 0),
					},
				}
			end
			gui.targets = targets
			gui.targetContainer = container
		end
		container.Parent = main.container
		targets[4].ImageColor3 = BrickColor.new('Dark green').Color
		targets[5].ImageColor3 = BrickColor.new('Dark green').Color
		targets[6].ImageColor3 = BrickColor.new('Dark green').Color
		local function updateTargetButton(bNum, pokemon)
			local token = getTokenForPosition(bNum)
			local button = targets[bNum]
			local transparency = token>0 and 0.0 or 0.5
			button.NameContainer:ClearAllChildren()
			button.ImageTransparency = transparency
			button.HighlightIcon.Visible = token==2
			if not pokemon or pokemon.isNull then return end
			local f = write(pokemon:getShortName()) {
				Frame = button.NameContainer,
				Scaled = true,
				Color = Color3.new(button.ImageColor3.r*.35, button.ImageColor3.g*.35, button.ImageColor3.b*.35),
				Transparency = transparency
			}.Frame
			local icon = pokemon:getIcon()
			if icon then
				local s = .5/.3
				icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
				icon.Size = UDim2.new(-s/3*4, 0, s, 0)
				icon.Position = UDim2.new(0.0, 0, -(s-1)/2, 0)
				icon.ImageTransparency = transparency
				icon.Parent = f
			end
		end
		if nActive == 2 then
			targets[2].Visible = false
			targets[5].Visible = false
			targets[3+userPosition+(userPosition==2 and 1 or 0)].ImageColor3 = BrickColor.new('Bright green').Color
			local battle = _p.Battle.currentBattle
			updateTargetButton(1, battle.yourSide.active[2])
			updateTargetButton(3, battle.yourSide.active[1])
			updateTargetButton(4, battle.mySide.active[1])
			updateTargetButton(6, battle.mySide.active[2])
		else
			targets[2].Visible = true
			targets[5].Visible = true
			targets[3+userPosition].ImageColor3 = BrickColor.new('Bright green').Color
			local battle = _p.Battle.currentBattle
			updateTargetButton(1, battle.yourSide.active[3])
			updateTargetButton(2, battle.yourSide.active[2])
			updateTargetButton(3, battle.yourSide.active[1])
			updateTargetButton(4, battle.mySide.active[1])
			updateTargetButton(5, battle.mySide.active[2])
			updateTargetButton(6, battle.mySide.active[3])
		end
		local fight, ms = main.fight, gui.mega.spriteLabel
		local spx, spy = selectedMove.Position.X.Scale, selectedMove.Position.Y.Scale
		local epy = -135/130/2

		-- transition the targets (& chosen move) in after choosing the move; other moves out
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = 1-a
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*a)
			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
			moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
			moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)

			selectedMove.Position = UDim2.new(spx*o, 0, spy + (epy-spy)*a, 0)
			l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*o
			targets[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			targets[4].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*o
			targets[3].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			targets[6].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			-- todo 2, 5
		end)

		self.selectedMoveNum = moveNum
		state = 'canchoosetarget'
	end

	function BattleGui:cancelToPreviousPokemon()
		self.inputEvent:fire('back')
		self:exitButtonsMain()
		pcall(function()
			gui.mega.selected = false
			gui.mega:Pause()
		end)
	end

	function BattleGui:cancelToMoves()
		state = 'animating'
		local moveNum = self.selectedMoveNum
		local targets = gui.targets
		local moves = gui.moves
		local main = gui.main
		local container = main.container
		local fight, ms = main.fight, gui.mega.spriteLabel
		local selectedMove = moves[moveNum]
		local spx, spy = selectedMove.Position.X.Scale, selectedMove.Position.Y.Scale
		local p = ({Vector2.new(-424/522, -134/130),
			Vector2.new(424/522, -134/130),
			Vector2.new(-424/522, 0.0),
			Vector2.new(424/522, 0.0),
		})[moveNum]
		local epx, epy = p.X, p.Y
		-- transition back to moves from target selection after canceling
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = a; a = 1-a
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*a)
			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
			moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
			moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)

			selectedMove.Position = UDim2.new(spx + (epx-spx)*o, 0, spy + (epy-spy)*o, 0)
			l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*o
			targets[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			targets[4].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*o
			targets[3].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			targets[6].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			-- todo 2, 5
		end)
		state = 'canchoosemove'
	end

	function BattleGui:exitButtonsMain()
		state = 'animating'
		local main = gui.main
		local fight, bag, pokemon, run, container = main.fight, main.bag, main.pokemon, main.run, main.container
		if not run.Visible then
			run = gui.cancel
		end
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*a)
			run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*a)
			bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*a, 0.0, 0)
			pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*a, 0.0, 0)
		end)
		container.Visible = false

		state = 'idle'
	end

	function BattleGui:updateButtonForMove(button, move)
		button.MoveNameContainer:ClearAllChildren()
		button.TypeContainer:ClearAllChildren()
		button.PPContainer:ClearAllChildren()

		if not move then
			button.ImageColor3 = Color3.new(.5, .5, .5)
			button.ImageTransparency = 0.5
			return
		end
		--	--print(move)
		local tc = typeColors[move.type]
		--	print(tc)
		button.ImageColor3 = tc;-- Color3.fromRGB();
		button.ImageTransparency = 0.0
		button.Image = 'rbxassetid://12097418726'
		button.Position = UDim2.new(-1,0,0,0)
		write(move.move or move.name) {
			Frame = button.MoveNameContainer,
			Scaled = true,
		}
		write(move.type) {
			Frame = button.TypeContainer,
			Color = Color3.new(tc.r*1.2, tc.g*1.2, tc.b*1.2),
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
		}
		write('PP '..move.pp..'/'..move.maxpp) {
			Frame = button.PPContainer,
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
	end

	function BattleGui:fightChoices(moveset, rqPokemon, slot, nActive, alreadyChoseMega, alreadyChoseZ)

		--print('Animating')

		state = 'animating'
		self.onMoveClicked = function(m)
			local move = self.moves[m]
			if not move then return end
			if move.pp <= 0 then
				state = 'canteven'
				self:message('There\'s no PP left for this move!')
				state = 'canchoosemove'
				return
			elseif move.disabled then
				state = 'canteven'
				self:message('This move cannot be used!')
				state = 'canchoosemove'
				return
			end

			if nActive > 1 then
				self:chooseMoveTarget(m, move, rqPokemon, slot, nActive)
			else
				self.inputEvent:fire('move '..m..((gui.mega.selected and ' mega') or ''))
				self:exitButtonsMoveChosen()
			end
		end
		local main = gui.main
		local container = main.container
		local moves, mega, cancel = gui.moves, gui.mega, gui.cancel

		--if moves then print("RUH ROH."); end;

		if not moves then
			moves = {false, false, false, false}
			for i = 1, 4 do
				moves[i] = create 'ImageLabel' { -- 522 x 130
					Name = 'Move'..i,
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://12097418726',
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Parent = container,

					create 'ImageButton' {
						Name = 'Button',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.6, 0, 1.0, 0),
						Position = UDim2.new(0.2, 0, 0.0, 0),
						ZIndex = 7,
						MouseButton1Click = function()
							if state ~= 'canchoosemove' then return end
							self.onMoveClicked(i)
						end,
					},
					create 'Frame' {
						Name = 'MoveNameContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.4, 0),
						Position = UDim2.new(0.5, 0, 0.09, 0),
						ZIndex = 8,
					},
					create 'Frame' {
						Name = 'TypeContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.25, 0),
						Position = UDim2.new(0.4, 0, 0.585, 0),
						ZIndex = 8,
					},
					create 'Frame' {
						Name = 'PPContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.25, 0),
						Position = UDim2.new(0.5, 0, 0.585, 0),
						ZIndex = 8,
					},
				}
			end
			gui.moves = moves

			-- #MEGA
			mega = _p.AnimatedSprite:new{sheets={{id=456223912,rows=10}},nFrames=20,fWidth=393,fHeight=99,framesPerRow=2,button=true}
			mega:RenderFirstFrame()
			mega.selected = false

			local s = mega.spriteLabel
			s.Size = UDim2.new(1.0, 0, 1.0, 0)
			s.Visible = false
			s.Parent = container
			local megaWrittenWord = write 'Mega' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					--				Size = UDim2.new(1.0, 0, 0.5, 0),
					--				Position = UDim2.new(0.0, 0, 0.25, 0),
					Size = UDim2.new(0.0, 0, 0.38, 0),
					Position = UDim2.new(0.5, 0, 0.09, 0),
					ZIndex = 8, Parent = s,
				}, Scaled = true,
			}
			local letters = {}
			local evolutionWrittenWord = write 'Evolution' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.275, 0),
					Position = UDim2.new(0.5, 0, 0.585, 0),
					ZIndex = 8, Parent = s,
				}, Scaled = true,
			}
			--		assert(container.Parent ~= nil, ':l')
			for _, l in pairs(megaWrittenWord.Labels) do
				local p = (l.AbsolutePosition.X - s.AbsolutePosition.X) / s.AbsoluteSize.X
				letters[l] = p
			end
			for _, l in pairs(evolutionWrittenWord.Labels) do
				local p = (l.AbsolutePosition.X - s.AbsolutePosition.X) / s.AbsoluteSize.X
				letters[l] = p
			end
			mega.updateCallback = function(a)
				if a then
					local hue_center = a+.25
					for l, p in pairs(letters) do
						l.ImageColor3 = Color3.fromHSV((hue_center + (p-.5)*.4)%1, .75, 1)
					end
				else
					local c = Color3.new(1, 1, 1)--Color3.fromRGB(255, 102, 75)--BrickColor.new('Crimson').Color
					for l in pairs(letters) do
						l.ImageColor3 = c
					end
				end
			end
			s.MouseButton1Click:connect(function()
				if mega.paused then
					mega.selected = true
					mega:Play()
				else
					mega.selected = false
					mega:Pause()
					mega.updateCallback(nil)
				end
			end)
			gui.mega = mega
		end
		local fight, bag, pokemon, run = main.fight, main.bag, main.pokemon, main.run
		local moveCancel = run.Visible
		cancel.Visible = true
		for i = 1, 4 do
			self:updateButtonForMove(moves[i], moveset[i])
			moves[i].Visible = true
		end
		if rqPokemon and rqPokemon.canMegaEvo and not alreadyChoseMega then
			mega.spriteLabel.Visible = true
			--		mega:Play(1)
			mega.updateCallback(nil)
		else
			mega.spriteLabel.Visible = false
			--		mega:Pause()
		end

		local ms = mega.spriteLabel
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = 1-a
			run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*a)
			bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*a, 0.0, 0)
			pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*a, 0.0, 0)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*o)

			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*o
			moves[1].Position = UDim2.new(-424/522, 0, -135/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*o
			moves[2].Position = UDim2.new(424/522, 0, -135/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			if moveCancel then
				cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*o)
			end
		end)
		bag.Visible, pokemon.Visible, run.Visible = false, false, false
		state = 'canchoosemove'
	end

	function BattleGui:exitButtonsMoveChosen()
		state = 'animating'
		local main = gui.main
		local fight, ms = main.fight, gui.mega.spriteLabel
		local container = main.container
		local moves, cancel = gui.moves, gui.cancel
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = 1-a
			fight.Position = UDim2.new(0.0, 0, -135/130/2, 0) + UDim2.new(0.0, 0, 0.0, -(container.AbsolutePosition.Y+fight.AbsoluteSize.Y+36)*a)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y*2+36)*a)
			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
			moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
			moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+cancel.AbsoluteSize.Y)*a)
		end)
		gui.mega.selected = false
		gui.mega:Pause()
		for i = 1, 4 do
			moves[i]:Remove();
		end

		moves = nil;
		gui.moves = nil;
		container.Visible = false
		state = 'canchoosemain'
	end

	function BattleGui:cancelToMain()
		state = 'animating'
		local main = gui.main
		local fight, bag, pokemon, run = main.fight, main.bag, main.pokemon, main.run
		local container = main.container
		local moves, ms, cancel = gui.moves, gui.mega.spriteLabel, gui.cancel
		local canRun = self.isFirstUserPokemon
		bag.Visible, pokemon.Visible, run.Visible = true, true, canRun
		if _p.Battle.currentBattle.kind == 'pvp' or _p.Battle.currentBattle.kind == '2v2' then
			bag.Visible = false
		end
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			local o = 1-a
			if canRun then
				run.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+run.AbsoluteSize.Y)*o)
				cancel.Position = UDim2.new(0.0, 0, 135/130/2, 0) + UDim2.new(0.0, 0, 0.0, (Utilities.gui.AbsoluteSize.Y-container.AbsolutePosition.Y+cancel.AbsoluteSize.Y)*a)
			end
			bag.Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -(container.AbsolutePosition.X+bag.AbsoluteSize.X)*o, 0.0, 0)
			pokemon.Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+pokemon.AbsoluteSize.Y)*o, 0.0, 0)
			local l = (container.AbsolutePosition.X+moves[1].AbsoluteSize.X)*a
			moves[1].Position = UDim2.new(-424/522, 0, -134/130, 0) + UDim2.new(0.0, -l, 0.0, -l*.4)
			moves[3].Position = UDim2.new(-424/522, 0, 0.0, 0) + UDim2.new(0.0, -l, 0.0, l*.4)
			local r = (Utilities.gui.AbsoluteSize.X-container.AbsolutePosition.X+moves[2].AbsoluteSize.Y)*a
			moves[2].Position = UDim2.new(424/522, 0, -134/130, 0) + UDim2.new(0.0, r, 0.0, -r*.4)
			moves[4].Position = UDim2.new(424/522, 0, 0.0, 0) + UDim2.new(0.0, r, 0.0, r*.4)
			ms.Position = UDim2.new(0.0, 0, -136/130*3/2, -(container.AbsolutePosition.Y+ms.AbsoluteSize.Y+36)*a)
		end)
		for i = 1, 4 do
			moves[i]:Remove();
		end

		moves = nil;
		gui.moves = nil;

		-- todo mega.visible = false
		state = 'canchoosemain'
	end

	function BattleGui:chooseSwitchSlot(options, fromSlot)
		local bg = create 'ImageButton' {
			AutoButtonColor = false,
			BackgroundTransparency = .4,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			ZIndex = 4, Parent = Utilities.frontGui,
		}
		local s = 0.2
		local container = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(s*4.5/3, 0, s, 0),
			Position = UDim2.new(0.5, 0, 0.5-s/2, 0),
			Parent = Utilities.frontGui,
		}
		write 'Switch to which position?' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.4, 0),
				Position = UDim2.new(0.0, 0, -1.5, 0),
				ZIndex = 5, Parent = container,
			}, Scaled = true,
		}
		local sig = Utilities.Signal()
		local battle = _p.Battle.currentBattle
		local rfs = {}
		local cancel = roundedFrame:new {
			Button = true,
			CornerRadius = Utilities.gui.AbsoluteSize.Y*.024,
			BackgroundColor3 = BrickColor.new('Bright red').Color,
			Size = UDim2.new(0.85, 0, 0.55, 0),
			Position = UDim2.new(-0.425, 0, 1.7, 0),
			ZIndex = 5, Parent = container,
			MouseButton1Click = function()
				sig:fire()
			end,
		}
		write 'Cancel' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.5, 0),
				Position = UDim2.new(0.0, 0, 0.25, 0),
				ZIndex = 6, Parent = cancel.gui,
			}, Scaled = true,
		}
		for s = 1, 2 do
			for a = 1, #options do
				local onClick
				if s == 1 and options[a] then
					onClick = function()
						sig:fire(a)
					end
				end
				local rf = roundedFrame:new {
					Button = onClick~=nil,
					CornerRadius = Utilities.gui.AbsoluteSize.Y*.03,
					BackgroundColor3 = Color3.new(.6, .6, .6),
					Size = UDim2.new(4/4.5, 0, 1.0, 0),
					ZIndex = 5, Parent = container,
					MouseButton1Click = onClick,
				}
				if s == 1 then
					rf.Position = UDim2.new(-(#options+1)/2+a-0.5+(1-4/4.5)/2, 0, 0.55, 0)
					if options[a] then
						rf.BackgroundColor3 = BrickColor.new('Dark green').Color
					else
						pcall(function()
							local p = battle.mySide.active[a]
							if p and p.hp > 0 then
								local icon = p:getIcon()
								icon.Size = UDim2.new(0.6, 0, 0.6, 0)
								icon.Position = UDim2.new(0.2, 0, 0.2, 0)
								icon.ZIndex = 6
								icon.Parent = rf.gui
							end
						end)
					end
				else
					rf.Position = UDim2.new((#options+1)/2-a-0.5+(1-4/4.5)/2, 0, -0.55, 0)
					pcall(function()
						local p = battle.yourSide.active[a]
						if p and p.hp > 0 then
							local icon = p:getIcon()
							icon.Size = UDim2.new(0.6, 0, 0.6, 0)
							icon.Position = UDim2.new(0.2, 0, 0.2, 0)
							icon.ZIndex = 6
							icon.Parent = rf.gui
						end
					end)
				end
				table.insert(rfs, rf)
			end
		end
		local r = sig:wait()
		for _, rf in pairs(rfs) do
			rf:remove()
		end
		container:remove()
		bg:remove()
		return r
	end

	function BattleGui:choosePokemon(selectionText, cannotCancel) -- yay for ugly hacks
		Menu.party.selectionText = selectionText
		local s = self:switchPokemon(cannotCancel and true or false)
		Menu.party.selectionText = nil
		return s
	end

	function BattleGui:switchPokemon(forced, chooseSlot, alreadySwitched, toSlot)
		local sig = Utilities.Signal()
		Menu.party.battleEvent = sig
		spawn(function()
			-- ugly hack, BUT much less ugly with PDS up-to-date-with-battle party data
			if self.side then
				local nActive = self.side.nTeamActive or self.side.nActive -- OVH  one reason we need to keep side
				Menu.party.nActive = nActive
			else
				Menu.party.partyOrder = nil
				Menu.party.nActive = 0
			end
			Menu.party.alreadySwitched = alreadySwitched
			Menu.party.forceSwitch = forced
			Menu.party.chooseItemTarget = false
			Menu.party:open()
		end)
		spawn(function()
			if forced or not gui or not gui.main then return end
			local container = gui.main.container
			container.Parent = Utilities.backGui
			self:exitButtonsMain()
			container.Parent = Utilities.gui
		end)
		while true do
			local res, slot = sig:wait()
			if res == 'cancel' then
				spawn(function() Menu.party:close() end)
				if not forced then return false end
			elseif res == 'switch' then
				if Menu.party.selectionText then
					--				local partyData = Menu.party.partyData
					Menu.party:close()
					return slot--, partyData
				else
					local partyData = Menu.party.partyData
					local poke = partyData[slot]
					local pokemonSwitchingOut, pokemonSwitchingOutIsTrapped, pokemonSwitchingOutIsMaybeTrapped
					pcall(function()
						local activeMon = _p.Battle.currentBattle.fulfillingRequest.active[toSlot]
						pokemonSwitchingOut = partyData[toSlot] -- no longer a Pokemon object
						pokemonSwitchingOutIsTrapped = activeMon.trapped and true or false
						pokemonSwitchingOutIsMaybeTrapped = activeMon.maybeTrapped and true or false
					end)
					if poke.egg then -- OVH  todo: test these cases
						self:message('You can\'t send an Egg into battle!')
					elseif poke.hp <= 0 then
						self:message(poke.name .. ' has no energy left to battle!')
					elseif pokemonSwitchingOutIsTrapped then
						self:message(pokemonSwitchingOut.name .. ' is trapped! It can\'t escape!')
					else
						local isTrapped = false
						if pokemonSwitchingOutIsMaybeTrapped then -- OVH  todo: test this
							local battle = _p.Battle.currentBattle
							local t, s, e = _p.Network:get('BattleFunction', battle.battleId, 'isTrapped', battle.sideId, toSlot)
							isTrapped = t
							local msg = false
							if t and s and e and e ~= '' then
								local poke = battle:getPokemon(s)
								if poke then
									msg = true
									self:message(poke:getName() .. '\'s ' .. e .. ' prevents switching!')
								end
							end
							if t and not msg then
								-- backup generic message
								self:message(pokemonSwitchingOut.name .. ' is trapped! It can\'t escape!')
							end
						end
						if not isTrapped then
							local fixedSlot = slot
							if self.side and self.side.indexFix and poke.bindex then
								fixedSlot = self.side.indexFix[poke.bindex]
								print(string.format('slot: %d; index: %d; b_index: %d; slot_fix: %d', slot or -1, poke.index or -1, poke.bindex or -1, fixedSlot or -1))
								Utilities.print_r(self.side.indexFix)
							else
								print('slot:', slot or -1, '[no fix]')
							end
							if chooseSlot then -- multiple faints, need to choose which slot to fill
								local toSlot = self:chooseSwitchSlot(forced, slot) -- I think this is correct usage
								if toSlot then
									self.inputEvent:fire('switch '..fixedSlot, toSlot)
									Menu.party:close()
									return true
								end
							else
								self.inputEvent:fire('switch '..fixedSlot)
								Menu.party:close()
								return true
							end
						end
					end
				end
			end
		end
	end

	function BattleGui:afterBattle()
		spawn(function() self:toggleRemainingPartyGuis(false) end)
		pcall(function() gui.main.container.Parent = nil end)
		pcall(function() gui.targetContainer.Parent = nil end)
		local s = Utilities.gui.AbsoluteSize
		local p = UDim2.new(10.0, s.X*3, 10.0, s.Y*3)
		pcall(function()
			for i = 1, 4 do
				gui.moves[i].Position = p
			end
		end)
		pcall(function() gui.cancel.Position = p end)
	end

	function BattleGui:createFoeHealthGui(nActive, slot)
		local yPos = 0.15
		local hg = {}
		function hg:evalYPos(checkSlot)
			if checkSlot then
				pcall(function() slot = hg.pokemon.slot or slot end)
			end
			yPos = 0.15
			if slot == 2 then
				yPos = 0.025
			end
		end
		hg:evalYPos()
		local isPhone = Utilities.isPhone()
		local hpg = isPhone and 1 or 2
		hg.main = create 'Frame' {--create 'ImageLabel' { --roundedFrame:new {
			Name = 'FoeHealthGui',
			BackgroundTransparency = 1.0,

			--		CornerRadius = Utilities.gui.AbsoluteSize.Y*0.04,
			--		BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = UDim2.new(-0.45, 0, 0.1, 0),
			Position = UDim2.new(0.975, 0, yPos, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Parent = Utilities.backGui,
			Visible = false,

			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://12097137045',
				ImageColor3 = Color3.new(.5, .5, .5),
				Size = UDim2.new(1.0, 0, 1.2, 0),
				Position = UDim2.new(.02, 0, 0.0, 0)
			},

			create 'Frame' {
				Name = 'NameContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.35, 0),
				Position = UDim2.new(0.05, 0, 0.125, 0),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'GenderContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.7, 0, 0.22, 0),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'LevelContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.75, 0, 0.22, 0),
				ZIndex = 4,
			},
			create 'ImageLabel' {
				Name = 'OwnedIcon',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6142797841',--no clue what this is, ownedicon?
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.3, 0, 0.3, 0),
				Position = UDim2.new(0.08, 0, 0.6, 0),
				ZIndex = 4,
				Visible = false,
			},
		}
		hg.hpdiv = roundedFrame:new {
			Name = 'hpdiv',
			BackgroundColor3 = Color3.new(.7, .7, .7),
			Size = UDim2.new(0.75, 0, 0.3, 0),
			Position = UDim2.new(0.2, 0, 0.6, 0),
			Style = 'HorizontalBar',
			ZIndex = 4,
			Parent = hg.main,--.gui,

			create 'Frame' {
				Name = 'text',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 1.0, -hpg*2),
				Position = UDim2.new(0.12, 0, 0.0, hpg),
				ZIndex = 5,
			},
		}
		hg.statusrf = roundedFrame:new {
			Name = 'status',
			Size = UDim2.new(0.15, 0, 0.25, 0),
			Position = UDim2.new(0.025, 0, 0.625, 0),
			Style = 'HorizontalBar',
			ZIndex = 4,
			Parent = hg.main,--.gui,

			create 'Frame' {
				Name = 'text',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.8, 0),--1.0, -hpg*2),
				Position = UDim2.new(0.5, 0, 0.1, 0),--0.0, hpg),
				ZIndex = 5,
			},
		}
		hg.hpfill = roundedFrame:new {
			Name = 'container',
			BackgroundColor3 = Color3.new(.9, .9, .9),
			Size = UDim2.new(0.8, -hpg*2, 1.0, -hpg*2),
			Position = UDim2.new(0.2, hpg, 0.0, hpg),
			Style = 'HorizontalBar',
			ZIndex = 5,
			Parent = hg.main--[[.gui]].hpdiv,
		}
		hg.hpfill:setupFillbar('gyr', hpg)
		write 'HP' {
			Frame = hg.main--[[.gui]].hpdiv.text,
			Color = Color3.new(.3, .3, .3),
			Scaled = true,
		}
		--	local resizeCn = Utilities.gui.Changed:connect(function(prop)
		--		if prop ~= 'AbsoluteSize' then return end
		--		hg.main.CornerRadius = Utilities.gui.AbsoluteSize.Y*0.04
		--	end)
		function hg:update(pokemon)
			pokemon = pokemon or self.pokemon
			local gui = self.main--.gui
			gui.NameContainer:ClearAllChildren()
			gui.GenderContainer:ClearAllChildren()
			gui.LevelContainer:ClearAllChildren()
			gui.status.text:ClearAllChildren()
			-- name
			write(pokemon:getShortName()) {
				Frame = gui.NameContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
			-- gender
			local show = (pokemon.data and pokemon.data.num ~= 29 and pokemon.data.num ~= 32) or (pokemon.species and pokemon.species ~= 'nidoranf' and pokemon.species ~= 'nidoranm')
			if show and pokemon.gender and pokemon.gender ~= '' then
				write('['..pokemon.gender:upper()..']') {
					Frame = gui.GenderContainer,
					Color = pokemon.gender=='F' and Color3.new(1, .44, .81) or BrickColor.new('Cyan').Color,
					Scaled = true,
				}
			end
			-- level
			write(pokemon.level == 100 and 'Lv.100' or 'Lv. '..pokemon.level) {
				Frame = gui.LevelContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
			-- hp
			self.hpfill:setFillbarRatio(pokemon.hp/pokemon.maxhp)
			-- status
			local statuses = {
				brn = {'BRN', Color3.new(238/255,  70/255,  44/255)},-- Color3.new(222/255, 23/255, 31/255)},
				frz = {'FRZ', Color3.new(179/255,       1, 240/255)},
				par = {'PAR', Color3.new(240/255, 203/255,  67/255)},
				psn = {'PSN', Color3.new(175/255, 106/255, 206/255)},
				tox = {'PSN', Color3.new(111/255,   9/255,  95/255), Color3.new(188/255, 153/255, 205/255)},
				slp = {'SLP', Color3.new(160/255, 185/255, 175/255)},
			}
			local status = pokemon.status
			if status then
				status = status:match('^(%D+)')
			end
			local s = statuses[status]
			local sf = self.statusrf
			if not s then
				sf.Visible = false
			else
				sf.Visible = true
				sf.BackgroundColor3 = s[2]
				write(s[1]) {
					Frame = sf.gui.text,
					Scaled = true,
					Color = s[3],
				}
			end
			-- owned
			gui.OwnedIcon.Visible = not sf.Visible and pokemon.owned
		end
		function hg:animateHP(fromHp, toHp, maxhp)
			self.animating = true
			self.hpfill:setFillbarRatio(toHp/maxhp, true)
			self.animating = false
			self.lastAnimTime = tick()
		end
		function hg:setHP(hp, maxhp)
			self.hpfill:setFillbarRatio(hp/maxhp)
		end
		function hg:setOwned(owned)
			self.main--[[.gui]].OwnedIcon.Visible = owned
		end
		function hg:slideOnscreen()
			spawn(function()
				self.main.Visible = true
				Utilities.Tween(.6, 'easeOutCubic', function(a)
					self.main.Position = UDim2.new(0.975+0.025*(1-a), math.abs(self.main.AbsoluteSize.X)*(1-a), yPos, 0)
				end)
			end)
		end
		function hg:slideOffscreen(delete)
			spawn(function()
				Utilities.Tween(.6, 'easeOutCubic', function(a)
					self.main.Position = UDim2.new(0.975+0.025*a, math.abs(self.main.AbsoluteSize.X)*a, yPos, 0)
				end)
				self.main.Visible = false
				if delete then
					self:remove()
				end
			end)
		end
		function hg:remove()
			self.pokemon = nil
			--		resizeCn:disconnect()
			pcall(function() self.statusrf:remove() end)
			pcall(function() self.hpdiv:remove() end)
			pcall(function() self.hpfill:remove() end)
			self.main:remove()
		end
		return hg
	end

	function BattleGui:createUserHealthGui(nActive, slot)
		local ys = 1.4
		local yPos = 0.3
		local hg = {}
		function hg:evalYPos(checkSlot)
			if checkSlot then
				pcall(function() slot = hg.pokemon.slot or slot end)
			end
			yPos = 0.3
			if nActive == 2 then
				if slot == 1 then
					yPos = 1-0.45/6-.0625-.2*ys
				elseif slot == 2 then
					yPos = 1-0.45/6-.0325-.1*ys
				end
			end
		end
		hg:evalYPos()
		local isPhone = Utilities.isPhone()
		local hpg = isPhone and 1 or 2
		hg.main = create 'Frame' {--'ImageLabel' {--roundedFrame:new {
			BackgroundTransparency = 1.0,
			--		Image = 'rbxassetid://',

			Name = 'UserHealthGui',
			--		CornerRadius = Utilities.gui.AbsoluteSize.Y*0.04,
			--		BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = UDim2.new(0.45, 0, 0.1*ys, 0),
			Position = UDim2.new(0.015, 0, 0.3, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Parent = Utilities.backGui,
			Visible = false,

			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://12097059245',--', -- user health gui
				ImageColor3 = Color3.new(.5, .5, .5),
				Size = UDim2.new(1.0, 0, 1.0, 0),
				Position = UDim2.new(0.0, 0, 0.05, 0),
			},

			create 'Frame' {
				Name = 'NameContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.35/ys, 0),
				Position = UDim2.new(0.05, 0, 0.125/ys, 0),
				--			Position = UDim2.new(0.2, 0, -0.135/ys, 0),
				ZIndex = 5,
			},
			create 'Frame' {
				Name = 'NameShadowContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.35/ys, 0),
				Position = UDim2.new(0.04, 0, 0.135/ys, 0),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'GenderContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25/ys, 0),
				Position = UDim2.new(0.7, 0, 0.22/ys, 0),
				--			Position = UDim2.new(0.7, 0, 0.25/ys, 0),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'LevelContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25/ys, 0),
				Position = UDim2.new(0.75, 0, 0.22/ys, 0),
				--			Position = UDim2.new(0.75, 0, 0.25/ys, 0),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'HealthContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25/ys, 0),
				Position = UDim2.new(0.75, 0, 1/ys, 0),
				ZIndex = 4,
			},
		}
		hg.hpdiv = roundedFrame:new {
			Name = 'hpdiv',
			BackgroundColor3 = Color3.new(.7, .7, .7),
			Size = UDim2.new(0.75, 0, 0.3/ys, 0),
			Position = UDim2.new(0.2, 0, 0.6/ys, 0),
			Style = 'HorizontalBar',
			ZIndex = 4,
			Parent = hg.main,--.gui,

			create 'Frame' {
				Name = 'text',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 1.0, -hpg*2),
				Position = UDim2.new(0.12, 0, 0.0, hpg),
				ZIndex = 5,
			},
		}
		hg.statusrf = roundedFrame:new {
			Name = 'status',
			Size = UDim2.new(0.15, 0, 0.25/ys, 0),
			Position = UDim2.new(0.025, 0, 0.625/ys, 0),
			Style = 'HorizontalBar',
			ZIndex = 4,
			Parent = hg.main,--.gui,

			create 'Frame' {
				Name = 'text',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.8, 0),--1.0, -hpg*2),
				Position = UDim2.new(0.5, 0, 0.1, 0),--0.0, hpg),
				ZIndex = 5,
			},
		}
		hg.hpfill = roundedFrame:new {
			Name = 'container',
			BackgroundColor3 = Color3.new(.9, .9, .9),
			Size = UDim2.new(0.8, -hpg*2, 1.0, -hpg*2),
			Position = UDim2.new(0.2, hpg, 0.0, hpg),
			Style = 'HorizontalBar',
			ZIndex = 5,
			Parent = hg.main--[[.gui]].hpdiv,
		}
		hg.hpfill:setupFillbar('gyr', hpg)
		hg.xpfill = roundedFrame:new {
			Name = 'xpdiv',
			BackgroundColor3 = Color3.new(.1, .1, .1),
			Size = UDim2.new(0.8, 0, 0.1),
			Position = UDim2.new(0.1, 0, 0.95, 0),
			Style = 'HorizontalBar',
			ZIndex = 4,
			Parent = hg.main--.gui,
		}
		hg.xpfill:setupFillbar(Color3.new(.4, .8, 1), hpg, 0)
		write 'HP' {
			Frame = hg.main--[[.gui]].hpdiv.text,
			Color = Color3.new(.3, .3, .3),
			Scaled = true,
		}
		--	local resizeCn = Utilities.gui.Changed:connect(function(prop)
		--		if prop ~= 'AbsoluteSize' then return end
		--		hg.main.CornerRadius = Utilities.gui.AbsoluteSize.Y*0.04
		--	end)
		function hg:update(pokemon, ignoreXP)
			pokemon = pokemon or self.pokemon
			local gui = self.main--.gui
			gui.NameContainer:ClearAllChildren()
			gui.NameShadowContainer:ClearAllChildren()
			gui.GenderContainer:ClearAllChildren()
			gui.LevelContainer:ClearAllChildren()
			gui.HealthContainer:ClearAllChildren()
			-- name
			--[[		local nameText = ]]write(pokemon:getShortName()) {
				Frame = gui.NameContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				--			Color = Color3.new(.3, .3, .3),
			}--.Frame
			--		roundedFrame:new {
			--			name = 'barthing',
			--			BackgroundColor3 = Color3.fromRGB(211, 203, 70),-- new(.7, .7, .7),
			--			Size = UDim2.new(1.15, 0, 1.3, 0),
			--			Position = UDim2.new(-.075, 0, -.15, 0),
			--			Style = 'HorizontalBar',
			--			ZIndex = 4, Parent = nameText
			--		}
			--		write(pokemon:getShortName()) {
			--			Frame = gui.NameShadowContainer,
			--			Scaled = true,
			--			TextXAlignment = Enum.TextXAlignment.Left,
			--			Color = Color3.new(0, 0, 0),
			--			Transparency = .6
			--		}
			-- gender
			local show = (pokemon.data and pokemon.data.num ~= 29 and pokemon.data.num ~= 32) or (pokemon.species and pokemon.species ~= 'nidoranf' and pokemon.species ~= 'nidoranm')
			if show and pokemon.gender and pokemon.gender ~= '' then
				write('['..pokemon.gender:upper()..']') {
					Frame = gui.GenderContainer,
					Color = pokemon.gender=='F' and Color3.new(1, .44, .81) or BrickColor.new('Cyan').Color,
					Scaled = true,
				}
			end
			-- level
			write(pokemon.level == 100 and 'Lv.100' or 'Lv. '..pokemon.level) {
				Frame = gui.LevelContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
			-- hp
			self.hpfill:setFillbarRatio(pokemon.hp/pokemon.maxhp)
			write(pokemon.hp..'/'..pokemon.maxhp) {
				Frame = gui.HealthContainer,
				Scaled = true,
			}
			-- exp
			if not ignoreXP then
				pcall(function()
					if not pokemon.expProg then
						gui.xpdiv.Visible = false
					else
						gui.xpdiv.Visible = true
						self.xpfill:setFillbarRatio(pokemon.expProg)
					end
				end)
			end
			-- status
			local statuses = {
				brn = {'BRN', Color3.new(238/255,  70/255,  44/255)},
				frz = {'FRZ', Color3.new(179/255,       1, 240/255)},
				par = {'PAR', Color3.new(240/255, 203/255,  67/255)},
				psn = {'PSN', Color3.new(175/255, 106/255, 206/255)},
				tox = {'PSN', Color3.new(111/255,   9/255,  95/255), Color3.new(188/255, 153/255, 205/255)},
				slp = {'SLP', Color3.new(160/255, 185/255, 175/255)},
			}
			local status = pokemon.status
			if status then
				status = status:match('^(%D+)')
			end
			local s = statuses[status]
			local sf = self.statusrf
			if not s then
				sf.Visible = false
			else
				sf.Visible = true
				sf.BackgroundColor3 = s[2]
				write(s[1]) {
					Frame = sf.gui.text,
					Scaled = true,
					Color = s[3],
				}
			end
		end
		function hg:animateHP(fromHp, toHp, maxhp)
			local ratio = toHp/maxhp
			local lo = math.min(fromHp, toHp)
			local hi = math.max(fromHp, toHp)
			local tc = hg.main--[[.gui]].HealthContainer
			local t
			self.animating = true
			self.hpfill:setFillbarRatio(ratio, true, function(a, r)
				local nt = math.max(lo, math.min(hi, math.floor(maxhp*r+.5)))
				if nt ~= t then
					tc:ClearAllChildren()
					write(nt..'/'..maxhp) {
						Frame = tc,
						Scaled = true,
					}
					t = nt
				end
			end)
			if t ~= toHp then
				tc:ClearAllChildren()
				write(toHp..'/'..maxhp) {
					Frame = tc,
					Scaled = true,
				}
			end
			self.animating = false
			self.lastAnimTime = tick()
		end
		function hg:setHP(hp, maxhp)
			self.hpfill:setFillbarRatio(hp/maxhp)
			local tc = hg.main--[[.gui]].HealthContainer
			tc:ClearAllChildren()
			write(hp..'/'..maxhp) {
				Frame = tc,
				Scaled = true,
			}
		end
		function hg:animateXP(ratio)
			self.xpfill:setFillbarRatio(ratio, true)
		end
		function hg:slideOnscreen()
			spawn(function()
				self.main.Visible = true
				Utilities.Tween(.6, 'easeOutCubic', function(a)
					self.main.Position = UDim2.new(0.015*a, -self.main.AbsoluteSize.X*(1-a), yPos, 0)
				end)
			end)
		end
		function hg:slideOffscreen(delete)
			spawn(function()
				Utilities.Tween(.6, 'easeOutCubic', function(a)
					self.main.Position = UDim2.new(0.015*(1-a), -self.main.AbsoluteSize.X*a, yPos, 0)
				end)
				self.main.Visible = false
				if delete then
					self:remove()
				end
			end)
		end
		function hg:remove()
			self.pokemon = nil
			--		resizeCn:disconnect()
			pcall(function() self.statusrf:remove() end)
			pcall(function() self.hpdiv:remove() end)
			pcall(function() self.hpfill:remove() end)
			pcall(function() self.xpfill:remove() end)
			self.main:remove()
		end
		return hg
	end


	function BattleGui:promptReplaceMove(movesData, alreadyFaded)
		local newMove
		if #movesData > 4 then
			newMove = table.remove(movesData) -- last
		end

		local fader = create 'Frame' {--Utilities.fadeGui
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.frontGui,
		}
		if not alreadyFaded then
			fader.BackgroundColor3 = Color3.new(0, 0, 0)
			fader.ZIndex = 6
		end
		local gui = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = Utilities.frontGui,
		}
		write 'Which move should be forgotten?' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.06, 0),
				Position = UDim2.new(0.5, 0, 0.03, 0),
				Parent = gui,
				ZIndex = 7,
			},
			Scaled = true,
		}
		local rframes = {}
		local sig = Utilities.Signal()
		local function guiForMove(move, onClick)
			local color = typeColors[move.type]
			local panel = roundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(color.r*.35, color.g*.35, color.b*.35),
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.03,
				Size = UDim2.new(0.425, 0, 0.25, 0),
				ZIndex = 8, Parent = gui,
				MouseButton1Click = onClick,

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://'..({Status=12097181428,Special=12097184479,Physical=12097188345})[move.category],
					Size = UDim2.new(0.175/16*39, 0, 0.175, 0),--39x16
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Position = UDim2.new(0.545, 0, 0.07, 0),
					ZIndex = 9,
				}
			}
			table.insert(rframes, panel)
			write(move.name) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.2),
					Position = UDim2.new(0.05, 0, 0.05, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write(move.type) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.95, 0, 0.075, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = color,
			}
			write('Power: '..move.power) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.1, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = Color3.new(.9, .9, .9),
			}
			write('Acc: '..(move.accuracy == true and '--' or move.accuracy)) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.6, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Center, Color = Color3.new(.9, .9, .9),
			}
			write('PP: '..move.pp) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.95, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = Color3.new(.9, .9, .9),
			}
			local descFrame = create 'Frame' {
				Size = UDim2.new(0.9, 0, 0.45),
				Position = UDim2.new(0.05, 0, 0.5, 0),
				BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
			}
			if move.desc and move.desc ~= '' then
				local ht = descFrame.AbsoluteSize.Y/4.5
				local obj = write(move.desc) {
					Frame = descFrame,
					Size = ht,
					Wraps = true,
				}
				if obj and obj.MaxBounds then
					local r = obj.MaxBounds.y/ht
					if r < 2 then
						descFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
					elseif r < 3 then
						descFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
					end
				end
			end
			return panel
		end
		local saying = false
		for i, move in pairs(movesData) do
			local panel = guiForMove(move, function()
				if saying then return end
				if newMove and hmMoveIds[move.id] then
					saying = true
					_p.NPCChat:say('HM moves can\'t be forgotten now.')
					wait() wait()
					saying = false
					return
				end
				sig:fire(i)
			end)
			panel.Position = UDim2.new(0.525-(i%2)*0.475, 0, 0.15+math.floor((i-1)/2)*0.28, 0)
		end
		if newMove then
			local np = guiForMove(newMove, function() sig:fire(nil) end)
			np.Position = UDim2.new(0.5-0.425/2, 0, 0.15+0.28*2, 0)
		else
			local cancel = roundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.35, .35, .35),
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.03,
				Size = UDim2.new(0.425, 0, 0.25, 0),
				Position = UDim2.new(0.5-0.425/2, 0, 0.15+0.28*2, 0),
				ZIndex = 8, Parent = gui,
				MouseButton1Click = function() sig:fire(nil) end,
			}
			table.insert(rframes, cancel)
			write 'Cancel' {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.3),
					Position = UDim2.new(0.5, 0, 0.35, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = cancel.gui,
				}, Scaled = true,
			}
		end
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if not alreadyFaded then fader.BackgroundTransparency = 1 - a*.6 end
			gui.Position = UDim2.new(1-a, 0, 0.0, 0)
		end)
		local res = sig:wait()
		spawn(function()
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				if not alreadyFaded then fader.BackgroundTransparency = 1 - (1-a)*.6 end
				gui.Position = UDim2.new(a, 0, 0.0, 0)
			end)
			for _, rf in pairs(rframes) do
				rf:remove()
			end
			gui:remove()
		end)
		wait(.35)
		return res
	end

	function BattleGui:animateEvolution(name1, name2, sd1, sd2, alreadyFaded, cannotBeCanceled)
		spawn(function() Menu:disable() end)

		local stepped = game:GetService('RunService').RenderStepped
		local animating = true
		local canceled = false

		local topGui = Utilities.frontGui--create 'ScreenGui' { Parent = Utilities.gui.Parent }
		local fader = create 'Frame' {
			BackgroundTransparency = 1.0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = topGui,
		}

		local function fadeOut(d)
			fader.ZIndex = 10
			local s = fader.BackgroundTransparency
			local e = 0.0
			Utilities.Tween(d, nil, function(a)
				fader.BackgroundTransparency = s + (e-s)*a
			end)
		end

		local function fadeIn(d)
			local s = fader.BackgroundTransparency
			local e = 1.0
			Utilities.Tween(d, nil, function(a)
				fader.BackgroundTransparency = s + (e-s)*a
			end)
		end

		if not alreadyFaded then
			spawn(function() _p.MusicManager:prepareToStack(.5) end)
			fadeOut(.5)
		end
		fader.ZIndex = 1

		-- todo -> convert to Pokemon::getSprite()
		--	local sd1 = _p.DataManager:getSprite((shiny and '_SHINY' or '')..'_FRONT', p1, p.gender=='F')
		--	local sd2 = _p.DataManager:getSprite((shiny and '_SHINY' or '')..'_FRONT', p2, p.gender=='F')

		local anim1 = _p.AnimatedSprite:new(sd1)
		local sprite1 = anim1.spriteLabel
		local anim2 = _p.AnimatedSprite:new(sd2)
		local sprite2 = anim2.spriteLabel

		local container1 = Utilities.Create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Parent = topGui,
		}
		do
			sprite1.Parent = container1
			sprite1.ZIndex = 5
			local scale = sd1.scale or 1
			local x = sd1.fWidth/110*scale
			local y = sd1.fHeight/110*scale
			sprite1.Size = UDim2.new(x, 0, y, 0)
			sprite1.Position = UDim2.new(0.5-x/2, 0, 0.5-y/2, 0)
		end
		local container2 = Utilities.Create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Visible = false,
			Parent = topGui,
		}
		do
			sprite2.Parent = container2
			sprite2.ZIndex = 5
			local scale = sd2.scale or 1
			local x = sd2.fWidth/110*scale
			local y = sd2.fHeight/110*scale
			sprite2.Size = UDim2.new(x, 0, y, 0)
			sprite2.Position = UDim2.new(0.5-x/2, 0, 0.5-y/2, 0)
		end
		container1.Size = UDim2.new(0.6, 0, 0.6, 0)
		container1.Position = UDim2.new(0.5, -container1.AbsoluteSize.X/2, 0.2, 0)
		anim1:Play()

		Utilities.sound(287784334, nil, nil, 5)
		local sound
		delay(1, function()
			if canceled then return end
			sound = Utilities.loopSound(12639585348)
		end)
		_p.NPCChat:say('What? ' .. name1 .. ' is evolving!')

		local cancel
		if not cannotBeCanceled then
			cancel = roundedFrame:new {
				Button = true, Name = 'CancelButton',
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.01,
				BackgroundColor3 = Color3.new(.3, .3, .3),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(1/5, 0, 1/16, 0),
				Position = UDim2.new(0.7, 0, 29/32, 0),
				ZIndex = 5,
				MouseButton1Click = function()
					pcall(function()
						sound:Stop()
						sound:remove()
					end)

					canceled = true
					cancel:remove()
				end,
			}
		end

		spawn(function()
			local t = 3
			local n = 10
			local s = tick()
			local timer = Utilities.Timing.easeInCubic(t)
			for i = 1, n do
				local c = (i%5+3)/7
				local image = Utilities.Create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://79427844962045',
					ImageColor3 = Color3.new(.4*c, .8*c, c),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					ZIndex = 3,
				}
				spawn(function()
					local last = 0
					while animating and not canceled do
						local et = (tick()-s-i*t/n)%t
						if et < last then
							image.Parent = nil; image.Parent = topGui
						end
						last = et
						local a = timer(et)
						image.Size = UDim2.new(a*2.5, 0, a*2.5, 0)
						image.Position = UDim2.new(0.5-a*2.5/2, 0, 0.5, -image.AbsoluteSize.Y/2)
						stepped:wait()
					end
					image:remove()
				end)
				wait(t/n)
			end
		end)

		wait(2)
		Utilities.Tween(1, nil, function(a)
			local o = 1-a
			sprite1.ImageColor3 = Color3.new(o, o, o)
		end)
		wait(.5)
		if cancel then
			cancel.Parent = topGui
			write 'Cancel' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 6, Parent = cancel.gui,
				}, Scaled = true,
			}
		end
		sprite2.ImageColor3 = Color3.new(0, 0, 0)
		anim2:Play()
		local s = tick()
		local last = 0
		while not canceled do
			local et = tick()-s
			local p = math.cos(et*math.pi*(0.5+et/3.5))
			if et >= 8 and p < 0 and last < p then break end
			last = p
			if p > 0 then
				container1.Visible = true
				container1.Size = UDim2.new(p*.6, 0, p*.6, 0)
				container1.Position = UDim2.new(0.5, -container1.AbsoluteSize.X/2, 0.5-p*.3, 0)
				container2.Visible = false
			else
				p = -p
				container1.Visible = false
				container2.Visible = true
				container2.Size = UDim2.new(p*.6, 0, p*.6, 0)
				container2.Position = UDim2.new(0.5, -container2.AbsoluteSize.X/2, 0.5-p*.3, 0)
			end
			stepped:wait()
		end
		if canceled then
			local bg = create 'Frame' {
				BackgroundColor3 = Color3.new(.4, .8, 1),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
				ZIndex = 2,
				Parent = topGui
			}
			container1.Visible = true
			sprite1.ImageColor3 = Color3.new(1, 1, 1)
			container1.Size = UDim2.new(.6, 0, .6, 0)
			container1.Position = UDim2.new(0.5, -container1.AbsoluteSize.X/2, 0.2, 0)
			container2:remove()
			_p.NPCChat:say('Huh? ' .. name1 .. ' stopped evolving!')
			fadeOut(1)
			bg:remove()
			container1:remove()
			--		topGui:remove()
			if not alreadyFaded then
				spawn(function() _p.MusicManager:returnFromSilence(.5) end)
				fadeIn(.5)
				if not Menu.bag.open then
					spawn(function() Menu:enable() end)
				end
			end
			fader:remove()
			return false
		end
		pcall(function() cancel:remove() end)
		container1.Visible = false
		container2.Visible = true
		container2.Size = UDim2.new(.6, 0, .6, 0)
		container2.Position = UDim2.new(0.5, -container2.AbsoluteSize.X/2, 0.2, 0)
		local image = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6604495601',
			ImageColor3 = Color3.new(.4, .8, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = 4,
			Parent = topGui,
		}
		Utilities.Tween(.75, 'easeInCubic', function(a)
			image.Size = UDim2.new(a*2, 0, a*2, 0)
			image.Position = UDim2.new(0.5-a*2/2, 0, 0.5, -image.AbsoluteSize.Y/2)
			sprite2.ImageColor3 = Color3.new(a, a, a)
		end)
		animating = false
		pcall(function()
			sound:Stop()
			sound:remove()
		end)
		Utilities.sound(12639642017, nil, .5, 10)
		_p.NPCChat:say('Congratulations! Your ' .. name1 .. ' evolved into ' .. name2 .. '!')
		wait(2)

		return true, function()
			fader.BackgroundTransparency = 1.0
			fadeOut(.5)
			container1:remove()
			container2:remove()
			image:remove()
			--		topGui:remove()
			if not alreadyFaded then
				spawn(function() _p.MusicManager:returnFromSilence(.5) end)
				fadeIn(.5)
				if not Menu.bag.open then
					spawn(function() Menu:enable() end)
				end
			end
			fader:remove()
		end
	end


	return BattleGui end