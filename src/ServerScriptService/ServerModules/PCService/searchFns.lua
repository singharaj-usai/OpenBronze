local flagTypes = {"shiny", "hiddenAbility"}
local genders = {"M", "F", nil}
local statTypes = {"BaseStats", "Stats", "IVs", "EVs"}

local function IsAllOfHandler(p, list, d, opt)
	local check

	-- empty, Is, Is Not
	-- is any of, is all of, is none of

	for i, v in pairs(list) do
		check = table.find(d, v) and true or false

		if table.find({1, 3}, opt) and check then
			break
		elseif opt == 2 and not check then
			break
		end
	end

	if opt == 3 then
		check = not check
	end

	return check
end

local function GreaterLessEaqualsHandler(p, list, d, opt)
	local check

	for k, v in pairs(list) do
		local o, n = unpack(v)

		--print("Level Stuff:", o, n)
		check = false

		if o == 1 and d > n then
			check = true
		elseif o == 2 and d < n then
			check = true
		elseif o == 3 and d == n then
			check = true
		end    

		if not check then break end
	end

	return check
end

local searchFns =  {
	["class"] = IsAllOfHandler,
	["moves"] = IsAllOfHandler,
	["level"] = GreaterLessEaqualsHandler,
	["type"] = IsAllOfHandler,
	["flags"] = function(p, list, d, opt)
		local check

		for v, flag in pairs(flagTypes) do
			check = p[flag] == list[v]
			if not check then break end
		end

		return check
	end,
	["egggroup"] = function(p, list, d, opt)
		local check

		if type(d) == "table" then
			for i, eggGroup in pairs(list) do
				check = table.find(d, eggGroup) and true or false
				if check then
					break
				end
			end
		elseif type(d) == "string" then
			check = table.find(list, d)
		end

		if opt == 2 then
			check = not check
		end

		return check
	end,
	["gender"] = function(p, list, d, opt)
		for k, v in pairs(list) do
			if v and genders[k] == d then
				return true
			end
		end

		return false
	end,
}

for i, statType in pairs(statTypes) do
	searchFns[string.lower(statType)] = function(p, list, d, opt)
		local check
		
		for k, v in pairs(list) do	
			
			check = GreaterLessEaqualsHandler(nil, v, d[tonumber(k)], nil)

			if not check then break end
		end

		return check
	end
end

return searchFns