// 1. Xác định độ phân giải bạn muốn (Ví dụ: Full HD 1920x1080)
var res_w = 1920;
var res_h = 1080;

// 2. Đổi kích thước cửa sổ game
window_set_size(res_w, res_h);

// 3. Đổi kích thước bề mặt render (Quan trọng nhất để game không bị vỡ hạt)
surface_resize(application_surface, res_w, res_h);

// 4. Đổi kích thước của layer UI/GUI (để chữ và nút bấm không bị lệch)
display_set_gui_size(res_w, res_h);

// 5. Căn giữa cửa sổ (Nên đặt lệnh window_center() vào Alarm 0 chạy sau 1 frame để Windows kịp cập nhật kích thước mới)
window_center();

// Register static weapon definitions before Player/Enemy Create events use them.
sc_weapon_init();

// Register enemy stat definitions (HP, speed, sprite...)
sc_enemy_definitions();

// Register spawner zone configurations (which enemy, how many, radius...)
sc_spawner_definitions();
