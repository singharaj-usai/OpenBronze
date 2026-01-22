local Utilities = require(game.ReplicatedStorage.Utilities)
local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
local nova = workspace.Supernova
wait(15)
Utilities.sound(6255933126)
wait(1.5)
delay(0, function()
Utilities.sound(6255934214) end)
spawn(function()
	Utilities.FadeIn(0.5) end)
spawn(function()
	Utilities.Tween(0.2, nil, function(a)
		game.StarterGui.Formulas.First.ImageTransparency = 1 - 1 * a
	end)
	wait()
	Utilities.Tween(0.5, nil, function(a)
		game.StarterGui.Formulas.First.ImageTransparency = 0 + 1 * a
	end)
	Utilities.Tween(0.2, nil, function(a)
		game.StarterGui.Formulas.Third.ImageTransparency = 1 - 1 * a
	end)
	wait()
	Utilities.Tween(0.5, nil, function(a)
		game.StarterGui.Formulas.Third.ImageTransparency = 0 + 1 * a
	end)
	Utilities.Tween(0.2, nil, function(a)
		game.StarterGui.Formulas.Second.ImageTransparency = 1 - 1 * a
	end)
	wait()
	Utilities.Tween(0.5, nil, function(a)
		game.StarterGui.Formulas.Second.ImageTransparency = 0 + 1 * a
	end)
	Utilities.Tween(0.2, nil, function(a)
		game.StarterGui.Formulas.Forth.ImageTransparency = 1 - 1 * a
	end)
	wait()
	Utilities.Tween(0.5, nil, function(a)
		game.StarterGui.Formulas.Forth.ImageTransparency = 0 + 1 * a
	end)
end)
local cam = workspace.CurrentCamera
local missile = nova.Missile
local planet = nova.Planet
--cam.CameraType = Enum.CameraType.Scriptable
local sCam1 = CFrame.new(-72.7281265, -356.376221, -990.24176, -0.72100544, -0.105626032, 0.684831619, -0, 0.988313675, 0.152434036, -0.692929447, 0.109905772, -0.712579489)
local sCam2 = CFrame.new(-67.1381836, -364.965851, -849.597534, -0.791943491, -0.052584745, 0.608325839, -3.72528985e-09, 0.996284723, 0.0861205831, -0.610594332, 0.0682026371, -0.789001286)
local mis1 = CFrame.new(-84.6941757, -362.943512, -991.224243, 0.965925574, 0.257833987, -0.0225575641, -7.4505806e-09, 0.087155737, 0.99619472, 0.258819044, -0.962249875, 0.0841859952)
local mis2 = CFrame.new(-178.411362, -394.622772, -641.466858, 0.965925574, 0.257833987, -0.0225575641, -7.4505806e-09, 0.087155737, 0.99619472, 0.258819044, -0.962249875, 0.0841859952)
delay(0.4, function()
	planet.Rocks.Enabled = true
	wait(0.2)
	planet.Rocks.Enabled = false
end)
delay(0.6, function()
--	Utilities.sound(5782801042)
	Utilities.sound(6255936389, 0.3)
	local expEf = Instance.new("Explosion")
	expEf.BlastPressure = 0
	expEf.BlastRadius = 0
	expEf.DestroyJointRadiusPercent = 0
	expEf.Name = "Explosion2"
	expEf.Position = Vector3.new(-98.535, -368.877, -934.049)
	expEf.Parent = nova.Planet
	expEf.Visible = true
	planet.Explosion.Enabled = true
	planet.Beam.Enabled = true
	
end)
delay(1.8, function()
--	Utilities.sound(1577567682)
	nova.Sun.Biggest:destroy()
	nova.Sun.Biggest2:destroy()
	nova.Sun.Biggest3:destroy()
	nova.Sun.Lens:destroy()
	nova.Sun.Parent = game.Lighting
	nova.BlackBackground.Transparency = 0
	nova.BlackBackground2.Transparency = 0
	nova.BlackBackground3.Transparency = 0
	nova.BlackBackground4.Transparency = 0
	nova.X.Decal.Transparency = 0
	missile:destroy()
	wait(0.05)
	nova.X.Decal.Transparency = 1
	nova.Plus.Decal.Transparency = 0
	wait(0.05)
	nova.Plus.Decal.Transparency = 1
	nova.BlackBackground.Transparency = 1
	nova.BlackBackground2.Transparency = 1
	nova.BlackBackground3.Transparency = 1
	nova.BlackBackground4.Transparency = 1
	game.Lighting.Sun.Parent = nova
	nova.StartRing.Transparency = 0
	nova.Glow.Transparency = 0.8
	spawn(function()
		Utilities.Tween(0.2, "easeInCubic", function(a)
			nova.Shine2.Transparency = 1 -0.2 * a
		end)
		Utilities.Tween(0.2, "easeInCubic", function(a)
			nova.Shine2.Size = Vector3.new(328.696, 331.968, 0.05) - Vector3.new(328.696 * a, 331.968 * a, 0.05 * a)
		end)
	end)
	spawn(function()
		Utilities.Tween(0.3, "easeInCubic", function(a)
			nova.Glow.Size = Vector3.new(396.564, 53.489, 383.668) - Vector3.new(396.564 * a, 53.489 * a, 383.668 * a)
		end)
	end)
	nova.Sun:destroy()
	
	spawn(function()
		Utilities.Tween(0.3, "easeInCubic", function(a)
			nova.SunGlow.Size = Vector3.new(32.151, 32.151, 32.151) - Vector3.new(32.151 * a, 32.151 * a, 32.151 * a)
		end)
	end)
	Utilities.Tween(0.3, "easeInCubic", function(a)
		nova.StartRing.Size = Vector3.new(185.509, 0.05, 187.173) - Vector3.new(185.509 * a, 0.05 * a, 187.173 * a)
	end)
	wait(0.1)
	
	spawn(function()
		CameraShaker:BeginEarthquake(function(cf)
			cam.CFrame = cam.CFrame * cf
		end, 0.3)
		wait(0.5)
		CameraShaker:EndEarthquake(0.1)
	end)
	Utilities.sound(6255934893)
	spawn(function()
		Utilities.Tween(0.5, "easeInSine", function(a)
			nova.BlastRing.Size = Vector3.new(0, 0, 0) + Vector3.new(729.71 * a, 0.3 * a, 743.564 * a)
		end)
	end)
	spawn(function()
		Utilities.Tween(0.5, "easeInSine", function(a)
			nova.BlastRing.Transparency = 0 + 1 * a
		end)
	end)
	spawn(function()
		Utilities.Tween(3, "easeOutCubic", function(a)
			nova.BlastRing2.Size = Vector3.new(0, 0, 0) + Vector3.new(849.694 * a, 0.921 * a, 803.598 * a)
		end)
	end)
	spawn(function()
		Utilities.Tween(3, "easeOutCubic", function(a)
			nova.BlastRing2.Transparency = 0 + 1 * a
		end)
	end)
	spawn(function()
		nova.Effects.Glow1.Enabled = true
		nova.Effects.Glow2.Enabled = true
		nova.Effects.Glow3.Enabled = true
		wait(0.2)
		nova.Effect2.Glow1.Enabled = true
		nova.Effect2.Glow2.Enabled = true
	end)
	wait(1)
	cam.CFrame = CFrame.new(-5.09776592, -384.158295, -779.417603, 0.337045282, 0.00692439964, -0.941462994, -0, 0.999972999, 0.00735473633, 0.941488504, -0.00247887918, 0.337036133)
	spawn(function()
		delay(0.3, function()
		Utilities.sound(6255935707) end)
		
		Utilities.Tween(1, "easeInSine", function(a)
			nova.EarthDestroy.CFrame = nova.EarthDestroy.CFrame * CFrame.new(0, 0, 5 * a)
		end)
	end)
	spawn(function()

		Utilities.Tween(1, "easeInSine", function(a)
			nova.EarthDestroy2.CFrame = nova.EarthDestroy2.CFrame * CFrame.new(0, 0, 5 * a)
		end)
	end)
	delay(1, function()
		spawn(function()
			CameraShaker:BeginEarthquake(function(cf)
				cam.CFrame = cam.CFrame * cf
			end, 0.5)
			wait(1)
			CameraShaker:EndEarthquake(0.4)
		end)
			Utilities.Tween(0.7, nil, function(a)
				nova.DarkEarth.Transparency = 0.5 - 0.5 * a
			end)
			wait(0.3)
			local dPlanet = game.ReplicatedStorage.Models.Misc["Destroyed Planet"]:Clone()
		nova.DarkEarth:destroy()
		Utilities.sound(6255936389)
		dPlanet.Parent = nova
		delay(0, function()
			nova.Earth.Rocks.Enabled = true
			wait(0.2)
			nova.Earth.Rocks.Enabled = false
		end)
			Utilities.Tween(1, "easeOutCubic", function(a)
				Utilities.MoveModel(dPlanet.Main, dPlanet.Main.CFrame * CFrame.new(0, 0.02 * a, -0.02 * a))
		end)
		wait(0.5)
		cam.CFrame = CFrame.new(0, 0, 0)
		Utilities.sound(0)
		cam.CameraType = Enum.CameraType.Custom
		end)
		delay(1, function()
			Utilities.Tween(1, nil, function(a)
				nova.GlowBackground.Transparency = 1-1 * a
			end)
		end)
		delay(1, function()
			Utilities.Tween(1, nil, function(a)
				nova.Earth.Transparency = 0 + 1 * a
			end)
		end)
		
	
end)

spawn(function()
	Utilities.Tween(2, "easeInSine", function(a)
		missile.CFrame = mis1:Lerp(mis2, a)
	end)
end)
--spawn(function()
--	Utilities.Tween(2, "easeInSine", function(a)
--		cam.CFrame = sCam1:Lerp(sCam2, a)
--	end)
--end)
spawn(function()
	Utilities.Tween(2, "easeInSine", function(a)
		missile.CFrame = mis1:Lerp(mis2, a)
	end)
end)
wait(6)


