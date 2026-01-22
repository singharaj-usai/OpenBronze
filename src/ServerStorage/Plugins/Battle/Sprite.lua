return function(_p)
local storage = game:GetService('ReplicatedStorage')
local class, null; do
	local util = require(script.Parent.BattleUtilities)
	class = util.class
	null = util.null
end

--local _p = require(script.Parent.Parent)--storage.Plugins)
local Utilities = _p.Utilities
local Tween, MoveModel = Utilities.Tween, Utilities.MoveModel
local create = Utilities.Create

local Sprites = {}

local runService = game:GetService('RunService')
local stepped = runService.RenderStepped
local bound = false
local function bind()
	if bound then return end
	bound = true
	local v3 = Vector3.new
	local xzPlane = v3(1,0,1)
	local cframe = CFrame.new
	runService:BindToRenderStep('SpritePartCFrameRenderStep', Enum.RenderPriority.Last.Value, function()
		if #Sprites == 0 then
			runService:UnbindFromRenderStep('SpritePartCFrameRenderStep')
			bound = false
			return
		end
		local cam = workspace.CurrentCamera
		local lv = (cam.Focus.p - cam.CFrame.p).unit * xzPlane
		for _, s in pairs(Sprites) do
			local part = s.part
			if part then
				local p = s.cf.p + v3(0, part.Size.y/2, 0) + s.offset
				part.CFrame = cframe(p, p - lv)
			end
		end
	end)
end

local function hideAll(...)
	for _, model in pairs({...}) do
		for _, ch in pairs(model:GetChildren()) do
			if ch:IsA('BasePart') then
				ch.Transparency = 1.0
			end
		end
	end
end


local Sprite = class({
	className = 'BattleSprite',
	
	forme = '',
	offset = Vector3.new(),
	
}, function(self, pokemon, battle, siden)
	self.pokemon = pokemon
	self.battle = battle
	self.siden = siden
	
	self.isBackSprite = siden == 1
	
	self:updateSpriteData()
	self.duringMove = false
	
	table.insert(Sprites, self)
	bind()
	
	return self
end)

function Sprite:updateSpriteData()
	local pokemon = self.pokemon
--	print(pokemon.spriteSpecies, pokemon.species, pokemon.name)
	local spriteId = pokemon.spriteSpecies or pokemon.species or pokemon.name
	if self.forme and self.forme ~= '' then
		spriteId = spriteId .. '-' .. self.forme
	end
	self.spriteData = _p.DataManager:getSprite((pokemon.shiny and '_SHINY' or '')..(self.isBackSprite and '_BACK' or '_FRONT'), spriteId, pokemon.gender=='F')
end


local mobile = Utilities.isTouchDevice()
function Sprite:playCry(pitch, cry, volume)
	--if mobile then return end -- mobile reeeeeally doesn't like Sound.TimePosition
	-- IF we enabled this for MOBILE one day, scroll down to animMegaEvolve and see the note about mobile
	pitch = pitch or 1.0
	cry = cry or self.spriteData.cry
	if cry then
		Utilities.fastSpawn(function()
			local sound = create 'Sound' {
				SoundId = 'rbxassetid://'..cry.id,
				Volume = volume or .4,
				TimePosition = cry.startTime-.05,--make this back into a comment if it doesnt work
				Pitch = pitch,
				Parent = Utilities.gui,
			}
			sound:Play()
			sound.TimePosition = cry.startTime-.05
			local endTime = cry.startTime + cry.duration + .05
			while sound.TimePosition < endTime do stepped:wait() end
			sound:Stop()
			sound:remove()
		end)
	end
end

function Sprite:animMegaEvolve(megaEvolutionSpriteData, color1, color2, color3)
	if self.battle.fastForward then
		self.spriteData = megaEvolutionSpriteData
		self.offset = Vector3.new()
		self:renderNewSpriteData()
		return
	end
--	Utilities.print_r(megaEvolutionSpriteData.cry)
	local disabledGuis = {}
	for _, side in pairs(self.battle.sides) do
		for _, active in pairs(side.active) do
			pcall(function()
				if active.statbar.main.Visible then
					active.statbar.main.Visible = false
					table.insert(disabledGuis, active.statbar.main)
				end
			end)
		end
	end
	
--	local color1, color2, color3 = _p.colorBox1.Text, _p.colorBox2.Text, _p.colorBox3.Text--_p.BrickColor.new('Cyan'), BrickColor.new('Bright orange')
--	color1 = BrickColor.new(color1)
--	color2 = BrickColor.new(color2)
--	if color3 == '' then
--		color3 = nil
--	else
--		color3 = BrickColor.new(color3)
--	end
	color1, color2 = BrickColor.new(color1), BrickColor.new(color2)
	if color3 == 0 then
		color3 = color2
	else
		color3 = BrickColor.new(color3)
	end
	
	_p.DataManager:preloadSprites(megaEvolutionSpriteData)
	local inAirBefore = self.spriteData.inAir or 0
	local inAirAfter  = megaEvolutionSpriteData.inAir or 0
	local cam = workspace.CurrentCamera
	local camBefore = cam.CFrame
	local part = self.part
	local lighting = game:GetService('Lighting')
	local ambientBefore = lighting.OutdoorAmbient
	

	spawn(function() _p.MusicManager:fadeToVolume(true, .65, 1) end)
	Utilities.sound(486262895, nil, nil, 10)

	
	spawn(function() -- particles 477984910
		local twopi = math.pi*2
		local rand = math.random
		local cos, sin = math.cos, math.sin
		local freq = 3.5
		local absorbDuration = 2
--		spawn(function()
--			Tween(2, 'easeInCubic', function(a)
----				freq = 2 + 4*a
--				absorbDuration = 2-.5*a
--			end)
--		end)
		local st = tick()
		while tick()-st < 4.25 do
			local color = (color3 or color2).Color
			spawn(function()
				local p = create 'Part' {
					Transparency = 1.0,
					Anchored = true,
					CanCollide = false,
					Size = Vector3.new(.2, .2, .2),
					Parent = workspace,
				}
				local bbg = create 'BillboardGui' {
					Adornee = p,
					Size = UDim2.new(.5, 0, .5, 0),
					Parent = p,
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
							Image = 'rbxassetid://12097496834',
						ImageColor3 = color,
						Size = UDim2.new(1.0, 0, 1.0, 0),
					},
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
							Image = 'rbxassetid://12097480671',
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 2,
					}
				}
				local h, a = rand()*twopi, (rand()-.5)*2
				local dir = Vector3.new(cos(h)*cos(a), sin(a), sin(h)*cos(a))
				Tween(absorbDuration, nil, function(a)
					local o = 1-a
					p.CFrame = part.CFrame + dir*4*o
					local s = .375 + .125*math.sin(a*10)
					if a < .2 then
						s = s * a * 5
					end
					bbg.Size = UDim2.new(s, 0, s, 0)
				end)
				p:remove()
			end)
			wait(1/freq)
		end
	end)
	local _, ambientStartSat, ambientStartVal = Color3.toHSV(ambientBefore)
	-- goal HSV: 0.016, 1, 0.5
	local sLabel = self.animation.spriteLabel
	local camGoalFocus = self.cf.p + Vector3.new(0, .25*18/2-inAirBefore, 0)--part.Position - self.offset - Vector3.new(0, inAirBefore, 0)
	local camGoal = CFrame.new(camGoalFocus - camBefore.lookVector*Vector3.new(12, 6, 12), camGoalFocus)
	local lerp = select(2, Utilities.lerpCFrame(camBefore, camGoal))
	local rst = tick()
	local function rumble()
		local et = tick()-rst
		local mag = .07
		if et < 1 then
			mag = mag * et
		elseif et > 5 then
			mag = mag * (6-et)
		end
		return CFrame.new(0, math.sin(et*50)*mag, 0)
	end
	Tween(3, nil, function(a)
		cam.CFrame = lerp(a) * rumble()
--		lighting.OutdoorAmbient = Color3.fromHSV(.016, ambientStartSat+(1-ambientStartSat)*a, ambientStartVal+(.5-ambientStartVal)*a)
		if a < .5 then
			local aa = a*2
			self.offset = Vector3.new(0, -inAirBefore*aa, 0)
		else
			local aa = 1-(2*(a-.5))
			sLabel.ImageColor3 = Color3.new(aa,aa,aa)
		end
	end)
	local megaEffect = _p.storage.Modelss.Misc.Mega:Clone()
	local egg = megaEffect.Egg
	local scale = .25--part.Size.Y/12
	Utilities.ScaleModel(megaEffect.Base, scale, true)
	local cf = self.cf * CFrame.Angles(0, math.pi/12--[[*2*math.random()]], 0) + Vector3.new(0, -.5*scale-inAirBefore, 0)
	local orb = megaEffect.Orb
	local innerEffect = megaEffect.InnerEnergy
	local outerEffect = megaEffect.OuterEnergy
	local fullsize = orb.Size
--	orb.PointLight.Range = 0
	innerEffect.EnergyPart.Transparency = 1.0
	outerEffect.EnergyPart.Transparency = 1.0
	innerEffect.EnergyPart.BrickColor = color2
	outerEffect.EnergyPart.BrickColor = color1
	MoveModel(megaEffect.Base, cf, true)
	local ocf = orb.CFrame
	egg.Parent = nil
	orb.BrickColor = color1
	megaEffect.Parent = self.battle.scene
	local shrinkTimer = Utilities.Timing.easeInCubic(.3)
	Tween(1, 'easeOutCubic', function(a, t)
		cam.CFrame = camGoal * rumble()
		orb.Size = fullsize*a
		orb.CFrame = ocf
--		orb.PointLight.Range = 20*scale*a
		if t > .5 and t < .8 then
			local sc = 1-shrinkTimer((t-.5))*.55
			sLabel.Size = UDim2.new(sc, 0, sc, 0)
			sLabel.Position = UDim2.new(.5-sc/2, 0, .5-sc/2, 0)
		end
	end)
	sLabel.Visible = false
	egg.Parent = megaEffect
	orb.Material = Enum.Material.Neon
	orb.BrickColor = color2
--	Tween(.5, 'easeInCubic', function(a)
--		orb.Size = fullsize*(1.05-.1*a)
--		orb.CFrame = ocf
--	end)
	local shellOffsets = {}
	for _, ch in pairs(egg:GetChildren()) do
		ch.BrickColor = color1
		shellOffsets[ch] = {ch.CFrame, (ch.Position - ocf.p).unit}
	end
	local stimer = Utilities.Timing.sineBack(1)
	local ecfi, ecfo = innerEffect.Hinge.CFrame, outerEffect.Hinge.CFrame
	Tween(2, 'easeInCubic', function(a)
		cam.CFrame = camGoal * rumble()
		orb.Size = fullsize*(.95+.2*a)
		orb.CFrame = ocf
		for sh, d in pairs(shellOffsets) do
			sh.CFrame = d[1] + d[2]*.4*a
		end
		innerEffect.EnergyPart.Transparency = 1-stimer(a)
		outerEffect.EnergyPart.Transparency = 1-stimer(a)
		MoveModel(innerEffect.Hinge, ecfi * CFrame.Angles(a*7, 0, 0))
		MoveModel(outerEffect.Hinge, ecfo * CFrame.Angles(-a*5, 0, 0))
	end)
	cam.CFrame = camGoal
	self.spriteData = megaEvolutionSpriteData
	self.offset = Vector3.new()
	self:renderNewSpriteData()
	sLabel = self.animation.spriteLabel
	local waitTime
	delay(.25, function()
		local cry = megaEvolutionSpriteData.cry
		if cry then
			if not mobile then waitTime = cry.duration end -- change if mobile gets cries
			self:playCry(nil, cry, .6)
		end
	end)
	Tween(.8, nil, function(a)
		orb.Size = fullsize*(1.15+a)
		orb.Transparency = a
		orb.CFrame = ocf
		for sh, d in pairs(shellOffsets) do
			sh.CFrame = d[1] + d[2]*(.4+15*a)
		end
		if a > .8 then
			for sh in pairs(shellOffsets) do
				sh.Transparency = (a-.8)*5
			end
		end
	end)
	megaEffect:remove()
	
	wait(waitTime and (waitTime - .15) or .5)
	lerp = select(2, Utilities.lerpCFrame(cam.CFrame, camBefore))
	spawn(function() _p.MusicManager:fadeToVolume(true, 1, .8) end)
	Tween(.8, 'easeOutCubic', function(a)
		local cf = lerp(a)
		cam.CFrame = cf--CFrame.new(cf.p, cf.p+cf.lookVector)
	end)
	
	for _, g in pairs(disabledGuis) do
		pcall(function() g.Visible = true end)
	end
end

function Sprite:animThrowBerry(brickColorName)
	if not self.battle.isSafari then return end

	local berry = storage.Models.Berry:Clone()
	local brickColor = BrickColor.new(brickColorName)
	for _, p in pairs(berry:GetChildren()) do
		if p:IsA("BasePart") then
			p.BrickColor = brickColor
		end
	end
	berry.Parent = self.battle.scene
	local main = berry.Main
	local p2 = self.battle.CoordinateFrame2 + (self.battle.CoordinateFrame1.p - self.battle.CoordinateFrame2.p).unit * 2 + Vector3.new(0, 0.1, 0)
	local rarm, gripOffset, holdDur
	local trainer = self.battle.playerModelObj
	--pcall(function()
	--	trainer.Model.HumanoidRootPart.Anchored = true
	--end)
	rarm = trainer.Model:FindFirstChild("Right Arm") or trainer.Model:FindFirstChild("RightHand")
	gripOffset = rarm and rarm.Name == "Right Arm" and 1 or 0.1675
	holdDur = rarm and rarm.Name == "Right Arm" and 0.55 or 0.45
	trainer.ThrowAnimation:Play()
	if rarm then
		do
			local trainerScale = trainer.Scale
			Tween(holdDur, nil, function()
				MoveModel(main, rarm.CFrame * CFrame.new(0, -(0.1 + gripOffset) * trainerScale, 0) * CFrame.Angles(-math.pi / 2, 0, 0), true)
			end)
		end
	else
		wait(holdDur)
	end
	local mcf = main.CFrame
	Tween(0.6, nil, function(a)
		MoveModel(main, mcf:lerp(p2, a) * CFrame.Angles(-a * 7, 0, 0) + Vector3.new(0, 2 * math.sin(a * math.pi), 0), true)
	end)
	return berry
end


function Sprite:animCaptureAttempt(ballId, shakes, critical, caught)
	local pokeball = (storage.Modelss.Pokeballs:FindFirstChild(ballId) or storage.Modelss.pokeball):Clone()
	pokeball.Parent = self.battle.scene
	local p2 = (self.battle.CoordinateFrame1 + Vector3.new(0, self.part.Size.Y, 0)) * CFrame.new(0, 0, .25)
	p2 = p2 + (self.battle.CoordinateFrame2.p-self.battle.CoordinateFrame1.p)
	local p1 = p2 + (self.battle.CoordinateFrame1.p-self.battle.CoordinateFrame2.p)*1.5 + Vector3.new(0, -self.part.Size.Y+4, 0)
	delay(.5, function()
		Utilities.sound(300394723, nil, nil, 10)
		Tween(.4, 'easeOutCubic', function(a)
			MoveModel(pokeball.top.Hinge,    pokeball.Hinge.CFrame * CFrame.Angles(0, 0, a*-.5))
			MoveModel(pokeball.bottom.Hinge, pokeball.Hinge.CFrame * CFrame.Angles(0, 0, a*.5 ))
		end)
	end)
	delay(.6, function()
		local s = self.animation.spriteLabel
		s.Visible = true
		Tween(.3, 'easeInCubic', function(a)
			local o = 1-a
			s.Size = UDim2.new(o, 0, o, 0)
			s.Position = UDim2.new(.5-o/2, 0, 0.0, 0)
			s.ImageColor3 = Color3.new(o, o, o)
		end)
	end)
	Tween(1, 'easeOutCubic', function(a)
		MoveModel(pokeball.Main, (p1+(p2.p-p1.p)*a+Vector3.new(0, math.sin(a*math.pi), 0))*CFrame.Angles(-a*6.8, 0, 0), true)
	end)
	Tween(.2, nil, function(a)
		local o = 1-a
		MoveModel(pokeball.top.Hinge,    pokeball.Hinge.CFrame * CFrame.Angles(0, 0, o*-.5))
		MoveModel(pokeball.bottom.Hinge, pokeball.Hinge.CFrame * CFrame.Angles(0, 0, o*.5 ))
	end)
	local cf = pokeball.Main.CFrame
	if critical then
		wait(.2)
		Tween(.6, nil, function(a)
			MoveModel(pokeball.Main, cf * CFrame.new(math.sin(a*math.pi*4)*(1-a)*.3, 0, 0), true)
		end)
		wait(.1)
	end
	Tween(.2*self.part.Size.Y, 'easeInQuad', function(a)
		local pos = cf.p - Vector3.new(0, (self.part.Size.Y-pokeball.Main.Size.Y/2)*a, 0)
		local look = (cf.lookVector*Vector3.new(1, 1-a, 1)).unit
		MoveModel(pokeball.Main, CFrame.new(pos, pos+look), true)
	end)
	cf = pokeball.Main.CFrame
	Tween(.5, nil, function(a)
		MoveModel(pokeball.Main, cf+Vector3.new(0, math.sin(a*math.pi)*self.part.Size.Y*.2, 0), true)
	end)
	wait(1)
	if critical and shakes == 0 then shakes = 1 end
	if shakes == 4 then shakes = 3 end
	for i = 1, shakes do
		Utilities.sound(301970857, 1, .1, 2)
		local angle = math.random()*math.pi*2
		local translate = Vector3.new(math.sin(angle), 0, math.cos(angle))
		local rotate = Vector3.new(math.sin(angle-math.pi/2), 0, math.cos(angle-math.pi/2))
		local vigor = .7+math.random()*.5
		Tween(.6, nil, function(t)
			local a = math.sin(t*3*math.pi) * (1-t)
			local theta = a*vigor
			local dist = a*pokeball.Main.Size.Y/2
			MoveModel(pokeball.Main, cf * CFrame.fromAxisAngle(rotate, theta) + translate*dist, true)
		end)
		wait(.5 + .5*math.random())
	end
	if caught then
		_p.MusicManager:fadeToVolume(true, 0.4, 0.3, true)
		delay(2, function()
			_p.MusicManager:fadeToVolume(true, 1, 0.6, true)
		end)
		Utilities.sound(300394776, 1.4, nil, 5)
		for i = 1, 12 do
			_p.Particles:new {
				Position = cf.p,
				Velocity = Vector3.new(0, 5, 0),
				VelocityVariation = 30,
				Acceleration = Vector3.new(0, -5, 0),
				Size = 0.3,
				Image = 286854973,
				Color = Color3.fromHSV(math.random(), 0.6, 1),
				Lifetime = 3
			}
		end
		--wait(.5)
	else
		delay(.125, function()
			hideAll(pokeball.top, pokeball.bottom)
			local s = self.animation.spriteLabel
			Tween(.15, 'easeOutCubic', function(a)
				s.Size = UDim2.new(a, 0, a, 0)
				s.Position = UDim2.new(.5-a/2, 0, 1-a, 0)
				s.ImageColor3 = Color3.new(a, a, a)
			end)
		end)
		Tween(.25, nil, function(a)
			local s = 5*a
			pokeball.Main.Mesh.Scale = Vector3.new(s, s, s)
			pokeball.Main.Transparency = math.abs(1-a*2)
		end)
		self:playCry()
		delay(1, function()
			pokeball:remove()
		end)
	end
end
-- transform
function Sprite:renderNewSpriteData()
	if self.animation then
		local wasPlaying = not self.animation.paused
		self.animation:remove()
		
		local sd, part = self.spriteData, self.part
		if self.slot then
			local posPart = self.battle.scene:FindFirstChild('pos'..self.siden..self.slot) or self.battle.scene[self.siden == 1 and '_User' or '_Foe']
			self.cf = posPart.CFrame - Vector3.new(0, posPart.Size.y/2, 0) + Vector3.new(0, sd.inAir or 0, 0)
			local scale = sd.scale or 1
			part.Size = Vector3.new(sd.fWidth/25*scale, sd.fHeight/25*scale, 0.6)
			part.CFrame = self.cf + Vector3.new(0, part.Size.y/2, 0)
			part.Gui.CanvasSize = Vector2.new(sd.fWidth, sd.fHeight)
		end
		
		local a = _p.AnimatedSprite:New(sd)
		a.spriteLabel.Parent = part.Gui
		if wasPlaying then a:Play() end
		self.animation = a
	end
end
function Sprite:animTransform(targetPokemon, spriteForme)
	if not self.oldSpriteData then
		self.oldSpriteData = self.spriteData
	end
	if targetPokemon then
		self.pokemon.spriteSpecies = targetPokemon.spriteSpecies or targetPokemon.species or targetPokemon.name
		self.forme = targetPokemon.sprite.forme
	else
		self.forme = spriteForme
	end
	self:updateSpriteData()
	self:renderNewSpriteData()
end
function Sprite:removeTransform(species)
	if self.oldSpriteData then
		self.spriteData = self.oldSpriteData
--		self.forme = ?
		self.oldSpriteData = nil
		self:renderNewSpriteData()
	end
end
-- substitute
function Sprite:animSub()
	-- [front] [back]
	-- 
--	local sp
	
end
function Sprite:animSubFade()
	
end
function Sprite:removeSub()
	
end
-- move
function Sprite:beforeMove()
	
end
function Sprite:afterMove()
	
end
function Sprite:animReset()
	self.offset = Vector3.new()
	pcall(function() self.animation.spriteLabel.ImageTransparency = 0.0 end)
end
-- send in / out
local stampEmitter = {
	function(stamp, cf) -- fountain
		local sheetId = stamp.sheetId
		local s = stamp.n-1
		local imageRectSize = Vector2.new(200, 200)
		local imageRectOffset = Vector2.new(200*(s%5), 200*math.floor(s/5))
		local rainbow = stamp.rainbow and true or false
		local imageColor3 = stamp.color3
		local accel = 30
		local pSpread = 2
		local aSpread = 40
		local roffset = math.random(6)
		for i = 1, 6 do
			local c0 = cf * CFrame.new((pSpread*7/6)/2-pSpread/6*i, -.7, -.5)
			local t0 = math.rad((aSpread*7/6)/2-aSpread/6*i)
			local vx = 10*math.sin(t0)
			local vy = 10*math.cos(t0)*1.2
			_p.Particles:new {
				Image = sheetId,
				Color = rainbow and Color3.fromHSV(((i+roffset)%6)/6, 1, 1) or imageColor3,
				ImageRectSize = imageRectSize,
				ImageRectOffset = imageRectOffset,
				Acceleration = false,
				Lifetime = .7,
				OnUpdate = function(a, gui)
					local t = a*.7
					gui.CFrame = c0 * CFrame.new(vx*t, vy*t-.5*accel*t*t, 0)
					local s = .6+1*a
					gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					gui.BillboardGui.ImageLabel.Rotation = -vx*30*t
					if a > .8 then
						gui.BillboardGui.ImageLabel.ImageTransparency = (a-.8)*5
					end
				end
			}
		end
	end,
	function(stamp, cf) -- explode
		local sheetId = stamp.sheetId
		local s = stamp.n-1
		local imageRectSize = Vector2.new(200, 200)
		local imageRectOffset = Vector2.new(200*(s%5), 200*math.floor(s/5))
		local rainbow = stamp.rainbow and true or false
		local imageColor3 = stamp.color3
		local twoPi = math.pi*2
		local offset = math.random()*twoPi
		for i = 1, 6 do
			local theta = offset+twoPi/6*i+.13*(math.random()-.5)
			local v = 5--2+3*math.random()
			local r = .1--.5+math.random()
			local rot = math.deg(theta)-90
			_p.Particles:new {
				Image = sheetId,
				Color = rainbow and Color3.fromHSV(i/6, 1, 1) or imageColor3,
				ImageRectSize = imageRectSize,
				ImageRectOffset = imageRectOffset,
				Position = cf * Vector3.new(math.cos(theta)*r, math.sin(theta)*r, -.5),
--				Size = 1.3,
				Velocity = (cf-cf.p) * Vector3.new(math.cos(theta)*v, math.sin(theta)*v, 0),
				Acceleration = false,
--				Rotation = math.deg(theta)-90,
				Lifetime = .7,--.4,--.2+.3*math.random()
				OnUpdate = function(a, gui)
					local s = .8+.8*a
					gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					gui.BillboardGui.ImageLabel.Rotation = rot+160*(a-.5)
					if a > .8 then
						gui.BillboardGui.ImageLabel.ImageTransparency = (a-.8)*5
					end
				end
			}
		end
	end,
	function(stamp, cf) -- wave
		local sheetId = stamp.sheetId
		local s = stamp.n-1
		local imageRectSize = Vector2.new(200, 200)
		local imageRectOffset = Vector2.new(200*(s%5), 200*math.floor(s/5))
		local rainbow = stamp.rainbow and true or false
		local imageColor3 = stamp.color3
		local twoPi = math.pi*2
		local offset = math.random()*twoPi
		for i = 1, 6 do
			local theta = offset+twoPi/6*i+.13*(math.random()-.5)
--			local v = 5--2+3*math.random()
--			local r = .1--.5+math.random()
			local rot = math.deg(theta)-90
			_p.Particles:new {
				Image = sheetId,
				Color = rainbow and Color3.fromHSV(i/6, 1, 1) or imageColor3,
				ImageRectSize = imageRectSize,
				ImageRectOffset = imageRectOffset,
--				Position = cf * Vector3.new(math.cos(theta)*r, math.sin(theta)*r, -.5),
--				Size = 1.3,
--				Velocity = (cf-cf.p) * Vector3.new(math.cos(theta)*v, math.sin(theta)*v, 0),
				Acceleration = false,
--				Rotation = math.deg(theta)-90,
				Lifetime = .7,--.4,--.2+.3*math.random()
				OnUpdate = function(a, gui)
					local t = theta - .3*math.sin(a*9)
					local r = .1 + a*.7*5
					gui.CFrame = cf * CFrame.new(math.cos(t)*r, math.sin(t)*r, -.5)
					local s = .8+.8*a
					gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					gui.BillboardGui.ImageLabel.Rotation = rot-90*math.cos(a*9)--+160*(a-.5)
					if a > .8 then
						gui.BillboardGui.ImageLabel.ImageTransparency = (a-.8)*5
					end
				end
			}
		end
	end,
	function(stamp, cf) -- spiral
		local sheetId = stamp.sheetId
		local s = stamp.n-1
		local imageRectSize = Vector2.new(200, 200)
		local imageRectOffset = Vector2.new(200*(s%5), 200*math.floor(s/5))
		local rainbow = stamp.rainbow and true or false
		local imageColor3 = stamp.color3
		local twoPi = math.pi*2
		local offset = math.random()*twoPi
		for i = 1, 6 do
			local theta = offset+twoPi/6*i+.13*(math.random()-.5)
--			local v = 5--2+3*math.random()
--			local r = .1--.5+math.random()
			local rot = math.deg(theta)-90
			_p.Particles:new {
				Image = sheetId,
				Color = rainbow and Color3.fromHSV(i/6, 1, 1) or imageColor3,
				ImageRectSize = imageRectSize,
				ImageRectOffset = imageRectOffset,
--				Position = cf * Vector3.new(math.cos(theta)*r, math.sin(theta)*r, -.5),
--				Size = 1.3,
--				Velocity = (cf-cf.p) * Vector3.new(math.cos(theta)*v, math.sin(theta)*v, 0),
				Acceleration = false,
--				Rotation = math.deg(theta)-90,
				Lifetime = .7,--.4,--.2+.3*math.random()
				OnUpdate = function(a, gui)
					local t = theta - 1.7*a
					local r = .1 + a*.7*5
					gui.CFrame = cf * CFrame.new(math.cos(t)*r, math.sin(t)*r, -.5)
					local s = .8+.8*a
					gui.BillboardGui.Size = UDim2.new(s, 0, s, 0)
					gui.BillboardGui.ImageLabel.Rotation = rot+160*(a-.5)
					if a > .8 then
						gui.BillboardGui.ImageLabel.ImageTransparency = (a-.8)*5
					end
				end
			}
		end
	end
}
function Sprite:animSummon(slot, msgFn, isSecondary)
	self.slot = slot
	while not self.spriteData do runService.RenderStepped:wait() end
	local sd = self.spriteData
	if not self.part then
		local posPart = self.battle.scene:FindFirstChild('pos'..self.siden..slot) or self.battle.scene[self.siden == 1 and '_User' or '_Foe']
		self.cf = posPart.CFrame - Vector3.new(0, posPart.Size.y/2, 0) + Vector3.new(0, sd.inAir or 0, 0)
		local part = posPart:Clone()
		local scale = sd.scale or 1
		part.Size = Vector3.new(sd.fWidth/25*scale, sd.fHeight/25*scale, 0.6)
		part.CFrame = self.cf + Vector3.new(0, part.Size.y/2, 0)
		part.Gui.CanvasSize = Vector2.new(sd.fWidth, sd.fHeight)
		part.Name = 'Part'
		part.Parent = self.battle.scene
		self.part = part
	else
		local posPart = self.battle.scene:FindFirstChild('pos'..self.siden..slot) or self.battle.scene[self.siden == 1 and '_User' or '_Foe']
		self.cf = posPart.CFrame - Vector3.new(0, posPart.Size.y/2, 0) + Vector3.new(0, sd.inAir or 0, 0)
		local part = self.part
		part.CFrame = self.cf + Vector3.new(0, part.Size.y/2, 0)
	end
	if not self.animation then
		local a = _p.AnimatedSprite:New(sd)
		a.spriteLabel.Visible = false
		a.spriteLabel.Parent = self.part.Gui
		self.animation = a
	end
	self.animation:Play()
	local customSparkle
	local pokemon = self.pokemon
	local spriteId = pokemon.spriteSpecies or pokemon.species or pokemon.name
		--	print(spriteId, pokemon.forme)
		pcall(function() if aura then aura:remove() aura = false end end)

		if customSparkle or self.pokemon.shiny then -- shiny sparkle
			local nsk = NumberSequenceKeypoint.new
			aura = create("ParticleEmitter")({

				Name = "Aura",
				Texture = "rbxassetid://771860314",
				ZOffset = 0.71,
				LightEmission = 0.2,
				Size = NumberSequence.new({
					nsk(0, 0, 0),
					nsk(0.5, 0.15, 0.05),
					nsk(1, 0, 0)
				}),
				Acceleration = Vector3.new(0, 0, 0),
				Lifetime = NumberRange.new(2),
				Rate = 5,
				Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(-150, 150),
				Speed = NumberRange.new(0),
				Parent = self.part
			})

		end
		
	if (spriteId == 'Onix' or spriteId == 'Steelix') and self.forme == 'crystal' then
		customSparkle = function()
			Utilities.sound(282237234, nil, nil, 5)
			local p = self.part
			local cf = p.CFrame
			for _ = 1, 8 do
				for _ = 1, 3 do
					local theta = math.random()*math.pi*2
					local v = 2+3*math.random()
					local r = .5+math.random()
					_p.Particles:new {
							Image = 5119886169,
						Position = cf * Vector3.new(math.cos(theta)*r, math.sin(theta)*r, -.5),
						Size = .25+.5*math.random(),
						Velocity = (cf-cf.p) * Vector3.new(math.cos(theta)*v, math.sin(theta)*v, 0),
						Acceleration = false,
						Rotation = math.deg(theta)+90,
						Lifetime = .2+.3*math.random()
					}
				end
				wait(.125)
			end
		end
	end
	local function sparkle()
		if type(customSparkle) == 'function' then
			customSparkle()
			return
		end
		Utilities.sound(282237234, nil, nil, 5)
		local p = self.part
		for _ = 1, 8 do
			for _ = 1, 3 do
				local theta = math.random()*math.pi*2
				_p.Particles:new {
					Image = customSparkle or 5217931446,
					Position = p.Position + Vector3.new(math.cos(theta)*(p.Size.x/2+1)*math.random(), -p.Size.Y*.5*math.random(), math.sin(theta)*(p.Size.x/2+1)*math.random()),
					Size = .25+.75*math.random(),
					Velocity = Vector3.new(0, 1+7*math.random(), 0),
					VelocityVariation = 15,
					Acceleration = Vector3.new(0, 5, 0),
					Lifetime = .2+.3*math.random()
				}
			end
			wait(.125)
		end
	end
	--
	if self.battle.kind == 'wild' and self.siden == 2 then
		self.animation.spriteLabel.Visible = true
		if customSparkle or self.pokemon.shiny then delay(.5, sparkle) end
		return
	end
	local trainer
	if self.siden == 1 then
		trainer = self.battle['playerModelObj'..slot] or self.battle.playerModelObj
	else
		trainer = self.battle['trainerModelObj'..slot] or self.battle.trainerModelObj
	end
	if trainer and not isSecondary then
		if trainer.faded then
			trainer = nil
		else
			trainer.faded = true
		end
	end
	if self.battle.fastForward then
		self.animation.spriteLabel.Visible = true
		if trainer and not isSecondary then
			trainer.Model.Parent = nil
			trainer.Root.CFrame = trainer.Root.CFrame * CFrame.new(0, 8, 0)
			for _, p in pairs(Utilities.GetDescendants(trainer.Model, 'BasePart')) do
				p.Transparency = 1.0
			end
		end
		return
	end
	local ballName = 'pokeball'
	pcall(function() if self.pokemon.pokeball then ballName = _p.Pokemon:getPokeBall(self.pokemon.pokeball) end end)
	local pokeball = (storage.Modelss.Pokeballs:FindFirstChild(ballName) or storage.Modelss.pokeball):Clone()
	local function check(model) for _, p in pairs(model:GetChildren()) do if p:IsA('BasePart') then p.Anchored = true p.CanCollide = false end check(p) end end check(pokeball)
	pokeball.Parent = self.battle.scene
	local p2; do
		local cf = self.battle['CoordinateFrame'..self.siden]
		p2 = (cf - cf.p + self.part.Position + Vector3.new(0, self.part.Size.Y/2, 0)) * CFrame.new(0, 0, .25)
	end
	local p1 = p2 * CFrame.new(0, 0, 4)
	
	local speed = 1
	local rarm, gripOffset, holdDur
	if trainer then -- pokeball grows in hand
		rarm = trainer.Model:FindFirstChild('Right Arm') or trainer.Model:FindFirstChild('RightHand')
		gripOffset = (rarm.Name=='Right Arm') and 1 or .335/2
		holdDur    = (rarm.Name=='Right Arm') and .55 or .45
		if rarm then
			local trainerScale = trainer.Scale
			local scale = Utilities.ScaleModel
			local main = pokeball.Main
			local lastScale = 1
			Tween(.6/speed, 'easeOutCubic', function(a)
				local newScale = .5 + .5*a
				scale(main, newScale / lastScale, true)
				lastScale = newScale
				MoveModel(main, rarm.CFrame * CFrame.new(0, -(newScale*.5+gripOffset)*trainerScale, 0) * CFrame.Angles(-math.pi/2, 0, 0), true)
			end)
--			wait(.15/speed)
		end
	end
	delay(.8/speed, function() -- cry & ball sounds
		local v = .2
		local sound = Utilities.sound(300394663, v, nil, 5)
		wait(.5/speed)
		delay(.25/speed, function()
			self:playCry()
		end)
		Utilities.Tween(2.5/speed, nil, function(a)
			sound.Volume = (1-a)*v
		end)
	end)
	if msgFn then
		spawn(msgFn)
	end
	delay(.5/speed, function() -- pokeball opening
		Tween(.4/speed, 'easeOutCubic', function(a)
			MoveModel(pokeball.top.Hinge,    pokeball.Hinge.CFrame * CFrame.Angles(0, 0, a*-.5))
			MoveModel(pokeball.bottom.Hinge, pokeball.Hinge.CFrame * CFrame.Angles(0, 0, a*.5 ))
		end)
	end)
	delay(.9/speed, function() -- pokemon growing from small / fading in from black
		local s = self.animation.spriteLabel
		s.Visible = true
		Tween(.3/speed, 'easeInCubic', function(a)
			s.Size = UDim2.new(a, 0, a, 0)
			s.Position = UDim2.new(.5-a/2, 0, 0.0, 0)
			s.ImageColor3 = Color3.new(a, a, a)
		end)
	end)
	if pokemon.pbs then -- poke ball stamps
		delay(.8/speed, function()
			for _, stamp in pairs(pokemon.pbs) do
			local pos = pokeball.Main.Position
			local cf = self.part.CFrame
			cf = cf-cf.p+pos
				pcall(function() stampEmitter[stamp.style](stamp, cf) end)
				wait(.1)
			end
		end)
	end
	delay(.8/speed, function() -- white flash expand effect, ball disappear
		delay(.25/speed, function()
			hideAll(pokeball.top, pokeball.bottom)
		end)
		Tween(.5/speed, nil, function(a)
			local s = 5*a
			pokeball.Main.Mesh.Scale = Vector3.new(s, s, s)
			pokeball.Main.Transparency = .5+.5*math.abs(1-a*2)
		end)
	end)
	-- main ball movement
	if trainer then -- throw from arm
		local main = pokeball.Main
--		local holdDur = .55
		if not isSecondary then
			trainer.ThrowAnimation:Play(nil, nil, speed)
			local v = create 'BodyVelocity' {
				MaxForce = Vector3.new(math.huge, 0, math.huge),
				Velocity = trainer.CFrame.lookVector*-8*speed,
				Parent = trainer.Root,
			}
			delay(1/speed, function()
				v:remove()
				trainer.Model.Parent = nil
			end)
			if self.siden == 2 then
				local root = trainer.Root
				local parts = {}
				local function check(obj)
					for _, p in pairs(obj:GetChildren()) do
						if p:IsA('BasePart') and p ~= root then
							parts[p] = p.Transparency
						elseif p:IsA('Model') then
							check(p)
						end
					end
				end
				check(trainer.Model)
				spawn(function()
					Tween(1/speed, nil, function(a)
						if a > .5 then
							local ta = (a-.5)*2
							for p, t in pairs(parts) do
								p.Transparency = t + (1-t)*ta
							end
						end
					end)
				end)
			end
		end
		if rarm then
			local trainerScale = trainer.Scale
			Tween(holdDur/speed, nil, function()
				MoveModel(main, rarm.CFrame * CFrame.new(0, -(.5+gripOffset)*trainerScale, 0) * CFrame.Angles(-math.pi/2, 0, 0), true)
			end)
		else
			wait(holdDur/speed)
		end
		local lerp = select(2, Utilities.lerpCFrame(main.CFrame, p2))
		Tween(1/speed, 'easeOutCubic', function(a)
			MoveModel(main, lerp(a) * CFrame.Angles(-a*7, 0, 0) + Vector3.new(0, math.sin(a*math.pi), 0), true)
		end)
	else -- throw from air
		Tween(1/speed, 'easeOutCubic', function(a)
			MoveModel(pokeball.Main, (p1+(p2.p-p1.p)*a+Vector3.new(0, math.sin(a*math.pi), 0))*CFrame.Angles(-a*7, 0, 0), true)
		end)
	end
	--
	delay(1/speed, function() -- ball cleanup
		pokeball:remove()
	end)
	wait(.25)
		if (customSparkle or self.pokemon.shiny) and not self.battle.isSafari then -- shiny sparkle
		sparkle()
		wait(.2)
	end
	wait(.4)
end
function Sprite:animUnsummon()
	if self.battle.fastForward then
		self.animation.spriteLabel.Visible = false
		self.animation:Pause()
		return
	end
	local pos = (self.part.CFrame*CFrame.new(0, -self.part.Size.Y/2+1, 0)).p
	local cf = self.battle['CoordinateFrame'..self.siden]
	cf = cf - cf.p + pos
--	local p, s = Utilities.extents(pos, 2)
	
	local part = create 'Part' {
		Transparency = 1.0,
		Anchored = true,
		CanCollide = false,
--		FormFactor = Enum.FormFactor.Custom,
		Size = Vector3.new(.2, .2, .2),
		CFrame = CFrame.new(pos),
		Parent = workspace,
	}
	local orb = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217740472',
		create 'ImageLabel' {
			BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5217740472',
			Size = UDim2.new(0.5, 0, 0.5, 0),
			Position = UDim2.new(0.25, 0, 0.25, 0),
		},
		Parent = create 'BillboardGui' {
			Size = UDim2.new(1.5, 0, 1.5, 0),
			Parent = part,
		}
	}
	
	Utilities.sound(300394866, nil, .2, 8)
	local sprite = self.animation.spriteLabel
	local offset = (self.part.Size.Y-1)/self.part.Size.Y - .5
	Tween(.5, 'easeInCubic', function(a)
		orb.Size = UDim2.new(a, 0, a, 0)
		orb.Position = UDim2.new(0.5-a/2, 0, 0.5-a/2, 0)
		local o = 1-a
		sprite.Size = UDim2.new(o, 0, o, 0)
		sprite.Position = UDim2.new(0.5-o/2, 0, 0.5-o/2+offset*a, 0)
	end)
	sprite.Visible = false
	self.animation:Pause()
	local timerx = Utilities.Timing.easeInCubic(1)
	local timery = Utilities.Timing.easeOutCubic(1)
	local lastp = 0
	Tween(.75, nil, function(a)
		local cf = cf + Vector3.new(0, timery(a)*2, 0) - cf.lookVector*a*4.5
		part.CFrame = cf
		if a-lastp > .1 then
			lastp = a
			_p.Particles:new {
				Image = 68068592,
				Position = cf.p,
				Size = .25+.5*math.random(),
				Velocity = Vector3.new(0, 1+7*math.random(), 0),
				VelocityVariation = 10,
				Acceleration = Vector3.new(0, 2, 0),
				Lifetime = .2+.25*math.random(),
			}
		end
	end)
	part:remove()
end
function Sprite:animDragIn(slot)
	self:animSummon(slot) --
end
function Sprite:animDragOut()
	self.pokemon.statbar:slideOffscreen(true)
	self.pokemon.statbar = nil
	if self.battle.fastForward then
		self.animation.spriteLabel.Visible = false
		self.animation:Pause()
		return
	end
	local dir = -self.battle['CoordinateFrame'..self.siden].lookVector
	local part = self.part
	local sprite = self.animation.spriteLabel
	local cf = part.CFrame
	Utilities.Tween(.5, nil, function(a)
		self.offset = dir*3*a
--		part.CFrame = cf + dir*3*a
		sprite.ImageTransparency = a
	end)
	sprite.Visible = false
	sprite.ImageTransparency = 0.0
	self.animation:Pause()
	self.offset = nil
--	part.CFrame = cf
end
function Sprite:animFaint()
	if not self.battle.fastForward then
		self:playCry(0.75)
	end
	if self.battle.kind == 'wild' and self.siden == 2 then
		local s = self.animation.spriteLabel
		local inAir = self.spriteData.inAir or 0
		delay(.5, function()
			self.pokemon.statbar:slideOffscreen(true)
			self.pokemon.statbar = nil
		end)
		Utilities.Tween(1, 'easeInCubic', function(a)
			self.offset = Vector3.new(0, -inAir*a, 0)
			local o = 1-a
			s.Size = UDim2.new(o, 0, o, 0)
			s.Position = UDim2.new(.5-o/2, 0, a, 0)
			s.ImageColor3 = Color3.new(o, o, o)
		end)
		s.Visible = false
	else
		self.pokemon.statbar:slideOffscreen(true)
		self.pokemon.statbar = nil
		self:animUnsummon()
	end
end
function Sprite:delay(time) end
function Sprite:selfAnim() end
function Sprite:anim() end

function Sprite:remove()
--	print('sprite::remove')
	pcall(function() self.animation:remove() end)
--	pcall(function() self.testAnimation:remove() end)
	pcall(function() self.part:remove() end)
	self.pokemon = nil
	self.battle = nil
	self.spriteData = nil
	
end


return Sprite end