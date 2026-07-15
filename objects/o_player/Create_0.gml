// Damage
maxHp = 20;
get_damaged_create(maxHp, true);

// Movement and aim
moveDir   = 0;
xspd      = 0;
yspd      = 0;
aimDir    = 0;
sprintKey = false;    // Set bởi player_input() mỗi frame
aimKey    = false;    // RMB → ADS, set bởi player_input() mỗi frame
centerYOffset    = 0;
centerY          = y + centerYOffset;
weaponOffsetDist = 2;
spr_idle = s_p_1_idle;
spr_walk = s_p_1_walk;
tile_wall = layer_tilemap_get_id("tile_wall");

// Stamina (thể lực)
stamina_create();
// spd được quản lý bởi stamina_get_speed() — KHÔNG dùng spd trực tiếp nữa

// Aim system (ngắm súng, camera bias, crosshair bloom)
aim_create();

// Weapon runtime state
shootTimer = 0;
reloadTimer = 0;
isReloading = false;
inventoryWeapons = [];
selectedWeapon = 0;
weapon = noone;

// Safeguard for rooms that do not contain o_init.
if (!variable_global_exists("Weapons")) sc_weapon_init();

array_push(inventoryWeapons, new create_weapon_instance(global.Weapons.pistol_fn57));
array_push(inventoryWeapons, new create_weapon_instance(global.Weapons.subgun_p90));
array_push(inventoryWeapons, new create_weapon_instance(global.Weapons.shotgun_tus34));
array_push(inventoryWeapons, new create_weapon_instance(global.Weapons.snipgun_nozin_v1));
weapon = inventoryWeapons[selectedWeapon];
