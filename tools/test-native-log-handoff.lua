-- Native upper-bar buttons must retain their engine-owned actions. The
-- handoff observes dialogs/hotkeys instead of registering frame click events.
local file=assert(io.open('src/infrastructure/ui.lua','r'))
local source=file:read('*a');file:close()
assert(not source:find('UI.nativeMenuTrigger',1,true))
assert(not source:find('UI.nativeSystemMouseTrigger',1,true))
assert(not source:find('ORIGIN_FRAME_SYSTEM_BUTTON',1,true))
assert(not source:find('ORIGIN_FRAME_ALLY_BUTTON',1,true))
assert(not source:find('ORIGIN_FRAME_CHAT_MSG_BUTTON',1,true))
local handler=assert(source:match('TriggerAddAction%(UI.nativeSystemKeyUpTrigger, function%(%)%s*(.-)%s*end%)%s*CreateRootPanel'))
local suspended=0
local UI={}
local nativeVisible=false
local environment={UI=UI,
 SuspendForNativeMenu=function() suspended=suspended+1 end,
 NativeMenuIsVisible=function() return nativeVisible end}
local action=assert(load('return function() '..handler..' end','native F10 key-up','t',environment))()
UI.menuVisible=true;action();assert(suspended==1)
UI.nativeMenuOpen=true;action();assert(suspended==1)
UI.nativeMenuOpen=false;UI.menuVisible=false;action();assert(suspended==1)
nativeVisible=true;action();assert(suspended==2)
UI.nativeKeyClosed=true;action();assert(suspended==2 and not UI.nativeKeyClosed)
assert(source:find('UI.nativeSystemKeyUpTrigger,',1,true),'Key-up hook must be disposed during UI rebuild')
assert(source:find('if NativeMenuIsVisible() then',1,true))
print('Passed: upper-bar buttons have no custom frame-event hooks; native dialog monitoring and paused F10 key handoff remain available.')
