

function npc_database_create() {
    var _database = {};

    _database[$ "npc_mechanic_01"] = {
        id: "npc_mechanic_01",
        name: "Marcus",
        display_name: "Marcus",
        faction_id: "faction_survivor",
        portrait: spr_portrait_marcus,
        default_dialogue_id: "dlg_marcus_default",

        services: {
            trader: true,
            repair: true,
            healing: false
        },

        shop_id: "shop_mechanic_01",

        quest_ids: [
            "quest_find_generator_part",
            "quest_clear_tunnel"
        ]
    };

    return _database;
}



function npc_database_get(_npc_id) {
    if (!variable_struct_exists(global.npc_database, _npc_id)) {
        show_debug_message("NPC not found: " + string(_npc_id));
        return undefined;
    }

    return global.npc_database[$ _npc_id];
}
