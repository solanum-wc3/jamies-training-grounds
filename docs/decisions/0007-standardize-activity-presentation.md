# Decision 0007: Standardize activity presentation components

- Status: Accepted
- Date: 2026-10-04

## Context

Exercises had accumulated different toolbar positions, result-card layouts, heading colors and briefing structures. Reimplementing the same controls for each activity increased visual inconsistency and made replay, focus handling and cleanup fixes repetitive.

## Decision

Use shared toolbar placement, briefing-page layout, result-card construction and common action dispatch. Activities advertise capabilities and provide text, choices, results and progression callbacks. They may override dimensions or arrangement when their content requires it, but ordinary pages use shared anchors and button sizes.

Advanced Play and Skill Training share their General / Race Specific catalogue structure. Reusable command-grid selectors may be extracted when future activities prove the same selection pattern.

## Consequences

- Common fixes apply across exercises.
- Visual and behavioral differences must be intentional activity requirements.
- Standardization stops at presentation and lifecycle boundaries; activity scoring and mechanics remain local.
- Future tutorials still need a dedicated shared progression system because briefing pages and exercise result cards do not cover tutorial checkpoints.
