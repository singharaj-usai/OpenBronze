local logNumber = 1

local function addLog(username, action, subject)
	if logNumber < 7 then
		local currentFrame = "Frame"..logNumber
		logNumber = logNumber + 1
		local Frame = script.Parent.Logs:FindFirstChild(currentFrame)
		Frame.Username.Text = "Moderator: "..username
		Frame.Action.Text = "Action: "..action
		Frame.Subject.Text = "Subject: "..subject
		local user = game.Players:FindFirstChild(username)
		local userId = user.UserId
	else
		logNumber = 1
		local currentFrame = "Frame"..logNumber
		local Frame = script.Parent.Logs:FindFirstChild(currentFrame)
		Frame.Username.Text = "Moderator: "..username
		Frame.Action.Text = "Action: "..action
		Frame.Subject.Text = "Subject: "..subject
		local user = game.Players:FindFirstChild(username)
	end
end

game.ReplicatedStorage.Remote.AddLog.OnClientEvent:Connect(addLog)