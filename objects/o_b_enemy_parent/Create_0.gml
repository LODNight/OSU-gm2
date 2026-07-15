event_inherited();

spd  = 7
xspd = 0
yspd = 0

destroy = false
playerDestroy = true

if (instance_exists(o_player)){
    dir = point_direction(x, y, o_player.x, o_player.y);
}
image_angle = dir;