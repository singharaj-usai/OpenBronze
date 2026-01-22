--SynapseX Decompiler

return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local Lighting = game:GetService("Lighting")
	local clouds = {enabled = false, currentTransparency = 0}
	local timeColors = {
		{
			Time = 0,
			Btm = Color3.fromRGB(13, 20, 25),
			Mid = Color3.fromRGB(18, 21, 31),
			Top = Color3.fromRGB(67, 67, 67),
			Topb = Color3.fromRGB(38, 38, 38)
		},
		{
			Time = 4,
			Btm = Color3.fromRGB(38, 37, 43),
			Mid = Color3.fromRGB(33, 28, 35),
			Top = Color3.fromRGB(67, 67, 67),
			Topb = Color3.fromRGB(38, 38, 38)
		},
		{
			Time = 6.167,
			Btm = Color3.fromRGB(49, 73, 90),
			Mid = Color3.fromRGB(44, 52, 74),
			Top = Color3.fromRGB(86, 86, 86),
			Topb = Color3.fromRGB(83, 83, 83)
		},
		{
			Time = 6.333,
			Btm = Color3.fromRGB(64, 96, 118),
			Mid = Color3.fromRGB(78, 92, 131),
			Top = Color3.fromRGB(131, 131, 131),
			Topb = Color3.fromRGB(150, 150, 150)
		},
		{
			Time = 6.5,
			Btm = Color3.fromRGB(110, 157, 198),
			Mid = Color3.fromRGB(120, 139, 198),
			Top = Color3.fromRGB(255, 255, 255),
			Topb = Color3.fromRGB(255, 255, 255)
		},
		{
			Time = 17.5,
			Btm = Color3.fromRGB(91, 131, 163),
			Mid = Color3.fromRGB(104, 121, 172),
			Top = Color3.fromRGB(193, 193, 193),
			Topb = Color3.fromRGB(193, 193, 193)
		},
		{
			Time = 17.667,
			Btm = Color3.fromRGB(87, 127, 157),
			Mid = Color3.fromRGB(96, 112, 159),
			Top = Color3.fromRGB(148, 148, 148),
			Topb = Color3.fromRGB(153, 153, 153)
		},
		{
			Time = 17.833,
			Btm = Color3.fromRGB(49, 73, 90),
			Mid = Color3.fromRGB(44, 52, 74),
			Top = Color3.fromRGB(86, 86, 86),
			Topb = Color3.fromRGB(70, 70, 70)
		},
		{
			Time = 18,
			Btm = Color3.fromRGB(68, 68, 58),
			Mid = Color3.fromRGB(58, 59, 49),
			Top = Color3.fromRGB(70, 70, 70),
			Topb = Color3.fromRGB(50, 50, 50)
		},
		{
			Time = 18.167,
			Btm = Color3.fromRGB(60, 59, 68),
			Mid = Color3.fromRGB(56, 48, 59),
			Top = Color3.fromRGB(67, 67, 67),
			Topb = Color3.fromRGB(38, 38, 38)
		},
		{
			Time = 18.333,
			Btm = Color3.fromRGB(38, 37, 43),
			Mid = Color3.fromRGB(33, 28, 35),
			Top = Color3.fromRGB(67, 67, 67),
			Topb = Color3.fromRGB(38, 38, 38)
		},
		{
			Time = 20.333,
			Btm = Color3.fromRGB(13, 20, 25),
			Mid = Color3.fromRGB(18, 21, 31),
			Top = Color3.fromRGB(67, 67, 67),
			Topb = Color3.fromRGB(38, 38, 38)
		}
	}
	function clouds.update()
		local cTime = Lighting.ClockTime
		for i = #timeColors, 1, -1 do
			local tData = timeColors[i]
			if cTime > tData.Time then
				clouds.Btm.Color = ColorSequence.new(tData.Btm)
				clouds.Mid.Color = ColorSequence.new(tData.Mid)
				clouds.Top.Color = ColorSequence.new(tData.Top)
				clouds.Topb.Color = ColorSequence.new(tData.Topb)
				break
			end
		end
	end
	function clouds:enable(cf)
		if self.enabled then
			if cf then
				self.desiredCFrame = cf
				self.part.CFrame = cf
			end
			return
		end
		self.enabled = true
		local part = self.part
		if not part then
			part = create("Part")({
				Name = "Clouds",
				Transparency = 1,
				Anchored = true,
				CanCollide = false,
				Size = Vector3.new(0.05, 0.05, 0.05)
			})
			local function makeBeam(texture, zoffset, height)
				return create("Beam")({
					Transparency = NumberSequence.new(0),
					LightEmission = 0,
					LightInfluence = 0,
					Texture = texture,
					TextureLength = 1,
					TextureSpeed = 0.001,
					TextureMode = Enum.TextureMode.Stretch,
					CurveSize0 = 0,
					CurveSize1 = 0,
					Segments = 1,
					Width0 = 50000,
					Width1 = 50000,
					ZOffset = zoffset,
					Parent = part,
					Attachment0 = create("Attachment")({
						Orientation = Vector3.new(90, 0, 0),
						Position = Vector3.new(-25000, height, 0),
						Parent = part
					}),
					Attachment1 = create("Attachment")({
						Orientation = Vector3.new(90, 0, 0),
						Position = Vector3.new(25000, height, 0),
						Parent = part
					})
				})
			end
			self.Btm = makeBeam("rbxassetid://1476330051", 0, 2500)
			self.Mid = makeBeam("rbxassetid://1476329662", -50, 2550)
			self.Top = makeBeam("rbxassetid://1476329662", -100, 2600)
			self.Topb = makeBeam("rbxassetid://1476330051", -150, 2650)
			self.part = part
		end
		self.timeConn = Lighting:GetPropertyChangedSignal("ClockTime"):Connect(self.update)
		self.update()
		if cf then
			self.desiredCFrame = cf
			part.CFrame = cf
		end
		part.Parent = workspace
		local thisThread = {}
		self.equipThread = thisThread
		if not self.loaded then
			Utilities.fastSpawn(function()
				game:GetService("ContentProvider"):PreloadAsync({part})
				if self.equipThread == thisThread then
					self.loaded = true
					self.Btm.Enabled = false
					self.Mid.Enabled = false
					self.Top.Enabled = false
					self.Topb.Enabled = false
					wait()
					self.Btm.Enabled = true
					self.Mid.Enabled = true
					self.Top.Enabled = true
					self.Topb.Enabled = true
				end
			end)
		end
	end
	function clouds:disable()
		if not self.enabled then
			return
		end
		self.enabled = false
		self.equipThread = nil
		if self.timeConn then
			self.timeConn:Disconnect()
			self.timeConn = nil
		end
		if self.part then
			self.part.Parent = nil
		end
	end
	function clouds:show()
		if not self.Btm then
			return
		end
		self.Btm.Enabled = true
		self.Mid.Enabled = true
		self.Top.Enabled = true
		self.Topb.Enabled = true
	end
	function clouds:hide()
		if not self.Btm then
			return
		end
		self.Btm.Enabled = false
		self.Mid.Enabled = false
		self.Top.Enabled = false
		self.Topb.Enabled = false
	end
	function clouds:setTransparency(t)
		if not self.Btm then
			return
		end
		local transparency = NumberSequence.new(t)
		self.Btm.Transparency = transparency
		self.Mid.Transparency = transparency
		self.Top.Transparency = transparency
		self.Topb.Transparency = transparency
	end
	return clouds
end
