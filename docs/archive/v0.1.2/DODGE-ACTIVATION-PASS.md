# Automated activation measurements — alpha 14 development build

Load the development map and type **`-timing-activation`**. Do not issue unit commands during the trials. Allow about **20–25 minutes** at normal game speed. The test returns to Skill Training and exports automatically when finished. `-timing-stop` stops, cleans up and exports the completed observations early.

The pass contains **153 trials**:

- All 38 individual dodge methods, each repeated three times.
- Construction, Burrow entry, goldmine entry, Archer/Hippogryph mounting and Zeppelin loading each have near/far approaches, both repeated three times. These account for 21 additional trials beyond the 114 single-position trials.
- Headhunter, Chimaera and Ancient Protector attacks at 45% and 85% of the selected native attack range, repeated three times each: 18 ranged reference trials.

Isolated dodge cases keep the opponent paused. Initial facing is aligned before the action; build sites are south of the worker. Near/far measurements retain approach time as part of command-to-activation time. Movement onset/stop and native cast/effect/state events allow approach and action phases to be distinguished where Warcraft exposes the necessary events. The Wisp build records both the build-order route and a point-order fallback if the first route is rejected; rejected orders are not interpreted as valid timings.

Snapshots record actual unit coordinates, facing and collision size at setup and action request. Enemy attack snapshots also record weapon index, current native range, damage point and cooldown. These are field reads, not measured projectile-launch events. Movement, hidden/invisible/invulnerable state, form changes and large position changes are sampled at the recorder's requested 0.01-second period. Simulation granularity and sampling bounds still apply.

Output: `Documents/Warcraft III/CustomMapData/JTG-Dodge-Timing.pld`. The export contains short numbered chunks; only parse it as data. It is written every 25 completed trials and on completion/stop. The existing CSV importer preserves snapshots and produces timelines relative to each dodge request. Repetition, method and approach are recorded in each trial's conditions.

This pass measures activation, not every buff's full duration or every projectile/dodge matchup. Two-distance attack observations can help check wind-up/flight estimates, but an attack-start event is not a direct launch event. Do not turn missing damage or a timeout into a successful-dodge claim.

The development-only Economy base workspace from alpha 13 remains available beside the Tavern, with `-export-layout`. No regular alpha is produced for this instrumentation-only pass.
