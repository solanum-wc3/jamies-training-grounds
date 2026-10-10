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
    return text:gsub('{Hotkeys}', '|cffcc66ffHotkeys|r')
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

function T.ResolveStep(steps,state)
    state=state or {}
    if state.stepId then
        for index,step in ipairs(steps) do if step.id==state.stepId then return index end end
    end
    return math.max(1,math.min(#steps,tonumber(state.step) or 1))
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
    return JTG.StartScopedTimer(session,session.scope,delay,false,function()
        if activity.step==step and (activity.tutorialEntry or 0)==entry then callback() end
    end)
end

-- An entry is a visit, not just a numeric position. Returning to the same
-- narration or crossing an optional branch invalidates earlier callbacks.
function T.BeginEntry(activity,id)
    activity.tutorialEntry=(activity.tutorialEntry or 0)+1
    activity.tutorialStepId=id
end

function T.RunStepExit(activity,step)
    local action=step and step.afterContinue
    if action then
        assert(type(activity[action])=='function','Unknown tutorial exit action: '..action)
        activity[action](activity)
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
        if JTG.UI then
            local sound=entry.sound
            if type(sound)=='function' then sound=sound() end
            if JTG.UI.PlayButtonSound then JTG.UI.PlayButtonSound(sound) end
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
    activity.tutorialSpec=spec
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
                T.BeginEntry(self,(step and step.id) or
                    (spec.id..':'..name..':'..tostring(index or 'end')))
                return enter(self,index,...)
            end
        end
    end
    local cleanup=activity.cleanup
    activity.cleanup=function(self,...)
        T.BeginEntry(self,'disposed')
        if cleanup then return cleanup(self,...) end
    end
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
    return unit
end
