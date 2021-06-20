love.graphics.setDefaultFilter("nearest", "nearest")

tiles = love.graphics.newImage("assets/testtiles-1.png")

floorTextures = {
	{1, 3},
	{2, 3},
	{3, 3},
	{4, 3}
}

collisionTextures = {
	{0,7},
	{0,6}
}

collidables = {}

firstmap = {
width = 50,
height = 6,
texturesize = 80,
pixelsize = 16,
floor = {},
collision = {}
}

