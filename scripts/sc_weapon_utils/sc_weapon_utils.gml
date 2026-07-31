function weapon_is_empty(_weapon)
{
    return (_weapon == noone) || (_weapon.current_ammo <= 0);
}

function weapon_can_reload(_weapon)
{
    return (_weapon != noone)
        && (_weapon.current_ammo < _weapon.definition.magSize)
        && (_weapon.mags > 0)
        && (!_weapon.is_jammed);
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
    _weapon.mags = clamp(_weapon.mags + _amount, 0, _weapon.definition.maxMags);
    return _weapon.mags - _before;
}

function weapon_play_sound(_sound)
{
    if (_sound != noone) audio_play_sound(_sound, 0, false);
}

/// @desc Get durability as a 0..1 percentage.
function weapon_get_durability_pct(_weapon)
{
    if (_weapon == noone) return 0;
    return clamp(_weapon.current_durability / _weapon.definition.max_durability, 0, 1);
}

/// @desc Get durability color: green → yellow → orange → red
function weapon_get_durability_color(_weapon)
{
    var _pct = weapon_get_durability_pct(_weapon);
    if (_pct > 0.6)  return make_color_rgb(100, 220, 100);
    if (_pct > 0.35) return make_color_rgb(240, 200, 60);
    if (_pct > 0.15) return make_color_rgb(240, 120, 30);
    return make_color_rgb(220, 50, 50);
}
