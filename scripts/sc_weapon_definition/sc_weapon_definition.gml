// ================================================================
// sc_weapon_definition — Immutable weapon data, shared by player and enemy
// Supports both new JSON schema and legacy GML config structs.
// ================================================================

/// @desc Resolve a string asset name to its GML asset index.
///       Returns noone (-1) if asset not found or input is not a string.
function weapon_parse_asset(_val)
{
    if (!is_string(_val) || _val == "") return noone;
    var _idx = asset_get_index(_val);
    return (_idx != -1) ? _idx : noone;
}

/// @desc Helper: safely read a nested struct field. Returns _default if missing.
function _wpn_get(_cfg, _key, _default)
{
    return variable_struct_exists(_cfg, _key) ? _cfg[$ _key] : _default;
}

/// @desc Immutable weapon data shared by player and enemy weapons.
///       Accepts both the new JSON sub-section schema and legacy flat config.
function create_weapon_definition(_config) constructor
{
    // ── Identity ──────────────────────────────────────────────────
    id   = _wpn_get(_config, "id",   "");
    name = _wpn_get(_config, "name", "");

    // ── Section structs (null when using legacy flat config) ──────
    var _cls  = _wpn_get(_config, "classification", {});
    var _ball = _wpn_get(_config, "ballistics",     {});
    var _acc  = _wpn_get(_config, "accuracy",       {});
    var _rec  = _wpn_get(_config, "recoil",         {});
    var _fire = _wpn_get(_config, "fire",           {});
    var _mag  = _wpn_get(_config, "magazine",       {});
    var _rel  = _wpn_get(_config, "reload",         {});
    var _dur  = _wpn_get(_config, "durability",     {});
    var _rely = _wpn_get(_config, "reliability",    {});
    var _vis  = _wpn_get(_config, "visual",         {});
    var _aud  = _wpn_get(_config, "audio",          {});
    var _eco  = _wpn_get(_config, "economy",        {});

    // ── Classification ────────────────────────────────────────────
    category      = _wpn_get(_cls, "category",     "");
    weapon_class  = _wpn_get(_cls, "weapon_class", "primary");
    ammo_type     = _wpn_get(_cls, "ammo_type",    "");
    rarity_class  = _wpn_get(_cls, "rarity",       "common");
    two_handed    = _wpn_get(_cls, "two_handed",   true);
    tags          = _wpn_get(_cls, "tags",         []);

    // ── Ballistics ────────────────────────────────────────────────
    damage           = _wpn_get(_ball, "base_damage",               _wpn_get(_config, "damage",        10));
    armor_penetration= _wpn_get(_ball, "armor_penetration",         0);
    bulletSpd        = _wpn_get(_ball, "bullet_speed",              _wpn_get(_config, "bulletSpd",     12));
    bulletMaxDist    = _wpn_get(_ball, "max_range",                 _wpn_get(_config, "bulletMaxDist", 240));
    effective_range  = _wpn_get(_ball, "effective_range",           bulletMaxDist);
    damage_falloff_start    = _wpn_get(_ball, "damage_falloff_start", effective_range);
    damage_falloff_end      = _wpn_get(_ball, "damage_falloff_end",   bulletMaxDist);
    min_damage_multiplier   = _wpn_get(_ball, "minimum_damage_multiplier", 0.5);
    bulletNum        = _wpn_get(_ball, "projectile_count",          _wpn_get(_config, "bulletNum", 1));
    bullet           = weapon_parse_asset(_wpn_get(_ball, "bullet_object", ""));
    if (bullet == noone) bullet = _wpn_get(_config, "bullet", noone);  // legacy fallback
    bulletSprite     = weapon_parse_asset(_wpn_get(_ball, "bullet_sprite", ""));
    if (bulletSprite == noone) bulletSprite = _wpn_get(_config, "bulletSprite", noone);
    damage_type      = _wpn_get(_ball, "damage_type", "ballistic");
    critical_multiplier = _wpn_get(_ball, "critical_multiplier", 1.5);
    stagger_power    = _wpn_get(_ball, "stagger_power", 0);
    knockback_power  = _wpn_get(_ball, "knockback_power", 0);

    // ── Accuracy ──────────────────────────────────────────────────
    spread                   = _wpn_get(_acc, "base_spread",              _wpn_get(_config, "spread", 0));
    aimed_spread             = _wpn_get(_acc, "aimed_spread",             spread * 0.5);
    moving_spread_multiplier = _wpn_get(_acc, "moving_spread_multiplier", 1.5);
    running_spread_multiplier= _wpn_get(_acc, "running_spread_multiplier",2.2);
    crouch_spread_multiplier = _wpn_get(_acc, "crouch_spread_multiplier", 0.8);
    first_shot_multiplier    = _wpn_get(_acc, "first_shot_multiplier",    1.0);
    spread_per_shot          = _wpn_get(_acc, "spread_per_shot",          0);
    spread_recovery          = _wpn_get(_acc, "spread_recovery",          0.3);
    maximum_spread           = _wpn_get(_acc, "maximum_spread",           max(spread * 2, 5));
    scopeZoom                = 1.0 - (_wpn_get(_acc, "aim_time", 20) / 100.0);  // backward compat estimate

    // ── Recoil ────────────────────────────────────────────────────
    recoil_vertical   = _wpn_get(_rec, "vertical",            1.0);
    recoil_horizontal = _wpn_get(_rec, "horizontal",          0.5);
    recoil_randomness = _wpn_get(_rec, "randomness",          0.2);
    weapon_kickback   = _wpn_get(_rec, "weapon_kickback",     2.0);
    camera_kick       = _wpn_get(_rec, "camera_kick",         0.8);
    camera_shake_duration = _wpn_get(_rec, "camera_shake_duration", 3);
    recoil_recovery   = _wpn_get(_rec, "recovery_speed",      0.2);
    recoil_stack_limit= _wpn_get(_rec, "recoil_stack_limit",  6);

    // ── Fire modes ────────────────────────────────────────────────
    supported_modes = _wpn_get(_fire, "supported_modes", []);
    if (array_length(supported_modes) == 0) {
        // Legacy fallback
        var _auto = _wpn_get(_config, "automatic", false);
        supported_modes = _auto ? ["semi", "auto"] : ["semi"];
    }
    default_mode     = _wpn_get(_fire, "default_mode", supported_modes[0]);
    automatic        = (default_mode == "auto");  // backward compat

    // cooldown in frames: room_speed * 60 / RPM
    var _rpm = _wpn_get(_fire, "rounds_per_minute", 0);
    if (_rpm > 0) {
        cooldown = round(room_speed * 60 / _rpm);
    } else {
        cooldown = _wpn_get(_config, "cooldown", 30);
    }
    can_fire_while_moving    = _wpn_get(_fire, "can_fire_while_moving",    true);
    can_fire_while_reloading = _wpn_get(_fire, "can_fire_while_reloading", false);

    // ── Magazine ──────────────────────────────────────────────────
    magSize   = _wpn_get(_mag, "capacity",  _wpn_get(_config, "magSize", 12));
    ammo_type_id = _wpn_get(_mag, "ammo_type", ammo_type);

    // Reserve ammo: legacy uses mags+maxMags, new system uses reserve_ammo
    mags    = _wpn_get(_config, "mags",    4);
    maxMags = _wpn_get(_config, "maxMags", mags);

    // ── Reload ────────────────────────────────────────────────────
    reload_type            = _wpn_get(_rel, "reload_type",           "magazine");
    reloadTime             = _wpn_get(_rel, "tactical_reload_time",  _wpn_get(_config, "reloadTime", room_speed));
    empty_reload_time      = _wpn_get(_rel, "empty_reload_time",     round(reloadTime * 1.25));
    can_interrupt_reload   = _wpn_get(_rel, "can_interrupt",         true);
    retain_chambered_round = _wpn_get(_rel, "retain_chambered_round",true);

    autoReload = _wpn_get(_config, "autoReload", true);

    // ── Durability ────────────────────────────────────────────────
    max_durability           = _wpn_get(_dur, "max_durability",            100);
    wear_per_shot            = _wpn_get(_dur, "wear_per_shot",             0.03);
    wear_per_reload          = _wpn_get(_dur, "wear_per_reload",           0.01);
    accuracy_degrade_start   = _wpn_get(_dur, "accuracy_degrade_start",   60);
    reliability_degrade_start= _wpn_get(_dur, "reliability_degrade_start",40);
    damage_degrade_start     = _wpn_get(_dur, "damage_degrade_start",     20);
    dur_max_spread_mult      = _wpn_get(_dur, "maximum_spread_multiplier", 1.4);
    dur_min_damage_mult      = _wpn_get(_dur, "minimum_damage_multiplier", 0.85);
    dur_min_effectiveness    = _wpn_get(_dur, "minimum_effectiveness",     0.6);

    // ── Reliability (Jam) ─────────────────────────────────────────
    base_jam_chance             = _wpn_get(_rely, "base_jam_chance",              0);
    low_durability_jam_mult     = _wpn_get(_rely, "low_durability_jam_multiplier",1);
    clear_jam_time              = _wpn_get(_rely, "clear_jam_time",               60);

    // ── Visual ────────────────────────────────────────────────────
    sprite = weapon_parse_asset(_wpn_get(_vis, "weapon_sprite", ""));
    if (sprite == noone) sprite = _wpn_get(_config, "sprite", noone);
    icon   = weapon_parse_asset(_wpn_get(_vis, "icon_sprite", ""));
    if (icon == noone) icon = _wpn_get(_config, "icon", sprite);
    length = _wpn_get(_vis, "weapon_length", _wpn_get(_config, "length", 0));
    if (length == 0 && sprite != noone) length = sprite_get_bbox_bottom(sprite);
    bullet_spawn_offset = _wpn_get(_vis, "bullet_spawn_offset", length);

    // ── Audio ─────────────────────────────────────────────────────
    fireSound   = weapon_parse_asset(_wpn_get(_aud, "fire_sound",    ""));
    if (fireSound == noone)   fireSound   = _wpn_get(_config, "fireSound",   noone);
    reloadSound = weapon_parse_asset(_wpn_get(_aud, "reload_sound",  ""));
    if (reloadSound == noone) reloadSound = _wpn_get(_config, "reloadSound", noone);
    emptySound  = weapon_parse_asset(_wpn_get(_aud, "dry_fire_sound",""));
    if (emptySound == noone)  emptySound  = _wpn_get(_config, "emptySound",  noone);
    jam_sound   = weapon_parse_asset(_wpn_get(_aud, "jam_sound",     ""));
    clear_jam_sound = weapon_parse_asset(_wpn_get(_aud, "clear_jam_sound", ""));

    // ── Economy ───────────────────────────────────────────────────
    base_value       = _wpn_get(_eco, "base_value",      _wpn_get(_config, "value", 0));
    sell_multiplier  = _wpn_get(_eco, "sell_multiplier", 0.4);
    loot_weight      = _wpn_get(_eco, "loot_weight",     10);
}

// ================================================================
// weapon_definitions_load — Đọc file JSON, build global.WeaponDefinitions
// ================================================================

/// @desc Load weapon definitions from weapon_definitions.json.
///       Populates global.WeaponDefinitions and sets global.Weapons alias.
function weapon_definitions_load()
{
    global.WeaponDefinitions = {};
    global.PlayerWeaponDefinitions = {};
    global.EnemyWeapons = {};

    var _filePath = "weapon_definitions.json";
    if (!file_exists(_filePath)) {
        show_debug_message("[weapon_definitions_load] File not found: " + _filePath);
        return false;
    }

    var _buf = buffer_load(_filePath);
    if (_buf == -1) {
        show_debug_message("[weapon_definitions_load] Failed to open: " + _filePath);
        return false;
    }

    var _jsonStr = buffer_read(_buf, buffer_string);
    buffer_delete(_buf);

    var _raw = json_parse(_jsonStr);
    if (!is_struct(_raw)) {
        show_debug_message("[weapon_definitions_load] Invalid JSON structure.");
        return false;
    }

    var _keys = variable_struct_get_names(_raw);
    for (var i = 0; i < array_length(_keys); i++) {
        var _key = _keys[i];
        var _cfg = _raw[$ _key];
        var _def = new create_weapon_definition(_cfg);

        global.WeaponDefinitions[$ _key] = _def;

        // Route to correct sub-registry
        var _cls = _wpn_get(_cfg, "classification", {});
        var _wClass = _wpn_get(_cls, "weapon_class", "primary");
        if (_wClass == "enemy") {
            global.EnemyWeapons[$ _key] = _def;
        } else {
            global.PlayerWeaponDefinitions[$ _key] = _def;
        }
    }

    // Aliases for legacy code
    global.Weapons = global.PlayerWeaponDefinitions;

    show_debug_message("[weapon_definitions_load] Loaded " + string(array_length(_keys)) + " weapon definitions.");
    return true;
}
