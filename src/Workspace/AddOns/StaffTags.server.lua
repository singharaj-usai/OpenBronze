local plrs = game.Players
local sss = game.ServerScriptService
local chatService = require(sss:WaitForChild('ChatServiceRunner'):WaitForChild('ChatService'))

chatService.SpeakerAdded:Connect(function(plr)

	local speaker = chatService:GetSpeaker(plr)

	-- COPY FROM THIS
	if plrs[plr].UserId == 446187905 then  -- Me
		speaker:SetExtraData('ChatColor', Color3.fromRGB(38, 226, 255))
		speaker:SetExtraData('Tags', {{TagText = '🛡️ ', TagColor = Color3.fromRGB(0, 179, 255)}})
	end

	if plrs[plr].UserId == 175929148 then  -- chloe
		speaker:SetExtraData('ChatColor', Color3.fromRGB(229, 0, 3))
		speaker:SetExtraData('Tags', {{TagText = '🛡️ ', TagColor = Color3.fromRGB(0, 179, 255)}})
	end
	if plrs[plr].UserId == 1127652156 then  -- jdubz
		speaker:SetExtraData('ChatColor', Color3.fromRGB(229, 0, 3))
		speaker:SetExtraData('Tags', {{TagText = '🛡️ ', TagColor = Color3.fromRGB(0, 179, 255)}})
	end
	if plrs[plr].UserId == 2416213102 then  -- coop
		speaker:SetExtraData('ChatColor', Color3.fromRGB(187, 81, 229))
		speaker:SetExtraData('Tags', {{TagText = '🛡️ ', TagColor = Color3.fromRGB(0, 179, 255)}})
	end
	if plrs[plr].UserId == 159436356 then  -- clarence
		speaker:SetExtraData('ChatColor', Color3.fromRGB(187, 81, 229))
		speaker:SetExtraData('Tags', {{TagText = '🛡️ ', TagColor = Color3.fromRGB(0, 179, 255)}})
	end


	-- TO THIS
	-- IF YOU WANT MORE PLAYERS AND OPTIONS JUST COPY WHAT I SAID

end)