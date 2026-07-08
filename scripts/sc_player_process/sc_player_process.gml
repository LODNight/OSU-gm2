// ====================
// Player Movement
function player_movement(){
	// =============================
	// Movement
	var _horKey = right - left
	var _verKey = down - up

	move_dir = point_direction( 0, 0, _horKey, _verKey)

	var _spd = 0
	var _inputLevel = point_distance( 0 ,0 , _horKey, _verKey)
	_inputLevel = clamp(_inputLevel, 0, 1)
	_spd = spd * _inputLevel

	xspd = lengthdir_x(_spd, move_dir)
	yspd = lengthdir_y(_spd, move_dir)

	if(xspd != 0 || yspd != 0){
		sprite_index = spr_walk
	} else {
		sprite_index = spr_idle
	}

	// =============================
	// Collision
	if(place_meeting(x + xspd, y, [tile_wall,o_wall, o_wall_colli])){
		xspd = 0
	}
	if(place_meeting(x, y + yspd, [tile_wall,o_wall, o_wall_colli])){
		yspd = 0
	}

	x += xspd
	y += yspd
}


// ====================
// Sprite Control
function sprite_control(){
	
	centerY = y + centerYOffset

	aimDir = point_direction(x, centerY, mouse_x, mouse_y)

	if (mouse_x > x) {
	    image_xscale = 1;
	} else if (mouse_x < x) {
	    image_xscale = -1; 
	}
}


// ====================
// Draw Weapons
function draw_my_weapon(){
	var xOffset = lengthdir_x(weaponOffsetDist , aimDir)
	var yOffset = lengthdir_y(weaponOffsetDist , aimDir)

	var _weaponYscl = 1

	if(aimDir > 90 && aimDir < 270){
		_weaponYscl = -1	
	}
	
	// Draw 
	draw_sprite_ext( weapon.sprite , 0, x + xOffset, centerY + yOffset, 1, _weaponYscl ,aimDir, c_white, image_alpha)
}


// ====================
// Weapon Swap
function weapon_swap()
{
    var _playerWeapons = global.PlayerWeapons;
    var _count = array_length(_playerWeapons);

    // Không có vũ khí
    if (_count == 0)
    {
        weapon = noone;
        return;
    }

    // Chọn bằng phím số
    if (num1Key && _count > 0) selectedWeapon = 0;
    if (num2Key && _count > 1) selectedWeapon = 1;
    if (num3Key && _count > 2) selectedWeapon = 2;
    if (num4Key && _count > 3) selectedWeapon = 3;

    // Cuộn đổi vũ khí
    if (swapKey)
    {
        selectedWeapon = (selectedWeapon + 1) mod _count;
    }

    // Đảm bảo chỉ số hợp lệ
    selectedWeapon = clamp(selectedWeapon, 0, _count - 1);

    // Trang bị
    weapon = _playerWeapons[selectedWeapon];
}


// ====================
// Player Shoot
function player_shoot(){
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
	
}
