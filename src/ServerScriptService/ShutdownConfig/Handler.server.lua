local ShutdownConfig = require(script.Parent)
local MessagingService = game:GetService("MessagingService")
local RunService = game:GetService("RunService")
local ShuttingDown = false

local ShutdownStartTime = 0
local MinutesLeft = 0
local SecondsLeft = 0
local ShutdownMessage = ""

function RunSetup()
	if not RunService:IsServer() then return end
	if #game.Players:GetPlayers() == 0 then return end
	if game.JobId == nil then return end

	ShutdownStartTime = os.time()
	MinutesLeft = ShutdownConfig.Timer
	SecondsLeft = 0

	for _, player in pairs(game.Players:GetPlayers()) do
		local shutdownGuiClone = script.Parent.ShutdownGUI:Clone()
		shutdownGuiClone.MainFrame.TitleMessage.Text = ShutdownConfig.TitleMessage
		shutdownGuiClone.MainFrame.SecondTitleMessage.Text = ShutdownConfig.SecondTitleMessage
		if ShutdownMessage == "" then
			shutdownGuiClone.MainFrame.ShutdownMessage.Text = ShutdownConfig.ShutdownMessage
		else
			shutdownGuiClone.MainFrame.ShutdownMessage.Text = ShutdownMessage
		end
		shutdownGuiClone.Parent = player.PlayerGui

		shutdownGuiClone.SetTimer:FireClient(player, ShutdownConfig.Timer, 0)
	end

	-- Start the countdown loop
	spawn(function()
		local minutesLeft = ShutdownConfig.Timer
		local secondsLeft = 0
		repeat
			if secondsLeft ~= 0 then
				secondsLeft = secondsLeft - 1
			else
				minutesLeft = minutesLeft - 1
				secondsLeft = 59
			end
			MinutesLeft = minutesLeft
			SecondsLeft = secondsLeft
			wait(1)
		until minutesLeft == 0 and secondsLeft == 0

		-- Shutdown logic
		for _, player in pairs(game.Players:GetPlayers()) do
			if ShutdownMessage == "" then
				player:Kick(ShutdownConfig.ShutdownMessage)
			else
				player:Kick(ShutdownMessage)
			end
		end
		game:Shutdown()
	end)
end

function GetSetup(Player)
	if not RunService:IsServer() then
		return
	end
	if #game.Players:GetPlayers() == 0 then
		return
	end
	if game.JobId == nil then
		return
	end
	
	
	local ShutdownGuiClone = script.Parent.ShutdownGUI:Clone()
	ShutdownGuiClone.MainFrame.TitleMessage.Text = ShutdownConfig.TitleMessage
	ShutdownGuiClone.MainFrame.SecondTitleMessage.Text = ShutdownConfig.SecondTitleMessage
	if ShutdownMessage == "" then
		ShutdownGuiClone.MainFrame.ShutdownMessage.Text = ShutdownConfig.ShutdownMessage
	else
		ShutdownGuiClone.MainFrame.ShutdownMessage.Text = ShutdownMessage
	end
	ShutdownGuiClone.Parent = Player.PlayerGui
	
	-- Calculate remaining time based on elapsed time
	local elapsedSeconds = os.time() - ShutdownStartTime
	local totalSeconds = ShutdownConfig.Timer * 60
	local remainingSeconds = math.max(0, totalSeconds - elapsedSeconds)
	
	local currentMinutes = math.floor(remainingSeconds / 60)
	local currentSeconds = remainingSeconds % 60
	
	ShutdownGuiClone.SetTimer:FireClient(Player, currentMinutes, currentSeconds)
end

MessagingService:SubscribeAsync("ShutdownServices", function(Message)
	if ShuttingDown == false then
		ShuttingDown = true
		ShutdownMessage = Message.Data
		RunSetup()
	end
end)

game.Players.PlayerAdded:Connect(function(Player)
	if ShuttingDown == true then
		GetSetup(Player)
	end
	
	
	Player.CharacterAdded:Connect(function(Character)
		Character:WaitForChild("Humanoid").Died:Connect(function()
			if ShuttingDown == true then
				GetSetup(Player)
			end
		end)
	end)
	
	
	local IsAllowed = false
	
	for Index, ID in pairs(ShutdownConfig.Admins) do
		if IsAllowed == false then
			if Player.UserId == ID then
				IsAllowed = true
			end
		end
	end
	
	if IsAllowed == true then
		Player.Chatted:Connect(function(ChatMessage)
			local SplittedMessage = string.split(tostring(ChatMessage), " ")
			
			if string.lower(SplittedMessage[1]) == ShutdownConfig.Prefix.."shutdown" then
				local MessageToSend = ""
				
				for Index, Word in pairs(SplittedMessage) do
					if Index ~= 1 then
						MessageToSend = MessageToSend.." "..SplittedMessage[Index]
					end	
				end
				MessagingService:PublishAsync("ShutdownServices",  MessageToSend)
			end
		end)
	end
end)