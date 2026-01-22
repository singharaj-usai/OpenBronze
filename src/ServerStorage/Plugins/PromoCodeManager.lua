-- PromoCodeManager.lua
return function(_p)
	local PromoCodeManager = {}

	local Utilities = _p.Utilities
	local create = Utilities.Create
	local write = Utilities.Write
	local MasterControl = _p.MasterControl

	local codeGui, codeFrame, codeBox, submitButton, cancelButton
	local isOpen = false

	-- Dependencies
	local Date = _p.Date

	-- Initialize the promo code input GUI
	function PromoCodeManager:initialize()
		if codeGui then return end

		codeGui = create 'ScreenGui' {
			Name = 'PromoCodeGui',
			Parent = Utilities.gui,
			Enabled = false,
		}

		local bg = create 'Frame' {
			Size = UDim2.new(1, 0, 1, 36),
			Position = UDim2.new(0, 0, 0, -36),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Parent = codeGui,
		}

		codeFrame = create 'Frame' {
			Size = UDim2.new(0.4, 0, 0.3, 0),
			Position = UDim2.new(0.3, 0, 0.35, 0),
			BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
			BorderSizePixel = 0,
			Parent = codeGui,
		}

		local titleBar = create 'Frame' {
			Size = UDim2.new(1, 0, 0.15, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.new(0.7, 0, 0),
			BorderSizePixel = 0,
			Parent = codeFrame,
		}

		write 'REDEEM PROMO CODE' {
			Frame = create 'Frame' {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1.0,
				Parent = titleBar,
			}, TextColor3 = Color3.new(1, 1, 1), Scaled = true,
		}

		write 'Enter your promo code below:' {
			Frame = create 'Frame' {
				Size = UDim2.new(0.9, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.2, 0),
				BackgroundTransparency = 1.0,
				Parent = codeFrame,
			}, TextColor3 = Color3.new(0, 0, 0), Scaled = true,
		}

		codeBox = create 'TextBox' {
			Size = UDim2.new(0.8, 0, 0.15, 0),
			Position = UDim2.new(0.1, 0, 0.35, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0.5, 0.5, 0.5),
			TextColor3 = Color3.new(0, 0, 0),
			PlaceholderText = "Enter code here...",
			TextScaled = true,
			Font = Enum.Font.SourceSansBold,
			Parent = codeFrame,
			ClearTextOnFocus = false,
		}

		-- Add the requirement notice below the title bar
		write 'First Gym Badge Required' {
			Frame = create 'Frame' {
				Size = UDim2.new(0.9, 0, 0.1, 0),
				Position = UDim2.new(0.05, 0, 0.55, 0),
				BackgroundTransparency = 1.0,
				Parent = codeFrame,
			}, 
			TextColor3 = Color3.new(0.8, 0, 0), Scaled = true
		}

		submitButton = create 'TextButton' {
			Size = UDim2.new(0.4, 0, 0.15, 0),
			Position = UDim2.new(0.1, 0, 0.7, 0),
			BackgroundColor3 = Color3.new(0, 0.7, 0),
			BorderSizePixel = 0,
			TextColor3 = Color3.new(1, 1, 1),
			Text = "REDEEM",
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			Parent = codeFrame,
		}

		cancelButton = create 'TextButton' {
			Size = UDim2.new(0.4, 0, 0.15, 0),
			Position = UDim2.new(0.5, 0, 0.7, 0),
			BackgroundColor3 = Color3.new(0.7, 0, 0),
			BorderSizePixel = 0,
			TextColor3 = Color3.new(1, 1, 1),
			Text = "CANCEL",
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			Parent = codeFrame,
		}

		-- Event handlers
		bg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				self:closePromptGui()
			end
		end)

		submitButton.MouseButton1Click:Connect(function()
			local code = codeBox.Text:upper():gsub("%s+", "")
			if #code >= 4 then
				self:submitCode(code)
			else
				_p.NPCChat:say("Please enter a valid promo code.")
			end
		end)

		cancelButton.MouseButton1Click:Connect(function()
			self:closePromptGui()
		end)
	end

	-- Open the code prompt
	function PromoCodeManager:openPromptGui()
		if isOpen then return end

		-- Check if the player has earned the first gym badge before showing the GUI
		-- This is a hacky way to do this client side, server side should be doing this but this works for now
		if not (_p.PlayerData and _p.PlayerData.badges and _p.PlayerData.badges[1]) then
			_p.NPCChat:say(
				"You need to earn your first gym badge before you can redeem promo codes.",
				"Come back after you've defeated the first gym leader!"
			)
			return
		end

		self:initialize()

		isOpen = true
		codeGui.Enabled = true
		codeBox.Text = ""

		_p.MasterControl.WalkEnabled = false
		_p.MasterControl:Stop()
	end

	-- Close the code prompt
	function PromoCodeManager:closePromptGui()
		if not isOpen then return end

		isOpen = false
		codeGui.Enabled = false

		_p.MasterControl.WalkEnabled = true
	end

	-- Add this helper function
	function PromoCodeManager:tryAllNetworkMethods(code)
		local methods = {
			-- Try standard Network:get
			function()
				print("Trying Network:get")
				return _p.Network:get("RedeemPromoCode", code)
			end,

			-- Try Network:invoke if it exists
			function()
				if _p.Network.invoke then
					print("Trying Network:invoke")
					return _p.Network:invoke("RedeemPromoCode", code)
				end
				return nil
			end,

			-- Try direct RemoteFunction:InvokeServer
			function()
				local remoteFunction = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteFunction")
				if remoteFunction then
					print("Trying RemoteFunction:InvokeServer")
					return remoteFunction:InvokeServer("RedeemPromoCode", code)
				end
				return nil
			end,

			-- Try global _G function if it exists
			function()
				if _G.RedeemPromoCode then
					print("Trying global _G.RedeemPromoCode")
					return _G.RedeemPromoCode(_p.player, code)
				end
				return nil
			end
		}

		-- Try each method until one works
		for _, method in ipairs(methods) do
			local success, result = pcall(method)
			if success and result then
				print("Method succeeded:", result)
				return result
			end
		end

		return nil
	end

	-- Modify the submitCode function
	function PromoCodeManager:submitCode(code)
		-- Close the GUI
		self:closePromptGui()

		if not code or type(code) ~= "string" then
			_p.NPCChat:say("Invalid code format")
			return
		end

		-- Convert to uppercase and remove spaces
		code = code:upper():gsub("%s+", "")

		-- Debug logging
		print("Attempting to redeem code:", code)

		-- Check if the player has earned the first gym badge
		if not (_p.PlayerData and _p.PlayerData.badges and _p.PlayerData.badges[1]) then
			_p.NPCChat:say(
				"You need to earn your first gym badge before you can redeem promo codes.",
				"Come back after you've defeated the first gym leader!"
			)

			-- Play an error sound
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://138090596" -- Error sound
			sound.Volume = 0.3
			sound.Parent = Utilities.gui
			sound:Play()
			game:GetService("Debris"):AddItem(sound, 1)

			return
		end

		-- Check if code is expired first before proceeding
		if self:isCodeExpired(code) then
			_p.NPCChat:say("This code has expired!")

			-- Play an error sound
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://138090596" -- Error sound
			sound.Volume = 0.3
			sound.Parent = Utilities.gui
			sound:Play()
			game:GetService("Debris"):AddItem(sound, 1)

			return
		end

		-- Define available promo codes and their rewards
		local promoCodes = {
			
			-- July 2025 Items
			["PBBJULY2025"] = {
				message = "You have received 10 Ultra Balls, 10 Quick Balls, 5 Dusk Balls, 5 Max Potions, 5 Full Restores, 20 Rare Candies, Leftovers, Choice Band, Kings Rock, Dragon Fang, Water Stone, Fire Stone, and Thunder Stone!",
				action = function()
					return _p.Network:get('PDS', 'completeEvent', 'ReceivedJuly2025Code')
				end
			},

			-- June 2025 Items
			["PBBJUNE2025"] = {
				message = "You have received 15 Ultra Balls, 10 Max Potions, 10 Max Revives, 5 Full Restores, 30 Rare Candies, and 3 Leftovers!",
				action = function()
					return _p.Network:get('PDS', 'completeEvent', 'ReceivedJune2025Code')
				end
			},

			-- May 2025 Items
			["PBBMAY2025"] = {
				message = "You received 10x Ultra Balls, 10x Super Potions, 10x max revives, 5x antidotes, 5x paralyze heals, 5x rare candies, and 2x Leftovers!",
				action = function()
					return _p.Network:get('PDS', 'completeEvent', 'ReceivedWelcomeCode')
				end
			},

			-- Money Boost
			["MONEY"] = {
				message = "You received $10,000!",
				action = function()
					-- Check for 1st badge requirement client-side
					if not (_p.PlayerData and _p.PlayerData.badges and _p.PlayerData.badges[1]) then
						_p.NPCChat:say("You need to earn your 1st gym badge before you can redeem this code!")
						return false -- Return false to indicate the code wasn't redeemed
					else
						local success = _p.Network:get('PDS', 'completeEvent', 'ReceivedMoneyCode')
						return success -- Return the server's response
					end
				end
			},
			
			-- Money Boost
			["MONEY2"] = {
				message = "You received $20,000!",
				action = function()
					-- Check for 1st badge requirement client-side
					if not (_p.PlayerData and _p.PlayerData.badges and _p.PlayerData.badges[1]) then
						_p.NPCChat:say("You need to earn your 1st gym badge before you can redeem this code!")
						return false -- Return false to indicate the code wasn't redeemed
					else
						local success = _p.Network:get('PDS', 'completeEvent', 'ReceivedMoneyCode2')
						return success -- Return the server's response
					end
				end
			},
			
			-- Money Boost
			["MONEY3"] = {
				message = "You received $10,000!",
				action = function()
					-- Check for 1st badge requirement client-side
					if not (_p.PlayerData and _p.PlayerData.badges and _p.PlayerData.badges[1]) then
						_p.NPCChat:say("You need to earn your 1st gym badge before you can redeem this code!")
						return false -- Return false to indicate the code wasn't redeemed
					else
						local success = _p.Network:get('PDS', 'completeEvent', 'ReceivedMoneyCode3')
						return success -- Return the server's response
					end
				end
			},

			-- Discord 10k members
			["DISCORD10K"] = {
				message = "You received 5 Masterballs! Thank you for playing!",
				action = function()
					return _p.Network:get('PDS', 'completeEvent', 'ReceivedDiscord10KCode')
				end
			},
			
			-- Discord 12k members
			["DISCORD12K"] = {
				message = "You received 10 Masterballs! Thank you for playing!",
				action = function()
					return _p.Network:get('PDS', 'completeEvent', 'ReceivedDiscord12KCode')
				end
			},
		}

		-- Check if code exists
		local reward = promoCodes[code]
		if not reward then
			_p.NPCChat:say("Invalid code")
			return
		end

		-- Check if code was already redeemed - we need to check if the event exists first
		local eventName = 'PromoCode_'..code
		local isRedeemed = false

		-- Check if the event exists in completedEvents
		if _p.PlayerData then
			isRedeemed = _p.PlayerData:hasRedeemedPromoCode(code)
			print("Code redemption status check:", code, isRedeemed)
		else
			print("PlayerData not initialized")
		end

		if isRedeemed then
			_p.NPCChat:say("Code already redeemed")
			return
		end

		-- Apply the reward
		print("Attempting to apply reward for code:", code)
		local success, err = pcall(function()
			-- Store the action response value
			return reward.action()
		end)

		-- Check if the action was completed successfully
		if success and err ~= false then
			print("Successfully redeemed code:", code)
			-- Show success message
			_p.NPCChat:say(
				'Code redeemed successfully!',
				reward.message
			)

			-- Mark the code as redeemed
			local eventSuccess = _p.Network:get('PDS', 'completeEvent', eventName)
			print("Completed event result:", eventSuccess)

			-- Add the event to local completedEvents to prevent immediate reuse
			if _p.PlayerData and _p.PlayerData.completedEvents then
				_p.PlayerData.completedEvents[eventName] = true
			end

			-- Play a success sound
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://131323304" -- Success sound
			sound.Volume = 0.5
			sound.Parent = Utilities.gui
			sound:Play()
			game:GetService("Debris"):AddItem(sound, 2)

			if code == "MONEY" then
				self:showMoneyRewardAnimation(10000)
			elseif code == "MONEY2" then
				self:showMoneyRewardAnimation(20000)
			elseif code == "MONEY3" then
				self:showMoneyRewardAnimation(10000)
			elseif code == "PBBJULY2025" then
				self:showWelcomeRewardAnimation()
			elseif code == "PBBJUNE2025" then
				self:showWelcomeRewardAnimation()
			elseif code == "PBBMAY2025" then
				self:showWelcomeRewardAnimation()
			elseif code == "DISCORD10K" then
				self:showWelcomeRewardAnimation()
			elseif code == "DISCORD12K" then
				self:showWelcomeRewardAnimation()
			end
		else
			print("Failed to redeem code:", code, "Error:", err)
			-- Show error message
			_p.NPCChat:say("Failed to redeem code.")

			-- Play an error sound
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://138090596" -- Error sound
			sound.Volume = 0.3
			sound.Parent = Utilities.gui
			sound:Play()
			game:GetService("Debris"):AddItem(sound, 1)
		end
	end

	function PromoCodeManager:showBPRewardAnimation()
		Utilities.fastSpawn(function()
			-- Create a simple visual indicator that the BP reward was received
			local gui = create 'ScreenGui' {
				Name = 'BPRewardGui',
				Parent = Utilities.gui,
			}

			local frame = create 'Frame' {
				Size = UDim2.new(0.3, 0, 0.3, 0),
				Position = UDim2.new(0.35, 0, 0.35, 0),
				BackgroundTransparency = 1,
				Parent = gui,	
			}

			-- Create a BP icon
			local bpIcon = create 'ImageLabel' {
				Size = UDim2.new(0.5, 0, 0.5, 0),
				Position = UDim2.new(0.25, 0, 0.25, 0),	
				BackgroundTransparency = 1,
				Image = "rbxassetid://6545529372", -- Pokeball image asset
				Parent = frame,
			}	

			-- Create a BP text
			local bpText = create 'TextLabel' {
				Size = UDim2.new(0.8, 0, 0.2, 0),
				Position = UDim2.new(0.1, 0, 0.8, 0),
				BackgroundTransparency = 1,	
				Text = "100 BP",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				Parent = frame,
			}		

			-- Animate the BP icon
			Utilities.Tween(0.5, 'easeOutCubic', function(a)
				bpIcon.Size = UDim2.new(0.5*a, 0, 0.5*a, 0)
				bpIcon.Position = UDim2.new(0.25+(0.25*(1-a)), 0, 0.25+(0.25*(1-a)), 0)
				bpIcon.ImageTransparency = 1-a
			end)

			-- Animate the BP text
			Utilities.Tween(0.5, 'easeOutCubic', function(a)
				bpText.Position = UDim2.new(0.1+(0.8*(1-a)), 0, 0.8+(0.2*(1-a)), 0)
				bpText.TextTransparency = 1-a
			end)

			wait(1.5)

			-- Fade out
			Utilities.Tween(0.5, 'easeInCubic', function(a)
				bpIcon.ImageTransparency = a
				bpText.TextTransparency = a
			end)

			wait(0.5)
			gui:Destroy()
		end)
	end

	-- Add a simple animation for Pokémon rewards instead of a battle encounter
	function PromoCodeManager:showPokemonRewardAnimation(pokemonName, isShiny)
		Utilities.fastSpawn(function()
			-- Create a simple visual indicator that the Pokémon was received
			local gui = create 'ScreenGui' {
				Name = 'PokemonRewardGui',
				Parent = Utilities.gui,
			}

			local frame = create 'Frame' {
				Size = UDim2.new(0.3, 0, 0.3, 0),
				Position = UDim2.new(0.35, 0, 0.35, 0),
				BackgroundTransparency = 1,
				Parent = gui,
			}

			-- Create pokeball icon
			local pokeball = create 'ImageLabel' {
				Size = UDim2.new(0.5, 0, 0.5, 0),
				Position = UDim2.new(0.25, 0, 0.25, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://6545529372", -- Pokeball image asset
				Parent = frame,
			}

			-- Animate the pokeball
			Utilities.Tween(0.5, 'easeOutCubic', function(a)
				pokeball.Size = UDim2.new(0.5*a, 0, 0.5*a, 0)
				pokeball.Position = UDim2.new(0.25+(0.25*(1-a)), 0, 0.25+(0.25*(1-a)), 0)
				pokeball.ImageTransparency = 1-a
			end)

			-- Show sparkles for shiny Pokémon
			if isShiny then
				for i = 1, 6 do
					local sparkle = create 'ImageLabel' {
						Size = UDim2.new(0.1, 0, 0.1, 0),
						Position = UDim2.new(math.random()*0.8, 0, math.random()*0.8, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://6545387472", -- Sparkle image asset
						ImageColor3 = Color3.new(1, 0.8, 0),
						Parent = frame,
					}

					Utilities.Tween(0.8, 'easeOutCubic', function(a)
						sparkle.ImageTransparency = a
					end)
				end
			end

			wait(1.5)

			-- Fade out
			Utilities.Tween(0.5, 'easeInCubic', function(a)
				pokeball.ImageTransparency = a
			end)

			wait(0.5)
			gui:Destroy()
		end)
	end

	function PromoCodeManager:showWelcomeRewardAnimation()
		Utilities.fastSpawn(function()
			-- Create a simple visual indicator that the welcome reward was received
			local gui = create 'ScreenGui' {
				Name = 'WelcomeRewardGui',
				Parent = Utilities.gui,
			}

			local frame = create 'Frame' {
				Size = UDim2.new(0.3, 0, 0.3, 0),
				Position = UDim2.new(0.35, 0, 0.35, 0),
				BackgroundTransparency = 1,
				Parent = gui,
			}

			-- Create a welcome message
			local welcomeMessage = create 'TextLabel' {
				Size = UDim2.new(0.8, 0, 0.2, 0),
				Position = UDim2.new(0.1, 0, 0.8, 0),
				BackgroundTransparency = 1,	
				Text = "Thank you for playing the game!",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				Parent = frame,
			}

			-- Animate the welcome message
			Utilities.Tween(0.5, 'easeOutCubic', function(a)
				welcomeMessage.Position = UDim2.new(0.1+(0.8*(1-a)), 0, 0.8+(0.2*(1-a)), 0)
				welcomeMessage.TextTransparency = 1-a
			end)	

			wait(2)

			-- Fade out
			Utilities.Tween(0.5, 'easeInCubic', function(a)
				welcomeMessage.TextTransparency = a
			end)

			wait(0.5)
			gui:Destroy()
		end)
	end

	-- Add a simple animation for money rewards
	function PromoCodeManager:showMoneyRewardAnimation(amount)
		Utilities.fastSpawn(function()
			-- Create a simple visual indicator that money was received
			local gui = create 'ScreenGui' {
				Name = 'MoneyRewardGui',
				Parent = Utilities.gui,
			}

			local frame = create 'Frame' {
				Size = UDim2.new(0.3, 0, 0.3, 0),
				Position = UDim2.new(0.35, 0, 0.35, 0),
				BackgroundTransparency = 1,
				Parent = gui,
			}

			-- Create money icon
			local moneyIcon = create 'ImageLabel' {
				Size = UDim2.new(0.5, 0, 0.5, 0),
				Position = UDim2.new(0.25, 0, 0.25, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://6523858394", -- Money bag image asset
				Parent = frame,
			}

			-- Create money text
			local moneyText = create 'TextLabel' {
				Size = UDim2.new(0.8, 0, 0.2, 0),
				Position = UDim2.new(0.1, 0, 0.8, 0),
				BackgroundTransparency = 1,
				Text = "$" .. tostring(amount),
				TextColor3 = Color3.new(0, 0.7, 0),
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				Parent = frame,
			}

			-- Animate the money icon
			Utilities.Tween(0.5, 'easeOutCubic', function(a)
				moneyIcon.Size = UDim2.new(0.5*a, 0, 0.5*a, 0)
				moneyIcon.Position = UDim2.new(0.25+(0.25*(1-a)), 0, 0.25+(0.25*(1-a)), 0)
				moneyIcon.ImageTransparency = 1-a
				moneyText.TextTransparency = 1-a
			end)

			-- Add floating dollar signs
			for i = 1, 5 do
				local dollar = create 'TextLabel' {
					Size = UDim2.new(0.1, 0, 0.1, 0),
					Position = UDim2.new(0.45, 0, 0.45, 0),
					BackgroundTransparency = 1,
					Text = "$",
					TextColor3 = Color3.new(0, 0.7, 0),
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					Parent = frame,
				}

				local angle = math.rad(i * 72) -- Spread dollars in a circle
				local distance = 0.3

				Utilities.Tween(1.5, 'easeOutCubic', function(a)
					dollar.Position = UDim2.new(
						0.45 + math.cos(angle) * distance * a,
						0,
						0.45 + math.sin(angle) * distance * a,
						0
					)
					dollar.TextTransparency = a
				end)
			end

			wait(2)

			-- Fade out
			Utilities.Tween(0.5, 'easeInCubic', function(a)
				moneyIcon.ImageTransparency = a
				moneyText.TextTransparency = a
			end)

			wait(0.5)
			gui:Destroy()
		end)
	end

	function PromoCodeManager:isCodeExpired(code)
		-- Direct expiration check without server call
		local expirationData = nil

		-- Local expiration dates to avoid server calls
		local expirationDates = {
			["PBBJULY2025"] = {
				year = 2025,
				month = 7,
				day = 31,
				hour = 23,
				minute = 59
			},
			["PBBJUNE2025"] = {
				year = 2025,
				month = 6,
				day = 30,
				hour = 23,
				minute = 59
			},
			["PBBMAY2025"] = {
				year = 2025,
				month = 5,
				day = 31,
				hour = 23,
				minute = 59
			},
			["MONEY3"] = {
				year = 2025,
				month = 12,
				day = 31,
				hour = 23,
				minute = 59
			},
			["MONEY2"] = {
				year = 2025,
				month = 7,
				day = 31,
				hour = 23,
				minute = 59
			},
			["MONEY"] = {
				year = 2025,
				month = 5,
				day = 31,
				hour = 23,
				minute = 59
			},
			["DISCORD12K"] = {
				year = 2025,
				month = 7,
				day = 31,
				hour = 23,
			},
			["DISCORD10K"] = {
				year = 2025,
				month = 5,
				day = 31,
				hour = 23,
			},

		}

		expirationData = expirationDates[code]
		if not expirationData then return false end

		local expirationDate = _p.Date:createExpirationDate(
			expirationData.year,
			expirationData.month,
			expirationData.day,
			expirationData.hour,
			expirationData.minute
		)

		-- Debug print
		print("Checking if code " .. code .. " has expired. Expiration date:", expirationDate)
		print("Current time:", os.time())
		local hasExpired = _p.Date:hasExpired(expirationDate)
		print("Has expired:", hasExpired)

		return hasExpired
	end

	return PromoCodeManager
end