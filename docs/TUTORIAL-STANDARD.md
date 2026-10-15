# Tutorial implementation standard

Confirmed with the user on 10 October 2026. Applies to Camera, Unit Controls, Hotkey Setup, Economy & Workers and future tutorials.

## Shared implementation

`src/infrastructure/tutorial.lua` owns the shared runner entry boundary, narration clearing/rendering, toolbar construction, highlights, click dispatch, disabled styling, fixed camera movement, Menu/pause behavior and checkpoint reset dispatch. All five tutorial factories, including the authored Heroes lesson, install this runner. Authored Continue boundaries, optional branches, scene actions and checkpoint restoration remain explicit tutorial hooks. The existing welcome arrow remains shared in `JTG.UI`: ten blinks, then visible until its narration is cleared.

Use 1.5 seconds for scripted camera moves, including initial entry. Do not jump the camera instantly or derive duration from distance.

Narration headings do not play an announcement sound. QuestNew is reserved for activation of an actual quest. Custom buttons follow the shared native menu-opening and normal-click cues documented in BUTTON-SOUNDS.md.

Narration uses the existing Heading, Button, Input, Menu and Term colors. Gold/Yellow, Green and Red font tags use the same formatter. Tutorial buttons default to height 0.024; retain existing toolbar anchors and content-specific Topics/Optional choices.

## Progression and world actions

A narration step contains player-facing text, its explicit Continue/Next boundary, checkpoint and optional world action. Preserve the author's progression; additions do not create new checkpoints unless requested.

Continue advances the script. Back and Topics restore the scene to the selected checkpoint. Reconstruction may recreate the activity or use a tutorial's existing semantic checkpoint restoration. It must restore that checkpoint's actual demonstrations and permissions, not merely change the displayed text.

World actions run when entering a script step or explicitly restoring a checkpoint. Clearing narration, hiding/reopening menus, resuming, and rebuilding frames after load only affect presentation. They must never create buildings, restart gathering, repeat attacks, change ownership or reset the world.

Use `JTG.Tutorial.ScheduleStep` for delayed actions that belong to a single narration visit. Its timers live in the visit's disposable scope. Native events owned by that visit also use `GuardStep` and the same scope. Persistent world events, such as normal worker construction completion, use scope/session guards and engine events instead. No callback may survive disposal and affect the replacement tutorial.

The runner assigns a new entry generation on every visit, including optional sections and completion. A step number alone is insufficient: A → B → A must reject A's old callbacks. Frame rebuilding and narration rendering do not enter steps. Use `RunStepExit` for authored `afterContinue` actions on forward progression and canonical replay. A runner `sceneExit` hook handles transient encounter cleanup on any departure, including Back, Topics and disposal. These are separate: a forward progression action must not accidentally grant control or spawn units during cleanup.

Economy steps use stable semantic IDs and named actions in `design/tutorials/economy-script.json`. Their `restore` records declare the canonical scene for explicit Back/Topics navigation; they do not claim to record what the player actually completed. Restart state prefers a stable ID and accepts old numeric indices for compatibility. Do not reintroduce runtime thresholds using historical `sourceStop` values.

Economy Back/Topics restoration runs within the existing scene. Preserve living workers already harvesting or returning resources and their positions; restore only idle, missing or transformed workers. Ownership handoffs reissue their native gathering orders. Do not rebuild every worker merely to revisit narration.

## Demonstration versus practice

During demonstrations, units stay owned by a script-controlled faction and share vision with the player. During practice, transfer the designated units to the player; restore their faction afterward. Tutorials whose purpose is teaching unit controls remain practice where player interaction is requested. Economy is an explicit user-approved exception: the active race is always player-owned and fully controllable (10 October 2026). Player ownership always grants control; do not add a second command-blocking state.

Never intercept all issued-order events to suppress player input. Those events also contain native harvesting and construction orders. Do not repeatedly issue Stop, hold or harvest to enforce a demonstration.

Keep the player's selected native UI race and idle-worker artwork by default. A tutorial-specific override belongs to that tutorial's presentation scope, as Camera's Peon icon does; do not put it in the map-wide skin or change race preferences merely when ownership switches.

Change sight independently from ownership. Only the active demonstration faction shares vision. Preserve its chosen color and mirror its resource display when needed. Reissue work orders only on setup, explicit return to work or ownership handoff, not when text is cleared.

## Placement and lifecycle

Create the scene once at entry, with buildings before mobile units. Use `JTG.Tutorial.CreateSceneUnit` for exact structure placement and required melee behavior (Town Hall militia conversion and War Mill lumber drop-off). Use `CreateMobileUnit` for workers and other mobile actors whose native walkable placement must be preserved. `EnsureMobileUnit` preserves a living actor or replaces a dead/missing one during explicit restoration. Do not move building gameplay coordinates independently of the visible model. Use exported coordinates and facing for structures; never force harvesting workers back into tree footprints after native creation has displaced them safely. Deliberately staged hero rows may use exact placement. Replace or temporarily hide conflicting foundation objects before creating equivalents, with scoped restoration.

Track engine-created structures, trained units, summons and transformations. Keep cleanup and borrowed-state restoration in scopes. Frame reconstruction after loading restores presentation without replaying world actions.

Economy's gathering guard observes building orders and native construction start/finish/cancel events. Never use an unwritten order-log flag as a task guard. Rejected/cancelled pending builds release the worker; active construction is protected during gathering restoration. Shared technology data belongs in `src/generated/melee-tech.lua`, not an exercise-specific catalogue.

Bat Splitting and Dodging use `src/infrastructure/training.lua` for countdowns and presentation visibility. Keep scoring and native-order behavior in their activity hooks. Opening menus hides status/result/feedback/toolbar; restoration must respect completed results and the separate gameplay pause. Countdowns are session-scoped and cannot start a finished exercise.

## Required checks

Topics, Optional and exercise Setups panels use `JTG.LayoutChoicePopup(panel, buttons, close)`. The shared `JTG.PopupLayout` owns placement, choice dimensions and a separate Close footer.

Create native actors through `JTG.CreateScopedUnit` (or the Tutorial scene wrappers). This captures terrain before structures spread blight. Terrain leases follow the scene/prompt scope and restore original tiles, variation and blight after the last overlapping scope releases them. Retire obsolete blight-spreading actors rather than merely hiding them. Opening a menu does not reset terrain.

Released terrain receives bounded next-tick and half-second post-removal checks for late native writes. Its baseline remains available during that interval; cell generations prevent old callbacks from affecting replacement scenes. These timers intentionally outlive a disposed scene, own no scene actors and destroy themselves after the final check.

Baseline retention is separate from blight-write ownership. A non-spreading replacement building must not block cleanup of departed blight; it only blocks repainting its live tile/variation. `CreateScopedUnit` tracks native blight abilities after creation, registering source release before unit tracking so reverse disposal removes the source first. Explicit `ScopePreserveTerrain` calls reserve mutation ownership by default; ordinary building capture uses a read-only baseline lease until source detection.

Check first entry, Continue, Back, Topics, Menu/Resume, pause, exit and save/load. Include assertions that presentation operations do not create units or issue orders, that delayed actions cannot affect another step, and that neutral demonstrations grant control only for practice. Native movement, construction and combat still require an in-game pass.

## Reference-first implementation

Before implementing a similar setup, identify its closest working reference and compare spawn order, coordinates, native orders, ownership, vision and interruption behavior. Camera’s imported gathering layout is the reference for Economy’s initial native worker setup. Use authored worker positions after buildings, explicit Harvest orders and preserve existing gathering during startup. Hall-centered placement is checkpoint recovery for idle/missing workers, not initial gathering placement.

When a mechanic fails, inspect deviations from the working reference before adding retries or state resets. Record what native exports prove separately from hypotheses. Accepted order returns and mock tests do not prove movement or effect completion. Keep diagnostic samples bounded and scoped.

## Scene transition and reset contract (14 October 2026)

`Transition` owns the entry boundary. It cancels the previous step scope and runs its scene departure hook before any restoration. A nested `showStep` shares that boundary, rather than creating a second visit. `RestoreAt` establishes the target index before invoking canonical scene restoration, then enters its narration. Presentation rebuilding never calls these methods.

Every tutorial exposes `restoreCheckpoint(index)` and `captureResetState()`. `ResetScene(activity, index)` delegates to the tutorial's existing canonical restorer; omitting the index restores its current main checkpoint. Optional branches capture their main return checkpoint for a full activity restart. Native save/load preserves the live scene and timers; it rebuilds frames without replaying setup. Explicit reset reconstructs canonical instructional state, not an arbitrary snapshot of every player action.

All main steps have explicit, validated, stable IDs. Camera, Unit Controls and Hotkey Setup use assigned IDs such as `camera.014` and `controls.027`; these are identities, not calculated runtime indices. Never renumber existing IDs when inserting/reordering narration. Restart prefers `stepId`, with numeric `step` retained for old restart records. The editable work files remain author-owned and are not overwritten by consolidation.

`WatchProgress(session, activity, condition, onSatisfied, interval)` is the common live-condition observer for future position/objective checks. It runs only while the lesson is visible and unpaused, fires once, and is cancelled on any scene transition or disposal. The success callback explicitly chooses the authored next action; the watcher never advances narration or resets a scene by itself. Query the activity's current named actors rather than closing over handles that restoration can replace.

Economy uses `RestoreWorkerOrders` after ownership, resources and vision are settled. Its bounded retries only resume live, visible, idle workers. Hidden miners finish their cycle first; active player orders are protected on retries and repeated same-race views. Construction protection and resource-target choice remain in the Economy adapter. A real ownership change can explicitly reissue visible workers. Normal gathering and completed construction are not tied to narration lifetime.

Camera notification production is a visit-owned demonstration: its trigger, trained actors, partial Burrow and borrowed weapon research are tracked in the step scope. Leaving cancels remaining demonstration queues and disables WarpTen. Returning reconstructs the demonstration. Its temporary resource grant remains session-owned. Notification attackers and idle-worker scenes remain explicitly restored on their selected steps.

Unit Controls restoration replaces dead or missing base actors, rebuilds group references, and resets health, mana, buffs and position. Native Spirit Wolves are registered by their summoning event and caster visit, so quick departure cannot bypass tracking. Late summons from retired casters are removed. Optional Back also restores its branch scene before displaying the chosen narration.

Required acceptance: rapid Continue through production/attacks/idle-worker demonstrations; repeated Back/Topics around those events; live and dead actor restoration; optional return; Menu/Resume; pause; save/load during a demonstration; and exit without leaving the current menu page. Mock tests validate orchestration; native pathing, production cancellation, harvesting and visual behavior still require Warcraft testing.

Named `SceneScope` containers own encounters that can span several narration lines. `ClearScene` disposes actors and movement timers together; `SceneTimer` rejects callbacks from replaced containers. They are cleaned up once with the activity, without accumulating a parent cleanup callback per visit. Camera attackers and Unit Controls enemies/wolves use these containers.

Unit Controls declares `sceneRoot` metadata on its canonical setup steps and uses `ReplaySetup` for main and optional restoration. Replay is permitted only inside an explicit transition, applies the nearest relevant setup root and preceding authored departure actions, and leaves the target step to run once through normal entry. A scene root is not a new Topics checkpoint.

Terminal narration is marked complete consistently. Back from a terminal page selects the preceding narration rather than getting stuck redisplaying the ending.

A malformed future condition check stops its watcher and reports one diagnostic instead of repeatedly erroring or advancing the lesson. Native-menu suspension also blocks condition checks.

Transient Slow casters also use a named scene scope and are cancelled before unit restoration. Combat replay sets its canonical autocast policy before replaying setup, and restored lesson units have ability cooldowns reset alongside health, mana and buffs.

Camera production revisits ensure sufficient demonstration resources and temporarily reset weapon research so the notification remains reproducible, then restore the prior research level when the visit ends.


## Follow-up after alpha47

Narration can gain a new Continue stop without renumbering existing stable IDs. Camera adds `camera.zoom-advice`; Unit Controls adds `controls.add-alternative`. Positional group/topic references and lesson boundaries must move with inserted array entries; tests should resolve their target by stable ID rather than copying array positions.

An ownership handoff now performs one delayed refresh of a visible worker's native gathering/return order. This handles an accepted-looking stale harvest order left by `SetUnitOwner`. The immediate handoff and bounded idle retries remain. Hidden miners and subsequent non-gathering player orders are protected. This is an engine-timing fix requiring first-visit Orc mining verification in Warcraft; mocked orders do not establish actual gold delivery.


## Authoring stable navigation

Give every narration stop a permanent ID. Use `Tutorial.TopicSteps(steps, topics)` with `stepId` in each authored topic and `Tutorial.StepIndex(steps, id)` for named scene/quest boundaries. These strict lookups fail on an unknown ID. `ResolveStep` still accepts numeric legacy restart records, but new authored links must not copy array positions. `InstallRunner` rejects invalid narration-group starts. New narration stops need their own ID; do not rename the existing ones.

## Exercise presentation contract

Hotkey and Reflex register presentation roots, frame lists, refresh methods, result rendering and all disposable frame aliases through `Training.InstallPresentation`. Every hidden root/list must also appear in the rebuild references. A presentation rebuild clears aliases, recreates frames and draws current state; it does not start a round, modify actor counts, reset a clock or change result identity. Hotkey native reselection remains a deliberate resume hook and is skipped on completed results. The shared visibility helper continues to support existing exercise-specific hooks.
