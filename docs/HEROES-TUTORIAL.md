# Heroes tutorial scene

The user-authored tutorial has 47 main narration stops, eight Topics checkpoints, and two Optional topics: Attack Dice (three stops) and XP Numbers (two stops). Continue/Next advances narration; Back and Topics reconstruct the selected checkpoint. Optional returns to the main stop from which it was opened. The final page highlights Menu rather than creating an extra Topics checkpoint.

Human, Orc and Undead Altars occupy the top row, 900 units apart. Night Elf and Tavern occupy the bottom row, 600 units below, staggered beneath the gaps. Heroes are placed 200 units below their building, 150 units apart, in native command-grid order. Tavern heroes occupy two rows (five and four for the current roster), with the lower row 350 units below the first (200 units farther south than the initial layout).

Arena1 (south) contains this showcase; Arena2 (north) contains comparisons, XP tasks, optional displays and items. Buildings spawn before heroes. Initially all heroes are neutral passive and level 10, with abilities unspent. Colors are Human blue, Orc red, Night Elf teal, Undead purple and Tavern grey. Every camera move uses the shared 1.5-second duration.

Level controls appear only in the interactive hero showcase and Attack Dice display. Selecting a hero enables +/− within levels 1–10. Lowering a level recreates that hero with no spent skills and transfers its inventory. Target Dummies use the verified native archery-target model, are continuously healed, and show damage popups from actual damage events. Their display name and hover tooltip are “Target Dummie”. They have one Change Mode command: Stop depicts Neutral and Attack depicts Hostile. Clicking toggles the mode. Friendly dummies belong to the player; hostile dummies use a separate shared-control faction, whose hostility is restored on exit. They cannot move or attack, but remain unpaused so their commands work. Dummies default to Neutral. The two-Archmage attack comparison is Hostile through the attack-speed narration, then becomes Neutral on Continue; Back restores the scripted state. Heroes start with zero acquisition and Stop (the legacy Demo Mode passive setup); only the Archmage comparison receives automatic attack orders. Displayed heroes are vulnerable so their armor remains visible. Daytime is locked at noon and restored on exit. Level-1 spawns keep their native starting level; the + button follows legacy Demo Mode’s level-up operation with the XP lock temporarily released. The − button removes the old hero before creating its replacement, preserving coordinates.

XP tasks use native Warcraft XP awards, not scripted grants. The golden circle has a 1200-unit radius. Inactive showcase actors are disposed; returning recreates them, so inactive heroes cannot consume the player's XP share or leave spreading buildings behind. The army now spawns alongside the first task instruction. The three Mountain King trials distinguish level 4, attacking with the full army and both heroes (the level-5 King initially starts outside), and leaving the King outside XP range. The XP Quest follows the user's revised wording; the Solo Hero Bonus narration includes tier 3's +30%, and item destruction has its own three-attacks instruction line.

XP Numbers shows ten Paladins in two rows (levels 1–5 above 6–10), with Arthas hammer/Frostmourne skins at the ends. Racial lists exclude heroes and include defensive buildings, native forms and summons. A sixth selector, Neutral, shows 25 summon types/forms from Tavern heroes, in grey: Bears, Quilbeasts, Hawks, Lava Spawns, Dark Minions, Doom Guard, Pocket Factories, Clockwerk Goblins and the three Storm/Earth/Fire spirits. Unit IDs come from native summon ability fields; campaign-only fourth levels are excluded. Clockwerk Goblins retain their native level 0 and nominal 0 XP. Regular units are grouped by level and food. Summons appear below the column matching their level and the corresponding regular food cost, with separate food/XP labels. Columns begin at least 500 units farther inward than in alpha48 and are centered when there is room. Summon labels include the half-XP factor; actual integer rounding and distribution are engine behavior. The invulnerable Spirit of Vengeance is excluded, while the vulnerable Avatar remains. Summoned Doom Guard displays zero Food Cost. Summon captions have “Summon” on its own line and stand above the units, directly below the regular-unit captions. Attack Dice visits 2D4, 2D6, 2D12, then the midpoint between 2D11/3D10; each 1.5-second move is followed by a one-second pause before the next move. Items provides the racial shops, Merchant, Marketplace and 49 distinct Twisted Meadows drops, grouped by the smallest eligible camp/drop group, without group captions. Initial stock delays are removed for these item types and shops receive explicit stock.

The item-section dummy defaults to Neutral. Switching the comparison dummy to Neutral Mode stops the two Archmages' scripted attacks; Hostile Mode resumes that demonstration.

## Lifecycle, terrain and presentation

`src/activities/heroes-tutorial.lua` owns progression and presentation; `src/infrastructure/heroes-scenes.lua` owns scoped actors. Normal narration preserves the current scene. Back/Topics restore canonical checkpoint state. Menu hiding and frame reconstruction after load never replay setup, gathering, quest sounds or progression.

Player 6 is reserved for hostile Target Dummies. One-way shared control for player 0 is configured before play; the tutorial applies/restores hostility only. Native tests established that changing the control permission at runtime emits the upkeep cue. Food and XP-handicap changes were not its cause. Demonstration actors and tracked summons do not use food; existing XP handicap is normalized only when necessary and restored on exit.

Scene scopes clean up actors, summons, ground/picked-up items, labels, effects and timers. Foundation actors and borrowed camera, resources, time and hostility are restored on exit. Terrain baselines survive overlapping scenes. Ordinary replacement buildings permit departed blight cleanup without repainting their live ground; new blight sources and explicit terrain writers remain protected. Native alpha60 testing confirmed the correction.

XP groups containing buildings use grid-aligned centers and two rows with 576-unit spacing. Summon captions/actors have the additional 200-unit separation. Optional XP buildings are presentation-only copies without ground texture; stock gameplay buildings are unchanged. Attack Dice reads roster metadata independently of disposed showcase actors.

Topics and Optional use the shared popup helper with a separate Close footer. XP quest discovery happens once upon reaching Experience or opening XP Numbers, with the New Quest cue and native Quest-button flash; no duplicate custom glow is added.

## Authoring and data

- `design/tutorials/heroes-script.json`: authoritative narration, stable stop IDs and scene metadata.
- `design/tutorials/heroes-script-draft.txt`: corrected readable draft; original attachment preserved.
- `design/tutorials/heroes-script-decisions.md`: confirmed clarification answers.
- `src/data/heroes-tutorial-data.json`: native constants, hero stats, racial XP lists, shop stock, TM drops and provenance hashes.
- `tools/prepare-heroes-tutorial.cjs`: validates and generates `src/generated/heroes-tutorial.lua`; `--check` rejects drift.
- `tools/patch-heroes-dummy.cjs`: adds the named target object while retaining existing unit overrides, plus explicit Channel-based mode and armor commands in a new ability table. Packaging refuses to overwrite a pre-existing ability table without an explicit merge.

The native snapshot is from installed Warcraft III 3.0.0.24268 and the repository's Twisted Meadows v1.9 reference. The approved narration gives the level-five cutoff; the Quest lists the native creep factors (80/70/60/50/0 percent). Spell reduction and fractional attribute data are unchanged.

`tools/heroes-presentation.cjs` derives presentation building IDs, preserves native/map overrides while removing their ground texture, and establishes dummy control during map configuration.

## Target Dummy controls

The named Target Dummie uses lowercase unit ID `jHdm`, based on a Footman, rather than the former uppercase hero-style ID. The name is set in native object data and at runtime. Dummies start with Heavy type and zero armor. Change Armor Type occupies the middle-left command cell, cycling Unarmed (native defense index 7), Light, Medium, Heavy, Building and Hero. Its icon shows the current type. Raise Armor and Lower Armor occupy the middle-right and bottom-right cells with gold plus/minus icons, changing armor by one, including negative values. Armor changes are per dummy and survive its regeneration/recreation; neutral/hostile mode remains independent. When changing these controls, test native hover names, hero counting and actual damage mitigation in Warcraft.

Hero armor uses the native 30% spell-damage reduction. Only that type also gains requirement-free native Resistant Skin (`ACsk`) for hero-duration negative effects and native ability immunities; changing to another type removes it. Its passive icon is hidden so it cannot occupy Raise Armor's command cell. The dummy remains a normal unit, and no extra spell-damage reduction is stacked.

The six armor buttons use the user-supplied square artwork in `design/menu-art/dummy-armor/`, converted without cropping to 128px DDS by `tools/prepare-dummy-icons.py`. Number boxes are absent. Tooltips use the command name as title and `Current: ...` below the native divider. Mode/type descriptions follow their per-state ability objects; Raise/Lower Armor descriptions are set on each dummy's own ability handle to preserve independent numeric values. Native tooltip refresh should be checked when changing the control objects.

## Validation and future maintenance

The tutorial is included in the accepted v0.2.0 release. Fixtures cover authored scene/XP decisions, world ownership and cleanup, level controls, menus, source reservations and native-object preservation. Native tests identified the control notification and confirmed the subsequent audio/control, ground presentation and blight corrections. This does not imply exhaustive save/load or combat acceptance.

When modifying the tutorial, check rapid Continue/Back/Topics around encounters, both optional branches and all XP selectors; native XP awards and damage/armor behavior; dummy controls in both modes; shop access; Menu/Resume; save/load; and exit/re-entry cleanup. Preserve the authored progression and current accepted behavior.

Earlier findings, attempts and checklists remain in [implementation history](archive/v0.2.0/HEROES-IMPLEMENTATION-HISTORY.md) and [the archived alpha handoffs](archive/v0.2.0/README.md).
