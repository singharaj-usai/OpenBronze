return function(_p)
	local Utilities = _p.Utilities
	local Tween = Utilities.Tween
	local shop = {}
	local chat = _p.NPCChat
	local theme = Color3.fromRGB(171, 149, 230)
	local gui = nil
	local create = Utilities.Create
	local write = Utilities.Write
	local saying
	local selection
	local update

	function shop:buySelection()
		if saying or not selection then return end
		local item = selection.item
		saying = true
		local max = _p.Network:get('PDS', 'tMaxBuy', selection.index)
		if type(max) == 'string' and max:sub(1,2) == 'pk' then
			local split = string.split(max, '-')
			max = tonumber(split[2])
		end
		if max == 'ao' then
			chat:say('You already own this TM.')
			wait() wait()
			saying = false
			return
		elseif max == 'fb' then
			chat:say('You don\'t have any more room in your bag for this item.')
			wait() wait()
			saying = false
			return
		elseif max == 'nm' then
			chat:say('You don\'t have enough Tix.')
			wait() wait()
			saying = false
			return
		elseif max == 'aoh' then
			if chat:say('[y/n]Would you like to equip it?') then
				_p.Network:get('PDS', 'setHoverboard', item.name)
			end
			wait() wait()
			saying = false
			return
		end
		local qty
		if max == 'hb' then
			qty = 1
		elseif max == 'tm' then
			qty = 1
		else
			qty = _p.Menu.bag:selectQuantity(max, selection.icon:Clone(), 'How many would you like?', '%d Tix', selection.price)
		end
		if not qty or not chat:say('[y/n]You want '..(max=='tm' and 'a' or qty)..' '..(item.tm and ('TM'..item.num) or item.name)..(qty>1 and 's' or '')..'. That will be '..(_p.PlayerData:formatTix(qty*selection.price))..' Tix. Is that OK?') then
			saying = false
			return
		end
		local s, newbp = _p.Network:get('PDS', 'buyWithTix', selection.index, max~='tm' and qty or nil)
		if not s then
			chat:say('An error occurred.')
			saying = false
			return
		end
		if newbp then
			_p.PlayerData.tix = newbp
		end

		chat:say('Here you go. Thank you.')
		if max == 'hb' and chat:say('[y/n]Would you like to equip it now?') then
			_p.Network:get('PDS', 'setHoverboard', item.name)
		end
		wait() wait()
		self:buildList()
		saying = false
	end

	function shop:buildList()
		local arcade = _p.Network:get("PDS", "getShop", "arcade")
		local scroller = gui.Scroller
		local container = scroller.ContentContainer
		container:ClearAllChildren()
		scroller.CanvasSize = UDim2.new(scroller.Size.X.Scale, -1, (#arcade + 1) * 0.06 * container.AbsoluteSize.X / scroller.AbsoluteSize.Y * scroller.Size.Y.Scale, 0)
		selection = nil

		for y, thing in pairs(arcade) do
			local area = create("ImageButton")({
				AutoButtonColor = false, 
				BackgroundColor3 = Color3.fromRGB(170, 149, 229),
				BackgroundTransparency = y % 2, -- i%2==0 and 0.0 or 1.0,
				BorderSizePixel = 0,
				Size = UDim2.new(0.80*1.2, 0, 0.06, 0),
				Position = UDim2.new(0.025, 0, 0.06 * (y - 1), 0),
				ZIndex = 10,
				Parent = container,
			})
			
			Utilities.fastSpawn(function()
				local tm
				local item, move, pknm, hover
				if thing[1]:sub(1, 2) == 'TM' then
					local moveName
					tm, moveName = thing[1]:match('^TM(%d+)%s(.+)$')
					move = _p.DataManager:getData('Movedex', Utilities.toId(moveName))
					if not move then print(moveName) end
				elseif thing[1]:sub(1, 4) == 'PKMN' then
					local mon = string.split(thing[1], ' ')[2]
					pknm = true
					if mon == 'Ditto' then
						item = {
							name = mon,
							desc = 'A unique Pokemon with the ability to reconstitute its cellular structure to transform into whatever it sees.',
							iconnumber = 140
						}
					elseif mon == 'Audino' then
						item = {
							name = mon,
							desc = 'A Pokemon that uses the feelers on its ears to sense others\' feelings.',
							iconnumber = 608
						}
					elseif mon == 'Chansey' then
						item = {
							name = mon,
							desc = 'A Pokemon that delivers happiness.',
							iconnumber = 118
						}
					end
				elseif thing[1]:sub(1, 5) == 'HOVER' then
					local hb = thing[1]:sub(7,#thing[1])
					hover = true
					if hb == 'Mega Salamence Board' then
						item = {
							name = hb,
							desc = 'A hoverboard that resembles Mega Salamence. It flies at the same speed as the deluxe boards from Hero\'s Hoverboards.',
						}
					elseif hb == 'Shiny M.Salamence Board' then
						item = {
							name = hb,
							desc = 'A hoverboard the exhibits extreme skill and dedication. To unlock this board, you had to achieve a score of 50 on the Alolan Adventure game.',
						}
					end
				else
					item = _p.DataManager:getData('Items', thing[1])
				end

				if not area.Parent then return end
				local text = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.95, 0, 0.7, 0),
					Position = UDim2.new(0.025, 0, 0.15, 0),
					ZIndex = 11, Parent = area,
				}
				write((tm and thing[1]) or item.name) { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }
				write(_p.PlayerData:formatTix(thing[2])..(' Tix')) { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right }
				area.MouseButton1Click:connect(function()
					if saying then return end
					local descContainer = gui.Details.DescContainer
					descContainer:ClearAllChildren()
					if tm then
						write(move.category..', '..move.type..'-type, '..(move.basePower or 0)..' Power,\n'..(move.accuracy==true and '--' or ((move.accuracy or 0)..'%'))..' Accuracy'..((move.desc and move.desc~='') and ('. Effect: '..move.desc) or '')) {
							Frame = descContainer, Size = descContainer.AbsoluteSize.Y/5.8, Wraps = true
						}
					elseif item.desc then
						write(item.desc) { Frame = descContainer, Size = descContainer.AbsoluteSize.Y/5.8, Wraps = true }
					end
					gui.Details.IconContainer:ClearAllChildren()
					if tm then
						item = {
							name = 'TM'..move.type,
							tm = true,
							num = tonumber(tm),
							--							encryptedId = encryptedId,
						}
					end

					local icon
					if pknm then
						icon = _p.Pokemon:getIcon(item.iconnumber, false)
					elseif not hover then
						icon = _p.Menu.bag:getItemIcon(item)
					end
					if not hover then
						icon.SizeConstraint = Enum.SizeConstraint.RelativeXY
						icon.Size = UDim2.new(1.0, 0, 1.0, 0)
						icon.Parent = gui.Details.IconContainer
					end
					selection = {item = item, price = thing[2], icon = icon, index = y}--, encryptedId = encryptedId}
					-- Handle Changing Text for Hover
					if hover and _p.Network:get('PDS', 'ownsHoverboard', item.name) then
						pcall(function() gui.Details.BuyButton.BuyText:Destroy() end)
						write("Equip")({
							Frame = create("Frame")({
								BackgroundTransparency = 1, 
								Size = UDim2.new(1, 0, 0.6, 0), 
								Position = UDim2.new(0, 0, 0.2, 0),
								Name = 'BuyText',
								ZIndex = 5, 
								Parent = gui.Details.BuyButton
							}), 
							Scaled = true
						})
					else
						pcall(function() gui.Details.BuyButton.BuyText:Destroy() end)
						write("Buy")({
							Frame = create("Frame")({
								BackgroundTransparency = 1, 
								Size = UDim2.new(1, 0, 0.6, 0), 
								Position = UDim2.new(0, 0, 0.2, 0),
								Name = 'BuyText',
								ZIndex = 5, 
								Parent = gui.Details.BuyButton
							}), 
							Scaled = true
						})
					end
					gui.Details.BuyButton.Visible = true
				end)
			end)
		end
	end
	local sig = nil
	local Color1 = Color3.fromRGB(226, 136, 217)
	local Color2 = Color3.fromRGB(95, 156, 227)
	local ColorThree = Color3.fromRGB(70, 122, 184)

	function shop:loadShop()
		local fade = Utilities.fadeGui
		if not gui then
			local pos = Utilities.gui.AbsoluteSize.Y * 0.035
			sig = Utilities.Signal()
			local acgui = {
				Name = "ArcadeShopGUI", 
				BackgroundColor3 = Color1, 
				SizeConstraint = Enum.SizeConstraint.RelativeYY, 
				Size = UDim2.new(1.2, 0, 0.9, 0), 
				Position = UDim2.new(0, Utilities.gui.AbsoluteSize.X *1.2, 0.05, 0), 
				Parent = Utilities.gui, 
				ZIndex = 2
			}
			local details = {
				Name = "Details", 
				BackgroundColor3 = Color2, 
				Size = UDim2.new(1.05, 0, 0.2, 0), 
				Position = UDim2.new(-0.025, 0, 0.775, 0), 
				ZIndex = 3
			}
			local buybutton = {
				Name = "BuyButton", 
				Button = true, 
				BackgroundColor3 = ColorThree,
				Size = UDim2.new(0.2, 0, 0.425, 0), 
				Position = UDim2.new(0.0125, 0, 0.5, 0), 
				ZIndex = 4, 
				Visible = false
			}
			function buybutton.MouseButton1Click()
				self:buySelection()
			end
			details[1] = create("Frame")({
				Name = "DescContainer", 
				BackgroundTransparency = 1, 
				Size = UDim2.new(0.75, 0, 0.85, 0), 
				Position = UDim2.new(0.225, 0, 0.075, 0), 
				ZIndex = 4
			})
			details[2] = create("Frame")({
				Name = "IconContainer", 
				BackgroundTransparency = 1, 
				SizeConstraint = Enum.SizeConstraint.RelativeYY, 
				Size = UDim2.new(0.5, 0, 0.5, 0), 
				Position = UDim2.new(0.06, 0, 0, 0)
			})
			details[3] = _p.RoundedFrame:new(buybutton)
			acgui[1] = _p.RoundedFrame:new({
				Name = "TitleBar", 
				BackgroundColor3 = Color2, 
				Size = UDim2.new(1.05, 0, 0.1, 0), 
				Position = UDim2.new(-0.025, 0, 0.025, 0), 
				ZIndex = 3,
				create("Frame")({
					Name = "TextContainer", 
					BackgroundTransparency = 1, 
					Size = UDim2.new(0.95, 0, 0.7, 0), 
					Position = UDim2.new(0.025, 0, 0.15, 0), 
					ZIndex = 4
				})
			})
			acgui[2] = create("ScrollingFrame")({
				Name = "Scroller", 
				BackgroundTransparency = 1, 
				BorderSizePixel = 0, 
				Size = UDim2.new(0.80*1.2, 0, 0.6, 0), 
				Position = UDim2.new(0.025, 0, 0.15, 0), 
				ScrollBarThickness = pos, 
				ZIndex = 3,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				
				create("Frame")({
					BackgroundTransparency = 1, 
					Name = "ContentContainer", 
					Size = UDim2.new(1, -pos, 1, -pos), 
					SizeConstraint = Enum.SizeConstraint.RelativeXX
				})
			})
			acgui[3] = _p.RoundedFrame:new(details)
			gui = _p.RoundedFrame:new(acgui).gui
			write("Tix Shop")({
				Frame = gui.TitleBar.TextContainer, 
				Scaled = true, 
				TextXAlignment = Enum.TextXAlignment.Left
			})
			write("Buy")({
				Frame = create("Frame")({
					BackgroundTransparency = 1, 
					Size = UDim2.new(1, 0, 0.6, 0), 
					Position = UDim2.new(0, 0, 0.2, 0),
					Name = 'BuyText',
					ZIndex = 5, 
					Parent = gui.Details.BuyButton
				}), 
				Scaled = true
			})
			local title = {
				Button = true, 
				BackgroundColor3 = ColorThree, 
				Size = UDim2.new(0.3, 0, 0.8, 0), 
				Position = UDim2.new(0.69, 0, 0.1, 0), 
				ZIndex = 4, 
				Parent = gui.TitleBar
			}
			local offswitch = "off"
			function title.MouseButton1Click()
				if offswitch == "transition" then
					return
				end
				offswitch = "transition"
				delay(0.3, function()
					sig:fire()
				end)
				local offset = gui.Position.X.Offset
				local pos2 = Utilities.gui.AbsoluteSize.X *1.2
				Utilities.Tween(0.8, "easeOutCubic", function(tvalue)
					gui.Position = UDim2.new(0, offset + (pos2 - offset) * tvalue, 0.05, 0)
					fade.BackgroundTransparency = 0.3 + tvalue * 0.7
				end)
				fade.BackgroundTransparency = 1
				offswitch = "off"
			end
			write("Close")({
				Frame = create("Frame")({
					BackgroundTransparency = 1, 
					Size = UDim2.new(1, 0, 0.7, 0), 
					Position = UDim2.new(0, 0, 0.15, 0), 
					ZIndex = 5, 
					Parent = _p.RoundedFrame:new(title).gui
				}), 
				Scaled = true
			})
		end
		self:buildList()
		gui.Details.BuyButton.Visible = false
		fade.ZIndex = 1
		fade.BackgroundColor3 = Color3.new(0, 0, 0)
		local l__Offset__12 = gui.Position.X.Offset
		local u13 = Utilities.gui.AbsoluteSize.X / 2 - gui.AbsoluteSize.X / 2
		Utilities.Tween(0.8, "easeOutCubic", function(p5)
			gui.Position = UDim2.new(0, l__Offset__12 + (u13 - l__Offset__12) * p5, 0.05, 0)
			fade.BackgroundTransparency = 1 - p5 * 0.7
		end)
		sig:wait()
	end
	local games = {
		["Alolan Adventure"] = require(script.AlolanAdventure)(_p), 
		["Whack-A-Diglett"] = require(script.WhackADiglett)(_p), 
		["Hammer Arm"] = require(script.HammerArm)(_p), 
		["Skeeball"] = require(script.Skeeball)(_p)
	}
	function shop:play(name, machine)
		if self.busy then
			return false
		end
		self.busy = true
		_p.Menu:disable()
		_p.MasterControl:Stop()
		_p.MasterControl.WalkEnabled = false
		if name:sub(1, 5) == "Whack" then
			local whackgame = {}
			local nextarea = next
			local ze, twed = _p.player.Character:GetDescendants()
			while true do
				local y, x = nextarea(ze, twed)
				if not y then
					break
				end
				twed = y
				pcall(function()
					whackgame[x] = x.Transparency
				end)
				pcall(function()
					x.Transparency = 1
				end)			
			end
			games["Whack-A-Diglett"]:start(machine)
			self.busy = false
			_p.Menu:enable()
			_p.MasterControl.WalkEnabled = true
			local nextup2 = next
			local chr, v = _p.player.Character:GetDescendants()
			while true do
				local s, t = nextup2(chr, v)
				if not s then
					break
				end
				v = s
				pcall(function()
					t.Transparency = whackgame[t]
				end)			
			end
		end
		if name:sub(1, 5) == "Smonk" then
			local smonkgame = {}
			local nextarea2 = next
			local s, d = _p.player.Character:GetDescendants()
			while true do
				local f, r = nextarea2(s, d)
				if not f then
					break
				end
				d = f
				pcall(function()
					smonkgame[r] = r.Transparency
				end)
				pcall(function()
					r.Transparency = 1
				end)			
			end
			games["Hammer Arm"]:start(machine)
			self.busy = false
			_p.Menu:enable()
			_p.MasterControl.WalkEnabled = true
			local followup2 = next
			local v42, v43 = _p.player.Character:GetDescendants()
			while true do
				local v44, v45 = followup2(v42, v43)
				if not v44 then
					break
				end
				v43 = v44
				pcall(function()
					v45.Transparency = smonkgame[v45]
				end)			
			end
		end

		if name:sub(1, 4) == "Skee" then
			local skeetable = {}
			local followup = next
			local c, t = _p.player.Character:GetDescendants()
			while true do
				local d, v = followup(c, t)
				if not d then
					break
				end
				t = d
				pcall(function()
					skeetable[v] = v.Transparency
				end)
				pcall(function()
					v.Transparency = 1
				end)			
			end
			games.Skeeball:start(machine)
			games.Skeeball.GameEnded:wait()
			self.busy = false
			_p.Menu:enable()
			_p.MasterControl.WalkEnabled = true
			local nextup = next
			local r, char = _p.player.Character:GetDescendants()
			while true do
				local find, mil = nextup(r, char)
				if not find then
					break
				end
				char = find
				pcall(function()
					mil.Transparency = skeetable[mil]
				end)			
			end
		end
		if name:sub(1, 6) == 'Flappy' then 
			local oldTransparencies = {}
			for i, v in next, _p.player.Character:GetDescendants() do 
				pcall(function() oldTransparencies[v] = v.Transparency end)
				pcall(function() v.Transparency = 1 end) 
			end
			spawn(function()
				games['Alolan Adventure']:start(machine)
			end)
			self.flappyConnection = _p.player:GetMouse().KeyDown:Connect(function(key)
				if key:byte() == 32 then 
					games['Alolan Adventure']:onSpaceClicked()
				end
			end)
			games['Alolan Adventure'].GameEnded:wait()
			self.flappyConnection = false 
			self.busy = false 
			for i, v in next, _p.player.Character:GetDescendants() do 
				pcall(function() v.Transparency = oldTransparencies[v] end) 
			end
		end
	end
	local interact = chat.interactableNPCs
	local tixgui = Utilities.gui
	local chunktab = {}
	function shop:onLoadChunk(chunk)
		update = true
		_p.DataManager.ignoreRegionChangeFlag = true
		interact[chunk.npcs.TicketGuy.model] = function()
			chat:say(chunk.npcs.TicketGuy, "Interested in exchanging your Tix for awesome prizes?")
			spawn(function() _p.Menu:disable() end)
			self:loadShop()
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			chat:say(chunk.npcs.TicketGuy, "Come back any time!")
			_p.MasterControl.WalkEnabled = true
			_p.MasterControl:Stop()
			spawn(function() _p.Menu:enable() end)
		end
		interact[chunk.npcs.TicketSeller.model] = function()
			if chat:say(chunk.npcs.TicketSeller, "Want lots of Tix, but don't have time?", "I'll give you 5,000 of my Tix for 100 of your R$.", "[y/n]Does that sound like a fair deal?") then
				_p.Network:post('PDS', 'TixPurchase')
			else
				chat:say(chunk.npcs.TicketSeller, "Well, good luck then.")
			end
		end
		local image = create("ImageLabel")({
			Rotation = -30, 
			Size = UDim2.new(0.068, 0, 0.088, 0), 
			Position = UDim2.new(0.089, 0, 0.809, 0), 
			Image = "rbxassetid://13044839149",
			BackgroundTransparency = 1, 
			Name = "TixImage", 
			Parent = tixgui
		})
		local lasttix = _p.PlayerData.tix
		write(tostring(_p.PlayerData.tix))({
			Frame = create("Frame")({
				Parent = tixgui, 
				Name = "TixFrame", 
				BackgroundTransparency = 1, 
				Size = UDim2.new(0.267, 0, 0.072, 0), 
				Position = UDim2.new(0.2, 0, 0.817, 0)
			}), 
			Scaled = true, 
			TextXAlignment = Enum.TextXAlignment.Left
		})
		spawn(function()
			while update do
				wait()
				if lasttix ~= _p.PlayerData.tix then
					lasttix = _p.PlayerData.tix
					pcall(function()
						tixgui.TixFrame:Destroy()
					end)
					write(tostring(_p.PlayerData.tix))({
						Frame = create("Frame")({
							Parent = tixgui, 
							Name = "TixFrame", 
							BackgroundTransparency = 1, 
							Size = UDim2.new(0.267, 0, 0.072, 0), 
							Position = UDim2.new(0.2, 0, 0.817, 0)
						}), 
						Scaled = true, 
						TextXAlignment = Enum.TextXAlignment.Left
					})
				end
			end
		end)
		local playnext = next
		local i, v = chunk.map:GetDescendants()
		while true do
			local s, d = playnext(i, v)
			if not s then
				break
			end
			v = s
			if d.Name == "PlayButtonNode" then
				local rf
				local ui2 = {
					BackgroundColor3 = Color3.fromRGB(74, 164, 98), 
					Size = UDim2.new(0.135, 0, .073, 0), 
					Parent = Utilities.gui, 
					ZIndex = 3, 
					Visible = false, 
					Button = true
				}
				function ui2.MouseButton1Click()
					rf.Visible = false
					self:play(d.Parent.Name, d.Parent)
				end
				rf = _p.RoundedFrame:new(ui2)
				chunktab[d] = rf
				write("Play")({
					Scaled = true, 
					Font = 'Avenir'	,
					Frame = create("Frame")({
						Parent = rf.gui, 
						ZIndex = 3, 
						BackgroundTransparency = 1, 
						Position = UDim2.new(0, 0, .2, 0), 
						Size = UDim2.new(1, 0,.6, 0)
					})
				})
			end		
		end
		local camera = workspace.CurrentCamera
		spawn(function()
			while wait() do
				for i, v in next, chunktab do
					if ((i.CFrame.p - _p.player.Character.HumanoidRootPart.CFrame.p) * Vector3.new(1, 0, 1)).magnitude <= 7 and not self.busy then
						local s, d = camera:WorldToScreenPoint(i.Position)
						v.Position = UDim2.new(0, s.x, 0, s.y)
						v.Visible = true
					else
						v.Visible = false
					end
				end			
			end
		end)
	end
	function shop:onUnload(chunk)
		update = false
		pcall(function()
			tixgui.TixFrame:Destroy()
			tixgui.TixImage:Destroy()
		end)
		_p.DataManager.ignoreRegionChangeFlag = false
	end
	return shop
end
