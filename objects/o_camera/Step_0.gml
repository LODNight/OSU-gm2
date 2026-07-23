// ── Zoom Camera ──
// Giảm kích thước view để zoom gần hơn 1 chút
var _currentRoom = room;
if (!variable_instance_exists(id, "lastRoom") || lastRoom != _currentRoom)
{
    lastRoom = _currentRoom;
    var _w = camera_get_view_width(view_camera[0]);
    var _h = camera_get_view_height(view_camera[0]);
    
    var _zoomFactor = 0.82; 
    var _newW = round(_w * _zoomFactor);
    var _newH = round(_h * _zoomFactor);
    camera_set_view_size(view_camera[0], _newW, _newH);
}

// Lấy kích thước view hiện tại
var _camW = camera_get_view_width(view_camera[0])
var _camH = camera_get_view_height(view_camera[0])

// ── Center camera trên Player + thêm Aim Bias ──
// Aim bias: camera trôi về phía chuột (tính trong sc_player_aim mỗi frame)
if (instance_exists(o_player))
{
    var _p = o_player;
    // Vị trí camera gốc = giữa player
    var _baseX = _p.x      - _camW / 2;
    var _baseY = _p.centerY - _camH / 2;

    // Áp dụng aim bias (offset do aim module tính sẵn)
    x = _baseX + _p.aimBiasX;
    y = _baseY + _p.aimBiasY;
}

// ── Clamp vào biên phòng ──
x = clamp(x, 0, room_width  - _camW);
y = clamp(y, 0, room_height - _camH);

// ── Áp dụng vị trí camera ──
camera_set_view_pos(view_camera[0], x, y);