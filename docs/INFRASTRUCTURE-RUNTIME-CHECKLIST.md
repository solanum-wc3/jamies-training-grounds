# Shared infrastructure runtime checklist

Candidate: `v0.0.2-alpha.31`

This candidate is not an accepted milestone until these checks pass in Warcraft III and World Editor.

## Navigation

- The map opens on the Jamie's Training Grounds root menu.
- Learn to Play, Advanced Play, Skill Training, and Tools & Extras each open their own catalogue.
- Every listed activity is grey and cannot be launched.
- Back returns to the root menu.
- Player Stats is visibly unavailable and cannot be clicked.
- Patch Notes and Credits open and return correctly.
- Patch Notes show dated milestone entries in newest-first order and can scroll when their contents exceed the visible area.
- Active category, illustrated-card, Restart, and Training Menu buttons show readable hover tooltips. Back, Patch Notes, and Credits do not need tooltips.
- Planned entries without artwork and Player Stats show no tooltip.
- On release, the cursor and tooltip remain stable while the deferred action opens another panel or restarts the activity.
- After clicking category, Patch Notes, Credits, Back, Restart, and Training Menu controls, Enter opens chat and F9 opens the native Quest window without first clicking the world.
- After clicking an illustrated planned card that remains on screen, wait a fraction of a second and verify that Enter opens chat rather than activating the focused card.
- Body Blocking uses the regular planned-button treatment; Surrounds uses the supplied illustrated card and tooltip.
- The native Quest button and F9 still open the native Quest window.
- Clicking custom controls does not leave keyboard focus stuck on a frame.

## Hidden lifecycle diagnostic

1. Type `-diag-start`. One invulnerable Footman should appear in the southern practice arena. Restart and Training Menu should appear.
2. Type `-diag-status`. State should be `running` and activity should be `dev.lifecycle`.
   The timer-pulse count should increase while that session remains active. The Footman should retain its normal team coloring without a yellow model tint.
3. Explore outside the southern arena, then click Restart repeatedly. Each click should replace the Footman rather than accumulating units. The entire playable map should return to masked fog outside the Footman's current vision, and the camera should retain a normal playable angle.
4. Wait between resets. No expired timer callback should affect a replacement session.
5. Click Training Menu. The Footman and activity should remain active, Skill Training should open, the toolbar should offer Return to Training, and `-diag-status` should still report `running` with `dev.lifecycle`.
6. Click Return to Training. The catalogue should close and the activity toolbar should return without creating another Footman.
7. Type `-diag-exit`. The Footman should disappear, the previous camera should be restored, the full playable map should be remasked, and `-diag-status` should report `idle` with no activity.
8. Repeat start/reset/exit through `-diag-start`, `-diag-reset`, and `-diag-exit`.

## Foundation regression

- Lobby still has one trainee slot with selectable race.
- Loading screen, browser preview, terrain minimap swap, terrain, pathing, fog defaults, and preserved map areas match accepted alpha.5.
- No melee starting army, melee victory condition, legacy exercise, camera tutorial, custom Info button, or profile load/save appears.

## Editor compatibility

- Open the candidate in World Editor without a trigger or data error.
- Confirm the Shared Infrastructure custom-text trigger is present.
- Save a separate copy, launch it, and repeat the navigation and diagnostic smoke tests.
- Record Warcraft III version, World Editor version, graphics mode, artifact SHA-256, and results before accepting the milestone.
