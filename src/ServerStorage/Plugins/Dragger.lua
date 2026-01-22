return function(_p)
	local Utilities = _p.Utilities
	local mouse = _p.player:GetMouse()
	local UserInputService = game:GetService("UserInputService")
	local currentlyDragging

	-- Class representing an object that can be dragged around
	local dragger = Utilities.class({
		clickEnabled = false, -- Whether the drag should only start after the mouse has been moved a certain distance
		dragging = false, -- Whether the object is currently being dragged
		className = "Dragger"
	}, function(self)
		if type(self) == "userdata" then
			self = {gui = self}
		end
		local guiObject = self.gui
		self.onDragBegin = Utilities.Signal() -- Signal that fires when the object starts being dragged
		self.onDragMove = Utilities.Signal() -- Signal that fires whenever the mouse moves while dragging the object
		self.onDragEnd = Utilities.Signal() -- Signal that fires when the object stops being dragged
		self.onClick = Utilities.Signal() -- Signal that fires when the object is clicked (only if clickEnabled is true)

		-- Connect to the InputBegan event of the GUI object to start dragging when the mouse button is clicked or a touch input begins
		if guiObject:IsA("GuiObject") then
			guiObject.InputBegan:Connect(function(inputObject)
				if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch and inputObject.UserInputState == Enum.UserInputState.Begin then
					self:beginDrag()
				end
			end)
		end
		return self
	end)

	-- Start dragging the object
	function dragger:beginDrag()
		-- If there is already a dragger being dragged, end the drag
		if currentlyDragging then
			currentlyDragging:endDrag()
		end
		currentlyDragging = self
		self.endCn = UserInputService.InputEnded:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
				self:endDrag()
			end
		end)
		self.dragging = true

		-- Record the initial mouse position when the drag begins
		local mouseStartX, mouseStartY = mouse.X, mouse.Y
		self.dragStartPosition = Vector2.new(mouseStartX, mouseStartY)

		-- Initialize variables for click threshold and whether the threshold has been broken
		local threshold
		local brokenThreshold = false

		-- If clickEnabled is true, set the threshold and initialize brokenThreshold to false
		local clickEnabled = self.clickEnabled or false
		if clickEnabled then
			self.brokenThreshold = false
			threshold = self.clickThresholdExact or Utilities.gui.AbsoluteSize.Y * (self.clickThreshold or 0.03)
		end

		-- Connect a function to the mouse's Move event to handle drag movement
		self.moveCn = mouse.Move:Connect(function()
			-- Calculate the offset of the mouse from its initial position
			local offset = Vector2.new(mouse.X - mouseStartX, mouse.Y - mouseStartY)

			-- If clickEnabled is true and the threshold has not yet been broken, check if the threshold has been exceeded
			if clickEnabled and not brokenThreshold then
				if offset.magnitude < threshold then
					return
				end
				-- If the threshold has been exceeded, set brokenThreshold to true and fire the onDragBegin event
				brokenThreshold = true
				self.brokenThreshold = true
				self.onDragBegin:fire(offset)
				return
			end
			self.onDragMove:fire(offset)
		end)
		if not clickEnabled then
			self.brokenThreshold = true
			self.onDragBegin:fire(Vector2.new())
		end
	end

	function dragger:endDrag()
		-- Disconnect the InputEnded and mouse.Move events
		if self.endCn then
			self.endCn:Disconnect()
			self.endCn = nil
		end
		if self.moveCn then
			self.moveCn:Disconnect()
			self.moveCn = nil
		end

		-- Reset the currentlyDragging variable if it is set to this dragger
		if currentlyDragging == self then
			currentlyDragging = nil
		end

		-- Return if the dragger was not dragging
		if not self.dragging then
			return
		end

		-- If the clickEnabled flag is set and the threshold has not been broken,
		-- fire the onClick signal. Otherwise, fire the onDragEnd signal.
		if self.clickEnabled and not self.brokenThreshold then
			self.onClick:fire()
		else
			self.onDragEnd:fire()
		end

		-- Reset the dragging flag
		self.dragging = false
	end
	return dragger
end
