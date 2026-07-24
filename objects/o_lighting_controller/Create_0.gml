// ============================================================
// o_lighting_controller — Create Event
// ============================================================

// Surface chứa lớp bóng tối
dark_surface = -1;

// Độ tối của toàn map
darkness_alpha = 0.92;

// Màu của bóng tối
darkness_color = c_black;

// Thông số đèn pin
flashlight_range = 420;
flashlight_angle = 55;

// Số lượng tia dùng để tạo hình nón — tăng lên để mườ hơn
flashlight_rays = 60;

// Khoảng cách mỗi bước raycast — nhỏ hơn cho va chạm chính xác hơn
ray_step = 2;

// Bật/tắt đèn pin
flashlight_enabled = true;

// Để kiểm tra việc đổi room
current_room = -1;
global.collision_tilemap = -1;