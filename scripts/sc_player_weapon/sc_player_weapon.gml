function player_weapon()
{
    if (shootTimer > 0) shootTimer--;
    player_weapon_swap();
    weapon_update_reload(id);

    if (weapon != noone && (reloadKey || (weapon.definition.autoReload && weapon.ammo <= 0))) {
        weapon_reload(id);
    }
    if (weapon == noone || isReloading) return;

    var _data = weapon.definition;
    if ((_data.automatic && shootKey) || (!_data.automatic && shootPressed)) {
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

    if (num1Key && _count > 0) selectedWeapon = 0;
    if (num2Key && _count > 1) selectedWeapon = 1;
    if (num3Key && _count > 2) selectedWeapon = 2;
    if (num4Key && _count > 3) selectedWeapon = 3;
    if (swapKey) selectedWeapon = (selectedWeapon + 1) mod _count;

    selectedWeapon = clamp(selectedWeapon, 0, _count - 1);
    var _nextWeapon = inventoryWeapons[selectedWeapon];
    if (weapon != _nextWeapon) {
        if (isReloading && weapon != noone && weapon.definition.reloadSound != noone) {
            audio_stop_sound(weapon.definition.reloadSound);
        }
        isReloading = false;
    }
    weapon = _nextWeapon;
}
