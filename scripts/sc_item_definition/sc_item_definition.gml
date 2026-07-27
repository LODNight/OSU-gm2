// ================================================================
// sc_item_definition — Database tất cả vật phẩm trong game
// ================================================================
// Gọi item_database_create() từ o_init/Create_0.gml để đăng ký.
// Dùng item_db_get(_id) để truy xuất bất kỳ đâu trong code.
// ================================================================

/// @desc Constructor tạo một item definition bất biến (immutable).
/// @param {struct} _config Struct chứa các thuộc tính của item.
function create_item_definition(_config) constructor
{
    id          = variable_struct_exists(_config, "id")          ? _config.id          : "item_unknown";
    name        = variable_struct_exists(_config, "name")        ? _config.name        : "Unknown Item";
    description = variable_struct_exists(_config, "description") ? _config.description : "";
    item_type   = variable_struct_exists(_config, "item_type")   ? _config.item_type   : ITEM_TYPE.MATERIAL;

    // Stack
    stackable   = variable_struct_exists(_config, "stackable")   ? _config.stackable   : false;
    max_stack   = variable_struct_exists(_config, "max_stack")   ? _config.max_stack   : 1;

    // Hiển thị
    icon_sprite = variable_struct_exists(_config, "icon_sprite") ? _config.icon_sprite : noone;

    // Kinh tế
    value       = variable_struct_exists(_config, "value")       ? _config.value       : 0;

    // Tham số đặc thù
    ammo_weapon_id  = variable_struct_exists(_config, "ammo_weapon_id") ? _config.ammo_weapon_id : "";
    heal_amount     = variable_struct_exists(_config, "heal_amount")    ? _config.heal_amount    : 0;
    is_tradable     = variable_struct_exists(_config, "is_tradable")    ? _config.is_tradable    : true;
}


/// @desc Đăng ký tất cả item vào global.ItemDatabase.
///       Gọi từ o_init/Create_0.gml.
function item_database_create()
{
    global.ItemDatabase = {};

    // ── Đạn dược ─────────────────────────────────────────────────
    global.ItemDatabase[$ "ammo_pistol"] = new create_item_definition({
        id:             "ammo_pistol",
        name:           "Pistol Ammo",
        description:    "Đạn tiêu chuẩn cho súng ngắn.",
        item_type:      ITEM_TYPE.AMMO,
        stackable:      true,
        max_stack:      120,
        value:          3,
        ammo_weapon_id: "pistol_fn57",
        icon_sprite:    s_9x19
    });

    global.ItemDatabase[$ "ammo_smg"] = new create_item_definition({
        id:             "ammo_smg",
        name:           "SMG Ammo",
        description:    "Đạn tốc độ cao cho súng tiểu liên.",
        item_type:      ITEM_TYPE.AMMO,
        stackable:      true,
        max_stack:      120,
        value:          3,
        ammo_weapon_id: "subgun_p90",
        icon_sprite:    s_9x19
    });

    global.ItemDatabase[$ "ammo_shotgun"] = new create_item_definition({
        id:             "ammo_shotgun",
        name:           "Shotgun Shell",
        description:    "Đạn ghém cho súng hoa cải.",
        item_type:      ITEM_TYPE.AMMO,
        stackable:      true,
        max_stack:      120,
        value:          4,
        ammo_weapon_id: "shotgun_tus34",
        icon_sprite:    s_12GA
    });

    global.ItemDatabase[$ "ammo_sniper"] = new create_item_definition({
        id:             "ammo_sniper",
        name:           "Sniper Round",
        description:    "Đạn xuyên giáp cho súng bắn tỉa.",
        item_type:      ITEM_TYPE.AMMO,
        stackable:      true,
        max_stack:      120,
        value:          8,
        ammo_weapon_id: "snipgun_nozin_v1",
        icon_sprite:    s_56x45mm
    });

    // ── Vật phẩm tiêu dùng ───────────────────────────────────────
    global.ItemDatabase[$ "item_medkit"] = new create_item_definition({
        id:          "item_medkit",
        name:        "Med Kit",
        description: "Hồi phục 50 HP.",
        item_type:   ITEM_TYPE.CONSUMABLE,
        stackable:   true,
        max_stack:   5,
        value:       30,
        heal_amount: 50,
        icon_sprite: s_bandage_lg
    });

    global.ItemDatabase[$ "item_bandage"] = new create_item_definition({
        id:          "item_bandage",
        name:        "Bandage",
        description: "Hồi phục 20 HP.",
        item_type:   ITEM_TYPE.CONSUMABLE,
        stackable:   true,
        max_stack:   10,
        value:       10,
        heal_amount: 20,
        icon_sprite: s_bandage_sm
    });

    // ── Nguyên liệu / Loot bán tiền ──────────────────────────────
    global.ItemDatabase[$ "item_scrap_metal"] = new create_item_definition({
        id:          "item_scrap_metal",
        name:        "Scrap Metal",
        description: "Mảnh kim loại vụn, bán được lấy tiền.",
        item_type:   ITEM_TYPE.MATERIAL,
        stackable:   true,
        max_stack:   50,
        value:       5
    });

    global.ItemDatabase[$ "item_dog_tag"] = new create_item_definition({
        id:          "item_dog_tag",
        name:        "Dog Tag",
        description: "Thẻ bài của một lính ngã xuống.",
        item_type:   ITEM_TYPE.MATERIAL,
        stackable:   true,
        max_stack:   20,
        value:       15
    });

    // ── Key items (nhiệm vụ) ──────────────────────────────────────
    global.ItemDatabase[$ "item_generator_part"] = new create_item_definition({
        id:          "item_generator_part",
        name:        "Generator Part",
        description: "Linh kiện máy phát điện. Ai đó đang cần cái này.",
        item_type:   ITEM_TYPE.KEY_ITEM,
        stackable:   true,
        max_stack:   3,
        value:       0,
        is_tradable: false
    });
}


/// @desc Truy xuất item definition theo ID.
/// @param {string} _item_id
/// @return {struct|undefined}
function item_db_get(_item_id)
{
    if (!variable_global_exists("ItemDatabase")) {
        show_debug_message("[item_db_get] ItemDatabase chưa được khởi tạo!");
        return undefined;
    }
    if (!variable_struct_exists(global.ItemDatabase, _item_id)) {
        show_debug_message("[item_db_get] Item không tồn tại: " + string(_item_id));
        return undefined;
    }
    return global.ItemDatabase[$ _item_id];
}
