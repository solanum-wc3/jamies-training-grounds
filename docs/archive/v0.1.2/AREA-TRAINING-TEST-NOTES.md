# Area training

Directional spells (Shockwave, Carrion Swarm, Breath of Fire and Impale) use a circular arena with radius equal to the spell's maximum travel distance. The pawn starts at that distance, with helpers positioned relative to it. A three-second countdown precedes the first cast and the exercise timer. The enemy remains at the centre. It aims along the ray toward the pawn, projecting the order point within cast range when needed; the wave continues toward the pawn beyond that point. The radius becomes 80% after five seconds and 60% after ten seconds. Cast commands occur at random intervals of 2–2.5 seconds; stationary movement feints occur at random intervals of 0.5–1 second outside the cast windup.

Radial abilities, including Thunder Clap and War Stomp, use a pursuing enemy. It approaches to half the ability's area radius before casting. Chasing heroes receive Boots of Speed once at ten seconds, for the final five seconds.

Blizzard and Rain of Fire cancel after the first damage wave, then use their native cooldowns rather than the random short cast interval. A damage event stops the channel immediately when the wave hits a player-owned unit. When nothing is hit, a fallback based on the native wave interval stops it; verify that fallback against the visible first wave in-game.

Red circles display directional travel distance, other spells’ casting range or, for radial abilities, area radius. Spell-use overlays show circular affected areas, travelling wave outlines or the Impale line. Wave movement is reconstructed from installed-game distance and speed data, not a live engine projectile handle. These overlays illustrate the footprint; they do not determine hit detection. Chain Lightning's area value describes potential bounce range, not circular splash damage. Native damage and debuffs still determine the result.

Check in Warcraft III:

- Directional casters stay centred while turning and feinting, and actually cast toward the pawn.
- Both arena reductions occur at the expected times and constrain the pawn to the new boundary.
- Thunder Clap and War Stomp heroes pursue and receive their boots at ten seconds.
- Blizzard and Rain of Fire stop after one damage wave even when the pawn avoids it, then wait for their native cooldown before recasting.
- Red markers match the visible spell effects, especially wave width, Impale and channelled spells.
- Opening Menu hides all markers; Resume restores them. Redo and Exit remove all old images, items and units.

Automated orchestration checks: `tools/test-area-training.lua`, after the existing Dodging lifecycle, revision and phase checks.
