


local _f = require(script.Parent)

local BitBuffer = _f.BitBuffer
local Persistence = {}
local sendToGlobal = {};
local backSendToGlobal = {};
local allowIncoming = true;

local FirebaseService = require(game.ServerScriptService.DataSave.RoPowersAndBP.FirebaseService);


local Backup1 = require(game.ServerScriptService.DataSave.FirebaseSave)
local Backup2 = require(game.ServerScriptService.DataSave.NewFirebaseSave)



local Backup3 = require(game.ServerScriptService.DataSave.FirebaseSaveNum3)

local backup4 = require(game.ServerScriptService.DataSave.FirebaseSaveNum4)
local backup5 = require(game.ServerScriptService.DataSave.FirebaseSaveNum5)

local function reportBadSaveString() end
local function safetyCheck(mainData, pcData)
	if select(2, mainData:gsub(';', ';')) ~= 3 then -- decline mismatched div counts
		return 1
	end
	local s, v = pcall(function()
		return select(2, mainData:match('^([^;]+);'):gsub('%-', '-')) == 4
	end)
	if not s or not v then
		return 2
	end
	if pcData then
		if pcData:find(',,') then
			return -1
		end
		local s, v = pcall(function()
			local buffer = BitBuffer.Create()
			buffer:FromBase64(pcData:match('^(.+);'))
			for _ = 1, 6+1+6 do buffer:ReadBool() end
			if buffer:ReadBool() then for _ = 1, buffer:ReadUnsigned(6) do if buffer:ReadBool() then buffer:ReadString() end end end
			if buffer:ReadBool() then for _ = 1, buffer:ReadUnsigned(6) do if buffer:ReadBool() then buffer:ReadUnsigned(5) end end end
			local nStoredPokemon = buffer:ReadUnsigned(11)
			local pokemonArrayString = pcData:match(';(.+)$')
			if nStoredPokemon == 0 and not pokemonArrayString then return true end
			return nStoredPokemon - select(2, pokemonArrayString:gsub(',', ',')) == 1
		end)
		if not s or not v then
			return -2
		end
	end
	return 0
end

local network = _f.Network--require(script.Parent.Parent.Network)

-- Testing
if game:GetService('RunService'):IsStudio() then--and false then
	print 'DataPersistence Test Mode Enabled'
	function Persistence.SaveData(player, mainData, pcData) -- OVH  change to playerId(?) (will have to change network binding); would benefit TradeManager
		if Persistence.PlaySolo then print('ATTEMPT TO SAVE AFTER LOADING TEST DATA') return false end
		local sc = safetyCheck(mainData, pcData)
		if sc ~= 0 then
			warn('Bad save attempt:', sc)
			return false
		end
		local c = game:GetService('Lighting')
		--pcall(function()
		--	c.TestData:Destroy()
		--	c.TestPC:Destroy()
		--end)
		if mainData then
			local t = Instance.new('StringValue', c)
			t.Name = 'TestData'
			t.Value = mainData
		end
		if pcData then
			local t = Instance.new('StringValue', c)
			t.Name = 'TestPC'
			t.Value = pcData
		end
		return true
	end
	function Persistence.LoadData(player)
		local c = game:GetService('Lighting')
		local d, p
		if c:FindFirstChild('TestData') then
			d = c.TestData.Value
		end
		if c:FindFirstChild('TestPC') then
			p = c.TestPC.Value
		end
		return true, d, p
	end
	function Persistence.ROPowerSave(player, action, arg1)
		if action == 'save' then
			return false
		elseif action == 'load' then
			return nil
		end
		warn('Bad RO-Power Backup request ('..tostring(action)..')')
	end

	--	network:bindFunction('SaveData', Persistence.SaveData)
	--	network:bindFunction('LoadData', Persistence.LoadData)
	return Persistence
end


local DataStoreService = game:GetService('DataStoreService')
local HttpService = game:GetService("HttpService");

-- Player Data

--local PermanentData   = DataStoreService:GetDataStore('PermanentPlayerData')


local STRING_LEN_LIMIT = 259900

local offsetByPlayer = {}
local keysByPlayer = {}

reportBadSaveString = function(userId, data, errorNum)
	warn('Bad save attempt:', errorNum)
	-- save report to store?
end

function Persistence.SaveData(player, mainData, pcData)
	if player.UserId < 1 then return false end -- guests cannot save
	local id = tostring(player.UserId)
	local check = safetyCheck(mainData, pcData)
	local pcdata = {};
	if check ~= 0 then
		reportBadSaveString(id, check>0 and mainData or pcData, check)
		return false
	end
	local l = pcData:len()
	local nReqKeys = math.ceil(l / STRING_LEN_LIMIT)
	local offset = 0
	if offsetByPlayer[player] and keysByPlayer[player] then
		if nReqKeys > offsetByPlayer[player] then
			offset = offsetByPlayer[player] + keysByPlayer[player] + 1
		end
	end
	for i = 1, nReqKeys do
		local si = STRING_LEN_LIMIT * (i-1) + 1
		local ei = math.min(l, STRING_LEN_LIMIT * i)
		table.insert(pcdata, i+offset..'-'..pcData:sub(si, ei))
		local s, e = pcall(function() 
			--	Backup1.DataSave(id..'_'..(i+offset), pcData:sub(si, ei));
			--	Backup2.DataSave(id..'_'..(i+offset), pcData:sub(si, ei));
			Backup3.DataSave(id..'_'..(i+offset), pcData:sub(si, ei));
			backup4.DataSave(id..'_'..(i+offset), pcData:sub(si, ei));
			--	backup5.DataSave(id..'_'..(i+offset), pcData:sub(si, ei));

		end)
		if not s then
			print('Error saving pc data:', e)
			return false
		end
	end

	local s, e = pcall(function() 
		--Backup1.DataSave(id, offset..'['..nReqKeys..']'..mainData);
		--Backup2.DataSave(id, offset..'['..nReqKeys..']'..mainData);
		Backup3.DataSave(id, offset..'['..nReqKeys..']'..mainData);
		backup4.DataSave(id, offset..'['..nReqKeys..']'..mainData);
		--backup5.DataSave(id, offset..'['..nReqKeys..']'..mainData);

	end)
	if not s then
		print('Error saving player data:', e)
		return false
	end
	offsetByPlayer[player] = offset
	keysByPlayer[player] = nReqKeys

	if allowIncoming then
		sendToGlobal[id] = {
			["PlayerID"] = id,
			["PlayerData"] = offset..'['..nReqKeys..']'..mainData,
			["PCData"] = pcdata
		}
	else
		backSendToGlobal[id] = {
			["PlayerID"] = id,
			["PlayerData"] = offset..'['..nReqKeys..']'..mainData,
			["PCData"] = pcdata
		}
	end

	return true
end

function Persistence.LoadData(player)
	local id = tostring(player.UserId)
	--local s, d = pcall(function() return PlayerDataStore:GetAsync(id) end)
	local pcdata = nil;

	local d = Backup3.DataLoad(id);

	if not d then
		d = backup4.DataLoad(id);

		--	d = Backup2.DataLoad(id);

		if not d then
			--	d = backup5.DataLoad(id);

			--	d = Backup3.DataLoad(id);
			--  Never played before idk

			if not d then
				-- Bob's weirdo thing

				local data =
					{
						["type"] = "main",
						["id"] = id

					}


				if d == "null" then
					d = nil;
				else
					print("No data in firebase, fetching from other thing.")
				end

				if not d then
					return true
				end
			end
		end
	end

	local offset, nKeys, data = d:match('^(%d+)%[(%d+)%](.+)$')
	if not offset or not nKeys or not data then
		return true, d
	end
	offset, nKeys = tonumber(offset), tonumber(nKeys)
	offsetByPlayer[player] = offset
	keysByPlayer[player] = nKeys
	local pc
	for i = 1, nKeys do
		local pcd = nil;
		if not pcdata then
			pcd = Backup3.DataLoad(id..'_'..i+offset);

			if not pcd then
				--pcd = Backup2.DataLoad(id..'_'..i+offset);
				pcd = backup4.DataLoad(id..'_'..i+offset);

				if not pcd then
					--pcd = Backup3.DataLoad(id..'_'..i+offset);
					--	pcd = backup5.DataLoad(id..'_'..i+offset);

				end
			end
		else
			pcd = pcdata[id..'_'..i+offset];
		end
		pc = (pc or '') .. pcd
	end
	return true, data, pc
end

--network:bindFunction('SaveData', Persistence.SaveData)
--network:bindFunction('LoadData', Persistence.LoadData)

--[[ Permanent Data   DEPRECATED
local function LoadPermanentData(player)
	local s, r = pcall(function() return PermanentData:GetAsync(tostring(player.UserId)) end)
	if s then return r end
end

local function SavePermanentData(player, updates)
	pcall(function()
		PermanentData:UpdateAsync(tostring(player.UserId), function(data)
			data = data or {}
			for key, value in pairs(updates) do
				data[key] = value
			end
			return data
		end)
	end)
end--]]


-- RO-Powers Autosave
do
	local ROPowerStore = FirebaseService:GetFirebase('ROPowerBackups')
	function Persistence.ROPowerSave(player, action, arg1)
		if action == 'save' then
			local success = pcall(function() ROPowerStore:SetAsync(tostring(player.UserId), arg1) end)
			return success
		elseif action == 'load' then
			local data
			local success = pcall(function() data = ROPowerStore:GetAsync(tostring(player.UserId)) end)
			return data
		end
		warn('Bad RO-Power Backup request ('..tostring(action)..')')
	end
end


-- BP Management (1 BP per battle between each player combo, per hour
do
	local BattledPlayers = FirebaseService:GetFirebase('PVPHourBattleHistoryV3')
	local BattleStreak = FirebaseService:GetFirebase('PVPWinStreak')

	local TIME_BETWEEN_BP_AWARDS = 60*60

	local Battle = _f.BattleEngine--require(script.Parent.BattleEngine)
	function Battle:PVPBattleAwardsBP(versusId)
		local s, lastTime = pcall(function() return BattledPlayers:GetAsync(versusId) end)
		if not s then
			if self.WIN_DEBUG then
				print('LANDO: Failed to get last time you\'ve battled this player:')
				print(lastTime)
				print('Defaulting to AwardBPEnabled')
			end
			--			print('cannot tell whether battled in last hour;', lastTime)
			return true--false -- WE DEFAULT TO TRUE CUZ BENEFIT OF THE DOUBT
		end
		local now = os.time()
		if lastTime and now-lastTime < TIME_BETWEEN_BP_AWARDS then
			if self.WIN_DEBUG then print('LANDO: You already battled this guy in the last hour, dingus.') end
			--			print(versusId, 'battled too recently')
			return false
		end
		--		if not lastTime then
		--			print('no previous battle recorded as', versusId)
		--		else
		--			print(now, lastTime)
		--		end
		pcall(function() BattledPlayers:SetAsync(versusId, now) end)
		if self.WIN_DEBUG then print('LANDO: This battle has properly been flagged to award BP.') end
		return true
	end

	function Battle:incrementStreak(userId)
		pcall(function() BattleStreak:IncrementAsync(tostring(userId), 1) end)
	end
	function Battle:resetStreak(userId)
		pcall(function() BattleStreak:SetAsync(tostring(userId), 0) end)
	end
	function Battle:getStreak(userId)
		local s, r = pcall(function() return BattleStreak:GetAsync(tostring(userId)) or 0 end)
		return s and r or 0
	end
end


-- Starter Stats   DEPRECATED
--[[
local StarterStats = DataStoreService:GetDataStore('StarterStats')

local toSubmit = {
	Original = {},
	Additional = {},
}

function Persistence.StarterChosen(player, starter, original)
	if original then
		local replace = 
		toSubmit.Original[starter] = (toSubmit.Original[starter] or 0) + 1
		if replace then
			toSubmit.Original[replace] = (toSubmit.Original[replace] or 0) - 1
		end
	else
		toSubmit.Additional[starter] = (toSubmit.Additional[starter] or 0) + 1
	end
end

local deepcopy = _f.Utilities.deepcopy
local function UpdateStarterStats()
	local todo = deepcopy(toSubmit)
	toSubmit.Original = {}
	toSubmit.Additional = {}
	if next(todo.Additional) then
		StarterStats:UpdateAsync('Additional', function(list)
			list = list or {}
			for k, v in pairs(todo.Additional) do
				list[k] = (list[k] or 0) + v
			end
			return list
		end)
	end
	if next(todo.Original) then
		StarterStats:UpdateAsync('Original', function(list)
			list = list or {}
			for k, v in pairs(todo.Original) do
				list[k] = (list[k] or 0) + v
			end
			return list
		end)
	end
end

game.OnClose = function()
	UpdateStarterStats()
	if not game:GetService('RunService'):IsStudio() then
		wait(10)
	end
end
spawn(function()
	while true do
		wait(15)
		UpdateStarterStats()
	end
end)
--]]

return Persistence