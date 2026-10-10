-- Run after the Dodging lifecycle and revision checks.
local devourIndex,pawnIndex
for i,d in ipairs(JTG.DodgeDangers) do if d.ability=='Adev' then devourIndex=i end end
for i,p in ipairs(JTG.DodgePawns) do if p.unit=='opeo' then pawnIndex=i end end
assert(devourIndex and pawnIndex)
local function session(state)
    return {restartData=state,scope={},presentationScope={},scene={centerX=0,centerY=0},descriptor={capabilities={}}}
end
local random,targetOrder,currentOrder=GetRandomReal,IssueTargetOrder,GetUnitCurrentOrder
local orders={}
function IssueTargetOrder(unit,order,target)
    orders[#orders+1]={order=order,time=unit.testTime}; unit.order=order; return true
end
function GetUnitCurrentOrder(unit) return unit.order=='move' and OrderId('move') or 0 end
for _,upper in ipairs({false,true}) do
    function GetRandomReal(low,high) return upper and high or low end
    local activity=JTG.CreateMissileDodgingActivity(session({dangerIndex=devourIndex,
        movementUnit={unit='hfoo',name='Footman',abilities={}}}))
    activity.caster={id='okod',x=600,y=0}; activity.target={id='hfoo',x=0,y=0}
    activity.devourRadius=180; orders={}
    activity:tryAttack()
    local moveDelay=upper and 1 or 0.5
    local devourDelay=upper and 2.5 or 2
    for n=1,math.floor((devourDelay-0.01)/moveDelay) do
        activity.trialTime=n*moveDelay; activity:updateDevourOrders()
        assert(orders[#orders].order=='move')
    end
    local count=#orders
    activity.trialTime=devourDelay; activity:updateDevourOrders()
    assert(#orders==count+1 and orders[#orders].order=='devour')
    activity.trialTime=devourDelay+0.1; activity.caster.x=20
    activity:updateDevourOrders()
    assert(orders[#orders].order=='devour')
    assert(activity.devourRetryAt==activity.trialTime+devourDelay)
    assert(activity.devourMoveAt==activity.trialTime+moveDelay)
    count=#orders; activity.trialTime=activity.trialTime+0.05
    activity:updateDevourOrders(); assert(#orders==count,'Remaining inside half range must not spam Devour')
    activity.caster.x=600; activity:updateDevourOrders()
    activity.caster.x=20; activity:updateDevourOrders(); assert(#orders==count+1)
    -- Rejected Devour commands still restart both deadlines.
    IssueTargetOrder=function() return false end
    activity.trialTime=activity.devourRetryAt
    activity:updateDevourOrders()
    assert(activity.devourRetryAt==activity.trialTime+devourDelay)
    activity.trialTime=activity.trialTime+0.05
    activity:updateDevourOrders(); assert(activity.devourRetryAt>activity.trialTime)
    IssueTargetOrder=targetOrder
    function IssueTargetOrder(unit,order,target)
        orders[#orders+1]={order=order}; unit.order=order; return true
    end
end
GetRandomReal=random
local timerFn=JTG.StartScopedTimer
local transition
JTG.StartScopedTimer=function(...) transition=timerFn(...); return transition end
for _,streak in ipairs({0,1,2}) do
    local current=session({dangerIndex=devourIndex,pawnIndex=pawnIndex,streak=streak,stage=3})
    local activity=JTG.CreateMissileDodgingActivity(current)
    activity:setup(current)
    assert(activity.abilityDevour and not activity.arena and activity.stageLimit==1 and activity.stage==1)
    assert(activity.pawn.speed==0 and activity.target.speed==0)
    assert(activity.caster.x-activity.target.x==activity.testRange+200)
    activity:tryAttack(); activity:recordDodge()
    activity.caster.order=nil
    local ended=false
    activity.showSuccess=function() ended=true end
    activity:updateTrial()
    assert(activity.pendingVerdict=='WELL DONE!' and transition.period==1)
    transition.callback()
    assert(activity.streak==streak+1)
    assert(ended==(streak==2) and activity.finished==(streak==2))
    assert(not activity:nextStage())
end
local failed=JTG.CreateMissileDodgingActivity(session({dangerIndex=devourIndex,pawnIndex=pawnIndex,streak=2}))
failed:finishDevour(true); assert(failed.pendingVerdict=='TOO LATE!')
transition.callback(); assert(failed.streak==0)
for _,raw in ipairs({'osw1','osw2','osw3'}) do
    assert(JTG.DodgeInvalidTargetReason(JTG.DodgeDangers[devourIndex],{unit=raw})==
        'Wolves can be re-summoned if they get devoured.')
end
JTG.StartScopedTimer=timerFn
IssueTargetOrder,GetUnitCurrentOrder=targetOrder,currentOrder
local oldBriefing,oldSession=JTG.UI.ShowActivityBriefing,JTG.Controller.session
local screen
JTG.UI.ShowActivityBriefing=function(spec) screen=spec end
JTG.Controller.session=nil
JTG.OpenMissileDodgingMenu('skills',false,'how',{dangerIndex=devourIndex})
screen.choices[2].action()
local bansheeFound=false
for _,choice in ipairs(screen.choices) do
    assert(not (choice.tooltip or ''):find('does not disjoin',1,true))
    if choice.unitRawcode=='uban' then
        bansheeFound=true
        assert(choice.enabled==false and choice.tooltip=='This ability does not protect against Devour.')
    end
end
assert(bansheeFound)
assert(not JTG.DodgeInvalidTargetReason(JTG.DodgeDangers[devourIndex],{unit='uban'}),
    'A Banshee may still be selected for movement avoidance')
JTG.UI.ShowActivityBriefing,JTG.Controller.session=oldBriefing,oldSession
print('Passed: random interval bounds, command priority, close-range timer reset, rejection throttling, stationary ability mode, three consecutive dodges, no next stage and wolf tooltips.')
