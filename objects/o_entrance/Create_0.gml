if (!variable_instance_exists(id, "entranceId")) entranceId = "default";
if (!variable_instance_exists(id, "labelText")) labelText = entranceId;
if (!variable_instance_exists(id, "spawnApplied")) spawnApplied = false;

if (!variable_global_exists("RoomTransition")) room_transition_init();
