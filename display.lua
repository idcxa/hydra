local Map = {}
Map.__index = Map

-- new map --

function Map:new(file, width, height, x, pixelsize, layers)
	layers = layers or {}
	local t = {
		tiles = love.graphics.newImage(file),
		width = width,
		height = height,
		texturesize = x,
		pixelsize = pixelsize,
		layers = layers
	}
	setmetatable(t, self)
	return t
end

-- table of positions, x in pixels, y in pixels, layer group
function Map:loadTextures(t, x, y, layers)
	for k, v in pairs(t) do
		t[k] = love.graphics.newQuad(x*v[1], y*v[2], x, y, self.tiles:getDimensions())
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

