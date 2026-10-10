# Economy & Workers tutorial

The scripted tutorial uses the 9 October 2026 draft in [economy-script-draft.txt](../design/tutorials/economy-script-draft.txt). Narration is stored in [economy-script.json](../design/tutorials/economy-script.json) and contains 58 narration stops, incorporating the edited work file’s splits and player practice prompts.

## Ownership and control

The active race is owned by Player 0 throughout this tutorial and has unrestricted player control. The other three races remain script-controlled and provide no vision. Changing race transfers ownership and preserves Human blue / Orc red / Night Elf teal / Undead purple and each faction's resource balance. Whenever a race is shown, its gathering tasks are reissued after ownership transfer, as requested. This avoids the engine cancelling Peon/Wisp work on a handoff. Ordinary narration and menu restoration do not replay work orders.

Native harvesting, construction and other engine orders are never intercepted. No orders or abilities are blocked, and tutorial-owned workers are not paused. No starting research is enabled.

Continue and Next advance narration. Back and Topics recreate a clean checkpoint scene, including preceding construction and the currently required faction. Camera changes use the shared fixed 1.5-second movement. Delayed cameras are guarded by their narration stop and session. Clearing narration and rebuilding presentation do not rebuild the scene or restart workers. The temporary four-race cycling preview is no longer used by the packaged tutorial.

## Layout and construction

The original export contains 70 placements. Correct native associations are Crypt `usep`, Moon Well `emow`, Ancient of Wonders `eden`, Altar of Darkness `uaod`, and Altar of Elders `eate`. The script adds a Sacrificial Pit and reserves two altar positions absent from the original export. There are 65 initial placements and 8 later-trigger placements.

| Building | Rawcode | X | Y | Appearance |
|---|---|---:|---:|---|
| Ancient of Wonders | eden | -4416.0 | -3968.0 | queued_worker_build |
| Altar of Kings | halt | -1696.0 | -6880.0 | queued_worker_build |
| Castle | hcas | -1344.0 | -6400.0 | trigger_spawn |
| Keep | hkee | -1856.0 | -6400.0 | trigger_spawn |
| Altar of Storms | oalt | 4000.0 | -4576.0 | queued_worker_build |
| Watch Tower | owtw | 3264.0 | -5248.0 | queued_worker_build |
| Altar of Darkness | uaod | -5664 | 1120 | queued_worker_build |
| Altar of Elders | eate | -4416 | -3552 | queued_worker_build |

The player now performs repair, Human power building, Orc altar construction and Burrow entry, Night Elf altar/Ancient construction, and Undead summoning, Unsummon and Sacrifice. These narration prompts issue no automatic work orders and do not gate Continue on completion. Native structures and trained units are still tracked for cleanup. Back/Topics reconstruct completed practice scenes before the selected stop; they do not perform its current practice action.

The Human Altar of Kings, Orc Altar of Storms, Night Elf Altar of Elders and Ancient of Wonders, and Undead Altar of Darkness begin absent. The Undead altar reference is (-5664, 1120), southeast of the base, with blight provided for the practice. The Crypt and Sacrificial Pit are present initially. Keep and Castle appear instantly for food-production narration and are removed afterward. The Watch Tower remains an unused reserved placement.

Human and Orc attacks use purple Ghouls owned by the Undead tutorial faction. Continue kills the attackers, leaving their death visible in the following narration; later encounter cleanup removes them. Far Seer wolves attack lumber Wisps.

## Gathering and cleanup

At map entry, all four bases’ workers spawn on native open-ground positions around their respective main building with pathing enabled, after all initial buildings. Five workers per race are sent to Gold and the remaining workers, including Ghouls, to Lumber. Exported worker positions remain reference points for their gathering assignments; buildings retain exact exported positions. Five workers per race gather gold; remaining Peasants, Peons and Wisps, and all Ghouls, gather nearby lumber. Those assignments were inferred from placement clusters because the original export has no orders. Wisps and Acolytes use their prepared racial mines. The underlying neutral gold mines are hidden and have pathing disabled until cleanup; they are not duplicated visibly. All initial buildings are created before workers. The shared scene-unit helper uses a full native position update if placement needs correction, keeping model and gameplay coordinates together; coordinate-only building setters are not used. Trigger-created Town Halls explicitly receive permanent native militia conversion (`Amic`), matching the existing legacy trainer.

Creeps within 1100 units of a layout placement are hidden and paused for the tutorial, then restored on exit. Trees start healthy and are restored after harvesting. Units, construction sites, training products, attackers, event triggers, timers, player state and camera changes use the activity scope; Undead blight is cleared after owned structures are disposed.

Native construction, garrisoning, Unsummon, Sacrifice, supply notifications and harvesting require in-game validation. Synthetic tests validate order routing and lifecycle rather than native pathfinding or animations.

The Outro shares the Upkeep checkpoint; Topics lists eight sections and has no separate Outro entry.

Gold Peons receive native smart (right-click) orders onto the Gold Mine. On showing the Orc base, an idle-only retry runs 0.10 seconds after ownership transfer. Burrow narration selects the Gold Mine-side Burrow at (4064, -5280), including the manual-entry prompt and food-building camera tour. Wolves have acquisition and guard behavior disabled; their direct attacks select visible, living lumber Wisps, excluding Wisps inside construction sites. The wolf targeting monitor repairs overwritten summon orders and redirects orders targeting a construction site.
