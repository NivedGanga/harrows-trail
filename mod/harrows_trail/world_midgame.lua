-- Construction data is checked against the terrain before any node is placed.
local sites={
 dust_flats={
  {name='dust',pos={x=642,y=11,z=1012},half=2,material='mcl_core:sandstone',open=true,actor='dust'},
  {name='exposed',pos={x=660,y=10,z=1024},half=2,material='mcl_core:sandstone',open=true,fixture='exposed'},
  {name='shelter1',pos={x=620,y=12,z=1010},half=2,material='mcl_core:sandstone',open=true,fixture='shelter1'},
  {name='shelter2',pos={x=618,y=10,z=1036},half=2,material='mcl_core:sandstone',open=true,fixture='shelter2'},
 },
 dry_gulch={
  {name='trading',pos={x=536,y=9,z=1212},half=2,material='mcl_trees:wood_spruce',actor='gulch'},
  {name='shop',pos={x=518,y=7,z=1210},half=1,material='mcl_trees:wood_spruce',actor='ruth_gulch'},
  {name='stable',pos={x=522,y=7,z=1218},half=2,material='mcl_trees:wood_spruce',open=true,actor='dutch'},
  {name='tower',pos={x=510,y=6,z=1206},half=2,material='mcl_trees:wood_spruce',open=true,tower=true},
 },
 ghost_mine={
  {name='entrance',pos={x=560,y=21,z=832},half=1,material='mcl_trees:wood_spruce',open=true,fixture='mine_gate'},
  {name='tracks',pos={x=560,y=21,z=840},half=1,material='mcl_trees:wood_spruce',open=true,fixture='mine_clue'},
  {name='office',pos={x=560,y=20,z=856},half=1,material='mcl_trees:wood_spruce',fixture='ledger1'},
 },
}
local positions={
 dust={x=642,y=11,z=1012},exposed={x=658,y=11,z=1024},
 shelter1={x=618,y=13,z=1010},shelter2={x=616,y=11,z=1036},
 gulch={x=536,y=9,z=1212},ruth_gulch={x=518,y=7,z=1210},dutch={x=522,y=7,z=1218},
 mine_gate={x=559,y=22,z=832},mine_clue={x=559,y=22,z=840},ledger1={x=559,y=21,z=856},
}
local function layout(id)
 local nodes,zones={},{}
 for _,spec in ipairs(assert(sites[id])) do
  local p,h=spec.pos,spec.half
  zones[#zones+1]={min={x=p.x-h,y=p.y,z=p.z-h},max={x=p.x+h,y=p.y+(spec.tower and 6 or 3),z=p.z+h}}
  for dx=-h,h do for dz=-h,h do for dy=0,3 do
   local perimeter=math.abs(dx)==h or math.abs(dz)==h
   local door=dx==0 and dz==-h and dy<2
   local include=not door and (dy==3 or perimeter and dy<3)
   if spec.open then include=dy==3 or (math.abs(dx)==h and math.abs(dz)==h and dy<3) end
   if include then
    local node=spec.material
    if dx==-h and dz==0 and dy==1 and (spec.actor or spec.fixture) then node='harrows_trail:mid_'..(spec.actor or spec.fixture) end
    nodes[#nodes+1]={pos={x=p.x+dx,y=p.y+dy,z=p.z+dz},name=node}
   end
  end end end
  if spec.open and (spec.actor or spec.fixture) then
   nodes[#nodes+1]={pos={x=p.x-h,y=p.y+1,z=p.z},name='harrows_trail:mid_'..(spec.actor or spec.fixture)}
  end
  if spec.tower then
   for dx=-1,1 do for dz=-1,1 do for dy=4,6 do
    if dy==6 or math.abs(dx)==1 or math.abs(dz)==1 then nodes[#nodes+1]={pos={x=p.x+dx,y=p.y+dy,z=p.z+dz},name='mcl_trees:wood_spruce'} end
   end end end
  end
 end
 return nodes,zones
end
return {sites=sites,positions=positions,layout=layout}
