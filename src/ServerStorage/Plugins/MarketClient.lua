return function(_p)
local marketplaceService = game:GetService('MarketplaceService')
local market = {}


function market:promptProductPurchase(devProductId)
	marketplaceService:PromptProductPurchase(_p.player, devProductId)
end

function market:promptPurchase(assetId)
	marketplaceService:PromptPurchase(_p.player, assetId)
end


return market end