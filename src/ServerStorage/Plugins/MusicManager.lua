--SynapseX Decompiler

return function(_p)
	local Utilities = _p.Utilities
	local MusicManager = {}
	local musicStack = {}
	function MusicManager:debug()
		print()
		print("MusicManager stack:")
		for i, music in ipairs(musicStack) do
			print(i, music.Name, music.DesiredVolume, music.Sound.Volume, music.Sound.SoundId)
		end
	end
	function MusicManager:getMusicStack()
		return musicStack
	end
	function MusicManager:getMusicNamed(name)
		for index, music in ipairs(musicStack) do
			if music.Name == name then
				return music, index
			end
		end
	end
	function MusicManager:fadeToVolume(music, relVolume, fadeDuration, ignoreWarning)
		if music == "top" or music == true then
			music = musicStack[#musicStack]
		elseif type(music) == "string" then
			local st = music
			music = self:getMusicNamed(st)
			if not music then
				if not ignoreWarning then
					warn("unable to find music \"" .. st .. "\".")
				end
				return
			end
		end
		if not music then
			return
		end
		local volume = music.DesiredVolume * relVolume
		if fadeDuration == 0 then
			music.FadeThread = nil
			music.Sound.Volume = volume
		else
			do
				local thisThread = {}
				music.FadeThread = thisThread
				local sv = music.Sound.Volume
				Utilities.Tween(fadeDuration or 1, nil, function(a)
					if music.FadeThread ~= thisThread then
						return false
					end
					music.Sound.Volume = sv + (volume - sv) * a
				end)
			end
		end
	end
	function MusicManager:prepareToStack(fadeDuration)
		local topMusic = musicStack[#musicStack]
		if not topMusic then
			return
		end
		self:fadeToVolume(topMusic, 0, fadeDuration)
	end
	function MusicManager:stackMusic(id, name, desiredVolume)
		local topMusic = musicStack[#musicStack]
		if topMusic and topMusic.Sound.Volume > 0 then
			Utilities.fastSpawn(self.fadeToVolume, self, topMusic, 0, 0.5)
		end
		local music = Utilities.loopSound(id, desiredVolume)
		music.Name = name
		musicStack[#musicStack + 1] = {
			Name = name,
			Sound = music,
			DesiredVolume = desiredVolume or 0.5
		}
		return music
	end
	function MusicManager:popMusic(name, fadeDuration, silence)
		local startIndex
		if name == "all" or name == true then
			startIndex = 1
		else
			for index, music in pairs(musicStack) do
				if music.Name == name then
					startIndex = index
					break
				end
			end
		end
		if not startIndex then
			return false
		end
		local fadeMusic = table.remove(musicStack)
		while startIndex <= #musicStack do
			do
				local m = table.remove(musicStack)
				m.FadeThread = nil
				m.Sound:Stop()
				delay(0.5, function()
					m.Sound:remove()
				end)
			end
		end
		if not silence then
			Utilities.fastSpawn(function()
				self:returnFromSilence(fadeDuration or 1)
			end)
		end
		if not fadeMusic then
			return true
		end
		Utilities.fastSpawn(function()
			if fadeDuration then
				self:fadeToVolume(fadeMusic, 0, fadeDuration)
			end
			fadeMusic.Sound:Stop()
			delay(0.5, function()
				fadeMusic.Sound:remove()
			end)
		end)
		return true
	end
	function MusicManager:removeMusic(name)
		local music, index = self:getMusicNamed(name)
		if music then
			table.remove(musicStack, index)
			music.FadeThread = nil
			music.Sound:Stop()
			delay(0.5, function()
				music.Sound:remove()
			end)
		end
	end
	function MusicManager:returnFromSilence(fadeDuration)
		local topMusic = musicStack[#musicStack]
		if not topMusic then
			return
		end
		self:fadeToVolume(topMusic, 1, fadeDuration)
	end
	return MusicManager
end
