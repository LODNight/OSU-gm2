x += xspd;
y += yspd;

// Áp dụng gia tốc trọng lực (bay lên rồi đạt đỉnh và rớt xuống)
yspd += grav;

scale = lerp(scale, 0.55, 0.15); // Thu nhỏ mượt về kích thước nhỏ gọn 0.55

life--;
if (life < 16) {
    alpha = life / 16;
}

if (life <= 0) {
    instance_destroy();
}
