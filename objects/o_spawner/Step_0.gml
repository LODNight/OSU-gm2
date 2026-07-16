// ================================================================
// o_spawner — Step Event
// ================================================================

// ──────────────────────────────────────────────────────────────
// 1. DEPLETED — đã spawn đủ quota, không làm gì nữa
// ──────────────────────────────────────────────────────────────
if (spawnerState == SPAWNER_STATE.DEPLETED) exit;

// ──────────────────────────────────────────────────────────────
// 2. Cần player để tính khoảng cách
// ──────────────────────────────────────────────────────────────
if (!instance_exists(o_player)) exit;
var _dist_to_player = point_distance(x, y, o_player.x, o_player.y);

// ──────────────────────────────────────────────────────────────
// 3. IDLE → ACTIVE: player bước vào activationRadius
// ──────────────────────────────────────────────────────────────
if (spawnerState == SPAWNER_STATE.IDLE)
{
    if (_dist_to_player <= config.activationRadius)
    {
        spawnerState = SPAWNER_STATE.ACTIVE;
        spawnTimer   = 0; // Reset timer để bắt đầu lại
        
        // Kích hoạt lại toàn bộ enemy thuộc spawner này
        var _size = ds_list_size(liveEnemies);
        for (var _i = 0; _i < _size; _i++)
        {
            instance_activate_object(liveEnemies[| _i]);
        }
    }
    exit; // Đang ngủ → không chạy logic tiếp theo
}

// ──────────────────────────────────────────────────────────────
// 4. ACTIVE → IDLE: player di chuyển ra quá deactivationRadius
// ──────────────────────────────────────────────────────────────
if (_dist_to_player > config.deactivationRadius)
{
    spawnerState = SPAWNER_STATE.IDLE;
    spawnTimer   = 0;

    // Deactivate riêng các enemy do spawner này tạo ra
    // Điều này giúp tối ưu hóa hiệu năng khi map lớn mà không tắt nhầm wall/camera
    var _size = ds_list_size(liveEnemies);
    for (var _i = 0; _i < _size; _i++)
    {
        instance_deactivate_object(liveEnemies[| _i]);
    }
    exit;
}

// ──────────────────────────────────────────────────────────────
// 5. Dọn dẹp các enemy đã bị tiêu diệt (chỉ chạy khi ACTIVE)
// ──────────────────────────────────────────────────────────────
for (var _i = ds_list_size(liveEnemies) - 1; _i >= 0; _i--)
{
    if (!instance_exists(liveEnemies[| _i]))
    {
        ds_list_delete(liveEnemies, _i);
    }
}

// ──────────────────────────────────────────────────────────────
// 6. Kiểm tra giới hạn tổng số đã spawn
// ──────────────────────────────────────────────────────────────
if (totalSpawned >= config.totalLimit)
{
    spawnerState = SPAWNER_STATE.DEPLETED;
    exit;
}

// ──────────────────────────────────────────────────────────────
// 7. Kiểm tra số lượng enemy sống hiện tại của spawner này
// ──────────────────────────────────────────────────────────────
var _live = ds_list_size(liveEnemies);
if (_live >= config.maxEnemies)
{
    spawnTimer = 0; // Giữ timer đứng im
    exit;
}

// ──────────────────────────────────────────────────────────────
// 8. Tăng timer và thực hiện spawn
// ──────────────────────────────────────────────────────────────
spawnTimer++;
if (spawnTimer >= config.spawnDelay)
{
    spawnTimer = 0;
    spawner_do_spawn(id);
}
