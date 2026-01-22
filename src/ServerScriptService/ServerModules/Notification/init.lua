print("Notif")
-- Notification is now sharded
-- Shard banlist?
local _f = require(script.Parent)

local subscribePlayerNotifications = false

local players = game:GetService('Players')
local repStorage = game:GetService('ReplicatedStorage')
--local remote = repStorage:WaitForChild('Remote')

local scheduledShutdown
local shutdownReason
local shutdownCommandThread
local network = _f.Network--require(script.Parent.Network)
--local ShutdownEvents = remote:WaitForChild('ShutDownSoon')
network:bindEvent('ShutdownEvents', function(player)
	if scheduledShutdown then
		network:post('ShutdownEvents', player, scheduledShutdown-os.time()-2, shutdownReason)
	end
end)

local function shutdown()
	local players = game:GetService('Players')
	players.PlayerAdded:connect(function(p)
		wait()
		p:Kick()
	end)
	for _, p in pairs(players:GetChildren()) do
		pcall(function() p:Kick() end)
	end
end

local FirebaseService = require(game.ServerScriptService.DataSave.BanList.FirebaseService)
local banlist = FirebaseService:GetFirebase('Banned')

local function globalNotificationReceived(n)
	if n.kind == 'ShutDown' then
		if n.cancel then
			shutdownCommandThread = nil
			scheduledShutdown = nil
			network:postAll('ShutdownEvents')
		else
			if n.version then
				local v = string.match(repStorage.Version.Value, '^v([^%s]+)')
				if v ~= n.version then return end
			end
			if n.context and n.context ~= _f.Context then return end
			local thisThread = {}
			shutdownCommandThread = thisThread
			scheduledShutdown = n.shutdownTime
			shutdownReason = n.reason
			local timeTilShutdown = scheduledShutdown-os.time()
			network:postAll('ShutdownEvents', timeTilShutdown-2, shutdownReason)
			delay(timeTilShutdown, function()
				if shutdownCommandThread == thisThread then
					shutdown()
				end
			end)
		end
	elseif n.kind == 'Ban' then
		local id = n.userId
		banlist:SetAsync(tostring(id), true)
		for _, player in pairs(players:GetChildren()) do
			local name = players:GetNameFromUserIdAsync(tostring(id)) -- roblox is dumb best way to do it
			if player.Name == name then
				pcall(function() player:Kick() end)
				wait()
				pcall(function() player:Kick() end)
				pcall(function() player:remove() end)
			end
		end
	elseif n.kind == 'Unban' then
		banlist:RemoveAsync(tostring(n.userId))
	elseif n.kind == 'Announcement' then

	end
end

local function playerNotificationReceived(recipient, n)
	if n.kind == 'Whisper' then

	elseif n.kind == 'QuestInvite' then

	end
end

---------------------------------------------------------------------------------------------
local stores = require(game.ServerScriptService.DataSave.BanList.FirebaseService)

local globalNotificationStore = game:GetService('MessagingService')

local serverLaunchTime = os.time()
local globalNotificationsRead = {}

if globalNotificationStore then
	globalNotificationStore:SubscribeAsync('Inbox', function(list)
		for _, n in pairs(list['Data']) do
			if n.ts > serverLaunchTime and not globalNotificationsRead[n.id] then
				globalNotificationsRead[n.id] = true
				globalNotificationReceived(n)
			end
		end
	end)
end


local playerSubscriptions = {}
local playerNotificationsRead = {}

local function playerNotificationListUpdated(player, list)
	stores:GetFirebase('Notification', tostring(player.UserId)):UpdateAsync('Inbox', function(list)
		for _, n in pairs(list) do
			if not playerNotificationsRead[player.Name][n.id] then
				playerNotificationsRead[player.Name][n.id] = true
				playerNotificationReceived(player, n)
			end
		end
		return {}
	end)
end

local function subscribePlayer(player)
	if not player or not player.Parent or not player:IsA('Player') then return end
	playerSubscriptions[player.Name] = stores:GetFirebase('Notification', tostring(player.UserId)):OnUpdate('Inbox', function(list)
		playerNotificationListUpdated(player, list)
	end)
	playerNotificationsRead[player.Name] = {}
end

local function unsubscribeMissingPlayers()
	for n, c in pairs(playerSubscriptions) do
		if not players:FindFirstChild(n) then
			pcall(function() c:disconnect() end)
			playerSubscriptions[n] = nil
			playerNotificationsRead[n] = nil
		end
	end
end

local function newPlayer(player)
	if banlist and banlist:GetAsync(tostring(player.UserId)) then
		pcall(function() player:Kick() end)
		wait()
		pcall(function() player:Kick() end)
		pcall(function() player:remove() end)
		return
	end
	if subscribePlayerNotifications then
		subscribePlayer(player)
	end
end

players.ChildAdded:connect(newPlayer)
for _, obj in pairs(players:GetChildren()) do newPlayer(obj) end

players.ChildRemoved:connect(unsubscribeMissingPlayers)

---------------------------------------------------------------------------------------------
local uid = require(game:GetService('ServerStorage'):WaitForChild('Utilities')).uid

local function sendNotification(recipientId, n)
	if not n or type(n) ~= 'table' then return end
	local global = true
	local recipientStore = globalNotificationStore
	if recipientId then
		global = false
		recipientStore = stores:GetFirebase('Notification', tostring(recipientId))
	end
	n.ts = os.time()
	n.id = uid()
	recipientStore:UpdateAsync('Inbox', function(list)
		list = list or {}
		if global then
			-- clean up global notifications older than an hour; note that they can be infinitely old if
			--   there have been no other notification posted one hour later until this one
			for i = #list, 1, -1 do
				if os.time()-list[i].ts > 360 then
					table.remove(list, i)
				end
			end
		end
		table.insert(list, n)
		return list
	end)
end

--remote:WaitForChild('SendNotification').OnServerEvent:connect(sendNotification)

return 0