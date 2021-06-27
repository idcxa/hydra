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
	scale = t.texturesize/t.pixelsize
	setmetatable(t, self)
	return t
end

-- table of positions, x in pixels, y in pixels, layer group
function Map:loadTextures(t, x, y, l)
	for k, v in pairs(t) do
		t[k] = love.graphics.newQuad(v[1], v[2], x, y, self.tiles:getDimensions())
	end
	self.layers[l].textures = t
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

function Map:set(x, y, l, quad)
	none = true
	for k, v in pairs(map.layers[l].textures) do
		x1, y1 = v:getViewport()
		x2, y2 = quad:getViewport()
		if x1 == x2 and y1 == y2 then
			c = k
			none = false
		end
	end
	if none == true then
		table.insert(self.layers[l].textures, quad)
		c = #self.layers[l].textures
	end
	self.layers[l].map[y + (x-1)*self.height] = c
end

function Map:load(filename)
	file = io.open(filename, "r")
	if file == nil then
		-- defaults
		if self.width == nil then
			self.width = math.random(20)
		end
		if self.height == nil then
			self.height = math.random(10)
		end
		if self.pixelsize == nil then
			self.pixelsize = 16
		end
		self:newLayer()
		self.layers[1].textures = {{16,3*16},{16,4*16}}
		self:newLayer()
		self.layers[2].textures = {{0,7*16}}
		noise(self)
		return
	end

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
		local t = temp[1]
		if t == "f" then
			self.file = temp[2]
			self.tiles = love.graphics.newImage(temp[2])
		end
		if t == "w" then
			self.width = tonumber(temp[2])
		end
		if t == "h" then
			self.height = tonumber(temp[2])
		end
		if t == "ps" then
			self.pixelsize = tonumber(temp[2])
		end
		if t == "l" then
			layer = tonumber(temp[2])
			self.layers[layer].textures = {}
			self.layers[layer].map = {}
			mode = nil
		end

		if t == "textures" or t == "collision" or t == "map" then
			mode = t
		end

		if mode == "textures" and t ~= "textures" then
			table.insert(self.layers[layer].textures, temp)
		end
		if mode == "map" and t ~= "map" then
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
				self.collidables[i + (j-1)*self.height] = {}
				local t = {
					j*self.texturesize - self.texturesize + camera.x,
					i*self.texturesize - self.texturesize + camera.y,
					{0, 0, 16, 16},
					c
				}
				if map.layers[layer].collision ~= nil then
				t[3] = map.layers[layer].collision[c] end
				table.insert(self.collidables, t)
			end
		end
	end
end

-- draw --

function Map:draw(cx, cy, layer)
	for j = 1,map.width do
		for i = 1,map.height do
			print(self.layers[layer].map[i + (j-1)*map.height])
			local c = map.layers[layer].map[i + (j-1)*map.height]
			if c > 0 and self.layers[layer].textures[c] ~= nil then
				love.graphics.draw(self.tiles, self.layers[layer].textures[c], (j*map.texturesize - map.texturesize + cx)/scale, (i*map.texturesize - map.texturesize + cy)/scale)
			end
		end
	end
end

return Map

