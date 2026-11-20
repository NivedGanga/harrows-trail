# Harrow’s Trail — Sprint 9 Prompt: Reactive Frontier Systems

Continue the current project after Sprints 1–8. Read `AGENTS.md`, the GDD, roadmap, sprint status, and current state/schema. Preserve all existing story flags and avoid duplicate or contradictory implementations of honor, wanted, or Nora’s trust.

## Outcome

The frontier reacts consistently to consequential choices. Honor, wanted level, and Nora’s trust persist, have clear player feedback, affect NPCs/services and verdict availability as specified in GDD sections 8–9, and remain understandable without exposing hidden numeric scores.

## Implement

- Audit the current systems first. Complete missing event hooks for the GDD’s honor changes (returning stolen goods, helping, paying debts, theft, assault, bystander death), wanted changes and Nora’s trust changes (promises, surrender/mercy, abandonment, killing a surrendered prisoner). Prevent duplicate event awards and clamp scores to their valid ranges.
- Implement wanted-level consequences: town deputies attack at 3 stars; wanted posters appear and road bounty hunters become eligible at 4; a fine costs 3 gold ingots per star; alternatively, evasion for one full day/night cycle lowers wanted. Keep encounters safe and performant.
- Connect honor to meaningful price/rumor/ferry-fee differences and verdict availability. Connect Nora’s trust to legible dialogue/reactions and Mercy eligibility. Show plain-language feedback and explain unavailable choices without exposing exact hidden values.
- Implement/update bounty boards and wanted documents to reflect current state. Ensure any debt, side request, fine, or fee system provides a clear non-grind path and does not block the main story.
- Verify the optional gold cache and ending choice remain optional and independent of the rescue/verdict gates. Preserve the GDD’s Justice/Mercy/Vengeance rules and all existing save migrations.

## Done means

- Tests cover each score-changing event, caps/ranges, persistence, thresholds, wanted decay/fines, town reaction, prices/fees, poster updates, dialogue feedback, and verdict constraints.
- Save/reload and death/rejoin do not reset or double-apply consequences. No hidden-score UI leakage or contradictory story choices remain.
- Test in disposable worlds; run the complete suite, syntax checks, and `git diff --check`. Report untested visual/AI behavior separately.
- Update README and sprint status with the rule table, player-facing cues, test results, and any documented deviations. Do not expand scope into weather or asset production; those are Sprint 10.
