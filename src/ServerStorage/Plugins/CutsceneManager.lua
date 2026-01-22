--SynapseX Decompiler

return function(_p)
	local CutsceneManager = {InCutscene = false}
	function CutsceneManager:StartCutscene()
		self.InCutscene = true
		_p.Network:post("PDS", "startCutscene")
	end
	function CutsceneManager:EndCutscene(...)
		self.InCutscene = false
		_p.Network:post("PDS", "endCutscene", ...)
	end
	function CutsceneManager:HideOtherPlayers()
		if self.showPlayersCallback then
			return
		end
		_p.DataManager.OtherPlayerPetsFolder.Parent = nil
		local hiddenParts = {}
		local disabledEffects = {}
		local effectTypes = {
			Fire = true,
			Smoke = true,
			Sparkles = true,
			ParticleEmitter = true
		}
		local connections = {}
		local function addObject(obj)
			if hiddenParts[obj] or disabledEffects[obj] then
				return
			end
			if obj:IsA("BasePart") or obj:IsA("Decal") then
				hiddenParts[obj] = true
				obj.LocalTransparencyModifier = 1
			elseif (obj:IsA("Light") or effectTypes[obj.ClassName]) and obj.Enabled then
				disabledEffects[obj] = true
				obj.Enabled = false
			end
		end
		local function newCharacter(char)
			if not char then
				return
			end
			wait()
			table.insert(connections, char.DescendantAdded:Connect(addObject))
			for _, obj in ipairs(char:GetDescendants()) do
				addObject(obj)
			end
		end
		local function newPlayer(p)
			if p == _p.player or not p:IsA("Player") then
				return
			end
			table.insert(connections, p.CharacterAdded:Connect(newCharacter))
			newCharacter(p.Character)
		end
		local players = game:GetService("Players")
		table.insert(connections, players.ChildAdded:Connect(newPlayer))
		spawn(function()
			for _, p in ipairs(players:GetChildren()) do
				newPlayer(p)
			end
		end)
		local bubbleChatContainer
		do
			local playerGui = _p.player:FindFirstChild("PlayerGui")
			if playerGui then
				bubbleChatContainer = playerGui:FindFirstChild("BubbleChat")
				if bubbleChatContainer then
					local function bubbleChatObj(obj)
						if obj:IsA("BillboardGui") then
							obj.Enabled = false
							table.insert(connections, obj:GetPropertyChangedSignal("Enabled"):Connect(function()
								obj.Enabled = false
							end))
						end
					end
					table.insert(connections, bubbleChatContainer.ChildAdded:Connect(bubbleChatObj))
					for _, ch in ipairs(bubbleChatContainer:GetChildren()) do
						bubbleChatObj(ch)
					end
				end
			end
		end
		function self.showPlayersCallback()
			for _, cn in ipairs(connections) do
				pcall(function()
					cn:Disconnect()
				end)
			end
			connections = nil
			wait()
			for p in pairs(hiddenParts) do
				p.LocalTransparencyModifier = 0
			end
			for e in pairs(disabledEffects) do
				e.Enabled = true
			end
			if bubbleChatContainer then
				for _, obj in ipairs(bubbleChatContainer:GetChildren()) do
					if obj:IsA("BillboardGui") then
						obj.Enabled = true
					end
				end
			end
		end
	end
	function CutsceneManager:ShowOtherPlayers()
		if self.showPlayersCallback then
			self.showPlayersCallback()
			self.showPlayersCallback = nil
		end
		_p.DataManager.OtherPlayerPetsFolder.Parent = workspace
	end
	return CutsceneManager
end
