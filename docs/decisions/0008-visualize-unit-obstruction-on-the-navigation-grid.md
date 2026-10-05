# Decision 0008: Visualize obstruction separately from unit models

- Status: Accepted
- Date: 2026-10-05

## Context

Selection circles and unit artwork do not explain the space used during surrounds and Windwalk displacement. Early movement-order measurements mixed physical obstruction with Warcraft III’s stopping distance and route selection, producing inconsistent apparent sizes.

## Decision

Base the overlay on collision-aware placement measurements rather than targeted Move or Smart stopping distances. Group tested normal units into three practical square widths: 48, 80 and 112 world units. Anchor displayed squares to the measured 32-unit repeating world grid using the containing cell center.

The Squares control first shows obstruction boxes and 32-unit snap points, then adds a finer 8-unit visual grid. Quest text gives the practical interpretation; detailed methods, uncertainty and raw exports remain in project documentation.

## Consequences

- The overlay intentionally advances in steps while the animated model moves smoothly.
- Apparent gaps caused by order stopping, route selection or position quantization are not added to the unit’s base obstruction square.
- The measurements establish behavioral patterns, not access to Warcraft III’s internal pathfinding implementation.
- Untested unit classes, especially flying or transformed units, require runtime validation before their overlays are treated as authoritative.
