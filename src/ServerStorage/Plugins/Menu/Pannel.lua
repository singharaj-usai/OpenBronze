return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local _f = require(script.Parent)

	local pannel = {
		isOpen = false,
	}
	local gui, bg, close


	local function color(r, g, b)
		return Color3.new(r/255, g/255, b/255)
	end


	function pannel:open()
		if self.isOpen or not _p.MasterControl.WalkEnabled then return end
		self.isOpen = true

		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.Menu:disable() end)

		if not gui then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5227227347', -- 5217662406  340903755
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}
			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(68, 206, 54),--77, 42, 116),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 3, Parent = gui,
			}
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = close.gui,
					ZIndex = 4,
				}, Scaled = true,
			}				

			local Events = game.ReplicatedStorage.Events
			local Dev = Events.GetDevs:InvokeServer()			

			if Dev then

				local PokeBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.1, 0),
					ZIndex = 3, Parent = gui,
				}

				local poke = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					Text = 'Poke',
					PlaceholderText = 'Poke',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.1, 0),
					ZIndex = 4, Parent = gui
				}

				local LvlBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.1, 0),
					ZIndex = 3, Parent = gui,
				}

				local lvl = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = math.random(1,100),
					PlaceholderText = 'Level',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.1, 0),
					ZIndex = 4, Parent = gui
				}

				local Shiny = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.4--[[.7]], 0, 0.225, 0),
					Value = false,
					ZIndex = 3, Parent = gui,
				}



				local shin = false	

				Shiny.ValueChanged:connect(function()
					shin = Shiny.Value
				end)				

				write 'Shiny' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.05, 0, 0.25, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}

				local HA = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.85, 0, 0.225, 0),
					Value = false,
					ZIndex = 3, Parent = gui,
				}

				local AH

				HA.ValueChanged:connect(function()
					AH = HA.Value
				end)

				write 'HA' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.6, 0, 0.25, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}												  

				local HpBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.02, 0),
					ZIndex = 3, Parent = gui,
				}	

				local AttackBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.17, 0),
					ZIndex = 3, Parent = gui,
				}
				local DefenseBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.32, 0),
					ZIndex = 3, Parent = gui,
				}
				local SpAttackBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.47, 0),
					ZIndex = 3, Parent = gui,
				}
				local SpDeffenseBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.62, 0),
					ZIndex = 3, Parent = gui,
				}
				local SpeedBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.77, 0),
					ZIndex = 3, Parent = gui,
				}

				local HpBackEV = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.02, 0),
					ZIndex = 3, Parent = gui,
				}	

				local AttackBackEV = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.17, 0),
					ZIndex = 3, Parent = gui,
				}
				local DefenseBackEV = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.32, 0),
					ZIndex = 3, Parent = gui,
				}
				local SpAttackBackEV = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.47, 0),
					ZIndex = 3, Parent = gui,
				}
				local SpDeffenseBackEV = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.62, 0),
					ZIndex = 3, Parent = gui,
				}
				local SpeedBackEV = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.77, 0),
					ZIndex = 3, Parent = gui,
				}






				local NatureBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.343, 0),
					ZIndex = 3, Parent = gui,
				}				
				local IV1 = {'0','1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31',}
				local IV2 = {'0','1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31',}	
				local IV3 = {'0','1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31',}	
				local IV4 = {'0','1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31',}	
				local IV5 = {'0','1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31',}	
				local IV6 = {'0','1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31',}	

				local natures = {'Hardy','Lonely', 'Brave', 'Adamant', 'Naughty', 'Bold', 'Docile', 'Relaxed', 'Impish', 'Lax', 'Timid', 'Hasty', 'Serious', 'Jolly', 'Naive', 'Modest', 'Mild','Quiet','Bashful','Rash','Calm','Gentle','Sassy','Careful','Quirky'} 
				local pokeballs = {'pokeball','greatball', 'ultraball', 'masterball', 'colorlessball', 'insectball', 'dreadball', 'dracoball', 'zapball', 'fistball', 'flameball', 'skyball', 'spookyball', 'premierball', 'repeatball', 'meadowball', 'earthball','netball','diveball','luxuryball','icicleball','quickball','duskball','cherishball','toxicball','mindball','stoneball','steelball','splashball','pixieball','pumpkinball'}


				local HEALTH = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV1[math.random(#IV1)],
					Text = 'Health',
					PlaceholderText = 'Hp',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.02, 0),
					ZIndex = 4, Parent = gui
				}
				local HEALTHEV = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV1[math.random(#IV1)],
					Text = '0',
					PlaceholderText = 'Hp EV',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.02, 0),
					ZIndex = 4, Parent = gui
				}

				local ATTACK = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV2[math.random(#IV2)],
					Text = 'Attack',
					PlaceholderText = 'Attack',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.17, 0),
					ZIndex = 4, Parent = gui
				}
				local ATTACKEV = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV2[math.random(#IV2)],
					Text = '0',
					PlaceholderText = 'Attack EV',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.17, 0),
					ZIndex = 4, Parent = gui
				}
				local DEFENSE = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV3[math.random(#IV3)],
					Text = 'Defense',
					PlaceholderText = 'Defense',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.32, 0),
					ZIndex = 4, Parent = gui
				}
				local DEFENSEEV = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV3[math.random(#IV3)],
					Text = '0',
					PlaceholderText = 'Defense EV',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.32, 0),
					ZIndex = 4, Parent = gui
				}
				local SPATTACK = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV4[math.random(#IV4)],
					Text = 'Sp. Atk',
					PlaceholderText = 'Sp. Attack',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.47, 0),
					ZIndex = 4, Parent = gui
				}
				local SPATTACKEV = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV4[math.random(#IV4)],
					Text = '0',
					PlaceholderText = 'Sp. Attack EV',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.47, 0),
					ZIndex = 4, Parent = gui
				}
				local SPDEFENSE = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV5[math.random(#IV5)],
					Text = 'Sp. Def',
					PlaceholderText = 'Sp. Def',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.62, 0),
					ZIndex = 4, Parent = gui
				}
				local SPDEFENSEEV = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV5[math.random(#IV5)],
					Text = '0',
					PlaceholderText = 'Sp. Def EV',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.62, 0),
					ZIndex = 4, Parent = gui
				}	
				local SPEED = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV6[math.random(#IV6)],
					Text = 'Speed',
					PlaceholderText = 'Speed',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(-0.45, 0, 0.77, 0),
					ZIndex = 4, Parent = gui
				}	

				local SPEEDEV = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV6[math.random(#IV6)],
					Text = '0',
					PlaceholderText = 'Speed EV',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(1.10, 0, 0.77, 0),
					ZIndex = 4, Parent = gui
				}	

				local POKEFORME = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					--	Text = IV6[math.random(#IV6)],
					Text = 'Forme',
					PlaceholderText = 'Forme',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.453, 0),
					ZIndex = 4, Parent = gui
				}	







				local nature = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					Text = natures[math.random(#natures)],
					PlaceholderText = 'Nature',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.3415, 0),
					ZIndex = 4, Parent = gui
				}	

				local pokeballinput = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					Text = pokeballs[math.random(#pokeballs)],
					PlaceholderText = 'Pokeball',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					--	Position = UDim2.new(0.05, 0, 0.7, 0),
					Position = UDim2.new(0.05, 0, 0.575, 0),
					ZIndex = 4, Parent = gui
				}



				function GoodNature(given) -- Checks If The Given Nature Exists
					for i = 1, #natures do
						if string.lower(given) == string.lower(natures[i]) then
							return true
						end
					end
					return false
				end






--[[				
				function IV1(given) -- Checks If The Given Nature Exists
					for i = 1, #IV1 do
						if string.lower(given) == string.lower(IV1[i]) then
							return true
						end
					end
					return false
				end
				function IV2(given) -- Checks If The Given Nature Exists
					for i = 1, #IV2 do
						if string.lower(given) == string.lower(IV2[i]) then
							return true
						end
					end
					return false
				end
				function IV3(given) -- Checks If The Given Nature Exists
					for i = 1, #IV3 do
						if string.lower(given) == string.lower(IV3[i]) then
							return true
						end
					end
					return false
				end
				function IV4(given) -- Checks If The Given Nature Exists
					for i = 1, #IV4 do
						if string.lower(given) == string.lower(IV4[i]) then
							return true
						end
					end
					return false
				end
				function IV5(given) -- Checks If The Given Nature Exists
					for i = 1, #IV5 do
						if string.lower(given) == string.lower(IV5[i]) then
							return true
						end
					end
					return false
				end
				function IV6(given) -- Checks If The Given Nature Exists
					for i = 1, #IV6 do
						if string.lower(given) == string.lower(IV6[i]) then
							return true
						end
					end
					return false
				end
				
				function GetIV1Number(HEALTH)
					for i = 1, #natures do
						if string.lower(IV1[i]) == string.lower(IV1) then
							return i
						end
					end
				end	
				function GetIV2Number(ATTACK)
					for i = 1, #natures do
						if string.lower(IV2[i]) == string.lower(IV2) then
							return i
						end
					end
				end	
				function GetIV3Number(DEFENSE)
					for i = 1, #natures do
						if string.lower(IV3[i]) == string.lower(IV3) then
							return i
						end
					end
				end	
				function GetIV4Number(SPATTACK)
					for i = 1, #natures do
						if string.lower(IV4[i]) == string.lower(IV4) then
							return i
						end
					end
				end	
				function GetIV5Number(SPDEFENSE)
					for i = 1, #natures do
						if string.lower(IV5[i]) == string.lower(IV5) then
							return i
						end
					end
				end	
				function GetIV6Number(SPEED)
					for i = 1, #IV6 do
						if string.lower(IV6[i]) == string.lower(IV6) then
							return i
						end
					end
				end	
				]]--
				function GetNatureNumber(nature)
					for i = 1, #natures do
						if string.lower(natures[i]) == string.lower(nature) then
							return i
						end
					end
				end	

				function GetPokeballNumber(pokeball)
					for i = 1, #pokeballs do
						if string.lower(pokeballs[i]) == string.lower(pokeball) then
							return i
						end
					end
				end




				local Egg = _p.ToggleButton:new {
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.85, 0, 0.343, 0),
					Value = false,
					ZIndex = 3, Parent = gui,
				}

				local egg

				Egg.ValueChanged:connect(function()
					egg = Egg.Value
				end)

				write 'Egg' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.6, 0, 0.343, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}

				--// This Was For Genders But PC Fixes Em So No Use... \\--
				--local genders = {"Male", "Female", "Genderless"}
				--local gendersdata = {["Male"] = "M", ["Female"] = "F", ["Genderless"] = "G"}
				--local currentgender = 1

				--local GenderButton = _p.RoundedFrame:new {
				--	Button = true,
				--	BackgroundColor3 = Color3.new(.4, .4, .4),
				--	Size = UDim2.new(0.4, 0, 0.1, 0),
				--	Position = UDim2.new(0.55, 0, 0.343, 0),
				--	ZIndex = 3, Parent = gui,
				--	MouseButton1Click = function()
				--		if currentgender >= #genders then
				--			currentgender = 1
				--		else
				--			currentgender = currentgender + 1
				--		end
				--		gui.Gender.Text = genders[currentgender]
				--	end,
				--}

				--local Gender = create 'TextLabel' {
				--	BackgroundTransparency = 1.0,
				--	TextColor3 = Color3.new(.8, .8, .8),
				--	TextScaled = true,
				--	Text = genders[currentgender],
				--	Name = "Gender",
				--	Font = Enum.Font.SourceSansBold,
				--	Size = UDim2.new(0.4, 0, 0.1, 0),
				--	Position = UDim2.new(0.55, 0, 0.343, 0),
				--	ZIndex = 4, Parent = gui
				--}
--[[		Useful but im gonna try and make it look better	
				local IVBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(0, 0.6, 1),
					Size = UDim2.new(0.55, 0, 1.0, 0),
					Position = UDim2.new(-0.55, 0, 0, 0),
					ZIndex = 2, Parent = gui,
				}
		--]]	

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://6774574744', -- 5217662406  340903755
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(0.55, 0, 1.0, 0),
					Position = UDim2.new(-0.55, 0, 0, 0),
					ZIndex = 2, Parent = gui,
				}

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://6774577038', -- 5217662406  340903755
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(0.55, 0, 1.0, 0),
					Position = UDim2.new(1.0, 0, 0, 0),
					ZIndex = 2, Parent = gui,
				}


				local randomIVs = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.075, 0),
					Position = UDim2.new(-0.45, 0, 0.9, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()
						HEALTH.Text = IV1[math.random(#IV1)]
						ATTACK.Text = IV2[math.random(#IV2)]
						DEFENSE.Text = IV3[math.random(#IV3)]
						SPATTACK.Text = IV4[math.random(#IV4)]
						SPDEFENSE.Text = IV5[math.random(#IV5)]
						SPEED.Text = IV6[math.random(#IV6)]
					end,
				}

				local perfectIVs = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.05, 0, 0.075, 0),
					Position = UDim2.new(-0.525, 0, 0.9, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()
						HEALTH.Text = 31
						ATTACK.Text = 31
						DEFENSE.Text = 31
						SPATTACK.Text = 31
						SPDEFENSE.Text = 31
						SPEED.Text = 31
					end,
				}

				local ResetEV = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.05, 0, 0.075, 0),
					Position = UDim2.new(1.025, 0, 0.9, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()
						HEALTHEV.Text = 0
						ATTACKEV.Text = 0
						DEFENSEEV.Text = 0
						SPATTACKEV.Text = 0
						SPDEFENSEEV.Text = 0
						SPEEDEV.Text = 0
					end,
				}

				local EVEDITORBUTTON = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.075, 0),
					Position = UDim2.new(1.10, 0, 0.9, 0),
					ZIndex = 3, Parent = gui,
				}

				local HEALTHBUTTON = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.95, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()
						_p.NPCChat:say('Pokemon Healed!')
						_p.Network:get('PDS', 'getPartyPokeBalls')
					end,
				}
--[[
				local HEALTHBUTTONBACK = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.95, 0),
					ZIndex = 3, Parent = gui,
				}
				]]	
				write 'Heal Party' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.05, 0),
						Position = UDim2.new(0.55, 0, 0.975, 0),
						ZIndex = 3, Parent = gui,
					}, Scaled = true,
				}




				write '31' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.025, 0),
						Position = UDim2.new(-0.70, 0, 0.92, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}
				write '0' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.025, 0),
						Position = UDim2.new(0.85, 0, 0.92, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}



				write 'Random IVs' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.045, 0),
						Position = UDim2.new(-0.45, 0, 0.92, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}

				write 'EV Editor' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.045, 0),
						Position = UDim2.new(1.10, 0, 0.92, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}
				--				local EV1 = tonumber(HEALTHEV.Text)
				--				local EV2 = tonumber(ATTACKEV.Text)
				--				local EV3 = tonumber(DEFENSEEV.Text)
				--				local EV4 = tonumber(SPATTACKEV.Text)
				--				local EV5 = tonumber(SPDEFENSEEV.Text)
				--				local EV6 = tonumber(SPEEDEV.Text)


				--				local InvalidEVs = 0
				--				local MaxEV = 510
				--				local totalEV = (EV1 + EV2 + EV3 +EV4 + EV5 + EV6)
				--				if totalEV > MaxEV then
				--				InvalidEVs = 1
				--			else
				--					InvalidEVs = 0
				--			end		
				--				local formes = "Forme"
				--				local enabledforme = 0
				--			if POKEFORME.Text == formes then
				--				enabledforme = 0
				--			end
				---			if POKEFORME.Text ~= formes then
				--				enabledforme = 1
				--			end
				local pokemonitem = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					Text = 'Poke Item',
					PlaceholderText = 'Poke Item',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					--	Position = UDim2.new(0.05, 0, 0.575, 0),
					Position = UDim2.new(0.05, 0, 0.95, 0),
					ZIndex = 4, Parent = gui
				}

				local pokeitemback = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.95, 0),
					ZIndex = 3, Parent = gui,
				}





				local spawnButton = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.18, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.453, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()																
						if tonumber(lvl.Text) then
							if GoodNature(nature.text) then
								Events.PCPoke:InvokeServer({
									name = poke.Text or "Pikachu",
									level = tonumber(lvl.Text) or 1,
									pokeball = GetPokeballNumber(string.lower(pokeballinput.text)) or 1,
									shiny = shin or false,
									item = pokemonitem.Text,
									--	ot = 38658,
									ivs = {tonumber(HEALTH.Text),tonumber(ATTACK.Text),tonumber(DEFENSE.Text),tonumber(SPATTACK.Text),tonumber(SPDEFENSE.Text),tonumber(SPEED.Text)},
									evs = {tonumber(HEALTHEV.Text),tonumber(ATTACKEV.Text),tonumber(DEFENSEEV.Text),tonumber(SPATTACKEV.Text),tonumber(SPDEFENSEEV.Text),tonumber(SPEEDEV.Text)},
									nature = GetNatureNumber(string.lower(nature.text)) or natures[math.random(#natures)],
									egg = egg,
									hiddenAbility = AH or false,
								})

								_p.NPCChat:say('Added A Level '..lvl.Text.." "..poke.Text.." To Your PC!")
							else
								_p.NPCChat:say("Invalid Nature "..nature.Text)
							end

						else
							_p.NPCChat:say(lvl.Text.." Is Not A Valid Number!")
						end

					end,

				}

				local spawnButtonForme = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.18, 0, 0.1, 0),
					Position = UDim2.new(0.77, 0, 0.453, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()																
						if tonumber(lvl.Text) then
							if GoodNature(nature.text) then
								Events.PCPoke:InvokeServer({
									name = poke.Text or "Pikachu",
									level = tonumber(lvl.Text) or 1,
									pokeball = GetPokeballNumber(string.lower(pokeballinput.text)) or 1,
									shiny = shin or false,
									forme = POKEFORME.Text,
									item = pokemonitem.Text,
									ivs = {tonumber(HEALTH.Text),tonumber(ATTACK.Text),tonumber(DEFENSE.Text),tonumber(SPATTACK.Text),tonumber(SPDEFENSE.Text),tonumber(SPEED.Text)},
									evs = {tonumber(HEALTHEV.Text),tonumber(ATTACKEV.Text),tonumber(DEFENSEEV.Text),tonumber(SPATTACKEV.Text),tonumber(SPDEFENSEEV.Text),tonumber(SPEEDEV.Text)},
									nature = GetNatureNumber(string.lower(nature.text)) or natures[math.random(#natures)],
									egg = egg,
									hiddenAbility = AH or false,
								})

								_p.NPCChat:say('Added A Level '..lvl.Text.." "..POKEFORME.Text.." "..poke.Text.." To Your PC!")
							else
								_p.NPCChat:say("Invalid Nature "..nature.Text)
							end

						else
							_p.NPCChat:say(lvl.Text.." Is Not A Valid Number!")
						end

					end,

				}





				--	ivs = {GetIV1Number(string.lower(IV1.text)) or IV1[math.random(#IV1)], GetIV2Number(string.lower(IV2.text)) or IV2[math.random(#IV2)],GetIV3Number(string.lower(IV3.text)) or IV3[math.random(#IV3)], GetIV4Number(string.lower(IV4.text)) or IV4[math.random(#IV4)], GetIV5Number(string.lower(IV5.text)) or IV5[math.random(#IV5)],GetIV6Number(string.lower(IV6.text)) or IV6[math.random(#IV6)]},
				--	ivs = {31, 31, 31, 31, 31, 31},
				--		if GoodNature(nature.text) and IV1(IV1.text) and IV2(IV2.text) and IV3(IV3.text) and IV4(IV4.text) and IV5(IV5.text) and IV6(IV6.text) then


				write 'Spawn' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.55, 0, 0.035, 0),
						Position = UDim2.new(0.35, 0, 0.475, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}

				write 'Spawn' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.55, 0, 0.025, 0),
						Position = UDim2.new(0.60, 0, 0.475, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}

				write 'Forme' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.55, 0, 0.025, 0),
						Position = UDim2.new(0.60, 0, 0.51, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}



				local ItemBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.575, 0),
					ZIndex = 3, Parent = gui,
				}

				local FormeBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.453, 0),
					ZIndex = 3, Parent = gui,
				}

				local item = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true, 
					ClearTextOnFocus = false,
					Text = 'Item',
					PlaceholderText = 'Item',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					--	Position = UDim2.new(0.05, 0, 0.575, 0),
					Position = UDim2.new(0.05, 0, 0.7, 0),
					ZIndex = 4, Parent = gui
				}





				local pokeballback = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.7, 0),
					ZIndex = 3, Parent = gui,
				}



				local AmountBack = _p.RoundedFrame:new {
					Button = false,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.575, 0),
					ZIndex = 3, Parent = gui,
				}

				local amount = create 'TextBox' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					ClearTextOnFocus = false,
					Text = 'Amount',
					PlaceholderText = 'Amount',
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.575, 0),
					ZIndex = 4, Parent = gui
				}


				local GiveButton = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.7, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()
						if tonumber(amount.text) then
							local data = {name = item.Text, number = amount.Text}
							Events.Item:InvokeServer(data)
							_p.NPCChat:say("Added "..amount.Text.."x "..item.Text.." In Your Bag")
						else
							_p.NPCChat:say(amount.Text.." Is Not A Valid Number!")
						end					
					end,
				}
				-- [[				
				local UMVButton = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.9, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()

						self:addBagItems({id = 'umvbattery', quantity = 6})
						_p.NPCChat:say("Added UMV Batteries In Your Bag")

					end,
				}
				--	]]



				--			self:addBagItems({id = 'umvbattery', quantity = 6})




				write 'Give' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.725, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}				

				local openables = {"PC", "Shop", "Stone Shop", "BP Shop"}

				local c = 1				

				local ToOpnButton = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.825, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()
						if c >= #openables then
							c = 1
						else
							c = c + 1
						end
						gui.ToOpen.Text = openables[c]
					end,
				}

				local ToOpen = create 'TextLabel' {
					BackgroundTransparency = 1.0,
					TextColor3 = Color3.new(.8, .8, .8),
					TextScaled = true,
					Text = openables[c],
					Name = "ToOpen",
					Font = Enum.Font.SourceSansBold,
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.05, 0, 0.825, 0),
					ZIndex = 4, Parent = gui
				}			

				local opening = {
					["PC"] = function() 
						_p.Menu.pc:bootUp()
					end
					, 
					["Shop"] = function()
						_p.Menu.shop:open()
					end, 
					["Stone Shop"] = function()
						_p.Menu.shop:open('stnshp')
					end, 
					["BP Shop"] = function()
						_p.Menu.battleShop:open()
					end}

				local OpnButton = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(0.4, 0, 0.1, 0),
					Position = UDim2.new(0.55, 0, 0.825, 0),
					ZIndex = 3, Parent = gui,
					MouseButton1Click = function()
						self:close()
						opening[openables[c]]()
					end,
				}

				write 'Open' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.4, 0, 0.05, 0),
						Position = UDim2.new(0.55, 0, 0.850, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true, Color = Color3.new(.8, .8, .8),
				}

				-- Old Open UI (Decided To Keep It If I Ever Need It Again Lol)

				--write 'Open...' {
				--	Frame = create 'Frame' {
				--		BackgroundTransparency = 1.0,
				--		Size = UDim2.new(0.4, 0, 0.05, 0),
				--		Position = UDim2.new(0.3, 0, 0.675, 0),
				--		ZIndex = 4, Parent = gui,
				--	}, Scaled = true,
				--}

				--local PCButton = _p.RoundedFrame:new {
				--	Button = true,
				--	BackgroundColor3 = Color3.new(.4, .4, .4),
				--	Size = UDim2.new(0.4, 0, 0.1, 0),
				--	Position = UDim2.new(0.05, 0, 0.775, 0),
				--	ZIndex = 3, Parent = gui,
				--	MouseButton1Click = function()

				--	end,
				--}

				--write 'PC' {
				--	Frame = create 'Frame' {
				--		BackgroundTransparency = 1.0,
				--		Size = UDim2.new(0.4, 0, 0.05, 0),
				--		Position = UDim2.new(0.05, 0, 0.8, 0),
				--		ZIndex = 4, Parent = gui,
				--	}, Scaled = true, Color = Color3.new(.8, .8, .8),
				--}

				--local ShopButton = _p.RoundedFrame:new {
				--	Button = true,
				--	BackgroundColor3 = Color3.new(.4, .4, .4),
				--	Size = UDim2.new(0.4, 0, 0.1, 0),
				--	Position = UDim2.new(0.55, 0, 0.775, 0),
				--	ZIndex = 3, Parent = gui,
				--	MouseButton1Click = function()

				--	end,
				--}	
				--write 'Shop' {
				--	Frame = create 'Frame' {
				--		BackgroundTransparency = 1.0,
				--		Size = UDim2.new(0.4, 0, 0.05, 0),
				--		Position = UDim2.new(0.55, 0, 0.8, 0),
				--		ZIndex = 4, Parent = gui,
				--	}, Scaled = true, Color = Color3.new(.8, .8, .8),
				--}

				--local MegastoneShopButton = _p.RoundedFrame:new {
				--	Button = true,
				--	BackgroundColor3 = Color3.new(.4, .4, .4),
				--	Size = UDim2.new(0.4, 0, 0.1, 0),
				--	Position = UDim2.new(0.55, 0, 0.9, 0),
				--	ZIndex = 3, Parent = gui,
				--	MouseButton1Click = function()

				--	end,
				--}

				--write 'Stone Shop' {
				--	Frame = create 'Frame' {
				--		BackgroundTransparency = 1.0,
				--		Size = UDim2.new(0.4, 0, 0.05, 0),
				--		Position = UDim2.new(0.55, 0, 0.925, 0),
				--		ZIndex = 4, Parent = gui,
				--	}, Scaled = true, Color = Color3.new(.8, .8, .8),
				--}

				--local BPShopButton = _p.RoundedFrame:new {
				--	Button = true,
				--	BackgroundColor3 = Color3.new(.4, .4, .4),
				--	Size = UDim2.new(0.4, 0, 0.1, 0),
				--	Position = UDim2.new(0.05, 0, 0.9, 0),
				--	ZIndex = 3, Parent = gui,
				--	MouseButton1Click = function()

				--	end,
				--}

				--write 'BP Shop' {
				--	Frame = create 'Frame' {
				--		BackgroundTransparency = 1.0,
				--		Size = UDim2.new(0.4, 0, 0.05, 0),
				--		Position = UDim2.new(0.05, 0, 0.925, 0),
				--		ZIndex = 4, Parent = gui,
				--	}, Scaled = true, Color = Color3.new(.8, .8, .8),
				--}

				--write 'Theme' {
				--	Frame = create 'Frame' {
				--		BackgroundTransparency = 1.0,
				--		Size = UDim2.new(0.0, 0, 0.05, 0),
				--		Position = UDim2.new(0.05, 0, 0.55, 0),
				--		ZIndex = 3, Parent = gui,
				--	}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				--}

				--				local Themes = {

				--					["Blue"] = {						
				--						Back = 5220782424,						
				--						Button = BrickColor.new('Deep blue').Color,						
				--					},	

				--					["Pink"] = {						
				--						Back = 5217661132,						
				--						Button = color(152, 44, 121),						
				--					},

				--					["Yellow"] = {						
				--						Back = 5222846494,						
				--						Button = Color3.new(.9, .625, 0),						
				--					},	

				--					["Green"] = {
				--						Back = 5227227373,
				--						Button = Color3.fromRGB(68, 206, 54),
				--					},

				--				}

				--				local ThemeOrder = {
				--					"Blue",
				--					"Pink",					
				--					"Yellow",
				--					"Green",
				--				}

				--				local CurrentTheme = 1				

				--				local theme = create 'ImageButton' {
				--					BackgroundTransparency = 0, 
				--					Image = 'rbxassetid://5217661132',
				--					Name = "Theme",
				--					BorderColor3 = Color3.fromRGB(0, 0, 0),
				--					BorderSizePixel = 3,
				--					Size = UDim2.new(0, 70, 0, 70),
				--					Position = UDim2.new(0.55, 0, 0.5, 0),
				--					ZIndex = 4, Parent = gui,
				--					MouseButton1Click = function()
				--						local ThemeN = ThemeOrder[CurrentTheme + 1]
				--						local ThemeData = Themes[ThemeN]

				--						print(ThemeN)

				--						close.BackgroundColor3 = ThemeData.Button
				--						gui.Image = "rbxassetid://"..ThemeData.Back

				--						print(CurrentTheme)

				--						if CurrentTheme == #ThemeOrder then
				--							gui.Theme.Image = "rbxassetid://"..Themes[1].Back
				--							CurrentTheme = 1
				--						else							
				--							CurrentTheme = CurrentTheme + 1
				--							gui.Theme.Image = "rbxassetid://"..Themes[ThemeOrder[CurrentTheme + 2]].Back
				--						end
				----						

				--					end
				--				}




			end
			close.gui.MouseButton1Click:connect(function()
				self:close()
			end)
		end

		bg.Parent = Utilities.gui
		gui.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpen then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui.Position = UDim2.new(1-.5*a, -gui.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function pannel:close()
		if not self.isOpen then return end
		self.isOpen = false

		spawn(function() _p.Menu:enable() end)

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if self.isOpen then return false end
			bg.BackgroundTransparency = .7+.3*a
			gui.Position = UDim2.new(.5+.5*a, -gui.AbsoluteSize.X/2*(1-a), 0.05, 0)
		end)
		bg.Parent = nil
		gui.Parent = nil

		_p.MasterControl.WalkEnabled = true
		--_p.MasterControl:Start()

	end

	function pannel:fastClose(enableWalk)
		if not self.isOpen then return end
		self.isOpen = false

		spawn(function() _p.Menu:enable() end)

		bg.BackgroundTransparency = 1.0
		gui.Position = UDim2.new(1.0, 0, 0.05, 0)
		bg.Parent = nil
		gui.Parent = nil

		if enableWalk then
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()

		end
	end


	return pannel end