// ================================================================
// sc_player_stamina — Module Thể Lực Player
// Quản lý toàn bộ logic stamina: tiêu hao, hồi phục, tốc độ, vignette.
//
// Pipeline gọi:
//   Create  → stamina_create()
//   Step    → stamina_update()
//   Move    → stamina_get_speed() để lấy tốc độ thực tế
//   HUD     → stamina_get_ratio() để vẽ thanh và vignette
// ================================================================

/// @desc  Khởi tạo tất cả biến stamina cho player.
///        Gọi một lần duy nhất trong Create event của o_player.
function stamina_create()
{
    // ── Chỉ số ──
    maxStamina        = 100;    // Thể lực tối đa
    stamina           = 100;    // Thể lực hiện tại

    // ── Tốc độ di chuyển ──
    walkSpeed         = 2;      // Tốc độ đi bộ thường
    sprintSpeed       = 4;      // Tốc độ khi chạy (Shift)

    // ── Tiêu hao / Hồi phục ──
    staminaDrainRate  = 0.5;    // Lượng stamina tốn mỗi frame khi chạy
    staminaRegenRate  = 0.4;    // Lượng stamina hồi mỗi frame khi không chạy
    staminaRegenDelay = 60;     // Frame chờ trước khi bắt đầu hồi (B-type: 1 giây ở 60fps)
    _staminaRegenTimer = 0;     // Bộ đếm delay hồi (biến nội bộ)

    // ── Trạng thái ──
    isSprinting       = false;  // Player có đang thực sự chạy sprint không

    // ── Hệ thống cân nặng (placeholder cho vật phẩm sau này) ──
    carryWeight       = 0;      // Tổng cân nặng đang mang (đơn vị tùy chọn)
    weightDrainMult   = 0.05;   // Mỗi đơn vị weight → drain tăng thêm 5%
}

/// @desc  Cập nhật trạng thái stamina mỗi frame.
///        Gọi trong pipeline Step (sc_player_process) SAU player_move().
function stamina_update()
{
    // Tính drain rate thực tế: bị tăng tỉ lệ với cân nặng đang mang
    var _effectiveDrain = staminaDrainRate * (1 + carryWeight * weightDrainMult);

    // Kiểm tra player có muốn sprint không (giữ Shift + đang di chuyển)
    var _isMoving     = (left || right || up || down);
    var _wantsToSprint = sprintKey && _isMoving;

    if (_wantsToSprint && stamina > 0)
    {
        // ── ĐANG CHẠY: tốn stamina, reset bộ đếm hồi ──
        isSprinting        = true;
        stamina            = max(0, stamina - _effectiveDrain);
        _staminaRegenTimer = staminaRegenDelay; // reset delay mỗi lần tiêu
    }
    else
    {
        isSprinting = false;

        // ── KHÔNG CHẠY: đếm delay rồi mới hồi (kiểu B) ──
        if (_staminaRegenTimer > 0)
        {
            _staminaRegenTimer--;
        }
        else
        {
            stamina = min(maxStamina, stamina + staminaRegenRate);
        }
    }
}

/// @desc  Trả về tốc độ di chuyển thực tế dựa trên trạng thái stamina.
///        Kết hợp Option 1+2:
///          - Stamina > 20%  → tốc độ sprint đầy đủ
///          - Stamina 0–20%  → tốc độ giảm dần về walk (smooth)
///          - Stamina = 0    → khoá sprint, chỉ đi walk
/// @return {real}  Tốc độ thực tế (pixels/frame)
function stamina_get_speed()
{
    if (!isSprinting) return walkSpeed;

    var _ratio = stamina / maxStamina;

    if (_ratio >= 0.20)
    {
        // Thể lực đủ → sprint bình thường
        return sprintSpeed;
    }
    else
    {
        // Thể lực dưới 20% → giảm dần từ sprint về walk
        // _t = 0 khi stamina = 0, _t = 1 khi stamina = 20%
        var _t = _ratio / 0.20;
        return lerp(walkSpeed, sprintSpeed, _t);
    }
}

/// @desc  Trả về tỉ lệ stamina còn lại (0.0 → 1.0).
///        Dùng trong HUD để vẽ thanh và vignette.
/// @return {real}  0.0 (cạn) đến 1.0 (đầy)
function stamina_get_ratio()
{
    return stamina / maxStamina;
}
