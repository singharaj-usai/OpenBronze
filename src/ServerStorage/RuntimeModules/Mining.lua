return function(_p)
local Utilities = _p.Utilities
local create = Utilities.Create
local write = Utilities.Write
local rc4 = Utilities.rc4

local stepped = game:GetService('RunService').RenderStepped
local sheetId = 5228907078--322450472
local levelSheetPositionsY = {2, 3, 5, 6, 7, 9}
local levelSheetPositionX = 17
local toolHitPatterns = {{{0, 1, 0},{1, 2, 1},{0, 1, 0}},{{1, 2, 1},{2, 2, 2},{1, 2, 1}}}
local nextDig

local MiningSystem


local function color(r, g, b)
	return Color3.new(r/255, g/255, b/255)
end

local DRILL_ACTIVE_BG_COLOR = color(106, 132, 245)
local DRILL_ACTIVE_TOOL_COLOR = color(36, 67, 245)
local DRILL_INACTIVE_BG_COLOR = color(22, 32, 185)
local DRILL_INACTIVE_TOOL_COLOR = color(2, 9, 111)

local DYNAMITE_ACTIVE_BG_COLOR = color(253, 92, 83)
local DYNAMITE_ACTIVE_TOOL_COLOR = color(196, 8, 19)
local DYNAMITE_INACTIVE_BG_COLOR = color(143, 4, 11)
local DYNAMITE_INACTIVE_TOOL_COLOR = color(88, 1, 4)

-- bubble 242218744
local aspectRatio = 1.9

local mouse = _p.player:GetMouse()


--// private class BuriedObject //--
local BuriedObject = Utilities.class({
	className = 'BuriedObject',
	
--	Rotation = 0,
--	Position = Vector2.new(),
	Obtained = false,
}, function(data, gContainer)
	local ico = data.icon
	local size, pos = data.size, data.pos
	local self = {
--		ItemId = data.ItemId or 'iron',
		Icon = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://'..sheetId,
			ImageColor3 = Color3.new(.7, .7, 1),
			ImageRectSize = Vector2.new(32 * ico[1], 32 * ico[2]),
			ImageRectOffset = Vector2.new(32 * (ico[3]-1), 32 * (ico[4]-1)),
			Size = UDim2.new(ico[1]/14, 0, ico[2]/10, 0),
			Position = (ico[5]%2==0 and
				UDim2.new((pos.X-1)/14, 0, (pos.Y-1)/10, 0)
			  or
				UDim2.new((pos.X-1-size.Y/2+size.X/2)/14, 0, (pos.Y-1-size.X/2+size.Y/2)/10, 0)),
			Rotation = ico[5]*90, ZIndex = 3, Parent = gContainer
		},
		Size = size,
		Position = pos,
		OccupiedSlots = data.occ,
		IsIron = data.iron and true or false
	}
--	if data.IsEgg then
--		self.IsEgg = true
--		self.ItemId = nil
--	end
	
	return self
end)

function BuriedObject:remove()
	self.Icon:remove()
	self.OccupiedSlots = nil
end


--// private class MiningGrid //--
local MiningGrid
MiningGrid = Utilities.class({
	className = 'MiningGrid',
	
	Hits = 50,
	Tool = 1,
}, function(self)
	if MiningGrid.Recyclable then
		local grid = self.Grid
		self = MiningGrid.Recyclable
		self.Grid = grid
		MiningGrid.Recyclable = nil
		
		self.Background.Parent = Utilities.frontGui
		self.MasterContainer.Parent = Utilities.frontGui
		
		return self
	end
	self.Background = create 'Frame' {
		BorderSizePixel = 0,
		BackgroundColor3 = color(72, 110, 126), -- Color3.new(.25, .3, .4), 
		Size = UDim2.new(1.0, 0, 1.0, 36),
		Position = UDim2.new(0.0, 0, 0.0, -36),
		Parent = Utilities.frontGui,
	}
	self.MasterContainer = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Parent = Utilities.frontGui,
	}
	local container = create 'Frame' {
		BackgroundTransparency = 1.0,--.5, ZIndex = 10,
		Parent = self.MasterContainer,
	}
	self.Container = container
	self.ProgressBar = _p.RoundedFrame:new {
		BackgroundColor3 = color(65, 80, 86),
		Size = UDim2.new(.5, 0, .06, 0),
		Position = UDim2.new(.25, 0, .02, 0),
		Style = 'HorizontalBar',
		ZIndex = 2, Parent = container,
	}
	self.ProgressBar:setupFillbar(color(100, 153, 176), Utilities.isPhone() and 2 or 4, 0)
	local drillButton, drillIcon, dynamiteButton, dynamiteIcon
	function self.setTool(t)
		self.Tool = t
		if t == 1 then
			drillButton.BackgroundColor3 = DRILL_ACTIVE_BG_COLOR
			drillIcon.ImageColor3 = DRILL_ACTIVE_TOOL_COLOR
			dynamiteButton.BackgroundColor3 = DYNAMITE_INACTIVE_BG_COLOR
			dynamiteIcon.ImageColor3 = DYNAMITE_INACTIVE_TOOL_COLOR
		elseif t == 2 then
			drillButton.BackgroundColor3 = DRILL_INACTIVE_BG_COLOR
			drillIcon.ImageColor3 = DRILL_INACTIVE_TOOL_COLOR
			dynamiteButton.BackgroundColor3 = DYNAMITE_ACTIVE_BG_COLOR
			dynamiteIcon.ImageColor3 = DYNAMITE_ACTIVE_TOOL_COLOR
		end
	end
	drillButton = _p.RoundedFrame:new {
		Button = true,
		BackgroundColor3 = DRILL_ACTIVE_BG_COLOR,
		Size = UDim2.new(.3/2/aspectRatio, 0, .3, 0),
		Position = UDim2.new(0.5125+.8/aspectRatio*.7, 0, 0.175, 0),
		ZIndex = 3, Parent = container,
		MouseButton1Click = function()
			self.setTool(1)
		end,
	}
	drillIcon = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228953828',
		ImageColor3 = DRILL_ACTIVE_TOOL_COLOR,
		Size = UDim2.new(1.0, 0, 0.5, 0),
		Position = UDim2.new(0.0, 0, 0.25, 0),
		ZIndex = 4, Parent = drillButton.gui,
	}
	dynamiteButton = _p.RoundedFrame:new {
		Button = true,
		BackgroundColor3 = DYNAMITE_INACTIVE_BG_COLOR,
		Size = UDim2.new(.3/2/aspectRatio, 0, .3, 0),
		Position = UDim2.new(0.5125+.8/aspectRatio*.7, 0, 0.525, 0),
		ZIndex = 3, Parent = container,
		MouseButton1Click = function()
			self.setTool(2)
		end,
	}
	dynamiteIcon = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228937861',
		ImageColor3 = DYNAMITE_INACTIVE_TOOL_COLOR,
		Size = UDim2.new(1.0, 0, 0.5, 0),
		Position = UDim2.new(0.05, 0, 0.25, 0),
		ZIndex = 4, Parent = dynamiteButton.gui,
	}
	self.RoundedFrames = {self.ProgressBar, drillButton, dynamiteButton}
	local isTouchDevice = Utilities.isTouchDevice()
	local vpo
	if isTouchDevice then
		vpo = workspace.CurrentCamera.ViewportSize-Utilities.gui.AbsoluteSize
	end
	local gContainer; gContainer = create 'ImageButton' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://'..sheetId,
		ImageRectSize = Vector2.new(32*14, 32*10),
		ImageRectOffset = Vector2.new(32, 32),
		Size = UDim2.new(.8/aspectRatio*1.4, 0, .8, 0),
		Position = UDim2.new(0.5-.8/aspectRatio*1.4/2, 0, .1, 0),
		ZIndex = 2, Parent = container,
		MouseButton1Down = function(x, y)
			if isTouchDevice then
				y = y-vpo.Y
			else
				x, y = mouse.X, mouse.Y
			end
			local as, ap = gContainer.AbsoluteSize, gContainer.AbsolutePosition
			self:ClickedGrid(math.ceil((x-ap.X)/as.X*14), math.ceil((y-ap.Y)/as.Y*10))
		end,
	}
	self.GridContainer = gContainer
	self.BuriedItems = {}
	self.ObtainedItemCount = 0
	self.GridIcons = {}
	self.hBuf = _p.BitBuffer.Create()
	
	local function update()
		if not container.Parent then return end
		local as = Utilities.gui.AbsoluteSize
		if as.X > as.Y*aspectRatio then
			container.SizeConstraint = Enum.SizeConstraint.RelativeYY
			container.Size = UDim2.new(aspectRatio, 0, 1.0, 0)
			container.Position = UDim2.new(0.5, -container.AbsoluteSize.X/2, 0.0, 0)
		else
			container.SizeConstraint = Enum.SizeConstraint.RelativeXX
			container.Size = UDim2.new(1.0, 0, 1/aspectRatio, 0)
			container.Position = UDim2.new(0.0, 0, 0.5, -container.AbsoluteSize.Y/2)
		end
		drillButton.CornerRadius = as.Y*.03
		dynamiteButton.CornerRadius = as.Y*.03
	end
	update()
	container.Changed:connect(update)
	
	return self
end)

function MiningGrid:Draw(buriedObjects)
	local img = 'rbxassetid://'..sheetId
	local grid = self.Grid
	local gridIcons = self.GridIcons
	local gContainer = self.GridContainer
	for x = 1, 14 do
		if not gridIcons[x] then gridIcons[x] = {} end
		for y = 1, 10 do
			local icon = gridIcons[x][y]
			if not icon then
				icon = create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = img,
--					ImageTransparency = .5,--
					ImageRectSize = Vector2.new(32, 32),
					Size = UDim2.new(1/14, 1, 1/10, 1),
					Position = UDim2.new((x-1)/14, 0, (y-1)/10, 0),
					ZIndex = 4, Parent = gContainer
				}
				gridIcons[x][y] = icon
			end
			local v = grid[x][y]
			icon.ImageRectOffset = Vector2.new(32 * (levelSheetPositionX-1), 32 * (levelSheetPositionsY[v]-1))
			icon.Visible = true
		end
	end
	for _, bo in pairs(buriedObjects) do
		table.insert(self.BuriedItems, BuriedObject:new(bo, gContainer))
	end
end

function MiningGrid:ClickedGrid(x, y) -- todo
	if self.Hits <= 0 or x < 1 or y < 1 or x > 14 or y > 10 then return end
	local function updateGridAt(x, y)
		local v = self.Grid[x][y]
		if v == 0 then
			self.GridIcons[x][y].Visible = false
		else
			self.GridIcons[x][y].ImageRectOffset = Vector2.new(32 * (levelSheetPositionX-1), 32 * (levelSheetPositionsY[v]-1))
		end
	end
	self.Hits = self.Hits - self.Tool
	-- update progress bar
	Utilities.fastSpawn(function() self.ProgressBar:setFillbarRatio(math.min(1, (50-self.Hits)/50), true) end)
	-- "rumble" the screen
	Utilities.fastSpawn(function()
		local mc = self.MasterContainer
		local st = tick()
		local duration = self.Tool*.1
		local magnitude = self.Tool*.01
		local thread = {}
		self.RumbleThread = thread
		while true do
			stepped:wait()
			if thread ~= self.RumbleThread then break end
			local et = tick()-st
			if et > duration then
				mc.Position = UDim2.new()
				break
			end
			local o = (et*1.5%.25)*2
			if o >= .325 then
				o = .5-(o-.325)*4
			elseif o >= .25 then
				o = (o-.25)*4
			elseif o >= .125 then
				o = -.5+(o-.125)*4
			else
				o = o*-4
			end
			mc.Position = UDim2.new(o*magnitude*(duration-et)/duration, 0, 0.0, 0)
		end
	end)
	-- particles
	Utilities.fastSpawn(function()
		local isExplosion = self.Tool == 2
		local s = .01
		local center = UDim2.new((x-.5)/14-s/2, 0, (y-.5)/10-s/2, 0)
		local particles = {}
		for i = 1, 10 do
			particles[i] = {math.random()+.5, math.random()*math.pi*2, create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(.6, .6, .65),
				Size = UDim2.new(s/1.4, 0, s, 0),
				ZIndex = 7, Parent = self.GridContainer,
			}}
		end
		Utilities.Tween(.5, nil, function(a)
			for _, p in pairs(particles) do
				p[3].Position = center + UDim2.new(.15*math.cos(p[2])*p[1]*a/1.4, 0, .15*math.sin(p[2])*p[1]*a, 0)
				if isExplosion then
					p[3].BackgroundColor3 = color(226+25*a, 59+150*a, 59-9*a) -- 226 59 59   251 209 50
				end
			end
		end)
		for _, p in pairs(particles) do
			p[3]:remove()
		end
	end)
	-- apply hit changes
	self.hBuf:WriteBool(self.Tool==2)
	self.hBuf:WriteUnsigned(4, x)
	self.hBuf:WriteUnsigned(4, y)
	local hitPattern = toolHitPatterns[self.Tool]
	self.Grid[x][y] = math.max(0, self.Grid[x][y] - hitPattern[2][2])
	updateGridAt(x, y)
	local dugAll = false
	if self.Grid[x][y] == 0 and self:IsIronAt(x, y) then
		-- play iron sound?
	else
		for ox = 1, 3 do
			for oy = 1, 3 do
				if ox ~= 2 or oy ~= 2 then
					local px, py = x-2+ox, y-2+oy
					if px >= 1 and px <= 14 and py >= 1 and py <= 10 then
						self.Grid[px][py] = math.max(0, self.Grid[px][py] - hitPattern[oy][ox])
						updateGridAt(px, py)
					end
				end
			end
		end
		local itemsLeft = 0
--		print(#self.BuriedItems, ' buried items')
		for _, item in pairs(self.BuriedItems) do
			if not item.Obtained and not item.IsIron then
				local buried = false
				for x = 1, item.Size.X do
					for y = 1, item.Size.Y do
						if self.Grid[item.Position.X-1+x][item.Position.Y-1+y] ~= 0 and (not item.OccupiedSlots or item.OccupiedSlots[y][x]) then
							itemsLeft = itemsLeft + 1
							buried = true
							break
						end
					end
					if buried then break end
				end
				if not buried then
					item.Obtained = true
--					table.insert(self.ObtainedItems, item)
					local n = self.ObtainedItemCount + 1
					self.ObtainedItemCount = n
					Utilities.fastSpawn(function()
						local icon = item.Icon
						local startRotation = icon.Rotation
						if startRotation == 270 then
							startRotation = -90
						end
						icon.ZIndex = 6
						local spx, spy = icon.Position.X.Scale, icon.Position.Y.Scale
						local ssx, ssy = icon.Size.X.Scale, icon.Size.Y.Scale
						local epx, epy = -ssx/2-.5/14, .125+.25*(n-1)-ssy/4
						Utilities.Tween(.5, 'easeOutCubic', function(a)
							icon.Rotation = startRotation*(1-a)
							icon.ImageColor3 = Color3.new(.7+.3*a, .7+.3*a, 1)
							icon.Size = UDim2.new(ssx*(1-.5*a), 0, ssy*(1-.5*a), 0)
							icon.Position = UDim2.new(spx+(epx-spx)*a, 0, spy+(epy-spy)*a, 0)
						end)
					end)
				end
			end
		end
		if itemsLeft == 0 then
			self.Hits = 0
			dugAll = true
			_p.NPCChat:say('All the buried items have been dug up!')
			-- TODO: inform server to close dig
		end
	end
	if self.Hits <= 0 then
		local returned, msg1, msg2
		Utilities.fastSpawn(function()
			msg1, msg2 = _p.Network:get('PDS', 'finishDig', self.hBuf:ToBase64())
			returned = true
		end)
		if not dugAll then
			local rumble = true
			delay(.5, function()
				local cover = create 'Frame' {
					Name = 'Wall',
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(.25, .3, .4),
					ZIndex = 8, Parent = self.Background,
				}
				Utilities.Tween(1, nil, function(a)
					cover.Size = UDim2.new(1.0, 0, a, 0)
				end)
				rumble = false
				_p.NPCChat:say('The wall collapsed.')
			end)
			local mc = self.MasterContainer
			local st = tick()
			local magnitude = .025
			local thread = {}
			self.RumbleThread = thread
			while rumble do
				stepped:wait()
				if thread ~= self.RumbleThread then break end
				local et = tick()-st
				local o = (et*1.5%.25)*2
				if o >= .325 then
					o = .5-(o-.325)*4
				elseif o >= .25 then
					o = (o-.25)*4
				elseif o >= .125 then
					o = -.5+(o-.125)*4
				else
					o = o*-4
				end
				mc.Position = UDim2.new(o*magnitude, 0, 0.0, 0)
			end
		end
		while not returned do wait() end
		if msg1 then _p.NPCChat:say(msg1) end
		if msg2 then _p.NPCChat:say(msg2) end
		Utilities.fastSpawn(function() nextDig = _p.Network:get('PDS', 'nextDig') end)
		local c = Utilities.FadeOutWithCircle(.6, true)
		self:Recycle()
		MiningSystem:DecrementBattery(6)
		Utilities.FadeInWithCircle(.6, c)
		_p.MasterControl.WalkEnabled = true
		--_p.MasterControl:Start()
	end
end

function MiningGrid:IsIronAt(x, y)
	for _, iron in pairs(self.BuriedItems) do
		if iron.IsIron then
			if x >= iron.Position.X and
			   x < iron.Position.X+iron.Size.X and
			   y >= iron.Position.Y and
			   y < iron.Position.Y+iron.Size.Y and
			   (not iron.OccupiedSlots or
			    iron.OccupiedSlots[y-iron.Position.Y+1][x-iron.Position.X+1]) then
				return true
			end
		end
	end
	return false
end

function MiningGrid:Recycle()
	if MiningGrid.Recyclable then
		self:remove()
		return
	end
	for _, item in pairs(self.BuriedItems) do
		item:remove()
	end
	self.BuriedItems = {}
	self.ObtainedItemCount = 0
	self.hBuf:Reset()
	self.MasterContainer.Parent = nil
	self.Background.Parent = nil
	pcall(function() self.Background.Wall:remove() end)
	self.ProgressBar:setFillbarRatio(0, false)
	self.setTool(1)
	self.Hits = 50
	MiningGrid.Recyclable = self
end

function MiningGrid:remove()
	for _, item in pairs(self.BuriedItems) do
		item:remove()
	end
	self.BuriedItems = nil
	for _, t in pairs(self.GridIcons) do
		for _, icon in pairs(t) do
			icon:remove()
		end
	end
	for _, rf in pairs(self.RoundedFrames) do
		rf:remove()
	end
	self.RoundedFrames = nil
	self.GridContainer:remove()
	self.MasterContainer:remove()
	self.Background:remove()
end


-- private class MinePoint
local MinePoint = Utilities.class({
	className = 'MinePoint',
	
}, function(cf)
	local self = {
		CFrame = cf,
		Position = cf.p,
	}
	
--	local test = Instance.new('Part', workspace)
--	test.Transparency = .5
--	test.Anchored = true
--	test.CFrame = cf
	
	local part = _p.DataManager.currentChunk.map.WallSparkle:Clone()
--	part.Mesh.MeshId = 'rbxassetid://120647846'
	self.Part = part
	local size = part.Mesh.Scale--Vector3.new(3.2, 3.2, 3.2)--
	
	local sin = math.sin
	local pi = math.pi
	local angle = CFrame.Angles
	local lighting = game:GetService('Lighting')
	delay(math.random()*1.75+.1, function()
		while self.Part do
			local mcf = self.CFrame
			part.Parent = workspace
			Utilities.Tween(1, nil, function(a)
				if not self.Part then return false end
				if a == 0 or a == 1 then return end
				part.Mesh.Scale = size * sin(a*pi) * .7
				part.CFrame = mcf * angle(0, 0, 7*a)
			end)
			if not self.Part then return end
			part.Parent = lighting
			wait(1.75)
		end
	end)
	
	return self
end)

function MinePoint:Relocate()
	local wall = Utilities.weightedRandom(MiningSystem.Walls, function(wall) return 10/wall.Width end)
	local cf = wall.CFrame * CFrame.new(wall.Width*(math.random()-.5), 4*(math.random()-.5), 0)-- * CFrame.Angles(0, math.pi/2, 0)
	self.CFrame = cf
	self.Position = cf.p
	
--	self.Part.CFrame = cf--
end

function MinePoint:remove()
	for i = #MiningSystem.MinePoints, 1, -1 do
		if MiningSystem.MinePoints[i] == self then
			table.remove(MiningSystem.MinePoints, i)
		end
	end
--	print('mp count:', #MiningSystem.MinePoints)
	self.Part:remove()
	self.Part = nil
end


-- public singleton MiningSystem
MiningSystem = {
	Done = Utilities.Signal(),
	MinePoints = {},
	BatteryLevel = 100,
}

--function MiningSystem:Ping()
--	
--end

function MiningSystem:CreateMinePoint()
	if not self.Walls then
		local walls = {}
		for _, ch in pairs(_p.DataManager.currentChunk.map:GetChildren()) do
			if ch.Name == 'Wall' and ch:IsA('BasePart') then
--				if ch.Size.X-.4>.01 and ch.Size.Z-.4>.01 then print(ch.Size) error('bad wall') end
				local wall = {
					CFrame = ch.CFrame + Vector3.new(0, 1, 0),
					Width = math.max(ch.Size.X, ch.Size.Z)-4,
				}
				if ch.Size.X < ch.Size.Z then
					wall.CFrame = wall.CFrame * CFrame.Angles(0, math.pi/2, 0)
				end
				do
					local ray = Ray.new((wall.CFrame*CFrame.new(0, 0, 4)).p+Vector3.new(0, 10, 0), Vector3.new(0, -15, 0))
					local players = game:GetService('Players')
					if (Utilities.findPartOnRayWithIgnoreFunction(ray, function(obj)
							if obj.Parent:IsA('Accoutrement') or players:GetPlayerFromCharacter(obj.Parent) or obj.Name == 'Plant' then return true end
							return false
						end)) then
						wall.CFrame = wall.CFrame * CFrame.Angles(0, math.pi, 0)
					end
				end
				wall.CFrame = wall.CFrame * CFrame.new(0, 0, .2)
				table.insert(walls, wall)
			end
		end
		self.Walls = walls
	end
	local wall = Utilities.weightedRandom(self.Walls, function(wall) return 10/wall.Width end)
	table.insert(self.MinePoints, MinePoint:new(wall.CFrame * CFrame.new(wall.Width*(math.random()-.5), 4*(math.random()-.5), 0)))-- * CFrame.Angles(0, math.pi/2, 0)))
end

function MiningSystem:ToggleSubmarine(on)
	self.SubmarineOn = on
	local mw, bubbles = _p.Network:get('ToggleSubmarine', on)
	if on then
		_p.RunningShoes:disable()
		_p.WalkEvents:bindToStep('UMV', function() self:DecrementBattery(1) end, 9)
	else
		_p.RunningShoes:enable()
		_p.WalkEvents:unbindFromStep('UMV')
	end
	if mw then
		local mwC1 = mw.C1
		local motorRotation = 0
		local currentSpeed = 0
		self.WalkConnection = Utilities.getHumanoid().Running:connect(function(speed)
			currentSpeed = speed
			bubbles.Enabled = speed > .05
		end)
		spawn(function()
			local lastTick = tick()
			while self.WalkConnection do
				wait()--stepped:wait()
				local now = tick()
				local dt = now-lastTick
				lastTick = now
				if currentSpeed > .05 then
					motorRotation = motorRotation + currentSpeed
					mw.C1 = mwC1 * CFrame.Angles(0, motorRotation, 0)
				end
			end
		end)
	elseif self.WalkConnection then
		self.WalkConnection:disconnect()
		self.WalkConnection = nil
	end
end

function MiningSystem:Resurface()
	pcall(function() MiningGrid.Recyclable:remove() end)
	MiningGrid.Recyclable = nil
	local c = Utilities.FadeOutWithCircle(.9, true)
	self:ToggleSubmarine(false)
	for _, mp in pairs(self.MinePoints) do
		mp:remove()
	end
	self.MouseClickConnection:disconnect()
	self.BatteryIcon:remove()
	self.QuitButton:remove()
	self.Done:fire(c)
end

function MiningSystem:DecrementBattery(units)
	if self.BatteryLevel <= 0 then return end
	self.BatteryLevel = math.max(0, self.BatteryLevel - units)
	self.BatteryFill.Size = UDim2.new(1.0, 0, -self.BatteryLevel/100, 0)
	if self.BatteryLevel <= 0 then
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.NPCChat:say('The UMV battery has been depleted.', 'Returning to surface...')
		self:Resurface()
	end
end

do
	local sig, mainMenu, batteriesFrame
	function MiningSystem:Menu(nBatteries)
		if not mainMenu then
			sig = Utilities.Signal()
			mainMenu = _p.RoundedFrame:new {
				Name = 'ShopMenu',
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0.3, 0, 0.4, 0),
				Position = UDim2.new(0.55, 0, 0.05, 0),
				Parent = Utilities.frontGui,
			}
			write 'Dive' {
				Frame = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.1, 0),
					ZIndex = 2,
					Parent = mainMenu.gui,
					MouseButton1Click = function()
						sig:fire('dive')
					end,
				},
				Scaled = true,
				Color = Color3.new(0.4, 0.4, 0.4),
				TextXAlignment = Enum.TextXAlignment.Center,
			}
			write 'Batteries' {
				Frame = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.4, 0),
					ZIndex = 2,
					Parent = mainMenu.gui,
					MouseButton1Click = function()
						sig:fire('buy')
					end,
				},
				Scaled = true,
				Color = Color3.new(0.4, 0.4, 0.4),
				TextXAlignment = Enum.TextXAlignment.Center,
			}
			write 'Cancel' {
				Frame = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.7, 0),
					ZIndex = 2,
					Parent = mainMenu.gui,
					MouseButton1Click = function()
						sig:fire()
					end,
				},
				Scaled = true,
				Color = Color3.new(0.4, 0.4, 0.4),
				TextXAlignment = Enum.TextXAlignment.Center,
			}
			batteriesFrame = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5267673546',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.3*1.2, 0, 0.3, 0),
				Position = UDim2.new(0.0, 0, 0.675, 0),
				Parent = Utilities.gui,
				
				create 'Frame' {
					Name = 'Text',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.3, 0),
					Position = UDim2.new(0.7, 0, 0.5, 0),
				}
			}
		end
		mainMenu.CornerRadius = Utilities.gui.AbsoluteSize.Y*.025
		write('x'..nBatteries) {
			Frame = batteriesFrame.Text,
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
		mainMenu.Visible = true
		batteriesFrame.Visible = true
		local choice = sig:wait()
		mainMenu.Visible = false
		batteriesFrame.Text:ClearAllChildren()
		batteriesFrame.Visible = false
		return choice
	end
end

do
	local sig, menu, buttons, cancel
	function MiningSystem:BuyBatteries()
		-- 1 batteries for 5  R$  5267673546
		-- 3 batteries for 11 R$  5267677034
		-- 6 batteries for 18 R$  5267679379
		if not menu then
			sig = Utilities.Signal()
			menu = _p.RoundedFrame:new {
				BackgroundColor3 = BrickColor.new('Bright yellow').Color,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.8, 0, 0.3, 0),
				Parent = Utilities.gui,
			}
			local robux = {5, 11, 18}
			local image = {5267673546, 5267677034, 5267679379}
			local products = {_p.productId.UMV1, _p.productId.UMV3, _p.productId.UMV6}
			buttons = {0, 0, 0}
			for i = 1, 3 do
				local button = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = BrickColor.new('Cyan').Color,
					Size = UDim2.new(.25, 0, .25*.8/.3, 0),
					Position = UDim2.new(.25/4*i+.25*(i-1), 0, .05, 0),
					ZIndex = 2, Parent = menu.gui,
					MouseButton1Click = function()
						_p.MarketClient:promptProductPurchase(products[i])
					end,
					
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://'..image[i],
						Size = UDim2.new(1.2, 0, 1.0, 0),
						Position = UDim2.new(-0.1, 0, 0.0, 0),
						ZIndex = 3,
					}
				}
				write(robux[i]..' R$') {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.3, 0),
						Position = UDim2.new(0.5, 0, 1.05, 0),
						ZIndex = 4, Parent = button.gui,
					}, Scaled = true,
					Color = BrickColor.new('Bright green').Color,
				}
				buttons[i] = button
			end
			cancel = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = menu.BackgroundColor3,
				Size = UDim2.new(0.25, 0, 0.175, 0),
				Position = UDim2.new(0.7, 0, -0.225, 0),
				Parent = menu.gui,
				MouseButton1Click = function()
					sig:fire()
				end,
			}
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.8, 0),
					Position = UDim2.new(0.5, 0, 0.1, 0),
					ZIndex = 2, Parent = cancel.gui,
				}, Scaled = true,
			}
		end
		menu.CornerRadius = Utilities.gui.AbsoluteSize.Y*.03
		cancel.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015
		for _, b in pairs(buttons) do
			b.CornerRadius = Utilities.gui.AbsoluteSize.Y*.028
		end
		menu.Position = UDim2.new(0.5, -menu.gui.AbsoluteSize.X/2, 0.35, 0)
		menu.Visible = true
		sig:wait()
		menu.Visible = false
	end
end

local function startMining()
	while not nextDig do wait() end
	local currentDig = nextDig
	nextDig = nil
	local grid = MiningGrid:new{Grid = currentDig.grid}
	grid:Draw(currentDig.objects)
end

function MiningSystem:Enable(firstDig) -- must confirm before teleporting that a battery is owned
	nextDig = firstDig
	spawn(function() _p.Menu:disable() end)
	if not self.SubmarineOn then
		for i = 1, 5 do
			self:CreateMinePoint()
		end
		self:ToggleSubmarine(true)
	end
	local mouse = _p.player:GetMouse()
	self.MouseClickConnection = mouse.Button1Down:connect(function()
		if self.BatteryLevel <= 0 or not _p.MasterControl.WalkEnabled then return end
		local cp = workspace.CurrentCamera.CoordinateFrame.p
		local p = select(2, Utilities.findPartOnRayWithIgnoreFunction(Ray.new(cp, (mouse.Hit.p-cp).unit*20), function(obj)
			return obj:IsDescendantOf(_p.player.Character) or obj.Name == 'Plant'
		end))
		for _, minePoint in pairs(self.MinePoints) do
			if (p-minePoint.Position).magnitude < 2 and (_p.player.Character.HumanoidRootPart.Position-p).magnitude < 9 then
				_p.MasterControl.WalkEnabled = false
				_p.MasterControl:Stop()
				local c = Utilities.FadeOutWithCircle(.6, true)
				minePoint:Relocate()--:remove()
				startMining()
				Utilities.FadeInWithCircle(.6, c)
				return
			end
		end
	end)
	self.BatteryIcon = create 'ImageLabel' { -- 57x152
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://323110141',
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(.3*57/152, 0, .3, 0),
		Position = UDim2.new(.0125, 0, .35, 0),
		ZIndex = 2, Parent = Utilities.gui,
	}
	local batteryContainer = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(41/57, 0, 132/152, 0), -- 41x132
		Position = UDim2.new(8/57, 0, 12/152), -- 8, 12
		Parent = self.BatteryIcon,
	}
	self.BatteryFill = create 'Frame' {
		BorderSizePixel = 0,
		BackgroundColor3 = color(58, 247, 127),-- 156, 248, 190),
		Size = UDim2.new(1.0, 0, -1.0, 0),
		Position = UDim2.new(0.0, 0, 1.0, 0),
		Parent = batteryContainer,
	}
	self.BatteryLevel = 100
	self.QuitButton = _p.RoundedFrame:new {
		Button = true,
		BackgroundColor3 = BrickColor.new('Smoky grey').Color,
		CornerRadius = Utilities.gui.AbsoluteSize.Y*.02,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(.18, 0, .05, 0),
		Position = UDim2.new(.005, 0, .675, 0),
		Parent = Utilities.gui,
		MouseButton1Click = function()
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			if _p.NPCChat:say('[y/n]Would you like to resurface early? Your UVM battery will be lost.') then
				self:Resurface()
			else
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()
			end
		end,
	}
	write 'Quit' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.7, 0),
			Position = UDim2.new(0.5, 0, 0.15, 0),
			ZIndex = 2, Parent = self.QuitButton.gui,
		}, Scaled = true
	}
end


return MiningSystem
end