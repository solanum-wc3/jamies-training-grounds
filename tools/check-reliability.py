"""Run lifecycle regressions in isolated fixture groups. No map is published.

Native mocks check orchestration; use the documented in-game acceptance pass
for Warcraft pathfinding, gathering, combat and save/load.
"""
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
os.chdir(ROOT)
sys.path.insert(0, str(ROOT / 'work/lua-test-runtime'))
from lupa import LuaRuntime

# A mocked UI helper must not silently invent an API missing from the map.
ui = (ROOT/'src/infrastructure/ui.lua').read_text(encoding='utf-8')
ui_exports = set(re.findall(r'(?:function\s+UI\.|UI\.)(\w+)\s*(?:\(|=)', ui))
hotkeys = (ROOT/'src/activities/hotkey-training.lua').read_text(encoding='utf-8')
missing_ui = set(re.findall(r'JTG\.UI\.(\w+)\s*\(', hotkeys)) - ui_exports
assert not missing_ui, f'Hotkey Trainer calls nonexistent shared UI APIs: {missing_ui}'

GROUPS = [
    ['generated-unit-cleanup'],
    ['menu-exit'],
    ['sound-preview'],
    ['button-sounds'],
    ['tutorial-standard'],
    ['tutorial-scenes'],
    ['heroes-tutorial'],
    ['camera-idle-navigation'],
    ['camera-scenes'],
    ['camera-production-scene'],
    ['camera-welcome-arrow', 'unit-controls-checkpoints'],
    ['tutorial-layout-workspace', 'economy-tutorial'],
    ['training-countdown'],
    ['training-presentation'],
    ['mining-timed'],
    ['mining-base-build'],
    ['setup-label'],
    ['quest-help'],
    ['reflex-training'],
    ['hotkey-training'],
    ['surrounds-formation'],
    ['catalog-layout'],
    ['windwalk-hero-order'],
    ['course-progression'],
    ['power-building'],
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
