-- Common tutorial presentation and lifecycle primitives.
JTG = JTG or {}
JTG.Tutorial = {cameraMoveDuration = 1.5, narrationDuration = 3600, buttonHeight = 0.024}
local T = JTG.Tutorial
function T.FormatNarration(text)
    local colors = {['Small Heading']='00ccff', Heading='00ccff', Button='ffcc00',
        Input='ffcc00', Menu='cc66ff', Term='ff9933', ['Yellow Font']='ffcc00',
        ['Gold Font']='ffcc00', ['Green Font']='00ff00', ['Red Font']='ff0000'}
    for tag,color in pairs(colors) do
        text = text:gsub('{'..tag..':%s*(.-)}', '|cff'..color..'%1|r')
    end
    return (text:gsub('{Hotkeys}', '|cffcc66ffHotkeys|r'))
end
function T.CreateButton(name, parent, label, width)
    local button=BlzCreateFrameByType('GLUETEXTBUTTON', name, parent, 'ScriptDialogButton', 0)
    BlzFrameSetSize(button,width,T.buttonHeight)
    BlzFrameSetText(button,label)
    return button
end
function T.MoveCamera(player,x,y,duration)
    if GetLocalPlayer()==player then PanCameraToTimed(x,y,duration or T.cameraMoveDuration) end
end
-- Explicit checkpoint navigation is allowed to reset the scene. Rendering,
-- clearing narration, resuming and rebuilding frames must never call this.
function T.RestoreCheckpoint(activity,id,category,index)
    activity.jumpStep=index
    activity:setTopicsVisible(false)
    local steps=activity.tutorialSpec and activity.tutorialSpec.steps
    JTG.StartActivityAfterCleanup(id,category,{step=index,stepId=steps and steps[index] and steps[index].id},nil,'tutorial-back')
end

-- Authored navigation must name a stable step; numeric positions are only
-- resolved at runtime. Unknown IDs are errors rather than silent welcome resets.
function T.StepIndex(steps,id)
    for index,step in ipairs(steps) do if step.id==id then return index end end
    error('Unknown tutorial step: '..tostring(id))
end
function T.TopicSteps(steps,topics)
    for _,topic in ipairs(topics) do topic.step=T.StepIndex(steps,topic.stepId) end
    return topics
end

function T.ResolveStep(steps,state)
    state=state or {}
    if state.stepId then
        for index,step in ipairs(steps) do if step.id==state.stepId then return index end end
    end
    return math.max(1,math.min(#steps,tonumber(state.step) or 1))
end

function T.CaptureCheckpoint(activity,index)
    local steps=assert(activity.tutorialSpec,'Tutorial runner not installed').steps
    index=T.ResolveStep(steps,{step=index or activity.step})
    return {step=index,stepId=steps[index].id}
end

function T.ResetScene(activity,index)
    local state=T.CaptureCheckpoint(activity,index)
    assert(type(activity.restoreCheckpoint)=='function','Tutorial has no scene restorer')
    return activity:restoreCheckpoint(state.step)
end

function T.SetButtonEnabled(activity,button,enabled)
    if button==nil then return end
    activity.buttonEnabled[GetHandleId(button)]=enabled==true
    BlzFrameSetEnable(button,enabled==true)
    BlzFrameSetAlpha(button,enabled and 255 or 145)
    BlzFrameSetTextColor(button,enabled and BlzConvertColor(255,255,204,0) or BlzConvertColor(255,145,145,145))
end
function T.ScheduleStep(session,activity,delay,callback)
    local step=activity.step
    local entry=activity.tutorialEntry or 0
    return JTG.StartScopedTimer(session,activity.tutorialStepScope or session.scope,delay,false,function()
        if activity.step==step and (activity.tutorialEntry or 0)==entry then callback() end
    end)
end

function T.GuardStep(session,activity,callback)
    local entry=activity.tutorialEntry or 0
    local scope=activity.tutorialStepScope
    return JTG.GuardSession(session,function(...)
        if (activity.tutorialEntry or 0)==entry and (not scope or not scope.disposed) then return callback(...) end
    end)
end

function T.CancelStep(activity)
    if activity.tutorialStepScope then
        JTG.DisposeScope(activity.tutorialStepScope)
        activity.tutorialStepScope=nil
    end
end

-- A scene can span several narration steps. Its actors and repeating movement
-- timers are disposed together when the tutorial explicitly replaces it.
function T.SceneScope(activity,key)
    activity.tutorialScenes=activity.tutorialScenes or {}
    local scope=activity.tutorialScenes[key]
    if not scope or scope.disposed then
        scope=JTG.CreateScope('tutorial-scene:'..key)
        activity.tutorialScenes[key]=scope
    end
    return scope
end

function T.ClearScene(activity,key)
    local scope=activity.tutorialScenes and activity.tutorialScenes[key]
    if scope then JTG.DisposeScope(scope);activity.tutorialScenes[key]=nil end
end

function T.SceneTimer(session,activity,key,period,repeating,callback)
    local scope=T.SceneScope(activity,key)
    return JTG.StartScopedTimer(session,scope,period,repeating,function()
        if not scope.disposed then callback() end
    end)
end

-- An entry is a visit, not just a numeric position. Returning to the same
-- narration or crossing an optional branch invalidates earlier callbacks.
function T.BeginEntry(activity,id,nextStep,reason)
    local previous=activity.tutorialActiveStep
    activity.tutorialActiveStep=nil
    T.CancelStep(activity)
    local spec=activity.tutorialSpec
    if spec and spec.sceneExit and previous then
        spec.sceneExit(activity,previous,nextStep,reason or 'advance')
    end
    activity.tutorialEntry=(activity.tutorialEntry or 0)+1
    activity.announcedHeadings={}
    activity.tutorialStepId=id
    if activity.tutorialSession and JTG.CreateScope and JTG.DisposeScope and id~='disposed' then
        activity.tutorialStepScope=JTG.CreateScope('tutorial-step:'..tostring(id))
    end
end

-- Navigation invalidates the previous visit BEFORE restoring the world. Nested
-- showStep calls share this boundary; rendering never enters a transition.
function T.Transition(activity,id,callback,nextStep,reason)
    if activity.tutorialTransitionActive then return callback() end
    activity.tutorialTransitionActive=true
    local ok,result=pcall(function()
        T.BeginEntry(activity,id,nextStep,reason)
        return callback()
    end)
    activity.tutorialTransitionActive=false
    if not ok then error(result,0) end
    return result
end

function T.RestoreAt(activity,index,restore,enter)
    local steps=assert(activity.tutorialSpec,'Tutorial runner not installed').steps
    local target=assert(steps[index],'Unknown tutorial checkpoint: '..tostring(index))
    return T.Transition(activity,target.id or ('restore:'..index),function()
        activity.step=index
        if restore then restore(index) end
        return enter(index)
    end,target,'restore')
end

-- A condition watcher observes live map state; it never advances or resets a
-- tutorial implicitly. Its success callback chooses the authored next action.
function T.WatchProgress(session,activity,condition,onSatisfied,interval)
    local entry=activity.tutorialEntry or 0
    local timer,done
    timer=JTG.StartScopedTimer(session,activity.tutorialStepScope or session.scope,
        interval or 0.1,true,function()
            if done or (activity.tutorialEntry or 0)~=entry then PauseTimer(timer);return end
            if activity.locallyPaused or activity.topicsOpen or activity.objectivesOpen or
                activity.optionalOpen or activity.presentationVisible==false or
                (JTG.UI and (JTG.UI.exercisePaused or JTG.UI.gameplayMenuPaused or
                    JTG.UI.nativeMenuOpen or JTG.UI.nativeSuspendQueued)) then return end
            local ok,satisfied=pcall(condition,activity)
            if not ok then
                done=true;PauseTimer(timer)
                print('JTG tutorial condition error ('..tostring(activity.tutorialStepId)..'): '..tostring(satisfied))
                return
            end
            if satisfied then
                done=true
                PauseTimer(timer)
                onSatisfied(activity)
            end
        end)
    return timer
end

-- One bounded ownership handoff policy. Native work and active player orders
-- are preserved on retries; hidden miners cannot accept replacement orders.
function T.RestoreWorkerOrders(session,activity,workers,resume,options)
    options=options or {}
    activity.gatheringHandoff=(activity.gatheringHandoff or 0)+1
    local handoff=activity.gatheringHandoff
    local settled={}
    local function apply(initial)
        if activity.gatheringHandoff~=handoff or (options.isCurrent and not options.isCurrent()) then return end
        for _,unit in ipairs(workers) do
            if GetUnitTypeId(unit)~=0 and GetWidgetLife(unit)>0.405 and not IsUnitHidden(unit) then
                local order=GetUnitCurrentOrder(unit)
                if options.observe then options.observe(unit,initial) end
                -- SetUnitOwner may leave a stale harvest order until the next
                -- simulation tick. Refresh it once after the handoff settles.
                -- Never replace a new move/build/attack order or order a hidden miner.
                local gathering=order==OrderId('harvest') or order==OrderId('resumeharvesting') or
                    order==OrderId('returnresources') or order==OrderId('returngold') or order==OrderId('returnlumber')
                local refresh=options.force and not initial and not settled[unit] and gathering
                if not initial then settled[unit]=true end
                if (initial and options.force) or refresh or order==0 or order==OrderId('stop') then
                    resume(unit,not ((initial and options.force) or refresh))
                end
            end
        end
    end
    apply(true)
    for _,delay in ipairs({0.25,0.75,1.5,3.0,5.0}) do
        JTG.StartScopedTimer(session,session.scope,delay,false,function() apply(false) end)
    end
end

function T.RunStepExit(activity,step)
    local action=step and step.afterContinue
    if action then
        assert(type(activity[action])=='function','Unknown tutorial exit action: '..action)
        activity[action](activity)
    end
end

-- Rebuild a lesson from its declared setup root, not from all earlier lessons.
-- The target step runs once, afterward, through the normal entry hook.
function T.ReplaySetup(activity,steps,index,reset,apply)
    assert(activity.tutorialTransitionActive,'Scene replay requires an explicit transition')
    reset()
    local first=1
    for i=1,index-1 do if steps[i].sceneRoot then first=i end end
    for i=first,index-1 do
        apply(steps[i])
        T.RunStepExit(activity,steps[i])
    end
end

function T.CreateToolbar(activity,scope,root,prefix,suffix,labels)
    local layout=(JTG.UI and JTG.UI.ToolbarLayout) or {
        buttonWidth=0.087,gap=0.001,rowStep=0.025,left=0.446,top=0.575}
    local bar=JTG.ScopeTrackFrame(scope,BlzCreateFrameByType('FRAME',
        prefix..'Bar'..suffix,root,'',0))
    BlzFrameSetSize(bar,0.351,0.060)
    BlzFrameSetAbsPoint(bar,FRAMEPOINT_TOPLEFT,layout.left,layout.top)
    activity.frames.bar=bar
    for _,spec in ipairs(labels) do
        local button=JTG.ScopeTrackFrame(scope,T.CreateButton(prefix..spec[1]..suffix,
            bar,spec[2],layout.buttonWidth))
        local slot=spec[3]-1
        BlzFrameSetPoint(button,FRAMEPOINT_TOPLEFT,bar,FRAMEPOINT_TOPLEFT,
            (slot%4)*(layout.buttonWidth+layout.gap),-math.floor(slot/4)*layout.rowStep)
        activity.frames[spec[1]]=button
        activity.toolbarSoundKinds=activity.toolbarSoundKinds or {}
        activity.toolbarSoundKinds[GetHandleId(button)]=
            (spec[2]=='Menu' or spec[2]=='Topics' or spec[2]=='Optional' or spec[2]=='Setups') and 'menu-open' or 'normal'
        local label=BlzFrameGetChild(button,4)
        if label then BlzFrameSetScale(label,0.72) end
    end
    return bar
end

function T.CreateHighlight(activity,scope,prefix,suffix,key,frameKey)
    local highlight=JTG.ScopeTrackFrame(scope,BlzCreateFrameByType('SPRITE',
        prefix..key..'Highlight'..suffix,activity.frames.bar,'',0))
    local target=activity.frames[frameKey or key]
    BlzFrameSetSize(highlight,0.058,0.024)
    BlzFrameSetPoint(highlight,FRAMEPOINT_CENTER,target,FRAMEPOINT_CENTER,-0.0125,0)
    BlzFrameSetModel(highlight,'UI\\Feedback\\QuestButton\\UI-QuestButtonOn.mdl',0)
    BlzFrameSetLevel(highlight,3);BlzFrameSetEnable(highlight,false)
    BlzFrameSetVisible(highlight,false);BlzFrameSetLevel(target,2)
    if key=='pause' and JTG.UI and JTG.UI.RegisterPauseHighlight then
        JTG.ScopeBorrow(scope,JTG.UI.RegisterPauseHighlight(highlight))
    else activity.frames[key..'Highlight']=highlight end
    return highlight
end

function T.RenderNarration(activity,player)
    ClearTextMessages()
    if not activity.presentationVisible or activity.topicsOpen or
            activity.objectivesOpen or activity.optionalOpen then
        if JTG.UI and JTG.UI.ClearWelcomeArrow then JTG.UI.ClearWelcomeArrow(activity) end
        if activity.clearArrow then activity:clearArrow() end
        return
    end
    for _,text in ipairs(activity.narrationBlocks or {}) do
        DisplayTimedTextToPlayer(player,0,0,T.narrationDuration,text)
    end
end

function T.ClearNarration(activity,preserveArrow)
    if JTG.UI and JTG.UI.ClearWelcomeArrow then JTG.UI.ClearWelcomeArrow(activity) end
    if not preserveArrow and activity.clearArrow then activity:clearArrow() end
    for _,key in ipairs({'menuHighlight','exportHighlight'}) do
        if activity.frames[key] then BlzFrameSetVisible(activity.frames[key],false) end
    end
    ClearTextMessages()
    activity.narrationBlocks={}
end

function T.BindClicks(activity,scope)
    activity.clickTrigger=JTG.ScopeTrackTrigger(scope,CreateTrigger())
    TriggerAddAction(activity.clickTrigger,function()
        if scope.disposed then return end
        local clicked=BlzGetTriggerFrame()
        local entry=activity.actions[GetHandleId(clicked)]
        if not entry or activity.buttonEnabled[GetHandleId(clicked)]==false then return end
        local toolbarKind=(activity.toolbarSoundKinds or {})[GetHandleId(clicked)]
        if JTG.UI then
            local sound=entry.sound
            if type(sound)=='function' then sound=sound() end
            if JTG.UI.PlayButtonSound then JTG.UI.PlayButtonSound(toolbarKind or sound or 'normal') end
            if JTG.UI.ReleaseFrameFocus then JTG.UI.ReleaseFrameFocus(clicked) end
        end
        entry.action()
        if JTG.UI and JTG.UI.ReleaseKeyboardFocusAfterClick then
            JTG.UI.ReleaseKeyboardFocusAfterClick()
        end
    end)
end

-- Shared lifecycle and entry dispatch; authored progression/optional branches
-- remain explicit hooks. Rendering and frame reconstruction never enter steps.
function T.InstallRunner(activity,session,spec)
    local ids={}
    for index,step in ipairs(spec.steps or {}) do
        if spec.requireStableIds then assert(type(step.id)=='string' and step.id~='',spec.id..': missing stable step ID at '..index) end
        if step.groupStart then assert(step.groupStart>=1 and step.groupStart<=index,spec.id..': invalid narration group at '..index) end
        if step.id then assert(not ids[step.id],spec.id..': duplicate step ID '..step.id);ids[step.id]=true end
    end
    activity.tutorialSpec=spec
    activity.tutorialSession=session
    if JTG.ScopeAdd then JTG.ScopeAdd(session.scope,function()
        T.CancelStep(activity)
        for key in pairs(activity.tutorialScenes or {}) do T.ClearScene(activity,key) end
    end) end
    activity.makeTimer=function(_,period,repeating,callback)
        return JTG.StartScopedTimer(session,session.scope,period,repeating,callback)
    end
    activity.registerClick=function(self,button,action,sound)
        self.actions[GetHandleId(button)]={action=action,sound=sound}
        BlzTriggerRegisterFrameEvent(self.clickTrigger,button,FRAMEEVENT_CONTROL_CLICK)
    end
    activity.setButtonEnabled=T.SetButtonEnabled
    activity.clearNarration=T.ClearNarration
    activity.renderNarration=function(self) T.RenderNarration(self,spec.player) end
    for _,name in ipairs(spec.entries or {'showStep','showOptionalStep','showCompletion'}) do
        local enter=activity[name]
        if enter then
            activity[name]=function(self,index,...)
                local step=spec.steps and name=='showStep' and spec.steps[index]
                if name=='showOptionalStep' and type(self.optionalSection)=='table' then
                    step=self.optionalSection.steps[index]
                end
                local args=table.pack(...)
                return T.Transition(self,(step and step.id) or
                    (spec.id..':'..name..':'..tostring(index or 'end')),function()
                        local result=enter(self,index,table.unpack(args,1,args.n))
                        if name=='showStep' then self.tutorialActiveStep=spec.steps[self.step]
                        elseif name=='showOptionalStep' then self.tutorialActiveStep=step end
                        return result
                    end,step,'advance')
            end
        end
    end
    local cleanup=activity.cleanup
    activity.cleanup=function(self,...)
        T.BeginEntry(self,'disposed',nil,'dispose')
        if cleanup then return cleanup(self,...) end
    end
end

-- Mobile units retain the engine's walkable spawn position. Exact authored
-- coordinates are a separate policy for structures and deliberate staging.
function T.CreateMobileUnit(scope,owner,raw,x,y,facing)
    local unit=JTG.ScopeTrackUnit(scope,CreateUnit(owner,raw,x,y,facing or 270))
    SetUnitPathing(unit,true)
    return unit
end

function T.EnsureMobileUnit(scope,unit,owner,raw,x,y,facing)
    if unit and GetUnitTypeId(unit)~=0 and GetWidgetLife(unit)>0.405 then return unit end
    if unit and GetUnitTypeId(unit)~=0 then RemoveUnit(unit) end
    return T.CreateMobileUnit(scope,owner,raw,x,y,facing)
end

function T.OpenMenu(activity,category)
    if not JTG.UI then return end
    activity:setPresentationVisible(false)
    JTG.UI.SetGameplayMenuPaused(true)
    JTG.UI.ShowActivityMenu(category or 'learn')
end
function T.TogglePause(activity)
    if JTG.UI then JTG.UI.SetExercisePaused(not JTG.UI.exercisePaused) end
    activity:refreshControls()
end

-- Scene creation initializes melee-only native behavior and keeps the engine's
-- visual and gameplay positions together. Place buildings before mobile units.
function T.CreateSceneUnit(scope,owner,raw,x,y,facing)
    local unit=JTG.ScopeTrackUnit(scope,CreateUnit(owner,raw,x,y,facing or 270))
    if math.abs(GetUnitX(unit)-x)>0.01 or math.abs(GetUnitY(unit)-y)>0.01 then
        SetUnitPathing(unit,false)
        SetUnitPosition(unit,x,y)
        SetUnitPathing(unit,true)
    end
    if raw==FourCC('htow') then
        UnitAddAbility(unit,FourCC('Amic'))
        UnitMakeAbilityPermanent(unit,true,FourCC('Amic'))
    end
    if raw==FourCC('ofor') and GetUnitAbilityLevel(unit,FourCC('Arlm'))==0 then
        UnitAddAbility(unit,FourCC('Arlm'))
        UnitMakeAbilityPermanent(unit,true,FourCC('Arlm'))
    end
    return unit
end
