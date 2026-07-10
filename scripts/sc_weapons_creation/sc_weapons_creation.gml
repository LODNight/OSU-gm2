// ================================================================
// sc_weapons_creation
// Defines all weapon data used by Player and Enemy.
// Uses the create_weapon() constructor — same struct for both.
// ================================================================

/// @desc Weapon data struct — shared by player and enemy systems
/// @param {Asset.GMSprite} _sprite       Weapon sprite
/// @param {real}           _weaponLength Tip offset from origin (pixels)
/// @param {Asset.GMObject} _bullet       Bullet object to spawn
/// @param {real}           _cooldown     Frames between shots
/// @param {real}           _bulletNum    Bullets per shot (default 1)
/// @param {real}           _spread       Total spread angle in degrees (default 0)
function create_weapon(
    _sprite       = s_pistol_FN57,
    _weaponLength = 0,
    _bullet       = o_b_pistol,
    _cooldown     = 30,
    _bulletNum    = 1,
    _spread       = 0
) constructor {
    sprite    = _sprite;
    length    = _weaponLength;
    bullet    = _bullet;
    cooldown  = _cooldown;
    bulletNum = _bulletNum;
    spread    = _spread;
}


// ================================================================
// PLAYER WEAPON REGISTRY
// ================================================================

global.PlayerWeapons = array_create(0)

global.Weapons = {

    pistol_fn57 : new create_weapon(
        s_pistol_FN57,
        sprite_get_bbox_bottom(s_pistol_FN57),
        o_b_pistol,
        23                  // ~0.4s cooldown, fast
    ),

    subgun_p90 : new create_weapon(
        s_sub_P90,
        sprite_get_bbox_bottom(s_sub_P90),
        o_b_sub,
        3.5                 // very fast fire rate
    ),

    shotgun_tus34 : new create_weapon(
        s_shot_Tus34,
        sprite_get_bbox_bottom(s_shot_Tus34),
        o_b_shot,
        50,                 // slow fire rate
        7,                  // 7 pellets per shot
        45                  // 45° spread
    ),

    snipgun_nozin_v1 : new create_weapon(
        s_snip_NozinV1,
        sprite_get_bbox_bottom(s_snip_NozinV1),
        o_b_snip,
        45
    ),

    snipgun_nozin_v2 : new create_weapon(
        s_snip_NozinV2,
        sprite_get_bbox_bottom(s_snip_NozinV2),
        o_b_snip,
        45
    ),
}


// ================================================================
// ENEMY WEAPON REGISTRY
// Enemies NEVER use global.PlayerWeapons.
// To give an enemy a weapon: weapon = global.EnemyWeapons.e_pistol
// The shoot system auto-reads weapon.cooldown, .bullet, .bulletNum, .spread
// ================================================================

global.EnemyWeapons = {

    // Pistol — basic guard, slow and inaccurate
    e_pistol : new create_weapon(
        s_pistol_FN57,      // sprite (replace with enemy-specific sprite later)
        8,
        o_b_e_pistol,
        90                  // 1.5s per shot
    ),

    // Rifle — soldier, medium speed
    e_rifle : new create_weapon(
        s_pistol_FN57,      // placeholder (replace with rifle sprite)
        10,
        o_b_e_pistol,
        45                  // 0.75s per shot — faster than pistol
    ),

    // Sniper — long range, very slow fire rate
    e_sniper : new create_weapon(
        s_snip_NozinV1,     // reuse sniper sprite
        14,
        o_b_e_snip,
        180                 // 3s per shot — punishing but dangerous
    ),

    // Shotgun — close range, spread, slow
    e_shotgun : new create_weapon(
        s_shot_Tus34,       // reuse shotgun sprite
        8,
        o_b_e_shot,
        120,                // 2s per shot
        3,                  // 3 pellets
        30                  // 30° spread
    ),

    // SMG — fast fire rate, low damage
    e_smg : new create_weapon(
        s_sub_P90,          // reuse P90 sprite
        8,
        o_b_e_pistol,
        20                  // ~0.33s — very fast
    ),
}
