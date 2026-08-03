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
        case TUTORIAL_TYPE.MOVE_AND_SPRINT:
        case TUTORIAL_TYPE.LOOT_AND_INVENTORY:
            // Khong can spawner zombie
        break;

        case TUTORIAL_TYPE.CLEAR_ARENA:
        case TUTORIAL_TYPE.ESCAPE_HORDE:
            if (variable_struct_exists(config, "spawnerZoneId")) {
                tutorial_start_spawner(config.spawnerZoneId);
            }
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
        case TUTORIAL_TYPE.MOVE_AND_SPRINT:
            var _wasd = (keyboard_check(ord("W")) || keyboard_check(ord("A")) || keyboard_check(ord("S")) || keyboard_check(ord("D")));
            var _shift = keyboard_check(vk_shift);
            if (_wasd) hasMoved = true;
            if (_shift) hasSprinted = true;

            var _m = variable_instance_exists(id, "hasMoved") && hasMoved;
            var _s = variable_instance_exists(id, "hasSprinted") && hasSprinted;
            if ((_m && _s) || objectiveComplete || point_distance(x, y, o_player.x, o_player.y) > activationRadius + 120) {
                tutorial_complete();
            }
        break;

        case TUTORIAL_TYPE.CLEAR_ARENA:
            if (killCount >= config.requiredKills) tutorial_complete();
        break;

        case TUTORIAL_TYPE.LOOT_AND_INVENTORY:
            var _invOpen = (variable_global_exists("InventoryOpen") && global.InventoryOpen);
            var _distOut = (point_distance(x, y, o_player.x, o_player.y) > activationRadius + 120);
            if (_invOpen || objectiveComplete || _distOut) {
                tutorial_complete();
            }
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
    var _req = config.requiresTutorialId;
    if (variable_struct_exists(global.TutorialProgress, _req) && global.TutorialProgress[$ _req]) return true;

    if (_req == "movement" && variable_struct_exists(global.TutorialProgress, "movement_pickup") && global.TutorialProgress[$ "movement_pickup"]) return true;
    if (_req == "aim_shoot" && variable_struct_exists(global.TutorialProgress, "shooting_range") && global.TutorialProgress[$ "shooting_range"]) return true;
    if (_req == "loot_inventory" && variable_struct_exists(global.TutorialProgress, "loot_inventory") && global.TutorialProgress[$ "loot_inventory"]) return true;

    return false;
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

    // Rót đồ P90 (30% độ bền, đạn giới hạn) + 1 Medkit lớn cho màn Aim & Shoot
    if (tutorialId == "shooting_range" || tutorialId == "aim_shoot" || (tutorialType == TUTORIAL_TYPE.CLEAR_ARENA && killCount >= config.requiredKills)) {
        var _dropX = x;
        var _dropY = y;
        if (instance_exists(o_player)) {
            _dropX = o_player.x + lengthdir_x(40, o_player.aimDir);
            _dropY = o_player.y + lengthdir_y(40, o_player.aimDir);
        }

        // Spawn P90 (equip_weapon_smg) với độ bền 30% và số đạn giới hạn
        var _p90 = instance_create_depth(_dropX - 16, _dropY, -_dropY, o_item_pickup);
        if (instance_exists(_p90)) {
            _p90.item_id      = "equip_weapon_smg"; // FN P90
            _p90.quantity     = 1;
            _p90.durability   = 30; // 30% độ bền
            _p90.ammo         = 15; // 15 viên đạn trong băng
            _p90.reserve_ammo = 30; // 30 viên đạn dự trữ
        }

        // Spawn Medkit lớn (item_medkit)
        var _med = instance_create_depth(_dropX + 16, _dropY, -_dropY, o_item_pickup);
        if (instance_exists(_med)) {
            _med.item_id  = "item_medkit";
            _med.quantity = 1;
        }

        inventory_toast("Reward: P90 (30% Durability) & Medkit dropped!");
    }

    if (variable_struct_exists(config, "gateId")) tutorial_open_gates(config.gateId);
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
function tutorial_configure_exit_gate(_nextRoom)
{
    gateId = "tutorial_exit";
    isExit = true;
    blocksPlayer = false;
    blocksEnemies = true;
	
	//room_goto(_nextRoom)
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

/// @desc Tìm instance tutorial ưu tiên duy nhất được phép hiển thị thông báo trên màn hình
function tutorial_get_active_display_instance()
{
    var _bestInst = noone;
    var _bestDist = 999999;
    var _completedInst = noone;
    var _completedTimer = 0;

    var _playerX = instance_exists(o_player) ? o_player.x : 0;
    var _playerY = instance_exists(o_player) ? o_player.y : 0;

    var _count = instance_number(o_tutorial);
    for (var i = 0; i < _count; i++) {
        var _inst = instance_find(o_tutorial, i);
        if (!instance_exists(_inst)) continue;

        // 1. Ưu tiên tutorial đang ACTIVE (đang thực hiện nhiệm vụ)
        if (_inst.active && !_inst.completed) {
            var _dist = point_distance(_inst.x, _inst.y, _playerX, _playerY);
            if (_dist < _bestDist) {
                _bestDist = _dist;
                _bestInst = _inst;
            }
        }
        // 2. Dự phòng: tutorial vừa hoàn thành và còn completionTimer
        else if (_inst.completed && _inst.completionTimer > 0) {
            if (_inst.completionTimer > _completedTimer) {
                _completedTimer = _inst.completionTimer;
                _completedInst = _inst;
            }
        }
    }

    return (_bestInst != noone) ? _bestInst : _completedInst;
}

function tutorial_draw_message()
{
    // Đảm bảo chỉ 1 thông báo duy nhất của tutorial ưu tiên được hiển thị (tránh đè chữ)
    var _activeTarget = tutorial_get_active_display_instance();
    if (_activeTarget != id) return;

    var _text = completed ? "TUTORIAL COMPLETE!" : message;
    if (!completed && tutorialType == TUTORIAL_TYPE.CLEAR_ARENA) {
        _text += " (" + string(killCount) + " / " + string(config.requiredKills) + ")";
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _w = string_width(_text) + 24;
    var _h = string_height(_text) + 12;
    var _cx = display_get_gui_width() * 0.5;
    var _cy = 40; // Vị trí phía trên màn hình

    draw_set_alpha(0.75);
    draw_set_color(c_black);
    draw_rectangle(_cx - _w/2, _cy - _h/2, _cx + _w/2, _cy + _h/2, false);
    
    draw_set_color(make_color_rgb(180, 180, 180)); // Viền xám sáng
    draw_rectangle(_cx - _w/2, _cy - _h/2, _cx + _w/2, _cy + _h/2, true);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(_cx, _cy, _text);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
