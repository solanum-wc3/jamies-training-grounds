local f=assert(io.open('src/activities/windwalk-pop.lua'));local source=f:read('*a');f:close()
local creations={}
JTG={ScopeTrackUnit=function(_,u) return u end}
function Player(i) return i end
function GetLocalPlayer() return 0 end
function ClearSelection() end
function SelectUnit() end
function BlzCreateUnitWithSkin(owner,raw,x,y)
 local u={owner=owner,raw=raw,x=x,y=y};creations[#creations+1]=u;return u
end
function SetHeroLevel() end
function IssueImmediateOrder() end
function BlzGetUnitCollisionSize() return 16 end
function SetUnitX(u,x) u.x=x end
function SetUnitY(u,y) u.y=y end
function BlzSetUnitMaxHP() end
function SetUnitState() end
function UnitRemoveAbility() end
function FourCC(s) return s end
function UnitAddItemById() end
local activity={}
function activity:createBlademaster(owner,x,y)
 self.blademaster=BlzCreateUnitWithSkin(owner,'Obla',x,y)
end
local a=assert(source:find('    function activity:createTimedScenario(',1,true))
local b=assert(source:find('    function activity:createCourseArmy(',a,true))
local ids={'ogru','ogru','ohun','ohun','orai','okod','ospw','otau','Oshd','Otch'}
local layouts={}
for stage=1,10 do layouts[stage]={{stage,0}} end
assert(load('return function(activity,session,TIMED_LAYOUT_ROWS,TIMED_TARGET_IDS)\nlocal SHADOW_HUNTER_ID="Oshd";local TAUREN_CHIEFTAIN_ID="Otch";local FOOTMAN_ID="hfoo"\n'..source:sub(a,b-1)..'\nend'))()(activity,{scope={}},layouts,ids)
for stage=1,10 do
 creations={};activity.timedStage=stage;activity:createTimedScenario(100,200)
 local heroes={}
 for _,u in ipairs(creations) do if u.owner==0 and (u.raw=='Obla' or u.raw=='Oshd' or u.raw=='Otch') then heroes[#heroes+1]=u.raw end end
 assert(heroes[1]=='Obla')
 if stage>=9 then assert(heroes[2]=='Oshd') end
 if stage==10 then assert(heroes[3]=='Otch') end
 local target=activity.timedTargets[1]
 assert(activity.blademaster.x==target.x-360 and activity.blademaster.y==target.y-240,'BM position changed')
end
a=assert(source:find('    function activity:createScenario()',1,true))
b=assert(source:find('\n    function activity:',a+10,true))
function activity:createCourseArmy() end
assert(load('return function(activity,session)\nlocal TAUREN_CHIEFTAIN_ID="Otch";local function PrepareHero() end\n'..source:sub(a,b-1)..'\nend'))()(activity,{scope={},scene={centerX=100,centerY=200}})
creations={};activity.mode='hard';activity:createScenario()
assert(creations[1].raw=='Obla' and creations[2].raw=='Otch')
print('Passed: Windwalk Pop preserves BM/SH/TC hero order across all timed stages and BM/TC in Hard mode.')
