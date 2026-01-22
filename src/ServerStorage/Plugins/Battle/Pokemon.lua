local class; do
	local util = require(script.Parent.BattleUtilities)
	class = util.class
end

--local player = game:GetService('Players').LocalPlayer

local Pokemon = class({
	className = 'BattleClientPokemon',
	
	atk = 0,
	def = 0,
	spa = 0,
	spd = 0,
	spe = 0,
	
	atkStat = 0,
	defStat = 0,
	spaStat = 0,
	spdStat = 0,
	speStat = 0,
	
	hp = 0,
	maxhp = 0,
	ability = '',
	baseAbility = '',
	item = '',
	fainted = false,
	zerohp = false,
	
	status = '',
	statusStage = 0,
	lastmove = '',
	
	name = '',
	species = '',
	id = '',
	
}, function(self, species, side)
--	print('pokemon::new')
	
	self.species = species
	self.side = side
	
	self.boosts = {}
	self.moves = {}
	self.volatiles = {}
	self.turnstatuses = {}
	self.movestatuses = {}
	self.moveTrack = {}
	
	--if (side.n==1 and side.battle.ignoreSelf) or (side.n==2 and side.battle.ignoreOpponent) then
	--	spawn(function() self:getFilteredNickname() end)
--	end
	
--	self.statbar = nil
	
	return self
end)


function Pokemon:getIcon()
	if self.iconOverride then
		return (self.side.battle:getPokemonIcon(self.iconOverride-1, self.shiny))
	elseif self.nonBattleObject then
		return (self.nonBattleObject:getIcon())
	elseif self.icon then
		return (self.side.battle:getPokemonIcon(self.icon-1, self.shiny))
	end
end

function Pokemon:removeVolatile() end
function Pokemon:addVolatile() end
function Pokemon:hasVolatile() end

function Pokemon:removeTurnstatus() end
function Pokemon:addTurnstatus() end
function Pokemon:hasTurnstatus() end
function Pokemon:clearTurnstatuses() end

function Pokemon:removeMovestatus() end
function Pokemon:addMovestatus() end
function Pokemon:hasMovestatus() end
function Pokemon:clearMovestatuses() end
function Pokemon:clearVolatiles() end


function Pokemon:markMove() end

--local CHAT = game:GetService('Chat')
function Pokemon:getFilteredNickname()
	-- for now we are going to return species >_>
	return self.species
--[[	if self.cfn then -- cached filtered nickname
		return self.cfn
	end
	local fn
	if self.name == self.species then
		fn = self.species
	else
--		if (pcall(function() fn = CHAT:FilterStringAsync(self.name, self.side.battle.opponent, player) end)) then
--			if fn:find('#') then
--				fn = self.species
--			end
--		else
--			fn = self.species
--		end
	end
	self.cfn = fn
	return fn--]]
end
function Pokemon:getShortName()
	return self.side.battle.ignoreNicknamesAt[self.side.n..(self.teamnForIntentsOfFilter or 1)] and self:getFilteredNickname() or self.name
end
function Pokemon:getName(shortName)
	if self.side.n == 1 then
		return self:getShortName()
	else
		local o = self.side.battle.kind == 'wild' and 'Wild ' or 'Opposing '
		return (shortName and o or 'The '..o:lower()) .. self:getShortName()
	end
end
function Pokemon:getLowerName(shortName)
	if self.side.n == 1 then
		return self:getShortName()
	else
		local o = self.side.battle.kind == 'wild' and 'wild ' or 'opposing '
		return (shortName and o or 'the '..o) .. self:getShortName()
	end
end

function Pokemon:clearVolatile() end
function Pokemon:copyVolatileFrom() end
function Pokemon:copyTypesFrom() end
function Pokemon:reset() end

function Pokemon:getHPColor()
	local ratio = self.hp / self.maxhp
	if ratio <= 0.2 then
		return Color3.new(1, 0, 0)
	elseif ratio <= 0.5 then
		return Color3.new(1, 1, 0)
	end
	return Color3.new(0, 1, 0)
end
function Pokemon:hpWidth() end
function Pokemon:hpDisplay() end

function Pokemon:healthParse(s)
	pcall(function()
		local hp, maxhp = s:match('^(%d+)/(%d+)')
		hp, maxhp = tonumber(hp), tonumber(maxhp)
		if not hp or not maxhp then return end
		self.hp, self.maxhp = hp, maxhp
	end)
	pcall(function()
		local exp = s:match(';([%d%.]+)$')
		exp = tonumber(exp)
		if not exp then return end
		self.expProg = exp
	end)
end

function Pokemon:getBoost() end

function Pokemon:checkDetails() end

function Pokemon:remove()
--	print('pokemon::remove')
	pcall(function() self.sprite:remove() end)
	self.sprite = nil
	pcall(function() self.statbar:remove() end)
	self.statbar = nil
	self.side = nil
	self.nonBattleObject = nil
end



return Pokemon