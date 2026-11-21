return function(ctx)
local rep=ctx.reputation
local chapter, states, save, storage = ctx.chapter, ctx.states, ctx.save, ctx.storage
local positions = {
 gate={x=264,y=221,z=0}, supplies={x=266,y=221,z=-4}, goods={x=268,y=221,z=4},
 help={x=271,y=221,z=4}, debt={x=274,y=221,z=4}, mercer={x=280,y=221,z=0},
 nora={x=287,y=221,z=0}, crane={x=294,y=221,z=0}, verdict={x=301,y=221,z=0}, ending={x=308,y=221,z=0},
}
local pending={}
local function show(p,kind,title,text,choices)
 pending[p:get_player_name()]=kind
 local buttons=''
 for i,c in ipairs(choices or {}) do
  buttons=buttons..'button['..(0.3+(i-1)*3.2)..',5;3,0.7;'..c[1]..';'..core.formspec_escape(c[2])..']'
 end
 core.show_formspec(p:get_player_name(),'harrows_trail:finale','formspec_version[4]size[10,6]label[0.5,0.4;'..core.formspec_escape(title)..']textarea[0.5,1;9,3.8;;;'..core.formspec_escape(text)..']'..buttons..(buttons=='' and 'button_exit[3.5,5;3,0.7;close;Close]' or ''))
end
local function journal(s)
 if ctx.late and ctx.late() then
  if not s.unlocked['9'] then return 'Follow the hill trail to Widowmaker’s supported stone entrance. '..chapter.gates[9].text..' Ruth’s supply desk and travelers offering optional help are near the entrance.' end
  if not s.flags.mercer_outcome then return 'Meet Mercer in the first tunnel chamber. Talk him down or face him in a duel.' end
  if not s.flags.nora_freed then return 'Mercer no longer blocks the way. Free Nora further inside the tunnel.' end
  if not s.flags.crane_outcome then return 'Confront Crane at the back of the tunnel, disarm him, and decide his fate.' end
  if not s.verdict or s.verdict=='' then return 'Return along the trail to Ada at Red Mesa’s sheriff’s office. Tell her Crane’s fate and decide the verdict.' end
  return 'Speak to Ada at Red Mesa’s sheriff’s office to settle the optional cache and read the epilogue.'
 end
 if not s.unlocked['9'] then return 'Follow the trail east to Widowmaker Tunnel. '..chapter.gates[9].text..' Ruth’s supply desk there offers replacements for gold. Three nearby one-time good deeds can improve your standing.' end
 if not s.flags.mercer_outcome then return 'Meet Mercer at the tunnel. Force him to surrender or face him in a duel.' end
 if not s.flags.nora_freed then return 'Mercer no longer blocks the way. Free Nora at the next marker.' end
 if not s.flags.crane_outcome then return 'Speak with Crane beyond Nora. Force his surrender and decide his fate.' end
 if not s.verdict or s.verdict=='' then return 'Go to the verdict marker beyond Crane. Your choice and its requirements are explained there.' end
 if s.flags.gold_found and not s.flags.gold_choice then return 'At the ending marker, decide what to do with the recovered cache.' end
 return 'Visit the ending marker to read the epilogue and see the final scene.'
end
local function reasons(s)
 local j,m={},{}
 if s.flags.crane_outcome~='captured' then j[#j+1]='Crane must be captured alive' end
 if s.honor<50 then j[#j+1]='earn a better standing' end
 if s.flags.crane_outcome=='killed' then m[#m+1]='Crane is dead' end
 if s.honor<60 then m[#m+1]='earn greater trust in town' end
 if not (s.flags.ledger1 and s.flags.ledger2) then m[#m+1]='find both ledger pages' end
 if s.nora_trust<60 then m[#m+1]='rebuild Nora’s trust by keeping your promise and sparing a surrendering Mercer' end
 return j,m
end
local function epilogue(s)
 local t=({justice='Ada takes Crane into custody. In Red Mesa, the ledger is read at his trial and Eli’s standing rises.', mercy='Crane rides into the badlands, perhaps to return. Nora agrees to let him go; Eli and Nora head home toward the ranch.', vengeance='Crane dies in the tunnel. Word of the killing spreads and Eli rides alone under a red sky.'})[s.verdict] or ''
 local gold=({railroad=' The recovered cache returns to the railroad, strengthening the case for justice.', keep=' Eli keeps the cache; Red Mesa remembers his rough reputation.', ranch=' The recovered cache helps rebuild the Harrow ranch.'})[s.flags.gold_choice] or ' The hidden cache was left undiscovered.'
 local trust=s.nora_trust>=60 and ' Nora trusts Eli’s word and hopes they can build a future together.' or ' Nora remains uncertain of Eli’s choices and needs time to trust him.'
 return t..gold..trust
end
local function scene(s)
 local function model(role) return 'mcl_armor_character.b3d;'..core.formspec_escape(ctx.skin(role))..';0,180;false;false;0,0]' end
 local eli='model[0.6,1;1.5,3;eli;'..model('eli_duster')
 local nora='model[2.2,1;1.5,3;nora;'..model('nora')
 if s.verdict=='justice' then
  return 'label[0.4,0.3;Red Mesa courthouse: Ada reads the verdict]'..eli..nora..
   'model[4.1,1;1.5,3;ada;'..model('ada')..'model[5.8,1;1.5,3;crane;'..model('crane')
 end
 local horse='mobs_mc_horse.b3d;blank.png,mobs_mc_horse_brown.png,blank.png;0,180;false;false;0,0]'
 if s.verdict=='mercy' then
  return 'label[0.4,0.3;Eli and Nora take the trail home]'..eli..nora..
   'model[4,1;2,3;horse1;'..horse..'model[6,1;2,3;horse2;'..horse
 end
 return 'label[0.4,0.3;Eli rides alone under a red sky]'..eli..'model[3,1;3,3;horse;'..horse
end
local function interact(kind,p,s)
 local f=s.flags
 if kind=='gate' then
  if not f.ledger2 then return show(p,kind,'Widowmaker Tunnel','Find the second ledger page at Bitter River before following Nora here.') end
  if s.unlocked['9'] then return show(p,kind,'Widowmaker Tunnel','The tunnel is open. Find Mercer east; your supplies were already handed over.') end
  return show(p,kind,'Widowmaker Tunnel',chapter.gates[9].text..' Check your main inventory: brown dye must be applied to a leather tunic, and the crossbow must contain an arrow. No items are taken unless you confirm and all requirements are met.',{{'start','Start rescue'}})
 elseif kind=='supplies' then
  local apples,duster,bow=rep.price(s,12),rep.price(s,6),rep.price(s,6)
  return show(p,kind,'Ruth’s rescue supplies','Fallback orders consume gold once per purchase. Make inventory room first. One-time frontier contracts fund the rescue; use /frontier in town.',{{'apples','Apples: '..apples..' gold'},{'duster','Duster: '..duster..' gold'},{'bow','Crossbow: '..bow..' gold'}})
 elseif kind=='goods' or kind=='help' or kind=='debt' then
  local label=({goods='Return stolen goods to their owner',help='Help a townsperson repair a wagon',debt='Pay a townsperson’s debt of one gold ingot'})[kind]
  if f['honor_'..kind] then return show(p,kind,'A good deed','You already helped here. Your standing benefited once.') end
  return show(p,kind,'A good deed',label..'. This is optional and can be done once.',{{'deed','Help'}})
 elseif kind=='mercer' then
  if not s.unlocked['9'] then return show(p,kind,'Mercer','Prepare at the tunnel entrance first.') end
  if f.mercer_outcome then return show(p,kind,'Mercer',f.mercer_outcome=='spared' and 'Mercer keeps his hands raised and lets you pass. Nora saw you spare him; her trust has improved. Nora is east.' or (f.mercer_trust_lost and 'You killed Mercer after he surrendered; Nora’s trust has fallen. Nora is east.' or 'Mercer is defeated. Nora is east.')) end
  if f.mercer_surrender then return show(p,kind,'Mercer surrenders','Mercer drops his weapon and raises both hands. He explicitly surrenders. Spare him or kill him.',{{'spare','Spare Mercer'},{'kill_mercer','Kill Mercer'}}) end
  if f.mercer_duel then return show(p,kind,'Duel with Mercer','Mercer refuses to yield. Strike him to win the duel, or talk him down before he falls.',{{'cover','Talk him down'}}) end
  return show(p,kind,'Mercer at Widowmaker','Mercer bars the tunnel. Offer him a way out or challenge him to a duel.',{{'cover','Talk him down'},{'duel','Challenge Mercer'}})
 elseif kind=='nora' then
  if not f.mercer_outcome then return show(p,kind,'Nora','Mercer blocks the way. Resolve his encounter first.') end
  if not f.nora_freed then return show(p,kind,'Nora','Nora is bound beside the tunnel. Free her. You may promise to bring Crane back alive; keeping that promise earns her trust.',{{'promise','Free; promise alive'},{'free','Free Nora'}}) end
  return show(p,kind,'Nora',(f.promise_alive and 'Nora is free. She remembers your promise to bring Crane back alive.' or 'Nora is free. Crane is ahead; she watches what you choose.')..(s.nora_trust>=60 and ' I trust your word, Eli.' or s.nora_trust<50 and ' Eli, I am afraid of what this is doing to you.' or ' Keep your promises, Eli.'))
 elseif kind=='crane' then
  if not f.nora_freed then return show(p,kind,'Crane','Free Nora before confronting Crane.') end
  if f.crane_outcome then return show(p,kind,'Crane','Crane’s recorded fate: '..f.crane_outcome..'. '..(f.promise_trust and 'You kept your promise; Nora trusts you more. ' or f.crane_trust_lost and 'You killed a surrendered prisoner; Nora’s trust has fallen. ' or '')..'Go east to decide the verdict.') end
  if not f.crane_surrender then
   if f.crane_disarm_started then return show(p,kind,'Crane','Close in and strike Crane twice with an empty hand to disarm him. He must surrender before his fate is decided.') end
   return show(p,kind,'Crane','Crane reaches for his weapon. Close in and disarm him without a shot; he must surrender before his fate is decided.',{{'disarm','Close in'}})
  end
  return show(p,kind,'Crane surrenders','Crane drops his weapon and yields. He is alive and unarmed. Restrain him for trial, release him, or kill him.',{{'capture','Capture alive'},{'release','Release alive'},{'kill_crane','Kill Crane'}})
 elseif kind=='verdict' then
  if not f.crane_outcome then return show(p,kind,'The verdict','Free Nora and resolve Crane’s surrender first.') end
  if s.verdict and s.verdict~='' then return show(p,kind,'The verdict','Your verdict is recorded. Go east to the ending marker.') end
  local j,m=reasons(s)
  local text='Justice: '..(#j==0 and 'available — Ada will take Crane for trial.' or 'locked — '..table.concat(j,'; ')..'.')..'\nMercy: '..(#m==0 and 'available — Crane rides free with Nora’s agreement.' or 'locked — '..table.concat(m,'; ')..'.')..'\nVengeance: available — Crane dies; your wanted level rises and Eli rides alone.'
  local choices={}; if #j==0 then choices[#choices+1]={'justice','Justice'} end; if #m==0 then choices[#choices+1]={'mercy','Mercy'} end; choices[#choices+1]={'vengeance','Vengeance'}
  return show(p,kind,'The verdict',text,choices)
 elseif kind=='ending' then
  if not s.verdict or s.verdict=='' then return show(p,kind,'Epilogue','Decide Crane’s verdict first.') end
  if f.gold_found and not f.gold_choice then return show(p,kind,'The recovered cache','What should become of the remaining cache? This choice is independent of the verdict.',{{'railroad','Return to railroad'},{'keep_gold','Keep the gold'},{'ranch','Rebuild ranch'}}) end
  pending[p:get_player_name()]=kind
  core.show_formspec(p:get_player_name(),'harrows_trail:finale','formspec_version[4]size[10,6]label[0.5,0.4;Epilogue]textarea[0.5,1;9,3.8;;;'..core.formspec_escape(epilogue(s))..']button[2,5;3,0.7;scene;See final scene]button_exit[5.2,5;3,0.7;close;Close]')
  return
 end
end
local function receive(p,form,fields)
 if form~='harrows_trail:finale' then return end
 local name=p:get_player_name(); local kind=pending[name]; local s=states[name]
 if not kind or not s or vector.distance(p:get_pos(),positions[kind])>8 then return end
 pending[name]=nil
 local f=s.flags; local inv=p:get_inventory()
 if kind=='ending' and fields.scene and s.verdict and s.verdict~='' then
  core.show_formspec(name,'harrows_trail:finale','formspec_version[4]size[9,6]'..scene(s)..'button_exit[3,5;3,0.7;close;Close]')
  return
 end
 if kind=='gate' and fields.start and f.ledger2 and not s.unlocked['9'] then
  if chapter.unlock(p,s,9) then save(name); return show(p,kind,'Widowmaker Tunnel','Four apples handed over once. Your duster and crossbow remain yours. Meet Mercer east.') end
  local missing={}; if not inv:contains_item('main','mcl_core:apple_gold 4') then missing[#missing+1]='four golden apples' end
  local d,b=false,false
  for _,v in ipairs(inv:get_list('main')) do local n=v:get_name(); if n=='mcl_armor:chestplate_leather' and v:get_meta():get_string('mcl_armor:color'):lower():sub(1,7)==mcl_dyes.colors.brown.rgb then d=true end; if (n=='mcl_bows:crossbow_loaded' or n=='mcl_bows:crossbow_loaded_enchanted') and v:get_meta():get_string('arrow')~='' then b=true end end
  if not d then missing[#missing+1]='brown-dyed leather tunic' end; if not b then missing[#missing+1]='loaded crossbow with an arrow' end
  return show(p,kind,'Missing rescue supplies','Still needed: '..table.concat(missing,', ')..'. Nothing was consumed. '..chapter.gates[9].text)
 elseif kind=='supplies' and (fields.apples or fields.duster or fields.bow) then
  local item,price
  if fields.apples then item=ItemStack('mcl_core:apple_gold 4'); price=12
  elseif fields.duster then item=mcl_armor.colorize_leather_armor(ItemStack('mcl_armor:chestplate_leather'),mcl_dyes.colors.brown.rgb); price=6
  else item=ItemStack('mcl_bows:crossbow_loaded'); item:get_meta():set_string('arrow','mcl_bows:arrow'); price=6 end
  price=rep.price(s,price)
  return show(p,kind,'Ruth’s rescue supplies',ctx.grant(inv,item,ItemStack('mcl_core:gold_ingot '..price)) and 'Purchase complete. The equipment is ready.' or 'Need enough gold and inventory room. Nothing was taken.')
 elseif (kind=='goods' or kind=='help' or kind=='debt') and fields.deed and not f['honor_'..kind] then
  if kind=='debt' and not inv:contains_item('main','mcl_core:gold_ingot') then return show(p,kind,'A good deed','Bring one gold ingot to pay the debt. Nothing was taken.') end
  if kind=='debt' then inv:remove_item('main','mcl_core:gold_ingot') end
  f['honor_'..kind]=true; rep.event(s,({goods='return_goods',help='help',debt='debt'})[kind],'tunnel_'..kind); save(name)
  return show(p,kind,'A good deed','Your help improves your standing in town. This opportunity cannot be repeated.')
 elseif kind=='mercer' and s.unlocked['9'] and not f.mercer_outcome then
  if fields.cover then f.mercer_surrender=true
  elseif fields.duel and not f.mercer_surrender then f.mercer_duel=true
  elseif fields.spare and f.mercer_surrender then f.mercer_outcome='spared'; if not f.mercer_trust then f.mercer_trust=true; rep.event(s,'spare','mercer_spared') end
  elseif fields.kill_mercer and f.mercer_surrender then f.mercer_outcome='killed'; rep.event(s,'prisoner_killed','mercer_killed'); f.mercer_trust_lost=true end
 elseif kind=='nora' and f.mercer_outcome and not f.nora_freed and (fields.promise or fields.free) then
  f.nora_freed=true; f.promise_alive=fields.promise and true or nil
 elseif kind=='crane' and f.nora_freed and not f.crane_outcome then
  if fields.disarm then f.crane_disarm_started=true
  elseif f.crane_surrender and (fields.capture or fields.release or fields.kill_crane) then
   f.crane_outcome=fields.capture and 'captured' or fields.release and 'released' or 'killed'
   if f.crane_outcome=='killed' then rep.event(s,'prisoner_killed','crane_killed'); f.crane_trust_lost=true end
   if f.promise_alive and f.crane_outcome~='killed' and not f.promise_trust then f.promise_trust=true; rep.event(s,'promise_kept','promise_alive') end
  end
 elseif kind=='verdict' and f.crane_outcome and (not s.verdict or s.verdict=='') then
  local j,m=reasons(s)
  if fields.justice and #j==0 then s.verdict='justice'; rep.event(s,'justice','justice')
  elseif fields.mercy and #m==0 then s.verdict='mercy'; f.crane_outcome='released'
  elseif fields.vengeance then s.verdict='vengeance'; if f.crane_outcome~='killed' and not f.crane_trust_lost then rep.event(s,'prisoner_killed','crane_killed'); f.crane_trust_lost=true end; f.crane_outcome='killed'; rep.event(s,'vengeance','vengeance') end
  if s.verdict then s.unlocked['10']=true; s.act=10 end
 elseif kind=='ending' and s.verdict and f.gold_found and not f.gold_choice then
  if fields.railroad then f.gold_choice='railroad' elseif fields.keep_gold then f.gold_choice='keep' elseif fields.ranch then f.gold_choice='ranch' end
 end
 save(name)
 return interact(kind,p,s)
end
core.register_on_player_receive_fields(receive)
core.register_on_leaveplayer(function(p) pending[p:get_player_name()]=nil end)
-- The existing node names remain as invisible anchors, including in older saves.
local cast = {mercer=true, nora=true, crane=true, verdict=true, ending=true}
local function ensure_actor(pos, kind)
 for _, obj in ipairs(core.get_objects_inside_radius(pos, 4)) do
  local ent = obj:get_luaentity()
  if ent and ent.name == 'harrows_trail:finale_actor' and ent.kind == kind then return end
 end
 core.add_entity(pos, 'harrows_trail:finale_actor', kind)
end
core.register_entity('harrows_trail:finale_actor', {
 initial_properties = {physical=false, pointable=true, visual='mesh', mesh='mcl_armor_character.b3d',
  textures={'character.png','blank.png','blank.png'}, visual_size={x=1,y=1},
  collisionbox={-0.3,-0.5,-0.3,0.3,1.3,0.3}, selectionbox={-0.3,-0.5,-0.3,0.3,1.3,0.3}, static_save=false},
 on_activate=function(self, data)
  if not cast[data] then self.object:remove(); return end
  self.kind=data; self.object:set_armor_groups({immortal=1})
 end,
 on_step=function(self, dtime)
  if self.kind~='mercer' and self.kind~='crane' then return end
  self.elapsed=(self.elapsed or 0)+dtime
  if self.elapsed<1 then return end
  self.elapsed=0
  local raised=false
  for _,player in ipairs(core.get_connected_players()) do
   local s=states[player:get_player_name()]
   if s and vector.distance(player:get_pos(),self.object:get_pos())<12 then
    local f=s.flags
    raised=self.kind=='mercer' and f.mercer_surrender and f.mercer_outcome~='killed'
     or self.kind=='crane' and f.crane_surrender and f.crane_outcome~='killed'
    break
   end
  end
  raised=not not raised
  if self.raised~=raised then
   local pose=raised and {rotation={vec={x=math.pi,y=0,z=0}}} or nil
   self.object:set_bone_override('Arm_Right_Pitch_Control',pose)
   self.object:set_bone_override('Arm_Left_Pitch_Control',pose)
   self.raised=raised
  end
 end,
 on_rightclick=function(self, player)
  local s=states[player:get_player_name()]
  if s then interact(self.kind,player,s) end
 end,
 on_punch=function(self, player)
  if not player or not player:is_player() then return true end
  local name=player:get_player_name(); local s=states[name]
  if not s then return true end
  local f=s.flags
  if self.kind=='mercer' and s.unlocked['9'] and f.mercer_duel and not f.mercer_surrender and not f.mercer_outcome then
   f.mercer_hits=(f.mercer_hits or 0)+1
   if f.mercer_hits>=3 then
    f.mercer_outcome='killed'; f.mercer_duel=nil
    core.chat_send_player(name,'Mercer falls. Nora is ahead.')
   else
    player:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=2}},nil)
    core.chat_send_player(name,'Mercer fights back. Strike again or speak to him to seek surrender.')
   end
   save(name)
  elseif self.kind=='crane' and f.nora_freed and f.crane_disarm_started and not f.crane_surrender and not f.crane_outcome then
   if not player:get_wielded_item():is_empty() then
    core.chat_send_player(name,'Put your weapon away to disarm Crane without killing him.')
    return true
   end
   f.crane_disarm_hits=(f.crane_disarm_hits or 0)+1
   if f.crane_disarm_hits>=2 then
    f.crane_surrender=true; f.crane_disarm_started=nil
    core.chat_send_player(name,'Crane drops his weapon and surrenders. Speak to him to decide his fate.')
   else
    player:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=1}},nil)
    core.chat_send_player(name,'Crane struggles. Disarm him with another empty-handed strike.')
   end
   save(name)
  end
  return true
 end,
})
core.register_lbm({name='harrows_trail:finale_actors', nodenames={'harrows_trail:finale_mercer','harrows_trail:finale_nora','harrows_trail:finale_crane','harrows_trail:finale_verdict','harrows_trail:finale_ending'},
 run_at_every_load=true, action=function(pos,node) ensure_actor(pos,node.name:match('finale_(.+)$')) end})
for kind,pos in pairs(positions) do
 local character=kind=='mercer' or kind=='nora' or kind=='crane' or kind=='verdict' or kind=='ending'
 local texture=kind=='gate' and 'default_stone.png' or kind=='supplies' and 'mcl_barrels_barrel_side.png' or 'default_bookshelf.png'
 core.register_node('harrows_trail:finale_'..kind,{description=kind..' (right-click)',
  tiles={texture}, drawtype=character and 'airlike' or 'normal',
  pointable=not character, walkable=not character, paramtype='light', groups={unbreakable=1}, diggable=false,
  on_construct=function(pos) if character then ensure_actor(pos,kind) end end,
  on_rightclick=function(_,_,p) local s=states[p:get_player_name()]; if s then interact(kind,p,s) end; return p:get_wielded_item() end})
end
local building=false
local function ensure()
 if building or storage:get_string('sprint4_site')=='1' then return end
 if ctx.late and ctx.late() then storage:set_string('sprint4_site','1');return end
 building=true
 core.emerge_area({x=261,y=220,z=-7},{x=312,y=225,z=7},function(_,action,left)
  if action==core.EMERGE_ERRORED or action==core.EMERGE_CANCELLED then building=false; return end
  if left~=0 then return end
  local layout={}
  for x=261,312 do for z=-7,7 do layout[#layout+1]={pos={x=x,y=220,z=z},name='harrows_trail:floor'} end end
  for k,pos in pairs(positions) do layout[#layout+1]={pos=pos,name='harrows_trail:finale_'..k,label=k} end
  for _,e in ipairs(layout) do local n=core.get_node(e.pos).name; if n~='air' and n~=e.name then core.log('error','[harrows_trail] Sprint 4 site occupied; preserved'); building=false; return end end
  for _,e in ipairs(layout) do core.set_node(e.pos,{name=e.name}); if e.label then core.get_meta(e.pos):set_string('infotext',e.label..' (right-click)') end end
  storage:set_string('sprint4_site','1'); building=false
 end)
end
core.register_on_joinplayer(ensure)
local function ensure_actors()
 for kind,pos in pairs(positions) do
  local node=core.get_node_or_nil(pos)
  if cast[kind] and node and node.name=='harrows_trail:finale_'..kind then ensure_actor(pos,kind) end
 end
end
return {positions=positions,interact=interact,receive=receive,journal=journal,reasons=reasons,epilogue=epilogue,scene=scene,ensure=ensure,ensure_actors=ensure_actors}
end
