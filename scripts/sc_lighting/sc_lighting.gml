/// @function draw_flashlight_cone(_x, _y, _direction, _range, _angle, _rays)
/// @description Vẽ vùng sáng hình nón chưa bị vật cản che
///
/// @param _x
/// @param _y
/// @param _direction
/// @param _range
/// @param _angle
/// @param _rays

function draw_flashlight_cone(
    _x,
    _y,
    _direction,
    _range,
    _angle,
    _rays
) {
    var _start_angle = _direction - (_angle * 0.5);
    var _angle_step  = _angle / _rays;

    draw_primitive_begin(pr_trianglefan);

    // Tâm đèn pin
    draw_vertex(_x, _y);

    for (var i = 0; i <= _rays; i++) {
        var _ray_angle = _start_angle + (i * _angle_step);

        var _end_x = _x + lengthdir_x(_range, _ray_angle);
        var _end_y = _y + lengthdir_y(_range, _ray_angle);

        draw_vertex(_end_x, _end_y);
    }

    draw_primitive_end();
}

function lighting_blend_erase_begin() {
    gpu_set_blendmode_ext(
        bm_zero,
        bm_inv_src_alpha
    );
}

function lighting_blend_erase_end() {
    gpu_set_blendmode(bm_normal);
}


/// @function flashlight_raycast_tilemap(
///     _tilemap,
///     _start_x,
///     _start_y,
///     _direction,
///     _max_distance,
///     _step
/// )
///
/// @returns Struct { x, y, distance, hit }
function flashlight_raycast_tilemap(
    _tilemap,
    _start_x,
    _start_y,
    _direction,
    _max_distance,
    _step
) {
    var _result_x = _start_x;
    var _result_y = _start_y;

    for (
        var _distance = 0;
        _distance <= _max_distance;
        _distance += _step
    ) {
        var _check_x =
            _start_x + lengthdir_x(_distance, _direction);

        var _check_y =
            _start_y + lengthdir_y(_distance, _direction);

        var _tile_data = 0;
        if (_tilemap != -1) {
            _tile_data = tilemap_get_at_pixel(_tilemap, _check_x, _check_y);
        }

        if (_tile_data != 0) {
            return {
                x: _result_x,
                y: _result_y,
                distance: max(0, _distance - _step),
                hit: true
            };
        }

        _result_x = _check_x;
        _result_y = _check_y;
    }

    return {
        x: _result_x,
        y: _result_y,
        distance: _max_distance,
        hit: false
    };
}
/// @function draw_flashlight_visibility_polygon(
///     _tilemap,
///     _world_x,
///     _world_y,
///     _surface_x,
///     _surface_y,
///     _direction,
///     _range,
///     _angle,
///     _rays,
///     _ray_step
/// )

function draw_flashlight_visibility_polygon(
    _tilemap,
    _world_x,
    _world_y,
    _surface_x,
    _surface_y,
    _direction,
    _range,
    _angle,
    _rays,
    _ray_step
) {
    var _start_angle = _direction - (_angle * 0.5);
    var _angle_step  = _angle / _rays;

    draw_primitive_begin(pr_trianglefan);

    draw_vertex_color(
        _surface_x,
        _surface_y,
        c_white,
        1
    );

    for (var i = 0; i <= _rays; i++) {
        var _ray_angle =
            _start_angle + (i * _angle_step);

        var _hit = flashlight_raycast_tilemap(
            _tilemap,
            _world_x,
            _world_y,
            _ray_angle,
            _range,
            _ray_step
        );

        // Đổi world coordinate sang surface coordinate
        var _vertex_x =
            _surface_x + (_hit.x - _world_x);

        var _vertex_y =
            _surface_y + (_hit.y - _world_y);

        // Có thể giảm alpha ở phía xa
        var _distance_ratio =
            clamp(_hit.distance / _range, 0, 1);

        var _edge_alpha =
            lerp(1, 0.15, _distance_ratio);

        draw_vertex_color(
            _vertex_x,
            _vertex_y,
            c_white,
            _edge_alpha
        );
    }

    draw_primitive_end();
}

/// @function draw_ambient_light(_x, _y, _radius, _segments)
/// @description Vẽ một vòng sáng mờ xung quanh vị trí với alpha giảm dần ra viền
function draw_ambient_light(_x, _y, _radius, _segments) {
    var _angle_step = 360 / _segments;
    
    draw_primitive_begin(pr_trianglefan);
    
    // Tâm sáng
    draw_vertex_color(_x, _y, c_white, 0.85);
    
    // Các đỉnh viền (alpha = 0)
    for (var i = 0; i <= _segments; i++) {
        var _angle = i * _angle_step;
        var _vx = _x + lengthdir_x(_radius, _angle);
        var _vy = _y + lengthdir_y(_radius, _angle);
        draw_vertex_color(_vx, _vy, c_white, 0);
    }
    
    draw_primitive_end();
}

