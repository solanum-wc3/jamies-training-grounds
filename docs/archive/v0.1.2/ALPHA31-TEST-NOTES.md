# Alpha 31 development checks

- Economy: verify Peons enter the gold mine. Gold workers now receive explicit Harvest orders. If they remain idle, type `-economy-orders` and report that the export is ready. The full report is written to `Documents/Warcraft III/CustomMapData/JTG-Economy-Orders.pld`; screenshots are unnecessary.
- The diagnostic report includes all racial workers, requested/accepted/current orders, owner, position, hidden state, Harvest ability, construction state and gold-mine target state. Its native preload wrapper is intentional for machine-readable diagnostics; user-facing text exports remain disabled.
- Economy: Back/Topics should preserve gathering workers, while restoring workers that are idle or missing. Human attackers should target the gold-mining Peasants.
- Dodging: open the custom menu during an exercise, then native F10 and Log. Custom surfaces should hide and return on closing the native menu. Check that Banshee is unavailable against all Orb effects.
- Bat Splitting: the first briefing should offer Normal Mode and Hard Mode directly.

Native gathering and native-menu behavior require an in-game check. Mock regressions verify orchestration and export completeness, not engine pathfinding.
