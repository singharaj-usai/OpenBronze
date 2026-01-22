--SynapseX Decompiler

return function(_p)
	local CollectionService = game:GetService("CollectionService")
	local CollectionManager = {}
	local gameInitialized = false
	local delayedHandlers = {}
	function CollectionManager:init()
		gameInitialized = true
		for i = 1, #delayedHandlers do
			delayedHandlers[i]()
		end
		delayedHandlers = nil
	end
	function CollectionManager:CreateBehaviorForTag(tag, behavior)
		local workspaceOnly = behavior.WorkspaceOnly
		local addedCallback = behavior.OnInstanceAdded
		if addedCallback then
			do
				local function handleNewInstance(instance)
					if workspaceOnly and not instance:IsDescendantOf(workspace) then
						do
							local connection
							connection = instance.AncestryChanged:Connect(function()
								if connection then
									if instance:IsDescendantOf(workspace) then
										connection:Disconnect()
										connection = nil
										addedCallback(instance)
									elseif instance:IsDescendantOf(nil) then
										connection:Disconnect()
										connection = nil
									end
								end
							end)
						end
					else
						addedCallback(instance)
					end
				end
				CollectionService:GetInstanceAddedSignal(tag):Connect(handleNewInstance)
				local function handleExistingInstances()
					local instances = CollectionService:GetTagged(tag)
					local wrap = coroutine.wrap
					for i = 1, #instances do
						wrap(handleNewInstance)(instances[i])
					end
				end
				if gameInitialized then
					handleExistingInstances()
				else
					delayedHandlers[#delayedHandlers + 1] = handleExistingInstances
				end
			end
		end
		local removedCallback = behavior.OnInstanceRemoved
		if removedCallback then
			CollectionService:GetInstanceRemovedSignal(tag):Connect(removedCallback)
		end
	end
	do
		local npcsByModel = {}
		function CollectionManager:GetNPCs()
			return npcsByModel
		end
		function CollectionManager:GetNPC(name)
			for model, npc in pairs(npcsByModel) do
				if model.Name == name then
					return npc
				end
			end
		end
		function CollectionManager:AddNPC(npc)
			npcsByModel[npc.model] = npc
		end
		CollectionManager:CreateBehaviorForTag("NPC", {
			WorkspaceOnly = true,
			OnInstanceAdded = function(model)
				if not model:IsA("Model") or npcsByModel[model] then
					return
				end
				local npc = _p.NPC:new(model)
				if not model:FindFirstChild("NoAnimate") then
					npc:Animate()
				end
				npcsByModel[model] = npc
			end,
			OnInstanceRemoved = function(model)
				local npc = npcsByModel[model]
				if npc then
					npcsByModel[model] = nil
					if not npc.removeing then
						npc:remove()
					end
				end
			end
		})
	end
	do
		local iiTagData = {}
		function CollectionManager:GetInanimateInteractables()
			return iiTagData
		end
		CollectionManager:CreateBehaviorForTag("InanimateInteract", {
			WorkspaceOnly = true,
			OnInstanceAdded = function(tag)
				if not tag:IsA("StringValue") then
					return
				end
				local model = tag.Parent
				local main = model:FindFirstChild("Main")
				if main then
					iiTagData[tag] = {
						model = model,
						main = main,
						kind = tag.Value
					}
				end
			end,
			OnInstanceRemoved = function(tag)
				iiTagData[tag] = nil
			end
		})
	end
	do
		local ambientSoundsEnabled = false
		function CollectionManager:SetAmbientSoundsEnabled(enabled)
			if ambientSoundsEnabled == enabled then
				return
			end
			ambientSoundsEnabled = enabled
			for _, sound in ipairs(CollectionService:GetTagged("AmbientSound")) do
				if sound:IsA("Sound") and sound:IsDescendantOf(workspace) then
					if enabled then
						if not sound.IsPlaying then
							sound:Play()
						end
					elseif sound.IsPlaying then
						sound:Stop()
					end
				end
			end
		end
		CollectionManager:CreateBehaviorForTag("AmbientSound", {
			WorkspaceOnly = true,
			OnInstanceAdded = function(sound)
				if sound:IsA("Sound") then
					if ambientSoundsEnabled then
						if not sound.IsPlaying then
							sound:Play()
						end
					elseif sound.IsPlaying then
						sound:Stop()
					end
				end
			end
		})
	end
	return CollectionManager
end
