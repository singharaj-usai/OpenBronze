-- based on the code for Roblox's built-in mobile on-screen DPad
-- modified, including aesthetically, by tbradm

local DPad = {}
local Interaction

local gui
local DPadFrame = nil
local TouchObject = nil
local OnInputEnded = nil

--[[ Constants ]]--
local DIRECTIONS = {
	Vector2.new( 1,  0), -- R
	Vector2.new( 0,  1), -- D
	Vector2.new(-1,  0), -- L
	Vector2.new( 0, -1), -- U
}

--[[ lua Function Cache ]]--
local ATAN2 = math.atan2
local FLOOR = math.floor
local PI = math.pi

--[[ Local Functions ]]--
local function getCenterPosition()
	return Vector2.new(DPadFrame.AbsolutePosition.x + DPadFrame.AbsoluteSize.x/2, DPadFrame.AbsolutePosition.y + DPadFrame.AbsoluteSize.y/2)
end

--[[ Public API ]]--
function DPad:Init(interaction)
	Interaction = interaction
end

function DPad:Enable()
	if not DPadFrame then
		gui = Instance.new('ScreenGui', game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui'))
		self:Create(gui)
	end
	DPadFrame.Visible = true
end

function DPad:Disable()
	if DPadFrame then DPadFrame.Visible = false end
	if OnInputEnded then
		OnInputEnded()
		OnInputEnded = nil
	end
end

function DPad:Create(parentFrame)
	if DPadFrame then
		DPadFrame:remove()
		DPadFrame = nil
	end
	
	local position = UDim2.new(0, 20, 1, -217)
	DPadFrame = Instance.new('ImageLabel')
	DPadFrame.Name = 'DPadFrame'
	DPadFrame.Image = 'rbxassetid://5267746574'
	DPadFrame.ImageTransparency = 0.5
	DPadFrame.Active = true
	DPadFrame.Visible = false
	DPadFrame.Size = UDim2.new(0, 192, 0, 192)
	DPadFrame.Position = position
	DPadFrame.BackgroundTransparency = 1
	DPadFrame.ZIndex = 10
	
	-- input connections
	
	local movementVector = Vector2.new()
	local function normalizeDirection(inputPosition)
		local minRadius = DPadFrame.AbsoluteSize.x/6
		local centerPosition = getCenterPosition()
		local direction = Vector2.new(inputPosition.x - centerPosition.x, inputPosition.y - centerPosition.y)
		
		if direction.magnitude > minRadius then
			local angle = ATAN2(direction.y, direction.x)
			local q = (FLOOR(4 * angle / (2 * PI) + .5)%4) + 1
			movementVector = DIRECTIONS[q]
--			print(movementVector)
		end
	end
	
	DPadFrame.InputBegan:connect(function(inputObject)
		if TouchObject or inputObject.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		
		Interaction:releaseDir(movementVector)
		
		TouchObject = inputObject
		normalizeDirection(TouchObject.Position)
		
		Interaction:pressDir(movementVector)
	end)
	
	DPadFrame.InputChanged:connect(function(inputObject)
		if inputObject == TouchObject then
			Interaction:releaseDir(movementVector)
			normalizeDirection(TouchObject.Position)
			Interaction:pressDir(movementVector)
		end
	end)
	
	OnInputEnded = function()
		TouchObject = nil
		
		Interaction:releaseDir(movementVector)
		movementVector = Vector2.new()
	end
	
	DPadFrame.InputEnded:connect(function(inputObject)
		if inputObject == TouchObject then
			OnInputEnded()
		end
	end)
	
	DPadFrame.Parent = parentFrame
end

function DPad:remove()
	if OnInputEnded then
		OnInputEnded()
		OnInputEnded = nil
	end
	if DPadFrame then
		DPadFrame:remove()
		DPadFrame = nil
	end
	if gui then
		gui:remove()
		gui = nil
	end
end

return DPad