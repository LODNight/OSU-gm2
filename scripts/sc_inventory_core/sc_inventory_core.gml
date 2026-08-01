// ================================================================
// sc_inventory_core — Hệ thống quản lý túi đồ của Player
// ================================================================
// Hệ thống Inventory hỗ trợ kích thước đa ô (Multi-cell size như 3x2, 2x1):
//   1. InventoryGrid: Ô chứa đồ chính (kích thước 6x7 = 42 ô)
//   2. Equipment: Trang bị (Nón, Giáp, Đèn pin, Vũ khí 1, Vũ khí 2)
//   3. Quickbar: Thanh phím tắt nhanh 8 ô (từ 1 đến 8)
// ================================================================

#macro INVENTORY_GRID_COLS 6
#macro INVENTORY_GRID_ROWS 7
#macro INVENTORY_GRID_SLOTS (INVENTORY_GRID_COLS * INVENTORY_GRID_ROWS) // 42 ô
#macro INVENTORY_QUICKBAR_SLOTS 8 // 8 ô phím tắt

/// @desc Khởi tạo toàn bộ dữ liệu Inventory. Gọi từ o_inventory_manager/Create_0.gml
function inventory_init()
{
    // Ô chứa đồ chính (42 ô)
    global.InventoryGrid = array_create(INVENTORY_GRID_SLOTS, undefined);
    
    // Trang bị người chơi
    global.Equipment = {
        weapon1:    undefined, // Vũ khí 1 (Slot 1)
        weapon2:    undefined, // Vũ khí 2 (Slot 2)
        helmet:     undefined, // Nón (Slot 3)
        armor:      undefined, // Giáp (Slot 4)
        backpack:   undefined, // Balo (Slot 5)
        flashlight: undefined  // Đèn pin (Slot 6)
    };
    
    // Thanh phím tắt bên ngoài (8 ô)
    global.Quickbar = array_create(INVENTORY_QUICKBAR_SLOTS, undefined);

    global.InventoryOpen   = false;
    global.InventoryToasts = [];

    // Tạo sẵn một vài item mẫu trong túi đồ để test
    inventory_add_starter_items();
}

/// @desc Cấp item khởi đầu chuẩn cho màn chơi thực tế / tutorial (chỉ giữ duy nhất 1 khẩu súng lục)
function inventory_add_starter_items()
{
    // Xóa sạch Grid túi đồ và Quickbar
    global.InventoryGrid = array_create(INVENTORY_GRID_SLOTS, undefined);
    global.Quickbar      = array_create(INVENTORY_QUICKBAR_SLOTS, undefined);

    // Chỉ trang bị duy nhất 1 khẩu súng lục ở ô Weapon 1
    global.Equipment = {
        weapon1:    { item_id: "equip_weapon_pistol", quantity: 1 },
        weapon2:    undefined,
        helmet:     undefined,
        armor:      undefined,
        backpack:   undefined,
        flashlight: undefined
    };

    inventory_sync_player_equip();
}

/// @desc Xóa sạch túi đồ và các ô trang bị.
/// @param {bool} _keep_pistol  Nên giữ lại súng lục trong ô weapon1 không (mặc định: true)
function inventory_clear_all(_keep_pistol = true)
{
    global.InventoryGrid = array_create(INVENTORY_GRID_SLOTS, undefined);
    global.Quickbar      = array_create(INVENTORY_QUICKBAR_SLOTS, undefined);

    global.Equipment = {
        weapon1:    _keep_pistol ? { item_id: "equip_weapon_pistol", quantity: 1 } : undefined,
        weapon2:    undefined,
        helmet:     undefined,
        armor:      undefined,
        backpack:   undefined,
        flashlight: undefined
    };

    inventory_sync_player_equip();
}

/// @desc Cấp đầy đủ trang bị và item mẫu (dùng khi cần test toàn bộ hệ thống đồ)
function inventory_add_full_test_items()
{
    global.Equipment.weapon1    = { item_id: "equip_weapon_pistol", quantity: 1 };
    global.Equipment.weapon2    = { item_id: "equip_weapon_smg", quantity: 1 };
    global.Equipment.helmet     = { item_id: "equip_helmet_tactical", quantity: 1 };
    global.Equipment.armor      = { item_id: "equip_armor_vest", quantity: 1 };
    global.Equipment.backpack   = { item_id: "equip_backpack_military", quantity: 1 };
    global.Equipment.flashlight = { item_id: "equip_flashlight_wide", quantity: 1 };

    inventory_add("item_medkit", 3);
    inventory_add("ammo_pistol", 60);

    global.Quickbar[2] = { item_id: "item_medkit", quantity: 3 };

    inventory_sync_player_equip();
}


/// @desc Lấy index gốc (root cell index) của một ô trong Grid. Nếu là ô phụ thuộc, trả về index của ô gốc.
function inventory_get_root_idx(_grid_idx)
{
    if (_grid_idx < 0 || _grid_idx >= INVENTORY_GRID_SLOTS) return -1;
    var _slot = global.InventoryGrid[_grid_idx];
    if (_slot != undefined && variable_struct_exists(_slot, "root_idx")) {
        return _slot.root_idx;
    }
    return _grid_idx;
}

/// @desc Lấy dữ liệu slot từ loại mảng và index
/// @param {string} _type  "grid", "equip", hoặc "quickbar"
/// @param {any}    _idx   index mảng hoặc tên thuộc tính struct
/// @return {struct|undefined}
function inventory_get_slot_data(_type, _idx)
{
    if (_type == "grid") {
        var _root = inventory_get_root_idx(_idx);
        if (_root >= 0 && _root < INVENTORY_GRID_SLOTS) {
            var _slot = global.InventoryGrid[_root];
            if (_slot != undefined && variable_struct_exists(_slot, "item_id")) return _slot;
        }
    } else if (_type == "equip") {
        if (variable_struct_exists(global.Equipment, _idx)) return global.Equipment[$ _idx];
    } else if (_type == "quickbar") {
        if (_idx >= 0 && _idx < INVENTORY_QUICKBAR_SLOTS) return global.Quickbar[_idx];
    }
    return undefined;
}

/// @desc Đặt dữ liệu slot trực tiếp
function inventory_set_slot_data(_type, _idx, _data)
{
    if (_type == "grid") {
        var _root = inventory_get_root_idx(_idx);
        if (_root >= 0 && _root < INVENTORY_GRID_SLOTS) {
            if (_data == undefined) {
                inventory_clear_grid_item(_root);
            } else {
                global.InventoryGrid[_root] = _data;
            }
        }
    } else if (_type == "equip") {
        if (variable_struct_exists(global.Equipment, _idx)) {
            global.Equipment[$ _idx] = _data;
            inventory_sync_player_equip();
        }
    } else if (_type == "quickbar") {
        if (_idx >= 0 && _idx < INVENTORY_QUICKBAR_SLOTS) global.Quickbar[_idx] = _data;
    }
}

/// @desc Kiểm tra item (với chiều rộng grid_w và chiều cao grid_h) có đặt vừa vào vị trí (target_col, target_row) không.
function inventory_can_place_grid(_item_id, _target_col, _target_row, _ignore_root_idx = -1)
{
    if (_item_id == "" || _item_id == undefined) return false;
    var _def = item_db_get(_item_id);
    if (_def == undefined) return false;

    var _w = _def.grid_w;
    var _h = _def.grid_h;

    // Kiểm tra tràn viền Grid (6x7)
    if (_target_col < 0 || _target_col + _w > INVENTORY_GRID_COLS) return false;
    if (_target_row < 0 || _target_row + _h > INVENTORY_GRID_ROWS) return false;

    // Kiểm tra xem tất cả các ô trong hình chữ nhật (w x h) có bị ô khác chiếm không
    for (var r = _target_row; r < _target_row + _h; r++) {
        for (var c = _target_col; c < _target_col + _w; c++) {
            var _idx = r * INVENTORY_GRID_COLS + c;
            var _slot = global.InventoryGrid[_idx];
            if (_slot != undefined) {
                var _cellRoot = inventory_get_root_idx(_idx);
                if (_cellRoot != _ignore_root_idx) return false;
            }
        }
    }

    return true;
}

/// @desc Tính toán ô góc trên trái (col, row) để item căn giữa tâm chuột tại ô (m_col, m_row)
/// @param {string} _item_id
/// @param {real}   _m_col
/// @param {real}   _m_row
/// @return {struct} { col, row, idx }
function inventory_get_centered_grid_pos(_item_id, _m_col, _m_row)
{
    var _def = item_db_get(_item_id);
    var _w = _def ? _def.grid_w : 1;
    var _h = _def ? _def.grid_h : 1;

    var _offCol = (_w - 1) div 2;
    var _offRow = (_h - 1) div 2;

    var _tCol = clamp(_m_col - _offCol, 0, INVENTORY_GRID_COLS - _w);
    var _tRow = clamp(_m_row - _offRow, 0, INVENTORY_GRID_ROWS - _h);

    return {
        col: _tCol,
        row: _tRow,
        idx: _tRow * INVENTORY_GRID_COLS + _tCol
    };
}

/// @desc Đặt item chiếm mảng hình chữ nhật (grid_w x grid_h) vào Grid với ô gốc là _anchor_idx
function inventory_place_item_in_grid(_anchor_idx, _item_id, _quantity, _slotData = undefined)
{
    var _def = item_db_get(_item_id);
    if (_def == undefined) return;

    var _col = _anchor_idx mod INVENTORY_GRID_COLS;
    var _row = _anchor_idx div INVENTORY_GRID_COLS;

    // Preserve per-item runtime data (for example weapon_inst) while moving.
    var _rootData = (_slotData == undefined)
        ? { item_id: _item_id, quantity: _quantity }
        : _slotData;
    _rootData.item_id  = _item_id;
    _rootData.quantity = _quantity;
    global.InventoryGrid[_anchor_idx] = _rootData;

    // Đặt các ô phụ thuộc liên kết tới ô gốc
    for (var r = _row; r < _row + _def.grid_h; r++) {
        for (var c = _col; c < _col + _def.grid_w; c++) {
            var _idx = r * INVENTORY_GRID_COLS + c;
            if (_idx != _anchor_idx) {
                global.InventoryGrid[_idx] = { root_idx: _anchor_idx };
            }
        }
    }
}

/// @desc Xóa item khỏi ô gốc và giải phóng tất cả các ô thuộc item đó
function inventory_clear_grid_item(_grid_idx)
{
    var _root = inventory_get_root_idx(_grid_idx);
    if (_root < 0 || _root >= INVENTORY_GRID_SLOTS) return;

    var _slot = global.InventoryGrid[_root];
    if (_slot == undefined) return;

    var _col = _root mod INVENTORY_GRID_COLS;
    var _row = _root div INVENTORY_GRID_COLS;

    var _w = 1;
    var _h = 1;
    if (variable_struct_exists(_slot, "item_id")) {
        var _def = item_db_get(_slot.item_id);
        if (_def != undefined) {
            _w = _def.grid_w;
            _h = _def.grid_h;
        }
    }

    for (var r = _row; r < _row + _h; r++) {
        for (var c = _col; c < _col + _w; c++) {
            var _idx = r * INVENTORY_GRID_COLS + c;
            if (_idx >= 0 && _idx < INVENTORY_GRID_SLOTS) {
                global.InventoryGrid[_idx] = undefined;
            }
        }
    }
}

/// @desc Thêm item vào Inventory (tự động tính toán số ô grid_w x grid_h)
/// @param {string} _item_id
/// @param {real}   _quantity  (mặc định 1)
/// @return {real}  Số lượng thực sự đã thêm được
function inventory_add(_item_id, _quantity)
{
    _quantity = (_quantity == undefined) ? 1 : _quantity;
    if (_quantity <= 0) return 0;

    var _def = item_db_get(_item_id);
    if (_def == undefined) return 0;

    var _added = 0;

    // 1. Nếu vật phẩm cho phép cộng dồn (stackable), tìm các ô grid đang có cùng item
    if (_def.stackable) {
        for (var i = 0; i < INVENTORY_GRID_SLOTS; i++) {
            var _root = inventory_get_root_idx(i);
            if (_root != i) continue;

            var _slot = global.InventoryGrid[_root];
            if (_slot != undefined && variable_struct_exists(_slot, "item_id") && _slot.item_id == _item_id && _slot.quantity < _def.max_stack) {
                var _room = _def.max_stack - _slot.quantity;
                var _fill = min(_room, _quantity - _added);
                _slot.quantity += _fill;
                _added         += _fill;
                global.InventoryGrid[_root] = _slot;
                if (_added >= _quantity) break;
            }
        }
    }

    // 2. Tìm vị trí trống trong Grid cho phần số lượng chưa xếp chồng hết
    while (_added < _quantity) {
        var _placedIdx = -1;

        for (var r = 0; r < INVENTORY_GRID_ROWS; r++) {
            for (var c = 0; c < INVENTORY_GRID_COLS; c++) {
                if (inventory_can_place_grid(_item_id, c, r)) {
                    _placedIdx = r * INVENTORY_GRID_COLS + c;
                    break;
                }
            }
            if (_placedIdx != -1) break;
        }

        // Nếu Grid không đủ khoảng trống chứa item
        if (_placedIdx == -1) {
            show_debug_message("[inventory_add] Grid full or no space for item: " + _item_id);
            break;
        }

        var _take = _def.stackable ? min(_def.max_stack, _quantity - _added) : 1;
        inventory_place_item_in_grid(_placedIdx, _item_id, _take);
        _added += _take;
    }

    if (_added > 0) {
        inventory_toast("+ " + string(_added) + "x " + _def.name);
    }
    return _added;
}

/// @desc Lấy danh sách ô Grid (dành cho tương thích ngược)
function inventory_get_all()
{
    return global.InventoryGrid;
}

/// @desc Xóa item khỏi túi đồ
function inventory_remove(_item_id, _quantity)
{
    _quantity = (_quantity == undefined) ? 1 : _quantity;
    if (!inventory_has(_item_id, _quantity)) return false;

    var _remaining = _quantity;

    // Xóa trong Grid trước
    for (var i = INVENTORY_GRID_SLOTS - 1; i >= 0; i--) {
        var _root = inventory_get_root_idx(i);
        if (_root != i) continue;

        var _slot = global.InventoryGrid[_root];
        if (_slot == undefined || !variable_struct_exists(_slot, "item_id") || _slot.item_id != _item_id) continue;

        if (_slot.quantity <= _remaining) {
            _remaining -= _slot.quantity;
            inventory_clear_grid_item(_root);
        } else {
            _slot.quantity -= _remaining;
            global.InventoryGrid[_root] = _slot;
            _remaining = 0;
        }
        if (_remaining <= 0) break;
    }

    // Xóa tiếp trong Quickbar nếu vẫn còn thiếu
    if (_remaining > 0) {
        for (var i = INVENTORY_QUICKBAR_SLOTS - 1; i >= 0; i--) {
            var _slot = global.Quickbar[i];
            if (_slot == undefined || _slot.item_id != _item_id) continue;

            if (_slot.quantity <= _remaining) {
                _remaining -= _slot.quantity;
                global.Quickbar[i] = undefined;
            } else {
                _slot.quantity -= _remaining;
                global.Quickbar[i] = _slot;
                _remaining = 0;
            }
            if (_remaining <= 0) break;
        }
    }

    return true;
}

/// @desc Đếm tổng số lượng của một item trong tất cả các kho chứa
function inventory_count(_item_id)
{
    var _total = 0;
    // Đếm trong Grid (chỉ đếm từ root cell)
    for (var i = 0; i < INVENTORY_GRID_SLOTS; i++) {
        var _root = inventory_get_root_idx(i);
        if (_root != i) continue;

        var _slot = global.InventoryGrid[_root];
        if (_slot != undefined && variable_struct_exists(_slot, "item_id") && _slot.item_id == _item_id) {
            _total += _slot.quantity;
        }
    }
    // Đếm trong Quickbar
    for (var i = 0; i < INVENTORY_QUICKBAR_SLOTS; i++) {
        var _slot = global.Quickbar[i];
        if (_slot != undefined && _slot.item_id == _item_id) _total += _slot.quantity;
    }
    return _total;
}

function inventory_has(_item_id, _quantity)
{
    _quantity = (_quantity == undefined) ? 1 : _quantity;
    return inventory_count(_item_id) >= _quantity;
}

function inventory_is_valid_for_equip(_item_id, _equip_slot)
{
    if (_item_id == "" || _item_id == undefined) return false;
    var _def = item_db_get(_item_id);
    if (_def == undefined) return false;

    switch (_equip_slot) {
        case "weapon1":    return (_def.item_type == ITEM_TYPE.WEAPON);
        case "weapon2":    return (_def.item_type == ITEM_TYPE.WEAPON);
        case "helmet":     return (_def.item_type == ITEM_TYPE.HELMET);
        case "armor":      return (_def.item_type == ITEM_TYPE.ARMOR);
        case "backpack":   return (_def.item_type == ITEM_TYPE.BACKPACK);
        case "flashlight": return (_def.item_type == ITEM_TYPE.FLASHLIGHT);
    }
    return false;
}

/// @desc Hoán đổi hoặc di chuyển item giữa 2 vị trí slot bất kỳ (xử lý đa ô grid_w x grid_h)
function inventory_swap_slots(_typeA, _idxA, _typeB, _idxB)
{
    var _rootA = (_typeA == "grid") ? inventory_get_root_idx(_idxA) : _idxA;
    var _rootB = (_typeB == "grid") ? inventory_get_root_idx(_idxB) : _idxB;

    if (_typeA == _typeB && _rootA == _rootB) return false;

    var _dataA = inventory_get_slot_data(_typeA, _rootA);
    var _dataB = inventory_get_slot_data(_typeB, _rootB);

    if (_dataA == undefined && _dataB == undefined) return false;

    // Kiểm tra ràng buộc trang bị
    if (_typeB == "equip" && _dataA != undefined) {
        if (!inventory_is_valid_for_equip(_dataA.item_id, _rootB)) {
            inventory_toast("Invalid item for this equipment slot!");
            return false;
        }
    }
    if (_typeA == "equip" && _dataB != undefined) {
        if (!inventory_is_valid_for_equip(_dataB.item_id, _rootA)) {
            inventory_toast("Invalid item for this equipment slot!");
            return false;
        }
    }

    // Xử lý di chuyển đến Grid B
    if (_typeB == "grid") {
        var _colB = _idxB mod INVENTORY_GRID_COLS;
        var _rowB = _idxB div INVENTORY_GRID_COLS;

        // Tạm thời xóa A và B khỏi Grid để kiểm tra không gian
        if (_typeA == "grid") inventory_clear_grid_item(_rootA);
        if (_dataB != undefined) inventory_clear_grid_item(_rootB);

        // Kiểm tra xem A có vừa ô B không
        if (_dataA != undefined && !inventory_can_place_grid(_dataA.item_id, _colB, _rowB)) {
            inventory_toast("Not enough grid space!");
            // Khôi phục vị trí cũ
            if (_typeA == "grid" && _dataA != undefined) inventory_place_item_in_grid(_rootA, _dataA.item_id, _dataA.quantity, _dataA);
            if (_dataB != undefined) inventory_place_item_in_grid(_rootB, _dataB.item_id, _dataB.quantity, _dataB);
            return false;
        }

        // Nếu B tồn tại và chuyển về Grid A
        if (_dataB != undefined && _typeA == "grid") {
            var _colA = _rootA mod INVENTORY_GRID_COLS;
            var _rowA = _rootA div INVENTORY_GRID_COLS;
            if (!inventory_can_place_grid(_dataB.item_id, _colA, _rowA)) {
                inventory_toast("Not enough grid space to swap!");
                if (_typeA == "grid" && _dataA != undefined) inventory_place_item_in_grid(_rootA, _dataA.item_id, _dataA.quantity, _dataA);
                if (_dataB != undefined) inventory_place_item_in_grid(_rootB, _dataB.item_id, _dataB.quantity, _dataB);
                return false;
            }
            inventory_place_item_in_grid(_rootA, _dataB.item_id, _dataB.quantity, _dataB);
        } else if (_dataB != undefined) {
            inventory_set_slot_data(_typeA, _rootA, _dataB);
        } else if (_typeA != "grid") {
            inventory_set_slot_data(_typeA, _rootA, undefined);
        }

        if (_dataA != undefined) {
            var _anchorB = _rowB * INVENTORY_GRID_COLS + _colB;
            inventory_place_item_in_grid(_anchorB, _dataA.item_id, _dataA.quantity, _dataA);
        }
        return true;
    }

    // Xử lý di chuyển từ Grid A sang Slot phi-Grid B (Equip/Quickbar)
    if (_typeA == "grid") {
        inventory_clear_grid_item(_rootA);
        if (_dataB != undefined) {
            var _colA = _rootA mod INVENTORY_GRID_COLS;
            var _rowA = _rootA div INVENTORY_GRID_COLS;
            if (!inventory_can_place_grid(_dataB.item_id, _colA, _rowA)) {
                inventory_toast("Not enough grid space!");
                if (_dataA != undefined) inventory_place_item_in_grid(_rootA, _dataA.item_id, _dataA.quantity, _dataA);
                return false;
            }
            inventory_place_item_in_grid(_rootA, _dataB.item_id, _dataB.quantity, _dataB);
        }
        inventory_set_slot_data(_typeB, _rootB, _dataA);
        return true;
    }

    // Hoán đổi giữa 2 slot không phải Grid (Equip & Quickbar)
    inventory_set_slot_data(_typeA, _rootA, _dataB);
    inventory_set_slot_data(_typeB, _rootB, _dataA);
    return true;
}

function inventory_sync_player_equip()
{
    if (!instance_exists(o_player)) return;

    var _flashSlot = global.Equipment.flashlight;
    if (_flashSlot != undefined) {
        var _def = item_db_get(_flashSlot.item_id);
        if (_def != undefined && _def.flashlight_id != "") {
            if (!variable_global_exists("FlashlightDefs")) sc_lighting_definitions();
            if (variable_struct_exists(global.FlashlightDefs, _def.flashlight_id)) {
                o_player.flashlightItem = global.FlashlightDefs[$ _def.flashlight_id];
            }
        }
    } else {
        if (variable_struct_exists(global.FlashlightDefs, DEFAULT_FLASHLIGHT)) {
            o_player.flashlightItem = global.FlashlightDefs[$ DEFAULT_FLASHLIGHT];
        }
    }

    var _w1 = global.Equipment.weapon1;
    var _w2 = global.Equipment.weapon2;
    var _w1Inst = noone;
    var _w2Inst = noone;

    if (!variable_global_exists("Weapons")) sc_weapon_init();

    if (_w1 != undefined) {
        var _def1 = item_db_get(_w1.item_id);
        if (_def1 != undefined && _def1.weapon_id != "" && variable_struct_exists(global.Weapons, _def1.weapon_id)) {
            var _weaponDef1 = global.Weapons[$ _def1.weapon_id];
            var _reuse1 = variable_struct_exists(_w1, "weapon_inst")
                && is_struct(_w1.weapon_inst)
                && variable_struct_exists(_w1.weapon_inst, "definition")
                && _w1.weapon_inst.definition.id == _weaponDef1.id;
            if (!_reuse1) _w1.weapon_inst = new create_weapon_instance(_weaponDef1);
            _w1Inst = _w1.weapon_inst;
        }
    }

    if (_w2 != undefined) {
        var _def2 = item_db_get(_w2.item_id);
        if (_def2 != undefined && _def2.weapon_id != "" && variable_struct_exists(global.Weapons, _def2.weapon_id)) {
            var _weaponDef2 = global.Weapons[$ _def2.weapon_id];
            var _reuse2 = variable_struct_exists(_w2, "weapon_inst")
                && is_struct(_w2.weapon_inst)
                && variable_struct_exists(_w2.weapon_inst, "definition")
                && _w2.weapon_inst.definition.id == _weaponDef2.id;
            if (!_reuse2) _w2.weapon_inst = new create_weapon_instance(_weaponDef2);
            _w2Inst = _w2.weapon_inst;
        }
    }

    o_player.inventoryWeapons = [_w1Inst, _w2Inst];

    if (o_player.selectedWeapon < 0 || o_player.selectedWeapon > 1) {
        o_player.selectedWeapon = 0;
    }

    // Nếu slot súng hiện tại rỗng nhưng slot còn lại có súng, tự động chọn slot có súng
    if (o_player.inventoryWeapons[o_player.selectedWeapon] == noone) {
        if (o_player.inventoryWeapons[1 - o_player.selectedWeapon] != noone) {
            o_player.selectedWeapon = 1 - o_player.selectedWeapon;
        }
    }

    o_player.weapon = o_player.inventoryWeapons[o_player.selectedWeapon];
}

function inventory_use_slot(_type, _idx)
{
    var _slot = inventory_get_slot_data(_type, _idx);
    if (_slot == undefined) return false;

    var _def = item_db_get(_slot.item_id);
    if (_def == undefined) return false;

    if (_type == "grid" || _type == "quickbar") {
        var _targetEquip = "";
        if (_def.item_type == ITEM_TYPE.HELMET)     _targetEquip = "helmet";
        if (_def.item_type == ITEM_TYPE.ARMOR)      _targetEquip = "armor";
        if (_def.item_type == ITEM_TYPE.BACKPACK)   _targetEquip = "backpack";
        if (_def.item_type == ITEM_TYPE.FLASHLIGHT) _targetEquip = "flashlight";
        if (_def.item_type == ITEM_TYPE.WEAPON) {
            if (global.Equipment.weapon1 == undefined) _targetEquip = "weapon1";
            else if (global.Equipment.weapon2 == undefined) _targetEquip = "weapon2";
            else _targetEquip = "weapon1";
        }

        if (_targetEquip != "") {
            inventory_swap_slots(_type, _idx, "equip", _targetEquip);
            inventory_toast("Equipped " + _def.name);
            return true;
        }
    }

    var _used = false;
    if (_def.item_type == ITEM_TYPE.CONSUMABLE) {
        if (_def.heal_amount > 0 && instance_exists(o_player)) {
            if (o_player.hp >= o_player.maxHp) {
                inventory_toast("HP is full!");
                return false;
            }
            with (o_player) {
                hp = min(maxHp, hp + _def.heal_amount);
            }
            inventory_toast("Restored +" + string(_def.heal_amount) + " HP");
            _used = true;
        }
    } else {
        inventory_toast("Cannot use this item!");
        return false;
    }

    if (_used) {
        _slot.quantity--;
        if (_slot.quantity <= 0) {
            inventory_set_slot_data(_type, _idx, undefined);
        } else {
            inventory_set_slot_data(_type, _idx, _slot);
        }
    }

    return _used;
}

function inventory_unequip_slot(_equip_slot)
{
    var _data = inventory_get_slot_data("equip", _equip_slot);
    if (_data == undefined) return false;

    // Tìm vị trí grid trống đủ kích thước
    var _def = item_db_get(_data.item_id);
    var _placedIdx = -1;
    if (_def != undefined) {
        for (var r = 0; r < INVENTORY_GRID_ROWS; r++) {
            for (var c = 0; c < INVENTORY_GRID_COLS; c++) {
                if (inventory_can_place_grid(_data.item_id, c, r)) {
                    _placedIdx = r * INVENTORY_GRID_COLS + c;
                    break;
                }
            }
            if (_placedIdx != -1) break;
        }
    }

    if (_placedIdx == -1) {
        inventory_toast("Grid is full! Cannot unequip.");
        return false;
    }

    inventory_swap_slots("equip", _equip_slot, "grid", _placedIdx);
    inventory_toast("Unequipped item");
    return true;
}

function inventory_drop_slot(_type, _idx, _amount = 1)
{
    var _slot = inventory_get_slot_data(_type, _idx);
    if (_slot == undefined) return false;
    if (!instance_exists(o_player)) return false;

    var _def = item_db_get(_slot.item_id);
    if (_def == undefined) return false;

    var _dropCount = min(_amount, _slot.quantity);
    if (_dropCount <= 0) return false;

    var _dropX = o_player.x + irandom_range(-12, 12);
    var _dropY = o_player.y + irandom_range(-12, 12);

    var _pickup = instance_create_depth(_dropX, _dropY, -_dropY, o_item_pickup);
    if (instance_exists(_pickup)) {
        _pickup.item_id  = _slot.item_id;
        _pickup.quantity = _dropCount;
    }

    inventory_toast("- " + string(_dropCount) + "x " + _def.name);

    _slot.quantity -= _dropCount;
    if (_slot.quantity <= 0) {
        inventory_set_slot_data(_type, _idx, undefined);
    } else {
        inventory_set_slot_data(_type, _idx, _slot);
    }

    return true;
}

function inventory_toast(_text)
{
    if (!variable_global_exists("InventoryToasts")) global.InventoryToasts = [];
    array_push(global.InventoryToasts, { text: _text, timer: 180 });
    while (array_length(global.InventoryToasts) > 5) {
        array_delete(global.InventoryToasts, 0, 1);
    }
}

function inventory_toast_update()
{
    if (!variable_global_exists("InventoryToasts")) return;
    for (var i = array_length(global.InventoryToasts) - 1; i >= 0; i--) {
        global.InventoryToasts[i].timer--;
        if (global.InventoryToasts[i].timer <= 0) {
            array_delete(global.InventoryToasts, i, 1);
        }
    }
}

/// @desc Vẽ icon item giữ nguyên tỷ lệ khung hình (Aspect Ratio), luôn nằm chính giữa ô
function draw_item_icon_fitted(_def, _x, _y, _maxW, _maxH, _forceHorizontal = false)
{
    if (_def == undefined || _def.icon_sprite == noone || !sprite_exists(_def.icon_sprite)) return;

    var _spr = _def.icon_sprite;
    var _sw  = sprite_get_width(_spr);
    var _sh  = sprite_get_height(_spr);
    var _xo  = sprite_get_xoffset(_spr);
    var _yo  = sprite_get_yoffset(_spr);

    var _angle = 0;
    if (_forceHorizontal && _sh > _sw) {
        _angle = -90;
    }

    var _effW = (abs(_angle) == 90 || abs(_angle) == 270) ? _sh : _sw;
    var _effH = (abs(_angle) == 90 || abs(_angle) == 270) ? _sw : _sh;

    var _scale = min(_maxW / _effW, _maxH / _effH);

    // Khoảng cách từ origin tới tâm sprite khi chưa xoay (unscaled)
    var _cx_unscaled = (_sw / 2) - _xo;
    var _cy_unscaled = (_sh / 2) - _yo;

    // Xoay vector tâm theo _angle và scale (hệ tọa độ GameMaker màn hình y xuống)
    var _cx_rot = (_cx_unscaled * dcos(_angle) + _cy_unscaled * dsin(_angle)) * _scale;
    var _cy_rot = (-_cx_unscaled * dsin(_angle) + _cy_unscaled * dcos(_angle)) * _scale;

    // Tọa độ vẽ sao cho TÂM của sprite luôn nằm đúng TÂM khung ô
    var _drawX = (_x + _maxW / 2) - _cx_rot;
    var _drawY = (_y + _maxH / 2) - _cy_rot;

    draw_sprite_ext(_spr, 0, _drawX, _drawY, _scale, _scale, _angle, c_white, 1);
}
