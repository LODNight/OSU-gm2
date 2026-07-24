// ============================================================
// o_lighting_controller — Draw End Event (73)
// ============================================================
// Pipeline:
//   1. Validate/resize cả hai surface
//   2. Vẽ light_surface — colored glow của đèn tĩnh (additive)
//   3. Vẽ dark_surface  — bóng tối + punch flashlight hole
//   4. Composite: light_surface (bm_add) → dark_surface (bm_normal)
// ============================================================

if (!lighting_enabled) exit;
if (!instance_exists(o_player)) exit;

var _cam   = view_camera[0];
var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

// ── 1. Validate surfaces ──────────────────────────────────────

if (!surface_exists(dark_surface)
    || surface_get_width(dark_surface)  != _cam_w
    || surface_get_height(dark_surface) != _cam_h
) {
    if (surface_exists(dark_surface)) surface_free(dark_surface);
    dark_surface = surface_create(_cam_w, _cam_h);
}

if (!surface_exists(light_surface)
    || surface_get_width(light_surface)  != _cam_w
    || surface_get_height(light_surface) != _cam_h
) {
    if (surface_exists(light_surface)) surface_free(light_surface);
    light_surface = surface_create(_cam_w, _cam_h);
}

// ── 2. Lấy thông số đèn pin từ item của Player ───────────────

var _player_x  = o_player.x;
var _player_y  = o_player.y;
var _surface_x = _player_x - _cam_x;
var _surface_y = _player_y - _cam_y;

var _def = (variable_instance_exists(o_player, "flashlightItem"))
         ? o_player.flashlightItem : noone;

var _range    = (_def != noone) ? _def.range     : 420;
var _angle    = (_def != noone) ? _def.angle     : 55;
var _rays     = (_def != noone) ? _def.rays      : 60;
var _ray_step = (_def != noone) ? _def.ray_step  : 2;
var _amb_r    = (_def != noone) ? _def.ambient_r : 72;
var _is_360   = (_angle >= 360);

// ── 3. Vẽ light_surface — colored glow đèn tĩnh + player flashlight ─────────────

surface_set_target(light_surface);
draw_clear_alpha(c_black, 0);  // transparent hoàn toàn

// Blend cộng màu (additive) — ánh sáng cộng thêm vào thế giới
gpu_set_blendmode(bm_add);

// A. Vẽ player flashlight color overlay
if (flashlight_enabled) {
    var _light_color = (_def != noone)
        ? make_color_rgb(_def.light_r, _def.light_g, _def.light_b)
        : c_white;
    var _intensity = (_def != noone) ? _def.intensity : 0.85;

    if (_is_360) {
        // Đèn Bão — toàn hướng
        draw_colored_point_light(_surface_x, _surface_y, _range, 72, _light_color, _intensity);
    } else {
        var _direction = point_direction(
            _player_x, _player_y,
            mouse_x,   mouse_y
        );
        draw_flashlight_visibility_polygon(
            global.collision_tilemap,
            _player_x, _player_y,
            _surface_x, _surface_y,
            _direction,
            _range, _angle, _rays, _ray_step,
            _light_color,
            _intensity
        );
    }
}

// B. Vẽ các nguồn sáng tĩnh
if (variable_global_exists("LightSources")) {
    var _n = ds_list_size(global.LightSources);

    for (var i = 0; i < _n; i++) {
        var _ls  = global.LightSources[| i];
        var _ref = _ls.ref;

        // Bỏ qua nếu instance không còn tồn tại
        if (!instance_exists(_ref)) continue;

        var _lx = _ref.x;
        var _ly = _ref.y;

        // ── Camera frustum culling ────────────────────────────
        // Chỉ vẽ đèn nếu vòng tròn ánh sáng chạm vào camera view
        var _r = _ls.range;
        if (_lx + _r < _cam_x) continue;
        if (_lx - _r > _cam_x + _cam_w) continue;
        if (_ly + _r < _cam_y) continue;
        if (_ly - _r > _cam_y + _cam_h) continue;

        var _sx = _lx - _cam_x;
        var _sy = _ly - _cam_y;
        var _col = make_color_rgb(_ls.light_r, _ls.light_g, _ls.light_b);

        draw_colored_point_light(_sx, _sy, _r, 48, _col, _ls.intensity);
    }
}

gpu_set_blendmode(bm_normal);
surface_reset_target();

// ── 4. Vẽ dark_surface — bóng tối + punch holes ──────────────

surface_set_target(dark_surface);
draw_clear_alpha(darkness_color, darkness_alpha);

// Erase blend — punch holes (transparent = vùng sáng)
gpu_set_blendmode_ext(bm_zero, bm_inv_src_alpha);

// Luôn vẽ ambient glow nhỏ quanh player (có thể nhìn thấy bản thân)
draw_ambient_light(_surface_x, _surface_y, _amb_r, 32);

// Vẽ flashlight cone nếu bật
if (flashlight_enabled) {
    if (_is_360) {
        // Đèn Bão — toàn hướng
        draw_ambient_light(_surface_x, _surface_y, _range, 72);
    } else {
        var _direction = point_direction(
            _player_x, _player_y,
            mouse_x,   mouse_y
        );
        draw_flashlight_visibility_polygon(
            global.collision_tilemap,
            _player_x, _player_y,
            _surface_x, _surface_y,
            _direction,
            _range, _angle, _rays, _ray_step
        );
    }
}

// Cũng punch holes tại vị trí đèn tĩnh để thế giới lộ ra dưới glow màu
if (variable_global_exists("LightSources")) {
    var _n = ds_list_size(global.LightSources);
    for (var i = 0; i < _n; i++) {
        var _ls  = global.LightSources[| i];
        var _ref = _ls.ref;
        if (!instance_exists(_ref)) continue;

        var _lx = _ref.x;
        var _ly = _ref.y;
        var _r  = _ls.range;

        // Camera frustum culling (trùng với light_surface)
        if (_lx + _r < _cam_x) continue;
        if (_lx - _r > _cam_x + _cam_w) continue;
        if (_ly + _r < _cam_y) continue;
        if (_ly - _r > _cam_y + _cam_h) continue;

        var _sx = _lx - _cam_x;
        var _sy = _ly - _cam_y;

        // Punch hole với bán kính nhỏ hơn glow để bóng tối vẫn có ở viền
        draw_ambient_light(_sx, _sy, _r * 0.6, 36);
    }
}

gpu_set_blendmode(bm_normal);
surface_reset_target();

// ── 5. Composite lên màn hình ────────────────────────────────

// 5a. Glow màu đèn tĩnh (additive — sáng thêm)
gpu_set_blendmode(bm_add);
draw_surface(light_surface, _cam_x, _cam_y);
gpu_set_blendmode(bm_normal);

// 5b. Lớp bóng tối đục (có punch holes từ flashlight + đèn tĩnh)
draw_surface(dark_surface, _cam_x, _cam_y);

// Reset state
draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);