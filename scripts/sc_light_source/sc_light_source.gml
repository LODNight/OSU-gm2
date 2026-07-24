// ============================================================
// sc_light_source — Quản lý danh sách nguồn sáng tĩnh
// ============================================================
// Mỗi o_light_source gọi light_source_register() trong Create
// và light_source_unregister() trong CleanUp.
//
// Vẽ bởi o_lighting_controller — chỉ vẽ đèn trong camera view.
// ============================================================

/// @function light_source_global_init()
/// @description Khởi tạo ds_list toàn cục. Gọi từ o_lighting_controller Create.
function light_source_global_init() {
    if (!variable_global_exists("LightSources")) {
        global.LightSources = ds_list_create();
    }
}

/// @function light_source_register(_inst, _config)
/// @description Đăng ký một instance làm nguồn sáng tĩnh.
/// @param {Id.Instance} _inst   instance đăng ký (thường là self)
/// @param {struct}      _config { range, light_r, light_g, light_b, intensity, cast_shadows }
function light_source_register(_inst, _config) {
    light_source_global_init();

    var _entry = {
        ref           : _inst,
        range         : variable_struct_exists(_config, "range")         ? _config.range         : 160,
        light_r       : variable_struct_exists(_config, "light_r")       ? _config.light_r       : 255,
        light_g       : variable_struct_exists(_config, "light_g")       ? _config.light_g       : 200,
        light_b       : variable_struct_exists(_config, "light_b")       ? _config.light_b       : 100,
        intensity     : variable_struct_exists(_config, "intensity")     ? _config.intensity     : 0.6,
        cast_shadows  : variable_struct_exists(_config, "cast_shadows")  ? _config.cast_shadows  : false,
    };

    ds_list_add(global.LightSources, _entry);
}

/// @function light_source_unregister(_inst)
/// @description Xóa instance khỏi danh sách đèn. Gọi từ CleanUp.
/// @param {Id.Instance} _inst
function light_source_unregister(_inst) {
    if (!variable_global_exists("LightSources")) return;

    var _n = ds_list_size(global.LightSources);
    for (var i = _n - 1; i >= 0; i--) {
        var _entry = global.LightSources[| i];
        if (_entry.ref == _inst) {
            ds_list_delete(global.LightSources, i);
            break;
        }
    }
}
