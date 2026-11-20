# Harrow's Trail: Game Design Document

Version 1.0 · Platform: Luanti with the Mineclonia game · One persistent single-player world · Status: pre-production

## 1. Overview

Harrow's Trail is a Western rescue story set in a free, Minecraft-style sandbox. The player is Eli Harrow, a rancher's son whose younger sister, Nora, is kidnapped by the outlaw Silas Crane. The goal is to bring her home. On the way, Eli crosses the frontier, learns what happened to his father, and finally decides what becomes of Crane.

The game is one persistent world with no timer and no fixed length. Progress comes from gathering what each mission needs: a saddle to ride, lanterns to cross the desert at night, gold to post bail, and so on. Mining, exploring, and crafting are part of the story rather than detours from it.

The design rests on four pillars. The rescue is the goal, and every act moves Eli closer to Nora. Gates are earned rather than timed: each act unlocks when the player brings the right item, and the unlock stays. The verdict belongs to the player, since Crane's fate depends on the honor Eli has earned and what he has learned. Finally, the frontier should feel lived in, with NPCs on daily routines, towns with their own character, and weather that changes the mood.

The core loop is explore, gather, prepare, travel, investigate, and resolve a situation. Each act must include at least one memorable playable beat—such as navigating a storm, making a consequential choice, solving a route problem, or negotiating a dangerous crossing. Required items open opportunities; they should not be the whole activity or substitute for a mission. The rescue remains present through fresh clues and changes in Crane's trail, but there is no countdown or punishment for taking time to explore.

The first playable proof of the concept is a short vertical slice: the burned ranch, the ride to Red Mesa, a useful interaction with Ada, and one encounter or choice that changes how an NPC responds. Test whether players feel they are pursuing Nora and uncovering a mystery, rather than completing a shopping list, before expanding the world.

## 2. Platform and Tools

The game runs on Luanti, a free, open-source voxel game engine for Windows, macOS, Linux, and Android. Luanti on its own contains no playable game. The gameplay comes from Mineclonia, a free Minecraft-style game for Luanti that provides mining, crafting, lava, diamonds, villages, and wandering traders. Harrow's Trail is a Lua mod that runs on top of Mineclonia.

The official Minecraft Java and Bedrock editions cost about $30 on PC. The free browser version, Minecraft Classic, cannot save progress and does not support mods, so it cannot carry a story. Luanti and Mineclonia are both free and support Lua mods, which makes them the practical choice.

Several constraints come with this stack. Mineclonia is marked as beta, so the mod pins its version and the world is backed up before any update. Mineclonia has no in-game music, so the soundtrack has to be added through a sound mod. Its documentation says large structures are still being worked on, so towns are placed as schematic files. Mineclonia already supports riding horses, but saddles are loot rather than craftable items; the story therefore provides Samuel's saddle at the ranch and avoids depending on a saddle recipe or a custom riding system.

The tools are Luanti with its built-in content browser (ContentDB) for installing Mineclonia, texture packs, and helper mods; a WorldEdit-style building mod for creating schematic files; a plain text editor for Lua; and Git for version control.

## 3. Story

### 3.1 Premise

Eli Harrow lives on his family's ranch on the grasslands with his younger sister, Nora. Their father, Samuel Harrow, died in the Red Mesa jail while awaiting trial for a robbery he did not commit. One night, raiders burn the ranch and take Nora. They are led by Silas Crane, a former railroad detective turned outlaw. Crane believes Nora knows where Samuel hid the railroad payroll, and he plans to trade her for a way out of the territory. Eli sets out to bring her home.

### 3.2 What happened before the story

Years before the story begins, the railroad's payroll train was robbed near Red Mesa. The robbery was carried out by Lyle Brandt, Crane's partner. Brandt hid part of the gold, but Samuel Harrow found the cache by chance and recovered most of it to keep it out of the gang's hands. Crane, by then a railroad detective, needed a conviction to close the case, so he arrested Samuel for the robbery. Samuel never got a trial. He died in the Red Mesa jail, and the gold stayed hidden.

### 3.3 How the story unfolds

Each piece of the truth comes out in a set order. In Act 1, the player learns that Crane took Nora and burned the ranch. In Act 3, the sheriff reveals that Crane was once a railroad detective, and the jailed outlaw Jesse Moss rode with him. From Acts 3 to 5, the player learns that Crane is hunting the gold Samuel hid. Ledger page 1, found in Act 7, shows Crane's route. Ledger page 2, found in Act 8, reveals that Brandt committed the robbery and that Crane knew it and framed Samuel anyway. The gold itself is hidden in Silver Spur, and its location can be found by combining the three map fragments.

Nora's silence is her own choice. She never told Crane where the gold is because she did not trust him to keep his word, and she knew that giving him the location would put the people of Red Mesa in danger.

### 3.4 Themes

The story asks who gets to decide what justice looks like when the law has failed. Crane is a villain, but he was also used by a man he trusted, and he was then willing to frame an innocent man to protect his own career. Eli has to decide whether to repeat that cycle, and the player's choices in the final act show the answer.

## 4. Characters

**Eli Harrow** (player character). A rancher's son who knows horses and hard work. Eli has no combat or skill stats. His abilities come from the items he gathers, and his reputation comes from what he does. Dialogue choices are mostly neutral, and the world reacts to actions more than to words.

**Nora Harrow**. Eli's younger sister, nineteen, sharp and stubborn. She kept their father's last letter and refused to tell Crane anything. She appears at Crane's hideouts, and her trust in Eli rises when he keeps his promises to people in danger. Her reaction in the final act shapes the epilogue.

**Samuel Harrow** (deceased). Seen through his letter, the map fragments, ledger, and the saddle he left in the ranch tack room. His memory drives the search, and Eli rides Samuel's saddle when he begins the rescue. Samuel was arrested for a robbery he did not commit and died in the Red Mesa jail before trial.

**Silas Crane** (antagonist). A former railroad detective who is methodical, polite, and convinced the railroad cheated him out of his reward. He moves between hideouts: Crane's Station, the Dry Gulch Ghost Mine, the Bitter River ferry, and the Widowmaker Tunnel. He leaves taunting messages on bounty boards, which the player can find and follow.

**Lyle Brandt** (deceased). Crane's former partner and the real robber of the payroll. He died in a fight at Bitter River years ago. Ledger page 2 names him.

**Sheriff Ada Wells**. The sheriff of Red Mesa. She is honest but overstretched. She doesn't trust Crane's men, but she needs evidence before she acts. She works the office by day, patrols at night, and posts wanted notices. After bail is posted, she gives Eli the second map fragment from the evidence locker. If Eli's wanted level is high, she orders deputies to bring him in.

**Jesse Moss**. A former member of Crane's gang, held in the Red Mesa jail. He knows the route to Crane's hideouts and will guide Eli across the Dust Flats if released. After the crossing he rides off on his own. He can be found again at the Bitter River ferry, where he has been hiding.

**Jonah Pike**. The bartender at the Red Mesa saloon. He is talkative and a source of rumors. He works the saloon in the evenings, and the rumor board changes as the player meets Crane's men or wins fights. He sells information for a few gold, and the price drops when Eli's honor is high.

**Dutch Hale**. The stable hand at Dry Gulch. He sells saddles and feed and trains horses. He tends the stables from morning until dusk and sleeps in the hayloft at night.

**Ruth Calloway**. Owner of the Dry Gulch trading post. She is shrewd and fair, and she keeps the shop open all day. She sells the fallback item for any gate at a steep gold price, so no player is stuck for long.

**Amos Reed**. The ferryman at Bitter River. He runs the ferry only in daylight and sits by a fire at night. He charges a fee in gold, which is waived when Eli's honor is high.

**Mercer**. Crane's lieutenant and the guard at the Widowmaker Tunnel. He fights to the end, but he can also surrender. He can be defeated in a duel or talked into surrender, and a surrender raises Nora's trust.

## 5. World and Locations

The map uses Mineclonia's natural biomes to suggest the frontier. Each location is fixed in place so that story events and schematics line up.

| Location | Biome | Role |
| --- | --- | --- |
| Harrow Ranch | Savanna | Starting point; burned ranch, reachable tack room with Samuel's saddle, and barn with map fragment 1 |
| Red Mesa | Mesa and badlands | Town with sheriff's office, saloon, bank, and jail |
| Dust Flats | Desert | Night crossing between Red Mesa and Dry Gulch; dangerous after dark |
| Dry Gulch | Plains | Trading post, stables, and Ruth's shop |
| Dry Gulch Ghost Mine | Badlands, north of Dry Gulch | Abandoned mine where Crane keeps his first hideout |
| Iron Pass | Snowy mountains | Route into the mountains and a collapsed shaft to Silver Spur |
| Silver Spur | Mountain foothills | Abandoned mining camp; the assay office holds map fragment 3 and the gold cache |
| Crane's Station | Plains beside a railway | Depot used as a hideout; site of the barricade |
| Bitter River | Swamp | Ferry crossing and Crane's second hideout |
| Widowmaker Tunnel | Mountain rock | Old railway tunnel where Nora is held |

The Dust Flats are the only area where nights are dangerous enough to need lanterns. Weather is covered in section 8.

## 6. Progression: The Ten Acts

The story is split into ten acts. Each act has a goal, a gate, and an outcome. A gate is an item or story-state check made when the player talks to an NPC, enters a location, or tries to start the act.

| Act | Goal | Gate | Outcome |
| --- | --- | --- | --- |
| 1. Ashes | Search the burned ranch for Nora's trail | None | Fragment 1 found in the barn; tracks point to Red Mesa |
| 2. Horseback | Find Samuel's saddle, fit it to a tamed horse, and ride to Red Mesa | Samuel's saddle fitted to a tamed horse | Eli reaches Red Mesa and the sheriff's office opens |
| 3. The Sheriff | Post bail for Jesse Moss | 9 gold ingots (1 gold block) | Jesse is released, Ada gives fragment 2, and Crane's route begins |
| 4. Dust Road | Cross the Dust Flats at night to Dry Gulch | 4 lanterns | Lanterns reveal trail markers and safe shelters; Eli chooses between a faster exposed route and a longer sheltered route through dangerous weather |
| 5. Iron Pass | Clear the collapsed shaft to Silver Spur | Iron pickaxe | Fragment 3 is found and the gold cache can be located |
| 6. Crane's Station | Breach the barricade | 1 TNT block | The player chooses where and when to place and trigger the TNT; Crane escapes with Nora, leaving a clue to the ghost mine |
| 7. The Hunt: Ghost Mine | Find Crane's first hideout | A filled map of the badlands | Ledger page 1 reveals his route |
| 8. The Hunt: Bitter River | Reach the ferry and search Crane's second hideout | A spruce boat | Eli can pay Amos, earn a fee waiver through high honor, or clear a snagged ferry line; ledger page 2 reveals the truth about the robbery |
| 9. The Hunt: Widowmaker Tunnel | Reach Nora and confront Crane | 4 golden apples, a brown duster, and a loaded crossbow | The player overcomes Mercer, can free Nora, and can capture or lose the chance to capture Crane alive |
| 10. The Verdict | Decide Crane's fate | Depends on honor and ledger pages (section 9) | Ending and epilogue |

Failing a gate has no penalty. It only means the player is not ready yet. There is no game over. Death sends the player back to their last bed or to spawn, and dropped items can be recovered. Once an act is unlocked, it stays unlocked.

A gate grants access to the next story opportunity; it does not automatically complete the act. Each act needs a clear objective and a playable resolution, and the journal or NPC dialogue should say what to do next. Optional exploration and side activities must not be required to repeat routine mining just to keep the main story moving.

## 7. Gate System

Gate checks evaluate inventory and relevant story state. When a gate is met, the mod marks the act as unlocked and saves the state. Some gate items are consumed and others are kept. Bail gold and TNT are consumed when their associated act starts. The four golden apples are handed over as rescue supplies and consumed once when Act 9 starts; they are not also consumed by a separate “use” action. Saddles, lanterns, pickaxes, boats, the brown duster, and the crossbow are kept, since they are needed again later. The Act 2 gate checks that Eli has a tamed horse equipped with a saddle; merely carrying a saddle is not enough. Gate text must identify what will be consumed before the player confirms.

Gates are defined in the act data, not in NPC dialogue. An NPC can describe what is needed, but the gate validator checks the required items or story state before an act starts.

Each NPC gives a short hint about the next gate. Ada says where gold can be mined, and Dutch explains how to fit a saddle and tame a horse; he sells replacement saddles at Dry Gulch. Hints never give exact coordinates, so the player still has to explore.

Ruth sells the fallback item for every gate at a steep gold price, starting at Act 4. The fallback exists so that no player is stuck, but it costs gold the player would otherwise use for bail or fines. Main-story progression should not depend on an unlimited mining grind: provide useful hints, more than one reasonable way to obtain common materials, and a fallback price that can be reached through ordinary exploration and play. Test the economy in a full run, including the cost of bail and likely fines.

## 8. Game Systems

### 8.1 Honor

Honor is a hidden score from 0 to 100. It starts at 50. The values in this document are starting targets that should be tuned during playtesting.

| Action | Honor change |
| --- | --- |
| Return a stolen item to its owner | +5 |
| Help a townsperson with a request | +3 |
| Pay a debt owed to a townsperson | +5 |
| Steal a horse or goods | -5 |
| Attack a townsperson or deputy without cause | -10 |
| Kill a bystander in a fight | -20 |

Honor affects prices, the rumors Jonah shares, Amos's ferry fee, and the verdict options in Act 10. The exact score remains hidden, but the journal gives plain-language feedback at meaningful thresholds (for example, “trusted in Red Mesa” or “known for trouble”), and important actions produce a short response explaining the change. A locked verdict explains its unmet requirements without exposing an exact score.

### 8.2 Wanted Level

The wanted level runs from 0 to 4 stars. Attacking a deputy adds one star, stealing a horse adds one star, and shooting a townsperson adds two stars.

At 3 stars, deputies attack Eli on sight in any town. At 4 stars, wanted posters appear in every town and bounty hunters ride the roads. The player can lower the level by paying a fine of three gold ingots per star, or by staying out of sight for one full day and night cycle.

### 8.3 Nora's Trust

Nora's trust is a hidden score from 0 to 100. It starts at 50. It rises when Eli keeps promises, such as returning stolen goods, and when he spares an outlaw who surrenders, as he can with Mercer or a gang member at Crane's Station. It falls when Eli abandons someone in danger or kills a prisoner who has surrendered. The Act 10 options use it, and Mercy requires a trust of at least 60. Nora's dialogue and the journal should signal whether trust is improving, worsening, or at risk, and explain which past actions affected her without showing a numeric score.

### 8.4 Maps, Ledger, and Documents

Samuel's map is split into three fragments. The first is hidden in the barn, the second is given by Ada, and the third is found in Silver Spur's assay office. A cartography table combines the fragments into the Harrow map, which marks the gold cache. The player can also fill maps of the badlands and the Dust Flats through exploration, and a filled badlands map is the Act 7 gate.

Crane's ledger has two pages. They are written books that the player finds in Acts 7 and 8, and they explain the route and the truth about the robbery.

Telegrams from the sheriff and wanted posters are written books. Bounty boards in each town show posters that update with the wanted level.

### 8.5 Horses and Travel

Mineclonia's native horses are rideable when saddled, so the mod should use that system rather than build a custom horse entity or riding mechanic. Samuel's saddle is a guaranteed, non-consumable story item in the ranch tack room. Eli must tame a horse and fit the saddle to it to pass Act 2; Dutch sells replacement saddles once Eli reaches Dry Gulch. If Samuel's saddle is lost before Dutch is reachable, it is restored to its marked place in the tack room, preventing an early softlock. If Eli's horse dies, the saddle returns to his inventory so he can tame another horse. Eli can name his horse, and the horse stays his when he logs out. Stables in each town keep horses safe overnight. Pack animals, such as trader llamas or mules, carry extra supplies on long trips.

If a horse dies, it is lost, and Eli must tame another one or walk to the next stable.

If reliable riding and persistence cannot be implemented early, use a tested horse mod or temporarily substitute a simpler travel system rather than delaying the first story slice for a custom mount implementation.

### 8.6 Camp and Rest

A campfire, a smoker for cooking, a barrel for supplies, and a bed let Eli rest. Sleeping through the night advances the day. The game saves automatically when the player sleeps, leaves a town, or finishes an act.

### 8.7 Day, Night, and Weather

Day and night follow Mineclonia's cycle. Nights are safe in towns and dangerous on the Dust Flats. Weather adds mood: dust storms roll across Red Mesa and Dry Gulch, rain falls in the swamp, and morning fog sits on Bitter River. Storms are chosen at random each day from a seed, so the same day produces the same weather after a reload.

### 8.8 NPC Routines

NPCs follow schedules based on the time of day.

| Character | Day | Evening | Night |
| --- | --- | --- | --- |
| Ada Wells | Sheriff's office | Patrols Red Mesa | Sleeps in the office |
| Jonah Pike | Cleaning the saloon | Saloon | Saloon until closing |
| Dutch Hale | Stables | Stables | Hayloft |
| Ruth Calloway | Trading post | Trading post | Shop closed |
| Amos Reed | Ferry | Fire by the ferry | Fire by the ferry |
| Jesse Moss | Jail cell until released, then wandering | Wandering or hiding | Hiding |

Crane has no fixed routine. He moves to a new hideout after each act, so the player must follow the clues he leaves.

## 9. Act 10: The Verdict and Endings

Once Nora is safe, Eli decides Crane's fate. The options shown depend on Eli's honor, Nora's trust, and which ledger pages Eli has found. Locked options are shown greyed out with the reason, so the player knows what to aim for.

| Verdict | Requirements | What happens |
| --- | --- | --- |
| Justice: bring Crane to Red Mesa for trial | Crane taken alive; honor at least 50 | Sheriff Wells takes Crane into custody. The town holds a trial scene, the ledger is read in court, and Eli's standing in Red Mesa rises. |
| Mercy: let Crane ride out of the canyon | Honor at least 60; both ledger pages; Nora's trust at least 60 | Crane vanishes into the badlands and can return later as a rival in a sequel chapter. Nora agrees to the choice because her trust is high enough. |
| Vengeance: finish the duel yourself | Open to anyone who reaches the tunnel | Eli kills Crane. The wanted level rises, Nora may leave him, and the ending shows Eli riding alone under a red sky. |

If Nora is with Eli at the verdict, her reaction depends on her trust. At high trust she argues for the choice she believes in, and at low trust she may walk away from the confrontation entirely.

The “taken alive” state must be a real, legible gameplay outcome, not an assumption based only on the player's equipment. In the final encounter, Crane yields after a defined nonlethal condition or surrender event. The player then gets an explicit choice to restrain and take him to Red Mesa, let him go, or kill him. Killing him removes Justice and Mercy; capturing him alive enables Justice, while Mercy still requires its listed honor, trust, and ledger conditions. If the player kills Crane during the encounter, the game records that outcome and does not offer a contradictory “bring him to trial” option.

### 9.1 The Gold Choice

The gold choice comes after the verdict and is independent of it, but it changes the epilogue. It is only offered if Eli has found the gold cache at Silver Spur. Eli can return the gold to the railroad, which strengthens the Justice epilogue. He can keep it, which leaves a rough reputation in Red Mesa. Or he can use it to rebuild the ranch, which strengthens the Mercy epilogue.

### 9.2 Epilogues

Each ending closes with a short epilogue screen written in a book-style interface, followed by a single scene. After Justice, Eli and Nora stand in the Red Mesa courthouse as the sheriff reads the verdict. After Mercy, they ride back to the rebuilt ranch together. After Vengeance, Eli rides alone toward the horizon. Epilogue text changes depending on the gold choice and on Nora's trust. The gold cache is an optional story and epilogue branch, not a requirement to rescue Nora or reach the main verdict; its map puzzle should reward exploration without creating a second mandatory grind.

## 10. Atmosphere and Audio

The visual palette is warm and faded, with browns, dusty yellows, and muted blues at night. A custom texture pack replaces the default textures with weathered wood, rusted iron, and sun-faded cloth. Lanterns and campfires give warm light, and the Dust Flats take on a yellow haze during storms. Tone and color should come from the texture pack and sky settings first. Any extra shader effects depend on the engine's shader options, so test them before relying on them.

Mineclonia has no in-game music, so the soundtrack is added by a sound mod. It includes wind loops that change by region, crickets at night, a distant train whistle near the railway, a looping piano or harmonica tune in the saloon, and footstep sounds that differ between sand, wood, gravel, and stone. Any original or licensed music must be checked for license terms before the game is shared.

| Region | Sound | Visual mood |
| --- | --- | --- |
| Harrow Ranch | Wind, cattle lowing, distant birds | Golden hour, wooden fences |
| Red Mesa | Saloon piano, boots on boardwalks, church bell | Dark oak false fronts, lanterns |
| Dust Flats | Wind, sand hiss, distant coyotes at night | Yellow haze, dust storms |
| Silver Spur | Creaking timbers, dripping water | Dim, lantern-lit tunnels |
| Bitter River | Frogs, ferry bell, wind over reeds | Fog, reeds, dark water |
| Widowmaker Tunnel | Echoing footsteps, distant train | Dark stone, iron rails |

The western look also comes from the items themselves. Lanterns, barrels, and hanging signs serve as shop decorations. Leather helmets dyed brown become hats, and renamed crossbows read as rifles. Written books serve as telegrams and wanted posters, which gives the story a paper trail.

## 11. Architecture and Build Guide

Each town has a distinct shape. Red Mesa has a main street of dark oak false fronts, a sheriff's office with a barred window, a saloon with swinging doors, a sandstone bank, a small stone jail, and a bell tower on the church. Dry Gulch has a trading post with a wooden porch, spruce stables with a hayloft, and a water tower for the railway. Silver Spur is an abandoned mining camp with shacks, a headframe over the mine shaft, an assay office with a safe, and tailings piles of dirt and gravel. Crane's Station is a railway depot with rails, a water tower, and barricades built from cobblestone walls and fences. Bitter River has a ferry dock, stilt huts over the water, and a flat ferry boat. Widowmaker Tunnel is a stone mouth framed with wooden supports and iron rails.

The table below suggests Mineclonia blocks for each look. Always check the block palette in the game first, since names and availability can change between versions.

| Look element | Suggested blocks | Notes |
| --- | --- | --- |
| False-front wooden buildings | Dark oak planks, stairs, and slabs | Stairs create the sloped roofline |
| Adobe walls | Sandstone or terracotta | Smooth variants look like plaster |
| Spruce barns | Spruce planks and fences | Hay bales for the hayloft if available |
| Lanterns | Lantern blocks or torches on fence posts | Confirm lantern blocks exist in the game |
| Railway | Rails and basic minecarts | Listed as part of the base game; verify |
| Bell towers | Bell blocks if available | Substitute a similar block if not |
| Barricades | Cobblestone walls and fences | Stand in for sandbags |

The build process runs in five steps. First, build each town in creative mode with the building mod. Second, export each town as a schematic file into the mod's schematics folder. Third, flatten each site before placing the schematic, so it isn't buried by terrain. Fourth, place each town with force placement so the schematic overwrites loose terrain. Fifth, record a flag in the saved state so each town is placed only once. Towns should be placed when the player first comes within range, not during world generation, so the procedural terrain stays intact.

Since the world is procedurally generated, the coordinates of each fixed location must be chosen in advance. Mineclonia may also spawn its own villages, so the mod should either choose coordinates far away from those spawns or disable village generation near the Western sites. Each site should be checked in the game after placement.

## 12. Items and Equipment

| Item | Source | Use |
| --- | --- | --- |
| Saddle | Samuel's guaranteed saddle in the ranch tack room; replacement saddles sold by Dutch at Dry Gulch | Fit to a tamed horse to ride; Act 2 gate checks the horse's saddled state. The ranch saddle is recoverable and is never consumed by the gate |
| Lantern | Crafted from iron nuggets and torches | Dust Road gate (Act 4); carried at night |
| Gold ingots and gold block | Mined in the badlands | Bail (Act 3) and fines |
| Iron pickaxe | Crafted from iron | Iron Pass gate (Act 5) |
| TNT block | Crafted from gunpowder and sand | Crane's Station gate (Act 6) |
| Filled badlands map | Cartography table from an explored map | Act 7 gate |
| Spruce boat | Crafted from spruce planks | Act 8 gate |
| Golden apples | Crafted from gold and an apple | Act 9 gate; four are handed over as rescue supplies and consumed once when the act starts |
| Brown duster | Leather armor dyed brown | Act 9 gate and the western look |
| Loaded crossbow | Crafted from sticks, string, and iron | Act 9 gate, shown as a rifle |
| Map fragments 1 to 3 | Found in the barn, given by Ada, found in Silver Spur | Combined into the Harrow map |
| Harrow map | Cartography table from the three fragments | Marks the gold cache |
| Ledger pages 1 and 2 | Written books | Crane's route and the truth about the robbery |
| Telegrams and wanted posters | Written books | Messages from the sheriff and bounty notices |

Some of these items are new and must be added by the mod: the three map fragments, the two ledger pages, the telegram and poster books, and the Harrow map. Others already exist in Mineclonia and need their exact item names checked in the game's item registry before use. The gate code should refer to items by those registered names, not by display names.

## 13. Technical Design

This section is written for whoever builds the mod. It describes how the game's systems fit together. Function names below are the intended design, and they should be checked against Luanti's Lua API reference when coding begins.

### 13.1 Stack and Versions

The game runs on Luanti 5.10 or later, which is the minimum version listed for Mineclonia. The development machine and the test machine should run the same Luanti version. Mineclonia is pinned to one release for the whole project, and any update is tested in a copy of the world before it is applied to the main save. The mod is written in Lua and uses only Luanti's built-in API plus Mineclonia's exposed item and block names.

### 13.2 File Structure

The mod lives in a single folder named harrows_trail inside the Luanti games or mods directory. The planned layout is below.

```
harrows_trail/
  mod.conf
  init.lua
  core/state.lua      -- load, save, and migrate player state
  core/gates.lua      -- inventory checks and item consumption
  core/acts.lua       -- the ten-act state machine and definitions
  core/honor.lua      -- honor, wanted level, and Nora's trust
  npc/init.lua        -- NPC entity registration
  npc/routines.lua    -- time-of-day schedules and waypoints
  ui/dialogue.lua     -- dialogue trees and formspecs
  ui/items.lua        -- telegrams, ledger pages, and posters
  world/towns.lua     -- schematic placement and site flags
  world/weather.lua   -- seeded dust storms and fog
  world/cutscene.lua  -- locked controls, letterbox, and camera path
  mobs/horse.lua      -- saddled horse entity or wrapper
  schematics/         -- exported town files
  sounds/             -- ambient loops and music
  textures/           -- Western texture overrides
  locale/             -- translatable strings
```

### 13.3 Metadata

The mod.conf file sets the mod name to harrows_trail, adds a short description, and lists Mineclonia as a dependency. A WorldEdit-style building mod is listed as an optional dependency, since it is needed for development but not for players. The exact Mineclonia module names that the code depends on should be confirmed from its own mod.conf files.

### 13.4 Player State

Each player has one state record. The record is a table with the following fields.

| Field | Type | Meaning |
| --- | --- | --- |
| version | integer | Schema version, used for migrations |
| act | integer | Current act, from 1 to 10 |
| unlocked | table | Set of acts whose gates have been met |
| honor | integer | 0 to 100, starts at 50 |
| wanted | integer | 0 to 4 stars |
| nora_trust | integer | 0 to 100, starts at 50 |
| ledger_pages | table | Pages 1 and 2 found or not |
| map_fragments | table | Fragments 1 to 3 found or not |
| towns_placed | table | Which town schematics have been placed |
| horse | table | Owned horse id and last known position |
| flags | table | Named story flags, such as nora_freed or gold_found |
| verdict | string | Chosen verdict, empty until Act 10 |

### 13.5 Persistence

State is stored in the world's mod storage, keyed by player name and serialized to JSON. A save happens when an act changes, when honor or wanted changes, when a player leaves, when a player sleeps, and at server shutdown. Saves are throttled so that no more than one write happens every few seconds per player. On load, the version field decides whether any migration functions must run before the state is used.

Because mod storage is still a single database file, the world folder should be backed up before major updates, and the mod should offer a debug command that exports a player's state as text for bug reports.

### 13.6 Act State Machine

Each act is a table with an id, a name, a gate definition, an on_enter function, a completion check, and an on_complete function. A gate definition can contain inventory requirements or a named story-state validator, such as checking that Eli is mounted on a tamed horse with a saddle equipped. The state machine only moves forward. An act can be entered when the previous act is complete and its gate is met. The hunt acts 7 to 9 follow the same pattern, so they can be reordered in the design later without rewriting the logic.

An act's completion check listens for a specific event, such as picking up ledger page 1, entering the Widowmaker Tunnel, or Nora being freed. When the check passes, the mod updates the state, saves, and starts the next act's on_enter function.

### 13.7 Gate Checks

Inventory gates are checked against the player's main inventory. An inventory requirement lists an item and count; some requirements consume their items and others do not, so each includes a consume flag. Item names must be the registered names from the game's item registry, not the display names shown in the interface. A gate may also name a state validator for conditions that cannot be represented by inventory alone, such as the Act 2 saddled-horse check.

```lua
local function has_items(player, requirements)
    local inv = player:get_inventory()
    for _, req in ipairs(requirements) do
        if not inv:contains_item('main', ItemStack(req.item .. ' ' .. req.count)) then
            return false, req
        end
    end
    return true
end
```

The Act 2 state validator must confirm that Eli is riding a tamed horse with a saddle equipped; having Samuel's saddle in inventory alone does not pass the gate. It does not consume the saddle. When an inventory gate passes and the act starts, any item requirement marked consume is removed from the inventory in the same step. The check runs when the player interacts with a gate NPC, enters a gate location, or opens the journal. A slow global timer also checks auto-unlocks, such as the cartography map, so the player is not forced to click for every change.

### 13.8 Events and Hooks

The mod uses a small set of hooks. On join, it loads the player's state and restores any horse. On leave and on shutdown, it saves. A global step runs at a low frequency to update NPC routines, check storm timers, and run the cutscene camera path when a cutscene is playing. The dialogue system uses the formspec receive-fields hook to read button choices. Honor and wanted changes happen in response to events: a player punching a deputy, a mob or NPC dying, a horse being taken, or a stolen item being returned.

### 13.9 NPCs

NPCs are registered as entities. Each NPC has a name, a routine, and a dialogue tree. The routine reads the time of day and selects the current waypoint from its schedule, so Ada moves from the office to the patrol route and Dutch moves from the stables to the hayloft. NPC updates run at a fixed interval, and NPCs far from the player pause their routines to save processing time.

Right-clicking an NPC opens its dialogue. Dialogue data is a set of nodes. Each node has a speaker, a line of text, and a list of choices. A choice has a label, the next node, an optional list of effects such as honor +3 or flag nora_freed set, and an optional requirement. Choices whose requirements aren't met are shown greyed out, with the reason written in the label, so the player knows what to aim for.

### 13.10 Cutscenes

Luanti does not provide a cutscene system, so the mod builds a simple one. When a cutscene starts, the mod disables movement by setting the player's physics override to zero speed and zero jump, hides most of the HUD with the HUD flags, adds two letterbox bars as HUD images at the top and bottom of the screen, and shows subtitles as HUD text. A hidden camera entity follows a path made of waypoints, and the player is attached to it so the view moves along the path. When the path ends, the mod detaches the player, restores physics and HUD flags, and removes the letterbox. The cutscene can be skipped with a key or a button, and it always restores controls if the player disconnects mid-scene.

### 13.11 Horses

Use Mineclonia's native horse and riding behavior. Do not implement custom movement, mounting, or a replacement horse entity. First test whether native horses and saddles persist correctly in the pinned Mineclonia version. Add only the smallest needed ownership, stable, or recovery layer around the native horse; store its owner and last position if the base game does not already preserve them, and restore it safely after logout or area unload. The Act 2 validator checks that the player has completed the taming/saddling step and is riding the saddled horse when entering the Red Mesa route.

### 13.12 Dust Storms and Weather

Weather is decided once per in-game day from a seed built from the day number and the world seed, so a reload produces the same weather. When a storm is active, the mod adds a particle spawner near each player in a storm-prone area and tints the sky through the player's sky and lighting settings. Visibility is only reduced near towns and the Dust Flats, not everywhere, so the storm feels local. Particle counts are capped per player to protect performance.

### 13.13 Items and Documents

Telegrams, ledger pages, wanted posters, and the Harrow map are custom items. Each item stores its text in its metadata, and using the item opens a formspec window with the text. This avoids the length and formatting limits of written books. Bounty boards are a node that opens a formspec listing the current posters, which update from the wanted level and the bounty table.

### 13.14 Towns and Schematics

Town placement follows the five-step process from section 11. The towns module checks the towns_placed flag before placing a schematic, clears the site, places the schematic with force placement, and records the result. Site coordinates live in one table in the towns file, so they are easy to change after a test.

### 13.15 Debug Commands

A small set of chat commands is available to a privileged account during development. These include a command to show the current state, a command to set the act, a command to set honor, wanted level, or Nora's trust, and a command to give gate items for testing. These commands must be removed or locked behind a privilege before release, since they would let players skip the story.

## 14. Development Roadmap

The project is built in milestones so that each one produces something playable. Each milestone should be finished and tested before the next one starts.

| Milestone | Scope | Done when |
| --- | --- | --- |
| M0. Setup | Install Luanti and Mineclonia, pin the version, create an empty mod that loads, and add state save and load | Player state survives a restart |
| M0.5. Vertical Slice | Build the burned ranch, the horse ride to Red Mesa, Ada's first interaction, one playable encounter or consequential choice, and a basic journal objective | A new player can complete the short sequence and explain what they are trying to do, why it matters, and what happens because of their choice |
| M1. Ranch and Horses | Acts 1 and 2: the burned ranch, fragment 1, Samuel's saddle in the tack room, taming and saddling a horse, and the ride to Red Mesa | A player can reach Red Mesa on horseback without crafting or grinding for a saddle |
| M2. Red Mesa and the Dust Road | Acts 3 and 4: the sheriff, bail, Jesse Moss, fragment 2, lanterns, the Dust Flats at night, and Ruth's shop | A player can reach Dry Gulch |
| M3. Iron Pass and Crane's Station | Acts 5 and 6: the collapsed shaft, the iron pickaxe gate, fragment 3, Silver Spur, the barricade, and TNT | Crane escapes and the trail is visible |
| M4. The Hunt | Acts 7 to 9: the ghost mine, Bitter River, ledger pages, Widowmaker Tunnel, Mercer, and the rescue | Nora is freed in a playable scene |
| M5. The Verdict | Act 10: the verdict menu, the gold choice, three endings, and epilogues | Each ending can be reached in testing |
| M6. Polish | Textures, sounds and music, town placement tuning, and atmosphere passes | The world matches the Western look |
| M7. Playtest and Balance | Full playthroughs, honor and trust tuning, bug fixes, and a final save test | A full run finishes without blockers |

## 15. Testing Checklist

Each test should run in a copy of the world, and the results should be recorded with the Luanti and Mineclonia versions.

| Area | Test |
| --- | --- |
| Gates | Each gate unlocks only when its item or story-state requirements are met, and it stays unlocked after required items are used |
| Consumption | Bail gold, TNT, and golden apples are removed; saddles, lanterns, pickaxes, boats, the duster, and the crossbow are kept |
| Persistence | Progress, honor, wanted level, Nora's trust, and the horse survive logout, restart, and death |
| Saddle recovery | Samuel's saddle is always obtainable in the ranch tack room before Act 2; losing it before reaching Dutch restores it there, and a lost horse does not destroy the saddle |
| Playable acts | Each act includes an objective and a distinct playable situation; a required item check alone never counts as act completion |
| Player feedback | Journal and NPC feedback make the next objective, consumed gate items, and meaningful honor/trust changes understandable without revealing exact hidden scores |
| Economy and pacing | A full playthrough reaches each gate without repetitive mandatory mining; optional exploration remains worthwhile and the rescue stays narratively present without a timer |
| Death | The player respawns at a bed or spawn, dropped items can be recovered, and no act is lost |
| Horses | A native Mineclonia horse can be tamed, saddled, ridden, stabled, and found again after logout; Act 2 rejects a loose saddle without a saddled horse |
| Towns | Each schematic is placed once, sits on flat ground, and doesn't overlap a Mineclonia village |
| NPC routines | Each character is in the right place at each time of day, and routines pause far from the player |
| Dialogue | Locked choices are greyed out with the reason, and effects change honor, trust, or flags as written |
| Honor and wanted | Each action changes the score correctly, and the wanted level causes the correct town reaction |
| Verdict | Each verdict appears only when its requirements are met; Crane's captured-alive, released, and killed states produce consistent options and endings |
| Gold choice | It appears only if the cache was found, and it changes the epilogue text |
| Weather | Storms are the same after a reload and only appear in the intended areas |
| Performance | The game stays playable with the maximum NPC count and storm particles active |

## 16. Risks and Limitations

| Risk | Effect | Mitigation |
| --- | --- | --- |
| Mineclonia is in beta | Updates may break the mod or the world | Pin the version, test updates in a copy, and keep backups |
| Some blocks or items are missing | Towns or gates may not match the design | Check the block palette early and substitute similar blocks |
| No in-game music | The atmosphere depends on the sound mod | Build the sound mod in the first milestone that needs audio |
| Large structures are not fully supported | Big towns may not place correctly | Use schematics and keep towns modest in size |
| Native horse persistence or saddle hooks may need adaptation | A horse or saddle could be lost, blocking travel | Use Mineclonia's native riding, test persistence early, make Samuel's saddle recoverable, and add only a small compatibility layer if needed |
| Save data could be corrupted | Players could lose progress | Use a versioned state, throttled saves, and debug exports |
| Particles and many NPCs could slow the game | Lower frame rates in towns and storms | Cap particles, limit active NPCs, and pause far routines |
| Scope is large | Ten acts, six towns, and a verdict system take time | Build in milestones and test each one before continuing |
| Honor and trust values could feel unfair | Players may feel punished for choices | Tune the values in playtesting and show the reason for each locked choice |
| Assets may have licenses | Shared work could break terms | Check every texture, sound, and music file before publishing |

## 17. Open Decisions

Several questions are still open and should be decided before the relevant milestone. Whether the gold cache location is fixed or randomized per world affects the Silver Spur build and the fragment design. Whether Jesse Moss can travel with Eli after Act 4 affects the dialogue and the routine for Jesse. Whether Mercer can be spared in every case, or only when the surrender conditions are met, affects the Act 9 logic. In M1, verify how native Mineclonia horses and saddles persist in the pinned version and implement only the compatibility behavior the tests show is missing; do not replace the existing riding system. The music source, whether original, commissioned, or licensed, should be decided before M6. Finally, the decision to share the game publicly, and under what license, affects naming, asset checks, and the release process. Before expanding beyond the vertical slice, playtest the core loop with someone unfamiliar with the plan and decide whether its tasks feel like story-driven play rather than item collection. Also decide how the final encounter communicates Crane's surrender and how the player can capture him alive before implementing the verdict options.

## 18. Glossary

| Term | Meaning |
| --- | --- |
| Luanti | The free, open-source voxel game engine formerly known as Minetest |
| Mineclonia | A free, Minecraft-style game that runs on Luanti; the base for this project |
| Mod | A folder of Lua scripts and assets that adds or changes game behavior |
| ContentDB | Luanti's content browser, where games, mods, and texture packs are installed |
| Node | A block in Luanti's world |
| Entity | A moving object such as an NPC, a horse, or a camera |
| Formspec | A window built from a text description, used for menus and dialogue |
| Schematic | A saved file of a built structure that can be placed in the world |
| Gate | An item or story-state check that must pass before an act can start |
| Honor | A hidden score from 0 to 100 that reflects Eli's conduct |
| Wanted level | A 0 to 4 star measure of how hunted Eli is by the law |
| Nora's trust | A hidden score from 0 to 100 that reflects Nora's view of Eli |
| Ledger | Crane's record, found in two pages during the hunt |
| Harrow map | The map made by combining Samuel's three fragments, which marks the gold cache |
| Force placement | Placing a schematic even when the terrain is in the way |

## 19. Decisions Log

| Decision | Reason |
| --- | --- |
| Use Luanti and Mineclonia instead of Minecraft | The player does not own Minecraft, and the free stack supports Lua mods |
| One persistent single-player world | The player wanted one realm with no timer |
| Progress is gated by inventory items | The player wanted exploration and mining to drive the story |
| Western story with Eli rescuing Nora | Chosen by the player for the frontier atmosphere |
| Eli hunts Crane and decides his fate | Chosen by the player for the final act |
| Three verdicts: Justice, Mercy, and Vengeance | Gives the player a real choice based on honor and what they learned |
| Fallback purchase for gate items | Prevents players from being stuck, at a cost |
| No timer or fixed length | The player explicitly dropped the 30-minute limit |

Names, numbers, and item identifiers in this document are starting points. They should be confirmed in the game and tuned during playtesting.