function npc_interact(_npc_instance) {
    if (!instance_exists(_npc_instance)) {
        return;
    }

    var _npc_id = _npc_instance.npc_id;

    with (o_dialogue_manager) {
        dialogue_start(_npc_id);
    }
}