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
        if (variable_instance_exists(_bullet, "damage"))      _bullet.damage      = weapon.damage;
        if (variable_instance_exists(_bullet, "base_damage")) _bullet.base_damage = weapon.damage;
        if (variable_instance_exists(_bullet, "spd"))         _bullet.spd         = weapon.bulletSpd;
        if (variable_instance_exists(_bullet, "maxDist"))     _bullet.maxDist     = weapon.bulletMaxDist;
        if (variable_instance_exists(_bullet, "falloff_start")) {
            _bullet.falloff_start = weapon.damage_falloff_start;
            _bullet.falloff_end   = weapon.damage_falloff_end;
            _bullet.min_dmg_mult  = weapon.min_damage_multiplier;
        }
        if (variable_instance_exists(_bullet, "damage_type"))     _bullet.damage_type     = weapon.damage_type;
        if (variable_instance_exists(_bullet, "stagger_power"))   _bullet.stagger_power   = weapon.stagger_power;
        if (variable_instance_exists(_bullet, "knockback_power")) _bullet.knockback_power = weapon.knockback_power;
        if (weapon.bulletSprite != noone) _bullet.sprite_index = weapon.bulletSprite;
        if (variable_struct_exists(weapon, "muzzle_flash_color")) _bullet.tracer_color = weapon.muzzle_flash_color;
    }

    // Phát âm thanh bắn nếu có cấu hình
    if (weapon.fireSound != noone) audio_play_sound(weapon.fireSound, 0, false);

    // ── Kích hoạt muzzle flash ────────────────────────────────────
    if (!variable_instance_exists(id, "muzzleFlashTimer")) muzzleFlashTimer = 0;
    muzzleFlashTimer     = weapon_get_flash_frames(weapon);
    muzzleFlashRandAngle = random_range(-20, 20);
    muzzleFlashRandScale = random_range(0.85, 1.2);

    return true;
}
