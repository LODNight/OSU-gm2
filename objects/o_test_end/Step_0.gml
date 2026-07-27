// o_test_end — Step Event
// ================================================================
// Phát hiện player đứng trên trigger.
// Hiển thị prompt [F] → nhấn F → reset test, spawn lại o_test_start.
// ================================================================

if (room != rm_test) exit;
if (_triggered) exit;
if (test_type == -1) exit;

_player_nearby = false;

if (instance_exists(o_player)) {
    if (place_meeting(x, y, o_player)) {
        _player_nearby = true;

        if (keyboard_check_pressed(ord("F"))) {
            _triggered = true;

            var _type = test_type;
            var _ox   = origin_x;
            var _oy   = origin_y;
            var _xs   = image_xscale;
            var _ys   = image_yscale;

            // Reset toàn bộ những gì test đã tạo
            test_zone_reset(_type);

            // Spawn lại o_test_start tại đúng vị trí cũ
            var _start = instance_create_depth(_ox, _oy, depth, o_test_start);
            _start.test_type    = _type;
            _start.image_xscale = _xs;
            _start.image_yscale = _ys;

            // Tự xóa
            instance_destroy();
        }
    }
}
