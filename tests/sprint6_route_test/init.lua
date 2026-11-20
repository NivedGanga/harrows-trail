core.after(0,function()
 local file=assert(io.open(core.get_modpath('sprint6_route_test')..'/path.json','r'));local path=assert(core.parse_json(file:read('*a')));file:close()
 local function validate()
 local function clear(p)
  core.load_area({x=p.x,y=p.y-1,z=p.z},{x=p.x,y=p.y+1,z=p.z})
  local n=core.get_node({x=p.x,y=p.y-1,z=p.z});local d=core.registered_nodes[n.name]
  if not d or not d.walkable or d.liquidtype and d.liquidtype~='none' then return false end
  for yy=p.y,p.y+1 do local v=core.registered_nodes[core.get_node({x=p.x,y=yy,z=p.z}).name];if not v or v.walkable or v.liquidtype and v.liquidtype~='none' then return false end end
  return true
 end
 local current=path[1];assert(clear(current),'route start blocked')
 local walked={current};local raw_blocked=0
 for i,goal in ipairs(path) do
  if not clear(goal) then raw_blocked=raw_blocked+1 end
  local function arrived(p) return math.abs(p.x-goal.x)+math.abs(p.z-goal.z)<=2 and math.abs(p.y-goal.y)<=2 end
  if not arrived(current) then
   local queue={current};local visited={[core.pos_to_string(current)]=true};local prev={};local index=1;local found
   while index<=#queue and #queue<4000 do
    local at=queue[index];index=index+1;if arrived(at) then found=at;break end
    for _,delta in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
     local x,z=at.x+delta[1],at.z+delta[2]
     if math.abs(x-goal.x)<=8 and math.abs(z-goal.z)<=8 then
      for dy=-1,1 do
       local v={x=x,y=at.y+dy,z=z};local k=core.pos_to_string(v)
       if not visited[k] then
        visited[k]=true
        if clear(v) then queue[#queue+1]=v;prev[k]=at end
       end
      end
     end
    end
   end
   assert(found,'no walking detour in route corridor at '..i..' '..core.pos_to_string(goal))
   local detour={};local at=found
   while at and at~=current do detour[#detour+1]=at;at=prev[core.pos_to_string(at)] end
   for j=#detour,1,-1 do walked[#walked+1]=detour[j] end
   current=found
  end
 end
 core.safe_file_write(core.get_worldpath()..'/route-verified.json',core.write_json(walked))
 core.log('action',('[route_validation] corridor_failures=0 recorded_cells=%d raw_blocked=%d verified_walking_cells=%d riding_unverified=true'):format(#path,raw_blocked,#walked))
 core.request_shutdown('validation done',false,0)
 end
 local columns,ordered={},{}
 for _,p in ipairs(path) do
  local x,z=math.floor(p.x/16)*16,math.floor(p.z/16)*16;local key=x..','..z
  local c=columns[key]
  if not c then c={x=x,z=z,miny=p.y-4,maxy=p.y+4};columns[key]=c;ordered[#ordered+1]=c else c.miny=math.min(c.miny,p.y-4);c.maxy=math.max(c.maxy,p.y+4) end
 end
 local function emerge(i)
  local c=ordered[i];if not c then return validate() end
  core.emerge_area({x=c.x,y=c.miny,z=c.z},{x=c.x+15,y=c.maxy,z=c.z+15},function(_,action,left)
   assert(action~=core.EMERGE_ERRORED and action~=core.EMERGE_CANCELLED,'route generation failed')
   if left==0 then emerge(i+1) end
  end)
 end
 for _,id in ipairs({'gulch_bridge','foothill_bridge','pass_bridge'}) do assert(harrows_trail_test.world_sites.placed(id),'source test world needs '..id) end
 emerge(1)
end)
