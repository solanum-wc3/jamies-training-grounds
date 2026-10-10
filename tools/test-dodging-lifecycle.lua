-- Native mocks exercise every dodge setup and cleanup, including replacement
-- handles that do not fire a summon event. Run after test-training-orders.lua.
local units, enumUnit, eventId, summoned = {}, nil, nil, nil
local triggers, resetCount, lastTimer = {}, 0, nil
local constants = {UNIT_TYPE_DEAD=true, UNIT_TYPE_HERO=true, UNIT_TYPE_FLYING=true,
    UNIT_TYPE_MECHANICAL=true, UNIT_TYPE_STRUCTURE=true}
setmetatable(_G, {__index = function(_, key)
    if key:match('^[A-Z][A-Z0-9_]+$') then rawset(_G,key,key); return key end
    local fn = function() return 0 end
    rawset(_G,key,fn); return fn
end})
function Player(id) return id end
function GetUnitLevel() return 1 end
function GetOwningPlayer(unit) return unit.owner end
function IsUnitType(unit, kind)
    if kind == UNIT_TYPE_DEAD then return unit.dead == true end
    if kind == UNIT_TYPE_HERO then return unit.id:sub(1,1):match('%u') ~= nil end
    return false
end
function CreateUnit(owner,id,x,y,facing)
    local unit={owner=owner,id=id,x=x,y=y,facing=facing}
    units[#units+1]=unit; return unit
end
function RemoveUnit(unit) unit.removed=true end
function SetUnitInvulnerable(unit,value) unit.invulnerable=value end
function SetUnitCreepGuard(unit,value) unit.creepGuard=value end
function RemoveGuardPosition(unit) unit.guardRemoved=true end
function SetUnitX(unit,x) unit.x=x end
function SetUnitY(unit,y) unit.y=y end
function SetUnitFacing(unit,facing) unit.facing=facing end
function BlzSetUnitFacingEx(unit,facing) unit.facing=facing end
function SetUnitMoveSpeed(unit,speed) unit.speed=speed end
function GetUnitMoveSpeed(unit)
    if unit.id:match('^osp[123]$') or unit.id:match('^[houe].tw$') then return 0 end
    return unit.speed or 270
end
function GetHeroSkillPoints() return 0 end
function BlzGetUnitAbility() return {} end
function CreateGroup() return {} end
function GroupEnumUnitsOfPlayer(group,owner)
    for _,unit in ipairs(units) do if not unit.removed and unit.owner==owner then group[#group+1]=unit end end
end
function ForGroup(group,callback) for _,unit in ipairs(group) do enumUnit=unit; callback() end end
function GetEnumUnit() return enumUnit end
function GroupClear(group) for i=#group,1,-1 do group[i]=nil end end
function DestroyGroup() end
function UnitItemInSlot() return nil end
function IsUnitInvisible() return false end
function IsUnitHidden() return false end
function UnitAddItemById() return {} end
function CreateTrigger() local t={events={}}; triggers[#triggers+1]=t; return t end
function TriggerRegisterPlayerUnitEvent(t,player,event) t.events[#t.events+1]={player,event} end
function TriggerAddAction(t,action) t.action=action end
function GetTriggerEventId() return eventId end
function GetSummonedUnit() return summoned end
function GetConstructingStructure() return nil end
function IssueImmediateOrder(unit,order)
    if order=='spiritwolf' then
        summoned=CreateUnit(unit.owner,'osw1',unit.x,unit.y,0)
        eventId=EVENT_PLAYER_UNIT_SUMMON
        for _,t in ipairs(triggers) do
            for _,event in ipairs(t.events) do
                if event[1]==unit.owner and event[2]==eventId then t.action() end
            end
        end
    end
    return true
end
function CreateTimer() return {} end
function TimerStart(timer,period,repeating,callback) timer.callback=callback; timer.period=period; lastTimer=timer end
function CreateQuest() return {} end
function BlzCreateFrameByType() return {} end
JTG.UI={HideActivityBriefing=function() end, CreateResultCard=function() return {} end, ShowResultCard=function() end,
    ShowToolbar=function() end, HideToolbar=function() end, HideResultCard=function() end}
function JTG.ScopeAdd(scope,fn) scope[#scope+1]=fn end
function JTG.ScopeBorrow(scope,fn) JTG.ScopeAdd(scope,fn) end
function JTG.ScopeTrackUnit(scope,unit) JTG.ScopeAdd(scope,function() RemoveUnit(unit) end); return unit end
function JTG.ScopeTrackTrigger(scope,t) return t end
function JTG.ScopeTrackTimer(scope,t) return t end
function JTG.StartScopedTimer(session,scope,period,periodic,fn)
    local timer=JTG.ScopeTrackTimer(scope,CreateTimer())
    TimerStart(timer,period,periodic,JTG.GuardSession(session,fn)); return timer
end
function JTG.ScopeTrackQuest(scope,q) return q end
function JTG.ScopeTrackFrame(scope,f) return f end
function JTG.ScopeTrackImage(scope,image) return image end
function JTG.ScopeTrackGroup(scope,group) return group end
function JTG.ScopeTrackFogModifier(scope,modifier) return modifier end
function CreateImage() return {} end
function JTG.GuardSession(session,fn) return fn end
function JTG.BorrowCamera() end
function JTG.ClearBlightAfterActivity() end
function JTG.ResetWorldFog() end
function JTG.ScopeRevealScene() end
function JTG.ScopeRevealRect() end
function JTG.FormatSurroundQuestText(s) return s end
function JTG.ResetActivity() resetCount=resetCount+1 end
local foundation=CreateUnit(0,'hfoo',0,0,0)
for index in ipairs(JTG.DodgePawns) do
    for stage=1,3 do
        triggers={}
        local session={restartData={pawnIndex=index,stage=stage}, scope={}, presentationScope={},
            scene={centerX=0,centerY=0},descriptor={capabilities={}}}
        local activity=JTG.CreateMissileDodgingActivity(session)
        activity:setup(session)
        assert(activity.target and activity.pawn,activity.definition.name)
        assert(activity.pawn.facing==((activity.definition.mine or activity.definition.support=="otrb") and 90 or (activity.definition.targetSupport and 270 or (stage==1 and 180 or 0))))
        if stage>1 then assert(activity.pawn.speed==0) end
        local orphan=CreateUnit(0,'ugar',5000,5000,0)
        for i=#session.scope,1,-1 do session.scope[i]() end
        assert(orphan.removed,'Unreported transformation outside arena was not removed')
        assert(not foundation.removed,'Foundation unit was removed')
        for _,unit in ipairs(units) do assert(unit==foundation or unit.removed,'Leaked '..unit.id) end
    end
end
local session={restartData={pawnIndex=5},scope={},presentationScope={},descriptor={capabilities={}}}
local activity=JTG.CreateMissileDodgingActivity(session)
activity.caster={id='Ofar',x=600,y=0}; activity.target={id='Obla',x=0,y=0}
activity.trialTime=100
activity:updateTrial()
assert(not activity.finished,'No cast must never earn success')
for success=1,3 do
    activity:confirmCast(); activity:recordDodge(); activity.trialTime=activity.castTime+activity.resolveAfter; activity:updateTrial()
    assert(lastTimer.period==1 and activity.streak==success-1)
    lastTimer.callback()
    assert(activity.streak==success)
    if success<3 then
        assert(not activity.finished and activity.repeatPending)
        assert(activity:captureResetState().streak==success)
        activity=JTG.CreateMissileDodgingActivity({restartData=activity:captureResetState()})
        activity.caster={id='Ofar',x=600,y=0}; activity.target={id='Obla',x=0,y=0}
    end
end
assert(activity.finished and activity.streak==3,'Third verdict must end the stage')
activity:nextStage()
assert(activity.stage==2 and resetCount==3)
local hit=JTG.CreateMissileDodgingActivity(session)
hit:resetAfterHit()
assert(hit.resetPending and lastTimer.period==1)
lastTimer.callback(); assert(resetCount==4)
local early=JTG.CreateMissileDodgingActivity({restartData={streak=2,pawnIndex=5}})
early:recordDodge(); assert(not early.pendingVerdict); early.casting=true; early:castStopped(); assert(early.pendingVerdict=='TOO EARLY!' and lastTimer.period==1)
lastTimer.callback(); assert(early.streak==0 and resetCount==5)
local late=JTG.CreateMissileDodgingActivity(session)
late.caster={id='Ofar',x=600,y=0}; late.target={id='Obla',x=0,y=0}
late:confirmCast(); late:recordDodge(); late.trialTime=late.castTime+late.resolveAfter; late:updateTrial()
local staleTimer=lastTimer
late:resetAfterHit(); assert(late.pendingVerdict=='TOO LATE!')
staleTimer.callback(); assert(resetCount==5,'A replaced verdict must not increment')
lastTimer.callback(); assert(late.streak==0 and resetCount==6)
local screen, launched, resumed
JTG.Controller={}
JTG.UI.SetGameplayMenuPaused=function() end
JTG.UI.ShowActivityBriefing=function(spec) screen=spec end
JTG.UI.ShowCategory=function() end
JTG.StartActivityAfterCleanup=function(id,category,state) launched=state end
JTG.ResumeActivity=function() resumed=true end
JTG.StopActivity=function() JTG.Controller.session=nil end
function JTG.GetSurroundCustomRaceColumns() return {{{rawcode='hfoo',label='Footman'},{rawcode='hrif',label='Rifleman'},{rawcode='hgry',label='Gryphon Rider'}}} end
function JTG.GetSurroundCustomUnitIcon() return 'icon' end
for index,name in ipairs({'Homing','Ranged','Artillery','Area','Devour'}) do
    JTG.OpenMissileDodgingMenu('skills',false)
    assert(#screen.choices==2 and screen.choices[1].label=='Disjoining' and screen.choices[2].label=='Avoiding')
    if name=='Artillery' then
        JTG.OpenMissileDodgingMenu('skills',false,'artillery')
    else
        screen.choices[(name=='Area' or name=='Devour') and 2 or 1].action()
        screen.choices[(name=='Ranged' or name=='Devour') and 2 or 1].action()
    end
    if name=='Homing' or name=='Area' then
        if name=='Area' then
            assert(screen.pageId=='area_intro'); screen.choices[1].action()
        end
        assert(#screen.commandGridHeadings==(name=='Homing' and 2 or 5))
        assert(screen.commandGridColumns==(name=='Homing' and 3 or 9))
        screen.choices[1].action()
    elseif name=='Ranged' then
        assert(#screen.choices==5)
        screen.choices[1].action()
        assert(screen.choices[1].enabled==false and screen.choices[2].enabled==false)
        assert(screen.choices[3].enabled==true)
        screen.choices[3].action()
    elseif name~='Devour' then screen.choices[1].action() end
    if name=='Homing' or name=='Ranged' then
        assert(#screen.commandGridHeadings==6 and screen.commandGridColumns==14)
        assert(#screen.choices==33)
        local columns={}
        for _,choice in ipairs(screen.choices) do columns[choice.column]=true end
        for _,col in ipairs({0,2,4,7,10,12}) do assert(columns[col]) end
        screen.choices[1].action()
    else
        assert(screen.choices[1].label=='Movement' and screen.choices[2].label=='Ability')
        screen.choices[1].action(); screen.choices[1].action(); screen.choices[1].action()
    end
    if name=='Artillery' then
        assert(screen.choices[1].label=='Begin')
        screen.choices[1].action()
    else assert(launched.startDelay==true) end
    assert(launched.stage==1)
end
for _,entry in ipairs(JTG.DodgePawns) do
    if entry.item then assert(entry.unit=='Ntin' and #entry.removeAbilities==4) end
    if entry.supportItem then assert(entry.support=='Ntin' and entry.selectSupport and #entry.removeSupportAbilities==4) end
    if entry.name=='Shadowmeld' then assert(entry.icon:find('BTNAmbush',1,true)) end
end
JTG.Controller.session={id='skills.missile_dodging',activity=activity}
JTG.OpenMissileDodgingMenu('skills',true)
assert(screen.resumeAction and screen.exitAction)
screen.resumeAction(); assert(resumed)
screen.exitAction(); assert(screen.choices[1].label=='Disjoining' and not screen.resumeAction)
print('Passed: 101 staged setups and cleanup sweeps, preserved foundation, no-cast rejection, success and stage progression.')
print('Passed: hit reset, five category menu routes, resume and exit recovery.')
local walkSession={restartData={stage=2},scope={},presentationScope={},scene={centerX=0,centerY=0},descriptor={capabilities={}}}
local walkActivity=JTG.CreateMissileDodgingActivity(walkSession)
triggers={}; walkActivity:setup(walkSession)
function OrderId(value) return value end
function GetUnitCurrentOrder(unit) return unit.order end
local issued='move'
function GetIssuedOrderId() return issued end
function GetTriggerUnit() return walkActivity.pawn end
function GetTriggerEventId() return EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER end
function IssueImmediateOrder(unit,order) unit.order=order; return true end
walkActivity.pawn.order='move'
local orderAction
for _,trigger in ipairs(triggers) do
    for _,event in ipairs(trigger.events) do
        if event[2]==EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER then orderAction=trigger.action end
    end
end
assert(orderAction)
orderAction(); lastTimer.callback()
assert(walkActivity.pawn.order=='stop','Walking must be canceled in stage 2')
issued='blink'; walkActivity.pawn.order='blink'
local previousTimer=lastTimer
orderAction()
assert(lastTimer==previousTimer and walkActivity.pawn.order=='blink','Dodge ability orders must remain usable')
for index=#walkSession.scope,1,-1 do walkSession.scope[index]() end
print('Passed: stage-2 walking cancellation preserves ability orders.')
-- Extra checks for circular boundaries, native health, restrictions and staged approach.
local dangerIndices={}
for index,entry in ipairs(JTG.DodgeDangers) do
    dangerIndices[entry.ability or entry.unit]=index
end
local nativeHP=BlzSetUnitMaxHP
function BlzSetUnitMaxHP() error('Dodging must use native health pools') end
local circleSession={restartData={dangerIndex=dangerIndices.Adev,movementUnit={unit='hfoo',name='Footman',abilities={}}},scope={},presentationScope={},
    scene={centerX=0,centerY=0},descriptor={capabilities={}}}
local circle=JTG.CreateMissileDodgingActivity(circleSession)
circle:setup(circleSession)
assert(circle.circular and circle.arenaHalf==384)
SetUnitX(circle.pawn,1000); SetUnitY(circle.pawn,1000); circle:updateTrial()
assert(math.sqrt(circle.pawn.x^2+circle.pawn.y^2)<=384)
for index=#circleSession.scope,1,-1 do circleSession.scope[index]() end
local artilleryIndex
for index,entry in ipairs(JTG.DodgeDangers) do if entry.menuGroup=='Artillery' then artilleryIndex=index; break end end
circleSession.restartData={dangerIndex=artilleryIndex}
local artillery=JTG.CreateMissileDodgingActivity(circleSession)
artillery:setup(circleSession)
assert(artillery.caster.x==0 and artillery.caster.y==0)
assert(artillery.arenaHalf==artillery.danger.range)
SetUnitX(artillery.pawn,0); SetUnitY(artillery.pawn,0); artillery:updateTrial()
assert(artillery.pawn.x>=artillery.arenaInner)
SetUnitX(artillery.pawn,2000); artillery:updateTrial()
assert(artillery.pawn.x<=artillery.arenaHalf)
artillery:resetAfterHit(); assert(artillery.hitCount==1 and not artillery.resetPending)
for index=#circleSession.scope,1,-1 do circleSession.scope[index]() end
local stageSession={restartData={dangerIndex=dangerIndices.AUdc,stage=3},scope={},presentationScope={},
    scene={centerX=0,centerY=0},descriptor={capabilities={}}}
local staged=JTG.CreateMissileDodgingActivity(stageSession)
staged:setup(stageSession)
assert(staged.caster.invulnerable and staged.caster.creepGuard==false and staged.caster.guardRemoved,
    'Practice attackers must ignore combat damage and native guard reactions')
assert(staged.caster.x==staged.testRange+200 and staged.pawn.speed==0)
local lastOrder
local oldPoint,oldTarget=IssuePointOrder,IssueTargetOrder
function IssuePointOrder(unit,order,x,y) lastOrder=order; return true end
function IssueTargetOrder(unit,order,target) lastOrder=order; return true end
staged:tryAttack(); assert(lastOrder=='move' and staged.attempts==0)
SetUnitX(staged.caster,staged.testRange/2); staged:updateTrial()
assert(lastOrder=='deathcoil' and staged.attempts==1)
IssuePointOrder,IssueTargetOrder=oldPoint,oldTarget
for index=#stageSession.scope,1,-1 do stageSession.scope[index]() end
BlzSetUnitMaxHP=nativeHP
-- All three Water Elemental levels have native ranged cases and numbered icons.
local elementalCases={}
for _,entry in ipairs(JTG.DodgeDangers) do if entry.menuGroup=='Ranged' then elementalCases[entry.unit]=true end end
assert(elementalCases.hwat and elementalCases.hwt2 and elementalCases.hwt3)
JTG.OpenMissileDodgingMenu('skills',false); screen.choices[2].action(); screen.choices[2].action(); screen.choices[2].action()
for _,choice in ipairs(screen.choices) do
    if choice.label=='Forsaken Paladin: Righteous Fury' or choice.label=='Shadowmeld' or choice.label=='Gargoyle: Stone Form' then
        assert(choice.enabled==false,'Devour must exclude heroes and flyers')
    elseif choice.label=='Peon: Build, Burrow' then assert(choice.enabled) end
end
JTG.OpenMissileDodgingMenu('skills',false); screen.choices[1].action(); screen.choices[1].action()
for _,choice in ipairs(screen.choices) do if choice.label=='Death Coil' then choice.action(); break end end
for _,choice in ipairs(screen.choices) do
    if choice.label=='Forsaken Paladin: Righteous Fury' or choice.label=='Acolyte' or choice.label=='Crypt Fiend: Burrow' then
        assert(choice.enabled==false,'Death Coil must exclude undead')
    end
end
print('Passed: circular Devour/Artillery bounds, hit counters, native HP, staged approach, eligibility and all Water Elemental levels.')

-- Stage two must recast on arrival, even if the native order remains active.
local secondSession={restartData={dangerIndex=dangerIndices.AUdc,stage=2},scope={},presentationScope={},
    scene={centerX=0,centerY=0},descriptor={capabilities={}}}
local second=JTG.CreateMissileDodgingActivity(secondSession)
second:setup(secondSession)
local castCount=0
local previousTarget=IssueTargetOrder
function IssueTargetOrder(unit,order,target)
    unit.order=order; castCount=castCount+1; return true
end
second:tryAttack()
assert(castCount==1 and second.waitingForRange and not second.halfApproach)
SetUnitX(second.caster,second.testRange)
second:updateTrial()
assert(castCount==2 and not second.waitingForRange,'Stage 2 must cast at full range without pawn movement')
second.trialTime=second.launchRetryAt
second:tryAttack()
assert(castCount==3,'An active but unlaunched order must not stall indefinitely')
second:confirmCast(); second.trialTime=second.trialTime+10; second:tryAttack()
assert(castCount==3,'A confirmed missile must not be cast twice')
IssueTargetOrder=previousTarget
for index=#secondSession.scope,1,-1 do secondSession.scope[index]() end
local paused=true
JTG.UI.SetGameplayMenuPaused=function(value) paused=value end
JTG.UI.ShowCategory=function(category) assert(category=='skills') end
JTG.Controller.session={id='skills.missile_dodging',activity=second}
JTG.OpenMissileDodgingMenu('skills',true)
screen.backAction()
assert(paused,'Back to a higher menu must retain the gameplay pause')
for _,entry in ipairs(JTG.DodgePawns) do
    if entry.unit=='Npal' then
        assert(entry.name=='Forsaken Paladin: Righteous Fury' and #entry.abilities==1 and entry.abilities[1]=='ANcp')
    end
end
print('Passed: stage-2 full-range arrival and stalled-cast retry, retained menu pause, and Righteous Fury only.')

-- Matchup restrictions and category placement are enforced in the picker.
local function picker(ability)
    JTG.Controller.session=nil
    JTG.OpenMissileDodgingMenu('skills',false); screen.choices[1].action(); screen.choices[1].action()
    for _,choice in ipairs(screen.choices) do if choice.label==(ability=='Aens' and 'Ensnare' or 'Storm Bolt') then choice.action(); break end end
    return screen
end
for _,ability in ipairs({'AHtb','Aens'}) do
    local spec=picker(ability)
    assert(spec.commandGridColumns==14 and #spec.commandGridHeadings==6)
    local byName={}
    for _,choice in ipairs(spec.choices) do
        byName[choice.label]=choice
        assert(choice.label~='Staff of Teleportation')
    end
    if ability=='AHtb' then
        assert(not byName['Obsidian Statue: Destroyer Form'].enabled)
        assert(not byName['Tinker: Robo-Goblin'].enabled)
        assert(byName['Potion of Invulnerability'].enabled,'Item carrier Tinker must remain eligible')
    else
        for _,name in ipairs({'Paladin: Divine Shield','Banshee: Anti-Magic Shell','Mountain King: Avatar','Anti-Magic Potion','Potion of Invulnerability','Shadowmeld','Sorceress: Invisibility','Cloak of Shadows','Potion of Invisibility','Crypt Fiend: Burrow','Carrion Beetle: Burrow'}) do
            assert(not byName[name].enabled,name..' must be disabled against Ensnare')
        end
        assert(byName['Obsidian Statue: Destroyer Form'].enabled and byName['Tinker: Robo-Goblin'].enabled)
    end
    for _,name in ipairs({'Mountain King: Avatar','Paladin: Divine Shield','Sorceress: Invisibility'}) do assert(byName[name].column==0) end
    for _,name in ipairs({'Blademaster','Spirit Wolf: re-summon','Peon: Build, Burrow','Shadow Hunter: Big Bad Voodoo'}) do assert(byName[name].column==2) end
    for _,name in ipairs({'Tinker: Robo-Goblin','Pandaren Brewmaster: Storm, Earth and Fire','Forsaken Paladin: Righteous Fury','Goblin Zeppelin: load unit'}) do assert(byName[name].column==10) end
    for i,heading in ipairs(spec.commandGridHeadings) do
        assert(math.abs(heading.width-((i==1 or i==2 or i==5) and 1 or 2)*0.034)<0.00001)
    end
end
-- Statue supply is borrowed and restored; summon cooldown resets after use.
local stateValues={}
function GetPlayerState(player,key) return stateValues[key] or 17 end
function SetPlayerState(player,key,value) stateValues[key]=value end
local statueIndex,wolfIndex
for i,entry in ipairs(JTG.DodgePawns) do
    if entry.unit=='uobs' then statueIndex=i end
    if entry.summon then wolfIndex=i end
end
local resourceSession={restartData={pawnIndex=statueIndex},scope={},presentationScope={},scene={centerX=0,centerY=0},descriptor={capabilities={}}}
local statue=JTG.CreateMissileDodgingActivity(resourceSession); statue:setup(resourceSession)
assert(stateValues[PLAYER_STATE_RESOURCE_FOOD_CAP]==5)
for i=#resourceSession.scope,1,-1 do resourceSession.scope[i]() end
assert(stateValues[PLAYER_STATE_RESOURCE_FOOD_CAP]==17)
resourceSession.restartData={pawnIndex=wolfIndex}; resourceSession.scope={}; triggers={}
local wolf=JTG.CreateMissileDodgingActivity(resourceSession); wolf:setup(resourceSession)
local cooldownAction
for _,trigger in ipairs(triggers) do
    for _,event in ipairs(trigger.events) do
        if event[1]==Player(0) and event[2]==EVENT_PLAYER_UNIT_SPELL_ENDCAST and not cooldownAction then cooldownAction=trigger.action end
    end
end
assert(cooldownAction)
local refreshed
function GetTriggerUnit() return wolf.helper end
function GetSpellAbilityId() return 'AOsf' end
function BlzEndUnitAbilityCooldown(unit,raw) refreshed={unit,raw} end
cooldownAction(); lastTimer.callback()
assert(refreshed[1]==wolf.helper and refreshed[2]=='AOsf')
local feedbackHidden=false
function BlzFrameSetVisible(frame,visible) if frame==wolf.feedback and visible==false then feedbackHidden=true end end
wolf.flashUntil=100; wolf:showSuccess()
assert(feedbackHidden and wolf.flashUntil==nil)
for i=#resourceSession.scope,1,-1 do resourceSession.scope[i]() end
print('Passed: Homing restrictions, picker columns/headings, staff removal, Statue supply restoration, summon cooldown and end-card feedback cleanup.')

-- Tooltip content and paired-unit geometry match the player-facing specification.
local spec=picker('AHtb')
local wispFound,peonFound=false,false
for _,choice in ipairs(spec.choices) do
    assert(choice.label~='Peasant: Militia')
    if choice.enabled then
        assert(choice.tooltip:find('Cast Point:',1,true) or choice.tooltip:sub(1,7)=='Instant' or choice.tooltip:find('Activation:',1,true))
    else
        assert(not choice.tooltip:find('Cast Point:',1,true) and not choice.tooltip:find('Activation:',1,true))
    end
    assert(not choice.tooltip:find('~',1,true) and not choice.tooltip:find('measured',1,true))
    assert(not choice.tooltip:find('Missile speed:',1,true))
    assert(not choice.tooltip:find('Range:',1,true) and not choice.tooltip:find('casting time:',1,true))
    if choice.label=='Wisp: Build, Goldmine, Detonate' then wispFound=true end
    if choice.label=='Peon: Build, Burrow' then peonFound=true end
end
assert(wispFound and peonFound)
function GetTriggerEventId() return eventId end
function IssueImmediateOrder(unit,order)
    if order=='spiritwolf' then
        summoned=CreateUnit(unit.owner,'osw1',unit.x,unit.y,0)
        eventId=EVENT_PLAYER_UNIT_SUMMON
        for _,t in ipairs(triggers) do
            for _,event in ipairs(t.events) do
                if event[1]==unit.owner and event[2]==eventId then t.action() end
            end
        end
    end
    return true
end
triggers={}
local stationarySession={restartData={pawnIndex=wolfIndex},scope={},presentationScope={},scene={centerX=0,centerY=0},descriptor={capabilities={}}}
local stationaryWolf=JTG.CreateMissileDodgingActivity(stationarySession); stationaryWolf:setup(stationarySession)
assert(stationaryWolf.stageLimit==2 and stationaryWolf.pawn.speed==0)
assert(stationaryWolf.opponentX==stationaryWolf.target.x+stationaryWolf.testRange+400)
assert(not stationaryWolf.halfApproach)
for i=#stationarySession.scope,1,-1 do stationarySession.scope[i]() end
triggers={}
local secondSession={restartData={pawnIndex=wolfIndex,stage=2},scope={},presentationScope={},scene={centerX=0,centerY=0},descriptor={capabilities={}}}
local secondWolf=JTG.CreateMissileDodgingActivity(secondSession); secondWolf:setup(secondSession)
assert(secondWolf.stageLimit==2 and secondWolf.halfApproach and secondWolf.pawn.speed==0)
for i=#secondSession.scope,1,-1 do secondSession.scope[i]() end
for i,entry in ipairs(JTG.DodgePawns) do
    if entry.name=='Sorceress: Invisibility' or entry.name=='Staff of Sanctuary' or entry.summon then
        triggers={}
        local pairSession={restartData={pawnIndex=i},scope={},presentationScope={},scene={centerX=100,centerY=200},descriptor={capabilities={}}}
        local paired=JTG.CreateMissileDodgingActivity(pairSession); paired:setup(pairSession)
        local controlled=entry.targetSupport and paired.pawn or paired.helper
        assert(paired.target.x==100 and paired.target.y==200)
        assert(controlled.x==100 and controlled.y==400 and controlled.facing==270)
        for n=#pairSession.scope,1,-1 do pairSession.scope[n]() end
    end
end
local toolbarHidden=false
JTG.UI.HideToolbar=function() toolbarHidden=true end
wolf:showSuccess(); assert(toolbarHidden)
print('Passed: simplified timing tooltips, worker labels, no Militia, 200-unit north helper positioning and end-card toolbar hiding.')

-- Verdicts now follow cancellation, launch and impact rather than button timing.
local timing=JTG.CreateMissileDodgingActivity({restartData={dangerIndex=dangerIndices.AUdc,pawnIndex=5},scope={}})
timing.caster={id='Udea',x=600,y=0}; timing.target={id='Hmkg',x=0,y=0}
timing:recordDodge(); assert(not timing.pendingVerdict)
timing.casting=true; timing:castStopped(); assert(timing.pendingVerdict=='TOO EARLY!')
local launched=JTG.CreateMissileDodgingActivity({restartData={dangerIndex=dangerIndices.AUdc,pawnIndex=5},scope={}})
launched.caster={id='Udea',x=600,y=0}; launched.target={id='Hmkg',x=0,y=0}
local pointOrder=IssuePointOrder
local runOrder
function IssuePointOrder(unit,order,x,y) runOrder={unit,order,x,y}; return true end
launched:confirmCast()
assert(runOrder==nil,'Stage one must not issue an automatic movement command')
launched:recordDodge(); assert(not launched.pendingVerdict,'Dodge command alone cannot earn success')
launched.trialTime=launched.resolveAfter; launched:updateTrial(); assert(launched.pendingVerdict=='WELL DONE!')
IssuePointOrder=pointOrder
local blinkIndex
for i,entry in ipairs(JTG.DodgePawns) do if entry.unit=='Ewar' then blinkIndex=i end end
local net=JTG.CreateMissileDodgingActivity({restartData={dangerIndex=dangerIndices.Aens,pawnIndex=blinkIndex,stage=2},scope={}})
net.caster={id='orai',x=500,y=0}; net.target={id='Ewar',x=0,y=0}; net:confirmCast()
local oldBuff=GetUnitAbilityLevel
local transient=true
function GetUnitAbilityLevel(unit,raw) return unit==net.target and transient and raw=='Beng' and 1 or 0 end
net:updateTrial(); assert(not net.pendingVerdict)
transient=false; net:updateTrial(); assert(not net.pendingVerdict,'Transient net marker must not count as a lasting hit')
transient=true
for i=1,5 do net:updateTrial() end
assert(net.pendingVerdict=='TOO LATE!','A lasting net debuff is a hit')
GetUnitAbilityLevel=oldBuff
for _,entry in ipairs(JTG.DodgeDangers) do
    if entry.orbOrder then
        local index
        for i,v in ipairs(JTG.DodgeDangers) do if v==entry then index=i end end
        for pawnIndex,pawn in ipairs(JTG.DodgePawns) do
            if pawn.unit=='Obla' then
                local one=JTG.CreateMissileDodgingActivity({restartData={dangerIndex=index,pawnIndex=pawnIndex,stage=3}})
                assert(one.stageLimit==1 and one.stage==1 and not one:nextStage())
            end
        end
    end
end
local fadeIndex
for i,entry in ipairs(JTG.DodgePawns) do if entry.name=='Shadowmeld' then fadeIndex=i end end
local fading=JTG.CreateMissileDodgingActivity({restartData={dangerIndex=dangerIndices.AUdc,pawnIndex=fadeIndex},scope={}})
fading.caster={id='Udea',x=600,y=0}; fading.target={id='Emoo',x=0,y=0}
function IsUnitInvisible() return true end
fading:recordDodge(); fading.casting=true; fading:castStopped()
assert(fading.pendingVerdict=='WELL DONE!','Completing invisibility before launch is the fade-method goal')
local struck=JTG.CreateMissileDodgingActivity({restartData={dangerIndex=dangerIndices.AUdc,pawnIndex=fadeIndex},scope={}})
struck.caster=fading.caster; struck.target=fading.target
struck:confirmCast(); struck:resetAfterHit()
assert(struck.pendingVerdict=='TOO LATE!','A hit must fail even if invisibility finishes afterwards')
local windwalk=JTG.CreateMissileDodgingActivity({restartData={dangerIndex=dangerIndices.AUdc},scope={}})
windwalk.caster=fading.caster; windwalk.target={id='Obla',x=0,y=0}
windwalk:recordDodge(); windwalk.casting=true; windwalk:castStopped()
assert(windwalk.pendingVerdict=='TOO EARLY!','Wind Walk still trains post-launch projectile dodging')
function IsUnitInvisible() return false end
local homingPage
JTG.Controller.session=nil; JTG.OpenMissileDodgingMenu('skills',false); screen.choices[1].action(); screen.choices[1].action(); homingPage=screen
assert(homingPage.title=='Dodging' and homingPage.titleSuffix==nil and #homingPage.commandGridHeadings==2)
assert(homingPage.commandGridHeadings[1].label=='Missile' and homingPage.commandGridHeadings[2].label=='Orb Effects')
local ensnarePage=picker('Aens')
for _,choice in ipairs(ensnarePage.choices) do
    if choice.label=='Blademaster' then assert(choice.enabled and choice.tooltip:find('Ensnare reveals invisible units',1,true)) end
    if choice.label=='Shadowmeld' then assert(not choice.enabled and choice.tooltipWhenDisabled and choice.tooltip:find('Ensnare reveals invisible units',1,true)) end
    if choice.label=='Paladin: Divine Shield' then assert(not choice.enabled and choice.tooltip:find('The net still hits if it was thrown before Divine Shield',1,true)) end
    if choice.label=='Mountain King: Avatar' then assert(not choice.enabled and choice.tooltip:find('Only blocks magical abilities',1,true)) end
end
print('Passed: cancellation/launch/impact verdicts, launch movement, stable net-hit evidence, one-stage orb invisibility, hidden-state results and disabled matchup tooltips.')

local arrivalSession={restartData={dangerIndex=dangerIndices.AUdc,pawnIndex=5,stage=3},scope={},presentationScope={},scene={centerX=0,centerY=0},descriptor={capabilities={}}}
local arrival=JTG.CreateMissileDodgingActivity(arrivalSession); arrival:setup(arrivalSession)
local nativeTarget=IssueTargetOrder
local launchedAtArrival=false
function IssueTargetOrder(unit,order,target) if unit==arrival.caster and order=='deathcoil' then launchedAtArrival=true end; return true end
arrival:tryAttack()
SetUnitX(arrival.caster,arrival.approachX+15); SetUnitY(arrival.caster,arrival.approachY)
arrival:updateTrial()
assert(launchedAtArrival and not arrival.approaching and not arrival.halfApproach)
IssueTargetOrder=nativeTarget
for i=#arrivalSession.scope,1,-1 do arrivalSession.scope[i]() end
print('Passed: immediate stage-three casting on arrival within the native movement tolerance.')

-- The current orb picker allows Wind Walk, excludes the other invisibility options,
-- and keeps the Talon's armor note in the lower tooltip text.
JTG.Controller.session=nil; JTG.OpenMissileDodgingMenu('skills',false); screen.choices[1].action(); screen.choices[1].action()
local storm,ensnare
for _,choice in ipairs(screen.choices) do
    if choice.label=='Storm Bolt' then storm=choice end
    if choice.label=='Ensnare' then ensnare=choice end
end
assert(storm.column==0 and math.abs(ensnare.x-(-0.08)-0.027)<0.000001)
for _,choice in ipairs(screen.choices) do if choice.label=='Searing Arrows' then choice.action(); break end end
for _,choice in ipairs(screen.choices) do
    if choice.label=='Blademaster' then assert(choice.enabled) end
    if choice.label=='Shadowmeld' or choice.label=='Potion of Invisibility' or choice.label=='Cloak of Shadows' or
        choice.label=='Sorceress: Invisibility' or choice.label=='Demon Hunter: Metamorphosis' or choice.label=='Druid of the Claw: Bear Form' then
        assert(not choice.enabled and choice.tooltipWhenDisabled)
    end
    if choice.label=='Druid of the Talon: Crow Form' then assert(not choice.enabled and choice.tooltipWhenDisabled) end
    assert(choice.tooltipColor=='|cffbbbbbb')
end
local bansheeIndex
for i,entry in ipairs(JTG.DodgePawns) do if entry.unit=='uban' then bansheeIndex=i end end
local bansheeSession={restartData={pawnIndex=bansheeIndex},scope={},presentationScope={},scene={centerX=100,centerY=200},descriptor={capabilities={}}}
triggers={}
local banshee=JTG.CreateMissileDodgingActivity(bansheeSession); banshee:setup(bansheeSession)
assert(banshee.target.id=='ugho' and banshee.target.owner==Player(PLAYER_NEUTRAL_PASSIVE))
assert(banshee.target.x==100 and banshee.target.y==200 and banshee.target.facing==180)
assert(banshee.pawn.x==100 and banshee.pawn.y==400 and banshee.pawn.facing==270)
local targetDamage,targetAttack=false,false
for _,trigger in ipairs(triggers) do
    for _,event in ipairs(trigger.events) do
        if event[1]==Player(PLAYER_NEUTRAL_PASSIVE) then
            if event[2]==EVENT_PLAYER_UNIT_DAMAGED then targetDamage=true end
            if event[2]==EVENT_PLAYER_UNIT_ATTACKED then targetAttack=true end
        end
    end
end
assert(targetDamage and targetAttack)
for i=#bansheeSession.scope,1,-1 do bansheeSession.scope[i]() end
assert(banshee.target.removed)
print('Passed: no automatic movement, left-facing targets, touching Ensnare icons, orb exclusions, grey lower tooltips and neutral Ghoul targeting/cleanup.')
