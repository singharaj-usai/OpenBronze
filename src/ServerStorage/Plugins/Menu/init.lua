print("Menu loaded")
return function(_p)
	local player = game:GetService('Players').LocalPlayer
	local stepped = game:GetService('RunService').RenderStepped

	--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local gui = Utilities.gui
	local MasterControl = _p.MasterControl
	local Sprite
	local movesOutsideBattle = require(script.MovesOutsideBattle)(_p)

	local Menu = {
		enabled = false,
		isOpen = false,
	}
	local roundedFrame, playerData; function Menu:init()
		roundedFrame = _p.RoundedFrame
		playerData = _p.PlayerData
		Sprite = _p.Battle._SpriteClass
	end



	-- Menu
	function Menu:setButtonEnabled(id, enabled)
		local container = self.gui.MainContainer
		container[id].Visible = enabled
		container[id..'Text'].Visible = enabled
	end

	function Menu:rewriteTrainerName()
		pcall(function() self.gui.MainContainer.TrainerText:ClearAllChildren() end)
		write(_p.PlayerData.trainerName) {
			Frame = self.gui.MainContainer.TrainerText, Scaled = true,
			--		Color = textColor,
		}
	end

	do
		local promptOn = false
		function Menu:comingSoon()
			if promptOn then return end
			promptOn = true
			local rf = roundedFrame:new {
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.03,
				BackgroundColor3 = Color3.new(.3, .3, .3),
				Size = UDim2.new(.4, 0, .4, 0),
				Position = UDim2.new(.3, 0, .3, 0),
				Parent = Utilities.backGui,
			}
			write 'Coming soon!' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.225, 0),
					Position = UDim2.new(0.5, 0, 0.1, 0),
					ZIndex = 2, Parent = rf.gui,
				}, Scaled = true,
			}
			write 'This feature is not' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.5, 0, 0.4, 0),
					ZIndex = 2, Parent = rf.gui,
				}, Scaled = true,
			}
			write 'yet available.' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.1, 0),
					Position = UDim2.new(0.5, 0, 0.55, 0),
					ZIndex = 2, Parent = rf.gui,
				}, Scaled = true,
			}
			local ok; ok = roundedFrame:new {
				Button = true,
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.02,
				BackgroundColor3 = Color3.new(.2, .2, .2),
				Size = UDim2.new(0.5, 0, 0.2, 0),
				Position = UDim2.new(0.25, 0, 0.7, 0),
				ZIndex = 2, Parent = rf.gui,
				MouseButton1Click = function()
					ok:remove()
					rf:remove()
					promptOn = false
				end,
			}
			write 'OK' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.7, 0),
					Position = UDim2.new(0.5, 0, 0.15, 0),
					ZIndex = 3, Parent = ok.gui,
				}, Scaled = true,
			}
		end
	end

	-- Network:get('PDS', 'saveGame', {
	--	tName = PlayerData.trainerName,
	--	[expShareOn]
	--	[repel = {
	--		steps
	--		kind
	--	}]
	--	options = {
	--		[autosaveEnabled]
	--		[reduceGraphics]
	--		lastUnstuckTick
	--	}
	--	location (in base64 string) }
	function Menu:saveGame()
		local chat = _p.NPCChat
		if _p.userId < 1 then
			chat:say('You cannot save when playing as a Guest.')
			return false
		end
		if _p.Battle.currentBattle or _p.Trade.sessionId then
			chat:say('Unable to save at this time.')
			return false
		end
		-- todo: ensure this flag is still set
		if self.willOverwriteIfSaveFlag and not chat:say('There is another save file that will be overwritten.', '[y/n]Are you sure you want to save?') then
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()

			return
		end
		spawn(function() chat:say('[ma]Saving...') end)
		local success = _p.PlayerData:save()
		wait()
		chat:manualAdvance()
		if success then
			--		_p.DataManager:commitPermanentKeys()
			Utilities.sound(301970897, nil, nil, 3)
			chat:say('Save successful!')
			self.willOverwriteIfSaveFlag = nil
		else
			chat:say('SAVE FAILED!')
		end
		return success
	end

--[[
function Menu:testTopbarMenu()
	local UserInputService = game:GetService('UserInputService')
	if UserInputService.VREnabled then return end
	local isTopBarOnThisDevice = (pcall(function()
		game:GetService('StarterGui'):SetCore('TopbarEnabled', false)
	end))
	if not isTopBarOnThisDevice then return end
	local tray = create 'Frame' {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(31, 31, 31),
		BackgroundTransparency = .5,
		Size = UDim2.new(1.0, 0, 0.0, 36),
		Position = UDim2.new(0.0, 0, 0.0, -36),
		ZIndex = 8, Parent = Utilities.simulatedCoreGui,
--		create 'Frame' { -- centerline
--			Size=UDim2.new(0,2,0,50),
--			Position=UDim2.new(.5,-1,1,0),
--		}
	}
	local descriptionTray = create 'Frame' {
		ClipsDescendants = true,
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 0.0, 36),
		Parent = Utilities.simulatedCoreGui,
	}
	
	local mc = self.gui.MainContainer
	local buttons = {
		mc.Party,
		mc.Pokedex,
		mc.Bag,
		mc.Trainer,
		mc.Save,
		mc.Options,
	}
	
	for b, button in pairs(buttons) do
		local c = button:Clone()
--		c.BackgroundTransparency = .5
--		c.Image = ''
		c.ZIndex = 9
		c.Size = UDim2.new(0.0, 60, 0.0, 30)
		c.Position = UDim2.new(0.5, 70*(b-4)+5, 0.0, 3)
		for _, ch in pairs(c:GetChildren()) do
--			ch.Size = UDim2.new(ch.Size.X.Scale*2, 0, ch.Size.Y.Scale, 0)
--			ch.Position = UDim2.new(ch.Position.X.Scale-.25, 0, ch.Position.Y.Scale, 0)
			ch.ZIndex = 10
		end
		c.Parent = tray
		buttons[b] = c
	end
	
end--]]

	function Menu:enable()
		if self.enabled then return end
		self.isOpen = false
		self.enabled = true
		local container = self.gui
		if not container then
			local ht = 0.6
			local bw = 0.7
			container = create 'ImageLabel' { -- 184 x 494; tab is 47px wide; border is about 4px thick
				Name = 'Menu',                -- 184 x 555 now
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6810763514', --5778644629,-- 5219830465 -- 5219589883
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(ht/494*184, 0, ht, 0),
				ZIndex = 5,

				create 'ImageButton' {
					Name = 'MainContainer',
					Selectable = false,
					BackgroundTransparency = 1.0,
					Size = UDim2.new(133/184, 0, 1.0, 0),
					ZIndex = 5,

					create 'ImageButton' { -- 150x75
						Name = 'Party',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6150013512',
						ImageColor3 = Color3.new(.2, .6, .9),--Color3.new(1, 0,0),--.2, .6),--0, .5, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						Size = UDim2.new(bw, 0, bw/150*75, 0),
						Position = UDim2.new(0.15, 0, 0.03, 0),
						ZIndex = 6,
						MouseButton1Click = function()
							if not self.enabled then return end
							spawn(function() self:disable() end)
							self.party.forceSwitch = nil
							self.party.battleEvent = nil
							self.party.partyOrder = nil
							self.party.chooseItemTarget = nil
							self.party:open()
						end,

						create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://5219725103',
							ImageColor3 = Color3.new(.45, .6, 1),--Color3.new(1, 0, 0),--Color3.new(.4, .1, .1),--.2, .6, 1),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(0.8, 0, 0.8, 0),
							Position = UDim2.new(0.3, 0, 0.1, 0),
							Rotation = -20,
							ZIndex = 7,
						}
					},
					create 'Frame' {
						Name = 'PartyText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.03, 0),
						Position = UDim2.new(0.5, 0, 0.14, 0),
						ZIndex = 6,
					},

					create 'ImageButton' {
						Name = 'Pokedex',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6150013512',
						ImageColor3 = Color3.new(.8, 0, 0),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						Size = UDim2.new(bw, 0, bw/150*75, 0),
						Position = UDim2.new(0.15, 0, 0.19, 0),
						ZIndex = 6,
						MouseButton1Click = function()
							if not self.enabled then return end
							self.dex:open()
						end,

						create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://6143010408',
							ImageColor3 = Color3.new(1, .35, .35),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(1.0, 0, 1.0, 0),
							Position = UDim2.new(0.25, 0, 0.0, 0),
							Rotation = -20,
							ZIndex = 7,
						}
					},
					create 'Frame' {
						Name = 'PokedexText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.03, 0),
						Position = UDim2.new(0.5, 0, 0.3, 0),
						ZIndex = 6,
					},

					create 'ImageButton' {
						Name = 'Bag',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6150013512',
						ImageColor3 = Color3.new(.9, .6, .2),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						Size = UDim2.new(bw, 0, bw/150*75, 0),
						Position = UDim2.new(0.15, 0, 0.35, 0),
						ZIndex = 6,
						MouseButton1Click = function()
							if not self.enabled then return end
							spawn(function() self:disable() end)
							self.bag:open()
						end,

						create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://6143014291',
							ImageColor3 = Color3.new(1, .75, .5),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(1.0, 0, 1.0, 0),
							Position = UDim2.new(0.25, 0, 0.0, 0),
							Rotation = -20,
							ZIndex = 7,
						}
					},
					create 'Frame' {
						Name = 'BagText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.03, 0),
						Position = UDim2.new(0.5, 0, 0.46, 0),
						ZIndex = 6,
					},

					create 'ImageButton' {
						Name = 'Trainer',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6150013512',
						ImageColor3 = Color3.new(.2, 1, .6),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						Size = UDim2.new(bw, 0, bw/150*75, 0),
						Position = UDim2.new(0.15, 0, 0.51, 0),
						ZIndex = 6,
						MouseButton1Click = function()
							if not self.enabled then return end
							self.card:viewMyCard()
						end,

						create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://6143016842',
							ImageColor3 = BrickColor.new('Lime green').Color,
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(1.0, 0, 1.0, 0),
							Position = UDim2.new(0.25, 0, 0.0, 0),
							Rotation = -20,
							ZIndex = 7,
						}
					},
					create 'Frame' {
						Name = 'TrainerText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.03, 0),
						Position = UDim2.new(0.5, 0, 0.62, 0),
						ZIndex = 6,
					},

					create 'ImageButton' {
						Name = 'Save',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6150013512',
						ImageColor3 = Color3.new(.5, .15, .9),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						Size = UDim2.new(bw, 0, bw/150*75, 0),
						Position = UDim2.new(0.15, 0, 0.67, 0),
						ZIndex = 6,
						MouseButton1Click = function()
							if not self.enabled then return end
							spawn(function() self:disable() end)
							_p.MasterControl.WalkEnabled = false
							_p.MasterControl:Stop()
							if _p.NPCChat:say('[y/n]Would you like to save the game?') then
								if not self:saveGame() then
									_p.NPCChat:say('Please wait a bit and try again.')
								end
							end
							_p.MasterControl.WalkEnabled = true
							--_p.MasterControl:Start()

							self:enable()
						end,

						create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://5119877152',
							ImageColor3 = Color3.new(.8, .3, 1),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(0.7, 0, 0.7, 0),
							Position = UDim2.new(0.35, 0, 0.15, 0),
							Rotation = -20,
							ZIndex = 7,
						}
					},
					create 'Frame' {
						Name = 'SaveText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.03, 0),
						Position = UDim2.new(0.5, 0, 0.78, 0),
						ZIndex = 6,
					},

					create 'ImageButton' {
						Name = 'Options',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6150013512',
						ImageColor3 = BrickColor.new('Hot pink').Color,
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						Size = UDim2.new(bw, 0, bw/150*75, 0),
						Position = UDim2.new(0.15, 0, 0.83, 0),
						ZIndex = 6,
						MouseButton1Click = function()
							local Events = game.ReplicatedStorage.Events
							local Dev = Events.GetDevs:InvokeServer()

							if Dev then
								_p.Menu:disable()
								_p.NPCChat:say("What Do You Want To Open?")

								local options = {"Options", "Dev Pannel", 'Cancel'}
								local choice = options[_p.NPCChat:choose(unpack(options))]

								if choice == "Options" then
									self.options:open()
								elseif choice == "Dev Pannel" then
									self.pannel:open()
								elseif choice == "Cancel" then
									_p.Menu:enable()
								end

							else
								self.options:open()

							end
						end,

						create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://5219785105',
							ImageColor3 = BrickColor.new('Pink').Color,
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(1.0, 0, 1.0, 0),
							Position = UDim2.new(0.25, 0, 0.0, 0),
							Rotation = -20,
							ZIndex = 7,
						}
					},
					create 'Frame' {
						Name = 'OptionsText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.03, 0),
						Position = UDim2.new(0.5, 0, 0.94, 0),
						ZIndex = 6,
					},
				},
				create 'TextButton' { -- tl 137, 22; 41 x 141
					Name = 'MenuButton',
					Text = '',
					BackgroundTransparency = 1.0,
					Rotation = 90,
					Size = UDim2.new(141/184, 0, 41/494, 0),
					Position = UDim2.new(86/184, 0, 72/494, 0),
					MouseButton1Click = function()
						if not self.enabled then return end
						if not self.isOpen then
							self:open()

						else
							self:close()
						end
					end,

					create 'Frame' {
						Name = 'ButtonText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.8, 0),
						Position = UDim2.new(0.5, 0, 0.05, 0),
						ZIndex = 6,
					}
				}
			}
			container.Parent = gui
			container.Position = UDim2.new(0.0, -container.AbsoluteSize.X, 0.3, 0)
			local textColor = Color3.new(1, 1, 1)--Color3.new(.2, .2, .2)
			write 'MENU' {
				Frame = container.MenuButton.ButtonText, Scaled = true,
				Color = textColor,
				--			Transparency = .1,
			}
			write 'Pok[e\']mon' {
				Frame = container.MainContainer.PartyText, Scaled = true,
				Color = textColor,
			}
			write 'Pok[e\']dex' {
				Frame = container.MainContainer.PokedexText, Scaled = true,
				Color = textColor,
			}
			write 'Bag' {
				Frame = container.MainContainer.BagText, Scaled = true,
				Color = textColor,
			}
			write(_p.PlayerData.trainerName) {
				Frame = container.MainContainer.TrainerText, Scaled = true,
				Color = textColor,
			}
			write 'Save' {
				Frame = container.MainContainer.SaveText, Scaled = true,
				Color = textColor,
			}
			write 'Options' {
				Frame = container.MainContainer.OptionsText, Scaled = true,
				Color = textColor,
			}
			self.gui = container
			if self.rtd and self.rtd.gui then
				self.rtd.gui.Parent = container
			end
		end
		if self.newGameFlag then
			self.newGameFlag = nil
			self:setButtonEnabled('Party', false)
			self:setButtonEnabled('Pokedex', false)
		end
		container.Visible = true
		local xs = container.Position.X.Offset
		local xe = -container.AbsoluteSize.X/184*133
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if not self.enabled then return false end
			container.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.3, 0)
		end)
	end
	gui.Changed:connect(function()
		local container = Menu.gui
		if not container then return end
		if Menu.enabled and not Menu.open then
			container.Position = UDim2.new(0.0, -container.AbsoluteSize.X/184*133, 0.3, 0)
		elseif not Menu.enabled then
			container.Position = UDim2.new(0.0, -container.AbsoluteSize.X, 0.3, 0)
		end
	end)

	function Menu:disable()
		if not self.enabled then return end
		self.enabled = false
		spawn(function() self.rtd:close() end)
		spawn(function() self.rtd:closePlayerSearch() end)
		local container = self.gui
		local xs = container.Position.X.Offset
		local xe = -container.AbsoluteSize.X
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if self.enabled then return end
			container.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.3, 0)
		end)
		container.Visible = false
	end

	function Menu:open()
		if _p.NPCChat.chatBox and _p.NPCChat.chatBox.Parent then return end
		if self.isOpen or not self.enabled then return end
		self.isOpen = true
		local rtdGui, rtdX--rtdS, rtdE
		if self.rtd.gui and self.rtd.isOpen then
			self.rtd.isOpen = false
			--spawn(function() self.rtd:close() end)
			rtdGui = self.rtd.gui
			rtdX = rtdGui.AbsolutePosition.X
			--		rtdS = rtdGui.Position.X.Scale
			--		rtdE = 0
		end
		local container = self.gui
		local xs = container.Position.X.Offset
		local xe = 0
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if not self.isOpen or not self.enabled or self.rtd.isOpen then return false end
			container.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.3, 0)
			if rtdGui then
				--			rtdGui.Position = UDim2.new(rtdS + (rtdE-rtdS)*a, 0, rtdGui.Position.Y.Scale, 0)
				rtdGui.Position = UDim2.new(0.0, (rtdX*(1-a))-container.AbsolutePosition.X, rtdGui.Position.Y.Scale, 0)
			end
		end)
		if self.isOpen and rtdGui and not self.rtd.isOpen then
			rtdGui.Position = UDim2.new(0.0, 0, rtdGui.Position.Y.Scale, 0)
		end
	end

	function Menu:close()
		if not self.isOpen or not self.enabled then return end
		self.isOpen = false
		local container = self.gui
		local xs = container.Position.X.Offset
		local xe = -container.AbsoluteSize.X/184*133
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if self.isOpen or not self.enabled then return false end
			container.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.3, 0)
		end)
	end


	-- Party
	Menu.party = {
		isOpen = false,
		slots = {},
		hpbars = {},
		switching = false,
		mobDebounce = false, -- mob = moves outside battle
	}
	function Menu.party:clearSlot(slot)
		slot.IconContainer:ClearAllChildren()
		slot.NameContainer:ClearAllChildren()
		slot.GenderContainer:ClearAllChildren()
		slot.LevelContainer:ClearAllChildren()
		slot.HealthContainer:ClearAllChildren()
		slot.ItemContainer:ClearAllChildren()
		slot.hpdiv.text:ClearAllChildren()
		slot.status.text:ClearAllChildren()
		slot.UsableMoveContainer:ClearAllChildren()

		slot.ImageTransparency = 0.5
		slot.ImageColor3 = self.battleEvent and Color3.new(0, 0, 0) or Color3.new(.5, .5, .5)
		slot.hpdiv.Visible = false
		slot.status.Visible = false
	end

	function Menu.party:updateSlotForPokemon(slot, hpbar, pokemon)
		self:clearSlot(slot)

		if not pokemon then return end
		slot.ImageTransparency = 0.0
		if self.battleEvent then
			slot.ImageColor3 = (pokemon.hp and pokemon.hp>0) and Color3.new(.8, 1, .4) or Color3.new(1, .25, .1)
		else
			slot.ImageColor3 = Color3.new(1, 1, 1)
		end
		slot.hpdiv.Visible = true
		-- icon
		_p.Pokemon:getIcon(pokemon.icon, pokemon.shiny).Parent = slot.IconContainer
		-- name
		write(pokemon.name) {
			Frame = slot.NameContainer,
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
		if pokemon.egg then
			hpbar.gui.Parent.Visible = false
			slot.status.Visible = false
		else
			-- gender
			if pokemon.gender and pokemon.gender ~= '' then
				write('['..pokemon.gender:upper()..']') {
					Frame = slot.GenderContainer,
					Color = pokemon.gender=='F' and Color3.new(1, .44, .81) or BrickColor.new('Cyan').Color,
					Scaled = true,
				}
			end
			-- level
			write('Lv. '..pokemon.level) {
				Frame = slot.LevelContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
			-- hp
			local hp = pokemon.hp
			local maxhp = pokemon.maxhp
			hpbar.gui.Parent.Visible = true
			hpbar:setFillbarRatio(hp/maxhp)
			write(hp..'/'..maxhp) {
				Frame = slot.HealthContainer,
				Scaled = true,
			}
			write 'HP' {
				Frame = slot.hpdiv.text,
				Scaled = true,
			}
			-- item
			if pokemon.itemIcon then
				local icon = _p.Menu.bag:getItemIcon(pokemon.itemIcon)
				icon.Size = UDim2.new(1.0, 0, 1.0, 0)
				icon.Position = UDim2.new()
				icon.Parent = slot.ItemContainer
			end
			-- status
			self:updateStatusLabel(slot.status, pokemon.status)
			-- moves usable outside battle
			if not self.battleEvent and pokemon.um then
				local usableMoveCount = 0
				for _, moveId in pairs(pokemon.um) do
					local um = movesOutsideBattle[moveId]
					if um then
						local button = create 'ImageButton' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://'..um.icon,
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(1.0, 0, 1.0, 0),
							Position = UDim2.new(0.25*usableMoveCount, 0, 0.0, 0),
							ZIndex = 5, Parent = slot.UsableMoveContainer,
							MouseButton1Click = function()
								if self.mobDebounce then return end
								self.mobDebounce = true
								local can = um.canUse(pokemon)
								if type(can) == 'string' then
									_p.NPCChat:say(can)
								elseif can then
									um.onUse(pokemon)
								else -- false condition needed?

								end
								self.mobDebounce = false
							end
						}
						if um.iconName then
							write(um.iconName) {
								Frame = create 'Frame' {
									BackgroundTransparency = 1.0,
									Size = UDim2.new(0.0, 0, 0.4, 0),
									Position = UDim2.new(.5, 0, .3, 0),
									ZIndex = 6, Parent = button
								}, Scaled = true
							}
						end
						usableMoveCount = usableMoveCount + 1
					end
				end
			end
		end
	end

	function Menu.party:updateStatusLabel(gui, status)
		local statuses = {
			brn = {'BRN', Color3.new(238/255,  70/255,  44/255)},
			frz = {'FRZ', Color3.new(179/255,       1, 240/255)},
			par = {'PAR', Color3.new(240/255, 203/255,  67/255)},
			psn = {'PSN', Color3.new(175/255, 106/255, 206/255)},
			tox = {'PSN', Color3.new(111/255,   9/255,  95/255), Color3.new(188/255, 153/255, 205/255)},
			slp = {'SLP', Color3.new(160/255, 185/255, 175/255)},
		}
		if status then
			status = status:match('^(%D+)')
		end
		local s = statuses[status]
		if not s then
			gui.Visible = false
		else
			gui.Visible = true
			for _, ch in pairs(gui:GetChildren()) do
				ch.BackgroundColor3 = s[2]
				pcall(function() ch.ImageColor3 = s[2] end)
			end
			write(s[1]) {
				Frame = gui.text,
				Scaled = true,
				Color = s[3],
			}
		end
	end

	function Menu.party:getNearestSlot(p)
		local c, d
		for i = 1, 6 do
			local s = self.backdrop['Slot'..i]
			local m = (s.AbsolutePosition-p).magnitude
			if not d or m < d then
				c = i
				d = m
			end
		end
		return c
	end

	function Menu.party:open(image)
		if self.isOpen then return end
		self.isOpen = true

		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		local backdrop = self.backdrop
		-- run once
		if not backdrop then
			local isPhone = Utilities.isPhone()
			local hpg = isPhone and 1 or 2
			local isDown = false
			--		local lastClickTime, lastClickTarget = 0
			local activeInput
			local function makeSlot(num)
				local slot, slots, cs
				local dragging = false
				local function battleSelectPokemon()
					if self.chooseItemTarget then
						self.battleEvent:fire(tonumber(slot.Parent.Name:sub(5)))
						return
					end
					if self.battleSelectMenuRemove then
						self.battleSelectMenuRemove()
					end
					local num = tonumber(slot.Parent.Name:sub(5))
					local alreadyOut = num<=self.nActive
					local switch = roundedFrame:new {
						Button = true,
						Name = 'SwitchButton',
						BackgroundColor3 = alreadyOut and Color3.new(.3, .3, .3) or BrickColor.new('Dark green').Color,
						Size = UDim2.new(1/5, 0, 1/16, 0),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Parent = Utilities.frontGui,
						MouseButton1Click = function()
							if alreadyOut then return end
							self.battleEvent:fire('switch', num)
						end,
					}
					if self.alreadySwitched and self.alreadySwitched[num] then
						switch.Visible = false
					end
					write(self.selectionText or (alreadyOut and 'Out' or 'Switch')) {
						Frame = create 'Frame' {
							Name = 'ButtonText',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(1.0, 0, 0.7, 0),
							Position = UDim2.new(0.0, 0, 0.15, 0),
							Parent = switch.gui,
							ZIndex = 2,
						},
						Scaled = true,
					}
					switch.Position = UDim2.new(0.0, slot.AbsolutePosition.X+slot.AbsoluteSize.X*.75-switch.AbsoluteSize.X/2, 0.0, slot.AbsolutePosition.Y+slot.AbsoluteSize.Y-switch.AbsoluteSize.Y*.25)
					local summary = roundedFrame:new {
						Button = true,
						Name = 'SummaryButton',
						BackgroundColor3 = BrickColor.new('Dark green').Color,
						Size = UDim2.new(1.25/5, 0, 1/16, 0),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Parent = Utilities.frontGui,
						MouseButton1Click = function()
							self.battleSelectMenuRemove()
							local n = num
							pcall(function() n = self.partyData[n].index end)
							print('summary index:', n)
							self:viewSummary(n)
						end,
					}
					write 'Summary' {
						Frame = create 'Frame' {
							Name = 'ButtonText',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(1.0, 0, 0.7, 0),
							Position = UDim2.new(0.0, 0, 0.15, 0),
							Parent = summary.gui,
							ZIndex = 2,
						},
						Scaled = true,
					}
					summary.Position = UDim2.new(0.0, slot.AbsolutePosition.X+slot.AbsoluteSize.X*.25-switch.AbsoluteSize.X/2, 0.0, slot.AbsolutePosition.Y+slot.AbsoluteSize.Y-switch.AbsoluteSize.Y*.25)
					self.battleSelectMenuRemove = function()
						switch:remove()
						summary:remove()
					end

				end
				local slides = {}
				local function slideTo(slot, p)
					local this = {}
					slides[slot] = this
					local s = slot.AbsolutePosition
					local o = p - s
					local ps = slot.Parent.AbsolutePosition
					spawn(function()
						Utilities.Tween(.2, 'easeOutCubic', function(a)
							if slides[slot] ~= this then return false end
							local pos = s + o*a - ps
							slot.Position = UDim2.new(0.0, pos.x, 0.0, pos.y)
						end)
						if slides[slot] == this then
							slides[slot] = nil
						end
					end)
				end
				local function mouseUp()
					if not isDown then return end
					isDown = false
					if dragging then
						dragging = false
						local s = math.min(self:getNearestSlot(slot.AbsolutePosition), #self.partyData)
						if s < cs then
							for i = cs-1, s, -1 do
								local n = i+1
								slots[n] = slots[i]
								slideTo(slots[n], self.backdrop['Slot'..n].AbsolutePosition)
							end
						elseif s > cs then
							for i = cs+1, s do
								local n = i-1
								slots[n] = slots[i]
								slideTo(slots[n], self.backdrop['Slot'..n].AbsolutePosition)
							end
						end
						slideTo(slot, self.backdrop['Slot'..s].AbsolutePosition)
						slots[s] = slot
						self.slots = slots
						wait(.2)
						slides = {}
						local party = {}
						for i, s in pairs(slots) do
							local from = s==slot and num or tonumber(s.Parent.Name:sub(5))
							party[i] = self.partyData[from]
							s.Position = UDim2.new(0.0, 0, 0.0, 0)
							s.Size = UDim2.new(1.0, 0, 1.0, 0)
							s.Parent = self.backdrop['Slot'..i]
						end
						self.partyData = party
						self.rearranged = true
						self.switching = false
					else
						-- didn't drag enough; open summary
						if self.switching then return end
						local num = tonumber(slot.Parent.Name:sub(5))
						pcall(function() num = self.partyData[num].index end)
						self:viewSummary(num)
					end
				end
				local function mouseDown(inputObject)
					if self.state ~= 'open' or not self.partyLoaded then return end
					if isDown or self.switching or slot.ImageTransparency > 0 then return end
					if self.battleEvent then
						battleSelectPokemon()
						return
					end
					if _p.Battle.currentBattle or _p.Trade.sessionId then return end
					isDown = true
					local getMousePosition
					if inputObject then
						getMousePosition = function()
							local p = inputObject.Position
							return p.X, p.Y
						end
					else
						local mouse = player:GetMouse()
						getMousePosition = function()
							return mouse.X, mouse.Y
						end
					end
					local oPos = Vector2.new(getMousePosition())
					local offset = oPos-slot.AbsolutePosition
					while isDown do -- initial drag threshold
						local mx, my = getMousePosition()
						if (Vector2.new(mx, my)-oPos).magnitude > Utilities.gui.AbsoluteSize.Y*.03 then
							dragging = true
							break
						end
						stepped:wait()
					end
					if isDown then
						num = tonumber(slot.Parent.Name:sub(5))
						cs = num
						slot.Size = UDim2.new(0.0, slot.AbsoluteSize.X, 0.0, slot.AbsoluteSize.Y)
						slot.Parent = Utilities.frontGui
						self.switching = true
						slots = {unpack(self.slots)}
						while isDown do
							local mx, my = getMousePosition()
							slot.Position = UDim2.new(0.0, mx-offset.x, 0.0, my-offset.y)
							local s = self:getNearestSlot(slot.AbsolutePosition)
							if s < cs then
								for i = cs-1, s, -1 do
									local n = i+1
									slots[n] = slots[i]
									slideTo(slots[n], self.backdrop['Slot'..n].AbsolutePosition)
								end
								cs = s
							elseif s > cs then
								for i = cs+1, s do
									local n = i-1
									slots[n] = slots[i]
									slideTo(slots[n], self.backdrop['Slot'..n].AbsolutePosition)
								end
								cs = s
							end
							stepped:wait()
						end
					end
					--				cn:disconnect()
				end
				slot = create 'ImageButton' { -- 450 x 150
					Name = 'Slot',
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://6516825983',
					Size = UDim2.new(1.0, 0, 1.0, 0),
					ZIndex = 3,

					create 'Frame' {
						Name = 'IconContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(.2223, 0, .5, 0),
						Position = UDim2.new(.05, 0, .15, 0),
					},
					create 'Frame' {
						Name = 'NameContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.25, 0),
						Position = UDim2.new(0.25, 0, 0.15, 0),
						ZIndex = 4,
					},
					create 'Frame' {
						Name = 'GenderContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.25, 0),
						Position = UDim2.new(0.9, 0, 0.15, 0),
						ZIndex = 4,
					},
					create 'Frame' {
						Name = 'LevelContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.2, 0),
						Position = UDim2.new(0.2125, 0, 0.65, 0),
						ZIndex = 4,
					},
					create 'Frame' {
						Name = 'HealthContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.2, 0),
						Position = UDim2.new(0.725, 0, 0.65, 0),
						ZIndex = 4,
					},
					create 'Frame' {
						Name = 'ItemContainer',
						BackgroundTransparency = 1.0,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(-0.3, 0, 0.3, 0),
						Position = UDim2.new(0.975, 0, 0.65, 0),
					},
					roundedFrame:new {
						Name = 'hpdiv',
						BackgroundColor3 = Color3.new(.3, .3, .3),
						Size = UDim2.new(0.7, 0, 0.15, 0),
						Position = UDim2.new(0.2, 0, 0.45, 0),
						Style = 'HorizontalBar',
						ZIndex = 4,

						create 'Frame' {
							Name = 'text',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 1.0, -hpg*2),
							Position = UDim2.new(0.12, 0, 0.0, hpg),
							ZIndex = 5,
						},
					},
					roundedFrame:new {
						Name = 'status',
						Size = UDim2.new(0.165, 0, 0.2, 0),
						Position = UDim2.new(0.025, 0, 0.675, 0),
						Style = 'HorizontalBar',
						ZIndex = 4,

						create 'Frame' {
							Name = 'text',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.8, 0),
							Position = UDim2.new(0.5, 0, 0.1, 0),
							ZIndex = 5,
						},
					},
					create 'Frame' {
						Name = 'UsableMoveContainer',
						BackgroundTransparency = 1.0,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(2.0, 0, 0.35, 0),
						Position = UDim2.new(0.15, 0, 0.875, 0)
					}
				}
				slot.InputBegan:connect(function(inputObject)
					if activeInput then return end
					local inputType = inputObject.UserInputType
					local isTouch = inputType == Enum.UserInputType.Touch
					if isTouch or inputType == Enum.UserInputType.MouseButton1 then
						activeInput = inputObject
						local didEnd = false
						local cn; cn = inputObject.Changed:connect(function()
							if didEnd then return end
							if inputObject.UserInputState == Enum.UserInputState.End then
								didEnd = true
								mouseUp()
								activeInput = nil
								pcall(function() cn:disconnect() end)
								cn = nil
							end
						end)
						mouseDown(isTouch and inputObject or nil)
					end
				end)
				self.slots[num] = slot
				local hpbar = roundedFrame:new {
					BackgroundColor3 = Color3.new(.9, .9, .9),
					Size = UDim2.new(0.8, -hpg*2, 1.0, -hpg*2),
					Position = UDim2.new(0.2, hpg, 0.0, hpg),
					Style = 'HorizontalBar',
					ZIndex = 5,
					Parent = slot.hpdiv,
				}
				hpbar:setupFillbar('gyr', hpg)
				self.hpbars[slot] = hpbar
				return slot
			end

			local relWidth = 1.25
			local slotWidth = 9/16/relWidth
			local px = (0.5-slotWidth)/2

			backdrop = create 'ImageLabel' {
				Name = 'PartyBackdrop',
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(relWidth, 0, 1.0, 0),
				Position = UDim2.new(0.0, gui.AbsoluteSize.X, 0.0, 0),
				ZIndex = 2,
				Parent = gui,
			--[[
			2 3
			3 3
			1 1
			3 3
			1 1
			3 3
			3 2
			--]]
				create 'Frame' { -- 450 x 150
					Name = 'Slot1',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(slotWidth, 0, 3/16, 0),
					Position = UDim2.new(px, 0, 2/16, 0),
					makeSlot(1),
				},
				create 'Frame' {
					Name = 'Slot2',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(slotWidth, 0, 3/16, 0),
					Position = UDim2.new(0.5+px, 0, 3/16, 0),
					makeSlot(2),
				},
				create 'Frame' {
					Name = 'Slot3',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(slotWidth, 0, 3/16, 0),
					Position = UDim2.new(px, 0, 6/16, 0),
					makeSlot(3),
				},
				create 'Frame' {
					Name = 'Slot4',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(slotWidth, 0, 3/16, 0),
					Position = UDim2.new(0.5+px, 0, 7/16, 0),
					makeSlot(4),
				},
				create 'Frame' {
					Name = 'Slot5',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(slotWidth, 0, 3/16, 0),
					Position = UDim2.new(px, 0, 10/16, 0),
					makeSlot(5),
				},
				create 'Frame' {
					Name = 'Slot6',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(slotWidth, 0, 3/16, 0),
					Position = UDim2.new(0.5+px, 0, 11/16, 0),
					makeSlot(6),
				},
			}
			local cancel = roundedFrame:new {
				Button = true,
				Name = 'CancelButton',
				Size = UDim2.new(1/5, 0, 1/16, 0),
				Position = UDim2.new(3/4, 0, 1/16, 0),--isPhone and UDim2.new(33/32, 0, 7/16, 0) or UDim2.new(3/4, 0, 1/16, 0),
				ZIndex = 3,
				Parent = backdrop,
				MouseButton1Click = function()
					if self.forceSwitch or self.switching then return end
					if self.battleEvent then
						self.battleEvent:fire('cancel')
						--if self.chooseItemTarget then return end
						return -- close is now performed by BattleGui:switchPokemon() because of the text-loop error
					end
					self:close()
				end,
			}
			write 'Close' {
				Frame = create 'Frame' {
					Name = 'ButtonText',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					Parent = cancel.gui,
					ZIndex = 4,
				},
				Scaled = true,
			}
			local wr = function(prop)
				if prop ~= 'AbsoluteSize' then return end
				cancel.CornerRadius = backdrop.AbsoluteSize.Y*.01
			end
			backdrop.Changed:connect(wr)
			wr('AbsoluteSize')
			self.backdrop = backdrop
			self.cancel = cancel
			self.mouseAbsorber = create 'TextButton' {
				Text = '',
				AutoButtonColor = false,
				BorderSizePixel = 0,
				BackgroundTransparency = 1.0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 60),
				Position = UDim2.new(0.0, 0, 0.0, -40),
			}
		end
		-- run each time
		self.rearranged = nil
		self.partyLoaded = false
		Utilities.fastSpawn(function()
			local rqThread = {}
			self.rqThread = rqThread
			for i = 1, 6 do self:clearSlot(self.slots[i]) end
			local party = _p.Network:get('PDS', 'getParty')
			if self.rqThread ~= rqThread then return end
			for i, p in pairs(party) do p.index = i end
			self.partyData = party
			for i = 1, 6 do
				local slot = self.slots[i]
				self:updateSlotForPokemon(slot, self.hpbars[slot], party[i])
			end
			self.partyLoaded = true
			self.rqThread = nil
		end)
		self.cancel.Visible = not self.forceSwitch
		self.cancel.BackgroundColor3 = self.battleEvent and BrickColor.new('Dark green').Color or BrickColor.new('Deep blue').Color
		backdrop.Image = 'rbxassetid://'..(self.battleEvent and 5227227347 or 5220746009)
		backdrop.Visible = true
		local fader = self.mouseAbsorber
		fader.Parent = Utilities.gui
		local xs = backdrop.Position.X.Offset
		local xe = gui.AbsoluteSize.X/2-backdrop.AbsoluteSize.X/2
		self.state = 'transition'
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpen then return false end
			backdrop.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.0, 0)
			if not self.chooseItemTarget then fader.BackgroundTransparency = 1.0-a*0.7 end
		end)
		self.state = 'open'
	end

	function Menu.party:close()
		if not self.isOpen then return end
		self.isOpen = false

		if not self.battleEvent and self.rearranged and self.partyData then
			local indices = {}
			for i, p in pairs(self.partyData) do
				indices[i] = p.index
			end
			_p.Network:post('PDS', 'rearrangeParty', indices)
		end

		if self.battleSelectMenuRemove then
			self.battleSelectMenuRemove()
			self.battleSelectMenuRemove = nil
		end
		if not self.battleEvent then
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()

			spawn(function() Menu:enable() end)
		end
		local backdrop = self.backdrop
		local fader
		if self.battleEvent then
			if not self.chooseItemTarget then
				fader = Utilities.fadeGui
				fader.ZIndex = 1
				fader.BackgroundColor3 = Color3.new(0, 0, 0)
			end
			self.mouseAbsorber.Parent = nil
		else
			fader = self.mouseAbsorber
		end
		local xs = backdrop.Position.X.Offset
		local xe = gui.AbsoluteSize.X
		self.state = 'transition'
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			--		if a > .5 then Utilities.Signal():wait() end -- test
			if self.isOpen then return false end
			backdrop.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.0, 0)
			if fader then fader.BackgroundTransparency = 0.3+a*0.7 end
		end)
		if not self.isOpen then
			self.mouseAbsorber.Parent = nil
			backdrop.Visible = false
			self.state = 'closed'
			self.rqThread = nil
			self.partyData = nil
			self.rearranged = nil
		end
	end


	function Menu.party:viewSummary(pokemon, ignoreParty, disableMoveSwitching) -- OVH  todo: EV/IV Viewer
		self.state = 'transition'

		local clickAbsorber = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = Utilities.frontGui
		}

		if type(pokemon) == 'number' then
			pokemon = _p.Network:get('PDS', 'getPokemonSummary', pokemon)
		end
		if not pokemon then
			clickAbsorber:remove()
			self.state = 'open'
			return
		end

		local main = create 'ImageLabel' {
			Name = 'Summary',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5220782424',
			ImageColor3 = Color3.new(.6, .6, .8),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.9, 0, 0.9, 0),
			Position = UDim2.new(2.0, 0, 0.0, 0),
			ZIndex = 5, Parent = Utilities.frontGui
		}
		local rframes = {}
		local name = pokemon.name
		local num = 'No. ' .. (pokemon.num or 0)
		if pokemon.nickname and pokemon.nickname ~= name then
			num = num .. ' (' .. name .. ')'
		end
		local ballIcon
		if pokemon.ballIcon then
			ballIcon = Menu.bag:getItemIcon(pokemon.ballIcon)
			ballIcon.Size = UDim2.new(.09, 0, .09, 0)
			ballIcon.Position = UDim2.new(.005, 0, .015, 0)
			ballIcon.ZIndex = 6
			ballIcon.Parent = main
		end
		write(pokemon.nickname or name) {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.07, 0),
				Position = UDim2.new(ballIcon and .09 or 0.04, 0, 0.025, 0),
				ZIndex = 6, Parent = main
			}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left
		}
		local cry
		if pokemon.egg then
			local eggStage = pokemon.eggStage or 1

			local phrase1, phrase2
			if pokemon.fossilEgg then
				phrase1 = 'A fossilized pokemon Egg.'
				phrase2 = 'It\'s rock-hard. It doesn\'t seem to be alive, but you never know...'
			else
				phrase1 = 'A mysterious pokemon Egg.'
				local eggWatch = ({
					'What will hatch from this? It will take some time.',
					'It moves around occasionally. It must be close to hatching.',
					'It\'s making sounds. It\'s about to hatch!'
				})[eggStage]
				phrase2 = 'The Egg Watch: '..eggWatch
			end
			local icon = (_p.Pokemon:getIcon(pokemon.icon, pokemon.shiny))
			if icon and #icon:GetChildren() > 0 then
				local eggIcon = icon:GetChildren()[1]
				local spriteContainer = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.4, 0),
					Position = UDim2.new(0.55, 0, 0.15, 0),
					Parent = main
				}
				eggIcon.Parent = spriteContainer
				icon:remove()
				local s = .6
				eggIcon.Size = UDim2.new(s, 0, s, 0)
				eggIcon.Position = UDim2.new(.5-s/2, 0, 1-s, 0)
				if eggStage > 1 then
					delay(1, function()
						while eggIcon.Parent do
							Utilities.Tween(2, nil, function(a)
								local p = math.cos(a*math.pi*2)
								local sy = s*.85
								local oy = 0
								if p > 0 then
									if eggStage == 3 and a > .5 then return false end
									sy = s*(.85+p*.15)
								else
									local p2 = math.sin((a*math.pi*2-math.pi/2)*1.2)
									if p2 > 0 then
										sy = s*(.85+p2*.25)
									end
									oy = p*s*.3
								end
								eggIcon.Size = UDim2.new(s, 0, sy, 0)
								eggIcon.Position = UDim2.new(.5-s/2, 0, 1-sy+oy, 0)
							end)
							if eggStage == 3 then
								Utilities.Tween(2, nil, function(a)
									local p = math.sin(a*math.pi*2)
									local sy = s
									if a < .25 then
										sy = s*(.85+p*.15)
									end
									eggIcon.Rotation = 45*p
									eggIcon.Size = UDim2.new(s, 0, sy, 0)
									eggIcon.Position = UDim2.new(.5-s/2+s*p/math.pi, 0, 1-sy, 0)
								end)
								wait(1)
							else
								wait(3)
							end
						end
					end)
				end
			end
			table.insert(rframes, roundedFrame:new {
				CornerRadius = gui.AbsoluteSize.Y*.025,
				BackgroundColor3 = Color3.new(.3, .3, .3),
				Size = UDim2.new(0.35, 0, 0.16, 0),
				Position = UDim2.new(0.025, 0, 0.8275, 0),
				ZIndex = 6, Parent = main,
			})
			write(phrase1) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.305, 0, 0.0325, 0),
					Position = UDim2.new(0.0475, 0, 0.84, 0),
					ZIndex = 7, Parent = main, BackgroundTransparency = 1.0,
				}, Wraps = true,
			}
			table.insert(rframes, roundedFrame:new {
				CornerRadius = gui.AbsoluteSize.Y*.025,
				BackgroundColor3 = Color3.new(.3, .3, .3),
				Size = UDim2.new(0.55, 0, 0.16, 0),
				Position = UDim2.new(0.425, 0, 0.8275, 0),
				ZIndex = 6, Parent = main,
			})
			write(phrase2) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.505, 0, 0.0325, 0),
					Position = UDim2.new(0.4475, 0, 0.84, 0),
					ZIndex = 7, Parent = main, BackgroundTransparency = 1.0,
				}, Wraps = true,
			}
		else
			write(num) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.0475, 0, 0.125, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			local statusRF
			local status = pokemon.status
			if status and status ~= '' then
				status = status:match('^(%D+)')
				local statuses = {
					brn = {'BRN', Color3.new(238/255,  70/255,  44/255)},-- Color3.new(222/255, 23/255, 31/255)},
					frz = {'FRZ', Color3.new(179/255,       1, 240/255)},
					par = {'PAR', Color3.new(240/255, 203/255,  67/255)},
					psn = {'PSN', Color3.new(175/255, 106/255, 206/255)},
					tox = {'PSN', Color3.new(111/255,   9/255,  95/255), Color3.new(188/255, 153/255, 205/255)},
					slp = {'SLP', Color3.new(160/255, 185/255, 175/255)},
				}
				local s = statuses[status]
				if s then
					statusRF = roundedFrame:new {
						BackgroundColor3 = s[2],
						Size = UDim2.new(0.15, 0, 0.05, 0),
						Position = UDim2.new(0.04, 0, 0.2, 0),
						Style = 'HorizontalBar',
						ZIndex = 6,
						Parent = main,

						create 'Frame' {
							Name = 'text',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.9, 0),
							Position = UDim2.new(0.5, 0, 0.05, 0),
							ZIndex = 7,
						},
					}
					table.insert(rframes, statusRF)
					write(s[1]) {
						Frame = statusRF.gui.text,
						Scaled = true,
						Color = s[3],
					}
				end
			end
			if not statusRF then
				write 'HP' {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.0475, 0, 0.2, 0),
						ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}
			end
			local hp = pokemon.hp
			local maxhp = pokemon.maxhp
			write(hp..'/'..maxhp) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.4525, 0, 0.2, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
			}
			local hprf = roundedFrame:new {
				BackgroundColor3 = Color3.new(.3, .3, .3),
				Size = UDim2.new(0.4, 0, 0.025, 0),
				Position = UDim2.new(0.05, 0, 0.2625, 0),
				Style = 'HorizontalBar',
				ZIndex = 6,
				Parent = main,
			}
			hprf:setupFillbar('gyr', Utilities.isPhone() and 1 or 2, hp/maxhp)
			table.insert(rframes, hprf)
			local statsRF = roundedFrame:new {
				CornerRadius = gui.AbsoluteSize.Y*.025,
				BackgroundColor3 = BrickColor.new('Cyan').Color,
				Size = UDim2.new(0.45, 0, 0.4, 0),
				Position = UDim2.new(0.025, 0, 0.3, 0),
				ZIndex = 6,
				Parent = main,
			}
			table.insert(rframes, statsRF)
			create 'Frame' {
				BackgroundTransparency = 0.75,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1.0, 0, 0.2, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				ZIndex = 7,
				Parent = statsRF.gui,
			}
			create 'Frame' {
				BackgroundTransparency = 0.75,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1.0, 0, 0.2, 0),
				Position = UDim2.new(0.0, 0, 0.6, 0),
				ZIndex = 7,
				Parent = statsRF.gui,
			}
			local nature = _p.Pokemon:getNature(pokemon.nature)
			local statnames = {'atk','def','spa','spd','spe'}
			for i, s in pairs({'Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed'}) do
				local statname = statnames[i]
				write(s) {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.1, 0),
						Position = UDim2.new(0.05, 0, 0.2*(i-1)+.05, 0),
						ZIndex = 8, Parent = statsRF.gui, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					Color = (nature.minus==statname and Color3.new(1, 1, .6) or (nature.plus==statname and Color3.new(.6, 1, .6)) or Color3.new(1, 1, 1)),
				}
				write(tostring(pokemon.stats[i])) {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.1, 0),
						Position = UDim2.new(0.95, 0, 0.2*(i-1)+.05, 0),
						ZIndex = 8, Parent = statsRF.gui, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
				}
			end
			-- disable if in battle?
			local effortViewer = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5221795778',
				ImageColor3 = Color3.new(.4, .8, 1),
				Size = UDim2.new(0.08/240*278, 0, 0.08, 0),
				Position = UDim2.new(0.475, 0, 0.46, 0),
				Rotation = 90, ZIndex = 6, Parent = main,
				MouseButton1Click = function()
					self:showEffort(pokemon)
				end,

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://5221795778',
					ImageColor3 = Color3.new(200/255, 250/255, 140/255),
					Size = UDim2.new(2/3, 0, 2/3, 0),
					Position = UDim2.new(1/6, 0, 1/6, 0),
					ZIndex = 7,
				},
				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://5221795778',
					ImageColor3 = Color3.new(16/255, 170/255, 136/255),
					Size = UDim2.new(1/3, 0, 1/3, 0),
					Position = UDim2.new(1/3, 0, 1/3, 0),
					ZIndex = 8,
				},
			}
			--
			write 'Item:' {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.035, 0),
					Position = UDim2.new(0.0475, 0, 0.715, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write(pokemon.itemName or 'None') {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.035, 0),
					Position = UDim2.new(0.4525, 0, 0.715, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
			}
			write 'Ability:' {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.035, 0),
					Position = UDim2.new(0.0475, 0, 0.775, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write(pokemon.abilityName) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.035, 0),
					Position = UDim2.new(0.4525, 0, 0.775, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
			}
			if pokemon.exp then
				write 'Exp Pts.' {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.035, 0),
						Position = UDim2.new(0.0475, 0, 0.845, 0),
						ZIndex = 7, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}
				write(tostring(pokemon.exp)) {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.035, 0),
						Position = UDim2.new(0.4525, 0, 0.845, 0),
						ZIndex = 7, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
				}
				write 'To Next Lv.' {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.035, 0),
						Position = UDim2.new(0.0475, 0, 0.905, 0),
						ZIndex = 7, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}
				write(tostring(pokemon.expToNx)) {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.035, 0),
						Position = UDim2.new(0.4525, 0, 0.905, 0),
						ZIndex = 7, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
				}
				table.insert(rframes, roundedFrame:new {
					CornerRadius = gui.AbsoluteSize.Y*.025,
					BackgroundColor3 = Color3.new(.3, .3, .3),
					Size = UDim2.new(0.45, 0, 0.16, 0),
					Position = UDim2.new(0.025, 0, 0.8275, 0),
					ZIndex = 6, Parent = main,
				})
				local xp = roundedFrame:new {
					BackgroundColor3 = Color3.new(.1, .1, .1),
					Size = UDim2.new(0.4, 0, 0.02),
					Position = UDim2.new(0.05, 0, 0.955, 0),
					Style = 'HorizontalBar',
					ZIndex = 7, Parent = main,
				}
				xp:setupFillbar(Color3.new(.4, .8, 1), Utilities.isPhone() and 1 or 2, pokemon.expProg)
				table.insert(rframes, xp)
			end


			if pokemon.num ~= 29 and pokemon.num ~= 32 and pokemon.gender and pokemon.gender ~= '' then
				write('['..pokemon.gender:upper()..']') {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.7, 0, 0.035, 0),
						ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, Color = pokemon.gender=='F' and Color3.new(1, .44, .81) or BrickColor.new('Cyan').Color,
				}
			end
			write('Lv '..pokemon.level) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.75, 0, 0.035, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			spawn(function()
				local spriteContainer = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.4, 0),
					Position = UDim2.new(0.55, 0, 0.15, 0),
					Parent = main
				}
				local spriteData = pokemon.sprite
				cry = spriteData.cry
				local anim = _p.AnimatedSprite:new(spriteData)
				local sprite = anim.spriteLabel
				sprite.ZIndex = 8
				local scale = spriteData.scale or 1
				local x = spriteData.fWidth/110*scale
				local y = spriteData.fHeight/110*scale
				sprite.Size = UDim2.new(x, 0, y, 0)
				sprite.Position = UDim2.new(0.5-x/2, 0, 1.0-y, 0)
				sprite.Parent = spriteContainer
				anim:Play()
			end)
			if pokemon.shiny then
				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://5217624409',
					ImageColor3 = BrickColor.new('Persimmon').Color,
					Size = UDim2.new(0.05, 0, 0.05, 0),
					Position = UDim2.new(0.9, 0, 0.5, 0),
					ZIndex = 9, Parent = main,
				}
			end
			for i, t in pairs(_p.Pokemon:getTypes(pokemon.types)) do
				local rf = roundedFrame:new {
					BackgroundColor3 = _p.BattleGui.typeColors[t],
					Size = UDim2.new(0.2, 0, 0.05, 0),
					Position = UDim2.new(0.525+0.225*(i-1), 0, 0.575, 0),
					ZIndex = 6, Style = 'HorizontalBar', Parent = main,
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
			spawn(function()
				local id = pokemon.id
				write 'ID:' {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.035, 0),
						Position = UDim2.new(0.5475, 0, 0.715, 0),
						ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}
				write(tostring(id)) {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.035, 0),
						Position = UDim2.new(0.9525, 0, 0.715, 0),
						ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
				}
				write 'OT:' {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.035, 0),
						Position = UDim2.new(0.5475, 0, 0.655, 0),
						ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
				}
				local ot = _p.Pokemon:getOT(id)
				if not ot or not main.Parent then return end
				write(ot) {
					Frame = create 'Frame' {
						Size = UDim2.new(0.0, 0, 0.035, 0),
						Position = UDim2.new(0.9525, 0, 0.655, 0),
						ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
				}
			end)
			write 'Nature:' {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.035, 0),
					Position = UDim2.new(0.5475, 0, 0.775, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write(nature.name) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.035, 0),
					Position = UDim2.new(0.9525, 0, 0.775, 0),
					ZIndex = 6, Parent = main, BackgroundTransparency = 1.0,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
			}
			table.insert(rframes, roundedFrame:new {
				CornerRadius = gui.AbsoluteSize.Y*.025,
				BackgroundColor3 = Color3.new(.3, .3, .3),
				Size = UDim2.new(0.45, 0, 0.16, 0),
				Position = UDim2.new(0.525, 0, 0.8275, 0),
				ZIndex = 6, Parent = main,
			})
			write('Characteristic: '..pokemon.desc) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.405, 0, 0.0325, 0),
					Position = UDim2.new(0.5475, 0, 0.84, 0),
					ZIndex = 7, Parent = main, BackgroundTransparency = 1.0,
				}, Wraps = true,
			}

			local ht = 0.7
			local bw = 0.8
			local movesOpen = false
			local t = 0
			local moveContainer; moveContainer = create 'ImageLabel' { -- 250 x 347
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5222284808',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(ht/347*250, 0, ht, 0),
				ZIndex = 2,
				Parent = main,

				create 'Frame' {
					Name = 'MainContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(199/250, 0, 1.0, 0),
				},
				create 'TextButton' { -- tl 137, 22; 41 x 141
					Name = 'MovesButton',
					Text = '',
					BackgroundTransparency = 1.0,
					Rotation = 90,
					Size = UDim2.new(141/250, 0, 41/347, 0),
					Position = UDim2.new(153/250, 0, 72/347, 0),
					ZIndex = 2,
					MouseButton1Click = function()
						movesOpen = not movesOpen
						t = t + 1
						local tt = t
						local xs = moveContainer.Position.X.Offset
						local xe = movesOpen and 0 or -moveContainer.AbsoluteSize.X/250*199
						Utilities.Tween(.5, 'easeOutCubic', function(a)
							if t ~= tt then return false end
							moveContainer.Position = UDim2.new(1.0, xs + (xe-xs)*a, 0.2, 0)
						end)
					end,

					create 'Frame' {
						Name = 'ButtonText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.6, 0),
						Position = UDim2.new(0.5, 0, 0.2, 0),
						ZIndex = 4,
					}
				}
			}
			moveContainer.Position = UDim2.new(1.0, -moveContainer.AbsoluteSize.X/250*199, 0.2, 0)
			write 'Moves' {
				Frame = moveContainer.MovesButton.ButtonText,
				Color = Color3.new(.2, .2, .2),
				Scaled = true,
			}
			local moves = pokemon.moves
			local busy = false
			local mrfs = {}
			local details
			local currentlyShowing
			local function showDetails(rf, instant)
				local i = rf.pos
				local move = moves[i]
				busy = true
				if details then
					local oldDetails = details
					details = nil
					if instant then
						oldDetails:remove()
					else
						spawn(function()
							local y = oldDetails.Position.Y.Scale
							Utilities.Tween(.5, 'easeOutCubic', function(a)
								oldDetails.Position = UDim2.new(0.05-a, 0, y, 0)
							end)
							oldDetails:remove()
						end)
					end
				end
				local justClose = move and currentlyShowing == i
				currentlyShowing = i
				for j = 1, 4 do
					if instant then
						if j ~= i then
							mrfs[j].Position = UDim2.new(0.05, 0, 0.05+0.175*(j-1), 0)
						end
					else
						spawn(function()
							local rf = mrfs[j]
							local sp = rf.Position.Y.Scale
							local ep = (j>i and not justClose) and 0.975-0.175*(5-j) or 0.05+0.175*(j-1)
							Utilities.Tween(.5, 'easeOutCubic', function(a)
								rf.Position = UDim2.new(0.05, 0, sp + (ep-sp)*a, 0)
							end)
						end)
					end
				end
				if move and not justClose and not instant then
					details = roundedFrame:new {
						CornerRadius = moveContainer.AbsoluteSize.Y*.02,
						BackgroundColor3 = rf.BackgroundColor3,
						Size = UDim2.new(0.9, 0, 0.2, 0),
						Position = UDim2.new(-1, 0, 0.2+0.175*(i-1), 0),
						ZIndex = 3, Parent = moveContainer.MainContainer,

						create 'TextLabel' {
							BackgroundTransparency = 1.0,
							Text = move.desc or '',
							TextColor3 = Color3.new(1, 1, 1),
							Font = Enum.Font.SourceSans, FontSize = (Utilities.isPhone() and Enum.FontSize.Size8 or Enum.FontSize.Size14),
							TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
							Size = UDim2.new(0.9, 0, 0.65, 0),
							Position = UDim2.new(0.05, 0, 0.3, 0),
							ZIndex = 4,
						},
						create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://'..({Status=5221910790,Special=5226547108,Physical=5221871913})[move.category],
							Size = UDim2.new(-0.25/16*39, 0, -0.25, 0),--39x16
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Position = UDim2.new(0.95, 0, 0.95, 0),
							ZIndex = 4,
						},
					}
					write('Pwr: '..move.basePower) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.2, 0),
							Position = UDim2.new(0.05, 0, 0.05, 0),
							ZIndex = 4, Parent = details.gui,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
					}
					write('Acc: '..(move.accuracy==true and '--' or move.accuracy)) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.2, 0),
							Position = UDim2.new(0.95, 0, 0.05, 0),
							ZIndex = 4, Parent = details.gui,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
					}
					spawn(function()
						Utilities.Tween(.5, 'easeOutCubic', function(a)
							if not details then return false end
							details.Position = UDim2.new(0.05-(1-a), 0, 0.2+0.175*(i-1), 0)
						end)
					end)
					table.insert(rframes, details)
				else
					currentlyShowing = nil
				end
				if not instant then wait(.5) end
				busy = false
			end
			do
				local isDown = false -- moved out 1 scope; prevent multi-drags
				for i = 1, 4 do
					local m = moves[i]
					local rf = roundedFrame:new {
						Button = true,
						CornerRadius = moveContainer.AbsoluteSize.Y*.02,
						Size = UDim2.new(0.9, 0, 0.15, 0),
						Position = UDim2.new(0.05, 0, 0.05+0.175*(i-1), 0),
						ZIndex = 3, Parent = moveContainer.MainContainer,
					}
					rf.pos = i
					mrfs[i] = rf
					local dragged
					local cs
					local slides = {}
					local function slideTo(rf, n)
						local this = {}
						slides[rf] = this
						local s = rf.Position.Y.Scale
						local e = 0.05+0.175*(n-1)
						spawn(function()
							Utilities.Tween(.2, 'easeOutCubic', function(a)
								if slides[rf] ~= this then return false end
								rf.Position = UDim2.new(0.05, 0, s + (e-s)*a, 0)
							end)
							if slides[rf] == this then
								slides[rf] = nil
							end
						end)
					end
					local function getNearestMove()
						local s, d
						for i = 1, 4 do
							local h = 0.05+0.175*(i-1)
							local p = (rf.AbsolutePosition.Y-moveContainer.AbsolutePosition.Y)/moveContainer.AbsoluteSize.Y
							local dif = math.abs(p-h)
							if not d or dif < d then
								d = dif
								s = i
							end
						end
						return s
					end
					function mouseUp()
						if not isDown then return end
						isDown = false
						if not dragged then
							showDetails(rf)
						else
							local s = math.min(getNearestMove(), #moves)
							if s < cs then
								for i = cs-1, s, -1 do
									local n = i+1
									mrfs[n] = mrfs[i]
									--						mrfs[n].pos = n
									slideTo(mrfs[n], n)
								end
							elseif s > cs then
								for i = cs+1, s do
									local n = i-1
									mrfs[n] = mrfs[i]
									--						mrfs[n].pos = n
									slideTo(mrfs[n], n)
								end
							end
							local p = rf.gui.AbsolutePosition
							rf.Size = UDim2.new(0.9, 0, 0.15, 0)
							local container = moveContainer.MainContainer
							rf.Parent = container
							local pos = UDim2.new(0.05, 0, 0.05+0.175*(s-1), 0)
							local ap = Vector2.new(container.AbsolutePosition.X+container.AbsoluteSize.X*pos.X.Scale, container.AbsolutePosition.Y+container.AbsoluteSize.Y*pos.Y.Scale)
							Utilities.Tween(.2, 'easeOutCubic', function(a)
								local offset = (p-ap)*(1-a)
								rf.Position = pos + UDim2.new(0.0, offset.x, 0.0, offset.y) 
							end)
							rf.Position = pos
							mrfs[s] = rf
							slides = {}
							local ms = {}
							for j, s in pairs(mrfs) do
								local from = s.pos
								ms[j] = pokemon.moves[from]
								s.pos = j
							end
							pokemon.moves = ms
							moves = pokemon:getMoves()
							busy = false
						end
					end
					rf.gui.MouseButton1Up:connect(mouseUp)
					rf.gui.MouseButton1Down:connect(function(x, y)
						if rf.pos > #moves then return end
						if isDown then return end
						dragged = false
						if busy then return end
						do--if self.battleEvent or disableMoveSwitching then
							showDetails(rf) -- Move Switching is completely disabled for the time being, as there are too many bugs
							return
						end
						isDown = true
						local mouse = player:GetMouse()
						local cn = mouse.Button1Up:connect(mouseUp)
						local oPos
						if Utilities.isTouchDevice() then
							local vpo = workspace.CurrentCamera.ViewportSize-Utilities.gui.AbsoluteSize
							oPos = Vector2.new(x, y-vpo.Y)
						else
							oPos = Vector2.new(mouse.X, mouse.Y)
						end
						local offset = oPos-rf.gui.AbsolutePosition
						while isDown do -- initial drag threshold
							if (Vector2.new(mouse.X, mouse.Y)-oPos).magnitude > Utilities.gui.AbsoluteSize.Y*.02 then
								dragged = true
								break
							end
							stepped:wait()
						end
						if isDown then
							busy = true
							if details then
								showDetails(mrfs[currentlyShowing], true)
							end
							cs = rf.pos
							rf.Size = UDim2.new(0.0, rf.gui.AbsoluteSize.X, 0.0, rf.gui.AbsoluteSize.Y)
							rf.Parent = Utilities.frontGui
							while isDown do
								rf.Position = UDim2.new(0.0, mouse.X-offset.x, 0.0, mouse.Y-offset.y)
								local s = getNearestMove()
								if s < cs then
									for i = cs-1, s, -1 do
										local n = i+1
										mrfs[n] = mrfs[i]
										--							mrfs[n].pos = n
										slideTo(mrfs[n], n)
									end
									cs = s
								elseif s > cs then
									for i = cs+1, s do
										local n = i-1
										mrfs[n] = mrfs[i]
										--							mrfs[n].pos = n
										slideTo(mrfs[n], n)
									end
									cs = s
								end
								stepped:wait()
							end
						end
						cn:disconnect()
					end)
					if m then
						local c = _p.BattleGui.typeColors[m.type]
						rf.BackgroundColor3 = Color3.new(c.r*.35, c.g*.35, c.b*.35)
						write(m.name) {
							Frame = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(0.0, 0, 0.4, 0),
								Position = UDim2.new(0.5, 0, 0.05, 0),
								ZIndex = 4, Parent = rf.gui,
							}, Scaled = true,
						}
						write(m.type) {
							Frame = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(0.0, 0, 0.3, 0),
								Position = UDim2.new(0.05, 0, 0.6, 0),
								ZIndex = 4, Parent = rf.gui,
							}, Scaled = true, Color = c, TextXAlignment = Enum.TextXAlignment.Left,
						}
						write(m.pp..'/'..m.maxpp) {
							Frame = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(0.0, 0, 0.3, 0),
								Position = UDim2.new(0.95, 0, 0.6, 0),
								ZIndex = 4, Parent = rf.gui,
							}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
						}
					else
						rf.BackgroundColor3 = Color3.new(.3, .3, .3)
					end
					table.insert(rframes, rf)
				end
			end
		end

		local bgFader
		if ignoreParty then
			bgFader = create 'ImageButton' {
				AutoButtonColor = false,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
				Parent = Utilities.frontGui,
			}
		end
		local cancel; cancel = roundedFrame:new {
			Button = true, Name = 'CancelButton',
			CornerRadius = gui.AbsoluteSize.Y*.01,
			BackgroundColor3 = BrickColor.new('Deep blue').Color,
			Size = UDim2.new(1/5/.9, 0, 1/16/.9, 0),
			Position = UDim2.new(-0.25, 0, 0.45, 0),
			ZIndex = 3, Parent = main,
			MouseButton1Click = function()
				if self.state ~= 'insummary' then return end
				cancel:remove()
				self.state = 'transition'
				local backdrop, xs, xe
				if not ignoreParty then
					backdrop = self.backdrop
					backdrop.Visible = true
					xs = backdrop.AbsolutePosition.X
					xe = gui.AbsoluteSize.X/2-backdrop.AbsoluteSize.X/2
				end
				Utilities.Tween(.8, 'easeOutCubic', function(a)
					main.Position = UDim2.new(1.0, (-gui.AbsoluteSize.X/2-main.AbsoluteSize.X/2)*(1-a), 0.05, 0)
					if ignoreParty then
						bgFader.BackgroundTransparency = 0.2 + a*0.8
					else
						backdrop.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.0, 0)
					end
				end)
				pcall(function() bgFader:remove() end)
				self.state = 'open'
				for _, rf in pairs(rframes) do
					pcall(function() rf:remove() end)
				end
				main:remove()
				clickAbsorber:remove()
			end,
		}
		table.insert(rframes, cancel)
		write '< Back' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.7, 0),
				Position = UDim2.new(0.0, 0, 0.15, 0),
				ZIndex = 4, Parent = cancel.gui,
			}, Scaled = true,
		}

		local backdrop, xs
		if not ignoreParty then
			backdrop = self.backdrop
			xs = backdrop.AbsolutePosition.X
		end
		local xe = -gui.AbsoluteSize.X/2-main.AbsoluteSize.X/2
		delay(.5, function()
			if cry then
				Sprite:playCry(1.0, cry)
			end
		end)
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			main.Position = UDim2.new(1.0, xe*a, 0.05, 0)
			if ignoreParty then
				bgFader.BackgroundTransparency = 1.0 - a*0.8
			else
				backdrop.Position = UDim2.new(0.0, xs - gui.AbsoluteSize.X*a, 0.0, 0)
			end
		end)
		if not ignoreParty then backdrop.Visible = false end
		self.state = 'insummary'
	end

	do
		local function triangle(a, b, c)
			local l = create 'Frame' {
				BorderSizePixel = 0,
				create 'Frame' {
					Name = 'subframe',
					BorderSizePixel = 0,
					Size = UDim2.new(0.0, 6, 0.8, 0),
					Position = UDim2.new(0.0, -2, 0.0, 0),
				}
			}
			local t1 = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5217627247',--5217628075',
			}
			local t2 = t1:Clone()
			local nodes
			local function draw(a, b, c)
				-- some code adapted from stravant's PolyDraw module (see PolyDraw for comments on logic)
				local ab, bc, ca = b-a, c-b, a-c
				local abm, bcm, cam = ab.magnitude, bc.magnitude, ca.magnitude
				local edg1 = math.abs(0.5 + (ca.x*ab.x+ca.y*ab.y)/(abm*abm))
				local edg2 = math.abs(0.5 + (ab.x*bc.x+ab.y*bc.y)/(bcm*bcm))
				local edg3 = math.abs(0.5 + (bc.x*ca.x+bc.y*ca.y)/(cam*cam))
				if edg1 < edg2 then
					if edg1 >= edg3 then
						a, b, c = c, a, b
						ab, bc, ca = ca, ab, bc
						abm = cam
					end
				else
					if edg2 < edg3 then
						a, b, c = b, c, a
						ab, bc, ca = bc, ca, ab
						abm = bcm
					else
						a, b, c = c, a, b
						ab, bc, ca = ca, ab, bc
						abm = cam
					end
				end
				if (ab.x*ca.y-ca.x*ab.y) > 0 then
					a, b = b, a
					ab, bc, ca = -ab, -ca, -bc
					bcm, cam = cam, bcm
				end
				local len1 = -(ca.x*ab.x+ca.y*ab.y)/abm
				local len2 = abm - len1
				local cmidab = ca + ab.unit*len1
				local width = cmidab.magnitude

				local r = -math.deg(math.atan2(cmidab.y, -cmidab.x))
				local c1 = c+ca/2
				t1.Size = UDim2.new(0.0, len1, 0.0, width)
				t1.Position = UDim2.new(0.0, c1.x-len1/2, 0.0, c1.y-width/2)
				t1.Rotation = r+90

				local c2 = b+bc/2
				t2.Size = UDim2.new(0.0, width, 0.0, len2)
				t2.Position = UDim2.new(0.0, c2.x-width/2, 0.0, c2.y-len2/2)
				t2.Rotation = r

				local cl = c+cmidab/2--c+cmidab.unit*(cmidab.magnitude/2+0.5)--c+cmidab/2
				l.Size = UDim2.new(0.0, 2, 0.0, width)-- -1)
				l.Position = UDim2.new(0.0, cl.x-1, 0.0, cl.y-width/2)
				l.Rotation = r-90
			end

			draw(a, b, c)
			return setmetatable({draw=draw}, {
				__index = function(_, k)
					return t1[k]
				end,
				__newindex = function(_, k, v)
					if k == 'Color' then
						t1.ImageColor3 = v
						t2.ImageColor3 = v
						l.BackgroundColor3 = v
						l.subframe.BackgroundColor3 = v
					else
						t1[k] = v
						t2[k] = v
						l[k] = v
						if k ~= 'Parent' then
							l.subframe[k] = v
						end
					end
				end,
			})
		end

		local function drawHex(container, stats, color, zindex, animateFrom)
			local center = container.AbsoluteSize/2
			local dist = center.Y
			local r = math.pi/3
			local s; if animateFrom then
				s = {}
			end
			local v = {}
			for i = 1, 6 do
				local t = r*(i-1)
				local corner = Vector2.new(math.sin(t)*dist, -math.cos(t)*dist)
				v[i] = center+corner*stats[i]
				if s then
					s[i] = center+corner*animateFrom[i]
				end
			end
			local function t(...)
				local tri = triangle(...)
				tri.Color = color
				tri.ZIndex = zindex
				tri.Parent = container
				return tri
			end
			local function l(v1, v2, line)
				local d = v2-v1
				local p = v1+d/2
				local m = d.magnitude
				if not line then
					line = create 'Frame' {
						BorderSizePixel = 0,
						BackgroundColor3 = color,
						ZIndex = zindex, Parent = container,

						create 'Frame' {
							BorderSizePixel = 0,
							BackgroundColor3 = color,
							Size = UDim2.new(0.0, 4, 0.8, 0),
							Position = UDim2.new(0.0, -1, 0.1, 0),
							ZIndex = zindex,
						}
					}
				end
				line.Size = UDim2.new(0.0, 2, 0.0, m-1)
				line.Position = UDim2.new(0.0, p.x-1, 0.0, p.y-m/2+.5)
				line.Rotation = -math.deg(math.atan2(-d.y, d.x))+90
				return line
			end
			if animateFrom then
				local triangles = {
					t(s[1], s[2], center),
					t(s[2], s[3], center),
					t(s[3], s[4], center),
					t(s[4], s[5], center),
					t(s[5], s[6], center),
					t(s[6], s[1], center),
				}
				local lines = {
					l(s[1], s[4]),
					l(s[2], s[5]),
					l(s[3], s[6]),
				}
				Utilities.Tween(1, 'easeOutCubic', function(a)
					local m = {}
					for i = 1, 6 do
						m[i] = s[i] + (v[i]-s[i])*a
					end
					triangles[1].draw(m[1], m[2], center)
					triangles[2].draw(m[2], m[3], center)
					triangles[3].draw(m[3], m[4], center)
					triangles[4].draw(m[4], m[5], center)
					triangles[5].draw(m[5], m[6], center)
					triangles[6].draw(m[6], m[1], center)
					l(m[1], m[4], lines[1])
					l(m[2], m[5], lines[2])
					l(m[3], m[6], lines[3])
				end)
			else
				t(v[1], v[2], center)
				t(v[2], v[3], center)
				t(v[3], v[4], center)
				t(v[4], v[5], center)
				t(v[5], v[6], center)
				t(v[6], v[1], center)
				l(v[1], v[4])
				l(v[2], v[5])
				l(v[3], v[6])
			end
			return v
		end

		function Menu.party:getHexFunction()
			return drawHex
		end

		function Menu.party:showEffort(pokemon)
			local modalGui = Instance.new('ScreenGui', Utilities.gui.Parent)
			modalGui.DisplayOrder = 5--fixes ev/iv checker to be in front of summary window instead of behind it
			local mouseCatcher = create 'ImageButton' {
				AutoButtonColor = false,
				BackgroundTransparency = 1.0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
				Parent = modalGui,
			}
			local effortLabel = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.08, 0),
				ZIndex = 2, Parent = modalGui,
			}
			local baseStats = {}
			local evs = {}
			local order = {1, 2, 3, 6, 5, 4}-- starts at top, rotates clockwise
			local totalEv = 0
			for i = 1, 6 do
				local bs = .1+pokemon.bss[order[i]]/200*.5
				baseStats[i] = bs
				local ev = pokemon.evs[order[i]]
				evs[i] = bs + ev/255*.6
				totalEv = totalEv + ev
			end
			local container = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.0, modalGui.AbsoluteSize.Y*.4),
				Parent = modalGui,
			}
			local tips = drawHex(container, {1, 1, 1, 1, 1, 1}, Color3.new(.5, .7, .8), 2)--.35, .85, .95
			local function l(v1, v2)
				local d = v2-v1
				local p = v1+d/2
				local m = d.magnitude
				create 'Frame' {
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(.5, .75, .9),
					Size = UDim2.new(0.0, 3, 0.0, m-1),
					Position = UDim2.new(0.0, p.x-1, 0.0, p.y-m/2+.5),
					Rotation = -math.deg(math.atan2(-d.y, d.x))+90,
					ZIndex = 3, Parent = container,
				}
			end
			l(tips[1],tips[4])
			l(tips[2],tips[5])
			l(tips[3],tips[6])
			local txtColors = {Color3.new(.4, 1, .8),Color3.new(1, 1, .4),Color3.new(1, .8, .4),
				Color3.new(.8, .4, 1),Color3.new(.4, .8, 1),Color3.new(.4, 1, 1)}
			local ht = modalGui.AbsoluteSize.Y*.035
			for i, txt in pairs({'HP', 'Attack', 'Defense', 'Speed', 'Sp. Def', 'Sp. Atk'}) do
				local p = tips[i]
				write(txt) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.0, ht),
						Position = UDim2.new(0.0, p.x, 0.0, p.y-ht/2),
						ZIndex = 5, Parent = container,
					}, Scaled = true, Color = txtColors[i],
				}
			end
			drawHex(container, baseStats, Color3.new(16/255, 170/255, 136/255), 5)
			local fillbar = roundedFrame:new {
				BackgroundColor3 = Color3.new(.4, .45, .4),
				Style = 'HorizontalBar',
				Size = UDim2.new(0.6, 0, 0.06, 0),
				ZIndex = 2, Parent = modalGui,
			}
			fillbar:setupFillbar(Color3.new(200/255, 250/255, 140/255), Utilities.isPhone() and 2 or 4, 1/510)
			write(pokemon.nickname..'\'s effort') {
				Frame = effortLabel,
				Scaled = true,
			}
			local cancel = roundedFrame:new {
				Button = true,
				BackgroundColor3 = BrickColor.new('Deep blue').Color,
				Name = 'CancelButton',
				Size = UDim2.new(0.15, 0, 0.075, 0),
				ZIndex = 3, Parent = modalGui,
			}
			write 'Close' {
				Frame = create 'Frame' {
					Name = 'ButtonText',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 4, Parent = cancel.gui,
				}, Scaled = true,
			}
			-- EV / IV Game Pass
			local rfs = {}
			local containerPositionX = .5
			if pokemon.ivs then
				containerPositionX = .675
				local stats = create 'Frame' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-2.5, 0, 1.0, 0),
					Parent = container,
				}
				local header = roundedFrame:new {
					CornerRadius = gui.AbsoluteSize.Y*.025,
					BackgroundColor3 = BrickColor.new('Deep blue').Color,
					Size = UDim2.new(0.7, 0, 1.5/7, 0),
					ZIndex = 3, Parent = stats,
				}
				table.insert(rfs, header)
				local body = roundedFrame:new {
					CornerRadius = gui.AbsoluteSize.Y*.025,
					BackgroundColor3 = BrickColor.new('Cyan').Color,
					Size = UDim2.new(0.7, 0, 5.5/7, 0),
					Position = UDim2.new(0.0, 0, 1.5/7, 0),
					ZIndex = 3, Parent = stats,
				}
				table.insert(rfs, body)
				for i = 1, 5, 2 do
					create 'Frame' {
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.new(3/255, 131/255, 177/255),
						Size = UDim2.new(0.7, 0, 1/7, 0),
						Position = UDim2.new(0.0, 0, i/7, 0),
						ZIndex = 4, Parent = stats,
					}
				end
				local ssc = .7
				--			local statnames = {'hp', 'atk','def','spa','spd','spe'}
				for i, txt in pairs({'HP', 'Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed'}) do
					write(txt) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, ssc/7, 0),
							Position = UDim2.new(0.2, 0, (i+(1-ssc)/2)/7, 0),
							ZIndex = 5, Parent = stats,
						}, Scaled = true, Color = txtColors[order[i]], TextXAlignment = Enum.TextXAlignment.Right,
					}
					write(tostring(pokemon.bss[i])) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1,
							Size = UDim2.new(0.0, 0, ssc/7, 0),
							Position = UDim2.new(0.3, 0, (i+(1-ssc)/2)/7, 0),
							ZIndex = 5, Parent = stats,
						}, Scaled = true, Color = Color3.new(16/255, 170/255, 136/255),
					}
					write(tostring(pokemon.ivs[i])) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1,
							Size = UDim2.new(0.0, 0, ssc/7, 0),
							Position = UDim2.new(0.4167, 0, (i+(1-ssc)/2)/7, 0),
							ZIndex = 5, Parent = stats,
						}, Scaled = true,
					}
					write(tostring(pokemon.evs[i])) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1,
							Size = UDim2.new(0.0, 0, ssc/7, 0),
							Position = UDim2.new(0.5333, 0, (i+(1-ssc)/2)/7, 0),
							ZIndex = 5, Parent = stats,
						}, Scaled = true, Color = Color3.new(200/255, 250/255, 140/255),
					}
					write(tostring(i==1 and pokemon.maxhp or pokemon.stats[i-1])) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1,
							Size = UDim2.new(0.0, 0, ssc/7, 0),
							Position = UDim2.new(0.65, 0, (i+(1-ssc)/2)/7, 0),
							ZIndex = 5, Parent = stats,
						}, Scaled = true,
					}
				end
				write 'Base' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1,
						Size = UDim2.new(0.0, 0, ssc/7, 0),
						Position = UDim2.new(0.3, 0, (1-ssc)/14, 0),
						ZIndex = 5, Parent = stats,
					}, Scaled = true,
				}
				write 'IV' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1,
						Size = UDim2.new(0.0, 0, ssc/7, 0),
						Position = UDim2.new(0.4167, 0, (1-ssc)/14, 0),
						ZIndex = 5, Parent = stats,
					}, Scaled = true,
				}
				write 'EV' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1,
						Size = UDim2.new(0.0, 0, ssc/7, 0),
						Position = UDim2.new(0.5333, 0, (1-ssc)/14, 0),
						ZIndex = 5, Parent = stats,
					}, Scaled = true,
				}
			end
			--
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				mouseCatcher.BackgroundTransparency = 1-a*.6
				container.Position = UDim2.new(containerPositionX, 0, 1-0.7*a, 0)
				fillbar.Position = UDim2.new(0.2, 0, 1.45-0.7*a, 0)
				effortLabel.Position = UDim2.new(0.5, 0, -0.3+0.35*a, 0)
				cancel.Position = UDim2.new(0.6, 0, -0.175+0.35*a, 0)
			end)
			spawn(function()
				fillbar:setFillbarRatio(math.max(1, totalEv)/510, true)
			end)
			drawHex(container, evs, Color3.new(200/255, 250/255, 140/255), 4, baseStats)
			cancel.MouseButton1Click:connect(function()
				Utilities.Tween(.5, 'easeOutCubic', function(a)
					a = 1-a
					mouseCatcher.BackgroundTransparency = 1-a*.6
					container.Position = UDim2.new(containerPositionX, 0, 1-0.7*a, 0)
					fillbar.Position = UDim2.new(0.2, 0, 1.45-0.7*a, 0)
					effortLabel.Position = UDim2.new(0.5, 0, -0.3+0.35*a, 0)
					cancel.Position = UDim2.new(0.6, 0, -0.175+0.35*a, 0)
				end)
				for _, rf in pairs(rfs) do rf:remove() end
				rfs = nil
				cancel:remove()
				fillbar:remove()
				modalGui:remove()
			end)
		end
	end

	function Menu.party:remindMove(r, num)
		local sig = Utilities.Signal()
		local bg = create 'ImageButton' {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
		}
		local inDetails = false
		local function showMoveDetails(move, canBeChosen)
			if inDetails then return end
			inDetails = true
			local fade = bg:Clone()
			fade.BackgroundTransparency = .4
			fade.ZIndex = 7
			fade.Parent = Utilities.frontGui
			local color = _p.BattleGui.typeColors[move.type]
			local panel = roundedFrame:new {
				BackgroundColor3 = Color3.new(color.r*.35, color.g*.35, color.b*.35),
				CornerRadius = Utilities.frontGui.AbsoluteSize.Y*.03,
				Size = UDim2.new(0.5, 0, 0.3, 0),
				ZIndex = 8, Parent = gui,

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://'..({Status=5221910790,Special=5226547108,Physical=5221871913})[move.category],
					Size = UDim2.new(0.175/16*39, 0, 0.175, 0),--39x16
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Position = UDim2.new(0.545, 0, 0.07, 0),
					ZIndex = 9,
				}
			}
			--		table.insert(rframes, panel)
			write(move.name) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.2),
					Position = UDim2.new(0.05, 0, 0.05, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write(move.type) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.95, 0, 0.075, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = color,
			}
			write('Power: '..(move.power or 0)) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.1, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = Color3.new(.9, .9, .9),
			}
			write('Acc: '..(move.accuracy == true and '--' or move.accuracy)) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.6, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Center, Color = Color3.new(.9, .9, .9),
			}
			write('PP: '..(move.maxpp or move.pp)) {
				Frame = create 'Frame' {
					Size = UDim2.new(0.0, 0, 0.15),
					Position = UDim2.new(0.95, 0, 0.3, 0),
					BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right, Color = Color3.new(.9, .9, .9),
			}
			local descFrame = create 'Frame' {
				Size = UDim2.new(0.9, 0, 0.45),
				Position = UDim2.new(0.05, 0, 0.5, 0),
				BackgroundTransparency = 1.0, ZIndex = 9, Parent = panel.gui,
			}
			if move.desc and move.desc ~= '' then
				local ht = descFrame.AbsoluteSize.Y/4.5
				local obj = write(move.desc) {
					Frame = descFrame,
					Size = ht,
					Wraps = true,
				}
				if obj and obj.MaxBounds then
					local r = obj.MaxBounds.y/ht
					if r < 2 then
						descFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
					elseif r < 3 then
						descFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
					end
				end
			end
			panel.Position = UDim2.new(0.25, 0, 0.3, 0)
			panel.Parent = Utilities.frontGui
			local choose
			local cancel; cancel = _p.RoundedFrame:new {
				Button = true,
				CornerRadius = Utilities.frontGui.AbsoluteSize.Y*.02,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(.3, 0, .25, 0),
				Position = UDim2.new(.15, 0, 1.075, 0),
				ZIndex = 8, Parent = panel.gui,
				MouseButton1Click = function()
					if choose then choose:remove() end
					cancel:remove()
					panel:remove()
					fade:remove()
					inDetails = false
				end,
			}
			write 'Cancel' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.7, 0),
					Position = UDim2.new(0.5, 0, 0.15, 0),
					ZIndex = 9, Parent = cancel.gui,
				}, Scaled = true, Color = Color3.new(.9, .9, .9),
			}
			if canBeChosen then
				choose = _p.RoundedFrame:new {
					Button = true,
					CornerRadius = Utilities.frontGui.AbsoluteSize.Y*.02,
					BackgroundColor3 = BrickColor.new('Cyan').Color,
					Size = UDim2.new(.3, 0, .25, 0),
					Position = UDim2.new(.55, 0, 1.075, 0),
					ZIndex = 8, Parent = panel.gui,
					MouseButton1Click = function()
						choose:remove()
						cancel:remove()
						panel:remove()
						fade:remove()
						sig:fire(move)
					end,
				}
				write 'Choose' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.7, 0),
						Position = UDim2.new(0.5, 0, 0.15, 0),
						ZIndex = 9, Parent = choose.gui,
					}, Scaled = true,
				}
			end
		end
		local cradii = {}
		local rframes = {}
		local knownMoves = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Size = UDim2.new(0.25, 0, 0.3, 0),
		}
		-- Known Moves
		for i, m in pairs(r.known) do
			local color = _p.BattleGui.typeColors[m.type]
			color = Color3.new(1-(1-color.r)*.35, 1-(1-color.g)*.35, 1-(1-color.b)*.35)
			local rf = roundedFrame:new {
				Button = true,
				BackgroundColor3 = color,
				Size = UDim2.new(1.0, 0, 0.225, 0),
				Position = UDim2.new(0.0, 0, (i-1)/4+.0125, 0),
				ZIndex = 3, Parent = knownMoves,
				MouseButton1Click = function() showMoveDetails(m) end,

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://'..({Status=5221910790,Special=5226547108,Physical=5221871913})[m.category],
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-0.3/16*39, 0, 0.3, 0),--39x16
					Position = UDim2.new(0.975, 0, 0.075, 0),
					ZIndex = 4,
				}
			}
			write(m.name) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.3, 0),
					Position = UDim2.new(0.075, 0, 0.125, 0),
					ZIndex = 5, Parent = rf.gui,
				}, Scaled = true, Color = Color3.new(.5, .5, .5), TextXAlignment = Enum.TextXAlignment.Left,
			}
			write((m.power or 0)..' Pwr') {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.2, 0),
					Position = UDim2.new(0.635, 0, 0.7, 0),
					ZIndex = 4, Parent = rf.gui,
				}, Scaled = true, Color = Color3.new(.5, .5, .5), TextXAlignment = Enum.TextXAlignment.Right,
			}
			write(m.accuracy == true and '-- Acc' or (m.accuracy..' Acc')) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.2, 0),
					Position = UDim2.new(0.95, 0, 0.7, 0),
					ZIndex = 4, Parent = rf.gui,
				}, Scaled = true, Color = Color3.new(.5, .5, .5), TextXAlignment = Enum.TextXAlignment.Right,
			}
			local trf = roundedFrame:new {
				BackgroundColor3 = _p.BattleGui.typeColors[m.type],
				Size = UDim2.new(0.325, 0, 0.4, 0),
				Position = UDim2.new(0.025, 0, 0.55, 0),
				ZIndex = 4, Style = 'HorizontalBar', Parent = rf.gui,
			}
			write(m.type) {
				Frame = create 'Frame' {
					Parent = rf.gui, ZIndex = 4, BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.5, 0),
					Position = UDim2.new(0.5, 0, 0.25, 0),
					ZIndex = 5, Parent = trf.gui,
				}, Scaled = true,
			}
			table.insert(rframes, trf)
			cradii[rf] = .015
			table.insert(rframes, rf)
		end
		--
		local scrollFrame = create 'ScrollingFrame' {
			BorderSizePixel = 0,
			BackgroundTransparency = 1.0,
			ClipsDescendants = true,
			Size = UDim2.new(0.65, 0, 0.8, 0),
			ZIndex = 2, Parent = Utilities.frontGui,
		}
		local listContainer = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Parent = scrollFrame,
		}
		local function update()
			local sbw = Utilities.frontGui.AbsoluteSize.Y*.05
			scrollFrame.ScrollBarThickness = sbw
			listContainer.Size = UDim2.new(1.0, -sbw, 1.0, -sbw)
			for rf, cr in pairs(cradii) do
				rf.CornerRadius = Utilities.frontGui.AbsoluteSize.X*cr
			end
			knownMoves.Position = UDim2.new(knownMoves.Position.X.Scale, 0, 0.5, -knownMoves.AbsoluteSize.Y/2)
		end
		local screenChanged = Utilities.frontGui.Changed:connect(update)
		update()
		local h = 0.08
		local gap = 0.005
		local contentRelativeSize = #r.moves * h * listContainer.AbsoluteSize.X / scrollFrame.AbsoluteSize.Y
		scrollFrame.CanvasSize = UDim2.new(scrollFrame.Size.X.Scale, -1, contentRelativeSize * scrollFrame.Size.Y.Scale, 0)
		scrollFrame.Parent = nil
		-- Remindable Moves
		for i, m in pairs(r.moves) do
			local color = _p.BattleGui.typeColors[m.type]
			color = Color3.new(1-(1-color.r)*.35, 1-(1-color.g)*.35, 1-(1-color.b)*.35)
			local rf = roundedFrame:new {
				Button = true,
				BackgroundColor3 = color,
				Size = UDim2.new(1.0, 0, h-gap, 0),
				Position = UDim2.new(0.0, 0, (i-1)*h+gap/2, 0),
				ZIndex = 3, Style = 'HorizontalBar', Parent = listContainer,
				MouseButton1Click = function() showMoveDetails(m, true) end,

				create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://'..({Status=5221910790,Special=5226547108,Physical=5221871913})[m.category],
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(-0.6/16*39, 0, 0.6, 0),--39x16
					Position = UDim2.new(0.975, 0, 0.2, 0),
					ZIndex = 4,
				}
			}
			write(m.name) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.6, 0),
					Position = UDim2.new(0.2, 0, 0.2, 0),
					ZIndex = 4, Parent = rf.gui,
				}, Scaled = true, Color = Color3.new(.5, .5, .5), TextXAlignment = Enum.TextXAlignment.Left,
			}
			write((m.power or 0)..' Power') {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.3, 0),
					Position = UDim2.new(0.815, 0, 0.1, 0),
					ZIndex = 4, Parent = rf.gui,
				}, Scaled = true, Color = Color3.new(.5, .5, .5), TextXAlignment = Enum.TextXAlignment.Right,
			}
			write(m.accuracy == true and '-- Accuracy' or (m.accuracy..'% Accuracy')) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.3, 0),
					Position = UDim2.new(0.85, 0, 0.6, 0),
					ZIndex = 4, Parent = rf.gui,
				}, Scaled = true, Color = Color3.new(.5, .5, .5), TextXAlignment = Enum.TextXAlignment.Right,
			}
			local trf = roundedFrame:new {
				BackgroundColor3 = _p.BattleGui.typeColors[m.type],
				Size = UDim2.new(0.175, 0, 0.8, 0),
				Position = UDim2.new(0.0125, 0, 0.1, 0),
				ZIndex = 4, Style = 'HorizontalBar', Parent = rf.gui,
			}
			write(m.type) {
				Frame = create 'Frame' {
					Parent = rf.gui, ZIndex = 4, BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.5, 0),
					Position = UDim2.new(0.5, 0, 0.25, 0),
					ZIndex = 5, Parent = trf.gui,
				}, Scaled = true,
			}
			table.insert(rframes, trf)
			table.insert(rframes, rf)
		end
		--
		local cancel = _p.RoundedFrame:new {
			Button = true,
			CornerRadius = Utilities.frontGui.AbsoluteSize.Y*.02,
			BackgroundColor3 = Color3.new(.4, .4, .4),
			Size = UDim2.new(.15, 0, .08, 0),
			ZIndex = 5, Parent = Utilities.frontGui,
			MouseButton1Click = function() sig:fire() end,
		}
		write 'Cancel' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.7, 0),
				Position = UDim2.new(0.5, 0, 0.15, 0),
				ZIndex = 6, Parent = cancel.gui,
			}, Scaled = true, Color = Color3.new(.9, .9, .9),
		}
		table.insert(rframes, cancel)
		--
		bg.Parent = Utilities.frontGui
		knownMoves.Parent = Utilities.frontGui
		scrollFrame.Parent = Utilities.frontGui
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			bg.BackgroundTransparency = 1-0.7*a
			knownMoves.Position = UDim2.new(-.3+.325*a, 0, 0.5, -knownMoves.AbsoluteSize.Y/2)
			scrollFrame.Position = UDim2.new(1.0-0.675*a, 0, 0.1, 0)
			cancel.Position = UDim2.new(1.05-.5*a, 0, .01, 0)
		end)
		local chosenId = sig:wait()
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			local o = 1-a
			bg.BackgroundTransparency = 1-0.7*o
			knownMoves.Position = UDim2.new(-.3+.325*o, 0, 0.5, -knownMoves.AbsoluteSize.Y/2)
			scrollFrame.Position = UDim2.new(1.0-0.675*o, 0, 0.1, 0)
			cancel.Position = UDim2.new(1.05-.5*o, 0, .01, 0)
		end)
		screenChanged:disconnect()
		for _, rf in pairs(rframes) do
			pcall(function() rf:remove() end)
		end
		knownMoves:remove()
		scrollFrame:remove()
		bg:remove()
		return chosenId
	end


	Menu.bag = require(script.Bag)(_p)
	Menu.card = require(script.TrainerCard)(_p)
	Menu.pc = require(script.PC)(_p)
	Menu.shop = require(script.Shop)(_p)
	Menu.rtd = require(script.RTD)(_p)
	Menu.battleShop = require(script.BPShop)(_p)
	Menu.dex = require(script.Pokedex)(_p)
	Menu.options = require(script.Options)(_p)
	Menu.ropowers = require(script.RoPowers)(_p)
	Menu.map = require(script.Map)(_p)
	Menu.pannel = require(script.Pannel)(_p)
	--Menu.stamps = require(script.PBStamps)(_p)


	return Menu end