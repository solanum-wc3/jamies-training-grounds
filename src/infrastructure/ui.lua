-- Permanent map-owned menu and shared activity controls.
JTG = JTG or {}
JTG.UI = {
    panels = {}, categoryButtons = {}, catalogueRows = {}, toolbarButtons = {},
    clickActions = {}, clickSounds = {}, clickTrigger = nil, browsingActivity = false,
    nativeHiddenFrames = {}, tooltips = {},
    epoch = 0, currentView = {kind = "root"},
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
local TOOLBAR_BUTTON_WIDTH = 0.087
local TOOLBAR_BUTTON_HEIGHT = 0.024
local TOOLBAR_BUTTON_GAP = 0.001
local TOOLBAR_ROW_STEP = TOOLBAR_BUTTON_HEIGHT + 0.001
local TOOLBAR_LEFT = 0.446
local TOOLBAR_TOP = 0.575

UI.ToolbarLayout = {
    buttonWidth = TOOLBAR_BUTTON_WIDTH,
    buttonHeight = TOOLBAR_BUTTON_HEIGHT,
    gap = TOOLBAR_BUTTON_GAP,
    rowStep = TOOLBAR_ROW_STEP,
    left = TOOLBAR_LEFT,
    top = TOOLBAR_TOP,
}
local PARAGRAPH_SCALE = 1.18
local CATALOGUE_BUTTON_WIDTH = 0.190
local CATALOGUE_BUTTON_HEIGHT = 0.052
local FOOTER_BUTTON_WIDTH = 0.17
local FOOTER_BUTTON_HEIGHT = 0.044
local footerDividerCount = 0

local function SetActivityOverlayVisible(visible)
    local session = JTG.Controller and JTG.Controller.session
    local activity = session and session.activity
    if activity ~= nil and activity.setOverlayVisible ~= nil then
        local ok, message = pcall(activity.setOverlayVisible, activity, visible == true)
        if not ok then print("JTG overlay visibility warning: " .. tostring(message)) end
    end
end

UI.SetActivityOverlayVisible = SetActivityOverlayVisible

local function ApplyActivityPause()
    local session = JTG.Controller and JTG.Controller.session
    local activity = session and session.activity
    local paused = UI.gameplayMenuPaused == true or UI.exercisePaused == true
    if activity ~= nil and activity.setPaused ~= nil then
        local ok, message = pcall(activity.setPaused, activity, paused)
        if not ok then print("JTG activity pause warning: " .. tostring(message)) end
    end
    -- Freeze Warcraft's simulation clock so engine-owned schedules, including
    -- power-build resource charges, retain their exact place in the cycle.
    PauseGame(paused and not UI.nativePauseReleased and
        not UI.deferGlobalPause)
end

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

local function AddFooterDivider(panel)
    footerDividerCount = footerDividerCount + 1
    local divider = BlzCreateFrameByType("BACKDROP",
        "JTGMenuFooterDivider" .. footerDividerCount, panel, "", 0)
    BlzFrameSetTexture(divider, "JTGMenu\\MenuDivider.dds", 0, true)
    BlzFrameSetSize(divider, 0.52, 0.0012)
    BlzFrameSetPoint(divider, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.092)
    BlzFrameSetLevel(divider, 8)
    BlzFrameSetEnable(divider, false)
    return divider
end

local function AddContentDivider(panel, topOffset)
    footerDividerCount = footerDividerCount + 1
    local divider = BlzCreateFrameByType("BACKDROP",
        "JTGMenuContentDivider" .. footerDividerCount, panel, "", 0)
    BlzFrameSetTexture(divider, "JTGMenu\\MenuDivider.dds", 0, true)
    BlzFrameSetSize(divider, 0.52, 0.0012)
    BlzFrameSetPoint(divider, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, topOffset)
    BlzFrameSetLevel(divider, 8)
    BlzFrameSetEnable(divider, false)
    return divider
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

local function BriefingChoicePoint(index, count, compact, compactColumns, centerSingle)
    if compact then
        local columns = compactColumns or 3
        local spacing = columns == 4 and 0.137 or 0.180
        local column = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        local firstRowY = columns == 4 and -0.261 or -0.225
        return -0.5 * (columns - 1) * spacing + column * spacing,
            firstRowY - row * 0.036
    end
    if centerSingle and count == 1 then
        return 0, -0.305
    end
    if count <= 2 then
        return index == 1 and -0.108 or 0.108, -0.305
    end
    if count <= 4 then
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        return column == 0 and -0.108 or 0.108, -0.278 - row * 0.050
    end
    local column = (index - 1) % 2
    local row = math.floor((index - 1) / 2)
    return column == 0 and -0.108 or 0.108, -0.215 - row * 0.055
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

local function RefreshPauseButton()
    local button = UI.toolbarButtons.pause
    if button == nil then return end
    local paused = UI.exercisePaused == true
    local color = paused and BlzConvertColor(255, 255, 255, 255) or
        BlzConvertColor(255, 255, 204, 0)
    local text = paused and "Unpause" or "Pause"
    BlzFrameSetText(button, paused and "|cffffffff" .. text .. "|r" or
        "|cffffcc00" .. text .. "|r")
    BlzFrameSetTextColor(button, color)
    local label = FindButtonText(button)
    if label ~= nil then BlzFrameSetTextColor(label, color) end
end

local function ClearPausedLoadNotice()
    if UI.loadWarningTimer ~= nil then
        PauseTimer(UI.loadWarningTimer)
        DestroyTimer(UI.loadWarningTimer)
        UI.loadWarningTimer = nil
    end
    if UI.unpauseHighlightTimer ~= nil then
        PauseTimer(UI.unpauseHighlightTimer)
        DestroyTimer(UI.unpauseHighlightTimer)
        UI.unpauseHighlightTimer = nil
    end
    if UI.loadWarningText ~= nil then
        BlzFrameSetVisible(UI.loadWarningText, false)
    end
    for _, highlight in ipairs(UI.unpauseHighlights or {}) do
        BlzFrameSetVisible(highlight, false)
    end
    UI.unpauseHighlightActive = false
    RefreshPauseButton()
end

local function HighlightUnpauseButton()
    if UI.toolbarButtons.pause == nil then return end
    UI.unpauseHighlightActive = true
    for _, highlight in ipairs(UI.unpauseHighlights or {}) do
        BlzFrameSetVisible(highlight, true)
        BlzFrameSetSpriteAnimate(highlight, 0, 0)
    end
    RefreshPauseButton()
    if UI.unpauseHighlightTimer ~= nil then
        PauseTimer(UI.unpauseHighlightTimer)
        DestroyTimer(UI.unpauseHighlightTimer)
    end
    local epoch = UI.epoch
    UI.unpauseHighlightTimer = CreateTimer()
    TimerStart(UI.unpauseHighlightTimer, 5.0, false, function()
        DestroyTimer(UI.unpauseHighlightTimer)
        UI.unpauseHighlightTimer = nil
        if UI.epoch ~= epoch then return end
        UI.unpauseHighlightActive = false
        for _, highlight in ipairs(UI.unpauseHighlights or {}) do
            BlzFrameSetVisible(highlight, false)
        end
        RefreshPauseButton()
    end)
end

-- Activity-owned toolbars can register their Pause/Unpause notification
-- sprite with the same paused-load warning used by the shared toolbar. The
-- returned disposer must run before the activity destroys the sprite frame.
function UI.RegisterPauseHighlight(highlight)
    if highlight == nil then return function() end end
    UI.unpauseHighlights = UI.unpauseHighlights or {}
    table.insert(UI.unpauseHighlights, highlight)
    local registered = true
    return function()
        if not registered then return end
        registered = false
        local highlights = UI.unpauseHighlights or {}
        for index = #highlights, 1, -1 do
            if highlights[index] == highlight then
                table.remove(highlights, index)
            end
        end
    end
end

local function WarnPausedLoad()
    UI.nativeLoadPanelWasVisible = true
    if UI.loadWarningText ~= nil then
        -- Native Save/Load dialogs are raised after the ordinary game UI.
        -- Reassert a top overlay level when the warning is shown so the text
        -- renders over the dialog rather than through its translucent panel.
        BlzFrameSetLevel(UI.loadWarningText, 10000)
        BlzFrameSetText(UI.loadWarningText,
            "|cffffffffTo load a game, you have to |r" ..
            "|cffffcc00Unpause|r|cffffffff.|r")
        BlzFrameSetVisible(UI.loadWarningText, true)
    end
    if UI.loadWarningTimer ~= nil then
        PauseTimer(UI.loadWarningTimer)
        DestroyTimer(UI.loadWarningTimer)
    end
    local epoch = UI.epoch
    UI.loadWarningTimer = CreateTimer()
    TimerStart(UI.loadWarningTimer, 5.0, false, function()
        DestroyTimer(UI.loadWarningTimer)
        UI.loadWarningTimer = nil
        if UI.epoch == epoch and UI.loadWarningText ~= nil then
            BlzFrameSetVisible(UI.loadWarningText, false)
        end
    end)
    PingMinimapEx(GetCameraTargetPositionX(), GetCameraTargetPositionY(),
        0.10, 255, 204, 0, true)
    HighlightUnpauseButton()
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

    return button, button, art
end

local function CreateIllustratedActivityCard(name, parent, descriptor)
    local frame, button, art = CreateIllustratedCard(name, parent, descriptor,
        CATALOGUE_BUTTON_WIDTH, CATALOGUE_BUTTON_HEIGHT,
        descriptor.artworkWidth or 0.098,
        descriptor.artworkHeight or 0.048,
        0.120, 0.84, descriptor.labelInset or 0.020)
    if descriptor.centerArtwork == true then
        BlzFrameClearAllPoints(art)
        BlzFrameSetPoint(art, FRAMEPOINT_CENTER, button,
            FRAMEPOINT_CENTER, descriptor.artworkOffsetX or 0,
            descriptor.artworkOffsetY or 0)
    end
    return frame, button, art
end

local function CreateIllustratedCategoryCard(name, parent, category)
    local descriptor = {
        title = category.title,
        artwork = category.artwork,
        status = "available",
    }
    local frame, button, art = CreateIllustratedCard(name, parent, descriptor,
        0.25, 0.088, 0.169, 0.082, 0.120, 0.84, 0.020)
    BlzFrameClearAllPoints(art)
    BlzFrameSetPoint(art, FRAMEPOINT_CENTER, button, FRAMEPOINT_CENTER,
        0.0585, 0)
    return frame, button, art
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
    table.insert(UI.tooltips, tooltip)
    return tooltip, label
end

local function HookNativeCloseButtons()
    if UI.nativeCloseTrigger == nil then return end
    local names = {
        "QuestAcceptButton", "LogOkButton", "ReturnButton",
        "AllianceAcceptButton", "AllianceCancelButton", "ChatAcceptButton",
    }
    for _, name in ipairs(names) do
        local button = BlzGetFrameByName(name, 0)
        if button ~= nil then
            local id = GetHandleId(button)
            if not UI.nativeCloseHooks[id] then
                UI.nativeCloseHooks[id] = true
                BlzTriggerRegisterFrameEvent(UI.nativeCloseTrigger, button,
                    FRAMEEVENT_CONTROL_CLICK)
            end
        end
    end
end

local function ApplyFullQuestTextLayout()
    local display = BlzGetFrameByName("QuestDisplay", 0)
    local detailsTitle = BlzGetFrameByName("QuestDetailsTitle", 0)
    local backdrop = BlzGetFrameByName("QuestDisplayBackdrop", 0)
    if display == nil or detailsTitle == nil or backdrop == nil then return end

    local displayId = GetHandleId(display)
    if UI.fullQuestTextFrameId == displayId then return end
    UI.fullQuestTextFrameId = displayId

    -- Exercise quests are reference pages rather than campaign objective
    -- checklists. Expand Warcraft's native description area through the
    -- otherwise empty QuestItem region so their text begins below the title.
    BlzFrameClearAllPoints(display)
    BlzFrameSetPoint(display, FRAMEPOINT_TOPLEFT,
        detailsTitle, FRAMEPOINT_BOTTOMLEFT, 0.003, -0.003)
    BlzFrameSetPoint(display, FRAMEPOINT_BOTTOMRIGHT,
        backdrop, FRAMEPOINT_BOTTOMRIGHT, -0.003, 0.003)
end

local HookNativeLoadButtons

local function SuspendForNativeMenu()
    if UI.nativeMenuOpen then return end
    UI.nativeMenuOpen = true
    UI.nativeCloseTicks = 0
    UI.nativeLoadPanelWasVisible = false
    UI.nativeHiddenFrames = {}
    local seen = {}
    local function suspend(frame)
        if frame == nil then return end
        local id = GetHandleId(frame)
        if seen[id] or not BlzFrameIsVisible(frame) then return end
        seen[id] = true
        table.insert(UI.nativeHiddenFrames, frame)
        BlzFrameSetVisible(frame, false)
    end
    -- Remove every shared custom surface that could accept clicks through a
    -- native dialog. Each frame is restored only if it was visible here.
    for _, panel in pairs(UI.panels) do suspend(panel) end
    suspend(UI.toolbar)
    suspend(UI.pausedActivityResume)
    suspend(UI.pausedActivityExit)
    suspend(UI.activityBriefingResume)
    suspend(UI.activityBriefingExit)
    local session = JTG.Controller and JTG.Controller.session
    local activity = session and session.activity
    if activity ~= nil and activity.hidePresentationForMenu ~= nil then
        activity:hidePresentationForMenu()
    else
        SetActivityOverlayVisible(false)
    end
    for _, tooltip in ipairs(UI.tooltips) do
        if tooltip ~= nil then BlzFrameSetVisible(tooltip, false) end
    end
    local questDialog = BlzGetFrameByName("QuestDialog", 0)
    if questDialog ~= nil and BlzFrameIsVisible(questDialog) then
        ApplyFullQuestTextLayout()
    end
    HookNativeCloseButtons()
    if HookNativeLoadButtons ~= nil then HookNativeLoadButtons() end
end

local function ReleasePauseForNativeSystemMenu(force)
    local newlyReleased = not UI.nativePauseReleased
    UI.nativePauseReleased = true
    -- Restart Mission cannot finish while a script-owned PauseGame is active.
    -- Loading deliberately leaves this state untouched and instructs the
    -- player to return and unpause instead.
    if newlyReleased or force == true then PauseGame(false) end
end


HookNativeLoadButtons = function()
    if UI.nativeLoadTrigger == nil then return end
    local controls = {
        {"LoadGameButton", FRAMEEVENT_CONTROL_CLICK},
        {"RestartButton", FRAMEEVENT_CONTROL_CLICK},
    }
    for _, control in ipairs(controls) do
        local frame = BlzGetFrameByName(control[1], 0)
        if frame ~= nil then
            local key = tostring(GetHandleId(frame)) .. ":" ..
                tostring(GetHandleId(control[2]))
            if not UI.nativeLoadHooks[key] then
                UI.nativeLoadHooks[key] = true
                BlzTriggerRegisterFrameEvent(UI.nativeLoadTrigger, frame,
                    control[2])
            end
        end
    end
end

local function QueueNativeMenuSuspend()
    if UI.nativeMenuOpen or UI.nativeSuspendQueued then return end
    UI.nativeSuspendQueued = true
    local epoch = UI.epoch
    local timer = CreateTimer()
    TimerStart(timer, 0.00, false, function()
        DestroyTimer(timer)
        if UI.epoch ~= epoch then return end
        UI.nativeSuspendQueued = false
        SuspendForNativeMenu()
    end)
end

local function RestoreAfterNativeMenu()
    if not UI.nativeMenuOpen then return false end
    UI.nativeMenuOpen = false
    for _, frame in ipairs(UI.nativeHiddenFrames) do
        BlzFrameSetVisible(frame, true)
    end
    UI.nativeHiddenFrames = {}
    UI.nativePauseReleased = false
    UI.nativeSaveLoadSeen = false
    UI.nativeLoadPanelWasVisible = false
    if not UI.menuVisible then
        local session = JTG.Controller and JTG.Controller.session
        local activity = session and session.activity
        if activity ~= nil and activity.restorePresentation ~= nil then
            activity:restorePresentation()
        else
            SetActivityOverlayVisible(true)
        end
    end
    UI.nativeCloseTicks = 0
    ApplyActivityPause()
    return true
end

local function NativeSaveLoadIsVisible()
    local names = {
        "SaveGameDialog", "LoadGameDialog", "SaveGamePanel", "LoadGamePanel",
    }
    for _, name in ipairs(names) do
        local frame = BlzGetFrameByName(name, 0)
        if frame ~= nil and BlzFrameIsVisible(frame) then return true end
    end
    return false
end

local function NativeLoadPanelIsVisible()
    local panel = BlzGetFrameByName("LoadOnly", 0)
    return panel ~= nil and BlzFrameIsVisible(panel)
end

local function NativeMenuIsVisible()
    local names = {
        "EscMenuBackdrop", "QuestDialog", "LogDialog",
        "AllianceDialog", "ChatDialog",
        "SaveGameDialog", "LoadGameDialog", "SaveGamePanel", "LoadGamePanel",
    }
    for _, name in ipairs(names) do
        local frame = BlzGetFrameByName(name, 0)
        if frame ~= nil and BlzFrameIsVisible(frame) then return true end
    end
    return false
end

local function StartNativeMenuMonitor()
    UI.nativeMenuMonitor = CreateTimer()
    TimerStart(UI.nativeMenuMonitor, 0.05, true, function()
        if NativeMenuIsVisible() then
            if NativeSaveLoadIsVisible() then UI.nativeSaveLoadSeen = true end
            UI.nativeCloseTicks = 0
            SuspendForNativeMenu()
            HookNativeCloseButtons()
            HookNativeLoadButtons()
            local loadVisible = NativeLoadPanelIsVisible()
            if loadVisible and not UI.nativeLoadPanelWasVisible and
                    (UI.exercisePaused == true or UI.gameplayMenuPaused == true) then
                WarnPausedLoad()
            end
            UI.nativeLoadPanelWasVisible = loadVisible
        elseif UI.nativeMenuOpen then
            UI.nativeCloseTicks = (UI.nativeCloseTicks or 0) + 1
            -- Save/Load temporarily removes the F10 frames while it changes
            -- screens. Do not mistake that gap for Return to Game and restore
            -- the script pause before loading can complete. Explicit close
            -- buttons and hotkeys still restore immediately.
            local threshold = UI.nativePauseReleased and 20 or 3
            if not UI.nativeSaveLoadSeen and UI.nativeCloseTicks >= threshold then
                RestoreAfterNativeMenu()
            end
        end
    end)
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

local function ReleaseKeyboardFocusAfterClick()
    -- Timers do not advance while the game is paused, so paused interfaces
    -- must release focus synchronously. During play, defer until Warcraft has
    -- finished dispatching the frame click or it may focus the button again.
    if UI.gameplayMenuPaused or UI.exercisePaused then
        ReleaseKeyboardFocus()
        return
    end
    local epoch = UI.epoch
    local focusTimer = CreateTimer()
    TimerStart(focusTimer, 0.05, false, function()
        DestroyTimer(focusTimer)
        if UI.epoch ~= epoch then return end
        ReleaseKeyboardFocus()
    end)
end

UI.ReleaseKeyboardFocus = ReleaseKeyboardFocus
UI.ReleaseKeyboardFocusAfterClick = ReleaseKeyboardFocusAfterClick

local function ReleaseFrameFocus(frame)
    if frame == nil or GetLocalPlayer() ~= Player(0) then return end
    -- Warcraft often restores focus to a clicked GLUETEXTBUTTON after the
    -- frame event finishes. Cycling the clicked frame itself prevents that
    -- restoration and immediately returns F-key input to the game.
    BlzFrameSetFocus(frame, false)
    BlzFrameSetEnable(frame, false)
    BlzFrameSetEnable(frame, true)
end

UI.ReleaseFrameFocus = ReleaseFrameFocus

local function PlayButtonSound(kind)
    local sound = kind == "return" and UI.returnButtonSound or UI.normalButtonSound
    if sound ~= nil then
        StopSound(sound, false, false)
        StartSound(sound)
    end
end

UI.PlayButtonSound = PlayButtonSound

local function RegisterClick(frame, action, soundKind)
    UI.clickActions[GetHandleId(frame)] = action
    UI.clickSounds[GetHandleId(frame)] = soundKind or "normal"
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
    if UI.menuShade ~= nil then BlzFrameSetVisible(UI.menuShade, false) end
    UI.menuVisible = false
    UI.currentBackAction = nil
end

function UI.HideToolbar()
    UI.browsingActivity = false
    if UI.toolbar then BlzFrameSetVisible(UI.toolbar, false) end
    if UI.pausedActivityResume then BlzFrameSetVisible(UI.pausedActivityResume, false) end
    if UI.pausedActivityExit then BlzFrameSetVisible(UI.pausedActivityExit, false) end
end

function UI.SetQuestAvailable(available)
    UI.questAvailable = available == true
    local button = BlzGetFrameByName("UpperButtonBarQuestsButton", 0) or
        BlzGetOriginFrame(ORIGIN_FRAME_QUEST_BUTTON, 0)
    if button ~= nil then
        BlzFrameSetEnable(button, UI.questAvailable)
        BlzFrameSetAlpha(button, UI.questAvailable and 255 or 145)
    end
    if not UI.questAvailable and UI.questHighlight ~= nil then
        BlzFrameSetVisible(UI.questHighlight, false)
    end
end

function UI.HighlightQuestButton(duration)
    if not UI.questAvailable or UI.questHighlight == nil then return end
    if UI.questHighlightTimer ~= nil then
        PauseTimer(UI.questHighlightTimer)
        DestroyTimer(UI.questHighlightTimer)
    end
    BlzFrameSetVisible(UI.questHighlight, true)
    BlzFrameSetSpriteAnimate(UI.questHighlight, 0, 0)
    local epoch = UI.epoch
    UI.questHighlightTimer = CreateTimer()
    TimerStart(UI.questHighlightTimer, duration or 5.0, false, function()
        DestroyTimer(UI.questHighlightTimer)
        UI.questHighlightTimer = nil
        if UI.epoch == epoch and UI.questHighlight ~= nil then
            BlzFrameSetVisible(UI.questHighlight, false)
        end
    end)
end

function UI.ShowRoot()
    UI.HideAllPanels()
    if UI.gameplayMenuPaused then UI.ShowPausedActivityToolbar()
    elseif not UI.browsingActivity then UI.HideToolbar() end
    BlzFrameSetVisible(UI.panels.root, true)
    SetRootActivityFooter(UI.gameplayMenuPaused == true)
    UI.menuVisible = true
    UI.currentView = {kind = "root"}
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
        UI.currentView = {kind = "category", id = categoryId}
        UI.currentBackAction = UI.ShowRoot
    else UI.ShowRoot() end
end

function UI.ShowSkillRace(raceId)
    UI.HideAllPanels()
    if UI.gameplayMenuPaused then UI.ShowPausedActivityToolbar()
    elseif not UI.browsingActivity then UI.HideToolbar() end
    local panel = UI.panels["skill_race_" .. raceId]
    if panel then
        BlzFrameSetVisible(panel, true)
        UI.menuVisible = true
        UI.currentView = {kind = "skill_race", id = raceId}
        UI.currentBackAction = function() UI.ShowCategory("skills") end
    else UI.ShowCategory("skills") end
end

function UI.ShowInfo(which)
    UI.HideAllPanels()
    if UI.gameplayMenuPaused then UI.ShowPausedActivityToolbar()
    elseif not UI.browsingActivity then UI.HideToolbar() end
    BlzFrameSetVisible(UI.panels[which], true)
    UI.menuVisible = true
    UI.currentView = {kind = "info", id = which}
    UI.currentBackAction = UI.ShowRoot
end

function UI.ShowToolbar(capabilities)
    local caps = capabilities or {}
    UI.SetQuestAvailable(caps.quests == true)
    UI.browsingActivity = false
    UI.currentView = {kind = "gameplay"}
    if UI.pausedActivityResume then BlzFrameSetVisible(UI.pausedActivityResume, false) end
    if UI.pausedActivityExit then BlzFrameSetVisible(UI.pausedActivityExit, false) end
    BlzFrameSetText(UI.toolbarButtons.restart, "Redo")
    BlzFrameSetText(UI.toolbarButtons.menu, "Menu")
    UI.clickActions[GetHandleId(UI.toolbarButtons.menu)] = JTG.OpenTrainingMenu
    BlzFrameSetVisible(UI.toolbarButtons.restart, caps.restart == true)
    BlzFrameSetVisible(UI.toolbarButtons.menu, caps.menu ~= false)
    BlzFrameSetVisible(UI.toolbarButtons.lastRunner, caps.lastRunner == true)
    BlzFrameSetVisible(UI.toolbarButtons.pause, caps.pause == true)
    RefreshPauseButton()
    BlzFrameSetVisible(UI.toolbar, true)
    UI.LayoutToolbar()
    UI.SetLastRunnerEnabled(false)
end

function UI.SetLastRunnerEnabled(enabled)
    if UI.toolbarButtons.lastRunner == nil then return end
    BlzFrameSetEnable(UI.toolbarButtons.lastRunner, enabled == true)
    BlzFrameSetAlpha(UI.toolbarButtons.lastRunner, enabled and 255 or 145)
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
    -- Resume and Exit already provide the activity controls around this menu.
    -- The former "Return to Training" toolbar button duplicated Resume.
    BlzFrameSetVisible(UI.toolbar, false)
end

function UI.HideActivityBriefing()
    local panel = UI.panels.activityBriefing
    if panel ~= nil then BlzFrameSetVisible(panel, false) end
    if UI.activityBriefingResume ~= nil then BlzFrameSetVisible(UI.activityBriefingResume, false) end
end

local function RefreshActivityBriefingChoices()
    local actions = UI.activityBriefingActions or {}
    local compact = UI.activityBriefingCompact == true
    local compactColumns = UI.activityBriefingCompactColumns
    UI.activityBriefingVisibleActions = {}
    for index, button in ipairs(UI.activityBriefingButtons or {}) do
        local choice = actions[index]
        UI.activityBriefingVisibleActions[index] = choice
        BlzFrameSetVisible(button, choice ~= nil)
        if choice ~= nil then
            local x, y = BriefingChoicePoint(index, #actions, compact, compactColumns,
                UI.activityBriefingCenterSingle)
            BlzFrameClearAllPoints(button)
            BlzFrameSetPoint(button, FRAMEPOINT_TOP, UI.panels.activityBriefing,
                FRAMEPOINT_TOP, x, y)
            BlzFrameSetSize(button,
                compact and (compactColumns == 4 and 0.125 or 0.165) or 0.190,
                compact and 0.033 or 0.042)
            BlzFrameSetText(button, choice.label)
            local label = FindButtonText(button)
            if label ~= nil then BlzFrameSetScale(label, compact and 0.72 or 1.0) end
            BlzFrameSetTextColor(button, choice.primary and
                BlzConvertColor(255, 255, 204, 0) or BlzConvertColor(255, 255, 255, 255))
        end
    end
end

function UI.ShowActivityBriefing(spec)
    local panel = UI.panels.activityBriefing
    if panel == nil then return end
    local actions = spec.choices or {}
    local compact = spec.compactChoices == true
    local compactColumns = spec.compactColumns
    local _, firstChoiceY = BriefingChoicePoint(1, math.max(1, #actions),
        compact, compactColumns, spec.centerSingleChoice == true)
    UI.SetGameplayMenuPaused(spec.pauseGame == true)
    SetActivityOverlayVisible(false)
    UI.HideAllPanels()
    UI.HideToolbar()
    BlzFrameSetText(UI.activityBriefingTitle, "|cffffcc00" .. (spec.title or "") .. "|r")
    BlzFrameSetText(UI.activityBriefingBody, spec.body or "")
    BlzFrameClearAllPoints(UI.activityBriefingContentDivider)
    BlzFrameSetPoint(UI.activityBriefingContentDivider, FRAMEPOINT_TOP, panel,
        FRAMEPOINT_TOP, 0, firstChoiceY + 0.013)
    BlzFrameClearAllPoints(UI.activityBriefingBody)
    BlzFrameSetPoint(UI.activityBriefingBody, FRAMEPOINT_TOP,
        UI.activityBriefingTitle, FRAMEPOINT_BOTTOM, 0, -0.022)
    BlzFrameSetPoint(UI.activityBriefingBody, FRAMEPOINT_BOTTOM,
        UI.activityBriefingContentDivider, FRAMEPOINT_TOP, 0, 0.013)
    BlzFrameSetVisible(UI.activityBriefingArtwork, spec.headingArtwork ~= nil)
    if spec.headingArtwork ~= nil then
        BlzFrameClearAllPoints(UI.activityBriefingArtwork)
        BlzFrameSetSize(UI.activityBriefingArtwork,
            spec.headingArtworkWidth or 0.200,
            spec.headingArtworkHeight or 0.098)
        BlzFrameSetPoint(UI.activityBriefingArtwork, FRAMEPOINT_TOPRIGHT,
            panel, FRAMEPOINT_TOPRIGHT, spec.headingArtworkOffsetX or -0.065,
            spec.headingArtworkOffsetY or -0.025)
        BlzFrameSetTexture(UI.activityBriefingArtwork, spec.headingArtwork, 0, true)
    end
    UI.activityBriefingActions = actions
    UI.activityBriefingCompact = compact
    UI.activityBriefingCompactColumns = compactColumns
    UI.activityBriefingCenterSingle = spec.centerSingleChoice == true
    RefreshActivityBriefingChoices()
    UI.activityBriefingBackAction = spec.backAction
    BlzFrameSetTextColor(UI.activityBriefingBack, BlzConvertColor(255, 255, 255, 255))
    UI.activityBriefingResumeAction = spec.resumeAction
    UI.activityBriefingExitAction = spec.exitAction or JTG.ExitActivityFromMenu
    BlzFrameSetVisible(UI.activityBriefingResume, spec.resumeAction ~= nil)
    BlzFrameSetVisible(UI.activityBriefingExit, spec.resumeAction ~= nil)
    BlzFrameSetVisible(panel, true)
    UI.menuVisible = true
    UI.currentView = {
        kind = "activity_briefing",
        id = spec.activityId,
        category = spec.originCategory,
        page = spec.pageId or "root",
        data = spec.restoreData,
    }
    UI.currentBackAction = spec.backAction
end

function UI.SetGameplayMenuPaused(paused)
    local nextState = paused == true
    UI.gameplayMenuPaused = nextState
    ApplyActivityPause()
    -- Pause the simulation without placing an extra dimmed layer over the map.
    if UI.menuShade ~= nil then BlzFrameSetVisible(UI.menuShade, false) end
end

function UI.ReleaseGameplayControl()
    UI.gameplayMenuPaused = false
    UI.exercisePaused = false
    ApplyActivityPause()
    if UI.menuShade ~= nil then BlzFrameSetVisible(UI.menuShade, false) end
    if UI.toolbarButtons.pause ~= nil then
        RefreshPauseButton()
    end
    ReleaseKeyboardFocus()
end

function UI.SetExercisePaused(paused)
    local nextState = paused == true
    UI.exercisePaused = nextState
    if not nextState then ClearPausedLoadNotice() end
    ApplyActivityPause()
    RefreshPauseButton()
end

function UI.ToggleExercisePause()
    UI.SetExercisePaused(not UI.exercisePaused)
end

local function CreateRootPanel()
    local panel = CreateNativePanel("JTGRootPanel", GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    AddFooterDivider(panel)
    local contentDivider = AddContentDivider(panel, -0.112)
    UI.panels.root = panel

    local title = CreateText("JTGRootTitle", panel, "|cffffcc00Jamie's Training Grounds|r",
        TITLE_WIDTH, TITLE_HEIGHT, TITLE_SCALE)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, TITLE_TOP_OFFSET)
    local subtitle = CreateText("JTGRootSubtitle", panel,
        "Choose what you want to learn or practice.",
        0.54 / PARAGRAPH_SCALE, 0.028 / PARAGRAPH_SCALE, PARAGRAPH_SCALE)

    local positions = {
        {-0.145, -0.1424}, {0.145, -0.1424},
        {-0.145, -0.2596}, {0.145, -0.2596},
    }
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
    BlzFrameSetPoint(subtitle, FRAMEPOINT_BOTTOM, contentDivider, FRAMEPOINT_TOP, 0, 0.013)

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
    RegisterClick(activeBack, function() UI.ShowCategory(JTG.Controller.lastCategory) end, "return")
    BlzFrameSetVisible(activeBack, false)
    UI.rootActivityBack = activeBack
    BlzFrameSetVisible(panel, false)
end

local function CreateCategoryPanel(category, categoryIndex)
    local panel = CreateNativePanel("JTGCategoryPanel" .. categoryIndex, GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    AddFooterDivider(panel)
    local contentDivider = AddContentDivider(panel, -0.087)
    if category.id == "skills" then BlzFrameSetVisible(contentDivider, false) end
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
    local skillGeneralLeft = nil
    local skillGeneralRight = nil
    for index, descriptor in ipairs(activities) do
        local column = math.floor((index - 1) / maxRows)
        local row = (index - 1) % maxRows
        if category.id == "skills" then
            column = (index - 1) % 2
            row = math.floor((index - 1) / 2)
        end
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
            -0.192 + column * 0.192,
            (category.id == "skills" and -0.1522 or -0.100) -
                row * (category.id == "skills" and 0.0562 or 0.055))
        if category.id == "skills" and row == 0 then
            if column == 0 then skillGeneralLeft = frame
            else skillGeneralRight = frame end
        end
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
    if category.id == "skills" then
        local generalHeading = CreateText("JTGSkillGeneralHeading", panel,
            "|cffffcc00General|r", 0.382, CATALOGUE_BUTTON_HEIGHT, 1.0)
        BlzFrameSetTextAlignment(generalHeading, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetFont(generalHeading, "Fonts\\FRIZQT__.TTF", 0.024, 0)
        BlzFrameSetPoint(generalHeading, FRAMEPOINT_CENTER, panel, FRAMEPOINT_TOP,
            -0.096, -0.122)
        local generalDivider = BlzCreateFrameByType("BACKDROP",
            "JTGSkillGeneralDivider", panel, "", 0)
        BlzFrameSetTexture(generalDivider, "JTGMenu\\MenuDivider.dds", 0, true)
        BlzFrameSetSize(generalDivider, 0.001, 0.0012)
        BlzFrameSetPoint(generalDivider, FRAMEPOINT_BOTTOMLEFT,
            skillGeneralLeft, FRAMEPOINT_TOPLEFT, 0.004, 0.0042)
        BlzFrameSetPoint(generalDivider, FRAMEPOINT_BOTTOMRIGHT,
            skillGeneralRight, FRAMEPOINT_TOPRIGHT, -0.004, 0.0042)
        BlzFrameSetLevel(generalDivider, 8)
        BlzFrameSetEnable(generalDivider, false)

        local raceHeading = CreateText("JTGSkillRaceHeading", panel,
            "|cffffcc00Race Specific|r", 0.176, CATALOGUE_BUTTON_HEIGHT, 1.0)
        BlzFrameSetTextAlignment(raceHeading, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetFont(raceHeading, "Fonts\\FRIZQT__.TTF", 0.024, 0)
        BlzFrameSetPoint(raceHeading, FRAMEPOINT_CENTER, panel, FRAMEPOINT_TOP,
            0.192, -0.122)
        local firstRaceFrame = nil
        for raceIndex, race in ipairs(JTG.SkillRaces) do
            local descriptor = {
                title = race.title, artwork = race.artwork, status = "available",
            }
            local frame, button, art = CreateIllustratedCard(
                "JTGSkillRaceButton" .. raceIndex, panel, descriptor,
                CATALOGUE_BUTTON_WIDTH, CATALOGUE_BUTTON_HEIGHT,
                0.0624, 0.0624, 0.110, 0.84, 0.020)
            BlzFrameClearAllPoints(art)
            BlzFrameSetPoint(art, FRAMEPOINT_CENTER, button,
                FRAMEPOINT_CENTER, 0.042, 0)
            BlzFrameSetPoint(frame, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP,
                0.192, -0.1522 - (raceIndex - 1) * 0.0562)
            if firstRaceFrame == nil then firstRaceFrame = frame end
            RegisterClick(button, function() UI.ShowSkillRace(race.id) end)
        end
        local raceDivider = BlzCreateFrameByType("BACKDROP",
            "JTGSkillRaceDivider", panel, "", 0)
        BlzFrameSetTexture(raceDivider, "JTGMenu\\MenuDivider.dds", 0, true)
        BlzFrameSetSize(raceDivider, 0.001, 0.0012)
        BlzFrameSetPoint(raceDivider, FRAMEPOINT_BOTTOMLEFT,
            firstRaceFrame, FRAMEPOINT_TOPLEFT, 0.004, 0.0042)
        BlzFrameSetPoint(raceDivider, FRAMEPOINT_BOTTOMRIGHT,
            firstRaceFrame, FRAMEPOINT_TOPRIGHT, -0.004, 0.0042)
        BlzFrameSetLevel(raceDivider, 8)
        BlzFrameSetEnable(raceDivider, false)
    end
    if firstActivityFrame ~= nil then
        BlzFrameClearAllPoints(summary)
        BlzFrameSetPoint(summary, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, 0)
        BlzFrameSetPoint(summary, FRAMEPOINT_BOTTOM, contentDivider, FRAMEPOINT_TOP, 0, 0.013)
    end

    local back = CreateButton("JTGCategoryBack" .. categoryIndex, panel, "Back",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, UI.ShowRoot, "return")
end


local function CreateSkillRacePanel(race, raceIndex)
    local panel = CreateNativePanel("JTGSkillRacePanel" .. raceIndex,
        GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    AddFooterDivider(panel)
    local contentDivider = AddContentDivider(panel, -0.087)
    UI.panels["skill_race_" .. race.id] = panel
    BlzFrameSetVisible(panel, false)

    local title = CreateText("JTGSkillRaceTitle" .. raceIndex, panel,
        "|cffffcc00Skill Training - Race Specific|r",
        TITLE_WIDTH, TITLE_HEIGHT, TITLE_SCALE)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, TITLE_TOP_OFFSET)
    local summary = CreateText("JTGSkillRaceSummary" .. raceIndex, panel,
        race.title .. " exercises.",
        0.54 / PARAGRAPH_SCALE, 0.025 / PARAGRAPH_SCALE, PARAGRAPH_SCALE)

    local activities = JTG.GetActivities("skills", race.id)
    local firstActivityFrame = nil
    for index, descriptor in ipairs(activities) do
        local column = (index - 1) % 3
        local row = math.floor((index - 1) / 3)
        local name = "JTGSkillRaceActivity" .. raceIndex .. "x" .. index
        local frame
        local button
        if descriptor.artwork ~= nil then
            frame, button = CreateIllustratedActivityCard(name, panel, descriptor)
        else
            button = CreateButton(name, panel,
                descriptor.title .. "  |cff808080[Planned]|r",
                CATALOGUE_BUTTON_WIDTH, CATALOGUE_BUTTON_HEIGHT)
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
                local raceData = {race = race.id}
                if descriptor.menu ~= nil then
                    JTG.OpenActivityMenu(descriptor.id, "skills", nil, raceData)
                else JTG.StartActivity(descriptor.id, "skills", raceData) end
            end)
        end
        UI.catalogueRows[descriptor.id .. "_" .. race.id] = button
    end
    if firstActivityFrame ~= nil then
        BlzFrameClearAllPoints(summary)
        BlzFrameSetPoint(summary, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, 0)
        BlzFrameSetPoint(summary, FRAMEPOINT_BOTTOM, contentDivider, FRAMEPOINT_TOP, 0, 0.013)
    end

    local back = CreateButton("JTGSkillRaceBack" .. raceIndex, panel, "Back",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, function() UI.ShowCategory("skills") end, "return")
end

local function CreateInfoPanel(key, titleText, bodyText, index, scrollable)
    local panel = CreateNativePanel("JTGInfoPanel" .. index, GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    local footerDivider = AddFooterDivider(panel)
    UI.panels[key] = panel
    BlzFrameSetVisible(panel, false)
    local title = CreateText("JTGInfoTitle" .. index, panel, "|cffffcc00" .. titleText .. "|r",
        TITLE_WIDTH, TITLE_HEIGHT, TITLE_SCALE)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, TITLE_TOP_OFFSET)
    local body
    if scrollable then
        local lines = {}
        for line in string.gmatch(bodyText .. "\n", "(.-)\n") do
            table.insert(lines, line)
        end
        -- Use the available space down to the footer divider. Pagination is
        -- line based so the slider always maps to a stable part of the notes.
        local visibleLines = 22
        local maximumStart = math.max(1, #lines - visibleLines + 1)
        local pages = {}
        for first = 1, maximumStart do
            local page = {}
            for lineIndex = first,
                    math.min(#lines, first + visibleLines - 1) do
                table.insert(page, lines[lineIndex])
            end
            local pageFrame = CreateText("JTGInfoBody" .. index .. "x" .. first,
                panel, table.concat(page, "\n"),
                0.49 / PARAGRAPH_SCALE, 0.273 / PARAGRAPH_SCALE,
                PARAGRAPH_SCALE)
            BlzFrameSetTextAlignment(pageFrame, TEXT_JUSTIFY_TOP,
                TEXT_JUSTIFY_LEFT)
            BlzFrameSetPoint(pageFrame, FRAMEPOINT_TOP, title,
                FRAMEPOINT_BOTTOM, 0, -0.025)
            BlzFrameSetEnable(pageFrame, false)
            BlzFrameSetVisible(pageFrame, first == 1)
            pages[first] = pageFrame
        end
        body = pages[1]

        local slider = BlzCreateFrameByType("SLIDER",
            "JTGInfoScrollBar" .. index, panel, "QuestMainListScrollBar",
            index)
        BlzFrameClearAllPoints(slider)
        BlzFrameSetSize(slider, 0.012, 0.258)
        BlzFrameSetPoint(slider, FRAMEPOINT_TOPLEFT, body,
            FRAMEPOINT_TOPRIGHT, 0.007, 0)
        BlzFrameSetMinMaxValue(slider, 1, maximumStart)
        BlzFrameSetStepSize(slider, 1)
        BlzFrameSetVisible(slider, maximumStart > 1)

        local shownPage = 1
        local function showPage(value)
            local sliderValue = math.floor((value or maximumStart) + 0.5)
            local first = maximumStart - sliderValue + 1
            first = math.max(1, math.min(maximumStart, first))
            if first ~= shownPage then
                BlzFrameSetVisible(pages[shownPage], false)
                BlzFrameSetVisible(pages[first], true)
                shownPage = first
            end
        end

        local sliderTrigger = CreateTrigger()
        BlzTriggerRegisterFrameEvent(sliderTrigger, slider,
            FRAMEEVENT_SLIDER_VALUE_CHANGED)
        TriggerAddAction(sliderTrigger, function()
            showPage(BlzGetTriggerFrameValue())
        end)

        -- Build every page once. Scrolling only changes frame visibility,
        -- avoiding the cursor flicker caused by replacing text during a
        -- pointer event.
        local wheelCatcher = BlzCreateFrameByType("BUTTON",
            "JTGInfoScrollWheel" .. index, panel, "", index)
        BlzFrameSetAllPoints(wheelCatcher, body)
        local wheelTrigger = CreateTrigger()
        BlzTriggerRegisterFrameEvent(wheelTrigger, wheelCatcher,
            FRAMEEVENT_MOUSE_WHEEL)
        TriggerAddAction(wheelTrigger, function()
            local value = BlzFrameGetValue(slider)
            if BlzGetTriggerFrameValue() > 0 then value = value + 1
            else value = value - 1 end
            value = math.max(1, math.min(maximumStart, value))
            BlzFrameSetValue(slider, value)
            showPage(value)
        end)

        BlzFrameSetValue(slider, maximumStart)
        showPage(maximumStart)
    else
        body = CreateText("JTGInfoBody" .. index, panel, bodyText,
            0.52 / PARAGRAPH_SCALE, 0.30 / PARAGRAPH_SCALE, PARAGRAPH_SCALE)
        BlzFrameSetTextAlignment(body, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
        BlzFrameSetPoint(body, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM, 0, -0.025)
    end
    local back = CreateButton("JTGInfoBack" .. index, panel, "Back",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, UI.ShowRoot, "return")
end

local function CreateActivityBriefingPanel()
    local panel = CreateNativePanel("JTGActivityBriefing", GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    AddFooterDivider(panel)
    UI.activityBriefingContentDivider = AddContentDivider(panel, -0.265)
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
    BlzFrameSetEnable(UI.activityBriefingBody, false)

    UI.activityBriefingButtons = {}
    UI.activityBriefingTooltipText = {}
    for index = 1, 15 do
        local button = CreateButton("JTGActivityBriefingChoice" .. index, panel, "", 0.190, 0.042)
        BlzFrameSetPoint(button, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, -0.305)
        UI.activityBriefingButtons[index] = button
        RegisterClick(button, function()
            local choice = UI.activityBriefingVisibleActions and UI.activityBriefingVisibleActions[index]
            if choice ~= nil and choice.action ~= nil then choice.action() end
        end)
    end

    local back = CreateButton("JTGActivityBriefingBack", panel, "Back",
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    BlzFrameSetPoint(back, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM, 0, 0.035)
    RegisterClick(back, function()
        if UI.activityBriefingBackAction ~= nil then UI.activityBriefingBackAction() end
    end, "return")
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
    end, "return")
    UI.activityBriefingResume = resume
    BlzFrameSetVisible(resume, false)
end

local function CreateToolbar()
    local bar = BlzCreateFrameByType("FRAME", "JTGActivityToolbar", GAME_UI, "", 0)
    -- Toolbars share two left-aligned rows beginning below the left edge of
    -- the gold resource window. Both row and column gaps are half a button.
    BlzFrameSetSize(bar, 0.285, 0.060)
    BlzFrameSetAbsPoint(bar, FRAMEPOINT_TOPLEFT,
        TOOLBAR_LEFT, TOOLBAR_TOP)
    UI.toolbar = bar

    local topRow = {}
    local bottomRow = {}

    local function toolbarButton(name, label)
        local button = CreateButton(name, bar, label,
            TOOLBAR_BUTTON_WIDTH, TOOLBAR_BUTTON_HEIGHT)
        local text = FindButtonText(button)
        if text ~= nil then BlzFrameSetScale(text, 0.72) end
        return button
    end

    local restart = toolbarButton("JTGToolbarRestart", "Redo")
    AttachTooltip(restart, "Cleanly reset the current activity and begin it again.", "left")
    RegisterClick(restart, JTG.ResetActivity)
    UI.toolbarButtons.restart = restart
    table.insert(bottomRow, restart)
    local menu = toolbarButton("JTGToolbarMenu", "Menu")
    AttachTooltip(menu, "Change this exercise's configuration or return to the training menus.", "left")
    RegisterClick(menu, JTG.OpenTrainingMenu)
    UI.toolbarButtons.menu = menu
    table.insert(topRow, menu)

    local lastRunner = toolbarButton("JTGToolbarLastRunner", "Last Runner")
    AttachTooltip(lastRunner, "Restart the exercise against the previous runner.", "left")
    BlzFrameSetEnable(lastRunner, false)
    BlzFrameSetAlpha(lastRunner, 145)
    RegisterClick(lastRunner, JTG.LastRunnerActivity)
    UI.toolbarButtons.lastRunner = lastRunner
    table.insert(bottomRow, lastRunner)

    -- Match the aspect ratio of Warcraft's native Quest-button notification
    -- effect, which is authored for the wider upper-button-bar controls.
    local pause = toolbarButton("JTGToolbarPause", "Pause")
    RegisterClick(pause, UI.ToggleExercisePause, function()
        return UI.exercisePaused and "return" or "normal"
    end)
    UI.toolbarButtons.pause = pause
    -- Use Warcraft's authored rectangular Quest-button notification model.
    -- Unlike the square autocast model, this is the native upper-button-bar
    -- effect and can be matched directly to the Unpause button.
    UI.unpauseHighlights = {}
    local pauseHighlight = BlzCreateFrameByType("SPRITE",
        "JTGToolbarPauseHighlight", bar, "", 0)
    BlzFrameSetSize(pauseHighlight, 0.058, 0.024)
    -- The native Quest model's visible particles sit to the right of its
    -- frame origin. Offset the host frame so the rendered border centers on
    -- the wider Pause/Unpause button.
    BlzFrameSetPoint(pauseHighlight, FRAMEPOINT_CENTER, pause,
        FRAMEPOINT_CENTER, -0.0125, 0)
    BlzFrameSetModel(pauseHighlight,
        "UI\\Feedback\\QuestButton\\UI-QuestButtonOn.mdl", 0)
    BlzFrameSetLevel(pauseHighlight, 3)
    BlzFrameSetEnable(pauseHighlight, false)
    BlzFrameSetVisible(pauseHighlight, false)
    table.insert(UI.unpauseHighlights, pauseHighlight)
    BlzFrameSetLevel(pause, 2)
    table.insert(topRow, pause)
    UI.LayoutToolbar = function()
        local function layoutRow(buttons, offsetY)
            local previous = nil
            for _, button in ipairs(buttons) do
                BlzFrameClearAllPoints(button)
                if BlzFrameIsVisible(button) then
                    if previous == nil then
                        BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, bar,
                            FRAMEPOINT_TOPLEFT, 0, offsetY)
                    else
                        BlzFrameSetPoint(button, FRAMEPOINT_LEFT, previous,
                            FRAMEPOINT_RIGHT, TOOLBAR_BUTTON_GAP, 0)
                    end
                    previous = button
                end
            end
        end
        layoutRow(topRow, 0)
        layoutRow(bottomRow, -TOOLBAR_ROW_STEP)
    end
    UI.LayoutToolbar()
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
    RegisterClick(resume, JTG.ResumeActivity, "return")
    BlzFrameSetVisible(resume, false)
    UI.pausedActivityResume = resume
end

function UI.AbandonForLoad()
    UI.epoch = (UI.epoch or 0) + 1
    if UI.loadWarningTimer ~= nil then
        PauseTimer(UI.loadWarningTimer)
        DestroyTimer(UI.loadWarningTimer)
        UI.loadWarningTimer = nil
    end
    if UI.unpauseHighlightTimer ~= nil then
        PauseTimer(UI.unpauseHighlightTimer)
        DestroyTimer(UI.unpauseHighlightTimer)
        UI.unpauseHighlightTimer = nil
    end
    if UI.questHighlightTimer ~= nil then
        PauseTimer(UI.questHighlightTimer)
        DestroyTimer(UI.questHighlightTimer)
        UI.questHighlightTimer = nil
    end
    if UI.nativeMenuMonitor ~= nil then
        PauseTimer(UI.nativeMenuMonitor)
        DestroyTimer(UI.nativeMenuMonitor)
    end
    local triggers = {
        UI.clickTrigger, UI.escapeTrigger, UI.nativeMenuTrigger,
        UI.nativeKeyTrigger, UI.nativeCloseTrigger, UI.nativeLoadTrigger,
    }
    for _, trigger in ipairs(triggers) do
        if trigger ~= nil then
            DisableTrigger(trigger)
            DestroyTrigger(trigger)
        end
    end
    GAME_UI = nil
    keyboardFocusSink = nil
    tooltipCount = 0
    nativePanelContext = 100
    footerDividerCount = 0
    UI.panels = {}
    UI.categoryButtons = {}
    UI.catalogueRows = {}
    UI.toolbarButtons = {}
    UI.clickActions = {}
    UI.clickSounds = {}
    UI.tooltips = {}
    UI.nativeHiddenFrames = {}
    UI.activityBriefingActions = nil
    UI.activityBriefingVisibleActions = nil
    UI.activityBriefingButtons = nil
    UI.activityBriefingTooltipText = nil
    UI.currentBackAction = nil
    UI.clickTrigger = nil
    UI.escapeTrigger = nil
    UI.nativeMenuTrigger = nil
    UI.nativeKeyTrigger = nil
    UI.nativeCloseTrigger = nil
    UI.nativeLoadTrigger = nil
    UI.nativeMenuMonitor = nil
    UI.nativeCloseHooks = {}
    UI.nativeLoadHooks = {}
    UI.nativeLoadPanelWasVisible = false
    UI.fullQuestTextFrameId = nil
    UI.questAvailable = false
    UI.questHighlight = nil
    UI.questHighlightTimer = nil
    UI.loadWarningText = nil
    UI.unpauseHighlights = nil
    UI.unpauseHighlightActive = false
    UI.nativeMenuOpen = false
    UI.nativeSuspendQueued = false
    UI.nativeCloseTicks = 0
    UI.nativePausedGameplayMenu = nil
    UI.nativePausedExercise = nil
    UI.nativePauseReleased = false
    UI.nativeSaveLoadSeen = false
    UI.deferGlobalPause = false
    UI.normalButtonSound = nil
    UI.returnButtonSound = nil
    UI.menuShade = nil
    UI.toolbar = nil
    UI.pausedActivityResume = nil
    UI.pausedActivityExit = nil
    UI.rootActivityBack = nil
    UI.rootCredits = nil
    UI.rootPatch = nil
    UI.activityBriefingContentDivider = nil
    UI.activityBriefingTitle = nil
    UI.activityBriefingArtwork = nil
    UI.activityBriefingBody = nil
    UI.activityBriefingBack = nil
    UI.activityBriefingExit = nil
    UI.activityBriefingResume = nil
    UI.menuVisible = false
end

function UI.RestoreLoadedView(view)
    local target = view or {kind = "root"}
    local session = JTG.Controller and JTG.Controller.session
    -- Newly reconstructed frames inherit their template visibility. Establish
    -- a clean baseline before restoring exactly one saved surface.
    UI.HideAllPanels()
    UI.HideToolbar()
    if session ~= nil then
        if target.kind ~= "gameplay" and session.activity ~= nil then
            if session.activity.hidePresentationForMenu ~= nil then
                session.activity:hidePresentationForMenu()
            elseif session.activity.setOverlayVisible ~= nil then
                session.activity:setOverlayVisible(false)
            end
        end
        if target.kind == "activity_briefing" then
            JTG.OpenActivityMenu(session.id, JTG.Controller.lastCategory,
                target.page, target.data)
        elseif target.kind == "root" then
            UI.ShowRoot()
        elseif target.kind == "category" then
            UI.ShowCategory(target.id or JTG.Controller.lastCategory)
        elseif target.kind == "skill_race" then
            UI.ShowSkillRace(target.id)
        elseif target.kind == "info" then
            UI.ShowInfo(target.id)
        elseif session.activity and session.activity.restorePresentation then
            session.activity:restorePresentation()
        else
            UI.ShowToolbar(session.descriptor.capabilities)
        end
        ApplyActivityPause()
        return
    end
    UI.gameplayMenuPaused = false
    UI.exercisePaused = false
    if target.kind == "activity_briefing" and target.id ~= nil then
        JTG.OpenActivityMenu(target.id, target.category, target.page, target.data)
    elseif target.kind == "category" then UI.ShowCategory(target.id)
    elseif target.kind == "skill_race" then UI.ShowSkillRace(target.id)
    elseif target.kind == "info" then UI.ShowInfo(target.id)
    else UI.ShowRoot() end
    ApplyActivityPause()
end

function UI.QueuePostLoadViewRestore(view)
    local target = view or {kind = "root"}
    local epoch = UI.epoch
    local attempts = 0
    local clearTicks = 0
    local timer = CreateTimer()
    TimerStart(timer, 0.05, true, function()
        attempts = attempts + 1
        if UI.epoch ~= epoch then
            PauseTimer(timer)
            DestroyTimer(timer)
            return
        end
        if NativeMenuIsVisible() then
            clearTicks = 0
        else
            clearTicks = clearTicks + 1
        end
        if clearTicks < 3 and attempts < 40 then return end
        PauseTimer(timer)
        DestroyTimer(timer)
        if UI.nativeMenuOpen then RestoreAfterNativeMenu() end
        -- Warcraft may hide frames created during EVENT_GAME_LOADED while it
        -- tears down the Load interface. Assert the saved view once more only
        -- after that native transition has settled.
        UI.deferGlobalPause = false
        UI.RestoreLoadedView(target)
    end)
end

function UI.Initialize(restoring)
    GAME_UI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    UI.loadWarningText = CreateText("JTGPausedLoadWarning", GAME_UI, "",
        0.72, 0.024, 1.55)
    -- Keep the instruction independent of Warcraft's native Load dialog, but
    -- place it in the dialog's open space immediately above its button row.
    BlzFrameSetAbsPoint(UI.loadWarningText, FRAMEPOINT_CENTER, 0.40, 0.302)
    BlzFrameSetLevel(UI.loadWarningText, 10000)
    BlzFrameSetEnable(UI.loadWarningText, false)
    BlzFrameSetVisible(UI.loadWarningText, false)
    UI.normalButtonSound = CreateSound("Sound\\Interface\\BigButtonClick.wav", false, false, false, 10, 10, "")
    UI.returnButtonSound = CreateSound("Sound\\Interface\\GamePause.wav", false, false, false, 10, 10, "")
    UI.clickTrigger = CreateTrigger()
    TriggerAddAction(UI.clickTrigger, function()
        local clickedFrame = BlzGetTriggerFrame()
        local action = UI.clickActions[GetHandleId(clickedFrame)]
        if action ~= nil then
            local soundKind = UI.clickSounds[GetHandleId(clickedFrame)]
            if type(soundKind) == "function" then soundKind = soundKind() end
            PlayButtonSound(soundKind)
            ReleaseFrameFocus(clickedFrame)
            if UI.gameplayMenuPaused or UI.exercisePaused then
                action()
                ReleaseFrameFocus(clickedFrame)
                ReleaseKeyboardFocusAfterClick()
                return
            end
            local epoch = UI.epoch
            local releaseTimer = CreateTimer()
            TimerStart(releaseTimer, 0.00, false, function()
                DestroyTimer(releaseTimer)
                if UI.epoch ~= epoch then return end
                action()
                ReleaseFrameFocus(clickedFrame)
                ReleaseKeyboardFocusAfterClick()
            end)
        end
    end)
    UI.escapeTrigger = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(UI.escapeTrigger, Player(0), OSKEY_ESCAPE, 0, true)
    TriggerAddAction(UI.escapeTrigger, function()
        if UI.nativeMenuOpen then
            RestoreAfterNativeMenu()
            return
        end
        if UI.menuVisible and UI.currentBackAction ~= nil then
            UI.currentBackAction()
        end
    end)
    -- Key events continue to fire while PauseGame is active and let us keep
    -- the custom interface synchronized with Warcraft's native menus.
    UI.nativeKeyTrigger = CreateTrigger()
    local nativeKeys = {
        OSKEY_F9, OSKEY_F10, OSKEY_F11, OSKEY_F12,
    }
    for _, key in ipairs(nativeKeys) do
        BlzTriggerRegisterPlayerKeyEvent(UI.nativeKeyTrigger, Player(0), key, 0, true)
    end
    TriggerAddAction(UI.nativeKeyTrigger, function()
        if BlzGetTriggerPlayerKey() == OSKEY_F9 and not UI.questAvailable then
            -- Disabling the upper-bar frame blocks its mouse action. Some
            -- clients dispatch F9 directly, so close that native dialog on
            -- the following UI frame as a defensive fallback.
            local closeTimer = CreateTimer()
            TimerStart(closeTimer, 0.00, false, function()
                DestroyTimer(closeTimer)
                local dialog = BlzGetFrameByName("QuestDialog", 0)
                local done = BlzGetFrameByName("QuestAcceptButton", 0)
                if dialog ~= nil and done ~= nil and
                        BlzFrameIsVisible(dialog) then
                    BlzFrameClick(done)
                end
            end)
            return
        end
        if UI.nativeMenuOpen then
            RestoreAfterNativeMenu()
            return
        end
        SuspendForNativeMenu()
    end)
    UI.nativeMenuTrigger = CreateTrigger()
    UI.nativeCloseHooks = {}
    UI.nativeCloseTrigger = CreateTrigger()
    TriggerAddAction(UI.nativeCloseTrigger, RestoreAfterNativeMenu)
    UI.nativeLoadHooks = {}
    UI.nativeLoadTrigger = CreateTrigger()
    TriggerAddAction(UI.nativeLoadTrigger, function()
        -- Loading is deliberately never force-unpaused. Warcraft does not
        -- expose every native save activation method, so paused loading uses
        -- one consistent instruction for clicks, keys and double-clicks.
        -- Restart Mission remains a native map transition that needs the
        -- script-owned pause released before it can proceed.
        local frame = BlzGetTriggerFrame()
        local restart = BlzGetFrameByName("RestartButton", 0)
        local loadMenu = BlzGetFrameByName("LoadGameButton", 0)
        if restart ~= nil and frame == restart then
            ReleasePauseForNativeSystemMenu(true)
        elseif loadMenu ~= nil and frame == loadMenu and
                (UI.exercisePaused == true or UI.gameplayMenuPaused == true) then
            WarnPausedLoad()
        end
    end)
    HookNativeCloseButtons()
    HookNativeLoadButtons()
    local nativeButtons = {
        BlzGetOriginFrame(ORIGIN_FRAME_QUEST_BUTTON, 0),
        BlzGetOriginFrame(ORIGIN_FRAME_ALLY_BUTTON, 0),
        BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG_BUTTON, 0),
    }
    for _, button in ipairs(nativeButtons) do
        if button ~= nil then
            BlzTriggerRegisterFrameEvent(UI.nativeMenuTrigger, button,
                FRAMEEVENT_CONTROL_CLICK)
        end
    end
    -- The system button is intentionally not hooked: merely observing its
    -- click prevents Warcraft from opening F10. The visibility monitor handles
    -- the system menu after Warcraft opens it, as it already does for F10.
    TriggerAddAction(UI.nativeMenuTrigger, function()
        if UI.nativeMenuOpen then
            RestoreAfterNativeMenu()
        elseif UI.gameplayMenuPaused or UI.exercisePaused then
            -- Timers do not advance under PauseGame, so hide synchronously.
            SuspendForNativeMenu()
        else
            QueueNativeMenuSuspend()
        end
    end)
    CreateRootPanel()
    for index, category in ipairs(JTG.Categories) do CreateCategoryPanel(category, index) end
    for index, race in ipairs(JTG.SkillRaces) do CreateSkillRacePanel(race, index) end
    CreateInfoPanel("patch", "Patch Notes",
        "|cffffcc00v0.0.9|r  |cffb0b0b02 October 2026|r\n" ..
        "- Added Windwalk Pop training, Hard Mode and counterplay.\n\n" ..
        "|cffffcc00v0.0.8|r  |cffb0b0b01 October 2026|r\n" ..
        "- Added the Unit Controls tutorial and optional tutorial topics.\n\n" ..
        "|cffffcc00v0.0.7|r  |cffb0b0b029 September 2026|r\n" ..
        "- Added Mining Micro training for Human and Orc workers.\n\n" ..
        "|cffffcc00v0.0.6|r  |cffb0b0b029 September 2026|r\n" ..
        "- Added the Camera tutorial, covering essential camera controls and navigation.\n\n" ..
        "|cffffcc00v0.0.5|r  |cffb0b0b028 September 2026|r\n" ..
        "- Added save and load support across menus and exercises.\n" ..
        "- Added race-specific Skill Training catalogues.\n" ..
        "- Improved menu layouts, native-menu integration and exercise controls.\n\n" ..
        "|cffffcc00v0.0.4|r  |cffb0b0b027 September 2026|r\n" ..
        "- Added Demonstration: Power Building.\n" ..
        "- Improved native-menu integration.\n\n" ..
        "|cffffcc00v0.0.3|r  |cffb0b0b027 September 2026|r\n" ..
        "- Added Training: Body Blocking.\n" ..
        "- Reworked menus.\n\n" ..
        "|cffffcc00v0.0.2|r  |cffb0b0b025 September 2026|r\n" ..
        "- Implemented menu structure.\n" ..
        "- Implemented base architecture.\n\n" ..
        "|cffffcc00v0.0.1|r  |cffb0b0b024 September 2026|r\n" ..
        "- Cleaned up source map.\n" ..
        "- Implemented menu-to-game environment transition.", 1, true)
    CreateInfoPanel("credits", "Credits",
        "Project started by |cffffcc00Jamie|r and currently run by |cffffcc00Solanum|r.\n\n" ..
        "Contributors: AoW, poison, floss2xdaily, Kaccel, MadPad09 and Solstice1221.\n\n" ..
        "Map adapted from Twisted Meadows by McCandish, MMC and W3Champions.\n\n" ..
        "Warcraft III belongs to Blizzard Entertainment.", 2)
    CreateActivityBriefingPanel()
    CreateToolbar()
    CreatePausedActivityResume()
    local questButton = BlzGetFrameByName("UpperButtonBarQuestsButton", 0) or
        BlzGetOriginFrame(ORIGIN_FRAME_QUEST_BUTTON, 0)
    if questButton ~= nil then
        UI.questHighlight = BlzCreateFrameByType("SPRITE",
            "JTGQuestButtonHighlight", GAME_UI, "", 0)
        BlzFrameSetSize(UI.questHighlight, 0.058, 0.024)
        BlzFrameSetPoint(UI.questHighlight, FRAMEPOINT_CENTER,
            questButton, FRAMEPOINT_CENTER, -0.0125, 0)
        BlzFrameSetModel(UI.questHighlight,
            "UI\\Feedback\\QuestButton\\UI-QuestButtonOn.mdl", 0)
        BlzFrameSetLevel(UI.questHighlight, 3)
        BlzFrameSetEnable(UI.questHighlight, false)
        BlzFrameSetVisible(UI.questHighlight, false)
    end
    local activeSession = JTG.Controller and JTG.Controller.session
    UI.SetQuestAvailable(activeSession ~= nil and
        activeSession.descriptor.capabilities.quests == true)
    if not restoring then UI.ShowRoot() end
    StartNativeMenuMonitor()
end
