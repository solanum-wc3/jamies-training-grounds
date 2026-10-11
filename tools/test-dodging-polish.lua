-- Run after the Dodging lifecycle and phases, before real-controller tests.
local screen,oldBriefing,oldSession= nil,JTG.UI.ShowActivityBriefing,JTG.Controller.session
JTG.UI.ShowActivityBriefing=function(spec) screen=spec end;JTG.Controller.session=nil
local indices={}
for i,d in ipairs(JTG.DodgeDangers) do if d.menuGroup=='Devour' or d.menuGroup=='Area' then indices[d.menuGroup]=i end end
JTG.OpenMissileDodgingMenu('skills',false,'how',{dangerIndex=indices.Devour})
assert(screen.title=='Dodging' and not screen.titleSuffix)
assert(screen.body:find('Try to avoid being devoured for 15 seconds!',1,true))
assert(screen.body:find('\n\nChoosing abilities turns this exercise into a timing training instead.',1,true))
screen.choices[2].action()
local potionIndex
for _,choice in ipairs(screen.choices) do
    if choice.label=='Potion of Invulnerability' then assert(choice.enabled) end
    if choice.label=='Cloak of Shadows' or choice.label=='Anti-Magic Potion' or choice.label=='Potion of Invisibility' then
        assert(not choice.enabled and choice.tooltip=='This ability does not protect against Devour.')
    end
end
local columns={}
for _,choice in ipairs(screen.choices) do columns[choice.column]=true end
for _,gap in ipairs({6,9,11}) do assert(not columns[gap],'Group spacing must contain an empty column') end
JTG.OpenMissileDodgingMenu('skills',false,'area')
assert(screen.contentDividerY>-0.17 and not screen.titleSuffix)
local raceColumns={}
for _,choice in ipairs(screen.choices) do
    local race=JTG.DodgeDangers[(function()
        for i,d in ipairs(JTG.DodgeDangers) do if d.name==choice.label and d.menuGroup=='Area' then return i end end
    end)()].race
    assert(not raceColumns[race] or raceColumns[race]==choice.column)
    raceColumns[race]=choice.column
end
local oldPath,oldCollision,oldAbility,oldField,oldImage,oldLevel=
    IsTerrainPathable,BlzGetUnitCollisionSize,BlzGetUnitAbility,BlzGetAbilityRealLevelField,SetImagePosition,SetUnitAbilityLevel
local oldPosition,oldUnitPathing=SetUnitPosition,SetUnitPathing
function SetUnitPathing(unit,enabled) unit.pathing=enabled end
function SetUnitPosition(unit,x,y)
    -- Emulate native collision displacement if exact placement is not used.
    unit.x=x+((unit.id=='egol' or unit.id=='otrb') and unit.pathing~=false and 64 or 0)
    unit.y=y
end
function BlzGetUnitCollisionSize(unit) return unit.id=='egol' and 50 or 16 end
function IsTerrainPathable(_,y) return y>-160 end
local function session(state) return {restartData=state,scope={},presentationScope={},scene={centerX=0,centerY=0},descriptor={capabilities={}}} end
local a=JTG.CreateMissileDodgingActivity(session({dangerIndex=indices.Devour,movementUnit={unit='hfoo'}}))
local wisp,mine={id='ewsp',x=0,y=0},{id='egol',x=0,y=0}
a:placeBelowBuilding(wisp,mine,256)
assert(wisp.x==mine.x and wisp.y==0 and mine.y==288 and wisp.facing==90)
assert(mine.facing==270 and mine.pathing==true)
a:placeBelowBuilding(wisp,mine,256,128)
assert(wisp.y==0 and mine.y==160,'Wisp mine must move two building squares south')
-- Even when ground terrain reports clear, the flying Wisp must remain below
-- the mine's visual/pathing footprint, at the original missile-target position.
function IsTerrainPathable() return false end
local peon,burrow={id='opeo',x=100,y=200},{id='otrb',x=36,y=200}
a:placeBelowBuilding(peon,burrow,96)
assert(peon.x==100 and peon.y==200 and burrow.x==100 and burrow.y==328)
local wispIndex
for i,p in ipairs(JTG.DodgePawns) do if p.mine then wispIndex=i;break end end
local wispSession=session({dangerIndex=1,pawnIndex=wispIndex})
local wispSetup=JTG.CreateMissileDodgingActivity(wispSession);wispSetup:setup(wispSession)
local spawnedMine
for _,unit in ipairs(wispSetup.supports) do if unit.id=='egol' then spawnedMine=unit end end
assert(spawnedMine and spawnedMine.y==wispSetup.pawn.y+32)
assert(spawnedMine.x==wispSetup.pawn.x-160 and spawnedMine.facing==270 and spawnedMine.pathing==true)
assert(wispSetup.pawn.y==wispSetup.caster.y and wispSetup.pawn.y==0,
    'Worker target must stay at scene height, aligned with the missile caster')
for i=#wispSession.scope,1,-1 do wispSession.scope[i]() end
for i,p in ipairs(JTG.DodgePawns) do if p.item=='pnvu' then potionIndex=i end end
local potionSession=session({dangerIndex=indices.Devour,pawnIndex=potionIndex})
local potion=JTG.CreateMissileDodgingActivity(potionSession);potion:setup(potionSession)
assert(potion.pawn.id=='hfoo' and potion.definition.item=='pnvu')
assert(JTG.DodgePawns[potionIndex].unit=='Ntin','Devour item bearer must not change other exercises')
for i=#potionSession.scope,1,-1 do potionSession.scope[i]() end
-- Final five seconds: one same-owner TC outside the arena, level-one aura.
a.caster={id='okod',owner=1,x=0,y=0};a.target={id='hfoo',owner=0,x=200,y=0};a.pawn=a.target
a.devourRadius=150;a.trialTime=9.96
local auraLevel
function SetUnitAbilityLevel(_,ability,level) if ability=='AOae' then auraLevel=level end end
a:updateTrial()
assert(a.devourAuraHero and a.devourAuraHero.owner==1 and a.devourAuraHero.y>a.arenaHalf and auraLevel==1)
local hero=a.devourAuraHero;a:updateTrial();assert(a.devourAuraHero==hero)
-- Red AoE ring reads the live radius, without halving it or adding collision.
function BlzGetUnitAbility() return {} end
function BlzGetAbilityRealLevelField(_,field) return field==ABILITY_RLF_AREA_OF_EFFECT and 375 or 0 end
function SetImagePosition(image,x,y) image.x=x;image.y=y end
for i,d in ipairs(JTG.DodgeDangers) do if d.ability=='AHtc' or d.ability=='AOws' then
    local radial=JTG.CreateMissileDodgingActivity(session({dangerIndex=i}))
    radial.caster={id=d.unit,x=100,y=200};radial.devourImages={{}}
    radial:updateAreaPresentation()
    assert(radial.devourImages[1].x==100+375-8 and radial.devourImages[1].y==200-8)
end end
IsTerrainPathable,BlzGetUnitCollisionSize,BlzGetUnitAbility,BlzGetAbilityRealLevelField,SetImagePosition,SetUnitAbilityLevel=
    oldPath,oldCollision,oldAbility,oldField,oldImage,oldLevel
SetUnitPosition,SetUnitPathing=oldPosition,oldUnitPathing
JTG.UI.ShowActivityBriefing,JTG.Controller.session=oldBriefing,oldSession
print('Passed: Devour potion eligibility/bearer, exact briefing, shared picker gaps, one-column Area races, southern building entry, final-five-second TC aura and live full-radius Clap/Stomp circles.')
