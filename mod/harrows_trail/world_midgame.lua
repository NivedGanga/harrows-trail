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
  {name='stable',pos={x=522,y=7,z=1218},half=2,material='mcl_trees:wood_spruce',open=true,actor='dutch',loft=true},
  {name='tower',pos={x=510,y=6,z=1206},half=2,material='mcl_trees:wood_spruce',open=true,tower=true},
 },
 ghost_mine={
  {name='entrance',pos={x=560,y=21,z=832},half=1,material='mcl_core:stone',open=true,fixture='mine_gate',mine=true},
  {name='tracks',pos={x=560,y=21,z=840},half=1,material='mcl_core:stone',open=true,fixture='mine_clue',mine=true},
  {name='office',pos={x=560,y=20,z=856},half=1,material='mcl_trees:wood_spruce',fixture='ledger1'},
 },
 iron_pass={},
 gulch_bridge={},
 foothill_bridge={},pass_bridge={},
 silver_spur={
  {name='assay_office',pos={x=-464,y=10,z=-548},half=2,material='mcl_trees:wood_spruce',fixture='assay',extra_fixtures={{dx=2,dz=0,kind='cartography'},{dx=0,dz=2,kind='gold_cache'}}},
  {name='shack',pos={x=-466,y=11,z=-556},half=2,material='mcl_trees:wood_spruce'},
  {name='headframe',pos={x=-460,y=12,z=-566},half=2,material='mcl_trees:wood_spruce',open=true,tower=true,headframe=true},
 },
}
local positions={
 dust={x=642,y=11,z=1012},exposed={x=658,y=11,z=1024},
 shelter1={x=618,y=13,z=1010},shelter2={x=616,y=11,z=1036},
 gulch={x=536,y=9,z=1212},ruth_gulch={x=518,y=7,z=1210},dutch={x=522,y=7,z=1218},
 mine_gate={x=559,y=22,z=832},mine_clue={x=559,y=22,z=840},ledger1={x=559,y=21,z=856},
 assay={x=-466,y=11,z=-548},cartography={x=-462,y=11,z=-548},gold_cache={x=-464,y=11,z=-546},
 pass={x=-486,y=54,z=-514},rubble1={x=-480,y=55,z=-512},rubble2={x=-474,y=56,z=-514},
}
local function layout(id)
 local nodes,zones={},{}
 local crossing=({foothill_bridge={x1=-317,x2=-299,y=11,z=-399},pass_bridge={x1=-424,x2=-420,y=6,z=-481}})[id]
 if crossing then
  local c=crossing
  zones[1]={min={x=c.x1,y=c.y,z=c.z-2},max={x=c.x2,y=c.y+3,z=c.z+2},bridge_span=true}
  for x=c.x1,c.x2 do for z=c.z-2,c.z+2 do
   nodes[#nodes+1]={pos={x=x,y=c.y,z=z},name='mcl_trees:wood_spruce'}
   if math.abs(z-c.z)==2 then for y=c.y+1,c.y+2 do nodes[#nodes+1]={pos={x=x,y=y,z=z},name='mcl_trees:wood_spruce'} end end
  end end
  return nodes,zones
 end
 if id=='gulch_bridge' then
  zones[1]={min={x=502,y=15,z=677},max={x=506,y=18,z=701},bridge_span=true}
  zones[2]={min={x=503,y=14,z=702},max={x=505,y=18,z=702}}
  for x=503,505 do nodes[#nodes+1]={pos={x=x,y=14,z=702},name='mcl_trees:wood_spruce'} end
  for x=502,506 do for z=677,701 do
   nodes[#nodes+1]={pos={x=x,y=15,z=z},name='mcl_trees:wood_spruce'}
   if x==502 or x==506 then for y=16,17 do nodes[#nodes+1]={pos={x=x,y=y,z=z},name='mcl_trees:wood_spruce'} end end
  end end
  return nodes,zones
 end
 if id=='iron_pass' then
  local spans={
   {x=-486,z=-516,roof=57,kind='pass',heights={{52,52,52,52,52},{53,52,52,52,52},{53,53,53,53,53},{53,53,53,53,53},{53,53,53,52,52}}},
   {x=-480,z=-514,roof=58,kind='rubble1',heights={{53,53,53,54,54},{53,53,54,54,54},{53,53,54,54,54},{53,53,54,54,54},{53,53,54,54,54}}},
   {x=-474,z=-516,roof=59,kind='rubble2',heights={{54,54,54,54,54},{54,54,54,54,54},{54,54,54,54,55},{54,54,55,55,55},{55,55,55,55,55}}},
  }
  for _,span in ipairs(spans) do
   for dz=-2,2 do for dx=-2,2 do
    local y=span.heights[dz+3][dx+3];local x,z=span.x+dx,span.z+dz
    zones[#zones+1]={min={x=x,y=y,z=z},max={x=x,y=span.roof,z=z}}
    for yy=y,span.roof do
     local wall=math.abs(dx)==2 or math.abs(dz)==2
     local door=math.abs(dx)==2 and dz==0 and yy<y+2
     if yy==span.roof or wall and not door then
      local name='mcl_trees:wood_spruce'
      if dx==0 and dz==2 and yy==y+1 then name='harrows_trail:mid_'..span.kind end
      nodes[#nodes+1]={pos={x=x,y=yy,z=z},name=name,replace_natural_snow=yy==y}
     end
    end
   end end
   if span.kind~='pass' then
    local y=span.heights[3][5]
    for yy=y,y+1 do nodes[#nodes+1]={pos={x=span.x+2,y=yy,z=span.z},name='harrows_trail:mid_'..span.kind,replace_natural_snow=yy==y} end
   end
  end
  return nodes,zones
 end
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
    if spec.mine and math.abs(dx)==h and math.abs(dz)==h and dy<3 then node='mcl_trees:wood_spruce' end
    if spec.loft and dy==3 and dz==1 and math.abs(dx)<=1 then node='mcl_farming:hay_block' end
    if dx==-h and dz==0 and dy==1 and (spec.actor or spec.fixture) then node='harrows_trail:mid_'..(spec.actor or spec.fixture) end
    if dy==1 then for _,fixture in ipairs(spec.extra_fixtures or {}) do
     if dx==fixture.dx and dz==fixture.dz then node='harrows_trail:mid_'..fixture.kind end
    end end
    nodes[#nodes+1]={pos={x=p.x+dx,y=p.y+dy,z=p.z+dz},name=node}
   end
  end end end
  if spec.open and (spec.actor or spec.fixture) then
   nodes[#nodes+1]={pos={x=p.x-h,y=p.y+1,z=p.z},name='harrows_trail:mid_'..(spec.actor or spec.fixture)}
  end
  if spec.tower then
   for dx=-1,1 do for dz=-1,1 do for dy=4,6 do
    if dy==6 or (spec.headframe and math.abs(dx)==1 and math.abs(dz)==1 or not spec.headframe and (math.abs(dx)==1 or math.abs(dz)==1)) then nodes[#nodes+1]={pos={x=p.x+dx,y=p.y+dy,z=p.z+dz},name='mcl_trees:wood_spruce'} end
   end end end
  end
  if spec.loft then for dx=-1,1 do nodes[#nodes+1]={pos={x=p.x+dx,y=p.y+2,z=p.z+1},name='mcl_trees:wood_spruce'} end end
  if spec.headframe then
   nodes[#nodes+1]={pos={x=p.x+1,y=p.y,z=p.z+1},name='mcl_core:gravel'}
   nodes[#nodes+1]={pos={x=p.x,y=p.y,z=p.z+1},name='mcl_core:dirt'}
  end
 end
 if id=='ghost_mine' then
  zones[#zones+1]={min={x=559,y=21,z=834},max={x=561,y=24,z=838}}
  for x=559,561 do for z=834,838 do for y=21,24 do
   if x~=560 or y==24 then
    nodes[#nodes+1]={pos={x=x,y=y,z=z},name=(z==834 or z==838) and 'mcl_trees:wood_spruce' or 'mcl_core:stone'}
   end
  end end end
  for z=831,841 do nodes[#nodes+1]={pos={x=560,y=21,z=z},name='mcl_minecarts:rail'} end
 end
 return nodes,zones
end
return {sites=sites,positions=positions,layout=layout}
