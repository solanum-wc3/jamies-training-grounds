# Architecture work list

Published baseline: v0.1.2-beta1; current source is alpha49, pending acceptance. Historical implementation audits are in the [0.1.2 archive](archive/v0.1.2/README.md).

## Implemented

- Separate release/development modules and build validation.
- Session/scoped resource ownership, guarded timers and baseline-aware cleanup.
- Shared briefing, catalogue, racial selector, toolbar and result-card helpers.
- Shared tutorial runner installed by all five narrated tutorials: stable entry generations, narration/presentation boundaries, checkpoints, fixed camera movement and interruption handling.
- Shared training countdown and presentation visibility used by Bat Splitting and Dodging.
- Economy semantic step IDs and checkpoint scenes; native worker gathering preserved independently of narration.
- Regression fixtures for tutorial transitions, exercise menus, scoring, orders and cleanup.

The consolidation described in the 14 October review is implemented: explicit tutorial scene lifetimes and restoration; stable-ID topic links; completion-attempt cues; shared response scoring; registered Hotkey/Reflex presentation; development-only Hotkey audit adapter; and authoritative generated briefing text for those two newer exercises. See [consolidation status and acceptance](CONSOLIDATION-2026-10-14.md).

## Next priorities

- Use the closest working tutorial/exercise before adding a new implementation; record necessary differences before coding.
- Keep native menu activation intact while investigating any reproduced paused-overlay problem. Do not reintroduce opening-button frame hooks.
- Separate Dodging eligibility, enemy orders and scoring further only when a concrete change benefits from it; retain known matchup outcomes.
- Extend scene/native-interaction coverage for future interactive tutorials and micro AI. Mock acceptance alone is insufficient.
- Review repeated code for extraction after its behavior is confirmed, rather than adding generalized abstractions preemptively.

## Deferred

- Clean player-facing text export until a supported native mechanism exists.
- Long-term player statistics pending a versioned persistence design.
- Combat, Creeping and The Base tutorials and other placeholder activities, subject to the user's scripts and priorities. Heroes is implemented and awaiting alpha49 acceptance.

## Earlier content directions (historical)

User direction, 11 October 2026: Heroes requires the user's script before implementation. Reflex Training (expanded beyond the legacy map) and Unit Comparison are the preferred next training candidates; either or both may be chosen. Scope and mechanics are not decided yet. Combat Micro is postponed because it needs substantial research. The Economy spelling pass is complete in source; no new alpha or public release was requested for it.

Those early directions are historical, not the current plan. Reflex now includes staged identification, multiple races and buff/debuff recognition; see [current behavior](REFLEX-TRAINING.md). Heroes now has an authored implementation. [Current acceptance work](DEVELOPMENT-STATUS.md) takes priority over starting another substantial feature. Unit Comparison remains a candidate, not started.
