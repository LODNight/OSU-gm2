// o_loot_manager — Step Event
// Tìm xác Enemy gần nhất Player chưa loot.
// Nếu nhấn F → loot xác đó, đánh dấu đã loot, đồ vào túi.

if (!instance_exists(o_player)) { closest_corpse = noone; exit; }

var _px = o_player.x;
var _py = o_player.y;
var _pressed_f = keyboard_check_pressed(ord("F"));

// -- Tìm xác gần nhất chưa loot ------------------------------------------
closest_corpse = noone;
var _closest_dist = PICKUP_RANGE;

// Danh sách tất cả corpse object types trong game
var _corpse_types = [o_z_1_die, o_z_speed_1_die, o_h_1_die, o_h_soli_die];

for (var t = 0; t < array_length(_corpse_types); t++) {
    var _type = _corpse_types[t];
    with (_type) {
        if (looted) continue;
        if (!variable_instance_exists(id, "loot_table_id")) continue;
        if (loot_table_id == "") continue;

        var _dist = point_distance(_px, _py, x, y);
        if (_dist < _closest_dist) {
            _closest_dist   = _dist;
            other.closest_corpse = id;
        }
    }
}

// -- Nhấn F: loot xác gần nhất -------------------------------------------
if (_pressed_f && instance_exists(closest_corpse)) {
    var _corpse = closest_corpse;
    if (!_corpse.looted && _corpse.loot_table_id != "") {
        if (!instance_exists(o_inventory_manager)) {
            instance_create_depth(0, 0, 0, o_inventory_manager);
        }
        loot_roll(_corpse.loot_table_id, _corpse.x, _corpse.y);
        _corpse.looted     = true;
        _corpse.loot_timer = -1; // Bắt đầu đếm 30s trong corpse_step()
        closest_corpse     = noone;
    }
}
