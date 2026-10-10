# Focused native timing verification — 2026-10-08

Imported the export modified at 18:08:25 local time: 279 observations, all 14 planned cases, no truncation flags. Raw export, CSV and JSON are preserved under `work/dodge-measurements/focused-2026-10-08/`.

## Recorder verification

Spell lifecycle events now appear. The value-comparison correction fixes the missing spell-event observations seen in the previous full pass. The two paired trials issued Wind Walk approximately 0.10 seconds after the requested Storm Bolt event anchors.

Observed channel/start-to-effect intervals, rounded to milliseconds:

| Spell | Interval |
| --- | ---: |
| Storm Bolt baseline | 398 ms |
| Ensnare baseline | 602 ms |
| Shockwave baseline | 469 ms |
| Wind Walk isolated | 0 ms |
| Invisibility Potion isolated | 0 ms |

These are individual native observations, not universal constants. Spell effect is not assumed to be projectile launch for every ability. Sampled transitions bound state changes rather than identifying an exact instant.

## Activation observations

- Wind Walk's effect and buff occurred in the order's timestamp. Invisibility was first sampled about 602 ms later.
- The invisibility potion effect and buff occurred in the order's timestamp. Invisibility was first sampled about 1.992 seconds later.
- Peon construction began about 383 ms after the accepted build order; hidden/invulnerable state was sampled about 391 ms after the order. This includes approaching/entering the construction site.
- Zeppelin loading occurred about 227 ms after the accepted loading order, including approach from the helper's starting position.
- The Wisp Moon Well build order was rejected again despite the farther placement. It generated no construction start; no build timing can be inferred.
- The Chimaera, Flying Machine and Ancient Protector baselines each emitted attack and damage events after their weapon-selection corrections.

## Paired Wind Walk observations

In the cast-start-plus-0.10 trial, Storm Bolt began at 2.50781 seconds. Wind Walk activated at 2.60938, Storm Bolt's effect occurred at 2.91406, and invisibility was first sampled at 3.21094. No target damage or stun transition was recorded in this trial. This is consistent with avoiding this cast, but does not isolate the mechanism or locate a boundary.

In the effect-plus-0.10 trial, Storm Bolt's effect occurred at 2.90625. Wind Walk activated at 3.01562, damage and stun occurred at 3.57031, and invisibility was first sampled at 3.60938. Thus pressing Wind Walk before impact did not prevent this hit: the invisibility transition followed the hit by about 39 ms. This supports separating ability effect from completed fade.

## Next measurements

The recorder is ready for broader spell-event acquisition. Resolve Wisp construction separately; do not discard the other cases. Before mathematical dodge-window predictions, record actual positions/ranges at command and effect, and distinguish state activation from completed invisibility. Attack-start timestamps still do not directly expose projectile launch. Use a small repeatable timing/distance sweep to validate predicted boundaries rather than interpreting absent damage alone as success.
