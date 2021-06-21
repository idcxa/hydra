local Camera = {}
Camera.__index = Camera

function Camera:new()
	local t = {x, y, pseudox, pseudoy, xmode, ymode}
	setmetatable(t, self)
	return t
end

function Camera:set(player, map)
	if player.x > love.graphics.getWidth()/2 then
		self.x = -player.x + love.graphics.getWidth()/2
		self.pseudox = self.x
		player.x = love.graphics.getWidth()/2
	else
		self.pseudox = love.graphics.getWidth()/2 - player.x + map.pixelsize*2
		self.x = 5
	end
	if player.y > love.graphics.getHeight()/2 then
		self.y = -player.y + love.graphics.getHeight()/2
		self.pseudox = self.y
		player.y = love.graphics.getHeight()/2
	else
		self.pseudoy = love.graphics.getHeight()/2 - player.y + map.pixelsize*2
		self.y = 5
	end
	return self
end

function Camera:movement(player, v)
	self.xmode = 1
	self.ymode = 1
	if self.pseudox > 0 then
		self.xmode = 2
	end
	if self.pseudox < -mapwx then
		self.xmode = 2
	end
	if self.pseudoy > 0 then
		self.ymode = 2
	end
	if self.pseudoy < -mapwy then
		self.ymode = 2
	end

	self.pseudox = self.pseudox + v[1]
	self.pseudoy = self.pseudoy + v[2]

	if self.xmode == 1 then
		self.x = self.pseudox
	else
		player.x = player.x - v[1]
	end
	if self.ymode == 1 then
		self.y = self.pseudoy
	else
		player.y = player.y - v[2]
	end
	return self
end

return Camera

