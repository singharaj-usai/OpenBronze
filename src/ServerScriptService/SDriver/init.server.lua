local scriptbin = script.Parent
local storage = game:GetService('ServerStorage')
local repstorage = game:GetService('ReplicatedStorage')

require(scriptbin:WaitForChild('Extra'):WaitForChild('Load'))(storage, scriptbin, repstorage)

--local scriptbin = script.Parent
--local storage = game:GetService('ServerStorage')


-- SERVER LAUNCH PREP
-- move (specific) buildings to proper storage
--pcall(function() workspace.Museum.Parent = storage.Indoors.chunk19 end)

--[[
local insertService = game:GetService("InsertService")
local data = {
	Plugins = 8585877212,--,
	Data = 8585879123,
	BattleData = 8585880242,
	Indoors = 8585883336,
	SubContexts = 8585885218,
	Hoverboards = 8585886411,
	RuntimeModules = 8585887506,
	Utilities = 8585890460,
	ThirdParty = 8585888882,
	src = 8585891118,
	--Models = 8507477708,
	--BattleScenes = 80390287,
}
local loadedAsset
for name, identification in pairs(data) do
	loadedAsset = insertService:LoadAsset(identification)
	if name == 'Hoverboards' then
		loadedAsset:FindFirstChild(name).Parent = storage.Models
	else
		loadedAsset:FindFirstChild(name).Parent = storage
	end
	loadedAsset:remove()
end
--]]

--local pluginsModel = insertService:LoadAsset(7992863692)
--pluginsModel.Plugins.Parent = storage
--pluginsModel:remove ()
--local dataModel = insertService:LoadAsset(7984390208)
--dataModel.Data.Parent = storage
--dataModel:remove ()
--local battleDataModel = insertService:LoadAsset(7984406837)
--battleDataModel.BattleData.Parent = storage
--battleDataModel:remove ()
--local indoorsFolder = insertService:LoadAsset(7991969933)
--indoorsFolder.Indoors.Parent = storage
--indoorsFolder:remove()
--local subContextsFolder = insertService:LoadAsset(7992050979)
--subContextsFolder.SubContexts.Parent = storage
--subContextsFolder:remove ()
--local HoverboardsFolder = insertService:LoadAsset(7992073984)
--HoverboardsFolder.Hoverboards.Parent = storage.Models
--HoverboardsFolder:remove ()
--local battleSceneFolder = insertService:LoadAsset(7992113973)
--battleSceneFolder.BattleScenes.Parent = storage.Models
--battleSceneFolder:remove ()


pcall(function() workspace.gym6.Parent = storage.MapChunks end)

-- move chunks to storage
for _, obj in pairs(workspace:GetChildren()) do
	if obj.Name:sub(1, 5) == 'chunk' and tonumber(obj.Name:sub(6)) then
		obj.Parent = storage.MapChunks
	end
end

-- fix regions
for _, r in pairs(storage.MapChunks.Regions:GetChildren()) do
	local chunk = storage.MapChunks:FindFirstChild(r.Name)
	if chunk then
		r.Parent = chunk
		r.Name = 'Regions'
	end
end

-- make spawn box invisible
for _, p in pairs(workspace.SpawnBox:GetChildren()) do
	pcall(function() p.Transparency = 1.0 end)
end

-- revert to legacy physics
-- Recursive function that applies old physics to all parts in an object and its children
local function applyOldPhysics(obj)
	for _, part in pairs(obj:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
		end
	end
end

-- Apply old physics to all parts in the ServerStorage object
applyOldPhysics(storage)

-- SERVER FRAMEWORK INSTALLATION
local moduleFolder = scriptbin:WaitForChild('ServerModules')
local frameworkModule = script:WaitForChild('SFramework')
frameworkModule.Parent = scriptbin

local _f = require(frameworkModule)
_f.Utilities = require(storage:WaitForChild('Utilities'))
_f.BitBuffer = require(storage:WaitForChild('Plugins'):WaitForChild('BitBuffer'))
_f.levelCap = 100
_f.isDay = function() -- Night is from 17:50 to 06:30, inclusive
	local min = game:GetService('Lighting'):GetMinutesAfterMidnight()
	return min > 6.5*60 and min < (17+5/6)*60
end

do-- Feb 9, 2017: kinda mad that I have to write this workaround
	local dataStores = game:GetService('DataStoreService')
	local errorText = 'Place has to be opened with Edit button to access DataStores'
	local errorText2 = 'You must publish this place to the web to access DataStore.'
	local efunc = function() error(errorText) end
	local fakeDataStore = {
		GetAsync = efunc,
		SetAsync = efunc,
		UpdateAsync = efunc,
		IncrementAsync = efunc,
		OnUpdate = function() end
	}
	_f.safelyGetDataStore = function(n, s)
		local ds
		local s, r = pcall(function() ds = dataStores:GetDataStore(n, s) end)
		if not s then
			if r == errorText or r:find(errorText2) then
				return fakeDataStore
			else
				error(r)
			end
		end
		return ds
	end
	_f.safelyGetOrderedDataStore = function(n, s)
		local ds
		local s, r = pcall(function() ds = dataStores:GetOrderedDataStore(n, s) end)
		if not s then
			if r == errorText or r:find(errorText2) then
				return fakeDataStore
			else
				error(r)
			end
		end
		return ds
	end
end

local function install(module, name)
	if name then module.Name = name end
	--	print('installing', module.Name)
	module.Parent = frameworkModule
	_f[module.Name] = require(module)
end

-- install the modules that are expected to be pre-installed or installed in particular order
for _, name in pairs({'Network', 'Context', 'DataService',
	'Elo', 'BattleEngine'}) do
	install(moduleFolder[name])

	-- Initialize Firebase for Elo system
	if name == 'Elo' then
		local FirebaseService = require(game:GetService("ServerScriptService").DataSave.PVPLeaderboardFirebase.FirebaseService)
		FirebaseService:SetUseFirebase(true) -- Enable Firebase
		print("Firebase initialized for Elo system")
	end
end

-- install the usable items
install(storage.src.UsableItemsServer, 'UsableItems')

-- misc installs
_f.PBStamps = require(storage.RuntimeModules.PBStamps){Utilities = _f.Utilities}

-- install all other modules
for _, module in pairs(moduleFolder:GetChildren()) do
	if module:IsA('ModuleScript') then
		install(module)
	end
end



-- Third party
pcall(function()
	local _RB = require(storage.ThirdParty.RorianBraviary)
	_f.Network:bindFunction('RorianBraviary', _RB.handleClientRequest)
end)


-- Load models
local insertService = game:GetService('InsertService')
local function safeLoadModel(groupAssetId, testAssetId)
	local assetId = (game.CreatorId == 1 and testAssetId or groupAssetId) --always change this
	while true do
		local success = false
		pcall(function()
			local loadedModel = insertService:LoadAsset(assetId)
			if loadedModel then
				success = true
				for _, m in pairs(loadedModel:GetChildren()) do
					if m:IsA('Model') then
						m.Parent = storage.Models
					end
				end
			end
		end)
		if success then break end
		wait(.5)
	end
end
wait()
spawn(function() safeLoadModel(656180015, 656169938) end) -- Heatran
wait(.25)
--spawn(function() safeLoadModel(668388587, 668387748) end) -- Beast Trio






