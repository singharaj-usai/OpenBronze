return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local shinyChance, roamChance, haChance, maxIvs = 0, 0, 0, 0
	local Chaining = {
		enabled = false,
		chainData = {
			'', --Name
			1, --Icon
			0, --Chain
		},
		currentIcon = 1,
		queue = {}
	}
	local chainSections = {
		251, 201, 151,
		101, 91, 81,
		71, 61, 51,
		41, 31, 21,
		11, 0
	}
	local chainToColor = {
		Color3.fromRGB(255, 170, 0),
		Color3.fromRGB(170, 0, 255),
		Color3.fromRGB(184, 61, 255),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(0, 85, 255),
		Color3.fromRGB(85, 85, 255),
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 26, 26),
		Color3.fromRGB(255, 42, 42),
		Color3.fromRGB(255, 69, 69),
		Color3.fromRGB(255, 105, 105),
		Color3.fromRGB(255, 137, 137),
		Color3.fromRGB(255, 172, 172),
		Color3.fromRGB(255, 194, 194),
		Color3.fromRGB(255, 255, 255),
	}
	function Chaining:toggleChain(enable)
		if not self.gui then
			return
		end
		if self.enabled and not enable then
			Utilities.spTween(self.gui, "Position", UDim2.fromScale(1.1, 0), 0.5, "easeOutCubic")
			self.enabled = false
		elseif not self.enabled and enable then
			Utilities.spTween(self.gui, "Position", UDim2.fromScale(-0.1, 0), 0.5, "easeOutCubic")
			self.enabled = true
			self:doQueuedUpdates()
		end
	end
	function Chaining:addToQueue(tag)
		if not table.find(self.queue, tag) then
			self.queue[#self.queue+1] = tag
		end
	end
	function Chaining:doQueuedUpdates()
		if not self.gui then
			self.queue = {}
			return
		end
		for _, tag in pairs(self.queue) do
			if tag == 'doColorUpdate' then
				for i, chain in pairs(chainSections) do
					if self.chainData[3] >= chain and self.gui.Chain.TextColor3 ~= chainToColor[i] then				
						Utilities.spTween(self.gui.Chain, "TextColor3", chainToColor[i], 0.25, "easeOutCubic")
						break
					end
				end	
			elseif tag == 'doFailedChainNotif' then

			elseif tag == 'doIconUpdate' then

			elseif tag == 'doChanceUpdate' then
				shinyChance, roamChance, haChance, maxIvs = _p.Network:get('PDS', 'getChainInfo')
			end
		end
		self.queue = {}
	end
	
	function Chaining:updateChain()
		--if not _p.Network:get('PDS', 'hasIngredient', 'meteorite', 5) then
		--	return
		--end
		self.queue = {}
		if not self.gui then
			self:createChainGUI()
			self.gui.Pokemon.Text = self.chainData[1] --Should fix issues
		end
		if self.chainData[3] >= 5 then
			self.gui.Chain.Text = self.chainData[3]
			self:addToQueue('doChanceUpdate')
			if self.currentIcon ~= self.chainData[2] then
				self.gui.Pokemon.Text = self.chainData[1]
				self:updateChainIcon(self.chainData[2])
			end
			self:addToQueue('doColorUpdate')
			if not self.enabled and not _p.Battle.currentBattle then
				self.enabled = true
				Utilities.spTween(self.gui, "Position", UDim2.fromScale(-0.1, 0), 0.5, "easeOutCubic")
			end	
			return
		elseif tonumber(self.gui.Chain.Text) >= 5 and self.chainData[3] <= tonumber(self.gui.Chain.Text) then
			self:addToQueue('doFailedChainNotif') --I can send this from Actions?
		end
		Utilities.spTween(self.gui, "Position", UDim2.fromScale(1.1, 0), 0.5, "easeOutCubic")
		self.enabled = false
		task.wait(.6)
		self.slot:Destroy()
		self.gui = nil
		self.slot = nil
	end
	
	
	function Chaining:updateChainIcon(icon)
		if not self.gui then
			return
		end
		if self.currentDisplayIcon then
			self.currentDisplayIcon:Destroy()
		end
		self.currentIcon = icon
		icon = _p.Pokemon:getIcon(icon, false)
		icon.Name = 'PokeIcon'
		icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		icon.Size = UDim2.fromScale((68/100), (56/100))
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.ZIndex = 1
		icon.Parent = self.gui
		local img2 = _p.Menu.bag:getItemIcon(4) --do 6 if rare poke?
		img2.SizeConstraint = Enum.SizeConstraint.RelativeYY
		img2.Size = UDim2.new(.5, 0, .5, 0)
		img2.AnchorPoint = Vector2.new(0.5, 0.5)
		img2.Position = UDim2.new(0.75, 0, 0.75, 0)
		img2.ZIndex = 1
		img2.Parent = icon

		self.currentDisplayIcon = icon
	end
	function Chaining:createChainGUI()
		if self.gui then
			return
		end
		self.slot = _p.NotificationManager:ReserveSlot(0.16, 0.16, 3)
		local slotGui = self.slot.gui

		self.gui = Create 'Frame' {
			BorderSizePixel = 0, 
			BackgroundColor3 = Color3.fromRGB(25, 25, 25), 
			Size = UDim2.fromScale(1, 1), 
			Position = UDim2.fromScale(1.1, 0), 
			Parent = slotGui,
			Create("UICorner")({
				CornerRadius = UDim.new(0.08, 0)
			}),
			Create("TextLabel")({
				Name = 'Pokemon',
				BackgroundTransparency = 1, 
				Size = UDim2.fromScale(0.95, 0.2), 
				Position = UDim2.fromScale(0.025, 0.03), 
				ZIndex = 2, 
				Text = 'NULL', 
				Font = Enum.Font.GothamBold, 
				TextScaled = true, 
				TextColor3 = Color3.fromRGB(255, 255, 255)
			}),
			Create("TextLabel")({
				Name = 'Chain',
				BackgroundTransparency = 1, 
				Size = UDim2.fromScale(0.95, 0.2), 
				Position = UDim2.fromScale(0.025, 0.77), 
				ZIndex = 2, 
				Text = "0", 
				Font = Enum.Font.GothamBold, 
				TextScaled = true, 
				TextColor3 = Color3.fromRGB(255, 255, 255)
			})
		}


		self:updateChainIcon(self.chainData[2])
		self.gui.MouseLeave:connect(function()
			if self.chanceSummary then
				self.chanceSummary:Destroy()
				self.chanceSummary = nil
			end
		end)
		self.gui.MouseEnter:connect(function()
			if self.chanceSummary then
				return
			end
			self.chanceSummary = Create ('Frame') ({
				Parent = Utilities.frontGui,
				ZIndex = 2,
				BackgroundColor3 = Color3.fromRGB(55, 55, 55),
				Size = UDim2.new(.35, 0, .2, 0),
				Position = UDim2.new(.5, 0, .5, 0),
				AnchorPoint = Vector2.new(.5, .5),
				Create 'UICorner' {
					CornerRadius = UDim.new(0.08, 0)
				},
				Create("TextLabel")({
					Name = 'shinyChance',
					BackgroundTransparency = 1, 
					Size = UDim2.fromScale(.8, 0.15), 
					Position = UDim2.fromScale(.1, 0.2), 
					ZIndex = 2, 
					Text = "Loading...", 
					Font = Enum.Font.GothamBold, 
					TextXAlignment = Enum.TextXAlignment.Center,
					TextScaled = true, 
					TextColor3 = Color3.fromRGB(255, 170, 0)
				}),
				Create("TextLabel")({
					Name = 'roamChance',
					BackgroundTransparency = 1, 
					Size = UDim2.fromScale(.8, 0.15), 
					Position = UDim2.fromScale(.1, 0.5),  --+.15
					ZIndex = 2, 
					Text = "Loading...", 
					Font = Enum.Font.GothamBold, 
					TextXAlignment = Enum.TextXAlignment.Center,
					TextScaled = true, 
					TextColor3 = Color3.fromRGB(255, 170, 0)
				}),
				Create("TextLabel")({
					Name = 'haChance',
					BackgroundTransparency = 1, 
					Size = UDim2.fromScale(.8, 0.15), 
					Position = UDim2.fromScale(.1, 0.65),  --+.13
					ZIndex = 2, 
					Text = "Loading...", 
					Font = Enum.Font.GothamBold, 
					TextXAlignment = Enum.TextXAlignment.Center,
					TextScaled = true, 
					TextColor3 = Color3.fromRGB(255, 170, 0)
				}),
				Create("TextLabel")({
					Name = 'maxIvs',
					BackgroundTransparency = 1, 
					Size = UDim2.fromScale(.8, 0.15), 
					Position = UDim2.fromScale(.1, 0.8),  --+.13
					ZIndex = 2, 
					Text = "Loading...", 
					Font = Enum.Font.GothamBold, 
					TextXAlignment = Enum.TextXAlignment.Center,
					TextScaled = true, 
					TextColor3 = Color3.fromRGB(255, 170, 0)
				}),
				Create("TextLabel")({
					Name = '_',
					BackgroundTransparency = 1, 
					Size = UDim2.fromScale(.8, 0.3), 
					Position = UDim2.fromScale(.1, 1.05),  --+.13
					ZIndex = 2, 
					Text = "Please note these percentages don't consider Charms and Ro-Powers! These also don't show the % to encounter but instead the % of how much more common they are.", 
					Font = Enum.Font.GothamBold, 
					TextXAlignment = Enum.TextXAlignment.Center,
					TextScaled = true, 
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Create 'UIStroke' {
						Color = Color3.fromRGB(0, 0, 0),
						Thickness = 3
					},
				}),
			})

			local Name = Utilities.Write('[EMPTY]'..self.chainData[1])({
				Frame = Create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.2, 0),
					Position = UDim2.new(0, 0, -0.1, 0),
					ZIndex = 3,
					Parent = self.chanceSummary
				}),
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Center
			}).Empties
			local icon = _p.Pokemon:getIcon(self.chainData[2], true)
			icon.Size = UDim2.new(2.7, 0, 2, 0)
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.ResampleMode = Enum.ResamplerMode.Default
			icon.Position = UDim2.new(0.5, 0.5)
			icon.ZIndex = 3
			icon.Parent = Name[1]
			task.wait(1.5)
			if not self.chanceSummary then
				return
			end
			--I should Probably Cache these values so I don't spam server with requests
			self.chanceSummary.shinyChance.Text = 'Shiny Chance: '..shinyChance..'%'
			self.chanceSummary.roamChance.Text = 'Roaming Chance: '..roamChance..'%'
			self.chanceSummary.haChance.Text ='Hidden Ability Chance: '.. haChance..'%'
			self.chanceSummary.maxIvs.Text = maxIvs..'x31'

		end)

	end

	_p.Network:bindEvent("updateChain", function(info)
		_p.Chaining.chainData = {
			info['poke'],
			info['icon'],
			info['currentChain']
		}
		_p.Chaining:updateChain()
		if info.forceQueue then
			_p.Chaining:doQueuedUpdates()
		end
	end)

	return Chaining
end