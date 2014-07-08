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

local regen = -1 --auto
local hoehe = 30
local p = {} -- temporary pos

local config_file = minetest.get_worldpath() .. "/wasserspiel.txt"
local saved_config = {}
info.wld = string.match(minetest.get_worldpath(),".*/(.*)")

local liqfin = is_minetest and minetest.setting_getbool("liquid_finite") 
	or is_freeminer and minetest.setting_getbool("liquid_real")

info.liqfin = liqfin

local function dbgr(name,s)
	if dbg and name == "debugger" then
		if s then minetest.chat_send_player(name,"dbgr>" .. s) end
		return true
	end
	return false
end

local function slog(o)
	print ('LS: ' .. dump(o))
	table.insert(logs.step_log,o)
end

local function flog(o)
	print ('LS: ' .. dump(o))
	table.insert(logs.full_log,o)
end

local function log_cnt(s)
	if logs.gezaehlt[s] then logs.gezaehlt[s] = logs.gezaehlt[s] + 1 else logs.gezaehlt[s] = 1 end 
end

local function log_stat(s,n)
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

local function log_to (player, t0)
	logs.t0 = t0
	local n = player:get_player_name()
	print("@" .. n .. ": " .. t0)
	minetest.chat_send_player(n, t0)
end

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

-- rundungsfehler bei getpos().y kleiner 0 zu klein
local function beinpos(player)
	local pos = player:getpos()
	pos.y = pos.y + .01
	return pos
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
		minetest.sound_play("default_gravel_footstep")
	else
		player:setpos(pos)
		--player:moveto(p,true) --geht nicht beim laufen
		minetest.sound_play("default_sand_footstep")
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

alle_rutschen()

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
		--"Y: " .. player:getpos().y
	}, ", "))
end

minetest.register_node(m .. "cloudlet", {
	tiles = {"default_cloud.png"},
 	-- light_source = 15,
	drawtype = "glasslike",
	tiles = {"default_glass.png"},
	
	groups = {oddly_breakable_by_hand=3},
	on_construct = function(pos)
		if debug then
			minetest.get_meta(pos):set_string("infotext",dump{minetest:get_node_light(p)})
		end
		pos.y = pos.y + 1
		minetest.set_node(pos, {name="default:water_source"})
		pos.y = pos.y - 1
		if not liqfin then minetest.sound_play("default_glass_footstep", {pos = pos, gain = 0.5}) end
	end,
	on_destruct = function(pos)
		pos.y = pos.y + 1
		minetest.set_node(pos, {name="air"})
		pos.y = pos.y - 1
		if not liqfin then minetest.sound_play("default_break_glass", {pos = pos, gain = 0.3}) end
	end,
	on_use = cloudlet_info,
})

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


-- entity-tropfen noch nicht fertig, nicht aktiviert

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
			p.y = p.y + 1
			if  minetest.get_node(p).name == "air" then
				minetest.set_node(p, {name="default:water_source"})
			end
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
	local use_no_object = is_minetest and active_object_count >= 20
	--engine-limit 49 objects max, 20 problem in minetest
	local oy = pos.y
	-- -1 nun lichtregen flag, 1 ist immer an
	if regen == 0 or regen > 1 and math.random(regen) > 1 then return end
	--if regen == 1 then regen = 4 end -- #objects bei 1 >50 per block
	if string.match(node.name, ":desert_") then return end
	local r = 1
	pos.y = pos.y + 6
	if hoehe > 1 then
		if liqfin then
			pos.y = pos.y + hoehe - 1
		else
			pos.y = pos.y + hoehe/2 - 1
		end
	end
	-- 20 ok
	if regen < 0 then
		local l = licht_wert(pos, 16) -- 2 .. 17
		pos.y = pos.y - 1
		--l = l * l
		local r = l <= 1 and 1 or math.random( 1,l )
		if r > 1 then return end
	end

	local drumrum = minetest.get_objects_inside_radius(pos, 2)
	if #drumrum > 0 then return end	

	for x = -r,r do
		p.x = pos.x + x
		for y = -r-1,r do
			p.y = pos.y + y
			for z = -r,r do
				p.z = pos.z + z
				local n = minetest.get_node(p).name
				if n ~= "air" then
					pos.y = oy
					return
				end
			end
		end
	end
	-- if nicht returned then nur air
	if liqfin then
		if use_no_object then
			minetest.set_node(pos, {name="default:water_source"})
		else
			minetest.add_entity(pos, m .. "tropfen")
		end
	else
		minetest.set_node(pos, {name=m .. "cloudlet"})
	end
	pos.y = oy
end

minetest.register_abm({
	nodenames = {"group:crumbly", "group:cracky", "group:snappy", "group:oddly_breakable_by_hand"},
	neighbors = {"air"},
	interval = 1,
	chance = liqfin and 100 or 2500,
	action = neues_cloudlet,
})

local function tropfen(pos, node)
	if not liqfin then return end
	pos.y = pos.y - 1
	if minetest.get_node(pos).name == "air" then
		minetest.set_node(pos, {name="default:water_source"})
		minetest.sound_play("default_glass_footstep", {pos = pos, gain = 0.5})
	end
	pos.y = pos.y + 1
end

if liqfin then
	minetest.register_abm({
		nodenames = {"default:stone"},
		neighbors = {"air"},
		interval = 1,
		chance = 1000,
		action = tropfen,
	})
end

local function erosion (pos, node)
	p.x = pos.x + math.random(-1,1)
	p.y = pos.y + math.random(-1,0)
	p.z = pos.z + math.random(-1,1)
	if "default:water_flowing" == minetest.get_node(p).name then
		pos.y = pos.y + 1
		local n = minetest.get_node(pos).name
		pos.y = pos.y - 1
		if minetest.get_item_group(n, "group:flora") == 0 then
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

if not liqfin then
	minetest.register_abm({
		nodenames = {"default:water_source"},
		neighbors = {"air"},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			for x = -1,1 do
				p.x = pos.x + x
				for y = -1,1 do
					p.y = pos.y + y
					for z = -1,1 do
						p.z = pos.z + z
						local n = minetest.get_node(p).name
						if n ~= "air" and n ~= "default:water_flowing" 
						and (x ~= 0 or y ~= 0 or z ~= 0) then
							return
						end
					end
				end
			end
			minetest.set_node(pos, {name="air"})
		end,
	})
end

function verdunsten(pos, node)
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

local function regen_setzen(name, param)
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
	func = regen_setzen
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
	"craft_guide:lcd_pc", m .. "cloudlet"
}

local function hello(player)
	local n = player:get_player_name()
	minetest.after(1,function()
		gib_fehlendes(player, standard_inventory)	
		minetest.chat_send_all("Wasserspiel begruest " .. n)
		if dbgr(n) then
			gib_fehlendes(player, {
				mn .. ":cloudlet 10", "default:water_source 10"
			})
		end
	end)
end

minetest.register_on_joinplayer(hello)

minetest.register_on_newplayer(function(player)
	local n = player:get_player_name()
end)

minetest.register_on_respawnplayer(function(player)
	local n = player:get_player_name()
	minetest.after(1,function()
		gib_fehlendes(player, standard_inventory)
		minetest.chat_send_all("Wasserspiel begruest " .. n .. " den Wiederbelebten")
	end)
end)

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
		
		print_log(dump(logs.gezaehlt))

	end
	clear_logs()
	minetest.after(3, step)
end

step()

if dbg then
	minetest.after(1, function()
		for i,v in pairs(minetest.registered_craftitems) do
			print(v.name)
			print(dump(minetest.get_craft_recipe(v.
			name)))
		end
	end)
end
