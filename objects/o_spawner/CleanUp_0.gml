// ================================================================
// o_spawner — Clean Up Event
// ================================================================
// Giải phóng ds_list khi instance bị destroy để tránh memory leak.
if (ds_exists(liveEnemies, ds_type_list))
{
    ds_list_destroy(liveEnemies);
}
