-- Shared presentation, response scoring and countdown lifecycle for exercises.
-- World setup, score progression and native orders remain exercise-specific.
JTG.Training = JTG.Training or {}
local T = JTG.Training
function T.ResponseAward(seconds)
    if seconds<=1 then return 15 end
    if seconds<=5 then return 10 end
    return 0
end

function T.ScoreStyle(score)
    if score>=450 then return '|cffffcc00',1.85 end
    if score>=350 then return '|cff40dd60',1.65 end
    if score>=250 then return '|cffffff00',1.45 end
    return '|cffff4040',1.25
end

-- An attempt is a gameplay boundary, independent of hiding/rebuilding cards.
function T.BeginAttempt(session)
    session.resultAttempt=(session.resultAttempt or 1)+1
end

local HELP_COLOR='|cff80c8ff'
local HELP_SCALE=1.85
local HELP_TEXT_DURATION,HELP_ARROW_DURATION=10,20

function T.QuestHelpState(session)
    session.restartData=session.restartData or {}
    session.restartData._questHelp=session.restartData._questHelp or {failures=0,shown=false,redoCount=0}
    return session.restartData._questHelp
end

function T.ResumeQuestHint(activity,session)
    local state=T.QuestHelpState(session)
    if session.id=='skills.body_blocking' and state.redoKey then
        local key=tostring(activity.race)..':'..tostring(activity.runnerIndex)..':'..tostring(activity.runnerId)
        if key~=state.redoKey then state.redoKey=nil;state.redoCount=0 end
    end
    if not state.active then return end
    if not activity.questHintText then
        local root=BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
        activity.questHintText=JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType('TEXT','JTGQuestHelpText',root,'',0))
        BlzFrameSetSize(activity.questHintText,0.70/HELP_SCALE,0.070/HELP_SCALE)
        BlzFrameSetAbsPoint(activity.questHintText,FRAMEPOINT_BOTTOM,0.40,0.16)
        BlzFrameSetTextAlignment(activity.questHintText,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(activity.questHintText,false)
        BlzFrameSetScale(activity.questHintText,HELP_SCALE)
        BlzFrameSetAlpha(activity.questHintText,230)
        BlzFrameSetText(activity.questHintText,HELP_COLOR..'You seem to be having some trouble. Try reading the Quest Log for an explanation of what to do!|r')
        -- There is no native QUEST_BUTTON origin-frame type. Use the engine's
        -- named upper-bar button, as the tutorial UI does.
        local button=BlzGetFrameByName('UpperButtonBarQuestsButton',0)
        activity.questHintArrow=JTG.UI.CreateWelcomeArrow(session.presentationScope,root,button,'JTGQuestHelpArrow')
    end
    local function render()
        local visible=activity.presentationVisible~=false
        if activity.questHintText then BlzFrameSetVisible(activity.questHintText,visible and state.elapsed<HELP_TEXT_DURATION) end
        if activity.questHintArrow then
            local arrowElapsed=state.elapsed
            local blinking=arrowElapsed<1.8
            local on=not blinking or math.floor((arrowElapsed+0.00001)/0.3)%2==0
            BlzFrameSetVisible(activity.questHintArrow,visible and state.active and arrowElapsed>=-0.00001 and on)
        end
    end
    render()
    if not activity.questHintTimer then
        local timer
        timer=JTG.StartScopedTimer(session,session.scope,0.1,true,function()
            if activity.locallyPaused or activity.paused then return end
            state.elapsed=math.floor((state.elapsed+0.1)*10+0.5)/10
            if state.elapsed>=1.8+HELP_ARROW_DURATION-0.00001 then state.active=false;PauseTimer(timer) end
            render()
        end)
        activity.questHintTimer=timer
    end
    if not activity.questHintWrapped then
        activity.questHintWrapped=true
        local hide,show=activity.hidePresentationForMenu,activity.restorePresentation
        activity.hidePresentationForMenu=function(self,...)
            if hide then hide(self,...) end
            if self.questHintText then BlzFrameSetVisible(self.questHintText,false) end
            if self.questHintArrow then BlzFrameSetVisible(self.questHintArrow,false) end
        end
        activity.restorePresentation=function(self,...)
            if show then show(self,...) end
            render()
        end
        local discard,rebuild=activity.discardPresentationForLoad,activity.rebuildPresentation
        activity.discardPresentationForLoad=function(self,...)
            self.questHintText=nil;self.questHintArrow=nil
            if discard then discard(self,...) end
        end
        activity.rebuildPresentation=function(self,...)
            if rebuild then rebuild(self,...) end
            if state.active then T.ResumeQuestHint(self,session) end
        end
    end
end

function T.TriggerQuestHint(activity,session)
    local state=T.QuestHelpState(session)
    if state.shown then return end
    state.shown=true;state.active=true;state.elapsed=0
    T.ResumeQuestHint(activity,session)
end

function T.RecordFailure(activity,session,success)
    local state=T.QuestHelpState(session)
    state.failures=success and 0 or state.failures+1
    if state.failures>=10 then T.TriggerQuestHint(activity,session) end
end

function T.RecordBodyBlockingRedo(activity,session,restartData)
    local state=T.QuestHelpState(session)
    local key=tostring(activity.race)..':'..tostring(activity.runnerIndex)..':'..tostring(activity.runnerId)
    if activity.nextRunnerRequested or restartData.runnerIndex~=activity.runnerIndex then
        state.redoCount=0;state.redoKey=nil;return
    end
    state.redoCount=state.redoKey==key and state.redoCount+1 or 1
    state.redoKey=key
    if state.redoCount>=5 and not state.shown then
        -- The old scope is about to be disposed; display in the restarted run.
        state.shown=true;state.active=true;state.elapsed=0
    end
end

-- Visits survive Redo/Next/Back within an exercise, but not a new menu launch.
function T.ShowSetupLabel(activity,session,label,index,total,key)
    local visits=(session.restartData or {})._setupVisits or {}
    session.restartData=session.restartData or {};session.restartData._setupVisits=visits
    key=key or (label..':'..index)
    if visits[key] then return end
    visits[key]=true
    if activity.setupLabelFrame then BlzFrameSetVisible(activity.setupLabelFrame,false) end
    local frame=JTG.ScopeTrackFrame(session.presentationScope,
        BlzCreateFrameByType('TEXT','JTGSetupVisit'..tostring(session.generation or ''),
            BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),'',0))
    BlzFrameSetSize(frame,0.40/HELP_SCALE,0.045/HELP_SCALE)
    BlzFrameSetAbsPoint(frame,FRAMEPOINT_TOP,0.40,0.47)
    BlzFrameSetTextAlignment(frame,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
    BlzFrameSetScale(frame,HELP_SCALE);BlzFrameSetEnable(frame,false)
    BlzFrameSetAlpha(frame,230)
    BlzFrameSetText(frame,HELP_COLOR..label..' '..index..'/'..total..'|r')
    activity.setupLabelFrame=frame;activity.setupLabelActive=true
    activity.setupLabelText=label..' '..index..'/'..total
    JTG.StartScopedTimer(session,session.scope,HELP_TEXT_DURATION,false,function()
        if activity.setupLabelText~=label..' '..index..'/'..total then return end
        activity.setupLabelActive=false
        if activity.setupLabelFrame then BlzFrameSetVisible(activity.setupLabelFrame,false) end
    end)
    if not activity.setupLabelWrapped then
        activity.setupLabelWrapped=true
        local hide,show=activity.hidePresentationForMenu,activity.restorePresentation
        activity.hidePresentationForMenu=function(self,...)
            if self.setupLabelFrame then BlzFrameSetVisible(self.setupLabelFrame,false) end
            if hide then return hide(self,...) end
        end
        activity.restorePresentation=function(self,...)
            if show then show(self,...) end
            if self.setupLabelFrame then BlzFrameSetVisible(self.setupLabelFrame,self.setupLabelActive==true) end
        end
        local discard,rebuild=activity.discardPresentationForLoad,activity.rebuildPresentation
        activity.discardPresentationForLoad=function(self,...)
            self.setupLabelFrame=nil
            if discard then return discard(self,...) end
        end
        activity.rebuildPresentation=function(self,...)
            if rebuild then rebuild(self,...) end
            if self.setupLabelActive then
                self.setupLabelFrame=JTG.ScopeTrackFrame(session.presentationScope,
                    BlzCreateFrameByType('TEXT','JTGSetupVisitReload',BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),'',0))
                BlzFrameSetSize(self.setupLabelFrame,0.40/HELP_SCALE,0.045/HELP_SCALE)
                BlzFrameSetAbsPoint(self.setupLabelFrame,FRAMEPOINT_TOP,0.40,0.47)
                BlzFrameSetTextAlignment(self.setupLabelFrame,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
                BlzFrameSetScale(self.setupLabelFrame,HELP_SCALE);BlzFrameSetEnable(self.setupLabelFrame,false)
                BlzFrameSetAlpha(self.setupLabelFrame,230)
                BlzFrameSetText(self.setupLabelFrame,HELP_COLOR..self.setupLabelText..'|r')
                BlzFrameSetVisible(self.setupLabelFrame,self.presentationVisible~=false)
            end
        end
    end
end

function T.SetPresentation(activity, session, visible, onShow, onHide)
    activity.presentationVisible = visible
    if activity.status then BlzFrameSetVisible(activity.status, visible) end
    if not visible then
        JTG.UI.HideResultCard(activity.resultCard)
        JTG.UI.HideToolbar()
        if activity.clearFeedback then activity:clearFeedback() end
        if onHide then onHide() end
        return
    end
    if activity.finished then JTG.UI.HideToolbar()
    else JTG.UI.ShowToolbar(session.descriptor.capabilities) end
    if activity.refreshStatus then activity:refreshStatus() end
    if onShow then onShow() end
end

-- Register presentation-owned aliases once. Hide/show/rebuild never restart
-- an attempt, spawn actors, advance a clock, or dispose gameplay scopes.
function T.InstallPresentation(activity,session,spec)
    assert(not activity.presentationSpec,'Presentation already installed')
    assert(type(spec.references)=='table','Presentation must declare frame references')
    local references={}
    for _,key in ipairs(spec.references) do references[key]=true end
    for _,list in ipairs({spec.roots or {},spec.lists or {}}) do
        for _,key in ipairs(list) do assert(references[key],'Unregistered presentation alias: '..key) end
    end
    for _,method in ipairs(spec.refresh or {}) do assert(type(activity[method])=='function','Missing presentation refresh: '..method) end
    if spec.result then assert(type(activity[spec.result])=='function','Missing result renderer') end
    activity.presentationSpec=spec
    local function hideFrames(self)
        for _,key in ipairs(spec.roots or {}) do
            if self[key] then BlzFrameSetVisible(self[key],false) end
        end
        for _,key in ipairs(spec.lists or {}) do
            for _,frame in ipairs(self[key] or {}) do BlzFrameSetVisible(frame,false) end
        end
    end
    function activity:hidePresentationForMenu()
        if spec.beforeHide then spec.beforeHide(self) end
        T.SetPresentation(self,session,false,nil,function() hideFrames(self) end)
    end
    function activity:restorePresentation()
        T.SetPresentation(self,session,true,function()
            for _,method in ipairs(spec.refresh or {}) do self[method](self) end
            if self.finished then
                if spec.result then self[spec.result](self) end
            elseif spec.resume then spec.resume(self) end
        end)
    end
    function activity:discardPresentationForLoad()
        -- The controller owns the old presentation scope. Drop every alias,
        -- including callbacks which close over frames from the previous scope.
        for _,key in ipairs(spec.references) do self[key]=nil end
    end
    function activity:rebuildPresentation()
        self:createPresentation()
        self:restorePresentation()
    end
end

function T.BriefingText(activityId,page)
    local pages=assert(JTG.ExerciseBriefings and JTG.ExerciseBriefings[activityId],
        'Missing exercise briefings: '..tostring(activityId))
    return JTG.Tutorial.FormatNarration(assert(pages[page],'Missing briefing page: '..tostring(page)))
end

function T.Countdown(activity, session, seconds, onTick, onComplete)
    local remaining = seconds
    onTick(remaining)
    local timer
    timer = JTG.StartScopedTimer(session, session.scope, 1, true, function()
        if activity.finished then PauseTimer(timer); return end
        remaining = remaining - 1
        if remaining <= 0 then
            PauseTimer(timer)
            onComplete()
        else onTick(remaining) end
    end)
    return timer
end
