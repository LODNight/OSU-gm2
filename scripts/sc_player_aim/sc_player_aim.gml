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
    crosshairBase     = 16;      // Bán kính tối thiểu (pixel) từ tâm ra đến đầu đường kẻ (tăng 30% từ 12)
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

/// @desc  Vẽ tia ngắm phụ (Aim Line) nối từ player hướng tới vị trí chuột.
///        Hàm này chạy trong Draw event (world space).
function aim_draw_aim_line()
{
    if (!showAimLine) exit;

    var _cx = mouse_x;
    var _cy = mouse_y;
    var _distToPlayer = point_distance(x, centerY, _cx, _cy);
    
    // Khoảng cách nét vẽ phù hợp với trạng thái ngắm
    var _base_gap = isAiming ? 4 : 16;
    var _gap = _base_gap + crosshairBloom;
    
    // Vẽ 40% quãng đường từ player hướng về crosshair
    var _lineLen = _distToPlayer * 0.4;
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
            draw_set_alpha(1);
        }
    }
}

/// @desc  Vẽ crosshair động tại vị trí chuột trên lớp GUI.
///        Được gọi trong Draw GUI event để đảm bảo luôn hiển thị trên cùng.
function aim_draw_crosshair()
{
    // Lấy tọa độ chuột trên lớp GUI
    var _cx      = device_mouse_x_to_gui(0);
    var _cy      = device_mouse_y_to_gui(0);
    
    var _accuracy = aim_get_accuracy(); // 1.0 (perfect) -> 0.0 (bloom max)
    
    var _gap, _len, _thick;
    var _color;
    
    if (isAiming)
    {
        // Khi ngắm (ADS): đường kẻ mảnh hơn, ngắn hơn và co sát vào tâm hơn dựa theo độ chính xác
        // 100% chính xác (bloom = 0) tương ứng với gap = 4, len = 3.25 (tăng 30% cho dễ nhìn)
        _gap   = lerp(21, 4, _accuracy) + (crosshairBloom * 0.5);
        _len   = lerp(8, 3.25, _accuracy);
        _thick = 2;
        _color = make_color_rgb(255, 220, 80); // Màu vàng ngắm bắn
    }
    else
    {
        // Khi bắn tự do (Hip-fire): đường nét rộng và dày hơn bình thường (tăng 30%)
        _gap   = crosshairBase + crosshairBloom;
        _len   = 9;
        _thick = 2.5;
        _color = c_white; // Màu trắng thường
    }

    var _alpha = 0.9;
    draw_set_alpha(_alpha);
    draw_set_color(_color);

    // ── Vẽ 4 đường kẻ xung quanh tâm ──
    // Nét trên
    draw_rectangle(_cx - _thick/2, _cy - _gap - _len, _cx + _thick/2, _cy - _gap, false);
    // Nét dưới
    draw_rectangle(_cx - _thick/2, _cy + _gap,         _cx + _thick/2, _cy + _gap + _len, false);
    // Nét trái
    draw_rectangle(_cx - _gap - _len, _cy - _thick/2, _cx - _gap,         _cy + _thick/2, false);
    // Nét phải
    draw_rectangle(_cx + _gap,         _cy - _thick/2, _cx + _gap + _len, _cy + _thick/2, false);

    // ── Vẽ chấm tâm (tăng 30%) ──
    var _dot_radius = isAiming ? 2.0 : 1.5;
    draw_circle(_cx, _cy, _dot_radius, false);

    // Reset draw state
    draw_set_alpha(1);
    draw_set_color(c_white);
}
