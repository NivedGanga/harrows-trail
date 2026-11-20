# Harrow’s Trail — Sprint 11 Prompt: Full-Game QA and Release Candidate

This is the final integration sprint after Sprints 1–10. Read `AGENTS.md`, the complete GDD, `docs/roadmap.md`, all sprint status records, and current code/tests before changing anything. Do not add large new features. Prioritize reproducible bugs, blockers, balance, installability, and accurate documentation.

## Outcome

A release candidate can be installed in a clean Luanti 5.17.0 + Mineclonia 0.124.1 environment, started in a fresh natural world, completed through all three endings, saved/reloaded safely, and understood by a new player using the journal and README.

## Implement and validate

- Run a full automated and disposable-world regression across Acts 1–10. Cover gates/consumption, all endings, gold/no-gold variants, old-save migration, restart/death, saddle recovery and horse persistence, schematic placement conflicts, NPC routines, weather determinism, and optional branches.
- Check the economy and pacing against the GDD: no mandatory repetitive mining grind; all required gates can be met through ordinary play; the cache remains optional; no timer makes the rescue unwinnable.
- Verify all six built settlements and story sites sit on appropriate terrain, are readable, do not overlap generated villages or unrelated builds, and connect by traversable routes. Record any visual review honestly; automate what can be automated and request only a short optional human smoke test for subjective issues.
- Test maximum intended NPC and particle/audio load. Fix serious regressions and record benchmark method/results. Remove or privilege-lock development commands, test fixtures, and cheats in release configuration.
- Add clean install/setup instructions, pinned dependency/version notes, new-world and existing-save guidance, backup/restore instructions, controls, known limitations, credits, and an asset-license inventory. Include a small bug-report/debug-state procedure without exposing private data.
- Produce a release checklist and a reproducible package/install method consistent with repository conventions. Do not publish externally or change repository visibility without separate authorization.

## Done means

- All automated tests and static checks pass, or every remaining failure is documented with a severity and reproduction step.
- At least one complete new-world playthrough is evidenced by automated progression coverage and/or a recorded disposable-world run; branch coverage demonstrates Justice, Mercy, and Vengeance. Clearly distinguish automated, server-side, and graphical evidence.
- No critical progression, persistence, asset-license, or data-loss issue is known. Remaining non-blockers are listed in a concise release report.
- Update README, sprint status, and release notes. Preserve the user’s saves and leave the project in a clean, loadable state.
