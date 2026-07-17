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
	
	player_draw_noti_reload()
}

/// @desc Temporary Draw GUI HUD for ammo and reload progress.
function player_draw_weapon_hud()
{
    if (weapon == noone) return;

    var _data = weapon.definition;
    var _guiWidth = display_get_gui_width();
    var _guiHeight = display_get_gui_height();
    var _x = _guiWidth - 270;
    var _y = _guiHeight - 92;

    draw_set_alpha(0.75);
    draw_set_color(c_black);
    draw_rectangle(_x - 12, _y - 28, _guiWidth - 18, _guiHeight - 18, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text(_x, _y - 22, _data.name);
    draw_text(_x + 150, _y - 22, string(weapon.ammo) + " / " + string(weapon.reserveAmmo));

    // Draw one small rectangle for each bullet or shell in the magazine.
    var _bulletWidth = 9;
    var _bulletGap = 3;
    var _maxVisible = 20;
    
    var _totalBlocks = _data.magSize;
    var _activeBlocks = weapon.ammo;
    if (_data.bulletNum > 1) {
        _totalBlocks = ceil(_data.magSize / _data.bulletNum);
        _activeBlocks = ceil(weapon.ammo / _data.bulletNum);
    }

    var _visibleCount = min(_totalBlocks, _maxVisible);
    for (var i = 0; i < _visibleCount; i++) {
        var _bx = _x + i * (_bulletWidth + _bulletGap);
        draw_set_color((i < _activeBlocks) ? c_yellow : c_dkgray);
        draw_rectangle(_bx, _y, _bx + _bulletWidth, _y + 22, false);
    }

    // Large magazines still show their exact value in text above.
    if (_totalBlocks > _maxVisible) {
        draw_set_color(c_ltgray);
        draw_text(_x + _visibleCount * (_bulletWidth + _bulletGap) + 5, _y + 3, "x" + string(_totalBlocks));
    }

    if (isReloading) {
        var _progress = 1 - (reloadTimer / max(1, _data.reloadTime));
        //draw_set_color(c_dkgray);
        draw_rectangle(_x, _y + 31, _x + 235, _y + 41, false);
        draw_set_color(c_lime);
        draw_rectangle(_x, _y + 31, _x + 235 * clamp(_progress, 0, 1), _y + 41, false);
        draw_set_color(c_white);
        draw_text(_x, _y + 46, "RELOADING");

		
    }

    draw_set_color(c_white);
    draw_set_alpha(1);
}

function player_draw_noti_reload(){
	
	if(isReloading) draw_text(o_player.x-32, o_player.y-35, "RELOAD!!")
	
	
}