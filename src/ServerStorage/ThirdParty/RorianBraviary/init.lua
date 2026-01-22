-- todo
-- launch / splash screen (animated braviary)
-- disclaimer / about screen

-- I'm shiny and I know it

local module = {}
local main = require(script.RBModule)

--[[
-- SECURITY CHECK: ensure database is solely a string
--   Update: we can't be sure arbitrary code is not run before the string is returned
--   New solution: manage the database myself, require them to send me updates of it
local database = require()

local function check()
	if type(database) ~= 'table' then return false end
	for i, v in pairs(database) do
		if i ~= 1 or type(v) ~= 'string' then return false end
	end
	
	return true
end

if not check() then
	module.fail = true
	return module
end
]]

function module.handleClientRequest(player, fn)
	if fn == 'open' then
		main.On(player)
		return true
	end
end



return module