event_inherited()

// ================================================================
// o_enemy_gun — Ranged / Gun Enemy Parent
// All gun-type enemies inherit from here.
// Attacks by firing bullet objects at the player.
// ================================================================

// Override: ranged combat stats
hp           = 10
chaseSpd     = 1.5
attack_range = 50    // Distance at which enemy stops and aims
aggro_range  = 200

// Sprite placeholders — child gun enemy MUST override these
spr_idle = -1
spr_walk = -1

// Weapon setup
hasWeapon    = true
weapon       = global.EnemyWeapons.e_pistol
bulletObject = o_b_e_pistol

// Combat timers
aimCooldown   = 60   // Frames spent aiming before firing
shootCooldown = 60   // Cooldown before returning to chase after firing

// Reinit damage system with correct hp
get_damaged_create(hp)
