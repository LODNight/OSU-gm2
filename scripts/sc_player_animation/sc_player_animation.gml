function player_animation()
{
    centerY = y + centerYOffset;
    if (!variable_global_exists("InventoryOpen") || !global.InventoryOpen) {
        aimDir = point_direction(x, centerY, mouse_x, mouse_y);

        if (mouse_x > x) image_xscale = 1;
        else if (mouse_x < x) image_xscale = -1;
    }

    sprite_index = (xspd != 0 || yspd != 0) ? spr_walk : spr_idle;
    
    // Đảm bảo player có depth theo trục Y để tự động sắp xếp z-order với enemy và chướng ngại vật
    depth = -y;
}
