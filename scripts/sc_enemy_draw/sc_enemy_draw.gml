// ================================================================
// sc_enemy_draw — Vẽ nhân vật và vũ khí với z-order chính xác
// ================================================================

/// @desc  Vẽ sprite vũ khí tại vị trí xoay quanh tâm nhân vật theo góc aimDir.
///        Chỉ gọi khi hasWeapon = true và weapon hợp lệ.
///        Vũ khí được vẽ trước hoặc sau sprite nhân vật tùy góc nhìn (z-order isometric).
function enemy_draw_weapon()
{
    if (!hasWeapon || weapon == noone) return;

    // Tính offset vị trí vũ khí từ tâm nhân vật theo hướng aimDir
    var _xOff = lengthdir_x(weaponOffsetDist, aimDir);
    var _yOff = lengthdir_y(weaponOffsetDist, aimDir);

    // Vẽ sprite vũ khí tại centerY (không phải y) để canh isometric đúng
    draw_sprite_ext(
        weapon.sprite, 0,
        x + _xOff, centerY + _yOff,
        1, face,          // Scale: không flip X; face flip Y để phản chiều
        aimDir,           // Xoay theo góc ngắm
        c_white, image_alpha
    );
}

/// @desc  Entry point vẽ chính, gọi từ Draw event của o_enemy_parent.
///        Thứ tự vẽ đảm bảo z-order đúng theo góc nhìn isometric top-down:
///        - aimDir 0°–179° (nhìn xuống dưới): vũ khí trước → nhân vật đè lên
///        - aimDir 180°–359° (nhìn lên trên): nhân vật trước → vũ khí đè lên
function enemy_draw()
{
    // Nếu nhân vật đang nhìn về phía dưới (aimDir 0–179): vẽ vũ khí trước
    if (hasWeapon && aimDir >= 0 && aimDir < 180) enemy_draw_weapon();

    // Vẽ sprite nhân vật (dùng shakeX/shakeY offset từ Module Shake)
    var _sx = variable_instance_exists(id, "shakeX") ? shakeX : 0;
    var _sy = variable_instance_exists(id, "shakeY") ? shakeY : 0;
    draw_sprite_ext(
        sprite_index, image_index,
        x + _sx, y + _sy,
        face, image_yscale,   // face = 1 hoặc -1 để lật trái/phải
        image_angle,
        image_blend, image_alpha
    );

    // Nếu nhân vật đang nhìn về phía trên (aimDir 180–359): vẽ vũ khí sau
    if (hasWeapon && aimDir >= 180 && aimDir <= 359) enemy_draw_weapon();
}
