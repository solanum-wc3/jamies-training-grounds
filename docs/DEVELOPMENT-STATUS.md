# Development checkpoint: v0.1.3-alpha59

Updated 15 October 2026. The public release remains v0.1.2-beta1; its download links and v0.1.2 patch notes are unchanged. Alpha59 is a testing build, not a completed milestone or a public release.

## Alpha59: confirmed sound source and presentation ground

The user confirms both direct shared-control changes chime, while no-control Heroes entry/exit is silent. Earlier food/XP theories did not identify this native permission notification. Configure player 6 -> player 0 shared control before play; remove runtime Heroes permission writes while preserving scoped hostility and usable hostile dummy commands. Optional XP Numbers now uses presentation-only building copies with no ground texture; stock objects and other activities are unchanged. Alpha58 cleared blight in the tested transition; the remaining dirt was under Human buildings. See [alpha59 testing](ALPHA59-TESTING.md). Native config persistence, initial-load/entry/exit sound, grass and dummy controls still require testing.

Source/data checks, all 45 Lua regression fixtures and release/development packaging pass. Development map: `outputs/Jamies-Training-Grounds-v0.1.3-alpha59-dev.w3x`, SHA256 `97ebe43e4deed90a755ba46f0412ecb19a6cd3231f9742210e85f936771bba85`. Source remains on `codex/alpha49-checkpoint`; prior alpha58 checkpoint is `df4b857`.

## Alpha58: focused native follow-up

Alpha57 feedback confirms the UpkeepLevel sound on no-button Heroes entry and exit, and inconsistent blight cleanup specifically when leaving Undead XP Numbers. Its native trace keeps player food at zero and XP handicap at 1; previous food/XP changes did not resolve the sound. A development-only shared-control probe and a Heroes entry omitting just that setting isolate the next candidate without changing normal dummy behavior. See [alpha58 testing](ALPHA58-TESTING.md).

Terrain restoration now retains released baselines through next-tick and half-second checks, records native blight differences, and guards replacement scenes by generation. Mock regressions cover late writes and reacquisition of dirty ground; native verification remains outstanding. Alpha57 is checkpointed at `8db4fac` on `codex/alpha49-checkpoint`.

## Alpha57: shared cleanup/layout and Heroes diagnostics

Heroes' upkeep chime remains unresolved. Earlier changes inferred food/XP causes without isolating native audio; mock checks cannot establish the source of a sound. A development-only diagnostic now starts/stops Heroes without button audio, logs actual XP/food and unit coordinates, and offers separately labelled button/upkeep sound samples. See [focused testing](ALPHA57-TESTING.md).

Racial XP displays use larger, grid-aligned building cells and 200 more units of separation before summon captions. Topics/Optional/Setups use one popup layout helper. Terrain snapshots belong to actor scopes, preserve original tiles/variation/blight, and restore after spreading buildings are removed; overlapping scene scopes share ownership. Obsolete Heroes showcase actors are disposed instead of hidden so their buildings cannot keep spreading blight. Attack Dice reads roster metadata independently of those actors.

Source checks, generated-data checks, all 45 Lua regression fixtures, release maintenance packaging and development packaging pass. Native sound diagnosis, building placement, grass/blight rendering, popup appearance and save/load checks remain outstanding. Alpha56 source was checkpointed at `f19736e`; alpha57 changes are on `codex/alpha49-checkpoint`.

Development output: `outputs/Jamies-Training-Grounds-v0.1.3-alpha57-dev.w3x`, 4,337,872 bytes, SHA256 `a3b7f5c55f27546cc53265635b01b0b39f022c5274914b8531a4bfc4d8d80edc`.

## Source and distributed build

The `codex/alpha49-checkpoint` branch preserves the development accumulated since the last source checkpoint at alpha8. This is a current snapshot, not a reconstruction of separate historical alpha commits. No merge into `main` or push is implied by making this checkpoint.

The distributed development map is `Jamies-Training-Grounds-v0.1.3-alpha56-dev.w3x`, copied to the user's Warcraft map folder. Its SHA-256 is `2a77b643152f1160be28f7d65370980c1a49f91bda292118d815cd6ef1bbdb47`. Earlier alpha55 and previous alpha files remain unchanged. Maintenance validation belongs under `work/`; never replace a distributed file with different contents under the same version.

Development packages can include local diagnostic binding/history files from ignored `work/`. A fresh checkout uses committed empty defaults instead; automated Hotkey audits require explicitly prepared local bindings. Ordinary Hotkey gameplay always uses Warcraft's current native bindings. A different local audit fixture can therefore change a development map's hash without changing production gameplay.

## Changes included in alpha56

Implemented, uncommitted and awaiting native testing: the user confirmed the upkeep chime still occurs on entry/exit, while other tested Heroes presentation changes appear satisfactory. Remove unnecessary food-cap setup/restore writes and avoid resetting an already-correct XP handicap; tests cover unchanged/default and non-default XP rates through cleanup. The optional Paladin XP display now has two rows of five, ascending left-to-right, upper then lower. Native sound verification remains outstanding; do not call this fixed based on mocks alone. Alpha56 passes all 42 fixtures and development packaging. Test entry/exit audio, the two Paladin rows with captions, and exit/re-entry cleanup.

## Changes included in alpha55

Heroes tutorial actors and tracked summons no longer use food, preventing unintended upkeep transitions without changing their combat stats or authored reference captions. Topics/Optional now match established tutorial popup geometry, omit extra title labels and give Close a separate footer. Quest discovery uses only the native flash; the duplicate custom glow and its timer state are removed. All 42 regression fixtures, source/data checks and development packaging pass. Native sound, menu appearance and highlight alignment remain awaiting acceptance. Source changes remain uncommitted on `codex/alpha49-checkpoint`. See [alpha55 testing](ALPHA55-TESTING.md).

## Alpha53 crash correction

The user reported native crashes on both Human and Orc Mining selectors in alpha52. The local crash report records a native null-pointer read; the precise native call is not symbolized. Alpha53 removes the suspect null/repeated tooltip attachments introduced in alpha52: rectangular choices now attach once at creation, matching the established icon-menu path, and hide empty descriptions through alpha. Repeated race/mode page transitions are covered by regression fixtures which reject null/repeated attachments. Native verification is still required. Test both race buttons and Back/re-entry before continuing Build Order tests below.

## Changes included in alpha54

User-supplied armor command artwork replaces the infocard textures with number boxes. Target Dummies have one current-mode toggle, nonduplicated current-state tooltips, and default to Neutral. The Archmage comparison switches to Neutral after the attack-speed narration, with Back restoring its scripted state. Build Order now handles building right-click rallies and reads native rally targets at worker completion. Shift-queue fidelity remains a known limitation. These changes are uncommitted and require native verification. The approved 0.2.0 patch note is included as Upcoming; the public release and links are unchanged.

## Changes included in alpha52

Alpha52 includes: XP Numbers paragraph spacing;
hover tooltips for rectangular briefing choices, including the Mining modes;
native start/completion confirmation and idle retry for copied Build Order
training; and cancellation of Build/Hero Abilities submenus after incorrect
Hotkey answers. Automated checks cover these changes; native acceptance remains
outstanding. See [the alpha52 test list](ALPHA52-TESTING.md). These source fixes are currently uncommitted.

## Changes included in alpha51

Hotkey transformation prompts now distinguish starting form, destination icon and forward/return commands for Spirit Walker, Druids, Gargoyle, Crypt Fiend and Tinker. One-way morphs remain forward-only. Return prompts prepare a real native transformation and wait for completion before accepting answers. See [Hotkey Trainer](HOTKEY-TRAINING.md#transformation-commands). These changes are included in alpha51; native form/button checks remain outstanding.

Alpha51 also includes Mining Micro's two-base Build Order comparison, revised briefings/tooltips, red indented player statistics and the four-field end card; normal scoped melee hero limits/tokens; normal-unit Target Dummies with independent armor controls; the approved creep-XP wording; and the added Reflex briefing paragraph. See [the focused test list](ALPHA51-TESTING.md). The prior hero-style dummy ID is removed; test first-hero recruitment again in a fresh game.

## Included work

- Five tutorials and ten accessible exercises/demonstrations, including Heroes, Reflex Training (WIP) and Hotkey Trainer. See [activity catalogue](ACTIVITIES.md).
- Shared tutorial scene/visit lifetimes, stable checkpoint navigation, guarded delayed actions, fixed camera movement and presentation-only menu/load reconstruction.
- Hotkey command catalogue, prerequisite/context preparation, native recognition, staged practice and missed-command review. Automated comparison/audit tools remain development-only.
- Reflex race selection, crowd layouts, population limits, staged identification, buff/debuff recognition and shared score presentation.
- Timed/Unlimited Mining Micro, setup labels and Quest help hints, shared cleanup/presentation improvements and revised sound cues.
- The authored 47-stop Heroes tutorial, optional Attack Dice and XP displays, hero controls and staged XP practice. Alpha49 includes the latest wording/layout changes, daytime lock, native level-1 spawning, revised +/− behavior, damage popups, Quest availability and defensive-building/Neutral-summon XP displays.

Detailed behavior remains in the relevant activity documents. Historical audits and dated consolidation reviews record earlier evidence, not acceptance of later changes.

## Verification and acceptance

Alpha51 passes 42 Lua regression fixtures, 31-module release / 47-module development assembly, authored briefing/Heroes/native-object checks, clean-checkout inputs, stock-delay preservation and both packaging modes. All six armor textures were verified in installed CASC. Warcraft acceptance remains outstanding.

Alpha50 passed Lua assembly validation, authored-briefing/data checks, 42 Lua regression fixtures and both packaging modes. Fresh-checkout build inputs and stock-delay preservation are checked separately. These validate source, resource ownership, navigation and packaging; they do not establish Warcraft engine behavior.

The subsequent [15 October source review](RELIABILITY-REVIEW-2026-10-15.md) extends the suite to 41 fixtures and corrects Reflex's Night Elf/Undead palette in source. Its maintenance builds are isolated under `work/`; the installed alpha49 remains unchanged. Wording proposals and conditional presentation/reset findings are recorded for review, not silently applied. The follow-up [legacy Demo Mode assessment](DEMO-MODE-PORT-REVIEW.md) is planning only.

The user is testing alpha56. Use [the alpha55 test list](ALPHA55-TESTING.md) first; these earlier tutorial checks also remain relevant:

Alpha50 includes the approved Heroes revision (paced Dice tour, selectable dummy modes, XP/item text and display corrections) and Mining Micro's Base Build mode plus shared labels/trees. See [Heroes](HEROES-TUTORIAL.md) and [Mining modes](MINING-MICRO-MODES.md). Prioritize native dummy command-grid/hover behavior, summon caption placement, Base Build's fifth-worker mine entry, and spending-independent gathered totals. It also includes the approved wording corrections, gold Input cues, Windwalk hidden-result safeguard and Gargoyle deferred reset.

1. Heroes: both comparison Archmages have levels 1/10; +/− work, preserve position/inventory and clear skills when lowering. Armor is visible and Night Elf heroes remain visible in daytime.
2. Target Dummies: damage numbers reflect actual hits, and only the comparison Archmages automatically attack. Check the item dummy's new position.
3. Narration/briefings: formatting tags, paragraph breaks, removed stops, task directions and Back/Topics transitions display correctly.
4. Heroes XP: all three range tasks and three creep trials award the expected native XP; the XP quest unlocks audibly/visibly and F9 is available afterward.
5. Optional displays: all six XP selectors work, defensive buildings are present, summons align beneath their matching columns, and the presentation fits. Neutral contains Tavern summons only.
6. Consolidation: first-arrival Orc gold gathering, fast Continue/Back, menu/load restoration and cleanup still need the focused engine acceptance described in [the consolidation record](CONSOLIDATION-2026-10-14.md).

Ask the user for milestone acceptance after these checks. Do not mark the milestone complete based solely on this source checkpoint.
