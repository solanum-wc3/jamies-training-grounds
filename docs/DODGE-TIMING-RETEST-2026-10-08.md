# Focused activation results — 8 October 2026

Source: alpha 15 development build, `-timing-retest`; export modified 20:52 local time. Preserved at `work/dodge-measurements/retest-2026-10-08/raw-export.pld`, with imported CSV and JSON alongside it. All 39 trials and 1,392 observations were recovered without truncation.

## Observed activation

Each condition below was repeated three times. Delays are measured from the automatic request, rounded to milliseconds. A delay of zero means the events share the recorded game-clock timestamp, not a proven infinitely fast transition. Sampled state/discovery events also have simulation and sampling uncertainty.

| Method | Observed signal | Request-to-signal delay |
|---|---|---:|
| Avatar | Native effect, magic immunity, Avatar buff | Same recorded timestamp |
| Destroyer Form | Native effect, Destroyer type, magic immunity | Same recorded timestamp |
| Shadowmeld | Becomes invisible | 1.508 seconds |
| Hippogryph pickup, near | Native effect and death of old units; Rider discovered | Same recorded timestamp |
| Hippogryph pickup, far | Native effect and death of old units | 0.750–0.773 seconds |
| Rider dismount | Native effect and Rider death; Archer and Hippogryph discovered | Same recorded timestamp |
| Wisp construction, near | Construction begins | 0.234–0.273 seconds |
| Wisp construction, far | Construction begins | 1.211–1.234 seconds |
| Wisp Detonate, point at own position | Native effect and Wisp death | Same recorded timestamp |

The far pickup's Rider was discovered at 0.773 seconds in all three repetitions. Discovery is sampled every 0.05 seconds and is not a native creation timestamp. Construction's sampled hidden/invulnerable Wisp state appeared at 0.250–0.273 seconds near and 1.219–1.242 seconds far. These observations do not by themselves measure a projectile disjoin boundary.

## What the corrected setups establish

- **Wisp building:** all six build orders were accepted and construction started. The build-site coordinates remained (4864, 3264) near and (4864, 3008) far. Removing the unused mine/Tree supports and checking the footprint eliminated the earlier failure in this setup. The earlier mine snapshot was (4736, 3136), close to both requested sites; its actual building footprint can extend beyond its collision size. This supports the user's occupancy diagnosis, but does not independently isolate which support/pathing cell caused rejection. Approach time is part of these results, not a fixed cast point.
- **Destroyer:** `avengerform` succeeded in all three trials; the old `sphinxform` trials rejected. The retest also increased the diagnostic food ceiling, so the data verifies the corrected configuration, not an isolated experiment proving that the order string alone caused the previous rejection. Transformation/type change and magic immunity were observed without the delay implied by reading the static cast/duration fields as a universal activation time.
- **Shadowmeld:** keeping the Priestess moving before the request provided a fresh visible-to-invisible transition. Its observed delay was consistently about 1.508 seconds.
- **Detonate:** point orders at the Wisp's own position activated and killed it in all three trials. The three immediate-order trials and three immediate-order trials with a nearby opponent were accepted but produced no activation. Accepted immediate orders must not be used as an activation signal; use the working point-order route for future automation.
- **Pickup and dismount:** the new replacement tracking successfully observed Rider creation after Hippogryph pickup and both separated units after dismount. Late removal/type changes on the old dead handles are corpse cleanup, not live movement or a delayed activation.
- **Avatar:** explicit immunity/buff sampling now establishes an observed defensive state rather than relying solely on its spell-effect event.

## One unresolved case

Archer-initiated mounting fired native Aco2 cast/effect events in all six near/far trials, but neither unit was removed, no Rider was discovered, and no subsequent approach movement was recorded. The Archer's ability event is therefore **not** evidence that mounting completed.

Both units were unpaused, had their expected native coupling ability, and had sufficient recorded supply. The setup still strips their attack ability to suppress automatic combat, and the helper had previously received Hold Position; their possible effects on the Archer-initiated coupling sequence remain untested. Do not present an Archer mounting delay until a completed merge is observed. The reverse operation, initiated by the Hippogryph, did complete.

Overall, 27 trials observed the intended defensive activation, construction or replacement; six Archer-initiated trials remain unresolved; six immediate Detonate trials are useful negative controls. The batch's generic `isolated_observations` status is not a success verdict.

## Application to the timing display

Keep command/approach, native casting/effect and observed defensive activation as separate boundaries. The current results support an immediate-state indicator for Avatar and Destroyer, a measured fade interval for Shadowmeld, construction/entry events for workers, and old-handle replacement tracking for mounting/dismounting. They do not establish all missile-versus-dodge interactions or universal success windows. The useful data can be retained; another broad activation batch is unnecessary.

The importer was corrected to include replacement-unit events in the summarized player timeline; these events were already present in the raw export and CSV. No new map was packaged during this analysis.

## Provisional Archer timing decision

The user approved using the same approach/entry model as Wisp/Peon building entry and Zeppelin loading rather than holding up implementation for another mounting test. The Archer tooltip labels this as a loading estimate. Treat travel to interaction distance separately from entry; do not copy a near/far total from a different unit's movement speed or support geometry. The exact Archer mounting timing and cause of the incomplete automated merge remain unverified. The helper's prior Hold Position and the stripped attack abilities are possible harness interference, not established causes.
