local api=assert(harrows_trail_test)
local phase=assert(core.settings:get('harrows_sprint7_phase'))
local jobs={'station','bitter_river','widowmaker'}
local function finish()
 core.log('action','[sprint7_test] PASS '..phase);core.request_shutdown('Sprint 7 test complete',false,0)
end
local function outside(site)
 local out={};local c=site.center;local hx,hz=site.half_x+1,site.half_z+1
 for x=c.x-hx,c.x+hx do for z=c.z-hz,c.z+hz do
  if x==c.x-hx or x==c.x+hx or z==c.z-hz or z==c.z+hz then
   for y=site.base_y-4,site.base_y+site.height+4 do
    local p={x=x,y=y,z=z};local n=core.get_node(p);out[#out+1]={pos=p,name=n.name,param2=n.param2}
   end
  end
 end end
 return out
end
local function verify_outside(entries)
 for _,e in ipairs(entries) do local n=core.get_node(e.pos);assert(n.name==e.name and n.param2==e.param2,'outside footprint changed: '..core.pos_to_string(e.pos)) end
end
local function run(i)
 local id=jobs[i];if not id then return finish() end
 local site=api.world_sites.registry[id];local p,y=site.center,site.base_y
 core.emerge_area({x=p.x-site.half_x-48,y=y-48,z=p.z-site.half_z-48},{x=p.x+site.half_x+48,y=y+site.height+48,z=p.z+site.half_z+48},function(_,action,left)
  assert(action~=core.EMERGE_ERRORED and action~=core.EMERGE_CANCELLED);if left~=0 then return end
  local layout,zones=api.world_lategame.layout(id)
  if phase=='blocked' then
   local target=layout[1].pos;core.set_node(target,{name='mcl_core:obsidian'})
   local ok=api.world_sites.place(id,y,layout,zones)
   assert(not ok and not api.world_sites.placed(id) and core.get_node(target).name=='mcl_core:obsidian')
  elseif phase=='modified' or phase=='modified_read' then
   if phase=='modified' then api.world_sites.mark_touched({x=p.x,y=y,z=p.z}) else assert(api.world_sites.touched(id)) end
   local ok,why=api.world_sites.place(id,y,layout,zones);assert(not ok and why:find('modified',1,true))
  else
   local boundary=phase=='read' and assert(core.parse_json(api.storage:get_string('test_outside:'..id))) or outside(site)
   local ok,why=api.world_sites.place(id,y,layout,zones);assert(ok,id..': '..why)
   for _,e in ipairs(layout) do
    local n=core.get_node(e.pos);local def=core.registered_nodes[n.name]
    assert(n.name==e.name or def and def._mcl_walls_name_root==e.name,core.pos_to_string(e.pos)..' '..n.name..' expected '..e.name)
    if e.owner then assert(core.get_meta(e.pos):get_string('harrows_site_owner')==e.owner) end
   end
   verify_outside(boundary)
   if phase=='write' then api.storage:set_string('test_outside:'..id,core.write_json(boundary)) end
   ok,why=api.world_sites.place(id,y,layout,zones);assert(ok and why=='already placed')
   if id=='bitter_river' then
    local cast={{pos={x=294,y=21,z=1500},half=2,actor='ferry'}}
    api.world_midgame_nodes.ensure_actors(cast);api.world_midgame_nodes.ensure_actors(cast)
    local found=0;for _,obj in ipairs(core.get_objects_inside_radius({x=294,y=21,z=1500},0.4)) do local e=obj:get_luaentity();if e and e.name=='harrows_trail:mid_actor' and e.kind=='ferry' then found=found+1 end end
    assert(found==1,'Amos actor recovery failed or duplicated')
   end
  end
  run(i+1)
 end)
end
core.after(0,function()run(1)end)
