fx_version 'cerulean'
game 'gta5'

author 'MaDHouSe (Adapted for DSRP by DelPerro Sands RP)'
description 'DSRP Loot Peds - QBCore/qs-inventory compatible dead ped looting system'
version '2.1.0'

lua54 'yes'

ox_lib 'locale'
shared_scripts {
	'@ox_lib/init.lua',
	'shared/config.lua'
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

files {
	'locales/*.json'
}

dependencies {
	'ox_lib',
	'qb-core',
	'ox_target',
	'qs-inventory'
}