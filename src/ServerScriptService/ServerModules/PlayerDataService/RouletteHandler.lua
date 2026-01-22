local _f = require(script.Parent.Parent)
local MarketplaceService = game:GetService("MarketplaceService")
local Spritesheets = require(game:GetService("ServerStorage").Data.Spritesheets)

local RouletteHandler = {}

-- Constants
local TOKENS_PER_SPIN = 1
local FREE_SPINS = 5 -- For testing

-- Roulette rewards configuration
local ROULETTE_REWARDS = {
	-- Common rewards (60% chance)
	{
		weight = 60,
		rewards = {
			{ type = "pokemon", name = "Pikachu", level = 10, chance = 20 },
			{ type = "pokemon", name = "Eevee", level = 10, chance = 20 },
			{ type = "item", name = "pokeball", quantity = 10, chance = 30 },
			{ type = "item", name = "greatball", quantity = 5, chance = 30 },
		}
	},
	-- Rare rewards (30% chance)
	{
		weight = 30,
		rewards = {
			{ type = "pokemon", name = "Dratini", level = 15, chance = 30 },
			{ type = "pokemon", name = "Larvitar", level = 15, chance = 30 },
			{ type = "item", name = "ultraball", quantity = 5, chance = 40 },
		}
	},
	-- Epic rewards (10% chance)
	{
		weight = 10,
		rewards = {
			{ type = "pokemon", name = "Mewtwo", level = 50, chance = 50 },
			{ type = "item", name = "masterball", quantity = 1, chance = 50 },
		}
	}
}

-- Helper function to get a random reward based on weights
local function getRandomReward()
	local totalWeight = 0
	for _, tier in ipairs(ROULETTE_REWARDS) do
		totalWeight = totalWeight + tier.weight
	end

	local roll = math.random() * totalWeight
	local currentWeight = 0

	for _, tier in ipairs(ROULETTE_REWARDS) do
		currentWeight = currentWeight + tier.weight
		if roll <= currentWeight then
			-- Select reward from this tier
			local tierRoll = math.random() * 100
			local currentChance = 0
			for _, reward in ipairs(tier.rewards) do
				currentChance = currentChance + reward.chance
				if tierRoll <= currentChance then
					return reward
				end
			end
		end
	end

	return ROULETTE_REWARDS[1].rewards[1] -- Fallback to first common reward
end

function RouletteHandler:init()
	-- Initialize free spins for testing
	_f.Network:bindFunction("RequestRouletteSpins", function(player)
		local PlayerData = _f.PlayerService:getPlayerData(player)
		if not PlayerData then return 0 end
		return FREE_SPINS
	end)

	-- Handle spin request
	_f.Network:bindFunction("SpinRoulette", function(player)
		local PlayerData = _f.PlayerService:getPlayerData(player)
		if not PlayerData then return nil end

		-- For testing, always allow spins
		local reward = getRandomReward()

		-- Grant the reward
		if reward.type == "pokemon" then
			local pokemon = _f.Pokemon:new({
				name = reward.name,
				level = reward.level,
				shiny = math.random() < 0.01, -- 1% shiny chance
			}, PlayerData)

			if #PlayerData.party < 6 then
				table.insert(PlayerData.party, pokemon)
			else
				PlayerData:PC_sendToStore(pokemon)
			end
		elseif reward.type == "item" then
			PlayerData:addBagItems({id = reward.name:lower(), quantity = reward.quantity})
		end

		-- Return reward info for animation (ensuring all fields exist)
		return {
			type = reward.type or "item",
			name = reward.name or "pokeball",
			level = reward.level or 1,
			quantity = reward.quantity or 1,
			spriteData = Spritesheets._FRONT and Spritesheets._FRONT[reward.name]
		}
	end)
end

return RouletteHandler 