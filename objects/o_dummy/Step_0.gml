// 1. Cập nhật hiệu ứng rung khi trúng đạn (Module Shake)
hit_shake_update();

// 2. Kiểm tra sát thương từ các nguồn (o_damage_enemies)
get_damaged(o_damage_enemies);

// 3. Nếu HP bị giảm so với maxHp (do đạn hoặc nguồn damage khác trừ)
if (hp < maxHp) {
    var _dmgDealt   = maxHp - hp;
    
    // Đọc falloff multiplier nếu có (được truyền từ bullet Step event)
    var _falloffMult = variable_instance_exists(id, "last_dmg_falloff")
                     ? last_dmg_falloff : 1.0;
    
    // Spawn popup số sát thương nổi lên trên đầu
    instance_create_depth(x + random_range(-6, 6), bbox_top - 12, -9999, o_damage_popup, {
        damage_value:    _dmgDealt,
        falloff_mult:    _falloffMult
    });
    
    // Reset HP về maxHp để dummy không bao giờ chết
    hp              = maxHp;
    last_dmg_falloff = 1.0; // Reset lại sau mỗi lần đọc
}

// 4. Giữ dummy đứng yên tại chỗ & cập nhật depth
xspd    = 0;
yspd    = 0;
centerY = y + centerYOffset;
depth   = -y;
