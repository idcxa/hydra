local hy = {}

Camera 	= require("camera")
Player 	= require("player")
Display	= require("display")

function hy.newCamera()
	return hy.Camera:new()
end

function hy.newPlayer()
	return hy.Player:new()
end

hy.Camera = Camera
hy.Player = Player

return hy
