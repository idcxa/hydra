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

function Player:collision(t, camera, map, layer)
	-- texture size
	local ts = map.texturesize
	-- player size
	local psx, psy = self:size()
	psx = psx*scale
	psy = psy*scale
	-- player position
	local px = math.floor((player.x+scale/2)/scale)*scale
	- math.floor((camera.x+scale/2)/scale)*scale

	local py = math.floor((player.y+scale/2)/scale)*scale
	- math.floor((camera.y+scale/2)/scale)*scale
	-- collision width
	local cw = scale*2

	--map.layers[layer].collision

	-- object collision
	for k, v in pairs(map.layers[layer].map) do
		if v > 0 then
			x = (math.floor(k/map.height+0.9))*ts
			y = (k - map.height*(x/ts-1))*ts
			-- left
			if x-ts-psx <= px and px < x and
				y-ts-psy < py and py < y
				and t[1] <= 0 then
				t[1] = 0
			end
			-- right
			if x >= px and px > x-ts-psy and
				y - ts - psy < py and py < y
				and t[1] >= 0 then
				t[1] = 0
			end
			-- top
			if y-ts-psy <= py and py < y and
				x-ts-psx < px and px < x
				and t[2] <= 0 then
				t[2] = 0
				if py > y-ts-psy then
					t[2] = player.speed*2 end
			end
			-- bottom
			if y >= py and py > y-cw and
				x-ts-psx < px and px < x
				and t[2] >= 0 then
				t[2] = 0
				if py < y then
					t[2] = -player.speed*2 end
			end
		end
	end
	return t
end

function Player:draw(px, py)
	px = math.floor((player.x+scale/2)/scale)*scale
	py = math.floor((player.y+scale/2)/scale)*scale
	love.graphics.draw(self.tile, self.quad, px/scale, py/scale)
end

return Player

