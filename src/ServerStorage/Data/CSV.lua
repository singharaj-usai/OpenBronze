print("CSV")

local _debug = false

return function(export_md, str)
	if not str and type(export_md) == 'string' then
		str = export_md
		export_md = {}
	end
	if not export_md then
		export_md = {}
	end
	local keys = {}
	local line1start, line1end = str:find('^[^\n]+\n')
	for key in str:sub(line1start, line1end-1):gmatch('[^,]+') do
		table.insert(keys, key)
	end
	local data = {}
	for line in str:sub(line1end+1):gmatch('[^\n]+') do
		local entry = {}
		local empty = true
		local key = 1
		local charindex = 1
		while charindex <= #line do
			local char = line:sub(charindex, charindex)
			if char == ',' then
				key = key + 1
				charindex = charindex + 1
			else
				local _, e, value = line:find('([^,]+)', charindex)
				if char == '"' then
					_, e, value = line:find('([^"]+)', charindex)
					e = e + 1
					while line:sub(e, e+1) == '""' do
						local _, newE, v = line:find('([^"]+)', e+2)
						if newE then
							e = newE + 1
						else
							e = e + 2
						end
						value = value .. '"' .. (v or '')
					end
--					value = value:sub(2)
				end
				if e and value then
					local keyname = keys[key]
					if (not export_md.exclude or not export_md.exclude[keyname]) and (not export_md.include or export_md.include[keyname]) then
						value = tonumber(value) or value
						if export_md.map and export_md.map[keyname] then
							value = export_md.map[keyname](value)
						end
						if value ~= nil then
							entry[keyname] = value
							empty = false
						end
					end
					key = key + 1
					charindex = e + 2
				end
			end
		end
		if not empty then
			table.insert(data, entry)
			if _debug then
				local s = ''
				for key, value in pairs(entry) do
					s = s .. key .. ' = ' .. tostring(value) .. ', '
				end
				print(s)
			end
		end
	end
	return data
end