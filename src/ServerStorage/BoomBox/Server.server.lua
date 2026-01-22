--[[
	Fixed by ArceusInator
--]]

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")
local Sound = Handle:WaitForChild("Sound")

function onUnequip()
	Sound:Stop()
end

function onActivate()
	Remote:FireClient(getPlayer(), "ChooseSong")
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function playSong(id)
	id = id or ""

	if Sound then
		Sound:remove()
	end
	Sound = Instance.new'Sound'
	Sound.Parent = Handle
	Sound.Volume = 0.4
	Sound.Looped = true
	Sound.PlayOnRemove = false
	Sound.SoundId = "http://www.roblox.com/asset/?id="..id
	Sound:Play()
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		onActivate(...)
	end
	
	if func == "PlaySong" then
		playSong(...)
	end
end

Remote.OnServerEvent:connect(onRemote)
Tool.Unequipped:connect(onUnequip)