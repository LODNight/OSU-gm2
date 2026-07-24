/// @function enemy_inside_flashlight(_enemy)
/// @description Kiểm tra enemy có nằm trong vùng sáng của đèn pin Player không.
/// @param {Id.Instance} _enemy
/// @returns {bool}

function enemy_inside_flashlight(_enemy) {
    if (!instance_exists(o_player))             return false;
    if (!instance_exists(o_lighting_controller)) return false;
    if (!o_lighting_controller.flashlight_enabled) return false;
    if (!o_lighting_controller.lighting_enabled)   return false;

    var _player_x = o_player.x;
    var _player_y = o_player.y;

    // Đọc range/angle từ item definition của player
    var _def = variable_instance_exists(o_player, "flashlightItem")
             ? o_player.flashlightItem : noone;

    var _range = (_def != noone) ? _def.range : 420;
    var _angle = (_def != noone) ? _def.angle : 55;
    var _is_360 = (_angle >= 360);

    var _enemy_distance = point_distance(
        _player_x, _player_y,
        _enemy.x,  _enemy.y
    );

    if (_enemy_distance > _range) return false;

    // Đèn 360° (Lantern) — không cần check góc
    if (_is_360) {
        return check_los_tilemap(
            _player_x, _player_y,
            _enemy.x,  _enemy.y
        );
    }

    // Đèn định hướng — check góc so với hướng chuột
    var _flashlight_dir = point_direction(
        _player_x, _player_y,
        mouse_x,   mouse_y
    );
    var _enemy_dir = point_direction(
        _player_x, _player_y,
        _enemy.x,  _enemy.y
    );
    var _angle_diff = abs(angle_difference(_flashlight_dir, _enemy_dir));

    if (_angle_diff > _angle * 0.5) return false;

    return check_los_tilemap(
        _player_x, _player_y,
        _enemy.x,  _enemy.y
    );
}