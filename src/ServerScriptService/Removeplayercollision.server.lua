--mrbobbilly, this removes player collisions, r15 and r6 doesn't matter just put it in workspace or serverscriptservice

-- This script is placed in the "ServerScriptService" and creates a PhysicsService collision group named "p"
-- The "p" collision group is set to not be collidable with itself
-- A function named "NoCollide" is defined which will set the collision group of any BaseParts in the given model to "p"
-- When a player is added to the game, the function connects to their "CharacterAdded" event
-- Once the character is added, the function waits for the "HumanoidRootPart", "Head", and "Humanoid" to be added as children
-- Then, the "NoCollide" function is called on the character
-- If the player already has a character when they are added, the "NoCollide" function is called on that character as well

-- This function assigns the parts of the given model to the "p" collision group, which disables collision between objects in the same group.
local PhysService = game:GetService("PhysicsService") -- Get the PhysicsService
local PlayerGroup = PhysService:CreateCollisionGroup("p") -- Create a new collision group called "p"
PhysService:CollisionGroupSetCollidable("p","p",false) -- Set the "p" collision group to not be collidable with itself

-- Define the NoCollide function
function NoCollide(model)
	for k,v in pairs(model:GetChildren()) do -- For each child of the model
		if v:IsA"BasePart" then -- If the child is a BasePart
			PhysService:SetPartCollisionGroup(v,"p") -- Set the part's collision group to "p"
		end
	end
end

-- When a player is added
game.Players.PlayerAdded:connect(function(player)
	-- When the player's character is added
	player.CharacterAdded:connect(function(char)
		-- Wait for the character's HumanoidRootPart, Head, and Humanoid to be added
		char:WaitForChild("HumanoidRootPart")
		char:WaitForChild("Head")
		char:WaitForChild("Humanoid")
		wait(0.1) -- Wait 0.1 seconds
		NoCollide(char) -- Set the character's collision group to "p"
	end)

	-- If the player already has a character
	if player.Character then
		NoCollide(player.Character) -- Set the character's collision group to "p"
	end

end)