centerY = y + centerYOffset

if instance_exists(o_player){
	// state machine
	switch ( state ){
	// chase state
	case 0:
		// Change Image
		sprite_index = spr_walk
		
		// State control
		state_enemy_chase()
		
		if distance_to_object(o_player) <= 50 && aimTimer <= 0{
			state = 1
			image_index = 0

		}

	break
	
	// Pause and Aim
	case 1:
	
		// Change Image
		sprite_index = spr_idle
	
		// State control
		aimDir = point_direction( x, y, o_player.x, o_player.y )
			
		// Stop move
		spd = 0
		
		// Shoot bullet
		aimTimer++
		
		if aimTimer >= aimCooldown {
			// Change State to Shoot
			state = 2
			image_index = 0
			
			// Reset aimTimer
			aimTimer = 0
		}
		
	break
	
	// Shot and change to Chase
	case 2: 
	
		// Change Image
		sprite_index = spr_idle
		
		if shootTimer <= 0 {
			// Create bullet
			var _bulletInst = instance_create_depth( x, y, depth, o_b_e_pistol )
			_bulletInst.dir = aimDir	
			
			// Shoot cooldown
			shootTimer = shootCooldown
			
			// Change state	
			state = 0
			image_index = 0
		}
		
		if shootTimer > 0 { shootTimer-- }
		
	
	break
	
	
}
}

state_enemy_run()

depth = -y

event_inherited();


