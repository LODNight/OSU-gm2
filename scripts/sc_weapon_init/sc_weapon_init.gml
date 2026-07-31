// ================================================================
// sc_weapon_init — Khởi tạo toàn bộ weapon registry
// Thứ tự: 1) Load JSON  2) Fallback GML nếu JSON thất bại
// ================================================================

function sc_weapon_init()
{
    // 1. Thử load từ JSON (ưu tiên)
    var _jsonOk = weapon_definitions_load();

    // 2. Fallback: nếu JSON không load được, dùng GML hardcode
    if (!_jsonOk || !variable_struct_exists(global.PlayerWeaponDefinitions, "pistol_fn57")) {
        show_debug_message("[sc_weapon_init] JSON load failed — using GML fallback.");
        sc_player_weapons();
    }

    if (!_jsonOk || !variable_struct_exists(global.EnemyWeapons, "e_pistol")) {
        sc_enemy_weapons();
    }

    // 3. Luôn load enemy definitions sau khi EnemyWeapons sẵn sàng
    sc_enemy_definitions();
}
