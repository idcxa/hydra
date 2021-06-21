tiles = love.graphics.newImage("assets/testtiles-1.png")

floorTextures = {
	{1, 3},
	{2, 3},
	{3, 3},
	{4, 3},
	{1, 4},
	{2, 4},
	{3, 4},
	{4, 4}
}

collisionTextures = {
	{0,7},
	{0,6},
	{2,7},
}

collisionBoxes = {
	{5, 2, 16, 16},
	{3, 2, 14, 16},
	{3, 2, 14, 16}
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

