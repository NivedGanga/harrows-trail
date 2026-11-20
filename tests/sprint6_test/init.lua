local api=assert(harrows_trail_test)
local phase=assert(core.settings:get('harrows_sprint6_phase'))
local jobs={'dust_flats','dry_gulch','ghost_mine','iron_pass','silver_spur','gulch_bridge'}
local function finish()
 core.log('action','[sprint6_test] PASS '..phase)
 core.request_shutdown('Sprint 6 test complete',false,0)
end
local function run(i)
 local id=jobs[i];if not id then return finish() end
 local site=api.world_sites.registry[id];local p,y=site.center,site.base_y
 core.emerge_area({x=p.x-site.half_x-48,y=y-48,z=p.z-site.half_z-48},
  {x=p.x+site.half_x+48,y=y+site.height+48,z=p.z+site.half_z+48},function(_,action,left)
  assert(action~=core.EMERGE_ERRORED and action~=core.EMERGE_CANCELLED);if left~=0 then return end
  local layout,zones=api.world_midgame.layout(id);assert(#layout>0 and #zones>0)
  if id=='gulch_bridge' and phase=='write' then
   local anchors=site.bridge_anchors
   site.bridge_anchors=nil; assert(not api.world_sites.preflight(site,y,layout,zones));site.bridge_anchors=anchors
   local at=anchors[1];core.get_meta(at):set_string('owner','test')
   assert(not api.world_sites.preflight(site,y,layout,zones));core.get_meta(at):set_string('owner','')
  end
  if phase=='blocked' then
   local target=layout[1].pos;assert(core.get_node(target).name=='air' or core.get_node(target).name=='mcl_core:snow')
   core.set_node(target,{name='mcl_core:obsidian'})
   local ok=api.world_sites.place(id,y,layout,zones)
   assert(not ok and not api.world_sites.placed(id) and core.get_node(target).name=='mcl_core:obsidian')
  elseif phase=='modified' or phase=='modified_read' then
   if phase=='modified' then api.world_sites.mark_touched({x=p.x,y=y,z=p.z}) else assert(api.world_sites.touched(id)) end
   local ok,reason=api.world_sites.place(id,y,layout,zones)
   assert(not ok and reason:find('modified',1,true) and not api.world_sites.placed(id))
  else
   local ok,reason=api.world_sites.place(id,y,layout,zones);assert(ok,reason)
   for _,e in ipairs(layout) do assert(core.get_node(e.pos).name==e.name,core.pos_to_string(e.pos)) end
   api.world_midgame_nodes.ensure_actors(api.world_midgame.sites[id])
   for _,b in ipairs(api.world_midgame.sites[id]) do if b.actor then
    local found=false
    for _,obj in ipairs(core.get_objects_inside_radius(b.pos,0.4)) do local e=obj:get_luaentity();if e and e.name=='harrows_trail:mid_actor' and e.kind==b.actor then found=true end end
    assert(found,'missing actor '..b.actor)
   end end
   ok,reason=api.world_sites.place(id,y,layout,zones);assert(ok and reason=='already placed')
  end
  run(i+1)
 end)
end
core.after(0,function()run(1)end)
