-- Real scopes, layouts and order callbacks; native entry is explicitly modeled.
JTG={UI={}}
function FourCC(raw) return raw end
function Player(id) return id end
function GetHandleId(handle) return handle end
function GetLocalPlayer() return 0 end
function OrderId(order) return order end
RACE_HUMAN,RACE_ORC='human','orc';PLAYER_NEUTRAL_PASSIVE=15
PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER='gold','lumber'
PLAYER_STATE_GOLD_GATHERED,PLAYER_STATE_LUMBER_GATHERED='gatheredGold','gatheredLumber'
PLAYER_STATE_RESOURCE_HERO_TOKENS='heroTokens'
EVENT_PLAYER_UNIT_TRAIN_FINISH,EVENT_PLAYER_UNIT_CONSTRUCT_START='train','construct'
EVENT_PLAYER_UNIT_TRAIN_START,EVENT_PLAYER_UNIT_TRAIN_CANCEL='train-start','train-cancel'
EVENT_PLAYER_UNIT_CONSTRUCT_FINISH,EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL='built','cancelled'
EVENT_PLAYER_UNIT_ISSUED_ORDER,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER='order','point','target'
ALLIANCE_PASSIVE,MAP_CONTROL_COMPUTER='passive','computer'
ORIGIN_FRAME_GAME_UI,FRAMEPOINT_TOPLEFT,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT='ui','topleft','top','left'
local resources,limits,controllers,alliances={},{},{},{}
for owner=0,2 do
 resources[owner]={gold=73,lumber=81,gatheredGold=10000,gatheredLumber=20000,heroTokens=7}
 limits[owner]=11;controllers[owner]='user';alliances[owner]={}
end
function GetPlayerState(owner,key) return resources[owner][key] or 0 end
function SetPlayerState(owner,key,value) resources[owner][key]=value end
function GetPlayerController(owner) return controllers[owner] end
function SetPlayerController(owner,value) controllers[owner]=value end
local heroLimits={}
function GetPlayerTechMaxAllowed(owner,raw) return (raw=='hpea' or raw=='opeo') and limits[owner] or (heroLimits[owner..raw] or 9) end
function SetPlayerTechMaxAllowed(owner,raw,value)
 if raw=='hpea' or raw=='opeo' then limits[owner]=value else heroLimits[owner..raw]=value end
end
function GetPlayerAlliance(owner,other) return alliances[owner][other] or false end
function SetPlayerAlliance(owner,other,_,value) alliances[owner][other]=value end
local units,trees,tags,triggers={},{},{},{}
function CreateUnit(owner,raw,x,y) local u={owner=owner,raw=raw,x=x,y=y,life=100};units[#units+1]=u;return u end
function RemoveUnit(u) u.removed=true end
function GetUnitTypeId(u) return not u.removed and u.raw or 0 end
function GetOwningPlayer(u) return u.owner end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function GetWidgetLife(u) return u.life end
function IsUnitHidden(u) return u.hidden==true end
function PauseUnit(u,value) u.paused=value end
function IssueTargetOrder(u,order,target) u.order=order;u.target=target;return true end
function IssueImmediateOrder(u,order) u.order=order;return true end
local denied
function IssueImmediateOrderById(u,order) if denied==order then return false end;u.order=order;return true end
function IssueBuildOrderById(u,raw,x,y) if denied==raw then return false end;u.order=raw;u.buildX=x;u.buildY=y;return true end
function IssuePointOrder(u,order,x,y) u.order=order;u.pointX=x;u.pointY=y;return true end
function GetUnitCurrentOrder(u) return u.order or 0 end
function SetResourceAmount(u,value) u.gold=value end
function CreateDestructable(raw,x,y) local t={raw=raw,x=x,y=y};trees[#trees+1]=t;return t end
function SetDestructableLife(t,value) t.life=value end
function RemoveDestructable(t) t.removed=true end
function CreateTextTag() local t={};tags[#tags+1]=t;return t end
function SetTextTagText(t,text,size) t.text=text;t.size=size end
function SetTextTagPos(t,x,y,z) t.x=x;t.y=y;t.z=z end
function SetTextTagPermanent() end
function SetTextTagVisibility(t,value) t.visible=value end
function DestroyTextTag(t) t.removed=true end
function BlzGetOriginFrame() return {} end
function BlzCreateFrameByType() return {} end
function BlzFrameSetText(f,text) f.text=text end
function BlzFrameSetVisible(f,value) f.visible=value end
function BlzFrameSetScale(f,value) f.scale=value end
function BlzFrameSetSize() end
function BlzFrameSetAbsPoint() end
function BlzFrameSetPoint() end
function BlzFrameSetTextAlignment() end
function BlzFrameSetEnable() end
function BlzDestroyFrame(f) f.removed=true end
function CreateQuest() return {} end
function DestroyQuest() end
function QuestSetTitle() end
function QuestSetDescription() end
function QuestSetIconPath() end
function QuestSetRequired() end
function QuestSetDiscovered() end
function QuestSetEnabled() end
function CreateTimer() return {} end
function TimerStart(t,_,_,callback) t.callback=callback end
function PauseTimer() end
function DestroyTimer() end
function CreateTrigger() local t={events={}};triggers[#triggers+1]=t;return t end
function TriggerRegisterPlayerUnitEvent(t,_,event) t.events[event]=true end
function TriggerAddAction(t,callback) t.callback=callback end
function DisableTrigger() end
function DestroyTrigger() end
local event,worker,target,order,created
function GetTriggerEventId() return event end
function GetTriggerUnit() return worker end
function GetOrderTargetUnit() return target end
local targetTree,pointX,pointY
function GetOrderTargetDestructable() return targetTree end
function GetOrderPointX() return pointX end
function GetOrderPointY() return pointY end
function GetIssuedOrderId() return order end
function GetTrainedUnit() return created end
function GetTrainedUnitType() return created.raw end
function GetConstructingStructure() return created end
function GetConstructedStructure() return created end
function GetCancelledStructure() return created end
UNIT_TYPE_STRUCTURE='structure'
function IsUnitType(u,kind)
 return kind==UNIT_TYPE_STRUCTURE and (u.raw=='htow' or u.raw=='ogre' or u.raw=='hbar')
end
function GetUnitRallyUnit(u) return u.rallyUnit end
function GetUnitRallyDestructable(u) return u.rallyTree end
function ClearSelection() end
function SetCameraPosition() end
function JTG.UI.ShowToolbar() end
function JTG.UI.HideToolbar() end
function JTG.UI.HideActivityBriefing() end
function JTG.UI.CreateResultCard() return {} end
function JTG.UI.ShowResultCard(card,spec) card.spec=spec;card.visible=spec.visible~=false end
function JTG.UI.HideResultCard(card) card.visible=false end
dofile('src/infrastructure/core.lua')
function JTG.BorrowCamera() end
function JTG.ResetWorldFog() end
function JTG.ScopeRevealScene() end
JTG.HotkeyCatalog={}
for _,spec in ipairs({{'human','hpea','htow','hhou'},{'orc','opeo','ogre','otrb'}}) do
 for _,command in ipairs({{spec[2],spec[4],'build'},{spec[3],spec[2],'train'},
     {spec[3],'TEST','research'},{spec[3],'TIER','upgrade'},{spec[2],'hbar','build'},{'hbar','hfoo','train'}}) do
  JTG.HotkeyCatalog[#JTG.HotkeyCatalog+1]={race=spec[1],source=command[1],raw=command[2],kind=command[3]}
 end
end
dofile('src/activities/mining-build-order.lua')
dofile('src/activities/mining-micro.lua')
local function fire(kind)
 event=kind
 for _,t in ipairs(triggers) do if t.events[kind] then t.callback() end end
end
for _,race in ipairs({'human','orc'}) do
 for orientation=0,3 do
  for _,base in ipairs({false,true}) do
   units,trees,tags,triggers={},{},{},{}
   local session={active=true,generation=1,scope=JTG.CreateScope('mine'),presentationScope=JTG.CreateScope('ui'),
    descriptor={capabilities={}},scene={},restartData={race=race,orientation=orientation,baseBuild=base}}
   JTG.Controller.session=session;JTG.Controller.generation=1
   local run=JTG.CreateMiningMicroActivity(session);run:setup(session);run:start(session)
   local lane=run.lanes[2]
   assert(resources[0].gold==(base and 500 or 0) and resources[0].lumber==(base and 150 or 0))
   assert(limits[0]==(base and -1 or 5) and limits[1]==(base and -1 or 5) and limits[2]==(base and -1 or 5))
   if base then assert(heroLimits['0HERO']==3 and resources[0].heroTokens==1 and resources[2].heroTokens==1) end
   assert(run.playerHeading.text=='|cffff0000YOU|r' and run.playerHeading.scale==run.lanes[2].counterFrame.scale)
   assert(#trees==(base and 6 or 9))
   assert(#run.lanes==(base and 2 or 3))
   for _,l in ipairs(run.lanes) do
    local first=(l.tree.x-l.hall.x)^2+(l.tree.y-l.hall.y)^2
    for _,tree in ipairs(l.trees) do
     assert((tree.x-l.hall.x)^2+(tree.y-l.hall.y)^2>=first)
     assert(tree.life==1000)
    end
   end
   resources[1].gold=100;resources[2].gold=80
   resources[2].gatheredGold=resources[2].gatheredGold+80
   resources[0].gatheredGold=resources[0].gatheredGold+90
   resources[0].gatheredLumber=resources[0].gatheredLumber+20
   resources[0].gold=5;resources[0].lumber=1 -- Building purchases in the same update.
   run:updateCounters();assert(run.playerGoldMined==90 and run.playerLumberMined==20)
   assert(run.minePercentTag.text==(base and '|cffffcc00+12.5%|r' or '|cffffcc00-10.0%|r'))
   resources[0].gold=205 -- Refund does not count as mining.
   run:updateCounters();assert(run.playerGoldMined==90)
   if base then
    created=CreateUnit(0,'hhou',lane.hall.x+400,lane.hall.y)
    fire('construct');local newBuilding=created
    for index=2,5 do local u=lane.workers[index];u.hidden=true;u.x=lane.mineX;u.y=lane.mineY end
    run:checkFifthGoldWorker();assert(not run.finished)
    created=CreateUnit(0,race=='human' and 'hpea' or 'opeo',lane.hall.x,lane.hall.y)
    fire('train');worker=created;target=lane.mine;order='harvest';fire('target')
    run:checkFifthGoldWorker();assert(not run.finished,'An order alone finished Base Build')
    created.x=lane.mineX;created.y=lane.mineY
    run:checkFifthGoldWorker();assert(not run.finished,'Walking next to the mine counted as entry')
    target=nil;order='move';fire('point');created.hidden=true
    run:checkFifthGoldWorker();assert(not run.finished,'A worker reassigned away from gold still counted')
    created.hidden=false;target=lane.mine;order='harvest';fire('target')
    run.elapsed=20;created.hidden=true
    run:setPaused(true);run:updateCounters();assert(not run.finished and run.elapsed==20)
    run:setPaused(false);run:checkFifthGoldWorker()
    assert(run.finished and run.recoveredGold==10)
    assert(run.resultCard.spec.details=='Total Gold mined: 90\nTotal Lumber mined: 20\nTime Elapsed: 20.0s')
    assert(run.extraGoldFrame.text=='|cffffcc00Extra Gold mined: 10|r' and run.extraGoldFrame.scale==1.5)
    assert(created.paused and newBuilding.paused)
    assert(run:captureResetState().baseBuild and run:captureRotatedState().baseBuild)
   else
    assert(not run.finished and run:captureResetState().baseBuild==false)
   end
   local count=#units;local tag=run.minePercentTag
   run:hidePresentationForMenu();assert(not tag.visible and not run.playerHeading.visible)
   run:restorePresentation();assert(tag.visible and run.playerHeading.visible and #units==count)
   run:discardPresentationForLoad();assert(tag.removed)
   run:rebuildPresentation();assert(#units==count and run.minePercentTag~=tag)
   run:cleanup();JTG.DisposeScope(session.presentationScope);JTG.DisposeScope(session.scope)
   for _,u in ipairs(units) do assert(u.removed,'Base construction/training actor leaked') end
   for _,tree in ipairs(trees) do assert(tree.removed) end
   assert(resources[0].gold==73 and resources[0].lumber==81 and limits[0]==11)
   assert(resources[0].heroTokens==7 and (heroLimits['0HERO'] or 9)==9)
  end
 end
end
-- Economic decisions are mirrored independently of native gathering cycles.
units,trees,tags,triggers={},{},{},{}
local session={active=true,generation=1,scope=JTG.CreateScope('mirror'),presentationScope=JTG.CreateScope('mirror-ui'),
 descriptor={capabilities={}},scene={},restartData={race='human',baseBuild=true}}
JTG.Controller.session=session
local run=JTG.CreateMiningMicroActivity(session);run:setup(session);run:start(session)
local lane,reference=run.lanes[2],run.lanes[1]
local mirror=run.buildMirror
worker=lane.workers[2];target=lane.mine;order='smart'
for i=1,10 do fire('target') end
assert(#mirror.jobs==0,'Repeated gold micro leaked into reference orders')
worker=lane.workers[1];fire('target');run:updateBuildMirror()
assert(#mirror.jobs==1 and mirror.pairs[worker].target==reference.mine)
target=nil;targetTree=lane.tree;order='harvest';fire('target');run:updateBuildMirror()
local before=#mirror.jobs
for i=1,10 do fire('target') end
assert(#mirror.jobs==before,'Lumber re-clicks were mirrored')
targetTree=nil;order='hbar';pointX,pointY=lane.hall.x+450,lane.hall.y+450;fire('point')
local job=mirror.jobs[#mirror.jobs];denied='hbar';run:updateBuildMirror()
assert(not job.issued,'Unaffordable construction was completed or funded')
denied=nil;run:updateBuildMirror();assert(job.issued)
local builder=mirror.pairs[worker]
assert(builder.buildX==pointX+reference.mineX-lane.mineX and builder.buildY==pointY+reference.mineY-lane.mineY)
created=CreateUnit(0,'hbar',pointX,pointY);fire('construct');local playerBuilding=created
created=CreateUnit(reference.owner,'hbar',builder.buildX,builder.buildY);fire('construct');local referenceBuilding=created
assert(mirror.pairs[playerBuilding]==referenceBuilding,'New building has no matching counterpart')
fire('built');run:updateBuildMirror()
assert(job.done and builder.target==reference.tree,'Builder did not resume ordinary gathering')
worker=playerBuilding;order='hfoo';fire('order');run:updateBuildMirror()
assert(referenceBuilding.order=='hfoo','Training from a newly built producer was not mirrored')
worker=lane.hall;order='hpea';fire('order');run:updateBuildMirror()
created=CreateUnit(0,'hpea',lane.hall.x,lane.hall.y);fire('train');local playerWorker=created
worker=playerWorker;order='harvest';target=lane.mine;fire('target');run:updateBuildMirror()
assert(not mirror.pairs[playerWorker],'Delayed training was replaced with an instantly spawned worker')
worker=reference.hall;created=CreateUnit(reference.owner,'hpea',reference.hall.x,reference.hall.y);fire('train')
run:updateBuildMirror();assert(mirror.pairs[playerWorker]==created and created.target==reference.mine)
worker=lane.hall;order='TEST';denied='TEST';fire('order')
order='TIER';fire('order');run:updateBuildMirror()
assert(reference.hall.order=='hpea','Later economic action bypassed the unaffordable queue head')
denied=nil;run:updateBuildMirror();assert(reference.hall.order=='TIER','Research/upgrade did not retry')
-- Native dispatch can return true without starting production. Keep the job
-- pending, retry only while idle, and never replay it during real training.
worker=lane.hall;order='hpea';denied='hpea';fire('order');run:updateBuildMirror()
local pending=mirror.jobs[#mirror.jobs]
assert(not pending.issued and not pending.done,'Rejected training was discarded')
denied=nil;run:updateBuildMirror()
assert(pending.issued and not pending.done,'Unconfirmed training was discarded')
reference.hall.order=0;run:updateBuildMirror();assert(not pending.issued and not pending.done)
run:updateBuildMirror();assert(pending.issued and not pending.done,'Idle unconfirmed training was not retried')
worker=reference.hall;created={raw='hpea'};fire('train-start')
assert(pending.done and pending.confirmed and mirror.training[reference.hall]==pending)
worker=lane.hall;order='hpea';fire('order');run:updateBuildMirror()
local queued=mirror.jobs[#mirror.jobs]
reference.hall.order=0;run:updateBuildMirror()
assert(queued.issued and not queued.done,'Queued training was retried during active production')
worker=reference.hall;created={raw='hpea'};fire('train-start')
assert(queued.confirmed and queued.done and mirror.training[reference.hall]==queued)
created=CreateUnit(reference.owner,'hpea',0,0);fire('train')
assert(mirror.training[reference.hall]==queued,'Prior completion erased the next active training')
created=CreateUnit(reference.owner,'hpea',0,0);fire('train')
assert(not mirror.training[reference.hall])
worker=lane.hall;created=CreateUnit(0,'hpea',0,0);fire('train')
created=CreateUnit(0,'hpea',0,0);fire('train')
-- A right-click on a mine is a rally action for buildings, not a worker
-- harvest click. A worker finishing later follows the actual native rally.
worker=lane.hall;order='smart';target=lane.mine;targetTree=nil;fire('target')
run:updateBuildMirror()
assert(reference.hall.target==reference.mine,'Right-click mine rally was not translated')
lane.hall.rallyUnit=lane.mine
order='hpea';fire('order');run:updateBuildMirror()
worker=lane.hall;created=CreateUnit(0,'hpea',0,0);fire('train');local rallied=created
worker=reference.hall;created=CreateUnit(reference.owner,'hpea',0,0);fire('train')
run:updateBuildMirror()
assert(mirror.pairs[rallied]==created and created.target==reference.mine,
 'New reference worker did not follow the native gold rally')
-- The actual rally can differ from a stale cached resource or move to ground.
worker=lane.hall;order='hpea';lane.hall.rallyUnit=nil;lane.hall.rallyTree=lane.tree
fire('order');run:updateBuildMirror()
created=CreateUnit(0,'hpea',0,0);fire('train');local lumberRallied=created
worker=reference.hall;created=CreateUnit(reference.owner,'hpea',0,0);fire('train')
run:updateBuildMirror();assert(mirror.pairs[lumberRallied].target==reference.tree)
worker=lane.hall;order='smart';target=nil;pointX,pointY=lane.hall.x+200,lane.hall.y+300
fire('point');run:updateBuildMirror()
assert(reference.hall.pointX==pointX+reference.mineX-lane.mineX and not mirror.rallies[lane.hall])
run:setPaused(true);worker=lane.workers[2];target=nil;targetTree=lane.tree;order='harvest';fire('target')
local copy=mirror.pairs[worker];local old=copy.target
run:updateBuildMirror();assert(copy.target==old,'Paused mirror advanced')
run:setPaused(false);run:updateBuildMirror();assert(copy.target==reference.tree)
worker=lane.workers[1];order='hhou';pointX,pointY=lane.hall.x+750,lane.hall.y+450
fire('point');run:updateBuildMirror();local cancelled=mirror.jobs[#mirror.jobs]
created=CreateUnit(0,'hhou',pointX,pointY);fire('construct');fire('cancelled')
assert(cancelled.done and mirror.pairs[worker].order=='stop','Cancelled construction continued on the reference side')
run:cleanup();JTG.DisposeScope(session.presentationScope);JTG.DisposeScope(session.scope)
assert(playerWorker.removed and referenceBuilding.removed,'Mirrored actors leaked')
print('Passed: two-base decisions, no gather micro, unaffordable retries, translated construction, generated actor pairing, research/upgrades and pause/cleanup.')
print('Passed: Mining modes, spending-independent income, rotated three-tree layouts, mine overlay and fifth-worker entry completion.')
