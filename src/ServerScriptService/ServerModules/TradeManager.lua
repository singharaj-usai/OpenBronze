local _f = require(script.Parent)
local Utilities = _f.Utilities
local network = _f.Network

local tradeHistoryStore = _f.safelyGetDataStore('TradeHistory')--game:GetService('DataStoreService'):GetDataStore('TradeHistory')

local Trades = {}
local TradeManager = Utilities.class({
	className = 'TradeManager',
	publicEvents = {
		join  = true,
		leave = true,
		offer = true,
		ready = true,
		trade = true,
		readyToTradeAgain = true,
	},
	publicFunctions = {
		getSummary = true,
		newSession = true,
	},

	lockedIn = false
}, function(self)
	local id = Utilities.uid()
	self.id = id
	Trades[id] = self

	return self
end)


function TradeManager:logTrade(playerId, partnerId, playerOffer, partnerOffer)
	spawn(function()
		tradeHistoryStore:UpdateAsync(tostring(playerId), function(data)
			data = data or {}
			table.insert(data, {os.time(), partnerId, playerOffer, partnerOffer})
			return data
		end)
	end)
end

function TradeManager:playerIsInTrade(player)
	for _, trade in pairs(Trades) do
		if trade.p1 == player or trade.p2 == player then
			return true
		end
	end
	return false
end

function TradeManager:cleanupTradeState()
	self.p1summaryCache = nil
	self.p2summaryCache = nil
	self.p1ready = false
	self.p2ready = false
	self.p1trade = nil
	self.p2trade = nil
	self.p1offer = nil
	self.p2offer = nil
	self.p1readyForNext = nil
	self.p2readyForNext = nil
	self.lockedIn = false
end

function TradeManager:join(p2)
	if not p2 or p2.UserId < 1 -- do not allow guests to join trades
		or self.p2 or p2 == self.p1 then return end
	self.p2 = p2
	self.p2id = p2.UserId
	self.p2playerData = _f.PlayerDataService[p2]

	local p1icons, p1ps = self.p1playerData:getPartyDataForTrade()
	local p2icons, p2ps = self.p2playerData:getPartyDataForTrade()
	self.p1partySerialized = p1ps -- compared when trade is confirmed to verify no tampering has taken place
	self.p2partySerialized = p2ps

	self:send(self.p1, 'start', p2.Name,      p1icons, p2icons)
	self:send(self.p2, 'start', self.p1.Name, p2icons, p1icons)
end

function TradeManager:leave(p)
	if p == self.p1 then
		self:send(self.p2, 'partnerCanceled')
		--self:cleanupTradeState()
		self:remove()
	elseif p == self.p2 then
		self:send(self.p1, 'partnerCanceled')
		--self:cleanupTradeState()
		self:remove()
	end
end

function TradeManager:getSummary(player, ownerSide, index)
	if (ownerSide ~= 1 and ownerSide ~= 2) or type(index) ~= 'number' then return end
	local requesterSide = 1
	if player == self.p2 then
		ownerSide = 3-ownerSide
		requesterSide = 2
	end
	-- try to return cached summary
	local cache = self['p'..ownerSide..'summaryCache']
	if cache and cache[index] then
		return cache[index][requesterSide]
	end
	-- hasn't been cached, get it
	local serializedPokemon = self['p'..ownerSide..'partySerialized'][index]
	if not serializedPokemon then return end
	if not cache then
		cache = {}
		self['p'..ownerSide..'summaryCache'] = cache
	end
	local tempPokemon = _f.ServerP:deserialize(serializedPokemon, self['p'..ownerSide..'playerData'])
	local ownerSummary = tempPokemon:getSummary{}
	tempPokemon.nickname = nil -- hide nicknames from other player in trades
	local otherSummary = tempPokemon:getSummary{
		[self['p'..(3-ownerSide)..'playerData']:ownsGamePass('StatViewer', true) -- show full stats according to who is requesting
		and 'forceShowStats' or 'forceHideStats'] = true}
	tempPokemon:remove()
	local summaries = (ownerSide==1) and {ownerSummary, otherSummary} or {otherSummary, ownerSummary}
	cache[index] = summaries
	return summaries[requesterSide]
end

function TradeManager:offer(p, offer)
	if p == self.p1 then
		self.p1offer = offer
		self:send(self.p2, 'partnerOfferUpdated', offer)
	elseif p == self.p2 then
		self.p2offer = offer
		self:send(self.p1, 'partnerOfferUpdated', offer)
	else
		return
	end
	self.p1ready = false
	self.p2ready = false
	self.p1trade = nil
	self.p2trade = nil
end

function TradeManager:ready(p, isReady)
	if p == self.p1 then
		self.p1ready = isReady
		self:send(self.p2, 'setPartnerReady', isReady)
	elseif p == self.p2 then
		self.p2ready = isReady
		self:send(self.p1, 'setPartnerReady', isReady)
	else
		return
	end
	if not isReady then
		self.p1trade = nil
		self.p2trade = nil
	end
end

function TradeManager:trade(player, playerOffer, partnerOffer)
	if player == self.p1 then
		self.p1trade = {playerOffer, partnerOffer}
	elseif player == self.p2 then
		self.p2trade = {partnerOffer, playerOffer}
	end
	if self.p1trade and self.p2trade then
		-- prevent ourselves from performing the trade twice
		local p1trade, p2trade = self.p1trade, self.p2trade
		self.p1trade, self.p2trade = nil, nil
		-- ensure party data has not changed since start/restart
		local match = true
		local p1psThen = self.p1partySerialized
		local p2psThen = self.p2partySerialized
		local p1icons, p1psNow = self.p1playerData:getPartyDataForTrade()
		local p2icons, p2psNow = self.p2playerData:getPartyDataForTrade()
		if #p1psThen ~= #p1psNow or #p2psThen ~= #p2psNow then
			print('a party changed [size]')
			match = false
		end
		for i, sd in pairs(p1psThen) do
			if sd ~= p1psNow[i] then
				print('party 1 changed')
				match = false
				break
			end
		end
		for i, sd in pairs(p2psThen) do
			if sd ~= p2psNow[i] then
				print('party 2 changed')
				match = false
				break
			end
		end
		if not match then
			self:sendBoth('tradeFailed', 'player data tampered')
			return
		end
		-- ensure offers match and contain no duplicate indices
		if p1trade[1] ~= p2trade[1] or p1trade[2] ~= p2trade[2] then
			print('mismatch in offers')
			match = false
		end
		local p1AlreadyOffered = {}
		local p2AlreadyOffered = {}
		local p1officialOffer = {}
		local p2officialOffer = {}
		local p1serOffer = {}
		local p2serOffer = {}
		local p1icoOffer = {}
		local p2icoOffer = {}
		for i = 1, 4 do
			local p1offerI = p1trade[1]:sub(i,i)
			if p1offerI ~= '_' then
				local p1offerN = tonumber(p1offerI)
				if not p1psNow[p1offerN] then
					print('offer contains null pokemon')
					self:sendBoth('tradeFailed', 'trade invalid')
					return
				end
				if p1AlreadyOffered[p1offerI] then
					print('offer contains dupe')
					self:sendBoth('tradeFailed', 'trade invalid')
					return
				end
				p1AlreadyOffered[p1offerI] = true
				p1officialOffer[i] = p1offerN
				p1serOffer[tostring(i)] = p1psThen[p1offerN]
				p1icoOffer[#p1icoOffer+1] = p1icons[p1offerN]
			end
			local p2offerI = p2trade[2]:sub(i,i)
			if p2offerI ~= '_' then
				local p2offerN = tonumber(p2offerI)
				if not p2psNow[p2offerN] then
					print('offer contains null pokemon')
					self:sendBoth('tradeFailed', 'trade invalid')
					return
				end
				if p2AlreadyOffered[p2offerI] then
					print('offer contains dupe')
					self:sendBoth('tradeFailed', 'trade invalid')
					return
				end
				p2AlreadyOffered[p2offerI] = true
				p2officialOffer[i] = p2offerN
				p2serOffer[tostring(i)] = p2psThen[p2offerN]
				p2icoOffer[#p2icoOffer+1] = p2icons[p2offerN]
			end
		end
		if not match then
			self:sendBoth('tradeFailed', 'client offer mismatch')
			return
		end
		-- get each player's "etc" data for saving
		local p1etc, p2etc
		local timedOut, completed = false, false
		delay(30, function()
			if completed then return end
			timedOut = true
			self:sendBoth('tradeFailed', 'communication timed out')
		end)
		Utilities.Sync {
			function() p1etc = self:sendAsync(self.p1, 'getEtc', p1trade[1], p1trade[2]) end,
			function() p2etc = self:sendAsync(self.p2, 'getEtc', p2trade[2], p2trade[1]) end
		}
		if timedOut then return end
		completed = true
		if not p1etc or not p2etc then
			self:sendBoth('tradeFailed', 'communication error')
			return
		end
		-- update player data
		local success
		local p1data, p1pc, p1evo
		success = pcall(function()
			p1data, p1pc, p1evo = self.p1playerData:performTrade(p1officialOffer, p2officialOffer, p1etc, p2psThen)
		end)
		if not success then
			print('error performing trade on p1 data')
			self.p1playerData:cancelTrade()
			self:sendBoth('tradeFailed', 'unknown error')
			return
		end
		local p2data, p2pc, p2evo
		success = pcall(function()
			p2data, p2pc, p2evo = self.p2playerData:performTrade(p2officialOffer, p1officialOffer, p2etc, p1psThen)
		end)
		if not success then
			print('error performing trade on p2 data')
			self.p1playerData:cancelTrade()
			self.p2playerData:cancelTrade()
			self:sendBoth('tradeFailed', 'unknown error')
			return
		end
		-- save updated data
		for i = 1, 3 do
			success = _f.DataPersistence.SaveData(self.p1, p1data, p1pc)
			if success then break end
			wait(.1)
		end
		if not success then
			self.p1playerData:cancelTrade()
			self.p2playerData:cancelTrade()
			self:sendBoth('tradeFailed', 'datastore error')
			return
		end
		for i = 1, 3 do
			success = _f.DataPersistence.SaveData(self.p2, p2data, p2pc)
			if success then break end
			wait(.1)
		end
		if not success then
			-- aw snap, p1 saved but p2 failed ._.
			warn('Trade: Player1 save succeeded but Player2 save failed.', os.time())
			self.p1playerData:cancelTrade() -- even though this is a rare case, we really should try to re-save the p1 old data
			self.p2playerData:cancelTrade()
			self:sendBoth('tradeFailed', 'datastore error')
			return
		end
		self.lockedIn = true
		self:send(self.p1, 'animateTrade', p1icoOffer, p2icoOffer, p1evo) -- todo: evolution data
		self:send(self.p2, 'animateTrade', p2icoOffer, p1icoOffer, p2evo)
		self:logTrade(self.p1id, self.p2id, p1serOffer, p2serOffer)
		self:logTrade(self.p2id, self.p1id, p2serOffer, p1serOffer)

		local p1name = game.Players:GetNameFromUserIdAsync(self.p1id)
		local p2name = game.Players:GetNameFromUserIdAsync(self.p2id)
		local p1pokenames = ''
		local p2pokenames = ''
		local p1playerdata = _f.PlayerDataService[game:GetService('Players')[p1name]]
		local p2playerdata = _f.PlayerDataService[game:GetService('Players')[p1name]]
		for i,pokemon in pairs(p1serOffer) do
			local deserializepokemon = _f.ServerP:deserialize(pokemon, p1playerdata)
			if p1pokenames == '' then
				p1pokenames = p1pokenames..deserializepokemon.name..'(Shiny: '..tostring(deserializepokemon.shiny)..', HA: '..tostring(deserializepokemon.hiddenAbility)..', Level: '..deserializepokemon.level..')'
			else
				p1pokenames = p1pokenames..', '..deserializepokemon.name..'(Shiny: '..tostring(deserializepokemon.shiny)..', HA: '..tostring(deserializepokemon.hiddenAbility)..', Level: '..deserializepokemon.level..')'
			end
		end
		for i,pokemon in pairs(p2serOffer) do
			local deserializepokemon = _f.ServerP:deserialize(pokemon, p2playerdata)
			if p2pokenames == '' then
				p2pokenames = p2pokenames..deserializepokemon.name..'(Shiny: '..tostring(deserializepokemon.shiny)..', HA: '..tostring(deserializepokemon.hiddenAbility)..', Level: '..deserializepokemon.level..')'
			else
				p2pokenames = p2pokenames..', '..deserializepokemon.name..'(Shiny: '..tostring(deserializepokemon.shiny)..', HA: '..tostring(deserializepokemon.hiddenAbility)..', Level: '..deserializepokemon.level..')'
			end
		end
		_f.Network:postToDiscord('Trade Logger', '```'..p1name..'('..self.p1id..') traded '..p1pokenames..' for '..p2name..'('..self.p2id..') '..p2pokenames..'```')

	end
end

function TradeManager:readyToTradeAgain(p)
	if p == self.p1 then
		self.p1readyForNext = true
	elseif p == self.p2 then
		self.p2readyForNext = true
	end

	if self.p1readyForNext and self.p2readyForNext then
		-- Clean up all trade states first
		--self:cleanupTradeState()
		self.p1summaryCache = nil
		self.p2summaryCache = nil
		-- Get new party data
		local p1icons, p1ps = self.p1playerData:getPartyDataForTrade()
		local p2icons, p2ps = self.p2playerData:getPartyDataForTrade()
		self.p1partySerialized = p1ps
		self.p2partySerialized = p2ps

		self:send(self.p1, 'restart', p1icons, p2icons)
		self:send(self.p2, 'restart', p2icons, p1icons)
		self.p1readyForNext = nil
		self.p2readyForNext = nil
		self.p1ready = false
		self.p2ready = false
		self.p1trade = nil
		self.p2trade = nil
		self.p1offer = nil
		self.p2offer = nil
		self.lockedIn = false
	end
end

--[[function TradeManager:silentUndoPartner(p)
--	if self.lockedIn then return end
	if p == self.p1 then
		self:send(self.p2, 'silentUndo')
	elseif p == self.p2 then
		self:send(self.p1, 'silentUndo')
	end
end]]

function TradeManager:sendAsync(player, ...)
	return network:get('TradeFunction', player, self.id, ...)
end

function TradeManager:send(player, ...)
	network:post('TradeEvent', player, self.id, ...)
end

function TradeManager:sendBoth(...)
	network:post('TradeEvent', self.p1, self.id, ...)
	network:post('TradeEvent', self.p2, self.id, ...)
end

function TradeManager:remove()
	Trades[self.id] = nil
	self.p1playerData = nil
	self.p2playerData = nil
	-- anything else to do...?
end

network:bindFunction('TradeFunction', function(player, id, fnName, ...)
	if not TradeManager.publicFunctions[fnName] then return end
	if fnName == 'newSession' then
		if player.UserId < 1 then return end -- do not allow guests to create trades
		local trade = TradeManager:new()
		trade.p1 = player
		trade.p1id = player.UserId
		trade.p1playerData = _f.PlayerDataService[player]
		return trade.id
	end
	local trade = Trades[id]
	if type(trade[fnName]) ~= 'function' then
		warn('Trade Manager received request:', fnName, '(invalid)') -- useless with public addition
		return
	end
	return trade[fnName](trade, player, ...)
end)
network:bindEvent('TradeEvent', function(player, id, fnName, ...)
	if not TradeManager.publicEvents[fnName] then return end
	local trade = Trades[id]
	if not trade then print(id, fnName, ...) end
	if type(trade[fnName]) ~= 'function' then
		warn('Trade Manager received event:', fnName, '(invalid)') -- useless with public addition
		return
	end
	trade[fnName](trade, player, ...)
end)

game:GetService('Players').ChildRemoved:connect(function()
	for _, trade in pairs(Trades) do
		if trade.p1 and not trade.p1.Parent and trade.p2 then
			trade:send(trade.p2, 'partnerCanceled', true)
			trade:remove()
		end
		if trade.p2 and not trade.p2.Parent and trade.p1 then
			trade:send(trade.p1, 'partnerCanceled', true)
			trade:remove()
		end
	end
end)


return TradeManager