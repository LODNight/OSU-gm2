if (!instance_exists(o_player)) exit;
if (point_distance(x, y, o_player.x, o_player.y) <= 28 && global.interactPressed) {
    if (o_player.weapon != noone) weapon_add_mags(o_player.weapon, magAmount);
    if (instance_exists(tutorialOwner)) tutorialOwner.objectiveComplete = true;
    instance_destroy();
}
