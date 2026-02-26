fx_version 'cerulean'
game 'gta5'

author 'AP Code'
description 'Pet System with Needs & K9 Features'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'locales.lua',
    'config.lua'
}

client_scripts {
    'client/ui_bridge.lua',
    'client/main.lua',
    'client/interaction.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'peds.meta'
}

data_file 'PED_METADATA_FILE' 'peds.meta'

lua54 'yes'
