// get the camera width and height
var _camW = camera_get_view_width( view_camera[0] )
var _camH = camera_get_view_height( view_camera[0] )


// Center on the Player
if instance_exists(o_player){
	
	x = o_player.x - _camW/2
	y = o_player.centerY - _camH/2
}

// clamp cam position to room borders
x = clamp( x, 0, room_width - _camW)
y = clamp( y, 0, room_height - _camH)

// Set the camera position
camera_set_view_pos(view_camera[0], x, y)