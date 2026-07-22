// ================================================================
// o_spawner — Step Event
// ================================================================

// ──────────────────────────────────────────────────────────────
// 0. Nạp lại config nếu zoneId bị đổi (ví dụ qua Instance Creation Code)
// ──────────────────────────────────────────────────────────────
if (config == undefined || config.id != zoneId)
{
    config = global.SpawnerZones[$ zoneId];
    if (config == undefined)
    {
        show_debug_message("WARNING: Spawner zoneId '" + string(zoneId) + "' not found!");
        instance_destroy();
        exit;
    }
}

// ──────────────────────────────────────────────────────────────
// 1. Cần player để tính khoảng cách
// ──────────────────────────────────────────────────────────────
if (!instance_exists(o_player)) exit;
var _dist_to_player = point_distance(x, y, o_player.x, o_player.y);
var _deact_dist     = config.deactivationRadius;

// ──────────────────────────────────────────────────────────────
// 2. Quản lý trạng thái Active / Deactive từng Enemy theo khoảng cách ENEMY <-> PLAYER
// ──────────────────────────────────────────────────────────────
// Bất kể Spawner đang IDLE, ACTIVE hay DEPLETED, luôn kiểm tra từng enemy:
// - Nếu enemy ở gần player -> Giữ ACTIVE (để tiếp tục đuổi player dù player đã đi xa Spawner)
// - Nếu enemy ở quá xa player -> Deactivate riêng enemy đó
for (var _i = ds_list_size(liveEnemies) - 1; _i >= 0; _i--)
{
    var _inst = liveEnemies[| _i];

    // Tạm kích hoạt để kiểm tra tồn tại và đọc vị trí x, y
    instance_activate_object(_inst);

    if (!instance_exists(_inst))
    {
        // Enemy đã bị tiêu diệt thật sự
        ds_list_delete(liveEnemies, _i);
        continue;
    }

    // Tính khoảng cách từ ENEMY tới PLAYER
    var _enemy_dist = point_distance(_inst.x, _inst.y, o_player.x, o_player.y);

    if (_enemy_dist > _deact_dist)
    {
        // Enemy quá xa Player -> Deactivate riêng enemy này
        instance_deactivate_object(_inst);
    }
}

// ──────────────────────────────────────────────────────────────
// 3. Quản lý trạng thái Spawner (IDLE / ACTIVE / DEPLETED)
// ──────────────────────────────────────────────────────────────

// Đã đẻ đủ chỉ tiêu -> DEPLETED, không đẻ thêm
if (spawnerState == SPAWNER_STATE.DEPLETED) exit;

// Chuyển đổi IDLE <-> ACTIVE của Spawner dựa vào khoảng cách PLAYER <-> SPAWNER
if (_dist_to_player <= config.activationRadius)
{
    spawnerState = SPAWNER_STATE.ACTIVE;
}
else if (_dist_to_player > _deact_dist)
{
    spawnerState = SPAWNER_STATE.IDLE;
}

// ──────────────────────────────────────────────────────────────
// 4. Nếu Spawner đang ACTIVE -> Thực hiện đẻ quái
// ──────────────────────────────────────────────────────────────
if (spawnerState == SPAWNER_STATE.ACTIVE)
{
    if (!config.infinite && totalSpawned >= config.totalLimit)
    {
        spawnerState = SPAWNER_STATE.DEPLETED;
        exit;
    }

    if (spawnTimer > 0)
    {
        spawnTimer--;
        exit;
    }

    var _live      = ds_list_size(liveEnemies);
    var _needed    = config.maxEnemies - _live;
    var _remaining = config.infinite ? _needed : (config.totalLimit - totalSpawned);
    var _can_spawn = min(_needed, _remaining);

    for (var _i = 0; _i < _can_spawn; _i++)
    {
        spawner_do_spawn(id);
        if (config.spawnDelay > 0)
        {
            spawnTimer = config.spawnDelay;
            break;
        }
    }
}
