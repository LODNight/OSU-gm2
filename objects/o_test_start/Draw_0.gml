// o_test_start — Draw Event
// ================================================================
// Vẽ trigger zone với màu xanh lá để dễ nhận dạng trong editor và khi debug.
// Ẩn khi game release (không quan trọng với rm_test).
// ================================================================

// Vẽ sprite gốc
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_lime, 0.5);

// Label hiển thị loại test
draw_set_color(c_lime);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_font(-1);

var _label = "START";
switch (test_type) {
    case TEST_TYPE.LIGHTING:  _label = "[START] Lighting"; break;
    case TEST_TYPE.COMBAT:    _label = "[START] Combat";   break;
    case TEST_TYPE.LOOT:      _label = "[START] Loot";     break;
    case TEST_TYPE.DIALOGUE:  _label = "[START] Dialogue"; break;
}
draw_text(x, y - sprite_height * 0.5 * image_yscale - 4, _label);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
