// sc_corpse — Shared logic cho tất cả corpse objects
// ================================================================

/// @desc Vẽ vòng viền trắng nhấp nháy quanh xác (chưa được loot).
///       Gọi trong Draw Event của mỗi corpse object.
function corpse_draw_outline()
{
    if (looted) return;

    // Nhấp nháy theo thời gian
    var _pulse = (sin(current_time * 0.006) * 0.3) + 0.7; // 0.4 – 1.0
    var _r = max(sprite_get_width(sprite_index), sprite_get_height(sprite_index)) * 0.5 + 4;

    draw_set_alpha(_pulse);
    draw_set_color(c_white);
    draw_circle(x, y, _r, true);      // Vòng viền
    draw_set_alpha(_pulse * 0.15);
    draw_set_color(c_white);
    draw_circle(x, y, _r - 2, false); // Fill nhạt bên trong
    draw_set_alpha(1);
    draw_set_color(c_white);
}


/// @desc Xử lý đếm ngược và xóa xác sau 30s khi đã loot.
///       Gọi trong Step Event của mỗi corpse object.
function corpse_step()
{
    if (!looted) return;

    // Bắt đầu đếm khi vừa loot xong
    if (loot_timer < 0) loot_timer = 30 * room_speed; // 30 giây

    loot_timer--;

    // Fade out dần trong 2 giây cuối
    var _fade_frames = 2 * room_speed;
    if (loot_timer <= _fade_frames) {
        image_alpha = max(0, loot_timer / _fade_frames) * 0.6; // 0.6 là alpha gốc
    }

    if (loot_timer <= 0) {
        instance_destroy();
    }
}
