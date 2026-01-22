return function(_p)
--local _p = require(script.Parent)
local Utilities = _p.Utilities

-- change autosave settings (intervals, etc.) for battle colosseum / trade resort?

local autosave = {
	enabled = false
}

local AUTOSAVE_INTERVAL = 2 * 60
local AUTOSAVE_SHORT_INTERVAL = 30

local lastSuccessfulAutosave = 0


-- ui
function autosave:animateSuccessfulAutosave()
	spawn(function()
		local create = Utilities.Create
		local floppy = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5119877152',
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(-0.05, 0, -0.05, 0),
			Position = UDim2.new(1.0, -20, 1.0, -20),
			ZIndex = 7, Parent = Utilities.frontGui,
		}
		local check = create 'ImageLabel' {
			BackgroundTransparency = 1.0,
			Image = 'rbxassetid://5119875359',
			ImageColor3 = Color3.new(124/255, 186/255, 99/255),
			ZIndex = 8, Parent = floppy,
		}
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			floppy.ImageTransparency = 1-a
			check.ImageRectSize = Vector2.new(450*a, 450)
			check.Size = UDim2.new(a, 0, 1.0, 0)
		end)
		wait(1)
		Utilities.Tween(.5, 'easeOutCubic', function(a)
			floppy.ImageTransparency = a
			check.ImageTransparency = a
		end)
		floppy:remove()
	end)
end
--

	function autosave:canSave()
		-- Check if the menu is enabled, if the player is allowed to walk, if there is no NPC chatbox active, and if there is no current battle
		return _p.Menu.enabled and _p.MasterControl.WalkEnabled and (not _p.NPCChat.chatBox or not _p.NPCChat.chatBox.Parent) and not _p.Battle.currentBattle
	end

	do
		local currentQueuedSaveThread
	
		function autosave:queueSave()
			-- If autosave is not enabled or if there is already a save thread queued, return without doing anything
			if not self.enabled or currentQueuedSaveThread then return end

			-- Create a reference to this save thread
			local thisThread = {}
			currentQueuedSaveThread = thisThread

			Utilities.fastSpawn(function()
				-- Wait until it is possible to save
				while not self:canSave() do
					wait(2)

					-- If autosave is no longer enabled, return from this thread
					if not self.enabled then return end
				end

				-- Reset the reference to the current save thread
				currentQueuedSaveThread = nil
			end)
		end
	end

--[[
This function attempts to save the player data and returns a boolean indicating success or failure.
If the save is successful, it updates the timestamp for the last successful autosave and removes
the "willOverwriteIfSave" flag from the menu. It also calls a function to animate a successful
save.
]]--
	function autosave:attemptSave()
		if not self:canSave() then return false end
		local success = _p.PlayerData:save()
		if success then
			lastSuccessfulAutosave = tick()
			-- _p.DataManager:commitPermanentKeys()
			_p.Menu.willOverwriteIfSaveFlag = nil
			self:animateSuccessfulAutosave()
		end
		return success
	end

--function autosave:tryEnable()
--	if _p.Menu.willOverwriteIfSaveFlag then
--		--
--	end
--end

	function autosave:enable()
		_p.DataManager:preload(5119877152, 5119875359)
		self.enabled = true
		delay(AUTOSAVE_SHORT_INTERVAL, function()
			while self.enabled do
				local et = tick()-lastSuccessfulAutosave
				if et < AUTOSAVE_INTERVAL-1 then
					-- Wait until it has been at least AUTOSAVE_INTERVAL seconds since the last successful autosave
					wait(AUTOSAVE_INTERVAL-et)
				end
				if not self.enabled then return end
				if self:canSave() then
					local success = self:attemptSave()
					if success then
						-- Wait until it has been at least AUTOSAVE_INTERVAL seconds since the last successful autosave before attempting another save
						wait(AUTOSAVE_INTERVAL)
					else
						-- notify player on-screen that an attempted autosave failed
						-- (but not every single short interval after the first failure)
						wait(AUTOSAVE_SHORT_INTERVAL)
					end
				else
					-- perhaps shorten the interval the longer it's been since a successful autosave
					-- (in case our timing has just been bad [e.g. player has opened menu on interval] up until now)
				wait(AUTOSAVE_SHORT_INTERVAL)
			end
		end
	end)
end

function autosave:disable()
	self.enabled = false
end


return autosave end