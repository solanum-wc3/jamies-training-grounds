# Architecture work list

Baseline: v0.1.2-beta1. Historical implementation audits are in the [0.1.2 archive](archive/v0.1.2/README.md).

## Implemented

- Separate release/development modules and build validation.
- Session/scoped resource ownership, guarded timers and baseline-aware cleanup.
- Shared briefing, catalogue, racial selector, toolbar and result-card helpers.
- Shared tutorial runner installed by all four tutorials: stable entry generations, narration/presentation boundaries, checkpoints, fixed camera movement and interruption handling.
- Shared training countdown and presentation visibility used by Bat Splitting and Dodging.
- Economy semantic step IDs and checkpoint scenes; native worker gathering preserved independently of narration.
- Regression fixtures for tutorial transitions, exercise menus, scoring, orders and cleanup.

## Next priorities

- Use the closest working tutorial/exercise before adding a new implementation; record necessary differences before coding.
- Keep native menu activation intact while investigating any reproduced paused-overlay problem. Do not reintroduce opening-button frame hooks.
- Separate Dodging eligibility, enemy orders and scoring further only when a concrete change benefits from it; retain known matchup outcomes.
- Extend scene/native-interaction coverage for future interactive tutorials and micro AI. Mock acceptance alone is insufficient.
- Review repeated code for extraction after its behavior is confirmed, rather than adding generalized abstractions preemptively.

## Deferred

- Clean player-facing text export until a supported native mechanism exists.
- Long-term player statistics pending a versioned persistence design.
- Future Heroes, Combat, Creeping and The Base tutorials and other placeholder activities.

## Next content candidates

User direction, 11 October 2026: Heroes requires the user's script before implementation. Reflex Training (expanded beyond the legacy map) and Unit Comparison are the preferred next training candidates; either or both may be chosen. Scope and mechanics are not decided yet. Combat Micro is postponed because it needs substantial research. The Economy spelling pass is complete in source; no new alpha or public release was requested for it.

Reflex's crowd prototype was tested in v0.1.3-alpha1/alpha2. Source now adds randomized population budgets and a fixed Footman–Footman–Priest–Knight recognition round with countdown, animated icons and transparent completion markers; see [prototype and test focus](REFLEX-TRAINING.md). No additional alpha is requested yet. Further target variations and scoring remain undecided. Unit Comparison remains a candidate, not started.
