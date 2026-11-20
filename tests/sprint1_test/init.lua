local api = assert(harrows_trail_test, "test mode must be enabled")
local phase = core.settings:get("harrows_trail_test_phase")
local player_name = "trail_test_player"
local previous_show = core.show_formspec
local last_form
core.show_formspec = function(name, formname, formspec)
	if name == player_name or name == "capacity_test" or name == "grant_test" then last_form = formspec else return previous_show(name, formname, formspec) end
end

local inventory = {count = 0, fragments = 0}
function inventory:get_list() return {} end
function inventory:room_for_item() return true end
function inventory:contains_item(_, item) return item == "mcl_mobitems:saddle" and self.count > 0 end
function inventory:add_item(_, item)
	if ItemStack(item):get_name() == "mcl_mobitems:saddle" or ItemStack(item):get_name() == api.starter.item then self.count = self.count + 1
	elseif ItemStack(item):get_name() == "harrows_trail:fragment_1" then self.fragments = self.fragments + 1
	else error("unexpected item " .. item) end
	return ItemStack("")
end
local player = {pos = api.site.route, parent = nil}
function player:get_player_name() return player_name end
function player:get_inventory() return inventory end
function player:get_pos() return self.pos end
function player:get_attach() return self.parent end

local function finish()
	core.log("action", "[sprint1_test] PASS phase " .. phase)
	core.request_shutdown("Sprint 1 automated test completed", false, 0)
end
local function test_world_sites()
 local sites=api.world_sites
 assert(sites.registry.ranch.biome_prefix=='Savanna' and sites.registry.red_mesa.biome_prefix=='Mesa')
 local pos={x=0,y=221,z=4}
 local biome=assert(mcl_biome_dispatch.get_biome_name(pos))
 local site={center={x=0,z=4},half_x=0,half_z=0,height=2,biome_prefix=biome}
 local layout={{pos=pos,name='harrows_trail:ash'}}
 assert(sites.preflight(site,221,layout))
 local wrong={center=site.center,half_x=0,half_z=0,height=2,biome_prefix='not_a_biome'}
 local ok,why=sites.preflight(wrong,221,layout); assert(not ok and why:find('unsuitable biome',1,true))
 core.set_node(pos,{name='mcl_core:obsidian'})
 ok,why=sites.preflight(site,221,layout); assert(not ok and why:find('occupied',1,true)); assert(core.get_node(pos).name=='mcl_core:obsidian')
 core.set_node(pos,{name='air'}); core.get_meta(pos):set_string('owner','test')
 ok,why=sites.preflight(site,221,layout); assert(not ok and why:find('metadata',1,true)); core.get_meta(pos):set_string('owner','')
 local poi_pos={x=10,y=221,z=4}; assert(not mcl_villages.get_poi(poi_pos))
 local poi_id=mcl_villages.insert_poi(poi_pos,'mcl_villages:bed')
 ok,why=sites.preflight(site,221,layout); assert(not ok and why:find('village',1,true)); mcl_villages.remove_poi(poi_id)
 local item=assert(core.add_item(pos,'mcl_core:gold_ingot'))
 ok,why=sites.preflight(site,221,layout); assert(not ok and why:find('object',1,true)); item:remove()
 sites.registry.test_fixture=site
 assert(sites.place('test_fixture',221,layout)); assert(sites.placed('test_fixture'))
 assert(core.get_node(pos).name=='harrows_trail:ash')
 assert(sites.place('test_fixture',221,layout)); assert(core.get_node(pos).name=='harrows_trail:ash')
end
local function run_first()
	test_world_sites()
	assert(core.registered_nodes["harrows_trail:barn"])
	assert(core.registered_items["mcl_mobitems:saddle"])
	assert(core.registered_entities["mobs_mc:horse"])
	assert(core.get_node(api.site.barn).name == "harrows_trail:barn")
	assert(core.get_node(api.site.ada).name == "harrows_trail:ada")
	local s = api.load(player_name)
	api.states[player_name] = s
	assert(s.version == 1 and not s.map_fragments['1'])
	api.interact("route", api.site.route, player)
	assert(not s.unlocked['2'])
	api.interact("barn", api.site.barn, player)
	api.interact("tack", api.site.tack, player)
	assert(s.map_fragments['1'] and s.flags.saddle_found and inventory.count == 1 and inventory.fragments == 1)
	api.interact("tack", api.site.tack, player)
	assert(inventory.count == 1, "repeated tack use must not duplicate a carried saddle")
	api.interact("barn", api.site.barn, player)
	assert(inventory.fragments == 1, "fragment must not be duplicated")
	api.interact("route", api.site.route, player)
	assert(not s.unlocked['2'], "a loose saddle must not unlock the route")
	local horse = {name = "mobs_mc:horse", tamed = true, owner = player_name, driver = player, _saddle = "mcl_mobitems:saddle"}
	player.parent = {get_luaentity = function() return horse end}
	assert(api.is_riding(player))
	api.interact("route", api.site.route, player)
	assert(s.unlocked['2'] and s.act == 2 and inventory.count == 1)
	player.pos = api.site.ada
	api.interact("ada", api.site.ada, player)
	assert(s.flags.reached_mesa and last_form:find("Trust Ada", 1, true))
	api.receive_fields(player, "harrows_trail:story", {evidence = true})
	assert(s.flags.choice == "evidence" and s.honor == 53)
	assert(last_form:find("protect the witness", 1, true))
	api.receive_fields(player, "harrows_trail:story", {evidence = true})
	assert(s.honor == 53, "choice must not apply twice")
	api.interact("ada", api.site.ada, player)
	assert(last_form:find("trusted me", 1, true))
	local alternative = api.load("unused_test_player")
	alternative.flags.reached_mesa = true
	api.states[player_name] = alternative
	player.pos = {x = 0, y = 222, z = 3}
	api.receive_fields(player, "harrows_trail:story", {keep = true})
	assert(not alternative.flags.choice, "a choice must be made near Ada")
	player.pos = api.site.ada
	api.receive_fields(player, "harrows_trail:story", {keep = true})
	assert(alternative.flags.choice == "keep" and alternative.honor == 50)
	assert(last_form:find("disappointed", 1, true))
	api.states[player_name] = s
	local obj = assert(core.add_entity({x=8, y=222, z=3}, "mobs_mc:horse"))
	local native = assert(obj:get_luaentity())
	assert(native.on_die == core.registered_entities["mobs_mc:horse"].on_die, "native instance must use recovery hook")
	assert(core.get_item_group("harrows_trail:floor", "solid") > 0)
	assert(native:pacing_target(obj:get_pos(), 5, 4, mcl_mobs.SOLID_PACING_GROUPS),
		"native horses must be able to find a pacing target on the ranch floor")
	native.tamed, native.owner, native._saddle, native.persistent = true, player_name, "mcl_mobitems:saddle", true
	inventory.count = 0
	api.interact("tack", api.site.tack, player)
	assert(inventory.count == 0, "nearby saddled horse must prevent another tack-room saddle")
	inventory.count = 1
	local serialized = native:get_staticdata()
	local decoded = assert(core.deserialize(serialized))
	assert(decoded.tamed and decoded.owner == player_name and decoded._saddle == "mcl_mobitems:saddle")
	obj:remove()
	local restored = assert(core.add_entity({x=8, y=222, z=3}, "mobs_mc:horse", serialized))
	local restored_horse = assert(restored:get_luaentity())
	assert(restored_horse.tamed and restored_horse.owner == player_name and restored_horse._saddle == "mcl_mobitems:saddle")
	restored:remove()
	local old_get_player = core.get_player_by_name
	local old_send = core.chat_send_player
	inventory.count = 0
	core.get_player_by_name = function(name) if name == player_name then return player end return old_get_player(name) end
	core.chat_send_player = function(name, msg) if name ~= player_name then old_send(name, msg) end end
	local online_horse = {tamed = true, owner = player_name, _saddle = "mcl_mobitems:saddle"}
	core.registered_entities["mobs_mc:horse"].on_die(online_horse)
	core.get_player_by_name, core.chat_send_player = old_get_player, old_send
	assert(inventory.count == 1 and online_horse._saddle == "", "online owner must receive saddle without a drop")
	local dead_horse = {tamed = true, owner = "offline_saddle_test", _saddle = "mcl_mobitems:saddle"}
	core.registered_entities["mobs_mc:horse"].on_die(dead_horse)
	assert(dead_horse._saddle == "", "native death must not drop a returned saddle")
	local recovered = api.load("offline_saddle_test")
	assert(recovered.flags.saddles_to_return and #recovered.flags.saddles_to_return == 1, "offline recovery must persist")
	local full_inventory = {room_for_item = function() return false end, get_list = function() return {} end}
	local offline_player = {get_inventory = function() return full_inventory end}
	api.deliver_saddles(offline_player, recovered)
	assert(recovered.flags.saddles_to_return and #recovered.flags.saddles_to_return == 1, "full inventory must retain recovery")
	local returned = 0
	function full_inventory:room_for_item() return true end
	function full_inventory:add_item(_, item) assert(ItemStack(item):get_name() == "mcl_mobitems:saddle"); returned = returned + 1; return ItemStack("") end
	api.deliver_saddles(offline_player, recovered)
	api.deliver_saddles(offline_player, recovered)
	assert(returned == 1 and not recovered.flags.saddles_to_return, "return exactly once")
	-- No loaded objects or carried saddle: issuance must still remain closed.
	inventory.count = 0
	api.interact("tack", api.site.tack, player)
	assert(inventory.count == 1, "lost starter must recover free")
	-- Use an actual 36-slot Luanti inventory, as Mineclonia does for players.
	local capacity=core.create_detached_inventory("saddle_capacity", {})
	capacity:set_size("main",36)
	local cp_player={get_player_name=function() return "capacity_test" end,
		get_inventory=function() return capacity end}
	api.states.capacity_test=api.load("capacity_test")
	assert(core.registered_items["harrows_trail:samuel_saddle"])
	for i=1,36 do capacity:set_stack("main",i,"harrows_trail:fragment_1 99") end
	api.interact("tack",api.site.tack,cp_player)
	assert(last_form:find("Make room",1,true) and not api.states.capacity_test.flags.saddle_found)
	assert(not capacity:contains_item("main",api.starter.item))
	capacity:set_stack("main",36,"")
	api.interact("tack",api.site.tack,cp_player)
	local issued=capacity:get_stack("main",36)
	assert(issued:get_name()==api.starter.item and issued:get_count()==1 and api.starter.valid(issued))
	assert(api.states.capacity_test.flags.saddle_found and last_form:find("You recover",1,true))
	api.interact("tack",api.site.tack,cp_player)
	assert(capacity:get_stack("main",36):to_string()==issued:to_string(),"repeat must preserve one exact saddle")
	-- Force add_item to return a leftover even though the capacity check succeeds.
	capacity:set_stack("main",36,"")
	local before_issue=api.storage:get_int("saddle:capacity_test")
	local rejected, checked, attempted
	local deny={get_list=function() return {} end, set_list=function() end, contains_item=function() return false end,
		room_for_item=function(_,list,stack) checked=ItemStack(stack); return true end,
		add_item=function(_,list,stack) attempted=ItemStack(stack); rejected=ItemStack(stack); return rejected end}
	cp_player.get_inventory=function() return deny end
	api.interact("tack",api.site.tack,cp_player)
	assert(checked:get_name()==api.starter.item and attempted:to_string()==rejected:to_string())
	assert(last_form:find("Make room",1,true) and api.storage:get_int("saddle:capacity_test")==before_issue)
	assert(api.starter.valid(issued),"failed insertion must not retire existing issue")
	local pending_state={flags={saddles_to_return={issued:to_string()}}}
	api.deliver_saddles(cp_player,pending_state)
	assert(#pending_state.flags.saddles_to_return==1 and pending_state.flags.saddles_to_return[1]==issued:to_string(),"leftover must stay queued")
	cp_player.get_inventory=function() return capacity end
	for i=1,36 do capacity:set_stack("main",i,"harrows_trail:fragment_1 99") end
	api.deliver_saddles(cp_player,pending_state)
	assert(#pending_state.flags.saddles_to_return==1 and not capacity:contains_item("main",api.starter.item))
	capacity:set_stack("main",36,"")
	api.deliver_saddles(cp_player,pending_state)
	assert(not pending_state.flags.saddles_to_return and capacity:get_stack("main",36):to_string()==issued:to_string())
	api.deliver_saddles(cp_player,pending_state)
	assert(capacity:get_stack("main",36):get_count()==1,"pending return must deliver only once")
	-- Reproduce Luanti's item_place write-back to the selected inventory slot.
	local wield_inv=core.create_detached_inventory("wield_regression", {})
	wield_inv:set_size("main",36)
	local wp={is_player=function() return true end, get_player_name=function() return "wield_test" end,
		get_inventory=function() return wield_inv end,
		get_wielded_item=function() return wield_inv:get_stack("main",1) end,
		get_player_control=function() return {sneak=false} end}
	api.states.wield_test=api.load("wield_test")
	local pointed={type="node",under=api.site.tack,above=vector.add(api.site.tack,{x=0,y=1,z=0})}
	local old_prevent=mcl_hunger.prevent_eating
	mcl_hunger.prevent_eating=function() end
	local returned=core.item_place(ItemStack(""),wp,pointed)
	wield_inv:set_stack("main",1,returned)
	assert(wield_inv:get_stack("main",1):get_name()==api.starter.item,
		"engine wield write-back must retain the newly recovered saddle")
	local original=wield_inv:get_stack("main",1):to_string()
	local again=core.item_place(ItemStack(original),wp,pointed)
	wield_inv:set_stack("main",1,again)
	assert(wield_inv:get_stack("main",1):to_string()==original,
		"repeated right-click must preserve the existing saddle")
	wield_inv:set_stack("main",1,"")
	local cache=api.chapter.positions.cache
	local cache_point={type="node",under=cache,above=vector.add(cache,{x=0,y=1,z=0})}
	local reward=core.item_place(ItemStack(""),wp,cache_point)
	wield_inv:set_stack("main",1,reward)
	assert(wield_inv:get_stack("main",1):get_name()=="mcl_core:gold_ingot" and
		wield_inv:get_stack("main",1):get_count()==12,
		"chapter marker must retain rewards in the selected slot")
	-- Occupied selected slot must remain untouched while the reward uses another slot.
	wield_inv:set_list("main",{})
	wield_inv:set_stack("main",1,"mcl_core:stone")
	api.states.wield_test=api.load("occupied_reward_test")
	local occupied=core.item_place(ItemStack("mcl_core:stone"),wp,cache_point)
	wield_inv:set_stack("main",1,occupied)
	assert(wield_inv:get_stack("main",1):get_name()=="mcl_core:stone" and
		wield_inv:contains_item("main","mcl_core:gold_ingot 12"),
		"occupied wield slot must preserve its item and grant the payroll elsewhere")
	mcl_hunger.prevent_eating=old_prevent
	local recovery_inv=core.create_detached_inventory("recovery_regression",{})
	recovery_inv:set_size("main",8)
	local rp={}
	function rp:get_player_name() return "recovery_player" end
	function rp:get_inventory() return recovery_inv end
	api.states.recovery_player=api.load("recovery_player")
	api.interact("tack",api.site.tack,rp)
	local first=recovery_inv:get_stack("main",1):to_string()
	api.interact("tack",api.site.tack,rp)
	assert(recovery_inv:get_stack("main",1):get_count()==1)
	-- A dropped or unloaded issue is absent from inventory and the nearby scan.
	recovery_inv:set_stack("main",1,"")
	api.interact("tack",api.site.tack,rp)
	local replacement=recovery_inv:get_stack("main",1):to_string()
	assert(not api.starter.valid(first) and api.starter.valid(replacement))
	local native_def=core.registered_entities["mobs_mc:horse"]
	assert(not native_def:is_saddle_item(ItemStack(first)))
	assert(native_def.set_saddle({},ItemStack(first),nil)==false)
	local retired={_saddle=first,remove_saddle=function(self) self._saddle="" end}
	api.starter.retire(retired)
	assert(retired._saddle=="", "reloaded distant horse loses only retired issue")
	recovery_inv:set_stack("main",2,first)
	api.interact("tack",api.site.tack,rp)
	assert(recovery_inv:get_stack("main",2):get_name()=="harrows_trail:retired_saddle")
	local tagged_dead={tamed=true,owner="recovery_player",_saddle=first}
	api.recover_horse_saddle(tagged_dead)
	assert(tagged_dead._saddle=="" and not api.states.recovery_player.flags.saddles_to_return,
		"retired issue death must not return a second usable saddle")
	local far=assert(core.add_entity({x=8,y=222,z=3},"mobs_mc:horse"))
	far:get_luaentity()._saddle=first
	local far_data=far:get_luaentity():get_staticdata()
	far:remove()
	local reloaded=assert(core.add_entity({x=8,y=222,z=3},"mobs_mc:horse",far_data))
	api.starter.retire(reloaded:get_luaentity())
	assert(reloaded:get_luaentity()._saddle=="", "native serialized old horse must retire its saddle")
	reloaded:remove()
	local live=assert(core.add_entity({x=8,y=222,z=3},"mobs_mc:horse"))
	local live_horse=live:get_luaentity()
	assert(live_horse:is_saddle_item(ItemStack(replacement)))
	assert(live_horse:set_saddle(ItemStack(replacement),nil), "native interface must fit current story saddle")
	assert(api.starter.valid(live_horse._saddle))
	live_horse.tamed=true; live_horse.owner="recovery_player"
	api.recover_horse_saddle(live_horse)
	assert(live_horse._saddle=="")
	local queue=api.states.recovery_player.flags.saddles_to_return
	assert(queue and queue[1]==replacement, "death must preserve current issue metadata")
	-- Remove the simulated carried copy before delivering the equipped saddle.
	recovery_inv:set_stack("main",1,"")
	api.deliver_saddles(rp,api.states.recovery_player)
	assert(recovery_inv:contains_item("main",ItemStack(replacement)))
	live:remove()
	local kept=recovery_inv:get_stack("main",1):to_string()
	for i=1,8 do recovery_inv:set_stack("main",i,"harrows_trail:fragment_1 99") end
	api.interact("tack",api.site.tack,rp)
	assert(api.starter.valid(kept), "full inventory must not revoke current issue")
	api.storage:set_string("old_issue_test",first)
	api.storage:set_string("new_issue_test",replacement)
	api.save("recovery_player")
	local chapter=api.chapter
	assert(core.registered_items["mcl_lanterns:lantern_floor"])
	local real=core.create_detached_inventory("chapter_test", {})
	real:set_size("main",32)
	local cp={pos=chapter.positions.ada}
	function cp:get_player_name() return "chapter_player" end
	function cp:get_inventory() return real end
	function cp:get_pos() return self.pos end
	function cp:get_attach() return nil end
	local cs=api.load("chapter_player"); cs.unlocked['2']=true; cs.flags.choice="evidence"
	api.states.chapter_player=cs
	local ingot_state=api.load("ingot_gate")
	real:add_item("main","mcl_core:gold_ingot 9")
	assert(chapter.unlock(cp,ingot_state,3))
	assert(not real:contains_item("main","mcl_core:gold_ingot"))
	assert(not chapter.unlock(cp,cs,3))
	real:add_item("main","mcl_core:goldblock")
	assert(chapter.unlock(cp,cs,3) and not real:contains_item("main","mcl_core:goldblock"))
	assert(chapter.unlock(cp,cs,3), "permanent unlock must not charge again")
	chapter.interact("jesse",chapter.positions.jesse,cp,cs)
	assert(cs.map_fragments['2'] and cs.flags.jesse_briefed)
	assert(not chapter.unlock(cp,cs,4))
	real:add_item("main","mcl_lanterns:lantern_floor 4")
	assert(chapter.unlock(cp,cs,4) and real:contains_item("main","mcl_lanterns:lantern_floor 4"))
	local old_time=core.get_timeofday
	core.get_timeofday=function() return 0 end
	cp.pos=chapter.positions.dust
	chapter.interact("dust",cp.pos,cp,cs)
	chapter.receive(cp,"harrows_trail:story",{exposed_route=true})
	assert(cs.flags.route=="exposed")
	chapter.interact("exposed",chapter.positions.exposed,cp,cs)
	assert(cs.flags.crossing_mark)
	chapter.interact("dust",cp.pos,cp,cs)
	chapter.receive(cp,"harrows_trail:story",{sheltered_route=true})
	assert(cs.flags.route=="sheltered" and not cs.flags.crossing_mark)
	core.get_timeofday=old_time
	cs.flags.route="sheltered"
	chapter.interact("shelter2",chapter.positions.shelter2,cp,cs)
	assert(not cs.flags.crossing_mark)
	chapter.interact("shelter1",chapter.positions.shelter1,cp,cs)
	chapter.interact("shelter2",chapter.positions.shelter2,cp,cs)
	chapter.interact("gulch",chapter.positions.gulch,cp,cs)
	assert(cs.flags.arrived and cs.act==4)
	cp.pos=chapter.positions.ruth
	real:add_item("main","mcl_core:gold_ingot 3")
	chapter.interact("ruth",cp.pos,cp,cs)
	chapter.receive(cp,"harrows_trail:story",{lantern_buy=true})
	assert(real:contains_item("main","mcl_lanterns:lantern_floor 8"))
	assert(not real:contains_item("main","mcl_core:gold_ingot"))
	chapter.receive(cp,"harrows_trail:story",{lantern_buy=true})
	assert(real:contains_item("main","mcl_lanterns:lantern_floor 8"))

	-- Exercise all reward paths with a real inventory and a controlled partial insertion.
	local gi=core.create_detached_inventory("grant_paths", {})
	gi:set_size("main",36)
	local active=gi
	local gp={pos=api.chapter.positions.cache}
	function gp:get_player_name() return "grant_test" end
	function gp:get_inventory() return active end
	function gp:get_pos() return self.pos end
	local gs=api.load("grant_test"); api.states.grant_test=gs
	local function count(item)
	 local total=0
	 for _,stack in ipairs(gi:get_list("main")) do if stack:get_name()==item then total=total+stack:get_count() end end
	 return total
	end
	local function clear() gi:set_list("main",{}) end
	local function partial()
	 return {
	  get_list=function(_,list) return gi:get_list(list) end,
	  set_list=function(_,list,items) return gi:set_list(list,items) end,
	  room_for_item=function() return true end,
	  contains_item=function(_,list,item) return gi:contains_item(list,item) end,
	  remove_item=function(_,list,item) return gi:remove_item(list,item) end,
	  add_item=function(_,list,item)
	   local rest=ItemStack(item)
	   local part=rest:take_item(math.max(1, math.floor(rest:get_count()/2)))
	   assert(gi:add_item(list,part):is_empty())
	   return rest:is_empty() and ItemStack(item) or rest
	  end,
	 }
	end
	-- Full and limited-space attempts leave one-time payroll unclaimed.
	for i=1,36 do gi:set_stack("main",i,"harrows_trail:fragment_1 99") end
	gi:set_stack("main",1,"mcl_core:gold_ingot 60")
	chapter.interact("cache",gp.pos,gp,gs)
	assert(not gs.flags.payroll and count("mcl_core:gold_ingot")==60 and last_form:find("Make room",1,true))
	clear(); active=partial()
	chapter.interact("cache",gp.pos,gp,gs)
	assert(not gs.flags.payroll and count("mcl_core:gold_ingot")==0)
	api.save("grant_test"); assert(not api.load("grant_test").flags.payroll, "failed claim must remain retryable after reload")
	active=gi; chapter.interact("cache",gp.pos,gp,gs)
	assert(gs.flags.payroll and count("mcl_core:gold_ingot")==12)
	chapter.interact("cache",gp.pos,gp,gs)
	assert(count("mcl_core:gold_ingot")==12 and last_form:find("already recovered",1,true))
	api.save("grant_test"); assert(api.load("grant_test").flags.payroll)
	-- A failed parcel reward retains the parcel and rolls back partial gold.
	clear(); gs.flags.parcel=true; active=partial()
	chapter.interact("depot",chapter.positions.depot,gp,gs)
	assert(gs.flags.parcel and count("mcl_core:gold_ingot")==0)
	active=gi; chapter.interact("depot",chapter.positions.depot,gp,gs)
	assert(not gs.flags.parcel and count("mcl_core:gold_ingot")==3)
	chapter.interact("depot",chapter.positions.depot,gp,gs)
	assert(count("mcl_core:gold_ingot")==3)
	-- Both fragments remain retryable if a supposedly successful add returns a leftover.
	clear(); active=partial(); gs.map_fragments['1']=nil; gs.flags.ranch_clue=nil
	api.interact("barn",api.site.barn,gp)
	assert(not gs.map_fragments['1'] and count("harrows_trail:fragment_1")==0)
	active=gi; api.interact("barn",api.site.barn,gp)
	assert(gs.map_fragments['1'] and count("harrows_trail:fragment_1")==1)
	api.interact("barn",api.site.barn,gp); assert(count("harrows_trail:fragment_1")==1)
	gs.unlocked['3']=true; gs.flags.jesse_briefed=nil; gs.map_fragments['2']=nil
	active=partial(); chapter.interact("jesse",chapter.positions.jesse,gp,gs)
	assert(not gs.flags.jesse_briefed and not gs.map_fragments['2'] and count("harrows_trail:fragment_2")==0)
	active=gi; chapter.interact("jesse",chapter.positions.jesse,gp,gs)
	assert(gs.flags.jesse_briefed and count("harrows_trail:fragment_2")==1)
	chapter.interact("jesse",chapter.positions.jesse,gp,gs); assert(count("harrows_trail:fragment_2")==1)
	-- Failed and partial purchases preserve all gold and roll back the reward.
	for _,shop in ipairs({{kind="ruth",key="lantern_buy",item="mcl_lanterns:lantern_floor",amount=4},
		{kind="dutch",key="saddle_buy",item="mcl_mobitems:saddle",amount=1}}) do
	 clear()
	 for i=1,36 do gi:set_stack("main",i,"harrows_trail:fragment_1 99") end
	 gi:set_stack("main",1,"mcl_core:gold_ingot 3")
	 gp.pos=chapter.positions[shop.kind]; active=gi
	 chapter.interact(shop.kind,gp.pos,gp,gs)
	 chapter.receive(gp,"harrows_trail:story",{[shop.key]=true})
	 assert(count("mcl_core:gold_ingot")==3 and count(shop.item)==0, "full shop inventory must not take payment")
	 gi:set_stack("main",36,"")
	 chapter.interact(shop.kind,gp.pos,gp,gs)
	 chapter.receive(gp,"harrows_trail:story",{[shop.key]=true})
	 assert(count("mcl_core:gold_ingot")==0 and count(shop.item)==shop.amount, "shop retry must grant exactly once")
	 clear(); assert(gi:add_item("main","mcl_core:gold_ingot 3"):is_empty())
	 gp.pos=chapter.positions[shop.kind]; active=partial()
	 chapter.interact(shop.kind,gp.pos,gp,gs)
	 chapter.receive(gp,"harrows_trail:story",{[shop.key]=true})
	 assert(count("mcl_core:gold_ingot")==3 and count(shop.item)==0)
	 active={get_list=function(_,list) return gi:get_list(list) end,
		set_list=function(_,list,items) return gi:set_list(list,items) end,
		room_for_item=function(_,list,item) return gi:room_for_item(list,item) end,
		contains_item=function(_,list,item) return gi:contains_item(list,item) end,
		add_item=function(_,list,item) return gi:add_item(list,item) end,
		remove_item=function(_,list,item) return gi:remove_item(list,"mcl_core:gold_ingot") end}
	 chapter.interact(shop.kind,gp.pos,gp,gs)
	 chapter.receive(gp,"harrows_trail:story",{[shop.key]=true})
	 assert(count("mcl_core:gold_ingot")==3 and count(shop.item)==0, "partial payment must restore the entire inventory")
	 active=gi; chapter.interact(shop.kind,gp.pos,gp,gs)
	 chapter.receive(gp,"harrows_trail:story",{[shop.key]=true})
	 assert(count("mcl_core:gold_ingot")==0 and count(shop.item)==shop.amount)
	 chapter.receive(gp,"harrows_trail:story",{[shop.key]=true})
	 assert(count(shop.item)==shop.amount)
	end
	-- Sprint 3 uses the real chapter callbacks and a Luanti detached inventory.
	local sp={pos=chapter.positions.pass}
	local si=core.create_detached_inventory('sprint3_inventory', {}); si:set_size('main',36)
	function sp:get_player_name() return 'sprint3_player' end
	function sp:get_inventory() return si end
	function sp:get_pos() return self.pos end
	local ss=api.load('sprint3_player'); ss.flags.arrived=true; ss.flags.choice='evidence'; ss.unlocked['4']=true
	api.states.sprint3_player=ss
	for _,id in ipairs({'mcl_tools:pick_iron','mcl_tnt:tnt','mcl_maps:filled_map','mcl_boats:boat_spruce'}) do assert(core.registered_items[id],id) end
	local function use(kind, fields)
	 sp.pos=chapter.positions[kind]; chapter.interact(kind,sp.pos,sp,ss)
	 if fields then chapter.receive(sp,'harrows_trail:story',fields) end
	end
	use('pass',{start5=true}); assert(not ss.unlocked['5'])
	si:add_item('main','mcl_tools:pick_iron'); use('pass',{start5=true})
	assert(ss.unlocked['5'] and si:contains_item('main','mcl_tools:pick_iron'))
	use('rubble2'); assert(not ss.flags.rubble2); use('rubble1'); use('rubble2'); use('assay')
	assert(ss.map_fragments['3'] and si:contains_item('main','harrows_trail:fragment_3'))
	use('station',{left=true}); assert(not ss.unlocked['6'])
	si:add_item('main','mcl_tnt:tnt 2'); use('station',{left=true}); assert(ss.unlocked['6'] and si:contains_item('main','mcl_tnt:tnt') and not si:contains_item('main','mcl_tnt:tnt 2'))
	use('station',{right=true}); assert(ss.flags.charge_side=='right' and si:contains_item('main','mcl_tnt:tnt'))
	use('charge',{trigger=true}); use('mine_gate',{start7=true}); assert(not ss.unlocked['7'])
	local map=mcl_maps.create_map({x=125,y=221,z=0}); si:add_item('main',map)
	use('mine_gate',{start7=true}); assert(ss.unlocked['7'] and si:contains_item('main',map))
	use('ledger1'); assert(not ss.flags.ledger1); use('mine_clue'); use('ledger1')
	assert(ss.flags.ledger1 and si:contains_item('main','harrows_trail:ledger_1'))
	use('ferry',{start8=true}); assert(not ss.unlocked['8']); si:add_item('main','mcl_boats:boat_spruce'); use('ferry',{start8=true})
	assert(ss.unlocked['8'] and si:contains_item('main','mcl_boats:boat_spruce'))
	use('ferry',{waiver=true}); assert(not ss.flags.ferry_crossed); use('snag'); use('hideout'); use('ledger2')
	assert(ss.flags.ledger2 and si:contains_item('main','harrows_trail:ledger_2') and ss.flags.ferry_method=='snag')
	assert(not ss.flags.gold_found and api.journal(ss):find('Widowmaker',1,true))
	-- Optional cache and both other ferry choices are separate from the main route.
	ss.map_fragments['1']=true; ss.map_fragments['2']=true; use('cartography'); use('gold_cache'); use('gold_cache')
	assert(ss.flags.gold_found and si:contains_item('main','harrows_trail:harrow_map') and si:contains_item('main','mcl_core:gold_ingot 6') and not si:contains_item('main','mcl_core:gold_ingot 7'))
	ss.flags.ferry_crossed=nil; ss.honor=53; use('ferry',{waiver=true}); assert(ss.flags.ferry_method=='waiver')
	ss.flags.ferry_crossed=nil; use('ferry',{pay=true}); assert(ss.flags.ferry_method=='pay' and si:contains_item('main','mcl_core:gold_ingot 3') and not si:contains_item('main','mcl_core:gold_ingot 4'))
	ss.flags.ferry_method='snag'
	dofile(core.get_modpath("sprint1_test") .. "/finale.lua")(api)
	api.save('sprint3_player')
	api.save("chapter_player")
	api.save(player_name)
	api.states.fresh_test = api.load("fresh_test")
	api.states.fresh_test.flags.start_pending = nil
	api.save("fresh_test")
	finish()
end
local function wait_for_site(attempt)
	if api.storage:get_string("site_ready") == "1" and api.storage:get_string("chapter_site") == "1" and api.storage:get_string("sprint3_site") == "1" and api.storage:get_string("sprint4_site") == "1" then return run_first() end
	assert(attempt < 90, "site did not finish placement")
	core.after(1, wait_for_site, attempt + 1)
end
core.after(0, function()
	if phase == "write" then
		api.ensure_site()
		api.chapter.ensure()
		api.chapter.ensure_more()
		api.finale.ensure()
		wait_for_site(0)
	elseif phase == "read" then
		assert(not api.starter.valid(api.storage:get_string("old_issue_test")))
		assert(api.starter.valid(api.storage:get_string("new_issue_test")))
		assert(api.world_sites.placed('test_fixture'))
		local duel=api.load('duel_test'); assert(duel.flags.mercer_outcome=='killed' and duel.flags.mercer_hits==3)
		local finale=api.load('finale_test'); assert(finale.verdict=='mercy' and finale.flags.gold_choice=='ranch' and finale.nora_trust==60 and finale.unlocked['9'] and finale.unlocked['10'])
		local later=api.load('sprint3_player')
		assert(later.act==8 and later.unlocked['5'] and later.unlocked['6'] and later.unlocked['7'] and later.unlocked['8'])
		assert(later.flags.ledger1 and later.flags.ledger2 and later.flags.station_breached and later.flags.ferry_method=='snag')
		assert(api.storage:get_string('sprint3_site')=='1')
		local persisted=api.load("chapter_player")
		assert(persisted.act==4 and persisted.flags.arrived and persisted.unlocked["4"])
		local s = api.load(player_name)
		assert(s.version == 1 and s.map_fragments['1'] and s.flags.saddle_found)
		assert(s.unlocked['2'] and s.act == 2 and s.flags.reached_mesa)
		assert(s.flags.choice == "evidence" and s.honor == 53)
		assert(api.journal(s):find("Bail", 1, true))
		assert(api.storage:get_string("site_ready") == "1")
		local waiting = api.load("offline_saddle_test")
		assert(waiting.flags.saddles_to_return and #waiting.flags.saddles_to_return == 1,
			"horse death recovery must survive restart")
		core.set_node(api.site.ada, {name = "mcl_core:obsidian"})
		api.ensure_site()
		assert(core.get_node(api.site.ada).name == "mcl_core:obsidian", "placed site must not be rebuilt")
		local fresh = api.load("fresh_test")
		assert(type(fresh.flags) == "table" and type(fresh.map_fragments) == "table")
		assert(api.journal(fresh):find("burned ranch", 1, true))
		finish()
	elseif phase == "survey" then
		core.emerge_area({x = -13, y = -32, z = -10}, {x = 65, y = 219, z = 10}, function(_, action, remaining)
			assert(action ~= core.EMERGE_ERRORED and action ~= core.EMERGE_CANCELLED)
			if remaining ~= 0 then return end
			for _, x in ipairs({0, 55}) do
				local height = "below -32"
				for y = 219, -32, -1 do
					local node = core.get_node({x = x, y = y, z = 0}).name
					if core.get_item_group(node, "solid") > 0 then height = tostring(y); break end
				end
				core.log("action", "[sprint1_test] survey x=" .. x .. " ground=" .. height)
			end
			local pois = mcl_villages.get_pois_in_by_nodepos({x=-13,y=-32,z=-10}, {x=65,y=219,z=10})
			core.log("action", "[sprint1_test] survey registered village POIs=" .. #pois)
			finish()
		end)
	elseif phase == "blocked" then
		core.emerge_area({x = -13, y = 219, z = -10}, {x = 65, y = 224, z = 10}, function(_, action, remaining)
			assert(action ~= core.EMERGE_ERRORED and action ~= core.EMERGE_CANCELLED)
			if remaining ~= 0 then return end
			core.set_node(api.site.barn, {name = "mcl_core:obsidian"})
			api.ensure_site()
			core.after(3, function()
				assert(api.storage:get_string("site_ready") == "")
				assert(core.get_node(api.site.barn).name == "mcl_core:obsidian")
				assert(core.get_node(api.site.ada).name == "air")
				finish()
			end)
		end)
	else error("missing test phase") end
end)
