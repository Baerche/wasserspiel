local mn = minetest.get_current_modname()
local debug = nil ~= string.match(mn,"_dev$")

if debug then io.stdout:setvbuf("no") end

local versionen = {
	"wasserspiel",
	"wasserspiel_dev",
	"wasserspiel_009",
}

local logs = {
	air = 0, air1 = 0, air2 = 0, air3 = 0, flow = 0, source = 0,
	t0 = {}, t = {}, debug = debug, mn = mn
}

local m = mn .. ":"

local regen = 1
local hoehe = 1
local p = {} -- temporary pos

local config_file = minetest.get_worldpath() .. "/wasserspiel.txt"
logs.wld = string.match(minetest.get_worldpath(),".*/(.*)")
local liqfin = minetest.setting_getbool("liquid_finite")
logs.liqfin = liqfin

local function save()
	s = minetest.serialize {regen = regen, hoehe = hoehe}
	local f,e = io.open(config_file,"w")
	if not f then return print(e) end
	f:write(s)
	f:close()		
end

local function load()
    local f = io.open(config_file, "r")
    if f then
		local t = minetest.deserialize (f:read("*all")) or {}
		f:close()
		regen = t.regen or regen
		hoehe = t.hoehe or hoehe
	end
end

load()

minetest.register_node(m .. "cloudlet", {
	tiles = {"default_cloud.png"},
 	-- light_source = 15,
	drawtype = "glasslike",
	tiles = {"default_glass.png"},
	
	groups = {oddly_breakable_by_hand=3},
	on_construct = function(pos)
		pos.y = pos.y + 1
		minetest.set_node(pos, {name="water_source"})
		minetest.sound_play("default_glass_footstep", {pos = pos})
	end,
	on_destruct = function(pos)
		pos.y = pos.y + 1
		minetest.set_node(pos, {name="air"})
		minetest.sound_play("default_break_glass", {pos = pos})
	end,
})

minetest.register_abm({
	nodenames = {m .. "cloudlet"},
	interval = liqfin and 2 or 3,
	chance = liqfin and 1 or 3,
	action = function (pos, node)
		logs.air3 = logs.air3 + 1
		minetest.set_node(pos, {name="air"})
		-- doppelt hält besser?
		-- seiteneffect pos.y-- von set-node ausnutzend
		minetest.set_node(pos, {name="air"})
	end,
})

minetest.register_abm({
	nodenames = {"air"},
	neighbors = {"group:crumbly", "group:cracky"},
	interval = 1,
	chance = 100,
	action = function(pos, node)
		if regen < 1 or math.random(regen) > 1 then return end
		local r = 1
		logs.air = logs.air + 1
		pos.y = pos.y + 5
		if hoehe > 1 then
			pos.y = pos.y + math.random(hoehe - 1)
		end
		-- 20 ok
		for x = -r,r do
			p.x = pos.x + x
			for y = -r-1,r do
				p.y = pos.y + y
				for z = -r,r do
					p.z = pos.z + z
					local n = minetest.get_node(p).name
					if n ~= "air" then
						return
					end
					-- print(n.name)
					logs.air1 = logs.air1 + 1
				end
			end
		end
		-- if nicht returned then nur air
		logs.air2 = logs.air2 + 1
		minetest.set_node(pos, {name=m .. "cloudlet"})
	end,
})

local function assign_pos(p,q)
	p.x = q.x
	p.y = q.y
	p.z = q.z
end

function alias_alte_versionen()
	for i,v in ipairs(versionen) do
		if v ~= mn then
			minetest.register_alias(v .. ":cloudlet", m .. "cloudlet")
		end
	end
end

minetest.register_chatcommand("rain", {
		func = function(name, param)
			logs.t0 = {}
			if param == "" then
				logs.t0 = "Regen: " .. regen .. ", Hoehe " .. hoehe
			else
				local r, h = string.match(param,"(%d*),?(%d*)")
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
})

minetest.register_chatcommand("ws?", {
		func = function(name, param)
			minetest.chat_send_player(name, dump(logs))
		end
})

local function step()
	logs.tm = minetest.get_timeofday()
	
	if debug then
		

		
	
		local s = dump(logs)
		print (s)
		
		--minetest.chat_send_player("debugger", s)
		
	end
	
	logs.air = 0
	logs.air1 = 0
	logs.air2 = 0
	logs.air3 = 0
	logs.flow = 0
	logs.source = 0
	minetest.after(3, step)
end

alias_alte_versionen()

minetest.after(1, step)



