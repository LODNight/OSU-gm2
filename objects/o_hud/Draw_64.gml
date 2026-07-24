// GUI coordinates
var _camX = 0;
var _camY = 0;
var _camW = display_get_gui_width();
var _camH = display_get_gui_height();

// Scale HUD theo port thực tế
// Port (viewport) thường là resolution window hiển thị
var _portW = view_get_wport(0);
var _portH = view_get_hport(0);
var _guiScaleX = _camW / _portW;
var _guiScaleY = _camH / _portH;
// Dùng scale nhỏ hơn để giữ tỉ lệ uniform
var _guiScale  = min(_guiScaleX, _guiScaleY);

var _border   = round(8 * _guiScale);
var _camXBor  = _border;
var _camYBor  = _border;


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
var _hpBarW = round(120 * _guiScale); // Chiều rộng thanh máu
var _hpBarH = round(12  * _guiScale); // Chiều cao thanh máu
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
    var _barW    = _hpBarW;                                  // Khớp chiều rộng với thanh máu
    var _barH    = max(1, round(5 * _guiScale));              // Chiều cao thanh stamina
    var _barX    = _camXBor;
    var _barY    = _hpBarY + _hpBarH + round(4 * _guiScale); // Offset ngay dưới thanh máu

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


// ── Flashlight Item HUD (debug text) ─────────────────────────
// Hiển thị tên đèn dưới stamina bar.
// Ẩn hoàn toàn khi player không có đèn.
if (instance_exists(o_player)) {
    var _fl = o_player.flashlightItem;
    if (_fl != noone) {
        var _flY = _camYBor
                 + round(12 * _guiScale)  // hp bar h
                 + round(4  * _guiScale)  // gap hp→stamina
                 + round(5  * _guiScale)  // stamina bar h
                 + round(6  * _guiScale); // gap stamina→flashlight text

        // Trạng thái bật/tắt
        var _active = (instance_exists(o_lighting_controller)
                    && o_lighting_controller.flashlight_enabled);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // Tên đèn
        draw_set_color(_active
            ? make_color_rgb(200, 220, 255)   // xanh nhạt = đang bật
            : make_color_rgb(120, 120, 120));  // xám = tắt
        draw_text(_camXBor, _flY,
            "[F] " + _fl.name + (_active ? " ON" : " OFF"));

        draw_set_color(c_white);
    }
}
