return function(ctx)
 local events={return_goods={5,5,0},help={3,0,0},debt={5,0,0},theft={-5,0,0},horse_theft={-5,0,1},assault={-10,0,0},deputy_assault={-10,0,1},deputy_fight={0,0,1},shoot_town={-10,0,2},bystander_killed={-20,0,0},bystander_shot_dead={-20,0,2},promise_kept={0,5,0},spare={0,5,0},abandon={0,-5,0},prisoner_killed={0,-5,0},evidence={3,0,0},justice={5,0,0},vengeance={0,0,1}}
 local function clamp(n,max) return math.max(0,math.min(max,math.floor(tonumber(n) or 0))) end
 local function normalize(s) s.honor=clamp(s.honor,100);s.nora_trust=clamp(s.nora_trust,100);s.wanted=clamp(s.wanted,4) end
 local function event(s,kind,id)
  local d=assert(events[kind],kind);local key=id and 'consequence_'..id
  if key and s.flags[key] then return false end
  if key then s.flags[key]=true end
  normalize(s);s.honor=clamp(s.honor+d[1],100);s.nora_trust=clamp(s.nora_trust+d[2],100);s.wanted=clamp(s.wanted+d[3],4)
  s.flags.last_consequence=kind
  if d[3]>0 then s.flags.evasion_days=0 end
  return true
 end
 local function price(s,base) return s.honor>=60 and math.max(1,math.ceil(base*2/3)) or s.honor<30 and base*2 or base end
 local function summary(s)
  local standing=s.honor>=60 and 'Trusted on the frontier.' or s.honor<30 and 'Known for trouble; traders charge more.' or 'Your actions are being weighed.'
  local trust=s.nora_trust>=60 and 'Nora trusts you to keep your word.' or s.nora_trust<50 and 'Nora fears the choices you are making.' or 'Nora is watching whether you keep your promises.'
  local cause=({return_goods='You returned stolen goods.',help='You helped a neighbor.',debt='You paid a debt.',theft='You stole goods.',horse_theft='You stole another rider’s horse.',assault='You attacked a townsperson.',deputy_assault='You attacked a deputy.',shoot_town='You shot a townsperson.',bystander_killed='A bystander died by your hand.',bystander_shot_dead='Your shot killed a bystander.',abandon='You chose to abandon a person in danger.',prisoner_killed='You killed a surrendered prisoner.',spare='You spared a surrendering outlaw.',promise_kept='You kept your promise.'})[s.flags.last_consequence] or ''
  return standing..' '..trust..' '..cause..' Wanted: '..s.wanted..' stars. Fine: '..(s.wanted*3)..' gold. A full day and night out of sight removes one star.'
 end
 local function town(pos)
  for id,p in pairs(ctx.towns()) do if vector.distance(pos,p)<36 then return id,p end end
 end
 -- Accumulate only online, unobserved game-days, including time-of-day changes from sleep.
 local function decay(s,day,tod,observed)
  local now=day+tod;local last=s.flags.evasion_clock
  s.flags.evasion_clock=now
  if observed then s.flags.evasion_days=0;return false end
  if not last or now<last or now-last>1.01 then return false end
  s.flags.evasion_days=(s.flags.evasion_days or 0)+(now-last)
  if s.wanted>0 and s.flags.evasion_days>=1-1e-9 then s.wanted=s.wanted-1;s.flags.evasion_days=0;return true end
  return false
 end
 local function reaction(s,in_town,on_road)
  return in_town and s.wanted>=3 and 'deputy' or on_road and s.wanted>=4 and 'hunter' or nil
 end
 local pending={}
 local function rumor(s)
  local lead=not s.flags.station_breached and 'Crane keeps supplies at the Plains depot.' or not s.flags.ledger1 and 'Look beside the mine tracks; Nora leaves signs.' or not s.flags.ledger2 and 'The river ledger names the man who robbed the payroll.' or 'Both pages can clear Samuel. Mercy still asks for trust and a good name.'
  return (s.honor>=60 and 'Jonah shares a trusted witness’s lead: ' or 'Jonah’s public lead: ')..lead
 end
 local function poster(s) return s.wanted>=4 and 'WANTED: ELI HARROW — four stars. Deputies and road hunters seek him. Settle the fine with Ada or evade notice for a full day and night.' or 'Ada’s telegram: pursue Silas Crane. Eli currently has '..s.wanted..' wanted stars. '..rumor(s) end
 local function show(p)
  local s=ctx.states[p:get_player_name()];if not s then return end
  local id=town(p:get_pos());if not id or not ctx.ready(id) then core.chat_send_player(p:get_player_name(),'Visit a town board or the ferry to use frontier services.');return end
  pending[p:get_player_name()]=id
  local text=summary(s)..'\n'..poster(s)..'\nJonah’s private rumor costs '..price(s,3)..' gold; public leads are free.\nExploration contracts pay once after reaching each settlement: Red Mesa 9, Dry Gulch 12, Silver Spur 18, Bitter River 12 gold. Take a claim after following the local story lead.\nRuth’s fallback shop: pickaxe '..price(s,6)..', TNT '..price(s,6)..', blank map '..price(s,3)..', spruce boat '..price(s,3)..' gold (consumed on purchase). Rescue supplies remain at the tunnel. Optional relief work never gates the rescue.'
  core.show_formspec(p:get_player_name(),'harrows_trail:frontier','formspec_version[4]size[12,8]textarea[.4,.3;11.2,4.3;reads;Frontier board;'..core.formspec_escape(text)..']button[.4,4.7;2.5,.7;fine;Pay fine]button[3,4.7;2.5,.7;rumor;Buy private lead]button[5.6,4.7;2.5,.7;document;Take document]button[8.2,4.7;3,.7;claim;Claim contract]button[.4,5.6;2.5,.7;pick;Pickaxe]button[3,5.6;2.5,.7;tnt;TNT]button[5.6,5.6;2.5,.7;map;Blank map]button[8.2,5.6;3,.7;boat;Spruce boat]button[.4,6.5;3,.7;theft;Steal goods (+risk)]button[3.5,6.5;4,.7;return_goods;Return stolen goods]button[7.6,6.5;3.6,.7;abandon;Refuse wagon rescue]button_exit[4,7.3;4,.6;close;Close]')
 end
 local function book(s)
  local stack=ItemStack('mcl_books:written_book');local m=stack:get_meta();m:set_string('title',s.wanted>=4 and 'Wanted: Eli Harrow' or 'Ada’s frontier telegram');m:set_string('author','Sheriff Ada Wells');m:set_string('text',poster(s));m:set_int('generation',0);m:set_int('harrows_trail:notice',1);return stack
 end
 local stock={pick={'mcl_tools:pick_iron',6},tnt={'mcl_tnt:tnt',6},map={'mcl_maps:empty_map',3},boat={'mcl_boats:boat_spruce',3}}
 local function fine(p,s)
  local cost=s.wanted*3;local inv=p:get_inventory()
  if cost==0 then return true end
  if not inv:contains_item('main','mcl_core:gold_ingot '..cost) then return false end
  local before=inv:get_list('main');local paid=inv:remove_item('main','mcl_core:gold_ingot '..cost)
  if paid:get_count()~=cost then inv:set_list('main',before);return false end
  s.wanted=0;s.flags.evasion_days=0;return true
 end
 local function receive(p,form,f)
  if form~='harrows_trail:frontier' then return end
  local name=p:get_player_name();local id=pending[name];pending[name]=nil
  local s=ctx.states[name];if not id or not s or town(p:get_pos())~=id then return end
  local inv=p:get_inventory();local response
  if f.fine then response=fine(p,s) and 'Fine settled. Deputies stand down.' or 'Bring 3 gold per star, or leave town and evade notice for a day and night.'
  elseif f.rumor then
   local cost=price(s,3);if inv:contains_item('main','mcl_core:gold_ingot '..cost) then inv:remove_item('main','mcl_core:gold_ingot '..cost);response=rumor(s)..(s.honor>=60 and ' The witness says Nora ties ribbons to mine timbers.' or ' Build trust and witnesses will share more.') else response='Insufficient gold. The public lead on this board is free.' end
  elseif f.document then
   local found=false;for _,stack in ipairs(inv:get_list('main')) do if stack:get_meta():get_int('harrows_trail:notice')==1 then found=true end end
   response=found and 'Your carried notice is updated automatically.' or ctx.grant(inv,book(s)) and 'Telegram placed in your inventory.' or 'Make inventory room.'
  elseif f.claim then
   local eligible=id=='red_mesa' and s.flags.choice or id=='dry_gulch' and s.flags.arrived or id=='silver_spur' and s.map_fragments['3'] or id=='bitter_river' and s.flags.ledger1
   local rewards={red_mesa=9,dry_gulch=12,silver_spur=18,bitter_river=12};local key='contract_'..id
   if s.flags[key] then response='This contract was already paid.'
   elseif not eligible then response='Follow the local story lead first; your journal names the next step.'
   elseif ctx.grant(inv,ItemStack('mcl_core:gold_ingot '..rewards[id])) then s.flags[key]=true;event(s,'help',key);response='Exploration contract paid. Your help is remembered.' else response='Make inventory room; the contract remains available.' end
  elseif f.theft and not s.flags.town_theft then
   if ctx.grant(inv,ItemStack('mcl_core:gold_ingot 3')) then s.flags.town_theft=true;event(s,'theft','town_goods');response='You stole the town’s goods. Return three gold to make amends.' end
  elseif f.return_goods and s.flags.town_theft and not s.flags.goods_returned then
   if inv:contains_item('main','mcl_core:gold_ingot 3') then inv:remove_item('main','mcl_core:gold_ingot 3');s.flags.goods_returned=true;event(s,'return_goods','town_goods_returned');response='Goods returned. Nora hears that you kept your word.' else response='Bring the three stolen ingots.' end
  elseif f.abandon and not s.flags.wagon_abandoned then
   s.flags.wagon_abandoned=true;event(s,'abandon','wagon');response='You refused to help a stranded wagon crew. Nora hears about the choice; there was no deadline.'
  else
   for key,def in pairs(stock) do if f[key] then
    response=ctx.grant(inv,ItemStack(def[1]),ItemStack('mcl_core:gold_ingot '..price(s,def[2]))) and 'Purchase complete.' or 'Bring '..price(s,def[2])..' gold and make room. Nothing was taken.';break
   end end
  end
  ctx.save(name);if response then core.chat_send_player(name,response) end
 end
 core.register_on_player_receive_fields(receive)
 core.register_chatcommand('frontier',{description='Read the nearby town board, contracts and services',func=function(name)local p=core.get_player_by_name(name);if p then show(p);return true end;return false end})
 local function crime(p,kind)
  if not p or not p:is_player() then return end
  local s=ctx.states[p:get_player_name()];if not s then return end
  event(s,kind);ctx.save(p:get_player_name());core.chat_send_player(p:get_player_name(),summary(s))
 end
 core.register_on_mods_loaded(function()
  -- Wrap pinned native damage/horse callbacks, preserving their return values and riding code.
  local villager=core.registered_entities['mobs_mc:villager'];local damage,death=villager.receive_damage,villager.on_die
  villager.receive_damage=function(self,reason,amount)
   local result=damage(self,reason,amount)
   if result and self.health>0 and reason.source and reason.source:is_player() then crime(reason.source,reason.type=='arrow' and 'shoot_town' or 'assault') end
   return result
  end
  villager.on_die=function(self,killer,reason)
   if reason and reason.source then crime(reason.source,reason.type=='arrow' and 'bystander_shot_dead' or 'bystander_killed') end
   return death(self,killer,reason)
  end
  local horse=core.registered_entities['mobs_mc:horse'];local click=horse.on_rightclick
  horse.on_rightclick=function(self,p)
   local owner=self.owner;local result=click(self,p)
   if self.driver==p and owner and owner~='' and owner~=p:get_player_name() and not self._trail_theft_reported then self._trail_theft_reported=true;crime(p,'horse_theft') end
   return result
  end
  for _,id in ipairs({'opening_actor','mid_actor'}) do
   local def=core.registered_entities['harrows_trail:'..id];local punch=def.on_punch
   def.on_punch=function(self,p,...)
    local arrow=p and not p:is_player() and p:get_luaentity()
    local shooter=arrow and arrow._shooter
    if shooter then crime(shooter,'shoot_town')
    elseif self.role~='jesse' or self.kind=='jesse' then crime(p,'assault') end
    if punch then return punch(self,p,...) end;return true
   end
  end
 end)
 core.register_entity('harrows_trail:notice_board',{
  initial_properties={physical=false,pointable=true,visual='cube',visual_size={x=1,y=.8,z=.1},textures={'mcl_core_planks_spruce.png','mcl_core_planks_spruce.png','default_bookshelf.png','default_bookshelf.png','default_bookshelf.png','default_bookshelf.png'},static_save=false},
  on_rightclick=function(_,p)show(p)end,
 })
 local boards,law={},{ }
 local function pursue(ent,p)
  local here=ent.object:get_pos();local s=ctx.states[p:get_player_name()]
  if not s or vector.distance(here,p:get_pos())>24 or p:get_hp()<=0 or ent.hunter and s.wanted<4 then ent.object:remove();return end
  if s.wanted==0 then ent.provoked=nil end
  if not ent.hunter and s.wanted<3 and not ent.provoked then return end
  if vector.distance(here,p:get_pos())<2 then p:punch(ent.object,1,{full_punch_interval=1,damage_groups={fleshy=2}},nil);return end
  local path=core.find_path(vector.round(here),vector.round(p:get_pos()),20,1,1,'A*_noprefetch')
  if path and path[2] and ctx.cast.safe(path[2]) then ent.object:move_to(path[2],true);ent.object:set_yaw(core.dir_to_yaw(vector.direction(here,p:get_pos()))) end
 end
 core.register_entity('harrows_trail:lawman',{
  initial_properties={physical=false,pointable=true,visual='mesh',mesh='mcl_armor_character.b3d',textures={'harrows_ada.png^[colorize:#746b5c:100','blank.png','blank.png'},collisionbox={-.3,-.5,-.3,.3,1.3,.3},selectionbox={-.3,-.5,-.3,.3,1.3,.3},static_save=false},
  on_activate=function(self,data)self.target=data;self.object:set_armor_groups({immortal=1});self.object:set_animation({x=0,y=79},20,0,true)end,
  on_punch=function(self,p)
   if p and not p:is_player() then local projectile=p:get_luaentity();p=projectile and projectile._shooter end
   if p and p:is_player() then if not self.hunter then
     local s=ctx.states[p:get_player_name()]
     crime(p,(self.provoked or s and s.wanted>=3) and 'deputy_fight' or 'deputy_assault');self.provoked=true
    end;self.hits=(self.hits or 0)+1;if self.hits>=3 then self.object:remove() end end;return true
  end,
  on_rightclick=function(_,p)show(p)end,
 })
 local elapsed=0
 core.register_globalstep(function(dt)
  elapsed=elapsed+dt;if elapsed<4 then return end;elapsed=0
  for _,p in ipairs(core.get_connected_players()) do
   local name=p:get_player_name();local s=ctx.states[name]
   if s then
    local id,center=town(p:get_pos());if id and not ctx.ready(id) then id=nil;center=nil end;local observed=id~=nil
    local obj=law[name];if obj and not obj:get_pos() then law[name]=nil;obj=nil end
    if obj then observed=observed or vector.distance(obj:get_pos(),p:get_pos())<16;pursue(obj:get_luaentity(),p) end
    if s.wanted>0 then decay(s,core.get_day_count(),core.get_timeofday(),observed);ctx.save(name) else s.flags.evasion_clock=core.get_day_count()+core.get_timeofday() end
    local response=reaction(s,id,not id and s.wanted>=4 and ctx.road(p:get_pos()))
    if not obj and (id or response=='hunter' and s.flags.hunter_day~=core.get_day_count()) then
     local spawn=center and vector.offset(center,1,0,1) or vector.offset(vector.round(p:get_pos()),3,0,0)
     if ctx.cast.safe(spawn) then
      obj=core.add_entity(spawn,'harrows_trail:lawman',name);law[name]=obj
      if obj and not id then s.flags.hunter_day=core.get_day_count();ctx.save(name);local ent=obj:get_luaentity();ent.hunter=true;obj:set_properties({textures={'harrows_mercer.png^[colorize:#88714a:100','blank.png','blank.png'}}) end
     end
    end
    for site,pos in pairs(ctx.board_positions()) do
     if ctx.ready(site) and vector.distance(pos,p:get_pos())<48 and not boards[site] then boards[site]=core.add_entity(pos,'harrows_trail:notice_board') end
     local b=boards[site];if b and not b:get_pos() then boards[site]=nil elseif b then local tile=s.wanted>=4 and 'default_paper.png' or 'default_bookshelf.png';b:set_properties({textures={'mcl_core_planks_spruce.png','mcl_core_planks_spruce.png',tile,tile,tile,tile}}) end
    end
    local inv=p:get_inventory();for index,stack in ipairs(inv:get_list('main')) do if stack:get_meta():get_int('harrows_trail:notice')==1 then inv:set_stack('main',index,book(s)) end end
   end
  end
 end)
 core.register_on_joinplayer(function(p) local s=ctx.states[p:get_player_name()];if s then s.flags.evasion_clock=nil end end)
 core.register_on_leaveplayer(function(p) local name=p:get_player_name();pending[name]=nil;local s=ctx.states[name];if s then s.flags.evasion_clock=nil end;if law[name] and law[name]:get_pos() then law[name]:remove() end;law[name]=nil end)
 return {events=events,event=event,normalize=normalize,price=price,summary=summary,reaction=reaction,town=town,decay=decay,fine=fine,poster=poster,show=show,receive=receive,book=book,crime=crime,pursue=pursue}
end
