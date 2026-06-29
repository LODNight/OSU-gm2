shootKey = global.spaceKey

alpha += alphaSpeed
alpha = clamp( alpha, 0, 1)


if shootKey && alpha >= 1 {
	room_restart()
}