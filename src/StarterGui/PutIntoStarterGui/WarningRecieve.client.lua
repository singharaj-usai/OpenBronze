game.ReplicatedStorage.Remote.ClientWarnUser.OnClientEvent:Connect(function(moderatorUsername, reason)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Warning Notification",
		Text = "You have been warned by "..moderatorUsername.." for the reason of "..reason..".",
		Icon = "http://www.roblox.com/asset/?id=6224039551", -- (this is optional meaning you can leave it)
		Duration = 5, -- if left blank then it will default to 5 seconds
	}
	)
end)