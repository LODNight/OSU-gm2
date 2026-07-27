function dialogue_execute_action(_action) {
    switch (_action.type) {
        case "quest_accept":
            quest_accept(_action.quest_id);
            break;

        case "quest_complete":
            quest_complete(_action.quest_id);
            break;

        case "give_item":
            inventory_add_item(
                _action.item_id,
                _action.amount
            );
            break;

        case "remove_item":
            inventory_remove_item(
                _action.item_id,
                _action.amount
            );
            break;

        case "open_shop":
            shop_open(_action.shop_id);
            break;

        case "set_flag":
            world_flag_set(
                _action.flag_id,
                _action.value
            );
            break;

        case "change_relationship":
            npc_relationship_add(
                _action.npc_id,
                _action.amount
            );
            break;
    }
}

function npc_get_dialogue(_npc_id) {
    switch (_npc_id) {
        case "npc_mechanic_01":
            var _quest_status = quest_get_status(
                "quest_find_generator_part"
            );

            switch (_quest_status) {
                case QuestStatus.NOT_STARTED:
                    return "dlg_marcus_generator_intro";

                case QuestStatus.ACTIVE:
                    if (inventory_has_item("item_voltage_regulator", 1)) {
                        return "dlg_marcus_generator_turn_in";
                    }

                    return "dlg_marcus_generator_progress";

                case QuestStatus.COMPLETED:
                    return "dlg_marcus_generator_completed";
            }

            break;
    }

    return "dlg_default";
}