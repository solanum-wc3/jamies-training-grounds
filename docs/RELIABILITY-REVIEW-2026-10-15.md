# Source reliability review — 15 October 2026

Scope: all five playable tutorials, ten exercises/demonstrations and their shared infrastructure. This is a source review and test-preparation pass, not Warcraft acceptance. No new alpha was installed or published. Player-facing wording, formatting and progression were left unchanged.

## Changes made

- Corrected Reflex's reversed Night Elf/Undead palette: Human blue, Orc red, Night Elf teal, Undead purple. The existing population fixture now asserts that convention independently of the runtime palette. Heroes, Economy and the layout workspace already use the correct colors.
- Added `tools/test-course-progression.lua`: real Body Blocking factories across all 22 racial runners; score/result idempotence, replay versus advancement, first/last boundaries, custom mode and carried state. Also checks Windwalk course-state isolation and timed-stage bounds.
- Added `tools/test-power-building.lua`: delayed/incorrect foundations, all-lane capture before release, assistant counts, repair ownership, pause/completion and presentation rebuild without restarting construction. Covers Town Hall, Blacksmith and Gryphon Aviary orchestration.
- Registered both fixtures in the reliability suite. They use explicit native mocks; neither simulates Warcraft pathfinding or construction speed.

The pre-review hash inventory covered 217 source/design files. The only changed file in that inventory is `src/activities/reflex-training.lua`, containing the authorized palette correction. Tests and this report are additional changes. Existing workflow/observer-plan working-tree edits were preserved.

## Findings and proposed follow-ups

### Hidden result presentation: conditional Windwalk defect

`src/activities/windwalk-pop.lua`, `finish` and `renderResultPresentation`: the one-second result callback renders unconditionally, and the renderer omits `visible=self.presentationVisible`. Shared `UI.ShowResultCard` defaults to visible. An isolated probe reproduced a hidden activity showing its result when the pending callback is deliberately allowed to run.

This is a confirmed visibility-contract gap, **not a reproduced normal-menu engine failure**: ordinary custom menus pause the game, which normally suspends that timer. Save/load/native-menu transitions deserve a focused check. Proposed fix: pass the activity's visibility to the result renderer; use the same contract in Body Blocking's renderer, which also omits it. Do not change pause or native-menu input handling to compensate. No runtime fix applied during this audit.

### Reset consistency: investigate before changing

`src/infrastructure/core.lua`, `ResetActivity`: Surrounds uses deferred recreation to let Warcraft retire old collision footprints; Gargoyle Surrounds does not enter that branch although it shares the Surrounds implementation. Flying initial actors may explain the distinction. Check repeated Redo after Stone Form before deciding to extend the deferred-reset list. This is a source inconsistency to investigate, not an established collision bug.

### Coverage improved; native acceptance remains separate

The earlier suite did not enter the complete Body Blocking, Windwalk or Power Building factories. Existing partial tests still covered hero creation order, formations and shared helpers. The new fixtures close specific orchestration gaps; they do not provide complete execution/branch coverage or native gameplay acceptance.

### Text proposals requiring approval

No changes applied:

| Location | Existing text/detail | Proposal |
| --- | --- | --- |
| Unit Controls, Control Group narration (`unit-controls-tutorial.lua:123`) | “by by selecting them” | Remove one “by”. Also remove the trailing space inside the Input tag if desired. |
| Windwalk briefing (`windwalk-pop.lua:7`) | “This allows him \"pop out\" a surrounded unit” | “This allows him to \"pop out\" a surrounded unit”. |

There is also a formatting-policy difference: the tutorial formatter makes Input gold, while the Surrounds Quest formatter makes Input green. Both are deliberate code paths; standardizing them would be a separate approved presentation change.

## Validation

- **41 Lua regression files passed**, including the two additions and the corrected race-palette expectation.
- Release/development Lua assembly passed: 30/46 modules.
- Authored briefing/drift, Heroes data, clean-checkout build-input and stock-delay override checks passed.
- Reviewed 7,816 decoded Lua literals from activity/shared presentation/generated narration sources. No unknown colon-style formatting tags were found. This checks vocabulary, not whether every display uses the right formatter or fits on screen.
- The 621-entry Hotkey catalogue has unique IDs and no missing names/icons in the inspected identity fields, rawcode-like fallback names, or unresolved native `<...>` tokens in stored descriptions. This does not retest native command recognition.
- All 21 Reflex effect/caster/buff associations were checked against locally extracted installed ability data and the catalogue. Each race has buff and debuff entries. Native effect onset and targeting still require the game.
- Both packaging modes passed syntax, archive round-trip, unchanged-member/foundation checks, development boundaries and shared lifecycle/result/menu invariants. Outputs are isolated under `work/overnight-audit-builds/`.
- The installed alpha49 retains SHA-256 `8fc0c3852c1c662f5c0a9697bb18a7384df26c45909f0a1e87fb46e0b0b578d0`.

Temporary inventories and the conditional result probe are under ignored `work/`. The maintained tests are under `tools/`.

## Focused Warcraft acceptance route

Use the next explicitly requested numbered alpha for the palette change; the installed alpha49 has not been replaced. Existing alpha49 can be used for the other checks. Start with the first three rows, then cover the remaining activities without repeating exhaustive Hotkey audits.

| Activity/system | Test that adds evidence beyond mocks |
| --- | --- |
| Camera | Fast Continue through the attack; attackers die on leaving. Back reconstructs it. Check right-base lumber placement/drop-off and the idle-worker checkpoint. |
| Economy | First Continue arrival at Orcs: five gold workers mine without manual intervention. Back/Continue preserves active gathering; test construction/Burrow/Unsummon/Sacrifice checkpoints. |
| Heroes | Levels 1/10, +/− position/inventory/skills, dummy damage/auto-attacks, XP tasks and Quest unlock; Optional/Topics returns reconstruct correctly. |
| Unit Controls / Hotkey Setup | Fast navigation, optional-return actors/arrows, paragraph/formatting display. Hotkey Setup export stays absent. |
| Hotkey Trainer | One round per pool; build/learn submenus, shop patron/stock, research tiers, autocast and uprooted Ancients. Test three-error UI reveal, recovery, later-stage review and menu/load restoration. |
| Reflex WIP | One-race and four-race starts; teal/purple after the next build. Identify all targets, clear marking on next stage; ten effect trials have matching names/effects. |
| Mining Micro | Human/Orc, One Minute/Unlimited; result loss-mitigation and lumber agree with actual resources. |
| Body Blocking | Finish/Redo/Replay/Next/Last across first and final runner; five same-runner Redos show the hint and native Quest arrow. |
| Surrounds / Gargoyle Surrounds | Failure and Redo hint counts, next setup, repeated Stone Form/Redo, finish-line outcome and four-Gargoyle dog cue. |
| Windwalk Pop | Normal/Hard/Timed/Counterplay. Hero order, course carry state, exit/re-enter. Open menus immediately after success to probe delayed-result visibility. |
| Dodging | Disjoin/Area/Devour; movable countdown, chain bounce overlay/Footman delays, eligibility, native F10/F12 while a nested exercise menu is open. |
| Bat Splitting | Normal/Hard, direct/splash/mixed results; menu/Resume/Exit and immediate Redo. |
| Power Building | Small and large building plus Blacksmith: all lanes start together, repair proceeds, timers stop at completion; leave/re-enter. |
| Shared exit/save/load | After summoning, merging or splitting units: exit, launch another activity, check no leftovers. Save/load an active tutorial and a completed exercise; confirm world state and menu visibility. |

## Recommended order

Finish alpha49's tutorial acceptance first, then approve the small result-visibility fix and any wording corrections. Resolve only reproduced native failures before another consolidation. Keep Demo Mode and observers as planning until activated. Avoid another broad refactor while the main uncertainty is engine behavior rather than source structure.

Review work is based on `143804c` on `codex/alpha49-checkpoint`; inspect the following audit checkpoint for its source/tests/report changes. No merge, push, release-link update or milestone acceptance is implied.
