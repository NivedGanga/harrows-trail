# Harrow’s Trail

> **A frontier rescue story about family, truth, and what justice means when the law has failed.**

Harrow’s Trail is a story-driven Western adventure built as a Lua mod for **Luanti + Mineclonia**. Play Eli Harrow, follow the trail of his kidnapped sister Nora across a changing frontier, uncover the truth behind his father’s death, and decide whether outlaw Silas Crane should face trial, be shown mercy, or meet Eli’s vengeance.

**No countdown. No single “right” ending. Your preparation and choices shape the way home.**

---

## At a glance

| | |
|---|---|
| **Genre** | Western adventure / sandbox narrative |
| **Engine** | Luanti 5.17.0 |
| **Game** | Mineclonia 0.124.1 |
| **Implementation** | Lua mod; uses Mineclonia’s native horse and riding systems |
| **Current phase** | Playable story prototype; grounded-world production in progress |
| **Roadmap** | 11 incremental sprints, from playable acts to release QA |

## The story

The Harrow ranch has burned. Eli’s sister, Nora, has been taken by Silas Crane, a former railroad detective turned outlaw. Crane believes Nora knows where a missing payroll is hidden. Eli follows clues left across the frontier—through Red Mesa, the Dust Flats, mining country, and the Bitter River—while discovering that the robbery that destroyed his family was not what it seemed.

The pursuit leads to more than a final duel. What Eli learns, the promises he keeps, and the risks he takes determine which verdicts are possible and how Nora sees his choices. The rescue has no timer: explore, prepare, and decide what kind of justice the frontier deserves.

## What makes it different

- **A personal goal drives the journey.** Every lead moves Eli closer to Nora and to the truth about Samuel Harrow.
- **Preparation opens situations, not just doors.** A saddle, lanterns, evidence, and other mission items support travel and investigation rather than replacing them.
- **The ending reflects the player’s choices.** Crane’s fate can lead to Justice, Mercy, or Vengeance; evidence and honor affect what Eli can choose.
- **The frontier is built for exploration.** Distinct biomes and settlements frame the route, with native Mineclonia horses and persistent story progress.
- **The project is being built incrementally.** Each sprint adds playable capability while preserving the existing story and saves.

## Current build status

This repository contains the Acts 1–10 story implementation and a developing grounded-world layer. Automated Luanti server tests cover substantial progression and placement behavior. **It is not yet a visually verified, release-ready game.**

| Area | Current state |
|---|---|
| **Story progression** | Acts 1–10 are implemented in the mod, including the Widowmaker finale, verdict branches, and epilogues. The finale has automated simulated-player coverage. |
| **Opening world** | A fresh launcher world uses a surveyed seed and guarded, grounded Ranch and Red Mesa sites. The buildings, characters, route, and mounted travel still need graphical verification. |
| **Mid-game world** | New layout-version-6 worlds use grounded Dust Flats, Dry Gulch, Ghost Mine, Iron Pass and Silver Spur, with ordered shaft clearing, a walking trail and checked bridges. Server integration and restart tests pass. Temporary stagecoach links reach the elevated station until Sprint 7. Graphics and actual riding remain unverified. |
| **Late-game world and presentation** | New version-7 worlds use the grounded station, river ferry/hideout and supported Widowmaker tunnel, with six tested walking corridors and a return to Ada for the verdict. Distinct cast, routines, frontier reactions, weather/audio and release QA remain Sprints 8–11. Graphics and actual riding are unverified. |
| **Player testing** | Some earlier progression and native horse taming/riding are player-reported. The complete Acts 1–10 graphical playthrough has not been verified. |

The current plan is documented in the [extended sprint roadmap](docs/roadmap.md). Detailed test evidence, open issues, and player-reported checks are in [sprint status](docs/sprint-status.md). The original design is in the [Game Design Document](docs/harrows-trail-gdd.md).

## Try the development build

### Requirements

The repository’s local launcher expects the project’s pinned development setup: **Luanti 5.17.0** at `.local/luanti.app`, Mineclonia **0.124.1** under `.local/games`, and this repository’s mod under `mod/`. These local engine/game files are ignored by Git and are not included in the repository. The launcher is a macOS development convenience, not a cross-platform installer.

### Start a fresh disposable world

From the repository root:

```sh
./play
```

The script creates a **new marked test world** under `.local/play-world.*`, enables the mod, and starts Mineclonia as `pen_tester`. It uses the surveyed development seed required by the current grounded-opening checks. It does not erase earlier worlds. The launcher prints the world path when it starts.

To resume one of the launcher’s marked worlds, close its running Luanti session first, then use its printed absolute path:

```sh
HARROWS_WORLD="/absolute/path/to/.local/play-world.XXXXXX" ./play
```

Optional environment variables select the player name or port:

```sh
HARROWS_PLAYER=eli HARROWS_PORT=30996 ./play
```

The launcher refuses unmarked worlds. Do not rename the marker/config files, point it at a valuable save, or manually copy over an existing world. Existing legacy worlds are not automatically migrated to the grounded opening. Back up any world before manually enabling or updating the mod.

### In game

Right-click story characters and interaction points. Use **`/trail`** to see the current objective. Luanti’s default inventory key is **I**, though key bindings may differ. Horse taming and riding use Mineclonia’s native behavior.

The opening is intended to begin at the burned ranch and lead toward Red Mesa. Some later story areas still use elevated prototype markers; current travel and interaction details are recorded in the sprint status and will change as grounded-world work progresses.

## Development and testing

The project pins Luanti 5.17.0 and Mineclonia 0.124.1 to keep APIs and registered game items reproducible. Do not update either dependency without testing in a copied world first.

The test runners use temporary or disposable worlds; they do not represent a completed graphical playthrough:

| Command | Coverage recorded in the project |
|---|---|
| `./tests/run-sprint1.sh` | Core progression/state regression, Acts 1–8 and finale callbacks, save/restart behavior, safe placement checks, and site survey. |
| `./tests/run-sprint5.sh` | Grounded opening placement, simulated interactions, restart/idempotence, wrong-seed refusal, legacy-save preservation, and conflict handling. |
| `./tests/run-sprint6.sh` | Mid-game sites and bridges: placement, restart, occupied-site refusal and player-modified-site protection. |
| `./tests/run-sprint6-integration.sh` | Grounded act interactions, physical shaft clearing, temporary station travel, gates, one-time rewards and restart. |
| `./tests/run-sprint6-route.sh /path/to/disposable/world` | Copies a world from the Sprint 6 placement suite and verifies a continuous walking corridor with local detours. |
| `./tests/run-sprint7.sh` | Late-site placement, unchanged recorded boundaries, restart, conflicts, actor recovery and tunnel light levels. |
| `./tests/run-sprint7-integration.sh` | Version-7 breach, ferry branches, rescue, all verdicts, persistence and absence of elevated story floors. |
| `./tests/run-sprint7-route.sh /path/to/disposable/world` | Six walking corridors, including the return to Red Mesa, copied from a version-7 integration world. |
| `./tests/run-play-safety.sh` | Launcher safeguards, including preservation of earlier worlds and refusal of unsafe paths. |
| `./tests/run-sprint4-death.sh` | Attempts connected-player death/restart verification; the recorded run could not create an OpenGL context and did not reach gameplay. |

For shell syntax and whitespace checks:

```sh
sh -n play tests/run-sprint1.sh tests/run-sprint4-death.sh \
  tests/run-sprint5.sh tests/run-sprint6.sh tests/run-play-safety.sh
git diff --check
```

Server tests use simulated players and real Mineclonia/Luanti registries where available. They are useful for regression coverage, but they do **not** prove that models render correctly, a route feels good to ride, or a connected player can finish the entire story. Those checks remain open and are reported separately rather than being presented as passed.

## Project layout

```text
mod/harrows_trail/   Lua gameplay, story, finale, inventory, and world/site systems
prompts/             Sprint-by-sprint implementation briefs
tests/               Disposable-world regression and safety test runners
docs/
  harrows-trail-gdd.md   Original design source of truth
  roadmap.md             Extended 11-sprint plan
  sprint-status.md       Implementation, evidence, and known limitations
play                  Local disposable-world development launcher
```

## Roadmap

The game is being built in stages: finish the story prototype; replace placeholder routes with grounded, safe-to-place sites; bring characters to life with distinct visible avatars and routines; add reactive frontier systems and atmosphere; then complete integrated QA and release documentation.

See [docs/roadmap.md](docs/roadmap.md) for the full Sprint 1–11 sequence and prompts. Work is incremental: later-world construction and polish are not implied to be complete just because the acts or their server tests exist.

## Project status and contribution

This is an active hackathon project. For bugs or implementation work, begin with `AGENTS.md`, the relevant sprint prompt, and the current sprint-status entry. Preserve existing saves, use disposable worlds for tests, and report exactly what was verified—especially whether a check was automated, server-side, player-reported, or graphical.

**Harrow’s Trail is a work in progress.** Its central promise is a family rescue that becomes a question of justice; its remaining work is to make the whole frontier feel as real and playable as that promise.

Sprint 6 is implemented for new versioned worlds and server-verified. Existing unversioned worlds retain their earlier layouts. Coordinates, temporary stagecoach connections and placement limitations are documented in [docs/world-sites.md](docs/world-sites.md). No graphical or actual-riding acceptance is claimed.

Latest checks: `./tests/run-sprint1.sh` PASS (write, read, occupied-site, survey); `./tests/run-sprint5.sh` PASS (12 phases); `./tests/run-sprint6.sh` PASS (five phases); `./tests/run-sprint6-integration.sh` PASS (write/read). `./tests/run-sprint6-route.sh /var/folders/kp/5hhqrcq12hn53ctgc38w33d80000gp/T/harrows-sprint6.nuqJfD/world` PASS with 3,486 verified walking cells and zero corridor failures. The exact original cells included 35 vegetation obstructions that the continuous walking check bypassed. Logs and unresolved verification limits are in [docs/sprint-status.md](docs/sprint-status.md).

Sprint 7 is implemented and server-verified. Fresh launcher worlds use layout version 7; version-6 worlds retain their interim station links, and older layouts remain unchanged. The new world has no elevated story floors. Its station breach clears only owned barricade pieces, ferry options remain optional alternatives, and rescue/verdict outcomes persist. Coordinates and terrain-edit assumptions are in [docs/world-sites.md](docs/world-sites.md).

The complete sequential regression batch passed: Sprint 1, Sprint 5 (12 phases), Sprint 6 placement and compatibility integration, the mid-game corridor, Sprint 7 placement and integration, six late-route corridors, launcher safety, shell syntax and whitespace checks. The final native-lantern placement and night-light assertions also passed `./tests/run-sprint7.sh`. Exact commands and logs are recorded in [docs/sprint-status.md](docs/sprint-status.md). These are server-side checks with simulated player callbacks; graphical play, actual riding, connected-player death/rejoin and audible/rendered presentation remain unverified. The user waived manual verification.

### Sprint 8 cast and routines

Original cast skins distinguish the ten named roles; Eli gains a brown coat appearance while carrying or wearing the brown leather duster. Native armor and horse riding remain intact. Right-click a person for a five-second introduction, sneak to skip, or right-click again to open the existing dialogue immediately. Scenes use actor facing and subtitles; they never take control of movement, the camera or a horse. Death/leave removes scene HUDs. First meetings and story reveals are saved once.

Ada patrols in the evening and rests in her office at night; Jonah cleans by day and tends the saloon later; Dutch uses the stable's upper hay shelf at night; Ruth closes regular business at night; Amos sits by a harmless visual fire after daylight. Urgent rescue supplies/evidence remain accessible after hours. Jesse stays jailed until released, stages along the Dust crossing, then hides at Bitter River. Crane appears at the depot, mine and river hideout before the final tunnel encounter. Rescued Nora and captured Crane appear with Ada for the verdict. New stables have a covered upper hay shelf; previously placed buildings are preserved.

Routines update every two seconds within 48 nodes, use validated short waypoints with a home fallback, and pin story encounters. These are simple schedule changes, not continuous simulated lives. Original asset sources and reproduction instructions are in [docs/assets.md](docs/assets.md). Run `./tests/run-sprint8.sh` for cast/persistence checks and `./tests/run-all.sh` for sequential server regressions. Graphical rendering, natural movement, actual riding and connected-client scene behavior remain unverified; manual verification was waived.
