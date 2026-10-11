-- Crowd movement must stay bounded, recover stalls, and survive presentation
-- restoration without spawning a second crowd or replaying its AI startup.
JTG = {UI = {}, Controller = {}}
local menu, orders, timers, camera, tracked = nil, {}, {}, {}, {}
local random, useMaximum = 0, false
function GetRandomInt(low, high) return useMaximum and high or low end
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
function SetUnitVertexColor(unit,r,g,b,alpha) unit.alpha=alpha end
function PauseUnit(unit,paused) unit.paused=paused end
function AddSpecialEffectTarget(model,unit) return {model=model,unit=unit} end
function JTG.ScopeTrackEffect(scope,effect) scope[#scope+1]=effect;return effect end
function CreateTrigger() return {} end
function JTG.ScopeTrackTrigger(_,trigger) return trigger end
local selectionTrigger
function TriggerRegisterPlayerUnitEvent(trigger,player,event)
    assert(player==0 and event==EVENT_PLAYER_UNIT_SELECTED)
    selectionTrigger=trigger
end
function TriggerRegisterUnitEvent() error('Reflex selection must register the selecting player') end
function TriggerAddAction(trigger,callback) trigger.action=callback end
local selectedUnit
function GetTriggerUnit() return selectedUnit end
function GetTriggerPlayer() return 0 end
function JTG.GuardSession(session,callback) return function() if session.active then callback() end end end
function BlzGetOriginFrame() return {} end
function BlzCreateFrameByType(kind,name) return {kind=kind,name=name} end
function JTG.ScopeTrackFrame(scope,frame) scope[#scope+1]=frame;return frame end
function BlzFrameSetSize(frame,w,h) frame.w,frame.h=w,h end
function BlzFrameSetAbsPoint(frame,point,x,y) frame.x,frame.y=x,y end
function BlzFrameClearAllPoints() end
function BlzFrameSetText(frame,text) frame.text=text end
function BlzFrameSetVisible(frame,visible) frame.visible=visible end
function BlzFrameSetAlpha(frame,alpha) frame.alpha=alpha end
function BlzFrameSetTexture(frame,texture) frame.texture=texture end
function BlzFrameSetTextAlignment() end
function BlzFrameSetScale() end
function BlzFrameSetEnable() end
function JTG.UI.CreateResultCard() return {} end
function JTG.UI.ShowResultCard(card,spec) card.spec=spec end
function JTG.GetSurroundCustomUnitIcon(code) return 'icon:'..code end
function IssuePointOrder(unit, order, x, y) orders[#orders+1] = {unit=unit,order=order,x=x,y=y}; return true end
function JTG.BorrowCamera() end
function JTG.ResetWorldFog() end
function JTG.ScopeRevealRect() end
function JTG.ScopeBorrow(scope, fn) scope[#scope+1] = fn end
function JTG.ScopeTrackUnit(scope, unit) tracked[#tracked+1] = unit; return unit end
function JTG.StartScopedTimer(session, scope, period, repeating, fn)
    local timer=setmetatable({period=period},{__call=function(self) if session.active and not self.paused then fn() end end})
    timers[#timers+1]=timer
    return timer
end
function PauseTimer(timer) timer.paused=true end
function JTG.GetSurroundCustomRaceColumns()
    return {{{kind="unit",enabled=true,rawcode="hpea"},
        {kind="unit",enabled=true,rawcode="Hamg",hero=true},
        {kind="unit",enabled=true,rawcode="hwat"},
        {kind="unit",enabled=true,rawcode="hwt2"},
        {kind="unit",enabled=true,rawcode="hwt3"},
        {kind="unit",enabled=true,rawcode="hfoo"},
        {kind="unit",enabled=true,rawcode="hmpr"},
        {kind="unit",enabled=true,rawcode="hkni"},
        {kind="unit",enabled=false,rawcode="hgry"}}}
end
function JTG.GetSurroundCustomSummonFamily(rawcode)
    if rawcode=='hwat' or rawcode=='hwt2' or rawcode=='hwt3' then return 'AHwe' end
end
function JTG.GetSurroundCustomSpawnRawcode(rawcode) return rawcode end
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
local session = {active=true,scope={},presentationScope={},descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local activity = JTG.CreateReflexTrainingActivity(session)
activity:setup(session); activity:start()
assert(#tracked == 21 and #activity.units == 21 and #timers == 2)
local counts = {}
for _, unit in ipairs(tracked) do counts[unit.code] = (counts[unit.code] or 0) + 1 end
assert(counts.hpea==4 and counts.Hamg==1)
assert(counts.hwat==2 and counts.hwt2==1 and counts.hwt3==1,
    'Summon population must be divided across levels')
assert(camera.x == 4864 and camera.y == 3456)
for _, unit in ipairs(tracked) do
    assert(unit.owner == 15 and unit.code ~= 'hgry')
    assert(unit.x >= activity.minX and unit.x <= activity.maxX and unit.y >= activity.minY and unit.y <= activity.maxY)
end
local function click(unit) selectedUnit=unit;selectionTrigger.action() end
local footmen,priest,knight={},nil,nil
for _,unit in ipairs(tracked) do
    if unit.code=='hfoo' then footmen[#footmen+1]=unit end
    if unit.code=='hmpr' then priest=unit end
    if unit.code=='hkni' then knight=unit end
end
click(footmen[1]);assert(activity.correct==0,'Countdown accepted a target')
activity:update();assert(#orders==0,'Crowd moved before GO')
assert(activity.status.text:find('3') and not activity.icons[1].visible)
timers[2]();assert(activity.countdown==2)
timers[2]();assert(activity.countdown==1)
timers[2]();assert(not activity.started and timers[2].paused)
assert(activity.icons[1].visible and activity.icons[1].w==0.064)
assert(activity.icons[1].texture=='icon:hfoo' and activity.icons[2].texture=='icon:hfoo')
for _=1,19 do timers[1]() end
assert(activity.icons[1].y==0.30 and not activity.started and activity.elapsed==0,
    'Popup must hold 0.4 seconds before GO and the exercise timer')
click(footmen[1]);assert(activity.correct==0,'Preview accepted a target before GO')
timers[1]();assert(activity.started and activity.elapsed==0 and #timers==3)
assert(activity.status.text:find('GO!',1,true))
local movementTimer=timers[3]
for _=1,5 do timers[1]() end
assert(activity.icons[1].y>0.30 and activity.icons[1].y<0.484,'Icons did not animate between positions')
activity:hidePresentationForMenu()
assert(not activity.icons[1].visible and not activity.status.visible)
click(footmen[1]);assert(activity.correct==0,'Hidden exercise accepted a target')
activity:restorePresentation();assert(activity.icons[1].visible)
for _=1,15 do timers[1]() end
assert(activity.icons[1].y==0.484 and activity.icons[1].w==0.032)
assert(timers[1].paused,'Finished cue should not continue its animation timer')
click(tracked[1].code=='hpea' and tracked[1] or {})
assert(activity.correct==0,'Wrong unit advanced targets')
click(footmen[1]);assert(activity.correct==1 and footmen[1].alpha==100 and activity.icons[1].alpha==65)
click(footmen[1]);assert(activity.correct==1,'Same Footman counted twice')
click(priest);assert(activity.correct==2 and activity.completed[3],'Targets must allow any order')
for _=1,12 do movementTimer() end
assert(#orders >= 21, 'Walkers did not receive independent orders')
local first = activity.units[1]
assert(first.targetX ~= activity.units[2].targetX or first.targetY ~= activity.units[2].targetY)
local before = #orders
for _=1,12 do movementTimer() end
assert(#orders > before, 'Blocked walkers did not choose a new destination')
for _, order in ipairs(orders) do
    assert(order.order == 'move' and order.x >= activity.minX and order.x <= activity.maxX)
    assert(order.y >= activity.minY and order.y <= activity.maxY)
end
first.unit.x = activity.maxX + 100
movementTimer(); assert(first.unit.x < activity.maxX)
local count, previousOrders = #tracked, #orders
activity:hidePresentationForMenu(); activity:restorePresentation()
activity:discardPresentationForLoad(); activity:rebuildPresentation()
assert(#tracked == count and #orders == previousOrders, 'Presentation replayed crowd setup')
assert(activity.correct==2 and activity.icons[1].alpha==65 and activity.icons[3].alpha==65)
click(footmen[2]);click(knight)
assert(activity.finished and activity.correct==4 and activity.resultCard.spec.tone=='success')
assert(not activity.icons[1].visible and not activity.status.visible)
for _,unit in ipairs(tracked) do assert(unit.paused) end
activity:hidePresentationForMenu();activity:restorePresentation()
assert(activity.resultCard.spec.visible,'Completed result did not restore')
activity:cleanup(); movementTimer(); assert(#orders == previousOrders)
session.active = false; movementTimer(); activity:afterCleanup(); assert(#activity.units == 0)
useMaximum=true
local upperSession={active=true,scope={},presentationScope={},descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local upper=JTG.CreateReflexTrainingActivity(upperSession);upper:setup(upperSession)
local upperCounts={}
for _,walker in ipairs(upper.units) do upperCounts[walker.unit.code]=(upperCounts[walker.unit.code] or 0)+1 end
assert(upperCounts.hpea==8 and upperCounts.Hamg==1)
assert(upperCounts.hwat==3 and upperCounts.hwt2==3 and upperCounts.hwt3==2)
-- Exercise the actual shared roster, rather than a mock that accepts invalid
-- native IDs. Previously the nonexistent hmtn produced nil in Warcraft.
dofile('src/activities/surrounds.lua')
local nativeIds={hpea=true,hmil=true,hfoo=true,hrif=true,hkni=true,hsor=true,hmpr=true,
    hspt=true,hmtm=true,hmtt=true,Hamg=true,Hmkg=true,Hpal=true,Hblm=true,hwat=true,hwt2=true,hwt3=true}
local originalCreateUnit=CreateUnit
function CreateUnit(owner,code,x,y,facing)
    assert(nativeIds[code],'Invalid Human ground native ID: '..tostring(code))
    return originalCreateUnit(owner,code,x,y,facing)
end
local realSession={active=true,scope={},presentationScope={},descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local real=JTG.CreateReflexTrainingActivity(realSession);real:setup(realSession)
local realCounts={}
for _,walker in ipairs(real.units) do realCounts[walker.unit.code]=(realCounts[walker.unit.code] or 0)+1 end
assert(realCounts.hmtm==8 and realCounts.hmtt==8 and #real.units==92)
print('Passed: Reflex population bounds, shared countdown, animated target cue, distinct any-order clicks, ethereal marking, movement, menu/load restoration, completion and cleanup guards.')
