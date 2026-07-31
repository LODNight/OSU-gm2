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
    _weapon.ammo          = _weapon.current_ammo;   // sync alias
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

    // ── Spread accumulation on owner ──────────────────────────────
    if (variable_instance_exists(_owner, "currentSpread")) {
        _owner.currentSpread = min(
            _owner.currentSpread + _data.spread_per_shot * _mods.spread_mult,
            _data.maximum_spread * _mods.spread_mult
        );
    }

    // ── Bullet spawn ──────────────────────────────────────────────
    var _xOffset = lengthdir_x(_data.length + _owner.weaponOffsetDist, _owner.aimDir);
    var _yOffset = lengthdir_y(_data.length + _owner.weaponOffsetDist, _owner.aimDir);
    var _tipX    = _owner.x     + _xOffset;
    var _tipY    = _owner.centerY + _yOffset;

    // Base spread = weapon base + accumulated spread from firing (durability-scaled)
    var _totalSpread = _data.spread * _mods.spread_mult;
    if (variable_instance_exists(_owner, "currentSpread")) {
        _totalSpread += _owner.currentSpread;
    }

    // Accuracy system (player only — if no aim system, accuracy = 1)
    var _accuracy = 1.0;
    if (variable_instance_exists(_owner, "crosshairBloom")) {
        with (_owner) { _accuracy = aim_get_accuracy(); }
    }
    var _maxDeviation = _totalSpread * 0.5;
    var _randomDev    = (1 - _accuracy) * _maxDeviation;

    var _spreadStep = (_bulletsToFire > 1) ? (_totalSpread / (_bulletsToFire - 1)) : 0;

    // Apply durability-scaled damage
    var _effectiveDamage = round(_data.damage * _mods.damage_mult);

    for (var i = 0; i < _bulletsToFire; i++) {
        var _bullet = instance_create_depth(_tipX, _tipY, _owner.depth + 100, _data.bullet);
        var _baseDir = (_bulletsToFire > 1)
            ? (_owner.aimDir - _totalSpread * 0.5 + _spreadStep * i)
            : _owner.aimDir;
        _bullet.dir         = _baseDir + random_range(-_randomDev, _randomDev);
        _bullet.image_angle = _bullet.dir;

        if (variable_instance_exists(_bullet, "damage"))  _bullet.damage  = _effectiveDamage;
        if (variable_instance_exists(_bullet, "spd"))     _bullet.spd     = _data.bulletSpd;
        if (variable_instance_exists(_bullet, "maxDist")) _bullet.maxDist = _data.bulletMaxDist;
        if (_data.bulletSprite != noone) _bullet.sprite_index = _data.bulletSprite;
    }
    return true;
}
