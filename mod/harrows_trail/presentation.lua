local path=core.get_modpath('harrows_trail')
local function exists(file) local f=io.open(path..'/'..file,'rb');if not f then return false end;f:close();return true end
local function texture(name,fallback) return exists('textures/'..name) and name or fallback end
local skins={}
local colors={eli='#695843',eli_duster='#704423',ada='#253b59',jonah='#733344',dutch='#a87b37',ruth='#ad583d',amos='#325e66',jesse='#b5ad95',nora='#638259',crane='#33363a',mercer='#302d2a'}
for role,color in pairs(colors) do local file='harrows_'..role..'.png';skins[role]=texture(file,'character.png^[colorize:'..color..':140') end
local function skin(role)return skins[role] or 'character.png'end
local map={}
for _,spec in ipairs({{'wood_spruce','weathered_wood','wood'},{'wood_dark_oak','weathered_dark_wood','dark_wood'},{'wood_oak','weathered_oak','wood'}}) do
 local source='mcl_trees:'..spec[1];local target='harrows_trail:'..spec[2]
 local def=table.copy(assert(core.registered_nodes[source]));def.name=nil;def.tiles={texture('harrows_'..spec[3]..'.png',def.tiles[1])};def.description='Weathered frontier timber';def.drop=source
 core.register_node(target,def);map[source]=target
end
core.register_on_mods_loaded(function()
 for _,kind in ipairs({'office','saloon'}) do core.override_item('harrows_trail:grounded_'..kind,{tiles={texture('harrows_dark_wood.png','mcl_core_planks_big_oak.png')},sounds=mcl_sounds.node_sound_wood_defaults()}) end
 core.override_item('harrows_trail:grounded_jail',{tiles={texture('harrows_rust.png','default_stone_brick.png')},sounds=mcl_sounds.node_sound_metal_defaults()})
 core.override_item('harrows_trail:mid_dust',{tiles={texture('harrows_cloth.png','mcl_core_sandstone_normal.png')},sounds=mcl_sounds.node_sound_wood_defaults()})
end)
return {exists=exists,texture=texture,skin=skin,decorate=function(nodes)
 for _,entry in ipairs(nodes) do if map[entry.name] then entry.name=map[entry.name] end end;return nodes
end}
