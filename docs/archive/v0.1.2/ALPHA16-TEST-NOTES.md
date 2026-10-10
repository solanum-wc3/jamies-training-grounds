# 0.1.2 alpha 16 — Disjoining polish

This is a regular testing map. The next review should focus on **Dodging → Disjoining**, both Abilities and Attacks. Avoiding receives the shared timing/colour improvements, but its final gameplay and wording review comes afterward.

## Changes

- Reviewed native measurements now live in `design/dodge-activation-measurements.json` and are applied when regenerating the catalogue. Tooltips separate measured cast point, fade and observed activation; transformation entries no longer retain the old unmeasured placeholder where a valid measurement exists. Values are approximate and identify the observed state, not a universal projectile-disjoin boundary.
- Town Portal explicitly separates immediate protection from the five-second teleport. Wind Walk and Mirror Image use separate phase behavior despite sharing one Blademaster entry. The Archer's unverified mounting timing retains the approved loading estimate.
- Pawn and enemy phase words use exactly the same RGB colours as the models: green ready/active/fired, red wind-up, yellow waiting/activating. Native state changes drive invisibility, protection, form changes, loading and replacement. Unrelated automatic spells and partial setup summons do not overwrite these phases. Ranged wind-up remains an animation estimate.
- Mount/dismount and resummoned units inherit the displayed phase colour. The old projectile target remains the target for outcome observation rather than silently retargeting the incoming shot to a replacement unit.
- A loaded pawn no longer stops the resolution check. Intentional removal/replacement no longer prematurely resets the stage before the projectile outcome resolves.
- Wisp and stationary-stage Peon loading setups use the support's actual native position to place the pawn near its entry edge. Ordinary movement remains disabled in stages two and three.
- Future diagnostic actions use the verified Destroyer order and point-targeted Detonate route. Explicit immediate Detonate retest controls remain available in development instrumentation.

## Test order

1. **Timing and colours:** Storm Bolt against Wind Walk, Mirror Image, Shadowmeld and Invisibility Potion. Confirm the red/yellow/green text matches the models. Mirror Image should activate on its hidden/protected state rather than wait for invisibility. Test Avatar, Destroyer, Bear Form, Metamorphosis and Robo-Goblin for immediate versus delayed activation. Try Town Portal against a valid threat and check protection starts before teleporting.
2. **Loading and replacement:** test Wisp mine entry/build/Detonate, Peon Burrow entry/build, Zeppelin loading, Feral Spirit resummoning and Rider dismount. Check three consecutive successes can finish a stage rather than silently reset or stall. Verify a hit still produces TOO LATE and an interrupted enemy cast still follows the existing pre-launch rules. Test Archer mounting manually as well; the automated Archer-initiated merge remains unverified.
3. **All three stages:** use Storm Bolt, Ensnare and one orb effect; then repeat with a normal ranged attacker. Check the half-range approach in stage three, facing in stage one, stationary behavior in stages two/three, one-second verdict transitions and streak reset on failure.
4. **Menu and result polish:** inspect measured tooltips, disabled matchup explanations and line wrapping. Open Menu during casting, fading, a pending verdict and an end card. Test Resume, Back, Setups, Redo, Next Stage and Exit; check stale text, tint or replacement units do not survive cleanup.

Green means the displayed ability phase is ready/active, not immunity to every attack. Native events and sampled states were measured in the current map setup; not every ability/projectile matchup has been independently established. This pass intentionally retains existing outcome rules while fixing the identified loaded/replaced-pawn resolution problems.

## Automated validation

Synthetic checks cover lifecycle/cleanup across the catalogue, stage orchestration, navigation restoration, results, measured tooltip data, matching text/model colours, Mirror Image versus Wind Walk, immediate/delayed morphs, protection before teleport, loading resolution and intentional removal. Build validation covers Lua syntax, archive roundtrip, unchanged foundation/members and release/development separation. Native gameplay and visual polish still require the test above.
