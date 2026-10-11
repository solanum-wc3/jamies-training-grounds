-- Run after Dodging phases: scheduling and overlays, not native spell collision.
local indices={}
for index,danger in ipairs(JTG.DodgeDangers) do
    if danger.menuGroup=='Area' then indices[danger.ability]=index end
end
local function create(raw)
    local session={restartData={dangerIndex=indices[raw],pawnIndex=1},scope={},presentationScope={},
        scene={centerX=0,centerY=0},descriptor={capabilities={}}}
    local activity=JTG.CreateMissileDodgingActivity(session)
    activity.caster={id=activity.danger.unit,x=0,y=0};activity.target={id='hfoo',x=500,y=0}
    return activity
end
local oldRandom,oldPoint,oldItem,oldAdd,oldPosition,oldShow=
    GetRandomReal,IssuePointOrder,UnitAddItemById,JTG.ScopeAdd,SetImagePosition,ShowImage
local orders,items,cleanups={},{},{}
function GetRandomReal(low,high)
    assert((low==2 and high==2.5) or (low==0.5 and high==1))
    return (low+high)/2
end
function IssuePointOrder(unit,order,x,y) orders[#orders+1]={order=order,x=x,y=y};return true end
function UnitAddItemById(unit,raw) items[#items+1]=raw;return {id=raw} end
JTG.ScopeAdd=function(_,callback) cleanups[#cleanups+1]=callback end
function SetImagePosition(image,x,y) image.x=x;image.y=y end
function ShowImage(image,visible) image.visible=visible end
local a=create('AOsh')
a:updateAreaOrders()
assert(a.circular and a.areaDirectional and a.arenaHalf==a.danger.waveDistance)
assert(orders[#orders].order=='shockwave' and a.areaCastAt==2.25 and a.areaMoveAt==0.75)
a.trialTime=0.75;a:updateAreaOrders();assert(orders[#orders].order=='move')
a.casting=true;a.trialTime=1.5;local count=#orders;a:updateAreaOrders();assert(#orders==count)
a.casting=false;a.trialTime=5;a:updateAreaOrders();assert(a.arenaHalf==a.arenaMaximum*0.8)
a.trialTime=10;a:updateAreaOrders();assert(a.arenaHalf==a.arenaMaximum*0.6 and #items==0)
assert(a.caster.x==0 and a.caster.y==0)
a.target.x=900;a.target.y=900;a.trialTime=13;a:updateAreaOrders()
local aim=orders[#orders]
assert(aim.order=='shockwave' and math.abs(aim.x-aim.y)<0.01)
assert(math.sqrt(aim.x*aim.x+aim.y*aim.y)<a.danger.range,
    'Beyond-range target must produce a valid point order in its direction')
-- A travelling marker follows the cast direction; hiding/resuming includes it.
a.devourImages={{}};a.arenaImages={{}};a.areaFootprintImages={{}}
a:showAreaFootprint(500,0)
a.trialTime=a.trialTime+0.2;a:updateAreaPresentation()
assert(a.areaFootprintImages[1].x>100 and a.areaFootprintImages[1].visible)
a:hidePresentationForMenu()
assert(not a.devourImages[1].visible and not a.arenaImages[1].visible and not a.areaFootprintImages[1].visible)
a:restorePresentation();assert(a.devourImages[1].visible and a.areaFootprintImages[1].visible)
a.trialTime=a.trialTime+2;a:updateAreaPresentation();assert(not a.areaFootprintImages[1].visible)
-- Radial heroes pursue until half-radius, then cast; boots appear once at 10s.
orders={};local b=create('AHtc')
b:updateAreaOrders();assert(orders[#orders].order=='move')
b.target.x=b.danger.area*0.5;b.trialTime=0.1;b:updateAreaOrders()
assert(b.attempts==1)
b.trialTime=9.99;b:updateAreaOrders();assert(#items==0)
b.trialTime=10;b:updateAreaOrders();assert(items[1]=='bspd' and #cleanups==1)
b.trialTime=10.5;b:updateAreaOrders();assert(#items==1)
local c=create('AOws');c.trialTime=10;c:updateAreaOrders();assert(items[2]=='bspd')
-- Timed casts use the whole AoE; crossing half range may fire early once.
local timed=create('AHtc')
timed.target.x=timed.danger.area*0.75
timed:updateAreaOrders();assert(timed.attempts==1 and timed.areaCastAt==2.25)
timed.trialTime=1;timed:updateAreaOrders();assert(timed.attempts==1)
timed.trialTime=2.25;timed:updateAreaOrders();assert(timed.attempts==2)
timed.target.x=timed.danger.area*0.5;timed.trialTime=2.3
timed:updateAreaOrders();assert(timed.attempts==3 and math.abs(timed.areaCastAt-4.55)<0.00001)
timed.trialTime=2.35;timed:updateAreaOrders();assert(timed.attempts==3)

-- Native hit observations relocate Chain Lightning's footprint per bounce.
local chain=create('AOcl')
chain.areaFootprintImages={{}}
local firstHit={id='hfoo',x=420,y=120}
local nextHit={id='hfoo',x=560,y=-80}
chain:chainLightningHit(firstHit)
assert(chain.areaFootprint.followUnit==firstHit and chain.areaFootprint.x==420)
chain:chainLightningHit(nextHit)
assert(chain.areaFootprint.followUnit==nextHit and chain.areaFootprint.x==560 and chain.areaFootprint.y==-80)
nextHit.x=600;chain:updateAreaPresentation();assert(chain.areaFootprint.x==600)
-- Helpers use their normal movement speed and hold position upon arrival.
local oldImmediate=IssueImmediateOrder
local holds={}
function IssueImmediateOrder(unit,order) holds[#holds+1]={unit=unit,order=order};return true end
chain.chainTargets={firstHit,nextHit,{id='hfoo',x=500,y=0}}
orders={};chain:updateChainCompanions(0.49);assert(#orders==0,'Footmen reacted before random delay')
chain:updateChainCompanions(0.51);assert(#orders>0)
local moving=chain.chainMoving[1]
firstHit.x,firstHit.y=moving.x,moving.y
chain:updateChainCompanions(1);assert(holds[#holds].unit==firstHit and holds[#holds].order=='holdposition')
chain.target.x=800;chain:updateChainCompanions(1);assert(chain.chainMoving[1].x==800)
IssueImmediateOrder=oldImmediate

GetRandomReal,IssuePointOrder,UnitAddItemById,JTG.ScopeAdd,SetImagePosition,ShowImage=
    oldRandom,oldPoint,oldItem,oldAdd,oldPosition,oldShow
print('Passed: Area circular arenas, shrinking stages, random casting/feints, windup protection, moving overlays, menu visibility, half-radius pursuit and scoped Boots of Speed at ten seconds.')
