function weapon_is_empty(_weapon)
{
    return (_weapon == noone) || (_weapon.ammo <= 0);
}

function weapon_can_reload(_weapon)
{
    return (_weapon != noone)
        && (_weapon.ammo < _weapon.definition.magSize)
        && (_weapon.reserveAmmo > 0);
}

function weapon_has_ammo(_weapon)
{
    return !weapon_is_empty(_weapon);
}

function weapon_play_sound(_sound)
{
    if (_sound != noone) audio_play_sound(_sound, 0, false);
}
