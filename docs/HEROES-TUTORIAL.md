# Heroes tutorial scene

The user-authored tutorial has 47 main narration stops, eight Topics checkpoints, and two Optional topics: Attack Dice (three stops) and XP Numbers (two stops). Continue/Next advances narration; Back and Topics reconstruct the selected checkpoint. Optional returns to the main stop from which it was opened. The final page highlights Menu rather than creating an extra Topics checkpoint.

Human, Orc and Undead Altars occupy the top row, 900 units apart. Night Elf and Tavern occupy the bottom row, 600 units below, staggered beneath the gaps. Heroes are placed 200 units below their building, 150 units apart, in native command-grid order. Tavern heroes occupy two rows (five and four for the current roster), with the lower row 350 units below the first (200 units farther south than the initial layout).

Arena1 (south) contains this showcase; Arena2 (north) contains comparisons, XP tasks, optional displays and items. Buildings spawn before heroes. Initially all heroes are neutral passive and level 10, with abilities unspent. Colors are Human blue, Orc red, Night Elf teal, Undead purple and Tavern grey. Every camera move uses the shared 1.5-second duration.

Level controls appear only in the interactive hero showcase and Attack Dice display. Selecting a hero enables +/− within levels 1–10. Lowering a level recreates that hero with no spent skills and transfers its inventory. Target Dummies use the verified native archery-target model, are continuously healed, and show damage popups from actual damage events. They remain enemy targets for offensive abilities. Heroes start with zero acquisition and Stop (the legacy Demo Mode passive setup); only the Archmage comparison receives automatic attack orders. Displayed heroes are vulnerable so their armor remains visible. Daytime is locked at noon and restored on exit. Level-1 spawns keep their native starting level; the + button follows legacy Demo Mode’s level-up operation with the XP lock temporarily released. The − button removes the old hero before creating its replacement, preserving coordinates.

XP tasks use native Warcraft XP awards, not scripted grants. The golden circle has a 1200-unit radius. Inactive showcase heroes are hidden, neutral-owned and XP-suspended, so they do not consume the player's XP share. The army now spawns alongside the first task instruction. The three Mountain King trials distinguish level 4, Paladin-only attacks with the level-5 King nearby, and leaving the King outside XP range.

XP Numbers shows ten Paladins at levels 1–10, with Arthas hammer/Frostmourne skins at the ends. Racial lists exclude heroes and include defensive buildings, native forms and summons. A sixth selector, Neutral, shows 25 summon types/forms from Tavern heroes, in grey: Bears, Quilbeasts, Hawks, Lava Spawns, Dark Minions, Doom Guard, Pocket Factories, Clockwerk Goblins and the three Storm/Earth/Fire spirits. Unit IDs come from native summon ability fields; campaign-only fourth levels are excluded. Clockwerk Goblins retain their native level 0 and nominal 0 XP. Regular units are grouped by level and food. Summons appear below the column matching their level and the corresponding regular food cost, with separate food/XP labels. Columns begin at least 500 units farther inward than in alpha48 and are centered when there is room. Summon labels include the half-XP factor; actual integer rounding and distribution are engine behavior. Attack Dice uses native dice groups with caption camera moves. Items provides the racial shops, Merchant, Marketplace and 49 distinct Twisted Meadows drops, grouped by the smallest eligible camp/drop group. Initial stock delays are removed for these item types and shops receive explicit stock.

## Standard lifecycle

`src/activities/heroes-tutorial.lua` owns progression and presentation. `src/infrastructure/heroes-scenes.lua` owns scoped world actors. Both use the shared Tutorial runner, guarded delayed actions and checkpoint restoration. Normal narration within a scene preserves actors and player actions. Back/Topics explicitly restore canonical scene state. Opening a menu or rebuilding presentation after load does not respawn actors, replay the quest sound or restart progression.

Scene scopes clean up units, summons, items (including picked-up items), text tags, images and timers. Foundation units are borrowed and parked during the tutorial. Camera, resources, XP handicap and hostile relationships are restored on exit. The optional XP quest is discovered once, when reaching Experience or opening XP Numbers, with the retained New Quest cue.

## Authoring and data

- `design/tutorials/heroes-script.json`: authoritative narration, stable stop IDs and scene metadata.
- `design/tutorials/heroes-script-draft.txt`: corrected readable draft; original attachment preserved.
- `design/tutorials/heroes-script-decisions.md`: confirmed clarification answers.
- `src/data/heroes-tutorial-data.json`: native constants, hero stats, racial XP lists, shop stock, TM drops and provenance hashes.
- `tools/prepare-heroes-tutorial.cjs`: validates and generates `src/generated/heroes-tutorial.lua`; `--check` rejects drift.
- `tools/patch-heroes-dummy.cjs`: adds the target object while retaining existing unit overrides.

The native snapshot is from installed Warcraft III 3.0.0.24268 and the repository's Twisted Meadows v1.9 reference. The narration uses the author's requested explanation of creep XP reduction; the data snapshot retains the extracted native factors. Spell reduction and fractional attribute data are unchanged.

## Verification and in-game acceptance

The Heroes fixture exercises actual shared scopes/guards with explicit native mocks: all scenes, level controls, optional return, race colors, XP setup distinctions, unique drops, delayed camera cancellation, presentation rebuilding and disposal. The full regression suite and both build modes must pass. Mocks cannot prove native XP, pathfinding or rendering.

Test in Warcraft:

1. Advance rapidly through Basics, then use Back/Topics. Old camera tours must stay cancelled; every camera move takes 1.5 seconds.
2. Compare the Archmages and use showcase +/−, skills and inventory. Lowering a level clears learned skills; leaving a scene removes its summons. Showcase heroes should not fill the F-key hero list.
3. Run the three XP-range tasks, then the three creep XP trials. Check actual hero XP before/after kills, the King's position, native creep factors and the ring. Back must recreate the task; ordinary Continue within a scene must preserve it.
4. Open both Optional topics, switch all XP display buttons, then return. Check caption/model visibility and the one-time XP quest cue.
5. Visit Items, buy from each shop and pick up ground items. Check stock, patron access, item group layout and cleanup on Back/exit.
6. Open native/custom menus and save/load during a task. Restore the same progress without duplicated units or sounds. Exit and open another tutorial to check shared camera, resources and ownership restoration.

The catalogue uses the authored Heroes tutorial artwork from `design/menu-art/heroes-tutorial-source.png`, fitted without cropping into a transparent DDS. The card draws it at 0.1152 by 0.0576 UI units (20% larger), anchored to the button’s top-right edge. Native color constants explicitly set Night Elf teal and Undead purple after hero initialization, with Human blue, Orc red and Tavern grey unchanged.
