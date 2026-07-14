event_inherited()

// Safeguard: đảm bảo global weapon table tồn tại khi test room không có o_init.
if (!variable_global_exists("EnemyWeapons")) sc_weapon_init();

// ================================================================
// o_enemy_parent — Biến nền tảng dùng chung cho TẤT CẢ enemy
// Các child object CHỈ override những gì khác; không khai báo lại ở đây.
// Biến cuối cùng (hp, sprite, weapon...) được set bởi enemy_apply_definition().
// ================================================================

// ──── Chỉ số cơ bản (override bằng enemy_apply_definition) ────
maxHp          = 10       // HP tối đa
hp             = maxHp    // HP hiện tại
chaseSpd       = 1.5      // Tốc độ đuổi theo mục tiêu
aggroRange     = 200      // Khoảng cách bắt đầu phát hiện mục tiêu
attackRange    = 40       // Khoảng cách đánh / bắn
aimCooldown    = 0        // Số frame dừng ngắm trước khi tấn công (0 = không ngắm)
attackCooldown = 45       // Số frame hồi chiêu giữa 2 lần tấn công

// ──── Chuyển động ────
xspd = 0                  // Tốc độ ngang mỗi frame
yspd = 0                  // Tốc độ dọc mỗi frame
face = 1                  // Hướng nhân vật: 1=phải, -1=trái (dùng cho image_xscale)

// ──── Hướng nhìn & vũ khí ────
aimDir           = 0      // Góc nhìn về phía mục tiêu (degree, 0–359)
centerYOffset    = 0      // Độ lệch tâm Y (dùng để canh vị trí vũ khí cho isometric)
centerY          = y      // Tọa độ Y trung tâm thực tế, cập nhật mỗi frame
weaponOffsetDist = 4      // Khoảng cách từ tâm đến vị trí vẽ vũ khí

// ──── Sprite (child PHẢI override qua definition) ────
spr_idle = -1             // Sprite đứng yên
spr_walk = -1             // Sprite di chuyển

// ──── State Machine ────
state = ENEMY_STATE.IDLE  // Trạng thái hiện tại

// ──── Timer chiến đấu ────
aimTimer    = 0           // Đếm số frame đang ngắm
attackTimer = 0           // Đếm hồi chiêu còn lại (>0 = chưa thể đánh)

// ──── Mục tiêu ────
target = noone            // Instance của player đang bị theo dõi

// ──── Kiểu chiến đấu (override trong child group parent: o_enemy_z / o_enemy_gun) ────
enemyCombat = ENEMY_COMBAT.MELEE

// ──── Vũ khí ────
hasWeapon  = false        // true = có vũ khí, vẽ thêm sprite vũ khí
weapon     = noone        // Struct definition của vũ khí (từ global.EnemyWeapons)

// ──── Xác / Death ────
corpseObject = noone      // Object xác để spawn khi chết (noone = không spawn)
deathHandled = false      // Cờ tránh gọi enemy_die() nhiều lần

// ──── Tilemap va chạm ────
tile_map = layer_tilemap_get_id("tile_wall")

// LƯU Ý: KHÔNG gọi get_damaged_create() ở đây.
// Hàm đó sẽ được gọi bên trong enemy_apply_definition() sau khi hp cuối cùng đã được set.
