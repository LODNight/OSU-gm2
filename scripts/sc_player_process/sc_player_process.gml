/// @desc Player Step coordinator. Systems live in their own scripts.
function player_process()
{
    player_input();
    player_move();
    player_animation();
    player_weapon();
    player_damage();
    player_state();
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
