-- Check rapid forward/back navigation without waiting for unit production.
local file=assert(io.open('src/activities/camera-tutorial.lua'))
local source=file:read('*a');file:close()
local start=assert(source:find('    function activity:prepareIdleWorkers()',1,true))
local finish=assert(source:find('    function activity:restoreNarrationThrough',start,true))
local created=0
JTG={}
function JTG.CreateScope() return {units={},callbacks={}} end
function JTG.ScopeAdd(scope,callback) scope.callbacks[#scope.callbacks+1]=callback end
function JTG.ScopeTrackUnit(scope,unit) scope.units[#scope.units+1]=unit;return unit end
function JTG.CreateScopedUnit(scope,...) return JTG.ScopeTrackUnit(scope,CreateUnit(...)) end
function JTG.DisposeScope(scope)
 if scope.disposed then return end
 scope.disposed=true
 for _,unit in ipairs(scope.units) do unit.removed=true end
 for _,callback in ipairs(scope.callbacks) do callback() end
end
function FourCC(raw) return raw end
function CreateUnit(owner,raw,x,y,facing) created=created+1;return {raw=raw,x=x,y=y} end
function IssueImmediateOrder(unit,order) unit.order=order end
local activity={createIdleWorkerQuest=function() end,stopNotificationAttack=function() end}
assert(load('return function(activity,session,CAMERA_PLAYER)\n'..source:sub(start,finish-1)..'\nend'))()(activity,{scope=JTG.CreateScope()},0)
activity:runStepTrigger({trigger='idleWorkers'})
assert(created==3)
local original=activity.idleWorkers
original[1].order='harvest'
activity:runStepTrigger({trigger='idleWorkerQuest'})
assert(created==3 and original[1].order=='stop','Forward did not prepare idle state')
activity:runStepTrigger({trigger='idleWorkers'})
assert(created==3,'Back duplicated idle workers')
activity:runStepTrigger({})
assert(original[1].removed and not activity.idleWorkersScope,'Leaving step leaked idle workers')
activity:runStepTrigger({trigger='idleWorkers'})
assert(created==6 and activity.idleWorkers[1].order=='stop','Revisit did not restore idle workers')
print('Passed: Camera idle workers prepared immediately, reused on Back/Continue and removed on exit.')

-- Camera Back used to bypass the shared entry generation. A pending callback
-- from the previous visit must remain stale even after a rapid A-B-A revisit.
dofile('src/infrastructure/tutorial.lua')
local pending
function JTG.StartScopedTimer(_,_,_,_,callback) pending=callback end
local backStart=assert(source:find('    function activity:goBack()',1,true))
local backEnd=assert(source:find('    function activity:restoreZoomCheckpoint',backStart,true))
local steps={{trigger='idleWorkers',wait=true},{trigger='idleWorkerQuest',wait=true}}
activity.tutorialSpec={steps=steps}
function activity:abandonOptionalSection() end
function activity:setObjectivesVisible() end
function activity:revealQuestsThrough() end
assert(load('return function(activity,TUTORIAL_STEPS,OPTIONAL_SECTIONS)\n'..source:sub(backStart,backEnd-1)..'\nend'))()(activity,steps,{})
activity.step=2;activity.tutorialEntry=10;activity.announcedHeadings={old=true}
function activity:restoreNarrationThrough(index) assert(index==1) end
function activity:refreshControls() end
local invoked=false
JTG.Tutorial.ScheduleStep({scope={}},activity,1,function() invoked=true end)
activity:goBack()
assert(activity.step==1 and activity.tutorialEntry==11 and not next(activity.announcedHeadings))
activity.step=2;pending();assert(not invoked,'Rapid Back/Next revived a stale Camera callback')
print('Passed: Camera Back creates a new narration entry and rejects stale callbacks after fast revisits.')
