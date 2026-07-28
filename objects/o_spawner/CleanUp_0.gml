// ================================================================
// o_spawner — Clean Up Event
// ================================================================
// Giải phóng ds_list khi instance bị destroy để tránh memory leak.
if (ds_exists(liveEnemies, ds_type_list))
{
    for (var _i = 0; _i < ds_list_size(liveEnemies); _i++)
    {
        var _inst = liveEnemies[| _i];
        instance_activate_object(_inst);
        if (instance_exists(_inst))
        {
            instance_destroy(_inst);
        }
    }
    ds_list_destroy(liveEnemies);
}
