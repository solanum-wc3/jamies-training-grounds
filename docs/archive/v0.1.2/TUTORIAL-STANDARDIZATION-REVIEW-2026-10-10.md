# Tutorial and recent-pass review

Reviewed 10 October 2026. Review only; no gameplay changes or new alpha produced.

Follow-up: the authorized implementation pass is recorded in [RELIABILITY-PASS-2026-10-10.md](RELIABILITY-PASS-2026-10-10.md). The findings below describe the state before that pass; native in-game acceptance remains outstanding.

## Conclusion

Tutorial standardization is partial. All four tutorials use shared presentation primitives, and all activities benefit from the existing controller and resource scopes. There is not yet one tutorial runner owning progression, presentation, checkpoint restoration and delayed step actions. The written standard describes a stronger contract than the implementation and tests currently enforce.

Trainings have a more substantial common presentation boundary: configuration briefings, toolbar capabilities, result cards, deferred restart, session guards and scoped cleanup. Their scoring and AI remain exercise-specific. They also suffered deviations in this pass; reusing the controller alone did not prevent menu overlays, positioning or native-order failures.

## Findings

| Priority | Finding and evidence | Recommended correction |
| --- | --- | --- |
| High | The tutorials independently implement `refreshControls`, narration clearing/rendering, frame construction, visibility and load reconstruction. `tutorial.lua` supplies helpers rather than a runner. Economy also retains Hotkey-oriented names and an unused command-arrow method. | Extract one tutorial presenter and progression runner; keep scene actions and unusual optional sections as explicit hooks. Migrate incrementally with behavior comparisons. |
| High | Checkpoint restoration has several implementations. Economy restarts and reconstructs; Unit Controls mostly calls `showStep` with selective cleanup; Camera restores narration and executes the selected trigger; Hotkey Setup changes steps directly. Those routes do not share a verifiable scene-state contract. | Define an explicit restore hook for each checkpoint and test its expected scene, independently of its narration. Do not assume replaying a current trigger reconstructs previous practice. |
| High | Economy restoration mixes stable actions with `sourceStop` number thresholds in `prepareCheckpoint`; runtime actions also include original numeric IDs. Construction is reconstructed as completed based on earlier instructions, rather than recorded player completion. | Give steps stable semantic IDs, named actions and explicit checkpoint scene specifications. Define what each practice checkpoint restores without relying on the old script's numbering. |
| High | `economy-layout.lua:startGathering` checks `self.orders[unit].build`, but `economy-tutorial.lua:order` only records `name`, `target`, `x` and `y`. Native player construction is not represented by that flag. The apparent construction-protection check is ineffective. | Track actual worker task/construction state through engine events or validated current orders. Preserve the approved policy of restoring gathering whenever a race is shown, but make task conflicts explicit. This finding does not establish the cause of the reported gold-Peon failure. |
| Medium | `Tutorial.ScheduleStep` checks only the step number plus the shared session guard. A focused reproduction scheduled at step 1, moved to step 2 and back to step 1, then ran the stale callback successfully. Economy's full-session checkpoint restart mitigates that route, but the helper is not safe for same-session revisits. | Assign a generation to each step entry, or dispose a separate step scope. Session guards protect replacement activities; entry guards must protect replacement visits. |
| Medium | The Economy layout provider still exposes the old observer-preview `showRace`, Next/Back cycling, restart data and presentation rebuild. The actual tutorial overrides some methods, while inheriting others. Its fixture still tests the obsolete preview behavior. | Separate scene creation from the preview activity. Remove preview-only methods from the scene provider and update tests to target the current tutorial contract. |
| Medium | Economy's baseline research reset depends on `JTG.DodgeTech`, coupling tutorial requirements to another exercise's catalogue. | Put shared melee technology data in a neutral shared module and explicitly validate the tutorial's initial research state. |
| High | The shared-standard test checks helper behavior and searches source for helper calls. Economy order mocks accept commands without native pathing, mining, target validity or construction semantics. Passing these tests does not establish that workers work in game. | Test real navigation/restoration paths and missing/invalid targets. Add in-game diagnostics for accepted order, actual current order, target, ownership and observable gathering/construction outcome. Keep native engine acceptance separate from Lua orchestration checks. |

## What is already sound

- Shared controller/session guards and scopes provide real lifecycle reuse, with separate gameplay and presentation resources for loading.
- All four tutorials use the shared narration formatter, button creation, menu/pause helpers and fixed-duration camera helper.
- Economy currently creates initial buildings before workers, starts all races at entry, grants full control to the active player-owned race, and keeps rendering separate from step actions.
- Shared training briefings and result cards provide reusable menu and result behavior. Recent tests exercise the actual menu functions, not just activity-specific callbacks.

These are useful foundations. They are not proof that every checkpoint, native interaction or save/load path is correct.

## Why the pass was unreliable

The code shows repeated local adaptations where a common contract should have been established first. Economy combines copied presentation code, the old layout preview, generated narration and a growing conditional action dispatcher. Dodging combines many native mechanics and matchup exceptions, which require stronger separation between presentation, eligibility, timing and enemy orders. Broad mocks then verified our intended commands, while much of their real engine behavior remained for the user to discover.

Some scope changed legitimately as the tutorial became interactive and Dodging evolved. That explains necessary redesign, but not repeated mistakes with established camera duration, cleanup, text sizing or menu presentation. Those should have been inherited and checked centrally. Reporting automated checks as sufficient evidence of readiness overstated what they demonstrated.

## Recommended work order

1. Correct the ineffective task guard and make worker/native-order diagnostics useful before further worker patches. Verify each race's gathering, ownership handoff and practice construction in game.
2. Extract the common tutorial presenter and runner from existing working behavior. Add stable step IDs, entry-scoped timers, and explicit checkpoint restore hooks. Preserve narration and authored Continue boundaries.
3. Migrate Economy first, then Camera, Unit Controls and Hotkey Setup, including optional branches. Require the same contract checks for each factory.
4. Test first entry, Continue, Back, Topics, Menu/Resume, pause, exit, re-entry and presentation reconstruction. Assert that rendering does not create units or issue orders, and that stale callbacks cannot act on a later visit. Verify scene contents and tasks after restoration, not just the requested step number.
5. Keep a short in-game acceptance pass for native harvesting, building placement, militia, summons, combat and save/load. Report these separately from syntax, archive and mock-test results.

Avoid a large general-purpose AI or scripting language rewrite. The useful optimization is fewer independent implementations of established behavior and clearer boundaries around native Warcraft interactions, rather than shorter code at any cost.

## Verification in this review

Read the four tutorial implementations, shared tutorial/controller/UI modules, Economy scene provider and relevant tests. Ran the existing shared tutorial contract test and Economy layout fixture, and reproduced the same-step stale callback behavior. No Warcraft III session was run; native-engine outcomes and save serialization remain unverified by this review.
