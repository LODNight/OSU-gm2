// ================================================================
// sc_hit_blood — Module A: Blood Splatter
// Spawn particle máu khi enemy bị trúng đạn.
// ================================================================

/// @desc  Spawn N hạt máu văng ra tại điểm va chạm.
///        Mỗi hạt bay theo hướng đạn ± bias ngẫu nhiên để tạo cảm giác thật.
/// @param {real} _x    Tọa độ X điểm trúng đạn
/// @param {real} _y    Tọa độ Y điểm trúng đạn
/// @param {real} _dir  Hướng đạn bay đến (image_angle của viên đạn)
function spawn_hit_blood(_x, _y, _dir)
{
    var _count = irandom_range(4, 6); // Số hạt máu mỗi lần

    for (var i = 0; i < _count; i++)
    {
        var _drop = instance_create_depth(_x, _y, -9999, o_hit_blood);

        // Hạt văng theo hướng đạn + lệch góc ngẫu nhiên ±60°
        _drop.hb_angle    = _dir + random_range(-60, 60);
        _drop.hb_vel      = random_range(1.5, 4.5);
        _drop.hb_lifetime = irandom_range(15, 30);
        _drop.hb_timer    = _drop.hb_lifetime;

        // Kích thước hạt ngẫu nhiên nhỏ
        _drop.hb_radius   = random_range(1, 2.5);
    }
}
