return function(_p)--local _p = require(script.Parent.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local remoteFn = _p.storage.Remote.WBag
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write

	-- todo: migrate to Network

	local gui, WBagClose, unstuckButton, unstuckTimerContainer

	local function color(r, g, b)
		return Color3.new(r/255, g/255, b/255)
	end


	local bag = {
		wearing = false,
		is2_0 = false,
		isSatchel = true,
		isRight = true,
		isOpen = false,
	}

--[[
	Bag variations and names:
	
	Backpack1.0
	Backpack2.0
	Satchel1.0Left
	Satchel1.0Right
	Satchel2.0Left
	Satchel2.0Right
--]]

	local function getSelectedBagId()
		return (bag.isSatchel and 'Satchel' or 'Backpack')
			.. (bag.is2_0 and '2.0' or '1.0')
			.. (bag.isSatchel and (bag.isRight and 'Right' or 'Left') or '')
	end

	local function getPokeballs()
		local BallString = _p.Network:get('PDS','getBagParty')
		return BallString
	end

	function bag:update()
		if not self.wearing then return end

	end

	function bag:wear()
		self.wearing = true
		remoteFn:InvokeServer(getSelectedBagId(), nil, nil, getPokeballs())
	end

	function bag:remove()
		self.wearing = false
		remoteFn:InvokeServer()
	end

	function bag:close()
		if not self.isOpen then return end
		self.isOpen = false

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			gui.Position = UDim2.new(.5+.5*a, -gui.AbsoluteSize.X/2*(1-a), 0.05, 0)
		end)
		gui.Parent = nil
	end
--[[
	function bag:configure()
		if self.isOpen then return end
		self.isOpen = true
		if not gui then
			gui = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5566230125',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 4,
			}

			WBagClose = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = color(61, 142, 196),
				Size = UDim2.new(.31, 0, .08, 0),
				Position = UDim2.new(.65, 0, -.03, 0),
				ZIndex = 5, Parent = gui,
			}
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = WBagClose.gui,
					ZIndex = 5,
				}, Scaled = true,
			}
			-- Switches // Is Stachel
			local IsStachelToggle = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.1, 0),
				Position = UDim2.new(0.8, 0, 0.225, 0),
				Value = self.isSatchel,
				ZIndex = 5, Parent = gui,
			}
			IsStachelToggle.ValueChanged:connect(function()
				IsStachelToggle.Enabled = false
				local v = IsStachelToggle.Value
				self.isSatchel = v
				IsStachelToggle.Enabled = true
			end)
			write 'Satchel = On / Backpack = Off' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.25, 0),
					ZIndex = 5, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			-- Switches // Is 2.0
			--[[
			local Is2Toggle = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.1, 0),
				Position = UDim2.new(0.825, 0, 0.4, 0),
				Value = self.is2_0,
				ZIndex = 5, Parent = gui,
			}
			Is2Toggle.ValueChanged:connect(function()
				Is2Toggle.Enabled = false
				local v = Is2Toggle.Value
				self.is2_0 = v
				Is2Toggle.Enabled = true
			end)
			write 'Version 2.0 = On / Version 1.0 = Off' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.4, 0),
					ZIndex = 5, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write 'More coming soon...' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.5, 0, 0.55, 0),
					ZIndex = 5, Parent = gui,
				}, Scaled = true,
			}
--]]
	--[[
			WBagClose.gui.MouseButton1Click:connect(function()
				self:close()
			end)
		end
		gui.Parent = Utilities.gui
		WBagClose.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpen then return false end
			gui.Position = UDim2.new(1-.5*a, -gui.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end
--]]
	return bag end