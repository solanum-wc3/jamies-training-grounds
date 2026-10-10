-- Synthetic events verify recording only, never Warcraft mechanics.
JTG={Dev={},Registry={byId={}},Controller={}}
local now, current, bootstrap=0,{},nil
local events={'SPELL_CHANNEL','SPELL_CAST','SPELL_EFFECT','SPELL_FINISH','SPELL_ENDCAST','DAMAGED','ATTACKED',
    'USE_ITEM','ISSUED_ORDER','ISSUED_POINT_ORDER','ISSUED_TARGET_ORDER','SUMMON','CONSTRUCT_START',
    'CONSTRUCT_FINISH','CONSTRUCT_CANCEL','LOADED','DEATH'}
local eventMeta={__eq=function(a,b) return a.name==b.name end}
for _,name in ipairs(events) do _G['EVENT_PLAYER_UNIT_'..name]=setmetatable({name=name},eventMeta) end
PLAYER_NEUTRAL_PASSIVE=15
function Player(id) return id end
function GetLocalPlayer() return 0 end
function FourCC(s) local n=0;for i=1,4 do n=n*256+s:byte(i) end;return n end
function GetUnitTypeId(u) return u.removed and 0 or FourCC(u.id) end
function GetHandleId(u) return u.handle end
function GetOwningPlayer(u) return u.owner end
function TimerGetElapsed() return now end
function JTG.StartScopedTimer(s,scope,delay,periodic,fn)
    local t={callback=JTG.GuardSession(s,fn),periodic=periodic,delay=delay};scope.timers[#scope.timers+1]=t;return t
end
function JTG.GuardSession(s,fn) return function(...) if not s.closed then return fn(...) end end end
function JTG.ScopeTrackTrigger(scope,t) scope.trigger=t;return t end
function CreateTrigger() return {} end
function TriggerRegisterPlayerUnitEvent() end
function TriggerRegisterPlayerChatEvent() end
function TriggerAddAction(t,fn) t.action=fn end
function GetTriggerEventId() return current.event end
function GetTriggerUnit() return current.unit end
function GetSpellAbilityId() return FourCC(current.ability or 'AHtb') end
function GetEventDamageSource() return current.source end
function GetEventDamage() return current.damage end
function GetAttacker() return current.source end
function GetIssuedOrderId() return 123 end
function GetManipulatedItem() return {id='pinv'} end
function GetItemTypeId(item) return FourCC(item.id) end
function GetSummonedUnit() return current.summoned end
function GetSummoningUnit() return current.unit end
function GetLoadedUnit() return current.loaded end
function GetTransportUnit() return current.transport end
function IsUnitHidden(u) return u.hidden==true end
function IsUnitInvisible(u) return u.invisible==true end
function BlzIsUnitInvulnerable(u) return u.invulnerable==true end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function GetUnitFacing(u) return u.facing or 0 end
function GetUnitAbilityLevel(u,raw) return u.buff==raw and 1 or 0 end
function JTG.RegisterBootstrapInitializer(fn) bootstrap=fn end
function DisplayTimedTextToPlayer() end
local exported={}
function PreloadGenClear() exported={} end
function PreloadGenStart() end
function Preload(s) exported[#exported+1]=s end
function PreloadGenEnd(path) assert(path=='JTG-Dodge-Timing.pld') end

dofile('src/infrastructure/dodge-timing-diagnostics.lua')
local timing=JTG.Dev.DodgeTiming
local function unit(id,owner,handle) return {id=id,owner=owner,handle=handle,x=0,y=0} end
local enemy,target=unit('Hmkg',1,1),unit('Ewar',0,2)
local cleaned,started,verdicts=false,false,0
local a={danger={id='spell.AHtb',buffs={'BHtb'}},definition={id='dodge.18',buffs={}},stage=1,
    caster=enemy,target=target,pawn=target,baselineUnits={[enemy]=true,[target]=true},
    confirmCast=function(self) self.castConfirmed=true end,
    verdict=function() verdicts=verdicts+1 end,
    start=function() started=true end, cleanup=function() cleaned=true end}
local s={scope={timers={}}}
timing.enabled=true
local run=timing.Attach(s,a)
assert(timing.Attach(s,a)==run and #timing.runs==1)
local function emit(event,u,ability,source,damage)
    current={event=setmetatable({name=event},eventMeta),unit=u,ability=ability,source=source,damage=damage};s.scope.trigger.action()
end
a:start();assert(started and run.events[#run.events].event=='exercise_start')
now=.1;emit('SPELL_CHANNEL',enemy,'AHtb')
now=.5;emit('SPELL_EFFECT',enemy,'AHtb')
now=.6;emit('SPELL_CHANNEL',target,'AEbl')
now=.7;emit('SPELL_EFFECT',target,'AEbl')
now=.8;emit('ATTACKED',target,nil,enemy)
emit('DAMAGED',target,nil,enemy,0)
emit('USE_ITEM',target)
emit('CONSTRUCT_START',unit('ogre',0,3))
local sampler=s.scope.timers[2].callback
target.invisible=true;target.x=300;now=.81;sampler()
a:confirmCast();a:verdict('WELL DONE!')
assert(verdicts==1)
local found={}
for _,e in ipairs(run.events) do found[e.event]=e end
assert(found.ability_effect.ability=='AEbl')
assert(found.attack_start and found.damage.detail=='0.00000')
assert(found.item_used.ability=='pinv' and found.construction_start.role=='player_created')
assert(found.state_invisible.quality=='sampled_transition' and found.position_jump)
assert(found.movement_start and found.movement_start.quality=='sampled_transition')
assert(found.training_launch_confirmation.quality=='training_inference')
assert(not found.missile_launch and not found.impact)
assert(timing.ExportRows()[1]:find('unit_handle',1,true))
-- Focused retests follow replacement handles and sample immunity explicitly.
UNIT_TYPE_DEAD='dead';UNIT_TYPE_MAGIC_IMMUNE='magic_immune'
function IsUnitType(u,kind) return u[kind]==true end
local replacement=unit('ehpr',0,4)
function CreateGroup() return {} end
function GroupEnumUnitsOfPlayer() end
function ForGroup(g,fn) fn() end
function GetEnumUnit() return replacement end
function DestroyGroup() end
a.timingRetest=true;a.timingTrackReplacements=true
now=.9;sampler()
assert(a.timingReplacementUnits[replacement])
local discovered=false
for _,e in ipairs(run.events) do
    if e.event=='replacement_discovered' then assert(e.role=='replacement' and e.quality=='sampled_transition');discovered=true end
end
assert(discovered)
target.magic_immune=true;now=1;sampler()
assert(run.events[#run.events].event=='state_magic_immune')
local movementCount=0
for _,e in ipairs(run.events) do if e.event=='movement_start' then movementCount=movementCount+1 end end
target.dead=true;target.x=400;now=1.1;sampler()
local afterDeath=0
for _,e in ipairs(run.events) do if e.event=='movement_start' then afterDeath=afterDeath+1 end end
assert(afterDeath==movementCount,'Corpse motion must not be measured as live movement')
run.conditions='a,"quoted" condition';timing.Export()
assert(table.concat(exported):find('""quoted""',1,true))
for _,chunk in ipairs(exported) do assert(#chunk<240,'Native export line is too long') end
local before=#run.events
a:cleanup();assert(cleaned and run.closed and next(run.states)==nil)
s.closed=true;sampler();emit('SPELL_EFFECT',enemy,'AHtb')
assert(#run.events==before+1)
timing.enabled=false;timing.Record(run,'forbidden');assert(#run.events==before+1)
local chat
function GetEventPlayerChatString() return chat end
JTG.Registry.byId['skills.missile_dodging']={factory=function()
    return {danger=a.danger,definition=a.definition,stage=2,caster=enemy,target=target,pawn=target,
        setup=function(self) self.setupCalled=true end,start=function() end,
        confirmCast=function() end,verdict=function() end,cleanup=function() end}
end}
bootstrap()
local descriptor=JTG.Registry.byId['skills.missile_dodging']
local s2={id='skills.missile_dodging',scope={timers={}}}
s2.activity=descriptor.factory(s2);s2.activity:setup(s2)
assert(s2.activity.setupCalled and not s2.activity.timingRun)
JTG.Controller.session=s2
chat='-timing-on';timing.commandTrigger.action()
assert(timing.enabled and s2.activity.timingRun and #timing.runs==2)
chat='-timing-off';timing.commandTrigger.action();assert(not timing.enabled)
print('Passed: timing observation events, native/inferred separation, state sampling, CSV, scoped cleanup and stale callbacks.')
