function player_weapon()
{
    if (shootTimer > 0) shootTimer--;
    if (muzzleFlashTimer > 0) muzzleFlashTimer--;
    player_weapon_swap();
    player_weapon_fire_mode_toggle();
    weapon_update_reload(id);

    // Spread recovery mỗi frame
    if (weapon != noone) {
        var _def = weapon.definition;
        currentSpread = max(0, currentSpread - _def.spread_recovery);
    }

    if (weapon != noone && !weapon.is_jammed
        && (reloadKey || (weapon.definition.autoReload && weapon.current_ammo <= 0))) {
        weapon_reload(id);
    }
    if (weapon == noone || isReloading) return;

    // Jam: không thể bắn
    if (weapon.is_jammed) return;

    var _data = weapon.definition;
    var _isAuto = (weapon.current_fire_mode == "auto");

    if ((_isAuto && shootKey) || (!_isAuto && shootPressed)) {
        weapon_fire(id);
    }
}

function player_weapon_swap()
{
    var _count = array_length(inventoryWeapons);
    if (_count <= 0) {
        weapon = noone;
        return;
    }

    if (num1Key) selectedWeapon = 0;
    if (num2Key && _count > 1) selectedWeapon = 1;
    if (swapKey) selectedWeapon = (selectedWeapon == 0 && _count > 1) ? 1 : 0;

    selectedWeapon = clamp(selectedWeapon, 0, _count - 1);
    var _nextWeapon = inventoryWeapons[selectedWeapon];
    if (weapon != _nextWeapon) {
        if (isReloading && weapon != noone && weapon.definition.reloadSound != noone) {
            audio_stop_sound(weapon.definition.reloadSound);
        }
        isReloading  = false;
        currentSpread = 0;
        currentRecoil = 0;
    }
    weapon = _nextWeapon;
}

/// @desc Toggle fire mode (semi ↔ auto) with V key — only if weapon supports both
function player_weapon_fire_mode_toggle()
{
    if (!fireModeKey) return;
    if (weapon == noone) return;

    var _modes = weapon.definition.supported_modes;
    if (array_length(_modes) < 2) return;  // only 1 mode, nothing to toggle

    // Cycle through supported modes
    var _current = weapon.current_fire_mode;
    var _found   = -1;
    for (var i = 0; i < array_length(_modes); i++) {
        if (_modes[i] == _current) { _found = i; break; }
    }
    var _nextIdx = (_found + 1) mod array_length(_modes);
    weapon.current_fire_mode = _modes[_nextIdx];

    inventory_toast("[V] Mode: " + string_upper(weapon.current_fire_mode));
}
