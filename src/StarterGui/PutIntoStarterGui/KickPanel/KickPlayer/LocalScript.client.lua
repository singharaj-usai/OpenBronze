script.Parent.MouseButton1Click:Connect(function()
	local usr = script.Parent.Parent.Username.Text
	local rsn = script.Parent.Parent.Reason.Text
	game.ReplicatedStorage.Remote.KickUser:FireServer(usr, rsn)
end)

