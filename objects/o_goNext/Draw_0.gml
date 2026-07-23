draw_self();

var _roomName = "";
if (nextRoom != noone) _roomName = room_get_name(nextRoom);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(x, y - sprite_get_height(sprite_index) * 0.5 - 12, "NEXT");
if (_roomName != "") {
    draw_text(x, y + sprite_get_height(sprite_index) * 0.5 + 8, _roomName + " -> " + nextEntranceId);
} else {
    draw_text(x, y + sprite_get_height(sprite_index) * 0.5 + 8, nextEntranceId);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
