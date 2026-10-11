-- Run after Dodging phases, before the real-controller standardization tests.
local oldTimer,oldCamera,oldClear,oldSelect,oldStop,oldRemaining=
    JTG.StartScopedTimer,SetCameraPosition,ClearSelection,SelectUnit,IssueImmediateOrder,BlzGetUnitAbilityCooldownRemaining
local timers,orders={},{}
JTG.StartScopedTimer=function(_,_,delay,repeatTimer,callback)
    timers[#timers+1]={delay=delay,periodic=repeatTimer,callback=callback};return {}
end
local function create(raw,delay)
    local index
    for i,d in ipairs(JTG.DodgeDangers) do if d.ability==raw then index=i;break end end
    local session={restartData={dangerIndex=index,pawnIndex=1,startDelay=delay},scope={},presentationScope={},
        scene={centerX=0,centerY=0},descriptor={capabilities={}}}
    local a=JTG.CreateMissileDodgingActivity(session)
    a.pawn={id='hfoo',x=200,y=0};a.target=a.pawn;a.caster={id=a.danger.unit,x=0,y=0}
    a.tryAttack=function() orders[#orders+1]='cast' end
    return a
end
local a=create('AHtb',true)
a:start();assert(a.countdownRemaining==3 and #orders==0 and #timers==1)
a:recordDodge();assert(not a.dodgeUsed)
timers[1].callback();assert(a.countdownRemaining==2 and #orders==0 and a.trialTime==0)
timers[1].callback();assert(a.countdownRemaining==1 and #orders==0)
local reset=a:captureResetState();assert(reset.startDelay==nil)
timers[1].callback();assert(a.countdownRemaining==nil and #orders==1)
assert(#timers==3 and timers[2].periodic and timers[3].periodic)
timers={};orders={};a=create('AHtb',false);a:start()
assert(a.countdownRemaining==nil and #orders==1,'Redo must start without the entry delay')
timers={};orders={};a=create('AOsh',false);a:start()
assert(a.countdownRemaining==3 and #orders==0,'Directional Area trials must count down')
-- Every Area shape has the same movable countdown, also on Redo. Only GO
-- starts enemy orders and the survival timer; no global/pawn pause is applied.
for _,raw in ipairs({'AOsh','AHtc','AHbz'}) do
    timers={};orders={}
    local area=create(raw,false)
    area.updateAreaOrders=function() orders[#orders+1]='area-cast' end
    local flags={}
    area.flash=function(_,text) flags[#flags+1]=text end
    area:start()
    assert(area.countdownRemaining==3 and area.trialTime==0 and #orders==0)
    assert(GetUnitMoveSpeed(area.pawn)>0 and not area.pawn.paused)
    timers[1].callback();timers[1].callback()
    assert(area.countdownRemaining==1 and area.trialTime==0 and #orders==0)
    timers[1].callback()
    assert(area.countdownRemaining==nil and orders[1]=='area-cast' and flags[4]=='GO!')
    assert(#timers==2 and timers[2].delay==0.05)
end
local directionalIndex
for index,danger in ipairs(JTG.DodgeDangers) do
    if danger.ability=='AOsh' then directionalIndex=index;break end
end
for index,pawn in ipairs(JTG.DodgePawns) do
    if pawn.unit=='hfoo' or pawn.support=='ehip' or pawn.targetSupport then
        local session={restartData={dangerIndex=directionalIndex,pawnIndex=index},scope={},presentationScope={},
            scene={centerX=0,centerY=0},descriptor={capabilities={}}}
        local trial=JTG.CreateMissileDodgingActivity(session);trial:setup(session)
        assert(trial.caster.x==0 and trial.target.x==trial.arenaMaximum and trial.target.y==0)
        for i=#session.scope,1,-1 do session.scope[i]() end
    end
end
-- Mount pairs coincide in every range stage, rather than using the helper offset.
for index,p in ipairs(JTG.DodgePawns) do
    if (p.unit=='earc' and p.support=='ehip') or (p.unit=='ehip' and p.support=='earc') then
        for stage=1,3 do
            local session={restartData={pawnIndex=index,stage=stage},scope={},presentationScope={},
                scene={centerX=0,centerY=0},descriptor={capabilities={}}}
            local pair=JTG.CreateMissileDodgingActivity(session);pair:setup(session)
            assert(pair.pawn.x==pair.helper.x and pair.pawn.y==pair.helper.y)
            for i=#session.scope,1,-1 do session.scope[i]() end
        end
    end
end
-- Channel interruption preserves native cooldowns rather than clearing them.
for _,raw in ipairs({'AHbz','ANrf'}) do
    local channel=create(raw,false)
    channel.tryAttack=nil
    channel.areaChannelUntil=1.05;channel.areaCastAt=6;channel.castConfirmed=true;channel.castTime=0
    local stopped=0
    function IssueImmediateOrder(_,order) assert(order=='stop');stopped=stopped+1;return true end
    function BlzGetUnitAbilityCooldownRemaining() return 4 end
    channel.trialTime=1.05;channel:updateAreaOrders()
    assert(stopped==1 and channel.areaChannelUntil==nil and channel.areaCastAt==5.05)
    channel:stopAreaChannel();assert(stopped==1,'Only one stop per channel')
end
JTG.StartScopedTimer,SetCameraPosition,ClearSelection,SelectUnit,IssueImmediateOrder,BlzGetUnitAbilityCooldownRemaining=
    oldTimer,oldCamera,oldClear,oldSelect,oldStop,oldRemaining
print('Passed: direct entry delay, no early verdict, immediate Redo, directional Area countdown, coincident mounting pairs and one-wave channel cancellation with preserved cooldown.')
