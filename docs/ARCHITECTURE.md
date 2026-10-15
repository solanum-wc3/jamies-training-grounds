# Architecture overview

## Project state

`v0.1.2-beta1` is the current tested release. It is assembled reproducibly from the accepted `v0.0.1-alpha.5` foundation, maintained Lua modules and packaged assets. The foundation remains immutable and is verified by hash during every build.

The published beta contains four tutorials and eight exercises. Current alpha49 development has five tutorials and ten exercises/demonstrations, listed in the [activity catalogue](ACTIVITIES.md), including the authored Heroes tutorial, Reflex Training and Hotkey Trainer. Economy, Bat Splitting and Dodging use shared tutorial/training procedures. [Development status](DEVELOPMENT-STATUS.md) separates implementation from native acceptance. Earlier migration specifications and candidate checklists remain under [`archive/`](archive/README.md) as historical context.

## Source and build boundary

- `src/infrastructure/` contains the controller, shared interface, registry and development diagnostics.
- `src/activities/` contains activity-specific rules and presentation.
- `src/assets/` and `src/data/` contain packaged resources.
- `tools/build-infrastructure.cjs` assembles release and development maps from the accepted foundation.
- Release builds omit diagnostic modules and commands. Development builds add them without changing player-facing activity code.

The module list in the builder is explicit so packaging order and the boundary between release and development code remain reviewable.

## Activity lifecycle

Player 6 is reserved for controllable hostile Target Dummies. Its one-way shared control for player 0 is configured before play; activities must not toggle it or place unrelated controllable units on that faction. Runtime permission changes emit a native notification sound. Hostility remains tutorial-scoped.

Only one activity session may be active:

1. `setup` creates or restores gameplay and presentation state.
2. `start` exposes the activity to the player.
3. Reset, replacement or exit invalidates the session so stale callbacks cannot affect the next activity.
4. `cleanup` performs semantic work while owned resources still exist.
5. Presentation and gameplay scopes dispose tracked resources in reverse order.
6. `afterCleanup` and registered finalizers run after disposal.
7. Shared fog, interface and borrowed state are restored before navigation or replacement continues.

Shared ownership helpers cover units, timers, triggers, frames, images, lightning markers, quests, destructables, fog modifiers and borrowed state. Activities own their rules; the menu and controller only dispatch lifecycle and shared actions.

## Shared presentation

The root menu, category catalogues, race submenus and activity briefing pages share layout primitives. Activities may override artwork dimensions or choice layout when their content requires it.

The toolbar uses stable positions for Menu, Back, Topics/Setups, Next, Redo, Pause and Rotate/Squares. Capabilities decide which controls an activity shows. Result cards share layout, semantic heading colors and action dispatch while each activity supplies its result text and progression.

Quest entries hold durable instructions and reference material. Temporary notifications introduce immediate events, and the Message Log preserves narration history. Tutorial progress must never depend on a message disappearing.

## Map and presentation ownership

The foundation provides reusable arenas and retained Twisted Meadows terrain. Mechanical exercises create temporary units and objects in shared scenes. Terrain-dependent tutorials may use dedicated decorated areas.

Visibility belongs to the active activity. Arena exercises reveal their scene; match-like tutorials may retain normal fog and unexplored terrain. Camera, selection, alliances, resources, music and modified preplaced objects are borrowed state and must be restored during cleanup.

## Persistence

Save/load reconstructs supported in-map activity and menu presentation. Long-term player statistics remain deferred. The successor does not read or write the inherited v0.92 profile path, and Player Stats remains unavailable until a separately versioned persistence format provides enough value.

## Development diagnostics

Development builds include the automated lifecycle check and collision research scenarios. The lifecycle check verifies reset, replacement, exit, disposal, post-disposal cleanup and stale-callback protection. Collision findings are documented in [`COLLISION-OBSTRUCTION-RESEARCH.md`](COLLISION-OBSTRUCTION-RESEARCH.md).

## Tutorial and training procedures

`src/infrastructure/tutorial.lua` owns the shared tutorial runner. Explicit authored hooks retain progression, optional topics and checkpoint scenes. Every entry receives a generation so revisiting the same step cannot revive stale callbacks. Presentation restoration never repeats world actions.

`src/infrastructure/training.lua` owns shared countdowns, visibility, completion-attempt identity, response scoring and score appearance. Hotkey and Reflex register their presentation roots, frame lists and rebuild aliases through `InstallPresentation`; native selection recovery remains an explicit Hotkey hook. Other exercises retain their existing shared visibility hooks. Clocks, stage progression, high-score storage and native enemy commands remain activity-specific. Economy separates its scene provider (`economy-layout.lua`) from authored JSON steps and tutorial progression. See [Tutorial standard](TUTORIAL-STANDARD.md).

Development modules also provide Economy layout/order exports and automated Dodging timing trials. Diagnostic Preload files are machine-readable evidence, not a supported arbitrary-text export facility.
