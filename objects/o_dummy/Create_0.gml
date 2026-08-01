event_inherited();

maxHp = 999999;
hp    = maxHp;

// Khởi tạo shake variables (shakeTimer, shakePower, shakeX, shakeY)
hit_shake_create();

// Khởi tạo damage_list cho dummy
get_damaged_create(maxHp, false);

centerYOffset = 0;
centerY       = y;

// Đảm bảo không di chuyển
xspd = 0;
yspd = 0;
