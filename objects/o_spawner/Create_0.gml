// ================================================================
// o_spawner — Create Event
// ================================================================

// ── Đọc config từ registry ──
// Biến zoneId phải được gán trong Room Editor (Instance Variables)
// Mặc định nếu không gán là "graveyard" để tránh lỗi crash
if (!variable_instance_exists(id, "zoneId"))
{
    zoneId = "graveyard";
}

config = global.SpawnerZones[$ zoneId];

// Phòng trường hợp config không hợp lệ
if (config == undefined)
{
    show_debug_message("WARNING: Spawner zoneId '" + string(zoneId) + "' not found in global.SpawnerZones!");
    instance_destroy();
    exit;
}

// ── State Machine ──
spawnerState = SPAWNER_STATE.IDLE; // Bắt đầu ngủ, chờ player đến gần

// ── Timer đếm giữa các lần spawn ──
spawnTimer = 0;

// ── Đếm tổng đã spawn ──
totalSpawned = 0;

// ── Danh sách instance enemy đang sống của spawner này ──
liveEnemies = ds_list_create();
