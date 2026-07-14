/// @desc Mutable state of one physical weapon. Never store this in a global registry.
function create_weapon_instance(_definition, _ammo = -1, _reserveAmmo = -1) constructor
{
    definition  = _definition;
    ammo        = (_ammo < 0) ? definition.magSize : clamp(_ammo, 0, definition.magSize);
    reserveAmmo = (_reserveAmmo < 0) ? definition.reserveAmmo : clamp(_reserveAmmo, 0, definition.maxReserveAmmo);

    // Reserved for future per-weapon systems without changing weapon definitions.
    durability  = 100;
    attachments = [];
}
