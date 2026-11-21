return function(ctx)
 local function report(name)
  local s=ctx.states[name];if not s then return false,'Join the trail before requesting a report.' end
  local placed={};for id in pairs(ctx.sites.registry) do if ctx.sites.placed(id) then placed[#placed+1]=id end end;table.sort(placed)
  -- Deliberately exclude player names, inventory, coordinates and hidden scores.
  return true,core.write_json({release='RC1',engine=core.get_version().string,game_pin='Mineclonia 0.124.1',schema=s.version,
   layout=ctx.storage:get_string('world_layout_version'),act=s.act,verdict=s.verdict or 'pending',
   crane=s.flags.crane_outcome or 'unresolved',nora_freed=not not s.flags.nora_freed,sites=placed})
 end
 core.register_chatcommand('trail_report',{description='Show a privacy-limited trail diagnostic for your own progress',func=report})
 return {report=report}
end
