hitConfirm = false

// ======== Bullet movement
dir  = 0
spd  = 0
xspd = 0
yspd = 0
sweep_x = x
sweep_y = y

// ======== Lifetime & hit logic
maxDist      = 240     // override in child (e.g. o_b_shot = 48)
damage       = 1       // override in child for higher damage
destroy      = false
enemyDestroy = true    // destroy on hitConfirm (set false for piercing)

// ======== Damage Falloff
falloff_start = 999999  // Khoảng cách bắt đầu giảm dame (set bởi weapon_fire)
falloff_end   = 999999  // Khoảng cách kết thúc giảm dame (= maxDist)
min_dmg_mult  = 1.0     // Hệ số dame tối thiểu ở tầm xa nhất
base_damage   = 1       // Dame gốc (giữ lại để tính falloff chính xác)
damage_type   = "ballistic"
stagger_power = 0
knockback_power = 0

// ======== Collision map
tile_wall = layer_tilemap_get_id("tile_wall")
tile_item = layer_tilemap_get_id("tile_item_coli")

// ======== Bullet Tracer & Visuals
trail_history    = [];
max_trail_length = 4;
tracer_color     = make_color_rgb(255, 215, 110); // Warm amber-yellow glow
tracer_width     = 1.8;
