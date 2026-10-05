-- Windwalk Pop: use Wind Walk's native loss and restoration of collision to
-- displace a surrounded Orc unit. The normal setup teaches the isolated
-- mechanic; Hard Mode and Counterplay run randomized four-stage racial courses.
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
    "5. Select the surrounded unit and give it any command. Move, Attack, " ..
    "Hold Position, Stop, Patrol and ability commands all make it regain " ..
    "collision with the Blademaster.\n\n" ..
    "If executed correctly, the surrounded unit will pop out of the " ..
    "surround. An ability can be particularly useful here. For example, a " ..
    "Tauren Chieftain can use War Stomp immediately after the pop to prevent " ..
    "a chase.\n\n" ..
    "Press the {Button: Squares} button to display the areas that units " ..
    "obstruct. These areas snap to a 32x32 in-game unit grid, so they do not " ..
    "move seamlessly like the units do. You can also display the snap points " ..
    "and a finer 8x8 grid.\n\n" ..
    "Of course, now the Blademaster is surrounded, so you should not do " ..
    "this when he does not have enough mana for two Wind Walks."

local COUNTERPLAY_QUEST_TEXT =
    "Knowing you are facing a Blademaster, you can try to counterplay the " ..
    "Windwalk pop.\n\n" ..
    "To do this, you need to see it coming.\n\n" ..
    "If you now loosen the surround a bit, so the surrounded unit is still " ..
    "trapped, but so there is enough space for it and the Blademaster, the " ..
    "Windwalk Pop will instead also trap the Blademaster in the surround.\n\n" ..
    "A Windwalk pop may also be made impossible if there is simply no room " ..
    "to displace the surrounded unit to. This can be the case particularly " ..
    "in a very tight surround with 8 units: one unit on every side and " ..
    "every corner.\n\n" ..
    "Press the {Button: Squares} button to display the areas that units " ..
    "obstruct. These areas snap to a 32x32 in-game unit grid, so they do not " ..
    "move seamlessly like the units do. You can also display the snap points " ..
    "and a finer 8x8 grid."

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
local TROLL_BERSERKER_ID = FourCC("otbk")
local GHOUL_ID = FourCC("ugho")
local DEATH_KNIGHT_ID = FourCC("Udea")
local ABOMINATION_ID = FourCC("uabo")
local NECROMANCER_ID = FourCC("unec")
local LICH_ID = FourCC("Ulic")
local HUNTRESS_ID = FourCC("esen")
local DEMON_HUNTER_ID = FourCC("Edem")
local DRYAD_ID = FourCC("edry")
local DRUID_OF_THE_CLAW_ID = FourCC("edoc")
local KEEPER_OF_THE_GROVE_ID = FourCC("Ekee")
local CROWN_OF_KINGS_ID = FourCC("ckng")

local WINDWALK_ID = FourCC("AOwk")
local CRITICAL_STRIKE_ID = FourCC("AOcr")
local SHOCKWAVE_ID = FourCC("AOsh")
local ENDURANCE_AURA_ID = FourCC("AOae")
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

local COURSE_SETUPS = {
    {
        id = "human", title = "Human",
        units = {FOOTMAN_ID, MOUNTAIN_KING_ID, SPELL_BREAKER_ID,
            RIFLEMAN_ID, FOOTMAN_ID, RIFLEMAN_ID, SPELL_BREAKER_ID,
        },
    },
    {
        id = "orc", title = "Orc",
        units = {GRUNT_ID, BLADEMASTER_ID, TAUREN_ID,
            TROLL_BERSERKER_ID, GRUNT_ID, TROLL_BERSERKER_ID,
            TAUREN_ID},
    },
    {
        id = "undead", title = "Undead",
        units = {GHOUL_ID, DEATH_KNIGHT_ID, GHOUL_ID, GHOUL_ID,
            ABOMINATION_ID, NECROMANCER_ID, GHOUL_ID},
    },
    {
        id = "nightelf", title = "Night Elf",
        units = {HUNTRESS_ID, DEMON_HUNTER_ID, HUNTRESS_ID, DRYAD_ID,
            DRUID_OF_THE_CLAW_ID, DRYAD_ID, DRUID_OF_THE_CLAW_ID,
        },
    },
}

local function IsCourseMode(mode)
    return mode == "hard" or mode == "counterplay"
end

local function CopyArray(source)
    local result = {}
    for index = 1, 4 do result[index] = (source or {})[index] end
    return result
end

local function CreateRandomCourseOrder()
    local order = {1, 2, 3, 4}
    for index = #order, 2, -1 do
        local other = GetRandomInt(1, index)
        order[index], order[other] = order[other], order[index]
    end
    return order
end

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
        if IsCourseMode(mode) then
            restartData.courseOrder = CreateRandomCourseOrder()
            restartData.courseStage = 1
            restartData.courseResults = {}
        end
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
                    x = 0,
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
            headingArtworkCenterX = 0.1993,
            headingArtworkTopOffset = -0.027,
            body = FormatBriefingText(WINDWALK_POP_INTRO),
            choices = choices,
            backAction = backAction,
            pauseGame = pauseGame == true,
            pageId = page,
            restoreData = selection,
        }
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
    local selectedMode = selection.mode or "normal"
    local courseOrder = CopyArray(selection.courseOrder)
    if IsCourseMode(selectedMode) and #courseOrder ~= #COURSE_SETUPS then
        courseOrder = CreateRandomCourseOrder()
    end
    local activity = {
        mode = selectedMode,
        blademaster = nil,
        surroundee = nil,
        humanArmy = {},
        quests = {},
        highlightQuestOnStart = selection.skipQuestHighlight ~= true,
        timedStage = math.max(1, math.min(10, selection.timedStage or 1)),
        timedTargets = {},
        timedRings = {},
        timedPending = {},
        timedCompleted = 0,
        popOriginX = nil,
        popOriginY = nil,
        timedRemaining = 5.0,
        courseOrder = courseOrder,
        courseStage = math.max(1, math.min(4, selection.courseStage or 1)),
        courseResults = CopyArray(selection.courseResults),
        finished = false,
        resultPending = false,
        resultKind = nil,
        resultTitleText = nil,
        resultDetailsText = nil,
        resultCard = nil,
        resultBackdrop = nil,
        timerFrame = nil,
        countdownFrame = nil,
        countdownTimer = nil,
        countdownValue = 3,
        countdownActive = false,
        counterplayArmy = {},
        exerciseStarted = false,
        squaresVisible = selection.squaresVisible == true,
        squareGridVisible = selection.squareGridVisible == true,
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
        local centerX = JTG.UnitObstructionGridCenter(GetUnitX(unit))
        local centerY = JTG.UnitObstructionGridCenter(GetUnitY(unit))
        local texture = (GetOwningPlayer(unit) == Player(0) or
            self:isCounterplayArmyUnit(unit)) and
            JTG.UnitSquarePlayerTexture or JTG.UnitSquareEnemyTexture
        local image = JTG.ScopeTrackImage(session.presentationScope,
            CreateImage(texture, size, size, 0,
                centerX - half, centerY - half, 2,
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
    end

    function activity:updateSquareOverlays()
        JTG.ShowNavigationGrid(self.navigationGridImages,
            self.squareGridVisible and self.presentationVisible)
        for _, entry in ipairs(self.squareEntries) do
            if entry.unit ~= nil and GetUnitTypeId(entry.unit) ~= 0 then
                local centerX = JTG.UnitObstructionGridCenter(GetUnitX(entry.unit))
                local centerY = JTG.UnitObstructionGridCenter(GetUnitY(entry.unit))
                SetImagePosition(entry.image, centerX - entry.half,
                    centerY - entry.half, 2)
                ShowImage(entry.image,
                    self.squaresVisible and self.presentationVisible)
            end
        end
        -- Draw snap points last so they remain legible over both the fine
        -- grid and the colored obstruction squares.
        JTG.ShowNavigationGrid(self.navigationDotsImages,
            self.squaresVisible and self.presentationVisible)
    end

    function activity:toggleSquares()
        if not self.squaresVisible then
            self.squaresVisible = true
            self.squareGridVisible = false
        elseif not self.squareGridVisible then
            self.squareGridVisible = true
        else
            self.squaresVisible = false
            self.squareGridVisible = false
        end
        self:updateSquareOverlays()
        if JTG.UI and JTG.UI.SetSquaresActive then
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
    end

    function activity:currentCourseSetup()
        return COURSE_SETUPS[self.courseOrder[self.courseStage]]
    end

    function activity:captureCourseState(stage)
        return {
            mode = self.mode,
            courseOrder = CopyArray(self.courseOrder),
            courseStage = stage or self.courseStage,
            courseResults = CopyArray(self.courseResults),
            skipQuestHighlight = true,
            squaresVisible = self.squaresVisible,
            squareGridVisible = self.squareGridVisible,
        }
    end

    function activity:openCourseStage(stage, reason)
        if not IsCourseMode(self.mode) or stage < 1 or stage > 4 then
            return false
        end
        return JTG.StartActivityAfterCleanup(session.id,
            JTG.Controller.lastCategory, self:captureCourseState(stage), nil,
            reason or "windwalk-course-stage")
    end

    function activity:nextStage()
        if not IsCourseMode(self.mode) or self.courseStage >= 4 then
            return false
        end
        return self:openCourseStage(self.courseStage + 1,
            "windwalk-course-next")
    end

    function activity:captureLastRunnerState()
        if not IsCourseMode(self.mode) or self.courseStage <= 1 then return nil end
        return self:captureCourseState(self.courseStage - 1)
    end

    function activity:toolbarCapabilities()
        if not IsCourseMode(self.mode) then
            return session.descriptor.capabilities
        end
        local capabilities = {}
        for key, value in pairs(session.descriptor.capabilities or {}) do
            capabilities[key] = value
        end
        capabilities.next = true
        capabilities.lastRunner = true
        return capabilities
    end

    function activity:refreshCourseToolbar()
        if not JTG.UI or not IsCourseMode(self.mode) then return end
        JTG.UI.SetLastRunnerEnabled(self.courseStage > 1)
        JTG.UI.SetNextEnabled(self.courseStage < 4)
    end

    activity.resultActions = {
        next = function(self)
            if self.mode == "timed" and self.resultKind == "success" then
                if self.timedStage < 10 then
                    self.timedStage = self.timedStage + 1
                else
                    self.timedStage = 1
                end
                JTG.ResetActivity()
            elseif IsCourseMode(self.mode) then
                if self.courseStage < 4 then
                    self:openCourseStage(self.courseStage + 1,
                        "windwalk-course-result-next")
                else
                    self.courseResults = {}
                    self:openCourseStage(1, "windwalk-course-restart")
                end
            else
                JTG.ResetActivity()
            end
        end,
    }

    function activity:createResultUI()
        self.resultCard = JTG.UI.CreateResultCard(session, {
            name = "JTGWindwalkPopResult", width = 0.36,
            detailsHeight = 0.070, centerY = 0.325,
            titleScale = 1.20,
        })
        self.resultBackdrop = self.resultCard.panel
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
        if self.timerFrame == nil then return end
        if self.mode == "timed" then
            BlzFrameSetText(self.timerFrame, "|cffffcc00Stage " ..
                tostring(self.timedStage) .. "|r   Freed " ..
                tostring(self.timedCompleted) .. "/" ..
                tostring(self.timedStage) .. "   |cffffcc00" ..
                string.format("%.1f", math.max(0, self.timedRemaining)) ..
                "|r")
        elseif IsCourseMode(self.mode) then
            local setup = self:currentCourseSetup()
            BlzFrameSetText(self.timerFrame, "|cffffcc00Stage " ..
                tostring(self.courseStage) .. "/4|r   " .. setup.title)
        end
    end

    function activity:renderResultPresentation()
        if self.resultCard == nil then return end
        local showPrimary = (self.mode == "timed" and
            self.resultKind == "success") or IsCourseMode(self.mode)
        local primary = "Next"
        if self.mode == "timed" and showPrimary then
            primary = self.timedStage < 10 and "Next Stage" or "Restart Course"
        elseif IsCourseMode(self.mode) then
            primary = self.courseStage < 4 and "Next Stage" or "Restart Course"
        end
        JTG.UI.ShowResultCard(self.resultCard, {
            title = self.resultTitleText or "",
            tone = self.resultKind,
            details = self.resultDetailsText or "",
            actions = {
                replay = {},
                next = showPrimary and {label = primary} or nil,
                menu = {},
            },
        })
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

    function activity:isCounterplayArmyUnit(unit)
        return unit ~= nil and self.counterplayArmy[GetHandleId(unit)] == true
    end

    function activity:prepareCounterplayArmy()
        if self.mode ~= "counterplay" then return end
        self.counterplayArmy = {}
        for _, unit in ipairs(self.humanArmy) do
            self.counterplayArmy[GetHandleId(unit)] = true
            SetUnitOwner(unit, Player(PLAYER_NEUTRAL_PASSIVE), true)
        end
    end

    function activity:releaseCounterplayArmy()
        if self.mode ~= "counterplay" then return end
        for _, unit in ipairs(self.humanArmy) do
            SetUnitOwner(unit, Player(0), true)
        end
        if GetLocalPlayer() == Player(0) then
            ClearSelection()
            for _, unit in ipairs(self.humanArmy) do SelectUnit(unit, true) end
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

    function activity:startCourseCountdownFormation()
        for _, unit in ipairs(self.humanArmy) do PauseUnit(unit, false) end
        local moveCount = 0
        local function issueFormationOrder()
            moveCount = moveCount + 1
            for _, unit in ipairs(self.humanArmy) do
                if moveCount <= 4 then
                    IssueTargetOrder(unit, "move", self.surroundee)
                else
                    IssueTargetOrder(unit, "attack", self.surroundee)
                end
            end
            if self.mode == "counterplay" and moveCount == 3 then
                PauseUnit(self.surroundee, false)
                IssuePointOrder(self.surroundee, "move",
                    GetUnitX(self.surroundee) + 500.0,
                    GetUnitY(self.surroundee) - 300.0)
            end
            return moveCount >= 5
        end
        issueFormationOrder()
        local moveTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(moveTimer, 0.60, true,
            JTG.GuardSession(session, function()
                if not issueFormationOrder() then return end
                PauseTimer(moveTimer)
            end))
    end

    function activity:beginExercise()
        if self.exerciseStarted or self.finished then return end
        self.exerciseStarted = true
        self.countdownActive = false
        self:releaseCounterplayArmy()
        self:setTrainingUnitsPaused(false)
        local centerX = session.scene.centerX
        local centerY = session.scene.centerY
        if self.mode == "normal" then
            self:startBasicSurround()
            self:startPopDetection()
        elseif self.mode == "hard" then
            self:startPopDetection()
        elseif self.mode == "timed" then
            self:startPopDetection()
            self:updateTimerUI()
            BlzFrameSetVisible(self.timerFrame, true)
        else
            -- Give the player a brief window after GO to loosen or tighten the
            -- completed surround before the automated pop begins.
            local adjustmentTimer = JTG.ScopeTrackTimer(session.scope,
                CreateTimer())
            TimerStart(adjustmentTimer, 2.0, false,
                JTG.GuardSession(session, function()
                    self:startCounterplayAttempt(centerX, centerY)
                end))
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
        if IsCourseMode(self.mode) then self:startCourseCountdownFormation() end
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
        if IsCourseMode(self.mode) then
            local setup = self:currentCourseSetup()
            self.courseResults[self.courseStage] = kind
            if self.courseStage >= 4 then
                local successes = 0
                for index = 1, 4 do
                    if self.courseResults[index] == "success" then
                        successes = successes + 1
                    end
                end
                self.resultKind = successes == 4 and "success" or "failure"
                self.resultTitleText = "COURSE COMPLETE"
                self.resultDetailsText = setup.title .. ": " .. title ..
                    "|nYou completed " .. tostring(successes) ..
                    " of 4 stages successfully."
            else
                self.resultKind = kind
                self.resultTitleText = title
                self.resultDetailsText = "Stage " ..
                    tostring(self.courseStage) .. "/4 - " .. setup.title ..
                    "|n" .. details
            end
        else
            self.resultKind = kind
            self.resultTitleText = title
            self.resultDetailsText = details
        end
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
        self.timedRemaining = 5.0
        self.timedPending = {}
        self.timedCompleted = 0
        self.surroundee = self.timedTargets[1]
        self.humanArmy = self.timedRings[1]
        local firstX, firstY = GetUnitX(self.surroundee),
            GetUnitY(self.surroundee)
        self:createBlademaster(Player(0), firstX - 360.0, firstY - 240.0,
            45.0)
    end

    function activity:createCourseArmy(owner, centerX, centerY)
        local setup = self:currentCourseSetup()
        self.humanArmy = {}
        local radius = 300.0
        for index, unitId in ipairs(setup.units) do
            local angle = (index - 1) * bj_PI * 0.25
            local x = centerX + radius * Sin(angle)
            local y = centerY + radius * Cos(angle)
            local facing = math.deg(Atan2(centerY - y, centerX - x))
            local unit = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(owner, unitId, x, y, facing, unitId))
            table.insert(self.humanArmy, unit)
        end
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

    function activity:startCounterplayResolution(centerX, centerY)
        local originX = GetUnitX(self.surroundee)
        local originY = GetUnitY(self.surroundee)
        local elapsed = 0.0
        local escapeX, escapeY = centerX + 350.0, centerY
        local resolutionTimer = JTG.ScopeTrackTimer(session.scope,
            CreateTimer())
        TimerStart(resolutionTimer, 0.05, true,
            JTG.GuardSession(session, function()
                if self.finished then PauseTimer(resolutionTimer) return end
                elapsed = elapsed + 0.05
                local x, y = GetUnitX(self.surroundee),
                    GetUnitY(self.surroundee)
                local totalDx, totalDy = x - originX, y - originY
                if totalDx * totalDx + totalDy * totalDy >= 100.0 * 100.0 then
                    PauseTimer(resolutionTimer)
                    self:finish("failure", "TAUREN CHIEFTAIN ESCAPED",
                        "The Tauren Chieftain escaped the surround after the " ..
                        "Windwalk Pop.")
                    return
                end
                for _, unit in ipairs(self.humanArmy) do
                    local dx, dy = GetUnitX(unit) - centerX,
                        GetUnitY(unit) - centerY
                    if dx * dx + dy * dy >= 500.0 * 500.0 then
                        PauseTimer(resolutionTimer)
                        self:finish("failure", "SURROUND BROKEN",
                            "A surrounding unit moved too far from the " ..
                            "encounter before the escape attempt finished.")
                        return
                    end
                end
                -- Repeat a fixed ground order so combat acquisition cannot
                -- turn the test into a chase after one of the player's units.
                if math.floor(elapsed * 20.0 + 0.5) % 5 == 0 then
                    IssuePointOrder(self.surroundee, "move", escapeX, escapeY)
                end
                if elapsed >= 3.0 then
                    PauseTimer(resolutionTimer)
                    self:finish("success", "COUNTERPLAY SUCCESSFUL",
                        "The Tauren Chieftain remained trapped after the " ..
                        "Windwalk Pop.")
                    return
                end
            end))
        IssuePointOrder(self.surroundee, "move", escapeX, escapeY)
    end

    function activity:startCounterplayAttempt(centerX, centerY)
        IssueImmediateOrder(self.blademaster, "windwalk")
        local windwalkTicks = 0
        local windwalkTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(windwalkTimer, 0.05, true,
            JTG.GuardSession(session, function()
                windwalkTicks = windwalkTicks + 1
                if not IsUnitInvisible(self.blademaster, Player(0)) then
                    if windwalkTicks == 40 then
                        IssueImmediateOrder(self.blademaster, "windwalk")
                    elseif windwalkTicks >= 80 then
                        PauseTimer(windwalkTimer)
                        self:finish("failure", "WIND WALK FAILED",
                            "The automated Blademaster could not activate " ..
                            "Wind Walk. Redo this stage to try again.")
                    end
                    return
                end
                PauseTimer(windwalkTimer)
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
                        if dx * dx + dy * dy > 75.0 * 75.0 and
                                enteredTicks < 30 then return end
                        PauseTimer(enterTimer)
                        if dx * dx + dy * dy > 75.0 * 75.0 then
                            -- No overlap means no pop is possible. Test
                            -- whether the TC is still trapped without letting
                            -- the Blademaster chase a distant target.
                            IssueImmediateOrder(self.blademaster,
                                "holdposition")
                            self:startCounterplayResolution(centerX, centerY)
                            return
                        end
                        local attackTarget = nil
                        local nearestDistance = nil
                        for _, unit in ipairs(self.humanArmy) do
                            local targetDx = GetUnitX(unit) -
                                GetUnitX(self.blademaster)
                            local targetDy = GetUnitY(unit) -
                                GetUnitY(self.blademaster)
                            local distance = targetDx * targetDx +
                                targetDy * targetDy
                            if nearestDistance == nil or
                                    distance < nearestDistance then
                                nearestDistance = distance
                                attackTarget = unit
                            end
                        end
                        if attackTarget ~= nil then
                            IssueTargetOrder(self.blademaster, "attack",
                                attackTarget)
                        end
                        local visibilityTicks = 0
                        local visibilityTimer = JTG.ScopeTrackTimer(
                            session.scope, CreateTimer())
                        TimerStart(visibilityTimer, 0.03, true,
                            JTG.GuardSession(session, function()
                                visibilityTicks = visibilityTicks + 1
                                if IsUnitInvisible(self.blademaster,
                                        Player(0)) and
                                        visibilityTicks < 25 then return end
                                PauseTimer(visibilityTimer)
                                if IsUnitInvisible(self.blademaster,
                                        Player(0)) then
                                    IssueImmediateOrder(self.blademaster,
                                        "holdposition")
                                    self:finish("failure",
                                        "POP ATTEMPT FAILED",
                                        "The automated Blademaster could not " ..
                                        "end Wind Walk cleanly. Redo this " ..
                                        "stage to try again.")
                                    return
                                end
                                IssueImmediateOrder(self.blademaster,
                                    "holdposition")
                                self:startCounterplayResolution(centerX,
                                    centerY)
                            end))
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
            self:createBlademaster(p0, centerX - 500.0, centerY, 0.0)
            self.surroundee = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(p0, TAUREN_CHIEFTAIN_ID, centerX,
                    centerY, 270.0, TAUREN_CHIEFTAIN_ID))
            PrepareHero(self.surroundee,
                {{SHOCKWAVE_ID, 2}, {ENDURANCE_AURA_ID, 1}})
            UnitAddItemById(self.surroundee, CROWN_OF_KINGS_ID)
            -- Counterplay tests displacement, not the computer player's
            -- target acquisition. Prevent the TC from chasing surrounders.
            UnitRemoveAbility(self.surroundee, FourCC("Aatk"))
            IssueImmediateOrder(self.surroundee, "holdposition")
            self:createCourseArmy(p1, centerX, centerY)
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
            self:createBlademaster(p1, centerX - 500.0, centerY, 0.0)
            self:createCourseArmy(p0, centerX, centerY)
        end

        if GetLocalPlayer() == p0 then
            ClearSelection()
            if self.mode ~= "counterplay" then
                SelectUnit(self.blademaster, true)
            end
        end
    end

    function activity:setup(current)
        self.scene = current.scene
        local p0 = Player(0)
        local p1 = Player(1)
        JTG.BorrowCamera(current.scope, p0)

        local passive01 = GetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE)
        local passive10 = GetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE)
        local oldController = GetPlayerController(p1)
        local oldColor = GetPlayerColor(p1)
        JTG.ScopeBorrow(current.scope, function()
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
        self:prepareCounterplayArmy()
        self:createSquareOverlays()
        self.squareTimer = JTG.ScopeTrackTimer(current.scope, CreateTimer())
        TimerStart(self.squareTimer, 0.03, true,
            JTG.GuardSession(current, function()
                self:updateSquareOverlays()
            end))
        self:createTrainingQuests()
        self.navigationGridImages = JTG.CreateNavigationGridOverlay(
            session.presentationScope, current.scene)
        self.navigationDotsImages = JTG.CreateNavigationDotsOverlay(
            session.presentationScope, current.scene)
        self:updateSquareOverlays()
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
        if IsCourseMode(self.mode) then
            self:updateTimerUI()
            BlzFrameSetVisible(self.timerFrame, true)
            JTG.UI.ShowToolbar(self:toolbarCapabilities())
            self:refreshCourseToolbar()
        end
        self:startCountdown()
    end

    function activity:captureResetState()
        if IsCourseMode(self.mode) then
            return self:captureCourseState(self.courseStage)
        end
        return {mode = self.mode, timedStage = self.timedStage,
            skipQuestHighlight = true, squaresVisible = self.squaresVisible,
            squareGridVisible = self.squareGridVisible}
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
            if IsCourseMode(self.mode) then
                self:updateTimerUI()
                BlzFrameSetVisible(self.timerFrame, true)
            end
            if JTG.UI then
                JTG.UI.ShowToolbar(self:toolbarCapabilities())
                JTG.UI.SetSquaresActive(self.squaresVisible)
                self:refreshCourseToolbar()
            end
        else
            if self.timerFrame ~= nil then
                BlzFrameSetVisible(self.timerFrame,
                    self.mode == "timed" or IsCourseMode(self.mode))
                self:updateTimerUI()
            end
            if JTG.UI then
                JTG.UI.ShowToolbar(self:toolbarCapabilities())
                JTG.UI.SetSquaresActive(self.squaresVisible)
                self:refreshCourseToolbar()
            end
        end
    end

    function activity:hidePresentationForMenu()
        self.presentationVisible = false
        if self.timerFrame ~= nil then BlzFrameSetVisible(self.timerFrame, false) end
        if self.countdownFrame ~= nil then
            BlzFrameSetVisible(self.countdownFrame, false)
        end
        JTG.UI.HideResultCard(self.resultCard)
        self:updateSquareOverlays()
    end

    function activity:rebuildPresentation()
        self.resultCard = nil
        self.resultBackdrop = nil
        self.timerFrame = nil
        self.countdownFrame = nil
        self.navigationGridImages = JTG.CreateNavigationGridOverlay(
            session.presentationScope, self.scene)
        self.navigationDotsImages = JTG.CreateNavigationDotsOverlay(
            session.presentationScope, self.scene)
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
            if IsCourseMode(self.mode) then
                self:updateTimerUI()
                BlzFrameSetVisible(self.timerFrame, true)
            end
        elseif self.mode == "timed" or IsCourseMode(self.mode) then
            self:updateTimerUI()
            BlzFrameSetVisible(self.timerFrame, true)
        end
    end

    function activity:discardPresentationForLoad()
        self.resultCard = nil
        self.resultBackdrop = nil
        self.timerFrame = nil
        self.countdownFrame = nil
        self.squareEntries = {}
        self.navigationGridImages = {}
        self.navigationDotsImages = {}
    end

    function activity:cleanup()
        if JTG.UI then JTG.UI.HideActivityBriefing() end
        self.blademaster = nil
        self.surroundee = nil
        self.humanArmy = {}
        self.quests = {}
        self.timedTargets = {}
        self.timedRings = {}
        self.timedPending = {}
        self.timedCompleted = 0
        self.counterplayArmy = {}
        self.popOriginX = nil
        self.popOriginY = nil
        self.squareEntries = {}
    end

    return activity
end
