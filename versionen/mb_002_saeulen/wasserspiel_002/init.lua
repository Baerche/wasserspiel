io.stdout:setvbuf("no") 

v = "002"
m = "wasserspiel_" .. v .. ":"
minetest.register_alias("wasserspiel:testding", m .. "testding")

minetest.register_node(m .. "testding", {
	tiles = {"default_cloud.png"},
 	light_source = 15,
	groups = {oddly_breakable_by_hand=3},
	on_construct = function(pos)
		pos.y = pos.y - 1
		minetest.set_node(pos, {name="water_source"})
		minetest.sound_play("default_break_glass", {
			pos = pos,
		})
	end,
	on_destruct = function(pos)
		pos.y = pos.y - 1
		minetest.set_node(pos, {name="air"})
	end,
})

if false then
	minetest.register_craft({
		output = 'wasserspiel_dev:testding',
		recipe = {
			{'default:dirt', '', ''},
			{'', '', ''},
			{'', '', ''},
		},
	})
end

minetest.register_abm({
	nodenames = {m .. "testding"},
	interval = 10,
	chance = 5,
	action = function(pos, node)
		-- print (node.name, minetest.pos_to_string(pos))
		minetest.set_node(pos, {name="air"})
	end,
})

p = {}

minetest.register_abm({
	nodenames = {"air"},
	--nodenames = {m .. "testding"},
	interval = 30,
	--chance = 1,
	chance = 500000,
	action = function(pos, node)
		-- print (node.name, minetest.pos_to_string(pos))
		r = 1
		logs.air = logs.air + 1
		for x = -r,r do
			p.x = pos.x + x
			for y = -r-1,r do
				p.y = pos.y + y
				for z = -r,r do
					p.z = pos.z + z
					n = minetest.get_node(p).name
					if n ~= "air" then
						return
					end
					-- print(n.name)
					logs.air1 = logs.air1 + 1
				end
			end
		end
		-- nicht returned, nur air
		logs.air2 = logs.air2 + 1
		minetest.set_node(pos, {name=m .. "testding"})
	end,
})

function assign_pos(p,q)
	p.x = q.x
	p.y = q.y
	p.z = q.z
end

logs = {
	n = 0,
	air = 0,
	air1 = 0,
	air2 = 0,
	v = v
}

function step()
	-- print ("boop", minetest.get_timeofday())
	logs.n = logs.n + 1
	
	print (minetest.serialize(logs))
	
	logs.air = 0
	logs.air1 = 0
	logs.air2 = 0
	minetest.after(3, step)
end

step()

