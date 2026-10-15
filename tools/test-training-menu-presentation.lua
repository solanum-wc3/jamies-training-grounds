-- Run after test-training-standardization.lua. Exercise the real shared menu
-- entry points with each new activity's actual presentation-hiding method.
local screen
JTG.UI.ShowActivityBriefing=function(spec) screen=spec end
JTG.OpenMissileDodgingMenu('skills',false,'abilities',{dangerIndex=1})
local starts={0,2,4,7,10,12,14}
for index,heading in ipairs(screen.commandGridHeadings) do
    local first,last
    for _,choice in ipairs(screen.choices) do
        if choice.column>=starts[index] and choice.column<starts[index+1] then
            first=math.min(first or choice.column,choice.column)
            last=math.max(last or choice.column,choice.column)
        end
    end
    if first then
        local center=heading.x+heading.width/2
        assert(math.abs(center-((first+last)/2-6.5)*0.034)<0.000001,
            'Heading is not centered over its occupied columns: '..heading.label)
    end
end

dofile('src/infrastructure/ui.lua')
local UI=JTG.UI
function BlzFrameSetVisible(frame,value) assert(type(frame)=='table'); frame.visible=value end
function BlzFrameSetText(frame,value) assert(type(frame)=='table'); frame.text=value end
function BlzFrameSetEnable(frame,value) assert(type(frame)=='table'); frame.enabled=value end
function BlzGetFrameByName() return nil end
function BlzGetOriginFrame() return {} end
function GetHandleId(frame) return frame end
function BlzFrameIsVisible(frame) return frame.visible==true end
local paused
function PauseGame(value) paused=value end
UI.LayoutToolbar=function() end
for _,key in ipairs({'toolbar','pausedActivityResume','pausedActivityExit',
    'activityBriefingTitle','activityBriefingTitleSuffix','activityBriefingBody',
    'activityBriefingContentDivider','activityBriefingArtwork','activityBriefingBack',
    'activityBriefingPrimary','activityBriefingResume','activityBriefingExit'}) do UI[key]={} end
for _,key in ipairs({'restart','menu','lastRunner','next','pause','rotate','setups','squares'}) do
    UI.toolbarButtons[key]={}
end
for _,key in ipairs({'root','category_skills','category_race_advanced_human',
    'activityBriefing','credits'}) do UI.panels[key]={} end
local function hidden(activity)
    assert(not activity.presentationVisible and not activity.status.visible)
    assert(not activity.resultCard.panel.visible and not UI.toolbar.visible)
    if activity.feedback then
        assert(not activity.feedback.visible and activity.feedback.text=='')
        assert(activity.flashUntil==nil)
    end
    assert(paused,'Opening a menu must preserve the gameplay pause')
end
for _,factory in ipairs({JTG.CreateMissileDodgingActivity,JTG.CreateBatSplittingActivity}) do
    local session={restartData={},descriptor={capabilities={}},scene={centerX=0,centerY=0}}
    local activity=factory(session)
    session.activity=activity; JTG.Controller.session=session
    activity.status={}; activity.resultCard={panel={}}
    if activity.flash then activity.feedback={} end
    for _,open in ipairs({
        function() UI.ShowActivityBriefing({pauseGame=true}) end,
        function() UI.ShowCategory('skills') end,
        function() UI.ShowRoot() end,
        function() UI.ShowCategoryRace('advanced','human') end,
        function() UI.ShowInfo('credits') end,
    }) do
        activity.presentationVisible=true; activity.status.visible=true
        activity.resultCard.panel.visible=true; UI.toolbar.visible=true
        if activity.flash then activity:flash('GO!') end
        open(); hidden(activity)
    end
    -- Resuming hides the menu and restores the gameplay toolbar; a retained
    -- user Pause remains in force independently of the menu's own pause.
    UI.exercisePaused=true
    JTG.ResumeActivity()
    assert(activity.presentationVisible and activity.status.visible and UI.toolbar.visible)
    assert(not UI.menuVisible and paused)
    UI.SetExercisePaused(false); assert(not paused)
end
JTG.Controller.session=nil
-- Rectangular briefing choices use the same native tooltip path as icon
-- choices. Reusing a slot must keep its native attachment stable, and hide
-- pages without descriptions through alpha rather than a null frame handle.
function BlzFrameGetChildrenCount() return 0 end
function BlzFrameSetTooltip(button,tooltip)
    assert(tooltip~=nil,'Never pass a null tooltip frame to Warcraft')
    assert(button.tooltip==nil,'Do not rebind an initialized native tooltip')
    button.tooltip=tooltip
end
function BlzFrameSetAlpha(frame,alpha) frame.alpha=alpha end
UI.activityBriefingButtons={{},{},{}}
UI.activityBriefingChoiceArtwork={{},{},{}}
UI.activityBriefingChoiceTooltips={{},{},{}}
UI.activityBriefingChoiceTooltipUpdates={}
for index=1,3 do
    BlzFrameSetTooltip(UI.activityBriefingButtons[index],UI.activityBriefingChoiceTooltips[index])
    UI.activityBriefingChoiceTooltipUpdates[index]=function(text)
        UI.activityBriefingChoiceTooltips[index].text=text
    end
end
UI.ShowActivityBriefing({choices={{label='One Minute',tooltip='Timed practice'},
    {label='Unlimited',tooltip='Unlimited practice'},{label='Build Order',tooltip='Build practice'}}})
for index,button in ipairs(UI.activityBriefingButtons) do
    assert(button.tooltip==UI.activityBriefingChoiceTooltips[index])
    assert(button.tooltip.alpha==255)
    assert(button.tooltip.text:find('practice',1,true))
end
UI.ShowActivityBriefing({choices={{label='Human'},{label='Orc'}}})
for _,button in ipairs(UI.activityBriefingButtons) do assert(button.tooltip.alpha==0) end
UI.ShowActivityBriefing({choices={{label='One Minute',tooltip='Timed practice'},
    {label='Unlimited',tooltip='Unlimited practice'},{label='Build Order',tooltip='Build practice'}}})
for _,button in ipairs(UI.activityBriefingButtons) do assert(button.tooltip.alpha==255) end
print('Passed: rectangular choice tooltips retain native attachments through repeated race/mode page transitions.')
print('Passed: category headings, shared briefing/catalogue navigation, GO/status/result hiding and resume with an independent exercise pause.')
