# Surround ability unlock audit

Verified against the locally installed Warcraft III build `3.0.0.24268`.
The installed CASC tables were read without editing game files. Temporary copies
of `Units/UnitAbilities.slk` and the racial `*AbilityFunc.txt` files remain in
ignored `work/`; those files are not distributed with the map.

Stone Form requires `Rusf`. The earlier code incorrectly researched `Rusp`,
which unlocks Destroyer Form. Necromancer training requires `Rune` level 2;
adding the abilities alone does not satisfy their research requirements.

All racial non-hero ability research is temporarily granted in every Surrounds
mode, including Custom and Gargoyle Surround. Caster training reaches master
level. Each previous research level is restored when the activity ends.
Heroes continue to receive only the skills selected by the preset or Custom menu.

The installed Forsaken Paladin's hero ability list is
`AHcr,ANcp,AHpa,AHcl`. The localized neutral ability strings identify them as:

| Ability | ID |
| --- | --- |
| Consecration | `AHcr` |
| Righteous Fury | `ANcp` |
| Sacred Aura | `AHpa` |
| Cleansing Fire | `AHcl` |

All four Custom definitions and both preset rotations now use these IDs.
Body Blocking lists the Paladin as a runner and assigns no hero skills, so it
does not contain the wrong ability assignment. Rain of Fire remains `ANrf` for
the Pit Lord, where it is correct.
