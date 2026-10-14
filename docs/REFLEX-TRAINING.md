# Reflex Training prototype

## Identification stages

Identify Units has ten stages. Stage one requests one unit; Continue retains the previous requests and adds one, up to ten. Requests use the existing three target types of the first selected race, even when the crowd mixes races. The icons are grouped by type. Only the newly added request flashes at 200% size and flies into the upper-right list; GO and the response clock begin when that flight starts. Later stages reuse the crowd and reset its selection marks rather than respawning it.

Each distinct correct selection scores 15 points within one second of GO/the previous correct selection, 10 within five seconds, and zero afterward. A wrong selection loses 10; re-clicking a marked unit does not count twice. Scores accumulate across the ten stages. Color and size thresholds match Hotkey Trainer: red below 250, yellow from 250, green from 350, and gold from 450. Results offer Continue until stage ten, Start Over, Menu and the race's high score. Toolbar Redo retries the current stage from its starting score.

## Current population rules

Identify Units always spawns **62 units**; Reflex Test always spawns **50 units** and remains stationary. These are another 20% reduction from the previous 77/62-unit fixed budgets, rounded to the nearest whole unit. Selecting one, two, three or four races changes the mixture and regions, not the total population. Each race receives an equal share; any remainder is assigned in selector order.

Each selected race has at most two of its war machine: Human Siege Engines, Orc Demolishers, Night Elf Glaive Throwers and Undead Meat Wagons. Caps use native spawn IDs, so the historical Siege Engine/Mortar Team selector aliases cannot interchange these limits. Heroes, Avatars of Vengeance and Phoenixes remain unique. Summon-family budgets remain divided across levels, and level-three Spirit Wolves and Shades remain excluded.

Random initial amounts are trimmed or filled to the fixed quota. Filling uses ordinary units and never adds heroes, ultimate summons, summon families or war machines. Trimming prefers duplicate models; if a race mixture has more distinct models than its quota allows, a random subset fits the screen. Identification always retains all copies needed by the target list from the first selected race. The one-race crowd therefore has more copies of ordinary units than a four-race crowd.

The fixture exercises all 15 nonempty race selections in both modes with minimum and maximum random draws, checking exact totals, even allocation, machine caps, unique heroes/ultimate summons, native spawn IDs and required targets. Existing movement, layouts, selection, timing and cleanup checks also remain in place. Live testing should compare screen density across race counts and confirm machines no longer dominate either mode.

## Native buff/debuff recognition

Each effect now uses its real melee caster, with 1,000 mana and scoped native research prepared before creation. Hero casters learn the relevant skill. This replaces the zero-mana Peasant dummy's dependency on mutable mana-cost fields and prepares Inner Fire's Priest Master Training explicitly. All 21 ability/caster/buff associations and prerequisites were checked against installed melee data. Each race has both buffs and debuffs; a single-race crowd uses its own buffs, while debuffs require another selected race. Identification marks are hidden and scaled to zero before destruction to suppress lingering death particles between stages.

Reflex Test now asks for a randomly selected effect rather than using the same decorative Rejuvenation marker every time. The effect name appears only after its native buff is confirmed on the target; pending applications say Preparing effect. Every previous trial's supported buffs are removed across the crowd, including effects on bystanders. There are ten successful clicks, with average and fastest times on the result card.

The supported melee pool excludes auras:

| Race | Buffs | Debuffs |
| --- | --- | --- |
| Human | Inner Fire | Slow, Polymorph, Banish |
| Orc | Bloodlust, Lightning Shield, Spirit Link | Hex, Ensnare |
| Night Elf | Roar, Rejuvenation | Entangling Roots, Faerie Fire, Cyclone, Shadow Strike |
| Undead | Frost Armor, Anti-magic Shell, Unholy Frenzy | Curse, Cripple, Sleep |

Only selected races contribute effects. Buffs target units of their own race; debuffs target a different selected race. A one-race selection therefore uses buffs only. War machines, summoned units, mechanical units and units with intrinsic magic immunity cannot be targets. Polymorph also excludes heroes. Skeletons and Carrion Beetles are explicitly classified as summoned targets even though the shared selector does not group them into summon families.

A transparent, unselectable dummy caster uses the actual native ability and its ordinary casting sound. Cast point and backswing are zero, dependency checks are disabled on that dummy ability, and supported autocast defaults are explicitly disabled. The target is temporarily vulnerable so hostile spells can affect it. Its health is maintained while waiting and during the trial; Rejuvenation retains one missing HP. Durations are set to 120 seconds where the native runtime field permits it. Roar and Spirit Link use a one-unit radius at the target, and Spirit Link requests a one-target cap. Lightning Shield also uses a one-unit damage area to avoid disturbing neighbors. None of these adjustments introduce a decorative substitute for a failed native cast.

Timing starts only when one of the native effect's verified buff IDs is detected on the target. Wrong clicks, pending casts, paused activity and hidden exercise presentation cannot advance a trial. A correct click removes all buff IDs associated with that effect, restores target invulnerability and removes its dummy caster before applying the next effect. If application fails or an effect expires, retry another eligible target; three unsuccessful applications exclude that effect for this session. If every eligible effect fails, show a result explaining that no native effect could be applied rather than waiting forever.

The fixture covers all 21 effect mappings, own/opposing race rules, target exclusions, pending native onset, expired-effect retries, one-race pools, bounded failures, and buff/caster cleanup. These mocks validate orchestration only. Native sound, target validity, field overrides and especially one-target Spirit Link / one-unit Roar still require live Warcraft testing. Native effects remain visible while a custom menu covers the exercise; the timer and click acceptance are suspended.

## Historical iterations

Last packaged iteration: v0.1.3-alpha12. This includes both training modes, the three randomized crowd layouts, authored briefing artwork and a race selector. The distributed release remains v0.1.2-beta1.

Alpha12 fixes Undead startup by translating the historical Infernal selector key `uin1` to native `ninf`. The fixture now checks spawn IDs against an inventory generated from installed unit data, rather than trusting a handwritten whitelist. Avatar of Vengeance and Phoenix population counts are capped at one; the current ground-only crowd still excludes flying entries.

In alpha11, both modes first open a 2×2 selector: “Select which races you want to see.” Selected buttons turn grey but remain clickable; clicking again deselects them. The list under the instruction highlights selected races. Start Training requires at least one race. Human units are blue, Orc red, Night Elf teal and Undead purple. Separated layouts use two halves, three horizontal/vertical slices, or four quadrants depending on the selected races; mixed layouts use the whole arena. At that iteration, total population was capped at 120 with a per-race share, while preserving distinct models and one of each hero. Reflex Test used 20% fewer units and no movement. The fixed totals above supersede those population rules. Redo retains the race selection.

Identification targets currently come from the first selected race in Human/Orc/Night Elf/Undead order. Human: two Footmen, Priest, Knight. Orc: two Grunts, Shaman, Tauren. Night Elf: two Archers, Dryad, Mountain Giant. Undead: two Ghouls, Crypt Fiend, Abomination. The crowd preserves enough copies of those targets. The Human/Orc descriptions below record the earlier mixed-race prototype; the selector now supports all four races.

In alpha8: Reflex Test uses 20% fewer units (rounded to the nearest unit), keeps all models represented and every hero unique, and is stationary regardless of layout. Both modes exclude level-three Spirit Wolves and Shades. The identification crossing layout now assigns opposing owners, enables acquisition and restores every unit to maximum HP once per second, including during the countdown. Normal attacks deal damage, with lethal damage capped to leave 1 HP between refreshes so required targets remain alive.

In alpha6: a mixed Human/Orc crowd, with blue Human and red Orc team colors. The fixed Human target list remains unchanged for this first mixture test.

Fixed in alpha5: selection is registered on Player 0's unit-selection event, not neutral units' individual events. The icon preview now precedes GO; clicks, walking and elapsed time begin when the icons depart the center.

Fixed in alpha4: the crowd now translates the shared selector's historical Mortar Team/Siege Engine keys to native `hmtm`/`hmtt` IDs. Alpha3 failed at startup when `hmtn` could not create a unit. The regression now runs the actual shared Human roster and rejects invalid native IDs instead of accepting every mocked creation request.

The Tools & Extras card opens a shared briefing with Identify Units and Reflex Test choices. Either opens the race selector, whose Start Training enters the south arena. The shared toolbar offers Menu, Redo and Pause; live briefing pages retain Resume and Exit.

Both briefing levels use the shared standard button dimensions and placement. The mode page uses the standard 0.16 × 0.08 heading artwork; each mode opens the same centered 2×2 racial selector. Race symbols use the shared racial-button size and offset. Selected races remain clickable and greyed out, and Start Training requires at least one selected race.

The earlier prototype used the shared Human and Orc mobile ground rosters (56–104 units). Initial regular unit counts independently vary from two to four per race before the current quota adjustment, except Footmen have four to six to provide extra identification candidates; each hero has one, and each summon type shares a random three-to-six-unit budget across its levels. Any indivisible remainder is distributed in roster order. This includes workers, Militia, normal ground military units, heroes and all three Water Elemental levels and the first two Spirit Wolf levels. Flying entries and stationary Serpent Wards are excluded. Except in the identification combat layout, units are neutral-passive owned, invulnerable and selectable, with blue Human and red Orc team colors, so clicking cannot interrupt their walking or populate the player's hero bar. Native collision and movement speeds are retained.

A shared three-second countdown shows 3, 2, 1. The fixed target row (Footman, Footman, Priest, Knight) then appears at screen center with 200% icon size. After a 0.4-second hold, GO appears and the icons smoothly move and shrink over 0.3 seconds to normal-size icons at the top right, below the toolbar. Identification clicks and elapsed time begin on GO. The pre-crossing layout has already issued its movement orders before the countdown. Reflex Test uses the same countdown, without the identification icon row, and marks its first target on GO. Selections during the preview cannot advance the targets.

The player must select two distinct Footmen, one Priest and one Knight, in any order. Each correct selection dims one target icon and gives the unit persistent transparency, a green tint and the native Banish target effect (verified in the local ability skin data). This is a visual marker; it does not apply Banish's gameplay effects. Repeated selections of the same unit and incorrect selections do not advance the targets. Selection during countdowns, menus or pauses is ignored. Four correct selections stop the crowd and show the shared success card with Redo and Menu. There is no time limit, penalty or performance score yet.

The earlier Reflex Test marked one random unit with the native Rejuvenation target effect; the recognition mechanic above replaces it. A correct click destroys the Rejuvenation effect on that unit and immediately marks another unit, excluding the previous target. Wrong clicks do not advance the trial. After ten correct clicks, the shared result card reports average and fastest reaction times. The reduced Reflex Test crowd remains still throughout the countdown and trials. Reaction time advances in 0.01-second simulation ticks, excluding pauses; this measures game event timing, not hardware input latency. Menu hiding hides the current marker and rejects clicks, and Resume restores it.

The initial arena is 1,800 units wide by 1,000 deep, centered at the south arena's center (4864, 3456). Camera target distance is 1650, rotation 90 and attack angle 304, with the target at the arena center. This is an approximate screen-fitting first layout; actual visible footprint depends on screen aspect ratio, UI and camera perspective and needs native testing.

Spawn slots are shuffled across a 15 × 8 lattice with small random offsets. The separation avoids overlapping initial crowds while shuffled unit types prevent grouping by model. Each unit independently chooses random destinations inside the arena, with staggered initial orders. A quarter-second scoped update chooses another destination on arrival or after 1.5 seconds of no progress; it does not continually overwrite working movement orders. Edge recovery handles collision pushes outside the rectangle. Dense native traffic and visible edge corrections need in-game observation before tuning.

Redo preserves the selected mode and randomizes a fresh crowd and layout. Menu/load frame restoration retains countdown/animation progress and completed target slots without creating units, effects or timers again. The activity scope removes all created units, effects, selection triggers and timers, restores borrowed camera and time-of-day state, and the controller restores menu/fog state on exit. `tools/test-reflex-training.lua` checks population bounds, countdown, cue interpolation, distinct any-order selections, order bounds, stalls and presentation/cleanup contracts; it cannot prove native selection, pathing, visual effects or camera fit.

## Alpha test focus

- Briefing offers Identify Units and Reflex Test; either opens the race selector, and Start Training enters the centered arena.
- Test one, two, three and four races. Selected grey buttons must remain clickable; three-race strips and four-race quadrants should retain the correct colors and fit the view.
- Across several Redos, check mixed walking, separated pre-countdown crossings, and separated walking from GO, using both horizontal and vertical race divisions.
- Reflex Test prompts one native buff or debuff; correct clicks remove the previous effect, advance ten trials and show reaction times. Wrong clicks, paused clicks and menu clicks cannot advance it.
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


## Consolidated runtime boundaries (14 October)

Briefing bodies are generated from `design/exercises/editable/reflex-training.txt`. Keep the dynamic summary marker on the race-selection page; the exercise supplies the live selected-race list after that prefix. Author notes are excluded. `Training.InstallPresentation` owns the hide/rebuild contract for status, target icons, score and result aliases. Rebuilding presentation preserves the crowd, target plan, elapsed time, marks, stage and completion identity. Response awards and score appearance are shared with Hotkey through `Training`; clocks, result conditions and score accumulation remain activity-specific. Reflex remains WIP; this consolidation does not add modes or change its gameplay.
