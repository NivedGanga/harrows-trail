local a=assert(harrows_trail_test);local w=a.atmosphere
local phase=core.settings:get('harrows_sprint10_phase')
local function snapshots()
 local out={};for day=0,90 do for _,id in ipairs({'red_mesa','dust_flats','dry_gulch','bitter_river','ranch','widowmaker'}) do out[#out+1]=w.weather('fixed-test-seed',day,id,.25) end end;return core.write_json(out)
end
core.after(0,function()
 if phase=='read' then
  assert(a.storage:get_string('weather_snapshot')==snapshots());core.log('action','[sprint10_test] PASS read');core.request_shutdown('weather test complete',false,0);return
 end
 assert(w.region({x=623,y=21,z=788})=='red_mesa');assert(w.region({x=687,y=21,z=788})=='red_mesa');assert(not w.region({x=687.1,y=21,z=788}))
 assert(not w.region({x=623,y=69,z=788}) and not w.region({x=20000,y=0,z=20000}))
 assert(w.palette('dust').fog.fog_distance>=96 and w.palette('fog').fog.fog_distance>=96)
 local storm_day
 local seed=core.get_mapgen_setting('seed')
 for day=0,100 do if w.weather(seed,day,'red_mesa',.5)=='dust' then storm_day=day;break end end;assert(storm_day)
 local original={light=core.get_natural_light,day=core.get_day_count,tod=core.get_timeofday,clock=core.get_gametime,particle=core.add_particle,sound=core.sound_play,stop=core.sound_stop}
 local meta=ItemStack('mcl_core:stone'):get_meta();meta:set_string('harrows_trail:audio','on')
 local p={pos={x=623,y=21,z=788},skies=0}
 function p:get_meta()return meta end;function p:get_player_name()return 'weather_probe'end;function p:get_pos()return self.pos end
 function p:get_sky()return {type='regular'}end;function p:set_sky(def)self.skies=self.skies+1;self.sky=def end
 function p:set_sun(def)self.sun=def end;function p:set_moon()end;function p:set_stars()end;function p:override_day_night_ratio()end
 core.get_natural_light=function()return 15 end;core.get_day_count=function()return storm_day end;core.get_timeofday=function()return .5 end
 local fake_time=1;core.get_gametime=function()return fake_time end
 local particles,sounds,stops=0,0,0
 core.add_particle=function(def)assert(def.playername=='weather_probe' and def.expirationtime<=2);particles=particles+1 end
 core.sound_play=function(_,def)assert(def.to_player=='weather_probe');sounds=sounds+1;return sounds end
 core.sound_stop=function()stops=stops+1 end
 if phase=='missing' then
  assert(not w.available.wind and not a.presentation.exists('textures/harrows_ada.png'))
  assert(a.finale.scene({verdict='justice'}):find('character.png',1,true))
  local emitted,handles=w.update(p);assert(emitted==0 and handles==0)
 else
  assert(w.available.wind and w.available.saloon)
  local emitted,handles=w.update(p);assert(emitted==12 and handles<=2 and particles==12)
  w.update(p);assert(particles==12,'command bursts must not bypass particle cooldown');assert(sounds<=2,'unchanged ambience must reuse its handles')
  fake_time=fake_time+2;meta:set_string('harrows_trail:effects','low');assert(w.emit(p,'red_mesa','dust')==4)
  meta:set_string('harrows_trail:effects','off');assert(w.emit(p,'red_mesa','dust')==0)
  meta:set_string('harrows_trail:effects','on')
  p.pos={x=620,y=21,z=788};w.update(p);assert(#w.sessions.weather_probe.handles<=2)
  meta:set_string('harrows_trail:audio','off');w.update(p);assert(#w.sessions.weather_probe.handles==0 and stops>0)
 end
 core.emerge_area({x=610,y=18,z=780},{x=625,y=26,z=795},function(_,_,left)
  if left~=0 then return end
  core.after(0,function()
   local obj=assert(core.add_entity({x=614,y=21,z=788},'harrows_trail:opening_actor','ada'));local ent=obj:get_luaentity()
   if phase=='missing' then assert(obj:get_properties().textures[1]:find('character.png',1,true)) else
    assert(obj:get_properties().textures[1]=='harrows_ada.png')
    local native_weather=mcl_weather.state;mcl_weather.state='rain'
    mcl_weather.skycolor.update_sky_color({p});assert(p.sun.visible and p.sky.fog.fog_distance==128)
    mcl_weather.state=native_weather
    local s=a.load('weather_probe');local start=core.get_us_time()
    meta:set_string('harrows_trail:audio','on')
    for _=1,500 do fake_time=fake_time+2;w.update(p);a.cast.tick(ent,p,s) end
    local ms=(core.get_us_time()-start)/1000;assert(ms<2000,'500 active server updates exceeded the smoke-test CPU budget')
    core.log('action','[sprint10_test] server_update_500_ms='..ms..' npc=active weather=dust particle_cap=12 audio_cap=2 graphical_fps=unverified')
   end
   obj:remove();p.pos={x=20000,y=0,z=20000};w.update(p);assert(not w.sessions.weather_probe)
   core.get_natural_light=original.light;core.get_day_count=original.day;core.get_timeofday=original.tod;core.get_gametime=original.clock
   core.add_particle=original.particle;core.sound_play=original.sound;core.sound_stop=original.stop
   if phase=='write' then a.storage:set_string('weather_snapshot',snapshots()) end
   core.log('action','[sprint10_test] PASS '..phase);core.request_shutdown('weather test complete',false,0)
  end)
 end)
end)
