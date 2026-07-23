/// @description Insert description here
// You can write your code in this editor
if instance_exists(o_player){
	playerHp = o_player.hp;
	playerMaxHp = o_player.maxHp;
	
	if (playerHpDelay == -1) {
		playerHpDelay = playerHp;
	}
	
	if (playerHpDelay > playerHp) {
		playerHpDelay = lerp(playerHpDelay, playerHp, 0.05);
		if (playerHpDelay - playerHp < 0.1) {
			playerHpDelay = playerHp;
		}
	} else {
		playerHpDelay = playerHp;
	}
} else {
	playerHp = 0;
	if (playerHpDelay > 0) {
		playerHpDelay = lerp(playerHpDelay, 0, 0.05);
		if (playerHpDelay < 0.1) {
			playerHpDelay = 0;
		}
	}
}