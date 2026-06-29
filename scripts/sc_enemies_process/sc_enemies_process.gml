

function enemies_movement_collision(){
}

// State Machine
function state_enemy_chase(){
	// chase player 
	if instance_exists(o_player){
		aimDir = point_direction( x, y, o_player.x, o_player.y)
	}
	spd = chaseSpd
	

}

function state_enemy_run(){
	
	// Getting the speeds
	xspd = lengthdir_x(spd, aimDir)
	yspd = lengthdir_y(spd, aimDir)
	
	// Get the correct face
	if aimDir > 90 && aimDir < 270 { face = -1 }
	else { face = 1 }
	
	// Collision
	if place_meeting(x + xspd, y, [tile_map, o_enemy_parent, o_wall]){
		xspd = 0
	}

	if place_meeting(x, y + yspd, [tile_map, o_enemy_parent, o_wall]){
		yspd = 0
	}
	
	// moving
	x += xspd
	y += yspd	
}


// ================================
// Damage Calculation
	// Damage Create Event
	function get_damaged_create( _hp, _iframes = false){
		hp = _hp
		// get the iframes
		if _iframes == true{
			iframeTimer = 0 
			iframeNumber = 90
		}
		
		// create the damage list
		if _iframes == false{
			damage_list = ds_list_create()	
		}
	}

	// Damage clean up
	/// DO NOT NEED IF USE IFRAMES
	function get_damaged_cleanup(){
		ds_list_destroy(damage_list)
	}

	// Recieve Damage Step Event
	function get_damaged(_damageObj, _iframes = false){
	
		// Special exit for iframe timer
		if _iframes == true && iframeTimer > 0 {
			iframeTimer--
			
			if iframeTimer mod 7 == 0{
				if image_alpha == 1{
					image_alpha = 0
				} else {
					image_alpha = 1	
				}	
			}
			
			exit
		}
		
		if _iframes == true{
			image_alpha = 1	
		}
		
		// Recieve Damage
		if place_meeting(x, y , _damageObj){
	
			// =============================
			// Get list of damage
			var _instList = ds_list_create()
			instance_place_list( x, y, _damageObj, _instList, false )
	
			var _listSize = ds_list_size(_instList)	

			var _hitConfirm = false

			for(var i = 0 ; i < _listSize; i++) {
				// Get damage object from list
				var _inst = ds_list_find_value( _instList, i )
			
			
				if _iframes == true || ds_list_find_index(damage_list, _inst) == -1
				{
					// add new damage instance to the damage list
					if _iframes == false {
						ds_list_add(damage_list, _inst)
					}
					// take damage
					hp -= _inst.damage
					_hitConfirm = true
					_inst.hitConfirm = true
				
				}
			}
			
			// set iframe if were hit
			if _iframes == true && _hitConfirm{
				iframeTimer = iframeNumber	
			}
	
			// free memory
			ds_list_destroy(_instList)
	
		}	
	
		// clear the damage list
		if _iframes == false{
			var _damageListSize = ds_list_size(damage_list)
			for(var i = 0; i < _damageListSize; i++){
				var _inst = ds_list_find_value(damage_list, i)
				if !instance_exists(_inst) || !place_meeting( x, y, _inst){
					ds_list_delete(damage_list, i)
					i--
					_damageListSize--
				}
			}
		}
	
	}

// ================================


// ====================
// Draw Enemies Weapons
function draw_enemies_weapon(){
	var xOffset = lengthdir_x(weaponOffsetDist , aimDir)
	var yOffset = lengthdir_y(weaponOffsetDist , aimDir)

	
	// Draw 
	draw_sprite_ext( weapon.sprite , 0, x + xOffset, centerY + yOffset, 1, face ,aimDir, c_white, 1)
}
