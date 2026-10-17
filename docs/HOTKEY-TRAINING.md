# Hotkey Trainer

The trainer is in Tools & Extras. Its standard briefing uses the authored artwork and editable introduction. Start Training opens a standard 2x2 race selector with Neutral centered below it. Selecting a race starts the exercise directly. Back, Resume and Exit use the shared briefing lifecycle.

The exercise runs in stages of up to 60 seconds and has only Menu on its toolbar. The countdown displays whole seconds. A command category and name appear above 200% icons inside a menu border. Build and Ability Choice prompts show three icons, with a gap after the source and the submenu/command icons next to each other. Displayed icons have tooltips. Native command buttons keep Warcraft's visibility and handlers. A noninteractive opaque black backdrop covers only the lower UI; temporary actors have zero sight and fog remains enabled.

## Practice lists

Five separate generated lists supply the five setups:

| Setup | File | Prompts before live conflict filtering |
| --- | --- | --- |
| Human | src/data/hotkey-pools/human.json | 130 |
| Orc | src/data/hotkey-pools/orc.json | 122 |
| Night Elf | src/data/hotkey-pools/nightelf.json | 147 |
| Undead | src/data/hotkey-pools/undead.json | 125 |
| Neutral | src/data/hotkey-pools/neutral.json | 115 |

Each list includes racial commands and shared Move, Hold Position, Attack, Stop and Patrol prompts. Take Root and Uproot appear only in Night Elf. Shared commands omit the source icon. Neutral contains Tavern heroes, shops, Goblin Laboratory and units hired from the specified Mercenary Camps, not unrelated placed creeps.

src/data/hotkey-catalog.json retains all 625 native contexts for diagnostics. Gather, Select User, Unload, Sacrifice, Absorb Mana and Inferno are temporarily excluded from random practice because their activation/context failures remain unresolved. Research levels 2 and 3 remain in the lists. Cancel is excluded entirely.

## Stages and command history

Stage 1 draws untested commands without replacement. Identity is based on
command category/name and research level, so the same ability carried by
several units appears only once. Ability Choice is distinct from casting the
ability; research levels remain distinct.

Continue starts the next stage with a fresh 60-second clock and score. Tested
commands and first-attempt failures persist. Untested commands take priority;
after they are exhausted, the stage draws from the missed-command list. Each
command appears at most once per stage. A first-try correct answer retires a
review command. Correcting an answer after an incorrect attempt keeps it in
the list. A displayed question still unanswered at timeout also enters the
review list. Build/Ability Choice opening keys do not count as incorrect.

The result shows remaining untested and review counts. A stage can end early
if it has exhausted its eligible commands. Continue disappears once all
commands have been tested and the review list is empty. If a remaining Ancient
or Burrow is still preparing, the trainer waits rather than declaring the
curriculum finished.

Scores below 250 are red; 250–349 yellow; 350–449 green; 450 and above gold.
The score has its own text frame in play and on the result card, increasing
from scale 1.25 through 1.45 and 1.65 to 1.85 at those thresholds. Frame bounds
stay fixed so larger text does not overlap result details or buttons.

## Recognition and preparation

Warcraft resolves the player's current bindings through a real selected unit/building and native command card. The trainer observes button activation before target selection, plus execution events for production, research, upgrades and purchases. Keyboard notifications measure response time and incorrect inputs. Normal play does not read the author's binding fixture; dev automation alone reads CustomKeys.

Correct events and keys are correlated within 0.5 seconds regardless of arrival order. Fast queued inputs are retained. Build/Hero Abilities opening commands are unpenalized. Their submenus remain open while selecting an entry; an incorrect entry cancels the submenu and restores the source's main command grid, so the player retries the full sequence. Held keys cannot answer repeatedly. Prompt changes cancel and clear the old selection while its source still exists, then let cancellation settle before replacing the context. Input is inactive during that transition. Context creation, selection and input arming happen on separate updates.

Each prompt creates only its source, explicit prerequisite buildings, required research and support context. Train, research, build, upgrade, purchase and hire refresh gold/lumber to 1000. Shops are neutral passive, have stock and a nearby inventory-bearing patron. Casting heroes are level 10 with skills learned; Ability Choice heroes are level 6 with unspent skills. Recruitment lifts and restores hero limits. Food, completed tiers and dependencies come from installed melee data. Stock-delay overrides used for auditing remain dev-only.

Autocast-off orders are sent before creating injured support units. Corrections cover neutral Heal (creepheal/creephealoff), Moon Well (recharge/rechargeoff), Searing Arrows (flamingarrowstarg/unflamingarrows) and Incinerate (incineratearrow/incineratearrowoff). Native UI files contain misleading or incomplete order metadata. Setup acceptance is logged separately from activation.

Night Elf selection prepares eight Ancient types in the background. Readiness uses UNIT_BF_IS_A_BUILDING and the Root ability's native duration plus 0.1 seconds. It does not require the last order to change from Uproot. Ancient Protector uses Aro2; the others use Aro1. Take Root/Eat Tree reuse a ready unit and immediately prepare its replacement. Random play skips preparations still running. Finishing/leaving removes used and background units.

Before choosing an ability prompt, the trainer checks whether another active ability on that unit shares its live button position. Conflicting prompts are skipped without affecting score; -hotkey-debug records their IDs. This covers command-cell collisions. Warcraft has no direct getter for effective custom hotkeys, so duplicate keys in different cells cannot be detected by this runtime check. Forced diagnostics can still test skipped commands.

## Transformation commands

Transformation entries explicitly record the native starting and destination forms. The source portrait represents the starting form; the command icon, name, order and description come from the appropriate forward or return command face. Spirit Walker's two native unit records share a portrait, so its Ethereal command artwork identifies the spirit starting form. The same distinction applies to Robo-Goblin's robot portrait.

Spirit Walker, both Druids, Gargoyle, Crypt Fiend and Tinker have separate forward/return entries. Most return prompts spawn the native base unit and issue the forward transformation during preparation, before registering answer events. Tinker's return prompt directly creates Robo-Goblin instead. They cannot arm until the native unit type matches the requested starting form and the native duration plus 0.1 seconds has elapsed. The setup cooldown is cleared before selection/arming. Preparing and transformed actors remain owned by the prompt's cleanup scope. Tinker's casting context uses the Robo-Goblin ability supplied by rank-three Engineering Upgrade.

Destroyer Form, Metamorphosis and Chemical Rage remain forward-only; a native Unorder field alone is not evidence that reversal is playable. Mount/Dismount retains its native merge/split command icons. Ancient Uproot/Take Root/Eat Tree retains its separately audited preparation. Form entries preserve the existing command-name deduplication across units.

These changes are included in alpha51. Automated fixtures verify direction, icons/tooltips, preparation gating, command registration and cleanup; native transformation state and actual custom-key recognition still require a focused in-game check in the next build.

## Scoring and lifecycle

Correct within 1 second earns 15 points; within 5 seconds earns 10; later earns zero. Incorrect input costs 10 and leaves the prompt. The end card shows score, high score, counts and average correct response time. Averages retain fractional seconds; only the countdown is rounded. High scores are separate per race and last for the map session.

Menu pauses exercise time and rejects inputs. Resume restores selection/prompt. Continue advances the curriculum to another one-minute stage; Start Over resets the chosen race and its command history. Scoped cleanup restores borrowed resources, technologies and day/night state and removes sources, patrons, prerequisites and the Ancient pool.

Alpha37's 0.5 + 0.5 + 0.2-second normal handoff passed the user's live
selection checks. Alpha38 preserves the same stages with 0.08 seconds before
context replacement, 0.08 seconds before selection and 0.04 seconds before
input arming (about 0.2 seconds total, plus native preparation). The user verified this faster
timing in normal Human and Orc play without selection failures. Selection alone is not proof that
Warcraft refreshed the command card. The prompt appears and its response
clock starts after preparation completes. Diagnostic audit timing is unchanged.

Orc Stand Down borrows a background Burrow with a Peon already loaded. The
Peon is created at the Burrow's exact coordinates with pathing disabled. The
prompt cannot arm until native transport state confirms loading. Shop patrons
are assigned during preparation; failed assignments retry after source
selection, and successful assignments are not repeated. These actors use the
same scoped cleanup as prompt sources.

## Covered presentation

Practice covers the arena and lower interface using disabled BACKDROP frames,
without changing native command-button visibility, enabled state or opacity.
The lower cover disappears after three incorrect attempts on the same prompt
and returns after a correct answer or the next question. There is no upper-screen cover that could overlap the prompt. The camera is held at the
map center while contexts spawn near the northern edge, so spawn-time sight
cannot briefly reveal the units in the exercise view. Native top-bar buttons and the custom Menu toolbar remain available.
Exercise/native menus hide the lower cover; resume restores them according to the
current mistake count. Result cards reveal the lower UI. Presentation rebuilding recreates covers after load.

All owned context actors, prerequisite/support units, prepared Ancients and
Burrows, patrons and observed summons/trained units receive sight radius zero.
Neutral shops receive a scoped 256-unit reveal around their off-camera position;
without this, the engine can reject selecting an unseen shop and stall prompt
readiness. The shop and patron retain zero sight. Fog/mask are enabled for this
exercise and their borrowed settings are restored
on exit. Units retain their ordinary rendering and native abilities behind the
cover. Diagnostic comparisons turn covers off, retaining the native audit path.

## Inventory and validation

Run tools/prepare-hotkey-catalog.py --verified to derive associations, prerequisites, five practice lists and runtime Lua from installed data. It refuses missing icons. tools/extract-hotkey-data.ps1 extracts data/verifies textures; tools/audit-hotkey-mercenaries.cjs checks camp stock in named ladder maps. Artwork uses tools/prepare-training-briefing-art.py. See [MELEE-PREREQUISITES.md](MELEE-PREREQUISITES.md).

Fixtures cover scoring, fast/delayed submenu input, event ordering, list separation, conflict skipping, whole-second countdowns, normal prompt transitions, preparation, pause/menu handling and cleanup. Mocked events do not prove every live command works. Native checks should cover rapid consecutive answers, Build/Ability Choice navigation, conflict skipping and Menu/Resume.

Alpha36 corrects alpha35's startup regression: the shared controller passes its session to start, which was accidentally interpreted as a forced prompt. Forced diagnostic prompts now use a separate argument. Fixtures invoke the controller-style start call for all five setups and reject invalid FourCC identifiers.

See [HOTKEY-TARGETED-AUDIT.md](HOTKEY-TARGETED-AUDIT.md), [HOTKEY-FULL-AUDIT.md](HOTKEY-FULL-AUDIT.md) and [HOTKEY-COMPARISON.md](HOTKEY-COMPARISON.md). Alpha34 verified nine of ten focused commands three times; Forest Troll Priest Heal remained blocked by a shared cell/key conflict. Automatic casts before input make audit results inconclusive.


## Consolidated runtime boundaries (14 October)

`hotkey-training.lua` keeps native context preparation, selection recovery, button/order recognition and scored stage progression. The optional diagnostic adapter is defined only in `infrastructure/hotkey-diagnostics.lua`, loaded before the development audit/comparison wrappers and rebound to the actual catalogue factory. It owns report export, native event traces, command-card observations and audit mode dispatch. Release builds contain no Hotkey debug chat command or audit report exporter. Native input matching rules and settling durations are unchanged.

Hotkey presentation registers disposable frame aliases with `Training.InstallPresentation`. Menu/native-menu hiding, completed-result restoration and presentation rebuild use that common contract. Completion sounds belong to the attempt, not visibility. Briefing bodies are generated from `design/exercises/editable/hotkey-trainer.txt`; edit that file rather than generated Lua. Shared response awards and score colors/sizes belong to `Training`; stage clocks, review history and high-score keys stay here.

## 0.2.2 native corrections

Neutral hiring contexts now use verified clear northern-arena terrain (center Y minus 256), with patrons 320 units toward the interior and outside the shop footprint. Prompt readiness observes settled selection and the patron's range; a false patron-order return or missing native simple-frame slot does not suppress an otherwise usable prompt. Hiring recognizes native unit-command names as well as raw IDs and sale events. The user completed the Hotkey pass and reported it working after these changes.

Wrong shop attempts restore resources, remove purchases, replenish stock and return selection to the source. Scoped overall/individual hero allowances prevent Tavern soft locks and are restored on exit. Tinker learn prompts accept its original skill and Engineering Upgrade replacement IDs. Ghoul's resource command is labelled Gather. The lower backdrop covers the full width and lower half beneath the prompt card; the user accepted this cover without requesting another native check.
