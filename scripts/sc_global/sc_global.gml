// ================================================================
// sc_global — Định nghĩa enum và hằng số dùng chung toàn dự án
// ================================================================

/// Các trạng thái trong State Machine của enemy.
/// Chỉ giữ lại những state đang thực sự dùng trong sc_enemy_state.gml
enum ENEMY_STATE {
    IDLE,    // Đứng yên, chưa phát hiện mục tiêu
    CHASE,   // Đang đuổi theo mục tiêu
    AIM,     // Dừng lại ngắm trước khi bắn (chỉ RANGED dùng)
    ATTACK,  // Đang thực hiện đòn tấn công
    DEAD,    // Đã chết, chờ spawn xác
}

/// Phân loại kiểu chiến đấu của enemy.
enum ENEMY_COMBAT {
    MELEE,   // Cận chiến (zombie) — tấn công bằng va chạm / hitbox
    RANGED,  // Tầm xa (lính) — tấn công bằng đạn
}

/// Trạng thái của Spawner.
enum SPAWNER_STATE {
    IDLE,     // Chờ player bước vào activationRadius
    ACTIVE,   // Đang spawn enemy theo timer
    DEPLETED, // Đã spawn đủ totalLimit — không spawn nữa
}

/// Tutorial zone behaviours. Each o_tutorial selects one by tutorialId.
enum TUTORIAL_TYPE {
    MOVE_AND_PICKUP,
    CLEAR_ARENA,
    ESCAPE_HORDE
}

// Trạng thái Quest
enum QuestStatus {
    NOT_STARTED,
    ACTIVE,
    READY_TO_TURN_IN,
    COMPLETED,
    FAILED
}

// Loại mục tiêu Quest
enum QuestObjectiveType {
    KILL,
    COLLECT_ITEM,
    INTERACT,
    REACH_LOCATION,
    TALK_TO_NPC,
    ESCORT,
    SURVIVE,
    CUSTOM
}

// Điều kiện thất bại Quest
enum QUEST_FAIL {
    NPC_DIED,        // NPC giao nhiệm vụ bị giết
    JOIN_FACTION,    // Player gia nhập phe đối lập
    TIME_LIMIT,      // Hết thời gian
    ITEM_EXPIRED,    // Item hết hạn / mất
    CUSTOM           // Điều kiện tuỳ biến
}

// Loại vật phẩm
enum ITEM_TYPE {
    AMMO,            // Đạn dược
    WEAPON,          // Vũ khí rơi ra
    CONSUMABLE,      // Đồ dùng một lần (medkit, stim...)
    KEY_ITEM,        // Vật phẩm nhiệm vụ (không bán được)
    MATERIAL         // Nguyên liệu craft / bán lấy tiền
}

// ================================================================
// Currency — Tiền tệ trong game
// ================================================================

/// @desc Khởi tạo ví tiền của player. Gọi từ o_init.
function currency_init() {
    if (!variable_global_exists("PlayerCurrency")) {
        global.PlayerCurrency = 0;
    }
}

/// @desc Cộng tiền vào ví. Số âm sẽ bị bỏ qua.
/// @param {real} _amount Số tiền cần thêm
function currency_add(_amount) {
    if (_amount <= 0) return;
    global.PlayerCurrency += floor(_amount);
}

/// @desc Tiêu tiền từ ví. Trả về true nếu đủ tiền và đã trừ thành công.
/// @param {real} _amount Số tiền cần tiêu
/// @return {bool}
function currency_spend(_amount) {
    if (_amount <= 0) return true;
    if (global.PlayerCurrency < _amount) return false;
    global.PlayerCurrency -= floor(_amount);
    return true;
}

/// @desc Lấy số tiền hiện có.
/// @return {real}
function currency_get() {
    return variable_global_exists("PlayerCurrency") ? global.PlayerCurrency : 0;
}

/// Bật/tắt debug draw cho tất cả o_spawner trong game.
/// true  = vẽ hình vuông + thông số tại tâm mỗi spawner.
/// false = ẩn hoàn toàn khi ship game.
#macro SPAWNER_DEBUG true

/// ================================================================
/// Room transition helpers
/// ================================================================

function room_transition_init()
{
    if (variable_global_exists("RoomTransition")) return;

    global.RoomTransition = {
        active: false,
        targetRoom: noone,
        entranceId: "",
        sourceRoom: noone
    };
}

function room_transition_clear()
{
    if (!variable_global_exists("RoomTransition")) return;

    global.RoomTransition.active = false;
    global.RoomTransition.targetRoom = noone;
    global.RoomTransition.entranceId = "";
    global.RoomTransition.sourceRoom = noone;
}

function room_transition_begin(_targetRoom, _entranceId)
{
    room_transition_init();

    global.RoomTransition.active = true;
    global.RoomTransition.targetRoom = _targetRoom;
    global.RoomTransition.entranceId = _entranceId;
    global.RoomTransition.sourceRoom = room;
}

function room_transition_is_pending_for(_entranceId)
{
    return variable_global_exists("RoomTransition")
        && global.RoomTransition.active
        && global.RoomTransition.targetRoom == room
        && global.RoomTransition.entranceId == _entranceId;
}

function room_transition_apply_entrance(_entranceId)
{
    if (!room_transition_is_pending_for(_entranceId)) return false;
    if (!instance_exists(o_player)) return false;

    with (o_player) {
        x = other.x;
        y = other.y;
        centerY = y + centerYOffset;
    }

    room_transition_clear();
    return true;
}
