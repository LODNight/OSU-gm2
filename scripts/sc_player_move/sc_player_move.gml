function player_move()
{
    var _horizontal = right - left;
    var _vertical = down - up;
    moveDir = point_direction(0, 0, _horizontal, _vertical);

    var _inputLevel = clamp(point_distance(0, 0, _horizontal, _vertical), 0, 1);
    xspd = lengthdir_x(spd * _inputLevel, moveDir);
    yspd = lengthdir_y(spd * _inputLevel, moveDir);

    if (place_meeting(x + xspd, y, [tile_wall, o_wall, o_wall_colli])) xspd = 0;
    if (place_meeting(x, y + yspd, [tile_wall, o_wall, o_wall_colli])) yspd = 0;
    x += xspd;
    y += yspd;
}
