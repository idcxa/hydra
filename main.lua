love.graphics.setDefaultFilter("nearest", "nearest")
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

function love.load()

	prelude = love.audio.newSource("assets/01-prelude.mp3", "static")
	--love.audio.play(prelude)

	--floorTextures = loadTextures(floorTextures, 16, 16)
	--collisionTextures = loadTextures(collisionTextures, 16, 16)

	camera = hybrid.newCamera()
	player = hybrid.newPlayer("assets/player.png")
	--map    = hybrid.newMap("assets/testtiles-1.png", 16, 9, 80, 16)
	map = hybrid.newMap("assets/testtiles-1.png", 11, 9, 80, 16)
	textures = hybrid.newElement("assets/testtiles-1.png", love.graphics.getWidth()*0.75, 0, love.graphics.getWidth()*0.25, height)

	map:load("test.txt")

	--for k, v in pairs(map.layers) do print(k, v) end
	--print(map.layers[2])
	map.texturesize = math.floor(love.graphics.getWidth()/map.pixelsize)

	scale = map.texturesize/map.pixelsize
	player.speed = 1*scale
	mapwx = map.width * map.texturesize - love.graphics.getWidth()
	mapwy = map.height * map.texturesize - love.graphics.getHeight()

	map:loadTextures(map.layers[1].textures, 16, 16, 1)
	map:loadTextures(map.layers[2].textures, 16, 16, 2)
	--map:loadCollisionBoxes(collisionBoxes, 2)

	anim = hybrid.newAnimation("assets/Animation-run.png", 32, 32)


	player.ox = player.texture:getPixelHeight()/2
	player.oy = player.texture:getPixelWidth()/2
	player.sx = map.texturesize * 0.8 / player.texture:getPixelHeight()
	player.sy = map.texturesize * 0.8 / player.texture:getPixelWidth()

	camera:set(player, map)
	--noise(map)
end

function love.wheelmoved(dx, dy)
	map.texturesize = map.texturesize + dy
end

local y = 0
local x = 0

a = coroutine.create(function()
	i = 1
	while(true) do
		if i > 5 then i = 1 end

		print(i)
		i = i + 1
		coroutine.yield()
	end
end)

for i = 1,15 do
	coroutine.resume(a)
end

function love.update(dt)
	y = os.clock()

	--v = direction()

	--map:loadCollision(camera, 2)
	--v = player:collision(v, camera, map)

	--camera:movement(player, v)
	anim:play(0, 0)
	mx = love.mouse.getX()
	my = love.mouse.getY()

	if love.keyboard.isDown("left") then
		camera.x = camera.x + 10
	end
	if love.keyboard.isDown("right") then
		camera.x = camera.x - 10
	end
	if love.keyboard.isDown("up") then
		camera.y = camera.y + 10
	end
	if love.keyboard.isDown("down") then
		camera.y = camera.y - 10
	end

	-- move the window
	textures:move(mx, my)

	-- select a texture based on the position of the mouse
	-- sets anim.quad to the selection and anim.layer to the layer selected
	textures:selection(mx, my, scale, map)

	if love.mouse.isDown(1) and mx < textures.x then
		local s = map.texturesize
		local x = (mx - camera.x - (mx-camera.x)%s)/s + 1
		local y = (my - camera.y - (my-camera.y)%s)/s + 1

		map:set(x, y, textures.layer, textures.quad)
	end


	player.dx = math.floor(player.x/scale)*scale
	player.dy = math.floor(player.y/scale)*scale

	if love.keyboard.isDown("r") then
		--map:load("test.txt")
		noise(map)
	end
	if love.keyboard.isDown("lctrl") and love.keyboard.isDown("s") then
		map:save("test.txt")
		love.event.quit()
	end
	if love.keyboard.isDown("f") then
		love.window.setFullscreen(true, "desktop")
	end
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

	--`player:draw()

	love.graphics.push()
	love.graphics.scale(scale, scale)
	anim:draw()
	map:draw(cx, cy, 2)

	textures:draw(scale)
	love.graphics.pop()

	--print(string.format("fps:		%.0f\n", 1/(os.clock() - y)))
end

