# Focused activation retest — alpha 15 development build

Load `Jamies-Training-Grounds-v0.1.2-alpha15-dev.w3x` and enter **`-timing-retest`**. Do not command the units during the run. Allow about **seven minutes** at normal speed.

There are 39 automatic trials, each case repeated three times:

- Wisp construction: near and far approach. The unused Tree of Life and mine are removed from these isolated cases. The harness searches for a clear building footprint, checks terrain, units and destructibles, aligns the worker north of it, and checks the site again at the actual request. A failed preflight is reported as a setup failure rather than an activation result.
- Wisp Detonate: immediate order, point order at its own position, and immediate order with the paused opponent nearby. These are separate trials, not repeated commands within a single measurement.
- Statue → Destroyer: `avengerform`, with diagnostic supply ceiling/cap. Gold, lumber, food usage/cap/ceiling, mana, paused state, current order and relevant ability levels are exported at setup and request. The original resource/supply state is restored on cleanup.
- Shadowmeld: the Priestess keeps moving during preparation so she is visible before the scheduled `ambush` order. An already-invisible pawn fails the setup check instead of yielding a false fade timing.
- Archer mounting and Hippogryph pickup: near and far, using `coupletarget` when the native unit has Aco2/Aco3. These abilities use base code Acoi in the installed ability data, unlike the older Acoa/Acoh orders. Legacy order routes remain for units without Aco2/Aco3.
- Hippogryph Rider dismount: new Archer/Hippogryph handles are discovered and sampled. The old handle's corpse movement is excluded from live movement observations.
- Avatar: additional magic-immunity and Avatar-buff state sampling distinguishes the native spell effect from observed protection.

The discovery of a replacement unit is sampled every 0.05 seconds; it is explicitly **not** a native creation event or an exact creation timestamp. Other sampled states retain the recorder's requested 0.01-second period and Warcraft simulation granularity. A clear-site test is conservative and is not a substitute for Warcraft accepting construction. An accepted order is still not proof of activation.

The order investigation used installed ability data and the community's directly researched [order catalogue](https://www.hiveworkshop.com/threads/list-of-order-ids.350361/). This pass will verify actual behavior in the map.

The run exports automatically to `Documents/Warcraft III/CustomMapData/JTG-Dodge-Timing.pld` and returns to Skill Training. `-timing-stop` stops early and exports what was observed. The preceding alpha 14 export has already been preserved in the repository's local work folder, so the new export can replace the game's working copy.

The development Economy workspace beside the Tavern remains available. This pass produces only a development map.
