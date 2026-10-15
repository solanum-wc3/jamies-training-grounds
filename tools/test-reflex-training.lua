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
function ConvertPlayerColor(id) return id end
function GetLocalPlayer() return 0 end
function FourCC(code) return code end
PLAYER_NEUTRAL_PASSIVE, PLAYER_COLOR_BLUE, UNIT_TYPE_DEAD, UNIT_TYPE_FLYING = 15, 1, "dead", "flying"
PLAYER_COLOR_RED=0
PLAYER_NEUTRAL_AGGRESSIVE=12
UNIT_TYPE_MAGIC_IMMUNE,UNIT_TYPE_MECHANICAL="immune","mechanical"
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
function SetUnitInvulnerable(unit,value) unit.invulnerable=value end
function SetUnitAcquireRange(unit,value) unit.acquire=value end
function SetUnitCreepGuard() end
function SetUnitVertexColor(unit,r,g,b,alpha) unit.alpha=alpha end
function BlzSetSpecialEffectAlpha(effect,alpha) effect.alpha=alpha end
function BlzSetSpecialEffectScale(effect,scale) effect.scale=scale end
function PauseUnit(unit,paused) unit.paused=paused end
local createdEffects={}
function AddSpecialEffectTarget(model,unit)
    local effect={model=model,unit=unit};createdEffects[#createdEffects+1]=effect;return effect
end
function DestroyEffect(effect) assert(not effect.destroyed,'Effect destroyed twice');effect.destroyed=true end
function JTG.ScopeAdd(scope,callback) scope[#scope+1]=callback;return callback end
function JTG.ScopeTrackEffect(scope,effect) scope[#scope+1]=function() DestroyEffect(effect) end;return effect end
function CreateTrigger() return {} end
function JTG.ScopeTrackTrigger(_,trigger) return trigger end
local selectionTrigger,damageTrigger
ALLIANCE_PASSIVE="passive"
EVENT_PLAYER_UNIT_DAMAGED="damaging"
local alliances={}
function GetPlayerAlliance(left,right) return alliances[left..":"..right]~=false end
function SetPlayerAlliance(left,right,kind,value) alliances[left..":"..right]=value end
UNIT_STATE_LIFE="life"
function GetUnitState(unit) return unit.life or 100 end
function SetUnitState(unit,state,value) unit.life=value end
function BlzGetUnitMaxHP() return 100 end
local effectTech={}
function GetPlayerTechCount(owner,raw) return (effectTech[owner] or {})[raw] or 0 end
function SetPlayerTechResearched(owner,raw,count) effectTech[owner]=effectTech[owner] or {};effectTech[owner][raw]=count end
function BlzSetUnitMaxMana(unit,value) unit.maxMana=value end
function SetHeroLevel(unit,value) unit.level=value end
function SelectHeroSkill() end
local incomingDamage=10
function GetEventDamage() return incomingDamage end
local interceptedDamage
function BlzSetEventDamage(value) interceptedDamage=value end
function TriggerRegisterPlayerUnitEvent(trigger,player,event)
    if event==EVENT_PLAYER_UNIT_DAMAGED then damageTrigger=trigger;return end
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
function JTG.ScopeTrackUnit(scope, unit) tracked[#tracked+1] = unit; scope[#scope+1]=function() unit.removed=true end; return unit end
function JTG.CreateScopedUnit(scope,...) return JTG.ScopeTrackUnit(scope,CreateUnit(...)) end
function JTG.CreateScope() return {} end
function JTG.DisposeScope(scope)
    if not scope or scope.disposed then return end
    scope.disposed=true
    for index=#scope,1,-1 do if type(scope[index])=='function' then scope[index]() end end
end
local castOrders,delayBuff,rejectCasts={},false,false
function UnitAddAbility(unit,code) unit.abilities=unit.abilities or {};unit.abilities[code]={};return true end
function UnitRemoveAbility(unit,code) if unit.buffs then unit.buffs[code]=nil end;return true end
function GetUnitAbilityLevel(unit,code) return unit.buffs and unit.buffs[code] and 1 or 0 end
function BlzGetUnitAbility(unit,code) return unit.abilities[code] end
function BlzSetUnitRealField(unit,field,value) unit[field or 'real']=value end
function BlzSetAbilityBooleanField(ability,field,value) ability[field or 'boolean']=value;return true end
ABILITY_BF_CHECK_DEPENDENCIES='dependencies'
function BlzSetAbilityIntegerLevelField(ability,field,level,value) ability[field or 'integer']=value;return true end
function BlzSetAbilityRealLevelField(ability,field,level,value) ability[field or 'real']=value;return true end
function SetUnitPathing(unit,value) unit.pathing=value end
function SetUnitX(unit,x) unit.x=x end
function SetUnitY(unit,y) unit.y=y end
ABILITY_ILF_MANA_COST,ABILITY_RLF_COOLDOWN='mana','cooldown'
ABILITY_RLF_DURATION_NORMAL,ABILITY_RLF_DURATION_HERO='duration','heroDuration'
ABILITY_RLF_AREA_OF_EFFECT,ABILITY_ILF_MAXIMUM_NUMBER_OF_TARGETS_SPL2='area','linkTargets'
UNIT_RF_CAST_POINT,UNIT_RF_CAST_BACK_SWING='castpoint','backswing'
local function nativeCast(caster,order,target)
    if order:sub(-3)=='off' then caster.autocastDisabled=order;return true end
    local effect
    for _,entry in ipairs(JTG.ReflexEffects) do if entry.order==order then effect=entry end end
    assert(effect and caster.abilities[effect.ability],'Incorrect native order/ability pair')
    assert(caster.code==effect.caster and caster.maxMana==1000,'Caster has no native mana/appropriate unit type')
    for raw,level in pairs(effect.research or {}) do assert(GetPlayerTechCount(caster.owner,raw)>=level,'Missing native spell research') end
    assert(caster.abilities[effect.ability].dependencies==false,'Dummy inherited melee research prerequisites')
    assert(caster.castpoint==0 and caster.backswing==0 and caster.alpha==0,'Dummy cast preparation incorrect')
    if not target then
        for index=#tracked,1,-1 do
            local unit=tracked[index]
            if not unit.removed and unit~=caster and unit.x==caster.x and unit.y==caster.y then target=unit;break end
        end
    end
    assert(target and not target.invulnerable,'Native effect requires vulnerable target')
    assert(caster.owner==(effect.debuff and 12 or 15),'Caster ownership did not match buff/debuff')
    if effect.area then assert(caster.abilities[effect.ability].area==1,'AoE leaked to neighboring units') end
    if effect.ability=='Aspl' then assert(caster.abilities.Aspl.linkTargets==1) end
    castOrders[#castOrders+1]={effect=effect,caster=caster,target=target}
    if not delayBuff and not rejectCasts then
        target.buffs=target.buffs or {};target.buffs[effect.buffs[1]]=true
    end
    return not rejectCasts
end
function IssueTargetOrder(caster,order,target) return nativeCast(caster,order,target) end
function IssueImmediateOrder(caster,order) return nativeCast(caster,order) end
function JTG.StartScopedTimer(session, scope, period, repeating, fn)
    local timer=setmetatable({period=period},{__call=function(self) if session.active and not self.paused then fn() end end})
    timers[#timers+1]=timer
    return timer
end
function PauseTimer(timer) timer.paused=true end
function JTG.GetSurroundCustomRaceColumns(race)
    if race=='orc' then return {{{kind='unit',enabled=true,rawcode='opeo'},
        {kind='unit',enabled=true,rawcode='ogru'},{kind='unit',enabled=true,rawcode='Obla',hero=true},
        {kind='unit',enabled=true,rawcode='osw1'},{kind='unit',enabled=true,rawcode='osw2'},
        {kind='unit',enabled=true,rawcode='osw3'}}} end
    return {{{kind="unit",enabled=true,rawcode="hpea"},
        {kind="unit",enabled=true,rawcode="Hamg",hero=true},
        {kind="unit",enabled=true,rawcode="hwat"},
        {kind="unit",enabled=true,rawcode="hwt2"},
        {kind="unit",enabled=true,rawcode="hwt3"},
        {kind="unit",enabled=true,rawcode="hfoo"},
        {kind="unit",enabled=true,rawcode="hmpr"},
        {kind="unit",enabled=true,rawcode="hkni"},
        {kind="unit",enabled=false,rawcode="hgry"},{kind="unit",enabled=true,rawcode="ushd"}}}
end
function JTG.GetSurroundCustomSummonFamily(rawcode)
    if rawcode=='hwat' or rawcode=='hwt2' or rawcode=='hwt3' then return 'AHwe' end
    if rawcode=='osw1' or rawcode=='osw2' or rawcode=='osw3' then return 'AOsf' end
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
function JTG.ExitActivityFromMenu() end
local launched
function JTG.StartActivityAfterCleanup(id) launched = id end
dofile('src/infrastructure/training.lua')
dofile('src/infrastructure/tutorial.lua')
dofile('src/generated/exercise-briefings.lua')
dofile('src/activities/reflex-training.lua')
JTG.OpenReflexTrainingMenu('skills', false)
assert(menu.pageId == 'root' and #menu.choices == 2 and menu.choices[1].label == 'Identify Units' and menu.choices[2].label == 'Reflex Test')
assert(menu.headingArtworkWidth==0.16 and menu.headingArtworkHeight==0.08)
menu.choices[1].action(); assert(menu.pageId=='races' and #menu.choices==4 and not menu.primaryEnabled)
for _,choice in ipairs(menu.choices) do
    assert(choice.x==nil and choice.y==nil and choice.width==nil and choice.height==nil,
        'Race buttons override shared briefing dimensions/placement')
    assert(choice.iconSize==0.0396 and choice.iconOffsetX==0.051)
end
menu.choices[1].action();assert(menu.choices[1].selected and menu.choices[1].enabled~=false and menu.primaryEnabled)
menu.choices[1].action();assert(not menu.choices[1].selected and not menu.primaryEnabled)
menu.choices[2].action();menu.primaryAction();assert(launched=='skills.reflex')
JTG.OpenReflexTrainingMenu('skills', true)
assert(menu.resumeAction and menu.exitAction and menu.backAction)
local ended=false
JTG.Controller.session={activity={finished=true}}
local stop=JTG.StopActivity
JTG.StopActivity=function(reason) assert(reason=='result-menu');ended=true;JTG.Controller.session=nil end
JTG.OpenReflexTrainingMenu('tools',true)
assert(ended and not menu.resumeAction and not menu.exitAction and not menu.pauseGame,
    'Completed Reflex menu offers Resume/Exit alongside a fresh Start')
JTG.StopActivity=stop
local session = {active=true,scope={},presentationScope={},restartData={identifyStage=4,identifyPlan={'hfoo','hfoo','hmpr','hkni','hfoo','hmpr','hkni','hfoo','hmpr','hkni'}},descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local activity = JTG.CreateReflexTrainingActivity(session)
activity:setup(session); activity:start()
assert(#tracked == 62 and #activity.units == 62 and #timers == 2)
local counts = {}
for _, unit in ipairs(tracked) do counts[unit.code] = (counts[unit.code] or 0) + 1 end
assert(counts.hpea>=2 and counts.Hamg==1 and counts.opeo>=2 and counts.Obla==1)
assert(counts.hwat==1 and counts.hwt2==1 and counts.hwt3==1 and counts.osw1==2 and counts.osw2==1 and counts.osw3==nil,
    'Summon population must be divided across levels')
assert(camera.x == 4864 and camera.y == 3456)
for _, unit in ipairs(tracked) do
    assert(unit.owner == 15 and unit.code ~= 'hgry' and unit.code~='ushd')
    assert(unit.color==(unit.code:sub(1,1):lower()=='o' and PLAYER_COLOR_RED or PLAYER_COLOR_BLUE))
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
assert(activity.icons[4].visible and activity.icons[4].w==0.064)
assert(activity.icons[1].texture=='icon:hfoo' and activity.icons[2].texture=='icon:hfoo')
for _=1,19 do timers[1]() end
assert(activity.icons[4].y==0.30 and not activity.started and activity.elapsed==0,
    'Popup must hold 0.4 seconds before GO and the exercise timer')
click(footmen[1]);assert(activity.correct==0,'Preview accepted a target before GO')
timers[1]();assert(activity.started and activity.elapsed==0 and #timers==3)
assert(activity.status.text:find('GO!',1,true))
local movementTimer=timers[3]
for _=1,5 do timers[1]() end
assert(activity.icons[4].y>0.30 and activity.icons[4].y<0.484,'New icon did not animate between positions')
activity:hidePresentationForMenu()
assert(not activity.icons[1].visible and not activity.status.visible)
click(footmen[1]);assert(activity.correct==0,'Hidden exercise accepted a target')
activity:restorePresentation();assert(activity.icons[1].visible)
for _=1,15 do timers[1]() end
assert(activity.icons[1].y==0.484 and activity.icons[1].w==0.032)
assert(activity.cueElapsed==0.7,'Finished cue must stop advancing until the next stage')
click(tracked[1].code=='hpea' and tracked[1] or {})
assert(activity.correct==0,'Wrong unit advanced targets')
click(footmen[1]);assert(activity.correct==1 and footmen[1].alpha==100 and activity.icons[1].alpha==65)
click(footmen[1]);assert(activity.correct==1,'Same Footman counted twice')
click(priest);assert(activity.correct==2 and activity.completed[3],'Targets must allow any order')
for _=1,12 do movementTimer() end
assert(#orders >= 20, 'Walkers did not receive independent orders')
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
assert(upperCounts.hpea>=4 and upperCounts.Hamg==1 and upperCounts.opeo>=4 and upperCounts.Obla==1)
assert(upperCounts.hwat==2 and upperCounts.hwt2==2 and upperCounts.hwt3==2)
-- Exercise the actual shared roster, rather than a mock that accepts invalid
-- native IDs. Previously the nonexistent hmtn produced nil in Warcraft.
dofile('src/activities/surrounds.lua')
local nativeIds={hpea=true,hmil=true,hfoo=true,hrif=true,hkni=true,hsor=true,hmpr=true,
    hspt=true,hmtm=true,hmtt=true,Hamg=true,Hmkg=true,Hpal=true,Hblm=true,hwat=true,hwt2=true,hwt3=true,
    opeo=true,ogru=true,ohun=true,otbk=true,ocat=true,oshm=true,odoc=true,orai=true,okod=true,
    ospw=true,otau=true,Obla=true,Ofar=true,Otch=true,Oshd=true,osw1=true,osw2=true,osw3=true,
    ewsp=true,earc=true,esen=true,ebal=true,edry=true,edoc=true,edcm=true,emtg=true,edot=true,
    Edem=true,Ekee=true,Emoo=true,Ewar=true,efon=true,espv=true,even=true,
    uaco=true,ugho=true,ucry=true,uban=true,unec=true,umtw=true,uabo=true,uobs=true,
    Udea=true,Udre=true,Ulic=true,Ucrl=true,uske=true,uskm=true,ninf=true,ucs1=true,ucs2=true,ucs3=true}
local nativeSnapshot={}
local snapshotFile=assert(io.open('src/data/native-unit-ids.json','r'))
for id in snapshotFile:read('*a'):gmatch('"(%w%w%w%w)"') do nativeSnapshot[id]=true end
snapshotFile:close()
for id in pairs(nativeIds) do assert(nativeSnapshot[id],'Fixture accepts nonexistent native unit: '..id) end
local originalCreateUnit=CreateUnit
function CreateUnit(owner,code,x,y,facing)
    assert(nativeSnapshot[code],'Invalid ground native ID: '..tostring(code))
    return originalCreateUnit(owner,code,x,y,facing)
end
local realSession={active=true,scope={},presentationScope={},descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local real=JTG.CreateReflexTrainingActivity(realSession);real:setup(realSession)
local realCounts={}
for _,walker in ipairs(real.units) do realCounts[walker.unit.code]=(realCounts[walker.unit.code] or 0)+1 end
assert(realCounts.hmtm>=1 and realCounts.hmtt<=2 and realCounts.ocat<=2 and #real.units==62)
print('Passed: Reflex population bounds, shared countdown, animated target cue, distinct any-order clicks, ethereal marking, movement, menu/load restoration, completion and cleanup guards.')

-- Both divided layouts must assign separate halves, not simply fill sorted
-- slots until one race runs out. Unequal populations still stay separated.
for _,layout in ipairs({2,3}) do
    local splitSession={active=true,scope={},presentationScope={},descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
    local split=JTG.CreateReflexTrainingActivity(splitSession)
    split.layout,split.vertical=layout,layout==2
    split:setup(splitSession)
    for _,walker in ipairs(split.units) do
        local coordinate=split.vertical and walker.unit.x or walker.unit.y
        local center=split.vertical and split.centerX or split.centerY
        assert((coordinate<center)==(walker.color==PLAYER_COLOR_BLUE),'Races mixed before divided setup')
    end
    local orderCount=#orders
    local firstTimer=#timers+1
    split:start()
    if layout==2 then
        assert(split.combat and not GetPlayerAlliance(1,2) and not GetPlayerAlliance(2,1))
        for _,walker in ipairs(split.units) do
            assert(walker.unit.owner==(walker.color==PLAYER_COLOR_BLUE and 1 or 2))
            assert(not walker.unit.invulnerable and walker.unit.acquire==600)
        end
        selectedUnit=split.units[1].unit;damageTrigger.action();assert(interceptedDamage==10,'Normal attacks must deal damage')
        selectedUnit.life=5;damageTrigger.action();assert(interceptedDamage==4,'Lethal volley must leave target alive')
        split:setPaused(true);timers[firstTimer]();assert(selectedUnit.life==5)
        split:setPaused(false);timers[firstTimer]();assert(selectedUnit.life==100,'One-second refresh must restore full health during countdown')
        split.finished=true;selectedUnit.life=40;timers[firstTimer]();assert(selectedUnit.life==40)
        split.finished=false

        assert(#orders==orderCount+#split.units,'Crossing must begin before countdown')
        assert(orders[#orders].order=='attack')
    else assert(#orders==orderCount,'Divided random walkers moved before countdown') end
end
local reflexSession={active=true,scope={},presentationScope={},restartData={mode='reflex'},descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local reflex=JTG.CreateReflexTrainingActivity(reflexSession)
reflex.layout=2;reflex:setup(reflexSession)
assert(#reflex.units==50)
for _,walker in ipairs(reflex.units) do assert(walker.unit.code~='osw3') end
local stationaryOrders=#orders
local timerStart=#timers
reflex:start()
local cue,countdown=timers[timerStart+1],timers[timerStart+2]
countdown();countdown();countdown()
for _=1,20 do cue() end
assert(reflex.started and reflex.marked and not reflex.icons[1].visible)
reflex:update();assert(#orders==stationaryOrders,'Reflex mode must never move, even in a crossing layout')
local reactionTimer=timers[timerStart+3]
reflex:setPaused(true);reactionTimer();assert(reflex.reactionElapsed==0)
reflex:setPaused(false)
for trial=1,10 do
    for _=1,12 do reactionTimer() end
    local marked,oldCaster,effect=reflex.marked,reflex.effectCaster,reflex.nativeEffect
    reflex:selectTarget({});assert(reflex.correct==trial-1,'Wrong click counted')
    reflex:hidePresentationForMenu()
    reflex:restorePresentation()
    reflex:selectTarget(marked)
    assert(reflex.correct==trial and oldCaster.removed and GetUnitAbilityLevel(marked,effect.buffs[1])==0 and marked.invulnerable,'Clicked native buff or caster was not cleaned up')
    if trial<10 then assert(reflex.marked~=marked) end
end
assert(reflex.finished and #reflex.reactions==10 and reflex.resultCard.spec.details:find('Average:'))
assert(reflex:captureResetState().mode=='reflex','Redo lost mode')
reflex:cleanup()
for _,dispose in ipairs(reflexSession.scope) do if type(dispose)=='function' then dispose() end end
print('Passed: divided crossing/random setups and ten timed native buff/debuff clicks with wrong-click, pause and presentation guards.')

local raceIds={'human','orc','nightelf','undead'}
for count=1,4 do
    local races={}
    for index=1,count do races[index]=raceIds[index] end
    for _,mode in ipairs({'identify','reflex'}) do for layout=1,3 do
        local groupSession={active=true,scope={},presentationScope={},restartData={mode=mode,races=races},
            descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
        local group=JTG.CreateReflexTrainingActivity(groupSession)
        group.layout=layout;group:setup(groupSession)
        assert(#group.units==(mode=='reflex' and 50 or 62) and group.raceCount==count)
        assert(#group:captureResetState().races==count)
        local counts={}
        for _,walker in ipairs(group.units) do
            counts[walker.unit.code]=(counts[walker.unit.code] or 0)+1
            -- Project convention: Human blue, Orc red, Night Elf teal,
            -- Undead purple. Keep this independent of the activity's table.
            assert(walker.unit.color==({1,0,2,3})[walker.raceIndex])
            if layout~=1 then
                local region=group.regions[walker.raceIndex]
                assert(walker.unit.x>region.minX and walker.unit.x<region.maxX)
                assert(walker.unit.y>region.minY and walker.unit.y<region.maxY)
            end
        end
        if mode=='identify' then
            local needed={}
            for _,raw in ipairs(group.targets) do needed[raw]=(needed[raw] or 0)+1 end
            for raw,amount in pairs(needed) do assert(counts[raw]>=amount) end
        end
        if count>=3 then assert((counts.Ewar or 0)<=1 and not counts.Ewdn,'Warden must use native ID and stay unique') end
        assert((counts.espv or 0)<=1 and (counts.hphx or 0)<=1,'Ultimate summons must be unique')
        if count==4 then assert(not counts.uin1,'Infernal must use native ninf') end
        local before=#orders;group.started=true;group:update()
        if mode=='reflex' then assert(#orders==before,'Selected races made reaction mode move') end
    end end
end
local undeadSession={active=true,scope={},presentationScope={},restartData={mode='identify',races={'undead'}},
    descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local undead=JTG.CreateReflexTrainingActivity(undeadSession)
undead:setup(undeadSession);undead:start()
assert(undead.raceCount==1 and #undead.targets==1 and
    (undead.targets[1]=='ugho' or undead.targets[1]=='ucry' or undead.targets[1]=='uabo'),'Undead-only startup failed')
print('Passed: one-to-four race budgets, colors, thirds/quadrants, native Warden, target availability and stationary reaction mode.')

-- Ten identification stages reuse the crowd and grow one persistent list.
local stagedSession={active=true,scope={},presentationScope={},restartData={mode='identify',races={'human','orc'}},
    descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local staged=JTG.CreateReflexTrainingActivity(stagedSession);staged:setup(stagedSession);staged:start()
local population=#staged.units
local planned={};for index,raw in ipairs(staged.targetPlan) do planned[index]=raw end
local rank={hfoo=1,hmpr=2,hkni=3}
for stage=1,10 do
    assert(staged.stage==stage and #staged.targets==stage)
    local requests={}
    for index,raw in ipairs(staged.targets) do
        assert(rank[raw] and (index==1 or rank[staged.targets[index-1]]<=rank[raw]),'Requests are not grouped by type/one race')
        requests[raw]=(requests[raw] or 0)+1
    end
    local previous={}
    for index=1,stage-1 do previous[planned[index]]=(previous[planned[index]] or 0)+1 end
    for raw,count in pairs(previous) do assert(requests[raw]>=count,'Stage dropped a previous request') end
    staged.started=true;staged.elapsed=0;staged.cueVisible=true;staged.cueElapsed=0
    staged:refreshIcons()
    local popped=0
    for index=1,stage do if staged.icons[index].w==0.064 then popped=popped+1 end end
    assert(popped==1,'Only the added icon should pop up')
    local score=staged.score
    local firstEffect=#createdEffects+1
    for _,raw in ipairs(staged.targets) do
        local candidate
        for _,walker in ipairs(staged.units) do if walker.rawcode==raw and not walker.accepted then candidate=walker.unit;break end end
        assert(candidate,'Stage cannot be completed with its crowd')
        staged.elapsed=staged.elapsed+0.5;staged.scoreElapsed=staged.elapsed;staged:selectTarget(candidate)
    end
    assert(staged.finished and staged.score==score+stage*15)
    assert(staged:nextStage()==(stage<10))
    if stage<10 then
        for index=firstEffect,#createdEffects do
            local effect=createdEffects[index]
            assert(effect.destroyed and effect.alpha==0 and effect.scale==0,'Stage left visible death particles')
        end
    end
    assert(#staged.units==population,'Continue recreated the crowd')
end
assert(staged.score==825 and staged:scoreStyle()=='|cffffcc00')
staged:hidePresentationForMenu();assert(not staged.scoreFrame.visible and not staged.resultScore.visible)
staged:cleanup()
print('Passed: ten growing, grouped single-race request lists; one-icon cues, available targets, cumulative timed scoring and unchanged crowd.')

-- All 15 nonempty race combinations, both modes, and low/high random draws
-- must fill the same screen budget, without expanding capped units to fill it.
for mask=1,15 do
    local races={}
    for index,id in ipairs(raceIds) do
        if math.floor(mask/2^(index-1))%2==1 then races[#races+1]=id end
    end
    for _,maximum in ipairs({false,true}) do
        useMaximum=maximum
        for _,mode in ipairs({'identify','reflex'}) do
            local populationSession={active=true,scope={},presentationScope={},restartData={mode=mode,races=races},
                descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
            local population=JTG.CreateReflexTrainingActivity(populationSession)
            population:setup(populationSession)
            local wanted=mode=='identify' and 62 or 50
            assert(#population.units==wanted,'Selected races changed screen density')
            local perRace,counts={},{}
            for _,walker in ipairs(population.units) do
                local code=walker.unit.code
                perRace[walker.raceIndex]=(perRace[walker.raceIndex] or 0)+1
                counts[code]=(counts[code] or 0)+1
            end
            for index=1,#races do
                local quota=math.floor(wanted/#races)+(index<=wanted%#races and 1 or 0)
                assert(perRace[index]==quota,'Race populations are not evenly divided')
            end
            for _,code in ipairs({'ocat','ebal','hmtt','umtw'}) do
                assert((counts[code] or 0)<=2,'War machine cap exceeded: '..code)
            end
            for _,code in ipairs({'Hamg','Hmkg','Hpal','Hblm','Obla','Ofar','Otch','Oshd',
                'Edem','Ekee','Emoo','Ewar','Udea','Udre','Ulic','Ucrl','espv','hphx'}) do
                assert((counts[code] or 0)<=1,'Unique hero or ultimate summon duplicated: '..code)
            end
            assert(not counts.osw3 and not counts.ushd,'Invisible units entered the crowd')
            if mode=='identify' then
                local needed={}
                for _,raw in ipairs(population.targets) do needed[raw]=(needed[raw] or 0)+1 end
                for raw,amount in pairs(needed) do assert((counts[raw] or 0)>=amount,'Required target removed') end
            end
        end
    end
end
print('Passed: all race subsets use exactly 62 identification / 50 reaction units, evenly divided, with war-machine and unique-unit caps.')

-- Verify the complete supported effect pool and targeting rules. Fake native
-- application can be delayed or rejected: no visual substitute may count.
local effectSession={active=true,scope={},presentationScope={},restartData={mode='reflex',races=raceIds},
    descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
local effects=JTG.CreateReflexTrainingActivity(effectSession)
effects:setup(effectSession);effects.started=true
assert(#effects.effectPool==21,'Buff/debuff pool lost a requested native effect')
local knownOrders={Ainf='innerfire',Aslo='slow',Aply='polymorph',AHbn='banish',Ablo='bloodlust',
    Alsh='lightningshield',Aspl='spiritlink',AOhx='hex',Aens='ensnare',Aroa='roar',Arej='rejuvination',
    AEer='entanglingroots',Afae='faeriefire',Acyc='cyclone',AEsh='shadowstrike',AUfu='frostarmor',
    Aam2='antimagicshell',Auhf='unholyfrenzy',Acrs='curse',Acri='cripple',AUsl='sleep'}
for _,effect in ipairs(JTG.ReflexEffects) do
    assert(knownOrders[effect.ability]==effect.order,'Unexpected ability or native order')
    local targets=effects:effectCandidates(effect)
    assert(#targets>0,'Supported effect lacks a valid target: '..effect.name)
    for _,unit in ipairs(targets) do
        local walker=effects.walkersByUnit[unit]
        assert(not walker.summon and not ({ocat=true,ebal=true,hmtt=true,umtw=true})[walker.rawcode])
        assert((walker.raceId==effect.race)==not effect.debuff,'Buff/debuff crossed the wrong faction')
        assert(not(effect.noHeroes and walker.hero),'Polymorph selected a hero')
    end
    effects.effectPool={effect};effects.failedEffects={};delayBuff=true
    effects:markNextTarget()
    local target,caster=effects.marked,effects.effectCaster
    assert(target and not effects.effectReady)
    local waiting=effects.effectWait
    effects.paused=true;effects:updateNativeEffect();assert(effects.effectWait==waiting)
    effects.paused=false;effects.presentationVisible=false;effects:updateNativeEffect();assert(effects.effectWait==waiting)
    effects.presentationVisible=true
    effects:updateNativeEffect();effects:selectTarget(target)
    assert(effects.correct==0 and effects.reactionElapsed==0,'Pending native cast started timing or accepted click')
    target.buffs=target.buffs or {};target.buffs[effect.buffs[1]]=true
    effects:updateNativeEffect()
    assert(effects.effectReady and effects.reactionElapsed==0,'Reaction clock did not wait for native buff onset')
    effects:updateNativeEffect();assert(effects.reactionElapsed==0.01)
    assert(effects.status.text:find(effect.name,1,true),'Current effect name missing from prompt')
    for _,buff in ipairs(effect.buffs) do target.buffs[buff]=true end
    local bystander=effects.units[1].unit
    bystander.buffs=bystander.buffs or {};bystander.buffs[effect.buffs[1]]=true
    effects:clearNativeEffect()
    for _,buff in ipairs(effect.buffs) do assert(GetUnitAbilityLevel(target,buff)==0,'Native buff survived cleanup') end
    assert(caster.removed and target.invulnerable and target.life==100,'Effect cleanup left caster or vulnerable target')
    assert(GetUnitAbilityLevel(bystander,effect.buffs[1])==0,'Previous trial effect remained on a bystander')
end
-- Intrinsic immunities must be rejected even for otherwise eligible factions.
local effect=JTG.ReflexEffects[1]
local candidate=effects:effectCandidates(effect)[1]
candidate.immune=true
for _,unit in ipairs(effects:effectCandidates(effect)) do assert(unit~=candidate) end
candidate.immune=false;candidate.mechanical=true
for _,unit in ipairs(effects:effectCandidates(effect)) do assert(unit~=candidate) end
candidate.mechanical=false
-- One race has its own buffs only: no fabricated enemy-race targets.
delayBuff=false
for _,race in ipairs(raceIds) do
    local soloSession={active=true,scope={},presentationScope={},restartData={mode='reflex',races={race}},
        descriptor={capabilities={}},scene={centerX=4864,centerY=3456}}
    local solo=JTG.CreateReflexTrainingActivity(soloSession);solo:setup(soloSession)
    assert(#solo.effectPool>0)
    for _,entry in ipairs(solo.effectPool) do assert(entry.race==race and not entry.debuff) end
    solo.started=true;solo:markNextTarget();solo:updateNativeEffect()
    assert(solo.effectReady and solo:nativeBuffPresent(),'Single-race buff setup failed: '..race)
    solo:clearNativeEffect()
end
-- Expired native buffs cannot leave an unclickable trial indefinitely.
effects.effectPool={JTG.ReflexEffects[1]};effects.failedEffects={};delayBuff=false
effects:markNextTarget();effects:updateNativeEffect()
local expiredTarget,expiredCaster=effects.marked,effects.effectCaster
UnitRemoveAbility(expiredTarget,'Binf')
for _=1,101 do effects:updateNativeEffect() end
assert(effects.marked~=expiredTarget and expiredCaster.removed and effects:nativeBuffPresent(),
    'Expired native effect did not get re-applied on an eligible target')
effects:clearNativeEffect()
-- Rejected applications retry three times, then show a bounded failure result;
-- they never silently fake the native effect or wait forever.
effects.effectPool={JTG.ReflexEffects[1]};effects.failedEffects={};rejectCasts=true;delayBuff=false
effects:markNextTarget()
local attempts=#castOrders
local failedFirstTarget=effects.marked
for _=1,305 do effects:updateNativeEffect() end
assert(#castOrders==attempts+2 and effects.finished and effects.effectError)
assert(castOrders[attempts+1].target~=failedFirstTarget,'Retry did not try another eligible target')
assert(not effects.marked and effects.resultCard.spec.tone=='failure','Unavailable native effect did not end safely')
rejectCasts=false
print('Passed: 21 native effects, race/target exclusions, native-onset timing, buff/caster cleanup, one-race buff pools and bounded failed applications.')
