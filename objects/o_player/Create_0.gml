// ====================
//Damage Setup
get_damaged_create(20, true)

// ====================
// Movement Setup
moveDir = 0
spd = 2
xspd = 0
yspd = 0

// ====================
// Sprite Control
aimDir = 0
centerYOffset = 0
centerY = y + centerYOffset

weaponOffsetDist = 2

spr_idle = s_p_1_idle
spr_walk = s_p_1_walk


tile_wall = layer_tilemap_get_id("tile_wall")

// ====================

shootTimer = 0

// ====================
// Setup Gun
array_push( global.PlayerWeapons, global.Weapons.pistol_fn57)
array_push( global.PlayerWeapons, global.Weapons.subgun_p90)
array_push( global.PlayerWeapons, global.Weapons.shotgun_tus34)
array_push( global.PlayerWeapons, global.Weapons.snipgun_nozin_v1)

selectedWeapon = 0
weapon = global.PlayerWeapons[selectedWeapon]