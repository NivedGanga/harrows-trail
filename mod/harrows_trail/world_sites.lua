-- Safe placement primitives; the legacy elevated sites remain active until migration is complete.
return function(storage)
 local registry={
  ranch={center={x=0,z=0},radius=48,half_x=12,half_z=9,height=7,biome_prefix='Savanna'},
  red_mesa={center={x=55,z=0},radius=48,half_x=9,half_z=8,height=8,biome_prefix='Mesa'},
 }
 local function key(id) return 'world_site_v1:'..id end
 local function placed(id) return storage:get_string(key(id))=='1' end
 local function preflight(site,y,layout)
  if type(site)~='table' or type(y)~='number' or type(layout)~='table' or #layout==0 then return false,'invalid site or layout' end
  local center={x=site.center.x,y=y,z=site.center.z}
  local biome=mcl_biome_dispatch.get_biome_name(center)
  if type(biome)~='string' or biome:sub(1,#site.biome_prefix)~=site.biome_prefix then return false,'unsuitable biome: '..tostring(biome) end
  local pad=32
  local min={x=center.x-site.half_x-pad,y=y-32,z=center.z-site.half_z-pad}
  local max={x=center.x+site.half_x+pad,y=y+site.height+32,z=center.z+site.half_z+pad}
  if #mcl_villages.get_pois_in_by_nodepos(min,max)>0 then return false,'village point of interest nearby' end
  local area_min={x=center.x-site.half_x-0.5,y=y-0.5,z=center.z-site.half_z-0.5}
  local area_max={x=center.x+site.half_x+0.5,y=y+site.height-0.5,z=center.z+site.half_z+0.5}
  if #core.get_objects_in_area(area_min,area_max)>0 then return false,'object in site' end
  for x=center.x-site.half_x,center.x+site.half_x do
   for z=center.z-site.half_z,center.z+site.half_z do
    local ground=core.get_node_or_nil({x=x,y=y-1,z=z})
    if not ground or core.get_item_group(ground.name,'solid')==0 then return false,'missing or uneven ground' end
    for yy=y,y+site.height-1 do
     local pos={x=x,y=yy,z=z}; local node=core.get_node_or_nil(pos)
     if not node or node.name~='air' then return false,'occupied or unloaded: '..core.pos_to_string(pos) end
     if core.is_protected(pos,'') then return false,'protected: '..core.pos_to_string(pos) end
     local meta=core.get_meta(pos):to_table()
     if meta and (next(meta.fields or {}) or next(meta.inventory or {})) then return false,'metadata present: '..core.pos_to_string(pos) end
     if core.get_node_timer(pos):is_started() then return false,'node timer present: '..core.pos_to_string(pos) end
    end
   end
  end
  local seen={}
  for _,entry in ipairs(layout) do
   local p=entry.pos
   if type(p)~='table' or type(entry.name)~='string' or not core.registered_nodes[entry.name] or
    p.x<center.x-site.half_x or p.x>center.x+site.half_x or p.z<center.z-site.half_z or p.z>center.z+site.half_z or p.y<y or p.y>=y+site.height then return false,'invalid layout node' end
   local k=core.pos_to_string(p); if seen[k] then return false,'duplicate layout node' end; seen[k]=true
  end
  return true
 end
 local function place(id,y,layout)
  local site=registry[id]
  if not site then return false,'unknown site' end
  if placed(id) then return true,'already placed' end
  local ok,reason=preflight(site,y,layout)
  if not ok then return false,reason end
  for _,entry in ipairs(layout) do core.set_node(entry.pos,{name=entry.name}) end
  storage:set_string(key(id),'1')
  return true,'placed'
 end
 return {registry=registry,preflight=preflight,place=place,placed=placed}
end
