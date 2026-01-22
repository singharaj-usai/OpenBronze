return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write

	local players = game:GetService('Players')
	local teleportService = game:GetService('TeleportService')
	local stepped = game:GetService('RunService').RenderStepped
	teleportService.CustomizedTeleportUI = true

	local rtd = {
		isOpen = false,
	}

	local locations = {
		[_p.placeId.Main] = 'Adventure',
		[_p.placeId.Battle] = 'Colosseum',
		[_p.placeId.Trade] = 'Resort',
	}


	local GET = game.ReplicatedStorage:WaitForChild("GET")
	do
		local function getPlayerPlaceInstanceAsync(userId)
			return _p.Network:get('GetPlayerPlaceInstanceAsync', userId)
			--return GET:InvokeServer('GetPlayerPlaceInstanceAsync', userId)
		end

		local function searchForPlayer(username)
			local userId
			--	if tonumber(username) then
			--		userId = tonumber(username)
			--	else
			local s, r = pcall(function() return players:GetUserIdFromNameAsync(username) end)
			userId = r
			if not s or not userId then
				return 'Unable to find a Roblox user named "'..username..'"'
			end
			--	end
			local success, errorMsg, placeId, jobId
			local s, r = pcall(function()
				success, errorMsg, placeId, jobId = getPlayerPlaceInstanceAsync(userId)
			end)
			if not s then
				warn('Player search failed because', r)
			else
				print("Search results: ", success, errorMsg, placeId, jobId)
			end
			local location
			if success then
				location = locations[placeId]
				print("Found location:", location)
			end
			if not location and placeId and locations[placeId] then
				location = locations[placeId]
				print("Player found in different server of:", location)
			end
			return '', location, placeId, jobId
		end

		local function tableCell()
			return create 'Frame' {
				BorderSizePixel = 0,
				ZIndex = 2,

				create 'Frame' {
					Name = 'PlayerName',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.3, 0, 0.6, 0),
					Position = UDim2.new(0.02, 0, 0.2, 0),
					ZIndex = 3,
				},
				create 'Frame' {
					Name = 'Location',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.3, 0, 0.6, 0),
					Position = UDim2.new(0.35, 0, 0.2, 0),
					ZIndex = 3,
				},
			}
		end

		local ht = 0.05
		local gui, thread
		local open = false
		function rtd:playerSearch(intro, UI)
			if open then
				self:closePlayerSearch()
				return
			end
			if not intro then
				if not _p.Menu.enabled then return end
			else
				for _, ui in ipairs(UI) do
					ui.Visible = false
				end
			end
			if not gui then
				gui = _p.RoundedFrame:new {
					BackgroundColor3 = Color3.new(.9, .9, .9),
					Size = UDim2.new(.6, 0, .7, 0),
					Position = UDim2.new(.2, 0, .15-1, 0),
					Parent = Utilities.backGui,

					create 'ScrollingFrame' {
						Name = 'List',
						BackgroundColor3 = Color3.new(.7, .7, .7),
						BorderSizePixel = 0,
						Size = UDim2.new(0.9, 0, 0.55, 0),
						Position = UDim2.new(0.05, 0, 0.2, 0),
						ZIndex = 2,

						create 'Frame' {
							Name = 'Container',
							BackgroundTransparency = 1.0,
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
						}
					},
					create 'Frame' {
						Name = 'SearchDiv',
						BackgroundColor3 = Color3.new(.7, .7, .7),
						BorderSizePixel = 0,
						Size = UDim2.new(0.9, 0, 0.1, 0),
						Position = UDim2.new(0.05, 0, 0.825, 0),
						ZIndex = 2,
					},
					create 'Frame' {
						Name = 'ErrorText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.9325, 0),
						ZIndex = 2,
					}
				}
				if intro then
					local trd = _p.RoundedFrame:new {
						Button = true,
						BackgroundColor3 = Color3.new(0, 0.501961, 1),
						Size = UDim2.new(.2, 0, .08, 0),
						Position = UDim2.new(.05, 0, .02, 0),--isPhone and UDim2.new(33/32, 0, 7/16, 0) or UDim2.new(3/4, 0, 1/16, 0),
						ZIndex = 3,
						Parent = gui.gui,
						MouseButton1Click = function()
							self:teleport(_p.placeId.Trade, nil, intro)
						end,
					}
					write 'Trade' {
						Frame = create 'Frame' {
							Name = 'ButtonText',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(1.0, 0, 0.7, 0),
							Position = UDim2.new(0.0, 0, 0.15, 0),
							Parent = trd.gui,
							ZIndex = 4,
						},
						Scaled = true,
					}
					local btl = _p.RoundedFrame:new {
						Button = true,
						BackgroundColor3 = Color3.new(1, 0.501961, 0),
						Size = UDim2.new(.2, 0, .08, 0),
						Position = UDim2.new(.27, 0, .02, 0),--isPhone and UDim2.new(33/32, 0, 7/16, 0) or UDim2.new(3/4, 0, 1/16, 0),
						ZIndex = 3,
						Parent = gui.gui,
						MouseButton1Click = function()
							self:teleport(_p.placeId.Battle, nil, intro)
						end,
					}
					write 'Battle' {
						Frame = create 'Frame' {
							Name = 'ButtonText',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(1.0, 0, 0.7, 0),
							Position = UDim2.new(0.0, 0, 0.15, 0),
							Parent = btl.gui,
							ZIndex = 4,
						},
						Scaled = true,
					}
				end
				local cancel = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.6, .6, .6),
					Size = UDim2.new(.2, 0, .08, 0),
					Position = UDim2.new(.775, 0, .02, 0),--isPhone and UDim2.new(33/32, 0, 7/16, 0) or UDim2.new(3/4, 0, 1/16, 0),
					ZIndex = 3,
					Parent = gui.gui,
					MouseButton1Click = function()
						self:closePlayerSearch()
						if UI then
							for _, ui in ipairs(UI) do
								ui.Visible = true
							end
						end
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
				if not intro then
					write 'Player Search' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.08, 0),
							Position = UDim2.new(0.5, 0, 0.02, 0),
							ZIndex = 2, Parent = gui.gui,
						}, Scaled = true, Color = Color3.new(.5, .5, .5),
					}
				end
				write 'Search by Username' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.775, 0),
						ZIndex = 2, Parent = gui.gui,
					}, Scaled = true, Color = Color3.new(.5, .5, .5),
				}
				local header = tableCell()
				--			header.BackgroundTransparency = 1.0
				header.BackgroundColor3 = Color3.new(.5, .5, .5)
				header.Position = UDim2.new(0.05, 0, 0.12, 0)
				local function cr()
					gui.CornerRadius = Utilities.gui.AbsoluteSize.Y*.04
					local sbw = Utilities.gui.AbsoluteSize.Y*.035
					gui.gui.List.ScrollBarThickness = sbw
					gui.gui.List.Container.Size = UDim2.new(1.0, -sbw, 1.0, -sbw)
					header.Size = UDim2.new(0.9, 0--[[-sbw]], 0.08, 0)
				end
				Utilities.gui.Changed:connect(cr)
				cr()
				header.Parent = gui.gui
				write 'Friend' {
					Frame = header.PlayerName,
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}
				write 'Location' {
					Frame = header.Location,
					Scaled = true,
				}
				local searchCell = tableCell()
				searchCell.Size = UDim2.new(1.0, -4, 1.0, -4)
				searchCell.Position = UDim2.new(0.0, 2, 0.0, 2)
				searchCell.Parent = gui.gui.SearchDiv
				local searchPlaceId, searchJobId
				local joinButton = create 'TextButton' {
					Text = '',
					BackgroundColor3 = Color3.new(0, .24, .5),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Size = UDim2.new(.175, 0, 0.8, 0),
					Position = UDim2.new(0.8, 0, 0.1, 0),
					Visible = false,
					ZIndex = 3, Parent = searchCell,
					MouseButton1Click = function()
						if not intro then
							if not _p.Menu.enabled then return end
						end
						if not searchPlaceId or not searchJobId then return end
						self:teleport(searchPlaceId, searchJobId, intro)
					end,
				}
				write 'Join' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.8, 0),
						Position = UDim2.new(0.5, 0, 0.1, 0),
						ZIndex = 4, Parent = joinButton,
					}, Scaled = true,
				}
				local search; search = create 'TextBox' {
					Text = 'Username',
					ClearTextOnFocus = false,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					TextColor3 = Color3.new(1, 1, 1),
					BackgroundColor3 = Color3.new(.5, .5, .5),
					BorderSizePixel = 0,
					Size = UDim2.new(1.0, 0, 1.0, 0),
					ZIndex = 3, Parent = searchCell.PlayerName,
					Focused = function()
						if search.Text == 'Username' then
							search.Text = ''
						end
						searchCell.Location:ClearAllChildren()
						joinButton.Visible = false
					end,
					FocusLost = function(enterPressed)
						if search.Text == '' then
							search.Text = 'Username'
							return
						end
						if not enterPressed then return end
						local tag = {}
						_p.DataManager:setLoading(tag, true)
						local msg, location, placeId, jobId = searchForPlayer(search.Text)
						_p.DataManager:setLoading(tag, false)
						if location and placeId and jobId then
							searchPlaceId, searchJobId = placeId, jobId
							searchCell.Location:ClearAllChildren()
							write(location) {
								Frame = searchCell.Location,
								Scaled = true,
							}
							joinButton.Visible = true
						elseif msg ~= '' then
							searchPlaceId, searchJobId = nil, nil
							gui.gui.ErrorText:ClearAllChildren()
							write(msg) {
								Frame = gui.gui.ErrorText,
								Scaled = true,
								Color = Color3.new(.9, .2, .2),
							}
							wait(4)
							gui.gui.ErrorText:ClearAllChildren()
						end
					end,
				}
			end
			local nList = 0
			local list = gui.gui.List
			local container = list.Container
			container:ClearAllChildren()
			local function addToList(name, location, placeId, jobId)
				nList = nList + 1
				local contentRelativeSize = nList*ht*container.AbsoluteSize.X/list.AbsoluteSize.Y
				list.CanvasSize = UDim2.new(list.Size.X.Scale, -1, contentRelativeSize * list.Size.Y.Scale, 0)
				local cell = tableCell()
				if nList%2 == 1 then
					cell.BackgroundColor3 = Color3.new(.8, .8, .8)
				else
					cell.BackgroundTransparency = 1.0
				end
				cell.Size = UDim2.new(1.0, 0, ht, 0)
				cell.Position = UDim2.new(0.0, 0, ht*(nList-1), 0)
				cell.Parent = container
				write(name) {
					Frame = cell.PlayerName,
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}
				write(location) {
					Frame = cell.Location,
					Scaled = true,
				}
				local button = create 'TextButton' {
					Text = '',
					BackgroundColor3 = Color3.new(0, .24, .5),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Size = UDim2.new(.175, 0, 0.8, 0),
					Position = UDim2.new(0.8, 0, 0.1, 0),
					ZIndex = 3, Parent = cell,
					MouseButton1Click = function()
						self:teleport(placeId, jobId)
					end,
				}
				write 'Join' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.8, 0),
						Position = UDim2.new(0.5, 0, 0.1, 0),
						ZIndex = 4, Parent = button,
					},
					Scaled = true,
				}
			end
			local thisThread = {}
			thread = thisThread
			Utilities.fastSpawn(function()
				local spinner = create 'ImageLabel' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://6142797850',
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(0.05, 0, 0.05, 0),
					Position = UDim2.new(0.015, 0, 0.135, 0),
					ZIndex = 3, Parent = gui.gui,
				}
				spawn(function()
					local st = tick()
					while spinner.Parent and open do
						stepped:wait()
						spinner.Rotation = (tick()-st)*250
					end
					pcall(function() spinner:remove() end)
				end)
				local s, r = ypcall(function()
					for _, _, friend in Utilities.pageItemPairs(players:GetFriendsAsync(_p.userId)) do
						Utilities.print_r(friend)
						if thisThread ~= thread then return end
						--if friend.IsOnline then
						Utilities.fastSpawn(function()
							local success, errorMsg, placeId, jobId
							local s, r = pcall(function()
								success, errorMsg, placeId, jobId = getPlayerPlaceInstanceAsync(friend.Id)
							end)
							if not s then
								warn('Unable to get friend location:', r)
							end
							local ya, na = pcall(function()
								local location = locations[placeId]
								if location and thisThread == thread then
									addToList(friend.Username, location, placeId, jobId)
								end
							end)
						end)
						--end
					end
				end)
				if not s then
					warn('Unable to get friends:', r)
				end
				spinner:remove()
			end)
			open = true
			local sp = gui.Position.Y.Scale
			local ep = .15
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				if thisThread ~= thread then return false end
				gui.Position = UDim2.new(.2, 0, sp + (ep-sp)*a, 0)
			end)
		end

		function rtd:closePlayerSearch()
			if not gui or not open then return end
			open = false
			local thisThread = {}
			thread = thisThread
			local sp = gui.Position.Y.Scale
			local ep = .15-1
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				if thisThread ~= thread then return false end
				gui.Position = UDim2.new(.2, 0, sp + (ep-sp)*a, 0)
			end)
		end
	end

	function rtd:teleport(placeId, jobId)
		if not _p.Menu.enabled or _p.Battle.currentBattle or _p.Trade.sessionId then return end
		if _p.PlayerData.hasIllegalPokemon and placeId == _p.placeId.Trade then return end
		if _p.userId < 0 then
			_p.NPCChat:say('You cannot teleport out of adventure mode as a Guest.')
			return
		end
		spawn(function() rtd:closePlayerSearch() end)
		local text1, text2 = unpack(({
			[_p.placeId.Main] = {'WELCOME', 'BACK'},
			[_p.placeId.Battle] = {'BATTLE', 'COLOSSEUM'},
			[_p.placeId.Trade] = {'TRADE', 'RESORT'},
		})[placeId])
		spawn(function() self:close() end)
		spawn(function() _p.Menu:disable() end)
		local function cancel()
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()

			_p.Menu:enable()
		end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		if _p.DataManager.currentChunk.regionData and _p.DataManager.currentChunk.regionData.RTDDisabled then
			local location = _p.DataManager.currentChunk.regionData.Name
			if not location then
				location = 'here'
			elseif location:sub(1, 5) == 'Route' then
				location = 'on '..location
			else
				location = 'in '..location
			end
			_p.NPCChat:say('The RTD doesn\'t seem to get a very good signal '..location..'.')
			cancel()
			return
		end
		local chat = _p.NPCChat
		if chat:say('You must save before teleporting with the RTD.', '[y/n]Would you like to save the game?') then
			if self.willOverwriteIfSaveFlag and not chat:say('There is another save file that will be overwritten.', '[y/n]Are you sure you want to save?') then
				cancel()
				return
			end
			spawn(function() chat:say('[ma]Saving...') end)
			local success = _p.PlayerData:save()
			wait()
			chat:manualAdvance()
			if success then
				--			_p.DataManager:commitPermanentKeys()
				Utilities.sound(301970897, nil, nil, 3)
				chat:say('Save successful!')
				self.willOverwriteIfSaveFlag = nil
			else
				chat:say('SAVE FAILED!', 'You were unable to teleport.', 'Please try again.')
				cancel()
				return
			end
		else
			cancel()
			return
		end
		if _p.Battle.currentBattle or _p.Trade.sessionId then return end

		local gui = create 'ScreenGui' {
			Name = 'TeleportGui',
			Parent = Utilities.gui.Parent,
		}
		local container = create 'Frame' {
			BackgroundTransparency = 1.0,

			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
			Parent = gui,
		}
		local top = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 0.5, 0),
			Position = UDim2.new(0.0, 0, 0.0, 0),
			ClipsDescendants = true,
			Parent = container,
		}
		local bottom = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 0.5, 0),
			Position = UDim2.new(0.0, 0, 0.5, 0),
			ClipsDescendants = true,
			Parent = container,

			create 'Frame' {
				Name = 'div',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 2.0, 0),
				Position = UDim2.new(0.0, 0, -1.0, 0),
			}
		}
		local function tileBackgroundTexture(frameToFill)
			frameToFill:ClearAllChildren()
			local backgroundTextureSize = Vector2.new(512, 512)
			for i = 0, math.ceil(frameToFill.AbsoluteSize.X/backgroundTextureSize.X) do
				for j = 0, math.ceil(frameToFill.AbsoluteSize.Y/backgroundTextureSize.Y) do
					create 'ImageLabel' {
						BackgroundTransparency = 1,
						Image = 'rbxasset://textures/loading/darkLoadingTexture.png',
						Position = UDim2.new(0, i*backgroundTextureSize.X, 0, j*backgroundTextureSize.Y),
						Size = UDim2.new(0, backgroundTextureSize.X, 0, backgroundTextureSize.Y),
						ZIndex = 2,
						Parent = frameToFill,
					}
				end
			end
		end
		local function onScreenSizeChanged(prop)
			if prop ~= 'AbsoluteSize' then return end
			tileBackgroundTexture(top)
			tileBackgroundTexture(bottom.div)
		end
		local ch = gui.Changed:connect(onScreenSizeChanged)
		onScreenSizeChanged('AbsoluteSize')
		Utilities.Tween(1, 'easeOutCubic', function(a)
			top.Position = UDim2.new(0.0, 0, -0.5+0.5*a, 0)
			bottom.Position = UDim2.new(0.0, 0, 1.0-0.5*a, 0)
		end)

		local data = {
			passcode = 'PBB_RTD_fast12<',
			userId = _p.userId,
			text1 = text1,
			text2 = text2,
		}
		-- To quote @spotco on the devforums   devforum.roblox.com/t/teleportservice-why-is-it-so-unreliable/28538/5
		-- teleport will "fail" some 2 of 3 times. It was suggested to try wrapping in pcall and making multiple 
		-- attempts, however, isn't the teleport actually failing later than the request is made?
		-- TeleportToPlaceInstance and Teleport are listed as Functions (not YieldFunctions), so why would it error
		-- immediately? Nonetheless, we have implemented this suggestion here, because why not.
		for i = 1, 4 do
			if jobId then
				if (pcall(function() teleportService:TeleportToPlaceInstance(placeId, jobId, _p.player, nil, data, gui) end))
				then break end
			else
				if (pcall(function() teleportService:Teleport(placeId, _p.player, data, gui) end))
				then break end
			end
		end
		wait(16)
		-- teleport failed
		ch:disconnect()
		gui:remove()
		cancel()
	end

	local yposition = (555-389-5)/555
	function rtd:enable()
		local gui = self.gui
		if not gui then
			gui = create 'ImageLabel' { -- 184 x 389
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6149881785', -- 313053191 -- 311460172
				Size = UDim2.new(1.0, 0, 389/555, 0),
				Position = UDim2.new(0.0, 0, yposition, 0),
				ZIndex = 2,

				create 'Frame' {
					Name = 'MainContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(133/184, 0, 1.0, 0),

					create 'ImageButton' { -- 100 x 80
						Name = 'BattleButton',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6811519051',
						ImageColor3 = Color3.new(.9, .65, .65),
						Size = UDim2.new(108/184, 0, 86/389, 0),
						Position = UDim2.new((184-108)/2/184, 0, 20/389, 0),
						ZIndex = 3,

						create 'ImageLabel' {
							Name = 'Icon',
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://5221286628',
							ImageColor3 = Color3.new(.7, .3, .35),
							Size = UDim2.new(0.8, 0, 1.0, 0),
							Position = UDim2.new(0.1, 0, 0.0, 0),
							ZIndex = 4,
						},
					},
					create 'Frame' {
						Name = 'BattleText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.275, 0),
						ZIndex = 3,
					},
					create 'Frame' {
						Name = 'ColosseumText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.335, 0),
						ZIndex = 3,
					},

					create 'ImageButton' {
						Name = 'TradeButton',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6811519051',
						ImageColor3 = Color3.new(.65, .65, .9),
						Size = UDim2.new(108/184, 0, 86/389, 0),
						Position = UDim2.new((184-108)/2/184, 0, 160/389, 0),
						ZIndex = 3,

						create 'ImageLabel' { -- 240x163
							Name = 'Icon',
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://5221304112',
							ImageColor3 = Color3.new(.35, .3, .7),
							Size = UDim2.new(240/250, 0, 163/200, 0),
							Position = UDim2.new(5/250, 0, 25/200, 0),
							ZIndex = 4,
						},
					},
					create 'Frame' {
						Name = 'TradeText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.64, 0),
						ZIndex = 3,
					},
					create 'Frame' {
						Name = 'ResortText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.7, 0),
						ZIndex = 3,
					},

					create 'ImageButton' {
						Name = 'PSearchButton',
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://6811519051',
						ImageColor3 = Color3.new(.9, .9, .9),
						Size = UDim2.new(140/184, 0, 64/389, 0),
						Position = UDim2.new((184-140)/2/184, 0, 305/389, 0),
						ZIndex = 3,
						MouseButton1Click = function()
							self:playerSearch()
						end,
					},
				},
				create 'TextButton' { -- tl 137, 22; 41 x 141
					Name = 'MenuButton',
					Text = '',
					BackgroundTransparency = 1.0,
					Rotation = 90,
					Size = UDim2.new(131/184, 0, 41/389, 0),
					Position = UDim2.new(92/184, 0, 72/389, 0),
					MouseButton1Click = function()
						if not _p.Menu.enabled then return end
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
						ZIndex = 5,
					}
				},

				-- RO-Powers tab
				create 'ImageLabel' { -- essentially 50x180
					Name = 'RoPowersTab',
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://6149629274',
					ImageRectSize = Vector2.new(50, 180),
					ImageRectOffset = Vector2.new(200, 2),
					Size = UDim2.new(50/184, 0, 180/389, 0),
					Position = UDim2.new(133/184, 0, 0.365, 0),

					create 'TextButton' {
						Name = 'MenuButton',
						Text = '',
						BackgroundTransparency = 1.0,
						Rotation = 90,
						Size = UDim2.new(140/50, 0, 40/180, 0),
						Position = UDim2.new(-45/50, 0, 70/180, 0),
						MouseButton1Click = function()
							if not _p.Menu.enabled then return end
							_p.Menu.ropowers:open()
						end,

						create 'Frame' {
							Name = 'ButtonText',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.4, 0),
							Position = UDim2.new(0.5, 0, 0.25, 0),
							ZIndex = 5,
						}
					},
				}
			}
			gui.Parent = Utilities.gui
			write 'RTD' {
				Frame = gui.MenuButton.ButtonText,
				Color = Color3.new(.3, .3, .3),
				Scaled = true,
			}
			local adventureButton
			if _p.context == 'battle' then
				adventureButton = gui.MainContainer.BattleButton
				write 'Adventure' { Frame = gui.MainContainer.BattleText, Scaled = true, Color = Color3.new(.1, .4, .1), }
				write 'Mode' { Frame = gui.MainContainer.ColosseumText, Scaled = true, Color = Color3.new(.1, .4, .1), }
			else
				write 'Battle' { Frame = gui.MainContainer.BattleText, Scaled = true, Color = Color3.new(.7, .3, .35), }
				write 'Colosseum' { Frame = gui.MainContainer.ColosseumText, Scaled = true, Color = Color3.new(.7, .3, .35), }
				gui.MainContainer.BattleButton.MouseButton1Click:connect(function()
					self:teleport(_p.placeId.Battle)
				end)
			end
			if _p.context == 'trade' then
				adventureButton = gui.MainContainer.TradeButton
				write 'Adventure' { Frame = gui.MainContainer.TradeText, Scaled = true, Color = Color3.new(.35, .7, .35), }
				write 'Mode' { Frame = gui.MainContainer.ResortText, Scaled = true, Color = Color3.new(.35, .7, .35), }
			else
				write 'Trade' { Frame = gui.MainContainer.TradeText, Scaled = true, Color = Color3.new(.35, .3, .7), }
				write 'Resort' { Frame = gui.MainContainer.ResortText, Scaled = true, Color = Color3.new(.35, .3, .7), }
				gui.MainContainer.TradeButton.MouseButton1Click:connect(function()
					self:teleport(_p.placeId.Trade)
				end)
			end
			write 'Player' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.3, 0),
					Position = UDim2.new(0.5, 0, 0.125, 0),
					ZIndex = 4, Parent = gui.MainContainer.PSearchButton,
				}, Scaled = true, Color = Color3.new(.3, .3, .3),
			}
			write 'Search' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.3, 0),
					Position = UDim2.new(0.5, 0, 0.575, 0),
					ZIndex = 4, Parent = gui.MainContainer.PSearchButton,
				}, Scaled = true, Color = Color3.new(.3, .3, .3),
			}
			if adventureButton then
				adventureButton.ImageColor3 = Color3.new(.65, .9, .65)
				adventureButton.Icon.Image = 'rbxassetid://6142797841'
				adventureButton.Icon.ImageColor3 = Color3.new(.35, .7, .35)
				adventureButton.Icon.Size = UDim2.new(0.8, 0, 0.8, 0)
				adventureButton.Icon.Position = UDim2.new(0.1, 0, 0.1, 0)
				adventureButton.MouseButton1Click:connect(function()
					self:teleport(_p.placeId.Main)
				end)
			end

			write 'RO-Powers' {
				Frame = gui.RoPowersTab.MenuButton.ButtonText,
				Color = Color3.new(.3, .3, .3),
				Scaled = true,
			}

			gui.Parent = _p.Menu.gui
			self.gui = gui
		end

	end

	function rtd:open()
		if not self.gui then return end
		if _p.NPCChat.chatBox and _p.NPCChat.chatBox.Parent then return end
		if self.isOpen or not _p.Menu.enabled then return end
		self.isOpen = true
		local menuGui, menuS, menuE, rtdX
		local gui = self.gui
		if _p.Menu.isOpen then
			--spawn(function() _p.Menu:close() end)
			_p.Menu.isOpen = false
			menuGui = _p.Menu.gui
			menuS = menuGui.Position.X.Offset
			menuE = -menuGui.AbsoluteSize.X/184*133
			rtdX = gui.AbsolutePosition.X
		end
		local xs = gui.Position.X.Scale
		local xe = 132/184
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if not self.isOpen or not _p.Menu.enabled then return false end
			if menuGui then
				menuGui.Position = UDim2.new(0.0, menuS + (menuE-menuS)*a, 0.3, 0)
				gui.Position = UDim2.new(0.0, (rtdX*(1-a))-menuGui.AbsolutePosition.X, yposition, 0)
			else
				gui.Position = UDim2.new(xs + (xe-xs)*a, 0, yposition, 0)
			end
		end)
		if self.isOpen and not _p.Menu.isOpen then
			gui.Position = UDim2.new(xe, 0, yposition, 0)
		end
	end

	function rtd:close()
		if not self.gui then return end
		if not self.isOpen or not _p.Menu.enabled then return end
		self.isOpen = false
		local gui = self.gui
		local xs = gui.Position.X.Scale
		local xe = 0
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			if self.isOpen then return false end
			gui.Position = UDim2.new(xs + (xe-xs)*a, 0, yposition, 0)
		end)
	end

	return rtd end