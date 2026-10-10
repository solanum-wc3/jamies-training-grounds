-- Standalone native mocks for the opening narration's finite arrow cue.
JTG={UI={HideToolbar=function() end}}
setmetatable(_G,{__index=function(_,name)
    if name:match('^[A-Z][A-Z0-9_]+$') then return name end
    return function() end
end})
function Player(id) return id end
function FourCC(raw) return raw end
function GetHandleId(frame) return frame end
function BlzFrameSetVisible(frame,visible) if frame then frame.visible=visible end end
function BlzFrameSetText(frame,text) if frame then frame.text=text end end
dofile('src/infrastructure/tutorial.lua')
dofile('src/activities/camera-tutorial.lua')
local activity=JTG.CreateCameraTutorialActivity({})
activity.frames={continue={},arrow={}}
activity:showStep(1)
assert(activity.arrowActive and activity.frames.arrow.visible)
local hiddenPulses=0
local wasVisible=true
for i=1,160 do
    activity:tick()
    local visible=activity.frames.arrow.visible
    if not visible and wasVisible then hiddenPulses=hiddenPulses+1 end
    wasVisible=visible
end
assert(hiddenPulses==10 and activity.arrowBlinks==10)
assert(activity.arrowActive and activity.frames.arrow.visible)
activity:showStep(1); activity:clearNarration()
assert(not activity.arrowActive and not activity.frames.arrow.visible)
activity:showStep(1); activity:continueTutorial()
assert(activity.step==2 and not activity.arrowActive and not activity.frames.arrow.visible)
activity:showStep(3); assert(not activity.arrowActive)
activity:showStep(1); activity:setObjectivesVisible(true)
assert(not activity.arrowActive and not activity.frames.arrow.visible)
activity:setObjectivesVisible(false); assert(not activity.arrowActive)
activity:showStep(1); activity:setOptionalVisible(true)
assert(not activity.arrowActive and not activity.frames.arrow.visible)
activity:setOptionalVisible(false)
activity:showStep(1); activity:hidePresentationForMenu()
assert(not activity.arrowActive and not activity.frames.arrow.visible)
activity:restorePresentation(); assert(not activity.arrowActive)
activity:showStep(1); activity:setPaused(true)
local elapsed=activity.arrowElapsed
activity:tick(); assert(activity.arrowElapsed==elapsed)
print('Passed: welcome-only cue, exactly ten blinks then standing, early Continue/clear, Topics/Optional/menu dismissal and pause behavior.')

-- Exercise the shared welcome cue through the other tutorials' real narration lifecycle.
local uiFile=assert(io.open('src/infrastructure/ui.lua'))
local uiSource=uiFile:read('*a'); uiFile:close()
local cue=uiSource:match('(%-%- Opening tutorial cue.-)local function RegisterClick')
assert(load('local UI=JTG.UI\n'..cue))()
for _,spec in ipairs({{'unit-controls-tutorial','CreateUnitControlsTutorialActivity'},
    {'hotkey-setup-tutorial','CreateHotkeySetupTutorialActivity'}}) do
    dofile('src/activities/'..spec[1]..'.lua')
    local tutorial=JTG[spec[2]]({})
    tutorial.frames={continue={},welcomeArrow={}}
    tutorial.runStepTrigger=function() end
    tutorial:showStep(1)
    assert(tutorial.welcomeArrowState and tutorial.frames.welcomeArrow.visible,spec[1])
    local hidden=0; local visible=true
    for i=1,160 do
        JTG.UI.TickWelcomeArrow(tutorial,0.1)
        if not tutorial.frames.welcomeArrow.visible and visible then hidden=hidden+1 end
        visible=tutorial.frames.welcomeArrow.visible
    end
    assert(hidden==10 and visible and tutorial.welcomeArrowState.blinks==10,spec[1])
    tutorial:clearNarration()
    assert(not tutorial.frames.welcomeArrow.visible and not tutorial.welcomeArrowState)
    tutorial:showStep(1); tutorial:showStep(2)
    assert(not tutorial.frames.welcomeArrow.visible and not tutorial.welcomeArrowState)
    tutorial:showStep(1); tutorial.presentationVisible=false; tutorial:renderNarration()
    assert(not tutorial.frames.welcomeArrow.visible and not tutorial.welcomeArrowState)
end
print('Passed: Unit Controls and Hotkey Setup welcome-only arrows blink ten times, remain standing, and clear with narration or menu dismissal.')
