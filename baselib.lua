local mod = loading_mod

-- logging

mod.dbg = nil ~= string.match(mod.branch,"_dev$")
if mod.dbg then io.stdout:setvbuf("no") end
mod.dbgr = function (name,s)
	if mod.dbg and name == "debugger" then
		if s then minetest.chat_send_player(name,"dbgr>" .. s) end
		return true
	end
	return false
end


local logs = {full_log = {}, step = 0}

local function clear_logs()
end

clear_logs()

mod.flog = function(o)
    local s = dump(o)
    print ('FL: ' .. s)
    table.insert(logs.full_log, 'FLO: ' .. s)
end


mod.logging = function()
    if mod.dbg then
	logs.step = logs.step + 1
	print ("---logs #" .. logs.step .. " " .. mod.branch)
	print (table.concat(logs.full_log, '\n'))
	    
    end
    clear_logs()
    minetest.after(3, mod.logging)
end

-- config

local config_file = minetest.get_worldpath() .. "/" .. mod.name .. ".txt"
mod.config = {}

mod.save = function ()
    mod.pre_save()
    s = minetest.serialize (mod.config)
    local f,e = io.open(config_file,"w")
    if not f then return print(e) end
    f:write(s)
    f:close()		
end

mod.load = function()
    local f = io.open(config_file, "r")
    if f then
	mod.config = minetest.deserialize (f:read("*all")) or {}
	f:close()
	mod.post_load()
    end
    mod.config.branches = mod.config.branches or {}
    mod.config.branches[mod.name]= true
    if not mod.config.branches[mod.branch] then
	mod.config.branches[mod.branch] = true
	mod.save()
    end
end

--compatibility

mod.ref = function(s)
	return mod.branch .. ':' .. s
end

mod.def = function(s)
	local id = mod.ref(s)
	for name,_ in pairs(mod.config.branches) do
		if name ~= mod.branches then
			--mod.flog {name, id}
			minetest.register_alias(name .. ":" .. s, id)
		end
	end	
	return id
end

-- sonstiges

mod.gib_fehlendes = function(player, liste)
    local iv = player:get_inventory()
    for i,st in ipairs(liste) do
	local n = string.match(st, '[^%s]*')
	if (minetest.registered_nodes[n]  or minetest.registered_tools[n])
	and not iv:contains_item("main", st) then
		iv:add_item("main", st)
	end
    end
end






