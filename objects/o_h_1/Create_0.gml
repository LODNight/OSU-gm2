
event_inherited();

// ========================
spd = 0
chaseSpd = .5
xspd = 0
yspd = 0

// ========================
// Face 
face = 1

// ========================
// Sprite control
aimDir = 0
centerYOffset = 0
centerY = y + centerYOffset

weaponOffsetDist = 4

spr_idle = s_hu_1_idle
spr_walk = s_hu_1_walk

// ========================
// state machine
state = 0

// ========================
// Shoot timer
shootTimer = 0
shootCooldown = 60

// ========================
// Aim timer
aimTimer = 0
aimCooldown = 60

// ========================
// Add Weapon
array_push( global.PlayerWeapons, global.Weapons.pistol_fn57)
weapon = global.PlayerWeapons[0]