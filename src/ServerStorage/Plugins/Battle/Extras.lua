local null, Not, split, indexOf, toId, sync; do
	local util = require(script.Parent.BattleUtilities)
	null = util.null
	Not = util.Not
	split = util.split
	indexOf = util.indexOf
	toId = util.toId
	sync = util.sync
end

local Tools = require(script.Parent.Tools)
--local BattleGui = require(script.Parent.Parent.BattleGui)


return function(Battle, _p)
	function Battle:soundStop() end
	function Battle:updateWeather() end
	function Battle:checkActive() end
	function Battle:activityWait(t)
--		wait(t/1000)
	end
	function Battle:fastForwardOff()
		self.fastForward = false
	--	self.elem.find('.seeking').remove();
	--	$.fx.off = false;
		self.playbackState = 2
	end
	
	
	function Battle:parseDetails(name, pokemonid, details, output)
		if not output then output = {} end
		if not details then details = "" end
		output.details = details
--		print(name)
		output.name = name
		output.species = name
		output.level = 100 
		output.shiny = false
		output.gender = ''
		output.ident = name and pokemonid or ''
		output.searchid = name and (pokemonid .. '|' .. details) or ''
		local splitDetails = split(details, ', ')
		if splitDetails[#splitDetails] == 'shiny' then
			output.shiny = true
			table.remove(splitDetails)
		end
		local g = splitDetails[#splitDetails]
		if g == 'M' or g == 'F' then
			output.gender = g
			table.remove(splitDetails)
		end
		if splitDetails[2] then
			output.level = tonumber(splitDetails[2]:sub(2)) or 1
		end
		if splitDetails[1] then
			output.species = splitDetails[1]
		end
		return output
	end
	function Battle:parseHealth(hpstring, output)
		if not output then output = {} end
		local hp = split(hpstring, ' ')
		local status = hp[2]
		hp = hp[1]
		
		-- hp parse
		output.hpcolor = ''
		if hp == '0' or hp == '0.0' then
			output.hp = 0
			output.zerohp = true
		elseif indexOf(hp, '/') then
			local hp = split(hp, '/')
			if not tonumber(hp[1]) or not tonumber(hp[2]) then return false end
			output.hp = tonumber(hp[1])
			output.maxhp = tonumber(hp[2]) or tonumber(hp[2]:sub(1, -2))
			output.hp = math.min(output.hp, output.maxhp)
			local colorchar = hp[2]:sub(-1)
			if colorchar == 'y' or colorchar == 'g' then
				output.hpcolor = colorchar
			end
			if not output.hp then
				output.zerohp = true
			end
		elseif tonumber(hp) then
			output.hp = output.maxhp * tonumber(hp) / 100
		end
		
		-- status parse
		if not status then
			output.status = ''
		elseif status == 'par' or status == 'brn' or status == 'slp' or status == 'frz' or status == 'tox' then
			output.status = status
		elseif status == 'psn' and output.status ~= 'tox' then
			output.status = status
		elseif status == 'fnt' then
			output.hp = 0
			output.zerohp = true
			output.fainted = true
		end
		return output
	end
	function Battle:getPokemon(pokemonid, details, onSwitch)
		local siden = -1
		local name = pokemonid
		local isNew = false -- if yes, don't match any pokemon that already exists (for Team Preview)
		local isOld = false -- if yes, match only pokemon that have been revealed, and can match fainted pokemon (now default)
		local isOther = false -- if yes, don't match an active pokemon (for switching)
		--var position = 0 -- todo: use for position in doubles/triples
		local getfoe = false
		local slot -- if there is an explicit slot for this pokemon
		local slotChart = {a = 1, b = 2, c = 3, d = 4, e = 5, f = 6}
		if pokemonid == nil or name == '??' then return end-- return null end
		if name:sub(1, 5) == 'foe: ' then
			name = name:sub(6)
			pokemonid = name
			getfoe = true
		end
		if name:sub(1, 5) == 'new: ' then
			name = name:sub(6)
			pokemonid = name
			isNew = true
			isOther = true
		end
		if name:sub(1, 7) == 'other: ' then
			name = name:sub(8)
			pokemonid = name
			isOther = true
		end
		if name:sub(1, 5) == 'old: ' then
			name = name:sub(6)
			pokemonid = name
			isOld = true
		end
		local index = tonumber(pokemonid:sub(1, 1))
		if index then
			name = name:sub(2)
			pokemonid = name
		end
		local side
		if name:sub(1, 4) == 'p2: ' or name == 'p2' then
			side = self.p2
			siden = side.n
			name = name:sub(5)
		elseif name:sub(1, 4) == 'p1: ' or name == 'p1' then
			side = self.p1
			siden = side.n
			name = name:sub(5)
		elseif name:sub(1, 2) == 'p2' and name:sub(4, 5) == ': ' then
			slot = slotChart[name:sub(3, 3)]
			side = self.p2
			siden = side.n
			name = name:sub(6)
			pokemonid = 'p2: ' .. name
		elseif name:sub(1, 2) == 'p1' and name:sub(4, 5) == ': ' then
			slot = slotChart[name:sub(3, 3)]
			side = self.p1
			siden = side.n
			name = name:sub(6)
			pokemonid = 'p1: ' .. name
		end
		if side then
			for _, p in pairs(side.pokemon) do
				if p.index == index then
--					print('found', name, 'by index')
					if slot then p.slot = slot end
					if onSwitch and details then
						local d = self:parseDetails(nil, nil, details)
						local somethingChanged = false
--						print(name)
						if name and name ~= p.name then
							p.name = name
							somethingChanged = true
						end
						if d.species and d.species ~= p.species then
							p.species = d.species
							somethingChanged = true
						end
						if d.gender and d.gender ~= p.gender then
							p.gender = d.gender
							somethingChanged = true
						end
						if somethingChanged then
							pcall(function() p.sprite:updateSpriteData() end)
						end
					end
					return p
				end
			end
		end
		
		if not slot then slot = 1 end
		
		if not details then
			if siden < 0 then return end-- return null end
			if self.sides[siden].active[slot] ~= null then return self.sides[siden].active[slot] end
		end
		
		local species = name
		local gender = ''
		local level = 1
		local shiny = false
		local searchid = ''
		if details then searchid = pokemonid .. '|' .. details end
		
		for s = 2, 1, -1 do
			local side = self['p'..s]
			if siden ~= self['p'..(3-s)].n and not isNew then
				if side.active[slot] and side.active[slot] ~= null and side.active[slot].searchid == searchid and not isOther then
					side.active[slot].slot = slot
					return side.active[slot]
				end
				for i, pokemon in pairs(side.pokemon) do
					local continue = false
					if pokemon.fainted and (isNew or isOther) then
						continue = true
					end
					if not continue and isOther and (indexOf(side.active, pokemon) or (pokemon == side.lastPokemon and side.active[slot] == null)) then
						continue = true
					end
					if not continue and (pokemon.searchid == searchid or (Not(pokemon.searchid) and pokemon:checkDetails(details)) or (Not(searchid) and pokemon.ident == pokemonid)) then
						if not pokemon.searchid then
							pokemon.name = name
							pokemon.searchid = searchid
							pokemon.ident = pokemonid
							if pokemon.needsReplace then
								pokemon = side:newPokemon(self:parseDetails(name, pokemonid, details), i)
							end
						end
						pokemon.slot = slot
						return pokemon
					end
				end
			end
		end
		if (not isNew and not isOther and not details) or isOld then return end -- return false end
		if siden < 0 then siden = self.p1.n end
		if details then
			local splitDetails = split(details, ', ')
			if splitDetails[#splitDetails] == 'shiny' then
				shiny = true
				table.remove(splitDetails)
			end
			local g = splitDetails[#splitDetails]
			if g == 'M' or g == 'F' then
				gender = g
				table.remove(splitDetails)
			end
			if splitDetails[2] then
				level = tonumber(splitDetails[2]:sub(2)) or 1
			end
			if splitDetails[1] then
				species = splitDetails[1]
			end
		end
		local pokemon = self.sides[siden]:newPokemon({
			species = species,
			details = details,
			name = --[[(self.kind == 'pvp' and siden == 2) and species or]] name,
			ident = (name and pokemonid or ''),
			searchid = (name and (pokemonid .. '|' .. details) or ''),
			level = level,
			gender = gender,
			shiny = shiny,
			slot = slot,
			index = index,
		})
		return pokemon
	end
	function Battle:getSide(sidename)
		if sidename == 'p1' or sidename:sub(1, 3) == 'p1:' then return self.p1 end
		if sidename == 'p2' or sidename:sub(1, 3) == 'p2:' then return self.p2 end
		if self.mySide.id == sidename then return self.mySide end
		if self.yourSide.id == sidename then return self.yourSide end
		if self.mySide.name == sidename then return self.mySide end
		if self.yourSide.name == sidename then return self.yourSide end
		return {
			name = sidename,
			id = string.gsub(sidename, ' ', '')
		}
	end
	
	
	function Battle:removePseudoWeather(weather)
		for i, pw in pairs(self.pseudoWeather) do
			if pw[1] == weather then
				table.remove(self.pseudoWeather, i)
				self:updateWeather()
				return
			end
		end
	end
	function Battle:addPseudoWeather(weather, poke)
		table.insert(self.pseudoWeather, {weather, 5})
		self:updateWeather()
	end
	function Battle:hasPseudoWeather(weather)
		for _, pw in pairs(self.pseudoWeather) do
			if pw[1] == weather then
				return true
			end
		end
		return false
	end
	function Battle:updatePseudoWeatherLeft()
		for _, ps in pairs(self.pseudoWeather) do
			if ps[2] > 0 then
				ps[2] = ps[2] - 1
			end
		end
		for _, side in pairs(self.sides) do
			for _, sc in pairs(self.sideConditions) do
				if sc[4] and sc[4] > 0 then
					sc[4] = sc[4] - 1
				end
				if sc[5] and sc[5] > 0 then
					sc[5] = sc[5] - 1
				end
			end
		end
		self:updateWeather()
	end
	function Battle:pseudoWeatherLeft(pWeather)
		local buf = Tools.getMove(pWeather[1]).name --
		if pWeather[2] then
			return buf .. ' (' .. pWeather[2] .. ' turn' .. (pWeather[2] == 1 and '' or 's') .. ')'
		end
		return buf -- weather not found
	end
	function Battle:endPrevAction()
		if #self.minorQueue > 0 then
			self:runMinor()
--			self.activityStep = self.activityStep - 1
			return true
		end
		if self.resultWaiting or self.messageActive then
			self:endAction()
--			self.activityStep = self.activityStep - 1
			self.resultWaiting = false
			self.multiHitMove = nil
			return true
		end
		return false
	end
	function Battle:endAction()
		if self.messageActive then
			self.messageActive = false
--			if (!this.fastForward) {
--				this.messagebarElem.delay(this.messageDelay).animate({
--					height: 'toggle',
--					opacity: 0
--				}, 300);
--				this.activityWait(this.messagebarElem);
--			}
		end
	end
	function Battle:waitForResult()
		if self:endPrevAction() then return true end
		self.resultWaiting = true
		return false
	end
	
	
	function Battle:changeWeather(weather, source, effect, isUpkeep)
		local weatherTable = {
			sunnyday = {
				name = 'Sun',
				startMessage = 'The sunlight turned harsh!',
				abilityMessage = "'s Drought intensified the sun's rays!",
				upkeepMessage = 'The sunlight is strong!',
				endMessage = "The sunlight faded."
			},
			desolateland = {
				name = "Intense Sun",
				startMessage = "The sunlight turned extremely harsh!",
				endMessage = "The harsh sunlight faded."
			},
			raindance = {
				name = 'Rain',
				startMessage = 'It started to rain!',
				abilityMessage = "'s Drizzle made it rain!",
				upkeepMessage = 'Rain continues to fall!',
				endMessage = 'The rain stopped.'
			},
			primordialsea = {
				name = "Heavy Rain",
				startMessage = "A heavy rain began to fall!",
				endMessage = "The heavy rain has lifted!"
			},
			ghostlyfog = {
				name = "Fog",
				startMessage = "A thick fog fills the field!",
				endMessage = "The fog faded!"
			},
			sandstorm = {
				name = 'Sandstorm',
				startMessage = 'A sandstorm kicked up!',
				abilityMessage = "'s Sand Stream whipped up a sandstorm!",
				upkeepMessage = 'The sandstorm is raging.',
				endMessage = 'The sandstorm subsided.'
			},
			hail = {
				name = 'Hail',
				startMessage = 'It started to hail!',
				abilityMessage = "'s Snow Warning whipped up a hailstorm!",
				upkeepMessage = 'The hail is crashing down.',
				endMessage = 'The hail stopped.'
			},
			deltastream = {
				name = 'Strong Winds',
				startMessage = 'A mysterious air current is protecting Flying-type Pokemon!',
				endMessage = 'The mysterious air current has dissipated!'
			}
		}
		if not weather or weather == 'none' then
			weather = ''
		end
		local newWeather = weatherTable[weather]
		if isUpkeep then
			sync {
				function()
					if not self.fastForward then
						_p.BattleGui:animWeather(weather)
					end
				end,
				function()
					if newWeather and newWeather.upkeepMessage then
						self:message(newWeather.upkeepMessage)
					end
				end,
			}
			return
		end
		if newWeather then
			local function animate() if not self.fastForward then _p.BattleGui:animWeather(weather) end end
			if source and effect and effect.effectType == 'Ability' then
				pcall(function() self:showAbility(source, effect.name) end) --wait(1)
				sync { animate, function() self:message(source:getName() .. newWeather.abilityMessage) end }
			else
				sync { animate, function() self:message(newWeather.startMessage) end }
			end
		elseif self.weather and self.weather ~= '' then
			self:message(weatherTable[self.weather].endMessage)
		end
		self:updateWeather(weather)
	end
	function Battle:prematureEnd()
		self:debug('This replay ends here.')
		self.done = true
	end
	function Battle:endLastTurn()
		if self.endLastTurnPending then
			self.endLastTurnPending = false
			self.mySide:updateStatbar(nil, true)
			self.yourSide:updateStatbar(nil, true)
		end
	end
	function Battle:setTurn(turnnum)
		turnnum = tonumber(turnnum)
		if turnnum == self.turn + 1 then
			self.endLastTurnPending = true
		end
		self.turn = turnnum
		self:updatePseudoWeatherLeft()
		
		for _, p in pairs(self.mySide.active) do
			if p ~= null then
				p:clearTurnstatuses()
			end
		end
		for _, p in pairs(self.yourSide.active) do
			if p ~= null then
				p:clearTurnstatuses()
			end
		end
		self:activityWait(500)
		if self.turnCallback then self:turnCallback() end
	end
	function Battle:start()
	--	this.log('<div>Battle between ' + Tools.escapeHTML(this.p1.name) + ' and ' + Tools.escapeHTML(this.p2.name) + ' started!</div>');
		if self.startCallback then self:startCallback() end
	end
	function Battle:reset(dontResetSound)
		-- battle state
		self.turn = 0
		self.done = false
		self.weather = ''
		self.weatherTimeLeft = 0
		self.weatherMinTimeLeft = 0
		self.pseudoWeather = {}
		self.lastMove = ''
		
		if self.mySide then self.mySide:reset() end
		if self.yourSide then self.yourSide:reset() end
		
		-- activity queue state
		self.animationDelay = 0
		self.multiHitMove = nil
		self.activityStep = 0
		self.activityDelay = 0
		self.activityAfter = nil
	--	self.activityAnimations = $();
		self.activityQueueActive = false
--		self:fastForwardOff()
	--	$.fx.off = false;
		self.minorQueue = {}
		self.resultWaiting = false
		self.paused = true
		if self.playbackState ~= 5 then
			self.playbackState = #self.activityQueue>0 and 1 or 0
			if not dontResetSound then self:soundStop() end
		end
	end
	function Battle:switchSides()
		-- `mySide` is always the local player, and will always have .n == 1 and will be stored in sides[1] 
		-- the thing that becomes inconsistent (granted, only in PVP when not the pseudo-host) is that battle.p1 may be the opponent
		self.sidesSwitched = not self.sidesSwitched
		if self.sidesSwitched then
			self.mySide = self.p2
			self.yourSide = self.p1
		else
			self.mySide = self.p1
			self.yourSide = self.p2
		end
		self.mySide.n = 1
		self.yourSide.n = 2
		self.sides[1] = self.mySide
		self.sides[2] = self.yourSide
		
--		self.mySide:updateSidebar()
--		self.mySide:updateSprites()
--		self.yourSide:updateSidebar()
--		self.yourSide:updateSprites()
		-- nothing else should need updating - don't call this function after sending out pokemon
	end
end