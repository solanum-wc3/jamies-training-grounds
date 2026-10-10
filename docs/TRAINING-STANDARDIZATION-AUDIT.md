# Bat Splitting and Dodging standardization audit

Reviewed on 2026-10-07 against the shared controller, scope ownership, briefing menus and result cards.

## Corrected

| Deviation | Correction |
| --- | --- |
| Bat Splitting returned to the former Human skill submenu | Back returns to the current Skill Training catalogue. |
| Its mode page lacked live-exercise Resume/Exit controls | Both briefing pages use the same configuration wrapper and pause rules. |
| Neither exercise recorded configuration pages for loading | Pages supply their origin, stable page ID and selection data; menu functions restore them. |
| Some Dodging Back actions skipped the preceding selector | Back preserves the selected danger/race and returns to that selector, including Movement confirmation. |
| Timers duplicated tracking and stale-session guards | Both exercises use the existing `StartScopedTimer` helper. |
| Dodging carried a partial summon-number table | Unit choices use the shared badge lookup. |
| Restoring a finished Bat Splitting card showed the toolbar | Result rendering always hides the toolbar. |
| Devour restoration temporarily marked the exercise unfinished and reran completion | Rendering the saved Devour result is separate from completion. |
| Both activities retained unused Hide result handlers | Only supported Next overrides remain; Redo and Menu use shared dispatch. |
| Neither activity had explicit semantic cleanup | Cleanup clears feedback, selection and references; scopes retain responsibility for destroying resources. |
| Obsolete Dodging pagination duplicated a confirmation path | Artillery uses a single selector; all confirmations use the common confirmation page. |

## Retained deliberately

- Shared `ShowActivityBriefing`, command grids, toolbar capabilities and result cards were already in use. They remain the presentation boundary.
- Unit rosters reuse the Surrounds racial selector. Homing/ability category columns retain the user's requested arrangements.
- Gameplay state uses scoped units, triggers, fog, camera borrowing, alliances, resources, research and time-of-day restoration. Dodging's baseline-aware sweep remains necessary for engine-created/morphed handles that do not reliably emit summon events.
- Redo uses the shared controller's deferred cleanup/restart. Bat Splitting retains its approach plan on Redo and generates a new plan for a new stage. Dodging retains the chosen matchup and stage; only automatic successful repeats preserve the streak.
- Scoring, staged casts, restrictions, chase behavior and collision/range indicators remain activity-specific. This pass does not remove categories or redesign exercises.

## Verification

Follow-up on 2026-10-08: all shared briefing and catalogue entry points now
hide the active exercise's presentation. This covers the toolbar's Menu/Setups
route as well as nested Back navigation, which previously left Dodging's GO
and status text above the menu. Ability headings center over their occupied
columns. The Dodging status frame uses an explicit 1.5 display scale.

`tools/test-training-menu-presentation.lua` additionally runs the real shared
menu functions with both new activities' presentation hooks. It checks hiding
GO/status/results, heading alignment, and resuming without releasing an
independent exercise pause.

`tools/test-training-standardization.lua` runs after the existing order, lifecycle, revision and Bat Splitting mock tests. It checks every configuration page's restore data, Back routes, Resume/Exit availability, finished-card toolbar state and pure Devour result restoration. It then loads the actual shared controller and scopes to check disposal and stale timer guards.

The broader tests cover 106 native order routes, 102 staged setups, cleanup sweeps, timing verdicts, menu eligibility and Bat Splitting's three outcomes. These are orchestration tests, not evidence that native Warcraft physics or save serialization behaves correctly.

In-game acceptance for the next requested alpha:

1. From both Bat Splitting pages, test Back, Resume and Exit during countdown, play and the result.
2. Save/load on each Dodging selector and confirmation page; check the selected danger, race and method remain intact.
3. Redo, switch exercises and exit after summons, morphs, construction, transport loading and Devour. Check for remaining units, markers or changed borrowed state.
4. Open and return from the menu after every result; the result card should return with the toolbar hidden.
5. Check Bat Splitting Redo repeats its approach, while Next advances to a newly generated approach.
