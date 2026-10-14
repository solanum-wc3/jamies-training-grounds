JTG={UI={}}
dofile('src/infrastructure/training.lua')
function JTG.ScopeTrackFrame(scope,frame) scope.frames[#scope.frames+1]=frame;return frame end
function BlzCreateFrameByType() return {} end
function BlzGetOriginFrame() return {} end
local questButton={}
function BlzGetFrameByName(name) assert(name=='UpperButtonBarQuestsButton');return questButton end
function BlzFrameSetScale(frame,value) frame.scale=value end
function BlzFrameSetAlpha(frame,value) frame.alpha=value end
function BlzFrameSetSize() end
function BlzFrameSetAbsPoint() end
function BlzFrameSetTextAlignment() end
function BlzFrameSetEnable() end
function BlzFrameSetText(frame,text) frame.text=text end
function BlzFrameSetVisible(frame,value) frame.visible=value end
function PauseTimer(timer) timer.paused=true end
function JTG.UI.CreateWelcomeArrow(scope,root,target)
 assert(target==questButton,'Arrow does not point to the real native Quest button')
 return JTG.ScopeTrackFrame(scope,{})
end
function JTG.StartScopedTimer(session,scope,_,_,fn)
 local timer={}
 timer.tick=function() if session.active and not timer.paused then fn() end end
 scope.timer=timer;return timer
end
local session={active=true,scope={},presentationScope={frames={}},restartData={}}
local activity={presentationVisible=true}
for index=1,9 do JTG.Training.RecordFailure(activity,session,false) end
assert(not activity.questHintText)
JTG.Training.RecordFailure(activity,session,true)
assert(session.restartData._questHelp.failures==0)
for index=1,10 do JTG.Training.RecordFailure(activity,session,false) end
local state=session.restartData._questHelp
assert(state.shown and activity.questHintText.visible and activity.questHintArrow.visible)
assert(activity.questHintText.scale==1.85 and activity.questHintText.alpha==230 and activity.questHintText.text:find('|cff80c8ff',1,true))
for blink=1,3 do
 for index=1,3 do session.scope.timer.tick() end
 assert(not activity.questHintArrow.visible)
 for index=1,3 do session.scope.timer.tick() end
 assert(activity.questHintArrow.visible)
end
for index=1,82 do session.scope.timer.tick() end
assert(not activity.questHintText.visible and activity.questHintArrow.visible)
activity:hidePresentationForMenu();assert(not activity.questHintArrow.visible)
activity:restorePresentation();assert(activity.questHintArrow.visible)
for index=1,118 do session.scope.timer.tick() end
assert(not state.active and not activity.questHintArrow.visible and session.scope.timer.paused)
JTG.Training.RecordFailure(activity,session,false)
assert(not state.active,'Hint repeated in the same session')
local body={race='human',runnerIndex=1,runnerId='hfoo'}
local bodySession={restartData={}}
for index=1,4 do JTG.Training.RecordBodyBlockingRedo(body,bodySession,{runnerIndex=1}) end
assert(not bodySession.restartData._questHelp.shown)
JTG.Training.RecordBodyBlockingRedo(body,bodySession,{runnerIndex=1})
assert(bodySession.restartData._questHelp.shown)
body.nextRunnerRequested=true
JTG.Training.RecordBodyBlockingRedo(body,bodySession,{runnerIndex=2})
assert(bodySession.restartData._questHelp.redoCount==0)
session.active=false
local previous=state.elapsed;session.scope.timer.tick();assert(state.elapsed==previous)
print('Passed: ten failures/success reset, five same-runner Redos, once-only hint, 10-second text, three blinks and 20-second arrow.')
