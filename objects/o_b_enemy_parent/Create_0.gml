hitConfirm = false;

spd  = 7
xspd = 0
yspd = 0
sweep_x = x
sweep_y = y

destroy = false
playerDestroy = true
maxDist = 240
damage = 1
base_damage = 1
damage_type = "ballistic"
stagger_power = 0
knockback_power = 0
falloff_start = 999999
falloff_end = 999999
min_dmg_mult = 1.0

tile_wall = layer_tilemap_get_id("tile_wall")
tile_item = layer_tilemap_get_id("tile_item_coli")

if (instance_exists(o_player)){
    dir = point_direction(x, y, o_player.x, o_player.y);
}
image_angle = dir;

// ======== Bullet Tracer & Visuals
trail_history    = [];
max_trail_length = 3;
tracer_color     = make_color_rgb(255, 90, 45); // Orange-red tracer for enemies
tracer_width     = 1.6;
