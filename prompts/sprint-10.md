# Harrow’s Trail — Sprint 10 Prompt: Western Atmosphere, Weather, and Audio

Continue the existing project after Sprints 1–9. Read `AGENTS.md`, the full GDD, roadmap, sprint status, and current asset/audio code. Keep the project loadable without optional licensed assets and preserve the pinned game versions.

## Outcome

The grounded world has a consistent warm, faded Western identity. Regional light, weather, textures, and sound reinforce locations and story without obscuring navigation, reducing performance, or introducing licensing risk.

## Implement

- Establish a coherent palette using weathered wood, rusted iron, sun-faded cloth, warm lantern/campfire light, and muted night colors. Use verified Mineclonia/Luanti assets or original project assets; do not overwrite base-game textures globally in a way that affects unrelated Mineclonia content.
- Polish the Sprint 8 character skins/outfits so the cast remains visually distinct and cohesive with the Western palette. Preserve readable silhouettes and outfit differences; maintain provenance/license notes and graceful fallbacks for every avatar asset.
- Add seeded per-day weather as specified: dust storms in Red Mesa/Dry Gulch and intended Dust Flats areas, rain in the swamp, and morning fog at Bitter River. The same world/day must reproduce the same weather after reload. Keep effects local, readable, and particle-capped per player.
- Add a small, opt-in sound layer: region wind, night crickets, railway whistle, saloon piano/harmonica, ferry/swamp ambience, and appropriate footsteps if supported. Prefer original or clearly licensed audio; document source and license for every non-original asset. If no valid music asset is available, ship ambience only rather than using unlicensed music.
- Provide settings or safe defaults to reduce/disable ambience and particle effects. Ensure weather and audio never hide objectives, change gates, or prevent play on low-end systems.
- Avoid shader-only dependencies. The game must retain its intended look with ordinary supported settings and no optional shaders.

## Done means

- Deterministic tests validate weather selection by seed/day, region boundaries, reload consistency, and particle/audio caps.
- Assets have an inventory with provenance and license notes; missing/optional files fail gracefully.
- Run the full suite and performance checks in a disposable world with NPCs and weather active. Provide a concise visual/audio review record; automated tests alone cannot establish that effects look or sound good.
- Update README and sprint status with settings, asset credits, version requirements, measured performance, and remaining limitations. Do not include unlicensed music or redistribute Mineclonia assets without confirming the applicable terms.
