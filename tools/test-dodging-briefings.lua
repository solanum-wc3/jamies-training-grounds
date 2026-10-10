-- Run after the Dodging revision checks, before the shared-controller checks.
local screen
JTG.UI.ShowActivityBriefing=function(spec) screen=spec end
local savedSession=JTG.Controller.session
JTG.Controller.session=nil
JTG.OpenMissileDodgingMenu('skills',false)
assert(screen.body:find('It is possible to dodge and evade many attacks and abilities.',1,true))
screen.choices[1].action()
assert(screen.body:find('Do disjoin a projectile',1,true))
screen.choices[1].action()
assert(screen.body:find("All but the Raider's Ensnare ability are spells.",1,true))
local indices={}
for i,d in ipairs(JTG.DodgeDangers) do indices[d.menuGroup]=i end
for group,page in pairs({Homing='homing',Ranged='ranged_races',Area='area',Devour='how'}) do
    JTG.Controller.session={id='skills.missile_dodging',activity={dangerIndex=indices[group],pawnIndex=1}}
    JTG.OpenMissileDodgingMenu('skills',true)
    assert(screen.pageId==page and screen.resumeAction and screen.exitAction,group)
    if group=='Ranged' then
        local body=screen.body; screen.choices[1].action(); assert(screen.body==body)
    end
    -- Explicit restoration must take precedence over the toolbar default.
    JTG.OpenMissileDodgingMenu('skills',true,'root')
    assert(screen.pageId=='root')
end
JTG.Controller.session=nil
JTG.OpenMissileDodgingMenu('skills',false)
screen.choices[2].action()
assert(screen.body:find('{Gold Font: Kodo Beast}',1,true))
screen.choices[1].action()
assert(screen.pageId=='area_intro' and screen.body:find('15 seconds',1,true))
screen.choices[1].action(); assert(screen.pageId=='area')
screen.backAction(); assert(screen.pageId=='area_intro')

local function current()
    return {restartData={dangerIndex=indices.Area,pawnIndex=1},scope={},presentationScope={},
        scene={centerX=0,centerY=0},descriptor={capabilities={}}}
end
local result,toolbar
JTG.UI.ShowResultCard=function(_,spec) result=spec end
JTG.UI.HideToolbar=function() toolbar=false end
JTG.UI.ShowToolbar=function() toolbar=true end
local activity=JTG.CreateMissileDodgingActivity(current())
activity.caster={id='caster',x=0,y=0}; activity.target={id='pawn',x=100,y=0}
activity.trialTime=14.96; activity:updateTrial()
assert(activity.finished and not activity.areaHit and result.tone=='success')
assert(not toolbar and result.actions.next==nil)
activity:hidePresentationForMenu(); activity:restorePresentation()
assert(result.tone=='success' and not toolbar)
activity=JTG.CreateMissileDodgingActivity(current())
activity.caster={id='caster',x=0,y=0}; activity.target={id='pawn',x=100,y=0}
activity:resetAfterHit()
assert(activity.finished and activity.areaHit and result.tone=='failure')
activity:hidePresentationForMenu(); activity:restorePresentation()
assert(result.tone=='failure' and not toolbar)
JTG.Controller.session=savedSession
print('Passed: briefing text, four toolbar menu destinations, explicit saved-page restoration, Area intro navigation and 15-second success/hit failure cards.')
