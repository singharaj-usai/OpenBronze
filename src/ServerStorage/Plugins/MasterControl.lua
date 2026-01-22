--SynapseX Decompiler

return function(_p)
	local RunningShoes, Hoverboard, Utilities

	--local Utilities = _p.Utilities
	local UserInputService = game:GetService("UserInputService")
	local ContextActionService = game:GetService("ContextActionService")
	local RunService = game:GetService("RunService")
	local LocalPlayer = _p.player
	local defaultMoveFunc = LocalPlayer.Move
	local currentMoveFunc = defaultMoveFunc
	local PlayerControls
	local UNTRANSFORM_PLAYER_MOVEMENT_WORKAROUND_ENABLED = true
	local zero3 = Vector3.new(0, 0, 0)
	local XZ_PLANE = Vector3.new(1, 0, 1)
	local isIndoors = false
	local jumpEnabled = false
	local MasterControl = {WalkEnabled = false}
	local moveVectorModifiers = {}
	UserInputService.ModalEnabled = true
	function MasterControl:init()
		local PlayerScripts = _p.player:WaitForChild("PlayerScripts", 999999)
		local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule", 999999))
		PlayerControls = PlayerModule:GetControls()
		local PlayerControlsRenderStepFunction = PlayerControls.OnRenderStepped
		function PlayerControls.OnRenderStepped(...)
			if self.WalkEnabled then
				PlayerControlsRenderStepFunction(...)
			end
		end
		self:RecompileMoveProcess()
		self:Stop()
	end
	
	function MasterControl:InstallPlugins(r, h, u)--p)
		RunningShoes = r--p.RunningShoes
		Hoverboard = h
		Utilities = u--p.Utilities
	end
	
	function MasterControl:SetMoveFunc(func)
		currentMoveFunc = func or defaultMoveFunc
		self:RecompileMoveProcess()
	end
	function MasterControl:SetMoveVectorModifier(id, modifyFunc)
		moveVectorModifiers[id] = modifyFunc
		self:RecompileMoveProcess()
	end
	local function wrapMoveFuncUntransformWorkaround(callback)
		return function(player, moveVector, relativeToCamera)
			if moveVector.Magnitude == 0 then
				callback(player, zero3, true)
			elseif not relativeToCamera then
				local cameraCFrame = workspace.CurrentCamera.CFrame
				local lv = cameraCFrame.LookVector
				if lv.Y == -1 or lv.Y == 1 then
					cameraCFrame = CFrame.new(Vector3.new(), cameraCFrame.UpVector)
				else
					cameraCFrame = CFrame.new(Vector3.new(), lv * Vector3.new(1, 0, 1))
				end
				callback(player, cameraCFrame:Inverse() * moveVector, true)
			else
				callback(player, moveVector, relativeToCamera)
			end
		end
	end
	function MasterControl:RecompileMoveProcess()
		local moveFunc = currentMoveFunc
		local resultFunc
		if next(moveVectorModifiers) then
			function resultFunc(player, moveVector, relativeToCamera)
				if self.WalkEnabled then
					for name, modifyFunc in pairs(moveVectorModifiers) do
						moveVector = modifyFunc(moveVector)
					end
				end
				moveFunc(player, moveVector, relativeToCamera)
			end
		else
			resultFunc = moveFunc
		end
		if resultFunc ~= defaultMoveFunc and UNTRANSFORM_PLAYER_MOVEMENT_WORKAROUND_ENABLED then
			resultFunc = wrapMoveFuncUntransformWorkaround(resultFunc)
		end
		PlayerControls.moveFunction = resultFunc
	end
	do
		local bindId = 0
		function MasterControl:WalkTo(point, ws, useDefaultMoveFunction)
			_p.Hoverboard:unequip(true)
			local humanoid = PlayerControls.humanoid
			if not humanoid then
				return
			end
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not root then
				return
			end
			self.lookThread = nil
			local thisThread = {}
			self.walkThread = thisThread
			local ows = humanoid.WalkSpeed
			if ws then
				humanoid.WalkSpeed = ws
			end
			local moveFunc = useDefaultMoveFunction and defaultMoveFunc or PlayerControls.moveFunction
			local initialDirection = (point - root.Position) * XZ_PLANE.Unit
			local signal = Utilities.Signal()
			local lastDist = math.huge
			local bindName = "mcWalkToAlignThread" .. bindId
			bindId = (bindId + 1) % 9000
			local walking = true
			RunService:BindToRenderStep(bindName, Enum.RenderPriority.Character.Value, function()
				if not walking then
					return
				end
				local dif = (point - root.Position) * XZ_PLANE
				local direction = dif.Unit
				local dist = dif.Magnitude
				if self.walkThread ~= thisThread or dist < 0.3 or math.deg(math.acos(direction:Dot(initialDirection))) > 80 or dist > lastDist and dist < 1.2 then
					walking = false
					RunService:UnbindFromRenderStep(bindName)
					signal:fire()
					return
				end
				lastDist = dist
				moveFunc(LocalPlayer, direction, false)
			end)
			if walking then
				signal:wait()
			end
			moveFunc(LocalPlayer, zero3)
			if ws then
				humanoid.WalkSpeed = ows
			end
			if self.walkThread == thisThread then
				self.walkThread = nil
			end
		end
	end
	function MasterControl:Look(v, t)
		_p.Hoverboard:unequip(true)
		local s, root = pcall(function()
			return LocalPlayer.Character.HumanoidRootPart
		end)
		if not s or not root then
			return
		end
		local bg
		if _p.Surf.surfing then
			root = _p.Surf.surfPart
			bg = root:FindFirstChild("BodyGyro")
			if not bg then
				return
			end
		end
		v = (v * XZ_PLANE).Unit
		if t == 0 then
			self.lookThread = nil
			root.CFrame = CFrame.new(root.Position, root.Position + v)
			if bg then
				bg.CFrame = root.CFrame
			end
		else
			do
				local thisThread = {}
				self.lookThread = thisThread
				local theta, lerp = Utilities.lerpCFrame(root.CFrame, CFrame.new(root.Position, root.Position + v))
				t = t or theta * 0.3
				Utilities.Tween(t, "easeOutCubic", function(a)
					if self.lookThread ~= thisThread then
						return false
					end
					root.CFrame = lerp(a)
					if bg then
						bg.CFrame = root.CFrame
					end
				end)
				if self.lookThread == thisThread then
					self.lookThread = nil
				end
			end
		end
	end
	function MasterControl:LookAt(point, t)
		local s, p = pcall(function()
			return LocalPlayer.Character.HumanoidRootPart.Position
		end)
		if not s or not p then
			return
		end
		self:Look(point - p, t)
	end
	function MasterControl:Stop()
		self.walkThread = nil
		PlayerControls.moveFunction(LocalPlayer, zero3, true)
	end
	function MasterControl:SetJumpEnabled(isJumpEnabled)
		jumpEnabled = isJumpEnabled
		pcall(function()
			PlayerControls.humanoid.JumpPower = jumpEnabled and 50 or 0
		end)
	end
	function MasterControl:ForceJump()
	end
	function MasterControl:Hidden(isHidden)
		pcall(function()
			UserInputService.ModalEnabled = isHidden
		end)
		pcall(function()
			_p.RunningShoes:setHidden(isHidden)
		end)
	end
	MasterControl.SetHidden = MasterControl.Hidden
	function MasterControl:GetHidden()
		local isHidden = false
		pcall(function()
			if UserInputService.ModalEnabled then
				isHidden = true
			end
		end)
		return isHidden
	end
	function MasterControl:SetIndoors(isNowIndoors)
		if isIndoors == isNowIndoors then
			return
		end
		isIndoors = isNowIndoors
		if isIndoors then
			do
				local leftArrowValue = UserInputService:IsKeyDown(Enum.KeyCode.Left) and -1 or 0
				local rightArrowValue = UserInputService:IsKeyDown(Enum.KeyCode.Right) and 1 or 0
				local function arrowInput(_, inputState, inputObject)
					if inputObject.KeyCode == Enum.KeyCode.Left then
						leftArrowValue = inputState == Enum.UserInputState.Begin and -1 or 0
					elseif inputObject.KeyCode == Enum.KeyCode.Right then
						rightArrowValue = inputState == Enum.UserInputState.Begin and 1 or 0
					end
				end
				ContextActionService:BindAction("loomIndoorArrowMovement", arrowInput, false, Enum.KeyCode.Left, Enum.KeyCode.Right)
				local function indoorModifyMoveVector(moveVector)
					return moveVector + Vector3.new(leftArrowValue + rightArrowValue, 0, 0)
				end
				self:SetMoveVectorModifier("indoorLR", indoorModifyMoveVector)
			end
		else
			ContextActionService:UnbindAction("loomIndoorArrowMovement")
			self:SetMoveVectorModifier("indoorLR", nil)
		end
	end
	function MasterControl:SetGamepadSelectionFocused(isGamepadSelectionFocused)
		if isGamepadSelectionFocused then
			local activeController = PlayerControls.activeController
			if activeController and activeController.GetHighestPriorityGamepad then
				activeController:Enable(false)
			end
		else
			local activeController = PlayerControls.activeController
			if activeController and activeController.GetHighestPriorityGamepad then
				activeController:Enable(true)
			end
		end
	end
	local function onNewCharacter(character)
		local humanoid
		while character.Parent do
			humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				break
			end
			wait()
		end
		if not humanoid then
			return
		end
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.MaxSlopeAngle = 75
		humanoid.JumpPower = jumpEnabled and 50 or 0
		humanoid.AutoJumpEnabled = false
		humanoid.Changed:Connect(function()
			if humanoid.WalkSpeed > 30 and not ({
				[446187905] = true,
				[1123551] = true,
				[14838908] = true,
				[21632574] = true,
				[1281876] = true,
				[1560128] = true,
				[747409] = true
			})[LocalPlayer.UserId] then
				LocalPlayer:Kick()
			end
			if humanoid.Jump and not jumpEnabled then
				humanoid.Jump = false
			end
		end)
		--[[
		local kickAnimation = Instance.new("Animation")
		kickAnimation.AnimationId = "rbxassetid://1864740301"
		MasterControl.KickAnim = humanoid:LoadAnimation(kickAnimation)
		local giveAnimation = Instance.new("Animation")
		giveAnimation.AnimationId = "rbxassetid://2974924138"
		MasterControl.GiveAnim = humanoid:LoadAnimation(giveAnimation)
		local watchAnim = Instance.new("Animation")
		watchAnim.AnimationId = "rbxassetid://1889612349"
		MasterControl.WatchAnim = humanoid:LoadAnimation(watchAnim)
		local watchCallAnim = Instance.new("Animation")
		watchCallAnim.AnimationId = "rbxassetid://3102466604"
		MasterControl.WatchCallAnim = humanoid:LoadAnimation(watchCallAnim)
		local watchDialAnim = Instance.new("Animation")
		watchDialAnim.AnimationId = "rbxassetid://3105196051"
		MasterControl.WatchDialAnim = humanoid:LoadAnimation(watchDialAnim)
		local digiTransportAnim = Instance.new("Animation")
		digiTransportAnim.AnimationId = "rbxassetid://3109180925"
		MasterControl.DigitalTransportAnim = humanoid:LoadAnimation(digiTransportAnim)
		--]]
	end
	LocalPlayer.CharacterAdded:Connect(onNewCharacter)
	if LocalPlayer.Character then
		coroutine.wrap(onNewCharacter)(LocalPlayer.Character)
	end
	return MasterControl
end
