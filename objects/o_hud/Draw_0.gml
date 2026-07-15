var _camX = camera_get_view_x(view_camera[0])
var _camY = camera_get_view_y(view_camera[0])
var _camW = camera_get_view_width(view_camera[0])
var _camH = camera_get_view_height(view_camera[0])

var _border   = 8
var _camXBor  = _camX + _border
var _camYBor  = _camY + _border


// ── Vignette: màn hình tối nhẹ khi thể lực gần cạn ──────────────────
if (instance_exists(o_player))
{
    var _staminaRatio = 1;
    with (o_player) {
        _staminaRatio = stamina_get_ratio();
    }

    if (_staminaRatio < 0.30)
    {
        // Alpha vignette tăng dần khi stamina từ 30% → 0%
        var _vigAlpha = (0.30 - _staminaRatio) / 0.30 * 0.40; // Tối đa alpha = 0.40

        draw_set_alpha(_vigAlpha);
        draw_set_color(c_black);
        draw_rectangle(_camX, _camY, _camX + _camW, _camY + _camH, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}


// ── HP Bar ────────────────────────────────────────────────────────────
draw_sprite(s_healthBar, 0, _camXBor, _camYBor)

for (var i = 0; i < playerMaxHp; i++)
{
    var _img = 1
    if (i + 1 <= playerHp) { _img = 2 }

    var _sep = 3
    draw_sprite(s_healthBar, _img, _camXBor + _sep * i, _camYBor)
}


// ── Stamina Bar (thanh ngang dưới HP) ────────────────────────────────
if (instance_exists(o_player))
{
    var _ratio = 1;
    with (o_player) {
        _ratio = stamina_get_ratio();
    }
    var _barW    = 60;   // Chiều rộng thanh tối đa
    var _barH    = 5;    // Chiều cao thanh
    var _barX    = _camXBor;
    var _barY    = _camYBor + 32;  // Offset bên dưới HP bar

    // Nền xám
    draw_set_color(make_color_rgb(50, 50, 50));
    draw_rectangle(_barX, _barY, _barX + _barW, _barY + _barH, false);

    // Màu fill thay đổi theo mức stamina
    var _fillW = _barW * _ratio;
    if (_ratio > 0.50)
        draw_set_color(make_color_rgb(80, 200, 80));   // Xanh lá — đầy
    else if (_ratio > 0.20)
        draw_set_color(make_color_rgb(220, 180, 40));  // Vàng — trung bình
    else
        draw_set_color(make_color_rgb(210, 60, 60));   // Đỏ — gần cạn

    if (_fillW > 0)
        draw_rectangle(_barX, _barY, _barX + _fillW, _barY + _barH, false);

    // Viền trắng mỏng
    draw_set_color(make_color_rgb(180, 180, 180));
    draw_rectangle(_barX, _barY, _barX + _barW, _barY + _barH, true);

    draw_set_color(c_white);
}
