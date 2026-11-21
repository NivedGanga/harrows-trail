core.after(0,function()
 local api=assert(harrows_trail_test)
 local p={};function p:get_player_name()return 'document_test'end;function p:is_player()return true end
 local state=api.load('document_test');api.states.document_test=state
 local before=core.write_json(state)
 local shown=0;local native_show=core.show_formspec
 core.show_formspec=function(name,form,text)
  assert(name=='document_test' and form=='harrows_trail:story' and #text>50)
  shown=shown+1
 end
 local native_click=mcl_util.call_on_rightclick
 mcl_util.call_on_rightclick=function()return nil end
 for _,id in ipairs({'fragment_1','fragment_2','fragment_3','harrow_map','ledger_1','ledger_2'})do
  local name='harrows_trail:'..id;local def=assert(core.registered_items[name]);local stack=ItemStack(name)
  stack:get_meta():set_string('test_saved_note','preserve me');local original=stack:to_string()
  for _,callback in ipairs({'on_use','on_secondary_use','on_place'})do
   local previous=shown;local pointed=callback=='on_place' and {type='node',under={x=0,y=0,z=0}} or {type='nothing'}
   local result=assert(def[callback])(stack,p,pointed)
   assert(shown==previous+1,id..' '..callback..' must open its document')
   assert(stack:to_string()==original and (not result or result:to_string()==original),'reading must retain the saved item unchanged')
  end
  local previous=shown;local delegated=0
  mcl_util.call_on_rightclick=function(item,player,pointed)
   assert(player==p and pointed.type=='node');delegated=delegated+1;return item
  end
  local result=def.on_place(stack,p,{type='node',under={x=0,y=0,z=0}})
  assert(result:to_string()==original and shown==previous and delegated==1,'interactive blocks must keep right-click priority')
  mcl_util.call_on_rightclick=function()return nil end
 end
 assert(shown==18 and core.write_json(state)==before,'reading must not change story progress or consume equipment')
 core.show_formspec=native_show;mcl_util.call_on_rightclick=native_click
 assert(core.registered_items['mcl_maps:empty_map'].on_secondary_use,'native map filling remains available')
 core.log('action','[document_test] PASS six documents: left-click, right-click air/block, node priority, item metadata and story state retained')
 core.request_shutdown('document regression complete',false,0)
end)
