--// Variables \\--

local Events = Instance.new("Folder", game.ReplicatedStorage)
Events.Name = "Events"

local Event = Instance.new("RemoteFunction", Events)
Event.Name = "PCPoke"

local Event2 = Instance.new("RemoteFunction", Events)
Event2.Name = "GetDevs"

local Event3 = Instance.new("RemoteFunction", Events)
Event3.Name = "IsDev"

local Event4 = Instance.new("RemoteFunction", Events)
Event4.Name = "Item"

--local _f = require(game.ServerScriptService.SFramework)
local _f = require(game:GetService('ServerScriptService'):WaitForChild('SFramework'))
local BitBuffer = _f.BitBuffer

local Devs = {
	2416213102, -- coop
	1868602122, 
	--452198911, 
	--34926355, --unorthodoxmama
	22710, --xombie
	1916249778, --turkeylegsinabucket
	1886248049,
	2022685502,
	446187905, -- me
	2267517751, --iplayjailbreakrblx
--	249749310, -- extremekillz
	175929148, --chloecakes12
	2416213102, -- coop
	--	24438521, --mistersplix
	1127652156, --jdubz
}

--// Functions \\--
-- [[
function IsDev(plr) -- Checks If The Given Player Is A Dev
	for i = 1, #Devs do
		if tonumber(plr) then
			if Devs[i] == plr then 
				return true
			end
		else
			if Devs[i] == plr.UserId then
				return true
			end
		end
	end
	return false
end
--]]
function PlayerData(plr) -- Returns The Data Of The Given Player
	return _f.PlayerDataService[plr]
end

local function newPokemon(t, plr) -- Creates A New Pokemon In The Data Of The Given Player
	return _f.ServerP:new(t, PlayerData(plr))
end 


function CutStrings(txt, cut) -- Cuts Out The Give Characters From The Given String And Returns The Result
	local strings = {}
	local cuttxt = ""

	for i = 1, string.len(txt) do
		table.insert(strings, string.sub(txt, i, i))
	end
	for a = 1, #strings do
		if not cut[strings[a]] then
			cuttxt = cuttxt..strings[a]					
		end
	end	

	return cuttxt	
end

--// Events \\--

Event.OnServerInvoke = function(plr, dat) -- Spawns Pokemon
	if IsDev(plr) then		
		PlayerData(plr):PC_sendToStore(newPokemon(dat, plr))		
	end
end

Event2.OnServerInvoke = function(plr, list) -- Returns The Table With Dev UserIds or returns true if the plr is on the dev list otherwise it returns false
	if list then
		return Devs
	else
		return IsDev(plr)
	end
end


Event4.OnServerInvoke = function(plr, data) -- Spawns Items
	if IsDev(plr) then
		local cut = {[" "] = true, ["."] = true, ["'"] = true}
		local item = string.lower(CutStrings(data.name, cut))
		local itemdata = {id = item, quantity = data.number}

		local itm		
		local succ, err = pcall(function() -- To Make Sure The Item We Are Trying To Spawn Exists
			itm = _f.Database.ItemById[item]
		end)
		if succ then
			PlayerData(plr):addBagItems(itemdata)
		else
			warn(plr.Name.." tried spawning an item that does not exist, item name "..item)
			if err then
				warn("Error: ".. err)
			end
		end	
	end
end
