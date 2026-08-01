// ================================================================
// sc_weapon_instance — Mutable state of one physical weapon.
// Never store this in a global registry.
// ================================================================
// Fields:
//   definition        → Pointer to immutable WeaponDefinition
//   current_ammo      → Rounds in current magazine
//   reserve_ammo      → Reserve round count (canonical unit)
//   mags              → Derived compatibility alias for legacy UI/code
//   current_durability→ Current durability (0..max_durability)
//   current_fire_mode → "semi" | "auto"
//   is_jammed         → Weapon needs clearing before firing
//   attachments       → Struct {muzzle, optic, magazine, stock}
// ================================================================

/// @desc Create a mutable weapon instance from a definition.
/// @param {struct}  _definition  A create_weapon_definition instance
/// @param {real}    _ammo        Starting ammo (-1 = full mag)
/// @param {real}    _reserveAmmo Starting reserve rounds (-1 = default)
/// @param {real}    _durability  Starting durability (-1 = full)
function create_weapon_instance(_definition, _ammo = -1, _reserveAmmo = -1, _durability = -1) constructor
{
    definition = _definition;

    // ── Ammo ──────────────────────────────────────────────────────
    current_ammo = (_ammo < 0) ? definition.magSize : clamp(_ammo, 0, definition.magSize);
    reserve_ammo = (_reserveAmmo < 0)
        ? definition.starting_reserve_ammo
        : clamp(_reserveAmmo, 0, definition.max_reserve_ammo);

    // Backward-compat alias (legacy code uses weapon.ammo)
    ammo = current_ammo;
    mags = ceil(reserve_ammo / max(definition.magSize, 1));

    // ── Durability ────────────────────────────────────────────────
    current_durability = (_durability < 0) ? definition.max_durability : clamp(_durability, 0, definition.max_durability);

    // ── Fire Mode ─────────────────────────────────────────────────
    current_fire_mode = definition.default_mode;

    // ── Jam State ─────────────────────────────────────────────────
    is_jammed = false;

    // ── Attachments ───────────────────────────────────────────────
    attachments = {
        muzzle:   undefined,
        optic:    undefined,
        magazine: undefined,
        stock:    undefined
    };
}

/// @desc Sync the backward-compat .ammo alias after any mutation.
function weapon_instance_sync_ammo(_inst)
{
    _inst.ammo = _inst.current_ammo;
    _inst.mags = ceil(_inst.reserve_ammo / max(_inst.definition.magSize, 1));
}

/// @desc Apply durability-based modifiers and return effective stats struct.
/// @param {struct} _inst  A create_weapon_instance
/// @return {struct} { damage_mult, spread_mult, jam_chance }
function weapon_get_durability_modifiers(_inst)
{
    var _def = _inst.definition;
    var _dur = _inst.current_durability;
    var _maxDur = _def.max_durability;

    // ── Damage modifier ───────────────────────────────────────────
    var _dmgMult = 1.0;
    if (_dur < _def.damage_degrade_start) {
        var _t = 1 - (_dur / max(_def.damage_degrade_start, 1));
        _dmgMult = lerp(1.0, _def.dur_min_damage_mult, _t);
    }

    // ── Spread modifier ───────────────────────────────────────────
    var _spreadMult = 1.0;
    if (_dur < _def.accuracy_degrade_start) {
        var _t = 1 - (_dur / max(_def.accuracy_degrade_start, 1));
        _spreadMult = lerp(1.0, _def.dur_max_spread_mult, _t);
    }

    // ── Jam chance ────────────────────────────────────────────────
    var _jamChance = _def.base_jam_chance;
    if (_dur < _def.reliability_degrade_start) {
        var _t = 1 - (_dur / max(_def.reliability_degrade_start, 1));
        _jamChance *= lerp(1.0, _def.low_durability_jam_mult, _t);
    }

    return {
        damage_mult: _dmgMult,
        spread_mult: _spreadMult,
        jam_chance:  _jamChance
    };
}
