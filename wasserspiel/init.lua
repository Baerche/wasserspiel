minetest.register_node("wasserspiel:testding", {
	tiles = {"tutorial_decowood.png"},
	groups = {oddly_breakable_by_hand=3},
})

minetest.register_craft({
	output = 'wasserspiel:testding',
	recipe = {
		{'default:dirt', '', ''},
		{'', '', ''},
		{'', '', ''},
	},
})

minetest.register_abm({
	nodenames = {"wasserspiel:testding"},
	interval = 3,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		print ("ws", minetest.pos_to_string(pos), active_object_count, active_object_count_wider)
	end,
})

function no()
end


function step()
	-- print ("boop", minetest.get_timeofday())
	minetest.after(1, step)
end

step()

