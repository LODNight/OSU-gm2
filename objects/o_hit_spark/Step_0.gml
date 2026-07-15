// ================================================================
// o_hit_spark — Step event
// ================================================================

x += lengthdir_x(hs_vel, hs_angle);
y += lengthdir_y(hs_vel, hs_angle);
hs_vel *= 0.78; // Spark giảm tốc nhanh hơn máu

hs_timer--;
image_alpha = hs_timer / hs_lifetime;

if (hs_timer <= 0) instance_destroy();
