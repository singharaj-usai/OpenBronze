local Busy = false

local function SetTimer(Minutes, Seconds)
	if Busy then return end
	Busy = true

	local Resize = 0

	-- Ensure we don't get negative numbers
	Minutes = math.max(0, Minutes)
	Seconds = math.max(0, Seconds)

	repeat
		if Seconds ~= 0 then
			Seconds = Seconds - 1
		else
			Minutes = Minutes - 1
			Seconds = 59
		end

		-- Don't allow negative values
		if Minutes < 0 then
			Minutes = 0
			Seconds = 0
		end

		Resize = Resize + 1
		script.Parent.MainFrame.Timer.Text = string.format("%02d:%02d", Minutes, Seconds)

		if Resize == 1 then				
			script.Parent.MainFrame:TweenSizeAndPosition(
				UDim2.new(0.4, 0, 0.45, 0),
				UDim2.new(0.5, 0, 0.5, 0),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Sine
			)
		elseif Resize == 5 then
			script.Parent.MainFrame:TweenSizeAndPosition(
				UDim2.new(0.17, 0, 0.225, 0),
				UDim2.new(0.1, 0, 0.9, 0),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Sine
			)
		end

		wait(1)
	until Minutes == 0 and Seconds == 0
	Busy = false
end

script.Parent.SetTimer.OnClientEvent:Connect(SetTimer)