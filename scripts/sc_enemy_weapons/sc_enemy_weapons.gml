/// @desc Register immutable enemy weapon definitions. Enemies do not need ammo instances yet.
function sc_enemy_weapons()
{
    global.EnemyWeapons = {
        e_pistol : new create_weapon_definition({
            id : "enemy_pistol", name : "Enemy Pistol", sprite : s_pistol_FN57,
            length : 8, bullet : o_b_enemy_parent, bulletSpd : 7, bulletSprite : s_bu_pis, damage : 9,
            cooldown : 90, magSize : 8, reserveAmmo : 999, reloadTime : 90,
            fireSound : snd_pistol_shot_1
        }),
        e_rifle : new create_weapon_definition({
            id : "enemy_rifle", name : "Enemy Rifle", sprite : s_sub_P90,
            length : 10, bullet : o_b_enemy_parent, bulletSpd : 8, bulletSprite : s_bu_sub, damage : 14,
            cooldown : 45, magSize : 30, reserveAmmo : 999, reloadTime : 75,
            fireSound : snd_smg_shot_1, automatic : true
        }),
        e_sniper : new create_weapon_definition({
            id : "enemy_sniper", name : "Enemy Sniper", sprite : s_snip_NozinV1,
            length : 14, bullet : o_b_enemy_parent, bulletSpd : 14, bulletSprite : s_bu_snip, damage : 20,
            cooldown : 180, magSize : 5, reserveAmmo : 999, reloadTime : 120,
            fireSound : snd_pistol_shot_1
        }),
        e_shotgun : new create_weapon_definition({
            id : "enemy_shotgun", name : "Enemy Shotgun", sprite : s_shot_Tus34,
            length : 8, bullet : o_b_enemy_parent, bulletSpd : 7, bulletSprite : s_bu_shot, damage : 9,
            cooldown : 120, bulletNum : 3, spread : 30, magSize : 6, reserveAmmo : 999, reloadTime : 120,
            fireSound : snd_shotgun_shot_1
        })
    };
}
