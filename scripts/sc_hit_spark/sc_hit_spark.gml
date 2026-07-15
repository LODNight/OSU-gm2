// ================================================================
// sc_hit_spark — Module B: Wall Spark
// Spawn tia lửa nhỏ khi đạn chạm tường hoặc vật cản.
// ================================================================

/// @desc  Spawn N tia sáng nhỏ tại điểm đạn chạm tường.
///        Góc văng 360° đều, không bias theo hướng (khác máu).
/// @param {real} _x  Tọa độ X điểm va chạm
/// @param {real} _y  Tọa độ Y điểm va chạm
function spawn_hit_spark(_x, _y)
{
    var _count = irandom_range(3, 5); // Ít hơn máu, trông gọn hơn

    for (var i = 0; i < _count; i++)
    {
        var _spark = instance_create_depth(_x, _y, -9999, o_hit_spark);

        // Góc văng ngẫu nhiên hoàn toàn 360°
        _spark.hs_angle    = random(360);
        _spark.hs_vel      = random_range(2.5, 5.5);
        _spark.hs_lifetime = irandom_range(8, 15); // Ngắn hơn máu
        _spark.hs_timer    = _spark.hs_lifetime;
    }
}
