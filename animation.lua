local Anim = {}
Anim.__index = Anim

-- new animtion
function Anim:new(file, sx, sy, speed, loop)
	local t = {
		tile = love.graphics.newImage(file),
		sx = sx, sy = sy,
		quad,
		x, y,
		loop = loop,
		speed = speed
	}
	t.quad = love.graphics.newQuad(0, 0, sx, sy, t.tile:getDimensions())
	t.anim = coroutine.create(
	function(anim)
		i = 0
		while true do
			x, y, w, h = anim.quad:getViewport()
			if x+anim.sx == anim.tile:getPixelWidth() then
				x = -anim.sx
				if anim.loop == false then break end
			end
			if i == anim.speed then
				i = 0
				anim.quad:setViewport(x+anim.sx, y, anim.sx, anim.sy, anim.tile:getDimensions())
			end
			i = i + 1
			coroutine.yield()
		end
	end)
	setmetatable(t, self)
	return t
end

-- run animation
function Anim:play()
	coroutine.resume(self.anim, self)
end

function Anim:stop()
	self = nil
end

-- draw animation
function Anim:draw(cx, cy)
	love.graphics.draw(self.tile, self.quad, cx, cy)
end

return Anim

