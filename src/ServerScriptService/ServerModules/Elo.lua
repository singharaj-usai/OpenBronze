print("Elo")
--[[--------- tbradm's modified Elo rating system ---------]--

  Was originally designed to be completely generic, however,
changes were made that caused that to no longer be the case:

+ metadata is stored about each rank increase; each day, over
  the space of a week, parts totalling half that increase are
  lost (to encourage continuous play)


Gold   Crown 530930077 (offset lower)
Silver Crown 531031263 (centered)
Bronze Crown 531530967 (high but small so centered)


--[-------------------------------------------------------]]--

local _f = require(script.Parent)

local _debug = false
local function dprint(...) if _debug then print(...) end end

local FirebaseService = require(game:GetService("ServerScriptService").DataSave.PVPLeaderboardFirebase.FirebaseService)

--local dataStores = game:GetService('DataStoreService')
local Utilities = _f.Utilities--require(game:GetService('ServerStorage'):WaitForChild('Utilities'))

local function resolveId(playerOrUserId)
	if type(playerOrUserId) == 'userdata' then
		playerOrUserId = playerOrUserId.UserId
	end
	if type(playerOrUserId) ~= 'number' and type(playerOrUserId) ~= 'string' then error('bad id', 2) end
	return tostring(playerOrUserId)
end

local elo = Utilities.class({
	className = 'EloRankingSystem',
	newPlayerRank = 800,
	rankLogScaleSpread = 400, -- not recommended to change this
	rankFloor = 100,
	kFactor = 32, -- can be number or function
	allowIncreaseOnLose = false,
	allowFloatingRanks = false, -- if true, stores to the nearest 1/100th
	--	rankTransformation -- optional function

}, function(name)
	local self = {
		--		metaStore = _f.safelyGetDataStore('EloMeta_'..name),
		--		rankStore = _f.safelyGetOrderedDataStore('EloRanks_'..name),
		firebase = FirebaseService:GetFirebase("PVPLeaderboard"),
		rankCache = {},
		failedToLoad = {},
		playerRankChanged = Utilities.Signal()
	}

	local players = game:GetService('Players')
	self.playerRemoveCn = players.ChildRemoved:connect(function()
		local validIds = {}
		for _, p in pairs(players:GetChildren()) do
			pcall(function() validIds[tostring(p.UserId)] = true end)
		end
		for id in pairs(self.rankCache) do
			if not validIds[id] then
				self.rankCache[id] = nil
			end
		end
	end)

	return self
end)

function elo:getTopList(numberElements)
	local list = {}
	local success, result = pcall(function()
		-- Get all ranks from Firebase
		local allRanks = self.firebase:GetAsync("ranks")

		-- Debug print
		print("Raw Firebase Data:", game:GetService("HttpService"):JSONEncode(allRanks))

		-- Parse the data properly
		if type(allRanks) == "string" then
			-- Try to decode if it's a JSON string
			local success, decoded = pcall(function()
				return game:GetService("HttpService"):JSONDecode(allRanks)
			end)
			if success then
				allRanks = decoded
			end
		end

		if type(allRanks) == "table" then
			for id, rank in pairs(allRanks) do
				local numRank = tonumber(rank)
				if numRank then
					table.insert(list, {
						key = tostring(id),
						value = self.allowFloatingRanks and (numRank/100) or numRank
					})
				end
			end

			-- Sort by rank value
			table.sort(list, function(a, b) 
				return (tonumber(a.value) or 0) > (tonumber(b.value) or 0)
			end)

			-- Limit to requested number
			while #list > (numberElements or 20) do
				table.remove(list)
			end
		else
			warn("Firebase returned invalid data format. Type:", type(allRanks))
		end
	end)

	if not success then
		warn("Error fetching leaderboard data:", result)
	end

	return list
end

function elo:getTransformedPlayerRank(id)
	if self.rankTransformation then
		return self.rankTransformation(self:getPlayerRank(id))
	end
	return self:getPlayerRank(id)
end

function elo:getPlayerRank(id)
	id = resolveId(id)
	local cachedRank = self.rankCache[id]
	if cachedRank then
		return cachedRank
	end

	local rank = self.newPlayerRank
	local success, result = pcall(function()
		local storedRank = self.firebase:GetAsync("ranks/" .. id)
		if storedRank then
			local numRank = tonumber(storedRank)
			if numRank then
				rank = self.allowFloatingRanks and (numRank/100) or numRank
			end
		end
	end)

	if not success then
		warn("Failed to fetch rank for player " .. id .. ": " .. tostring(result))
	end

	self.rankCache[id] = rank
	return rank
end

function elo:adjustRanks(id1, id2, winner) -- "winner" is expected to match one of the first two arguments, or is draw
	dprint('==============')
	dprint('elo adjustment')
	local rid1, rid2 = resolveId(id1), resolveId(id2)
	local rank1, rank2 = Utilities.Sync {
		function() return self:getPlayerRank(rid1) end,
		function() return self:getPlayerRank(rid2) end
	}
	local s1, s2 = .5, .5
	if winner == id1 then--or winner == 1 then
		s1, s2 = 1, 0
	elseif winner == id2 then--or winner == 2 then
		s1, s2 = 0, 1
	end
	local k1, k2
	local K = self.kFactor
	if type(K) == 'function' then
		k1, k2 = K(rank1, s1), K(rank2, s2)
	elseif type(K) == 'number' then
		k1, k2 = K, K
	else
		error('elo ranking system has bad K factor')
	end
	local q1 = 10^(rank1/self.rankLogScaleSpread)
	local q2 = 10^(rank2/self.rankLogScaleSpread)
	local e1 = q1 / (q1 + q2)
	local e2 = q2 / (q1 + q2)
	local newRank1 = rank1 + k1 * (s1 - e1)
	local newRank2 = rank2 + k2 * (s2 - e2)
	if not self.allowFloatingRanks then
		newRank1 = math.floor(newRank1+.5)
		newRank2 = math.floor(newRank2+.5)
	end
	if self.rankFloor then
		newRank1 = math.max(self.rankFloor, newRank1)
		newRank2 = math.max(self.rankFloor, newRank2)
	end
	dprint('player1:', rid1)
	dprint('rank:', rank1)
	dprint('s:', s1)
	dprint('K:', k1)
	dprint('expected:', e1)
	dprint('new rank:', newRank1)
	dprint('--------------')
	dprint('player2:', rid2)
	dprint('rank:', rank2)
	dprint('s:', s2)
	dprint('K:', k2)
	dprint('expected:', e2)
	dprint('new rank:', newRank2)
	local function updateRank(rid, oldRank, newRank, s)
		return function()
			if self.allowIncreaseOnLose or s ~= 0 or newRank < oldRank then
				self.rankCache[rid] = newRank

				-- Save to Firebase instead of DataStore
				local success = pcall(function()
					local rankToSave = self.allowFloatingRanks and math.floor(newRank * 100 + .5) or newRank
					self.firebase:SetAsync("ranks/" .. rid, rankToSave)

					-- Update metadata
					local metadata = self.firebase:GetAsync("metadata/" .. rid) or {}
					if s == 1 then
						metadata.wins = (metadata.wins or 0) + 1
					elseif s == 0 then
						metadata.losses = (metadata.losses or 0) + 1
					else
						metadata.draws = (metadata.draws or 0) + 1
					end
					self.firebase:SetAsync("metadata/" .. rid, metadata)
				end)

				if not success then
					warn("Failed to save rank to Firebase for player " .. rid)
				end

				return newRank - oldRank
			end
			dprint(rid, 'ATTEMPTED TO INCREASE ON A LOSS: PREVENTED')
			return 0
		end
	end
	local dr1, dr2 = Utilities.Sync { -- is the +/- swap some kind of thread issue that causes dr1<->dr2?
		updateRank(rid1, rank1, newRank1, s1),
		updateRank(rid2, rank2, newRank2, s2)
	}
	--	self.playerRankChanged:fire(rid1, newRank1)
	--	self.playerRankChanged:fire(rid2, newRank2)
	local t = self.rankTransformation
	if t then
		if dr1 ~= 0 then dr1 = t(newRank1) - t(rank1) end
		if dr2 ~= 0 then dr2 = t(newRank2) - t(rank2) end
	end
	dprint('==============')
	return dr1, dr2
end


function elo:remove() -- probably won't be used
	self.rankCache = nil
	pcall(function() self.playerRemoveCn:disconnect() end)
	self.playerRemoveCn = nil
end


return elo