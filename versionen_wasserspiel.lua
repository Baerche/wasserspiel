wasserspiel = {}

local verfuegbare_versionen = {"dev", "default", "jungle", "kristalltuerme"}

local config_file = minetest.get_worldpath() .. "/wasserspiel.txt"
local saved_config = {}

local function save()
	s = minetest.serialize (saved_config)
	local f,e = io.open(config_file,"w")
	if not f then return print(e) end
	f:write(s)
	f:close()		
end

local function load()
    local f = io.open(config_file, "r")
    if f then
		saved_config = minetest.deserialize (f:read("*all")) or {}
		f:close()
	end
end

load()
if not saved_config.zuletzt_benutzt then
	saved_config.zuletzt_benutzt = "default"
	local n = minetest.setting_get("wasserspiel_new_world_version")
	for _,v in ipairs(verfuegbare_versionen) do
		if v == n then
			saved_config.zuletzt_benutzt = v
		end
	end
	save()
end
local aktiv = saved_config.zuletzt_benutzt

local function choose_version(name, param, global)
	if string.match(param, "%d") then
		local n = verfuegbare_versionen[tonumber(param)]
		if n then
			if not global then
				minetest.chat_send_player(name, "Stelle um auf Wasserpiel/" .. n
					.. " --- Danach Neustart noetig ---")
				saved_config.zuletzt_benutzt = n
				save()
			else
				minetest.chat_send_player(name, "Neue Maps benutzen nun Wasserpiel/" .. n)
				minetest.setting_set("wasserspiel_new_world_version", n)
			end
		end		
	else
		minetest.chat_send_player(name, dump({
			aktiv = aktiv,
			nach_neustart = saved_config.zuletzt_benutzt,
			verfuegbare_versionen
		}))
		if not global then
			minetest.chat_send_player(name, "Hier laeuft Wasserpiel/" .. aktiv)
		else
			minetest.chat_send_player(name, "Bei neuen Spielen läuft Wasserpiel/" 
				.. (minetest.setting_get("wasserspiel_new_world_version") or "default"))
		end
		minetest.chat_send_player(name, "Bitte die Nummer der Version beim kommando eingeben")
	end
end

local choose_version_desc = {
	func = function(name, param) choose_version(name, param) end, 
	description = "Wasserspiel Version setzen. Nach setzen muss neu gestarted werden.",
	params = "version-id",	
}

local choose_global_version_desc = {
	func = function(name, param) choose_version(name, param, true) end, 
	description = "Wasserspiel Version *fuer neues Spiel* setzen. Gilt für neu erstellte maps.",
	params = "version-id",	
}
minetest.register_chatcommand("ws/v", choose_version_desc)
minetest.register_chatcommand("ws/version", choose_version_desc)

minetest.register_chatcommand("ws/gv", choose_global_version_desc)
minetest.register_chatcommand("ws/global-version", choose_global_version_desc)

minetest.register_on_joinplayer(function(player)
	local n = player:get_player_name()
	minetest.after(1,function()
		minetest.chat_send_player(n, "Hier laeuft Wasserpiel/" .. aktiv)
	end)
end)

wasserspiel.dbg = saved_config.zuletzt_benutzt == "dev"
wasserspiel.version = saved_config.zuletzt_benutzt

dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/ws_" .. saved_config.zuletzt_benutzt .. "/wasserspiel.lua")




