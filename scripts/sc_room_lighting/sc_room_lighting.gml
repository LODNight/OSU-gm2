// ============================================================
// sc_room_lighting — Cấu hình độ tối riêng cho từng room
// ============================================================
// Gọi sc_room_lighting_init() từ o_init.
//
// darkness_alpha: 0.0 = sáng bình thường, 1.0 = tối hoàn toàn
// darkness_color: màu nền bóng tối (thường là c_black)
// lighting_enabled: false → không vẽ lighting system (room ngoài trời / an toàn)
// ============================================================

/// @function sc_room_lighting_init()
function sc_room_lighting_init() {
    global.RoomLighting = {};

    // ── Rooms với lighting system ──────────────────────────────

    // Tutorial: tối chuẩn, đủ tối để cảm nhận hệ thống đèn
    variable_struct_set(global.RoomLighting, "rm_tutorial", {
        darkness_alpha   : 0.92,
        darkness_color   : c_black,
        lighting_enabled : true,
    });

    // Demo 1: tối bình thường
    variable_struct_set(global.RoomLighting, "rm_demo1", {
        darkness_alpha   : 0.90,
        darkness_color   : c_black,
        lighting_enabled : true,
    });

    // Mall: khu thương mại bỏ hoang — tối hơn một chút
    variable_struct_set(global.RoomLighting, "rm_mall", {
        darkness_alpha   : 0.95,
        darkness_color   : c_black,
        lighting_enabled : true,
    });

    // Street Bacon: ngoài đường đêm — bầu trời tím nhạt
    variable_struct_set(global.RoomLighting, "rm_streetBacon", {
        darkness_alpha   : 0.75,
        darkness_color   : make_color_rgb(10, 10, 30),
        lighting_enabled : true,
    });

    // Test room: tối nhẹ để debug
    variable_struct_set(global.RoomLighting, "rm_test", {
        darkness_alpha   : 0.85,
        darkness_color   : c_black,
        lighting_enabled : true,
    });

    // ── Rooms không có lighting (sáng bình thường) ─────────────

    // Main Base: nơi an toàn, ánh sáng đầy đủ
    variable_struct_set(global.RoomLighting, "rm_mainBase", {
        darkness_alpha   : 0.0,
        darkness_color   : c_black,
        lighting_enabled : false,
    });

    // Setup room (chỉ chạy init): không cần lighting
    variable_struct_set(global.RoomLighting, "rm_setup", {
        darkness_alpha   : 0.0,
        darkness_color   : c_black,
        lighting_enabled : false,
    });
}

/// @function room_lighting_get(_room)
/// @description Trả về struct config của room, hoặc default nếu chưa đăng ký.
/// @param {Asset.GMRoom} _room
/// @returns {struct}
function room_lighting_get(_room) {
    var _key = room_get_name(_room);

    if (variable_global_exists("RoomLighting")
        && variable_struct_exists(global.RoomLighting, _key)
    ) {
        return variable_struct_get(global.RoomLighting, _key);
    }

    // Fallback an toàn — tối chuẩn
    return {
        darkness_alpha   : 0.90,
        darkness_color   : c_black,
        lighting_enabled : true,
    };
}
