return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
local Utilities = _p.Utilities
local create = Utilities.Create
local write = Utilities.Write

local powers = {
	isOpen = false,
}

local gui, bg, close, xpbar, eggs, buttons
local openThread
local timerContainers, activeMultiplierContainers = {}, {}
local network = _p.Network

local powerLevel = {}--0, 0, 0, 0, 0, 0, 0}
local endTime = {}--lastPurchasedAt = {0, 0, 0, 0, 0, 0, 0}

local color = Color3.fromRGB-- function color(r, g, b)
--	return Color3.new(r/255, g/255, b/255)
--end

local groupEnabled = {true, true, true, true, true, true, true}
local function setGroupEnabled(g, enabled)
--	do return end-- disabling setGroupEnabled; dev products do not notify when purchase is canceled >:l
	
	groupEnabled[g] = enabled
	local function setButtonEnabled(b)
		if not b then return end
		b.ImageTransparency = enabled and 0.0 or 0.5
	end
	setButtonEnabled(buttons[g*2-1])
	setButtonEnabled(buttons[g*2])
end

local function setGroupIsActive(g, isActive)
	activeMultiplierContainers[g]:ClearAllChildren()
	local level = powerLevel[g]
	if isActive and level > 0 then
		local mult = 1 + level
		if g == 1 then
			mult = 1 + level/2
		elseif g == 5 then
			mult = 16
		elseif g == 7 then
			mult = 4
			gui.Part2.LegendContainer.AvailableLabel.Visible = not isActive
		end
		write('x'..mult) {
			Frame = activeMultiplierContainers[g],
			Scaled = true,
		}
	end
	local function setButtonEnabled(b)
		if not b then return end
		b.Visible = not isActive
	end
	setButtonEnabled(buttons[g*2-1])
	setButtonEnabled(buttons[g*2])
end

local function startTimer(g)
	local function start(g)
		if g == 6 then return end -- catch rate currently unavailable
		Utilities.fastSpawn(function()
			local now = tick()
			local timerContainer = timerContainers[g]
			timerContainer:ClearAllChildren()
			if now > endTime[g] then
--				setGroupEnabled(g, true)
				setGroupIsActive(g, false)
				return
			end
			setGroupIsActive(g, true)
			local sr = math.ceil(endTime[g]-now)
			while gui.Parent do
				now = tick()
				local t = endTime[g] - sr + 1
				wait(t-now)
				timerContainer:ClearAllChildren()
				if now > endTime[g] then
--					setGroupEnabled(g, true)
					setGroupIsActive(g, false)
					return
				end
				sr = math.floor(endTime[g]-now+.5)
				local rm = math.floor(sr/60)
				local rs = sr%60
				write(rm..':'..(rs<10 and ('0'..rs) or rs)) {
					Frame = timerContainer,
					Scaled = true,
				}
			end
		end)
	end
	if g then
		start(g)
	else
		for g = 1, 7 do
			start(g)
		end
	end
end

local function onButtonClicked(n)
	local now = os.time()
	local group = math.ceil(n/2)
	if not groupEnabled[group] or now < endTime[group] then return end
	local level = 2 - (n%2)
--	setGroupEnabled(group, false)
	_p.Network:post('PDS', 'purchaseRoPower', group, level)
end

_p.Network:bindEvent('rpActivate', function(group, level, duration)
	powerLevel[group] = level
	endTime[group] = tick()+duration
	if gui and gui.Parent then
		startTimer(group)
	end
end)

function powers:open()
	if self.isOpen or not _p.MasterControl.WalkEnabled then return end
	self.isOpen = true
	
	_p.MasterControl.WalkEnabled = false
	_p.MasterControl:Stop()
	spawn(function() _p.Menu:disable() end)
	
	if not gui then
		local size = .6
		local activeMultiplierPosition = 0.55
		local timerPosition = 0.76
		bg = create 'ImageButton' {--'Frame' {
			AutoButtonColor = false,
			
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
		}
		gui = create 'ImageLabel' { -- 650x400
			BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6138636248', --5221322676
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Size = UDim2.new(.45, 0, .45/650*400, 0),--650/400*size, 0, size, 0),
			ZIndex = 2,
			
			create 'Frame' {
				Name = 'ExpContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(200/650, 0, 1.0, 0),
			},
			create 'Frame' {
				Name = 'EggsContainer',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(200/650, 0, 1.0, 0),
				Position = UDim2.new(225/650, 0, 0.0, 0),
			},
			create 'Frame' {
				Name = 'MoneyContainer',
				ClipsDescendants = true,
				BackgroundTransparency = 1.0,
				Size = UDim2.new(200/650, 0, 1.0, 0),
				Position = UDim2.new(450/650, 0, 0.0, 0),
			},
			
			create 'Frame' {
				Name = 'Part2',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 1.0, 0),
				Position = UDim2.new(-1-25/650, 0, 0.0, 0),
				
				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6138636193',--5221325031
					ImageRectSize = Vector2.new(430, 400),
					Size = UDim2.new(430/650, 0, 1.0, 0),
	--				Position = UDim2.new(-1-245/650, 0, 0.0, 0),
					ZIndex = 2
				},
				
				create 'Frame' {
					Name = 'EVContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(200/650, 0, 1.0, 0)
				},
				create 'Frame' {
					Name = 'ShinyContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(200/650, 0, 1.0, 0),
					Position = UDim2.new(225/650, 0, 0.0, 0)
				},
				create 'Frame' {
					Name = 'LegendContainer',--'CatchContainer',
					ClipsDescendants = true,
					BackgroundTransparency = 1.0,
					Size = UDim2.new(200/650, 0, 1.0, 0),
					Position = UDim2.new(450/650, 0, 0.0, 0),
					
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
							Image = 'rbxassetid://6138636033',
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 3
					}
				}
			}
		}
		close = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = color(150, 73, 69),
			Size = UDim2.new(.2*1.5, 0, .085*1.25, 0),
			Position = UDim2.new(.525, 0, -.125, 0),
			ZIndex = 3, Parent = gui,
			MouseButton1Click = function()
				self:close()
			end,
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
		
		-- Exp
		xpbar = _p.RoundedFrame:new {
			BackgroundColor3 = Color3.new(.1, .1, .1),
			Size = UDim2.new(0.9, 0, 0.025),
			Position = UDim2.new(0.05, 0, 0.3, 0),
			Style = 'HorizontalBar',
			ZIndex = 4, Parent = gui.ExpContainer,
		}
		xpbar:setupFillbar(Color3.new(.4, .8, 1), Utilities.isPhone() and 1 or 2, 0)
		
		local button1 = create 'ImageButton' { -- 150x100
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(31, 92, 154),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .4, 0),
			ZIndex = 3, Parent = gui.ExpContainer,
			MouseButton1Click = function()
				onButtonClicked(1)
			end,
		}
		write 'x1.5 Exp' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 4, Parent = button1,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 4, Parent = button1,
			}, Scaled = true,
		}
			write '8 R$' { --write '40 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 4, Parent = button1,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		activeMultiplierContainers[1] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.15, 0),
			Position = UDim2.new(0.5, 0, activeMultiplierPosition, 0),
			ZIndex = 4, Parent = gui.ExpContainer,
		}
		timerContainers[1] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, timerPosition, 0),
			ZIndex = 4, Parent = gui.ExpContainer,
		}
		local button2 = create 'ImageButton' { -- 150x100
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(31, 92, 154),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .7, 0),
			ZIndex = 3, Parent = gui.ExpContainer,
			MouseButton1Click = function()
				onButtonClicked(2)
			end,
		}
		write 'x2 Exp' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 4, Parent = button2,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 4, Parent = button2,
			}, Scaled = true,
		}
		write '14 R$' { --write '70 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 4, Parent = button2,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		
		-- Eggs              -- egg threshold
		local egg1 = _p.Pokemon:getIcon(1613)-- seviper
		egg1.Rotation = -25
		egg1.SizeConstraint = Enum.SizeConstraint.RelativeYY
		egg1.Size = UDim2.new(0.15*4/3, 0, 0.15, 0)
		egg1.Position = UDim2.new(0.0, 0, 0.2, 0)
		egg1.Parent = gui.EggsContainer
		local egg2 = _p.Pokemon:getIcon(1612)-- zangoose
		egg2.Rotation = 22
		egg2.SizeConstraint = Enum.SizeConstraint.RelativeYY
		egg2.Size = UDim2.new(-0.15*4/3, 0, 0.15, 0)
		egg2.Position = UDim2.new(1.0, 0, 0.15, 0)
		egg2.Parent = gui.EggsContainer
		local egg3 = _p.Pokemon:getIcon(1508)-- eevee
		egg3.Rotation = -15
		egg3.SizeConstraint = Enum.SizeConstraint.RelativeYY
		egg3.Size = UDim2.new(0.15*4/3, 0, 0.15, 0)
		egg3.Position = UDim2.new(-0.1, 0, .45, 0)
		egg3.Parent = gui.EggsContainer
		local egg4 = _p.Pokemon:getIcon(1530)-- togepi
		egg4.Rotation = 18
		egg4.SizeConstraint = Enum.SizeConstraint.RelativeYY
		egg4.Size = UDim2.new(-0.15*4/3, 0, 0.15, 0)
		egg4.Position = UDim2.new(1.05, 0, .6, 0)
		egg4.Parent = gui.EggsContainer
		local egg5 = _p.Pokemon:getIcon(1585)-- shroomish/default
		egg5.Rotation = -3
		egg5.SizeConstraint = Enum.SizeConstraint.RelativeYY
		egg5.Size = UDim2.new(0.15*4/3, 0, -0.15, 0)
		egg5.Position = UDim2.new(0.175, 0, 1.0125, 0)
		egg5.Parent = gui.EggsContainer
		eggs = {egg1, egg2, egg3, egg4, egg5}
		
		local button3 = create 'ImageButton' { -- 150x100
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',--290486212',
			ImageColor3 = color(163, 80, 29),--163, 39, 29),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .4, 0),
			ZIndex = 3, Parent = gui.EggsContainer,
			MouseButton1Click = function()
				onButtonClicked(3)
			end,
		}
		write 'x2 Steps' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 4, Parent = button3,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 4, Parent = button3,
			}, Scaled = true,
		}
			write '5 R$' { --write '20 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 4, Parent = button3,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		activeMultiplierContainers[2] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.15, 0),
			Position = UDim2.new(0.5, 0, activeMultiplierPosition, 0),
			ZIndex = 4, Parent = gui.EggsContainer,
		}
		timerContainers[2] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, timerPosition, 0),
			ZIndex = 4, Parent = gui.EggsContainer,
		}
		local button4 = create 'ImageButton' { -- 150x100
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(163, 80, 29),--163, 39, 29),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .7, 0),
			ZIndex = 3, Parent = gui.EggsContainer,
			MouseButton1Click = function()
				onButtonClicked(4)
			end,
		}
		write 'x3 Steps' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 4, Parent = button4,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 4, Parent = button4,
			}, Scaled = true,
		}
			write '10 R$' { --write '35 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 4, Parent = button4,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		
		-- Money
		local button5 = create 'ImageButton' { -- 150x100
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(63, 150, 64),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .4, 0),
			ZIndex = 5, Parent = gui.MoneyContainer,
			MouseButton1Click = function()
				onButtonClicked(5)
			end,
		}
		write 'x2 [$]' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 6, Parent = button5,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 6, Parent = button5,
			}, Scaled = true,
		}
			write '10 R$' { --write '30 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 6, Parent = button5,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		activeMultiplierContainers[3] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.15, 0),
			Position = UDim2.new(0.5, 0, activeMultiplierPosition, 0),
			ZIndex = 4, Parent = gui.MoneyContainer,
		}
		timerContainers[3] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, timerPosition, 0),
			ZIndex = 4, Parent = gui.MoneyContainer,
		}
		local button6 = create 'ImageButton' { -- 150x100
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(63, 150, 64),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .7, 0),
			ZIndex = 5, Parent = gui.MoneyContainer,
			MouseButton1Click = function()
				onButtonClicked(6)
			end,
		}
		write 'x3 [$]' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 6, Parent = button6,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 6, Parent = button6,
			}, Scaled = true,
		}
			write '15 R$' { --write '55 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 6, Parent = button6,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		
--==========================================================================================================--
--==========================================================================================================--
--================================================= Part 2 =================================================--
--==========================================================================================================--
		
		-- EVs
		local button7 = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(167, 56, 126),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .4, 0),
			ZIndex = 3, Parent = gui.Part2.EVContainer,
			MouseButton1Click = function()
				onButtonClicked(7)
			end,
		}
		write 'x2 EVs' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 4, Parent = button7,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 4, Parent = button7,
			}, Scaled = true,
		}
		write '5 R$' { --write '20 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 4, Parent = button7,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		activeMultiplierContainers[4] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.15, 0),
			Position = UDim2.new(0.5, 0, activeMultiplierPosition, 0),
			ZIndex = 4, Parent = gui.Part2.EVContainer,
		}
		timerContainers[4] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, timerPosition, 0),
			ZIndex = 4, Parent = gui.Part2.EVContainer,
		}
		local button8 = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(167, 56, 126),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .7, 0),
			ZIndex = 3, Parent = gui.Part2.EVContainer,
			MouseButton1Click = function()
				onButtonClicked(8)
			end,
		}
		write 'x3 EVs' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 4, Parent = button8,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 4, Parent = button8,
			}, Scaled = true,
		}
		write '10 R$' { --write '35 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 4, Parent = button8,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		
		-- Shiny
		local button9 = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(166, 152, 42),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .4, 0),
			ZIndex = 5, Parent = gui.Part2.ShinyContainer,
			MouseButton1Click = function()
				onButtonClicked(9)
			end,
		}
		write 'x16 Chance' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 6, Parent = button9,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 6, Parent = button9,
			}, Scaled = true,
		}
			write '10 R$' { --write '100 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 6, Parent = button9,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		activeMultiplierContainers[5] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.15, 0),
			Position = UDim2.new(0.5, 0, activeMultiplierPosition, 0),
			ZIndex = 4, Parent = gui.Part2.ShinyContainer,
		}
		timerContainers[5] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, timerPosition, 0),
			ZIndex = 4, Parent = gui.Part2.ShinyContainer,
			}

			write 'Shiny sprites invisible' { --write 'Stacks with Game Pass' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.0275, 0),
				Position = UDim2.new(0.5, 0, 0.95, 0),
				ZIndex = 4, Parent = gui.Part2.ShinyContainer,
			}, Scaled = true, Color = Color3.new(.3, .3, .3),
		}
--[[		
		-- Catch rate
		local button11 = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://343003229',
			ImageColor3 = color(78, 65, 133),
			Size = UDim2.new(.6, 0, .6/3, 0),
			Position = UDim2.new(.2, 0, .4, 0),
			ZIndex = 5, Parent = gui.Part2.CatchContainer,
			MouseButton1Click = function()
				onButtonClicked(11)
			end,
		}
		write 'x2 Rate' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 6, Parent = button11,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 6, Parent = button11,
			}, Scaled = true,
		}
		write '15 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 6, Parent = button11,
			}, Scaled = true, Color = color(50, 225, 77),
		}]]
		local button13 = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5217682909',
			ImageColor3 = color(163, 39, 29),
			Size = UDim2.new(.6, 0, .2, 0),
			Position = UDim2.new(.2, 0, .4, 0),
			ZIndex = 7, Parent = gui.Part2.LegendContainer,
			MouseButton1Click = function()
				onButtonClicked(13)
			end,
		}
		write 'x4 Chance' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.25, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				ZIndex = 8, Parent = button13,
			}, Scaled = true,
		}
		write '1 Hour' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.425, 0),
				ZIndex = 8, Parent = button13,
			}, Scaled = true,
		}
			write '15 R$' { --		write '150 R$' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.2, 0),
				Position = UDim2.new(0.5, 0, 0.7, 0),
				ZIndex = 8, Parent = button13,
			}, Scaled = true, Color = color(50, 225, 77),
		}
		activeMultiplierContainers[7] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.15, 0),
			Position = UDim2.new(0.5, 0, activeMultiplierPosition-.125, 0),
			ZIndex = 4, Parent = gui.Part2.LegendContainer,--CatchContainer,
		}
		timerContainers[7] = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, timerPosition-.165, 0),
			ZIndex = 4, Parent = gui.Part2.LegendContainer,--CatchContainer,
		}
		write 'Available:' {
			Frame = create 'Frame' {
				Name = 'AvailableLabel',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.04, 0),
				Position = UDim2.new(0.5, 0, 0.63, 0),
				ZIndex = 4, Parent = gui.Part2.LegendContainer
			}, Scaled = true, Color = Color3.new(.8, .8, .8)
		}
		create 'Frame' {
			Name = 'IconsContainer',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.2, 0, .075, 0),
			Position = UDim2.new(.025, 0, .685, 0),
			Parent = gui.Part2.LegendContainer
		}
		create 'Frame' {
			Name = 'ReqContainer',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Position = UDim2.new(0.0, 0, .78, 0),
			Parent = gui.Part2.LegendContainer
		}
		write 'Stacks with Game Pass' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.0275, 0),
				Position = UDim2.new(0.5, 0, 0.95, 0),
				ZIndex = 4, Parent = gui.Part2.LegendContainer,
			}, Scaled = true, Color = Color3.new(.8, .8, .8),
		}
		
--==========================================================================================================--
--==========================================================================================================--
		
		buttons = {button1, button2, button3, button4, button5, button6, button7, button8, button9, nil, nil, nil, button13, nil}
	end
	
	bg.Parent = Utilities.gui
	gui.Parent = Utilities.gui
	close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015
	for i = 1, 7 do
		if i ~= 6 then -- capture rate may be retiring (stay tuned)
			local b1, b2 = buttons[i*2-1], buttons[i*2]
			if b1 then b1.Visible = false end
			if b2 then b2.Visible = false end
			activeMultiplierContainers[i]:ClearAllChildren()
			timerContainers[i]:ClearAllChildren()
		end
	end
	local status
	Utilities.fastSpawn(function()
		status = _p.Network:get('PDS', 'roStatus')
		local now = tick()
		for i = 1, 7 do
			local r = status[tostring(i)]
			if r then
				powerLevel[i] = r[1]
				endTime[i] = now + r[2]
			else
				powerLevel[i] = 0
				endTime[i] = 0
			end
		end
		setGroupEnabled(7, #status.r > 2)
		startTimer()
	end)
	
	-- ANIMATIONS
	local thisThread = {}
	openThread = thisThread
	spawn(function()
		while openThread == thisThread do
			xpbar:setFillbarRatio(0, false)
			xpbar:setFillbarRatio(1, true)
			local ring = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6142896054',
				ImageColor3 = Color3.new(.2, .4, .5),
				ZIndex = 5, Parent = xpbar.gui.CornerTopRight,
			}
			Utilities.Tween(1, 'easeOutCubic', function(a)
				local s = a*8
				ring.Size = UDim2.new(s, 0, s, 0)
				ring.Position = UDim2.new(.5-s/2, 0, .5-s/2, 0)
				ring.ImageTransparency = a
			end)
			ring:remove()
		end
	end)
	spawn(function()
		while openThread == thisThread do
			wait(.25+1*math.random())
			local egg = eggs[math.random(#eggs)]
			local r = egg.Rotation
			Utilities.Tween(1.5, nil, function(a)
				egg.Rotation = r + math.sin(a*math.pi*4)*15*math.sin(a*math.pi)
			end)
		end
	end)
	spawn(function()
		local container = gui.MoneyContainer
		local green = color(50, 225, 77)
		while openThread == thisThread do
			spawn(function()
				local mooney = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 3, Parent = container,
				}
				write '[$]' {
					Frame = mooney,
					Scaled = true,
					Color = green,
				}
				local x = math.random()
				Utilities.Tween(6, nil, function(a)
					mooney.Position = UDim2.new(x, 0, 1-1.3*a, 0)
				end)
				mooney:remove()
			end)
			wait(2)
		end
	end)
	--
	spawn(function()
		local container = gui.Part2.EVContainer
		local drawHex = _p.Menu.party:getHexFunction()
		local hexContainer = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Size = UDim2.new(.5, 0, .5, 0),
			Position = UDim2.new(.25, 0, .2, 0),
			Parent = container,
		}
		while openThread == thisThread do
			local evs = {.5+math.random()*.45, .5+math.random()*.45, .5+math.random()*.45,
			             .5+math.random()*.45, .5+math.random()*.45, .5+math.random()*.45}
			drawHex(hexContainer, {1, 1, 1, 1, 1, 1}, Color3.new(.5, .7, .8), 2)
			drawHex(hexContainer, evs, Color3.new(200/255, 250/255, 140/255), 4, {0, 0, 0, 0, 0, 0})
			wait(.5)
			hexContainer:ClearAllChildren()
		end
	end)
	spawn(function()
		local container = gui.Part2.ShinyContainer
		while openThread == thisThread do
			local s = .1+.15*math.random()
			local r = 90*math.random()
			local rv = math.random(-50, 50)
			local px, py = math.random(), math.random()
			local sparkle = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5221328134',
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				ZIndex = 3,
			}
			spawn(function()
				local st = tick()
				sparkle.Parent = container
				Utilities.Tween(.4+.6*math.random(), nil, function(a)
					local size = s*math.sin(a*math.pi)
					sparkle.Size = UDim2.new(size, 0, size, 0)
					sparkle.Position = UDim2.new(px-size/2, 0, py, -sparkle.AbsoluteSize.Y/2)
					sparkle.Rotation = r + rv*(tick()-st)
				end)
				sparkle:remove()
			end)
			wait(.1)
		end
	end)
--[[	spawn(function()
		local container = gui.Part2.CatchContainer
		local size = .2
		while openThread == thisThread do
			local ball = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://285485468',
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Size = UDim2.new(size, 0, size, 0),
				ZIndex = 3, Parent = container,
			}
			Utilities.Tween(.75, 'easeInCubic', function(a)
				ball.Position = UDim2.new(.5-size/2, 0, -size+.5*a, 0)
			end)
			local pos = ball.Position
			for i = 1, 3 do
				wait(.5 + .5*math.random())
				local vigor = .7+math.random()*.5
				local sign = (math.random(2)==1 and -1 or 1)
				Utilities.Tween(.6, nil, function(t)
					local a = math.sin(t*3*math.pi) * (1-t) * sign
					local theta = a*vigor
					local dist = theta*ball.AbsoluteSize.Y/2
					ball.Rotation = theta/math.pi*180
					ball.Position = pos + UDim2.new(0.0, dist, 0.0, 0)
				end)
			end
			wait(.5)
			Utilities.Tween(.6, 'easeOutCubic', function(a)
				ball.ImageTransparency = a
			end)
			ball:remove()
		end
	end)]]
	spawn(function()
		local container = gui.Part2.LegendContainer
		local grass1, grass2 = container:FindFirstChild('grass1'), container:FindFirstChild('grass2')
		if not grass1 then
			grass1 = create 'ImageLabel' {
				Name = 'grass1',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5217688531',
				ImageColor3 = color(84, 164, 7),
				Size = UDim2.new(.4, 0, .2, 0),
				Position = UDim2.new(.3, 0, .203, 0),
				ZIndex = 6, Parent = container
			}
			grass2 = create 'ImageLabel' {
				Name = 'grass2',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5217688531',
				ImageRectSize = Vector2.new(-200, 200),
				ImageRectOffset = Vector2.new(200, 0),
				ImageColor3 = color(123, 217, 14),
				Size = UDim2.new(.35, 0, .175, 0),
				Position = UDim2.new(.325, 0, .225, 0),
				ZIndex = 4, Parent = container
			}
		end
		while not status do
			wait()
			if openThread ~= thisThread then return end
		end
		local icons = status.r
		local nIcons = #icons
		if nIcons == 0 then return end
		-- make static "Available" list
		local iconsContainer = container.IconsContainer
		iconsContainer:ClearAllChildren()
		for i, icon in pairs(icons) do
			i = i-1
			local x = i % 5
			local y = math.floor(i/5)
			local img = _p.Pokemon:getIcon(icon)
			img.Parent = iconsContainer
			img.Position = UDim2.new(x*.93, 0, y*1.05, 0)
		end
		local reqContainer = container.ReqContainer
		reqContainer:ClearAllChildren()
		if nIcons < 3 then
			write 'At least three must' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.0275, 0),
					Position = UDim2.new(0.5, 0, 0.0, 0),
					ZIndex = 4, Parent = reqContainer,
				}, Scaled = true--, Color = Color3.new(.6, .2, .2),
			}
			write 'be discovered to use' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.0275, 0),
					Position = UDim2.new(0.5, 0, 0.035, 0),
					ZIndex = 4, Parent = reqContainer,
				}, Scaled = true--, Color = Color3.new(.6, .2, .2),
			}
			write 'this RO-Power.' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.0275, 0),
					Position = UDim2.new(0.5, 0, 0.07, 0),
					ZIndex = 4, Parent = reqContainer,
				}, Scaled = true--, Color = Color3.new(.6, .2, .2),
			}
		end
		--
		local lastIcon = 0
		local function chooseIcon()
			if nIcons == 1 then return icons[1] end
			local n = math.random(nIcons-1)
			if n == lastIcon then
				n = nIcons
			end
			lastIcon = n
			return icons[n]
		end
		while openThread == thisThread do
			wait(1.4)
			spawn(function()
				Utilities.Tween(.7, nil, function(a)
					local o = math.sin(a*12.56)*math.cos(a*1.57)
					grass1.Position = UDim2.new(.3+o*.025, 0, .203, 0)
					grass2.Position = UDim2.new(.325-o*.013, 0, .225, 0)
				end)
			end)
			wait(.4)
			local icon = _p.Pokemon:getIcon(chooseIcon())
			icon.ZIndex = 5
			icon.Parent = container
			Utilities.Tween(.5, nil, function(a)
				local s = 1+a
				icon.Size = UDim2.new(.13*s, 0, .05*s, 0)
				icon.Position = UDim2.new(.5-a*.2, 0, .4-.05*s-math.sin(a*3.14)*.11)
				if a > .5 then
					icon.ZIndex = 7
				end
			end)
			wait(.8)
			Utilities.Tween(.5, nil, function(a)
				icon.Position = UDim2.new(.3-.5*a, 0, .3, 0)
			end)
			icon:remove()
		end
	end)
	--
	
	Utilities.Tween(.8, 'easeOutCubic', function(a)
		if not self.isOpen then return false end
		bg.BackgroundTransparency = 1-.3*a
		gui.Position = UDim2.new(1.5-a, 0, 0.5, -gui.AbsoluteSize.Y/2)
	end)
end

function powers:close()
	if not self.isOpen then return end
	self.isOpen = false
	
	openThread = nil
	
	spawn(function() _p.Menu:enable() end)
	
	Utilities.Tween(.8, 'easeOutCubic', function(a)
		if self.isOpen then return false end
		bg.BackgroundTransparency = .7+.3*a
		gui.Position = UDim2.new(.5+a, 0, 0.5, -gui.AbsoluteSize.Y/2)
	end)
	bg.Parent = nil
	gui.Parent = nil
	
	_p.MasterControl.WalkEnabled = true
	--_p.MasterControl:Start()
	
end

return powers end