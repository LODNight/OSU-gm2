event_inherited()

// ================================================================
// o_enemy_z — Zombie Melee Parent
// All zombie-type enemies inherit from here.
// Attacks via HITBOX COLLISION — no projectiles.
// ================================================================

// Override: melee stats
hp           = 6
chaseSpd     = 0.8
attack_range = 30    // Close-range hitbox (pixels)
aggro_range  = 180
shootCooldown = 45   // Attack lockout before returning to chase

// Sprites — child zombie MUST override these
spr_idle = -1
spr_walk = -1

// No weapon for melee enemies
hasWeapon = false

// Reinit damage system with correct hp
get_damaged_create(hp)
