local Anim = {}
Anim.__index = Anim

-- new animtion
function Anim:new(file, sx, sy)
	local t = {
		tiles = love.graphics.newImage(file),
		sx = sx, sy = sy,
		run = false,
		quad,
		x, y
	}
	t.quad = love.graphics.newQuad(0, 0, sx, sy, t.tiles:getDimensions())
	setmetatable(t, self)
	return t
end

-- run animation
function Anim:play(x, y)
	--print("play()")
	--if self.run then return end

	self.run = true
	self.x = x
	self.y = y
	self.a = coroutine.create(function()
		--print(0, "to", self.tiles:getPixelWidth()/self.sx)
		for i = 0, self.tiles:getPixelWidth()/self.sx do
			self.quad:setViewport(i*self.sx, 0, self.sx, self.sy, self.tiles:getDimensions())
			--print(i)
			coroutine.yield()
		end
	end)
	coroutine.resume(a)
	--[[run = coroutine.create(function()
		while(self.run) do
			for i = 0, self.tiles:getPixelWidth()/self.sx do
				print(i)
				self.quad:setViewport(i*self.sx, 0, self.sx, self.sy, self.tiles:getDimensions())
			end
			--coroutine.yield()
		end
	end)
	if love.keyboard.isDown("right") then
	end
	--coroutine.resume(run)
	idle = coroutine.create(function()
		coroutine.yield(run)
		while(self.run) do
			for i = 0, self.tiles:getPixelWidth()/self.sx do
				print(i)
				self.quad:setViewport(i*self.sx, 0, self.sx, self.sy, self.tiles:getDimensions())
			end
			coroutine.yield()
			coroutine.resume(run)
		end
	end)
	coroutine.resume(run)]]--
end

-- stop animation
function Anim:stop()
	self.run = false
end

-- draw animation
function Anim:draw()
	love.graphics.draw(self.tiles, self.quad, self.x, self.y)
end

return Anim

