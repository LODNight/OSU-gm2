// ================================================================
// o_hit_spark — Draw event
// Vẽ tia lửa là chấm vàng nhỏ với alpha hiện tại.
// ================================================================

draw_set_alpha(image_alpha);
draw_set_color(c_yellow);
draw_circle(x, y, 1, false);

draw_set_alpha(1);
draw_set_color(c_white);
