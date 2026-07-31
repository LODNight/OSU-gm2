function player_draw_weapon()
{
    if (weapon == noone) return;

    var _data    = weapon.definition;
    var _xOffset = lengthdir_x(weaponOffsetDist, aimDir);
    var _yOffset = lengthdir_y(weaponOffsetDist, aimDir);
    var _yScale  = (aimDir > 90 && aimDir < 270) ? -1 : 1;
    draw_sprite_ext(_data.sprite, 0, x + _xOffset, centerY + _yOffset,
        1, _yScale, aimDir, c_white, image_alpha);
}

/// @desc Vẽ vũ khí trước hoặc sau nhân vật tùy theo hướng ngắm.
function player_draw()
{
    if (aimDir >= 90 && aimDir < 270) player_draw_weapon();
    draw_self();
    if (aimDir >= 0   && aimDir <= 89)  player_draw_weapon();
    if (aimDir >= 271 && aimDir <= 360) player_draw_weapon();

    player_draw_noti_reload();
}

/// @desc Vẽ HUD thông tin vũ khí: đạn, reload, fire mode, độ bền, kẹt đạn.
function player_draw_weapon_hud()
{
    if (weapon == noone) return;

    var _data      = weapon.definition;
    var _guiWidth  = display_get_gui_width();
    var _guiHeight = display_get_gui_height();
    var _x = _guiWidth  - 270;
    var _y = _guiHeight - 120;

    // Nền panel
    draw_set_alpha(0.78);
    draw_set_color(c_black);
    draw_rectangle(_x - 12, _y - 28, _guiWidth - 18, _guiHeight - 18, false);
    draw_set_alpha(1);

    // Tên vũ khí
    draw_set_color(c_white);
    draw_text(_x, _y - 22, _data.name);

    // Badge fire mode
    var _fmText = string_upper(weapon.current_fire_mode);
    var _fmCol  = (weapon.current_fire_mode == "auto")
        ? make_color_rgb(255, 160, 50)
        : make_color_rgb(120, 210, 255);
    draw_set_color(_fmCol);
    draw_set_halign(fa_right);
    draw_text(_guiWidth - 22, _y - 22, "[" + _fmText + "]");
    draw_set_halign(fa_left);

    // Khối đạn (Ammo blocks)
    var _bulletWidth  = 9;
    var _bulletGap    = 3;
    var _maxVisible   = 20;
    var _totalBlocks  = _data.magSize;
    var _activeBlocks = weapon.current_ammo;
    if (_data.bulletNum > 1) {
        _totalBlocks  = ceil(_data.magSize       / _data.bulletNum);
        _activeBlocks = ceil(weapon.current_ammo / _data.bulletNum);
    }

    var _visibleCount = min(_totalBlocks, _maxVisible);
    for (var i = 0; i < _visibleCount; i++) {
        var _bx = _x + i * (_bulletWidth + _bulletGap);
        draw_set_color((i < _activeBlocks) ? c_yellow : c_dkgray);
        draw_rectangle(_bx, _y, _bx + _bulletWidth, _y + 22, false);
    }
    if (_totalBlocks > _maxVisible) {
        draw_set_color(c_ltgray);
        draw_text(_x + _visibleCount * (_bulletWidth + _bulletGap) + 5, _y + 3, "x" + string(_totalBlocks));
    }

    // Khối băng đạn (Mag blocks)
    var _magWidth = 18;
    for (var m = 0; m < weapon.mags; m++) {
        draw_set_color(c_orange);
        draw_rectangle(_x + m * (_magWidth + 4), _y + 25, _x + m * (_magWidth + 4) + _magWidth, _y + 29, false);
    }

    // Thanh độ bền (Durability bar)
    var _durPct  = weapon_get_durability_pct(weapon);
    var _durCol  = weapon_get_durability_color(weapon);
    var _durBarW = 235;
    var _durY    = _y + 32;
    draw_set_color(make_color_rgb(25, 25, 35));
    draw_rectangle(_x, _durY, _x + _durBarW, _durY + 7, false);
    if (_durPct > 0) {
        draw_set_color(_durCol);
        draw_rectangle(_x, _durY, _x + _durBarW * _durPct, _durY + 7, false);
    }
    draw_set_color(_durCol);
    draw_text(_x + _durBarW + 4, _durY - 1, string(round(_durPct * 100)) + "%");

    // Thanh reload
    if (isReloading) {
        var _progress = 1 - (reloadTimer / max(1, _data.reloadTime));
        var _rlY = _durY + 12;
        draw_set_color(c_dkgray);
        draw_rectangle(_x, _rlY, _x + _durBarW, _rlY + 10, false);
        draw_set_color(c_lime);
        draw_rectangle(_x, _rlY, _x + _durBarW * clamp(_progress, 0, 1), _rlY + 10, false);
        draw_set_color(c_white);
        draw_text(_x, _rlY + 14, "RELOADING");
    }

    // Cảnh báo kẹt đạn (Jam warning)
    if (weapon.is_jammed) {
        draw_set_color(make_color_rgb(255, 60, 60));
        draw_set_halign(fa_center);
        draw_text(_x + _durBarW * 0.5, _y - 10, "!! WEAPON JAMMED !!");
        draw_set_halign(fa_left);
    }

    draw_set_color(c_white);
    draw_set_alpha(1);
}

/// @desc Hiển thị thông báo đang reload phía trên đầu player.
function player_draw_noti_reload()
{
    if (isReloading) draw_text(o_player.x - 32, o_player.y - 35, "RELOAD!!");
}