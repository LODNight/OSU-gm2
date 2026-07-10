event_inherited()

// o_h_soli — Human Soldier (Elite)
// Overrides: longer range, faster aim, better weapon

// Sprites
spr_idle = s_hu_soli1_idle
spr_walk = s_hu_soli1_walk

// Stats — AFTER event_inherited() so they won't be overwritten
attack_range = 200
aggro_range  = 300
aimCooldown  = 40   // aims faster than basic guard

// Weapon — rifle: faster fire rate than pistol
weapon = global.EnemyWeapons.e_sniper