-- wish this were object oriented
-- what was I doing when I wrote this
-- and the magic numbers
-- anyways, if it ain't broke don't fix it

return function(_p)--local _p = require(script.Parent.Parent)--game:GetService('ReplicatedStorage').Plugins)
	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	--local MasterControl = _p.MasterControl

	local pc_ui = {
		mb = 8
	}

	local pc_bgs = {
		-- types
		5778176234,--298274976, -- grass    (old 297119555)
		5898708883,--297114272, -- fire
		5778189199,--297114291, -- water
		5778186295,--297114309, -- electric
		5778183307,--297119570, -- ground
		5778182542,--298274965, -- steel
		5778181278,--298274969, -- ghost (?)
		5778180201,--297309290, -- dark
		6148279752,--298752628, -- rock
		6148833693,--298754147, -- ice
		6148279728,--298754346, -- clouds
		-- scenery
		6148279797,--298752738, -- sun n moon
		6148279551,--297309259, -- volcano
		6148839679,--297309345, -- beach
		6148844677,--298752867, -- cave
		6148279651,--297309328, -- iceberg
		6148848307,--298752441, -- waterfall
		6149533701,--299360334, -- city
		6149595778,--299264515, -- galaxy
		6148279793,--299360476, -- galaxy 2
		6148279775,--299360383, -- mega charizards

		6148279569,--298752559, -- rainbow
		-- IF YOU ADD TO THIS LIST, BE SURE TO MODIFY PCService!
		16649108820, -- // Pastel Red
		16649117318, -- // Pastel Orange
		16649119977, -- // Pastel Yellow
		16649122799, -- // Pastel Green
		16649124867, -- // Pastel Cyan
		16649128677, -- // Pastel Blue
		16649131217, -- // Pastel Purple
		16649134553, -- // Pastel Pink
		16649137568, -- // Pastel White
		16649140190, -- // Gradient White
		16649142799, -- // Pink Hearts
		16649145069, -- // Small Dots
		16649418090, -- // Large Dots
		16649170410, -- // Black/Red
		16649174043, -- // Black/Yellow
		16649176929, -- // Black/Green
		16649186460, -- // Black/Blue
		16649190008, -- // Black/Purple
		16649193364, -- // Black/Pink
		16649195482, -- // Black/Rainbow
		16649199674, -- // PBB :)
	}

	--local deserializedPokemonCache
	--local boxLabels
	local partyLabel
	local dragContainerPositions
	local activeBox
	local canClosePC = true

	local enabled = true

	local mouseAbsorb = create 'ImageButton' {
		BackgroundTransparency = 1.0,
		Image = '',
		Size = UDim2.new(1.0, 0, 1.0, 0),
		ZIndex = 10,
	}
	local pcContainer = create 'Frame' {
		Name = 'PC',
		BackgroundTransparency = 1.0,
		Visible = false,
		Parent = Utilities.gui,

		create 'Frame' {
			Name = 'PartyDiv',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.25, 0, 1.0, 0),

			create 'Frame' {
				Name = 'Container',
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(350/500*0.75, 0, 0.75, 0),
			}
		},
		create 'Frame' {
			Name = 'BoxDiv',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.5, 0, 1.0, 0),
			Position = UDim2.new(0.25, 0, 0.0, 0),
		},
		create 'ScrollingFrame' {
			Name = 'OtherBoxes',
			BackgroundTransparency = 1.0,
			BorderSizePixel = 0,
			Size = UDim2.new(0.25, 0, 1.0, 0),
			Position = UDim2.new(0.75, 0, 0.0, 0),
			ZIndex = 3,

			create 'Frame' {
				Name = 'Container',
				BackgroundTransparency = 1.0,
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
			}
		},
	}

	local searchSystemMouseBlocker = create("ImageButton")({
		AutoButtonColor = false, 
		BorderSizePixel = 0, 
		BackgroundColor3 = Color3.fromRGB(24, 24, 30), 
		BackgroundTransparency = 0.6, 
		Size = UDim2.new(1, 0, 1, 36), 
		Position = UDim2.new(0, 0, 0, -36)
	})
	local searchInitializingFrame = create("Frame")({
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(102, 204, 255), 
		BorderColor3 = Color3.fromRGB(0, 102, 153), 
		BorderSizePixel = 2, 
		SizeConstraint = Enum.SizeConstraint.RelativeYY, 
		Size = UDim2.new(0.6, 0, 0.3, 0), 
		AnchorPoint = Vector2.new(0.5, 0.5), 
		Position = UDim2.new(0.5, 0, 0.5, 0), 
		ZIndex = 3, 
		Parent = searchSystemMouseBlocker,
		create("TextLabel")({
			BackgroundTransparency = 1, 
			Text = "Initializing...", 
			TextColor3 = Color3.fromRGB(0, 88, 136), 
			Font = Enum.Font.GothamBlack, 
			TextScaled = true, 
			Size = UDim2.new(0.8, 0, 0.5, 0), 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			ZIndex = 4
		})
	})	

	local menuRFs = {}
	local function onScreenResized(prop)
		if prop ~= 'AbsoluteSize' then return end
		local s = Utilities.gui.AbsoluteSize
		if s.X/2/6*5 < s.Y*0.8 then
			pcContainer.Size = UDim2.new(1.0, 0, 0.0, s.X/2/6*5)
			pcContainer.Position = UDim2.new(0.0, 0, 0.525, -pcContainer.AbsoluteSize.Y/2)
		else
			pcContainer.Size = UDim2.new(0.0, s.Y*0.8/5*6*2, 0.8, 0)
			pcContainer.Position = UDim2.new(0.5, -pcContainer.AbsoluteSize.X/2, 0.125, 0)
		end
		pcContainer.PartyDiv.Container.Position = UDim2.new(0.5, -pcContainer.PartyDiv.Container.AbsoluteSize.X/2, 0.125, 0)
		local sbw = Utilities.gui.AbsoluteSize.Y*.035
		pcContainer.OtherBoxes.ScrollBarThickness = sbw
		pcContainer.OtherBoxes.Container.Size = UDim2.new(1.0, -sbw, 1.0, -sbw)
		local scrollContainer = pcContainer.OtherBoxes
		local container = scrollContainer.Container
		local contentRelativeSize = pc_ui.mb*container.AbsoluteSize.X/scrollContainer.AbsoluteSize.Y
		scrollContainer.CanvasSize = UDim2.new(scrollContainer.Size.X.Scale, -1, contentRelativeSize * scrollContainer.Size.Y.Scale, 0)

		for _, rf in pairs(menuRFs) do rf.CornerRadius = Utilities.gui.AbsoluteSize.Y*.02 end
	end
	Utilities.gui.Changed:connect(onScreenResized)
	onScreenResized('AbsoluteSize')


	local onMoreBoxesPurchased; do
		local getMoreBoxesButton = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = BrickColor.new('Storm blue').Color,
			Size = UDim2.new(0.2, 0, 0.1, 0),
			Position = UDim2.new(0.775, 0, -0.075, 0),
			ZIndex = 5, Parent = pcContainer,
			MouseButton1Click = function()
				_p.MarketClient:promptPurchase(_p.passId.MoreBoxes)
			end,
		}
		pcContainer.OtherBoxes.Position = UDim2.new(0.75, 0, 0.05, 0)
		write 'Get More Boxes' {
			Frame = create 'Frame' {
				BackgroundTransparency = 1.0,
				Size = UDim2.new(0.0, 0, 0.45, 0),
				Position = UDim2.new(0.5, 0, 0.275, 0),
				ZIndex = 6, Parent = getMoreBoxesButton.gui,
			}, Scaled = true,
		}
		onMoreBoxesPurchased = function()
			getMoreBoxesButton:remove()
			pcContainer.OtherBoxes.Position = UDim2.new(0.75, 0, 0.0, 0)

			onMoreBoxesPurchased = function() end
		end
	end


	local deselect, selectionOptions, selectionBack, disableTakeItem, disableRelease, boxOptions, boxOptionsBack
	local function getPokemon(frame)
		local pc = pc_ui.pcData
		if frame.Name:sub(1, 9) == 'Container' then
			-- Party
			local n = tonumber(frame.Name:sub(10))
			if not n then return end
			return pc.party[n], true
		else
			-- PC
			local n = frame.Name
			local b = frame.Parent.Parent.Name:sub(4)
			local p = pc.boxes[b][n]
			return p, false, b, n
		end
	end
	local function onOptionClicked(option)
		if option == 'Summary' then
			local frame = selectionBack.Parent
			deselect()
			enabled = false
			local p = getPokemon(frame)
			if not p then enabled = true return end
			p = _p.Network:get('PDS', 'cPC', 'getSummary', p[1])
			if not p then enabled = true return end
			local party = _p.Menu.party
			party.forceSwitch = nil
			party.battleEvent = nil
			delay(1.6, function()
				enabled = true
			end)
			party:viewSummary(p, true, true)--not inParty) -- for now, we won't let you change move order from pc at all
		elseif option == 'Nickname' then -- TODO: prevent nicknaming Eggs?
			local frame = selectionBack.Parent
			deselect()
			enabled = false
			local p = getPokemon(frame)
			if not p then enabled = true return end
			local name = _p.Pokemon:giveNickname(p[2], p[3])
			_p.Network:get('PDS', 'cPC', 'nickname', p[1], name)
			enabled = true
		elseif option == 'Take Item' then
			local frame = selectionBack.Parent
			deselect()
			enabled = false
			local p = getPokemon(frame)
			if not p then enabled = true return end
			local pName, itemName = _p.Network:get('PDS', 'cPC', 'getItem', p[1])
			if pName then
				local chat = _p.NPCChat
				if not itemName then
					chat:say(pName .. ' is not holding an item!')
				elseif chat:say('[y/n]Take ' .. pName .. '\'s ' .. itemName .. '?') then
					_p.Network:get('PDS', 'cPC', 'takeItem', p[1])
				end
			end
			enabled = true
		elseif option == 'Release' then
			local frame = selectionBack.Parent
			deselect()
			if disableRelease.Visible then return end
			local p, inParty, box, position = getPokemon(frame)
			if inParty then return end
			enabled = false
			local pName = _p.Network:get('PDS', 'cPC', 'getItem', p[1])
			if pName then
				local chat = _p.NPCChat
				if chat:say('[y/n]Release ' .. pName .. '?') then
					if chat:say('This cannot be undone.', '[y/n]Are you sure you want to release ' .. pName .. '?') then
						local ch = frame:GetChildren()[1]
						local dur = 1
						if ch then
							ch:TweenSizeAndPosition(UDim2.new(0.0, 0, 0.0, 0), UDim2.new(0.5, 0, 0.5, 0), nil, nil, dur, true, function() ch:remove() end)
						end
						local pc = pc_ui.pcData
						local r = pc.rcount + 1
						pc.rcount = r
						pc.ch.m[tostring(p[1])] = {-1, r}
						pcall(function()
							local box = frame.Parent.Parent.Name:sub(4)
							local pos = frame.Name
							pc.boxes[box][pos] = nil
						end)
						frame.Active = false
						wait(dur)
						pcall(function() pcContainer.OtherBoxes.Container['Box'..box].Container[tostring(position)]:ClearAllChildren() end)
					end
				end
			end
			enabled = true
			--	elseif Marking [todo]
		end
	end
	local function selectFrame(frame)
		if not enabled then return end
		local gui = Utilities.frontGui
		if selectionOptions then
			selectionOptions.Parent = gui
			selectionBack.Parent = frame
		else
			selectionOptions = _p.RoundedFrame:new {
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.02,
				BackgroundColor3 = BrickColor.new('Cyan').Color,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.35, 0, 0.5, 0),
				Parent = gui,
			}
			table.insert(menuRFs, selectionOptions)
			local options = {'Summary', 'Nickname', 'Take Item', 'Marking', 'Release'}
			for i, o in pairs(options) do
				local gap = .0125
				local rf = _p.RoundedFrame:new {
					Button = true,
					CornerRadius = Utilities.gui.AbsoluteSize.Y*.02,
					BackgroundColor3 = Color3.new(.3, .3, .3),
					Size = UDim2.new(0.95, 0, 1/(1+gap)/#options-gap, 0),
					Position = UDim2.new(0.025, 0, (i-1)/(1+gap)/#options+gap, 0),
					ZIndex = 2, Parent = selectionOptions.gui,
					MouseButton1Click = function()
						onOptionClicked(o)
					end,
				}
				table.insert(menuRFs, rf)
				write(o) {
					Frame = create 'Frame' {
						Name = 'ButtonText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 0.5, 0),
						Position = UDim2.new(0.0, 0, 0.25, 0),
						ZIndex = 4, Parent = rf.gui,
					}, Scaled = true,
				}
				if o == 'Take Item' then
					disableTakeItem = create 'Frame' {
						BorderSizePixel = 0,
						BackgroundTransparency = 0.25,
						BackgroundColor3 = Color3.new(.3, .3, .3),
						Size = UDim2.new(.9, 0, .8, 0),
						Position = UDim2.new(.05, 0, .1, 0),
						ZIndex = 5, Parent = rf.gui,
						Visible = false,
					}
				elseif o == 'Release' then
					disableRelease = create 'Frame' {
						BorderSizePixel = 0,
						BackgroundTransparency = 0.25,
						BackgroundColor3 = Color3.new(.3, .3, .3),
						Size = UDim2.new(.9, 0, .8, 0),
						Position = UDim2.new(.05, 0, .1, 0),
						ZIndex = 5, Parent = rf.gui,
						Visible = false,
					}
				end
			end
			selectionBack = _p.RoundedFrame:new {
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.02,
				BackgroundColor3 = BrickColor.new('Cyan').Color,
				Size = UDim2.new(1.2, 0, 1.0, 0),
				Position = UDim2.new(-0.1, 0, 0.0, 0),
				ZIndex = 4, Parent = frame
			}
			table.insert(menuRFs, selectionBack)
		end
		selectionOptions.Position = UDim2.new(0.0, math.max(0, math.min(gui.AbsoluteSize.X-selectionOptions.AbsoluteSize.X, frame.AbsolutePosition.X+frame.AbsoluteSize.X*.95)), 0.0, math.max(0, math.min(gui.AbsoluteSize.Y-selectionOptions.AbsoluteSize.Y, frame.AbsolutePosition.Y-gui.AbsoluteSize.Y*.02)))
		disableRelease.Visible = frame.Parent==partyLabel
	end
	deselect = function()
		pcall(function() selectionOptions.Parent  = nil end)
		pcall(function() selectionBack.Parent     = nil end)
		pcall(function() boxOptions.Parent        = nil end)
		pcall(function() boxOptionsBack.Parent    = nil end)
	end
	local function selectBoxOptions(configButton)
		if not enabled then return end
		deselect()
		local gui = Utilities.frontGui
		if boxOptions then
			boxOptions.Parent = gui
			boxOptionsBack.Parent = configButton
		else
			boxOptions = _p.RoundedFrame:new {
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.02,
				BackgroundColor3 = BrickColor.new('Cyan').Color,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(0.35, 0, 0.3, 0),
				AnchorPoint = Vector2.new(1,0),
				Parent = gui
			}
			table.insert(menuRFs, boxOptions)
			local options = {'Rename', 'Wallpaper', 'Release All'}
			for optionNum, optionName in pairs(options) do
				local gap = .025
				local rf = _p.RoundedFrame:new {
					Button = true,
					CornerRadius = Utilities.gui.AbsoluteSize.Y*.02,
					BackgroundColor3 = Color3.new(.3, .3, .3),
					Size = UDim2.new(0.95, 0, 1/(1+gap)/#options-gap, 0),
					Position = UDim2.new(0.025, 0, (optionNum-1)/(1+gap)/#options+gap, 0),
					ZIndex = 2, Parent = boxOptions.gui,
					MouseButton1Click = function() -- an option was clicked
						if not enabled then return end
						deselect()
						local pc = pc_ui.pcData
						enabled = false
						if optionNum == 1 then--RENAME
							pcall(function() pcContainer.BoxDiv.BoxName:remove() end)
							local entryBox = create 'TextBox' {
								BackgroundTransparency = 1.0,
								TextColor3 = Color3.new(1, 1, 1),
								TextScaled = true, Text = '',
								TextXAlignment = Enum.TextXAlignment.Left,
								Font = Enum.Font.SourceSansBold,
								Size = UDim2.new(1.4, 0, .1, 0),
								Position = UDim2.new(.1, 0, -.1, 0),
								ZIndex = 4, Parent = pcContainer.BoxDiv
							}
							entryBox.Changed:connect(function(p)if p~='Text'then return end entryBox.Text=entryBox.Text:sub(1,12)end)
							entryBox:CaptureFocus()
							entryBox.FocusLost:wait()
							local name = Utilities.trim(entryBox.Text:gsub('[^%w ,%.!@#%$%%*^&%*%(%)%+%-%?:;]+',''))
							local boxNum = pc.ch.cb or pc.cb or 1
							if not name or name == '' then
								name = pc.bNames[tostring(boxNum)] or ('Box '..boxNum)
							end
							name = _p.Network:get('PDS', 'cPC', 'nameBox', boxNum, name) or ('Box '..boxNum)
							entryBox:remove()
							pc.bNames[tostring(boxNum)] = name
							write(name) { -- top line (rn)
								Frame = create 'Frame' {
									Name = 'BoxName',
									BackgroundTransparency = 1.0,
									Size = UDim2.new(.0, 0, .1, 0),
									Position = UDim2.new(.1, 0, -.1, 0),
									ZIndex = 3, Parent = pcContainer.BoxDiv
								}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left
							}
							pcall(function() pcContainer.OtherBoxes.Container['Box'..boxNum..'Text']:remove() end)
							write(name) { -- above in list (rn)
								Frame = create 'Frame' {
									Name = 'Box'..boxNum..'Text',
									BackgroundTransparency = 1.0,
									Size = UDim2.new(1.0, 0, 1/6*3/4*.9, 0),
									Position = UDim2.new(0.0, 0, boxNum-1+1/6/4+.1/6*3/4, 0),
									ZIndex = 3, Parent = pcContainer.OtherBoxes.Container
								}, Scaled = true
							}
						elseif optionNum == 2 then--WALLPAPER
							local sig = Utilities.Signal()
							local mouseCancel = create 'ImageButton' {
								BackgroundTransparency = 1.0,
								Image = '',
								Size = UDim2.new(1.0, 0, 1.0, 0),
								Parent = Utilities.frontGui,
								MouseButton1Click = sig.fire
							}
							local bg = create 'Frame' {
								BorderSizePixel = 0,
								BackgroundColor3 = BrickColor.new('Cyan').Color,
								SizeConstraint = Enum.SizeConstraint.RelativeYY,
								Size = UDim2.new(.9/4*6/5*6, 0, .9, 0),
								AnchorPoint = Vector2.new(.5, .5),
								Position = UDim2.new(.5, 0, .5, 0),
								Parent = Utilities.frontGui
							}
							for i, id in pairs(pc_bgs) do
								local x = (i-1)%6
								local y = math.floor((i-1)/6)
								local b = create 'ImageButton' {
									BackgroundTransparency = 1.0,
									Image = 'rbxassetid://'..id,
									Size = UDim2.new(1/6, 0, 1/4, 0),
									Position = UDim2.new(x/6, 0, y/4, 0),
									ZIndex = 2, Parent = bg,
									MouseButton1Click = function()
										sig:fire(i)
									end
								}
							end
							local wNum = sig:wait()
							mouseCancel:remove()
							bg:remove()
							if wNum then
								local boxNum = pc.ch.cb or pc.cb or 1
								pc.bBacks[tostring(boxNum)] = wNum
								spawn(function() _p.Network:get('PDS', 'cPC', 'setWPaper', boxNum, wNum) end)
								pcall(function() pcContainer.BoxDiv['Box'..boxNum].Image = 'rbxassetid://'..pc_bgs[wNum] end)
								pcall(function() pcContainer.OtherBoxes.Container['Box'..boxNum].Image = 'rbxassetid://'..pc_bgs[wNum] end)
							end
						elseif optionNum == 3 then--RELEASE ALL
							local chat = _p.NPCChat

							local container
							local boxNum = pc.ch.cb or pc.cb or 1
							pcall(function() container = pcContainer.BoxDiv['Box'..boxNum].Container end)

							if container then
								local frames = {}
								local nPokemon = 0
								for i = 1, 30 do
									pcall(function()
										local frame = container[tostring(i)]
										if #frame:GetChildren() > 0 then
											nPokemon = nPokemon + 1
											table.insert(frames, frame)
										end
									end)
								end
								if nPokemon == 0 then
									chat:say('The box is already empty.')
								else
									if chat:say('[y/n]Release all pokemon in this box?') then
										if chat:say('WARNING! This cannot be undone. You are about to release '..nPokemon..' pokemon.',
											'[y/n]Are you sure you want to release these pokemon?') then
											local dur = 1
											for _, frame in pairs(frames) do
												local p, _, box, position = getPokemon(frame)
												local ch = frame:GetChildren()[1]
												if ch then
													ch:TweenSizeAndPosition(UDim2.new(.0,0,.0,0), UDim2.new(.5,0,.5,0), nil, nil, dur, true, function() ch:remove() end)
												end
												local r = pc.rcount + 1
												pc.rcount = r
												pc.ch.m[tostring(p[1])] = {-1, r}
												pcall(function()
													local box = frame.Parent.Parent.Name:sub(4)
													local pos = frame.Name
													pc.boxes[box][pos] = nil
												end)
												frame.Active = false
												delay(dur, function() pcall(function() pcContainer.OtherBoxes.Container['Box'..box].Container[tostring(position)]:ClearAllChildren() end) end)
											end
											wait(dur)
										end
									end
								end
							else
								print(boxNum)
								chat:say('An error occured.')
							end
						end
						enabled = true
					end
				}
				table.insert(menuRFs, rf)
				write(optionName) {
					Frame = create 'Frame' {
						Name = 'ButtonText',
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 0.5, 0),
						Position = UDim2.new(0.0, 0, 0.25, 0),
						ZIndex = 4, Parent = rf.gui
					}, Scaled = true
				}
			end
			boxOptionsBack = _p.RoundedFrame:new {
				CornerRadius = Utilities.gui.AbsoluteSize.Y*.02,
				BackgroundColor3 = BrickColor.new('Cyan').Color,
				Size = UDim2.new(1.2, 0, 1.0, 0),
				Position = UDim2.new(-0.1, 0, 0.0, 0),
				ZIndex = 4, Parent = configButton
			}
			table.insert(menuRFs, boxOptionsBack)
		end
		-- todo
		boxOptions.Position = UDim2.new(.0, boxOptionsBack.gui.AbsolutePosition.X+boxOptions.gui.AbsoluteSize.X*.055, .0, boxOptionsBack.gui.AbsolutePosition.Y-gui.AbsoluteSize.Y*.02)
	end

	local function swap(aParent, bParent)
		local pc = pc_ui.pcData
		mouseAbsorb.Parent = Utilities.frontGui
		canClosePC = false
		aParent.Active = false
		bParent.Active = false
		local a = aParent:GetChildren()[1]
		local b = bParent:GetChildren()[1]
		local miniAParent, miniBParent
		if aParent.Parent == activeBox.Container then
			miniAParent = pcContainer.OtherBoxes.Container[activeBox.Name].Container[aParent.Name]
			miniAParent:ClearAllChildren()
		end
		if bParent.Parent == activeBox.Container then
			miniBParent = pcContainer.OtherBoxes.Container[activeBox.Name].Container[bParent.Name]
			miniBParent:ClearAllChildren()
		end
		local pA, sA, osA, nsA, pB, sB, osB, nsB
		if a then
			pA = a.AbsolutePosition - bParent.AbsolutePosition
			sA = a.Size
			osA = a.AbsoluteSize
			a.Parent = bParent
			nsA = a.AbsoluteSize
			if miniBParent then a:Clone().Parent = miniBParent end
		end
		pcall(function() aParent.Position = dragContainerPositions[aParent] end)
		if b then
			pB = b.AbsolutePosition - aParent.AbsolutePosition
			sB = b.Size
			osB = b.AbsoluteSize
			b.Parent = aParent
			nsB = b.AbsoluteSize
			if miniAParent then b:Clone().Parent = miniAParent end
		end
		-- condition: dragging out of party and leaving a gap
		if not b and aParent.Parent == partyLabel and bParent.Parent ~= partyLabel then
			local s = tonumber(aParent.Name:sub(-1))
			local e = #pc.party-1--_p.PlayerData.party-1
			spawn(function()
				for i = s, e do
					wait()
					spawn(function()
						swap(partyLabel['Container'..i],
							partyLabel['Container'..(i+1)])
					end)
				end
			end)
		end
		do --// data shift //--
			local function get(from)
				if from.Parent == partyLabel then
					local i = tonumber(from.Name:sub(-1))
					local p = pc.party[i]
					pc.party[i] = nil
					return p
				else
					local box = from.Parent.Parent.Name:sub(4)
					local pos = from.Name
					local p = pc.boxes[box][pos]
					pc.boxes[box][pos] = nil
					return p
				end
			end
			local function set(p, to)
				if to.Parent == partyLabel then
					local i = tonumber(to.Name:sub(-1))
					pc.party[i] = p
					pc.ch.m[tostring(p[1])] = {0,i}
				else
					local box = to.Parent.Parent.Name:sub(4)
					local pos = to.Name
					pc.boxes[box][pos] = p
					pc.ch.m[tostring(p[1])] = {box,pos}
					if p[5] then
						pc.ch.h[tostring(p[1])] = true
						p[4] = p[2] < 1450 -- egg threshold
					end
				end
			end
			local ap, bp
			if a then ap = get(aParent) end
			if b then bp = get(bParent) end
			if ap then pcall(set, ap, bParent) end
			if bp then pcall(set, bp, aParent) end
			canClosePC = true
			mouseAbsorb.Parent = nil
		end
		Utilities.Tween(.25, 'easeOutCubic', function(alpha)
			local o = 1-alpha
			if a then
				a.Position = UDim2.new(0.0, pA.X*o, 0.0, pA.Y*o)
				a.Size = UDim2.new(0.0, osA.X+(nsA.X-osA.X)*alpha, 0.0, osA.Y+(nsA.Y-osA.Y)*alpha)
			end
			if b then
				b.Position = UDim2.new(0.0, pB.X*o, 0.0, pB.Y*o)
				b.Size = UDim2.new(0.0, osB.X+(nsB.X-osB.X)*alpha, 0.0, osB.Y+(nsB.Y-osB.Y)*alpha)
			end
		end)
		if a then a.Size = sA end
		if b then b.Size = sB end
		pcall(function() if b then aParent.Active = (aParent.Parent==activeBox.Container or aParent.Parent==partyLabel) and #aParent:GetChildren()>0 end end)
		pcall(function() if a then bParent.Active = (bParent.Parent==activeBox.Container or bParent.Parent==partyLabel) and #bParent:GetChildren()>0 end end)
	end

	local function setLayer(icon, z)
		while true do
			local ch = icon:GetChildren()
			if #ch == 0 then break end
			icon = ch[1]
		end
		icon.ZIndex = z
	end

	-- OVH  TODO: prevent double-drags when someone clicks on a pixel overlap, etc.
	local function onDragBegin(frame)
		deselect()
		--	if not enabled then -- try to cancel the drag
		--		local p = frame.Parent
		--		frame.Parent = nil
		--		pcall(function() frame.Position = dragContainerPositions[frame] end)
		--		frame.Parent = p
		--	end
		setLayer(frame, 6)
	end

	local function onDragStopped(frame)
		local pc = pc_ui.pcData

		setLayer(frame, 5)
		if math.abs(frame.Position.X.Offset) < 3 and math.abs(frame.Position.Y.Offset) < 3 then -- if not dragged far (i.e. clicked)
			frame.Position = UDim2.new(frame.Position.X.Scale, 0, frame.Position.Y.Scale, 0)
			selectFrame(frame)
			return
		end
		local center = frame.AbsolutePosition+frame.AbsoluteSize/2
		local function within(f)
			local tl = f.AbsolutePosition
			local br = tl+f.AbsoluteSize
			return center.X > tl.X and center.X < br.X and center.Y > tl.Y and center.Y < br.Y
		end
		-- verification: make sure we don't have fainted/egg team
		local canMovePokemon = true
		local onlyHealthyPokemon
		if frame.Parent == partyLabel then
			canMovePokemon = false
			for i, p in pairs(pc.party) do
				if p[4] then--p.hp > 0 and not p.egg
					if onlyHealthyPokemon then
						onlyHealthyPokemon = nil
						canMovePokemon = true
						break
					else
						onlyHealthyPokemon = i
					end
				end
			end
			if not canMovePokemon and onlyHealthyPokemon then
				if frame.Name ~= 'Container'..onlyHealthyPokemon then
					canMovePokemon = true
				end
			end
		end
		--
		if canMovePokemon and enabled then
			-- drop in active box
			if within(activeBox.Container) then
				for _, otherFrame in pairs(activeBox.Container:GetChildren()) do
					if otherFrame ~= frame and within(otherFrame) then
						swap(frame, otherFrame)
						return
					end
				end
			end
			-- drop into party
			for i = 1, 6 do
				local otherFrame = partyLabel['Container'..i]
				if otherFrame ~= frame and within(otherFrame) then
					local n = math.min(i, #pc.party+(frame.Parent == partyLabel and 0 or 1))
					if n ~= i then
						otherFrame = partyLabel['Container'..n]
					end
					if otherFrame ~= frame then
						if frame.Parent ~= partyLabel then -- prevent all-egg parties
							local otherpd = pc.party[i]
							if otherpd and otherpd[4] then
								local hasHealthyOtherThanWhereDropping = false
								for _, pd in pairs(pc.party) do
									if pd ~= otherpd and pd[4] then
										hasHealthyOtherThanWhereDropping = true
										break
									end
								end
								if not hasHealthyOtherThanWhereDropping then break end
							end
						end
						swap(frame, otherFrame)
						return
					end
				end
			end
			-- drop into another box
			for _, miniBox in pairs(pcContainer.OtherBoxes.Container:GetChildren()) do
				if miniBox.Name:sub(-4) ~= 'Text' and miniBox.Name ~= activeBox.Name and within(miniBox.Container) then
					local x = (center.X - miniBox.Container.AbsolutePosition.X) / miniBox.Container.AbsoluteSize.X
					local y = (center.Y - miniBox.Container.AbsolutePosition.Y) / miniBox.Container.AbsoluteSize.Y
					if x > 0 and x < 1 and y > 0 and y < 1 then
						local p = math.floor(x*6) + math.floor(y*6)*6 + 1
						if p > 0 and p <= 30 then
							swap(frame, miniBox.Container[tostring(p)])
							return -- right?
						end
					end
				end
			end
		end
		-- abort
		frame.Active = false
		local offset = frame.AbsolutePosition
		local p = dragContainerPositions[frame]
		frame.Position = p
		offset = offset - frame.AbsolutePosition
		Utilities.Tween(.25, 'easeOutCubic', function(a)
			local o = 1-a
			frame.Position = p + UDim2.new(0.0, offset.X*o, 0.0, offset.Y*o)
		end)
		frame.Active = true
	end

	local currentlySearching = false
	local dragging = false
	local function enableDragging(obj)
		dragContainerPositions[obj] = obj.Position
		local dragger = _p.Dragger:new(obj)
		local sp
		local active = false
		dragger.onDragBegin:connect(function(offset)
			sp = nil
			if not (not dragging and enabled) or not obj.Active then
				dragger:endDrag()
				return
			end
			dragging = true
			sp = obj.Position
			active = true
			onDragBegin(obj)
		end)
		dragger.onDragMove:connect(function(offset)
			if not active then
				return
			end
			obj.Position = sp + UDim2.new(0, offset.X, 0, offset.Y)
		end)
		dragger.onDragEnd:connect(function()
			if not active then
				return
			end
			active = false
			onDragStopped(obj)
			dragging = false
		end)
	end

	local function makeBox(box, n, isActive)--, name, wallpaper)
		local pc = pc_ui.pcData
		local boxLabel = create 'ImageButton' {
			--		Active = false,
			Name = 'Box'..n,
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://'..pc_bgs[pc.bBacks[tostring(n)] or ((n-1)%#pc_bgs+1)],
			ZIndex = 3,
			MouseButton1Down = deselect,

			create 'Frame' {
				Name = 'Container',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(530/600, 0, 430/500, 0),
				Position = UDim2.new(40/600, 0, 36/500, 0),
			}
		}
		for i = 1, 30 do
			local draggableContainer; draggableContainer = create 'Frame' {
				Name = tostring(i),
				Draggable = true, ZIndex = 4,
				BorderSizePixel = 0,
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1/6, -2, 1/5, -2),
				Position = UDim2.new(((i-1)%6)/6, 0, math.floor((i-1)/6)/5, 0),
				Parent = boxLabel.Container,
				DragBegin = function() onDragBegin(draggableContainer) end,
				DragStopped = function() onDragStopped(draggableContainer, n, i) end,
			}
			dragContainerPositions[draggableContainer] = draggableContainer.Position
			local pd = box[tostring(i)]
			if pd then
				draggableContainer.Active = isActive and true or false
				local icon = _p.Pokemon:getIcon(pd[2], pd[3])
				pc_ui.labelIndexPairs[icon] = pd[1]
				icon.Parent = create 'Frame' {
					BackgroundTransparency = 1.0,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.new(4/3, 0, 1.0, 0),
					Parent = draggableContainer,
				}
				icon.Position = UDim2.new(-(4/3-1)/2*3/4, 0, 0.0, 0)
				if isActive and pc_ui.currentSearchResults and not pc_ui.currentSearchResults[pd[1]] then
					pcall(function()
						icon.ImageTransparency = 0.7
					end)
					pcall(function()
						icon.ImageLabel.ImageTransparency = 0.7
					end)
				end
			end
		end
		if isActive then-- table.insert(boxLabels, boxLabel) end
			pcall(function() pc_ui.pcData.ch.cb = n end)
			activeBox = boxLabel
			write(pc.bNames[tostring(n)] or ('Box '..n)) { -- top line
				Frame = create 'Frame' {
					Name = 'BoxName',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(.0, 0, .1, 0),
					Position = UDim2.new(.1, 0, -.1, 0),
					ZIndex = 3, Parent = pcContainer.BoxDiv
				}, Scaled = true, TextXAlignment = Enum.TextXAlignment.Left
			}

			local searchButton, configButton

				searchButton = create("ImageButton")({
				BackgroundTransparency = 1.0, 
				Image = "rbxassetid://395920720", 
				SizeConstraint = Enum.SizeConstraint.RelativeYY, 
				Size = UDim2.new(0.06, 0, 0.06, 0), 
				AnchorPoint = Vector2.new(1, 0.5), 
				Position = UDim2.new(0, 0, -.05, 0), 
				Rotation = 90, 
				ZIndex = 10, Parent = pcContainer.BoxDiv,
				
				
			
				
				MouseButton1Click = function()
					if currentlySearching then
						return
					end
					local SearchSystem = _p.DataManager:getModule("SearchSystem");
					if SearchSystem and SearchSystem.isOpen then
						return
					end
					currentlySearching = true
					searchInitializingFrame.Visible = true
					searchSystemMouseBlocker.Parent = Utilities.simulatedCoreGui
					if not SearchSystem then
						SearchSystem = _p.DataManager:loadModule("SearchSystem")
					end
					local results = SearchSystem:open(searchSystemMouseBlocker, function()
						searchInitializingFrame.Visible = false
						currentlySearching = false
					end)
					if results then
						pc_ui:showSearchResults(results)
						return
					end
					pc_ui:clearSearchResults()
				end,
			})

			configButton = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5640373647',
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(.08, 0, .08, 0),
				AnchorPoint = Vector2.new(1, .5),
				Position = UDim2.new(.08, 0, -.05, 0),
				ZIndex = 10, Parent = pcContainer.BoxDiv,
				MouseButton1Click = function()
					selectBoxOptions(configButton)
				end
			}
		else
			boxLabel.MouseButton1Click:connect(function()
				if not enabled then return end
				pcContainer.BoxDiv:ClearAllChildren()
				local nb = makeBox(box, n, true)
				nb.Size = UDim2.new(1.0, 0, 1.0, 0)
				nb.Parent = pcContainer.BoxDiv
			end)
		end
		return boxLabel
	end

	local porygonDebounce = false
	local function porygonButtonActivated()
		if porygonDebounce then return end
		porygonDebounce = true
		wait(1.5)
		delay(.1, function()
			_p.MasterControl.WalkEnabled = false
			_p.MasterControl:Stop()
			_p.Menu:disable()
		end)
		--	_p.PlayerData.completedEvents.PCPorygonEncountered = true
		_p.Battle:doWildBattle(_p.DataManager.currentChunk.regionData.PCEncounter, {battleSceneType = 'Porygon'})
		porygonDebounce = false
	end

	local pcOn = false
	local done
	local forceClosed
	function pc_ui:bootUp(pcModel)
		if pcOn or _p.Trade.sessionId or not _p.Menu.enabled then return end
		pcOn = true
		local canChat = false
		spawn(function() pcall(function() canChat = game:GetService('Chat'):CanUserChatAsync(_p.userId) end) end)
		pcall(function() pcModel.Screen.Material = Enum.Material.Neon end)
		pcall(function() _p.player.PlayerGui:SetTopbarTransparency(0) end)
		--pcall(function() _p.player.PlayerGui.TopBar.TopBarContainer.BackgroundTransparency = 0 end)

		spawn(function() _p.Menu:disable() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		done = Utilities.Signal()
		--	deserializedPokemonCache = {}
		--	boxLabels = {}
		dragContainerPositions = {}

		Utilities.sound(301976260, nil, nil, 5)
		
		self.labelIndexPairs = {}

		--// request data //--
		local pc
		Utilities.fastSpawn(function()
			pc = _p.Network:get('PDS', 'openPC')
		end)
		--// startup animation //--
		local bg = create 'ImageButton' {--'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = BrickColor.new('Cyan').Color,
			Parent = Utilities.gui,

			AutoButtonColor = false,
			MouseButton1Down = deselect,
		}
		Utilities.Tween(.75, 'easeInCubic', function(a)
			bg.Size = UDim2.new(a, 0, 0.0, 2)
			bg.Position = UDim2.new(0.5-a/2, 0, 0.5, -1)
		end)
		Utilities.Tween(.75, 'easeOutCubic', function(a)
			bg.Size = UDim2.new(1.0, 0, a, 2)
			bg.Position = UDim2.new(0.0, 0, 0.5-a/2, -1)
		end)
		local animBG = true
		--// wait until session is started //--
		while not pc do wait() end
		pc_ui.mb = pc.maxBoxes
		pc.ch = {m={},h={}} -- changes; will be sent to server on close
		pc.rcount = 0
		for _, p in pairs(pc.party) do
			p[5] = true
		end
		self.pcData = pc
		--// create scrolling background, if not mobile //--
		if not Utilities.isTouchDevice() then
			spawn(function()
				local stepped = game:GetService('RunService').RenderStepped
				local pen = 0.0
				local rows = {}
				local function createRow()
					local row = {}
					local container = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(1.0, 0, 0.08, 0),
						Position = UDim2.new(0.0, 0, pen + 0.01, 0),
						Parent = bg,
					}
					local r = math.random(29)-1
					local function makeStrip()
						local strip = create 'ImageLabel' {
							BackgroundTransparency = 1.0,
							Image = 'rbxassetid://8938689312',--5217733563',
							ImageColor3 = BrickColor.new('Bright blue').Color,
							ImageRectSize = Vector2.new(1000, 30),
							ImageRectOffset = Vector2.new(0, 30*r),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Size = UDim2.new(1000/30, 0, 1.0, 0),
							ZIndex = 2, Parent = container,
						}
						if r == 5 and _p.DataManager.currentChunk.id == 'chunk3' and not _p.PlayerData.completedEvents.PCPorygonEncountered then -- porygon button
							create 'ImageLabel' {
								BackgroundTransparency = 1.0,
								Image = 'rbxassetid://8938689312',--5217733563',
								ImageColor3 = BrickColor.new('Pink').Color,
								ImageRectSize = Vector2.new(40, 30),
								ImageRectOffset = Vector2.new(40*11, 30*r),
								Size = UDim2.new(1/25, 0, 1.0, 0),
								Position = UDim2.new(11/25, 0, 0.0, 0),
								ZIndex = 2, Parent = strip,

								create 'ImageButton' {
									BackgroundTransparency = 1.0,
									Size = UDim2.new(0.55, 0, 0.71, 0),
									Position = UDim2.new(0.25, 0, 0.25, 0),
									ZIndex = 2,
									MouseButton1Click = function()
										done:fire()
										porygonButtonActivated()
									end,
								}
							}
						end
						return strip
					end
					local lastStrip = makeStrip()
					lastStrip.Position = UDim2.new(0.0, -container.AbsoluteSize.Y/30*40*(math.random(25)-1+(pen*5)), 0.0, 0)
					function row:update(penShift, xShift)
						container.Position = container.Position + UDim2.new(0.0, 0, -penShift, 0)
						if container.AbsolutePosition.Y + container.AbsoluteSize.Y < 0 then
							self:remove()
							return
						end
						for _, strip in pairs(container:GetChildren()) do
							strip.Position = strip.Position + UDim2.new(0.0, -xShift, 0.0, 0)
							if strip.AbsolutePosition.X + strip.AbsoluteSize.X < 0 then
								strip:remove()
							end
						end
						while true do
							local endPt = lastStrip.AbsolutePosition.X + lastStrip.AbsoluteSize.X*(r==28 and 22/25 or 1.0)
							if endPt >= Utilities.gui.AbsoluteSize.X then break end
							r = (r + 1) % 29
							lastStrip = makeStrip()
							lastStrip.Position = UDim2.new(0.0, endPt, 0.0, 0)
						end
					end
					function row:remove()
						rows[self] = nil
						container:remove()
					end
					rows[row] = true
				end
				bg.Changed:connect(function(prop)
					if prop ~= 'AbsoluteSize' then return end
					for row in pairs(rows) do
						row:remove()
					end
					pen = 0.0
				end)
				while animBG do
					local lastTick = tick()
					stepped:wait()
					local et = tick()-lastTick
					local penShift = 0.1*et
					pen = pen - penShift
					local xShift = Utilities.gui.AbsoluteSize.Y * penShift
					while pen < 1.0 do
						createRow()
						pen = pen + 0.1
					end
					for row in pairs(rows) do
						row:update(penShift, xShift)
					end
				end
				for row in pairs(rows) do
					row:remove()
				end
			end)
		end
		--// close button //--
		local close = _p.RoundedFrame:new {
			Button = true,
			BackgroundColor3 = BrickColor.new('Deep blue').Color,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(1/5, 0, 1/16, 0),
			Position = UDim2.new(0.625, 0, 1/32, 0),
			ZIndex = 3, Parent = bg,
			MouseButton1Click = function()
				if not canClosePC or not enabled then return end
				done:fire()
			end
		}
		write 'Close' {
			Frame = create 'Frame' {
				Name = 'ButtonText',
				BackgroundTransparency = 1.0,
				Size = UDim2.new(1.0, 0, 0.7, 0),
				Position = UDim2.new(0.0, 0, 0.15, 0),
				ZIndex = 4, Parent = close.gui,
			}, Scaled = true
		}
		--// party //--
		do
			local positions = {
				UDim2.new( 22/350, 0,  34/500, 0),
				UDim2.new(181/350, 0,  93/500, 0),
				UDim2.new( 22/350, 0, 163/500, 0),
				UDim2.new(181/350, 0, 223/500, 0),
				UDim2.new( 22/350, 0, 294/500, 0),
				UDim2.new(181/350, 0, 354/500, 0),
			}
			local party = create 'ImageButton' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5295755248',
				Size = UDim2.new(1.0, 0, 1.0, 0),
				ZIndex = 3, Parent = pcContainer.PartyDiv.Container,
				MouseButton1Down = deselect,
			}
			for i = 1, 6 do
				local draggableContainer; draggableContainer = create 'Frame' {
					Name = 'Container'..i,
					Draggable = true, ZIndex = 4,
					BackgroundTransparency = 1.0,
					Size = UDim2.new(111/350, 0, 111/500, 0),
					Position = positions[i] + UDim2.new(19/350, 0, 0.0, 0),
					Parent = party,
					DragBegin = function() onDragBegin(draggableContainer) end,
					DragStopped = function() onDragStopped(draggableContainer) end,
				}
				dragContainerPositions[draggableContainer] = draggableContainer.Position
				local pd = pc.party[i]
				if pd then
					draggableContainer.Active = true
					local icon = _p.Pokemon:getIcon(pd[2], pd[3])
					self.labelIndexPairs[icon] = pd[1]
					icon.Parent = create 'Frame' {
						BackgroundTransparency = 1.0,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Size = UDim2.new(4/3, 0, 1.0, 0),
						Parent = draggableContainer,
					}
					icon.Position = UDim2.new(-(4/3-1)/2*3/4, 0, 0.0, 0)
				end
			end
			partyLabel = party
		end
		--// current box //--
		local currentBox = pc.cBox or 1
		local b = makeBox(pc.boxes[tostring(currentBox)] or {}, currentBox, true)
		b.Size = UDim2.new(1.0, 0, 1.0, 0)
		b.Parent = pcContainer.BoxDiv
		onScreenResized('AbsoluteSize')
		--// box list //--
		if pc.maxBoxes >= 50 then pcall(onMoreBoxesPurchased) end
		for i = 1, pc.maxBoxes do
			local i_string = tostring(i)
			local box = pc.boxes[i_string]
			if not box then
				box = {}
				pc.boxes[i_string] = box
			end
			local b = makeBox(box, i, false)--, pc.bNames[i_string], pc.bBacks[i_string])
			b.Size = UDim2.new(1.0, 0, 5/6, 0)
			b.Position = UDim2.new(0.0, 0, i-1+1/6, 0)
			b.Parent = pcContainer.OtherBoxes.Container
			write(pc.bNames[i_string] or ('Box '..i)) { -- above in list
				Frame = create 'Frame' {
					Name = 'Box'..i..'Text',
					BackgroundTransparency = 1.0,
					Size = UDim2.new(1.0, 0, 1/6*3/4*.9, 0),
					Position = UDim2.new(0.0, 0, i-1+1/6/4+.1/6*3/4, 0),
					ZIndex = 3, Parent = pcContainer.OtherBoxes.Container
				}, Scaled = true
			}
		end

		--// fade in //--
		local fade = create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = bg.BackgroundColor3,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 10, Parent = bg,
		}
		pcContainer.Visible = true
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			fade.BackgroundTransparency = a
		end)
		forceClosed = false
		done:wait()

		--// close pc //--
		_p.WalkEvents:clearHatchQueue()
		self.pcData = nil
		local done = false
		Utilities.fastSpawn(function()
			if not _p.Network:get('PDS', 'closePC', pc.id, pc.ch) then
				print 'ERROR: SESSION REJECTED'
			end
			done = true
		end)





		mouseAbsorb.Parent = Utilities.frontGui
		deselect()
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			fade.BackgroundTransparency = 1-a
		end)
		Utilities.sound(301976189, nil, nil, 5)
		pcContainer.Visible = false
		pcContainer.OtherBoxes.Container:ClearAllChildren()
		animBG = false
		while not done do wait() end
		Utilities.Tween(.5, 'easeInCubic', function(a)
			local o = 1-a
			bg.Size = UDim2.new(1.0, 0, o, 2)
			bg.Position = UDim2.new(0.0, 0, 0.5-o/2, -1)
		end)
		-- wait until close has processed before further animating (PAUSE here)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			local o = 1-a
			bg.Size = UDim2.new(o, 0, 0.0, 2)
			bg.Position = UDim2.new(0.5-o/2, 0, 0.5, -1)
		end)
		bg:remove()
		pcContainer.PartyDiv.Container:ClearAllChildren()
		pcContainer.BoxDiv:ClearAllChildren()
		pcContainer.OtherBoxes.Container:ClearAllChildren()
		--	for _, dp in pairs(deserializedPokemonCache) do
		--		if not dp:getPartyIndex() then
		--			dp:remove()
		--		end
		--	end
		--	deserializedPokemonCache = nil
		--	boxLabels = nil
		partyLabel = nil
		dragContainerPositions = nil
		pcall(function() pcModel.Screen.Material = Enum.Material.SmoothPlastic end)
		pcall(function() _p.player.PlayerGui:SetTopbarTransparency(0.5) end)
		--pcall(function() _p.player.PlayerGui.TopBar.TopBarContainer.BackgroundTransparency = 1 end)

		_p.WalkEvents.checkEggs = true
		if not forceClosed then
			_p.MasterControl.WalkEnabled = true
			--_p.MasterControl:Start()

			spawn(function() _p.Menu:enable() end)
		end
		pcOn = false
		mouseAbsorb.Parent = nil
		done = nil
	end

	function pc_ui:forceClose()
		if not pcOn then return end
		forceClosed = true
		if done then done:fire() end
	end

	function pc_ui:showSearchResults(results)
		local isResult = {}
		for _, index in pairs(results) do
			isResult[index] = true
		end
		self.currentSearchResults = isResult
		for label, index in pairs(self.labelIndexPairs) do
			do
				local t = isResult[index] and 0 or 0.7
				pcall(function()
					label.ImageTransparency = t
				end)
				pcall(function()
					label.ImageLabel.ImageTransparency = t
				end)
			end
		end
	end

	function pc_ui:clearSearchResults()
		self.currentSearchResults = nil
		for label in pairs(self.labelIndexPairs) do
			pcall(function()
				label.ImageTransparency = 0
			end)
			pcall(function()
				label.ImageLabel.ImageTransparency = 0
			end)
		end
	end

	_p.Network:bindEvent('PCPassPurchased', function()
		if not pcOn then
			pcall(onMoreBoxesPurchased)
			return
		end
		local blockGui = create 'ImageButton' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 10, Parent = Utilities.frontGui,
		}
		pc_ui:forceClose()
		repeat wait() until not pcOn
		pcall(onMoreBoxesPurchased)
		blockGui:remove()
		spawn(function() _p.Menu:enable() end) -- this must be done to get PC to open, it is subsequently disabled (and the blockGui covers it anyway)
		wait()
		pc_ui:bootUp()
	end)


	return pc_ui end
