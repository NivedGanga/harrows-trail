-- Disposable-world fixture only. Never enable this mod in a player's world.
local storage = core.get_mod_storage()
local gate = {x=3,y=221,z=4}
local function toggle(pos, node)
 local open = node.name == 'horse_pen:gate_open'
 for y=221,222 do core.swap_node({x=gate.x,y=y,z=gate.z}, {name=open and 'horse_pen:gate' or 'horse_pen:gate_open'}) end
end
for _, open in ipairs({false,true}) do
 core.register_node(open and 'horse_pen:gate_open' or 'horse_pen:gate', {
  description='Test pen gate: right-click to open or close', tiles={'default_wood.png'},
  drawtype='nodebox', paramtype='light', sunlight_propagates=true,
  node_box={type='fixed', fixed=open and {-0.5,-0.5,-0.5,0.5,0.5,-0.4} or {-0.12,-0.5,-0.5,0.12,0.5,0.5}},
  walkable=not open, diggable=false, groups={unbreakable=1}, on_rightclick=toggle,
 })
end
local building=false
local function build()
 if building or storage:get_string('ready')=='1' then return end
 building=true
 core.emerge_area({x=3,y=220,z=-2},{x=12,y=223,z=7},function(_,action,remaining)
  if action==core.EMERGE_ERRORED or action==core.EMERGE_CANCELLED then building=false; return end
  if remaining~=0 then return end
  local walls={}
  for x=3,12 do for z=-2,7 do
   if x==3 or x==12 or z==-2 or z==7 then
    for y=221,222 do walls[#walls+1]={x=x,y=y,z=z} end
   end
  end end
  for _,p in ipairs(walls) do
   if core.get_node(p).name~='air' then
    core.log('error','[horse_pen] Occupied test pen boundary; nothing replaced at '..core.pos_to_string(p))
    building=false; return
   end
  end
  for _,p in ipairs(walls) do
   core.set_node(p,{name=p.x==gate.x and p.z==gate.z and 'horse_pen:gate' or 'harrows_trail:rail'})
  end
  local obj=core.add_entity({x=8,y=222,z=2},'mobs_mc:horse')
  if not obj then core.log('error','[horse_pen] Native horse spawn failed'); building=false; return end
  local horse=obj:get_luaentity()
  horse.persistent=true
  storage:set_string('ready','1')
  core.log('action','[horse_pen] Native horse and test pen placed; tamed='..tostring(horse.tamed))
  building=false
 end)
end
core.register_on_joinplayer(function(player)
 -- The main mod places the ranch asynchronously on first join.
 local function wait(attempt)
  if core.get_node_or_nil({x=8,y=221,z=0}) and core.get_node({x=8,y=221,z=0}).name=='harrows_trail:corral' then
   build()
  elseif attempt<60 then core.after(1,wait,attempt+1)
  else core.log('error','[horse_pen] Ranch marker unavailable; pen not placed') end
 end
 core.after(1,wait,0)
end)
