-- todo: options
return function(_p)--local _p = require(script.Parent)
local Utilities = _p.Utilities
local isTouchDevice = Utilities.isTouchDevice()

local contextActionService = game:GetService('ContextActionService')
local isR15 = false
local runAnim = Utilities.Create 'Animation' {
	AnimationId = 'rbxassetid://'.._p.animationId.Run,
}
local runAnimTrack
local totalSpeedMultiplier = 1
local speedMultipliers = {}
local currentSpeed = 16

local run = {
	enabled = false,
	running = false,
	toggleMode = false,
	hotKey = Enum.KeyCode.LeftShift,
	gamePadButton = Enum.KeyCode.ButtonB,
	caButtonState = 0
}

local playing = false
local function humanoidRunning(speed)
	if speed > 0.01 and run.running then
		if not playing then
			playing = true
			runAnimTrack:Play(nil, nil, totalSpeedMultiplier)
		end
	elseif playing then
		playing = false
		runAnimTrack:Stop()
	end
end

local cachedHumanoid
local function getHumanoid()
	if not _p.player.Character then return end
	if cachedHumanoid and cachedHumanoid.Parent == _p.player.Character then
		return cachedHumanoid
	end
	for _, human in pairs(_p.player.Character:GetChildren()) do
		if human:IsA('Humanoid') then
			local humanIsR15 = human.RigType == Enum.HumanoidRigType.R15
			if humanIsR15 ~= isR15 then
				runAnim:remove()
				runAnim = Utilities.Create 'Animation' {
					AnimationId = 'rbxassetid://'.._p.animationId[humanIsR15 and 'R15_Run' or 'Run'],
				}
				isR15 = humanIsR15
			end
			cachedHumanoid = human
			runAnimTrack = human:LoadAnimation(runAnim)
			human.Running:connect(humanoidRunning)
			return human
		end
	end
end

local function updateSpeed()
	local speed = currentSpeed
	local mult = 1
	for _, m in pairs(speedMultipliers) do
		mult = mult * m
	end
	totalSpeedMultiplier = mult
	pcall(function() getHumanoid().WalkSpeed = speed * mult end)
	pcall(function()
		if playing then--runAnimTrack.IsPlaying then
			runAnimTrack:AdjustSpeed(mult)
		end
	end)
end

function run:setRunning(isRunning)
	if isRunning and not self.enabled then return end -- prevent running when disabled (in case this function is accidentally called)
	self.running = isRunning
	pcall(function() contextActionService:SetTitle('Run', isRunning and 'Walk' or 'Run') end)
	currentSpeed = isRunning and 26 or 16
	updateSpeed()
end

function run:toggle()
	self:setRunning(not self.running)
end

function run:setHidden(isHidden)
	if not isTouchDevice or not self.enabled then return end
	pcall(function() Utilities.fastSpawn(function() contextActionService:GetButton('Run').Visible = not isHidden end) end)
end

function run:setToggleMode(toggleMode)
	self.toggleMode = toggleMode
	self:setRunning(false)
end

-- this action is shard between touch devices and mouse/keyboard
local function runAction(actionName, userInputState, inputObject)
	if userInputState == Enum.UserInputState.Begin then
		if isTouchDevice then
			local hasHoverboard = _p.PlayerData.completedEvents.hasHoverboard
			if run.caButtonState == 1 then
				run.caButtonState = 2
				run:setRunning(true)
				pcall(function() contextActionService:SetTitle('Run', hasHoverboard and 'Hover' or 'Walk') end)
			elseif run.caButtonState == 2 then
				run.caButtonState = hasHoverboard and 3 or 1
				run:setRunning(false)
				pcall(function() contextActionService:SetTitle('Run', hasHoverboard and 'Walk' or 'Run') end)
				if hasHoverboard then _p.Hoverboard:equip() end
			elseif run.caButtonState == 3 then
				run.caButtonState = 1
				pcall(function() contextActionService:SetTitle('Run', 'Run') end)
				_p.Hoverboard:unequip(true)
			end
		elseif run.toggleMode then
			run:toggle()
		else
			run:setRunning(true)
		end
	elseif userInputState == Enum.UserInputState.End then
		if not isTouchDevice and not run.toggleMode then
			run:setRunning(false)
		end
	end
end

-- this action is specific to gamepad
local function runGamepad(actionName, userInputState, inputObject)
	if userInputState == Enum.UserInputState.Begin then
		run:setRunning(true)
	elseif userInputState == Enum.UserInputState.End then
		run:setRunning(false)
	end
end

function run:setHotKey(hotKey)
	self.hotKey = hotKey
	contextActionService:UnbindAction('Run')
	contextActionService:BindAction('Run', runAction, true, hotKey)
end

function run:setGamepadButton(button)
	self.gamePadButton = button
	contextActionService:UnbindAction('GamepadRun')
	contextActionService:BindAction('GamepadRun', runGamepad, false, button)
end

function run:setSpeedMultiplier(key, mult)
	speedMultipliers[key] = mult
	updateSpeed()
end

function run:removeSpeedMultiplier(key)
	speedMultipliers[key] = nil
	updateSpeed()
end

function run:enable()
	self.enabled = true
	pcall(getHumanoid)
	contextActionService:BindAction('Run', runAction, true, self.hotKey)
	pcall(function() contextActionService:SetTitle('Run', _p.Hoverboard.equipped and 'Walk' or 'Run') end)
	run.caButtonState = _p.Hoverboard.equipped and 3 or 1
	contextActionService:BindAction('GamepadRun', runGamepad, false, self.gamePadButton)
end

function run:disable()
	self.enabled = false
	self:setRunning(false)
	contextActionService:UnbindAction('Run')
	contextActionService:UnbindAction('GamepadRun')
end

return run end