
left = global.leftKey
right = global.rightKey
up = global.upKey
down = global.downKey

shootKey = global.shootKey
swapKey = global.swapKey

num1Key = global.num1Key
num2Key = global.num2Key
num3Key = global.num3Key
num4Key = global.num4Key


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
player_shoot()


// ====================
// Death / GOV
if hp <= 0 {
	// Create the game over object
	instance_create_depth(0,0,-10000, o_gameover_screen)
	
	// Destroy
	instance_destroy()
}



