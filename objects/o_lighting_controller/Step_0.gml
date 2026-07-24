// ============================================================
// o_lighting_controller — Step Event
// ============================================================

if (room != current_room) {
    current_room = room;
    // Đèn pin mặc định được bật khi bắt đầu raid (đổi room)
    flashlight_enabled = true;
    
    var _layer = layer_get_id("tile_wall");
    if (_layer != -1) {
        global.collision_tilemap = layer_tilemap_get_id(_layer);
    } else {
        global.collision_tilemap = -1;
    }
}

if (keyboard_check_pressed(ord("F"))) {
    flashlight_enabled = !flashlight_enabled;
}