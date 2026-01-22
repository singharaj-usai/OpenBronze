return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create

	local manaphy = Utilities.rc4('Manaphy')

	return {
		hackableShrubbery = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.DataManager:preload(316598829)
			local trunk = model.CutKit.Main
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(trunk.Position) end)
			local cutter, done
			Utilities.fastSpawn(function()
				cutter = _p.Network:get('PDS', 'getCutter')
				done = true
			end)
			chat:say('This tree looks like it can be cut down.')
			while not done do wait() end
			if not cutter or not chat:say('[y/n]Would you like ' .. cutter .. ' to use Cut?') then
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				return
			end
			chat:say(cutter .. ' used Cut!')
			pcall(function() model['#InanimateInteract']:remove() end)
			local slashEffect = model.CutKit.SlashEffect
			local size = slashEffect.Size
			slashEffect.Parent = model
			local playerPos = _p.player.Character.HumanoidRootPart.CFrame
			local cf = CFrame.new(trunk.Position, Vector3.new(playerPos.X, trunk.CFrame.Y, playerPos.Z))
			Utilities.sound(316598829, nil, nil, 5)
			Utilities.Tween(.35, nil, function(a)
				slashEffect.Size = size*(0.2+1.2*math.sin(a*math.pi))
				slashEffect.CFrame = cf * CFrame.new(-3+6*a, 3-6*a, -2.5) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.pi/4, 0, 0)
			end)
			slashEffect:remove()
			model.Main:remove()
			Utilities.MoveModel(trunk, cf)
			create 'Weld' {
				Part0 = model.CutKit.Top,
				Part1 = model.TreePart,
				C0 = CFrame.new(),
				C1 = model.TreePart.CFrame:inverse() * model.CutKit.Top.CFrame,
				Parent = model.CutKit.Top,
			}
			model.TreePart.Anchored = false
			model.CutKit.Top.Anchored = false
			local force = create 'BodyForce' {
				Force = -cf.lookVector * 5000,
				Parent = model.CutKit.Top,
			}
			local force2 = create 'BodyForce' {
				Force = -cf.lookVector * 9000,
				Parent = model.TreePart,
			}
			wait(.5)
			--		pcall(function()
			--			if model.Parent.Name == 'ChristmasTrees' then
			--				local cutall = true
			--				for _, tree in pairs(model.Parent:GetChildren()) do
			--					if tree:FindFirstChild('#InanimateInteract') then
			--						cutall = false
			--						break
			--					end
			--				end
			--				if cutall then
			--					_p.Events.onCutAllChristmasTrees()
			--				end
			--			end
			--		end)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
			force:remove()
			force2:remove()
			wait(1)
			Utilities.Tween(1, nil, function(a)
				model.CutKit.Top.Transparency = a
				model.CutKit.Base.Transparency = a
				model.TreePart.Transparency = a
			end)
			model.CutKit:remove()
			model.TreePart:remove()
		end,

		durantHill = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			local digger, done
			Utilities.fastSpawn(function()
				digger = _p.Network:get('PDS', 'getDigger')
				done = true
			end)
			chat:say('This pile of dirt seems to have been made by a pokemon.')
			if not digger or not chat:say('[y/n]Would you like ' .. digger .. ' to use Dig?') then
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				return
			end
			chat:say(digger .. ' used Dig!')
			pcall(function() model['#InanimateInteract']:remove() end)
			model.Part:remove()
			model.Main.Transparency = 1.0
			model.Main.CanCollide = false
			local smoke = create 'Smoke' {
				Color = BrickColor.new('Brown').Color,
				Parent = model.Main,
			}
			delay(10, function()
				smoke:remove()
			end)
			wait(.5)
			smoke.Enabled = false
			wait(1.5)
			if math.random(10) <= 3 then
				_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Anthill, {battleSceneType = 'Safari'})
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		spiritombWell = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)

			if _p.PlayerData.hasOddKeystone then
				if chat:say('Whispers can be heard coming from deep within the well.',
					'The Odd Keystone in your Bag is rumbling...',
					'[y/n]Toss the Odd Keystone into the well?')
				then
					chat:say('You tossed the Odd Keystone into the well.')
					model.SmokePart.Smoke.Enabled = true
					local cf = CFrame.new(model.Main.Position + Vector3.new(0, -model.Main.Size.X/2+.1, 0))
					for i = 1, 3 do
						local pulse = create 'Part' {
							Transparency = 1,
							Anchored = true,
							CanCollide = false,
							Parent = model,
						}
						local sg = create 'SurfaceGui' {
							CanvasSize = Vector2.new(600, 600),
							Face = Enum.NormalId.Top,
							Adornee = pulse,
							Parent = pulse,
						}
						local image = create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://6142896054',
							ImageColor3 = Color3.new(.5, 0, 1),
							Size = UDim2.new(1.0, 0, 1.0, 0),
							Parent = sg,
						}
						spawn(function()
							Utilities.Tween(1.5, nil, function(a)
								pulse.Size = Vector3.new(5+a*10, 0.2, 5+a*10)
								pulse.CFrame = cf
								if a > .75 then
									image.ImageTransparency = (a-.75)*4
								end
							end)
							pulse:remove()
						end)
						wait(1)
					end
					delay(5, function()
						model.SmokePart.Smoke.Enabled = false
					end)
					_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Well, {battleSceneType = 'SpiritombWell'})
					_p.PlayerData.hasOddKeystone = _p.Network:get('PDS', 'hasOKS')
				end
			else
				chat:say('This well looks really old...')
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		headbuttablePalmTree = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.DataManager:preload(330262909)-- preload sound
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			local headbutter, done
			Utilities.fastSpawn(function()
				headbutter = _p.Network:get('PDS', 'getHeadbutter')
				done = true
			end)
			chat:say('It\'s a large palm tree that could possibly be the home to small pokemon.')
			while not done do wait() end
			if headbutter and chat:say('[y/n]Would you like ' .. headbutter .. ' to use Headbutt?') then
				chat:say(headbutter .. ' used Headbutt!')
				local p = model.Main.Position + Vector3.new(0, -model.Main.Size.Y/2+0.8, 0)
				local cf = CFrame.new(p, p + (p-_p.player.Character.HumanoidRootPart.Position)*Vector3.new(1, 0, 1))
				local cfs = {}
				for _, ch in pairs(model:GetChildren()) do
					if ch:IsA('BasePart') then
						cfs[ch] = cf:toObjectSpace(ch.CFrame)
					end
				end
				local pow = _p.storage.Modelss.Misc.Pow:Clone()
				pow.Parent = workspace
				local ps = pow.Size*.7
				pow.CFrame = cf * CFrame.new(0, model.Main.Size.Y/2, model.Main.Size.Z/2+.4) * CFrame.Angles(0, math.pi/2, 0)
				local particlePart = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(10, 1, 10),
					CFrame = model.Main.CFrame * CFrame.new(0, 25, 0),
					Parent = workspace,
				}
				local emitter = create 'ParticleEmitter' {
					EmissionDirection = Enum.NormalId.Bottom,
					Color = ColorSequence.new(BrickColor.new('Bright green').Color),
					Lifetime = NumberRange.new(26),
					Rate = 12,
					Speed = NumberRange.new(5),
					RotSpeed = NumberRange.new(-50, 50),
					Texture = 'rbxassetid://5217700605',--330258890
					Parent = particlePart,
				}
				game:GetService('Debris'):AddItem(particlePart, 11)
				Utilities.sound(330262909, nil, nil, 5)
				Utilities.Tween(1.25, nil, function(a)
					if pow then
						if a > .4 then
							pow:remove()
							pow = nil
							emitter.Enabled = false
						else
							if a > .2 then
								pow.Transparency = (a-.2)*5
							end
							pow.Size = ps * (1+a)
							--						pow.CFrame = pcf * CFrame.Angles(a*2, 0, 0)
						end
					end
					local ncf = cf*CFrame.Angles(-math.sin(a*math.pi*2)*.4*(1-a), 0, 0)
					for part, rcf in pairs(cfs) do
						part.CFrame = ncf:toWorldSpace(rcf)
					end
				end)
				wait(1)
				local enc
				pcall(function() enc = _p.DataManager.currentChunk.regionData.PalmTree end)
				if enc and math.random(10) <= 5 then
					_p.Battle:doWildBattle(enc)
				end
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		headbuttablePineTree = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.DataManager:preload(330262909)
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			local headbutter, done
			Utilities.fastSpawn(function()
				headbutter = _p.Network:get('PDS', 'getHeadbutter')
				done = true
			end)
			chat:say('It\'s a tall tree that could possibly be the home to small pokemon.')
			while not done do wait() end
			if headbutter and chat:say('[y/n]Would you like ' .. headbutter .. ' to use Headbutt?') then
				chat:say(headbutter .. ' used Headbutt!')
				local p = model.Main.Position + Vector3.new(0, -model.Main.Size.Y/2+2, 0)
				local cf = CFrame.new(p, p + (p-_p.player.Character.HumanoidRootPart.Position)*Vector3.new(1, 0, 1))
				local cfs = {}
				for _, ch in pairs(model:GetChildren()) do
					if ch:IsA('BasePart') then
						cfs[ch] = cf:toObjectSpace(ch.CFrame)
					end
				end
				local pow = _p.storage.Modelss.Misc.Pow:Clone()
				pow.Parent = workspace
				local ps = pow.Size*.7
				pow.CFrame = cf * CFrame.new(0, 3.5, model.Main.Size.Z/2+1) * CFrame.Angles(0, math.pi/2, 0)
				local particlePart = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(10, 1, 10),
					CFrame = model.Main.CFrame * CFrame.new(0, 25, 0),
					Parent = workspace,
				}
				local emitter = create 'ParticleEmitter' {
					EmissionDirection = Enum.NormalId.Bottom,
					--				Color = ColorSequence.new(BrickColor.new('Bright green').Color),
					Size = NumberSequence.new(.3),
					Lifetime = NumberRange.new(26),
					Rate = 12,
					Speed = NumberRange.new(5),
					RotSpeed = NumberRange.new(-50, 50),
					Texture = 'rbxassetid://5217702038',
					Parent = particlePart,
				}
				game:GetService('Debris'):AddItem(particlePart, 11)
				Utilities.sound(330262909, nil, nil, 5)
				Utilities.Tween(1.25, nil, function(a)
					if pow then
						if a > .4 then
							pow:remove()
							pow = nil
							emitter.Enabled = false
						else
							if a > .2 then
								pow.Transparency = (a-.2)*5
							end
							pow.Size = ps * (1+a)
							--						pow.CFrame = pcf * CFrame.Angles(a*2, 0, 0)
						end
					end
					local ncf = cf*CFrame.Angles(-math.sin(a*math.pi*2)*.4*(1-a), 0, 0)
					for part, rcf in pairs(cfs) do
						part.CFrame = ncf:toWorldSpace(rcf)
					end
				end)
				wait(1)
				local enc
				pcall(function() enc = _p.DataManager.currentChunk.regionData.PineTree end)
				if enc and math.random(10) <= 5 then
					_p.Battle:doWildBattle(enc)
				end
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		Water = function(_, pos)
			_p.Fishing:OnWaterClicked(pos)
		end,

		SpookyBook = function(model)
			pcall(function() model['#InanimateInteract']:remove() end)
			local m = Instance.new('Model', model)
			local mm = Utilities.MoveModel
			for _, ch in pairs(model:GetChildren()) do
				if ch.Name == 'Top' then
					ch.Parent = m
				end
			end
			local hinge = model.Hinge
			hinge.Parent = m
			local hcf = hinge.CFrame
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				mm(hinge, hcf * CFrame.Angles(0, -math.pi*0.5*a, 0))
			end)
			local button = model.Button
			local bm = Instance.new('Model', model)
			button.Parent = bm
			button.Name = 'Main'
			create 'StringValue' {
				Name = '#InanimateInteract',
				Value = 'SpookyBookButton',
				Parent = bm,
			}
		end,

		SpookyBookButton = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			local chunk = _p.DataManager.currentChunk
			local room = chunk:topRoom()

			local wardrobe = room.model.Wardrobe
			spawn(function() _p.MasterControl:LookAt(wardrobe.Main.Position) end)

			local cam = workspace.CurrentCamera
			chunk:unbindIndoorCam()
			do
				local startCF = cam.CoordinateFrame
				local p = Vector3.new(wardrobe.Main.Position.X + 10, room.model.Base.Position.Y + room.model.Base.Size.Y/2 + 4.5, wardrobe.Main.Position.Z)
				local angle = math.rad(40)
				local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*18
				local endCF = CFrame.new(from, p)
				local lerp = select(2, Utilities.lerpCFrame(startCF, endCF))
				Utilities.Tween(.75, 'easeOutCubic', function(a)
					cam.CoordinateFrame = startCF + (from - startCF.p) * a
				end)
			end

			local main = wardrobe.Main
			local wcf = main.CFrame
			local lhp, rhp, lh, rh = wardrobe.LDoor.Hinge, wardrobe.RDoor.Hinge, wardrobe.LHinge, wardrobe.RHinge
			local mm = Utilities.MoveModel
			Utilities.sound(360064127, .8, nil, 5)
			Utilities.Tween(.75, 'easeOutCubic', function(a)
				mm(main, wcf * CFrame.Angles(math.sin(a*math.pi*2)*-0.1, 0, math.sin(a*math.pi)*0.2))
				mm(lhp, lh.CFrame * CFrame.Angles(0, 3*a, 0))
				mm(rhp, rh.CFrame * CFrame.Angles(0, -3*a, 0))
			end)

			do
				local startCF = cam.CoordinateFrame
				local p = room.model.Base.Position + Vector3.new(0, room.model.Base.Size.Y/2 + 4.5, 0)
				local angle = math.rad(30)
				local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*25
				local endCF = CFrame.new(from, p)
				local lerp = select(2, Utilities.lerpCFrame(startCF, endCF))
				Utilities.Tween(.75, 'easeOutCubic', function(a)
					cam.CoordinateFrame = lerp(a)
				end)
			end

			local st = tick()
			local sucking = true
			local endPoint = wardrobe.Main.Position + Vector3.new(0, 2.5, 0)
			local function particle()
				local size = .4 + math.random()*.6
				local part = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					--				FormFactor = Enum.FormFactor.Custom,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local frame = create 'Frame' {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(.7, .7, .7),
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Parent = create 'BillboardGui' {
						Size = UDim2.new(size, 0, size, 0),
						Adornee = part, Parent = part,
					}
				}
				local startRotation = math.random(360)
				local deltaRotation = math.random(-360, 360) * 3
				local startPoint = endPoint + Vector3.new(20 + math.random(10), math.random(-5, 5), math.random(-10, 10))
				local moveVector = endPoint - startPoint
				local duration = 1.5 - math.min(1, (tick() - st)/2)
				Utilities.Tween(duration, 'easeInCubic', function(a)
					if not sucking then return false end
					frame.BackgroundTransparency = 1-a
					frame.Rotation = startRotation + deltaRotation * a
					part.CFrame = CFrame.new(startPoint + moveVector * a)
				end)
				part:remove()
			end
			local whoosh = Utilities.sound(360068426)
			spawn(function()
				while sucking do
					spawn(particle)
					wait(.1)
				end
			end)
			wait(2)
			for _, wedge in pairs(room.model.Funnel:GetChildren()) do
				wedge.CanCollide = true
			end
			local hGoal = endPoint + Vector3.new(2, 0, 0)
			local humanoid = Utilities.getHumanoid()
			local psc = humanoid.Changed:connect(function()
				humanoid.PlatformStand = true
			end)
			humanoid.PlatformStand = true
			local hroot = _p.player.Character.HumanoidRootPart
			local force = create 'BodyForce' {
				Parent = hroot,
			}
			local mf = 3000
			Utilities.Tween(.5, 'easeInCubic', function(a)
				force.Force = (hGoal - hroot.Position).unit * mf * a
			end)
			local antigravs = {}
			local function antigrav(obj)
				if obj:IsA('BasePart') then
					table.insert(antigravs, create 'BodyForce' {
						Force = Vector3.new(0, 196.2 * obj:GetMass(), 0),
						Parent = obj,
					})
				end
				for _, ch in pairs(obj:GetChildren()) do
					antigrav(ch)
				end
			end
			antigrav(_p.player.Character)
			local stepped = game:GetService('RunService').RenderStepped
			while hroot.Position.X > hGoal.X do
				stepped:wait()
				force.Force = (hGoal - hroot.Position).unit * mf
				if force.Force.X > 0 then
					force.Force = force.Force * Vector3.new(0, 1, 1)
				end
			end
			force:remove()
			local bp = create 'BodyPosition' {
				Position = endPoint,
				Parent = hroot,
			}
			spawn(function()
				local v = whoosh.Volume
				Utilities.Tween(1, nil, function(a)
					whoosh.Volume = v * (1-a)
				end)
				whoosh:remove()
			end)
			Utilities.FadeOut(1, Color3.new(0, 0, 0))
			sucking = false
			Utilities.TeleportToSpawnBox()
			chunk:popSubRoom(true)
			room = chunk:stackSubRoom('HMUpperHall', chunk:topRoom().model.SubRoom, true)
			room = chunk:stackSubRoom('HMBadBedroom', room:getDoor('HMBadBedroom'), true)
			bp:remove()
			for _, ag in pairs(antigravs) do ag:remove() end
			local tp = room.model.WardrobeBase.Position + Vector3.new(0, 2.5, 0)
			do
				local p = room.model.Base.Position + Vector3.new(0, room.model.Base.Size.Y/2 + 4.5, 0)
				local angle = math.rad(30)
				local from = p + Vector3.new(0, math.sin(angle), -math.cos(angle))*25
				cam.CoordinateFrame = CFrame.new(from, p)
			end
			wait(1)
			Utilities.FadeIn(1)
			Utilities.Teleport(CFrame.new(tp.x, tp.y, tp.z, 0, 1, 0, 0, 0, 1, 1, 0, 0))
			hroot.RotVelocity = Vector3.new()
			hroot.Velocity = Vector3.new(50, 0, 0)
			do
				local startCF = cam.CoordinateFrame
				local angle = math.rad(40)
				local offset = Vector3.new(0, math.sin(angle), -math.cos(angle))*18
				local lcf = Utilities.lerpCFrame
				Utilities.Tween(.75, 'easeOutCubic', function(a)
					local p = hroot.CFrame * Vector3.new(0, 1.5, 0)
					p = Vector3.new(math.max(room.indoorCamMinX, math.min(room.indoorCamMaxX, p.x)), p.y, p.z)
					local from = p + offset
					cam.CoordinateFrame = select(2, lcf(startCF, CFrame.new(from, p)))(a)
				end)
			end
			chunk:bindIndoorCam()
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
			psc:disconnect()
			humanoid.PlatformStand = false
		end,

		-- Rotom Event Click-Helpers
		HauntedJukebox = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedJukeboxClicked(model)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,
		HauntedComputer = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedComputerClicked(model)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,
		HauntedToaster = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedToasterClicked(model)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,
		HauntedTelevision = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedTelevisionClicked(model)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,
		HauntedHairDryer = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedHairDryerClicked(model)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,
		HauntedBabyMonitor = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedBabyMonitorClicked(model)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,
		HauntedGameBoy = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			pcall(function() model['#InanimateInteract']:remove() end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Events.onHauntedGameBoyClicked(model)
			--_p.MasterControl:Start()
			_p.MasterControl.WalkEnabled = true
		end,

		JirachiMonument = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			chat:say('"Under sky alight with stars shall the wish made upon the pedestal of dreams come true."')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		Pansage = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk14' then return end
			local enc
			pcall(function() enc = chunk.regionData.Sage end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say(model.Main, 'Sa sa sage!')
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		Pansear = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk14' then return end
			local enc
			pcall(function() enc = chunk.regionData.Sear end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say(model.Main, 'Sear sear!')
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		Panpour = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk14' then return end
			local enc
			pcall(function() enc = chunk.regionData.Pour end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say(model.Main, 'Po pour!')
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

--[[	ManaphyEgg = function(model)
		if not _p.MasterControl.WalkEnabled then return end
		local chunk = _p.DataManager.currentChunk
		if not chunk or chunk.id ~= 'chunk11' then return end
		
--		pcall(function() model['#InanimateInteract']:remove() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		if #_p.PlayerData.party >= 6 then
			_p.NPCChat:say('It\'s a mysterious pokemon Egg.',
				'There\'s no room in your party for it.')
		elseif _p.Network:get('GrabManaphyEgg') then--_p.storage.Remote.PickUpManaphyEgg:InvokeServer() then
			table.insert(_p.PlayerData.party, _p.Pokemon:new {
				name = Utilities.rc4(manaphy),
				egg = true,
				shinyChance = 4096,
			})
			Utilities.sound(304774035, nil, nil, 8)
			_p.NPCChat:say(_p.PlayerData.trainerName .. ' found an Egg!',
				_p.PlayerData.trainerName .. ' put the Egg in the party.')
		end
		_p.MasterControl.WalkEnabled = true
	end,]]

		Drifloon = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk15' then return end
			local enc
			pcall(function() enc = chunk.regionData.Windmill end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say(model.Main, 'Floooooon!')
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc, {battleSceneType = 'DrifWindmill'})
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		HoneyTree = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk15' then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			local chat = _p.NPCChat
			local honeyData = _p.PlayerData.honey
			if honeyData then
				if honeyData.status > 1 then
					delay(3, function()
						honeyData.status = 0
						model.SlatheredHoney.Transparency = 1.0
						pcall(function() model.HoneyTeddiursa:remove() end)
					end)
					_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.HoneyTree)
				elseif honeyData.status == 1 then
					chat:say('There is honey slathered on this tree.')
				else
					chat:say('This tree looks like a good place to slather honey to attract wild pokemon.')
					if honeyData.has then
						if chat:say('[y/n]Would you like to slather some honey?') then
							honeyData.status = 1
							_p.Network:post('PDS', 'slatherHoney')
							chat:say('You slathered honey on the tree.')
							pcall(function() model.SlatheredHoney.Transparency = .2 end)
						end
					end
				end
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		gym4tool = function(model)
			local chat = _p.NPCChat
			if model.Name == 'MeasuringTape' then
				chat:say('It\'s a measuring tape.')
				model:remove()
				chat:say('This might come in handy.')
				_p.PlayerData:completeEvent('G4FoundTape')
			elseif model.Name == 'Wrench' then
				chat:say('It\'s a wrench with worm gear adjustment.')
				model:remove()
				chat:say('This might come in handy.')
				_p.PlayerData:completeEvent('G4FoundWrench')
			elseif model.Name == 'Hammer' then
				chat:say('It\'s an ordinary hammer.')
				model:remove()
				chat:say('This might come in handy.')
				_p.PlayerData:completeEvent('G4FoundHammer')
			end
		end,

		EmptyDumpster = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			chat:say('It\'s a stinky dumpster.')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		FullDumpster = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			pcall(function() model['#InanimateInteract'].Value = 'EmptyDumpster' end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 18856424984, startTime = 57.68, duration = 1.24}) end)--cr10
			wait(.8)
			spawn(function()
				local lid = model.Lid
				local parts = {}
				local main = lid.Hinge
				local mcf = main.CFrame
				local function index(obj)
					for _, ch in pairs(obj:GetChildren()) do
						if ch:IsA('BasePart') and ch ~= main then
							parts[ch] = mcf:toObjectSpace(ch.CFrame)
						end
					end
				end
				index(lid)
				Utilities.Tween(.7, 'easeOutCubic', function(a)
					local cf = mcf * CFrame.Angles(0, 0, -math.pi*3/2*a)
					for p, rcf in pairs(parts) do
						p.CFrame = cf:toWorldSpace(rcf)
					end
					main.CFrame = cf
				end)
				delay(3, function()
					for p, rcf in pairs(parts) do
						p.CFrame = mcf:toWorldSpace(rcf)
					end
					main.CFrame = mcf
				end)
			end)
			wait(.7)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Dumpster, {battleSceneType = 'Trash'})
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		-- [[	
		SantaClaus = function(model) -- to make it easy to unify the 3 santas in different chunks
			local santa = _p.DataManager.currentChunk.npcs.Santa
			if not santa or not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			local chunkId = model.Parent.Name
			_p.DataManager:preload(576438342, 576461904)

			spawn(function() santa:LookAt(_p.player.Character.Head.Position) end)
			spawn(function() _p.MasterControl:LookAt(model.Head.Position) end)

			if not _p.PlayerData.completedEvents.BeatSanta then
				if chunkId == 'chunk5' then _p.NPCChat.bottom = true end
				santa:Say('Ho ho ho, look who it is, little '.._p.PlayerData.trainerName..'.',
					'You\'ve been very good this year.', 'Oh what\'s that?',
					'You\'re not here to settle your own account?',
					'You wanna know about the lawyer from Anthian City, eh?',
					'He\'s been very naughty lately.',
					'I went to court a few years ago for a reindeer speeding violation and it was his fault I lost and I had to pay the ticket.',
					'I haven\'t forgiven him since.',
					'I\'ll make a deal with you though, for working so hard to find me.',
					'If you beat me in a battle, I will put him back on the nice list.',
					'I can\'t resist a good battle.')
				_p.NPCChat.bottom = nil
				local win = _p.Battle:doTrainerBattle {
					musicId = 576461904,
					PreventMoveAfter = true,
					vs = {name = 'Santa', id = 576438342, hue = 0, sat = .5, val = .7},
					trainerModel = model,
					num = 120
				}

				if win then
					if chunkId == 'chunk5' then _p.NPCChat.bottom = true end
					santa:Say('Well, I made a deal and I\'m a man of my word.',
						'You let that lawyer know that he\'ll be put back on the nice list this year.',
						'You can also let him know that he\'s terrible at his job and charges way too much money.',
						'Anyways, I better be off for now.', 'I\'m very busy this time of year.',
						'Maybe I\'ll see you again next year.')
					_p.NPCChat.bottom = nil
					Utilities.FadeOut(.5)
					santa:remove()
					wait(.5)
					Utilities.FadeIn(.5)
				end
			end
			-- these all 3 need to be enabled, I think, because we use tag "PreventMoveAfter"
			_p.NPCChat:enable()
			_p.MasterControl.WalkEnabled = true
			spawn(function() _p.Menu:enable() end)
		end,
		--]]

--[[		
		Mrbobbilly = function(model) -- 
		local bob = _p.DataManager.currentChunk.npcs.Bob
		if not bob or not _p.MasterControl.WalkEnabled then return end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		local chunkId = model.Parent.Name
		_p.DataManager:preload(5589806258, 315131669)
		
		spawn(function() bob:LookAt(_p.player.Character.Head.Position) end)
		spawn(function() _p.MasterControl:LookAt(model.Head.Position) end)
		
		if not _p.PlayerData.completedEvents.BeatBob2 then
			if chunkId == 'chunk21' then _p.NPCChat.bottom = true end
			bob:Say('Well look who it is, it\'s '.._p.PlayerData.trainerName..'.',
					'I\'ve heard you\'ve done many great things on your adventure up to this point.', 
					'You look like a very capable trainer if I say so myself.',
					'Oh what\'s that?',
				'You spoke to the guy over at the housing district?',
				'You wanna know about him?',
				'He\'s been very mean lately.',
				'He has taken a few of my favorite Mons from me and I haven\'t seen it since.',
				
				'I\'ll make a deal since you worked so hard to try to find me.',
				'If you beat me in a battle, I will forgive him.',
				'I just can\'t resist a good battle!')
			_p.NPCChat.bottom = nil
		local win = _p.Battle:doTrainerBattle {
				battleScene = 'BattleDistrict',
				musicId = 315131669,
				PreventMoveAfter = true,
				vs = {name = 'Mrbobbilly', id = 5589806258, hue = 0, sat = .5, val = .7},
				trainerModel = model,
				num = 188
			}
			
			if win then
				if chunkId == 'chunk21' then _p.NPCChat.bottom = true end
				bob:Say('Well, I made a deal and you won.',
					'You let that guy know I forgive him.',
					'You also let him know that he\'s can\'t do this again.',
					'Anyways, that was a nice battle but I got to get going.', 'I\'m actually behind my schedule.',
					'Maybe I\'ll see you again soon!')
				_p.NPCChat.bottom = nil
				Utilities.FadeOut(.5)
				bob:remove()
				wait(.5)
				Utilities.FadeIn(.5)
			end
		end
		
		_p.NPCChat:enable()
		_p.MasterControl.WalkEnabled = true
		spawn(function() _p.Menu:enable() end)
	end,
--]]		



		ShayminEncounter = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk17' then return end
			local enc
			pcall(function() enc = chunk.regionData.Grace end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 18856423150, startTime = 25.60, duration = 1.82}) end)--cr9
			_p.NPCChat:say(model.Main, 'Shayyyyy!')
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 9537298254})--jb
			_p.NPCChat:say('Shaymin can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		mashableMineral = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			--		_p.DataManager:preload(TODO)
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local main = model.Main
			spawn(function() _p.MasterControl:LookAt(main.Position) end)
			local smasher, rm, enc, done
			Utilities.fastSpawn(function()
				smasher, rm, enc = _p.Network:get('PDS', 'getSmasher')
				done = true
			end)
			chat:say('It\'s a cracked boulder.', 'A pokemon may be able to break it.')
			while not done do wait() end
			if not smasher or not rm or not chat:say('[y/n]Would you like ' .. smasher .. ' to use Rock Smash?') then
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				return
			end
			local isKey = model.Name == 'KeyRockSmash'
			chat:say(smasher .. ' used Rock Smash!')
			--		pcall(function() model['#InanimateInteract']:remove() end)

			local cf = main.CFrame
			local scale = main.Size.Magnitude / 14.847123146057
			--		Utilities.sound(TODO, nil, nil, 5)
			Utilities.ScaleModel(rm.Main, scale)
			Utilities.MoveModel(rm.Main, cf)
			rm.Main:remove()--rm.Main.Transparency = 1; rm.Main.Size = Vector3.new(1,1,1); rm.Main.CanCollide = true--
			model:remove()
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
					delay(.25, function() force:remove() end)
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
			rm:remove()
			if enc and not isKey then
				_p.Battle:doWildBattle(enc)
			else
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
			end
		end,

		jewelStand = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			local events = _p.PlayerData.completedEvents
			if not events.RJO then
				chat:say('It\'s a column with strange indentations.', 'It is unclear what purpose it serves.')
			else
				if events.RJO and not events.RJP then
					spawn(function() _p.PlayerData:completeEvent('RJP') end)
					chat:say('You placed the King\'s Red Jewel in the slot on the column.')
					model.RedJewel.Transparency = 0
					-- TODO: rumble sound/camera?
					chat:say('A rumble can be heard from deep within the ruins.')
				elseif events.GJO and not events.GJP then
					spawn(function() _p.PlayerData:completeEvent('GJP') end)
					chat:say('You placed the King\'s Green Jewel in the slot on the column.')
					model.GreenJewel.Transparency = 0
					-- TODO: rumble sound/camera?
					chat:say('A rumble can be heard from deep within the ruins.')
				elseif events.PJO and not events.PJP then
					spawn(function() _p.PlayerData:completeEvent('PJP') end)
					chat:say('You placed the King\'s Purple Jewel in the slot on the column.')
					model.PurpleJewel.Transparency = 0
					-- TODO: rumble sound/camera?
					chat:say('A rumble can be heard from deep within the ruins.')
				elseif events.BJO and not events.BJP then
					spawn(function() _p.PlayerData:completeEvent('BJP') end)
					chat:say('You placed the King\'s Blue Jewel in the slot on the column.')
					model.BlueJewel.Transparency = 0
					-- TODO: rumble sound/camera?
					chat:say('A rumble can be heard from somewhere else in the ruins.')
				end
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		restartPuzzleJ = function()
			-- implemented in PuzzleJ module
		end,

		ancientSarcophagus = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			pcall(function() model['#InanimateInteract']:remove() end)
			--		spawn(function() _p.PlayerData:completeEvent('BJO') end)
			local main = model.Main
			local lidcf = model.LidEndLocation.CFrame
			model.LidEndLocation:remove()
			local mcf = main.CFrame
			Utilities.Teleport(CFrame.new(mcf * Vector3.new(3.5, 1, 0), mcf.p))
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = CFrame.new(mcf * Vector3.new(4, 10, 6), mcf.p)
			Utilities.Tween(2, nil, function(a)
				Utilities.MoveModel(main, mcf * CFrame.new(-1.8*a, 0, 0))
			end)
			local lerp = select(2, Utilities.lerpCFrame(main.CFrame, lidcf))
			Utilities.Tween(.4, 'easeInCubic', function(a)
				Utilities.MoveModel(main, lerp(a))
			end)
			wait(1)
			_p.NPCChat:say(_p.PlayerData.trainerName .. ' found one of the King\'s Jewels!',
				'It glimmers a soothing blue color.')
			local chunk = _p.DataManager.currentChunk
			local map = chunk.map
			map.BlueJewel:remove()
			wait(.5)
			Utilities.lookBackAtMe()

			local players = game:GetService('Players')
			local cn; cn = map.MummyBattleTrigger.Touched:connect(function(p)
				if not p or not p.Parent or players:GetPlayerFromCharacter(p.Parent) ~= _p.player then return end
				cn:disconnect()
				_p.Events.onActivateMummy(map.Mummy)
			end)

			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		vicSeal = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()

			local main = model.Main
			local mcf = main.CFrame
			pcall(function() model['#InanimateInteract']:remove() end)
			Utilities.Teleport(mcf * CFrame.new(0, 2.5, 8))
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = CFrame.new(mcf.p + Vector3.new(9, 7, -7), mcf.p + Vector3.new(0, 4, 0))

			_p.MusicManager:stackMusic(608811548, 'BattleMusic', .4)--v

			wait(.5)
			local decal = model.Inscription.Decal
			Utilities.Tween(1, 'easeInCubic', function(a)
				decal.Transparency = a
			end)
			wait(.5)

			local vic = _p.DataManager.currentChunk.map.Victini
			vic.Eyes.Glow1.Transparency = 1
			vic.Eyes.Glow2.Transparency = 1
			_p.DataManager:loadModule('AnchoredRig')
			local vcf = vic.Main.CFrame
			local rig = _p.DataManager:loadModule('AnchoredRig'):new(vic)
			rig:connect(vic, vic.Eyes)
			rig:connect(vic, vic.Mouth)
			rig:connect(vic, vic.RightArm)
			rig:connect(vic, vic.LeftArm)

			rig:reset()
			rig:pose('Victini', vcf)
			rig:pose('Victini', vcf + Vector3.new(0, 7, 0), 3.5, 'easeOutCubic')

			--		wait(.5)
			local orb = create 'Part' {
				Anchored = true,
				CanCollide = false,
				Shape = Enum.PartType.Ball,
				BrickColor = BrickColor.new('Neon orange'),
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Parent = workspace
			}
			local ocf = vcf + Vector3.new(0, 7, 0)
			Utilities.Tween(.25, nil, function(a)
				orb.Size = Vector3.new(6, 6, 6)*a
				orb.CFrame = ocf
			end)
			vic.Eyes.Main.BrickColor = BrickColor.new('Deep blue')
			vic.Eyes.LBlue.BrickColor = BrickColor.new('Pastel Blue')
			vic.Eyes.LBlue.Material = Enum.Material.Ice
			vic.Eyes.Glow1.Transparency = .75
			vic.Eyes.Glow2.Transparency = .75
			vic.Mouth.Closed1:remove()
			vic.Mouth.Closed2:remove()
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 18856423150, startTime = 31.13, duration = .81}) end)--cr9
			Utilities.Tween(.25, nil, function(a)
				orb.Size = Vector3.new(6, 6, 6)*(1+a)
				orb.CFrame = ocf
				orb.Transparency = a
			end)
			orb:remove()

			rig:poses(
				{'Victini', vcf + Vector3.new(0, 5.5, 0), 2, 'easeOutCubic'},
				{'LeftArm',  CFrame.Angles(0, 0, -.8),  2, 'easeOutCubic'},
				{'RightArm', CFrame.Angles(0, 0,  .8),  2, 'easeOutCubic'})
			wait(.5)
			delay(3, function()
				vic:remove()
				decal.Transparency = 0
			end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Victory, {battleSceneType = 'VicBattle', musicId = 'none'})
			_p.NPCChat:say('Victini can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		Snorlax = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			local has, done
			Utilities.fastSpawn(function()
				has = _p.Network:get('PDS', 'hasFlute')
				done = true
			end)
			chat:say('It\'s an enormous, sleeping pokemon.')
			while not done do wait() end
			if has then _p.DataManager:preload(610093998) end--pf
			if has and chat:say('[y/n]Would you like to use the Pok[e\'] Flute?') then
				Utilities.sound(610093998, nil, nil, 10)--pf
				delay(6, function() chat:manualAdvance() end)
				delay(2, function() model.Mouth.PE.Enabled = false end)
				chat:say('[ma]'.._p.PlayerData.trainerName .. ' played the Pok[e\'] Flute.')
				wait(.5)
				spawn(function() _p.Battle._SpriteClass:playCry(.5, {id = 18856404568, startTime = 43.94, duration = .42}) end)--cr3
				wait(1)
				delay(3, function() model:remove() end)
				_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Snore)
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		Landorus = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			spawn(function() chat:say(model.Mouth, '[ma]Grrrraaghrraaah!') end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 18856427443, startTime = 104.50, duration = 1.68}) end)--cr11
			wait(1.7)
			chat:manualAdvance()
			wait(.5)
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Landforce, {musicId = 9537298254})--jb
			_p.NPCChat:say('Landorus can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		sign = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			chat:say(unpack(Utilities.jsonDecode(model.SignText.Value)))
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		motorized = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat

			local forme = model.Name
			local appliance = ({
				fan = 'Electric Fan',
				frost = 'Refrigerator',
				heat = 'Microwave Oven',
				mow = 'Lawn Mower',
				wash = 'Washing Machine'
			})[forme]
			chat:say('It\'s '..Utilities.aOrAn(appliance)..'.')
			local nRotom = _p.PlayerData.nRotom
			if nRotom and nRotom > 0 then
				chat:say('Oh? Rotom would like to investigate the circuits of the '..appliance..'.')
				if chat:say('[y/n]Is that OK?') then
					local slot
					if nRotom > 1 then
						chat:say('Which Rotom will you allow to investigate the circuits of the '..appliance..'?')
						slot = _p.BattleGui:choosePokemon('Choose')
						if not slot then
							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()
							return
						end
					end
					local r = _p.Network:get('PDS', 'motorize', forme, slot)
					if r then
						chat:say(r.n..' entered the motor.')
						if r.r then
							chat:say(r.n..' reverted to its original state.')
						end
						if r.f then
							chat:say(r.n..' forgot '..r.f..'...')
						end
						if r.l then
							chat:say(r.n..' learned '..r.l..'!')
						elseif r.t then
							_p.Pokemon:processMovesAndEvolution({
								pokeName = r.n,
								moves = r.t,
								known = r.k
							}, false)
						end
					end
				end
			end

			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		rockClimb = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			--		_p.DataManager:preload(316598829)
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local main = model.Main
			local normals = {
				[Enum.NormalId.Right ] = Vector3.new( 1, 0, 0),
				[Enum.NormalId.Left  ] = Vector3.new(-1, 0, 0),
				[Enum.NormalId.Top   ] = Vector3.new(0,  1, 0),
				[Enum.NormalId.Bottom] = Vector3.new(0, -1, 0),
				[Enum.NormalId.Back  ] = Vector3.new(0, 0,  1),
				[Enum.NormalId.Front ] = Vector3.new(0, 0, -1),
			}
			local function getDirection(part, surfaceType)
				for id, vec in pairs(normals) do
					if part[id.Name..'Surface'] == surfaceType then
						return vec--(part.CFrame*vec)-part.Position
					end
				end
			end
			local out = getDirection(main, Enum.SurfaceType.Weld)
			spawn(function() _p.MasterControl:LookAt(main.CFrame*(out*((main.Size*out).magnitude/2))) end)
			local climber, done
			Utilities.fastSpawn(function()
				climber = _p.Network:get('PDS', 'getClimber')
				done = true
			end)
			chat:say('These rocks look like they can be scaled by a Pokemon.')
			while not done do wait() end
			if not climber or not chat:say('[y/n]Would you like ' .. climber .. ' to use Rock Climb?') then
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
				return
			end
			chat:say(climber .. ' used Rock Climb!')
			local up = getDirection(main, Enum.SurfaceType.Studs)
			local yDist = (main.Size*up).magnitude
			--		print(yDist)
			local top = main.CFrame*(up*(yDist/2))
			local hDist = 3+(main.Size*out).magnitude/2
			local bottom = main.CFrame*(out*hDist-up*(yDist/2))
			out = (main.CFrame*out)-main.CFrame.p -- convert `out` to world space
			local hipHeight = 3
			local root = _p.player.Character.HumanoidRootPart
			pcall(function()
				local human = Utilities.getHumanoid()
				if human.RigType == Enum.HumanoidRigType.R15 then
					hipHeight = root.Size.Y/2 + human.HipHeight
				end
			end)
			local smokePart = create 'Part' {
				Anchored = true,
				CanCollide = false,
				Transparency = 1.0,
				Size = Vector3.new(.2, .2, .2)
			}
			local smoke = create 'Smoke' {
				Color = Color3.fromRGB(83, 67, 56),
				Opacity = .5,
				RiseVelocity = 0,
				Size = .6,
				Parent = smokePart
			}
			local smokeTransform = CFrame.new(0, 2-hipHeight, 0)
			local climbspeed = 22
			local extraheight = 2
			if top.Y > root.Position.Y then
				-- up
				local pos = bottom + Vector3.new(0, hipHeight, 0)
				local endcf = CFrame.new(pos, pos - out)
				local lerper = select(2, Utilities.lerpCFrame(root.CFrame, endcf))
				smokePart.Parent = workspace
				Utilities.Tween(yDist/climbspeed, nil, function(a)
					root.CFrame = lerper(a) + Vector3.new(0, yDist*a, 0)
					smokePart.CFrame = root.CFrame * smokeTransform
				end, 150)
				smoke.Enabled = false
				Utilities.Tween(math.pi/climbspeed*extraheight, nil, function(a)
					root.CFrame = endcf + Vector3.new(0, yDist+extraheight*math.sin(math.pi*a), 0) - out*hDist*a
				end, 150)
			else
				-- down
				local pos = top + Vector3.new(0, hipHeight, 0)
				local endcf = CFrame.new(pos, pos + out)
				local lerper = select(2, Utilities.lerpCFrame(root.CFrame, endcf))
				Utilities.Tween(math.pi/climbspeed*extraheight, nil, function(a)
					root.CFrame = lerper(a) + Vector3.new(0, extraheight*math.sin(math.pi*a), 0) + out*hDist*a
				end, 150)
				smokePart.Parent = workspace
				Utilities.Tween(yDist/climbspeed, nil, function(a)
					root.CFrame = endcf + out*hDist + Vector3.new(0, -yDist*a, 0)
					smokePart.CFrame = root.CFrame * smokeTransform
				end, 150)
				smoke.Enabled = false
			end
			delay(10, function() smokePart:remove() end)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		heatran = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local roar = model.AnimationController:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.heatranRoar })
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Jaw.Position) end)
			spawn(function() chat:say(model.Jaw, '[ma]Grrawraayuuuh!') end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 18856423150, startTime = 7.41, duration = 1.72}) end)--cr9
			roar:Play()
			wait(1.7)
			chat:manualAdvance()
			wait(.5)
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Heat, {musicId = 9537298254})--jb
			_p.NPCChat:say('Heatran can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		jDoor = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			chat:say('There are some strange markings written in the wall.')
			if _p.PlayerData.hasjkey then
				spawn(function() _p.PlayerData:completeEvent('OpenJDoor') end)
				local main = model.Main
				local mcf = main.CFrame
				Utilities.Tween(2, nil, function(a)
					Utilities.MoveModel(main, mcf + Vector3.new(0, 16*a, 0))
				end)
				model:remove()
				pcall(function()
					local chunk = _p.DataManager.currentChunk
					local door = chunk.map.CD41
					door.Name = 'CaveDoor:chunk41'
					chunk:hookupCaveDoor(door)
				end)
			end
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		diancie = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 18856430010, startTime = 27.79, duration = 1.93}) end)--cr13
			wait(1.8)
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Jewel, {musicId = 9537298254})--jb
			_p.NPCChat:say('Diancie can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,



		cresselia = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local chat = _p.NPCChat
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			spawn(function() _p.Battle._SpriteClass:playCry(nil, {id = 18856421417, startTime = 35.42, duration = 0.67}) end)
			wait(1.8)
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.Pysc, {musicId = 9537298254})
			_p.NPCChat:say('Cresselia can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		end,

		rDoor = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.NPCChat:say('The Three Protectors shall awaken the Titan.')
			if _p.Network:get('PDS', 'has3regis') then
				local CamCFrame = workspace.CurrentCamera.CFrame
				spawn(function()
					(function(p84)
						Utilities.Tween(3.5, nil, function(p86)
							workspace.CurrentCamera.CFrame = CamCFrame * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - p86) * p84), 0)
						end)
					end)(0.07)
				end)
				wait()
				pcall(function() _p.PlayerData:completeEvent('OpenRDoor') end)
				pcall(function() model['#InanimateInteract']:remove() end)
				local DoorMain = model.Main
				local DoorCFrame = DoorMain.CFrame
				Utilities.Tween(3.5, "easeInSine", function(p87)
					Utilities.MoveModel(DoorMain, DoorCFrame + Vector3.new(0, 10 * p87, 0))
				end);
				(function(p84)
					Utilities.Tween(1, nil, function(p86)
						workspace.CurrentCamera.CFrame = CamCFrame * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - p86) * p84), 0)
					end)
				end)(0.1)
			end
			_p.MasterControl.WalkEnabled = true
		end,

		GirafarigDunsparceDoor = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local canOpen, done
			Utilities.fastSpawn(function()
				canOpen = _p.Network:get('PDS', 'RevealCatacombs')
				done = true
			end)
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.NPCChat:say('There are strange markings on this wall.',
				'What could they mean?'
			)
			while not done do wait() end
			if canOpen then
				local DoorMain = model.Main;
				local DoorCFrame = DoorMain.CFrame;
				pcall(function() model['#InanimateInteract']:remove() end)
				Utilities.Tween(3, "easeInSine", function(p87)
					Utilities.MoveModel(DoorMain, DoorCFrame + Vector3.new(0, 10 * p87, 0));
				end);
				pcall(function() _p.PlayerData:completeEvent('RevealCatacombs') end)
				_p.NPCChat:say('The strange wall opened, revealing another chamber.')
			end
			_p.MasterControl.WalkEnabled = true
		end,

		wallbreak = function(model)
			if not _p.MasterControl.WalkEnabled then return end
			local chat = _p.NPCChat
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			local main = model.Main
			spawn(function() _p.MasterControl:LookAt(main.Position) end)
			local smasher, done
			Utilities.fastSpawn(function()
				smasher = _p.Network:get('PDS', 'getSmasher')
				done = true
			end)
			chat:say('It\'s a cracked wall.', 'A pokemon may be able to break it.')
			while not done do wait() end
			if not smasher or not chat:say('[y/n]Would you like ' .. smasher .. ' to use Rock Smash?') then
				_p.MasterControl.WalkEnabled = true
				return
			end
			chat:say(smasher .. ' used Rock Smash!')
			pcall(function() model['#InanimateInteract']:remove() end)
			main:remove()
			local cf = main.CFrame
			for _, p in pairs(model:GetChildren()) do
				if p:IsA('BasePart') then
					p.Anchored = false
					local dir = (p.Position-cf.p+Vector3.new(10,7,10)).unit
					p.Velocity = dir * 20
					local force = create 'BodyForce' {
						Force = dir * 50 * p:GetMass(),
						Parent = p
					}
					delay(.25, function() force:remove() end)
				end
			end
			wait(1)
			Utilities.Tween(.5, nil, function(a)
				for _, p in pairs(model:GetChildren()) do
					if p:IsA('BasePart') then
						p.Transparency = a
					end
				end
			end)
			model:remove()
			pcall(function() _p.PlayerData:completeEvent('SmashRockDoor') end)
			_p.MasterControl.WalkEnabled = true
		end,

		Regirock = function(model)
			if not _p.PlayerData.completedEvents.CompletedCatacombs then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk61' then return end
			local enc
			pcall(function() enc = chunk.regionData.Regirock end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9543571221, startTime = 2.93, duration = 1.66})
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 9537298254})
			pcall(function() _p.PlayerData:completeEvent('Regirock') end)
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
			_p.NPCChat:say('Regirock can now be found roaming in the wild.')
		end,

		Registeel = function(model)
			if not _p.PlayerData.completedEvents.CompletedCatacombs then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk58' then return end
			local enc
			pcall(function() enc = chunk.regionData.Registeel end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9543571221, startTime = 8.14, duration = 1.22})
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 9537298254})
			pcall(function() _p.PlayerData:completeEvent('Registeel') end)
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
			_p.NPCChat:say('Registeel can now be found roaming in the wild.')
		end,

		Regice = function(model)
			if not _p.PlayerData.completedEvents.CompletedCatacombs then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk59' then return end
			local enc
			pcall(function() enc = chunk.regionData.Regice end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 9543571221, startTime = 5.59, duration = 1.55})
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 9537298254})
			pcall(function() _p.PlayerData:completeEvent('Regice') end)
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
			_p.NPCChat:say('Regice can now be found roaming in the wild.')
		end,

		Volcanion = function(model)
			if _p.PlayerData.completedEvents.Volcanion then return end
			if not _p.PlayerData.completedEvents.RevealSteamChamber then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk62' then return end
			local enc
			pcall(function() enc = chunk.regionData.Volcanion end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			pcall(function() _p.PlayerData:completeEvent('Volcanion') end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 10840610122, startTime = 32.99, duration = 1.66})
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 9537298254})
			_p.NPCChat:say('Volcanion can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,



		HeadbuttBarrel = function(model)
			local chat = _p.NPCChat
			_p.MasterControl:Stop()
			_p.MasterControl.WalkEnabled = false
			spawn(function()
				_p.MasterControl:LookAt(model.Main.Position)
			end)
			local headbutter = nil
			local gotheadbutter = nil
			Utilities.fastSpawn(function()
				headbutter = _p.Network:get("PDS", "getHeadbutter")
				gotheadbutter = true
			end)
			chat:say("These barrels are precariously placed")
			while not gotheadbutter do
				wait()
			end
			if headbutter and chat:say("[y/n]Would you like " .. headbutter .. " to use Headbutt?") then
				local currentChunk = _p.DataManager.currentChunk
				local room = currentChunk:topRoom()
				model["#InanimateInteract"]:remove()
				local Barrels = room.model
				local SecurityDude = room.npcs.Guy
				spawn(function()
					SecurityDude:LookAt(SecurityDude.model.HumanoidRootPart.Position + Vector3.new(0, 0, -5))
				end)
				chat:say(headbutter .. " used Headbutt!")
				spawn(function()
					_p.Menu:disable()
				end)
				Utilities.sound(330262909, nil, nil, 5)
				local PushedBarrels = Barrels.PushBarrels
				Barrels.InvisWall.CanCollide = false
				PushedBarrels.Main.CanCollide = false
				PushedBarrels.Barrel1.Main.Anchored = false
				PushedBarrels.Barrel2.Main.Anchored = false
				PushedBarrels.Barrel3.Main.Anchored = false
				PushedBarrels.Barrel1.Main.AssemblyLinearVelocity = Vector3.new(0, 0, 30)
				PushedBarrels.Barrel2.Main.AssemblyLinearVelocity = Vector3.new(0, 0, 30)
				PushedBarrels.Barrel3.Main.AssemblyLinearVelocity = Vector3.new(0, 0, 30)
				delay(0.5, function()
					for i, v in pairs(Barrels:GetChildren()) do
						if v:IsA("BasePart") and v.Name == "OilSpill" then
							v.Transparency = 0
						end
					end
				end)
				wait(2)
				currentChunk:unbindIndoorCam()
				local camera = workspace.CurrentCamera
				camera.CameraType = Enum.CameraType.Scriptable
				Utilities.lookAt(SecurityDude.model.HumanoidRootPart.CFrame * CFrame.new(0, 13, -15) * CFrame.Angles(math.rad(40), math.rad(180), 0))
				Utilities.exclaim(SecurityDude.model.Head)
				SecurityDude:Say("What have you done?!")
				spawn(function()
					SecurityDude:WalkTo(Barrels.GuyWalkTo.CFrame)
					SecurityDude:LookAt(Barrels.Boat.LookAt.CFrame)
					SecurityDude.model.Interact.Parent = nil
					chat.interactableNPCs[SecurityDude.model] = function()
						SecurityDude:Say("Look at what you've done!", "How am I supposed to clean this?")
						SecurityDude:LookAt(Barrels.Boat.LookAt.CFrame)
					end
				end)
				local CFrame1 = camera.CFrame
				local CFrame2 = camera.CFrame
				Utilities.Tween(0.8, "easeInOutCubic", function(z)
					camera.CFrame = CFrame1:Lerp(CFrame2, z)
				end)
				spawn(function()
					_p.PlayerData:completeEvent("PushBarrels")
				end)
				currentChunk:bindIndoorCam()
				Barrels.NoPass.CanCollide = false
				Barrels.InvisWall.CanCollide = true
				PushedBarrels.Main.CanCollide = true
				spawn(function()
					_p.Menu:enable()
				end)
				_p.MasterControl.WalkEnabled = true
			end
			_p.MasterControl.WalkEnabled = true
		end,

		CraneButton = function(model)
			_p.MasterControl:Stop()
			local currentChunk = _p.DataManager.currentChunk
			_p.MasterControl.WalkEnabled = false
			if not _p.NPCChat:say("[y/n]A secret switch! Press it?") then
				_p.MasterControl.WalkEnabled = true
				return
			end
			model["#InanimateInteract"]:remove()
			currentChunk:unbindIndoorCam()
			spawn(function()
				_p.Menu:disable()
			end)
			local camera = workspace.CurrentCamera
			camera.CameraType = Enum.CameraType.Scriptable
			local CraneModel = currentChunk:topRoom().model
			local CraneHook = CraneModel.Hook
			camera.FieldOfView = 60
			camera.CFrame = CraneHook.Main.CFrame * CFrame.new(35, -8, 35)
			local running = game:GetService("RunService")
			local TruckMain = CraneModel.Truck.Main
			running:BindToRenderStep("camThing", Enum.RenderPriority.Camera.Value + 20, function()
				camera.CFrame = CFrame.new(camera.CFrame.p, CraneHook.Main.Position)
			end)
			local CraneHookMain = CraneHook.Main
			local CraneMain = CraneModel.Crane.Main
			Utilities.MoveModel(CraneMain, CraneMain.CFrame)
			Utilities.MoveModel(CraneHookMain, CraneHookMain.CFrame)
			Utilities.MoveModel(TruckMain, TruckMain.CFrame)
			local CraneHookMainCFrame = CraneHookMain.CFrame
			local c = TruckMain.CFrame
			spawn(function()
				Utilities.Tween(4, nil, function(z)
					Utilities.MoveModel(CraneHookMain, CraneHookMainCFrame * CFrame.new(0, 0, 27 * z))
				end)
				CraneHookMainCFrame = CraneHookMain.CFrame
				Utilities.Tween(2, nil, function(z)
					Utilities.MoveModel(CraneHookMain, CraneHookMainCFrame * CFrame.new(0, -10.5 * z, 13.5 * z))
				end)
				CraneHookMainCFrame = CraneHookMain.CFrame
				Utilities.Tween(2, nil, function(z)
					Utilities.MoveModel(CraneHookMain, CraneHookMainCFrame * CFrame.new(0, 0, 13.5 * z))
				end)
				CraneHookMainCFrame = CraneHookMain.CFrame
				spawn(function()
					Utilities.Tween(1, nil, function(y)
						Utilities.MoveModel(TruckMain, c * CFrame.new(0, 2.625 * y, 0) * CFrame.Angles(0, 0, math.rad(20 * y)))
					end)
					c = TruckMain.CFrame
					Utilities.Tween(3, nil, function(y)
						Utilities.MoveModel(TruckMain, c * CFrame.new(2.625 * y, 7.875 * y, 0))
					end)
				end)
				Utilities.Tween(4, nil, function(y)
					Utilities.MoveModel(CraneHookMain, CraneHookMainCFrame * CFrame.new(0, 10.5 * y, 0))
				end)
			end)
			local CraneMainCFrame = CraneMain.CFrame
			Utilities.Tween(8, nil, function(x)
				Utilities.MoveModel(CraneMain, CraneMainCFrame * CFrame.new(-54 * x, 0, 0))
			end)
			wait(7)
			running:UnbindFromRenderStep("camThing")
			camera.FieldOfView = 70
			currentChunk:bindIndoorCam()
			spawn(function()
				_p.PlayerData:completeEvent("UnlockMewLab")
			end)
			spawn(function()
				_p.Menu:enable()
			end)
			_p.MasterControl.WalkEnabled = true
		end,

		MewMachine = function(model)
			_p.MasterControl:Stop()
			_p.MasterControl.WalkEnabled = false
			local chat = _p.NPCChat
			if not chat:say("This computer is running a machine that is trapping Mew.", "[y/n]Shut down the computer?") then
				_p.MasterControl.WalkEnabled = true
				return
			end
			chat:say("...", "Shutdown sequence activated.")
			model.Main.Color = Color3.fromRGB(76, 78, 79)
			model["#InanimateInteract"]:remove()
			spawn(function()
				_p.Menu:disable()
			end)
			local MewChamber = _p.DataManager.currentChunk.map.MewChamber
			local MewTube = MewChamber.Tube
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			Utilities.lookAt((CFrame.new(12481.0635, 80.3596649, 650.964417, 0.936088681, 0.0287937634, -0.350583851, 3.7252903E-09, 0.996644318, 0.0818552896, 0.351764292, -0.0766238123, 0.932947338)))
			local TubeInner = MewChamber.TubeInner
			Utilities.Tween(0.5, "easeOutCubic", function(z)
				TubeInner.Transparency = 0.5 + 0.5 * z
			end)
			wait(0.8)
			local TubeCFrame = MewTube.CFrame
			Utilities.Tween(0.8, "easeOutCubic", function(x)
				MewTube.CFrame = TubeCFrame * CFrame.new(10 * x, 0, 0)
			end)
			wait(1)
			local Mew = MewChamber.Mew
			spawn(function()
				for i, v in pairs(Mew:GetChildren()) do
					if v:IsA("UnionOperation") then
						spawn(function()
							Utilities.Tween(0.5, nil, function(z)
								v.Transparency = 0 + 1 * z
							end)
						end)
					end
				end
			end)
			for i, v in pairs(Mew:GetChildren()) do
				if v:IsA("BasePart") then
					spawn(function()
						Utilities.Tween(0.5, nil, function(z)
							v.Transparency = 0 + 1 * z
						end)
					end)
				end
			end
			wait(3)
			chat:say("Mew used Teleport!", "Mew can now be found roaming in the wild.")
			spawn(function()
				_p.PlayerData:completeEvent("Mew")
			end)
			Utilities.lookBackAtMe()
			_p.MasterControl.WalkEnabled = true
			_p.Menu:enable()
		end,

		Keldeo = function(model)
			if _p.PlayerData.completedEvents.Keldeo then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk66' then return end
			local enc
			pcall(function() enc = chunk.regionData.Keldeo end)
			if not enc then return end

			pcall(function() model['#InanimateInteract']:remove() end)
			pcall(function() _p.PlayerData:completeEvent('Keldeo') end)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 10840606887, startTime = 109.55, duration = 1.07})
			delay(3, function() model:remove() end)
			_p.Battle:doWildBattle(enc, {musicId = 9537298254})
			_p.NPCChat:say('Keldeo can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,

		PinkKeg = function(room)
			local chat = _p.NPCChat
			spawn(function()
				_p.Menu:disable()
				_p.MasterControl:Stop()
				_p.MasterControl.WalkEnabled = false
			end)
			if chat:say("It's a juice keg.", "[y/n]Would you like to pull the lever?") then
				wait(1)
				chat:say("It's strawberry watermelon!", "[small]Mmmmmmmmmmmm...")
				spawn(function()
					_p.Menu:enable()
					_p.MasterControl.WalkEnabled = true
				end)
				return
			end
			_p.Menu:enable()
			_p.MasterControl.WalkEnabled = true
		end,

		PurpleKeg = function(room)
			local chat = _p.NPCChat
			spawn(function()
				_p.Menu:disable()
				_p.MasterControl:Stop()
				_p.MasterControl.WalkEnabled = false
			end)
			if chat:say("It's a juice keg.", "[y/n]Would you like to pull the lever?") then
				wait(1)
				chat:say("It's grape!", "[small]Mmmmmmmmmmmm...")
				spawn(function()
					_p.Menu:enable()
					_p.MasterControl.WalkEnabled = true
				end)
				return
			end
			_p.Menu:enable()
			_p.MasterControl.WalkEnabled = true
		end,

		OrangeKeg = function(room)
			local chat = _p.NPCChat
			spawn(function()
				_p.Menu:disable()
				_p.MasterControl:Stop()
				_p.MasterControl.WalkEnabled = false
			end)
			if chat:say("It's a juice keg.", "[y/n]Would you like to pull the lever?") then
				wait(1)
				chat:say("It's orange!", "[small]Mmmmmmmmmmmm...")
				spawn(function()
					_p.Menu:enable()
					_p.MasterControl.WalkEnabled = true
				end)
				return
			end
			_p.Menu:enable()
			_p.MasterControl.WalkEnabled = true
		end,

		RedKeg = function(room)
			if false then
				return
			end
			spawn(function()
				_p.Menu:disable()
				_p.MasterControl:Stop()
				_p.MasterControl.WalkEnabled = false
			end)
			if not _p.NPCChat:say("It's a juice keg.", "[y/n]Would you like to pull the lever?") then
				_p.Menu:enable()
				_p.MasterControl.WalkEnabled = true
				return
			end
			spawn(function()
				_p.Menu:disable()
				_p.MasterControl.WalkEnabled = false
			end)
			local ElevatorM = room.ElevatorMain
			local CameraCFrame = workspace.CurrentCamera.CFrame;
			(function(pos1)
				Utilities.Tween(1.2, nil, function(pos2)
					workspace.CurrentCamera.CFrame = CameraCFrame * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - pos2) * pos1), 0)
				end)
			end)(0.07)
			wait(1)
			local ElevatorCFrame = ElevatorM.CFrame
			Utilities.Tween(2, "easeInSine", function(pos3)
				Utilities.MoveModel(ElevatorM, ElevatorCFrame + Vector3.new(0, 7.5 * pos3, 0))
			end)
			spawn(function()
				local cameraCFrame2 = workspace.CurrentCamera.CFrame;
				(function(pos5)
					Utilities.Tween(1.2, nil, function(pos4)
						workspace.CurrentCamera.CFrame = cameraCFrame2 * CFrame.new(0, math.cos(math.random() * math.pi * 2) * ((1 - pos4) * pos5), 0)
					end)
				end)(0.07)
			end)
			_p.Menu:enable()
			_p.MasterControl.WalkEnabled = true
		end,

		SecurityButton = function(model)
			local camera = workspace.CurrentCamera
			local map = _p.DataManager.currentChunk.map
			local cframe = camera.CFrame
			spawn(function()
				pcall(function() model['#InanimateInteract']:remove() end)
				_p.MasterControl.WalkEnabled = false
				_p.Menu:disable()
			end)
			model.Main.Color = Color3.fromRGB(255, 0, 0);
			(function(y)
				Utilities.Tween(1.2, nil, function(z)
					local v = (1 - z) * y
					local c = math.random() * math.pi * 2
					camera.CFrame = cframe * CFrame.new(math.cos(c) * v, 0, math.sin(c) * v)
				end)
			end)(0.1)
			wait(0.7)
			Utilities.FadeOut(1)
			camera.CameraType = Enum.CameraType.Scriptable
			camera.FieldOfView = 60
			local pos1 = CFrame.new(-91.7385941, 330.102966, -1376.26001, -0.999999285, 4.34831145E-06, -0.0012283239, -0, 0.999993742, 0.00354001415, 0.0012283317, 0.00354001159, -0.999992967)
			local pos2 = CFrame.new(-91.2999802, 328.840088, -1019.50378, -0.999999285, 4.34831145E-06, -0.0012283239, -0, 0.999993742, 0.00354001415, 0.0012283317, 0.00354001159, -0.999992967)
			local pos3 = CFrame.new(-137.010788, 347.528259, -973.685242, -0.00883319881, -0.0998192951, 0.994966388, -5.82076679E-11, 0.99500531, 0.0998231769, -0.999961078, 0.000881757936, -0.00878907833)
			local pos4 = CFrame.new(-49.142952, 335.980804, -968.162354, 0.220119029, 0.246904269, -0.943708658, -0, 0.967437029, 0.253112346, 0.975473046, -0.0557148457, 0.212951273)
			wait(3)
			spawn(function()
				Utilities.FadeIn(1)
			end)
			local cframe1 = map.Door2.Left.Main.CFrame
			delay(0, function()
				Utilities.Tween(3, "easeOutSine", function(z)
					Utilities.MoveModel(map.Door2.Left.Main, cframe1 + Vector3.new(-10 * z, 0, 0))
				end)
			end)
			local cframe2 = map.Door2.Right.Main.CFrame
			delay(0, function()
				Utilities.Tween(3, "easeOutSine", function(x)
					Utilities.MoveModel(map.Door2.Right.Main, cframe2 + Vector3.new(10 * x, 0, 0))
				end)
			end)
			local cframe3 = map.Door3.Left.Main.CFrame
			delay(4, function()
				Utilities.Tween(3, "easeOutCubic", function(c)
					Utilities.MoveModel(map.Door3.Left.Main, cframe3 + Vector3.new(-10 * c, 0, 0))
				end)
			end)
			local cframe4 = map.Door3.Right.Main.CFrame
			delay(4, function()
				Utilities.Tween(3, "easeOutCubic", function(n)
					Utilities.MoveModel(map.Door3.Right.Main, cframe4 + Vector3.new(10 * n, 0, 0))
				end)
			end)
			local cframe5 = map.Door4.Left.Main.CFrame
			delay(11, function()
				Utilities.Tween(3.5, "easeOutCubic", function(r)
					Utilities.MoveModel(map.Door4.Left.Main, cframe5 + Vector3.new(0, 0, 7 * r))
				end)
			end)
			local cframe6 = map.Door4.Right.Main.CFrame
			delay(11, function()
				Utilities.Tween(3.5, "easeOutCubic", function(m)
					Utilities.MoveModel(map.Door4.Right.Main, cframe6 + Vector3.new(0, 0, -7 * m))
				end)
			end)
			local cframe7 = map.Door5.Left.Main.CFrame
			delay(13, function()
				Utilities.Tween(5, "easeOutCubic", function(t)
					Utilities.MoveModel(map.Door5.Left.Main, cframe7 + Vector3.new(0, 0, -7 * t))
				end)
			end)
			local cframe8 = map.Door5.Right.Main.CFrame
			delay(13, function()
				Utilities.Tween(5, "easeOutCubic", function(o)
					Utilities.MoveModel(map.Door5.Right.Main, cframe8 + Vector3.new(0, 0, 7 * o))
				end)
			end)
			Utilities.Tween(10, nil, function(poss)
				camera.CFrame = pos1:Lerp(pos2, poss)
			end)
			Utilities.Tween(2, nil, function(poss2)
				camera.CFrame = pos2:Lerp(pos3, poss2)
			end)
			Utilities.Tween(3, "easeInOutCubic", function(poss3)
				camera.CFrame = pos3:Lerp(pos4, poss3)
			end)
			wait(0.5)
			Utilities.FadeOut(1)
			camera.CameraType = Enum.CameraType.Custom
			_p.Menu:enable()
			_p.MasterControl.WalkEnabled = true
			camera.FieldOfView = 70
			Utilities.FadeIn(1)
			spawn(function()
				_p.PlayerData:completeEvent("PressSecurityButton")
			end)
		end,

		CardKey = function(model)
			if _p.PlayerData.completedEvents.FindCardKey then return end
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			Utilities.sound(288899943, nil, nil, 10)
			pcall(function() _p.PlayerData:completeEvent('FindCardKey') end)
			_p.NPCChat:say(_p.PlayerData.trainerName..' found a Card Key!')
			pcall(function() model:remove() end)
			_p.NPCChat:say(_p.PlayerData.trainerName..' put the Card Key in the Bag.')
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,

		GenesectDoor = function(model)
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.NPCChat:say('This door is locked.')
			if _p.PlayerData.completedEvents.FindCardKey then
				_p.NPCChat:say('You swiped your Card Key.')
				model.Light.BrickColor = BrickColor.new('Lime green')
				model.Light.PointLight.Color = Color3.fromRGB(0, 255, 0)
				_p.NPCChat:say('The door unlocked.')
				pcall(function() model['#InanimateInteract']:remove() end)
				pcall(function() _p.PlayerData:completeEvent('UnlockGenDoor') end)
				local door = _p.DataManager.currentChunk:getDoor('C_chunk88')
				door.disabled = false
			end
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,

		getdrive = function(model)
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk88' then return end
			local dtype = model.Name
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			Utilities.sound(288899943, nil, nil, 10)
			local textype = ''
			if dtype == 'burndrive' then
				textype = 'Burn Drive'
			elseif dtype == 'dousedrive' then
				textype = 'Douse Drive'
			elseif dtype == 'chilldrive' then
				textype = 'Chill Drive'
			elseif dtype == 'shockdrive' then
				textype = 'Shock Drive'
			end
			_p.NPCChat:say(_p.PlayerData.trainerName..' found a '..textype..'!')
			pcall(function() model:remove() end)
			_p.NPCChat:say(_p.PlayerData.trainerName..' put the '..textype..' in the Bag.')
			pcall(function() _p.PlayerData:completeEvent(dtype) end)
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
		end,

		Genesect = function(model)
			if _p.PlayerData.completedEvents.Genesect then return end
			if not _p.PlayerData.completedEvents.UnlockGenDoor then return end
			if not _p.MasterControl.WalkEnabled then return end
			local chunk = _p.DataManager.currentChunk
			if not chunk or chunk.id ~= 'chunk88' then return end
			local enc
			pcall(function() enc = chunk.regionData.MetalBug end)
			if not enc then return end

			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			spawn(function() _p.MasterControl:LookAt(model.Main.Position) end)
			_p.Battle._SpriteClass:playCry(nil, {id = 10840606887, startTime = 113.91, duration = 1.16})
			
			delay(3, function() model:remove() end)

			-- Do battle first
			_p.Battle:doWildBattle(enc, {musicId = 9537298254})

			-- Complete event after battle
			pcall(function() _p.PlayerData:completeEvent('Genesect') end)


			pcall(function() model['#InanimateInteract']:remove() end)
			
			_p.NPCChat:say('Genesect can now be found roaming in the wild.')
			_p.MasterControl.WalkEnabled = true
		end,
		

	
	} end