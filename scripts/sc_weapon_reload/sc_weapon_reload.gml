/// @desc Start a timed reload. Ammo is transferred when the timer finishes.
function weapon_reload(_owner)
{
    if (_owner.weapon == noone || _owner.isReloading || !weapon_can_reload(_owner.weapon)) return false;

    _owner.isReloading = true;
    _owner.reloadTimer = max(1, _owner.weapon.definition.reloadTime);
    weapon_play_sound(_owner.weapon.definition.reloadSound);
    return true;
}

function weapon_update_reload(_owner)
{
    if (!_owner.isReloading) return;

    _owner.reloadTimer--;
    if (_owner.reloadTimer > 0) return;

    var _weapon = _owner.weapon;
    if (_weapon != noone && _weapon.mags > 0) {
        _weapon.ammo = _weapon.definition.magSize;
        _weapon.mags -= 1;
    }
    _owner.isReloading = false;
}
