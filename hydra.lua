local hy = {}

Camera 	= require("camera")
Player 	= require("player")
Display	= require("display")
Gui	    = require("gui")

function hy.newCamera()
	return hy.Camera:new()
end

function hy.newPlayer(file)
	return hy.Player:new(file)
end

function hy.newMap(file, width, height, texturesize, pixelsize)
	return hy.Map:new(file, width, height, texturesize, pixelsize)
end

function hy.newElement(file, x, y, width, height)
	return hy.Gui:new(file, x, y, width, height)
end

hy.Camera = Camera
hy.Player = Player
hy.Map 	  = Display
hy.Gui    = Gui

return hy

