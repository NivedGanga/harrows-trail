# Harrow’s Trail — Extended Sprint Roadmap

## Why the roadmap now has 11 sprints

Sprints 1–4 build the playable story: Acts 1–10, including the rescue, verdicts, and endings. They do **not** by themselves deliver the finished world described in the GDD. The current floating platform and labeled interaction blocks are a functional prototype. Sprints 5–7 replace that prototype with a connected frontier world, and Sprints 8–11 complete the living-world systems, atmosphere, and release validation.

The project is complete only when the story works in its intended Mineclonia world—not merely when the marker-based progression tests pass.

## Sequence

| Sprint | Focus | Main deliverable | GDD coverage |
|---|---|---|---|
| 1–3 | Playable acts through Bitter River | Existing progression prototype | M0–M4 in progress |
| 4 | Rescue, verdict, endings | Complete core story, with visible rescue/verdict/epilogue moments and all ending branches | M4–M5 |
| 5 | World foundation: Harrow Ranch and Red Mesa | Fixed-site placement system; grounded opening region | Sections 5, 11, 13.14 |
| 6 | Dust Flats to Silver Spur | Grounded mid-game route and settlements | Sections 5, 8.4, 11 |
| 7 | Crane’s Station to Widowmaker | Grounded late-game route and finale sites | Sections 5, 11 |
| 8 | Character avatars, introductions, and NPC routines | Distinct in-world cast, visible story introductions/scenes, dialogue, and schedules—not names on markers | Sections 8.8, 10, 13.9–13.10 |
| 9 | Reactive frontier systems | Honor/wanted/trust consequences, town responses, services and boards | Sections 8.1–8.4, 9 |
| 10 | Western atmosphere | Weather, textures, regional ambience and licensed/original audio | Sections 7, 10 |
| 11 | Full-game QA and release | Tested, documented, installable release candidate | Sections 13, 15–17; M7 |

## Important scope and safety rules

- Complete the existing Sprints 1–4 in order before starting Sprint 5. The new work is additive; do not skip ahead or replace already-tested story logic with a rewrite.
- Keep Luanti **5.17.0** and Mineclonia **0.124.1** pinned unless a version change is justified and tested separately. Continue using Mineclonia’s native horse and riding behavior.
- Build on natural Mineclonia terrain and biomes. Fixed story locations should be placed once, when first approached, using the GDD’s site-placement approach. Avoid placing over generated villages or destroying unrelated player builds.
- Keep saves backward-compatible. Never silently clear or migrate the user’s active world in place; test migrations and placement in disposable copies and provide backup instructions.
- Each sprint must leave the game loadable and playable. Preserve `/trail` or an equivalent clear journal/objective flow while changing the world presentation.
- Do not make user-performed graphical testing a blocker. Use automated tests, disposable-world checks, screenshots/logs where available, and state clearly what was or was not visually verified. Ask for only a short optional smoke test when human judgment is genuinely needed.
- Keep development/debug commands privileged or development-only. Check asset licenses before distribution.

## Sprint prompts

Run one prompt at a time with Codex from the project root, attaching the full GDD and `AGENTS.md` as project context. Each prompt is a new target file:

- [Sprint 5 — World foundation, Ranch and Red Mesa](../prompts/sprint-5.md)
- [Sprint 6 — Dust Flats, Dry Gulch and Silver Spur route](../prompts/sprint-6.md)
- [Sprint 7 — Station, Bitter River and Widowmaker](../prompts/sprint-7.md)
- [Sprint 8 — Character avatars, introductions and NPC routines](../prompts/sprint-8.md)
- [Sprint 9 — Reactive frontier systems](../prompts/sprint-9.md)
- [Sprint 10 — Western atmosphere and audio](../prompts/sprint-10.md)
- [Sprint 11 — Full-game QA and release candidate](../prompts/sprint-11.md)

## Definition of “real game” for this project

A new player starts at the burned ranch on a natural frontier map, travels through distinct and readable locations, sees the main cast as recognizable characters in key story moments (not only as names or dialogue), sees the world react to meaningful actions, follows clear story clues, and reaches a coherent ending. The world’s look and sound support the Western tone. Saves survive progression and restarts, and the project can be installed and tested using documented, pinned dependencies.
