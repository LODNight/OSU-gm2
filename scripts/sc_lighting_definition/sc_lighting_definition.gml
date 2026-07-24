// ============================================================
// sc_lighting_definitions — Định nghĩa tất cả loại đèn pin
// ============================================================
// Gọi từ o_init trước khi Player Create event chạy.
//
// battery = -1          → vô hạn
// battery = N (frames)  → đèn tắt sau N frame
//   Ví dụ: battery = room_speed * 60 → 60 giây ở 60fps
//
// ambient_r: bán kính quầng sáng mờ quanh player (px)
// ============================================================

/// @function create_flashlight_definition(_config)
/// @description Struct bất biến định nghĩa một loại đèn pin.
function create_flashlight_definition(_config) constructor {
    id        = variable_struct_exists(_config, "id")        ? _config.id        : "flashlight_unknown";
    name      = variable_struct_exists(_config, "name")      ? _config.name      : "Unknown Light";
    range     = variable_struct_exists(_config, "range")     ? _config.range     : 300;
    angle     = variable_struct_exists(_config, "angle")     ? _config.angle     : 60;
    rays      = variable_struct_exists(_config, "rays")      ? _config.rays      : 60;
    ray_step  = variable_struct_exists(_config, "ray_step")  ? _config.ray_step  : 2;
    ambient_r = variable_struct_exists(_config, "ambient_r") ? _config.ambient_r : 64;
    battery   = variable_struct_exists(_config, "battery")   ? _config.battery   : -1;

    // Màu ánh sáng: r, g, b (0–255) cho light_surface
    light_r   = variable_struct_exists(_config, "light_r")   ? _config.light_r   : 255;
    light_g   = variable_struct_exists(_config, "light_g")   ? _config.light_g   : 255;
    light_b   = variable_struct_exists(_config, "light_b")   ? _config.light_b   : 255;
    intensity = variable_struct_exists(_config, "intensity")  ? _config.intensity  : 0.85;
}

/// @function sc_lighting_definitions()
/// @description Khởi tạo global.FlashlightDefs — registry tất cả đèn.
function sc_lighting_definitions() {
    global.FlashlightDefs = {

        // ── Đèn Tiêu Chuẩn ────────────────────────────────────
        // Đèn pin thông thường — cân bằng giữa range và góc nhìn
        flashlight_standard : new create_flashlight_definition({
            id        : "flashlight_standard",
            name      : "Đèn Pin Thường",
            range     : 420,
            angle     : 55,
            rays      : 60,
            ray_step  : 2,
            ambient_r : 72,
            battery   : -1,
            light_r   : 255, light_g : 255, light_b : 255,
            intensity : 0.85
        }),

        // ── Đèn Pha Rộng ──────────────────────────────────────
        // Góc nhìn rộng, tầm gần — tốt cho không gian hẹp
        flashlight_wide : new create_flashlight_definition({
            id        : "flashlight_wide",
            name      : "Đèn Pha Rộng",
            range     : 280,
            angle     : 120,
            rays      : 80,
            ray_step  : 2,
            ambient_r : 80,
            battery   : -1,
            light_r   : 220, light_g : 240, light_b : 255,  // trắng lạnh
            intensity : 0.80
        }),

        // ── Đèn Chiến Thuật ───────────────────────────────────
        // Tầm xa, góc hẹp — bắn tỉa / trinh sát từ xa
        flashlight_tactical : new create_flashlight_definition({
            id        : "flashlight_tactical",
            name      : "Đèn Chiến Thuật",
            range     : 560,
            angle     : 35,
            rays      : 50,
            ray_step  : 2,
            ambient_r : 60,
            battery   : -1,
            light_r   : 255, light_g : 255, light_b : 240,  // trắng hơi vàng
            intensity : 0.95
        }),

        // ── Đèn Bão (Lantern) ─────────────────────────────────
        // Chiếu toàn hướng 360° — không hướng theo chuột
        // angle = 360 → controller sẽ bỏ qua direction khi vẽ
        flashlight_lantern : new create_flashlight_definition({
            id        : "flashlight_lantern",
            name      : "Đèn Bão",
            range     : 200,
            angle     : 360,
            rays      : 72,
            ray_step  : 2,
            ambient_r : 120,
            battery   : -1,
            light_r   : 255, light_g : 200, light_b : 100,  // vàng ấm
            intensity : 0.75
        }),

        // ── Đèn UV ────────────────────────────────────────────
        // Tầm trung, màu tím — dùng cho hiệu ứng đặc biệt
        flashlight_uv : new create_flashlight_definition({
            id        : "flashlight_uv",
            name      : "Đèn UV",
            range     : 300,
            angle     : 60,
            rays      : 60,
            ray_step  : 2,
            ambient_r : 56,
            battery   : -1,
            light_r   : 160, light_g : 80, light_b : 255,  // tím
            intensity : 0.80
        }),
    };
}
