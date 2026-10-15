# Heroes tutorial scene

The user-authored tutorial has 47 main narration stops, eight Topics checkpoints, and two Optional topics: Attack Dice (three stops) and XP Numbers (two stops). Continue/Next advances narration; Back and Topics reconstruct the selected checkpoint. Optional returns to the main stop from which it was opened. The final page highlights Menu rather than creating an extra Topics checkpoint.

Human, Orc and Undead Altars occupy the top row, 900 units apart. Night Elf and Tavern occupy the bottom row, 600 units below, staggered beneath the gaps. Heroes are placed 200 units below their building, 150 units apart, in native command-grid order. Tavern heroes occupy two rows (five and four for the current roster), with the lower row 350 units below the first (200 units farther south than the initial layout).

Arena1 (south) contains this showcase; Arena2 (north) contains comparisons, XP tasks, optional displays and items. Buildings spawn before heroes. Initially all heroes are neutral passive and level 10, with abilities unspent. Colors are Human blue, Orc red, Night Elf teal, Undead purple and Tavern grey. Every camera move uses the shared 1.5-second duration.

Level controls appear only in the interactive hero showcase and Attack Dice display. Selecting a hero enables +/− within levels 1–10. Lowering a level recreates that hero with no spent skills and transfers its inventory. Target Dummies use the verified native archery-target model, are continuously healed, and show damage popups from actual damage events. Their display name and hover tooltip are “Target Dummie”. They have one Change Mode command: Stop depicts Neutral and Attack depicts Hostile. Clicking toggles the mode. Friendly dummies belong to the player; hostile dummies use a separate shared-control faction, whose alliances are restored on exit. They cannot move or attack, but remain unpaused so their commands work. Dummies default to Neutral. The two-Archmage attack comparison is Hostile through the attack-speed narration, then becomes Neutral on Continue; Back restores the scripted state. Heroes start with zero acquisition and Stop (the legacy Demo Mode passive setup); only the Archmage comparison receives automatic attack orders. Displayed heroes are vulnerable so their armor remains visible. Daytime is locked at noon and restored on exit. Level-1 spawns keep their native starting level; the + button follows legacy Demo Mode’s level-up operation with the XP lock temporarily released. The − button removes the old hero before creating its replacement, preserving coordinates.

XP tasks use native Warcraft XP awards, not scripted grants. The golden circle has a 1200-unit radius. Inactive showcase heroes are hidden, neutral-owned and XP-suspended, so they do not consume the player's XP share. The army now spawns alongside the first task instruction. The three Mountain King trials distinguish level 4, attacking with the full army and both heroes (the level-5 King initially starts outside), and leaving the King outside XP range. The XP Quest follows the user's revised wording; the Solo Hero Bonus narration includes tier 3's +30%, and item destruction has its own three-attacks instruction line.

XP Numbers shows ten Paladins at levels 1–10, with Arthas hammer/Frostmourne skins at the ends. Racial lists exclude heroes and include defensive buildings, native forms and summons. A sixth selector, Neutral, shows 25 summon types/forms from Tavern heroes, in grey: Bears, Quilbeasts, Hawks, Lava Spawns, Dark Minions, Doom Guard, Pocket Factories, Clockwerk Goblins and the three Storm/Earth/Fire spirits. Unit IDs come from native summon ability fields; campaign-only fourth levels are excluded. Clockwerk Goblins retain their native level 0 and nominal 0 XP. Regular units are grouped by level and food. Summons appear below the column matching their level and the corresponding regular food cost, with separate food/XP labels. Columns begin at least 500 units farther inward than in alpha48 and are centered when there is room. Summon labels include the half-XP factor; actual integer rounding and distribution are engine behavior. The invulnerable Spirit of Vengeance is excluded, while the vulnerable Avatar remains. Summoned Doom Guard displays zero Food Cost. Summon captions have “Summon” on its own line and stand above the units, directly below the regular-unit captions. Attack Dice visits 2D4, 2D6, 2D12, then the midpoint between 2D11/3D10; each 1.5-second move is followed by a one-second pause before the next move. Items provides the racial shops, Merchant, Marketplace and 49 distinct Twisted Meadows drops, grouped by the smallest eligible camp/drop group, without group captions. Initial stock delays are removed for these item types and shops receive explicit stock.

The item-section dummy defaults to Neutral. Switching the comparison dummy to Neutral Mode stops the two Archmages' scripted attacks; Hostile Mode resumes that demonstration.

## Standard lifecycle

`src/activities/heroes-tutorial.lua` owns progression and presentation. `src/infrastructure/heroes-scenes.lua` owns scoped world actors. Both use the shared Tutorial runner, guarded delayed actions and checkpoint restoration. Normal narration within a scene preserves actors and player actions. Back/Topics explicitly restore canonical scene state. Opening a menu or rebuilding presentation after load does not respawn actors, replay the quest sound or restart progression.

Scene scopes clean up units, summons, items (including picked-up items), text tags, images and timers. Foundation units are borrowed and parked during the tutorial. Camera, resources, XP handicap and hostile relationships are restored on exit. The optional XP quest is discovered once, when reaching Experience or opening XP Numbers, with the retained New Quest cue.

## Authoring and data

- `design/tutorials/heroes-script.json`: authoritative narration, stable stop IDs and scene metadata.
- `design/tutorials/heroes-script-draft.txt`: corrected readable draft; original attachment preserved.
- `design/tutorials/heroes-script-decisions.md`: confirmed clarification answers.
- `src/data/heroes-tutorial-data.json`: native constants, hero stats, racial XP lists, shop stock, TM drops and provenance hashes.
- `tools/prepare-heroes-tutorial.cjs`: validates and generates `src/generated/heroes-tutorial.lua`; `--check` rejects drift.
- `tools/patch-heroes-dummy.cjs`: adds the named target object while retaining existing unit overrides, plus explicit Channel-based mode and armor commands in a new ability table. Packaging refuses to overwrite a pre-existing ability table without an explicit merge.

The native snapshot is from installed Warcraft III 3.0.0.24268 and the repository's Twisted Meadows v1.9 reference. The approved narration gives the level-five cutoff; the Quest lists the native creep factors (80/70/60/50/0 percent). Spell reduction and fractional attribute data are unchanged.

## Verification and in-game acceptance

The Heroes fixture exercises actual shared scopes/guards with explicit native mocks: all scenes, level controls, optional return, race colors, XP setup distinctions, unique drops, delayed camera cancellation, presentation rebuilding and disposal. The full regression suite and both build modes must pass. Mocks cannot prove native XP, pathfinding or rendering.

Test in Warcraft:

1. Advance rapidly through Basics, then use Back/Topics. Old camera tours must stay cancelled; every camera move takes 1.5 seconds.
2. Compare the Archmages and use showcase +/−, skills and inventory. Lowering a level clears learned skills; leaving a scene removes its summons. Showcase heroes should not fill the F-key hero list.
3. Run the three XP-range tasks, then the three creep XP trials. Check actual hero XP before/after kills, the King's position, native creep factors and the ring. Back must recreate the task; ordinary Continue within a scene must preserve it.
4. Open both Optional topics, switch all XP display buttons, then return. Check caption/model visibility and the one-time XP quest cue.
5. Select friendly/hostile dummies and use both native command buttons. Confirm the hover name, damage numbers in both modes, and no automatic showcase attacks. Revisit via Back/Topics and save/load to check mode preservation versus canonical scene reset.
6. Visit Items, buy from each shop and pick up ground items. Check stock, patron access, item group layout and cleanup on Back/exit.
7. Open native/custom menus and save/load during a task. Restore the same progress without duplicated units or sounds. Exit and open another tutorial to check shared camera, resources and ownership restoration.

The catalogue uses the authored Heroes tutorial artwork from `design/menu-art/heroes-tutorial-source.png`, fitted without cropping into a transparent DDS. The card draws it at 0.1152 by 0.0576 UI units (20% larger), anchored to the button’s top-right edge. Native color constants explicitly set Night Elf teal and Undead purple after hero initialization, with Human blue, Orc red and Tavern grey unchanged.

## Target Dummy controls (alpha51)

Alpha55 excludes tutorial actors and tracked summons from food usage to prevent unintended upkeep transitions. It preserves their native combat stats and authored food-cost reference captions. Heroes Topics/Optional popups now match the established tutorial panel width, button sizes/spacing and separate Close footer, without extra titles. Quest discovery uses one native `FlashQuestDialogButton` call; the duplicate custom Quest sprite is removed. Native audio/highlight acceptance remains outstanding.

Follow-up: the user accepted the menu/highlight changes but still heard the upkeep chime on entry and exit. Source now leaves food-cap states untouched and skips XP-handicap setters when the current rate already equals the desired value; a genuinely different XP rate is still temporarily normalized and restored. The native sound result remains unverified. Optional XP Numbers presents Paladins at levels 1–5 in the upper row and 6–10 in the lower row, with individual XP captions beneath them and the existing Arthas endpoint skins retained.

The named Target Dummie uses lowercase unit ID `jHdm`, based on a Footman, rather than the former uppercase hero-style ID. The name is set in native object data and at runtime. Dummies start with Heavy type and zero armor. Change Armor Type occupies the middle-left command cell, cycling Unarmed (native defense index 7), Light, Medium, Heavy, Building and Hero. Its icon shows the current type. Raise Armor and Lower Armor occupy the middle-right and bottom-right cells with gold plus/minus icons, changing armor by one, including negative values. Armor changes are per dummy and survive its regeneration/recreation; neutral/hostile mode remains independent. Native hover names, hero counting and actual damage mitigation still require Warcraft testing.

Hero armor uses the native 30% spell-damage reduction. Only that type also gains requirement-free native Resistant Skin (`ACsk`) for hero-duration negative effects and native ability immunities; changing to another type removes it. Its passive icon is hidden so it cannot occupy Raise Armor's command cell. The dummy remains a normal unit, and no extra spell-damage reduction is stacked.

The six armor buttons use the user-supplied square artwork in `design/menu-art/dummy-armor/`, converted without cropping to 128px DDS by `tools/prepare-dummy-icons.py`. Number boxes are absent. Tooltips use the command name as title and `Current: ...` below the native divider. Mode/type descriptions follow their per-state ability objects; Raise/Lower Armor descriptions are set on each dummy's own ability handle to preserve independent numeric values. Native tooltip refresh remains an acceptance check.
