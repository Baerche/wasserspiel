local dbg = wasserspiel.dbg
if dbg then io.stdout:setvbuf("no") end

local logs = {
	t0 = {}, full_log = {}
}
local info = {dbg = dbg, mn = mn}

local function clear_logs()
	logs.t = {}
	logs.gezaehlt = {}
	logs.step_log = {}
	logs.stats = {}
end

clear_logs()

local is_freeminer = minetest.setting_getbool("liquid_real")
local is_minetest = not is_freeminer

local versionen = {
}

local mn = minetest.get_current_modname()
local m = mn .. ":"

local regen = -1 --lichtabhängig
local hoehe = 30
local p = {} -- temporary pos

local config_file = minetest.get_worldpath() .. "/wasserspiel.txt"
local saved_config = {}
info.wld = string.match(minetest.get_worldpath(),".*/(.*)")

local liqfin = is_freeminer and minetest.setting_getbool("liquid_real")
	-- mit 4.9, wie unterscheiden?
	-- or is_minetest and minetest.setting_getbool("liquid_finite") 

info.liqfin = liqfin


--
-- logging
--

local function dbgr(name,s)
	if dbg and name == "debugger" then
		if s then minetest.chat_send_player(name,"dbgr>" .. s) end
		return true
	end
	return false
end

-- logs sammeln und nach programmstart ausgeben. Leichter zu sehen beim debuggen
-- ausserdem, statistiken werden alle paar sekunden ausgegeben. Log scrollt weg.
-- also wird das log auch alle paar sekunden wieder ausgegeben.

--step-log wird nach step-ausgabe gelöscht
local function slog(o)
	print ('LS: ' .. dump(o))
	table.insert(logs.step_log,o)
end

-- full_log bleibt komplett, hauptsächlich für startausgaben
local function flog(o)
	print ('LS: ' .. dump(o))
	table.insert(logs.full_log,o)
end

-- zählt
local function log_cnt(zaehl_dies)
	local s = zaehl_dies
	if logs.gezaehlt[s] then logs.gezaehlt[s] = logs.gezaehlt[s] + 1 else logs.gezaehlt[s] = 1 end 
end

-- macht statistik: mittelwert, min max. aufruf:
local function log_stat(zaehl_dies,aktueller_wert)
	local s = zaehl_dies
	local n = aktueller_wert
	local l = logs.stats[s]
	if not l then
		l = {mit = 0, ges = 0, anz = 0, min = n, max = n, }
		logs.stats[s] = l
	end
	l.ges = l.ges + n
	l.anz = l.anz + 1
	l.mit = l.ges / l.anz
	if n < l.min then l.min = n end
	if n > l.max then l.max = n end
end

--veraltet, bleibt noch als api-beispiel
local function log_to (player, t0)
	local n = player:get_player_name()
	print("@" .. n .. ": " .. t0)
	minetest.chat_send_player(n, t0)
end

--
--config und so persistenz
--

local function save()
	local t = saved_config
	t.benutzte_versionen = versionen
	t.regen = regen
	t.hoehe = hoehe
	s = minetest.serialize (t)
	local f,e = io.open(config_file,"w")
	if not f then return print(e) end
	f:write(s)
	f:close()		
end

local function load()
    local f = io.open(config_file, "r")
    if f then
		local t = minetest.deserialize (f:read("*all")) or {}
		saved_config = t
		f:close()
		regen = t.regen or regen
		hoehe = t.hoehe or hoehe
		if t.benutzte_versionen then
			versionen = t.benutzte_versionen
		end
	end
end

load()

--
-- licht-tools
--

local function licht_text(pos)
	if not pos then return "nicht in welt" end
	if string.match( minetest.get_node(pos).name,":water_") then return "wasser-bug" end
	return minetest.get_node_light(pos) or "kein licht"
end

local function licht_wert(pos, wenn_fehlt)
	if not pos then return wenn_fehlt end
	if string.match( minetest.get_node(pos).name,":water_") then return wenn_fehlt end
	return minetest.get_node_light(pos) or wenn_fehlt
end


-- alte info-funktion, mal aufräumen
local function wasserspiel_info(name, param)
	info.you = name
	info.regen = regen
	info.hoehe = hoehe
	minetest.chat_send_player(name, dump(info))
	if dbgr(name) then
		minetest.chat_send_player(name, dump(logs))
		print("@" .. name)
		print(dump(logs))
		print(dump(info))
	end
end
minetest.register_chatcommand("ws?", {func = wasserspiel_info})

--
-- rutschen
--

-- rundungsfehler bei getpos().y kleiner 0 zu klein
local function beinpos(player)
	local pos = player:getpos()
	pos.y = pos.y + .01
	return pos
end

local function bein2playerpos(beinpos)
	beinpos.y = beinpos.y - .01
end

local rutsch_dirs = {{-1,0},{1,0},{0,-1},{0,1}}
local function rutschen(player)
	local pos = beinpos(player)
	--2d non diagonal
	local d = rutsch_dirs[math.random(#rutsch_dirs)]
	pos.x = pos.x + d[1]
	pos.z = pos.z + d[2]
	local dort = minetest.registered_nodes[minetest.get_node(pos).name]
	pos.y = pos.y + 1
	local above_dort = minetest.registered_nodes[minetest.get_node(pos).name]
	pos.y = pos.y - 1
	if dort.walkable or above_dort.walkable then
		--s minetest.sound_play("default_gravel_footstep")
	else
		bein2playerpos(pos)
		player:setpos(pos)
		--s minetest.sound_play("default_sand_footstep")
	end
end

local function alle_rutschen()
	for i,player in ipairs(minetest.get_connected_players()) do
		if true -- math.random(5) == 1
		and	minetest.get_node(beinpos(player)).name == "default:water_flowing" then
			rutschen(player)
		end
	end
	minetest.after(1, alle_rutschen)
end

alle_rutschen() -- trigger after

--
-- cloudlets wurden benutzt um wasserquellen festzuhalten und wieder zu löschen.
-- setzen in die luft ging nicht, gingen kaputt
-- und löschen brauchte eine markierung für die abm
-- das fliegt raus.
--
-- nebenbei als debuganzeigetool benutzt
--

local function cloudlet_info(itemstack, player, ps)
	minetest.chat_send_player(player:get_player_name(), "---infos:")
	wasserspiel_info(player:get_player_name())
	local p = beinpos(player)
	log_to (player, table.concat ({
		"HIT: " .. (ps.under and minetest.get_node(ps.under).name or "nix"),
		"ABOVE: " .. (ps.above and minetest.get_node(ps.above).name or "nix"),
		"INV#1: " .. player:get_inventory():get_stack("main", 1):to_string(),
		"LEGS: " .. minetest.get_node(beinpos(player)).name,
		--"LEGS: " .. minetest.get_node(player:getpos()).name, --rundungsfehler
		"Y: " .. player:getpos().y
	}, ", "))
end

minetest.register_node(m .. "cloudlet", {
	tiles = {"default_cloud.png"},
	drawtype = "glasslike",
	tiles = {"default_glass.png"},
	groups = {oddly_breakable_by_hand=3},
	on_use = cloudlet_info,
})

-- cloudlet wieder löschen, aufräumen für alte maps
minetest.register_abm({
	nodenames = {m .. "cloudlet"},
	interval = liqfin and 2 or 3,
	chance = liqfin and 1 or 3,
	action = function (pos, node)
		minetest.set_node(pos, {name="air"})
		pos.y = pos.y + 1
		minetest.set_node(pos, {name="air"})
		pos.y = pos.y - 1
	end,
})

--
-- regentools
--

local function is_watersource_stabil(p)
	local p2 = {y = p.y}
	for x = -1, 1,2 do
		for z = -1, 1, 2 do
			p2.x = p.x + x
			p2.z = p.z + z
			if minetest.get_node(p2).name == "default:water_source" then
				return true
			end
		end
	end
	return false
end

--
-- regen nun per objekte
--

local cb = 0.5
minetest.register_entity(m .. "tropfen", {
	state = nil,
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-cb,-cb,-cb, cb,cb,cb},
		visual = "sprite",
		visual_size = {x=1, y=1},
		textures = {"default_water.png"},
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
	},
	on_punch = function(self, hitter)
		local player = hitter
		self.object:remove()
	end,	
	on_step = function(self, dtime)
		self.state.alter = self.state.alter + dtime
		if self.state.alter > 60 then
			flog("Zu alt " .. dump({self.object:getpos(), self.state}))
			self.object:remove()
		end
		local p = self.object:getpos()
		p.y = p.y - .52
		if minetest.get_node(p).name ~= "air" then
			self.object:remove()
			p.y = p.y + .52
			if  minetest.get_node(p).name ~= "air" then
				return
			end
			if is_watersource_stabil(p) then 
				return
			end
			minetest.set_node(p, {name="default:water_source"})
			--s minetest.sound_play("default_break_glass", {pos = pos, gain = 0.3})
		end
	end,
	on_activate = function(self, staticdata)
		staticdata = minetest.deserialize(staticdata)
		self.state = staticdata or {}
		local neu = self.state == {}
		if not self.state.alter then self.state.alter = 0 end
		if not staticdata then
			self.object:setvelocity({x = 0, y = -5, z = 0})
		end
	end,
	get_staticdata = function(self)
		return minetest.serialize(state)
	end,
})

local function neues_cloudlet(pos, node, active_object_count, active_object_count_wider)
	log_cnt "abm neues"
	-- -1 macht regenstärke lichtabhängig, 1.. ist immer an per zufall, 0 aus
	if regen == 0 or regen > 1 and math.random(regen) > 1 then return end
	-- nicht in wüste
	if string.match(node.name, ":desert_") then return end
	pos.y = pos.y + 20
	local r = 1
	if regen < 0 then
		local l = licht_wert(pos, 16) -- 2 .. 17
		local r = l <= 1 and 1 or math.random( 1,l )
		if r > 1 then return end
	end
	if minetest.get_node(pos).name ~= "air" then return end
	log_cnt "wirklich neues"
	minetest.add_entity(pos, m .. "tropfen")
	--s minetest.sound_play("default_glass_footstep", {pos = pos, gain = 0.5}) 
end

minetest.register_abm({
	nodenames = {"group:crumbly", "group:cracky", "group:snappy", "group:oddly_breakable_by_hand"},
	neighbors = {"air"},
	interval = 1,
	chance = liqfin and 100 or 2500,
	action = neues_cloudlet,
})

--
-- extras
--

local function tropfen(pos, node)
	pos.y = pos.y - 1
	if minetest.get_node(pos).name == "air" then
		minetest.add_entity(pos, m .. "tropfen")
		--s minetest.sound_play("default_glass_footstep", {pos = pos, gain = 0.5})
	end
end

minetest.register_abm({
	nodenames = {"default:stone"},
	neighbors = {"air"},
	interval = 1,
	chance = 1000,
	action = tropfen,
})

local function erosion (pos, node)
	p.x = pos.x + math.random(-1,1)
	p.y = pos.y + math.random(-1,0)
	p.z = pos.z + math.random(-1,1)
	if "default:water_flowing" == minetest.get_node(p).name then
		--gras, blumen verhindern erosion. theoretisch. klappt nicht.
		pos.y = pos.y + 1
		local n = minetest.get_node(pos).name
		pos.y = pos.y - 1
		if minetest.get_item_group(n, "group:flora") == 0 then
			-- TODO meta-inf und so fehlt.
			local o = minetest.get_node(p)
			minetest.set_node(p, minetest.get_node(pos))
			minetest.set_node(pos, o)
		end
	end
end
	
minetest.register_abm({
	nodenames =  {"group:crumbly"},
	neighbors = {"default:water_flowing"},
	interval = 1,
	chance = 1000,
	action = erosion,
})

local function einzelne_watersources_loeschen(pos, node)
	log_cnt "watersources"
	if not is_watersource_stabil(pos) then
		log_cnt "watersources unstabil"
		minetest.set_node(pos, {name="air"})
	end
end
minetest.register_abm({
	nodenames = {"default:water_source"},
	neighbors = {"air"},
	interval = 1,
	chance = 1,
	action = einzelne_watersources_loeschen,
})


local function verdunsten(pos, node)
	if freeminer then return end
	if not liqfin then return end
	if hoehe == 1 or regen ~= -1 then return end
	pos.y = pos.y + 1
	local n = minetest.get_node(p).name
	pos.y = pos.y - 1
	if n == "air" then
		pos.y = pos.y + 1
		local l = 16 - licht_wert(pos,15)
		pos.y = pos.y - 1
		if l == 1 or math.random(1,l) == 1 then
			minetest.set_node(pos, {name="air"})
		end
	end
end

if liqfin then
	minetest.register_abm({
		nodenames = {"default:water_flowing"},
		neighbors = {"air"},
		interval = 5,
		chance = 1 ,
		action = verdunsten,
	})
end

--
-- chat-commands
--

local function regenstaerke_setzen(name, param)
		logs.t0 = {}
		if param == "" then
			logs.t0 = "Regen: " .. regen .. ", Hoehe " .. hoehe
		else
			local r, h = string.match(param,"(-?%d*),?(%d*)")
			logs.t0 = ""
			if r ~= "" then
				logs.t0 = "Regen von " .. regen .. " auf " .. r
				regen = tonumber(r)
			end
			if h ~= "" then
				logs.t0 = logs.t0 .. ", Hoehe von " .. hoehe .. " auf " .. h
				hoehe = tonumber(h)
			end
			save()
		end
		minetest.chat_send_player(name, dump(logs.t0))
	end
	
minetest.register_chatcommand("rain", {
	func = regenstaerke_setzen
})

local function gib_fehlendes(player, liste)
	local iv = player:get_inventory()
	for i,st in ipairs(liste) do
		local n = string.match(st, '[^%s]*')
		if (minetest.registered_nodes[n]  or minetest.registered_tools[n])
		and not iv:contains_item("main", st) then
			iv:add_item("main", st)
		end
	end
end

local standard_inventory = {
	"default:torch 4", "default:pick_wood", "default:apple 10",
}

local function hello(player)
	local n = player:get_player_name()
	minetest.after(1,function()
		gib_fehlendes(player, standard_inventory)	
		minetest.chat_send_all("Wasserspiel begruest " .. n)
		if dbgr(n) then
			gib_fehlendes(player, {
				"default:ladder 10",
				mn .. ":cloudlet 10", "default:water_source 10"
			})
		end
	end)
end

minetest.register_on_joinplayer(hello)

minetest.register_on_respawnplayer(function(player)
	local n = player:get_player_name()
	minetest.after(1,function()
		gib_fehlendes(player, standard_inventory)
		minetest.chat_send_all("Wasserspiel begruest " .. n .. " den Wiederbelebten")
	end)
end)

--
-- logging 2
--

local function print_log(s)
	print(s)
	local pn = "debugger"
	local player = minetest.get_player_by_name(pn)
	if player then
		minetest.chat_send_player(pn, s)
	end
end


local function step()
	info.tm = minetest.get_timeofday()
	
	if dbg then
		
		print_log(""
			.. " GEZAEHLT " .. dump(logs.gezaehlt)
			.. " STATS " .. dump(logs.stats)
		)

	end
	clear_logs()
	minetest.after(3, step)
end

step()

-- sollte extra mod sein, war gerade neugierig
if dbg then
	minetest.after(1, function()
		for i,v in pairs(minetest.registered_craftitems) do
			print(v.name)
			print(dump(minetest.get_craft_recipe(v.name)))
		end
	end)
end
