
// ================================================================
// Hệ Thống Nhận Damage — Dùng chung cho Player và Enemy
// ================================================================

/// @desc  Khởi tạo hệ thống nhận damage cho một entity.
///        Gọi một lần trong Create event (với _iframes = true cho player,
///        hoặc gọi qua enemy_apply_definition() cho enemy — KHÔNG gọi trực tiếp ở enemy).
/// @param {real}  _hp      HP ban đầu của entity.
/// @param {bool}  _iframes Nếu true, dùng iframe invincibility (player).
///                         Nếu false, dùng damage list (enemy).
function get_damaged_create(_hp, _iframes = false)
{
    hp = _hp;
    if (_iframes) {
        // Player: dùng iframe timer để bất tử tạm thời sau khi bị đánh
        iframeTimer  = 0;
        iframeNumber = 90; // Số frame bất tử sau mỗi lần bị đánh
    } else {
        // Enemy: dùng ds_list để track từng hitbox đã chạm (tránh damage 2 lần từ 1 viên đạn)
        damage_list = ds_list_create();
    }
}

/// @desc Canonical damage contract passed to the shared resolver.
function damage_payload_create(_amount, _type = "generic", _direction = 0,
    _falloffMult = 1.0, _baseAmount = -1, _stagger = 0, _knockback = 0)
{
    var _base = (_baseAmount < 0) ? _amount : _baseAmount;
    return {
        amount:       max(0, _amount),
        base_amount:  max(0, _base),
        damage_type:  _type,
        direction:    _direction,
        falloff_mult: clamp(_falloffMult, 0, 1),
        stagger:      _stagger,
        knockback:    _knockback
    };
}

/// @desc Build a payload from any legacy damage instance.
function damage_payload_from_source(_source, _falloffMult = 1.0)
{
    var _base = variable_instance_exists(_source, "base_damage")
        ? _source.base_damage
        : _source.damage;
    var _type = variable_instance_exists(_source, "damage_type")
        ? _source.damage_type
        : "generic";
    var _dir = variable_instance_exists(_source, "dir")
        ? _source.dir
        : _source.image_angle;
    var _stagger = variable_instance_exists(_source, "stagger_power")
        ? _source.stagger_power
        : 0;
    var _knockback = variable_instance_exists(_source, "knockback_power")
        ? _source.knockback_power
        : 0;
    var _amount = max(0, round(_base * _falloffMult));
    return damage_payload_create(
        _amount, _type, _dir, _falloffMult, _base, _stagger, _knockback
    );
}

/// @desc The only function allowed to mutate target HP.
/// @return true when damage was accepted, false when blocked/duplicated.
function damage_resolve(_target, _source, _payload, _useIframes = false)
{
    if (!instance_exists(_target) || !instance_exists(_source)) return false;
    if (!variable_instance_exists(_target, "hp")) return false;
    if (_payload.amount <= 0) return false;

    if (_useIframes
        && variable_instance_exists(_target, "iframeTimer")
        && _target.iframeTimer > 0) return false;

    if (!_useIframes && variable_instance_exists(_target, "damage_list")) {
        if (ds_exists(_target.damage_list, ds_type_list)) {
            if (ds_list_find_index(_target.damage_list, _source) != -1) return false;
            ds_list_add(_target.damage_list, _source);
        }
    }

    _target.hp -= _payload.amount;
    _target.last_damage      = _payload.amount;
    _target.last_dmg_falloff = _payload.falloff_mult;
    _target.last_damage_type = _payload.damage_type;
    _source.hitConfirm       = true;

    var _impactX = variable_struct_exists(_payload, "impact_x")
        ? _payload.impact_x
        : _target.x;
    var _impactY = variable_struct_exists(_payload, "impact_y")
        ? _payload.impact_y
        : _target.y;
    _target.last_hit_x = _impactX;
    _target.last_hit_y = _impactY;

    spawn_hit_blood(_impactX, _impactY, _payload.direction + 180);
    if (variable_instance_exists(_target, "shakeTimer")) {
        with (_target) hit_shake_apply(3);
    }

    if (_useIframes && variable_instance_exists(_target, "iframeTimer")) {
        _target.iframeTimer = _target.iframeNumber;
    }
    return true;
}

/// @desc Calculate distance-based projectile falloff.
function projectile_get_falloff_multiplier(_projectile)
{
    var _traveled = point_distance(
        _projectile.xstart, _projectile.ystart, _projectile.x, _projectile.y
    );
    if (_traveled > _projectile.falloff_end) return _projectile.min_dmg_mult;
    if (_traveled <= _projectile.falloff_start) return 1.0;

    var _t = (_traveled - _projectile.falloff_start)
           / max(_projectile.falloff_end - _projectile.falloff_start, 1);
    return lerp(1.0, _projectile.min_dmg_mult, _t);
}

/// @desc Sweep a projectile segment against the real target collision mask.
///       Returns { target, x, y } at the first contact point, or noone.
function projectile_sweep_target(_x1, _y1, _x2, _y2, _targetObject)
{
    // Broad phase: skip pixel sampling when the segment cannot hit anything.
    if (collision_line(_x1, _y1, _x2, _y2, _targetObject, false, true) == noone) {
        return noone;
    }

    // Narrow phase: sample at <= 1 px to find the first visible contact.
    var _distance = point_distance(_x1, _y1, _x2, _y2);
    var _steps = max(1, ceil(_distance));
    for (var i = 0; i <= _steps; i++) {
        var _t = i / _steps;
        var _px = lerp(_x1, _x2, _t);
        var _py = lerp(_y1, _y2, _t);
        var _target = collision_point(_px, _py, _targetObject, false, true);
        if (_target != noone) {
            return { target: _target, x: _px, y: _py };
        }
    }
    return noone;
}

/// @desc Sweep the same segment against tile and object walls.
///       Returns { x, y } at the first blocked point, or noone.
function projectile_sweep_world(_projectile, _x1, _y1, _x2, _y2)
{
    var _distance = point_distance(_x1, _y1, _x2, _y2);
    var _steps = max(1, ceil(_distance));
    for (var i = 0; i <= _steps; i++) {
        var _t = i / _steps;
        var _px = lerp(_x1, _x2, _t);
        var _py = lerp(_y1, _y2, _t);

        var _tileBlocked = false;
        if (_projectile.tile_wall != -1) {
            _tileBlocked = tilemap_get_at_pixel(_projectile.tile_wall, _px, _py) != 0;
        }
        if (!_tileBlocked && _projectile.tile_item != -1) {
            _tileBlocked = tilemap_get_at_pixel(_projectile.tile_item, _px, _py) != 0;
        }

        var _objectBlocked = collision_point(_px, _py, o_wall_colli, false, true) != noone
            || collision_point(_px, _py, o_wall, false, true) != noone;
        if (_tileBlocked || _objectBlocked) return { x: _px, y: _py };
    }
    return noone;
}



/// @desc  Kiểm tra va chạm với damage source và trừ HP tương ứng mỗi frame.
///        Hỗ trợ 2 chế độ:
///        - _iframes = false (enemy): Mỗi hitbox chỉ được tính 1 lần qua damage_list.
///          Hitbox biến mất hoặc không còn chạm → tự động xóa khỏi list.
///        - _iframes = true (player): Mỗi lần bị đánh → bất tử iframeNumber frame,
///          nhấp nháy alpha để thông báo cho người chơi.
/// @param {asset.GMObject} _damageObj  Object class của damage source (o_damage_enemies / o_damage_player).
/// @param {bool}           _iframes    Dùng iframe mode hay damage list mode.
function get_damaged(_damageObj, _iframes = false)
{
    // ── Chế độ IFRAME (player): đếm frame bất tử, nhấp nháy ──
    if (_iframes && iframeTimer > 0) {
        iframeTimer--;
        if (iframeTimer mod 7 == 0) image_alpha = (image_alpha == 1) ? 0 : 1;
        exit;
    }
    // Hết iframe: khôi phục alpha về 1
    if (_iframes) image_alpha = 1;

    // ── Kiểm tra va chạm với tất cả instance của damage source ──
    if (place_meeting(x, y, _damageObj)) {
        var _instances = ds_list_create();
        instance_place_list(x, y, _damageObj, _instances, false);
        var _count  = ds_list_size(_instances);
        var _wasHit = false;

        for (var i = 0; i < _count; i++) {
            var _damage = ds_list_find_value(_instances, i);

            var _payload = damage_payload_from_source(_damage);
            if (damage_resolve(id, _damage, _payload, _iframes)) _wasHit = true;
        }

        // Iframe mode: nếu bị đánh → kích hoạt timer bất tử
        if (_iframes && _wasHit) iframeTimer = iframeNumber;
        ds_list_destroy(_instances);
    }

    // ── Damage list mode: dọn các hitbox đã biến mất hoặc không còn chạm ──
    if (!_iframes) {
        var _size = ds_list_size(damage_list);
        for (var j = 0; j < _size; j++) {
            var _damage = ds_list_find_value(damage_list, j);
            if (!instance_exists(_damage) || !place_meeting(x, y, _damage)) {
                ds_list_delete(damage_list, j);
                j--;
                _size--;
            }
        }
    }
}
