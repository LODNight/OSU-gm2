// ================================================================
// sc_enemy_definition — Định nghĩa và áp dụng cấu hình enemy
// ================================================================

/// @desc   Tạo một cấu hình bất biến (immutable) cho một loại enemy.
///         Dùng new create_enemy_definition({...}) khi đăng ký trong sc_enemy_definitions().
/// @param  {struct} _config  Struct chứa các tham số cấu hình (xem các field bên dưới).
function create_enemy_definition(_config) constructor
{
    // ──── Định danh ────
    id = _config.id;

    // ──── Chỉ số chiến đấu (có giá trị mặc định nếu không truyền vào) ────
    maxHp          = variable_struct_exists(_config, "maxHp")          ? _config.maxHp          : 10;
    chaseSpeed     = variable_struct_exists(_config, "chaseSpeed")     ? _config.chaseSpeed     : 1;
    aggroRange     = variable_struct_exists(_config, "aggroRange")     ? _config.aggroRange     : 200;
    attackRange    = variable_struct_exists(_config, "attackRange")    ? _config.attackRange    : 40;
    aimTime        = variable_struct_exists(_config, "aimTime")        ? _config.aimTime        : 0;
    attackCooldown = variable_struct_exists(_config, "attackCooldown") ? _config.attackCooldown : 45;
    combatType     = variable_struct_exists(_config, "combatType")     ? _config.combatType     : ENEMY_COMBAT.MELEE;

    // ──── Hiển thị ────
    spriteIdle   = variable_struct_exists(_config, "spriteIdle")   ? _config.spriteIdle   : noone;
    spriteWalk   = variable_struct_exists(_config, "spriteWalk")   ? _config.spriteWalk   : spriteIdle; // fallback về idle nếu không có walk
    weapon       = variable_struct_exists(_config, "weapon")       ? _config.weapon       : noone;
    corpseObject = variable_struct_exists(_config, "corpseObject") ? _config.corpseObject : noone;
}

/// @desc  Áp dụng một definition vào instance enemy mới được tạo.
///        Gọi trong Create event của mỗi concrete enemy (o_z_1, o_h_1, o_h_soli...).
///        Hàm này là điểm DUY NHẤT khởi tạo damage list — không gọi get_damaged_create() ở nơi khác.
/// @param {struct} _definition  Một instance của create_enemy_definition
function enemy_apply_definition(_definition)
{
    // Lưu lại definition gốc để debug / UI sau này
    enemyDefinition = _definition;

    // ──── Áp dụng chỉ số ────
    maxHp          = _definition.maxHp;
    hp             = maxHp;              // HP hiện tại bắt đầu bằng max
    chaseSpd       = _definition.chaseSpeed;
    aggroRange     = _definition.aggroRange;
    attackRange    = _definition.attackRange;
    aimCooldown    = _definition.aimTime;
    attackCooldown = _definition.attackCooldown;
    enemyCombat    = _definition.combatType;

    // ──── Áp dụng sprite ────
    spr_idle = _definition.spriteIdle;
    spr_walk = _definition.spriteWalk;

    // ──── Áp dụng vũ khí ────
    weapon    = _definition.weapon;
    hasWeapon = (weapon != noone);

    // ──── Áp dụng xác ────
    corpseObject = _definition.corpseObject;

    // ──── Khởi tạo hệ thống nhận damage ────
    // Gọi đúng một lần duy nhất ở đây, SAU KHI hp cuối cùng đã được xác định.
    // o_enemy_parent/Create_0.gml KHÔNG được gọi hàm này nữa.
    get_damaged_create(hp);
}

/// @desc  Registry trung tâm — Đăng ký tất cả loại enemy tại đây.
///        Thêm enemy type mới: thêm entry vào struct bên dưới,
///        rồi tạo object kế thừa o_enemy_gun hoặc o_enemy_z và gọi enemy_apply_definition().
///        Gọi hàm này từ o_init Create event.
function sc_enemy_definitions()
{
    global.EnemyDefinitions = {

        // ── Lính canh (bắn súng ngắn, aggro tầm trung) ──
        human_guard : new create_enemy_definition({
            id            : "human_guard",
            maxHp         : 10,
            chaseSpeed    : 1.5,
            aggroRange    : 200,
            attackRange   : 50,
            aimTime       : 60,
            attackCooldown: 90,
            combatType    : ENEMY_COMBAT.RANGED,
            spriteIdle    : s_hu_1_idle,
            spriteWalk    : s_hu_1_walk,
            weapon        : global.EnemyWeapons.e_pistol,
            corpseObject  : o_h_1_die
        }),

        // ── Lính bắn tỉa (tầm xa, cooldown dài, damage cao) ──
        human_soldier : new create_enemy_definition({
            id            : "human_soldier",
            maxHp         : 10,
            chaseSpeed    : 1.5,
            aggroRange    : 300,
            attackRange   : 200,
            aimTime       : 40,
            attackCooldown: 180,
            combatType    : ENEMY_COMBAT.RANGED,
            spriteIdle    : s_hu_soli1_idle,
            spriteWalk    : s_hu_soli1_walk,
            weapon        : global.EnemyWeapons.e_sniper,
            corpseObject  : o_h_soli_die
        }),

        // ── Zombie cơ bản (cận chiến, chậm, HP thấp) ──
        zombie_1 : new create_enemy_definition({
            id            : "zombie_1",
            maxHp         : 6,
            chaseSpeed    : 0.8,
            aggroRange    : 180,
            attackRange   : 30,
            aimTime       : 0,
            attackCooldown: 45,
            combatType    : ENEMY_COMBAT.MELEE,
            spriteIdle    : s_z1_idle,
            spriteWalk    : s_z1_walk,
            corpseObject  : o_z_1_die
        })
    };
}
