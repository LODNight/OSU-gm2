var _count = array_length(trail_history);
if (_count < 2) exit;

var _fadeAlpha = fade_timer / max(fade_max, 1);

gpu_set_blendmode(bm_add);

// Outer soft light aura (Thu hẹp sát vệt đạn)
draw_primitive_begin(pr_trianglestrip);
for (var i = 0; i < _count; i++) {
    var _p     = trail_history[i];
    var _t     = i / max(_count - 1, 1);
    var _w     = lerp(tracer_width * 1.5, 0.15, _t);
    var _alpha = lerp(0.25, 0.0, _t) * _fadeAlpha;

    var _pNext = (i < _count - 1) ? trail_history[i + 1] : _p;
    var _segAngle = (i < _count - 1) ? point_direction(_pNext.x, _pNext.y, _p.x, _p.y) : dir;
    var _perpX = lengthdir_x(_w * 0.5, _segAngle + 90);
    var _perpY = lengthdir_y(_w * 0.5, _segAngle + 90);

    draw_vertex_color(_p.x + _perpX, _p.y + _perpY, tracer_color, _alpha);
    draw_vertex_color(_p.x - _perpX, _p.y - _perpY, tracer_color, _alpha);
}
draw_primitive_end();

// Outer glow ribbon
draw_primitive_begin(pr_trianglestrip);
for (var i = 0; i < _count; i++) {
    var _p     = trail_history[i];
    var _t     = i / max(_count - 1, 1);
    var _w     = lerp(tracer_width, 0.2, _t);
    var _alpha = lerp(0.9, 0.0, _t) * _fadeAlpha;

    var _pNext = (i < _count - 1) ? trail_history[i + 1] : _p;
    var _segAngle = (i < _count - 1) ? point_direction(_pNext.x, _pNext.y, _p.x, _p.y) : dir;
    var _perpX = lengthdir_x(_w * 0.5, _segAngle + 90);
    var _perpY = lengthdir_y(_w * 0.5, _segAngle + 90);

    draw_vertex_color(_p.x + _perpX, _p.y + _perpY, tracer_color, _alpha);
    draw_vertex_color(_p.x - _perpX, _p.y - _perpY, tracer_color, _alpha);
}
draw_primitive_end();

// Core white beam
draw_primitive_begin(pr_trianglestrip);
for (var i = 0; i < _count; i++) {
    var _p     = trail_history[i];
    var _t     = i / max(_count - 1, 1);
    var _w     = lerp(tracer_width * 0.4, 0.1, _t);
    var _alpha = lerp(1.0, 0.0, _t) * _fadeAlpha;

    var _pNext = (i < _count - 1) ? trail_history[i + 1] : _p;
    var _segAngle = (i < _count - 1) ? point_direction(_pNext.x, _pNext.y, _p.x, _p.y) : dir;
    var _perpX = lengthdir_x(_w * 0.5, _segAngle + 90);
    var _perpY = lengthdir_y(_w * 0.5, _segAngle + 90);

    draw_vertex_color(_p.x + _perpX, _p.y + _perpY, c_white, _alpha);
    draw_vertex_color(_p.x - _perpX, _p.y - _perpY, c_white, _alpha);
}
draw_primitive_end();

gpu_set_blendmode(bm_normal);
