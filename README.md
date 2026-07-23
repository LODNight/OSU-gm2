# 🔫 Ohaka Shooter (OSU!")

Dự án Game bắn súng Top-down 2D nhịp độ nhanh.

### 🎯 Mục tiêu
Sống sót qua các đợt quái vật, duy trì chuỗi Combo Chain càng cao càng tốt và sống sót lâu nhất có thể.

### 🚀 Cách chạy
1. Mở file `OhakaShooter.yyp` bằng **GameMaker Studio 2**.
2. Nhấn **F5** (Run) để chơi.

### 📁 Cấu trúc Thư mục chính
- `docs/`: Toàn bộ tài liệu phân tích kỹ thuật của dự án.
- `objects/`: Chứa các thực thể (Player, Enemy, Spawner, Bullet).
- `scripts/`: Chứa toàn bộ logic code (Hệ thống vũ khí, AI State Machine).
- `rooms/`: Các màn chơi và giao diện.
- `sprites/`: Hình ảnh và animation.

### 🔄 Luồng Gameplay
1. Khởi động game (Khởi tạo hệ thống).
2. Di chuyển vào vùng **Spawner Zone**.
3. Quái xuất hiện -> Bắn, nạp đạn, né tránh.
4. Tiêu diệt quái liên tục để tăng **Combo**.
5. Hết quái -> Chuyển khu vực mới. Chết -> Nhấn `R` chơi lại.

---
*Đọc chi tiết về thiết kế tại thư mục `docs/`.*
