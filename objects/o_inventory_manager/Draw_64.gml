// o_inventory_manager — Draw GUI Event
// Vẽ Inventory Grid UI (khi mở) + Toast Notifications

var _camW = display_get_gui_width();
var _camH = display_get_gui_height();

// ── Toast Notifications (pickup feed) ────────────────────────────────────
// Vị trí: Phía giữa bên trái màn hình
if (variable_global_exists("InventoryToasts")) {
    var _toastX = 24;
    var _toastY = _camH / 2;
    var _lineH  = 28; // Tăng khoảng cách dòng để dễ nhìn hơn

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    for (var i = 0; i < array_length(global.InventoryToasts); i++) {
        var _toast = global.InventoryToasts[i];
        var _alpha = clamp(_toast.timer / 60, 0, 1); // Fade out

        // Shadow đậm hơn để dễ nhìn
        draw_set_alpha(_alpha * 0.8);
        draw_set_color(c_black);
        draw_text(_toastX + 2, _toastY + i * _lineH + 2, _toast.text);

        // Text
        draw_set_alpha(_alpha);
        draw_set_color(make_color_rgb(180, 255, 130)); // Xanh lá nhạt
        draw_text(_toastX, _toastY + i * _lineH, _toast.text);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ── Corpse Loot Prompt [F] — GUI Layer ───────────────────────────────────
// Vẽ prompt "Press [F] to Loot" tại vị trí xác trên màn hình.
// Dùng GUI layer để KHÔNG bị ảnh hưởng bởi lighting/màu nền.
if (instance_exists(o_loot_manager) && instance_exists(o_loot_manager.closest_corpse)) {
    var _corpse = o_loot_manager.closest_corpse;
    var _cam    = view_camera[0];

    // Chuyển tọa độ World → GUI
    var _scale_x = _camW / camera_get_view_width(_cam);
    var _scale_y = _camH / camera_get_view_height(_cam);
    var _gx = (_corpse.x - camera_get_view_x(_cam)) * _scale_x;
    var _gy = (_corpse.y - camera_get_view_y(_cam)) * _scale_y;

    // Vẽ badge [F] Loot
    var _txt = "[F]  Loot";
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var _tw = string_width(_txt) + 14;
    var _th = string_height(_txt) + 8;
    var _tx = _gx;
    var _ty = _gy - 30; // Nằm ngay phía trên xác

    // Nền đen đặc — không bao giờ bị lighting làm mờ
    draw_set_alpha(0.88);
    draw_set_color(c_black);
    draw_roundrect_ext(_tx - _tw/2, _ty - _th/2,
                       _tx + _tw/2, _ty + _th/2, 5, 5, false);

    // Viền trắng sắc nét
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_roundrect_ext(_tx - _tw/2, _ty - _th/2,
                       _tx + _tw/2, _ty + _th/2, 5, 5, true);

    // Text trắng sáng
    draw_set_color(c_white);
    draw_text(_tx, _ty, _txt);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

// ── Inventory Grid UI ─────────────────────────────────────────────────────
if (!variable_global_exists("InventoryOpen") || !global.InventoryOpen) exit;

// Kích thước panel
var _cols     = 6;
var _rows     = 5;
var _cellSize = 64;
var _gap      = 4;
var _pad      = 16;
var _panelW   = _cols * (_cellSize + _gap) + _pad * 2;
var _panelH   = _rows * (_cellSize + _gap) + _pad * 2 + 40; // +40 cho tiêu đề
var _panelX   = (_camW - _panelW) / 2;
var _panelY   = (_camH - _panelH) / 2;

// Nền panel (glassmorphism style)
draw_set_alpha(0.88);
draw_set_color(make_color_rgb(18, 18, 28));
draw_roundrect_ext(_panelX, _panelY, _panelX + _panelW, _panelY + _panelH, 10, 10, false);
draw_set_alpha(1);

// Viền panel
draw_set_color(make_color_rgb(80, 80, 120));
draw_roundrect_ext(_panelX, _panelY, _panelX + _panelW, _panelY + _panelH, 10, 10, true);

// Tiêu đề
draw_set_color(make_color_rgb(210, 210, 255));
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(_panelX + _panelW / 2, _panelY + 10, "INVENTORY");
draw_set_halign(fa_left);

// Tiền tệ (góc trên phải panel)
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(255, 220, 60));
draw_text(_panelX + _panelW - _pad, _panelY + 10,
    "$" + string(currency_get()));
draw_set_halign(fa_left);

// Lấy danh sách slot
var _slots    = inventory_get_all();
var _slotNum  = array_length(_slots);
var _mx       = device_mouse_x_to_gui(0);
var _my       = device_mouse_y_to_gui(0);
var _hovSlot  = -1;
var _tooltip  = "";

// Vẽ từng ô grid
for (var i = 0; i < _cols * _rows; i++) {
    var _col = i mod _cols;
    var _row = i div _cols;
    var _cx  = _panelX + _pad + _col * (_cellSize + _gap);
    var _cy  = _panelY + _pad + 40 + _row * (_cellSize + _gap);

    // Kiểm tra hover
    var _hovered = (_mx >= _cx && _mx <= _cx + _cellSize
                 && _my >= _cy && _my <= _cy + _cellSize);
    if (_hovered) {
        _hovSlot = i;
    }

    // Nền ô
    if (_hovered) {
        draw_set_color(make_color_rgb(60, 60, 100));
    } else {
        draw_set_color(make_color_rgb(35, 35, 55));
    }
    draw_roundrect_ext(_cx, _cy, _cx + _cellSize, _cy + _cellSize, 4, 4, false);

    // Viền ô
    draw_set_color(_hovered
        ? make_color_rgb(120, 120, 200)
        : make_color_rgb(55, 55, 80));
    draw_roundrect_ext(_cx, _cy, _cx + _cellSize, _cy + _cellSize, 4, 4, true);

    // Nếu slot có item
    if (i < _slotNum) {
        var _slot = _slots[i];
        var _def  = item_db_get(_slot.item_id);

        if (_def != undefined) {
            // Icon sprite (nếu có)
            if (_def.icon_sprite != noone) {
                draw_sprite_stretched(_def.icon_sprite, 0,
                    _cx + 8, _cy + 8, _cellSize - 16, _cellSize - 16);
            } else {
                // Fallback: chữ tắt item type
                draw_set_color(make_color_rgb(150, 150, 200));
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(_cx + _cellSize / 2, _cy + _cellSize / 2,
                    string_upper(string_copy(_slot.item_id, 1, 3)));
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }

            // Số lượng (góc dưới phải)
            if (_def.stackable && _slot.quantity > 1) {
                draw_set_color(c_white);
                draw_set_halign(fa_right);
                draw_set_valign(fa_bottom);
                draw_text(_cx + _cellSize - 4, _cy + _cellSize - 4,
                    string(_slot.quantity));
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }

            // Chuẩn bị tooltip nếu hover
            if (_hovered) {
                _tooltip = _def.name + "\n" + _def.description;
                if (_def.value > 0) _tooltip += "\nGiá: $" + string(_def.value);
            }
        }
    }
}

// Tooltip
if (_tooltip != "" && _hovSlot >= 0) {
    var _tw  = 180;
    var _th  = 56;
    var _ttx = clamp(_mx + 14, 4, _camW - _tw - 4);
    var _tty = clamp(_my - _th - 8, 4, _camH - _th - 4);

    draw_set_alpha(0.9);
    draw_set_color(make_color_rgb(12, 12, 20));
    draw_roundrect_ext(_ttx, _tty, _ttx + _tw, _tty + _th, 6, 6, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(100, 100, 160));
    draw_roundrect_ext(_ttx, _tty, _ttx + _tw, _tty + _th, 6, 6, true);

    draw_set_color(c_white);
    draw_text_ext(_ttx + 8, _tty + 8, _tooltip, 16, _tw - 12);
}

// Hướng dẫn đóng
draw_set_halign(fa_center);
draw_set_color(make_color_rgb(100, 100, 140));
draw_text(_panelX + _panelW / 2, _panelY + _panelH - 20,
    "[TAB] Đóng");
draw_set_halign(fa_left);
draw_set_color(c_white);
