# Activation measurements — 8 October 2026

Source: alpha 14 development build, `-timing-activation`. The native export was copied to `work/dodge-measurements/activation-2026-10-08/raw-export.pld` and imported into the adjacent CSV and JSON files. All 153 trials and 4,210 observations were recovered; no trial was truncated.

## Quality of the trials

Completion of the batch does **not** mean every method activated successfully.

- 21 trials rejected the requested action: Statue → Destroyer (3), Archer mounting (6), Hippogryph pickup (6), Wisp construction (6). None supplies an activation timing.
- Shadowmeld's three trials began with the Priestess already invisible. The accepted `ambush` order supplied no new transition. These cannot measure fade duration.
- Detonate's three orders were accepted, but no cast, death or sampled activation followed. The cause remains unresolved; an accepted order is insufficient evidence of activation.
- Six Peon construction trials started construction successfully.
- All 18 ranged reference trials produced damage. These are attack references, not dodge successes.
- The remaining trials contain observations of varying strength: a spell effect, a relevant buff, an actual visibility/protection transition, a form change or a displacement. These signals must remain distinct.

The user observed occupied Wisp building sites. The export confirms rejected construction at the requested coordinates, but does not record the occupying object or building-pathing result. Occupancy is a plausible setup failure, not yet a proven explanation of every rejected build. The near site's requested coordinates were (4864, 3264); the far site's were (4864, 3008).

The mounting order strings used by the harness were `mounthippogryph` and `loadarcher`; both were rejected. The Destroyer request used `sphinxform`, which agrees with the extracted ability metadata, but was nevertheless rejected. Its prerequisites, supply and actual ability availability need checking in-game rather than guessing a replacement order.

## Selected repeatable observations

Times below are seconds from the automatic dodge request, rounded to milliseconds. Each row has three repetitions. Sampled transitions have simulation/sampling uncertainty; they are not exact continuous-time boundaries or proof that a missile disjoins at that moment.

| Method | Observed signal | Delay across three trials |
|---|---|---:|
| Wind Walk | Invisible | 0.602 |
| Mirror Image | Hidden/invulnerable | 0.305 |
| Divine Shield | Invulnerable | 0.000 |
| Sorceress Invisibility | Target invisible | 0.461 |
| Big Bad Voodoo | Target invulnerable | 0.555 |
| Stone Form | Stone-form unit type | 1.008 |
| Crypt Fiend Burrow | Burrowed type/invisible | 1.461 |
| Carrion Beetle Burrow | Burrowed type/invisible | 1.461 |
| Phase Shift | Invisible | 0.312 |
| Metamorphosis | Demon-form type | 1.508 |
| Bear Form | Bear-form type | 1.453 |
| Storm, Earth and Fire | Hidden/invulnerable | 0.406 |
| Robo-Goblin | Transformed type | 1.500 |
| Town Portal | Invulnerable | 0.000 |
| Cloak of Shadows | Invisible after stopping | 1.469 |
| Invisibility Potion | Invisible | 1.953 |
| Invulnerability Potion | Invulnerable | 0.000 |

Town Portal's spell effect and teleport occurred five seconds after the request, although invulnerability began immediately. Mirror Image's native spell effect occurred about 0.297 seconds after the request, followed by sampled hidden/invulnerable state at 0.305. These demonstrate why spell effect and defensive activation cannot be treated as interchangeable.

Crow Form produced an immediate unit-type transition, unlike Bear Form. This is an observed type change, not an independently established missile-disjoin boundary. Avatar emitted a native spell effect, but the currently sampled generic states do not establish its magic-immunity onset. Charge's movement likewise does not establish a protection window.

| Approach-dependent method | Near | Far |
|---|---:|---:|
| Peon construction begins | 0.375–0.383 | 1.680–1.703 |
| Peon loaded into Burrow | 0.016–0.023 | 1.086–1.109 |
| Wisp loaded into entangled mine | 0.039–0.055 | 0.758–0.781 |
| Unit loaded into Zeppelin | 0.000 | 0.906–0.930 |

These are total command-to-entry times at this test's actual positions. They include approach and interaction distance and should not become fixed ability cast-point tooltips. Sampled hidden state can follow the native loading event by a sampling interval.

## Limits and implications

The phase model needs separate signals for command/approach, native cast start, native effect, and actual defensive activation or replacement. Some methods skip phases; Town Portal starts protection before its effect, while transformations and invisibility can activate after their spell effect. A single universal cast-time formula would lose this distinction.

Dismount kills/hides the old Rider handle immediately. Subsequent movement/type changes on that old handle include its death animation/removal. The recorder does not yet follow all replacement handles, so those later changes must not be interpreted as movement or activation of the newly separated Archer and Hippogryph. Feral Spirit also replaces the tracked old summon; its new summon events and old-unit death are stronger evidence than the old corpse's later sampled movement.

The ranged references used the intended selected weapons: Headhunter range 550, Chimaera ground weapon range 450, Ancient Protector ranged weapon range 700. Attack-start-to-damage spans include wind-up and flight. There is no native projectile-launch observation here, so any division into wind-up and flight remains an estimate.

## Focused follow-up

Retain the useful results; do not repeat all 153 trials merely because some setups failed. A corrected short pass should cover Wisp construction and Detonate, Destroyer transformation, Archer/Hippogryph coupling, and Shadowmeld. It should verify a valid unoccupied build footprint and affordable prerequisites before issuing construction, keep Shadowmeld visible until the scheduled action, record actual resources/supply and ability availability for rejected transformations, and follow replacement units where needed. Buff-specific sampling is also needed before assigning an observed immunity onset to Avatar.

No new map was packaged as part of this analysis.
