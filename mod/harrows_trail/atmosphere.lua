return function(ctx)
 local enabled=core.settings:get_bool('harrows_trail_weather',true)
 local particles=core.settings:get_bool('harrows_trail_particles',true)
 local default_audio=core.settings:get_bool('harrows_trail_ambience',false)
 local gain=math.max(0,math.min(.5,tonumber(core.settings:get('harrows_trail_ambience_gain')) or .15))
 local regions={ranch={654,19,652,70},red_mesa={623,21,788,64},dust_flats={642,11,1024,80},dry_gulch={523,8,1212,64},silver_spur={-463,11,-557,60},station={-300,19,-213,60},bitter_river={300,21,1500,64},widowmaker={499,32,1605,40}}
 local function region(pos)
  for id,p in pairs(regions) do if math.abs(pos.y-p[2])<48 and (pos.x-p[1])^2+(pos.z-p[3])^2<=p[4]^2 then return id end end
 end
 local function weather(seed,day,id,tod)
  local roll=tonumber(core.sha1(tostring(seed)..':'..math.floor(day)..':'..tostring(id)):sub(1,8),16)%100
  if id=='bitter_river' then
   if tod>=.2 and tod<.33 and roll<75 then return 'fog' end
   return roll<45 and 'rain' or 'clear'
  end
  if (id=='red_mesa' or id=='dry_gulch' or id=='dust_flats') and roll<35 then return 'dust' end
  return 'clear'
 end
 local function count(p,kind)
  if not particles or kind=='clear' then return 0 end
  local setting=p:get_meta():get_string('harrows_trail:effects')
  return setting=='off' and 0 or setting=='low' and 4 or 12
 end
 local function audible(p)
  local value=p:get_meta():get_string('harrows_trail:audio');return value=='on' or value~='off' and default_audio
 end
 local available={}
 for _,sound in ipairs({'wind','crickets','whistle','saloon','swamp','rail'}) do available[sound]=ctx.assets.exists('sounds/harrows_'..sound..'.ogg') end
 local particle_assets={}
 for _,kind in ipairs({'rain','dust','fog'}) do particle_assets[kind]=ctx.assets.exists('textures/harrows_'..kind..'.png') end
 local sessions,last_particles,last_whistle={},{},{}
 local seed=core.get_mapgen_setting('seed') or '0'
 local function stop(p,restore)
  local name=p:get_player_name();local s=sessions[name];if not s then return end
  for _,handle in pairs(s.handles or {}) do core.sound_stop(handle) end
  if restore and s.sky then p:set_sky(s.sky);mcl_weather.skycolor.force_update=true end
  sessions[name]=nil
 end
 local function palette(kind)
  return {type='regular',sky_color={day_sky='#9cbbc0',day_horizon='#dac7a1',dawn_sky='#c4936a',dawn_horizon='#d6a975',night_sky='#1e2d42',night_horizon='#48586a',indoors='#86715a',fog_sun_tint='#d8a15f',fog_moon_tint='#64748b',fog_tint_type='custom'},
   fog={fog_distance=kind=='fog' and 96 or kind=='dust' and 128 or -1,fog_start=kind=='clear' and -1 or .6,fog_color=kind=='fog' and '#c7ceb6' or kind=='dust' and '#c8b17b' or '#00000000'}}
 end
 local function sky(p)
  if not enabled then return end
  local id=region(p:get_pos());if not id then return end
  local n=core.get_node_or_nil(vector.offset(p:get_pos(),0,1.5,0))
  if not n or core.get_item_group(n.name,'liquid')>0 then return end
  local kind=weather(seed,core.get_day_count(),id,core.get_timeofday())
  if p:get_meta():get_string('harrows_trail:effects')=='off' then kind='clear' end
  local name=p:get_player_name()
  if not sessions[name] then sessions[name]={sky=p:get_sky(true),handles={}} end
  p:set_sky(palette(kind));return true
 end
 -- Native rain/snow are suppressed only inside story regions; external biomes keep native weather.
 for _,fn in ipairs({'has_rain','has_snow'}) do local native=assert(mcl_weather[fn]);mcl_weather[fn]=function(pos,...)
  if enabled and region(pos) then return false end;return native(pos,...)
 end end
 for _,fn in ipairs({'set_sky_box_clear','set_sky_color'}) do local native=assert(mcl_weather[fn]);mcl_weather[fn]=function(p,...)
  native(p,...);sky(p)
 end end
 local native_sky_update=mcl_weather.skycolor.update_sky_color
 mcl_weather.skycolor.update_sky_color=function(players)
  local result=native_sky_update(players)
  for _,p in ipairs(mcl_weather.skycolor.utils.get_players(players)) do
   if sky(p) then
    p:set_sun({visible=true,sunrise_visible=true});p:set_moon({visible=true});p:set_stars({visible=true})
    mcl_weather.skycolor.override_day_night_ratio(p,nil)
   end
  end
  return result
 end
 local function emit(p,id,kind)
  local total=count(p,kind);local pos=p:get_pos()
  if not enabled or total==0 or (core.get_natural_light(vector.offset(pos,0,2,0),.5) or 0)<12 then return 0 end
  local file='harrows_'..kind..'.png';if not particle_assets[kind] then return 0 end
  local name=p:get_player_name();local now=core.get_gametime()
  if last_particles[name] and now-last_particles[name]<2 then return 0 end
  last_particles[name]=now
  local rand=PcgRandom(tonumber(core.sha1(seed..':'..id..':'..core.get_gametime()):sub(1,8),16)%2147483647)
  for _=1,total do
   local rain=kind=='rain'
   core.add_particle({pos=vector.offset(pos,rand:next(-8,8),rain and 8 or rand:next(1,5),rand:next(-8,8)),
    velocity=rain and {x=-1,y=-6,z=0} or {x=kind=='dust' and 2 or .2,y=0,z=.2},expirationtime=2,size=kind=='fog' and 14 or rain and 3 or 4,
    texture=file,collisiondetection=true,playername=p:get_player_name()})
  end
  return total
 end
 local function sound_set(p,id,tod)
  local base=(id=='bitter_river' and 'swamp') or (id=='silver_spur' or id=='widowmaker') and 'rail' or 'wind'
  local second
  if id=='red_mesa' and vector.distance(p:get_pos(),{x=620,y=21,z=788})<14 then second='saloon'
  elseif id=='station' or id=='widowmaker' then second='whistle'
  elseif tod<.2 or tod>.8 then second='crickets' end
  return base,second
 end
 local function update(p)
  local name=p:get_player_name();local id=region(p:get_pos())
  if not id then stop(p,true);return end
  local s=sessions[name]
  if not s then s={sky=p:get_sky(true),handles={}};sessions[name]=s end
  if enabled then sky(p) end
  local tod=core.get_timeofday();local kind=weather(seed,core.get_day_count(),id,tod)
  local emitted=emit(p,id,kind)
  local base,second=sound_set(p,id,tod);local signature=id..':'..tostring(second)..':'..tostring(audible(p))
  if s.sound~=signature then
   for _,h in pairs(s.handles) do core.sound_stop(h) end;s.handles={};s.sound=signature;s.last_whistle=nil
   if audible(p) then for _,sound in ipairs({base,second}) do
    if sound~='whistle' and available[sound] then local handle=core.sound_play('harrows_'..sound,{to_player=name,gain=gain,loop=true});if handle then s.handles[#s.handles+1]=handle end end
   end end
  end
  if second=='whistle' and audible(p) and available.whistle and (not last_whistle[name] or core.get_gametime()-last_whistle[name]>=60) then
   if s.handles[2] then core.sound_stop(s.handles[2]) end
   s.handles[2]=core.sound_play('harrows_whistle',{to_player=name,gain=gain*.6});last_whistle[name]=core.get_gametime()
  end
  return emitted,#s.handles
 end
 local function setting_command(key,allowed)
  return function(name,param)
   if not allowed[param] then return false,'Choose '..(key=='audio' and 'on or off.' or 'on, low or off.') end
   local p=core.get_player_by_name(name);if not p then return false end
   p:get_meta():set_string('harrows_trail:'..key,param);stop(p,true);update(p);return true,'Trail '..key..': '..param
  end
 end
 core.register_chatcommand('trail_audio',{params='on | off',description='Opt in or out of original frontier ambience',func=setting_command('audio',{on=true,off=true})})
 core.register_chatcommand('trail_effects',{params='on | low | off',description='Set local frontier particles and haze',func=setting_command('effects',{on=true,low=true,off=true})})
 local elapsed=0
 core.register_globalstep(function(dt)elapsed=elapsed+dt;if elapsed<2 then return end;elapsed=0;for _,p in ipairs(core.get_connected_players()) do update(p) end end)
 core.register_on_leaveplayer(function(p)stop(p,false);last_particles[p:get_player_name()]=nil;last_whistle[p:get_player_name()]=nil end)
 core.register_on_dieplayer(function(p)stop(p,true)end)
 core.register_on_joinplayer(function(p)p:set_sky({fog={fog_distance=-1,fog_start=-1,fog_color='#00000000'}})end)
 return {region=region,weather=weather,count=count,update=update,emit=emit,stop=stop,palette=palette,sessions=sessions,available=available,sound_set=sound_set}
end
