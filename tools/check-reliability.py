"""Run lifecycle regressions in isolated fixture groups. No map is published.

Native mocks check orchestration; use the documented in-game acceptance pass
for Warcraft pathfinding, gathering, combat and save/load.
"""
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
os.chdir(ROOT)
sys.path.insert(0, str(ROOT / 'work/lua-test-runtime'))
from lupa import LuaRuntime

GROUPS = [
    ['tutorial-standard'],
    ['camera-welcome-arrow', 'unit-controls-checkpoints'],
    ['tutorial-layout-workspace', 'economy-tutorial'],
    ['training-countdown'],
    ['reflex-training'],
    ['native-log-handoff'],
    ['dodge-timing'],
    ['dodge-timing-batch'],
    ['training-orders', 'dodging-lifecycle', 'dodging-revisions',
     'dodging-phases', 'dodging-briefings', 'devour-modes', 'dodging-polish',
     'dodging-entry', 'area-training', 'bat-splitting',
     'training-standardization', 'training-menu-presentation'],
]
for group in GROUPS:
    runtime = LuaRuntime()
    for name in group:
        source = (ROOT / f'tools/test-{name}.lua').read_text(encoding='utf-8')
        runtime.execute(source)
print(f'Passed: {sum(map(len, GROUPS))} Lua regression files; no map published.')
