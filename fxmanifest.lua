fx_version 'cerulean'
game 'gta5'

description 'Oil Well System for QBCore'
author 'FiveM Lua GPT'
version '1.0.0'
lua54 'yes'

client_script 'client.lua'
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'items.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'oxmysql',
    'ox_target'
}
-- qb-core or qbx-core should be installed but is detected at runtime
