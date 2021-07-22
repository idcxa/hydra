local Entity = {}
Entity.__index = Entity

-- takes a single argument of a table of animations
function Entity:new(anims, x, y, speed)
	local t = {
		x = x, y = y,
		anims = anims,
		speed = speed*scale
	}
	t.quad = t.anims[1].quad
	setmetatable(t, self)
	return t
end

function Entity:draw(px, py)
	love.graphics.draw(self.tile, self.quad, px/scale, py/scale)
end

return Entity
