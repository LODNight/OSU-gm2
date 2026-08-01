if (font_exists(fntSegoe)) draw_set_font(fntSegoe);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _valStr = (damage_value == floor(damage_value))
    ? string(int64(damage_value))
    : string_format(damage_value, 0, 1);

// ── Màu chữ theo mức falloff ──────────────────────────────────────────────
// 1.0 = dame full → Vàng sáng
// 0.8 → Cam vàng
// 0.6 trở xuống → Trắng xám nhạt (dame bị giảm mạnh)
var _r, _g, _b;
if (falloff_mult >= 0.9) {
    // Full / gần full — Vàng
    _r = 255; _g = 220; _b = 50;
} else if (falloff_mult >= 0.7) {
    // Falloff nhẹ — Cam vàng
    _t  = (falloff_mult - 0.7) / 0.2;    // 0→1 trong khoảng 0.7-0.9
    _r  = 255;
    _g  = lerp(160, 220, _t);
    _b  = lerp(80,  50,  _t);
} else {
    // Falloff nặng — Trắng nhạt xám
    _t  = clamp((falloff_mult - 0.5) / 0.2, 0, 1); // 0→1 trong khoảng 0.5-0.7
    _r  = lerp(200, 255, _t);
    _g  = lerp(200, 160, _t);
    _b  = lerp(200, 80,  _t);
}
var _textColor = make_color_rgb(_r, _g, _b);

// Shadow / Outline
draw_set_alpha(alpha * 0.80);
draw_set_color(c_black);
draw_text_transformed(x + 1, y + 1, _valStr, scale, scale, 0);
draw_text_transformed(x - 1, y + 1, _valStr, scale, scale, 0);
draw_text_transformed(x + 1, y - 1, _valStr, scale, scale, 0);
draw_text_transformed(x - 1, y - 1, _valStr, scale, scale, 0);

// Main Text
draw_set_alpha(alpha);
draw_set_color(_textColor);
draw_text_transformed(x, y, _valStr, scale, scale, 0);

// Reset
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
