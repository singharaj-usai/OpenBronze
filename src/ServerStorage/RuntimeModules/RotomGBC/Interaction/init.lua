local Utilities
local interaction = {}

--local dPad = require(script.DPad)

local gbc, screen, arrow, cell
local connections = {}

local currentContext
local registeredContexts = {}
local defaultSelectionsByContext = {}
local lastSelectionsByContext = {}
local selection

local heldDirKeys = {}

function interaction:init(util, _gbc, _arrow, _cell)
	Utilities = util
	gbc = _gbc
	screen = _gbc.screen
	arrow = _arrow
	arrow.Parent = nil
	cell = _cell
--	dPad:Init(self)
end

function interaction:pressDir(dir)
	table.insert(heldDirKeys, 1, dir)
	gbc:dirKeyPressed()
end

function interaction:releaseDir(dir)
	for i = #heldDirKeys, 1, -1 do
		if heldDirKeys[i] == dir then
			table.remove(heldDirKeys, i)
		end
	end
end

function interaction:getDir()
	return heldDirKeys[1]
end

function interaction:setContext(context)
--	if context == 'Overworld' and Utilities.isTouchDevice() then dPad:Enable() else dPad:Disable() end
	heldDirKeys = {}
	currentContext = context
	if context then
		self:select(defaultSelectionsByContext[context] or lastSelectionsByContext[context])
	else
		self:select()
	end
end

function interaction:select(obj)
	if selection == obj then return end
	selection = obj
	if obj then
		if currentContext then
			lastSelectionsByContext[currentContext] = obj
		end
		arrow.Parent = screen
		arrow.Position = UDim2.new((obj.minX-1)*cell.X, 0, obj.minY*cell.Y, 0)
		if obj.onSelect then obj.onSelect() end
	else
		arrow.Parent = nil
	end
end

function interaction:registerSelectable(context, px, py, sx, sy, isDefault, onSelect, onChoose)
	local rc = registeredContexts[context]
	if not rc then
		rc = {}
		registeredContexts[context] = rc
	end
	local this = {minX = px, minY = py, maxX = px+sx-1, maxY = py+sy-1, onSelect = onSelect, onChoose = onChoose}
	table.insert(rc, this)
	if isDefault then
		defaultSelectionsByContext[context] = this
	end
	if not lastSelectionsByContext[context] then
		lastSelectionsByContext[context] = this
	end
	return this
end

local function getSelectionAt(pos)
	local x = math.floor((pos.X-screen.AbsolutePosition.X)/screen.AbsoluteSize.X*20)
	if x < 0 or x > 19 then return end
	local y = math.floor((pos.Y-screen.AbsolutePosition.Y)/screen.AbsoluteSize.Y*18)
	if y < 0 or y > 17 then return end
	for _, s in pairs(registeredContexts[currentContext]) do
		if x >= s.minX and x <= s.maxX and y >= s.minY and y <= s.maxY then
			return s
		end
	end
end

--local DPad
--function interaction:enableDPad()
--	if not DPad then DPad = require(script.DPad) end
--	
--end
--
--function interaction:disableDPad()
--	
--end

function interaction:connect()
	self:disconnect()
	local uis = game:GetService('UserInputService')
	local mouseb1 = Enum.UserInputType.MouseButton1
	local touch = Enum.UserInputType.Touch
	local confirm = { [Enum.KeyCode.Space]=true, [Enum.KeyCode.ButtonA]=true, [Enum.KeyCode.ButtonX]=true }
	local up    = { [Enum.KeyCode.W]=true, [Enum.KeyCode.Up   ]=true, [Enum.KeyCode.DPadUp   ]=true }; local upDir    = Vector2.new( 0, -1);
	local left  = { [Enum.KeyCode.A]=true, [Enum.KeyCode.Left ]=true, [Enum.KeyCode.DPadLeft ]=true }; local leftDir  = Vector2.new(-1,  0);
	local down  = { [Enum.KeyCode.S]=true, [Enum.KeyCode.Down ]=true, [Enum.KeyCode.DPadDown ]=true }; local downDir  = Vector2.new( 0,  1);
	local right = { [Enum.KeyCode.D]=true, [Enum.KeyCode.Right]=true, [Enum.KeyCode.DPadRight]=true }; local rightDir = Vector2.new( 1,  0);
	table.insert(connections, uis.InputBegan:connect(function(inputObject)
		if inputObject.UserInputType == mouseb1 or inputObject.UserInputType == touch then
			if not currentContext or not registeredContexts[currentContext] then return end
			local sel = getSelectionAt(inputObject.Position)
			if sel then
				self:select(sel)
				sel.onChoose()
			end
		elseif confirm[inputObject.KeyCode] then
			if selection then
				selection.onChoose()
			end
		elseif up[inputObject.KeyCode] then
			if currentContext == 'Overworld' then
				table.insert(heldDirKeys, 1, upDir)
				gbc:dirKeyPressed()
			elseif selection and selection.up then
				self:select(selection.up)
			end
		elseif left[inputObject.KeyCode] then
			if currentContext == 'Overworld' then
				table.insert(heldDirKeys, 1, leftDir)
				gbc:dirKeyPressed()
			elseif selection and selection.left then
				self:select(selection.left)
			end
		elseif down[inputObject.KeyCode] then
			if currentContext == 'Overworld' then
				table.insert(heldDirKeys, 1, downDir)
				gbc:dirKeyPressed()
			elseif selection and selection.down then
				self:select(selection.down)
			end
		elseif right[inputObject.KeyCode] then
			if currentContext == 'Overworld' then
				table.insert(heldDirKeys, 1, rightDir)
				gbc:dirKeyPressed()
			elseif selection and selection.right then
				self:select(selection.right)
			end
		end
	end))
	local mousemove = Enum.UserInputType.MouseMovement
	table.insert(connections, uis.InputChanged:connect(function(inputObject)
		if not currentContext or not registeredContexts[currentContext] then return end
		if inputObject.UserInputType == mousemove then
			local sel = getSelectionAt(inputObject.Position)
			if sel then
				self:select(sel)
			end
		end
	end))
	table.insert(connections, uis.InputEnded:connect(function(inputObject)
		if currentContext ~= 'Overworld' then return end
		if up[inputObject.KeyCode] then
			for i = #heldDirKeys, 1, -1 do
				if heldDirKeys[i] == upDir then
					table.remove(heldDirKeys, i)
				end
			end
		elseif left[inputObject.KeyCode] then
			for i = #heldDirKeys, 1, -1 do
				if heldDirKeys[i] == leftDir then
					table.remove(heldDirKeys, i)
				end
			end
		elseif down[inputObject.KeyCode] then
			for i = #heldDirKeys, 1, -1 do
				if heldDirKeys[i] == downDir then
					table.remove(heldDirKeys, i)
				end
			end
		elseif right[inputObject.KeyCode] then
			for i = #heldDirKeys, 1, -1 do
				if heldDirKeys[i] == rightDir then
					table.remove(heldDirKeys, i)
				end
			end
		end
	end))
end

function interaction:disconnect()
	for _, c in pairs(connections) do
		pcall(function() c:disconnect() end)
	end
	connections = {}
end


return interaction