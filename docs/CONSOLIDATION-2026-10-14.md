# Consolidation status — 14 October 2026

The agreed consolidation pass is implemented. This is a defined maintenance milestone, not a claim that future features will need no refactoring or that mocked tests replace Warcraft acceptance.

## Completed

- Tutorials share stable entry generations, fixed-duration camera movement, step/scene scopes, canonical checkpoint restoration and live progress-check hooks. Camera demonstrations are repeatable; Unit Controls restores missing actors and cleans up late summons; Economy protects harvesting/construction while refreshing ownership handoffs.
- Topic links and authored scene boundaries resolve stable step IDs. New narration stops do not shift these links. Optional branches retain authored progression and checkpoints.
- Completion cues use attempt identity across Menu/Resume, native menus, replay and presentation reconstruction. New in-place Body Blocking rounds and Hotkey/Reflex stages explicitly begin a new attempt. The four-Gargoyle dog celebration remains intact.
- Hotkey and Reflex share response awards and score appearance. Their clocks, completion conditions, score accumulation and high-score keys remain independent.
- Hotkey and Reflex declare presentation roots, frame lists and disposable aliases through one lifecycle. Old frame callbacks/aliases are dropped on load; presentation restoration cannot restart a completed exercise. Hotkey selection recovery stays an explicit native-specific resume action.
- Hotkey development mode dispatch, reports, native observations and audit traces live in a development-only adapter. Release packaging checks reject that adapter and its debug command. Native preparation, prerequisites, button recognition, event matching and timings remain unchanged.
- The two newer exercises' editable briefing files are authoritative and generate runtime Lua automatically during builds. Structural checks preserve page identity, paragraph breaks, dynamic selection summaries and author notes. Exporting snapshots cannot overwrite those files. Legacy exercise/tutorial work files remain manual authoring snapshots, explicitly documented as such.
- Current architecture, tutorial, authoring and build guidance describe these boundaries. Heroes and Creeping lesson authoring remains with the user.

## Automated evidence

39 Lua regression fixtures pass, including real-scope transitions, stable-ID navigation, worker-order orchestration, registered presentation hiding/rebuild, existing native Hotkey/audit mocks, stage progression and result audio identity. Additional Node checks cover authoring-file parsing, generated-text drift, dynamic summaries and the development-only Hotkey boundary. Release (28 modules) and development (44 modules) Lua assemblies and both MPQ packaging validations pass.

Validation builds were written only below `work/consolidation-validation/`, using the current configured alpha47 label. They are internal validation artifacts, not a new distributed alpha, and do not replace the previously delivered alpha47. No commit, push, public release or download-link update was made.

## Native acceptance for the next alpha

1. Camera: rapid Continue through attacks/production and repeated Back/Topics. Check old actors, building queues and delayed effects clear, and demonstrations reconstruct correctly.
2. Economy: first arrival at Orc through Continue must yield actual gold deliveries without Back/Continue. Repeat faction changes, preserving active miners and construction. This remains the principal unconfirmed engine-timing fix.
3. Unit Controls: revisit combat after deaths; check replacement actors, wolves, temporary effects and optional returns.
4. Hotkey: a brief normal round in each race, plus a build/learn submenu, shop, hero and uprooted Ancient command. Confirm ordinary recognition, menu return, third-mistake lower-UI reveal and stage continuation. A full catalogue audit is not required unless native failures recur.
5. Reflex: both modes, then menu return, identification-stage continuation and save/load. Crowd/targets/time must persist; old icon and result frames must not remain on screen.
6. Results: Menu/Resume, native menus and save/load must not replay completion audio. The next attempt/stage should play its own cue. Check Body Blocking replay and the four-Gargoyle celebration.
7. Learn to Play: guidance text, divider/card spacing, top-aligned enlarged Heroes art, new narration stops, equal interface-arrow sizes and lower Tavern row.

These checks concern actual engine behavior and visual layout. The consolidation is ready for acceptance; this is not a reason to rerun hundreds of hotkeys manually.
