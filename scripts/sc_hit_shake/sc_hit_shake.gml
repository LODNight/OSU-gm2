// ================================================================
// sc_hit_shake — Module Shake: Hit Knockback Visual
// Rung lắc nhẹ sprite enemy khi bị trúng đạn.
// KHÔNG thay đổi x/y thật — chỉ dùng shakeX/shakeY làm offset khi Draw.
// ================================================================

/// @desc  Khởi tạo biến shake cho enemy.
///        Gọi MỘT LẦN trong enemy_apply_definition() (Create phase).
function hit_shake_create()
{
    shakeTimer = 0;
    shakePower = 0;
    shakeX     = 0;
    shakeY     = 0;
}

/// @desc  Kích hoạt hiệu ứng rung lắc khi bị trúng đạn.
///        Gọi trong sc_damage_receive sau khi trừ HP.
/// @param {real} _power  Biên độ rung (pixel), mặc định 3
function hit_shake_apply(_power = 3)
{
    shakeTimer = 8;      // Kéo dài 8 frame (~0.13s ở 60fps)
    shakePower = _power;
}

/// @desc  Cập nhật offset rung lắc mỗi frame.
///        Gọi ở đầu enemy_process() trong sc_enemy_process.
function hit_shake_update()
{
    if (shakeTimer > 0)
    {
        // Offset ngẫu nhiên trong biên độ, giảm dần theo timer còn lại
        var _fade = shakeTimer / 8; // 1.0 → 0.125 theo frame
        shakeX = random_range(-shakePower, shakePower) * _fade;
        shakeY = random_range(-shakePower, shakePower) * _fade;
        shakeTimer--;
    }
    else
    {
        shakeX = 0;
        shakeY = 0;
    }
}
