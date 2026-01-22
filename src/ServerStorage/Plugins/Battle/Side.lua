return function(_p)
local class, null, indexOf; do
	local util = require(script.Parent.BattleUtilities)
	class = util.class
	null = util.null
	indexOf = util.indexOf
end

local Tools = require(script.Parent.Tools)
local Pokemon = require(script.Parent.Pokemon)--(_p)
local Sprite = require(script.Parent.Sprite)(_p)

local function extend(obj, ...)
	for _, otherObj in pairs({...}) do
		for property, value in pairs(otherObj) do
			obj[property] = value
		end
	end
	return obj
end


local Side = class({
	className = 'BattleClientSide',
	
	name = '',
	id = '',
	initialized = false,
	totalPokemon = 6,
	_SpriteClass = Sprite,
	
}, function(self, battle, n)
	self.battle = battle
	self.n = n
	
--	self.foe = null
--	self.spriteid = 262
	
--	self.missedPokemon = {
--		sprite = Sprite:new(nil, nil, self.leftof(-100), self.y, self.z, self.battle, self.n)
--	}
	
	self.sideConditions = {}
--	self.wisher = null
	
	self.active = {null}
	if battle.gameType == 'doubles' then
		self.active = {null, null}
	elseif battle.gameType == 'triples' or battle.gameType == 'rotation' then
		self.active = {null, null, null}
	end
--	self.lastPokemon = null
	self.pokemon = {}
	
	return self
end)

function Side:newPokemon(species, replaceSlot)
	local id
	local pokeobj
	if species.species then
		pokeobj = species
		species = pokeobj.species
		id = pokeobj.id
	end
	local poke = Tools.getTemplate(species)
	poke = extend(Pokemon:new(nil, species, self), poke)
	poke.atkStat = 10
	poke.defStat = 10
	poke.spaStat = 10
	poke.spdStat = 10
	poke.hp = 10
	poke.maxhp = 10
	if pokeobj then poke = extend(poke, pokeobj) end
	if poke.ability == '' and poke.baseAbility ~= '' then poke.ability = poke.baseAbility end
	poke.id = id
	poke:reset()
	poke.sprite = Sprite:new(nil, poke, self.battle, self.n)
	
	if replaceSlot ~= nil then
		self.pokemon[replaceSlot] = poke
	else
		table.insert(self.pokemon, poke)
	end
--	if #self.pokemon >= 7 then
--		-- something's wrong
--		self.battle:debug('corruption: assuming Illusion')
--		
--		-- the other possibility is Illusion, which we'll assume
--		local existingTable = {}
--		for i = 1, 6 do
--			local poke1 = self.pokemon[i]
--			if existingTable[poke1.searchid] then
--				local j = existingTable[poke1.searchid]
--				local poke2 = self.pokemon[j]
--				if indexOf(self.active, poke1) then
--					table.remove(self.pokemon, j)
--				elseif indexOf(self.active, poke2) then
--					table.remove(self.pokemon, i)
--				elseif poke1.fainted and not poke2.fainted then
--					table.remove(self.pokemon, j)
--				else
--					table.remove(self.pokemon, i)
--				end
--				break
--			end
--			existingTable[poke1.searchid] = i
--		end
--	end
	self:updateSidebar()
	
	return poke
end
function Side:setName(name)
	self.name = name
end

function Side:getTeamName()
	if self == self.battle.mySide then return 'Your team' end
	return 'The opposing team'
end
function Side:getLowerTeamName()
	if self == self.battle.mySide then return 'your team' end
	return 'the opposing team'
end

function Side:getNameForSlot(slot)
	if self.battle.kind == '2v2' then
		return self['name'..(slot or '')]
	end
	return self.name
end
function Side:getCombinedName()
	if self.battle.kind == '2v2' then -- todo: NPC 2v2s/2v1s?
		return self.name1..' and '..self.name2
	end
	return self.name
end

function Side:reset() end
function Side:updateSprites() end

function Side:addSideCondition() end
function Side:removeSideCondition() end

function Side:switchOut(pokemon, slot)
	if slot == nil then slot = pokemon.slot end
	if pokemon.lastmove ~= 'batonpass' then
		pokemon:clearVolatile()
	else
		pokemon:removeVolatile('transform')
		pokemon:removeVolatile('formechange')
	end
	if pokemon.lastmove == 'uturn' or pokemon.lastmove == 'voltswitch' then
		self.battle:message(pokemon:getName() .. ' went back to ' .. pokemon.side:getNameForSlot(slot) .. '!')
	elseif pokemon.lastmove ~= 'batonpass' then
		if pokemon.side.n == 1 then
			self.battle:message(pokemon:getName() .. ', come back!')
		else
			self.battle:message(pokemon.side:getNameForSlot(slot) .. ' withdrew ' .. pokemon:getShortName() .. '!')
		end
	end
	self.lastPokemon = pokemon
	self.active[slot] = null
	
	self:updateStatbar(pokemon, true)
	pokemon.sprite:animUnsummon()
	if self.battle.fastForward then
		pokemon.statbar:remove()
		pokemon.statbarElem = nil
		return
	end
	if pokemon.statbar then
		pokemon.statbar:slideOffscreen(true) -- remove when done
		pokemon.statbar = nil
	end
end
function Side:switchIn(pokemon, slot, silent, isSecondary)
	if slot == nil then slot = pokemon.slot end
	self.active[slot] = pokemon
	pokemon.slot = slot
	pokemon:clearVolatile()
	pokemon.lastmove = ''
	self.battle.lastmove = 'switch-in'
	if self.lastPokemon and self.lastPokemon.lastmove == 'batonpass' then
		pokemon:copyVolatileFrom(self.lastPokemon)
	end
	
	local msgFn
	if not silent then
		if pokemon.side.n == 1 then
			if self.battle.skipGoFlag then
				self.battle.skipGoFlag = nil
			else
				msgFn = --[[spawn(]]function() self.battle:message('Go! ' .. pokemon:getShortName() .. '!') end--)
			end
		elseif self.battle.kind == 'wild' then
	--		self.battle:message('A wild ' .. pokemon.species .. ' appeared!')
		else
			msgFn = --[[spawn(]]function() self.battle:message(pokemon.side:getNameForSlot(slot) .. ' sent out ' .. pokemon:getShortName() .. '!') end--)
		end
	end
	
	pokemon.sprite:animSummon(slot, msgFn, isSecondary)
	if pokemon:hasVolatile('substitute') then
		pokemon.sprite:animSub()
	end
	if pokemon.statbar then
		pokemon.statbar:remove()
	end
	local statbar = self.battle:getStatbar(pokemon) --
	pokemon.statbar = statbar
	--	self:updateStatbar(pokemon, true) --
	statbar:update()
	pokemon.side:updateSidebar() -- self: ?
	end
	--
	
--	if self.battle.fastForward then
--		
--	end
	
--	if self.battle.switchCallback then self.battle:switchCallback(self) end
function Side:replace() end -- [was] used by Illusion ability
function Side:dragIn(pokemon, slot)
	slot = slot or pokemon.slot
	if pokemon == self.active[slot] then return end
	local oldpokemon = self.active[slot]
	self.lastPokemon = oldpokemon
	if oldpokemon and oldpokemon ~= null then oldpokemon:clearVolatile() end
	pokemon:clearVolatile()
	pokemon.lastmove = ''
	self.battle.lastmove = 'switch-in'
	self.active[slot] = pokemon
	
	if oldpokemon == pokemon then return end
	
	if oldpokemon and oldpokemon ~= null then
		oldpokemon.sprite:animDragOut()
	end
	pokemon.sprite:animDragIn(slot)
	local statbar = self.battle:getStatbar(pokemon) --
	pokemon.statbar = statbar
--	self:updateStatbar(pokemon, true) --
	statbar:update()
	self.battle:message(pokemon:getShortName() .. ' was dragged out!')--
--	if pokemon.statbarElem then
--		pokemon.statbarElem.remove()
--	end
--	self.battle.statElem.append(this.getStatbarHTML(pokemon))
--	pokemon.statbarElem = this.battle.statElem.children().last();
--	this.updateStatbar(pokemon, true);
--	pokemon.side.updateSidebar();
--	if self.battle.fastForward then
--		
--	end
end

function Side:swapTo(pokemon, slot, kwargs)
	if pokemon.slot == slot then return end
	local target = self.active[slot]
	if target==null then target = nil end
	
	local oslot = pokemon.slot
	
	if target then target.slot = pokemon.slot end
	pokemon.slot = slot
	self.active[slot] = pokemon
	self.active[oslot] = target
	
	if self.battle.fastForward then
		-- TODO: do quick swaps, then return
	end
	
	if pokemon:hasVolatile('substitute') then pokemon.sprite:animSubFade() end
	if target and target:hasVolatile('substitute') then target.sprite:animSubFade() end
	
	spawn(function() pokemon.statbar:slideOffscreen(false) end)
	if target then spawn(function() target.statbar:slideOffscreen(false) end) end
	
	if target then
		local pBasePos = pokemon.sprite.cf.p - Vector3.new(0, pokemon.sprite.spriteData.inAir or 0, 0)
		local tBasePos = target .sprite.cf.p - Vector3.new(0, target .sprite.spriteData.inAir or 0, 0)
		local h_offset = CFrame.new(pBasePos, Vector3.new(tBasePos.X, pBasePos.Y, tBasePos.Z)).rightVector*1.5
		local dif = tBasePos - pBasePos
		local p_offset = pokemon.sprite.offset
		local t_offset = target .sprite.offset
		_p.Utilities.Tween(.8, nil, function(a)
			pokemon.sprite.offset = p_offset+dif*a+h_offset*math.sin(a*math.pi)
			target .sprite.offset = t_offset-dif*a-h_offset*math.sin(a*math.pi)
		end)
		local pcf = target .sprite.cf + Vector3.new(0, (pokemon.sprite.spriteData.inAir or 0)-(target .sprite.spriteData.inAir or 0), 0)
		local tcf = pokemon.sprite.cf + Vector3.new(0, (target .sprite.spriteData.inAir or 0)-(pokemon.sprite.spriteData.inAir or 0), 0)
		pokemon.sprite.cf = pcf
		target .sprite.cf = tcf
		pokemon.sprite.offset = p_offset
		target .sprite.offset = t_offset
	else
		local posPart = self.battle.scene:FindFirstChild('pos'..self.n..slot) or self.battle.scene[self.n == 1 and '_User' or '_Foe']
		local cf = posPart.CFrame - Vector3.new(0, posPart.Size.y/2, 0) + Vector3.new(0, pokemon.sprite.spriteData.inAir or 0, 0)
		local dif = cf.p - pokemon.sprite.cf.p
		local offset = pokemon.sprite.offset
		_p.Utilities.Tween(.7, 'easeOutQuad', function(a)
			pokemon.sprite.offset = offset + dif*a
		end)
		pokemon.sprite.cf = cf
		pokemon.sprite.offset = offset
	end
	
	spawn(function() pokemon.statbar:evalYPos(true) pokemon.statbar:slideOnscreen() end)
	if target then spawn(function() target.statbar:evalYPos(true) target.statbar:slideOnscreen() end) end
	
	if not kwargs.silent then
		local fromeffect = Tools.getEffect(kwargs.from)
		if fromeffect and fromeffect.id == 'allyswitch' then
			self.battle:message(pokemon:getName() .. ' and ' .. target:getLowerName() .. ' switched places.')
		else
			self.battle:message(pokemon:getName() .. ' moved to the center!')
		end
	end
	
	if pokemon:hasVolatile('substitute') then pokemon.sprite:animSub() end
	if target and target:hasVolatile('substitute') then target.sprite:animSub() end
end
--function Side:swapWith(pokemon, target, kwargs) end
function Side:faint(pokemon, slot)
	if slot == nil then slot = pokemon.slot end
	pokemon:clearVolatile()
	self.lastPokemon = pokemon
	self.active[slot] = null
	
	spawn(function() self.battle:message(pokemon:getName() .. ' fainted!') end)
	
	pokemon.fainted = true
	pokemon.zerohp = true
	pokemon.hp = 0
	pokemon.side:updateStatbar(pokemon, false, true)
	pokemon.side:updateSidebar()
	
	wait(.6)
	pokemon.sprite:animFaint()
	-- delete sprite ?
	if self.battle.faintCallback then self.battle:faintCallback(self) end
end
function Side:updateHPText() end
function Side:updateStatbar() end
function Side:updateSidebar() end

function Side:remove()
--	print('side::remove')
	for i, p in pairs(self.pokemon) do
		if p ~= null then
			p:remove()
		end
		self.pokemon[i] = nil
	end
	for i, p in pairs(self.active) do
		if p ~= null then
			p:remove()
		end
		self.active[i] = nil
	end
	self.battle = nil
	self.foe = nil
end



return Side end