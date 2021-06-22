local Gui = {}
Gui.__index = Gui

function Gui:new(file, x, y, width, height)
	local t = {
		tiles = love.graphics.newImage(file),
		x = x,
		y = y,
		width = width,
		height = height,
		followmouse = false,
		select = {x, y},
		quad,
		layer = 1
	}
	setmetatable(t, self)
	return t
end

function Gui:move(mx, my)
	if love.mouse.isDown(2) then
		self.x = mx
	end
end

function Gui:selection(mx, my, scale, map)
	s = scale*16
	if love.mouse.isDown(1) then
		if mx > self.x + 5 then
			--self.select[1] = math.floor(((math.floor(mx/s)*s)-self.x)/s)
			--self.select[2] = ((math.floor(my/s)*s))/s
			local x = (mx-self.x - (mx+self.x)%s)/s
			local x = (mx-self.x - (mx-self.x)%s)/s
			local y = (my - (my)%s)/s
			self.select[1] = x
			self.select[2] = y
		end
	end
	--return self
	if love.keyboard.isDown("1") then
		self.layer = 1
	end
	if love.keyboard.isDown("2") then
		self.layer = 2
	end
	if love.keyboard.isDown("3") then
		self.layer = 3
	end
	if love.keyboard.isDown("0") then
		return nil
	end

	self.quad = love.graphics.newQuad(16*self.select[1], 16*self.select[2], 16, 16, map.tiles:getDimensions())
end

function Gui:draw(scale)
	--love.graphics.draw(map.tiles, self.quad, , 0)
	self.width = love.graphics.getWidth() - self.x
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", self.x/scale, 0, self.width, love.graphics.getHeight())
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", self.x/scale, 0, self.width, love.graphics.getHeight())
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(map.tiles, self.x/scale, 0)
	love.graphics.rectangle("line", self.select[1]*16 + self.x/scale, self.select[2]*16,16, 16)
end

return Gui
