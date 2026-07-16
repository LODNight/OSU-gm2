// ================================================================
// o_spawner — Draw GUI Event (Debug Overlay)
// ================================================================
if (!SPAWNER_DEBUG) exit;

// ── Chuyển tọa độ world → screen ──
var _vx  = camera_get_view_x(view_camera[0]);
var _vy  = camera_get_view_y(view_camera[0]);
var _vw  = camera_get_view_width(view_camera[0]);
var _vh  = camera_get_view_height(view_camera[0]);
var _gw  = display_get_gui_width();
var _gh  = display_get_gui_height();

var _sx  = (x - _vx) / _vw * _gw;
var _sy  = (y - _vy) / _vh * _gh;

// Chỉ vẽ khi nằm gần khung hình camera
if (_sx >= -100 && _sx <= _gw + 100 && _sy >= -100 && _sy <= _gh + 100)
{
    // ── Kích thước hình vuông debug nhỏ ──
    var _hw = 16; 

    // ── Màu nền hình vuông tùy thuộc vào state của spawner ──
    var _fill_col = c_gray;
    switch (spawnerState) {
        case SPAWNER_STATE.IDLE:     _fill_col = c_yellow; break;
        case SPAWNER_STATE.ACTIVE:   _fill_col = make_color_rgb(50, 220, 80); break; // Xanh lá
        case SPAWNER_STATE.DEPLETED: _fill_col = make_color_rgb(220, 60, 60); break; // Đỏ
    }

    // ── Vẽ hình vuông nền và viền ──
    draw_set_alpha(0.7);
    draw_set_color(_fill_col);
    draw_rectangle(_sx - _hw, _sy - _hw, _sx + _hw, _sy + _hw, false);

    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_rectangle(_sx - _hw, _sy - _hw, _sx + _hw, _sy + _hw, true);

    // Chữ 'S' trung tâm đại diện cho Spawner
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_sx, _sy, "S");

    // ── Hiển thị tham số debug bên dưới hình vuông ──
    var _state_names = ["IDLE", "ACTIVE", "DEPLETED"];
    var _live  = ds_list_size(liveEnemies);
    var _txt
        = "[" + string(zoneId) + "]\n"
        + "St: " + _state_names[spawnerState] + "\n"
        + "Lv: " + string(_live) + "/" + string(config.maxEnemies) + "\n"
        + "Tt: " + string(totalSpawned) + "/" + string(config.totalLimit) + "\n"
        + "T: " + string(spawnTimer) + "/" + string(config.spawnDelay);

    draw_set_valign(fa_top);
    
    // Đổ bóng chữ đen
    draw_set_color(c_black);
    draw_text(_sx + 1, _sy + _hw + 4, _txt);
    
    // Chữ trắng chính
    draw_set_color(c_white);
    draw_text(_sx, _sy + _hw + 3, _txt);

    // Reset draw settings về mặc định
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
