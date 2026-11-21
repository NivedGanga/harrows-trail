return function(ctx)
 local maps=dofile(core.get_modpath('harrows_trail')..'/paper_maps.lua')(ctx)
 local definitions={
  {id='fragment_1',description="Samuel's map fragment 1",title="Samuel's map — Fragment I",map=true,text="A torn piece of Samuel's map. Nora's ribbon and Crane's tracks lead toward Red Mesa. Find the tack room and Samuel's saddle, then follow the road to the sheriff."},
  {id='fragment_2',description='Samuel’s map fragment 2',title='Samuel’s map — Fragment II',map=true,text='Recovered from Samuel’s evidence locker. Crane is pursuing the hidden payroll. Jesse knows the crossing; follow his lantern trail over the Dust Flats to Dry Gulch.'},
  {id='fragment_3',description='Samuel’s map fragment 3',title='Samuel’s map — Fragment III',map=true,text='The third fragment shows the workings at Silver Spur. Combine all three pieces at the cartography desk to read Samuel’s cache mark. Finding the gold is optional.'},
  {id='harrow_map',description='Harrow map',title='The Harrow map',map=true,text='X marks the cache inside Silver Spur’s assay office. Finding the gold is optional.'},
  {id='ledger_1',description='Crane’s ledger page 1',title='Crane’s ledger page 1',text='Crane’s route leads from the Ghost Mine to Bitter River. Nora is with him.'},
  {id='ledger_2',description='Crane’s ledger page 2',title='Crane’s ledger page 2',text='Brandt robbed the payroll. Crane knew and framed Samuel. Nora was taken toward Widowmaker Tunnel.'},
 }
 for _,doc in ipairs(definitions)do
  local function read(stack,player)
   if not player or not player:is_player()then return stack end
   if doc.map then core.show_formspec(player:get_player_name(),'harrows_trail:map',maps.build(doc.id,doc.title,doc.text))
   else ctx.message(player,doc.title,doc.text)end
   return stack
  end
  local function rightclick(stack,player,pointed)
   if not player or not player:is_player()then return stack end
   local handled=mcl_util.call_on_rightclick(stack,player,pointed)
   if handled then return handled end
   return read(stack,player)
  end
  core.register_craftitem('harrows_trail:'..doc.id,{description=doc.description,inventory_image='default_paper.png',
   on_use=read,on_place=rightclick,on_secondary_use=rightclick,
   _doc_items_usagehelp='Hold this document and right-click to read it. Sneak-right-click to read while pointing at an interactive block. Left-click also works.'})
 end
 return {maps=maps,definitions=definitions}
end
