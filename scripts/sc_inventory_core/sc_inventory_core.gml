// ================================================================
// sc_inventory_core — Hệ thống quản lý túi đồ của Player
// ================================================================
// Inventory lưu dưới dạng array of slot structs:
//   slot = { item_id: string, quantity: real }
//
// API:
//   inventory_add()    — nhặt đồ / nhận thưởng
//   inventory_remove() — dùng đồ / nộp quest
//   inventory_has()    — quest / shop kiểm tra
//   inventory_count()  — tổng số lượng một item
//   inventory_use()    — dùng consumable
// ================================================================

#macro INVENTORY_MAX_SLOTS 30   // Số ô tối đa trong grid

/// @desc Khởi tạo inventory rỗng. Gọi từ o_inventory_manager/Create_0.gml
function inventory_init()
{
    global.Inventory      = [];
    global.InventoryOpen  = false;
    global.InventoryToasts = [];
}


/// @desc Thêm item vào inventory. Xử lý stacking tự động.
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

    if (_def.stackable) {
        // Tìm slot cùng item chưa đầy stack
        for (var i = 0; i < array_length(global.Inventory); i++) {
            var _slot = global.Inventory[i];
            if (_slot.item_id == _item_id && _slot.quantity < _def.max_stack) {
                var _room = _def.max_stack - _slot.quantity;
                var _fill = min(_room, _quantity - _added);
                _slot.quantity += _fill;
                _added         += _fill;
                global.Inventory[i] = _slot;
                if (_added >= _quantity) break;
            }
        }
    }

    // Tạo slot mới cho số lượng còn lại
    while (_added < _quantity) {
        if (array_length(global.Inventory) >= INVENTORY_MAX_SLOTS) {
            show_debug_message("[inventory_add] Inventory đầy! Không thể thêm: " + _item_id);
            break;
        }
        var _take = _def.stackable ? min(_def.max_stack, _quantity - _added) : 1;
        array_push(global.Inventory, { item_id: _item_id, quantity: _take });
        _added += _take;
    }

    if (_added > 0) {
        inventory_toast("+ " + string(_added) + "x " + _def.name);
    }
    return _added;
}


/// @desc Xóa item khỏi inventory (dùng đồ, nộp quest, bán).
/// @param {string} _item_id
/// @param {real}   _quantity
/// @return {bool}  true nếu đủ và đã xóa thành công
function inventory_remove(_item_id, _quantity)
{
    _quantity = (_quantity == undefined) ? 1 : _quantity;
    if (!inventory_has(_item_id, _quantity)) return false;

    var _remaining = _quantity;
    for (var i = array_length(global.Inventory) - 1; i >= 0; i--) {
        var _slot = global.Inventory[i];
        if (_slot.item_id != _item_id) continue;

        if (_slot.quantity <= _remaining) {
            _remaining -= _slot.quantity;
            array_delete(global.Inventory, i, 1);
        } else {
            _slot.quantity -= _remaining;
            global.Inventory[i] = _slot;
            _remaining = 0;
        }
        if (_remaining <= 0) break;
    }
    return true;
}


/// @desc Kiểm tra xem inventory có đủ số lượng item không.
/// @param {string} _item_id
/// @param {real}   _quantity  (mặc định 1)
/// @return {bool}
function inventory_has(_item_id, _quantity)
{
    _quantity = (_quantity == undefined) ? 1 : _quantity;
    return inventory_count(_item_id) >= _quantity;
}


/// @desc Đếm tổng số lượng của một item (kể cả phân tán nhiều slot).
/// @param {string} _item_id
/// @return {real}
function inventory_count(_item_id)
{
    var _total = 0;
    for (var i = 0; i < array_length(global.Inventory); i++) {
        var _slot = global.Inventory[i];
        if (_slot.item_id == _item_id) _total += _slot.quantity;
    }
    return _total;
}


/// @desc Lấy toàn bộ danh sách slot (dùng cho UI vẽ grid).
/// @return {array}
function inventory_get_all()
{
    return global.Inventory;
}


/// @desc Dùng một consumable item theo ID. Trả về true nếu dùng được.
/// @param {string} _item_id
/// @return {bool}
function inventory_use(_item_id)
{
    var _def = item_db_get(_item_id);
    if (_def == undefined) return false;
    if (!inventory_has(_item_id, 1)) return false;

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
    }

    if (_used) inventory_remove(_item_id, 1);
    return _used;
}


/// @desc Dùng item tại slot chỉ định trong túi đồ.
/// @param {real} _slot_index
/// @return {bool}
function inventory_use_slot(_slot_index)
{
    if (_slot_index < 0 || _slot_index >= array_length(global.Inventory)) return false;

    var _slot = global.Inventory[_slot_index];
    var _def  = item_db_get(_slot.item_id);
    if (_def == undefined) return false;

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
            array_delete(global.Inventory, _slot_index, 1);
        } else {
            global.Inventory[_slot_index] = _slot;
        }
    }
    return _used;
}


/// @desc Vứt item tại slot chỉ định ra mặt đất tại vị trí Player.
/// @param {real} _slot_index
/// @param {real} _amount Số lượng muốn vứt (1 hoặc tất cả)
/// @return {bool}
function inventory_drop_slot(_slot_index, _amount = 1)
{
    if (_slot_index < 0 || _slot_index >= array_length(global.Inventory)) return false;
    if (!instance_exists(o_player)) return false;

    var _slot = global.Inventory[_slot_index];
    var _def  = item_db_get(_slot.item_id);
    if (_def == undefined) return false;

    var _dropCount = min(_amount, _slot.quantity);
    if (_dropCount <= 0) return false;

    // Spawn item_pickup tại vị trí Player với chút lệch nhẹ
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
        array_delete(global.Inventory, _slot_index, 1);
    } else {
        global.Inventory[_slot_index] = _slot;
    }

    return true;
}


// ── Toast Notification System ─────────────────────────────────────

/// @desc Thêm toast nhỏ ở góc màn hình khi nhặt/dùng đồ.
function inventory_toast(_text)
{
    if (!variable_global_exists("InventoryToasts")) global.InventoryToasts = [];
    array_push(global.InventoryToasts, { text: _text, timer: 180 });
    // Tối đa 5 toast cùng lúc
    while (array_length(global.InventoryToasts) > 5) {
        array_delete(global.InventoryToasts, 0, 1);
    }
}

/// @desc Tick timer toast mỗi frame. Gọi từ o_inventory_manager/Step_0.gml
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
