/// @desc Register immutable player weapon definitions.
function sc_player_weapons()
{
    global.PlayerWeaponDefinitions = {
        pistol_fn57 : new create_weapon_definition({
            id : "pistol_fn57", name : "FN57", sprite : s_pistol_FN57,
            length : sprite_get_bbox_bottom(s_pistol_FN57), bullet : o_b_pistol,
            cooldown : 23, bulletNum : 1, spread : 0, damage : 18,
            scopeZoom : 0.85,  // ADS nhẹ
            magSize : 20, reserveAmmo : 120, maxReserveAmmo : 240, reloadTime : 72, // ~1.2s audio duration
            fireSound : snd_pistol_shot_1, reloadSound : snd_pistol_reload, automatic : false
        }),

        subgun_p90 : new create_weapon_definition({
            id : "subgun_p90", name : "P90", sprite : s_sub_P90,
            length : sprite_get_bbox_bottom(s_sub_P90), bullet : o_b_sub,
            cooldown : 4, bulletNum : 1, spread : 4, damage : 9,
            scopeZoom : 0.95,  // ADS tầm gần, ít zoom
            magSize : 50, reserveAmmo : 300, maxReserveAmmo : 600, reloadTime : 85, // ~1.4s audio duration
            fireSound : snd_smg_shot_1, reloadSound : snd_smg_reload, automatic : true
        }),

        shotgun_tus34 : new create_weapon_definition({
            id : "shotgun_tus34", name : "Tus34", sprite : s_shot_Tus34,
            length : sprite_get_bbox_bottom(s_shot_Tus34), bullet : o_b_shot,
            cooldown : 50, bulletNum : 7, spread : 45, damage : 8,
            scopeZoom : 1.0,   // Shotgun không zoom
            magSize : 6, reserveAmmo : 48, maxReserveAmmo : 96, reloadTime : 77, // ~1.28s audio duration
            fireSound : snd_shotgun_shot_1, reloadSound : snd_shotgun_reload, automatic : false
        }),

        snipgun_nozin_v1 : new create_weapon_definition({
            id : "snipgun_nozin_v1", name : "Nozin V1", sprite : s_snip_NozinV1,
            length : sprite_get_bbox_bottom(s_snip_NozinV1), bullet : o_b_snip,
            cooldown : 45, bulletNum : 1, spread : 0, damage : 40,
            scopeZoom : 0.45,  // Sniper zoom mạnh
            magSize : 5, reserveAmmo : 30, maxReserveAmmo : 60, reloadTime : 67, // ~1.12s audio duration
            fireSound : snd_snip_shot_1, reloadSound : snd_snip_reload, automatic : false
        })
    };

    // Temporary alias for scripts that still expect the previous registry name.
    global.Weapons = global.PlayerWeaponDefinitions;
}
