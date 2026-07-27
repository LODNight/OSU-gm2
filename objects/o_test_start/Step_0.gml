// o_test_start — Step Event
// ================================================================
// Phát hiện player đứng trên trigger.
// Khi player overlap → hiển thị prompt [F].
// Nhấn F → kích hoạt test, spawn o_test_end, tự destroy.
// ================================================================

if (room != rm_test) exit;
if (_triggered) exit;

_player_nearby = false;

if (instance_exists(o_player)) {
    if (place_meeting(x, y, o_player)) {
        _player_nearby = true;

        if (keyboard_check_pressed(ord("F"))) {
            _triggered = true;

            var _ox   = x;
            var _oy   = y;
            var _type = test_type;

            // Kích hoạt logic test
            test_zone_activate(_type, _ox, _oy);

            // Spawn o_test_end tại đúng vị trí này
            var _end = instance_create_depth(_ox, _oy, depth, o_test_end);
            _end.test_type    = _type;
            _end.origin_x     = _ox;
            _end.origin_y     = _oy;
            _end.image_xscale = image_xscale;
            _end.image_yscale = image_yscale;

            // Tự xóa (chỉ tồn tại 1 trong 2 tại 1 vị trí)
            instance_destroy();
        }
    }
}
