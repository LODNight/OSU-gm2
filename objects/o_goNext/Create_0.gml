if (!variable_instance_exists(id, "goNext")) goNext = noone;
if (!variable_instance_exists(id, "nextRoom")) nextRoom = goNext;
if (!variable_instance_exists(id, "targetRoom")) targetRoom = nextRoom;

if (!variable_instance_exists(id, "goNextId")) goNextId = "";
if (!variable_instance_exists(id, "nextEntranceId")) nextEntranceId = (goNextId != "") ? goNextId : "default";
if (!variable_instance_exists(id, "targetEntranceId")) targetEntranceId = nextEntranceId;

if (!variable_instance_exists(id, "triggerRadius")) triggerRadius = 0;
if (!variable_instance_exists(id, "oneShot")) oneShot = false;
if (!variable_instance_exists(id, "triggered")) triggered = false;
if (!variable_instance_exists(id, "promptText")) promptText = "[F] to go";

_player_nearby = false;
visible = true;

if (!variable_global_exists("RoomTransition")) room_transition_init();
