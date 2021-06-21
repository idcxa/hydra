local Player = {}
Player.__index = Player

function Player:new()
	local t = {
		x = 1000,
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
		movement = {0, 0},
		speed = 5
	}
	setmetatable(t, self)
	return t
end

return Player

