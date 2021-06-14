require "data"
require "map"

local playerTrans

local vector = Vector()

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
	speed = 4
}

camera = {
	x = -love.graphics.getWidth(),
	y = -love.graphics.getHeight(),
	movement = vector.new_vector{0, 0},
}

function love.load()
	playerTexture = love.graphics.newImage("shork.png");
	player.ox = playerTexture:getPixelHeight()/2;
	player.oy = playerTexture:getPixelWidth()/2;
end

mapwx = firstmap.mapwidth-love.graphics.getWidth()
mapwy = firstmap.mapheight-love.graphics.getHeight()

function cameraCollision()
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
end

function love.update(dt)
	playerTrans = love.math.newTransform(player.x, player.y, player.angle, player.sx, player.sy, player.ox, player.oy, player.kx, player.ky);

	camera.movement[1] = 0;
	camera.movement[2] = 0;

	if love.keyboard.isDown("left") then
		camera.movement[1] = player.speed
	elseif love.keyboard.isDown("right")  then
		camera.movement[1] = -player.speed
	end
	if love.keyboard.isDown("up") then
		camera.movement[2] = player.speed
	elseif love.keyboard.isDown("down")  then
		camera.movement[2] = -player.speed
	end
	if love.keyboard.isDown("right") and love.keyboard.isDown("up") then
		camera.movement[1] = -player.speed*math.sin(45)
		camera.movement[2] = player.speed*math.sin(45)
	elseif love.keyboard.isDown("right") and love.keyboard.isDown("down") then
		camera.movement[1] = -player.speed*math.sin(45)
		camera.movement[2] = -player.speed*math.sin(45)
	elseif love.keyboard.isDown("left") and love.keyboard.isDown("up") then
		camera.movement[1] = player.speed*math.sin(45)
		camera.movement[2] = player.speed*math.sin(45)
	elseif love.keyboard.isDown("left") and love.keyboard.isDown("down") then
		camera.movement[1] = player.speed*math.sin(45)
		camera.movement[2] = -player.speed*math.sin(45)
	end

	if love.keyboard.isDown("w") then
		for i = 1,firstmap.width*firstmap.height do
			firstmap.map[i] = math.random(2)-1
		end
	end

	cameraCollision()

	camera.x = camera.x + camera.movement[1]
	camera.y = camera.y + camera.movement[2]
end

function drawmap()
	screenx = love.graphics.getWidth()
	screeny = screenx
	texturesize = screenx/8
	map = firstmap
	for j = 1,map.width do
		for i = 1,map.height do
			if map.map[i + (j-1) * (map.width)] == 1 then
				love.graphics.rectangle("line", j*screenx/8 - texturesize + camera.x, i*screeny/8 - texturesize + camera.y, texturesize, texturesize)
			else
				love.graphics.rectangle("fill", j*screenx/8 - texturesize + camera.x, i*screeny/8 - texturesize + camera.y, texturesize, texturesize)
			end
		end
	end
end

function love.draw()
	drawmap()
	love.graphics.draw(playerTexture, playerTrans)
end
