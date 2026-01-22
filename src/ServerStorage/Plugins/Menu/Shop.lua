return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
local Utilities = _p.Utilities
local rc4 = Utilities.rc4
local create = Utilities.Create
local write = Utilities.Write

local shop = {
--	moneyUpdateCallbacks = {}
}

function shop:updateMoney(gui)
	gui.MoneyContainer:ClearAllChildren()
	write('[$]'.._p.PlayerData:formatMoney()) {
		Frame = gui.MoneyContainer,
		Scaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}
end

local saying
local state = 'off'

do
	local selection
	function shop:buySelection()
		if saying or not selection then return end
		local item = selection.item
		local itemId = selection.encryptedId
		if selection.robux then
			_p.MarketClient:promptProductPurchase(_p.productId[selection.arg3])
		else
			saying = true
			local max = _p.Network:get('PDS', 'maxBuy', itemId)
			if max == 'fb' then -- full bag
				_p.NPCChat:say('You don\'t have any more room in your bag for this item.')
				wait() wait()
				saying = false
				return
			end
			if max == 'nm' then -- not enough money
				_p.NPCChat:say('You don\'t have enough money.')
				wait() wait()
				saying = false
				return
			end
			local qty = _p.Menu.bag:selectQuantity(max, selection.icon:Clone(), 'How many would you like?', '[$]%d', selection.price)
			if not qty or not _p.NPCChat:say('[y/n]You want '..qty..' '..item.name..(qty>1 and 's' or '')..'. That will be [$]'.._p.PlayerData:formatMoney(qty*selection.price)..'. Is that OK?') then
				saying = false
				return
			end
			local s, pb = _p.Network:get('PDS', 'buyItem', itemId, qty)
			if not s then
				_p.NPCChat:say('An error occurred.')
				saying = false
				return
			end
			_p.NPCChat:say('Here you go. Thank you.')
			if pb then -- premier ball obtained
				_p.NPCChat:say('You also get a Premier Ball as an added bonus.')
			end
			wait() wait()
			saying = false
		end
	end
	
	function shop:buildList(gui, shopId)
		selection = nil
		gui.Details.BuyButton.Visible = false
		self:updateMoney(gui) -- 
		
		Utilities.fastSpawn(function()
			local items = _p.Network:get('PDS', 'getShop', shopId) -- TODO: return the items' icon, desc, etc. with this data
			
			if state == 'transitionoff' or state == 'off' then print('closed state:', state) return end
			
			local s = 0.08
			local scrollContainer = gui.Scroller
			local container = scrollContainer.ContentContainer
			container:ClearAllChildren()
			local contentRelativeSize = (#items+1)*s*container.AbsoluteSize.X/scrollContainer.AbsoluteSize.Y
			scrollContainer.CanvasSize = UDim2.new(scrollContainer.Size.X.Scale, -1, contentRelativeSize * scrollContainer.Size.Y.Scale, 0)
			
				for i, thing in pairs(items) do
					local button = create 'ImageButton' {
						AutoButtonColor = false,
						BackgroundColor3 = Color3.new(.4, .8, 1),
						BackgroundTransparency = i%2==0 and 0.75 or 1.0,
						BorderSizePixel = 0,
						Size = UDim2.new(0.95, 0, s, 0),
						Position = UDim2.new(0.025, 0, s*(i-1), 0),
						ZIndex = 10,
						Parent = container,
					}
					Utilities.fastSpawn(function()
						local item = _p.DataManager:getData('Items', rc4(thing[1]))
						if not button.Parent then return end
						local text = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.95, 0, 0.7, 0),
							Position = UDim2.new(0.025, 0, 0.15, 0),
							ZIndex = 3, Parent = button,
						}					write(item.name) { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }
					local price = thing[2]
					local isRobux = type(price) == 'string' and price:sub(1,1) == 'r'
					if isRobux then
						price = tonumber(price:sub(2))
						write(_p.PlayerData:formatMoney(price)..' R$') { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right }
					else
						write('[$] '.._p.PlayerData:formatMoney(price)) { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right }
					end
					button.MouseButton1Click:connect(function()
						if saying then return end
						local descContainer = gui.Details.DescContainer
						descContainer:ClearAllChildren()
						if item.desc then
							write(item.desc) { Frame = descContainer, Size = descContainer.AbsoluteSize.Y/5.8, Wraps = true }
						end
						gui.Details.IconContainer:ClearAllChildren()
						local icon = _p.Menu.bag:getItemIcon(item)
						icon.SizeConstraint = Enum.SizeConstraint.RelativeXY
						icon.Size = UDim2.new(1.0, 0, 1.0, 0)
						icon.Parent = gui.Details.IconContainer
						selection = {item = item, price = price, icon = icon, encryptedId = thing[1], robux = isRobux, arg3 = thing[3]}
						gui.Details.BuyButton.Visible = true
					end)
				end)
			end
		end)
	end
end

do
	local sig, mainMenu
	function shop:open(shopId)--, enableSelling ?
		if not mainMenu then
			sig = Utilities.Signal()
			mainMenu = _p.RoundedFrame:new {
				Name = 'ShopMenu',
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0.2, 0, 0.4, 0),
				Position = UDim2.new(0.6, 0, 0.05, 0),
				Parent = Utilities.frontGui,
			}
			write 'Buy' {
				Frame = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.1, 0),
					ZIndex = 2,
					Parent = mainMenu.gui,
					MouseButton1Click = function()
						mainMenu.Visible = false
						sig:fire('buy')
					end,
				},
				Scaled = true,
				Color = Color3.new(0.4, 0.4, 0.4),
				TextXAlignment = Enum.TextXAlignment.Center,
			}
			write 'Sell' {
				Frame = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.4, 0),
					ZIndex = 2,
					Parent = mainMenu.gui,
					MouseButton1Click = function()
						mainMenu.Visible = false
						sig:fire('sell')
					end,
				},
				Scaled = true,
				Color = Color3.new(0.4, 0.4, 0.4),
				TextXAlignment = Enum.TextXAlignment.Center,
			}
			write 'Cancel' {
				Frame = Utilities.Create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.8, 0, 0.2, 0),
					Position = UDim2.new(0.1, 0, 0.7, 0),
					ZIndex = 2,
					Parent = mainMenu.gui,
					MouseButton1Click = function()
						mainMenu.Visible = false
						sig:fire()
					end,
				},
				Scaled = true,
				Color = Color3.new(0.4, 0.4, 0.4),
				TextXAlignment = Enum.TextXAlignment.Center,
			}
		end
		mainMenu.CornerRadius = Utilities.gui.AbsoluteSize.Y*.025
		mainMenu.Visible = true
		local choice = sig:wait()
		if choice == 'buy' then
			self:buyMenu(shopId)
			return true
		elseif choice == 'sell' then
			self:sellMenu()
			return true
		end
		return false
	end
end

do
	local sig, gui
	function shop:buyMenu(shopId)
		local fader = Utilities.fadeGui
		if not gui then
			local sbw = Utilities.gui.AbsoluteSize.Y*.035
			sig = Utilities.Signal()
			gui = _p.RoundedFrame:new{ -- gui == RF.gui
				Name = 'MartGui',
				BackgroundColor3 = Color3.new(.35, .7, 1),--BrickColor.new('Cyan').Color,--Color3.new(.4, .8, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(.8, 0, .9, 0),
				Position = UDim2.new(0.0, Utilities.gui.AbsoluteSize.X*1.2, 0.05, 0),
				Parent = Utilities.gui,
				ZIndex = 2,
				
				create 'Frame' {
					Name = 'MoneyContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.06, 0),
					Position = UDim2.new(1.05, 0, 0.1, 0),
					ZIndex = 3,
				},
				_p.RoundedFrame:new {
					Button = true,
					Name = 'DevProdButton',
					BackgroundColor3 = Color3.fromRGB(104, 225, 74),
					Size = UDim2.new(.22, 0, .07, 0),
					Position = UDim2.new(1.1, 0, 0.2, 0),
					ZIndex = 3,
					MouseButton1Click = function()
						self:buyMoney()
					end
				},
				_p.RoundedFrame:new {
					Name = 'TitleBar',
					BackgroundColor3 = BrickColor.new('Deep blue').Color,--Color3.new(.4, .4, 1),
					Size = UDim2.new(1.05, 0, .1, 0),
					Position = UDim2.new(-.025, 0, .025, 0),
					ZIndex = 3,
					
					create 'Frame' {
						Name = 'TextContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.95, 0, 0.7, 0),
						Position = UDim2.new(0.025, 0, 0.15, 0),
						ZIndex = 4,
					},
				},
				create 'ScrollingFrame' {
					Name = 'Scroller',
					BackgroundTransparency = 1.0,
					BorderSizePixel = 0,
					Size = UDim2.new(0.95, 0, 0.6, 0),
					Position = UDim2.new(0.025, 0, 0.15, 0),
					ScrollBarThickness = sbw,
					ZIndex = 3,
					
					create 'Frame' {
						BackgroundTransparency = 1.0,
						Name = 'ContentContainer',
						Size = UDim2.new(1.0, -sbw, 1.0, -sbw),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
					}
				},
				_p.RoundedFrame:new {
					Name = 'Details',
					BackgroundColor3 = BrickColor.new('Deep blue').Color,--Color3.new(.3, .3, .3),
					Size = UDim2.new(1.05, 0, 0.2, 0),
					Position = UDim2.new(-0.025, 0, 0.775, 0),
					ZIndex = 3,
					
					create 'Frame' {
						Name = 'DescContainer',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.75, 0, 0.85, 0),
						Position = UDim2.new(0.225, 0, 0.075, 0),
						ZIndex = 4,
					},
					create 'Frame' {
						Name = 'IconContainer',
						BackgroundTransparency = 1.0,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(0.5, 0, 0.5, 0),
						Position = UDim2.new(0.04, 0, 0.0, 0),
					},
					_p.RoundedFrame:new {
						Name = 'BuyButton',
						Button = true,
						BackgroundColor3 = BrickColor.new('Navy blue').Color,
						Size = UDim2.new(0.2, 0, 0.425, 0),
						Position = UDim2.new(0.0125, 0, 0.5, 0),
						ZIndex = 4,
						MouseButton1Click = function()
							self:buySelection()
							self:updateMoney(gui) -- 
						end,
					}
				},
			}.gui
			write 'Pok[e\'] Mart' {
				Frame = gui.TitleBar.TextContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}
			write 'Buy' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					ZIndex = 5, Parent = gui.Details.BuyButton,
				}, Scaled = true
			}
			write 'Buy [$]' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					ZIndex = 5, Parent = gui.DevProdButton,
				}, Scaled = true
			}
			local cancel = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = BrickColor.new('Navy blue').Color,
				Size = UDim2.new(0.3, 0, 0.8, 0),
				Position = UDim2.new(0.69, 0, 0.1, 0),
				ZIndex = 4, Parent = gui.TitleBar,
				MouseButton1Click = function()
					if saying or state == 'transitionoff' then return end
					state = 'transitionoff'
					local xs = gui.Position.X.Offset
					local xe = Utilities.gui.AbsoluteSize.X*1.2
					delay(.3, function() sig:fire() end)
					Utilities.Tween(.8, 'easeOutCubic', function(a)
						gui.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.05, 0)
						fader.BackgroundTransparency = 0.3+a*0.7
					end)
					fader.BackgroundTransparency = 1.0
					state = 'off'
					gui.Parent = nil
				end,
			}
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.7, 0),
					Position = UDim2.new(0.0, 0, 0.15, 0),
					ZIndex = 5, Parent = cancel.gui,
				}, Scaled = true,
			}
		end
		-- todo: needs to adjust when screen adjusts
		gui.Parent = Utilities.gui
		state = 'transition'
		self:buildList(gui, shopId)
		fader.ZIndex = 1
		local xs = gui.Position.X.Offset
		local xe = Utilities.gui.AbsoluteSize.X/2-gui.AbsoluteSize.X/2
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			gui.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.05, 0)
			fader.BackgroundTransparency = 1.0-a*0.7
		end)
		state = 'on'
		sig:wait()
	end
	
	function shop:updateMoneyIfActive()
--		for _, cb in pairs(self.moneyUpdateCallbacks) do pcall(cb) end
		if not gui or state ~= 'on' then return end
		self:updateMoney(gui)
	end
end

function shop:sellMenu()
	local sig = Utilities.Signal()
	_p.Menu.bag:open(nil, sig)
	sig:wait()
end

do
	local open = false
	local buttons = {}
	local gui, bg, window, cancel
	function shop:buyMoney()
		if open then return end
		open = true
		if not gui then
			gui = create 'ScreenGui' {
				Name = 'BuyMoneyGui'
			}
			bg = create 'ImageButton' {
				AutoButtonColor = false,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
				Parent = gui
			}
			window = _p.RoundedFrame:new {
				BackgroundColor3 = Color3.fromRGB(104, 225, 74),
				Size = UDim2.new(.4, 0, .4, 0),
				ZIndex = 2, Parent = gui
			}
			local amounts = {10000,50000,100000,200000}
			local ids = {_p.productId._10kP, _p.productId._50kP, _p.productId._100kP, _p.productId._200kP}
			local rbxs = {20, 85, 150, 275}
			for i = 1, 4 do
				local b = _p.RoundedFrame:new {
					Button = true,
					BackgroundColor3 = Color3.fromRGB(92, 200, 64),
					Size = UDim2.new(.95, 0, .2, 0),
					Position = UDim2.new(.025, 0, .025+.25*(i-1), 0),
					ZIndex = 3, Parent = window.gui,
					MouseButton1Click = function()
						_p.MarketClient:promptProductPurchase(ids[i])
					end
				}
				buttons[i] = b
				write('[$]'.._p.PlayerData:formatMoney(amounts[i])) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, .7, 0),
						Position = UDim2.new(.05, 0, .15, 0),
						ZIndex = 4, Parent = b.gui
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left
				}
				write(rbxs[i]..'R$') {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, .7, 0),
						Position = UDim2.new(.95, 0, .15, 0),
						ZIndex = 4, Parent = b.gui
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
					Color = Color3.fromRGB(0, 144, 56)
				}
			end
			write 'Please remember to save' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, .07, 0),
					Position = UDim2.new(.5, 0, 1.05, 0),
					ZIndex = 3, Parent = window.gui
				}, Scaled = true
			}
			cancel = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.fromRGB(0, 144, 56),
				Size = UDim2.new(.4, 0, .2, 0),
				Position = UDim2.new(.3, 0, 1.17, 0),
				ZIndex = 3, Parent = window.gui
			}
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, .7, 0),
					Position = UDim2.new(.5, 0, .15, 0),
					ZIndex = 4, Parent = cancel.gui
				}, Scaled = true
			}
		end
		local h = Utilities.gui.AbsoluteSize.Y
		window.CornerRadius = h*.025
		cancel.CornerRadius = h*.0175
		for _, b in pairs(buttons) do
			b.CornerRadius = h*.015
		end
		gui.Parent = Utilities.gui.Parent
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			bg.BackgroundTransparency = 1-.3*a
			window.Position = UDim2.new(.3, 0, -.7+a, 0)
		end)
		cancel.MouseButton1Click:wait()
		Utilities.Tween(.6, 'easeOutCubic', function(a)
			bg.BackgroundTransparency = .7+.3*a
			window.Position = UDim2.new(.3, 0, .3-a, 0)
		end)
		gui.Parent = nil
		open = false
	end
end


return shop end