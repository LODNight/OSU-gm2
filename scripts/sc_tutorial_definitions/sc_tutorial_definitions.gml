/// @desc Static tutorial presets. Put o_tutorial in a room and set tutorialId.
function sc_tutorial_definitions()
{
    global.TutorialProgress = {};
    global.TutorialDefinitions = {
        movement_pickup : {
            id : "movement_pickup",
            type : TUTORIAL_TYPE.MOVE_AND_PICKUP,
            activationRadius : 180,
            message : "Di chuyen bang WASD. Den gan hop dan va nhan F de nhat dan.",
            pickupMags : 2,
            pickupOffsetX : 48,
            pickupOffsetY : 0
        },

        shooting_range : {
            id : "shooting_range",
            type : TUTORIAL_TYPE.CLEAR_ARENA,
            activationRadius : 220,
            message : "Tieu diet zombie de mo cong phia truoc.",
            requiredKills : 8,
            spawnerZoneId : "tutorial_shooting",
            gateId : "tutorial_gate_escape"
        },

        escape_horde : {
            id : "escape_horde",
            type : TUTORIAL_TYPE.ESCAPE_HORDE,
            requiresTutorialId : "shooting_range",
            activationRadius : 220,
            message : "Zombie se khong ngung keo den. Chay toi loi thoat!",
            spawnerZoneId : "tutorial_escape_horde",
            exitGateId : "tutorial_exit"
        }
    };
}
