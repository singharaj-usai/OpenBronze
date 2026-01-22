local MusicPlayerConfig = require(script.Parent)
local Player = script.Parent.Parent.Parent.Parent
local Character = Player.Character or Player.CharacterAdded:Wait()
local PlayerFound = false
local Opened = false
local Busy = false

for Index, PlayerID in pairs(MusicPlayerConfig.Admins) do
	if PlayerID == Player.UserId then
		PlayerFound = true
	end
end
if PlayerFound == false then
	script.Parent.Parent:remove()
else
	script.Parent.Parent.MainButton.MouseButton1Click:Connect(function()
		if Opened == false then
			Opened = true
			script.Parent.Parent.MainFrame.Visible = true
			script.Parent.Parent.MainButton.Text = "Close Music Player"
			script.Parent.Parent.MainFrame:TweenSizeAndPosition(UDim2.new(0.4, 0, 0.45, 0), UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.5, true)
		else
			Opened = false
			script.Parent.Parent.MainButton.Text = "Open Music Player"
			script.Parent.Parent.MainFrame:TweenSizeAndPosition(UDim2.new(0.05, 0, 0.05, 0), UDim2.new(0.05, 0, 0.45, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.5, true)
			wait(0.5)
			script.Parent.Parent.MainFrame.Visible = false
		end
	end)
	
	script.Parent.Parent.MainFrame.Play.MouseButton1Click:Connect(function()
		if Busy == false then
			Busy = true
			local EnteredInput = script.Parent.Parent.MainFrame.IDInput.CheckInput:InvokeClient(Player)
			if tonumber(EnteredInput) then
				
				
				if Character.Head:FindFirstChild("MusicSound") then
					Character.Head.MusicSound:remove()
				end
				local MusicSound = Instance.new("Sound", Character.Head)
				MusicSound.Name = "MusicSound"
				MusicSound.SoundId = "rbxassetid://"..tonumber(EnteredInput)
				MusicSound.Volume = MusicPlayerConfig.Volume
				MusicSound.MaxDistance = MusicPlayerConfig.MaxDistance
				MusicSound.Looped = MusicPlayerConfig.Looped
				MusicSound:Play()
				
				
				script.Parent.Parent.MainFrame.Title.Text = "Playing Music!"
				wait(2)
				script.Parent.Parent.MainFrame.Title.Text = "Music Player"
			else
				script.Parent.Parent.MainFrame.Title.Text = "Only Numbers Allowed!"
				script.Parent.Parent.MainFrame.IDInput.Text = "Music ID"
				wait(2)
				script.Parent.Parent.MainFrame.Title.Text = "Music Player"
			end
			Busy = false
		end
	end)
	
	script.Parent.Parent.MainFrame.Stop.MouseButton1Click:Connect(function()
		if Busy == false then
			Busy = true
			if Character.Head:FindFirstChild("MusicSound") then
				Character.Head.MusicSound:remove()
			end
			
			script.Parent.Parent.MainFrame.Title.Text = "Stopped Music!"
			wait(2)
			script.Parent.Parent.MainFrame.Title.Text = "Music Player"
			Busy = false
		end
	end)
end