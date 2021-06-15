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
	speed = 2
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
			map.map[i+map.height*(j-1)] = love.math.noise(i+love.math.random(),j+love.math.random())
		end
	end
end
function random()
	for j = 1,map.width do
		for i = 1,map.height do
			map.map[i+map.height*(j-1)] = math.random(2)-1
		end
	end
end

function direction()
	movement = vector.new_vector{0,0}
	if love.keyboard.isDown("left") then
		movement[1] = player.speed
	elseif love.keyboard.isDown("right")  then
		movement[1] = -player.speed
	end
	if love.keyboard.isDown("up") then
		movement[2] = player.speed
	elseif love.keyboard.isDown("down")  then
		movement[2] = -player.speed
	end
	if love.keyboard.isDown("right") and love.keyboard.isDown("up") then
		movement[1] = -player.speed*math.sin(45)
		movement[2] = player.speed*math.sin(45)
	elseif love.keyboard.isDown("right") and love.keyboard.isDown("down") then
		movement[1] = -player.speed*math.sin(45)
		movement[2] = -player.speed*math.sin(45)
	elseif love.keyboard.isDown("left") and love.keyboard.isDown("up") then
		movement[1] = player.speed*math.sin(45)
		movement[2] = player.speed*math.sin(45)
	elseif love.keyboard.isDown("left") and love.keyboard.isDown("down") then
		movement[1] = player.speed*math.sin(45)
		movement[2] = -player.speed*math.sin(45)
	end
	return movement
end

function cameraSet()
	if camera.x > 0 then
		camera.x = 0;
	end
	if camera.x < -mapwx then
		camera.x = -mapwx;
	end
	if camera.y > 0 then
		camera.y = 0;
	end
	if camera.y < -mapwy then
		camera.y = -mapwy;
	end
	camera.pseudox = camera.x
	camera.pseudoy = camera.y
end


function love.load()
	playerTexture = love.graphics.newImage("assets/shork.png");
	player.ox = playerTexture:getPixelHeight()/2;
	player.oy = playerTexture:getPixelWidth()/2;
	noise()
	cameraSet()
end

mapwx = map.width * map.texturesize - love.graphics.getWidth()
mapwy = map.height * map.texturesize - love.graphics.getHeight()


function cameraCollision()
	if camMode == true then
		if camera.pseudox < 0 then
			camera.x = camera.pseudox;
			camMode = false
		end
		if camera.pseudox > -mapwx then
			camera.x = camera.pseudox;
			camMode = false
		end
		if camera.pseudoy < 0 then
			camera.y = camera.pseudoy;
			camMode = false
		end
		if camera.pseudoy > -mapwy then
			camera.y = camera.pseudoy;
			camMode = false
		end
	end
	camMode = true
	if camera.x > 0 then
		camera.x = 0;
		camMode = false
	end
	if camera.x < -mapwx then
		camera.x = -mapwx;
		camMode = false
	end
	if camera.y > 0 then
		camera.y = 0;
		camMode = false
	end
	if camera.y < -mapwy then
		camera.y = -mapwy;
		camMode = false
	end
	print(camMode)
	camMode = true
end


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

function cameraCollision2()
	if camera.pseudox > 0 then
		camModex = 2;
	end
	if camera.pseudox < -mapwx then
		camModex = 2;
	end
	if camera.pseudoy > 0 then
		camModey = 2;
	end
	if camera.pseudoy < -mapwy then
		camModey = 2;
	end
end


function love.update(dt)
	playerTrans = love.math.newTransform(player.x, player.y, player.angle, player.sx, player.sy, player.ox, player.oy, player.kx, player.ky);

	v = direction()

	camera.pseudox = camera.pseudox + v[1]
	camera.pseudoy = camera.pseudoy + v[2]

	camModex = 1
	camModey = 1
	cameraCollision2()
	--print(camMode)

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
			--print(map.map[i+map.width*(j-1)])
			local c = math.floor(1 * map.map[i + (j-1)*map.height] + 0.5)
			love.graphics.setColor(c, c, c, 1)
			love.graphics.rectangle("fill", j*map.texturesize - map.texturesize + camera.x, i*map.texturesize - map.texturesize + camera.y, map.texturesize, map.texturesize)
			love.graphics.setColor(1, 1, 1, 1)
			--[[if map.map[i + (j-1) * (map.width)] == 1 then
				love.graphics.rectangle("line", j*map.texturesize - map.texturesize + camera.x, i*map.texturesize - map.texturesize + camera.y, map.texturesize, map.texturesize)
			else
				love.graphics.rectangle("fill", j*map.texturesize - map.texturesize + camera.x, i*map.texturesize - map.texturesize + camera.y, map.texturesize, map.texturesize)
			end]]--
		end
	end
end

function love.draw()
	drawmap()
	love.graphics.draw(playerTexture, playerTrans)
end
