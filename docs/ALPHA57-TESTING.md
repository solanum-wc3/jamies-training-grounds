# Alpha57 focused testing

Implemented changes await Warcraft III acceptance. The upkeep chime is not yet diagnosed or claimed fixed.

1. From the main menu, type `-heroes-audio-start`. This enters Heroes without button audio. Note whether the unwanted chime occurs.
2. Type `-heroes-audio-stop`. Note exit audio. This writes `JTG-Heroes-Audio.pld` in Warcraft III's CustomMapData directory. It contains native XP handicap, food/cap and actor placement records. It is diagnostic preload output, not an executable script.
3. Type `-heroes-audio-sounds`. Three labelled cues play three seconds apart: PauseGame, GlueScreenClick, UpkeepLevel. Identify which matches the unwanted sound, if any. Compare normal button entry/exit too.
4. In Heroes > Optional > XP Numbers, inspect every racial list, especially Undead structures. Check placement, building overlap and the extra 200 units between regular and summon captions.
5. Switch from an Undead presentation to a section without spreading buildings, then exit. Check original ground and grass return and no blight remains. Repeat via Back/Topics and in Hotkey Trainer with Undead commands. Original map blight must remain intact.
6. Compare Topics/Optional in Heroes, Camera, Controls and Economy, plus Surrounds Setups. Check matching panel/button layout and a separate Close footer. Check long labels.
7. Smoke-test Menu/Resume, exit/re-entry and save/load in changed scenes; actors and ground should remain correct and menus should restore without replaying setup.

Automated checks cover source syntax, generated data, scope restoration, overlapping terrain ownership, popup geometry and the development-only audio commands. Native audio, blight/grass rendering and building placement still require this in-game pass.
