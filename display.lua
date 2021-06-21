local Map = {}
Map.__index = Map

-- new map --

function Map:new(file, width, height, x, pixelsize, layers)
	layers = layers or {}
	local t = {
		file = file,
		tiles = love.graphics.newImage(file),
		width = width,
		height = height,
		texturesize = x,
		pixelsize = pixelsize,
		layers = {}
	}
	setmetatable(t, self)
	return t
end

-- table of positions, x in pixels, y in pixels, layer group
function Map:loadTextures(t, x, y, layers)
	for k, v in pairs(t) do
		t[k] = love.graphics.newQuad(v[1], v[2], x, y, self.tiles:getDimensions())
	end
	self.layers[layers].textures = t
	return self
end

function Map:loadCollisionBoxes(t, layer)
	self.layers[layer].collision = {}
	for _, v in pairs(t) do
		table.insert(self.layers[layer].collision, v)
	end
end

function Map:newLayer(t)
	t = t or {}
	table.insert(self.layers, t)
	return self
end

function Map:set(x, y, l, c)
	self.layers[l].map[y + (x-1)*self.height] = c
end

function Map:load(filename)
	file = io.open(filename, "r")
	self.layers = {}
	self.layers[1] = {}
	self.layers[2] = {}
	layer = 0
	local mode
	for line in file:lines() do
		temp = {}
		for str in string.gmatch(line, "([^".."%s".."]+)") do
			table.insert(temp, str)
		end
		if temp[1] == "f" then
			self.file = temp[2]
			self.tiles = love.graphics.newImage(temp[2])
		end
		if temp[1] == "w" then
			self.width = tonumber(temp[2])
		end
		if temp[1] == "h" then
			self.height = tonumber(temp[2])
		end
		if temp[1] == "ps" then
			self.pixelsize = tonumber(temp[2])
		end
		if temp[1] == "l" then
			layer = tonumber(temp[2])
			self.layers[layer].textures = {}
			self.layers[layer].map = {}
			mode = nil
		end

		if temp[1] == "textures" then
			mode = temp[1]
		end
		if temp[1] == "collision" then
			mode = temp[1]
		end
		if temp[1] == "map" then
			mode = temp[1]
		end

		if mode == "textures" and temp[1] ~= "textures" then
			table.insert(self.layers[layer].textures, temp)
		end
		if mode == "map" and temp[1] ~= "map" then
			self.layers[layer].map = {}
			for _, v in pairs(temp) do
				table.insert(self.layers[layer].map, tonumber(v))
			end
		end
	end
	return self
end

function Map:save(filename)
	file = io.open(filename, "w")
	file:write("f ", self.file, "\n")
	--file = io.open(filename, "a")
	file:write("w ", self.width, "\n")
	file:write("h ", self.height, "\n")
	--file:write("ts ", self.texturesize, "\n")
	file:write("ps ", self.pixelsize, "\n")
	for k, v in pairs(self.layers) do
		file:write("l ", k, "\n")
		for l, m in pairs(v) do
			file:write(l, "\n")
			if l == "textures" then
				for o, p in pairs(m) do
					local x, y, w, h = p:getViewport()
					if x < 1000 then
						file:write(x, " ", y, " ", w, " ", h, "\n")
					end
				end
			elseif l == "map" then
				for _, p in pairs(m) do
					file:write(p, " ")
				end
				file:write("\n")
			elseif l == "collision" then
				for _, p in pairs(m) do
					for i = 1,4 do
						file:write(p[i], " ")
					end
				file:write("\n")
				end
			end
		end
	end
end

-- collision --

function Map:loadCollision(camera, layer)
	self.collidables = {}
	for j = 1,self.width do
		for i = 1,self.height do
			local c = self.layers[layer].map[i + (j-1)*self.height]
			if c > 0 then
				self.collidables[i + (j-1)*self.height] = collidables[i + (j-1)*self.height] or {}
				local t = {
					j*self.texturesize - self.texturesize + camera.x,
					i*self.texturesize - self.texturesize + camera.y,
					{0, 0, 16, 16},
					c
				}
				t[3] = map.layers[layer].collision[c]
				table.insert(self.collidables, t)
			end
		end
	end
end

-- draw --

function Map:draw(cx, cy, layer)
	for j = 1,map.width do
		for i = 1,map.height do
			local c = map.layers[layer].map[i + (j-1)*map.height]
			if c > 0 then
				love.graphics.draw(tiles, self.layers[layer].textures[c], (j*map.texturesize - map.texturesize + cx)/scale, (i*map.texturesize - map.texturesize + cy)/scale)
			end
		end
	end
end

return Map

