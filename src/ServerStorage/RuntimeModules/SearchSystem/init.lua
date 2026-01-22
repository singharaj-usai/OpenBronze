return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local SearchSystem = {
		isOpen = false, 
		closing = Utilities.Signal()
	}

	local baseColor = Color3.fromHSV(0.591, 0.3, 0.6)
	local totalClasses = nil
	local baseFrame = nil
	local Queries = nil
	local Enum_Font_GothamBlack = Enum.Font.GothamBlack

	local SearchSystemClass = Utilities.class({
		enabled = false
	}, function(tbl, title)
		local classNum = totalClasses + 1
		totalClasses = classNum
		tbl.title = title
		tbl.order = classNum
		tbl.gui = create("Frame")({
			BorderSizePixel = 2, 
			BorderColor3 = Color3.fromRGB(27, 42, 53), 
			BackgroundColor3 = baseColor, 
			Size = UDim2.new(0.96, 0, 0.2, 0), 
			LayoutOrder = classNum, 
			ZIndex = 5, 
			Parent = baseFrame
		})
		tbl.headContainer = create("Frame")({
			BackgroundTransparency = 1, 
			SizeConstraint = Enum.SizeConstraint.RelativeXX, 
			Size = UDim2.new(1, 0, 0.1, 0), 
			Parent = tbl.gui
		})
		tbl.titleLabel = create("TextLabel")({
			BackgroundTransparency = 1, 
			Size = UDim2.new(0.3, 0, 0.5, 0), 
			Position = UDim2.new(0.15, 0, 0.25, 0), 
			Font = Enum_Font_GothamBlack, 
			Text = title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextScaled = true, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			ZIndex = 6, 
			Parent = tbl.headContainer
		})
		tbl.toggleButton = create("ImageButton")({
			AutoButtonColor = false, 
			BorderSizePixel = 2, 
			BorderColor3 = Color3.new(0.7, 0.7, 0.7), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			SizeConstraint = Enum.SizeConstraint.RelativeXX, 
			Size = UDim2.new(0.07, 0, 0.07, 0), 
			AnchorPoint = Vector2.new(0, 0.5), 
			Position = UDim2.new(0.02, 0, 0.5, 0), 
			ZIndex = 6, 
			Parent = tbl.headContainer,
			MouseButton1Click = function()
				if not tbl.enabled and tbl.canEnable and not tbl:canEnable() then
					return
				end
				tbl:setEnabled(not tbl.enabled)
			end
		})
		tbl.toggleCheck = create("ImageLabel")({
			BackgroundTransparency = 1, 
			Image = "rbxassetid://16643646628", 
			ImageRectSize = Vector2.new(450, 450), 
			ImageColor3 = Color3.fromRGB(124, 186, 99), 
			Size = UDim2.new(1.2, 0, 1.2, 0), 
			Position = UDim2.new(-0.05, 0, -0.1, 0), 
			Visible = false, 
			ZIndex = 7, 
			Parent = tbl.toggleButton
		})
		tbl.resetCallbacks = {}
		Queries[classNum] = tbl
		return tbl
	end)
	function SearchSystemClass:modifyQuery()

	end
	local buttonColor = Color3.fromRGB(100, 170, 255)
	function SearchSystemClass:setEnabled(isEnabled)
		self.enabled = isEnabled
		self.toggleCheck.Visible = isEnabled
		self.gui.BackgroundColor3 = isEnabled and buttonColor or baseColor
	end
	function SearchSystemClass:reset()
		for _, functionName in pairs(self.resetCallbacks) do
			functionName()
		end
		self:setEnabled(false)
	end
	local toId = Utilities.toId
	local function u9(p9, p10)
		local function u11(p13, p14)
			local v8 = p9[p14]
			local v9 = p13 - 1
			for v10 = p13, p14 - 1 do
				if p9[v10] < v8 then
					v9 = v9 + 1
					if v9 ~= v10 then
						p9[v9] = p9[v10]
						p9[v10] = p9[v9]
						p10[v9] = p10[v10]
						p10[v10] = p10[v9]
					end
				end
			end
			p9[v9 + 1] = p9[p14]
			p9[p14] = p9[v9 + 1]
			p10[v9 + 1] = p10[p14]
			p10[p14] = p10[v9 + 1]
			return v9 + 1
		end
		local function u12(p15, p16)
			if p15 < p16 then
				local v11 = u11(p15, p16)
				u12(p15, v11 - 1)
				u12(v11 + 1, p16)
			end
		end
		u12(1, #p9)
	end
	local DropDown = require(script.DropDownGotham)(_p)
	local updateState = nil
	local function SetupSearchOption(BaseGUI, possibleOptions, addIsAllOf, addOrNotAndAllOrNone, options)
		if not options or options == {} then
			options = { "is:", "is not:", "is only:", "is any of:", "is all of:", "is none of:", "is exactly:" }
		end
		local isOrNot = { options[1], options[2] }
		local isAllOrNone = { options[4], options[6] }
		if addIsAllOf then
			table.insert(isAllOrNone, 2, options[5])
		end
		if addOrNotAndAllOrNone then
			table.insert(isOrNot, options[3])
			table.insert(isAllOrNone, options[7])
		end
		local Ids = {}
		if not possibleOptions then possibleOptions = {} end
		for i, v in pairs(possibleOptions) do
			Ids[i] = toId(v)
		end
		-- u9(Ids, possibleOptions)
		local newDropDown = DropDown:new(BaseGUI.headContainer, isOrNot, 0.6)
		newDropDown:setSize(UDim2.new(0.4, 0, 0.5, 0))
		newDropDown:setPosition(UDim2.new(0.5, 0, 0.25, 0))
		BaseGUI.dropDown = newDropDown
		local textUis = {}
		local lastHad = false
		BaseGUI.gui.Size = UDim2.new(0.96, 0, 0.12, 20)
		local optionBg = create("Frame")({
			BorderSizePixel = 2, 
			BorderColor3 = Color3.fromRGB(27, 42, 53), 
			BackgroundColor3 = Color3.fromRGB(99, 99, 105), 
			Size = UDim2.new(0.95, 0, 0, 20), 
			Position = UDim2.new(0.025, 0, 1.05, 0), 
			ZIndex = 5, 
			Parent = BaseGUI.headContainer
		})
		local AddButton = nil
		local function updateOpts()
			local has = #textUis > 1
			if has ~= lastHad then
				local opts = newDropDown.valueIndex
				if addOrNotAndAllOrNone then
					if addIsAllOf then
						if has then
							if opts > 1 then
								opts = opts + 1
							end
						elseif opts > 1 then
							opts = opts - 1
						end
					else
						error("case not expected if needed, implement")
					end
				elseif addIsAllOf then
					if has then
						if opts == 2 then
							opts = 3
						end
					elseif opts > 1 then
						opts = opts - 1
					end
				end
				newDropDown:setOptions(has and isAllOrNone or isOrNot, opts)
				lastHad = has
			end
		end
		local TextBoxLeft = create("TextBox")({
			BackgroundTransparency = 1, 
			Size = UDim2.new(1, -10, 0, 20), 
			Font = Enum_Font_GothamBlack, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextXAlignment = Enum.TextXAlignment.Left, 
			TextScaled = true, 
			ZIndex = 6
		})
		local lastId = nil
		local idIndexes = nil
		local num = nil
		local FrameGrey = create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = Color3.fromRGB(130, 130, 141), 
			Position = UDim2.new(0, 0, 1, 0), 
			ZIndex = 11
		})
		local function updateTexts(indexes)
			if not indexes or #indexes == 0 then
				FrameGrey.Parent = nil
				updateState = nil
				return
			end
			FrameGrey:ClearAllChildren()
			local v = math.min(10, #indexes)
			local texts = {}
			local active = nil
			for i = 1, v do
				local a = true
				if i ~= num then
					a = false
					if num == nil then
						a = i == 1
					end
				end
				texts[i] = create("TextButton")({
					BorderSizePixel = 0, 
					BackgroundColor3 = Color3.fromRGB(0, 180, 204),
					BackgroundTransparency = a and 0 or 1,
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 0, 0, 20 * (i - 1)),
					Text = "  " .. possibleOptions[indexes[i]],
					Font = Enum_Font_GothamBlack,
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					ZIndex = 12,
					Parent = FrameGrey,
				})
				if a then
					active = texts[i]
				end
				FrameGrey.Size = UDim2.new(1, 0, 0, 20 * i)
			end
			updateState = function(n)
				num = math.max(1, math.min(v, (num or 1) + n))
				if active then
					active.BackgroundTransparency = 1
				end
				active = texts[num]
				active.BackgroundTransparency = 0
			end
			FrameGrey.Parent = optionBg
		end
		local function updateData()
			if #Ids == 0 then
				return
			end
			local id = toId(TextBoxLeft.Text)
			if id == "" then
				lastId = nil
				idIndexes = nil
				num = nil
				updateTexts()
				return
			end
			if id == lastId then
				return
			end

			-- Sorry brad but why'd you have to complicate it?
			idIndexes = {}

			local function isAdded(name)
				for i, v in pairs(textUis) do
					if toId(v.Text) == name then
						return true
					end
				end
				return false
			end

			for i, iId in pairs(Ids) do
				if iId:lower():sub(1, #id) == id:lower() and not isAdded(iId) then
					table.insert(idIndexes, i)
				end
			end

			--local l = id:len()
			--local ll = lastId and lastId:len()
			--if lastId and ll < l and id:sub(1, ll) == lastId then
			--	local doTake = false
			--	for i = #idIndexes, 1, -1 do
			--		if Ids[idIndexes[i]]:sub(1, l) ~= id then
			--			table.remove(idIndexes, i)
			--			if doTake then
			--				num = num - 1
			--			elseif i == num then
			--				num = nil
			--			end
			--		elseif i == num then
			--			doTake = true
			--		end
			--	end
			--else
			--	local index = nil
			--	if num then
			--		index = idIndexes[num]
			--	end
			--	num = nil
			--	idIndexes = {}
			--	local take = 1
			--	local nIds = #Ids
			--	if id <= Ids[1] then
			--		nIds = 1
			--	else	
			--		while not (nIds - take <= 1) do
			--			local res = take + math.ceil((nIds - take + 1) / 2) - 1
			--			if Ids[res] < id then
			--				take = res
			--			else
			--				nIds = res
			--			end					
			--		end
			--	end
			--	for i = nIds, #Ids do
			--		if id ~= Ids[i]:sub(1, l) then
			--			break
			--		end
			--		table.insert(idIndexes, i)
			--		if i == index then
			--			num = #idIndexes
			--		end
			--	end
			--end
			lastId = id
			updateTexts(idIndexes)
		end
		TextBoxLeft:GetPropertyChangedSignal("Text"):connect(function()-- Changed
			if TextBoxLeft:IsFocused() then
				updateData()
			end
		end)
		local function writeText(text, white)
			local nTextUis = #textUis
			local ui; ui = create("TextButton")({
				BackgroundTransparency = 1, 
				Size = UDim2.new(1, -10, 0, 20), 
				Position = UDim2.new(0, 5, 0, 20 * nTextUis), 
				Text = text, 
				Font = Enum_Font_GothamBlack, 
				TextColor3 = white and Color3.new(1, 1, 1) or Color3.new(1, 0.3, 0.3), 
				TextXAlignment = Enum.TextXAlignment.Left, 
				TextScaled = true, 
				ZIndex = 6, 
				Parent = optionBg,
				MouseButton1Click = function()
					local n = #textUis
					for i = 1, n do
						task.wait()
						if textUis[i] == ui then
							for v = i, n - 1 do
								local _next = textUis[v + 1]
								textUis[v] = _next
								_next.Position = _next.Position + UDim2.new(0, 0, 0, -20)
							end
							textUis[n] = nil
							ui:Destroy()
							break
						end
					end
					AddButton.Position = UDim2.new(0, 5, 0, 20 * (n - 1))
					optionBg.Size = UDim2.new(0.95, 0, 0, 20 * n)
					BaseGUI.gui.Size = UDim2.new(0.96, 0, 0.12, 20 * n)
					updateOpts()
				end
			})
			textUis[nTextUis + 1] = ui
			AddButton.Position = UDim2.new(0, 5, 0, 20 * (nTextUis + 1))
			AddButton.Parent = optionBg
			optionBg.Size = UDim2.new(0.95, 0, 0, 20 * (nTextUis + 2))
			BaseGUI.gui.Size = UDim2.new(0.96, 0, 0.12, 20 * (nTextUis + 2))
			updateOpts()
			BaseGUI:setEnabled(true)
		end
		TextBoxLeft.FocusLost:connect(function(isEnter, inputCause)
			if inputCause and idIndexes and #idIndexes > 0 and (inputCause.UserInputType == Enum.UserInputType.MouseButton1 or inputCause.UserInputType == Enum.UserInputType.Touch) then
				local X = inputCause.Position.X
				if FrameGrey.AbsolutePosition.X < X and X < FrameGrey.AbsolutePosition.X + FrameGrey.AbsoluteSize.X then
					local num = math.ceil((inputCause.Position.Y - FrameGrey.AbsolutePosition.Y) / 20)
					if num > 0 and num <= #idIndexes then
						writeText(possibleOptions[idIndexes[num]], true)
						isEnter = false
					end
				end
			end
			TextBoxLeft.Parent = nil
			if isEnter and toId(TextBoxLeft.Text) ~= "" then
				if idIndexes and #idIndexes > 0 then
					writeText(possibleOptions[idIndexes[num and 1]], true)
				else
					writeText(TextBoxLeft.Text, false)
				end
			else
				AddButton.Parent = optionBg
			end
			lastId = nil
			idIndexes = nil
			num = nil
			updateTexts()
		end)
		AddButton = create("TextButton")({
			BackgroundTransparency = 1, 
			Size = UDim2.new(1, -10, 0, 20), 
			Position = UDim2.new(0, 5, 0, 0), 
			Text = "+ Add", 
			Font = Enum_Font_GothamBlack, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextXAlignment = Enum.TextXAlignment.Left, 
			TextScaled = true, 
			ZIndex = 6, 
			Parent = optionBg, 
			MouseButton1Click = function()
				AddButton.Parent = nil
				TextBoxLeft.Text = ""
				TextBoxLeft.Position = AddButton.Position
				TextBoxLeft.Parent = optionBg
				TextBoxLeft:CaptureFocus()
				lastId = nil
				idIndexes = nil
				num = nil
			end
		})
		table.insert(BaseGUI.resetCallbacks, function()
			for i, v in pairs(textUis) do
				v:Destroy()
			end
			textUis = {}
			AddButton.Position = UDim2.new(0, 5, 0, 0)
			optionBg.Size = UDim2.new(0.95, 0, 0, 20)
			BaseGUI.gui.Size = UDim2.new(0.96, 0, 0.12, 20)
			updateOpts()
			newDropDown:setValue(1)
		end)
		function BaseGUI:modifyQuery(list)
			local index = newDropDown.valueIndex
			if addIsAllOf and #textUis < 2 then
				index = index + 1
			end
			local opt = toId(self.title)
			list[opt .. "Option"] = index
			local d = {}
			for i, v in pairs(textUis) do
				d[i] = v.Text
			end
			list[opt .. "List"] = d
		end
	end
	function SearchSystem:open(baseFramePC, onOpenFn)
		if self.isOpen then
			return
		end
		self.isOpen = true
		self.results = nil
		if self.rootGui then
			onOpenFn()
			self.closing:wait()
			return self.results
		end
		Queries = {}
		totalClasses = 0
		local registeredSpecies, HeldItems, registeredAbilities, registeredMoves, registeredEggGroups, registeredFormes, registeredNicknames = _p.Network:get("PDS", "cPC", "getSearchableLists")
		onOpenFn()
		local TopFrame = create("Frame")({
			BackgroundColor3 = Color3.fromRGB(102, 204, 255), 
			BorderColor3 = Color3.fromRGB(0, 102, 153), 
			BorderSizePixel = 2, 
			SizeConstraint = Enum.SizeConstraint.RelativeYY, 
			Size = UDim2.new(0.8, 4, 0.8, 0), 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			ZIndex = 3, 
			Parent = baseFramePC
		})
		local TopScrollingFrame = create("ScrollingFrame")({
			BackgroundTransparency = 1, 
			BorderSizePixel = 0, 
			TopImage = "rbxassetid://3763595294", 
			MidImage = "rbxassetid://3763596048", 
			BottomImage = "rbxassetid://3763596631", 
			ScrollBarImageTransparency = 0.3, 
			ScrollBarImageColor3 = Color3.fromRGB(24, 24, 24), 
			ScrollingDirection = Enum.ScrollingDirection.Y, 
			Size = UDim2.new(1, -4, 0.92, 0), 
			ZIndex = 4, 
			Parent = TopFrame
		})
		baseFrame = create("Frame")({
			BackgroundTransparency = 1, 
			SizeConstraint = Enum.SizeConstraint.RelativeXX, 
			Parent = TopScrollingFrame
		})
		local xPos = nil
		local UIListLayout = create("UIListLayout")({
			Padding = UDim.new(0.02, 0), 
			FillDirection = Enum.FillDirection.Vertical, 
			HorizontalAlignment = Enum.HorizontalAlignment.Center, 
			VerticalAlignment = Enum.VerticalAlignment.Top, 
			SortOrder = Enum.SortOrder.LayoutOrder, 
			Parent = baseFrame
		})
		local canvasPos = false
		local function updateCanvas()
			TopScrollingFrame.CanvasSize = UDim2.new(1, -xPos, 0, UIListLayout.AbsoluteContentSize.Y + xPos * 2)
			if canvasPos then
				TopScrollingFrame.CanvasPosition = Vector2.new(TopScrollingFrame.CanvasPosition.X, TopScrollingFrame.CanvasSize.Y.Offset - TopScrollingFrame.AbsoluteWindowSize.Y)
			end
		end
		create("ImageButton")({
			AutoButtonColor = false, 
			BackgroundColor3 = Color3.fromRGB(72, 165, 223), 
			BorderColor3 = Color3.fromRGB(0, 102, 153), 
			Size = UDim2.new(0.25, 0, 0.06, 0), 
			Position = UDim2.new(0.0125, 0, 0.93, 0), 
			ZIndex = 4, 
			Parent = TopFrame, 
			MouseButton1Click = function()
				SearchSystem:close()
			end,
			create("TextLabel")({
				BackgroundTransparency = 1, 
				Text = "Cancel", 
				Font = Enum_Font_GothamBlack, 
				TextScaled = true, 
				TextColor3 = Color3.new(1, 1, 1), 
				Size = UDim2.new(1, 0, 0.5, 0), 
				Position = UDim2.new(0, 0, 0.25, 0), 
				ZIndex = 5
			})
		})
		create("ImageButton")({
			AutoButtonColor = false, 
			BackgroundColor3 = Color3.fromRGB(72, 165, 223), 
			BorderColor3 = Color3.fromRGB(0, 102, 153), 
			Size = UDim2.new(0.25, 0, 0.06, 0), 
			Position = UDim2.new(0.275, 0, 0.93, 0), 
			ZIndex = 4, 
			Parent = TopFrame, 
			MouseButton1Click = function()
				SearchSystem:reset()
			end,
			create("TextLabel")({
				BackgroundTransparency = 1, 
				Text = "Reset", 
				Font = Enum_Font_GothamBlack, 
				TextScaled = true, 
				TextColor3 = Color3.new(1, 1, 1), 
				Size = UDim2.new(1, 0, 0.5, 0), 
				Position = UDim2.new(0, 0, 0.25, 0), 
				ZIndex = 5
			})
		})
		create("ImageButton")({
			AutoButtonColor = false, 
			BackgroundColor3 = Color3.fromRGB(72, 165, 223), 
			BorderColor3 = Color3.fromRGB(0, 102, 153), 
			Size = UDim2.new(0.25, 0, 0.06, 0), 
			Position = UDim2.new(0.7375, 0, 0.93, 0), 
			ZIndex = 4, 
			Parent = TopFrame, 
			MouseButton1Click = function()
				SearchSystem:submit()
			end,
			create("TextLabel")({
				BackgroundTransparency = 1, 
				Text = "Search", 
				Font = Enum_Font_GothamBlack, 
				TextScaled = true, 
				TextColor3 = Color3.new(1, 1, 1), 
				Size = UDim2.new(1, 0, 0.5, 0), 
				Position = UDim2.new(0, 0, 0.25, 0), 
				ZIndex = 5
			})
		})
		local Cns = {}
		local function updateBFrame()
			xPos = Utilities.gui.AbsoluteSize.Y * 0.03
			TopScrollingFrame.ScrollBarThickness = xPos
			baseFrame.Size = UDim2.new(1, -xPos, 1, -xPos)
			baseFrame.Position = UDim2.new(0, 0, 0, xPos)
			updateCanvas()
		end

		local function makeStatOptions(name, defNum)
			local statOption = SearchSystemClass:new({}, name)
			statOption.gui.Size = UDim2.new(0.96, 0, 0.12, 20)
			local statsData = {}
			local SpecialQuerys = statOption
			local bg = create("Frame")({
				BorderSizePixel = 2, 
				BorderColor3 = Color3.fromRGB(27, 42, 53), 
				BackgroundColor3 = Color3.fromRGB(99, 99, 105), 
				Size = UDim2.new(0.95, 0, 0, 20), 
				Position = UDim2.new(0.025, 0, 1.05, 0), 
				ZIndex = 5, 
				Parent = statOption.headContainer
			})
			local AddNewQuery = nil

			local function updateStatQuerySize()
				local countUpdated = #statsData+1

				AddNewQuery.Position = UDim2.new(0, 5, 0, 20 * (countUpdated - 1))
				bg.Size = UDim2.new(0.95, 0, 0, 20 * countUpdated)
				SpecialQuerys.gui.Size = UDim2.new(0.96, 0, 0.12, 20 * countUpdated)
				if countUpdated == 1 then
					SpecialQuerys:setEnabled(false)
				end
				updateCanvas()
			end

			AddNewQuery = create("TextButton")({
				BackgroundTransparency = 1, 
				Size = UDim2.new(1, -10, 0, 20), 
				Position = UDim2.new(0, 5, 0, 0), 
				Text = "+ Add", 
				Font = Enum_Font_GothamBlack, 
				TextColor3 = Color3.new(1, 1, 1), 
				TextXAlignment = Enum.TextXAlignment.Left, 
				TextScaled = true, 
				ZIndex = 6, 
				Parent = bg, 
				MouseButton1Click = function()
					local count = #statsData
					SpecialQuerys:setEnabled(true)
					local StatBg = create("Frame")({
						BackgroundTransparency = 1, 
						Size = UDim2.new(1, -10, 0, 20), 
						Position = UDim2.new(0, 5, 0, 20 * count), 
						Parent = bg
					})

					local btn = create("ImageButton")({
						AutoButtonColor = false, 
						BorderColor3 = Color3.fromRGB(102, 0, 0), 
						BackgroundColor3 = Color3.fromRGB(255, 51, 51), 
						Size = UDim2.new(0, 14, 0, 14), 
						Position = UDim2.new(0, 8, 0, 3), 
						ZIndex = 6, 
						Parent = StatBg,
						MouseButton1Click = function()
							local countUpdated = #statsData
							for i = 1, countUpdated do
								if statsData[i].gui == StatBg then
									for v = i, countUpdated - 1 do
										local _next = statsData[v + 1]
										statsData[v] = _next
										_next.gui.Position = _next.gui.Position + UDim2.new(0, 0, 0, -20)
									end
									statsData[countUpdated] = nil

									StatBg:Destroy()
									break
								end
							end
							updateStatQuerySize()
						end,				
						create("Frame")({
							BorderSizePixel = 0, 
							BackgroundColor3 = Color3.fromRGB(102, 0, 0), 
							Size = UDim2.new(0, 8, 0, 2), 
							Position = UDim2.new(0, 3, 0, 6), 
							ZIndex = 7
						})
					})

					local Stat = DropDown:new(StatBg, {"Health", "Attack", "Defense", "Sp. Attack", "Sp. Defense", "Speed"}, 0.58)
					Stat:setSize(UDim2.new(0.2, 0, 0, 18))
					Stat:setPosition(UDim2.new(0.08, 0, 0, 1))

					local GreaterLessEqual = DropDown:new(StatBg, {"greater than", "less than", "equals"}, 0.58)
					GreaterLessEqual:setSize(UDim2.new(0.3, 0, 0, 18))
					GreaterLessEqual:setPosition(UDim2.new(0.3, 0, 0, 1))	

					local numLabel; numLabel = create("TextBox")({
						BorderSizePixel = 0, 
						BackgroundColor3 = Color3.fromHSV(0.58, 0.821, 0.725), 
						Size = UDim2.new(0.2, 0, 0, 18), 
						Position = UDim2.new(0.62, 0, 0, 1), 
						Text = tostring(defNum), 
						Font = Enum_Font_GothamBlack, 
						TextScaled = true, 
						TextColor3 = Color3.new(1, 1, 1), 
						TextXAlignment = Enum.TextXAlignment.Left, 
						ZIndex = 7, 
						Parent = StatBg,
						FocusLost = function ()
							local num = tonumber(numLabel.Text)
							if not num then
								numLabel.TextColor3 = Color3.new(1, 0, 0)
								return
							end			
							--numLabel.Text = tostring((math.max(1, math.min(100, num))))
							numLabel.TextColor3 = Color3.new(1, 1, 1)
						end,
						Focused = function()
							numLabel.TextColor3 = Color3.new(1, 1, 1)
						end
					})

					statsData[count + 1] = {
						gui = StatBg, 
						GreaterLessEqual = GreaterLessEqual, 
						Stat = Stat,
						numberInput = numLabel
					}

					AddNewQuery.Position = UDim2.new(0, 5, 0, 20 * (count + 1))
					AddNewQuery.Parent = bg
					bg.Size = UDim2.new(0.95, 0, 0, 20 * (count + 2))
					SpecialQuerys.gui.Size = UDim2.new(0.96, 0, 0.12, 20 * (count + 2))

					updateCanvas()
				end
			})

			function SpecialQuerys:modifyQuery(data)
				local id = string.lower(string.gsub(name, " ", "")).."List"
				local list = {}

				for i, v in pairs(statsData) do
					local n = tonumber(v.numberInput.Text)
					local s = tonumber(v.Stat.valueIndex)
					if n then
						if not list[s] then list[s] = {} end
						table.insert(list[s], {
							v.GreaterLessEqual.valueIndex, 
							n
						})
					end
				end

				local has = false

				for i=1, 6 do
					has = list[i] ~= nil
					if has then break end
				end

				if has then
					data[id] = list
				end	
			end

			table.insert(statOption.resetCallbacks, function()
				for i, v in pairs(statsData) do
					v.gui:Destroy()
					statsData[i] = nil
				end
				updateStatQuerySize()
			end)
		end

		table.insert(Cns, Utilities.gui:GetPropertyChangedSignal("AbsoluteSize"):connect(function(val) -- .Changed
			updateBFrame()
		end))
		table.insert(Cns, game:GetService("UserInputService").InputBegan:connect(function(input)
			if not updateState then
				return
			end
			if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.DPadUp then
				updateState(-1)
				return
			end
			if input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.DPadDown then
				updateState(1)
			end
		end))
		local function updateCanvasPos()
			canvasPos = TopScrollingFrame.CanvasSize.Y.Offset - TopScrollingFrame.AbsoluteWindowSize.Y - 2 < TopScrollingFrame.CanvasPosition.Y
		end
		TopScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):connect(function() -- .Changed
			updateCanvasPos()
		end)
		updateBFrame()
		SetupSearchOption(SearchSystemClass:new({}, "Species"), registeredSpecies)
		SetupSearchOption(SearchSystemClass:new({}, "Class"), {"Starter", "Legendary", "Mythical", "Ultra Beast", "Paradox"}, true)
		SetupSearchOption(SearchSystemClass:new({}, "Generation"), {"Gen 1", "Gen 2", "Gen 3", "Gen 4", "Gen 5", "Gen 6", "Gen 7", --[["Gen 7.5",]] "Gen 8", --[["Gen 8.5",]] "Gen 9"})
		SetupSearchOption(SearchSystemClass:new({}, "Nickname"), registeredNicknames)
		SetupSearchOption(SearchSystemClass:new({}, "Form"), registeredFormes, false, false)
		SetupSearchOption(SearchSystemClass:new({}, "Held Item"), HeldItems, false, false, { "is holding:", "is not holding:", false, "is holding any of:", false, "is not holding:" })
		SetupSearchOption(SearchSystemClass:new({}, "Moves"), registeredMoves, true, false, { "knows:", "doesn't know:", "knows only:", "knows any of:", "knows all of:", "knowns none of:", "knows exactly:" })
		SetupSearchOption(SearchSystemClass:new({}, "Ability"), registeredAbilities)
		local LevelOption = SearchSystemClass:new({}, "Level")
		LevelOption.gui.Size = UDim2.new(0.96, 0, 0.12, 20)
		local levelData = {}
		local SpecialQuerys = LevelOption
		local bg = create("Frame")({
			BorderSizePixel = 2, 
			BorderColor3 = Color3.fromRGB(27, 42, 53), 
			BackgroundColor3 = Color3.fromRGB(99, 99, 105), 
			Size = UDim2.new(0.95, 0, 0, 20), 
			Position = UDim2.new(0.025, 0, 1.05, 0), 
			ZIndex = 5, 
			Parent = LevelOption.headContainer
		})
		local AddNewQuery = nil

		local function updateLevelQuerySize()
			local countUpdated = #levelData+1

			AddNewQuery.Position = UDim2.new(0, 5, 0, 20 * (countUpdated - 1))
			bg.Size = UDim2.new(0.95, 0, 0, 20 * countUpdated)
			SpecialQuerys.gui.Size = UDim2.new(0.96, 0, 0.12, 20 * countUpdated)
			if countUpdated == 1 then
				SpecialQuerys:setEnabled(false)
			end
		end

		AddNewQuery = create("TextButton")({
			BackgroundTransparency = 1, 
			Size = UDim2.new(1, -10, 0, 20), 
			Position = UDim2.new(0, 5, 0, 0), 
			Text = "+ Add", 
			Font = Enum_Font_GothamBlack, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextXAlignment = Enum.TextXAlignment.Left, 
			TextScaled = true, 
			ZIndex = 6, 
			Parent = bg, 
			MouseButton1Click = function()
				local count = #levelData
				SpecialQuerys:setEnabled(true)
				local LvlBg = create("Frame")({
					BackgroundTransparency = 1, 
					Size = UDim2.new(1, -10, 0, 20), 
					Position = UDim2.new(0, 5, 0, 20 * count), 
					Parent = bg
				})

				local btn = create("ImageButton")({
					AutoButtonColor = false, 
					BorderColor3 = Color3.fromRGB(102, 0, 0), 
					BackgroundColor3 = Color3.fromRGB(255, 51, 51), 
					Size = UDim2.new(0, 14, 0, 14), 
					Position = UDim2.new(0, 8, 0, 3), 
					ZIndex = 6, 
					Parent = LvlBg,
					MouseButton1Click = function()
						local countUpdated = #levelData
						for i = 1, countUpdated do
							if levelData[i].gui == LvlBg then
								for v = i, countUpdated - 1 do
									local _next = levelData[v + 1]
									levelData[v] = _next
									_next.gui.Position = _next.gui.Position + UDim2.new(0, 0, 0, -20)
								end
								levelData[countUpdated] = nil

								LvlBg:Destroy()
								break
							end
						end
						updateLevelQuerySize()
					end,				
					create("Frame")({
						BorderSizePixel = 0, 
						BackgroundColor3 = Color3.fromRGB(102, 0, 0), 
						Size = UDim2.new(0, 8, 0, 2), 
						Position = UDim2.new(0, 3, 0, 6), 
						ZIndex = 7
					})
				})
				local GreaterLessEqual = DropDown:new(LvlBg, { "greater than", "less than", "equals" }, 0.58)
				GreaterLessEqual:setSize(UDim2.new(0.3, 0, 0, 18))
				GreaterLessEqual:setPosition(UDim2.new(0.08, 0, 0, 1))	
				local MidLevel50; MidLevel50 = create("TextBox")({
					BorderSizePixel = 0, 
					BackgroundColor3 = Color3.fromHSV(0.58, 0.821, 0.725), 
					Size = UDim2.new(0.2, 0, 0, 18), 
					Position = UDim2.new(0.4, 0, 0, 1), 
					Text = "50", 
					Font = Enum_Font_GothamBlack, 
					TextScaled = true, 
					TextColor3 = Color3.new(1, 1, 1), 
					TextXAlignment = Enum.TextXAlignment.Left, 
					ZIndex = 7, 
					Parent = LvlBg,
					FocusLost = function ()
						local num = tonumber(MidLevel50.Text)
						if not num then
							MidLevel50.TextColor3 = Color3.new(1, 0, 0)
							return
						end
						MidLevel50.Text = tostring((math.max(1, math.min(100, num))))
						MidLevel50.TextColor3 = Color3.new(1, 1, 1)
					end,
					Focused = function()
						MidLevel50.TextColor3 = Color3.new(1, 1, 1)
					end
				})

				levelData[count + 1] = {
					gui = LvlBg, 
					dropdown = GreaterLessEqual, 
					numberInput = MidLevel50
				}
				AddNewQuery.Position = UDim2.new(0, 5, 0, 20 * (count + 1))
				AddNewQuery.Parent = bg
				bg.Size = UDim2.new(0.95, 0, 0, 20 * (count + 2))
				SpecialQuerys.gui.Size = UDim2.new(0.96, 0, 0.12, 20 * (count + 2))

				updateCanvas()
			end
		})
		function SpecialQuerys:modifyQuery(data)
			local list = {}
			for i, v in pairs(levelData) do
				local n = tonumber(v.numberInput.Text)
				if n then
					table.insert(list, { v.dropdown.valueIndex, n })
				end
			end
			if #list > 0 then
				data.levelList = list
			end
		end

		table.insert(LevelOption.resetCallbacks, function()
			for i, v in pairs(levelData) do
				v.gui:Destroy()
				levelData[i] = nil
			end
			updateLevelQuerySize()
		end)

		SetupSearchOption(SearchSystemClass:new({}, "Type"), {'Bug','Dark','Dragon','Electric','Fairy','Fighting','Fire','Flying','Ghost','Grass','Ground','Ice','Normal','Poison','Psychic','Rock','Steel','Water'}, true)
		local DataClass = SearchSystemClass:new({}, "Flags")
		DataClass.gui.Size = UDim2.new(0.96, 0, 0.095, 0)
		local flagsUis = {}
		local flags = { 
			{"Shiny", BrickColor.new('Persimmon').Color, 0.39}, 
			{"HA", BrickColor.new('Mint').Color, 0.57},
			--{"Alpha", Color3.new(.6, 0, 0), 0.68}, 


		}

		-- {"Swapped Ability", BrickColor.new("Pastel light blue").Color, 0.74}, 
		-- ^ Maybe? Color3.new(.9, .3, .3)
		-- do we add "Event"?

		for i, v in pairs(flags) do
			local state_ui = create("ImageLabel")({
				BackgroundTransparency = 1, 
				Image = "rbxassetid://16643646628", 
				ImageRectSize = Vector2.new(450, 450), 
				ImageColor3 = Color3.fromRGB(124, 186, 99), 
				Size = UDim2.new(1.2, 0, 1.2, 0), 
				Position = UDim2.new(-0.05, 0, -0.1, 0), 
				Visible = false, 
				ZIndex = 7
			})
			flagsUis[i] = state_ui

			local btn = create("ImageButton")({
				AutoButtonColor = false, 
				BorderSizePixel = 2, 
				BorderColor3 = Color3.new(0.7, 0.7, 0.7), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				SizeConstraint = Enum.SizeConstraint.RelativeXX, 
				Size = UDim2.new(0.04, 0, 0.04, 0), 
				AnchorPoint = Vector2.new(0, 0.5), 
				Position = UDim2.new(v[3], 0, 0.5, 0), 
				ZIndex = 6, 
				Parent = DataClass.headContainer,
				MouseButton1Click =function ()
					state_ui.Visible = not state_ui.Visible
					local enabled = false

					for i, flagUi in pairs(flagsUis) do
						enabled = flagUi.Visible
						if enabled then break end
					end

					DataClass:setEnabled(enabled)
				end,
				state_ui
			})
			create("TextLabel")({
				BackgroundTransparency = 1, 
				Text = v[1], 
				Font = Enum_Font_GothamBlack, 
				TextScaled = true, 
				TextColor3 = v[2], 
				TextXAlignment = Enum.TextXAlignment.Left, 
				Size = UDim2.new(0.3, 0, 0.4, 0), 
				Position = UDim2.new(v[3] + 0.05, 0, 0.3, 0), 
				ZIndex = 6, 
				Parent = DataClass.headContainer
			})
		end
		--function DataClass.canEnable()
		--	return flagsUis[1].Visible or (flagsUis[2].Visible or flagsUis[3].Visible)
		--end
		table.insert(DataClass.resetCallbacks, function()
			for i, v in pairs(flagsUis) do
				v.Visible = false
			end
		end)
		function DataClass:modifyQuery(data)
			local d = {}

			for i, v in pairs(flagsUis) do
				d[i] = flagsUis[i].Visible
			end

			data.flagsList = d -- { flagsUis[1].Visible, flagsUis[2].Visible, flagsUis[3].Visible }
		end

		--local HAQuery = SearchSystemClass:new({}, "Hidden Ability")
		--local ha_dd = DropDown:new(HAQuery.headContainer, { "has HA", "doesn't have HA" }, 0.6)
		--ha_dd:setSize(UDim2.new(0.4, 0, 0.5, 0))
		--ha_dd:setPosition(UDim2.new(0.5, 0, 0.25, 0))
		--HAQuery.gui.Size = UDim2.new(0.96, 0, 0.095, 0)
		--ha_dd.changed:connect(function()
		--	HAQuery:setEnabled(true)
		--end)
		--table.insert(HAQuery.resetCallbacks, function()
		--	ha_dd:setValue(1)
		--end)
		--function HAQuery:modifyQuery(data)
		--	data.secretAbility = ha_dd.valueIndex == 1
		--end

		SetupSearchOption(SearchSystemClass:new({}, "Nature"), {'Hardy', 'Lonely', 'Brave', 'Adamant', 'Naughty', 'Bold', 'Docile', 'Relaxed', 'Impish', 'Lax', 'Timid', 'Hasty', 'Serious', 'Jolly', 'Naive', 'Modest', 'Mild', 'Quiet', 'Bashful', 'Rash', 'Calm', 'Gentle', 'Sassy', 'Careful', 'Quirky'})
		SetupSearchOption(SearchSystemClass:new({}, "Egg Group"), registeredEggGroups)
		local GenderQuery = SearchSystemClass:new({}, "Gender")
		GenderQuery.gui.Size = UDim2.new(0.96, 0, 0.095, 0)
		local genderUis = {}
		for i, v in pairs({ { "[M]", Color3.fromRGB(51, 102, 255) }, { "[F]", Color3.fromRGB(255, 102, 153) }, { "Genderless", Color3.new(1, 1, 1) } }) do
			local state_ui = create("ImageLabel")({
				BackgroundTransparency = 1, 
				Image = "rbxassetid://16643646628", 
				ImageRectSize = Vector2.new(450, 450), 
				ImageColor3 = Color3.fromRGB(124, 186, 99), 
				Size = UDim2.new(1.2, 0, 1.2, 0), 
				Position = UDim2.new(-0.05, 0, -0.1, 0), 
				Visible = false, 
				ZIndex = 7
			})
			genderUis[i] = state_ui

			local btn = create("ImageButton")({
				AutoButtonColor = false, 
				BorderSizePixel = 2, 
				BorderColor3 = Color3.new(0.7, 0.7, 0.7), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				SizeConstraint = Enum.SizeConstraint.RelativeXX, 
				Size = UDim2.new(0.04, 0, 0.04, 0), 
				AnchorPoint = Vector2.new(0, 0.5), 
				Position = UDim2.new(0.2 + 0.15 * i, 0, 0.5, 0), 
				ZIndex = 6, 
				Parent = GenderQuery.headContainer,
				MouseButton1Click =  function()
					state_ui.Visible = not state_ui.Visible
					GenderQuery:setEnabled(genderUis[1].Visible or (genderUis[2].Visible or genderUis[3].Visible))
				end,
				state_ui
			})

			if v[1]:sub(1, 1) == "[" then
				Utilities.Write(v[1])({
					Frame = create("Frame")({
						BackgroundTransparency = 1, 
						Size = UDim2.new(0, 0, 0.4, 0), 
						Position = UDim2.new(0.25 + 0.15 * i, 0, 0.3, 0), 
						ZIndex = 6, 
						Parent = GenderQuery.headContainer
					}), 
					Font = "Avenir", 
					Scaled = true, 
					Color = v[2], 
					TextXAlignment = Enum.TextXAlignment.Left
				})
			else
				create("TextLabel")({
					BackgroundTransparency = 1, 
					Text = v[1], 
					Font = Enum_Font_GothamBlack, 
					TextScaled = true, 
					TextColor3 = v[2], 
					TextXAlignment = Enum.TextXAlignment.Left, 
					Size = UDim2.new(0.3, 0, 0.4, 0), 
					Position = UDim2.new(0.25 + 0.15 * i, 0, 0.3, 0), 
					ZIndex = 6, 
					Parent = GenderQuery.headContainer
				})
			end
		end
		function GenderQuery:canEnable()
			return genderUis[1].Visible or (genderUis[2].Visible or genderUis[3].Visible)
		end
		table.insert(GenderQuery.resetCallbacks, function()
			for i, v in pairs(genderUis) do
				v.Visible = false
			end
		end)
		function GenderQuery:modifyQuery(data)
			data.genderList = { genderUis[1].Visible, genderUis[2].Visible, genderUis[3].Visible }
		end
		local acs = UIListLayout.AbsoluteContentSize
		GenderQuery.gui:GetPropertyChangedSignal("AbsolutePosition"):connect(function(val) -- .Changed
			if UIListLayout.AbsoluteContentSize ~= acs then
				acs = UIListLayout.AbsoluteContentSize
				updateCanvas()
			end
		end)

		makeStatOptions("Base Stats", 0)
		makeStatOptions("Stats", 0)
		makeStatOptions("IVs", 31)
		makeStatOptions("EVs", 0)

		self.rootGui = baseFramePC
		self.connections = Cns
		self.mainWindow = TopFrame
		updateBFrame()
		self.closing:wait()
		return self.results
	end
	function SearchSystem:close()
		if not self.isOpen then
			return
		end
		self.isOpen = false
		pcall(function()
			self.rootGui.Parent = nil
		end)
		self.closing:fire()
	end
	function SearchSystem:dump()
		pcall(function()
			self.mainWindow:Destroy()
		end)
		self.mainWindow = nil
		self.rootGui = nil
		if self.connections then
			for i, v in pairs(self.connections) do
				pcall(function()
					v:disconnect()
				end)
			end
		end
	end
	function SearchSystem:getQuery()
		local list = {}

		for _, v in pairs(Queries) do
			if v.enabled then
				v:modifyQuery(list)
			end
		end

		return list
	end
	function SearchSystem:reset()
		for _, v in pairs(Queries) do
			v:reset()
		end
	end
	function SearchSystem:submit()
		local block = create("ImageButton")({
			BackgroundTransparency = 1, 
			Size = UDim2.new(1, 0, 1, 0), 
			ZIndex = 20, 
			Parent = Utilities.simulatedCoreGui
		})
		local a = {}
		_p.DataManager:setLoading(a, true)
		self.results = _p.Network:get("PDS", "cPC", "search", self:getQuery())
		_p.DataManager:setLoading(a, false)
		self:close()
		block:Destroy()
	end
	return SearchSystem
end
