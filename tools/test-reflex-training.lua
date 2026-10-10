-- Crowd movement must stay bounded, recover stalls, and survive presentation
-- restoration without spawning a second crowd or replaying its AI startup.
JTG = {UI = {}, Controller = {}}
local menu, orders, timers, camera, tracked = nil, {}, {}, {}, {}
local random = 0
function GetRandomInt(low, high) return low end
function GetRandomReal(low, high)
    random = (random + 0.371) % 1
    return low + (high - low) * random
end
function Player(id) return id end
function GetLocalPlayer() return 0 end
function FourCC(code) return code end
PLAYER_NEUTRAL_PASSIVE, PLAYER_COLOR_BLUE, UNIT_TYPE_DEAD, UNIT_TYPE_FLYING = 15, 1, "dead", "flying"
GAME_STATE_TIME_OF_DAY = "time"
CAMERA_FIELD_ROTATION, CAMERA_FIELD_ANGLE_OF_ATTACK = "rotation", "angle"
function GetFloatGameState() return 7 end
function GetTimeOfDayScale() return 1 end
function SetFloatGameState() end
function SetTimeOfDayScale() end
function SetCameraField(key, value) camera[key] = value end
function SetCameraPosition(x, y) camera.x, camera.y = x, y end
function ClearSelection() end
function CreateUnit(owner, code, x, y, facing) return {owner=owner,code=code,x=x,y=y,facing=facing} end
function GetUnitTypeId(unit) return unit.code end
function IsUnitType(unit, kind) return unit[kind] == true end
function GetUnitX(unit) return unit.x end
function GetUnitY(unit) return unit.y end
function SetUnitPosition(unit, x, y) unit.x, unit.y = x, y end
function SetUnitColor(unit, color) unit.color = color end
function SetUnitInvulnerable() end
function SetUnitAcquireRange() end
function SetUnitCreepGuard() end
function IssuePointOrder(unit, order, x, y) orders[#orders+1] = {unit=unit,order=order,x=x,y=y}; return true end
function JTG.BorrowCamera() end
function JTG.ResetWorldFog() end
function JTG.ScopeRevealRect() end
function JTG.ScopeBorrow(scope, fn) scope[#scope+1] = fn end
function JTG.ScopeTrackUnit(scope, unit) tracked[#tracked+1] = unit; return unit end
function JTG.StartScopedTimer(session, scope, period, repeating, fn)
    timers[#timers+1] = function() if session.active then fn() end end
end
function JTG.GetSurroundCustomRaceColumns()
    return {{{kind="unit",enabled=true,rawcode="hpea"},
        {kind="unit",enabled=true,rawcode="Hamg",hero=true},
        {kind="unit",enabled=false,rawcode="hgry"}}}
end
function JTG.UI.ShowActivityBriefing(spec) menu = spec end
function JTG.UI.SetGameplayMenuPaused() end
function JTG.UI.ShowCategory() end
function JTG.UI.ShowToolbar() end
function JTG.UI.HideToolbar() end
function JTG.UI.HideResultCard() end
function JTG.UI.HideActivityBriefing() end
function JTG.ResumeActivity() end
function JTG.StopActivity() end
local launched
function JTG.StartActivityAfterCleanup(id) launched = id end
dofile('src/infrastructure/training.lua')
dofile('src/activities/reflex-training.lua')
JTG.OpenReflexTrainingMenu('skills', false)
assert(menu.pageId == 'root' and #menu.choices == 1 and menu.choices[1].label == 'Start Training')
menu.choices[1].action(); assert(launched == 'skills.reflex')
JTG.OpenReflexTrainingMenu('skills', true)
assert(menu.resumeAction and menu.exitAction and menu.backAction)
local session = {active=true,scope={},descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local activity = JTG.CreateReflexTrainingActivity(session)
activity:setup(session); activity:start()
assert(#tracked == 12 and #activity.units == 12 and #timers == 1)
assert(camera.x == 4864 and camera.y == 3456)
for _, unit in ipairs(tracked) do
    assert(unit.owner == 15 and unit.code ~= 'hgry')
    assert(unit.x >= activity.minX and unit.x <= activity.maxX and unit.y >= activity.minY and unit.y <= activity.maxY)
end
for _=1,12 do timers[1]() end
assert(#orders >= 12, 'Walkers did not receive independent orders')
local first = activity.units[1]
assert(first.targetX ~= activity.units[2].targetX or first.targetY ~= activity.units[2].targetY)
local before = #orders
for _=1,12 do timers[1]() end
assert(#orders > before, 'Blocked walkers did not choose a new destination')
for _, order in ipairs(orders) do
    assert(order.order == 'move' and order.x >= activity.minX and order.x <= activity.maxX)
    assert(order.y >= activity.minY and order.y <= activity.maxY)
end
first.unit.x = activity.maxX + 100
timers[1](); assert(first.unit.x < activity.maxX)
local count, previousOrders = #tracked, #orders
activity:hidePresentationForMenu(); activity:restorePresentation()
activity:discardPresentationForLoad(); activity:rebuildPresentation()
assert(#tracked == count and #orders == previousOrders, 'Presentation replayed crowd setup')
activity:cleanup(); timers[1](); assert(#orders == previousOrders)
session.active = false; timers[1](); activity:afterCleanup(); assert(#activity.units == 0)
print('Passed: Reflex direct briefing entry, ground crowd, bounded independent movement, stall/edge recovery, menu/load restoration and cleanup guards.')
