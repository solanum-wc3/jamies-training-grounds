# Legacy Unit Comparison: port assessment

Reviewed 15 October 2026. Planning only: `tools.compare` remains a placeholder. No gameplay code, menu availability or distributed build changed for this review.

## Evidence and scope

Inspected the extracted v0.92 legacy script, `work/legacy-analysis/war3map.lua` (identical to `work/legacy-war3map.lua`; SHA-256 `aa371b9303baf554c615a620267ec960e05c2500c11eb28de63572f1fb9f34c0`). Relevant sections:

- `DC_AddUnit` / `DC_InitCatalogues`, around lines 15312–15356: shared Demo catalogue.
- `UnitComparison_GetRaceName` through `UnitComparison_Cleanup`, lines 16649–17519: comparison and quiz.
- `Training_StartUnitComparisonLevel`, around lines 18554–18586: entry, camera, fog and shared legacy controls.

This is source inspection and a roster cross-check against the installed native unit-ID inventory, not a new in-game acceptance test. The legacy comparison uses live getters for base unit metadata, but its attack/armor multipliers are a manually coded table; this review does not establish those numbers as current game rules.

## What it does

The module has an exploration view and an endless quiz.

In exploration, the player chooses a race. Its ground and air unit entries are spawned in a line, ordered by sampled maximum HP, with alphabetical tie-breaking. Each has an HP label. Selecting a lineup unit shows its portrait, HP, attack type and armor type. Two buttons change the result display:

- **Strong:** units whose armor type receives a multiplier above 100% from the selected unit's first attack type.
- **Weak:** units whose first attack type receives a multiplier above 100% against the selected unit's armor type.

Results are divided into four racial columns, sorted by HP, with unit names, the relevant attack/armor category and the percentage. Large groups split into two branches. The displayed models are paused, invulnerable and have pathing disabled; this is an explanatory gallery, not a combat simulation. Only the original lineup is interactive in exploration; clicking result models does not drill into them.

The quiz shows one attacker below four possible targets. It selects one answer from that attack type's highest-multiplier armor group and three distinct distractors from lower-multiplier groups, then shuffles the choices. Clicking an answer immediately grades it, highlights the correct model, updates correct/wrong/streak counts and starts another question after 0.85 seconds. It has no fixed session length, timer-based score or end card.

The catalogue supplies 46 candidate entries before spawn validation: Human 12, Orc 12, Undead 11 and Night Elf 11. Despite the comment calling these combat units, the filter includes workers. Heroes, buildings, neutral units and summons are not part of this comparison roster. Several alternate forms/variants are also absent.

## Useful behavior to retain

- Direct selection and immediate result changes, without restarting the activity.
- Visual unit models, HP ordering and percentages rather than a purely textual chart.
- Native sampling of HP, armor category and attack category instead of a second spreadsheet of numerical stats.
- A common roster shared with Demo Mode, while keeping the activities' own selection, presentation and cleanup independent.
- Quiz generation that deliberately distinguishes one best answer among the four displayed choices.

## Important limits and port risks

1. **Damage-type advantage is not overall combat strength.** Results ignore armor value, attack damage, attack rate, HP, costs, abilities and immunities. Ground/air attack eligibility is deliberately not filtered in the legacy code. A result can therefore show a type advantage against a unit the attacker cannot actually damage. We should decide whether to preserve a strictly labeled type lesson or add a separate practical-matchup view; silently presenting it as a counter guide would be misleading.

2. **Only the first attack is read.** Alternate weapons and forms can have different attack types or targeting rules. The port needs an explicit policy for those cases rather than treating the first weapon field as the whole unit. Non-attacking workers also need a deliberate gallery/quiz eligibility rule; the current filter does not check for an enabled weapon.

3. **The roster is manually named and incomplete.** For example, the legacy Batrider entry uses `obat`, which is absent from our installed native unit-ID inventory; the existing native trainer uses `otbr`. Other shared Demo entries label `eaoe` as Ancient of War and `eaom` as Ancient of Lore, opposite the installed names. Those buildings are outside the legacy comparison roster, but the discrepancy matters if Demo and Comparison share a new catalogue. Native identities, names, icons and forms must be validated before reuse; a failed spawn should be reported rather than quietly dropped.

4. **The table is hardcoded, and the sample cache is not continuously live.** A one-time pass creates and removes roster samples, then caches their base metadata for the map session. It does not follow subsequently applied upgrades, buffs or changed ownership. This is reasonable for a base-stat gallery if labeled accordingly. Validate multipliers against the map's actual gameplay constants and representative native hits before grading answers.

5. **Question fallback assumes a suitable roster.** It tries up to 80 random attackers, then falls back to the first entry without guaranteeing three lower-multiplier distractors. Its distinct-distractor loop has no retry bound. A smaller or differently filtered roster could break those assumptions. Precomputing eligible attacker/answer groups and shuffling bounded candidate lists would give reliable questions without needing repeated random searches.

6. **Lifetime and presentation are coupled to legacy globals.** State lives in `udg_compare*` arrays and checks active level 12. Frames and selection triggers are initialized once; coordinates, camera zoom and terrain deformations are fixed. Cleanup explicitly removes models, tags, effects, quiz timer and terrain changes, but those routines do not supply the current map's scoped ownership, borrowed-state restoration or shared menu/load presentation contract.

7. **Palette and layout need adaptation.** Legacy Night Elf units use player color 10, whereas the project requires teal; Undead must remain purple. Racial order should follow Human, Orc, Night Elf, Undead. A broader roster will also need a screen-fit check rather than inheriting the old column spacing and 2200 camera distance.

## Fit with the current structure

Implement a separate `tools.compare` activity, with the standard briefing, race selector and Menu toolbar. Keep the roster metadata in a maintained/generated catalogue that Demo can also consume; do not make Comparison depend on starting the Demo activity or generating every Demo picker.

Keep lineup and results in disposable child scopes, so changing race or selection rebuilds only the necessary display. Quiz questions should have their own scope for models, tags and the delayed next-question callback. Shared activity/presentation helpers should own menu hiding, pause/resume, load reconstruction and final cleanup. Rebuilding frames must not create a new question or reset quiz counters.

The most useful improvement over a literal port is separating pure matchup/question calculations from unit spawning and display. These calculations can be tested exhaustively with the validated roster, including empty groups, ties, missing weapons and no-bonus attack types. That is a small local separation, not a reason to redesign the project infrastructure.

## Suggested future sequence

First agree whether the feature teaches attack/armor categories or broader practical matchups, and choose its roster/form scope. Then validate the catalogue and multipliers, port the HP gallery and selection/results, and verify camera/menu/exit behavior in Warcraft. Add the quiz once those rules are accepted. Keep any new timed scoring or broader statistics as separate design decisions.

This should be a smaller port than the full Demo workbench. It does not need Hotkey Trainer's command-card input recognition: ordinary model selection drives it. The main effort is accurate data, honest presentation of the comparison's limits, and clean integration with the existing lifecycle. Native interaction, displayed armor information, layout and representative damage multipliers remain in-game checks.
