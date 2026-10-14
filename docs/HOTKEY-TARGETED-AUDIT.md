# Alpha30 targeted hotkey audit

Historical diagnostic record. Preserve the findings below; its alpha-specific setup is not the current exercise specification. See [Hotkey Trainer](HOTKEY-TRAINING.md) for current behavior and [development status](DEVELOPMENT-STATUS.md) before scheduling another audit.

Alpha31 follow-up: 44 unresolved commands, three repetitions plus controls
(144 trials, roughly 10 minutes). Neutral sources are restricted to the specified
shops and the heroes/mercenaries actually sold by them. Sellable units/items have dev-only object-data
stock-start delays of zero. Autocasting Heal is disabled before preparing its
target, and native actions before forced input are recorded but not counted as
input confirmations. Previous reports are archived before the next audit.

Start Hotkey Training with any race, enter `-hotkey-targeted-audit`, then close
chat. Leave Warcraft foreground and avoid clicking units during the audit.

The plan contains 101 repaired/unresolved command IDs, three repetitions and
Stop controls (324 trials). Expected running time is approximately 25 minutes.
Results are saved automatically as `JTG-Hotkey-Targeted-Audit.pld` and numbered
batches in CustomMapData. Full-audit reports are preserved.

Changes being checked:

- Neutral shops use neutral passive ownership. Sale observers listen to both
  trainee and neutral events, including hired units.
- Tavern recruitment has a tier-three main building, altar and lifted hero limits.
- Tinker active prompts and binding lookup use ANs3/ANc3 after Engineering Upgrade.
- Tree of Life Root/Uproot use its actual Aro1 ability, rather than generic Aroo.
- Headhunter preparation temporarily clears Berserker Upgrade and restores it on exit.
- Corpse commands receive corpses; Drop Corpse attempts to load one first.
- Zeppelin Unload attempts to load a passenger; Stand Down attempts to garrison a Peon.
- Pickup receives an Archer; Sacrifice gets a nearby Pit; heal/replenish receives an
  injured ally; Absorb Mana receives a mana donor; Gather gets a nearby mine.
- Eat Tree begins uprooted; Hide uses night time.

The audit records preparation order acceptance separately from actual tested
activation. Mock tests cannot prove boarding or corpse loading completed.
Persistent failures still need interpretation from the returned game data.

Automation uses current CustomKeys entries. If an entry is absent, it uses the
installed native default, rather than guessing a standard or grid layout key.
Explicitly blank custom bindings remain unsupported.

Use `-hotkey-full-audit-end` to stop and save. The full-audit command continues
to exclude already completed command IDs.

## Alpha33 expanded check

The targeted pool has 31 commands: the 11 unresolved alpha32 cases plus 20 regression cases covering Build, unit training, research (including levels 2 and 3), purchases, hiring, upgrades, active abilities and Ability Choice. Historically problematic Grunt, Batrider, Pillage, Spiked Barricades, Clarity, Scroll of Speed, Berserk, Devour, altar/Tavern heroes, and Eat Tree are included. Three passes plus nine Stop controls produce 102 trials, approximately 7–8 minutes.

The audit prepares uprooted Ancient sources in the background when it begins, regardless of the chosen practice race. Native correct events remain available for correlation when the keyboard notification arrives later; alpha32's Heal failures were reporting false negatives caused by consuming the earlier correct event. Button, execution and trainer evidence remain separate.

Alpha33 completed all 102 trials, with all nine Stop controls healthy. Both Heal cases were confounded by enabled autocast; the timing fix above does not establish that those hotkeys activated Heal. Six Ancient trials were blocked by the readiness check and should be classified as setup errors rather than hotkey failures. The follow-up implementation corrects the neutral Heal off/activation orders and uses the Ancient's dynamic building flag and native transition duration for readiness.

## Alpha34 focused verification

Ten commands, three repetitions and six Stop controls: 36 trials, approximately three minutes. The pool is the two neutral Heals, Priest Heal, Take Root, Uproot, Eat Tree from Tree of Life and Ancient Protector, Moon Well recharge, Searing Arrows, and Firelord Incinerate. Start with `-hotkey-targeted-audit` inside Hotkey Training; results save automatically. Any expected spell cast before the test input makes an autocast case inconclusive. The report logs the Ancient's building flag and last order when preparation becomes ready. Readiness and accepted autocast-off setup remain separate from actual hotkey evidence.

Alpha34 completed all 36 trials. All six Stop controls passed; there were no setup errors or pre-input casts. Nine commands registered activation in all three passes: eight target-selection commands had both button and trainer evidence without execution, and Uproot also executed. Ancients reported building=false at readiness. All three Heal contexts accepted their autocast-off order. Other off orders returned false, so their return values alone do not prove a toggle-state change.

Forest Troll Shadow Priest Heal had no activation in all three passes. The current CustomKeys entries for Anh1 (Heal) and ACdm (Abolish Magic) both set Buttonpos/Unbuttonpos=0,0 and Hotkey/Unhotkey=Q. Both abilities exist on nfsp, creating a command-cell and key collision. The Ice Troll Priest has only Heal and passed. Preserve the player's layout; this needs a layout-conflict policy rather than another autocast fix. Latest raw records are archived in work/hotkey-alpha34-complete, using only the two batches named by the manifest. Older numbered batches remaining in CustomMapData belong to earlier audits.
