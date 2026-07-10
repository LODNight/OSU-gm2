
		
xspd = lengthdir_x( spd, dir )
yspd = lengthdir_y( spd, dir )

x += xspd
y += yspd
		

// set depth
depth = -y



// clean up
var _pad = 30
if bbox_right < -_pad || bbox_left > room_width + _pad || bbox_bottom < -_pad || bbox_top > room_height + _pad { destroy = true }

if hitConfirm && playerDestroy { destroy = true }

if destroy == true { instance_destroy() }

if place_meeting( x, y, [tile_map, o_wall]) { destroy = true }