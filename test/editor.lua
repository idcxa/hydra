love.graphics.setDefaultFilter("nearest", "nearest")
hybrid = require("hydra")

-- display
local function noise(map)
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

local function direction()
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

	-- load animations
		-- file, size, speed, repeat boolean
	idle = hybrid.newAnimation("assets/Animation-idle.png", 32, 32, 8, true)
	runr = hybrid.newAnimation("assets/Animation-runr.png", 32, 32, 8, true)
	runl = hybrid.newAnimation("assets/Animation-runl.png", 32, 32, 8, true)

	-- make a new player object with animations
		-- animation table, x, y, speed
	player = hybrid.newPlayer({idle, runr, runl}, 1, 3, 5)
	-- new camera
	camera = hybrid.newCamera()

	-- make a new map
		-- arguments: tiles, sizex, sizey, 16
	map = hybrid.newMap("maps/test.map")

	-- new gui element dont worry about it
	textures = hybrid.newElement("assets/testtiles-1.png", love.graphics.getWidth()*0.75, 0, love.graphics.getWidth()*0.25, height)

	-- loads the map file
	map:load("maps/test.map")

	-- set global texturesize
	map.texturesize = math.floor(love.graphics.getWidth()/map.pixelsize)

	-- set global scale
	scale = map.texturesize/map.pixelsize

	-- map size
	mapwx = map.width * map.texturesize - love.graphics.getWidth()
	mapwy = map.height * map.texturesize - love.graphics.getHeight()

	-- load all the textures
	-- should not be required
	--map:loadTextures(map.layers[1].textures, 16, 16, 1)
	--map:loadTextures(map.layers[2].textures, 16, 16, 2)
	--map:loadTextures(map.layers[3].textures, 16, 16, 2)
	--map:loadCollisionBoxes(collisionBoxes, 2)


	--player.speed = 0.1*scale

	--player:animation(idle)

	-- required for the camera to work with the player and the map
	camera:set(player, map)


	mx = love.mouse.getX()
	my = love.mouse.getY()

	mmx	= math.floor((mx - camera.x)/scale)
	mmy	= math.floor((my - camera.y)/scale)
	map:clean()
	--noise(map)
end

function love.wheelmoved(dx, dy)
	map.texturesize = map.texturesize + dy*16
end

local y = 0
local x = 0

-- on a single mouseclick take v1, v2
-- on mouse release take v3, v4

function love.mousepressed(x, y, button, istouch, presses)
	if mx < textures.x and button == 1
		and textures.layer == "collision" then
		local t = {}
		t[1] = math.floor((mx - camera.x)/scale)
		t[2] = math.floor((my - camera.y)/scale)
		table.insert(map.collision, t)
	end
	if mx < textures.x and button == 2
		and textures.layer == "collision" then
		for i, v in pairs(map.collision) do
			if math.floor((mx - camera.x)/scale) >= v[1]
				and math.floor((my - camera.y)/scale) <= v[2]
				and math.floor((mx - camera.x)/scale) <= v[3]
				and math.floor((my - camera.y)/scale) >= v[4]
				then
					print(i, v, #map.collision)
					if #map.collision == 0 then
						map.collision = {}
					end
					print(table.remove(map.collision, i))
			end
		end
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	if mx < textures.x and button == 1
		and textures.layer == "collision" then
		map.collision[#map.collision][3] = math.floor((mx - camera.x)/scale)
		map.collision[#map.collision][4] = math.floor((my - camera.y)/scale)
	end
end

function collision()
end

function love.update(dt)
	player:setAnimation(1)
	--print(love.graphics.getWidth()%map.texturesize)

	--map.texturesize = map.texturesize + love.graphics.getWidth()%map.texturesize
	--print((love.graphics.getWidth()%map.texturesize)*map.pixelsize)
	if love.keyboard.isDown("=") or love.keyboard.isDown("+") then
		map.texturesize = map.texturesize + 16
	elseif love.keyboard.isDown("-") or love.keyboard.isDown("_") then
		map.texturesize = map.texturesize - 16
	end

	--print(map.texturesize)

	-- set scaling stuff
	scale = math.floor(map.texturesize/map.pixelsize)
	map.texturesize = map.pixelsize*scale

	-- scale is divisible by height of screen
	--
	--print(map.texturesize, scale, love.graphics.getWidth()%scale)

	--scale = scale - (scale)%love.graphics.getWidth()
	--print(scale)
	y = os.clock()

	-- local function
	v = direction()

	--map:loadCollision(camera, 2)
	--v = player:collision(v, camera, map)

	--camera:movement(player, v)
	--print(player.x, player.y)
	camera.x = camera.x + v[1]
	camera.y = camera.y + v[2]

	--player.x = player.x - v[1]
	--player.y = player.y - v[2]
	--anim:play()
	--player.anims[1]:play()
	for _, v in pairs(player.anims) do
		v:play()
	end

	mx = love.mouse.getX()
	my = love.mouse.getY()
	mmx	= math.floor((mx - camera.x)/scale)
	mmy	= math.floor((my - camera.y)/scale)

	--camera.x = camera.x + v[1]
	--camera.y = camera.y + v[2]

	-- move the window
	textures:move(mx, my)

	-- select a texture based on the position of the mouse
	-- sets anim.quad to the selection and anim.layer to the layer selected
	textures:selection(mx, my, scale, map)

	--textures.layer = "collision"

	--[[
	if mx < textures.x and textures.layer == "collision" then
		k = collisionk
		if love.mouse.isDown(1) then
			map.collision[k] = {}
			if map.collision[k][1] == nil then
			end
		end
		if love.mouse.isDown == false then
			map.collision[k][3] = mx
			map.collision[k][4] = my
			collisionk = collisionk + 1
		else
			return
		end
	end
	]]--

	local s = map.texturesize
	local x = (mx - camera.x - (mx-camera.x)%s)/s + 1
	local y = (my - camera.y - (my-camera.y)%s)/s + 1
	if love.mouse.isDown(1) and mx < textures.x and type(textures.layer) == "number" then
		map:set(x, y, textures.layer, textures.quad)
	end

	if love.mouse.isDown(2) and mx < textures.x and type(textures.layer) == "number"  then
		map:set(x, y, textures.layer, nil)
	end

	if love.mouse.isDown(1) and mx < textures.x and textures.layer == "player" then
		player.x = mmx
		player.y = mmy
	end

	player.dx = math.floor(player.x/scale)*scale
	player.dy = math.floor(player.y/scale)*scale

	if love.keyboard.isDown("r") then
		--map:load("test.txt")
		noise(map)
	end
	if love.keyboard.isDown("lctrl") and love.keyboard.isDown("s") then
		map:save("maps/test.map")
		--love.event.quit()
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
	scale = map.texturesize/map.pixelsize

	love.graphics.push()
	----------
	love.graphics.scale(scale, scale)
	map:draw(cx, cy, 1)
	map:draw(cx, cy, 2)
	player:draw(player.x+camera.x/scale, player.y+camera.y/scale)
	map:draw(cx, cy, 3)
	map:drawCollision()

	textures:draw(scale)
	----------
	love.graphics.pop()

	if textures.layer == "collision" then
		love.graphics.print("collision (draw from bottom-left to top-right! right click to delete)", 0, 0, 0, 2)
	else
		love.graphics.print(textures.layer, 0, 0, 0, 5)
	end

	--print(string.format("fps:		%.0f\n", 1/(os.clock() - y)))
end

