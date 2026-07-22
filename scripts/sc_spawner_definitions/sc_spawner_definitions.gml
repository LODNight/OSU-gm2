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
    // ============================================================
    // PHẦN 1: ĐỊNH NGHĨA PHE PHÁI (FACTIONS)
    // Các preset cấu hình loại lính, boss và tỉ lệ xuất hiện.
    // ============================================================
    global.Factions = 
    {
		 zombies_tutorial: {
            spawnTable: [
                { obj: o_z_1,       weight: 20 },
                { obj: o_z_speed_1, weight: 10 }
            ],
            bossObj: undefined, 
            bossChance: 0 // Tỉ lệ 0%
        },
        zombies_basic: {
            spawnTable: [
                { obj: o_z_1,       weight: 10 },
                { obj: o_z_speed_1, weight: 15 }
            ],
            bossObj: undefined, 
            bossChance: 5 // Tỉ lệ 5% 
        },
        zombies_speed: {
            spawnTable: [
                { obj: o_z_1,       weight: 20 },
                { obj: o_z_speed_1, weight: 10 }
            ],
            bossObj: undefined, 
            bossChance: 10 // Tỉ lệ 10%
        },
        mutants: {
            spawnTable: [
                { obj: o_z_speed_1, weight: 15 },
                { obj: o_z_1,       weight: 15 },
                { obj: o_h_1,       weight: 20 }
            ],
            bossObj: undefined, 
            bossChance: 15 // Tỉ lệ 15%
        },
        military: {
            spawnTable: [
                { obj: o_h_1,    weight: 20 },
                { obj: o_h_soli, weight: 10 },
                { obj: o_z_1,    weight: 10 }
            ],
            bossObj: undefined, 
            bossChance: 20 // Tỉ lệ 20%
        }
    };

    // ============================================================
    // PHẦN 2: ĐỊNH NGHĨA KHU VỰC (ZONES)
    // Áp dụng Factions vào các khu vực trên bản đồ.
    // ============================================================
    global.SpawnerZones =
    {
		// ──────────────────────────────────────────────
        // KHU VỰC: TUTORIAL SHOOTING - 
        // ──────────────────────────────────────────────
        tutorial_shooting : new create_spawner_zone({
            id               : "tutorial_shooting",
            spawnTable       : global.Factions.zombies_tutorial.spawnTable,
            bossObj          : global.Factions.zombies_tutorial.bossObj,
            bossChance       : global.Factions.zombies_tutorial.bossChance,
            spawnRadius      : 192,
            activationRadius : 256,
            deactivationRadius: 320,
            totalLimit       : 8,
            maxEnemies       : 8,
            spawnDelay       : 0,
            tileLayers       : ["tile_wall", "tile_item_coli"],
            instanceLayer    : "Instances"
        }),
		
        // ──────────────────────────────────────────────
        // KHU VỰC: GRAVEYARD (Mộ ma) - Dùng Faction: zombies_basic
        // ──────────────────────────────────────────────
        graveyard : new create_spawner_zone({
            id               : "graveyard",
            spawnTable       : global.Factions.zombies_basic.spawnTable,
            bossObj          : global.Factions.zombies_basic.bossObj,
            bossChance       : global.Factions.zombies_basic.bossChance,
            spawnRadius      : 192,
            activationRadius : 256,
            deactivationRadius: 320,
            totalLimit       : 15,
            maxEnemies       : 4,
            spawnDelay       : 60,
            tileLayers       : ["tile_wall", "tile_item_coli"],
            instanceLayer    : "Instances"
        }),

        tutorial_escape_horde : new create_spawner_zone({
            id                : "tutorial_escape_horde",
            spawnTable        : global.Factions.zombies_tutorial.spawnTable,
            bossObj           : undefined,
            bossChance        : 0,
            infinite          : true,
            maxEnemies        : 100,
            spawnDelay        : 12,
            spawnRadius       : 260,
            minPlayerDist     : 96,
            activationRadius  : 300,
            deactivationRadius: 360,
            tileLayers        : ["tile_wall", "tile_item_coli"],
            instanceLayer     : "Instances"
        }),

        // ──────────────────────────────────────────────
        // KHU VỰC: BATTLEGROUND (Trận địa) - Dùng Faction: zombies_hard
        // ──────────────────────────────────────────────
        battleground : new create_spawner_zone({
            id               : "battleground",
            spawnTable       : global.Factions.zombies_speed.spawnTable,
            bossObj          : global.Factions.zombies_speed.bossObj,
            bossChance       : global.Factions.zombies_speed.bossChance,
            spawnRadius      : 224,
            activationRadius : 288,
            deactivationRadius: 352,
            totalLimit       : 20,
            maxEnemies       : 5,
            spawnDelay       : 50,
            tileLayers       : ["tile_wall", "tile_item_coli"],
            instanceLayer    : "Instances"
        }),

        // ──────────────────────────────────────────────
        // KHU VỰC: CITY (Thành phố) - Dùng Faction: mutants
        // ──────────────────────────────────────────────
        city : new create_spawner_zone({
            id               : "city",
            spawnTable       : global.Factions.mutants.spawnTable,
            bossObj          : global.Factions.mutants.bossObj,
            bossChance       : global.Factions.mutants.bossChance,
            spawnRadius      : 160,
            activationRadius : 224,
            deactivationRadius: 288,
            totalLimit       : 30,
            maxEnemies       : 6,
            spawnDelay       : 40,
            tileLayers       : ["tile_wall", "tile_item_coli"],
            instanceLayer    : "Instances"
        }),

        // ──────────────────────────────────────────────
        // KHU VỰC: ENTRANCE (Cổng thành phố) - Dùng Faction: military
        // ──────────────────────────────────────────────
        entrance : new create_spawner_zone({
            id               : "entrance",
            spawnTable       : global.Factions.military.spawnTable,
            bossObj          : global.Factions.military.bossObj,
            bossChance       : global.Factions.military.bossChance,
            spawnRadius      : 128,
            activationRadius : 192,
            deactivationRadius: 256,
            totalLimit       : 10,
            maxEnemies       : 3,
            spawnDelay       : 45,
            tileLayers       : ["tile_wall", "tile_item_coli"],
            instanceLayer    : "Instances"
        })
    };
}
