// ================================================================
// o_hit_blood — Draw event
// Vẽ hạt máu là một chấm tròn đỏ nhỏ với alpha hiện tại.
// ================================================================

draw_set_alpha(image_alpha);
draw_set_color(c_red);
draw_circle(x, y, hb_radius, false);

// Reset về mặc định sau khi vẽ
draw_set_alpha(1);
draw_set_color(c_white);
