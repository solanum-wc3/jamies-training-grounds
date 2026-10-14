JTG={UI={}}
function Player(i) return i end
function FourCC(raw) return raw end
local triggers,timers={},{}
function CreateTrigger() local t={};triggers[#triggers+1]=t;return t end
function TriggerRegisterPlayerUnitEvent() end
function TriggerAddAction(t,fn) t.fn=fn end
function DestroyTrigger(t) t.destroyed=true end
function DisableTrigger(t) t.disabled=true end
function CreateTimer() local t={};timers[#timers+1]=t;return t end
function TimerStart(t,_,_,fn) t.fn=fn end
function PauseTimer(t) t.paused=true end
function DestroyTimer(t) t.destroyed=true end
function RemoveUnit(u) u.removed=true end
function GetUnitTypeId(u) return u and not u.removed and u.raw or 0 end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function SetUnitPosition(u,x,y) u.x=x;u.y=y end
local research=1
function GetPlayerTechCount() return research end
function SetPlayerTechResearched(_,_,value) research=value end
function IssueImmediateOrderById(u,raw) u.queue=raw;return true end
function IssueImmediateOrder(u,order) if order=='cancel' then u.queue=nil end;return true end
function IssuePointOrder() end
function IsTerrainPathable() return false end
EVENT_PLAYER_UNIT_TRAIN_FINISH='train';EVENT_PLAYER_UNIT_CONSTRUCT_START='start';EVENT_PLAYER_UNIT_CONSTRUCT_FINISH='finish'
local event,trained,structure,building
function GetTriggerEventId() return event end
function GetTriggerUnit() return building end
function GetTrainedUnit() return trained end
function GetConstructingStructure() return structure end
function GetConstructedStructure() return structure end
dofile('src/infrastructure/core.lua');dofile('src/infrastructure/tutorial.lua')
local session={active=true,generation=1,scope=JTG.CreateScope('production-test')}
JTG.Controller.session=session;JTG.Controller.generation=1
local fortress,barracks,warMill={raw='ofrt'},nil,nil
barracks={raw='obar'};warMill={raw='ofor'}
local activity={step=1}
function activity:findOwnedUnit(raw) return ({ofrt=fortress,obar=barracks,ofor=warMill})[raw] end
function activity:provideNotificationResources() end
function activity:enableWarpTen() self.warp=true end
function activity:disableWarpTen() self.warp=false end
local f=assert(io.open('src/activities/camera-tutorial.lua'));local source=f:read('*a');f:close()
local first=assert(source:find('    function activity:orderDemoBurrow(',1,true))
local last=assert(source:find('    function activity:stopNotificationAttack()',first,true))
assert(load('return function(activity,session,CAMERA_PLAYER)\n'..source:sub(first,last-1)..'\nend'))()(activity,session,0)
function activity:showStep(index) self.step=index;if index==1 then self:startNotificationProduction() end end
JTG.Tutorial.InstallRunner(activity,session,{id='camera-test',player=0,steps={{id='production'},{id='later'}},
 sceneExit=function(self,previous) if previous.id=='production' then self:stopNotificationProduction() end end})
activity:showStep(1)
local oldTrigger=triggers[1]
activity:startNotificationProduction();assert(#triggers==1,'Duplicate notification production in one visit')
event='train';trained={raw='opeo'};building=fortress;oldTrigger.fn()
local oldPeon=trained;local oldTimer=timers[#timers]
research=2;activity:showStep(2)
assert(oldPeon.removed and oldTrigger.destroyed and oldTimer.destroyed and research==1 and not activity.warp)
assert(not fortress.queue and not barracks.queue and not warMill.queue)
oldTimer.fn();assert(not activity.demoBurrowSite,'Old delayed build survived scene exit')
activity:showStep(1)
local current=triggers[#triggers]
assert(current~=oldTrigger and not current.destroyed and fortress.queue=='opeo' and warMill.queue=='Rome')
event='train';trained={raw='opeo'};building=fortress;current.fn()
local peon=trained
function IssueBuildOrderById(_,raw,x,y)
 -- A construction event may fire immediately, before the native order returns.
 structure={raw=raw,x=x,y=y};event='start';current.fn();return true
end
timers[#timers].fn()
local burrow=structure
assert(activity.demoBurrowSite and burrow.raw=='otrb')
activity:showStep(2)
assert(peon.removed and burrow.removed and current.destroyed,'Partial construction was not owned by its visit')
event='train';trained={raw='opeo'};building=fortress;current.fn()
assert(not trained.removed and not activity.demoPeon,'Stale completion callback changed the replacement visit')
activity:cleanup();JTG.DisposeScope(session.scope)
print('Passed: repeatable Camera production, native instant construction tracking, borrowed research restoration, cancellation and stale completion guards.')
