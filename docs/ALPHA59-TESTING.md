# Alpha59: confirmed shared-control chime and XP building ground

Alpha58 native tests establish the sound source: changing only dummy shared control produces the upkeep cue on both changes, while Heroes entry/exit omitting that change produces neither. Blight cleared in the tested Undead-to-Human transition; the remaining bare earth follows Human building footprints.

## Changes

- Configure player 6's shared control for player 0 in `config()`, after generic slot/alliance configuration and before gameplay. Heroes applies/restores hostility only; it never toggles that control permission. Player 6 remains reserved for hostile, controllable Target Dummies. No UI sound is muted.
- Optional XP Numbers uses custom presentation building copies with `uubs` ground texture set to none. Native unit stats and existing map overrides are inherited/copied. Stock buildings and all other activities remain unchanged. Generated display IDs derive from the maintained racial XP lists.
- Remove the obsolete development no-control entry branch. Normal no-button start/stop and terrain reports remain available. The direct control probe intentionally changes permission and may still chime; it is not part of normal play.

## Warcraft checks

1. Start a fresh alpha59 game. Check for an unwanted chime at initial map load, then enter and exit Heroes normally twice. Entry/exit should be silent apart from intentional menu cues.
2. In the Archmage target comparison, select the Hostile Target Dummie. Its mode, armor type and armor +/- commands must remain usable. Switch Neutral/Hostile, leave and re-enter, and test again. Hostility must still behave correctly.
3. Optional > XP Numbers > Undead, then Human: after one second, check that blight is gone and the displayed Human buildings have no dirt ground texture. Repeat other races and quick changes. Original terrain and blight must survive exit.
4. Check the same normal buildings in Mining Micro still have their usual appearance and production controls. XP captions must retain their original values and building models/names must remain correct.
5. Save/load with a Hostile dummy selected and with an XP display active. Controls, presentation and cleanup should remain correct.

If sound or control still fails, use `-heroes-audio-start` / `-heroes-audio-stop` from no active exercise; the native trace includes the configured shared-control value. Do not run the direct `-heroes-audio-control` probe during the ordinary sound acceptance pass.

Automatic checks cover no runtime permission writes, config placement, custom object inheritance/preservation, ID collisions, scene cleanup and generated data. Native config persistence, audio, grass rendering and save/load require the above game checks.
