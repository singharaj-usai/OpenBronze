
--old tradegui
--[[
return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
local Utilities = _p.Utilities
local create = Utilities.Create
local write = Utilities.Write
--]]
--[[

TODO: 

The following condition causes a confused Trade Session:
Both Players hit Ready
One hits Trade, their Pokeball icon starts spinning
The other hits cancel (ready = false)

The first player's pokeball keeps spinning
They are unable to actually trade unless they start a new session
	(this isn't completely tested but if you can trade in this
	condition, it's not easy to do)

^
im gonna fix that later

]]
--[[
local TradeGui = {}

local container, fader, rfs
local acceptButton, cancelButton, tradeButton
local acceptButtonText
local myOfferTray, theirOfferTray
local offerIconContainers, partyIconContainers
local offerTrayRFs
local partyIcons
local depositInfo, errorContainer
local onScreenResized

local mouse = _p.player:GetMouse()
local mouseDown = false
local stepped = game:GetService('RunService').RenderStepped

local AB_COLOR_READY = Color3.new(.15, .6, .5)
local AB_COLOR_DISABLED = Color3.new(.3, .3, .3)

local TRAY_COLOR_READY = Color3.new(.2, .85, .7)
local TRAY_RF_COLOR_READY = Color3.new(.25, 1, .75)
local TRAY_COLOR_NOT_READY = Color3.new(.5, .5, .5)
local TRAY_RF_COLOR_NOT_READY = Color3.new(.65, .65, .65)

local acceptState = 0

game:GetService('UserInputService').InputEnded:connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
		mouseDown = false
	end
end)

local function viewSummary(side, index)
	if not _p.Trade[(side==1 and 'my' or 'their')..'Party'][index] then return end
	local sum = _p.Trade:sendAsync('getSummary', side, index)
	if not sum then
--		print('couldn\'t get summary')
		return
	end
	_p.Menu.party:viewSummary(sum, true, true)
end

local isReady = {}
local function setTrayReady(n, ready)
	isReady[n] = ready
	local tray = n==1 and myOfferTray or theirOfferTray
	tray.BackgroundColor3 = ready and TRAY_COLOR_READY or TRAY_COLOR_NOT_READY
	for i = 1, 4 do
		offerTrayRFs[n][i].BackgroundColor3 = ready and TRAY_RF_COLOR_READY or TRAY_RF_COLOR_NOT_READY
	end
	if isReady[1] and isReady[2] then
		tradeButton.Visible = true
	else
		tradeButton.Visible = false
	end
	cancelButton.Visible = not tradeButton.Visible
end
function TradeGui:setTrayReady(...)
	setTrayReady(...)
end

local iconThreads = {}
local function moveIcon(icon, parent)
	if icon.Parent == parent then wait(.5) return end
	local ss, sp = icon.AbsoluteSize, icon.AbsolutePosition
	local es, ep = parent.AbsoluteSize, parent.AbsolutePosition
	icon.Parent = Utilities.gui
	local thisThread = {}
	iconThreads[icon] = thisThread
	Utilities.Tween(.5, 'easeOutCubic', function(a)
		if iconThreads[icon] ~= thisThread then return false end
		icon.Size = UDim2.new(0.0, ss.X + (es.X-ss.X)*a, 0.0, ss.Y + (es.Y-ss.Y)*a)
		icon.Position = UDim2.new(0.0, sp.X + (ep.X-sp.X)*a, 0.0, sp.Y + (ep.Y-sp.Y)*a)
	end)
	if iconThreads[icon] == thisThread then
		icon.Size = UDim2.new(1.0, 0, 1.0, 0)
		icon.Position = UDim2.new(0.0, 0, 0.0, 0)
		icon.Parent = parent
	end
end

local countdownThread
local function countdown()
	acceptState = 0
	local trade = _p.Trade
	local myOffer, theirOffer = trade.myOffer, trade.theirOffer
	local myParty, theirParty = trade.myParty, trade.theirParty
	local pcount = #myParty
	for i = 1, 4 do
		if myOffer[i] then
			pcount = pcount - 1
		end
		if theirOffer[i] then
			pcount = pcount + 1
		end
	end
	depositInfo.Visible = pcount>6
	-- check whether you will end up with all eggs
	local allEggs = true; 
	do
		local keep = {
		true, true, true, true, true, true}
		for i = 1, 4 do
			if theirOffer[i] and theirParty[theirOffer[i] ][1] < 1450 then -- egg threshold
				allEggs = false
				break
			elseif myOffer[i] then
				keep[myOffer[i] ] = false
			end
		end
		if allEggs then
			for i, p in pairs(myParty) do
				if keep[i] and p[1] < 1450 then -- egg threshold
					allEggs = false
					break
				end
			end
		end
	end
	--
	if allEggs or not _p.Trade:isValidTrade() or pcount <= 0 then
		acceptButton.Visible = false
		return
	end
	local thisThread = {}
	countdownThread = thisThread
	acceptButton.BackgroundColor3 = AB_COLOR_DISABLED
	acceptButton.Visible = true
	for i = 5, 1, -1 do
		acceptButtonText:ClearAllChildren()
		write(tostring(i)) { Frame = acceptButtonText, Scaled = true }
		wait(1)
		if countdownThread ~= thisThread then return end
	end
	acceptButton.BackgroundColor3 = AB_COLOR_READY
	acceptButtonText:ClearAllChildren()
	write 'Ready' { Frame = acceptButtonText, Scaled = true }
	acceptState = 1
end

function TradeGui:updatePartnerOffer(offer)
	local offerIndicesByPartyIndex = {}
	for i = 1, 4 do
		if offer[i] then
			offerIndicesByPartyIndex[offer[i] ] = i
		end
	end
	for i = 1, 6 do
		local ic = partyIcons[2][i]
		if ic then
			local oi = offerIndicesByPartyIndex[i]
			Utilities.fastSpawn(moveIcon, ic, oi and offerIconContainers[2][oi] or partyIconContainers[2][i])
		end
	end
	countdown()
end

function TradeGui:dragIcon(pokemonIndex, x, y, prevOfferIndex)
	local icon = partyIcons[1][pokemonIndex]
	local oPos
	if Utilities.isTouchDevice() then
		local vpo = workspace.CurrentCamera.ViewportSize-Utilities.gui.AbsoluteSize
		oPos = Vector2.new(x, y-vpo.Y)
	else
		oPos = Vector2.new(mouse.X, mouse.Y)
	end
	local as, ap = icon.AbsoluteSize, icon.AbsolutePosition
	local offset = oPos-ap
	local dragging = false
	while mouseDown do
		if (Vector2.new(mouse.X, mouse.Y)-oPos).magnitude > Utilities.gui.AbsoluteSize.Y*.03 then
			dragging = true
			break
		end
		stepped:wait()
	end
	if not dragging then
		viewSummary(1, pokemonIndex)
		self.busy = false
		return
	end
	icon.Size = UDim2.new(0.0, as.X, 0.0, as.Y)
	icon.Parent = Utilities.gui
	while mouseDown do
		icon.Position = UDim2.new(0.0, mouse.X-offset.X, 0.0, mouse.Y-offset.Y)
		stepped:wait()
	end
	-- Mouse Released
	local c = icon.AbsolutePosition + as/2
	local offerPos
	for i = 1, 4 do
		local oc = offerIconContainers[1][i]
		local l = oc.AbsolutePosition
		local h = l+oc.AbsoluteSize
		if c.X > l.X and c.X < h.X and c.Y > l.Y and c.Y < h.Y then
			offerPos = i
			break
		end
	end
	if offerPos then
		if _p.Trade.myParty[pokemonIndex][3] then
			self:error('That pokemon cannot be traded')
			moveIcon(icon, partyIconContainers[1][pokemonIndex])
			return
		end
		self:clearError()
		if offerPos == prevOfferIndex then
			moveIcon(icon, offerIconContainers[1][offerPos])
			return
		end
		local offerAtDestination = _p.Trade.myOffer[offerPos]
		if offerAtDestination then
			Utilities.fastSpawn(moveIcon, partyIcons[1][offerAtDestination], partyIconContainers[1][offerAtDestination])
		end
		if prevOfferIndex then -- MOVED FROM ANOTHER SLOT; CLEAR SLOT == NO DUPE
			_p.Trade.myOffer[prevOfferIndex] = nil
		end
		_p.Trade.myOffer[offerPos] = pokemonIndex
		_p.Trade:updateMyOffer()
		Utilities.fastSpawn(countdown)
		_p.Trade:setReady(false)
		setTrayReady(2, false)
		moveIcon(icon, offerIconContainers[1][offerPos])
	else
		if prevOfferIndex then
			_p.Trade.myOffer[prevOfferIndex] = nil
			_p.Trade:updateMyOffer()
			Utilities.fastSpawn(countdown)
			_p.Trade:setReady(false)
			setTrayReady(2, false)
		end
		moveIcon(icon, partyIconContainers[1][pokemonIndex])
	end
end

function TradeGui:offerIconClicked(side, index, x, y)
	if self.busy then return end
	if side == 2 then
		if #offerIconContainers[2][index]:GetChildren() > 0 then
			local partyIndex = _p.Trade.theirOffer[index]
			if partyIndex and _p.Trade.theirParty[partyIndex] then
				viewSummary(2, partyIndex)
			end
		end
		return
	end
	local prevOffer = _p.Trade.myOffer[index]
	if not prevOffer then return end
	self.busy = true
	self:dragIcon(prevOffer, x, y, index)
	self.busy = false
end

function TradeGui:partyIconClicked(side, index, x, y)
	if self.busy then return end
	if side == 2 then
		if #partyIconContainers[2][index]:GetChildren() > 0 and _p.Trade.theirParty[index] then
			viewSummary(2, index)
		end
		return
	end
	if partyIcons[1][index].Parent ~= partyIconContainers[1][index] then return end
	self.busy = true
	self:dragIcon(index, x, y)
	self.busy = false
end

function TradeGui:onTradeClicked()
	if self.trading or not isReady[1] or not isReady[2] then return end
	self.trading = true
	local tag = {}
	self.tradeLoadTag = tag
	_p.DataManager:setLoading(tag, true)
	_p.Trade:submit()
	wait(30)
	if self.tradeLoadTag == tag then
--		_p.Trade:undoPartner()
		_p.Trade:tradeFailed('timed out')
	end
end

function TradeGui:onAcceptClicked()
	if self.busy then return end
	if acceptState == 1 then
		if not _p.Trade:isValidTrade() then return end
		acceptState = 2
		acceptButtonText:ClearAllChildren()
		write 'Cancel' { Frame = acceptButtonText, Scaled = true }
		acceptButton.BackgroundColor3 = AB_COLOR_DISABLED
		_p.Trade:setReady(true)
	elseif acceptState == 2 then
		_p.Trade:setReady(false)
		countdown()
	end
end

function TradeGui:open()
	if self.isOpen or self.busy then return end
	self.isOpen = true
	self.busy = true
	spawn(function() _p.Menu:disable() end)
	spawn(function()
		while self.isOpen do
			_p.Menu.pc:forceClose()
			_p.Menu.party:close()
			wait(.25)
		end
	end)
	
	if not container then
		fader = create 'ImageButton' {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
		}
		container = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			
			create 'Frame' {
				Name = 'Divider',
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(.25, 1, .75),
				ZIndex = 4,
			},
			create 'Frame' {
				Name = 'MyParty',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.25, 0, 1.0, 0),
				
				create 'Frame' {
					Name = 'PlayerNameContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.06, 0),
					Position = UDim2.new(0.05, 0, 0.0, 0),
					ZIndex = 2,
				},
				create 'Frame' {
					Name = 'Container',
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(350/500*0.75, 0, 0.75, 0),
					
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5295755248',
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 3,
					}
				}
			},
			create 'Frame' {
				Name = 'TheirParty',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.25, 0, 1.0, 0),
				Position = UDim2.new(0.75, 0, 0.0, 0),
				
				create 'Frame' {
					Name = 'PlayerNameContainer',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.06, 0),
					Position = UDim2.new(0.95, 0, 0.0, 0),
					ZIndex = 2,
				},
				create 'Frame' {
					Name = 'Container',
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(350/500*0.75, 0, 0.75, 0),
					
					create 'ImageLabel' {
						BackgroundTransparency = 1.0,
						Image = 'rbxassetid://5295755248',
						Size = UDim2.new(1.0, 0, 1.0, 0),
						ZIndex = 3,
					}
				}
			},
			
			create 'Frame' {
				Name = 'MyOffer',
				ClipsDescendants = true,
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.25, -1, 1.0, 0),
				Position = UDim2.new(0.25, 0, 0.0, 0),
			},
			create 'Frame' {
				Name = 'TheirOffer',
				ClipsDescendants = true,
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.25, -1, 1.0, 0),
				Position = UDim2.new(0.5, 1, 0.0, 0),
			},
		}
		
		rfs = {}
		myOfferTray = _p.RoundedFrame:new {
--			BackgroundColor3 = Color3.new(.2, .85, .7),
			Size = UDim2.new(0.5, 0, 0.75, 0),
			Position = UDim2.new(1.0, 0, 0.05, 0),
			ZIndex = 2, Parent = container.MyOffer,
		}
		table.insert(rfs, myOfferTray)
		theirOfferTray = _p.RoundedFrame:new {
--			BackgroundColor3 = Color3.new(.5, .5, .5),
			Size = UDim2.new(0.5, 0, 0.75, 0),
			Position = UDim2.new(-0.5, 0, 0.05, 0),
			ZIndex = 2, Parent = container.TheirOffer,
		}
		table.insert(rfs, theirOfferTray)
		offerIconContainers = {{},{}}
		offerTrayRFs = {{},{}}
		for s, tray in pairs({myOfferTray, theirOfferTray}) do
			for i = 1, 4 do
				local rf = _p.RoundedFrame:new {
					Button = true,
--					BackgroundColor3 = (s==1 and Color3.new(.25, 1, .75) or Color3.new(.65, .65, .65)),
					Size = UDim2.new(0.9, 0, 0.225, 0), -- ~1.6x1
					Position = UDim2.new(0.05, 0, 0.02+.245*(i-1), 0),
					ZIndex = 3, Parent = tray.gui,
				}
				rf.gui.MouseButton1Down:connect(function(x, y)
					mouseDown = true
					self:offerIconClicked(s, i, x, y)
				end)
				offerTrayRFs[s][i] = rf
				table.insert(rfs, rf)
				offerIconContainers[s][i] = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(4/3/1.6, 0, 1.0, 0),
					Position = UDim2.new(0.5-(4/3/1.6/2), 0, 0.0, 0),
					Parent = rf.gui,
				}
			end
		end
		partyIconContainers = {{},{}}
		do
			local positions = {
				UDim2.new( 22/350, 0,  34/500, 0),
				UDim2.new(181/350, 0,  93/500, 0),
				UDim2.new( 22/350, 0, 163/500, 0),
				UDim2.new(181/350, 0, 223/500, 0),
				UDim2.new( 22/350, 0, 294/500, 0),
				UDim2.new(181/350, 0, 354/500, 0),
			}
			for s, container in pairs({container.MyParty.Container, container.TheirParty.Container}) do
				for i = 1, 6 do
					local ic = create 'ImageButton' {
						Image = '',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(148/350, 0, 111/500, 0),
						Position = positions[i],-- + UDim2.new(19/350, 0, 0.0, 0),
						ZIndex = 3, Parent = container,
						MouseButton1Down = function(x, y)
							mouseDown = true
							self:partyIconClicked(s, i, x, y)
						end,
					}
					partyIconContainers[s][i] = ic
				end
			end
		end
		
		tradeButton = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = Color3.new(.45, .6, .9),
			Size = UDim2.new(0.15, 0, 0.125, 0),
			Position = UDim2.new(0.425, 0, -0.1, 0),
			ZIndex = 7, Parent = container,
			MouseButton1Click = function()
				self:onTradeClicked()
			end,
		}
		write 'Trade' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.5, 0),
				Position = UDim2.new(0.5, 0, 0.25, 0),
				ZIndex = 8, Parent = tradeButton.gui,
			}, Scaled = true,
		}
		acceptButton = _p.RoundedFrame:new {
			Button = true,
			Size = UDim2.new(0.9, 0, 0.15, 0),
			Position = UDim2.new(0.05, 0, 1.05, 0),
			ZIndex = 3, Parent = myOfferTray.gui,
			MouseButton1Click = function()
				if self.busy then return end
				self:onAcceptClicked()
			end,
		}
		acceptButtonText = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.5, 0),
			Position = UDim2.new(0.5, 0, 0.25, 0),
			ZIndex = 4, Parent = acceptButton.gui,
		}
		cancelButton = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = Color3.new(.5, .3, .3),
			Size = UDim2.new(0.9, 0, 0.15, 0),
			Position = UDim2.new(0.05, 0, -0.2, 0),
			ZIndex = 3, Parent = theirOfferTray.gui,
			MouseButton1Click = function()
				if self.busy then return end
				self.busy = true
				if not _p.NPCChat:say('[y/n]Cancel Trade with ' .. (self.tradingWith or 'NULL') .. '?') then
					self.busy = false
					return
				end
				_p.Trade:exitCurrentSession()
				self:close()
				self.busy = false
			end,
		}
		write 'Exit' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.5, 0),
				Position = UDim2.new(0.5, 0, 0.25, 0),
				ZIndex = 4, Parent = cancelButton.gui,
			}, Scaled = true,
		}
		depositInfo = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.04, 0),
			Position = UDim2.new(0.5, 0, 1.03, 0),
			ZIndex = 3, Parent = container,
		}
		write 'One or more of the received pokemon will be sent to the PC.' { Frame = depositInfo, Scaled = true }
		errorContainer = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.04, 0),
			Position = UDim2.new(0.5, 0, 1.03, 0),
			ZIndex = 3, Parent = container,
		}
		
		onScreenResized = function(prop)
			if prop ~= 'AbsoluteSize' then return end
			local s = Utilities.gui.AbsoluteSize
			if s.X/2/6*5 < s.Y*0.8 then
				container.Size = UDim2.new(1.0, 0, 0.0, s.X/2/6*5)
				container.Position = UDim2.new(0.0, 0, 0.5, -container.AbsoluteSize.Y/2)
			else
				container.Size = UDim2.new(0.0, s.Y*0.8/5*6*2, 0.8, 0)
				container.Position = UDim2.new(0.5, -container.AbsoluteSize.X/2, 0.1, 0)
			end
			container.MyParty.Container.Position = UDim2.new(0.5, -container.MyParty.Container.AbsoluteSize.X/2, 0.125, 0)
			container.TheirParty.Container.Position = UDim2.new(0.5, -container.TheirParty.Container.AbsoluteSize.X/2, 0.125, 0)
			
			for _, rf in pairs(rfs) do rf.CornerRadius = Utilities.gui.AbsoluteSize.Y*.03 end
			tradeButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.02
			acceptButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.02
			cancelButton.CornerRadius = Utilities.gui.AbsoluteSize.Y*.02
		end
		Utilities.gui.Changed:connect(onScreenResized)
	end
	
	setTrayReady(1, false)
	setTrayReady(2, false)
	depositInfo.Visible = false
	
	acceptButton.Visible = false
--[[	acceptButton.BackgroundColor3 = AB_COLOR_DISABLED
	write 'Ready' {
		Frame = acceptButtonText,
		Scaled = true,
	}--]]


--[[
	container.MyParty.PlayerNameContainer:ClearAllChildren()
	container.TheirParty.PlayerNameContainer:ClearAllChildren()
	write(_p.PlayerData.trainerName) {
		Frame = container.MyParty.PlayerNameContainer,
		Scaled = true, TextXAlignment = Enum.TextXAlignment.Left,
	}
	write(self.tradingWith or 'NULL') {
		Frame = container.TheirParty.PlayerNameContainer,
		Scaled = true, TextXAlignment = Enum.TextXAlignment.Right,
	}
	local trade = _p.Trade
	local myParty, theirParty = trade.myParty, trade.theirParty
	
	partyIcons = {{},{}}
	for i = 1, 6 do
		partyIconContainers[1][i]:ClearAllChildren()
		partyIconContainers[2][i]:ClearAllChildren()
		if myParty and myParty[i] then
			local id = myParty[i]
			local icon = _p.Pokemon:getIcon(id[1], id[2])
			icon.Parent = partyIconContainers[1][i]
			partyIcons[1][i] = icon
		end
		if theirParty and theirParty[i] then
			local id = theirParty[i]
			local icon = _p.Pokemon:getIcon(id[1], id[2])
			icon.Parent = partyIconContainers[2][i]
			partyIcons[2][i] = icon
		end
	end
	for i = 1, 4 do
		offerIconContainers[1][i]:ClearAllChildren()
		offerIconContainers[2][i]:ClearAllChildren()
	end
	
	fader.Parent = Utilities.gui
	container.Parent = Utilities.gui
	onScreenResized('AbsoluteSize')
	
	delay(.4, function()
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			container.Divider.Size = UDim2.new(0.0, 2, a, 0)
			container.Divider.Position = UDim2.new(0.5, -1, 0.5-a/2, 0)
		end)
	end)
	Utilities.Tween(.8, 'easeOutCubic', function(a)
		fader.BackgroundTransparency = 1-0.3*a
		container.MyParty.Position = UDim2.new(-.35*(1-a), 0, 0.0, 0)
		container.TheirParty.Position = UDim2.new(1.1-.35*a, 0, 0.0, 0)
	end)
	Utilities.Tween(.8, 'easeOutCubic', function(a)
		myOfferTray.Position = UDim2.new(1.1-0.7*a, 0, 0.05, 0)
		theirOfferTray.Position = UDim2.new(.1-.7*(1-a), 0, 0.05+.75*.2, 0)
	end)
	self.busy = false
end

function TradeGui:close()
	self.busy = true
	delay(.4, function()
		Utilities.Tween(.8, 'easeOutCubic', function(a)
			a = 1-a
			container.Divider.Size = UDim2.new(0.0, 2, a, 0)
			container.Divider.Position = UDim2.new(0.5, -1, 0.5-a/2, 0)
		end)
	end)
	Utilities.Tween(.8, 'easeOutCubic', function(a)
		a = 1-a
		myOfferTray.Position = UDim2.new(1.1-0.7*a, 0, 0.05, 0)
		theirOfferTray.Position = UDim2.new(.1-.7*(1-a), 0, 0.05+.75*.2, 0)
	end)
	Utilities.Tween(.8, 'easeOutCubic', function(a)
		a = 1-a
		fader.BackgroundTransparency = 1-0.3*a
		container.MyParty.Position = UDim2.new(-.35*(1-a), 0, 0.0, 0)
		container.TheirParty.Position = UDim2.new(1.1-.35*a, 0, 0.0, 0)
	end)
	self.busy = false
	container.Parent = nil
	fader.Parent = nil
	self.isOpen = false
end

function TradeGui:animateTrade(myOfferIcons, theirOfferIcons, evolutions)
	self.actuallyTrading = true
	spawn(function() self:close() end) -- todo: prevent opening while "actuallyTrading" ?
	local bg = create 'ImageButton' {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(1.0, 0, 1.0, 36),
		Position = UDim2.new(0.0, 0, 0.0, -36),
		Parent = Utilities.frontGui,
	}
	Utilities.Tween(.6, 'easeOutCubic', function(a)
		bg.BackgroundTransparency = 1-a
	end)
	local img1 = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5640653139',--need to be replaced/reuplaoded
		Size = UDim2.new(1.0, 0, 0.4, 0),
		Position = UDim2.new(0.0, 0, 0.06, 0),
		ZIndex = 2, Parent = Utilities.frontGui,
	}
	local img2 = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5640653139',--need to be replaced/reuplaoded
		Size = UDim2.new(1.0, 0, 0.4, 0),
		Position = UDim2.new(0.0, 0, 0.54, 0),
		ZIndex = 2, Parent = Utilities.frontGui,
	}
	Utilities.Tween(.3, 'easeOutCubic', function(a)
		img1.ImageTransparency = 1-a
		img2.ImageTransparency = 1-a
	end)
	local pokeContainer1 = create 'Frame' {
		BackgroundTransparency = 1.0,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(-0.2/3*4, 0, 0.2, 0),
	}
	for i, id in pairs(myOfferIcons) do
		local icon = _p.Pokemon:getIcon(id[1], id[2])
		icon.Parent = pokeContainer1
		icon.Position = UDim2.new(-i+1, 0, 0.0, 0)
	end
	local pokeContainer2 = create 'Frame' {
		BackgroundTransparency = 1.0,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(0.2/3*4, 0, 0.2, 0),
	}
	for i, id in pairs(theirOfferIcons) do
		local icon = _p.Pokemon:getIcon(id[1], id[2])
		icon.Parent = pokeContainer2
		icon.Position = UDim2.new(i-1, 0, 0.0, 0)
	end
	wait(.2)
	pokeContainer1.Parent = Utilities.frontGui
	pokeContainer2.Parent = Utilities.frontGui
	Utilities.Tween(5, nil, function(a)
		pokeContainer1.Position = UDim2.new(a, math.abs(pokeContainer1.AbsoluteSize.X)*4*a, 0.16, 0)
		pokeContainer2.Position = UDim2.new(1-a, -pokeContainer2.AbsoluteSize.X*4*a, 0.64, 0)
	end)
	pokeContainer1:remove()
	pokeContainer2:remove()
	Utilities.Tween(.3, 'easeOutCubic', function(a)
		img1.ImageTransparency = a
		img2.ImageTransparency = a
	end)
	img1:remove()
	img2:remove()
	Utilities.Tween(.5, 'easeOutCubic', function(a)
		bg.BackgroundTransparency = a
	end)
	self.actuallyTrading = false
	-- currently, when an evolution occurs, the trade session is closed
	local somethingTriedEvolving = false
	if evolutions then
		for _, evo in pairs(evolutions) do
			if not somethingTriedEvolving then
				_p.Trade:exitCurrentSession()
				somethingTriedEvolving = true
			end
			_p.Pokemon:processMovesAndEvolution(evo, false)
		end
	end
	if somethingTriedEvolving then
		_p.TradeMatching:afterTrade() -- this is already called by exitCurrentSession... :l
	else
		if self.tradePartnerQuitBetween then
			_p.NPCChat:say('The trade partner no longer wishes to trade.')
			_p.TradeMatching:afterTrade()
		else
			_p.Trade:readyToTradeAgain()
		end
	end
	bg:remove()
end

local errorThread
function TradeGui:error(txt)
	local thisThread = {}
	errorThread = thisThread
	errorContainer:ClearAllChildren()
	write(txt) {
		Frame = errorContainer,
		Scaled = true,
		Color = Color3.new(1, .2, .2),
	}
	delay(5, function()
		if thisThread ~= errorThread then return end
		errorContainer:ClearAllChildren()
	end)
end

function TradeGui:clearError()
	errorThread = nil
	errorContainer:ClearAllChildren()
end


	return TradeGui end

--]]




return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local TradeGui = {}
	local container, fader, rfs, acceptButton, cancelButton, tradeButton, acceptButtonText, myOfferTray, theirOfferTray, offerIconContainers, partyIconContainers, offerTrayRFs, partyIcons, depositInfo, errorContainer, onScreenResized
	local mouse = _p.player:GetMouse()
	local mouseDown = false
	local stepped = game:GetService("RunService").RenderStepped
	local AB_COLOR_READY = Color3.new(0.15, 0.6, 0.5)
	local AB_COLOR_DISABLED = Color3.new(0.3, 0.3, 0.3)
	local TRAY_COLOR_READY = Color3.new(0.2, 0.85, 0.7)
	local TRAY_RF_COLOR_READY = Color3.new(0.25, 1, 0.75)
	local TRAY_COLOR_NOT_READY = Color3.new(0.5, 0.5, 0.5)
	local TRAY_RF_COLOR_NOT_READY = Color3.new(0.65, 0.65, 0.65)
	local acceptState = 0
	game:GetService("UserInputService").InputEnded:connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			mouseDown = false
		end
	end)
	local summaryDebounce = false
	local function viewSummary(side, index)
		if summaryDebounce or not _p.Trade[(side == 1 and "my" or "their") .. "Party"][index] then
			return
		end
		summaryDebounce = true
		local sum = _p.Trade:sendAsync("getSummary", side, index)
		if sum then
			_p.Menu.party:viewSummary(sum, true, true)
		end
		summaryDebounce = false
	end
	local function getExtendedPokemonIcon(t)
		local icon = _p.Pokemon:getIcon(t[1], t[2])
		if t[4] then
			icon.Position = icon.Position + UDim2.new(-0.1, 0, -0.1, 0)
			local img2 = _p.Pokemon:getIcon(t[4], t[5])
			img2.SizeConstraint = Enum.SizeConstraint.RelativeYY
			img2.Size = UDim2.new(1, 0, 0.75, 0)
			img2.AnchorPoint = Vector2.new(0.5, 0.5)
			img2.Position = UDim2.new(0.6, 0, 0.6, 0)
			img2.ZIndex = 6
			img2.Parent = icon
		elseif t[6] then
			local img2 = _p.Menu.bag:getItemIcon(t[6])
			img2.SizeConstraint = Enum.SizeConstraint.RelativeYY
			img2.Size = UDim2.new(.5, 0, .5, 0)
			img2.AnchorPoint = Vector2.new(0.5, 0.5)
			img2.Position = UDim2.new(0.75, 0, 0.75, 0)
			img2.ZIndex = 7
			img2.Parent = icon
		end
		return icon
	end
	local isReady = {}
	local function setTrayReady(n, ready)
		isReady[n] = ready
		local tray = n == 1 and myOfferTray or theirOfferTray
		tray.BackgroundColor3 = ready and TRAY_COLOR_READY or TRAY_COLOR_NOT_READY
		for i = 1, 4 do
			offerTrayRFs[n][i].BackgroundColor3 = ready and TRAY_RF_COLOR_READY or TRAY_RF_COLOR_NOT_READY
		end
		if isReady[1] and isReady[2] then
			tradeButton.Visible = true
		else
			tradeButton.Visible = false
		end
		cancelButton.Visible = not tradeButton.Visible
	end
	function TradeGui:setTrayReady(...)
		setTrayReady(...)
	end
	local iconThreads = {}
	local function moveIcon(icon, parent)
		if icon.Parent == parent then
			wait(0.5)
			return
		end
		local ss, sp = icon.AbsoluteSize, icon.AbsolutePosition
		local es, ep = parent.AbsoluteSize, parent.AbsolutePosition
		icon.Parent = Utilities.gui
		local thisThread = {}
		iconThreads[icon] = thisThread
		Utilities.Tween(0.5, "easeOutCubic", function(a)
			if iconThreads[icon] ~= thisThread then
				return false
			end
			icon.Size = UDim2.new(0, ss.X + (es.X - ss.X) * a, 0, ss.Y + (es.Y - ss.Y) * a)
			icon.Position = UDim2.new(0, sp.X + (ep.X - sp.X) * a, 0, sp.Y + (ep.Y - sp.Y) * a)
		end)
		if iconThreads[icon] == thisThread then
			icon.Size = UDim2.new(1, 0, 1, 0)
			icon.Position = UDim2.new(0, 0, 0, 0)
			icon.Parent = parent
		end
	end
	local countdownThread
	local function countdown()
		acceptState = 0
		local trade = _p.Trade
		local myOffer, theirOffer = trade.myOffer, trade.theirOffer
		local myParty, theirParty = trade.myParty, trade.theirParty
		local pcount = #myParty
		for i = 1, 4 do
			if myOffer[i] then
				pcount = pcount - 1
			end
			if theirOffer[i] then
				pcount = pcount + 1
			end
		end
		depositInfo.Visible = pcount > 6
		local allEggs = true
		do
			local keep = {
				true,
				true,
				true,
				true,
				true,
				true
			}
			for i = 1, 4 do
				if theirOffer[i] and theirParty[theirOffer[i]][1] < 1450 then
					allEggs = false
					break
				elseif myOffer[i] then
					keep[myOffer[i]] = false
				end
			end
			if allEggs then
				for i, p in pairs(myParty) do
					if keep[i] and p[1] < 1450 then
						allEggs = false
						break
					end
				end
			end
		end
		if not (not allEggs and _p.Trade:isValidTrade()) or pcount <= 0 then
			acceptButton.Visible = false
			return
		end
		local thisThread = {}
		countdownThread = thisThread
		acceptButton.BackgroundColor3 = AB_COLOR_DISABLED
		acceptButton.Visible = true
		for i = 5, 1, -1 do
			acceptButtonText:ClearAllChildren()
			write(tostring(i))({Frame = acceptButtonText, Scaled = true})
			wait(1)
			if countdownThread ~= thisThread then
				return
			end
		end
		acceptButton.BackgroundColor3 = AB_COLOR_READY
		acceptButtonText:ClearAllChildren()
		write("Ready")({Frame = acceptButtonText, Scaled = true})
		acceptState = 1
	end
	function TradeGui:updatePartnerOffer(offer)
		local offerIndicesByPartyIndex = {}
		for i = 1, 4 do
			if offer[i] then
				offerIndicesByPartyIndex[offer[i]] = i
			end
		end
		for i = 1, 6 do
			local ic = partyIcons[2][i]
			if ic then
				local oi = offerIndicesByPartyIndex[i]
				Utilities.fastSpawn(moveIcon, ic, oi and offerIconContainers[2][oi] or partyIconContainers[2][i])
			end
		end
		countdown()
	end
	function TradeGui:dragIcon(pokemonIndex, x, y, prevOfferIndex)
		local icon = partyIcons[1][pokemonIndex]
		local oPos
		if Utilities.isTouchDevice() then
			local vpo = workspace.CurrentCamera.ViewportSize - Utilities.gui.AbsoluteSize
			oPos = Vector2.new(x, y - vpo.Y)
		else
			oPos = Vector2.new(mouse.X, mouse.Y)
		end
		local as, ap = icon.AbsoluteSize, icon.AbsolutePosition
		local offset = oPos - ap
		local dragging = false
		while mouseDown do
			if (Vector2.new(mouse.X, mouse.Y) - oPos).magnitude > Utilities.gui.AbsoluteSize.Y * 0.03 then
				dragging = true
				break
			end
			stepped:wait()
		end
		if not dragging then
			viewSummary(1, pokemonIndex)
			self.busy = false
			return
		end
		icon.Size = UDim2.new(0, as.X, 0, as.Y)
		icon.Parent = Utilities.gui
		while mouseDown do
			icon.Position = UDim2.new(0, mouse.X - offset.X, 0, mouse.Y - offset.Y)
			stepped:wait()
		end
		local c = icon.AbsolutePosition + as / 2
		local offerPos
		for i = 1, 4 do
			local oc = offerIconContainers[1][i]
			local l = oc.AbsolutePosition
			local h = l + oc.AbsoluteSize
			if c.X > l.X and c.X < h.X and c.Y > l.Y and c.Y < h.Y then
				offerPos = i
				break
			end
		end
		if offerPos then
			if _p.Trade.myParty[pokemonIndex][3] then
				self:error("That Pokemon cannot be traded")
				moveIcon(icon, partyIconContainers[1][pokemonIndex])
				return
			end
			self:clearError()
			if offerPos == prevOfferIndex then
				moveIcon(icon, offerIconContainers[1][offerPos])
				return
			end
			local offerAtDestination = _p.Trade.myOffer[offerPos]
			if offerAtDestination then
				Utilities.fastSpawn(moveIcon, partyIcons[1][offerAtDestination], partyIconContainers[1][offerAtDestination])
			end
			if prevOfferIndex then
				_p.Trade.myOffer[prevOfferIndex] = nil
			end
			_p.Trade.myOffer[offerPos] = pokemonIndex
			_p.Trade:updateMyOffer()
			Utilities.fastSpawn(countdown)
			_p.Trade:setReady(false)
			setTrayReady(2, false)
			moveIcon(icon, offerIconContainers[1][offerPos])
		else
			if prevOfferIndex then
				_p.Trade.myOffer[prevOfferIndex] = nil
				_p.Trade:updateMyOffer()
				Utilities.fastSpawn(countdown)
				_p.Trade:setReady(false)
				setTrayReady(2, false)
			end
			moveIcon(icon, partyIconContainers[1][pokemonIndex])
		end
	end
	function TradeGui:offerIconClicked(side, index, x, y)
		if self.busy then
			return
		end
		if side == 2 then
			if #offerIconContainers[2][index]:GetChildren() > 0 then
				local partyIndex = _p.Trade.theirOffer[index]
				if partyIndex and _p.Trade.theirParty[partyIndex] then
					viewSummary(2, partyIndex)
				end
			end
			return
		end
		local prevOffer = _p.Trade.myOffer[index]
		if not prevOffer then
			return
		end
		self.busy = true
		self:dragIcon(prevOffer, x, y, index)
		self.busy = false
	end
	function TradeGui:partyIconClicked(side, index, x, y)
		if self.busy then
			return
		end
		if side == 2 then
			if #partyIconContainers[2][index]:GetChildren() > 0 and _p.Trade.theirParty[index] then
				viewSummary(2, index)
			end
			return
		end
		if partyIcons[1][index].Parent ~= partyIconContainers[1][index] then
			return
		end
		self.busy = true
		self:dragIcon(index, x, y)
		self.busy = false
	end
	function TradeGui:onTradeClicked()
		if not (not self.trading and isReady[1]) or not isReady[2] then
			return
		end
		self.trading = true
		local tag = {}
		self.tradeLoadTag = tag
		_p.DataManager:setLoading(tag, true)
		_p.Trade:submit()
		wait(30)
		if self.tradeLoadTag == tag then
			_p.Trade:tradeFailed("timed out")
		end
	end
	function TradeGui:onAcceptClicked()
		if self.busy then
			return
		end
		if acceptState == 1 then
			if not _p.Trade:isValidTrade() then
				return
			end
			acceptState = 2
			acceptButtonText:ClearAllChildren()
			write("Cancel")({Frame = acceptButtonText, Scaled = true})
			acceptButton.BackgroundColor3 = AB_COLOR_DISABLED
			_p.Trade:setReady(true)
		elseif acceptState == 2 then
			_p.Trade:setReady(false)
			countdown()
		end
	end
	function TradeGui:open()
		if self.isOpen or self.busy then
			return
		end
		self.isOpen = true
		self.busy = true
		_p.Menu:disable()
		spawn(function()
			while self.isOpen do
				_p.Menu.pc:forceClose()
				if _p.Menu.currentMenuIndex then
					_p.Menu:closeMenu(_p.Menu.currentMenuIndex, false, -1)
				end
				wait(0.25)
			end
		end)
		if not container then
			fader = create("ImageButton")({
				AutoButtonColor = false,
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1, 0, 1, 36),
				Position = UDim2.new(0, 0, 0, -36)
			})
			container = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				create("Frame")({
					Name = "Divider",
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.new(0.25, 1, 0.75),
					ZIndex = 4
				}),
				create("Frame")({
					Name = "MyParty",
					BackgroundTransparency = 1,
					Size = UDim2.new(0.25, 0, 1, 0),
					create("Frame")({
						Name = "PlayerNameContainer",
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.06, 0),
						Position = UDim2.new(0.05, 0, 0, 0),
						ZIndex = 2
					}),
					create("Frame")({
						Name = "Container",
						BackgroundTransparency = 1,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(0.5249999999999999, 0, 0.75, 0),
						create("ImageLabel")({
							BackgroundTransparency = 1,
							Image = "rbxassetid://5295755248",
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 3
						})
					})
				}),
				create("Frame")({
					Name = "TheirParty",
					BackgroundTransparency = 1,
					Size = UDim2.new(0.25, 0, 1, 0),
					Position = UDim2.new(0.75, 0, 0, 0),
					create("Frame")({
						Name = "PlayerNameContainer",
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0.06, 0),
						Position = UDim2.new(0.95, 0, 0, 0),
						ZIndex = 2
					}),
					create("Frame")({
						Name = "Container",
						BackgroundTransparency = 1,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(0.5249999999999999, 0, 0.75, 0),
						create("ImageLabel")({
							BackgroundTransparency = 1,
							Image = "rbxassetid://5295755248",
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 3
						})
					})
				}),
				create("Frame")({
					Name = "MyOffer",
					ClipsDescendants = true,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.25, -1, 1, 0),
					Position = UDim2.new(0.25, 0, 0, 0)
				}),
				create("Frame")({
					Name = "TheirOffer",
					ClipsDescendants = true,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.25, -1, 1, 0),
					Position = UDim2.new(0.5, 1, 0, 0)
				})
			})
			rfs = {}
			myOfferTray = _p.RoundedFrame:new({
				Size = UDim2.new(0.5, 0, 0.75, 0),
				Position = UDim2.new(1, 0, 0.05, 0),
				ZIndex = 2,
				Parent = container.MyOffer
			})
			table.insert(rfs, myOfferTray)
			theirOfferTray = _p.RoundedFrame:new({
				Size = UDim2.new(0.5, 0, 0.75, 0),
				Position = UDim2.new(-0.5, 0, 0.05, 0),
				ZIndex = 2,
				Parent = container.TheirOffer
			})
			table.insert(rfs, theirOfferTray)
			offerIconContainers = {
				{},
				{}
			}
			offerTrayRFs = {
				{},
				{}
			}
			for s, tray in pairs({myOfferTray, theirOfferTray}) do
				for i = 1, 4 do
					do
						local rf = _p.RoundedFrame:new({
							Button = true,
							Size = UDim2.new(0.9, 0, 0.225, 0),
							Position = UDim2.new(0.05, 0, 0.02 + 0.245 * (i - 1), 0),
							ZIndex = 3,
							Parent = tray.gui
						})
						rf.gui.MouseButton1Down:connect(function(x, y)
							mouseDown = true
							self:offerIconClicked(s, i, x, y)
						end)
						offerTrayRFs[s][i] = rf
						table.insert(rfs, rf)
						offerIconContainers[s][i] = create("Frame")({
							BackgroundTransparency = 1,
							Size = UDim2.new(0.8333333333333333, 0, 1, 0),
							Position = UDim2.new(0.08333333333333337, 0, 0, 0),
							Parent = rf.gui
						})
					end
				end
			end
			partyIconContainers = {
				{},
				{}
			}
			do
				local positions = {
					UDim2.new(0.06285714285714286, 0, 0.068, 0),
					UDim2.new(0.5171428571428571, 0, 0.186, 0),
					UDim2.new(0.06285714285714286, 0, 0.326, 0),
					UDim2.new(0.5171428571428571, 0, 0.446, 0),
					UDim2.new(0.06285714285714286, 0, 0.588, 0),
					UDim2.new(0.5171428571428571, 0, 0.708, 0)
				}
				for s, container in pairs({
					container.MyParty.Container,
					container.TheirParty.Container
					}) do
					for i = 1, 6 do
						do
							local ic = create("ImageButton")({
								Image = "",
								BackgroundTransparency = 1,
								Size = UDim2.new(0.4228571428571429, 0, 0.222, 0),
								Position = positions[i],
								ZIndex = 3,
								Parent = container,
								MouseButton1Down = function(x, y)
									mouseDown = true
									self:partyIconClicked(s, i, x, y)
								end
							})
							partyIconContainers[s][i] = ic
						end
					end
				end
			end
			tradeButton = _p.RoundedFrame:new({
				Button = true,
				BackgroundColor3 = Color3.new(0.45, 0.6, 0.9),
				Size = UDim2.new(0.15, 0, 0.125, 0),
				Position = UDim2.new(0.425, 0, -0.1, 0),
				ZIndex = 7,
				Parent = container,
				MouseButton1Click = function()
					self:onTradeClicked()
				end
			})
			write("Trade")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.5, 0),
					Position = UDim2.new(0.5, 0, 0.25, 0),
					ZIndex = 8,
					Parent = tradeButton.gui
				}),
				Scaled = true
			})
			acceptButton = _p.RoundedFrame:new({
				Button = true,
				Size = UDim2.new(0.9, 0, 0.15, 0),
				Position = UDim2.new(0.05, 0, 1.05, 0),
				ZIndex = 3,
				Parent = myOfferTray.gui,
				MouseButton1Click = function()
					if self.busy then
						return
					end
					self:onAcceptClicked()
				end
			})
			acceptButtonText = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0.5, 0),
				Position = UDim2.new(0.5, 0, 0.25, 0),
				ZIndex = 4,
				Parent = acceptButton.gui
			})
			cancelButton = _p.RoundedFrame:new({
				Button = true,
				BackgroundColor3 = Color3.new(0.5, 0.3, 0.3),
				Size = UDim2.new(0.9, 0, 0.15, 0),
				Position = UDim2.new(0.05, 0, -0.2, 0),
				ZIndex = 3,
				Parent = theirOfferTray.gui,
				MouseButton1Click = function()
					if self.busy then
						return
					end
					self.busy = true
					if not _p.NPCChat:say("[y/n]Cancel Trade with " .. (self.tradingWith or "NULL") .. "?") then
						self.busy = false
						return
					end
					_p.Trade:exitCurrentSession()
					self:close()
					self.busy = false
				end
			})
			write("Exit")({
				Frame = create("Frame")({
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0.5, 0),
					Position = UDim2.new(0.5, 0, 0.25, 0),
					ZIndex = 4,
					Parent = cancelButton.gui
				}),
				Scaled = true
			})
			depositInfo = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0.04, 0),
				Position = UDim2.new(0.5, 0, 1.03, 0),
				ZIndex = 3,
				Parent = container
			})
			write("One or more of the received Pokemons will be sent to the PC.")({Frame = depositInfo, Scaled = true})
			errorContainer = create("Frame")({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0.04, 0),
				Position = UDim2.new(0.5, 0, 1.03, 0),
				ZIndex = 3,
				Parent = container
			})
			function onScreenResized(prop)
				if prop ~= "AbsoluteSize" then
					return
				end
				local s = Utilities.gui.AbsoluteSize
				if s.X / 2 / 6 * 5 < s.Y * 0.8 then
					container.Size = UDim2.new(1, 0, 0, s.X / 2 / 6 * 5)
					container.Position = UDim2.new(0, 0, 0.5, -container.AbsoluteSize.Y / 2)
				else
					container.Size = UDim2.new(0, s.Y * 0.8 / 5 * 6 * 2, 0.8, 0)
					container.Position = UDim2.new(0.5, -container.AbsoluteSize.X / 2, 0.1, 0)
				end
				container.MyParty.Container.Position = UDim2.new(0.5, -container.MyParty.Container.AbsoluteSize.X / 2, 0.125, 0)
				container.TheirParty.Container.Position = UDim2.new(0.5, -container.TheirParty.Container.AbsoluteSize.X / 2, 0.125, 0)
				for _, rf in pairs(rfs) do
					rf.CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.03
				end
				tradeButton.CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.02
				acceptButton.CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.02
				cancelButton.CornerRadius = Utilities.gui.AbsoluteSize.Y * 0.02
			end
			Utilities.gui.Changed:connect(onScreenResized)
		end
		setTrayReady(1, false)
		setTrayReady(2, false)
		depositInfo.Visible = false
		acceptButton.Visible = false
		container.MyParty.PlayerNameContainer:ClearAllChildren()
		container.TheirParty.PlayerNameContainer:ClearAllChildren()
		write(_p.PlayerData.trainerName)({
			Frame = container.MyParty.PlayerNameContainer,
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		write(self.tradingWith or "NULL")({
			Frame = container.TheirParty.PlayerNameContainer,
			Scaled = true,
			TextXAlignment = Enum.TextXAlignment.Right
		})
		local trade = _p.Trade
		local myParty, theirParty = trade.myParty, trade.theirParty
		partyIcons = {
			{},
			{}
		}
		for i = 1, 6 do
			partyIconContainers[1][i]:ClearAllChildren()
			partyIconContainers[2][i]:ClearAllChildren()
			if myParty and myParty[i] then
				local icon = getExtendedPokemonIcon(myParty[i])
				icon.Parent = partyIconContainers[1][i]
				partyIcons[1][i] = icon
			end
			if theirParty and theirParty[i] then
				local icon = getExtendedPokemonIcon(theirParty[i])
				icon.Parent = partyIconContainers[2][i]
				partyIcons[2][i] = icon
			end
		end
		for i = 1, 4 do
			offerIconContainers[1][i]:ClearAllChildren()
			offerIconContainers[2][i]:ClearAllChildren()
		end
		fader.Parent = Utilities.gui
		container.Parent = Utilities.gui
		onScreenResized("AbsoluteSize")
		delay(0.4, function()
			Utilities.Tween(0.8, "easeOutCubic", function(a)
				container.Divider.Size = UDim2.new(0, 2, a, 0)
				container.Divider.Position = UDim2.new(0.5, -1, 0.5 - a / 2, 0)
			end)
		end)
		Utilities.Tween(0.8, "easeOutCubic", function(a)
			fader.BackgroundTransparency = 1 - 0.3 * a
			container.MyParty.Position = UDim2.new(-0.35 * (1 - a), 0, 0, 0)
			container.TheirParty.Position = UDim2.new(1.1 - 0.35 * a, 0, 0, 0)
		end)
		Utilities.Tween(0.8, "easeOutCubic", function(a)
			myOfferTray.Position = UDim2.new(1.1 - 0.7 * a, 0, 0.05, 0)
			theirOfferTray.Position = UDim2.new(0.1 - 0.7 * (1 - a), 0, 0.2, 0)
		end)
		self.busy = false
	end
	function TradeGui:close()
		self.busy = true
		delay(0.4, function()
			Utilities.Tween(0.8, "easeOutCubic", function(a)
				a = 1 - a
				container.Divider.Size = UDim2.new(0, 2, a, 0)
				container.Divider.Position = UDim2.new(0.5, -1, 0.5 - a / 2, 0)
			end)
		end)
		Utilities.Tween(0.8, "easeOutCubic", function(a)
			a = 1 - a
			myOfferTray.Position = UDim2.new(1.1 - 0.7 * a, 0, 0.05, 0)
			theirOfferTray.Position = UDim2.new(0.1 - 0.7 * (1 - a), 0, 0.2, 0)
		end)
		Utilities.Tween(0.8, "easeOutCubic", function(a)
			a = 1 - a
			fader.BackgroundTransparency = 1 - 0.3 * a
			container.MyParty.Position = UDim2.new(-0.35 * (1 - a), 0, 0, 0)
			container.TheirParty.Position = UDim2.new(1.1 - 0.35 * a, 0, 0, 0)
		end)
		self.busy = false
		container.Parent = nil
		fader.Parent = nil
		self.isOpen = false
	end
	function TradeGui:animateTrade(myOfferIcons, theirOfferIcons, evolutions)
		self.actuallyTrading = true
		spawn(function()
			self:close()
		end)
		local bg = create("ImageButton")({
			AutoButtonColor = false,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1, 0, 1, 36),
			Position = UDim2.new(0, 0, 0, -36),
			Parent = Utilities.frontGui
		})
		Utilities.Tween(0.6, "easeOutCubic", function(a)
			bg.BackgroundTransparency = 1 - a
		end)
		local img1 = create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = "rbxassetid://5640653139",
			Size = UDim2.new(1, 0, 0.4, 0),
			Position = UDim2.new(0, 0, 0.06, 0),
			ZIndex = 2,
			Parent = Utilities.frontGui
		})
		local img2 = create("ImageLabel")({
			BackgroundTransparency = 1,
			Image = "rbxassetid://5640653139",
			Size = UDim2.new(1, 0, 0.4, 0),
			Position = UDim2.new(0, 0, 0.54, 0),
			ZIndex = 2,
			Parent = Utilities.frontGui
		})
		Utilities.Tween(0.3, "easeOutCubic", function(a)
			img1.ImageTransparency = 1 - a
			img2.ImageTransparency = 1 - a
		end)
		local pokemonContainer1 = create("Frame")({
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(-0.26666666666666666, 0, 0.2, 0)
		})
		for i, id in pairs(myOfferIcons) do
			local icon = _p.Pokemon:getIcon(id[1], id[2])
			icon.Parent = pokemonContainer1
			icon.Position = UDim2.new(-i + 1, 0, 0, 0)
		end
		local pokemonContainer2 = create("Frame")({
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0.26666666666666666, 0, 0.2, 0)
		})
		for i, id in pairs(theirOfferIcons) do
			local icon = _p.Pokemon:getIcon(id[1], id[2])
			icon.Parent = pokemonContainer2
			icon.Position = UDim2.new(i - 1, 0, 0, 0)
		end
		wait(0.2)
		pokemonContainer1.Parent = Utilities.frontGui
		pokemonContainer2.Parent = Utilities.frontGui
		Utilities.Tween(5, nil, function(a)
			pokemonContainer1.Position = UDim2.new(a, math.abs(pokemonContainer1.AbsoluteSize.X) * 4 * a, 0.16, 0)
			pokemonContainer2.Position = UDim2.new(1 - a, -pokemonContainer2.AbsoluteSize.X * 4 * a, 0.64, 0)
		end)
		pokemonContainer1:remove()
		pokemonContainer2:remove()
		Utilities.Tween(0.3, "easeOutCubic", function(a)
			img1.ImageTransparency = a
			img2.ImageTransparency = a
		end)
		img1:remove()
		img2:remove()
		Utilities.Tween(0.5, "easeOutCubic", function(a)
			bg.BackgroundTransparency = a
		end)
		self.actuallyTrading = false
		local somethingTriedEvolving = false
		if evolutions then
			for _, evo in pairs(evolutions) do
				if not somethingTriedEvolving then
					_p.Trade:exitCurrentSession()
					somethingTriedEvolving = true
				end
				_p.Pokemon:processMovesAndEvolution(evo, false)
			end
		end
		if somethingTriedEvolving then
			_p.TradeMatching:afterTrade()
		elseif self.tradePartnerQuitBetween then
			_p.NPCChat:say("The trade partner no longer wishes to trade.")
			_p.TradeMatching:afterTrade()
		else
			_p.Trade:readyToTradeAgain()
		end
		bg:remove()
	end
	local errorThread
	function TradeGui:error(txt)
		local thisThread = {}
		errorThread = thisThread
		errorContainer:ClearAllChildren()
		write(txt)({
			Frame = errorContainer,
			Scaled = true,
			Color = Color3.new(1, 0.2, 0.2)
		})
		delay(5, function()
			if thisThread ~= errorThread then
				return
			end
			errorContainer:ClearAllChildren()
		end)
	end

	function TradeGui:clearError()
		errorThread = nil
		errorContainer:ClearAllChildren()
	end
	return TradeGui
end
