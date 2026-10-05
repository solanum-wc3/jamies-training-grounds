# Body Blocking runtime checklist

Candidate: `v0.0.3-alpha.1`

This candidate is not a tested milestone until these checks pass in Warcraft III and World Editor.

## Menu and launch

- The map opens on Jamie's Training Grounds and the existing category, Patch Notes, Credits and native Quest controls still work.
- Skill Training shows Body Blocking as an active regular button with a tooltip. Surrounds retains the illustrated planned card.
- Body Blocking opens a format dialog with Training and Custom, followed by Normal and Hard difficulty.
- Back buttons have no tooltip. Patch Notes still contain only the two completed milestones.

## Training format

1. Choose Training, a difficulty and each race roster in turn.
2. Confirm that a Footman blocker and the roster's first runner appear in the southern arena with START and FINISH markers.
3. Confirm the 3-2-1-GO countdown, rifleman start cue and quick removal of GO.
4. Keep the blocker in front of the runner. Confirm streak feedback, finish timing, added-delay score and result panel.
5. Click Next Runner. The old units, markers, timers and result panel must disappear; the next runner in the roster must start cleanly.
6. Click Restart during a run. The same matchup must restart without duplicate units or delayed callbacks.

## Custom format and failure

1. Choose Custom, difficulty, runner race, runner and blocker. Confirm the selected matchup is used.
2. Let the runner get 300 units ahead. The rifleman should eliminate the blocker and the round should reset after two seconds.
3. Complete a custom round and click Retry. The selected runner and blocker must be retained.
4. On Hard, confirm that the runner changes its path and receives more frequent movement orders.

## Shared lifecycle

- Training Menu preserves the current round; Return to Training restores it without creating another round.
- Restart, menu browsing, return, failure reset and exit preserve native F9 and chat behavior apart from the deferred one-frame custom-button release flicker.
- Leaving the activity removes its units, lightning markers, text tags, dialogs, result/countdown frames, timers and triggers; camera and fog return to shared defaults.
- Re-entering Body Blocking starts one fresh selection flow. No legacy profile is read or written.

## Foundation and editor regression

- Lobby remains one trainee slot with selectable race; terrain, pathing, minimaps and areas outside the practice district match the accepted foundation.
- No melee starting army, melee victory condition or unrelated legacy exercise appears.
- Open the candidate in World Editor without a trigger or data error, save a separate copy, launch it, and repeat the launch/reset/exit smoke test.
- Record Warcraft III version, World Editor version, graphics mode, artifact SHA-256 and results before accepting the milestone.
