if (!instance_exists(o_player)) {
    exit;
}

var _distance = point_distance(x, y, o_player.x, o_player.y);
var _near_player = _distance <= interaction_range;

if (_near_player && can_interact) {
    if (keyboard_check_pressed(ord("E"))) {
        npc_interact(id);
    }
}