# Harrow’s Trail — Sprint 5 Prompt: Grounded World Foundation, Ranch, and Red Mesa

Continue the existing Harrow’s Trail repository. Read `AGENTS.md`, the full GDD (`docs/harrows-trail-gdd.md`), `docs/roadmap.md`, `docs/sprint-status.md`, and the current implementation before editing. This sprint follows the completed Acts 1–10 story work in Sprint 4. Do not redesign story rules or replace Mineclonia’s native horses.

## Outcome

The game starts in a natural Mineclonia frontier world, not on the floating prototype platform. Harrow Ranch and Red Mesa are recognizable, grounded places that the player can travel between, and the existing opening story remains playable.

## Implement

1. Add a small, data-driven world-site registry for fixed coordinates, intended biome/terrain, build footprint, placement radius, and placement status. Keep coordinates centralized and easy to tune.
2. Implement safe, one-time site initialization when the player approaches a site. Respect procedural terrain; do not flatten broad areas, overwrite unrelated builds, or place a structure over an existing Mineclonia village. If the chosen site is unsuitable, fail safely and provide a development diagnostic rather than destructively forcing placement.
3. Build and integrate the Harrow Ranch and Red Mesa described in GDD sections 5 and 11. Use Mineclonia blocks and verified schematics or compatible built-in construction data. Include the burned barn, accessible tack room, map-fragment clue, sheriff’s office, saloon, bank, jail, and clear paths/landmarks as appropriate to the current story.
4. Replace the opening-area marker blocks with interactions attached to the relevant world objects or characters. Preserve existing chapter state, inventory rewards, gates, journal behavior, and old-save progress. Never duplicate rewards when a location is revisited.
5. Add a safe transition plan from existing marker-era saves. Do not automatically erase or alter the active world; document backup and test migration/placement using disposable copies. Retain a development-only way to inspect site coordinates and placement status.

## Done means

- A fresh disposable world can generate the opening sites on terrain and run the ranch-to-Red-Mesa story without a floating platform.
- Site placement is one-time and idempotent across restart/rejoin; no duplicate items, structures, or progress rewards occur.
- Existing saves load without losing story flags or player inventory. Placement conflicts are reported and do not destroy unrelated builds.
- Automated tests cover site registration, suitability/conflict handling, one-time placement, state persistence, and the opening progression. Run the existing test suite and syntax/diff checks.
- Clearly report which parts were verified in engine versus visually inspected. Do not claim graphical acceptance if no graphical playthrough occurred.

Keep the scope to the placement foundation, Ranch, and Red Mesa. Leave Dust Flats, Dry Gulch, and later locations for Sprints 6–7. Update the README and sprint status with coordinates, test instructions, migration/backup notes, dependencies, and remaining visual checks.
