return function(_p)
local Utilities = _p.Utilities
--if not Utilities then pcall(function() Utilities = require(game:GetService('ServerStorage').Utilities) end) end
local create = Utilities.Create

--local roundedFrames = {}

local RoundedFrame = Utilities.class({
	className = 'RoundedFrame',
	
	BackgroundColor3 = Color3.new(1, 1, 1),
	ClipsDescendants = false,
	CornerRadius = Utilities.isPhone() and 5 or 10,
	Name = 'RoundedFrame',
	Position = UDim2.new(),
	Rotation = 0,
	Size = UDim2.new(),
	SizeConstraint = Enum.SizeConstraint.RelativeXY,
	Visible = true,
	ZIndex = 1,
}, function(self)
	local children = {}
	for i, v in pairs(self) do
		if type(i) == 'number' then
			table.insert(children, v)
		end
	end
	
	local inheritFromGui = {AbsoluteSize=true,AbsolutePosition=true,MouseButton1Click=true,TouchTap=true} -- *get* from gui
	local mt = {
		__index = function(t, k)
			if inheritFromGui[k] then
--				if k == 'MouseButton1Click' and Utilities.isTouchDevice() then
--					return self.gui.TouchTap
--				end
				return self.gui[k]
			end
			return self[k]
		end,
		__newindex = function(t, k, v)
			if self['set'..k] then
				self['set'..k](self, v)
			end
			self[k] = v
		end,
	}
	self:createGui()
	
	for _, ch in pairs(children) do
		pcall(function()
			ch.Parent = self.gui
		end)
	end
	
	local object = setmetatable({}, mt)
--	if self.Retain ~= false then
--		roundedFrames[object] = true
--	end
	return object
end)

-- class function
--function RoundedFrame.objectFromGui(gui)
--	for obj in pairs(roundedFrames) do
--		if obj.gui == gui then
--			return obj
--		end
--	end
--end


-- object functions
for _, prop in pairs({'ClipsDescendants','Name','Parent','Position','Rotation','Size','SizeConstraint','Visible','Selectable','AnchorPoint'}) do -- *set* on gui
	RoundedFrame['set'..prop] = function(self, value)
		self.gui[prop] = value
	end
end

function RoundedFrame:setCornerRadius(cornerRadius)
	local gui = self.gui
	gui.CornerTopLeft.Size = UDim2.new(0.0, cornerRadius*2, 0.0, cornerRadius*2)
	gui.CornerTopRight.Size = UDim2.new(0.0, -cornerRadius*2, 0.0, cornerRadius*2)
	gui.CornerBottomLeft.Size = UDim2.new(0.0, cornerRadius*2, 0.0, -cornerRadius*2)
	gui.CornerBottomRight.Size = UDim2.new(0.0, -cornerRadius*2, 0.0, -cornerRadius*2)
	gui.BackgroundTall.Size = UDim2.new(1.0, -cornerRadius*2, 1.0, 0)
	gui.BackgroundTall.Position = UDim2.new(0.0, cornerRadius, 0.0, 0)
	gui.BackgroundWide.Size = UDim2.new(1.0, 0, 1.0, -cornerRadius*2)
	gui.BackgroundWide.Position = UDim2.new(0.0, 0, 0.0, cornerRadius)
end

function RoundedFrame:setBackgroundColor3(backgroundColor3)
	local gui = self.gui
	gui.CornerTopLeft.ImageColor3 = backgroundColor3
	gui.CornerTopRight.ImageColor3 = backgroundColor3
	gui.CornerBottomLeft.ImageColor3 = backgroundColor3
	gui.CornerBottomRight.ImageColor3 = backgroundColor3
	gui.BackgroundTall.BackgroundColor3 = backgroundColor3--ImageColor3 = backgroundColor3--
	gui.BackgroundWide.BackgroundColor3 = backgroundColor3--ImageColor3 = backgroundColor3--
end

function RoundedFrame:setZIndex(zindex)
	local gui = self.gui
	gui.CornerTopLeft.ZIndex = zindex
	gui.CornerTopRight.ZIndex = zindex
	gui.CornerBottomLeft.ZIndex = zindex
	gui.CornerBottomRight.ZIndex = zindex
	gui.BackgroundTall.ZIndex = zindex
	gui.BackgroundWide.ZIndex = zindex
	if self.fillbar then
		self.fillbar.elem.ZIndex = zindex + 1
	end
end

function RoundedFrame:setStyle(style)
	if self.styleCn then
		self.styleCn:disconnect()
		self.styleCn = nil
	end
	local gui = self.gui
	gui.CornerBottomLeft.Visible = true
	gui.CornerBottomRight.Visible = true
	gui.BackgroundWide.Visible = true
	if style == 'HorizontalBar' then
		gui.CornerBottomLeft.Visible = false
		gui.CornerBottomRight.Visible = false
		gui.BackgroundWide.Visible = false
		local fn = function(prop)
			if prop ~= 'AbsoluteSize' then return end
			local cr = gui.AbsoluteSize.Y/2
			self:setCornerRadius(cr)
			self.CornerRadius = cr
		end
		self.styleCn = gui.Changed:connect(fn)
		fn('AbsoluteSize')
	end
end

function RoundedFrame:createGui()
	if self.gui then return end
	local circle = 'rbxasset://textures/WhiteCircle.png'
	local backgroundColor3 = self.BackgroundColor3
	local cornerRadius = self.CornerRadius
	local zindex = self.ZIndex
--	local click = Utilities.isTouchDevice() and 'TouchTap' or 'MouseButton1Click'
	local gui = create(self.Button and 'ImageButton' or 'Frame') {
		BackgroundTransparency = 1.0,
		ClipsDescendants = self.ClipsDescendants,
		Name = self.Name,
		AnchorPoint = self.AnchorPoint,
		Position = self.Position,
		Rotation = self.Rotation,
		Size = self.Size,
		SizeConstraint = self.SizeConstraint,
		Visible = self.Visible,
		ZIndex = zindex,
		Parent = self.Parent,
		
		Selectable = self.Selectable,
		MouseButton1Click = self.MouseButton1Click,--[click] = self.MouseButton1Click,
--		Image = self.Button and 'rbxasset://textures/Blank.png' or nil,
		
		create 'ImageLabel' {
			Name = 'CornerTopLeft',
			Image = circle,
			ImageColor3 = backgroundColor3,
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, cornerRadius*2, 0.0, cornerRadius*2),
			Position = UDim2.new(0.0, 0, 0.0, 0),
			ZIndex = zindex,
		},
		create 'ImageLabel' {
			Name = 'CornerTopRight',
			Image = circle,
			ImageColor3 = backgroundColor3,
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, -cornerRadius*2, 0.0, cornerRadius*2),
			Position = UDim2.new(1.0, 0, 0.0, 0),
			ZIndex = zindex,
		},
		create 'ImageLabel' {
			Name = 'CornerBottomLeft',
			Image = circle,
			ImageColor3 = backgroundColor3,
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, cornerRadius*2, 0.0, -cornerRadius*2),
			Position = UDim2.new(0.0, 0, 1.0, 0),
			ZIndex = zindex,
		},
		create 'ImageLabel' {
			Name = 'CornerBottomRight',
			Image = circle,
			ImageColor3 = backgroundColor3,
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, -cornerRadius*2, 0.0, -cornerRadius*2),
			Position = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = zindex,
		},
		create 'Frame' {--'ImageLabel' {
			Name = 'BackgroundTall',
			
--			BackgroundTransparency = 1.0,
--			Image = circle,
--			ImageColor3 = backgroundColor3,
--			ImageRectSize = Vector2.new(2, 512),
--			ImageRectOffset = Vector2.new(255, 0),
			
			BackgroundColor3 = backgroundColor3,
			BorderSizePixel = 0,
			
			Size = UDim2.new(1.0, -cornerRadius*2, 1.0, 0),
			Position = UDim2.new(0.0, cornerRadius, 0.0, 0),
			ZIndex = zindex,
		},
		create 'Frame' {--'ImageLabel' {
			Name = 'BackgroundWide',
			
--			BackgroundTransparency = 1.0,
--			Image = circle,
--			ImageColor3 = backgroundColor3,
--			ImageRectSize = Vector2.new(512, 2),
--			ImageRectOffset = Vector2.new(0, 255),
			
			BackgroundColor3 = backgroundColor3,
			BorderSizePixel = 0,
			
			Size = UDim2.new(1.0, 0, 1.0, -cornerRadius*2),
			Position = UDim2.new(0.0, 0, 0.0, cornerRadius),
			ZIndex = zindex,
		},
	}
--	if self.Button then
--		local color = self.BackgroundColor3
--		local hoverColor = Color3.new(color.r*1.1, color.g*1.1, color.b*1.1)
--		local clickColor = Color3.new(color.r*0.9, color.g*0.9, color.b*0.9)
--		gui.MouseEnter:connect(function() self:setBackgroundColor3(hoverColor) end)
--		gui.MouseLeave:connect(function() self:setBackgroundColor3(color) end)
--		gui.MouseButton1Down:connect(function() self:setBackgroundColor3(clickColor) end)
--		gui.MouseButton1Up:connect(function() self:setBackgroundColor3(hoverColor) end)
--	end
	do -- detect when our frame has been removeed to clean ourself up
		local parent
		local function check()
			local s, r = pcall(function() 
				if not gui.Parent and #(gui:GetChildren()) == 0 then
					return true
				end
				return false
			end)
			if not s or r then
				print('RoundedFrame: cleaning up self')
				self:remove()
			end
		end
		local function hookupWatchParent()
			if gui.Parent and gui.Parent ~= parent then
				if self.parentChangedCn then
					self.parentChangedCn:disconnect()
				end
				parent = gui.Parent
				self.parentChangedCn = parent.ChildRemoved:connect(check)
			end
		end
		gui.AncestryChanged:connect(hookupWatchParent)
		hookupWatchParent()
	end --
	local keep = {}
	for _, ch in pairs(gui:GetChildren()) do
		keep[ch] = true
	end
	self.keep = keep
	self.gui = gui
	if self.Style then
		self:setStyle(self.Style)
	end
end



-- Fillbars
local gyrColors = {Color3.new(0, .8, .4),Color3.new(1, .8, .4),Color3.new(1, .4, .4)}
function RoundedFrame:setupFillbar(colors, border, ratio)
	if self.fillbar then return end
	ratio = ratio or 1
	if colors == 'gyr' then
		colors = gyrColors
	end
	local f = {
		colors = type(colors) == 'table' and colors or {colors},
		ratio = ratio,
		border = border,
		animating = false,
	}
	local elem = RoundedFrame:new {
		Name = 'fill',
		BackgroundColor3 = f.colors[1],
		Size = UDim2.new(1.0, -border*2, 1.0, -border*2),
		Position = UDim2.new(0.0, border, 0.0, border),
		Style = 'HorizontalBar',
		ZIndex = self.ZIndex + 1,
		Visible = ratio > 0,
		Parent = self.gui,
	}
	local setSizeForRatio = function(r)
		local minSizeX = elem.Parent.AbsoluteSize.Y - border*2
		local maxSizeX = elem.Parent.AbsoluteSize.X - border*2
		local sizeX = minSizeX + (maxSizeX-minSizeX)*r
		elem.Visible = r > 0
		elem.Size = UDim2.new(0.0, sizeX, 1.0, -border*2)
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
			else
				if f.c ~= 1 then
					elem.BackgroundColor3 = f.colors[1]
					f.c = 1
				end
			end
		end
		f.ratio = r
	end
	f.elem = elem
	f.setSizeForRatio = setSizeForRatio
	self.gui.Changed:connect(function(prop)
		if prop ~= 'AbsoluteSize' or f.animating then return end
		setSizeForRatio(f.ratio)
	end)
	setSizeForRatio(ratio)
	self.fillbar = f
end
function RoundedFrame:setFillbarRatio(toRatio, animated, fn)
	local f = self.fillbar
	if animated then
		local fromRatio = f.ratio
		local t = math.abs(fromRatio - toRatio)*1.5
		f.animating = true
		Utilities.Tween(t, Utilities.Timing.cubicBezier(t, .45, .6, .6, .9), function(a)
			local r = fromRatio + (toRatio-fromRatio)*a
			f.setSizeForRatio(r)
			if fn then
				fn(a, r)
			end
		end)
		f.animating = false
	else
		f.setSizeForRatio(toRatio)
	end
end
--



--function RoundedFrame:Clone() return self:clone() end
--function RoundedFrame:clone()
--	-- todo
--end

function RoundedFrame:ClearAllChildren() self:clearAllChildren() end
function RoundedFrame:clearAllChildren()
	local keep = self.keep
	for _, ch in pairs(self.gui:GetChildren()) do
		if not keep[ch] then
			ch:remove()
		end
	end
end

function RoundedFrame:remove() self:remove() end
function RoundedFrame:remove()
--	local obj = RoundedFrame.objectFromGui(self.gui)
--	if obj then
--		roundedFrames[obj] = nil
--	end
	pcall(function() self.fillbar.elem:remove() end)
	pcall(function() self.parentChangedCn:disconnect() end)
	self.parentChangedCn = nil
	pcall(function() self.gui:remove() end)
end


return RoundedFrame end