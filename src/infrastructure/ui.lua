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

local function CreateBackdrop(name, parent, width, height)
    local frame = BlzCreateFrameByType("BACKDROP", name, parent, "", 0)
    BlzFrameSetTexture(frame, "JTGMenu\\MenuBackdrop.dds", 0, true)
    BlzFrameSetSize(frame, width, height)
    return frame
end

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

local function CreateIllustratedActivityCard(name, parent, descriptor)
    local button = CreateButton(name, parent,
        "|cffffcc00" .. descriptor.title .. "|r\n|cffaaaaaaPLANNED|r", 0.190, 0.052)
    local art = BlzCreateFrameByType("BACKDROP", name .. "Artwork", button, "", 0)
    BlzFrameSetTexture(art, descriptor.artwork, 0, true)
    BlzFrameSetSize(art, 0.098, 0.048)
    BlzFrameSetPoint(art, FRAMEPOINT_RIGHT, button, FRAMEPOINT_RIGHT, -0.004, 0)
    BlzFrameSetEnable(art, false)

    local label = FindButtonText(button)
    if label ~= nil then
        BlzFrameClearAllPoints(label)
        BlzFrameSetSize(label, 0.082, 0.040)
        BlzFrameSetTextAlignment(label, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
        BlzFrameSetScale(label, 0.72)
        BlzFrameSetPoint(label, FRAMEPOINT_LEFT, button, FRAMEPOINT_LEFT, 0.012, 0)
    end

    return button, button
end

local function TooltipHeight(description)
    local lines = 0
    for line in string.gmatch(description .. "\n", "([^\n]*)\n") do
        lines = lines + math.max(1, math.ceil(string.len(line) / 42))
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

    local label = CreateText("JTGTooltipText" .. tooltipCount, tooltip,
        description, 0.215, height - 0.012, 0.80)
    BlzFrameSetTextAlignment(label, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
    BlzFrameSetPoint(label, FRAMEPOINT_TOPLEFT, tooltip, FRAMEPOINT_TOPLEFT, 0.010, -0.006)
    BlzFrameSetVisible(tooltip, false)
    BlzFrameSetTooltip(button, tooltip)
    return tooltip
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

function UI.HideAllPanels()
    for _, panel in pairs(UI.panels) do BlzFrameSetVisible(panel, false) end
end

function UI.HideToolbar()
    UI.browsingActivity = false
    if UI.toolbar then BlzFrameSetVisible(UI.toolbar, false) end
end

function UI.ShowRoot()
    UI.HideAllPanels()
    if not UI.browsingActivity then UI.HideToolbar() end
    BlzFrameSetVisible(UI.panels.root, true)
end

function UI.ShowCategory(categoryId)
    UI.HideAllPanels()
    if not UI.browsingActivity then UI.HideToolbar() end
    local panel = UI.panels["category_" .. categoryId]
    if panel then BlzFrameSetVisible(panel, true) else UI.ShowRoot() end
end

function UI.ShowInfo(which)
    UI.HideAllPanels()
    if not UI.browsingActivity then UI.HideToolbar() end
    BlzFrameSetVisible(UI.panels[which], true)
end

function UI.ShowToolbar(capabilities)
    local caps = capabilities or {}
    UI.browsingActivity = false
    BlzFrameSetText(UI.toolbarButtons.menu, "Training Menu")
    BlzFrameSetVisible(UI.toolbarButtons.restart, caps.restart == true)
    BlzFrameSetVisible(UI.toolbarButtons.menu, caps.menu ~= false)
    BlzFrameSetVisible(UI.toolbar, true)
end

function UI.ShowActivityMenu(categoryId)
    UI.browsingActivity = true
    UI.ShowCategory(categoryId)
    BlzFrameSetVisible(UI.toolbarButtons.restart, false)
    BlzFrameSetText(UI.toolbarButtons.menu, "Return to Training")
    BlzFrameSetVisible(UI.toolbarButtons.menu, true)
    BlzFrameSetVisible(UI.toolbar, true)
end

local function CreateRootPanel()
    local panel = CreateBackdrop("JTGRootPanel", GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    UI.panels.root = panel

    local title = CreateText("JTGRootTitle", panel, "|cffffcc00Jamie's Training Grounds|r", 0.54, 0.045, 1.55)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, -0.010)
    local subtitle = CreateText("JTGRootSubtitle", panel, "Choose what you want to learn or practice.", 0.54, 0.028, 1.02)
    BlzFrameSetPoint(subtitle, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, 0.002)

    local positions = {{-0.145, -0.125}, {0.145, -0.125}, {-0.145, -0.205}, {0.145, -0.205}}
    for index, category in ipairs(JTG.Categories) do
        local button = CreateButton("JTGCategory" .. index, panel, category.title, 0.25, 0.055)
        BlzFrameSetPoint(button, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, positions[index][1], positions[index][2])
        UI.categoryButtons[category.id] = button
        AttachTooltip(button, category.summary, index % 2 == 0 and "left" or "right")
        RegisterClick(button, function() UI.ShowCategory(category.id) end)
    end

    local stats = CreateButton("JTGPlayerStats", panel, "Player Stats  |cff808080[PLANNED]|r", 0.19, 0.044)
    BlzFrameSetPoint(stats, FRAMEPOINT_BOTTOMLEFT, panel, FRAMEPOINT_BOTTOMLEFT, 0.045, 0.035)
    BlzFrameSetEnable(stats, false)
    BlzFrameSetTextColor(stats, BlzConvertColor(255, 135, 135, 135))

    local patch = CreateButton("JTGPatchNotes", panel, "Patch Notes", 0.17, 0.044)
    BlzFrameSetPoint(patch, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(patch, function() UI.ShowInfo("patch") end)
    local credits = CreateButton("JTGCredits", panel, "Credits", 0.17, 0.044)
    BlzFrameSetPoint(credits, FRAMEPOINT_BOTTOMRIGHT, panel, FRAMEPOINT_BOTTOMRIGHT, -0.045, 0.035)
    RegisterClick(credits, function() UI.ShowInfo("credits") end)
end

local function CreateCategoryPanel(category, categoryIndex)
    local panel = CreateBackdrop("JTGCategoryPanel" .. categoryIndex, GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    UI.panels["category_" .. category.id] = panel
    BlzFrameSetVisible(panel, false)

    local title = CreateText("JTGCategoryTitle" .. categoryIndex, panel,
        "|cffffcc00" .. category.title .. "|r", 0.54, 0.035, 1.2)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, -0.025)
    local summary = CreateText("JTGCategorySummary" .. categoryIndex, panel, category.summary, 0.54, 0.025, 0.85)
    BlzFrameSetPoint(summary, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, -0.005)

    local activities = JTG.GetActivities(category.id)
    local maxRows = 5
    for index, descriptor in ipairs(activities) do
        local column = math.floor((index - 1) / maxRows)
        local row = (index - 1) % maxRows
        local name = "JTGActivity" .. categoryIndex .. "x" .. index
        local frame
        local button
        if descriptor.artwork ~= nil then
            frame, button = CreateIllustratedActivityCard(name, panel, descriptor)
        else
            button = CreateButton(name, panel,
                descriptor.title .. "  |cff808080[Planned]|r", 0.190, 0.052)
            frame = button
        end
        BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, panel, FRAMEPOINT_TOPLEFT,
            0.025 + column * 0.200, -0.100 - row * 0.055)
        if descriptor.status ~= "available" and descriptor.artwork ~= nil then
            AttachTooltip(button, descriptor.description, column >= 2 and "left" or "right")
            RegisterClick(button, function() end)
        elseif descriptor.status ~= "available" then
            BlzFrameSetEnable(button, false)
            BlzFrameSetTextColor(button, BlzConvertColor(255, 145, 145, 145))
        else
            RegisterClick(button, function() JTG.StartActivity(descriptor.id, category.id) end)
        end
        UI.catalogueRows[descriptor.id] = button
    end

    local back = CreateButton("JTGCategoryBack" .. categoryIndex, panel, "Back", 0.16, 0.042)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, UI.ShowRoot)
end

local function CreateInfoPanel(key, titleText, bodyText, index, scrollable)
    local panel = CreateBackdrop("JTGInfoPanel" .. index, GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    UI.panels[key] = panel
    BlzFrameSetVisible(panel, false)
    local title = CreateText("JTGInfoTitle" .. index, panel, "|cffffcc00" .. titleText .. "|r", 0.54, 0.04, 1.25)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, -0.03)
    local body
    if scrollable then
        body = BlzCreateFrame("EscMenuTextAreaTemplate", panel, 0, index)
        BlzFrameSetSize(body, 0.52, 0.30)
        BlzFrameSetText(body, bodyText)
        BlzFrameSetPoint(body, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, -0.025)
    else
        body = CreateText("JTGInfoBody" .. index, panel, bodyText, 0.52, 0.30, 0.9)
        BlzFrameSetTextAlignment(body, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
        BlzFrameSetPoint(body, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, -0.025)
    end
    local back = CreateButton("JTGInfoBack" .. index, panel, "Back", 0.16, 0.042)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, UI.ShowRoot)
end

local function CreateToolbar()
    local bar = BlzCreateFrameByType("FRAME", "JTGActivityToolbar", GAME_UI, "", 0)
    BlzFrameSetSize(bar, 0.30, 0.055)
    BlzFrameSetAbsPoint(bar, FRAMEPOINT_TOPRIGHT, 0.79, 0.585)
    UI.toolbar = bar
    local restart = CreateButton("JTGToolbarRestart", bar, "Restart", 0.125, 0.037)
    BlzFrameSetPoint(restart, FRAMEPOINT_LEFT, bar, FRAMEPOINT_LEFT, 0.018, 0)
    AttachTooltip(restart, "Cleanly reset the current activity and begin it again.", "left")
    RegisterClick(restart, JTG.ResetActivity)
    UI.toolbarButtons.restart = restart
    local menu = CreateButton("JTGToolbarMenu", bar, "Training Menu", 0.125, 0.037)
    BlzFrameSetPoint(menu, FRAMEPOINT_RIGHT, bar, FRAMEPOINT_RIGHT, -0.018, 0)
    AttachTooltip(menu, "Open the Training Grounds menu.", "left")
    RegisterClick(menu, function()
        if UI.browsingActivity then JTG.ResumeActivity() else JTG.OpenTrainingMenu() end
    end)
    UI.toolbarButtons.menu = menu
    BlzFrameSetVisible(bar, false)
end

function UI.Initialize()
    GAME_UI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    UI.clickTrigger = CreateTrigger()
    TriggerAddAction(UI.clickTrigger, function()
        local action = UI.clickActions[GetHandleId(BlzGetTriggerFrame())]
        if action ~= nil then
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
        "Training project by Jamie and Solanum.\n\n" ..
        "Foundation terrain adapted from Twisted Meadows by McCandlish, MMC and W3Champions.\n\n" ..
        "Warcraft III is a game by Blizzard Entertainment.", 2)
    CreateToolbar()
    UI.ShowRoot()
end
