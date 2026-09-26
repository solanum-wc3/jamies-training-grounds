# Legacy-map architecture analysis

Status: initial source analysis, 2026-09-24. Baseline: accepted `v0.0.1-alpha.5`. Runtime comparison remains pending.

## Evidence boundary

The user supplied the authoritative legacy map and an existing local extraction. Neither the legacy gameplay source nor its complete archive is tracked in this repository.

Read-only archive inspection with `@jamiephan/stormlib` 0.2.1 established:

- Archive: 2,248,543 bytes; SHA-256 `e789410d5dcae58413bcfaa8919905248fa188ea13e01f6cfc7bed47a69681c8`.
- `war3map.lua`: 956,388 bytes; SHA-256 `aa371b9303baf554c615a620267ec960e05c2500c11eb28de63572f1fb9f34c0`.
- The existing extracted Lua matches the authoritative archive entry byte for byte. Other extracted entries have not been compared.
- Enumeration returned 69 entries, including compiled Lua, editor trigger/custom-text files, terrain, units, strings, object data and imports. Some names are synthetic `File000000…` entries; this is not a complete resolved asset manifest.
- The archive hash was unchanged after inspection. No game launch, editor save, or profile read/write was performed. Actual game/editor version and runtime behavior remain unverified in this analysis.

All line references below refer to the verified `war3map.lua` above. Source behavior is distinguished from proposed successor behavior; no observed runtime equivalence is claimed.

## Verified successor seams

| Evidence | Finding | Infrastructure implication |
| --- | --- | --- |
| `docs/FOUNDATION-ACCEPTANCE.md` and foundation validation JSON | One selectable-race trainee, native UI and Quest access, normal fog, preserved terrain outside the northeast district | Retain these as regression gates for every infrastructure build |
| `src/foundation-test.lua`: `FoundationStart` | Fog defaults, minimap restoration, quests, units, and chat dispatch are initialized together | Separate permanent bootstrap responsibilities from disposable inspection activity |
| `src/foundation-test.lua`: `foundationTestUnits`, visit functions | Test units use a file-local registry; movement is separated from local camera and selection changes | Replace ad hoc ownership with an activity session and scoped resources |
| `src/foundation-test.lua`: `InitTrig_Foundation_Test` | A deferred one-shot timer starts the harness and destroys itself | Preserve deliberate initialization order; prevent duplicate bootstrap |
| `src/foundation-test.lua` | No activity teardown or transition controller; quests and command trigger last for the map session | Do not reuse this harness as production lifecycle infrastructure |
| `tools/build-foundation.cjs`: script and trigger assembly | The same harness is inserted into compiled Lua and editor custom text | A future module bundle must remain consistent in both representations |
| `tools/build-foundation.cjs`: dependency loading | StormLib and luaparse are loaded through ignored `work/mpq-tool/package.json` | A fresh checkout lacks a declared, locked dependency setup |
| `tools/foundation-minimap.py` | Minimap generation consumes preparation files and Pillow | Document the complete staged build and pin its required environment |
| Build assertions and stored validation report | Terrain/pathing preservation, archive readback, Lua syntax, and preview checks already exist | Extend these checks; do not replace them with syntax-only validation |

The stored validation report records prior acceptance, not a new build run. Its absolute output path is historical provenance, not a dependency the new build should require.

## Initial legacy findings

| Area and source evidence | Verified source behavior | Proposed disposition |
| --- | --- | --- |
| `main` (21775), `Trig_Melee_Initialization_Actions` (21718), `HumanTraining_Begin` (21694) | Generated setup loads `TrainingCourseUI.toc`, restores `CUSTOM_MINIMAP.blp`, initializes globals/triggers, then starts training after a 0.50-second timer. Training initializes the profile, clears an upper field, starts a recurring counter timer, and opens the path selector | Rewrite composition root; retain only necessary initialization ordering |
| `Training_OnLevelDialogClick` (20545), `Training_StartLevelByIndex` (20594) | Frame handles map to numeric course IDs 1–17; clicks record a profile start before dispatching to course functions | Stable descriptor registry; menu command boundary; preserve an explicit legacy-ID mapping |
| `SpawnTrainer_OnRestartClick` (6295), `Training_ReturnToLevelSelector` (21348) | Separate hard-coded dispatch chains select restart and cleanup routines using `udg_trainingActiveLevel`; return also clears terrain/fog and resets shared opening state | Replace with one controller contract, rather than maintaining three lists |
| `Training_ShowMenuMode` (20879), `Training_OnBasicsPlaceholderClick` (20933) | Basics and advanced catalogues share frames; Basics entries show planned-curriculum messages | Camera tutorial is new content; do not assume an existing tutorial engine |
| Existing architecture overview and archived camera draft | Basics card 1 is `Camera & Selection` (visual card 21); working exercise IDs 1–17 are separate from card indices. The placeholder handler’s label arithmetic is not a safe route for the new card | Give the camera tutorial a stable new activity ID (proposed 18), preserve card-to-activity mapping in data, and return to the originating Basics catalogue on exit |
| `Training_PlayButtonClickSound` (1748) | Click handler resets the clicked frame's enabled state in a local-player branch to release focus, and plays a one-shot sound | Isolate and re-test the focus workaround behind the UI adapter |
| `Training_InfoInitialize` (21520), `Training_InfoOnF9` (21513) | Legacy code disables/hides the native Quest button, overlays an Info button and supplies an F9 handler | Do not port this replacement: alpha.5 explicitly accepts the native Quest window |
| Runtime test recorded in the conversation archive | A disposable build restored the native Quest button; clicking it and pressing F9 worked in the tested foundation. Earlier F-key failures were a separate focus/input observation, not evidence that Quest itself crashes | Keep native Quest and F9 in the successor; treat focus release as a testable shared UI requirement |
| `Training_DestroyLevelFog` (15020), `Training_HideGoblinUI` (15044) | Shared functions own multiple global fog handles and hide UI belonging to other courses | Replace cross-course knowledge with scoped visibility and views |
| `Advanced_BeginRun` (19662 and 20027) | Later definition wraps a captured earlier implementation to restore a deadline | Preserve source order during analysis; naïve function splitting could change behavior |

The header still describes eleven levels, but the actual start dispatcher handles seventeen course IDs. Use executable dispatch and profile definitions as the inventory, not header prose.

## Representative exercise: Reflexes (legacy ID 11)

Static trace: catalogue click → `Training_StartLevelByIndex(11)` → `Training_StartReflexesLevel` (16616) → `Reflexes_CreateScenario` (16555) → selection/timer events → `Reflexes_Finish` (16504). Restart routes through `Reflexes_Restart` (16599); return routes through `Training_CleanupReflexesLevel` (21328) and `Reflexes_Cleanup` (16606).

Setup creates twelve invulnerable Peons in a fixed 4×3 grid, sets acquisition/pathing behavior, starts a 0.025-second tick timer and a long-duration elapsed-time clock, and lazily registers a selection trigger. Entry also applies shared natural-terrain/fog helpers, changes time of day, sets camera distance, and configures shared restart controls. These are dependencies to replace, not reasons to copy the fixed coordinates.

Rules from `Reflexes_ApplyDifficulty`, `Reflexes_NextTarget`, `Reflexes_Resolve` and `Reflexes_Finish` (16422–16543):

- Thirty targets, starting focus 80; hit restores 4 up to 100, timeout costs 20, zero focus ends the run. Selecting an incorrect unit is ignored by `Reflexes_OnSelection`, rather than counted as a miss.
- Target scale is `max(0.67, 1.25 - (attempt - 1) * 0.020)`; response window is `max(0.57, 1.15 - (attempt - 1) * 0.020)` seconds. Consecutive target indices cannot match.
- Reaction time accumulates in tick increments. Score rounds `0.55 * accuracy + 0.30 * speedScore + 0.15 * remainingFocus`, with speed score clamped to 0–100 from `(1.15 - averageHitSeconds) / 0.60 * 100`.
- Completion is guarded against duplicate finishes and calls `Profile_RecordResult(11, won, elapsedMs, score)`. Winning requires remaining focus and all thirty attempts. Rank is F at zero focus, otherwise S/A/B/C at 90/80/70/60, D below.

| Resource / state | Legacy lifetime | Successor requirement |
| --- | --- | --- |
| Twelve units and current target effect | Removed by scenario recreation and cleanup (`Reflexes_RemoveUnits`, 16545; `Reflexes_ClearTarget`, 16256) | Session-owned; use scene-relative spawn positions |
| Tick timer and elapsed clock | Created lazily, restarted for another run, paused on finish/cleanup | Session disposal or an explicitly map-owned pool; no ambiguous paused handles |
| Selection trigger | Created once and retained; callback checks active course and reflex flag | Scoped trigger and stale-session guard |
| HUD/result frames and event handlers | Lazily constructed, hidden on cleanup | Explicit view ownership; verify focus after Play Again |
| Camera, time of day, shared terrain and fog | Mutated through entry/shared helpers; Reflexes cleanup does not restore all of them itself | Register restoration with controller/presentation services |
| Sound and profile side effects | One-shot hit sound; result function updates shared profile | Audio adapter plus result sink independent of storage |

Reflexes is a **provisional early legacy migration candidate**: its rules and grid are bounded, but terrain helpers, full frame creation and runtime re-entry still need inspection. Body Blocking is the other leading candidate because it is important, already works reasonably well, and exercises the shared explanation/format-selection flow. Reuse verified exercise rules; rewrite lifecycle and presentation integration. The camera tutorial remains a separate later implementation step after the infrastructure and one legacy exercise have proven the shared framework.

## Persistence findings

Globals at 870–872 set 17 courses, schema **10**, and `JamiesTrainingGrounds\\profile.pld`. `Profile_FileRead` (1134) invokes `Preloader`, uses the `Amls` ability icon as a string transport, then restores the original icon. `Profile_FileWrite` (1150) writes generated preload code in 240-character chunks using escaping helpers. This is engine-specific transport; isolate it from any future codec.

`Profile_Serialize` (1180) writes comma-separated integers: schema and aggregate progress/MMR, thirteen statistics per course, 112 body-blocking runner ratings, three preferences, 160 advanced-stage values, and a checksum. Schema 10 has 503 values including the checksum. `Profile_ComputeChecksum` (1169) starts at 173 and adds each value multiplied by `(index * 37 + 11)`, modulo 1000003. Treat this as an integrity check, not authentication.

`Profile_Deserialize` (1262) accepts schema/count pairs 1/45, 2/53, 3/57, 4/58, 5/166, 6/278, 7/352, 8/291, 9/423 and 10/503. It checks the checksum, reads fields conditionally, and normalizes selected ranges. Further compatibility tests must verify each older layout; these branches alone do not establish successful migration.

`Profile_Initialize` (1727) resets defaults, attempts a read, records load status, marks the profile initialized, increments sessions and calls `Profile_Save` (1433) even after a failed deserialize. **Source-level risk:** an invalid existing profile can be replaced by defaults during initialization. The successor should distinguish absent, invalid and unsupported data and avoid writing over failed reads. Use a separate successor save path unless an explicit, backed-up migration is designed. Never run the inherited initializer against the user's existing profile during analysis.

## Remaining legacy investigation register

The initial traces above cover the central dispatcher, one exercise and the persistence format. The following register tracks the deeper evidence still needed, especially runtime verification. “Target” is a proposed successor boundary.

| Area | Evidence to collect | Migration question / target |
| --- | --- | --- |
| Initialization | Generated entry points, trigger init order, global tables, library dependencies | Which shared systems must initialize before the menu? Bootstrap and explicit composition |
| Menu and navigation | Frame creation, callbacks, activity IDs, navigation state, keyboard focus behavior | Can selection be separated from exercise logic? Menu emits controller commands |
| Exercise lifecycle | One complete exercise trace: selection, setup, start, restart, exit, re-entry | What state survives accidentally? Session controller and ownership scope |
| Tutorial presentation | Text progression, Continue/Back/Pause, objectives, camera locks, optional audio | Separate lesson content, progression, and presentation; define checkpoint behavior |
| World layout | Regions, coordinates, preplaced handles, object IDs, shared units, pathing assumptions | Reusable arena, dedicated scene, or terrain-dependent hold? Scene descriptors |
| Input and event handling | Key/chat/frame/gameplay registrations, timer callbacks, trigger enable/disable paths | What can still run after exit? Scoped callbacks with session identity checks |
| Camera, visibility, selection, music | Mutation sites and restoration paths, local-player branches | What is global versus activity-owned? Presentation adapters and explicit defaults |
| Persistence | Read/write entry points, encoding, keys, versioning, defaults, example saved data | Can old data be decoded safely? Versioned profile boundary; defer compatibility decision |
| Exercise results | Scoring formulas, time sources, completion/failure rules, restart effects | Preserve verified behavior in isolated result logic |
| Imported resources | Archive inventory, UI definitions, models, textures, sounds and dependencies | Reuse only referenced assets with provenance and retained credits |

## Extraction and analysis procedure

1. Locate the exact v0.92 reference. Record its original filename, byte size, SHA-256, provenance, and observed game/editor version. Preserve the archive unchanged; never resave the reference in World Editor.
2. Extract to ignored `work/legacy-v0.92/` using read-only archive access. Record the extractor and version. Enumerate actual archive entries; do not assume a complete listfile or script language.
3. Inspect compiled Lua or JASS, editor trigger/custom-text files, string table, map metadata, regions/cameras, object data and imports where present. Record missing or unreadable entries as limitations.
4. Trace initialization and menu dispatch before exercises. Build an evidence table with archive-relative file, function/trigger name, extracted line range, callers, writes, allocations, cleanup and local/synchronized context. Treat generated globals and dynamic dispatch explicitly.
5. Trace one representative mechanical exercise plus shared tutorial navigation if present. Inventory every unit, group, timer, trigger, effect, sound, frame, visibility modifier and mutable player setting it touches. Classify each as map-owned, session-owned, borrowed, or unresolved.
6. Observe the same paths in a disposable runtime copy: first entry, retry, exit during a callback, re-entry, and switching activities. Compare source interpretation against observed behavior.
7. Commit concise findings and evidence references here, keeping bulk extraction ignored. Classify each component as reuse, wrap, rewrite, or defer only when its dependencies and behavior are known.

For persistence, use supplied or deliberately generated test profiles. Preserve existing saves unchanged. Unknown formats and invalid payloads must not be silently rewritten during investigation.

## Next evidence required

Next inspect resolved UI imports, the shared terrain helpers used by Reflexes, and its complete frame/event ownership. Then compare the static trace with a disposable runtime copy under an isolated test profile. Build preparation and controller/scope implementation can proceed from the current findings; no legacy archive change is needed.
