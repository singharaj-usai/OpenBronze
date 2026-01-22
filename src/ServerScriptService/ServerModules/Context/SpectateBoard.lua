print("SpectateBoard")
local _f = require(script.Parent.Parent)

local board = {}
_f.SpectateBoard = board

local storage = game:GetService('ServerStorage')
local Utilities = _f.Utilities
local create = Utilities.Create
local write = Utilities.Write
local uid = Utilities.uid
local roundedFrame = require(storage.Plugins.RoundedFrame2){Utilities=Utilities}

local gui



local publicEvents = {}
local publicFunctions = {'getSpecButtons', 'onClick'}
_f.Network:bindEvent('SpecE', function(player, fn, ...)
	if not publicEvents[fn] then return end
	local args = {...}
	pcall(function() return board[fn](board, player, unpack(args)) end)
end)
_f.Network:bindFunction('SpecF', function(player, fn, ...)
	if not publicFunctions[fn] then return end
	local args = {...}
	local s, r = pcall(function() return board[fn](board, player, unpack(args)) end)
	if s then return r end
end)
do -- move values to keys
	local pe, pf = {}, {}
	for _, s in pairs(publicEvents)    do pe[s] = true end
	for _, s in pairs(publicFunctions) do pf[s] = true end
	publicEvents, publicFunctions = pe, pf
end


local scrollList, container, sbw, none
-- this board update system is hackier than I'd like it to be... we'll see how it turns out...
local listelements = {}
local battleForElement = setmetatable({}, {__mode='v'})

function board:getSpecButtons()
	return Utilities.GetDescendants(container, 'GuiButton')
end

function board:onClick(player, button)
	if not button then return end
	for elem, battle in pairs(battleForElement) do
		if elem.gui:IsAncestorOf(button) then
			-- 2v2specdo
			return {
				id = battle.id,
				name1 = battle.p1.name,
				name2 = battle.p2.name,
			}
		end
	end
end

function board:update()
	local s, r = pcall(function()
--	print('updating board')
	if not container then return end
--	print('good container')
	local h = .07
	local battles = _f.BattleEngine:getSpectatableBattles()
	-- remove ended battles
--	print('removing battles')
	for element, battle in pairs(battleForElement) do
		if not battle or battle.ended or not battles[battle] then
			battleForElement[element] = nil
		end
	end
	for i = #listelements, 1, -1 do
		local elem = listelements[i]
		if not battleForElement[elem] then
			elem:remove()
			table.remove(listelements, i)
		end
	end
	-- add new battles
--	print('adding battles')
		-- [[ TEST stuff
--	for _, vs in pairs({{'tbradm', 'lando64000'}, {'Srybon', 'chrissuper'}, {'Our_Hero', 'zombie7737'}, {'KyleAllenMusic', 'Twitter'}, {'hoboj03', 'briest'}}) do
	local newbuttons = {}
	for battle in pairs(battles) do
		local hasElem = false
		for elem, b in pairs(battleForElement) do
			if b == battle then
				hasElem = true
				break
			end
		end
		if not hasElem and not battle.ended then
			if battle.p1.isTwoPlayerSide then
				-- todo
				
			else
				local name1 = battle.p1.name
				local name2 = battle.p2.name
				local elem = roundedFrame:new {
					CornerRadius = 15,
					BackgroundColor3 = Color3.fromRGB(25, 35, 50),
					BorderSizePixel = 0,
					Size = UDim2.new(.98, 0, h*.9, 0)
				}
				local textContainer = create 'Frame' {
					BackgroundTransparency = 1.0,
					ClipsDescendants = true,
					Size = UDim2.new(.85, 0, 1.0, 0),
					Position = UDim2.new(.025, 0, 0.0, 0),
					Parent = elem.gui
				}
				local name1 = write(name1) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, .4, 0),
						Position = UDim2.new(0.0, 0, .3, 0),
						ZIndex = 2, Parent = textContainer
					}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = Utilities.GetNameColor(name1)
				}.Frame
				name1.ZIndex = 2
				local vsText = write ' vs.' {
					Frame = name1, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left
				}.Frame
				vsText.Position = UDim2.new(1.0, 0, 0.0, 0)
				vsText.ZIndex = 2
				write(' '..name2) {
					Frame = vsText, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left, Color = Utilities.GetNameColor(name2)
				}.Frame.Position = UDim2.new(1.0, 0, 0.0, 0)
				
				local joinButton = roundedFrame:new {
					Button = true,
					CornerRadius = 15,
					BackgroundColor3 = Color3.fromRGB(47, 69, 99),
					Size = UDim2.new(.24, 0, .8, 0),
					Position = UDim2.new(.75, 0, 0.1, 0),
					ZIndex = 2, Parent = elem.gui
				}
				table.insert(newbuttons, joinButton.gui)
				write 'Spectate' {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(0.0, 0, 0.7, 0),
						Position = UDim2.new(0.5, 0, 0.15, 0),
						ZIndex = 3, Parent = joinButton.gui
					}, Scaled = true
				}
				
				elem.Parent = container
				table.insert(listelements, elem)
				battleForElement[elem] = battle
			end
		end
	end
		--]]
	-- update list
--	print('positioning list elements')
	local n = #listelements
	if n > 0 then
		none.Visible = false
		local contentRelativeSize = n * h * container.AbsoluteSize.X / scrollList.AbsoluteSize.Y
		scrollList.CanvasSize = UDim2.new(scrollList.Size.X.Scale, -1, contentRelativeSize * scrollList.Size.Y.Scale, 0)
		for i, elem in pairs(listelements) do
			elem.Position = UDim2.new(0.0, 0, h*(i-1), 0)
		end
	else
		none.Visible = true
	end
--	print('board updated')
	if #newbuttons > 0 then
		_f.Network:postAll('SpecE', 'newButtons', newbuttons)
	end
	end)
	if not s then print('board update error:', r) end
end

function board:enable(guiContainer)
	gui = guiContainer
	
	write 'Spectate a Battle' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.08, 0),
			Position = UDim2.new(0.5, 0, 0.01, 0),
			Parent = gui
		}, Scaled = true
	}
	
	none = write 'None are available at this time' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.05, 0),
			Position = UDim2.new(0.5, 0, 0.475, 0),
			Parent = gui
		}, Scaled = true
	}.Frame
	
	sbw = math.ceil(gui.AbsoluteSize.X*.04)
	scrollList = create 'ScrollingFrame' {
		BackgroundTransparency = 1.0,
		BorderSizePixel = 0,
		Size = UDim2.new(1.0, 0, 0.875, 0),
		Position = UDim2.new(0.0, 0, 0.15, 0),
		ScrollBarThickness = sbw,
		Parent = gui
	}
	container = create 'Frame' {
		BackgroundTransparency = 1.0,
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Size = UDim2.new(1.0, -sbw, 1.0, -sbw),
		Parent = scrollList
	}
	
	self:update() -- for testing only
end

return board