local Player = {}
Player.__index = Player

function Player:new(file)
	-- too many variables, will fix
	local t = {
		texture = love.graphics.newImage(file),
		ps = 14,
		x = 144,
		y = love.graphics.getHeight()/2,
		dx = x,
		dy = y,
		angle = 0,
		sx = 0.2,
		sy = 0.2,
		ox = 0.5,
		oy = 0.5,
		kx = 0,
		ky = 0,
		speed = 5
	}
	setmetatable(t, self)
	return t
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

-- make better you dumb stupid bitch
function Player:draw()
	playerTrans = love.math.newTransform(player.dx, player.dy, player.angle, player.sx, player.sy, player.ox, player.oy, player.kx, player.ky)
	-- need 16x16 player texture!
	love.graphics.draw(self.texture, playerTrans)
end

return Player

