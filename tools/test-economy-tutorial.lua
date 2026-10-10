-- Run after tools/test-tutorial-layout-workspace.lua; validate script state and native orders.
JTG.UI={ToolbarLayout={buttonWidth=.087,gap=.001,rowStep=.025,left=.446,top=.575},epoch=1}
function JTG.UI.ClearWelcomeArrow() end
function JTG.UI.RefreshWelcomeArrow() end
function JTG.UI.StartWelcomeArrow(a) a.welcomeStarted=true end
function JTG.UI.TickWelcomeArrow() end
function JTG.UI.HideToolbar() end
function JTG.UI.CreateWelcomeArrow() return {} end
function JTG.UI.RegisterPauseHighlight() return function() end end
function JTG.UI.SetExercisePaused() end
function JTG.UI.SetGameplayMenuPaused() end
function JTG.UI.ShowActivityMenu() end
function JTG.ClearBlightAfterActivity() return function() end end
function JTG.TutorialMenuHeight(n) return .1+n*.03 end
local frames={}
function BlzCreateFrameByType() local f={};frames[#frames+1]=f;return f end
function BlzCreateFrame() return {} end
function BlzGetOriginFrame() return {} end
function BlzFrameGetChild() return {} end
function BlzGetFrameByName() return nil end
function BlzFrameSetSize() end
function BlzFrameSetAbsPoint() end
function BlzFrameSetPoint() end
function BlzFrameClearAllPoints() end
function BlzFrameSetScale() end
function BlzFrameSetText(f,t) f.text=t end
function BlzFrameSetVisible(f,v) f.visible=v end
function BlzFrameSetEnable() end
function BlzFrameSetAlpha() end
function BlzFrameSetTextColor() end
function BlzFrameSetModel() end
function BlzFrameSetTexture() end
function BlzFrameSetLevel() end
function BlzConvertColor() return 0 end
function BlzTriggerRegisterFrameEvent() end
function GetHandleId(f) return tostring(f) end
function JTG.ScopeTrackFrame(_,f) return f end
local triggers={}
function CreateTrigger() local t={};triggers[#triggers+1]=t;return t end
function OrderId(name) return name end
function GetUnitCurrentOrder(u) return u.order or 0 end
function SetUnitAcquireRange(u,value) u.acquire=value end
function SetUnitCreepGuard(u,value) u.creepGuard=value end
function RemoveGuardPosition(u) u.guardRemoved=true end
local timers={}
function JTG.StartScopedTimer(_,_,delay,repeating,fn) local t={delay=delay,repeating=repeating,fn=fn};timers[#timers+1]=t;return t end
function TriggerRegisterPlayerUnitEvent(t,p,event) t.events=t.events or {};t.events[#t.events+1]={p,event} end
function GetPlayerRace() return 'human' end
function SetPlayerRacePreference() error('Economy must preserve the selected native UI race') end
RACE_HUMAN='human';RACE_ORC='orc';RACE_NIGHTELF='nightelf';RACE_UNDEAD='undead'
RACE_PREF_HUMAN=1;RACE_PREF_ORC=2;RACE_PREF_NIGHTELF=3;RACE_PREF_UNDEAD=4
PLAYER_STATE_RESOURCE_FOOD_USED='used'
EVENT_PLAYER_UNIT_CONSTRUCT_START='construct';EVENT_PLAYER_UNIT_CONSTRUCT_FINISH='constructed';EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL='cancelled';EVENT_PLAYER_UNIT_TRAIN_FINISH='trained'
EVENT_PLAYER_UNIT_ISSUED_ORDER='order';EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER='point';EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER='target';EVENT_PLAYER_UNIT_SUMMON='summon';EVENT_PLAYER_UNIT_SPELL_EFFECT='spell'
function GetWidgetLife(u) return u.life or (u.removed and 0 or 1000) end
function SetWidgetLife(u,v) u.life=v end
function KillUnit(u) u.life=0;u.killed=true end
function BlzGetUnitMaxHP() return 1000 end
function UnitSetConstructionProgress(u,p) u.progress=p end
function IssueImmediateOrder(u,name) u.order=name;return true end
function IssueImmediateOrderById(u,id) u.order=id;return false end
function IssuePointOrder(u,name,x,y) u.order=name;u.destination={x,y};return true end
function IssueBuildOrderById(u,id,x,y) u.order='build';u.buildId=id;u.destination={x,y};return true end
function SelectUnit() end
function SelectHeroSkill() end
function ClearTextMessages() end
function JTG.StartActivityAfterCleanup(id,_,state) JTG.testJump={id=id,step=state.step} end
function GetUnitTypeId(u) return u.removed and 0 or u.raw end
local current
function GetTriggerUnit() return current end
function BlzUnitDisableAbility(u,id,disabled) u.disabled=u.disabled or {};u.disabled[id]=disabled end
UNIT_TYPE_STRUCTURE='structure'
function IsUnitIdType(id,kind)
 assert(kind==UNIT_TYPE_STRUCTURE)
 for _,raw in ipairs({'hpea','opeo','ewsp','uaco','ugho','ushd','hfoo','hmil'}) do
  if id==FourCC(raw) then return false end
 end
 return true
end
function GetUnitAbilityLevel(u,id) return u.abilities and u.abilities[id] or 0 end
function UnitAddAbility(u,id) u.abilities=u.abilities or {};u.abilities[id]=1 end
function UnitMakeAbilityPermanent(u,permanent,id) u.permanent=u.permanent or {};u.permanent[id]=permanent end
function SetUnitFacing(u,facing) u.facing=facing end
function IsUnitVisible() return true end
function SetUnitPosition(u,x,y) u.x=x;u.y=y;u.modelX=x;u.modelY=y end
-- Model a native displacement separately from the visible model: coordinate-only
-- setters would leave the two positions out of sync, as in the reported images.
local nativeCreate=CreateUnit
function CreateUnit(owner,id,x,y,facing)
 local u=nativeCreate(owner,id,x,y,facing)
 if IsUnitIdType(id,UNIT_TYPE_STRUCTURE) then u.x=x+128;u.y=y+128 end
 u.modelX=u.x;u.modelY=u.y
 return u
end
function SetUnitPathing(u,v) u.pathing=v end
-- Model the engine cancelling orders when ownership changes.
function SetUnitOwner(u,p)
 if u.owner~=p then u.order='stop' end
 u.owner=p
end
function SetBlight() end
local moves={}
function PanCameraToTimed(x,y,duration) assert(duration==1.5);moves[#moves+1]={x,y} end
-- Foundations must be hidden, never layered underneath prepared racial mines.
local elfFoundation=CreateUnit(15,FourCC('ngol'),-5248,-4352,0)
local udFoundation=CreateUnit(15,FourCC('ngol'),-6528,2432,0)
-- Add native lifecycle helpers to scope-owned environment fixture.
dofile('src/infrastructure/economy-layout.lua')
dofile('src/generated/economy-script.lua')
dofile('src/infrastructure/tutorial.lua')
dofile('src/activities/economy-tutorial.lua')
local session={scope={},presentationScope={},generation=100,scene={centerX=0,centerY=0},restartData={}}
local a=JTG.CreateEconomyTutorialActivity(session)
a:setup(session)
local establishedHuman=a:findUnit('hpea',1,'gold')
local nativeTargetOrder=IssueTargetOrder
local duplicateStartupOrders=0
function IssueTargetOrder(u,name,target)
 if u==establishedHuman then duplicateStartupOrders=duplicateStartupOrders+1 end
 return nativeTargetOrder(u,name,target)
end
a:start()
IssueTargetOrder=nativeTargetOrder
assert(duplicateStartupOrders==0,'Startup and welcome must preserve an established gathering order')
assert(a.step==1 and a.welcomeStarted)
assert(#JTG.EconomySteps==58)
local human=a:findUnit('hpea',1,'gold')
assert(GetOwningPlayer(human)==0 and human.order=='harvest')
assert(a.protectedOrderTrigger==nil,'Engine orders must not be intercepted')
assert(elfFoundation.hidden and udFoundation.hidden)
assert(not elfFoundation.pathing and not udFoundation.pathing)
for _,assignment in ipairs(a.placements) do
 if IsUnitIdType(assignment.unit.raw,UNIT_TYPE_STRUCTURE) then
  assert(assignment.unit.x==assignment.placement.x and assignment.unit.y==assignment.placement.y)
  assert(assignment.unit.modelX==assignment.placement.x and assignment.unit.modelY==assignment.placement.y)
 else
  assert(assignment.unit.pathing==true)
  assert(assignment.unit.x==assignment.placement.x and assignment.unit.y==assignment.placement.y,
   "Initial workers must use their authored gathering positions")
 end
end
local mobileSeen=false
for _,u in ipairs(a.units) do
 if not IsUnitIdType(u.raw,UNIT_TYPE_STRUCTURE) then mobileSeen=true
 else assert(not mobileSeen,'Every initial building must precede workers') end
end
local hall=a:findUnit('htow',1)
assert(GetUnitAbilityLevel(hall,FourCC('Amic'))==1 and hall.permanent[FourCC('Amic')])
local beforeUnits=#a.units
local workOrder=human.order
a:clearNarration();a:renderNarration();a:setPresentationVisible(false);a:setPresentationVisible(true)
assert(#a.units==beforeUnits and human.order==workOrder,'Presentation cannot reset scene or issue orders')
local visit=a.tutorialEntry
a:discardPresentationForLoad();a:rebuildPresentation()
assert(#a.units==beforeUnits and human.order==workOrder and a.tutorialEntry==visit,
 'Presentation reconstruction replayed world actions or entered the step again')
local function index(action)
 for i,spec in ipairs(JTG.EconomySteps) do if spec.action==action or (type(action)=='number' and spec.sourceStop==action) then return i end end
 error('Missing action '..tostring(action))
end
local function show(action) a:showStep(index(action)) end
show(5)
for i=1,140 do a:tick() end
assert(not a.arrowBlinking and a.arrowVisible and a.arrowToggles==20)
local wisp=a:findUnit('ewsp',3,'lumber')
assert(GetOwningPlayer(wisp)==4)
show(7)
local attackers={a.attackers[1],a.attackers[2]}
assert(#attackers==2 and GetOwningPlayer(attackers[1])==5 and attackers[1].order=='attack' and attackers[1].target==human)
show(8);assert(attackers[1].killed and attackers[2].killed and human.order=='harvest')
show(9);assert(hall.life==800)
local peasant=a:findUnit('hpea',1,'lumber')
peasant.order='player-repair'
show('human-repair');assert(peasant.order=='player-repair','Repair is a player action')
show(10);show('human-build');assert(not a:findUnit('halt',1))
peasant.order='player-build'
show('construction-cost');assert(peasant.order=='player-build','Continue must not cancel player construction')
show(11);assert(a.raceIndex==2 and GetOwningPlayer(human)==2 and peasant.order=='stop')
local goldPeon=a:findUnit('opeo',2,'gold')
assert(goldPeon.order=='harvest' and goldPeon.target.raw==FourCC('ngol'))
show('orc-build');assert(not a:findUnit('oalt',2) and not a:findUnit('owtw',2))
local peon=a:findUnit('opeo',2,'lumber');peon.order='player-build'
show(14);show('orc-burrow');assert(peon.order=='player-build')
assert(moves[#moves][1]==4064 and moves[#moves][2]==-5280,'Select the Burrow by the Gold Mine')
show(15);assert(#a.attackers==3)
show(16);assert(a.attackers[1].killed)
show(17);assert(a.raceIndex==3 and #a.attackers==0 and peon.order=='stop')
assert(a:findUnit('ewsp',3,'gold').order=='harvest')
show(20);show('nightelf-build');assert(wisp.order=='harvest' and not a:findUnit('eden',3))
wisp.order='player-build'
show(21);assert(wisp.order=='player-build')
show(23);assert(#a.attackers==1 and a.attackers[1].order=='spiritwolf')
assert(a.attackers[1].x>-4000 and a.attackers[1].y>-3000)
local otherWisp=a:visibleLumberWisp()
otherWisp.hidden=true
local visibleWisp=a:visibleLumberWisp();assert(visibleWisp and visibleWisp~=otherWisp)
local wolfUnit=CreateUnit(1,FourCC('osw1'),-3400,-2400,225)
function GetSummonedUnit() return wolfUnit end
for _,t in ipairs(triggers) do
 for _,event in ipairs(t.events or {}) do if event[2]==EVENT_PLAYER_UNIT_SUMMON then t.action() end end
end
assert(wolfUnit.target==visibleWisp and wolfUnit.acquire==0 and wolfUnit.guardRemoved)
-- Model the native summon behavior overwriting the initial attack with a move.
wolfUnit.order='move';a:tick();assert(wolfUnit.order=='attack' and wolfUnit.target==visibleWisp)
otherWisp.hidden=false
show(24);assert(a.raceIndex==4 and #a.attackers==0 and wisp.order=='stop')
local acolyte=a:findUnit('uaco',4,'gold')
show(27);show('text-27');show('undead-build');assert(acolyte.order=='harvest' and not a:findUnit('uaod',4))
acolyte.order='player-unsummon'
show(28);assert(acolyte.order=='player-unsummon')
acolyte.order='player-sacrifice'
show(29);assert(acolyte.order=='player-sacrifice')
-- Native player buildings and trained units must still be tracked for cleanup.
local altar=CreateUnit(0,FourCC('uaod'),-5664,1120,270)
function GetTriggerEventId() return EVENT_PLAYER_UNIT_CONSTRUCT_START end
function GetConstructingStructure() return altar end
function GetTrainedUnit() return nil end
a.constructionTrigger.action()
assert(a.unitFaction[altar]==4 and acolyte.order=='player-sacrifice')
show(34);assert(a:findUnit('hkee',1) and a:findUnit('hcas',1))
show(35);assert(not a:findUnit('hkee',1) and not a:findUnit('hcas',1))
local before=a.raceIndex
show(36)
for _,t in ipairs(timers) do if not t.repeating then t.fn() end end
assert(a.raceIndex==before,'Delayed camera changes cannot survive Continue')
show(41);assert(GetPlayerState(0,'used')==51)
show(43);assert(GetPlayerState(0,'used')==50)
show(44);assert(GetPlayerState(0,'used')==81)
local retained=human
human.order='harvest';human.x=-3000;human.y=-6800
a:goBack();assert(a.step==index(44)-1 and a:findUnit('hpea',1,'gold')==retained)
assert(human.x==-3000 and human.y==-6800,'Back displaced a gathering worker')
a:restoreTopic(index(17));assert(a.step==index(17))
-- Checkpoint reconstruction follows new practice steps, not obsolete demo indexes.
a:prepareCheckpoint(index('human-build'));assert(not a:findUnit('halt',1))
a:prepareCheckpoint(index('construction-cost'));assert(a:findUnit('halt',1))
a:prepareCheckpoint(index(21));assert(a:findUnit('eden',3) and a:findUnit('eate',3))
a:prepareCheckpoint(index(28));assert(a:findUnit('uaod',4))
local topics=0
for _,spec in ipairs(JTG.EconomySteps) do if not spec.terminal then topics=topics+1 end end
assert(JTG.EconomySteps[#JTG.EconomySteps].checkpoint=='upkeep')
a:setRace(2);assert(goldPeon.order=='harvest')
goldPeon.order=nil;timers[#timers].fn();assert(goldPeon.order=='harvest','Idle gold miner gets a post-handoff retry')
local lumberPeon=a:findUnit('opeo',2,'lumber')
lumberPeon.order=nil;timers[#timers].fn();assert(lumberPeon.order=='harvest','Handoff retry covers lumber too')
lumberPeon.order='player-move';timers[#timers].fn();assert(lumberPeon.order=='player-move','Handoff retry must preserve an active player order')
local staleRetry=timers[#timers].fn
a:setRace(3);goldPeon.order=nil;staleRetry();assert(not goldPeon.order,'Old race retry must not affect an inactive base')
local originalFog=JTG.ResetWorldFog
function JTG.ResetWorldFog() goldPeon.order=nil end
a:setRace(2);assert(goldPeon.order=='harvest','Work restoration must follow the fog reset')
JTG.ResetWorldFog=originalFog
a:setRace(3);assert(a:findUnit('ewsp',3,'lumber').order=='harvest')
a:setRace(4);assert(a:findUnit('ugho',4,'lumber').order=='harvest')
show(49);assert(a.complete and not a.waitingForContinue and a.frames.menuHighlight.visible)
-- Native construction belongs to its worker until finish/cancel; failed or
-- cancelled orders must not prevent later gathering after a handoff.
current=human
local issued=FourCC('halt')
function GetIssuedOrderId() return issued end
function GetOrderPointX() return -2000 end
function GetOrderPointY() return -6000 end
a.workerOrdersTrigger.action()
assert(a.workerTasks[human].building==true)
human.order='build';a:startGathering(human)
assert(human.order=='build','Gathering interrupted a pending build')
issued='stop';a.workerOrdersTrigger.action()
assert(not a.workerTasks[human])
a:startGathering(human);assert(human.order=='harvest')
issued=FourCC('halt');a.workerOrdersTrigger.action()
local building=CreateUnit(GetOwningPlayer(human),issued,-2000,-6000,270)
function GetTriggerEventId() return EVENT_PLAYER_UNIT_CONSTRUCT_START end
function GetConstructingStructure() return building end
a.constructionTrigger.action();assert(a.workerTasks[human].building==building)
human.order='repair';a:startGathering(human);assert(human.order=='repair')
function GetTriggerEventId() return EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL end
function GetCancelledStructure() return building end
a.constructionTrigger.action();assert(not a.workerTasks[human])
a:startGathering(human);assert(human.order=='harvest')
a:setRace(2)
-- A carrying worker can reject a mine order after ownership changes. Its
-- native return-and-resume order must target an owned gold drop-off instead.
local greatHall=a:findUnit('ogre',2)
greatHall.abilities=greatHall.abilities or {};greatHall.abilities[FourCC('Argl')]=1
local targetOrder=IssueTargetOrder
function IssueTargetOrder(unit,order,target)
 if unit==goldPeon and order=='harvest' then return false end
 if unit==goldPeon and order=='resumeharvesting' then assert(target==greatHall and target.owner==unit.owner) end
 return targetOrder(unit,order,target)
end
a:startGathering(goldPeon)
assert(goldPeon.order=='resumeharvesting' and goldPeon.target==greatHall)
local observed=a.gatheringObservations[goldPeon]
assert(observed.firstAccepted==false and observed.accepted and observed.target.raw==FourCC('ngol') and observed.orderTarget==greatHall)
a:startGathering(goldPeon,nil,true)
assert(goldPeon.order=='resumeharvesting','Do not interrupt a working native delivery cycle')
IssueTargetOrder=targetOrder
a:startGathering(goldPeon)
local diagnostics={}
function PreloadGenClear() diagnostics={} end
function PreloadGenStart() end
function Preload(text) assert(#text<=240);diagnostics[#diagnostics+1]=text end
local diagnosticPath
function PreloadGenEnd(path) diagnosticPath=path end
function GetResourceAmount(u) return u.gold or 12500 end
a:reportWorkerOrders()
assert(diagnosticPath=='JTG-Economy-Orders.pld')
assert(diagnostics[1]:find('//JTG_ECONOMY_META',1,true))
local peonRows=0
for i=3,#diagnostics do
 local row=diagnostics[i]
 if row:find(',orc,opeo,gold,',1,true) then
  peonRows=peonRows+1
  assert(row:find(',harvest,true,harvest,harvest,',1,true),'Export must retain issued and current Peon orders separately')
 end
end
assert(peonRows==5,'Export must contain all five gold-mining Peons')
a:cleanup()
for i=#session.scope,1,-1 do session.scope[i]() end
for _,u in ipairs(a.units) do assert(u.removed) end
assert(#moves>0)
assert(not elfFoundation.hidden and elfFoundation.pathing)
print('Passed: 58 Economy stops, player-led repair/construction/Burrow/Unsummon/Sacrifice, worker collision and staging, purple attacks, gathering restored after ownership handoffs, checkpoint reconstruction, lifecycle and camera guards.')
