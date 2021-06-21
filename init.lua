local hy = {}

Camera 	= require("camera")
Player 	= require("player")
Display	= require("display")

function hy.newCamera()
	return hy.Camera:new()
end

function hy.newPlayer(file)
	return hy.Player:new(file)
end

function hy.newMap(file, width, height, texturesize, pixelsize)
	return hy.Map:new(file, width, height, texturesize, pixelsize)
end

hy.Camera = Camera
hy.Player = Player
hy.Map 	  = Display

return hy
