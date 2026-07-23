if (!variable_instance_exists(id, "nextRoom")) nextRoom = noone;
if (!variable_instance_exists(id, "nextEntranceId")) nextEntranceId = "default";
if (!variable_instance_exists(id, "triggerRadius")) triggerRadius = 0;
if (!variable_instance_exists(id, "oneShot")) oneShot = true;
if (!variable_instance_exists(id, "triggered")) triggered = false;

if (!variable_global_exists("RoomTransition")) room_transition_init();
