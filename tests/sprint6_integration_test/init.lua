local api=assert(harrows_trail_test)
local phase=assert(core.settings:get('harrows_sprint6_integration_phase'))
local function finish()
 core.log('action','[sprint6_integration] PASS '..phase)
 core.request_shutdown('integration complete',false,0)
end
if phase=='read' then
 core.after(0,function()
  assert(api.midgame_mode() and api.storage:get_string('world_layout_version')=='6')
  local s=api.load('midgame_test')
  assert(s.unlocked['7'] and s.flags.ledger1 and s.flags.station_breached and s.flags.gold_found)
  assert(s.map_fragments['3'] and s.flags.midgame_route_step and s.flags.midgame_route_step>1)
  assert(api.chapter.positions.dust.x==642 and api.chapter.positions.mine_gate.z==832)
  for _,id in ipairs({'ranch','red_mesa','dust_flats','dry_gulch','iron_pass','silver_spur','ghost_mine','gulch_bridge','foothill_bridge','pass_bridge'}) do assert(api.world_sites.placed(id),id) end
  finish()
 end)
 return
end
local jobs={'ranch','red_mesa','dust_flats','dry_gulch','iron_pass','silver_spur','ghost_mine','gulch_bridge','foothill_bridge','pass_bridge'}
local function wait_for(check,done,n)
 n=n or 0;assert(n<60,'integration wait timed out')
 if check() then return done() end
 core.after(1,wait_for,check,done,n+1)
end
local function exercise()
 local inv=core.create_detached_inventory('midgame_test',{});inv:set_size('main',36)
 local p={pos=api.chapter.positions.dust}
 function p:get_player_name() return 'midgame_test' end
 function p:get_inventory() return inv end
 function p:get_pos() return self.pos end
 function p:set_pos(pos) self.pos=vector.new(pos) end
 function p:get_attach() return nil end
 function p:get_wielded_item() return ItemStack('') end
 local s=api.load('midgame_test');s.flags.choice='evidence';s.flags.jesse_briefed=true;s.flags.jesse_free=true
 s.unlocked['2']=true;s.unlocked['3']=true;s.act=3;s.map_fragments['1']=true;s.map_fragments['2']=true;api.states.midgame_test=s
 local positions=api.chapter.positions
 local function at(kind) p.pos=positions[kind];api.interact(kind,positions[kind],p) end
 local function submit(fields) api.chapter.receive(p,'harrows_trail:story',fields) end
 local old_show=core.show_formspec;core.show_formspec=function() end
 core.set_timeofday(0)
 at('dust');submit({exposed_route=true});assert(not s.unlocked['4'])
 inv:add_item('main','mcl_lanterns:lantern_floor 4')
 at('dust');submit({exposed_route=true});assert(s.unlocked['4'] and s.flags.route=='exposed')
 at('exposed');assert(s.flags.crossing_mark)
 at('dust');submit({sheltered_route=true});assert(not s.flags.crossing_mark)
 at('shelter2');assert(not s.flags.crossing_mark)
 at('shelter1');at('shelter2');assert(s.flags.crossing_mark)
 at('gulch');assert(s.flags.arrived and inv:contains_item('main','mcl_lanterns:lantern_floor 4'))
 p.pos={x=532,y=8,z=1212};local label,target=api.midgame_target(p,s);assert(label=='Walking trail to Iron Pass' and target and s.flags.midgame_route_step>1)
 at('pass');submit({start5=true});assert(not s.unlocked['5'])
 inv:add_item('main','mcl_tools:pick_iron');at('pass');submit({start5=true});assert(s.unlocked['5'])
 at('rubble2');assert(not s.flags.rubble2);at('rubble1');at('rubble2');assert(s.flags.rubble2)
 assert(core.get_node({x=-478,y=54,z=-514}).name=='air' and core.get_node({x=-472,y=55,z=-516}).name=='air')
 assert(core.get_node({x=-480,y=55,z=-512}).name=='harrows_trail:mid_rubble1_cleared')
 assert(inv:contains_item('main','mcl_tools:pick_iron'))
 at('assay');at('assay');assert(s.map_fragments['3'] and inv:contains_item('main','harrows_trail:fragment_3'))
 local fragments=0;for _,stack in ipairs(inv:get_list('main')) do if stack:get_name()=='harrows_trail:fragment_3' then fragments=fragments+stack:get_count() end end;assert(fragments==1)
 assert(not s.flags.gold_found and not s.flags.harrow_map)
 local old_get=core.get_player_by_name;core.get_player_by_name=function(name) if name=='midgame_test' then return p else return old_get(name) end end
 assert(api.world_travel.travel('midgame_test','station'))
 wait_for(function() return math.abs(p.pos.x-181)<=5 and p.pos.y>200 end,function()
  at('station');submit({left=true});assert(not s.unlocked['6'])
  inv:add_item('main','mcl_tnt:tnt');at('station');submit({left=true});assert(s.unlocked['6'] and not inv:contains_item('main','mcl_tnt:tnt'))
  at('station');submit({right=true});assert(s.flags.charge_side=='right')
  at('charge');submit({trigger=true});assert(s.flags.station_breached)
  at('station');assert(api.world_travel.travel('midgame_test','mine'))
  wait_for(function() return math.abs(p.pos.z-832)<=6 and p.pos.y<100 end,function()
   at('mine_gate');submit({start7=true});assert(not s.unlocked['7'])
   local map=ItemStack('mcl_maps:filled_map');local meta=map:get_meta();meta:set_string('mcl_maps:id','integration-map')
   meta:set_string('mcl_maps:minp','(100, 0, -20)');meta:set_string('mcl_maps:maxp','(150, 0, 20)');inv:add_item('main',map)
   at('mine_gate');submit({start7=true});assert(not s.unlocked['7'],'legacy coordinates must not satisfy the new map gate')
   map=ItemStack('mcl_maps:filled_map');meta=map:get_meta();meta:set_string('mcl_maps:id','badlands-map')
   meta:set_string('mcl_maps:minp','(520, 0, 800)');meta:set_string('mcl_maps:maxp','(600, 0, 880)');inv:add_item('main',map)
   at('mine_gate');submit({start7=true});assert(s.unlocked['7'] and inv:contains_item('main','mcl_maps:filled_map'))
   at('ledger1');assert(not s.flags.ledger1);at('mine_clue');at('ledger1');at('ledger1');assert(s.flags.ledger1 and not s.flags.gold_found)
   at('cartography');at('gold_cache');assert(s.flags.gold_found and inv:contains_item('main','mcl_core:gold_ingot 6'))
   at('gold_cache');local gold=0;for _,stack in ipairs(inv:get_list('main')) do if stack:get_name()=='mcl_core:gold_ingot' then gold=gold+stack:get_count() end end;assert(gold==6)
   api.save('midgame_test');core.get_player_by_name=old_get;core.show_formspec=old_show;finish()
  end)
 end)
end
local function place(i)
 local id=jobs[i]
 if not id then api.chapter.ensure_more();return wait_for(function() return api.storage:get_string('sprint3_site')=='1' end,exercise) end
 api.ensure_grounded_site(id)
 wait_for(function() return api.world_sites.placed(id) end,function()place(i+1)end)
end
core.after(0,function()assert(api.midgame_mode());place(1)end)
