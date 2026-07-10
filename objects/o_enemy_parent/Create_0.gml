event_inherited()

// ================================================================
// o_enemy_parent — Common variables for ALL enemies
// Children override only what differs; never redeclare these.
// ================================================================

// ======== Stats (override in child Create)
hp           = 10
chaseSpd     = 1.5
attack_range = 40
aggro_range  = 200

// ======== Movement
spd  = 0
xspd = 0
yspd = 0
face = 1

// ======== Sprite (child MUST override spr_idle / spr_walk)
aimDir           = 0
centerYOffset    = 0
centerY          = y + centerYOffset
weaponOffsetDist = 4
spr_idle         = -1
spr_walk         = -1

// ======== State Machine
// 0=idle | 1=chase | 2=aim/prepare | 3=attack | 4=dead
state = 0

// ======== Combat Timers
aimTimer      = 0
aimCooldown   = 60
shootTimer    = 0
shootCooldown = 60

// ======== Weapon (hasWeapon=false → skip draw; gun parents set true)
hasWeapon    = false
weapon       = noone
bulletObject = o_b_e_pistol

// ======== Tile map (inherited from o_damage_parent, kept for state_enemy_run)
tile_map = layer_tilemap_get_id("tile_wall")

// ======== Init damage system (uses hp defined above)
get_damaged_create(hp)