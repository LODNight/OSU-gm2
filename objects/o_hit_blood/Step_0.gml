// ================================================================
// o_hit_blood — Step event
// Di chuyển hạt máu, giảm alpha tuyến tính, destroy khi hết lifetime.
// ================================================================

// Di chuyển theo hướng + giảm tốc độ (friction)
x += lengthdir_x(hb_vel, hb_angle);
y += lengthdir_y(hb_vel, hb_angle);
hb_vel *= 0.82; // Ma sát: giảm tốc mỗi frame

// Giảm alpha tuyến tính theo thời gian
hb_timer--;
image_alpha = hb_timer / hb_lifetime;

// Destroy khi hết lifetime
if (hb_timer <= 0) instance_destroy();
