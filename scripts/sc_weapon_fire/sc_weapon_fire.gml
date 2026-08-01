/// @desc Fire the owner's equipped weapon once.
function weapon_fire(_owner)
{
    var _weapon = _owner.weapon;
    if (_weapon == noone || _owner.isReloading || _owner.shootTimer > 0) return false;
    if (_weapon.is_jammed) return false;

    var _data = _weapon.definition;
    if (!weapon_has_ammo(_weapon)) {
        weapon_play_sound(_data.emptySound);
        return false;
    }

    // ── Durability modifiers ──────────────────────────────────────
    var _mods = weapon_get_durability_modifiers(_weapon);

    // ── Jam Check ─────────────────────────────────────────────────
    if (_mods.jam_chance > 0 && random(1) < _mods.jam_chance) {
        _weapon.is_jammed = true;
        weapon_play_sound(_data.jam_sound);
        show_debug_message("[weapon_fire] JAMMED: " + _data.id);
        return false;
    }

    // ── Fire ──────────────────────────────────────────────────────
    var _bulletsToFire = min(_weapon.current_ammo, _data.bulletNum);
    _weapon.current_ammo -= _bulletsToFire;
    weapon_instance_sync_ammo(_weapon);
    _owner.shootTimer     = _data.cooldown;
    weapon_play_sound(_data.fireSound);

    // ── Kích hoạt muzzle flash ────────────────────────────────────
    if (variable_instance_exists(_owner, "muzzleFlashTimer")) {
        _owner.muzzleFlashTimer     = _data.muzzle_flash_frames;
        _owner.muzzleFlashRandAngle = random_range(-20, 20); // Xoay flash nhẹ mỗi phát
        _owner.muzzleFlashRandScale = random_range(0.85, 1.2); // Scale nhẹ mỗi phát
    }

    // ── Durability wear ───────────────────────────────────────────
    _weapon.current_durability = max(0, _weapon.current_durability - _data.wear_per_shot);

    // ── 1. Calculate Base Spread (ADS / Standing / Moving / Crouch) ──
    var _isAiming   = variable_instance_exists(_owner, "isAiming") ? _owner.isAiming : false;
    var _baseSpread = _isAiming ? _data.aimed_spread : _data.spread;

    // Movement state multipliers
    if (variable_instance_exists(_owner, "state")) {
        var _st = _owner.state;
        if (_st == PLAYER_STATE.RUN)        _baseSpread *= _data.running_spread_multiplier;
        else if (_st == PLAYER_STATE.MOVE)  _baseSpread *= _data.moving_spread_multiplier;
        else if (_st == PLAYER_STATE.CROUCH) _baseSpread *= _data.crouch_spread_multiplier;
    }

    // First shot multiplier (if no current spread accumulated)
    var _accumulatedSpread = variable_instance_exists(_owner, "currentSpread") ? _owner.currentSpread : 0;
    if (_accumulatedSpread <= 0.05) {
        _baseSpread *= _data.first_shot_multiplier;
    }

    // Combined total spread (durability-scaled)
    var _maxCap       = _data.maximum_spread * _mods.spread_mult;
    var _totalSpread  = min(_baseSpread + _accumulatedSpread, _maxCap) * _mods.spread_mult;

    // ── 2. Accumulate spread & crosshair bloom on owner ─────────────
    if (variable_instance_exists(_owner, "currentSpread")) {
        _owner.currentSpread = min(
            _owner.currentSpread + _data.spread_per_shot * _mods.spread_mult,
            _maxCap
        );
    }

    if (variable_instance_exists(_owner, "crosshairBloom")) {
        var _bloomInc = _data.spread_per_shot * 3.5 + _data.recoil_vertical * 2.0 + 8.0;
        _owner.crosshairBloom = min(_owner.crosshairBloom + _bloomInc, _owner.maxBloom);
    }

    // ── 3. Bullet spawn with full recoil & spread deviation ─────────
    var _xOffset = lengthdir_x(_data.length + _owner.weaponOffsetDist, _owner.aimDir);
    var _yOffset = lengthdir_y(_data.length + _owner.weaponOffsetDist, _owner.aimDir);
    var _tipX    = _owner.x       + _xOffset;
    var _tipY    = _owner.centerY + _yOffset;

    var _effectiveDamage = round(_data.damage * _mods.damage_mult);
    var _halfSpread      = _totalSpread * 0.5;
    var _spreadStep      = (_bulletsToFire > 1) ? (_totalSpread / max(_bulletsToFire - 1, 1)) : 0;

    for (var i = 0; i < _bulletsToFire; i++) {
        var _bullet = instance_create_depth(_tipX, _tipY, _owner.depth + 100, _data.bullet);

        // Base angle across multi-pellet spread
        var _baseDir = (_bulletsToFire > 1)
            ? (_owner.aimDir - _halfSpread + _spreadStep * i)
            : _owner.aimDir;

        // Recoil jitter calculation (Horizontal jitter + Randomness)
        var _recoilJitter = random_range(-_data.recoil_horizontal, _data.recoil_horizontal)
                          + random_range(-_data.recoil_randomness, _data.recoil_randomness);

        // Total deviation angle per shot
        var _bulletDev = random_range(-_halfSpread, _halfSpread) + _recoilJitter;

        _bullet.dir         = _baseDir + _bulletDev;
        _bullet.image_angle = _bullet.dir;

        // Sweep from the shooter body on the first frame. This catches an
        // enemy already standing between the player and the muzzle tip.
        if (variable_instance_exists(_bullet, "sweep_x")) {
            _bullet.sweep_x = _owner.x;
            _bullet.sweep_y = _owner.centerY;
        }

        if (variable_instance_exists(_bullet, "damage"))  _bullet.damage  = _effectiveDamage;
        if (variable_instance_exists(_bullet, "spd"))     _bullet.spd     = _data.bulletSpd;
        if (variable_instance_exists(_bullet, "maxDist")) _bullet.maxDist = _data.bulletMaxDist;
        if (variable_instance_exists(_bullet, "damage_type"))    _bullet.damage_type    = _data.damage_type;
        if (variable_instance_exists(_bullet, "stagger_power"))  _bullet.stagger_power  = _data.stagger_power;
        if (variable_instance_exists(_bullet, "knockback_power")) _bullet.knockback_power = _data.knockback_power;
        if (_data.bulletSprite != noone) _bullet.sprite_index = _data.bulletSprite;
        if (variable_struct_exists(_data, "muzzle_flash_color")) _bullet.tracer_color = _data.muzzle_flash_color;

        // ── Damage Falloff ─────────────────────────────────────────
        if (variable_instance_exists(_bullet, "falloff_start")) {
            _bullet.falloff_start = _data.damage_falloff_start;
            _bullet.falloff_end   = _data.damage_falloff_end;
            _bullet.min_dmg_mult  = _data.min_damage_multiplier;
            _bullet.base_damage   = _effectiveDamage;
        }
    }
    return true;
}
