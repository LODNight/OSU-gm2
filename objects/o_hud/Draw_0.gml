var _camX = camera_get_view_x( view_camera[0] )
var _camY = camera_get_view_y( view_camera[0] )


// Draw text
//var _hpString = "HP: " + string(playerHp) + "/" + string(playerMaxHp)
//draw_text( _camX, _camY, _hpString)



// Draw sprite
var _border = 8
var _camXBor = _camX + _border
var _camYBor = _camY + _border
draw_sprite( s_healthBar, 0, _camXBor, _camYBor)

for(var i=0; i < playerMaxHp; i++){
	var _img = 1
	if i+1 <= playerHp { _img = 2 }
	
	var _sep = 3
	draw_sprite( s_healthBar , _img, _camXBor + _sep*i, _camYBor)
}
