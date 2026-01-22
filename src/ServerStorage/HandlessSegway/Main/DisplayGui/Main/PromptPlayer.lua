local MarketService = game:GetService("MarketplaceService")

local PromptPlayer = function(Player,ProductId)
	MarketService:PromptPurchase(Player, ProductId)
end

return PromptPlayer