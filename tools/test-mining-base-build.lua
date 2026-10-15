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
EVENT_PLAYER_UNIT_TRAIN_FINISH,EVENT_PLAYER_UNIT_CONSTRUCT_START='train','construct'
EVENT_PLAYER_UNIT_ISSUED_ORDER,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER='order','point','target'
ALLIANCE_PASSIVE,MAP_CONTROL_COMPUTER='passive','computer'
ORIGIN_FRAME_GAME_UI,FRAMEPOINT_TOPLEFT,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT='ui','topleft','top','left'
local resources,limits,controllers,alliances={},{},{},{}
for owner=0,2 do
 resources[owner]={gold=73,lumber=81,gatheredGold=10000,gatheredLumber=20000}
 limits[owner]=11;controllers[owner]='user';alliances[owner]={}
end
function GetPlayerState(owner,key) return resources[owner][key] or 0 end
function SetPlayerState(owner,key,value) resources[owner][key]=value end
function GetPlayerController(owner) return controllers[owner] end
function SetPlayerController(owner,value) controllers[owner]=value end
function GetPlayerTechMaxAllowed(owner) return limits[owner] end
function SetPlayerTechMaxAllowed(owner,_,value) limits[owner]=value end
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
function GetIssuedOrderId() return order end
function GetTrainedUnit() return created end
function GetConstructingStructure() return created end
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
   assert(limits[0]==(base and -1 or 5) and limits[1]==5 and limits[2]==5)
   assert(run.playerHeading.text=='|cffcc66ffYOU|r' and run.playerHeading.scale==1.8)
   assert(#trees==9)
   for _,l in ipairs(run.lanes) do
    local first=(l.tree.x-l.hall.x)^2+(l.tree.y-l.hall.y)^2
    for _,tree in ipairs(l.trees) do
     assert((tree.x-l.hall.x)^2+(tree.y-l.hall.y)^2>=first)
     assert(tree.life==1000)
    end
   end
   resources[1].gold=100;resources[2].gold=80
   resources[0].gatheredGold=resources[0].gatheredGold+90
   resources[0].gatheredLumber=resources[0].gatheredLumber+20
   resources[0].gold=5;resources[0].lumber=1 -- Building purchases in the same update.
   run:updateCounters();assert(run.playerGoldMined==90 and run.playerLumberMined==20)
   assert(run.minePercentTag.text=='|cffffcc00-10.0%|r')
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
    assert(run.finished and run.expectedLoss==20 and run.actualLoss==10 and run.recoveredGold==10)
    assert(run.resultCard.spec.details:find('Gold loss per 10 seconds: 5.0',1,true))
    assert(run.resultCard.spec.details:find('Gold recovered per 10 seconds: 5.0',1,true))
    assert(run.resultCard.spec.details:find('50.0%',1,true) and created.paused and newBuilding.paused)
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
  end
 end
end
print('Passed: Mining modes, spending-independent income, rotated three-tree layouts, mine overlay and fifth-worker entry completion.')
