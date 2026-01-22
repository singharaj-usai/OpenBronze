script.Parent.MouseButton1Click:Connect(function()
	if script.Parent.Parent.AdminPanel.Visible == true then
		script.Parent.Parent.AdminPanel.Visible = false
	else
		script.Parent.Parent.AdminPanel.Visible = true
	end
end)