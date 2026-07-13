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

    _weapon.ammo--;
    _owner.shootTimer = _data.cooldown;
    weapon_play_sound(_data.fireSound);

    var _xOffset = lengthdir_x(_data.length + _owner.weaponOffsetDist, _owner.aimDir);
    var _yOffset = lengthdir_y(_data.length + _owner.weaponOffsetDist, _owner.aimDir);
    var _tipX = _owner.x + _xOffset;
    var _tipY = _owner.centerY + _yOffset;
    var _spreadStep = _data.spread / max(_data.bulletNum - 1, 1);

    for (var i = 0; i < _data.bulletNum; i++) {
        var _bullet = instance_create_depth(_tipX, _tipY, _owner.depth + 100, _data.bullet);
        _bullet.dir = _owner.aimDir - _data.spread * 0.5 + _spreadStep * i;
        _bullet.image_angle = _bullet.dir;
        if (variable_instance_exists(_bullet, "damage")) _bullet.damage = _data.damage;
    }
    return true;
}
