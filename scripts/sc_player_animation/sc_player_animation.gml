function player_animation()
{
    centerY = y + centerYOffset;
    aimDir = point_direction(x, centerY, mouse_x, mouse_y);

    if (mouse_x > x) image_xscale = 1;
    else if (mouse_x < x) image_xscale = -1;

    sprite_index = (xspd != 0 || yspd != 0) ? spr_walk : spr_idle;
}
