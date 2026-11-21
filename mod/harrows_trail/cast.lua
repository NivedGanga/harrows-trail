-- Small scheduled cast over the existing authoritative dialogue/encounter entities.
return function(ctx)
 local names={eli='Eli Harrow',ada='Ada Wells',jonah='Jonah Pike',dutch='Dutch Hale',ruth='Ruth Calloway',amos='Amos Reed',jesse='Jesse Moss',nora='Nora Harrow',crane='Silas Crane',mercer='Mercer'}
 local roles={ada='ada',jesse='jesse',ruth='jonah',dust='jesse',gulch='jesse',ruth_gulch='ruth',dutch='dutch',ferry='amos',mercer='mercer',nora='nora',crane='crane',verdict='ada',ending='nora'}
 local actors,scenes={},{}
 local function phase(t) return t>=0.25 and t<0.75 and 'day' or t>=0.75 and t<0.875 and 'evening' or 'night' end
 local function schedule(role,t,f)
  local period=phase(t)
  if role=='jesse' and not f.jesse_free then return 'jailed',0,0 end
  if role=='ada' and period=='evening' then return 'patrol',0,-3 end
  if role=='amos' and period~='day' then return 'fire',1,0 end
  if role=='dutch' and period=='night' then return 'hayloft',0,1 end
  if role=='ruth' and period=='night' then return 'closed',0,0 end
  if role=='jesse' then return period=='night' and 'hiding' or 'wandering',period=='night' and 0 or 1,0 end
  return period=='night' and 'resting' or role=='jonah' and period=='day' and 'cleaning' or 'working',0,0
 end
 local function active(kind,s)
  local f=s.flags
  if kind=='jesse' then return not f.jesse_briefed end
  if kind=='dust' then return f.jesse_briefed and not f.arrived end
  if kind=='gulch' then return f.arrived and not f.ledger1 end
  if kind=='river_jesse' then return f.ledger1 end
  if kind=='mercer' then return s.unlocked['9'] and f.mercer_outcome~='killed' end
  if kind=='nora' then return s.unlocked['9'] and not f.crane_outcome end
  if kind=='crane' then return s.unlocked['9'] and not f.crane_outcome end
  return true
 end
 local function safe(p)
  local at=vector.round(p)
  local below=core.get_node_or_nil(vector.offset(at,0,-1,0))
  if not below or not core.registered_nodes[below.name] or not core.registered_nodes[below.name].walkable then return false end
  if core.get_item_group(below.name,'fence')>0 or core.get_item_group(below.name,'wall')>0 then return false end
  for y=0,1 do local n=core.get_node_or_nil(vector.offset(at,0,y,0));if not n or not core.registered_nodes[n.name] or core.registered_nodes[n.name].walkable or core.get_item_group(n.name,'liquid')>0 then return false end end
  return true
 end
 local function stop(p)
  local name=p:get_player_name();local scene=scenes[name];if not scene then return end
  p:hud_remove(scene.hud);scenes[name]=nil
 end
 local function scene(p,id,role,text,then_do)
  if not p.hud_add or not p.get_player_control then return false end
  local name=p:get_player_name();local s=ctx.states[name];if not s then return false end
  if s.flags['seen_'..id] then return false end
  stop(p);s.flags['seen_'..id]=true;ctx.save(name)
  -- Staging changes the actors' facing only. Camera, physics and horse attachment stay native.
  local pos=p:get_pos()
  for ent in pairs(actors) do
   local at=ent.object:get_pos()
   if at and ent.role==role and vector.distance(pos,at)<24 then ent.object:set_yaw(core.dir_to_yaw(vector.direction(at,pos))) end
  end
  core.close_formspec(name,'harrows_trail:story');core.close_formspec(name,'harrows_trail:finale')
  local hud=p:hud_add({hud_elem_type='text',position={x=0.5,y=0.78},alignment={x=0,y=0},number=0xffe3b0,
   text=(names[role] or role)..': '..text..'\n[Sneak to skip; right-click again for dialogue]',scale={x=100,y=100}})
  scenes[name]={hud=hud,left=5,then_do=then_do};return true
 end
 local intro={ada='I need evidence, Eli. We can bring him in.',jonah='Jonah Pike. I hear things at this bar. Ruth leaves urgent supplies here.',dutch='Dutch Hale. Keep a good horse close and its saddle closer.',ruth='Ruth Calloway. Preparation matters. I keep a fallback for every road.',amos='Amos Reed. I can take you across, or you can help clear my line.',jesse='Jesse Moss. I know Crane’s trail. Let me show you.',nora='Eli! I kept Father’s letter safe.',crane='Harrow. You have your father’s stubbornness.',mercer='This is as far as you ride, Harrow.'}
 local function introduce(ent,p,continuation)
  local s=ctx.states[p:get_player_name()];if not s then return false end
  if scenes[p:get_player_name()] then stop(p);return false end
  return scene(p,'intro_'..ent.role,ent.role,intro[ent.role] or 'The trail brought you here.',function()
   if ent.object:get_pos() and vector.distance(p:get_pos(),ent.object:get_pos())<=8 then continuation() end
  end)
 end
 local texture=ctx.skin
 local function decorate(ent)
  ent.role=roles[ent.kind] or ent.role;ent.home=vector.new(ent.object:get_pos());actors[ent]=true
  ent.object:set_properties({textures={texture(ent.role),'blank.png','blank.png'},nametag=''})
  ent.object:set_animation({x=0,y=79},20,0,true)
 end
 local function nearest(pos)
  local near,distance
  for _,p in ipairs(core.get_connected_players()) do local d=vector.distance(pos,p:get_pos());if not distance or d<distance then near,distance=p,d end end
  return near,distance
 end
 local function tick(ent,p,s)
  local visible=not not active(ent.kind,s)
  if ent.visible~=visible then ent.object:set_properties({is_visible=visible,pointable=visible});ent.visible=visible end
  if not visible then return end
  local routine,dx,dz=schedule(ent.role,core.get_timeofday(),s.flags)
  if ent.kind=='mercer' or ent.kind=='nora' or ent.kind=='crane' or ent.kind=='cameo' then routine='encounter';dx=0;dz=0 end
  if routine=='fire' then
   local fire=vector.offset(ent.home,1,0,-1)
   if safe(fire) then core.add_particle({pos=vector.offset(fire,0,-0.3,0),velocity={x=0,y=0.1,z=0},expirationtime=2,size=7,glow=10,
    texture='mcl_campfires_campfire_fire.png',animation={type='vertical_frames',aspect_w=16,aspect_h=16,length=1},playername=p:get_player_name()}) end
  end
  if routine=='patrol' then dx=math.floor(core.get_us_time()/10000000)%2 end
  if routine=='wandering' then dx=math.floor(core.get_us_time()/10000000)%2 end
  local target=vector.offset(ent.home,dx,routine=='hayloft' and 4 or 0,dz)
  if not safe(target) and safe(vector.offset(target,0,1,0)) then target.y=target.y+1 end
  if not safe(target) and safe(vector.offset(target,0,-1,0)) then target.y=target.y-1 end
  local key=core.pos_to_string(target)
  if routine==ent.routine and key==ent.waypoint then return end
  if not safe(target) or routine~='hayloft' and not core.find_path(vector.round(ent.object:get_pos()),vector.round(target),4,1,1,'A*_noprefetch') then target=ent.home end
  ent.object:move_to(target,true);ent.routine=routine;ent.waypoint=key
  local rest=routine=='resting' or routine=='hiding' or routine=='hayloft'
  ent.object:set_animation(rest and {x=81,y=160} or routine=='cleaning' and {x=189,y=198} or {x=0,y=79},20,0,true)
 end
 local function duster(p)
  for _,list in ipairs({'main','armor'}) do
   for _,stack in ipairs(p:get_inventory():get_list(list) or {}) do
    if stack:get_name()=='mcl_armor:chestplate_leather' and stack:get_meta():get_string('mcl_armor:color'):lower():sub(1,7)==mcl_dyes.colors.brown.rgb then return true end
   end
  end
  return false
 end
 core.register_on_mods_loaded(function()
  for _,name in ipairs({'opening_actor','mid_actor','finale_actor'}) do
   local def=core.registered_entities['harrows_trail:'..name];local activate,click,deactivate=def.on_activate,def.on_rightclick,def.on_deactivate
   def.on_activate=function(self,data,...)
    activate(self,data,...);if self.kind then decorate(self) end
   end
   def.on_deactivate=function(self,...) actors[self]=nil;if deactivate then deactivate(self,...) end end
   def.on_rightclick=function(self,p)
    if not introduce(self,p,function() click(self,p) end) then
     if self.routine=='closed' or self.routine=='resting' or self.routine=='hayloft' then core.chat_send_player(p:get_player_name(),(names[self.role] or '')..': I was resting. Urgent rescue supplies and evidence can still be handled tonight.') end
     click(self,p)
    end
   end
  end
 end)
 core.register_entity('harrows_trail:cast_cameo',{
  initial_properties={physical=false,pointable=true,visual='mesh',mesh='mcl_armor_character.b3d',textures={'character.png','blank.png','blank.png'},static_save=false},
  on_activate=function(self,data) self.kind='cameo';self.role=data;self.object:set_armor_groups({immortal=1});decorate(self) end,
  on_deactivate=function(self) actors[self]=nil end,
  on_rightclick=function(self,p)
   local s=ctx.states[p:get_player_name()];if not s then return end
   if scene(p,'intro_'..self.role,self.role,intro[self.role]) then return end
   if self.role=='jesse' then core.chat_send_player(p:get_player_name(),'Jesse: Crane fled upriver. Nora left signs. Check the hideout ledger.')
   elseif self.role=='crane' then core.chat_send_player(p:get_player_name(),s.flags.crane_outcome and 'Crane: My weapon is gone. I will hear your final word here with Ada.' or 'Crane: You will have to follow the trail, Harrow.')
   else core.chat_send_player(p:get_player_name(),s.verdict=='vengeance' and 'Nora: I need time, Eli. I will not ride with you today.' or s.verdict and 'Nora: Now we can think about home.' or 'Nora: We can go home when the truth is heard.') end
  end,
 })
 local cameos={}
 local function cameo(key,role,pos,p)
  local obj=cameos[key]
  if not pos or vector.distance(pos,p:get_pos())>48 then if obj and obj:get_pos() then obj:remove() end;cameos[key]=nil;return end
  if obj and obj:get_pos() and vector.equals(obj:get_pos(),pos) then return end
  if obj and obj:get_pos() then obj:remove() end
  if safe(pos) then cameos[key]=core.add_entity(pos,'harrows_trail:cast_cameo',role) end
 end
 local function update(ent)
  local pos=ent.object:get_pos();if not pos then actors[ent]=nil;return end
  local p,d=nearest(pos);if not p or d>=48 then return false end
  local s=ctx.states[p:get_player_name()];if s then tick(ent,p,s);return true end
 end
 local function advance(dt)
  for name,event in pairs(scenes) do
   local p=core.get_player_by_name(name)
   if p then event.left=event.left-dt;if event.left<=0 or p:get_player_control().sneak then local next=event.then_do;stop(p);if next then next() end end else scenes[name]=nil end
  end
 end
 local elapsed=0
 core.register_globalstep(function(dt)
  advance(dt)
  elapsed=elapsed+dt;if elapsed<2 then return end;elapsed=0
  for ent in pairs(actors) do update(ent) end
  for _,p in ipairs(core.get_connected_players()) do
   local name=p:get_player_name();local s=ctx.states[name]
   if s then
    local skin=duster(p) and 'eli_duster' or 'eli'
    if mcl_player.players[p] and p:get_properties().textures[1]~=texture(skin) then mcl_player.player_set_skin(p,texture(skin)) end
    if ctx.late() then
     local f=s.flags;local cp=not f.station_breached and vector.offset(ctx.chapter.positions.station,1,0,0) or not f.ledger1 and vector.offset(ctx.chapter.positions.mine_clue,1,0,0) or not f.hideout_searched and vector.offset(ctx.chapter.positions.hideout,0,0,1) or nil
     cameo('crane','crane',not f.crane_outcome and cp or nil,p)
     cameo('jesse','jesse',f.ledger1 and vector.offset(ctx.chapter.positions.ferry,0,0,-1) or nil,p)
     local home=ctx.ada
     cameo('nora_home','nora',f.crane_outcome and vector.offset(home,1,0,0) or nil,p)
     cameo('custody','crane',(f.crane_outcome=='captured' or f.crane_outcome=='released' and not s.verdict) and vector.offset(home,-1,0,0) or nil,p)
    end
   end
  end
 end)
 core.register_on_leaveplayer(function(p) stop(p) end)
 core.register_on_dieplayer(function(p) stop(p) end)
 local event_text={station_breached={'crane','You breached the depot, but Crane slipped out toward the mine.'},nora_freed={'nora','You came back. Now let us finish this together.'},crane_surrender={'crane','Enough. I surrender.'},verdict={'ada','The truth about Samuel Harrow will be heard. Nora stands beside you.'}}
 local seen={}
 local function changed(name)
  local p=core.get_player_by_name(name);local s=ctx.states[name];if not p or not s then return end
  seen[name]=seen[name] or {}
  for flag,data in pairs(event_text) do
   local value=flag=='verdict' and s.verdict or s.flags[flag]
   if value and not s.flags['seen_event_'..flag] and not seen[name][flag] then
    seen[name][flag]=true
    core.after(0.1,function() if core.get_player_by_name(name)==p then scene(p,'event_'..flag,data[1],data[2]) end end)
   end
  end
 end
 return {phase=phase,schedule=schedule,active=active,safe=safe,actors=actors,update=update,scenes=scenes,scene=scene,advance=advance,stop=stop,changed=changed,duster=duster,tick=tick}
end
