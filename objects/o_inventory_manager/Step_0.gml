// o_inventory_manager — Step Event
// Toggle UI + cập nhật toast timer

// Toggle mở/đóng inventory bằng Tab
if (keyboard_check_pressed(inv_key)) {
    global.InventoryOpen = !global.InventoryOpen;
}

// Tick toast timers
inventory_toast_update();
