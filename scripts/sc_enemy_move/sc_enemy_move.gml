// ================================================================
// sc_enemy_move — Xử lý di chuyển và hướng nhìn của enemy
// ================================================================

/// @desc  Tính toán và áp dụng vận tốc dịch chuyển cho enemy mỗi frame.
///        Enemy chỉ di chuyển khi đang ở state CHASE; các state khác đứng yên.
///        Collision check với tilemap tường và các enemy + tường khác.
function enemy_move()
{
    // Chỉ di chuyển khi đang chase, các state khác (IDLE, AIM, ATTACK) thì đứng yên
    var _speed = (state == ENEMY_STATE.CHASE) ? chaseSpd : 0;

    // Tính vector vận tốc từ góc aimDir
    xspd = lengthdir_x(_speed, aimDir);
    yspd = lengthdir_y(_speed, aimDir);

    // Collision riêng cho trục X và Y để enemy vẫn trượt dọc tường khi bị chặn
    if (place_meeting(x + xspd, y, [tile_map, o_enemy_parent, o_wall])) xspd = 0;
    if (place_meeting(x, y + yspd, [tile_map, o_enemy_parent, o_wall])) yspd = 0;

    x += xspd;
    y += yspd;
}

/// @desc  Cập nhật góc nhìn `aimDir` và chiều nhân vật `face` về phía mục tiêu.
///        Gọi trong mỗi state cần quay mặt về phía mục tiêu (CHASE, AIM, ATTACK).
///        centerYOffset dùng để canh chính xác hướng từ "mắt" nhân vật thay vì gốc sprite.
function enemy_face_target()
{
    if (!enemy_has_target()) return;

    // Tính góc từ tâm nhân vật (có offset Y isometric) về phía mục tiêu
    aimDir = point_direction(x, y + centerYOffset, target.x, target.y);

    // Xác định hướng nhìn trái/phải dựa trên góc
    // Góc 90°–270° = nhìn trái; còn lại = nhìn phải
    face = (aimDir > 90 && aimDir < 270) ? -1 : 1;
}
