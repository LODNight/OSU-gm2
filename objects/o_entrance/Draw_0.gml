draw_self();

var _tag = entranceId;
if (variable_instance_exists(id, "labelText") && labelText != "") {
    _tag = labelText;
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(x, y - sprite_get_height(sprite_index) * 0.5 - 12, _tag);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
