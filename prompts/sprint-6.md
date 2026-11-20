# Harrow’s Trail — Sprint 6 Prompt: Dust Flats, Dry Gulch, and Silver Spur Route

Continue the current project after Sprints 1–5. Read `AGENTS.md`, the full GDD, `docs/roadmap.md`, sprint status, and current world/site code. Preserve the working story, save format, version pins, and Sprint 5 placement behavior.

## Outcome

Acts 3–7 take place across a grounded, navigable mid-game frontier: Dust Flats, Dry Gulch, the Ghost Mine, Iron Pass, and Silver Spur. The existing mechanics remain, but story beats are no longer represented by isolated blocks on a floating platform.

## Implement

- Add and validate fixed sites for Dust Flats shelters/trail, Dry Gulch trading post/stables/shop, Ghost Mine entrance and clue area, Iron Pass collapsed shaft, and the abandoned Silver Spur camp/assay office. Follow GDD sections 5 and 11: distinct biomes, modest readable structures, clear paths, landmarks, and site footprints.
- Integrate locations through Sprint 5’s one-time, terrain-safe placement system. Preserve procedural terrain outside each footprint; detect village/build conflicts and fail safely. Keep site coordinates configurable and avoid accidental overlap between locations.
- Attach existing Act 3–7 interactions to in-world NPCs, buildings, clues, and structures where feasible. Keep progression gates and rewards authoritative in the chapter/state system. Ensure exposed/sheltered Dust Flats routes, lantern guidance, collapsed-shaft order, fragment 3, the optional cache/map puzzle, and the filled-badlands-map gate remain understandable and completable.
- Use appropriate existing Mineclonia blocks. Verify item/block names from the pinned installation rather than assuming GDD suggestions are registered. If a schematic cannot be used in automated tests, provide a deterministic test fixture or compact data-driven test build without weakening production placement checks.
- Preserve marker-era saves and existing progress. No migration may grant duplicate fragments, cache rewards, or act completion.

## Done means

- A new disposable-world player can follow the journal from Red Mesa through Dry Gulch to Silver Spur and the Ghost Mine using visible terrain routes and in-world clues.
- All five site groups place once, are grounded, and do not overwrite unrelated builds or Mineclonia villages. Rejoin/restart does not duplicate them.
- The main path works; optional exploration does not become a required grind. Automated tests cover placement/conflicts, route flags, ordered interactions, rewards, and persistence.
- Run the established suite, Lua/shell checks, and `git diff --check`. Report engine test results separately from any graphical inspection; do not present marker/server tests as proof of visual quality.

Update README, sprint status, and site coordinate documentation. Keep later locations—Crane’s Station, Bitter River, and Widowmaker Tunnel—for Sprint 7; defer NPC schedules and global atmosphere to later sprints.
