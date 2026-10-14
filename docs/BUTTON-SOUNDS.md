# Custom button sounds

Opening a smaller menu (Topics, Optional or Setups), a root category, an exercise briefing, or the in-exercise Menu uses the native PauseGame cue. Other custom menu, toolbar and end-card buttons use GlueScreenClick. Native Warcraft buttons keep their native behavior.

Shared routing is in `src/infrastructure/ui.lua` and `src/infrastructure/tutorial.lua`. Each custom click plays one cue, with handles cached and no imported audio. The native labels chosen are PauseGame (GamePause.flac) and GlueScreenClick (BigButtonClick.flac); their audible match to the requested native buttons needs checking in Warcraft.

Headline and runner-finish cues remain unassigned. QuestNew remains only when an actual quest is activated. The HotDiggedyDog celebration for a successful four-Gargoyle surround remains. Ordinary unit and spell sounds are not globally muted. The development sound preview browser remains available for auditioning future assignments.

## Event cues

- First map initialization: MarkOfChaos (once, not on frame restoration).
- End cards: WandOfIllusionTarget1 (ItemIllusion); failure cards use BundleOfLumber (ReceiveLumber).
- Credits entry: ReviveOrc.
- Hotkey Trainer incorrect input: StampedeHit1 (StampedeHit).
- Hotkey Trainer correct input: PhaseShift1 (PhaseShift).

Result cues wait until the card is visible and do not replay on redraw or presentation rebuilding. Starting another stage resets the cue. Automated Hotkey audits/comparisons omit answer sounds. The four-Gargoyle celebration retains both its animated dog and HotDiggedyDog audio.


Completion cues are keyed to `session.resultAttempt`, not result-card visibility. `Training.BeginAttempt(session)` advances that identity for in-place Body Blocking rounds and Hotkey/Reflex stages; restarting an activity creates a new session. Hiding a result, Menu/Resume, replaying a Body Blocking run, or rebuilding presentation does not reset its cue. A hidden pre-render consumes no cue. A new result card uses its own session, and presentation reconstruction retains the session's completion identity.
