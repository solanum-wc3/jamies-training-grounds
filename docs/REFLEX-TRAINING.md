# Reflex Training prototype

Last packaged iteration: v0.1.3-alpha8. This includes both training modes and the three randomized crowd layouts. The distributed release remains v0.1.2-beta1.

In alpha8: Reflex Test uses 20% fewer units (rounded to the nearest unit), keeps all models represented and every hero unique, and is stationary regardless of layout. Both modes exclude level-three Spirit Wolves and Shades. The identification crossing layout now assigns opposing owners, enables acquisition and restores every unit to maximum HP once per second, including during the countdown. Normal attacks deal damage, with lethal damage capped to leave 1 HP between refreshes so required targets remain alive.

In alpha6: a mixed Human/Orc crowd, with blue Human and red Orc team colors. The fixed Human target list remains unchanged for this first mixture test.

Fixed in alpha5: selection is registered on Player 0's unit-selection event, not neutral units' individual events. The icon preview now precedes GO; clicks, walking and elapsed time begin when the icons depart the center.

Fixed in alpha4: the crowd now translates the shared selector's historical Mortar Team/Siege Engine keys to native `hmtm`/`hmtt` IDs. Alpha3 failed at startup when `hmtn` could not create a unit. The regression now runs the actual shared Human roster and rejects invalid native IDs instead of accepting every mocked creation request.

The Skill Training card opens a shared briefing with Identify Units and Reflex Test choices. Either enters the south arena directly. The shared toolbar offers Menu, Redo and Pause; live briefing pages retain Resume and Exit.

The prototype uses the shared Human and Orc mobile ground rosters (56–104 units). Regular unit counts independently vary from two to four per race, except Footmen have four to six to provide extra identification candidates; each hero has one, and each summon type shares a random three-to-six-unit budget across its levels. Any indivisible remainder is distributed in roster order. This includes workers, Militia, normal ground military units, heroes and all three Water Elemental levels and the first two Spirit Wolf levels. Flying entries and stationary Serpent Wards are excluded. Except in the identification combat layout, units are neutral-passive owned, invulnerable and selectable, with blue Human and red Orc team colors, so clicking cannot interrupt their walking or populate the player's hero bar. Native collision and movement speeds are retained.

A shared three-second countdown shows 3, 2, 1. The fixed target row (Footman, Footman, Priest, Knight) then appears at screen center with 200% icon size. After a 0.4-second hold, GO appears and the icons smoothly move and shrink over 0.3 seconds to normal-size icons at the top right, below the toolbar. Identification clicks and elapsed time begin on GO. The pre-crossing layout has already issued its movement orders before the countdown. Reflex Test uses the same countdown, without the identification icon row, and marks its first target on GO. Selections during the preview cannot advance the targets.

The player must select two distinct Footmen, one Priest and one Knight, in any order. Each correct selection dims one target icon and gives the unit persistent transparency, a green tint and the native Banish target effect (verified in the local ability skin data). This is a visual marker; it does not apply Banish's gameplay effects. Repeated selections of the same unit and incorrect selections do not advance the targets. Selection during countdowns, menus or pauses is ignored. Four correct selections stop the crowd and show the shared success card with Redo and Menu. There is no time limit, penalty or performance score yet.

Reflex Test marks one random unit with the native Rejuvenation target effect. A correct click removes that visible marker and immediately marks another unit, excluding the previous target. Wrong clicks do not advance the trial. After ten correct clicks, the shared result card reports average and fastest reaction times. The reduced Reflex Test crowd remains still throughout the countdown and trials. Reaction time advances in 0.01-second simulation ticks, excluding pauses; this measures game event timing, not hardware input latency. Menu hiding hides the current marker and rejects clicks, and Resume restores it.

The initial arena is 1,800 units wide by 1,000 deep, centered at the south arena's center (4864, 3456). Camera target distance is 1650, rotation 90 and attack angle 304, with the target at the arena center. This is an approximate screen-fitting first layout; actual visible footprint depends on screen aspect ratio, UI and camera perspective and needs native testing.

Spawn slots are shuffled across a 15 × 8 lattice with small random offsets. The separation avoids overlapping initial crowds while shuffled unit types prevent grouping by model. Each unit independently chooses random destinations inside the arena, with staggered initial orders. A quarter-second scoped update chooses another destination on arrival or after 1.5 seconds of no progress; it does not continually overwrite working movement orders. Edge recovery handles collision pushes outside the rectangle. Dense native traffic and visible edge corrections need in-game observation before tuning.

Redo preserves the selected mode and randomizes a fresh crowd and layout. Menu/load frame restoration retains countdown/animation progress and completed target slots without creating units, effects or timers again. The activity scope removes all created units, effects, selection triggers and timers, restores borrowed camera and time-of-day state, and the controller restores menu/fog state on exit. `tools/test-reflex-training.lua` checks population bounds, countdown, cue interpolation, distinct any-order selections, order bounds, stalls and presentation/cleanup contracts; it cannot prove native selection, pathing, visual effects or camera fit.

## Alpha test focus

- Briefing offers Identify Units and Reflex Test; either starts in the centered arena.
- Across several Redos, check mixed walking, separated pre-countdown crossings, and separated walking from GO, using both horizontal and vertical race divisions.
- Reflex Test marks exactly one unit; correct clicks advance ten trials and show reaction times. Wrong clicks, paused clicks and menu clicks cannot advance it.
- Units fill the view without being obscured by the toolbar or lower interface.
- Human and Orc ground models are mixed throughout the arena, with blue Humans and red Orcs, and independently wander without becoming permanently stuck.
- Countdown and the 0.4-second central preview prevent premature clicks; GO appears when the icons begin moving below the toolbar and the exercise timer starts.
- Click a Priest, Knight and two different Footmen in any order. Correct units become transparent and their icons dim. Re-clicking the same Footman cannot complete both slots.
- Wrong selections do not advance the targets; the fourth correct selection shows the shared success card.
- Judge density, arena proportions and whether edge recovery causes distracting jumps.
- Menu/Resume and Pause preserve the same crowd; Redo creates a fresh randomized crowd.
- Exit and entering another exercise remove the entire crowd and restore camera/time state.
- Save/load preserves the crowd and resumes movement without duplicate units or timers.

Further identification target variations, additional race mixtures and penalties remain undecided. Do not produce another alpha until requested.
