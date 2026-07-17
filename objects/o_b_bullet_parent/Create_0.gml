event_inherited()

// ======== Bullet movement
dir  = 0
spd  = 0
xspd = 0
yspd = 0

// ======== Lifetime & hit logic
maxDist      = 240     // override in child (e.g. o_b_shot = 48)
damage       = 1       // override in child for higher damage
destroy      = false
enemyDestroy = true    // destroy on hitConfirm (set false for piercing)

// ======== Collision map
tile_wall = layer_tilemap_get_id("tile_wall")
tile_item = layer_tilemap_get_id("tile_item_coli")