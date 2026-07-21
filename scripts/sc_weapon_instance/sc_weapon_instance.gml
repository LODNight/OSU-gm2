/// @desc Mutable state of one physical weapon. Never store this in a global registry.
function create_weapon_instance(_definition, _ammo = -1, _mags = -1) constructor
{
    definition  = _definition;
    ammo        = (_ammo < 0) ? definition.magSize : clamp(_ammo, 0, definition.magSize);
    mags        = (_mags < 0) ? definition.mags : clamp(_mags, 0, definition.maxMags);

    // Reserved for future per-weapon systems without changing weapon definitions.
    durability  = 100;
    attachments = [];
}
