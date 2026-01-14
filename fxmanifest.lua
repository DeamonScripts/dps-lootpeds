--[[
    dps-lootpeds - State Bag Synced Ped Looting
    Framework: QB/QBX/ESX
    Original: MaDHouSe (mh-lootpeds)
    Enhanced: @daemonAlex

    Features:
    - State Bag sync (no body deletion required)
    - Model-specific loot tables
    - Framework agnostic (QB/QBX/ESX)
    - Inventory agnostic (ox/qs/qb)
    - Optional police/evidence integration
]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dps-lootpeds'
author 'DPS Development (Original: MaDHouSe)'
description 'State Bag synced ped looting with model-specific loot tables'
version '3.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'bridge/init.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server.lua',
    'server/main.lua',
}

files {
    'locales/*.json',
}

dependencies {
    'ox_lib',
    'ox_target',
}

provides {
    'dps-lootpeds',
    'mh-lootpeds', -- Backwards compatibility
}
