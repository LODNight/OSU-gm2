// o_inventory_manager — Step Event
// Xử lý Toggle UI, Cập nhật Toast, Phím tắt Quickbar 1-8, Kéo-Thả & Context Menu

// Toggle mở/đóng inventory bằng phím Tab
if (keyboard_check_pressed(inv_key)) {
    global.InventoryOpen = !global.InventoryOpen;
    if (!global.InventoryOpen) {
        context_active = false;
        drag_active    = false;
    }
}

// Tick timer hiển thị thông báo toast
inventory_toast_update();

// Phím tắt Quickbar 1 - 8 khi chơi game
for (var k = 0; k < 8; k++) {
    if (keyboard_check_pressed(ord(string(k + 1)))) {
        inventory_use_slot("quickbar", k);
    }
}

if (variable_global_exists("InventoryOpen") && global.InventoryOpen) {
    var _camW = display_get_gui_width();
    var _camH = display_get_gui_height();
    var _mx   = device_mouse_x_to_gui(0);
    var _my   = device_mouse_y_to_gui(0);

    // Kích thước khung giao diện tổng
    var _windowW = 880;
    var _windowH = 580;
    var _winX    = (_camW - _windowW) / 2;
    var _winY    = (_camH - _windowH) / 2;

    inv_hover_type = "";
    inv_hover_idx  = -1;

    // 1. Kiểm tra hover ô Grid (Area 1: 6x7 = 42 ô)
    var _gridX    = _winX + 24;
    var _gridY    = _winY + 48;
    var _cellSize = 54;
    var _gap      = 6;

    for (var i = 0; i < INVENTORY_GRID_SLOTS; i++) {
        var _col = i mod INVENTORY_GRID_COLS;
        var _row = i div INVENTORY_GRID_COLS;
        var _cx  = _gridX + _col * (_cellSize + _gap);
        var _cy  = _gridY + _row * (_cellSize + _gap);

        if (_mx >= _cx && _mx <= _cx + _cellSize &&
            _my >= _cy && _my <= _cy + _cellSize) {
            inv_hover_type = "grid";
            inv_hover_idx  = i;
            break;
        }
    }

    // 2. Kiểm tra hover ô Trang bị (Area 2-6)
    if (inv_hover_type == "") {
        var _splitX      = _gridX + 354 + 20;
        var _equipPanelX = _splitX + 16;
        var _equipPanelY = _winY + 48;

        // Vị trí các slot trang bị mới (Ô 5 & 6 là hình chữ nhật nằm ngang dài, Ô 2, 3, 4 ở dưới)
        var _eq_weapon1    = { x: _equipPanelX + 10,  y: _equipPanelY + 10,  w: 385, h: 88,  slot: "weapon1" };
        var _eq_weapon2    = { x: _equipPanelX + 10,  y: _equipPanelY + 104, w: 385, h: 88,  slot: "weapon2" };
        var _eq_helmet     = { x: _equipPanelX + 10,  y: _equipPanelY + 204, w: 123, h: 190, slot: "helmet" };
        var _eq_armor      = { x: _equipPanelX + 141, y: _equipPanelY + 204, w: 123, h: 190, slot: "armor" };
        var _eq_flashlight = { x: _equipPanelX + 272, y: _equipPanelY + 204, w: 123, h: 190, slot: "flashlight" };

        var _equipSlots = [_eq_weapon1, _eq_weapon2, _eq_helmet, _eq_armor, _eq_flashlight];
        for (var e = 0; e < array_length(_equipSlots); e++) {
            var _eq = _equipSlots[e];
            if (_mx >= _eq.x && _mx <= _eq.x + _eq.w &&
                _my >= _eq.y && _my <= _eq.y + _eq.h) {
                inv_hover_type = "equip";
                inv_hover_idx  = _eq.slot;
                break;
            }
        }
    }

    // 3. Kiểm tra hover ô Quickbar (Area 0: 8 ô)
    if (inv_hover_type == "") {
        var _qCellSize = 54;
        var _qGap      = 8;
        var _qW        = INVENTORY_QUICKBAR_SLOTS * _qCellSize + (INVENTORY_QUICKBAR_SLOTS - 1) * _qGap;
        var _qX        = _winX + (_windowW - _qW) / 2;
        var _qY        = _winY + _windowH - 68;

        for (var q = 0; q < INVENTORY_QUICKBAR_SLOTS; q++) {
            var _qx = _qX + q * (_qCellSize + _qGap);
            if (_mx >= _qx && _mx <= _qx + _qCellSize &&
                _my >= _qY && _my <= _qY + _qCellSize) {
                inv_hover_type = "quickbar";
                inv_hover_idx  = q;
                break;
            }
        }
    }

    // 4. Xử lý Context Menu khi đang mở
    var _context_clicked = false;
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

        if (_mx >= context_x && _mx <= context_x + _ctxW &&
            _my >= context_y && _my <= context_y + _ctxH) {

            if (mouse_check_button_pressed(mb_left)) {
                _context_clicked = true;
                var _opt = (_my - context_y) div _optH;
                var _chosenAction = (_opt >= 0 && _opt < array_length(_opts)) ? _opts[_opt] : "";

                if (_chosenAction == "Equip" || _chosenAction == "Use") {
                    inventory_use_slot(context_slot_type, context_slot_idx);
                } else if (_chosenAction == "Unequip") {
                    inventory_unequip_slot(context_slot_idx);
                } else if (_chosenAction == "Drop 1") {
                    inventory_drop_slot(context_slot_type, context_slot_idx, 1);
                } else if (_chosenAction == "Drop All") {
                    inventory_drop_slot(context_slot_type, context_slot_idx, 999999);
                }
                context_active = false;
            }
        } else {
            if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)) {
                context_active = false;
                _context_clicked = true;
            }
        }
    }

    // 5. Xử lý Chuột Trái (Bắt đầu / Kết thúc Kéo-Thả)
    if (!_context_clicked) {
        if (mouse_check_button_pressed(mb_left)) {
            if (inv_hover_type != "") {
                var _targetIdx = (inv_hover_type == "grid") ? inventory_get_root_idx(inv_hover_idx) : inv_hover_idx;
                var _data      = inventory_get_slot_data(inv_hover_type, _targetIdx);
                if (_data != undefined) {
                    drag_active      = true;
                    drag_source_type = inv_hover_type;
                    drag_source_idx  = _targetIdx;
                    drag_data        = _data;
                }
            }
        }

        if (mouse_check_button_released(mb_left)) {
            if (drag_active) {
                if (inv_hover_type == "grid") {
                    var _mCol = inv_hover_idx mod INVENTORY_GRID_COLS;
                    var _mRow = inv_hover_idx div INVENTORY_GRID_COLS;
                    var _pos  = inventory_get_centered_grid_pos(drag_data.item_id, _mCol, _mRow);

                    inventory_swap_slots(drag_source_type, drag_source_idx, "grid", _pos.idx);
                } else if (inv_hover_type != "") {
                    inventory_swap_slots(drag_source_type, drag_source_idx, inv_hover_type, inv_hover_idx);
                } else {
                    // Thả ra ngoài UI cửa sổ -> Vứt item ra đất
                    if (_mx < _winX || _mx > _winX + _windowW || _my < _winY || _my > _winY + _windowH) {
                        inventory_drop_slot(drag_source_type, drag_source_idx, 1);
                    }
                }
                drag_active = false;
                drag_data   = undefined;
            }
        }

        // 6. Xử lý Chuột Phải (Mở Context Menu)
        if (mouse_check_button_pressed(mb_right)) {
            if (inv_hover_type != "") {
                var _targetIdx = (inv_hover_type == "grid") ? inventory_get_root_idx(inv_hover_idx) : inv_hover_idx;
                var _data      = inventory_get_slot_data(inv_hover_type, _targetIdx);
                if (_data != undefined) {
                    context_active    = true;
                    context_x         = _mx;
                    context_y         = _my;
                    context_slot_type = inv_hover_type;
                    context_slot_idx  = _targetIdx;
                }
            }
        }
    }
}
