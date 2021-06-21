require "map"
hybrid = require "init"

map = firstmap

scale = map.texturesize/map.pixelsize

function noise()
	for j = 1,map.width do
		for i = 1,map.height do
			map.collision[i+map.height*(j-1)] = love.math.noise(i+love.math.random(),j+love.math.random())
			local c = math.floor(1 * map.collision[i + (j-1)*map.height] + 0.2)
			if c > 0 then
				map.collision[i+map.height*(j-1)] = math.random(#collisionTextures)
			else
				map.collision[i+map.height*(j-1)] = 0
			end

			map.floor[i+map.height*(j-1)] = math.random(#floorTextures)
		end
	end
end

function direction()
	movement = {0,0}
	angle = player.speed*math.sin(45)
	if love.keyboard.isDown("up") then
		movement[2] = player.speed
	elseif love.keyboard.isDown("down")  then
		movement[2] = -player.speed
	end
	if love.keyboard.isDown("left") then
		movement[1] = player.speed
		if love.keyboard.isDown("up") then
			movement[1] = angle
			movement[2] = angle
		end
		if love.keyboard.isDown("down") then
			movement[1] = angle
			movement[2] = -angle
		end
	elseif love.keyboard.isDown("right")  then
		movement[1] = -player.speed
		if love.keyboard.isDown("up") then
			movement[1] = -angle
			movement[2] = angle
		end
		if love.keyboard.isDown("down") then
			movement[1] = -angle
			movement[2] = -angle
		end
	end
	return movement
end

function loadTextures(t, x, y)
	for i, v in pairs(t) do
		t[i] = love.graphics.newQuad(x*v[1], y*v[2], x, y, tiles:getDimensions())
	end
	return t
end

local playerTrans
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	playerTexture = love.graphics.newImage("assets/player.png")

	prelude = love.audio.newSource("assets/01-prelude.mp3", "static")
	love.audio.play(prelude)

	floorTextures = loadTextures(floorTextures, 16, 16)
	collisionTextures = loadTextures(collisionTextures, 16, 16)

	camera = hybrid.newCamera()
	player = hybrid.newPlayer()

	player.ox = playerTexture:getPixelHeight()/2
	player.oy = playerTexture:getPixelWidth()/2
	player.sx = map.texturesize * 0.8 / playerTexture:getPixelHeight()
	player.sy = map.texturesize * 0.8 / playerTexture:getPixelWidth()

	camera:setCamera(player)
	noise()
end

mapwx = map.width * map.texturesize - love.graphics.getWidth()
mapwy = map.height * map.texturesize - love.graphics.getHeight()

--[[
1. camera follows psuedo camera 		[state 1]
2. camera hits border 					[enter state 2]
3. camera stops following pseudo camera	[state 2]
   and player starts moving
4. psuedo camera comes away from border [enter state 1]
5. camera follows pseudo camera			[state 1]
]]--

function loadCollision()
	collidables = {}
	for j = 1,map.width do
		for i = 1,map.height do
			--local c = math.floor(1 * map.collision[i + (j-1)*map.height] + 0.2)
			local c = map.collision[i + (j-1)*map.height]
			if c > 0 then
				collidables[i + (j-1)*map.height] = collidables[i + (j-1)*map.height] or {}
				local t = {
					j*map.texturesize - map.texturesize + camera.x,
					i*map.texturesize - map.texturesize + camera.y,
					{0, 0, 16, 16},
					c
				}
				if c == 1 then
					t[3] = {5, 2, 16, 16}
				end
				if c == 2 then
					t[3] = {3, 2, 14, 16}
				end
				table.insert(collidables, t)
			end
		end
	end
end

function playerCollision(t)
	-- texture size
	local ts = map.texturesize
	-- player size
	local ps = map.texturesize*0.8
	-- collision width
	local cw = 5
	scale = map.texturesize/map.pixelsize

	-- map border collision
	-- left
	if player.x < ps/2 - player.speed/2 then
		player.x = ps/2
		camera.pseudox = love.graphics.getWidth()/2
	end
	-- right
	if player.x > map.width * ts - ts/2 + camera.x + player.speed/2 then
		player.x = map.width * ts - ts/2 + camera.x
		camera.pseudox = -map.texturesize*map.width + love.graphics.getWidth()/2
	end
	-- top
	if player.y < ts/2 - player.speed/2 then
		player.y = ts/2
		camera.pseudoy = love.graphics.getHeight()/2
	end
	-- bottom
	if player.y > map.height * ts - ts/2 + camera.y + player.speed/2 then
		player.y = map.height * ts - ts/2 + camera.y
		camera.pseudoy = -map.texturesize*map.height + love.graphics.getHeight()/2
	end

	-- object collision
	-- v display coordinates
	for _, v in pairs(collidables) do
		if v[2] ~= nil then
			c = v[3]
			-- left
			if v[2] - ps/2 + cw + c[2]*scale < player.y and player.y < v[2] + ts + ps/2 - cw
				and v[1] - ps/2 + c[1]*scale < player.x and player.x < v[1] - ps/2 + cw + c[1]*scale
				and t[1] <= 0 then
				t[1] = 0
			end
			-- right
			if v[2] - ps/2 + cw + c[2]*scale < player.y and player.y < v[2] + ts + ps/2 - cw
				and v[1] + ts + ps/2 - cw - (16-c[3])*scale < player.x and player.x < v[1] + ts + ps/2 - (16-c[3])*scale
				and t[1] >= 0 then
				t[1] = 0
			end
			-- top
			if v[1] - ps/2 + cw + c[1]*scale < player.x and player.x < v[1] + ts + ps/2 - cw - (16-c[3])*scale
				and v[2] - ps/2 + c[2]*scale < player.y and player.y < v[2] - ps/2 + cw + c[2]*scale
				and t[2] <= 0 then
				t[2] = 0
			end
			-- bottom
			if v[1] - ps/2 + cw + c[1]*scale < player.x and player.x < v[1] + ts + ps/2 - cw - (16-c[3])*scale
				and v[2] + ts + ps/2 - cw < player.y and player.y < v[2] + ts + ps/2
				and t[2] >= 0 then
				t[2] = 0
			end
		end
	end
	return t
end

local y = 0
local x = 0
function love.update(dt)
	y = os.clock()
	--print(player.x, camera.x, camera.pseudox)

	playerTrans = love.math.newTransform(player.dx, player.dy, player.angle, player.sx, player.sy, player.ox, player.oy, player.kx, player.ky)

	v = direction()

	loadCollision()
	v = playerCollision(v)

	camera:movement(player, v)

	player.dx = math.floor(player.x/scale)*scale
	player.dy = math.floor(player.y/scale)*scale

	if love.keyboard.isDown("escape") or love.keyboard.isDown("q") then
		love.event.quit()
	end

	--print(player.x, camera.x, camera.pseudox)
end

function drawFloor(cx, cy)
	for j = 1,map.width do
		for i = 1,map.height do
			local c = map.floor[i + (j-1)*map.height]
			love.graphics.draw(tiles, floorTextures[c], (j*map.texturesize - map.texturesize + cx)/scale, (i*map.texturesize - map.texturesize + cy)/scale)
		end
	end
end

function drawCollision(cx, cy)
	for j = 1,map.width do
		for i = 1,map.height do
			local c = map.collision[i + (j-1)*map.height]
			r = math.random(#floorTextures)
			if c > 0 then
				love.graphics.draw(tiles, collisionTextures[c], (j*map.texturesize - map.texturesize + cx)/scale, (i*map.texturesize - map.texturesize + cy)/scale)
			end
		end
	end
end

function love.draw()
	x = os.clock()

	cx = math.floor(camera.x/scale)*scale
	cy = math.floor(camera.y/scale)*scale
	scale = map.texturesize/16

	love.graphics.push()
	love.graphics.scale(scale, scale)
	drawFloor(cx, cy)
	love.graphics.pop()

	-- need 16x16 player texture!
	love.graphics.draw(playerTexture, playerTrans)

	love.graphics.push()
	love.graphics.scale(scale, scale)
	drawCollision(cx, cy)
	love.graphics.pop()

	--print(string.format("fps:		%.0f\n", 1/(os.clock() - y)))
end

