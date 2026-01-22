--SynapseX Decompiler

return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local guiChangedSignal = Utilities.gui:GetPropertyChangedSignal("AbsoluteSize")
	local CIRCLE_SHEET = "rbxassetid://2180281104"
	local CIRCLE_TOP_LEFT = {
		[1] = false,
		[2] = Vector2.new(0, 0),
		[3] = Vector2.new(5, 0),
		[4] = Vector2.new(12, 0),
		[5] = Vector2.new(21, 0),
		[6] = Vector2.new(32, 0),
		[7] = Vector2.new(45, 0),
		[8] = Vector2.new(60, 0),
		[9] = Vector2.new(77, 0),
		[10] = Vector2.new(96, 0),
		[11] = Vector2.new(117, 0),
		[12] = Vector2.new(140, 0),
		[13] = Vector2.new(165, 0),
		[14] = Vector2.new(192, 0),
		[15] = Vector2.new(221, 0),
		[16] = Vector2.new(252, 0),
		[17] = Vector2.new(285, 0),
		[18] = Vector2.new(320, 0),
		[19] = Vector2.new(357, 0),
		[20] = Vector2.new(396, 0),
		[21] = Vector2.new(437, 0),
		[22] = Vector2.new(480, 0),
		[23] = Vector2.new(525, 0),
		[24] = Vector2.new(572, 0),
		[25] = Vector2.new(621, 0),
		[26] = Vector2.new(672, 0),
		[27] = Vector2.new(725, 0),
		[28] = Vector2.new(780, 0),
		[29] = Vector2.new(837, 0),
		[30] = Vector2.new(896, 0),
		[31] = Vector2.new(957, 0),
		[32] = Vector2.new(0, 63),
		[33] = Vector2.new(65, 63),
		[34] = Vector2.new(132, 63),
		[35] = Vector2.new(201, 63),
		[36] = Vector2.new(272, 63),
		[37] = Vector2.new(345, 63),
		[38] = Vector2.new(420, 63),
		[39] = Vector2.new(497, 63),
		[40] = Vector2.new(576, 63),
		[41] = Vector2.new(657, 63),
		[42] = Vector2.new(740, 63),
		[43] = Vector2.new(825, 63),
		[44] = Vector2.new(912, 63),
		[45] = Vector2.new(0, 152),
		[46] = Vector2.new(91, 152),
		[47] = Vector2.new(184, 152),
		[48] = Vector2.new(279, 152),
		[49] = Vector2.new(376, 152),
		[50] = Vector2.new(475, 152),
		[51] = Vector2.new(576, 152),
		[52] = Vector2.new(679, 152),
		[53] = Vector2.new(784, 152),
		[54] = Vector2.new(891, 152),
		[55] = Vector2.new(0, 261),
		[56] = Vector2.new(111, 261),
		[57] = Vector2.new(224, 261),
		[58] = Vector2.new(339, 261),
		[59] = Vector2.new(456, 261),
		[60] = Vector2.new(575, 261),
		[61] = Vector2.new(696, 261),
		[62] = Vector2.new(819, 261),
		[63] = Vector2.new(0, 386),
		[64] = Vector2.new(127, 386),
		[65] = Vector2.new(256, 386),
		[66] = Vector2.new(387, 386),
		[67] = Vector2.new(520, 386),
		[68] = Vector2.new(655, 386),
		[69] = Vector2.new(792, 386),
		[70] = Vector2.new(0, 525),
		[71] = Vector2.new(141, 525),
		[72] = Vector2.new(284, 525),
		[73] = Vector2.new(429, 525),
		[74] = Vector2.new(576, 525),
		[75] = Vector2.new(725, 525),
		[76] = Vector2.new(0, 676),
		[77] = Vector2.new(153, 676),
		[78] = Vector2.new(308, 676),
		[79] = Vector2.new(465, 676),
		[80] = Vector2.new(624, 676),
		[81] = Vector2.new(785, 676),
		[82] = Vector2.new(0, 839),
		[83] = Vector2.new(165, 839),
		[84] = Vector2.new(332, 839),
		[85] = Vector2.new(501, 839),
		[86] = Vector2.new(672, 839),
		[87] = Vector2.new(845, 839)
	}
	local RoundedFrame
	RoundedFrame = Utilities.class({
		className = "RoundedFrame",
		STYLE = {
			HORIZONTAL_BAR = "HorizontalBar"
		},
		CORNER_RADIUS_CONSTRAINT = {
			FRAME = 0,
			SCREEN = 1,
			ABSOLUTE = 2
		},
		CIRCLE = {SHEET = CIRCLE_SHEET, TOP_LEFT = CIRCLE_TOP_LEFT},
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		ClipsDescendants = false,
		CornerRadius = Utilities.isPhone() and 5 or 10,
		Name = "RoundedFrame",
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
				children[#children + 1] = v
			end
		end
		local object, gui
		local inheritFromGui = {
			AbsoluteSize = true,
			AbsolutePosition = true,
			Activated = true,
			MouseButton1Click = true,
			TouchTap = true,
			MouseEnter = true,
			MouseLeave = true
		}
		object = newproxy(true)
		local mt = getmetatable(object)
		function mt.__index(t, k)
			if inheritFromGui[k] and gui then
				return gui[k]
			end
			return self[k]
		end
		function mt.__newindex(t, k, v)
			local setfunc = self["set" .. k]
			if setfunc then
				setfunc(object, v)
			end
			self[k] = v
		end
		object:createGui()
		gui = self.gui
		for _, ch in pairs(children) do
			pcall(function()
				ch.Parent = gui
			end)
		end
		return object
	end)
	for _, prop in pairs({
		"ClipsDescendants",
		"Name",
		"Parent",
		"Position",
		"Rotation",
		"Size",
		"SizeConstraint",
		"Visible",
		"Selectable",
		"AnchorPoint"
	}) do
		RoundedFrame["set" .. prop] = function(self, value)
			self.gui[prop] = value
		end
	end
	function RoundedFrame:setPropertyAll(property, value)
		self:setPropertyFrames(property, value)
		self:setPropertyImageLabels(property, value)
	end
	function RoundedFrame:setPropertyFrames(property, value)
		if self.backgroundTall then
			self.backgroundTall[property] = value
		end
		if self.backgroundLeft then
			self.backgroundLeft[property] = value
		end
		if self.backgroundRight then
			self.backgroundRight[property] = value
		end
	end
	function RoundedFrame:setPropertyImageLabels(property, value)
		if self.cornerTopLeft then
			self.cornerTopLeft[property] = value
		end
		if self.cornerTopRight then
			self.cornerTopRight[property] = value
		end
		if self.cornerBottomLeft then
			self.cornerBottomLeft[property] = value
		end
		if self.cornerBottomRight then
			self.cornerBottomRight[property] = value
		end
	end
	function RoundedFrame:setCornerRadiusConstraint(cornerRadiusConstraint)
		if cornerRadiusConstraint ~= 0 and cornerRadiusConstraint ~= 1 then
			cornerRadiusConstraint = 2
		end
		if cornerRadiusConstraint == self._CornerRadiusConstraint then
			return
		end
		self._CornerRadiusConstraint = cornerRadiusConstraint
		if self.updateCn then
			self.updateCn:Disconnect()
			self.updateCn = nil
		end
		if cornerRadiusConstraint == 0 then
			self.updateCn = self.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				self:setCornerRadius(self.CornerRadius)
			end)
		elseif cornerRadiusConstraint == 1 then
			self.updateCn = guiChangedSignal:Connect(function()
				self:setCornerRadius(self.CornerRadius)
			end)
		end
		self:setCornerRadius(self.CornerRadius)
	end
	function RoundedFrame:setCornerRadius(cornerRadius)
		local absoluteCornerRadius = cornerRadius
		local cornerRadiusConstraint = self.CornerRadiusConstraint
		if cornerRadiusConstraint == 0 then
			absoluteCornerRadius = self.gui.AbsoluteSize.Y * cornerRadius
		elseif cornerRadiusConstraint == 1 then
			absoluteCornerRadius = Utilities.gui.AbsoluteSize.Y * cornerRadius
		end
		absoluteCornerRadius = math.clamp(math.floor(absoluteCornerRadius + 0.5), 2, 87)
		if absoluteCornerRadius == self.AbsoluteCornerRadius then
			return
		end
		self.AbsoluteCornerRadius = absoluteCornerRadius
		local cornerSize = UDim2.new(0, absoluteCornerRadius, 0, absoluteCornerRadius)
		local spriteSize = Vector2.new(absoluteCornerRadius, absoluteCornerRadius)
		local offset = CIRCLE_TOP_LEFT[absoluteCornerRadius]
		local cornerTopLeft, cornerTopRight, cornerBottomLeft, cornerBottomRight, backgroundLeft, backgroundTall, backgroundRight = self.cornerTopLeft, self.cornerTopRight, self.cornerBottomLeft, self.cornerBottomRight, self.backgroundLeft, self.backgroundTall, self.backgroundRight
		cornerTopLeft.Size = cornerSize
		cornerTopLeft.ImageRectSize = spriteSize
		cornerTopLeft.ImageRectOffset = offset
		cornerTopRight.Size = cornerSize
		cornerTopRight.ImageRectSize = spriteSize
		cornerTopRight.ImageRectOffset = offset + Vector2.new(absoluteCornerRadius, 0)
		cornerBottomLeft.Size = cornerSize
		cornerBottomLeft.ImageRectSize = spriteSize
		cornerBottomLeft.ImageRectOffset = offset + Vector2.new(0, absoluteCornerRadius)
		cornerBottomRight.Size = cornerSize
		cornerBottomRight.ImageRectSize = spriteSize
		cornerBottomRight.ImageRectOffset = offset + Vector2.new(absoluteCornerRadius, absoluteCornerRadius)
		backgroundLeft.Size = UDim2.new(0, absoluteCornerRadius, 1, -2 * absoluteCornerRadius)
		backgroundLeft.Position = UDim2.new(0, 0, 0, absoluteCornerRadius)
		backgroundTall.Size = UDim2.new(1, -2 * absoluteCornerRadius, 1, 0)
		backgroundTall.Position = UDim2.new(0, absoluteCornerRadius, 0, 0)
		backgroundRight.Size = backgroundLeft.Size
		backgroundRight.Position = UDim2.new(1, 0, 0, absoluteCornerRadius)
	end
	function RoundedFrame:setBackgroundColor3(color)
		self:setPropertyFrames("BackgroundColor3", color)
		self:setPropertyImageLabels("ImageColor3", color)
	end
	function RoundedFrame:setBackgroundTransparency(transparency)
		self:setPropertyFrames("BackgroundTransparency", transparency)
		self:setPropertyImageLabels("ImageTransparency", transparency)
	end
	function RoundedFrame:setZIndex(zindex)
		self.gui.ZIndex = zindex
		self:setPropertyAll("ZIndex", zindex)
		if self.fillbar then
			self.fillbar.elem:setZIndex(zindex + 1)
		end
	end
	function RoundedFrame:setStyle(style)
		if self.updateCn then
			self.updateCn:Disconnect()
			self.updateCn = nil
		end
		local gui = self.gui
		if style == RoundedFrame.STYLE.HORIZONTAL_BAR then
			function self.setCornerRadius()
			end
			do
				local currentEdgeDiameter
				local function update()
					local cr = math.clamp(math.ceil(gui.AbsoluteSize.Y * 0.5), 2, 87)
					local ed = 2 * cr
					if ed == currentEdgeDiameter then
						return
					end
					currentEdgeDiameter = ed
					local spriteEffectiveWidth = cr
					local spriteSize = Vector2.new(spriteEffectiveWidth, ed)
					local edgeSize = UDim2.new(0, spriteEffectiveWidth, 1, 0)
					local offset = CIRCLE_TOP_LEFT[cr]
					local cornerTopLeft, cornerTopRight, backgroundTall = self.cornerTopLeft, self.cornerTopRight, self.backgroundTall
					cornerTopLeft.Size = edgeSize
					cornerTopLeft.ImageRectSize = spriteSize
					cornerTopLeft.ImageRectOffset = offset
					cornerTopRight.Size = edgeSize
					cornerTopRight.ImageRectSize = spriteSize
					cornerTopRight.ImageRectOffset = offset + Vector2.new(ed - spriteEffectiveWidth, 0)
					backgroundTall.Size = UDim2.new(1, -2 * spriteEffectiveWidth, 1, 0)
					backgroundTall.Position = UDim2.new(0, spriteEffectiveWidth, 0, 0)
				end
				self.updateCn = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
				self.updateFn = update
				update()
			end
		else
			if not self.cornerBottomLeft then
				self.cornerBottomLeft = create("ImageLabel")({
					Name = "CornerBottomLeft",
					BackgroundTransparency = 1,
					Image = CIRCLE_SHEET,
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new(0, 0, 1, 0),
					Parent = gui
				})
				self.keep[self.cornerBottomLeft] = true
			end
			if not self.cornerBottomRight then
				self.cornerBottomRight = create("ImageLabel")({
					Name = "CornerBottomRight",
					BackgroundTransparency = 1,
					Image = CIRCLE_SHEET,
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(1, 0, 1, 0),
					Parent = gui
				})
				self.keep[self.cornerBottomRight] = true
			end
			if not self.backgroundLeft then
				self.backgroundLeft = create("Frame")({
					Name = "BackgroundLeft",
					BorderSizePixel = 0,
					Parent = gui
				})
				self.keep[self.backgroundLeft] = true
			end
			if not self.backgroundRight then
				self.backgroundRight = create("Frame")({
					Name = "BackgroundRight",
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(1, 0),
					Parent = gui
				})
				self.keep[self.backgroundRight] = true
			end
			self:setCornerRadiusConstraint(self.CornerRadiusConstraint)
		end
	end
	function RoundedFrame:createGui()
		if self.gui then
			return
		end
		local gui = create(self.Button and "ImageButton" or "Frame")({
			BackgroundTransparency = 1,
			ClipsDescendants = self.ClipsDescendants,
			Name = self.Name,
			AnchorPoint = self.AnchorPoint,
			Position = self.Position,
			Rotation = self.Rotation,
			Size = self.Size,
			SizeConstraint = self.SizeConstraint,
			Visible = self.Visible,
			Parent = self.Parent,
			Selectable = self.Selectable,
			MouseButton1Click = self.MouseButton1Click,
			Activated = self.Activated
		})
		self.cornerTopLeft = create("ImageLabel")({
			Name = "CornerTopLeft",
			BackgroundTransparency = 1,
			Image = CIRCLE_SHEET,
			Parent = gui
		})
		self.cornerTopRight = create("ImageLabel")({
			Name = "CornerTopRight",
			BackgroundTransparency = 1,
			Image = CIRCLE_SHEET,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Parent = gui
		})
		self.backgroundTall = create("Frame")({
			Name = "BackgroundTall",
			BorderSizePixel = 0,
			Parent = gui
		})
		do
			local parent
			local function check()
				local s, r = pcall(function()
					if not gui.Parent and #gui:GetChildren() == 0 then
						return true
					end
					return false
				end)
				if not s or r then
					print("RoundedFrame: cleaning up self")
					self:remove()
				end
			end
			local function hookupWatchParent()
				if gui.Parent and gui.Parent ~= parent then
					if self.parentChangedCn then
						self.parentChangedCn:Disconnect()
					end
					parent = gui.Parent
					self.parentChangedCn = parent.ChildRemoved:Connect(check)
				end
			end
			gui.AncestryChanged:Connect(hookupWatchParent)
			hookupWatchParent()
		end
		self.keep = {
			[self.cornerTopLeft] = true,
			[self.cornerTopRight] = true,
			[self.backgroundTall] = true
		}
		self.gui = gui
		self:setStyle(self.Style)
		self:setBackgroundTransparency(self.BackgroundTransparency)
		self:setBackgroundColor3(self.BackgroundColor3)
		self:setZIndex(self.ZIndex)
	end
	local gyrColors = {
		Color3.new(0, 0.8, 0.4),
		Color3.new(1, 0.8, 0.4),
		Color3.new(1, 0.4, 0.4)
	}
	function RoundedFrame:setupFillbar(colors, border, ratio)
		if self.fillbar then
			return
		end
		ratio = ratio or 1
		if colors == "gyr" then
			colors = gyrColors
		end
		local container = create("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -border * 2, 1, -border * 2),
			Position = UDim2.new(0, border, 0, border),
			Parent = self.gui
		})
		local clipper = create("Frame")({
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Parent = container
		})
		local f = {
			colors = type(colors) == "table" and colors or {colors},
			ratio = ratio,
			border = border,
			animating = false
		}
		local elem = RoundedFrame:new({
			Name = "fill",
			BackgroundColor3 = f.colors[1],
			Style = RoundedFrame.STYLE.HORIZONTAL_BAR,
			ZIndex = self.ZIndex + 1,
			Visible = ratio > 0,
			Parent = clipper
		})
		local function setSizeForRatio(r)
			clipper.Size = UDim2.new(r, 0, 1, 0)
			local size = container.AbsoluteSize
			elem.Size = UDim2.new(0, size.X, 0, size.Y)
			elem.Visible = r > 0
			if elem.Visible and #f.colors == 3 then
				local c = f.c
				if r <= 0.2 then
					if f.c ~= 3 then
						elem.BackgroundColor3 = f.colors[3]
						f.c = 3
					end
				elseif r <= 0.5 then
					if f.c ~= 2 then
						elem.BackgroundColor3 = f.colors[2]
						f.c = 2
					end
				elseif f.c ~= 1 then
					elem.BackgroundColor3 = f.colors[1]
					f.c = 1
				end
			end
			f.ratio = r
		end
		f.elem = elem
		f.setSizeForRatio = setSizeForRatio
		container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if not f.animating then
				setSizeForRatio(f.ratio)
			end
		end)
		setSizeForRatio(ratio)
		self.fillbar = f
	end
	function RoundedFrame:setFillbarRatio(toRatio, animated, fn)
		local f = self.fillbar
		if animated then
			do
				local thisThread = {}
				self.animateFillThread = thisThread
				local fromRatio = f.ratio
				local t = math.abs(fromRatio - toRatio) * 1.5
				f.animating = true
				Utilities.Tween(t, Utilities.Timing.cubicBezier(t, 0.45, 0.6, 0.6, 0.9), function(a)
					if self.animateFillThread ~= thisThread then
						return false
					end
					local r = fromRatio + (toRatio - fromRatio) * a
					f.setSizeForRatio(r)
					if fn then
						fn(a, r)
					end
				end)
				if self.animateFillThread == thisThread then
					f.animating = false
					self.animateFillThread = nil
					return true
				end
				return false
			end
		else
			f.animating = false
			self.animateFillThread = nil
			f.setSizeForRatio(toRatio)
		end
	end
	function RoundedFrame:ClearAllChildren()
		self:clearAllChildren()
	end
	function RoundedFrame:clearAllChildren()
		local keep = self.keep
		for _, ch in pairs(self.gui:GetChildren()) do
			if not keep[ch] then
				ch:remove()
			end
		end
	end
	function RoundedFrame:remove()
		self:remove()
	end
	function RoundedFrame:remove()
		if self.fillbar then
			self.animateFillThread = nil
			self.fillbar.elem:remove()
			self.fillbar = nil
		end
		if self.parentChangedCn then
			self.parentChangedCn:Disconnect()
			self.parentChangedCn = nil
		end
		if self.updateCn then
			self.updateCn:Disconnect()
			self.updateCn = nil
		end
		if self.gui then
			self.gui:remove()
			self.gui = nil
		end
	end
	return RoundedFrame
end
