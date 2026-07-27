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
    // 100% rơi 1-3 scrap metal để đảm bảo luôn rớt đồ khi test
    global.LootTables[$ "zombie_basic"] = [
        { item_id: "item_scrap_metal", chance: 1.00, min: 1, max: 3 },
        { item_id: "item_bandage",     chance: 0.30, min: 1, max: 1 }
    ];

    // ── Zombie tốc độ ─────────────────────────────────────────────
    global.LootTables[$ "zombie_speed"] = [
        { item_id: "item_scrap_metal", chance: 1.00, min: 1, max: 2 },
        { item_id: "item_bandage",     chance: 0.30, min: 1, max: 1 }
    ];

    // ── Lính canh (bắn súng ngắn) ─────────────────────────────────
    global.LootTables[$ "human_guard"] = [
        { item_id: "ammo_pistol",      chance: 1.00, min: 5,  max: 20 },
        { item_id: "item_dog_tag",     chance: 0.50, min: 1,  max: 1  },
        { item_id: "item_medkit",      chance: 0.20, min: 1,  max: 1  },
        { item_id: "item_scrap_metal", chance: 0.50, min: 2,  max: 5  }
    ];

    // ── Lính bắn tỉa ──────────────────────────────────────────────
    global.LootTables[$ "human_soldier"] = [
        { item_id: "ammo_sniper",      chance: 1.00, min: 3,  max: 10 },
        { item_id: "item_dog_tag",     chance: 0.70, min: 1,  max: 2  },
        { item_id: "item_medkit",      chance: 0.20, min: 1,  max: 1  },
        { item_id: "item_scrap_metal", chance: 0.50, min: 2,  max: 4  }
    ];
}


/// @desc Roll loot từ bảng và spawn vật phẩm trên map qua o_loot_manager.
/// @param {string} _table_id  ID bảng loot
/// @param {real}   _x         Tọa độ X
/// @param {real}   _y         Tọa độ Y
function loot_roll(_table_id, _x, _y)
{
    if (!variable_global_exists("LootTables")) return;
    if (!variable_struct_exists(global.LootTables, _table_id)) {
        show_debug_message("[loot_roll] Không tìm thấy loot table: " + string(_table_id));
        return;
    }

    var _table = global.LootTables[$ _table_id];

    for (var i = 0; i < array_length(_table); i++) {
        var _entry = _table[i];
        if (random(1) > _entry.chance) continue;

        var _qty = irandom_range(_entry.min, _entry.max);
        if (_qty <= 0) continue;

        // Add trực tiếp vào túi đồ vì tính năng rớt đồ đã chuyển sang rớt từ xác
        inventory_add(_entry.item_id, _qty);
    }
}
