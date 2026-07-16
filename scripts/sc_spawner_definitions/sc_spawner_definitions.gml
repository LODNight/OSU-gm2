// ================================================================
// sc_spawner_definitions — Registry tất cả zone spawner trong game
// ================================================================
// Cách thêm zone mới:
//   1. Thêm entry mới vào global.SpawnerZones bên dưới
//   2. Đặt o_spawner vào Room, gán Instance Variable: zoneId = "tên_zone"
// ================================================================

/// @desc  Đăng ký tất cả zone spawner. Gọi từ o_init Create event.
function sc_spawner_definitions()
{
    global.SpawnerZones =
    {
        // ──────────────────────────────────────────────
        // ZONE 1: GRAVEYARD (Mộ ma)
        // ──────────────────────────────────────────────
        graveyard : new create_spawner_zone({
            id               : "graveyard",
            spawnTable       : [
                { obj: o_z_1,       weight: 10 },
                { obj: o_z_speed_1, weight: 15 } // Tỷ lệ xuất hiện của zombie_speed cao hơn
            ],
            spawnRadius      : 192,
            activationRadius : 256,
            deactivationRadius: 320,
            totalLimit       : 15,
            maxEnemies       : 4,
            spawnDelay       : 60,
            tileLayers       : ["tile_wall"],
            instanceLayer    : "Instances"
        }),

        // ──────────────────────────────────────────────
        // ZONE 2: BATTLEGROUND (Trận địa)
        // ──────────────────────────────────────────────
        battleground : new create_spawner_zone({
            id               : "battleground",
            spawnTable       : [
                { obj: o_z_1,       weight: 20 },
                { obj: o_z_speed_1, weight: 10 }
            ],
            spawnRadius      : 224,
            activationRadius : 288,
            deactivationRadius: 352,
            totalLimit       : 20,
            maxEnemies       : 5,
            spawnDelay       : 50,
            tileLayers       : ["tile_wall"],
            instanceLayer    : "Instances"
        }),

        // ──────────────────────────────────────────────
        // ZONE 3: CITY (Thành phố)
        // ──────────────────────────────────────────────
        city : new create_spawner_zone({
            id               : "city",
            spawnTable       : [
                { obj: o_z_speed_1, weight: 15 },
                { obj: o_z_1,       weight: 15 },
                { obj: o_h_1,       weight: 20 }
            ],
            spawnRadius      : 160,
            activationRadius : 224,
            deactivationRadius: 288,
            totalLimit       : 30,
            maxEnemies       : 6,
            spawnDelay       : 40,
            tileLayers       : ["tile_wall"],
            instanceLayer    : "Instances"
        }),

        // ──────────────────────────────────────────────
        // ZONE 4: ENTRANCE (Cổng thành phố)
        // ──────────────────────────────────────────────
        entrance : new create_spawner_zone({
            id               : "entrance",
            spawnTable       : [
                { obj: o_h_1,    weight: 20 },
                { obj: o_h_soli, weight: 10 },
                { obj: o_z_1,    weight: 10 }
            ],
            spawnRadius      : 128,
            activationRadius : 192,
            deactivationRadius: 256,
            totalLimit       : 10,
            maxEnemies       : 3,
            spawnDelay       : 45,
            tileLayers       : ["tile_wall"],
            instanceLayer    : "Instances"
        })
    };
}
