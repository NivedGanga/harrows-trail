local api=assert(harrows_trail_test)
local phase=assert(core.settings:get('harrows_sprint5_phase'))
local jobs={{id='ranch',y=19},{id='red_mesa',y=21}}
local function finish()
 core.log('action','[sprint5_test] PASS '..phase)
 core.request_shutdown('Sprint 5 test complete',false,0)
end
local function run(i)
 local job=jobs[i]; if not job then return finish() end
 local site=api.world_sites.registry[job.id]; local p=site.center
 core.emerge_area({x=p.x-site.half_x-48,y=job.y-48,z=p.z-site.half_z-48},
  {x=p.x+site.half_x+48,y=job.y+site.height+48,z=p.z+site.half_z+48},function(_,action,left)
  assert(action~=core.EMERGE_ERRORED and action~=core.EMERGE_CANCELLED)
  if left~=0 then return end
  local layout,zones=api.world_buildings.layout(job.id)
  assert(#layout>0 and #zones>0)
  if phase=='blocked' then
   local target=layout[1].pos
   assert(core.get_node(target).name=='air')
   core.set_node(target,{name='mcl_core:obsidian'})
   local ok=api.world_sites.place(job.id,job.y,layout,zones)
   assert(not ok and not api.world_sites.placed(job.id))
   assert(core.get_node(target).name=='mcl_core:obsidian')
  else
   if phase=='write' then assert(not api.world_sites.placed(job.id)) end
   local ok,reason=api.world_sites.place(job.id,job.y,layout,zones)
   assert(ok,reason)
   assert(api.world_sites.placed(job.id))
   for _,e in ipairs(layout) do assert(core.get_node(e.pos).name==e.name,core.pos_to_string(e.pos)) end
   ok,reason=api.world_sites.place(job.id,job.y,layout,zones)
   assert(ok and reason=='already placed')
  end
  run(i+1)
 end)
end
local function test_opening()
 local pos=api.world_buildings.positions
 local inv=core.create_detached_inventory('opening_test',{}); inv:set_size('main',36)
 local p={pos=pos.barn}
 function p:get_player_name() return 'opening_test' end
 function p:get_inventory() return inv end
 function p:get_pos() return self.pos end
 function p:get_wielded_item() return ItemStack('') end
 function p:get_attach() return self.parent end
 function p:set_pos(pos) self.pos=pos end
 local s=api.load('opening_test'); api.states.opening_test=s
 local old=core.show_formspec; core.show_formspec=function(name,form,text) if name~='opening_test' then old(name,form,text) end end
 local function wall(kind,at)
  p.pos=at; local def=assert(core.registered_nodes['harrows_trail:grounded_'..kind]); def.on_rightclick(at,{},p)
 end
 local function actor(kind,at)
  p.pos=at
  for _,obj in ipairs(core.get_objects_inside_radius(at,0.4)) do
   local ent=obj:get_luaentity()
   if ent and ent.name=='harrows_trail:opening_actor' and ent.kind==kind then ent:on_rightclick(p); return end
  end
  error('opening actor missing: '..kind)
 end
 wall('barn',pos.barn); assert(s.map_fragments['1'] and inv:contains_item('main','harrows_trail:fragment_1'))
 wall('tack',pos.tack); assert(s.flags.saddle_found and inv:contains_item('main',api.starter.item))
 wall('corral',pos.corral); assert(s.flags.corral_visited)
 local found_horse=false
 for _,obj in ipairs(core.get_objects_inside_radius({x=654,y=20,z=652},4)) do local e=obj:get_luaentity(); if e and e.name=='mobs_mc:horse' then found_horse=true end end
 assert(found_horse,'native horse was not spawned at the corral')
 wall('delivery',pos.delivery); assert(s.flags.parcel)
 wall('depot',pos.depot); assert(not s.flags.parcel and inv:contains_item('main','mcl_core:gold_ingot 3'))
 local saddle
 for _,stack in ipairs(inv:get_list('main')) do if stack:get_name()==api.starter.item then saddle=stack:to_string() end end
 assert(saddle); local horse={name='mobs_mc:horse',tamed=true,owner='opening_test',driver=p,_saddle=saddle}
 p.parent={get_luaentity=function() return horse end}
 for i=1,#api.world_buildings.route-1 do
  p.pos=api.world_buildings.route[i]; assert(api.advance_ranch_route(p,s)==api.world_buildings.route[i+1])
 end
 p.pos=pos.route; api.interact('route',pos.route,p)
 assert(s.unlocked['2'] and inv:contains_item('main',api.starter.item))
 p.parent=nil; actor('ada',pos.ada); api.receive_fields(p,'harrows_trail:story',{evidence=true})
 assert(s.flags.choice=='evidence')
 local door={x=620,y=21,z=786}; local d=core.get_node(door)
 assert(d.name=='mcl_doors:door_dark_oak_b_1' and not mcl_doors.is_open(door))
 core.registered_nodes[d.name].on_rightclick(vector.new(door),d,p)
 assert(mcl_doors.is_open(door))
 d=core.get_node(door); core.registered_nodes[d.name].on_rightclick(vector.new(door),d,p)
 assert(not mcl_doors.is_open(door))
 assert(core.get_item_group(core.get_node({x=632,y=22,z=790}).name,'iron_bars')>0)
 assert(core.get_node({x=640,y=24,z=788}).name=='mcl_bells:bell')
 for _,sign in ipairs({{x=614,y=25,z=786},{x=620,y=25,z=786},{x=626,y=24,z=786},{x=632,y=24,z=786},{x=640,y=23,z=786}}) do
  assert(core.get_item_group(core.get_node(sign).name,'sign')>0)
  assert(core.get_meta(sign):get_string('utext')~='')
 end
 wall('cache',pos.cache); assert(inv:contains_item('main','mcl_core:gold_ingot 12'))
 actor('ada',pos.ada); api.chapter.receive(p,'harrows_trail:story',{bail=true}); assert(s.unlocked['3'])
 actor('jesse',pos.jesse); assert(s.flags.jesse_briefed and s.map_fragments['2'])
 local label,target=api.opening_target(p,s); assert(label=='Ruth: lanterns' and target==pos.ruth)
 actor('ruth',pos.ruth); api.chapter.receive(p,'harrows_trail:story',{lantern_buy=true})
 assert(inv:contains_item('main','mcl_lanterns:lantern_floor 4'))
 label,target=api.opening_target(p,s)
 if (tonumber(api.storage:get_string('world_layout_version')) or 0)>=6 then
  assert(label=='Dust Flats departure' and target==api.chapter.positions.dust)
  local old_get=core.get_player_by_name
  core.get_player_by_name=function(name) if name=='opening_test' then return p else return old_get(name) end end
  p.pos=pos.stagecoach; assert(not api.world_travel.travel('opening_test'))
  core.get_player_by_name=old_get
 else
 assert(label=='Stagecoach desk' and target==pos.stagecoach)
 assert(api.world_travel.clear(api.world_travel.mesa))
 local old_get=core.get_player_by_name; local old_emerge=core.emerge_area
 core.get_player_by_name=function(name) if name=='opening_test' then return p else return old_get(name) end end
 core.emerge_area=function(_,_,callback) callback(nil,core.EMERGE_FROM_MEMORY,0) end
 p.pos=pos.stagecoach
 assert(api.world_travel.travel('opening_test')); assert(vector.distance(p.pos,api.world_travel.dust)<0.01)
 assert(api.world_travel.travel('opening_test')); assert(vector.distance(p.pos,api.world_travel.mesa)<0.01)
 local mount={get_luaentity=function() return horse end,set_pos=function(_,target) p.pos=target end}
 p.parent=mount; p.pos=pos.stagecoach
 assert(api.world_travel.travel('opening_test')); assert(vector.distance(p.pos,api.world_travel.dust)<0.01)
 assert(api.world_travel.travel('opening_test')); assert(vector.distance(p.pos,api.world_travel.mesa)<0.01)
 p.parent=nil; p.pos=api.chapter.positions.dust
 local landing=api.world_travel.mesa; core.set_node(landing,{name='mcl_core:obsidian'})
 assert(api.world_travel.travel('opening_test')); assert(vector.distance(p.pos,api.chapter.positions.dust)<0.01)
 assert(core.get_node(landing).name=='mcl_core:obsidian'); core.set_node(landing,{name='air'})
 core.get_player_by_name=old_get; core.emerge_area=old_emerge
 end
 api.save('opening_test'); core.show_formspec=old
end
local function test_route()
 local route=api.world_buildings.route
 local allowed={['mcl_core:dirt_with_grass']=true,['mcl_core:dirt']=true,['mcl_core:coarse_dirt']=true,['mcl_core:sand']=true,['mcl_core:redsand']=true,['mcl_colorblocks:hardened_clay']=true}
 for color in pairs(mcl_dyes.colors) do allowed['mcl_colorblocks:hardened_clay_'..color]=true end
 local function height(x,z)
  for y=99,0,-1 do
   local n=core.get_node({x=x,y=y,z=z}); local d=core.registered_nodes[n.name]
   if d and ((d.liquidtype and d.liquidtype~='none') or d.walkable) then
    assert(allowed[n.name],'blocked route at '..x..','..z..': '..n.name); return y
   end
  end
  error('missing route ground at '..x..','..z)
 end
 local previous
 local function check(x,z)
  local h=height(x,z)
  if previous then assert(math.abs(h-previous)<=1,'route step too high') end; previous=h
  for xx=x-1,x+1 do for zz=z-1,z+1 do assert(math.abs(height(xx,zz)-h)<=1,'horse clearance too uneven') end end
 end
 check(route[1].x,route[1].z)
 for i=2,#route do
  local a,b=route[i-1],route[i]; local dx=b.x-a.x; local dz=b.z-a.z
  assert(dx==0 or dz==0,'route segment is not axis-aligned')
  local steps=math.abs(dx)+math.abs(dz); assert(steps>0)
  local sx=dx==0 and 0 or dx/math.abs(dx); local sz=dz==0 and 0 or dz/math.abs(dz)
  for j=1,steps do check(a.x+sx*j,a.z+sz*j) end
 end
end
local function test_ranch_paths()
 local allowed={['mcl_core:dirt_with_grass']=true,['mcl_core:dirt']=true,['mcl_core:coarse_dirt']=true,['mcl_core:sand']=true,['mcl_core:redsand']=true,['mcl_colorblocks:hardened_clay']=true}
 for color in pairs(mcl_dyes.colors) do allowed['mcl_colorblocks:hardened_clay_'..color]=true end
 local cache={}
 local function height(x,z)
  local key=x..','..z; if cache[key]~=nil then return cache[key] or nil end
  for y=80,0,-1 do
   local n=core.get_node({x=x,y=y,z=z});local d=core.registered_nodes[n.name]
   if d and ((d.liquidtype and d.liquidtype~='none') or d.walkable) then cache[key]=allowed[n.name] and y or false;return cache[key] or nil end
  end
  cache[key]=false
 end
 local function connected(start,goal)
  local queue,first={{start.x,start.z}},1;local seen={[start.x..','..start.z]=true}
  while first<=#queue do
   local current=queue[first];first=first+1;local x,z=current[1],current[2];if x==goal.x and z==goal.z then return true end
   for _,delta in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
    local nx,nz=x+delta[1],z+delta[2];local k=nx..','..nz
    if nx>=642 and nx<=682 and nz>=628 and nz<=664 and not seen[k] then
     local a,b=height(x,z),height(nx,nz)
     if a and b and math.abs(a-b)<=1 then seen[k]=true;queue[#queue+1]={nx,nz} end
    end
   end
  end
  return false
 end
 assert(core.get_node({x=670,y=18,z=648}).name=='air','tack room doorway is blocked')
 assert(connected({x=670,z=647},{x=661,z=638}),'no walking path from tack room to barn')
 assert(connected({x=670,z=647},{x=654,z=649}),'no walking path from tack room to corral')
end
local function integration()
 assert(api.grounded_mode); api.ensure_grounded_site('ranch')
 local function wait(attempt)
  assert(attempt<45,'grounded ranch did not initialize')
  if api.storage:get_string('site_ready')~='1' then return core.after(1,wait,attempt+1) end
  assert((tonumber(api.storage:get_string('world_layout_version')) or 0)>=6)
  local pos=api.world_buildings.positions; assert(api.site.barn.x==pos.barn.x and api.chapter.positions.ada.x==pos.ada.x)
  core.emerge_area({x=570,y=-27,z=738},{x=676,y=73,z=838},function(_,action,left)
   assert(action~=core.EMERGE_ERRORED and action~=core.EMERGE_CANCELLED)
   if left~=0 then return end
   api.world_opening.ensure_actors(api.world_buildings.sites.red_mesa)
   api.chapter.ensure()
   local function wait_chapter(attempt)
    assert(attempt<45,'temporary chapter site did not initialize')
    if api.storage:get_string('chapter_site')~='1' then return core.after(1,wait_chapter,attempt+1) end
    test_opening(); finish()
   end
   core.after(1,wait_chapter,0)
  end)
 end
 core.after(1,wait,0)
end
if phase=='bad_seed' then
 core.after(0,function()
  assert(core.get_mapgen_setting('seed')~='1730940739604968791')
  api.ensure_grounded_site('ranch')
  assert(not api.world_sites.placed('ranch') and api.storage:get_string('site_ready')=='')
  finish()
 end)
elseif phase=='dynamic' then
 core.after(0,function()
  assert(api.grounded_mode and not api.world_sites.placed('ranch')); api.ensure_grounded_site('ranch')
  local function wait_ranch(attempt)
   assert(attempt<45,'grounded ranch did not place')
   if api.storage:get_string('site_ready')~='1' then return core.after(1,wait_ranch,attempt+1) end
   local target=api.world_sites.registry.red_mesa.center
   local p={pos={x=target.x-100,y=21,z=target.z}}; function p:get_pos() return self.pos end
   api.update_grounded(p); assert(not api.world_sites.placed('red_mesa'))
   p.pos.x=target.x-63; api.update_grounded(p)
   local function wait_mesa(n)
    assert(n<45,'Red Mesa did not place on approach')
    if not api.world_sites.placed('red_mesa') then return core.after(1,wait_mesa,n+1) end
    assert(core.get_node({x=612,y=22,z=788}).name=='harrows_trail:grounded_office')
    core.emerge_area({x=600,y=0,z=628},{x=685,y=100,z=790},function(_,action,left)
     assert(action~=core.EMERGE_ERRORED and action~=core.EMERGE_CANCELLED)
     if left==0 then test_route(); test_ranch_paths(); finish() end
    end)
   end
   core.after(1,wait_mesa,0)
  end
  core.after(1,wait_ranch,0)
 end)
elseif phase=='legacy_write' then
 core.after(0,function()
  assert(not api.grounded_mode); api.ensure_site()
  local function wait(attempt)
   assert(attempt<45,'legacy site did not initialize')
   if api.storage:get_string('site_ready')~='1' then return core.after(1,wait,attempt+1) end
   local s=api.load('legacy_opening'); s.map_fragments['1']=true; s.flags.saddle_found=true
   api.states.legacy_opening=s; api.save('legacy_opening'); finish()
  end
  core.after(1,wait,0)
 end)
elseif phase=='legacy_read' then
 core.after(0,function()
  local s=api.load('legacy_opening')
  assert(not api.grounded_mode and api.site.barn.x==-8 and api.site.barn.y==221)
  assert(api.storage:get_string('world_layout_version')=='')
  assert(api.chapter.positions.dust.x==70 and api.chapter.positions.mine_gate.x==205)
  assert(s.map_fragments['1'] and s.flags.saddle_found and not api.world_sites.placed('ranch'))
  finish()
 end)
elseif phase=='legacy_grounded_write' then
 core.after(0,function()
  assert(api.grounded_mode and api.storage:get_string('site_ready')=='1')
  api.storage:set_string('world_layout_version','')
  local s=api.load('opening_test'); assert(s.flags.jesse_briefed and s.map_fragments['2'])
  finish()
 end)
elseif phase=='legacy_grounded_read' then
 core.after(0,function()
  assert(api.grounded_mode and api.storage:get_string('grounded_v1')=='1')
  assert(api.storage:get_string('world_layout_version')=='')
  assert(api.chapter.positions.dust.x==70 and api.chapter.positions.mine_gate.x==205 and not api.late_mode())
  local s=api.load('opening_test'); assert(s.flags.jesse_briefed and s.map_fragments['2'])
  api.ensure_grounded_site('ranch'); assert(api.storage:get_string('world_layout_version')=='')
  finish()
 end)
elseif phase=='integration' then core.after(0,integration)
elseif phase=='integration_read' then
 core.after(0,function()
  local s=api.load('opening_test'); local pos=api.world_buildings.positions
  assert(api.grounded_mode and api.storage:get_string('grounded_v1')=='1')
  assert((tonumber(api.storage:get_string('world_layout_version')) or 0)>=6)
  assert(s.unlocked['2'] and s.unlocked['3'] and s.flags.jesse_briefed and s.map_fragments['2'])
  assert(api.site.ada.x==pos.ada.x and api.chapter.positions.jesse.x==pos.jesse.x)
  finish()
 end)
else core.after(0,function() run(1) end) end
