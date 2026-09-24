# Architecture overview

## Project state

The inherited v0.92 map places exercises in separate areas of one large map and moves the player between them. It provides valuable exercises and interface work, but the successor project will use a smaller, intentionally planned layout and a clearer activity lifecycle.

## Map layout

The planned successor map will contain two broad kinds of space:

1. Neutral reusable arenas for mechanical exercises where terrain is incidental.
2. Decorated Warcraft-style areas for tutorials that teach play in a realistic context.

Terrain-dependent activities may retain dedicated areas. Compatible activities may share an arena by creating their units and temporary objects during setup and removing them during cleanup.

## Activity lifecycle

The shared controller will allow only one active activity. Each activity should provide the operations it needs from this common lifecycle:

1. `setup` creates or restores its required state.
2. `start` positions the player, camera, and interface.
3. `reset` returns the activity to its initial playable state.
4. `cleanup` removes activity-owned units, triggers, timers, effects, and interface state.
5. `exit` restores shared state and returns to the training menu.

The menu selects activities but does not contain their gameplay logic.

## Shared interface

The shared interface is expected to provide:

- training-path and activity selection;
- restart and return-to-menu controls;
- Continue, Back, Pause, and Objectives controls for tutorials;
- player-paced instruction text;
- optional reference pages and screenshots;
- reliable release of custom-frame keyboard focus;
- access to Warcraft III's native Quest window.

## Activity presentation state

The map itself must not imply that the trainee belongs to one Warcraft race. The lobby permits a race choice for now; the shared activity system will later decide which parts of race presentation can safely be randomized or changed at runtime. Race-specific tutorials create the units and presentation they require instead of relying on a permanent map-wide Orc setting.

Visibility is owned by the active activity. Mechanical exercises should reveal their complete arena. Tutorials that reproduce ordinary match conditions, including the camera tutorial, should use normal unexplored terrain and fog of war. Cleanup must remove activity visibility modifiers and restore the shared default before another activity starts.

Music and other race-flavored presentation should be selected by the active tutorial when the subject requires a race. Race-neutral activities may choose among appropriate themes without changing their rules.

## Persistence

The inherited persistence system must be documented before it is migrated. The successor format should be versioned so later releases can add tutorial completion, exercise results, preferences, and other fields without invalidating earlier data.

## Reference implementation

The inherited v0.92 map remains the behavioral reference. Exercises will be migrated individually and compared with that version before the old map is retired.
