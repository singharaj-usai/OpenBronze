print("Marketplace")
local _f = require(script.Parent)

local marketplaceService = game:GetService('MarketplaceService')
local players = game:GetService('Players')
local network = _f.Network
local purchaseHistory = {}

marketplaceService.ProcessReceipt = function(receiptInfo)
	local purchaseId = receiptInfo.PlayerId .. '_' .. receiptInfo.PurchaseId
	if purchaseHistory[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	------------Spinner logic
	local plr = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId)
	if plr then
		local PlayerData = _f.PlayerDataService[plr]
		local function newPokemon(t)
			return _f.ServerP:new(t, PlayerData)
		end
		if receiptInfo.ProductId == 1209422619 then
			local spinDetails = game.ServerStorage.SpinDetails:Invoke()
			game.ReplicatedStorage.Remote.Spin:FireClient(plr, spinDetails)

			local ratename = spinDetails.Rate.Name
			if ratename == 'Common' or 'Uncommon' or 'Legendary' or ratename == 'Mythical' then
				_f.Network:postToDiscord2('Roulette Logger', '```'..plr.Name..'('..plr.UserId..') just won '..spinDetails.WinningItem.Name..' from the Roulette.```')
				network:postAll('SystemChat', plr.Name..' just won '..spinDetails.WinningItem.Name..' from the Roulette.', spinDetails.Rate.Color)
			end

			PlayerData:PC_sendToStore(newPokemon{
				name = spinDetails.WinningItem.Name,
				level = 5,
				untradable = true,
				shinyChance = 256,
			})
			return Enum.ProductPurchaseDecision.PurchaseGranted
		elseif receiptInfo.ProductId == 1209422656 then
			local spinDetails = {game.ServerStorage.SpinDetails:Invoke(), game.ServerStorage.SpinDetails:Invoke(), game.ServerStorage.SpinDetails:Invoke()}
			game.ReplicatedStorage.Remote.Spin:FireClient(plr, spinDetails)

			local ratename1 = spinDetails[1].Rate.Name
			local ratename2 = spinDetails[2].Rate.Name
			local ratename3 = spinDetails[3].Rate.Name
			if ratename1 == 'Legendary' or ratename1 == 'Mythical' then
				_f.Network:postToDiscord2('Roulette Logger', '```'..plr.Name..'('..plr.UserId..') just won '..spinDetails[1].WinningItem.Name..' from the Roulette.```')
				network:postAll('SystemChat', plr.Name..' just won '..spinDetails[1].WinningItem.Name..' from the Roulette.', spinDetails[1].Rate.Color)
			end
			if ratename2 == 'Legendary' or ratename2 == 'Mythical' then
				_f.Network:postToDiscord2('Roulette Logger', '```'..plr.Name..'('..plr.UserId..') just won '..spinDetails[2].WinningItem.Name..' from the Roulette.```')
				network:postAll('SystemChat', plr.Name..' just won '..spinDetails[2].WinningItem.Name..' from the Roulette.', spinDetails[2].Rate.Color)
			end
			if ratename3 == 'Legendary' or ratename3 == 'Mythical' then
				_f.Network:postToDiscord2('Roulette Logger', '```'..plr.Name..'('..plr.UserId..') just won '..spinDetails[3].WinningItem.Name..' from the Roulette.```')
				network:postAll('SystemChat', plr.Name..' just won '..spinDetails[3].WinningItem.Name..' from the Roulette.', spinDetails[3].Rate.Color)
			end

			PlayerData:PC_sendToStore(newPokemon{
				name = spinDetails[1].WinningItem.Name,
				level = 5,
				untradable = true,
				shinyChance = 256,
			})
			PlayerData:PC_sendToStore(newPokemon{
				name = spinDetails[2].WinningItem.Name,
				level = 5,
				untradable = true,
				shinyChance = 256,
			})
			PlayerData:PC_sendToStore(newPokemon{
				name = spinDetails[3].WinningItem.Name,
				level = 5,
				untradable = true,
				shinyChance = 256,
			})
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			for _, p in pairs(players:GetPlayers()) do
				if p.UserId == receiptInfo.PlayerId and _f.PlayerDataService[p] then
					_f.PlayerDataService[p]:onDevProductPurchased(receiptInfo.ProductId)
					--			network:post('PurchaseCompleted', p, receiptInfo.ProductId, true)
					purchaseHistory[purchaseId] = true
					return Enum.ProductPurchaseDecision.PurchaseGranted
				end
			end
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	for _, p in pairs(players:GetPlayers()) do
		if p.UserId == receiptInfo.PlayerId and _f.PlayerDataService[p] then
			_f.PlayerDataService[p]:onDevProductPurchased(receiptInfo.ProductId)
			--			network:post('PurchaseCompleted', p, receiptInfo.ProductId, true)
			purchaseHistory[purchaseId] = true
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

marketplaceService.PromptPurchaseFinished:connect(function(player, assetId, isPurchased)
	if isPurchased then
		_f.PlayerDataService[player]:onAssetPurchased(assetId)
	end
--	network:post('PromptPurchaseFinished', player, assetId, isPurchased)
end)

return 0