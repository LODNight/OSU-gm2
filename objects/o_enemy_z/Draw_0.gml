// Melee enemies have no weapon — draw sprite only
draw_sprite_ext(
    sprite_index, image_index,
    x, y,
    face, image_yscale,
    image_angle, image_blend, image_alpha
)

// Debug HP (remove in release)
// draw_text(x, y - 10, string(hp))
