print("Context")
wait(.5)
local COLOSSEUM_ID = 120576570377936
local RESORT_ID    = 124737548790762
--[[
--[[
if game.CreatorId == 2022685502 then --always change this whenever new creatorid
	COLOSSEUM_ID = 5967914040
	RESORT_ID    = 5967914192
end
--]]
local storage = game:GetService('ServerStorage')
local subContextStorage = storage:WaitForChild('SubContexts')
local repStorage = game:GetService('ReplicatedStorage')
local placeId = game.PlaceId
local context

--[[
This code is setting the game context to 'battle' and making the necessary changes to the game world to prepare for a battle.
First, it removes the MapChunks and Indoors folders from the ServerStorage and sets the Skybox to the Lighting service.
Next, it sets the WorldModel and its children (the 2v2Board and SpectateBoard) to the Workspace.
Then it sets the 'colosseum' chunk to the MapChunks folder and removes the 'Colosseum' folder from the SubContextStorage.
Finally, it sets the SingleFields and DoubleFields folders to the Models.BattleScenes folder and removes the SubContextStorage folder.
It also sets the TimeOfDay to 14:00:00.
]]
if placeId == COLOSSEUM_ID then
	context = 'battle'
	storage.MapChunks:ClearAllChildren()
	storage.Indoors:ClearAllChildren()
	subContextStorage.Colosseum.Skybox.Parent = game:GetService('Lighting')
	local worldModel = subContextStorage.Colosseum.WorldModel
	worldModel.Parent = workspace
	pcall(function() require(script['2v2Board']):enable(worldModel['2v2Board'].Screen.SurfaceGui.Container) end)
	pcall(function() require(script.SpectateBoard):enable(worldModel.SpectateBoard.Screen.SurfaceGui.Container) end)
	local chunk = subContextStorage.Colosseum.chunk
	chunk.Name = 'colosseum'
	chunk.Parent = storage.MapChunks

	storage.Models.BattleScenes:ClearAllChildren()
	subContextStorage.Colosseum.SingleFields.Parent = storage.Models.BattleScenes
	subContextStorage.Colosseum.DoubleFields.Parent = storage.Models.BattleScenes

	subContextStorage:remove()
	game:GetService('Lighting').TimeOfDay = '14:00:00'

--[[
This code sets the context variable to 'trade' if the place ID is equal to RESORT_ID.
It then clears all children of the MapChunks and Indoors folders in the storage service.
The WorldModel in the subContextStorage is set as the parent of the workspace.
The chunk in the subContextStorage is set as a child of the MapChunks folder and given the name 'resort'.
The subContextStorage is then removed and the TimeOfDay is set to '10:00:00'.
If the place ID is not equal to RESORT_ID, then the context variable is set to 'adventure' and the subContextStorage is removed.	
]]	
elseif placeId == RESORT_ID then
	context = 'trade'
	storage.MapChunks:ClearAllChildren()
	storage.Indoors:ClearAllChildren()
	--subContextStorage.Resort.Skybox.Parent = game:GetService('Lighting')--for winter
	subContextStorage.Resort.WorldModel.Parent = workspace
	local chunk = subContextStorage.Resort.chunk
	chunk.Name = 'resort'
	chunk.Parent = storage.MapChunks

	--	repStorage.Models.BattleScenes:remove()

	subContextStorage:remove()
	game:GetService('Lighting').TimeOfDay = '10:00:00'--'14:00:00'
else
	context = 'adventure'
	subContextStorage:remove()
end

if context ~= 'adventure' then
	game:GetService('Players').ChildAdded:connect(function(player)
		if not player or not player:IsA('Player') then return end
		if player.UserId < 1 then
			player:Kick()
		end
	end)
end

-- Create a new string value object
local tag = Instance.new("StringValue")

-- Set the name of the string value object to "GameContext"
tag.Name = "GameContext"

-- Set the value of the string value object to the current context
tag.Value = context

-- Set the parent of the string value object to the ReplicatedStorage's Version folder
tag.Parent = repStorage.Version

return context