local Chat = game:GetService("Chat")

-- Define the event
local ChatWindowCreated = Instance.new("BindableEvent")

-- Create the function that will handle the event
local function onChatWindowCreated()
	-- Add your code here to customize the chat window as needed
end

-- Connect the function to the event
ChatWindowCreated.Event:Connect(onChatWindowCreated)

-- Register the event with the chat service
Chat:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, function()
	ChatWindowCreated:Fire()
	return {
		ClassicChatEnabled = true,
		BubbleChatEnabled = true,
	}
end)
