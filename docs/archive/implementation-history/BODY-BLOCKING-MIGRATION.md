# Body Blocking migration

Candidate: `v0.0.3-alpha.1`

Body Blocking is the first real activity ported from the inherited v0.92 map. It runs in the southern reusable arena and derives every gameplay position from that scene instead of retaining legacy map coordinates.

## Preserved behavior

- Training and Custom formats with Normal and Hard difficulty.
- Four race rosters for Training and selectable runner/blocker matchups for Custom.
- A 3-2-1-GO start, rifleman start cue, invulnerable runner and collision-based delay objective.
- Failure when the blocker dies or falls 300 units behind, followed by a clean retry.
- Natural-time comparison, up to 15 seconds of added delay, a 0–100 score and block-streak feedback.
- Restart retains the current choices; a successful Training round advances to the next runner.

## Successor changes

- The course is 2,400 units long and centered in `arena.south`.
- GO clears after 0.65 seconds so it does not obscure early movement.
- All units, timers, triggers, frames, effects and markers belong to the activity session and are removed by the shared controller.
- Training Menu temporarily hides the activity view while preserving the live round, and Return to Training resumes it.

## Deferred legacy features

The first candidate intentionally omits legacy MMR/profile persistence, replay storage, terrain painting and the large bespoke picker interface. The shared dialogs and result panel prove gameplay and lifecycle behavior first. These omissions do not change the blocking rules and can be reconsidered after runtime comparison.
