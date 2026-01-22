return function(_p)--local _p = require(script.Parent)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write

	local tradeRQgui, rqListGui, rqButton, globalError
	local network = _p.Network
	--local event = _p.storage.Remote.TradeRequest
	local accepting
	local errorThread
	local settings = {}
	local requests = {}

	local tradingplayers = {}

	local trade = {
		updateBadgeNumber = function() end,
	}

	-- TODO: attempt to accept a trade request while the sending player is busy
	--  -> wheel spins, menu disappears, nothing happens [verify each]

	--old trade init	
--[[
function trade:init()
	network:bindEvent('TradeRequest', function(from, request)
		if request.error then
			if from == accepting.from then
				if accepting and accepting.loadTag then
					accepting.failed = true
					_p.DataManager:setLoading(accepting.loadTag, false)
				end
				accepting = nil
			end
			spawn(function() _p.Menu:enable() end)
			self:error(request.error, rqListGui.gui.ErrorText)
		elseif request.accepted then
			self:onRequestAccepted(from, request)
		elseif request.joinTrade then
			if accepting and accepting.loadTag then
				accepting.completed = true
				_p.DataManager:setLoading(accepting.loadTag, false)
			end
			accepting = nil
			self:beforeTrade()
--			Utilities.print_r(request)
--			_p.Trade.gui.tradingWith = request.
			_p.Trade:joinSession(request.joinTrade)
--			self:afterTrade()
		else
			self:receivedRequest(from, request)
		end
	end)
end
	--]]
	--- Called when the trade module is initialized.
	function trade:init()
		-- Binds the "TradeRequest" event from the Network module. When this event is fired, this anonymous function will be called.
		network:bindEvent("TradeRequest", function(from, request)
			-- If the request has an error message, display the error message and enable the menu.
			if request.error then
				if from == accepting.from then
					-- If the request is from the player that was accepting a trade, set the acceptance status to "failed" and stop the loading animation.
					if accepting and accepting.loadTag then
						accepting.failed = true
						_p.DataManager:setLoading(accepting.loadTag, false)
					end
					accepting = nil
				end
				spawn(function() _p.Menu:enable() end)
				self:error(request.error, rqListGui.gui.ErrorText)
				-- If the request has been accepted, call the "onRequestAccepted" function.
			elseif request.accepted then
				self:onRequestAccepted(from, request)
				-- If the request contains a "joinTrade" field, call the "beforeTrade" function and join the trade session.
			elseif request.joinTrade then
				if accepting and accepting.loadTag then
					accepting.completed = true
					_p.DataManager:setLoading(accepting.loadTag, false)
				end
				accepting = nil
				self:beforeTrade()
				_p.Trade:joinSession(request.joinTrade)
			else
				self:receivedRequest(from, request)
			end
		end)
	end

	function trade:beforeTrade()
		-- disable the ability to walk and stop the player's movement
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()

		-- store the current state of the player list, then disable it
		self.playerListWasEnabled = _p.PlayerList.enabled
		_p.PlayerList:disable()

		-- update the title to show that the player is trading
		network:post('UpdateTitle', 'Trading')

		-- set the "busy" flag to true
		self.busy = true

		-- try to remove the request list GUI and hide the request button
		pcall(function() rqListGui.Parent = nil end)
		pcall(function() rqButton.Visible = false end)
	end

	function trade:afterTrade()
		-- Enable player list if it was enabled before the trade started
		if self.playerListWasEnabled then _p.PlayerList:enable() end

		-- Reset the player's title
		network:post('UpdateTitle')

		-- Set busy status to false
		self.busy = false

		-- Make the request button visible again
		pcall(function() rqButton.Visible = true end)

		-- Re-enable character movement
		_p.MasterControl.WalkEnabled = true

		-- Re-enable the menu
		_p.Menu:enable()
	end

	function trade:enableRequestMenu()
		globalError = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.05, 0),
			Position = UDim2.new(0.5, 0, 0.9, 0),
			Parent = Utilities.backGui,
		}
		local rq = _p.RoundedFrame:new {
			Button = true,
			--		CornerRadius = 5,
			BackgroundColor3 = Color3.new(0, .64, 1),
			Size = UDim2.new(.2, 0, .075, 0),
			Position = UDim2.new(.775, 0, .9, 0),
			Parent = Utilities.backGui,
			MouseButton1Click = function()
				self:viewRequests()
			end,
		}
		write'Requests' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.7, 0),
				Position = UDim2.new(0.5, 0, 0.15, 0),
				ZIndex = 2, Parent = rq.gui,
			}, Scaled = true,
		}
		local badgeIcon = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxasset://textures/WhiteCircle.png',
			ImageColor3 = Color3.new(1, .2, .2),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(-0.8, 0, 0.8, 0),
			Position = UDim2.new(0.1, 0, -0.25, 0),
			Visible = false,
			ZIndex = 3, Parent = rq.gui,
		}
		local badgeText = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.8, 0),
			Position = UDim2.new(0.5, 0, 0.1, 0),
			ZIndex = 4, Parent = badgeIcon,
		}
		function self:updateBadgeNumber(n)
			badgeText:ClearAllChildren()
			if n == 0 then
				badgeIcon.Visible = false
				return
			end
			badgeIcon.Visible = true
			write(tostring(n)) {
				Frame = badgeText,
				Scaled = true,
			}
		end
		rqButton = rq
		self:updateBadgeNumber(#requests)
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
		}
	end
	do
		local gui
		function trade:updateRequests()
			for i = #requests, 1, -1 do
				if requests[i].expired then
					table.remove(requests, i)
				end
			end
			if gui and gui.Parent then--and gui.Visible then
				local list = gui.gui.List
				local container = list.Container
				local ht = 0.05
				local contentRelativeSize = #requests*ht*container.AbsoluteSize.X/list.AbsoluteSize.Y
				list.CanvasSize = UDim2.new(list.Size.X.Scale, -1, contentRelativeSize * list.Size.Y.Scale, 0)
				container:ClearAllChildren()
				for i, request in pairs(requests) do
					local cell = tableCell()
					if i%2 == 1 then
						cell.BackgroundColor3 = Color3.new(0, .48, .75)
					else
						cell.BackgroundTransparency = 1.0
					end
					cell.Size = UDim2.new(1.0, 0, ht, 0)
					cell.Position = UDim2.new(0.0, 0, ht*(i-1), 0)
					cell.Parent = container
					write(request.fromName) {
						Frame = cell.PlayerName,
						Scaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
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
							if accepting or not _p.Menu.enabled then return end
							self:acceptRequest(request)
						end,
					}
					write 'Accept' {
						Frame = create 'Frame' {
							BackgroundTransparency = 1.0,
							Size = UDim2.new(0.0, 0, 0.8, 0),
							Position = UDim2.new(0.5, 0, 0.1, 0),
							ZIndex = 4, Parent = button,
						},
						Scaled = true,
					}
				end
			else
				local n = 0
				for _, r in pairs(requests) do
					if r.new then
						n = n + 1
					end
				end
				self:updateBadgeNumber(n)
			end
		end

		function trade:viewRequests()
			if not gui then
				gui = _p.RoundedFrame:new {
					BackgroundColor3 = Color3.new(0, .64, 1),
					Size = UDim2.new(.6, 0, .7, 0),
					Parent = Utilities.backGui,

					create 'ScrollingFrame' {
						Name = 'List',
						--					BackgroundTransparency = 1.0,
						BackgroundColor3 = BrickColor.new('Deep blue').Color,
						BorderSizePixel = 0,
						Size = UDim2.new(0.9, 0, 0.7, 0),
						Position = UDim2.new(0.05, 0, 0.2, 0),
						ZIndex = 2,

						create 'Frame' {
							Name = 'Container',
							BackgroundTransparency = 1.0,
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
						}
					},
					create 'Frame' {
						Name = 'ErrorText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.05, 0),
						Position = UDim2.new(0.5, 0, 0.925, 0),
						ZIndex = 2,
					}
				}
				write 'Trade Requests' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.08, 0),
						Position = UDim2.new(0.5, 0, 0.01, 0),
						ZIndex = 2, Parent = gui.gui,
					}, Scaled = true,
				}
				local header = tableCell()
				--			header.BackgroundTransparency = 1.0
				header.BackgroundColor3 = BrickColor.new('Navy blue').Color
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
				write 'From' {
					Frame = header.PlayerName,
					Scaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}
				rqListGui = gui
			elseif gui.Parent then
				gui.Parent = nil
				return
			end
			if tradeRQgui then tradeRQgui.Parent = nil end
			for _, r in pairs(requests) do
				r.new = false
			end
			self:updateBadgeNumber(0)
			gui.Parent = Utilities.backGui
			self:updateRequests()
			--		gui.Visible = true
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				gui.Position = UDim2.new(.2, 0, .15-(1-a), 0)
			end)
		end

		function trade:acceptRequest(request)
			if request.expired then
				self:updateRequests()
				self:error('This request has expired', gui.gui.ErrorText)
				return
			end
			if not request.from or not request.from.Parent then
				request.expired = true
				self:updateRequests()
				self:error('Trade partner has left the game', gui.gui.ErrorText)
				return
			end

			spawn(function() _p.Menu:disable() end)
			accepting = request
			request.accepted = true
			local tag = {}
			_p.DataManager:setLoading(tag, true)
			network:post('TradeRequest', request.from, request)
			request.loadTag = tag
			wait(15)
			if not request.completed and not request.failed then
				accepting = nil
				_p.DataManager:setLoading(tag, false)
				self:error('Trade partner not ready', gui.gui.ErrorText)
				_p.Menu:enable()
			end
		end
	end

	function trade:onRequestAccepted(partner, request)
		if self.busy or (_p.NPCChat.chatBox and _p.NPCChat.chatBox.Parent) or not _p.Menu.enabled then
			request.error = 'Player is busy'
			network:post('TradeRequest', partner, request)
			return
		end
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		spawn(function() _p.Menu:disable() end)
		if not _p.NPCChat:say(partner.Name .. ' accepted your trade request.', '[y/n]Are you ready to trade?') then
			request.error = 'The trade partner canceled the trade'
			network:post('TradeRequest', partner, request)
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()

			_p.Menu:enable()
			return
		end
		if not partner or not partner.Parent then
			self:error('The trade partner left the game')
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()

			_p.Menu:enable()
			return
		end
		request.pseudoHost = true
		request.partner = partner
		self:beforeTrade()
		_p.Trade:createSession()
		network:post('TradeRequest', partner, {joinTrade = _p.Trade.sessionId})
		--	self:afterTrade()
	end

	-- This function is a part of the trade object, and is used to handle incoming trade requests.
	-- It first looks for any existing requests from the same player from, and removes them if found.
	-- It then creates a new request table with the sender's information, and marks it as new.
	-- A delay is created to mark the request as expired after 60 seconds.
	-- Finally, the function updates the request list to reflect the new request.
	function trade:receivedRequest(from, request)
		-- Iterate through the list of requests in reverse order
		for i = #requests, 1, -1 do
			-- If the request is from the same player, remove it from the list
			if requests[i].from == from then
				table.remove(requests, i)
			end
		end
		-- Add the sender's information to the new request table
		request.from = from
		request.fromName = from.Name
		-- Mark the request as new
		request.new = true
		-- Insert the new request into the list
		table.insert(requests, request)
		-- Set a delay to mark the request as expired after 60 seconds
		delay(60, function()
			request.expired = true
			self:updateRequests()
		end)
		-- Update the request list to reflect the new request
		self:updateRequests()
	end
	
	-- This function displays an error message in the GUI
	function trade:error(txt)
		-- If the tradeRQgui variable is not set, return and do nothing
		if not tradeRQgui then return end
		-- Set the `frame` variable to the `globalError` frame
		local frame = globalError
		-- Clear all children of the `frame`
		frame:ClearAllChildren()
		-- Create a local table called `thisThread`
		local thisThread = {}
		-- Set the global `errorThread` variable to `thisThread`
		errorThread = thisThread
		-- Use the `write` function to add text to the `frame` with the specified color and scaling
		write(txt) {
			Frame = frame,
			Color = Color3.new(1, .2, .2),
			Scaled = true,
		}
		-- Wait for 3 seconds
		wait(3)
		-- If the global `errorThread` variable is still equal to `thisThread`, clear all children of the `frame`
		if errorThread == thisThread then
			frame:ClearAllChildren()
		end
	end

	-- This function is used to send a trade request to the selected player
	function trade:sendRequest()
		-- If there is no selected player, then display an error message
		if not settings.targetPlayer then self:error('No trade partner selected') return end
		-- If the selected player is not in the game, then display an error message
		if not settings.targetPlayer.Parent then self:error('Selected player has left the resort') return end
		-- Add the name of the selected player to the tradingplayers table
		-- Send a 'TradeRequest' message to the selected player with the specified settings
		network:post('TradeRequest', settings.targetPlayer, settings)
		-- Return true
		return true
	end

	function trade:onClickedPlayer(player)
		if rqListGui then rqListGui.Parent = nil end
		settings.targetPlayer = player
		if not tradeRQgui then
			tradeRQgui = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(0, .64, 1),
				Size = UDim2.new(.4, 0, .4, 0),
				Parent = Utilities.backGui,

				create 'Frame' {
					Name = 'PartnerText',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.2, 0),
					Position = UDim2.new(0.5, 0, 0.4, 0),
					ZIndex = 2,
				},
			}
			write 'Trade With' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.2, 0),
					Position = UDim2.new(0.5, 0, 0.1, 0),
					ZIndex = 2, Parent = tradeRQgui.gui,
				}, Scaled = true,
			}

			local cancel = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(0, .48, .75),
				Size = UDim2.new(.35, 0, .2, 0),
				Position = UDim2.new(0.1, 0, 0.75, 0),
				ZIndex = 2, Parent = tradeRQgui.gui,
				MouseButton1Click = function()
					tradeRQgui.Parent = nil
				end,
			}
			local send = _p.RoundedFrame:new {
				Button = true,
				BackgroundColor3 = Color3.new(0, .48, .75),
				Size = UDim2.new(.35, 0, .2, 0),
				Position = UDim2.new(0.55, 0, 0.75, 0),
				ZIndex = 2, Parent = tradeRQgui.gui,
				MouseButton1Click = function()
					if self:sendRequest() then
						tradeRQgui.Parent = nil
					end
				end,
			}
			write 'Cancel' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.7, 0),
					Position = UDim2.new(0.5, 0, 0.15, 0),
					ZIndex = 3, Parent = cancel.gui,
				}, Scaled = true,
			}
			write 'Send' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.7, 0),
					Position = UDim2.new(0.5, 0, 0.15, 0),
					ZIndex = 3, Parent = send.gui,
				}, Scaled = true,
			}
			local function cr()
				tradeRQgui.CornerRadius = Utilities.gui.AbsoluteSize.Y*.04
				cancel.CornerRadius = Utilities.gui.AbsoluteSize.Y*.03
				send.CornerRadius = Utilities.gui.AbsoluteSize.Y*.03
			end
			Utilities.gui.Changed:connect(cr)
			cr()
			tradeRQgui.Parent = nil
		end
		local gui = tradeRQgui.gui
		gui.PartnerText:ClearAllChildren()
		write((player and player.Name or 'NULL') .. '?') {
			Frame = gui.PartnerText,
			Scaled = true,
		}
		if not tradeRQgui.Parent then
			tradeRQgui.Parent = Utilities.backGui
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				tradeRQgui.Position = UDim2.new(.3, 0, .3-(1-a), 0)
			end)
		end
	end

	return trade end