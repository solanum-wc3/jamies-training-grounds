JTG={}
dofile('src/infrastructure/training.lua')
function JTG.ScopeTrackFrame(_,frame) return frame end
function BlzCreateFrameByType() return {} end
function BlzGetOriginFrame() return {} end
function BlzFrameSetSize() end
function BlzFrameSetAbsPoint(frame,_,x,y) frame.x=x;frame.y=y end
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
local staged={};local opts={repeatOnRedo=true,color='|cffffff00',round=2,rounds=2}
JTG.Training.ShowSetupLabel(staged,session,'Stage',1,8,'human:1',opts)
assert(staged.setupLabelFrame.text=='|cffffff00Stage 1/8, Round 2/2|r' and staged.setupLabelFrame.scale>1)
local redo={}
JTG.Training.ShowSetupLabel(redo,session,'Stage',1,8,'human:1',opts)
assert(redo.setupLabelFrame,'Redo must repeat the stage/round announcement')
redo:discardPresentationForLoad();redo:rebuildPresentation()
assert(redo.setupLabelFrame.text=='|cffffff00Stage 1/8, Round 2/2|r','Reload lost yellow stage/round text')
opts.countdown=true
JTG.Training.ShowSetupLabel(redo,session,'Stage',1,8,'human:1',opts)
assert(redo.setupLabelFrame.x==.4 and redo.setupLabelFrame.y==.30,'Stage label is not beneath the central countdown')
JTG.Training.EndSetupLabel(redo);redo:restorePresentation()
assert(not redo.setupLabelFrame.visible and not redo.setupLabelActive,'Stage label survived countdown completion')
print('Passed: first-visit and repeat-on-redo stage/round labels, ten-second expiry, menu hiding and reload style.')
