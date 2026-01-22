local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework'))
local Utilities = _f.Utilities
local Tween = Utilities.Tween
local create = Utilities.Create

local partTypes = {
	"Part",
	"MeshPart",
	"WedgePart",
	"UnionOperation"
}

local function getPartGrab(name)
	return function(board)
		local parts = {}

		for i, obj in pairs(board:GetChildren()) do
			if table.find(partTypes, obj.ClassName) and obj.Name == name then
				table.insert(parts, obj)
			end
		end

		return parts
	end
end

local function RainbowFn(board, parts)
	local x = 0

	while board and wait() do
		if not board then return end
		for i, part in pairs(parts) do
			if not board then return end
			spawn(function()
				part.Color = Color3.fromHSV(x,1,1)
			end)
		end
		x = x + 1/255
		if x >= 1 then
			x = 0
		end
	end	
end

local function cParticle(s, image, size, color)
	local p = create 'Part' {
		Transparency = 1.0,
		Anchored = false,
		CanCollide = false,
		Size = Vector3.new(.2, .2, .2),
		Position = s.Position,
		Parent = s,
	}
	local bbg = create 'BillboardGui' {
		Adornee = p,
		Size = UDim2.new(size or 1, 0, size or 1, 0),
		Parent = p
	}
	local img = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = type(image) == 'number' and ('rbxassetid://'..image) or image,
		ImageColor3 = color or nil,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		ZIndex = 2,
		Parent = bbg
	}

	local w = 	Utilities.Create 'Weld' {
		Name = "PWeld",
		Part0 = s,
		Part1 = p,
		C0 = CFrame.new(), 
		C1 = CFrame.new(),
		Parent = p
	}
	return p, bbg, img, w
end

local function gr(n)
	return math.random(-n, n) / 100
end

return {
	effects = {
		["Rainbow Basic"] = {
			grabParts = getPartGrab("Recolor"),
			effect = {
				Fn = RainbowFn,
				doSpawn = true
			},
		},
		["Rainbow Lavaboard"] = {
			grabParts = getPartGrab("Recolor"),
			effect = {
				Fn = RainbowFn,
				doSpawn = true
			},
		},
		["Rainbow Fidget Spinner"] = {
			grabParts = getPartGrab("Recolor"),
			effect = {
				Fn = RainbowFn,
				doSpawn = true
			},
		},
		["Rainbow Laserboard"] = {
			grabParts = getPartGrab("Recolor"),
			effect = {
				Fn = RainbowFn,
				doSpawn = true
			},
		},
		["Rainbow Part"] = {
			effect = {
				Fn = function(board)
					RainbowFn(board, {board.pt})
				end,
				doSpawn = true
			},
		},
	},
	actions = {
		Spinner = {
			fn = function(PlayerData, board)
				local speed = .5 -- / 0.25 / .125 
				local doSpin = true
				local SWeld = board.Main.SWeld

				spawn(function()
					while doSpin and SWeld do
						if not doSpin or not SWeld then return end
						local C0 = SWeld.C0

						local theta, lerp = Utilities.lerpCFrame(C0, C0*CFrame.Angles(0, 360, 0))
						Tween(speed, nil, function(a)
							if not doSpin or not SWeld then return end
							SWeld.C0 = lerp(a)
						end)
					end
				end)

				PlayerData.currentBoardAnim = function()
					if speed <= .125 then
						doSpin = false
						SWeld.C0 = CFrame.new()
						PlayerData.currentBoardAnim = nil
					else
						speed /= 2
					end	
				end
			end
		},
		["Shiny M.Salamence Board"] = {
			doDebounce = true,
			fn = function(PlayerData, board)
				local head = board:WaitForChild("Head")
				local effect = head.Effect
				local mouth = effect.Mouth
				local s = effect.s
				local weld

				for i, obj in pairs(board.Main:GetChildren()) do
					if obj:IsA("Weld") and obj.Part1 == mouth then
						weld = obj
						break
					end
				end

				local doSpin = true
				local dp = Vector3.new(5,0,0) -- ty not
				local C0 = weld.C0
				local theta, lerp = Utilities.lerpCFrame(C0, C0*CFrame.Angles(math.rad(22.5), 0, 0))

				Tween(1, 'easeOutCubic', function(a)
					weld.C0 = lerp(a)
				end)

				for n = 1, 10 do
					for i=1, math.random(5) do
						local r = Vector3.new(gr(35), gr(35), gr(35))
						spawn(function()
							local p, b, i, w = cParticle(s, 600006428, 1)
							Tween(2, nil, function(a)
								i.ImageColor3 = Color3.fromHSV(.069 + .069*(1-a), 1, 1)
								w.C0 = CFrame.new(r + dp * a)
								b.Size = UDim2.new(0.25 + 1.25 * a, 0, 0.25 + 1.25 * a, 0)
							end)
							p:Destroy()
						end)    
						wait(0.01)
					end    
					wait(math.random(1, 5)/ 100)
				end
				C0 = weld.C0
				theta, lerp = Utilities.lerpCFrame(C0, C0*CFrame.Angles(math.rad(-22.5), 0, 0))

				Tween(1, 'easeOutCubic', function(a)
					weld.C0 = lerp(a)
				end)
			end,
		},
		["Pipe Rusted"] = {
			doDebounce = true,
			fn = function(PlayerData, board)
				local s = board.s
				local c = Color3.fromHSV((210 + math.random() * 20) / 360, 0.8, 0.75)
				local r, g, b = math.round(c.R*255), math.round(c.G*255), math.round(c.B*255)
				for n = 1, 25 do
					spawn(function()
						local r = Vector3.new(gr(15), gr(15), gr(15))
						local p, b, i, w = cParticle(s, 650846795, 1, c)
						Tween(0.4, nil, function(a)
							i.ImageColor3 = c:Lerp(Color3.fromRGB(128, 187, 219), a)
							w.C0 = CFrame.new(r + Vector3.new(0, 5, 0) * a)
							b.Size = UDim2.new(1 + 2 * a, 0, 1 + 2 * a, 0)
						end)
						p:Destroy()
					end)
					wait(0.05)
				end	
			end,
		},
		["Ghost"] = {
			doDebounce = true,
			fn = function(PlayerData, board)
				local extraClasses = {
					effects = {"Smoke", "ParticleEmitter", "Fire"},
					tweenClasses = {"Decal"}
				}
				local parts = {}
				local effects = {}

				for i, obj in pairs(PlayerData.player.Character:GetDescendants()) do
					if (table.find(partTypes, obj.ClassName) or table.find(extraClasses.tweenClasses, obj.ClassName)) and obj.Transparency ~= 1 then
						table.insert(parts, {
							obj, 
							Utilities.lerpNumber(obj.Transparency, 1), 
							obj.Transparency
						})
					elseif table.find(extraClasses.effects, obj.ClassName) then
						obj.Enabled = false
						table.insert(effects, obj)
					end
				end

				Tween(1, nil, function(a)
					for i, v in pairs(parts) do
						local p, l = unpack(v)
						p.Transparency = l(a)
					end
				end)

				for i, v in pairs(parts) do
					local obj = v[1]
					parts[i] = {obj, Utilities.lerpNumber(1, v[3])}
				end

				wait(3) 

				delay(0.5, function()
					for i, effect in pairs(effects) do
						effect.Enabled = true
					end
				end)

				Tween(1, nil, function(a)
					for i, v in pairs(parts) do
						local p, l = unpack(v)
						p.Transparency = l(a)
					end
				end)
			end,

		},
	}
}
