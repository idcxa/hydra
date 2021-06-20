love.graphics.setDefaultFilter("nearest", "nearest")
testTiles = love.graphics.newImage("assets/testtiles-1.png")

floorTextures = {
	love.graphics.newQuad(16*1, 16*3, 16, 16, testTiles:getDimensions()),
	love.graphics.newQuad(16*2, 16*3, 16, 16, testTiles:getDimensions()),
	love.graphics.newQuad(16*3, 16*3, 16, 16, testTiles:getDimensions()),
	love.graphics.newQuad(16*4, 16*3, 16, 16, testTiles:getDimensions()),
}

collisionTextures = {
	love.graphics.newQuad(0, 16*7, 16, 16, testTiles:getDimensions()),
	love.graphics.newQuad(0, 16*6, 16, 16, testTiles:getDimensions())
}

collidables = {}

firstmap = {
width = 20,
height = 30,
texturesize = 80,
pixelsize = 16,
map = {},
collision = {}
}

