JTG={}
dofile('src/infrastructure/training.lua')
function JTG.ScopeTrackFrame(_,frame) return frame end
function BlzCreateFrameByType() return {} end
function BlzGetOriginFrame() return {} end
function BlzFrameSetSize() end
function BlzFrameSetAbsPoint() end
function BlzFrameSetTextAlignment() end
function BlzFrameSetScale(frame,value) frame.scale=value end
function BlzFrameSetAlpha(frame,value) frame.alpha=value end
function BlzFrameSetEnable() end
function BlzFrameSetText(frame,text) frame.text=text end
function BlzFrameSetVisible(frame,value) frame.visible=value end
local expiry
function JTG.StartScopedTimer(_,_,seconds,_,callback) assert(seconds==10);expiry=callback end
local session={restartData={},scope={},presentationScope={}}
local activity={}
JTG.Training.ShowSetupLabel(activity,session,'Runner',2,8,'orc:2')
local first=activity.setupLabelFrame
assert(first.text=='|cff80c8ffRunner 2/8|r' and first.scale==1.85 and first.alpha==230)
activity:hidePresentationForMenu();assert(not first.visible)
activity:restorePresentation();assert(first.visible)
expiry();activity:restorePresentation();assert(not first.visible)
local restarted={}
JTG.Training.ShowSetupLabel(restarted,{restartData=session.restartData},'Runner',2,8,'orc:2')
assert(not restarted.setupLabelFrame,'Redo repeated a visited setup label')
JTG.Training.ShowSetupLabel(activity,session,'Runner',3,8,'orc:3')
assert(activity.setupLabelFrame~=first,'New runner missed label')
local beforeLoad=activity.setupLabelFrame
activity:discardPresentationForLoad();activity:rebuildPresentation()
assert(activity.setupLabelFrame~=beforeLoad and activity.setupLabelFrame.text:find('Runner 3/8',1,true))
expiry();assert(not activity.setupLabelFrame.visible,'Reload left setup label visible indefinitely')
JTG.Training.ShowSetupLabel({}, {restartData={},scope={},presentationScope={}},'Runner',2,8,'orc:2')
print('Passed: first-visit labels, five-second expiry, menu hiding and carried visit state.')
