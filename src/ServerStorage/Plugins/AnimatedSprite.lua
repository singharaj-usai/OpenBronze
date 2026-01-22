-- Animated Sprites v3.3
return function(_p)

	-- Create a connection to the Stepped event
	local stepped = game:GetService('RunService').Stepped
	local steppedConnection

	-- Create a table to store active animations
	local active_animations = {}

	-- Define the prefix for asset URLs
	local urlPrefix = 'rbxassetid://'

	-- Define the AnimatedSprite class
	local animation = _p.Utilities.class({
		className = 'AnimatedSprite',
		-- The border is the size of the gap between each frame
		border = 1,
		-- The start pixel Y is the vertical position of the first frame in the spritesheet
		startPixelY = 0,
		-- The speed is the number of seconds between each frame
		speed = 0.03,
		-- The paused flag indicates whether the animation is currently paused
		paused = true,
		-- The start time is the time when the animation was last started or unpaused
		startTime = 0,
		-- The current frame is the index of the current frame being displayed
		currentFrame = 0,
		-- The number of caches is the number of copies of the spritesheet that are displayed to reduce flicker
		nCaches = 0,
	}, function (o)
		-- Initialize a new AnimatedSprite instance
		local n = {spriteData = o, startTime = tick()}

		-- Create a label to display the sprite
		local spriteLabel = Instance.new(o.button and 'ImageButton' or 'ImageLabel')
		spriteLabel.BackgroundTransparency = 1
		spriteLabel.Size = UDim2.new(1.0, 0, 1.0, 0)
		spriteLabel.ImageRectSize = Vector2.new(o.fWidth, o.fHeight)

		-- Set the sprite label as a property of the new instance
		n.spriteLabel = spriteLabel

		-- If the sprite has more than one sheet, create a cache to reduce flicker
		if #o.sheets > 1 then
			n.nCaches = 1

			local cache = Instance.new('ImageLabel', spriteLabel)
			cache.ImageTransparency = 0.9
			cache.Image = urlPrefix..o.sheets[1].id
			cache.BackgroundTransparency = 1
			cache.Size = UDim2.new(0.0, 1, 0.0, 1)

			n.cache = cache
		end

		return n
	end)

	animation.New = animation.new


	-- IMPORTANT - complete steps in this order:
	-- Call AnimatedSprite:New()
	-- Parent the new animation object's spriteLabel
	-- Invoke :Play() on the animation object
	-- 
	-- If the spriteLabel ever does not have a parent (while
	-- playing), the animation will automatically clean itself
	-- up. If for some reason you decide to de-parent it and
	-- wish to keep it, one way to do this, albeit hacky, is
	-- to parent it to an arbitrary object which does not have
	-- a parent. This, however, will cause the animation to
	-- still update its image each heartbeat. If this
	-- functionality is legitimately needed at some point, I
	-- will write API for it.

	-- Declare a function to update the frame of an animation
	local updateFrameFunction

	-- Define a function to update all active animations
	local function update()
		-- If there are no active animations, disconnect from the Stepped event and clear the connection variable
		if #active_animations == 0 then
			steppedConnection:disconnect()
			steppedConnection = nil
			return
		end

		-- Iterate through all active animations
		for _, a in pairs(active_animations) do
			-- Update the frame of the current animation
			updateFrameFunction(a)
		end
	end

	-- Define a method to play the animation
	function animation:Play(speed)
		-- If the animation is not paused, do nothing
		if not self.paused then return end
		-- Set the relative speed of the animation
		self.relativeSpeed = speed or 1
		-- Set the paused flag to false
		self.paused = false
		-- If there is a pause offset, use it to update the start time
		if self.pauseOffset then
			self.startTime = tick()-self.pauseOffset
			self.pauseOffset = nil
		end
		-- Check if the animation is already in the active_animations table
		for _, a in pairs(active_animations) do
			if self == a then return end
		end

		-- If the frame data has not been generated yet, generate it
		if not self.frameData then
			local f = 0 -- f is the current frame index
			local sd = self.spriteData -- sd is the sprite data
			local fd = {} -- fd is the frame data table
			for sheetNumber, sheet in pairs(sd.sheets) do -- Iterate through each sheet
				local framesBeforeSheet = f -- The number of frames before this sheet
				local f_end = f + sheet.rows * sd.framesPerRow -- The index of the last frame in this sheet
				for frame = f, math.min(f_end, sd.nFrames)-1 do -- Iterate through each frame in the sheet
					local frameNumberSheet = frame - framesBeforeSheet -- The index of the current frame within the sheet
					local col, row = frameNumberSheet % sd.framesPerRow, math.floor(frameNumberSheet / sd.framesPerRow) -- Calculate the column and row of the current frame
					local cacheId
					-- If the number of caches is greater than 0, set the cache ID
					if self.nCaches > 0 then
						if sheetNumber == #sd.sheets then
							cacheId = sd.sheets[1].id
						else
							cacheId = sd.sheets[sheetNumber + 1].id
						end
					end
					fd[frame+1] = {
						urlPrefix..sheet.id,
						Vector2.new(col*(sd.fWidth+(sd.border or self.border)), row*(sd.fHeight+(sd.border or self.border))+(sheet.startPixelY or self.startPixelY)),
						(cacheId and urlPrefix..cacheId or nil)
					}
				end
				f = f_end
			end
			self.frameData = fd
		end

		table.insert(active_animations, self)
		if not steppedConnection then
			steppedConnection = stepped:connect(update)
		end
	end

	function animation:Pause()
		-- Don't do anything if the animation is already paused
		if self.paused then return end

		-- Mark the animation as paused
		self.paused = true

		-- Calculate the amount of time that has passed since the animation started
		self.pauseOffset = tick() - self.startTime

		-- Remove the animation from the list of active animations
		for i = #active_animations, 1, -1 do
			if active_animations[i] == self then
				table.remove(active_animations, i)
			end
		end

		-- Disconnect the update function if there are no more active animations
		if #active_animations == 0 then
			steppedConnection:disconnect()
			steppedConnection = nil
		end
	end


	-- Function that updates the frame of the animation
	function animation:UpdateFrame()
		-- If the animation is paused, do nothing
		if self.paused then return end

		-- Get the sprite label object
		local sl = self.spriteLabel

		-- If the sprite label has been removed from the parent, remove the animation from the active animations list
		if not sl.Parent then
			self:remove()
			return
		end

		-- If the sprite label is not visible, do nothing
		if not sl.Visible then return end

		-- Get the sprite data and frame number for the current time
		local sd = self.spriteData
		local frameNumber = math.floor((tick()-self.startTime)/(sd.speed or self.speed)*self.relativeSpeed) % sd.nFrames + 1

		-- If the frame hasn't changed, do nothing
		if frameNumber == self.currentFrame then return end

		-- Update the current frame number and the sprite label's image and image rect offset based on the frame data
		self.currentFrame = frameNumber
		local fd = self.frameData[frameNumber]
		sl.Image = fd[1]
		sl.ImageRectOffset = fd[2]

		-- If there is a cache, update its image as well
		if fd[3] then
			self.cache.Image = fd[3]
		end

		-- If there is an update callback function, call it with the current frame number as a proportion of the total number of frames
		if self.updateCallback then
			self.updateCallback(frameNumber / sd.nFrames)
		end
	end

	-- Set the updateFrameFunction to be the UpdateFrame function of the animation class
	updateFrameFunction = animation.UpdateFrame

	function animation:RenderFirstFrame()
		-- get the ImageLabel object for the sprite and the sprite data
		local spriteLabel = self.spriteLabel
		local spriteData = self.spriteData
		-- get the first sheet of the sprite
		local firstSheet = spriteData.sheets[1]

		-- set the ImageLabel object's image to the first sheet
		spriteLabel.Image = urlPrefix..firstSheet.id

		-- set the ImageLabel object's ImageRectOffset to the starting pixel Y of the first sheet
		spriteLabel.ImageRectOffset = Vector2.new(0, firstSheet.startPixelY or 0)
	end

	function animation:remove()
		-- Remove the animation from the active animations list
		for i = #active_animations, 1, -1 do
			if active_animations[i] == self then
				table.remove(active_animations, i)
			end
		end

		-- Remove the sprite label associated with the animation
		pcall(function() self.spriteLabel:remove() end)

		-- Clear the frame data and other properties of the animation object
		for i in pairs(self.frameData) do
			self.frameData[i] = nil
		end
		for i in pairs(self) do
			self[i] = nil
		end
	end

	return animation end