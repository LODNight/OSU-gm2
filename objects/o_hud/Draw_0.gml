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
var _maxHp = (playerMaxHp > 0) ? playerMaxHp : 100;
var _hpBarW = 120; // Chiều rộng thanh máu
var _hpBarH = 12;  // Chiều cao thanh máu
var _hpBarX = _camXBor;
var _hpBarY = _camYBor;

// 1. Nền tối màu
draw_set_color(make_color_rgb(30, 30, 30));
draw_rectangle(_hpBarX, _hpBarY, _hpBarX + _hpBarW, _hpBarY + _hpBarH, false);

// 2. Thanh máu trễ màu trắng (khoảng trắng bị trừ máu)
var _delayRatio = playerHpDelay / _maxHp;
var _delayW = _hpBarW * _delayRatio;
if (_delayW > 0) {
    draw_set_color(c_white);
    draw_rectangle(_hpBarX, _hpBarY, _hpBarX + _delayW, _hpBarY + _hpBarH, false);
}

// 3. Thanh máu hiện tại màu đỏ
var _hpRatio = playerHp / _maxHp;
var _fillW = _hpBarW * _hpRatio;
if (_fillW > 0) {
    draw_set_color(make_color_rgb(220, 40, 40)); // Màu đỏ tươi
    draw_rectangle(_hpBarX, _hpBarY, _hpBarX + _fillW, _hpBarY + _hpBarH, false);
}

// 4. Viền thanh máu
draw_set_color(make_color_rgb(180, 180, 180));
draw_rectangle(_hpBarX, _hpBarY, _hpBarX + _hpBarW, _hpBarY + _hpBarH, true);

draw_set_color(c_white);


// ── Stamina Bar (thanh ngang dưới HP) ────────────────────────────────
if (instance_exists(o_player))
{
    var _ratio = 1;
    with (o_player) {
        _ratio = stamina_get_ratio();
    }
    var _barW    = _hpBarW;  // Khớp chiều rộng với thanh máu (120px)
    var _barH    = 5;        // Chiều cao thanh stamina
    var _barX    = _camXBor;
    var _barY    = _hpBarY + _hpBarH + 4; // Offset ngay dưới thanh máu

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
