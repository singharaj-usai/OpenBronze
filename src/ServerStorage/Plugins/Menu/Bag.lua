--[[
My ScrollingFrame logic:
let scrollList = the ScrollingFrame
 scrollList.SizeConstraint must be RelativeXY
let sbw = width (in pixels) of scrollbar (dynamic, relative)
let container = an invisible subframe of scrollList with SizeConstraint.RelativeXX and Size 1.0, -sbw, 1.0, -sbw
onUpdateList:
 let h = height of an individual item (or row) in list (factor of width of list)
 let n = the number of items (or rows) in the list
 let contentRelativeSize = n * h * container.AbsoluteSize.X / scrollList.AbsoluteSize.Y
 set scrollList.CanvasSize = UDim2.new(scrollList.Size.X.Scale, -1, contentRelativeSize * scrollList.Size.Y.Scale, 0)
 parent list items to container, Size (x, 0, h, 0)
--]]
local ITEM_SHEET_ID = 16644464645

return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local Utilities = _p.Utilities
	local rc4 = Utilities.rc4
	local create = Utilities.Create
	local write = Utilities.Write
	local fastSpawn = Utilities.fastSpawn
	local MasterControl = _p.MasterControl
	local usableItems = require(script.UsableItems)(_p)

	local pokemonClickedSignal, takeItemRF
	local function removeTakeItemRF()
		if takeItemRF then
			takeItemRF:remove()
			takeItemRF = nil
		end
	end

	local zpouchalreadyenable = false
	local buttons
	local bag = {}

	local tmIcons = {
		Bug = 326,
		Dark = 310,
		Dragon = 311,
		Electric = 321,
		Fairy = 547,
		Fighting = 316,
		Fire = 317,
		Flying = 324,
		Ghost = 323,
		Grass = 319,
		Ground = 322,
		Ice = 315,
		Normal = 313,
		Poison = 314,
		Psychic = 312,
		Rock = 320,
		Steel = 325,
		Water = 318,
	}
	local hmIcons = {
		Fighting = 589,
		Flying = 328,
		Normal = 327,
		Water = 329,
	}

	local zMoveTable = {
		[777] = true, --fire
		[778] = true, --water
		[779] = true, --grass
		[780] = true, --dragon
		[781] = true, --bug
		[782] = true, --ice
	}
	local customitemsIcons = {
		-- Z Moves
		[777] = 7178511815, --fire
		[778] = 7178511351, --water
		[779] = 7178510651, --grass
		[780] = 7178510005, --dragon
		[781] = 7178509336, --bug
		[782] = 7178508509, --ice

		-- Other
		[783] = 7178513870, -- Epineshroom
		[459] = 7178514797, -- Bottle Cap
		[402] = 7178512319, -- GS Ball
		[784] = 7316986660, -- Voltaic Ticket
		[785] = 7316986660, -- Frigid Ticket
		[786] = 7316986660 -- Obsidian Ticket
	}

	function bag:getItemIcon(item)
		local icon
		if type(item)=='number' then
			icon = item
		else
			icon = item.icon or item.num
			if item.name:sub(1, 2) == 'TM' or item.name:sub(1, 2) == 'HM' then
				local type = item.name:sub(3)
				if item.name:sub(1, 1) == 'H' and hmIcons[type] then
					icon = hmIcons[type]
				else
					icon = tmIcons[type]
				end
			end
		end
		local function iscustomitems() local s, e = pcall(function() return customitemsIcons[icon] end) if s then return customitemsIcons[icon] end end
		local s = 0.9
		return create 'ImageLabel' {
			Name = 'ItemIcon',
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://'..(not iscustomitems() and ITEM_SHEET_ID or tostring(customitemsIcons[icon])),
			ImageRectSize = not iscustomitems() and Vector2.new(32, 32) or Vector2.new(0, 0),
			ImageRectOffset = not iscustomitems() and Vector2.new(32*((icon-1)%26), 32*math.floor((icon-1)/26)) or Vector2.new(0, 0),
			Size = UDim2.new(s*2/3, 0, s, 0),
			Position = UDim2.new(0.5-s/3, 0, 0.0, 0),
			ZIndex = 4,
		}
	end

	function bag:partyIconClicked(index)
		if pokemonClickedSignal then
			pokemonClickedSignal:fire(index)
		else
			local pokemon
			pcall(function() pokemon = self.partyData[index] end)
			if pokemon and not pokemon.egg then
				if pokemon.itemId then
					removeTakeItemRF()
					takeItemRF = _p.RoundedFrame:new {
						Button = true,
						CornerRadius = 5,
						BackgroundColor3 = Color3.new(.4, .4, .4),
						Size = UDim2.new(0.5, 0, 0.5, 0),
						Position = UDim2.new(0.575, 0, 0.9, 0),
						ZIndex = 9, Parent = self.partyGui[index].gui,
						MouseButton1Click = function()--::takeItem
							removeTakeItemRF()
							local s, d, p = _p.Network:get('PDS', 'takeItem', index)
							if s then
								-- increment cache
								local pouch = self.pouchCache[p]
								if pouch then
									local updated = false
									for i, item in pairs(pouch) do
										if item.id == d.id then
											pouch[i] = d
											updated = true
											break
										end
									end
									if not updated then
										pouch[#pouch+1] = d
									end
								end
								pokemon.itemId   = nil
								pokemon.itemName = nil
								pokemon.itemIcon = nil
							end
							self:updatePartyList(self.currentPouch, index)
							self:updateCurrentPouch()
						end,
					}
					write 'Take Item' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.8, 0),
							Position = UDim2.new(0.5, 0, 0.1, 0),
							ZIndex = 10, Parent = takeItemRF.gui,
						}, Scaled = true,
					}
				end
			end
		end
	end

	function bag:updatePartyList(pouch, specificPokemonIndex, ZMoveText, ZMoveColor)--::updatePartyList
		local tm
		if type(pouch) == 'table' and not ZMoveText then
			tm, pouch = pouch, nil
		end
		fastSpawn(function()
			local party = self.partyData
			local rewriteNames = false
			if not party then
				rewriteNames = true
				local thisThread = {}
				self.partyThread = thisThread
				party = _p.Network:get('PDS', 'getParty', 'bag')
				if self.partyThread ~= thisThread then return end
				for i, p in pairs(party) do p.index = i end
				self.partyData = party
				self.partyThread = nil
			end

			local partyGui = self.partyGui
			-- create gui (if not yet created)

			if not partyGui then
				local container = self.backdrop.NormalContainer.PartyContainer
				partyGui = {}
				-- background
				_p.RoundedFrame:new {
					BackgroundColor3 = Color3.new(.9, .625, 0),
					Size = UDim2.new(1.1, 0, 1.025, 0),
					Position = UDim2.new(-0.05, 0, -0.025, 0),
					ZIndex = 7, Parent = container,
				}
				for i = 1, 6 do
					local rf = _p.RoundedFrame:new {
						Button = true,
						BackgroundColor3 = Color3.new(.3, .3, .3),
						Size = UDim2.new(1.0, 0, 1/6-.025, 0),
						Position = UDim2.new(0.0, 0, (i-1)/6, 0),
						ZIndex = 8, Parent = container,
						MouseButton1Click = function()
							self:partyIconClicked(i)
						end,

						create 'Frame' {
							Name = 'PokeIconContainer',
							BackgroundTransparency = 1.0,
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(4/3, 0, 1.0, 0),
							Position = UDim2.new(-0.025, 0, 0.0, 0)
						},
						create 'Frame' {
							Name = 'NameContainer',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.5, 0),
							Position = UDim2.new(0.1875, 0, 0.05, 0),
							ZIndex = 9
						},
						create 'Frame' {
							Name = 'ItemIconContainer',
							BackgroundTransparency = 1.0,
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(-0.6, 0, 0.6, 0),
							Position = UDim2.new(0.95, 0, 0.3, 0)
						},
						create 'Frame' {
							Name = 'LearnContainer',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.35, 0),
							Position = UDim2.new(0.7, 0, 0.575, 0),
							ZIndex = 116
						}
					}
					-- hp bar
					local hpbar = _p.RoundedFrame:new {
						BackgroundColor3 = Color3.new(.9, .9, .9),
						Size = UDim2.new(.6, 0, .2, 0),
						Position = UDim2.new(.25, 0, .65, 0),
						Style = 'HorizontalBar',
						ZIndex = 9, 
						Parent = rf.gui,
						Visible = (not ZMoveText)
					}
					hpbar:setupFillbar('gyr', Utilities.isPhone() and 1 or 2)
					rf.hpbar = hpbar
					rf.status = _p.RoundedFrame:new {
						Name = 'status',
						Size = UDim2.new(0.125, 0, 0.25, 0),
						Position = UDim2.new(0.1, 0, 0.625, 0),
						Style = 'HorizontalBar',
						ZIndex = 9, Parent = rf.gui,

						create 'Frame' {
							Name = 'text',
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.8, 0),
							Position = UDim2.new(0.5, 0, 0.1, 0),
							ZIndex = 10
						}
					}.gui
					partyGui[i] = rf
				end
				self.partyGui = partyGui
			end
			-- update gui
			local function update(i)
				self.PG = partyGui;

				local slot = partyGui[i]

				if slot and slot.gui then
					slot.gui.PokeIconContainer:ClearAllChildren()
					if rewriteNames then slot.gui.NameContainer:ClearAllChildren() end
					slot.gui.ItemIconContainer:ClearAllChildren()
					slot.gui.LearnContainer:ClearAllChildren()
					slot.hpbar.Visible = false
					slot.status.Visible = false
				end

				local pokemon = party[i]

				if pokemon then
					local icon = _p.Pokemon:getIcon(pokemon.icon, pokemon.shiny)
					icon.ZIndex = 9                                        -- if not egg
					pcall(function() icon:GetChildren()[1].ZIndex = 9 end) -- if egg
					icon.Parent = slot.gui.PokeIconContainer

					if rewriteNames then
						write(pokemon.name) {Frame = slot.gui.NameContainer, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left}
					end
					if pokemon.itemIcon then
						local icon = self:getItemIcon(pokemon.itemIcon)
						icon.Size = UDim2.new(1.0, 0, 1.0, 0)
						icon.Position = UDim2.new(0.0, 0, 0.0, 0)
						icon.ZIndex = 9
						icon.Parent = slot.gui.ItemIconContainer
					end
					if pouch --[[== 2]] and not pokemon.egg then
						slot.hpbar:setFillbarRatio(pokemon.hp/pokemon.maxhp)
						slot.hpbar.Visible = true
						-- status
						slot.status.text:ClearAllChildren()
						_p.Menu.party:updateStatusLabel(slot.status, pokemon.status)
					end
					if pouch == 6 then
						--MROPHERE

						--print(pokemon)


					end;
					if ZMoveText then
						slot.hpbar.Visible = false

						write(ZMoveText) {
							Frame = slot.gui.LearnContainer,
							Scaled = true,
							Color = ZMoveColor,
						}						
					end
					if tm then
						local learned  = tm.learn[i] == 2
						local canLearn = tm.learn[i] == 1
						local text, color = unpack(({
							{'Unable', Color3.new(.9, .3, .3)},
							{'Able', Color3.new(1, 1, 1)},
							{'Learned', Color3.new(.3, .6, .9)},
						})[tm.learn[i]+1] or {})
						if text and color then
							write(text) {
								Frame = slot.gui.LearnContainer,
								Scaled = true,
								Color = color,
							}
						end
					end
				end
			end
			if specificPokemonIndex then
				update(specificPokemonIndex)
			else
				for i = 1, 6 do update(i) end
			end
		end)
	end

	function bag:updatePartyForLearningTM(tm)
		if self.sellEvent then return end
		self.updatePartyOnDeselect = true
		self:updatePartyList(tm)
	end

	function bag:deselect()
		removeTakeItemRF()
		self.selection = nil
		pcall(function() self.selectionGui:remove() end)
		self.selectionSell.Visible = false
		self.selectionChoose.Visible = false
		self.selectionUse.Visible = false
		self.selectionGive.Visible = false
		self.selectionRegister.Visible = false
		self.selectionToss.Visible = false
		self.descContainer:ClearAllChildren()

		pcall(function() self.backdrop.BattleDetailsContainer.ItemIcon:remove() end)
		self.battleSelectionName:ClearAllChildren()
		self.battleSelectionQty:ClearAllChildren()
		self.btlDescContainer:ClearAllChildren()
		if self.updatePartyOnDeselect then
			self.updatePartyOnDeselect = nil
			-- instead, we should do some kind of clear but not request new data
			--		self:updatePartyList()
		end
	end

	function bag:selectItem(item, gui, pouch)--::selectItem
		if self.busy then return end
		self:deselect()
		self.selection = item
		self.selectionGui = create 'ImageLabel' { -- OVH  todo: modify gui for TMs
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://132696627530715',
			--		ScaleType = Enum.ScaleType.Slice,
			--		SliceCenter = Rect.new(17, 17, 133, 83),
			Size = UDim2.new(1.1, 0, 1+.1*.75, 0),
			Position = UDim2.new(-0.05, 0, -0.05*.75, 0),
			ZIndex = 4, Parent = gui,
		}

		if self.sellEvent then
			self.selectionSell.Visible = item.sell and true or false
		elseif self.chooseEvent then
			self.selectionChoose.Visible = true
		elseif zMoveTable[item.icon] then
			-- ZMove!

			self.selectionUse.Visible = true;
			--self.selectionGive.Visible = true;
		else
			self.selectionUse.Visible      = item.tm or usableItems[item.id]~=nil or item.canUse
			self.selectionGive.Visible     = pouch and pouch < 5 
			--		self.selectionRegister.Visible = pouch == 5 and (usableItems[item.id]~=nil or item.canUse) -- TODO: make `Register` a thing
			self.selectionToss.Visible     = pouch and pouch < 5 and item.id ~= 'masterball'
		end
		if item.desc then
			write(item.desc) {
				Frame = self.descContainer,
				Size = self.descContainer.AbsoluteSize.Y/5.8,
				Wraps = true,
			}
		end
		if item.tm then
			self:updatePartyForLearningTM(item)
		end
	end

	function bag:sellSelectedItem()
		local item = self.selection
		if not item or not item.sell then return end
		local qty = self:selectQuantity(item.qty, self:getItemIcon(item.icon), 'How many will you sell?', '[$]%d', item.sell)
		if not qty then return end
		local r = _p.Network:get('PDS', 'sellItem', item.id, qty)
		if r == 'fw' then
			_p.NPCChat:say('Your wallet is full!')
			return
		elseif not r then
			_p.NPCChat:say('An error occurred.')
			return
		end
		self:deselect()
		-- update cache
		item.qty = item.qty - qty
		if item.qty < 1 then
			local pouch = self.pouchCache[self.currentPouch]
			if pouch then
				for i = #pouch, 1, -1 do
					if pouch[i] == item then
						table.remove(pouch, i)
						break
					end
				end
			end
		end
		_p.PlayerData.money = r
		self:updateMoney()
		self:updateCurrentPouch()
	end

	function bag:chooseSelectedItem()
		self.chooseEvent:fire(self.selection.id)
		self:close()
	end

	function bag:useSelectedItem()--::useSelectedItem
		-- Implement if user can have z move

		if self.busy then return end
		local item = self.selection
		if not item then return end
		self.busy = true
		local usableItem; if item.id then usableItem = usableItems[item.id] end
		local pokemon, _index, bg, txtRF, cancel
		if not usableItem or not usableItem.noTarget then
			bg = create 'ImageButton' {
				AutoButtonColor = false,
				BorderSizePixel = 0,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 0),
				ZIndex = 6, Parent = Utilities.gui,
			}
			txtRF = _p.RoundedFrame:new {
				BackgroundColor3 = Color3.new(.3, .3, .3),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.95, 0, 0.1, 0),
				Position = UDim2.new(0.1125, 0, 0.03, 0),
				ZIndex = 7, Parent = bg,
			}
			write 'Use on which pokemon?' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.6, 0),
					Position = UDim2.new(0.5, 0, 0.2, 0),
					ZIndex = 8, Parent = txtRF.gui,
				}, Scaled = true,
			}
			cancel = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.25, 0, 0.7, 0),
				Position = UDim2.new(1.05, 0, 0.15, 0),
				ZIndex = 7, Parent = txtRF.gui,
				MouseButton1Click = function()
					pokemonClickedSignal:fire()
				end,
			}
			write 'Cancel' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					ZIndex = 8, Parent = cancel.gui,
				}, Scaled = true,
			}
			pokemonClickedSignal = Utilities.Signal()
			while true do
				local i = pokemonClickedSignal:wait()
				if not i or not self.partyData then break end
				pokemon = self.partyData[i]
				if pokemon.egg then pokemon = nil end
				if pokemon then break end
			end
		end
		local use = false
		if pokemon or (usableItem and usableItem.noTarget) then
			local chat = _p.NPCChat
			if item.tm then
				local l = item.learn[pokemon.index]
				if l == 2 then
					chat:say(pokemon.name .. ' already knows ' .. item.mName .. '!')
				elseif l == 0 then
					chat:say(pokemon.name .. ' cannot learn ' .. item.mName .. '!')
				else
					if chat:say('Booted up ' .. (item.hm and 'an HM.' or 'a TM.'), 'It contains ' .. item.mName .. '.', '[y/n]Teach ' .. item.mName .. ' to ' .. pokemon.name .. '?') then
						local moves, decision = _p.Network:get('PDS', 'teachTM', pokemon.index, item.num, item.hm)
						if moves == true then
							chat:say(pokemon.name .. ' learned ' .. item.mName .. '!')
							item.learn[pokemon.index] = 2
							self:updatePartyList(item, pokemon.index)
						elseif moves and decision then
							local newMove = table.remove(moves)
							if _p.Pokemon:tryLearnMove(pokemon.name, moves, {id = decision, move = newMove}) then
								item.learn[pokemon.index] = 2
								self:updatePartyList(item, pokemon.index)
							else
								_p.Network:get('PDS', 'makeDecision', decision, nil)
							end
							--					else
							-- an error occurred
						end
					end
				end
			elseif item.compat then
				local compat = item.compat[pokemon.index]
				if compat > 0 or chat:say("[y/n]This pokemon currently can't use this crystal's Z-Power. Is that OK?") then
					chat:say("The " .. item.name .. " will be given to the pokemon so that the pokemon can use its Z-Power!")
					if not pokemon.itemName or chat:say(pokemon.name .. " is already holding a " .. pokemon.itemName .. ".", "[y/n]Would you like to switch the two items?") then
						if _p.Network:get("PDS", "useItem", item.id, pokemon.index) then
							if pokemon.itemName then
								chat:say("You took the pokemon's " .. pokemon.itemName .. " and gave it the " .. item.name .. ".")
								for i = 1, 4 do
									pcall(function()
										self.pouchCache[i] = nil
									end)
								end
							else
								chat:say("Your pokemon is now holding the " .. item.name .. "!")
							end
							pokemon.itemId = item.id
							pokemon.itemName = item.name
							pokemon.itemIcon = item.icon
							self:updatePartyList(item, pokemon.index)
						else
							chat:say("An error occurred.")
						end
					end
				end
			elseif (usableItem and usableItem.canUse and (usableItem.canUse == true or usableItem.canUse(pokemon))) -- determined by client
				or (item.canUse and (item.canUse == true or item.canUse[tostring(pokemon.index)])) then             -- determined by server
				pcall(function() cancel:remove() end)
				pcall(function() txtRF:remove() end)
				pcall(function() bg:remove() end)
				use = true
				local smsg, updatedTarget = _p.Network:get('PDS', 'useItem', item.id, (pokemon and pokemon.index))
				if pokemon and updatedTarget then
					local index = pokemon.index
					updatedTarget.index = index
					self.partyData[index] = updatedTarget
					if pokemon.hp ~= updatedTarget.hp then
						pcall(function()
							local hpbar = self.partyGui[index].hpbar
							if not hpbar.Visible then return end
							hpbar:setFillbarRatio(updatedTarget.hp/updatedTarget.maxhp, true)
						end)
					end
					if pokemon.status ~= updatedTarget.status or pokemon.icon ~= updatedTarget.icon then
						self:updatePartyList(self.currentPouch, index)
					end
				end
				if smsg == false then
					chat:say('It won\'t have any effect.')
					use = false
				elseif type(smsg) == 'string' then
					chat:say(smsg)
				elseif usableItem and usableItem.onProcess then
					usableItem.onProcess(updatedTarget or pokemon, smsg)
					self.partyData = nil -- remove cache, force update
					self:updatePartyList(self.currentPouch)
				elseif item.id and item.id:match('repel$') then
					_p.Repel.more = smsg==1
				end
				if use and usableItem and usableItem.onUse then
					local cmsg = usableItem.onUse(pokemon)
					if cmsg then
						chat:say(cmsg)
					elseif cmsg == false then
						use = false
					end
				end
				if use and (not usableItem or not usableItem.nonConsumable) then
					-- decrement cache
					item.qty = item.qty - 1
					if item.qty < 1 then
						local pouch = self.pouchCache[self.currentPouch]
						if pouch then
							for i = #pouch, 1, -1 do
								if pouch[i] == item then
									table.remove(pouch, i)
									break
								end
							end
						end
					end
				end
			else
				chat:say('It won\'t have any effect.')
			end
		end
		pokemonClickedSignal = nil
		pcall(function() cancel:remove() end)
		pcall(function() txtRF:remove() end)
		pcall(function() bg:remove() end)
		if use then
			--		self:updatePartyList(self.currentPouch) -- called above, when necessary
			self:updateCurrentPouch()
			self:deselect()
		end
		self.busy = false
	end

	function bag:giveSelectedItem()--::giveSelectedItem
		if self.busy then return end
		local item = self.selection
		if not item then return end
		self.busy = true
		local bg = create 'ImageButton' {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 6, Parent = Utilities.gui,
		}
		local txtRF = _p.RoundedFrame:new {
			BackgroundColor3 = Color3.new(.3, .3, .3),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.95, 0, 0.1, 0),
			Position = UDim2.new(0.1125, 0, 0.03, 0),
			ZIndex = 7, Parent = bg,
		}
		write 'Give to which pokemon?' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.6, 0),
				Position = UDim2.new(0.5, 0, 0.2, 0),
				ZIndex = 8, Parent = txtRF.gui,
			}, Scaled = true,
		}
		local cancel = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = Color3.new(.4, .4, .4),
			Size = UDim2.new(0.25, 0, 0.7, 0),
			Position = UDim2.new(1.05, 0, 0.15, 0),
			ZIndex = 7, Parent = txtRF.gui,
			MouseButton1Click = function()
				pokemonClickedSignal:fire()
			end,
		}
		write 'Cancel' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.6, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				ZIndex = 8, Parent = cancel.gui,
			}, Scaled = true,
		}
		local pokemon
		pokemonClickedSignal = Utilities.Signal()
		while true do
			local i = pokemonClickedSignal:wait()
			if not i then break end
			pokemon = self.partyData[i]
			if pokemon.egg then pokemon = nil end
			if pokemon then break end
		end
		local give = false
		if pokemon then
			give = true
			local taking = pokemon.itemName
			if taking then
				local chat = _p.NPCChat
				if not chat:say('[y/n]Swap with ' .. taking .. '?') then
					give = false
				end
			end
			if give then
				local s, d, p = _p.Network:get('PDS', 'giveItem', item.id, pokemon.index)
				if s then
					-- decrement cache
					item.qty = item.qty - 1
					if item.qty < 1 then
						local pouch = self.pouchCache[self.currentPouch]
						if pouch then
							for i = #pouch, 1, -1 do
								if pouch[i] == item then
									table.remove(pouch, i)
									break
								end
							end
						end
					end
					-- increment cache (if taking)
					if d and p then
						local pouch = self.pouchCache[p]
						if pouch then
							local updated = false
							for i, item in pairs(pouch) do
								if item.id == d.id then
									pouch[i] = d
									updated = true
									break
								end
							end
							if not updated then
								pouch[#pouch+1] = d
							end
						end
					end
					pokemon.itemId   = item.id
					pokemon.itemName = item.name
					pokemon.itemIcon = item.icon
				else
					give = false
				end
			end
		end
		pokemonClickedSignal = nil
		cancel:remove()
		txtRF:remove()
		bg:remove()
		if give then
			self:updatePartyList(self.currentPouch, pokemon.index)
			self:updateCurrentPouch()
			self:deselect()
		end
		self.busy = false
	end

	function bag:giveZCrystal()--::giveSelectedItem
		if self.busy then return end

		local item = self.selection

		if not item then return end

		self.busy = true
		local bg = create 'ImageButton' {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 6, Parent = Utilities.gui,
		}
		local txtRF = _p.RoundedFrame:new {
			BackgroundColor3 = Color3.new(.3, .3, .3),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.95, 0, 0.1, 0),
			Position = UDim2.new(0.1125, 0, 0.03, 0),
			ZIndex = 7, Parent = bg,
		}
		write 'Use on which pokemon?' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.6, 0),
				Position = UDim2.new(0.5, 0, 0.2, 0),
				ZIndex = 8, Parent = txtRF.gui,
			}, Scaled = true,
		}
		local cancel = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = Color3.new(.4, .4, .4),
			Size = UDim2.new(0.25, 0, 0.7, 0),
			Position = UDim2.new(1.05, 0, 0.15, 0),
			ZIndex = 7, Parent = txtRF.gui,
			MouseButton1Click = function()
				pokemonClickedSignal:fire()
			end,
		}
		write 'Cancel' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.6, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				ZIndex = 8, Parent = cancel.gui,
			}, Scaled = true,
		}

		-- Mrophere

		for I=1, #self.partyData do
			local Poke = self.partyData[I];


			local text, color = _p.Network:get('PDS', 'HasZMoveOn', Poke.index, item.id);

			self:updatePartyList(item.id, I, text, color)
		end;

		local pokemon
		pokemonClickedSignal = Utilities.Signal()
		while true do
			local i = pokemonClickedSignal:wait()
			if not i then break end
			pokemon = self.partyData[i]
			if pokemon.egg then pokemon = nil end
			if pokemon then break end
		end
		local give = false
		if pokemon then
			give = true

			local taking = pokemon.itemName
			if taking then
				local chat = _p.NPCChat
				if not chat:say('[y/n]Swap with ' .. taking .. '?') then
					give = false
				end
			end
			if give then
				local s, d, p = _p.Network:get('PDS', 'giveItem', item.id, pokemon.index, true);

				if not s and d == 'nocrystal' then 
					local chat = _p.NPCChat
					chat:say('It won\'t have any effect.')
				end
				if s then
					-- decrement cache

					-- No need to decrease dummy


					--[[item.qty = item.qty - 1
					if item.qty < 1 then
						local pouch = self.pouchCache[self.currentPouch]
						if pouch then
							for i = #pouch, 1, -1 do
								if pouch[i] == item then
									table.remove(pouch, i)
									break
								end
							end
						end
					end--]]

					-- increment cache (if taking)

					if d and p then
						local pouch = self.pouchCache[p]
						if pouch then
							local updated = false
							for i, item in pairs(pouch) do
								if item.id == d.id then
									pouch[i] = d
									updated = true
									break
								end
							end
							if not updated then
								pouch[#pouch+1] = d
							end
						end
					end--]]

					pokemon.itemId   = item.id
					pokemon.itemName = item.name
					pokemon.itemIcon = item.icon
					local usableItem; if item.id then usableItem = usableItems[item.id] end
					local chat = _p.NPCChat

					chat:say('The '..item.name..' will be given to the Pokemon so that the Pokemon can use its Z-Power!')

					chat:say('Your Pokemon is now holding the '..item.name..'!')
				--[[local smsg, updatedTarget = _p.Network:get('PDS', 'useItem', item.id, (pokemon and pokemon.index))
				if smsg then 
					_p.NPCChat:say(smsg)
				end--]]

				else
					give = false
				end
			end
		end
		pokemonClickedSignal = nil
		cancel:remove()
		txtRF:remove()
		bg:remove()

		for I=1, #self.partyData do
			local Poke = self.partyData[I];

			self:updatePartyList(item.id, I)
		end;

		if give then
			self:updatePartyList(self.currentPouch, pokemon.index)
			self:updateCurrentPouch()
			self:deselect()
		end

		self.busy = false
	end

	function bag:selectQuantity(maxQty, icon, msg, format, price)
		local grey = Color3.new(.3, .3, .3)
		local bg = create 'ImageButton' {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Parent = Utilities.frontGui,
		}
		local prompt = _p.RoundedFrame:new {
			BackgroundColor3 = grey,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.6, 0, 0.2, 0),
			ZIndex = 2, Parent = Utilities.frontGui,
		}
		prompt.Position = UDim2.new(0.5, -prompt.AbsoluteSize.X/2, 0.4, 0)
		icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		icon.Position = UDim2.new()
		icon.Size = UDim2.new(1.0, 0, 1.0, 0)
		icon.Parent = prompt.gui
		local entryRF = _p.RoundedFrame:new {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(0.6, 0, 0.8, 0),
			Position = UDim2.new(0.35, 0, 0.1, 0),
			ZIndex = 3, Parent = prompt.gui,
		}
		if msg then
			write(msg) {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.08, 0),
					Position = UDim2.new(0.5, 0, 0.225, 0),
					ZIndex = 2, Parent = bg,
				}, Scaled = true,
			}
		end
		local tens = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.8, 0),
			Position = UDim2.new(0.275, 0, 0.1, 0),
			ZIndex = 4, Parent = entryRF.gui,
		}
		local ones = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.8, 0),
			Position = UDim2.new(0.725, 0, 0.1, 0),
			ZIndex = 4, Parent = entryRF.gui,
		}
		local priceFrame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.1, 0),
			Position = UDim2.new(0.5, 0, 0.8, 0),
			ZIndex = 3, Parent = bg,
		}
		local n = 1
		local function update()
			tens:ClearAllChildren()
			ones:ClearAllChildren()
			write(tostring(math.floor(n/10))) {
				Frame = tens,
				Color = grey,
				Scaled = true,
			}
			write(tostring(n%10)) {
				Frame = ones,
				Color = grey,
				Scaled = true,
			}
			priceFrame:ClearAllChildren()
			if format and price then
				write(string.format(format, price*n)) {
					Frame = priceFrame,
					Scaled = true,
				}
			end
		end
		update()
		create 'ImageButton' { -- tens up
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://122982582748288',
			Rotation = 180,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Size = UDim2.new(0.3, 0, -0.3*13/20, 0),
			Position = UDim2.new(0.125, 0, -0.1, 0),
			ZIndex = 3, Parent = entryRF.gui,
			MouseButton1Click = function()
				n = math.min(maxQty, n + 10)
				update()
			end,
		}
		create 'ImageButton' { -- tens down
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://122982582748288',
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Size = UDim2.new(0.3, 0, 0.3*13/20, 0),
			Position = UDim2.new(0.125, 0, 1.1, 0),
			ZIndex = 3, Parent = entryRF.gui,
			MouseButton1Click = function()
				n = math.max(1, n - 10)
				update()
			end,
		}
		create 'ImageButton' { -- ones up
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://122982582748288',
			Rotation = 180,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Size = UDim2.new(0.3, 0, -0.3*13/20, 0),
			Position = UDim2.new(0.575, 0, -0.1, 0),
			ZIndex = 3, Parent = entryRF.gui,
			MouseButton1Click = function()
				n = math.min(maxQty, n + 1)
				update()
			end,
		}
		create 'ImageButton' { -- ones down
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://122982582748288',
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Size = UDim2.new(0.3, 0, 0.3*13/20, 0),
			Position = UDim2.new(0.575, 0, 1.1, 0),
			ZIndex = 3, Parent = entryRF.gui,
			MouseButton1Click = function()
				n = math.max(1, n - 1)
				update()
			end,
		}
		local sig = Utilities.Signal()
		local ok = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = grey,
			Size = UDim2.new(0.6, 0, 0.6, 0),
			Position = UDim2.new(1.05, 0, 0.2, 0),
			ZIndex = 2, Parent = prompt.gui,
			MouseButton1Click = function()
				sig:fire(n)
			end,
		}
		write 'OK' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.6, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				ZIndex = 4, Parent = ok.gui,
			}, Scaled = true,
		}
		local cancel = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = grey,
			Size = UDim2.new(0.6, 0, 0.6, 0),
			Position = UDim2.new(-0.65, 0, 0.2, 0),
			ZIndex = 2, Parent = prompt.gui,
			MouseButton1Click = function()
				sig:fire()
			end,
		}
		write 'Cancel' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.6, 0),
				Position = UDim2.new(0.0, 0, 0.2, 0),
				ZIndex = 4, Parent = cancel.gui,
			}, Scaled = true,
		}
		local res = sig:wait()
		ok:remove()
		cancel:remove()
		entryRF:remove()
		prompt:remove()
		bg:remove()
		return res
	end

	function bag:tossSelectedItem()--::tossSelectedItem
		if self.busy then return end
		local item = self.selection
		if not item then return end
		self.busy = true
		local toss = self:selectQuantity(item.qty, self:getItemIcon(item.icon), 'Toss how many?')
		if toss then
			self:deselect()
			if _p.Network:get('PDS', 'tossItem', item.id, toss) then
				-- decrement cache
				item.qty = item.qty - toss
				if item.qty < 1 then
					local pouch = self.pouchCache[self.currentPouch]
					if pouch then
						for i = #pouch, 1, -1 do
							if pouch[i] == item then
								table.remove(pouch, i)
								break
							end
						end
					end
				end
				self:updateCurrentPouch()
			end
		end
		self.busy = false
	end

	function bag:selectItemBattle(item)
		local battle = _p.Battle.currentBattle
		if not battle or battle.kind == 'pvp' or battle.kind == '2v2' then return end
		self:deselect()
		self.selection = item
		self.backdrop.BattleContainer.Visible = false
		write(item.name) {
			Frame = self.battleSelectionName,
			Scaled = true,
		}
		local icon = self:getItemIcon(item.icon)
		icon.Size = UDim2.new(0.2, 0, 0.2, 0)
		icon.Position = UDim2.new(0.2875, 0, 0.25, 0)
		icon.Parent = self.backdrop.BattleDetailsContainer
		write('x'..item.qty) {
			Frame = self.battleSelectionQty,
			Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
		}
		if item.desc then
			write(item.desc) {
				Frame = self.btlDescContainer,
				Size = self.btlDescContainer.AbsoluteSize.Y/5.8,
				Wraps = true,
			}
		end
		self.backdrop.BattleDetailsContainer.Visible = true
	end

	function bag:useSelectedItemBattle()--::useSelectedItemBattle
		if not self.selection or not self.battleEvent then return end
		local target
		local item = self.selection
		local usableItem = usableItems[item.id]
		if item.bUse or usableItem then
			if item.bCat == 1 then
				if _p.Battle.currentBattle.kind ~= 'wild' then
					self.selection = nil
					_p.BattleGui:message('You can\'t catch another trainer\'s pokemon!')
					self.selection = item
					return
						--			elseif #_p.PlayerData.party >= 6 and not _p.PlayerData.pc:hasSpace() then -- OVH  recreate condition
						--				self.selection = nil
						--				_p.BattleGui:message('There is no room to store this pokemon if captured!')
						--				self.selection = item
						--				return
				end
			elseif usableItem then
				self.selection = nil
				local backdrop = self.backdrop
				spawn(function()
					local xs = backdrop.Position.X.Offset
					local xe = -backdrop.AbsoluteSize.X-50
					Utilities.Tween(.8, 'easeOutCubic', function(a)
						if not self.isOpen then return false end
						backdrop.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.0, 0)
					end)
				end)
				local sig = Utilities.Signal()
				_p.Menu.party.battleEvent = sig
				_p.Menu.party.alreadySwitched = nil
				_p.Menu.party.selectionText = nil
				_p.Menu.party.nActive = _p.BattleGui.side.nActive
				_p.Menu.party.forceSwitch = nil
				_p.Menu.party.chooseItemTarget = true
				_p.Menu.party:open()
				while true do
					local res = sig:wait()
					if res == 'cancel' then
						spawn(function() _p.Menu.party:close() end)
						local xs = backdrop.Position.X.Offset
						local xe = Utilities.gui.AbsoluteSize.X/2-backdrop.AbsoluteSize.X/2
						Utilities.Tween(.8, 'easeOutCubic', function(a)
							if not self.isOpen then return false end
							backdrop.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.0, 0)
						end)
						self.selection = item
						return
					elseif type(res) == 'number' then
						local pokemon = _p.Menu.party.partyData[res]
						if pokemon then
							if usableItem.canUse and (usableItem.canUse == true or usableItem.canUse(pokemon)) then
								_p.Menu.party.chooseItemTarget = nil
								backdrop.Position = UDim2.new(0.0, Utilities.gui.AbsoluteSize.X*1.2, 0.0, 0)
								self.isOpen = false
								backdrop.Visible = false
								self.state = 'closed'
								self:deselect()
								_p.Menu.party:close()
								target = res
								break
							else
								_p.BattleGui:message('It won\'t have any effect.')
							end
						end
					end
				end
			end
			self.battleEvent:fire('useitem ' .. item.id .. (target and ('|'..target) or ''))
		end
	end

	function bag:updateCurrentPouch()
		local p = self.currentPouch
		self.currentPouch = nil
		self:updateListForPouch(p)
	end

	function bag:updateListForPouch(n)--::updateListForPouch
		-- MROHERE

		removeTakeItemRF()
		if self.currentPouch == n then return end
		self.currentPouch = n

		self.pouchCache = self.pouchCache or {}
		fastSpawn(function()
			local pouch = self.pouchCache[n]
			if not pouch then
				local thisThread = {}
				self.listThread = thisThread
				pouch = _p.Network:get('PDS', 'getBagPouch', n, self.sellEvent and 'sell' or nil)
				if self.listThread ~= thisThread then return end
				self.pouchCache[n] = pouch
			end

			local scrollContainer = self.backdrop.NormalContainer.ScrollingContainer
			local container = scrollContainer.ItemsContainer
			container:ClearAllChildren() -- THERE IS PROBABLY A BETTER ALTERNATIVE WHEN JUST RELOADING THE SAME POUCH

			local contentRelativeSize = math.ceil(#pouch/3)*2/9*container.AbsoluteSize.X/scrollContainer.AbsoluteSize.Y
			scrollContainer.CanvasSize = UDim2.new(scrollContainer.Size.X.Scale, -1, contentRelativeSize * scrollContainer.Size.Y.Scale, 0)

			for i, item in pairs(pouch) do
				local gui; gui = create 'ImageButton' { -- 150x100
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://7449026973',
					Size = UDim2.new(1/3-.025, 0, 2/9-.025, 0),
					Position = UDim2.new((i-1)%3/3+.0125, 0, math.floor((i-1)/3)*2/9+.0125, 0),
					ZIndex = 3, Parent = container,
					MouseButton1Click = function()
						self:selectItem(item, gui, n)
					end,

					self:getItemIcon(item.icon),
				}
				write(item.name) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.2, 0),
						Position = UDim2.new(0.5, 0, 0.7, 0),
						ZIndex = 5, Parent = gui,
					}, Scaled = true,
				}

				if item.qty and not zMoveTable[item.icon] then
					write('x'..item.qty) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.2, 0),
							Position = UDim2.new(0.95, 0, 0.075, 0),
							ZIndex = 5, Parent = gui,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
					}
				end
			end
		end)
	end

	function bag:updateListForTMs()--::updateListForTMs
		fastSpawn(function()
			local tmData = self.tmCache
			if not tmData then
				local thisThread = {}
				self.listThread = thisThread
				tmData = _p.Network:get('PDS', 'getTMs')
				if self.listThread ~= thisThread then return end
				self.tmCache = tmData
			end

			local h = 0.175
			local scrollContainer = self.backdrop.NormalContainer.ScrollingContainer
			local container = scrollContainer.ItemsContainer
			local contentRelativeSize = #tmData*h*container.AbsoluteSize.X/scrollContainer.AbsoluteSize.Y
			scrollContainer.CanvasSize = UDim2.new(scrollContainer.Size.X.Scale, -1, contentRelativeSize * scrollContainer.Size.Y.Scale, 0)

			for i, tm in pairs(tmData) do
				tm.tm = true
				--			tm.bagCategory = 9?
				local gui; gui = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://7449026973',
					Size = UDim2.new(1.0, 1, h-.0125, 0),
					Position = UDim2.new(0.0, -1, (i-1)*h+.00625, 0),
					ZIndex = 3, Parent = container,
					MouseButton1Click = function()
						self:selectItem(tm, gui)
					end,
				}
				write((tm.hm and 'H' or 'T')..'M'..(tm.num<10 and '0' or '')..tm.num..' '..tm.mName) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.4, 0),
						Position = UDim2.new(0.2, 0, 0.3, 0),
						ZIndex = 4, Parent = gui,
					}, Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}
				local icon = self:getItemIcon({name = (tm.hm and 'HM' or 'TM')..tm.type})
				icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
				icon.Size = UDim2.new(1.0, 0, 1.0, 0)
				icon.Position = UDim2.new(0.02, 0, 0.02, 0)
				icon.Parent = gui
			end
		end)
	end

	function bag:updateListForBattle()
		local bags
		fastSpawn(function()
			local thisThread = {}
			self.listThread = thisThread
			bags = _p.Network:get('PDS', 'getBattleBag')
			if self.listThread ~= thisThread then return end

			local mContainer = self.backdrop.BattleContainer
			for i, scrollContainer in pairs({mContainer.BallsContainer, mContainer.RecoveryContainer, mContainer.BtlItemsContainer}) do
				local pouch = bags[i]
				local container = scrollContainer.ContentContainer
				container:ClearAllChildren()

				local contentRelativeSize = (math.floor((#pouch-1)/2)+1)*0.75*container.AbsoluteSize.Y/scrollContainer.AbsoluteSize.X
				scrollContainer.CanvasSize = UDim2.new(contentRelativeSize * scrollContainer.Size.X.Scale, 0, scrollContainer.Size.Y.Scale, -1)

				for i, item in pairs(pouch) do
					local gui = create 'ImageButton' { -- 150x100
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://7449026973',
						Size = UDim2.new(0.75-.025, 0, 0.5-.025, 0),
						Position = UDim2.new(math.floor((i-1)/2)*0.75+.0125, 0, (i-1)%2*0.5+.0125, 0),
						ZIndex = 3, Parent = container,
						MouseButton1Click = function()
							self:selectItemBattle(item)
						end,

						self:getItemIcon(item.icon),
					}
					write(item.name) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.225, 0),
							Position = UDim2.new(0.5, 0, 0.7, 0),
							ZIndex = 5, Parent = gui,
						}, Scaled = true,
					}
					write('x'..item.qty) {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.2, 0),
							Position = UDim2.new(0.95, 0, 0.075, 0),
							ZIndex = 5, Parent = gui,
						}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
					}
				end
			end
		end)
	end

	function bag:updateMoney()
		self.backdrop.MoneyContainer:ClearAllChildren()
		if not self.sellEvent then return end
		write('[$]'.._p.PlayerData:formatMoney()) {
			Frame = self.backdrop.MoneyContainer,
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
	end

	function bag:chooseItem()
		local sig = Utilities.Signal()
		self:open(nil, nil, sig)
		return sig:wait()
	end

	function bag:open(battleEvent, sellEvent, chooseEvent)
		if self.isOpen then return end
		self.isOpen = true

		self.battleEvent = battleEvent
		self.inBattle = battleEvent and true or false

		self.sellEvent = sellEvent

		self.chooseEvent = chooseEvent

		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		local backdrop = self.backdrop
		if not backdrop then
			local sbw = Utilities.gui.AbsoluteSize.Y*.035
			backdrop = create 'ImageLabel' {
				Name = 'BagBackdrop',
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://6809937124',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(1.0, 0, 1.0, 0),
				Position = UDim2.new(0.0, Utilities.gui.AbsoluteSize.X*1.2, 0.0, 0),
				ZIndex = 2,
				Parent = Utilities.gui,

				create 'Frame' {
					Name = 'MoneyContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.06, 0),
					Position = UDim2.new(1.05, 0, 0.1, 0),
					ZIndex = 3,
				},
				create 'Frame' {
					BackgroundTransparency = 1.0,
					Name = 'NormalContainer',
					Size = UDim2.new(1.0, 0, 1.0, 0),

					create 'Frame' {
						Name = 'PartyContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.45, 0, 0.6, 0),
						Position = UDim2.new(-0.1375, 0, 0.1625, 0),
					},

					create 'ScrollingFrame' {
						BackgroundTransparency = 1.0,
						BorderSizePixel = 0,
						Name = 'ScrollingContainer',
						Size = UDim2.new(0.6, 0, 0.625, 0),
						Position = UDim2.new(0.35, 0, 0.1375, 0),
						ScrollBarThickness = sbw,
						ZIndex = 3,

						create 'Frame' {
							BackgroundTransparency = 1.0,
							Name = 'ItemsContainer',
							Size = UDim2.new(1.0, -sbw, 1.0, -sbw),
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
						}
					}
				},

				create 'Frame' {
					BackgroundTransparency = 1.0,
					Name = 'BattleContainer',
					Size = UDim2.new(1.0, 0, 1.0, 0),

					create 'ScrollingFrame' {
						BackgroundTransparency = 1.0,
						BorderSizePixel = 0,
						Name = 'BallsContainer',
						Size = UDim2.new(0.9, 0, 0.225, 0),
						Position = UDim2.new(0.05, 0, 0.25/3, 0),
						ScrollBarThickness = sbw,
						ZIndex = 3,

						create 'Frame' {
							BackgroundTransparency = 1.0,
							Name = 'ContentContainer',
							Size = UDim2.new(1.0, -sbw, 1.0, -sbw),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
						}
					},
					create 'ScrollingFrame' {
						BackgroundTransparency = 1.0,
						BorderSizePixel = 0,
						Name = 'RecoveryContainer',
						Size = UDim2.new(0.9, 0, 0.225, 0),
						Position = UDim2.new(0.05, 0, 0.25*5/3, 0),
						ScrollBarThickness = sbw,
						ZIndex = 3,

						create 'Frame' {
							BackgroundTransparency = 1.0,
							Name = 'ContentContainer',
							Size = UDim2.new(1.0, -sbw, 1.0, -sbw),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
						}
					},
					create 'ScrollingFrame' {
						BackgroundTransparency = 1.0,
						BorderSizePixel = 0,
						Name = 'BtlItemsContainer',
						Size = UDim2.new(0.9, 0, 0.225, 0),
						Position = UDim2.new(0.05, 0, 0.75, 0),
						ScrollBarThickness = sbw,
						ZIndex = 3,

						create 'Frame' {
							BackgroundTransparency = 1.0,
							Name = 'ContentContainer',
							Size = UDim2.new(1.0, -sbw, 1.0, -sbw),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
						}
					},
				},

				create 'Frame' {
					BackgroundTransparency = 1.0,
					Name = 'BattleDetailsContainer',
					Size = UDim2.new(1.0, 0, 1.0, 0),
				}
			}
			buttons = {}
			for i, c in pairs({'Items','Medicine','Poke Balls','TMs/HMs','Berries','Key Items', 'Z-Crystals'}) do
				local button = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.new(.4, .4, .4),
					Size = UDim2.new(1/4-.025, 0, 0.05, 0),
					Position = UDim2.new(i ~= 7 and (i-1)%3/4+.0125 or i == 7 and 0.7625, 0, i<=3 and 0.0125 or 0.075, 0),--UDim2.new((i-1)%3/4+.0125, 0, i<=3 and 0.0125 or 0.075, 0),
					ZIndex = 3, Parent = backdrop.NormalContainer,
					MouseButton1Click = function()
						if self.busy then return end
						self:deselect()
						if i == 4 then
							-- tms
							self.currentPouch = nil
							backdrop.NormalContainer.ScrollingContainer.ItemsContainer:ClearAllChildren()
							self:updateListForTMs()
						elseif i > 4 then
							self:updateListForPouch(i-1)
							self:updatePartyList(i-1)
						else
							self:updateListForPouch(i)
							self:updatePartyList(i)
						end
					end,
				}
				if i == 7 and not zpouchalreadyenable then -- zmove
					button.Visible = false
				end
				write(c) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 0.7, 0),
						Position = UDim2.new(0.0, 0, 0.15, 0),
						ZIndex = 4, Parent = button.gui,
					}, Scaled = true,
				}
				table.insert(buttons, button)
			end
			local cancel = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.9, .625, 0),
				Size = UDim2.new(1/4-.025, 0, 0.05, 0),
				Position = UDim2.new(3/4+.0125, 0, 0.0125, 0),
				ZIndex = 3, Parent = backdrop,
				MouseButton1Click = function()
					if self.battleEvent then
						self.battleEvent:fire('cancel')
					end
					self:close()
				end,
			}
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 4, Parent = cancel.gui,
				}, Scaled = true,
			}
			local wr = function(prop)
				if prop ~= 'AbsoluteSize' then return end
				local cr = backdrop.AbsoluteSize.Y*.01
				cancel.CornerRadius = cr
				for _, b in pairs(buttons) do
					b.CornerRadius = cr
				end
			end
			backdrop.Changed:connect(wr)
			wr('AbsoluteSize')

			local options = _p.RoundedFrame:new {
				BackgroundColor3 = Color3.new(.9, .625, 0),
				Size = UDim2.new(0.25, 0, 0.2125, 0),
				Position = UDim2.new(0.0125, 0, 0.775, 0),
				ZIndex = 3, Parent = backdrop.NormalContainer,
			}
			self.selectionSell = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.9, 0, 0.25, 0),
				Position = UDim2.new(0.05, 0, 0.075, 0),
				ZIndex = 4, Parent = options.gui, Visible = false,
				MouseButton1Click = function()
					removeTakeItemRF()
					self:sellSelectedItem()
				end,
			}
			self.selectionChoose = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.9, 0, 0.25, 0),
				Position = UDim2.new(0.05, 0, 0.075, 0),
				ZIndex = 4, Parent = options.gui, Visible = false,
				MouseButton1Click = function()
					removeTakeItemRF()
					self:chooseSelectedItem()
				end,
			}
			self.selectionUse = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.9, 0, 0.25, 0),
				Position = UDim2.new(0.05, 0, 0.075, 0),
				ZIndex = 4, Parent = options.gui, Visible = false,
				MouseButton1Click = function()
					removeTakeItemRF()
					warn(self.currentPouch)
					if self.currentPouch == 6 then 
						self:giveZCrystal()
					else
						self:useSelectedItem()
					end
				end,
			}
			self.selectionGive = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.9, 0, 0.25, 0),
				Position = UDim2.new(0.05, 0, 0.375, 0),
				ZIndex = 4, Parent = options.gui, Visible = false,
				MouseButton1Click = function()
					removeTakeItemRF()
					self:giveSelectedItem()
				end,
			}
			self.selectionRegister = _p.RoundedFrame:new {
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.9, 0, 0.25, 0),
				Position = UDim2.new(0.05, 0, 0.375, 0),
				ZIndex = 4, Parent = options.gui, Visible = false,
			}
			self.selectionToss = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.9, 0, 0.25, 0),
				Position = UDim2.new(0.05, 0, 0.675, 0),
				ZIndex = 4, Parent = options.gui, Visible = false,
				MouseButton1Click = function()
					removeTakeItemRF()
					self:tossSelectedItem()
				end,
			}
			write 'Sell' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = self.selectionSell.gui,
				}, Scaled = true,
			}
			write 'Choose' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = self.selectionChoose.gui,
				}, Scaled = true,
			}
			write 'Use' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = self.selectionUse.gui,
				}, Scaled = true,
			}
			write 'Give' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = self.selectionGive.gui,
				}, Scaled = true,
			}
			write 'Register' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = self.selectionRegister.gui,
				}, Scaled = true,
			}
			write 'Toss' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = self.selectionToss.gui,
				}, Scaled = true,
			}
			local desc = _p.RoundedFrame:new {
				BackgroundColor3 = Color3.new(.3, .3, .3),
				Size = UDim2.new(0.7125, 0, 0.2125, 0),
				Position = UDim2.new(0.275, 0, 0.775, 0),
				ZIndex = 3, Parent = backdrop.NormalContainer,
			}
			self.descContainer = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.95, 0, 0.85, 0),
				Position = UDim2.new(0.025, 0, 0.075, 0),
				ZIndex = 4, Parent = desc.gui,
			}

			write 'Poke Balls' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.25/3-.025, 0),
					Position = UDim2.new(0.1, 0, 0.0125, 0),
					ZIndex = 3, Parent = backdrop.BattleContainer,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write 'Healing Items' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.25/3-.025, 0),
					Position = UDim2.new(0.1, 0, 0.25*4/3+0.0125, 0),
					ZIndex = 3, Parent = backdrop.BattleContainer,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}
			write 'Battle Items' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.25/3-.025, 0),
					Position = UDim2.new(0.1, 0, 0.25*8/3+0.0125, 0),
					ZIndex = 3, Parent = backdrop.BattleContainer,
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
			}

			self.battleSelectionName = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.08, 0),
				Position = UDim2.new(0.5, 0, 0.15, 0),
				ZIndex = 4, Parent = backdrop.BattleDetailsContainer,
			}
			self.battleSelectionQty = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.05, 0),
				Position = UDim2.new(0.5125, 0, 0.325, 0),
				ZIndex = 4, Parent = backdrop.BattleDetailsContainer,
			}
			_p.RoundedFrame:new {
				BackgroundColor3 = Color3.new(.9, .625, 0),
				Size = UDim2.new(0.8, 0, 0.8, 0),
				Position = UDim2.new(0.1, 0, 0.1, 0),
				ZIndex = 3, Parent = backdrop.BattleDetailsContainer,
			}
			local btlDesc = _p.RoundedFrame:new {
				BackgroundColor3 = Color3.new(.3, .3, .3),
				Size = UDim2.new(0.7, 0, 0.2125, 0),
				Position = UDim2.new(0.15, 0, 0.5, 0),
				ZIndex = 4, Parent = backdrop.BattleDetailsContainer,
			}
			self.btlDescContainer = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.95, 0, 0.85, 0),
				Position = UDim2.new(0.025, 0, 0.075, 0),
				ZIndex = 5, Parent = btlDesc.gui,
			}
			local useButtonBattle = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(0.425, 0, 0.075, 0),
				Position = UDim2.new(0.15, 0, 0.75, 0),
				ZIndex = 4, Parent = backdrop.BattleDetailsContainer,
				MouseButton1Click = function()
					self:useSelectedItemBattle()
				end,
			}
			write 'Use' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = useButtonBattle.gui,
				}, Scaled = true,
			}
			local cancelButtonBattle = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(.4, .4, .4),
				Size = UDim2.new(-0.25, 0, 0.075, 0),
				Position = UDim2.new(0.85, 0, 0.75, 0),
				ZIndex = 4, Parent = backdrop.BattleDetailsContainer,
				MouseButton1Click = function()
					backdrop.BattleDetailsContainer.Visible = false
					backdrop.BattleContainer.Visible = true
				end,
			}
			write 'Cancel' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = cancelButtonBattle.gui,
				}, Scaled = true,
			}

			self.backdrop = backdrop
		end
		self:updateMoney()
		backdrop.NormalContainer.Visible = not self.inBattle
		backdrop.BattleContainer.Visible = self.inBattle
		backdrop.BattleDetailsContainer.Visible = false
		if not self.inBattle then
			local pouch = self.currentPouch or 1
			self.currentPouch = nil

			self:updateListForPouch(pouch)
			self:updatePartyList(pouch)
		else
			self:updateListForBattle()
		end
		backdrop.Visible = true
		local fader = Utilities.fadeGui
		fader.ZIndex = 1
		fader.BackgroundColor3 = Color3.new(0, 0, 0)
		local xs = backdrop.Position.X.Offset
		local xe = Utilities.gui.AbsoluteSize.X/2-backdrop.AbsoluteSize.X/2
		self.state = 'transition'
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if not self.isOpen then return false end
			backdrop.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.0, 0)
			fader.BackgroundTransparency = 1.0-a*0.7
		end)
		if self.isOpen then
			self.state = 'open'
		end
	end

	function bag:close()--::close
		if not self.isOpen then return end
		self.isOpen = false

		_p.DataManager:dumpCache('TMs')

		if self.sellEvent then
			self.sellEvent:fire()
		elseif self.chooseEvent then
			self.chooseEvent:fire()
		elseif not self.inBattle then
			_p.MasterControl.WalkEnabled = true
			spawn(function() _p.Menu:enable() end)
		end

		local backdrop = self.backdrop
		local fader = Utilities.fadeGui
		local xs = backdrop.Position.X.Offset
		local xe = Utilities.gui.AbsoluteSize.X*1.2
		self.state = 'transition'
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			if self.isOpen then return false end
			backdrop.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.0, 0)
			fader.BackgroundTransparency = 0.3+a*0.7
		end)
		if not self.isOpen then
			self.listThread  = nil
			self.partyThread = nil
			self.partyData   = nil
			self.pouchCache  = nil
			self.tmCache     = nil

			backdrop.Visible = false
			self.state = 'closed'
			self:deselect()
		end
	end

	function bag:enablezmovepouch()
		spawn(function() 
			repeat wait() until self.isOpen
			for i,v in pairs(buttons) do
				if i == 7 then
					v.Visible = true
					zpouchalreadyenable = true
				end
			end
		end)
	end

	return bag end