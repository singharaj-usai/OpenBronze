local Colors = script.Parent:WaitForChild("Colors")
local OpenButton = script.Parent:WaitForChild("OpenButton")
local MyTool = script.Parent:WaitForChild("MyTool")
while not MyTool.Value do wait() end
local UsersTool = MyTool.Value
local SettingsFolder = UsersTool:WaitForChild("Configuration")
local StartingColor = SettingsFolder:WaitForChild("StartingColor")
local RemoteFolder = UsersTool:WaitForChild("RemoteEvents")
local ConfigTool = RemoteFolder:WaitForChild("ConfigTool")
local Opened = false
local Wings = {"Left Wing","Right Wing"}

local ConfigTool = function(Transparency,Tool,ShouldColor,Color)
	for _,v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and ShouldColor == false then
			v.Transparency = Transparency
		elseif ShouldColor == true and v:IsA("BasePart") and v.Name == "ColorablePart" then
			v.BrickColor = Color
		end
	end
end

for _,v in pairs(Colors:GetChildren()) do
	if v:IsA("ImageButton") then
	local ButtonsColor = v:WaitForChild("PartColor").Value
		v.MouseEnter:connect(function()
			if Opened == true then
				ConfigTool(0,UsersTool,true,ButtonsColor)
			end
		end)
			v.MouseLeave:connect(function()
				if Opened == true then
					ConfigTool(0,UsersTool,true,StartingColor.Value)
				end
			end)
				v.MouseButton1Down:connect(function()
					if Opened == true then
						StartingColor.Value = ButtonsColor
						ConfigTool(0,UsersTool,true,ButtonsColor)
					end
				end)
	end
end

OpenButton.MouseButton1Click:connect(function()
	if Opened == false then
		Opened = true
		OpenButton.Rotation = -90
		Colors:TweenPosition(UDim2.new(0.5, -99,0.5, -140),0,0,0.4,true)
	elseif Opened == true then
		Opened = false
		OpenButton.Rotation = 90
		Colors:TweenPosition(UDim2.new(0, -230,0.5, -140),0,0,0.4,true)
	end
end)
