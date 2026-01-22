return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local MasterControl = _p.MasterControl	

	local wbag = require(script.WearableBag)(_p)

	local options = {
		isOpen = false,
		lastUnstuckTick = 0,
		reduceGraphics = false,
	}
	local gui, bg, close, unstuckButton, unstuckTimerContainer

	local unstuckCooldown = 5 * 3

	local function color(r, g, b)
		return Color3.new(r/255, g/255, b/255)
	end

	local function unstuckTimer()
		Utilities.fastSpawn(function()
			unstuckTimerContainer:ClearAllChildren()
			local et = tick()-options.lastUnstuckTick
			if et >= unstuckCooldown then
				write 'Ready' {
					Frame = unstuckTimerContainer,
					Scaled = true,
					Color = color(124, 200, 99),
				}
				return
			end
			et = math.floor(et+.5)
			while gui.Parent do
				local t = options.lastUnstuckTick + et + 1
				wait(t-tick())
				unstuckTimerContainer:ClearAllChildren()
				et = math.floor(tick()-options.lastUnstuckTick+.5)
				if et >= unstuckCooldown then
					write 'Ready' {
						Frame = unstuckTimerContainer,
						Scaled = true,
						Color = color(124, 200, 99),
					}
					return
				end
				local rt = unstuckCooldown-et
				local rm = math.floor(rt/60)
				local rs = rt%60
				write(rm..':'..(rs<10 and ('0'..rs) or rs)) {
					Frame = unstuckTimerContainer,
					Scaled = true,
					--				Color = color(238, 88, 73),
				}
			end
		end)
	end

	function options:setLightingForReducedGraphics(isReduced)
		local lighting = game:GetService('Lighting')
		lighting.GlobalShadows = not isReduced
		lighting.Ambient = isReduced and Color3.new(.6, .6, .6) or Color3.new(.3, .3, .3)
		lighting.OutdoorAmbient = isReduced and Color3.new(.75, .75, .75) or Color3.new(.5, .5, .5)
		pcall(function() _p.DataManager.currentChunk:setDay(_p.DataManager.isDay) end)
	end

	function options:getUnstuck(manually)
		if not manually and tick()-self.lastUnstuckTick < unstuckCooldown then return end
		_p.Hoverboard:unequip(true)
		_p.Surf:forceUnsurf()
		local cf
		if _p.context == 'battle' then
			local t = math.random()*math.pi*2
			local r = math.random()*40
			cf = CFrame.new(-24.4, 3.5, -206.5) + Vector3.new(math.cos(t)*r, 0, math.sin(t)*r)
		elseif _p.context == 'trade' then
			cf = CFrame.new(10.8, 3.5, 10.1) + Vector3.new(math.random()*40-20, 0, math.random()*40-20)
		else
			local chunk = _p.DataManager.currentChunk
			if chunk.id == 'mining' then
				cf = CFrame.new(350, 93, -883)
				if manually then
					Utilities.TeleportToSpawnBox()
					chunk:remove()
					wait(.5)
					_p.DataManager:loadMap('chunk9')
					wait(.5)
					Utilities.Teleport(cf)
				else
					Utilities.FadeOut(.5, Color3.new(0, 0, 0))
					Utilities.TeleportToSpawnBox()
					chunk:remove()
					wait(.5)
					_p.DataManager:loadMap('chunk9')
					wait(.5)
					Utilities.Teleport(cf)
					self.lastUnstuckTick = tick()
					self:fastClose(false)
					wait(.5)
					Utilities.FadeIn(.5)
					_p.MasterControl.WalkEnabled = true
					--_p.MasterControl:Start()

				end
				return
			end
			if chunk.indoors then
				-- inside
				local room = chunk:topRoom()
				local entrance = room.Entrance
				if entrance then
					cf = entrance.CFrame * CFrame.new(0, 3, 3.5) * CFrame.Angles(0, math.pi, 0)
				else
					entrance = room.model:FindFirstChild('ToChunk:'..chunk.id)
					if entrance then
						cf = entrance.CFrame * CFrame.new(0, 0, -5.5)
					end
				end
			else
				-- outside
				local door
				if chunk.id == 'chunk1' then
					door = chunk:getDoor('yourhomef1')
				elseif chunk.id == 'chunk7' then
					cf = CFrame.new(Vector3.new(-761, 45.2, -705), Vector3.new(-760, 45.2, -705))
				elseif chunk.id == 'chunk16' then
					cf = CFrame.new(Vector3.new(662.3, 10.4, 640.6), Vector3.new(662.3, 10.4, 630))
				elseif chunk.id == 'gym6' then
					cf = CFrame.new(989, 52, 503)
				elseif chunk.id == 'chunk45' then --route 15
					cf = CFrame.new(-2367, 3302.995, 1851)
				elseif chunk.id == 'gym7' then --gym 7
					cf = CFrame.new(-133, 83.7, 340)
				elseif chunk.id == 'chunk49' then -- Cosmeos Observatory
					door = chunk:getDoor('C_chunk51')
				elseif chunk.id == 'gym8' then --gym 8
					cf = CFrame.new(-47.581, 26.86, -7.486)
				elseif chunk.id == 'chunk56' then --aborille
					cf = CFrame.new(-792.207, 799.915, 1449.922)
				elseif chunk.id == 'chunk65' then --halloween place
					cf = CFrame.new(-3998.33, 1594.305, -3261)
				elseif chunk.id == 'chunk66' then --keldeo
					cf = CFrame.new(-174, 960.5, 40)
				elseif chunk.id == 'chunk70' then --lost island
					cf = CFrame.new(739.025, 7.589, 117.782)
				elseif chunk.id == 'chunk71' then --route 17
					cf = CFrame.new(455.27, 397.532, -3487.29)	
				elseif chunk.id == 'chunk72' then --silvent cove
					cf = CFrame.new(200.629, 1069.975, -230.719)
				elseif chunk.id == 'gym72' then --silvent cove
					cf = CFrame.new(1291.065, 284.955, 4298.653)

				elseif chunk.id == 'chunk57' then -- eclipse base entrance hall
					cf = CFrame.new(-1992.144, 939.572, -437.878)
				elseif chunk.id == 'chunk81' then -- eclipse base cafeteria
					door = chunk:getDoor('C_chunk57|a')
				elseif chunk.id == 'chunk82' then -- eclipse base power station
					door = chunk:getDoor('C_chunk57|a')
				elseif chunk.id == 'chunk83' then -- eclipse base living quarters
					door = chunk:getDoor('C_chunk57')
				elseif chunk.id == 'chunk84' then
					door = chunk:getDoor('C_chunk57')
				elseif chunk.id == 'chunk85' then
					door = chunk:getDoor('C_chunk57')
				elseif chunk.id == 'chunk86' then
					door = chunk:getDoor('C_chunk57')
				elseif chunk.id == 'chunk60' then
					door = chunk:getDoor('C_chunk86')
				elseif chunk.id == 'chunk88' then
					door = chunk:getDoor('C_chunk82')

				else
					door = chunk:getDoor('PokeCenter')
					if chunk.id == 'chunk23' then
						door = chunk:getDoor('C_chunk20')
					end
					if not door then
						local gateNum = 999
						for _, d in pairs(chunk.doors) do
							if d.id:sub(1, 4) == 'Gate' then
								local n = tonumber(d.id:sub(5))
								if n and n < gateNum then
									door = d
									gateNum = n
								end
							end
						end
					end
					if not door then
						print('trying cave doors')
						-- try cave doors
						local caveDoor
						local cdn
						for _, p in pairs(chunk.map:GetChildren()) do
							if p:IsA('BasePart') then
								local id = p.Name:match('^CaveDoor:([^:]+)')
								if id then
									local n
									if id:sub(1, 5) == 'chunk' then
										n = tonumber(id:sub(6))
									end
									print('found cave door:', n or '?')
									if not caveDoor or (not cdn and n) or (cdn and n and n < cdn) then
										print('setting')
										caveDoor = p
										cdn = n
									end
								end
							end
						end
						if caveDoor then
							cf = caveDoor.CFrame * CFrame.new(0, -caveDoor.Size.Y/2+3, -caveDoor.Size.Z-4)
						end
					end
				end
				if door then
					cf = door.CFrame * CFrame.new(0, 0, -5)
				end
			end
		end
		if cf then
			if manually then
				Utilities.Teleport(cf)
			else
				Utilities.FadeOut(.5, Color3.new(0, 0, 0))
				Utilities.Teleport(cf)
				self.lastUnstuckTick = tick()
				self:fastClose(false)
				wait(.5)
				Utilities.FadeIn(.5)
				_p.MasterControl.WalkEnabled = true
				--_p.MasterControl:Start()

				--			unstuckTimer()
			end
		end
	end

	function options:open()
		if self.isOpen or not _p.MasterControl.WalkEnabled then return end
		self.isOpen = true
		spawn(function() _p.Menu:disable() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()


		if not gui then
			bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
			}
			gui = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5217661132', -- 5217662406  340903755
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.9, 0, 0.9, 0),
				ZIndex = 2,
			}
			close = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = color(152, 44, 121),--77, 42, 116),
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

			-- Autosave
			--[UPDATE: Autosave doesn't work with my cloud saving... So I disabled it]
			-- [[
			local autosaveToggle = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.1, 0),
				Position = UDim2.new(0.8, 0, 0.075, 0),
				Value = _p.Autosave.enabled,
				ZIndex = 3, Parent = gui,
			}
			autosaveToggle.ValueChanged:connect(function()
				if autosaveToggle.Value then
					autosaveToggle.Enabled = false
					wait(.2)
					if _p.NPCChat:say('Autosave will save every two minutes, and after completing battles.',
						'It is recommended that you still manually save before leaving the game.',
						'[y/n]Would you like to enable Autosave?') then
						if _p.Menu.willOverwriteIfSaveFlag then
							if _p.NPCChat:say('There is another save file that may be overwritten by Autosave.',
								'[y/n]Would you still like to enable Autosave?') then
								_p.Autosave:enable()
							else
								autosaveToggle:animateToValue(false)
							end
						else
							_p.Autosave:enable()
						end
					else
						autosaveToggle:animateToValue(false)
					end
					autosaveToggle.Enabled = true
				else
					_p.Autosave:disable()
				end
			end)
			write 'Autosave' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.1, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			--]]

			-- Reduced Graphics
			local reducedGraphicsToggle = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.1, 0),
				Position = UDim2.new(0.8, 0, 0.225, 0),
				Value = self.reduceGraphics,--_p.DataManager.useMobileGrass and true or false,
				ZIndex = 3, Parent = gui,
			}
			reducedGraphicsToggle.ValueChanged:connect(function()
				reducedGraphicsToggle.Enabled = false
				local chunk = _p.DataManager.currentChunk
				local v = reducedGraphicsToggle.Value
				self.reduceGraphics = v--_p.DataManager.useMobileGrass = v
				self:setLightingForReducedGraphics(v)
				if not _p.Utilities.isTouchDevice() then
					local grass = _p.DataManager:request({'Grass', chunk.id, v})
					if grass then
						pcall(function() chunk.map[v and 'Grass' or 'MGrass']:remove() end)
						grass.Parent = chunk.map
					end
				end
				reducedGraphicsToggle.Enabled = true
			end)
			write 'Reduced Graphics' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.25, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			-- Unstuck
			write 'Stuck?' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.4, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			unstuckButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.3, 0, 0.375, 0),
				ZIndex = 3, Parent = gui,
				MouseButton1Click = function()
					self:getUnstuck()
				end,
			}
			write 'Get Unstuck' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.3, 0, 0.4, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(.8, .8, .8),
			}
			unstuckTimerContainer = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.05, 0),
				Position = UDim2.new(0.825, 0, 0.4, 0),
				ZIndex = 3, Parent = gui,
			}

			-- Bag
			-- [[
			local wearBagToggle = _p.ToggleButton:new {
				Size = UDim2.new(0.0, 0, 0.1, 0),
				Position = UDim2.new(0.7, 0, 0.525, 0),
				Value = self.bagEnabled,
				ZIndex = 3, Parent = gui,
			}
			wearBagToggle.ValueChanged:connect(function()
				wearBagToggle.Enabled = false
				if wearBagToggle.Value then
					wbag:wear()
				else
					wbag:remove()
				end
				wearBagToggle.Enabled = true
			end)
			--[[
		local gear = create 'ImageButton' {
			AutoButtonColor = false,
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://55092053',
			ImageColor3 = Color3.new(.7, .7, .7),
			Size = UDim2.new(.08, 0, .08, 0),
			Position = UDim2.new(.87, 0, .535, 0),
			ZIndex = 3, Parent = gui,
			MouseButton1Click = function()
--				WBagClose.Visible = true	
				wbag:configure()
			end,
		}
		--]]
			write 'Wearable Bag' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.55, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			--[[
		if not self.hasWBag then
			wearBagToggle.Visible = false
			gear.Visible = false
			local purchaseBagButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.3, 0, 0.375, 0),
				ZIndex = 3, Parent = gui,
				MouseButton1Click = function()
					-- todo // dont do because we made bags free (but maybe exclusives?)
				end,
			}
			
		end
		--]]
			close.gui.MouseButton1Click:connect(function()
				--uncomment if i find a way to fix autosave
				--if not autosaveToggle.Enabled or 
				if not wearBagToggle.Enabled or not reducedGraphicsToggle.Enabled then return end
				self:close()
			end)

			-- Promo Code Redemption
			write 'Redeem Code' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.7, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local redeemCodeButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.4, 0, 0.1, 0),
				Position = UDim2.new(0.5, 0, 0.675, 0),
				ZIndex = 3, Parent = gui,
				MouseButton1Click = function()
					self:fastClose(true)
					_p.PromoCodeManager:openPromptGui()
				end,
			}

			write 'Enter Code' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.4, 0, 0.05, 0),
					Position = UDim2.new(0.5, 0, 0.7, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true, Color = Color3.new(.8, .8, .8),
			}

			-- Add Roulette button to options menu
			write 'Pokemon Roulette' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.05, 0),
					Position = UDim2.new(0.05, 0, 0.85, 0),
					ZIndex = 3, Parent = gui,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			local rouletteButton = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.3, 0, 0.1, 0),
				Position = UDim2.new(0.6, 0, 0.825, 0),
				ZIndex = 3, Parent = gui,
				MouseButton1Click = function()
					self:close()
					pcall(function()
						if _p.Menu and _p.Menu.roulette and _p.Menu.roulette.open then
							_p.Menu.roulette:open()
						else
							_p.NPCChat:say("The Roulette feature is coming soon!", "Join the Thiscored for more information!")
						end
					end)
				end,
			}

			write 'Spin!' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.3, 0, 0.05, 0),
					Position = UDim2.new(0.6, 0, 0.85, 0),
					ZIndex = 4, Parent = gui,
				}, Scaled = true,
			}
		end

		bg.Parent = Utilities.gui
		gui.Parent = Utilities.gui
		close.CornerRadius = Utilities.gui.AbsoluteSize.Y*.015
		unstuckButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.02

		unstuckTimer()

		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpen then return false end
			bg.BackgroundTransparency = 1-.3*a
			gui.Position = UDim2.new(1-.5*a, -gui.AbsoluteSize.X/2*a, 0.05, 0)
		end)
	end

	function options:close()
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
		--_p.MasterControl:Start()

		_p.MasterControl.WalkEnabled = true
	end

	function options:fastClose(enableWalk)
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


	return options end