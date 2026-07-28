// o_test_end — Create Event
// ================================================================
// Được spawn bởi o_test_start sau khi test kích hoạt.
// Lưu test_type, origin_x, origin_y để biết sẽ reset cái gì
// và spawn lại o_test_start ở đâu.
//
// Các biến được set bởi o_test_start ngay sau instance_create_depth():
//   test_type   — TEST_TYPE enum
//   origin_x    — Vị trí X để spawn lại o_test_start
//   origin_y    — Vị trí Y để spawn lại o_test_start
// ================================================================

// Khởi tạo fallback (sẽ bị ghi đè bởi code ở o_test_start)
if (!variable_instance_exists(id, "test_type")) test_type = -1;
if (!variable_instance_exists(id, "origin_x"))  origin_x  = x;
if (!variable_instance_exists(id, "origin_y"))  origin_y  = y;

_triggered = false;
_player_nearby = false;
has_left = false;
