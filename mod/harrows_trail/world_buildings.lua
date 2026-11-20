-- Coordinates surveyed in the disposable development seed; other seeds are checked before placement.
local sites={
 ranch={
  {name='barn',pos={x=664,y=17,z=638},wall='harrows_trail:ash',damaged=true},
  {name='tack',pos={x=670,y=18,z=650},wall='mcl_trees:wood_spruce'},
  {name='corral',pos={x=654,y=19,z=652},wall='mcl_trees:wood_spruce',corral=true},
 },
 red_mesa={
  {name='sheriff',pos={x=614,y=21,z=788},wall='mcl_trees:wood_dark_oak'},
  {name='saloon',pos={x=620,y=21,z=788},wall='mcl_trees:wood_dark_oak'},
  {name='bank',pos={x=626,y=21,z=788},wall='mcl_core:sandstone'},
  {name='jail',pos={x=632,y=21,z=788},wall='mcl_core:stonebrick'},
  {name='church',pos={x=640,y=20,z=788},wall='mcl_core:sandstone',tower=true},
 },
}
local positions={
 spawn={x=670,y=18,z=650},barn={x=662,y=18,z=638},tack={x=668,y=19,z=650},
 corral={x=652,y=19,z=652},route={x=614,y=21,z=784},ada={x=614,y=21,z=788},
 delivery={x=666,y=18,z=638},depot={x=672,y=19,z=650},
 jesse={x=632,y=21,z=788},ruth={x=620,y=21,z=788},cache={x=624,y=22,z=788},
 stagecoach={x=622,y=22,z=788},
}
local route={
 {x=654,y=19,z=649},
 {x=654,y=18,z=648},
 {x=650,y=18,z=648},
 {x=650,y=20,z=660},
 {x=650,y=21,z=672},
 {x=650,y=21,z=684},
 {x=650,y=21,z=696},
 {x=650,y=20,z=708},
 {x=650,y=20,z=720},
 {x=650,y=20,z=732},
 {x=650,y=20,z=744},
 {x=650,y=20,z=756},
 {x=650,y=20,z=768},
 {x=650,y=19,z=780},
 {x=650,y=19,z=784},
 {x=638,y=20,z=784},
 {x=626,y=21,z=784},
 {x=614,y=22,z=784},
}
local function layout(id)
 local specs=assert(sites[id]); local nodes,zones,details={},{},{}
 for _,spec in ipairs(specs) do
  local p=spec.pos
  zones[#zones+1]={min={x=p.x-2,y=p.y,z=p.z-2},max={x=p.x+2,y=p.y+(spec.tower and 7 or (spec.name=='sheriff' or spec.name=='saloon') and 4 or 3),z=p.z+2}}
  for dx=-2,2 do for dz=-2,2 do
   for dy=0,3 do
    local perimeter=math.abs(dx)==2 or math.abs(dz)==2
    local door=(dx==0 or spec.corral and math.abs(dx)<=1) and dz==-2 and dy<2
    local saloon_door=spec.name=='saloon' and dz==-2 and (dx==0 or dx==1) and dy<2
    local include=saloon_door or not door and ((perimeter and dy<3) or dy==3)
    if spec.damaged then include=perimeter and not door and dy<2 and not (dx==2 and dz>0) end
    if spec.corral then include=perimeter and not door and dy<1 end
    if include then
     local name=spec.wall
     if saloon_door then name='mcl_doors:door_dark_oak_'..(dy==0 and 'b' or 't')..'_'..(dx==0 and '1' or '2') end
     local bars=spec.name=='jail' and dx==0 and dz==2 and dy==1
     if bars then name='mcl_panes:bar_flat' end
     local sign=(spec.name=='bank' or spec.name=='jail' or spec.name=='church') and dx==0 and dz==-2 and dy==3
     if sign then name='mcl_signs:wall_sign_dark_oak' end
     if dx==-2 and dz==0 and dy==(spec.corral and 0 or 1) then
      local anchor=({barn='barn',tack='tack',corral='corral',sheriff='office',saloon='saloon',bank='cache',jail='jail'})[spec.name]
      if anchor then name='harrows_trail:grounded_'..anchor end
     elseif dx==2 and dz==0 and dy==1 then
      if spec.name=='barn' then name='harrows_trail:grounded_delivery' elseif spec.name=='tack' then name='harrows_trail:grounded_depot' elseif spec.name=='saloon' then name='harrows_trail:grounded_stagecoach' end
     end
     local entry={pos={x=p.x+dx,y=p.y+dy,z=p.z+dz},name=name,mirrored=saloon_door and dx==1 or nil,
      text=sign and spec.name:upper() or nil,param2=sign and core.dir_to_wallmounted({x=0,y=0,z=1}) or nil}
     if bars then details[#details+1]=entry else nodes[#nodes+1]=entry end
    end
   end
  end end
  if spec.name=='sheriff' or spec.name=='saloon' then
   for dx=-2,2 do
    local sign=dx==0
    nodes[#nodes+1]={pos={x=p.x+dx,y=p.y+4,z=p.z-2},name=sign and 'mcl_signs:wall_sign_dark_oak' or spec.wall,
     text=sign and spec.name:upper() or nil,param2=sign and core.dir_to_wallmounted({x=0,y=0,z=1}) or nil}
   end
   nodes[#nodes+1]={pos={x=p.x,y=p.y+4,z=p.z-1},name=spec.wall}
  end
  if spec.tower then
   for dy=4,6 do
    for _,offset in ipairs({{-1,-1},{-1,1},{1,-1},{1,1}}) do
     nodes[#nodes+1]={pos={x=p.x+offset[1],y=p.y+dy,z=p.z+offset[2]},name=spec.wall}
    end
   end
   nodes[#nodes+1]={pos={x=p.x,y=p.y+4,z=p.z},name='mcl_bells:bell'}
  end
 end
 for _,entry in ipairs(details) do nodes[#nodes+1]=entry end
 return nodes,zones
end
return {sites=sites,positions=positions,route=route,layout=layout}
