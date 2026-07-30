// ================================================================
// sc_enemy_definition — Hệ thống định nghĩa & nạp dữ liệu Enemy
// ================================================================

/// @desc Chuyển đổi tên enum, asset, weapon từ chuỗi string trong JSON sang dữ liệu GML
/// @param {any} _val Giá trị truyền vào (string, struct, number...)
function enemy_parse_val(_val)
{
    if (is_string(_val)) {
        // Enums
        if (_val == "ZOMBIE") return ENEMY_TYPE.ZOMBIE;
        if (_val == "HUMAN")  return ENEMY_TYPE.HUMAN;
        if (_val == "BOSS")   return ENEMY_TYPE.BOSS;
        if (_val == "MUTANT") return ENEMY_TYPE.MUTANT;
        if (_val == "MELEE")  return ENEMY_COMBAT.MELEE;
        if (_val == "RANGED") return ENEMY_COMBAT.RANGED;
        if (_val == "STAND")  return ENEMY_IDLE.STAND;
        if (_val == "WANDER") return ENEMY_IDLE.WANDER;
        if (_val == "PATROL") return ENEMY_IDLE.PATROL;

        // Vũ khí kẻ địch
        if (variable_global_exists("EnemyWeapons") && variable_struct_exists(global.EnemyWeapons, _val)) {
            return global.EnemyWeapons[$ _val];
        }

        // Sprite hoặc Object asset
        var _asset = asset_get_index(_val);
        if (_asset != -1) return _asset;
    }
    return _val;
}

/// @desc   Tạo cấu hình chi tiết cho loại Enemy (hỗ trợ cả schema phân cấp và legacy).
/// @param  {struct} _config  Struct chứa tham số cấu hình của enemy.
function create_enemy_definition(_config) constructor
{
    id          = variable_struct_exists(_config, "id")          ? _config.id          : "enemy_unknown";
    displayName = variable_struct_exists(_config, "displayName") ? _config.displayName : "Unknown Enemy";
    enemyType   = variable_struct_exists(_config, "enemyType")   ? enemy_parse_val(_config.enemyType) : ENEMY_TYPE.ZOMBIE;

    // ── 1. Stats (Chỉ số) ──
    var _st = variable_struct_exists(_config, "stats") ? _config.stats : {};
    stats = {
        maxHp     : variable_struct_exists(_st, "maxHp")     ? _st.maxHp     : (variable_struct_exists(_config, "maxHp") ? _config.maxHp : 30),
        armor     : variable_struct_exists(_st, "armor")     ? _st.armor     : 0,
        moveSpeed : variable_struct_exists(_st, "moveSpeed") ? _st.moveSpeed : 1.0,
        chaseSpeed: variable_struct_exists(_st, "chaseSpeed")? _st.chaseSpeed: (variable_struct_exists(_config, "chaseSpeed") ? _config.chaseSpeed : 1.5),
        turnSpeed : variable_struct_exists(_st, "turnSpeed") ? _st.turnSpeed : 12,
        mass      : variable_struct_exists(_st, "mass")      ? _st.mass      : 1.0
    };

    // ── 2. Perception (Thị giác / Thính giác) ──
    var _per = variable_struct_exists(_config, "perception") ? _config.perception : {};
    perception = {
        visionRange    : variable_struct_exists(_per, "visionRange")    ? _per.visionRange    : (variable_struct_exists(_config, "aggroRange") ? _config.aggroRange : 200),
        visionAngle    : variable_struct_exists(_per, "visionAngle")    ? _per.visionAngle    : 100,
        hearingRange   : variable_struct_exists(_per, "hearingRange")   ? _per.hearingRange   : 300,
        loseTargetRange: variable_struct_exists(_per, "loseTargetRange")? _per.loseTargetRange: 350,
        memoryTime     : variable_struct_exists(_per, "memoryTime")     ? _per.memoryTime     : 180
    };

    // ── 3. Combat (Chiến đấu) ──
    var _com = variable_struct_exists(_config, "combat") ? _config.combat : {};
    combat = {
        combatType    : variable_struct_exists(_com, "combatType")    ? enemy_parse_val(_com.combatType)    : (variable_struct_exists(_config, "combatType") ? enemy_parse_val(_config.combatType) : ENEMY_COMBAT.MELEE),
        damage        : variable_struct_exists(_com, "damage")        ? _com.damage        : 10,
        attackRange   : variable_struct_exists(_com, "attackRange")   ? _com.attackRange   : (variable_struct_exists(_config, "attackRange") ? _config.attackRange : 20),
        attackCooldown: variable_struct_exists(_com, "attackCooldown")? _com.attackCooldown: (variable_struct_exists(_config, "attackCooldown") ? _config.attackCooldown : 45),
        windupTime    : variable_struct_exists(_com, "windupTime")    ? _com.windupTime    : 12,
        recoveryTime  : variable_struct_exists(_com, "recoveryTime")  ? _com.recoveryTime  : 15,
        hitFrame      : variable_struct_exists(_com, "hitFrame")      ? _com.hitFrame      : 4,
        knockbackForce: variable_struct_exists(_com, "knockbackForce")? _com.knockbackForce: 2
    };

    // ── 4. Resistance (Kháng sát thương) ──
    var _res = variable_struct_exists(_config, "resistance") ? _config.resistance : {};
    resistance = {
        bulletResistance: variable_struct_exists(_res, "bulletResistance")? _res.bulletResistance: 0,
        meleeResistance : variable_struct_exists(_res, "meleeResistance") ? _res.meleeResistance : 0,
        fireResistance  : variable_struct_exists(_res, "fireResistance")  ? _res.fireResistance  : 0,
        poisonResistance: variable_struct_exists(_res, "poisonResistance")? _res.poisonResistance: 0
    };

    // ── 5. Behaviour (Hành vi AI) ──
    var _beh = variable_struct_exists(_config, "behaviour") ? _config.behaviour : {};
    behaviour = {
        idleType       : variable_struct_exists(_beh, "idleType")       ? enemy_parse_val(_beh.idleType)       : ENEMY_IDLE.WANDER,
        wanderRadius   : variable_struct_exists(_beh, "wanderRadius")   ? _beh.wanderRadius   : 100,
        wanderWaitMin  : variable_struct_exists(_beh, "wanderWaitMin")  ? _beh.wanderWaitMin  : 60,
        wanderWaitMax  : variable_struct_exists(_beh, "wanderWaitMax")  ? _beh.wanderWaitMax  : 180,
        investigateTime: variable_struct_exists(_beh, "investigateTime")? _beh.investigateTime: 240,
        canOpenDoor    : variable_struct_exists(_beh, "canOpenDoor")    ? _beh.canOpenDoor    : false,
        canBreakDoor   : variable_struct_exists(_beh, "canBreakDoor")   ? _beh.canBreakDoor   : false,
        canCallNearby  : variable_struct_exists(_beh, "canCallNearby")  ? _beh.canCallNearby  : true,
        groupAggroRange: variable_struct_exists(_beh, "groupAggroRange")? _beh.groupAggroRange: 150
    };

    // ── 6. Animation (Hình ảnh & Tốc độ) ──
    var _anim = variable_struct_exists(_config, "animation") ? _config.animation : {};
    animation = {
        spriteIdle  : variable_struct_exists(_anim, "spriteIdle")  ? enemy_parse_val(_anim.spriteIdle)  : (variable_struct_exists(_config, "spriteIdle") ? enemy_parse_val(_config.spriteIdle) : noone),
        spriteWalk  : variable_struct_exists(_anim, "spriteWalk")  ? enemy_parse_val(_anim.spriteWalk)  : (variable_struct_exists(_config, "spriteWalk") ? enemy_parse_val(_config.spriteWalk) : noone),
        spriteAttack: variable_struct_exists(_anim, "spriteAttack")? enemy_parse_val(_anim.spriteAttack): noone,
        spriteHit   : variable_struct_exists(_anim, "spriteHit")   ? enemy_parse_val(_anim.spriteHit)   : noone,
        spriteDeath : variable_struct_exists(_anim, "spriteDeath") ? enemy_parse_val(_anim.spriteDeath) : noone,
        idleSpeed   : variable_struct_exists(_anim, "idleSpeed")   ? _anim.idleSpeed   : 0.15,
        walkSpeed   : variable_struct_exists(_anim, "walkSpeed")   ? _anim.walkSpeed   : 0.20,
        attackSpeed : variable_struct_exists(_anim, "attackSpeed") ? _anim.attackSpeed : 0.25,
        deathSpeed  : variable_struct_exists(_anim, "deathSpeed")  ? _anim.deathSpeed  : 0.15
    };

    // ── 7. Audio (Âm thanh) ──
    var _aud = variable_struct_exists(_config, "audio") ? _config.audio : {};
    audio = {
        idleSounds     : variable_struct_exists(_aud, "idleSounds")     ? _aud.idleSounds     : [],
        aggroSounds    : variable_struct_exists(_aud, "aggroSounds")    ? _aud.aggroSounds    : [],
        attackSounds   : variable_struct_exists(_aud, "attackSounds")   ? _aud.attackSounds   : [],
        hitSounds      : variable_struct_exists(_aud, "hitSounds")      ? _aud.hitSounds      : [],
        deathSounds    : variable_struct_exists(_aud, "deathSounds")    ? _aud.deathSounds    : [],
        idleSoundChance: variable_struct_exists(_aud, "idleSoundChance")? _aud.idleSoundChance: 0.003
    };

    // ── 8. Loot (Phần thưởng) ──
    var _loot = variable_struct_exists(_config, "loot") ? _config.loot : {};
    loot = {
        lootTableId: variable_struct_exists(_loot, "lootTableId")? _loot.lootTableId: "",
        expReward  : variable_struct_exists(_loot, "expReward")  ? _loot.expReward  : 5,
        currencyMin: variable_struct_exists(_loot, "currencyMin")? _loot.currencyMin: 0,
        currencyMax: variable_struct_exists(_loot, "currencyMax")? _loot.currencyMax: 0
    };

    // ── 9. Special (Hiệu ứng đặc biệt) ──
    var _spec = variable_struct_exists(_config, "special") ? _config.special : {};
    special = {
        effectOnHit    : variable_struct_exists(_spec, "effectOnHit")    ? _spec.effectOnHit    : undefined,
        effectOnDeath  : variable_struct_exists(_spec, "effectOnDeath")  ? _spec.effectOnDeath  : undefined,
        explosionRadius: variable_struct_exists(_spec, "explosionRadius")? _spec.explosionRadius: 0
    };

    // ── 10. Vũ khí & Xác chết ──
    weapon       = variable_struct_exists(_config, "weapon")       ? enemy_parse_val(_config.weapon)       : noone;
    corpseObject = variable_struct_exists(_config, "corpseObject") ? enemy_parse_val(_config.corpseObject) : noone;

    // Tương thích ngược (Legacy variables)
    maxHp          = stats.maxHp;
    chaseSpeed     = stats.chaseSpeed;
    aggroRange     = perception.visionRange;
    attackRange    = combat.attackRange;
    attackCooldown = combat.attackCooldown;
    combatType     = combat.combatType;
    aimTime        = variable_struct_exists(_config, "aimTime") ? _config.aimTime : 0;
    spriteIdle     = animation.spriteIdle;
    spriteWalk     = animation.spriteWalk;
}

/// @desc  Áp dụng cấu hình definition vào instance enemy mới tạo.
/// @param {struct} _definition  Một instance của create_enemy_definition
function enemy_apply_definition(_definition)
{
    enemyDefinition = _definition;

    // ──── Stats ────
    maxHp      = _definition.stats.maxHp;
    hp         = maxHp;
    armor      = _definition.stats.armor;
    moveSpeed  = _definition.stats.moveSpeed;
    chaseSpd   = _definition.stats.chaseSpeed;
    turnSpeed  = _definition.stats.turnSpeed;
    mass       = _definition.stats.mass;

    // ──── Perception ────
    visionRange     = _definition.perception.visionRange;
    visionAngle     = _definition.perception.visionAngle;
    hearingRange    = _definition.perception.hearingRange;
    loseTargetRange = _definition.perception.loseTargetRange;
    memoryTime      = _definition.perception.memoryTime;
    aggroRange      = visionRange;

    // ──── Combat ────
    enemyCombat    = _definition.combat.combatType;
    combatType     = enemyCombat;
    damage         = _definition.combat.damage;
    attackRange    = _definition.combat.attackRange;
    attackCooldown = _definition.combat.attackCooldown;
    windupTime     = _definition.combat.windupTime;
    recoveryTime   = _definition.combat.recoveryTime;
    hitFrame       = _definition.combat.hitFrame;
    knockbackForce = _definition.combat.knockbackForce;
    aimCooldown    = _definition.aimTime;

    // ──── Resistance ────
    bulletResistance = _definition.resistance.bulletResistance;
    meleeResistance  = _definition.resistance.meleeResistance;
    fireResistance   = _definition.resistance.fireResistance;
    poisonResistance = _definition.resistance.poisonResistance;

    // ──── Behaviour ────
    idleType        = _definition.behaviour.idleType;
    wanderRadius    = _definition.behaviour.wanderRadius;
    wanderWaitMin   = _definition.behaviour.wanderWaitMin;
    wanderWaitMax   = _definition.behaviour.wanderWaitMax;
    investigateTime = _definition.behaviour.investigateTime;
    canOpenDoor     = _definition.behaviour.canOpenDoor;
    canBreakDoor    = _definition.behaviour.canBreakDoor;
    canCallNearby   = _definition.behaviour.canCallNearby;
    groupAggroRange = _definition.behaviour.groupAggroRange;

    // ──── Animation ────
    spr_idle      = _definition.animation.spriteIdle;
    spr_walk      = _definition.animation.spriteWalk;
    spr_attack    = _definition.animation.spriteAttack;
    spr_hit       = _definition.animation.spriteHit;
    spr_death     = _definition.animation.spriteDeath;
    animIdleSpd   = _definition.animation.idleSpeed;
    animWalkSpd   = _definition.animation.walkSpeed;
    animAttackSpd = _definition.animation.attackSpeed;
    animDeathSpd  = _definition.animation.deathSpeed;

    // ──── Audio ────
    idleSounds      = _definition.audio.idleSounds;
    aggroSounds     = _definition.audio.aggroSounds;
    attackSounds    = _definition.audio.attackSounds;
    hitSounds       = _definition.audio.hitSounds;
    deathSounds     = _definition.audio.deathSounds;
    idleSoundChance = _definition.audio.idleSoundChance;

    // ──── Loot ────
    lootTableId = _definition.loot.lootTableId;
    expReward   = _definition.loot.expReward;
    currencyMin = _definition.loot.currencyMin;
    currencyMax = _definition.loot.currencyMax;

    // ──── Special ────
    effectOnHit     = _definition.special.effectOnHit;
    effectOnDeath   = _definition.special.effectOnDeath;
    explosionRadius = _definition.special.explosionRadius;

    // ──── Weapon & Corpse ────
    weapon       = _definition.weapon;
    hasWeapon    = (weapon != noone);
    corpseObject = _definition.corpseObject;

    // ──── Khởi tạo nhận damage & shake ────
    get_damaged_create(hp);
    hit_shake_create();
}

/// @desc  Registry trung tâm — Đăng ký tất cả loại enemy từ JSON hoặc GML Code.
///        Gọi từ o_init Create event.
function sc_enemy_definitions()
{
    global.EnemyDefinitions = {};

    var _filePath = "enemy_definitions.json";
    var _jsonLoaded = false;

    if (file_exists(_filePath)) {
        var _buffer = buffer_load(_filePath);
        if (_buffer != -1) {
            var _jsonStr = buffer_read(_buffer, buffer_string);
            buffer_delete(_buffer);

            var _rawData = json_parse(_jsonStr);
            if (is_struct(_rawData)) {
                var _keys = variable_struct_get_names(_rawData);
                for (var i = 0; i < array_length(_keys); i++) {
                    var _key = _keys[i];
                    var _cfg = _rawData[$ _key];
                    global.EnemyDefinitions[$ _key] = new create_enemy_definition(_cfg);
                }
                _jsonLoaded = true;
            }
        }
    }

    // Fallback định nghĩa thủ công bằng GML nếu không tìm thấy file JSON
    if (!_jsonLoaded) {
        global.EnemyDefinitions.zombie_speed_1 = new create_enemy_definition({
            id          : "zombie_speed_1",
            displayName : "Fast Zombie",
            enemyType   : ENEMY_TYPE.ZOMBIE,
            stats       : { maxHp: 30, armor: 0, moveSpeed: 1.2, chaseSpeed: 1.8, turnSpeed: 12, mass: 0.8 },
            perception  : { visionRange: 210, visionAngle: 100, hearingRange: 320, loseTargetRange: 350, memoryTime: 180 },
            combat      : { combatType: ENEMY_COMBAT.MELEE, damage: 10, attackRange: 18, attackCooldown: 45, windupTime: 12, recoveryTime: 15, hitFrame: 4, knockbackForce: 2 },
            resistance  : { bulletResistance: 0, meleeResistance: 0, fireResistance: -0.25, poisonResistance: 1 },
            behaviour   : { idleType: ENEMY_IDLE.WANDER, wanderRadius: 100, wanderWaitMin: 60, wanderWaitMax: 180, investigateTime: 240, canOpenDoor: false, canBreakDoor: false, canCallNearby: true, groupAggroRange: 150 },
            animation   : { spriteIdle: s_z_speed1_idle, spriteWalk: s_z_speed1_walk, spriteDeath: s_z_speed1_die, idleSpeed: 0.15, walkSpeed: 0.2, deathSpeed: 0.15 },
            audio       : { idleSounds: ["snd_zombie_idle_01"], aggroSounds: ["snd_zombie_aggro_01"], attackSounds: ["snd_zombie_attack_01"], hitSounds: ["snd_zombie_hit_01"], deathSounds: ["snd_zombie_death_01"], idleSoundChance: 0.003 },
            loot        : { lootTableId: "loot_zombie_common", expReward: 5, currencyMin: 0, currencyMax: 2 },
            corpseObject: o_z_speed_1_die
        });

        global.EnemyDefinitions.zombie_basic_1 = new create_enemy_definition({
            id          : "zombie_basic_1",
            displayName : "Walker Zombie",
            enemyType   : ENEMY_TYPE.ZOMBIE,
            stats       : { maxHp: 30, chaseSpeed: 0.8 },
            perception  : { visionRange: 180 },
            combat      : { combatType: ENEMY_COMBAT.MELEE, attackRange: 15, attackCooldown: 45 },
            animation   : { spriteIdle: s_z1_idle, spriteWalk: s_z1_walk, spriteDeath: s_z1_die },
            corpseObject: o_z_1_die
        });

        global.EnemyDefinitions.human_guard = new create_enemy_definition({
            id          : "human_guard",
            displayName : "Human Guard",
            enemyType   : ENEMY_TYPE.HUMAN,
            stats       : { maxHp: 50, chaseSpeed: 1.5 },
            perception  : { visionRange: 200 },
            combat      : { combatType: ENEMY_COMBAT.RANGED, attackRange: 160, attackCooldown: 90 },
            animation   : { spriteIdle: s_hu_1_idle, spriteWalk: s_hu_1_walk, spriteDeath: s_hu_1_die },
            weapon      : global.EnemyWeapons.e_pistol,
            corpseObject: o_h_1_die
        });

        global.EnemyDefinitions.human_soldier = new create_enemy_definition({
            id          : "human_soldier",
            displayName : "Elite Soldier",
            enemyType   : ENEMY_TYPE.HUMAN,
            stats       : { maxHp: 100, chaseSpeed: 1.5 },
            perception  : { visionRange: 300 },
            combat      : { combatType: ENEMY_COMBAT.RANGED, attackRange: 250, attackCooldown: 180 },
            animation   : { spriteIdle: s_hu_soli1_idle, spriteWalk: s_hu_soli1_walk, spriteDeath: s_hu_soli1_die },
            weapon      : global.EnemyWeapons.e_sniper,
            corpseObject: o_h_soli_die
        });
    }
}
