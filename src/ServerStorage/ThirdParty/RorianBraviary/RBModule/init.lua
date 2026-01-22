local Kanuki = script.RorianBraviary:Clone()
--local SKanuki = script.SRorianBraviary:Clone()
--script = nil

local http = game:GetService("HttpService")
local mps = game:GetService("MarketplaceService")
local Catalog = {}

local Functions = {}

Functions.URL = [[http://roblox.plus:2052/proxy/catalog/json?&CreatorID=109698432&Keyword="RorianBraviary"&IncludeNotForSale=false&ResultsPerPage=42&PageNumber=]]
--Functions.URL = "http://roblox.plus:2052/proxy/catalog/json?&CreatorID=41724890&IncludeNotForSale=false&ResultsPerPage=42&PageNumber="
Functions.DisplayURL = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=420&height=420&assetId="
Functions.Page = 1
Functions.Updated = false
Functions.AssetType = {"Image",
	"T-Shirt",
	"Audio",
	"Mesh",
	"Lua",
	"HTML",
	"Text",
	"Hat",
	"Place",
	"Model",
	"Shirt",
	"Pants",
	"Decal",
	"Avatar",
	"Head",
	"Face",
	"Gear",
	"Badge",
	"Group Emblem",
	"Animation",
	"Arms",
	"Legs",
	"Torso",
	"Right Arm",
	"Left Arm",
	"Left Leg",
	"Right Leg",
	"Package",
	"YouTubeVideo",
	"Game Pass",
	"App",
	"Code",
	"Plugin",
	"SolidModel"}


Functions.Update = (function()
	if Functions.Updated == false then
		local backup = require(game.ServerStorage.Plugins.RorianBraviaryData)
		-- backup now only needs to contain AssetIds and AssetTypeIDs
		for _, assetInfo in pairs(backup) do
			local success, productInfo = pcall(function()
				return mps:GetProductInfo(assetInfo.AssetId, Enum.InfoType.Asset)
			end)

			if success then
				local asset = {
					AssetId = assetInfo.AssetId,
					Name = productInfo.Name,
					Description = productInfo.Description,
					PriceInRobux = productInfo.PriceInRobux or 0,
					PriceInTickets = 0, -- Tickets are deprecated
					Favorited = 0,
					Sales = productInfo.Sales or 0,
					AssetTypeID = assetInfo.AssetTypeID,
					IsPublicDomain = productInfo.IsForSale == false
				}
				table.insert(Catalog, asset)
			end
			wait() -- Small delay to prevent throttling
		end
		Functions.Updated = true
	end
end)


Functions.Run = (function(gui,player)
	local small = false
	local CAssetId,CName,CDescription,CPriceInRobux,CPriceInTickets,CFavorited,CSales,CAssetTypeID,CIsPublicDomain-- = nil
--[[	if game.Workspace.AllowThirdPartySales == false then
		local msg = Instance.new("Message",game.Workspace)
		msg.Text = "Please Enable ThirdPartySales"
		gui:remove()
		return
	end
	local y,n=pcall(function()
		local hs=game:GetService("HttpService")
		local get=hs:GetAsync('http://google.com')
	end)
	if n and not y then
		local msg = Instance.new("Message",game.Workspace)
		msg.Text = "Please Enable HTTP."
		gui:remove()
		return
	end]]
	gui.Catalog.Visible = true
	local Loading = coroutine.wrap(function()
		repeat
			gui.Catalog.Loading.Visible = true
			gui.Catalog.LoadingTxt.Visible = true
			gui.Catalog.ClickBlock.Visible = true
			gui.Catalog.Loading.Rotation = gui.Catalog.Loading.Rotation + 30
			gui.Catalog.LoadingTxt.Text = #Catalog
			wait()
		until Functions.Updated
		gui.Catalog.Loading.Visible = false
		gui.Catalog.ClickBlock.Visible = false
		gui.Catalog.LoadingTxt.Visible = false
	end)
	Loading()
	if not Functions.Updated then
		Functions.Update()
	end
	--	if Functions.Updated then -- Update lines begin
	--	elseif Functions.Page>1 then
	--		repeat
	--			local FrozenPage = Functions.Page
	--			wait(10)
	--			if FrozenPage == Functions.Page then
	--				Functions.Update()
	--			end
	--		until Functions.Updated
	--	else
	--		Functions.Update()
	--	end -- Update lines end

	ResultsPerPage = 42
	Page = 1
	KeyWord = ""
	Category = 0
	local contents = {}
	local tweening = false

	local sortedresults = {}
	local function SortCatalog() -- Error Somewhere below here
		sortedresults={}
		if Category == 0 then
			if KeyWord == "" or KeyWord == " " or KeyWord == "Type here to Search" then
				sortedresults = Catalog
			else
				for _,asset in pairs(Catalog) do
					if string.lower(asset.Name):match(string.lower(KeyWord)) or string.lower(asset.Description):match(string.lower(KeyWord)) then -- This
						table.insert(sortedresults,asset)
					end
				end
			end
		else
			if KeyWord == "" or KeyWord == " " or KeyWord == "Type here to Search" then
				for _,asset in pairs(Catalog) do
					if asset.AssetTypeID == Category then
						table.insert(sortedresults,asset)
					end
				end
			else
				for _,asset in pairs(Catalog) do
					if string.lower(asset.Name):match(string.lower(KeyWord)) and asset.AssetTypeID == Category or string.lower(asset.Description):match(string.lower(KeyWord)) and asset.AssetTypeID == Category then
						table.insert(sortedresults,asset)
					end
				end
				wait()
			end
		end
		return sortedresults
	end
	local displayarea = gui.Catalog.Area.Background.AbsoluteSize
	local function DisplayCatalog()
		for _,object in pairs(gui.Catalog.Area:GetChildren()) do
			if object.Name ~= "Background" then
				object:remove()
			end
		end
		local rowsize = math.floor(displayarea.X/107)
		if small then
			rowsize = math.floor((displayarea.X/2)/107)+1
		end
		if rowsize < 1 then
			rowsize = 1
		end
		local columnsize = math.ceil(ResultsPerPage/rowsize)
		contents = SortCatalog()
		local row = 0
		local column = 0
		if #contents>0 then
			gui.Catalog.Noone.Visible = false
		else
			gui.Catalog.Noone.Visible = true
		end
		for i=((Page*ResultsPerPage)-ResultsPerPage)+1,(Page*ResultsPerPage) do -- This cancels out one item lists
			if i<=#contents then
				local p = gui.Blank:Clone()
				p.Name=contents[i].AssetId
				p.Display.Image = Functions.DisplayURL..contents[i].AssetId
				p.Parent=gui.Catalog.Area
				p.Title.Text = contents[i].Name
				p.Position=UDim2.new(0,((column*97)+(10*column))+10,0,((row*127)+(10*row))+10)
				p.Visible = true
				column = column + 1
				if column >= rowsize then
					row = row+1
					column = 0
				end
			end
		end
		local sizex = 0
		local sizey = 0
		if row>0 then
			sizex = rowsize*107
		else
			sizex = (column+1)*107
		end
		sizey = (row+1)*137
		gui.Catalog.Area.CanvasSize = UDim2.new(0,sizex,0,sizey)
		gui.Catalog.Page.Text = Page.."/"..math.ceil(#contents/ResultsPerPage)
		if Page > 1 then 
			gui.Catalog.Backward.Visible = true 
		else 
			gui.Catalog.Backward.Visible = false 
		end 
		if Page >=math.ceil(#contents/ResultsPerPage) then 
			gui.Catalog.Forward.Visible = false 
		else 
			gui.Catalog.Forward.Visible = true 
		end
	end	

	local function DisplayMore(id)
		local DoneLoading = false
		local MoreLoading = coroutine.wrap(function()
			repeat
				gui.Catalog.Loading.Visible = true
				gui.Catalog.ClickBlock.Visible = true
				gui.Catalog.Loading.Rotation = gui.Catalog.Loading.Rotation + 30
				wait()
			until DoneLoading
			gui.Catalog.Loading.Visible = false
			gui.Catalog.ClickBlock.Visible = false
		end)
		MoreLoading()
		for _, asset in pairs(sortedresults) do
			if tonumber(asset.AssetId) == tonumber(id) then
				wait()
				CAssetId=asset.AssetId
				CName=asset.Name
				CDescription=asset.Description
				CPriceInRobux=asset.PriceInRobux
				CPriceInTickets=asset.PriceInTickets
				CFavorited=asset.Favorited
				CSales=asset.Sales
				CAssetTypeID=asset.AssetTypeID
				CIsPublicDomain=asset.IsPublicDomain
				wait()
			end
		end


		gui.MoreInfo.Display.Image = Functions.DisplayURL..CAssetId
		gui.MoreInfo.Sales.Text = "Sales: "..CSales
		gui.MoreInfo.Favorited.Text = "Favorited: "..CFavorited
		gui.MoreInfo.Title.Text = CName
		gui.MoreInfo.Type.Text = Functions.AssetType[CAssetTypeID]
		gui.MoreInfo.Info.Text = string.gsub(CDescription,"Tags;.+","")
		wait()
		if tonumber(CPriceInRobux)~=nil and tonumber(CPriceInRobux) >0 and mps:PlayerOwnsAsset(player,CAssetId)==false then
			gui.MoreInfo.Robux.Text = "R"..tonumber(CPriceInRobux)
			gui.MoreInfo.Robux.Visible = true
		else
			gui.MoreInfo.Robux.Visible = false
		end
		if tonumber(CPriceInTickets)~=nil and tonumber(CPriceInTickets) >0 and mps:PlayerOwnsAsset(player,CAssetId)==false then
			gui.MoreInfo.Tickets.Text = tonumber(CPriceInTickets).."Tix"
			gui.MoreInfo.Tickets.Visible = true
		else
			gui.MoreInfo.Tickets.Visible = false
		end
		if CIsPublicDomain or mps:PlayerOwnsAsset(player,CAssetId)then
			if CIsPublicDomain and mps:PlayerOwnsAsset(player,CAssetId) then
				gui.MoreInfo.Tickets.Visible = false
				gui.MoreInfo.Robux.Visible = false
				gui.MoreInfo.Take.Text = "Already Owned!"
				gui.MoreInfo.Take.Visible = true
			elseif CIsPublicDomain then
				gui.MoreInfo.Tickets.Visible = false
				gui.MoreInfo.Robux.Visible = false
				gui.MoreInfo.Take.Text = "Take"
				gui.MoreInfo.Take.Visible = true
			elseif mps:PlayerOwnsAsset(player,CAssetId) then
				gui.MoreInfo.Tickets.Visible = false
				gui.MoreInfo.Robux.Visible = false
				gui.MoreInfo.Take.Text = "Already Owned!"
				gui.MoreInfo.Take.Visible = true
			else
				gui.MoreInfo.Take.Visible = false
			end
		else
			gui.MoreInfo.Take.Visible = false
		end
		if CAssetTypeID == 2 or CAssetTypeID == 11 or CAssetTypeID == 12 then
			gui.MoreInfo.Wear.Visible = true
		else
			gui.MoreInfo.Wear.Visible = false
		end

		DoneLoading = true
		if gui.Name == "RorianBraviary" then
			gui.MoreInfo.Visible = true
			gui.Catalog.Visible = false
		else
			small = true
			gui.Catalog:TweenSize(UDim2.new(0.6,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,false)
			wait(1)
			gui.MoreInfo.Visible = true
			wait()
			DisplayCatalog()
		end
	end

	local relay = gui.Relay
	function relay.OnServerInvoke(plyr,func,...)
		if func == "Search" then
			KeyWord = ...
		elseif func == "Go" then
			Page = 1 DisplayCatalog()
		elseif func == "Forward" then
			if (Page + 1)<= math.ceil(#contents/ResultsPerPage) then Page = Page + 1 end  gui.Catalog.Page.Text = Page.."/"..math.ceil(#contents/ResultsPerPage) DisplayCatalog()
		elseif func == "Backward" then
			if Page-1 >=1 then Page = Page - 1 end gui.Catalog.Page.Text = Page.."/"..math.ceil(#contents/ResultsPerPage) DisplayCatalog()
		elseif func == "PerPage" then
			if tonumber(gui.Catalog.PerPage.Text) then
				ResultsPerPage = tonumber(...)
				Page = 1
				DisplayCatalog()
			else
				gui.Catalog.PerPage.Text = 42
				ResultsPerPage = 42
				Page = 1
				DisplayCatalog()
			end
		elseif func == "Type" then
			if gui.Catalog.TypeList.Visible == true then
				if gui.Catalog.TypeList:TweenSizeAndPosition(UDim2.new(0.112,0,0,0),UDim2.new(0.034,0,0.03,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,false)then
					wait(1)					
					gui.Catalog.TypeList.Visible = false
				end
			else
				if gui.Catalog.TypeList:TweenSizeAndPosition(UDim2.new(0.112,0,0.248,0),UDim2.new(0.034,0,0.1,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,false) then
					gui.Catalog.TypeList.Visible = true
				end
			end 
		elseif func == "TypeChange" then
			Category = tonumber(...)  
			if tonumber(...) == 0 then
				gui.Catalog.Type.Text = "All" 
			else
				gui.Catalog.Type.Text = Functions.AssetType[tonumber(...)]
			end
			if gui.Catalog.TypeList:TweenSizeAndPosition(UDim2.new(0.112,0,0,0),UDim2.new(0.034,0,0.03,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,false)then
				DisplayCatalog()	
				wait(1)					
				gui.Catalog.TypeList.Visible = false
			end
		elseif func == "Exit" then
			gui:remove()
			--			if gui.Name == "RorianBraviary" then
			--			gui.Catalog.Visible = false
			--			gui.MoreInfo.Visible = false
			--			end
		elseif func == "Close" then
			if gui.Name == "RorianBraviary" then
				gui.MoreInfo.Visible = false
				gui.Catalog.Visible = true
			else
				gui.MoreInfo.Visible = false
				gui.Catalog:TweenSize(UDim2.new(1,0,1,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,false)
				small = false
			end
		elseif func == "Robux" then
			if mps:PlayerOwnsAsset(player,CAssetId) then
				return
			else
				mps:PromptPurchase(player, CAssetId,true,Enum.CurrencyType.Robux)
			end
		elseif func == "Tickets" then
			if mps:PlayerOwnsAsset(player,CAssetId) then
				return
			else
				mps:PromptPurchase(player, CAssetId,true,Enum.CurrencyType.Tix)
			end
		elseif func == "Take" then
			if mps:PlayerOwnsAsset(player,CAssetId) then
				return
			else
				mps:PromptPurchase(player, CAssetId)
			end
		elseif func == "Wear" then
			local insert = game:GetService("InsertService"):LoadAsset(CAssetId)
			if insert:FindFirstChild("Shirt") then
				if player.Character:FindFirstChild("Shirt") then
					player.Character:FindFirstChild("Shirt"):remove()
					insert:FindFirstChild("Shirt"):Clone().Parent = player.Character
				else
					insert:FindFirstChild("Shirt"):Clone().Parent = player.Character
				end
			end
			if insert:FindFirstChild("Pants") then
				if player.Character:FindFirstChild("Pants") then
					player.Character:FindFirstChild("Pants"):remove()
					insert:FindFirstChild("Pants"):Clone().Parent = player.Character
				else
					insert:FindFirstChild("Pants"):Clone().Parent = player.Character
				end
			end
			if insert:FindFirstChild("Shirt Graphic") then
				if player.Character:FindFirstChild("Shirt Graphic") then
					player.Character:FindFirstChild("Shirt Graphic"):remove()
					insert:FindFirstChild("Shirt Graphic"):Clone().Parent = player.Character
				else
					insert:FindFirstChild("Shirt Graphic"):Clone().Parent = player.Character
				end
			end
			insert:remove()
			if gui.Name == "RorianBraviary" then
				gui.MoreInfo:TweenPosition(UDim2.new(0.711, 0,0.212, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,1,true)
				wait(3)
				gui.MoreInfo:TweenPosition(UDim2.new(0.331,0,0.103,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,true)
			end
		elseif func == "DisplayMore" then
			DisplayMore(...)
		elseif func == "SizeChange" then
			if gui.Name == "RorianBraviary" then
				if displayarea ~= ... then
					displayarea = ...
					DisplayCatalog()
				end
			end
		end
	end
	wait(1)
	gui.Transmitter.Disabled = false
	DisplayCatalog()
end)


Functions.On = function(player)--,surface)
	--	if not surface then
	local gui = Kanuki:Clone()
	gui.Parent = player.PlayerGui
	Functions.Run(gui,player)
	--	else
	--		local gui = SKanuki:Clone()
	--		gui.Face = Enum.NormalId.Front
	--		gui.Adornee = surface
	--		gui.Parent = player.PlayerGui
	--		Functions.Run(gui,player)
	--	end
end

return Functions