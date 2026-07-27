function dialog_database_create() {
    global.DialogDatabase = {};

    global.DialogDatabase[$ "dlg_marcus_default"] = {
        lines: [
            {
                speaker: "Marcus",
                text: "Chào mừng đến khu vực an toàn. Tôi có thể giúp gì cho anh?",
                choices: [
                    { label: "Mua bán",       action: "open_shop", shop_id: "shop_mechanic_01" },
                    { label: "Xem nhiệm vụ",  action: "open_quests" },
                    { label: "Thôi, để sau",  action: "close" }
                ]
            }
        ]
    };
}
