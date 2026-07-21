function weapon_is_empty(_weapon)
{
    return (_weapon == noone) || (_weapon.ammo <= 0);
}

function weapon_can_reload(_weapon)
{
    return (_weapon != noone)
        && (_weapon.ammo < _weapon.definition.magSize)
        && (_weapon.mags > 0);
}

function weapon_has_ammo(_weapon)
{
    return !weapon_is_empty(_weapon);
}

/// @desc Add magazines to one weapon instance. Returns the amount actually received.
function weapon_add_mags(_weapon, _amount)
{
    if (_weapon == noone || _amount <= 0) return 0;

    var _before = _weapon.mags;
    _weapon.mags = clamp(
        _weapon.mags + _amount,
        0,
        _weapon.definition.maxMags
    );
    return _weapon.mags - _before;
}

function weapon_play_sound(_sound)
{
    if (_sound != noone) audio_play_sound(_sound, 0, false);
}
