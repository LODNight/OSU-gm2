// o_test_start — Create Event
// ================================================================
// Khai báo test_type tại đây HOẶC qua Creation Code trong Room Editor.
// Ví dụ: test_type = TEST_TYPE.LIGHTING;
//
// Creation Code trong Room Editor sẽ OVERWRITE biến này,
// nên giá trị mặc định ở đây chỉ là fallback.
// ================================================================

// Khởi tạo global tracking nếu chưa có
test_zone_global_init();

// Loại test mặc định — ghi đè bằng Creation Code trong Room Editor
if (!variable_instance_exists(id, "test_type")) {
    test_type = TEST_TYPE.LIGHTING;
}

// Flag để tránh trigger 2 lần liên tiếp
_triggered = false;

// Flag cho biết player đang đứng trên trigger (dùng để vẽ GUI prompt)
_player_nearby = false;
