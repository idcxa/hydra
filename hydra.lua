local hy = {}

Camera 	= require("camera")
Player 	= require("player")
Map		= require("map")
Gui	    = require("gui")
Anim 	= require("animation")

scale = nil

function hy.newCamera()
	return hy.Camera:new()
end

function hy.newPlayer(anims, x, y, speed)
	return hy.Player:new(anims, x, y, speed)
end

function hy.newMap(file)
	return hy.Map:new(file)
end

function hy.newElement(file, x, y, width, height)
	return hy.Gui:new(file, x, y, width, height)
end

function hy.newAnimation(file, sx, sy, speed, loop)
	return hy.Anim:new(file, sx, sy, speed, loop)
end

hy.Camera 	= Camera
hy.Player 	= Player
hy.Map 	  	= Map
hy.Gui    	= Gui
hy.Anim   	= Anim

return hy

