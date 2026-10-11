# Dodging and Bat Splitting

Current baseline: v0.1.2-beta1. Earlier candidate behavior and measurement reports are retained in [the 0.1.2 archive](archive/v0.1.2/README.md).

## Dodging progression

The briefing offers **Disjoining** (Abilities or Attacks) and **Avoiding** (Area or Devour). Selecting the final dodge ability or movement unit starts the exercise directly, with a three-second initial countdown. The toolbar Menu returns to the current branch's threat selection; Devour returns to Movement/Ability. There is no Setups toolbar button. Native menu handoff is described separately in [Native menu handoff](NATIVE-LOG-HANDOFF.md).

Every Area round, including Redo, shows 3, 2, 1, GO. The player's pawn can move during the countdown; enemy orders and the 15-second survival clock begin on GO. This applies to directional, radial and ground-targeted abilities.

Dodging creates no quest and keeps its Quest control inactive. Status labels use an ASCII separator to avoid broken character encoding. The Wisp mine is placed 160 units west and 32 units north of the pawn, with standard 270-degree building facing and exact placement; the pawn and camera anchors remain fixed.

Disjoining requires three consecutive successes per stage. Stage one starts at attack/spell range plus 200 units, with both units movable and the target facing left. Stage two uses the same distance with the target locked. Stage three makes the enemy approach half range before launching, with the target locked. Locked Spirit Wolf replacement tests have two stages; Wind Walk against orb effects has one. Attack tests issue attack orders, rather than casting unrelated abilities.

TOO EARLY, TOO LATE and WELL DONE resolve the trial after one second. Failure clears the streak; the third success ends the stage. Opening a menu or an end card clears temporary prompts. Confirmed launch, damage and debuff events inform scoring; the engine does not provide a general projectile enumeration API. A rejected cast is not proof of a successful disjoin.

Enemy and dodger model colors visualize preparation, wind-up and effect phases. Status text follows those colors. The measured timings are references for this installed game version, not guarantees that command processing, turning, distance and attack-speed changes are identical in every situation.

## Avoiding

Area trials last 15 seconds. Directional casters remain centered and cast toward the player at randomized 2–2.5 second intervals, including beyond target range. Their arena uses travel distance and shrinks to 80% after five seconds and 60% after ten. Feint orders are randomized at 0.5–1 second intervals. Close-area casters pursue the target, cast on their scheduled interval within their area, and can cast immediately at half range. Hero chasers receive Boots of Speed for the final five seconds. Blizzard and Rain of Fire cancel after the first damage wave before subsequent casts. Range/area overlays are intended to show the relevant footprint; directional travel and width are separate quantities.

Devour by Movement is a 15-second survival exercise. Devour by Ability locks the target and requires three successful dodges, with no further stages. Kodo follow orders use randomized 0.5–1 second intervals; direct Devour orders use randomized 2–2.5 second intervals. Entering half Devour range triggers an immediate attempt and resets both timers. Movement must not interrupt a simultaneous Devour attempt. A confirmed eat waits one second before displaying failure. The movement trial adds a stationary level-one Endurance Aura Tauren Chieftain outside the arena for the final five seconds.

Artillery data and implementation are retained for compatibility/research, but are not offered as a public branch.

## Selection and setup

Ability choices use grouped columns; Ranged and Movement use the shared racial unit selector. Eligibility accounts for native targets, magic immunity, Devour restrictions and known disjoin outcomes. Disabled choices explain the reason and do not play a click sound. Timing-limited methods can carry an exercise explanation rather than pretending the projectile is disjoinable.

Threat tooltips use cast point and projectile speed, or base attack wind-up, attack range and projectile speed for attacks. Dodge tooltips show cast point and relevant fade/effect onset; zero cast points read `Cast Point: Instant`. Disabled choices show their reason. Blademaster's Wind Walk and Mirror Image have separate sections.

Units retain native health pools and receive the applicable unlocked research. Builders and Statue/Destroyer tests receive resources. When a helper casts on a separate target, the helper starts 200 units north, facing that target; Archer/Hippogryph mounting starts together. Setup-specific buildings are supplied for construction, Burrow and gold-mine tests. Units, items, temporary overlays and callbacks belong to the exercise lifecycle and must be removed on reset or exit.

## Bat Splitting

The briefing directly offers Normal (day) and Hard (night). Stages use 6, 8 and 10 Gryphons and matching Batriders. Group sizes are 2/4, 3/3 or 4/2; then 4/4 or 3/3/2; then 4/4/2, 5/5 or 3/3/4. Each bat initially targets a different Gryphon with Unstable Concoction. The formation is centered at the northern boundary of Arena 1. Bat groups begin 400 units beyond the Gryphons' daytime vision distance from their initial positions, at normal native speeds.

Unit vision applies during the neutral-owned countdown, followed by player ownership; no artificial player reveal replaces it. Enemies have arena vision. Groups receive their first orders one, two and three seconds after the start. The trial ends after the last bat dies: any Gryphon loss fails; all surviving with splash damage gives a neutral card; no splash gives success. Generated formation choices persist for Redo.

## Data and diagnostics

`design/dodge-catalog.json` and `src/generated/dodge-catalog.lua` contain the checked-in catalog. `tools/prepare-dodge-catalog.py` regenerates it from extracted native unit, weapon, ability and item tables in ignored `work/`. Normal builds do not require a new CASC extraction. The original workbook is a research artifact, not a source of proven outcomes.

Development builds include individual timing commands and automated batches (`-timing-smoke`, `-timing-batch`, `-timing-activation`, `-timing-retest`, `-timing-metamorph`, `-timing-stop`). [Build and test](BUILD-AND-TEST.md) describes the development workflow. Runtime reports in the archive distinguish command, cast, launch, effect and hit observations from raw editor fields. Mock regression tests cover scripted sequencing and cleanup; native playtesting remains necessary for projectile behavior, native targeting and menu stacking.
