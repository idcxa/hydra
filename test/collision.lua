love.graphics.setDefaultFilter("nearest", "nearest")
require("test/defaults")
hybrid = require("hydra")

-- display
function noise(map)
	map.layers[1].map = {}
	map.layers[2].map = {}
	for j = 1,map.width do
		for i = 1,map.height do
			map.layers[2].map[i+map.height*(j-1)] = love.math.noise(i+love.math.random(),j+love.math.random())
			local c = math.floor(1 * map.layers[2].map[i + (j-1)*map.height] + 0.2)
			if c > 0 then
				map.layers[2].map[i+map.height*(j-1)] = math.random(#map.layers[2].textures)
			else
				map.layers[2].map[i+map.height*(j-1)] = c
			end
			map.layers[1].map[i+map.height*(j-1)] = math.random(#map.layers[1].textures)
		end
	end
	return map
end

function direction()
	movement = {0,0}
	local angle = player.speed
	local speed = player.speed
	if love.keyboard.isDown("up") then
		movement[2] = speed
	elseif love.keyboard.isDown("down")  then
		movement[2] = -speed
	end
	if love.keyboard.isDown("left") then
		movement[1] = speed
		if love.keyboard.isDown("up") then
			movement[1] = angle
			movement[2] = angle
		end
		if love.keyboard.isDown("down") then
			movement[1] = angle
			movement[2] = -angle
		end
	elseif love.keyboard.isDown("right")  then
		movement[1] = -speed
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

function collisionTest()
	for j = 1,map.width do
		for i = 1,map.height do
			map.layers[2].map[i+map.height*(j-1)] = 0
		end
	end
	--map.layers[2].map[5+map.height*(5-1)] = 5
	--map.layers[2].map[6+map.height*(9-1)] = 1
	map.layers[2].map[4+map.height*(3-1)] = 1
	map.layers[2].map[4+map.height*(6-1)] = 2
	map.layers[2].map[4+map.height*(7-1)] = 3
	--map.layers[2].map[8+map.height*(10-1)] = 1
	--map.layers[2].map[7+map.height*(10-1)] = 5
	--map.layers[2].map[7+map.height*(9-1)] = 5
	--map.layers[2].map[9+map.height*(8-1)] = 5
	--map.layers[2].map[9+map.height*(7-1)] = 5
end

function love.load()

	prelude = love.audio.newSource("assets/01-prelude.mp3", "static")
	--love.audio.play(prelude)

	idle = hybrid.newAnimation("assets/Animation-idle.png", 32, 32, 8, true)
	runr = hybrid.newAnimation("assets/Animation-runr.png", 32, 32, 8, true)
	runl = hybrid.newAnimation("assets/Animation-runl.png", 32, 32, 8, true)
	test = hybrid.newAnimation("assets/testplayer.png", 14, 14, 8, true)

	camera = hybrid.newCamera()
	map    = hybrid.newMap("maps/test.map")

	map.pixelsize = 16
	map.texturesize = math.floor(love.graphics.getWidth()/map.pixelsize)
	map.texturesize = 80
	scale = map.texturesize/map.pixelsize

	player = hybrid.newPlayer({test}, 160*3+10, 1000, 1)

	--map:loadTextures(floorTextures, 16, 16, 1)
	--map:loadTextures(collisionTextures, 16, 16, 2)

	map:load("maps/test.map")

	mapwx = map.width * map.texturesize - love.graphics.getWidth()
	mapwy = map.height * map.texturesize - love.graphics.getHeight()

	--map:loadTextures(map.layers[1].textures, 16, 16, 1)
	--map:loadTextures(map.layers[2].textures, 16, 16, 2)
	--map:loadTextures(map.layers[3].textures, 16, 16, 2)

	--map:loadCollisionBoxes(collisionBoxes, 2)

	camera:set(player, map)
	--map.width = 16
	--noise(map)
	--collisionTest()
end

--local c = math.floor(1 * map.layers[2].map[i + (j-1)*map.height] + 0.2)

local y = 0
local x = 0
function love.update(dt)
	y = os.clock()

	player:setAnimation(1)

	v = direction()

	--io.write("\n\n")
	--[[
	if v[1] > 0 then
		player:setAnimation(3)
	elseif v[1] < 0 then
		player:setAnimation(2)
	end
	]]--

	--player:playAnimation()

	--print(camera.x, camera.pseudox, player.x)

	--map:loadCollision(camera, 2)
	v = player:collision(v, camera, map, 2)


	camera:movement(player, v)
	--print(camera.xmode, camera.ymode)


	if love.keyboard.isDown("escape") or love.keyboard.isDown("q") then
		love.event.quit()
	end
end

local function drawLayerBoxes(map, layer, size)
	for j = 1,map.width do
		for i = 1,map.height do
			local c = map.layers[layer].map[i + (j-1)*map.height]
			if c > 0 then
				love.graphics.setColor(1, 0, 0, 1)
				love.graphics.setLineWidth(0.1)
				love.graphics.rectangle("line",
				(j*map.texturesize - map.texturesize + cx)/scale,
				(i*map.texturesize - map.texturesize + cy)/scale,
				16, 16)
				love.graphics.setColor(1, 1, 1, 1)
			end
		end
	end
end

function love.draw()
	x = os.clock()

	cx = math.floor((camera.x+scale/2)/scale)*scale
	cy = math.floor((camera.y+scale/2)/scale)*scale
	--cx = camera.x
	--cy = camera.y

	--px = player.x
	--py = player.y

	love.graphics.push()
	love.graphics.scale(scale, scale)
	map:draw(cx, cy, 1)
	player:draw()
	map:draw(cx, cy, 2)
	map:draw(cx, cy, 3)
	drawLayerBoxes(map, 2)
	love.graphics.pop()

	love.graphics.setColor(0, 0, 0, 1)
	--love.graphics.rectangle("line", -1, -1, love.graphics.getWidth()/2+1, love.graphics.getHeight()/2+1)
	--love.graphics.rectangle("line", love.graphics.getWidth()/2, love.graphics.getHeight()/2, love.graphics.getWidth()/2+1, love.graphics.getHeight()/2+1)
	love.graphics.setColor(1, 1, 1, 1)

	--print(string.format("fps:		%.0f\n", 1/(os.clock() - y)))
end

