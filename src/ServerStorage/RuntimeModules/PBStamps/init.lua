return function(_p)
local Utilities = _p.Utilities
local create = Utilities.Create
local write = Utilities.Write

local runService = game:GetService('RunService')
local stampData = require(script.StampData)

local stamps = {}

local SPIN_SPEED = 2.3
local SPIN_DECEL = .4

local styleIcons = {}
for i = 0, 4 do
	styleIcons[i+1] = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228628035',
		ImageRectSize = Vector2.new(180, 180),
		ImageRectOffset = Vector2.new(10+200*(i%3), 10+200*math.floor(i/3)),
		ZIndex = 3
	}
end


local tierColors = {
	[0] = Color3.new(.7, .7, .7),
	Color3.fromRGB(21,198,27),
	Color3.fromRGB(32,63,216),
	Color3.fromRGB(107,17,216),
	Color3.fromRGB(219,189,101),
	Color3.fromRGB(127,0,0)
}

for i, tc in pairs(tierColors) do
	local h, s, v = Color3.toHSV(tc)
	tierColors[i] = Color3.fromHSV(h, s*.7, math.min(1, v*1.2))
end

local function getRandomStamp(rand)
	rand = rand or math.random
	local tr = rand(100)
	local tier = 1
	if tr < 4 then
		tier = 5
	elseif tr < 10 then
		tier = 4
	elseif tr < 20 then
		tier = 3
	elseif tr < 53 then
		tier = 2
	end
	
	local qr = rand(100)
	local q
	if qr < 6 then
		q = 3
	elseif qr < 21 then
		q = 2
	end
	
	local tierData = stampData.tiers[tier]
	local stamp = tierData[rand(#tierData)]
	local style = rand(4)
	
	return {
		tier = tier,
		quantity = q,
		sheet = stamp.sheet,
		sheetId = stampData.sheetIds[stamp.sheet],
		n = stamp.n,
		color = stamp.color,
		color3 = stampData.colors[stamp.color],
		colorName = stampData.colorNumToName[stamp.color],
		style = style,
		name = stamp.name
	}
end
stamps.getRandomStamp = getRandomStamp

function stamps:getStampId(stamp)
	return string.format('%d,%d,%d,%d', stamp.sheet, stamp.n, stamp.color, stamp.style)
end

function stamps:getExtendedStampData(stamp)
	local sheet, color = stamp.sheet, stamp.color
	local ed = stampData.db[sheet].Particles[stamp.n]
	local colorName = stampData.colorNumToName[color]
	return {
		sheet = sheet,
		n = stamp.n,
		color = color,
		style = stamp.style,
		quantity = stamp.quantity,
		
		tier = ed.Colors[colorName] or 0,
		sheetId = stampData.sheetIds[sheet],
		color3 = stampData.colors[color],
		colorName = colorName,
		name = ed.name
	}
end

function stamps:getStampAnimationData(stamp)
	return {
		sheetId = stampData.sheetIds[stamp.sheet],
		n = stamp.n,
		color3 = stampData.colors[stamp.color],
		style = stamp.style
	}
end


local function getStampIcon(stamp, button)
	if not stamp then
		stamp = getRandomStamp()
	end
	
	local m = create(button and 'ImageButton' or 'ImageLabel') {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228630788',
		ImageColor3 = tierColors[stamp.tier],
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(Vector2.new(20, 20), Vector2.new(80, 80)),
		AnchorPoint = Vector2.new(.5, 0),
		Size = UDim2.new(1.0, 0, 1.0, 0),
		ZIndex = 2
	}
	
	local s = stamp.n-1
	local image = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://'..stamp.sheetId,
		ImageColor3 = stamp.color3,
		ImageRectSize = Vector2.new(200, 200),
		ImageRectOffset = Vector2.new(200*(s%5), 200*math.floor(s/5)),
		Size = UDim2.new(.6, 0, .6, 0),
		Position = UDim2.new(.2, 0, .1, 0),
		ZIndex = 2, Parent = m
	}
	
	if stamp.colorName == 'Rainbow' then
		image.Size = UDim2.new(.28, 0, .28, 0)
		image.AnchorPoint = Vector2.new(.5, .5)
		local thirdPi = math.pi/3
		for i = 0, 5 do
			local img = i==1 and image or image:Clone()
			img.Position = UDim2.new(.5+.18*math.sin(thirdPi*i), 0, .4-.18*math.cos(thirdPi*i), 0)
			img.ImageColor3 = Color3.fromHSV(i/6, 1, 1)
			img.Parent = m
		end
	end
	
	local q = stamp.quantity
	if q then -- nil == 1
		create 'TextLabel' {
			Name = 'QuantityLabel',
			BackgroundTransparency = 1.0,
			Font = Enum.Font.Cartoon,
			Text = (button and '' or 'x')..q,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			Size = UDim2.new(.3, 0, .25, 0),
			Position = UDim2.new(.1, 0, .65, 0),
			ZIndex = 3, Parent = m
		}
	end
	
	local s = styleIcons[stamp.style]:Clone()
	s.Size = UDim2.new(.38, 0, .38, 0)
	s.Position = UDim2.new(.54, 0, .58, 0)
	s.Parent = m
	return m
end


function stamps:openSpinner(sessionId)
	if self.spinnerOpen then return end
	self.spinnerOpen = true
	
	local animating = true
	
	local bg = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228633611', -- 5228635559
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(.6*4168/2217, 0, .6, 0),
		AnchorPoint = Vector2.new(.5, .5),
		ZIndex = 4, Parent = Utilities.frontGui
	}
	local pointer = create 'ImageLabel' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228637622',
		ImageColor3 = Color3.new(.8, .8, .8),
		ImageTransparency = .5,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(0.14, 0, 0.1, 0),
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.new(0.5, 0, 0.32, 0),
		ZIndex = 5, Parent = bg
	}
	local clipContainer = create 'Frame' {
		ClipsDescendants = true,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(37, 43, 49),
		Size = UDim2.new(.8, 0, .46, 0),
		Position = UDim2.new(.1, 0, .27, 0),
		Parent = bg
	}
	local squareContainer = create 'Frame' {
		BackgroundTransparency = 1.0,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(.7, 0, .7, 0),
		AnchorPoint = Vector2.new(.5, 0),
		Position = UDim2.new(.5, 0, 0.12, 0),
		Parent = clipContainer
	}
	local sig = Utilities.Signal()
	local spinning = true
	local stop = false
	local stopping = false
	
	local spins, shownSpins
	
	--1000x532
	--left  311x57@100,407
	--right 311x57@589,407
	local cr = Utilities.gui.AbsoluteSize.Y*.02
	local ypad = .032
	local xpad = .01--ypad/532*1000
	
	write 'Stamp Spinner' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.0, 0, .125, 0),
			Position = UDim2.new(.5, 0, .1, 0),
			ZIndex = 5, Parent = bg
		}, Scaled = true
	}
	
	local buyButton = _p.RoundedFrame:new {
		CornerRadius = cr,
		Button = true,
		BackgroundColor3 = Color3.fromRGB(53, 63, 73),
		Size = UDim2.new(.311+xpad, 0, 57/532+ypad, 0),
		Position = UDim2.new(.1-xpad/2, 0, 407/532-ypad/2, 0),
		ZIndex = 5, Parent = bg,
		MouseButton1Click = function()
			if animating or not spinning or stop then return end
			animating = true
			--  1 roll  - 10 robux - standard price
			--  5 rolls - 45 robox - save  5 robux 
			-- 10 rolls - 85 robux - save 15 robux
			
			local bsig = Utilities.Signal()
			
			local fader = create 'Frame' {
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.new(1.0, 0, 1.0, 36),
				Position = UDim2.new(.0, 0, .0, -36),
				ZIndex = 7, Parent = Utilities.frontGui
			}
			local buyGui = create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5228630788',
				ImageColor3 = Color3.fromRGB(73, 86, 111),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(Vector2.new(20, 20), Vector2.new(80, 80)),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.new(.8, 0, .37, 0),
				AnchorPoint = Vector2.new(.5, .5),
				ZIndex = 8, Parent = Utilities.frontGui
			}
			local robux = {5, 10, 15} --{8, 35, 65}
			local products = {_p.productId.PBSpins1, _p.productId.PBSpins5, _p.productId.PBSpins10}
			for i, value in pairs({1, 5, 10}) do
				local button = create 'ImageButton' {
					BackgroundTransparency = 1.0,
					Image = 'rbxassetid://5228630788',
					ImageColor3 = tierColors[2*i-1],
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(Vector2.new(20, 20), Vector2.new(80, 80)),
					Size = UDim2.new(.25, 0, .25*.8/.37, 0),
					Position = UDim2.new(.25/4*i+.25*(i-1), 0, .1, 0),
					ZIndex = 9, Parent = buyGui,
					MouseButton1Click = function()
						_p.MarketClient:promptProductPurchase(products[i])
					end
				}
				write(tostring(value)) {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(.0, 0, .54, 0),
						Position = UDim2.new(.5, 0, .12, 0),
						ZIndex = 10, Parent = button
					}, Scaled = true
				}
				write(i==1 and 'spin' or 'spins') {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(.0, 0, .2, 0),
						Position = UDim2.new(.5, 0, .67, 0),
						ZIndex = 10, Parent = button
					}, Scaled = true
				}
				write(robux[i]..' R$') {
					Frame = create 'Frame' {
						BackgroundTransparency = 1.0,
						Size = UDim2.new(.0, 0, .24, 0),
						Position = UDim2.new(.5, 0, 1.1, 0),
						ZIndex = 10, Parent = button
					}, Scaled = true,
					Color = BrickColor.new('Bright green').Color
				}
			end
			local closeButton = _p.RoundedFrame:new {
				Button = true, CornerRadius = Utilities.gui.AbsoluteSize.Y*.015,
				BackgroundColor3 = Color3.fromRGB(73, 86, 111),
				Size = UDim2.new(0.25, 0, 0.17, 0),
				Position = UDim2.new(0.7, 0, -0.225, 0),
				ZIndex = 9, Parent = buyGui,
				MouseButton1Click = function()
					bsig:fire()
				end,
			}
			write 'Close' {
				Frame = create 'Frame' {
					BackgroundTransparency = 1.0,
					Size = UDim2.new(0.0, 0, 0.5, 0),
					Position = UDim2.new(0.5, 0, 0.25, 0),
					ZIndex = 10, Parent = closeButton.gui
				}, Scaled = true
			}
			Utilities.Tween(.6, 'easeOutCubic', function(a)
				fader.BackgroundTransparency = 1-.4*a
				buyGui.Position = UDim2.new(.5, 0, -.5+a)
			end)
			bsig:wait()
			Utilities.Tween(.6, 'easeOutCubic', function(a)
				fader.BackgroundTransparency = .6+.4*a
				buyGui.Position = UDim2.new(.5, 0, .5-a)
			end)
			closeButton:remove()
			buyGui:remove()
			fader:remove()
			animating = false
		end
	}
	write 'Buy Spins' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.0, 0, .5, 0),
			Position = UDim2.new(.5, 0, .25, 0),
			ZIndex = 6, Parent = buyButton.gui
		}, Scaled = true
	}
	local spinButton = _p.RoundedFrame:new {
		CornerRadius = cr,
		Button = true,
		BackgroundColor3 = Color3.fromRGB(53, 63, 73),
		Size = UDim2.new(.311+xpad, 0, 57/532+ypad, 0),
		Position = UDim2.new(.589-xpad/2, 0, 407/532-ypad/2, 0),
		ZIndex = 5, Parent = bg,
		MouseButton1Click = function()
			if animating then return end
			-- do nothing more than try to flag a stop here
			-- the step function takes care of accepting the stop and running related code
			stop = true
		end
	}
	write 'Use Spin' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.0, 0, .5, 0),
			Position = UDim2.new(.5, 0, .25, 0),
			ZIndex = 6, Parent = spinButton.gui
		}, Scaled = true
	}
	local closeButton = _p.RoundedFrame:new {
		Button = true,
		CornerRadius = cr*.5,
		BackgroundColor3 = Color3.fromRGB(53, 63, 73),
		Size = UDim2.new(.14, 0, .09, 0),
		Position = UDim2.new(.84, 0, .2, 0),
		ZIndex = 5, Parent = bg,
		MouseButton1Click = function()
			if animating or stop or stopping then return end
			animating = true
			sig:fire()
		end
	}
	write 'Close' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.0, 0, .5, 0),
			Position = UDim2.new(.5, 0, .25, 0),
			ZIndex = 6, Parent = closeButton.gui
		}, Scaled = true
	}
	
	--.178
	local countContainer = create 'Frame' {
		ClipsDescendants = true,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(53, 63, 73),
		Size = UDim2.new(.11, 0, .095, 0),
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.new(.5, 0, .82, 0),
		ZIndex = 5, Parent = bg
	}
	
	local nums = {}
	local numCurrent = {}
	local function writeNumber(s)
		local f = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(.0, 0, .6, 0),
			ZIndex = 6
		}
		write(s) {Frame = f, Scaled = true}
		return f
	end
	
	local lastThread, currentThread
	local function setNumSpins(n)
		spins = n
		local thisThread = {}
		lastThread = thisThread
		if currentThread then
			while true do
				wait()
				if lastThread ~= thisThread then return end
				if not currentThread then break end
			end
		end
		currentThread = thisThread
		local animDir = 0
		if shownSpins then
			animDir = shownSpins > n and -1 or 1
		end
		local spinString = tostring(n)
		local animFuncs = {}
		for i = 1, 3 do
			local s = spinString:sub(-i,-i)
			s = s=='' and '0' or s
			if s ~= numCurrent[i] then
				numCurrent[i] = s
				local w = writeNumber(s)
				w.Parent = countContainer
				local x = (7-2*i)/6
				if animDir == 0 or not nums[i] then
					w.Position = UDim2.new(x, 0, .2, 0)
				else
					local replacing = nums[i]
					table.insert(animFuncs, function()
						Utilities.Tween(.5, nil, function(a)
							replacing.Position = UDim2.new(x, 0, .2+a*animDir, 0)
							w.Position = UDim2.new(x, 0, .2-animDir+a*animDir, 0)
						end)
						replacing:remove()
					end)
				end
				nums[i] = w
			end
		end
		if #animFuncs > 0 then
			Utilities.Sync(animFuncs)
		end
		shownSpins = n
		if currentThread == thisThread then
			currentThread = nil
		end
	end
	
	Utilities.fastSpawn(function()
		setNumSpins(_p.Network:get('PDS', 'nSpins'))
	end)
	
	_p.Network:bindEvent('uPBSpins', function(n)
		setNumSpins(n)
	end)
	
	
	local w = clipContainer.AbsoluteSize.X/squareContainer.AbsoluteSize.Y
	local half_w = w/2
	
	local et = 0
	local p0 = math.ceil(half_w)+1
	local speed = SPIN_SPEED
	local pos, accel, ep, wr, wonStamp
	
	local flashPointer
	
	local things = {}
	local thingCount = 0
	local null = {}
	local gcount = 0
	
	local rsId = 'RSpin_'..Utilities.uid()
	local st = tick()
	local spinUpdate = function()
		if not spinning then return end
		
		local et = tick()-st
		if accel then
			if accel*et+speed < 0 then
				pos = ep
			else
				pos = p0 + speed*et + accel*.5*et*et
			end
		else
			pos = p0 + speed*et
		end
		
		-- add/remove things as necessary
		local min = math.floor(pos-half_w)
		local max = math.ceil(pos+half_w)
--		print(min, max)
		for i = gcount+1, min-1 do
			local t = things[i]
			if t and t ~= null then
				t:remove()
				things[i] = null
			end
			gcount = i
		end
		for i = math.max(min, thingCount+1), max do
			local t = getStampIcon(i==wr and wonStamp or nil)
--			t.Name = 'thing'..i --
			t.Parent = squareContainer
			things[i] = t
			thingCount = i
		end
		-- position things
		for i = min, max do
			things[i].Position = UDim2.new(1.03*(i-pos), 0, 0.0, 0)
		end
		
		if pos == ep then
			spinning = false
--			local pauseAt = tick()
			pos = ep
			local wt = things[wr]
			local p = wt.Position.X.Scale-.5
			local newTopGui = Instance.new('ScreenGui', _p.player:WaitForChild('PlayerGui'))
			local sp = wt.AbsolutePosition
			local ss = wt.AbsoluteSize
			local es = ss * 1.5
			local ep = newTopGui.AbsoluteSize/2-es/2
			local ds, dp = es-ss, ep-sp
			wt.Parent = newTopGui
			wt.AnchorPoint = Vector2.new(0, 0)
			Utilities.Tween(.5, 'easeOutCubic', function(a)
				wt.Size = UDim2.new(.0, ss.X+ds.X*a, .0, ss.Y+ds.Y*a)
				wt.Position = UDim2.new(.0, sp.X+dp.X*a, .0, sp.Y+dp.Y*a)
			end)
			local quantity = ({'a', 'two', 'three'})[wonStamp.quantity or 1]
			local colorName = wonStamp.colorName
			if colorName == 'NoColor' then
				colorName = ''
			else
				colorName = colorName:gsub('%u', ' %0')
			end
			local chat = _p.NPCChat
			chat.bottom = true
			chat:say('You got '..quantity..colorName..' '..wonStamp.name..' stamp'..(wonStamp.quantity and 's' or '')..'!')
			chat.bottom = nil
			newTopGui:remove()
			things[wr] = null
			-- safe reset here would be nice
			st = tick()-- -pos/speed
			p0 = pos
			accel, ep, wr, wonStamp = nil, nil, nil, nil
			stop = false
			spinning = true
			pointer.ImageTransparency = .5
			return
		end
		
		if not stopping and not accel then
			if stop then
				if et < .3 or not spins or spins < 1 then
					stop = false
				else
					stopping = true
					
					Utilities.fastSpawn(setNumSpins, spins-1)
					
					pointer.ImageTransparency = .0
					spawn(function()
						if not flashPointer then
							flashPointer = pointer:Clone()
							flashPointer.Parent = bg
						end
						Utilities.Tween(.5, 'easeOutCubic', function(a)
							local s = 1+a
							flashPointer.Size = UDim2.new(s*.14, 0, s*.1, 0)
							flashPointer.ImageTransparency = a
						end)
					end)
					
					Utilities.fastSpawn(function()
						wonStamp = _p.Network:get('PDS', 'spinForStamp')
						if not wonStamp then return end
						
						p0 = pos -- note that `pos` here has been changed by parallel thread
						accel = -SPIN_DECEL
						st = tick()
						
						local t = speed / -accel
						ep = pos + speed*t + .5*accel*t*t
						
						local mep = ep + .5*1.03
						local upper = math.ceil(mep)
						local lower = math.floor(mep)
		--				print(lower, upper)
		--				print(string.format('%.2f, %.2f', mep-lower, upper-mep))
						wr = upper-mep < mep-lower and upper or lower
						stopping = false
					end)
				end
--			elseif pos > 100 then
--				print('safe reset')
--				local newThings = {}
--				for i = min, max do
--					newThings[i-gcount] = things[i]
--				end
--				things = newThings
--				p0 = pos - gcount
--				st = tick()-- - pos/speed
--				gcount = 0
--				thingCount = max - gcount
			end
		end
		
	end
	
	runService:BindToRenderStep(rsId, Enum.RenderPriority.First.Value+5, spinUpdate)
	
	Utilities.Tween(.6, 'easeOutCubic', function(a)
		bg.Position = UDim2.new(.5, 0, -.5+a, 0)
	end)
	animating = false
	sig:wait()
	Utilities.Tween(.6, 'easeOutCubic', function(a)
		bg.Position = UDim2.new(.5, 0, .5-a, 0)
	end)
	
	spinning = false
	runService:UnbindFromRenderStep(rsId)
	_p.Network:bindEvent('uPBSpins', nil)
	
	buyButton:remove()
	spinButton:remove()
	closeButton:remove()
	bg:remove()
	
	self.spinnerOpen = false
end



function stamps:openInventory(bmap, pokemonSlot)
	local inventory, pokemonData, hasPass = _p.Network:get('PDS', 'stampInventory', pokemonSlot)
	if not inventory then return end
	
	local st = tick()
	Utilities.FadeOut(.6)
	
	local chunk = _p.DataManager.currentChunk
	local room = chunk:topRoom()
	
	local offset = Vector3.new(0, 95, 385)
	Utilities.MoveModel(bmap._User, CFrame.new(5, 96.9, 383), true)
	bmap.Parent = room.model
	
	chunk.roomCamDisabled = true
	
	local cam = workspace.CurrentCamera
	cam.FieldOfView = 28
	cam.CFrame = CFrame.new(-5.59, 99.56, 376.09, -.746, .063, -.663, 0, .996, .094, .666, .07, -.742)
	
	local fakeBattle = {
		scene = bmap,
		CoordinateFrame2 = CFrame.new(bmap._Foe.Position, bmap._User.Position) + Vector3.new(0, -bmap._Foe.Size.Y/2, 0)
	}
	
	local sprite = _p.Battle._SpriteClass:new({forme = pokemonData.forme}, pokemonData, fakeBattle, 2)
	
	local sig = Utilities.Signal()
	local pStamps = {}
	
	local function updateSpriteStamps()
		local ss = {}
		for i, id in pairs(pStamps) do
			local sheet, n, color, style = id:match('(%d+),(%d+),(%d+),(%d+)')
			sheet, n, color, style = tonumber(sheet), tonumber(n), tonumber(color), tonumber(style)
			if sheet and n and color and style then
				local s = self:getStampAnimationData{sheet = sheet, n = n, color = color, style = style}
				if color == 20 then s.rainbow = true end
				ss[#ss+1] = s
			else
				print('bad stamp id: could not convert "'..id..'" back to stamp (test summon)')
			end
		end
		pokemonData.pbs = ss
	end
	
	local canPlay = false
	local playButton; playButton = create 'ImageButton' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228643597',
		ImageColor3 = Color3.fromRGB(73, 86, 111),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(.09, 0, .09, 0),
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.new(.55, 0, .84, 0),
		Parent = Utilities.gui,
		MouseButton1Click = function()
			if not canPlay then return end
			canPlay = false
			playButton.ImageTransparency = .5
			updateSpriteStamps()
			sprite.animation.spriteLabel.Visible = false
			sprite:animSummon(1)
			wait(.2)
			canPlay = true
			playButton.ImageTransparency = .0
		end
	}
	local inventoryGui = create 'ImageLabel' {--620x1000; 553x933@33,34
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228643597',
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(.62*.9, 0, .9, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(.45, 0, .05, 0),
		Parent = Utilities.gui
	}
	local scrollList = create 'ScrollingFrame' {
		BackgroundTransparency = 1.0,
		BorderSizePixel = 0,
		Size = UDim2.new(553/620, 0, .933, 0),
		Position = UDim2.new(33/620, 0, .034, 0),
		ZIndex = 2, Parent = inventoryGui
	}
	local listContainer = create 'Frame' {
		BackgroundTransparency = 1.0,
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Parent = scrollList
	}
	local stampButtonPairs = {}
	local ebuttons = {}
	for i, stamp in pairs(pokemonData.stamps) do
		local id = stamp.id
		if not id then
			id = stamps:getStampId(stamp)
			stamp.id = id
		end
		pStamps[i] = id
	end
	local blankButton = create 'ImageButton' {
		BackgroundTransparency = 1.0,
		Image = 'rbxassetid://5228630788',
		ImageColor3 = Color3.new(.3, .3, .3),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(Vector2.new(20, 20), Vector2.new(80, 80)),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.new(1.0, 0, 1.0, 0)
	}
	local function updateEquippedStamp(slot, stamp)
--		local stamp = pokemonData.stamps[slot]
		local button = stamp and getStampIcon(stamp, true) or blankButton:Clone()
		if not hasPass and not stamp and slot > 1 then
			button.ImageTransparency = .5
			create 'ImageLabel' {
				BackgroundTransparency = 1.0,
				Image = 'rbxassetid://5228648746',
				Size = UDim2.new(.5, 0, .5, 0),
				Position = UDim2.new(.25, 0, .25, 0),
				ZIndex = 6, Parent = button
			}
		end
		pcall(function() button.QuantityLabel:remove() end)
		button.SizeConstraint = Enum.SizeConstraint.RelativeYY
		button.Size = UDim2.new(1.8, 0, 1.8, 0)
		button.AnchorPoint = Vector2.new(0, .5)
		button.Position = UDim2.new(slot*2, 0, .5, 0)
		button.Parent = playButton
		if stamp then
			button.MouseButton1Click:connect(function()--unequip
				button:remove()
				for i, eb in pairs(ebuttons) do
					if eb == button then
						slot = i
						break
					end
				end
				local nStamps = #pStamps
				if nStamps > slot then
					for i = slot+1, nStamps do
						local eb = ebuttons[i]
						eb.Position = UDim2.new((i-1)*2, 0, .5, 0)
						ebuttons[i-1] = eb
						ebuttons[i] = nil
						pStamps[i-1] = pStamps[i]
						pStamps[i] = nil
					end
					updateEquippedStamp(nStamps, nil)
				else
					pStamps[slot] = nil
					updateEquippedStamp(slot, nil)
				end
				pcall(function()
					local s, b = unpack(stampButtonPairs[stamp.id])
					local q = s.quantity + 1
					s.quantity = q
					b.QuantityLabel.Text = tostring(q)
				end)
			end)
		end
		
		ebuttons[slot] = button
	end
	for i = 1, 3 do
		updateEquippedStamp(i, pokemonData.stamps[i])
	end
--	local function updateList()
		local sbw = Utilities.gui.AbsoluteSize.Y*.03
		scrollList.ScrollBarThickness = sbw
		listContainer.Size = UDim2.new(1.0, -sbw, 1.0, -sbw)
		
		local h = .32
		local n = math.ceil(#inventory/3)/.9
		local contentRelativeSize = n * h * listContainer.AbsoluteSize.X / scrollList.AbsoluteSize.Y
		scrollList.CanvasSize = UDim2.new(scrollList.Size.X.Scale, -1, contentRelativeSize * scrollList.Size.Y.Scale, 0)
		
		for i, stamp in pairs(inventory) do
			local button = getStampIcon(stamp, true)
			button.Size = UDim2.new(h, 0, h, 0)
			local x = (i-1)%3
			local y = math.floor((i-1)/3)
			button.AnchorPoint = Vector2.new(.5, .5)
			button.Position = UDim2.new((x*2+1)/6, 0, (y*2+1)/6, 0)
			button.Parent = listContainer
			
			local id = stamp.id
			if not id then
				id = stamps:getStampId(stamp)
				stamp.id = id
			end
			stampButtonPairs[id] = {stamp, button}
			
			button.MouseButton1Click:connect(function()
				if stamp.quantity < 1 then return end
				if #pStamps > (hasPass and 2 or 0) then return end
				stamp.quantity = stamp.quantity - 1
				pcall(function() button.QuantityLabel.Text = tostring(stamp.quantity) end)
				local n = #pStamps+1
				pStamps[n] = id
				pcall(function() ebuttons[n]:remove() end)
				updateEquippedStamp(n, stamp)
			end)
		end
--	end
--	updateList()
	
	local closeButton = _p.RoundedFrame:new {
		Button = true, CornerRadius = Utilities.gui.AbsoluteSize.Y*.018,
		BackgroundColor3 = Color3.fromRGB(73, 86, 111),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Size = UDim2.new(.2, 0, .06, 0),
		Position = UDim2.new(.6, 0, .02, 0),
		Parent = Utilities.gui,
		MouseButton1Click = function()
			if not canPlay then return end
			sig:fire()
		end,
	}
	write 'Done' {
		Frame = create 'Frame' {
			BackgroundTransparency = 1.0,
			Size = UDim2.new(0.0, 0, 0.5, 0),
			Position = UDim2.new(0.5, 0, 0.25, 0),
			ZIndex = 2, Parent = closeButton.gui
		}, Scaled = true
	}
	
	local et = tick()-st
	if et < .7 then wait(.7-et) end
	Utilities.FadeIn(.6)
	wait(.3)
	updateSpriteStamps()
	sprite:animSummon(1)
	canPlay = true
	
	
	sig:wait()
	Utilities.FadeOut(.6)
	wait(.1)
	
	pcall(function() sprite:remove() end)
	closeButton:remove()
	playButton:remove()
	inventoryGui:remove()
	
	st = tick()
	_p.Network:get('PDS', 'setStamps', pokemonSlot, pStamps)
	
	cam.FieldOfView = 70
	bmap.Parent = nil
	chunk.roomCamDisabled = false
	
	wait(math.max(.1, .4-(tick()-st)))
	Utilities.FadeIn(.6)
end


return stamps
end