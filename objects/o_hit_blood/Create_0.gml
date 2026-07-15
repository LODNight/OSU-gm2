// ================================================================
// o_hit_blood — Create event
// Các biến được set bởi spawn_hit_blood() ngay sau instance_create_depth().
// ================================================================

// Các biến mặc định (fallback nếu chưa set từ bên ngoài)
hb_angle    = 0;      // Góc bay của hạt
hb_vel      = 3;      // Tốc độ ban đầu
hb_lifetime = 20;     // Tổng số frame tồn tại
hb_timer    = 20;     // Đếm ngược xuống 0 thì destroy
hb_radius   = 2;      // Bán kính vẽ

// Alpha ban đầu
image_alpha = 1;
