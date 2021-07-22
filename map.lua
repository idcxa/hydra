local Map = {}
Map.__index = Map

-- new map --

function Map:new(file)
	local t = {
		file = file,
		layers = {},
		collision = {}
	}
	setmetatable(t, self)
	return t
end

-- table of positions, x in pixels, y in pixels, layer group
function Map:loadTextures(t, x, y, l, file)
	self.tiles = love.graphics.newImage(file)
	for k, v in pairs(t) do
		if v[1] ~= nil then
			t[k] = love.graphics.newQuad(v[1], v[2], x, y, self.tiles:getDimensions())
		end
	end
	self.layers[l].textures = t
	return self
end

--[[
function Map:loadCollisionBoxes(t, layer)
	self.layers[layer].collision = {}
	for _, v in pairs(t) do
		table.insert(self.layers[layer].collision, v)
	end
end
]]--

function Map:newLayer(t)
	t = t or {}
	table.insert(self.layers, t)
	return self
end

function Map:set(x, y, l, quad)
	if quad == nil then self.layers[l].map[y + (x-1)*self.height] = 0
	return end
	local none = true
	for k, v in pairs(map.layers[l].textures) do
		local x1, y1 = v:getViewport()
		local x2, y2 = quad:getViewport()
		if x1 == x2 and y1 == y2 then
			C = k
			none = false
		end
	end
	if none == true then
		table.insert(self.layers[l].textures, quad)
		C = #self.layers[l].textures
	end
	if quad == nil then C = 0 end
	self.layers[l].map[y + (x-1)*self.height] = C
end

local function contains(t, x)
	for _, v in ipairs(t) do
	   if v == x then return true end
   end
end

function Map:clean()
	for _, v in pairs(self.layers) do
		local t = {}
		for k, m in pairs(v.textures) do
			if contains(v.map, k) then
				table.insert(t, m)
				for i, n in pairs(v.map) do
					if n == k then
						v.map[i] = #t
					end
				end
			end
		end
		for i, n in pairs(v.map) do
			if v.textures[n] == nil then
				v.map[i] = 0
			end
		end
		v.textures = t
	end
end

function Map:load(filename)
	local file = io.open(filename, "r")
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
	local layer = 0
	local mode
	for line in file:lines() do
		local token = {}
		for str in string.gmatch(line, "([^".."%s".."]+)") do
			table.insert(token, str)
		end
		local t = token[1]
		if t == "player" then
			player.x = tonumber(token[2])
			player.y = tonumber(token[3])
		end
		if t == "f" then
			self.file = token[2]
			self.tiles = love.graphics.newImage(token[2])
		end
		if t == "w" then
			self.width = tonumber(token[2])
		end
		if t == "h" then
			self.height = tonumber(token[2])
		end
		if t == "ps" then
			self.pixelsize = tonumber(token[2])
		end
		if t == "l" then
			layer = tonumber(token[2])
			self.layers[layer] = {}
			self.layers[layer].textures = {}
			self.layers[layer].map = {}
			mode = nil
		end

		if t == "textures" or t == "collision" or t == "map" then
			mode = t
		end

		if mode == "textures" and t ~= "textures" then
			table.insert(self.layers[layer].textures, token)
		end
		if mode == "map" and t ~= "map" then
			self.layers[layer].map = {}
			for _, v in pairs(token) do
				table.insert(self.layers[layer].map, tonumber(v))
			end
		end
		if mode == "collision" and t ~= "collision" then
			t = {}
			for _, v in pairs(token) do
				table.insert(t, tonumber(v))
			end
			table.insert(self.collision, t)
		end
	end
	for i = 1,layer do
		self:loadTextures(self.layers[i].textures, self.pixelsize, self.pixelsize, i, self.file)
	end
	return self
end

function Map:save(filename)
	local file = io.open(filename, "w")
	file:write("player ", player.x, " ", player.y, "\n")
	file:write("f ", self.file, "\n")
	--file = io.open(filename, "a")
	file:write("w ", self.width, "\n")
	file:write("h ", self.height, "\n")
	--file:write("ts ", texturesize, "\n")
	file:write("ps ", self.pixelsize, "\n")
	for k, v in pairs(self.layers) do
		file:write("l ", k, "\n")
		for l, m in pairs(v) do
			file:write(l, "\n")
			if l == "textures" then
				for _, p in pairs(m) do
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
			end
		end
	end
	file:write("collision\n")
	for _, v in pairs(self.collision) do
		for _, m in pairs(v) do
			file:write(m, " ")
		end
		file:write("\n")
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
					j*texturesize - texturesize + camera.x,
					i*texturesize - texturesize + camera.y,
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

function Map:drawCollision()
	for _, v in pairs(self.collision) do
		if v[1] ~= nil and v[2] ~= nil then
			love.graphics.setColor(1, 0, 0, 1)
			love.graphics.setLineWidth(0.1)
			if v[3] == nil and v[4] == nil then
				love.graphics.rectangle("line", (v[1]+camera.x/scale), (v[2]+camera.y/scale), mmx-v[1], mmy-v[2])
			else
				love.graphics.rectangle("line", (v[1]+camera.x/scale), (v[2]+camera.y/scale), (v[3]-v[1]), (v[4]-v[2]))
				--love.graphics.rectangle("line", (v[1]+camera.x)/scale, (v[2]+camera.y)/scale, (v[3]-v[1])/scale, (v[4]-v[2])/scale)
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.setLineWidth(1)
			end
		end
	end
end

function Map:draw(cx, cy, layer)
	for j = 1,self.width do
		for i = 1,self.height do
			local c = self.layers[layer].map[i + (j-1)*self.height]
			if c > 0 and self.layers[layer].textures[c] ~= nil then
				love.graphics.draw(self.tiles, self.layers[layer].textures[c], (j*map.texturesize - map.texturesize + cx)/scale, (i*map.texturesize - map.texturesize + cy)/scale)
			end
		end
	end
end

return Map

