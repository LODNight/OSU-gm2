// ============================================================
// o_lighting_controller — Draw End Event
// ============================================================

if (!instance_exists(o_player)) {
    exit;
}

var _cam = view_camera[0];

var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);

var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

// ------------------------------------------------------------
// Surface validation
// ------------------------------------------------------------

if (
    !surface_exists(dark_surface)
    || surface_get_width(dark_surface) != _cam_w
    || surface_get_height(dark_surface) != _cam_h
) {
    if (surface_exists(dark_surface)) {
        surface_free(dark_surface);
    }

    dark_surface = surface_create(_cam_w, _cam_h);
}

// ------------------------------------------------------------
// Create darkness mask
// ------------------------------------------------------------

surface_set_target(dark_surface);

draw_clear_alpha(
    darkness_color,
    darkness_alpha
);

// ------------------------------------------------------------
// Draw flashlight into darkness mask
// ------------------------------------------------------------

    var _player_x = o_player.x;
    var _player_y = o_player.y;

    var _surface_x = _player_x - _cam_x;
    var _surface_y = _player_y - _cam_y;

    lighting_blend_erase_begin();

    // Luôn vẽ ánh sáng mờ xung quanh Player để có thể nhìn thấy bản thân
    draw_ambient_light(_surface_x, _surface_y, 72, 32);

    if (flashlight_enabled) {
        var _direction = point_direction(
            _player_x,
            _player_y,
            mouse_x,
            mouse_y
        );

        draw_flashlight_visibility_polygon(
            global.collision_tilemap,
            _player_x,
            _player_y,
            _surface_x,
            _surface_y,
            _direction,
            flashlight_range,
            flashlight_angle,
            flashlight_rays,
            ray_step
        );
    }

    lighting_blend_erase_end();

surface_reset_target();

// ------------------------------------------------------------
// Draw darkness over world
// ------------------------------------------------------------

draw_surface(
    dark_surface,
    _cam_x,
    _cam_y
);

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);