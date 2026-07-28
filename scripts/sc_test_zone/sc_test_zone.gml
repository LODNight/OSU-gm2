// ================================================================
// sc_test_zone — Logic kích hoạt và reset từng loại test
// ================================================================
// Chỉ hoạt động trong rm_test.
// Gọi test_zone_activate(type, origin_x, origin_y) khi player bước qua o_test_start.
// Gọi test_zone_reset(type) khi player bước qua o_test_end.
// ================================================================

/// @enum TEST_TYPE — Danh sách các loại test zone
enum TEST_TYPE {
    LIGHTING   = 1,   // Test hệ thống ánh sáng / đèn pin
    COMBAT     = 2,   // Test combat / enemy spawn
    LOOT       = 3,   // Test hệ thống loot
    DIALOGUE   = 4,   // Test NPC / dialogue
    CAMERA     = 5,   // Test camera zoom bằng scroll wheel
}

// ── Global tracking cho active test ────────────────────────────
// Được khởi tạo lần đầu khi o_test_start được tạo
function test_zone_global_init() {
    if (!variable_global_exists("TestZone")) {
        global.TestZone = {
            active_type          : -1,    // TEST_TYPE đang chạy (-1 = không có)
            origin_x             : 0,     // Vị trí X của o_test_start được trigger
            origin_y             : 0,     // Vị trí Y của o_test_start được trigger
            spawned_ids          : [],    // Instance IDs được tạo trong test
            camera_zoom_enabled  : false, // Cho phép scroll-wheel zoom (TEST_TYPE.CAMERA)
            camera_zoom_base_w   : -1,   // View width gốc trước khi test
            camera_zoom_base_h   : -1,   // View height gốc trước khi test
        };
    }
}

// ────────────────────────────────────────────────────────────────
/// @function test_zone_activate(_type, _ox, _oy)
/// @description Kích hoạt test zone khi player bước qua o_test_start.
/// @param {real} _type   TEST_TYPE enum
/// @param {real} _ox     Vị trí X gốc của o_test_start
/// @param {real} _oy     Vị trí Y gốc của o_test_start
function test_zone_activate(_type, _ox, _oy) {
    if (!variable_global_exists("TestZone")) test_zone_global_init();

    global.TestZone.active_type = _type;
    global.TestZone.origin_x    = _ox;
    global.TestZone.origin_y    = _oy;
    global.TestZone.spawned_ids = [];  // Reset danh sách mỗi lần test mới

    switch (_type) {
        case TEST_TYPE.LIGHTING:
            _test_lighting_start();
            break;
        case TEST_TYPE.CAMERA:
            _test_camera_start();
            break;
        case TEST_TYPE.COMBAT:
            _test_combat_start();
            break;
        case TEST_TYPE.LOOT:
            _test_loot_start();
            break;
        case TEST_TYPE.DIALOGUE:
            _test_dialogue_start();
            break;
    }

    show_debug_message("[TestZone] Activated: " + string(_type) + " at (" + string(_ox) + "," + string(_oy) + ")");
}

// ────────────────────────────────────────────────────────────────
/// @function test_zone_reset(_type)
/// @description Cleanup test và reset mọi thứ khi player bước qua o_test_end.
/// @param {real} _type   TEST_TYPE đang được reset
function test_zone_reset(_type) {
    if (!variable_global_exists("TestZone")) return;

    // Destroy tất cả instance được tạo bởi test này
    var _ids = global.TestZone.spawned_ids;
    for (var i = 0; i < array_length(_ids); i++) {
        if (instance_exists(_ids[i])) {
            instance_destroy(_ids[i]);
        }
    }
    global.TestZone.spawned_ids = [];

    switch (_type) {
        case TEST_TYPE.LIGHTING:
            _test_lighting_reset();
            break;
        case TEST_TYPE.CAMERA:
            _test_camera_reset();
            break;
        case TEST_TYPE.COMBAT:
            _test_combat_reset();
            break;
        case TEST_TYPE.LOOT:
            _test_loot_reset();
            break;
        case TEST_TYPE.DIALOGUE:
            _test_dialogue_reset();
            break;
    }

    global.TestZone.active_type = -1;
    show_debug_message("[TestZone] Reset: " + string(_type));
}

// ────────────────────────────────────────────────────────────────
/// @function test_zone_register(_inst_id)
/// @description Đăng ký một instance vào danh sách cleanup của test hiện tại.
/// @param {Id.Instance} _inst_id
function test_zone_register(_inst_id) {
    if (!variable_global_exists("TestZone")) return;
    array_push(global.TestZone.spawned_ids, _inst_id);
}


// ================================================================
// == LIGHTING TEST ===============================================
// ================================================================

function _test_lighting_start() {
    if (!instance_exists(o_lighting_controller)) return;

    with (o_lighting_controller) {
        // Bật chế độ tối như phòng hầm ngầm
        darkness_alpha   = 0.92;
        darkness_color   = c_black;
        lighting_enabled = true;
        flashlight_enabled = true;

        // Free surface cũ để render lại với setting mới
        if (surface_exists(dark_surface))  surface_free(dark_surface);
        if (surface_exists(light_surface)) surface_free(light_surface);
        dark_surface  = -1;
        light_surface = -1;
    }
}

function _test_lighting_reset() {
    if (!instance_exists(o_lighting_controller)) return;

    // Đọc lại config mặc định của rm_test từ registry
    var _cfg = room_lighting_get(room);
    with (o_lighting_controller) {
        darkness_alpha   = _cfg.darkness_alpha;
        darkness_color   = _cfg.darkness_color;
        lighting_enabled = _cfg.lighting_enabled;
        flashlight_enabled = false;

        if (surface_exists(dark_surface))  surface_free(dark_surface);
        if (surface_exists(light_surface)) surface_free(light_surface);
        dark_surface  = -1;
        light_surface = -1;
    }
}


// ================================================================
// == CAMERA ZOOM TEST ============================================
// ================================================================

/// @desc Bật chế độ cho phép scroll-wheel zoom camera.
function _test_camera_start() {
    if (!variable_global_exists("TestZone")) return;

    // Lưu kích thước view gốc để reset về sau
    global.TestZone.camera_zoom_base_w = camera_get_view_width(view_camera[0]);
    global.TestZone.camera_zoom_base_h = camera_get_view_height(view_camera[0]);
    global.TestZone.camera_zoom_enabled = true;

    show_debug_message("[TestZone] Camera zoom ENABLED. Scroll to zoom.");
}

/// @desc Tắt scroll-wheel zoom và khôi phục kích thước camera gốc.
function _test_camera_reset() {
    if (!variable_global_exists("TestZone")) return;

    global.TestZone.camera_zoom_enabled = false;

    // Khôi phục kích thước view ban đầu
    var _bw = global.TestZone.camera_zoom_base_w;
    var _bh = global.TestZone.camera_zoom_base_h;
    if (_bw > 0 && _bh > 0) {
        camera_set_view_size(view_camera[0], _bw, _bh);
    }

    global.TestZone.camera_zoom_base_w = -1;
    global.TestZone.camera_zoom_base_h = -1;

    show_debug_message("[TestZone] Camera zoom DISABLED. View restored.");
}


// ================================================================
// == COMBAT TEST =================================================
// ================================================================

function _test_combat_start() {
    var _spawner = instance_create_depth(1419, 968, 0, o_spawner, { zoneId: "tutorial_shooting" });
    test_zone_register(_spawner);
    show_debug_message("[TestZone] Combat test: spawned o_spawner at 1419, 968 with zoneId 'tutorial_shooting'");
}

function _test_combat_reset() {
    show_debug_message("[TestZone] Combat test: reset and despawned");
}


// ================================================================
// == LOOT TEST (placeholder) =====================================
// ================================================================

function _test_loot_start() {
    show_debug_message("[TestZone] Loot test: placeholder");
}

function _test_loot_reset() {
    // Xóa xác / loot item còn lại nếu cần
}


// ================================================================
// == DIALOGUE TEST (placeholder) =================================
// ================================================================

function _test_dialogue_start() {
    show_debug_message("[TestZone] Dialogue test: placeholder");
}

function _test_dialogue_reset() {
    // Xóa NPC tạm nếu cần
}
