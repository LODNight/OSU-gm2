// ================================================================
// sc_animation — Gợi ý dùng trong tương lai
// ================================================================

// Ví dụ có thể thêm vào đây trong tương lai:
//   - anim_set(inst, spr_idle)      : Set sprite và reset frame
//   - anim_is_done(inst)            : Kiểm tra animation đã phát xong chưa
//   - anim_play_once(inst, spr, cb) : Phát animation một lần rồi callback
//
// Hiện tại mỗi state trong sc_enemy_state.gml tự set sprite_index trực tiếp.
// Khi cần animation phức tạp hơn (hit flash, death anim...) thì migrate vào đây.
// ================================================================