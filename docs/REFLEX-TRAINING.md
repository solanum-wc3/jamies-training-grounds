# Reflex Training (WIP)

Included in v0.2.0; the WIP label remains intentional.

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

## Menus, layout and maintenance checks

Tools & Extras opens the standard briefing with Identify Units and Reflex Test. Each mode opens the centered 2×2 race selector; selected races remain clickable and greyed out, and Start Training requires at least one selected race. Live briefing pages retain Resume and Exit. The exercise toolbar offers Menu, Redo and Pause.

Human is blue, Orc red, Night Elf teal and Undead purple. Identification uses the existing mixed/separated crowd layouts; Reflex Test stays stationary. Race selection changes the mixture, not the total population. Check all race counts, required target availability, stage continuation, mark cleanup, effect onset/name agreement, Menu/Resume and save/load when modifying this activity.

## Shared runtime boundaries

Briefing bodies are generated from `design/exercises/editable/reflex-training.txt`. Keep the dynamic summary marker on the race-selection page; the exercise supplies the live selected-race list after that prefix. Author notes are excluded. `Training.InstallPresentation` owns the hide/rebuild contract for status, target icons, score and result aliases. Rebuilding presentation preserves the crowd, target plan, elapsed time, marks, stage and completion identity. Response awards and score appearance are shared with Hotkey through `Training`; clocks, result conditions and score accumulation remain activity-specific. Reflex remains WIP; this consolidation does not add modes or change its gameplay.

Earlier population limits, fixed four-target trials and alpha-specific instructions are preserved in [iteration history](archive/v0.2.0/REFLEX-ITERATIONS.md). They do not define the current stages or scoring.
