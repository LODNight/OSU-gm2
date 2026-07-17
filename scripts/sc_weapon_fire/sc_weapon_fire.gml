/// @desc Fire the owner's equipped weapon once.
function weapon_fire(_owner)
{
    var _weapon = _owner.weapon;
    if (_weapon == noone || _owner.isReloading || _owner.shootTimer > 0) return false;

    var _data = _weapon.definition;
    if (!weapon_has_ammo(_weapon)) {
        weapon_play_sound(_data.emptySound);
        return false;
    }

    var _bulletsToFire = min(_weapon.ammo, _data.bulletNum);
    _weapon.ammo -= _bulletsToFire;
    _owner.shootTimer = _data.cooldown;
    weapon_play_sound(_data.fireSound);

    var _xOffset = lengthdir_x(_data.length + _owner.weaponOffsetDist, _owner.aimDir);
    var _yOffset = lengthdir_y(_data.length + _owner.weaponOffsetDist, _owner.aimDir);
    var _tipX = _owner.x + _xOffset;
    var _tipY = _owner.centerY + _yOffset;
    var _spreadStep = (_bulletsToFire > 1) ? (_data.spread / (_bulletsToFire - 1)) : 0;

    // Lấy hệ số chính xác từ aim module (bloom nhỏ = accuracy cao = ít lệch)
    // Nếu owner không có aim system (enemy), dùng accuracy = 1 (không lệch thêm)
    var _accuracy = 1.0;
    if (variable_instance_exists(_owner, "crosshairBloom")) {
        with (_owner) {
            _accuracy = aim_get_accuracy();
        }
    }
    
    // Random deviation tỉ lệ nghịch với accuracy (cùng chiều với spread của súng)
    var _maxDeviation = _data.spread * 0.5;   // Tối đa lệch thêm nửa spread của súng
    var _randomDev    = (1 - _accuracy) * _maxDeviation;

    for (var i = 0; i < _bulletsToFire; i++) {
        var _bullet = instance_create_depth(_tipX, _tipY, _owner.depth + 100, _data.bullet);
        // Hướng cố định theo pattern + thêm random deviation từ crosshair bloom
        var _baseDir = (_bulletsToFire > 1) 
            ? (_owner.aimDir - _data.spread * 0.5 + _spreadStep * i) 
            : _owner.aimDir;
        _bullet.dir = _baseDir + random_range(-_randomDev, _randomDev);
        _bullet.image_angle = _bullet.dir;
        
        // Gán thông số vật lý & sát thương từ súng sang đạn
        if (variable_instance_exists(_bullet, "damage")) _bullet.damage = _data.damage;
        if (variable_instance_exists(_bullet, "spd")) _bullet.spd = _data.bulletSpd;
        if (variable_instance_exists(_bullet, "maxDist")) _bullet.maxDist = _data.bulletMaxDist;
        if (_data.bulletSprite != noone) _bullet.sprite_index = _data.bulletSprite;
    }
    return true;
}
