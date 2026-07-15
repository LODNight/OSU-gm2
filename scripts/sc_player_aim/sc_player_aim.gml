// ================================================================
// sc_player_aim — Module Ngắm Súng (ADS + Camera Bias + Crosshair Bloom)
//
// Pipeline gọi:
//   Create  → aim_create()
//   Step    → aim_update()  (SAU player_move và player_weapon để biết có bắn không)
//   Draw    → aim_draw_crosshair()
//   Weapon  → aim_get_accuracy() để tính random spread khi bắn
//   Camera  → aim_get_camera_target() để camera biết cần trôi về đâu
// ================================================================

/// @desc  Khởi tạo tất cả biến aim cho player.
///        Gọi một lần trong Create event của o_player.
function aim_create()
{
    // ── Trạng thái ADS ──
    isAiming          = false;   // Đang giữ chuột phải (ADS) không

    // ── Crosshair Bloom ──
    crosshairBase     = 12;      // Bán kính tối thiểu (pixel) từ tâm ra đến đầu đường kẻ
    crosshairBloom    = 0;       // Bloom hiện tại (tăng khi bắn, giảm khi không bắn)
    bloomRecoveryRate = 1.2;     // Pixel giảm mỗi frame khi không bắn
    bloomADS_mult     = 0.4;     // Khi ADS, bloom recovery nhanh hơn x2.5 (x/mult)

    // ── Camera Bias ──
    cameraBiasNormal  = 40;      // Pixel camera kéo về phía chuột khi đi bộ thường
    cameraBiasADS     = 90;      // Pixel camera kéo về phía chuột khi ADS
    cameraLerpSpeed   = 0.07;    // Tốc độ camera trôi (0 = đứng yên, 1 = instant)

    // ── Scope Zoom ──
    baseViewW         = camera_get_view_width(view_camera[0]);   // Kích thước view gốc
    baseViewH         = camera_get_view_height(view_camera[0]);
    currentZoom       = 1.0;     // Zoom hiện tại (lerp về target zoom)

    // ── Camera vị trí nội bộ (dùng bởi o_camera) ──
    aimBiasX          = 0;       // Offset camera theo hướng ngắm (X)
    aimBiasY          = 0;       // Offset camera theo hướng ngắm (Y)
}

/// @desc  Cập nhật trạng thái aim mỗi frame.
///        Gọi trong pipeline Step SAU player_weapon() để biết shotFired.
/// @param {bool} _shotFired  True nếu frame này player vừa bắn (kích hoạt bloom).
function aim_update(_shotFired)
{
    // ── 1. Đọc trạng thái ADS từ input ──
    isAiming = aimKey;

    // ── 2. Bloom ──
    // Tốc độ recovery: nhanh hơn khi ADS, do đó ADS cho phép ngắm chính xác hơn
    var _recovery = isAiming ? bloomRecoveryRate / bloomADS_mult : bloomRecoveryRate;

    if (_shotFired && weapon != noone)
    {
        // Bắn → tăng bloom theo spread của súng (súng scatter thì bloom nhiều)
        var _spreadBloom = weapon.definition.spread * 0.25 + 10;
        crosshairBloom += _spreadBloom;
    }
    else
    {
        // Không bắn → giảm bloom về 0
        crosshairBloom = max(0, crosshairBloom - _recovery);
    }

    // ── 3. Camera Bias: tính offset dịch camera về phía chuột ──
    var _biasDist  = isAiming ? cameraBiasADS : cameraBiasNormal;
    var _targetBiasX = lengthdir_x(_biasDist, aimDir);
    var _targetBiasY = lengthdir_y(_biasDist, aimDir);
    aimBiasX = lerp(aimBiasX, _targetBiasX, cameraLerpSpeed);
    aimBiasY = lerp(aimBiasY, _targetBiasY, cameraLerpSpeed);

    // ── 4. Scope Zoom: lerp view size về target theo scopeZoom của súng ──
    var _targetZoom = 1.0;
    if (isAiming && weapon != noone)
        _targetZoom = weapon.definition.scopeZoom;

    // Zoom in smooth khi ADS, zoom out nhanh hơn khi thả RMB
    var _zoomSpeed = isAiming ? 0.08 : 0.12;
    currentZoom = lerp(currentZoom, _targetZoom, _zoomSpeed);

    // Áp dụng zoom vào view (thay đổi kích thước ảnh camera chiếu lên màn hình)
    camera_set_view_size(view_camera[0],
        baseViewW * currentZoom,
        baseViewH * currentZoom
    );
}

/// @desc  Trả về hệ số chính xác dựa trên bloom hiện tại.
///        Hệ số = 1.0 khi crosshair nhỏ nhất (không bloom), 0.0 khi bloom tối đa.
///        Dùng trong weapon_fire() để tính độ lệch ngẫu nhiên của đạn.
/// @return {real}  0.0 (xịt nhiều) → 1.0 (chuẩn xác)
function aim_get_accuracy()
{
    var _maxBloom = 80;   // Bloom tối đa có thể xảy ra
    return 1.0 - clamp(crosshairBloom / _maxBloom, 0, 1);
}

/// @desc  Vẽ crosshair động tại vị trí chuột.
///        4 đường kẻ (trên/dưới/trái/phải) cách tâm = crosshairBase + bloom.
///        Khi ADS: thêm chấm tâm nhỏ để báo hiệu đang ngắm.
function aim_draw_crosshair()
{
    var _cx      = mouse_x;
    var _cy      = mouse_y;
    var _gap     = crosshairBase + crosshairBloom;  // Khoảng cách từ tâm ra đầu nét
    var _len     = 7;                                // Độ dài mỗi nét
    var _thick   = 2;                                // Độ dày nét (pixel)

    // Màu crosshair: trắng bình thường, vàng khi ADS
    var _color   = isAiming ? make_color_rgb(255, 220, 80) : c_white;
    var _alpha   = 0.9;

    draw_set_alpha(_alpha);
    draw_set_color(_color);

    // Nét trên
    draw_rectangle(_cx - _thick/2, _cy - _gap - _len, _cx + _thick/2, _cy - _gap, false);
    // Nét dưới
    draw_rectangle(_cx - _thick/2, _cy + _gap,         _cx + _thick/2, _cy + _gap + _len, false);
    // Nét trái
    draw_rectangle(_cx - _gap - _len, _cy - _thick/2, _cx - _gap,         _cy + _thick/2, false);
    // Nét phải
    draw_rectangle(_cx + _gap,         _cy - _thick/2, _cx + _gap + _len, _cy + _thick/2, false);

    // Chấm tâm khi ADS (báo đang ngắm)
    if (isAiming)
    {
        draw_set_color(make_color_rgb(255, 220, 80));
        draw_circle(_cx, _cy, 1.5, false);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}
