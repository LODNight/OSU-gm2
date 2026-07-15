
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

            // Damage list mode: bỏ qua nếu hitbox này đã được tính rồi
            if (_iframes || ds_list_find_index(damage_list, _damage) == -1) {
                if (!_iframes) ds_list_add(damage_list, _damage); // Đánh dấu đã xử lý
                hp            -= _damage.damage;
                _wasHit        = true;
                _damage.hitConfirm = true; // Thông báo cho hitbox biết đã trúng

                // ── [Module A] Máu văng ra tại điểm bị trúng ──
                spawn_hit_blood(x, y, _damage.image_angle);

                // ── [Module Shake] Rung lắc nhẹ khi bị trúng ──
                if (variable_instance_exists(id, "shakeTimer")) hit_shake_apply(3);
            }
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
