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

    // Kích thước ô trong kho đồ (Grid size)
    grid_w = variable_struct_exists(_config, "grid_w") ? _config.grid_w : 1;
    grid_h = variable_struct_exists(_config, "grid_h") ? _config.grid_h : 1;

    // Tự động tách định dạng chuỗi "WxH" (Ví dụ: size: "3x2" -> grid_w = 3, grid_h = 2)
    size = variable_struct_exists(_config, "size") ? _config.size : "";
    if (size != "") {
        var _parts = string_split(size, "x");
        if (array_length(_parts) >= 2) {
            var _strW = string_digits(_parts[0]);
            var _strH = string_digits(_parts[1]);
            if (_strW != "") grid_w = real(_strW);
            if (_strH != "") grid_h = real(_strH);
        }
    } else {
        size = string(grid_w) + "x" + string(grid_h);
    }

    // Tham số đặc thù
    ammo_weapon_id  = variable_struct_exists(_config, "ammo_weapon_id") ? _config.ammo_weapon_id : "";
    flashlight_id   = variable_struct_exists(_config, "flashlight_id")  ? _config.flashlight_id  : "";
    weapon_id       = variable_struct_exists(_config, "weapon_id")      ? _config.weapon_id      : "";
    heal_amount     = variable_struct_exists(_config, "heal_amount")    ? _config.heal_amount    : 0;
    defense         = variable_struct_exists(_config, "defense")        ? _config.defense        : 0;
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
        description:    "Standard 9mm pistol ammunition.",
        item_type:      ITEM_TYPE.AMMO,
        stackable:      true,
        max_stack:      60,
        value:          2,
        ammo_weapon_id: "pistol_fn57",
        icon_sprite:    s_9x19
    });

    global.ItemDatabase[$ "ammo_shotgun"] = new create_item_definition({
        id:             "ammo_shotgun",
        name:           "Shotgun Shells",
        description:    "12 Gauge shotgun shells.",
        item_type:      ITEM_TYPE.AMMO,
        stackable:      true,
        max_stack:      20,
        value:          5,
        ammo_weapon_id: "shotgun_tus34",
        icon_sprite:    s_12GA
    });

    global.ItemDatabase[$ "ammo_rifle"] = new create_item_definition({
        id:             "ammo_rifle",
        name:           "Rifle Ammo",
        description:    "5.56mm assault rifle rounds.",
        item_type:      ITEM_TYPE.AMMO,
        stackable:      true,
        max_stack:      30,
        value:          4,
        ammo_weapon_id: "subgun_p90",
        icon_sprite:    s_56x45mm
    });

    // ── Vật phẩm hồi máu (Consumables) ────────────────────────────
    global.ItemDatabase[$ "item_medkit"] = new create_item_definition({
        id:          "item_medkit",
        name:        "First Aid Kit",
        description: "Medical kit. Restores 50 HP when used.",
        item_type:   ITEM_TYPE.CONSUMABLE,
        stackable:   true,
        max_stack:   5,
        value:       25,
        heal_amount: 50,
        icon_sprite: s_bandage_lg
    });

    global.ItemDatabase[$ "item_bandage"] = new create_item_definition({
        id:          "item_bandage",
        name:        "Bandage",
        description: "Small bandage. Restores 20 HP.",
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
        description: "Scrap metal parts, can be sold for cash.",
        item_type:   ITEM_TYPE.MATERIAL,
        stackable:   true,
        max_stack:   50,
        value:       5
    });

    global.ItemDatabase[$ "item_dog_tag"] = new create_item_definition({
        id:          "item_dog_tag",
        name:        "Dog Tag",
        description: "Dog tag of a fallen soldier.",
        item_type:   ITEM_TYPE.MATERIAL,
        stackable:   true,
        max_stack:   20,
        value:       15
    });

    // ── Key items (nhiệm vụ) ──────────────────────────────────────
    global.ItemDatabase[$ "item_generator_part"] = new create_item_definition({
        id:          "item_generator_part",
        name:        "Generator Part",
        description: "Generator component. Someone might need this.",
        item_type:   ITEM_TYPE.KEY_ITEM,
        stackable:   true,
        max_stack:   3,
        value:       0,
        is_tradable: false
    });

    // ── Trang bị (Equipment) ──────────────────────────────────────
    // 2. Nón (Helmet)
    global.ItemDatabase[$ "equip_helmet_tactical"] = new create_item_definition({
        id:          "equip_helmet_tactical",
        name:        "Tactical Helmet",
        description: "Head protection gear. Reduces headshot damage.",
        item_type:   ITEM_TYPE.HELMET,
        stackable:   false,
        max_stack:   1,
        size:        "1x1",
        value:       50,
        defense:     10
    });

    // 3. Giáp (Armor)
    global.ItemDatabase[$ "equip_armor_vest"] = new create_item_definition({
        id:          "equip_armor_vest",
        name:        "Kevlar Vest",
        description: "Body protection vest. Increases overall resistance.",
        item_type:   ITEM_TYPE.ARMOR,
        stackable:   false,
        max_stack:   1,
        size:        "2x2",
        value:       80,
        defense:     25
    });

    // 4. Đèn pin (Flashlight)
    global.ItemDatabase[$ "equip_flashlight_std"] = new create_item_definition({
        id:            "equip_flashlight_std",
        name:          "Tactical Flashlight",
        description:   "Standard issue military flashlight.",
        item_type:     ITEM_TYPE.FLASHLIGHT,
        stackable:     false,
        max_stack:     1,
        size:          "1x1",
        value:         40,
        flashlight_id: "flashlight_standard"
    });

    global.ItemDatabase[$ "equip_flashlight_wide"] = new create_item_definition({
        id:            "equip_flashlight_wide",
        name:          "Floodlight Torch",
        description:   "Wide beam flashlight for exploring dark zones.",
        item_type:     ITEM_TYPE.FLASHLIGHT,
        stackable:     false,
        max_stack:     1,
        size:          "1x1",
        value:         60,
        flashlight_id: "flashlight_wide"
    });

    // 5 & 6. Vũ khí (Weapons - Khai báo tỉ lệ ô theo chuỗi "WxH", ví dụ "3x2" hoặc "2x1")
    global.ItemDatabase[$ "equip_weapon_pistol"] = new create_item_definition({
        id:          "equip_weapon_pistol",
        name:        "FN Five-seveN",
        description: "Sidearm pistol with high accuracy.",
        item_type:   ITEM_TYPE.WEAPON,
        stackable:   false,
        max_stack:   1,
        size:        "2x1", // Chiếm 2 ô ngang, 1 ô dọc
        value:       100,
        weapon_id:   "pistol_fn57",
        icon_sprite: s_pistol_FN57
    });

    global.ItemDatabase[$ "equip_weapon_smg"] = new create_item_definition({
        id:          "equip_weapon_smg",
        name:        "FN P90",
        description: "High rate-of-fire submachine gun.",
        item_type:   ITEM_TYPE.WEAPON,
        stackable:   false,
        max_stack:   1,
        size:        "3x2", // Chiếm 3 ô ngang, 2 ô dọc
        value:       180,
        weapon_id:   "subgun_p90",
        icon_sprite: s_sub_P90
    });

    global.ItemDatabase[$ "equip_weapon_shotgun"] = new create_item_definition({
        id:          "equip_weapon_shotgun",
        name:        "TUS-34 Shotgun",
        description: "Heavy close-range shotgun.",
        item_type:   ITEM_TYPE.WEAPON,
        stackable:   false,
        max_stack:   1,
        size:        "3x2", // Chiếm 3 ô ngang, 2 ô dọc
        value:       220,
        weapon_id:   "shotgun_tus34",
        icon_sprite: s_shot_Tus34
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
