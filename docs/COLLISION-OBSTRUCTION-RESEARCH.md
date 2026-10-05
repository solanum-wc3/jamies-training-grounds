# Unit movement obstruction research

This note records the collision experiments behind the Surrounds and Windwalk
Pop square overlays. It intentionally contains more engine detail than the
in-game quests, whose purpose is practical player instruction.

## Tested unit categories

The calibration covered 63 regular racial units and neutral heroes. Warcraft
reported only four raw collision values:

| Raw collision | Tested units | Practical category |
| ---: | ---: | --- |
| 16 | 13 | Small |
| 31 | 3 | Small |
| 32 | 39 | Medium |
| 48 | 8 | Large |

Values 16 and 31 behaved identically in collision-aware placement tests.

## Targeted movement is not physical contact

For all 16 mover/target category pairings and eight approach directions,
targeted Move and Smart orders stopped approximately 33.5 world units farther
away on average than the closest point observed during forced-through movement.
The stopping distances also depended strongly on approach direction.

Consequently, resting formations produced by Move or Smart orders cannot be
used to size physical obstruction overlays. These orders preserve additional
spacing before unit obstruction becomes relevant.

## Movement tests and route selection

Forced-through movement remained unsuitable for exact footprint measurement.
Warcraft selected a route around the stationary unit long before contact, and
small changes to the complete setup changed the selected route. Shifting both
units by 4–12 world units changed some closest approaches by as much as 39.2
units.

These measurements describe path selection as well as obstruction and should
not be treated as direct footprint dimensions.

## Collision-aware placement result

The decisive diagnostic used `SetUnitPosition` to request every integer
distance from 0 through 180 around a stationary unit. Requested overlapping
positions were relocated; accepted positions were preserved exactly. The
acceptance masks were monotonic in all cases.

The forbidden center intervals decomposed exactly into three footprint widths:

| Practical category | Footprint width | Half-width |
| --- | ---: | ---: |
| Small (16/31) | 48 | 24 |
| Medium (32) | 80 | 40 |
| Large (48) | 112 | 56 |

Every mixed pairing agreed with these values. For example, the complete
forbidden interval for a small and medium unit was 128 units: 48 + 80.

The category rule is:

```text
half-width = floor(raw collision / 16) * 16 + 8
```

## World-grid anchoring

The placement boundary is anchored to a 32-unit world grid. When both units
were shifted together through phases 0, 4, 8, 12, 16, 20, 24 and 28, the
absolute forbidden region remained fixed while its offset relative to the unit
coordinate changed. At phase 32 the phase-0 result repeated exactly; phase 36
repeated phase 4 in all 64 comparable cases.

The overlay therefore uses the center of the unit's containing grid cell:

```text
grid center = floor(unit coordinate / 32) * 32 + 16
```

The displayed obstruction square advances in 32-unit steps as the unit crosses
cell boundaries. Model artwork, animation, camera projection and selection
circles are separate visual systems and need not remain centered on it.

## Player-facing interpretation

- Unit movement obstruction behaves as a fixed-orientation square.
- There are three practical square sizes among the tested normal units.
- Targeted movement normally stops before the obstruction areas touch.
- The obstruction becomes important when units press against each other, such
  as when a surrounded unit attempts to escape through a gap.
- Mixed-size selections can approach differently because mover and target size
  both influence command stopping distances, in addition to unit movement and
  turning behavior.

The diagnostic source is retained in development-only modules and is excluded
from release builds. The four original Warcraft III exports used during this
investigation are preserved under [`reference/diagnostics/data/`](../reference/diagnostics/data/), together with checksums and format notes.
