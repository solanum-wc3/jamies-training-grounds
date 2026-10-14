-- Real lifecycle scopes and transition code, with a controllable native clock.
JTG={UI={}}
function Player(id) return id end
function FourCC(raw) return raw end
local timers={}
function CreateTimer() local t={};timers[#timers+1]=t;return t end
function TimerStart(t,delay,repeating,fn) t.delay=delay;t.fn=fn;t.repeating=repeating end
function PauseTimer(t) t.paused=true end
function DestroyTimer(t) t.destroyed=true end
function GetLocalPlayer() return 0 end
function ClearTextMessages() end
function DisplayTimedTextToPlayer() end
function GetUnitTypeId(u) return u and not u.removed and u.raw or 0 end
function GetWidgetLife(u) return u.life or 100 end
function GetUnitCurrentOrder(u) return u.order or 0 end
function IsUnitHidden(u) return u.hidden==true end
function OrderId(order) return order end
function CreateUnit(owner,raw,x,y) return {owner=owner,raw=raw,x=x+16,y=y-16,life=100} end
function RemoveUnit(u) u.removed=true end
function SetUnitPathing(u,v) u.pathing=v end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function SetUnitPosition(u,x,y) u.x=x;u.y=y end
function GetUnitAbilityLevel(u,id) return u.abilities and u.abilities[id] or 0 end
function UnitAddAbility(u,id) u.abilities=u.abilities or {};u.abilities[id]=1 end
function UnitMakeAbilityPermanent(u,_,id) u.permanent=id end
dofile('src/infrastructure/core.lua')
dofile('src/infrastructure/tutorial.lua')
local T=JTG.Tutorial
local session={active=true,generation=1,scope=JTG.CreateScope('test')}
JTG.Controller.generation=1;JTG.Controller.session=session
local actor={raw='hfoo',x=0,life=100}
local a={frames={},narrationBlocks={'test'},presentationVisible=true,step=1}
local entries,resets,exits=0,0,0
local steps={{id='first'},{id='second'}}
function a:showStep(index) self.step=index;entries=entries+1 end
function a:restoreCheckpoint(index)
 return T.RestoreAt(self,index,function()
  resets=resets+1;actor.x=0
  assert(not self.tutorialTransitionActive or self.tutorialStepScope,'Missing restored entry scope')
 end,function(target) self:showStep(target) end)
end
T.InstallRunner(a,session,{id='test',player=0,steps=steps,requireStableIds=true,
 sceneExit=function() exits=exits+1 end})
a:showStep(1)
local parentDisposers=#session.scope.disposers
local oldScope=a.tutorialStepScope
local fired=0
local pending=T.ScheduleStep(session,a,1,function() fired=fired+1 end)
local guarded=T.GuardStep(session,a,function() fired=fired+1 end)
local entry=a.tutorialEntry
a:restoreCheckpoint(1)
assert(oldScope.disposed and pending.destroyed and a.tutorialEntry==entry+1,'Restoration did not cancel the old visit before entry')
pending.fn();guarded();assert(fired==0,'Restoring the same step revived stale work')
a:showStep(2);a:showStep(1);pending.fn();assert(fired==0)
assert(#session.scope.disposers==parentDisposers,'Each visit accumulates a new parent-scope disposer')
entry=a.tutorialEntry
a:renderNarration();a:clearNarration();a:renderNarration()
assert(a.tutorialEntry==entry and not a.tutorialStepScope.disposed,'Presentation changed world entry')
local state=T.CaptureCheckpoint(a,2)
assert(state.stepId=='second' and T.ResolveStep({steps[2],steps[1]},state)==1,'Reset identity depends on list position')
assert(not pcall(T.InstallRunner,{},session,{id='bad',steps={{id='duplicate'},{id='duplicate'}}}))
assert(not pcall(T.InstallRunner,{},session,{id='bad',steps={{}},requireStableIds=true}))
local replayed={}
function a:finishSetup() replayed[#replayed+1]='leave' end
local setup={{id='old'},{id='root',sceneRoot=true,afterContinue='finishSetup'},{id='target'}}
T.Transition(a,'setup-test',function()
 T.ReplaySetup(a,setup,3,function() replayed[#replayed+1]='reset' end,
    function(step) replayed[#replayed+1]=step.id end)
end)
assert(table.concat(replayed,',')=='reset,root,leave','Replay ran an unrelated lesson or entered the target twice')
assert(not pcall(T.ReplaySetup,a,setup,3,function() end,function() end),'Replay changed the world outside a transition')
local before=resets
local watch=T.WatchProgress(session,a,function() return actor.x>=100 end,function(self) T.ResetScene(self) end)
watch.fn();assert(resets==before)
actor.x=100;a.topicsOpen=true;watch.fn();assert(resets==before)
a.topicsOpen=false;JTG.UI.exercisePaused=true;watch.fn();assert(resets==before)
JTG.UI.exercisePaused=false;JTG.UI.nativeMenuOpen=true;watch.fn();assert(resets==before)
JTG.UI.nativeMenuOpen=false;watch.fn();assert(resets==before+1 and actor.x==0 and watch.destroyed)
watch.fn();assert(resets==before+1,'Satisfied condition fired twice or survived reset')
local errors,probes=0,0
local originalPrint=print
print=function() errors=errors+1 end
local invalid=T.WatchProgress(session,a,function() probes=probes+1;error('invalid actor') end,function() error('Unexpected advancement') end)
invalid.fn();invalid.fn()
print=originalPrint
assert(errors==1 and probes==1 and invalid.paused,'A malformed condition repeatedly errored or advanced the tutorial')
local mobile=T.CreateMobileUnit(session.scope,0,'opeo',100,200,0)
assert(mobile.x==116 and mobile.y==184 and mobile.pathing,'Mobile spawn lost native displacement')
local mill=T.CreateSceneUnit(session.scope,0,'ofor',100,200,0)
assert(mill.x==100 and mill.y==200 and mill.abilities.Arlm==1,'Structure placement/drop-off behavior changed')
local alive=T.EnsureMobileUnit(session.scope,mobile,0,'opeo',100,200,0)
assert(alive==mobile)
mobile.life=0
local replacement=T.EnsureMobileUnit(session.scope,mobile,0,'opeo',100,200,0)
assert(replacement~=mobile and mobile.removed and replacement.life==100)
local hidden={raw='opeo',hidden=true,life=100}
local working={raw='opeo',order='harvest',life=100}
local builder={raw='opeo',order='build',life=100,building=true}
local calls=0
local function resume(u)
 if u.building then return end
 calls=calls+1;u.order='harvest'
end
T.RestoreWorkerOrders(session,a,{hidden,working,builder},resume,{force=true})
assert(calls==1 and builder.order=='build')
local retry=timers[#timers]
working.order='player-move';retry.fn();assert(calls==1 and working.order=='player-move')
hidden.hidden=false;retry.fn();assert(hidden.order=='harvest' and calls==2)
T.RestoreWorkerOrders(session,a,{working},resume,{force=false})
retry.fn();assert(working.order=='player-move','Old ownership retry or repeated same-race setup overwrote player orders')
-- Simulate a successful-looking native harvest order which is stale after
-- ownership changes. One delayed refresh is needed; subsequent retries leave it alone.
local stalled={raw='opeo',order='harvest',life=100}
local refreshed=0
T.RestoreWorkerOrders(session,a,{stalled},function(_,preserve)
 assert(not preserve);refreshed=refreshed+1
end,{force=true})
assert(refreshed==1)
local settle=timers[#timers-4];assert(settle.delay==.25)
settle.fn();assert(refreshed==2,'Accepted stale harvest was not refreshed after ownership settled')
timers[#timers].fn();assert(refreshed==2,'Handoff kept reissuing active harvest')
T.RestoreWorkerOrders(session,a,{stalled},function() refreshed=refreshed+1 end,{force=true})
stalled.order='player-move';timers[#timers-4].fn()
assert(refreshed==3 and stalled.order=='player-move','Deferred handoff overwrote player movement')
local scope=a.tutorialStepScope
local scene=T.SceneScope(a,'encounter')
local runner=JTG.ScopeTrackUnit(scene,CreateUnit(1,'ogru',0,0))
local movement=T.SceneTimer(session,a,'encounter',0.1,true,function() runner.x=runner.x+1 end)
a:showStep(2)
assert(not scene.disposed and not movement.destroyed,'A persistent scene was tied to one narration line')
local x=runner.x
T.ClearScene(a,'encounter')
assert(runner.removed and movement.destroyed)
movement.fn();assert(runner.x==x,'Old movement timer affected a replaced scene')
local newScene=T.SceneScope(a,'encounter')
assert(newScene~=scene and not newScene.disposed)
scope=a.tutorialStepScope
a:cleanup();assert(scope.disposed)
JTG.DisposeScope(session.scope)
assert(newScene.disposed,'Current persistent scene survived activity cleanup')
for _,t in ipairs(timers) do assert(t.destroyed,'A tutorial-owned timer survived disposal') end
assert(entries>3 and resets>1 and exits>2)
print('Passed: real step scopes, restore-before-entry cancellation, stable IDs, position-based checks, exact/native placement and protected worker handoffs.')

local ordered={{id='intro'},{id='combat'}}
local reordered={{id='intro'},{id='new-stop'},{id='combat'}}
assert(T.TopicSteps(ordered,{{label='Combat',stepId='combat'}})[1].step==2)
assert(T.TopicSteps(reordered,{{label='Combat',stepId='combat'}})[1].step==3)
assert(not pcall(T.StepIndex,reordered,'typo'),'Authored navigation silently fell back on an unknown ID')
print('Passed: topic links and scene boundaries resolve stable step IDs after narration insertion.')
