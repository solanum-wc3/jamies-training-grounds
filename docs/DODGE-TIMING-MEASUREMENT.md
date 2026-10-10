# Dodging timing measurement pass

Status: the first smoke export and [complete 595-case native pass](DODGE-TIMING-FULL-2026-10-08.md) have been inspected. The complete pass lacked spell lifecycle timestamps. **A focused 14-case pass is prepared to verify corrected event matching, attack selection and construction placement.** Code tests inject synthetic events and cannot establish Warcraft's actual timings or dodge outcomes.

Scope: all 10 Homing, 14 Area and 77 Ranged catalogue entries, plus all 34 dodge choices expanded into 38 individual methods (including the Movement baseline). See [the full inventory](DODGE-TIMING-INVENTORY.md) and `design/dodge-timing-audit.json`. Artillery has not been removed; its four targeted attack variants are included in Ranged. This is category coverage, not a requirement to test every possible pairing.

## Findings from the analysis

- The catalogue currently sums unit animation cast point and ability `Cast1`. That is not universally valid. Shadow Strike uses its misleadingly named field for poison damage intervals; Blizzard and Rain of Fire use it for wave timing. Keep these raw fields separate until the native event sequence has been measured. No spell data or existing scoring behavior was changed in this pass.
- Orb effects follow attack timing, so the base animation damage point alone is insufficient when attack speed changes. The training sets the enemy attack cooldown to two seconds and unlocks configured research; these are test conditions, not an unmodified melee baseline. A follow-up calibration must compare attack-speed conditions before publishing an effective release time.
- The recorder can observe spell channel/cast/effect/finish/end events, attacks starting, damage, item usage, construction, summons, loading and death. These are distinct events. Spell effect is not a universal missile-launch timestamp; attack-start is earlier than projectile release.
- Visibility, invulnerability, type changes, selected threat/dodger buffs and large position changes are sampled every requested 0.01 seconds. A sampled timestamp bounds a transition; it is not exact to five decimal places. Engine simulation granularity also applies.
- Native damage is useful evidence, but absent damage does not prove a dodge. Protection, immunity, non-damaging spells, delayed waves and cancelled attacks require their own interpretation. The training's launch confirmation and verdict are explicitly labelled `training_inference`, never used as measured proof.
- First Hawk has no native attack. Siege Engine's Barrage, other secondary projectiles, transformations, item casts and loading need individual validation. Missing events must be reported as unknown or unavailable rather than success.

Sources for event interpretation: [first-hand casting-event experiments and attached test map](https://www.hiveworkshop.com/threads/casting-events-guide.228472/); [Shadow Strike editor investigation](https://www.hiveworkshop.com/threads/shadowstrike-casting-time-like-in-x-seconds-before-casting.301135/). These older experiments are hypotheses to verify on the current installed build, not substitutes for current measurements. Numeric inventory fields come from the locally extracted installed-game tables.

## Recording a native pass

### Automatic batch (preferred)

Load the focused measurement development build and enter **`-timing-smoke`**. It automatically runs 14 trials: Storm Bolt, Ensnare, Headhunter attack and Shockwave baselines; corrected Chimaera, Flying Machine and Ancient Protector baselines; isolated Wind Walk, Peon construction, Wisp construction, Zeppelin loading and invisibility potion; and Wind Walk scheduled 0.10 seconds after Storm Bolt cast start and after its effect. Allow about three minutes. No player commands or per-case setup are required. On completion it exports the observations and returns to Skill Training. Wisp construction is moved farther south to reduce interference from its mine setup; native success remains to be checked.

Then enter **`-timing-batch`** for the full 595-trial pass:

- 101 baselines, one for every listed Homing, Area and Ranged threat. Homing/Ranged baseline targets are already within range (85% of native range), so stationary towers can also attack. Air-only weapons get a flying baseline target. First Hawk stays listed; absence of a native attack is reported rather than silently removed.
- 38 isolated dodge methods, with the enemy paused, to observe the method's own events and state changes.
- 456 representative paired trials: each of the 38 methods against Storm Bolt, Ensnare, Headhunter attacks and Shockwave, at three scheduled timings: before the enemy order, 0.10 s after cast start, and 0.10 s after spell effect. Ranged attacks use attack start for both event-anchored timings; this is explicitly not a missile-launch timestamp.

This covers categories without a full all-against-all matrix. It is an initial discovery pass, not ten-repeat calibration or all three range stages. Invalid native targets, rejected orders and missing events remain recorded and do not count as dodges. The ordinary menu's eligibility restrictions are not used to hide such diagnostic results.

Allow roughly two hours for the full pass; most trial windows are capped at 14 seconds, with longer Area windows where configured. Native summons/forms get two seconds to settle. Each trial reuses the real exercise setup, but suppresses its normal automatic scoring/restarts and drives the orders itself. It removes automatic pawn/helper attacks to avoid incidental combat. Cloak trials use walking followed by Stop to observe passive fade; those paired trials have moving geometry.

Diagnostic trials borrow a food cap of 200 to prevent food availability from blocking native morph/merge orders; cleanup restores the previous cap. This condition is recorded in every run. Isolated methods put the paused enemy 400 units away so Righteous Fury does not include a forced approach before its cast.

**`-timing-stop`** stops, cleans up and exports immediately. The batch also exports every 25 completed trials and at completion. If another activity replaces the current trial, the batch stops without deleting that other activity. Pausing the game pauses the batch; use `-timing-stop` to leave it deliberately. Native timing results are still pending until this build is run in Warcraft III.

### Optional manual investigation

Use a development build containing `src/infrastructure/dodge-timing-diagnostics.lua`. Release builds exclude the recorder and chat commands. The published alpha is unchanged.

1. Enter `-timing-on` before starting Dodging. It also attaches to an already active test, but those observations lack earlier events.
2. Run an untouched baseline for every threat: allow the selected native spell/attack to hit a valid target. Record all three distances for Homing/Ranged. Use a flying recipient for air-only weapons. For Area, remain in the affected area and allow a complete cast or channel, then leave through the normal menu.
3. Test every individual dodge method separately: at least one early use, one late use, and successful attempts where possible. Start with a representative damaging Homing spell, then check Ensnare, ranged attacks and Area separately where applicable. Invalid pairings remain invalid; do not enable greyed-out options merely to fill a matrix.
4. Repeat each timing of interest at least ten times at the same stage/distance. Record ability level, attack-speed research/buffs, facing and any replacement unit. Build vs cancel, loading vs unloading, invisibility fade and actual removal must not be combined into a single method.
5. Use `-timing-export` before leaving Warcraft. It writes `JTG-Dodge-Timing.pld` in Warcraft III's `CustomMapData` folder. The file contains comment-prefixed CSV records. Export replaces the previous file with the current in-memory history; copy it between game sessions. `-timing-status` reports recorder state; `-timing-off` exports and stops recording.
6. Import with `python tools/analyze-dodge-timing.py <export-file> --output work/dodge-measurements/<session-name>`. The importer reads text only, never executes the preload file. Keep raw CSV beside its summary.

Each activity session/reset receives a run ID and records selected threat, dodge choice, stage, unit handle identity, game-time timestamps, observation quality and truncation. Automatic streak resets create new records. In unscored Area tests, several casts can share a run. Export before quitting; this is not an automatic save-on-exit feature. Ordinary exercise cleanup owns and destroys the diagnostic timers/triggers, and clears sampled unit references.

The importer pairs a spell's channel start with its effect for the same unit handle and ability. It also provides player events relative to the **first enemy effect** in the run. That anchor is explicitly not an automatic match for every repeated Area cast. Raw event order remains available for analysis.

## What the eventual player display can safely say

Where observed: enemy cast start/effect/end; player cast start/effect/end; sampled moment protection or invisibility became active; recorded damage relative to those events. For example, “Your Blink took effect 0.12 s after the enemy spell effect.”

Only label a timestamp “missile launched,” “hit” or “dodge succeeded” after that particular mechanism has been validated. Ordinary ranged missile flight cannot be exactly timed from an attack-start event and a guessed damage point. Initial-distance divided by missile speed is an estimate, especially for a moving homing target; it must not be presented as a measurement. No new player-facing timeline or scoring changes are included yet.
