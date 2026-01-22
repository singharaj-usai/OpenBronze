return function(_p)
	local Utilities = _p.Utilities
	local create = Utilities.Create

	_p.DataManager:preload(347174353, 347174282, 347416341, 347416268, 347416317, 347416293, 347416563)

	_p.DataManager:preload(8695783637);
	_p.DataManager:preload(8678676983, 8678676843, 8678677238, 8678677107, 8669458868, 8669458679, 8669459168, 8669458981, 8674779570, 8674780817);
	_p.DataManager:preload(8689948278, 8688642680, 8688782441, 8689472187, 8689472386, 8689486814, 8689486624, 8695612940, 8675216731, 8675683443);
	_p.DataManager:preload(8691805402, 8678663334, 8678663099, 8678663185);

	-- battle music 347258672

	-- runtime-install gen 1 font
	Utilities.loadFont(require(script.Gen1Font))

	local event = {
		FinishedSignal = Utilities.Signal(),
	}
	local battle

	local interaction = require(script.Interaction)

	local SHEET_ID = 'rbxassetid://347174353'
	local BLACK_COLOR = Color3.new(24/255, 24/255, 24/255)
	local BACKGROUND_COLOR = Color3.new(248/255, 248/255, 248/255)
	local HEALTH_GREEN = Color3.new(40/255, 246/255, 45/255)
	local HEALTH_ORANGE = Color3.new(246/255, 143/255, 37/255)
	local HEALTH_RED = Color3.new(245/255, 12/255, 26/255)

	local gui = create 'ScreenGui' {
		Parent = _p.player:WaitForChild('PlayerGui'),
		create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = BLACK_COLOR,
			Size = UDim2.new(1.0, 0, 1.0, 36),
			Position = UDim2.new(0.0, 0, 0.0, -36),
		}
	}
	local screen = create 'Frame' {
		ClipsDescendants = true,
		BorderSizePixel = 0,
		BackgroundColor3 = BACKGROUND_COLOR,
		Size = UDim2.new(1.0, 0, 1.0, 0),
		Position = UDim2.new(-0.5, 0, 0.0, 0),
		ZIndex = 2,

		Parent = create 'Frame' {
			BackgroundTransparency = 1.0,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(160/144*.9, 0, 0.9, 0),
			Position = UDim2.new(0.5, 0, 0.05, 0),
			Parent = gui,
		},
	}
	event.screen = screen

	local cell = Vector2.new(8/160, 8/144)

	local function write(text, parent, px, py, timedFill, rightJustify)
		local psx = math.floor(parent.AbsoluteSize.X/(screen.AbsoluteSize.X/20)+.5)
		local psy = math.floor(parent.AbsoluteSize.Y/(screen.AbsoluteSize.Y/18)+.5)
		local frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 1/psy, 0),
			Position = UDim2.new(px/psx, 0, py/psy, 0),
			ZIndex = parent.ZIndex+1, Parent = parent,
		}
		Utilities.Write(text) {
			Font = 'Gen1Font',
			Frame = frame,
			Scaled = true,
			AnimationRate = timedFill and 35 or nil,
			AnimationFadeDisabled = true,
			TextXAlignment = rightJustify and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
		}
		for i, v in pairs(frame:GetChildren()) do
			pcall(function()
				v.ResampleMode = Enum.ResamplerMode.Pixelated
			end)
		end
		return frame
	end

	do
		local arrow = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(cell.X, 0, cell.Y, 0),
			ZIndex = 10, Parent = screen,
		}
		write('[right]', arrow, 0, 0)
		interaction:init(Utilities, event, arrow, cell)
	end

	local chatBox
	local function say(autoAdvance, t1, t2, ...)
		local function advance()
			if autoAdvance then
				wait(.5)
			else
				-- create blinking arrow indicator
				_p.NPCChat.AdvanceSignal:wait()
			end
		end
		local f1 = write(t1, chatBox, 1, 2, true)
		local f2
		if t2 then
			f2 = write(t2, chatBox, 1, 4, true)
		end
		advance()
		local more = {...}
		while #more > 0 do
			local line = table.remove(more, 1)
			wait(.05)
			f1:remove()
			f2.Position = f2.Position + UDim2.new(0.0, 0, -1/6, 0)
			wait(.05)
			f2.Position = f2.Position + UDim2.new(0.0, 0, -1/6, 0)
			f1 = f2
			f2 = write(line, chatBox, 1, 4, true)
			advance()
		end
		f1:remove()
		pcall(function() f2:remove() end)
	end

	local function makeBorderedFrame(sx, sy, px, py, zindex)
		if sx < 3 or sy < 3 then
			error("bad frame size", 2)
		end
		zindex = zindex or 1
		local frame = create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BACKGROUND_COLOR, 
			Size = UDim2.new(sx * cell.X, 0, sy * cell.Y, 0), 
			Position = UDim2.new((px or 0) * cell.X, 0, (py or 0) * cell.Y, 0), 
			ZIndex = zindex
		})
		create("ImageLabel")({
			BackgroundTransparency = 1, 
			Image = "rbxassetid://8678676983", 
			ImageRectSize = Vector2.new(8, 8), 
			Size = UDim2.new(1 / sx, 0, 1 / sy, 0), 
			ZIndex = zindex, 
			Parent = frame, 
			ResampleMode = Enum.ResamplerMode.Pixelated
		})
		create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BLACK_COLOR, 
			Size = UDim2.new(1 - 2 / sx, 0, 1 / sy / 8, 0), 
			Position = UDim2.new(1 / sx, 0, 2 / sy / 8, 0), 
			ZIndex = zindex, 
			Parent = frame
		})
		create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BLACK_COLOR, 
			Size = UDim2.new(1 - 2 / sx, 0, 2 / sy / 8, 0), 
			Position = UDim2.new(1 / sx, 0, 4 / sy / 8, 0), 
			ZIndex = zindex, 
			Parent = frame
		})
		create("ImageLabel")({
			BackgroundTransparency = 1, 
			Image = "rbxassetid://8678676843", 
			ImageRectSize = Vector2.new(8, 8), 
			Size = UDim2.new(1 / sx, 0, 1 / sy, 0), 
			Position = UDim2.new(1 - 1 / sx, 0, 0, 0), 
			ZIndex = zindex, 
			Parent = frame, 
			ResampleMode = Enum.ResamplerMode.Pixelated
		})
		create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BLACK_COLOR, 
			Size = UDim2.new(1 / sx / 8, 0, 1 - 2 / sy, 0), 
			Position = UDim2.new(2 / sx / 8, 0, 1 / sy, 0), 
			ZIndex = zindex, 
			Parent = frame
		})
		create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BLACK_COLOR, 
			Size = UDim2.new(1 / sx / 8, 0, 1 - 2 / sy, 0), 
			Position = UDim2.new(4 / sx / 8, 0, 1 / sy, 0), 
			ZIndex = zindex, 
			Parent = frame
		})
		create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BLACK_COLOR, 
			Size = UDim2.new(1 / sx / 8, 0, 1 - 2 / sy, 0), 
			Position = UDim2.new(1 - 3 / sx / 8, 0, 1 / sy, 0), 
			ZIndex = zindex, 
			Parent = frame
		})
		create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BLACK_COLOR, 
			Size = UDim2.new(1 / sx / 8, 0, 1 - 2 / sy, 0), 
			Position = UDim2.new(1 - 5 / sx / 8, 0, 1 / sy, 0), 
			ZIndex = zindex, 
			Parent = frame
		})
		create("ImageLabel")({
			BackgroundTransparency = 1, 
			Image = "rbxassetid://8678677238", 
			ImageRectSize = Vector2.new(8, 8), 
			Size = UDim2.new(1 / sx, 0, 1 / sy, 0), 
			Position = UDim2.new(0, 0, 1 - 1 / sy, 0), 
			ZIndex = zindex, 
			Parent = frame, 
			ResampleMode = Enum.ResamplerMode.Pixelated
		})
		create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BLACK_COLOR, 
			Size = UDim2.new(1 - 2 / sx, 0, 1 / sy / 8, 0), 
			Position = UDim2.new(1 / sx, 0, 1 - 1 / sy + 2 / sy / 8, 0), 
			ZIndex = zindex, 
			Parent = frame
		})
		create("Frame")({
			BorderSizePixel = 0, 
			BackgroundColor3 = BLACK_COLOR, 
			Size = UDim2.new(1 - 2 / sx, 0, 2 / sy / 8, 0), 
			Position = UDim2.new(1 / sx, 0, 1 - 1 / sy + 4 / sy / 8, 0), 
			ZIndex = zindex, 
			Parent = frame
		})
		create("ImageLabel")({
			BackgroundTransparency = 1, 
			Image = "rbxassetid://8678677107", 
			ImageRectSize = Vector2.new(8, 8), 
			Size = UDim2.new(1 / sx, 0, 1 / sy, 0), 
			Position = UDim2.new(1 - 1 / sx, 0, 1 - 1 / sy, 0), 
			ZIndex = zindex, 
			Parent = frame, 
			ResampleMode = Enum.ResamplerMode.Pixelated
		})
		return frame
	end

	local function setZIndex(frame, zindex)
		local function set(f)
			pcall(function() f.ZIndex = zindex end)
			for _, ch in pairs(f:GetChildren()) do
				set(ch)
			end
		end
		set(frame)
	end


	-- Overworld
	local worldmap = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(352/160, 0, 352/144, 0),
		Parent = screen,
	}
	-- lavender town 22 x 22 16x16 tiles
	create 'ImageLabel' { -- top-left
		BackgroundTransparency = 1.0,
		Image = "rbxassetid://8669458868", 
		Size = UDim2.new(0.5, 0, 0.5, 0), 
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 4, Parent = worldmap,
	}
	create 'ImageLabel' { -- top-right
		BackgroundTransparency = 1.0,
		Image = "rbxassetid://8669458679", 
		ImageRectSize = Vector2.new(640, 768), 
		Size = UDim2.new(0.5, 0, 0.5, 0), 
		Position = UDim2.new(0.5, 0, 0, 0), 
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 4, Parent = worldmap,
	}
	create 'ImageLabel' { -- bottom-left
		BackgroundTransparency = 1.0,
		Image = "rbxassetid://8669459168", 
		Size = UDim2.new(0.5, 0, 0.5, 0), 
		Position = UDim2.new(0, 0, 0.5, 0), 
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 4, Parent = worldmap,
	}
	create 'ImageLabel' { -- bottom-right
		BackgroundTransparency = 1.0,
		Image = "rbxassetid://8669458981", 
		Size = UDim2.new(0.5, 0, 0.5, 0), 
		Position = UDim2.new(0.5, 0, 0.5, 0), 
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 4, Parent = worldmap,
	}
	--local cave = create 'ImageLabel' { -- no need, map sheet has it
	--	BackgroundTransparency = 1.0,
	--	Image = 'rbxassetid://347416268',
	--	ImageRectSize = Vector2.new(64, 64),
	--	ImageRectOffset = Vector2.new(704, 0),
	--	Size = UDim2.new(16/352, 0, 16/352, 0),
	--	Position = UDim2.new(256/352, 0, 144/352, 0),
	--	ZIndex = 5, Parent = worldmap,
	--}
	local trainerOW = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://8864045155', -- todo
		ImageRectSize = Vector2.new(16, 16),
		--ImageRectSize = Vector2.new(64, 64),
		--ImageRectOffset = Vector2.new(4, 4),
		Size = UDim2.new(2*cell.X, 0, 2*cell.Y, 0),
		Position = UDim2.new(8*cell.X, 0, 8*cell.Y-4/144, 0),
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 6, Parent = screen,
	}
	local pikachuOW = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://8674780817', -- todo
		ImageRectSize = Vector2.new(16, 16), 
		--ImageRectSize = Vector2.new(64, 64),
		--ImageRectOffset = Vector2.new(4, 4+68*2),
		Size = UDim2.new(2*cell.X, 0, 2*cell.Y, 0),
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 5, Parent = screen,
	}
	do
		local encounterPosition = Vector2.new(17, 11)
		local extraMapBuffers = {top={},left={},bottom={}}
		local scrollingBg = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(11/22, 0, 10/22, 0),
			Parent = worldmap,
			create 'ImageLabel' {--tl
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://8689948278',
				ImageRectSize = Vector2.new(64*6, 64*5),
				Size = UDim2.new(6/11, 1, 0.5, 1),
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ZIndex = 3,
			},
			create 'ImageLabel' {--tr
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://8689948278',
				ImageRectSize = Vector2.new(64*5, 64*5),
				Size = UDim2.new(5/11, 0, 0.5, 1),
				Position = UDim2.new(6/11, 0, 0.0, 0),
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ZIndex = 3,
			},
			create 'ImageLabel' {--bl
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://8689948278',
				ImageRectSize = Vector2.new(64*6, 64*5),
				Size = UDim2.new(6/11, 1, 0.5, 0),
				Position = UDim2.new(0.0, 0, 0.5, 0),
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ZIndex = 3,
			},
			create 'ImageLabel' {--br
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://8689948278',
				ImageRectSize = Vector2.new(64*5, 64*5),
				Size = UDim2.new(5/11, 0, 0.5, 0),
				Position = UDim2.new(6/11, 0, 0.5, 0),
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ZIndex = 3,
			},
		}
		local charPos = Vector2.new(6, 11)
		local pikachuOffset = Vector2.new(1, 0)
		pikachuOW.Position = UDim2.new((8+pikachuOffset.X*2)*cell.X, 0, (8+pikachuOffset.Y*2)*cell.Y-4/144, 0)
		local isRight = false
		worldmap.Position = UDim2.new(((-charPos.X+5)*2)*cell.X, 0, ((-charPos.Y+5)*2)*cell.Y, 0)
		local collision = require(script.TownCollision)
		--local trainerRectOffsets = {
		--	--[[up   ]] [-2] = {Vector2.new(4, 4+68), Vector2.new(4+68, 4+68), Vector2.new(4+68*2, 4+68)},
		--	--[[left ]] [-1] = {Vector2.new(4+68*3, 4), Vector2.new(4+68*4, 4), Vector2.new(4+68*4, 4)},
		--	--[[down ]] [ 2] = {Vector2.new(4, 4), Vector2.new(4+68, 4), Vector2.new(4+68*2, 4)},
		--	--[[right]] [ 1] = {Vector2.new(4+68*3, 4+68), Vector2.new(4+68*4, 4+68), Vector2.new(4+68*4, 4+68)},
		--}
		--local pikachuRectOffsets = {
		--	--[[up   ]] [-2] = {Vector2.new(4, 4+68*3), Vector2.new(4+68, 4+68*3), Vector2.new(4+68*2, 4+68*3)},
		--	--[[left ]] [-1] = {Vector2.new(4+68*3, 4+68*2), Vector2.new(4+68*4, 4+68*2), Vector2.new(4+68*4, 4+68*2)},
		--	--[[down ]] [ 2] = {Vector2.new(4, 4+68*2), Vector2.new(4+68, 4+68*2), Vector2.new(4+68*2, 4+68*2)},
		--	--[[right]] [ 1] = {Vector2.new(4+68*3, 4+68*3), Vector2.new(4+68*4, 4+68*3), Vector2.new(4+68*4, 4+68*3)},
		--}
		local trainerRectOffsets = {
		--[[up   ]] [-2] =  {Vector2.new(0, 16), Vector2.new(16, 16), Vector2.new(32, 16)},
		--[[left ]] [-1] = {Vector2.new(48, 0), Vector2.new(64, 0), Vector2.new(64, 0)},
		--[[down ]] [ 2] = {Vector2.new(0, 0), Vector2.new(16, 0), Vector2.new(32, 0)},
		--[[right]] [ 1] = {Vector2.new(48, 16), Vector2.new(64, 16), Vector2.new(64, 16)}
		}
		
		local pikachuRectOffsets = {
			--[[up   ]] [-2] =  {Vector2.new(0, 16), Vector2.new(16, 16), Vector2.new(32, 16)},
			--[[left ]] [-1] = {Vector2.new(48, 0), Vector2.new(64, 0), Vector2.new(64, 0)},
			--[[down ]] [ 2] = {Vector2.new(0, 0), Vector2.new(16, 0), Vector2.new(32, 0)},
			--[[right]] [ 1] = {Vector2.new(48, 16), Vector2.new(64, 16), Vector2.new(64, 16)}
		}
		
		local isMoving = false
		local collisionThread
		local colorOffset = Vector2.new()
		local inside = false
		local function tryMove(dir)
			isMoving = true
			local pos = charPos + dir
			isRight = not isRight
			local offsetSet = trainerRectOffsets[dir.X+2*dir.Y]
			if collision[math.min(22, math.max(1, pos.Y))][math.max(1, pos.X)] == 0 then
				do -- let's do some "unescapable town" logic
					-- top
					local requiredTopBuffers = math.max(0, 5-pos.Y)
					if requiredTopBuffers < #extraMapBuffers.top then
						for i = requiredTopBuffers+2, #extraMapBuffers.top do
							extraMapBuffers.top[i]:remove()
							extraMapBuffers.top[i] = nil
						end
					elseif requiredTopBuffers > #extraMapBuffers.top then
						for i = #extraMapBuffers.top+1, requiredTopBuffers do
							local b = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(1.0, 0, 1/22, 0),
								Position = UDim2.new(0.0, 0, -i/22, 0),
								Parent = worldmap,
								create 'ImageLabel' {
									BackgroundTransparency = 1.0,
									Image = 'rbxassetid://8688642680',
									ImageRectSize = Vector2.new(768, 64*1.5),
									Size = UDim2.new(192/352, 0, 1.0*1.5, 0),
									ResampleMode = Enum.ResamplerMode.Pixelated,
									ZIndex = 3,
								},
								create 'ImageLabel' {
									BackgroundTransparency = 1.0,
									Image = 'rbxassetid://8688782441',
									ImageRectSize = Vector2.new(640, 64*1.5),
									Size = UDim2.new(160/352, 0, 1.0*1.5, 0),
									Position = UDim2.new(192/352, 0, 0.0, 0),
									ResampleMode = Enum.ResamplerMode.Pixelated,
									ZIndex = 3,
								},
							}
							extraMapBuffers.top[i] = b
						end
					end
					-- left
					local requiredLeftBuffers = math.max(0, 5-pos.X)
					if requiredLeftBuffers < #extraMapBuffers.left then
						for i = requiredLeftBuffers+2, #extraMapBuffers.left do
							extraMapBuffers.left[i]:remove()
							extraMapBuffers.left[i] = nil
						end
					elseif requiredLeftBuffers > #extraMapBuffers.left then
						for i = #extraMapBuffers.left+1, requiredLeftBuffers do
							local b = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(1/22, 1, 1.0, 0),
								Position = UDim2.new(-i/22, 0, 0.0, 0),
								Parent = worldmap,
								create 'ImageLabel' {
									BackgroundTransparency = 1.0,
									Image = 'rbxassetid://8689472187',
									ImageRectSize = Vector2.new(64, 768),
									Size = UDim2.new(1.0, 0, 192/352, 0),
									ResampleMode = Enum.ResamplerMode.Pixelated,
									ZIndex = 3,
								},
								create 'ImageLabel' {
									BackgroundTransparency = 1.0,
									Image = 'rbxassetid://8689472386',
									ImageRectSize = Vector2.new(64, 640),
									Size = UDim2.new(1.0, 0, 160/352, 0),
									Position = UDim2.new(0.0, 0, 192/352, 0),
									ResampleMode = Enum.ResamplerMode.Pixelated,
									ZIndex = 3,
								}
							}
							extraMapBuffers.left[i] = b
						end
					end
					-- bottom
					local requiredBottomBuffers = math.max(0, pos.Y-18)
					if requiredBottomBuffers < #extraMapBuffers.bottom then
						for i = requiredBottomBuffers+2, #extraMapBuffers.bottom do
							extraMapBuffers.bottom[i]:remove()
							extraMapBuffers.bottom[i] = nil
						end
					elseif requiredBottomBuffers > #extraMapBuffers.bottom then
						for i = #extraMapBuffers.bottom+1, requiredBottomBuffers do
							local b = create 'Frame' {
								BackgroundTransparency = 1.0,
								Size = UDim2.new(1.0, 0, 1/22, 1),
								Position = UDim2.new(0.0, 0, 1+(i-1)/22, -1),
								Parent = worldmap,
								create 'ImageLabel' {
									BackgroundTransparency = 1.0,
									Image = 'rbxassetid://8689486814',
									ImageRectSize = Vector2.new(768, 64),
									ImageRectOffset = Vector2.new(0, 640-64),
									Size = UDim2.new(192/352, 0, 1.0, 0),
									ResampleMode = Enum.ResamplerMode.Pixelated,
									ZIndex = 3,
								},
								create 'ImageLabel' {
									BackgroundTransparency = 1.0,
									Image = 'rbxassetid://8689486624',
									ImageRectSize = Vector2.new(640, 64),
									ImageRectOffset = Vector2.new(0, 640-64),
									Size = UDim2.new(160/352, 0, 1.0, 0),
									Position = UDim2.new(192/352, 0, 0.0, 0),
									ResampleMode = Enum.ResamplerMode.Pixelated,
									ZIndex = 3,
								},
							}
							extraMapBuffers.bottom[i] = b
						end
					end
				end

				scrollingBg.Position = UDim2.new((charPos.X-5+(dir.X<0 and -1 or 0))/22, 0, (charPos.Y-5+(dir.Y<0 and -1 or 0))/22, 0)

				local newPikachuOffset = -dir
				pikachuOW.ZIndex = ((pikachuOffset.Y==1 or newPikachuOffset.Y==1) and pikachuOffset.Y>-1 and newPikachuOffset.Y>-1) and 7 or 5
				local pikaDir = (newPikachuOffset == pikachuOffset) and dir or ((newPikachuOffset-pikachuOffset) * Vector2.new(math.abs(pikachuOffset.X), math.abs(pikachuOffset.Y))).unit
				local pikachuOffsetSet = pikachuRectOffsets[pikaDir.X+2*pikaDir.Y]
				pikachuOW.ImageRectOffset = pikachuOffsetSet[2]
				trainerOW.ImageRectOffset = offsetSet[isRight and 2 or 3]
				local walkTime = .35
				delay(walkTime*.25, function()
					pikachuOW.ImageRectOffset = pikachuOffsetSet[1]
				end)
				delay(walkTime*.5, function()
					pikachuOW.ImageRectOffset = pikachuOffsetSet[3]
					trainerOW.ImageRectOffset = offsetSet[1]
				end)
				delay(walkTime*.75, function()
					pikachuOW.ImageRectOffset = pikachuOffsetSet[1]
				end)
				Utilities.Tween(.35, nil, function(a)
					local midPos = charPos + dir*a
					worldmap.Position = UDim2.new(((-midPos.X+5)*2)*cell.X, 0, ((-midPos.Y+5)*2)*cell.Y, 0)
					local po = pikachuOffset + (newPikachuOffset - pikachuOffset)*a
					pikachuOW.Position = UDim2.new((8+po.X*2)*cell.X, 0, (8+po.Y*2)*cell.Y-4/144, 0)
				end)
				charPos = Vector2.new(math.max(pos.X, -4), math.min(26, math.max(pos.Y, -2)))
				pikachuOffset = newPikachuOffset
				if charPos == encounterPosition then
					warn("Running Battle")
					battle()
				end
			else
				local thisThread = {}
				collisionThread = thisThread
				Utilities.Tween(.7, nil, function(a)
					if collisionThread ~= thisThread then return false end
					if a < .5 then
						trainerOW.ImageRectOffset = offsetSet[isRight and 2 or 3]
					else
						trainerOW.ImageRectOffset = offsetSet[1]
					end
				end)
				if collisionThread ~= thisThread then return end
				collisionThread = nil
			end
			local dir = interaction:getDir()
			if dir then
				return tryMove(dir)
			end
			isMoving = false
		end
		function event:dirKeyPressed()
			if isMoving and not collisionThread then return end
			local dir = interaction:getDir()
			if not dir then return end
			collisionThread = nil
			tryMove(dir)
		end
	end



	chatBox = makeBorderedFrame(20, 6, 0, 12, 3)

	-- Battle
	local mainBattleMenu, moveInfo, movesMenu, itemMenu

	mainBattleMenu = makeBorderedFrame(12, 6, 8, 12, 4)
	mainBattleMenu.Parent = screen
	write('FIGHT', mainBattleMenu, 2, 2)
	write('ITEM', mainBattleMenu, 2, 4)
	write('[PK][MN]', mainBattleMenu, 8, 2)
	write('RUN', mainBattleMenu, 8, 4)
	mainBattleMenu.Parent = nil
	do
		local function onRunClicked()
			interaction:setContext()
			setZIndex(chatBox, 6)
			say(true, "Can[']t escape!")
			setZIndex(chatBox, 3)
			interaction:setContext('BattleMainMenu')
		end
		local fight = interaction:registerSelectable('BattleMainMenu', 10, 14, 5, 1, false, nil, function() 
			mainBattleMenu.Parent = nil
			moveInfo.Parent = screen
			movesMenu.Parent = screen
			interaction:setContext('BattleMovesMenu') 
		end)
		local pkmn  = interaction:registerSelectable('BattleMainMenu', 16, 14, 2, 1, false, nil, function() 
			
		end)
		local item  = interaction:registerSelectable('BattleMainMenu', 10, 16, 4, 1, false, nil, function() 
			mainBattleMenu.Parent = nil
			itemMenu.Parent = screen
			interaction:setContext('ItemMenu') 
		end)
		local run   = interaction:registerSelectable('BattleMainMenu', 16, 16, 3, 1, false, nil, onRunClicked)
		fight.right = pkmn;  fight.down = item;
		pkmn.left   = fight; pkmn.down  = run;
		item.right  = run;   item.up    = fight;
		run.left    = item;  run.up     = pkmn;
	end

	moveInfo = makeBorderedFrame(11, 5, 0, 8, 5)
	moveInfo.Parent = screen
	write('TYPE/', moveInfo, 1, 1)
	moveInfo.Parent = nil
	movesMenu = makeBorderedFrame(16, 6, 4, 12, 4)
	movesMenu.Parent = screen
	write('THUNDER', movesMenu, 2, 1)
	write('QUICK ATTACK', movesMenu, 2, 2)
	write('AGILITY', movesMenu, 2, 3)
	write('DOUBLE TEAM', movesMenu, 2, 4)
	movesMenu.Parent = nil
	local pp = {8, 0, 0, 0}--10, 30, 30, 15}
	do
		local types = {'ELECTRIC', 'NORMAL', 'PSYCHIC', 'NORMAL'}
		local maxpp = {10, 30, 30, 15}
		local typeMsg, ppMsg
		local function updateInfo(n)
			pcall(function() typeMsg:remove() end)
			pcall(function() ppMsg:remove() end)
			typeMsg = write(types[n], moveInfo, 2, 2)
			ppMsg = write(string.format('%2d/%2d', pp[n], maxpp[n]), moveInfo, 5, 3)
		end
		local function noPP()
			interaction:setContext()
			setZIndex(chatBox, 6)
			say(true, 'No PP left for', 'this move!')
			setZIndex(chatBox, 3)
			interaction:setContext('BattleMovesMenu')
		end
		local function onThunderClicked()
			interaction:setContext()
			moveInfo.Parent = nil
			movesMenu.Parent = nil
			say(true, 'PIKACHU', 'used THUNDER!')
			local bg = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = BLACK_COLOR,
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(0.0, 0, 0.0, -36),
				ZIndex = 10, Parent = gui,
			}
			spawn(function() _p.MusicManager:popMusic('RotomBattle', .5, true) end)
			Utilities.Tween(.5, nil, function(a)
				bg.BackgroundTransparency = 1-a
			end)
			bg.Parent = nil
			gui:ClearAllChildren()
			bg.Parent = gui
			wait(1)
			Utilities.Tween(.5, nil, function(a)
				bg.BackgroundTransparency = a
			end)
			gui:remove()
			event.FinishedSignal:fire()
		end
		local m1 = interaction:registerSelectable('BattleMovesMenu', 6, 13, 12, 1, false, function() updateInfo(1) end, onThunderClicked)
		local m2 = interaction:registerSelectable('BattleMovesMenu', 6, 14, 12, 1, false, function() updateInfo(2) end, noPP)
		local m3 = interaction:registerSelectable('BattleMovesMenu', 6, 15, 12, 1, false, function() updateInfo(3) end, noPP)
		local m4 = interaction:registerSelectable('BattleMovesMenu', 6, 16, 12, 1, false, function() updateInfo(4) end, noPP)
		m1.up = m4; m1.down = m2;
		m2.up = m1; m2.down = m3;
		m3.up = m2; m3.down = m4;
		m4.up = m3; m4.down = m1;
	end

	itemMenu = makeBorderedFrame(16, 11, 4, 2, 5)
	itemMenu.Parent = screen
	write('HELIX FOSSIL', itemMenu, 2, 2)
	write('CANCEL', itemMenu, 2, 4)
	itemMenu.Parent = nil
	do
		local fossil = interaction:registerSelectable('ItemMenu', 6, 4, 12, 1, false, nil, function()
			interaction:setContext()
			setZIndex(chatBox, 6)
			local ea = write('[right_empty]', itemMenu, 1, 2)
			say(false, 'OAK: RED!', "This isn[']t the ", 'time to use that!')
			ea:remove()
			setZIndex(chatBox, 3)
			interaction:setContext('ItemMenu')
		end)
		local cancel = interaction:registerSelectable('ItemMenu', 6, 6, 12, 1, false, nil, function() 
			itemMenu.Parent = nil
			mainBattleMenu.Parent = screen
			interaction:setContext('BattleMainMenu') 
		end)
		fossil.down = cancel
		cancel.up   = fossil
	end

	local rotom = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://8695612940',
		ImageRectSize = Vector2.new(56, 56), 
		--ImageRectSize = Vector2.new(56*4, 56*4),
		--ImageRectOffset = Vector2.new(200*4, 24*4),
		Size = UDim2.new(7*cell.X, 0, 7*cell.Y, 0),
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 3,
	}
	local trainer = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = "rbxassetid://8675216731",
		ImageRectSize = Vector2.new(56, 56), 
		--ImageRectSize = Vector2.new(56*4, 56*4),
		--ImageRectOffset = Vector2.new(112*4, 0),
		Size = UDim2.new(7*cell.X, 0, 7*cell.Y, 0),
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 3,
	}
	local pikachu = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = "rbxassetid://8675683443",
		ImageRectSize = Vector2.new(56, 48), 
		--ImageRectSize = Vector2.new(56*4, 48*4),
		--ImageRectOffset = Vector2.new(48*4, 24*4),
		Size = UDim2.new(7*cell.X, 0, 6*cell.Y, 0),
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 3,
	}

	local partyIndicator = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = "rbxassetid://8691805402",
		ImageRectSize = Vector2.new(320, 64),
		--ImageRectSize = Vector2.new(80*4, 16*4),
		--ImageRectOffset = Vector2.new(120*4, 64*4),
		Size = UDim2.new(10*cell.X, 0, 2*cell.Y, 0),
		Position = UDim2.new(9*cell.X, 0, 10*cell.Y, 0),
		ResampleMode = Enum.ResamplerMode.Pixelated,
		ZIndex = 4,
		create 'ImageLabel' { -- ball
			BackgroundTransparency = 1.0,
			Image = "", 
			ImageRectSize = Vector2.new(56, 48), 
			--ImageRectSize = Vector2.new(8*4, 8*4),
			--ImageRectOffset = Vector2.new(0, 3*8*4),
			Size = UDim2.new(1/10, 0, 1/2, 0),
			Position = UDim2.new(2/10, 0, 0.0, 0),
			ResampleMode = Enum.ResamplerMode.Pixelated,
			ZIndex = 5,
		}
	}

	local opponentInfo = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(10*cell.X, 0, 4*cell.Y, 0),
		Position = UDim2.new(cell.X, 0, 0.0, 0),
		create 'Frame' {
			BackgroundTransparency = 1.0,
			Name = 'NameContainer',
			Size = UDim2.new(0.1, 0, 0.25, 0),
			ZIndex = 3,
		},
		create 'Frame' {
			BackgroundTransparency = 1.0,
			Name = 'LevelContainer',
			Size = UDim2.new(0.1, 0, 0.25, 0),
			Position = UDim2.new(0.3, 0, 0.25, 0),
			ZIndex = 3,
		},
		create 'ImageLabel' { -- arrow
			BackgroundTransparency = 1.0,
			Image = "rbxassetid://8678663334", 
			ImageRectSize = Vector2.new(80, 16), 
			--ImageRectSize = Vector2.new(80*4, 16*4),
			--ImageRectOffset = Vector2.new(3*8*4, 0),
			Size = UDim2.new(1.0, 0, 0.5, 0),
			Position = UDim2.new(0.0, 0, 0.5, 0),
			ZIndex = 3,
			ResampleMode = Enum.ResamplerMode.Pixelated
		},
		create 'ImageLabel' { -- hpbar
			BackgroundTransparency = 1.0,
			Image = "rbxassetid://8678663099", 
			ImageRectSize = Vector2.new(72, 8), 
			--ImageRectSize = Vector2.new(72*4, 8*4),
			--ImageRectOffset = Vector2.new(3*8*4, 2*8*4),
			Size = UDim2.new(0.9, 0, 0.25, 0),
			Position = UDim2.new(0.1, 0, 0.5, 0),
			ZIndex = 3,
			ResampleMode = Enum.ResamplerMode.Pixelated
		},
		create 'Frame' {
			Name = 'HPFillBar',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(48/80, 0, 2/32, 0),
			Position = UDim2.new(24/80, 0, 19/32, 0),
			create 'Frame' {
				Name = 'Filler',
				BorderSizePixel = 0,
				ZIndex = 4,
			}
		},
	}
	local myInfo = create 'Frame' {
		BackgroundTransparency = 1.0,
		Size = UDim2.new(10*cell.X, 0, 5*cell.Y, 0),
		Position = UDim2.new(9*cell.X, 0, 7*cell.Y, 0),
		create 'Frame' {
			BackgroundTransparency = 1.0,
			Name = 'NameContainer',
			Size = UDim2.new(0.1, 0, 0.2, 0),
			Position = UDim2.new(0.1, 0, 0.0, 0),
			ZIndex = 3,
		},
		create 'Frame' {
			BackgroundTransparency = 1.0,
			Name = 'LevelContainer',
			Size = UDim2.new(0.1, 0, 0.2, 0),
			Position = UDim2.new(0.5, 0, 0.2, 0),
			ZIndex = 3,
		},
		create 'Frame' {
			BackgroundTransparency = 1.0,
			Name = 'HealthContainer',
			Size = UDim2.new(0.1, 0, 0.2, 0),
			Position = UDim2.new(0.2, 0, 0.6, 0),
			ZIndex = 3,
		},
		create 'ImageLabel' { -- arrow
			BackgroundTransparency = 1.0,
			Image = "rbxassetid://8678663185", 
			ImageRectSize = Vector2.new(80, 24), 
			--ImageRectSize = Vector2.new(80*4, 24*4),
			--ImageRectOffset = Vector2.new(176*4, 0),
			Size = UDim2.new(1.0, 0, 0.6, 0),
			Position = UDim2.new(0.0, 0, 0.4, 0),
			ResampleMode = Enum.ResamplerMode.Pixelated,
			ZIndex = 3,
		},
		create 'ImageLabel' { -- hpbar
			BackgroundTransparency = 1.0,
			Image = "rbxassetid://8678663099", 
			ImageRectSize = Vector2.new(72, 8), 
			--ImageRectSize = Vector2.new(72*4, 8*4),
			--ImageRectOffset = Vector2.new(3*8*4, 2*8*4),
			Size = UDim2.new(0.9, 0, 0.2, 0),
			Position = UDim2.new(0.1, 0, 0.4, 0),
			ResampleMode = Enum.ResamplerMode.Pixelated,
			ZIndex = 3,
		},
		create 'Frame' {
			Name = 'HPFillBar',
			BackgroundTransparency = 1.0,
			Size = UDim2.new(48/80, 0, 2/40, 0),
			Position = UDim2.new(24/80, 0, 19/40, 0),
			create 'Frame' {
				Name = 'Filler',
				BorderSizePixel = 0,
				ZIndex = 4,
			}
		},
	}

	battle = function()
		_p.MusicManager:popMusic('LavenderTown', 0, true)
		_p.MusicManager:stackMusic(9537515115, 'RotomBattle', .5)

		wait(.25)
		pikachuOW.Visible = false
		local flash = create 'Frame' {
			BorderSizePixel = 0,
			BackgroundColor3 = BLACK_COLOR,
			Size = UDim2.new(1.0, 0, 1.0, 0),
			ZIndex = 5, Parent = screen,
		}
		for i = 1, 3 do
			Utilities.Tween(.25, nil, function(a)
				--			local n = (248 - 224*a)/255
				--			screen.BackgroundColor3 = Color3.new(n, n, n)
				flash.BackgroundTransparency = 1-a
			end)
			Utilities.Tween(.25, nil, function(a)
				--			local n = (24 + 224*a)/255
				--			screen.BackgroundColor3 = Color3.new(n, n, n)
				flash.BackgroundTransparency = a
			end)
		end
		Utilities.Tween(.25, nil, function(a)
			flash.BackgroundTransparency = 1-a
		end)
		wait(.25)
		flash:remove()

		worldmap.Visible = false
		trainerOW.Visible = false

		interaction:setContext()
		moveInfo.Parent = nil
		movesMenu.Parent = nil
		opponentInfo.Parent = nil
		mainBattleMenu.Parent = nil
		myInfo.Parent = nil
		pikachu.Parent = nil
		screen.Visible = false
		chatBox.Parent = screen
		wait(.75)
		screen.Visible = true
		rotom.ImageColor3 = Color3.new(0, 0, 0)
		rotom.Parent = screen
		trainer.ImageColor3 = Color3.new(0, 0, 0)
		trainer.Parent = screen
		local units = 2
		Utilities.Tween(1.5, nil, function(a)
			local p = math.floor((152*a)/units+.5)*units
			rotom.Position = UDim2.new(p/160-7*cell.X, 0, 0.0, 0)
			trainer.Position = UDim2.new((160-p)/160, 0, 5*cell.Y, 0)
		end)
		rotom.ImageColor3 = Color3.new(1, 1, 1)
		trainer.ImageColor3 = Color3.new(1, 1, 1)
	
		partyIndicator.Parent = screen
		say(true, 'Wild ROTOM', 'appeared!')
		partyIndicator.Parent = nil
		opponentInfo.NameContainer:ClearAllChildren()
		opponentInfo.LevelContainer:ClearAllChildren()
		local ofiller = opponentInfo.HPFillBar.Filler
		ofiller.BackgroundColor3 = HEALTH_GREEN
		ofiller.Size = UDim2.new(1.0, 0, 1.0, 0)
		opponentInfo.Parent = screen
		write('ROTOM', opponentInfo.NameContainer, 0, 0)
		write('[:L]25', opponentInfo.LevelContainer, 0, 0)
		Utilities.Tween(.4, nil, function(a)
			local p = math.floor((64*a)/units+.5)*units
			trainer.Position = UDim2.new((8-p)/160, 0, 5*cell.Y, 0)
		end)
		trainer.Parent = nil
		say(true, 'Go! PIKACHU!')
		myInfo.NameContainer:ClearAllChildren()
		myInfo.LevelContainer:ClearAllChildren()
		myInfo.HealthContainer:ClearAllChildren()
		local mfiller = myInfo.HPFillBar.Filler
		mfiller.BackgroundColor3 = HEALTH_GREEN
		mfiller.Size = UDim2.new(1.0, 0, 1.0, 0)
		myInfo.Parent = screen
		write('PIKACHU', myInfo.NameContainer, 0, 0)
		write('[:L]42', myInfo.LevelContainer, 0, 0)
		write('110/110', myInfo.HealthContainer, 0, 0)
		pikachu.Parent = screen
		Utilities.Tween(.4, nil, function(a)
			local p = math.floor((64*a)/units+.5)*units
			pikachu.Position = UDim2.new((8-64+p)/160, 0, 6*cell.Y, 0)
		end)
		mainBattleMenu.Parent = screen
		interaction:setContext('BattleMainMenu')
	end


	function event:activate()
		if self.activated then
			--		battle()
			return
		end
		self.activated = true
		spawn(function() _p.Menu:disable() end)
		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
		_p.MasterControl:Hidden(true) --

		Utilities.backGui.Parent = nil
		Utilities.gui.Parent = nil
		Utilities.frontGui.Parent = nil

		interaction:connect()

		interaction:setContext('Overworld')

		_p.MusicManager:stackMusic(9537515115, 'LavenderTown', .3)
	end


	return event
end