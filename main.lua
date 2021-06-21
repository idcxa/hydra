love.graphics.setDefaultFilter("nearest", "nearest")
require "map"
hybrid = require "init"

-- display
function noise(map)
	map.layers[1].map = {}
	map.layers[2].map = {}
	for j = 1,map.width do
		for i = 1,map.height do
			map.layers[2].map[i+map.height*(j-1)] = love.math.noise(i+love.math.random(),j+love.math.random())
			local c = math.floor(1 * map.layers[2].map[i + (j-1)*map.height] + 0.2)
			if c > 0 then
				map.layers[2].map[i+map.height*(j-1)] = math.random(#collisionTextures)
			else
				map.layers[2].map[i+map.height*(j-1)] = c
			end

			map.layers[1].map[i+map.height*(j-1)] = math.random(#floorTextures)
		end
	end
	return map
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

local playerTrans
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	prelude = love.audio.newSource("assets/01-prelude.mp3", "static")
	--love.audio.play(prelude)

	--floorTextures = loadTextures(floorTextures, 16, 16)
	--collisionTextures = loadTextures(collisionTextures, 16, 16)

	camera = hybrid.newCamera()
	player = hybrid.newPlayer("assets/player.png")
	map    = hybrid.newMap("assets/testtiles-1.png", 50, 6, 80, 16)

	scale = map.texturesize/map.pixelsize
	mapwx = map.width * map.texturesize - love.graphics.getWidth()
	mapwy = map.height * map.texturesize - love.graphics.getHeight()

	map:newLayer()
	map:loadTextures(floorTextures, 16, 16, 1)
	map:newLayer()
	map:loadTextures(collisionTextures, 16, 16, 2)
	map:loadCollisionBoxes(collisionBoxes, 2)

	player.ox = player.texture:getPixelHeight()/2
	player.oy = player.texture:getPixelWidth()/2
	player.sx = map.texturesize * 0.8 / player.texture:getPixelHeight()
	player.sy = map.texturesize * 0.8 / player.texture:getPixelWidth()

	camera:set(player, map)
	noise(map)
end


--[[
1. camera follows psuedo camera 		[state 1]
2. camera hits border 					[enter state 2]
3. camera stops following pseudo camera	[state 2]
   and player starts moving
4. psuedo camera comes away from border [enter state 1]
5. camera follows pseudo camera			[state 1]
]]--

--local c = math.floor(1 * map.layers[2].map[i + (j-1)*map.height] + 0.2)

local y = 0
local x = 0
function love.update(dt)
	y = os.clock()

	v = direction()

	map:loadCollision(camera, 2)
	v = player:collision(v, camera, map)

	camera:movement(player, v)

	player.dx = math.floor(player.x/scale)*scale
	player.dy = math.floor(player.y/scale)*scale

	if love.keyboard.isDown("escape") or love.keyboard.isDown("q") then
		love.event.quit()
	end
end

function love.draw()
	x = os.clock()

	cx = math.floor(camera.x/scale)*scale
	cy = math.floor(camera.y/scale)*scale
	scale = map.texturesize/16

	love.graphics.push()
	love.graphics.scale(scale, scale)
	map:draw(cx, cy, 1)
	love.graphics.pop()

	player:draw()

	love.graphics.push()
	love.graphics.scale(scale, scale)
	map:draw(cx, cy, 2)
	love.graphics.pop()

	--print(string.format("fps:		%.0f\n", 1/(os.clock() - y)))
end

