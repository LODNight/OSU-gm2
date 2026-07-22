draw_self();
draw_set_color(c_white);
var _label = isExit ? "EXIT" : (blocksPlayer ? "CLEAR" : "OPEN");
draw_text(x - 18, y - sprite_get_height(sprite_index) * 0.5 - 16, _label);
