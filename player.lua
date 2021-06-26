local Player = {}
Player.__index = Player

-- takes a single argument of a table of animations
function Player:new(anims, x, y, speed)
	local t = {
		x = x, y = x,
		anims = anims,
		tile,
		quad,
		speed = speed
	}
	setmetatable(t, self)
	return t
end

-- switch animation based on the key
function Player:animation(k)
	self.quad = self.anims[k].quad
	self.tile = self.anims[k].tile
end

function Player:collision(t, camera, map)
	-- texture size
	local ts = map.texturesize
	-- player size
	local ps = map.texturesize*0.8
	-- collision width
	local cw = 5
	scale = map.texturesize/map.pixelsize

	-- map border collision
	-- left
	if self.x < ps/2 - self.speed/2 then
		self.x = ps/2
		camera.pseudox = love.graphics.getWidth()/2
	end
	-- right
	if self.x > map.width * ts - ts/2 + camera.x + self.speed/2 then
		self.x = map.width * ts - ts/2 + camera.x
		camera.pseudox = -map.texturesize*map.width + love.graphics.getWidth()/2
	end
	-- top
	if self.y < ts/2 - self.speed/2 then
		self.y = ts/2
		camera.pseudoy = love.graphics.getHeight()/2
	end
	-- bottom
	if self.y > map.height * ts - ts/2 + camera.y + self.speed/2 then
		self.y = map.height * ts - ts/2 + camera.y
		camera.pseudoy = -map.texturesize*map.height + love.graphics.getHeight()/2
	end

	-- object collision
	-- v display coordinates
	for _, v in pairs(map.collidables) do
		if v[2] ~= nil then
			c = v[3]
			-- left
			if v[2] - ps/2 + cw + c[2]*scale < self.y and self.y < v[2] + ts + ps/2 - cw
				and v[1] - ps/2 + c[1]*scale < self.x and self.x < v[1] - ps/2 + cw + c[1]*scale
				and t[1] <= 0 then
				t[1] = 0
			end
			-- right
			if v[2] - ps/2 + cw + c[2]*scale < self.y and self.y < v[2] + ts + ps/2 - cw
				and v[1] + ts + ps/2 - cw - (16-c[3])*scale < self.x and self.x < v[1] + ts + ps/2 - (16-c[3])*scale
				and t[1] >= 0 then
				t[1] = 0
			end
			-- top
			if v[1] - ps/2 + cw + c[1]*scale < self.x and self.x < v[1] + ts + ps/2 - cw - (16-c[3])*scale
				and v[2] - ps/2 + c[2]*scale < self.y and self.y < v[2] - ps/2 + cw + c[2]*scale
				and t[2] <= 0 then
				t[2] = 0
			end
			-- bottom
			if v[1] - ps/2 + cw + c[1]*scale < self.x and self.x < v[1] + ts + ps/2 - cw - (16-c[3])*scale
				and v[2] + ts + ps/2 - cw < self.y and self.y < v[2] + ts + ps/2
				and t[2] >= 0 then
				t[2] = 0
			end
		end
	end
	return t
end

function Player:draw()
	love.graphics.draw(self.tile, self.quad, math.floor(self.x), math.floor(self.y))
end

return Player

