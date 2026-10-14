local f=assert(io.open('src/activities/camera-tutorial.lua'));local source=f:read('*a');f:close()
JTG={Tutorial={}}
function FourCC(s) return s end
function JTG.ScopeTrackUnit(scope,u) if scope.units then scope.units[#scope.units+1]=u end;return u end
function JTG.CreateScope() return {units={},disposed=false} end
function JTG.DisposeScope(scope) scope.disposed=true;for _,u in ipairs(scope.units) do u.removed=true end end
function CreateUnit(_,raw,x,y) return {raw=raw,x=x+32,y=y-32,life=100} end
function SetUnitPathing(u,v) u.pathing=v end
function JTG.Tutorial.CreateSceneUnit(_,_,raw,x,y) return {raw=raw,x=x,y=y} end
function JTG.Tutorial.CreateMobileUnit(scope,owner,raw,x,y,facing)
 local unit=JTG.ScopeTrackUnit(scope,CreateUnit(owner,raw,x,y,facing));SetUnitPathing(unit,true);return unit
end
function GetUnitAbilityLevel() return 0 end
function UnitAddAbility(u,a) u.ability=a end
function UnitMakeAbilityPermanent(u,v) u.permanent=v end
local a=assert(source:find('local function CreateBaseUnit(',1,true))
local b=assert(source:find('local function RawcodeToString',a,true))
local create=assert(load(source:sub(a,b-1)..'\nreturn CreateBaseUnit'))()
local peon=create({},0,'opeo',100,200,0)
assert(peon.x==132 and peon.y==168 and peon.pathing,'Peon native placement was overwritten')
local mill=create({},0,'ofor',100,200,0)
assert(mill.x==100 and mill.y==200)
function GetUnitTypeId(u) return not u.removed and u.raw or 0 end
function GetWidgetLife(u) return u.life end
function KillUnit(u) u.life=0 end
function IssueTargetOrder(u,o,t) u.order=o;u.target=t end
function IssueImmediateOrder(u,o) u.order=o end
function GetHandleId(u) return u end
function BlzGetUnitMaxHP() return 100 end
function SetUnitState(u,_,v) u.life=v end
function Player(i) return i end
function UnitDamageTarget(_,u,v) u.life=u.life-v end
local retire={}
function JTG.StartScopedTimer(_,_,_,_,cb) retire[#retire+1]=cb end
dofile('src/infrastructure/tutorial.lua')
local towers={{raw='owtw',life=25},{raw='owtw',life=40}}
local worker={raw='opeo',life=100};local tree={}
local activity={workerActivities={[worker]={targetKind='destructable',targetX=1,targetY=2}},pending={},entry=1}
function activity:findOwnedUnit(_,x) return x>0 and towers[1] or towers[2] end
function activity:findNearestLumberPeons() return {worker} end
function activity:findDestructable() return tree end
function activity:schedule(_,cb)
 local entry=self.entry
 self.pending[#self.pending+1]=function() if self.entry==entry then cb() end end
end
a=assert(source:find('    function activity:stopNotificationAttack()',1,true))
b=assert(source:find('    function activity:prepareNotificationGhoul()',a,true))
assert(load('return function(activity,session)\n'..source:sub(a,b-1)..'\nend'))()(activity,{scope={}})
activity:startNotificationAttack()
local old=activity.demoGhouls
assert(#old==2 and towers[1].life==100 and towers[2].life==100)
activity.pending[3]() -- Start repairing in the original entry.
assert(worker.order=='repair')
activity:stopNotificationAttack();activity.entry=2
assert(old[1].life==0 and old[2].life==0 and worker.order=='harvest' and worker.target==tree)
activity:startNotificationAttack();local fresh=activity.demoGhouls
activity.pending[1]();activity.pending[2]();activity.pending[3]();retire[1]()
assert(fresh[1].life==100 and fresh[2].life==100,'Old attack callbacks affected a revisit')
activity:stopNotificationAttack()
assert(fresh[1].life==0 and fresh[2].life==0)
print('Passed: Camera retains native worker placement, restores lumber drop-off and rebuilds attack scenes safely.')
