global.leftKey  = keyboard_check(ord("A"))
global.rightKey = keyboard_check(ord("D"))
global.upKey    = keyboard_check(ord("W"))
global.downKey  = keyboard_check(ord("S"))
global.sprintKey = keyboard_check(vk_shift)    // Shift → Sprint

global.shootKey     = mouse_check_button(mb_left)
global.shootPressed = mouse_check_button_pressed(mb_left)
global.aimKey       = mouse_check_button(mb_right)          // RMB giữ → ADS
global.reloadKey    = keyboard_check_pressed(ord("R"))
global.swapKey      = keyboard_check_pressed(ord("Q"))      // Q → swap súng (đã đổi từ RMB)
global.spaceKey     = keyboard_check(vk_space)

global.num1Key = keyboard_check(ord("1"))
global.num2Key = keyboard_check(ord("2"))
global.num3Key = keyboard_check(ord("3"))
global.num4Key = keyboard_check(ord("4"))
