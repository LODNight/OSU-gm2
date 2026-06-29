
// draw the weapon behind the enemy
if aimDir >= 0 && aimDir <= 180{
	draw_enemies_weapon()	
}

// Draw the enemy
draw_sprite_ext( sprite_index, image_index, x, y, face, image_yscale, image_angle, image_blend, image_alpha)


// draw the weapon
if aimDir >= 180 && aimDir <= 360{
	// Draw the weapon
	draw_enemies_weapon()
}
