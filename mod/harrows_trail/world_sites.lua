-- Safe placement primitives; the legacy elevated sites remain active until migration is complete.
return function(storage)
 local registry={
  ranch={center={x=654,z=652},radius=64,half_x=18,half_z=16,height=4,biome_prefix='Savanna',base_y=19},
  red_mesa={center={x=623,z=788},radius=64,half_x=19,half_z=2,height=8,biome_prefix='Mesa',base_y=21},
  dust_flats={center={x=642,z=1024},radius=80,half_x=26,half_z=16,height=5,biome_prefix='Desert',base_y=11},
  dry_gulch={center={x=523,z=1212},radius=64,half_x=15,half_z=9,height=9,biome_prefix='Plains',base_y=8},
  ghost_mine={center={x=560,z=844},radius=64,half_x=2,half_z=14,height=5,biome_prefix='Mesa',base_y=21},
  iron_pass={center={x=-480,z=-516},radius=64,half_x=8,half_z=4,height=10,biome_prefix='ExtremeHills+_snowtop',base_y=53,allow_mountain_ground=true,allow_natural_snow=true},
  silver_spur={center={x=-463,z=-557},radius=64,half_x=5,half_z=11,height=8,biome_prefix='ExtremeHills+',base_y=11},
  gulch_bridge={center={x=504,z=689},radius=64,half_x=2,half_z=13,height=4,biome_prefix='Desert',base_y=15,
   bridge_anchors={{x=504,y=14,z=677},{x=504,y=14,z=701}}},
  foothill_bridge={center={x=-308,z=-399},radius=64,half_x=9,half_z=2,height=4,biome_prefix='Mesa',base_y=11,
   bridge_anchors={{x=-317,y=10,z=-399},{x=-299,y=10,z=-399}}},
  pass_bridge={center={x=-422,z=-481},radius=64,half_x=2,half_z=2,height=4,biome_prefix='ExtremeHills',base_y=6,
   bridge_anchors={{x=-424,y=5,z=-481},{x=-420,y=5,z=-481}}},
  station={center={x=-300,z=-213},radius=64,half_x=9,half_z=12,height=10,biome_prefix='Plains',base_y=19,allow_terrain_edit=true,
   terrain_nodes={['mcl_core:dirt_with_grass']=true,['mcl_core:dirt']=true,['mcl_core:coarse_dirt']=true,['mcl_flowers:tallgrass']=true}},
  bitter_river={center={x=300,z=1500},radius=64,half_x=9,half_z=9,height=10,biome_prefix='Swampland',base_y=21,allow_terrain_edit=true,
   terrain_nodes={['mcl_core:dirt_with_grass']=true,['mcl_core:dirt']=true,['mcl_core:coarse_dirt']=true,['mcl_flowers:tallgrass']=true,['mcl_core:water_source']=true}},
  widowmaker={center={x=499,z=1605},radius=64,half_x=4,half_z=11,height=12,biome_prefix='Forest',base_y=32,allow_mountain_ground=true,allow_terrain_edit=true,
   terrain_nodes={['mcl_core:stone']=true,['mcl_core:dirt_with_grass']=true,['mcl_core:dirt']=true,['mcl_core:coarse_dirt']=true,['mcl_flowers:tallgrass']=true}},
 }
 local natural_ground={['mcl_core:dirt_with_grass']=true,['mcl_core:dirt']=true,['mcl_core:sand']=true,['mcl_core:redsand']=true,['mcl_colorblocks:hardened_clay']=true,['mcl_colorblocks:hardened_clay_orange']=true}
 for color in pairs(mcl_dyes.colors) do natural_ground['mcl_colorblocks:hardened_clay_'..color]=true end
 natural_ground['mcl_core:coarse_dirt']=true
 local widow=registry.widowmaker
 widow.extra_ground_nodes={['mcl_core:stone']=true,['mcl_core:stone_with_coal']=true,['mcl_core:stone_with_iron']=true,['mcl_copper:stone_with_copper']=true,['mcl_core:andesite']=true,['mcl_core:diorite']=true}
 for name in pairs(widow.extra_ground_nodes) do widow.terrain_nodes[name]=true end
 for i=1,4 do widow.terrain_nodes['mcl_flowers:leaf_litter_'..i]=true end
 widow.bridge_anchors={{x=495,y=30,z=1600},{x=503,y=30,z=1600},{x=495,y=30,z=1616},{x=503,y=30,z=1616}}
 local function is_natural_ground(site,name)
  return natural_ground[name] or site.allow_mountain_ground and (name=='mcl_core:stone' or name=='mcl_core:dirt_with_grass_snow') or type(site.extra_ground_nodes)=='table' and site.extra_ground_nodes[name]==true
 end
 local function key(id) return 'world_site_v1:'..id end
 local function placed(id) return storage:get_string(key(id))=='1' end
 local function touched(id) return storage:get_string('world_site_touched_v1:'..id)=='1' end
 local function mark_touched(pos)
  for id,site in pairs(registry) do
   local c=site.center; local y=site.base_y
   if y and not placed(id) and pos.x>=c.x-site.half_x-4 and pos.x<=c.x+site.half_x+4 and
    pos.z>=c.z-site.half_z-4 and pos.z<=c.z+site.half_z+4 and pos.y>=y-16 and pos.y<=y+site.height+15 then
    storage:set_string('world_site_touched_v1:'..id,'1')
   end
  end
 end
 local function preflight(site,y,layout,zones)
  if type(site)~='table' or type(y)~='number' or type(layout)~='table' or #layout==0 then return false,'invalid site or layout' end
  local targets={}
  for _,entry in ipairs(layout) do
   local p=entry.pos
   if type(p)~='table' or type(entry.name)~='string' or not core.registered_nodes[entry.name] then return false,'invalid layout node' end
   local k=core.pos_to_string(p); if targets[k] then return false,'duplicate layout node' end; targets[k]=entry
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
  if site.bridge_anchors then
   if #site.bridge_anchors<2 then return false,'bridge needs checked anchors' end
   for _,pos in ipairs(site.bridge_anchors) do
    local node=core.get_node_or_nil(pos)
    if not node or not is_natural_ground(site,node.name) or core.get_item_group(node.name,'solid')==0 then return false,'bridge anchor is not natural ground: '..core.pos_to_string(pos)..' '..(node and node.name or 'nil') end
    local meta=core.get_meta(pos):to_table()
    if core.is_protected(pos,'') or core.get_node_timer(pos):is_started() or next(meta.fields or {}) or next(meta.inventory or {}) then return false,'bridge anchor is occupied or protected' end
   end
  end
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
    local span=zone.bridge_span==true and site.bridge_anchors and #site.bridge_anchors>=2
    if not span and (not ground or not is_natural_ground(site,ground.name) or core.get_item_group(ground.name,'solid')==0) then return false,'missing, uneven, or non-natural ground: '..core.pos_to_string({x=x,y=a.y-1,z=z})..' '..(ground and ground.name or 'nil') end
    for yy=a.y,b.y do
     local pos={x=x,y=yy,z=z}; local node=core.get_node_or_nil(pos)
     local target=targets[core.pos_to_string(pos)]
     local allowed_snow=node and node.name=='mcl_core:snow' and yy==a.y and site.allow_natural_snow and (not target or target.replace_natural_snow==true)
     local allowed_terrain=node and target and target.terrain_edit==true and site.allow_terrain_edit==true and type(site.terrain_nodes)=='table' and site.terrain_nodes[node.name]==true
     if not node or (node.name~='air' and not allowed_snow and not allowed_terrain and (node.name~='mcl_flowers:tallgrass' or target)) then return false,'occupied or unloaded: '..core.pos_to_string(pos)..' '..(node and node.name or 'nil') end
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
  if touched(id) then return false,'site area was modified by a player' end
  local ok,reason=preflight(site,y,layout,zones)
  if not ok then return false,reason end
  for _,entry in ipairs(layout) do
   core.set_node(entry.pos,{name=entry.name,param2=entry.param2 or 0})
   if entry.owner then core.get_meta(entry.pos):set_string('harrows_site_owner',entry.owner) end
   if entry.mirrored then core.get_meta(entry.pos):set_int('is_mirrored',1) end
  end
  for _,entry in ipairs(layout) do
   if entry.text then
    core.get_meta(entry.pos):set_string('utext',core.serialize(mcl_signs.string_to_ustring(entry.text)))
    mcl_signs.update_sign(entry.pos)
   end
  end
  storage:set_string(key(id),'1')
  return true,'placed'
 end
 return {registry=registry,preflight=preflight,place=place,placed=placed,touched=touched,mark_touched=mark_touched}
end
