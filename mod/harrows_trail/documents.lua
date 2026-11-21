-- Keep existing document text/left-click behavior, and support native right-click use.
for _,id in ipairs({'fragment_1','fragment_2','fragment_3','harrow_map','ledger_1','ledger_2'}) do
 local name='harrows_trail:'..id
 local read=assert(core.registered_items[name].on_use)
 local function rightclick(stack,player,pointed)
  if not player or not player:is_player() then return stack end
  local handled=mcl_util.call_on_rightclick(stack,player,pointed)
  if handled then return handled end
  return read(stack,player,pointed) or stack
 end
 core.override_item(name,{on_place=rightclick,on_secondary_use=rightclick,
  _doc_items_usagehelp='Hold this document and right-click to read it. Sneak-right-click to read while pointing at an interactive block. Left-click also works.'})
end
