function player_draw_weapon()
{
    if (weapon == noone) return;

    var _data = weapon.definition;
    var _xOffset = lengthdir_x(weaponOffsetDist, aimDir);
    var _yOffset = lengthdir_y(weaponOffsetDist, aimDir);
    var _yScale = (aimDir > 90 && aimDir < 270) ? -1 : 1;
    draw_sprite_ext(_data.sprite, 0, x + _xOffset, centerY + _yOffset,
        1, _yScale, aimDir, c_white, image_alpha);
}

/// @desc Draw weapon behind or in front of the player based on aim direction.
function player_draw()
{
    if (aimDir >= 90 && aimDir < 270) player_draw_weapon();
    draw_self();
    if (aimDir >= 0 && aimDir <= 89) player_draw_weapon();
    if (aimDir >= 271 && aimDir <= 360) player_draw_weapon();
}
