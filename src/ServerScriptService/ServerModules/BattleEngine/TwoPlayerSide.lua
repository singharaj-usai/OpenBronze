print("TwoPlayerSide")
local _f = require(script.Parent.Parent)

local undefined, null, subclass, split, trim, indexOf, Not, deepcopy, toId, shallowcopy; do
	local util = require(game:GetService('ServerStorage'):WaitForChild('src').BattleUtilities)
	undefined = util.undefined
	null = util.null
	subclass = util.subclass
	split = util.split
	trim = util.trim
	indexOf = util.indexOf
	Not = util.Not
	deepcopy = util.deepcopy
	toId = util.toId
	shallowcopy = util.shallowcopy
end

local BattlePokemon = require(script.Parent.BattlePokemon)


-- 2v2do: mega evolution for both trainers


local TwoPlayerSide = subclass(require(script.Parent.BattleSide), {
	className = 'TwoPlayerSide',

	isTwoPlayerSide = true,
	isSecondPlayerNpc = false,
}, function(self, player1, player2, battle, n, team1, team2)
	assert(battle.gameType == 'doubles', 'Battle must be of type Double to implement TwoPlayerSide')

	self.battle = battle
	self.n = n
	self.names = {player1.Name, player2.Name}
	self.name = player1.Name .. ' and ' .. player2.Name
	self.pokemon = {}
	self.active = {null, null}
	self.sideConditions = {}
	--self.zmoveAdornment = {}
	self.dynaAdornment = {}
	self.megaAdornment = {}
	pcall(function()
		local bd = _f.PlayerDataService[player1]:getBagDataById('megakeystone', 5)
		if bd and bd.quantity > 0 then
			self.megaAdornment[1] = 'true'
		end
		--[[
		local zr = _f.PlayerDataService[player1]:getBagDataById('zring', 5)
		if zr and zr.quantity > 0 then
			self.zmoveAdornment[1] = 'true' -- todo: allow different adornments
		end
		local dr = _f.PlayerDataService[player1]:getBagDataById('zpowerring', 5)
		if dr and dr.quantity > 0 then
			self.dynaAdornment[1] = 'true' -- todo: allow different adornments
		end
		--]]
	end)
	pcall(function()
		local bd = _f.PlayerDataService[player2]:getBagDataById('megakeystone', 5)
		if bd and bd.quantity > 0 then
			self.megaAdornment[2] = 'true'
		end
		--[[
		local zr = _f.PlayerDataService[player2]:getBagDataById('zring', 5)
		if zr and zr.quantity > 0 then
			self.zmoveAdornment[2] = 'true' -- todo: allow different adornments
		end
		local dr = _f.PlayerDataService[player1]:getBagDataById('zpowerring', 5)
		if dr and dr.quantity > 0 then
			self.dynaAdornment[1] = 'true' -- todo: allow different adornments
		end
		--]]
	end)

	self.id = 'p'..n

	--	self.teams = {team1, team2}
	local pl = 0
	for i = 1, math.min(#team1, 6) do
		local p = BattlePokemon:new(nil, team1[i], self)
		p.teamn = 1
		p.canMegaEvo = battle:canMegaEvo(p)
	--	p.canZMove = battle:canZMove(p)
	--	p.canMaxMove = battle:canMaxMove(p)

		if battle.is2v2 or not p.index then
			p.index = i
		end
		table.insert(self.pokemon, p)
		p.fainted = p.hp == 0
		if p.hp > 0 then
			pl = pl + 1
		end
	end
	self.nPokemonFromTeam1 = #team1
	local index = #team1
	for i = 1, math.min(#team2, 6) do
		local p = BattlePokemon:new(nil, team2[i], self)
		p.teamn = 2
		p.canMegaEvo = battle:canMegaEvo(p)
		--p.canZMove = battle:canZMove(p)
		--p.canMaxMove = battle:canMaxMove(p)
		--		if not p.index then
		index = index + 1
		p.index = index
		--		end
		table.insert(self.pokemon, p)
		p.fainted = p.hp == 0
		if p.hp > 0 then
			pl = pl + 1
		end
	end
	self.pokemonLeft = pl--#self.pokemon
	for i = 1, #self.pokemon do
		self.pokemon[i].position = i
	end

	return self
end)

function TwoPlayerSide:toString()
	return self.id .. ': ' .. self.names[1] .. ' & ' .. self.names[2]
end
function TwoPlayerSide:start()
	local function sendOutForTeamN(teamn)
		for i, p in pairs(self.pokemon) do
			if p.hp > 0 and p.teamn == teamn then
				self.battle:switchIn(p, teamn)
				if teamn == 2 then
					local i = p.index
					table.remove(self.pokemon, i)
					table.insert(self.pokemon, 2, p)
				end
				return
			end
		end
	end
	for i = 1, 2 do sendOutForTeamN(i) end
	for i, p in pairs(self.pokemon) do
		p.position = i
	end
end
function TwoPlayerSide:getData(context)
	local data = {
		--		name = self.name,
		id = self.id,
		nActive = 2,
		nTeamActive = 1,
		nTeam1 = self.nPokemonFromTeam1
		--		pokemon = {}
	}
	local indexFix = {}
	local h
	if context == 'switch' then
		h = {}
		data.healthy = h
	end
	for i, pokemon in pairs(self.pokemon) do
		--		if self.battle.is2v2 and pokemon.teamn == 2 then
		--			indexFix[pokemon.index] = i -- - self.nPokemonFromTeam1
		--		else
		indexFix[pokemon.index] = i
		--		end

		if h then h[i] = not pokemon.egg and pokemon.hp > 0 end
--[[		local pp = {}
		for i, m in pairs(pokemon.moveset) do
			pp[i] = m.pp
		end
		table.insert(data.pokemon, {
			ident = pokemon.fullname,
			level = pokemon.level,
			status = pokemon.status,
			hp = pokemon.hp,
			maxhp = pokemon.maxhp,
			active = (pokemon.position <= #self.active),
			moves = pokemon.moves,
			pp = pp,
			item = pokemon.item,
			pokeball = pokemon.pokeball,
			canMegaEvo = pokemon.canMegaEvo and true or false,
			index = pokemon.index,
			isEgg = pokemon.isEgg,
			teamn = pokemon.teamn,
		})]]
	end
	data.indexFix = indexFix
	return data
end
function TwoPlayerSide:getRelevantDataChanges()
	local blackout = false
	if self.isSecondPlayerNpc then
		blackout = true
		for _, p in pairs(self.pokemon) do
			if p.hp > 0 and p.teamn == 1 then
				blackout = false
				break
			end
		end
	end
	return {blackout = blackout}
end
function TwoPlayerSide:canSwitch(position)
	if position then
		for _, pokemon in pairs(self.pokemon) do
			if not pokemon.isActive and not pokemon.fainted and pokemon.teamn == position then
				return true
			end
		end
	else
		for pos, a in pairs(self.active) do
			if a ~= null and a.switchFlag then
				for _, pokemon in pairs(self.pokemon) do
					if not pokemon.isActive and not pokemon.fainted and pokemon.teamn == pos then
						return true
					end
				end
			end
		end
	end
	return false
end
-- inherited
--randomActive
--addSideCondition
--getSideCondition
--removeSideCondition

-- not sure whether these need to be custom
--send
--emitCallback

-- todo (?)
--AIChooseMove
--[[
function TwoPlayerSide:AIChooseMove(request)
    if request.requestType ~= 'move' then
        self.battle:debug('non-move request sent to AI foe side')
        return
    end
    
    -- Handle moves for both active Pokemon (team1 and team2)
    local choices = {}
    for n, a in pairs(request.active) do
        -- Only process AI moves for the NPC partner (teamn == 2)
        if self.active[n] and self.active[n].teamn == 2 then
            -- Get valid moves
            local enabledMoves = {}
            for i, m in pairs(a.moves) do
                if not m.disabled and (not m.pp or m.pp > 0) then
                    table.insert(enabledMoves, i)
                end
            end
            
            -- Always Mega-evolve if available
            local mega = ''
            if a.canMegaEvo then
                mega = ' mega'
            end
            
            -- Choose random move for NPC
            local move = enabledMoves[math.random(#enabledMoves)]
            choices[n] = 'move ' .. move .. mega
        end
    end
    
    if #choices > 0 then
        self.battle:choose(nil, self.id, choices, self.battle.rqid)
    end
end
--]]
--AIForceSwitch
--[[
function TwoPlayerSide:AIForceSwitch(request)
    local alreadySwitched = {}
    local choices = {}
    
    -- Helper function to get valid Pokemon index for switching
    local function getValidPokemonIndex(teamn)
        for i, p in pairs(self.pokemon) do
            if not alreadySwitched[i] and not p.isActive and p.hp > 0 and p.teamn == teamn then
                return i
            end
        end
    end
    
    -- Process force switch only for NPC partner (team 2)
    local fs = request.forceSwitch
    for i = 1, #fs do
        if fs[i] then
            local activePos = i
            local activeMon = self.active[activePos]
            
            if activeMon and activeMon.teamn == 2 then
                local s = getValidPokemonIndex(2)  -- Only get Pokemon from team 2
                if s then
                    choices[i] = 'switch ' .. s
                    alreadySwitched[s] = true
                else
                    choices[i] = 'pass'
                end
            end
        else
            choices[i] = 'pass'
        end
    end
    
    if #choices > 0 then
        self.battle:choose(nil, self.id, choices, self.battle.rqid)
    end
end
--]]
function TwoPlayerSide:emitRequest(request)
	local sendToTeam1, sendToTeam2 = true, true
	if request.forceSwitch or request.foeAboutToSendOut then
		request.requestType = 'switch'
		if (self.active[1] ~= null and not self.active[1].fainted and not self.active[1].switchFlag) or not self:canSwitch(1) then
			sendToTeam1 = false
		end
		if (self.active[2] ~= null and not self.active[2].fainted and not self.active[2].switchFlag) or not self:canSwitch(2) then
			sendToTeam2 = false
		end
	elseif request.teamPreview then
		request.requestType = 'team'
	elseif request.wait then
		request.requestType = 'wait'
	elseif request.active then
		request.requestType = 'move'
	end
	if (self.name == '#Wild' or self.battle.isTrainer) and self.n == 2 then
		if request.requestType == 'move' then
			self:AIChooseMove(request)
		elseif request.requestType == 'switch' then
			self:AIForceSwitch(request)
		else
			--			print('battle ai received request of type:', request.requestType)
		end
		return
	end
	local d = self.battle:getDataForTransferToPlayer(self.id, true)
	if d and #d > 0 then
		request.qData = d
	end
	if sendToTeam1 then
		--		print('sending request of type', request.requestType, 'to player 1 of side', self.n, self.battle.listeningPlayers[self.id])
		self.battle:sendToPlayer(self.id, 'request', self.id, self.battle.rqid, request)
	else
		--		print('sending request of type switch[WAIT] to player 1 of side', self.n, self.battle.listeningPlayers[self.id])
		local r = shallowcopy(request)
		r.requestType = 'wait'
		self.battle:sendToPlayer(self.id, 'request', self.id, self.battle.rqid, r)
	end
	if sendToTeam2 then
		--		print('sending request of type', request.requestType, 'to player 2 of side', self.n, self.battle.listeningPlayers['p'..(self.n+2)])
		self.battle:sendToPlayer('p'..(self.n+2), 'request', self.id, self.battle.rqid, request)
	else
		--		print('sending request of type switch[WAIT] to player 2 of side', self.n, self.battle.listeningPlayers['p'..(self.n+2)])
		local r = shallowcopy(request)
		r.requestType = 'wait'
		self.battle:sendToPlayer('p'..(self.n+2), 'request', self.id, self.battle.rqid, r)
	end
end


function TwoPlayerSide:remove()
	-- deallocate ourself

	-- deallocate children and get rid of references to them
	for i = 1, #self.pokemon do
		if self.pokemon[i] then self.pokemon[i]:remove() end
		self.pokemon[i] = nil
	end
	self.pokemon = nil
	for i = 1, #self.active do
		self.active[i] = nil
	end
	self.active = nil

	if self.decision and self.decision ~= true then
		self.decision.side = nil
		self.decision.pokemon = nil
	end
	self.decision = nil

	-- get rid of some possibly-circular references
	self.battle = nil
	self.foe = nil
end


return TwoPlayerSide