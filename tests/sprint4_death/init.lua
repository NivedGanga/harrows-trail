local api=assert(harrows_trail_test)
local phase=core.settings:get('harrows_death_phase')
local function finish()
 core.log('action','[sprint4_death] PASS '..phase)
 core.request_shutdown('Death test finished',false,0)
end
if phase=='write' then
 core.register_on_joinplayer(function(player)
  core.after(2,function()
   local name=player:get_player_name(); local s=api.states[name]; local inv=player:get_inventory()
   s.flags.ledger2=true
   inv:add_item('main','mcl_core:apple_gold 4')
   inv:add_item('main',mcl_armor.colorize_leather_armor(ItemStack('mcl_armor:chestplate_leather'),mcl_dyes.colors.brown.rgb))
   local bow=ItemStack('mcl_bows:crossbow_loaded'); bow:get_meta():set_string('arrow','mcl_bows:arrow'); inv:add_item('main',bow)
   assert(api.chapter.unlock(player,s,9)); api.save(name)
   assert(not inv:contains_item('main','mcl_core:apple_gold'))
   player:set_hp(0,{type='set_hp',from='mod',reason='sprint4_death_test'})
  end)
 end)
 core.register_on_dieplayer(function(player)
  local name=player:get_player_name(); local s=api.states[name]
  assert(s.unlocked['9'] and s.act>=9); api.save(name)
  core.after(1,finish)
 end)
elseif phase=='read' then
 core.after(0,function()
  local s=api.load('sprint4_death_player')
  assert(s.unlocked['9'] and s.act>=9)
  finish()
 end)
else error('unknown death test phase') end
