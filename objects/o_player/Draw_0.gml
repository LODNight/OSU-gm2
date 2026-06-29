// draw the weapon behind the player
if aimDir >= 0 && aimDir <= 180{
	draw_my_weapon()	
}

// Draw the player
draw_self()

// draw the weapon
if aimDir >= 180 && aimDir <= 360{
	// Draw the weapon
	draw_my_weapon()
}

//draw hp as a number
//draw_text( x, y, string(hp) )

