bullet_tracer_update();

xspd = lengthdir_x( spd, dir)
yspd = lengthdir_y( spd, dir)

x += xspd
y += yspd

// Wall Collision
if (place_meeting(x, y, [tile_wall, tile_item, o_wall_colli])) {
    spawn_hit_spark(x, y); // [Module B] Tia lửa khi chạm tường
    destroy = true;
}

// hit confirm destroy
if (hitConfirm == true && enemyDestroy == true) { destroy = true; }

if (destroy) {
    spawn_bullet_tracer_fade();
    instance_destroy();
}

// ── Enemy Hit Detection (Sprite-Bounds, không phụ thuộc physics mask của enemy) ──
// Bước 1: thử collision_point (nhanh). Nếu mask nhỏ bị bỏ qua → fallback sang bbox sprite.
// Cách này tách biệt hoàn toàn hitbox nhận đạn ra khỏi mask vật lý của enemy,
// cho phép enemy có mask nhỏ (overlap đẹp) mà vẫn đảm bảo đạn dính đúng.
if (!destroy) {
    var _hit = noone;
    
    // ── Bước 1: Thử collision_point (dùng mask hiện tại của enemy) ──
    _hit = collision_point(x, y, o_enemy_parent, false, true);
    
    // ── Bước 2 (Fallback): Nếu miss do mask nhỏ, kiểm tra sprite bbox thủ công ──
    if (_hit == noone) {
        var _nearest_dist = 999999;
        var _count = instance_number(o_enemy_parent);
        for (var _i = 0; _i < _count; _i++) {
            var _e = instance_find(o_enemy_parent, _i);
            if (!instance_exists(_e) || _e.sprite_index == -1) continue;
            
            var _sw  = sprite_get_width(_e.sprite_index);
            var _sh  = sprite_get_height(_e.sprite_index);
            var _ox  = sprite_get_xoffset(_e.sprite_index);
            var _oy  = sprite_get_yoffset(_e.sprite_index);
            var _ex  = _e.x - _ox;
            var _ey  = _e.y - _oy;
            
            // Kiểm tra bullet có nằm trong sprite bbox của enemy không
            if (x >= _ex && x <= _ex + _sw && y >= _ey && y <= _ey + _sh) {
                // Ưu tiên enemy gần bullet nhất (trường hợp nhiều enemy chồng nhau)
                var _d = point_distance(x, y, _e.x, _e.y);
                if (_d < _nearest_dist) {
                    _nearest_dist = _d;
                    _hit = _e;
                }
            }
        }
    }
    
    // ── Xử lý damage nếu đã tìm thấy enemy bị trúng ──
    if (_hit != noone && instance_exists(_hit)) {
        if (ds_list_find_index(_hit.damage_list, id) == -1) {
            ds_list_add(_hit.damage_list, id); // Đánh dấu đã xử lý

            // ── Tính Damage Falloff theo khoảng cách bay ──────────────
            var _traveled  = point_distance(xstart, ystart, x, y);
            var _dmg_mult  = 1.0;
            if (_traveled > falloff_end) {
                _dmg_mult = min_dmg_mult;
            } else if (_traveled > falloff_start) {
                var _t    = (_traveled - falloff_start) / max(falloff_end - falloff_start, 1);
                _dmg_mult = lerp(1.0, min_dmg_mult, _t);
            }
            var _final_damage = max(1, round(base_damage * _dmg_mult));

            _hit.hp   -= _final_damage;         // Trừ HP với dame có falloff
            hitConfirm = true;

            // Truyền thông tin falloff vào hit target để popup biết màu
            _hit.last_damage       = _final_damage;
            _hit.last_dmg_falloff  = _dmg_mult;  // 1.0 = full, < 1.0 = giảm

            // Spawn hiệu ứng máu tại điểm trúng
            spawn_hit_blood(_hit.x, _hit.y, dir + 180);

            // Rung nhẹ nếu enemy hỗ trợ
            if (variable_instance_exists(_hit, "shakeTimer")) {
                with (_hit) hit_shake_apply(3);
            }
        }
    }
}




// Bullet out range
if(point_distance( xstart, ystart, x, y) > maxDist) { destroy = true }

