-- Synthetic driver checks. No claim about native ability behavior.
JTG={Dev={},Controller={},Registry={byId={}},UI={}}
UNIT_TYPE_DEAD='dead'
PLAYER_STATE_RESOURCE_FOOD_CAP='food_cap'
PLAYER_STATE_RESOURCE_FOOD_CAP_CEILING='food_ceiling'
PLAYER_STATE_RESOURCE_FOOD_USED='food_used'
PLAYER_STATE_RESOURCE_GOLD='gold';PLAYER_STATE_RESOURCE_LUMBER='lumber';UNIT_STATE_MANA='mana'
UNIT_TYPE_FLYING='flying';PATHING_TYPE_BUILDABILITY='buildability'
local now,initializers,timers,exports=0,{}, {},0
function Player(n) return n end
function FourCC(s) return s end
function GetUnitTypeId(u) return u.removed and 0 or u.id end
function IsUnitType(u,kind) return kind=='dead' and u.dead==true or kind=='flying' and u.flying==true end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function GetUnitFacing(u) return u.facing or 0 end
function BlzGetUnitCollisionSize() return 16 end
function BlzGetUnitWeaponRealField(u,field) return field==UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT and 0.3 or 450 end
function BlzGetUnitAttackCooldown() return 2 end
UNIT_WEAPON_RF_ATTACK_RANGE='range';UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT='damage_point'
function SetUnitX(u,x) u.x=x end
function SetUnitY(u,y) u.y=y end
function SetUnitMoveSpeed(u,speed) u.speed=speed end
function BlzSetUnitFacingEx(u,facing) u.facing=facing end
function GetPlayerState() return 5 end
function GetUnitCurrentOrder() return 0 end
function GetUnitState() return 0 end
function IsUnitPaused(u) return u.paused==true end
function IsUnitInvisible(u) return u.invisible==true end
function GetUnitAbilityLevel(u,id)
    return (u.id=='earc' and id=='Aco2' or u.id=='ehip' and id=='Aco3') and 1 or 0
end
function RemoveUnit(u) u.removed=true end
local terrainBlocked,nearby,destructible=false,{},false
local enumUnit
function IsTerrainPathable() return terrainBlocked end
function CreateGroup() return {} end
function GroupEnumUnitsInRange() end
function ForGroup(g,fn) for _,u in ipairs(nearby) do enumUnit=u;fn() end end
function GetEnumUnit() return enumUnit end
function DestroyGroup() end
function Rect() return {} end
function EnumDestructablesInRect(r,filter,fn) if destructible then fn() end end
function GetEnumDestructable() return {} end
function GetDestructableLife() return 100 end
function RemoveRect() end
function SetPlayerState() end
function TimerGetElapsed() return now end
function CreateTimer() return {} end
function TimerStart(t,period,repeatable,fn) t.callback=fn;timers[#timers+1]=t end
function CreateTrigger() return {} end
function TriggerRegisterPlayerChatEvent() end
function TriggerAddAction(t,fn) t.action=fn end
function GetEventPlayerChatString() return '' end
function DisplayTimedTextToPlayer() end
function PauseUnit(u,v) u.paused=v end
function UnitRemoveAbility() end
function BlzEndUnitAbilityCooldown() end
function JTG.CreateScope() return {timers={}} end
function JTG.ScopeTrackTimer(scope,t) scope.timers[#scope.timers+1]=t;return t end
function JTG.DisposeScope(scope) scope.disposed=true end
function JTG.ScopeBorrow(scope,fn) scope.borrowed=fn end
function JTG.RegisterBootstrapInitializer(fn) initializers[#initializers+1]=fn end
function JTG.UI.SetGameplayMenuPaused() end
function JTG.UI.SetExercisePaused() end
function JTG.UI.ShowCategory() end
local last
local function order(kind,u,id,target) last={kind,u,id,target};return true end
function IssueImmediateOrder(u,id) return order('immediate',u,id) end
function IssuePointOrder(u,id,x,y) return order('point',u,id,{x,y}) end
function IssueTargetOrder(u,id,t) return order('target',u,id,t) end
function IssueBuildOrderById(u,id,x,y) return order('build',u,id,{x,y}) end
function IssuePointOrderById(u,id,x,y) return order('point_id',u,id,{x,y}) end
function UnitItemInSlot(u,slot) return slot==0 and u.item or nil end
function GetItemTypeId(item) return item.id end
function UnitUseItem(u,item) return order('item',u,item.id) end
function UnitUseItemTarget(u,item,t) return order('item_target',u,item.id,t) end
local function unit(id) return {id=id,x=0,y=0} end
dofile('src/generated/melee-tech.lua')
dofile('src/generated/dodge-catalog.lua')
dofile('src/generated/dodge-timing-methods.lua')
local history={}
JTG.Dev.DodgeTiming={enabled=false,Record=function(run,event,role,u,ability,detail,quality)
    run.events[#run.events+1]={time=now,event=event,role=role,ability=ability,detail=detail,quality=quality}
end,Export=function() exports=exports+1 end}
function JTG.StartActivity(id,category,selection)
    assert(selection.timingBatch and id=='skills.missile_dodging')
    local definition=JTG.DodgePawns[selection.pawnIndex]
    local a={definition=definition,danger=JTG.DodgeDangers[selection.dangerIndex],
        pawn=unit(definition.unit),helper=unit(definition.support or 'hfoo'),caster=unit('Hmkg'),supports={unit('egol')},
        home=unit('htow'),timingRun={events={},clock={},conditions='synthetic'},attempts=0,accepted=0}
    a.target=a.pawn;a.pawn.item={id=definition.item};a.helper.item={id=definition.supportItem}
    a.tryAttack=function(self)
        self.attempts=1;self.accepted=1
        local r=self.timingRun
        for _,event in ipairs({'cast_start','ability_effect','attack_start'}) do
            JTG.Dev.DodgeTiming.Record(r,event,'enemy',self.caster,'AHtb','','native_event')
        end
        JTG.Dev.DodgeTiming.Record(r,'damage','target',self.target,'','','native_event')
    end
    JTG.Controller.session={activity=a,scope={}};history[#history+1]=JTG.Controller.session;return true
end
function JTG.StopActivity()
    local s=JTG.Controller.session
    if s then s.stopped=true;if s.scope and s.scope.borrowed then s.scope.borrowed() end end
    JTG.Controller.session=nil
end
dofile('src/infrastructure/dodge-timing-batch.lua')
local batch=JTG.Dev.DodgeTimingBatch
local facingFixture={pawn=unit('opeo'),helper=unit('otrb'),caster=unit('Hmkg'),supports={}}
facingFixture.target=facingFixture.pawn;facingFixture.caster.x=400
batch.SetInitialFacing(facingFixture,nil)
assert(facingFixture.pawn.facing==180 and facingFixture.caster.facing==180)
batch.SetInitialFacing(facingFixture,{method='Build'})
assert(facingFixture.pawn.facing==270)
local plan=batch.Plan(false)
assert(#plan==594 and #batch.Plan(true)==14)
local threat,methods={},{}
for _,case in ipairs(plan) do
    if case.mode=='baseline' then threat[case.dangerIndex]=true end
    if case.mode=='isolated' then methods[case.method.id]=true end
end
local n=0;for _ in pairs(threat) do n=n+1 end;assert(n==100)
n=0;for _ in pairs(methods) do n=n+1 end;assert(n==38)
for _,method in ipairs(JTG.DodgeTimingMethods) do
    local definition=JTG.DodgePawns[method.pawnIndex]
    local a={definition=definition,pawn=unit(definition.unit),helper=unit(definition.support or 'hfoo'),
        caster=unit('Hmkg'),home=unit('htow'),supports={unit('egol')}}
    a.target=a.pawn;a.pawn.item={id=definition.item};a.helper.item={id=definition.supportItem}
    local accepted,detail=batch.Action(a,method)
    assert(accepted,method.id..':'..tostring(detail))
end
batch.Start(true)
local scope=batch.scope
for i=1,30000 do
    now=now+.01;batch.Tick()
    if not batch.active then break end
end
assert(not batch.active and #batch.results==14 and exports>0 and scope.disposed)
for _,s in ipairs(history) do assert(s.stopped) end
local makePlan=batch.Plan
local paired={}
for _,mode in ipairs({'before_order','cast_start_plus_0.10','effect_plus_0.10'}) do
    for _,case in ipairs(plan) do
        if case.method and case.method.id=='dodge.01.1' and case.mode==mode then paired[#paired+1]=case;break end
    end
end
batch.Plan=function() return paired end
local historyStart=#history
batch.Start(false)
for i=1,10000 do now=now+.01;batch.Tick();if not batch.active then break end end
assert(not batch.active and #batch.results==3)
for index=historyStart+1,#history do
    local request,enemy
    for _,e in ipairs(history[index].activity.timingRun.events) do
        if e.event=='batch_dodge_request' then request=e.time end
        if e.event=='batch_enemy_request' then enemy=e.time end
    end
    assert(request and enemy)
    if index==historyStart+1 then assert(request<enemy)
    else assert(request>=enemy+.1-1e-6) end
end
batch.Plan=makePlan
local activation=batch.ActivationPlan()
assert(#activation==153)
local repetitions,distances={},{}
for _,case in ipairs(activation) do
    assert(case.activationPass and case.repetition>=1 and case.repetition<=3)
    if case.method then
        local key=case.method.id..':'..case.approach
        repetitions[key]=(repetitions[key] or 0)+1
    else
        local key=case.dangerIndex..':'..case.rangeFraction
        distances[key]=(distances[key] or 0)+1
    end
end
local count=0;for _,n in pairs(repetitions) do assert(n==3);count=count+1 end;assert(count==45)
count=0;for _,n in pairs(distances) do assert(n==3);count=count+1 end;assert(count==6)
batch.Start(false,true)
scope=batch.scope
for i=1,180000 do now=now+.01;batch.Tick();if not batch.active then break end end
assert(not batch.active and #batch.results==153 and scope.disposed)
-- A rejected Wisp build is retried through a separate, explicitly logged route.
local oldBuild=IssueBuildOrderById
IssueBuildOrderById=function() return false end
local wisp={definition={unit='ewsp'},pawn=unit('ewsp'),timingRun={events={}}}
assert(batch.Action(wisp,{method='Build'}))
assert(last[1]=='point_id' and #wisp.timingRun.events==2)
IssueBuildOrderById=oldBuild
-- Only problem methods are retried, with distinct approach and order variants.
local retest=batch.RetestPlan()
assert(#retest==39)
local retestMethods={}
for _,case in ipairs(retest) do
    assert(case.retest and case.activationPass and case.mode=='isolated')
    retestMethods[case.method.id]=true
end
count=0;for _ in pairs(retestMethods) do count=count+1 end;assert(count==8)
local buildFixture={definition={unit='ewsp'},pawn=unit('ewsp'),caster=unit('Hmkg'),supports={unit('egol'),unit('etol')}}
buildFixture.pawn.x=1000;buildFixture.pawn.y=1000
local buildCase={method={choice='dodge.26',method='Build'},approach='near',route='native'}
terrainBlocked=true
assert(not batch.PrepareRetest(buildFixture,buildCase) and buildFixture.batchSetupFailure)
terrainBlocked=false
nearby={unit('hfoo')};nearby[1].x=1000;nearby[1].y=800
assert(not batch.BuildSiteClear(buildFixture,1000,800))
nearby={};destructible=true
assert(not batch.BuildSiteClear(buildFixture,1000,800))
destructible=false
assert(batch.PrepareRetest(buildFixture,buildCase) and buildFixture.batchBuildSite)
assert(buildFixture.supports[1].removed and buildFixture.supports[2].removed)
assert(buildFixture.pawn.y==buildFixture.batchBuildSite.y+192)
local mountFixture={definition={unit='earc'},pawn=unit('earc'),helper=unit('ehip')}
assert(batch.Action(mountFixture,{choice='dodge.23'}) and last[3]=='coupletarget')
mountFixture.pawn=unit('ehip');mountFixture.helper=unit('earc')
assert(batch.Action(mountFixture,{choice='dodge.24'}) and last[3]=='coupletarget')
local transformFixture={definition={unit='uobs'},pawn=unit('uobs'),timingRetest=true}
assert(batch.Action(transformFixture,{ability='Aave',order='sphinxform'}) and last[3]=='avengerform')
local detonateFixture={definition={unit='ewsp'},pawn=unit('ewsp'),timingRetest=true,batchRoute='point'}
assert(batch.Action(detonateFixture,{ability='Adtn',order='detonate'}) and last[1]=='point')
batch.Start(false,false,true)
scope=batch.scope
for i=1,60000 do now=now+.01;batch.Tick();if not batch.active then break end end
assert(not batch.active and #batch.results==39 and scope.disposed)
batch.Start(true);batch.Tick()
scope=batch.scope;local other={activity={}}
JTG.Controller.session=other
batch.Tick()
assert(not batch.active and scope.disposed and JTG.Controller.session==other)
print('Passed: all 100 threats, 38 methods, 594-case plan, every action route, automatic progression/export, scoped stop and external replacement.')

local meta=batch.MetamorphPlan()
assert(#meta==54)
for _,case in ipairs(meta) do
    assert(case.metamorphPass and JTG.DodgePawns[case.pawnIndex].unit=='Edem')
    assert(case.mode=='meta_baseline' or case.method.ability=='AEme')
end
batch.Start(false,false,false,true)
for i=1,50000 do now=now+.01;batch.Tick();if not batch.active then break end end
assert(not batch.active and #batch.results==54)
for i=#history-53,#history do
    local requested,stopped=false,false
    for _,e in ipairs(history[i].activity.timingRun.events) do
        if e.event=='batch_dodge_request' then requested=true end
        if e.event=='single_shot_stop' then stopped=true end
    end
    assert(stopped)
    assert(requested==(meta[i-(#history-54)].mode~='meta_baseline'))
end
print('Passed: 54 focused Metamorphosis trials, launch scheduling, control cases and single-shot suppression.')
