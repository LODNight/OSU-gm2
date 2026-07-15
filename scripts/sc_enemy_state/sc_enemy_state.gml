// ================================================================
// sc_enemy_state — State Machine của enemy
// ================================================================
// Flow cơ bản:
//   IDLE ──(phát hiện mục tiêu)──► CHASE
//   CHASE ──(vào tầm đánh)──► AIM (nếu có aimCooldown) hoặc ATTACK (nếu không)
//   AIM ──(đủ frame ngắm)──► ATTACK
//   ATTACK ──(thực hiện xong)──► IDLE  attackTimer bắt đầu đếm hồi chiêu
// ================================================================

/// @desc  Dispatcher: gọi hàm xử lý tương ứng với state hiện tại của enemy.
///        Gọi mỗi frame từ enemy_process().
function enemy_update_state()
{
    switch (state) {
        case ENEMY_STATE.IDLE:   enemy_state_idle();   break;
        case ENEMY_STATE.CHASE:  enemy_state_chase();  break;
        case ENEMY_STATE.AIM:    enemy_state_aim();    break;
        case ENEMY_STATE.ATTACK: enemy_state_attack(); break;
        case ENEMY_STATE.DEAD:   enemy_die();          break; // Fallback phòng thủ
    }
}

/// @desc  Trạng thái IDLE: đứng yên chờ phát hiện mục tiêu.
///        Chuyển sang CHASE khi mục tiêu vào aggroRange và hồi chiêu đã xong.
function enemy_state_idle()
{
    sprite_index = spr_idle;

    // Chuyển sang CHASE khi: có mục tiêu + hết hồi chiêu + mục tiêu đủ gần
    if (enemy_has_target()
        && attackTimer <= 0
        && point_distance(x, y, target.x, target.y) <= aggroRange)
    {
        state = ENEMY_STATE.CHASE;
    }
}

/// @desc  Trạng thái CHASE: đuổi theo mục tiêu, quay mặt về phía mục tiêu.
///        Chuyển sang AIM hoặc ATTACK khi đã vào tầm đánh.
function enemy_state_chase()
{
    sprite_index = spr_walk;
    enemy_face_target();

    // Mất target → quay lại IDLE
    if (!enemy_has_target()) {
        state = ENEMY_STATE.IDLE;
        return;
    }

    // Vào tầm đánh + hết hồi chiêu → chuyển sang ngắm hoặc tấn công luôn
    var _dist = point_distance(x, y, target.x, target.y);
    if (_dist <= attackRange && attackTimer <= 0) {
        aimTimer = 0;
        state = (aimCooldown > 0) ? ENEMY_STATE.AIM : ENEMY_STATE.ATTACK;
    }
}

/// @desc  Trạng thái AIM: dừng lại ngắm mục tiêu trong aimCooldown frame.
///        Chỉ RANGED enemy dùng (aimTime > 0 trong definition).
///        MELEE enemy có aimTime = 0 nên sẽ bỏ qua state này.
function enemy_state_aim()
{
    sprite_index = spr_idle;
    enemy_face_target();

    // Mất target trong lúc ngắm → huỷ ngắm, quay lại IDLE
    if (!enemy_has_target()) {
        state = ENEMY_STATE.IDLE;
        return;
    }

    aimTimer++;
    if (aimTimer >= aimCooldown) {
        state    = ENEMY_STATE.ATTACK;
        aimTimer = 0;
    }
}

/// @desc  Trạng thái ATTACK: thực hiện đòn tấn công, sau đó kích hoạt hồi chiêu.
///        Phân nhánh sang melee hoặc ranged tùy enemyCombat.
function enemy_state_attack()
{
    sprite_index = spr_idle;
    enemy_face_target();

    // Mất target trước khi ra đòn → huỷ
    if (!enemy_has_target()) {
        state = ENEMY_STATE.IDLE;
        return;
    }

    // Thực hiện đòn dựa trên kiểu chiến đấu
    if (enemyCombat == ENEMY_COMBAT.RANGED) {
        enemy_weapon_fire();
    } else {
        enemy_melee_attack();
    }

    // Kích hoạt hồi chiêu → quay về IDLE chờ
    attackTimer = attackCooldown;
    state       = ENEMY_STATE.IDLE;
}

/// @desc  Đòn cận chiến của zombie: gây damage trực tiếp lên player.
///        Flow: zombie tiến sát → dừng 1 nhịp (aimCooldown trong CHASE→AIM→ATTACK)
///              → ra đòn → player nhận damage → zombie tiếp tục chase.
///
///        Cơ chế: tạo một instance o_damage_player tạm thời 1 frame ngay tại vị trí enemy.
///        Instance này sẽ bị player detect qua get_damaged() bên o_player/Step event.
///        Sau 1 frame, instance tự hủy (alarm[0]).
function enemy_melee_attack()
{
    // Chỉ tấn công khi mục tiêu vẫn còn trong tầm cận chiến
    var _dist = point_distance(x, y, target.x, target.y);
    if (_dist > attackRange * 1.2) return; // Margin nhỏ để tránh miss sát mép

    // Spawn hitbox damage tạm thời (1 frame) tại vị trí enemy
    var _hit = instance_create_depth(x, y, depth, o_damage_player);
    _hit.damage    = 1;          // Sát thương mỗi đòn — có thể đưa vào definition sau
    _hit.hitConfirm = false;
    alarm[0] = 1;                // Alarm 0 của _hit sẽ destroy nó sau 1 frame

    // Gán alarm destroy cho hitbox (dùng with để set alarm của instance vừa tạo)
    with (_hit) {
        alarm[0] = 1;
    }
}
