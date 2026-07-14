

/// @desc  Dọn dẹp damage list khi entity bị destroy (tránh memory leak).
///        Gọi trong CleanUp event hoặc trước khi instance_destroy().
function get_damaged_cleanup()
{
    if (variable_instance_exists(id, "damage_list") && ds_exists(damage_list, ds_type_list)) {
        ds_list_destroy(damage_list);
    }
}