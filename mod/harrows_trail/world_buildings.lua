-- Coordinates surveyed in the disposable development seed; other seeds are checked before placement.
local sites={
 ranch={
  {name='barn',pos={x=490,y=13,z=634},wall='harrows_trail:ash',damaged=true},
  {name='tack',pos={x=510,y=16,z=660},wall='mcl_trees:wood_spruce'},
  {name='corral',pos={x=536,y=18,z=644},wall='mcl_trees:wood_spruce',corral=true},
 },
 red_mesa={
  {name='sheriff',pos={x=614,y=21,z=788},wall='mcl_trees:wood_dark_oak'},
  {name='saloon',pos={x=620,y=21,z=788},wall='mcl_trees:wood_dark_oak'},
  {name='bank',pos={x=626,y=21,z=788},wall='mcl_core:sandstone'},
  {name='jail',pos={x=632,y=21,z=788},wall='mcl_core:stonebrick'},
 },
}
local function layout(id)
 local specs=assert(sites[id]); local nodes,zones={},{}
 for _,spec in ipairs(specs) do
  local p=spec.pos
  zones[#zones+1]={min={x=p.x-2,y=p.y,z=p.z-2},max={x=p.x+2,y=p.y+3,z=p.z+2}}
  for dx=-2,2 do for dz=-2,2 do
   for dy=0,3 do
    local perimeter=math.abs(dx)==2 or math.abs(dz)==2
    local door=dx==0 and dz==-2 and dy<2
    local include=not door and ((perimeter and dy<3) or dy==3)
    if spec.damaged then include=perimeter and not door and dy<2 and not (dx==2 and dz>0) end
    if spec.corral then include=perimeter and not door and dy<1 end
    if include then nodes[#nodes+1]={pos={x=p.x+dx,y=p.y+dy,z=p.z+dz},name=spec.wall} end
   end
  end end
 end
 return nodes,zones
end
return {sites=sites,layout=layout}
