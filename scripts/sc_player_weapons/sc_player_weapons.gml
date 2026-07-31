/// @desc GML fallback: Register player weapon definitions if JSON failed.
function sc_player_weapons()
{
    if (!variable_global_exists("PlayerWeaponDefinitions")) global.PlayerWeaponDefinitions = {};

    global.PlayerWeaponDefinitions[$ "pistol_fn57"] = new create_weapon_definition({
        id : "pistol_fn57", name : "FN Five-seveN",
        sprite : s_pistol_FN57, length : sprite_get_bbox_bottom(s_pistol_FN57),
        bullet : o_b_bullet_parent, bulletSpd : 22, bulletMaxDist : 330, bulletSprite : s_bu_pis,
        cooldown : 23, bulletNum : 1, spread : 0, damage : 18,
        automatic : false, magSize : 20, mags : 4, maxMags : 12, reloadTime : 72,
        fireSound : snd_pistol_shot_1, reloadSound : snd_pistol_reload
    });

    global.PlayerWeaponDefinitions[$ "subgun_p90"] = new create_weapon_definition({
        id : "subgun_p90", name : "FN P90",
        sprite : s_sub_P90, length : sprite_get_bbox_bottom(s_sub_P90),
        bullet : o_b_bullet_parent, bulletSpd : 22, bulletMaxDist : 330, bulletSprite : s_bu_sub,
        cooldown : 4, bulletNum : 1, spread : 4, damage : 9,
        automatic : true, magSize : 50, mags : 4, maxMags : 12, reloadTime : 85,
        fireSound : snd_smg_shot_1, reloadSound : snd_smg_reload
    });

    global.PlayerWeaponDefinitions[$ "shotgun_tus34"] = new create_weapon_definition({
        id : "shotgun_tus34", name : "TUS-34 Shotgun",
        sprite : s_shot_Tus34, length : sprite_get_bbox_bottom(s_shot_Tus34),
        bullet : o_b_bullet_parent, bulletSpd : 22, bulletMaxDist : 48, bulletSprite : s_bu_shot,
        cooldown : 50, bulletNum : 7, spread : 45, damage : 8,
        automatic : false, magSize : 42, mags : 4, maxMags : 12, reloadTime : 77,
        fireSound : snd_shotgun_shot_1, reloadSound : snd_shotgun_reload
    });

    global.PlayerWeaponDefinitions[$ "snipgun_nozin_v1"] = new create_weapon_definition({
        id : "snipgun_nozin_v1", name : "Nozin V1",
        sprite : s_snip_NozinV1, length : sprite_get_bbox_bottom(s_snip_NozinV1),
        bullet : o_b_bullet_parent, bulletSpd : 30, bulletMaxDist : 500, bulletSprite : s_bu_snip,
        cooldown : 45, bulletNum : 1, spread : 0, damage : 40,
        automatic : false, magSize : 5, mags : 4, maxMags : 12, reloadTime : 67,
        fireSound : snd_snip_shot_1, reloadSound : snd_snip_reload
    });

    // Alias for legacy code
    global.Weapons = global.PlayerWeaponDefinitions;
}
