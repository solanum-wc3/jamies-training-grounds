JTG={}
function FourCC(raw) return raw end
function Player(id) return id end
dofile('src/infrastructure/core.lua')
local restored,cleaned=nil,false
local function noop() end
JTG.UI={SetGameplayMenuPaused=noop,SetExercisePaused=noop,SetQuestAvailable=noop,
    HideToolbar=noop,RestoreLoadedView=function(view) restored=view end}
JTG.ResetWorldFog=noop
local session={active=true,finalizers={},scope=JTG.CreateScope('exercise'),
    presentationScope=JTG.CreateScope('presentation'),
    activity={cleanup=function() cleaned=true end}}
JTG.Controller.session=session
JTG.Controller.lastCategory='tools'
local view={kind='activity_briefing',id='skills.reflex',category='tools',page='races',data={mode='identify',races={'human','orc'}}}
JTG.UI.currentView=view
-- Use the real UI's footer assignment, including a conflicting old selector
-- callback. A paused footer must preserve its exact page through shared Exit.
local file=assert(io.open('src/infrastructure/ui.lua'));local source=file:read('*a');file:close()
local expression=assert(source:match('UI.activityBriefingExitAction = (.-)%s*UI.activityBriefingPrimaryAction'))
local callback=assert(load('return '..expression,'paused footer','t',{
    JTG=JTG,spec={resumeAction=noop,exitAction=function() error('Legacy selector exit used') end}}))()
assert(callback==JTG.ExitActivityFromMenu)
callback()
assert(restored==view and restored.page=='races' and #restored.data.races==2 and cleaned and
    session.scope.disposed and session.presentationScope.disposed and
    JTG.Controller.session==nil,'Exit fails to clean up and preserve its exact selector')
local primary=assert(source:match('local showPrimary = (.-)%s*BlzFrameSetVisible%(UI.activityBriefingPrimary'))
local visible=assert(load('return '..primary,'paused footer primary','t',{
    spec={resumeAction=noop,primaryAction=noop,primaryLabel='Start Training'}}))()
assert(not visible,'Paused briefing shows Start alongside Resume/Exit')
print('Passed: shared exercise-menu Exit disposes activity and preserves its current selector and selections; paused footer suppresses competing Start.')

-- Exercise the real post-cleanup menu restoration gateway, not a fake redirect.
function JTG.UI.HideAllPanels() end
local entered
JTG.Registry.byId['skills.reflex']={status='available',category='tools',menu=function(cat,paused,page,data)
 entered={category=cat,paused=paused,page=page,data=data}
end}
local start=assert(source:find('function UI.RestoreLoadedView(view)',1,true))
local finish=assert(source:find('function UI.QueuePostLoadViewRestore(view)',start,true))
assert(load('local UI=JTG.UI;local function ApplyActivityPause() end\n'..source:sub(start,finish-1)))()
JTG.ExitActivityFromMenu()
assert(entered.category=='tools' and entered.page=='races' and entered.data==view.data and not entered.paused,
 'Exit reopened another menu page or retained exercise controls')
