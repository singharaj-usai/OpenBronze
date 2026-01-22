local InfoFrame = script.Parent:WaitForChild("InfoFrame")
local CreditLabel = InfoFrame:WaitForChild("CreditLabel")
local OpenButton = script.Parent:WaitForChild("OpenButton")
local Opened = false
local TakeOne = InfoFrame:WaitForChild("TakeOne")
local Market = game:GetService("MarketplaceService")
local ModelId = 331554374
local PromptModule = require(script:WaitForChild("PromptPlayer"))
local Player = game.Players.LocalPlayer
local CreatorsName = game:GetService("InsertService"):GetUserSets(31342830)[1].CreatorName


function ShiftColor(t,FromColor,ToColor)
	for i=0,1,1/(t/0.03) do
	local c = FromColor * (1-i) + ToColor * i
	OpenButton.ImageColor3=Color3.new(c.X/255,c.Y/255,c.Z/255)
	wait()
	end
end

OpenButton.MouseButton1Click:connect(function()
	if Opened == false then
		Opened = true
		InfoFrame:TweenPosition(UDim2.new(0.5, -120,0.5, -140),0,0,0.4,true)
		CreditLabel.Text = "Brought to you by: " .. CreatorsName
	elseif Opened == true then
		Opened = false
		InfoFrame:TweenPosition(UDim2.new(0.5, -120,1, 140),0,0,0.4,true)
	end
end)

TakeOne.MouseButton1Down:connect(function()
	PromptModule(Player,ModelId)
end)

while wait(2) do
	if script.Parent.Parent and script.Parent.Parent.Name == "PlayerGui" then -- So the color won't be transitioning while not in PlayerGui
	ShiftColor(1.5,Vector3.new(255, 255, 255),Vector3.new(71, 185, 255))
	wait(2)
	ShiftColor(1.5,Vector3.new(71, 185, 255),Vector3.new(255, 255, 255))
	end
end