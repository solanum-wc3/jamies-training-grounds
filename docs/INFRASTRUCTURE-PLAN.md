# Modular infrastructure plan

Status: shared infrastructure implemented; first legacy migration candidate built, 2026-09-25. `v0.0.3-alpha.1` ports Body Blocking and awaits runtime and World Editor checks.

## Boundaries and dependency direction

Keep one composition root and explicit dependencies. Activities depend on a small session context and shared services; shared services must not import activities. The menu lists descriptors and submits commands; it never creates exercise units or implements scoring.

| Proposed location | Responsibility | Lifetime / owner |
| --- | --- | --- |
| `src/bootstrap.lua` | Compose services, restore terrain minimap, establish defaults, register activities, open menu once | Map |
| `src/core/controller.lua` | Serialize selection, reset, exit and failure recovery; own current session | Map |
| `src/core/scope.lua` | Track disposables, cancel callbacks, dispose in reverse acquisition order | Session or checkpoint |
| `src/core/registry.lua` | Stable activity IDs, descriptors and factories; reject duplicate IDs | Map |
| `src/world/scenes.lua` | Named bounds, spawn points and scene requirements | Static descriptions; controller grants use |
| `src/presentation/` | Camera, selection, fog, music and UI adapters with explicit restore operations | Map services; session leases |
| `src/ui/` | Menu, instruction panel and native Quest integration; focus handling | Map shell plus session views |
| `src/tutorial/` | Player-paced steps and checkpoint transitions | Tutorial session |
| `src/profile/` | Versioned in-memory profile and a replaceable storage adapter | Map; deferred disk implementation |
| `src/activities/<id>/` | Descriptor, activity implementation, lesson content and owned assets | Fresh instance per run |
| `src/dev/` | Opt-in inspection harness and diagnostics | Development builds only |

The first candidate groups these responsibilities into five small files under `src/infrastructure/`: `core.lua`, `catalog.lua`, `ui.lua`, `diagnostics.lua`, and `bootstrap.lua`. Further separation waits for concrete activity needs.

## Activity contract

Proposed descriptor fields: stable `id`, display title, activity kind, scene ID, visibility policy, and factory. Resolve descriptors and validate scene requirements before altering the current session.

The factory returns an activity instance with `setup(context)`, `start()`, `cleanup(reason)` and optional checkpoint support. The public controller exposes select/start, reset and exit. Reset initially means dispose the complete run and create a fresh instance; this implements the shared reset behavior without requiring every activity to maintain an error-prone in-place reset method. A specialized reset hook needs a demonstrated requirement and the same postconditions.

`context` provides the trainee, scene descriptor, session ID, ownership scope, presentation services, tutorial view and a result sink. Activities must not call other activities or overwrite controller state. World objects are created only after the session owns a scope. Raw handles returned by adapters must be registered immediately.

Exit belongs to the controller: invalidate the session, perform cleanup, restore shared state, and show the menu. Cleanup is safe after partial setup and repeat calls. Activity-specific cleanup may release semantic state, but generic disposal still runs if that hook fails.

## State transitions and failure behavior

| State / command | Required behavior |
| --- | --- |
| `idle` + select | Validate descriptor; allocate session/scope; enter `setting_up`; run setup then start; enter `running` |
| `running` + reset | Enter `stopping`; invalidate callbacks; cleanup/dispose/restore; create a fresh run of the same descriptor |
| `running` + select another | Validate target first; dispose current run; then set up target. Never overlap world ownership |
| Active session + exit | Enter `stopping`; invalidate, cleanup, dispose, restore; return to `idle` and menu |
| Setup/start/callback failure | Record activity/session and error; follow the same teardown; show a recoverable error only if restoration succeeds |
| Repeated input during setup/stop | Reject while busy; disable controls until the transition finishes; do not recursively enter lifecycle code |
| Teardown cannot restore a safe world | Attempt remaining disposers, retain diagnostics, enter `faulted`; block another activity and offer normal map exit |

Callbacks capture a session generation and return immediately when stale. Invalidate before destroying resources, including on reset. Tutorial pause is progression state inside `running`, not permission to leave resources unmanaged. Define which timers/input pause for each activity before exposing Pause.

## Ownership and restoration

- Map-owned: bootstrap, registry, controller, permanent credits/menu shell, and untouched terrain/preplaced objects. Activity cleanup must never broadly enumerate and delete these.
- Session-owned: spawned units/items, temporary groups, triggers, timers, effects, sounds, visibility modifiers and custom views. A scope records each resource with its disposer and attempts every disposer even if one fails.
- Borrowed state: camera, selection, control bindings, player resources, interface visibility, music and any deliberately modified preplaced object. Register a restoration action before mutation, or prohibit the mutation until restoration is implemented.
- Checkpoint-owned: temporary objects and callbacks for a tutorial step. Leaving the checkpoint disposes its child scope while retaining session progress.

Prefer immutable scene data and explicit map defaults over trying to infer all prior engine state. Any engine state without a proven restore operation needs an experiment before it becomes part of the contract. Normal fog settings and removal of reveal modifiers alone must not be assumed to erase explored terrain; test a supported remasking strategy before promising a fresh camera lesson after arena use.

Keep gameplay changes and lifecycle decisions on a consistent execution path. Restrict local-player branches to verified presentation operations. Audit frame/input callbacks and any future synchronization needs against the actual supported game build before implementing them; the current scope is one trainee, not multiplayer support.

## Tutorial and persistence scope

The first beginner module remains camera controls on preserved realistic terrain with normal fog and unexplored areas. The archived design resolves an important progression question: this is a player-paced guided sandbox, not an input exam. Each page explains one mechanic, leaves the player unlimited time to practise, and advances only when Continue is pressed. Automatic checks are limited to the tutorial’s own state: finishing a scripted camera move, cancelling old timers, restoring scenes, and preventing stale callbacks. Do not require audio or player-input detection to advance.

Write its lesson specification before implementation: starting camera and Orc scene, concise on-screen instruction, persistent Try it prompt, Continue/Back/Pause behavior, Objectives checkpoint navigation, Tutorial Notes/Quest references, reset, exit, and visibility restoration. The archived draft’s 43 audio lines and roughly 351 seconds of fallback timing make full voice delivery optional; essential instruction must work as text, with audio treated as a later enhancement rather than a lifecycle dependency.

The camera scene should include three Orc bases (Fortress, Stronghold and Great Hall), a separated army, and the ambient notification demonstration described in the archived draft. The supplied reference screenshots are visual targets rather than coordinate specifications: preserve realistic Lordaeron Summer surroundings, irregular grass/earth clearings, tree lines, paths, cliffs or water landmarks, readable building spacing, and distinct army clusters. The army should be separated into visually legible groups with enough open ground for camera movement and selection practice. These are activity-owned scenario resources. Native notification order and exact hotkeys remain client behaviors to verify; the lesson should teach command names and defaults rather than pretending the map can read a player’s bindings.

The supplied UI references establish the layout contract. Keep the lower native console unobstructed: minimap and formation controls at lower left, selected-unit information in the center, inventory and command card at lower right. Place the custom toolbar in the top chrome alongside the native Menu/Allies/Log controls; keep Training Menu beside that toolbar; put Restart and any exercise controls in the upper-right rail; and anchor Objectives beneath its own button rather than over the world or console. The annotated reference also marks an upper-world start area and finish area, which should be represented as activity markers or scene data rather than hard-coded UI. Preserve native Quest and F9 access. Tutorial Notes may use Quest for durable text and a custom panel for screenshots or richer layout. Every custom-frame action must release keyboard focus so F1–F10, F9, command groups and native controls remain testable.

The compact alternate reference reinforces that exercise overlays must scale within the dependable 4:3 interface region and remain readable over a dark or fogged arena. Coordinate labels and colored boxes in both images are design annotations, not assets or final text. Validate the toolbar, Objectives panel, restart controls and instructional markers at the supported widescreen and 4:3 layouts before treating their positions as stable.

Normal exercises enter through a readable explanation window describing purpose, operation and evaluation, optionally offering modes such as Body Blocking’s Training/Custom, then a short orientation countdown. Tutorial activities may use their own page sequence but still enter through the same controller and clearly separate explanation, practice and evaluation.

The camera tutorial includes two imported settings references: the Gameplay → Game Behavior screenshot for “Snap Camera to Worker on Double Click” and the Camera Settings screenshot showing Improved Zoom, Default Camera Distance 1900, and Max Camera Distance 2400. The lesson should create durable Quest/Tutorial Notes text that points to these references. Because native Quest descriptions are text-oriented and do not normally embed arbitrary imported images, the images should be displayed through the custom Tutorial Notes panel, with the native Quest entry serving as the durable written reference unless a client test proves inline image support.

Text presentation follows the supplied campaign reference: durable Quest entries hold organized objectives and settings guidance; the native Message Log retains recent narration; and short colored notifications announce concepts, prompts, or scripted activity. These channels have independent lifetimes. Clearing or expiring a notification must not advance a lesson, and Continue remains the authoritative transition from explanation to practice or the next page.

The supplied draft is now the camera tutorial content master: five sections, ten named checkpoints, 43 narration/audio slots, and explicit player-paced practice pauses. Its runtime representation should be data-driven rather than a chain of bespoke trigger actions. Each narration record should contain stable ID, text, optional audio, fallback duration, progression mode, scene transition, trigger/scripted activity, tutorial-note entry, and cleanup requirements. `Wait for Continue` creates a persistent practice state; it must not be implemented as a timer that merely happens to wait.

Before implementation, verify client-dependent claims marked by the draft or implied by it: default camera distance versus the tutorial’s scripted 1650-unit scene distance, F5 reset behavior, Insert/Delete rotation, Backspace ordering, Space notification behavior, tilde/idle-worker behavior, F1–F3 hero binding, control-group camera centering, and Ctrl+C lock-on. The draft should remain usable if these defaults differ: show command names first, defaults second, and keep Continue available as the fallback.

Separate lesson completion from profile storage. Start with in-memory completion and preferences behind a small interface. The eventual saved envelope should include a schema version and stable activity IDs. The [legacy analysis](LEGACY-ANALYSIS.md) identifies a schema-10 integer format, older-schema readers and preload-based storage. Codec, storage transport and import policy still need dedicated design and fixtures. Use a separate successor save path; unsupported or corrupt data should return an explicit result without overwriting the original.

## Build and editor integration

First make the existing build reproducible from this checkout: declare locked Node dependencies, document compatible Node/Python versions and Pillow installation, and state preparation/minimap/packaging order. The current `work/mpq-tool` lookup is a portability gap, not a reason to change the accepted archive.

Use a deterministic build-time Lua bundle with explicit module order or a small generated loader. Do not assume filesystem `require` is available inside the map. Keep editable module sources authoritative; generate matching compiled Lua and editor custom text from the same bundle. Validate no missing or duplicate modules and exactly one bootstrap registration. Confirm the chosen approach survives editor open/save and repackaging before expanding it.

Retain foundation preservation checks, preview/minimap separation, marker removal, metadata and Lua/archive validation. Add source and dependency fingerprints to reports and write new versions under `outputs/`. Preserve `reference/foundation/` unchanged. Specify editor-save ingestion separately: the present builder starts from the original terrain archive and is not a general importer of arbitrary editor changes.

## Sequenced work and acceptance gates

| Phase | Deliverable | Gate before advancing |
| --- | --- | --- |
| 0 — legacy evidence | Initial archive/hash verification, dispatcher/Reflexes trace and persistence findings recorded; finish asset/terrain dependencies and runtime comparison | Evidence links distinguish source behavior, runtime observations, inference and unresolved questions |
| 1 — build preparation (can run alongside phase 0) | Declared dependencies, deterministic assembly design, documented clean-checkout build | Build passes existing checks; accepted reference hashes unchanged; editor-save/repackage workflow verified |
| 2 — shared infrastructure | Controller, scope, registry, scene descriptor, four-category menu, Patch Notes, Credits, disabled Player Stats placeholder, shared controls and development-only diagnostic activity | Setup/reset/exit/re-entry and failure injection pass; stale callbacks do nothing; category navigation and return routing work; native Quest/F-keys remain usable |
| 3 — first legacy migration | Port one selected legacy exercise, initially Body Blocking or Reflexes, with isolated rules and assets | Compare setup, rules, score, failure, retry and exit against v0.92; record intentional differences |
| 4 — camera tutorial | Implement the player-paced lesson, realistic scene, text progression, checkpoint behavior, and fog/camera restoration on the proven infrastructure | Player can practise indefinitely, use Continue/Back/Objectives, reset and exit at every step; arena-to-tutorial transition preserves intended exploration behavior |
| 5 — persistence and expansion | Versioned storage after legacy findings; additional activities as independent modules | Corrupt/unknown/older profile fixtures handled without data loss; cross-activity regression passes |

Phase 0 is required for legacy migration, not for writing independent successor infrastructure. Do not migrate the whole inherited UI, implement all planned lessons, redesign terrain, or promise runtime race-console switching as prerequisites for the first slice. Race choice remains map-wide lobby presentation; activities may require units and music for a race, while full native console reskinning remains unproven.

## Verification plan

Use a fake resource adapter for controller/scope tests: partial setup failure, disposer failure, double disposal, stale callbacks after reset, repeated input, and transition ordering. Check that borrowed map objects are never disposed and no new session starts before restoration completes. These test lifecycle guarantees, not engine behavior.

During the shared-infrastructure phase, run repeated setup/reset/exit cycles with the development-only diagnostic activity. Compare tracked resources to their idle baseline; also observe input focus, native UI, fog/exploration, selection, camera, sound and delayed callbacks. Resource counters alone cannot prove native handles were released. Inject a failure during setup and verify either recovery to the menu or the defined faulted state. Cross-activity tests begin only after the first real legacy exercise is migrated; camera-tutorial transition tests belong to its later implementation phase.

For every playable candidate, retain the foundation checklist and test editor open/save followed by packaging. Record game/editor version, graphics mode, tested artifact hash and manual results. Only actual runtime acceptance should create a new tested milestone; a documentation change does not supersede alpha.5.
