-- Root variables 
local Tool = script.Parent
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:wait()
local Humanoid = Character:WaitForChild("Humanoid")
local SettingsFolder = Tool:WaitForChild("Configuration")
local MaxSpeed = SettingsFolder:WaitForChild("MaxSpeed")
local TurnSpeed = SettingsFolder:WaitForChild("TurnSpeed")
local StarterColor = SettingsFolder:WaitForChild("StartingColor")
local ToolCoolDown = 2

-- Tool's current status
local ToolStatus = Tool:WaitForChild("ToolStatus")
local SpawnedSegway = ToolStatus:WaitForChild("SpawnedSegway")
local HasSpawnedSegway = ToolStatus:WaitForChild("HasSpawnedSegway")
local IsCoolingDown = false

-- RemoteEvents
local RemoteEvents = Tool:WaitForChild("RemoteEvents")
local SpawnSegway = RemoteEvents:WaitForChild("SpawnSegway")
local ConfigTool = RemoteEvents:WaitForChild("ConfigTool")
local removeSegway = RemoteEvents:WaitForChild("removeSegway")
local ConfigHumanoid = RemoteEvents:WaitForChild("ConfigHumanoid")

-- Camera
local Camera = game.Workspace.CurrentCamera

-- Player's gui and input service
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- Controller script
local SegwayController = script:WaitForChild("SegwayController")

-- Gui
local DisplayGui = script:WaitForChild("DisplayGui")
local ColorGui = script:WaitForChild("ColorGui")
local NewDisplayGui = nil
local NewColorGui = nil

function UndoSettings(Folder)
	for _,v in pairs(Folder:GetChildren()) do
		if v:IsA("NumberValue") or v:IsA("IntValue") then
			v.Value = 0
		elseif v:IsA("ObjectValue") and v.Name ~= "SpawnedSegway" then
			v.Value = nil
		end
	end
end

function RemoveSegway()
	
	-- Remove segway
	removeSegway:FireServer(Character,SpawnedSegway)
	
	-- Reset camera
	Camera.CameraType = "Custom"
	
	-- Show tool
	ConfigTool:FireServer(0,Tool,false,nil)
	
	-- Undo tags anyway
	HasSpawnedSegway.Value = false

	-- UnPlatformStand player
	ConfigHumanoid:FireServer(Humanoid,false,false,true)
	
	-- If player has the segway controller script, we'll reset its settings
	if PlayerGui:FindFirstChild("GuiControls") then -- Remove mobile gui
		PlayerGui:FindFirstChild("GuiControls").Parent = script
	end
	UserInputService.ModalEnabled = false
	UndoSettings(ToolStatus)
end

-- Listeners
Tool.Equipped:connect(function()
	
	-- Redefine character and humanoid just in case
	Character = Player.Character
	Humanoid = Character:WaitForChild("Humanoid")
	
	-- Show the segway menu gui and color gui
	NewDisplayGui = DisplayGui:Clone()
	NewDisplayGui.Parent = PlayerGui
	
	NewColorGui = ColorGui:Clone()
	NewColorGui.Parent = PlayerGui
	NewColorGui:WaitForChild("MyTool").Value = Tool
	
	local OpenButton = NewDisplayGui:WaitForChild("OpenButton")
	local ColorOpenButton = NewColorGui:WaitForChild("OpenButton")
	
	OpenButton:TweenPosition(UDim2.new(1, -92,1, -38),0,0,0.4,true)
	ColorOpenButton:TweenPosition(UDim2.new(0, -6,0.5, -70),0,0,0.4,true)
end)

Tool.Unequipped:connect(function() -- Remove segway when tool is unequipped
	game:GetService("ContextActionService"):UnbindAction("segInputAction")
	
	if NewDisplayGui and NewColorGui then
		NewDisplayGui:remove()
		NewColorGui:remove()
	end
	
	if SpawnedSegway.Value then
		RemoveSegway()
	end
end)

Tool.Activated:connect(function()
	if HasSpawnedSegway.Value == false and IsCoolingDown == false then -- So workspace won't be spammed with segways
	IsCoolingDown = true
	HasSpawnedSegway.Value = true
	
	-- Hide the tool player is holding
	ConfigTool:FireServer(1,Tool,false,nil)
	
	-- Spawn segway
	SpawnSegway:FireServer(Character,Tool,SpawnedSegway,StarterColor.Value) -- Fire remote event to spawn
	
	-- Prevent spamming of segways which may lag the server
	wait(ToolCoolDown)
	IsCoolingDown = false
	end
end)

Humanoid.Died:connect(function()
	RemoveSegway()
end)