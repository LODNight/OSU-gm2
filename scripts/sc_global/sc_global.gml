// ================================================================
// sc_global — Định nghĩa enum và hằng số dùng chung toàn dự án
// ================================================================

/// Các trạng thái trong State Machine của enemy.
/// Chỉ giữ lại những state đang thực sự dùng trong sc_enemy_state.gml
enum ENEMY_STATE {
    IDLE,    // Đứng yên, chưa phát hiện mục tiêu
    CHASE,   // Đang đuổi theo mục tiêu
    AIM,     // Dừng lại ngắm trước khi bắn (chỉ RANGED dùng)
    ATTACK,  // Đang thực hiện đòn tấn công
    DEAD,    // Đã chết, chờ spawn xác
}

/// Phân loại kiểu chiến đấu của enemy.
enum ENEMY_COMBAT {
    MELEE,   // Cận chiến (zombie) — tấn công bằng va chạm / hitbox
    RANGED,  // Tầm xa (lính) — tấn công bằng đạn
}
