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
 local function travel(name)
  local player=core.get_player_by_name(name); local s=ctx.states[name]
  if not ctx.grounded or not player or not s or not s.flags.jesse_briefed then return false,'The stagecoach opens after Jesse explains the Dust Road.' end
  local pos=player:get_pos(); local source,target
  if vector.distance(pos,ctx.desk)<12 then source=ctx.desk; target=dust
  elseif vector.distance(pos,ctx.dust_marker)<12 then source=ctx.dust_marker; target=mesa
  else return false,'Use the stagecoach desk at Red Mesa or the Dust Road departure point.' end
  if target==dust and ctx.storage:get_string('chapter_site')~='1' then return false,'The Dust Road is not ready. Try again shortly.' end
  local initial_mount=player:get_attach()
  if initial_mount and not ctx.riding(player) then return false,'Dismount before boarding, or ride your own saddled horse.' end
  core.emerge_area({x=target.x-2,y=target.y-2,z=target.z-2},{x=target.x+2,y=target.y+4,z=target.z+2},function(_,action,left)
   if action==core.EMERGE_ERRORED or action==core.EMERGE_CANCELLED then core.chat_send_player(name,'The destination could not be loaded.'); return end
   if left~=0 then return end
   local current=core.get_player_by_name(name)
   if not current or vector.distance(current:get_pos(),source)>=12 then return end
   if not clear(target) then core.chat_send_player(name,'The destination is obstructed. Nothing was moved.'); return end
   local mount=current:get_attach()
   if mount~=initial_mount then core.chat_send_player(name,'Your mount changed; start the trip again.'); return end
   if mount then
    if not ctx.riding(current) then core.chat_send_player(name,'Dismount or ride your own saddled horse.'); return end
    mount:set_pos(target)
   else current:set_pos(target) end
   core.chat_send_player(name,target==dust and 'The stagecoach reaches the Dust Road.' or 'The stagecoach returns to Red Mesa.')
  end)
  return true,'Preparing the stagecoach. Stay nearby.'
 end
 if ctx.grounded then core.register_chatcommand('stagecoach',{description='Travel between Red Mesa and the temporary Dust Road departure',func=travel}) end
 return {travel=travel,clear=clear,mesa=mesa,dust=dust}
end
