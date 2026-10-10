# Metamorphosis projectile results — 2026-10-08

The alpha 17 native export contains all 54 planned trials and 3,757 observations, without truncated runs or missing export rows. The original is preserved locally at `work/dodge-measurements/metamorph-2026-10-08/raw-export.pld`, with decoded CSV and JSON alongside it.

## Findings

| Threat | No-transformation controls | Transformation before enemy order | Transformation during projectile flight |
| --- | --- | --- | --- |
| Ensnare | Net buff applied, 2/2 | Net buff applied, 6/6; enemy cast was delayed until transformation completed | No net buff observed, 10/10 |
| Storm Bolt | Damage and stun, 2/2 | Damage and stun, 6/6 | Damage and stun, 10/10 |
| Headhunter/Berserker ranged attack | Positive damage, 2/2 | Positive first-impact damage, 6/6 | Positive first-impact damage, 10/10 |

Metamorphosis was requested and completed in all 48 transformation trials. There was no sampled invulnerability transition. Form completion followed the request by about 1.5 seconds.

For Ensnare, the in-flight transformation requests were roughly 0.008–0.258 seconds after the native spell effect. The net's zero-damage impact events still occurred, but the Beng net buff did not appear. The successful observation is therefore prevention of the root, not proof that the visible projectile disappeared. No-dodge controls and casts made after transformation completed did apply Beng.

All tested Storm Bolts caused 70 damage and the BPSE stun buff. All tested ordinary first projectiles caused positive damage. This supports an Ensnare-specific transformation interaction rather than general invulnerability or a universal projectile disjoin. It does not establish outcomes for every other homing ability.

## Limits

The pre-order Ensnare cases all cast after the form transition, despite differing scheduled enemy-order delays; they are not evidence about Ensnare landing during transformation.

The ranged trials recorded later automatic attacks despite the post-launch Stop command. The table uses the first impact associated with the first attack; later damage is excluded from the dodge inference. A future driver should suppress re-acquisition after that impact. This does not overturn the positive first-impact evidence.

Ordinary attack launch and flight fractions were estimated. Spell-effect events, damage, buffs and form transitions were native events or sampled native states. State sampling can miss transitions shorter than a simulation/sample interval. The tested in-flight requests show a working interval, not its exact earliest/latest boundary.

No further full batch is needed for the current conclusion. A narrower boundary test would only be useful if an exact Ensnare timing tooltip is desired.
