# Standardization and reliability pass

This pass covers Camera, Unit Controls, Hotkey Setup, Economy & Workers, Bat Splitting and Dodging. No alpha was published. Narration wording, progression boundaries and gameplay choices were preserved.

## Implemented

- Four tutorial factories now install one shared runner/presenter for entry tracking, narration, toolbar/highlights, clicks and scoped timers. Disabled/disposed controls cannot dispatch actions or play sounds.
- Step-visit generations reject delayed callbacks after A → B → A, optional navigation and disposal. Camera attack/repair delays and Unit Controls wolf setup use that boundary. Persistent construction completion and cleanup retain session guards.
- Unit Controls restores movement props and declared departure cleanup on Back, Topics and optional returns. Repeated visits do not duplicate the formation Peasant or lose the siege engine.
- Economy uses named actions, stable step IDs and explicit canonical checkpoint scene records. Scene setup no longer inherits the obsolete observer-preview progression. Completed canonical practice scenes are distinct from a record of player actions.
- Economy guards actual construction through order/construction events, releases cancelled pending work and avoids reissuing gathering to dead workers or removed construction. Technology reset uses a shared melee catalogue.
- Bat Splitting and Dodging use common countdown and menu-presentation handling. Existing shared controller/scopes continue to own replacement, exit, cleanup and presentation reconstruction.
- Development builds provide `-economy-orders` to report requested/accepted/current worker orders and ownership in the log. These diagnostics distinguish order acceptance from observable gathering.

## Verification boundary

Automated Lua checks exercise real factories and controller paths with native mocks: entry/re-entry, checkpoint props, construction cancellation, ownership handoff, menu/result visibility, reset plans, command routing, countdowns and stale callbacks. Parsing and generator checks validate source/build inputs. They do not prove Warcraft's native targeting, pathfinding, mining, transformations or save serialization.

Passed: `tools/check-reliability.py` (21 Lua regression files), `tools/check-lua-sources.cjs` (23 release / 31 development modules, individually and assembled), Economy script validation/regeneration, disabled Hotkey export checks and timing-analysis checks. Both check commands operate without publishing a map.

## In-game acceptance before further feature work

1. In Economy, observe all four bases gathering from entry, then revisit each race. Check five gold workers, lumber workers and Ghouls; use `-economy-orders` if any stop. Start/cancel construction, then revisit the race. Check militia and the scripted attacks.
2. In Unit Controls, enter the movement/formation section, visit an optional section, return, use Back repeatedly and revisit Topics. Expect one siege engine and the appropriate single Peasant; obstacles disappear after their demonstration.
3. Across tutorials, check Continue/Back/Topics, pause, Menu/Resume, Exit and re-entry. Camera moves retain 1.5-second duration and arrows disappear with their narration.
4. In Dodging and Bat Splitting, open custom and native menus during countdown, an active trial and a result. Confirm no GO/status/result overlay leaks, pause is retained, Redo preserves the setup and advancing makes the intended new setup.
5. Save/load during a narration, an active demonstration, a countdown and a result. Confirm frames reconstruct without repeating world actions, duplicating units or restarting completed trials. Native save/load remains an acceptance test, not an automated guarantee.

Future changes should use these shared boundaries and add scene/native-interaction checks where mechanics differ. Dodging's matchup, scoring and enemy-order rules remain separate from presentation; this pass deliberately preserves those rules.
