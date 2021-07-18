fx_version 'adamant'
game 'gta5'

client_scripts {
	"config.lua",
	"client/translator.lua",
	"language/**/*",
	"client/utils.lua",
	"client/native_rect.lua",
	"client/client.lua"
}

server_script 'server.lua'

--[[ 
ui_page "html/index.html"
files {
    "html/index.html",
    "html/config_language.js",
    "html/app.js",
    "html/style.css",
    "html/reset.css"
}
]]