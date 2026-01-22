return function(_p)
local player = game:GetService('Players').LocalPlayer
local mouse = player:GetMouse()
local stepped = game:GetService('RunService').RenderStepped
local heartbeat = game:GetService('RunService').Heartbeat

local Utilities = _p.Utilities
local fporwif = Utilities.findPartOnRayWithIgnoreFunction
local create = Utilities.Create
local MoveModel = Utilities.MoveModel
--local MasterControl = _p.MasterControl
local npc = _p.NPC
	
local puzzle = {
	PuzzleCompleted = Utilities.Signal()
}

local enabled = false

local currentLevel = 0
local puzzleModel
local planeY, xGridOffset, zGridOffset

local chunk, light

local filling = false
local waterModel

local disable, positionWatchThread

local function reset()
	if waterModel then
		waterModel:remove()
		waterModel = nil
	end
--	if puzzleModel then
--		puzzleModel.Receiver.Green.BrickColor = BrickColor.new('Fossil')
--		puzzleModel.Receiver.Green.Material = Enum.Material.SmoothPlastic
--		puzzleModel.Receiver.Red.BrickColor = BrickColor.new('Bright red')
--		puzzleModel.Receiver.Red.Material = Enum.Material.Neon
--	end
end

local cameraThread
local function moveCam(goalCF, goalFOV, duration)
	chunk:unbindIndoorCam()
	local cam = workspace.CurrentCamera
	local scf = cam.CoordinateFrame
	local sfov = cam.FieldOfView
	local thisThread = {}
	cameraThread = thisThread
	local lerp
	if goalCF then
		lerp = select(2, Utilities.lerpCFrame(scf, goalCF))
	end
	if not duration then duration = math.abs(goalFOV-sfov)/40 end
	Utilities.Tween(duration, 'easeOutCubic', function(a)
		if cameraThread ~= thisThread then return false end
		cam.FieldOfView = sfov + (goalFOV-sfov)*a
		if lerp then
			cam.CoordinateFrame = lerp(a)
		else
			cam.CoordinateFrame = select(2, Utilities.lerpCFrame(scf, chunk.getIndoorCamCFrame()))(a)
		end
	end)
	if cameraThread == thisThread and not goalCF then
		chunk:bindIndoorCam()
	end
end


-- level completion utilities
local function win(pm, auto)
	pm.Receiver.Green.BrickColor = BrickColor.new('Bright green')
	pm.Receiver.Green.Material = Enum.Material.Neon
	pm.Receiver.Red.BrickColor = BrickColor.new('Fossil')
	pm.Receiver.Red.Material = Enum.Material.SmoothPlastic
	local water = pm.PuzzleWater
	local wcf = water.CFrame
	local floatingObjects = {}
	for _, obj in pairs(pm.FloatingObjects:GetChildren()) do
		local wl = obj:FindFirstChild('WaterLevel')
		if wl then
			table.insert(floatingObjects, {main = wl, cf = wl.CFrame, startHeight = wl.Position.Y+wl.Size.Y/2})
		end
	end
	if auto then
		water.CFrame = wcf + Vector3.new(0, 11, 0)
		local waterTop = water.Position.Y + water.Size.Y/2
		for _, fobj in pairs(floatingObjects) do
			MoveModel(fobj.main, fobj.cf + Vector3.new(0, waterTop-fobj.startHeight, 0), true)
		end
		pm.Blockade:remove()
	else
		positionWatchThread = nil
		disable()
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
		local f = water.Position + Vector3.new(-water.Position.X+pm.Base.Position.X, water.Size.Y/2+6, 0)
		local p = f + Vector3.new(0, 3, -2).unit*25
		moveCam(CFrame.new(p, f), 70, 1)
		local particles = {}
		for _, part in pairs(pm.WaterParticles:GetChildren()) do
			local p = part:FindFirstChild('ParticleEmitter')
			if p then
				p.Enabled = true
				table.insert(particles, p)
			end
		end
		Utilities.Tween(5, 'easeInOutCubic', function(a)
			water.CFrame = wcf --[[* CFrame.Angles(0, 0, -0.01*(1-a))]] + Vector3.new(0, 11*a, 0)
			local waterTop = water.Position.Y + water.Size.Y/2
			for _, fobj in pairs(floatingObjects) do
				if waterTop > fobj.startHeight then
					MoveModel(fobj.main, fobj.cf + Vector3.new(0, waterTop-fobj.startHeight, 0), true)
				end
			end
			for _, p in pairs(particles) do
				p.Acceleration = Vector3.new(0, -5+15*a, 0)
				if a > .85 then
					p.Enabled = false
				end
			end
		end)
--		for _, p in pairs(particles) do
--			p.Enabled = false
--		end
		for _, fobj in pairs(pm.FloatingObjects:GetChildren()) do
			for _, obj in pairs(fobj:GetChildren()) do
				if obj:IsA('Model') and obj:FindFirstChild('Humanoid') then
					npc:new(obj):Animate()
				end
			end
		end
		pm.Blockade:remove()
		moveCam(nil, 70, 1)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()
		puzzle.PuzzleCompleted:fire(currentLevel)
	end
end

local function fill()
	if not enabled or filling then return end
	local pm = puzzleModel
	filling = true
	reset()
	waterModel = Instance.new('Model', pm)
	local waterColor = BrickColor.new('Steel blue')
	local speed = 3
	local water = create 'Part' {
--		FormFactor = Enum.FormFactor.Custom,
		BrickColor = waterColor,
		Anchored = true,
		CanCollide = false,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		Parent = waterModel,
	}
	do
		local fmain = pm.WaterSupply.Faucet.Main
		local fcf = fmain.CFrame
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			MoveModel(fmain, fcf * CFrame.Angles(0, a*math.pi*2, 0))
		end)
	end
	local sourceCF = pm.WaterSupply.Source.CFrame
	Utilities.Tween(4/3/speed, nil, function(a)
		local s = 4*a
		water.Size = Vector3.new(1, 1, s)
		water.CFrame = sourceCF * CFrame.new(0, 0, -s/2+1.75)
	end)
	local function rayIgnoreFn(part)
		return (part.Name == 'Main' or not part.Parent.Parent or part.Parent.Parent ~= pm.Pieces) and part.Parent ~= pm.Receiver
	end
	local lastWaterBrick = water
	local cf = sourceCF * CFrame.new(0, 0, -2.25)
	local ht = planeY+.25
	while true do
		-- identify next block
		local block = fporwif(Ray.new(cf*Vector3.new(0, 1.5, -1.5), Vector3.new(0, -3, 0)), rayIgnoreFn)
		if not block then
			-- no block at all
			local corner = pm.WaterSupply.WaterCorner:Clone()
			corner.BrickColor = waterColor
			corner.Parent = waterModel
			local ccf = cf * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, math.pi/2)
			Utilities.Tween(1/3/speed, nil, function(a)
				corner.CFrame = ccf * CFrame.Angles(0, -math.pi/2*(1-a), 0) * CFrame.new(0.5, 0, -0.5)
			end)
			local wcf = cf * CFrame.new(0, -0.5, -0.5) * CFrame.Angles(-math.pi/2, 0, 0)
			local water = lastWaterBrick:Clone()
			water.Parent = waterModel
			Utilities.Tween(2/3/speed, nil, function(a)
				water.Size = Vector3.new(1, 1, 2*a)
				water.CFrame = wcf * CFrame.new(0, 0, -a)
			end)
			break
		end
		if block.Parent == pm.Receiver then
			-- puzzle complete
			local wcf, ws = lastWaterBrick.CFrame, lastWaterBrick.Size
			Utilities.Tween(1/speed, nil, function(a)
				lastWaterBrick.Size = ws + Vector3.new(0, 0, a*3)
				lastWaterBrick.CFrame = wcf * CFrame.new(0, 0, -a*1.5)
			end)
			cf = cf * CFrame.new(0, 0, -3)
			win(pm, false)
			break
		end
		local _, p = fporwif(Ray.new(cf*Vector3.new(0, 1.5, -0.5), Vector3.new(0, -3, 0)), rayIgnoreFn)
		if p.y < ht then
			local _, p = fporwif(Ray.new(cf*Vector3.new(0, 1.5, -2.5), Vector3.new(0, -3, 0)), rayIgnoreFn)
			if p.y < ht then
				-- straight
				local wcf, ws = lastWaterBrick.CFrame, lastWaterBrick.Size
				Utilities.Tween(1/speed, nil, function(a)
					lastWaterBrick.Size = ws + Vector3.new(0, 0, a*3)
					lastWaterBrick.CFrame = wcf * CFrame.new(0, 0, -a*1.5)
				end)
				cf = cf * CFrame.new(0, 0, -3)
			else
				-- turn
				local _, p = fporwif(Ray.new(cf*Vector3.new(-1, 1.5, -1.5), Vector3.new(0, -3, 0)), rayIgnoreFn)
				if p.y < ht then
					-- left turn
					local wcf, ws = lastWaterBrick.CFrame, lastWaterBrick.Size
					Utilities.Tween(1/3/speed, nil, function(a)
						lastWaterBrick.Size = ws + Vector3.new(0, 0, a)
						lastWaterBrick.CFrame = wcf * CFrame.new(0, 0, -a*.5)
					end)
					local corner = lastWaterBrick:Clone()
					corner.Parent = waterModel
					corner.Size = Vector3.new(2, 1, 1)
					local ccf = cf * CFrame.new(-0.5, 0, -1)
					Utilities.Tween(1/3/speed, nil, function(a)
						corner.CFrame = ccf * CFrame.Angles(0, math.pi/2*a, 0) * CFrame.new(0.5, 0, 0.5)
					end)
					ccf = cf * CFrame.new(0, 0, -1.5) * CFrame.Angles(0, math.pi/2, 0)
					Utilities.Tween(1/3/speed, nil, function(a)
						corner.Size = Vector3.new(1, 1, 1+a)
						corner.CFrame = ccf * CFrame.new(0, 0, -a*.5)
					end)
					cf = ccf * CFrame.new(0, 0, -1.5)
					lastWaterBrick = corner
				else
					local _, p = fporwif(Ray.new(cf*Vector3.new(1, 1.5, -1.5), Vector3.new(0, -3, 0)), rayIgnoreFn)
					if p.y < ht then
						-- right turn
						local wcf, ws = lastWaterBrick.CFrame, lastWaterBrick.Size
						Utilities.Tween(1/3/speed, nil, function(a)
							lastWaterBrick.Size = ws + Vector3.new(0, 0, a)
							lastWaterBrick.CFrame = wcf * CFrame.new(0, 0, -a*.5)
						end)
						local corner = lastWaterBrick:Clone()
						corner.Parent = waterModel
						corner.Size = Vector3.new(2, 1, 1)
						local ccf = cf * CFrame.new(0.5, 0, -1)
						Utilities.Tween(1/3/speed, nil, function(a)
							corner.CFrame = ccf * CFrame.Angles(0, -math.pi/2*a, 0) * CFrame.new(-0.5, 0, 0.5)
						end)
						ccf = cf * CFrame.new(0, 0, -1.5) * CFrame.Angles(0, -math.pi/2, 0)
						Utilities.Tween(1/3/speed, nil, function(a)
							corner.Size = Vector3.new(1, 1, 1+a)
							corner.CFrame = ccf * CFrame.new(0, 0, -a*.5)
						end)
						cf = ccf * CFrame.new(0, 0, -1.5)
						lastWaterBrick = corner
					else
						print 'unknown block'
						break
					end
				end
			end
		else
			-- receiving block is not facing such that a tunnel connects
--			print 'bad dead end'
			-- for now we just stop flowing
			break
		end
	end
	filling = false
end


-- dragging logic
local function clampPos(pm, p)
	local minX, maxX = pm.Base.Position.X-pm.Base.Size.X/2+1.5, pm.Base.Position.X+pm.Base.Size.X/2-1.5 -- -3.5, 11.5
	local minZ, maxZ = pm.Base.Position.Z-pm.Base.Size.Z/2+1.5, pm.Base.Position.Z+pm.Base.Size.Z/2-1.5 -- -8.5, 6.5
	return Vector3.new(math.max(minX, math.min(maxX, p.X)), p.Y, math.max(minZ, math.min(maxZ, p.Z)))
end

local selectedPiece
local function deselect()
	if not selectedPiece then return end
	local piece, rcfs = unpack(selectedPiece)
	selectedPiece = nil
	local p = piece.Main.Position
	local x = math.floor((p.X-xGridOffset)/3+.5)*3+xGridOffset
	local z = math.floor((p.Z-zGridOffset)/3+.5)*3+zGridOffset
	local cf = CFrame.new(Vector3.new(x, planeY, z))
	piece.Main.CFrame = cf
	for p, rcf in pairs(rcfs) do
		p.CFrame = cf:toWorldSpace(rcf)
	end
--	piece.Union.CFrame = cf:toWorldSpace(rcf)
--	piece.Union.CFrame = piece.Union.CFrame - piece.Union.Position + piece.Main.Position -- fix ??
end

local mouseIsDown = false
local mouseDownCn

local pieceCache = {}
local function mouseDown()
	if filling then return end
	local pm = puzzleModel
	deselect()
	if mouseIsDown then
		mouseIsDown = false
		return
	end
	local piece
	pcall(function()
		local lp = light.Parent
		light.Parent = nil
		local t = mouse.Target
		light.Parent = lp or workspace
		if t.Parent == pm.WaterSupply.Faucet then
			fill()
			return
		end
		if t.Parent.Name == 'Draggable' and t.Parent.Parent == pm.Pieces and t.Parent:FindFirstChild('Main') and t.Parent:FindFirstChild('Union') then
			piece = t.Parent
		end
	end)
	if not piece then return end
	reset()
	mouseIsDown = true
	selectedPiece = pieceCache[piece]
	local rcf
	if selectedPiece then
		rcf = selectedPiece[2][piece.Union]
		piece.Union.CFrame = piece.Main.CFrame:toWorldSpace(rcf) + Vector3.new(0, 0.5, 0)
	else
		local main = piece.Main
		local mcf = main.CFrame
		local rcfs = {}
		for _, p in pairs(piece:GetChildren()) do
			if p:IsA('BasePart') and p ~= main then
				rcfs[p] = mcf:toObjectSpace(p.CFrame)
			end
		end
		rcf = rcfs[piece.Union]
		piece.Union.CFrame = piece.Union.CFrame + Vector3.new(0, 0.5, 0)
		selectedPiece = {piece, rcfs}
		pieceCache[piece] = selectedPiece
	end
	local function mouseProjectedToPlane()
		local p = mouse.Hit.p
		local c = workspace.CurrentCamera.CoordinateFrame.p
		local v = (p-c).unit
		local m = (planeY-c.Y)/v.Y
		return c + v*m
	end
	local offset = piece.Main.Position-mouseProjectedToPlane()
	local function rayIgnoreFn(part)
		return part.Name ~= 'Main' or part.Parent == piece
	end
	local function rcast(from, dir, add)
		local hit, pos = fporwif(Ray.new(from, dir), rayIgnoreFn)
		if hit then
			return pos - dir.unit*1.5
		end
		return add and from + dir or from
	end
	local boxes = {}
	for _, pc in pairs(pm.Pieces:GetChildren()) do
		if pc ~= piece and pc:FindFirstChild('Main') then
			local p, s = pc.Main.Position, pc.Main.Size
			table.insert(boxes, {p.x, p.z})
		end
	end
	local function u(n)
		return n < 0 and -1 or (n > 0 and 1 or 0)
	end
	local sqrt = math.sqrt
	local function bcast(from)
		local closestBox, dist
		for _, box in pairs(boxes) do
			local dx, dz = math.abs(box[1]-from.X), math.abs(box[2]-from.Z)
			if dx < 2.99 and dz < 2.99 then
				local d = sqrt(dx*dx+dz*dz)
				if not closestBox or d<dist then
					closestBox = box
					dist = d
				end
			end
		end
		if closestBox then
			if math.abs(from.X-closestBox[1]) > math.abs(from.Z-closestBox[2]) then
				return bcast(Vector3.new(closestBox[1] + u(from.X-closestBox[1])*3, from.Y, from.Z))
			else
				return bcast(Vector3.new(from.X, from.Y, closestBox[2] + u(from.Z-closestBox[2])*3))
			end
		end
		return from
	end
	stepped:wait()
	while mouseIsDown do
		local lastPos = piece.Main.Position
		local goalPos = clampPos(pm, mouseProjectedToPlane()+offset)
		if goalPos ~= lastPos then
			local dir = (goalPos-lastPos).unit
			local hit, pos, normal = fporwif(Ray.new(lastPos, dir*((goalPos-lastPos).magnitude+1)), rayIgnoreFn)
			local endPos = hit and bcast(pos + normal) or bcast(goalPos)
			local cf = CFrame.new(lastPos + (endPos-lastPos)/2)
			piece.Main.CFrame = cf
			piece.Union.CFrame = cf:toWorldSpace(rcf) + Vector3.new(0, 0.5, 0)
		end
		stepped:wait()
	end
	deselect()
end

local mouseUpCn
local function mouseUp()
	mouseIsDown = false
end




local function enable(model)
	if enabled then return end
	puzzleModel = model
	planeY = model.Base.Position.Y+1.5
	xGridOffset = model.Base.Position.X%3 + (model.Base.Size.X%2 == 0 and 1.5 or 0)
	zGridOffset = model.Base.Position.Z%3 + (model.Base.Size.Z%2 == 0 and 1.5 or 0)
	enabled = true
	mouseDownCn = mouse.Button1Down:connect(mouseDown)
	mouseUpCn = mouse.Button1Up:connect(mouseUp)
end

disable = function()
	if not enabled then return end
	puzzleModel = nil
	enabled = false
	mouseIsDown = false
	if mouseDownCn then
		mouseDownCn:disconnect()
		mouseDownCn = nil
	end
	if mouseUpCn then
		mouseUpCn:disconnect()
		mouseUpCn = nil
	end
end

-- public api
function puzzle:Init(roomLight)
	chunk = _p.DataManager.currentChunk
	light = roomLight
end

function puzzle:AutoComplete(pm)
	win(pm, true)
end

function puzzle:ActivatePuzzle(n, pm)
	disable()
	currentLevel = n
	puzzleModel = pm
	local thisThread = {}
	positionWatchThread = thisThread
	spawn(function()
		local pos = pm.ControlStand.Pad.Position
		local player = game:GetService('Players').LocalPlayer
		local enabled = false
		local camCF; do
			local pos = pm.Base.Position
			local top = Vector3.new(0, 1, 40).unit
			local right = Vector3.new(-1, 0, 0)
			local back = right:Cross(top)
			camCF = CFrame.new(pos.X, pos.Y+57.6, pos.Z-0.5,
				right.x, top.x, back.x,
				right.y, top.y, back.y,
				right.z, top.z, back.z)
		end

		
		while positionWatchThread == thisThread do
			local pp; pcall(function() pp = player.Character.HumanoidRootPart.Position end)
			if pp then
				if pp.x > pos.x-2 and pp.x < pos.x+2 and pp.z > pos.z-2 and pp.z < pos.z+2 then
					if not enabled then
						spawn(function() moveCam(camCF, 30) end)
						enable(pm)
						enabled = true
					end
				else
					if enabled then
						disable()
						spawn(function() moveCam(nil, 70) end)
						enabled = false
					end
				end
			end
			heartbeat:wait()
		end
	end)
end


return puzzle
end