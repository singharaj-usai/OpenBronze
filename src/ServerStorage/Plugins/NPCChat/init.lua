--[[ todo: give this to an NPC character near water:
	{'I just caught a wild Horsea!',
	'Because of her mysterious behavior, I have decided to nickname her Mystery.',
	'Hmmm, now that I think of it, she is very graceful and majestic.',
	'Perhaps I should nickname her Grace, or Majesty...',
	'... or Debbie.'}
--]]
return function(_p)

	local players = game:GetService('Players')
	local player = players.LocalPlayer
	local mouse = player:GetMouse()

	local runService = game:GetService('RunService')
	local stepped = runService.RenderStepped
	local userInputService = game:GetService('UserInputService')
	local storage = game:GetService('ReplicatedStorage')

	--local _p = require(script.Parent)
	local context = _p.context
	local Utilities = _p.Utilities
	local write = Utilities.Write
	--local MasterControl = _p.MasterControl

	local interactableNPCs, silentInteract; do
		local weakKeys = {__mode = 'k'}
		interactableNPCs = setmetatable({}, weakKeys)
		silentInteract = setmetatable({}, weakKeys)
	end
	local inanimateInteract = require(script.InanimateInteract)(_p)


	local maxInteractDistance = 6.5
	local customMaxInteractDist = {
		--	HoneyTree = 11.5,
		SantaClaus = 12,
		--	Mrbobbilly = 12,	
		Snorlax = 17,
		--	ChooseHoverboard = 50
	}

	local NPCChat = {
		interactableNPCs = interactableNPCs,
		silentInteract = silentInteract,
		customMaxInteractDist = customMaxInteractDist,
	}

	local clickCon
	local chatQueue = {}
	local chatArrow, chatTarget
	local continueIcon

	local gui = Utilities.gui
	local chatIcon = Utilities.Create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://6138635850',
		Size = UDim2.new(0.0, 30, 0.0, 30),
	}
	local pcIcon = Utilities.Create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5640293079',
		Size = UDim2.new(0.0, 30, 0.0, 30),
	}
	local interactIcon = Utilities.Create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5219725103',
		Size = UDim2.new(0.0, 30, 0.0, 30),
	}
	local playerIcon = {}
	if context == 'battle' then
		playerIcon = Utilities.Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5640326405',
			--	ImageColor3 = Color3.new(1, .7, .7),
			Size = UDim2.new(0.0, 50, 0.0, 50),
		}
	elseif context == 'trade' then
		playerIcon = Utilities.Create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5640350139',
			Size = UDim2.new(0.0, 50, 0.0, 50),
		}
	end

	local advance = Utilities.Signal()
	local manualAdvance = Utilities.Signal()
	local waitingForManualAdvance
	userInputService.InputBegan:connect(function(inputObject)
		if inputObject.KeyCode == Enum.KeyCode.ButtonA or inputObject.KeyCode == Enum.KeyCode.ButtonX or ((inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch) and inputObject.UserInputState == Enum.UserInputState.Begin) then
			advance:fire()
		end
	end)
	NPCChat.AdvanceSignal = advance

	local function getNPCTarget()
		local camP = workspace.CurrentCamera.CoordinateFrame.p
		local targ, pos = Utilities.findPartOnRayWithIgnoreFunction(Ray.new(camP, (mouse.hit.p-camP).unit*100), {player.Character}, function(obj) return --[[obj:IsA('BasePart') and]] (obj.Transparency >= 1.0 and obj.Name ~= 'Main') or (obj.Parent and obj.Parent:IsA('Accoutrement')) end)
		if targ and targ.Parent and (interactableNPCs[targ.Parent] or targ.Parent:FindFirstChild('Interact')) and targ.Parent:FindFirstChild('HumanoidRootPart') and (targ.Parent.HumanoidRootPart.Position-player.Character.HumanoidRootPart.Position).magnitude < (customMaxInteractDist[targ.Parent] or maxInteractDistance) then
			return targ.Parent
		end
		return nil, targ, pos
	end

	local function getOtherTarget(targ, pos)
		--	local targ = mouse.Target
		if not targ or not targ.Parent then return end
		if targ.Parent.Name == '#PC' and (targ.Parent.Main.Position-player.Character.HumanoidRootPart.Position).magnitude <= maxInteractDistance then
			return targ.Parent, 'pc'
		elseif targ.Parent:FindFirstChild('#InanimateInteract') then
			local kind = targ.Parent['#InanimateInteract'].Value
			local closeEnough
			if kind == 'rockClimb' then
				closeEnough = ((targ.Parent.Main.Position-player.Character.HumanoidRootPart.Position)*Vector3.new(1,0,1)).magnitude <= 9
			else
				local maxDist = customMaxInteractDist[kind] or maxInteractDistance+2
				closeEnough = (targ.Parent.Main.Position-player.Character.HumanoidRootPart.Position).magnitude <= maxDist
			end
			if closeEnough then
				return targ.Parent, 'inanimateInteract', kind
			end
		elseif targ.Name == 'Water' then
			local mp = pos--mouse.Hit.p
			local root = player.Character.HumanoidRootPart
			local cp = root.Position
			pcall(function()
				local human = Utilities.getHumanoid()
				if human.RigType == Enum.HumanoidRigType.R15 then
					cp = cp + Vector3.new(0, 3 - root.Size.Y/2 - human.HipHeight, 0)
				end
			end)
			if mp.y < cp.y-2.9 and mp.y > cp.y-8 and Vector3.new(mp.x-cp.x, 0, mp.z-cp.z).magnitude < 8.5 then--maxInteractDistance then
				return targ, 'inanimateInteract', 'Water'
			end
		end
		if context == 'battle' or context == 'trade' then
			local opponent = players:GetPlayerFromCharacter(targ.Parent)
			if not opponent or opponent == player then return end
			local s, tooFar = pcall(function() return (player.Character.HumanoidRootPart.Position-opponent.Character.HumanoidRootPart.Position).magnitude > 10 end)
			if s and tooFar then return end
			return opponent
		end
	end

	local interacting = false
	local function onCheckMouse()
		local targ, hitObj, hitPos = getNPCTarget()
		local cb = NPCChat.chatBox
		chatIcon.Parent = nil
		pcIcon.Parent = nil
		interactIcon.Parent = nil
		playerIcon.Parent = nil
		if (cb and cb.Parent) or interacting then return end
		if targ then
			chatIcon.Parent = gui
			for i = 1, 3 do
				chatIcon.Position = UDim2.new(0.0, mouse.X + 5, 0.0, mouse.Y + 20)-- - 16)
				stepped:wait()
			end
		else
			local t, kind = getOtherTarget(hitObj, hitPos)
			if not t then return end
			if kind == 'pc' then
				pcIcon.Parent = gui
				for i = 1, 3 do
					pcIcon.Position = UDim2.new(0.0, mouse.X + 8, 0.0, mouse.Y + 17)
					stepped:wait()
				end
			elseif kind == 'inanimateInteract' then
				interactIcon.Parent = gui
				for i = 1, 3 do
					interactIcon.Position = UDim2.new(0.0, mouse.X + 3, 0.0, mouse.Y + 22)
					stepped:wait()
				end
			elseif t:IsA('Player') then
				playerIcon.Parent = gui
				for i = 1, 3 do
					playerIcon.Position = UDim2.new(0.0, mouse.X - 2, 0.0, mouse.Y + 20)
					stepped:wait()
				end
			end
		end
	end

	local function onMouseDown()
		if interacting or not _p.MasterControl.WalkEnabled then return end
		local cb = NPCChat.chatBox
		if cb and cb.Parent then 
			--		advance:fire()
			return
		end
		if not NPCChat.enabled then return end
		local targ, hitObj, hitPos = getNPCTarget()
		if not targ then
			local kind, arg1
			targ, kind, arg1 = getOtherTarget(hitObj, hitPos)
			if not targ then
				-- be sure to debounce silent interactions and
				-- add proximity checks manually
				pcall(function() silentInteract[hitObj.Parent]() end)
				return
			end
			if kind == 'pc' then
				if not NPCChat.enabled then return end
				NPCChat:disable()
				_p.Menu.pc:bootUp(targ)
				NPCChat:enable()
			elseif kind == 'inanimateInteract' then
				local v = inanimateInteract[arg1]
				if type(v) == 'function' then
					v(targ, hitPos)
				end
			elseif targ:IsA('Player') then
				if context == 'battle' then
					playerIcon.Parent = nil
					_p.PVP:onClickedPlayer(targ)
				elseif context == 'trade' then
					playerIcon.Parent = nil
					_p.TradeMatching:onClickedPlayer(targ)
				end
			end
			return
		end
		if not _p.Menu.enabled then return end
		chatIcon.Parent = nil
		interacting = true

		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		for _, npc in pairs(_p.DataManager.currentChunk:getNPCs()) do
			if npc.model == targ then
				spawn(function() ypcall(function() npc:LookAt(player.Character.HumanoidRootPart.Position) end) end)
				break
			end
		end
		spawn(function() ypcall(function() _p.MasterControl:LookAt(targ.HumanoidRootPart.Position) end) end)

		local interact = interactableNPCs[targ] or targ.Interact
		if type(interact) == 'function' then
			interact()
			_p.MasterControl.WalkEnabled = true
			----_p.MasterControl:Start()
			interacting = false
			return
		elseif type(interact) == 'userdata' then
			if interact:IsA('StringValue') then
				interact = interact.Value
				pcall(function() interact = Utilities.jsonDecode(interact) end)
			elseif interact:IsA('ModuleScript') then
				interact = require(interact)
			else
				_p.MasterControl.WalkEnabled = true
				----_p.MasterControl:Start()
				interacting = false
				return
			end
		end

		chatTarget = targ:FindFirstChild('Head')
		if type(interact) == 'table' then
			NPCChat:say(unpack(interact))
		else
			NPCChat:say(interact)
		end

		_p.MasterControl.WalkEnabled = true
		----_p.MasterControl:Start()
		interacting = false
	end

	local font = Utilities.AvenirFont--require(storage.Utilities.FontDisplayService.FontCreator).load('Avenir')
	function NPCChat:doChat()
		spawn(function() _p.Menu:close() end)
		local gui = Utilities.frontGui
		local chatBox = self.chatBox
		if not chatBox then
			chatArrow = Utilities.Create 'ImageLabel' {
				Name = 'ChatArrowPointer',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5217697142',
				Visible = false,
				ZIndex = 8,
				Parent = gui,
			}
			chatBox = _p.RoundedFrame:new {
				Name = 'ChatBox',
				ClipsDescendants = true,
				ZIndex = 9,
			}
			chatBox.gui.Changed:connect(function(prop)
				if prop ~= 'Parent' then return end
				local cb = chatBox
				if not chatTarget or not cb.gui.Parent then
					chatArrow.Visible = false
					return
				end
				while cb.gui.Parent do
					if not chatTarget then
						chatArrow.Visible = false
						break
					end
					local pos, onscreen = workspace.CurrentCamera:WorldToScreenPoint(chatTarget.Position)
					if onscreen then
						local p1 = Vector2.new(cb.AbsolutePosition.X + cb.AbsoluteSize.X*.5,
							cb.AbsolutePosition.Y + (self.bottom and cb.AbsoluteSize.Y*.25 or cb.AbsoluteSize.Y*.75))
						local p2 = Vector2.new(pos.x, pos.y)
						local offset = p2-p1
						p2 = p1 + offset*.9
						offset = p2-p1
						chatArrow.Size = UDim2.new(0.0, cb.AbsoluteSize.Y*0.3, 0.0, offset.magnitude)
						chatArrow.Rotation = math.deg(math.atan2(offset.y, offset.x))-90
						local p = p1 + offset/2 - chatArrow.AbsoluteSize/2
						chatArrow.Position = UDim2.new(0.0, p.x, 0.0, p.y)
						chatArrow.Visible = true
					else
						chatArrow.Visible = false
					end
					stepped:wait()
				end
			end)
			continueIcon = Utilities.Create 'ImageLabel' {
				Image = 'rbxassetid://14912464',
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.2, 0, 0.1333, 0),
				Position = UDim2.new(0.94, 0, 0.775, 0),
				Visible = false,
				ZIndex = 10,
				Parent = chatBox.gui,
			}
			self.chatBox = chatBox
		end

		local boxHeightFill = 0.65
		local line1Pos = (1-boxHeightFill)/2
		local line2Pos = line1Pos + boxHeightFill/(font.baseHeight*2+font.lineSpacing)*(font.baseHeight+font.lineSpacing)
		local lineHeight = boxHeightFill/(font.baseHeight*2+font.lineSpacing)*font.baseHeight

		while #chatQueue > 0 do
			local line = 0
			local lines = {}
			chatBox.Size = UDim2.new(0.0, gui.AbsoluteSize.X*0.75, 0.0, gui.AbsoluteSize.Y*0.225)
			chatBox.Position = UDim2.new(0.0, gui.AbsoluteSize.X*0.125, 0.0, self.bottom and gui.AbsoluteSize.Y*0.75 or gui.AbsoluteSize.Y*0.025)
			chatBox.Parent = gui
			chatBox.CornerRadius = chatBox.AbsoluteSize.Y / 4

			local str = table.remove(chatQueue, 1)
			local overflow
			local yesorno = false
			local thisWaitingForManualAdvance = false
			repeat
				if str:sub(1, 5):lower() == '[y/n]' then
					yesorno = true
					self.answer = nil
					str = str:sub(6)
				end
				if str:sub(1, 4):lower() == '[ma]' then
					thisWaitingForManualAdvance = true
					waitingForManualAdvance = true
					str = str:sub(5)
				end
				line = line + 1
				local lf = Utilities.Create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.9, 0, lineHeight, 0),
					Position = UDim2.new(0.05, 0, line==1 and line1Pos or line2Pos, 0),
					Parent = self.chatBox.gui,
					ZIndex = 10,
				}
				lines[line] = lf
				if line > 2 then
					local l1 = lines[line-2]
					local l2 = lines[line-1]
					local offset = line2Pos-line1Pos
					Utilities.Tween(.2, 'easeOutCubic', function(a)
						l1.Position = UDim2.new(0.05, 0, line1Pos-a*offset, 0)
						l2.Position = UDim2.new(0.05, 0, line2Pos-a*offset, 0)
					end)
					l1:remove()
				end
				overflow = write(str) {
					Size = lf.AbsoluteSize.Y,
					Frame = lf,
					Color = Color3.new(0.4, 0.4, 0.4),
					WritingToChatBox = true,
					AnimationRate = 35, -- ht / sec
				}

				if yesorno and not overflow then
					yesorno = false
					self.answer = self:promptYesOrNo()
					--				if thisWaitingForManualAdvance and waitingForManualAdvance then
					--					manualAdvance:wait()
					--				end
				else
					if line ~= 1 and overflow then
						continueIcon.Visible = true
						advance:wait()
						continueIcon.Visible = false
					elseif not overflow then
						if thisWaitingForManualAdvance then
							if waitingForManualAdvance then
								manualAdvance:wait()
							end
						else
							continueIcon.Visible = true
							advance:wait()
							continueIcon.Visible = false
						end
					end
				end
				str = overflow
				if self.canceling then break end
			until not overflow
			continueIcon.Parent = nil
			chatBox:ClearAllChildren()
			continueIcon.Parent = chatBox.gui
			if self.canceling then break end
		end

		chatArrow.Visible = false
		chatTarget = nil
		chatBox.Parent = nil
	end


	do
		local sig, yon
		function NPCChat:promptYesOrNo()
			if not yon then
				sig = Utilities.Signal()
				NPCChat.yonSignal = sig
				yon = _p.RoundedFrame:new {
					Name = 'YesOrNoPrompt',
					BackgroundColor3 = Color3.new(1, 1, 1),
					Size = UDim2.new(0.15, 0, 0.3, 0),
					Position = UDim2.new(0.7, 0, 0.275, 0),
					ZIndex = 9, Parent = Utilities.frontGui,
				}
				write 'Yes' {
					Frame = Utilities.Create 'ImageButton' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.8, 0, 0.25, 0),
						Position = UDim2.new(0.1, 0, 0.175, 0),
						ZIndex = 10,
						Parent = yon.gui,
						MouseButton1Click = function()
							yon.Visible = false
							sig:fire(true)
						end,
					},
					Scaled = true,
					Color = Color3.new(0.4, 0.4, 0.4),
					TextXAlignment = Enum.TextXAlignment.Center,
				}
				write 'No' {
					Frame = Utilities.Create 'ImageButton' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.8, 0, 0.25, 0),
						Position = UDim2.new(0.1, 0, 0.575, 0),
						ZIndex = 10,
						Parent = yon.gui,
						MouseButton1Click = function()
							yon.Visible = false
							sig:fire(false)
						end,
					},
					Scaled = true,
					Color = Color3.new(0.4, 0.4, 0.4),
					TextXAlignment = Enum.TextXAlignment.Center,
				}
			end
			yon.CornerRadius = Utilities.gui.AbsoluteSize.Y*.05
			yon.Visible = true
			return sig:wait()
		end
	end

	function NPCChat:choose(...)
		local options = {...}
		local sig = Utilities.Signal()
		local u = 1/(1+#options*3)
		local menu = _p.RoundedFrame:new {
			CornerRadius = Utilities.gui.AbsoluteSize.Y*(.02+.01*#options),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0.2, 0, 0.4/9/u, 0),
			Position = UDim2.new(0.6, 0, 0.05, 0),
			Parent = Utilities.frontGui,
		}
		local maxX = 0
		for i, option in pairs(options) do
			local text = write(option) {
				Frame = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, u*1.6, 0),
					Position = UDim2.new(0.1, 0, u*1.2+(i-1)*u*3, 0),
					ZIndex = 2,
					Parent = menu.gui,
					MouseButton1Click = function()
						sig:fire(i)--option)
					end,
				},
				Scaled = true,
				Color = Color3.new(0.4, 0.4, 0.4),
			}
			maxX = math.max(maxX, text.MaxBounds.X)
		end
		local size = menu.Size.X.Scale
		local desiredSize = size/menu.gui.AbsoluteSize.X*maxX+.05
		if desiredSize > size then
			local plus = desiredSize-size
			menu.Size = menu.Size + UDim2.new(plus, 0, 0.0, 0)
			menu.Position = menu.Position + UDim2.new(-plus/2, 0, 0.0, 0)
		end
		local choice = sig:wait()
		menu:remove()
		return choice
	end

	function NPCChat:say(arg1, ...)
		local arg1type = type(arg1)
		if arg1type == 'string' then
			table.insert(chatQueue, arg1)
		elseif arg1type == 'userdata' and arg1.IsA and arg1:IsA('BasePart') then
			chatTarget = arg1
		elseif arg1type == 'table' and arg1.className == 'NPC' then
			pcall(function() chatTarget = arg1.model.Head end)
		end
		for _, c in pairs({...}) do
			table.insert(chatQueue, c)
		end
		local cb = self.chatBox
		if not cb or not cb.Parent then
			self:doChat()
		else
			while cb.gui.Parent do
				cb.gui.AncestryChanged:wait()
			end
		end
		local ans = self.answer
		self.answer = nil
		return ans
	end

	function NPCChat:manualAdvance()
		waitingForManualAdvance = nil
		manualAdvance:fire()
	end

	function NPCChat:clear()
		while #chatQueue > 0 do
			table.remove(chatQueue)
		end
		self.canceling = true
		self.answer = false
		manualAdvance:fire()
		advance:fire()
		pcall(function() self.yonSignal:fire() end)
		self.canceling = nil
	end


	local heartbeatCn
	function NPCChat:enable()
		if self.enabled then return end
		self.enabled = true
		--	runService:BindToRenderStep('NPCMouseCheck', Enum.RenderPriority.Last.Value, onCheckMouse)
		if not heartbeatCn and not Utilities.isTouchDevice() then
			heartbeatCn = runService.Heartbeat:connect(onCheckMouse)
		end
		if not clickCon then clickCon = mouse.Button1Down:connect(onMouseDown) end
	end

	function NPCChat:disable()
		self.enabled = false
		--	runService:UnbindFromRenderStep('NPCMouseCheck')
		pcall(function() heartbeatCn:disconnect() end)
		heartbeatCn = nil
		chatIcon.Parent = nil
		pcIcon.Parent = nil
		interactIcon.Parent = nil
		playerIcon.Parent = nil
		chatTarget = nil
	end


	return NPCChat end