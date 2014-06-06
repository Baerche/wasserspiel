local debug = true
if debug then io.stdout:setvbuf("no") end

local versionen = {
	"wasserspiel",
	"wasserspiel_dev",
	"wasserspiel_003_locals",
	"wasserspiel_004_aufraeumen",
	"wasserspiel_005_pings",
}

local logs = {
	air = 0, air1 = 0, air2 = 0, air3 = 0, flow = 0, source = 0,
	m = m, t0 = {}, t = {},
}

local mn = minetest.get_current_modname()
local m = mn .. ":"

local regen = 1
local p = {} -- temporary pos

config_file = minetest.get_worldpath() .. "/wasserspiel.txt"
logs.t0 = config_file

local function save()
	s = minetest.serialize {regen = regen}
	local f,e = io.open(config_file,"w")
	if not f then return print(e) end
	f:write(s)
	f:close()		
end

local function load()
    local f = io.open(config_file, "r")
    if f then
		local t = minetest.deserialize (f:read("*all"))
		f:close()
		regen = t.regen
	end
end

load()

minetest.register_node(m .. "testding", {
	tiles = {"default_cloud.png"},
 	light_source = 15,
	groups = {oddly_breakable_by_hand=3},
	on_construct = function(pos)
		pos.y = pos.y - 1
		minetest.set_node(pos, {name="water_source"})
		minetest.sound_play("default_glass_footstep", {pos = pos})
	end,
	on_destruct = function(pos)
		pos.y = pos.y - 1
		minetest.set_node(pos, {name="air"})
		minetest.sound_play("default_break_glass", {pos = pos})
	end,
})

minetest.register_abm({
	nodenames = {m .. "testding"},
	interval = 3,
	chance = 3,
	action = function (pos, node)
		logs.air3 = logs.air3 + 1
		minetest.set_node(pos, {name="air"})
	end,
})

minetest.register_abm({
	nodenames = {"air"},
	interval = 3,
	chance = 20000,
	action = function(pos, node)
		if regen < 1 or math.random(regen) > 1 then return end
		local r = 1
		logs.air = logs.air + 1
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
		minetest.set_node(pos, {name=m .. "testding"})
	end,
})

minetest.register_abm({
	nodenames = {"default:water_flowing"},
	interval = 3,
	chance = 3000,
	action = function(pos, node)
		logs.flow = logs.flow + 1
		minetest.set_node(pos, {name="air"})
	end,
})

minetest.register_abm({
	nodenames = {"default:water_source"},
	interval = 3,
	chance = 3000,
	action = function(pos, node)
		logs.source = logs.source + 1
		minetest.set_node(pos, {name="air"})
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
			minetest.register_alias(v .. ":testding", m .. "testding")
		end
	end
end

minetest.register_chatcommand("rain", {
		func = function(name, param)
			logs.t0 = {}
			if param == "" then
				logs.t0 = "Regen: " .. regen
			else
				logs.t0 = "Regen von " .. regen .. " auf " .. param
				regen = tonumber(param)
				save()
			end
			minetest.chat_send_player(name, dump(logs.t0))
		end
})

local function step()
	logs.tm = minetest.get_timeofday()
	
	if debug then
		

		
	
		local s = minetest.serialize(logs)
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

if false then
	for k,v in pairs(minetest) do
		table.insert(logs.t, k)
	end
end

minetest.after(1, step)


