# Harrow’s Trail — Agent Instructions

## Project purpose

Build **Harrow’s Trail**, a single-player Western story game implemented as a Lua mod for Luanti and Mineclonia. The player is Eli Harrow, pursuing the rescue of his sister Nora and uncovering the truth about their father. The game is one persistent world with no timer.

## Source of truth and task scope

- Treat `docs/harrows-trail-gdd.md` as the source of truth for story, characters, locations, acts, items, progression, and intended systems. If that file is not present, locate the supplied GDD or ask the user where it is; do not invent replacements for its rules.

- For sprint work, read the corresponding prompt in `prompts/` and the current progress notes in `docs/sprint-status.md` when available.

- Implement **only the sprint or task explicitly requested**. Do not start later sprint work, broaden scope, or replace working foundations without a clear need.

- Preserve existing project structure and working behavior. Inspect the repository before editing; do not assume a particular layout if the repository differs from the suggested layout.

- If requirements conflict or an important design decision is still open in the GDD, identify the conflict and ask or document a proposed decision before building behavior that would be costly to change.

## Technical constraints

- Target Luanti with Mineclonia. Confirm the actual installed Luanti and Mineclonia versions and pin/document the versions used for development and testing. Do not upgrade the base game or change the pin without approval.

- Verify Lua APIs, Mineclonia mod dependencies, and registered item/node/entity names in the pinned installation before using them. Never guess registry identifiers based only on display names or examples from another release.

- Keep the implementation in Lua and use Luanti’s built-in APIs plus documented/exposed Mineclonia interfaces. Prefer the smallest change that meets the current sprint’s acceptance criteria.

- Use Mineclonia’s native horse and riding behavior. Do not create a custom horse entity or custom riding/movement system. Test persistence first and add only the minimum compatibility or saddle-recovery behavior the verified game requires.

- Keep player/story state versioned and persistent. Preserve existing saves; use migrations for schema changes. Do not reset, overwrite, or delete player worlds or save data as part of development or testing.

- Keep development/debug commands privileged and unavailable to normal players.

## Gameplay invariants

- Progress is earned through exploration, preparation, travel, investigation, choices, and story situations—not repetitive mandatory mining alone.

- There is no countdown or timer. Taking time to explore must not punish the player or undermine the rescue story.

- Gates open story opportunities; they do not automatically complete acts. Each act needs a clear objective and a playable resolution beyond an inventory check.

- Gate requirements and item-consumption behavior should be defined centrally in act/gate data, not duplicated inconsistently in dialogue. Explain missing requirements and identify consumed items before confirmation. Once unlocked, an act stays unlocked.

- Follow the GDD’s item-consumption rules. Test that consumed items are removed exactly once and reusable equipment remains available.

- Avoid softlocks. A failed gate has no penalty; required recovery paths and fallback options should work as designed.

- Keep honor and Nora’s trust numerically hidden from players. Give understandable qualitative feedback and explain why a choice is unavailable. Keep wanted-level effects consistent with the GDD.

- Make the story’s key outcomes explicit and persistent, especially whether Crane is captured alive, released, or killed. Do not show contradictory verdict choices.

- Keep the gold-cache branch optional; it must not block rescuing Nora or reaching the verdict.

## Implementation and quality expectations

- Before editing, inspect the relevant code, project instructions, version/dependency setup, and existing tests. For a large or ambiguous change, provide a short plan before implementation.

- Keep changes focused and maintainable. Reuse established project patterns unless they conflict with the GDD or create a concrete bug.

- Add or update tests where practical. Run relevant automated checks and report exactly what ran and whether it passed. Do not claim an in-game behavior passed unless it was actually tested in Luanti/Mineclonia.

- For manual gameplay checks, provide clear steps the developer can perform in-game. Include new-game progression, invalid and valid gates, item consumption, persistence/rejoin, death recovery, and regressions from earlier sprints when applicable.

- When placing towns or locations, use documented coordinates and one-time placement state. Test placement in Mineclonia and check for terrain disruption or overlap with native villages.

- Use only assets with verified licenses. Keep unverified or unlicensed music, textures, sounds, and other assets out of release builds.

- Do not spend a sprint on broad polish or simulation when its acceptance criteria call for playable progression. Prefer simple placeholder presentation over blocking core gameplay.

## Repository documentation

- Keep setup, pinned versions, required mods, and verified run/test instructions in `README.md` or the project’s existing equivalent.

- Keep the GDD in `docs/harrows-trail-gdd.md` and sprint prompts in `prompts/` if that matches the repository’s conventions.

- Keep `docs/sprint-status.md` current with completed criteria, test results, known issues, decisions, and the next sprint’s risks. Do not mark a criterion complete without evidence.

- Record any approved change to an open design decision in the status notes or GDD’s decisions log.

## Completion report

At the end of each task, report:

1. What changed and which files were affected.

1. How to run or test the result using verified instructions.

1. Automated checks and in-game checks actually performed, with results.

1. Acceptance criteria not yet met, known issues, and any temporary substitute or limitation.

1. Decisions or user input needed before expanding scope.

Do not begin the next sprint unless the user explicitly asks.