// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function create_weapon( _sprite = s_pistol_FN57, _weaponLength = 0, _bullet = obj_b_sub, _cooldown = 1, _bullerNumber = 1, _spread = 0) constructor{
	sprite = _sprite;
	length = _weaponLength;
	bullet = _bullet;
	cooldown = _cooldown;
	bulletNum = _bullerNumber;
	spread = _spread;
}

// Player's weapon inventory
global.PlayerWeapons = array_create(0)

// Weapons
global.Weapons = {	

	pistol_fn57 : new create_weapon(
			s_pistol_FN57, 
			sprite_get_bbox_bottom(s_pistol_FN57),
			o_b_pistol,
			23
			),
		
	subgun_p90 : new create_weapon(
			s_sub_P90, 
			sprite_get_bbox_bottom(s_sub_P90),
			o_b_sub,
			3.5
			), 
			
	shotgun_tus34 : new create_weapon(
			s_shot_Tus34, 
			sprite_get_bbox_bottom(s_shot_Tus34),
			o_b_shot,
			50,
			7,
			45
			), 
			
	snipgun_nozin_v1 : new create_weapon(
			s_snip_NozinV1, 
			sprite_get_bbox_bottom(s_snip_NozinV1),
			o_b_snip,
			45
			), 
	snipgun_nozin_v2 : new create_weapon(
			s_snip_NozinV2, 
			sprite_get_bbox_bottom(s_snip_NozinV2),
			o_b_snip,
			45
			),
}
