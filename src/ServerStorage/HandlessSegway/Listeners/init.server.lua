-- This script listens for RemoteEvents that will be called from the client ("Main" script)
local Home = script.Parent

-- ModuleScript that holds all the functions that are tied with the RemoteEvents
local Functions = require(script:WaitForChild("ServerFunctions"))

-- Folder that contains the RemoteEvents
local RemoteFolder = Home:WaitForChild("RemoteEvents")

-- Define each RemoteEvent individually
local SpawnSegway = RemoteFolder:WaitForChild("SpawnSegway") -- Spawning segway
local ConfigTool = RemoteFolder:WaitForChild("ConfigTool") -- Coloring segway
local removeSegway = RemoteFolder:WaitForChild("removeSegway") -- Coloring segway
local PlaySound = RemoteFolder:WaitForChild("PlaySound")
local StopSound = RemoteFolder:WaitForChild("StopSound")
local AnchorSegway = RemoteFolder:WaitForChild("AnchorSegway")
local UndoTags = RemoteFolder:WaitForChild("UndoTags")
local UndoHasWelded = RemoteFolder:WaitForChild("UndoHasWelded")
local DeleteWelds = RemoteFolder:WaitForChild("DeleteWelds")
local ConfigHumanoid = RemoteFolder:WaitForChild("ConfigHumanoid")
local ConfigLights = RemoteFolder:WaitForChild("ConfigLights")

-- Listeners
SpawnSegway.OnServerEvent:connect(function(Player,Character,MaxSpeed,TurnSpeed,Tool,SpawnedSegway,Color)
	Functions.SpawnSegway(Player,Character,MaxSpeed,TurnSpeed,Tool,SpawnedSegway,Color)
end)

ConfigTool.OnServerEvent:connect(function(Player,Transparency,Tool,ShouldColor,Color)
	Functions.ConfigTool(Transparency,Tool,ShouldColor,Color)
end)

removeSegway.OnServerEvent:connect(function(Player,Character,SpawnedSegway)
	Functions.removeSegway(Character,SpawnedSegway)
end)

PlaySound.OnServerEvent:connect(function(Player,Sound,Pitch,Volume)
	Functions.PlaySound(Sound,Pitch,Volume)
end)

StopSound.OnServerEvent:connect(function(Player,Sound,Volume)
	Functions.StopSound(Sound,Volume)
end)

AnchorSegway.OnServerEvent:connect(function(Player,PrimaryPart,Anchored)
	Functions.AnchorPart(PrimaryPart,Anchored)
end)

UndoTags.OnServerEvent:connect(function(Player,SegwayObject,WeldObject,Thruster,TiltMotor)
	Functions.UndoTags(SegwayObject,WeldObject,Thruster,TiltMotor)
end)

UndoHasWelded.OnServerEvent:connect(function(Player,SeaterObject)
	Functions.UndoHasWelded(SeaterObject)
end)

function DeleteWelds.OnServerInvoke(Player,Part)
	Functions.DeleteWelds(Part)
	return true
end

ConfigHumanoid.OnServerEvent:connect(function(Player,Humanoid,PlatformStand,Jump,AutoRotate)
	Functions.ConfigHumanoid(Player.Character,Humanoid,PlatformStand,Jump,AutoRotate)
end)

ConfigLights.OnServerEvent:connect(function(Player,Transparency,Color,Bool,Material,Lights,Notifiers)
	Functions.ConfigLights(Transparency,Color,Bool,Material,Lights,Notifiers)
end)
