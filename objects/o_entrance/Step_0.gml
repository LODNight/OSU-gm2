if (spawnApplied) exit;
if (!variable_global_exists("RoomTransition")) {
    spawnApplied = true;
    exit;
}
if (!global.RoomTransition.active) {
    spawnApplied = true;
    exit;
}

// This entrance belongs to another room, so stop checking once the transition
// target does not match the current room.
if (global.RoomTransition.targetRoom != room) {
    spawnApplied = true;
    exit;
}

if (room_transition_apply_entrance(entranceId)) {
    spawnApplied = true;
}
