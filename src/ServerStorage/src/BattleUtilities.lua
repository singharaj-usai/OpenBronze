local util = {} -- table for utility functions

-- Define undefined and null metatables to handle attempts to index or assign to these values
local undefined, null = {isUndefined = true}, {isNull = true}
setmetatable(undefined, {
	__eq = function(a, b) return rawget(a, 'isUndefined') and rawget(b, 'isUndefined') end,
	__index = function(_, key) error('attempt to index field '..tostring(key)..' of <undefined>', 2) end,
	__newindex = function(_, key, value) error('attempt to assign '..tostring(value)..' to field '..tostring(key)..' of <undefined>', 2) end,
	__metatable = true
})
setmetatable(null, {
	__eq = function(a, b) return rawget(a, 'isNull') and rawget(b, 'isNull') end,
	__index = function(_, key) error('attempt to index field '..tostring(key)..' of <null>', 2) end,
	__newindex = function(_, key, value) error('attempt to assign '..tostring(value)..' to field '..tostring(key)..' of <null>', 2) end,
	__metatable = true
})
util.undefined = undefined
util.null = null

-- Import Utilities module
local Utilities
local serverStorage = game:GetService('ServerStorage')
if script:IsDescendantOf(serverStorage) then
	Utilities = require(serverStorage.Utilities)
else
	Utilities = require(game:GetService('Players').LocalPlayer.Utilities)
end

-- Add utility functions from Utilities module to util table
util.class = Utilities.class
util.subclass = Utilities.subclass
util.toId = Utilities.toId
util.split = Utilities.split
util.deepcopy = Utilities.deepcopy
util.shallowcopy = Utilities.shallowcopy
util.trim = Utilities.trim
util.rc4 = Utilities.rc4
util.map = Utilities.map
util.sync = Utilities.Sync
util.comma_value = Utilities.comma_value


util.jsonEncode = function(...) return game:GetService('HttpService'):JSONEncode(...) end


function util.Not(value)
	-- If value is equal to null or undefined or an empty string or 0 or not v then return true
	return value == null or value == undefined or value == '' or value == 0 or not value
end

-- This function creates a shallow copy of a table.
-- A shallow copy means that the copied table will have references to the same values as the original table, rather than creating new copies of the values. 
-- The function creates an empty table called 'copy', then iterates over each key-value pair in the original table and adds them to the copy table. 
-- Finally, it returns the copy table.
function util.shallowcopy(originalTable)
	local copy = {} -- create an empty table to store the copy
	-- iterate over each key-value pair in the original table
	for key, value in pairs(originalTable) do
		-- add the key-value pair to the copy table
		copy[key] = value
	end
	-- return the copy table
	return copy
end

-- This function creates a new table called "newTab" and iterates through the key-value pairs in the input table "tab".
-- If the callback function "fn" returns true when passed the value, key, and input table, then the key-value pair is added to the new table "newTab".
-- At the end, the new table "newTab" is returned.
function util.filter(tab, fn)
	local newTab = {}
	for key, value in pairs(tab) do
		if fn(value, key, tab) then
			newTab[key] = value
		end
	end
	return newTab
end

-- This function returns the index of the first occurrence of searchValue in searchObject.
-- If searchObject is a table, it searches through the values of the table.
-- If searchObject is a string, it searches through the characters of the string.
-- If searchValue is not found, it returns nil.
function util.indexOf(searchObject, searchValue)
	if type(searchObject) == 'table' then
		-- Iterate through each key-value pair in the table.
		for index, value in pairs(searchObject) do
			-- If the value equals the search value, return the index.
			if value == searchValue then
				return index
			end
		end
	elseif type(searchObject) == 'string' then
		-- Get the length of the search object and search value strings.
		local objLen = #searchObject
		local valLen = #searchValue
		-- If the search value is longer than the search object, return nil.
		if valLen > objLen then return end
		-- Iterate through each possible substring of searchObject with a length of valLen.
		for i = 1, objLen-valLen+1 do
			-- If the current substring equals the search value, return the starting index.
			if string.sub(searchObject, i, i+valLen-1) == searchValue then
				return i
			end
		end
	end
end

-- This function checks if the given object is an array (a table with only numeric keys).
-- It takes an optional second argument, which is a list of keys that are allowed to be present in the table.
function util.isArray(obj, ...)
	-- If the object is not a table, it can't be an array
	if type(obj) ~= 'table' then return false end
	-- Create a list of exceptions (keys that are allowed to be present in the table)
	local exceptions = {}
	for _, e in pairs({...}) do
		exceptions[e] = true
	end
	-- Iterate through all keys in the table
	for i in pairs(obj) do
		-- If the key is not a number and is not in the exceptions list, return false (table is not an array)
		if type(i) ~= 'number' and not exceptions[i] then
			return false
		end
	end
	-- If no non-numeric, non-excepted keys were found, return true (table is an array)
	return true
end



return util
