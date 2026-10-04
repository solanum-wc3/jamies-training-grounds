-- Windwalk Pop: use Wind Walk's native loss and restoration of collision to
-- displace a surrounded Orc unit. The normal setup teaches the isolated
-- mechanic; Hard Mode and Counterplay stage a small two-army encounter.
JTG = JTG or {}

local WINDWALK_POP_INTRO =
    "Orcs have a unique way to free a unit from being surrounded.\n" ..
    "During Blademaster's {Term: Windwalk}, he has no unit collision.\n" ..
    "This allows him \"pop out\" a surrounded unit, after getting " ..
    "collision again.\n" ..
    "In these trainings, you can practice freeing units from surrounds " ..
    "like this,\nor you can learn the counterplay against a Windwalk Pop.\n\n" ..
    "Check the {Button: Quest Log} for precise instructions!\n" ..
    "You can reset the training using the {Button: Redo} button."

local WINDWALK_POP_QUEST_TEXT =
    "The Blademaster loses unit collision immediately upon using his Wind " ..
    "Walk ability.\n\n" ..
    "He regains it immediately after ending the effect.\n\n" ..
    "This does not immediately push him and other units apart. That only " ..
    "happens once one of them moves.\n\n\n" ..
    "Keeping that in mind, here is the order of operations on how to " ..
    "perform a Windwalk Pop.\n\n" ..
    "1. Use {Term: Wind Walk}.\n" ..
    "2. Run through the surrounded unit by using a {Term: Move} command " ..
    "behind it.\n" ..
    "3. When the Blademaster is exactly on it, use a {Term: Stop} or " ..
    "{Term: Hold Position} command.\n" ..
    "4. Attack one of the surrounding units.\n" ..
    "5. Select the surrounded unit you want to save, and have it move " ..
    "somewhere.\n\n" ..
    "If executed correctly, the surrounded unit will pop out of the " ..
    "surround.\n\n" ..
    "Of course, now the Blademaster is surrounded, so you should not do " ..
    "this when he does not have enough mana for two Wind Walks."

local COUNTERPLAY_QUEST_TEXT =
    "Knowing you are facing a Blademaster, you can try to counterplay the " ..
    "Windwalk pop.\n\n" ..
    "To do this, you need to see it coming.\n\n" ..
    "If you now loosen the surround a bit, so the surrounded unit is still " ..
    "trapped, but so there is enough space for it and the Blademaster, the " ..
    "Windwalk Pop will instead also trap the Blademaster in the surround."

local BLADEMASTER_ID = FourCC("Obla")
local GRUNT_ID = FourCC("ogru")
local TAUREN_CHIEFTAIN_ID = FourCC("Otch")
local ARCHMAGE_ID = FourCC("Hamg")
local MOUNTAIN_KING_ID = FourCC("Hmkg")
local FOOTMAN_ID = FourCC("hfoo")
local HEADHUNTER_ID = FourCC("ohun")
local RAIDER_ID = FourCC("orai")
local KODO_ID = FourCC("okod")
local SPIRIT_WALKER_ID = FourCC("ospw")
local TAUREN_ID = FourCC("otau")
local SHADOW_HUNTER_ID = FourCC("Oshd")
local RIFLEMAN_ID = FourCC("hrif")
local SPELL_BREAKER_ID = FourCC("hspt")
local CROWN_OF_KINGS_ID = FourCC("ckng")
local WATER_ELEMENTAL_UNIT_IDS = {
    [FourCC("hwat")] = true,
    [FourCC("hwt2")] = true,
    [FourCC("hwt3")] = true,
}

local WINDWALK_ID = FourCC("AOwk")
local CRITICAL_STRIKE_ID = FourCC("AOcr")
local WAR_STOMP_ID = FourCC("AOws")
local SHOCKWAVE_ID = FourCC("AOsh")
local ENDURANCE_AURA_ID = FourCC("AOae")
local WATER_ELEMENTAL_ID = FourCC("AHwe")
local BRILLIANCE_AURA_ID = FourCC("AHab")
local STORM_BOLT_ID = FourCC("AHtb")
local STORM_BOLT_BUFF_ID = FourCC("BHtb")
local THUNDER_CLAP_ID = FourCC("AHtc")
local TIMED_TARGET_IDS = {
    GRUNT_ID, GRUNT_ID, HEADHUNTER_ID, HEADHUNTER_ID, RAIDER_ID,
    KODO_ID, SPIRIT_WALKER_ID, TAUREN_ID, SHADOW_HUNTER_ID,
    TAUREN_CHIEFTAIN_ID,
}
local TIMED_TARGET_NAMES = {
    "Grunt", "Grunt", "Headhunter", "Headhunter", "Raider",
    "Kodo Beast", "Spirit Walker", "Tauren", "Shadow Hunter",
    "Tauren Chieftain",
}
local TIMED_LAYOUT_ROWS = {
    [1] = {{1, 0.0}},
    [2] = {{2, 0.0}},
    [3] = {{2, 0.0}, {1, 0.5}},
    [4] = {{2, 0.0}, {2, 0.5}},
    [5] = {{3, 0.0}, {2, 0.5}},
    [6] = {{3, 0.0}, {3, 0.5}},
    [7] = {{3, 0.0}, {2, 0.5}, {2, 0.0}},
    [8] = {{3, 0.0}, {2, 0.5}, {3, 0.0}},
    [9] = {{3, 0.0}, {3, 0.5}, {3, 0.0}},
    [10] = {{4, 0.0}, {3, 0.5}, {3, 1.0}},
}

local function FormatBriefingText(text)
    local formatted = string.gsub(text, "{Button:%s*(.-)}",
        "|cffffcc00%1|r")
    return string.gsub(formatted, "{Term:%s*(.-)}", "|cffff9933%1|r")
end

local function TrainSkill(hero, abilityId, levels)
    for _ = 1, levels do SelectHeroSkill(hero, abilityId) end
end

local function PrepareHero(hero, skills, level)
    SetHeroLevel(hero, level or 3, false)
    for _, skill in ipairs(skills) do TrainSkill(hero, skill[1], skill[2]) end
    SetUnitState(hero, UNIT_STATE_MANA, BlzGetUnitMaxMana(hero))
end

function JTG.OpenWindwalkPopMenu(originCategory, pauseGame, restorePage,
        restoreData)
    local active = JTG.Controller.session
    local returningFromRun = active ~= nil and active.id == "skills.windwalk"
    local selection = {mode = "normal"}
    for key, value in pairs((active and active.restartData) or {}) do
        selection[key] = value
    end
    for key, value in pairs(restoreData or {}) do selection[key] = value end
    local page = restorePage == "modes" and "modes" or "root"

    local function releaseMenuPause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function resumeCurrentRun()
        releaseMenuPause()
        JTG.ResumeActivity()
    end
    local function launch(mode)
        releaseMenuPause()
        selection.mode = mode
        local restartData = {
            mode = mode,
            skipQuestHighlight = returningFromRun,
        }
        if JTG.Controller.session ~= nil then
            JTG.StartActivityAfterCleanup("skills.windwalk",
                originCategory or "skills", restartData, nil,
                "briefing-restart")
        else
            JTG.StartActivity("skills.windwalk", originCategory or "skills",
                restartData)
        end
    end
    local showBriefing
    showBriefing = function(nextPage)
        page = nextPage or page
        local choices
        local backAction
        if page == "modes" then
            choices = {
                {label = "Normal Mode", primary = true,
                    action = function() launch("normal") end},
                {label = "Hard Mode", primary = true,
                    action = function() launch("hard") end},
                {label = "Timed Training", primary = true,
                    action = function() launch("timed") end},
            }
            backAction = function() showBriefing("root") end
        else
            choices = {
                {label = "Start Training", primary = true,
                    action = function() showBriefing("modes") end},
                {label = "Counterplay", primary = false,
                    action = function() launch("counterplay") end},
            }
            backAction = function() JTG.UI.ShowSkillRace("orc") end
        end
        local spec = {
            title = "Windwalk Pop",
            activityId = "skills.windwalk",
            originCategory = originCategory or "skills",
            headingArtwork = "JTGMenu\\WindwalkPopBriefing.dds",
            headingArtworkWidth = 0.2214,
            headingArtworkHeight = 0.108,
            headingArtworkOffsetX = -0.010,
            headingArtworkOffsetY = -0.027,
            body = FormatBriefingText(WINDWALK_POP_INTRO),
            choices = choices,
            backAction = backAction,
            pauseGame = pauseGame == true,
            pageId = page,
            restoreData = selection,
        }
        if page == "modes" then
            spec.compactChoices = true
            spec.compactColumns = 3
            spec.choiceOffsetY = -0.079
            spec.contentDividerY = -0.245
        end
        if pauseGame then
            spec.resumeAction = resumeCurrentRun
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                returningFromRun = false
                pauseGame = false
                showBriefing(page)
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showBriefing(page)
end

function JTG.CreateWindwalkPopActivity(session)
    local selection = session.restartData or {}
    local activity = {
        mode = selection.mode or "normal",
        blademaster = nil,
        surroundee = nil,
        humanArmy = {},
        archmage = nil,
        summonedWaterElementals = {},
        quests = {},
        highlightQuestOnStart = selection.skipQuestHighlight ~= true,
        timedStage = math.max(1, math.min(10, selection.timedStage or 1)),
        timedTargets = {},
        timedRings = {},
        timedPending = {},
        timedCompleted = 0,
        popOriginX = nil,
        popOriginY = nil,
        hardMovementLocked = false,
        hardTargetMoveSpeed = nil,
        timedCurrent = 1,
        timedRemaining = 5.0,
        finished = false,
        resultPending = false,
        resultKind = nil,
        resultTitleText = nil,
        resultDetailsText = nil,
        resultBackdrop = nil,
        resultTitle = nil,
        resultDetails = nil,
        resultPrimary = nil,
        resultRetry = nil,
        resultReplay = nil,
        resultMenu = nil,
        timerFrame = nil,
        countdownFrame = nil,
        countdownTimer = nil,
        countdownValue = 3,
        countdownActive = false,
        exerciseStarted = false,
        detectorArmed = false,
        windwalkSeen = false,
        overlapSeen = false,
        breakSeen = false,
        overlapX = nil,
        overlapY = nil,
        squaresVisible = selection.squaresVisible == true,
        squareEntries = {},
        presentationVisible = true,
    }

    function activity:createTrainingQuests()
        local definitions = {
            {
                title = "Windwalk Pop",
                icon = "ReplaceableTextures\\CommandButtons\\BTNWindWalkOn.blp",
                text = WINDWALK_POP_QUEST_TEXT,
                required = true,
            },
            {
                title = "Counterplay",
                icon = "ReplaceableTextures\\CommandButtons\\BTNMassTeleport.blp",
                text = COUNTERPLAY_QUEST_TEXT,
                required = false,
            },
        }
        self.quests = {}
        for _, definition in ipairs(definitions) do
            local quest = JTG.ScopeTrackQuest(session.scope, CreateQuest())
            QuestSetTitle(quest, definition.title)
            QuestSetDescription(quest, FormatBriefingText(definition.text))
            QuestSetIconPath(quest, definition.icon)
            QuestSetRequired(quest, definition.required)
            QuestSetDiscovered(quest, true)
            QuestSetEnabled(quest, true)
            table.insert(self.quests, quest)
        end
    end

    function activity:createBlademaster(owner, x, y, facing)
        local hero = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(owner, BLADEMASTER_ID, x, y, facing,
                BLADEMASTER_ID))
        PrepareHero(hero, {{WINDWALK_ID, 2}, {CRITICAL_STRIKE_ID, 1}})
        IssueImmediateOrder(hero, "holdposition")
        self.blademaster = hero
        return hero
    end

    function activity:addSquareOverlay(unit)
        if unit == nil or GetUnitTypeId(unit) == 0 then return end
        local half = JTG.UnitObstructionHalfSize(BlzGetUnitCollisionSize(unit))
        local size = half * 2.0
        local texture = GetOwningPlayer(unit) == Player(0) and
            JTG.UnitSquarePlayerTexture or JTG.UnitSquareEnemyTexture
        local image = JTG.ScopeTrackImage(session.presentationScope,
            CreateImage(texture, size, size, 0,
                GetUnitX(unit) - half, GetUnitY(unit) - half, 2,
                0, 0, 0, 2))
        SetImageRenderAlways(image, true)
        SetImageAboveWater(image, true, true)
        ShowImage(image, self.squaresVisible and self.presentationVisible)
        self.squareEntries[#self.squareEntries + 1] = {
            unit = unit, image = image, half = half,
        }
    end

    function activity:createSquareOverlays()
        self.squareEntries = {}
        local added = {}
        local function add(unit)
            if unit ~= nil and not added[GetHandleId(unit)] then
                added[GetHandleId(unit)] = true
                self:addSquareOverlay(unit)
            end
        end
        add(self.blademaster)
        add(self.surroundee)
        for _, unit in ipairs(self.humanArmy) do add(unit) end
        for _, unit in ipairs(self.timedTargets) do add(unit) end
        for _, ring in ipairs(self.timedRings) do
            for _, unit in ipairs(ring) do add(unit) end
        end
        for _, unit in ipairs(self.summonedWaterElementals) do add(unit) end
    end

    function activity:updateSquareOverlays()
        for _, entry in ipairs(self.squareEntries) do
            if entry.unit ~= nil and GetUnitTypeId(entry.unit) ~= 0 then
                SetImagePosition(entry.image, GetUnitX(entry.unit) - entry.half,
                    GetUnitY(entry.unit) - entry.half, 2)
                ShowImage(entry.image,
                    self.squaresVisible and self.presentationVisible)
            end
        end
    end

    function activity:toggleSquares()
        self.squaresVisible = not self.squaresVisible
        self:updateSquareOverlays()
        if JTG.UI and JTG.UI.SetSquaresActive then
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
    end

    function activity:createResultUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.resultBackdrop = JTG.ScopeTrackFrame(session.presentationScope,
            JTG.UI.CreateNativePanel("JTGWindwalkPopResult", gameUI, 0.32,
                0.345))
        BlzFrameSetSize(self.resultBackdrop, 0.32, 0.345)
        BlzFrameSetAbsPoint(self.resultBackdrop, FRAMEPOINT_CENTER, 0.40,
            0.325)
        self.resultTitle = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGWindwalkPopResultTitle",
                self.resultBackdrop, "", 0))
        BlzFrameSetSize(self.resultTitle, 0.28, 0.032)
        BlzFrameSetPoint(self.resultTitle, FRAMEPOINT_TOP,
            self.resultBackdrop, FRAMEPOINT_TOP, 0, -0.025)
        BlzFrameSetTextAlignment(self.resultTitle, TEXT_JUSTIFY_MIDDLE,
            TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.resultTitle, 1.20)
        self.resultDetails = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGWindwalkPopResultDetails",
                self.resultBackdrop, "", 0))
        BlzFrameSetSize(self.resultDetails, 0.27, 0.070)
        BlzFrameSetPoint(self.resultDetails, FRAMEPOINT_TOP,
            self.resultTitle, FRAMEPOINT_BOTTOM, 0, -0.008)
        BlzFrameSetTextAlignment(self.resultDetails, TEXT_JUSTIFY_TOP,
            TEXT_JUSTIFY_CENTER)
        local function addButton(name, label, x, y, action)
            local button = JTG.ScopeTrackFrame(session.presentationScope,
                BlzCreateFrameByType("GLUETEXTBUTTON", name,
                    self.resultBackdrop, "ScriptDialogButton", 0))
            BlzFrameSetSize(button, 0.170, 0.032)
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, self.resultBackdrop,
                FRAMEPOINT_TOPLEFT, x, y)
            BlzFrameSetText(button, label)
            local trigger = JTG.ScopeTrackTrigger(session.presentationScope,
                CreateTrigger())
            BlzTriggerRegisterFrameEvent(trigger, button,
                FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trigger, function()
                if JTG.UI and JTG.UI.PlayButtonSound then
                    JTG.UI.PlayButtonSound("normal")
                end
                if JTG.UI and JTG.UI.ReleaseFrameFocus then
                    JTG.UI.ReleaseFrameFocus(BlzGetTriggerFrame())
                end
                action()
            end)
            return button
        end
        self.resultPrimary = addButton("JTGWindwalkPopResultPrimary",
            "Continue", 0.075, -0.140, function()
                if self.mode == "timed" and self.resultKind == "success" then
                    if self.timedStage < 10 then
                        self.timedStage = self.timedStage + 1
                    else
                        self.timedStage = 1
                    end
                end
                JTG.ResetActivity()
            end)
        self.resultRetry = addButton("JTGWindwalkPopResultRetry", "Retry",
            0.075, -0.185, function() JTG.ResetActivity() end)
        self.resultReplay = addButton("JTGWindwalkPopResultReplay", "Replay",
            0.075, -0.230, function() JTG.ResetActivity() end)
        self.resultMenu = addButton("JTGWindwalkPopResultMenu", "Menu", 0.075,
            -0.275,
            function()
                BlzFrameSetVisible(self.resultBackdrop, false)
                JTG.OpenTrainingMenu()
            end)
        BlzFrameSetVisible(self.resultBackdrop, false)
    end

    function activity:createTimerUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.timerFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGWindwalkPopTimer", gameUI, "",
                0))
        BlzFrameSetSize(self.timerFrame, 0.34, 0.055)
        BlzFrameSetAbsPoint(self.timerFrame, FRAMEPOINT_TOP, 0.40, 0.535)
        BlzFrameSetTextAlignment(self.timerFrame, TEXT_JUSTIFY_MIDDLE,
            TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.timerFrame, 1.35)
        BlzFrameSetEnable(self.timerFrame, false)
        BlzFrameSetVisible(self.timerFrame, false)
    end

    function activity:createCountdownUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.countdownFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGWindwalkPopCountdown", gameUI,
                "", 0))
        BlzFrameSetSize(self.countdownFrame, 0.20, 0.08)
        BlzFrameSetAbsPoint(self.countdownFrame, FRAMEPOINT_CENTER, 0.40,
            0.38)
        BlzFrameSetTextAlignment(self.countdownFrame, TEXT_JUSTIFY_MIDDLE,
            TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.countdownFrame, 2.45)
        BlzFrameSetEnable(self.countdownFrame, false)
        BlzFrameSetVisible(self.countdownFrame, false)
    end

    function activity:updateTimerUI()
        if self.timerFrame == nil or self.mode ~= "timed" then return end
        BlzFrameSetText(self.timerFrame, "|cffffcc00Stage " ..
            tostring(self.timedStage) .. "|r   Freed " ..
            tostring(self.timedCompleted) .. "/" .. tostring(self.timedStage) ..
            "   |cffffcc00" .. string.format("%.1f", math.max(0,
                self.timedRemaining)) .. "|r")
    end

    function activity:renderResultPresentation()
        if self.resultBackdrop == nil then return end
        BlzFrameSetText(self.resultTitle, self.resultTitleText or "")
        BlzFrameSetText(self.resultDetails, self.resultDetailsText or "")
        local primary = "Replay"
        local showPrimary = self.mode == "timed" and
            self.resultKind == "success"
        if showPrimary then
            primary = self.timedStage < 10 and "Next Stage" or "Restart Course"
        end
        BlzFrameSetText(self.resultPrimary, primary)
        BlzFrameSetVisible(self.resultPrimary, showPrimary)
        BlzFrameSetVisible(self.resultRetry, false)
        BlzFrameClearAllPoints(self.resultRetry)
        BlzFrameClearAllPoints(self.resultReplay)
        BlzFrameClearAllPoints(self.resultMenu)
        BlzFrameSetPoint(self.resultRetry, FRAMEPOINT_TOPLEFT,
            self.resultBackdrop, FRAMEPOINT_TOPLEFT, 0.075, -0.185)
        BlzFrameSetPoint(self.resultMenu, FRAMEPOINT_TOPLEFT,
            self.resultBackdrop, FRAMEPOINT_TOPLEFT, 0.075,
            showPrimary and -0.230 or -0.205)
        BlzFrameSetPoint(self.resultReplay, FRAMEPOINT_TOPLEFT,
            self.resultBackdrop, FRAMEPOINT_TOPLEFT, 0.075,
            showPrimary and -0.185 or -0.160)
        BlzFrameSetVisible(self.resultBackdrop, true)
        if self.timerFrame ~= nil then BlzFrameSetVisible(self.timerFrame, false) end
        if JTG.UI then JTG.UI.HideToolbar() end
    end

    function activity:setTrainingUnitsPaused(paused)
        local function setPaused(unit)
            if unit ~= nil and GetUnitTypeId(unit) ~= 0 then
                PauseUnit(unit, paused)
            end
        end
        setPaused(self.blademaster)
        setPaused(self.surroundee)
        for _, unit in ipairs(self.humanArmy) do setPaused(unit) end
        for _, unit in ipairs(self.timedTargets) do setPaused(unit) end
        for _, ring in ipairs(self.timedRings) do
            for _, unit in ipairs(ring) do setPaused(unit) end
        end
    end

    function activity:pauseTrainingUnits()
        self:setTrainingUnitsPaused(true)
    end

    function activity:startTimedCountdownFormation()
        for _, ring in ipairs(self.timedRings) do
            for _, blocker in ipairs(ring) do PauseUnit(blocker, false) end
        end
        local moveCount = 0
        local function issueMoveSeries()
            moveCount = moveCount + 1
            for index, ring in ipairs(self.timedRings) do
                local target = self.timedTargets[index]
                for _, blocker in ipairs(ring) do
                    IssueTargetOrder(blocker, "move", target)
                end
            end
            if moveCount >= 5 then
                local holdTimer = JTG.ScopeTrackTimer(session.scope,
                    CreateTimer())
                TimerStart(holdTimer, 0.25, false,
                    JTG.GuardSession(session, function()
                        for _, ring in ipairs(self.timedRings) do
                            for _, blocker in ipairs(ring) do
                                IssueImmediateOrder(blocker, "holdposition")
                                PauseUnit(blocker, true)
                            end
                        end
                    end))
                return true
            end
            return false
        end
        issueMoveSeries()
        local moveTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(moveTimer, 0.15, true,
            JTG.GuardSession(session, function()
                if issueMoveSeries() then PauseTimer(moveTimer) end
            end))
    end

    function activity:beginExercise()
        if self.exerciseStarted or self.finished then return end
        self.exerciseStarted = true
        self.countdownActive = false
        self:setTrainingUnitsPaused(false)
        local centerX = session.scene.centerX
        local centerY = session.scene.centerY
        if self.mode == "normal" then
            self:startBasicSurround()
            self:startPopDetection()
        elseif self.mode == "hard" then
            self:lockHardTargetMovement(5.0)
            self:stageHardSurround(centerX, centerY)
            self:startPopDetection()
        elseif self.mode == "timed" then
            self:startPopDetection()
            self:updateTimerUI()
            BlzFrameSetVisible(self.timerFrame, true)
        else
            self:stageCounterplay(centerX, centerY)
        end
    end

    function activity:countdownTick()
        if self.countdownValue > 1 then
            self.countdownValue = self.countdownValue - 1
            BlzFrameSetText(self.countdownFrame, "|cffffcc00" ..
                tostring(self.countdownValue) .. "|r")
            return
        end
        PauseTimer(self.countdownTimer)
        self.countdownValue = 0
        BlzFrameSetText(self.countdownFrame, "|cff80ff80GO!|r")
        self:beginExercise()
        local hideTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(hideTimer, 0.65, false,
            JTG.GuardSession(session, function()
                if self.countdownFrame ~= nil then
                    BlzFrameSetVisible(self.countdownFrame, false)
                end
            end))
    end

    function activity:startCountdown()
        self.countdownActive = true
        self.countdownValue = 3
        self:setTrainingUnitsPaused(true)
        if self.mode == "timed" then self:startTimedCountdownFormation() end
        BlzFrameSetText(self.countdownFrame, "|cffffcc003|r")
        BlzFrameSetVisible(self.countdownFrame, true)
        self.countdownTimer = JTG.ScopeTrackTimer(session.scope,
            CreateTimer())
        TimerStart(self.countdownTimer, 1.0, true,
            JTG.GuardSession(session, function() self:countdownTick() end))
    end

    function activity:finish(kind, title, details)
        if self.finished then return end
        self.finished = true
        self.resultPending = true
        self.resultKind = kind
        self.resultTitleText = title
        self.resultDetailsText = details
        self:pauseTrainingUnits()
        if self.timerFrame ~= nil then BlzFrameSetVisible(self.timerFrame, false) end
        if JTG.UI then JTG.UI.HideToolbar() end
        local resultDelay = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(resultDelay, 1.0, false,
            JTG.GuardSession(session, function()
                self.resultPending = false
                self:renderResultPresentation()
            end))
    end

    function activity:currentSurrounders()
        if self.mode == "timed" then
            return self.timedRings[self.timedCurrent] or {}
        end
        return self.humanArmy
    end

    function activity:countClosedSides()
        local target = self.surroundee
        if target == nil or GetUnitTypeId(target) == 0 then return 0 end
        local tx, ty = GetUnitX(target), GetUnitY(target)
        local occupied = {false, false, false, false}
        for _, unit in ipairs(self:currentSurrounders()) do
            if unit ~= nil and GetUnitTypeId(unit) ~= 0 and
                    GetWidgetLife(unit) > 0.405 then
                local dx, dy = GetUnitX(unit) - tx, GetUnitY(unit) - ty
                if dx * dx + dy * dy <= 150.0 * 150.0 then
                    if math.abs(dx) >= math.abs(dy) then
                        occupied[dx >= 0 and 1 or 2] = true
                    else
                        occupied[dy >= 0 and 3 or 4] = true
                    end
                end
            end
        end
        local count = 0
        for index = 1, 4 do if occupied[index] then count = count + 1 end end
        return count
    end

    function activity:isCurrentSurrounder(candidate)
        for _, unit in ipairs(self:currentSurrounders()) do
            if candidate == unit then return true end
        end
        return false
    end

    function activity:resetPopAttempt()
        self.windwalkSeen = false
        self.overlapSeen = false
        self.breakSeen = false
        self.overlapX = nil
        self.overlapY = nil
        self.detectorArmed = self.mode == "timed" or
            self:countClosedSides() == 4
    end

    function activity:markPoppedUnit(unit)
        SetUnitAnimation(unit, "stand hit")
        SetUnitVertexColor(unit, 120, 255, 120, 255)
        PauseUnit(unit, true)
        DestroyEffect(AddSpecialEffect(
            "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl",
            GetUnitX(unit), GetUnitY(unit)))
    end

    function activity:completeTimedTarget(entry, pendingIndex)
        self:markPoppedUnit(entry.unit)
        table.remove(self.timedPending, pendingIndex)
        self.timedCompleted = self.timedCompleted + 1
        if #self.timedPending == 0 then
            self:finish("success", "STAGE COMPLETE", "You freed all " ..
                tostring(self.timedStage) .. " surrounded units.")
            return
        end
        self.timedRemaining = 5.0
        SetUnitState(self.blademaster, UNIT_STATE_MANA,
            BlzGetUnitMaxMana(self.blademaster))
        BlzStartUnitAbilityCooldown(self.blademaster, WINDWALK_ID, 0.0)
        self:updateTimerUI()
    end

    function activity:playPopSuccessSound()
        local successSound = CreateSound(
            "Sound\\Interface\\QuestActivateWhat1.wav", false, false,
            false, 10, 10, "DefaultEAXON")
        SetSoundChannel(successSound, 5)
        SetSoundVolume(successSound, 72)
        StartSound(successSound)
        KillSoundWhenDone(successSound)
    end

    function activity:startPopDetection()
        if self.mode == "timed" then
            self.timedPending = {}
            self.timedCompleted = 0
            for index, unit in ipairs(self.timedTargets) do
                self.timedPending[#self.timedPending + 1] = {
                    unit = unit,
                    index = index,
                    startX = GetUnitX(unit),
                    startY = GetUnitY(unit),
                }
            end
            self:updateTimerUI()
        else
            self.popOriginX = GetUnitX(self.surroundee)
            self.popOriginY = GetUnitY(self.surroundee)
        end

        local monitor = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(monitor, 0.05, true,
            JTG.GuardSession(session, function()
                if self.finished then PauseTimer(monitor) return end
                if self.mode == "timed" then
                    for index = #self.timedPending, 1, -1 do
                        local entry = self.timedPending[index]
                        local unit = entry.unit
                        if unit == nil or GetUnitTypeId(unit) == 0 or
                                GetWidgetLife(unit) <= 0.405 then
                            self:finish("failure", "TARGET SLAIN",
                                "A surrounded unit died before it could be freed.")
                            return
                        end
                        local dx = GetUnitX(unit) - entry.startX
                        local dy = GetUnitY(unit) - entry.startY
                        if dx * dx + dy * dy >= 100.0 * 100.0 then
                            self:playPopSuccessSound()
                            self:completeTimedTarget(entry, index)
                            if self.finished then return end
                        end
                    end
                    self.timedRemaining = self.timedRemaining - 0.05
                    self:updateTimerUI()
                    if self.timedRemaining <= 0 then
                        self:finish("failure", "TIME EXPIRED", "You freed " ..
                            tostring(self.timedCompleted) .. " of " ..
                            tostring(self.timedStage) .. " units in this stage.")
                    end
                    return
                end

                local target = self.surroundee
                if target == nil or GetUnitTypeId(target) == 0 or
                        GetWidgetLife(target) <= 0.405 then
                    local title = self.mode == "hard" and
                        "TAUREN CHIEFTAIN SLAIN" or "TARGET SLAIN"
                    self:finish("failure", title,
                        "The surrounded unit died before it could be freed.")
                    return
                end
                local movedX = GetUnitX(target) - self.popOriginX
                local movedY = GetUnitY(target) - self.popOriginY
                if movedX * movedX + movedY * movedY >= 100.0 * 100.0 then
                    self:playPopSuccessSound()
                    self:markPoppedUnit(target)
                    self:finish("success", "WINDWALK POP SUCCESSFUL",
                        "The surrounded unit escaped after the Blademaster " ..
                        "restored his collision.")
                    return
                end
            end))
    end

    function activity:createTimedScenario(centerX, centerY)
        self.timedTargets = {}
        self.timedRings = {}
        local rows = TIMED_LAYOUT_ROWS[self.timedStage]
        local spacingX = 360.0
        local spacingY = 285.0
        local rawPositions = {}
        local minX, maxX = nil, nil
        for rowIndex, row in ipairs(rows) do
            local count, indent = row[1], row[2]
            for column = 1, count do
                local x = (indent + column - 1) * spacingX
                local y = -(rowIndex - 1) * spacingY
                rawPositions[#rawPositions + 1] = {x = x, y = y}
                minX = minX == nil and x or math.min(minX, x)
                maxX = maxX == nil and x or math.max(maxX, x)
            end
        end
        local horizontalCenter = (minX + maxX) * 0.5
        local verticalCenter = -(#rows - 1) * spacingY * 0.5
        for index = 1, self.timedStage do
            local x = centerX + rawPositions[index].x - horizontalCenter
            local y = centerY + rawPositions[index].y - verticalCenter
            local unitId = TIMED_TARGET_IDS[index]
            local target = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(Player(0), unitId, x, y, 270.0,
                    unitId))
            if unitId == SHADOW_HUNTER_ID or
                    unitId == TAUREN_CHIEFTAIN_ID then
                SetHeroLevel(target, 3, false)
            end
            IssueImmediateOrder(target, "holdposition")
            self.timedTargets[index] = target
            local ring = {}
            local directions = {{0, 1, 270}, {1, 0, 180},
                {0, -1, 90}, {-1, 0, 0}}
            for _, direction in ipairs(directions) do
                local blocker = JTG.ScopeTrackUnit(session.scope,
                    BlzCreateUnitWithSkin(Player(1), FOOTMAN_ID,
                        x + direction[1] * 200.0,
                        y + direction[2] * 200.0, direction[3], FOOTMAN_ID))
                local contactDistance = BlzGetUnitCollisionSize(target) +
                    BlzGetUnitCollisionSize(blocker) + 1.0
                local spawnDistance = contactDistance + 100.0
                SetUnitX(blocker, x + direction[1] * spawnDistance)
                SetUnitY(blocker, y + direction[2] * spawnDistance)
                BlzSetUnitMaxHP(blocker, 10000)
                SetUnitState(blocker, UNIT_STATE_LIFE, 10000)
                UnitRemoveAbility(blocker, FourCC("Aatk"))
                IssueImmediateOrder(blocker, "holdposition")
                ring[#ring + 1] = blocker
            end
            self.timedRings[index] = ring
        end
        self.timedCurrent = 1
        self.timedRemaining = 5.0
        self.timedPending = {}
        self.timedCompleted = 0
        self.surroundee = self.timedTargets[1]
        self.humanArmy = self.timedRings[1]
        local firstX, firstY = GetUnitX(self.surroundee),
            GetUnitY(self.surroundee)
        self:createBlademaster(Player(0), firstX - 360.0, firstY - 240.0,
            45.0)
        self:resetPopAttempt()
    end

    function activity:createHumanArmy(owner, centerX, centerY)
        local specifications = {
            {ARCHMAGE_ID, -190.0, -300.0, 90.0},
            {MOUNTAIN_KING_ID, 190.0, -300.0, 90.0},
            {FOOTMAN_ID, -285.0, -245.0, 90.0},
            {FOOTMAN_ID, 285.0, -245.0, 90.0},
            {RIFLEMAN_ID, -95.0, -340.0, 90.0},
            {RIFLEMAN_ID, 95.0, -340.0, 90.0},
            {SPELL_BREAKER_ID, -190.0, -245.0, 90.0},
            {SPELL_BREAKER_ID, 190.0, -245.0, 90.0},
        }
        self.humanArmy = {}
        self.archmage = nil
        self.summonedWaterElementals = {}
        self.mountainKing = nil
        for _, spec in ipairs(specifications) do
            local unit = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(owner, spec[1], centerX + spec[2],
                    centerY + spec[3], spec[4], spec[1]))
            if spec[1] == ARCHMAGE_ID then
                PrepareHero(unit,
                    {{WATER_ELEMENTAL_ID, 2}, {BRILLIANCE_AURA_ID, 1}})
                self.archmage = unit
            elseif spec[1] == MOUNTAIN_KING_ID then
                PrepareHero(unit, {{STORM_BOLT_ID, 2}, {THUNDER_CLAP_ID, 1}})
                self.mountainKing = unit
            end
            table.insert(self.humanArmy, unit)
        end

        local summonTrigger = JTG.ScopeTrackTrigger(session.scope,
            CreateTrigger())
        TriggerRegisterPlayerUnitEvent(summonTrigger, owner,
            EVENT_PLAYER_UNIT_SUMMON, nil)
        TriggerAddAction(summonTrigger, JTG.GuardSession(session, function()
            local summoned = GetSummonedUnit()
            if GetSummoningUnit() == self.archmage and summoned ~= nil and
                    WATER_ELEMENTAL_UNIT_IDS[GetUnitTypeId(summoned)] then
                table.insert(self.summonedWaterElementals, summoned)
                self:addSquareOverlay(summoned)
            end
        end))
        JTG.ScopeAdd(session.scope, function()
            for _, summoned in ipairs(self.summonedWaterElementals) do
                if summoned ~= nil and GetUnitTypeId(summoned) ~= 0 then
                    RemoveUnit(summoned)
                end
            end
            self.summonedWaterElementals = {}
        end)
    end

    function activity:formBasicSurround(centerX, centerY)
        local positions = {
            {centerX, centerY + 200.0, 270.0},
            {centerX + 200.0, centerY, 180.0},
            {centerX, centerY - 200.0, 90.0},
            {centerX - 200.0, centerY, 0.0},
        }
        self.humanArmy = {}
        for _, point in ipairs(positions) do
            local enemy = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(Player(1), FOOTMAN_ID, point[1], point[2],
                    point[3], FOOTMAN_ID))
            table.insert(self.humanArmy, enemy)
        end
    end

    function activity:startBasicSurround()
        local formationStep = 0
        local timer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(timer, 0.25, true,
            JTG.GuardSession(session, function()
                formationStep = formationStep + 1
                for _, enemy in ipairs(self.humanArmy) do
                    if formationStep <= 5 then
                        IssueTargetOrder(enemy, "move", self.surroundee)
                    else
                        IssuePointOrder(enemy, "attack",
                            GetUnitX(self.surroundee), GetUnitY(self.surroundee))
                    end
                end
                if formationStep > 5 then PauseTimer(timer) end
            end))
    end

    function activity:adjustOpenCardinalSides()
        local tcX = GetUnitX(self.surroundee)
        local tcY = GetUnitY(self.surroundee)
        local sides = {
            {name = "east", x = 1.0, y = 0.0, occupied = false},
            {name = "west", x = -1.0, y = 0.0, occupied = false},
            {name = "north", x = 0.0, y = 1.0, occupied = false},
            {name = "south", x = 0.0, y = -1.0, occupied = false},
        }
        local available = {}
        for _, unit in ipairs(self.humanArmy) do
            local dx = GetUnitX(unit) - tcX
            local dy = GetUnitY(unit) - tcY
            local assigned = false
            if dx >= 45.0 and dx <= 110.0 and math.abs(dy) <= 65.0 then
                sides[1].occupied = true
                assigned = true
            elseif dx <= -45.0 and dx >= -110.0 and
                    math.abs(dy) <= 65.0 then
                sides[2].occupied = true
                assigned = true
            elseif dy >= 45.0 and dy <= 110.0 and
                    math.abs(dx) <= 65.0 then
                sides[3].occupied = true
                assigned = true
            elseif dy <= -45.0 and dy >= -110.0 and
                    math.abs(dx) <= 65.0 then
                sides[4].occupied = true
                assigned = true
            end
            if not assigned then table.insert(available, unit) end
        end

        local moved = false
        local contactOffset = 80.0
        for _, side in ipairs(sides) do
            if not side.occupied and #available > 0 then
                local targetX = tcX + side.x * contactOffset
                local targetY = tcY + side.y * contactOffset
                local bestIndex = 1
                local bestDistance = nil
                for index, unit in ipairs(available) do
                    local dx = GetUnitX(unit) - targetX
                    local dy = GetUnitY(unit) - targetY
                    local distance = dx * dx + dy * dy
                    if bestDistance == nil or distance < bestDistance then
                        bestDistance = distance
                        bestIndex = index
                    end
                end
                local unit = table.remove(available, bestIndex)
                IssuePointOrder(unit, "move", targetX, targetY)
                moved = true
            end
        end
        return moved
    end

    function activity:orderHumanArmyToAttack()
        local army = CreateGroup()
        for _, unit in ipairs(self.humanArmy) do
            GroupAddUnit(army, unit)
        end
        GroupTargetOrder(army, "attack", self.surroundee)
        DestroyGroup(army)
    end

    function activity:waitForHumanArmyStill(callback)
        local previous = {}
        for index, unit in ipairs(self.humanArmy) do
            previous[index] = {x = GetUnitX(unit), y = GetUnitY(unit)}
        end
        local stableTicks = 0
        local stillTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(stillTimer, 0.10, true,
            JTG.GuardSession(session, function()
                local allStill = true
                for index, unit in ipairs(self.humanArmy) do
                    local x = GetUnitX(unit)
                    local y = GetUnitY(unit)
                    local dx = x - previous[index].x
                    local dy = y - previous[index].y
                    if dx * dx + dy * dy > 1.0 then allStill = false end
                    previous[index].x = x
                    previous[index].y = y
                end
                if allStill then stableTicks = stableTicks + 1
                else stableTicks = 0 end
                if stableTicks >= 1 then
                    PauseTimer(stillTimer)
                    callback()
                end
            end))
    end

    function activity:beginHardAttack()
        self:orderHumanArmyToAttack()
        local groundAttackTimer = JTG.ScopeTrackTimer(session.scope,
            CreateTimer())
        TimerStart(groundAttackTimer, 1.00, false,
            JTG.GuardSession(session, function()
                local targetX = GetUnitX(self.surroundee)
                local targetY = GetUnitY(self.surroundee)
                local army = CreateGroup()
                for _, unit in ipairs(self.humanArmy) do
                    GroupAddUnit(army, unit)
                end
                GroupPointOrder(army, "attack", targetX, targetY)
                DestroyGroup(army)
            end))
    end

    function activity:finishHardSurround()
        local moved = self:adjustOpenCardinalSides()
        if moved then
            self:waitForHumanArmyStill(function()
                self:beginHardAttack()
            end)
        else
            self:beginHardAttack()
        end
    end

    function activity:beginHardSurrounding()
        local moveCount = 0
        local function issueMoveOrders()
            moveCount = moveCount + 1
            for _, unit in ipairs(self.humanArmy) do
                IssueTargetOrder(unit, "move", self.surroundee)
            end
            return moveCount >= 5
        end

        issueMoveOrders()
        local moveTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(moveTimer, 0.15, true,
            JTG.GuardSession(session, function()
                if issueMoveOrders() then
                    PauseTimer(moveTimer)
                    self:finishHardSurround()
                end
            end))
    end

    function activity:stageHardSurround(centerX, centerY)
        local function beginPositioning()
            local tcX = GetUnitX(self.surroundee)
            local tcY = GetUnitY(self.surroundee)
            for _, unit in ipairs(self.humanArmy) do
                IssuePointOrder(unit, "move", tcX, tcY + 600.0)
            end

            local approachTimer = JTG.ScopeTrackTimer(session.scope,
                CreateTimer())
            TimerStart(approachTimer, 0.03, true,
                JTG.GuardSession(session, function()
                    local liveTcY = GetUnitY(self.surroundee)
                    for _, unit in ipairs(self.humanArmy) do
                        if GetUnitY(unit) >= liveTcY + 250.0 then
                            PauseTimer(approachTimer)
                            self:beginHardSurrounding()
                            return
                        end
                    end
                end))
        end

        IssueTargetOrder(self.mountainKing, "thunderbolt", self.surroundee)
        local stunPollTicks = 0
        local stunTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(stunTimer, 0.03, true,
            JTG.GuardSession(session, function()
                stunPollTicks = stunPollTicks + 1
                if GetUnitAbilityLevel(self.surroundee,
                        STORM_BOLT_BUFF_ID) > 0 or stunPollTicks >= 100 then
                    PauseTimer(stunTimer)
                    beginPositioning()
                end
            end))
    end

    function activity:lockHardTargetMovement(duration)
        local target = self.surroundee
        self.hardMovementLocked = true
        self.hardTargetMoveSpeed = GetUnitMoveSpeed(target)
        local lockX, lockY = GetUnitX(target), GetUnitY(target)
        SetUnitMoveSpeed(target, 0)

        local orderTrigger = JTG.ScopeTrackTrigger(session.scope,
            CreateTrigger())
        TriggerRegisterPlayerUnitEvent(orderTrigger, Player(0),
            EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
        TriggerAddAction(orderTrigger, JTG.GuardSession(session, function()
            if not self.hardMovementLocked or GetTriggerUnit() ~= target then
                return
            end
            local dx = GetOrderPointX() - GetUnitX(target)
            local dy = GetOrderPointY() - GetUnitY(target)
            IssueImmediateOrder(target, "stop")
            SetUnitFacingTimed(target, math.deg(Atan2(dy, dx)), 0)
        end))

        local lockTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(lockTimer, 0.03, true,
            JTG.GuardSession(session, function()
                if not self.hardMovementLocked then
                    PauseTimer(lockTimer)
                    return
                end
                SetUnitX(target, lockX)
                SetUnitY(target, lockY)
            end))

        local releaseTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(releaseTimer, duration, false,
            JTG.GuardSession(session, function()
                self.hardMovementLocked = false
                PauseTimer(lockTimer)
                SetUnitMoveSpeed(target, self.hardTargetMoveSpeed)
                IssueImmediateOrder(target, "holdposition")
            end))
    end

    function activity:startCounterplayResolution()
        local originX = GetUnitX(self.surroundee)
        local originY = GetUnitY(self.surroundee)
        local previousX, previousY = originX, originY
        local elapsed = 0.0
        local stillTime = 0.0
        local resolutionTimer = JTG.ScopeTrackTimer(session.scope,
            CreateTimer())
        TimerStart(resolutionTimer, 0.05, true,
            JTG.GuardSession(session, function()
                if self.finished then PauseTimer(resolutionTimer) return end
                elapsed = elapsed + 0.05
                local x, y = GetUnitX(self.surroundee),
                    GetUnitY(self.surroundee)
                local totalDx, totalDy = x - originX, y - originY
                if totalDx * totalDx + totalDy * totalDy >= 300.0 * 300.0 then
                    PauseTimer(resolutionTimer)
                    self:finish("failure", "TAUREN CHIEFTAIN ESCAPED",
                        "The Tauren Chieftain moved 300 units away from the " ..
                        "surround.")
                    return
                end
                if elapsed <= 4.0 then
                    local dx, dy = x - previousX, y - previousY
                    if dx * dx + dy * dy <= 1.0 then
                        stillTime = stillTime + 0.05
                    else
                        stillTime = 0.0
                    end
                    if stillTime >= 2.0 then
                        PauseTimer(resolutionTimer)
                        self:finish("success", "COUNTERPLAY SUCCESSFUL",
                            "The Tauren Chieftain remained trapped after the " ..
                            "Windwalk Pop.")
                        return
                    end
                end
                previousX, previousY = x, y
            end))
    end

    function activity:stageCounterplay(centerX, centerY)
        local radius = 108.0
        for index, unit in ipairs(self.humanArmy) do
            local angle = (index - 1) * bj_PI * 0.25
            SetUnitPosition(unit, centerX + radius * Cos(angle),
                centerY + radius * Sin(angle))
            IssueTargetOrder(unit, "attack", self.surroundee)
        end
        local beginTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(beginTimer, 3.0, false,
            JTG.GuardSession(session, function()
                IssueImmediateOrder(self.blademaster, "windwalk")
                IssuePointOrder(self.blademaster, "move",
                    GetUnitX(self.surroundee), GetUnitY(self.surroundee))
                local enteredTicks = 0
                local enterTimer = JTG.ScopeTrackTimer(session.scope,
                    CreateTimer())
                TimerStart(enterTimer, 0.10, true,
                    JTG.GuardSession(session, function()
                        enteredTicks = enteredTicks + 1
                        local dx = GetUnitX(self.blademaster) -
                            GetUnitX(self.surroundee)
                        local dy = GetUnitY(self.blademaster) -
                            GetUnitY(self.surroundee)
                        if dx * dx + dy * dy <= 75.0 * 75.0 or
                                enteredTicks >= 50 then
                            PauseTimer(enterTimer)
                            if self.humanArmy[1] ~= nil then
                                IssueTargetOrder(self.blademaster, "attack",
                                    self.humanArmy[1])
                            end
                            local visibilityTicks = 0
                            local visibilityTimer = JTG.ScopeTrackTimer(
                                session.scope, CreateTimer())
                            TimerStart(visibilityTimer, 0.03, true,
                                JTG.GuardSession(session, function()
                                    visibilityTicks = visibilityTicks + 1
                                    if IsUnitInvisible(self.blademaster,
                                            Player(0)) and
                                            visibilityTicks < 200 then
                                        return
                                    end
                                    PauseTimer(visibilityTimer)
                                    self:startCounterplayResolution()
                                    IssuePointOrder(self.surroundee, "move",
                                        centerX + 350.0, centerY)
                                    local jointMoveTimer =
                                        JTG.ScopeTrackTimer(session.scope,
                                            CreateTimer())
                                    TimerStart(jointMoveTimer, 0.50, false,
                                        JTG.GuardSession(session, function()
                                            local escapingUnits = CreateGroup()
                                            GroupAddUnit(escapingUnits,
                                                self.surroundee)
                                            GroupAddUnit(escapingUnits,
                                                self.blademaster)
                                            GroupPointOrder(escapingUnits,
                                                "move", centerX + 350.0,
                                                centerY)
                                            DestroyGroup(escapingUnits)
                                        end))
                                end))
                        end
                    end))
            end))
    end

    function activity:createScenario()
        local centerX = session.scene.centerX
        local centerY = session.scene.centerY
        local p0 = Player(0)
        local p1 = Player(1)

        if self.mode == "normal" then
            self.surroundee = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(p0, GRUNT_ID, centerX, centerY, 0.0,
                    GRUNT_ID))
            IssueImmediateOrder(self.surroundee, "holdposition")
            self:createBlademaster(p0, centerX - 360.0, centerY - 240.0,
                45.0)
            self:formBasicSurround(centerX, centerY)
        elseif self.mode == "hard" then
            -- The Blademaster is created first so he always occupies F1.
            self:createBlademaster(p0, centerX - 730.0, centerY - 80.0, 0.0)
            self.surroundee = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(p0, TAUREN_CHIEFTAIN_ID, centerX,
                    centerY, 270.0, TAUREN_CHIEFTAIN_ID))
            PrepareHero(self.surroundee,
                {{SHOCKWAVE_ID, 2}, {ENDURANCE_AURA_ID, 1}})
            UnitAddItemById(self.surroundee, CROWN_OF_KINGS_ID)
            IssueImmediateOrder(self.surroundee, "holdposition")
            self:createHumanArmy(p1, centerX, centerY)
        elseif self.mode == "timed" then
            self:createTimedScenario(centerX, centerY)
        else
            self.surroundee = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(p1, TAUREN_CHIEFTAIN_ID, centerX,
                    centerY, 270.0, TAUREN_CHIEFTAIN_ID))
            PrepareHero(self.surroundee,
                {{SHOCKWAVE_ID, 2}, {ENDURANCE_AURA_ID, 1}})
            UnitAddItemById(self.surroundee, CROWN_OF_KINGS_ID)
            IssueImmediateOrder(self.surroundee, "holdposition")
            self:createBlademaster(p1, centerX - 430.0, centerY - 80.0, 0.0)
            self:createHumanArmy(p0, centerX, centerY)
        end

        if GetLocalPlayer() == p0 then
            ClearSelection()
            if self.mode == "counterplay" then
                for _, unit in ipairs(self.humanArmy) do SelectUnit(unit, true) end
            else
                SelectUnit(self.blademaster, true)
            end
        end
    end

    function activity:setup(current)
        local p0 = Player(0)
        local p1 = Player(1)
        JTG.BorrowCamera(current.scope, p0)

        local passive01 = GetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE)
        local passive10 = GetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE)
        local oldController = GetPlayerController(p1)
        local oldColor = GetPlayerColor(p1)
        JTG.ScopeAdd(current.scope, function()
            SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, passive01)
            SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, passive10)
            SetPlayerController(p1, oldController)
            SetPlayerColor(p1, oldColor)
        end)
        SetPlayerController(p1, MAP_CONTROL_COMPUTER)
        SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, false)
        SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, false)
        SetPlayerColor(p1, ConvertPlayerColor(1))

        JTG.ResetWorldFog(p0)
        JTG.ScopeRevealScene(current.scope, current.scene, p0)

        self:createScenario()
        self:createSquareOverlays()
        self.squareTimer = JTG.ScopeTrackTimer(current.scope, CreateTimer())
        TimerStart(self.squareTimer, 0.03, true,
            JTG.GuardSession(current, function()
                self:updateSquareOverlays()
            end))
        self:createTrainingQuests()
        self:createTimerUI()
        self:createCountdownUI()
        self:createResultUI()
    end

    function activity:start(current)
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(current.scene.centerX, current.scene.centerY)
        end
        if self.highlightQuestOnStart and JTG.UI and
                JTG.UI.HighlightQuestButton then
            JTG.UI.HighlightQuestButton(5.0)
        end
        if JTG.UI and JTG.UI.SetSquaresActive then
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
        self:startCountdown()
    end

    function activity:captureResetState()
        return {mode = self.mode, timedStage = self.timedStage,
            skipQuestHighlight = true, squaresVisible = self.squaresVisible}
    end

    function activity:restorePresentation()
        self.presentationVisible = true
        if self.finished then
            if not self.resultPending then self:renderResultPresentation()
            elseif JTG.UI then JTG.UI.HideToolbar() end
        elseif self.countdownActive then
            BlzFrameSetText(self.countdownFrame, self.countdownValue > 0 and
                ("|cffffcc00" .. tostring(self.countdownValue) .. "|r") or
                "|cff80ff80GO!|r")
            BlzFrameSetVisible(self.countdownFrame, true)
            if JTG.UI then
                JTG.UI.ShowToolbar(session.descriptor.capabilities)
                JTG.UI.SetSquaresActive(self.squaresVisible)
            end
        else
            if self.timerFrame ~= nil then
                BlzFrameSetVisible(self.timerFrame, self.mode == "timed")
                self:updateTimerUI()
            end
            if JTG.UI then
                JTG.UI.ShowToolbar(session.descriptor.capabilities)
                JTG.UI.SetSquaresActive(self.squaresVisible)
            end
        end
    end

    function activity:hidePresentationForMenu()
        self.presentationVisible = false
        if self.timerFrame ~= nil then BlzFrameSetVisible(self.timerFrame, false) end
        if self.countdownFrame ~= nil then
            BlzFrameSetVisible(self.countdownFrame, false)
        end
        if self.resultBackdrop ~= nil then
            BlzFrameSetVisible(self.resultBackdrop, false)
        end
        self:updateSquareOverlays()
    end

    function activity:rebuildPresentation()
        self.resultBackdrop = nil
        self.resultTitle = nil
        self.resultDetails = nil
        self.resultPrimary = nil
        self.resultRetry = nil
        self.resultReplay = nil
        self.resultMenu = nil
        self.timerFrame = nil
        self.countdownFrame = nil
        self:createTimerUI()
        self:createCountdownUI()
        self:createResultUI()
        self:createSquareOverlays()
        if self.finished then
            if not self.resultPending then self:renderResultPresentation()
            elseif JTG.UI then JTG.UI.HideToolbar() end
        elseif self.countdownActive then
            BlzFrameSetText(self.countdownFrame, self.countdownValue > 0 and
                ("|cffffcc00" .. tostring(self.countdownValue) .. "|r") or
                "|cff80ff80GO!|r")
            BlzFrameSetVisible(self.countdownFrame, true)
        elseif self.mode == "timed" then
            self:updateTimerUI()
            BlzFrameSetVisible(self.timerFrame, true)
        end
    end

    function activity:discardPresentationForLoad()
        self.resultBackdrop = nil
        self.resultTitle = nil
        self.resultDetails = nil
        self.resultPrimary = nil
        self.resultRetry = nil
        self.resultReplay = nil
        self.resultMenu = nil
        self.timerFrame = nil
        self.countdownFrame = nil
        self.squareEntries = {}
    end

    function activity:cleanup()
        if JTG.UI then JTG.UI.HideActivityBriefing() end
        for _, summoned in ipairs(self.summonedWaterElementals) do
            if summoned ~= nil and GetUnitTypeId(summoned) ~= 0 then
                RemoveUnit(summoned)
            end
        end
        self.blademaster = nil
        self.surroundee = nil
        self.humanArmy = {}
        self.archmage = nil
        self.summonedWaterElementals = {}
        self.mountainKing = nil
        self.quests = {}
        self.timedTargets = {}
        self.timedRings = {}
        self.timedPending = {}
        self.timedCompleted = 0
        self.popOriginX = nil
        self.popOriginY = nil
        self.hardMovementLocked = false
        self.hardTargetMoveSpeed = nil
        self.squareEntries = {}
    end

    return activity
end
