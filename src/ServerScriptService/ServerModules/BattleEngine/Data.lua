print("Data")
local undefined, null, class, toId, deepcopy, isArray, split; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	undefined = util.undefined
	null = util.null
	class = util.class
	toId = util.toId
	deepcopy = util.deepcopy
	isArray = util.isArray
	split = util.split
end

local function setupConcatenator(class, classname)
	local fn = function(op1, op2)
		pcall(function() if type(op1) == 'table' then op1 = op1.name end end)
		pcall(function() if type(op2) == 'table' then op2 = op2.name end end)
		local s, r = pcall(function() return op1 .. op2 end)
		assert(s, 'unable to concatenate object of type Battle.'..classname..' ('..r..')')
		return r
	end
	local mt = getmetatable(class)
	if mt then
		pcall(function() mt.__concat = fn end)
	else
		setmetatable(class, {__concat = fn})
	end
end

local gifData = require(game:GetService('ServerStorage').Data.Spritesheets)


return function(Battle)
	local data = {}
	Battle.data = data
	
	for _, file in pairs(game:GetService('ServerStorage').BattleData:GetChildren()) do
		data[file.Name] = require(file)
	end
	
	data.Natures = {
		adamant = {name="Adamant", plus='atk', minus='spa'},
		bashful = {name="Bashful"                         },
		bold =    {name="Bold",    plus='def', minus='atk'},
		brave =   {name="Brave",   plus='atk', minus='spe'},
		calm =    {name="Calm",    plus='spd', minus='atk'},
		careful = {name="Careful", plus='spd', minus='spa'},
		docile =  {name="Docile"                          },
		gentle =  {name="Gentle",  plus='spd', minus='def'},
		hardy =   {name="Hardy"                           },
		hasty =   {name="Hasty",   plus='spe', minus='def'},
		impish =  {name="Impish",  plus='def', minus='spa'},
		jolly =   {name="Jolly",   plus='spe', minus='spa'},
		lax =     {name="Lax",     plus='def', minus='spd'},
		lonely =  {name="Lonely",  plus='atk', minus='def'},
		mild =    {name="Mild",    plus='spa', minus='def'},
		modest =  {name="Modest",  plus='spa', minus='atk'},
		naive =   {name="Naive",   plus='spe', minus='spd'},
		naughty = {name="Naughty", plus='atk', minus='spd'},
		quiet =   {name="Quiet",   plus='spa', minus='spe'},
		quirky =  {name="Quirky"                          },
		rash =    {name="Rash",    plus='spa', minus='spd'},
		relaxed = {name="Relaxed", plus='def', minus='spe'},
		sassy =   {name="Sassy",   plus='spd', minus='spe'},
		serious = {name="Serious"                         },
		timid =   {name="Timid",   plus='spe', minus='atk'},
	}
	
	data.TypeFromInt = {'Bug','Dark','Dragon','Electric','Fairy','Fighting','Fire','Flying','Ghost','Grass','Ground','Ice','Normal','Poison','Psychic','Rock','Steel','Water'}
	
	function Battle:getImmunity(source, target)
		-- returns false if the target is immune; true otherwise
		-- also checks immunity to some statuses
		local sourceType = source.type or source
		local targetTyping = target.getTypes and target:getTypes() or target.types or target
		if type(targetTyping) == 'table' then
			for _, t in pairs(targetTyping) do
				if not self:getImmunity(sourceType, t) then return false end
			end
			return true
		end
		local typeData = self.data.TypeChart[targetTyping]
		if typeData and typeData[sourceType] == 0 then return false end
		return true
	end
	function Battle:getEffectiveness(source, target)
		local sourceType = source.type or source
		local totalEffectivity = 1
		local targetTyping = target.getTypes and target:getTypes() or target.types or target
		if isArray(targetTyping) then
			for _, t in pairs(targetTyping) do
				totalEffectivity = totalEffectivity * self:getEffectiveness(sourceType, t)
			end
			return totalEffectivity
		end
		local typeData = self.data.TypeChart[targetTyping]
		if typeData then
			if typeData[sourceType] == 0 then return 1 end -- I'm not a fan of the way they write this to begin with
			                                               -- but in the end I jacked it up so this is my fix
			return typeData[sourceType] or 1
		end
		return 1
	end
	
	
	local cachedTemplates = {}
	function Battle:getTemplate(template)
		if not template or type(template) == 'string' then
			local name = template or ''
			local id = toId(name)
			self:setupDataForTransferToPlayers('Template', id)
			template = {}
			if id and self.data.Pokedex[id] then
				template = cachedTemplates[id]
				if template then
					if template.baseSpecies then
						local bsid = toId(template.baseSpecies)
						if bsid ~= id then
							self:setupDataForTransferToPlayers('Template', bsid)
						end
					end
					return template
				end
				template = self.data.Pokedex[id]
--				if template.cached then return template end
--				template.cached = true
				template.exists = true
			end
			local tcopy = {}
			for k, v in pairs(template) do
				if k ~= 'learnedMoves' then
					tcopy[k] = v
				end
			end
			template = tcopy
			name = template.species or template.name or name
	--		if self.data.FormatsData[id] then
	--			Object.merge(template, self.data.FormatsData[id])
	--		end
	--		if self.data.Learnsets[id] then
	--			Object.merge(template, self.data.Learnsets[id])
	--		end
			if not template.id then template.id = id end
			if not template.name then template.name = name end
			if not template.speciesid then template.speciesid = id end
			if not template.species then template.species = name end
			if template.baseSpecies then
				local bsid = toId(template.baseSpecies)
				if bsid ~= id then
					self:setupDataForTransferToPlayers('Template', bsid)
				end
			else template.baseSpecies = name end
			if not template.forme then template.forme = '' end
--			if not template.formeLetter then template.formeLetter = '' end
			if not template.spriteid then template.spriteid = template.baseSpecies .. (template.baseSpecies ~= name and '-' .. toId(template.forme) or '') end
			if not template.prevo then template.prevo = '' end
			if not template.evos then template.evos = {} end
			if not template.nfe then template.nfe = (#template.evos > 0) end
--			local sd = gifData[template.species]
--			if not sd then
--				if template.species:sub(-5) == '-Mega' then
--					sd = gifData['Mega '..template.species:sub(1, -6)]
--				elseif template.species:sub(-7) == '-Mega-X' then
--					sd = gifData['Mega '..template.species:sub(1, -8)..' X']
--				elseif template.species:sub(-7) == '-Mega-Y' then
--					sd = gifData['Mega '..template.species:sub(1, -8)..' Y']
--				elseif template.species:sub(-7) == '-Primal' then
--					sd = gifData['Primal '..template.species:sub(1, -8)]
--				end
--				if not sd and template.baseSpecies then
--					sd = gifData[template.baseSpecies]
--				end
--			end
--			template.spriteData = sd
			
	--		if not template.gender then template.gender = '' end
	--		if not template.genderRatio and template.gender == 'M' then template.genderRatio = {M:1, F:0} end
	--		if not template.genderRatio and template.gender == 'F' then template.genderRatio = {M:0, F:1} end
	--		if not template.genderRatio and template.gender == 'N' then template.genderRatio = {M:0, F:0} end
	--		if not template.genderRatio then template.genderRatio = {M:0.5, F:0.5} end
	--		if not template.tier and template.baseSpecies ~= template.species then template.tier = self.data.FormatsData[toId(template.baseSpecies)].tier end
	--		if not template.tier then template.tier = 'Illegal' end
			if not template.gen then
				if template.forme and ({['Mega']=true,['Mega-X']=true,['Mega-Y']=true})[template.forme] then
					template.gen = 6
					template.isMega = true
				elseif template.forme == 'Primal' then
					template.gen = 6
					template.isPrimal = true
				elseif template.forme == 'Origin' then
					template.gen = 6
					template.isOrigin = true
				elseif not template.num then
--					warn('template "'..template.id..'" has no num')
				elseif template.num >= 650 then template.gen = 6
				elseif template.num >= 494 then template.gen = 5
				elseif template.num >= 387 then template.gen = 4
				elseif template.num >= 252 then template.gen = 3
				elseif template.num >= 152 then template.gen = 2
				elseif template.num >= 1   then template.gen = 1
				else                            template.gen = 0 end
			end
			cachedTemplates[id] = template
		end
		return template
	end
	
	function Battle:getMove(move)
		if not move or type(move) == 'string' then
			local name = move or ''
			local id = toId(name)
			self:setupDataForTransferToPlayers('Move', id)
			move = {}
			if id:sub(1, 11) == 'hiddenpower' then
				id = 'hiddenpower'
			end
			if id and self.data.Movedex[id] then
				move = self.data.Movedex[id]
				if move.cached then return move end
				move.cached = true
				move.exists = true
			end
			if not move.id then move.id = id end
			if not move.name then move.name = name end
			if not move.fullname then move.fullname = 'move: ' .. move.name end
			if not move.critRatio then move.critRatio = 1 end
			if not move.baseType then move.baseType = move.type end
			if not move.effectType then move.effectType = 'Move' end
			if not move.secondaries and move.secondary then move.secondaries = {move.secondary} end
			if not move.gen and move.num then
				if     move.num >= 560 then move.gen = 6
				elseif move.num >= 468 then move.gen = 5
				elseif move.num >= 355 then move.gen = 4
				elseif move.num >= 252 then move.gen = 3
				elseif move.num >= 166 then move.gen = 2
				elseif move.num >= 1   then move.gen = 1
				else                        move.gen = 0 end
			end
			if not move.priority then move.priority = 0 end
			if move.ignoreImmunity == nil then move.ignoreImmunity = (move.category == 'Status') end
			if not move.flags then move.flags = {} end
			setupConcatenator(move, 'move')
		end
		return move
	end
	
	function Battle:getMoveCopy(move)
		if move and move.isCopy then return move end
		move = self:getMove(move)
		local moveCopy = deepcopy(move)
		moveCopy.isCopy = true
		return moveCopy
	end
	
	function Battle:getEffect(effect)
		if not effect or type(effect) == 'string' then
			local name = effect or ''
			local id = toId(name)
			self:setupDataForTransferToPlayers('Effect', id)
			effect = {}
			if id and self.data.Statuses[id] then
				effect = self.data.Statuses[id]
				effect.name = effect.name or self.data.Statuses[id].name
			elseif id and self.data.Movedex[id] and self.data.Movedex[id].effect then
				effect = self.data.Movedex[id].effect
				effect.name = effect.name or self.data.Movedex[id].name
			elseif id and self.data.Abilities[id] and self.data.Abilities[id].effect then
				effect = self.data.Abilities[id].effect
				effect.name = effect.name or self.data.Abilities[id].name
			elseif id and self.data.Items[id] and self.data.Items[id].effect then
				effect = self.data.Items[id].effect
				effect.name = effect.name or self.data.Items[id].name
--			elseif id and self.data.Formats[id] then
--				effect = self.data.Formats[id]
--				effect.name = effect.name or self.data.Formats[id].name
--	--			if not effect.mod then effect.mod = 'base' end
--				if not effect.effectType then effect.effectType = 'Format' end
			elseif id == 'recoil' then
				effect = { effectType = 'Recoil' }
			elseif id == 'drain' then
				effect = { effectType = 'Drain' }
			end
			if not effect.id then effect.id = id end
			if not effect.name then effect.name = name end
			if not effect.fullname then effect.fullname = effect.name end
			if not effect.category then effect.category = 'Effect' end
			if not effect.effectType then effect.effectType = 'Effect' end
			setupConcatenator(effect, 'effect')
		end
		return effect
	end
	
	function Battle:getFormat(effect)
	--[[
		if !effect or type(effect) == 'string') {
			local name = effect or ''
			local id = toId(name);
			if self.data.Aliases[id]) {
				name = self.data.Aliases[id];
				id = toId(name);
			}
			effect = {};
			if id and self.data.Formats[id]) {
				effect = self.data.Formats[id];
				if effect.cached) return effect;
				effect.cached = true;
				effect.name = effect.name or self.data.Formats[id].name;
				if !effect.mod) effect.mod = 'base';
				if !effect.effectType) effect.effectType = 'Format';
			}
			if !effect.id) effect.id = id;
			if !effect.name) effect.name = name;
			if !effect.fullname) effect.fullname = effect.name;
			if !effect.category) effect.category = 'Effect';
			if !effect.effectType) effect.effectType = 'Effect';
		}
		return effect;
	]]
		return {}
	end
	
	function Battle:getItem(item)
		if not item or type(item) == 'string' then
			local name = item or ''
			local id = toId(name)
			self:setupDataForTransferToPlayers('Item', id)
			item = {}
			if id and self.data.Items[id] then
				item = self.data.Items[id]
				if item.cached then return item end
				item.cached = true
				item.exists = true
			end
			if not item.id then item.id = id end
			if not item.name then item.name = name end
			if not item.fullname then item.fullname = 'item: ' .. item.name end
			setupConcatenator(item, 'item')
			if not item.category then item.category = 'Effect' end
			if not item.effectType then item.effectType = 'Item' end
			if type(item.fling) == 'number' then item.fling = {basePower = item.fling} end
			if item.isBerry then item.fling = {basePower = 10} end
			if item.onPlate then item.fling = {basePower = 90} end
			if item.onDrive then item.fling = {basePower = 70} end
			if item.megaStone then item.fling = {basePower = 80} end
			if not item.gen and item.num then
				if     item.num >= 577 then item.gen = 6
				elseif item.num >= 537 then item.gen = 5
				elseif item.num >= 377 then item.gen = 4
				-- Due to difference in storing items, gen 2 items must be specified manually
				else                        item.gen = 3 end
			end
		end
		return item
	end
	
	function Battle:getAbility(ability)
		if not ability or type(ability) == 'string' then
			local name = ability or ''
			local id = toId(name)
			self:setupDataForTransferToPlayers('Ability', id)
			ability = {}
			if id and self.data.Abilities[id] then
				ability = self.data.Abilities[id]
				if ability.cached then return ability end
				ability.cached = true
				ability.exists = true
			end
			if not ability.id then ability.id = id end
			if not ability.name then ability.name = name end
			if not ability.fullname then ability.fullname = 'ability: ' .. ability.name end
			setupConcatenator(ability, 'ability')
			if not ability.category then ability.category = 'Effect' end
			if not ability.effectType then ability.effectType = 'Ability' end
			if not ability.gen then
				--[[
				if     ability.num >= 165 then ability.gen = 6
				elseif ability.num >= 124 then ability.gen = 5
				elseif ability.num >= 77  then ability.gen = 4
				elseif ability.num >= 1   then ability.gen = 3
					--]]
				-- fix for trainer pokemons that dont have abilities specified in Trainers.lua
				if     ability.num and ability.num >= 165 then ability.gen = 6
				elseif ability.num and ability.num >= 124 then ability.gen = 5
				elseif ability.num and ability.num >= 77  then ability.gen = 4
				elseif ability.num and ability.num >= 1   then ability.gen = 3
				else                           ability.gen = 0 end
			end
		end
		return ability
	end
	
	local typeCache = {}
	function Battle:getType(_type)
		if not _type or type(_type) == 'string' then
			local id = toId(_type)
			id = id:sub(1, 1):upper() .. id:sub(2)
			if typeCache[_type] then return typeCache[_type] end
			typeCache[_type] = {}
			_type = typeCache[_type]
			if self.data.TypeChart[id] then
				_type.chart = self.data.TypeChart[id]
				_type.exists = true
				_type.isType = true
				_type.effectType = 'Type'
			else
				_type.effectType = 'EffectType'
			end
			_type.id = id
		end
		return _type
	end
	
	function Battle:getNature(nature)
		if not nature or type(nature) == 'string' then
			local name = nature or ''
			local id = toId(name)
			nature = {}
			if id and self.data.Natures[id] then
				nature = self.data.Natures[id]
				if nature.cached then return nature end
				nature.cached = true
				nature.exists = true
			end
			if not nature.id then nature.id = id end
			if not nature.name then nature.name = name end
			setupConcatenator(nature, 'nature')
			if not nature.effectType then nature.effectType = 'Nature' end
		end
		return nature
	end
	
	function Battle:getSprite(id) -- only called by getDataForTransferToPlayer (see :runMegaEvo in Extension)
		local folder, spriteId = id:match('^(.+)/(.+)$')
		return gifData[folder][spriteId]
	end
	
	
	function Battle:clampIntRange(num, min, max)
		if type(num) ~= 'number' then num = 0 end
		num = math.max(math.floor(num), min)
		if max then num = math.min(num, max) end
		return num
	end
	
	
	
	function Battle:getExpYield(template)
		if template.template then
			template = template.template
		end
		if not template.baseExp then
			local s = pcall(function()
				template = self.data.Pokedex[toId(template.baseSpecies)]
			end)
			if not s or not template then
				return 0, {}
			end
		end
		return template.baseExp, template.evYield
	end
	
	-- Apparently when this data is looked up, it uses P1's for both players (since updates are sent at the same time)
	function Battle:setupDataForTransferToPlayers(kind, id)
		if not id or id == '' then return end
		local key = kind..'|'..id
		if self.queriedData[key] then return end
		self.queriedData[key] = true
		self.transferDataToP1[key] = true
		self.transferDataToP2[key] = true
	end
	
	function Battle:getDataForTransferToPlayer(sideId, isForRequest)
		local d = {}
		local pcd = self.previousCachedData -- for spectators joining late
		if not pcd then
			pcd = {}
			self.previousCachedData = pcd
		end
		local t = 'transferDataTo'..sideId:upper()
		for key in pairs(self[t]) do
			local kind, id = unpack(split(key, '|'))
			local data = {kind, id, self['get'..kind](self, id)}
			table.insert(d, data)
			table.insert(pcd, data)
			if isForRequest then
				table.insert(self.transferDataToSpec, data)
			end
		end
--		if sideId:lower() == 'p1' and self.arq_send then
--			table.insert(d, {'arq', self.arq_send})
--			self.arq_send = nil
--		end
		if #d == 0 then return nil end
		self[t] = {}
		return d
	end
	
	function Battle:addDataForTransferToSpectator(dataToTransferToPlayer)
		dataToTransferToPlayer = dataToTransferToPlayer or {}
		for _, data in pairs(self.transferDataToSpec) do
			table.insert(dataToTransferToPlayer, data)
		end
		self.transferDataToSpec = {}
		return dataToTransferToPlayer
	end
	
	
	
	
--	do
--		local rc4 = require(game:GetService('ServerStorage').Utilities).rc4
		function Battle:getNPCPartnerTeam(teamId)
			local starterType
			local t, s = teamId:match('^([^_]*)_([^_]*)$')
			if t then
				teamId = t
				starterType = s
			end
			if teamId == 'jakeChunk11' then
				local main = ({
					Grass = {id = 'flareon',  types = {'Fire'},     moves = {{id='firefang'},   {id='bite'},      {id='quickattack'},{id='sandattack'}}},
					Fire  = {id = 'vaporeon', types = {'Water'},    moves = {{id='aurorabeam'}, {id='waterpulse'},{id='quickattack'},{id='sandattack'}}},
					Water = {id = 'jolteon',  types = {'Electric'}, moves = {{id='thunderfang'},{id='doublekick'},{id='quickattack'},{id='sandattack'}}},
				})['Fire']--[starterType or 'Fire'] -- well I screwed that up, so we'll just let Jake always have Vaporeon
				return {
					{ -- Jolteon / Flareon / Vaporeon
						id = main.id,
						level = 24,
						gender = 'M',
						ability = 1,
						types = main.types,
						moves = main.moves,
						ivs = {20, 20, 20, 20, 20, 20},
						nature = 'Hardy',
					},
					{ -- Nidorino
						id = 'nidorino',
						level = 21,
						gender = 'M',
						ability = 2,
						types = {'Poison'},
						moves = {{id='furyattack'},{id='poisonsting'},{id='doublekick'},{id='peck'}},
						ivs = {20, 20, 20, 20, 20, 20},
						nature = 'Hardy',
					},
					{ -- Blitzle
						id = 'blitzle',
						level = 20,
						gender = 'M',
						ability = 2,
						types = {'Electric'},
						moves = {{id='flamecharge'},{id='thunderwave'},{id='shockwave'},{id='tailwhip'}},
						ivs = {20, 20, 20, 20, 20, 20},
						nature = 'Hardy',
					}
				}, 'Jake'
			elseif teamId == 'tessChunk23' then
				return {
					{ -- Gabite
						id = 'gabite',
						level = 41,
						gender = 'F',
						ability = 1,
						types = {'Dragon','Ground'},
						moves = {{id='dig'},{id='dragonclaw'},{id='shadowclaw'},{id='rockslide'}},
						ivs = {20, 20, 20, 20, 20, 20},
						nature = 'Docile',
					},
					{ -- Shelgon
						id = 'shelgon',
						level = 40,
						gender = 'F',
						ability = 1,
						types = {'Dragon'},
						moves = {{id='zenheadbutt'},{id='dragonclaw'},{id='crunch'},{id='rockslide'}},
						ivs = {20, 20, 20, 20, 20, 20},
						nature = 'Impish',
					},
					{ -- Fraxure
						id = 'fraxure',
						level = 41,
						gender = 'M',
						ability = 2,
						types = {'Dragon'},
						moves = {{id='dragondance'},{id='dragonclaw'},{id='poisonjab'},{id='xscissor'}},
						ivs = {20, 20, 20, 20, 20, 20},
						nature = 'Calm',
					}
				}, 'Tess'
			end
		end
--	end
end