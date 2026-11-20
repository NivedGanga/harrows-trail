-- All item/payment changes happen synchronously within a single inventory callback.
return function(inv, reward, payment)
 local stack = ItemStack(reward)
 local cost = payment and ItemStack(payment)
 if stack:is_empty() or not inv:room_for_item('main', stack) then return false end
 if cost and not inv:contains_item('main', cost) then return false end
 local before = inv:get_list('main')
 local leftover = inv:add_item('main', stack)
 if not leftover:is_empty() then
  inv:set_list('main', before)
  return false
 end
 if cost then
  local removed = inv:remove_item('main', cost)
  if removed:get_count() ~= cost:get_count() then
   inv:set_list('main', before)
   return false
  end
 end
 return true
end
