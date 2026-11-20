# Harrow’s Trail — Sprint 8 Prompt: Frontier NPCs and Daily Routines

Continue the current project after Sprints 1–7. Read `AGENTS.md`, the full GDD, `docs/roadmap.md`, sprint status, and existing interactions before editing. Keep story progression and existing saves intact.

## Outcome

The named characters appear as distinct, visible people in grounded locations—not just names, floating labels, or detached marker blocks—and respond as people in the world. Their basic daily schedules follow GDD section 8.8.

## Implement

- Implement or adapt a minimal, maintainable NPC entity/dialogue layer compatible with pinned Luanti/Mineclonia versions. Prefer a supported existing NPC capability if already available; do not add a large dependency without justification.
- Place and configure Ada Wells, Jonah Pike, Dutch Hale, Ruth Calloway, Amos Reed, and Jesse Moss according to their GDD locations and day/evening/night schedules. Keep Jesse in jail until released; after release, use a simple wandering/hiding routine.
- Give the core cast distinct visible avatars: Eli, Ada, Jonah, Dutch, Ruth, Amos, Jesse, Nora, Crane, and Mercer. Use compatible humanoid models/skins with recognizable clothing, colors, and simple props that fit each role; reusing a base model is fine, but the characters must be visually distinguishable during play. Provide Eli’s Western identity through a compatible player skin or visible wearable/outfit representation, including the brown duster when acquired. Do not substitute nametags, icons, or marker blocks for character bodies. Keep asset sources/license notes and fallbacks for missing optional assets.
- Give the main cast visible introductions and story presence, not just scheduled idle appearances. Stage concise first-meeting or reveal moments for the key characters and ensure Crane’s escape, Mercer’s confrontation, Nora’s rescue, and the verdict/epilogue show the relevant characters on screen. Use a small skippable cutscene or readable in-world staging with camera/facing, simple gestures, and dialogue; no voice acting or elaborate cinematic system is required. Restore controls and the normal camera reliably if a scene is skipped, interrupted, or the player disconnects.
- Make Crane’s hideout change follow the existing act/clue state. Implement Mercer and Nora only as needed for their already-authored encounter and rescue states; do not let routine movement break a story encounter.
- Make right-click dialogue accessible and concise. Preserve gates and choice effects; locked choices explain requirements. If the dialogue layer is replaced or consolidated, migrate existing interactions without changing their outcomes.
- Update routines at a fixed, low frequency. Pause or reduce activity for NPCs far from players; avoid unnecessary pathfinding or per-frame work. Give each NPC a safe fallback waypoint if terrain or an entity load fails.
- Scope horse/stable behavior only to GDD-compatible safety improvements that can be validated without replacing Mineclonia’s native riding/taming.

## Done means

- NPCs appear at expected sites, can be interacted with, and move to correct schedule waypoints in a disposable test world. Story-critical NPCs cannot wander out of reach or block completion.
- A player can visually tell the core characters apart without relying on their names. Avatars render in-world at gameplay scale, and the brown duster/player appearance is visibly represented when equipped or acquired.
- Key introductions and story scenes visibly feature their characters; they can be skipped safely and never leave player controls or camera state broken.
- Automated tests cover schedule selection, dialogue requirements/effects, story-state exceptions, distance throttling, and persistence/rejoin behavior where applicable.
- Run the full existing test suite and static checks. Include at least a concise visual/engine verification record; server-only assertions do not prove movement looks natural.
- Update README and sprint status with schedules, controls, test evidence, performance notes, and any planned follow-up. Make no unverified claim of complex AI; simple predictable routines are acceptable and preferred.
