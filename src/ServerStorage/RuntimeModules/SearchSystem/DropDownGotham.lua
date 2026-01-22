return function(_p)
	local Utilities = _p.Utilities
	local Create = Utilities.Create
	local Enum_Font_GothamBold = Enum.Font.GothamBold
	local DropDownGotham = Utilities.class({}, function(ParentObj, OptionList, Hue)
		local DrpDwn = {
			options = OptionList, 
			value = OptionList[1], 
			valueIndex = 1, 
			changed = Utilities.Signal()
		}
		local OptProperties = {
			AutoButtonColor = false, 
			BorderSizePixel = 0, 
			BackgroundColor3 = Color3.fromHSV(Hue, 0.821, 0.725), 
			Text = DrpDwn.value, 
			Font = Enum_Font_GothamBold, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextXAlignment = Enum.TextXAlignment.Left, 
			TextScaled = true, 
			ZIndex = 5, 
			Parent = ParentObj
		}
		function OptProperties.MouseButton1Click()
			local ImageButton = Create("ImageButton")({
				AutoButtonColor = false, 
				BorderSizePixel = 0, 
				BackgroundColor3 = Color3.new(0, 0, 0), 
				BackgroundTransparency = 0.6, 
				Size = UDim2.new(1, 0, 1, 36), 
				Position = UDim2.new(0, 0, 0, -36), 
				ZIndex = 13, 
				Parent = Utilities.simulatedCoreGui
			})
			local a = Utilities.gui.AbsoluteSize.Y * 0.03
			local AbsoluteSize = DrpDwn.mainButton.AbsoluteSize
			local AbsolutePosition = DrpDwn.mainButton.AbsolutePosition
			local scrollFrame = Create("ScrollingFrame")({
				BorderColor3 = Color3.fromHSV(Hue, 0.491, 0.208), 
				BorderSizePixel = 2, 
				BackgroundColor3 = Color3.fromHSV(Hue, 0.822, 0.73), 
				ScrollBarThickness = a, 
				TopImage = "rbxassetid://3763595294", 
				MidImage = "rbxassetid://3763596048", 
				BottomImage = "rbxassetid://3763596631", 
				ScrollBarImageTransparency = 0.3, 
				ScrollBarImageColor3 = Color3.fromRGB(24, 24, 24), 
				ScrollingDirection = Enum.ScrollingDirection.Y, 
				Size = UDim2.new(0, AbsoluteSize.X, 0.3, 0), 
				Position = UDim2.new(0, AbsolutePosition.X, 0, AbsolutePosition.Y), 
				ZIndex = 14, 
				Parent = Utilities.simulatedCoreGui
			})
			local Frame = Create("Frame")({
				BackgroundTransparency = 1, 
				SizeConstraint = Enum.SizeConstraint.RelativeXX, 
				Size = UDim2.new(1, -a, 1, -a), 
				Parent = scrollFrame
			})
			scrollFrame.CanvasSize = UDim2.new(0, AbsoluteSize.X - 1, 0, AbsoluteSize.Y * #DrpDwn.options)
			if AbsoluteSize.Y * #DrpDwn.options < scrollFrame.AbsoluteSize.Y then
				scrollFrame.Size = scrollFrame.CanvasSize
			end
			if Utilities.gui.AbsoluteSize.Y < scrollFrame.AbsolutePosition.Y + scrollFrame.AbsoluteSize.Y then
				scrollFrame.Position = UDim2.new(0, AbsolutePosition.X, 0, Utilities.gui.AbsoluteSize.Y - scrollFrame.AbsoluteSize.Y)
			end

			for i, v in pairs(DrpDwn.options) do
				Create("TextButton")({
					AutoButtonColor = false, 
					BorderSizePixel = 0, 
					BackgroundColor3 = DrpDwn.value == v and Color3.fromHSV(Hue, 0.9, 0.5) or Color3.fromHSV(Hue, 0.822, 0.73), 
					Size = UDim2.new(1, 0, 0, AbsoluteSize.Y), 
					Position = UDim2.new(0, 0, 0, AbsoluteSize.Y * (i - 1)), 
					Text = v, 
					Font = Enum_Font_GothamBold, 
					TextColor3 = Color3.new(1, 1, 1), 
					TextXAlignment = Enum.TextXAlignment.Left, 
					TextScaled = true, 
					ZIndex = 15, 
					Parent = Frame,
					MouseButton1Click = function()
						scrollFrame:Destroy()
						ImageButton:Destroy()
						DrpDwn.value = v
						DrpDwn.valueIndex = i
						DrpDwn.mainButton.Text = v
						DrpDwn.changed:fire(v, i)
					end
				})	
			end

			ImageButton.MouseButton1Click:connect(function()
				scrollFrame:Destroy()
				ImageButton:Destroy()
			end)
		end
		DrpDwn.mainButton = Create("TextButton")(OptProperties)
		return DrpDwn
	end)
	function DropDownGotham:setSize(Size)
		self.mainButton.Size = Size
	end
	function DropDownGotham:setPosition(Pos)
		self.mainButton.Position = Pos
	end
	function DropDownGotham:setValue(Options)
		self.value = self.options[Options]
		self.valueIndex = Options
		self.mainButton.Text = self.value
	end
	function DropDownGotham:setOptions(Options, Index)
		self.options = Options
		self.value = Options[Index]
		self.valueIndex = Index
		self.mainButton.Text = self.value
	end
	function DropDownGotham:destroy()
		self.mainButton:Destroy()
	end
	return DropDownGotham
end
