// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
enum ENEMY_STATE { 
	IDLE,   // Đứng im quan sát
    WALK,   // Phát hiện mục tiêu -> Rượt!
	HIT,	// Bị tấn công
	RUN,	// Chạy
	DEAD,	// Chết
	ATTACK,	// Tấn công
	INVESTIGATE, // Đi tuần	
	PREPARE_ATTACK, // Khựng lại chuẩn bị đánh
	CHASE,	// Tìm kiếm
	AIM,   // Ngắm
}