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
    maxBloom          = 60;      // Giới hạn độ giãn tối đa của crosshair
    bloomRecoveryRate = 1.2;     // Pixel giảm mỗi frame khi không bắn
    bloomADS_mult     = 0.4;     // Khi ADS, bloom recovery nhanh hơn x2.5 (x/mult)

    // ── UI / Settings ──
    showAimLine       = true;    // (Cài đặt) Bật/tắt đường tia ngắm mỏng nối với player

    // ── Camera Bias ──
    cameraBiasNormal  = 40;      // Pixel camera kéo về phía chuột khi đi bộ thường
    cameraBiasADS     = 90;      // Pixel camera kéo về phía chuột khi ADS
    cameraLerpSpeed   = 0.07;    // Tốc độ camera trôi (0 = đứng yên, 1 = instant)

    // ── Scope Zoom ──
    // Zoom hiện tại đã đổi thành việc đẩy camera đi xa hơn thay vì đổi view size
    // để tránh bị lỗi HUD scale up


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
    
    // Giới hạn bloom không vượt quá mức tối đa
    crosshairBloom = min(crosshairBloom, maxBloom);

    // ── 3. Camera Bias: tính offset dịch camera về phía chuột ──
    var _mouseDist = point_distance(x, centerY, mouse_x, mouse_y);
    
    // Camera kéo theo bao nhiêu % khoảng cách đến chuột
    var _biasFraction = isAiming ? 0.35 : 0.15;
    var _biasDist = _mouseDist * _biasFraction;
    
    // Tính khoảng cách kéo tối đa cho phép
    var _maxBias  = isAiming ? cameraBiasADS : cameraBiasNormal;
    
    // Nếu đang ngắm xa (scopeZoom nhỏ hơn 1), cho phép giới hạn kéo camera xa hơn
    if (isAiming && weapon != noone)
    {
        var _zoomMult = 1.0 / max(0.1, weapon.definition.scopeZoom);
        _maxBias *= _zoomMult;
    }
    
    // Chốt khoảng cách bias không vượt quá max
    _biasDist = min(_biasDist, _maxBias);

    var _targetBiasX = lengthdir_x(_biasDist, aimDir);
    var _targetBiasY = lengthdir_y(_biasDist, aimDir);
    aimBiasX = lerp(aimBiasX, _targetBiasX, cameraLerpSpeed);
    aimBiasY = lerp(aimBiasY, _targetBiasY, cameraLerpSpeed);
}

/// @desc  Trả về hệ số chính xác dựa trên bloom hiện tại.
///        Hệ số = 1.0 khi crosshair nhỏ nhất (không bloom), 0.0 khi bloom tối đa.
///        Dùng trong weapon_fire() để tính độ lệch ngẫu nhiên của đạn.
/// @return {real}  0.0 (xịt nhiều) → 1.0 (chuẩn xác)
function aim_get_accuracy()
{
    return 1.0 - clamp(crosshairBloom / maxBloom, 0, 1);
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
    
    // ── Vẽ tia ngắm phụ (Aim Line) ──
    if (showAimLine)
    {
        var _distToPlayer = point_distance(x, centerY, _cx, _cy);
        
        // Vẽ 40% quãng đường từ player hướng về crosshair
        var _lineLen = _distToPlayer * 0.4;
        
        // Bắt đầu vẽ cách xa nhân vật một khoảng nhỏ để không bị đè lên sprite nhân vật
        var _startDist = 20; 
        
        if (_distToPlayer > _startDist) 
        {
            var _endDist = _startDist + _lineLen;
            
            // Đảm bảo nét vẽ không vượt quá vị trí tâm ngắm (để trông thẩm mỹ)
            var _maxAllowedDist = _distToPlayer - (_gap + 4);
            if (_endDist > _maxAllowedDist) {
                _endDist = _maxAllowedDist;
            }
            
            if (_endDist > _startDist) {
                var _startX = x + lengthdir_x(_startDist, aimDir);
                var _startY = centerY + lengthdir_y(_startDist, aimDir);
                var _endX   = x + lengthdir_x(_endDist, aimDir);
                var _endY   = centerY + lengthdir_y(_endDist, aimDir);
                
                draw_set_alpha(0.3);  // Làm nét mảnh, mờ để không bị rối mắt
                draw_set_color(c_white);
                draw_line(_startX, _startY, _endX, _endY);
            }
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}
