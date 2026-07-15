// ================================================================
// sc_enemy_weapon — Xử lý bắn súng (RANGED enemy)
// ================================================================

/// @desc  Ra đòn bắn đạn dựa trên cấu hình vũ khí hiện tại của enemy.
///        Hỗ trợ multi-bullet (shotgun spread) thông qua weapon.bulletNum và weapon.spread.
///        Gọi từ enemy_state_attack() khi enemyCombat == ENEMY_COMBAT.RANGED.
/// @return {bool}  true nếu bắn thành công, false nếu không có vũ khí hợp lệ.
function enemy_weapon_fire()
{
    // Kiểm tra vũ khí hợp lệ
    if (weapon == noone || weapon.bullet == noone) return false;

    // Tính góc lệch giữa các viên đạn (dàn đều trong weapon.spread)
    // Ví dụ: bulletNum=3, spread=30 → góc: aimDir-15, aimDir, aimDir+15
    var _spreadStep = weapon.spread / max(weapon.bulletNum - 1, 1);

    for (var i = 0; i < weapon.bulletNum; i++) {
        var _bullet = instance_create_depth(x, y, depth, weapon.bullet);
        // Góc mỗi viên = từ mép trái của hình nón spread
        _bullet.dir         = aimDir - weapon.spread * 0.5 + _spreadStep * i;
        _bullet.image_angle = _bullet.dir;
        
        // Gán thông số từ súng sang đạn
        if (variable_instance_exists(_bullet, "damage")) _bullet.damage = weapon.damage;
        if (variable_instance_exists(_bullet, "spd"))    _bullet.spd    = weapon.bulletSpd;
        if (weapon.bulletSprite != noone) _bullet.sprite_index = weapon.bulletSprite;
    }

    // Phát âm thanh bắn nếu có cấu hình
    if (weapon.fireSound != noone) audio_play_sound(weapon.fireSound, 0, false);

    return true;
}
