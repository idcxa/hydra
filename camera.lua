local Camera = {}
Camera.__index = Camera

function Camera:new()
	local t = {x, y, pseudox, pseudoy, xmode, ymode}
	setmetatable(t, self)
	return t
end

function Camera:set(player, map)
	psx, psy = player:size()
	if player.x > love.graphics.getWidth()/2 then
		self.x = -player.x + love.graphics.getWidth()/2
		self.pseudox = self.x
		player.x = love.graphics.getWidth()/2
	else
		self.pseudox = love.graphics.getWidth()/2 - player.x - psx*scale/2
		self.x = 0
	end
	if player.y > love.graphics.getHeight()/2 then
		self.y = -player.y + love.graphics.getHeight()/2
		self.pseudoy = self.y
		player.y = love.graphics.getHeight()/2
	else
		self.pseudoy = love.graphics.getHeight()/2 - player.y - psy*scale/2
		self.y = 0
	end
	return self
end

function Camera:movement(player, v)
	psx, psy = player:size()
	self.xmode = 1
	self.ymode = 1
	if self.pseudox > 0 then
		self.xmode = 2
		self.x = scale
	end
	if self.pseudox < -mapwx then
		self.xmode = 2
		self.x = -mapwx - scale
	end
	if self.pseudoy > 0 then
		self.ymode = 2
		self.y = scale
	end
	if self.pseudoy < -mapwy then
		self.ymode = 2
		self.y = -mapwy - scale
	end

	self.pseudox = self.pseudox + v[1]
	self.pseudoy = self.pseudoy + v[2]

	if self.xmode == 1 then
		self.x = self.pseudox
		player.x = love.graphics.getWidth()/2 - psx*scale/2
	else
		player.x = player.x - v[1]
	end
	if self.ymode == 1 then
		self.y = self.pseudoy
		player.y = love.graphics.getHeight()/2 - psy*scale/2
	else
		player.y = player.y - v[2]
	end
end

return Camera

