var _fromX = sweep_x;
var _fromY = sweep_y;

xspd = lengthdir_x(spd, dir);
yspd = lengthdir_y(spd, dir);
var _toX = x + xspd;
var _toY = y + yspd;
x = _toX;
y = _toY;

var _targetHit = projectile_sweep_target(_fromX, _fromY, _toX, _toY, o_player);
var _worldHit = projectile_sweep_world(id, _fromX, _fromY, _toX, _toY);
var _targetFirst = _targetHit != noone
    && (_worldHit == noone
        || point_distance(_fromX, _fromY, _targetHit.x, _targetHit.y)
        <= point_distance(_fromX, _fromY, _worldHit.x, _worldHit.y));

if (_targetFirst) {
    var _falloffMult = projectile_get_falloff_multiplier(id);
    var _payload = damage_payload_from_source(id, _falloffMult);
    _payload.impact_x = _targetHit.x;
    _payload.impact_y = _targetHit.y;
    damage_resolve(_targetHit.target, id, _payload, true);

    if (playerDestroy) {
        x = _targetHit.x;
        y = _targetHit.y;
        destroy = true;
    }
} else if (_worldHit != noone) {
    x = _worldHit.x;
    y = _worldHit.y;
    spawn_hit_spark(x, y);
    destroy = true;
}

depth = -y;
sweep_x = x;
sweep_y = y;
bullet_tracer_update();

var _pad = 30;
if (bbox_right < -_pad || bbox_left > room_width + _pad
    || bbox_bottom < -_pad || bbox_top > room_height + _pad) {
    destroy = true;
}
if (point_distance(xstart, ystart, x, y) > maxDist) destroy = true;

if (destroy) {
    spawn_bullet_tracer_fade();
    instance_destroy();
    exit;
}
