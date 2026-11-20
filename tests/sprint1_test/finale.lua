return function(api)
 local finale=api.finale
 for _,kind in ipairs({'mercer','nora','crane','verdict','ending'}) do
  local found=false
  for _,obj in ipairs(core.get_objects_inside_radius(finale.positions[kind],0.5)) do
   local ent=obj:get_luaentity()
   if ent and ent.name=='harrows_trail:finale_actor' and ent.kind==kind then found=true end
  end
  assert(found,'missing finale actor '..kind)
 end
 local inv=core.create_detached_inventory('finale_test',{}); inv:set_size('main',36)
 local p={pos=finale.positions.gate}
 function p:get_player_name() return 'finale_test' end
 function p:get_pos() return self.pos end
 function p:get_inventory() return inv end
 function p:is_player() return true end
 function p:get_wielded_item() return ItemStack('') end
 local counterattacks=0
 function p:punch() counterattacks=counterattacks+1 end
 local actor=assert(core.registered_entities['harrows_trail:finale_actor'])
 local s=api.load('finale_test'); s.flags.arrived=true; s.flags.choice='evidence'; s.flags.ledger1=true; s.flags.ledger2=true
 api.states.finale_test=s
 local form=''; local old=core.show_formspec
 core.show_formspec=function(name,formname,text) if name=='finale_test' then form=text else old(name,formname,text) end end
 local function use(kind,fields)
  p.pos=finale.positions[kind]; finale.interact(kind,p,s)
  if fields then finale.receive(p,'harrows_trail:finale',fields) end
 end
 local function disarm()
  use('crane',{disarm=true}); assert(not s.flags.crane_surrender)
  function p:get_wielded_item() return ItemStack('mcl_core:gold_ingot') end
  actor.on_punch({kind='crane',object={}},p); assert(not s.flags.crane_disarm_hits)
  function p:get_wielded_item() return ItemStack('') end
  actor.on_punch({kind='crane',object={}},p); assert(not s.flags.crane_surrender)
  actor.on_punch({kind='crane',object={}},p); assert(s.flags.crane_surrender)
 end
 for _,id in ipairs({'mcl_core:apple_gold','mcl_armor:chestplate_leather','mcl_bows:crossbow_loaded','mcl_bows:crossbow_loaded_enchanted'}) do assert(core.registered_items[id],id) end
 use('gate',{start=true}); assert(not s.unlocked['9'] and form:find('four golden apples',1,true))
 inv:add_item('main','mcl_core:apple_gold 4')
 local coat=mcl_armor.colorize_leather_armor(ItemStack('mcl_armor:chestplate_leather'),mcl_dyes.colors.brown.rgb); inv:add_item('main',coat)
 inv:add_item('main','mcl_bows:crossbow_loaded'); use('gate',{start=true}); assert(not s.unlocked['9'] and form:find('loaded crossbow',1,true) and inv:contains_item('main','mcl_core:apple_gold 4'))
 inv:remove_item('main','mcl_bows:crossbow_loaded'); local bow=ItemStack('mcl_bows:crossbow_loaded'); bow:get_meta():set_string('arrow','mcl_bows:arrow'); inv:add_item('main',bow)
 use('gate',{start=true}); assert(s.unlocked['9'] and not inv:contains_item('main','mcl_core:apple_gold') and inv:contains_item('main',coat) and inv:contains_item('main',bow))
 inv:add_item('main','mcl_core:apple_gold 4'); use('gate',{start=true}); assert(inv:contains_item('main','mcl_core:apple_gold 4'))
 use('goods',{deed=true}); use('goods',{deed=true}); use('help',{deed=true}); assert(s.honor==58)
 inv:add_item('main','mcl_core:gold_ingot'); use('debt',{deed=true}); use('debt',{deed=true}); assert(s.honor==63 and not inv:contains_item('main','mcl_core:gold_ingot'))
 use('mercer',{spare=true}); assert(not s.flags.mercer_outcome and s.nora_trust==50)
 use('mercer',{cover=true}); assert(s.flags.mercer_surrender); use('mercer',{spare=true}); use('mercer',{spare=true}); assert(s.flags.mercer_outcome=='spared' and s.nora_trust==55)
 use('nora',{promise=true}); use('crane',{capture=true}); assert(not s.flags.crane_outcome); disarm(); use('crane',{capture=true}); assert(s.flags.crane_outcome=='captured' and s.nora_trust==60)
 use('verdict'); assert(form:find('Justice: available',1,true) and form:find('Mercy: available',1,true)); use('verdict',{mercy=true}); assert(s.verdict=='mercy' and s.flags.crane_outcome=='released')
 use('ending'); assert(not form:find('remaining cache',1,true)); assert(finale.epilogue(s):find('undiscovered',1,true))
 s.flags.gold_found=true; use('ending'); assert(form:find('remaining cache',1,true)); use('ending',{ranch=true}); assert(s.flags.gold_choice=='ranch' and finale.epilogue(s):find('rebuild',1,true))
 api.save('finale_test')
 local saved=core.write_json(s)
 s=core.parse_json(saved); api.states.finale_test=s
 for _,outcome in ipairs({'captured','released','killed'}) do
  s.verdict=''; s.flags.crane_outcome=outcome; s.honor=50; s.nora_trust=50
  use('verdict'); assert(form:find('Mercy: locked',1,true)); assert(form:find('standing',1,true) or form:find('trust in town',1,true))
  local j,m=finale.reasons(s); assert((#j==0)==(outcome=='captured')); if outcome=='killed' then assert(#m>0) end
  use('verdict',{justice=true}); assert((s.verdict=='justice')==(outcome=='captured'))
  assert(s.honor==(outcome=='captured' and 55 or 50))
  if outcome=='captured' then use('verdict',{justice=true}); assert(s.honor==55) end
  s.verdict=nil; use('verdict',{vengeance=true}); assert(s.verdict=='vengeance' and s.flags.crane_outcome=='killed')
 end
 for _,choice in ipairs({'release','kill_crane'}) do
  s=api.load('branch_'..choice); api.states.finale_test=s; s.unlocked['9']=true; s.flags.mercer_outcome='spared'; s.flags.nora_freed=true; s.flags.promise_alive=true
  disarm(); use('crane',{[choice]=true})
  assert(s.flags.crane_outcome==(choice=='release' and 'released' or 'killed'))
  assert(s.nora_trust==(choice=='release' and 55 or 45))
  use('verdict'); assert(form:find('Justice: locked',1,true))
  if choice=='kill_crane' then assert(form:find('Crane is dead',1,true)) end
 end
 s.flags.gold_choice='railroad'; assert(finale.epilogue(s):find('railroad',1,true)); s.flags.gold_choice='keep'; assert(finale.epilogue(s):find('rough reputation',1,true))
 for _,v in ipairs({'justice','mercy','vengeance'}) do
  s.verdict=v; s.flags.gold_found=false; use('ending',{scene=true}); local view=form; assert(view:find('model[',1,true))
  if v=='justice' then assert(view:find('ada;',1,true) and view:find('crane;',1,true)) else assert(view:find('mobs_mc_horse.b3d',1,true)) end
 end
 -- Exercise the duel callback without requiring a connected graphical client.
 s=api.load('duel_test'); api.states.finale_test=s; s.unlocked['9']=true
 p.pos=finale.positions.mercer
 counterattacks=0
 local self={kind='mercer',object={}}
 actor.on_punch(self,p); assert(not s.flags.mercer_hits)
 use('mercer',{duel=true}); assert(s.flags.mercer_duel and not s.flags.mercer_outcome)
 actor.on_punch(self,p); actor.on_punch(self,p); assert(s.flags.mercer_hits==2 and counterattacks==2 and not s.flags.mercer_outcome)
 actor.on_punch(self,p); assert(s.flags.mercer_outcome=='killed' and not s.flags.mercer_duel)
 actor.on_punch(self,p); assert(counterattacks==2)
 api.states.duel_test=s; api.save('duel_test')
 -- Restore the state reserved for the restart check after the isolated branch cases.
 api.states.finale_test=core.parse_json(saved); api.save('finale_test')
 core.show_formspec=old
end
