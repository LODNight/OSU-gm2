_player_nearby = false;
if (triggered && oneShot) exit;
if (!instance_exists(o_player)) exit;

var _destRoom = noone;
if (variable_instance_exists(id, "goNext") && goNext != noone) {
    _destRoom = goNext;
} else if (variable_instance_exists(id, "nextRoom") && nextRoom != noone) {
    _destRoom = nextRoom;
} else if (variable_instance_exists(id, "targetRoom") && targetRoom != noone) {
    _destRoom = targetRoom;
}

if (_destRoom == noone) exit;

var _destEntrance = "default";
if (variable_instance_exists(id, "goNextId") && goNextId != "") {
    _destEntrance = goNextId;
} else if (variable_instance_exists(id, "nextEntranceId") && nextEntranceId != "" && nextEntranceId != "default") {
    _destEntrance = nextEntranceId;
} else if (variable_instance_exists(id, "targetEntranceId") && targetEntranceId != "") {
    _destEntrance = targetEntranceId;
}

var _hit = false;
if (triggerRadius > 0) {
    _hit = point_distance(x, y, o_player.x, o_player.y) <= triggerRadius;
} else {
    _hit = place_meeting(x, y, o_player);
}

if (!_hit) exit;

_player_nearby = true;

if (keyboard_check_pressed(ord("F"))) {
    triggered = true;
    room_transition_begin(_destRoom, _destEntrance);
    room_goto(_destRoom);
}
