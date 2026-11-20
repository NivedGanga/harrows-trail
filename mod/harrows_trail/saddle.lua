-- A recovered starter replaces the previous issue, even while that issue is unloaded.
return function(storage)
 local item = 'harrows_trail:samuel_saddle'
 core.register_craftitem(item, {description="Samuel's saddle", inventory_image='mcl_mobitems_saddle.png', stack_max=1})
 local function valid(stack)
  stack = ItemStack(stack or '')
  local meta = stack:get_meta()
  local owner = meta:get_string('harrows_trail:owner')
  return owner == '' or meta:get_int('harrows_trail:issue') == storage:get_int('saddle:' .. owner)
 end
 local function issue(name)
  local serial = storage:get_int('saddle:' .. name) + 1
  local stack = ItemStack(item)
  stack:get_meta():set_string('harrows_trail:owner', name)
  stack:get_meta():set_int('harrows_trail:issue', serial)
  stack:get_meta():set_string('description', "Samuel's saddle (recoverable at the ranch)")
  return stack
 end
 local function commit(name, stack)
  storage:set_int('saddle:' .. name, stack:get_meta():get_int('harrows_trail:issue'))
 end
 core.register_craftitem('harrows_trail:retired_saddle', {description="Retired saddle issue (recovered at the ranch)", inventory_image='mcl_mobitems_saddle.png'})
 local function clean(inv)
  for index, stack in ipairs(inv:get_list('main') or {}) do
   if stack:get_name() == item and not valid(stack) then
    stack:set_name('harrows_trail:retired_saddle'); inv:set_stack('main', index, stack)
   end
  end
 end
 local horse = assert(core.registered_entities['mobs_mc:horse'])
 local native_accept, native_set, native_step = horse.is_saddle_item, horse.set_saddle, horse.on_step
 horse.is_saddle_item = function(self, stack) return valid(stack) and (stack:get_name() == item or native_accept(self, stack)) end
 horse.set_saddle = function(self, stack, clicker)
  if not valid(stack) then return false end
  return native_set(self, stack, clicker)
 end
 local function retire(self)
  if self._saddle and self._saddle ~= '' and not valid(self._saddle) then
   self:remove_saddle()
   if self._armor_inv then self._armor_inv:set_stack('main', 1, '') end
  end
 end
 horse.on_step = function(self, ...)
  retire(self)
  return native_step(self, ...)
 end
 return {item=item, valid=valid, issue=issue, commit=commit, retire=retire, clean=clean}
end
