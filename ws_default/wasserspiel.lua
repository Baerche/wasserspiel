local mn = minetest.get_current_modname()
local dbg = nil ~= string.match(mn,"_dev$")
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




if wasserspiel then

local s = "Mehrere wasserspiel-mods geladen, '" ..mn .. "' deaktivierte sich, '"
.. wasserspiel.mn .. "' laeuft."
print (s)

minetest.register_on_joinplayer(function(player)
	print(s)
	minetest.after(1,function()
		minetest.chat_send_player(player:get_player_name(),":"..s)
	end)
end)

else


wasserspiel = {mn = mn}

local versionen = {
}

local m = mn .. ":"

local regen = -1 --auto
local hoehe = 30
local p = {} -- temporary pos

local config_file = minetest.get_worldpath() .. "/wasserspiel.txt"
local saved_config = {}
info.wld = string.match(minetest.get_worldpath(),".*/(.*)")
local liqfin = minetest.setting_getbool("liquid_finite")
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

local function log_t0_to (player, t0)
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

local function alias_alte_versionen()
	for v,_ in pairs(versionen) do
		if v ~= mn then
			minetest.register_alias(v .. ":cloudlet", m .. "cloudlet")
		end
	end
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
	versionen["wasserspiel"] = true --release-compat
	if not versionen[mn] then
		versionen[mn] = true
		save()
	end
	alias_alte_versionen()
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

local function rutschen(player)
	local pos = player:getpos()
	p.x = pos.x + math.random(-1,1)
	p.y = pos.y + math.random(-1,0)
	p.z = pos.z + math.random(-1,1)
	local dort = minetest.registered_nodes[minetest.get_node(p).name]
	p.y = p.y + 1
	local above_dort = minetest.registered_nodes[minetest.get_node(p).name]
	p.y = p.y - 1
	if dort.walkable or above_dort.walkable then -- walkable: nicht dorthin, nur drauf
		minetest.sound_play("default_gravel_footstep")
	else
		player:setpos(p)
		--player:moveto(p,true) --geht nicht beim laufen
		minetest.sound_play("default_sand_footstep")
	end
end

local function alle_rutschen()
	for i,player in ipairs(minetest.get_connected_players()) do
		if true -- math.random(5) == 1
		and	minetest.get_node(player:getpos()).name == "default:water_flowing" then
			rutschen(player)
		end
	end
	minetest.after(1, alle_rutschen)
end

alle_rutschen()

local function cloudlet_info(itemstack, player, ps)
	if not debug then return end
	minetest.chat_send_player(player:get_player_name(), "")
	logs.t0 = nil
	wasserspiel_info(player:get_player_name())
	local l
	if ps.above then
		p.x = ps.above.x; p.z = ps.above.z; p.y = ps.above.y + 6
		l = licht_text(p)
	else
		l = "nix"
	end
	log_t0_to (player, table.concat ({
		"TYPE: " .. ps.type,
		"LIGHT: ", l,
		"UNDER: " ..
		licht_text(ps.under), 
		ps.under and minetest.get_node(ps.under).name or "nix",
		ps.under and ps.under.y or "nix",
		"GROUPS: " .. (ps.under and
			dump(minetest.registered_nodes[minetest.get_node(ps.under).name].groups)
			or "nix"),
		"ABOVE: " ..
		licht_text(ps.above),
		ps.above and minetest.get_node(ps.above).name or "nix",
		ps.above and ps.above.y or "nix",
		"NODE: " ..
		(ps.above and dump(minetest.get_node(ps.above)) or "nix"),
		"INV#1: " .. player:get_inventory():get_stack("main", 1):to_string(),
		"@" .. minetest.get_node(player:getpos()).name,
		"UNDER_ALL: " .. (ps.under and dump(minetest.registered_nodes[minetest.get_node(ps.under).name]) or "nix"),
		"WALKABLE: " .. (ps.under and dump(minetest.registered_nodes[minetest.get_node(ps.under).name].walkable) or "nix"),
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
	if active_object_count >= 20 then --49 objects max
		return 
	end --engine-limit
	local oy = pos.y
	-- -1 nun lichtregen flag, 1 ist immer an
	if regen == 0 or regen > 1 and math.random(regen) > 1 then return end
	--if regen == 1 then regen = 4 end -- #objects bei 1 >50 per block
	if string.match(node.name, ":desert_") then return end
	local r = 1
	pos.y = pos.y + 6
	if hoehe > 1 then
		pos.y = pos.y + hoehe - 1
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
		--minetest.set_node(pos, {name="default:water_source"})
		local obj = minetest.add_entity(pos, m .. "tropfen")
	else
		minetest.set_node(pos, {name=m .. "cloudlet"})
	end
	pos.y = oy
end

minetest.register_abm({
	nodenames = {"group:crumbly", "group:cracky", "group:snappy", "group:oddly_breakable_by_hand"},
	neighbors = {"air"},
	interval = 1,
	chance = 100,
	action = neues_cloudlet,
})

local function tropfen(pos, node)
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
			local r, h = string.match(param,"(\-?%d*),?(%d*)")
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
	"craft_guide:lcd_pc",
}

local function hello(player)
	local n = player:get_player_name()
	minetest.after(1,function()
		minetest.chat_send_all("Wasserspiel begruest " .. n)
	end)
	if dbg then
		gib_fehlendes(player, standard_inventory)
	end
	if dbgr(n) then
		gib_fehlendes(player, standard_inventory)
		gib_fehlendes(player, {
			mn .. ":cloudlet 10", "default:water_source 10", "default:apple 10"
		})
	end
end

minetest.register_on_joinplayer(hello)

minetest.register_on_newplayer(function(player)
	local n = player:get_player_name()
	minetest.after(1,function()
		minetest.chat_send_all("Wasserspiel begruest " .. n .. " den neuen")
	end)
	gib_fehlendes(player, standard_inventory)
end)

if false then -- so nicht
	minetest.register_on_respawnplayer(function(player)
		local n = player:get_player_name()
		minetest.after(1,function()
			minetest.chat_send_all("Wasserspiel begruest " .. n .. " den Wiederbelebten")
		end)
		gib_fehlendes(player, standard_inventory)	
	end)
end

local function step()
	info.tm = minetest.get_timeofday()
	
	if dbg then
		
		local player = minetest.get_player_by_name("debugger")
		if player then
			local drumrum = minetest.get_objects_inside_radius(player:getpos(), 50)
			if logs.gezaehlt["tropfen ueberlauf"] then
				log_t0_to (player, logs.gezaehlt["tropfen ueberlauf"] .. " tropfen ueberlauf")
			end
		end
		
		print(dump(logs.stats))
		print(dump(logs.gezaehlt))

		--local s = dump(logs.gezaehlt)
		--local s = dump(logs.full_log)
		--local s = dump(logs.step_log)
		--local s = dump(logs)
		--local s = dump(logs)
		--local s = "t0: " .. dump(logs.t0)
		
		
		--minetest.chat_send_player("debugger", s)
		
	end
	clear_logs()
	minetest.after(3, step)
end

step()

end
