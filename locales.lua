Locales = {}

function Lang(key, ...)
    local locale = Config.Locale or 'en'
    if Locales[locale] and Locales[locale][key] then
        local str = Locales[locale][key]
        if select('#', ...) > 0 then
            return string.format(str, ...)
        end
        return str
    else
        return 'Translation [' .. locale .. '][' .. key .. '] missing'
    end
end

-- ============================================ --
-- BAHASA INDONESIA
-- ============================================ --
Locales['id'] = {
    -- Notification
    ['no_pet'] = 'Kamu tidak memiliki pet. Beli di Pet Shop terlebih dahulu.',
    ['pet_fainted'] = '%s pingsan/mati karena kelaparan atau luka.',
    ['pet_shot'] = '%s tewas tertembak/terluka parah!',
    ['pet_returned'] = 'Pet dikembalikan.',
    ['pet_called'] = '%s dipanggil.',
    ['pet_deleted'] = 'Peliharaan telah dibuang.',
    ['pet_delete_cancel'] = 'Penghapusan dibatalkan.',
    ['k9_sniffing'] = 'K9 sedang mengendus...',
    ['k9_bark'] = 'K9 MENGGONGGONG! (Ada Barang Ilegal)',
    ['k9_clean'] = 'K9 diam. (Bersih)',
    ['k9_npc_clean'] = 'K9 selesai mengendus. Penduduk ini bersih.',
    ['k9_no_target'] = 'Tidak ada orang atau penduduk di dekat sini untuk diendus.',
    ['k9_attacking'] = 'K9 Menyerang Target!',
    ['k9_return'] = 'K9 ditarik kembali.',
    ['need_vehicle'] = 'Kamu harus berada di dalam kendaraan terlebih dahulu!',
    ['feed_success'] = 'Berhasil memberi %s',
    ['no_item'] = 'Kamu tidak memiliki item: %s',
    ['heal_success'] = 'Pet berhasil disembuhkan (Health Penuh)!',
    ['k9_only'] = 'Hanya Polisi K9 yang bisa memiliki jenis ini!',
    ['not_enough_money'] = 'Uang tidak cukup!',
    ['adopt_success'] = 'Berhasil mengadopsi %s!',
    ['adopt_fail'] = 'Gagal menyimpan pet.',
    ['adopt_fail_model'] = 'Gagal memuat model peliharaan.',
    ['revive_success'] = 'Pet berhasil dihidupkan kembali!',
    ['need_revive'] = 'Kamu membutuhkan item: pet_revive',
    
    -- Main Menu
    ['main_menu_title'] = 'Menu Peliharaan',
    ['return_pet'] = '💼 Pulangkan %s',
    ['return_pet_desc'] = 'Masukkan pet kembali ke rumah.',
    ['command_pet_menu'] = '🐕 Beri Perintah',
    ['command_pet_desc'] = 'Akses menu interaksi pet.',
    ['summon_pet_menu'] = '🐾 Keluarkan Pet',
    ['summon_pet_desc'] = 'Pilih pet untuk dikeluarkan.',
    ['shop_menu'] = '🛒 Pet Shop',
    ['shop_menu_desc'] = 'Adopsi pet baru.',
    
    -- Sub Menu & Dialog
    ['pet_menu_title'] = 'Daftar Peliharaan',
    ['pet_shop_title'] = 'Pet Shop',
    ['pet_shop_k9'] = ' [K9]',
    ['pet_shop_free'] = 'Gratis (Khusus Polisi)',
    ['pet_shop_price'] = 'Harga: $%s',
    ['buy_pet'] = 'Beli ($%s)',
    ['buy_pet_desc'] = 'Beli peliharaan ini seharga $%s.',
    ['pet_name_input'] = 'Beri Nama Pet',
    ['pet_name_label'] = 'Nama untuk peliharaan barumu:',
    ['pet_action_title'] = 'Aksi: %s',
    ['pet_dead_action_title'] = 'Aksi: %s (Tewas)',
    ['pet_dead_status'] = '☠️ %s (Tewas)',
    ['pet_dead_desc'] = 'Gunakan Pet Revive atau Buang secara permanen.',
    ['pet_info'] = 'Model: %s\nStatus: Health %s%%',
    ['spawn_pet'] = '🐾 Keluarkan %s',
    ['spawn_pet_desc'] = 'Panggil pet ini untuk mengikutimu.',
    ['delete_pet'] = '⚠️ Buang Peliharaan',
    ['delete_pet_desc'] = 'Hapus permanen dari database.',
    ['revive_pet'] = '💉 Hidupkan Kembali',
    ['revive_pet_desc'] = 'Gunakan item pet_revive untuk menghidupkan pet ini.',
    ['confirm_delete_title'] = 'Buang %s',
    ['confirm_delete_content'] = 'Apakah Anda yakin ingin membuang dan menghapus **%s** selamanya?\n\nTindakan ini tidak dapat dibatalkan!',
    ['cancel'] = 'Batal',
    ['confirm_delete'] = 'Ya, Hapus',
    
    -- Interaksi
    ['interact_title'] = 'Interaksi Pet',
    ['interact_label'] = 'Berinteraksi dengan %s',
    ['feed_food'] = '🍖 Beri Makan',
    ['feed_food_desc'] = 'Mengurangi rasa lapar.',
    ['feed_water'] = '💧 Beri Minum',
    ['feed_water_desc'] = 'Mengurangi rasa haus.',
    ['pet_dog'] = '🖐️ Elus',
    ['pet_dog_desc'] = 'Bermain dengan peliharaan.',
    ['heal_pet_action'] = '💊 Beri Obat (Heal)',
    ['heal_pet_desc'] = 'Gunakan Pet Medkit untuk menyembuhkan luka.',
    ['command_sit_follow'] = '🛑 Perintah (Duduk/Ikuti)',
    ['toggle_vehicle'] = '🚗 Kendaraan',
    ['toggle_vehicle_desc'] = 'Masuk/Keluar Kendaraan',
    ['k9_sniff'] = 'K9: Endus Target',
    ['k9_attack'] = 'K9: Serang Target',
    
    -- Progress Bar
    ['prog_food'] = 'Memberi Makan...',
    ['prog_water'] = 'Memberi Minum...',
    ['prog_play'] = 'Bermain dengan pet...',
    ['prog_heal'] = 'Mengobati Pet...'
}


-- ============================================ --
-- ENGLISH
-- ============================================ --
Locales['en'] = {
    -- Notification
    ['no_pet'] = 'You have no pet. Buy one at the Pet Shop first.',
    ['pet_fainted'] = '%s fainted/died from starvation.',
    ['pet_shot'] = '%s got shot/heavily injured!',
    ['pet_returned'] = 'Pet returned.',
    ['pet_called'] = '%s summoned.',
    ['pet_deleted'] = 'Pet permanently deleted.',
    ['pet_delete_cancel'] = 'Deletion cancelled.',
    ['k9_sniffing'] = 'K9 is sniffing...',
    ['k9_bark'] = 'K9 BARKING! (Illegal Items Found)',
    ['k9_clean'] = 'K9 is silent. (Clean)',
    ['k9_npc_clean'] = 'K9 finished sniffing. The ped is clean.',
    ['k9_no_target'] = 'No person nearby to sniff.',
    ['k9_attacking'] = 'K9 Attacking Target!',
    ['k9_return'] = 'K9 recalled.',
    ['need_vehicle'] = 'You need to be in a vehicle first!',
    ['feed_success'] = 'Successfully gave %s',
    ['no_item'] = 'You don\'t have item: %s',
    ['heal_success'] = 'Pet successfully healed (Full Health)!',
    ['k9_only'] = 'Only K9 Police can own this breed!',
    ['not_enough_money'] = 'Not enough money!',
    ['adopt_success'] = 'Successfully adopted %s!',
    ['adopt_fail'] = 'Failed to save pet.',
    ['adopt_fail_model'] = 'Failed to load pet model.',
    ['revive_success'] = 'Pet successfully revived!',
    ['need_revive'] = 'You need item: pet_revive',
    
    -- Main Menu
    ['main_menu_title'] = 'Pet Menu',
    ['return_pet'] = '💼 Return %s',
    ['return_pet_desc'] = 'Tell pet to go home.',
    ['command_pet_menu'] = '🐕 Command Pet',
    ['command_pet_desc'] = 'Access pet interaction menu.',
    ['summon_pet_menu'] = '🐾 Summon Pet',
    ['summon_pet_desc'] = 'Choose a pet to summon.',
    ['shop_menu'] = '🛒 Pet Shop',
    ['shop_menu_desc'] = 'Adopt a new pet.',
    
    -- Sub Menu & Dialog
    ['pet_menu_title'] = 'Pet List',
    ['pet_shop_title'] = 'Pet Shop',
    ['pet_shop_k9'] = ' [K9]',
    ['pet_shop_free'] = 'Free (Police Only)',
    ['pet_shop_price'] = 'Price: $%s',
    ['buy_pet'] = 'Buy ($%s)',
    ['buy_pet_desc'] = 'Buy this pet for $%s.',
    ['pet_name_input'] = 'Name Your Pet',
    ['pet_name_label'] = 'Name for your new pet:',
    ['pet_action_title'] = 'Action: %s',
    ['pet_dead_action_title'] = 'Action: %s (Dead)',
    ['pet_dead_status'] = '☠️ %s (Dead)',
    ['pet_dead_desc'] = 'Use Pet Revive or Delete permanently.',
    ['pet_info'] = 'Model: %s\nStatus: Health %s%%',
    ['spawn_pet'] = '🐾 Summon %s',
    ['spawn_pet_desc'] = 'Call this pet to follow you.',
    ['delete_pet'] = '⚠️ Discard Pet',
    ['delete_pet_desc'] = 'Permanently delete from database.',
    ['revive_pet'] = '💉 Revive Pet',
    ['revive_pet_desc'] = 'Use pet_revive item to bring pet back to life.',
    ['confirm_delete_title'] = 'Discard %s',
    ['confirm_delete_content'] = 'Are you sure you want to discard and delete **%s** forever?\n\nThis action cannot be undone!',
    ['cancel'] = 'Cancel',
    ['confirm_delete'] = 'Yes, Delete',
    
    -- Interaksi
    ['interact_title'] = 'Pet Interaction',
    ['interact_label'] = 'Interact with %s',
    ['feed_food'] = '🍖 Feed',
    ['feed_food_desc'] = 'Decrease hunger.',
    ['feed_water'] = '💧 Give Water',
    ['feed_water_desc'] = 'Decrease thirst.',
    ['pet_dog'] = '🖐️ Pet',
    ['pet_dog_desc'] = 'Play with your pet.',
    ['heal_pet_action'] = '💊 Give Meds (Heal)',
    ['heal_pet_desc'] = 'Use Pet Medkit to heal injuries.',
    ['command_sit_follow'] = '🛑 Command (Sit/Follow)',
    ['toggle_vehicle'] = '🚗 Vehicle',
    ['toggle_vehicle_desc'] = 'Enter/Exit Vehicle',
    ['k9_sniff'] = 'K9: Sniff Target',
    ['k9_attack'] = 'K9: Attack Target',
    
    -- Progress Bar
    ['prog_food'] = 'Feeding...',
    ['prog_water'] = 'Giving Water...',
    ['prog_play'] = 'Playing with pet...',
    ['prog_heal'] = 'Healing Pet...'
}
