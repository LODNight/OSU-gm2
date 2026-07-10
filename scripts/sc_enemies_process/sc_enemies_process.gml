// ================================================================
// sc_enemies_process
// Shared functions for all enemy AI logic
// ================================================================


// ================================================================
// SECTION 1 — MOVEMENT
// ================================================================

function state_enemy_run() {

    xspd = lengthdir_x(spd, aimDir)
    yspd = lengthdir_y(spd, aimDir)

    // Face direction
    if aimDir > 90 && aimDir < 270 { face = -1 }
    else                            { face =  1 }

    // Wall collision (x-axis)
    if place_meeting(x + xspd, y, [tile_map, o_enemy_parent, o_wall]) {
        xspd = 0
    }
    // Wall collision (y-axis)
    if place_meeting(x, y + yspd, [tile_map, o_enemy_parent, o_wall]) {
        yspd = 0
    }

    x += xspd
    y += yspd
}


// ================================================================
// SECTION 2 — STATE FUNCTIONS
// ================================================================

/// @desc Enemy stands still, waits until player enters aggro range
function state_enemy_idle() {
    sprite_index = spr_idle
    spd = 0
    if instance_exists(o_player) {
        if distance_to_object(o_player) <= aggro_range {
            state = ENEMY_STATE.CHASE
            image_index = 0
        }
    }
}

/// @desc Enemy moves toward player, transitions to attack when close enough
function state_enemy_chase() {
    sprite_index = spr_walk
    if instance_exists(o_player) {
        aimDir = point_direction(x, y, o_player.x, o_player.y)
    }
    spd = chaseSpd
    if instance_exists(o_player) {
        if distance_to_object(o_player) <= attack_range && aimTimer <= 0 {
            state = ENEMY_STATE.AIM
            image_index = 0
        }
    }
}

/// @desc Enemy stops, aims at player before firing (ranged only)
function state_enemy_aim() {
    sprite_index = spr_idle
    spd = 0
    if instance_exists(o_player) {
        aimDir = point_direction(x, y, o_player.x, o_player.y)
    }
    aimTimer++
    if aimTimer >= aimCooldown {
        state = ENEMY_STATE.ATTACK
        aimTimer = 0
        image_index = 0
    }
}

/// @desc Enemy fires based on its equipped weapon (cooldown, spread, bulletNum auto-applied)
/// @param {Asset.GMObject} _bulletObj  Fallback bullet if no weapon is assigned
function state_enemy_shoot(_bulletObj) {
    sprite_index = spr_idle

    // Read fire stats from weapon struct if available, else use manual overrides
    var _cooldown  = (hasWeapon && weapon != noone) ? weapon.cooldown  : shootCooldown
    var _numBullets = (hasWeapon && weapon != noone) ? weapon.bulletNum : 1
    var _spread    = (hasWeapon && weapon != noone) ? weapon.spread    : 0
    var _bullet    = (hasWeapon && weapon != noone) ? weapon.bullet    : _bulletObj

    if shootTimer <= 0 {
        // Spawn bullets with spread (works for 1 bullet too — spread=0 means straight)
        var _spreadDiv = _spread / max(_numBullets - 1, 1)
        for (var i = 0; i < _numBullets; i++) {
            var _b = instance_create_depth(x, y, depth, _bullet)
            _b.dir = aimDir - _spread/2 + _spreadDiv * i
        }
        shootTimer = _cooldown
        state      = ENEMY_STATE.IDLE
        image_index = 0
    }
    if shootTimer > 0 { shootTimer-- }
}


/// @desc Enemy deals melee damage via hitbox collision, then returns to chase
function state_enemy_melee_attack() {
    sprite_index = spr_idle
    spd = 0
    // Damage is handled automatically via hitbox overlap on o_player
    if shootTimer <= 0 {
        shootTimer = shootCooldown
        state = ENEMY_STATE.IDLE
        image_index = 0
    }
    if shootTimer > 0 { shootTimer-- }
}

/// @desc Enemy death — placeholder for future animation & drops
function state_enemy_dead() {
    spd = 0
    // TODO: play death animation, drop item
    instance_destroy()
}


// ================================================================
// SECTION 3 — STATE RUNNERS
// ================================================================

/// @desc Full state machine for RANGED enemies (idle→chase→aim→shoot)
/// @param {Asset.GMObject} _bulletObj  Bullet object to spawn when shooting
function enemy_run_states_gun(_bulletObj = o_b_e_pistol) {
    switch (state) {
    case ENEMY_STATE.IDLE: state_enemy_idle();                 break
    case ENEMY_STATE.CHASE: state_enemy_chase();                break
    case ENEMY_STATE.AIM: state_enemy_aim();                  break
    case ENEMY_STATE.ATTACK: state_enemy_shoot(_bulletObj);      break
    case ENEMY_STATE.DEAD: state_enemy_dead();                 break
    }
}

/// @desc Full state machine for MELEE enemies (idle→chase→melee attack)
function enemy_run_states_melee() {
    switch (state) {
    case ENEMY_STATE.IDLE: state_enemy_idle();                 break
    case ENEMY_STATE.CHASE: state_enemy_chase();                break
    case ENEMY_STATE.ATTACK: state_enemy_melee_attack();         break
    case ENEMY_STATE.DEAD: state_enemy_dead();                 break
    }
}


// ================================================================
// SECTION 4 — DAMAGE SYSTEM
// ================================================================

/// @desc Call in Create event. Initialises hp and iframe / damage list system.
/// @param {real}  _hp      Starting HP
/// @param {bool}  _iframes Use iframe (flash) system instead of damage list
function get_damaged_create(_hp, _iframes = false) {
    hp = _hp
    if _iframes {
        iframeTimer  = 0
        iframeNumber = 90
    } else {
        damage_list = ds_list_create()
    }
}

/// @desc Call in Clean Up event when using damage-list mode
function get_damaged_cleanup() {
    ds_list_destroy(damage_list)
}

/// @desc Call in Step event. Handles damage reception from a damage-tagged object.
/// @param {Asset.GMObject} _damageObj  The damage-tag object to check overlap with
/// @param {bool}           _iframes    Whether to use iframe-based protection
function get_damaged(_damageObj, _iframes = false) {

    // --- Iframe countdown ---
    if _iframes && iframeTimer > 0 {
        iframeTimer--
        if iframeTimer mod 7 == 0 {
            image_alpha = (image_alpha == 1) ? 0 : 1
        }
        exit
    }
    if _iframes { image_alpha = 1 }

    // --- Check overlap with damage source ---
    if place_meeting(x, y, _damageObj) {

        var _instList = ds_list_create()
        instance_place_list(x, y, _damageObj, _instList, false)

        var _listSize    = ds_list_size(_instList)
        var _hitConfirm  = false

        for (var i = 0; i < _listSize; i++) {
            var _inst = ds_list_find_value(_instList, i)

            if _iframes || ds_list_find_index(damage_list, _inst) == -1 {
                if !_iframes { ds_list_add(damage_list, _inst) }
                hp            -= _inst.damage
                _hitConfirm    = true
                _inst.hitConfirm = true
            }
        }

        if _iframes && _hitConfirm { iframeTimer = iframeNumber }

        ds_list_destroy(_instList)
    }

    // --- Clear stale entries from damage list ---
    if !_iframes {
        var _sz = ds_list_size(damage_list)
        for (var i = 0; i < _sz; i++) {
            var _inst = ds_list_find_value(damage_list, i)
            if !instance_exists(_inst) || !place_meeting(x, y, _inst) {
                ds_list_delete(damage_list, i)
                i--
                _sz--
            }
        }
    }
}


// ================================================================
// SECTION 5 — DRAW HELPERS
// ================================================================

/// @desc Draw the equipped weapon sprite at the correct offset around the enemy
function draw_enemies_weapon() {
    var _xOff = lengthdir_x(weaponOffsetDist, aimDir)
    var _yOff = lengthdir_y(weaponOffsetDist, aimDir)
    draw_sprite_ext(weapon.sprite, 0, x + _xOff, centerY + _yOff, 1, face, aimDir, c_white, 1)
}

/// @desc Draw enemy with weapon layered correctly behind/in-front based on aimDir
function draw_enemy_layered() {
    if aimDir >= 0 && aimDir < 180 {
        if hasWeapon { draw_enemies_weapon() }
        draw_sprite_ext(sprite_index, image_index, x, y, face, image_yscale, image_angle, image_blend, image_alpha)
    } else {
        draw_sprite_ext(sprite_index, image_index, x, y, face, image_yscale, image_angle, image_blend, image_alpha)
        if hasWeapon { draw_enemies_weapon() }
    }
}
