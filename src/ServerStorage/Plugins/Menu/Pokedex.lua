return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
local Utilities = _p.Utilities
local create = Utilities.Create
local write = Utilities.Write
local MasterControl = _p.MasterControl

local pokedex = {}
local N_MAX_DEX = 1025 --increase this whenever new pokemons get added each generations

local function color(r, g, b)
	return Color3.new(r/255, g/255, b/255)
end

local BACKGROUND_COLOR = color(90, 170, 221)--color(27, 169, 222)
local GRID_COLOR = color(72, 94, 150)--color(33, 97, 195)--BrickColor.new('Deep blue').Color--color(34, 131, 222)
local ENTRY_THEME_COLOR = Color3.new(.7, .8, .9)
local ENTRY_TEXT_COLOR = GRID_COLOR

local background, gui, iconContainer, entryContainer, rightTray, leftTray, topTray, backButton
local squares = Vector2.new(6, 4)
local currentPage
local zoom = 2
local busy = false
local entryThread

function pokedex:showPokemonEntry(num, limited)
	if busy then return end
	busy = true
	local thisThread = {}
	entryThread = thisThread
	local f = create 'Frame' {
		BorderSizePixel = 0,
		BackgroundColor3 = BACKGROUND_COLOR,
		Size = iconContainer.Size,--UDim2.new(1.0, 0, 1.0, 0),
		Position = iconContainer.Position,
		ZIndex = 5, Parent = entryContainer,
	}
	local content = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Parent = entryContainer,
	}
	local idContainer = _p.RoundedFrame:new {
		CornerRadius = gui.CornerRadius,
		BackgroundColor3 = ENTRY_THEME_COLOR,
		Size = UDim2.new(0.5, 0, 0.2, 0),
		Position = UDim2.new(0.475, 0, 0.05, 0),
		ZIndex = 6, Parent = content,
	}
	if not limited then
		create 'ImageLabel' {
			Name = 'OwnedIcon',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6142797841',
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.4, 0, 0.4, 0),
			Position = UDim2.new(0.025, 0, 0.05, 0),
			ZIndex = 7, Parent = idContainer.gui,
		}
	end
	local dimContainer = _p.RoundedFrame:new {
		CornerRadius = gui.CornerRadius,
		BackgroundColor3 = ENTRY_THEME_COLOR,
		Size = UDim2.new(0.3, 0, 0.2, 0),
		Position = UDim2.new(0.65, 0, 0.3, 0),
		ZIndex = 6, Parent = content,
	}
	write 'Ht' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.25, 0),
			Position = UDim2.new(0.05, 0, 0.125, 0),
			ZIndex = 7, Parent = dimContainer.gui,
		},
		Scaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Color = ENTRY_TEXT_COLOR,
	}
	write 'Wt' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.25, 0),
			Position = UDim2.new(0.05, 0, 0.625, 0),
			ZIndex = 7, Parent = dimContainer.gui,
		},
		Scaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Color = ENTRY_TEXT_COLOR,
	}
	if limited then
		write '??? pokemon' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.3, 0),
				Position = UDim2.new(0.025, 0, 0.6, 0),
				ZIndex = 7, Parent = idContainer.gui,
			},
			Scaled = true,
			Color = ENTRY_TEXT_COLOR,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
		write '???' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.3, 0, 0.125, 0),
				ZIndex = 7, Parent = dimContainer.gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Color = ENTRY_TEXT_COLOR,
		}
		write '???' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.3, 0, 0.625, 0),
				ZIndex = 7, Parent = dimContainer.gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Color = ENTRY_TEXT_COLOR,
		}
	end
	local descContainer = _p.RoundedFrame:new {
		CornerRadius = gui.CornerRadius,
		BackgroundColor3 = ENTRY_THEME_COLOR,
		Size = UDim2.new(0.975, 0, 0.325, 0),
		Position = UDim2.new(0.0125, 0, 0.65, 0),
		ZIndex = 6, Parent = content,
	}
	local rframes = {idContainer, dimContainer, descContainer}
	local animation
	Utilities.fastSpawn(function()
		local pdata = _p.DataManager:getData('Pokedex', num)
		if entryThread ~= thisThread then return end
		local ns = tostring(num)
		ns = string.rep('0', 3-ns:len())..ns
		write(ns..' '..pdata.species) {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.3, 0),
				Position = UDim2.new(0.15, 0, 0.1, 0),
				ZIndex = 7, Parent = idContainer.gui,
			},
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Color = ENTRY_TEXT_COLOR,
		}
		Utilities.fastSpawn(function()
			local sd = _p.DataManager:getSprite('_FRONT', pdata.species)
			if entryThread ~= thisThread then return end
			animation = _p.AnimatedSprite:new(sd)
			local container = create 'Frame' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.65, 0, 0.6, 0),
				Position = UDim2.new(.05, 0, .025, 0),
				Parent = content,
			}
			local sprite = animation.spriteLabel
			sprite.Parent = container
			sprite.ZIndex = 6
			local x = sd.fWidth/110
			local y = sd.fHeight/110
			sprite.Size = UDim2.new(x, 0, y, 0)
			sprite.Position = UDim2.new(0.5-x/2, 0, 1-y, 0)
			animation:Play()
		end)
		if not limited then
			Utilities.fastSpawn(function()
				local xd = _p.DataManager:getData('PokedexExtended', Utilities.rc4(pdata.id))
				if entryThread ~= thisThread then return end
				write(xd.class .. ' pokemon') {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.3, 0),
						Position = UDim2.new(0.025, 0, 0.6, 0),
						ZIndex = 7, Parent = idContainer.gui,
					},
					Scaled = true,
					Color = ENTRY_TEXT_COLOR,
					TextXAlignment = Enum.TextXAlignment.Left,
				}
				local df = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.975, 0, 0.15, 0),
					Position = UDim2.new(0.0125, 0, 0.05, 0),
					ZIndex = 7, Parent = descContainer.gui,
				}
				local dt = write(xd.desc) {
					Frame = df,
					Wraps = true,
					Color = ENTRY_TEXT_COLOR,
				}
				if dt.MaxBounds.Y > descContainer.gui.AbsoluteSize.Y then
					df:ClearAllChildren()
					df.Size = UDim2.new(0.975, 0, 0.12, 0)
					local dt = write(xd.desc) {
						Frame = df,
						Wraps = true,
						Color = ENTRY_TEXT_COLOR,
					}
				end
			end)
			write(string.format('%.1fm', pdata.heightm)) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.25, 0),
					Position = UDim2.new(0.3, 0, 0.125, 0),
					ZIndex = 7, Parent = dimContainer.gui,
				},
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = ENTRY_TEXT_COLOR,
			}
			write(string.format('%.1fkg', pdata.weightkg)) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.25, 0),
					Position = UDim2.new(0.3, 0, 0.625, 0),
					ZIndex = 7, Parent = dimContainer.gui,
				},
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Color = ENTRY_TEXT_COLOR,
			}
			for i, t in pairs(_p.Pokemon:getTypes(pdata.types)) do
				local rf = _p.RoundedFrame:new {
					BackgroundColor3 = _p.BattleGui.typeColors[t],
					Size = UDim2.new(0.2, 0, 0.075, 0),
					Position = UDim2.new(0.525+0.225*(i-1), 0, 0.55, 0),
					ZIndex = 6, Style = 'HorizontalBar', Parent = content,
				}
				write (t) {
					Frame = create 'Frame' {
						Parent = rf.gui, ZIndex = 4, BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.7, 0),
						Position = UDim2.new(0.5, 0, 0.15, 0),
						ZIndex = 7, Parent = rf.gui,
					}, Scaled = true,
				}
				table.insert(rframes, rf)
			end
		end
	end)
	Utilities.Tween(.5, 'easeOutCubic', function(a)
		f.BackgroundTransparency = 1-a
		content.Position = UDim2.new(0.0, 0, a-1, 0)
		leftTray.Position = UDim2.new(0.05-.2*a, 0, 0.1, 0)
		rightTray.Position = UDim2.new(.85-.2*a, 0, 0.1, 0)
	end)
	backButton.MouseButton1Click:wait()
	entryThread = nil
	Utilities.Tween(.5, 'easeOutCubic', function(a)
		f.BackgroundTransparency = a
		content.Position = UDim2.new(0.0, 0, -a, 0)
		leftTray.Position = UDim2.new(-.15+.2*a, 0, 0.1, 0)
		rightTray.Position = UDim2.new(.65+.2*a, 0, 0.1, 0)
	end)
	for _, rf in pairs(rframes) do
		rf:remove()
	end
	content:remove()
	f:remove()
	busy = false
end

local getIcon; do
		local skip = { 4,   8,   9,  13,  70, 100, 122, 135, 139, 152, 161, 162, 194,
			215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228,
			229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241,
			253, 256, 272, 292, 302, 328, 350, 354, 357, 360, 402, 403, 404,
			408, 414, 436, 438, 444, 445, 446, 473, 474, 476, 477, 486, 488, 490,
			513, 517, 530, 550, 551, 552, 553, 554, 563, 569, 599, 629, 635,
			666, 667, 668, 670, 671, 672, 679, 681, 730, 732, 736, 738, 739, 741, 743,
			762, 763, 764, 765, 766, 767, 768, 769, 770, 771,
			772, 773, 774, 775, 776, 777, 778, 779, 780,
			783, 785, 786, 787, 788, 790, 791, 792, 793, 794, 796, 797, 798, 799, -- removed 791,792 add back
			805, 806, 807, 808, 809, 810, 811, 812, 813,
			816, 820, 856,
			862, 863, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877,
			878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894,915,916,917,922,924,953,954,955,956,957,958,959,987, 989,990, 991,992,
			993, 994, 995, 996, 997, 998, 999, 
			1000, 1001, 1002, 1003, 1004, 1012, 1019, 1020, 1021, 1022,
			1023, 1024, 1025, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1131, 1132, 1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 1144, 1145, 1146, 1147, 1151, 1152, 1153, 1154, 1155,
			1154, 1155, 1156, 1157, 1158, 1159, 1160, 1161, 1162, 1163, 1164, 1165, 1166, 1167, 1168, 1169, 1170, 1171, 1172, 1173, 1174, 1175, 1176, 1177, 1178, 1179, 1180, 1181, 1182, 1183, 1184, 1185, 1186, 1187, 1188, 1189, 1190, 1191, 1192,
			1193, 1194, 1195, 1196, 1197, 1198, 1199, 1200, 1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, -- 1217, -- 1218,
			1223, 1227, 1228, 1229, 1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1239, 1240, 1241, 1242, 1243, 1244, 1245, 1246,
			1258, 1268, 1275, 1276, 1277, 1311, 1326, 1327, 1332, 1349, 1360, 1361, 1362, 1363,
			1366, 1367, 1368, 1369, 1370, 1371, 1372, 1373, 1374, 1385, 1386
			}
			--1104,1105,1106,1107,1108,1109,1110,1111,1112,1113,1114,1115,1116,1117,1118,1119,1120,1121,1122,1123,1124,1125,1126,1127,1128,1129,1130,1131,1132,1135,1136,1137,1138,1139,1140,1141,1142,1143,1144,1145,1146,1147} --1147 

	getIconNumbers = function(lowerBound, upperBound)
--		print(lowerBound, upperBound)
		local iconNumbers = {}
		-- n is
		-- i is
		-- s is the current skip index
		local n, i, s = 1, 1, 1
		for goal = lowerBound, upperBound do
			while skip[s] and skip[s] <= goal+i-n do
				local d = (skip[s] - (skip[s-1] or 0) - 1)
				n = n + d
				i = i + d + 1
				s = s + 1
			end
			i = i + (goal-n)
			n = goal
			table.insert(iconNumbers, i)
		end
--		print(unpack(iconNumbers))
		return iconNumbers
	end
end

function pokedex:viewPage(p)
	local dex = self.dexData
	if not dex then return end
	
	currentPage = p
	iconContainer:ClearAllChildren()
	local x, y = squares.X, squares.Y
	local a = x*y
	
	local iconNumbers = getIconNumbers((p-1)*a+1, p*a)
	for i = 0, a-1 do
		local n = (p-1)*a+i+1
		if n > N_MAX_DEX then break end
		local f = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1/x, 0, 1/y, 0),
			Position = UDim2.new((i%x)/x, 0, math.floor(i/x)/y, 0),
			Parent = iconContainer,
		}
		if zoom <= 5 then
			local ns = tostring(n)
			ns = string.rep('0', 3-ns:len())..ns
			write(ns) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.2, 0),
					Position = UDim2.new(0.95, 0, 0.05, 0),
					ZIndex = 4, Parent = f,
				},
				Scaled = true,
				Color = GRID_COLOR,
				TextXAlignment = Enum.TextXAlignment.Right,
			}
		end
		if dex[n*2-1] == 1 then
			local icon = _p.Pokemon:getIcon(iconNumbers[i+1]-1)
			icon.SizeConstraint = Enum.SizeConstraint.RelativeXX
			icon.Size = UDim2.new(1.0, 0, -3/4, 0)
			icon.Position = UDim2.new(0.0, 0, 1.0, 0)
			icon.ZIndex = 4
			icon.Parent = f
			if dex[n*2] == 1 then
				create 'ImageLabel' {
					Name = 'OwnedIcon',
					BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6142797841',
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(0.2, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.05, 0),
					ZIndex = 4, Parent = f,
				}
				f.MouseButton1Click:connect(function()
					self:showPokemonEntry(n)
				end)
			else
				icon.ImageTransparency = .5
				f.MouseButton1Click:connect(function()
					self:showPokemonEntry(n, true)
				end)
			end
		end
	end
end

local function zoomIn()
	if zoom <= 1 then return end
	zoom = zoom - 1
	squares = Vector2.new(zoom*3, zoom*2)
	pokedex:redrawGrid()
	pokedex:viewPage(currentPage)
end

local function zoomOut()
	if zoom >= 11 then return end
	zoom = zoom + 1
	squares = Vector2.new(zoom*3, zoom*2)
	pokedex:redrawGrid()
	pokedex:viewPage(math.min(currentPage, math.floor(N_MAX_DEX/(squares.X*squares.Y))+1))
end
	
	
	--this might be useful... v	
	-- [[
game:GetService('UserInputService').InputBegan:connect(function(inputObject)
	if not gui then return end
	for i, n in pairs({'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Zero'}) do
		if inputObject.KeyCode == Enum.KeyCode[n] then
			pokedex:viewPage(i)
			return
		end
	end
	if inputObject.KeyCode == Enum.KeyCode.Minus then
		zoomIn()
	elseif inputObject.KeyCode == Enum.KeyCode.Equals then
		zoomOut()
	end
end)
--]]
function pokedex:read(data)
	local buffer = _p.BitBuffer.Create()
	buffer:FromBase64(data)
	self.dexData = buffer:GetData()
end

function pokedex:open()
	spawn(function() _p.Menu:disable() end)
	_p.MasterControl.WalkEnabled = false
	_p.MasterControl:Stop()
	
	local dex
	Utilities.fastSpawn(function() dex = _p.Network:get('PDS', 'getDex') end)
	
	if not gui then
		background = create 'ImageButton' {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = Utilities.gui,
		}
		local aspectRatio = 1.5
		gui = _p.RoundedFrame:new {
			BackgroundColor3 = BACKGROUND_COLOR,--Color3.new(1, 1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.7*aspectRatio, 0, 0.7, 0),
			Position = UDim2.new(0.0, 0, 0.15, 0),
			ZIndex = 3, Parent = Utilities.gui,
		}
		local outerSize = .05--.0625
		local outerBorder = _p.RoundedFrame:new {
			BackgroundColor3 = color(237, 52, 57),
			Size = UDim2.new(1+outerSize/aspectRatio*2, 0, 1+outerSize*2, 0),
			Position = UDim2.new(-outerSize/aspectRatio, 0, -outerSize, 0),
			Parent = gui.gui,
		}
		local innerSize = .025
		local innerBorder = _p.RoundedFrame:new {
			BackgroundColor3 = color(147, 20, 37),
			Size = UDim2.new(1+innerSize/aspectRatio*2, 0, 1+innerSize*2, 0),
			Position = UDim2.new(-innerSize/aspectRatio, 0, -innerSize, 0),
			ZIndex = 2, Parent = gui.gui,
		}
		local grid = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = gui.gui,
		}
		iconContainer = create 'Frame' {
			BackgroundTransparency = 1.0,
			Parent = gui.gui,
		}
		entryContainer = create 'Frame' {
			ClipsDescendants = true,
			BackgroundTransparency = 1.0,
			Parent = gui.gui,
		}
		leftTray = _p.RoundedFrame:new {
			BackgroundColor3 = outerBorder.BackgroundColor3,
			Size = UDim2.new(0.3, 0, 0.8/5, 0),
			Position = UDim2.new(0.15, 0, 0.1, 0),
			Parent = gui.gui,
		}
		do
			backButton = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(.75, 0, .75, 0),
				Position = UDim2.new(0.05, 0, 0.125, 0),
				Rotation = 90,
				Parent = leftTray.gui,
			}
			write 'v' { -- back
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Position = UDim2.new(0.175, 0, 0.0, 0),
					Parent = backButton,
				}, Scale = true,
			}
		end
		rightTray = _p.RoundedFrame:new {
			BackgroundColor3 = outerBorder.BackgroundColor3,
			Size = UDim2.new(0.3, 0, 0.8, 0),
			Parent = gui.gui,
		}
		write 'X' {
			Frame = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-.15, 0, .15, 0),
				Position = UDim2.new(0.95, 0, 0.025, 0),
				Parent = rightTray.gui,
				MouseButton1Click = function()
					if busy then return end
					self:close()
				end,
			}, Scale = true, Color = innerBorder.BackgroundColor3,
		}
		write '+' {
			Frame = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-.15, 0, .15, 0),
				Position = UDim2.new(0.95, 0, 0.425, 0),
				Parent = rightTray.gui,
				MouseButton1Click = function()
					if busy then return end
					zoomIn()
				end,
			}, Scale = true, Color = color(61, 149, 77),
		}
		do
			local b = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-.15, 0, .15, 0),
				Position = UDim2.new(0.95, 0, 0.625, 0),
				Parent = rightTray.gui,
				MouseButton1Click = function()
					if busy then return end
					zoomOut()
				end,
			}
			write '-' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Position = UDim2.new(0.2, 0, 0.0, 0),
					Parent = b,
				}, Scale = true, Color = color(61, 149, 77),
			}
		end
		do
			local b = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-.15, 0, .15, 0),
				Position = UDim2.new(0.95, 0, 0.225, 0),
				Rotation = 180,
				Parent = rightTray.gui,
				MouseButton1Click = function()
					if busy then return end
					local p = math.max(currentPage - 1, 1)
					if p ~= currentPage then
						self:viewPage(p)
					end
				end,
			}
			write 'v' { -- up
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					Position = UDim2.new(0.225, 0, 0.0, 0),
					Parent = b,
				}, Scale = true, Color = GRID_COLOR,
			}
		end
		write 'v' {
			Frame = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(-.15, 0, .15, 0),
				Position = UDim2.new(0.95, 0, 0.825, 0),
				Parent = rightTray.gui,
				MouseButton1Click = function()
					if busy then return end
					local p = math.min(currentPage + 1, math.floor(N_MAX_DEX/(squares.X*squares.Y))+1)
					if p ~= currentPage then
						self:viewPage(p)
					end
				end,
			}, Scale = true, Color = GRID_COLOR,
		}
		topTray = _p.RoundedFrame:new {
			BackgroundColor3 = outerBorder.BackgroundColor3,
			Size = UDim2.new(0.6, 0, 0.3, 0),
			Parent = gui.gui,
		}
		write 'Pokedex' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.35, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				Parent = topTray.gui,
			}, Scaled = true, Color = innerBorder.BackgroundColor3,
		}
		
		local function update(prop)
			if prop ~= 'AbsoluteSize' then return end
			gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, gui.Position.Y.Scale, 0)
			local c = Utilities.gui.AbsoluteSize.Y*.02
			gui.CornerRadius = c
			local gh = gui.AbsoluteSize.Y
			outerBorder.CornerRadius = c+(outerBorder.gui.AbsoluteSize.Y-gh)/2
			innerBorder.CornerRadius = c+(innerBorder.gui.AbsoluteSize.Y-gh)/2
			rightTray.CornerRadius = c
			leftTray.CornerRadius = c
			topTray.CornerRadius = c
			grid:ClearAllChildren()
			local gw = math.max(1, math.floor(gh*.02/zoom))
			local mx = squares.X+.5
			for x = 1, squares.X+1 do
				local f = create 'Frame' {
					BorderSizePixel = 0,
					BackgroundColor3 = GRID_COLOR,
					Size = UDim2.new(0.0, gw, 1.0, -gw*2),
					Position = UDim2.new((x-.75)/mx, -math.floor(gw/2), 0.0, gw),
					ZIndex = 6, Parent = grid,
				}
			end
			local my = squares.Y+.5
			for y = 1, squares.Y+1 do
				local f = create 'Frame' {
					BorderSizePixel = 0,
					BackgroundColor3 = GRID_COLOR,
					Size = UDim2.new(1.0, -gw*2, 0.0, gw),
					Position = UDim2.new(0.0, gw, (y-.75)/my, -math.floor(gw/2)),
					ZIndex = 6, Parent = grid,
				}
			end
			iconContainer.Size = UDim2.new(squares.X/(squares.X+.5), 0, squares.Y/(squares.Y+.5), 0)
			iconContainer.Position = UDim2.new(.25/(squares.X+.5), 0, .25/(squares.Y+.5), 0)
			entryContainer.Size = UDim2.new(1.0, -gw*2, 1.0, -gw*2)
			entryContainer.Position = UDim2.new(0.0, gw, 0.0, gw)
		end
		Utilities.gui.Changed:connect(update)
		update('AbsoluteSize')
		function pokedex:redrawGrid()
			update('AbsoluteSize')
		end
	end
	busy = true
	background.Parent = Utilities.gui
	gui.Parent = Utilities.gui
--	self:viewPage(math.floor(N_MAX_DEX/(squares.X*squares.Y))+1)
	Utilities.Tween(.5, 'easeOutCubic', function(a)
		background.BackgroundTransparency = 1-.5*a
		gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, 1.15-a, 0)
	end)
	while not dex do wait() end
	self:read(dex)
	self:viewPage(1)
	Utilities.Tween(.5, 'easeOutCubic', function(a)
		rightTray.Position = UDim2.new(.65+.2*a, 0, 0.1, 0)
		topTray.Position = UDim2.new(0.2, 0, -.2*a, 0)
	end)
	busy = false
end

function pokedex:close()
	if not gui or busy then return end
	busy = true
	
	_p.DataManager:dumpCache('PokedexExtended')
	
	spawn(function()
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			rightTray.Position = UDim2.new(.85-.2*a, 0, 0.1, 0)
			topTray.Position = UDim2.new(0.2, 0, -.2+.2*a, 0)
		end)
	end)
	wait(.25)
	Utilities.Tween(.5, 'easeOutCubic', function(a)
		background.BackgroundTransparency = .5+.5*a
		gui.Position = UDim2.new(0.5, -gui.gui.AbsoluteSize.X/2, .15+a, 0)
	end)
	gui.Parent = nil
	background.Parent = nil
	self.dexData = nil
	busy = false
	
	spawn(function() _p.Menu:enable() end)
	_p.MasterControl.WalkEnabled = true
	--_p.MasterControl:Start()
	
end


return pokedex end