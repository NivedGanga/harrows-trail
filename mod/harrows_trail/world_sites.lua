-- Safe placement primitives; the legacy elevated sites remain active until migration is complete.
return function(storage)
 local registry={
  ranch={center={x=513,z=647},radius=64,half_x=25,half_z=17,height=4,biome_prefix='Savanna'},
  red_mesa={center={x=623,z=788},radius=64,half_x=11,half_z=2,height=4,biome_prefix='Mesa'},
 }
 local natural_ground={['mcl_core:dirt_with_grass']=true,['mcl_core:dirt']=true,['mcl_core:sand']=true,['mcl_core:redsand']=true,['mcl_colorblocks:hardened_clay']=true,['mcl_colorblocks:hardened_clay_orange']=true}
 for color in pairs(mcl_dyes.colors) do natural_ground['mcl_colorblocks:hardened_clay_'..color]=true end
 natural_ground['mcl_core:coarse_dirt']=true
 local function key(id) return 'world_site_v1:'..id end
 local function placed(id) return storage:get_string(key(id))=='1' end
 local function preflight(site,y,layout,zones)
  if type(site)~='table' or type(y)~='number' or type(layout)~='table' or #layout==0 then return false,'invalid site or layout' end
  local targets={}
  for _,entry in ipairs(layout) do
   local p=entry.pos
   if type(p)~='table' or type(entry.name)~='string' or not core.registered_nodes[entry.name] then return false,'invalid layout node' end
   local k=core.pos_to_string(p); if targets[k] then return false,'duplicate layout node' end; targets[k]=true
  end
  local center={x=site.center.x,y=y,z=site.center.z}
  local biome=mcl_biome_dispatch.get_biome_name(center)
  if type(biome)~='string' or biome:sub(1,#site.biome_prefix)~=site.biome_prefix then return false,'unsuitable biome: '..tostring(biome) end
  local pad=32
  local min={x=center.x-site.half_x-pad,y=y-32,z=center.z-site.half_z-pad}
  local max={x=center.x+site.half_x+pad,y=y+site.height+32,z=center.z+site.half_z+pad}
  for x=math.floor(min.x/16)*16, max.x,16 do
   for yy=math.floor(min.y/16)*16, max.y,16 do
    for z=math.floor(min.z/16)*16, max.z,16 do
     local node=core.get_node_or_nil({x=x,y=yy,z=z})
     if not node or node.name=='ignore' then return false,'village survey area not loaded' end
    end
   end
  end
  if #mcl_villages.get_pois_in_by_nodepos(min,max)>0 then return false,'village point of interest nearby' end
  zones=zones or {{min={x=center.x-site.half_x,y=y,z=center.z-site.half_z},max={x=center.x+site.half_x,y=y+site.height-1,z=center.z+site.half_z}}}
  if type(zones)~='table' or #zones==0 then return false,'invalid zones' end
  for _,zone in ipairs(zones) do
   local a,b=zone.min,zone.max
   if not a or not b or a.x<center.x-site.half_x or b.x>center.x+site.half_x or a.z<center.z-site.half_z or b.z>center.z+site.half_z or
    a.x>b.x or a.z>b.z or a.y>b.y or a.y<y-16 or b.y>y+site.height+15 then return false,'invalid zone' end
   local area_min={x=a.x-0.5,y=a.y-0.5,z=a.z-0.5}
   local area_max={x=b.x+0.5,y=b.y+0.5,z=b.z+0.5}
   if #core.get_objects_in_area(area_min,area_max)>0 then return false,'object in site' end
   for x=a.x,b.x do for z=a.z,b.z do
    local ground=core.get_node_or_nil({x=x,y=a.y-1,z=z})
    if not ground or not natural_ground[ground.name] or core.get_item_group(ground.name,'solid')==0 then return false,'missing, uneven, or non-natural ground' end
    for yy=a.y,b.y do
     local pos={x=x,y=yy,z=z}; local node=core.get_node_or_nil(pos)
     if not node or (node.name~='air' and (node.name~='mcl_flowers:tallgrass' or targets[core.pos_to_string(pos)])) then return false,'occupied or unloaded: '..core.pos_to_string(pos) end
     if core.is_protected(pos,'') then return false,'protected: '..core.pos_to_string(pos) end
     local meta=core.get_meta(pos):to_table()
     if meta and (next(meta.fields or {}) or next(meta.inventory or {})) then return false,'metadata present: '..core.pos_to_string(pos) end
     if core.get_node_timer(pos):is_started() then return false,'node timer present: '..core.pos_to_string(pos) end
    end
   end end
  end
  for _,entry in ipairs(layout) do
   local p=entry.pos
   local within=false
   for _,zone in ipairs(zones) do
    local a,b=zone.min,zone.max
    if p.x>=a.x and p.x<=b.x and p.y>=a.y and p.y<=b.y and p.z>=a.z and p.z<=b.z then within=true; break end
   end
   if not within then return false,'layout node outside checked zones' end
  end
  return true
 end
 local function place(id,y,layout,zones)
  local site=registry[id]
  if not site then return false,'unknown site' end
  if placed(id) then return true,'already placed' end
  local ok,reason=preflight(site,y,layout,zones)
  if not ok then return false,reason end
  for _,entry in ipairs(layout) do core.set_node(entry.pos,{name=entry.name}) end
  storage:set_string(key(id),'1')
  return true,'placed'
 end
 return {registry=registry,preflight=preflight,place=place,placed=placed}
end
