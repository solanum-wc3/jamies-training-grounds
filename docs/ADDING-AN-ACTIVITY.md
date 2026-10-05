# Adding an activity

Use an existing activity of similar shape as the starting example. Copy concepts and shared helpers; do not copy coordinates, global state or cleanup code blindly.

## 1. Define the player experience

Before coding, record:

- what the player learns or practises;
- whether it is a tutorial, repeatable exercise or demonstration;
- required terrain and units;
- configuration pages and modes;
- success, failure and progression rules;
- controls, Quest references, reset behavior and save/load expectations.

## 2. Choose or register a scene

Reusable mechanical activities should use `arena.south` or `arena.north` unless they genuinely need dedicated terrain. Register a new scene in `src/infrastructure/catalog.lua` only when terrain, fog or permanent objects are part of the lesson. Derive gameplay positions from the scene rather than embedding coordinates from an older map.

## 3. Register the activity

Add a descriptor in `src/infrastructure/catalog.lua` with:

- a stable ID such as `skills.example`;
- category, title, description and artwork;
- `status = "available"` only when a real factory exists;
- scene ID and optional race availability;
- toolbar capabilities;
- optional briefing-menu function;
- activity factory.

The catalogue displays descriptors. It must not create exercise units or implement scoring.

## 4. Implement the lifecycle

Create `src/activities/<activity>.lua` and add it to the explicit module list in `tools/build-infrastructure.cjs`. A typical activity implements:

- `setup(session)` to create owned state and register restoration before mutation;
- `start(session)` to expose the activity and begin its first phase;
- `captureResetState()` when Redo or stage navigation must retain choices;
- `cleanup()` for semantic cleanup that needs live resources;
- `afterCleanup()` only for work that must occur after disposal;
- presentation hide, restore or rebuild hooks when menus and save/load require them.

Use `JTG.ScopeTrack*` helpers for units, timers, triggers, frames, images, markers, quests, destructables and fog modifiers. Use guarded scoped timers so callbacks from an invalidated session cannot affect its replacement. Register borrowed camera, selection, alliance, resource or object state before changing it.

## 5. Use shared presentation

Use `JTG.UI.ShowActivityBriefing` for briefing and selector pages. Preserve the shared title, body, artwork, divider and footer anchors unless the content needs an explicit override.

Advertise toolbar capabilities rather than creating another permanent toolbar. Use the shared result card for ordinary completion, success and failure states. Supply activity-specific text and progression while reusing common Replay, Retry, Next and Menu behavior.

Quest text should explain behavior a player can use. Put experimental detail and engine hypotheses in project documentation instead.

## 6. Support interruption and persistence

Test Menu, Resume, Exit, Redo and activity replacement during countdowns, active play and result presentation. If the activity can be saved in those states, capture enough semantic data to reconstruct presentation without retaining invalid frame or handle references.

Cleanup must be safe after partial setup and repeated transition attempts. Activity-specific code must not assume its timers or units survive reset or exit.

## 7. Build and validate

Run both builds:

```text
pnpm run build:all
```

Then test in Warcraft III:

1. first entry and normal completion;
2. Redo and repeated re-entry;
3. Menu, Resume and Exit from every meaningful phase;
4. replacement by another activity;
5. Replay/Retry/Next where present;
6. save/load restoration;
7. Quest, hotkeys, selection, fog and camera restoration;
8. `-diag-lifecycle` in the development build.

Update [`ACTIVITIES.md`](ACTIVITIES.md), the changelog and any affected architectural decision. Keep experimental tools in development-only modules and prove the release build does not package them.
