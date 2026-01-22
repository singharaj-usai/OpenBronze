-- FontCreator

local fontCreator = {}
local out = {}
local loaderBin = script--game:GetService('ReplicatedStorage').FontBin

--
--

setmetatable(out, {
	__index = function(out, index)
		if fontCreator[index] then
			return fontCreator[index]
		else
			error(tostring(index)..' is not a valid member of fontCreator')
		end
	end,

	__newindex = function(out, index, value)
		error('fontCreator.'..tostring(index)..' cannot be set')
	end
})

--
--

function findInString(str, text)
	local startingIndex = 0
	local checkingIndex = 1

	for i=1, #str do
		if str:sub(i,i) == text:sub(checkingIndex, checkingIndex) then
			if checkingIndex == 2 then
				startingIndex = i-1
			end

			if checkingIndex == #text then
				-- print('found "' .. text .. '" in "' .. str .. '" at ' .. startingIndex .. 'x' .. i) wait()
				return startingIndex, i
			end

			checkingIndex = checkingIndex + 1
		end
	end

	return nil
end

--
--

local loadedFonts = {}
local fontObjs = {} -- out=font

local fontMeta = {
	__index = function(fout, index)
		if fontObjs[fout][index] then
			return fontObjs[fout][index]
		else
			error(tostring(index)..' is not a valid member of font')
		end
	end,

	__newindex = function(fout, index, value)
		error('font.'..tostring(index)..' cannot be set')
	end
}

fontCreator.load = function(name)
	if type(name) == 'string' and loadedFonts[name] then
		return loadedFonts[name]
	else
		local f = {}
		local fout = {}
		setmetatable(fout, fontMeta)
		fontObjs[fout] = f

		local info
		if type(name) == 'string' then
			local loaderObj = loaderBin:FindFirstChild(name)

			if loaderObj == nil then
				error(tostring(name)..' is not a valid font name')
			end

			info = require(loaderObj)
		elseif type(name) == 'table' then
			info = name
			name = info.name
		end

		for i,v in next, info do f[i] = v end

		--
		-- find what size to scale the characters to

		local maxCharHeight = 0

		for char, bounds in next, f.map do
			maxCharHeight = math.max(maxCharHeight, bounds[4])
		end

		f.baseHeight = maxCharHeight

		--
		-- create a list of special word characters

		f.specialWordCharacters = {}

		for index, char in next, f.specialWordCharactersList or {} do
			f.specialWordCharacters[char] = true
		end

		--
		-- create utility functions

		function f.transformCharacter(char)
			if f.lowercase == 'none' or f.lowercase == nil then
				return char
			elseif f.lowercase == 'determinate' then
				if f.map[char] ~= nil then
					return char
				elseif f.map[char:upper()] ~= nil then
					return char:upper()
				elseif f.map[char:lower()] ~= nil then
					return char:lower()
				end

				return char
			elseif f.lowercase == 'all' then
				return char:lower()
			end
		end

		function f.getCharBounds(char)
			return f.map[f.transformCharacter(char)]
		end

		function f.getStringSize(str, fontSize)
			local sizemx = fontSize/f.baseHeight
			local totalSize = Vector2.new(0, 0)

			local specials = {} -- index = bounds

			for char, bounds in next, f.map do
				if #char > 1 then
					local start, fin = findInString(str, char)

					while start ~= nil do
						-- print(str, char, start, fin)
						str = str:sub(1, start-1) .. '_' .. str:sub(fin+1)
						specials[start] = {bounds, f.extensions[char]}
						start, fin = findInString(str, char)
						-- print(str, char, start, fin)
						-- return
					end
				end
			end

			for index=1, #str do
				local specialBounds, specialExt = unpack(specials[index] or {})
				local char = str:sub(index, index)
				local bounds = specialBounds or f.getCharBounds(char) or {0, 0, f.spaceWidth, f.baseHeight}

				local sizemy = sizemx/(1/(bounds[4]/f.baseHeight))
				local relativeSize = Vector2.new(bounds[3]*sizemx + f.letterSpacing, bounds[4]*sizemy)

				local ext = (specialBounds and specialExt) or (not specialBounds and f.extensions[char])

				if ext then
					local relativeExtension = Vector2.new(0, (ext[1]+ext[2])*sizemy)
					relativeSize = relativeSize + relativeExtension
				end

				-- totalSize = totalSize+relativeSize

				totalSize = Vector2.new(
					(totalSize + relativeSize).x,
					math.max(totalSize.y, relativeSize.y)
				)
			end

			return totalSize
		end

		--
		--

		loadedFonts[name] = fout

		return fout
	end
end

--
--

return out