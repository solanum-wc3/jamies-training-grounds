"""Check CustomKeys section casing and explicit overrides versus native defaults."""
import runpy
from pathlib import Path
prepare=runpy.run_path(str(Path(__file__).with_name('prepare-hotkey-comparison.py')))['prepare']
cases=[('spell','AOsh','Hotkey',None),('build','oalt','Hotkey','CmdBuildOrc')]
keys='[aosh]\nHotkey=E\n[oalt]\nHotkey=Q\n[cmdbuildorc]\nHotkey=B\n'
assert prepare(keys,cases)==[('spell',['E']),('build',['B','Q'])]
assert prepare('',[cases[0]],{'AOsh':{'hotkey':'W'}})==[('spell',['W'])]
assert prepare('[aosh]\nHotkey=\n',[cases[0]],{'AOsh':{'hotkey':'W'}})==[('spell',[])]
print('Passed: lowercase CustomKeys sections, submenu prefixes and explicit blank overrides.')
