-- todo: offer to enable Autosave at the beginning (after explanation)
return function(_p)

	game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	local stepped = game:GetService('RunService').RenderStepped

	--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local animation = _p.AnimatedSprite
	local create = Utilities.Create
	local write = Utilities.Write

	local intro = {}


	function intro:newGame(fader)
		local canChat = true
		spawn(function() pcall(function() canChat = game:GetService('Chat'):CanUserChatAsync(_p.userId) end) end)
		_p.DataManager:preload(5210432141, 5119871511, 5119871241)
		Utilities:layerGuis()
		--	Utilities.Teleport(CFrame.new(44, 54, 135))
		local ac = Utilities.getHumanoid()
		local isR15 = ac.RigType == Enum.HumanoidRigType.R15
		local sleepTrack = ac:LoadAnimation(Utilities.Create'Animation'{AnimationId='rbxassetid://'.._p.animationId[isR15 and'R15_IntroSleep'or'IntroSleep']})
		local sitTrack   = ac:LoadAnimation(Utilities.Create'Animation'{AnimationId='rbxassetid://'.._p.animationId[isR15 and'R15_IntroWake'or'IntroSit']})
		local throwTrack = isR15 and ac:LoadAnimation(Utilities.Create'Animation'{AnimationId='rbxassetid://'.._p.animationId.R15_IntroTossClock}) or nil
		-- [[
		Utilities.sound(12635469705, nil, .5, 35)--288901896, nil, nil, 35)--intro cutscene music 5773407047 and old intro cutscene music 5773401700
		local cam = workspace.CurrentCamera
		cam.CameraType = Enum.CameraType.Scriptable
		-- route 1
		spawn(function()
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
			wait(7)
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = 1-a
			end)
		end)
		local p1 = Vector3.new(-48.1, 70, -5.7)
		local p2 = Vector3.new(7.1, 63.4, -17.3)
		local f1 = Vector3.new(-58.3, 63.4, -27.9)
		local f2 = Vector3.new(1.7, 62.6, -5.7)
		Utilities.Tween(8, nil, function(a)
			local p = p1:Lerp(p2, a)
			local f = f1:Lerp(f2, a)
			cam.CoordinateFrame = CFrame.new(p, f)
		end)
		-- dig site
		spawn(function()
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
			wait(7)
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = 1-a
			end)
		end)
		p1 = Vector3.new(102, 78, 189.6)
		p2 = Vector3.new(109.8, 87.1, 249)
		f1 = Vector3.new(121, 70.5, 240.6)
		f2 = Vector3.new(134.4, 82.5, 252.6)
		Utilities.Tween(8, nil, function(a)
			local p = p1:Lerp(p2, a)
			local f = f1:Lerp(f2, a)
			cam.CoordinateFrame = CFrame.new(p, f)
		end)
		-- lab
		spawn(function()
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
			wait(7)
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = 1-a
			end)
		end)
		p1 = Vector3.new(-46.6, 57.6, 179.8)
		p2 = Vector3.new(-108,  57.6, 179.8)--82.2, 204.2)
		local ptimer = Utilities.Timing.cubicBezier(8, .05, 0, .75, 1)
		local ptimer2 = Utilities.Timing.cubicBezier(8, .4, 0, .75, .75)
		f1 = Vector3.new(-74.6, 60, 179.8)
		f2 = Vector3.new(-138.4, 65.4, 189.4)
		Utilities.Tween(8, nil, function(a)
			local t = ptimer2(a*8)
			local p = p1:Lerp(p2, ptimer(a*8)) + Vector3.new(0, (82.2-57.6)*t, (204.2-179.8)*t)
			local f = f1:Lerp(f2, a)
			cam.CoordinateFrame = CFrame.new(p, f)
		end)
		-- house window
		spawn(function()
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
		end)
		local f = Vector3.new(-29.816, 65.6, 136.415)
		Utilities.Tween(8, nil, function(a)
			local d = 1 + 20*(1-a)
			local p = f + Vector3.new(2, 1, 0).unit*d
			cam.CoordinateFrame = CFrame.new(p, f)
			if a > 7/8 then
				fader.BackgroundTransparency = 1 - (a*8-7)
			end
		end)--]]
		-- chunk/room setup
		local chunk = _p.DataManager.currentChunk
		chunk.indoors = true
		local room = chunk:getRoom('yourhomef1', chunk:getDoor('yourhomef1'), 1)
		chunk.roomStack = {room}
		chunk:stackSubRoom('yourhomef2', room.model.SubRoom, true)
		room = chunk.roomStack[2]
		chunk:bindIndoorCam()
		local root = _p.player.Character.HumanoidRootPart
		if isR15 then
			room.model.NewGameSpawn.CanCollide = false
		end
		root.Anchored = true
		Utilities.Teleport(room.model.NewGameSpawn.CFrame + (isR15 and Vector3.new(0, -.8+1+1.35, .3) or Vector3.new(0, 3, 1)))
		_p.MasterControl:SetIndoors(true)
		-- character
		local face
		pcall(function()
			face = _p.player.Character.Head.face.Texture
			_p.player.Character.Head.face.Texture = 'rbxassetid://60146291'
		end)
		sleepTrack:Play(0)
		local alarm = Utilities.sound(5773411976)
		wait(4)
		Utilities.Tween(.5, nil, function(a)
			fader.BackgroundTransparency = a
		end)
		wait(3)
		local character = _p.player.Character
		local ac = chunk.roomStack[2].model.AlarmClock
		local chat = _p.NPCChat
		if isR15 then
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
			local alarmParts = {}
			local leftHand = character:FindFirstChild('LeftHand')
			local hold = false
			throwTrack:Play()
			schedule(throwTrack, 'Grab', 3.45, function()
				local lcf = leftHand.CFrame
				for _, p in pairs(ac:GetChildren()) do
					if p:IsA('BasePart') then
						alarmParts[p] = lcf:toObjectSpace(p.CFrame)
						p.CanCollide = false
					end
				end
				hold = true
				while hold do
					stepped:wait()
					local cf = leftHand.CFrame
					for p, rcf in pairs(alarmParts) do
						p.CFrame = cf:toWorldSpace(rcf)
					end
				end
			end)
			local proceed = Utilities.Signal()
			schedule(throwTrack, 'Throw', 3.8, function()
				hold = false
				local mcf = ac.Main.CFrame
				local offset = Vector3.new(4, 2, -20)
				local vol = alarm.Volume
				delay(.25, function() Utilities.sound(5773416362, nil, nil, 5) end)
				Utilities.Tween(.5, nil, function(a)
					Utilities.MoveModel(ac.Main, mcf + offset*a)
					alarm.Volume = vol * (1-a)
				end)
				alarm:remove()
				ac:remove()
				proceed:fire()
			end)
			proceed:wait()

			-- jump out of bed
			wait(2)
			chat:enable()
			pcall(function() _p.player.Character.Head.face.Texture = face end)
			chat:say('...oh wait!')
			sitTrack:Play()
			delay(.1, function() sleepTrack:Stop() end)
			schedule(sitTrack, 'GetUp', 2.25, function()
				local rcf = root.CFrame
				Utilities.Tween(.5, 'easeInOutQuad', function(a)
					root.CFrame = rcf + Vector3.new(3.75*a, 0, 0)
				end)
				root.Anchored = false
			end)
			wait(4)
		else
			local m = create 'Model' { Parent = workspace, create 'Humanoid' {} }
			local larmNames = {['Left Arm']=true, LeftUpperArm=true, LeftLowerArm=true, LeftHand=true}
			local --[[larm,]] larmclone = create 'Part' {
				Name = 'Left Arm',
				Anchored = true,
				CanCollide = false,
				Size = Vector3.new(1, 2, 1),
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Parent = m,
			}
			local torso = character:FindFirstChild('Torso')
				or character:FindFirstChild('UpperTorso')
			for _, obj in pairs(character:GetChildren()) do
				if obj:IsA('CharacterAppearance') and not obj:IsA('BodyColors')then
					obj:Clone().Parent = m
				elseif obj:IsA('Part') and obj.Name == 'Left Arm' then
					larmclone.BrickColor = obj.BrickColor
					--			larm = obj
					--			larmclone = larm:Clone()
					--			larmclone.Anchored = true
					--			larmclone.Parent = m
					--			larm.Transparency = 1
				end
			end
			for name in pairs(larmNames) do
				pcall(function() character[name].Transparency = 1 end)
			end

			local f = Vector3.new()
			local cframe = CFrame.new
			local angles = CFrame.Angles
			local function point()
				local joint = (torso.CFrame * cframe(-1, 0.5, 0)).p
				local top = (joint-f).unit
				local right = Vector3.new(0, 1, 0):Cross(top)
				local back = right:Cross(top)
				Utilities.MoveModel(larmclone, cframe(joint.x, joint.y, joint.z,
					right.x, top.x, back.x,
					right.y, top.y, back.y,
					right.z, top.z, back.z) * cframe(-0.5, -0.5, 0), true)
			end

			local p1 = (torso.CFrame*cframe(-1.5, -1, 0)).p
			local pts = {
				ac.Main.Position + Vector3.new(0, 1, -1.5),
				ac.Main.Position + Vector3.new(0, 0, -1.5),
				ac.Main.Position + Vector3.new(0, 2, 0),
				ac.Main.Position + Vector3.new(0, 0, 1.5),
				ac.Main.Position + Vector3.new(0, 1.5, -0.5),
				ac.Main.Position + Vector3.new(0, 0, -3),
				ac.Main.Position + Vector3.new(0, 1.5, -1),
				ac.Main.Position,
			}
			for _, p2 in pairs(pts) do
				Utilities.Tween(.5, nil, function(a)
					f = p1:Lerp(p2, a)
					pcall(point)
				end)
				p1 = p2
			end
			p2 = ac.Main.Position + Vector3.new(10, 8, -20)
			ac.Parent = m
			spawn(function()
				Utilities.Tween(.4, nil, function(a)
					f = p1:Lerp(p2, a)
					pcall(point)
				end)
			end)
			wait(.1)
			local from = ac.Main.Position
			local to = p2
			local pos1 = p2
			local pos2 = (torso.CFrame*cframe(-1.5, -1, 0)).p
			local v = alarm.Volume
			ac.Parent = chunk.map
			delay(.15, function() Utilities.sound(5773416362, nil, nil, 5) end)
			Utilities.Tween(.5, nil, function(a)
				f = pos1:Lerp(pos2, a)
				pcall(point)
				local pos = from:Lerp(to, a)
				Utilities.MoveModel(ac.Main, ac.Main.CFrame - ac.Main.Position + pos, true)
				alarm.Volume = v * (1-a)
			end)
			alarm:remove()
			ac:remove()

			m:remove()
			--		pcall(function() larmclone:remove() end)
			--		pcall(function() larm.Transparency = 0 end)
			for name in pairs(larmNames) do
				pcall(function() character[name].Transparency = 0 end)
			end
			-- jump out of bed
			wait(2)
			chat:enable()
			pcall(function() _p.player.Character.Head.face.Texture = face end)
			chat:say('...oh wait!')
			sitTrack:Play(.5)
			sleepTrack:Stop(.5)
			wait(1.5)
			local cf = room.model.NewGameSpawn.CFrame
			Utilities.Tween(.4, 'easeInOutCubic', function(a)
				pcall(function() root.CFrame = cf * CFrame.Angles(0, math.pi*-.5*a, 0) + Vector3.new(0, 3, 1) end)
			end)
			root.Anchored = false
			wait()
			_p.player:Move(Vector3.new(5, 0, 0), false)
			sitTrack:Stop(.25)
			wait(.25)
			_p.player:Move(Vector3.new())
			local cf = root.CFrame
			Utilities.Tween(.4, 'easeOutCubic', function(a)
				pcall(function() root.CFrame = cf * CFrame.Angles(0, math.pi/2*a, 0) end)
			end)
			root.Anchored = true
		end
		wait(.2)
		-- monologue
		chat:say(
			'Oh boy, oh boy, I can\'t believe today has finally come!',
			'I\'ve played so many Pokemon Brick Bronze games over the years only for those to shut down after a few weeks.',
			'But now that I\'m playing one by mrbobbilly, I can rest assured that I won\'t have to restart for the 1,000,000th time!',
			'That is actually because mrbobbilly created this version to use Cloud Saving to back up your saves that transfers to our official reuploads if this game gets taken down!',
			'I should really join the Thiscored server down in the description to know the new game link whenever the game gets taken down to get my data restored.',
			'It would be wise to so that I can figure out which one is the official Project Bronze copy because there\'s a bunch of Project Bronze copies out there that claim to be the original one when they\'re not.',
			--		'I\'ll also be glad to know that I can be able to obtain a few Gen 7 at the basement in Silvent City.',
			'Well, here comes my journey!'
		--[['I can\'t believe today has finally come!',
		'Today I get my first pokemon from the pokemon Professor!',
		'I have always dreamed of setting out on my own adventure with pokemon by my side!',
		'There are so many pokemon in this world!',
		'I hope to discover them all one day!',
		'Well, I\'d better get going!'--]])
		if canChat then
			chat:say(
				'Oh, how silly of me!',
				'I almost forgot to fill out my Trainer Card for the thousand time!'
				--[[
				
				'Oh, I almost forgot!',
			'I need to fill out my Trainer Card!'--]])
			--	_p.PlayerData.pokedex = nil
			_p.Menu.card:enterName()
			wait(1)
			chat:say(
				'That\'s crazy, now I don\'t have to do that over and over again!',
				'Now I can continue being the best Pokemon Trainer ever!',
				--	'I\'ll have to take note that Shiny Pokemons are not currently available due to tbradm deleting them all.',
				--	'Thankfully mrbobbilly is attempting to remake them but it would be a while to get them completed as there\'s thousands of spritesheets to remake.',
				'Anyways, let\'s start our adventure now!'
				--[[
				'Awesome!',
			'I\'m that much closer to officially being a pokemon Trainer!'--]])
			wait(.3)
			local gui = _p.Menu.card.gui
			Utilities.Tween(.6, 'easeOutCubic', function(a)
				gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, 0.3+.7*a, 0)
			end)
			gui:remove()
			_p.Menu.card.gui = nil
			root.Anchored = false
		end
		_p.Menu.newGameFlag = true
		room.model.NewGameSpawn.CanCollide = true

		self:newPlayerInfo()
	end

	function intro:newPlayerInfo()
		--	do return end
		local fader = create 'Frame' {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1.0,
			BorderSizePixel = 0,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.frontGui,
		}
		local bg = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5210432121',
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 3, Parent = Utilities.frontGui,
		}
		local textbox = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.7, 0, 0.5, 0),
			Position = UDim2.new(0.15, 0, 0.3125, 0),
			ZIndex = 5, Parent = bg,
		}
		local textbox2 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.5, 0, 0.2, 0),
			Position = UDim2.new(0.35, 0, 0.7375, 0),
			ZIndex = 5, Parent = bg,
		}
		local textbox3 = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.5, 0, 0.05, 0),
			Position = UDim2.new(0.325, 0, 0.8625, 0),
			ZIndex = 5, Parent = bg,
		}
		write([[Some notes from the developer of Project Bronze:

 - Your progress is saved permanently, meaning if Roblox shuts down the game, then your data will be backed up and restored on our official reuploads!

 - Your progress is NOT saved automatically. You must either manually save from the Menu OR enable autosave from the Options menu.

 - We have a Thiscored chat room server, please join it below the game page to get notified of frequent updates or game links if the game gets taken down!]]) {

			Frame = textbox,
			Size = textbox.AbsoluteSize.Y*.0375,
			Wraps = true,
		}
		write([[- If you have any questions about Project Bronze, message me on eX at Omrbobbilly or at Thiscored at mrbobbilly if you need help.]]) {
			Frame = textbox2,
			Size = textbox.AbsoluteSize.Y*.0375,
			Wraps = true,
		}
		write 'Thanks for playing!' {
			Frame = textbox3,
			Scaled = true,
		}

		local SIGN_NO_HOVER = 'rbxassetid://5119871499'
		local SIGN_HOVER = 'rbxassetid://5119871225'
		local signpostContainer = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.05, 0, .05, 0),
			Parent = bg,
		}
		local signImage = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = SIGN_NO_HOVER,
			Size = UDim2.new(10, 0, 10, 0),
			Position = UDim2.new(-4, 0, -9.5, 0),
			ZIndex = 7, Parent = signpostContainer,
		}
		local button = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.7, 0, .2125, 0),
			Position = UDim2.new(.15, 0, .7, 0),
			Parent = signImage,
		}

		button.MouseEnter:connect(function()
			signImage.Image = SIGN_HOVER
		end)
		button.MouseLeave:connect(function()
			signImage.Image = SIGN_NO_HOVER
		end)

		local rotate = true
		spawn(function()
			local st = tick()
			local sin = math.sin
			while rotate do
				stepped:wait()
				local et = tick()-st
				signpostContainer.Rotation = 8 * sin(et)
			end
		end)

		Utilities.Tween(.5, 'easeOutCubic', function(a)
			fader.BackgroundTransparency = 1-.3*a
			bg.Position = UDim2.new(0.5, -bg.AbsoluteSize.X/2, -1.5*(1-a), 0)
			signpostContainer.Position = UDim2.new(1.0, 0, 0.975+3*(1-a), 0)
		end)
		button.MouseButton1Click:wait()

		Utilities.Tween(.5, 'easeOutCubic', function(a)
			fader.BackgroundTransparency = .7+.3*a
			bg.Position = UDim2.new(0.5, -bg.AbsoluteSize.X/2, -1.5*a, 0)
			signpostContainer.Position = UDim2.new(1.0, 0, 0.975+3*a, 0)
		end)
		bg:remove()
		fader:remove()

		--this isnt even needed anymore...
		if _p.userId < 1 then
			wait(.5)
			local chat = _p.NPCChat
			chat.bottom = true
			chat:say('You are currently playing ROBLOX as a Guest.',
				'Guests are not able to save their adventure in Pokemon Brick Bronze.',
				'If you choose to continue playing as a Guest, please remember that you will be unable to save later.',
				'You also cannot enter the PVP Battle Colosseum or Trade Resort.',
				'If you would like to be able to save, Sign in or Create a ROBLOX account now, then rejoin this game.',
				'It\'s FREE!')
		end
	end

	function intro:perform(loadGui, loadFn)
		local canSkip = false
		local skipped = true -- set to false if you want intro
		local function swait(t)
			if not canSkip then wait(t) return end
			local endTick = tick()+t
			while not skipped and tick() < endTick do
				stepped:wait()
			end
		end
		local function sdelay(t, f)
			if not canSkip then delay(t, f) return end
			if skipped then return end
			delay(t, function()
				if skipped then return end
				f()
			end)
		end

		local skipButton
		pcall(function() --if game.CreatorId == 446187905 or game:GetService('RunService'):IsServer() then
			canSkip = true
			skipButton = create 'ImageButton' {
				AutoButtonColor = false,
				BackgroundColor3 = Color3.new(.15, .15, .15),
				Size = UDim2.new(0.08, 0, 0.08, 0),
				Position = UDim2.new(0.16, 0, 0.92, 0),
				ZIndex = 9, Parent = Utilities.frontGui,
				MouseButton1Click = function()
					skipButton:remove()
					skipped = true
				end
			}

			write 'skip' {
				Frame = create 'Frame' {
					--Color = Color3.new(1, .4, .4),
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.6, 0),
					Position = UDim2.new(0.5, 0, 0.2, 0),
					ZIndex = 10, Parent = skipButton
				}, Scaled = true, Color = Color3.new(0, 0, 0)
			}
			--		Utilities.layerGuis()
		end)
		local bg = create("Frame")({
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1, 0, 1, 36),
			Position = UDim2.new(0, 0, 0, -36),
			Parent = Utilities.gui
		})
		wait()
		local music
		for _, obj in pairs(loadGui:GetChildren()) do
			if obj:IsA("Sound") then
				music = obj
			else
				obj:remove()
			end
		end

		swait(1)
		local tbradm = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0.08, 0),
			Position = UDim2.new(0.25, 0, 0.27, 0),
			ZIndex = 5,
			Parent = bg
		})
		sdelay(0.3, function()
			local narwhal = create("ImageLabel")({
				BackgroundTransparency = 1,
				ImageTransparency = 1,
				Image = "rbxassetid://313110711",
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-0.4, 0, 0.4, 0),
				ZIndex = 4,
				Parent = bg
			})
			Utilities.Tween(3, nil, function(a)
				if skipped then
					return false
				end
				narwhal.Position = UDim2.new(0.85 - 0.1 * a, 0, 0.125, 0)
				narwhal.ImageTransparency = math.max(0, 1 - 1.2 * math.sin(a * math.pi))
			end)
			narwhal:remove()
		end)
		if not skipped then
			write("tbradm")({
				Frame = tbradm,
				Color = Color3.new(1, 0.4, 0.4),
				AnimationRate = 10,
				FadeAfter = 3,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		end
		local presents = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0.06, 0),
			Position = UDim2.new(0.3, 0, 0.39, 0),
			ZIndex = 5,
			Parent = bg
		})
		if not skipped then
			write("presents...")({
				Frame = presents,
				AnimationRate = 10,
				FadeAfter = 3,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		end

		swait(1.65)
		local association = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0.06, 0),
			Position = UDim2.new(0.31, 0, 0.485, 0),
			ZIndex = 5,
			Parent = bg
		})
		if not skipped then
			write("in association with")({
				Frame = association,
				AnimationRate = 10,
				FadeAfter = 3,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		end
		sdelay(0.45, function()
			local doctor = create("ImageLabel")({
				BackgroundTransparency = 1,
				ImageTransparency = 1,
				Image = "rbxassetid://313609630", --6486673486
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.4, 0, 0.4, 0),
				ZIndex = 4,
				Parent = bg
			})
			Utilities.Tween(3, nil, function(a)
				if skipped then
					return false
				end
				doctor.Position = UDim2.new(0.0625 + 0.1 * a, 0, 0.5, 0)
				doctor.ImageTransparency = math.max(0, 1 - 1.2 * math.sin(a * math.pi))
			end)
			doctor:remove()
		end)
		local green = Color3.new(0.4, 1, 0.8)
		local yellow = Color3.new(1, 0.8, 0.4)
		local red = Color3.new(1, 0.4, 0.4)
		local tan = Color3.fromRGB(255, 233, 159)
		local blue = Color3.new(0.4, 0.8, 1)
		local purple = Color3.new(0.8, 0.4, 1)
		local pink = Color3.fromRGB(255, 111, 207)
		for i, name in pairs({
			"lando64000",
			"Srybon",
			"zombie7737",
			"Our_Hero",
			"KyleAllenMusic",
			"chrissuper",
			"ShipooI",
			"MySixthSense",
			"kevincatssing",
			"roball1",
			"Roselius",
			"oldschooldude2"
			}) do
			sdelay(i * 0.25, function()
				local x = i % 2 == 1 and 0 or 1
				local y = math.ceil(i / 2)
				write(name)({
					Frame = create("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.04, 0),
						Position = UDim2.new(0.15 + 0.015 * i + 0.315 * x, 0, 0.56 + 0.03 * i - 0.016 * x, 0),
						ZIndex = 5,
						Parent = bg
					}),
					Color = ({
						green,
						yellow,
						red,
						tan,
						green,
						red,
						tan,
						blue,
						purple,
						tan,
						pink,
						blue
					})[i],
					AnimationRate = 10,
					FadeAfter = ({
						3.8,
						3,
						3,
						2.5,
						1.9,
						2.5,
						2.6,
						2,
						2,
						2.5,
						2.1,
						1.3
					})[i],
					TextXAlignment = Enum.TextXAlignment.Left
				})
			end)
		end


		swait(4.35)
		local sq = create("Frame")({
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = Utilities.gui
		})
		local function u(p)
			if p == "AbsoluteSize" then
				sq.Position = UDim2.new(0.5, -sq.AbsoluteSize.X / 2, 0, 0)
			end
		end
		local c = Utilities.gui.Changed:connect(u)
		u("AbsoluteSize")
		local hoopa, fireAnimBottom, fireAnimTop
		if not skipped then
			local fire = {sheets={{id=5478522832,rows=4},{id=5478523727,rows=4},{id=5478524690,rows=4},{id=5478525432,rows=4},},nFrames=64,fWidth=255,fHeight=255,framesPerRow=4}
			local s = 1.5
			fireAnimBottom = animation:new(fire)
			fireAnimBottom.startTime = 0
			fireAnimBottom.cache.Position = UDim2.new(0, 0, 0.5, 0)
			fireAnimBottom.spriteLabel.ImageColor3 = Color3.new(1, 0.3, 0.3)
			fireAnimBottom.spriteLabel.Size = UDim2.new(1.5, 0, 1.5, 0)
			fireAnimBottom.spriteLabel.Position = UDim2.new(-0.25, 0, 1, 0)
			fireAnimBottom.spriteLabel.ZIndex = 2
			fireAnimBottom.spriteLabel.Parent = sq
			fireAnimBottom:Play()
			hoopa = animation:new({
				sheets = {
					{
						id = 5224408011,
						startPixelY = 100,
						rows = 3
					},
					{id = 5224411028, rows = 4},
					{id = 5224413663, rows = 4},
					{id = 5224416193, rows = 4},
					{id = 5224418887, rows = 4}
				},
				nFrames = 74,
				fWidth = 131,
				fHeight = 126,
				framesPerRow = 4
			})
			local x = 0.7277777777777777
			hoopa.spriteLabel.ImageColor3 = Color3.new(0, 0, 0)
			hoopa.spriteLabel.ImageTransparency = 0.9
			hoopa.spriteLabel.Size = UDim2.new(x, 0, 0.7, 0)
			hoopa.spriteLabel.Position = UDim2.new(0.5 - x / 2, 0, 0.25, 0)
			hoopa.spriteLabel.ZIndex = 3
			hoopa.spriteLabel.Parent = sq
			hoopa:Play()
			fireAnimTop = animation:new(fire)
			fireAnimTop.startTime = 0.96
			fireAnimTop.spriteLabel.ImageTransparency = 0.5
			fireAnimTop.cache.Position = UDim2.new(0, 0, 0.5, 0)
			fireAnimTop.spriteLabel.Size = UDim2.new(1.5, 0, 1.5, 0)
			fireAnimTop.spriteLabel.Position = UDim2.new(-0.25, 0, 1, 0)
			fireAnimTop.spriteLabel.ZIndex = 4
			fireAnimTop.spriteLabel.Parent = sq
			fireAnimTop:Play()
		end
		local pokemoncontainer = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0.38362919132149903, 0),
			Position = UDim2.new(0, 0, 0.05, 0),
			Parent = sq
		})
		local pokemoncutter = create("Frame")({
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Size = UDim2.new(0, 0, 1, 0),
			Parent = pokemoncontainer
		})
		local pokemon = create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = "rbxassetid://771144807",
			ZIndex = 5,
			Parent = pokemoncutter
		})
		local bbLetterBounds = {
			{
				0,
				0,
				190,
				246
			},
			{
				213,
				0,
				220,
				240
			},
			{
				455,
				0,
				78,
				239
			},
			{
				563,
				0,
				189,
				240
			},
			{
				769,
				0,
				220,
				239
			},
			{
				0,
				244,
				158,
				199
			},
			{
				161,
				244,
				165,
				199
			},
			{
				337,
				244,
				160,
				199
			},
			{
				513,
				246,
				170,
				197
			},
			{
				683,
				245,
				157,
				198
			},
			{
				842,
				244,
				148,
				199
			}
		}
		local bbContainer = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0.4484848484848485, 0),
			Position = UDim2.new(0, 0, 0.45, 0),
			Parent = sq
		})
		swait(2)
		Utilities.Tween(0.325, nil, function(a)
			if skipped then
				return false
			end
			local c = math.sin(a * math.pi)
			bg.BackgroundColor3 = Color3.new(c, c, c)
			pokemoncutter.Size = UDim2.new(a, 0, 1, 0)
			if a ~= 0 then
				pokemon.Size = UDim2.new(1 / a, 0, 1, 0)
			end
		end)
		swait(1)
		pcall(function()
			hoopa.spriteLabel.ImageTransparency = 0.5
		end)
		Utilities.Tween(3, "easeOutCubic", function(a)
			if skipped then
				return false
			end
			fireAnimBottom.spriteLabel.Position = UDim2.new(-0.25, 0, 1 - 1.45 * a, 0)
			fireAnimTop.spriteLabel.Position = UDim2.new(-0.25, 0, 1 - 1.45 * a, 0)
		end)
		swait(0.3)
		for _, lb in pairs(bbLetterBounds) do
			do
				local container = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(lb[3] / 990, 0, lb[4] / 444, 0),
					Position = UDim2.new(lb[1] / 990, 0, lb[2] / 444, 0),
					Parent = bbContainer
				})
				local letter = create("ImageLabel")({
					BackgroundTransparency = 1,
					Image = "rbxassetid://9725710701",
					ImageRectSize = Vector2.new(lb[3], lb[4]),
					ImageRectOffset = Vector2.new(lb[1], lb[2]),
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 5
				})
				print(letter:GetFullName())
				sdelay(0.5 * math.random(), function()
					local bounce = Utilities.Timing.easeOutBounce(1)
					local cubic = Utilities.Timing.easeOutCubic(1)
					local dir = math.random() < 0.5 and 1 or -1
					local x = dir * 0.15 / container.Size.X.Scale
					local y = -0.3 / container.Size.Y.Scale
					letter.Parent = container
					Utilities.Tween(1, nil, function(a)
						if skipped then
							return false
						end
						local c = 1 - cubic(a)
						letter.ImageTransparency = c
						letter.Position = UDim2.new(x * (1 - a), 0, y * (1 - bounce(a)), 0)
						letter.Rotation = 30 * dir * c
					end)
				end)
			end
		end
		swait(5.4)
		local txt = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0.05, 0),
			ZIndex = 6,
			Parent = Utilities.gui
		})

		if not skipped then
			local touch = Utilities.isTouchDevice()
			write(touch and "TAP TO PLAY" or "CLICK TO PLAY")({Frame = txt, Scaled = true})
			Utilities.Tween(0.5, "easeOutCubic", function(a)
				if skipped then
					return false
				end
				txt.Position = UDim2.new(0.5, 0, 1 - 0.075 * a, 0)
			end)
			if not skipped then
				game:GetService("Players").LocalPlayer:GetMouse().Button1Down:wait()
			end
		end
		local fader = create("Frame")({
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1, 0, 1, 36),
			Position = UDim2.new(0, 0, 0, -36),
			ZIndex = 10,
			Parent = Utilities.gui
		})
		local v
		pcall(function()
			v = music.Volume
		end)
		Utilities.Tween(1.5, nil, function(a)
			if skipped then
				return false
			end
			local o = 1 - a
			pcall(function()
				music.Volume = v * o
			end)
			fader.BackgroundTransparency = o
		end)
		sq:remove()
		loadGui:remove()
		txt:remove()

		if skipped then
			bg:ClearAllChildren()
		end
		pcall(function()
			skipButton:remove()
		end)

		local sig = Utilities.Signal()
		local continue
		local continueContainer
		local newgame
		local hasFile, name, badges, pokedex = _p.Network:get("PDS", "getContinueScreenInfo")
		if hasFile then
			-- Modern continue screen with gradient background and better layout
			continueContainer = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0.7, 0, 0.7, 0),
				Position = UDim2.new(0.15, 0, 0.15, 0),
				ZIndex = 2,
				Parent = Utilities.gui
			})

			-- Create gradient background
			local gradientBg = create("Frame")({
				BackgroundColor3 = Color3.fromRGB(30, 30, 40),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 2,
				Parent = continueContainer
			})

			local uiCorner = create("UICorner")({
				CornerRadius = UDim.new(0, 16),
				Parent = gradientBg
			})

			local uiGradient = create("UIGradient")({
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 120, 160)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 60, 100))
				}),
				Rotation = 45,
				Parent = gradientBg
			})

			-- Add decorative Pokeball image
			local pokeDecor = create("ImageLabel")({
				BackgroundTransparency = 1,
				Image = "rbxassetid://5119871511", -- Pokeball image
				ImageTransparency = 0.85,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.4, 0, 0.4, 0),
				Position = UDim2.new(0.8, 0, 0.8, 0),
				ZIndex = 3,
				Parent = gradientBg
			})

			-- Rotate the decoration slightly for visual interest
			spawn(function()
				local startRot = 0
				while pokeDecor and pokeDecor.Parent do
					pokeDecor.Rotation = startRot + math.sin(tick() * 0.5) * 5
					wait(0.03)
				end
			end)

			-- Header with player info
			local headerContainer = create("Frame")({
				BackgroundColor3 = Color3.fromRGB(20, 40, 80),
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0.2, 0),
				ZIndex = 3,
				Parent = gradientBg
			})

			create("UICorner")({
				CornerRadius = UDim.new(0, 12),
				Parent = headerContainer
			})

			-- Continue title with animation
			local titleContainer = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0.6, 0),
				Position = UDim2.new(0.05, 0, 0.2, 0),
				ZIndex = 4,
				Parent = headerContainer
			})

			write("Continue Your Adventure")({
				Frame = titleContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = Color3.fromRGB(255, 255, 255)
			})

			-- Player info section
			local infoContainer = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0.9, 0, 0.65, 0),
				Position = UDim2.new(0.05, 0, 0.25, 0),
				ZIndex = 3,
				Parent = gradientBg
			})

			-- Player name with icon - use player's actual headshot
			local nameIcon = create("ImageLabel")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0.08, 0, 0.08, 0),
				Position = UDim2.new(0.02, 0, 0.2, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = 4,
				Parent = infoContainer
			})

			-- Get player's headshot using Roblox API
			spawn(function()
				local Players = game:GetService("Players")
				local player = Players.LocalPlayer

				if player then
					local success, content = pcall(function()
						return Players:GetUserThumbnailAsync(
							player.UserId,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size150x150
						)
					end)

					if success and content then
						nameIcon.Image = content

						-- Add circular mask
						local uiCorner = create("UICorner")({
							CornerRadius = UDim.new(1, 0), -- Make it fully circular
							Parent = nameIcon
						})
					else
						-- Fallback to default icon if API call fails
						nameIcon.Image = "rbxassetid://5119871241"
					end
				else
					-- Fallback to default icon if player not found
					nameIcon.Image = "rbxassetid://5119871241"
				end
			end)

			write("Trainer:")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.08, 0),
					Position = UDim2.new(0.12, 0, 0.2, 0),
					ZIndex = 4,
					Parent = infoContainer
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = Color3.fromRGB(220, 230, 255)
			})

			write(name)({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.08, 0),
					Position = UDim2.new(0.95, 0, 0.2, 0),
					ZIndex = 4,
					Parent = infoContainer
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				Color = Color3.fromRGB(255, 255, 255)
			})

			-- Badges with icon
			local badgeIcon = create("ImageLabel")({
				BackgroundTransparency = 1,
				Image = "rbxassetid://5210432141", -- Badge icon
				Size = UDim2.new(0.08, 0, 0.08, 0),
				Position = UDim2.new(0.02, 0, 0.4, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = 4,
				Parent = infoContainer
			})

			write("Badges:")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.08, 0),
					Position = UDim2.new(0.12, 0, 0.4, 0),
					ZIndex = 4,
					Parent = infoContainer
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = Color3.fromRGB(220, 230, 255)
			})

			write(tostring(badges))({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.08, 0),
					Position = UDim2.new(0.95, 0, 0.4, 0),
					ZIndex = 4,
					Parent = infoContainer
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				Color = Color3.fromRGB(255, 255, 255)
			})



			write("Pok[e']dex:")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.08, 0),
					Position = UDim2.new(0.12, 0, 0.6, 0),
					ZIndex = 4,
					Parent = infoContainer
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = Color3.fromRGB(220, 230, 255)
			})

			write(tostring(pokedex))({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.08, 0),
					Position = UDim2.new(0.95, 0, 0.6, 0),
					ZIndex = 4,
					Parent = infoContainer
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				Color = Color3.fromRGB(255, 255, 255)
			})

			-- Continue button
			continue = _p.RoundedFrame:new({
				Button = true,
				CornerRadius = 12,
				BackgroundColor3 = Color3.fromRGB(60, 180, 140),
				Size = UDim2.new(0.4, 0, 0.12, 0),
				Position = UDim2.new(0.05, 0, 0.83, 0),
				ZIndex = 4,
				Parent = gradientBg,
				MouseButton1Click = function()
					sig:fire("continue")
				end
			})

			-- Button hover effect
			local continueOrigColor = continue.BackgroundColor3
			continue.gui.MouseEnter:Connect(function()
				Utilities.Tween(0.3, "easeOutQuad", function(a)
					continue.BackgroundColor3 = Color3.fromRGB(
						continueOrigColor.R * 255 + 20 * a,
						continueOrigColor.G * 255 + 20 * a,
						continueOrigColor.B * 255 + 20 * a
					)
				end)
			end)

			continue.gui.MouseLeave:Connect(function()
				Utilities.Tween(0.3, "easeOutQuad", function(a)
					continue.BackgroundColor3 = Color3.fromRGB(
						continueOrigColor.R * 255 + 20 * (1-a),
						continueOrigColor.G * 255 + 20 * (1-a),
						continueOrigColor.B * 255 + 20 * (1-a)
					)
				end)
			end)

			write("Continue")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.6, 0),
					Position = UDim2.new(0.5, 0, 0.2, 0),
					ZIndex = 5,
					Parent = continue.gui
				}),
				Scaled = true,
				Color = Color3.fromRGB(255, 255, 255)
			})

			-- New Game button (now on the same axis as Continue)
			newgame = _p.RoundedFrame:new({
				Button = true,
				CornerRadius = 12,
				BackgroundColor3 = Color3.fromRGB(220, 80, 80),
				Size = UDim2.new(0.4, 0, 0.12, 0),
				Position = UDim2.new(0.55, 0, 0.83, 0),
				ZIndex = 4,
				Parent = gradientBg,
				MouseButton1Click = function()
					sig:fire('newgame')
					wait(3)
				end,
			})

			-- Button hover effect
			local newgameOrigColor = newgame.BackgroundColor3
			newgame.gui.MouseEnter:Connect(function()
				Utilities.Tween(0.3, "easeOutQuad", function(a)
					newgame.BackgroundColor3 = Color3.fromRGB(
						newgameOrigColor.R * 255 + 20 * a,
						newgameOrigColor.G * 255 + 20 * a,
						newgameOrigColor.B * 255 + 20 * a
					)
				end)
			end)

			newgame.gui.MouseLeave:Connect(function()
				Utilities.Tween(0.3, "easeOutQuad", function(a)
					newgame.BackgroundColor3 = Color3.fromRGB(
						newgameOrigColor.R * 255 + 20 * (1-a),
						newgameOrigColor.G * 255 + 20 * (1-a),
						newgameOrigColor.B * 255 + 20 * (1-a)
					)
				end)
			end)

			write('New Game')({
				Frame = create('Frame')({
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.6, 0),
					Position = UDim2.new(0.5, 0, 0.2, 0),
					ZIndex = 5, 
					Parent = newgame.gui,
				}), 
				Scaled = true, 
				Color = Color3.fromRGB(255, 255, 255)
			})
		else
			-- New player screen
			write("Are you ready to")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.1, 0),
					Position = UDim2.new(0.5, 0, 0.25, 0),
					ZIndex = 3,
					Parent = bg
				}),
				Scaled = true
			})
			write("start your adventure?")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.1, 0),
					Position = UDim2.new(0.5, 0, 0.4, 0),
					ZIndex = 3,
					Parent = bg
				}),
				Scaled = true
			})

			-- For new player, create a single centered New Game button
			newgame = _p.RoundedFrame:new {
				Button = true, 
				CornerRadius = 12,
				BackgroundColor3 = Color3.fromRGB(60, 180, 140),
				Size = UDim2.new(0.45, 0, 0.16, 0),
				Position = UDim2.new(0.275, 0, 0.65, 0),
				ZIndex = 4, 
				Parent = Utilities.gui,
				MouseButton1Click = function()
					sig:fire('newgame')
					wait(3)
				end,
			}

			-- Button hover effect
			local newgameOrigColor = newgame.BackgroundColor3
			newgame.gui.MouseEnter:Connect(function()
				Utilities.Tween(0.3, "easeOutQuad", function(a)
					newgame.BackgroundColor3 = Color3.fromRGB(
						newgameOrigColor.R * 255 + 20 * a,
						newgameOrigColor.G * 255 + 20 * a,
						newgameOrigColor.B * 255 + 20 * a
					)
				end)
			end)

			newgame.gui.MouseLeave:Connect(function()
				Utilities.Tween(0.3, "easeOutQuad", function(a)
					newgame.BackgroundColor3 = Color3.fromRGB(
						newgameOrigColor.R * 255 + 20 * (1-a),
						newgameOrigColor.G * 255 + 20 * (1-a),
						newgameOrigColor.B * 255 + 20 * (1-a)
					)
				end)
			end)

			write 'New Game' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.6, 0),
					Position = UDim2.new(0.5, 0, 0.2, 0),
					ZIndex = 5, 
					Parent = newgame.gui,
				}, Scaled = true, Color = Color3.fromRGB(255, 255, 255)
			}
		end

		-- Version number
		pcall(function()
			write(_p.storage.Version.Value)({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.04, 0),
					Position = UDim2.new(0.98, 0, 0.935, 0),
					ZIndex = 3,
					Parent = bg
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Right
			})
		end)

		-- Continue with existing code
		local cm = Utilities.loopSound(_p.musicId.ContinueScreen, .6)--.4)
		Utilities.Tween(.5, nil, function(a) if skipped then return false end
			fader.BackgroundTransparency = a
		end)
		if skipped then fader.BackgroundTransparency = 1.0 end

		local v = cm.Volume
		local choice
		while true do
			choice = sig:wait()
			Utilities.Tween(.5, nil, function(a)
				local o = 1-a
				cm.Volume = v*o
				fader.BackgroundTransparency = o
			end)
			if choice ~= 'newgame' or not hasFile then break end
			local confirmNewGame = _p.NPCChat:say('You are starting a New Game.', 'Your previous data has not been overwritten.',
				'However, if you choose to Save after starting a new game, your previous data will then be lost.',
				'Overwritten data CANNOT be recovered.', '[y/n]Are you sure you want to start a New Game?')
			if confirmNewGame then break end
			Utilities.Tween(.5, nil, function(a)
				cm.Volume = v*a
				fader.BackgroundTransparency = a
			end)
		end
		cm:Stop()
		cm:remove()

		-- Safe cleanup of UI elements with nil checks
		if continue then 
			pcall(function() continue:remove() end)
		end

		if continueContainer then 
			pcall(function() continueContainer:remove() end)
		end

		if newgame then
			pcall(function() newgame:remove() end)
		end

		bg:remove()
		loadFn()
		pcall(function() c:disconnect() end)
		if choice == 'newgame' then
			local st = tick()
			_p.Network:get('PDS', 'startNewGame')
			if hasFile then
				_p.Menu.willOverwriteIfSaveFlag = true
			end
			_p.DataManager:loadMap('chunk1')
			local et = tick()-st
			if et < 3 then wait(3-et) end
			--			_p.PlayerData.party = {}
			_p.PlayerData.gameBegan = true
			self:newGame(fader)
		else
			local s, etc = _p.Network:get('PDS', 'continueGame')
			if s then
				_p.PlayerData:loadEtc(etc)
			else
				error('FAILED TO CONTINUE')
			end
			Utilities.Tween(.5, nil, function(a)
				fader.BackgroundTransparency = a
			end)
			fader:remove()
		end
		--		_p.loadedData = nil

	end


	return intro end