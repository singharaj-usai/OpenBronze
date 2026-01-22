--SynapseX Decompiler

return function(_p)
	local player = game:GetService("Players").LocalPlayer
	local Utilities = _p.Utilities
	local stepped = game:GetService("RunService").RenderStepped
	local color = function(r, g, b)
		return Color3.new(r / 255, g / 255, b / 255)
	end
	local ASPECT_RATIO = 2.5
	local BACKGROUND_COLOR = color(102, 102, 102)
	local STATE_COLOR = color(204, 204, 204)
	local ENABLED_COLOR_MAIN = {
		124,
		186,
		99
	}
	local ENABLED_COLOR_LINES = {
		94,
		141,
		75
	}
	local DISABLED_COLOR_MAIN = {
		127,
		127,
		127
	}
	local DISABLED_COLOR_LINES = {
		102,
		102,
		102
	}
	local ToggleButton = Utilities.class({
		className = "ToggleButton",
		Value = false,
		Enabled = true,
		Name = "ToggleButton",
		AnchorPoint = Vector2.new(),
		Position = UDim2.new(),
		Rotation = 0,
		Size = UDim2.new(),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Visible = true,
		ZIndex = 1
	}, function(self)
		local children = {}
		for i, v in pairs(self) do
			if type(i) == "number" then
				table.insert(children, v)
			end
		end
		local inheritFromGui = { AbsoluteSize = true, AbsolutePosition = true }
		local mt = {
			__index = function(t, k)
				if inheritFromGui[k] then
					return self.gui[k]
				end
				return self[k]
			end,
			__newindex = function(t, k, v)
				if self["set" .. k] then
					self["set" .. k](self, v)
				end
				self[k] = v
			end
		}
		self:createGui()
		for _, ch in pairs(children) do
			pcall(function()
				ch.Parent = self.gui
			end)
		end
		return setmetatable({}, mt)
	end)
	local mouseDown = false
	local function ToggleButtonClicked(tb)
		mouseDown = true
		local mouse = player:GetMouse()
		local ct = tb.container.gui
		local sg = tb.switch.gui
		local sxs = tb.switch.Size.X.Scale
		local padX = 0.075 / ASPECT_RATIO
		local xOffset = sg.AbsolutePosition.X - mouse.X - padX * ct.AbsoluteSize.X
		local thisThread = {}
		tb.dragThread = thisThread
		local downTick = tick()
		local mouseUpConn = game:GetService("UserInputService").InputEnded:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
				mouseDown = false
			end
		end)
		while mouseDown and tb.Enabled do
			local xp = mouse.X + xOffset - ct.AbsolutePosition.X
			local a = xp / (1 - padX * 2 - sxs) / ct.AbsoluteSize.X
			tb:updateAlpha(a)
			stepped:wait()
		end
		mouseUpConn:Disconnect()
		local lastAlpha = tb._alpha
		local v = tb.Value
		local value = lastAlpha > 0.5
		if tick() - downTick < 0.15 then
			value = not value
		end
		tb.Value = value
		if tb.Value ~= v then
			tb.ValueChanged:fire()
		end
		tb:animateToValue(value)
	end
	function ToggleButton:animateToValue(value)
		local thisThread = {}
		self.dragThread = thisThread
		local lastAlpha = self._alpha or 0
		local goalAlpha = value and 1 or 0
		self.Value = value
		Utilities.Tween(0.35, "easeOutCubic", function(a)
			if self.dragThread ~= thisThread then
				return false
			end
			self:updateAlpha(lastAlpha + (goalAlpha - lastAlpha) * a)
		end)
		if self.dragThread == thisThread then
			self.dragThread = nil
		end
	end

	function ToggleButton:toggleValue()
		local value = not self.Value
		self.Value = value
		self.ValueChanged:fire()
		self:animateToValue(value)
	end

	function ToggleButton:updateAlpha(a)
		self._alpha = a
		a = math.max(0, math.min(1, a))
		local padX = 0.075 / ASPECT_RATIO
		self.switch.Position = UDim2.new(padX + (1 - padX * 2 - self.switch.Size.X.Scale) * a, 0, 0.075, 0)
		local color1 = color(DISABLED_COLOR_MAIN[1] + (ENABLED_COLOR_MAIN[1] - DISABLED_COLOR_MAIN[1]) * a,
			DISABLED_COLOR_MAIN[2] + (ENABLED_COLOR_MAIN[2] - DISABLED_COLOR_MAIN[2]) * a,
			DISABLED_COLOR_MAIN[3] + (ENABLED_COLOR_MAIN[3] - DISABLED_COLOR_MAIN[3]) * a)
		self.switch.BackgroundColor3 = color1
		local color2 = color(DISABLED_COLOR_LINES[1] + (ENABLED_COLOR_LINES[1] - DISABLED_COLOR_LINES[1]) * a,
			DISABLED_COLOR_LINES[2] + (ENABLED_COLOR_LINES[2] - DISABLED_COLOR_LINES[2]) * a,
			DISABLED_COLOR_LINES[3] + (ENABLED_COLOR_LINES[3] - DISABLED_COLOR_LINES[3]) * a)
		for _, line in pairs(self.lines) do
			line.BackgroundColor3 = color2
		end
		self.onImage.ImageTransparency = 1 - a
		self.offImage.ImageTransparency = a
	end

	function ToggleButton:setZIndex(zindex)
		self.container.ZIndex = zindex
	end

	function ToggleButton:createGui()
		if self.gui then
			return
		end
		local zindex = self.ZIndex
		local create = Utilities.Create
		local gui = create("Frame")({
			BackgroundTransparency = 1,
			SizeConstraint = self.SizeConstraint,
			Size = self.Size,
			AnchorPoint = self.AnchorPoint,
			Position = self.Position,
			Parent = self.Parent
		})
		local sizeConstrainer = create("Frame")({
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(-ASPECT_RATIO / 2, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Parent = gui
		})
		local container = _p.RoundedFrame:new({
			Button = true,
			BackgroundColor3 = BACKGROUND_COLOR,
			Size = UDim2.new(2, 0, 1, 0),
			ZIndex = zindex,
			Parent = sizeConstrainer,
			Activated = function(inputObject)
				if inputObject.KeyCode == Enum.KeyCode.ButtonA and inputObject.UserInputType == _p.activeGamepad then
					self:toggleValue()
				end
			end
		})
		local iconSize = 0.8
		local onImage = create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = "rbxassetid://341227219",
			ImageRectSize = Vector2.new(450, 450),
			ImageColor3 = STATE_COLOR,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(iconSize, 0, iconSize, 0),
			Position = UDim2.new(0.25 - iconSize / 2 / ASPECT_RATIO, 0, 0.1, 0),
			ZIndex = zindex,
			Parent = container.gui
		})
		local offImage = create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = "rbxassetid://341227219",
			ImageRectSize = Vector2.new(450, 450),
			ImageRectOffset = Vector2.new(450, 0),
			ImageColor3 = STATE_COLOR,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(iconSize, 0, iconSize, 0),
			Position = UDim2.new(0.75 - iconSize / 2 / ASPECT_RATIO, 0, 0.1, 0),
			ZIndex = zindex,
			Parent = container.gui
		})
		local switch = _p.RoundedFrame:new({
			Button = true,
			Size = UDim2.new(0.5, 0, 0.85, 0),
			ZIndex = zindex,
			Parent = container.gui
		})
		local lines = {}
		do
			local n = 4
			local t = n * 2 - 1
			for i = 1, n do
				table.insert(lines, create("Frame")({
					BorderSizePixel = 0,
					Size = UDim2.new(0.5 / t, 0, 0.6, 0),
					Position = UDim2.new(0.25 + (i - 1) / t, 0, 0.2, 0),
					ZIndex = zindex,
					Parent = switch.gui
				}))
			end
		end
		switch.gui.MouseButton1Down:Connect(function()
			if not self.Enabled or not self.Visible then
				return
			end
			ToggleButtonClicked(self)
		end)
		local function updateCornerRadii()
			container.CornerRadius = gui.AbsoluteSize.Y * 0.15
			switch.CornerRadius = gui.AbsoluteSize.Y * 0.075
		end
		gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCornerRadii)
		updateCornerRadii()
		self.ValueChanged = Utilities.Signal()
		self.gui = gui
		self.container = container
		self.onImage = onImage
		self.offImage = offImage
		self.switch = switch
		self.lines = lines
		self:updateAlpha(self.Value and 1 or 0)
	end

	function ToggleButton:remove()
		pcall(function()
			self.switch:remove()
		end)
		pcall(function()
			self.container:remove()
		end)
		pcall(function()
			self.gui:remove()
		end)
	end

	return ToggleButton
end
