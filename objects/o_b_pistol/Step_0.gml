xspd = lengthdir_x( spd, dir)
yspd = lengthdir_y( spd, dir)


x += xspd
y += yspd

// hit confirm destroy
if hitConfirm == true && enemyDestroy == true { destroy = true }

if(destroy) instance_destroy()	

// Coliision
if(place_meeting(x, y, tile_wall))  { destroy = true }

// Bullet out range
if(point_distance( xstart, ystart, x, y) > maxDist) { destroy = true }

