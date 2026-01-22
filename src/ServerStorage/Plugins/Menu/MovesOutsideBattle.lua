return function(_p)

return {
	fly = {
		icon = 5217659228,
		iconName = 'Fly',
		canUse = function(pokemon)
			if not _p.PlayerData.badges[4] then
				return 'You must obtain the Soaring Badge before using Fly outside of battle.'
			end
			local chunk = _p.DataManager.currentChunk
			if chunk.indoors or chunk.data.canFly == false then
				return 'You can\'t use that here.'
			end
			return true
		end,
		onUse = function(pokemon)
			spawn(function()
				_p.Menu.party.battleEvent = 1 -- important hack to prevent enabling movement / menu
				_p.Menu.party:close()
				_p.Menu.party.battleEvent = nil
			end)
			_p.Menu.map:fly()
		end
	}
}
end