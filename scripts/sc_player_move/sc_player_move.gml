function player_move()
{
    var _horizontal = right - left;
    var _vertical   = down  - up;
    moveDir = point_direction(0, 0, _horizontal, _vertical);

    // Lấy tốc độ thực tế từ Module Stamina (walk / sprint / giảm dần khi kiệt sức)
    var _currentSpd  = stamina_get_speed();
    var _inputLevel  = clamp(point_distance(0, 0, _horizontal, _vertical), 0, 1);
    xspd = lengthdir_x(_currentSpd * _inputLevel, moveDir);
    yspd = lengthdir_y(_currentSpd * _inputLevel, moveDir);

    if (place_meeting(x + xspd, y, [tile_wall, tile_item, o_wall, o_wall_colli])
        || tutorial_gate_blocks_player(x + xspd, y)) xspd = 0;
    if (place_meeting(x, y + yspd, [tile_wall, tile_item, o_wall, o_wall_colli])
        || tutorial_gate_blocks_player(x, y + yspd)) yspd = 0;
    x += xspd;
    y += yspd;
}
