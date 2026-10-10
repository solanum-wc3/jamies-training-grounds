-- Run after the training order/lifecycle/revision and Bat Splitting tests.
-- Uses native mocks for navigation, then the real shared controller and scopes.
local screen, toolbar, result, exited, resumed
JTG.UI.ShowActivityBriefing=function(spec) screen=spec end
JTG.UI.ShowCategory=function(category) assert(category=='skills') end
JTG.UI.ShowToolbar=function() toolbar=true end
JTG.UI.HideToolbar=function() toolbar=false end
JTG.UI.ShowResultCard=function(_,spec) result=spec end
JTG.UI.HideActivityBriefing=function() end
JTG.ResumeActivity=function() resumed=true end
JTG.StopActivity=function() exited=true end
JTG.Controller.session=nil
local function restorePage(opener)
    local before=screen
    assert(before.pageId and before.originCategory=='skills' and before.restoreData)
    local saved={}
    for k,v in pairs(before.restoreData) do saved[k]=v end
    opener('skills',false,before.pageId,saved)
    assert(screen.pageId==before.pageId and screen.body==before.body)
    assert(#screen.choices==#before.choices)
    for i,choice in ipairs(before.choices) do
        assert(screen.choices[i].label==choice.label and screen.choices[i].enabled==choice.enabled)
    end
end
local function choose(label)
    for _,choice in ipairs(screen.choices) do
        if choice.label==label then assert(choice.enabled~=false); choice.action(); return end
    end
    error('Missing choice: '..label)
end
JTG.OpenBatSplittingMenu('skills',true)
assert(screen.resumeAction and screen.exitAction)
assert(screen.pageId=='root' and #screen.choices==2 and screen.resumeAction and screen.exitAction)
screen.resumeAction(); assert(resumed)
screen.exitAction(); assert(exited and screen.pageId=='root' and not screen.resumeAction)
screen.backAction()
JTG.OpenBatSplittingMenu('skills',false);restorePage(JTG.OpenBatSplittingMenu)

local open=JTG.OpenMissileDodgingMenu
open('skills',false); restorePage(open)
choose('Disjoining'); restorePage(open); choose('Abilities'); restorePage(open)
choose('Storm Bolt'); restorePage(open)
choose('Blademaster'); restorePage(open)
screen.backAction(); assert(screen.pageId=='homing')
open('skills',false); choose('Disjoining'); choose('Attacks'); restorePage(open)
choose('Human'); restorePage(open)
choose('Gryphon Rider'); restorePage(open)
screen.backAction(); assert(screen.pageId=='ranged_units')
open('skills',false,'artillery'); restorePage(open)
choose('Mortar Team'); restorePage(open)
choose('Movement'); restorePage(open)
choose('Orc'); restorePage(open)
choose('Footman'); restorePage(open)
screen.backAction(); assert(screen.pageId=='movement_units')
open('skills',false); choose('Avoiding'); restorePage(open); choose('Area'); restorePage(open)
choose('Start Training'); restorePage(open)
screen.choices[1].action(); restorePage(open)
choose('Ability'); restorePage(open)
open('skills',false); choose('Avoiding'); choose('Devour (Kodo)'); restorePage(open)
assert(screen.pageId=='how')
print('Passed: all configuration pages restore choices, Back returns to the previous selector, and Bat Splitting uses Resume/Exit on both pages.')

-- Replace earlier test scope stubs with the actual controller implementation.
dofile('src/infrastructure/core.lua')
JTG.Registry={byId={}}
JTG.Scenes={test={centerX=100,centerY=200,minX=-800,minY=-800,maxX=800,maxY=800}}
JTG.BorrowCamera=function() end
JTG.ResetWorldFog=function() end
JTG.ScopeRevealScene=function() end
JTG.UI.SetGameplayMenuPaused=function() end
JTG.UI.SetExercisePaused=function() end
JTG.UI.SetQuestAvailable=function() end
JTG.UI.ReleaseGameplayControl=function() end
JTG.UI.HideAllPanels=function() end
function GetCameraField() return 1650 end
local timers,units,frames,images,triggers,quests,fog={},{},{},{},{},{},{}
local oldCreateUnit,oldRemoveUnit=CreateUnit,RemoveUnit
function CreateUnit(...) local u=oldCreateUnit(...); units[#units+1]=u; return u end
function RemoveUnit(u) oldRemoveUnit(u) end
function CreateTimer() local t={}; timers[#timers+1]=t; return t end
function TimerStart(t,period,periodic,callback) t.callback=callback; t.period=period end
function PauseTimer(t) t.paused=true end
function DestroyTimer(t) t.destroyed=true end
function BlzCreateFrameByType() local f={}; frames[#frames+1]=f; return f end
function BlzDestroyFrame(f) f.destroyed=true end
function CreateImage() local i={}; images[#images+1]=i; return i end
function DestroyImage(i) i.destroyed=true end
function CreateTrigger() local t={events={}}; triggers[#triggers+1]=t; return t end
function DestroyTrigger(t) t.destroyed=true end
function CreateQuest() local q={}; quests[#quests+1]=q; return q end
function DestroyQuest(q) q.destroyed=true end
function CreateFogModifierRadius() local f={}; fog[#fog+1]=f; return f end
function DestroyFogModifier(f) f.destroyed=true end
local time,scale=6,1
function GetFloatGameState() return time end
function SetFloatGameState(_,value) time=value end
function GetTimeOfDayScale() return scale end
function SetTimeOfDayScale(value) scale=value end
for _,definition in ipairs({{'skills.bat_splitter',JTG.CreateBatSplittingActivity},
    {'skills.missile_dodging',JTG.CreateMissileDodgingActivity}}) do
    JTG.Registry.byId[definition[1]]={status='available',factory=definition[2],sceneId='test',category='skills',capabilities={}}
end
local function assertDisposed()
    for _,u in ipairs(units) do assert(u.removed,'Leaked unit '..u.id) end
    for _,list in ipairs({timers,frames,images,triggers,quests,fog}) do
        for _,handle in ipairs(list) do assert(handle.destroyed,'Leaked native handle') end
    end
    assert(time==6 and scale==1,'Borrowed day/night state was not restored')
end
-- Finished cards must hide the toolbar both on first display and restoration.
assert(JTG.StartActivity('skills.bat_splitter','skills',{hard=true}))
local batSession=JTG.Controller.session
local bat=batSession.activity
assert(not bat:nextStage(),'Next must reject an unfinished round')
bat:finish(); assert(not toolbar and result.actions.hide==nil)
bat:hidePresentationForMenu(); bat:restorePresentation(); assert(not toolbar)
local stale=timers[1].callback
assert(JTG.StopActivity('exit')); assertDisposed()
local before=bat.elapsed; stale(); assert(bat.elapsed==before,'Stale callback survived exit')
-- Failed Devour restoration renders the saved result without rerunning completion.
local devourIndex
for i,d in ipairs(JTG.DodgeDangers) do if d.menuGroup=='Devour' then devourIndex=i end end
assert(JTG.StartActivity('skills.missile_dodging','skills',{dangerIndex=devourIndex,movementUnit={unit='hfoo',name='Footman',abilities={}}}))
local dodge=JTG.Controller.session.activity
dodge:finishDevour(true)
assert(not dodge.devourResultReady)
timers[#timers].callback()
dodge.finishDevour=function() error('Restoration must not rerun completion') end
dodge:hidePresentationForMenu(); dodge:restorePresentation()
assert(dodge.finished and result.tone=='failure' and not toolbar and result.actions.hide==nil)
stale=timers[#timers].callback
assert(JTG.StopActivity('replace')); assertDisposed()
before=dodge.trialTime; stale(); assert(dodge.trialTime==before)
print('Passed: real controller exit/replacement disposal, stale timer guards, day/night restoration, result toolbar visibility and pure Devour result restoration.')
