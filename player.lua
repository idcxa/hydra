local Player = {}
Player.__index = Player

-- takes a single argument of a table of animations
function Player:new(anims, x, y, speed)
	local t = {
		x = x, y = y,
		anims = anims,
		tile,
		speed = speed*scale
	}
	t.quad = t.anims[1].quad
	setmetatable(t, self)
	return t
end

function Player:size()
	x, y, w, h = self.quad:getViewport()
	return w, h
end

-- switch animation based on the key
function Player:setAnimation(k)
	self.quad = self.anims[k].quad
	self.tile = self.anims[k].tile
end

function Player:playAnimation()
	for _, v in pairs(self.anims) do
		v:play()
	end
end

function Player:collision(t, camera, map, player)
	-- texture size
	local ts = map.texturesize
	-- player size
	local ps, psy = player:size()
	-- collision width
	local cw = 5

	-- object collision
	-- v display coordinates
	--[[for _, v in pairs(map.collidables) do
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
	end]]--
	return t
end

function Player:draw()
	love.graphics.draw(self.tile, self.quad, math.floor(self.x/scale), math.floor(self.y/scale))
end

return Player

