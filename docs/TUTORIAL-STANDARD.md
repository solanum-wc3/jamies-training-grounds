# Tutorial implementation standard

Confirmed with the user on 10 October 2026. Applies to Camera, Unit Controls, Hotkey Setup, Economy & Workers and future tutorials.

## Shared implementation

`src/infrastructure/tutorial.lua` owns the shared runner entry boundary, narration clearing/rendering, toolbar construction, highlights, click dispatch, disabled styling, fixed camera movement, Menu/pause behavior and checkpoint reset dispatch. All four factories install this runner. Authored Continue boundaries, optional branches, scene actions and checkpoint restoration remain explicit tutorial hooks. The existing welcome arrow remains shared in `JTG.UI`: ten blinks, then visible until its narration is cleared.

Use 1.5 seconds for scripted camera moves, including initial entry. Do not jump the camera instantly or derive duration from distance.

Narration uses the existing Heading, Button, Input, Menu and Term colors. Gold/Yellow, Green and Red font tags use the same formatter. Tutorial buttons default to height 0.024; retain existing toolbar anchors and content-specific Topics/Optional choices.

## Progression and world actions

A narration step contains player-facing text, its explicit Continue/Next boundary, checkpoint and optional world action. Preserve the author's progression; additions do not create new checkpoints unless requested.

Continue advances the script. Back and Topics restore the scene to the selected checkpoint. Reconstruction may recreate the activity or use a tutorial's existing semantic checkpoint restoration. It must restore that checkpoint's actual demonstrations and permissions, not merely change the displayed text.

World actions run when entering a script step or explicitly restoring a checkpoint. Clearing narration, hiding/reopening menus, resuming, and rebuilding frames after load only affect presentation. They must never create buildings, restart gathering, repeat attacks, change ownership or reset the world.

Use `JTG.Tutorial.ScheduleStep` for delayed actions that belong to a single narration step. Persistent world events such as construction completion use scope/session guards and engine events instead. No callback may survive disposal and affect the replacement tutorial.

The runner assigns a new entry generation on every visit, including optional sections and completion. A step number alone is insufficient: A → B → A must reject A's old callbacks. Frame rebuilding and narration rendering do not enter steps. Use `RunStepExit` for declared departure actions when restoring a scene through earlier steps as well as on Continue.

Economy steps use stable semantic IDs and named actions in `design/tutorials/economy-script.json`. Their `restore` records declare the canonical scene for explicit Back/Topics navigation; they do not claim to record what the player actually completed. Restart state prefers a stable ID and accepts old numeric indices for compatibility. Do not reintroduce runtime thresholds using historical `sourceStop` values.

Economy Back/Topics restoration runs within the existing scene. Preserve living workers already harvesting or returning resources and their positions; restore only idle, missing or transformed workers. Ownership handoffs reissue their native gathering orders. Do not rebuild every worker merely to revisit narration.

## Demonstration versus practice

During demonstrations, units stay owned by a script-controlled faction and share vision with the player. During practice, transfer the designated units to the player; restore their faction afterward. Tutorials whose purpose is teaching unit controls remain practice where player interaction is requested. Economy is an explicit user-approved exception: the active race is always player-owned and fully controllable (10 October 2026). Player ownership always grants control; do not add a second command-blocking state.

Never intercept all issued-order events to suppress player input. Those events also contain native harvesting and construction orders. Do not repeatedly issue Stop, hold or harvest to enforce a demonstration.

Keep the player's selected native UI race and idle-worker artwork by default. A tutorial-specific override belongs to that tutorial's presentation scope, as Camera's Peon icon does; do not put it in the map-wide skin or change race preferences merely when ownership switches.

Change sight independently from ownership. Only the active demonstration faction shares vision. Preserve its chosen color and mirror its resource display when needed. Reissue work orders only on setup, explicit return to work or ownership handoff, not when text is cleared.

## Placement and lifecycle

Create the scene once at entry, with buildings before mobile units. Use `JTG.Tutorial.CreateSceneUnit` to initialize required melee behavior (Town Hall militia conversion) and correct native placement with a full position update. Do not move building gameplay coordinates independently of the visible model. Use exported placement coordinates and facing; correct native placement displacement where exact exported positions are required. Replace or temporarily hide conflicting foundation objects before creating equivalents, with scoped restoration.

Track engine-created structures, trained units, summons and transformations. Keep cleanup and borrowed-state restoration in scopes. Frame reconstruction after loading restores presentation without replaying world actions.

Economy's gathering guard observes building orders and native construction start/finish/cancel events. Never use an unwritten order-log flag as a task guard. Rejected/cancelled pending builds release the worker; active construction is protected during gathering restoration. Shared technology data belongs in `src/generated/melee-tech.lua`, not an exercise-specific catalogue.

Bat Splitting and Dodging use `src/infrastructure/training.lua` for countdowns and presentation visibility. Keep scoring and native-order behavior in their activity hooks. Opening menus hides status/result/feedback/toolbar; restoration must respect completed results and the separate gameplay pause. Countdowns are session-scoped and cannot start a finished exercise.

## Required checks

Check first entry, Continue, Back, Topics, Menu/Resume, pause, exit and save/load. Include assertions that presentation operations do not create units or issue orders, that delayed actions cannot affect another step, and that neutral demonstrations grant control only for practice. Native movement, construction and combat still require an in-game pass.
