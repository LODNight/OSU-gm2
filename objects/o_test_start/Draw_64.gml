// o_test_start — Draw GUI Event
// ================================================================
// Vẽ badge [F] Activate trên GUI layer — không bị ảnh hưởng bởi lighting.
// Chỉ hiện khi player đứng trên trigger (_player_nearby = true từ Step event).
// ================================================================

if (!_player_nearby) exit;

// ── Convert tọa độ World → GUI ──────────────────────────────────
var _cx = camera_get_view_x(view_camera[0]);
var _cy = camera_get_view_y(view_camera[0]);
var _cw = camera_get_view_width(view_camera[0]);
var _ch = camera_get_view_height(view_camera[0]);
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _gui_x = (x - _cx) / _cw * _gw;
var _gui_y = (y - _cy) / _ch * _gh - sprite_height * 0.5 * image_yscale * (_gh / _ch) - 12;

// ── Tên test để hiển thị trong badge ────────────────────────────
var _label = "Activate";
switch (test_type) {
    case TEST_TYPE.LIGHTING:  _label = "Lighting Test"; break;
    case TEST_TYPE.CAMERA:    _label = "Camera Test";   break;
    case TEST_TYPE.COMBAT:    _label = "Combat Test";   break;
    case TEST_TYPE.LOOT:      _label = "Loot Test";     break;
    case TEST_TYPE.DIALOGUE:  _label = "Dialogue Test"; break;
}

// ── Vẽ badge [F] Activate ───────────────────────────────────────
draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _txt   = "[F]  " + _label;
var _tw    = string_width(_txt);
var _th    = string_height(_txt);
var _pad_x = 10;
var _pad_y = 5;
var _bx1   = _gui_x - _tw * 0.5 - _pad_x;
var _by1   = _gui_y - _th * 0.5 - _pad_y;
var _bx2   = _gui_x + _tw * 0.5 + _pad_x;
var _by2   = _gui_y + _th * 0.5 + _pad_y;

// Nền đen mờ
draw_set_color(c_black);
draw_set_alpha(0.75);
draw_roundrect_ext(_bx1, _by1, _bx2, _by2, 5, 5, false);

// Viền trắng
draw_set_alpha(1);
draw_set_color(c_white);
draw_roundrect_ext(_bx1, _by1, _bx2, _by2, 5, 5, true);

// Chữ trắng
draw_set_color(c_white);
draw_text(_gui_x, _gui_y, _txt);

// Reset
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
