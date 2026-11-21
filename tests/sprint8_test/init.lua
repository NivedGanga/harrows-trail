local api=assert(harrows_trail_test)
local c=api.cast
core.after(0,function()
 local phase=core.settings:get('harrows_sprint8_phase')
 if phase=='read' then
  local s=api.load('cast_test');assert(s.flags.seen_test_scene and s.flags.jesse_free);assert(s.version==1)
 else
  local s=api.load('cast_test');s.flags={};api.states.cast_test=s
  assert(c.phase(.5)=='day' and c.phase(.8)=='evening' and c.phase(.1)=='night')
  assert(c.schedule('jesse',.5,s.flags)=='jailed');s.flags.jesse_free=true
  assert(c.schedule('jesse',.1,s.flags)=='hiding' and c.schedule('jesse',.5,s.flags)=='wandering')
  assert(c.schedule('ada',.8,s.flags)=='patrol' and c.schedule('dutch',.1,s.flags)=='hayloft')
  assert(c.schedule('ruth',.1,s.flags)=='closed' and c.schedule('amos',.8,s.flags)=='fire')
  assert(c.active('jesse',s));s.flags.jesse_briefed=true;assert(not c.active('jesse',s) and c.active('dust',s))
  s.flags.arrived=true;assert(not c.active('dust',s) and c.active('gulch',s));s.flags.ledger1=true;assert(not c.active('gulch',s) and c.active('river_jesse',s))
  local p={removed=0,added=0};function p:get_player_name()return 'cast_test'end
  function p:get_pos()return {x=0,y=20,z=0}end
  function p:get_player_control()return {}end
  function p:hud_add(d)self.added=self.added+1;assert(d.text:find('Sneak'));return 123 end
  function p:hud_remove(id)assert(id==123);self.removed=self.removed+1 end
  assert(c.scene(p,'test_scene','ada','Testing.'));assert(c.scenes.cast_test and s.flags.seen_test_scene)
  c.stop(p);assert(not c.scenes.cast_test and p.removed==1);assert(not c.scene(p,'test_scene','ada','Testing.'))
  assert(c.scene(p,'skip_scene','ada','Skip.'));local lookup=core.get_player_by_name
  core.get_player_by_name=function(name) if name=='cast_test' then return p end;return lookup(name) end
  function p:get_player_control()return {sneak=true}end
  c.advance(.1);assert(not c.scenes.cast_test and p.removed==2);core.get_player_by_name=lookup
  assert(#core.registered_on_dieplayers>0)
  for _,role in ipairs({'eli','eli_duster','ada','jonah','dutch','ruth','amos','jesse','nora','crane','mercer'}) do
   local f=assert(io.open(core.get_modpath('harrows_trail')..'/textures/harrows_'..role..'.png','rb'));assert(f:read(8)=='\137PNG\13\10\26\10');f:close()
  end
  -- Empty unloaded terrain must never be used as a waypoint.
  assert(not c.safe({x=30000,y=30000,z=30000}))
  core.emerge_area({x=0,y=15,z=0},{x=16,y=25,z=16},function(_,_,left)
   if left~=0 then return end
   core.after(0,function()
    for x=2,8 do for z=1,7 do
     core.set_node({x=x,y=19,z=z},{name='mcl_core:stone'});for y=20,25 do core.set_node({x=x,y=y,z=z},{name='air'}) end
    end end
    local obj=assert(core.add_entity({x=5,y=20,z=5},'harrows_trail:opening_actor','ada'));local ent=obj:get_luaentity()
    assert(ent.role=='ada' and ent.home.x==5 and obj:get_properties().textures[1]=='harrows_ada.png')
    assert(c.actors[ent]);assert(c.update(ent)==false and not ent.routine);core.set_timeofday(.8);c.tick(ent,p,s);assert(ent.routine=='patrol' and obj:get_pos().z==2)
    core.set_timeofday(.1);c.tick(ent,p,s);assert(ent.routine=='resting' and obj:get_pos().z==5)
    ent.role='dutch';core.set_node({x=5,y=23,z=6},{name='mcl_farming:hay_block'});ent.routine=nil;c.tick(ent,p,s)
    assert(ent.routine=='hayloft' and obj:get_pos().y==24);obj:remove();assert(not c.actors[ent])
    api.save('cast_test');core.log('action','[sprint8_test] PASS write');core.request_shutdown('cast test complete',false,0)
   end)
  end)
  return
 end
 core.log('action','[sprint8_test] PASS read');core.request_shutdown('cast test complete',false,0)
end)
