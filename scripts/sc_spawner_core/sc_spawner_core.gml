// ================================================================
// sc_spawner_core — Logic cốt lõi cho hệ thống Spawner
// ================================================================

/// @desc  Constructor tạo cấu hình zone spawn bất biến.
///        Dùng: new create_spawner_zone({...}) trong sc_spawner_definitions().
/// @param {struct} _cfg  Struct tham số (xem các field bên dưới).
function create_spawner_zone(_cfg) constructor
{
    // ── Định danh ──
    id = _cfg.id;

    // ── Bảng spawn (array of {obj, weight}) ──
    // weight = tỷ lệ xuất hiện tương đối.
    // Ví dụ: zombie_1 weight=70, zombie_speed weight=30
    //   → zombie_1 có xác suất 70/(70+30) = 70%, zombie_speed 30%.
    // Muốn mọi loại ngang nhau → đặt weight bằng nhau (vd: đều là 1).
    spawnTable = _cfg.spawnTable;

    // ── Giới hạn số lượng ──
    maxEnemies = variable_struct_exists(_cfg, "maxEnemies") ? _cfg.maxEnemies : 8;
    // Tổng số được spawn cả vòng đời → hết thì DEPLETED
    totalLimit = variable_struct_exists(_cfg, "totalLimit") ? _cfg.totalLimit : 20;
    // true = keep spawning forever, while maxEnemies still caps living enemies.
    infinite = variable_struct_exists(_cfg, "infinite") ? _cfg.infinite : false;

    // ── Timer ──
    // Số frame giữa 2 lần spawn liên tiếp (game_fps=60 → 180 = 3 giây)
    spawnDelay = variable_struct_exists(_cfg, "spawnDelay") ? _cfg.spawnDelay : 180;

    // ── Khoảng cách ──
    // Bán kính quanh tâm spawner mà enemy sẽ xuất hiện bên trong
    spawnRadius = variable_struct_exists(_cfg, "spawnRadius") ? _cfg.spawnRadius : 160;
    // Không spawn gần player hơn khoảng cách này (tránh spawn ngay mặt player)
    minPlayerDist = variable_struct_exists(_cfg, "minPlayerDist") ? _cfg.minPlayerDist : 100;
    // Player bước vào trong radius này → spawner thức dậy (IDLE → ACTIVE)
    activationRadius = variable_struct_exists(_cfg, "activationRadius") ? _cfg.activationRadius : 400;
    // Player bước ra ngoài radius này → spawner ngủ, enemy bị deactivate
    // Nên đặt lớn hơn activationRadius để tránh bật/tắt liên tục (hysteresis)
    deactivationRadius = variable_struct_exists(_cfg, "deactivationRadius") ? _cfg.deactivationRadius : 600;

    // ── Tilemap cần tránh ──
    // Danh sách tên layer tilemap. Dễ bổ sung: thêm vào array là xong.
    // Ví dụ: ["tile_wall", "tile_water", "tile_cliff"]
    tileLayers = variable_struct_exists(_cfg, "tileLayers") ? _cfg.tileLayers : ["tile_wall"];

    // ── Boss ──
    // Tỉ lệ % xuất hiện Boss thay vì lính thường (ví dụ: 5 = 5%).
    bossChance = variable_struct_exists(_cfg, "bossChance") ? _cfg.bossChance : 0;
    bossObj = variable_struct_exists(_cfg, "bossObj") ? _cfg.bossObj : undefined;

    // ── Layer tạo instance ──
    instanceLayer = variable_struct_exists(_cfg, "instanceLayer") ? _cfg.instanceLayer : "Instances";
}

// ----------------------------------------------------------------

/// @desc  Tìm điểm spawn hợp lệ: không nằm trên tile, không quá gần player.
///        Thử tối đa 20 lần, nếu không tìm được thì trả về undefined.
/// @param {real}  _sx         Tọa độ X tâm spawner
/// @param {real}  _sy         Tọa độ Y tâm spawner
/// @param {real}  _radius     Bán kính vùng spawn
/// @param {array} _layers     Mảng tên layer tilemap cần tránh (string[])
/// @param {real}  _minDist    Khoảng cách tối thiểu đến player
/// @param {real}  _clearRadius Bán kính vùng an toàn cần trống quanh điểm spawn (ví dụ 16px)
/// @return {struct|undefined}
function spawner_find_valid_point(_sx, _sy, _radius, _layers, _minDist, _clearRadius = 16)
{
    var _MAX_TRIES = 20;

    for (var _i = 0; _i < _MAX_TRIES; _i++)
    {
        // Random điểm trong vòng tròn (không phải hình vuông)
        var _angle = random(360);
        var _dist  = random_range(_radius * 0.25, _radius);
        var _tx    = _sx + lengthdir_x(_dist, _angle);
        var _ty    = _sy + lengthdir_y(_dist, _angle);

        // ── Kiểm tra từng layer tilemap ──
        var _blocked = false;
        var _layer_count = array_length(_layers);
        for (var _j = 0; _j < _layer_count; _j++)
        {
            var _tm = layer_tilemap_get_id(_layers[_j]);
            if (_tm == -1) continue; // layer không tồn tại trong room này → bỏ qua

            // Kiểm tra 4 góc của bounding box thay vì 1 điểm trung tâm để tránh enemy kẹt vào tường
            var _t1 = tilemap_get_at_pixel(_tm, _tx - _clearRadius, _ty - _clearRadius);
            var _t2 = tilemap_get_at_pixel(_tm, _tx + _clearRadius, _ty - _clearRadius);
            var _t3 = tilemap_get_at_pixel(_tm, _tx - _clearRadius, _ty + _clearRadius);
            var _t4 = tilemap_get_at_pixel(_tm, _tx + _clearRadius, _ty + _clearRadius);

            if (_t1 != 0 || _t2 != 0 || _t3 != 0 || _t4 != 0) // ≠ 0 → có tile ở đây
            {
                _blocked = true;
                break;
            }
        }
        if (_blocked) continue;

        // ── Kiểm tra khoảng cách đến player ──
        if (instance_exists(o_player))
        {
            if (point_distance(_tx, _ty, o_player.x, o_player.y) < _minDist)
                continue;
        }

        // Điểm hợp lệ!
        return { x: _tx, y: _ty };
    }

    return undefined; // Không tìm được sau MAX_TRIES lần
}

// ----------------------------------------------------------------

/// @desc  Chọn ngẫu nhiên object từ bảng spawn theo trọng số (weight).
///        Weight cao hơn = xác suất xuất hiện cao hơn.
/// @param  {array} _table  Array of {obj, weight}
/// @return {asset.GMObject}
function spawner_pick_object(_table)
{
    // Tính tổng weight
    var _total  = 0;
    var _len    = array_length(_table);
    for (var _i = 0; _i < _len; _i++)
        _total += _table[_i].weight;

    // Random một số trong [0, total) rồi tìm entry tương ứng
    var _roll  = random(_total);
    var _accum = 0;
    for (var _i = 0; _i < _len; _i++)
    {
        _accum += _table[_i].weight;
        if (_roll < _accum)
            return _table[_i].obj;
    }

    return _table[0].obj; // fallback an toàn
}

// ----------------------------------------------------------------

/// @desc  Thực hiện một lần spawn: tìm điểm → chọn enemy → tạo instance.
///        Gọi từ Step event của o_spawner khi đủ điều kiện.
/// @param {Id.Instance} _spawner  Instance ID của o_spawner đang gọi
function spawner_do_spawn(_spawner)
{
    with (_spawner)
    {
        var _cfg = config;
        var _pt  = spawner_find_valid_point(x, y,
                       _cfg.spawnRadius,
                       _cfg.tileLayers,
                       _cfg.minPlayerDist,
                       16); // Bán kính an toàn 16px để không kẹt tile

        // Không tìm được điểm hợp lệ lần này → thử lại lần sau
        if (_pt == undefined) exit;

        var _obj;
        // Kiểm tra tỉ lệ ra Boss
        if (_cfg.bossObj != undefined && _cfg.bossChance > 0 && random(100) < _cfg.bossChance)
        {
            _obj = _cfg.bossObj;
        }
        else
        {
            _obj = spawner_pick_object(_cfg.spawnTable);
        }

        var _inst = instance_create_layer(_pt.x, _pt.y, _cfg.instanceLayer, _obj);

        // Optional bridge: tutorial-owned spawners tag their enemies for kill tracking.
        if (variable_instance_exists(id, "tutorialOwner") && instance_exists(tutorialOwner)) {
            _inst.tutorialOwner = tutorialOwner;
        }

        // Track instance trong ds_list của spawner này
        ds_list_add(liveEnemies, _inst);
        totalSpawned++;
    }
}

// ----------------------------------------------------------------

/// @desc Vẽ vị trí và thông tin debug của spawner. Gọi trong Draw GUI event của o_spawner.
function sc_spawner_debug_draw(_spawner)
{
    if (!SPAWNER_DEBUG) exit;

    with (_spawner)
    {
        // ── Chuyển tọa độ world → screen ──
        var _vx  = camera_get_view_x(view_camera[0]);
        var _vy  = camera_get_view_y(view_camera[0]);
        var _vw  = camera_get_view_width(view_camera[0]);
        var _vh  = camera_get_view_height(view_camera[0]);
        var _gw  = display_get_gui_width();
        var _gh  = display_get_gui_height();

        var _sx  = (x - _vx) / _vw * _gw;
        var _sy  = (y - _vy) / _vh * _gh;

        // Chỉ vẽ khi nằm gần khung hình camera
        if (_sx >= -100 && _sx <= _gw + 100 && _sy >= -100 && _sy <= _gh + 100)
        {
            var _hw = 16; 
            var _fill_col = c_gray;
            switch (spawnerState) {
                case SPAWNER_STATE.IDLE:     _fill_col = c_yellow; break;
                case SPAWNER_STATE.ACTIVE:   _fill_col = make_color_rgb(50, 220, 80); break;
                case SPAWNER_STATE.DEPLETED: _fill_col = make_color_rgb(220, 60, 60); break;
            }

            draw_set_alpha(0.7);
            draw_set_color(_fill_col);
            draw_rectangle(_sx - _hw, _sy - _hw, _sx + _hw, _sy + _hw, false);

            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_rectangle(_sx - _hw, _sy - _hw, _sx + _hw, _sy + _hw, true);

            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(_sx, _sy, "S");

            var _state_names = ["IDLE", "ACTIVE", "DEPLETED"];
            var _live  = ds_list_size(liveEnemies);
            var _txt
                = "[" + string(zoneId) + "]\n"
                + "St: " + _state_names[spawnerState] + "\n"
                + "Lv: " + string(_live) + "/" + string(config.maxEnemies) + "\n"
                + "Tt: " + string(totalSpawned) + "/" + string(config.totalLimit);

            draw_set_valign(fa_top);
            draw_set_color(c_black);
            draw_text(_sx + 1, _sy + _hw + 4, _txt);
            draw_set_color(c_white);
            draw_text(_sx, _sy + _hw + 3, _txt);

            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(c_white);
        }
    }
}
