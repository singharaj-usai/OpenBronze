-- FontDisplayService
-- Originally written by ArceusInator/Sharksie
-- Adapted by tbradm

-- todo: max write lines

local fds = {}
local out = {}

local FontCreator = require(script.FontCreator)
local ContentProvider = game:GetService('ContentProvider')
local stepped = game:GetService('RunService').RenderStepped


local wordCharactersString = 'abcdefghijklmnopqrstuvwxyz.?!1234567890/-\'";:,[]{}()<>'
local wordCharacters = {}
for i = 1, #wordCharactersString do
	local char = wordCharactersString:sub(i,i)
	wordCharacters[char:lower()] = true
end


setmetatable(out, {
	__index = function(out, index)
		if fds[index] then
			return fds[index]
		else
			error(tostring(index)..' is not a valid member of fontDisplayService')
		end
	end,
	__newindex = function(out, index, value)
		error('fontDisplayService.'..tostring(index)..' cannot be set')
	end
})


local function tween(duration, fn)
	local st = tick()
	while true do
		stepped:wait()
		local et = tick()-st
		if et >= duration then
			fn(1)
			return
		end
		local a = et/duration
		fn(a)
	end
end

function fds:Preload(name)
	local source = FontCreator.load(name).source
	ContentProvider:Preload(source)
end

function fds:WriteToFrame(fontname, size, text, wraps, frame, wordDetectionEnabled, settings)--color, writingToChatBox, animationRate, transparency)
	local color, writingToChatBox, animationRate, animationFadeDisabled, transparency, scaled, textXAlignment, fadeAfter
	if settings then
		color = settings.Color
		writingToChatBox = settings.WritingToChatBox
		animationRate = settings.AnimationRate
		animationFadeDisabled = settings.AnimationFadeDisabled
		transparency = settings.Transparency
		scaled = settings.Scaled and true or false
		textXAlignment = settings.TextXAlignment-- or Enum.TextXAlignment.Center -- alignment is only applicable when scaling is enabled
		fadeAfter = settings.FadeAfter
	end
	text = text:gsub('[Pp]okemon', 'Pok[e\']mon'):gsub('Flabebe', 'Flab[e\']b[e\']')
	if text == '' then return {} end --return Vector2.new() end

	local originalText = text
	local font = FontCreator.load(fontname)

	local maxBounds = Vector2.new()
	local currentPosition = Vector2.new(0, 0)
	local absoluteCurrentPosition = Vector2.new(0, 0)
	local wrappingBounds = frame.AbsoluteSize
	local sizeMultiplierX = size/font.baseHeight

	local wraps = wraps and true or false
	local wordDetectionEnabled = wordDetectionEnabled and true or false

	local currentWord = ''
	local currentWordPosition = Vector2.new(0, 0)
	local currentWordSpecialLocations = {}
	local currentWordRemovedTextLength = 0

	local specialCases = {} -- int index = string charname

	local removedTextLength = 0
	local removedTextLengths = {}

	local visualCharacters = {}
	local vSize = {}
	local vPosition = {}

	-- load special cases
	for charname, bounds in next, font.map do
		if #charname > 1 then
			local start, fin = text:find(charname, 1, true)
			while start do
				text = text:sub(1, start-1) .. '_' .. text:sub(fin+1)
				specialCases[start] = charname
				removedTextLengths[start] = fin-start

				start, fin = text:find(charname, start+1, true)
			end
		end
	end

	local function tryAddCharacter(charSize, absoluteCharSize)
		if wraps and (currentPosition + charSize).x > wrappingBounds.x then
			currentPosition = Vector2.new(0, currentPosition.y + font.letterSpacing*sizeMultiplierX + size + font.lineSpacing*sizeMultiplierX)
			absoluteCurrentPosition = Vector2.new(0, absoluteCurrentPosition.y + font.letterSpacing + font.baseHeight + font.lineSpacing)
		else
			currentPosition = currentPosition + charSize
			absoluteCurrentPosition = absoluteCurrentPosition + Vector2.new(absoluteCharSize, 0)
		end
	end

	local function addCharacter(char)
		if char == ' ' or char == '\t' then
			local unitLength = (char == ' ' and 1) or (char == '\t' and 3)
			local realSize = (font.spaceWidth+font.letterSpacing)*unitLength*sizeMultiplierX

			tryAddCharacter(Vector2.new(realSize, 0), (font.spaceWidth+font.letterSpacing)*unitLength)
		elseif char == '\n' then
			currentPosition = Vector2.new(0, currentPosition.y + font.letterSpacing*sizeMultiplierX + size + font.lineSpacing*sizeMultiplierX)
			absoluteCurrentPosition = Vector2.new(0, absoluteCurrentPosition.y + font.letterSpacing + font.baseHeight + font.lineSpacing)
		else
			local bounds = font.getCharBounds(char)
			local sizeMultiplierY = sizeMultiplierX/(bounds[4]/font.baseHeight)

			local relativeSize = Vector2.new(bounds[3]*sizeMultiplierX, bounds[4]*sizeMultiplierY)

			--
			local visual = Instance.new 'ImageLabel'
			visual.Name = tostring(#visualCharacters+1)
			visual.BackgroundTransparency = 1
			visual.Image = font.source
			visual.ImageRectOffset = Vector2.new(bounds[1], bounds[2])
			visual.ImageRectSize = Vector2.new(bounds[3], bounds[4])
			visual.Position = UDim2.new(0, currentPosition.x, 0, currentPosition.y)
			visual.Size = UDim2.new(0, relativeSize.x, 0, relativeSize.y)
			vSize[visual] = Vector2.new(bounds[3], bounds[4])
			vPosition[visual] = absoluteCurrentPosition
			visual.ZIndex = frame.ZIndex
			if color then
				visual.ImageColor3 = color
			end
			if animationRate then
				visual.ImageTransparency = 1.0
			elseif transparency then
				visual.ImageTransparency = transparency
			end
			table.insert(visualCharacters, visual)

			tryAddCharacter(Vector2.new(relativeSize.x + (font.letterSpacing*sizeMultiplierX), 0), bounds[3]+font.letterSpacing)

			-- do extension
			local ext = font.extensions[char]
			if ext then
				local top, bottom = ext[1] or 0, ext[2] or 0

				visual.ImageRectOffset = visual.ImageRectOffset + Vector2.new(0, -top)
				visual.ImageRectSize = visual.ImageRectSize + Vector2.new(0, top+bottom)

				visual.Position = visual.Position + UDim2.new(0, 0, 0, sizeMultiplierY*-top)
				visual.Size = visual.Size + UDim2.new(0, 0, 0, sizeMultiplierY*(top+bottom))
				vPosition[visual] = vPosition[visual] + Vector2.new(0, -top)
				vSize[visual] = vSize[visual] + Vector2.new(0, top+bottom)
			end
			--
		end
	end

	local lastWord
	local function addWord()
		if lastWord == '\n' and writingToChatBox then return false end
		lastWord = currentWord
		local wordSize = font.getStringSize(currentWord, size)

		if (currentWordPosition + wordSize).x > wrappingBounds.x and currentWordPosition.x > 0 then
			if writingToChatBox then
				return false
			elseif wraps and wordDetectionEnabled then
				currentPosition = Vector2.new(0, currentWordPosition.y + font.letterSpacing*sizeMultiplierX + size + font.lineSpacing*sizeMultiplierX)
				absoluteCurrentPosition = Vector2.new(0, absoluteCurrentPosition.y + font.letterSpacing + font.baseHeight + font.lineSpacing)
			else
				currentPosition = currentWordPosition
			end
		else
			currentPosition = currentWordPosition
		end

		-- setup special info
		local specialStartingLocations = {} -- int start = vector2 size
		for specialSize, char in next, currentWordSpecialLocations do
			specialStartingLocations[specialSize.x] = specialSize
		end

		local index = 1
		while true do
			local specialSize = specialStartingLocations[index]
			if specialSize then
				local diff = specialSize.y - specialSize.x

				local specialChar = currentWordSpecialLocations[specialSize]
				addCharacter(specialChar)

				index = index + diff
			else
				if index > #currentWord then break end
				addCharacter(currentWord:sub(index,index))
				index = index + 1
			end
		end

		removedTextLength = removedTextLength + currentWordRemovedTextLength

		currentWord = ''
		currentWordPosition = currentPosition
		currentWordSpecialLocations = {}
		currentWordRemovedTextLength = 0

		return true
	end

	local overflow
	local wordStartIndex
	for index=1, #text do
		local char = text:sub(index, index)
		local isSpecial = false

		if specialCases[index] then
			char = specialCases[index]
			isSpecial = true
		end

		if wordCharacters[char:lower()] or font.specialWordCharacters[char] then
			currentWord = currentWord .. char

			if isSpecial then
				currentWordSpecialLocations[Vector2.new(#currentWord-#char+1, #currentWord+1)] = char
			end

			if currentWord == char then -- char is the first letter, set a new currentWordPosition
				currentWordPosition = currentPosition
				wordStartIndex = index
			end

			currentPosition = currentPosition + Vector2.new(font.getStringSize(char, size), 0)
			--			absoluteCurrentPosition = absoluteCurrentPosition + Vector2.new(, 0)
		else
			if currentWord ~= '' then -- need to write the current word
				if not addWord() then
					overflow = originalText:sub(wordStartIndex+removedTextLength)
					break
				end
			end

			addCharacter(char)
		end

		local rtl = removedTextLengths[index]
		if rtl then
			currentWordRemovedTextLength = currentWordRemovedTextLength + rtl
		end
	end

	if currentWord ~= '' then -- there's still a word waiting to be written
		if not addWord() then
			overflow = originalText:sub(wordStartIndex+removedTextLength)
		end
	end

	local absoluteMaxBounds
	do
		local mbx, mby = 0, 0
		local amx, amy = 0, 0
		for index, visual in next, visualCharacters do
			mbx = math.max(mbx, visual.Position.X.Offset+visual.Size.X.Offset)
			mby = math.max(mby, visual.Position.Y.Offset+visual.Size.Y.Offset)
			local vp = vPosition[visual]
			local vs = vSize[visual]
			amx = math.max(amx, vp.X+vs.X)
			amy = math.max(amy, vp.Y+vs.Y)
		end
		maxBounds = Vector2.new(mbx, mby)
		absoluteMaxBounds = Vector2.new(amx, amy)
	end

	-- now parent all the frames.
	local container
	if scaled then
		local mbx = maxBounds.X
		local amx = absoluteMaxBounds.X
		local ht = font.baseHeight
		local f = Instance.new('Frame')
		f.BackgroundTransparency = 1.0
		if textXAlignment == Enum.TextXAlignment.Left then
			f.SizeConstraint = Enum.SizeConstraint.RelativeYY
			f.Size = UDim2.new(amx/ht, 0, 1.0, 0)--(mbx/size, 0, 1.0, 0)
			f.Parent = frame
		elseif textXAlignment == Enum.TextXAlignment.Right then
			f.SizeConstraint = Enum.SizeConstraint.RelativeYY
			f.Size = UDim2.new(-amx/ht, 0, 1.0, 0)--(-mbx/size, 0, 1.0, 0)
			f.Position = UDim2.new(1.0, 0, 0.0, 0)
			f.Parent = frame
		else--if textXAlignment == Enum.TextXAlignment.Center then
			local f2 = f:Clone()
			f2.SizeConstraint = Enum.SizeConstraint.RelativeYY
			f2.Size = UDim2.new(-amx/ht/2, 0, 1.0, 0)--(-mbx/size/2, 0, 1.0, 0)
			f2.Position = UDim2.new(0.5, 0, 0.0, 0)
			f2.Parent = frame
			f.Size = UDim2.new(2.0, 0, 1.0, 0)
			f.Parent = f2
		end
		for index, visual in next, visualCharacters do
			--			visual.Size = UDim2.new(visual.Size.X.Offset/mbx, 0, visual.Size.Y.Offset/size, 0)
			--			visual.Position = UDim2.new(visual.Position.X.Offset/mbx, 0, visual.Position.Y.Offset/size, 0)
			local vs = vSize[visual]
			local vp = vPosition[visual]
			visual.Size = UDim2.new(vs.X/amx, 0, vs.Y/ht, 0)
			visual.Position = UDim2.new(vp.X/amx, 0, vp.Y/ht, 0)
			visual.Parent = f
		end
		container = f
	else
		for index, visual in next, visualCharacters do
			visual.Parent = frame
		end
	end

	-- animation
	if animationRate then
		local mbx = maxBounds.x
		--		transparency = transparency or 0.0 -- todo: support both transparency and animation
		--		local t = mbx/sizeMultiplierX/font.baseHeight/animationRate
		--		print(t)
		if scaled then
			local amx = absoluteMaxBounds.X
			tween(amx/sizeMultiplierX/font.baseHeight/animationRate, function(a)
				local c = amx * a
				for _, v in pairs(visualCharacters) do
					local s = vSize[v].X
					local p = vPosition[v].X
					if animationFadeDisabled then
						v.ImageTransparency = c>=p+s/2 and 0.0 or 1.0
					else
						if c >= p+s then
							v.ImageTransparency = 0.0
						elseif c > p then
							v.ImageTransparency = 1 - (c-p)/s
						end
					end
				end
			end)
		else
			tween(mbx/sizeMultiplierX/font.baseHeight/animationRate, function(a) -- mbx/sizeMultiplierX/font.baseHeight/animationRate
				local c = mbx * a
				for _, v in pairs(visualCharacters) do
					local p = v.Position.X.Offset
					local s = v.Size.X.Offset
					if c >= p+s then
						v.ImageTransparency = 0.0--transparency
					elseif c > p then
						v.ImageTransparency = 1 - (c-p)/s
					end
				end
			end)
		end
		if fadeAfter then
			delay(fadeAfter, function()
				tween(mbx/sizeMultiplierX/font.baseHeight/animationRate, function(a)
					local c = mbx * a
					for _, v in pairs(visualCharacters) do
						local p = v.Position.X.Offset
						local s = v.Size.X.Offset
						if c >= p+s then
							v.ImageTransparency = 1.0
						elseif c > p then
							v.ImageTransparency = (c-p)/s
						end
					end
				end)
			end)
		end
	end

	local thing = {
		Frame = container,
		MaxBounds = maxBounds,
		AbsoluteMaxBounds = absoluteMaxBounds,
		Labels = visualCharacters,
	}
	function thing:remove()
		for _, v in pairs(visualCharacters) do
			v:remove()
		end
	end
	function thing:remove()
		self:remove()
	end

	if writingToChatBox then
		return overflow, thing
	end
	return thing
end

function fds:Write(str)
	return function(settings)
		local wde = settings.WordDetectionEnabled
		if wde == nil then wde = true end
		return self:WriteToFrame(settings.Font or 'Avenir', settings.Size or settings.Frame.AbsoluteSize.Y, str, settings.Wraps or false,
			settings.Frame, wde, settings)--settings.Color, settings.WritingToChatBox or false, settings.AnimationRate, settings.Transparency)
	end
end


return out