return function(_p)--local _p = require(script.Parent)
	local Utilities = _p.Utilities

	local network = _p.Network

	local Trade = {
		myOffer = {},
		theirOffer = {},
	}

	function Trade:init()
		self.gui = _p.TradeGui
	end

	function Trade:createSession()
		if self.sessionId then return end
		self.sessionId = self:sendAsync('newSession')
	end

	function Trade:joinSession(id)
		if self.sessionId then return end
		self.sessionId = id
		self:send('join')
	end

	function Trade:start(theirName, myParty, theirParty)
		self.myOffer = {}
		self.theirOffer = {}
		self.myParty = myParty
		self.theirParty = theirParty
		self.gui.tradingWith = theirName
		self.gui:open()
	end

	function Trade:restart(myParty, theirParty)
		if not self.restartTag then return end
		_p.DataManager:setLoading(self.restartTag, false)
		self.restartTag = nil
		self.myOffer = {}
		self.theirOffer = {}
		self.myParty = myParty
		self.theirParty = theirParty
		self.gui:open()
	end

	function Trade:isValidTrade()
		for i = 1, 4 do
			if self.myOffer[i] or self.theirOffer[i] then
				return true
			end
		end
		return false
	end

	function Trade:setReady(amReady)
		self:send('ready', amReady)
		self.gui:setTrayReady(1, amReady)
	end

	function Trade:setPartnerReady(isReady)
		self.gui:setTrayReady(2, isReady)
	end

	local function compileOffer(theOffer)
		local offer = ''
		for i = 1, 4 do
			offer = offer .. (theOffer[i] or '_')
		end
		return offer
	end

	function Trade:submit()
		self:send('trade', compileOffer(self.myOffer), compileOffer(self.theirOffer))
	end

	function Trade:updateMyOffer()
		self:send('offer', compileOffer(self.myOffer))
	end
	
	function Trade:partnerOfferUpdated(newOffer)
		local offer = {}
		for i = 1, 4 do
			local n = tonumber(newOffer:sub(i, i))
			if n then
				offer[i] = n
			end
		end
		self.theirOffer = offer
		self.gui:updatePartnerOffer(offer)
	end

	function Trade:getEtc(officialMyOffer, officialTheirOffer)
		if officialMyOffer ~= compileOffer(self.myOffer) or officialTheirOffer ~= compileOffer(self.theirOffer) then return false end
		return _p.PlayerData:getEtc()
	end

	function Trade:animateTrade(...)
		if self.gui.tradeLoadTag then
			_p.DataManager:setLoading(self.gui.tradeLoadTag, false)
			self.gui.tradeLoadTag = nil
		end
		self.gui:animateTrade(...)
		self.gui.trading = false
	end

	function Trade:readyToTradeAgain()
		local tag = {}
		self.restartTag = tag
		_p.DataManager:setLoading(tag, true)
		self:send('readyToTradeAgain')
		local st = tick()
		while self.restartTag do
			if tick() - st > 30 then
				_p.DataManager:setLoading(tag, false)
				self.restartTag = nil
				self:exitCurrentSession()
				break
			end
			wait()
		end
	end
	
	function Trade:tradeFailed(reason)
		if self.gui.tradeLoadTag then
			_p.DataManager:setLoading(self.gui.tradeLoadTag, false)
			self.gui.tradeLoadTag = nil
			self.gui.trading = false
		end
		self.gui:setTrayReady(1, false)
		self.gui:setTrayReady(2, false)
		self.gui:error(string.format('Trade failed (%s)', reason or 'unknown error'))
	end

	function Trade:exitCurrentSession()
		self:send('leave')

		self.sessionId = nil

		delay(1.2, function()
			_p.TradeMatching:afterTrade()
		end)
	end

	function Trade:partnerCanceled(leftGame)
		if self.gui.actuallyTrading then
			self.gui.tradePartnerQuitBetween = true
			return
		end

		if self.restartTag then
			_p.DataManager:setLoading(self.restartTag, false)
			self.restartTag = nil
		end

		self.gui.busy = true
		local partnerName = self.gui.tradingWith or 'The trade partner'
		if leftGame then
			_p.NPCChat:say(partnerName .. ' left the game.', 'The trade has been canceled.')
		else
			_p.NPCChat:say(partnerName .. ' canceled the trade.')
		end
		self.gui:close()
		self.gui.busy = false

		self.sessionId = nil

		delay(1.2, function()
			_p.TradeMatching:afterTrade()
		end)
	end

	function Trade:sendAsync(...)
		return network:get('TradeFunction', self.sessionId, ...)
	end

	function Trade:send(...)
		network:post('TradeEvent', self.sessionId, ...)
	end

	network:bindFunction('TradeFunction', function(sessionId, fnName, ...)
		if sessionId ~= Trade.sessionId then return end

		if not Trade[fnName] then
			if _p.debug then
				warn('Trade Client received bad invoke-request ('..tostring(fnName)..')')
			end
			return
		end

		return Trade[fnName](Trade, ...)
	end)

	network:bindEvent('TradeEvent', function(sessionId, fnName, ...)
		if sessionId ~= Trade.sessionId then return end

		if not Trade[fnName] then
			if _p.debug then
				warn('Trade Client received bad request ('..tostring(fnName)..')')
			end
			return
		end

		Trade[fnName](Trade, ...)
	end)



	return Trade end