# Hotkey audit failure analysis — alpha28

Historical diagnostic record. Preserve the findings below; its alpha-specific setup is not the current exercise specification. See [Hotkey Trainer](HOTKEY-TRAINING.md) for current behavior and [development status](DEVELOPMENT-STATUS.md) before scheduling another audit.

All 652 command IDs completed at least one trial. 583 produced activation evidence; 57 never produced activation evidence and 12 lacked a supported automation binding.
All 42 Stop controls produced both native and trainer confirmations. No command had a recorded native action that the trainer missed. This does not prove every targeted ability can complete its effect: activation-only confirms a button, not a target or placement.

## Findings

- Neutral buildings account for 32 failures: 24 hires and eight purchases. The native stock call is already shared and supplies current stock=1. Stock timers alone are not established as the cause. Check neutral ownership, patron selection, displayed availability and actual button identity together.
- Engineering Upgrade uses PASBTNEngineeringUpgrade and is passive. It belongs in Ability Choice, not the active ability rotation.
- Destroyer Form must be tested from an Obsidian Statue, not an already transformed Destroyer.
- Corpse handling, unloading, replenishing, coupling and garrison commands need prepared context. The current generic source/mana preparation is insufficient to prove these.
- Tinker learns Engineering Upgrade level 3, which changes its other abilities. The test registers the base ability IDs; upgraded identities need checking.
- Raise Dead failed once and worked once. Ritual Dagger worked once and failed once. These are additional inconsistent cases even though each activated at least once.
- Other native-versus-activation-only differences are not hotkey failures.

## Next targeted verification

First correct the passive/morph/context data. Then inspect one neutral purchase and one hire with the native button visible; apply the verified shared fix to the group. Only the repaired cases and unresolved commands need another audit. Missing CustomKeys entries require a separately verified key or a physical test.

## Context-dependent commands — missing preparation to investigate (9)

| Source | Command | ID | Trials |
|---|---|---|---|
| Zeppelin | Unload | `neutral.nzep.ability.Adro` | 1 |
| Hippogryph | Pick up Archer | `nightelf.ehip.ability.Aco3` | 1 |
| Moon Well | Replenish Mana and Life | `nightelf.emow.ability.Ambt` | 2 |
| Burrow | Stand Down | `orc.otrb.ability.Astd` | 1 |
| Crypt Lord | Carrion Beetles | `undead.Ucrl.ability.AUcb` | 1 |
| Acolyte | Sacrifice | `undead.uaco.ability.Alam` | 1 |
| Destroyer | Absorb Mana | `undead.ubsp.ability.Aabs` | 1 |
| Meat Wagon | Drop Corpse | `undead.umtw.ability.Amed` | 2 |
| Meat Wagon | Get Corpse | `undead.umtw.ability.Amel` | 1 |

## Unsupported automated binding — not a failed game input (12)

| Source | Command | ID | Trials |
|---|---|---|---|
| Goblin Merchant | Select User | `common.ngme.common.select` | 1 |
| Forest Troll Trapper | Ensnare | `neutral.nftt.ability.ACen` | 2 |
| Granite Golem | Slam | `neutral.nggr.ability.ACtc` | 1 |
| Ice Troll High Priest | Frost Armor | `neutral.nith.ability.ACf2` | 1 |
| Ice Troll Trapper | Ensnare | `neutral.nitt.ability.ACen` | 1 |
| Murloc Huntsman | Ensnare | `neutral.nmrr.ability.ACen` | 1 |
| Ogre Lord | Shockwave | `neutral.nogl.ability.ACsh` | 1 |
| Wendigo Shaman | Rejuvenation | `neutral.nwns.ability.ACrj` | 1 |
| Wendigo Shaman | Roar | `neutral.nwns.ability.ACro` | 2 |
| Dire Frost Wolf | Roar | `neutral.nwwd.ability.ACro` | 1 |
| Renegade Wizard | Lightning Shield | `neutral.nwzg.ability.ACls` | 2 |
| Rogue Wizard | Frost Armor | `neutral.nwzr.ability.ACf2` | 1 |

## Neutral shop purchases and hires — shared cause unconfirmed (32)

| Source | Command | ID | Trials |
|---|---|---|---|
| Goblin Laboratory | Shredder | `neutral.ngad.hire.ngir` | 2 |
| Goblin Laboratory | Sapper | `neutral.ngad.hire.ngsp` | 1 |
| Goblin Laboratory | Zeppelin | `neutral.ngad.hire.nzep` | 1 |
| Goblin Merchant | Boots of Speed | `neutral.ngme.buy.bspd` | 1 |
| Goblin Merchant | Potion of Invisibility | `neutral.ngme.buy.pinv` | 1 |
| Goblin Merchant | Potion of Lesser Invulnerability | `neutral.ngme.buy.pnvl` | 1 |
| Goblin Merchant | Scroll of Healing | `neutral.ngme.buy.shea` | 1 |
| Goblin Merchant | Scroll of Protection | `neutral.ngme.buy.spro` | 1 |
| Goblin Merchant | Staff of Teleportation | `neutral.ngme.buy.stel` | 1 |
| Goblin Merchant | Scroll of Town Portal | `neutral.ngme.buy.stwp` | 1 |
| Goblin Merchant | Tome of Retraining | `neutral.ngme.buy.tret` | 1 |
| Mercenary Camp | Forest Troll Shadow Priest | `neutral.nmer.hire.nfsp` | 1 |
| Mercenary Camp | Forest Troll Berserker | `neutral.nmer.hire.nftb` | 2 |
| Mercenary Camp | Mud Golem | `neutral.nmer.hire.ngrk` | 2 |
| Mercenary Camp | Ogre Mauler | `neutral.nmer.hire.nogm` | 1 |
| Mercenary Camp | Gnoll Brute | `neutral.nmr2.hire.ngnb` | 1 |
| Mercenary Camp | Gnoll Warden | `neutral.nmr2.hire.ngnw` | 2 |
| Mercenary Camp | Mud Golem | `neutral.nmr2.hire.ngrk` | 1 |
| Mercenary Camp | Ogre Magi | `neutral.nmr2.hire.nomg` | 1 |
| Mercenary Camp | Mud Golem | `neutral.nmr3.hire.ngrk` | 1 |
| Mercenary Camp | Ice Troll Priest | `neutral.nmr3.hire.nitp` | 2 |
| Mercenary Camp | Ice Troll Berserker | `neutral.nmr3.hire.nits` | 1 |
| Mercenary Camp | Ogre Mauler | `neutral.nmr3.hire.nogm` | 1 |
| Tavern | Alchemist | `neutral.ntav.hire.Nalc` | 1 |
| Tavern | Dark Ranger | `neutral.ntav.hire.Nbrn` | 2 |
| Tavern | Beastmaster | `neutral.ntav.hire.Nbst` | 1 |
| Tavern | Firelord | `neutral.ntav.hire.Nfir` | 1 |
| Tavern | Sea Witch | `neutral.ntav.hire.Nngs` | 2 |
| Tavern | Forsaken Paladin | `neutral.ntav.hire.Npal` | 2 |
| Tavern | Brewmaster | `neutral.ntav.hire.Npbm` | 2 |
| Tavern | Pit Lord | `neutral.ntav.hire.Nplh` | 2 |
| Tavern | Tinker | `neutral.ntav.hire.Ntin` | 1 |

## Other commands requiring focused investigation (14)

| Source | Command | ID | Trials |
|---|---|---|---|
| Tree of Life | Take Root | `common.etol.common.root` | 1 |
| Tree of Life | Uproot | `common.etol.common.uproot` | 1 |
| Peasant | Gather | `common.hpea.common.gather` | 2 |
| Tinker | Cluster Rockets | `neutral.Ntin.ability.ANcs` | 1 |
| Tinker | Pocket Factory | `neutral.Ntin.ability.ANsy` | 2 |
| Forest Troll High Priest | Heal | `neutral.nfsh.ability.Anh2` | 2 |
| Forest Troll Shadow Priest | Heal | `neutral.nfsp.ability.Anh1` | 1 |
| Granite Golem | Hurl Boulder | `neutral.nggr.ability.ACtb` | 1 |
| Ice Troll High Priest | Heal | `neutral.nith.ability.Anh2` | 2 |
| Ice Troll Priest | Heal | `neutral.nitp.ability.Anh1` | 1 |
| Kobold Geomancer | Slow | `neutral.nkog.ability.ACsw` | 1 |
| Priestess of the Moon | Searing Arrows | `nightelf.Emoo.ability.AHfa` | 1 |
| Barracks | Headhunter | `orc.obar.train.ohun` | 1 |
| Dreadlord | Inferno | `undead.Udre.ability.AUin` | 1 |

## Confirmed catalogue error — passive ability listed as active (1)

| Source | Command | ID | Trials |
|---|---|---|---|
| Tinker | Engineering Upgrade | `neutral.Ntin.ability.ANeg` | 1 |

## Wrong transformation state — Destroyer already transformed (1)

| Source | Command | ID | Trials |
|---|---|---|---|
| Destroyer | Destroyer Form | `undead.ubsp.ability.Aave` | 1 |
