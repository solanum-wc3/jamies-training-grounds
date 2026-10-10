-- Shared presentation and countdown lifecycle for exercises. World setup,
-- scoring and native orders remain owned by the individual exercise.
JTG.Training = JTG.Training or {}
local T = JTG.Training

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
