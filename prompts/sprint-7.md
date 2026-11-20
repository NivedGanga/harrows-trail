# Harrow’s Trail — Sprint 7 Prompt: Crane’s Station, Bitter River, and Widowmaker

Continue the existing project after Sprints 1–6. Read `AGENTS.md`, the GDD, `docs/roadmap.md`, sprint status, and the current site-placement/story systems. Preserve the stable version pins, save data, and all playable acts.

## Outcome

Acts 6–10 take place at grounded, legible late-game locations: Crane’s railway station, the Bitter River ferry and hideout, and Widowmaker Tunnel. The player can physically follow the clue trail from Silver Spur through the endgame.

## Implement

- Create fixed, terrain-safe sites for Crane’s Station and barricade, Bitter River ferry/dock and second hideout, and Widowmaker Tunnel/railway approach. Use the GDD’s distinct architectural language: rail depot and water tower, swamp reeds/stilt structures and ferry, and a supported stone tunnel mouth with rails.
- Connect the existing TNT decision/breach, Ghost Mine clue flow as appropriate, ferry options, ledger page 2, Act 9 encounter, Nora rescue, and Act 10 ending interactions to recognizable in-world locations. Do not silently change gates, outcomes, or story-state requirements.
- Ensure the route is navigable on foot and on the native Mineclonia horse where terrain permits. Provide signposting, landmarks, and journal hints without relying on exact coordinates. Keep combat/encounter spaces readable and avoid trapping the player.
- Use the shared one-time placement registry from Sprint 5. Preserve terrain outside footprints, reject village/build conflicts safely, and prevent repeat placement/reward duplication. Do not create a second parallel town-placement system.
- Preserve existing saves and progress. Any schema changes require a versioned, tested migration and backup guidance.

## Done means

- A fresh disposable-world run can travel from the mid-game region to the final encounter and return/epilogue path without needing the floating platform.
- Each late site places once and remains present after restart; story interactions and rescue/verdict outcomes still work.
- Automated checks cover site placement, route prerequisites, ledger/rescue/verdict progression and save/reload. Run all existing tests, syntax checks, and `git diff --check`.
- Record coordinates, terrain assumptions, unresolved visual issues, and what was tested in engine versus only in server tests. Do not claim a full graphical playthrough unless one was actually completed.

Update README, site documentation, and sprint status. Defer full NPC schedules, global honor/wanted reactions, and weather/audio polish to Sprints 8–10.
