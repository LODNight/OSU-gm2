/// @desc Static tutorial presets. Put o_tutorial in a room and set tutorialId.
function sc_tutorial_definitions()
{
    global.TutorialProgress = {};
    global.TutorialDefinitions = {
        // ── 1. HƯỚNG DẪN DI CHUYỂN (Movement & Sprint) ────────────────
        movement : {
            id : "movement",
            type : TUTORIAL_TYPE.MOVE_AND_SPRINT,
            activationRadius : 180,
            message : "Di chuyen bang [W] [A] [S] [D] va Giu [SHIFT] de Chay nhanh.",
            gateId : "tutorial_gate_aim"
        },
        movement_pickup : {
            id : "movement_pickup",
            type : TUTORIAL_TYPE.MOVE_AND_SPRINT,
            activationRadius : 180,
            message : "Di chuyen bang [W] [A] [S] [D] va Giu [SHIFT] de Chay nhanh.",
            gateId : "tutorial_gate_aim"
        },

        // ── 2. HƯỚNG DẪN AIM VÀ BẮN SÚNG (Aim & Shoot) ───────────────
        aim_shoot : {
            id : "aim_shoot",
            type : TUTORIAL_TYPE.CLEAR_ARENA,
            requiresTutorialId : "movement",
            activationRadius : 220,
            message : "Giu Chuot Phai [RMB] de Ngam, Chuot Trai [LMB] de Ban. Tieu diet Zombie!",
            requiredKills : 5,
            spawnerZoneId : "tutorial_shooting",
            gateId : "tutorial_gate_loot"
        },
        shooting_range : {
            id : "shooting_range",
            type : TUTORIAL_TYPE.CLEAR_ARENA,
            requiresTutorialId : "movement",
            activationRadius : 220,
            message : "Giu Chuot Phai [RMB] de Ngam, Chuot Trai [LMB] de Ban. Tieu diet Zombie!",
            requiredKills : 5,
            spawnerZoneId : "tutorial_shooting",
            gateId : "tutorial_gate_loot"
        },

        // ── 3. SỬ DỤNG KHO ĐỒ ĐỂ HỒI MÁU VÀ NHẶT SÚNG (Loot & Inventory) ──
        loot_inventory : {
            id : "loot_inventory",
            type : TUTORIAL_TYPE.LOOT_AND_INVENTORY,
            requiresTutorialId : "aim_shoot",
            activationRadius : 220,
            message : "Nhan [F] Nhat do. Nhan [TAB] mo Kho do: Dung Medkit hoi mau & Trang bi P90!",
            gateId : "tutorial_gate_escape"
        },

        // ── 4. CHẠY KHỎI MAP (Run & Escape) ───────────────────────────
        run_escape : {
            id : "run_escape",
            type : TUTORIAL_TYPE.ESCAPE_HORDE,
            requiresTutorialId : "loot_inventory",
            activationRadius : 220,
            message : "Zombie se khong ngung keo den. Chay nhanh toi loi thoat!",
            spawnerZoneId : "tutorial_escape_horde",
            exitGateId : "tutorial_exit"
        },
        escape_horde : {
            id : "escape_horde",
            type : TUTORIAL_TYPE.ESCAPE_HORDE,
            requiresTutorialId : "loot_inventory",
            activationRadius : 220,
            message : "Zombie se khong ngung keo den. Chay nhanh toi loi thoat!",
            spawnerZoneId : "tutorial_escape_horde",
            exitGateId : "tutorial_exit"
        }
    };
}

