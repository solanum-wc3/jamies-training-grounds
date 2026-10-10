-- Run after the other two Lua test files to reuse the lifecycle mocks.
local lastCard, damageSource, damagedUnit, damageAmount
function SetUnitOwner(unit,owner) unit.owner=owner end
function BlzGetUnitRealField() return 1800 end
function GetLocalPlayer() return Player(0) end
function GetEventDamageSource() return damageSource end
function GetTriggerUnit() return damagedUnit end
function GetEventDamage() return damageAmount end
JTG.UI.HideToolbar=function() end
JTG.UI.ShowResultCard=function(card,presentation) lastCard=presentation end
local damageActions={}
local originalTriggerAddAction=TriggerAddAction
function TriggerAddAction(trigger,action)
    originalTriggerAddAction(trigger,action)
    for _,event in ipairs(trigger.events) do
        if event[2]==EVENT_PLAYER_UNIT_DAMAGED then damageActions[#damageActions+1]=action end
    end
end
local dayTime
function SetFloatGameState(_,value) dayTime=value end
function UnitShareVision(unit,_,enabled) unit.sharedVision=enabled end
function CreateFogModifierRadius(owner) assert(owner==Player(1),'Player vision must remain native'); return {} end
local allowed={['2,4']=true,['3,3']=true,['4,2']=true,['4,4']=true,['3,3,2']=true,
    ['4,4,2']=true,['5,5']=true,['3,3,4']=true}
for stage=1,3 do
    local session={restartData={stage=stage,hard=stage==2},scope={},presentationScope={},
        scene={centerX=4864,centerY=3456,maxY=4864},descriptor={capabilities={}}}
    local activity=JTG.CreateBatSplittingActivity(session)
    activity:setup(session)
    assert(dayTime==(stage==2 and 0 or 12))
    for _,unit in ipairs(activity.gryphons) do assert(unit.sharedVision) end
    assert(activity.startX==4864 and activity.startY==4864)
    assert(#activity.gryphons==4+stage*2 and #activity.bats==4+stage*2)
    assert(allowed[table.concat(activity.plan.groups,',')])
    local targets={}
    for _,bat in ipairs(activity.bats) do
        local target=activity.targets[bat]
        assert(not targets[target],'Every bat needs a different target')
        targets[target]=true
        local dx,dy=GetUnitX(bat)-GetUnitX(target),GetUnitY(bat)-GetUnitY(target)
        assert(math.abs(math.sqrt(dx*dx+dy*dy)-2000)<0.00001)
    end
    local orders={}
    local savedTargetOrder=IssueTargetOrder
    function IssueTargetOrder(unit,order,target) orders[unit]=order; return true end
    activity:beginBattle()
    for _,bat in ipairs(activity.bats) do assert(orders[bat]==nil) end
    for step=1,30 do
        activity:update()
        for _,bat in ipairs(activity.bats) do
            assert((orders[bat]~=nil)==(step*0.1+0.00001>=activity.releaseAt[bat]))
        end
    end
    IssueTargetOrder=savedTargetOrder
    for _,unit in ipairs(activity.gryphons) do assert(not unit.sharedVision and unit.owner==Player(0)) end
    assert(activity:outcome()=='success')
    damageSource=activity.bats[1]; damagedUnit=activity.targets[damageSource]; damageAmount=600
    damageActions[#damageActions]()
    assert(activity.splashDamage==0,'Direct damage is not splash')
    for _,gryphon in ipairs(activity.gryphons) do
        if gryphon~=damagedUnit then damagedUnit=gryphon; break end
    end
    damageAmount=140; damageActions[#damageActions]()
    assert(activity.splashDamage==140 and activity.splashHits==1)
    assert(activity:outcome()=='neutral')
    activity.gryphons[1].dead=true
    assert(activity:outcome()=='failure')
    activity:update(); assert(not activity.finished,'A Gryphon loss must not end the round')
    for _,bat in ipairs(activity.bats) do bat.dead=true end
    activity:update(); assert(not activity.finished)
    activity:update(); assert(activity.finished and lastCard.tone=='failure')
    for index=#session.scope,1,-1 do session.scope[index]() end
end
print('Passed: 6/8/10 spawns, legal groups, unique fixed targets, vision+400 placement, direct/splash attribution, all three outcomes and resolution after the final bat.')
