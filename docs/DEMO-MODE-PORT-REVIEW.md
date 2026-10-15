# Legacy Demo Mode: port assessment

Reviewed 15 October 2026, after the source reliability pass. Planning only; `tools.demo` remains a placeholder. Evidence is the extracted legacy Lua, `work/legacy-war3map.lua`, functions `DC_InitCatalogues` through `Training_StartDamageCalculatorLevel` (approximately lines 15328–16251).

## What already works as a reference

The legacy workbench is substantial: paginated 24-slot unit/item pickers; race/type/side/quantity selection; controlled spawning; selected-unit controls; damage and external mana-loss popups/logs; rolling DPS; free-spell, day/night and vision toggles. Selected-unit actions include heal/refill, cooldown reset, invulnerability, clone, swap side, remove, level up, upgrades, passive/fight, skill learning and reset position.

The interactions are a useful specification and much of the local logic can be adapted. A port should preserve their immediacy rather than force every edit through a full activity restart. It is more than menu-design work, chiefly because lifetime, cleanup and global-state restoration differ in the successor map. A wholesale rewrite is unnecessary.

## Fit with the current map

Implement one `tools.demo` activity with a small briefing and the normal Menu toolbar. Keep mutable units/items/history in the activity object. Track timers, triggers, generated units and items in its session scope; put workbench frames and presentation callbacks in its presentation scope. Rebuilding the UI after load must not respawn units or replay an experiment.

Reuse the shared briefing/buttons, native-menu visibility, borrowed camera/world state and generated-unit cleanup. Import the verified legacy picker behavior and local measurement calculations incrementally. Use maintained unit/item/hero data, with explicit icon/name validation, rather than copying a second hand-maintained melee catalogue. The Hotkey catalogue supplies useful identities and prerequisites, but is command-oriented and is not a complete Demo inventory by itself.

## Patterns worth retaining or improving

- **Retain:** bounded logs/history, reusable picker slots, separation of spawning from UI refresh, two explicit sides and fast local reset controls.
- **Use a local experiment scope:** Clear/Reset can dispose its units/items/casters/history without recreating the whole activity or disturbing the camera/menu. This is a useful application of existing scopes, not a reason to redesign every exercise.
- **Keep an explicit spawn registry plus shared generated-unit tracking:** summons, transformations and split/merge products need to belong to the experiment even if they never passed through the picker.
- **Keep measurement separate from display:** an activity-owned measurement component can update while the panels are hidden; UI refresh should only display snapshots. Extract a shared component only if another activity actually needs it.

## Structural limits to address

1. **Global coupling and persistent handles.** The legacy uses many `udg_dc*` globals, fixed coordinates, shared training fog/UI and an active-level number. UI initialization creates timers/triggers once, with callbacks checking that level. Adapt these to the activity lifetime rather than copying the globals or permanent callbacks.
2. **Cleanup restores defaults rather than previous state.** Legacy cleanup resets upgrades to zero, fog and some controls. The current map must borrow/restore the actual previous research, alliances, controllers, time/fog/camera state. Avoid repainting/deforming shared terrain in the first port.
3. **Catalogue and upgrade coverage are incomplete.** The unit list contains only selected buildings; icon lookup has explicit exceptions. Skill learning enumerates the 16 racial heroes, omitting Tavern heroes. Upgrade cycling chooses research from the owner's race, which is wrong for mixed-race experiments. Select upgrades from the actual units/races under test and agree the intended catalogue scope first.
4. **“Clone” is a fresh spawn.** It calls the spawn path with the selected type; side/quantity come from picker state. It does not duplicate exact level, inventory or buffs. Preserve or change this only after deciding what Clone should mean. “Full Reset” restores health/mana/cooldowns/invulnerability, not level, skills, inventory or all effects; there is no level-down action.
5. **Combat attribution is approximate.** Before/after damage is paired using target-indexed storage; nested damage can overwrite that pairing. Spell labels use a recent-cast time window, and mana-loss attribution uses a global recent spell. Delayed/projectile/periodic or simultaneous effects can therefore be mislabeled. DPS is incoming damage to the selected target, capped by its remaining HP, not universally damage dealt by the selected attacker. Label and test these semantics before presenting them as exact diagnostics.

## Suggested port order

First agree scope and control semantics, then implement spawning/selection/clear with reliable exit and menu/load restoration. Add heal/cooldown/side/level/item controls next; follow with measured damage/DPS/logging and representative armor/spell/overkill tests. Leave terrain cosmetics and expanded statistics until the workbench is accepted.

This should be a moderate feature port with native testing, rather than another extensive Hotkey-style input investigation: the player directly controls visible units, and no hidden command-grid recognition is needed. A numerical effort estimate would depend on catalogue completeness and how exact the combat diagnostics must be.

Before implementation, clarify Clone/reset semantics, whether level-down is needed, racial versus side colors when races are mixed, and whether the measurement panel should report damage taken, dealt, or both. These are deferred design questions, not blockers for current tutorial work.
