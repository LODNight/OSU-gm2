// ============================================================
// o_lighting_controller — Step Event
// ============================================================

// ── Detect đổi room ──────────────────────────────────────────
if (room != current_room) {
    current_room = room;

    // Cập nhật tilemap va chạm
    var _layer = layer_get_id("tile_wall");
    if (_layer != -1) {
        global.collision_tilemap = layer_tilemap_get_id(_layer);
    } else {
        global.collision_tilemap = -1;
    }

    // Đọc cấu hình độ tối của room mới
    var _cfg = room_lighting_get(room);
    darkness_alpha   = _cfg.darkness_alpha;
    darkness_color   = _cfg.darkness_color;
    lighting_enabled = _cfg.lighting_enabled;

    // Đèn pin mặc định bật khi bước vào room có lighting
    if (lighting_enabled) {
        flashlight_enabled = true;
    }

    // Free surface cũ khi đổi room để tránh stale size
    if (surface_exists(dark_surface))  surface_free(dark_surface);
    if (surface_exists(light_surface)) surface_free(light_surface);
    dark_surface  = -1;
    light_surface = -1;
}

// ── Toggle đèn pin (phím F) ───────────────────────────────────
if (keyboard_check_pressed(ord("F")) && lighting_enabled) {
    flashlight_enabled = !flashlight_enabled;
}