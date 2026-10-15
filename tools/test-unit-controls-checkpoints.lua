-- Use after test-camera-welcome-arrow.lua for presentation-only native mocks.
local units={}
function JTG.CreateScope() return {disposed=false} end
function JTG.DisposeScope(scope) scope.disposed=true end
bj_PI=math.pi;bj_RADTODEG=180/math.pi
Cos=math.cos;Sin=math.sin
function CreateUnit(owner,raw,x,y,facing)
 local u={owner=owner,raw=raw,x=x,y=y,facing=facing};units[#units+1]=u;return u
end
function GetUnitTypeId(u) return u and not u.removed and u.raw or 0 end
function GetWidgetLife(u) return u.life or 100 end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function RemoveUnit(u) u.removed=true end
function SetUnitOwner(u,owner) u.owner=owner end
function IssuePointOrder(u,order) u.order=order;return true end
function IssueImmediateOrder(u,order) u.order=order;return true end
function JTG.ScopeTrackUnit(_,u) return u end
function JTG.CreateScopedUnit(scope,...) return JTG.ScopeTrackUnit(scope,CreateUnit(...)) end
function JTG.StartScopedTimer() return {} end
function BlzGetUnitMaxMana() return 100 end
JTG.Scenes={['arena.north']={minX=-1000,maxY=2000}}
local a=JTG.CreateUnitControlsTutorialActivity({scope={},scene={centerX=0,centerY=0,minX=-1000,minY=-1000,maxX=1000,maxY=1000}})
a.frames={continue={},back={},pause={}}
local function step(id)
 for i,spec in ipairs(a.tutorialSpec.steps) do if spec.id==id then return i end end
 error('Missing step '..id)
end
for _,id in ipairs({'controls.038','controls.039','controls.040','controls.041','controls.042','controls.043','controls.044','controls.039','controls.039'}) do
 local index=step(id)
 a:restoreCheckpoint(index)
 assert(a.siegeEngine and GetUnitTypeId(a.siegeEngine)=='hmtt','Missing siege engine at '..index)
 local engines,peasants=0,0
 for _,u in ipairs(units) do
  if not u.removed then
   if u.raw=='hmtt' then engines=engines+1 end
   if u.raw=='hpea' then peasants=peasants+1 end
  end
 end
 assert(engines==1 and peasants==(index>=step("controls.039") and 1 or 0),'Duplicate movement props at '..index)
end
local engine,peasant=a.siegeEngine,a.formationPeasant
a:giveSiegeAndPeasant()
assert(a.siegeEngine==engine and a.formationPeasant==peasant)
a:restoreCheckpoint(step("controls.036"))
assert(GetUnitTypeId(engine)==0 and GetUnitTypeId(peasant)==0)
print('Passed: Unit Controls checkpoint reconstruction, optional return props and duplicate prevention.')

local oldFootman=a.units[1]
oldFootman.life=0
local oldPriest=a.unitGroups.priests[1]
RemoveUnit(oldPriest)
a:restoreCheckpoint(2)
assert(a.units[1]~=oldFootman and a.unitGroups.footmen[1]==a.units[1] and oldFootman.removed)
assert(a.unitGroups.priests[1]~=oldPriest and GetUnitTypeId(a.unitGroups.priests[1])=='hmpr')
local caster=CreateUnit(1,'Ofar',0,0)
a.wolfCasterVisits={[caster]=a.tutorialEntry};a.wolfSummoners={caster}
local wolf=CreateUnit(1,'osw1',0,0)
a:trackWolfSummon(caster,wolf)
assert(#a.wolves==1 and wolf.order=='attack')
a:restoreCheckpoint(2)
assert(wolf.removed and caster.removed)
local late=CreateUnit(1,'osw1',0,0)
a:trackWolfSummon(caster,late);assert(late.removed,'Late old summon survived a scene reset')
local unrelated=CreateUnit(1,'osw1',0,0)
a:trackWolfSummon({},unrelated);assert(not unrelated.removed,'Reset removed an unrelated summon')
assert(a:captureResetState().stepId=='controls.002')
a:restoreCheckpoint(step("controls.068"));assert(a.complete and not a.waitingForContinue)
a:goBack();assert(a.step==step("controls.067") and not a.complete,'Back is stuck on completed narration')
a.combatAutocast=false
a:restoreCheckpoint(step("controls.051"))
assert(a.unitGroups.priests[1].order=='healon' and a.unitGroups.priests[2].order=='healon',
    'Combat scene replay retained autocast settings from a previous chapter')
print('Passed: Unit Controls recreates dead/missing actors and cleans up immediate and late summons across checkpoint resets.')

local add=step('controls.011')
assert(a.tutorialSpec.steps[add].wait and not table.concat(a.tutorialSpec.steps[add].lines):find('Alternatively',1,true))
assert(a.tutorialSpec.steps[add+1].id=='controls.add-alternative' and a.tutorialSpec.steps[add+1].wait)
a.frames.arrow={}
local originalSize,originalPoint=BlzFrameSetSize,BlzFrameSetPoint
function BlzFrameSetSize(frame,w,h) frame.width=w;frame.height=h end
function BlzFrameSetPoint(frame,_,_,_,x,y) frame.x=x;frame.y=y end
function BlzGetOriginFrame() return {} end
function BlzGetFrameByName() return {} end
for _,kind in ipairs({'portrait','info','inventory','commands'}) do
 a:showInterfaceArrow(kind)
 assert(a.frames.arrow.width==.068 and a.frames.arrow.height==.068,'Interface arrows have inconsistent sizes')
 if kind=='portrait' then assert(a.frames.arrow.x==.004,'Portrait arrow did not move left by .006') end
end
BlzFrameSetSize,BlzFrameSetPoint=originalSize,originalPoint
print('Passed: separate Control Group narration stops and uniformly sized interface arrows.')
