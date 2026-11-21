-- Plans only: all changes go through the shared world_sites preflight and placer.
local sites={station=true,bitter_river=true,widowmaker=true}
local positions={station={x=-295,y=20,z=-204},charge={x=-299,y=19,z=-222},ferry={x=294,y=21,z=1500},snag={x=297,y=22,z=1500},hideout={x=304,y=23,z=1495},ledger2={x=308,y=23,z=1496}}
local finale={gate={x=496,y=32,z=1600},supplies={x=497,y=32,z=1600},goods={x=497,y=32,z=1602},help={x=501,y=32,z=1602},debt={x=501,y=32,z=1600},mercer={x=499,y=32,z=1604},nora={x=497,y=32,z=1608},crane={x=501,y=32,z=1610}}
local function layout(id)
 assert(sites[id]);local cells,zones={},{}
 local function add(x,y,z,name,owner)
  local pos={x=x,y=y,z=z};cells[x..','..y..','..z]={pos=pos,name=name,terrain_edit=true,owner=owner}
 end
 local function zone(x1,y1,z1,x2,y2,z2)
  zones[#zones+1]={min={x=x1,y=y1,z=z1},max={x=x2,y=y2,z=z2}}
 end
 local function room(x,y,z,half,open,fixture,tower)
  zone(x-half,y-1,z-half,x+half,y+(tower and 6 or 3),z+half)
  for dx=-half,half do for dz=-half,half do for dy=-1,(tower and 6 or 3) do
   local edge=math.abs(dx)==half or math.abs(dz)==half
   local corner=math.abs(dx)==half and math.abs(dz)==half
   local name='air'
   if dy==-1 or dy==3 then name='mcl_trees:wood_spruce'
   elseif dy<3 and dy>=0 and (open and corner or not open and edge and not (dx==0 and dz==-half and dy<2)) then name='mcl_trees:wood_spruce'
   elseif tower and dy>=4 and (dy==6 or math.abs(dx)<=1 and math.abs(dz)<=1 and (math.abs(dx)==1 or math.abs(dz)==1)) then name='mcl_trees:wood_spruce' end
   if fixture and dx==-half and dz==0 and dy==1 then name='harrows_trail:mid_'..fixture end
   add(x+dx,y+dy,z+dz,name)
  end end end
 end
 if id=='station' then
  room(-293,19,-204,2,false,'station')
  room(-305,19,-216,2,true,nil,true)
  room(-297,18,-222,2,true,'charge')
  for x=-298,-296 do
   add(x,18,-222,'mcl_walls:cobble','station:barricade')
   add(x,19,-222,'mcl_fences:spruce_fence','station:barricade')
  end
  for z=-224,-220 do if z~=-222 then add(-297,18,z,'mcl_minecarts:rail') end end
 elseif id=='bitter_river' then
  room(294,21,1500,2,true,'ferry')
  room(306,22,1496,2,false,nil)
  add(304,23,1495,'harrows_trail:mid_hideout');add(308,23,1496,'harrows_trail:mid_ledger2')
  -- A shallow channel, enclosed by unchanged solid banks, in the Swamp footprint.
  zone(299,20,1494,301,24,1502)
  for x=299,301 do for z=1494,1502 do for y=20,24 do add(x,y,z,y==20 and 'mcl_core:water_source' or 'air') end end end
  for _,range in ipairs({{297,298},{302,303}}) do
   zone(range[1],21,1496,range[2],24,1500)
   for x=range[1],range[2] do for z=1496,1500 do for y=21,24 do add(x,y,z,y==21 and 'mcl_trees:wood_spruce' or 'air') end end end
  end
  -- The flat ferry deck lies over the channel, between its two docks.
  for x=299,301 do for z=1496,1500 do
   add(x,21,z,'mcl_trees:wood_dark_oak')
   if z==1496 or z==1500 then add(x,22,z,'mcl_fences:dark_oak_fence','river:ferry') end
  end end
  add(297,22,1500,'harrows_trail:mid_snag')
  for _,p in ipairs({{x=299,z=1493},{x=300,z=1493},{x=301,z=1493},{x=299,z=1503},{x=300,z=1503},{x=301,z=1503}}) do
   zone(p.x,20,p.z,p.x,20,p.z);add(p.x,20,p.z,'mcl_core:dirt')
  end
 elseif id=='widowmaker' then
  -- A supported cut in the exposed rocky Forest hillside. No terrain outside
  -- this footprint is edited; the lower approach has a short stair descent.
  zone(499,31,1594,501,37,1599)
  zone(495,31,1600,503,34,1616);zones[#zones].bridge_span=true
  for x=495,503 do for z=1594,1616 do for y=31,(z<1600 and 37 or 34) do
   local name='air'
   if y==31 or y==34 and z>=1600 or (x==495 or x==503 or z==1616) and z>=1600 and y<=34 then name='mcl_core:stone' end
   if z>=1600 and z<=1614 and z%4==0 and (x==496 or x==502) and y<=34 then name='mcl_trees:wood_spruce' end
   if z>=1600 or x>=499 and x<=501 then add(x,y,z,name) end
  end end end
  for z=1594,1599 do
   local floor=31+math.max(0,1598-z)
   for x=499,501 do
    for y=31,floor do add(x,y,z,'mcl_core:stone') end
   end
  end
  for z=1600,1615 do add(499,32,z,'mcl_minecarts:rail') end
  for kind,p in pairs(finale) do add(p.x,p.y,p.z,'harrows_trail:finale_'..kind) end
 end
 local nodes={};for _,entry in pairs(cells) do nodes[#nodes+1]=entry end
 table.sort(nodes,function(a,b)local p,q=a.pos,b.pos;if p.x~=q.x then return p.x<q.x elseif p.z~=q.z then return p.z<q.z else return p.y<q.y end end)
 return nodes,zones
end
return {sites=sites,positions=positions,finale=finale,layout=layout}
