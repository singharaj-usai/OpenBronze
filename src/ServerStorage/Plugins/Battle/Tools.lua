local trim, toId; do
	local util = require(script.Parent.BattleUtilities)
	trim = util.trim
	toId = util.toId
end

local Tools = {}
local cache = {}


local function getData(kind, id)
	if not id or id == '' then
		return {id = '', effectType = kind}
	end
	if ({unboost=true,nopp=true,recoil=true,psn=true,brn=true,protect=true,stockpile1=true,stockpile2=true,stockpile3=true,perish3=true,perish2=true,perish1=true,perish0=true, zpower=true})[id] then
		return {id = id, effectType = kind}
	end
	if not cache[kind] then
		warn('attempt to lookup pre-queried data; no cache for kind '..kind..' ('..id..')')
		return
	end
	local d = cache[kind][id] or cache[kind][toId(id)]
	if kind:lower() == 'effect' then
		for _, k in pairs({'Move', 'Template', 'Ability', 'Item'}) do
			if d then break end
			if cache[k] then
				d = cache[k][id] or cache[k][toId(id)]
			end
		end
	end
	if not d then
		warn('attempt to lookup pre-queried data; no value cached under '..kind..'.'..id)
		return --{id = id}
	end
	return d
end

function Tools.getEffect(effect)
	if not effect or type(effect) == 'string' then
		local name = trim(effect or '')
		if name:sub(1, 5) == 'item:' then
			return Tools.getItem(name:sub(6))
		elseif name:sub(1, 7) == 'item = ' then
			return Tools.getItem(name:sub(8))
		elseif name:sub(1, 8) == 'ability:' then
			return Tools.getAbility(name:sub(9))
		elseif name:sub(1, 10) == 'ability = ' then
			return Tools.getAbility(name:sub(11))
		elseif name:sub(1, 5) == 'move:' then
			return Tools.getMove(name:sub(6))
		elseif name:sub(1, 7) == 'move = ' then
			return Tools.getMove(name:sub(8))
		end
		return getData('Effect', toId(name))
	end
	return effect
end

for _, kind in pairs({'Template', 'Move', 'Ability', 'Item'}) do
	Tools['get'..kind] = function(name)
		return getData(kind, toId(name))
	end
end

function Tools.getSprite(key)
--	require(game.ServerStorage.Utilities).print_r(cache)
	return getData('Sprite', key) -- does not toId()
end

function Tools.getARQPacket(arq_id)
	
end

function Tools.add(kind, id, data)
	if not cache[kind] then
		cache[kind] = {}
	end
	cache[kind][id] = data
end

function Tools.empty()
	cache = {}
end


return Tools