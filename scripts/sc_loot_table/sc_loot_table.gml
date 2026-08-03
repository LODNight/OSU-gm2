// ================================================================
// sc_loot_table — Bảng loot rơi ra khi enemy chết
// ================================================================
// Gọi loot_table_create() từ o_init/Create_0.gml.
// Gọi loot_roll(_table_id, _x, _y) trong enemy_die().
// ================================================================

/// @desc Đăng ký tất cả bảng loot. Gọi từ o_init/Create_0.gml.
function loot_table_create()
{
    global.LootTables = {};

    // ── Zombie cơ bản ─────────────────────────────────────────────
    // Rớt đồ theo tỷ lệ (không phải lúc nào cũng rớt)
    global.LootTables[$ "zombie_basic"] = [
        { item_id: "item_scrap_metal", chance: 0.35, min: 1, max: 2 },
        { item_id: "item_bandage",     chance: 0.15, min: 1, max: 1 }
    ];

    // ── Zombie tốc độ ─────────────────────────────────────────────
    global.LootTables[$ "zombie_speed"] = [
        { item_id: "item_scrap_metal", chance: 0.40, min: 1, max: 2 },
        { item_id: "item_bandage",     chance: 0.20, min: 1, max: 1 }
    ];

    // ── Lính canh (bắn súng ngắn) ─────────────────────────────────
    global.LootTables[$ "human_guard"] = [
        { item_id: "ammo_pistol",      chance: 0.60, min: 5,  max: 15 },
        { item_id: "item_dog_tag",     chance: 0.30, min: 1,  max: 1  },
        { item_id: "item_medkit",      chance: 0.15, min: 1,  max: 1  },
        { item_id: "item_scrap_metal", chance: 0.30, min: 1,  max: 3  }
    ];

    // ── Lính bắn tỉa ──────────────────────────────────────────────
    global.LootTables[$ "human_soldier"] = [
        { item_id: "ammo_sniper",      chance: 0.65, min: 3,  max: 8  },
        { item_id: "item_dog_tag",     chance: 0.40, min: 1,  max: 2  },
        { item_id: "item_medkit",      chance: 0.15, min: 1,  max: 1  },
        { item_id: "item_scrap_metal", chance: 0.30, min: 1,  max: 3  }
    ];
}


/// @desc Sinh danh sách vật phẩm ngẫu nhiên từ bảng loot (trả về array các struct {item_id, quantity})
/// @param {string} _table_id ID bảng loot
/// @return {array} Danh sách struct {item_id, quantity}
function loot_generate(_table_id)
{
    var _result = [];
    if (!variable_global_exists("LootTables")) return _result;
    if (!variable_struct_exists(global.LootTables, _table_id)) return _result;

    var _table = global.LootTables[$ _table_id];

    for (var i = 0; i < array_length(_table); i++) {
        var _entry = _table[i];
        if (random(1) > _entry.chance) continue;

        var _qty = irandom_range(_entry.min, _entry.max);
        if (_qty <= 0) continue;

        array_push(_result, { item_id: _entry.item_id, quantity: _qty });
    }

    return _result;
}

/// @desc Roll loot từ bảng và add trực tiếp vào túi đồ (dành cho tương thích)
function loot_roll(_table_id, _x, _y)
{
    var _items = loot_generate(_table_id);
    for (var i = 0; i < array_length(_items); i++) {
        inventory_add(_items[i].item_id, _items[i].quantity);
    }
}

