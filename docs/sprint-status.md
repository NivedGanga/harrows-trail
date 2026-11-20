# Sprint Status

## Current state

- Project phase: Pre-production
- Current sprint: Sprint 1 — blocked on setup; no gameplay implementation yet
- Playable build: None
- Luanti/Mineclonia versions: Not found or pinned (inspection 2026-11-20)

## Inspection and changes

- Repository contains the GDD, project instructions, this status file, and empty `mod/harrows_trail` and `prompts` directories. The supplied Sprint 1 prompt was copied from `../team race/outputs/harrows-trail-sprint-1-prompt.md` into `prompts/`.
- No Luanti or Minetest executable was found on PATH, in common Homebrew locations, or in `/Applications`. No Luanti/Minetest data directory or Mineclonia installation was found in the usual user locations inspected.
- No mod code was added: installed Mineclonia item names, dependencies, horse behavior, and APIs cannot be verified without the game. No version was selected or pinned.

## Checks and manual testing

- Repository and standard installation locations inspected; no engine or game was available to run.
- Automated and in-game checks: not run. All Sprint 1 acceptance criteria remain open, including native horse taming, saddle recovery, riding and persistence, progression, choice, and rejoin.
- Once the environment is available, test a fresh world through ranch investigation, fragment and saddle recovery, horse taming and riding, Ada's choice and response, and logout/rejoin; also test losing the saddle and death recovery.

## Setup needed

Install Luanti and Mineclonia, or provide the paths to an existing installation, so their exact versions and registries can be checked. Open the `harrows-trail` repository as the writable workspace before implementation. Do not upgrade a pinned game or use an existing world for destructive testing.

## Next sprint risks

Sprint 2 remains unstarted. Native horse persistence, safe site placement, and Mineclonia compatibility remain unverified.
