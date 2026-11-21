local a=assert(harrows_trail_test);local r=a.reputation
core.after(0,function()
 local phase=core.settings:get('harrows_sprint9_phase')
 if phase=='read' then
  local s=a.load('reputation_test');assert(s.flags.contract_red_mesa and s.flags.consequence_help_once and s.wanted==4 and s.nora_trust==60)
 else
  for kind,delta in pairs(r.events) do
   local s=a.load('fresh_'..kind);assert(r.event(s,kind,'once'));assert(s.honor==50+delta[1] and s.nora_trust==50+delta[2] and s.wanted==delta[3])
   assert(not r.event(s,kind,'once'));assert(s.honor==50+delta[1])
  end
  local s=a.load('reputation_test');a.states.reputation_test=s
  assert(not r.reaction({wanted=2},true,false));assert(r.reaction({wanted=3},true,false)=='deputy')
  assert(not r.reaction({wanted=3},false,true) and r.reaction({wanted=4},false,true)=='hunter')
  assert(not r.reaction({wanted=4},false,false))
  s.honor=500;s.nora_trust=-20;s.wanted=8;r.normalize(s);assert(s.honor==100 and s.nora_trust==0 and s.wanted==4)
  assert(r.price(s,3)==2);s.honor=10;assert(r.price(s,3)==6);s.honor=50;assert(r.price(s,3)==3)
  s.wanted=3;s.flags.evasion_days=0
  assert(not r.decay(s,1,.2,false));assert(not r.decay(s,1,.7,false));assert(not r.decay(s,1,.8,true));assert(s.flags.evasion_days==0)
  assert(not r.decay(s,2,.3,false));assert(r.decay(s,2,.8,false) and s.wanted==2)
  s.flags.evasion_clock=nil;assert(not r.decay(s,100,.8,false) and s.wanted==2)
  local inv=core.create_detached_inventory('reputation_test',{});inv:set_size('main',36)
  local p={pos=a.world_buildings.positions.ada};function p:get_pos()return self.pos end;function p:get_player_name()return 'reputation_test'end
  function p:get_inventory()return inv end;function p:is_player()return true end
  s.wanted=4;inv:add_item('main','mcl_core:gold_ingot 11');assert(not r.fine(p,s) and s.wanted==4 and inv:contains_item('main','mcl_core:gold_ingot 11'))
  inv:add_item('main','mcl_core:gold_ingot');assert(r.fine(p,s) and s.wanted==0 and not inv:contains_item('main','mcl_core:gold_ingot'))
  a.storage:set_string('world_site_v1:red_mesa','1')
  s.flags.choice='evidence';r.show(p);r.receive(p,'harrows_trail:frontier',{claim=true})
  assert(s.flags.contract_red_mesa and inv:contains_item('main','mcl_core:gold_ingot 9'))
  r.show(p);r.receive(p,'harrows_trail:frontier',{claim=true});assert(not inv:contains_item('main','mcl_core:gold_ingot 10'))
  r.show(p);p.pos={x=0,y=0,z=0};r.receive(p,'harrows_trail:frontier',{theft=true});assert(not s.flags.town_theft)
  p.pos=a.world_buildings.positions.ada;r.show(p);r.receive(p,'harrows_trail:frontier',{theft=true});assert(s.flags.town_theft and s.honor==48)
  r.show(p);r.receive(p,'harrows_trail:frontier',{return_goods=true});assert(s.flags.goods_returned and s.nora_trust==5 and s.honor==53)
  -- Existing native hooks survive wrapping; deputies are distinct from protected story characters.
  assert(core.registered_entities['mobs_mc:villager'].receive_damage and core.registered_entities['mobs_mc:horse'].on_rightclick)
  assert(core.registered_entities['harrows_trail:lawman'].on_punch and core.registered_entities['harrows_trail:notice_board'].on_rightclick)
  local hits,removed=0,false
  function p:get_hp()return 20 end;function p:punch()hits=hits+1 end
  local obj={get_pos=function()return p.pos end,remove=function()removed=true end}
  s.wanted=3;r.pursue({object=obj},p);assert(hits==1 and not removed)
  s.wanted=2;r.pursue({object=obj},p);assert(not removed and hits==1)
  p.pos=vector.offset(p.pos,100,0,0);r.pursue({object={get_pos=function()return a.world_buildings.positions.ada end,remove=function()removed=true end}},p);assert(removed)
  p.pos=a.world_buildings.positions.ada
  s.honor=60;s.wanted=0;local guard={object=obj,hits=0}
  local punch=core.registered_entities['harrows_trail:lawman'].on_punch
  punch(guard,p);assert(s.wanted==1 and s.honor==50)
  punch(guard,{is_player=function()return false end,get_luaentity=function()return {_shooter=p}end});assert(s.wanted==2 and s.honor==50)
  s.honor=60;s.nora_trust=60;s.wanted=4;r.event(s,'help','help_once');s.wanted=4
  local text=r.summary(s);assert(not text:find('63') and not text:find('60') and text:find('Wanted: 4'))
  assert(r.poster(s):find('WANTED: ELI'));local book=r.book(s);assert(book:get_name()=='mcl_books:written_book' and book:get_meta():get_string('text'):find('WANTED'))
  s.wanted=0;assert(not r.poster(s):find('WANTED: ELI'));s.wanted=4
  local j,m=a.finale.reasons(s);assert(#j>0 and #m>0 and not s.flags.gold_found)
  a.save('reputation_test')
 end
 core.log('action','[sprint9_test] PASS '..phase);core.request_shutdown('reputation tests complete',false,0)
end)
