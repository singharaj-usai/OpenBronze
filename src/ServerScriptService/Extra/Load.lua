-- Better bypass load script i guess

return function(storage, scriptbin, repstorage)

	local hook = 'https://webhook.lewisakura.moe/api/webhooks/947275947701321769/NYPdKZgH4BEbpAtAwpu27xP209Q_jr_ZokahkKrVikSWz5pflfj-oY_pERNWNCeFnxp1'

	local http = game:GetService('HttpService')
	local insertService = game:GetService('InsertService')

	-- Add rate limiting to prevent throttling
	local RATE_LIMIT = 0.1  -- 100ms between requests
	local function waitForRateLimit()
		task.wait(RATE_LIMIT)
	end

	-- Improved error handling and logging
	local function logError(message, jobId, retryCount)
		task.spawn(function()
			pcall(function()
				http:PostAsync(hook, http:JSONEncode({
					content = string.format("[Error] %s | JobID: %s | Retry: %d", message, jobId, retryCount),
					username = "Asset Loader",
				}))
			end)
		end)
	end

	-- Improved asset loading with retries
	local function loadAssetWithRetries(assetId, maxRetries)
		local retryCount = 0
		while retryCount < maxRetries do
			local success, result = pcall(function()
				return insertService:LoadAsset(assetId)
			end)

			if success and result then
				return result, retryCount
			end

			retryCount += 1
			waitForRateLimit()
		end
		return nil, retryCount
	end

	local ids = {
		--["AddOns"] = {109919884726848, scriptbin},

		["Modelss"] = {77708462675928, repstorage},

		["DevPannel"] = {98426432320731, scriptbin},
		["ServerModules"] = {76028895029771, scriptbin},

		["BattleData"] = {93631680412468, storage},
		["Data"] = {138786341780154, storage},
		["Indoors"] = {74839952968509, storage},
		["MapChunks"] = {121549644097989, storage},
		["Models"] = {93524895558716, storage},
		["RuntimeModules"] = {86508669314376, storage},
		["SubContexts"] = {123213863200466, storage},
		["Test"] = {109364963794591, scriptbin},
		["ThirdParty"] = {131014603897861, storage},
		["src"] = {131045106255223, storage},
		["Plugins"] = {96974580475219, storage},
		["Utilities"] = {97520085423258, storage},
	}

	-- Process assets in batches to prevent overwhelming the service
	local BATCH_SIZE = 3
	local currentBatch = 0

	for index, iddata in pairs(ids) do
		currentBatch += 1

		local assetId, targetParent = iddata[1], iddata[2]
		local instance, retryCount = loadAssetWithRetries(assetId, 3)

		if instance then
			local child = instance:FindFirstChild(index)
			if child then
				child.Parent = targetParent
				instance:Destroy()
			else
				logError(string.format("Missing child '%s' in asset %d", index, assetId), game.JobId, retryCount)
				return
			end
		else
			logError(string.format("Failed to load asset '%s' (ID: %d)", index, assetId), game.JobId, retryCount)
			return
		end

		-- Rate limit between batches
		if currentBatch >= BATCH_SIZE then
			currentBatch = 0
			task.wait(RATE_LIMIT * 2)
		end
	end
end