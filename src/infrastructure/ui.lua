-- Permanent map-owned menu and shared activity controls.
JTG = JTG or {}
JTG.UI = {
    panels = {}, categoryButtons = {}, catalogueRows = {}, toolbarButtons = {},
    clickActions = {}, clickTrigger = nil, browsingActivity = false,
}

local UI = JTG.UI
local GAME_UI = nil
local MENU_WIDTH = 0.64
local MENU_HEIGHT = 0.47
local tooltipCount = 0
local keyboardFocusSink = nil
local nativePanelContext = 100
local TITLE_WIDTH = 0.54
local TITLE_HEIGHT = 0.045
local TITLE_SCALE = 1.55
local TITLE_TOP_OFFSET = -0.010
local PARAGRAPH_SCALE = 1.18
local CATALOGUE_BUTTON_WIDTH = 0.190
local CATALOGUE_BUTTON_HEIGHT = 0.052
local FOOTER_BUTTON_WIDTH = 0.17
local FOOTER_BUTTON_HEIGHT = 0.044

local function CreateNativePanel(name, parent, width, height)
    local panel = BlzCreateFrameByType("FRAME", name, parent, "", 0)
    BlzFrameSetSize(panel, width, height)
    nativePanelContext = nativePanelContext + 1
    local skin = BlzCreateFrame("EscMenuBackdrop", panel, 0, nativePanelContext)
    BlzFrameClearAllPoints(skin)
    BlzFrameSetPoint(skin, FRAMEPOINT_TOPLEFT, panel, FRAMEPOINT_TOPLEFT, 0, 0)
    BlzFrameSetPoint(skin, FRAMEPOINT_BOTTOMRIGHT, panel, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
    BlzFrameSetEnable(skin, false)
    return panel
end

UI.CreateNativePanel = CreateNativePanel

local function CreateText(name, parent, text, width, height, scale)
    local frame = BlzCreateFrameByType("TEXT", name, parent, "", 0)
    BlzFrameSetSize(frame, width, height)
    BlzFrameSetText(frame, text)
    BlzFrameSetTextAlignment(frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
    BlzFrameSetScale(frame, scale or 1.0)
    return frame
end

local function CreateButton(name, parent, text, width, height)
    local button = BlzCreateFrameByType("GLUETEXTBUTTON", name, parent, "ScriptDialogButton", 0)
    BlzFrameSetSize(button, width, height)
    BlzFrameSetText(button, text)
    return button
end

local function BriefingChoicePoint(index, count)
    if count <= 2 then
        return index == 1 and -0.108 or 0.108, -0.305
    end
    if count <= 4 then
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        return column == 0 and -0.108 or 0.108, -0.278 - row * 0.050
    end
    local column = (index - 1) % 3
    local row = math.floor((index - 1) / 3)
    return -0.190 + column * 0.190, -0.278 - row * 0.050
end

local function FindButtonText(button)
    for index = 0, BlzFrameGetChildrenCount(button) - 1 do
        local child = BlzFrameGetChild(button, index)
        if BlzFrameGetName(child) == "ScriptDialogButtonText" then return child end
    end
    if BlzFrameGetChildrenCount(button) > 4 then
        return BlzFrameGetChild(button, 4)
    end
    return nil
end

local function CreateIllustratedCard(name, parent, descriptor, width, height, artWidth, artHeight,
        labelWidth, labelScale, leftInset)
    local isAvailable = descriptor.status == "available"
    local status = isAvailable and "" or "\n|cffaaaaaaPLANNED|r"
    local button = CreateButton(name, parent,
        "|cffffcc00" .. descriptor.title .. "|r" .. status, width, height)
    local art = BlzCreateFrameByType("BACKDROP", name .. "Artwork", button, "", 0)
    BlzFrameSetTexture(art, descriptor.artwork, 0, true)
    BlzFrameSetSize(art, artWidth, artHeight)
    BlzFrameSetPoint(art, FRAMEPOINT_RIGHT, button, FRAMEPOINT_RIGHT, -0.004, 0)
    BlzFrameSetEnable(art, false)

    local label = FindButtonText(button)
    if label ~= nil then
        BlzFrameClearAllPoints(label)
        BlzFrameSetSize(label, labelWidth, height - 0.012)
        BlzFrameSetTextAlignment(label, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
        BlzFrameSetScale(label, labelScale)
        BlzFrameSetPoint(label, FRAMEPOINT_LEFT, button, FRAMEPOINT_LEFT, leftInset, 0)
    end

    return button, button
end

local function CreateIllustratedActivityCard(name, parent, descriptor)
    return CreateIllustratedCard(name, parent, descriptor,
        CATALOGUE_BUTTON_WIDTH, CATALOGUE_BUTTON_HEIGHT,
        0.098, 0.048, 0.082, 0.72, 0.012)
end

local function CreateIllustratedCategoryCard(name, parent, category)
    local descriptor = {
        title = category.title,
        artwork = category.artwork,
        status = "available",
    }
    return CreateIllustratedCard(name, parent, descriptor,
        0.25, 0.055, 0.125, 0.051, 0.104, 0.88, 0.020)
end

local function TooltipHeight(description)
    local lines = 0
    for line in string.gmatch(description .. "\n", "([^\n]*)\n") do
        -- Warcraft's stock tooltip text uses nearly the full interior width.
        -- This estimate only chooses the box height; the engine still performs
        -- the actual word wrapping according to the rendered font metrics.
        lines = lines + math.max(1, math.ceil(string.len(line) / 54))
    end
    return math.max(0.030, 0.012 + lines * 0.010)
end

local function CreateTooltipSlice(name, parent, texture, width, height, point)
    local slice = BlzCreateFrameByType("BACKDROP", name, parent, "", 0)
    BlzFrameSetTexture(slice, texture, 0, true)
    BlzFrameSetSize(slice, width, height)
    BlzFrameSetPoint(slice, point, parent, point, 0, 0)
    BlzFrameSetEnable(slice, false)
    return slice
end

local function AttachTooltip(button, description, side)
    tooltipCount = tooltipCount + 1
    local tooltip = BlzCreateFrameByType("FRAME", "JTGTooltip" .. tooltipCount,
        GAME_UI, "", 0)
    local width = 0.235
    local height = TooltipHeight(description)
    BlzFrameSetSize(tooltip, width, height)
    BlzFrameSetAbsPoint(tooltip, FRAMEPOINT_BOTTOMRIGHT, 0.728, 0.135)
    BlzFrameSetLevel(tooltip, 100)

    local corner = 0.008
    local innerWidth = width - corner * 2
    local innerHeight = height - corner * 2
    local prefix = "JTGTooltipSlice" .. tooltipCount
    CreateTooltipSlice(prefix .. "TL", tooltip, "JTGMenu\\TooltipTL.dds",
        corner, corner, FRAMEPOINT_TOPLEFT)
    CreateTooltipSlice(prefix .. "Top", tooltip, "JTGMenu\\TooltipTop.dds",
        innerWidth, corner, FRAMEPOINT_TOP)
    CreateTooltipSlice(prefix .. "TR", tooltip, "JTGMenu\\TooltipTR.dds",
        corner, corner, FRAMEPOINT_TOPRIGHT)
    CreateTooltipSlice(prefix .. "Left", tooltip, "JTGMenu\\TooltipLeft.dds",
        corner, innerHeight, FRAMEPOINT_LEFT)
    CreateTooltipSlice(prefix .. "Center", tooltip, "JTGMenu\\TooltipCenter.dds",
        innerWidth, innerHeight, FRAMEPOINT_CENTER)
    CreateTooltipSlice(prefix .. "Right", tooltip, "JTGMenu\\TooltipRight.dds",
        corner, innerHeight, FRAMEPOINT_RIGHT)
    CreateTooltipSlice(prefix .. "BL", tooltip, "JTGMenu\\TooltipBL.dds",
        corner, corner, FRAMEPOINT_BOTTOMLEFT)
    CreateTooltipSlice(prefix .. "Bottom", tooltip, "JTGMenu\\TooltipBottom.dds",
        innerWidth, corner, FRAMEPOINT_BOTTOM)
    CreateTooltipSlice(prefix .. "BR", tooltip, "JTGMenu\\TooltipBR.dds",
        corner, corner, FRAMEPOINT_BOTTOMRIGHT)

    -- BlzFrameSetScale scales the text frame's geometry as well as its glyphs.
    -- Compensate the declared size so the rendered text reaches the same inner
    -- right edge as a stock Warcraft tooltip.
    local tooltipTextScale = 0.95
    local label = CreateText("JTGTooltipText" .. tooltipCount, tooltip,
        description, 0.223 / tooltipTextScale,
        (height - 0.012) / tooltipTextScale, tooltipTextScale)
    BlzFrameSetTextAlignment(label, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetPoint(label, FRAMEPOINT_TOPLEFT, tooltip, FRAMEPOINT_TOPLEFT, 0.006, -0.006)
    BlzFrameSetVisible(tooltip, false)
    BlzFrameSetTooltip(button, tooltip)
    return tooltip, label
end

local function ReleaseKeyboardFocus()
    if keyboardFocusSink == nil then
        keyboardFocusSink = BlzCreateFrameByType("EDITBOX", "JTGKeyboardFocusSink",
            GAME_UI, "", 0)
        BlzFrameSetSize(keyboardFocusSink, 0.001, 0.001)
        BlzFrameSetAbsPoint(keyboardFocusSink, FRAMEPOINT_BOTTOMLEFT, 0.001, 0.001)
        BlzFrameSetVisible(keyboardFocusSink, false)
    end
    if GetLocalPlayer() == Player(0) then
        BlzFrameSetVisible(keyboardFocusSink, true)
        BlzFrameSetEnable(keyboardFocusSink, true)
        BlzFrameSetFocus(keyboardFocusSink, true)
        BlzFrameSetFocus(keyboardFocusSink, false)
        BlzFrameSetEnable(keyboardFocusSink, false)
        BlzFrameSetVisible(keyboardFocusSink, false)
    end
end

local function RegisterClick(frame, action)
    UI.clickActions[GetHandleId(frame)] = action
    BlzTriggerRegisterFrameEvent(UI.clickTrigger, frame, FRAMEEVENT_CONTROL_CLICK)
end

local function PositionTop(frame)
    BlzFrameClearAllPoints(frame)
    BlzFrameSetAbsPoint(frame, FRAMEPOINT_TOP, 0.40, 0.555)
end

local function SetRootActivityFooter(active)
    if UI.rootCredits ~= nil then BlzFrameSetVisible(UI.rootCredits, not active) end
    if UI.rootPatch ~= nil then BlzFrameSetVisible(UI.rootPatch, not active) end
    if UI.rootActivityBack ~= nil then BlzFrameSetVisible(UI.rootActivityBack, active) end
end


function UI.IsActivityBriefingOpen()
    return UI.panels.activityBriefing ~= nil and
        BlzFrameIsVisible(UI.panels.activityBriefing)
end

function UI.OnActivityExitedInMenu(restoreBriefing)
    if UI.pausedActivityExit ~= nil then BlzFrameSetVisible(UI.pausedActivityExit, false) end
    if UI.pausedActivityResume ~= nil then BlzFrameSetVisible(UI.pausedActivityResume, false) end
    if UI.activityBriefingExit ~= nil then BlzFrameSetVisible(UI.activityBriefingExit, false) end
    if UI.activityBriefingResume ~= nil then BlzFrameSetVisible(UI.activityBriefingResume, false) end
    SetRootActivityFooter(false)
    if restoreBriefing and UI.panels.activityBriefing ~= nil then
        BlzFrameSetVisible(UI.panels.activityBriefing, true)
        UI.menuVisible = true
    end
end

function UI.HideAllPanels()
    for _, panel in pairs(UI.panels) do BlzFrameSetVisible(panel, false) end
    UI.menuVisible = false
    UI.currentBackAction = nil
end

function UI.HideToolbar()
    UI.browsingActivity = false
    if UI.toolbar then BlzFrameSetVisible(UI.toolbar, false) end
    if UI.pausedActivityResume then BlzFrameSetVisible(UI.pausedActivityResume, false) end
    if UI.pausedActivityExit then BlzFrameSetVisible(UI.pausedActivityExit, false) end
end

function UI.ShowRoot()
    UI.HideAllPanels()
    if UI.gameplayMenuPaused then UI.ShowPausedActivityToolbar()
    elseif not UI.browsingActivity then UI.HideToolbar() end
    BlzFrameSetVisible(UI.panels.root, true)
    SetRootActivityFooter(UI.gameplayMenuPaused == true)
    UI.menuVisible = true
    if UI.gameplayMenuPaused then
        UI.currentBackAction = function() UI.ShowCategory(JTG.Controller.lastCategory) end
    end
end

function UI.ShowCategory(categoryId)
    UI.HideAllPanels()
    if UI.gameplayMenuPaused then UI.ShowPausedActivityToolbar()
    elseif not UI.browsingActivity then UI.HideToolbar() end
    local panel = UI.panels["category_" .. categoryId]
    if panel then
        BlzFrameSetVisible(panel, true)
        UI.menuVisible = true
        UI.currentBackAction = UI.ShowRoot
    else UI.ShowRoot() end
end

function UI.ShowInfo(which)
    UI.HideAllPanels()
    if UI.gameplayMenuPaused then UI.ShowPausedActivityToolbar()
    elseif not UI.browsingActivity then UI.HideToolbar() end
    BlzFrameSetVisible(UI.panels[which], true)
    UI.menuVisible = true
    UI.currentBackAction = UI.ShowRoot
end

function UI.ShowToolbar(capabilities)
    local caps = capabilities or {}
    UI.browsingActivity = false
    if UI.pausedActivityResume then BlzFrameSetVisible(UI.pausedActivityResume, false) end
    if UI.pausedActivityExit then BlzFrameSetVisible(UI.pausedActivityExit, false) end
    BlzFrameSetText(UI.toolbarButtons.restart, "Redo")
    BlzFrameSetText(UI.toolbarButtons.menu, "Menu")
    UI.clickActions[GetHandleId(UI.toolbarButtons.menu)] = JTG.OpenTrainingMenu
    BlzFrameSetVisible(UI.toolbarButtons.restart, caps.restart == true)
    BlzFrameSetVisible(UI.toolbarButtons.menu, caps.menu ~= false)
    BlzFrameSetVisible(UI.toolbar, true)
end

function UI.ShowPausedActivityToolbar()
    if UI.toolbar == nil then return end
    UI.browsingActivity = false
    BlzFrameSetVisible(UI.toolbar, false)
    BlzFrameSetVisible(UI.pausedActivityResume, true)
    BlzFrameSetVisible(UI.pausedActivityExit, true)
end

function UI.SetRestartText(text)
    if UI.toolbarButtons.restart ~= nil then
        BlzFrameSetText(UI.toolbarButtons.restart, text or "Restart")
    end
end

function UI.ShowActivityMenu(categoryId)
    UI.browsingActivity = true
    UI.ShowCategory(categoryId)
    BlzFrameSetVisible(UI.toolbarButtons.restart, false)
    BlzFrameSetText(UI.toolbarButtons.menu, "Return to Training")
    BlzFrameSetVisible(UI.toolbarButtons.menu, true)
    BlzFrameSetVisible(UI.toolbar, true)
end

function UI.HideActivityBriefing()
    local panel = UI.panels.activityBriefing
    if panel ~= nil then BlzFrameSetVisible(panel, false) end
    if UI.activityBriefingResume ~= nil then BlzFrameSetVisible(UI.activityBriefingResume, false) end
end

function UI.ShowActivityBriefing(spec)
    local panel = UI.panels.activityBriefing
    if panel == nil then return end
    UI.SetGameplayMenuPaused(spec.pauseGame == true)
    UI.HideAllPanels()
    UI.HideToolbar()
    BlzFrameSetText(UI.activityBriefingTitle, "|cffffcc00" .. (spec.title or "") .. "|r")
    BlzFrameSetText(UI.activityBriefingBody, spec.body or "")
    BlzFrameSetVisible(UI.activityBriefingArtwork, spec.headingArtwork ~= nil)
    if spec.headingArtwork ~= nil then
        BlzFrameSetTexture(UI.activityBriefingArtwork, spec.headingArtwork, 0, true)
    end
    UI.activityBriefingActions = spec.choices or {}
    local choiceCount = #UI.activityBriefingActions
    for index, button in ipairs(UI.activityBriefingButtons) do
        local choice = UI.activityBriefingActions[index]
        BlzFrameSetVisible(button, choice ~= nil)
        if choice ~= nil then
            local x, y = BriefingChoicePoint(index, choiceCount)
            BlzFrameClearAllPoints(button)
            BlzFrameSetPoint(button, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, x, y)
            BlzFrameSetText(button, choice.label)
            local color = choice.primary and BlzConvertColor(255, 255, 204, 0) or
                BlzConvertColor(255, 255, 255, 255)
            BlzFrameSetTextColor(button, color)
            if UI.activityBriefingTooltipText[index] ~= nil then
                BlzFrameSetText(UI.activityBriefingTooltipText[index], choice.tooltip or "")
            end
        end
    end
    UI.activityBriefingBackAction = spec.backAction
    BlzFrameSetTextColor(UI.activityBriefingBack, BlzConvertColor(255, 255, 255, 255))
    UI.activityBriefingResumeAction = spec.resumeAction
    UI.activityBriefingExitAction = spec.exitAction or JTG.ExitActivityFromMenu
    BlzFrameSetVisible(UI.activityBriefingResume, spec.resumeAction ~= nil)
    BlzFrameSetVisible(UI.activityBriefingExit, spec.resumeAction ~= nil)
    BlzFrameSetVisible(panel, true)
    UI.menuVisible = true
    UI.currentBackAction = spec.backAction
end

function UI.SetGameplayMenuPaused(paused)
    local nextState = paused == true
    if UI.gameplayMenuPaused == nextState then return end
    UI.gameplayMenuPaused = nextState
    PauseGame(nextState or UI.exercisePaused)
    -- Pause the simulation without placing an extra dimmed layer over the map.
    if UI.menuShade ~= nil then BlzFrameSetVisible(UI.menuShade, false) end
end

function UI.ReleaseGameplayControl()
    UI.gameplayMenuPaused = false
    UI.exercisePaused = false
    PauseGame(false)
    if UI.menuShade ~= nil then BlzFrameSetVisible(UI.menuShade, false) end
    if UI.toolbarButtons.pause ~= nil then
        BlzFrameSetText(UI.toolbarButtons.pause, "Pause")
        BlzFrameSetTextColor(UI.toolbarButtons.pause, BlzConvertColor(255, 255, 204, 0))
    end
    ReleaseKeyboardFocus()
end

function UI.SetExercisePaused(paused)
    local nextState = paused == true
    UI.exercisePaused = nextState
    PauseGame(nextState or UI.gameplayMenuPaused)
    BlzFrameSetText(UI.toolbarButtons.pause, nextState and "Unpause" or "Pause")
    BlzFrameSetTextColor(UI.toolbarButtons.pause, nextState and
        BlzConvertColor(255, 255, 255, 255) or BlzConvertColor(255, 255, 204, 0))
end

function UI.ToggleExercisePause()
    UI.SetExercisePaused(not UI.exercisePaused)
end

local function CreateRootPanel()
    local panel = CreateNativePanel("JTGRootPanel", GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    UI.panels.root = panel

    local title = CreateText("JTGRootTitle", panel, "|cffffcc00Jamie's Training Grounds|r",
        TITLE_WIDTH, TITLE_HEIGHT, TITLE_SCALE)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, TITLE_TOP_OFFSET)
    local subtitle = CreateText("JTGRootSubtitle", panel,
        "Choose what you want to learn or practice.",
        0.54 / PARAGRAPH_SCALE, 0.028 / PARAGRAPH_SCALE, PARAGRAPH_SCALE)

    local positions = {{-0.145, -0.125}, {0.145, -0.125}, {-0.145, -0.205}, {0.145, -0.205}}
    local firstCategoryButton = nil
    for index, category in ipairs(JTG.Categories) do
        local _, button = CreateIllustratedCategoryCard("JTGCategory" .. index, panel, category)
        BlzFrameSetPoint(button, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, positions[index][1], positions[index][2])
        if firstCategoryButton == nil then firstCategoryButton = button end
        UI.categoryButtons[category.id] = button
        AttachTooltip(button, category.summary, index % 2 == 0 and "left" or "right")
        RegisterClick(button, function() UI.ShowCategory(category.id) end)
    end
    BlzFrameClearAllPoints(subtitle)
    BlzFrameSetPoint(subtitle, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, 0)
    BlzFrameSetPoint(subtitle, FRAMEPOINT_BOTTOM, firstCategoryButton, FRAMEPOINT_TOP, 0, 0)

    local patch = CreateButton("JTGPatchNotes", panel, "Patch Notes",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(patch, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(patch, function() UI.ShowInfo("patch") end)
    UI.rootPatch = patch
    local credits = CreateButton("JTGCredits", panel, "Credits",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(credits, FRAMEPOINT_BOTTOMLEFT, panel, FRAMEPOINT_BOTTOMLEFT, 0.045, 0.035)
    RegisterClick(credits, function() UI.ShowInfo("credits") end)
    UI.rootCredits = credits

    local activeBack = CreateButton("JTGRootActivityBack", panel, "Back",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(activeBack, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(activeBack, function() UI.ShowCategory(JTG.Controller.lastCategory) end)
    BlzFrameSetVisible(activeBack, false)
    UI.rootActivityBack = activeBack
end

local function CreateCategoryPanel(category, categoryIndex)
    local panel = CreateNativePanel("JTGCategoryPanel" .. categoryIndex, GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    UI.panels["category_" .. category.id] = panel
    BlzFrameSetVisible(panel, false)

    local title = CreateText("JTGCategoryTitle" .. categoryIndex, panel,
        "|cffffcc00" .. category.title .. "|r", TITLE_WIDTH, TITLE_HEIGHT, TITLE_SCALE)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, TITLE_TOP_OFFSET)
    local summary = CreateText("JTGCategorySummary" .. categoryIndex, panel, category.summary,
        0.54 / PARAGRAPH_SCALE, 0.025 / PARAGRAPH_SCALE, PARAGRAPH_SCALE)

    local activities = JTG.GetActivities(category.id)
    local maxRows = 5
    local firstActivityFrame = nil
    for index, descriptor in ipairs(activities) do
        local column = math.floor((index - 1) / maxRows)
        local row = (index - 1) % maxRows
        local name = "JTGActivity" .. categoryIndex .. "x" .. index
        local frame
        local button
        if descriptor.artwork ~= nil then
            frame, button = CreateIllustratedActivityCard(name, panel, descriptor)
        else
            local label = descriptor.title
            if descriptor.status ~= "available" then
                label = label .. "  |cff808080[Planned]|r"
            end
            button = CreateButton(name, panel,
                label, CATALOGUE_BUTTON_WIDTH, CATALOGUE_BUTTON_HEIGHT)
            frame = button
        end
        BlzFrameSetPoint(frame, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP,
            -0.192 + column * 0.192, -0.100 - row * 0.055)
        if firstActivityFrame == nil then firstActivityFrame = frame end
        if descriptor.status ~= "available" then
            BlzFrameSetEnable(button, false)
            BlzFrameSetAlpha(button, 145)
            BlzFrameSetTextColor(button, BlzConvertColor(255, 145, 145, 145))
        else
            AttachTooltip(button, descriptor.description, column >= 2 and "left" or "right")
            RegisterClick(button, function()
                if descriptor.menu ~= nil then JTG.OpenActivityMenu(descriptor.id, category.id)
                else JTG.StartActivity(descriptor.id, category.id) end
            end)
        end
        UI.catalogueRows[descriptor.id] = button
    end
    if firstActivityFrame ~= nil then
        BlzFrameClearAllPoints(summary)
        BlzFrameSetPoint(summary, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, 0)
        BlzFrameSetPoint(summary, FRAMEPOINT_BOTTOM, firstActivityFrame, FRAMEPOINT_TOP, 0, 0)
    end

    local back = CreateButton("JTGCategoryBack" .. categoryIndex, panel, "Back",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, UI.ShowRoot)
end

local function CreateInfoPanel(key, titleText, bodyText, index, scrollable)
    local panel = CreateNativePanel("JTGInfoPanel" .. index, GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    UI.panels[key] = panel
    BlzFrameSetVisible(panel, false)
    local title = CreateText("JTGInfoTitle" .. index, panel, "|cffffcc00" .. titleText .. "|r",
        TITLE_WIDTH, TITLE_HEIGHT, TITLE_SCALE)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, TITLE_TOP_OFFSET)
    local body
    if scrollable then
        body = BlzCreateFrame("EscMenuTextAreaTemplate", panel, 0, index)
        BlzFrameSetSize(body, 0.52 / PARAGRAPH_SCALE, 0.30 / PARAGRAPH_SCALE)
        BlzFrameSetScale(body, PARAGRAPH_SCALE)
        BlzFrameSetText(body, bodyText)
        BlzFrameSetPoint(body, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, -0.025)
    else
        body = CreateText("JTGInfoBody" .. index, panel, bodyText,
            0.52 / PARAGRAPH_SCALE, 0.30 / PARAGRAPH_SCALE, PARAGRAPH_SCALE)
        BlzFrameSetTextAlignment(body, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
        BlzFrameSetPoint(body, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, -0.025)
    end
    local back = CreateButton("JTGInfoBack" .. index, panel, "Back",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, UI.ShowRoot)
end

local function CreateActivityBriefingPanel()
    local panel = CreateNativePanel("JTGActivityBriefing", GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    UI.panels.activityBriefing = panel
    BlzFrameSetVisible(panel, false)

    UI.activityBriefingTitle = CreateText("JTGActivityBriefingTitle", panel, "",
        TITLE_WIDTH, TITLE_HEIGHT, TITLE_SCALE)
    BlzFrameSetPoint(UI.activityBriefingTitle, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP,
        0, TITLE_TOP_OFFSET)
    UI.activityBriefingArtwork = BlzCreateFrameByType("BACKDROP", "JTGActivityBriefingArtwork", panel, "", 0)
    BlzFrameSetSize(UI.activityBriefingArtwork, 0.200, 0.098)
    BlzFrameSetPoint(UI.activityBriefingArtwork, FRAMEPOINT_TOPRIGHT, panel, FRAMEPOINT_TOPRIGHT, -0.065, -0.025)
    BlzFrameSetEnable(UI.activityBriefingArtwork, false)
    BlzFrameSetVisible(UI.activityBriefingArtwork, false)
    UI.activityBriefingBody = CreateText("JTGActivityBriefingBody", panel, "",
        0.53 / PARAGRAPH_SCALE, 0.205 / PARAGRAPH_SCALE, PARAGRAPH_SCALE)
    BlzFrameSetTextAlignment(UI.activityBriefingBody, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetPoint(UI.activityBriefingBody, FRAMEPOINT_TOP, UI.activityBriefingTitle, FRAMEPOINT_BOTTOM, 0, -0.022)

    UI.activityBriefingButtons = {}
    UI.activityBriefingTooltipText = {}
    for index = 1, 6 do
        local button = CreateButton("JTGActivityBriefingChoice" .. index, panel, "", 0.190, 0.042)
        BlzFrameSetPoint(button, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, -0.305)
        UI.activityBriefingButtons[index] = button
        RegisterClick(button, function()
            local choice = UI.activityBriefingActions and UI.activityBriefingActions[index]
            if choice ~= nil and choice.action ~= nil then choice.action() end
        end)
    end

    local back = CreateButton("JTGActivityBriefingBack", panel, "Back",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, function()
        if UI.activityBriefingBackAction ~= nil then UI.activityBriefingBackAction() end
    end)
    UI.activityBriefingBack = back

    local exit = CreateButton("JTGActivityBriefingExit", panel, "Exit",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(exit, FRAMEPOINT_BOTTOMLEFT, panel, FRAMEPOINT_BOTTOMLEFT, 0.045, 0.035)
    BlzFrameSetTextColor(exit, BlzConvertColor(255, 255, 255, 255))
    RegisterClick(exit, function()
        if UI.activityBriefingExitAction ~= nil then UI.activityBriefingExitAction() end
    end)
    UI.activityBriefingExit = exit
    BlzFrameSetVisible(exit, false)

    local resume = CreateButton("JTGActivityBriefingResume", panel, "Resume",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(resume, FRAMEPOINT_BOTTOMRIGHT, panel, FRAMEPOINT_BOTTOMRIGHT, -0.045, 0.035)
    BlzFrameSetTextColor(resume, BlzConvertColor(255, 255, 255, 255))
    RegisterClick(resume, function()
        if UI.activityBriefingResumeAction ~= nil then UI.activityBriefingResumeAction() end
    end)
    UI.activityBriefingResume = resume
    BlzFrameSetVisible(resume, false)
end

local function CreateMenuShade()
    local shade = BlzCreateFrameByType("BACKDROP", "JTGMenuShade", GAME_UI, "", 0)
    BlzFrameSetTexture(shade, "UI\\Widgets\\EscMenu\\Human\\human-options-menu-background.blp", 0, true)
    BlzFrameSetSize(shade, 0.80, 0.60)
    BlzFrameSetAbsPoint(shade, FRAMEPOINT_CENTER, 0.40, 0.30)
    BlzFrameSetEnable(shade, false)
    BlzFrameSetVertexColor(shade, BlzConvertColor(145, 30, 30, 30))
    BlzFrameSetVisible(shade, false)
    UI.menuShade = shade
end

local function CreateToolbar()
    local bar = BlzCreateFrameByType("FRAME", "JTGActivityToolbar", GAME_UI, "", 0)
    -- Match the compact native system-button row and sit directly beneath the
    -- resource gauges on the right side of the upper interface.
    BlzFrameSetSize(bar, 0.286, 0.030)
    BlzFrameSetAbsPoint(bar, FRAMEPOINT_TOPRIGHT, 0.79, 0.575)
    UI.toolbar = bar

    local function toolbarButton(name, label, width)
        local button = CreateButton(name, bar, label, width, 0.024)
        local text = FindButtonText(button)
        if text ~= nil then BlzFrameSetScale(text, 0.72) end
        return button
    end

    local restart = toolbarButton("JTGToolbarRestart", "Redo", 0.062)
    BlzFrameSetPoint(restart, FRAMEPOINT_LEFT, bar, FRAMEPOINT_LEFT, 0.004, 0)
    AttachTooltip(restart, "Cleanly reset the current activity and begin it again.", "left")
    RegisterClick(restart, JTG.ResetActivity)
    UI.toolbarButtons.restart = restart
    local menu = toolbarButton("JTGToolbarMenu", "Menu", 0.062)
    BlzFrameSetPoint(menu, FRAMEPOINT_LEFT, restart, FRAMEPOINT_RIGHT, 0.004, 0)
    AttachTooltip(menu, "Change this exercise's configuration or return to the training menus.", "left")
    RegisterClick(menu, JTG.OpenTrainingMenu)
    UI.toolbarButtons.menu = menu

    local lastRunner = toolbarButton("JTGToolbarLastRunner", "Last Runner", 0.078)
    BlzFrameSetPoint(lastRunner, FRAMEPOINT_LEFT, menu, FRAMEPOINT_RIGHT, 0.004, 0)
    BlzFrameSetEnable(lastRunner, false)
    BlzFrameSetAlpha(lastRunner, 145)
    UI.toolbarButtons.lastRunner = lastRunner

    local pause = toolbarButton("JTGToolbarPause", "Pause", 0.058)
    BlzFrameSetPoint(pause, FRAMEPOINT_LEFT, lastRunner, FRAMEPOINT_RIGHT, 0.004, 0)
    RegisterClick(pause, UI.ToggleExercisePause)
    UI.toolbarButtons.pause = pause
    BlzFrameSetVisible(bar, false)
end

local function CreatePausedActivityResume()
    local exit = CreateButton("JTGPausedActivityExit", GAME_UI, "Exit",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetAbsPoint(exit, FRAMEPOINT_BOTTOMLEFT, 0.125, 0.120)
    BlzFrameSetTextColor(exit, BlzConvertColor(255, 255, 255, 255))
    RegisterClick(exit, JTG.ExitActivityFromMenu)
    BlzFrameSetVisible(exit, false)
    UI.pausedActivityExit = exit

    local resume = CreateButton("JTGPausedActivityResume", GAME_UI, "Resume",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetAbsPoint(resume, FRAMEPOINT_BOTTOMRIGHT, 0.675, 0.120)
    BlzFrameSetTextColor(resume, BlzConvertColor(255, 255, 255, 255))
    RegisterClick(resume, JTG.ResumeActivity)
    BlzFrameSetVisible(resume, false)
    UI.pausedActivityResume = resume
end

function UI.Initialize()
    GAME_UI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    UI.clickTrigger = CreateTrigger()
    TriggerAddAction(UI.clickTrigger, function()
        local action = UI.clickActions[GetHandleId(BlzGetTriggerFrame())]
        if action ~= nil then
            if UI.gameplayMenuPaused or UI.exercisePaused then
                action()
                return
            end
            local releaseTimer = CreateTimer()
            TimerStart(releaseTimer, 0.00, false, function()
                DestroyTimer(releaseTimer)
                action()
                local focusTimer = CreateTimer()
                TimerStart(focusTimer, 0.05, false, function()
                    DestroyTimer(focusTimer)
                    ReleaseKeyboardFocus()
                end)
            end)
        end
    end)
    UI.escapeTrigger = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(UI.escapeTrigger, Player(0), OSKEY_ESCAPE, 0, true)
    TriggerAddAction(UI.escapeTrigger, function()
        if UI.menuVisible and UI.currentBackAction ~= nil then
            UI.currentBackAction()
        end
    end)
    CreateMenuShade()
    CreateRootPanel()
    for index, category in ipairs(JTG.Categories) do CreateCategoryPanel(category, index) end
    CreateInfoPanel("patch", "Patch Notes",
        "|cffffcc00v0.0.2-alpha.31|r  |cffb0b0b025 September 2026|r\n" ..
        "- Added the four-category Training Grounds menu, illustrated cards, tooltips, Patch Notes and Credits.\n" ..
        "- Added modular activity lifecycle support with shared Restart, Training Menu and complete state cleanup.\n\n" ..
        "|cffffcc00v0.0.1-alpha.5|r  |cffb0b0b024 September 2026|r\n" ..
        "- Established the playable Twisted Meadows foundation with two reusable training arenas.\n" ..
        "- Preserved the native interface, race selection and fog while adding separate preview and loading artwork.", 1, true)
    CreateInfoPanel("credits", "Credits",
        "Project started by |cffffcc00Jamie|r and currently run by |cffffcc00Solanum|r.\n\n" ..
        "Contributors: AoW, poison, floss2xdaily, Kaccel, MadPad09 and Solstice1221.\n\n" ..
        "Map adapted from Twisted Meadows by McCandish, MMC and W3Champions.\n\n" ..
        "Warcraft III belongs to Blizzard Entertainment.", 2)
    CreateActivityBriefingPanel()
    CreateToolbar()
    CreatePausedActivityResume()
    UI.ShowRoot()
end
