# Menu and shared-infrastructure port specification

Status: revised implementation candidate built as `v0.0.2-alpha.31`; runtime acceptance pending. This scope ports shared structure from v0.92 into the accepted `v0.0.1-alpha.5` successor foundation. It does not port Body Blocking, Reflexes, the camera tutorial, or any other activity.

## Top-level menu

The initial screen is the permanent navigation root:

```text
Jamie’s Training Grounds

[Learn to Play]
[Advanced Play]
[Skill Training]
[Tools & Extras]

[Player Stats]   [Patch Notes]   [Credits]
```

The four category controls open catalogues. `Patch Notes` and `Credits` open informational panels and never create an activity session. `Player Stats` is present as a disabled or visibly unfinished placeholder until persistence and useful statistics are designed. The successor does not load or save the v0.92 profile during this phase, so the existing local profile file remains untouched.

Patch Notes record completed milestones only. Entries include a version and date, appear newest first, and normally use one or two concise points. The panel uses a native scrollable text area so additional completed milestones do not require shrinking the text or enlarging the menu.

The former legacy `Info` button and its replacement of the native Quest button are not ported. The native Quest button and F9 remain available. Activity-specific Quest entries are the responsibility of a future activity, not the top-level menu.

## Categories

| Category | Purpose | Initial content state |
| --- | --- | --- |
| Learn to Play | Basic controls and beginner tutorials | Catalogue shell with planned entries; no tutorial implementation in this phase |
| Advanced Play | Competitive tutorials such as build orders, base layouts, scouting and strategic decisions | Catalogue shell; planned entries may be disabled |
| Skill Training | Repeatable mechanical exercises, including race-specific exercises | Catalogue shell populated from descriptors; legacy exercises remain unavailable until migrated |
| Tools & Extras | Analysis tools, demonstrations, quizzes and optional games | Catalogue shell; planned entries may be disabled |

Known tutorials, exercises, and tools are represented by catalogue cards from the first menu build, including entries that have not been migrated. Unavailable entries remain visible with a grey treatment and cannot launch. This retains the useful roadmap effect of the legacy catalogue without attaching placeholder clicks to gameplay code. Each card declares a stable ID, category, title, short description, implementation status, optional race tags, and an activity factory only when implemented. The menu renders descriptors and sends a selection request to the controller; it contains no exercise rules.

Every catalogue provides Back to return to the navigation root. Returning from an activity restores the catalogue from which it was launched rather than always opening the old Advanced catalogue.

Active category, illustrated-card, and activity controls provide concise native-frame tooltips on hover. Back, Patch Notes, Credits, planned entries without artwork, and the disabled Player Stats placeholder do not need tooltips. Tooltips describe the action and any lifecycle consequence; they do not replace visible labels or activity instructions.

Scripted button actions are deferred by one zero-duration timer callback so Warcraft can finish its native mouse-release transition before the action changes panel visibility or activity state. This avoids clearing focus or hiding a clicked frame from inside `FRAMEEVENT_CONTROL_CLICK` itself.

Runtime A/B testing confirmed that an otherwise normal `GLUETEXTBUTTON` remains stable until `FRAMEEVENT_CONTROL_CLICK` is registered, even when the registered trigger is completely empty. This matches a documented Warcraft frame-event cursor bug. The temporary diagnostic controls have been removed. Replacing the production controls would require a separately tested FDF-defined input layer and is deferred as visual polish.

After a real custom-button action, a short local delay allows Warcraft to complete its button-focus assignment before a hidden edit box receives and releases keyboard focus. This restores Enter chat, F9, control groups, and command hotkeys without changing synchronized game state. Pressing a button and deliberately releasing outside it produces no click action, so that unusual cancelled-click path cannot run the post-action focus release.

The successor may retain the legacy cards' illustrated artwork, title treatment, yellow border, and tracked hover highlight. Card backgrounds should follow the trainee's selected race rather than using the legacy black wallpaper: Human blue, Orc red, Night Elf green, and Undead purple. The original course-card DDS files are fully opaque, so the successor presentation should separate race panel, artwork, border, text, and hover into layers instead of tinting the complete legacy texture.

## Shared activity flow

Only one activity session may exist. The shared controller owns transitions and delegates activity-specific behavior through a common contract:

1. Validate the selected descriptor and scene before changing the current state.
2. Create a fresh session and ownership scope.
3. Call the activity’s `setup` and `start` operations.
4. Route shared commands such as Restart and Training Menu to the active activity/controller.
5. On reset or exit, invalidate callbacks, call semantic cleanup, dispose tracked resources, restore borrowed presentation state, and then show the correct menu.

The visible Restart or tutorial controls may be shared frames. Their meaning comes from the active activity’s capabilities. This avoids the legacy pattern where one callback contains a long exercise-ID switch while still giving every activity customizable behavior.

An activity descriptor may advertise capabilities such as restart, pause, back, continue, objectives, difficulty selection, or mode selection. The shared toolbar shows only the relevant controls. Normal exercises and guided tutorials can therefore use the same infrastructure without being forced into the same interface.

## Ownership and state

- Map-owned state includes bootstrap, the root menu, catalogues, Patch Notes, Credits, the registry, controller, and accepted foundation behavior.
- Session-owned state includes activity units, timers, triggers, effects, sounds, visibility modifiers, temporary frames, and result state.
- Borrowed state includes camera, selection, fog, music, player resources, alliances, interface visibility, and modified preplaced objects. Restoration is registered before mutation.
- Player 0 is the trainee. Additional hidden slots receive explicit technical roles when an activity needs them; they are not exposed as opponent lobby slots.

Session callbacks capture a session identity and do nothing after that session has been invalidated. Cleanup is safe after partial setup and repeated calls. A cleanup failure does not prevent the controller from attempting the remaining disposers.

## Persistence boundary

Disk persistence is outside this port. The legacy schema-10 profile, MMR, course results, continuation behavior, and analytics panel are not copied into the successor foundation. In particular, the successor does not call the legacy profile loader or writer and does not access its `JamiesTrainingGrounds\\profile.pld` path. A player’s existing v0.92 statistics therefore remain available to v0.92 and are neither imported nor erased by the successor.

The infrastructure may expose an in-memory result/statistics interface so later activities are not tied to storage. During this phase, it lasts only for the current map session. `Player Stats` remains a placeholder rather than presenting incomplete or misleading data. A later persistence design can connect to the same interface using a new versioned save path.

## Legacy disposition

| Legacy component | Disposition |
| --- | --- |
| Path/category selector and catalogue concept | Recreate for the new four-category structure |
| Course-card visual language and hover behavior | Reuse or adapt after asset-path and scaling verification |
| Numeric start/restart/cleanup dispatch chains | Replace with registry descriptors and activity instances |
| Shared Restart and Training Menu controls | Recreate as controller commands with activity capabilities |
| Custom Info button, hidden Quest button, custom F9 interception | Omit |
| Native Quest button and F9 | Preserve and regression-test |
| Legacy profile and Player Stats analytics | Defer; show placeholder only |
| Exercise-specific UI, score logic, units and scenarios | Leave for individual migration tasks |
| Global cross-exercise state | Replace with map services and per-session state |
| Persistent UI/event objects | Keep only when they are true map services; otherwise scope them to a session |

## Source and build structure

Implement the shared layer as editable Lua modules assembled deterministically into the map script. The first implementation slice should contain bootstrap, controller, scope, registry, menu shell, common toolbar, presentation restoration, and development diagnostics. Generated compiled Lua and editor custom text must come from the same source bundle.

The accepted alpha.5 archive remains a reference. New builds use new versioned output names and preserve the existing terrain, preview/minimap swap, loading screen, lobby, metadata, fog defaults, and native interface behavior.

## Implementation order

1. Make the build reproducible from a clean checkout and declare its dependencies.
2. Add bootstrap, registry, session controller, ownership scope, and presentation restoration.
3. Add the top-level menu, four catalogue shells, Patch Notes, Credits, and disabled Player Stats placeholder.
4. Add shared activity controls driven by advertised capabilities.
5. Connect a development-only diagnostic activity to verify lifecycle behavior; do not expose it as project content.
6. Test entry, reset, exit, re-entry, stale callbacks, focus release, native Quest/F9, fog restoration, and return to the originating catalogue.
7. Once the shared layer passes, select Body Blocking or Reflexes as a separate first migration task.

## Acceptance boundary

This infrastructure phase is complete when the player can navigate the root and category menus, read Patch Notes and Credits, see unavailable content and Player Stats clearly marked, and the controller can prove setup/reset/cleanup/exit through diagnostics without leaking state. No real exercise or tutorial is required for this acceptance point.
