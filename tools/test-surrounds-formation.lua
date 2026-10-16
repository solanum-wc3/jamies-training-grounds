-- Isolated formation and shared success-copy checks.
JTG={UI={HideToolbar=function() end}}
setmetatable(_G,{__index=function(_,name)
    if name:match('^[A-Z][A-Z0-9_]+$') then return name end
    return function() end
end})
function Player(id) return id end
function FourCC(raw) return raw end
function GetLocalPlayer() return 0 end
function IsUnitType() return false end
function BlzCreateUnitWithSkin(owner,raw,x,y) return {raw=raw,x=x,y=y} end
function JTG.ScopeTrackUnit(_,unit) return unit end
function JTG.CreateScopedUnit(scope,...) return JTG.ScopeTrackUnit(scope,CreateUnit(...)) end
function JTG.StartScopedTimer() return {} end
dofile('src/activities/surrounds.lua')
local session={scope={},restartData={race='undead',setupIndex=2,runnerIndex=2}}
local normal=JTG.CreateSurroundsActivity(session)
normal.finishX,normal.laneY=1000,500
normal:spawnArmy()
assert(#normal.army==6 and normal.army[1].raw=='Ucrl')
assert(math.abs(normal.army[1].x-1095)<0.01 and normal.army[1].y>500,'Crypt Lord did not move to side slot')
assert(normal.army[2].raw=='ugho' and normal.army[2].x==1190 and normal.army[2].y==500,'Ghoul did not take forward slot')
local gargoyle=JTG.CreateGargoyleSurroundActivity(session)
gargoyle.finishX,gargoyle.laneY=1000,500
gargoyle:spawnArmy()
assert(gargoyle.army[1].raw=='Ucrl' and gargoyle.army[1].x==1190,'Standard swap leaked into Gargoyle formation')
gargoyle.runner={}
gargoyle.setSetupsOpen=function() end
gargoyle.renderResultPresentation=function() end
gargoyle:finish(true)
assert(gargoyle.resultDetailsText=='The Grunt and Demon Hunter were surrounded with this setup.')
print('Passed: Crypt Lord/side-Ghoul formation swap, unchanged Gargoyle formation and explicit two-runner end-card copy.')

-- Exercise the actual custom spawn path, including native-like skill points
-- and rank requirements. An unconfigured hero retains its first free point.
function BlzCreateUnitWithSkin(owner,raw,x,y)
 return {owner=owner,raw=raw,x=x,y=y,level=1,points=1,skills={}}
end
function GetUnitTypeId(u)return u.raw end
function IsUnitType(u,kind)return kind==UNIT_TYPE_HERO and u.raw:match('^[A-Z]')~=nil end
function GetHeroLevel(u)return u.level end
function SetHeroLevel(u,level)
 assert(level>u.level,'Fresh level-1 hero received redundant level change')
 u.points=u.points+level-u.level;u.level=level
end
function GetUnitAbilityLevel(u,raw)return u.skills[raw] or 0 end
function SelectHeroSkill(u,raw)
 local rank=(u.skills[raw] or 0)+1
 local required=raw=='AHmt' and 6 or 2*rank-1
 assert(u.level>=required and u.points>0,'Illegal selected hero skill')
 u.skills[raw]=rank;u.points=u.points-1
end
local function custom(abilities)
 local run=JTG.CreateSurroundsActivity({scope={},restartData={race='custom',customArmy={{'Hamg',1,abilities},{'hfoo',3}}}})
 run.finishX,run.laneY=1000,500;run:spawnArmy();return run.army[1]
end
local empty=custom({});assert(empty.level==1 and empty.points==1 and next(empty.skills)==nil)
local three=custom({'AHwe','AHwe','AHwe'});assert(three.level==5 and three.points==2 and three.skills.AHwe==3)
local ultimate=custom({'AHmt'});assert(ultimate.level==6 and ultimate.points==5)
local combined=custom({'AHwe','AHwe','AHwe','AHbz','AHbz','AHbz'})
assert(combined.level==6 and combined.points==0)
JTG.Controller={lastCategory='skills'}
local stopped,briefing
function JTG.StopActivity(reason)stopped=reason end
function JTG.OpenSurroundsMenu(category,paused)briefing=category;assert(paused==false)end
normal.resultAction='finish';normal.resultActions.next(normal)
assert(stopped=='surround-finish' and briefing=='skills','Finish did not open the Surrounds briefing')
print('Passed: custom hero legal ranks/minimum levels/free points and Finish-to-briefing navigation.')
