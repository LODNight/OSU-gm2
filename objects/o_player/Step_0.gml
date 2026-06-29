
left = keyboard_check(ord("A"))
right = keyboard_check(ord("D"))
up = keyboard_check(ord("W"))
down = keyboard_check(ord("S"))

shootKey = mouse_check_button(mb_left)
swapKey = mouse_check_button_pressed(mb_right)


// ====================
// Player Movement
player_movement()


// ====================
// Get Damaged
get_damaged(o_damage_player, true)


// ====================
// Sprite Control
sprite_control()


// ====================
// Weapon Swap 
weapon_swap()


// ====================
// Shoot
if shootTimer > 0 { shootTimer-- }
if shootKey && shootTimer <= 0 {
	shootTimer = weapon.cooldown
	
	var _xOffset = lengthdir_x(weapon.length + weaponOffsetDist, aimDir)
	var _yOffset = lengthdir_y(weapon.length + weaponOffsetDist, aimDir)
	
	var _spread = weapon.spread
	var _spreadDiv = _spread / max(weapon.bulletNum-1, 1)
	
	var _weaponTipX = x + _xOffset
	var _weaponTipY = centerY + _yOffset
	
	
	for(var i = 0; i <= weapon.bulletNum; i++){
		var _bulletInst = instance_create_depth(_weaponTipX, _weaponTipY, depth+100, weapon.bullet)
	
		with(_bulletInst){
			dir = other.aimDir - _spread/2 + _spreadDiv*i
		
			image_angle = dir

		}	
	}
}	



