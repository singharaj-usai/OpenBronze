return function(_p)
	local Roulette = {}
	
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local MasterControl = _p.MasterControl
	
	-- Constants for the Roulette
	local SPIN_DURATION = 3 -- seconds
	local SPIN_ROTATIONS = 5 -- number of full rotations
	local SLOT_COUNT = 8 -- number of visible slots in the roulette wheel
	
	-- UI elements
	local gui, mainFrame, spinButton
	local rewardFrame, rewardImage, rewardName
	local slotContainer
	local isOpen = false
	local isSpinning = false
	local currentAnimation
	local initialized = false

	-- Initialize the Roulette UI
	function Roulette:init()
		if initialized then return end
		
		gui = _p.RoundedFrame:new {
			BackgroundColor3 = Color3.new(.1, .1, .1),
			Size = UDim2.new(0.8, 0, 0.8, 0),
			Position = UDim2.new(1.0, 0, 0.1, 0),
			Parent = Utilities.gui,
		}
		gui.gui.Visible = false
		gui.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015
		
		mainFrame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 3,
			Parent = gui.gui,
		}
		
		-- Title
		write 'POKEMON ROULETTE' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.08, 0),
				Position = UDim2.new(0.5, 0, 0.02, 0),
				ZIndex = 4,
				Parent = mainFrame,
			},
			Scaled = true,
			TextColor3 = Color3.new(1, 1, 1),
		}
		
		-- Create slot container (wheel)
		slotContainer = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.8, 0, 0.8, 0),
			Position = UDim2.new(0.1, 0, 0.1, 0),
			ZIndex = 3,
			Parent = mainFrame,
		}
		
		-- Create slots in a circle
		local slots = {}
		for i = 1, SLOT_COUNT do
			local angle = (i-1) * (2 * math.pi / SLOT_COUNT)
			local x = math.cos(angle) * 0.3 + 0.5
			local y = math.sin(angle) * 0.3 + 0.5
			
			local slot = _p.RoundedFrame:new {
				BackgroundColor3 = Color3.new(.2, .2, .2),
				Size = UDim2.new(0.2, 0, 0.2, 0),
				Position = UDim2.new(x-0.1, 0, y-0.1, 0),
				ZIndex = 4,
				Parent = slotContainer,
			}
			slot.CornerRadius = Utilities.gui.AbsoluteSize.Y*.01
			
			local spriteContainer = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 1.0, 0),
				ZIndex = 5,
				Parent = slot.gui,
			}
			
			slots[i] = {frame = slot, container = spriteContainer}
		end
		self.slots = slots
		
		-- Create spin button
		spinButton = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = Color3.new(0, 0.6, 0),
			Size = UDim2.new(0.2, 0, 0.1, 0),
			Position = UDim2.new(0.4, 0, 0.85, 0),
			ZIndex = 4,
			Parent = mainFrame,
			MouseButton1Click = function()
				if not isSpinning then
					self:spin()
				end
			end,
		}
		spinButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.01
		
		write 'SPIN!' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.8, 0, 0.8, 0),
				Position = UDim2.new(0.1, 0, 0.1, 0),
				ZIndex = 5,
				Parent = spinButton.gui,
			},
			Scaled = true,
			TextColor3 = Color3.new(1, 1, 1),
		}
		
		-- Create close button
		local closeButton = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = Color3.new(.8, 0, 0),
			Size = UDim2.new(0.1, 0, 0.08, 0),
			Position = UDim2.new(0.85, 0, 0.05, 0),
			ZIndex = 4,
			Parent = mainFrame,
			MouseButton1Click = function()
				self:close()
			end,
		}
		closeButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.01
		
		write 'X' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.8, 0, 0.8, 0),
				Position = UDim2.new(0.1, 0, 0.1, 0),
				ZIndex = 5,
				Parent = closeButton.gui,
			},
			Scaled = true,
			TextColor3 = Color3.new(1, 1, 1),
		}
		
		-- Create reward container
		rewardFrame = _p.RoundedFrame:new {
			BackgroundColor3 = Color3.new(.3, .3, .3),
			Size = UDim2.new(0.4, 0, 0.4, 0),
			Position = UDim2.new(0.3, 0, 0.3, 0),
			ZIndex = 6,
			Parent = mainFrame,
		}
		rewardFrame.CornerRadius = Utilities.gui.AbsoluteSize.Y*.02
		rewardFrame.gui.Visible = false
		
		rewardImage = create 'ImageLabel' {
			Size = UDim2.new(0.6, 0, 0.6, 0),
			Position = UDim2.new(0.2, 0, 0.1, 0),
			BackgroundTransparency = 1.0,
			ZIndex = 7,
			Parent = rewardFrame.gui,
		}
		
		rewardName = create 'TextLabel' {
			Size = UDim2.new(0.8, 0, 0.2, 0),
			Position = UDim2.new(0.1, 0, 0.7, 0),
			BackgroundTransparency = 1.0,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			Text = "",
			ZIndex = 7,
			Parent = rewardFrame.gui,
		}
		
		initialized = true
	end
	
	function Roulette:updateSlots(reward)
		-- Clear existing animations
		if currentAnimation then
			pcall(function() currentAnimation:Stop() end)
			currentAnimation = nil
		end

		-- Update slots with random rewards and the winning reward
		local winningSlot = math.random(1, SLOT_COUNT)
		for i, slot in ipairs(self.slots) do
			local slotReward
			if i == winningSlot then
				slotReward = reward
			else
				-- Get a random reward for display or use a placeholder
				slotReward = {
					type = math.random() > 0.5 and "pokemon" or "item",
					name = math.random() > 0.5 and "Pikachu" or "Ultra Ball",
					level = 10,
					quantity = 5
				}
			end

			-- Clear existing content
			slot.container:ClearAllChildren()

			if slotReward.type == "pokemon" then
				-- Create Pokemon icon
				local icon
				pcall(function()
					icon = _p.Pokemon:getIcon(slotReward.name)
				end)
				
				if not icon then
					-- Fallback in case of error
					icon = create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = "rbxassetid://6932435438" -- Default placeholder image
					}
				end
				
				icon.Size = UDim2.new(0.8, 0, 0.8, 0)
				icon.Position = UDim2.new(0.1, 0, 0.1, 0)
				icon.ZIndex = 6
				icon.Parent = slot.container
			else
				-- Show item icon
				local icon
				pcall(function()
					icon = _p.Menu.bag:getItemIcon(slotReward.name:lower():gsub(" ", ""))
				end)
				
				if not icon then
					-- Fallback in case of error
					icon = create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = "rbxassetid://6932435438" -- Default placeholder image
					}
				end
				
				icon.Size = UDim2.new(0.8, 0, 0.8, 0)
				icon.Position = UDim2.new(0.1, 0, 0.1, 0)
				icon.ZIndex = 6
				icon.Parent = slot.container
			end
		end

		return winningSlot
	end
	
	function Roulette:spin()
		if isSpinning then return end
		isSpinning = true
		spinButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
		
		-- Request spin from server
		local reward
		pcall(function()
			reward = _p.Network:get('SpinRoulette')
		end)
		
		if not reward then
			-- Create default reward if server call fails
			reward = {
				type = "item",
				name = "Poké Ball",
				quantity = 5,
				level = 1
			}
		end
		
		-- Hide any previous reward
		rewardFrame.gui.Visible = false
		
		-- Update slots and get winning position
		local winningSlot = self:updateSlots(reward)
		
		-- Animate the spin
		local startRotation = slotContainer.Rotation
		local totalRotation = SPIN_ROTATIONS * 360 + (winningSlot-1) * (360/SLOT_COUNT)
		
		-- Play spin sound
		local spinSound = Instance.new("Sound")
		spinSound.SoundId = "rbxassetid://133559603" -- Spinning sound
		spinSound.Volume = 0.5
		spinSound.Parent = gui.gui
		spinSound:Play()
		
		Utilities.Tween(SPIN_DURATION, 'easeOutCubic', function(a)
			slotContainer.Rotation = startRotation + totalRotation * a
		end)
		
		spinSound:Stop()
		spinSound:Destroy()
		
		-- Play win sound
		local winSound = Instance.new("Sound")
		winSound.SoundId = "rbxassetid://2974000125" -- Win sound
		winSound.Volume = 0.7
		winSound.Parent = gui.gui
		winSound:Play()
		
		-- Show reward
		wait(SPIN_DURATION + 0.5)
		self:showReward(reward)
		
		game:GetService("Debris"):AddItem(winSound, 3)
		isSpinning = false
		spinButton.BackgroundColor3 = Color3.new(0, 0.6, 0)
	end
	
	function Roulette:showReward(reward)
		rewardFrame.gui.Visible = true
		rewardFrame.gui:ClearAllChildren()
		
		-- Create new elements inside
		local rewardImage = create 'ImageLabel' {
			Size = UDim2.new(0.6, 0, 0.6, 0),
			Position = UDim2.new(0.2, 0, 0.1, 0),
			BackgroundTransparency = 1.0,
			ZIndex = 7,
			Parent = rewardFrame.gui,
		}
		
		if reward.type == "pokemon" then
			local icon
			pcall(function()
				icon = _p.Pokemon:getIcon(reward.name)
			end)
			
			if icon then
				icon.Size = UDim2.new(1, 0, 1, 0)
				icon.Parent = rewardImage
			else
				rewardImage.Image = "rbxassetid://6932435438" -- Default placeholder image
			end
			
			write('You got '..reward.name..' (Lv. '..reward.level..')!') {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.8, 0),
					ZIndex = 8,
					Parent = rewardFrame.gui,
				},
				Scaled = true,
				TextColor3 = Color3.new(1, 1, 1),
			}
		else
			local icon
			pcall(function() 
				icon = _p.Menu.bag:getItemIcon(reward.name:lower():gsub(" ", ""))
			end)
			
			if icon then
				icon.Size = UDim2.new(1, 0, 1, 0)
				icon.Parent = rewardImage
			else
				rewardImage.Image = "rbxassetid://6932435438" -- Default placeholder image
			end
			
			write('You got '..reward.quantity..'x '..reward.name..'!') {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.8, 0),
					ZIndex = 8,
					Parent = rewardFrame.gui,
				},
				Scaled = true,
				TextColor3 = Color3.new(1, 1, 1),
			}
		end
		
		wait(3)
		rewardFrame.gui.Visible = false
	end
	
	function Roulette:open()
		if isOpen then return end
		isOpen = true
		
		self:init()
		gui.gui.Visible = true
		
		-- Disable player movement
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		
		-- Animate opening
		local xs = gui.Position.X.Scale
		local xe = 0.1
		Utilities.Tween(0.5, 'easeOutCubic', function(a)
			if not isOpen then return false end
			gui.Position = UDim2.new(xs + (xe-xs)*a, 0, 0.1, 0)
		end)
	end
	
	function Roulette:close()
		if not isOpen then return end
		isOpen = false
		
		-- Animate closing
		local xs = gui.Position.X.Scale
		local xe = 1
		Utilities.Tween(0.5, 'easeOutCubic', function(a)
			if isOpen then return false end
			gui.Position = UDim2.new(xs + (xe-xs)*a, 0, 0.1, 0)
		end)
		
		-- Re-enable player movement
		_p.MasterControl.WalkEnabled = true
		
		wait(0.5)
		gui.gui.Visible = false
	end

	-- Return the module with the open function
	Roulette.open = Roulette.open
	
	return Roulette
end
