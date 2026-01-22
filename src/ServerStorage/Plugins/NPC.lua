

return function(_p)--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local create = Utilities.Create

	local stepped = game:GetService('RunService').RenderStepped

	local zero3 = Vector3.new()
	local force = Vector3.new(2e4, 0, 2e4)
	local torque = Vector3.new(math.huge, 9e3, math.huge)
	local walkTorque = Vector3.new(math.huge, 0, math.huge)

	local watchingTrainers = setmetatable({}, {__mode = 'v'})
	local skipCheck = false


	local NPC = Utilities.class({
		className = 'NPC',

	}, function(model)
		local swimr
		local self = {}
		self.model = model
		if self.model:FindFirstChild("IsSwimmer") then
			swimr = true
		else
			swimr = false
		end	
		--self.model.isSwimmer = swimr

		if not model:FindFirstChild('HumanoidRootPart') then
			Utilities.fastSpawn(function() error(model.Name..' does not have a HumanoidRootPart', 0) end)
			return
		end
		self.ocf = model.HumanoidRootPart.CFrame

		if model:FindFirstChild('#Battle') then
			local v = model['#Battle'].Value
			local battle = _p.DataManager.currentChunk.battles[tostring(v)] or _p.DataManager.currentChunk.battles[v]
			if battle then
				battle.num = v
				if _p.BitBuffer.GetBit(_p.PlayerData.defeatedTrainers, v) then
					if battle.RematchQuestion then
						_p.NPCChat.interactableNPCs[model] = function()
							if not _p.Menu.enabled then return end
							local msg = battle.Interact
							if msg then
								if type(msg) == 'table' then
									_p.NPCChat:say(self, unpack(msg))
								else
									_p.NPCChat:say(self, msg)
								end
							end
							msg = battle.RematchQuestion
							local fight
							if type(msg) == 'table' then
								local copy = {unpack(msg)}
								copy[#copy] = '[y/n]'..copy[#copy]
								fight = _p.NPCChat:say(self, unpack(copy))
							else
								fight = _p.NPCChat:say(self, '[y/n]'..msg)
							end
							if fight then
								local win = _p.Battle:doTrainerBattle({trainer = battle, trainerModel = model})
								if win then
									_p.NPCChat.interactableNPCs[model] = battle.Interact
								end
							end
						end
					elseif battle.Interact then
						_p.NPCChat.interactableNPCs[model] = battle.Interact
					end
				else
					self.battle = battle
					if battle.EyesMeetMusic then
						if type(battle.EyesMeetMusic) == 'table' then
							_p.DataManager:preload(unpack(battle.EyesMeetMusic))
						else
							_p.DataManager:preload(battle.EyesMeetMusic)
						end
					end
					do
						local chunk = _p.DataManager.currentChunk
						if model:FindFirstChild("IsSwimmer") then
							self.Swimmer = true
						elseif model.Parent.Name == 'Gym2' then
							self.gym2 = true
						end
					end
					if not battle.InteractRequired then
						table.insert(watchingTrainers, self)
					end
					_p.NPCChat.interactableNPCs[model] = function()
						if not _p.Menu.enabled then return end
						skipCheck = true
						if battle.EyesMeetMusic then
							_p.MusicManager:stackMusic(battle.EyesMeetMusic, 'EyesMeet')
						end
						local msg = battle.IntroPhrase
						if msg then
							if type(msg) == 'table' then
								_p.NPCChat:say(self, unpack(msg))
							else
								_p.NPCChat:say(self, msg)
							end
						end
						_p.MusicManager:popMusic('EyesMeet', .5, true)
						local win = _p.Battle:doTrainerBattle({trainer = battle, trainerModel = model})
						if win then
							_p.PlayerData.defeatedTrainers = _p.BitBuffer.SetBit(_p.PlayerData.defeatedTrainers, battle.num, true)
							for i = #watchingTrainers, 1, -1 do
								if watchingTrainers[i] == self then
									table.remove(watchingTrainers, i)
								end
							end
							_p.NPCChat.interactableNPCs[model] = battle.Interact
						else
							self:Teleport(self.ocf)
						end
						skipCheck = false
					end
				end
				--		else
				--			print('unknown battle:', v)
			end
		end

		return self
	end)

	-- class functions
	function NPC:collectNPCs(model, collection) -- old API, didn't use much
		while true do
			local tag = model:FindFirstChild('#NPC', true)
			if not tag then break end
			local parent, cframe, name = tag.Parent.Parent, tag.Parent.RootPart.CFrame, tag.Value
			tag.Parent:remove()
			local m = _p.storage.Modelss.NPCs[name]:Clone()
			Utilities.MoveModel(m.HumanoidRootPart, cframe)
			m.Parent = parent
			local npc = NPC:new(m)
			if not m:FindFirstChild('NoAnimate') then npc:Animate() end
			collection[name] = npc
		end
	end

	local angle; do
		local cframe = CFrame.new
		local toObjSpace = cframe().toObjectSpace
		local atan2 = math.atan2
		angle = function(cf, p)
			local s = toObjSpace(cf - cf.p, cframe(cf.p - p))
			return atan2(s.x, s.z)
		end
	end
	function NPC.trainersCheck()
		if skipCheck then
			while skipCheck do stepped:wait() end
			return true
		end
		if _p.Battle.currentBattle then return end
		local p = _p.player.Character.HumanoidRootPart.Position
		for _, t in pairs(watchingTrainers) do
			if t.model and t.model:FindFirstChild('HumanoidRootPart') then
				local cf = t.model.HumanoidRootPart.CFrame
				local yCondition = math.abs(cf.p.y-p.y) < 3.5
				local i = 30
				if t.Swimmer and _p.Surf.surfing then
					yCondition = cf.p.y-1 < p.y and cf.p.y+15 > p.y
					i = 180
				elseif t.gym2 then
					yCondition = cf.p.y-1 < p.y and cf.p.y+15 > p.y
				end
				if yCondition and (cf.p-p).magnitude < i then--30
					local theta = angle(cf, Vector3.new(p.x, cf.p.y, p.z))
					if math.deg(math.abs(theta)) < 15 then
						local character = _p.player.Character
						local phead = character.Head
						local thead = t.model.Head
						if t.battle.IgnoreWalls or (Utilities.findPartOnRayWithIgnoreFunction(Ray.new(thead.Position, (phead.Position-thead.Position)), function(p) return p~=phead and (not p.CanCollide or p.Parent==character or p.Parent:FindFirstChild('Humanoid')) end)) == phead then
							_p.MasterControl.WalkEnabled = false
							_p.MasterControl:Stop()
							_p.MasterControl:Hidden(true)
							spawn(function() _p.Menu:disable() end)
							_p.NPCChat:disable()

							if t.battle.EyesMeetMusic then
								_p.MusicManager:stackMusic(t.battle.EyesMeetMusic, 'EyesMeet')
							end

							local part = create 'Part' {
								Size = Vector3.new(1, 1, 1),
								Anchored = true,
								CanCollide = false,
								Transparency = 1.0,
								CFrame = t.model.Head.CFrame * CFrame.new(0, 2, 0),
								Parent = t.model,
							}
							local bbg = create 'BillboardGui' {
								Adornee = part,
								Parent = part,
							}
							local exc = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(0.0, 0, 0.2, 0),
								Parent = Utilities.gui,
							}
							Utilities.Write '!' {
								Frame = exc,
								Scaled = true,
							}
							exc.Parent = bbg
							exc.Size = UDim2.new(1.0, 0, 1.0, 0)
							local duration = .35
							Utilities.Tween(duration, Utilities.Timing.cubicBezier(duration, .85, 0, .6, 2), function(a)
								bbg.Size = UDim2.new(1.8, 0, 1.8*a, 0)
							end)
							wait(.25)
							bbg:remove()
							part:remove()

							if not t.model.Name:lower():match('eclipse') then
								t.waveAnim:Play()
								wait(1.5)
							end
							p = _p.player.Character.HumanoidRootPart.Position -- refresh location

							local sig = Utilities.Signal()
							local dif = p-cf.p
							if not t.battle.DontWalk and dif.magnitude > 4 then
								delay(10, function() sig:fire() end)
								spawn(function()
									t:WalkTo(cf.p + dif.unit * (dif.magnitude-4))
									sig:fire()
								end)
								sig:wait()
							end
							local a, b
							spawn(function()
								_p.MasterControl:LookAt(cf.p)
								a = true
							end)
							spawn(function()
								t:LookAt(p)
								b = true
							end)
							while not a or not b do stepped:wait() end
							local msg = t.battle.IntroPhrase
							if msg then
								if type(msg) == 'table' then
									_p.NPCChat:say(t, unpack(msg))
								else
									_p.NPCChat:say(t, msg)
								end
							end

							_p.MusicManager:popMusic('EyesMeet', .5, true)
							local win = _p.Battle:doTrainerBattle({trainer = t.battle, trainerModel = t.model})
							if win then
								_p.PlayerData.defeatedTrainers = _p.BitBuffer.SetBit(_p.PlayerData.defeatedTrainers, t.battle.num, true)
								for i = #watchingTrainers, 1, -1 do
									if watchingTrainers[i] == t then
										table.remove(watchingTrainers, i)
									end
								end
								if t.battle.Interact then
									_p.NPCChat.interactableNPCs[t.model] = t.battle.Interact
								end
							else
								t:Teleport(t.ocf)
							end
							return true
						end
					end
				end
			end
		end
		return false
	end

	function NPC:PlaceNew(name, parent, cframe, dontAnimate)
		local m = _p.storage.Modelss.NPCs[name]:Clone()
		local npc = _p.NPC:new(m)
		m.Parent = parent
		if not dontAnimate then
			npc:Animate()
		end
		if cframe then
			npc:Teleport(cframe)
		end
		return npc
	end
	--


	function NPC:Animate()
		local CustomRig = false
		local model = self.model
		if not model then return end
		local torso = model:FindFirstChild('Torso') or model:FindFirstChild('UpperTorso')
		if not torso then return end
		local root = model:FindFirstChild('HumanoidRootPart')
		--local face = _p.NPC.Face:new(model.Head)
		--face:AddStandardFeatures()
		--face:EnableBlinking() 
		if not root then
			root = torso:Clone()
			root:ClearAllChildren()
			root.Transparency = 1
			root.Name = 'HumanoidRootPart'
			root.Parent = model
		end
		if self.model:FindFirstChild("R15") or self.model:FindFirstChild("Custom") then
			CustomRig = true
		else
			CustomRig = false
		end
		local head = model:FindFirstChild('Head')
		if CustomRig == false then
			pcall(function() model.Humanoid:remove() end)	
			model:BreakJoints()
			self:Rig()
		end
		--self:Rig()
		local limbs = {}
		for _, part in pairs(root:GetConnectedParts(true)) do
			limbs[part] = true
		end
		for _, obj in pairs(model:GetChildren()) do
			if obj:IsA('BasePart') and obj ~= root then
				if not limbs[obj] then -- assume it's a hat
					pcall(function()
						create 'Weld' {
							Part0 = head,
							Part1 = obj,
							C1 = obj.CFrame:inverse() * head.CFrame,
							Parent = head,
						}
					end)
				end
				if obj.Name ~= head then
					obj.Anchored = false
				end
			end
		end
		root.Anchored = false
		if head then head.Anchored = false end
		if CustomRig == false then
			self.humanoid = create 'Humanoid' {
				DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None,
				Parent = model,
			}
		else
			model.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			self.humanoid = model.Humanoid
		end	
		if self.model:FindFirstChild("IsSwimmer") then
			self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCIdleSwim }):Play()
			self.walkAnim = self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCSwim })
			self.waveAnim = self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCWave })
		elseif self.model:FindFirstChild("R15") then
			self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCR15 }):Play()
			self.walkAnim = self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCR15Walk })
			self.waveAnim = self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCR15Wave })
		elseif self.model:FindFirstChild("Custom") then	
			self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId[self.model.Name]}):Play()
			self.walkAnim = self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCWalk })
			self.waveAnim = self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCWave })
		else
			self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCIdle }):Play()
			self.walkAnim = self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCWalk })
			self.waveAnim = self.humanoid:LoadAnimation(create 'Animation' { AnimationId = 'rbxassetid://'.._p.animationId.NPCWave })
		end
		if CustomRig == true then
			pcall(function() model.RightLowerLeg.CanCollide = false end)
			pcall(function() model.RightUpperLeg.CanCollide = false end)
			pcall(function() model.LeftLowerLeg.CanCollide = false end)
			pcall(function() model.LeftUpperLeg.CanCollide = false end)

			pcall(function() model.RightLowerArm.CanCollide = false end)
			pcall(function() model.RightUpperArm.CanCollide = false end)
			pcall(function() model.LeftLowerArm.CanCollide = false end)
			pcall(function() model.LeftUpperArm.CanCollide = false end)

			pcall(function() model.LeftFoot.CanCollide = false end)
			pcall(function() model.RightFoot.CanCollide = false end)
			pcall(function() model.LeftHand.CanCollide = false end)
			pcall(function() model.RightHand.CanCollide = false end)

		else
			pcall(function() model['Right Leg'].CanCollide = false end)
			pcall(function() model['Left Leg' ].CanCollide = false end)

			pcall(function() model['Right Arm'].CanCollide = false end)
			pcall(function() model['Left Arm' ].CanCollide = false end)
		end

		self.position = create 'BodyPosition' {
			MaxForce = force,
			Position = root.Position,
			Parent = root,
			D = 0,
		}
		self.gyro = create 'BodyGyro' {
			MaxTorque = torque,
			CFrame = root.CFrame,
			P = 1e4,
			Parent = root,
		}

		self.animated = true
	end

	function NPC:Rig()
		local model = self.model
		local root  = model.HumanoidRootPart
		local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")-- consideration: will we ever have R15 NPCs?
		local head  = model.Head
		if not model:FindFirstChild("R15") then		
			create 'Motor6D' {
				Name = 'RootJoint',
				Part0 = root,
				Part1 = torso,
				C0 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
				C1 = CFrame.new(0, 0, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
				Parent = root,
			}
			create 'Motor6D' {
				Name = 'Neck',
				Part0 = torso,
				Part1 = head,
				C0 = CFrame.new(0, 1, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
				C1 = CFrame.new(0, -0.5, 0, -1, -0, -0, 0, 0, 1, 0, 1, 0),
				MaxVelocity = 0.1,
				Parent = torso,
			}
			create 'Motor6D' {
				Name = 'Right Shoulder',
				Part0 = torso,
				Part1 = model:FindFirstChild('Right Arm'),
				C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
				C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
				MaxVelocity = 0.1,
				Parent = torso,
			}
			create 'Motor6D' {
				Name = 'Left Shoulder',
				Part0 = torso,
				Part1 = model:FindFirstChild('Left Arm'),
				C0 = CFrame.new(-1, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
				C1 = CFrame.new(0.5, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
				MaxVelocity = 0.1,
				Parent = torso,
			}
			create 'Motor6D' {
				Name = 'Right Hip',
				Part0 = torso,
				Part1 = model:FindFirstChild('Right Leg'),
				C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
				C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0),
				MaxVelocity = 0.1,
				Parent = torso,
			}
			create 'Motor6D' {
				Name = 'Left Hip',
				Part0 = torso,
				Part1 = model:FindFirstChild('Left Leg'),
				C0 = CFrame.new(-1, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
				C1 = CFrame.new(-0.5, 1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0),
				MaxVelocity = 0.1,
				Parent = torso,
			}
		end
	end
	local flat = Vector3.new(1, 0, 1)
	function NPC:WalkTo(point)
		if not self.model or not self.animated or self.followingPlayerThread then return end
		local root = self.model:FindFirstChild('HumanoidRootPart')
		if not root then return end
		local thisThread = {}
		self.walkThread = thisThread

		local initialDirection = ((point-root.Position)*flat).unit
		self.position.MaxForce = zero3
		self.gyro.MaxTorque = walkTorque--self.gyro.Parent = nil
		self.walkAnim:Play()
		while self.walkThread == thisThread do
			local direction = ((point-root.Position)*flat).unit
			if math.deg(math.acos(direction:Dot(initialDirection))) > 80 then break end
			if not self.humanoid then return end
			self.humanoid:Move(direction)
			stepped:wait()
		end
		self.humanoid:Move(zero3)
		self.walkAnim:Stop()
		self.position.Position = root.Position
		self.position.MaxForce = force
		self.gyro.CFrame = root.CFrame
		self.gyro.MaxTorque = torque--self.gyro.Parent = root
		if self.walkThread == thisThread then self.walkThread = nil end
	end

	function NPC:Stop()
		self.walkThread = nil
	end

	function NPC:Look(v, t)
		if not self.animated then return end
		local s, root = pcall(function() return self.model.HumanoidRootPart end)
		if not s or not root then return end
		local thread = {}
		self.lookThread = thread
		v = (v * Vector3.new(1, 0, 1)).unit
		local gyro = self.gyro
		gyro.MaxTorque = walkTorque
		if t == 0 then
			root.CFrame = CFrame.new(root.Position, root.Position+v)
		else
			local theta, lerp = Utilities.lerpCFrame(root.CFrame, CFrame.new(root.Position, root.Position+v))
			if not t then
				t = theta*.3
			end
			Utilities.Tween(t, 'easeOutCubic', function(a)
				if thread ~= self.lookThread then return false end
				root.CFrame = lerp(a)
			end)
		end
		if thread == self.lookThread and not self.followingPlayerThread then
			gyro.CFrame = CFrame.new(zero3, v)
			gyro.maxTorque = torque
		end
	end

	function NPC:LookAt(point, t)
		if not self.animated then return end
		local s, p = pcall(function() return self.model.HumanoidRootPart.Position end)
		if not s or not p then return end
		self:Look(point-p, t)
	end

	function NPC:Jump()
		self.humanoid.Jump = true
	end

	function NPC:Teleport(cf)
		if not self.model or not self.model:FindFirstChild('HumanoidRootPart') then return end
		local root = self.model.HumanoidRootPart
		self.position.MaxForce = zero3
		self.gyro.MaxTorque = zero3
		Utilities.Teleport(cf, root)
		self.position.Position = root.Position
		self.position.MaxForce = force
		self.gyro.CFrame = root.CFrame
		self.gyro.MaxTorque = torque
	end

	function NPC:StartFollowingPlayer()
		if self.followingPlayerThread then return end
		local thisThread = {}
		self.followingPlayerThread = thisThread

		local myRoot = self.model.HumanoidRootPart
		local playerRoot = _p.player.Character.HumanoidRootPart
		self:Stop()
		spawn(function()
			self.position.MaxForce = zero3
			self.gyro.MaxTorque = walkTorque
			local walking = false

			local human = self.humanoid
			local playerHuman = Utilities.getHumanoid()
			local anim = self.walkAnim
			local pfs = game:GetService('PathfindingService')
			while self.followingPlayerThread == thisThread do
				local mp = myRoot.Position
				local pp = playerRoot.Position
				local d = (pp-mp).magnitude
				if d > 15 then
					if walking then
						anim:Stop()
						walking = false
					end
					Utilities.Teleport(playerRoot.CFrame * CFrame.new(0, 0, 1), myRoot)
				elseif d > 9 then
					human.WalkSpeed = 26
					local path = pfs:ComputeSmoothPathAsync(mp, pp, 50)
					if path and path.Status == Enum.PathStatus.Success then
						local coords = path:GetPointCoordinates()
						local cp = #coords > 2 and coords[2] or pp
						--					print('walking to', cp)
						human:Move(((cp-mp)*flat).unit)
					else
						--					pcall(function() print('unable to compute path:', path.Status.Name) end)
					end
				elseif d > 4.5 then
					human.WalkSpeed = d>6 and playerHuman.WalkSpeed or playerHuman.WalkSpeed-2
					human:Move(((pp-mp)*flat).unit)
					if not walking then
						anim:Play()
						walking = true
					end
				else--if d < 4 then
					human:Move(zero3)
					if walking then
						anim:Stop()
						walking = false
					end
				end
				wait()
			end

			human:Move(zero3)
			anim:Stop()
			self.position.Position = myRoot.Position
			self.position.MaxForce = force
			self.gyro.CFrame = myRoot.CFrame
			self.gyro.MaxTorque = torque
		end)
	end

	function NPC:StopFollowingPlayer()
		self.followingPlayerThread = nil
		--	self:Stop()
	end

	function NPC:SetInteract(...)
		pcall(function() self.model.Interact:remove() end)
		create 'StringValue' {
			Name = 'Interact',
			Value = Utilities.jsonEncode({...}),
			Parent = self.model,
		}
	end

	function NPC:Say(...)
		return _p.NPCChat:say(self, ...)
	end


	function NPC:remove() self:remove() end
	function NPC:remove()
		self.walkThread = nil
		pcall(function() self.model:remove() end)
		self.model = nil
		pcall(function() self.animate:remove() end)
		self.animate = nil

		self.humanoid = nil
		self.walkAnim = nil

		self.position = nil
		self.gyro = nil
	end


	return NPC end