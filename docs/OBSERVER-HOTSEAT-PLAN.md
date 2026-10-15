# Observer and control-handoff plan

Saved 15 October 2026. Status: future work, not implemented. The user approved retaining this analysis for a later discussion; implementation is not starting now. Revisit the approach with the user under the workflow in `AGENTS.md` before coding.

## Intended experience

- Several people join the lobby before the map starts.
- One human is the active player; the others watch the same training session.
- Spectators should see the relevant world, camera, briefing/narration, prompts and score presentation without controlling the exercise.
- The active role can pass to another participant between exercises. Mid-exercise handoff is not required.
- Joining a map already in progress is outside this proposal.

## Existing code and references

The alpha49 inspection found `Player(0)` assumptions across activities, shared UI, keyboard registrations, camera and sound handling. Other slots already serve scripted opponents/factions. Adding human slots must not overwrite those roles.

The v0.2.0 implementation reserves player 6 for controllable hostile Target Dummies and configures its one-way shared control before play. Preserve that role and permission when planning participant slots; runtime permission toggles were confirmed to emit the native upkeep cue.

Start by reading the shared controller/scopes in `src/infrastructure/core.lua`, UI/native-menu handling in `ui.lua`, bootstrap/load restoration, the catalogue and builder's inherited player configuration. Use `training.lua`, `tutorial.lua` and the closest working activities for presentation and cleanup. Existing native-menu, ownership and Hotkey selection fixes must be preserved.

The shared controller, presentation helpers and cleanup scopes are useful foundations. They do not establish multiplayer correctness. Existing native-mock regressions cannot prove synchronized behavior across clients.

## Proposed approach, subject to proof

Prefer regular human lobby slots assigned custom active/spectator roles. Do not base the design on an unverified ability to promote Warcraft's native observer slots into playable slots.

1. Inventory/reserve gameplay faction slots and introduce explicit participant roles.
2. Separate the active participant's input authority from who receives presentation. Gate exercise/menu actions to the active role; spectators must not advance narration, select answers, issue exercise commands or change setup.
3. Mirror the intended camera, visible world and relevant UI/audio to viewers while keeping gameplay state synchronized. Review local versus shared state carefully, including native menus, pause handling and keyboard/selection events.
4. Permit handoff only at a safe boundary with no exercise active. Dispose the previous activity, change the active participant, then let the next activity initialize for that participant. Avoid transferring a live tutorial's workers, inventory, timers or partially completed state.
5. Adapt remaining activities incrementally. Replace hardcoded assumptions deliberately; do not perform a blind global replacement of `Player(0)`.

Decide before the first prototype which simple existing activity to use, who may request/approve a handoff, and how host/active-player departure should behave. Decide score ownership and multiplayer save/load scope before promising support for them.

## First milestone: two-client proof

One representative exercise, one active participant and one spectator:

- Both can enter through the lobby without disrupting scripted factions.
- The spectator sees the intended exercise world and presentation.
- Only the active participant can navigate or affect the exercise.
- Both clients stay synchronized through start, result, Menu, Resume/Exit and cleanup.
- With no exercise active, pass control and run the same exercise again under the other participant.

Prove these basics inside Warcraft before expanding the scope. A partially supported prototype must identify its supported activity and should not expose untested activities as multiplayer-ready.

## Subsequent rollout and tests

- Expand presentation coverage to briefings, narration, target icons, scores, results and camera transitions.
- Adapt tutorials and exercises in small groups, checking direct ownership, input events, resources, shop patrons, selection and cleanup. Hotkey Trainer and selection-based Reflex need particular attention.
- Check multiple spectators, repeated handoffs and participant departure. Verify spectator native menus cannot accidentally navigate or pause the active exercise.
- Add automated role-gating/lifecycle tests, while retaining real multi-client acceptance for synchronization, camera/UI visibility and native controls.
- Preserve single-player operation and existing save/load behavior. Agree on multiplayer save/load expectations separately rather than assuming existing single-player support covers them.

## Relative effort and acceptance

Basic world spectators are a relatively small prototype. Faithfully mirroring the player's camera and custom presentation is moderate shared-system work. Reliable between-exercise handoff is another substantial step touching individual activities; it is not merely another menu button.

Expect several focused implementation/testing passes. This is a relative scope assessment, not a time commitment. Synchronization and native input behavior are the main uncertainties. A successful two-client proof should determine the next estimate and rollout scope. User acceptance is required before treating either observer support or handoff as complete.
