local black = Color3.new(0, 0, 0)

return {
	function(container)
		local tilesX = 8
		local tilesY = 6
		local tiles = {}
		local total = math.max(tilesX, tilesY) + 8
		return function(a)
			local prog = total*a
			for x = 0, tilesX-1 do
				if not tiles[x] then tiles[x] = {} end
				for y = 0, tilesY-1 do
					if not tiles[x][y] then
						tiles[x][y] = Instance.new("Frame", container)
						tiles[x][y].BackgroundTransparency = 1
						tiles[x][y].Size = UDim2.new(1/tilesX, 2, 1/tilesY, 2)
						tiles[x][y].Position = UDim2.new(1/tilesX*x, -1, 1/tilesY*y, -1)
						local tile = Instance.new("Frame", tiles[x][y])
						tile.BackgroundColor3 = black--Color3.new(0, 0, 0)
						tile.BorderSizePixel = 0
						tile.Name = "Tile"
					end
					local tile = tiles[x][y]["Tile"]
					local alpha = math.min(1, (prog >= x+y) and (prog - (x+y)) / 4 or 0)
					tile.Size = UDim2.new(alpha, 0, alpha, 0)
					tile.Position = UDim2.new((1-alpha)/2, 0, (1-alpha)/2, 0)
				end
			end
		end
	end,
	function(container)
		local tilesX = 8
		local tilesY = 6
		local tiles = {}
		local total = math.max(tilesX, tilesY) + 8
		return function(a)
			local prog = total*a
			for x = 0, tilesX-1 do
				if not tiles[x] then tiles[x] = {} end
				for y = 0, tilesY-1 do
					if not tiles[x][y] then
						tiles[x][y] = Instance.new("Frame", container)
						tiles[x][y].BackgroundTransparency = 1
						tiles[x][y].Size = UDim2.new(1/tilesX, 2, 1/tilesY, 2)
						tiles[x][y].Position = UDim2.new(1-1/tilesX*(x+1), -1, 1-1/tilesY*(y+1), -1)
						local tile = Instance.new("Frame", tiles[x][y])
						tile.BackgroundColor3 = black--Color3.new(0, 0, 0)
						tile.BorderSizePixel = 0
						tile.Name = "Tile"
					end
					local tile = tiles[x][y]["Tile"]
					local alpha = math.min(1, (prog >= x+y) and (prog - (x+y)) / 4 or 0)
					tile.Size = UDim2.new(alpha, 0, alpha, 0)
					tile.Position = UDim2.new((1-alpha)/2, 0, (1-alpha)/2, 0)
				end
			end
		end
	end,
	function(container)
		return function(_, a)
			container.BackgroundTransparency = 1-a
		end
	end,
}