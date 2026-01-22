local ShutdownConfig = {
	
	Timer = 15, -- Timer before shutting down. (In minutes!)
	Prefix = ".", -- Prefix before the command
	TitleMessage = "Shutting Down...", -- Title of the message.
	SecondTitleMessage = "Please SAVE as soon as possible!", -- Second title of the message.
	ShutdownMessage = "The server is being updated!", -- Message to be shown before shutting down if there is no message given.
	
	Admins = { -- Add the user ID's of the people that able to shutdown the server.
		--166411070, -- Dutch_Coder
		1916249778, -- mrbobbilly
		446187905,
		2022685502
	}
}

return ShutdownConfig
