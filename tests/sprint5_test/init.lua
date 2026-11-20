local api=assert(harrows_trail_test)
local phase=assert(core.settings:get('harrows_sprint5_phase'))
local jobs={{id='ranch',y=16},{id='red_mesa',y=21}}
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
core.after(0,function() run(1) end)
