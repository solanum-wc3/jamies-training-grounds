# Alpha60: finish blight cleanup across replacement displays

Alpha59 feedback accepts the sound/control and presentation-building changes, but shows residual blight after switching to Human XP Numbers. The saved terrain report records 663 initially released cells and only 204 eligible delayed cells: 459 were excluded after replacement buildings acquired baseline leases.

The cleanup guard incorrectly equated every live terrain user with an active blight writer. Baseline ownership and blight-source ownership are now separate. Native Abgs/Abgl/Abgm abilities identify spawning buildings that spread blight, including custom presentation copies. Ordinary buildings retain their baseline lease but no longer block departed blight cleanup. Explicit terrain mutations reserve blight-write ownership by default. Only fully released ground has its tile/variation repainted; partial cleanup changes only blight. Generations still protect new blight writers and later releases.

## Focused Warcraft checks

1. Heroes > Optional > XP Numbers > Undead, then Human. Wait one second and inspect the whole former Undead area, including around and beneath the Human display. No leftover blight should remain; presentation buildings should retain their clean ground.
2. Repeat with Orc, Night Elf and Hero as destinations. Include a quick Undead -> Human -> Undead change; the new Undead display must keep its expected blight.
3. Exit and revisit the presentation. Check original ground returns and the accepted dummy controls/audio still behave normally.
4. If any blight remains, type `-heroes-terrain` after waiting one second. The report now includes `blight-only` counts for cleanup completed while replacement buildings retain baseline leases. Provide the transition used and whether the remnant is still visible.

Regression fixtures reproduce the non-spreading replacement failure, a simultaneous ordinary-building/source overlap, a live replacement blight source, explicit terrain writers and delayed native writes. Automatic checks do not prove native rendering; acceptance remains pending the game check.
