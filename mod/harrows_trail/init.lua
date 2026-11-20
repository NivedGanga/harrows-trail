local storage = core.get_mod_storage()
local world_sites = dofile(core.get_modpath("harrows_trail") .. "/world_sites.lua")(storage)
local world_buildings = dofile(core.get_modpath("harrows_trail") .. "/world_buildings.lua")
local grant = dofile(core.get_modpath("harrows_trail") .. "/inventory.lua")
local states = {}
core.register_chatcommand("trail_sites", {
 description = "Inspect Harrow's Trail world site status", privs = {server=true},
 func = function()
  local out = {}
  for id, site in pairs(world_sites.registry) do
   out[#out+1] = id .. " x=" .. site.center.x .. " z=" .. site.center.z ..
    " " .. (world_sites.placed(id) and "placed" or "not placed")
  end
  table.sort(out)
  return true, table.concat(out, "; ")
 end,
})
local saddle = "mcl_mobitems:saddle"
local starter = dofile(core.get_modpath("harrows_trail") .. "/saddle.lua")(storage)
local function default_state()
	return {version = 1, act = 1, unlocked = {['1'] = true}, honor = 50,
		wanted = 0, nora_trust = 50, map_fragments = {}, flags = {start_pending = true}}
end
local function save(name)
	if states[name] then storage:set_string("player:" .. name, core.write_json(states[name])) end
end
local function load(name)
	local raw = storage:get_string("player:" .. name)
	if raw == "" then return default_state() end
	local state = core.parse_json(raw)
	if type(state) ~= "table" or state.version ~= 1 then
		error("Harrow's Trail: unsupported or damaged state for " .. name .. "; refusing to overwrite it")
	end
	-- Luanti serializes empty tables as JSON null; restore empty collections on load.
	for _, field in ipairs({"flags", "map_fragments", "unlocked"}) do
		if state[field] == nil then state[field] = {} end
		if type(state[field]) ~= "table" then
			error("Harrow's Trail: damaged " .. field .. " for " .. name .. "; refusing to overwrite it")
		end
	end
	return state
end
-- The pinned native horse calls on_die before its normal equipment drops.
-- Keep undeliverable saddles in player state until there is inventory space.
local function deliver_saddles(player, s)
	local pending = s.flags.saddles_to_return or {}
	local inv = player:get_inventory()
	while #pending > 0 do
		local stack = ItemStack(pending[1])
		if not starter.valid(stack) then stack:set_name("harrows_trail:retired_saddle") end
		if not grant(inv, stack) then break end
		table.remove(pending, 1)
	end
	s.flags.saddles_to_return = #pending > 0 and pending or nil
end
local function recover_horse_saddle(horse)
	if not horse.tamed or not horse.owner or horse.owner == "" or
		(ItemStack(horse._saddle or ""):get_name() ~= saddle and ItemStack(horse._saddle or ""):get_name() ~= starter.item) then return end
	if not starter.valid(horse._saddle) then horse._saddle = ""; return end
	local name = horse.owner
	local s = states[name] or load(name)
	local pending = s.flags.saddles_to_return or {}
	pending[#pending + 1] = horse._saddle
	s.flags.saddles_to_return = pending
	-- Save before suppressing the native drop, including when the owner is offline.
	storage:set_string("player:" .. name, core.write_json(s))
	horse._saddle = ""
	local player = core.get_player_by_name(name)
	if player then
		deliver_saddles(player, s)
		storage:set_string("player:" .. name, core.write_json(s))
		core.chat_send_player(name, s.flags.saddles_to_return and
			"Your horse's saddle is safe; make inventory room and rejoin to recover it." or
			"Your horse's saddle has returned to your inventory.")
	end
end
local horse_def = assert(core.registered_entities["mobs_mc:horse"])
local native_horse_death = horse_def.on_die
horse_def.on_die = function(horse, ...)
	recover_horse_saddle(horse)
	if native_horse_death then return native_horse_death(horse, ...) end
end
local chapter
local grounded_mode
local function journal(s)
	if chapter and s.flags.choice then return chapter.journal(s) end
	if s.flags.choice then
		return "Ada has heard your decision. Nora's trail leads beyond Red Mesa. This is the end of the current trail."
	elseif s.flags.reached_mesa then
		return "Meet Sheriff Ada at the Red Mesa office and decide what to do with the witness's evidence."
	elseif not s.map_fragments['1'] then
		return grounded_mode and "Search the burned barn near the tack room for Nora's trail." or "Search the burned ranch: the barn marker is west of where you woke. Right-click it to examine Nora's trail."
	elseif not s.flags.saddle_found then
		return "Find Samuel's saddle at the tack room marker. The tracks lead east to Red Mesa."
	elseif not s.unlocked['2'] then
		return grounded_mode and "Tame a horse at the corral with an empty hand, fit Samuel's saddle, and ride toward Red Mesa." or "Tame a horse by mounting it with an empty hand until it accepts you. Fit Samuel's saddle, mount, and follow the eastward trail marker."
	else
		return "Ride to Red Mesa and speak with Sheriff Ada at the office."
	end
end
local function show(name, title, message, buttons)
	local formspec = "formspec_version[4]size[10,6]label[0.5,0.5;" .. core.formspec_escape(title) .. "]textarea[0.5,1;9,3.6;;;" .. core.formspec_escape(message) .. "]" .. (buttons or "button_exit[3.5,5;3,0.7;close;Close]")
	core.show_formspec(name, "harrows_trail:story", formspec)
end
local function message(player, title, msg, buttons)
	show(player:get_player_name(), title, msg, buttons)
end
core.register_chatcommand("trail", {description = "Read Eli's trail journal", func = function(name)
	if not states[name] then return false, "Your journal is unavailable." end
	show(name, "Eli's journal", journal(states[name]))
	return true
end})
local function is_riding(player)
	local parent = player:get_attach()
	local horse = parent and parent:get_luaentity()
	return horse and horse.name == "mobs_mc:horse" and horse.tamed == true
		and horse.owner == player:get_player_name() and horse.driver == player
		and starter.valid(horse._saddle) and horse._saddle and (ItemStack(horse._saddle):get_name() == saddle or ItemStack(horse._saddle):get_name() == starter.item)
end
local function interact(kind, pos, player)
	local name = player:get_player_name()
	local s = states[name]
	if not s then return end
	if chapter and chapter.interact(kind, pos, player, s) then return end
	if kind == "stagecoach" then
		message(player, "Stagecoach desk", "After Jesse explains the route, use /stagecoach near this desk to travel to the temporary Dust Road and use it there to return. Your mounted native horse can travel with you.")
		return
	end
	if kind == "barn" then
		if not s.map_fragments['1'] then
			local inv = player:get_inventory()
			if not grant(inv, ItemStack("harrows_trail:fragment_1")) then
				message(player, "The burned barn", "Make room in your inventory to recover Samuel's map fragment.")
				return
			end
		end
		s.map_fragments['1'] = true
		s.flags.ranch_clue = true
		save(name)
		message(player, "The burned barn", "In the ashes is a torn piece of Samuel's map. Nearby, Nora's ribbon lies beside boot prints and a note: Crane took her toward Red Mesa. Find the tack room and Samuel's saddle. Use /trail for your journal.")
	elseif kind == "tack" then
		local inv = player:get_inventory()
		starter.clean(inv)
		if inv:contains_item("main", saddle) or inv:contains_item("main", starter.item) then
			message(player, "Samuel's tack room", "You already have a saddle in your pack.")
			return
		end
		for _, nearby in ipairs(core.get_objects_inside_radius(pos, 32)) do
			local horse = nearby:get_luaentity()
			if horse and horse.name == "mobs_mc:horse" and horse.owner == name and starter.valid(horse._saddle) and
				(ItemStack(horse._saddle or ""):get_name() == saddle or ItemStack(horse._saddle or ""):get_name() == starter.item) then
				message(player, "Samuel's tack room", "Your nearby horse already has a saddle.")
				return
			end
		end
		if s.flags.saddles_to_return and #s.flags.saddles_to_return > 0 then
			deliver_saddles(player, s)
			save(name)
			message(player, "Samuel's tack room", s.flags.saddles_to_return and
				"Make room in your inventory to recover your horse's saddle." or "Your horse's saddle is back in your pack.")
			return
		end
		if s.flags.arrived then
			message(player, "Samuel's tack room", "Dutch at Dry Gulch sells replacements now that you can reach him.")
			return
		end
		local candidate = starter.issue(name)
		if grant(inv, candidate) then
			starter.commit(name, candidate)
			s.flags.saddle_found = true
			save(name)
			message(player, "Samuel's tack room", "You recover Samuel's saddle. Recovery here is free before Dry Gulch. Recovering a lost saddle retires its previous issue, including on distant horses; old issues can no longer be fitted. Tame a horse with an empty hand, then right-click it with the saddle.")
		else
			message(player, "Samuel's tack room", "Make room in your inventory to recover the saddle.")
		end
	elseif kind == "corral" then
		local p = {x = pos.x, y = pos.y + 1, z = pos.z + 2}
		for _, nearby in ipairs(core.get_objects_inside_radius(p, 12)) do
			local mob = nearby:get_luaentity()
			if mob and mob.name == "mobs_mc:horse" then
				s.flags.corral_visited=true; save(name)
				message(player, "Ranch corral", "A horse is already nearby. Mount with an empty hand until it accepts you, then fit the saddle.")
				return
			end
		end
		local obj = core.add_entity(p, "mobs_mc:horse")
		if obj then
			local horse = obj:get_luaentity()
			horse.persistent = true
			s.flags.corral_visited=true; save(name)
			message(player, "Ranch corral", "A horse approaches. With an empty hand, right-click to mount; keep trying until it accepts you. Dismount and right-click with the saddle, then mount again.")
		else
			message(player, "Ranch corral", "No horse could reach the corral. Try again when the area is clear.")
		end
	elseif kind == "route" then
		if not s.map_fragments['1'] then
			message(player, "Eastward trail", "Search the burned barn first; Nora's trail may still be there.")
		elseif not s.flags.saddle_found then
			message(player, "Eastward trail", "Find Samuel's saddle in the tack room first.")
		elseif not s.unlocked['2'] and not is_riding(player) then
			message(player, "Eastward trail", "You need to be riding your tamed, saddled horse. A saddle in your pack is not enough; it will not be consumed.")
		else
			chapter.unlock(player, s, 2)
			save(name)
			message(player, "Eastward trail", "The tracks continue to Red Mesa. Samuel's saddle stays with your horse. Find Ada at the office marker.")
		end
	elseif kind == "ada" then
		if not s.unlocked['2'] then
			message(player, "Sheriff Ada Wells", grounded_mode and "Follow Nora's trail from the ranch and ride a tamed, saddled horse to Red Mesa first." or "Follow Nora's trail from the ranch and ride a tamed, saddled horse past the eastward trail marker first.")
			return
		end
		s.flags.reached_mesa = true
		if s.flags.choice then
			local reaction = s.flags.choice == "evidence" and "You trusted me with the witness's evidence. I'll protect it and follow Crane's trail." or "You kept the witness's evidence safe yourself. I wish you'd trusted me, but I'll still help find Nora."
			chapter.ada(player, s, reaction)
		else
			message(player, "Sheriff Ada Wells", "A frightened witness saw Crane ride east with Nora. They left a scrap of evidence but fear the gang. Will you entrust it to Ada, or keep it yourself?",
				"button[0.5,5;4.2,0.7;evidence;Trust Ada with it]button[5.1,5;4.2,0.7;keep;Keep it safe yourself]")
		end
		save(name)
	end
end
local world_opening = dofile(core.get_modpath("harrows_trail") .. "/world_opening.lua")(interact)
core.register_craftitem("harrows_trail:fragment_1", {
	description = "Samuel's map fragment 1",
	inventory_image = "default_paper.png",
	on_use = function(_, player)
		message(player, "Samuel's map fragment", "A torn piece of Samuel's map. Nora's ribbon and Crane's tracks led east toward Red Mesa.")
	end,
})
local node_info = {
	barn = {"Burned barn: search", "default_wood.png^[colorize:#311b12:130"},
	tack = {"Tack room: recover saddle", "default_wood.png"},
	corral = {"Ranch corral: find a horse", "default_wood.png"},
	route = {"Eastward trail: Red Mesa", "default_cobble.png"},
	ada = {"Sheriff Ada Wells", "mcl_core_sandstone_normal.png"},
}
for kind, info in pairs(node_info) do
	core.register_node("harrows_trail:" .. kind, {
		description = info[1], tiles = {info[2]}, groups = {unbreakable = 1, not_in_creative_inventory = 1},
		diggable = false, on_rightclick = function(pos, _, player)
			interact(kind, pos, player)
			return player:get_wielded_item()
		end,
	})
end
local function receive_fields(player, formname, fields)
	if formname ~= "harrows_trail:story" or not (fields.evidence or fields.keep) then return end
	local name = player:get_player_name()
	local s = states[name]
	if not s or not s.flags.reached_mesa or s.flags.choice then return end
	local site = core.parse_json(storage:get_string("site"))
	if not site or vector.distance(player:get_pos(), site.ada) > 8 then return end
	s.flags.choice = fields.evidence and "evidence" or "keep"
	if fields.evidence then s.honor = math.min(100, s.honor + 3) end
	save(name)
	local response = fields.evidence and "Ada accepts the scrap and promises to protect the witness. Your trust in her strengthens your standing." or "Ada nods, though disappointed. She asks you to keep the witness safe and promises to pursue Crane."
	message(player, "Sheriff Ada Wells", response .. " Speak to Ada again about Jesse Moss and bail.")
end
core.register_on_player_receive_fields(receive_fields)

-- The temporary slice is elevated so it does not flatten generated terrain.
grounded_mode = storage:get_string('grounded_v1') == '1' or
 (core.settings:get_bool('harrows_trail_grounded',false) and storage:get_string('site_ready') ~= '1')
local site = {
	spawn = {x = 0, y = 222, z = 3},
	barn = {x = -8, y = 221, z = 0}, tack = {x = 0, y = 221, z = -6},
	corral = {x = 8, y = 221, z = 0}, route = {x = 22, y = 221, z = 0},
	ada = {x = 55, y = 221, z = 0},
}
local function make_layout()
	local nodes = {}
	local function add(x, y, z, name)
		nodes[#nodes + 1] = {pos = {x = x, y = y, z = z}, name = name}
	end
	for x = -12, 64 do
		local width = x <= 12 and 9 or (x >= 46 and 8 or 2)
		for z = -width, width do add(x, 220, z, "harrows_trail:floor") end
	end
	-- Guard rails keep the narrow temporary route traversable on horseback.
	for x = -13, 65 do
		local width = x <= 12 and 10 or (x >= 46 and 9 or 3)
		add(x, 221, -width, "harrows_trail:rail")
		add(x, 221, width, "harrows_trail:rail")
	end
	for z = -9, 9 do add(-13, 221, z, "harrows_trail:rail") end
	for z = -8, 8 do add(65, 221, z, "harrows_trail:rail") end
	for kind, pos in pairs(site) do
		if kind ~= "spawn" then add(pos.x, pos.y, pos.z, "harrows_trail:" .. kind) end
	end
	-- Partial walls suggest a burned barn and a small sheriff's office.
	for z = -3, 3 do
		if z ~= 0 then add(-11, 221, z, "harrows_trail:ash") end
		add(-11, 222, z, "harrows_trail:ash")
		if z ~= 0 then add(60, 221, z, "harrows_trail:adobe") end
		add(60, 222, z, "harrows_trail:adobe")
	end
	return nodes
end
core.register_node("harrows_trail:floor", {
	description = "Trail platform", tiles = {"default_wood.png"},
	groups = {solid = 1, unbreakable = 1, not_in_creative_inventory = 1}, diggable = false,
})
core.register_node("harrows_trail:rail", {
	description = "Trail guard rail", tiles = {"default_wood.png"},
	drawtype = "nodebox", paramtype = "light",
	node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}},
	groups = {unbreakable = 1, not_in_creative_inventory = 1}, diggable = false,
})
core.register_node("harrows_trail:ash", {
	description = "Burned ranch timbers", tiles = {"default_wood.png^[colorize:#24140d:190"},
	groups = {unbreakable = 1, not_in_creative_inventory = 1}, diggable = false,
})
core.register_node("harrows_trail:adobe", {
	description = "Sheriff's office", tiles = {"mcl_core_sandstone_normal.png"},
	groups = {unbreakable = 1, not_in_creative_inventory = 1}, diggable = false,
})

local ground_busy, ground_retry, ground_error = {}, {}, {}
local function apply_grounded_positions()
 local positions=world_buildings.positions
 for _,key in ipairs({'spawn','barn','tack','corral','route','ada'}) do site[key]=positions[key] end
 if chapter then
  for _,key in ipairs({'ada','jesse','ruth','cache','delivery','depot'}) do chapter.positions[key]=positions[key] end
  chapter.positions.recovery=positions.tack
 end
end
local function ensure_grounded_site(id)
 if not grounded_mode or ground_busy[id] then return end
 local def=world_sites.registry[id]; local y=def and def.base_y
 if not def or world_sites.placed(id) and (id~='ranch' or storage:get_string('site_ready')=='1') then return end
 if not world_sites.placed(id) and core.get_mapgen_setting('seed')~='1730940739604968791' then
  if ground_error[id]~='seed' then
   ground_error[id]='seed'; core.log('error','[harrows_trail] Grounded sites require the documented development seed; no blocks changed')
   for _,p in ipairs(core.get_connected_players()) do core.chat_send_player(p:get_player_name(),'This world seed is unsuitable for the grounded sites; no blocks were changed.') end
  end
  return
 end
 if (ground_retry[id] or 0)>core.get_gametime() then return end
 ground_busy[id]=true
 local p=def.center
 core.emerge_area({x=p.x-def.half_x-48,y=y-48,z=p.z-def.half_z-48},
  {x=p.x+def.half_x+48,y=y+def.height+48,z=p.z+def.half_z+48},function(_,action,left)
   if action==core.EMERGE_ERRORED or action==core.EMERGE_CANCELLED then
    ground_busy[id]=nil; ground_retry[id]=core.get_gametime()+15; return
   end
   if left~=0 then return end
   local layout,zones=world_buildings.layout(id)
   local ok,reason=world_sites.place(id,y,layout,zones)
   ground_busy[id]=nil
   if not ok then
    ground_retry[id]=core.get_gametime()+15
    core.log('warning','[harrows_trail] Grounded site '..id..' not placed: '..tostring(reason))
    if ground_error[id]~=reason then
     ground_error[id]=reason
     for _,player in ipairs(core.get_connected_players()) do
      core.chat_send_player(player:get_player_name(),'The '..id..' site cannot be placed safely. No blocks were changed; see the server log.')
     end
    end
    return
   end
   apply_grounded_positions()
   if id=='ranch' then
    storage:set_string('grounded_v1','1'); storage:set_string('site',core.write_json(site)); storage:set_string('site_ready','1')
    for _,player in ipairs(core.get_connected_players()) do
     local name=player:get_player_name(); local s=states[name]
     if s and s.flags.start_pending then
      player:set_pos(site.spawn); s.flags.start_pending=nil; save(name)
      core.chat_send_player(name,"Search the burned barn for Nora's trail. Use /trail for your journal.")
     end
    end
   end
   core.log('action','[harrows_trail] Grounded site placed: '..id)
  end)
end
if grounded_mode then apply_grounded_positions() end
local function update_grounded(player)
 if not grounded_mode or storage:get_string('site_ready')~='1' then return end
 local pos=player:get_pos(); local target=world_sites.registry.red_mesa.center
 local distance2=(pos.x-target.x)^2+(pos.z-target.z)^2
 if world_sites.placed('red_mesa') then
  if distance2<=96^2 then world_opening.ensure_actors(world_buildings.sites.red_mesa) end
 elseif distance2<=world_sites.registry.red_mesa.radius^2 then ensure_grounded_site('red_mesa') end
end
local building = false
local function ensure_site()
	if storage:get_string("site_ready") == "1" or building then return end
	building = true
	local layout = make_layout()
	core.emerge_area({x = -13, y = 219, z = -10}, {x = 65, y = 224, z = 10}, function(_, action, remaining)
		if action == core.EMERGE_ERRORED or action == core.EMERGE_CANCELLED then
			building = false
			core.log("error", "[harrows_trail] Could not emerge the slice site")
			return
		end
		if remaining ~= 0 then return end
		for _, entry in ipairs(layout) do
			local node = core.get_node(entry.pos).name
			if node ~= "air" and node ~= entry.name then
				building = false
				core.log("error", "[harrows_trail] Site occupied at " .. core.pos_to_string(entry.pos) .. "; no nodes replaced")
				for _, player in ipairs(core.get_connected_players()) do
					core.chat_send_player(player:get_player_name(), "Harrow's Trail site is occupied; see the server log.")
				end
				return
			end
		end
		for _, entry in ipairs(layout) do
			core.set_node(entry.pos, {name = entry.name})
			local kind = entry.name:match("^harrows_trail:(.+)$")
			if node_info[kind] then
				core.get_meta(entry.pos):set_string("infotext", node_info[kind][1] .. " (right-click)")
			end
		end
		storage:set_string("site", core.write_json(site))
		storage:set_string("site_ready", "1")
		building = false
		for _, player in ipairs(core.get_connected_players()) do
			local name = player:get_player_name()
			local s = states[name]
			if s and s.flags.start_pending then
				player:set_pos(site.spawn)
				s.flags.start_pending = nil
				save(name)
				core.chat_send_player(name, "Search the burned barn to the west. Right-click the marker; use /trail to read your journal.")
			end
		end
		core.log("action", "[harrows_trail] Slice site placed at y=220")
	end)
end

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	states[name] = load(name)
	deliver_saddles(player, states[name])
	save(name)
	if storage:get_string("site_ready") == "1" and states[name].flags.start_pending then
		core.after(0.5, function()
			local current = core.get_player_by_name(name)
			if current and states[name] and states[name].flags.start_pending then
				current:set_pos(site.spawn)
				states[name].flags.start_pending = nil
				save(name)
				core.chat_send_player(name, "Search the burned barn to the west. Right-click the marker; use /trail for your journal.")
			end
		end)
	else
		if grounded_mode then ensure_grounded_site('ranch') else ensure_site() end
	end
end)
core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	save(name)
	states[name] = nil
end)
core.register_on_shutdown(function()
	for name in pairs(states) do save(name) end
end)
core.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	if storage:get_string("site_ready") == "1" and player:get_meta():get_string("mcl_beds:spawn") == "" then
		core.after(0.5, function()
			local current = core.get_player_by_name(name)
			if current then current:set_pos(site.spawn) end
		end)
	end
end)

local function advance_ranch_route(player,s)
 local route=world_buildings.route; local step=tonumber(s.flags.ranch_route_step) or 1
 step=math.max(1,math.min(#route,math.floor(step)))
 local target=route[step]; local pos=player:get_pos()
 if step<#route and is_riding(player) and (pos.x-target.x)^2+(pos.z-target.z)^2<=4 and math.abs(pos.y-target.y)<=4 then
  step=step+1; s.flags.ranch_route_step=step; save(player:get_player_name())
 end
 return route[step]
end
local function opening_target(player,s)
 if not s.map_fragments['1'] then return 'Burned barn',site.barn end
 if not s.flags.saddle_found then return 'Tack room',site.tack end
 if not s.flags.corral_visited and not s.unlocked['2'] then return 'Ranch corral',site.corral end
 if not s.unlocked['2'] then return 'Trail to Red Mesa',advance_ranch_route(player,s) end
 if not s.flags.choice then return 'Sheriff Ada',site.ada end
 if s.flags.jesse_free and not s.flags.jesse_briefed then return 'Jesse at the jail',world_buildings.positions.jesse end
 if s.flags.jesse_briefed and not s.unlocked['4'] and player:get_pos().x>400 then
  if player:get_inventory():contains_item('main','mcl_lanterns:lantern_floor 4') then return 'Stagecoach desk',world_buildings.positions.stagecoach end
  return 'Ruth: lanterns',world_buildings.positions.ruth
 end
end
local elapsed = 0
local opening_huds = {}
core.register_on_leaveplayer(function(p) opening_huds[p:get_player_name()]=nil end)
core.register_globalstep(function(dtime)
	elapsed = elapsed + dtime
	if elapsed < 1 then return end
	elapsed = 0
	if storage:get_string("site_ready") ~= "1" then
		if grounded_mode and #core.get_connected_players()>0 then ensure_grounded_site('ranch') end
		return
	end
	for _, player in ipairs(core.get_connected_players()) do
		update_grounded(player)
		local name=player:get_player_name(); local s = states[name]
		if grounded_mode and s then
			local label,target=opening_target(player,s)
			local signature=target and label..':'..target.x..':'..target.y..':'..target.z
			local previous=opening_huds[name]
			if previous and previous.signature~=signature then player:hud_remove(previous.id); opening_huds[name]=nil end
			if label and not opening_huds[name] then
				local id=player:hud_add({hud_elem_type='waypoint',name=label,text='m',number=0xffd080,world_pos=target})
				if id then opening_huds[name]={id=id,signature=signature} end
			end
		end
		if s and not s.unlocked['2'] and vector.distance(player:get_pos(), site.route) < 5 and is_riding(player) then
			interact("route", site.route, player)
		end
	end
end)

if core.settings:get_bool("harrows_trail_test", false) then
	harrows_trail_test = {states = states, load = load, save = save, interact = interact,
		receive_fields = receive_fields, journal = journal, is_riding = is_riding,
		ensure_site = ensure_site, ensure_grounded_site = ensure_grounded_site, update_grounded = update_grounded, advance_ranch_route = advance_ranch_route, opening_target = opening_target, grounded_mode = grounded_mode, site = site, storage = storage, world_sites = world_sites, world_buildings = world_buildings, world_opening = world_opening,
		grant = grant, starter = starter, recover_horse_saddle = recover_horse_saddle, deliver_saddles = deliver_saddles}
end

chapter = dofile(core.get_modpath("harrows_trail") .. "/chapter.lua")({
 states=states, save=save, storage=storage, message=message, grant=grant, riding=is_riding, grounded=grounded_mode, recover=function(p) interact("tack", site.tack, p) end})
if core.settings:get_bool("harrows_trail_test", false) then harrows_trail_test.chapter = chapter end
if grounded_mode then apply_grounded_positions() end
local world_travel = dofile(core.get_modpath("harrows_trail") .. "/world_travel.lua")({
 grounded=grounded_mode,states=states,storage=storage,riding=is_riding,
 desk=world_buildings.positions.stagecoach,dust_marker=chapter.positions.dust})
if core.settings:get_bool("harrows_trail_test", false) then harrows_trail_test.world_travel=world_travel end

local finale = dofile(core.get_modpath("harrows_trail") .. "/finale.lua")({
 states=states, save=save, storage=storage, message=message, grant=grant, chapter=chapter})
chapter.context.finale_journal = finale.journal
if core.settings:get_bool("harrows_trail_test", false) then harrows_trail_test.finale = finale end
