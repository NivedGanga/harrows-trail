# Harrow's Trail RC1 — installation and release checklist

Target: **Luanti 5.17.0 + Mineclonia 0.124.1**, single player. No optional mods, shaders or external audio packs are required. Install the complete pinned game, including its licenses and credits. Runtime downloads and user worlds are deliberately absent from the package.

This is an automated/server-verified release candidate. Graphical play, actual riding, connected-player death/rejoin, natural movement and subjective audio quality remain unverified; the user waived manual verification. Do not interpret server callback tests as a recorded graphical playthrough.

## Install into a fresh world

1. Obtain the exact engine/game pins. The development checkout uses `.local/luanti.app` and `.local/games/mineclonia`; the installed game's README records `Version: 0.124.1`. Verify the engine with `luanti --version`.
2. Extract `harrows-trail-rc1.zip`. It contains one `harrows_trail` mod folder, original media, credits and a SHA-256 manifest. Place that folder inside your isolated Luanti profile's `mods` directory, or set `LUANTI_MOD_PATH` to its parent directory. Put Mineclonia in a `games/mineclonia` folder and set `LUANTI_GAME_PATH` to the parent `games` folder if needed.
3. Create a **new, previously nonexistent** world directory. In `world.mt`, set:

```ini
gameid = mineclonia
backend = sqlite3
player_backend = sqlite3
auth_backend = sqlite3
mod_storage_backend = sqlite3
load_mod_harrows_trail = true
```

4. Use a separate configuration file:

```ini
fixed_map_seed = 1730940739604968791
harrows_trail_grounded = true
harrows_trail_test = false
server_announce = false
harrows_trail_ambience = false
```

5. Launch with the pinned executable, `--world /absolute/path/to/new-world --config /absolute/path/to/harrows.conf --go --name eli`. Set `LUANTI_USER_PATH` to an isolated profile. The seed is required for this surveyed frontier: unsupported seeds fail placement safely. Initial terrain generation can take several seconds. The journal is `/trail`.

For the source checkout, `./play` creates a uniquely named disposable world and prints its path. Resume only that marked world with `HARROWS_WORLD=/printed/path ./play`; the launcher refuses unmarked or locked worlds. New launcher worlds use SQLite backends. Existing worlds keep their own backend configuration.

## Existing saves, backup and restore

Close the game/server before copying an **entire world directory**, its configuration, and the currently working mod version. Keep that backup outside the active world folder. Replace only the mod directory during an upgrade, never the world database or player files. State schema 1 remains supported, with additive flags; old layouts stay in place. Version-6 interim travel remains available. Existing version-7 structures are not retroactively rebuilt or recolored; project fixture/character appearance can update.

Never change an existing seed to force placement, clear placement flags, reset a world, or run new-world setup over an existing directory. Wrong-seed, village overlap, protected/modified terrain and player builds fail safely. Do not change legacy database backends in place as part of this update. To roll back, stop the game and restore the matching full-world backup **and** prior mod version; removing a mod with placed custom nodes can leave unknown nodes.

## Controls and player guidance

- Right-click characters, desks and boards. `/trail` explains objectives and consumed items. Inventory is normally I; native key bindings can be changed.
- Tame/saddle/ride through Mineclonia's native horse controls. Samuel's saddle recovery is at the ranch; Dutch handles later replacements. No custom horse movement is installed.
- First meetings use five-second subtitles: sneak skips; right-click again opens dialogue immediately. Scenes never override movement, physics or horse attachment.
- `/frontier` near a built settlement offers notices, contracts, equipment, rumors and fines. One-time exploration contracts fund preparation; the gold cache stays optional.
- Mercer can surrender or be defeated. Disarm Crane with two empty-handed strikes after initiating the confrontation, then explicitly restrain him, free his restraints under a truce, or kill him. The final verdict determines his departure/custody and ending. A dead Crane cannot receive Justice or Mercy.
- `/trail_audio on|off` opts into original ambience. `/trail_effects on|low|off` controls local particles/haze. Audio defaults off; low emits four weather particles per batch, normal at most 12. No shader dependency.

## Evidence and reproducible package

From the source checkout, run `./tests/run-all.sh`. It creates disposable worlds and runs all server suites plus both corridor validators. `tests/run-sprint4-death.sh` is a connected graphical-client test and is excluded because the renderer failed; connected-client death/riding are not reported as passes.

`./tests/run-sprint11.sh` checks a no-cache preparation budget, all 12 verdict/gold epilogue combinations, state restart, 32 active NPCs with capped weather/audio, and release mode with the test API disabled. Travel/mounted validation and terrain/path checks have separate integrated coverage. No continuous mouse/keyboard full playthrough is claimed.

Build with `python3 tools/package-release.py`; it includes only tracked/staged runtime files and selected release documentation, excluding worlds, test fixtures, vendor media and private machine files. It emits `.local/releases/harrows-trail-rc1.zip` with fixed ZIP timestamps, sorted files, dependency pins and SHA-256 hashes. Run `python3 tools/package-release.py --verify /absolute/path/to/zip` and `./tests/run-package.sh /absolute/path/to/zip` to validate an extracted installation. Rebuilding from the same source revision/content produces identical bytes. The manifest's runtime digest identifies the exact tested game files independently of release-document edits.

## Release checklist

- [x] Exact pins retained; native horse/riding behavior retained.
- [x] Story/gate/consumption/ending and gold/no-gold callbacks covered; optional cache independent.
- [x] Old-layout/save, state restart, native horse serialization and saddle-recovery regression coverage.
- [x] Grounded sites, terrain/village/build conflicts and structural walking corridors tested in disposable worlds.
- [x] Original-asset inventory and fallback/decode tests; no unverified third-party music shipped.
- [x] Normal-player commands grant no debug state/item privileges; test API disabled in release configuration.
- [x] No active player world opened, reset, migrated or replaced during QA.
- [ ] Graphical/audio/connected-player acceptance: **waived and unverified**, not a server-test pass.

## Remaining limitations and bug reports

Pursuers use bounded on-foot waypoints; mounted enemy AI is absent. NPC routines are intentionally simple, and hay-shelf transitions are schedule repositioning. Combat uses minimal melee/disarm interactions. Terrain paths allow local detours and are verified for walking, not horse clearance. Cold site generation may pause before placement. Graphical legibility, movement, renderer performance and listening quality remain unknown.

Use `/trail_report` for a privacy-limited report containing engine/pins, schema/layout, act, verdict, public outcome and placed site IDs. It omits player names, inventory, coordinates and hidden honor/trust. Describe the action, expected/actual result and whether it occurred in a new disposable or copied legacy world. Do not attach a world, raw player data or unredacted server logs by default. The privileged `/trail_sites` command is available to the world owner for placement diagnostics. No report is sent automatically.
