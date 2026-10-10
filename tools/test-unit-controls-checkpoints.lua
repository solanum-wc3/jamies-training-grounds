-- Use after test-camera-welcome-arrow.lua for presentation-only native mocks.
local units={}
bj_PI=math.pi;bj_RADTODEG=180/math.pi
Cos=math.cos;Sin=math.sin
function CreateUnit(owner,raw,x,y,facing)
 local u={owner=owner,raw=raw,x=x,y=y,facing=facing};units[#units+1]=u;return u
end
function GetUnitTypeId(u) return u and not u.removed and u.raw or 0 end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function RemoveUnit(u) u.removed=true end
function SetUnitOwner(u,owner) u.owner=owner end
function IssuePointOrder(u,order) u.order=order;return true end
function IssueImmediateOrder(u,order) u.order=order;return true end
function JTG.ScopeTrackUnit(_,u) return u end
function JTG.StartScopedTimer() return {} end
function BlzGetUnitMaxMana() return 100 end
local a=JTG.CreateUnitControlsTutorialActivity({scope={},scene={centerX=0,centerY=0}})
a.frames={continue={},back={},pause={}}
for _,index in ipairs({38,39,40,41,42,43,44,39,39}) do
 a:restoreCheckpoint(index)
 assert(a.siegeEngine and GetUnitTypeId(a.siegeEngine)=='hmtt','Missing siege engine at '..index)
 local engines,peasants=0,0
 for _,u in ipairs(units) do
  if not u.removed then
   if u.raw=='hmtt' then engines=engines+1 end
   if u.raw=='hpea' then peasants=peasants+1 end
  end
 end
 assert(engines==1 and peasants==(index>=39 and 1 or 0),'Duplicate movement props at '..index)
end
local engine,peasant=a.siegeEngine,a.formationPeasant
a:giveSiegeAndPeasant()
assert(a.siegeEngine==engine and a.formationPeasant==peasant)
a:restoreCheckpoint(36)
assert(GetUnitTypeId(engine)==0 and GetUnitTypeId(peasant)==0)
print('Passed: Unit Controls checkpoint reconstruction, optional return props and duplicate prevention.')
