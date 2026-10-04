# Architecture overview

## Project state

The accepted playable foundation is `v0.0.1-alpha.5`, and `v0.0.2-alpha.31` implements the shared menu and activity lifecycle. The unaccepted `v0.0.3-alpha.1` candidate ports Body Blocking as the first real activity on that architecture. The [legacy analysis](LEGACY-ANALYSIS.md) records verified v0.92 source findings, the [infrastructure plan](INFRASTRUCTURE-PLAN.md) defines ownership and lifecycle transitions, and the [migration notes](BODY-BLOCKING-MIGRATION.md) define this port's preserved behavior and intentional omissions. The authoritative legacy archive remains external to this checkout and unchanged.

The concrete shared-menu scope is defined in the [menu and infrastructure port specification](MENU-AND-INFRASTRUCTURE-PORT.md). That phase ends before any real legacy exercise or tutorial is migrated.

The inherited v0.92 map places exercises in separate areas of one large map and moves the player between them. It provides valuable exercises and interface work, but the successor project will use a smaller, intentionally planned layout and a clearer activity lifecycle.

## Map layout

The planned successor map will contain two broad kinds of space:

1. Neutral reusable arenas for mechanical exercises where terrain is incidental.
2. Decorated Warcraft-style areas for tutorials that teach play in a realistic context.

Terrain-dependent activities may retain dedicated areas. Compatible activities may share an arena by creating their units and temporary objects during setup and removing them during cleanup.

## Activity lifecycle

The shared controller allows only one active activity. Each activity provides the operations it needs from this common lifecycle:

1. `setup` creates or restores its required state.
2. `start` positions the player, camera, and interface.
3. Reset, replacement or exit invalidates the session so stale callbacks stop.
4. `cleanup` performs semantic work while its resources are still available.
5. Shared scopes dispose presentation and gameplay resources in reverse order.
6. `afterCleanup` and registered finalizers run after those resources are gone.
7. The controller restores shared fog and interface state, then returns to the
   requested menu or creates a fresh run.

Activities register owned handles and borrowed state with their session. The
shared layer handles units, timers, triggers, frames, images, markers, quests,
destructables and fog modifiers. Its timer helper guards callbacks with the
session identity without changing the timing chosen by an exercise.

The menu selects activities but does not contain their gameplay logic.

## Shared interface

The shared interface now provides root/category navigation and capability-driven Restart and Training Menu controls. Training Menu enters a reversible browsing state while the activity continues; Return to Training restores its toolbar and view. Continue, Back, Pause, Objectives, and lesson text remain future capabilities for activities that need them:

- training-path and activity selection;
- restart and return-to-menu controls;
- Continue, Back, Pause, and Objectives controls for tutorials;
- player-paced instruction text;
- optional reference pages and screenshots;
- reliable release of custom-frame keyboard focus;
- access to Warcraft III's native Quest window.

The archived design keeps the native lower console untouched and places successor controls in the safe top interface band: a compact toolbar, an Objectives dropdown beneath its button, and a Training Menu control beside the other custom buttons. The native Quest button and F9 path remain available. Custom-frame focus must be released after clicks so native F-keys and command inputs continue to work.

The campaign-style reference establishes three separate text channels: Quest entries for durable objectives and reference material; the Message Log for readable narration history; and temporary colored notifications for new concepts, prompts, or scripted events. A message disappearing must never advance a tutorial. Color changes use Warcraft’s inline text-color formatting, while Continue remains the explicit progression control for player-paced practice.

## Activity presentation state

The map itself must not imply that the trainee belongs to one Warcraft race. The lobby permits a race choice for now; the shared activity system will later decide which parts of race presentation can safely be randomized or changed at runtime. Race-specific tutorials create the units and presentation they require instead of relying on a permanent map-wide Orc setting.

Visibility is owned by the active activity. Mechanical exercises should reveal their complete arena. Tutorials that reproduce ordinary match conditions, including the camera tutorial, should use normal unexplored terrain and fog of war. Cleanup must remove activity visibility modifiers and restore the shared default before another activity starts.

Music and other race-flavored presentation should be selected by the active tutorial when the subject requires a race. Race-neutral activities may choose among appropriate themes without changing their rules.

## Persistence

Disk persistence is deferred. The infrastructure records attempts and completions in memory behind a small boundary, while Player Stats remains visibly unavailable. It never reads or writes the v0.92 profile path. If persistence later provides enough user value to justify implementation, the successor format should be separately versioned so later releases can add fields without invalidating earlier data.

The camera tutorial is intentionally player-paced: text explains a mechanic, the player practises without a time limit, and Continue controls progression. It is a later implementation step after the shared infrastructure and an initial legacy exercise have proven the lifecycle. Audio is optional and must never be required for completion. This makes tutorial progression separate from exercise scoring and from fragile detection of customized hotkeys.

## Reference implementation

The inherited v0.92 map remains the behavioral reference. Exercises will be migrated individually and compared with that version before the old map is retired.
