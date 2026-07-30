// o_inventory_manager — Draw GUI Event
// Vẽ giao diện túi đồ (6x7 Grid, 5 Slot trang bị, 8 Slot Quickbar) + Thông báo Toast

var _camW = display_get_gui_width();
var _camH = display_get_gui_height();

// ── 1. Toast Notifications (pickup feed ở góc trái giữa màn hình) ─────────
if (variable_global_exists("InventoryToasts")) {
    var _toastX = 24;
    var _toastY = _camH / 2;
    var _lineH  = 28;

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    for (var i = 0; i < array_length(global.InventoryToasts); i++) {
        var _toast = global.InventoryToasts[i];
        var _alpha = clamp(_toast.timer / 60, 0, 1);

        // Shadow đen
        draw_set_alpha(_alpha * 0.8);
        draw_set_color(c_black);
        draw_text(_toastX + 2, _toastY + i * _lineH + 2, _toast.text);

        // Chữ chính màu xanh nhạt
        draw_set_alpha(_alpha);
        draw_set_color(make_color_rgb(180, 255, 130));
        draw_text(_toastX, _toastY + i * _lineH, _toast.text);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ── 2. Prompt nhặt đồ / loot xác [F] ────────────────────────────────────
if (instance_exists(o_loot_manager)) {
    var _targetObj = noone;
    var _txt = "";

    if (instance_exists(o_loot_manager.closest_item)) {
        _targetObj = o_loot_manager.closest_item;
        var _def = item_db_get(_targetObj.item_id);
        var _itemName = (_def != undefined) ? _def.name : "Item";
        _txt = "[F]  Pick up " + _itemName;
        if (_targetObj.quantity > 1) _txt += " (x" + string(_targetObj.quantity) + ")";
    } else if (instance_exists(o_loot_manager.closest_corpse)) {
        _targetObj = o_loot_manager.closest_corpse;
        _txt = "[F]  Loot";
    }

    if (_targetObj != noone) {
        var _cam = view_camera[0];
        var _scale_x = _camW / camera_get_view_width(_cam);
        var _scale_y = _camH / camera_get_view_height(_cam);
        var _gx = (_targetObj.x - camera_get_view_x(_cam)) * _scale_x;
        var _gy = (_targetObj.y - camera_get_view_y(_cam)) * _scale_y;

        draw_set_font(-1);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        var _tw = string_width(_txt) + 16;
        var _th = string_height(_txt) + 8;
        var _tx = _gx;
        var _ty = _gy - 52; // Tăng khoảng cách độ cao giữa khung chữ [F] và vật phẩm dưới đất

        draw_set_alpha(0.88);
        draw_set_color(make_color_rgb(16, 18, 28));
        draw_roundrect_ext(_tx - _tw/2, _ty - _th/2, _tx + _tw/2, _ty + _th/2, 6, 6, false);

        draw_set_alpha(1);
        draw_set_color(make_color_rgb(90, 200, 255)); // Viền màu xanh cyan nổi bật
        draw_roundrect_ext(_tx - _tw/2, _ty - _th/2, _tx + _tw/2, _ty + _th/2, 6, 6, true);
        draw_text(_tx, _ty, _txt);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
    }
}

// ── 2.5. HUD Quickbar Slots (3 - 8) ở góc dưới giữa màn hình khi chơi game ──
if (!variable_global_exists("InventoryOpen") || !global.InventoryOpen) {
    var _hudSlotSize = 54;
    var _hudGap      = 10;
    var _hudTotalW   = 6 * _hudSlotSize + 5 * _hudGap;
    var _hudX        = (_camW - _hudTotalW) / 2;
    var _hudY        = _camH - 68;

    // Nền mờ phía sau thanh Quickbar HUD
    draw_set_alpha(0.75);
    draw_set_color(make_color_rgb(12, 14, 22));
    draw_roundrect_ext(_hudX - 10, _hudY - 8, _hudX + _hudTotalW + 10, _hudY + _hudSlotSize + 8, 8, 8, false);

    draw_set_alpha(0.85);
    draw_set_color(make_color_rgb(45, 50, 75));
    draw_roundrect_ext(_hudX - 10, _hudY - 8, _hudX + _hudTotalW + 10, _hudY + _hudSlotSize + 8, 8, 8, true);
    draw_set_alpha(1);

    for (var k = 0; k < 6; k++) {
        var _q    = k + 2; // Quickbar index 2..7 (phím 3..8)
        var _key  = k + 3; // Phím 3..8
        var _sx   = _hudX + k * (_hudSlotSize + _hudGap);
        var _sy   = _hudY;

        var _isKeyDown = keyboard_check(ord(string(_key)));
        var _slotData  = global.Quickbar[_q];

        // Nền ô
        if (_isKeyDown) {
            draw_set_color(make_color_rgb(70, 75, 120));
            draw_set_alpha(0.9);
        } else if (_slotData != undefined) {
            draw_set_color(make_color_rgb(24, 27, 42));
            draw_set_alpha(0.85);
        } else {
            draw_set_color(make_color_rgb(18, 20, 30));
            draw_set_alpha(0.7);
        }
        draw_roundrect_ext(_sx, _sy, _sx + _hudSlotSize, _sy + _hudSlotSize, 6, 6, false);

        // Viền ô
        draw_set_alpha(1);
        if (_isKeyDown) {
            draw_set_color(make_color_rgb(255, 215, 80));
        } else if (_slotData != undefined) {
            draw_set_color(make_color_rgb(85, 90, 135));
        } else {
            draw_set_color(make_color_rgb(45, 48, 70));
        }
        draw_roundrect_ext(_sx, _sy, _sx + _hudSlotSize, _sy + _hudSlotSize, 6, 6, true);

        // Nhãn phím tắt (3..8) màu vàng ở góc trên trái ô
        draw_set_font(-1);
        draw_set_color(make_color_rgb(255, 205, 80));
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(_sx + 5, _sy + 3, string(_key));

        // Vẽ icon vật phẩm & số lượng
        if (_slotData != undefined) {
            var _def = item_db_get(_slotData.item_id);
            if (_def != undefined) {
                if (_def.icon_sprite != noone) {
                    draw_item_icon_fitted(_def, _sx + 4, _sy + 4, _hudSlotSize - 8, _hudSlotSize - 8, false);
                } else {
                    draw_set_color(make_color_rgb(160, 165, 210));
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text(_sx + _hudSlotSize / 2, _sy + _hudSlotSize / 2, string_upper(string_copy(_slotData.item_id, 1, 3)));
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }

                // Hiển thị số lượng nhỏ ở góc dưới bên phải
                if (_slotData.quantity > 1 || _def.stackable) {
                    draw_set_font(-1);
                    // Shadow đen
                    draw_set_color(c_black);
                    draw_set_halign(fa_right);
                    draw_set_valign(fa_bottom);
                    draw_text(_sx + _hudSlotSize - 3, _sy + _hudSlotSize - 2, string(_slotData.quantity));

                    // Chữ trắng
                    draw_set_color(c_white);
                    draw_text(_sx + _hudSlotSize - 4, _sy + _hudSlotSize - 3, string(_slotData.quantity));

                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }
            }
        }
    }
}

// ── 3. Vẽ Giao diện túi đồ chính (Main Inventory Window) ──────────────────
if (!variable_global_exists("InventoryOpen") || !global.InventoryOpen) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// Khung cửa sổ chính (Giao diện lớn tràn gần hết màn hình)
var _windowW = 1160;
var _windowH = 640;
var _winX    = (_camW - _windowW) / 2;
var _winY    = (_camH - _windowH) / 2;

// Nền Glassmorphism sẫm màu
draw_set_alpha(0.92);
draw_set_color(make_color_rgb(16, 18, 26));
draw_roundrect_ext(_winX, _winY, _winX + _windowW, _winY + _windowH, 12, 12, false);
draw_set_alpha(1);

// Viền cửa sổ
draw_set_color(make_color_rgb(70, 75, 110));
draw_roundrect_ext(_winX, _winY, _winX + _windowW, _winY + _windowH, 12, 12, true);

// Header / Tiêu đề cửa sổ
draw_set_color(make_color_rgb(220, 225, 255));
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(_winX + 32, _winY + 24, "INVENTORY");

// Hiển thị số tiền (Currency) ở góc trên phải
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(255, 215, 60));
draw_text(_winX + _windowW - 32, _winY + 24, "$" + string(currency_get()));
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _tooltip = "";

// ── Area 1: Kho đồ chính (Main Grid 6x7 = 42 ô) ─────────────────────────
var _gridX    = _winX + 32;
var _gridY    = _winY + 48;
var _cellSize = 72;
var _gap      = 8;

// Tiêu đề sub-panel Grid
draw_set_color(make_color_rgb(140, 145, 180));
draw_text(_gridX, _gridY - 18, "STORAGE (6x7)");

for (var i = 0; i < INVENTORY_GRID_SLOTS; i++) {
    var _col = i mod INVENTORY_GRID_COLS;
    var _row = i div INVENTORY_GRID_COLS;
    var _cx  = _gridX + _col * (_cellSize + _gap);
    var _cy  = _gridY + _row * (_cellSize + _gap);

    var _slotData = global.InventoryGrid[i];

    // Trường hợp 1: Ô trống (Undefined)
    if (_slotData == undefined) {
        var _isHover = (inv_hover_type == "grid" && inv_hover_idx == i);
        // Nền ô trống
        draw_set_color(_isHover ? make_color_rgb(55, 60, 95) : make_color_rgb(28, 30, 44));
        draw_roundrect_ext(_cx, _cy, _cx + _cellSize, _cy + _cellSize, 5, 5, false);
        // Viền ô trống
        draw_set_color(_isHover ? make_color_rgb(130, 135, 210) : make_color_rgb(48, 52, 75));
        draw_roundrect_ext(_cx, _cy, _cx + _cellSize, _cy + _cellSize, 5, 5, true);
        continue;
    }

    // Trường hợp 2: Ô phụ thuộc của item đa ô (Secondary Cell) -> Bỏ qua không vẽ nền đè lên
    if (variable_struct_exists(_slotData, "root_idx")) {
        continue;
    }

    // Trường hợp 3: Ô gốc của vật phẩm (Root Cell) -> Gom các ô lại vẽ thành 1 ô lớn chung duy nhất!
    if (variable_struct_exists(_slotData, "item_id")) {
        var _def = item_db_get(_slotData.item_id);
        if (_def != undefined) {
            var _w = _def.grid_w;
            var _h = _def.grid_h;
            var _totalW = _w * _cellSize + (_w - 1) * _gap;
            var _totalH = _h * _cellSize + (_h - 1) * _gap;

            var _rootHover = (inv_hover_type == "grid") ? inventory_get_root_idx(inv_hover_idx) : -1;
            var _isHover   = (_rootHover != -1 && _rootHover == i);

            // Nền 1 ô gộp lớn (Merged background card)
            draw_set_color(_isHover ? make_color_rgb(55, 60, 95) : make_color_rgb(28, 32, 48));
            draw_roundrect_ext(_cx, _cy, _cx + _totalW, _cy + _totalH, 6, 6, false);

            // Viền 1 ô gộp lớn (Merged border)
            draw_set_color(_isHover ? make_color_rgb(140, 145, 220) : make_color_rgb(52, 58, 85));
            draw_roundrect_ext(_cx, _cy, _cx + _totalW, _cy + _totalH, 6, 6, true);

            // Shift index khi đang kéo (Drag Preview)
            if (!drag_active || drag_source_type != "grid" || inventory_get_root_idx(drag_source_idx) != i) {
                // Vẽ sprite vật phẩm giữ tỉ lệ sắc nét
                if (_def.icon_sprite != noone) {
                    draw_item_icon_fitted(_def, _cx + 4, _cy + 4, _totalW - 8, _totalH - 8, false);
                } else {
                    draw_set_color(make_color_rgb(160, 165, 210));
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text(_cx + _totalW / 2, _cy + _totalH / 2, string_upper(string_copy(_slotData.item_id, 1, 3)));
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }

                // Hiển thị kích thước ô (vd: 3x2, 2x1) chìm ở góc trên trái
                draw_set_color(make_color_rgb(110, 115, 150));
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                draw_text(_cx + 6, _cy + 4, _def.size);

                // Số lượng nếu stack được
                if (_def.stackable && _slotData.quantity > 1) {
                    draw_set_color(c_white);
                    draw_set_halign(fa_right);
                    draw_set_valign(fa_bottom);
                    draw_text(_cx + _totalW - 4, _cy + _totalH - 3, string(_slotData.quantity));
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }

                if (_isHover) {
                    _tooltip = _def.name + " (" + _def.size + ")" + "\n" + _def.description;
                    if (_def.value > 0) _tooltip += "\nValue: $" + string(_def.value);
                    if (_def.defense > 0) _tooltip += "\nDefense: +" + string(_def.defense);
                    if (_def.heal_amount > 0) _tooltip += "\nHeal: +" + string(_def.heal_amount);
                }
            }
        }
    }
}

// ── Hiệu ứng Highlight khu vực ô khi đang Kéo-Thả (Grid Placement Preview) ────
if (drag_active && drag_data != undefined && inv_hover_type == "grid") {
    var _dragDef = item_db_get(drag_data.item_id);
    if (_dragDef != undefined) {
        var _mCol = inv_hover_idx mod INVENTORY_GRID_COLS;
        var _mRow = inv_hover_idx div INVENTORY_GRID_COLS;

        var _pos       = inventory_get_centered_grid_pos(drag_data.item_id, _mCol, _mRow);
        var _targetCol = _pos.col;
        var _targetRow = _pos.row;

        var _w = _dragDef.grid_w;
        var _h = _dragDef.grid_h;

        var _ignoreRoot = (drag_source_type == "grid") ? inventory_get_root_idx(drag_source_idx) : -1;
        var _canFit     = inventory_can_place_grid(drag_data.item_id, _targetCol, _targetRow, _ignoreRoot);

        var _hlX = _gridX + _targetCol * (_cellSize + _gap);
        var _hlY = _gridY + _targetRow * (_cellSize + _gap);

        var _hlW = _w * _cellSize + (_w - 1) * _gap;
        var _hlH = _h * _cellSize + (_h - 1) * _gap;

        // Màu Xanh Lá (Đặt vừa ô) hoặc Màu Đỏ (Không đủ ô / Vướng ô khác)
        var _bgColor     = _canFit ? make_color_rgb(35, 130, 60)  : make_color_rgb(150, 35, 35);
        var _borderColor = _canFit ? make_color_rgb(90, 240, 130) : make_color_rgb(255, 80, 80);

        draw_set_alpha(0.45);
        draw_set_color(_bgColor);
        draw_roundrect_ext(_hlX, _hlY, _hlX + _hlW, _hlY + _hlH, 6, 6, false);

        draw_set_alpha(0.9);
        draw_set_color(_borderColor);
        draw_roundrect_ext(_hlX, _hlY, _hlX + _hlW, _hlY + _hlH, 6, 6, true);
        draw_set_alpha(1);
    }
}

// ── Vạch ngăn cách dọc giữa Grid & Trang bị ─────────────────────────────
var _splitX = _gridX + 472 + 24;
draw_set_color(make_color_rgb(45, 48, 70));
draw_line_width(_splitX, _winY + 36, _splitX, _winY + _windowH - 36, 2);

// ── Area 1-6: Khu vực Trang bị (Right Equipment Panel) ────────────────────
var _equipPanelX = _splitX + 24;
var _equipPanelY = _winY + 48;

draw_set_color(make_color_rgb(140, 145, 180));
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_equipPanelX, _equipPanelY - 22, "EQUIPMENT");

var _eq_weapon1    = { x: _equipPanelX,       y: _equipPanelY,       w: 540, h: 100, slot: "weapon1",    label: "PRIMARY WEAPON (1)",    num: "1" };
var _eq_weapon2    = { x: _equipPanelX,       y: _equipPanelY + 112, w: 540, h: 100, slot: "weapon2",    label: "SECONDARY WEAPON (2)",  num: "2" };

var _eq_helmet     = { x: _equipPanelX,       y: _equipPanelY + 224, w: 123, h: 180, slot: "helmet",     label: "HELMET (3)",            num: "3" };
var _eq_armor      = { x: _equipPanelX + 139, y: _equipPanelY + 224, w: 123, h: 180, slot: "armor",      label: "ARMOR (4)",             num: "4" };
var _eq_backpack   = { x: _equipPanelX + 278, y: _equipPanelY + 224, w: 123, h: 180, slot: "backpack",   label: "BACKPACK (5)",          num: "5" };
var _eq_flashlight = { x: _equipPanelX + 417, y: _equipPanelY + 224, w: 123, h: 180, slot: "flashlight", label: "FLASHLIGHT (6)",        num: "6" };

var _equipSlots = [_eq_weapon1, _eq_weapon2, _eq_helmet, _eq_armor, _eq_backpack, _eq_flashlight];

for (var e = 0; e < array_length(_equipSlots); e++) {
    var _eq      = _equipSlots[e];
    var _isHover = (inv_hover_type == "equip" && inv_hover_idx == _eq.slot);
    var _data    = global.Equipment[$ _eq.slot];

    // Card background
    draw_set_color(_isHover ? make_color_rgb(55, 60, 95) : make_color_rgb(26, 28, 42));
    draw_roundrect_ext(_eq.x, _eq.y, _eq.x + _eq.w, _eq.y + _eq.h, 8, 8, false);

    // Card border
    draw_set_color(_isHover ? make_color_rgb(140, 145, 220) : make_color_rgb(50, 54, 80));
    draw_roundrect_ext(_eq.x, _eq.y, _eq.x + _eq.w, _eq.y + _eq.h, 8, 8, true);

    // Nhãn tên slot
    draw_set_color(make_color_rgb(110, 115, 150));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(_eq.x + 8, _eq.y + 6, _eq.label);

    if (_data != undefined && (!drag_active || drag_source_type != "equip" || drag_source_idx != _eq.slot)) {
        var _def = item_db_get(_data.item_id);
        if (_def != undefined) {
            // Icon sprite (Tự động lật ngang đối với slot vũ khí)
            if (_def.icon_sprite != noone) {
                var _isWepSlot = (_eq.slot == "weapon1" || _eq.slot == "weapon2");
                if (_isWepSlot) {
                    draw_item_icon_fitted(_def, _eq.x + 8, _eq.y + 20, _eq.w - 16, _eq.h - 26, true);
                } else {
                    draw_item_icon_fitted(_def, _eq.x + 6, _eq.y + 26, _eq.w - 12, _eq.h - 34, false);
                }
            } else {
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(_eq.x + _eq.w / 2, _eq.y + _eq.h / 2 + 6, _def.name);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }

            if (_isHover) {
                _tooltip = _def.name + "\n" + _def.description;
                if (_def.defense > 0) _tooltip += "\nDefense: +" + string(_def.defense);
            }
        }
    } else {
        // Chữ chìm hướng dẫn khi ô trống
        draw_set_color(make_color_rgb(60, 64, 90));
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_eq.x + _eq.w / 2, _eq.y + _eq.h / 2 + 4, "[ Empty Slot ]");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

// ── Area 7: Khu vực item từ 3 tới 8 (Quickbar Slots 3 - 8) ────────────
var _qCellSize = 72;
var _qGap      = 21.6;
var _qY        = _equipPanelY + 448;

draw_set_color(make_color_rgb(140, 145, 180));
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_equipPanelX, _qY - 24, "QUICK SLOTS (3 - 8)");

for (var k = 0; k < 6; k++) {
    var _q       = k + 2; // Quickbar slot index 2..7 (phím 3..8)
    var _qx      = _equipPanelX + k * (_qCellSize + _qGap);
    var _isHover = (inv_hover_type == "quickbar" && inv_hover_idx == _q);

    // Nền ô
    draw_set_color(_isHover ? make_color_rgb(55, 60, 95) : make_color_rgb(28, 30, 44));
    draw_roundrect_ext(_qx, _qY, _qx + _qCellSize, _qY + _qCellSize, 5, 5, false);

    // Viền ô
    draw_set_color(_isHover ? make_color_rgb(140, 145, 220) : make_color_rgb(50, 54, 80));
    draw_roundrect_ext(_qx, _qY, _qx + _qCellSize, _qY + _qCellSize, 5, 5, true);

    // Số phím tắt (3..8) ở góc trên trái ô
    draw_set_color(make_color_rgb(255, 200, 80));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(_qx + 6, _qY + 4, string(_q + 1));

    var _slotData = global.Quickbar[_q];
    if (_slotData != undefined && (!drag_active || drag_source_type != "quickbar" || drag_source_idx != _q)) {
        var _def = item_db_get(_slotData.item_id);
        if (_def != undefined) {
            if (_def.icon_sprite != noone) {
                draw_item_icon_fitted(_def, _qx + 4, _qY + 4, _qCellSize - 8, _qCellSize - 8, false);
            } else {
                draw_set_color(make_color_rgb(160, 165, 210));
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(_qx + _qCellSize / 2, _qY + _qCellSize / 2, string_upper(string_copy(_slotData.item_id, 1, 3)));
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }

            if (_def.stackable && _slotData.quantity > 1) {
                draw_set_color(c_white);
                draw_set_halign(fa_right);
                draw_set_valign(fa_bottom);
                draw_text(_qx + _qCellSize - 4, _qY + _qCellSize - 4, string(_slotData.quantity));
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }

            if (_isHover) {
                _tooltip = _def.name + "\n" + _def.description;
            }
        }
    }
}

// ── 4. Vẽ icon vật phẩm đang Kéo (Drag Preview theo tỉ lệ kích thước ô) ─────
if (drag_active && drag_data != undefined) {
    var _def = item_db_get(drag_data.item_id);
    if (_def != undefined) {
        var _w = _def.grid_w;
        var _h = _def.grid_h;
        var _previewW = _w * _cellSize + (_w - 1) * _gap;
        var _previewH = _h * _cellSize + (_h - 1) * _gap;

        var _px = _mx - _previewW / 2;
        var _py = _my - _previewH / 2;

        // Khung thẻ mờ đại diện cho kích thước thực tế của item
        draw_set_alpha(0.85);
        draw_set_color(make_color_rgb(32, 36, 56));
        draw_roundrect_ext(_px, _py, _px + _previewW, _py + _previewH, 6, 6, false);

        draw_set_color(make_color_rgb(140, 145, 230));
        draw_roundrect_ext(_px, _py, _px + _previewW, _py + _previewH, 6, 6, true);

        if (_def.icon_sprite != noone) {
            draw_item_icon_fitted(_def, _px + 4, _py + 4, _previewW - 8, _previewH - 8, false);
        } else {
            draw_set_color(c_yellow);
            draw_circle(_mx, _my, 18, false);
        }

        // Nhãn kích thước ô (vd: 3x2, 2x1) chìm ở góc trên trái ô kéo
        draw_set_color(make_color_rgb(170, 175, 220));
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(_px + 6, _py + 4, _def.size);

        draw_set_alpha(1);
    }
}

// ── 5. Tooltip thông tin vật phẩm khi Rê chuột (Hover) ──────────────────
if (_tooltip != "" && !drag_active && !context_active) {
    var _maxTextW = 210;
    var _lineSep  = 18;
    var _padX     = 10;
    var _padY     = 10;

    var _textW = string_width_ext(_tooltip, _lineSep, _maxTextW);
    var _textH = string_height_ext(_tooltip, _lineSep, _maxTextW);

    var _tw = max(180, _textW + _padX * 2);
    var _th = _textH + _padY * 2;

    var _ttx = clamp(_mx + 16, 4, _camW - _tw - 4);
    var _tty = clamp(_my - _th - 8, 4, _camH - _th - 4);

    draw_set_alpha(0.95);
    draw_set_color(make_color_rgb(14, 16, 26));
    draw_roundrect_ext(_ttx, _tty, _ttx + _tw, _tty + _th, 6, 6, false);

    draw_set_alpha(1);
    draw_set_color(make_color_rgb(95, 100, 150));
    draw_roundrect_ext(_ttx, _tty, _ttx + _tw, _tty + _th, 6, 6, true);

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_ext(_ttx + _padX, _tty + _padY, _tooltip, _lineSep, _maxTextW);
}

// ── 6. Context Menu khi Click Chuột Phải ──────────────────────────────
if (context_active) {
    var _ctxW = 140;
    var _optH = 34;
    var _slotData = inventory_get_slot_data(context_slot_type, context_slot_idx);
    var _opts = [];

    if (_slotData != undefined) {
        var _def = item_db_get(_slotData.item_id);
        if (_def != undefined) {
            if (context_slot_type == "equip") {
                _opts = ["Unequip", "Drop 1", "Drop All"];
            } else {
                if (_def.item_type == ITEM_TYPE.HELMET || _def.item_type == ITEM_TYPE.ARMOR ||
                    _def.item_type == ITEM_TYPE.FLASHLIGHT || _def.item_type == ITEM_TYPE.WEAPON) {
                    _opts = ["Equip", "Drop 1", "Drop All"];
                } else if (_def.item_type == ITEM_TYPE.CONSUMABLE) {
                    _opts = ["Use", "Drop 1", "Drop All"];
                } else {
                    _opts = ["Drop 1", "Drop All"];
                }
            }
        }
    }

    var _ctxH = array_length(_opts) * _optH;

    // Nền context menu
    draw_set_alpha(0.96);
    draw_set_color(make_color_rgb(20, 22, 34));
    draw_roundrect_ext(context_x, context_y, context_x + _ctxW, context_y + _ctxH, 6, 6, false);

    // Viền
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(90, 95, 140));
    draw_roundrect_ext(context_x, context_y, context_x + _ctxW, context_y + _ctxH, 6, 6, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var j = 0; j < array_length(_opts); j++) {
        var _oy = context_y + j * _optH;
        var _hoverOpt = (_mx >= context_x && _mx <= context_x + _ctxW &&
                         _my >= _oy && _my <= _oy + _optH);

        if (_hoverOpt) {
            draw_set_color(make_color_rgb(60, 65, 105));
            draw_roundrect_ext(context_x + 2, _oy + 2, context_x + _ctxW - 2, _oy + _optH - 2, 4, 4, false);
            draw_set_color(c_white);
        } else {
            draw_set_color(make_color_rgb(200, 205, 225));
        }

        draw_text(context_x + _ctxW / 2, _oy + _optH / 2, _opts[j]);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// ── 7. Chú thích đóng UI ────────────────────────────────────────────────
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(120, 125, 160));
draw_text(_winX + _windowW - 24, _winY + _windowH - 20, "[TAB] Close");
draw_set_halign(fa_left);
draw_set_color(c_white);
