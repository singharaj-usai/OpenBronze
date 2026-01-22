local Functions = {}

-- General variables
local ThisTool = script.Parent.Parent
local MainScript = ThisTool:WaitForChild("Main")
local SegwayController = MainScript:WaitForChild("SegwayController")
local ToolStatus = ThisTool:WaitForChild("ToolStatus")
local Wings = {"Left Wing","Right Wing"}

-- Create base segway to clone from
local SegID = 581150091
local Segway = require(SegID)

local function Get_des(instance, func)
	func(instance)
	for _, child in next, instance:GetChildren() do
		Get_des(child, func)
	end
end

Functions.PlaySound = function(Sound,Pitch,Volume)
	if Sound and Sound.Parent.Name == "Seat" then
		Sound.Pitch = Pitch
		Sound.Volume = Volume
		Sound:Play()
	end
end

Functions.StopSound = function(Sound,Volume)
	if Sound and Sound.Parent.Name == "Seat" then
		Sound.Volume = Volume
		Sound:Stop()
	end
end

Functions.AnchorPart = function(Part,Anchored)
	if Part and Part:IsA("BasePart") and Part.Name == "Seat" then
		Part.Anchored = Anchored
	end
end

Functions.UndoTags = function(SegwayObject,WeldObject,TiltMotor)
	WeldObject.Value = nil
	TiltMotor.Value = nil
	SegwayObject.Value = nil
end

Functions.UndoHasWelded = function(SeaterObject)
	if SeaterObject.Value and SeaterObject.Value.Parent then
		SeaterObject.Value.Parent.HasWelded.Value = false
		SeaterObject.Value = nil
	end
end

Functions.TiltMotor = function(Motor,Angle)
	if Motor and Motor.Name == "TiltMotor" then
		Motor.DesiredAngle = Angle
	end
end

Functions.DeleteWelds = function(Part)
	if Part and Part:IsA("BasePart") and Part.Name == "Seat" then
		for _,v in pairs(Part:GetChildren()) do
			if v:IsA("Motor6D") then
			v:remove()
			end
		end
	end
end

Functions.ConfigHumanoid = function(Character,Humanoid,PlatformStand,Jump,AutoRotate)
	if Humanoid and Humanoid.Parent == Character then
		Humanoid.AutoRotate = AutoRotate
		Humanoid.PlatformStand = PlatformStand
		Humanoid.Jump = Jump
		
		Get_des(Character,function(d)
			if d and d:IsA("CFrameValue") and d.Name == "KeptCFrame" then
				d.Parent.C0 = d.Value
				d:remove()
			end
		end)
	end
end

Functions.ConfigLights = function(Transparency,Color,Bool,Material,Lights,Notifiers)
	if Lights and Notifiers then
		for _,v in pairs(Lights:GetChildren()) do
			if v:IsA("BasePart") and v:FindFirstChild("SpotLight") and v:FindFirstChild("Glare") then
			v.BrickColor = BrickColor.new(Color)
			v.Transparency = Transparency
			v:FindFirstChild("SpotLight").Enabled = Bool
			v.Material = Material
			end
		end
		
		for _,v in pairs(Notifiers:GetChildren()) do
			if v:IsA("BasePart") and v:FindFirstChild("SurfaceGui") then
			v:FindFirstChild("SurfaceGui").ImageLabel.Visible = Bool
			end
		end
	end
end

Functions.ColorSegway = function(Model,Color)
	for i=1, #Wings do
		for _,v in pairs(Model[Wings[i]]:GetChildren()) do
			if v.Name == "Base" or v.Name == "Cover" then
			v.BrickColor = Color
			end
		end
	end
end

Functions.removeSegway = function(Character,SpawnedSegway)
	if SpawnedSegway:IsA("ObjectValue") and SpawnedSegway.Value and SpawnedSegway.Value:FindFirstChild("SegPlatform") then
		SpawnedSegway.Value:remove()
	end
end

Functions.SpawnSegway = function(Player,Character,Tool,SpawnedSegway,Color)
	if Character and not Character:FindFirstChild(Segway.Name) and Tool.Parent == Character then
		local NewSegway = Segway:Clone()
		local Head = Character:WaitForChild("Head")
		
		-- Get the head's rotation matrix
		local p,p,p,xx,xy,xz,yx,yy,yz,zx,zy,zz = Head.CFrame:components()
		
		-- Get the position in front of player
		local SpawnPos = Head.Position + (Head.CFrame.lookVector*4)
		
		ToolStatus.Thruster.Value = NewSegway:WaitForChild("Wheels"):WaitForChild("Thruster")
		
		-- Apply the settings called from the client
		NewSegway:WaitForChild("Creator").Value = Player
		NewSegway:WaitForChild("MyTool").Value = Tool
		SpawnedSegway.Value = NewSegway
		
		-- Colors the segway
		Functions.ColorSegway(NewSegway,Color)
		
		-- Parent segway into the player's character
		NewSegway.Parent = Character
		NewSegway:MakeJoints()
			
		-- Position segway
		NewSegway:SetPrimaryPartCFrame(CFrame.new(0,0,0,xx,xy,xz,yx,yy,yz,zx,zy,zz)*CFrame.Angles(0,math.rad(180),0)) -- Rotate segway properly
		NewSegway:MoveTo(SpawnPos)
	end
end

Functions.ConfigTool = function(Transparency,Tool,ShouldColor,Color)
	if Tool == ThisTool then
		for _,v in pairs(Tool:GetChildren()) do
			if v:IsA("BasePart") and ShouldColor == false then
				v.Transparency = Transparency
			elseif ShouldColor == true and v:IsA("BasePart") and v.Name == "ColorablePart" then
				v.BrickColor = Color
			end
		end
	end
end

return Functions