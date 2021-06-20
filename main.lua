require "data"
require "map"

local playerTrans

local vector = Vector()

map = firstmap

player = {
	x = love.graphics.getWidth()/2,
	y = love.graphics.getHeight()/2,
	angle = 0,
	sx = 0.2,
	sy = 0.2,
	ox = 0.5,
	oy = 0.5,
	kx = 0,
	ky = 0,
	movement = vector.new_vector{0, 0},
	speed = 1
}

camera = {
	x = -love.graphics.getWidth(),
	y = -love.graphics.getHeight(),
	movement = vector.new_vector{0, 0},
	pseudox = -love.graphics.getWidth(),
	pseudoy = -love.graphics.getHeight()
}

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

			map.map[i+map.height*(j-1)] = math.random(#floorTextures)
		end
	end
end

function random()
	for j = 1,map.width do
		for i = 1,map.height do
			map.map[i+map.height*(j-1)] 		= math.random(#floorTextures)
			map.collision[i+map.height*(j-1)] 	= math.random(#collisionTextures)
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

function cameraSet()
	if camera.x > 0 then
		camera.x = 0
	end
	if camera.x < -mapwx then
		camera.x = -mapwx
	end
	if camera.y > 0 then
		camera.y = 0
	end
	if camera.y < -mapwy then
		camera.y = -mapwy
	end
	camera.pseudox = camera.x
	camera.pseudoy = camera.y
end


function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	playerTexture = love.graphics.newImage("assets/player.png")

	player.ox = playerTexture:getPixelHeight()/2
	player.oy = playerTexture:getPixelWidth()/2
	player.sx = map.texturesize * 0.8 / playerTexture:getPixelHeight()
	player.sy = map.texturesize * 0.8 / playerTexture:getPixelWidth()
	noise()
	cameraSet()
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

camModex = 1
camModey = 1

function cameraCollision()
	if camera.pseudox > 0 then
		camModex = 2
	end
	if camera.pseudox < -mapwx then
		camModex = 2
	end
	if camera.pseudoy > 0 then
		camModey = 2
	end
	if camera.pseudoy < -mapwy then
		camModey = 2
	end
end

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
	--collidables = {}
	--table.insert(collidables, {map.texturesize*10 + camera.x, map.texturesize*15 + camera.y})
	--table.insert(collidables, {map.texturesize*5 + camera.x, map.texturesize*15 + camera.y})
	--table.insert(collidables, {map.texturesize*12 + camera.x, map.texturesize*15 + camera.y})
	--table.insert(collidables, {700,200})
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
					print(v[1] - ps/2 + cw + c[1]*2, player.x)
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

function love.update(dt)
	playerTrans = love.math.newTransform(player.x, player.y, player.angle, player.sx, player.sy, player.ox, player.oy, player.kx, player.ky)

	v = direction()

	loadCollision()
	v = playerCollision(v)

	camModex = 1
	camModey = 1
	cameraCollision()

	camera.pseudox = camera.pseudox + v[1]
	camera.pseudoy = camera.pseudoy + v[2]

	if camModex == 1 then
		camera.x = camera.pseudox
	else
		player.x = player.x - v[1]
	end
	if camModey == 1 then
		camera.y = camera.pseudoy
	else
		player.y = player.y - v[2]
	end


	if love.keyboard.isDown("w") then
		noise()
	end
	if love.keyboard.isDown("e") then
		random()
	end
	if love.keyboard.isDown("escape") or love.keyboard.isDown("q") then
		love.event.quit()
	end
end

function drawmap()
	screenx = love.graphics.getWidth()
	screeny = screenx
	for j = 1,map.width do
		for i = 1,map.height do
			local c = map.map[i + (j-1)*map.height]
			love.graphics.draw(testTiles, floorTextures[c], (j*map.texturesize - map.texturesize + camera.x)/scale, (i*map.texturesize - map.texturesize + camera.y)/scale)
		end
	end
end

function drawcollision()
	screenx = love.graphics.getWidth()
	screeny = screenx
	for j = 2,map.width-1 do
		for i = 2,map.height-1 do
			local c = map.collision[i + (j-1)*map.height]
			r = math.random(#floorTextures)
			if c > 0 then
				love.graphics.draw(testTiles, collisionTextures[c], (j*map.texturesize - map.texturesize + camera.x)/scale, (i*map.texturesize - map.texturesize + camera.y)/scale)
			end
		end
	end
end

function love.draw()

	love.graphics.push()
	scale = map.texturesize/16
	love.graphics.scale(scale, scale)
	drawmap()
	drawcollision()
	love.graphics.pop()

	love.graphics.draw(playerTexture, playerTrans)
	love.graphics.push()
	scale = map.texturesize/16
	love.graphics.scale(scale, scale)
	for _, v in pairs(collidables) do
		if v[2] ~= nil and v[4] ~= nil then
			--local c = math.floor(1 * map.map[i + (j-1)*map.height] + 0.2)
			love.graphics.draw(testTiles, collisionTextures[v[4]], v[1]/scale, v[2]/scale)
			--love.graphics.rectangle("fill", v[1]/scale, v[2]/scale, map.texturesize, map.texturesize)
		end
	end
	love.graphics.pop()
end

