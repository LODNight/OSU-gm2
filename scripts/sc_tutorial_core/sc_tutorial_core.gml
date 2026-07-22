function tutorial_load_config()
{
    if (!variable_global_exists("TutorialDefinitions")) sc_tutorial_definitions();
    if (!variable_instance_exists(id, "tutorialId")) tutorialId = "movement_pickup";
    config = global.TutorialDefinitions[$ tutorialId];
    if (config == undefined) {
        show_debug_message("Tutorial id not found: " + string(tutorialId));
        instance_destroy();
        exit;
    }

    tutorialType = config.type;
    loadedTutorialId = tutorialId;
    activationRadius = config.activationRadius;
    message = config.message;
    active = false;
    completed = false;
    objectiveComplete = false;
    killCount = 0;
    tutorialSpawner = noone;
    completionTimer = 0;
}

function tutorial_activate()
{
    if (active) return;
    active = true;

    // The horde must always have a real exit gate in the room. Keeping this
    // check here makes a missing room setup obvious while testing.
    if (tutorialType == TUTORIAL_TYPE.ESCAPE_HORDE
        && !tutorial_exit_gate_exists(config.exitGateId)) {
        show_debug_message("Tutorial exit gate not found: " + config.exitGateId);
    }

    switch (tutorialType) {
        case TUTORIAL_TYPE.MOVE_AND_PICKUP:
            var _pickup = instance_create_depth(
                x + config.pickupOffsetX,
                y + config.pickupOffsetY,
                -y,
                o_tutorial_ammo
            );
            _pickup.tutorialOwner = id;
            _pickup.magAmount = config.pickupMags;
        break;

        case TUTORIAL_TYPE.CLEAR_ARENA:
        case TUTORIAL_TYPE.ESCAPE_HORDE:
            tutorial_start_spawner(config.spawnerZoneId);
        break;
    }
}

function tutorial_update()
{
    // Room Instance Creation Code runs after Create. Reload once when it changes tutorialId.
    if (loadedTutorialId != tutorialId) {
        tutorial_load_config();
        return;
    }

    if (completed) {
        if (completionTimer > 0) completionTimer--;
        return;
    }
    if (!instance_exists(o_player)) return;

    if (!active && tutorial_requirements_met()
        && point_distance(x, y, o_player.x, o_player.y) <= activationRadius) {
        tutorial_activate();
    }
    if (!active) return;

    switch (tutorialType) {
        case TUTORIAL_TYPE.MOVE_AND_PICKUP:
            if (objectiveComplete) tutorial_complete();
        break;

        case TUTORIAL_TYPE.CLEAR_ARENA:
            if (killCount >= config.requiredKills) tutorial_complete();
        break;

        case TUTORIAL_TYPE.ESCAPE_HORDE:
            tutorial_update_horde();
        break;
    }
}

function tutorial_update_horde()
{
    if (tutorial_player_reached_exit(config.exitGateId)) tutorial_complete();
}

function tutorial_requirements_met()
{
    if (!variable_struct_exists(config, "requiresTutorialId")) return true;
    return variable_struct_exists(global.TutorialProgress, config.requiresTutorialId)
        && global.TutorialProgress[$ config.requiresTutorialId];
}

function tutorial_start_spawner(_zoneId)
{
    tutorialSpawner = instance_create_depth(x, y, depth, o_spawner);
    tutorialSpawner.zoneId = _zoneId;
    tutorialSpawner.tutorialOwner = id;
}

/// @desc Called by enemy_die() only for enemies created by this tutorial.
function tutorial_register_enemy_kill()
{
    killCount++;
}

function tutorial_complete()
{
    if (completed) return;
    completed = true;
    completionTimer = 240;
    global.TutorialProgress[$ tutorialId] = true;

    if (instance_exists(tutorialSpawner)) with (tutorialSpawner) instance_destroy();

    if (tutorialType == TUTORIAL_TYPE.CLEAR_ARENA) tutorial_open_gates(config.gateId);
}

function tutorial_open_gates(_gateId)
{
    with (o_tutorial_gate) {
        if (gateId == _gateId) blocksPlayer = false;
    }
}

function tutorial_player_reached_exit(_gateId)
{
    var _reached = false;
    with (o_tutorial_gate) {
        if (gateId == _gateId && isExit && place_meeting(x, y, o_player)) _reached = true;
    }
    return _reached;
}

function tutorial_exit_gate_exists(_gateId)
{
    var _exists = false;
    with (o_tutorial_gate) {
        if (gateId == _gateId && isExit) _exists = true;
    }
    return _exists;
}

/// @desc Call from an o_tutorial_gate Instance Creation Code to make it the zone 3 exit.
/// The player may cross this gate; enemies remain confined inside zone 3.
function tutorial_configure_exit_gate()
{
    gateId = "tutorial_exit";
    isExit = true;
    blocksPlayer = false;
    blocksEnemies = true;
}

function tutorial_gate_blocks_player(_x, _y)
{
    var _gates = ds_list_create();
    instance_place_list(_x, _y, o_tutorial_gate, _gates, false);
    var _blocked = false;
    for (var i = 0; i < ds_list_size(_gates); i++) {
        if (_gates[| i].blocksPlayer) {
            _blocked = true;
            break;
        }
    }
    ds_list_destroy(_gates);
    return _blocked;
}

function tutorial_gate_blocks_enemy(_x, _y)
{
    var _gates = ds_list_create();
    instance_place_list(_x, _y, o_tutorial_gate, _gates, false);
    var _blocked = false;
    for (var i = 0; i < ds_list_size(_gates); i++) {
        if (_gates[| i].blocksEnemies) {
            _blocked = true;
            break;
        }
    }
    ds_list_destroy(_gates);
    return _blocked;
}

function tutorial_draw_message()
{
    if (!active && !completed) return;

    var _text = completed ? "TUTORIAL COMPLETE!" : message;
    if (!completed && tutorialType == TUTORIAL_TYPE.CLEAR_ARENA) {
        _text += " (" + string(killCount) + " / " + string(config.requiredKills) + ")";
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(0.75);
    draw_set_color(c_black);
    draw_rectangle(260, 22, display_get_gui_width() - 260, 76, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(display_get_gui_width() * 0.5, 49, _text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
