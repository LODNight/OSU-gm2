if (triggered && oneShot) exit;
if (!instance_exists(o_player)) exit;
if (nextRoom == noone) exit;

var _hit = false;
if (triggerRadius > 0) {
    _hit = point_distance(x, y, o_player.x, o_player.y) <= triggerRadius;
} else {
    _hit = place_meeting(x, y, o_player);
}

if (!_hit) exit;

triggered = true;
room_transition_begin(nextRoom, nextEntranceId);
room_goto(nextRoom);
