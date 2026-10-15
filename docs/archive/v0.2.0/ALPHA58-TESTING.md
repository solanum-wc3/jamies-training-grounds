# Alpha58: Heroes sound isolation and blight follow-up

The alpha57 native trace has XP handicap 1 throughout, no player food usage, and no conditional XP setter call. The user confirms the unwanted sound is the UpkeepLevel sample and occurs on both no-button entry and exit. Blight remains when switching away from Undead XP Numbers; full-exit failure has not been established. Shared control is a candidate, not an established sound cause.

## Focused Warcraft checks

1. From the main menu with no activity running, type `-heroes-audio-control`. It changes only player 6's shared control, then restores the prior value three seconds later. Report whether either transition produces the chime. No tutorial is spawned and no sound is played by the test itself.
2. Type `-heroes-audio-no-control`, listen on entry, then `-heroes-audio-stop` and listen on exit. This starts the normal Heroes opening with only the shared-control setup omitted. Test the opening only: hostile dummy controls are deliberately unavailable in this diagnostic run. The temporary flag is restored immediately; ordinary entry retains normal control. The stop command exports `JTG-Heroes-Audio.pld`.
3. Enter Heroes normally. Open Optional > XP Numbers > Undead. Switch to Human, wait at least one second and inspect the former Undead ground. Type `-heroes-terrain` to export `JTG-Heroes-Terrain.pld`, including before-immediate/next-tick/settled blight differences and first affected coordinates. Check switching back to Undead quickly too: stale cleanup must not erase the new display's blight.
4. Exit/re-enter and check the original grass/terrain and authored blight remain correct. If the visual blight remains despite zero sampled differences, report that separately; the snapshot sampling may need further native investigation.

Exports are diagnostic preload files in Warcraft III's CustomMapData directory; never execute them as scripts.

## Implementation and limits

Released terrain baselines remain available until a next-tick and a half-second post-removal check finish. Reacquiring or releasing a cell changes its generation; older callbacks cannot restore or delete the replacement scene's state. Each timer is bounded and destroys itself. Terrain restoration remains scene-owned; original tiles, variation and existing blight are preserved.

The sound commands are development-only. No production sound is muted, and no gameplay alliance behavior changes outside the explicit no-control diagnostic. Automated fixtures test flag restoration, direct control-probe restoration, delayed native writes and overlapping/replacement scene lifetimes. Actual sound causation and blight rendering still need the above native tests.
