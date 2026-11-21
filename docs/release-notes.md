# Harrow's Trail RC1

RC1 combines Acts 1–10 with a grounded frontier, visible original cast, introductions and schedules, reactive reputation/services, seeded local weather and opt-in original sound. Luanti 5.17.0 and Mineclonia 0.124.1 remain pinned. Native horses and riding are retained.

The final QA adds a no-cache economy check, all 12 verdict/gold epilogue combinations, a 32-NPC stress scenario, release-privilege checks, a privacy-limited `/trail_report`, SQLite for newly created launcher worlds, reproducible packaging and extracted-install tests. Existing world layouts and database backends are retained. Character visibility updates are sent only when changed.

A presentation ambiguity is clarified: freeing Crane from his restraints is a truce pending the final verdict; he remains present with Ada until that decision. Mercy finalizes his departure. Killed Crane never appears for trial, and release/capture/kill flags and old saves remain compatible. New-layout dialogue points back to Ada rather than obsolete ending markers.

Validation is automated/server-side. Actual riding, connected-player death/rejoin, graphical play, movement quality, client FPS and listening quality are unverified; manual verification was waived. No critical progression/data-loss issue is known from automated coverage. See INSTALL.md in the package or `docs/release-candidate.md` in source for evidence, setup, backup/restore, controls, limits and reproduction commands. Asset provenance is in ASSETS.md in the package or `docs/assets.md` in source. This package is local; no public publication or visibility change is part of the release process.

Final source and extracted-package suites pass. The no-cache budget retains seven gold after required purchases and a 12-gold fine. The 32-NPC/12-particle/two-audio-handle probe took 25.4 ms in source QA and 60.7 ms from the extracted package for 100 updates; these are instrumented server CPU figures, not FPS. Both structural walking corridor suites pass. The original RC1 runtime digest was `c01397583de0e8f4b6e8371936a7b73ba2a24f7db76d3c42a2bb5ee73f913264`; the package manifest identifies the current patched runtime.

## Right-click document hotfix

Story map fragments, the Harrow map and both ledgers now open on right-click in air or on ordinary blocks, as well as left-click. Interactive blocks retain native priority; sneak-right-click reads instead. Existing saved items, metadata and story state are retained. Native empty/filled terrain-map behavior is unchanged. The new document callback regression is included in the full test runner.

## Illustrated Samuel maps

All three fragments and the assembled Harrow map now open parchment route sketches with landmarks, a north compass, dotted trails and clue notes. The assembled map includes a Silver Spur assay-office cache inset; finding the gold remains optional. The sketches use saved/current story-site positions and support legacy layouts. Existing item IDs, metadata, gates and saves are retained. Ledger readers and native terrain maps retain their controls.

Fragment I and the assembled map were visually inspected in a disposable pinned Luanti client, including corrected heading/footer fit. All four views, legacy projection, three input callbacks per document, node priority and state preservation pass server tests. These are not a full graphical playthrough or physical mouse-click acceptance.
