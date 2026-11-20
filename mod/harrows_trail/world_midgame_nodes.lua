return function(interact)
 local actors={dust=2,gulch=2,ruth_gulch=1,dutch=2}
 local function spawn(pos,kind)
  local at={x=pos.x+actors[kind],y=pos.y-1,z=pos.z}
  for _,obj in ipairs(core.get_objects_inside_radius(at,0.4)) do
   local ent=obj:get_luaentity()
   if ent and ent.name=='harrows_trail:mid_actor' and ent.kind==kind then return end
  end
  core.add_entity(at,'harrows_trail:mid_actor',kind)
 end
 core.register_entity('harrows_trail:mid_actor',{
  initial_properties={physical=false,pointable=true,visual='mesh',mesh='mcl_armor_character.b3d',
   textures={'character.png','blank.png','blank.png'},visual_size={x=1,y=1},
   collisionbox={-0.3,-0.5,-0.3,0.3,1.3,0.3},selectionbox={-0.3,-0.5,-0.3,0.3,1.3,0.3},static_save=false},
  on_activate=function(self,data) if not actors[data] then self.object:remove();return end;self.kind=data;self.object:set_armor_groups({immortal=1}) end,
  on_rightclick=function(self,p) interact(self.kind,self.object:get_pos(),p) end,
 })
 for _,kind in ipairs({'dust','gulch','ruth_gulch','dutch','exposed','shelter1','shelter2','mine_gate','mine_clue','ledger1'}) do
  local actor=actors[kind]
  core.register_node('harrows_trail:mid_'..kind,{
   description=actor and 'Building wall' or 'Trail shelter',
   tiles={actor and 'mcl_core_planks_spruce.png' or 'mcl_core_sandstone_normal.png'},
   groups={unbreakable=1,not_in_creative_inventory=1},diggable=false,
   on_construct=actor and function(pos) spawn(pos,kind) end or nil,
   on_rightclick=not actor and function(pos,_,p) interact(kind,pos,p);return p:get_wielded_item() end or nil,
  })
 end
 core.register_lbm({name='harrows_trail:mid_actors',nodenames={'harrows_trail:mid_dust','harrows_trail:mid_gulch','harrows_trail:mid_ruth_gulch','harrows_trail:mid_dutch'},run_at_every_load=true,
  action=function(pos,node) local kind=node.name:match('mid_(.+)$');if actors[kind] then spawn(pos,kind) end end})
 local function ensure_actors(buildings)
  for _,b in ipairs(buildings) do if b.actor then
   local p=b.pos;local pos={x=p.x-b.half,y=p.y+1,z=p.z};local n=core.get_node_or_nil(pos)
   if n and n.name=='harrows_trail:mid_'..b.actor then spawn(pos,b.actor) end
  end end
 end
 return {ensure_actors=ensure_actors}
end
