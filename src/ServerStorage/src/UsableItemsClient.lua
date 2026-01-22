return function(_p)

local usableItems = {
	gracidea = {
		nonConsumable = true,
	},
--	abilitycapsule
	['antidote'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and (pokemon.status == 'psn' or pokemon.status == 'tox')
		end
	},
	['awakening'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.status and pokemon.status:sub(1, 3) == 'slp'
		end
	},
	['burnheal'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.status == 'brn'
		end
	},
	['expshare'] = {
		canUse = true,
		noTarget = true,
		nonConsumable = true,
		onUse = function()
			local on = _p.PlayerData.expShareOn
			local chat = _p.NPCChat
			if chat:say('The Exp. Share is currently '..(on and 'on.' or 'off.'),
				'[y/n]Would you like to switch it '..(on and 'off?' or 'on?')) then
				_p.PlayerData.expShareOn = not on
				chat:say('You switched '..(on and 'off' or 'on')..' the Exp. Share.')
			else
				chat:say('The Exp. Share remained '..(on and 'on.' or 'off.'))
			end
		end
	},
	['freshwater'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.hp < pokemon.maxhp
		end
	},
	['fullheal'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and ((pokemon.status and pokemon.status ~= '') or (pokemon.volatiles and pokemon.volatiles['confusion']))
		end
	},
	['fullrestore'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and
				(pokemon.hp < pokemon.maxhp or (pokemon.status and pokemon.status ~= '') or (pokemon.volatiles and pokemon.volatiles['confusion']))
		end
	},
	['iceheal'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.status == 'frz'
		end
	},
	['paralyzeheal'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.status == 'par'
		end
	},
	['hotchocolate'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.hp < pokemon.maxhp
		end
	},
	['potion'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.hp < pokemon.maxhp
		end
	},
	['superpotion'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.hp < pokemon.maxhp
		end
	},
	['hyperpotion'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.hp < pokemon.maxhp
		end
	},
	['maxpotion'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.hp < pokemon.maxhp
		end
	},
	
	['rarecandy'] = {
		onProcess = function(pokemon, data)
			_p.Utilities.sound(287531241, nil, nil, 5)--level up need to be replaced/reuploaded
			if data.evo and data.evo.flip then
				data.evo.orientation0 = _p.Battle:sampleOrientation()
			end
			_p.NPCChat:say(data.pokeName .. ' grew to level ' .. data.newLevel .. '!')
			_p.Pokemon:processMovesAndEvolution(data, false)
		end
	},
	['revive'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp <= 0
		end
	},
	['maxrevive'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp <= 0
		end
	},
	['moomoomilk'] = {
		canUse = function(pokemon)
			return not pokemon.egg and pokemon.hp > 0 and pokemon.hp < pokemon.maxhp
		end
	},
	
	['abilitypatch'] = {
		canUse = function(pokemon)
			if not pokemon.hashiddenAbility then return false end
			return not pokemon.egg and not pokemon.hiddenAbility
		end,
	},
	
	-- EV Resets
--	hpreset
--	attackreset
--	defensereset
--	spatkreset
--	spdefreset
--	speedreset
	
	-- Repels
	['repel'] = {
		canUse = true,
		noTarget = true,
		onUse = function()
			local chat = _p.NPCChat
			if _p.Repel.steps > 0 then
				chat:say('Another repellent\'s effects still linger.', 'You can\'t use this now.')
				return false
			end
			chat:say(_p.PlayerData.trainerName .. ' used the Repel.',
				'The likelihood of encountering wild pokemon decreased!')
			_p.Repel.steps = 100 * 2
			_p.Repel.kind = 1
		end
	},
	['superrepel'] = {
		canUse = true,
		noTarget = true,
		onUse = function()
			local chat = _p.NPCChat
			if _p.Repel.steps > 0 then
				chat:say('Another repellent\'s effects still linger.', 'You can\'t use this now.')
				return false
			end
			chat:say(_p.PlayerData.trainerName .. ' used the Super Repel.',
				'The likelihood of encountering wild pokemon decreased!')
			_p.Repel.steps = 200 * 2
			_p.Repel.kind = 2
		end
	},
	['maxrepel'] = {
		canUse = true,
		noTarget = true,
		onUse = function()
			local chat = _p.NPCChat
			if _p.Repel.steps > 0 then
				chat:say('Another repellent\'s effects still linger.', 'You can\'t use this now.')
				return false
			end
			chat:say(_p.PlayerData.trainerName .. ' used the Max Repel.',
				'The likelihood of encountering wild pokemon decreased!')
			_p.Repel.steps = 250 * 2
			_p.Repel.kind = 3
		end
	},
	

}

usableItems.cheriberry  = usableItems.paralyzeheal
usableItems.chestoberry = usableItems.awakening
usableItems.pechaberry  = usableItems.antidote
usableItems.rawstberry  = usableItems.burnheal
usableItems.aspearberry = usableItems.iceheal

local stone = {
	onProcess = function(pokemon, data)
		_p.Pokemon:processMovesAndEvolution(data, false)
	end
}
usableItems.sunstone     = stone
usableItems.moonstone    = stone
usableItems.firestone    = stone
usableItems.thunderstone = stone
usableItems.waterstone   = stone
usableItems.leafstone    = stone
usableItems.shinystone   = stone
usableItems.duskstone    = stone
usableItems.dawnstone    = stone
usableItems.icestone     = stone


return usableItems end