// o_inventory_manager — Create Event
// Khởi tạo hệ thống túi đồ 6x7, 5 slot trang bị và 8 ô Quickbar.
// Set Persistent = true cho object này.

inventory_init();

inv_key = vk_tab;

// Trạng thái Hover
inv_hover_type = "";  // "grid", "equip", "quickbar"
inv_hover_idx  = -1;

// Trạng thái Kéo - Thả (Drag & Drop)
drag_active      = false;
drag_source_type = ""; // "grid", "equip", "quickbar"
drag_source_idx  = -1;
drag_data        = undefined;

// Context Menu (Chuột phải)
context_active    = false;
context_x         = 0;
context_y         = 0;
context_slot_type = "";
context_slot_idx  = -1;
