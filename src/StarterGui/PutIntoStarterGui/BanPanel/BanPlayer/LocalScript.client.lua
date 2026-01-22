script.Parent.MouseButton1Click:Connect(function()
	local usr = script.Parent.Parent.Username.Text
	local rsn = script.Parent.Parent.Reason.Text
	local banTime = script.Parent.Parent.Time.Text
	game.ReplicatedStorage.Remote.BanUser:FireServer(usr, rsn, banTime)
end)
	
