/// @desc Player Step coordinator. Systems live in their own scripts.
function player_process()
{
    player_input();     // 1. Đọc input từ o_input
    player_move();      // 2. Di chuyển (dùng stamina_get_speed bên trong)
    stamina_update();   // 3. Cập nhật thể lực sau khi đã biết player có di chuyển không
    player_animation(); // 4. Cập nhật sprite và hướng nhìn
    player_weapon();    // 5. Xử lý bắn / reload / đổi súng
    player_damage();    // 6. Nhận sát thương
    player_state();     // 7. Kiểm tra chết
}

function player_damage()
{
    get_damaged(o_damage_player, true);
}

function player_state()
{
    if (hp > 0) return;
    instance_create_depth(0, 0, -10000, o_gameover_screen);
    instance_destroy();
}
