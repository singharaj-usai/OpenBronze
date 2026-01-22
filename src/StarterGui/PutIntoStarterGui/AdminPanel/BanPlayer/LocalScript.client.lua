script.Parent.MouseButton1Click:Connect(function()
	local plr = script.Parent.Parent.Parent.Parent.Parent
	if plr:GetRankInGroup(8637068) >= 238 then
		script.Parent.Parent.Visible = false
		script.Parent.Parent.Parent.BanPanel.Visible = true
	end
end)