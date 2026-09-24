# Decision 0001: Build a planned successor map

- Status: Accepted
- Date: 2026-09-23

## Context

Version 0.92 uses a very large map with each exercise permanently placed in a separate location. Switching is quick, but most terrain is irrelevant during any one activity and the native minimap represents the entire map.

Warcraft III does not provide straightforward native minimap cropping for an active exercise. Dynamically rebuilding arbitrary terrain and pathing would also be fragile.

## Decision

Create a smaller successor map with reusable neutral arenas and dedicated realistic tutorial areas. Migrate useful shared systems and individual exercises from v0.92 in controlled stages.

Every migrated or new activity will use a shared lifecycle for setup, start, reset, cleanup, and exit. The inherited map will remain unchanged as the behavioral reference during migration.

## Consequences

- The minimap can represent a much larger proportion of relevant terrain.
- Shared cleanup and reset behavior must be designed before exercises are migrated.
- Existing work will be ported incrementally rather than copied wholesale.
- A period of parallel maintenance is expected while the successor map is incomplete.

