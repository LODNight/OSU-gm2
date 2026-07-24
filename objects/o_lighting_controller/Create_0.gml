// ============================================================
// o_lighting_controller — Create Event
// ============================================================

// Surface bóng tối (punched holes = vùng sáng của flashlight)
dark_surface = -1;

// Surface ánh sáng màu (additive overlay cho đèn tĩnh)
light_surface = -1;

// Cấu hình darkness — được ghi đè bởi sc_room_lighting khi đổi room
darkness_alpha   = 0.92;
darkness_color   = c_black;
lighting_enabled = true;

// Bật/tắt đèn pin (phím F)
flashlight_enabled = true;

// Theo dõi room hiện tại để detect đổi room
current_room = -1;

// Tilemap va chạm (cập nhật mỗi khi đổi room)
global.collision_tilemap = -1;

// Khởi tạo ds_list cho đèn tĩnh
light_source_global_init();

// Khởi tạo definitions (đảm bảo không bị gọi trùng)
if (!variable_global_exists("FlashlightDefs")) {
    sc_lighting_definitions();
}
if (!variable_global_exists("RoomLighting")) {
    sc_room_lighting_init();
}