return function(_p)--local _p = require(script.Parent)
local Utilities = _p.Utilities
local create = Utilities.Create
local network = _p.Network

---------------------------------------------------------------------------------------------
local function hsb( h, s, v ) -- h = 0..360, s = 0..1, v = 0..1
	h = h % 360
	if s == 0 then
		return Color3.new(v, v, v)
	end
	h = h / 60
	local i = math.floor(h)
	local f = h - i
	local p = v * ( 1 - s )
	local q = v * ( 1 - s * f )
	local t = v * ( 1 - s * ( 1 - f ) )
	if i == 0 then
		return Color3.new(v, t, p)
	elseif i == 1 then
		return Color3.new(q, v, p)
	elseif i == 2 then
		return Color3.new(p, v, t)
	elseif i == 3 then
		return Color3.new(p, q, v)
	elseif i == 4 then
		return Color3.new(t, p, v)
	end
	return Color3.new(v, p, q)
end
---------------------------------------------------------------------------------------------

game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
local pad = '   '

local players = game:GetService('Players')
local player = players.LocalPlayer

local pListNames = {}
local pListNamesReverse = {}

local WIDTH = 190

local dexText = 'Pokedex'
if _p.context == 'battle' then dexText = 'Rank' end
local pListGui = create 'Frame' {
	Name = 'PlayerList',
	BackgroundColor3 = Color3.new(.2, .2, .2),
	BackgroundTransparency = 0.8,
	BorderSizePixel = 0,
	Size = UDim2.new(0.0, WIDTH, 0.0, 31),
	Position = UDim2.new(1.0, -WIDTH-11, 0.0, 15),
	Visible = false,
	Parent = Utilities.backGui,
	
	create 'Frame' {
		Name = 'content',
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, -16, 1.0, -16),
		Position = UDim2.new(0.0, 8, 0.0, 8),
	},
	create 'Frame' { -- header
		Name = 'header',
		BackgroundColor3 = Color3.new(.2, .2, .2),
		BorderSizePixel = 0,
		Size = UDim2.new(1.0, -24, 0.0, 14),
		Position = UDim2.new(0.0, 12, 0.0, -11),
		ZIndex = 3,
		
		create 'Frame' { -- outline
			BackgroundColor3 = Color3.new(.2, .2, .2),
			BorderSizePixel = 1,
			BorderColor3 = Color3.new(0, 0, 0),
			Size = UDim2.new(1.0, 0, 1.0, 0),
		},
		create 'TextLabel' { -- title
			Name = 'title',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Position = UDim2.new(0.0, -1, 0.0, -1),
			Font = Enum.Font.SourceSansBold,
			FontSize = Enum.FontSize.Size14,--TextScaled = true
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = pad..'Players',
			ZIndex = 5,
		},
		create 'TextLabel' { -- title shadow
			Name = 'titleshadow',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Position = UDim2.new(0.0, 0, 0.0, 0),
			Font = Enum.Font.SourceSansBold,
			FontSize = Enum.FontSize.Size14,--TextScaled = true
			TextColor3 = Color3.new(0, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = pad..'Players',
			ZIndex = 4,
		},
		create 'TextLabel' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Position = UDim2.new(0.0, -1, 0.0, -1),
			Font = Enum.Font.SourceSansBold,
			FontSize = Enum.FontSize.Size14,--TextScaled = true
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = dexText..pad,
			ZIndex = 5,
		},
		create 'TextLabel' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			Position = UDim2.new(0.0, 0, 0.0, 0),
			Font = Enum.Font.SourceSansBold,
			FontSize = Enum.FontSize.Size14,--TextScaled = true
			TextColor3 = Color3.new(0, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = dexText..pad,
			ZIndex = 4,
		},
	},
	create 'Frame' { -- top
		BackgroundColor3 = Color3.new(.2, .2, .2),
		BorderColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(1.0, 0, 0.0, 2),
		Position = UDim2.new(0.0, 0, 0.0, -1),
		ZIndex = 2,
	},
	create 'Frame' { -- bottom
		BackgroundColor3 = Color3.new(.2, .2, .2),
		BorderColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(1.0, 0, 0.0, 2),
		Position = UDim2.new(0.0, 0, 1.0, -1),
		ZIndex = 2,
	},
	create 'Frame' { -- left
		BackgroundColor3 = Color3.new(.2, .2, .2),
		BorderColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(0.0, 2, 1.0, 0),
		Position = UDim2.new(0.0, -1, 0.0, 0),
		ZIndex = 2,
	},
	create 'Frame' { -- right
		BackgroundColor3 = Color3.new(.2, .2, .2),
		BorderColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(0.0, 2, 1.0, 0),
		Position = UDim2.new(1.0, -1, 0.0, 0),
		ZIndex = 2,
	},
	create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://6142797841',--reupload/replace
		ImageColor3 = Color3.new(.5, .5, .5),
		Rotation = -45,
		Size = UDim2.new(0.0, 16, 0.0, 16),
		Position = UDim2.new(0.0, -8, 0.0, -8),
		ZIndex = 3,
	},
	create 'ImageLabel' {
		BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6142797841',--reupload/replace
		ImageColor3 = Color3.new(.5, .5, .5),
		Rotation = 45,
		Size = UDim2.new(0.0, 16, 0.0, 16),
		Position = UDim2.new(1.0, -8, 0.0, -8),
		ZIndex = 3,
	},
	create 'ImageLabel' {
		BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6142797841',--reupload/replace
		ImageColor3 = Color3.new(.5, .5, .5),
		Rotation = -45-90,
		Size = UDim2.new(0.0, 16, 0.0, 16),
		Position = UDim2.new(0.0, -8, 1.0, -8),
		ZIndex = 3,
	},
	create 'ImageLabel' {
		BackgroundTransparency = 1.0,
			Image = 'rbxassetid://6142797841',--reupload/replace
		ImageColor3 = Color3.new(.5, .5, .5),
		Rotation = 45+90,
		Size = UDim2.new(0.0, 16, 0.0, 16),
		Position = UDim2.new(1.0, -8, 1.0, -8),
		ZIndex = 3,
	},
}

local user = create 'TextButton' {
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(.24, .24, .24),
	BackgroundTransparency = .3,
	BorderColor3 = Color3.new(0, 0, 0),
	Size = UDim2.new(1.0, -12, 0.0, 15),
	Font = Enum.Font.SourceSansBold,
	FontSize = Enum.FontSize.Size14,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.new(0, 0, 0),
	ZIndex = 2,
	
	create 'TextLabel' {
		Name = 'top',
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Position = UDim2.new(0.0, -1, 0.0, -1),
		Font = Enum.Font.SourceSansBold,
		FontSize = Enum.FontSize.Size14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	},
	create 'TextLabel' {
		Name = 'dex',
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Position = UDim2.new(0.0, -1, 0.0, -1),
		Font = Enum.Font.SourceSansBold,
		FontSize = Enum.FontSize.Size14,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = Color3.new(1, 1, 1),
		ZIndex = 4,
	},
	create 'TextLabel' {
		Name = 'dextop',
		BackgroundTransparency = 1.0,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Position = UDim2.new(0.0, -1, 0.0, -1),
		Font = Enum.Font.SourceSansBold,
		FontSize = Enum.FontSize.Size14,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = Color3.new(0, 0, 0),
		ZIndex = 3,
	},
	create 'ImageLabel' {
		Name = 'badge',
		BackgroundTransparency = 1.0,
		Image = '',
		Size = UDim2.new(0.0, 21, 0.0, 21),
		Position = UDim2.new(0.0, -18, 0.0, -3),
		ZIndex = 3,
	}
}

local showHideContainer = create 'Frame' {
	BackgroundTransparency = 1.0,
	Size = UDim2.new(0.0, 0, 0.0, 12),
	Position = UDim2.new(1.0, -WIDTH/2-11, 0.0, -22),
	Parent = Utilities.backGui
}


local pListNamesUsers = {}

local function updateUser(u, badgeId, ownedPokemon)
	u.badge.Image = badgeId==0 and '' or ('rbxassetid://'..badgeId)
	local t = (ownedPokemon==0 and _p.context~='battle') and '' or (tostring(ownedPokemon)..pad)
	u.dex.Text = t
	u.dextop.Text = t
end

local function addUser(p)
	local i = #pListNames+1
	local u = user:Clone()
	if p == player then
		u.Position = UDim2.new(0.0, 12, 0.0, 0)
		u.Parent = pListGui.content
	else
		u.Position = UDim2.new(0.0, 12, 0.0, 18*(i-1))
		u.Parent = pListGui.content
		if _p.context == 'battle' then
			u.MouseButton1Click:connect(function()
				_p.PVP:onClickedPlayer(p)
			end)
		elseif _p.context == 'trade' then
			u.MouseButton1Click:connect(function()
				_p.TradeMatching:onClickedPlayer(p)
			end)
		end
	end
	u.Text = pad..p.Name
	u.top.Text = pad..p.Name
	u.top.TextColor3 = Utilities.GetNameColor(p.Name)
	
	pListNames[i] = p.Name
	pListNamesReverse[p.Name] = true
	pListNamesUsers[i] = u
	
	local b, o = 0, 0
	pcall(function() b = p.BadgeId.Value end)
	pcall(function() o = p.OwnedPokemon.Value end)
	updateUser(u, b, o)
end

local function updatepListGui()
	-- removals
	for i = #pListNames, 1, -1 do
		if not players:FindFirstChild(pListNames[i]) then
			pListNamesReverse[ pListNames[i] ] = nil
			table.remove(pListNames, i)
			pListNamesUsers[i]:remove()
			for j = i+1, #pListNamesUsers do
				pcall(function() pListNamesUsers[j]:TweenPosition(UDim2.new(0.0, 12, 0.0, 18*(j-2)), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true) end)
			end
			table.remove(pListNamesUsers, i)
		end
	end
	-- additions
	for _, p in pairs(players:GetChildren()) do
		if p:IsA('Player') then
			if not pListNamesReverse[p.Name] then
				addUser(p)
			end
		end
	end
	-- adjust container
	local size = UDim2.new(0.0, WIDTH, 0.0, #pListNamesUsers*18+13)
	if size ~= pListGui.Size then
		pcall(function() pListGui:TweenSize(size, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true) end)
	end
end

addUser(player)

players.ChildAdded:connect(updatepListGui)
players.ChildRemoved:connect(updatepListGui)
updatepListGui()


network:bindEvent('UpdatePlayerlist', function(playerName, badgeId, ownedPokemon)
	local u
	for i, pn in pairs(pListNames) do
		if pn == playerName then
			u = pListNamesUsers[i]
			break
		end
	end
	if not u then return end
	updateUser(u, badgeId, ownedPokemon)
end)


local playerList = {
	enabled = false
}

function playerList:enable()
	self.enabled = true
	pListGui.Visible = true
	showHideContainer:ClearAllChildren()
	Utilities.Write 'Hide Players' {
		Frame = showHideContainer,
		Scaled = true
	}
end

function playerList:disable()
	self.enabled = false
	pListGui.Visible = false
	showHideContainer:ClearAllChildren()
	Utilities.Write 'Show Players' {
		Frame = showHideContainer,
		Scaled = true
	}
end

function playerList:updateStatus()
--	updateStatus()
end

game:GetService('UserInputService').InputBegan:connect(function(inputObject)
	local iType = inputObject.UserInputType
	if iType == Enum.UserInputType.MouseButton1 or iType == Enum.UserInputType.Touch then
		local pos = inputObject.Position
		if pos.Y < 0 and pos.X > Utilities.gui.AbsoluteSize.X-WIDTH then
			if playerList.enabled then playerList:disable() else playerList:enable() end
		end
	end
end)


return playerList end