// ================================================================
// sc_enemy_process — Pipeline AI chính chạy mỗi frame (Step event)
// ================================================================

/// @desc  Điểm vào duy nhất của vòng lặp AI enemy mỗi frame.
///        Thứ tự xử lý: nhận đòn → kiểm tra chết → cập nhật mục tiêu
///        → đếm timer → chuyển state → di chuyển → cập nhật vị trí hiển thị.
///        Gọi trong Step event của o_enemy_parent.
function enemy_process()
{
    // 0. Cập nhật offset rung lắc từ hit shake (Module Shake)
    hit_shake_update();

    // 1. Nhận damage từ các hitbox tấn công enemy (đạn, vùng sát thương...)
    get_damaged(o_damage_enemies);

    // 2. Nếu HP về 0 hoặc âm → xử lý death và dừng pipeline
    if (hp <= 0) {
        enemy_die();
        exit;
    }

    // 3. Cập nhật biến mục tiêu (target) mỗi frame
    enemy_update_target();

    // 4. Giảm các timer hồi chiêu
    enemy_update_timers();

    // 5. Chạy logic State Machine (IDLE / CHASE / AIM / ATTACK)
    enemy_update_state();

    // 6. Tính toán và áp dụng di chuyển theo state hiện tại
    enemy_move();

    // 7. Cập nhật Y trung tâm và depth (z-order) theo vị trí thực tế
    centerY = y + centerYOffset;
    depth   = -y;
}

/// @desc  Cập nhật biến `target` trỏ đến instance player hiện tại.
///        Nếu không có player trong room thì trả về `noone`.
function enemy_update_target()
{
    target = instance_exists(o_player) ? instance_find(o_player, 0) : noone;
}

/// @desc  Giảm tất cả timer hồi chiêu mỗi frame.
///        Thêm timer mới tại đây nếu cần thêm sau này.
function enemy_update_timers()
{
    // Hồi chiêu giữa 2 lần tấn công
    if (attackTimer > 0) attackTimer--;
}

/// @desc  Kiểm tra xem enemy hiện tại có target hợp lệ không.
/// @return {bool}  true nếu target tồn tại và còn sống.
function enemy_has_target()
{
    return target != noone && instance_exists(target);
}

/// @desc  Xử lý cái chết của enemy: spawn xác, dọn dẹp damage list, destroy instance.
///        Cờ `deathHandled` đảm bảo hàm chỉ chạy đúng 1 lần dù được gọi nhiều chỗ.
function enemy_die()
{
    // Tránh gọi lại khi enemy đã đang trong quá trình chết
    if (deathHandled) return;
    deathHandled = true;
    state = ENEMY_STATE.DEAD;

    if (variable_instance_exists(id, "tutorialOwner") && instance_exists(tutorialOwner)) {
        var _tutorialOwner = tutorialOwner;
        with (_tutorialOwner) tutorial_register_enemy_kill();
    }

    // Spawn xác tại vị trí hiện tại, kế thừa hướng nhìn và độ trong suốt
    if (corpseObject != noone) {
        var _corpse = instance_create_depth(x, y, -y, corpseObject);
        if (variable_instance_exists(_corpse, "face")) _corpse.face = face;
        _corpse.image_angle = image_angle;
        _corpse.image_blend = c_dkgray; // Làm màu đậm/tối hơn
        _corpse.image_alpha = image_alpha * 0.6; // Làm mờ đi (giảm alpha)
		
    }

    // Dọn ds_list damage để tránh memory leak
    get_damaged_cleanup();
    instance_destroy();
}
