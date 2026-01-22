script.Parent.MouseButton1Click:Connect(function()
	local plr = script.Parent.Parent.Parent.Parent.Parent
	if plr:GetRankInGroup(8637068) >= 248 then
		game.ReplicatedStorage.Remote.ShutdownServer:FireServer()
	end
end)