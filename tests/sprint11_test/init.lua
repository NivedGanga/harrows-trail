local phase=core.settings:get('harrows_sprint11_phase')
local function finish()core.log('action','[sprint11_test] PASS '..phase);core.request_shutdown('release QA complete',false,0)end
if phase=='release' then
 core.after(0,function()
  assert(rawget(_G,'harrows_trail_test')==nil,'test API must be absent in release configuration')
  assert(core.registered_chatcommands.trail_sites.privs.server)
  assert(core.registered_chatcommands.trail_report and core.registered_nodes['harrows_trail:weathered_wood'])
  assert(core.get_version().string=='5.17.0')
  core.emerge_area({x=650,y=16,z=648},{x=658,y=25,z=656},function(_,_,left)
   if left==0 then core.after(0,function()assert(mcl_biome_dispatch.get_biome_name({x=654,y=19,z=652}):find('Savanna',1,true));finish()end)end
  end)
 end);return
end
local a=assert(harrows_trail_test)
core.after(0,function()
 if phase=='read' then
  local s=a.load('budget_test');assert(s.verdict=='justice' and s.unlocked['10'] and s.flags.budget_remaining==7 and not s.flags.gold_found)
  assert(s.flags.contract_red_mesa and s.flags.contract_dry_gulch and s.flags.contract_silver_spur and s.flags.contract_bitter_river)
  assert(s.wanted==0 and s.flags.nora_freed);finish();return
 end
 local r=a.reputation;local inv=core.create_detached_inventory('budget_test',{});inv:set_size('main',54)
 local p={name='budget_test',pos=a.site.barn,meta=ItemStack('mcl_core:stone'):get_meta()}
 function p:get_player_name()return self.name end;function p:get_pos()return self.pos end;function p:set_pos(pos)self.pos=vector.new(pos)end
 function p:get_inventory()return inv end;function p:get_attach()return nil end;function p:get_wielded_item()return ItemStack('')end
 function p:is_player()return true end;function p:punch()end;function p:get_meta()return self.meta end
 function p:get_sky()return {type='regular'}end;function p:set_sky()end
 local s=a.load(p.name);a.states[p.name]=s
 local function gold()local n=0;for _,stack in ipairs(inv:get_list('main'))do if stack:get_name()=='mcl_core:gold_ingot' then n=n+stack:get_count()end end;return n end
 local function at(kind,fields)
  p.pos=a.chapter.positions[kind] or a.site[kind];a.interact(kind,p.pos,p)
  if fields then a.chapter.receive(p,'harrows_trail:story',fields)end
 end
 local function final(kind,fields)p.pos=a.finale.positions[kind];a.finale.interact(kind,p,s);if fields then a.finale.receive(p,'harrows_trail:finale',fields)end end
 local towns={red_mesa=a.world_buildings.positions.ada,dry_gulch=a.chapter.positions.gulch,silver_spur=a.chapter.positions.assay,bitter_river=a.chapter.positions.ferry}
 local function service(id,field)p.pos=towns[id];r.show(p);r.receive(p,'harrows_trail:frontier',{[field]=true})end
 for id in pairs(towns)do a.storage:set_string('world_site_v1:'..id,'1')end
 a.storage:set_string('site',core.write_json(a.site))
 -- Travel is simulated here; mounted validation, actual structures and paths are checked by earlier suites.
 a.interact('barn',a.site.barn,p);s.unlocked['2']=true
 at('cache');assert(gold()==12)
 p.pos=a.site.ada;a.interact('ada',p.pos,p);a.receive_fields(p,'harrows_trail:story',{evidence=true})
 assert(s.honor==53);service('red_mesa','claim');assert(gold()==21)
 at('ada',{bail=true});assert(s.unlocked['3'] and gold()==12);at('jesse')
 at('ruth',{lantern_buy=true});assert(gold()==9 and inv:contains_item('main','mcl_lanterns:lantern_floor 4'))
 core.set_timeofday(0);at('dust',{exposed_route=true});at('exposed');at('gulch');assert(s.flags.arrived)
 service('dry_gulch','claim');service('dry_gulch','pick');assert(gold()==15)
 at('pass',{start5=true});at('rubble1');at('rubble2');at('assay');assert(s.map_fragments['3'])
 service('silver_spur','claim');service('silver_spur','tnt');service('silver_spur','map');service('silver_spur','boat');assert(gold()==25)
 assert(a.chapter.unlock(p,s,6));assert(not inv:contains_item('main','mcl_tnt:tnt'))
 s.flags.station_breached=true -- Physical owned-barrier detonation is separately exercised in Sprint 7 integration.
 assert(inv:remove_item('main','mcl_maps:empty_map'):get_count()==1)
 inv:add_item('main',mcl_maps.create_map({x=560,y=22,z=844}))
 at('mine_gate',{start7=true});assert(s.unlocked['7']);at('mine_clue');at('ledger1')
 service('bitter_river','claim');at('ferry',{start8=true});at('ferry',{pay=true});assert(gold()==35 and s.flags.ferry_crossed)
 at('hideout');at('ledger2');final('supplies',{apples=true});final('supplies',{duster=true});final('supplies',{bow=true});assert(gold()==19)
 final('gate',{start=true});assert(s.unlocked['9'] and not inv:contains_item('main','mcl_core:apple_gold'))
 assert(inv:contains_item('main','mcl_tools:pick_iron') and inv:contains_item('main','mcl_boats:boat_spruce') and inv:contains_item('main','mcl_armor:chestplate_leather') and inv:contains_item('main','mcl_bows:crossbow_loaded'))
 final('mercer',{cover=true});final('mercer',{spare=true});final('nora',{promise=true});final('crane',{disarm=true})
 local actor=core.registered_entities['harrows_trail:finale_actor'];actor.on_punch({kind='crane',object={}},p);actor.on_punch({kind='crane',object={}},p)
 final('crane',{capture=true});final('verdict',{justice=true});assert(s.verdict=='justice' and not s.flags.gold_found)
 for _=1,4 do r.event(s,'horse_theft')end;assert(s.wanted==4 and r.fine(p,s) and gold()==7)
 service('red_mesa','claim');assert(gold()==7,'contract replay must not increase the budget')
 s.flags.budget_remaining=gold();a.save(p.name)
 local ok,report=a.release.report(p.name);assert(ok and not report:find('budget_test',1,true) and not report:find('honor',1,true) and not report:find('nora_trust',1,true))
 core.log('action','[sprint11_test] economy=PASS starting_gold=0 mining=0 repeat_deliveries=0 cache=not_found fine=12 remaining_gold=7')
 -- Endings and the optional payroll choice remain independent, with all 12 combinations.
 for _,verdict in ipairs({'justice','mercy','vengeance'})do for _,choice in ipairs({'none','railroad','keep_gold','ranch'})do
  p.name='ending_'..verdict..'_'..choice;local t=a.load(p.name);a.states[p.name]=t;t.verdict=verdict;t.flags.nora_freed=true;t.flags.gold_found=choice~='none'
  p.pos=a.finale.positions.ending;a.finale.interact('ending',p,t);a.finale.receive(p,'harrows_trail:finale',{[choice=='none' and 'railroad' or choice]=true})
  assert((not t.flags.gold_choice)==(choice=='none'));if choice~='none'then assert(t.flags.gold_choice==({keep_gold='keep'})[choice] or t.flags.gold_choice==choice)end
  assert(#a.finale.epilogue(t)>50)
 end end
 p.name='stress_probe';p.pos={x=620,y=30,z=788};p.meta:set_string('harrows_trail:audio','on')
 core.emerge_area({x=612,y=28,z=780},{x=632,y=33,z=800},function(_,_,left)
  if left~=0 then return end
  core.after(0,function()
   local objects={};for x=614,629 do for z=782,795 do core.set_node({x=x,y=29,z=z},{name='mcl_core:stone'});for y=30,31 do core.set_node({x=x,y=y,z=z},{name='air'})end end end
   for i=1,32 do local obj=assert(core.add_entity({x=614+i%8,y=30,z=784+math.floor((i-1)/8)},'harrows_trail:opening_actor','ada'));objects[#objects+1]=obj end
   local orig={clock=core.get_gametime,day=core.get_day_count,tod=core.get_timeofday,light=core.get_natural_light,particle=core.add_particle,sound=core.sound_play,stop=core.sound_stop}
   local clock,emitted,handles=0,0,0;local day=0;while a.atmosphere.weather(core.get_mapgen_setting('seed'),day,'red_mesa',.5)~='dust'do day=day+1;assert(day<100)end
   core.get_gametime=function()return clock end;core.get_day_count=function()return day end;core.get_timeofday=function()return .5 end;core.get_natural_light=function()return 15 end
   core.add_particle=function()emitted=emitted+1 end;core.sound_play=function()handles=handles+1;return handles end;core.sound_stop=function()end
   local state=a.load('stress_probe');local start=core.get_us_time()
   for _=1,100 do clock=clock+2;local n,h=a.atmosphere.update(p);assert(n<=12 and h<=2);for _,obj in ipairs(objects)do a.cast.tick(obj:get_luaentity(),p,state)end end
   local ms=(core.get_us_time()-start)/1000;assert(ms<5000 and emitted==1200 and handles<=2)
   a.atmosphere.stop(p,false);for _,obj in ipairs(objects)do obj:remove()end
   core.get_gametime=orig.clock;core.get_day_count=orig.day;core.get_timeofday=orig.tod;core.get_natural_light=orig.light;core.add_particle=orig.particle;core.sound_play=orig.sound;core.sound_stop=orig.stop
   core.log('action','[sprint11_test] stress_npcs=32 ticks=100 particle_batch=12 audio_handles=2 total_ms='..ms..' client_fps=unverified')
   finish()
  end)
 end)
end)
