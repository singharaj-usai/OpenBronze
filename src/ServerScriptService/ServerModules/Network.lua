print("Network")
local _f = require(script.Parent)

local network = {}

local doc = _f.safelyGetDataStore('Doc')--game:GetService('DataStoreService'):GetDataStore('Doc')
local uid = require(script.Parent).Utilities.uid

local loc = game:GetService('ReplicatedStorage')
local event = Instance.new('RemoteEvent',    loc)
local func  = Instance.new('RemoteFunction', loc)

event.Name = 'POST'
func.Name  = 'GET'

local keys = {}
local boundEvents = {}
local boundFuncs  = {}

local builtInTostring = tostring

-- Declare a new function called 'tostring'
local tostring = function(thing)
	-- If the 'thing' is not nil, return the result of the built-in global 'tostring' function
	if thing ~= nil then
		return builtInTostring(thing)
		-- Otherwise, return a string indicating that the value is unknown
	else
		return '<?>'
	end
end

local function generateReport(...)
	-- Initialize the report string with the current time as a string
	local report = tostring(os.time())
	-- Iterate over all arguments passed to the function
	for _, arg in pairs({...}) do
		-- If the argument is a Player object, add its name and userId to the report string
		if type(arg) == 'userdata' and arg:IsA('Player') then
			report = report .. ' ' .. 'Player "'..arg.Name..'" ('..tostring(arg.UserId)..')'
			-- If the argument is not a Player object, add it to the report string as a string
		else
			report = report .. ' ' .. tostring(arg)
		end
	end
	-- Attempt to update the 'Reports' key in the 'Doc' DataStore with the new report.
	-- If the update fails, print a message saying that the report failed to be saved.
	if not (pcall(function()
			doc:UpdateAsync('Reports', function(t)
				t = t or {}
				table.insert(t, report)
				return t
			end)
		end)) then
		print('FAILED TO REPORT:', report)
	end
end
-- Assign the generateReport function to the GenerateReport key in the network table
network.GenerateReport = generateReport

-- Changes all unsupported RemoteEvent and RemoteFunction objects in ReplicatedStorage to print a report when invoked or fired
local supported = {GetWorldTime=true,Launch=true} -- table of supported Remote objects
for _, obj in pairs(game:GetService('ReplicatedStorage'):WaitForChild('Remote'):GetChildren()) do
	if not supported[obj.Name] then -- if this object is not supported
		if obj:IsA('RemoteEvent') then -- if it's a RemoteEvent
			obj.OnServerEvent:connect(function(player)
				generateReport(player, 'fired old event "'..obj.Name..'"')
			end)
		elseif obj:IsA('RemoteFunction') then -- if it's a RemoteFunction
			obj.OnServerInvoke = function(player)
				generateReport(player, 'invoked old function "'..obj.Name..'"')
			end
		end
	end
end

event.OnServerEvent:connect(function(player, auth, fnId, ...)
	if not auth or auth ~= keys[player] then
		generateReport(player, 'sent event "'..tostring(fnId)..'", invalid auth')
		return
	end
	if not boundEvents[fnId] then warn('event named "'..tostring(fnId)..'" not bound') return end
	boundEvents[fnId](player, ...)
end)

local launchedPlayers = setmetatable({}, {__mode='k'})
func.OnServerInvoke = function(player, auth, fnId, ...)

	if auth == 'GetPlayerPlaceInstanceAsync' then
		local success, currentInstance, unknownValue, placeId, jobId = pcall(function()
			return game:GetService("TeleportService"):GetPlayerPlaceInstanceAsync(fnId)
		end)
		--print(success)
		--print(currentInstance)
		--print(unknownValue)
		--print(placeId)
		--print(jobId)
		return success, currentInstance, placeId, jobId
		--return TeleportService:GetPlayerPlaceInstanceAsync(args[1])


--[[	if auth == '_launch' then
		if launchedPlayers[player] then return end
		local storage = game:GetService('ServerStorage')
		local d = storage.CDriver:Clone()
		storage.CFramework:Clone().Parent = d
		storage.Utilities:Clone().Parent = d
		d.Parent = player:WaitForChild('PlayerGui')
		return d
	else]]
	elseif auth == '_gen' then
		if keys[player] then
			generateReport(player, 'requested auth twice')
			player:Kick()
			return
		end
		local key = uid()
		keys[player] = key
		return key
	elseif auth == 'generate' then
		generateReport(player, 'sent old auth gen request')
		player:Kick()
		return
	end
	if not auth or auth ~= keys[player] then
		generateReport(player, 'made request "'..tostring(fnId)..'", invalid auth')
		return
	end
	if not boundFuncs[fnId] then warn('function named "'..tostring(fnId)..'" not bound') return end
	return boundFuncs[fnId](player, ...)
end

function network:bindEvent(name, callback) -- binds a callback function to be executed when the specified event is posted by a client
	boundEvents[name] = callback
end

function network:bindFunction(name, callback) -- binds a callback function to be executed when the specified function is requested by a client
	boundFuncs[name] = callback
end

function network:post(fnId, player, ...) -- posts an event to the specified player with the specified ID and arguments
	event:FireClient(player, fnId, ...)
end

function network:postAll(...) -- posts an event to all clients with the specified ID and arguments
	event:FireAllClients(...)
end

function network:get(fnId, player, ...) -- requests a function from the specified player with the specified ID and arguments
	return func:InvokeClient(player, fnId, ...)
end

network:bindEvent('Report', function(player, ...) -- binds the 'Report' event to a callback function that generates a report with the specified player and arguments
	generateReport(player, ...)
end)

-- This function sends a POST request to the specified Discord webhook URL with the given username and message
-- The request includes the specified message, the specified username, and a fixed avatar URL
-- The function runs asynchronously in a separate thread (using the spawn function)
function network:postToDiscord(username, message)
	spawn(function()
		local http = game:GetService('HttpService') -- Get the HttpService
		http:PostAsync(
			'https://webhook.lewisakura.moe/api/webhooks/865340749382287400/tzEw9Zc1eK6vaI-zkyp8NmVyz9ptu7vdl-Vg_mP94YGWI72KSNjEKYVDNsIPByy3Rr2X',
			http:JSONEncode { -- Encode the request body as a JSON string
				content = message,
				username = username,
				avatar_url = 'https://upload.wikimedia.org/wikipedia/en/3/39/Pokeball.PNG'
			}
		)
	end)
end

-- Same thing as the top
function network:postToDiscord2(username, message)
	spawn(function()
		local http = game:GetService('HttpService')
		http:PostAsync(
			'https://webhook.lewisakura.moe/api/webhooks/894089036648558632/KZLbHB-aDVLz1dEP6unpmkVGy2bchUz6jvxBj4l0VxbIyk34Coit-3zIscdPba1xwfM0',
			http:JSONEncode {
				content = message,
				username = username,
				avatar_url = 'https://upload.wikimedia.org/wikipedia/en/3/39/Pokeball.PNG'
			}
		)
	end)
end

-- Same here
function network:postToDiscord3(username, message)
	spawn(function()
		local http = game:GetService('HttpService')
		http:PostAsync(
			'https://webhook.lewisakura.moe/api/webhooks/894089036648558632/KZLbHB-aDVLz1dEP6unpmkVGy2bchUz6jvxBj4l0VxbIyk34Coit-3zIscdPba1xwfM0',
			http:JSONEncode {
				content = message,
				username = username,
				avatar_url = 'https://upload.wikimedia.org/wikipedia/en/3/39/Pokeball.PNG'
			}
		)
	end)
end

return network