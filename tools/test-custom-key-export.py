"""Exercise the actual exporter with the observed native output size limit.

This checks payload completeness, not clean-file output or native disk writes.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "work" / "lua-test-runtime"))
from lupa import LuaRuntime

lua = LuaRuntime()
lua.execute("""
JTG={Tutorial={}}
function Player(n) return n end
function GetLocalPlayer() return 0 end
shown={}
function DisplayTimedTextToPlayer(_,_,_,_,text) shown[#shown+1]=text end
function ClearTextMessages() end
function BlzGetOriginFrame() return nil end
JTG.UI=setmetatable({}, {__index=function() return function() end end})
""")
lua.execute((ROOT / "src/infrastructure/tutorial.lua").read_text(encoding="utf-8"))
lua.execute((ROOT / "src/generated/custom-keys.lua").read_text(encoding="utf-8"))
lua.execute((ROOT / "src/activities/hotkey-setup-tutorial.lua").read_text(encoding="utf-8"))

pending = []
written = {}


def clear():
    pending.clear()


def emit(value):
    escaped = value.replace("\\", "\\\\").encode("utf-8")
    assert len(escaped) <= 259, "Native Preload would truncate this payload"
    pending.append(escaped[:259].decode("utf-8"))


def finish(filename):
    # Remove only the known injection framing, then reverse native escaping
    # to compare the retained payload. These operations are test-only.
    parts = []
    for value in pending:
        assert value.startswith('\")\n') and value.endswith('\n//')
        parts.append(value[3:-3].replace("\\\\", "\\"))
    written[filename] = "\n".join(parts)


lua.globals().PreloadGenClear = clear
lua.globals().PreloadGenStart = lambda: None
lua.globals().Preload = emit
lua.globals().PreloadGenEnd = finish
lua.execute("""
local activity=JTG.CreateHotkeySetupTutorialActivity({})
assert(activity:exportCustomKeys()==false)
activity:showStep(1)
for i=1,40 do if activity.complete then break end; activity:continueTutorial() end
assert(activity.complete and activity.step==32)
for _,text in ipairs(shown) do
    assert(not text:find('Export',1,true))
    assert(not text:find('CustomMapData',1,true))
    assert(not text:find('README_ShortcutSetup',1,true))
    assert(not text:find('you can use this map to help set you up',1,true))
end
activity:showStep(16);activity:continueTutorial();assert(activity.step==21)
activity:goBack();assert(activity.step==16)
activity:showStep(13);activity:continueTutorial();assert(activity.step==15)
activity:goBack();assert(activity.step==13)
activity:restoreTopic(22);assert(activity.step==22)
""")
assert not written and not pending, "Disabled export must not write anything"
print("PASS: export is disabled; Continue/Back skip export steps; Topics remain stable")
# Retained payload is independently checked for eventual re-enablement.
for _, export in lua.globals().JTG.CustomKeyExports.items():
    clear()
    for _, chunk in export.chunks.items():
        emit('\")\n' + chunk + '\n//')
    finish(export.filename)
assert len(written) == 3
for filename, value in written.items():
    source = (ROOT / "src/data" / filename).read_text(encoding="utf-8")
    assert value.splitlines() == source.splitlines(), filename
    print(f"PASS: {filename}: all source lines survive the modeled native limit")
