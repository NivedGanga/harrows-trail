local api=assert(harrows_trail_test)
local phase=assert(core.settings:get('harrows_sprint7_integration_phase'))
local function finish() core.log('action','[sprint7_integration] PASS '..phase);core.request_shutdown('integration complete',false,0) end
if phase=='read' then
 core.after(0,function()
  assert(api.late_mode() and api.storage:get_string('world_layout_version')=='7')
  for name,verdict in pairs({late_main='justice',late_mercy='mercy',late_vengeance='vengeance'}) do
   local s=api.load(name);assert(s.verdict==verdict and s.flags.nora_freed and s.unlocked['10'])
  end
  local s=api.load('late_main');assert(s.flags.station_breached and s.flags.ferry_method=='snag' and s.flags.ledger2 and not s.flags.gold_found)
  assert(s.flags.late_route and s.flags.late_route_step and api.finale.positions.verdict==api.world_buildings.positions.ada)
  assert(api.chapter.positions.station.y<100 and api.finale.positions.nora.y<100)
  assert(api.world_sites.placed('station') and api.world_sites.placed('bitter_river') and api.world_sites.placed('widowmaker'))
  api.finale.ensure_actors();finish()
 end)
 return
end
local function wait_for(check,done,n)
 n=n or 0;assert(n<60,'integration wait timed out');if check() then return done() end;core.after(1,wait_for,check,done,n+1)
end
local function player(name)
 local inv=core.create_detached_inventory(name,{});inv:set_size('main',48)
 local p={pos={x=0,y=0,z=0},hits=0}
 function p:get_player_name() return name end
 function p:get_inventory() return inv end
 function p:get_pos() return self.pos end
 function p:set_pos(pos) self.pos=vector.new(pos) end
 function p:get_attach() return nil end
 function p:get_wielded_item() return ItemStack('') end
 function p:is_player() return true end
 function p:punch() self.hits=self.hits+1 end
 local s=api.load(name);api.states[name]=s
 return p,s,inv
end
local function count(inv,item)
 local n=0;for _,stack in ipairs(inv:get_list('main')) do if stack:get_name()==item then n=n+stack:get_count() end end;return n
end
local function actor(kind)
 local at=api.finale.positions[kind]
 for _,obj in ipairs(core.get_objects_inside_radius(at,0.4)) do local e=obj:get_luaentity();if e and e.name=='harrows_trail:finale_actor' and e.kind==kind then return e end end
 error('missing finale actor '..kind)
end
local function exercise()
 assert(api.late_mode() and api.storage:get_string('world_layout_version')=='7')
 api.chapter.ensure();api.chapter.ensure_more();api.finale.ensure();api.finale.ensure_actors()
 local old_show=core.show_formspec;core.show_formspec=function()end
 local p,s,inv=player('late_main');s.act=5;s.honor=53;s.flags.arrived=true;s.flags.jesse_briefed=true;s.flags.choice='evidence'
 for i=2,5 do s.unlocked[tostring(i)]=true end;for i=1,3 do s.map_fragments[tostring(i)]=true end
 local positions=api.chapter.positions
 local function at(kind) p.pos=positions[kind];api.interact(kind,p.pos,p) end
 local function submit(fields) api.chapter.receive(p,'harrows_trail:story',fields) end
 local function final_at(kind) p.pos=api.finale.positions[kind];api.finale.interact(kind,p,s) end
 local function final_submit(fields) api.finale.receive(p,'harrows_trail:finale',fields) end
 at('rubble1');at('rubble2');assert(s.flags.rubble2)
 p.pos=positions.assay;local label=api.late_target(p,s);assert(label=='Railway trail to the depot' and s.flags.late_route=='station' and s.flags.late_route_step>1)
 assert(not api.world_travel.travel('late_main','station'))
 inv:add_item('main','mcl_tnt:tnt')
 local pad=api.world_lategame.pads.left
 core.set_node(pad,{name='mcl_core:obsidian'});at('station');submit({left=true});assert(not s.unlocked['6'] and count(inv,'mcl_tnt:tnt')==1)
 core.set_node(pad,{name='air'});core.get_meta(pad):set_string('harrows_site_owner','player:test')
 at('station');submit({left=true});assert(not s.unlocked['6'] and count(inv,'mcl_tnt:tnt')==1);core.get_meta(pad):set_string('harrows_site_owner','')
 at('station');submit({left=true});assert(s.unlocked['6'] and count(inv,'mcl_tnt:tnt')==0 and core.get_node(pad).name=='harrows_trail:story_charge')
 local right=api.world_lategame.pads.right;core.set_node(right,{name='mcl_core:obsidian'})
 at('station');submit({right=true});assert(s.flags.charge_side=='left' and core.get_node(pad).name=='harrows_trail:story_charge')
 core.set_node(right,{name='air'});at('station');submit({right=true});assert(s.flags.charge_side=='right' and core.get_node(pad).name=='air')
 local barrier={x=-298,y=18,z=-222};local old_protect=core.is_protected
 core.is_protected=function(pos,name) return vector.equals(pos,barrier) or old_protect(pos,name) end
 at('charge');submit({trigger=true});assert(not s.flags.station_breached and core.get_node(right).name=='harrows_trail:story_charge');core.is_protected=old_protect
 core.set_node(barrier,{name='mcl_core:obsidian'});at('charge');submit({trigger=true})
 assert(s.flags.station_breached and core.get_node(barrier).name=='mcl_core:obsidian' and core.get_node(right).name=='air')
 assert(core.get_node({x=-297,y=18,z=-222}).name=='mcl_minecarts:rail' and count(inv,'mcl_tnt:tnt')==0)
 core.set_node(barrier,{name='air'})
 at('mine_gate');submit({start7=true});assert(not s.unlocked['7'])
 local map=ItemStack('mcl_maps:filled_map');local meta=map:get_meta();meta:set_string('mcl_maps:id','badlands')
 meta:set_string('mcl_maps:minp','(520, 0, 800)');meta:set_string('mcl_maps:maxp','(600, 0, 880)');inv:add_item('main',map)
 at('mine_gate');submit({start7=true});assert(s.unlocked['7'] and count(inv,'mcl_maps:filled_map')==1)
 at('mine_clue');at('ledger1');at('ledger1');assert(s.flags.ledger1 and count(inv,'harrows_trail:ledger_1')==1)
 at('ferry');submit({start8=true});assert(not s.unlocked['8'])
 inv:add_item('main','mcl_boats:boat_spruce');at('ferry');submit({start8=true});assert(s.unlocked['8'] and count(inv,'mcl_boats:boat_spruce')==1)
 at('ferry');submit({pay=true});assert(not s.flags.ferry_crossed)
 local snag=positions.snag;core.is_protected=function(pos,name)return vector.equals(pos,snag) or old_protect(pos,name)end
 at('snag');assert(not s.flags.ferry_crossed);core.is_protected=old_protect
 at('snag');assert(s.flags.ferry_crossed and s.flags.ferry_method=='snag' and core.get_node(snag).name=='air')
 at('ledger2');assert(not s.flags.ledger2);at('hideout');at('ledger2');at('ledger2');assert(s.flags.ledger2 and count(inv,'harrows_trail:ledger_2')==1)
 for _,branch in ipairs({'pay','waiver'}) do
  local q,t,bag=player('ferry_'..branch);t.flags.arrived=true;t.flags.ledger1=true;t.unlocked['8']=true;t.honor=50;q.pos=positions.ferry
  if branch=='pay' then bag:add_item('main','mcl_core:gold_ingot 3') else api.interact('ferry',q.pos,q);api.chapter.receive(q,'harrows_trail:story',{waiver=true});assert(not t.flags.ferry_crossed);t.honor=53 end
  api.interact('ferry',q.pos,q);api.chapter.receive(q,'harrows_trail:story',{[branch]=true});assert(t.flags.ferry_crossed and t.flags.ferry_method==branch and count(bag,'mcl_core:gold_ingot')==0)
 end
 final_at('gate');final_submit({start=true});assert(not s.unlocked['9'])
 inv:add_item('main','mcl_core:apple_gold 4')
 inv:add_item('main',mcl_armor.colorize_leather_armor(ItemStack('mcl_armor:chestplate_leather'),mcl_dyes.colors.brown.rgb))
 local bow=ItemStack('mcl_bows:crossbow_loaded');bow:get_meta():set_string('arrow','mcl_bows:arrow');inv:add_item('main',bow)
 final_at('gate');final_submit({start=true});assert(s.unlocked['9'] and count(inv,'mcl_core:apple_gold')==0)
 final_at('gate');final_submit({start=true});assert(count(inv,'mcl_armor:chestplate_leather')==1 and count(inv,'mcl_bows:crossbow_loaded')==1)
 final_at('mercer');final_submit({cover=true});final_at('mercer');final_submit({spare=true})
 final_at('nora');final_submit({promise=true});assert(s.flags.nora_freed)
 final_at('crane');final_submit({kill_crane=true});assert(not s.flags.crane_outcome)
 final_at('crane');final_submit({disarm=true});actor('crane'):on_punch(p);actor('crane'):on_punch(p);assert(s.flags.crane_surrender and p.hits>0)
 final_at('crane');final_submit({capture=true});assert(s.flags.crane_outcome=='captured' and s.nora_trust==60 and not s.flags.gold_found)
 api.late_target(p,s);assert(s.flags.late_route=='returning')
 p.pos=api.world_buildings.positions.ada;local _,destination=api.late_target(p,s);assert(destination==api.world_buildings.positions.ada and s.flags.late_route_step>1)
 api.interact('ada',p.pos,p);local honor=s.honor;final_submit({justice=true})
 assert(s.verdict=='justice' and s.act==10 and s.honor==honor+5)
 api.interact('ada',p.pos,p);final_submit({scene=true});assert(s.honor==honor+5)
 api.save('late_main')
 for _,branch in ipairs({'mercy','vengeance'}) do
  local q,t=player('late_'..branch);t.honor=branch=='mercy' and 60 or 20;t.flags.ledger1=true;t.flags.ledger2=true;t.unlocked['9']=true
  local function talk(kind,fields)q.pos=api.finale.positions[kind];api.finale.interact(kind,q,t);api.finale.receive(q,'harrows_trail:finale',fields)end
  if branch=='mercy' then talk('mercer',{cover=true});talk('mercer',{spare=true}) else talk('mercer',{duel=true});actor('mercer'):on_punch(q);actor('mercer'):on_punch(q);actor('mercer'):on_punch(q);assert(t.flags.mercer_outcome=='killed') end
  talk('nora',branch=='mercy' and {promise=true} or {free=true});talk('crane',{disarm=true});actor('crane'):on_punch(q);actor('crane'):on_punch(q)
  talk('crane',branch=='mercy' and {release=true} or {kill_crane=true})
  q.pos=api.world_buildings.positions.ada;api.interact('ada',q.pos,q);api.finale.receive(q,'harrows_trail:finale',{[branch]=true})
  assert(t.verdict==branch and t.unlocked['10'] and (branch~='vengeance' or t.flags.crane_outcome=='killed' and t.wanted==1))
  api.save(q:get_player_name())
 end
 core.show_formspec=old_show
 core.emerge_area({x=65,y=220,z=-7},{x=312,y=225,z=7},function(_,a,left)
  assert(a~=core.EMERGE_ERRORED and a~=core.EMERGE_CANCELLED);if left~=0 then return end
  for _,x in ipairs({70,185,230,280,308}) do assert(core.get_node({x=x,y=220,z=0}).name=='air','new world created an elevated story floor') end
  finish()
 end)
end
local jobs={'ranch','red_mesa','dust_flats','dry_gulch','iron_pass','silver_spur','ghost_mine','gulch_bridge','foothill_bridge','pass_bridge','station','bitter_river','widowmaker'}
local function place(i)
 local id=jobs[i];if not id then return exercise() end
 api.ensure_grounded_site(id);wait_for(function()return api.world_sites.placed(id)end,function()place(i+1)end)
end
core.after(0,function()place(1)end)
