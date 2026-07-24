// ============================================================
// o_light_source — Create Event
// ============================================================
// Đặt instance này vào Room Editor.
// Điều chỉnh các biến bên dưới trực tiếp per-instance trong Room Editor.
// ============================================================

// ── Cấu hình đèn (chỉnh trong Room Editor per-instance) ──────
// light_range       : bán kính chiếu sáng (px)
// light_r/g/b       : màu ánh sáng (0–255)
// light_intensity   : độ sáng trung tâm (0.0–1.0)
// light_cast_shadows: true → raycast cắt bóng qua tường (chậm hơn)

if (!variable_instance_exists(id, "light_range"))       light_range       = 160;
if (!variable_instance_exists(id, "light_r"))           light_r           = 255;
if (!variable_instance_exists(id, "light_g"))           light_g           = 200;
if (!variable_instance_exists(id, "light_b"))           light_b           = 100;
if (!variable_instance_exists(id, "light_intensity"))   light_intensity   = 0.60;
if (!variable_instance_exists(id, "light_cast_shadows"))light_cast_shadows= false;

// Đăng ký vào danh sách đèn toàn cục
light_source_register(id, {
    range        : light_range,
    light_r      : light_r,
    light_g      : light_g,
    light_b      : light_b,
    intensity    : light_intensity,
    cast_shadows : light_cast_shadows,
});
