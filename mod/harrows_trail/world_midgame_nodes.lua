return function(interact)
 local actors={dust=2,gulch=2,ruth_gulch=1,dutch=2,ferry=2}
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
 local fixtures={mine_gate={'Mine timbers','mcl_core_planks_spruce.png'},mine_clue={'Nora’s trail beside the tracks','default_bookshelf.png'},ledger1={'Mine office ledger','default_bookshelf.png'},pass={'Iron Pass timbers','mcl_core_planks_spruce.png'},rubble1={'Western collapsed shaft','default_cobble.png'},rubble2={'Eastern collapsed shaft','default_cobble.png'},assay={'Assay ledger desk','default_bookshelf.png'},cartography={'Map desk','default_bookshelf.png'},gold_cache={'Assay safe','mcl_barrels_barrel_side.png'}}
 fixtures.station={'Station planning desk','default_bookshelf.png'};fixtures.charge={'Barricade charge controls','mcl_barrels_barrel_side.png'}
 fixtures.hideout={'Hideout search','default_bookshelf.png'};fixtures.ledger2={'Hideout ledger','default_bookshelf.png'};fixtures.snag={'Snagged ferry line','mcl_core_planks_spruce.png'}
 for _,kind in ipairs({'dust','gulch','ruth_gulch','dutch','exposed','shelter1','shelter2','mine_gate','mine_clue','ledger1','pass','rubble1','rubble2','assay','cartography','gold_cache','station','charge','ferry','snag','hideout','ledger2'}) do
  local actor=actors[kind]
  core.register_node('harrows_trail:mid_'..kind,{
   description=fixtures[kind] and fixtures[kind][1] or actor and 'Building wall' or 'Trail shelter',
   tiles={fixtures[kind] and fixtures[kind][2] or actor and kind~='dust' and 'mcl_core_planks_spruce.png' or 'mcl_core_sandstone_normal.png'},
   groups={unbreakable=1,not_in_creative_inventory=1},diggable=false,
   on_construct=actor and function(pos) spawn(pos,kind) end or nil,
   on_rightclick=not actor and function(pos,_,p) interact(kind,pos,p);return p:get_wielded_item() end or nil,
  })
 end
 for _,kind in ipairs({'rubble1','rubble2'}) do
  core.register_node('harrows_trail:mid_'..kind..'_cleared',{description='Cleared shaft support',tiles={'mcl_core_planks_spruce.png'},groups={unbreakable=1,not_in_creative_inventory=1},diggable=false,
   on_rightclick=function(pos,_,p) interact(kind,pos,p);return p:get_wielded_item() end})
 end
 local function clear_rubble(kind)
  local definitions={rubble1={anchor={x=-480,y=55,z=-512},door={x=-478,y=54,z=-514}},rubble2={anchor={x=-474,y=56,z=-514},door={x=-472,y=55,z=-516}}}
  local def=definitions[kind];if not def then return end
  local name='harrows_trail:mid_'..kind
  if core.get_node(def.anchor).name==name then core.set_node(def.anchor,{name=name..'_cleared'}) end
  for dy=0,1 do local p=vector.offset(def.door,0,dy,0);if core.get_node(p).name==name then core.set_node(p,{name='air'}) end end
 end
 core.register_lbm({name='harrows_trail:mid_actors',nodenames={'harrows_trail:mid_dust','harrows_trail:mid_gulch','harrows_trail:mid_ruth_gulch','harrows_trail:mid_dutch','harrows_trail:mid_ferry'},run_at_every_load=true,
  action=function(pos,node) local kind=node.name:match('mid_(.+)$');if actors[kind] then spawn(pos,kind) end end})
 local function ensure_actors(buildings)
  for _,b in ipairs(buildings) do if b.actor then
   local p=b.pos;local pos={x=p.x-b.half,y=p.y+1,z=p.z};local n=core.get_node_or_nil(pos)
   if n and n.name=='harrows_trail:mid_'..b.actor then spawn(pos,b.actor) end
  end end
 end
 return {ensure_actors=ensure_actors,clear_rubble=clear_rubble}
end
