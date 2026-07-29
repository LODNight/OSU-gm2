// o_inventory_manager — Step Event
// Toggle UI + cập nhật toast timer

// Toggle mở/đóng inventory bằng Tab
if (keyboard_check_pressed(inv_key)) {
    global.InventoryOpen = !global.InventoryOpen;
    if (!global.InventoryOpen) {
        context_active = false;
    }
}

// Tick toast timers
inventory_toast_update();

if (variable_global_exists("InventoryOpen") && global.InventoryOpen) {
    var _camW = display_get_gui_width();
    var _camH = display_get_gui_height();
    var _mx   = device_mouse_x_to_gui(0);
    var _my   = device_mouse_y_to_gui(0);

    var _cols     = 6;
    var _rows     = 5;
    var _cellSize = 64;
    var _gap      = 4;
    var _pad      = 16;
    var _panelW   = _cols * (_cellSize + _gap) + _pad * 2;
    var _panelH   = _rows * (_cellSize + _gap) + _pad * 2 + 40;
    var _panelX   = (_camW - _panelW) / 2;
    var _panelY   = (_camH - _panelH) / 2;

    inv_selected_slot = -1;

    var _context_clicked = false;
    if (context_active) {
        var _ctxW = 120;
        var _ctxH = 80; // 2 options: Use, Drop (40px each)
        
        if (_mx >= context_x && _mx <= context_x + _ctxW &&
            _my >= context_y && _my <= context_y + _ctxH) {
            
            if (mouse_check_button_pressed(mb_left)) {
                _context_clicked = true;
                var _opt = (_my - context_y) div 40; 
                if (_opt == 0) {
                    // TODO: Use Item Logic
                    // item_use(context_slot);
                } else if (_opt == 1) {
                    // TODO: Drop Item Logic
                    // item_drop(context_slot);
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

    if (!_context_clicked) {
        for (var i = 0; i < _cols * _rows; i++) {
            var _col = i mod _cols;
            var _row = i div _cols;
            var _cx  = _panelX + _pad + _col * (_cellSize + _gap);
            var _cy  = _panelY + _pad + 40 + _row * (_cellSize + _gap);

            if (_mx >= _cx && _mx <= _cx + _cellSize &&
                _my >= _cy && _my <= _cy + _cellSize) {
                inv_selected_slot = i;
                break;
            }
        }

        if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)) {
            if (inv_selected_slot >= 0) {
                var _slots = inventory_get_all();
                if (inv_selected_slot < array_length(_slots)) {
                    context_active = true;
                    context_x = _mx;
                    context_y = _my;
                    context_slot = inv_selected_slot;
                }
            }
        }
    }
}
