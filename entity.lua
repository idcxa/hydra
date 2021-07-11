local Entity = {}
Entity.__index = entity

-- takes a single argument of a table of animations
function Entity:new(anims, x, y, speed)
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

function Player:draw(px, py)
	love.graphics.draw(self.tile, self.quad, px/scale, py/scale)
end

return Entity
