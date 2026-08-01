/// @desc Start a timed reload. Uses tactical or empty reload time based on remaining ammo.
function weapon_reload(_owner)
{
    if (_owner.weapon == noone || _owner.isReloading || !weapon_can_reload(_owner.weapon)) return false;
    if (_owner.weapon.is_jammed) return false;

    var _weapon = _owner.weapon;
    var _data   = _weapon.definition;

    // Use tactical reload if there's still ammo in the chamber, empty if not
    var _isEmpty  = (_weapon.current_ammo <= 0);
    var _reloadT  = _isEmpty ? _data.empty_reload_time : _data.reloadTime;

    _owner.isReloading  = true;
    _owner.reloadTimer  = max(1, _reloadT);
    weapon_play_sound(_data.reloadSound);
    return true;
}

function weapon_update_reload(_owner)
{
    if (!_owner.isReloading) return;

    _owner.reloadTimer--;
    if (_owner.reloadTimer > 0) return;

    var _weapon = _owner.weapon;
    if (_weapon != noone && _weapon.reserve_ammo > 0) {
        var _needed = max(0, _weapon.definition.magSize - _weapon.current_ammo);
        var _loaded = min(_needed, _weapon.reserve_ammo);
        _weapon.current_ammo += _loaded;
        _weapon.reserve_ammo -= _loaded;
        weapon_instance_sync_ammo(_weapon);

        // Durability wear on reload
        _weapon.current_durability = max(0, _weapon.current_durability - _weapon.definition.wear_per_reload);
    }
    _owner.isReloading = false;
}

/// @desc Clear a jammed weapon. Costs time (clear_jam_time frames).
///       Call this when player presses a dedicated clear-jam action.
function weapon_clear_jam(_owner)
{
    if (_owner.weapon == noone) return false;
    if (!_owner.weapon.is_jammed) return false;

    var _data = _owner.weapon.definition;
    _owner.weapon.is_jammed = false;
    weapon_play_sound(_data.clear_jam_sound);
    show_debug_message("[weapon_clear_jam] Jam cleared on: " + _data.id);
    return true;
}
