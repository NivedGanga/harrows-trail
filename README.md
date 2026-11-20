# Harrow’s Trail

Acts 1–10 are implemented as a compact Lua mod for Luanti/Mineclonia. Sprint 1 is **implemented; awaiting in-game acceptance**. Sprint 2 has server-side automated coverage; a full graphical playthrough remains unverified.

Development pin: Luanti **5.17.0**, LuaJIT **2.1.1764270282**, Mineclonia **0.124.1**. The engine version was checked with `--version`; the installed Mineclonia README states its version. Neither installation was upgraded. Dependencies are in `mod/harrows_trail/mod.conf`; no third-party mods or new assets were added.

## Launch a disposable world

To start a fresh disposable grounded-opening game from the repository directory:

```sh
./play
```

Each `./play` run creates a new marked `.local/play-world.*` and starts as `pen_tester`; it does not delete earlier worlds. It prints the world directory. To resume a marked world, close its existing session and run `HARROWS_WORLD=/absolute/path/to/world ./play`. Set `HARROWS_PLAYER` or `HARROWS_PORT` to choose a different player name or port. The new world uses the surveyed seed `1730940739604968791` and enables grounded opening sites; existing legacy worlds are not migrated automatically.


A fresh copy was created at `.local/sprint2-preview.XfXYBj`; its original world configuration is backed up as `world.mt.before-harrows`. It has a preview player who joined, but has not completed the chapter. Stop that preview client before relaunching the same world:

```sh
LUANTI_USER_PATH="$PWD/.local/user" LUANTI_GAME_PATH="$PWD/.local/games" LUANTI_MOD_PATH="$PWD/mod" \
  .local/luanti.app/Contents/MacOS/luanti --world "$PWD/.local/sprint2-preview.XfXYBj" --go --name chapter_preview --port 30989
```

For a fresh run, copy `.local/world` to a **new, unused** directory, back up its `world.mt`, and append `load_mod_harrows_trail = true`; substitute that directory in the command. Never copy over an existing world. Existing real worlds and saves were not edited.

## Gameplay reference and unverified checks

Use right-click to interact and `/trail` for the current objective. Press **I** to open the inventory with the default Luanti key bindings (your bindings may differ). Fresh launcher worlds use the grounded ranch and Red Mesa; the later route remains an elevated prototype for now. Existing legacy saves retain their original sites.

Ada's choice marker is the labeled block at X=55, Y=221, Z=0. Point at it to see “Sheriff Ada Wells (right-click)” and right-click it. An inspection of a committed snapshot of `.local/play-world` found the marker and infotext there; the interaction itself was not tested. The one-time site placement does not restore a marker removed after the site is marked ready. This description applies to the legacy prototype; the new launcher creates a separate world and never resets it.

1. At the ranch, search the barn (west), collect Samuel’s saddle at the tack room, tame a native horse with an empty hand, fit its saddle and ride east. A loose saddle must fail the route gate; riding the owned, tamed, saddled horse must pass without consuming it.
2. Repeat tack-room use with the saddle carried, dropped, on a distant horse and after unloading/rejoining. Carrying the current saddle must prevent reissue. If it is dropped or on a distant/unloaded horse, recover it free at the tack room: only the new issue may be fitted. Retrieve the old item and try fitting it; it must be rejected. Revisit the old horse after unloading/rejoining: its retired saddle must be removed. Kill an owned saddled horse: its saddle should return once. Repeat with full inventory and an offline owner; make room and rejoin or visit the tack room. Death must preserve story progress. Test bed respawn too.
3. At Ada (Red Mesa), try both evidence choices in separate new runs. Confirm different reactions and qualitative feedback without numeric honor. Rejoin and confirm the choice persists.
4. Search the payroll box near the office for 12 gold (one reward). Alternatively carry parcels from the west ranch supply desk to the east corral depot for 3 gold per trip, repeatable. This also replaces lost bail/shop funds without mining.
5. Ask Ada about bail. Try insufficient gold: no loss or unlock. Confirm with 9 ingots, then in another run with 1 gold block: payment removed exactly once. Speak to Jesse at the jail door; obtain fragment 2 and route guidance. Rejoin and repeat Ada/Jesse: no second charge or fragment.
6. Buy 4 lanterns for 3 gold at Ruth’s Red Mesa order desk, or craft them using Mineclonia’s native recipe. Test missing gold and full inventory. Lanterns must remain after entering Act 4. Ruth also has a desk at Dry Gulch.
7. At the Dust Road marker east of Red Mesa, wait safely for night and choose a route. Daytime and missing lanterns must reject entry without penalty. After entry, lantern waypoint labels reveal the markers. Exposed: dismount at the middle marker; blowing dust slows walking. Sheltered: follow the northern branch and visit both roofed shelters west to east; no wind slowdown. Confirm the routes differ in travel and that controls return to normal outside the gale.
8. Reach Dry Gulch and right-click its arrival marker after following the chosen markers. Jesse departs with a clue toward Iron Pass. Test arriving early without completing markers, save/rejoin mid-route and after arrival, death mid-route, and permanent unlocks after dropping lanterns. Dutch sells replacement saddles; Ruth sells lanterns. The trail continues east into Iron Pass.
9. Inspect riding space, platform edges, shelter access, terrain and nearby villages. Automatic occupied-site refusal protects nodes but does not establish acceptable terrain integration.

## Free saddle recovery

Before reaching Dry Gulch, Samuel’s saddle is always recoverable at the marked ranch tack room (the nearby recovery desk opens the same interaction). No gold or delivery is required. A carried saddle or nearby saddled horse prevents unnecessary issuance. Otherwise recovery issues a new identified Samuel’s saddle and permanently retires the previous issue. Dropped and unloaded issues cannot be fitted again; a horse wearing a retired issue loses it when its native step runs after loading. The recovered saddle uses a story item accepted by the native horse’s saddle interface, with native mounting, textures, movement and serialization preserved. It cannot be used as a generic saddle on other mobs.

Repeated recovery can leave retired physical items in unloaded areas, but only the current issue is usable. Retired carried items become labeled keepsakes when using the tack room. The tack room checks capacity for the identified saddle and confirms the inventory insertion before issuing it or displaying success. Story markers preserve changes to the selected hotbar slot after right-click. A full inventory or an insertion that returns a leftover leaves recovery available and does not revoke the current issue. Horse-death returns preserve saddle metadata and remain queued until inventory insertion succeeds; offline/full-inventory returns remain available. Retired issues cannot return from death as usable saddles. After reaching Dry Gulch, Dutch’s paid native saddle replacements remain available.

Existing untagged saddles in older saves are preserved: they cannot safely be distinguished from looted or purchased saddles. They are not retroactively revoked. This finite legacy inventory may coexist with the first identified starter, but further recoveries cannot create additional usable starter issues. Story schema and progress remain intact. Crash-atomic delivery across player inventory and mod storage is still not guaranteed.

## Item rewards and purchases

Barn and Jesse fragments, payroll gold, ranch delivery payouts, saddle issuance and horse-death returns require room for the exact item before completion. If delivery fails, make room and retry; the claim, parcel or pending return remains available. Ruth's lanterns and Dutch's saddle require space and the stated gold price; a failed or partial delivery leaves both payment and inventory unchanged. A previously recovered payroll box reports that its reward was already claimed.

Older saves with `payroll` already marked claimed are preserved. A past false success cannot be distinguished from a successful reward that was spent, so it is not automatically granted again; repeatable ranch deliveries remain available for gold. This transaction protection is server-side within one callback; recovery from a process crash between inventory and state saves remains unverified.

## Automated verification

```sh
./tests/run-sprint1.sh
sh -n tests/run-sprint1.sh
git diff --check
```

The suite uses temporary copied worlds and the installed real server. It covers the earlier choices, horse validator and native serialization, free recovery with absent/dropped/unloaded issues, retired-item rejection and native horse serialization/retirement, full-inventory and failed-insertion protection using an actual 36-slot inventory, pending-return leftover retention, payroll/delivery/fragment and shop retry and partial-rollback checks, persistent issue retirement across restart, online/offline/full-inventory death return, restart persistence, both bail denominations, retained lanterns, purchase replay protection, both route selections, ordered shelter traversal, Dry Gulch completion, and one-time/occupied placement. It also reports a limited terrain/village-POI survey. Player controls, HUD appearance, storm effects and full graphical playthrough remain unverified. The checklist is reference material, not a prerequisite or a request for personal testing. There is no standalone Lua executable; server loading checks Lua syntax.

## Disposable native-horse pen

A separate copied test world is at `.local/horse-pen.Zhqh52`. Its original `world.mt` is backed up as `world.mt.before-harrows`; its `horse_pen` world mod is confined to this copy. It builds a two-node-high pen around the ranch corral (x=3..12, z=-2..7, y=221..222) and spawns one persistent **untamed** native horse at x=8, z=2. The gate is on the west/ranch side at x=3, z=4; right-click it to open or close it. This is a test fixture, not a change to the production mod or native taming. The server logged pen placement with `tamed=false`; containment, gate interaction and taming still need in-game testing.

The test client may already be open. Close that client before relaunching this same world:

```sh
LUANTI_USER_PATH="$PWD/.local/user" LUANTI_GAME_PATH="$PWD/.local/games" LUANTI_MOD_PATH="$PWD/mod" \
  .local/luanti.app/Contents/MacOS/luanti --world "$PWD/.local/horse-pen.Zhqh52" --go --name pen_tester --port 30995
```

Use a mouse and the normal configured keys (defaults below; your Luanti key bindings may differ):

1. Search the barn and recover Samuel's saddle at the tack-room marker, as instructed by `/trail`. Keep the saddle for later. Walk east to the pen, right-click its west gate, enter, and right-click the gate to close it behind you.
2. Select an **empty hotbar slot**, release sneak, aim the crosshair at the adult horse, and right-click. Stay mounted while it moves. It may throw you off: approach and right-click again with an empty hand. Repeat until hearts appear, indicating it accepted you. Feeding is optional; no fixture changes taming chance or sets ownership.
3. Press **Shift** (sneak) to dismount. Select Samuel's saddle, release Shift, aim at the tamed horse and right-click to equip it. Then choose an empty slot and right-click to mount. For this project's Act 2 gate, the horse must be tamed, owned by you, saddled and mounted.
4. Open the gate and ride out; use **W/A/S/D** to move/steer, and the mouse to look. Hold **Space** and release to jump; **Shift** dismounts. Follow the east trail and test the loose-saddle rejection before the mounted gate, then ride through to Red Mesa.
5. Leave and rejoin, checking the horse and saddle, act state, and the corral gate. Test horse-death/full-inventory saddle recovery, both Ada choices, bail and lantern consumption, both Dust Flats routes and Dry Gulch using the checklist above. None of those checks has yet passed in-game.

The test-only fixture source is `tests/horse_pen/`; do not enable or copy it into a real world. It does not tame, mount, saddle or grant a horse to the player. There is no test command.

## Sprint 3: Dry Gulch to Bitter River

Continue east from Dry Gulch along the elevated placeholder (Y=220). Right-click the labeled markers; `/trail` gives the current objective. Sites are fixed at X=136–260, Z=-7–7, with a separate one-time placement flag and occupied-node refusal. This is a functional placeholder, not a terrain-integrated town, working explosion, real ferry, or full mine.

1. At Iron Pass (X=143), carry an iron pickaxe, enter, clear the western and eastern obstruction markers in order, and search the assay office for fragment 3. The pickaxe stays in inventory.
2. Optionally combine the three recorded fragments at the assay cartography desk, then open the adjacent cache for six gold ingots. It is never required for the main path. The desk reconstructs the map from recorded discoveries even if fragments were lost. The remaining cache disposition is deferred until after the verdict. Its fixed location and reward are provisional.
3. At Crane’s Station (X=185), carry TNT, choose left or right, and confirm. One TNT is consumed at this point; change the placement or trigger at the charge marker when ready. The scene is a scripted interaction rather than a destructive explosion. Crane escapes with Nora and leaves a Ghost Mine clue.
4. Fill a Mineclonia empty map while standing at Dry Gulch (X=125, Z=0), and carry the filled map to the mine gate (X=205). Its map metadata must cover that position; it is retained. Investigate the tracks and then the desk to find ledger page 1.
5. At Amos (X=230), carry a spruce boat to start Act 8. It is retained. Pay the provisional fee of three gold, request the waiver when trusted, or clear the snagged line marker for free. Search the hideout and ledger desk for page 2, which reveals Brandt’s robbery and Crane’s framing of Samuel. The journal points toward Nora at Widowmaker Tunnel and the implemented finale.

The headless tests use temporary copies of `.local/world`; they do not launch `./play` or alter the active player world. `./play` creates a separate marked world on each fresh launch; pass `HARROWS_WORLD` to resume one. Automated tests cover simulated player objects against real Luanti inventories and chapter callbacks, not a connected player or graphical playthrough. They verify permanent unlocks, required items, TNT consumption, ordered pages, ferry alternatives, optional cache, and story-state reload across server restart. Full gameplay rejoin, actual player inventory persistence, death recovery, both Dust Flats routes, graphical controls, readability, riding and route feel remain open. The surveyed earlier site does not establish the new site's terrain or village overlap.

## Sprint 4: Widowmaker and the verdict

Continue east from Bitter River on the elevated placeholder at Y=220. The tunnel entrance is X=264. The gate consumes four golden apples once, after confirmation, and retains a brown-dyed leather tunic and a loaded crossbow in the main inventory. Apply brown dye to a leather tunic and load the crossbow with an arrow. The supply desk at X=266 sells replacements for gold; ranch deliveries remain available. Three optional markers at X=268–274 offer one-time good deeds, including a debt costing one ingot.

After passing the gate, right-click Mercer at X=280. Take cover to make him explicitly surrender before sparing him, or choose the duel. Free Nora at X=287 and optionally promise to bring Crane back alive. At X=294 disarm Crane, then capture, release, or kill him. The verdict marker at X=301 explains each locked option; Justice needs capture and good standing, Mercy needs good standing, both ledgers and Nora’s trust, and Vengeance remains available. If the cache was found, select its disposition at X=308 before reading the epilogue. Honor and trust are hidden; the responses explain the choices that affect them. Placeholder figures and epilogue models represent the cast; the camera and controls are not changed.

For a graphical check in a **fresh disposable copy**, follow the launch instructions above, not an active player world. Play from the beginning through the earlier gates and confirm the invalid and valid Act 9 gate, exact apple consumption and equipment retention. Try each Mercer and Crane branch in separate copies; verify the locked explanations, all verdicts, cache/no-cache and each gold choice, and epilogue presentation. Rejoin and test death after the gate and during the finale; verify story progress, inventory and controls survive. Inspect readability, visible figures, terrain and village overlap. These are manual checks, not completed graphical verification.

Automated regression command: `./tests/run-sprint1.sh` runs Acts 1–8 and Sprint 4 in temporary world copies. `sh -n play tests/run-sprint1.sh` checks shell syntax; server loading checks Lua syntax. Run `git diff --check` for tracked changes. The automated harness uses simulated players and real server inventories; it does not establish graphical presentation, actual rejoin or death behavior, or crash-atomic inventory persistence. See `docs/sprint-status.md` for results and limitations.

### Sprint 4 encounter work in progress

Mercer, Nora and Crane use temporary humanoid entities at the existing finale site; they are not final cast assets. Challenge Mercer and strike him to duel, or speak to him to seek surrender. To disarm Crane, start the confrontation and strike twice with an empty hand. These interactions and the surrender pose have server-side callback coverage but have not been graphically verified.

`./tests/run-sprint1.sh` passed its write, restart/read, occupied-site and survey phases with the new simulated-player encounter tests. `./tests/run-sprint4-death.sh` attempts a connected-player death and restart in a disposable copied world; on this run it failed before joining because Luanti could not create an OpenGL context. It did not test death. `sh -n play tests/run-sprint1.sh tests/run-sprint4-death.sh` and `git diff --check` passed. Sprint 4 remains incomplete; death/rejoin, actor rendering and actual combat are unverified. The script leaves its temporary test world and logs in the reported temporary directory.

The Justice verdict raises Eli's standing once. Each epilogue offers a skippable static model scene; it is a temporary presentation and has not been graphically verified. `./tests/run-sprint1.sh` passed its write, read, occupied-site and survey phases with these additions; actual player death and rejoin remain unverified because `./tests/run-sprint4-death.sh` could not initialize OpenGL in this environment.

The conservative placement checks live in `mod/harrows_trail/world_sites.lua`. They reject unsuitable or occupied areas rather than overwriting them. The grounded launcher uses a verified development seed; a different seed may be unsuitable. The opening structures, route, character rendering and actual gameplay have not been graphically verified.

The Sprint 5 test is `./tests/run-sprint5.sh`. It creates a fresh seeded world and disposable copies and checks placement, simulated opening interactions, restart, legacy-save preservation and an occupied-node conflict. The surveyed sites are near ranch X=654/Z=652 and Red Mesa X=623/Z=788. A temporary `/stagecoach` link connects Red Mesa to the elevated Dust Road prototype after Jesse explains the route. The site-status command `/trail_sites` requires the `server` privilege. Back up any world before updating the mod; legacy sites are retained and are not migrated automatically. No graphical checks have been performed. The opening HUD guides the mounted horse along a surveyed land route. At Red Mesa, buy lanterns from Ruth, then use the saloon stagecoach desk and `/stagecoach` to reach the temporary Dust Road; the same command near its departure point returns to town. The route-clearance checks are server-side and do not establish that riding has been played in-game.

Before an unplaced grounded site is built, player placement and digging in its footprint are recorded. Automatic placement refuses a recorded player-altered area; `/trail_sites` reports this to a server-privileged account. Node changes made directly by other mods without placement or digging callbacks are not tracked, so backups remain important.

Sprint 6 is in progress. `./tests/run-sprint6.sh` tests isolated Dust Flats, Dry Gulch and preliminary Ghost Mine construction data in fresh disposable worlds, including refusal after a modified site is reloaded; the data is not yet connected to ordinary gameplay, and the completed mine, Iron Pass and Silver Spur remain outstanding. The latest run passed all five phases, with logs in `/var/folders/kp/5hhqrcq12hn53ctgc38w33d80000gp/T/harrows-sprint6.sz0Wsp`. The tests are server-side and do not verify appearance or travel.

An opt-in snowy-terrain preflight rule passed `./tests/run-sprint1.sh` (write, read, occupied-site and survey; logs `/var/folders/kp/5hhqrcq12hn53ctgc38w33d80000gp/T/harrows-sprint1.p5dID1`). No active site uses it yet, and the snowy mountain route has not been verified.

An inactive Iron Pass construction plan also passed `./tests/run-sprint6.sh` (write, read, blocked, modified and modified_read; logs `/var/folders/kp/5hhqrcq12hn53ctgc38w33d80000gp/T/harrows-sprint6.s8gdck`). The pass is still preliminary and its route, appearance and gameplay have not been verified.

Preliminary Silver Spur construction data has been added but is also inactive and unfinished. The latest `./tests/run-sprint6.sh` passed all five phases for the five planned site groups; logs are in `/var/folders/kp/5hhqrcq12hn53ctgc38w33d80000gp/T/harrows-sprint6.mD8ckV`. No mountain route or graphical playthrough was verified.

A disposable server terrain survey found a narrow approach between the preliminary mountain sites but did not establish horse-width access to Iron Pass or a route from Dry Gulch; see `docs/sprint-status.md` for the evidence and limitations.

New grounded worlds record a layout version for future safe site activation. Existing unversioned grounded and marker-era worlds keep their previous layout. `./tests/run-sprint5.sh` passed its 12 phases including old grounded-world restart and saved progress (logs `/var/folders/kp/5hhqrcq12hn53ctgc38w33d80000gp/T/harrows-sprint5.86ZfZl`); this does not yet activate the mid-game plans.
