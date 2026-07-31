// Damage
maxHp = 100;
get_damaged_create(maxHp, true);

// ── Flashlight item slot ──────────────────────────────────────
// Thay đổi giá trị "flashlight_standard" để đổi đèn mặc định.
// Các ID có sẵn: flashlight_standard, flashlight_wide,
//               flashlight_tactical, flashlight_lantern, flashlight_uv
//#macro DEFAULT_FLASHLIGHT "flashlight_standard"
#macro DEFAULT_FLASHLIGHT "flashlight_standard"

if (!variable_global_exists("FlashlightDefs")) sc_lighting_definitions();
if (variable_struct_exists(global.FlashlightDefs, DEFAULT_FLASHLIGHT)) {
    flashlightItem = variable_struct_get(global.FlashlightDefs, DEFAULT_FLASHLIGHT);
} else {
    flashlightItem = noone;
}

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
tile_item = layer_tilemap_get_id("tile_item_coli");

// Stamina (thể lực)
stamina_create();
// spd được quản lý bởi stamina_get_speed() — KHÔNG dùng spd trực tiếp nữa

// Aim system (ngắm súng, camera bias, crosshair bloom)
aim_create();

// Weapon runtime state
shootTimer     = 0;
reloadTimer    = 0;
isReloading    = false;
inventoryWeapons = [noone, noone];
selectedWeapon = 0;
weapon         = noone;
fireModeKey    = false;   // set by player_input()

// ── Runtime volatile state (NOT saved) ────────────────────────
currentSpread      = 0;   // Current dynamic spread (grows on fire, recovers over time)
currentRecoil      = 0;   // Accumulated recoil offset
muzzleFlashTimer   = 0;   // Countdown frames for muzzle flash
muzzleFlashRandAngle = 0; // Random angle offset per shot (set in weapon_fire)
muzzleFlashRandScale = 1; // Random scale per shot (set in weapon_fire)
cameraShakeTimer   = 0;   // Countdown frames for camera shake

// Safeguard for rooms that do not contain o_init.
if (!variable_global_exists("Weapons")) sc_weapon_init();


// Đồng bộ trang bị/vũ khí từ Inventory nếu đã khởi tạo
if (variable_global_exists("Equipment")) {
    inventory_sync_player_equip();
}

