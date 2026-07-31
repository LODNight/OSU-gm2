/// @desc Helper functions for bullet tracer trails
/// ================================================================

/// @desc Record position into bullet's trail_history array
function bullet_tracer_update()
{
    if (!variable_instance_exists(id, "trail_history")) {
        trail_history = [];
    }

    var _max_len = variable_instance_exists(id, "max_trail_length") ? max_trail_length : 4;

    // Push current position to top of trail array
    array_insert(trail_history, 0, { x: x, y: y });

    // Cap history length
    if (array_length(trail_history) > _max_len) {
        array_pop(trail_history);
    }
}

/// @desc Draw glowing tapered bullet tracer line & white core beam
function draw_bullet_tracer()
{
    var _count = variable_instance_exists(id, "trail_history") ? array_length(trail_history) : 0;
    var _col   = variable_instance_exists(id, "tracer_color") ? tracer_color : make_color_rgb(255, 215, 110);
    var _wMax  = variable_instance_exists(id, "tracer_width") ? tracer_width : 1.6;
    var _dir   = variable_instance_exists(id, "dir") ? dir : image_angle;

    // ── 1. Draw Tapered Additive Tracer Mesh ──────────────────────
    if (_count >= 2) {
        gpu_set_blendmode(bm_add);

        // --- Layer A: Outer Soft Light Aura (Sáng nhẹ lan tỏa) ---
        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i < _count; i++) {
            var _p     = trail_history[i];
            var _t     = i / max(_count - 1, 1);
            var _w     = lerp(_wMax * 2.8, 0.3, _t);
            var _alpha = lerp(0.35, 0.0, _t);

            var _pNext = (i < _count - 1) ? trail_history[i + 1] : _p;
            var _segAngle = (i < _count - 1) ? point_direction(_pNext.x, _pNext.y, _p.x, _p.y) : _dir;
            var _perpX = lengthdir_x(_w * 0.5, _segAngle + 90);
            var _perpY = lengthdir_y(_w * 0.5, _segAngle + 90);

            draw_vertex_color(_p.x + _perpX, _p.y + _perpY, _col, _alpha);
            draw_vertex_color(_p.x - _perpX, _p.y - _perpY, _col, _alpha);
        }
        draw_primitive_end();

        // --- Layer B: Core Glow Ribbon ---
        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i < _count; i++) {
            var _p     = trail_history[i];
            var _t     = i / max(_count - 1, 1); // 0.0 at bullet tip, 1.0 at tail
            var _w     = lerp(_wMax, 0.1, _t);
            var _alpha = lerp(0.95, 0.0, _t);

            // Angle of this trail segment
            var _pNext = (i < _count - 1) ? trail_history[i + 1] : _p;
            var _segAngle = (i < _count - 1) ? point_direction(_pNext.x, _pNext.y, _p.x, _p.y) : _dir;
            var _perpX = lengthdir_x(_w * 0.5, _segAngle + 90);
            var _perpY = lengthdir_y(_w * 0.5, _segAngle + 90);

            draw_vertex_color(_p.x + _perpX, _p.y + _perpY, _col, _alpha);
            draw_vertex_color(_p.x - _perpX, _p.y - _perpY, _col, _alpha);
        }
        draw_primitive_end();

        // --- Layer B: Super Bright Inner Core Beam ---
        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i < _count; i++) {
            var _p     = trail_history[i];
            var _t     = i / max(_count - 1, 1);
            var _w     = lerp(_wMax * 0.45, 0.05, _t);
            var _alpha = lerp(1.0, 0.0, _t);

            var _pNext = (i < _count - 1) ? trail_history[i + 1] : _p;
            var _segAngle = (i < _count - 1) ? point_direction(_pNext.x, _pNext.y, _p.x, _p.y) : _dir;
            var _perpX = lengthdir_x(_w * 0.5, _segAngle + 90);
            var _perpY = lengthdir_y(_w * 0.5, _segAngle + 90);

            draw_vertex_color(_p.x + _perpX, _p.y + _perpY, c_white, _alpha);
            draw_vertex_color(_p.x - _perpX, _p.y - _perpY, c_white, _alpha);
        }
        draw_primitive_end();

        gpu_set_blendmode(bm_normal);
    }

    // ── 2. Draw Bullet Sprite (No circle head) ─────────────────────
    if (sprite_index != -1 && sprite_exists(sprite_index)) {
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, _dir, image_blend, image_alpha);
    }
}

/// @desc Spawn a visual fading trail effect instance when bullet is destroyed
function spawn_bullet_tracer_fade()
{
    if (!variable_instance_exists(id, "trail_history")) return;
    var _count = array_length(trail_history);
    if (_count < 2) return;

    var _fade = instance_create_depth(x, y, depth, o_bullet_tracer_fade);
    // Deep copy trail array
    _fade.trail_history = [];
    for (var i = 0; i < _count; i++) {
        array_push(_fade.trail_history, { x: trail_history[i].x, y: trail_history[i].y });
    }
    _fade.tracer_color = variable_instance_exists(id, "tracer_color") ? tracer_color : make_color_rgb(255, 215, 110);
    _fade.tracer_width = variable_instance_exists(id, "tracer_width") ? tracer_width : 3.5;
    _fade.dir          = variable_instance_exists(id, "dir") ? dir : image_angle;
    _fade.fade_timer   = 4;
    _fade.fade_max     = 4;
}
