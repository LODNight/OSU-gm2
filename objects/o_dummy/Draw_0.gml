// Draw sprite với shakeX/shakeY offset từ Module Shake
var _drawX = x + shakeX;
var _drawY = y + shakeY;

draw_sprite_ext(sprite_index, image_index, _drawX, _drawY, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
