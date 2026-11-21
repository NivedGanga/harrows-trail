return function(ctx)
local states, save, storage, message = ctx.states, ctx.save, ctx.storage, ctx.message
local gold, block, lantern = 'mcl_core:gold_ingot', 'mcl_core:goldblock', 'mcl_lanterns:lantern_floor'
local gates = {
 [2]={text='Ride your owned, tamed, saddled horse; saddle retained.', validator=ctx.riding},
 [3]={text='Bail consumes 9 gold ingots OR 1 gold block once.', alternatives={{item=gold,count=9,consume=true},{item=block,count=1,consume=true}}},
 [4]={text='Carry 4 lanterns; all lanterns are retained.', alternatives={{item=lantern,count=4,consume=false}}},
 [5]={text='Carry an iron pickaxe; it is retained.', alternatives={{item='mcl_tools:pick_iron',count=1}}},
 [6]={text='Starting the breach consumes 1 TNT once.', alternatives={{item='mcl_tnt:tnt',count=1,consume=true}}},
 [7]={text='Carry a filled map covering the Dry Gulch badlands; it is retained.', validator=function(p)
  for _,stack in ipairs(p:get_inventory():get_list('main')) do
   if stack:get_name()=='mcl_maps:filled_map' then
    local meta=stack:get_meta(); local lo=core.string_to_pos(meta:get_string('mcl_maps:minp')); local hi=core.string_to_pos(meta:get_string('mcl_maps:maxp'))
    local x,z=125,0
    if ctx.midgame and ctx.midgame() then x,z=560,844 end
    if meta:get_string('mcl_maps:id')~='' and lo and hi and lo.x<=x and hi.x>=x and lo.z<=z and hi.z>=z then return true end
   end
  end
  return false
 end},
 [8]={text='Carry a spruce boat; it is retained.', alternatives={{item='mcl_boats:boat_spruce',count=1}}},
 [9]={text='Hand over 4 golden apples once; carry a brown-dyed leather tunic and a loaded crossbow. The duster and crossbow are retained.', requirements={{item='mcl_core:apple_gold',count=4,consume=true}}, validator=function(p)
  local duster, bow=false,false
  for _,stack in ipairs(p:get_inventory():get_list('main')) do
   local n=stack:get_name()
   if n=='mcl_armor:chestplate_leather' and stack:get_meta():get_string('mcl_armor:color'):lower():sub(1,7)==mcl_dyes.colors.brown.rgb then duster=true end
   if (n=='mcl_bows:crossbow_loaded' or n=='mcl_bows:crossbow_loaded_enchanted') and stack:get_meta():get_string('arrow')~='' then bow=true end
  end
  return duster and bow
 end},
}
local function unlock(player,s,id)
 if s.unlocked[tostring(id)] then return true end
 local gate=gates[id]
 if gate.validator and not gate.validator(player) then return false end
 if gate.requirements then
  local inv=player:get_inventory()
  for _,r in ipairs(gate.requirements) do if not inv:contains_item('main',r.item..' '..r.count) then return false end end
  for _,r in ipairs(gate.requirements) do if r.consume then inv:remove_item('main',r.item..' '..r.count) end end
 elseif gate.alternatives then
  local inv=player:get_inventory(); local found
  for _,r in ipairs(gate.alternatives) do if inv:contains_item('main',r.item..' '..r.count) then found=r; break end end
  if not found then return false end
  if found.consume then inv:remove_item('main',found.item..' '..found.count) end
 end
 s.unlocked[tostring(id)]=true; s.act=math.max(s.act,id); save(player:get_player_name()); return true
end
local positions={recovery={x=3,y=221,z=-6}, delivery={x=-5,y=221,z=6}, depot={x=10,y=221,z=6},
 ada={x=55,y=221,z=0}, jesse={x=59,y=221,z=5}, cache={x=49,y=221,z=-5},
 ruth={x=62,y=221,z=-5}, dust={x=70,y=221,z=0},
 exposed={x=90,y=221,z=0}, shelter1={x=80,y=221,z=18}, shelter2={x=105,y=221,z=18},
 ruth_gulch={x=130,y=221,z=-5}, gulch={x=125,y=221,z=0}, dutch={x=130,y=221,z=5}}
local more={pass={x=143,y=221,z=0}, rubble1={x=153,y=221,z=-2}, rubble2={x=160,y=221,z=2}, assay={x=170,y=221,z=0}, cartography={x=170,y=221,z=-5}, gold_cache={x=176,y=221,z=-5}, station={x=185,y=221,z=0}, charge={x=193,y=221,z=0}, mine_gate={x=205,y=221,z=0}, mine_clue={x=212,y=221,z=-3}, ledger1={x=220,y=221,z=0}, ferry={x=230,y=221,z=0}, snag={x=237,y=221,z=4}, hideout={x=246,y=221,z=0}, ledger2={x=254,y=221,z=0}}
for k,v in pairs(more) do positions[k]=v end
local pending={}
local function buttons(a,b) return 'button[0.5,5;4.2,0.7;'..a..']'..(b and 'button[5.1,5;4.2,0.7;'..b..']' or '') end
local function prompt(p,kind,text,a,b)
 pending[p:get_player_name()]=kind; message(p,kind,text,buttons(a,b))
end
local function ada(p,s,reaction)
 if s.flags.jesse_free then message(p,'Ada Wells','Jesse is free. Speak with him at the jail door. '..(s.flags.arrived and 'You reached Dry Gulch.' or 'Nora needs you on the Dust Road.')); return end
 prompt(p,'ada',(reaction or '')..' Crane was a railroad detective. Jesse rode with him and knows his hideouts. '..gates[3].text..' Search the abandoned payroll box near the office or earn gold on ranch deliveries.', 'bail;Confirm bail')
end
local function journal(s)
 local late=ctx.late and ctx.late()
 if ctx.midgame and ctx.midgame() and s.flags.arrived then
  if not s.unlocked['5'] then return 'Follow the walking trail to Iron Pass. Lead your horse or leave it safely where the trail narrows. '..gates[5].text end
  if not s.flags.rubble1 then return 'Clear the western obstruction inside the timber shaft.' end
  if not s.flags.rubble2 then return 'Follow the shaft to its eastern obstruction and clear it.' end
  if not s.map_fragments['3'] then return 'Descend to Silver Spur and search the assay office. The optional map desk and safe are inside.' end
  if not s.flags.station_breached then return late and 'Follow the railway trail back through the pass to Crane’s Plains depot. Choose a charge position at the planning desk, then trigger it at the barricade controls. '..gates[6].text or 'At Silver Spur’s assay office, use /stagecoach station to reach the temporary station site. Place the charge at the station, then trigger it separately. '..gates[6].text end
  if not s.unlocked['7'] then return late and 'Crane fled toward the Ghost Mine. Follow the eastern trail and fill a map in the badlands near the mine entrance. The map is retained.' or 'From the station use /stagecoach mine. Fill a map of the badlands near the Ghost Mine (560, 22, 844), then approach its entrance. The filled map is retained.' end
  if not s.flags.ledger1 then return 'Investigate Nora’s trail at the Ghost Mine entrance, then search the timber office for ledger page 1.' end
 end
 if late and s.flags.ledger1 then
  if not s.unlocked['8'] then return 'Follow the river trail to Amos at Bitter River. '..gates[8].text end
  if not s.flags.ferry_crossed then return 'Speak with Amos about passage: pay, ask for a waiver if trusted, or clear the snagged ferry line. Then cross the ferry deck to the hideout.' end
  if not s.flags.hideout_searched then return 'Cross the channel to Crane’s stilt hideout and search it.' end
  if not s.flags.ledger2 then return 'Read the ledger inside the river hideout.' end
  if ctx.finale_journal then return ctx.finale_journal(s) end
 end
 if s.flags.arrived then
  if not s.unlocked['5'] then return 'Nora was taken toward Iron Pass. Go east to the pass marker. '..gates[5].text end
  if not s.map_fragments['3'] then return 'Clear the two marked shaft obstructions in order, then search the Silver Spur assay office for Samuel’s fragment.' end
  if not s.unlocked['6'] then return 'Follow Nora to Crane’s Station east of Silver Spur. '..gates[6].text end
  if not s.flags.station_breached then return 'Choose a charge position at the station and trigger it at the charge marker when ready.' end
  if not s.unlocked['7'] then return 'Crane fled with Nora toward the Ghost Mine. Fill a map at Dry Gulch (125, 221, 0), then bring it to the mine gate. '..gates[7].text end
  if not s.flags.ledger1 then return 'Investigate the mine clue, then search for ledger page 1.' end
  if not s.unlocked['8'] then return 'Crane’s ledger points to Bitter River. Go east to Amos. '..gates[8].text end
  if not s.flags.ferry_crossed then return 'Reach the hideout by paying Amos, asking for a waiver if trusted, or clearing the snagged line.' end
  if not s.flags.ledger2 then return 'Search the Bitter River hideout for ledger page 2 and Nora’s trail.' end
  if ctx.finale_journal then return ctx.finale_journal(s) end
  return 'Follow Nora east to Widowmaker Tunnel.'
 end
 if not s.flags.jesse_free then return 'Ask Ada about Jesse Moss. '..gates[3].text..' Search the payroll box near the office or carry ranch deliveries.' end
 if not s.flags.jesse_briefed then return 'Jesse is free. Meet him at the jail door to learn Crane’s route and receive Ada’s map fragment.' end
 if not s.unlocked['4'] then return 'Prepare for the Dust Flats. '..gates[4].text..' Ruth’s Red Mesa order desk sells four for 3 gold. Ranch deliveries provide renewable gold.' end
 return 'Follow the Dust Road at night. Choose exposed (short, wind slows you) or sheltered (visit both shelters). Read revealed markers, then meet Jesse at Dry Gulch. No deadline.'
end
local function interact(kind,pos,p,s)
 local inv=p:get_inventory(); local name=p:get_player_name()
 local mid=ctx.midgame and ctx.midgame()
 if more[kind] then
  if not s.flags.arrived then message(p,'The trail','Reach Dry Gulch before following Nora east.'); return true end
  if kind=='pass' then prompt(p,kind,gates[5].text..' Clear the collapsed shaft to reach Silver Spur.','start5;Enter Iron Pass')
  elseif kind=='rubble1' or kind=='rubble2' then
   if not s.unlocked['5'] then message(p,'Collapsed shaft','Prepare at Iron Pass first.')
   elseif kind=='rubble2' and not s.flags.rubble1 then message(p,'Collapsed shaft','Clear the western obstruction first.')
   else s.flags[kind]=true; save(name);if mid and ctx.clear_rubble then ctx.clear_rubble(kind) end;message(p,'Collapsed shaft',kind=='rubble1' and 'The first obstruction is clear. Follow the shaft east to the second.' or 'The route is clear. Search the assay office for Samuel’s fragment.') end
  elseif kind=='assay' then
   if not s.flags.rubble2 then message(p,'Assay office','Clear the shaft before searching here.')
   elseif not s.map_fragments['3'] and not ctx.grant(inv,ItemStack('harrows_trail:fragment_3')) then message(p,'Assay office','Make room for the map fragment and try again.')
   else s.map_fragments['3']=true; save(name); message(p,'Assay office','Samuel’s third fragment lies under the assay ledger. Crane took Nora to the station east. The cartography desk can reveal the optional gold cache.') end
  elseif kind=='cartography' then
   if not (s.map_fragments['1'] and s.map_fragments['2'] and s.map_fragments['3']) then message(p,'Cartography desk','Find all three fragments first. The gold cache is optional.')
   elseif s.flags.harrow_map then message(p,'Cartography desk','Your reconstructed map points to the nearby cache marker.')
   elseif ctx.grant(inv,ItemStack('harrows_trail:harrow_map')) then s.flags.harrow_map=true; save(name); message(p,'Cartography desk','The reconstructed map marks the nearby cache. Finding it is optional.')
   else message(p,'Cartography desk','Make room for the map.') end
  elseif kind=='gold_cache' then
   if not s.flags.harrow_map then message(p,'Assay safe','The location can be decoded from all three fragments at the cartography desk.')
   elseif s.flags.gold_found then message(p,'Assay safe','The cache is recorded. Its final disposition can wait until after Nora is safe.')
   elseif ctx.grant(inv,ItemStack(gold..' 6')) then s.flags.gold_found=true; save(name); message(p,'Assay safe','You found the hidden payroll and recovered six loose ingots. The remaining cache can be decided after Nora is safe.')
   else message(p,'Assay safe','Make room for six gold ingots.') end
  elseif kind=='station' then
   if not s.map_fragments['3'] then message(p,'Crane’s Station','Search Silver Spur’s assay office first.')
   elseif s.flags.station_breached then message(p,'Crane’s Station','Crane escaped with Nora toward the Ghost Mine. Follow the route east.')
   elseif not s.unlocked['6'] then prompt(p,kind,gates[6].text..' Choose the left or right side of the barricade; trigger the charge separately.','left;Place left','right;Place right')
   else prompt(p,kind,'Your reserved charge is ready. You may change its side before triggering it at the charge marker east.','left;Place left','right;Place right') end
  elseif kind=='charge' then
   if not s.unlocked['6'] then message(p,'Barricade','Reserve and place TNT at the station first.')
   elseif s.flags.station_breached then message(p,'Barricade','The breach is open. Crane fled with Nora to the Ghost Mine.')
   else prompt(p,kind,'Your charge is placed on the '..(s.flags.charge_side or 'left')..' side. Trigger it when ready; no timer.','trigger;Trigger charge') end
  elseif kind=='mine_gate' then
   if not s.flags.station_breached then message(p,'Ghost Mine','Follow Crane from the station first.') else prompt(p,kind,gates[7].text..((ctx.midgame and ctx.midgame()) and ' Fill an empty map in these badlands near the entrance (560, 22, 844).' or ' Fill an empty map at Dry Gulch (125, 221, 0).'),'start7;Enter mine') end
  elseif kind=='mine_clue' then
   if not s.unlocked['7'] then message(p,'Mine tracks','Bring the map to the mine gate first.') else s.flags.mine_clue=true; save(name); message(p,'Mine tracks','Nora’s ribbon catches on a timber. Footprints lead to a ledger deeper east.') end
  elseif kind=='ledger1' then
   if not s.flags.mine_clue then message(p,'Mine desk','Investigate the tracks near the mine entrance first.')
   elseif not s.flags.ledger1 and not ctx.grant(inv,ItemStack('harrows_trail:ledger_1')) then message(p,'Mine desk','Make room for ledger page 1.')
   else s.flags.ledger1=true; save(name); message(p,'Ledger page 1','Crane’s route runs from the mine to Amos at Bitter River. Nora is still with him.') end
  elseif kind=='ferry' then
   if not s.flags.ledger1 then message(p,'Amos Reed','Follow the Ghost Mine clue to the ledger first.')
   elseif not s.unlocked['8'] then prompt(p,kind,gates[8].text..' Amos can ferry you toward Nora.','start8;Approach ferry')
   elseif s.flags.ferry_crossed then message(p,'Amos Reed','The way to the hideout east is open.')
   else prompt(p,kind,'Passage costs 3 gold ingots (provisional), or ask for a waiver if trusted. You can instead clear the snagged line east.','pay;Pay 3 gold','waiver;Ask for waiver') end
  elseif kind=='snag' then
   if not s.unlocked['8'] then message(p,'Ferry line','Speak to Amos first.')
   elseif mid and ctx.late and ctx.late() and not ctx.clear_snag() then message(p,'Ferry line','The line is protected or has been replaced. Nothing was changed; speak with Amos about the other passage options.')
   else s.flags.ferry_crossed=true; s.flags.ferry_method='snag'; save(name); message(p,'Ferry line','You free the snagged line. Amos ferries you across; search the hideout east.') end
  elseif kind=='hideout' then
   if not s.flags.ferry_crossed then message(p,'River hideout','Arrange passage with Amos or clear the snagged ferry line first.') else s.flags.hideout_searched=true; save(name); message(p,'River hideout','Nora’s recent note points deeper into the hideout. Search the ledger desk east.') end
  elseif kind=='ledger2' then
   if not s.flags.hideout_searched or not s.flags.ledger1 then message(p,'Hideout ledger','Cross the ferry and investigate the hideout first.')
   elseif not s.flags.ledger2 and not ctx.grant(inv,ItemStack('harrows_trail:ledger_2')) then message(p,'Hideout ledger','Make room for ledger page 2.')
   else s.flags.ledger2=true; save(name); message(p,'Ledger page 2','Brandt robbed the payroll. Crane knew, yet framed Samuel. Crane took Nora toward Widowmaker Tunnel; pursue them when the trail continues.') end
  end
  return true
 elseif kind=='recovery' then ctx.recover(p)
 elseif kind=='dutch' then prompt(p,kind,'Replacement saddle costs 3 gold ingots, consumed on confirmation. Before Dry Gulch, the ranch tack room recovers Samuel’s saddle for free. Horse-death returns are free.','saddle_buy;Buy replacement')
 elseif kind=='delivery' then s.flags.parcel=true; save(name); message(p,'Ranch delivery','Take the supply parcel to the east corral depot. Each completed trip earns 3 gold. Repeat if supplies are lost.')
 elseif kind=='depot' then
  if not s.flags.parcel then message(p,'Supply depot','Collect a parcel at the west ranch supply desk first.')
  elseif ctx.grant(inv,ItemStack(gold..' 3')) then s.flags.parcel=nil; save(name); message(p,'Supply depot','Delivery accepted. You earned 3 gold; the ranch always has more work.')
  else message(p,'Supply depot','Make room for 3 gold ingots, then return with your parcel.') end
 elseif kind=='cache' then
  if s.flags.payroll then message(p,'Abandoned payroll box','The payroll reward was already recovered. Ranch deliveries provide more gold.')
  elseif ctx.grant(inv,ItemStack(gold..' 12')) then s.flags.payroll=true; save(name); message(p,'Abandoned payroll box','You recover 12 gold ingots: enough for bail and Ruth’s lantern order. If lost, ranch deliveries provide more.')
  else message(p,'Abandoned payroll box','Make room for 12 gold ingots and search again.') end
 elseif kind=='ruth' or kind=='ruth_gulch' then prompt(p,kind,'Ruth’s order desk: four lanterns cost 3 gold ingots, consumed once per purchase. Lanterns remain yours during the crossing. Her shop also awaits at Dry Gulch.','lantern_buy;Buy 4 lanterns')
 elseif kind=='jesse' then
  if not s.unlocked['3'] then message(p,'Jesse Moss','Ada needs bail before she can release me.')
  elseif not s.flags.jesse_briefed and not ctx.grant(inv,ItemStack('harrows_trail:fragment_2')) then message(p,'Jesse Moss','Make room for Ada’s map fragment.')
  else
   s.flags.jesse_free=true; s.flags.jesse_briefed=true; s.map_fragments['2']=true; save(name)
   message(p,'Jesse Moss','Crane wants Samuel’s hidden gold. He took Nora east. Ada sent this map fragment. Bring four lanterns to the Dust Road marker. The sheltered trail is longer; exposed sand slows riders in the gale.')
  end
 elseif kind=='dust' then
  if not s.flags.jesse_briefed then message(p,'Dust Road','Speak to Jesse after posting bail first.')
  else prompt(p,'dust',gates[4].text..' Crossing starts at night; you may wait safely here. '..(mid and 'Exposed: the eastern shelter. Sheltered: visit the western shelters in order, first the northern one, then the southern one. Dry Gulch lies southwest beyond the sand.' or 'Exposed: one marker, gale slows travel. Sheltered: two markers via the northern shelters, no wind penalty.')..' No deadline.'..(ctx.grounded and not mid and ' Use /stagecoach here to return to Red Mesa.' or ''),'exposed_route;Exposed route','sheltered_route;Sheltered route') end
 elseif kind=='exposed' or kind=='shelter1' or kind=='shelter2' then
  if not s.unlocked['4'] then message(p,'Unlit trail','Your lanterns will reveal these trail signs after you prepare at the Dust Road.')
  elseif s.flags.route=='exposed' and kind=='exposed' then
   if p:get_attach() then message(p,'Exposed gale','Dismount and lead your horse through the gale on foot before reading this marker.'); return true end
   s.flags.crossing_mark=true; save(name); message(p,'Lantern-lit marker',mid and 'Through the blowing dust: the trading post at Dry Gulch lies southwest. The gale makes every step heavy.' or 'Through the blowing dust: Dry Gulch lies east. The gale makes every step heavy.')
  elseif s.flags.route=='sheltered' then
   if kind=='shelter1' then s.flags.shelter1=true elseif kind=='shelter2' and s.flags.shelter1 then s.flags.crossing_mark=true end
   save(name); message(p,'Lantern-lit shelter',mid and 'Rock walls break the wind. Visit the northern shelter first, then the southern one. Continue southwest to Dry Gulch.' or 'Rock walls break the wind. Follow the shelters in order west to east, then turn south for Dry Gulch.')
  end
 elseif kind=='gulch' then
  if s.unlocked['4'] and s.flags.crossing_mark then s.flags.arrived=true; save(name); message(p,'Dry Gulch — Jesse',mid and 'You made it. Crane took Nora toward Iron Pass. Follow the long northwest walking trail around the water. I’m riding on alone. Prepare here at Ruth’s shop and Dutch’s stable before leaving.' or 'You made it. Crane rode toward Iron Pass with Nora. I’m riding on alone. Ruth’s shop is here; follow the pass marker east.') else message(p,'Dry Gulch','Return to Jesse’s Dust Road trail. Follow your chosen lantern markers before concluding the crossing.') end
 else return false end
 return true
end
core.register_craftitem('harrows_trail:fragment_2',{description='Samuel’s map fragment 2',inventory_image='default_paper.png',on_use=function(_,p) message(p,'Ada’s fragment','Recovered from Samuel’s evidence locker. Crane is pursuing the hidden payroll; Nora’s trail leads east.') end})
for _,doc in ipairs({{'fragment_3','Samuel’s map fragment 3','The third fragment points toward Silver Spur.'},{'harrow_map','Harrow map','The three fragments reveal the optional Silver Spur cache.'},{'ledger_1','Crane’s ledger page 1','Crane’s route leads from the Ghost Mine to Bitter River. Nora is with him.'},{'ledger_2','Crane’s ledger page 2','Brandt robbed the payroll. Crane knew and framed Samuel. Nora was taken toward Widowmaker Tunnel.'}}) do
 core.register_craftitem('harrows_trail:'..doc[1],{description=doc[2],inventory_image='default_paper.png',on_use=function(stack,p) message(p,doc[2],doc[3]); return stack end})
end
for kind,pos in pairs(positions) do
 if kind~='ada' then core.register_node('harrows_trail:'..kind,{description=kind..' — right-click',tiles={'mcl_core_sandstone_normal.png'},groups={unbreakable=1},diggable=false,on_rightclick=function(at,_,p) local s=states[p:get_player_name()]; if s then interact(kind,at,p,s) end; return p:get_wielded_item() end}) end
end
local function receive(p,form,f)
 if form~='harrows_trail:story' then return end
 local name=p:get_player_name(); local kind=pending[name]; local s=states[name]
 if not kind or not s or vector.distance(p:get_pos(),positions[kind])>8 then return end
 pending[name]=nil
 local inv=p:get_inventory()
 if kind=='pass' and f.start5 then
  if unlock(p,s,5) then message(p,'Iron Pass','Clear the western and eastern shaft obstructions, then search the assay office.') else message(p,'Iron Pass','Missing equipment. '..gates[5].text) end
 elseif kind=='station' and (f.left or f.right) and s.map_fragments['3'] then
  local side=f.left and 'left' or 'right'
  if ctx.late and ctx.late() and not ctx.can_charge(side) then message(p,'Crane’s Station','The selected charge position is obstructed or protected. No TNT was taken.');return end
  if unlock(p,s,6) then
   if ctx.late and ctx.late() then assert(ctx.place_charge(side),'charge placement changed during confirmation') end
   s.flags.charge_side=side;save(name);message(p,'Crane’s Station','Charge placed on the '..s.flags.charge_side..' side. Trigger it at the barricade when ready.')
  else message(p,'Crane’s Station','Missing TNT. '..gates[6].text) end
 elseif kind=='charge' and f.trigger and s.unlocked['6'] and not s.flags.station_breached then
  if ctx.late and ctx.late() and not ctx.breach() then message(p,'Barricade','The marked barricade or charge is protected, or the charge is missing. Return to the station desk to replace the reserved charge without paying again.');return end
  s.flags.station_breached=true; save(name); message(p,'The breach','The barricade breaks. Crane escapes with Nora; his abandoned note points to the Ghost Mine east.')
 elseif kind=='mine_gate' and f.start7 and s.flags.station_breached then
  if unlock(p,s,7) then message(p,'Ghost Mine','Investigate the tracks, then search the mine desk.') else message(p,'Ghost Mine','Missing map. '..gates[7].text) end
 elseif kind=='ferry' and f.start8 and s.flags.ledger1 then
  if unlock(p,s,8) then message(p,'Amos Reed','Speak to me again to arrange passage, or clear the snagged line.') else message(p,'Amos Reed','Missing equipment. '..gates[8].text) end
 elseif kind=='ferry' and s.unlocked['8'] and not s.flags.ferry_crossed and (f.pay or f.waiver) then
  if f.waiver and s.honor<53 then message(p,'Amos Reed','I do not yet know you well enough to waive the fee. Pay or clear the snagged line.'); return end
  if f.pay and not inv:contains_item('main',gold..' 3') then message(p,'Amos Reed','You need 3 gold ingots, or clear the snagged line.'); return end
  if f.pay then inv:remove_item('main',gold..' 3') end
  s.flags.ferry_crossed=true; s.flags.ferry_method=f.pay and 'pay' or 'waiver'; save(name); message(p,'Amos Reed','Passage arranged. Search the hideout east for Nora’s trail.')
 elseif f.bail and kind=='ada' and s.flags.choice and s.unlocked['2'] then
  if unlock(p,s,3) then s.flags.jesse_free=true; save(name); message(p,'Ada Wells','Bail recorded. Jesse is released; meet him at the jail door for my fragment and Crane’s route.') else message(p,'Ada Wells','Missing bail. '..gates[3].text) end
 elseif f.saddle_buy and kind=='dutch' or f.lantern_buy and (kind=='ruth' or kind=='ruth_gulch') then
  local item=f.saddle_buy and 'mcl_mobitems:saddle' or lantern..' 4'
  if ctx.grant(inv,ItemStack(item),ItemStack(gold..' 3')) then message(p,'Purchase complete','Three gold paid. Your equipment is retained by story gates.') else message(p,'Shop','Need 3 gold ingots and room for the purchase. No payment was taken; try again.') end
 elseif kind=='dust' and (f.exposed_route or f.sheltered_route) and s.flags.jesse_briefed then
  local tod=core.get_timeofday()
  if tod>0.2 and tod<0.8 then message(p,'Dust Road','Wait safely for night. There is no deadline.'); return end
  if not unlock(p,s,4) then message(p,'Dust Road','Missing equipment. '..gates[4].text); return end
  s.flags.route=f.exposed_route and 'exposed' or 'sheltered'; s.flags.crossing_mark=nil; s.flags.shelter1=nil; save(name)
  message(p,'Jesse Moss',journal(s))
 end
end
core.register_on_player_receive_fields(receive)
local building=false
local function ensure()
 if building or storage:get_string('chapter_site')=='1' then return end
 if ctx.midgame and ctx.midgame() then storage:set_string('chapter_site','1');return end
 building=true
 core.emerge_area({x=-6,y=220,z=-7},{x=135,y=225,z=22},function(_,action,left)
  if action==core.EMERGE_ERRORED or action==core.EMERGE_CANCELLED then building=false; return end
  if left~=0 then return end
  local layout={}
  local function add(x,y,z,n) layout[#layout+1]={pos={x=x,y=y,z=z},name=n} end
  for x=65,135 do for z=-7,22 do
   -- Two traversable branches, with a connecting plaza at either end.
   if x<75 or x>115 or math.abs(z)<=3 or z>=15 and z<=21 then add(x,220,z,'harrows_trail:floor') end
  end end
  local grounded_opening={recovery=true,delivery=true,depot=true,jesse=true,cache=true,ruth=true}
  for k,p in pairs(positions) do
   if k~='ada' and not more[k] and not (ctx.grounded and grounded_opening[k]) then add(p.x,p.y,p.z,'harrows_trail:'..k) end
  end
  for _,x in ipairs({80,105}) do for z=15,21 do add(x,224,z,'harrows_trail:adobe') end end
  for _,e in ipairs(layout) do local n=core.get_node(e.pos).name; if n~='air' and n~=e.name then core.log('error','[harrows_trail] Chapter site occupied; preserved'); building=false; return end end
  for _,e in ipairs(layout) do core.set_node(e.pos,{name=e.name}); core.get_meta(e.pos):set_string('infotext',e.name..' (right-click)') end
  storage:set_string('chapter_site','1'); building=false
 end)
end
local more_building=false
local function ensure_more()
 if more_building or storage:get_string('sprint3_site')=='1' then return end
 if ctx.late and ctx.late() then storage:set_string('sprint3_site','1');return end
 more_building=true
 core.emerge_area({x=136,y=220,z=-7},{x=260,y=225,z=7},function(_,action,left)
  if action==core.EMERGE_ERRORED or action==core.EMERGE_CANCELLED then more_building=false; return end
  if left~=0 then return end
  local layout={}
  for x=136,260 do for z=-7,7 do layout[#layout+1]={pos={x=x,y=220,z=z},name='harrows_trail:floor'} end end
  local grounded={pass=true,rubble1=true,rubble2=true,assay=true,cartography=true,gold_cache=true,mine_gate=true,mine_clue=true,ledger1=true}
  for k,p in pairs(more) do if not (ctx.midgame and ctx.midgame() and grounded[k]) then layout[#layout+1]={pos=p,name='harrows_trail:'..k} end end
  for _,e in ipairs(layout) do local n=core.get_node(e.pos).name; if n~='air' and n~=e.name then core.log('error','[harrows_trail] Sprint 3 site occupied; preserved'); more_building=false; return end end
  for _,e in ipairs(layout) do core.set_node(e.pos,{name=e.name}); core.get_meta(e.pos):set_string('infotext',e.name..' (right-click)') end
  storage:set_string('sprint3_site','1'); more_building=false
 end)
end
core.register_on_joinplayer(ensure)
core.register_on_joinplayer(ensure_more)
local windy={}
local marker_huds={}
core.register_on_leaveplayer(function(p) marker_huds[p:get_player_name()]=nil; windy[p:get_player_name()]=nil end)
local elapsed=0
core.register_globalstep(function(dt)
 elapsed=elapsed+dt; if elapsed<1 then return end; elapsed=0
 for _,p in ipairs(core.get_connected_players()) do
  local s=states[p:get_player_name()]; local at=p:get_pos()
  local name=p:get_player_name()
  if s and s.unlocked['4'] and not s.flags.arrived and not marker_huds[name] then
   marker_huds[name]={}
   for _,kind in ipairs({'exposed','shelter1','shelter2','gulch'}) do
    marker_huds[name][#marker_huds[name]+1]=p:hud_add({hud_elem_type='waypoint',name='Lantern trail: '..kind,text='m',number=0xffd080,world_pos=positions[kind]})
   end
  elseif s and s.flags.arrived and marker_huds[name] then
   for _,id in ipairs(marker_huds[name]) do p:hud_remove(id) end; marker_huds[name]=nil
  end
  local storm_area=at.x>74 and at.x<116 and math.abs(at.z)<5
  if ctx.midgame and ctx.midgame() then storm_area=at.x>=640 and at.x<=675 and at.z>=1010 and at.z<=1040 end
  local storm=s and s.unlocked['4'] and not s.flags.arrived and storm_area and s.flags.route=='exposed'
  local name=p:get_player_name()
  if storm and not windy[name] then windy[name]=p:get_physics_override().speed; p:set_physics_override({speed=windy[name]*0.55})
  elseif not storm and windy[name] then p:set_physics_override({speed=windy[name]}); windy[name]=nil end
  if storm then core.add_particlespawner({amount=24,time=1,minpos=vector.add(at,{x=-4,y=0,z=-4}),maxpos=vector.add(at,{x=4,y=3,z=4}),minvel={x=-4,y=0,z=0},maxvel={x=-2,y=0,z=1},minexptime=0.4,maxexptime=0.8,minsize=2,maxsize=4,texture='mcl_core_sandstone_normal.png'}) end
 end
end)
return {interact=interact,ada=ada,journal=journal,gates=gates,unlock=unlock,ensure=ensure,positions=positions,receive=receive,ensure_more=ensure_more, context=ctx}
end
