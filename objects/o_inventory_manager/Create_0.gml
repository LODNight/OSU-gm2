// o_inventory_manager — Create Event
// Khởi tạo inventory system. Object này nên set Persistent = true.

inventory_init();

inv_selected_slot = -1;   // slot đang hover trong grid
inv_key           = vk_tab;

// Context Menu
context_active = false;
context_x = 0;
context_y = 0;
context_slot = -1;
