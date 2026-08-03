// o_goNext — Draw GUI Event
// Hiển thị thông báo [F] to go trên GUI phía trên đầu của Player khi đụng vào o_goNext

if (!_player_nearby) exit;
if (!instance_exists(o_player)) exit;

var _destRoom = noone;
if (variable_instance_exists(id, "goNext") && goNext != noone) {
    _destRoom = goNext;
} else if (variable_instance_exists(id, "nextRoom") && nextRoom != noone) {
    _destRoom = nextRoom;
} else if (variable_instance_exists(id, "targetRoom") && targetRoom != noone) {
    _destRoom = targetRoom;
}

if (_destRoom == noone) exit;

// Tính vị trí trên đầu Player
var _px = o_player.x;
var _py = o_player.y - 36;
if (sprite_exists(o_player.sprite_index)) {
    _py = o_player.y - sprite_get_height(o_player.sprite_index) * 0.75;
}

// Convert World coordinates → GUI coordinates
var _cx = camera_get_view_x(view_camera[0]);
var _cy = camera_get_view_y(view_camera[0]);
var _cw = camera_get_view_width(view_camera[0]);
var _ch = camera_get_view_height(view_camera[0]);
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _gui_x = (_px - _cx) / _cw * _gw;
var _gui_y = (_py - _cy) / _ch * _gh;

draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _txt   = promptText;
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

// Text
draw_set_color(c_white);
draw_text(_gui_x, _gui_y, _txt);

// Reset
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
