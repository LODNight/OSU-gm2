// o_item_pickup — Draw Event
var _def = item_db_get(item_id);

// Bóng mờ dưới chân vật phẩm
draw_set_color(c_black);
draw_set_alpha(0.35);
draw_ellipse(x - 7, y - 2, x + 7, y + 2, false);
draw_set_alpha(1);
draw_set_color(c_white);

if (_def != undefined && _def.icon_sprite != noone) {
    var _sw = sprite_get_width(_def.icon_sprite);
    var _sh = sprite_get_height(_def.icon_sprite);
    var _maxDim = max(_sw, _sh);
    var _targetSize = 18; // Kích thước tối đa khoảng 18px (vừa tầm mắt so với nhân vật)
    var _scale = (_maxDim > 0) ? min(1.0, _targetSize / _maxDim) : 1.0;
    
    var _xo = sprite_get_xoffset(_def.icon_sprite);
    var _yo = sprite_get_yoffset(_def.icon_sprite);
    
    // Vẽ sprite vật phẩm thu nhỏ chuẩn tỉ lệ và căn giữa bóng
    draw_sprite_ext(_def.icon_sprite, 0, x - (_sw/2 - _xo) * _scale, y - (_sh/2 - _yo) * _scale - 4, _scale, _scale, 0, c_white, 1);
} else {
    // Fallback nếu không có sprite
    draw_set_color(make_color_rgb(180, 255, 130));
    draw_circle(x, y - 4, 4, false);
    draw_set_color(c_white);
}
