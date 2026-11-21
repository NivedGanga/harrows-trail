# World sites

The grounded layout uses seed `1730940739604968791` with Luanti 5.17.0 and Mineclonia 0.124.1. Coordinates below identify interaction points or bridge centres; buildings use separately checked footprints at local terrain heights. The construction registry and layouts are in `world_sites.lua`, `world_buildings.lua` and `world_midgame.lua` under `mod/harrows_trail/`.

| Place | X | Y | Z | Purpose |
|---|---:|---:|---:|---|
| Harrow Ranch | 654 | 19 | 652 | Opening region; barn, tack room and native horse corral |
| Red Mesa | 623 | 21 | 788 | Town region; sheriff, jail, shops and opening evidence |
| Dust Flats departure | 642 | 11 | 1012 | Choose a lantern route at night |
| Exposed shelter | 658 | 11 | 1024 | Short exposed route; dismount to read the clue |
| Northern sheltered clue | 618 | 13 | 1010 | First sheltered-route clue |
| Southern sheltered clue | 616 | 11 | 1036 | Second sheltered-route clue |
| Dry Gulch trading post | 536 | 9 | 1212 | Conclude the crossing and prepare for Iron Pass |
| Dry Gulch shop | 518 | 7 | 1210 | Ruth's lantern service |
| Dry Gulch stable | 522 | 7 | 1218 | Dutch's saddle service |
| Southern trail bridge | 504 | 15 | 689 | Checked bank anchors and a southern landing step |
| Foothill bridge | -308 | 11 | -399 | First stream near the mountain approach |
| Pass bridge | -422 | 6 | -481 | Second stream near the mountain approach |
| Iron Pass entrance | -486 | 54 | -514 | Iron-pickaxe gate |
| Western shaft obstruction | -480 | 55 | -512 | Clear first; removes matching doorway rubble |
| Eastern shaft obstruction | -474 | 56 | -514 | Clear second; opens the shaft exit |
| Silver Spur assay office | -466 | 11 | -548 | Fragment 3 |
| Silver Spur map desk | -462 | 11 | -548 | Optional reconstructed-map branch |
| Silver Spur safe | -464 | 11 | -546 | Optional cache; fixed location, one-time reward |
| Ghost Mine entrance | 559 | 22 | 832 | Filled badlands-map gate |
| Ghost Mine tracks | 559 | 22 | 840 | Nora's clue inside the supported tunnel |
| Ghost Mine office | 559 | 21 | 856 | Ledger page 1 |

The long walking corridor from Dry Gulch follows existing terrain around water. Guidance allows short detours around generated vegetation. The recorded corridor is tested in `tests/sprint6_route.json`; runtime guidance is in `world_midgame_route.lua`. This is walking evidence, not a horse-riding or graphical playtest. Narrow forest and mountain sections may require dismounting.

For existing layout-version-6 worlds, `/stagecoach station` at the Silver Spur assay office reaches the earlier elevated station after fragment 3 is found. After the breach, `/stagecoach mine` at the station reaches the grounded Ghost Mine; `/stagecoach silver` provides a return. Landing checks must pass before moving the player or the native mounted horse. New layout-version-7 worlds instead follow the grounded trails and do not use these temporary links.

New grounded worlds have layout version 7; version-6 worlds retain their existing layout and temporary station connections. Earlier unversioned grounded worlds and marker-era worlds retain their original positions, progression and stagecoach connection. No active save is opened or migrated by the tests. Placement rejects occupied or protected construction space, nearby village POIs, metadata, timers, objects, unsuitable terrain and recorded player edits. A partial placement after a crash is preserved and refused rather than repaired automatically. Direct changes made by other mods without player callbacks are not recorded by the touched-site safeguard.

## Sprint 7 sites — active in layout version 7

| Site | Centre X/Y/Z | Construction |
|---|---|---|
| Crane's Station | -300 / 19 / -213 | Plains depot, water tower, native rails, owned wall/fence barricade |
| Bitter River | 300 / 21 / 1500 | Swampland shade/hut, shallow channel, docks and flat ferry deck |
| Widowmaker | 499 / 32 / 1605 | Supported cut in exposed mountain rock within the Forest hillside; stairs and rails |

The plans are in `world_lategame.lua`. Terrain changes require explicit per-target permission and a per-site native-node whitelist; normal site rules remain unchanged. Bitter River's channel is constructed inside the footprint because this Swamp patch had no open water in the survey. Widowmaker's floor spans a natural cavity between checked rock anchors; its roof and narrow approach preserve the tree trunks. The construction test records and checks the outer boundary across restart. New version-7 worlds activate these plans on approach. Earlier worlds are not migrated. The scripted breach removes only site-owned barricade pieces and does not apply an unrestricted terrain blast. Ada handles the verdict and epilogue at her existing Red Mesa office. The tunnel wall lanterns have server-tested night light levels; rendering and actual riding remain unverified.

| Late interaction | X | Y | Z |
|---|---:|---:|---:|
| Station planning desk | -295 | 20 | -204 |
| Charge controls | -299 | 19 | -222 |
| Amos | 294 | 21 | 1500 |
| Snagged line | 297 | 22 | 1500 |
| River hideout search | 304 | 23 | 1495 |
| River ledger | 308 | 23 | 1496 |
| Widowmaker entrance support | 496 | 32 | 1600 |
| Mercer | 499 | 32 | 1604 |
| Nora | 497 | 32 | 1608 |
| Crane | 501 | 32 | 1610 |
| Ada: verdict and epilogue | 614 | 21 | 788 |

`world_lategame_routes.lua` provides advisory guidance for six corridors. `tests/sprint7_routes.json` records the surveyed routes, and the route checker requires continuous walking detours around local generated obstacles. The tunnel stairs were also checked with the engine pathfinder and explicit headroom checks. This does not establish horse clearance throughout the forest, mine or tunnel; dismount where the trail narrows.
