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
