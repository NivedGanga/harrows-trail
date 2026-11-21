return function(interact)
 local actor_nodes={ada='harrows_trail:grounded_office',jesse='harrows_trail:grounded_jail',ruth='harrows_trail:grounded_saloon'}
 local function spawn(pos,kind)
  local at={x=pos.x+2,y=pos.y-1,z=pos.z}
  for _,obj in ipairs(core.get_objects_inside_radius(at,4)) do
   local ent=obj:get_luaentity()
   if ent and ent.name=='harrows_trail:opening_actor' and ent.kind==kind then return end
  end
  core.add_entity(at,'harrows_trail:opening_actor',kind)
 end
 core.register_entity('harrows_trail:opening_actor',{
  initial_properties={physical=false,pointable=true,visual='mesh',mesh='mcl_armor_character.b3d',
   textures={'character.png','blank.png','blank.png'},visual_size={x=1,y=1},
   collisionbox={-0.3,-0.5,-0.3,0.3,1.3,0.3},selectionbox={-0.3,-0.5,-0.3,0.3,1.3,0.3},static_save=false},
  on_activate=function(self,data)
   if not actor_nodes[data] then self.object:remove();return end
   self.kind=data;self.object:set_armor_groups({immortal=1})
  end,
  on_rightclick=function(self,p) interact(self.kind,self.object:get_pos(),p) end,
 })
 local walls={
  barn={texture='default_bookshelf.png^[colorize:#24140d:130',kind='barn',label='Search the burned shelf'},
  tack={texture='mcl_barrels_barrel_side.png',kind='tack',label='Tack-room supplies'},
  corral={texture='mcl_core_planks_spruce.png',kind='corral',label='Ranch corral'},
  delivery={texture='mcl_barrels_barrel_side.png',kind='delivery',label='Ranch delivery supplies'},
  depot={texture='mcl_barrels_barrel_side.png',kind='depot',label='Ranch delivery depot'},
  stagecoach={texture='default_bookshelf.png',kind='stagecoach',label='Stagecoach desk'},
  cache={texture='mcl_barrels_barrel_side.png',kind='cache',label='Abandoned payroll box'},
  office={texture='mcl_core_planks_big_oak.png',actor='ada'},
  saloon={texture='mcl_core_planks_big_oak.png',actor='ruth'},
  jail={texture='default_stone_brick.png',actor='jesse'},
 }
 for id,def in pairs(walls) do
  core.register_node('harrows_trail:grounded_'..id,{
   description=def.label or 'Building wall',tiles={def.texture},groups={unbreakable=1,not_in_creative_inventory=1},diggable=false,
   on_construct=function(pos)
    if def.label then core.get_meta(pos):set_string('infotext',def.label..' (right-click)') end
    if def.actor then spawn(pos,def.actor) end
   end,
   on_rightclick=def.kind and function(pos,_,player)
    local target=def.kind=='corral' and {x=pos.x+2,y=pos.y,z=pos.z-2} or pos
    interact(def.kind,target,player); return player:get_wielded_item()
   end or nil,
  })
 end
 core.register_lbm({name='harrows_trail:opening_actors',nodenames={actor_nodes.ada,actor_nodes.jesse,actor_nodes.ruth},
  run_at_every_load=true,action=function(pos,node)
   for kind,n in pairs(actor_nodes) do if node.name==n then spawn(pos,kind); return end end
  end})
 local function ensure_actors(buildings)
  local names={sheriff='ada',jail='jesse',saloon='ruth'}
  for _,building in ipairs(buildings) do
   local kind=names[building.name]
   if kind then
    local p=building.pos; local anchor={x=p.x-2,y=p.y+1,z=p.z}
    local node=core.get_node_or_nil(anchor)
    if node and node.name==actor_nodes[kind] then spawn(anchor,kind) end
   end
  end
 end
 return {ensure_actors=ensure_actors}
end
