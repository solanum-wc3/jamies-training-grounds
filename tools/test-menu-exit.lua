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

-- Both Surround variants must stop first, then recreate on the next update.
-- A new activity entered before that update must cancel the pending restart.
local resetTimer, starts, stopped = nil, 0, 0
function GetLocalPlayer() return 0 end
function GetCameraField() return 1650 end
function CreateTimer() return {} end
function TimerStart(timer, delay, repeating, callback)
    assert(delay==0 and not repeating)
    timer.callback=callback;resetTimer=timer
end
function DestroyTimer(timer) timer.destroyed=true end
local originalStop, originalStart = JTG.StopActivity, JTG.StartActivity
JTG.StopActivity=function()
    stopped=stopped+1
    JTG.Controller.session=nil
    JTG.Controller.generation=(JTG.Controller.generation or 0)+1
end
JTG.StartActivity=function(id, category, data, distance)
    starts=starts+1
    assert(category=='skills' and data.setupIndex==2 and distance==1650)
    JTG.Controller.session={id=id}
    return true
end
for _,id in ipairs({'skills.surround','skills.gargoyle'}) do
    local function prepare()
        JTG.Controller.lastCategory='skills'
        JTG.Controller.session={id=id,restartData={},activity={
            captureResetState=function() return {setupIndex=2} end}}
    end
    prepare()
    local before=starts
    assert(JTG.ResetActivity() and JTG.Controller.session==nil and starts==before)
    resetTimer.callback()
    assert(resetTimer.destroyed and starts==before+1 and JTG.Controller.session.id==id)
    prepare();assert(JTG.ResetActivity())
    JTG.Controller.session={id='another.activity'}
    resetTimer.callback()
    assert(starts==before+1 and JTG.Controller.session.id=='another.activity')
end
assert(stopped==4)
JTG.StopActivity, JTG.StartActivity=originalStop, originalStart
JTG.Controller.session=nil
JTG.Controller.lastCategory='tools'
print('Passed: Surrounds/Gargoyle Redo share deferred recreation and cancel stale restarts.')

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
