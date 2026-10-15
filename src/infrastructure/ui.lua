-- Permanent map-owned menu and shared activity controls.
JTG = JTG or {}
JTG.UI = {
    panels = {}, categoryButtons = {}, catalogueRows = {}, toolbarButtons = {},
    clickActions = {}, clickSounds = {}, clickTrigger = nil,
    rightClickActions = {}, rightClickTrigger = nil, hoverTrigger = nil,
    hoveredRightClickFrame = nil, browsingActivity = false,
    nativeHiddenFrames = {}, tooltips = {},
    epoch = 0, currentView = {kind = "root"},
}

local UI = JTG.UI
-- Native summon variants use different names as well as different rawcodes.
local SUMMON_LEVELS = {
    hwat="1",hwt2="2",hwt3="3",
    osw1="1",osw2="2",osw3="3",
    o001="1",o002="2",o003="3",osp1="1",osp2="2",osp3="3",
    ucs1="1",ucs2="2",ucs3="3",
    nlv1="1",nlv2="2",nlv3="3",
    nqb1="1",nqb2="2",nqb3="3",
    ngz1="1",ngz2="2",ngz3="3",
    nwe1="1",nwe2="2",nwe3="3",
    ndr1="1",ndr2="2",ndr3="3",
}
function UI.GetSummonLevelBadge(choice)
    return choice.badge or SUMMON_LEVELS[choice.unitRawcode] or
        (choice.label or ""):match("Level (%d+)") or (choice.label or ""):match("Lvl (%d+)")
end

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
    slots = {
        menu = 1, back = 2, topics = 3, optional = 4,
        continue = 5, next = 5, restart = 6, pause = 7,
        setups = 3, rotate = 8, squares = 8,
    },
}

function UI.PlaceToolbarButton(button, slot, bar)
    local index = math.max(1, math.min(8, slot or 1)) - 1
    local column = index % 4
    local row = math.floor(index / 4)
    BlzFrameClearAllPoints(button)
    BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, bar, FRAMEPOINT_TOPLEFT,
        column * (TOOLBAR_BUTTON_WIDTH + TOOLBAR_BUTTON_GAP),
        -row * TOOLBAR_ROW_STEP)
end
local PARAGRAPH_SCALE = 1.18
local CATALOGUE_BUTTON_WIDTH = 0.190
local CATALOGUE_BUTTON_HEIGHT = 0.052
local FOOTER_BUTTON_WIDTH = 0.17
local FOOTER_BUTTON_HEIGHT = 0.044
local MENU_DIVIDER_WIDTH = 0.52
local MENU_DIVIDER_HEIGHT = 0.0012
local MENU_FOOTER_DIVIDER_Y = 0.092
local MENU_FOOTER_BUTTON_Y = 0.035
local MENU_FOOTER_SIDE_INSET = 0.045
local MENU_BODY_BOTTOM_GAP = 0.013
local BRIEFING_CHOICE_WIDTH = 0.190
local BRIEFING_CHOICE_HEIGHT = 0.042
local BRIEFING_COMPACT_CHOICE_WIDTH = 0.165
local BRIEFING_COMPACT_CHOICE_HEIGHT = 0.033
local BRIEFING_IMAGE_CENTER_X = 0.167
local BRIEFING_IMAGE_TOP_OFFSET = -0.025
local BRIEFING_DIVIDER_BUTTON_GAP = 0.013
local BRIEFING_COMMAND_BUTTON_SIZE = 0.043
local BRIEFING_COMMAND_BUTTON_STEP = BRIEFING_COMMAND_BUTTON_SIZE
local BRIEFING_COMMAND_GRID_TOP = -0.247
local SECTIONED_CATEGORY_LAYOUTS = {advanced = true}
local footerDividerCount = 0

UI.MenuLayout = {
    width = MENU_WIDTH,
    height = MENU_HEIGHT,
    titleTopOffset = TITLE_TOP_OFFSET,
    dividerWidth = MENU_DIVIDER_WIDTH,
    footerDividerY = MENU_FOOTER_DIVIDER_Y,
    footerButtonY = MENU_FOOTER_BUTTON_Y,
    briefingChoiceWidth = BRIEFING_CHOICE_WIDTH,
    briefingChoiceHeight = BRIEFING_CHOICE_HEIGHT,
    briefingImageCenterX = BRIEFING_IMAGE_CENTER_X,
    briefingImageTopOffset = BRIEFING_IMAGE_TOP_OFFSET,
}

local function SetActivityOverlayVisible(visible)
    local session = JTG.Controller and JTG.Controller.session
    local activity = session and session.activity
    if activity ~= nil and activity.setOverlayVisible ~= nil then
        local ok, message = pcall(activity.setOverlayVisible, activity, visible == true)
        if not ok then print("JTG overlay visibility warning: " .. tostring(message)) end
    end
end

UI.SetActivityOverlayVisible = SetActivityOverlayVisible

local function HideActivityPresentationForMenu()
    local session = JTG.Controller and JTG.Controller.session
    local activity = session and session.activity
    if activity ~= nil and activity.hidePresentationForMenu ~= nil then
        activity:hidePresentationForMenu()
    else
        SetActivityOverlayVisible(false)
    end
end

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
    BlzFrameSetSize(divider, MENU_DIVIDER_WIDTH, MENU_DIVIDER_HEIGHT)
    BlzFrameSetPoint(divider, FRAMEPOINT_BOTTOM, panel, FRAMEPOINT_BOTTOM,
        0, MENU_FOOTER_DIVIDER_Y)
    BlzFrameSetLevel(divider, 8)
    BlzFrameSetEnable(divider, false)
    return divider
end

local function AddContentDivider(panel, topOffset)
    footerDividerCount = footerDividerCount + 1
    local divider = BlzCreateFrameByType("BACKDROP",
        "JTGMenuContentDivider" .. footerDividerCount, panel, "", 0)
    BlzFrameSetTexture(divider, "JTGMenu\\MenuDivider.dds", 0, true)
    BlzFrameSetSize(divider, MENU_DIVIDER_WIDTH, MENU_DIVIDER_HEIGHT)
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
    local status = descriptor.cardStatus and ("\n|cffaaaaaa" .. descriptor.cardStatus .. "|r") or
        (isAvailable and "" or "\n|cffaaaaaaPLANNED|r")
    local button = CreateButton(name, parent,
        "|cffffcc00" .. (descriptor.cardTitle or descriptor.title) .. "|r" .. status, width, height)
    local art = BlzCreateFrameByType("BACKDROP", name .. "Artwork", button, "", 0)
    BlzFrameSetTexture(art, descriptor.artwork, 0, true)
    BlzFrameSetSize(art, artWidth, artHeight)
    BlzFrameSetPoint(art, FRAMEPOINT_RIGHT, button, FRAMEPOINT_RIGHT,
        -0.004 + (descriptor.artworkOffsetX or 0), descriptor.artworkOffsetY or 0)
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
    if descriptor.artworkAlignTop == true then
        BlzFrameClearAllPoints(art)
        BlzFrameSetPoint(art, FRAMEPOINT_TOPRIGHT, button, FRAMEPOINT_TOPRIGHT,
            -0.004 + (descriptor.artworkOffsetX or 0), 0)
    elseif descriptor.centerArtwork == true then
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
        0.25, 0.088, 0.169, 0.082, 0.120, 1.0, 0.020)
    BlzFrameClearAllPoints(art)
    BlzFrameSetPoint(art, FRAMEPOINT_CENTER, button, FRAMEPOINT_CENTER,
        0.0585, 0)
    return frame, button, art
end

local function WrapTooltipText(description)
    local wrapped = {}
    description = description:gsub("|n", "\n")
    for line in string.gmatch(description .. "\n", "([^\n]*)\n") do
        local current, length = "", 0
        for word in line:gmatch("%S+") do
            local visible = word:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
            local wordLength = #visible
            if length > 0 and length + 1 + wordLength > 45 then
                table.insert(wrapped, current)
                current, length = "", 0
            end
            current = current .. (length > 0 and " " or "") .. word
            length = length + (length > 0 and 1 or 0) + wordLength
        end
        table.insert(wrapped, current)
    end
    return table.concat(wrapped, "|n")
end

local function TooltipHeight(description)
    -- Count visible text and both supported line-break forms, rather than
    -- treating Warcraft formatting codes as printable characters.
    description = description:gsub("|n", "\n")
        :gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    local lines = 0
    for line in string.gmatch(description .. "\n", "([^\n]*)\n") do
        -- Warcraft's stock tooltip text uses nearly the full interior width.
        -- This estimate only chooses the box height; the engine still performs
        -- the actual word wrapping according to the rendered font metrics.
        lines = lines + math.max(1, math.ceil(string.len(line) / 45))
    end
    return math.max(0.025, 0.012 + lines * 0.009)
end

local function CreateTooltipSlice(name, parent, texture, width, height, point)
    local slice = BlzCreateFrameByType("BACKDROP", name, parent, "", 0)
    BlzFrameSetTexture(slice, texture, 0, true)
    BlzFrameSetSize(slice, width, height)
    BlzFrameSetPoint(slice, point, parent, point, 0, 0)
    BlzFrameSetEnable(slice, false)
    return slice
end

local function AttachTooltip(button, description, side, scope)
    description = WrapTooltipText(description)
    tooltipCount = tooltipCount + 1
    local tooltip = BlzCreateFrameByType("FRAME", "JTGTooltip" .. tooltipCount,
        GAME_UI, "", 0)
    local width = 0.235
    local height = TooltipHeight(description)
    BlzFrameSetSize(tooltip, width, height)
    -- Keep the top and width fixed so extra lines extend downward.
    BlzFrameSetAbsPoint(tooltip, FRAMEPOINT_TOPRIGHT, 0.728, 0.135 + height)
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
    local left = CreateTooltipSlice(prefix .. "Left", tooltip, "JTGMenu\\TooltipLeft.dds",
        corner, innerHeight, FRAMEPOINT_LEFT)
    local center = CreateTooltipSlice(prefix .. "Center", tooltip, "JTGMenu\\TooltipCenter.dds",
        innerWidth, innerHeight, FRAMEPOINT_CENTER)
    local right = CreateTooltipSlice(prefix .. "Right", tooltip, "JTGMenu\\TooltipRight.dds",
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
    if scope then JTG.ScopeTrackFrame(scope,tooltip)
    else table.insert(UI.tooltips, tooltip) end
    local function updateText(text)
        text = WrapTooltipText(text)
        -- Let the engine measure wrapped text at this fixed width; the height
        -- estimate is retained when layout has not resolved yet (hidden frames).
        BlzFrameSetSize(label,0.223 / tooltipTextScale,0)
        BlzFrameSetText(label,text)
        local renderedHeight=BlzFrameGetHeight(label)*tooltipTextScale
        local newHeight = renderedHeight > 0 and math.max(0.025, renderedHeight + 0.012) or TooltipHeight(text)
        BlzFrameSetSize(tooltip, width, newHeight)
        BlzFrameSetSize(left, corner, newHeight - corner * 2)
        BlzFrameSetSize(center, innerWidth, newHeight - corner * 2)
        BlzFrameSetSize(right, corner, newHeight - corner * 2)
        BlzFrameSetSize(label, 0.223 / tooltipTextScale,
            (newHeight - 0.012) / tooltipTextScale)
        BlzFrameSetText(label, text)
    end
    updateText(description)
    return tooltip, label, updateText
end

function UI.AttachActivityTooltip(scope,button,description)
    return AttachTooltip(button,description,nil,scope)
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

    -- Warcraft may restore native anchors when the selected quest changes,
    -- even while reusing the same frame handle. Reapply while it is visible.

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
        local questDialog = BlzGetFrameByName("QuestDialog", 0)
        if questDialog ~= nil and BlzFrameIsVisible(questDialog) then
            ApplyFullQuestTextLayout()
        end
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

local BUTTON_SOUND_FILES={
    ["menu-open"]={file="Sound\\Interface\\GamePause.flac",label="PauseGame"},
    ["normal"]={file="Sound\\Interface\\BigButtonClick.flac",label="GlueScreenClick"},
}
local function PlayButtonSound(kind)
    if kind==false then return end
    kind=kind=='menu-open' and 'menu-open' or 'normal'
    local entry=BUTTON_SOUND_FILES[kind]
    UI.buttonSounds=UI.buttonSounds or {}
    local sound=UI.buttonSounds[kind]
    if not sound then
        sound=CreateSoundFromLabel(entry.label,false,false,false,10,10)
        UI.buttonSounds[kind]=sound
    end
    if sound then
        if UI.activeButtonSound then StopSound(UI.activeButtonSound,false,false) end
        if GetLocalPlayer()==Player(0) then StartSound(sound) end
        UI.activeButtonSound=sound
    end
end

UI.PlayButtonSound = PlayButtonSound

local FEEDBACK_LABELS={quest='QuestNew',startup='MarkOfChaos',result='ItemIllusion',failure='ReceiveLumber',
    credits='ReviveOrc',incorrect='StampedeHit',correct='PhaseShift'}
function UI.PlayFeedbackSound(kind)
    local label=FEEDBACK_LABELS[kind]
    if not label then return end
    UI.feedbackSounds=UI.feedbackSounds or {}
    local sound=UI.feedbackSounds[kind]
    if not sound then
        sound=CreateSoundFromLabel(label,false,false,false,10,10)
        UI.feedbackSounds[kind]=sound
    end
    if sound and GetLocalPlayer()==Player(0) then
        StopSound(sound,false,false)
        StartSound(sound)
    end
end

-- Opening tutorial cue, separate from the arrows used for later UI lessons.
function UI.CreateWelcomeArrow(scope, root, target, name)
    local arrow=JTG.ScopeTrackFrame(scope,BlzCreateFrameByType("BACKDROP",name,root,"",0))
    BlzFrameSetSize(arrow,0.052,0.052)
    BlzFrameSetTexture(arrow,"JTGMenu\\TutorialArrowUp.dds",0,true)
    BlzFrameSetPoint(arrow,FRAMEPOINT_TOP,target,FRAMEPOINT_BOTTOM,0,-0.004)
    BlzFrameSetEnable(arrow,false); BlzFrameSetLevel(arrow,30)
    BlzFrameSetVisible(arrow,false)
    return arrow
end

function UI.RefreshWelcomeArrow(activity)
    local state=activity.welcomeArrowState
    if activity.frames.welcomeArrow then
        BlzFrameSetVisible(activity.frames.welcomeArrow,state~=nil and state.active and state.visible and
            activity.presentationVisible and not activity.topicsOpen and not activity.optionalOpen)
    end
end

function UI.StartWelcomeArrow(activity)
    activity.welcomeArrowState={active=true,visible=true,elapsed=0,blinks=0}
    UI.RefreshWelcomeArrow(activity)
end

function UI.ClearWelcomeArrow(activity)
    activity.welcomeArrowState=nil
    UI.RefreshWelcomeArrow(activity)
end

function UI.TickWelcomeArrow(activity, interval)
    local state=activity.welcomeArrowState
    if not state or not state.active or not activity.presentationVisible then return end
    if state.blinks>=10 and state.visible then return end
    state.elapsed=state.elapsed+interval
    if state.elapsed>=0.35 then
        state.elapsed=state.elapsed-0.35
        state.visible=not state.visible
        if not state.visible then state.blinks=state.blinks+1 end
        UI.RefreshWelcomeArrow(activity)
    end
end

local function RegisterClick(frame, action, soundKind)
    UI.clickActions[GetHandleId(frame)] = action
    UI.clickSounds[GetHandleId(frame)] = soundKind or "normal"
    BlzTriggerRegisterFrameEvent(UI.clickTrigger, frame, FRAMEEVENT_CONTROL_CLICK)
end

local function RegisterRightClick(frame, action)
    UI.rightClickActions[GetHandleId(frame)] = action
end

local RESULT_ACTION_ORDER = {"replay", "retry", "next", "menu", "hide"}
local RESULT_ACTION_LABELS = {
    replay = "Replay", retry = "Redo", next = "Next", menu = "Menu",
    hide = "Hide",
}
local RESULT_TITLE_COLORS = {
    success = "|cff80ff80",
    failure = "|cffff6060",
    neutral = "|cffffcc00",
}
local resultCardCount = 0

-- Result cards own presentation only. Activities provide the title, details,
-- visible actions and exercise-specific callbacks; the shared UI owns layout,
-- click safety, focus release and presentation-scope cleanup.
function UI.CreateResultCard(session, options)
    assert(session ~= nil and session.presentationScope ~= nil,
        "Result cards require an activity presentation scope")
    options = options or {}
    resultCardCount = resultCardCount + 1
    local name = options.name or ("JTGResultCard" .. resultCardCount)
    local width = options.width or 0.38
    local detailsHeight = options.detailsHeight or 0.080
    local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    local card = {
        session = session,
        width = width,
        detailsHeight = detailsHeight,
        centerY = options.centerY or 0.325,
        actions = {},
        buttons = {},
        busy = false,
    }
    card.panel = JTG.ScopeTrackFrame(session.presentationScope,
        CreateNativePanel(name, gameUI, width, 0.30))
    BlzFrameSetAbsPoint(card.panel, FRAMEPOINT_CENTER, 0.40, card.centerY)
    card.title = JTG.ScopeTrackFrame(session.presentationScope,
        BlzCreateFrameByType("TEXT", name .. "Title", card.panel, "", 0))
    BlzFrameSetSize(card.title, width - 0.060, 0.040)
    BlzFrameSetPoint(card.title, FRAMEPOINT_TOP, card.panel,
        FRAMEPOINT_TOP, 0, -0.025)
    BlzFrameSetTextAlignment(card.title, TEXT_JUSTIFY_MIDDLE,
        TEXT_JUSTIFY_CENTER)
    BlzFrameSetScale(card.title, options.titleScale or 1.30)
    card.details = JTG.ScopeTrackFrame(session.presentationScope,
        BlzCreateFrameByType("TEXT", name .. "Details", card.panel, "", 0))
    BlzFrameSetSize(card.details, width - 0.060, detailsHeight)
    BlzFrameSetPoint(card.details, FRAMEPOINT_TOP, card.title,
        FRAMEPOINT_BOTTOM, 0, -0.008)
    BlzFrameSetTextAlignment(card.details, TEXT_JUSTIFY_TOP,
        TEXT_JUSTIFY_CENTER)
    BlzFrameSetScale(card.details, options.detailsScale or 1.0)

    local buttonWidth = math.min(0.170, (width - 0.068) * 0.5)
    card.buttonWidth = buttonWidth
    for _, action in ipairs(RESULT_ACTION_ORDER) do
        local actionName = action
        local button = JTG.ScopeTrackFrame(session.presentationScope,
            CreateButton(name .. actionName, card.panel,
                RESULT_ACTION_LABELS[actionName], buttonWidth, 0.034))
        card.buttons[actionName] = button
        RegisterClick(button, function()
            local state = card.actions[actionName]
            if card.busy or not JTG.IsCurrentSession(session) or
                    state == nil or state.visible == false or
                    state.enabled == false then return end
            card.busy = true
            BlzFrameSetVisible(card.panel, false)
            JTG.ActivateResultAction(actionName)
        end)
    end
    JTG.ScopeAdd(session.presentationScope, function()
        for _, button in pairs(card.buttons) do
            local handleId = GetHandleId(button)
            UI.clickActions[handleId] = nil
            UI.clickSounds[handleId] = nil
        end
    end)
    BlzFrameSetVisible(card.panel, false)
    return card
end

function UI.ShowResultCard(card, presentation)
    if card == nil then return end
    presentation = presentation or {}
    card.busy = false
    card.actions = presentation.actions or {}
    local titleColor = RESULT_TITLE_COLORS[presentation.tone or "neutral"] or
        RESULT_TITLE_COLORS.neutral
    BlzFrameSetText(card.title,
        titleColor .. (presentation.title or "") .. "|r")
    BlzFrameSetText(card.details, presentation.details or "")

    local visible = {}
    for _, action in ipairs(RESULT_ACTION_ORDER) do
        local state = card.actions[action]
        local button = card.buttons[action]
        local shown = state ~= nil and state.visible ~= false
        BlzFrameSetVisible(button, shown)
        if shown then
            BlzFrameSetText(button, state.label or RESULT_ACTION_LABELS[action])
            local enabled = state.enabled ~= false
            BlzFrameSetEnable(button, enabled)
            BlzFrameSetAlpha(button, enabled and 255 or 145)
            table.insert(visible, button)
        end
    end

    local rows = math.max(1, math.ceil(#visible / 2))
    local buttonTop = -(0.087 + card.detailsHeight)
    local gap = 0.008
    for index, button in ipairs(visible) do
        local row = math.floor((index - 1) / 2)
        local firstInRow = row * 2 + 1
        local itemsInRow = math.min(2, #visible - firstInRow + 1)
        local column = index - firstInRow
        local x = itemsInRow == 1 and 0 or
            (column == 0 and -(0.5 * (card.buttonWidth + gap)) or
                (0.5 * (card.buttonWidth + gap)))
        BlzFrameClearAllPoints(button)
        BlzFrameSetPoint(button, FRAMEPOINT_TOP, card.panel,
            FRAMEPOINT_TOP, x, buttonTop - row * 0.040)
    end
    local height = 0.112 + card.detailsHeight + rows * 0.040
    BlzFrameSetSize(card.panel, card.width, height)
    BlzFrameClearAllPoints(card.panel)
    BlzFrameSetAbsPoint(card.panel, FRAMEPOINT_CENTER, 0.40, card.centerY)
    BlzFrameSetVisible(card.panel, presentation.visible ~= false)
    if presentation.visible ~= false then
        local session=card.session or (JTG.Controller and JTG.Controller.session)
        local state=session or card
        local attempt=state.resultAttempt or 1
        if state.resultCueAttempt~=attempt then
            state.resultCueAttempt=attempt
            UI.PlayFeedbackSound(presentation.tone=='failure' and 'failure' or 'result')
        end
    end
end

function UI.HideResultCard(card)
    if card ~= nil and card.panel ~= nil then
        BlzFrameSetVisible(card.panel, false)
    end
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
    HideActivityPresentationForMenu()
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
    HideActivityPresentationForMenu()
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

function UI.ShowCategoryRace(categoryId, raceId)
    HideActivityPresentationForMenu()
    if categoryId == "skills" then UI.ShowCategory("skills"); return end
    UI.HideAllPanels()
    if UI.gameplayMenuPaused then UI.ShowPausedActivityToolbar()
    elseif not UI.browsingActivity then UI.HideToolbar() end
    local panel = UI.panels["category_race_" .. categoryId .. "_" .. raceId]
    if panel then
        BlzFrameSetVisible(panel, true)
        UI.menuVisible = true
        UI.currentView = {
            kind = "category_race", category = categoryId, id = raceId,
        }
        UI.currentBackAction = function() UI.ShowCategory(categoryId) end
    else UI.ShowCategory(categoryId) end
end

function UI.ShowSkillRace(raceId)
    UI.ShowCategory("skills")
end

function UI.ShowInfo(which)
    if which=="credits" and not (UI.currentView and UI.currentView.kind=="info" and UI.currentView.id=="credits") then UI.PlayFeedbackSound("credits") end
    HideActivityPresentationForMenu()
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
    BlzFrameSetText(UI.toolbarButtons.lastRunner, "Back")
    BlzFrameSetText(UI.toolbarButtons.next, "Next")
    UI.clickActions[GetHandleId(UI.toolbarButtons.menu)] = JTG.OpenTrainingMenu
    BlzFrameSetVisible(UI.toolbarButtons.restart, caps.restart == true)
    BlzFrameSetVisible(UI.toolbarButtons.menu, caps.menu ~= false)
    BlzFrameSetVisible(UI.toolbarButtons.lastRunner, caps.lastRunner == true)
    BlzFrameSetVisible(UI.toolbarButtons.pause, caps.pause == true)
    BlzFrameSetVisible(UI.toolbarButtons.rotate, caps.rotate == true)
    BlzFrameSetVisible(UI.toolbarButtons.setups, caps.setups == true)
    BlzFrameSetVisible(UI.toolbarButtons.next, caps.next == true)
    BlzFrameSetVisible(UI.toolbarButtons.squares, caps.squares == true)
    BlzFrameSetEnable(UI.toolbarButtons.next, caps.next == true)
    BlzFrameSetAlpha(UI.toolbarButtons.next, caps.next == true and 255 or 145)
    BlzFrameSetEnable(UI.toolbarButtons.squares, caps.squares == true)
    BlzFrameSetAlpha(UI.toolbarButtons.squares,
        caps.squares == true and 255 or 145)
    BlzFrameSetText(UI.toolbarButtons.squares, "Squares")
    RefreshPauseButton()
    BlzFrameSetVisible(UI.toolbar, true)
    UI.LayoutToolbar()
    UI.SetLastRunnerEnabled(caps.previous == true)
end

function UI.SetLastRunnerEnabled(enabled)
    if UI.toolbarButtons.lastRunner == nil then return end
    BlzFrameSetEnable(UI.toolbarButtons.lastRunner, enabled == true)
    BlzFrameSetAlpha(UI.toolbarButtons.lastRunner, enabled and 255 or 145)
end

local function CreateStandardMenuShell(name, titleText, bodyText,
        contentDividerY, bodyOptions)
    bodyOptions = bodyOptions or {}
    local panel = CreateNativePanel(name, GAME_UI, MENU_WIDTH, MENU_HEIGHT)
    PositionTop(panel)
    local footerDivider = AddFooterDivider(panel)
    local contentDivider = AddContentDivider(panel, contentDividerY or -0.087)
    local title = CreateText(name .. "Title", panel,
        "|cffffcc00" .. (titleText or "") .. "|r",
        TITLE_WIDTH, TITLE_HEIGHT, TITLE_SCALE)
    BlzFrameSetPoint(title, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP,
        0, TITLE_TOP_OFFSET)
    local bodyScale = bodyOptions.scale or PARAGRAPH_SCALE
    local body = CreateText(name .. "Body", panel, bodyText or "",
        (bodyOptions.width or 0.54) / bodyScale,
        (bodyOptions.height or 0.025) / bodyScale, bodyScale)
    BlzFrameSetTextAlignment(body,
        bodyOptions.verticalAlignment or TEXT_JUSTIFY_MIDDLE,
        bodyOptions.horizontalAlignment or TEXT_JUSTIFY_CENTER)
    BlzFrameSetPoint(body, FRAMEPOINT_TOP, title, FRAMEPOINT_BOTTOM,
        0, bodyOptions.topGap or 0)
    BlzFrameSetPoint(body, FRAMEPOINT_BOTTOM, contentDivider,
        FRAMEPOINT_TOP, 0, bodyOptions.bottomGap or MENU_BODY_BOTTOM_GAP)
    return {
        panel = panel,
        title = title,
        body = body,
        contentDivider = contentDivider,
        footerDivider = footerDivider,
    }
end

local function CreateFooterButton(name, panel, label, slot, action, soundKind)
    local button = CreateButton(name, panel, label,
        FOOTER_BUTTON_WIDTH, FOOTER_BUTTON_HEIGHT)
    if slot == "left" then
        BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMLEFT, panel,
            FRAMEPOINT_BOTTOMLEFT, MENU_FOOTER_SIDE_INSET,
            MENU_FOOTER_BUTTON_Y)
    elseif slot == "right" then
        BlzFrameSetPoint(button, FRAMEPOINT_BOTTOMRIGHT, panel,
            FRAMEPOINT_BOTTOMRIGHT, -MENU_FOOTER_SIDE_INSET,
            MENU_FOOTER_BUTTON_Y)
    else
        BlzFrameSetPoint(button, FRAMEPOINT_BOTTOM, panel,
            FRAMEPOINT_BOTTOM, 0, MENU_FOOTER_BUTTON_Y)
    end
    RegisterClick(button, action, soundKind)
    return button
end

local function UsesSectionedCatalogue(categoryId)
    return SECTIONED_CATEGORY_LAYOUTS[categoryId] == true
end

function UI.SetNextEnabled(enabled)
    if UI.toolbarButtons.next == nil then return end
    BlzFrameSetEnable(UI.toolbarButtons.next, enabled == true)
    BlzFrameSetAlpha(UI.toolbarButtons.next, enabled and 255 or 145)
end

function UI.SetNextText(text)
    if UI.toolbarButtons.next ~= nil then
        BlzFrameSetText(UI.toolbarButtons.next, text or "Next")
    end
end

function UI.SetSquaresActive(active)
    if UI.toolbarButtons.squares == nil then return end
    BlzFrameSetText(UI.toolbarButtons.squares,
        active == true and "Squares: On" or "Squares")
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
    local commandGrid = UI.activityBriefingCommandGrid == true
    local commandColumns = UI.activityBriefingCommandColumns or 4
    local commandRows = UI.activityBriefingCommandRows or 3
    local commandSize = UI.activityBriefingCommandSize or
        BRIEFING_COMMAND_BUTTON_SIZE
    local commandStep = UI.activityBriefingCommandStep or commandSize
    local commandTop = UI.activityBriefingCommandTop or
        BRIEFING_COMMAND_GRID_TOP
    UI.activityBriefingVisibleActions = {}
    for index, button in ipairs(UI.activityBriefingButtons or {}) do
        local choice = actions[index]
        UI.activityBriefingVisibleActions[index] = choice
        BlzFrameSetVisible(button, not commandGrid and choice ~= nil)
        local tooltip=(UI.activityBriefingChoiceTooltips or {})[index]
        if tooltip then
            local hasTooltip=not commandGrid and choice~=nil and choice.tooltip~=nil and choice.tooltip~=''
            -- Keep the native attachment stable. Detaching with a null frame
            -- and reattaching while changing a hovered button can crash WC3.
            BlzFrameSetAlpha(tooltip,hasTooltip and 255 or 0)
            BlzFrameSetVisible(tooltip,false)
            if hasTooltip then
                UI.activityBriefingChoiceTooltipUpdates[index]("|cffffcc00"..choice.label.."|r|n"..
                    (choice.tooltipColor or "|cffffffff")..choice.tooltip.."|r")
            end
        end
        if not commandGrid and choice ~= nil then
            local x, y = BriefingChoicePoint(index, #actions, compact, compactColumns,
                UI.activityBriefingCenterSingle)
            x = choice.x or x
            y = choice.y or y
            y = y + (UI.activityBriefingChoiceOffsetY or 0)
            BlzFrameClearAllPoints(button)
            BlzFrameSetPoint(button, FRAMEPOINT_TOP, UI.panels.activityBriefing,
                FRAMEPOINT_TOP, x, y)
            local defaultWidth = compact and
                (compactColumns == 4 and 0.125 or
                    BRIEFING_COMPACT_CHOICE_WIDTH) or BRIEFING_CHOICE_WIDTH
            local defaultHeight = compact and BRIEFING_COMPACT_CHOICE_HEIGHT or
                BRIEFING_CHOICE_HEIGHT
            local choiceWidth = choice.width or UI.activityBriefingChoiceWidth or
                defaultWidth
            local choiceHeight = choice.height or UI.activityBriefingChoiceHeight or
                defaultHeight
            BlzFrameSetSize(button, choiceWidth, choiceHeight)
            BlzFrameSetText(button, choice.label)
            local artwork = UI.activityBriefingChoiceArtwork[index]
            BlzFrameSetVisible(artwork, choice.icon ~= nil)
            if choice.icon ~= nil then
                local artworkSize = choice.iconSize or
                    choiceHeight * 1.2 * (choice.iconScale or 1.0)
                BlzFrameClearAllPoints(artwork)
                BlzFrameSetSize(artwork, artworkSize, artworkSize)
                BlzFrameSetPoint(artwork, FRAMEPOINT_CENTER, button,
                    FRAMEPOINT_CENTER,
                    choice.iconOffsetX or choiceWidth * 0.221 + 0.003, 0)
                BlzFrameSetTexture(artwork, choice.icon, 0, true)
            end
            local label = FindButtonText(button)
            if label ~= nil then
                BlzFrameSetScale(label, choice.scale or
                    UI.activityBriefingChoiceScale or (compact and 0.72 or 1.0))
            end
            local badge=(UI.activityBriefingCommandBadges or {})[index]
            if badge then
                local number=UI.GetSummonLevelBadge(choice)
                BlzFrameSetText(badge,number and ("|cffffcc00"..number.."|r") or "")
            end
            local enabled = choice.enabled ~= false
            BlzFrameSetEnable(button, enabled)
            BlzFrameSetAlpha(button, enabled and not choice.selected and 255 or 145)
            BlzFrameSetTextColor(button, (not enabled or choice.selected) and
                BlzConvertColor(255, 145, 145, 145) or (choice.primary and
                BlzConvertColor(255, 255, 204, 0) or
                BlzConvertColor(255, 255, 255, 255)))
        end
    end
    for index, button in ipairs(UI.activityBriefingCommandButtons or {}) do
        local choice = actions[index]
        UI.activityBriefingVisibleActions[index] = choice
        BlzFrameSetVisible(button, commandGrid and choice ~= nil)
        if commandGrid and choice ~= nil then
            local column = choice.column
            local row = choice.row
            if column == nil or row == nil then
                column = (index - 1) % 4
                row = math.floor((index - 1) / 4)
            end
            column = math.max(0, math.min(commandColumns - 1, column))
            row = math.max(0, math.min(commandRows - 1, row))
            BlzFrameClearAllPoints(button)
            BlzFrameSetSize(button, choice.size or commandSize,
                choice.size or commandSize)
            BlzFrameSetPoint(button, FRAMEPOINT_TOP, UI.panels.activityBriefing,
                FRAMEPOINT_TOP,
                choice.x or (column - (commandColumns - 1) * 0.5) * (UI.activityBriefingCommandColumnStep or commandStep),
                commandTop - row * commandStep +
                    (UI.activityBriefingChoiceOffsetY or 0))
            BlzFrameSetTexture(UI.activityBriefingCommandArtwork[index],
                choice.icon or "ReplaceableTextures\\CommandButtons\\BTNCancel.blp",
                0, true)
            local badge=(UI.activityBriefingCommandBadges or {})[index]
            if badge then
                local number=UI.GetSummonLevelBadge(choice)
                BlzFrameSetText(badge,number and ("|cffffcc00"..number.."|r") or "")
            end
            local enabled = choice.enabled ~= false
            BlzFrameSetEnable(button, enabled or choice.tooltipWhenDisabled==true)
            BlzFrameSetAlpha(button, enabled and 255 or 145)
            local tooltipText = "|cffffcc00" .. (choice.label or "") .. "|r"
            if choice.tooltip ~= nil and choice.tooltip ~= "" then
                tooltipText = tooltipText .. "|n"..(choice.tooltipColor or "|cffffffff") .. choice.tooltip .. "|r"
            end
            UI.activityBriefingCommandTooltipUpdates[index](tooltipText)
        end
    end
end

function UI.ShowActivityBriefing(spec)
    local panel = UI.panels.activityBriefing
    if panel == nil then return end
    HideActivityPresentationForMenu()
    local actions = spec.choices or {}
    local compact = spec.compactChoices == true
    local compactColumns = spec.compactColumns
    local commandGrid = spec.commandGridChoices == true
    local firstChoiceY
    if commandGrid then
        firstChoiceY = spec.commandGridTop or BRIEFING_COMMAND_GRID_TOP
    else
        local unusedX
        unusedX, firstChoiceY = BriefingChoicePoint(1, math.max(1, #actions),
            compact, compactColumns, spec.centerSingleChoice == true)
    end
    firstChoiceY = firstChoiceY + (spec.choiceOffsetY or 0)
    UI.SetGameplayMenuPaused(spec.pauseGame == true)
    SetActivityOverlayVisible(false)
    UI.HideAllPanels()
    UI.HideToolbar()
    BlzFrameSetText(UI.activityBriefingTitle, "|cffffcc00" .. (spec.title or "") .. "|r")
    BlzFrameSetText(UI.activityBriefingTitleSuffix,"|cffffcc00"..(spec.titleSuffix or "").."|r")
    BlzFrameSetVisible(UI.activityBriefingTitleSuffix,spec.titleSuffix~=nil)
    BlzFrameSetText(UI.activityBriefingBody, spec.body or "")
    BlzFrameClearAllPoints(UI.activityBriefingContentDivider)
    BlzFrameSetPoint(UI.activityBriefingContentDivider, FRAMEPOINT_TOP, panel,
        FRAMEPOINT_TOP, 0, spec.contentDividerY or (firstChoiceY + BRIEFING_DIVIDER_BUTTON_GAP))
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
        BlzFrameSetPoint(UI.activityBriefingArtwork, FRAMEPOINT_TOP,
            panel, FRAMEPOINT_TOP,
            spec.headingArtworkCenterX or BRIEFING_IMAGE_CENTER_X,
            spec.headingArtworkTopOffset or BRIEFING_IMAGE_TOP_OFFSET)
        BlzFrameSetTexture(UI.activityBriefingArtwork, spec.headingArtwork, 0, true)
    end
    UI.activityBriefingActions = actions
    UI.activityBriefingCompact = compact
    UI.activityBriefingCompactColumns = compactColumns
    UI.activityBriefingCommandGrid = commandGrid
    UI.activityBriefingCommandColumns = spec.commandGridColumns
    UI.activityBriefingCommandRows = spec.commandGridRows
    UI.activityBriefingCommandSize = spec.commandGridButtonSize
    UI.activityBriefingCommandStep = spec.commandGridStep
    UI.activityBriefingCommandColumnStep = spec.commandGridColumnStep
    UI.activityBriefingCommandTop = spec.commandGridTop
    for index, frame in ipairs(UI.activityBriefingCommandHeadings or {}) do
        local heading = (spec.commandGridHeadings or {})[index]
        BlzFrameSetVisible(frame, heading ~= nil)
        if heading then
            BlzFrameSetTextAlignment(frame,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
            BlzFrameSetSize(frame, heading.width or 0.16, 0.018)
            BlzFrameSetScale(frame, heading.scale or 1)
            BlzFrameSetText(frame, "|cffffcc00" .. heading.label .. "|r")
            BlzFrameClearAllPoints(frame)
            BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, panel, FRAMEPOINT_TOPLEFT,
                MENU_WIDTH * 0.5 + heading.x, heading.y)
        end
    end
    UI.activityBriefingCenterSingle = spec.centerSingleChoice == true
    UI.activityBriefingChoiceOffsetY = spec.choiceOffsetY or 0
    UI.activityBriefingChoiceWidth = spec.choiceWidth
    UI.activityBriefingChoiceHeight = spec.choiceHeight
    UI.activityBriefingChoiceScale = spec.choiceScale
    RefreshActivityBriefingChoices()
    UI.activityBriefingBackAction = spec.backAction
    BlzFrameSetTextColor(UI.activityBriefingBack, BlzConvertColor(255, 255, 255, 255))
    UI.activityBriefingResumeAction = spec.resumeAction
    -- Shared Exit rebuilds this exact page without a running exercise. Old
    -- selector closures must not resurrect Resume or leave cleaned-up actors.
    UI.activityBriefingExitAction = spec.resumeAction and JTG.ExitActivityFromMenu or
        spec.exitAction or JTG.ExitActivityFromMenu
    UI.activityBriefingPrimaryAction = spec.primaryAction
    local showPrimary = spec.resumeAction == nil and
        (spec.primaryAction ~= nil or spec.primaryLabel ~= nil)
    BlzFrameSetVisible(UI.activityBriefingPrimary, showPrimary)
    if showPrimary then
        BlzFrameSetText(UI.activityBriefingPrimary,
            spec.primaryLabel or "Begin")
        local enabled = spec.primaryEnabled ~= false
        BlzFrameSetEnable(UI.activityBriefingPrimary, enabled)
        BlzFrameSetAlpha(UI.activityBriefingPrimary, enabled and 255 or 145)
        BlzFrameSetTextColor(UI.activityBriefingPrimary, enabled and
            BlzConvertColor(255, 255, 204, 0) or
            BlzConvertColor(255, 145, 145, 145))
        BlzFrameClearAllPoints(UI.activityBriefingBack)
        BlzFrameSetPoint(UI.activityBriefingBack, FRAMEPOINT_BOTTOMLEFT,
            panel, FRAMEPOINT_BOTTOMLEFT, MENU_FOOTER_SIDE_INSET,
            MENU_FOOTER_BUTTON_Y)
        BlzFrameClearAllPoints(UI.activityBriefingPrimary)
        BlzFrameSetPoint(UI.activityBriefingPrimary,
            FRAMEPOINT_BOTTOMRIGHT, panel, FRAMEPOINT_BOTTOMRIGHT,
            -MENU_FOOTER_SIDE_INSET, MENU_FOOTER_BUTTON_Y)
    else
        BlzFrameClearAllPoints(UI.activityBriefingBack)
        BlzFrameSetPoint(UI.activityBriefingBack, FRAMEPOINT_BOTTOM, panel,
            FRAMEPOINT_BOTTOM, 0, MENU_FOOTER_BUTTON_Y)
    end
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
        RegisterClick(button, function() UI.ShowCategory(category.id) end, "menu-open")
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

local function HasAvailableRaceActivity(categoryId, raceId)
    for _, descriptor in ipairs(JTG.GetActivities(categoryId, raceId)) do
        if descriptor.status == "available" then return true end
    end
    return false
end

local function CreateCategoryPanel(category, categoryIndex)
    local learnBody = category.id == "learn" and JTG.Tutorial.FormatNarration(
        "In the tutorials you can navigate through them by using the {Button: Topics} and {Button: Optional} buttons.")
    local shell = CreateStandardMenuShell("JTGCategoryPanel" .. categoryIndex,
        category.title, learnBody or category.description or category.summary,
        category.id == "learn" and -0.112 or -0.087)
    local panel = shell.panel
    local sectioned = UsesSectionedCatalogue(category.id)
    UI.panels["category_" .. category.id] = panel
    BlzFrameSetVisible(panel, false)

    local activities = JTG.GetActivities(category.id)
    local learn = category.id == "learn"
    local tools = category.id == "tools"
    local centeredColumns = learn or tools
    local maxRows = tools and math.max(1, math.ceil(#activities / 2)) or (learn and 4 or 5)
    local generalLeft = nil
    local generalRight = nil
    for index, descriptor in ipairs(activities) do
        local column = math.floor((index - 1) / maxRows)
        local row = (index - 1) % maxRows
        if sectioned then
            column = (index - 1) % 2
            row = math.floor((index - 1) / 2)
        end
        if category.id == "skills" then
            column = descriptor.catalogueColumn or column
            row = descriptor.catalogueRow or row
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
            centeredColumns and (-0.120 + column * 0.240) or (-0.192 + column * 0.192),
            (sectioned and -0.1522 or (learn and -0.125 or -0.100)) -
                row * (sectioned and 0.0562 or (learn and 0.062 or 0.055)))
        if sectioned and row == 0 then
            if column == 0 then generalLeft = frame
            else generalRight = frame end
        end
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
    if sectioned then
        local generalHeading = CreateText("JTGSectionedGeneralHeading" ..
            categoryIndex, panel,
            "|cffffcc00General|r", 0.382, CATALOGUE_BUTTON_HEIGHT, 1.0)
        BlzFrameSetTextAlignment(generalHeading, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetFont(generalHeading, "Fonts\\FRIZQT__.TTF", 0.024, 0)
        BlzFrameSetPoint(generalHeading, FRAMEPOINT_CENTER, panel, FRAMEPOINT_TOP,
            -0.096, -0.122)
        local generalDivider = BlzCreateFrameByType("BACKDROP",
            "JTGSectionedGeneralDivider" .. categoryIndex, panel, "", 0)
        BlzFrameSetTexture(generalDivider, "JTGMenu\\MenuDivider.dds", 0, true)
        BlzFrameSetSize(generalDivider, 0.001, 0.0012)
        BlzFrameSetPoint(generalDivider, FRAMEPOINT_BOTTOMLEFT,
            generalLeft, FRAMEPOINT_TOPLEFT, 0.004, 0.0042)
        BlzFrameSetPoint(generalDivider, FRAMEPOINT_BOTTOMRIGHT,
            generalRight, FRAMEPOINT_TOPRIGHT, -0.004, 0.0042)
        BlzFrameSetLevel(generalDivider, 8)
        BlzFrameSetEnable(generalDivider, false)

        local raceHeading = CreateText("JTGSectionedRaceHeading" .. categoryIndex,
            panel,
            "|cffffcc00Race Specific|r", 0.176, CATALOGUE_BUTTON_HEIGHT, 1.0)
        BlzFrameSetTextAlignment(raceHeading, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetFont(raceHeading, "Fonts\\FRIZQT__.TTF", 0.024, 0)
        BlzFrameSetPoint(raceHeading, FRAMEPOINT_CENTER, panel, FRAMEPOINT_TOP,
            0.192, -0.122)
        local firstRaceFrame = nil
        for raceIndex, race in ipairs(JTG.Races) do
            local hasAvailableActivity = HasAvailableRaceActivity(category.id, race.id)
            local descriptor = {
                title = race.title,
                artwork = race.artwork,
                status = hasAvailableActivity and "available" or "planned",
            }
            local frame, button, art = CreateIllustratedCard(
                "JTGSectionedRaceButton" .. categoryIndex .. "x" .. raceIndex,
                panel, descriptor,
                CATALOGUE_BUTTON_WIDTH, CATALOGUE_BUTTON_HEIGHT,
                0.0624, 0.0624, 0.110, 0.84, 0.020)
            BlzFrameClearAllPoints(art)
            BlzFrameSetPoint(art, FRAMEPOINT_CENTER, button,
                FRAMEPOINT_CENTER, 0.042, 0)
            BlzFrameSetPoint(frame, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP,
                0.192, -0.1522 - (raceIndex - 1) * 0.0562)
            if firstRaceFrame == nil then firstRaceFrame = frame end
            if hasAvailableActivity then
                RegisterClick(button, function()
                    UI.ShowCategoryRace(category.id, race.id)
                end)
            else
                BlzFrameSetEnable(button, false)
                BlzFrameSetAlpha(button, 145)
                BlzFrameSetTextColor(button,
                    BlzConvertColor(255, 145, 145, 145))
            end
        end
        local raceDivider = BlzCreateFrameByType("BACKDROP",
            "JTGSectionedRaceDivider" .. categoryIndex, panel, "", 0)
        BlzFrameSetTexture(raceDivider, "JTGMenu\\MenuDivider.dds", 0, true)
        BlzFrameSetSize(raceDivider, 0.001, 0.0012)
        BlzFrameSetPoint(raceDivider, FRAMEPOINT_BOTTOMLEFT,
            firstRaceFrame, FRAMEPOINT_TOPLEFT, 0.004, 0.0042)
        BlzFrameSetPoint(raceDivider, FRAMEPOINT_BOTTOMRIGHT,
            firstRaceFrame, FRAMEPOINT_TOPRIGHT, -0.004, 0.0042)
        BlzFrameSetLevel(raceDivider, 8)
        BlzFrameSetEnable(raceDivider, false)
    end
    CreateFooterButton("JTGCategoryBack" .. categoryIndex, panel, "Back",
        "center", UI.ShowRoot, "return")
end


local function CreateCategoryRacePanel(category, categoryIndex, race, raceIndex)
    local shell = CreateStandardMenuShell(
        "JTGCategoryRacePanel" .. categoryIndex .. "x" .. raceIndex,
        category.title .. " - Race Specific", race.title .. " topics.", -0.087)
    local panel = shell.panel
    UI.panels["category_race_" .. category.id .. "_" .. race.id] = panel
    BlzFrameSetVisible(panel, false)

    local activities = JTG.GetActivities(category.id, race.id)
    for index, descriptor in ipairs(activities) do
        local displayDescriptor = descriptor
        if descriptor.artworkByRace ~= nil and
                descriptor.artworkByRace[race.id] ~= nil then
            displayDescriptor = {}
            for key, value in pairs(descriptor) do displayDescriptor[key] = value end
            displayDescriptor.artwork = descriptor.artworkByRace[race.id]
        end
        local column = (index - 1) % 3
        local row = math.floor((index - 1) / 3)
        local name = "JTGCategoryRaceActivity" .. categoryIndex .. "x" ..
            raceIndex .. "x" .. index
        local frame
        local button
        if displayDescriptor.artwork ~= nil then
            frame, button = CreateIllustratedActivityCard(name, panel,
                displayDescriptor)
        else
            button = CreateButton(name, panel,
                descriptor.title .. "  |cff808080[Planned]|r",
                CATALOGUE_BUTTON_WIDTH, CATALOGUE_BUTTON_HEIGHT)
            frame = button
        end
        BlzFrameSetPoint(frame, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP,
            -0.192 + column * 0.192, -0.100 - row * 0.055)
        if descriptor.status ~= "available" then
            BlzFrameSetEnable(button, false)
            BlzFrameSetAlpha(button, 145)
            BlzFrameSetTextColor(button, BlzConvertColor(255, 145, 145, 145))
        else
            AttachTooltip(button, descriptor.description, column >= 2 and "left" or "right")
            RegisterClick(button, function()
                local raceData = {race = race.id}
                if descriptor.menu ~= nil then
                    JTG.OpenActivityMenu(descriptor.id, category.id, nil, raceData)
                else JTG.StartActivity(descriptor.id, category.id, raceData) end
            end)
        end
        UI.catalogueRows[descriptor.id .. "_" .. category.id .. "_" .. race.id] =
            button
    end
    CreateFooterButton("JTGCategoryRaceBack" .. categoryIndex .. "x" ..
        raceIndex, panel, "Back", "center",
        function() UI.ShowCategory(category.id) end, "return")
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
    local shell = CreateStandardMenuShell("JTGActivityBriefing", "", "", -0.265, {
        width = 0.53,
        height = 0.205,
        verticalAlignment = TEXT_JUSTIFY_TOP,
        horizontalAlignment = TEXT_JUSTIFY_LEFT,
        topGap = -0.022,
    })
    local panel = shell.panel
    UI.activityBriefingContentDivider = shell.contentDivider
    UI.panels.activityBriefing = panel
    BlzFrameSetVisible(panel, false)

    UI.activityBriefingTitle = shell.title
    UI.activityBriefingTitleSuffix=CreateText("JTGBriefingTitleSuffix",panel,"",0.16,0.025,TITLE_SCALE)
    BlzFrameSetPoint(UI.activityBriefingTitleSuffix,FRAMEPOINT_LEFT,shell.title,FRAMEPOINT_CENTER,0.06,0)
    BlzFrameSetTextAlignment(UI.activityBriefingTitleSuffix,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_LEFT)
    BlzFrameSetEnable(UI.activityBriefingTitleSuffix,false)
    BlzFrameSetVisible(UI.activityBriefingTitleSuffix,false)
    UI.activityBriefingArtwork = BlzCreateFrameByType("BACKDROP", "JTGActivityBriefingArtwork", panel, "", 0)
    BlzFrameSetSize(UI.activityBriefingArtwork, 0.200, 0.098)
    BlzFrameSetPoint(UI.activityBriefingArtwork, FRAMEPOINT_TOP, panel,
        FRAMEPOINT_TOP, BRIEFING_IMAGE_CENTER_X, BRIEFING_IMAGE_TOP_OFFSET)
    BlzFrameSetEnable(UI.activityBriefingArtwork, false)
    BlzFrameSetVisible(UI.activityBriefingArtwork, false)
    UI.activityBriefingBody = shell.body
    BlzFrameSetEnable(UI.activityBriefingBody, false)

    UI.activityBriefingButtons = {}
    UI.activityBriefingCommandHeadings = {}
    for index = 1, 6 do
        local frame = BlzCreateFrameByType("TEXT", "JTGBriefingGroup" .. index, panel, "", 0)
        BlzFrameSetSize(frame, 0.16, 0.018)
        BlzFrameSetEnable(frame, false)
        BlzFrameSetVisible(frame, false)
        UI.activityBriefingCommandHeadings[index] = frame
    end
    UI.activityBriefingChoiceArtwork = {}
    UI.activityBriefingTooltipText = {}
    UI.activityBriefingChoiceTooltips = {}
    UI.activityBriefingChoiceTooltipUpdates = {}
    for index = 1, 15 do
        local button = CreateButton("JTGActivityBriefingChoice" .. index, panel,
            "", BRIEFING_CHOICE_WIDTH, BRIEFING_CHOICE_HEIGHT)
        BlzFrameSetPoint(button, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, -0.305)
        local artwork = BlzCreateFrameByType("BACKDROP",
            "JTGActivityBriefingChoiceArtwork" .. index, button, "", 0)
        BlzFrameSetEnable(artwork, false)
        BlzFrameSetVisible(artwork, false)
        UI.activityBriefingButtons[index] = button
        UI.activityBriefingChoiceArtwork[index] = artwork
        local tooltip,tooltipText,updateTooltip=AttachTooltip(button,"","right")
        UI.activityBriefingChoiceTooltips[index]=tooltip
        UI.activityBriefingTooltipText[index]=tooltipText
        UI.activityBriefingChoiceTooltipUpdates[index]=updateTooltip
        BlzFrameSetAlpha(tooltip,0)
        RegisterClick(button, function()
            local choice = UI.activityBriefingVisibleActions and UI.activityBriefingVisibleActions[index]
            if choice ~= nil and choice.enabled~=false and choice.action ~= nil then choice.action() end
        end, function()
            local choice = UI.activityBriefingVisibleActions and UI.activityBriefingVisibleActions[index]
            return choice ~= nil and choice.enabled ~= false and "normal" or false
        end)
    end

    UI.activityBriefingCommandButtons = {}
    UI.activityBriefingCommandArtwork = {}
    UI.activityBriefingCommandTooltipText = {}
    UI.activityBriefingCommandTooltipUpdates = {}
    UI.activityBriefingCommandBadges = {}
    for index = 1, 72 do
        local button = BlzCreateFrameByType("BUTTON",
            "JTGActivityBriefingCommandChoice" .. index, panel, "", 0)
        BlzFrameSetSize(button, BRIEFING_COMMAND_BUTTON_SIZE,
            BRIEFING_COMMAND_BUTTON_SIZE)
        BlzFrameSetPoint(button, FRAMEPOINT_TOP, panel, FRAMEPOINT_TOP, 0, -0.305)
        local artwork = BlzCreateFrameByType("BACKDROP",
            "JTGActivityBriefingCommandArtwork" .. index, button, "", 0)
        BlzFrameSetAllPoints(artwork, button)
        BlzFrameSetEnable(artwork, false)
        local _, tooltipText, updateTooltip = AttachTooltip(button,
            "Unit name|nCast Point: 0.000s|nMissile speed: 0000 units/s|n|n- Matchup restriction explanation.",
            "right")
        UI.activityBriefingCommandButtons[index] = button
        local badge=BlzCreateFrameByType("TEXT","JTGCommandBadge"..index,button,"",0)
        BlzFrameSetSize(badge,0.012,0.012)
        BlzFrameSetPoint(badge,FRAMEPOINT_BOTTOMRIGHT,button,FRAMEPOINT_BOTTOMRIGHT,-0.001,0.001)
        BlzFrameSetTextAlignment(badge,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_RIGHT)
        BlzFrameSetEnable(badge,false)
        UI.activityBriefingCommandBadges[index]=badge
        UI.activityBriefingCommandArtwork[index] = artwork
        UI.activityBriefingCommandTooltipText[index] = tooltipText
        UI.activityBriefingCommandTooltipUpdates[index] = updateTooltip
        RegisterClick(button, function()
            local choice = UI.activityBriefingVisibleActions and
                UI.activityBriefingVisibleActions[index]
            if choice ~= nil and choice.enabled~=false and choice.action ~= nil then choice.action() end
        end, function()
            local choice = UI.activityBriefingVisibleActions and UI.activityBriefingVisibleActions[index]
            return choice ~= nil and choice.enabled ~= false and "normal" or false
        end)
        RegisterRightClick(button, function()
            local choice = UI.activityBriefingVisibleActions and
                UI.activityBriefingVisibleActions[index]
            if choice ~= nil and choice.enabled~=false and choice.rightAction ~= nil then
                choice.rightAction()
            end
        end)
        BlzFrameSetVisible(button, false)
    end

    local back = CreateFooterButton("JTGActivityBriefingBack", panel, "Back",
        "center", function()
        if UI.activityBriefingBackAction ~= nil then UI.activityBriefingBackAction() end
    end, "return")
    UI.activityBriefingBack = back

    local primary = CreateFooterButton("JTGActivityBriefingPrimary", panel,
        "Begin", "right", function()
        if UI.activityBriefingPrimaryAction ~= nil then
            UI.activityBriefingPrimaryAction()
        end
    end)
    UI.activityBriefingPrimary = primary
    BlzFrameSetVisible(primary, false)

    local exit = CreateFooterButton("JTGActivityBriefingExit", panel, "Exit",
        "left", function()
        if UI.activityBriefingExitAction ~= nil then UI.activityBriefingExitAction() end
    end)
    BlzFrameSetTextColor(exit, BlzConvertColor(255, 255, 255, 255))
    UI.activityBriefingExit = exit
    BlzFrameSetVisible(exit, false)

    local resume = CreateFooterButton("JTGActivityBriefingResume", panel, "Resume",
        "right", function()
        if UI.activityBriefingResumeAction ~= nil then UI.activityBriefingResumeAction() end
    end)
    BlzFrameSetTextColor(resume, BlzConvertColor(255, 255, 255, 255))
    UI.activityBriefingResume = resume
    BlzFrameSetVisible(resume, false)
end

local function CreateToolbar()
    local bar = BlzCreateFrameByType("FRAME", "JTGActivityToolbar", GAME_UI, "", 0)
    -- Every exercise uses the same fixed two-by-four control grid.
    BlzFrameSetSize(bar, 0.351, 0.060)
    BlzFrameSetAbsPoint(bar, FRAMEPOINT_TOPLEFT,
        TOOLBAR_LEFT, TOOLBAR_TOP)
    UI.toolbar = bar

    local function toolbarButton(name, label)
        local button = CreateButton(name, bar, label,
            TOOLBAR_BUTTON_WIDTH, TOOLBAR_BUTTON_HEIGHT)
        local text = FindButtonText(button)
        if text ~= nil then BlzFrameSetScale(text, 0.72) end
        return button
    end

    local restart = toolbarButton("JTGToolbarRestart", "Redo")
    AttachTooltip(restart, "Cleanly reset the current activity and begin it again.", "left")
    RegisterClick(restart, JTG.ResetActivity, "toolbar")
    UI.toolbarButtons.restart = restart
    UI.PlaceToolbarButton(restart, 6, bar)
    local menu = toolbarButton("JTGToolbarMenu", "Menu")
    AttachTooltip(menu, "Change this exercise's configuration or return to the training menus.", "left")
    RegisterClick(menu, JTG.OpenTrainingMenu, "menu-open")
    UI.toolbarButtons.menu = menu
    UI.PlaceToolbarButton(menu, 1, bar)

    local lastRunner = toolbarButton("JTGToolbarLastRunner", "Back")
    AttachTooltip(lastRunner, "Restart the exercise against the previous runner.", "left")
    BlzFrameSetEnable(lastRunner, false)
    BlzFrameSetAlpha(lastRunner, 145)
    RegisterClick(lastRunner, JTG.LastRunnerActivity, "SpiritTouch")
    UI.toolbarButtons.lastRunner = lastRunner
    UI.PlaceToolbarButton(lastRunner, 2, bar)

    local rotate = toolbarButton("JTGToolbarRotate", "Rotate")
    AttachTooltip(rotate,
        "Restart with the mine, main building and lumber position rotated.",
        "left")
    RegisterClick(rotate, JTG.RotateActivity, "toolbar")
    UI.toolbarButtons.rotate = rotate
    UI.PlaceToolbarButton(rotate, 8, bar)

    local setups = toolbarButton("JTGToolbarSetups", "Setups")
    AttachTooltip(setups,
        "Choose another unit setup for this exercise.", "left")
    RegisterClick(setups, JTG.ToggleActivitySetups, "menu-open")
    UI.toolbarButtons.setups = setups
    UI.PlaceToolbarButton(setups, 3, bar)

    local nextStage = toolbarButton("JTGToolbarNext", "Next")
    AttachTooltip(nextStage,
        "Continue to the next runner or unit setup.", "left")
    RegisterClick(nextStage, JTG.NextActivityStage, "toolbar")
    UI.toolbarButtons.next = nextStage
    UI.PlaceToolbarButton(nextStage, 5, bar)

    local squares = toolbarButton("JTGToolbarSquares", "Squares")
    AttachTooltip(squares,
        "Display unit obstruction areas, snap points and the finer grid.",
        "left")
    RegisterClick(squares, JTG.ToggleActivitySquares, "Lever")
    UI.toolbarButtons.squares = squares
    UI.PlaceToolbarButton(squares, 8, bar)

    -- Match the aspect ratio of Warcraft's native Quest-button notification
    -- effect, which is authored for the wider upper-button-bar controls.
    local pause = toolbarButton("JTGToolbarPause", "Pause")
    RegisterClick(pause, UI.ToggleExercisePause, function()
        return "toolbar"
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
    UI.PlaceToolbarButton(pause, 7, bar)
    UI.LayoutToolbar = function() end
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
    RegisterClick(resume, JTG.ResumeActivity)
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
        UI.clickTrigger, UI.rightClickTrigger, UI.hoverTrigger, UI.escapeTrigger,
        UI.nativeSystemKeyUpTrigger,
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
    UI.rightClickActions = {}
    UI.hoveredRightClickFrame = nil
    UI.tooltips = {}
    UI.nativeHiddenFrames = {}
    UI.activityBriefingActions = nil
    UI.activityBriefingVisibleActions = nil
    UI.activityBriefingButtons = nil
    UI.activityBriefingChoiceArtwork = nil
    UI.activityBriefingTooltipText = nil
    UI.activityBriefingChoiceTooltips = nil
    UI.activityBriefingChoiceTooltipUpdates = nil
    UI.activityBriefingCommandButtons = nil
    UI.activityBriefingCommandBadges = nil
    UI.activityBriefingCommandArtwork = nil
    UI.activityBriefingCommandTooltipText = nil
    UI.activityBriefingCommandTooltipUpdates = nil
    UI.activityBriefingCommandGrid = nil
    UI.currentBackAction = nil
    UI.clickTrigger = nil
    UI.rightClickTrigger = nil
    UI.hoverTrigger = nil
    UI.escapeTrigger = nil
    UI.nativeSystemKeyUpTrigger = nil
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
    UI.nativeKeyClosed = false
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
    UI.activityBriefingTitleSuffix = nil
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
        elseif target.kind == "category_race" then
            UI.ShowCategoryRace(target.category or "skills", target.id)
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
    elseif target.kind == "category_race" then
        UI.ShowCategoryRace(target.category or "skills", target.id)
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

    UI.clickTrigger = CreateTrigger()
    TriggerAddAction(UI.clickTrigger, function()
        local clickedFrame = BlzGetTriggerFrame()
        local action = UI.clickActions[GetHandleId(clickedFrame)]
        if action ~= nil then
            local soundKind = UI.clickSounds[GetHandleId(clickedFrame)]
            local previousView=UI.currentView
            local function dispatch()
                action()
                local kind=type(soundKind)=='function' and soundKind() or soundKind
                if kind=='normal' and UI.menuVisible and UI.currentView~=previousView then kind='menu-open' end
                PlayButtonSound(kind)
                ReleaseFrameFocus(clickedFrame)
                ReleaseKeyboardFocusAfterClick()
            end
            ReleaseFrameFocus(clickedFrame)
            if UI.gameplayMenuPaused or UI.exercisePaused then
                dispatch()
                return
            end
            local epoch = UI.epoch
            local releaseTimer = CreateTimer()
            TimerStart(releaseTimer, 0.00, false, function()
                DestroyTimer(releaseTimer)
                if UI.epoch ~= epoch then return end
                dispatch()
            end)
        end
    end)
    UI.hoverTrigger = CreateTrigger()
    TriggerAddAction(UI.hoverTrigger, function()
        local frame = BlzGetTriggerFrame()
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
            UI.hoveredRightClickFrame = frame
        elseif UI.hoveredRightClickFrame == frame then
            UI.hoveredRightClickFrame = nil
        end
    end)
    UI.rightClickTrigger = CreateTrigger()
    TriggerRegisterPlayerEvent(UI.rightClickTrigger, Player(0),
        EVENT_PLAYER_MOUSE_DOWN)
    TriggerAddAction(UI.rightClickTrigger, function()
        if BlzGetTriggerPlayerMouseButton() ~= MOUSE_BUTTON_TYPE_RIGHT then
            return
        end
        local clickedFrame = UI.hoveredRightClickFrame
        if clickedFrame == nil then return end
        local action = UI.rightClickActions[GetHandleId(clickedFrame)]
        if action == nil then return end
        local soundKind = UI.clickSounds[GetHandleId(clickedFrame)]
        if type(soundKind) == "function" then soundKind = soundKind() end
        if soundKind ~= false then PlayButtonSound("return") end
        ReleaseFrameFocus(clickedFrame)
        action()
        ReleaseFrameFocus(clickedFrame)
        ReleaseKeyboardFocusAfterClick()
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
            UI.nativeKeyClosed=BlzGetTriggerPlayerKey()==OSKEY_F10
            RestoreAfterNativeMenu()
            return
        end
        UI.nativeKeyClosed=false
        SuspendForNativeMenu()
    end)
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
    -- Never register frame events on Warcraft's upper-bar buttons. Those
    -- registrations can replace the native button behavior, including sound
    -- and dialog activation. Observe native dialogs and hotkeys instead.
    UI.nativeSystemKeyUpTrigger = CreateTrigger()
    BlzTriggerRegisterPlayerKeyEvent(UI.nativeSystemKeyUpTrigger, Player(0),
        OSKEY_F10, 0, false)
    TriggerAddAction(UI.nativeSystemKeyUpTrigger, function()
        if UI.nativeKeyClosed then UI.nativeKeyClosed=false;return end
        -- F10 key release covers clients that consume its key-down event.
        if not UI.nativeMenuOpen and (NativeMenuIsVisible() or UI.menuVisible) then
            SuspendForNativeMenu()
        end
    end)
    CreateRootPanel()
    for index, category in ipairs(JTG.Categories) do CreateCategoryPanel(category, index) end
    for categoryIndex, category in ipairs(JTG.Categories) do
        if UsesSectionedCatalogue(category.id) then
            for raceIndex, race in ipairs(JTG.Races) do
                CreateCategoryRacePanel(category, categoryIndex, race, raceIndex)
            end
        end
    end
    CreateInfoPanel("patch", "Patch Notes",
        "|cffffcc00v0.2.0|r  |cffb0b0b0Upcoming|r\n" ..
        "- Added the Heroes tutorial, covering attributes, abilities, experience and items.\n" ..
        "- Added Hotkey Trainer, using your current hotkeys and helping you practise missed commands.\n" ..
        "- Added Reflex Training with unit identification and buff/debuff recognition. Still WIP—feedback welcome!\n" ..
        "- Expanded Mining Micro with One Minute and Build Order modes, including an income comparison against a base without mining micro.\n" ..
        "- Improved tutorial navigation, exercise cleanup, menus and feedback throughout the map.\n\n" ..
        "|cffffcc00v0.1.2|r  |cffb0b0b010 October 2026|r\n" ..
        "- Added Economy & Workers with gathering, construction and base-defense practice.\n" ..
        "- Added Bat Splitting with three unit-count stages and daytime/nighttime modes.\n" ..
        "- Added Dodging with projectile disjoining and Area/Devour avoidance training.\n\n" ..
        "|cffffcc00v0.1.1|r  |cffb0b0b06 October 2026|r\n" ..
        "- Added Gargoyle Surrounds with ten setups.\n" ..
        "- Updated Undead Surrounds and unlocked non-hero abilities.\n" ..
        "- Revised tutorial texts and race-selection layouts.\n" ..
        "- Added Gargoyle Surrounds and Combat Micro artwork.\n" ..
        "- Improved Surrounds completion detection.\n" ..
        "- Added enemy health restoration in Windwalk Pop.\n\n" ..
        "|cffffcc00v0.1.0|r  |cffb0b0b05 October 2026|r\n" ..
        "- Added custom Surrounds training and expanded Windwalk Pop.\n" ..
        "- Added unit-obstruction and navigation-grid visualization.\n" ..
        "- Standardized exercise controls, result cards and briefing menus.\n" ..
        "- Added separate development tools and shared activity cleanup.\n" ..
        "- Standardized Mining Micro and expanded Power Building.\n\n" ..
        "|cffffcc00v0.0.11|r  |cffb0b0b04 October 2026|r\n" ..
        "- Added Surrounds Skill Training\n" ..
        "- Improved map script structure\n\n" ..
        "|cffffcc00v0.0.10|r  |cffb0b0b02 October 2026|r\n" ..
        "- Added the Hotkey Setup tutorial and CustomKeys exports.\n\n" ..
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
        "Contributors: AoW, poison, floss2xdaily, Kaccel, MadPad09, Solstice1221, Barren and Thae.\n\n" ..
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
