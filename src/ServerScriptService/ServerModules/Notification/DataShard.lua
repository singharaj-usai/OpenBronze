print("DataShard")
-- this code is incomplete and probably not very reusable but
-- it does what I need it to

local _f = require(script.Parent.Parent)

--local dataStores = game:GetService('DataStoreService')
local http = game:GetService('HttpService')

local nShards = 14

return function(name, scope)
	local n = math.random(nShards)
	pcall(function()
		local guid = http:GenerateGUID():gsub('%W+', '')
		n = tonumber(guid, 16) % nShards + 1
	end)
--	local store = dataStores:GetDataStore(name..'_shard'..n, scope)
	local store = _f.safelyGetDataStore(name..'_shard'..n, scope)
	
	return store
end