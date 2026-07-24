/// @function enemy_inside_flashlight(_enemy)
/// @returns Boolean

function enemy_inside_flashlight(_enemy) {
    if (!instance_exists(o_player)) {
        return false;
    }

    if (!o_lighting_controller.flashlight_enabled) {
        return false;
    }

    var _player_x = o_player.x;
    var _player_y = o_player.y;

    var _enemy_distance = point_distance(
        _player_x,
        _player_y,
        _enemy.x,
        _enemy.y
    );

    if (
        _enemy_distance
        > o_lighting_controller.flashlight_range
    ) {
        return false;
    }

    var _flashlight_direction = point_direction(
        _player_x,
        _player_y,
        mouse_x,
        mouse_y
    );

    var _enemy_direction = point_direction(
        _player_x,
        _player_y,
        _enemy.x,
        _enemy.y
    );

    var _angle_difference = abs(
        angle_difference(
            _flashlight_direction,
            _enemy_direction
        )
    );

    if (
        _angle_difference
        > o_lighting_controller.flashlight_angle * 0.5
    ) {
        return false;
    }

    return check_los_tilemap(
        _player_x,
        _player_y,
        _enemy.x,
        _enemy.y
    );
}