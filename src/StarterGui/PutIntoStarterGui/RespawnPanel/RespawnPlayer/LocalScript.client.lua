script.Parent.MouseButton1Click:Connect(function()
	local username = script.Parent.Parent.Username.Text
	game.ReplicatedStorage.Remote.RespawnPlayer:FireServer(username)
end)