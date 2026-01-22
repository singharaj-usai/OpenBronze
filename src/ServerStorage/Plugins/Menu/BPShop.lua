return function(_p)
local Utilities = _p.Utilities
local create = Utilities.Create
local write = Utilities.Write

local shop = {}

local gui

function shop:updateBP()
	if not gui then return end
	gui.MoneyContainer:ClearAllChildren()
	write(_p.PlayerData.bp..' BP') {
		Frame = gui.MoneyContainer,
		Scaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}
end

local saying
do
	local selection
	function shop:buySelection()
		if saying or not selection then return end
		local item = selection.item
--		local itemId = selection.encryptedId
		if item.bp then
			if item.productId then
				_p.MarketClient:promptProductPurchase(item.productId)
			end
			return
		end
		saying = true
		local max = _p.Network:get('PDS', 'bMaxBuy', selection.index)
		if max == 'ao' then
			_p.NPCChat:say('You already own this TM.')
			wait() wait()
			saying = false
			return
		elseif max == 'fb' then
			_p.NPCChat:say('You don\'t have any more room in your bag for this item.')
			wait() wait()
			saying = false
			return
		elseif max == 'nm' then
			_p.NPCChat:say('You don\'t have enough BP.')
			wait() wait()
			saying = false
			return
		end
		local qty
		if max == 'tm' then
			qty = 1
		else
			qty = _p.Menu.bag:selectQuantity(max, selection.icon:Clone(), 'How many would you like?', '%d BP', selection.price)
		end
		if not qty or not _p.NPCChat:say('[y/n]You want '..(max=='tm' and 'a' or qty)..' '..(item.tm and ('TM'..item.num) or item.name)..(qty>1 and 's' or '')..'. That will be '..(qty*selection.price)..' BP. Is that OK?') then
			saying = false
			return
		end
		local s, newbp = _p.Network:get('PDS', 'buyWithBP', selection.index, max~='tm' and qty or nil)
		if not s then
			_p.NPCChat:say('An error occurred.')
			saying = false
			return
		end
		if newbp then
			_p.PlayerData.bp = newbp
		end
		_p.NPCChat:say('Here you go. Thank you.')
		wait() wait()
		saying = false
	end
	
	function shop:buildList(gui)
		selection = nil
		gui.Details.BuyButton.Visible = false
		self:updateBP(gui) --
		
		local items--[[, encryptedIds]] = _p.Network:get('PDS', 'getShop', 'bp')
		
		local s = 0.08
		local scrollContainer = gui.Scroller
		local container = scrollContainer.ContentContainer
		container:ClearAllChildren()
		local contentRelativeSize = (#items+1)*s*container.AbsoluteSize.X/scrollContainer.AbsoluteSize.Y
		scrollContainer.CanvasSize = UDim2.new(scrollContainer.Size.X.Scale, -1, contentRelativeSize * scrollContainer.Size.Y.Scale, 0)
		
			for i, thing in pairs(items) do
				local button = create 'ImageButton' {
					AutoButtonColor = false,
					BackgroundColor3 = Color3.new(.37, .86, .69),
					BackgroundTransparency = i%2==0 and 0.75 or 1.0,
					BorderSizePixel = 0,
					Size = UDim2.new(0.95, 0, s, 0),
					Position = UDim2.new(0.025, 0, s*(i-1), 0),
					ZIndex = 10,
					Parent = container,
				}
					
					
--			local encryptedId = encryptedIds[i]
			Utilities.fastSpawn(function()
				local tm, bp
				local item, move
				if thing[1]:sub(1, 2) == 'TM' then
					local moveName
					tm, moveName = thing[1]:match('^TM(%d+)%s(.+)$')
					move = _p.DataManager:getData('Movedex', Utilities.toId(moveName))
					if not move then print(moveName) end
				elseif thing[1]:sub(1, 2) == 'BP' then
					bp = thing[1]:sub(3)
				else
					item = _p.DataManager:getData('Items', thing[1])
				end
				if not button.Parent then return end
				local text = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.95, 0, 0.7, 0),
					Position = UDim2.new(0.025, 0, 0.15, 0),
					ZIndex = 3, Parent = button,
				}
				write((tm and thing[1]) or (bp and bp..' BP') or item.name) { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left }
				write(thing[2]..(bp and ' R$' or ' BP')) { Frame = text, Scaled = true, TextXAlignment = Enum.TextXAlignment.Right }
				button.MouseButton1Click:connect(function()
					if saying then return end
					local descContainer = gui.Details.DescContainer
					descContainer:ClearAllChildren()
					if tm then
						write(move.category..', '..move.type..'-type, '..(move.basePower or 0)..' Power,\n'..(move.accuracy==true and '--' or ((move.accuracy or 0)..'%'))..' Accuracy'..((move.desc and move.desc~='') and ('. Effect: '..move.desc) or '')) {
							Frame = descContainer, Size = descContainer.AbsoluteSize.Y/5.8, Wraps = true
						}
					elseif bp then
						write('Need BP fast? Purchase '..bp..' BP for '..thing[2]..'R$.') { Frame = descContainer, Size = descContainer.AbsoluteSize.Y/3.9, Wraps = true }
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
					elseif bp then
						item = { bp = true }
						if bp == '10' then
							item.productId = _p.productId.TenBP
						elseif bp == '50' then
							item.productId = _p.productId.FiftyBP
						end
					end
					local icon
					if not bp then
						icon = _p.Menu.bag:getItemIcon(item)
						icon.SizeConstraint = Enum.SizeConstraint.RelativeXY
						icon.Size = UDim2.new(1.0, 0, 1.0, 0)
						icon.Parent = gui.Details.IconContainer
					end
					selection = {item = item, price = thing[2], icon = icon, index = i}--, encryptedId = encryptedId}
					gui.Details.BuyButton.Visible = true
				end)
			end)
		end
	end
end

do
	local sig
	local state = 'off'
	function shop:open()
		local fader = Utilities.fadeGui
		if not gui then
			local sbw = Utilities.gui.AbsoluteSize.Y*.035
			sig = Utilities.Signal()
			gui = _p.RoundedFrame:new{
				Name = 'BPShopGui',
				BackgroundColor3 = Color3.new(.33, .8, .6),
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
					Name = 'TitleBar',
					BackgroundColor3 = BrickColor.new('Dark green').Color,
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
					BackgroundColor3 = BrickColor.new('Dark green').Color,
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
						BackgroundColor3 = BrickColor.new('Earth green').Color,
						Size = UDim2.new(0.2, 0, 0.425, 0),
						Position = UDim2.new(0.0125, 0, 0.5, 0),
						ZIndex = 4,
						MouseButton1Click = function()
							self:buySelection()
							self:updateBP(gui)
						end,
					}
				},
			}.gui
			write 'BP Shop' {
				Frame = gui.TitleBar.TextContainer,
				Scaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}
			write 'Buy' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 0.6, 0),
					Position = UDim2.new(0.0, 0, 0.2, 0),
					ZIndex = 5, Parent = gui.Details.BuyButton,
				}, Scaled = true,
			}
			local cancel = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = BrickColor.new('Earth green').Color,
				Size = UDim2.new(0.3, 0, 0.8, 0),
				Position = UDim2.new(0.69, 0, 0.1, 0),
				ZIndex = 4, Parent = gui.TitleBar,
				MouseButton1Click = function()
					if saying or state == 'transition' then return end
					state = 'transition'
					local xs = gui.Position.X.Offset
					local xe = Utilities.gui.AbsoluteSize.X*1.2
					delay(.3, function() sig:fire() end)
					Utilities.Tween(.8, 'easeOutCubic', function(a)
						gui.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.05, 0)
						fader.BackgroundTransparency = 0.3+a*0.7
					end)
					fader.BackgroundTransparency = 1.0
					state = 'off'
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
		self:buildList(gui)
		state = 'transition'
		fader.ZIndex = 1
		fader.BackgroundColor3 = Color3.new(0, 0, 0)
		local xs = gui.Position.X.Offset
		local xe = Utilities.gui.AbsoluteSize.X/2-gui.AbsoluteSize.X/2
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			gui.Position = UDim2.new(0.0, xs + (xe-xs)*a, 0.05, 0)
			fader.BackgroundTransparency = 1.0-a*0.7
		end)
		state = 'on'
		sig:wait()
	end
end



return shop end