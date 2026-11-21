return function(ctx)
 local mesa={x=620,y=22,z=783}
 local dust={x=70,y=221,z=3}
 local function clear(target)
  for x=target.x-1,target.x+1 do for z=target.z-1,target.z+1 do
   local floor=core.get_node_or_nil({x=x,y=target.y-1,z=z})
   if not floor or core.get_item_group(floor.name,'solid')==0 then return false end
   for y=target.y,target.y+2 do
    local node=core.get_node_or_nil({x=x,y=y,z=z})
    local def=node and core.registered_nodes[node.name]
    if not def or def.walkable~=false or (def.liquidtype and def.liquidtype~='none') then return false end
   end
  end end
  return #core.get_objects_in_area({x=target.x-1.5,y=target.y-0.5,z=target.z-1.5},
   {x=target.x+1.5,y=target.y+2.5,z=target.z+1.5})==0
 end
 local function travel(name,param)
  local player=core.get_player_by_name(name); local s=ctx.states[name]
  if ctx.late and ctx.late() then return false,'Travel along the railway and river trails. Use /trail for your current objective.' end
  if not ctx.grounded or not player or not s or not s.flags.jesse_briefed then return false,'The stagecoach opens after Jesse explains the Dust Road.' end
  local pos=player:get_pos(); local source,target
  local mid=ctx.midgame and ctx.midgame();local destination
  if mid then
   local p=ctx.chapter.positions
   local at_silver=vector.distance(pos,p.assay)<12
   local at_station=vector.distance(pos,p.station)<12
   local at_mine=vector.distance(pos,p.mine_gate)<12
   if not (at_silver or at_station or at_mine) then return false,'Follow the grounded Dust Flats trail. The temporary stagecoach connects Silver Spur, the station and the Ghost Mine.' end
   destination=param and param:match('^%s*(%S+)') or (at_silver and 'station' or at_mine and 'station' or s.flags.station_breached and 'mine' or 'silver')
   if not s.map_fragments['3'] then return false,'Find Samuel’s third fragment in the assay office before following Crane to the station.' end
   source=at_silver and p.assay or at_station and p.station or p.mine_gate
   local site_id
   if destination=='station' then target={x=181,y=221,z=3}
   elseif destination=='mine' and s.flags.station_breached then target={x=563,y=21,z=832};site_id='ghost_mine'
   elseif destination=='silver' then target={x=-464,y=10,z=-552};site_id='silver_spur'
   else return false,'Use /stagecoach station, /stagecoach silver, or /stagecoach mine after breaching the barricade.' end
   if site_id and not ctx.sites.placed(site_id) then ctx.ensure(site_id);return false,'Preparing the destination safely. Stay nearby and try again shortly.' end
  elseif vector.distance(pos,ctx.desk)<12 then source=ctx.desk; target=dust
  elseif vector.distance(pos,ctx.dust_marker)<12 then source=ctx.dust_marker; target=mesa
  else return false,'Use the stagecoach desk at Red Mesa or the Dust Road departure point.' end
  if target==dust and ctx.storage:get_string('chapter_site')~='1' then return false,'The Dust Road is not ready. Try again shortly.' end
  local initial_mount=player:get_attach()
  if initial_mount and not ctx.riding(player) then return false,'Dismount before boarding, or ride your own saddled horse.' end
  local pad=mid and 8 or 2
  core.emerge_area({x=target.x-pad,y=target.y-6,z=target.z-pad},{x=target.x+pad,y=target.y+8,z=target.z+pad},function(_,action,left)
   if action==core.EMERGE_ERRORED or action==core.EMERGE_CANCELLED then core.chat_send_player(name,'The destination could not be loaded.'); return end
   if left~=0 then return end
   local current=core.get_player_by_name(name)
   if not current or vector.distance(current:get_pos(),source)>=12 then return end
   if mid and not clear(target) then
    local desired=target;local landing
    for radius=0,5 do if not landing then
     for dx=-radius,radius do for dz=-radius,radius do for dy=-3,3 do
      if not landing and math.max(math.abs(dx),math.abs(dz))==radius then
       local candidate={x=desired.x+dx,y=desired.y+dy,z=desired.z+dz}
       if clear(candidate) then landing=candidate end
      end
     end end end
    end end
    if landing then target=landing end
   end
   if not clear(target) then core.chat_send_player(name,'The destination is obstructed. Nothing was moved.'); return end
   local mount=current:get_attach()
   if mount~=initial_mount then core.chat_send_player(name,'Your mount changed; start the trip again.'); return end
   if mount then
    if not ctx.riding(current) then core.chat_send_player(name,'Dismount or ride your own saddled horse.'); return end
    mount:set_pos(target)
   else current:set_pos(target) end
   core.chat_send_player(name,mid and 'The stagecoach reaches '..destination..'.' or target==dust and 'The stagecoach reaches the Dust Road.' or 'The stagecoach returns to Red Mesa.')
  end)
  return true,'Preparing the stagecoach. Stay nearby.'
 end
 if ctx.grounded then core.register_chatcommand('stagecoach',{description='Use a temporary stagecoach connection',params='[station | mine | silver]',func=travel}) end
 return {travel=travel,clear=clear,mesa=mesa,dust=dust}
end
